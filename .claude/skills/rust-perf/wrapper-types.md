# Wrapper Types

## What to Look For

- **Multiple `Arc<Mutex<T>>` / `Rc<RefCell<T>>` fields in a struct where the values are always accessed together**: Each wrapper has its own overhead (atomic ops for Arc, borrow checks for RefCell, lock acquisition for Mutex). Combining co-accessed values into a single wrapper reduces this overhead.
- **`Mutex<T>` protecting a single small field when a larger struct could be wrapped**: Multiple lock acquisitions for related data can be combined.
- **Nested wrappers like `Arc<Mutex<Vec<Arc<T>>>>`**: Deep nesting multiplies overhead. Consider flattening the ownership model.

### Search Patterns

```
# Multiple wrapped fields in a struct
Arc<Mutex<
Rc<RefCell<
Arc<RwLock<

# Deeply nested wrappers
Arc<Mutex<Vec<
Arc<RwLock<HashMap<
```

## How to Fix

### Combine co-accessed wrapped values

```rust
// BEFORE — two separate lock acquisitions needed
struct State {
    count: Arc<Mutex<u32>>,
    total: Arc<Mutex<u64>>,
}

fn update(state: &State) {
    *state.count.lock().unwrap() += 1;   // lock 1
    *state.total.lock().unwrap() += 100; // lock 2
}

// AFTER — single lock acquisition
struct StateInner {
    count: u32,
    total: u64,
}

struct State {
    inner: Arc<Mutex<StateInner>>,
}

fn update(state: &State) {
    let mut inner = state.inner.lock().unwrap();
    inner.count += 1;
    inner.total += 100;
}
```

### Combine RefCell fields

```rust
// BEFORE
struct Component {
    x: RefCell<f32>,
    y: RefCell<f32>,
    z: RefCell<f32>,
}

// AFTER
struct Component {
    position: RefCell<(f32, f32, f32)>,
}
```

## Caveats

- Combining values into a single wrapper increases lock contention if different threads access different subsets of the data. Only combine values that are truly co-accessed.
- Wider locks hold the lock for longer, which can hurt concurrent throughput.
- This optimization trades granularity for reduced overhead — profile to confirm it helps.
