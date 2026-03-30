# Machine Code

## What to Look For

- **Very hot, small functions where micro-optimization matters**: For the innermost hot loop, inspecting generated assembly can reveal missed optimizations like unnecessary bounds checks, redundant moves, or failed auto-vectorization.
- **Unexpected `memcpy` calls**: Types larger than 128 bytes are copied via `memcpy`. If `memcpy` shows up in profiles, the type may need shrinking.
- **Failed SIMD vectorization**: Loops operating on arrays of numeric data may or may not be auto-vectorized. Checking the assembly confirms whether vectorization happened.

### How to Inspect

Use [Compiler Explorer](https://godbolt.org/) for small snippets. For full projects, build in release mode and use `objdump -d` to inspect specific functions.

```bash
# Disassemble a specific function (after finding the symbol name)
objdump -d path/to/binary | grep -A 50 'function_name'
```

## What to Look For in Assembly

- **`call` instructions to bounds-check panic handlers** (`panic_bounds_check`): Indicates bounds checks were not elided.
- **`memcpy` or `memmove` calls**: Large type copies.
- **Scalar instructions where SIMD was expected**: Look for `xmm`/`ymm` registers (SSE/AVX) vs plain `eax`/`rax` registers.
- **Redundant loads/stores**: Values being written to memory and immediately read back.

## How to Fix

Most fixes at this level involve changes at the Rust source level:

- **Bounds checks**: See the [bounds-checks](bounds-checks.md) guide.
- **Large type copies**: See the [type-sizes](type-sizes.md) guide.
- **SIMD**: Consider using `core::arch` intrinsics or crates like `packed_simd` for explicit vectorization.

## Caveats

- Assembly-level optimization is rarely the best use of time. Algorithm and data structure changes almost always have larger impact.
- Generated assembly changes between compiler versions — don't over-optimize for one specific rustc version.
- SIMD intrinsics are `unsafe` and platform-specific. Prefer auto-vectorization by writing "SIMD-friendly" loops (fixed-size, no early exits, simple operations).
