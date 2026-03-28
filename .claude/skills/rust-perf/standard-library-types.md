# Standard Library Types

## What to Look For

- **`Vec::remove()` in hot paths**: This is O(n) because it shifts elements. If order doesn't matter, `swap_remove` is O(1).
- **Eager evaluation in `Option`/`Result` methods**: `ok_or`, `map_or`, `unwrap_or` evaluate their arguments eagerly even when the value is `Some`/`Ok`. Use the `_else` variants for expensive fallbacks.
- **`std::sync::Mutex` / `RwLock` in contended hot paths**: The `parking_lot` crate provides faster implementations on most platforms.

### Search Patterns

```
# Vec::remove (O(n) — consider swap_remove)
\.remove(

# Eager Option/Result methods with expensive arguments
\.ok_or(
\.map_or(
\.unwrap_or(

# Standard library sync primitives
use std::sync::Mutex
use std::sync::RwLock
std::sync::Condvar
std::sync::Once

# Check if parking_lot is already used
parking_lot
```

## How to Fix

### Replace `Vec::remove` with `Vec::swap_remove`

```rust
// BEFORE — O(n), shifts all subsequent elements
items.remove(idx);

// AFTER — O(1), swaps with last element (changes order)
items.swap_remove(idx);
```

### Use lazy evaluation for Option/Result fallbacks

```rust
// BEFORE — expensive() always runs, even when value is Some
let result = maybe_value.ok_or(expensive_computation());
let val = maybe_value.unwrap_or(create_default());
let mapped = maybe_value.map_or(fallback(), |v| transform(v));

// AFTER — closures only run when needed
let result = maybe_value.ok_or_else(|| expensive_computation());
let val = maybe_value.unwrap_or_else(|| create_default());
let mapped = maybe_value.map_or_else(|| fallback(), |v| transform(v));
```

### Use `Vec::retain` for bulk removal

```rust
// BEFORE — manual iteration with remove (O(n²))
let mut i = 0;
while i < items.len() {
    if should_remove(&items[i]) {
        items.remove(i);
    } else {
        i += 1;
    }
}

// AFTER — single O(n) pass
items.retain(|item| !should_remove(item));
```

### Zero-fill a Vec efficiently

```rust
// BEFORE — various suboptimal approaches
let mut v = Vec::with_capacity(n);
for _ in 0..n { v.push(0); }

// AFTER — uses OS-assisted zeroing
let v = vec![0u8; n];
```

## Caveats

- `swap_remove` does NOT preserve element order — only use it when order is irrelevant.
- The `_else` variants only matter when the fallback argument is expensive to compute. For cheap values like literals, the eager version is fine.
- `parking_lot` types have different APIs and semantics from std types (e.g., no poisoning). Measure before switching, as std primitives have improved significantly.
