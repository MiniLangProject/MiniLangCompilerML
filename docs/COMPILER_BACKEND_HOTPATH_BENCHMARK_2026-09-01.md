# Compiler backend hot-path benchmark (2026-09-01)

## Scope

This pass profiled the current fixed-point self build and optimized five
backend areas without changing generated-program semantics:

1. profile the complete fixed-point workload again instead of relying on old
   microbenchmarks,
2. make compiler-internal `ArrayVector` recognition nominal and add trusted
   access paths,
3. specialize lexical-frame count/get/set operations after one vector check,
4. cache the assembler's active 64 KiB byte chunk, and
5. decode MLO U32 fields in place while reusing the reader result pair.

The standard-library `List` bulk-copy paths were also converted from
MiniLang-level element loops to the native `copyArray` primitive. The same
file is present byte-for-byte in the Python and self-hosted compiler
repositories.

## Profile evidence

The instrumented fixed-point workload confirmed that small dynamic helpers,
not parsing, dominated the remaining backend cost. Approximate call counts in
that deliberately instrumented run were:

| Helper | Calls |
| --- | ---: |
| `arr_vec_is` | 1.096 billion |
| lexical `frame_get` | 890.5 million |
| assembler `_emit8` | 29.57 million |
| MLO `_objreader_read_u32` | 17.97 million |

The instrumented build itself took about 212 seconds and was used only for
ranking work. Its timing is not compared with production builds because call
counters materially alter these very small helpers.

## Retained implementation

### Nominal vectors and trusted frame operations

`arr_vec_is` now uses `value is ArrayVector`. The old structural test performed
three guarded member probes on every call and also accepted unrelated structs
with coincidentally matching fields. Public vector operations retain their
validation; internal trusted count/get/set helpers are called only after one
nominal check. Frame count/get/set use those helpers directly.

The new typed helpers are referenced by fully qualified names inside their own
package. A broader basename resolver experiment was rejected after the full
language suite exposed a collision between unrelated package functions named
`decode`. This keeps package lookup semantics unchanged while preserving exact
Python/self-hosted output.

### Active assembler chunk

`AsmBuilder` retains the active byte chunk and its index. Consecutive byte
emissions therefore mutate the cached 64 KiB buffer directly; page/tail lookup
is performed only when emission crosses a chunk boundary or another operation
selects a different chunk. Materialization explicitly invalidates the cache.
A regression emits through the 65,536-byte boundary and checks bytes on both
sides.

### Allocation-free MLO U32 reads

The MLO reader now decodes four bytes directly at its cursor and advances the
cursor in place. Each reader owns one reusable two-cell result array. All
callers consume that pair before the next read, removing roughly 18 million
short-lived result arrays from the fixed-point workload without introducing
global state.

### Native `List` copies

`List.fromArray`, growth, `addAll`, and `toArray` use `copyArray`. These paths
preserve logical size and capacity rules while avoiding interpreter-level
element loops in compiler and application workloads.

## Correctness and binary compatibility

- Python bootstrap Stage 1, self-hosted Stage 2, and self-hosted Stage 3 are
  byte-identical: 65,592,832 bytes, SHA-256
  `55F3E04FD9A44A81EFBBE3B67CCECE60D091383AF7697E707BD401FF9421D0E5`.
- A fourth fair-timing build produced the same hash.
- The self-hosted Windows/WSL regression run completed in 108.922 seconds with
  no failed step. It includes the full language and standard-library suites,
  Windows and Linux FFI/runtime checks, threads, TLABs, GC, object-pipeline
  determinism, monolithic/MLO byte identity, standalone relinking, assembly
  listing checks, and historical MiniQuake reproductions.
- The Python compiler suite reports 124 passed, 0 failed, and 0 skipped.
- The new vector nominal-type and assembler chunk-boundary regressions pass.

## Self-build measurements

Measurements used Windows x64, a warm filesystem cache, fresh object
directories, and the production object-pipeline heap configuration: 8 GiB
reserve, 512 MiB initial commit, heap shrinking with a 16 MiB floor, and a
1.5 GiB target GC limit. The comparison builds both enabled `--mem-probe` and
`--profile-compiler`. They were taken in the same machine-load window because
absolute times on this host varied noticeably from the preceding day's runs.

| Metric | Same-window control | Retained result | Change |
| --- | ---: | ---: | ---: |
| Wall time | 169.959 s | 153.763 s | -9.53% |
| Compiler-reported total | 169.672 s | 153.687 s | -9.42% |
| Canonical function objects | 159.797 s | 144.297 s | -9.70% |
| Object-pipeline planning | 2.313 s | 1.407 s | -39.17% |
| Peak process-tree private bytes | 900.2 MiB | 907.1 MiB | +0.77% |
| Peak process-tree working set | 803.3 MiB | 809.9 MiB | +0.82% |
| Compiler image | 65,654,784 B | 65,592,832 B | -0.09% |

Process-tree memory was sampled separately. Even the lightweight sampler
increased build time substantially, so its 215.450-second wall time is not a
performance result. The approximately 7 MiB private-byte and 6.6 MiB
working-set differences are small enough to treat as measurement noise rather
than a material memory regression.

For a practical reference, the final self build without `--mem-probe` completed
in 151.859 seconds and reported 151.796 seconds internally. The Python
bootstrap generated the same fixed-point image in 90.524 seconds.

## Result

The retained backend changes reduce the current complete fixed-point build by
about 9.5% while preserving exact Python/self-hosted and monolithic/MLO output.
Memory consumption is effectively unchanged, and the generated compiler image
is 61,952 bytes smaller.
