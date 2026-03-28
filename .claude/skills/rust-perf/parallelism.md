# Parallelism

## What to Look For

- **CPU-bound loops processing independent items sequentially**: `for item in items { process(item); }` where each `process` call is independent and expensive.
- **Sequential iteration over large collections**: `items.iter().map(expensive_fn).collect()` — if the items are independent, this can be parallelized.
- **Batch processing pipelines**: Multi-stage pipelines where each stage could run on different threads.
- **Single-threaded bottlenecks in otherwise concurrent applications**: One thread doing all the work while others are idle.

### Search Patterns

```
# Large sequential loops (candidates for par_iter)
for .* in .*\.iter()
\.iter()\.map(
\.iter()\.for_each(

# Check if rayon is already in use
rayon
par_iter
par_bridge
into_par_iter

# Check if crossbeam is in use
crossbeam
```

## How to Fix

### Use `rayon` for data parallelism

```rust
// BEFORE — sequential
let results: Vec<_> = items.iter()
    .map(|item| expensive_process(item))
    .collect();

// AFTER — parallel
use rayon::prelude::*;
let results: Vec<_> = items.par_iter()
    .map(|item| expensive_process(item))
    .collect();
```

### Parallelize independent loop iterations

```rust
// BEFORE
for item in &mut items {
    item.transform();
}

// AFTER
use rayon::prelude::*;
items.par_iter_mut().for_each(|item| {
    item.transform();
});
```

### Use scoped threads for heterogeneous parallel work

```rust
// BEFORE — sequential
let a = compute_a();
let b = compute_b();
let result = combine(a, b);

// AFTER — parallel
use std::thread;
let (a, b) = thread::scope(|s| {
    let handle_a = s.spawn(|| compute_a());
    let b = compute_b();
    let a = handle_a.join().expect("thread panicked");
    (a, b)
});
let result = combine(a, b);
```

## Caveats

- Parallelism adds overhead (thread pool, synchronization, scheduling). Only parallelize work that is expensive enough to amortize this overhead.
- `rayon` uses a global thread pool by default, which can conflict with other uses of rayon in the same process.
- Parallelism can introduce non-determinism in output ordering. Use `par_iter().collect()` to preserve order, but note this has synchronization cost.
- Not all work is parallelizable — shared mutable state, I/O bottlenecks, and dependencies between iterations all limit parallelism.
- Thread contention on shared resources (allocators, locks, I/O) can make parallel code slower than sequential.
