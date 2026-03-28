# Heap Allocations

## What to Look For

- **`Vec::new()` / `vec![]` followed by repeated `push`**: Missing `with_capacity` when the size is known or estimable.
- **Short `Vec`s that could use `SmallVec` or `ArrayVec`**: Vectors that almost always have a small, bounded number of elements.
- **`Vec` that never grows after creation**: Candidates for `Box<[T]>` (boxed slice) to save one word per instance.
- **Unnecessary `.clone()` calls**: Cloning heap-allocated data when a reference would suffice.
- **`format!()` where a string literal would work**: `format!` always allocates a `String`.
- **`to_owned()` / `to_string()` on static data**: Could use `Cow<'static, str>` instead.
- **Allocating inside a loop**: Collections declared inside a loop body that could be hoisted out and reused via `.clear()`.
- **`BufRead::lines()`**: Allocates a new `String` per line; `read_line` with a reused buffer is cheaper.
- **Functions returning `Vec<T>` called repeatedly**: Consider taking `&mut Vec<T>` to allow callers to reuse the allocation.

### Search Patterns

```
# Vecs without capacity hints
Vec::new()
vec!\[\]

# Clone calls (check if hot/unnecessary)
\.clone()

# format! calls that could be string literals
format!

# to_owned / to_string on literals
\.to_owned()
\.to_string()

# Lines iterator (allocates per line)
\.lines()

# SmallVec already in use?
SmallVec
smallvec

# Functions returning Vec
-> Vec<
```

## How to Fix

### Pre-allocate with known capacity

```rust
// BEFORE
let mut results = Vec::new();
for item in items {
    results.push(process(item));
}

// AFTER
let mut results = Vec::with_capacity(items.len());
for item in items {
    results.push(process(item));
}
```

### Use `SmallVec` for short vectors

```rust
// BEFORE
let mut parts: Vec<&str> = line.split(',').collect();

// AFTER
use smallvec::{SmallVec, smallvec};
let mut parts: SmallVec<[&str; 8]> = line.split(',').collect();
```

### Convert finalized `Vec` to boxed slice

```rust
// BEFORE — stored in a long-lived struct, never modified after creation
struct Data {
    items: Vec<u32>,
}

// AFTER — saves one word (capacity field)
struct Data {
    items: Box<[u32]>,
}
// Construct with: items.into_boxed_slice()
```

### Reuse collections across loop iterations

```rust
// BEFORE — allocates every iteration
for batch in batches {
    let mut buffer = Vec::new();
    process(batch, &mut buffer);
    consume(&buffer);
}

// AFTER — reuses allocation
let mut buffer = Vec::new();
for batch in batches {
    buffer.clear();
    process(batch, &mut buffer);
    consume(&buffer);
}
```

### Use `Cow` for mixed borrowed/owned data

```rust
// BEFORE
let mut errors: Vec<String> = vec![];
errors.push("static error".to_owned());
errors.push(format!("dynamic error on line {}", n));

// AFTER
use std::borrow::Cow;
let mut errors: Vec<Cow<'static, str>> = vec![];
errors.push(Cow::Borrowed("static error"));
errors.push(format!("dynamic error on line {}", n).into());
```

### Use `clone_from` to reuse existing allocations

```rust
// BEFORE — always allocates
destination = source.clone();

// AFTER — reuses destination's allocation if large enough
destination.clone_from(&source);
```

### Avoid per-line allocations when reading files

```rust
// BEFORE — allocates a String per line
for line in reader.lines() {
    process(&line?);
}

// AFTER — reuses one String buffer
let mut line = String::new();
while reader.read_line(&mut line)? != 0 {
    process(&line);
    line.clear();
}
```

## Caveats

- `SmallVec` is slightly slower than `Vec` for normal operations due to the inline-vs-heap check. Only use it when profiling confirms many short vectors.
- `Box<[T]>` cannot grow — only use for truly immutable collections.
- Hoisting collections out of loops obscures the independence of iterations; only do it for hot loops.
- `Cow` adds API complexity — only worthwhile when the borrowed case is common.
