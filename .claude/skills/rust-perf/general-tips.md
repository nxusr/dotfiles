# General Tips

## What to Look For

- **Eager computation of values that may not be needed**: Computing results upfront when they could be deferred until actually used.
- **Generic handling of common special cases**: Code that runs the full general algorithm even when the input is trivially small or has a common shape that allows a fast path.
- **Small collections (0, 1, or 2 elements) handled by general-case code**: When small sizes dominate, specializing for them avoids overhead from allocation, hashing, sorting, etc.
- **Repeated lookups with high locality**: A small inline cache in front of a HashMap or BTree can avoid the full lookup cost.
- **Redundant recomputation**: The same value computed multiple times when it could be cached or memoized.
- **Uniform representation for data with skewed distribution**: When most values fit in a compact form, use a compact primary representation with a fallback table for outliers.

### Search Patterns

```
# Look for opportunities to add fast paths for small sizes
\.len() == 0
\.is_empty()
\.len() == 1
match .* \{

# Lazy computation opportunities
# (functions that compute and return values that callers may not use)
fn .* -> .*\{

# Memoization candidates
# (same function called with same arguments in nearby code)
```

## How to Fix

### Add fast paths for common special cases

```rust
// BEFORE — always runs full algorithm
fn process(items: &[Item]) -> Result {
    let mut state = State::new();
    for item in items {
        state.update(item)?;
    }
    state.finalize()
}

// AFTER — fast paths for common sizes
fn process(items: &[Item]) -> Result {
    match items.len() {
        0 => return Ok(Result::empty()),
        1 => return process_single(&items[0]),
        _ => {}
    }
    let mut state = State::new();
    for item in items {
        state.update(item)?;
    }
    state.finalize()
}
```

### Defer expensive computation

```rust
// BEFORE — always computes debug info
fn analyze(data: &Data) -> Analysis {
    let debug_info = build_debug_info(data); // expensive
    let result = core_analysis(data);
    Analysis { result, debug_info }
}

// AFTER — only compute debug info when accessed
struct Analysis {
    result: CoreResult,
    data: Data,
}

impl Analysis {
    fn debug_info(&self) -> DebugInfo {
        build_debug_info(&self.data)
    }
}
```

### Use compact representation with overflow table

```rust
// BEFORE — uniform u64 for all values, but 99% fit in u8
struct Record {
    tag: u64,
}

// AFTER — compact representation with fallback
struct Record {
    tag: u8, // covers 99% of cases, 0xFF means "check overflow table"
}
// Overflow table: HashMap<RecordId, u64> for the rare large values
```

### Add a small cache for repeated lookups

```rust
// BEFORE — full HashMap lookup every time
fn lookup(&self, key: Key) -> &Value {
    &self.map[&key]
}

// AFTER — cache the last lookup (wins when locality is high)
fn lookup(&mut self, key: Key) -> &Value {
    if self.cached_key == Some(key) {
        return self.cached_value.as_ref().expect("cached");
    }
    let value = &self.map[&key];
    self.cached_key = Some(key);
    self.cached_value = Some(value.clone());
    value
}
```

## Caveats

- Fast paths add code complexity and branches. Only add them when profiling shows the general case is hot AND the special case is common.
- Caching/memoization trades memory for speed and adds invalidation complexity.
- Over-specialization makes code harder to maintain. Focus on the 2-3 most common cases, not every possible case.
- Always add a comment explaining WHY a fast path exists, e.g., "99% of inputs have <= 2 elements, measured via tracing".
