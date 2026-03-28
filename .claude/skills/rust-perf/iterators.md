# Iterators

## What to Look For

- **`.collect()` followed by iteration**: Collecting into an intermediate `Vec` just to iterate again wastes an allocation. Return `impl Iterator` instead.
- **`.collect()` + `.append()` instead of `.extend()`**: Extending a collection directly from an iterator avoids an intermediate allocation.
- **`.chain()` in hot loops**: Chained iterators add per-element overhead. A manual loop or flattened approach may be faster.
- **`.filter().map()` instead of `.filter_map()`**: `filter_map` combines both operations and can be faster.
- **`.chunks()` when `.chunks_exact()` would work**: `chunks_exact` gives the compiler more information, enabling better optimization and eliminating bounds checks.
- **`iter()` on small Copy types where `iter().copied()` is better**: For small types like integers, iterating by value (via `.copied()`) can produce better codegen than iterating by reference.
- **Missing `size_hint` / `ExactSizeIterator` on custom iterators**: These enable `collect` and `extend` to pre-allocate, reducing reallocations.

### Search Patterns

```
# Collect followed by iteration (unnecessary intermediate Vec)
\.collect::<Vec
\.collect()

# Chain in hot paths
\.chain(

# Filter then map (could be filter_map)
\.filter(.*\.map(

# chunks (could be chunks_exact)
\.chunks(

# Custom iterator impls missing size_hint
impl Iterator
```

## How to Fix

### Return iterators instead of collecting

```rust
// BEFORE — allocates a Vec just to return items
fn get_even(items: &[i32]) -> Vec<i32> {
    items.iter().filter(|x| *x % 2 == 0).copied().collect()
}

// AFTER — no allocation, lazy evaluation
fn get_even(items: &[i32]) -> impl Iterator<Item = i32> + '_ {
    items.iter().filter(|x| *x % 2 == 0).copied()
}
```

### Use `extend` instead of `collect` + `append`

```rust
// BEFORE
let extra: Vec<_> = source.iter().map(transform).collect();
dest.extend(extra);

// AFTER
dest.extend(source.iter().map(transform));
```

### Use `filter_map` instead of `filter` + `map`

```rust
// BEFORE
items.iter()
    .filter(|x| x.value.is_some())
    .map(|x| x.value.unwrap())

// AFTER
items.iter()
    .filter_map(|x| x.value)
```

### Use `chunks_exact` instead of `chunks`

```rust
// BEFORE
for chunk in data.chunks(4) {
    // compiler doesn't know chunk.len() == 4
    process(chunk[0], chunk[1], chunk[2], chunk[3]);
}

// AFTER
for chunk in data.chunks_exact(4) {
    // compiler knows chunk.len() == 4, bounds checks eliminated
    process(chunk[0], chunk[1], chunk[2], chunk[3]);
}
// Handle remainder if needed:
let remainder = data.chunks_exact(4).remainder();
```

### Use `.copied()` for small types

```rust
// BEFORE — iterates by reference (&i32)
let sum: i32 = numbers.iter().sum();

// AFTER — iterates by value (i32), potentially better codegen
let sum: i32 = numbers.iter().copied().sum();
```

## Caveats

- Returning `impl Iterator` can require complex lifetime annotations.
- `chunks_exact` drops remainder elements silently — handle them explicitly if they matter.
- `.copied()` benefits are subtle and depend on what LLVM does; check generated assembly to confirm improvement.
- Avoiding `.chain()` can make code less readable — only optimize if the iterator is genuinely hot.
