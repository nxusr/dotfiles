# Inlining

## What to Look For

- **Small functions without `#[inline]`**: Functions that are 1-5 lines, especially if they cross crate boundaries. The compiler cannot inline across crate boundaries without `#[inline]`.
- **Single-call-site functions**: Functions called from exactly one place — these are prime candidates for `#[inline(always)]`.
- **Hot wrapper/delegation functions**: Functions that just forward to another function or do trivial work (getters, setters, newtype constructors).
- **Large functions with cold error paths**: Functions where the happy path is short but error handling bloats the function body — split the cold path out with `#[cold]`.

### Search Patterns

```
# Find small pub functions that might cross crate boundaries (candidates for #[inline])
pub fn .* \{
pub(crate) fn .* \{

# Find functions already marked inline (to understand existing patterns)
#\[inline\]

# Find potential cold-path candidates (panic/error handling in otherwise small functions)
fn .* -> Result
unreachable!
panic!
```

## How to Fix

### Add `#[inline]` to small cross-crate functions

```rust
// BEFORE
pub fn is_empty(&self) -> bool {
    self.len == 0
}

// AFTER
#[inline]
pub fn is_empty(&self) -> bool {
    self.len == 0
}
```

### Split hot/cold paths for large functions with a single hot call site

```rust
// BEFORE
fn process(data: &[u8]) -> Result<Output> {
    // ... lots of code ...
}

// AFTER — use inlined version at the hot call site
#[inline(always)]
fn process_inlined(data: &[u8]) -> Result<Output> {
    // ... lots of code ...
}

#[inline(never)]
fn process(data: &[u8]) -> Result<Output> {
    process_inlined(data)
}
```

### Outline cold error paths with `#[cold]`

```rust
// BEFORE
fn do_work(x: usize) {
    if x == 0 {
        // expensive error handling rarely taken
        eprintln!("error: ...");
        cleanup();
        return;
    }
    // hot path
}

// AFTER
#[cold]
#[inline(never)]
fn handle_zero_error() {
    eprintln!("error: ...");
    cleanup();
}

fn do_work(x: usize) {
    if x == 0 {
        handle_zero_error();
        return;
    }
    // hot path
}
```

## Caveats

- Excessive inlining increases binary size (code bloat) and can *hurt* performance by reducing instruction cache locality.
- `#[inline(always)]` can increase compile times, especially for cross-crate inlining.
- Always measure after adding inline attributes — the effect can be unpredictable.
- Inlining is non-transitive: if `f` calls `g` and you want both inlined at a callsite of `f`, both need the attribute.
