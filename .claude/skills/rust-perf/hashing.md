# Hashing

## What to Look For

- **`HashMap` / `HashSet` usage in hot paths**: The default SipHash 1-3 hasher is cryptographically robust but slow, especially for integer keys. If HashDoS is not a concern, a faster hasher can yield large wins.
- **Integer-keyed maps**: These benefit the most from switching to `FxHashMap` / `FxHashSet` (from `rustc-hash`).
- **`#[derive(Hash)]` on structs with no padding**: These might benefit from byte-wise hashing instead of field-by-field hashing.
- **Newtype wrappers around random integers used as keys**: If the wrapped values already have good distribution, consider `nohash_hasher` to skip hashing entirely.

### Search Patterns

```
# Find all HashMap/HashSet usage
HashMap
HashSet
use std::collections::Hash

# Find derive(Hash) on types (candidates for byte-wise hashing)
derive.*Hash

# Check if alternative hashers are already in use
FxHash
AHash
FnvHash
rustc_hash
```

## How to Fix

### Switch to a faster hasher

```rust
// BEFORE
use std::collections::{HashMap, HashSet};
let map: HashMap<u64, Value> = HashMap::new();

// AFTER
use rustc_hash::{FxHashMap, FxHashSet};
let map: FxHashMap<u64, Value> = FxHashMap::default();
```

### Use `nohash_hasher` for already-random integer keys

```rust
// BEFORE — hashing a newtype that wraps a random u64
use std::collections::HashMap;
let map: HashMap<EntityId, Data> = HashMap::new();

// AFTER
use nohash_hasher::IntMap;
let map: IntMap<u64, Data> = IntMap::default();
```

### Use pre-sized maps when the size is known

```rust
// BEFORE
let mut map = HashMap::new();
for item in items {
    map.insert(item.key, item.value);
}

// AFTER
let mut map = HashMap::with_capacity(items.len());
for item in items {
    map.insert(item.key, item.value);
}
```

## Caveats

- `FxHash` is NOT cryptographically secure — do not use it where HashDoS is a concern (e.g., parsing untrusted input into a map).
- Different hashers perform differently depending on key types and sizes — always benchmark.
- Switching from `FxHash` to `AHash` does not always help; in rustc it caused 1-4% slowdowns.
- When standardizing on an alternative hasher, use clippy's `disallowed_types` to prevent accidental use of `std::collections::HashMap`.
