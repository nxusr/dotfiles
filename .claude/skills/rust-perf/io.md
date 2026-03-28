# I/O

## What to Look For

- **Repeated `println!` / `print!` calls**: Each call locks and unlocks stdout. Lock once manually for batches of output.
- **Writing to files without `BufWriter`**: Rust file I/O is unbuffered by default — every `write!` / `writeln!` is a system call.
- **Reading from files without `BufReader`**: Same issue on the read side.
- **`BufRead::lines()` in hot paths**: Allocates a new `String` per line. Use `read_line` with a reused buffer instead.
- **Reading text as `String` when raw bytes would suffice**: UTF-8 validation adds overhead. Use `read_until` or byte-oriented readers when you only need ASCII or raw bytes.

### Search Patterns

```
# Repeated print/println (consider locking stdout)
println!
print!
eprintln!

# File I/O without buffering
File::create
File::open
# Then check if wrapped in BufWriter/BufReader

# Lines iterator
\.lines()

# Check for existing buffered I/O
BufWriter
BufReader
```

## How to Fix

### Lock stdout for repeated writes

```rust
// BEFORE — locks/unlocks stdout on every call
for line in &lines {
    println!("{}", line);
}

// AFTER — single lock for all writes
use std::io::Write;
let stdout = std::io::stdout();
let mut lock = stdout.lock();
for line in &lines {
    writeln!(lock, "{}", line)?;
}
```

### Wrap file writes in `BufWriter`

```rust
// BEFORE — each writeln! is a system call
use std::io::Write;
let mut out = std::fs::File::create("output.txt")?;
for line in &lines {
    writeln!(out, "{}", line)?;
}

// AFTER — writes are batched in memory
use std::io::{BufWriter, Write};
let mut out = BufWriter::new(std::fs::File::create("output.txt")?);
for line in &lines {
    writeln!(out, "{}", line)?;
}
out.flush()?;
```

### Wrap file reads in `BufReader`

```rust
// BEFORE
let file = std::fs::File::open("input.txt")?;
// reading from `file` directly makes a syscall per read

// AFTER
use std::io::BufReader;
let file = BufReader::new(std::fs::File::open("input.txt")?);
```

### Read raw bytes instead of UTF-8 strings

```rust
// BEFORE — pays UTF-8 validation cost
use std::io::BufRead;
let mut line = String::new();
reader.read_line(&mut line)?;

// AFTER — no UTF-8 validation, suitable for ASCII data
use std::io::BufRead;
let mut buf = Vec::new();
reader.read_until(b'\n', &mut buf)?;
```

## Caveats

- `BufWriter` drops silently flush on drop but ignores errors. Always call `.flush()` explicitly to catch write errors.
- Locking stdout manually prevents other threads from writing to it during the lock — fine for single-threaded output, but be aware in multi-threaded programs.
- Raw byte reading is only appropriate when you don't need valid UTF-8 guarantees.
