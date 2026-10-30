# Compiler optimization experiments, 30 October 2026

Windows x64, MiniLang 1.2.25 source. Both repositories were changed together.
Measurements below are local observations, not general speed guarantees. The
compiler self-build uses the MLO pipeline; the smaller compiler comparison uses
the monolithic pipeline. No cache was used unless stated.

## Changes and outcome

1. **MLO serialization:** `byte_pages_append` now copies a page span with native
   `memmove` instead of a MiniLang byte loop. An AST-kind dispatch experiment
   was reverted after its nine-run `mlfmt` result showed no gain (1.103 vs
   1.111 s). In a warm self-build, the isolated copy change shortened the
   combined MLO projection/serialization phase by about 0.2 s, but total build
   time was 1.1 s longer. This is not a demonstrated overall compile-time win.
2. **Incremental analysis:** both compilers persist the global declaration
   fingerprint in a validated, atomic `.mif` record. The key includes compiler
   identity, effective options and every parsed source content identity. A
   changed source graph recomputes the fingerprint. Records are data only and
   corrupt records fall back to computation.
3. **Array loops:** the existing guarded byte-loop versioning also covers
   dynamically sized arrays. The nonempty version elides repeated index bounds
   checks; the slow version preserves MiniLang's descending `0..-1` behavior
   for empty arrays. Reassigned targets, modified loop indices and boxed
   bindings stay on the checked path.

## Compile-time measurements

| Workload | Before | After | Evaluation |
| --- | ---: | ---: | --- |
| Warm ML self-build, old compiler vs copy-only compiler | 49.78 s | 50.83 s | No overall gain; MLO phase 8.58 to 8.38 s |
| Warm ML self-build, old compiler vs full new compiler | 49.78 s | 52.20 s | About 4.9% slower; array versioning duplicates loop bodies |
| `mlfmt`, Python old vs new, 9 runs | 1.698 s | 1.706 s | Essentially unchanged; peak working set 63.35 to 63.50 MB |
| `mlfmt`, ML old vs new, 11 runs | 1.075 s | 1.090 s | Small regression; peak working set about 157.8 MB in both |

The new Python compiler built the same compiler source in 78.48 and 80.24 s
on two runs. The warm ML runs took about 50 to 53 s, so ML remains faster for
this full build on this machine.

The first self-builds took roughly 79 to 82 s. Later warm runs took 50 to
53 s even with the unchanged compiler, so the cold-to-warm gap must not be
attributed to these edits. Batch profiling of the warm runs gives codegen/MLO
phase times of 34.26/8.58 s (old), 35.30/8.38 s (copy only) and 34.89/11.26 s
(full new compiler). `serialize_ms` includes object projection and writing.

With function fragments already warm, deleting only the `.mif` file between
runs isolates the extra analysis cache:

| Source | Compiler | Recomputed | Cached | Outcome |
| --- | --- | ---: | ---: | --- |
| 1,000 simple functions | Python | 0.883 s | 0.855 s | 3.2% faster |
| 1,000 simple functions | ML | 0.470 s | 0.448 s | 4.7% faster |
| `mlfmt` | Python | 0.682 s | 0.694 s | No gain at this size |
| `mlfmt` | ML | 0.505 s | 0.510 s | No gain at this size |

These are seven-run medians. The cache helps declaration-heavy unchanged
builds; it does not yet reuse semantic analysis across edited source files.

## Generated programs

Python and ML produced identical SHA-256 hashes for each before/after version
of both runtime fixtures. The new compiler's Python-built, ML-built and
repeated self-built images also share SHA-256
`3E0F6EAE41AB976101E5C7BF1065B594F204C0768CAC61D539E51B2B80EB95AB`.

| Array workload | Before | After | Memory and size |
| --- | ---: | ---: | --- |
| `runtime_codegen` dynamic index, internal time, 11 paired runs on CPU 4 | 21.238 ms | 20.989 ms | Managed heap delta 0 B; peak working set about 7.5 MB; image +1,536 B |
| `loop_array`, whole process, 21 paired runs | 147.43 ms | 145.32 ms | Peak working set 7,536,640 B in both; image +1,024 B |

The guarded array path yields a repeatable roughly 1% gain on these hot loops,
with no material memory change and modest code growth. Its current code-size
cost also makes the full compiler self-build slower, so the profitability
heuristic remains worth improving.

## Validation

- `check_compiler_techniques.py`: Windows Python, ML monolithic and ML MLO
  output parity, runtime behavior, corrupt `.mif` fallback, and other compiler
  techniques.
- `check_codegen_structure.py`: both compilers emit an unchecked fast array
  version and a checked empty-array fallback.
- `check_incremental.py`: 96 checks each for Windows x64 and Linux x64 across
  three backends, including edits, cache corruption and byte parity.
- `runtime_codegen.ml`: both Windows executables pass and have identical bytes.
- `compiler_techniques.ml`: Python/ML Linux x64 ELF hashes match. Linux runtime
  execution was not measured on this Windows host.

Raw measurements and self-build logs are under `build/experiments/`.
