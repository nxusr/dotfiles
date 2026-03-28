# Bounds Checks

## What to Look For

- **Indexing into slices/Vecs inside hot loops**: Each `container[i]` includes a bounds check. The compiler can sometimes elide them, but not always.
- **Indexing a `Vec` instead of a slice**: Slicing the `Vec` before the loop (`let slice = &vec[..]`) gives the compiler a fixed-length reference, helping elide checks.
- **Missing length assertions before indexed loops**: An `assert!(idx < slice.len())` before the loop can help the compiler prove bounds checks are unnecessary inside the loop.
- **Using indexing when iteration would work**: `for item in &slice` never needs bounds checks; `for i in 0..slice.len() { slice[i] }` does.

### Search Patterns

```
# Direct indexing in loops (potential bounds checks)
\[i\]
\[idx\]
\[index\]

# Loops that index rather than iterate
for .* in 0\.\.

# get_unchecked (existing unsafe bounds-check elision)
get_unchecked
```

## How to Fix

### Replace indexed loops with iteration

```rust
// BEFORE — bounds check on every access
for i in 0..data.len() {
    process(data[i]);
}

// AFTER — no bounds checks
for item in &data {
    process(*item);
}

// or with index needed:
for (i, item) in data.iter().enumerate() {
    process(i, *item);
}
```

### Slice a Vec before a loop

```rust
// BEFORE — bounds check on every access
fn process(vec: &Vec<u32>) {
    for i in 0..vec.len() {
        do_thing(vec[i]);
    }
}

// AFTER — slice helps compiler elide bounds checks
fn process(vec: &Vec<u32>) {
    let slice = &vec[..];
    for i in 0..slice.len() {
        do_thing(slice[i]);
    }
}
```

### Add assertions to help the compiler

```rust
// BEFORE — compiler can't prove a < data.len() and b < data.len()
fn swap_values(data: &mut [u32], a: usize, b: usize) {
    let tmp = data[a]; // bounds check
    data[a] = data[b]; // bounds check
    data[b] = tmp;     // bounds check
}

// AFTER — single assertion, compiler elides subsequent checks
fn swap_values(data: &mut [u32], a: usize, b: usize) {
    assert!(a < data.len() && b < data.len());
    let tmp = data[a];
    data[a] = data[b];
    data[b] = tmp;
}
```

### Use `zip` for parallel iteration

```rust
// BEFORE — two bounds checks per iteration
for i in 0..a.len().min(b.len()) {
    a[i] += b[i];
}

// AFTER — no bounds checks
for (x, y) in a.iter_mut().zip(b.iter()) {
    *x += *y;
}
```

## Caveats

- Most bounds checks are cheap (a comparison + branch that's almost never taken). Only optimize in genuinely hot loops confirmed by profiling.
- `get_unchecked` is `unsafe` and should be an absolute last resort. Prefer safe approaches (iteration, assertions, slicing).
- Adding assertions changes behavior — a panic instead of a bounds-check panic has a different message. This is fine for internal code but worth noting.
