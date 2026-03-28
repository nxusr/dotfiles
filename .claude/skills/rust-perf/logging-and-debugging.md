# Logging and Debugging

## What to Look For

- **Expensive computation in logging arguments that runs even when logging is disabled**: If the log level is off, the argument should not be evaluated.
- **`format!` or `.to_string()` inside `log::debug!` / `tracing::debug!` etc.**: These allocate even if the log line is never emitted. Use lazy formatting or deferred evaluation.
- **`assert!` in hot paths where `debug_assert!` would suffice**: `assert!` runs in release builds. If the assertion is for correctness checking (not safety), `debug_assert!` is free in release.
- **`Display` / `Debug` implementations that do expensive work**: These run every time the value is formatted, including in log lines.

### Search Patterns

```
# assert! in potentially hot code
assert!(
assert_eq!(
assert_ne!(

# debug_assert already in use (existing patterns)
debug_assert

# Logging macros with potentially expensive arguments
log::debug!
log::trace!
tracing::debug!
tracing::trace!
debug!
trace!

# format! inside log macros
# (look for format! or .to_string() nested inside debug!/trace! calls)
```

## How to Fix

### Replace `assert!` with `debug_assert!` in hot paths

```rust
// BEFORE — runs the check in release builds
fn process(data: &[u8]) {
    assert!(data.len() > 0);
    // ... hot code ...
}

// AFTER — check only runs in debug/test builds
fn process(data: &[u8]) {
    debug_assert!(!data.is_empty());
    // ... hot code ...
}
```

### Use lazy formatting in logging

```rust
// BEFORE — format! runs even if debug logging is disabled
log::debug!("{}", format!("processed {} items in {:?}", count, elapsed));

// AFTER — formatting only happens if the log line is emitted
log::debug!("processed {} items in {:?}", count, elapsed);
```

### Guard expensive logging data collection

```rust
// BEFORE — expensive_summary() runs even if trace is disabled
tracing::trace!("state: {}", expensive_summary(&state));

// AFTER — skip computation entirely when trace is off
if tracing::enabled!(tracing::Level::TRACE) {
    tracing::trace!("state: {}", expensive_summary(&state));
}
```

## Caveats

- `debug_assert!` provides NO safety guarantee in release builds. Only use it for invariants that are "nice to check" but not safety-critical.
- Some logging frameworks already do lazy evaluation of arguments — verify before adding manual guards.
- Adding `if enabled!()` guards adds visual noise; only do it when the argument computation is genuinely expensive.
