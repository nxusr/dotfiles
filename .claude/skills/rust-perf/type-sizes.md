# Type Sizes

## What to Look For

- **Enums with one outsized variant**: A single large variant makes the entire enum large, even when the common variants are small. Box the large variant's fields.
- **`usize` used for indices that fit in `u32` or smaller**: Indices into collections rarely exceed 2^32. Using `u32` halves the memory per index.
- **`Vec<T>` in long-lived structs that never changes after construction**: Could be `Box<[T]>` (saves one word) or `ThinVec<T>` (saves two words if often empty).
- **Types larger than 128 bytes**: These get copied via `memcpy` instead of inline code. Shrinking below 128 bytes can eliminate `memcpy` overhead.
- **Structs/enums that are instantiated in very large quantities**: Even small size reductions matter when multiplied by millions of instances.

### Search Patterns

```
# Find enums (check for outsized variants)
enum .*\{

# Find usize fields that could be u32
: usize
: Vec<usize>

# Check type sizes with std::mem::size_of
size_of

# Find ThinVec / SmallVec already in use
ThinVec
thin_vec
```

### Measuring Type Sizes

Add temporary assertions to discover actual type sizes:

```rust
// Add this temporarily to find the size of a type
eprintln!("size of MyType: {}", std::mem::size_of::<MyType>());
```

## How to Fix

### Box outsized enum variants

```rust
// BEFORE — variant Z makes the entire enum 112 bytes
enum Token {
    Ident(String),          // 24 bytes
    Literal(i64),           // 8 bytes
    Complex {               // 104 bytes
        data: [u8; 96],
        tag: u64,
    },
}

// AFTER — all variants are roughly the same size
enum Token {
    Ident(String),
    Literal(i64),
    Complex(Box<ComplexData>),
}

struct ComplexData {
    data: [u8; 96],
    tag: u64,
}
```

### Use smaller integer types for indices

```rust
// BEFORE
struct NodeRef {
    index: usize,   // 8 bytes on 64-bit
    generation: usize,
}

// AFTER
struct NodeRef {
    index: u32,      // 4 bytes — supports up to ~4 billion nodes
    generation: u32,
}
```

### Use `ThinVec` for frequently-empty vectors in hot types

```rust
// BEFORE — Vec is 3 words (24 bytes) even when empty
struct AstNode {
    children: Vec<AstNode>,
    // ...
}

// AFTER — ThinVec is 1 word (8 bytes), stores len/cap in heap allocation
use thin_vec::ThinVec;
struct AstNode {
    children: ThinVec<AstNode>,
    // ...
}
```

### Add static assertions to prevent regressions

```rust
#[cfg(target_arch = "x86_64")]
static_assertions::assert_eq_size!(MyHotType, [u8; 64]);
```

## Caveats

- Boxing a variant adds a heap allocation when constructing that variant. Only box variants that are infrequently constructed.
- Smaller integers require casts at use points (`as usize`), which adds noise.
- `ThinVec` has slightly higher overhead than `Vec` for non-empty vectors (extra indirection).
- Always measure — smaller types don't always translate to faster code if they require more instructions to manipulate.
