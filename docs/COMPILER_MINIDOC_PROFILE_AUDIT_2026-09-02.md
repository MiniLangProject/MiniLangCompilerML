# MiniDoc-guided compiler profile audit (2026-09-02)

## Scope

This audit used the generated MiniDoc implementation reference as a map of the
self-hosted compiler, then validated candidates with a complete fixed-point
call profile. The goal was to improve maintainability and compilation speed
without increasing production memory consumption or changing target-program
semantics.

MiniDoc reported 25 compiler source files, 48,195 source lines and 1,754
functions after the retained changes. Documentation coverage remains 100%
(3,221 of 3,221 items), and a strict regeneration completes with zero
warnings. Complexity remains concentrated in `codegen_expr.ml`,
`codegen_stmt.ml`, `compiler.ml` and the parser. Those files are useful review
boundaries, but their largest functions were not split mechanically: extra
MiniLang calls in backend inner loops can cost more than the structural cleanup
saves.

## Profile evidence

`benchmarks/compiler_call_profile.ml` is a new reproducible diagnostic entry
point. It runs the normal compiler CLI and prints every non-zero native call
counter after the object-emitter and coordinator return. Call instrumentation
is intentionally expensive, so the counts rank hot paths while normal compiler
images provide the timing and memory results.

The first complete profile exposed two independent problems:

1. `cg_resolve_binding` consulted every scope index and then repeated the same
   failed lookup as a linear scan over all lexical frames. The index stacks are
   complete in production, so the scan could not find anything the indexes had
   missed.
2. `_qualify_identifier` included the current binding generation in its main
   cache key. That is required for lexical lookup, but it also invalidated
   package-suffix results whose inputs are append-only static symbol pools.
   Hundreds of thousands of suffix searches repeatedly scanned the same four
   pools and performed more than one hundred million string checks.

| Profiled helper | Before | After | Change |
| --- | ---: | ---: | ---: |
| lexical `frame_get` | 912,363,287 | 3,192,911 | -99.65% |
| lexical `_frame_last_binding` | 943,130 | 2,477 | -99.74% |
| suffix-pool scans | 261,146 | 40,118 | -84.64% |
| expression `_coerce_name` | 169,049,975 | 53,572,058 | -68.31% |
| `std.string.startsWith` | 136,044,332 | 20,557,734 | -84.89% |
| `std.string.endsWith` | 9,251,324 | 2,352,144 | -74.58% |

The number of calls to `cg_resolve_binding` itself remains effectively
unchanged (about 1.21 million); the optimization removes redundant work inside
each miss rather than avoiding semantic lookups. `fastmap_get` increases by
about 0.4% because the suffix cache adds one cheap lookup before avoiding a
full pool scan.

## Retained implementation

### Authoritative lexical indexes

`cg_resolve_binding` now treats equally sized, fully formed scope/index stacks
as authoritative. A complete miss returns immediately. The old frame scan is
retained for partially constructed, mismatched or legacy states, preserving
the compatibility behavior used by focused compiler tests.

`tests/compiler_scope_index.ml` verifies nearest-scope resolution, conclusive
indexed misses, authoritative complete indexes and the legacy fallback.

### Stable package-suffix cache

Package-suffix lookup now has a second cache key composed of the four symbol
pool sizes, package prefix and requested suffix. It stores the unique qualified
name or a boolean negative/ambiguous marker. Pool growth selects a new key,
while lexical bindings continue to use the generation-sensitive outer cache
and are checked first.

`tests/compiler_qualification_cache.ml` verifies a unique cached result, reuse
across binding generations, invalidation after pool growth, ambiguous results
and later lexical shadowing.

### Reproducible profiling and test stability

The benchmark README documents how to build and run the call-profile harness.
The Windows network unit test now chooses candidate ports below the dynamic
ephemeral range in both compiler repositories. This avoids false failures on
hosts where virtualization reserves more than 1,000 consecutive dynamic
ports; no networking implementation or public API changed.

## Self-build performance

The fair A/B uses the old 1.2.1 compiler and the optimized Stage 1 compiler to
compile the exact same final source with the production object-pipeline
configuration: 8 GiB reserve, 512 MiB initial commit, heap shrinking with a
16 MiB floor, and a 1.5 GiB target GC limit. Each row contains two fresh output
builds. Machine load still caused visible absolute variation, so both the range
and the two-run median are shown.

| Compiler | Runs | Range | Median |
| --- | ---: | ---: | ---: |
| Previous 1.2.1 self-host | 2 | 112.660-151.755 s | 132.208 s |
| Retained optimized self-host | 2 | 69.092-75.553 s | 72.323 s |

The median improvement is 45.30%. A separate same-method instrumented phase
comparison agrees with that result: canonical function-object emission fell
from 186.844 to 103.297 seconds (-44.71%), and sampled end-to-end wall time
fell from 194.114 to 110.198 seconds (-43.23%).

The same sampled runs show no memory cost:

| Process-tree peak | Before | After | Change |
| --- | ---: | ---: | ---: |
| Private bytes | 884.8 MiB | 878.2 MiB | -0.75% |
| Working set | 765.9 MiB | 759.3 MiB | -0.86% |

These small memory reductions are best treated as neutral within sampling
noise. The important result is that the new caches reuse existing compiler
state and introduce no material retained-memory growth.

## Correctness and binary compatibility

- The timed A/B builds preceded the release-version stamp and converged on the
  same 66,487,808-byte candidate image with SHA-256
  `7288385919A16B086550F2818B4C146DAEF08668BBCE3CFA2145FFAD3AD28673`.
- After stamping 1.2.2, Python bootstrap Stage 1 and self-hosted Stages 2 and 3
  are byte-identical 66,487,808-byte release images with SHA-256
  `5C4AF305EAB1D825E6304A628FF43C9D1D1B9AE0100300B1DEBD4A4C4837E61A`.
- Python and self-hosted Windows cross-builds emit the same 66,461,232-byte
  Linux compiler with SHA-256
  `38259A7747C8389221461984237952C4D4492F6C1C0AD3AEF31223FA57426A88`.
- Focused Windows code-generation output is byte-identical between Python and
  self-hosted compilers: 464,896 bytes, SHA-256
  `1E47B22E4F1A2D548C7208F353C68605A4CA779CF79F11DAD234AFA372E4983C`.
- Focused Linux output is byte-identical between Python and self-hosted
  compilers: 91,808 bytes, SHA-256
  `CFDC6AE1F07BA7150363D59D0CB46381593C91CB67F5CFE37870C2CBCF7881CB`.
- The Python compiler suite reports 133 passed, 0 failed and 0 skipped.
- The final 1.2.2 self-hosted suite completed in 207.376 seconds with no failed
  steps. Its embedded ML harness reports 127 passed and 0 failed, followed by
  the focused compiler tests and Windows/WSL runtime, FFI, threads, GC, MLO
  determinism and monolithic/MLO byte-identity gates. The first run had one
  environmental port-selection false failure; the isolated retry passed, and
  the port selection was hardened before this clean full rerun.
- MiniDoc strict generation reports 37 processed files, 3,252 symbols and zero
  warnings; compiler-source coverage remains 100%. Both repositories contain
  the same 46 standard-library sources, byte-identical MiniDoc configuration
  and byte-identical 289-file generated standard-library documentation tree.

## Result and next priorities

MiniDoc was useful as an ownership and complexity map, while the call profile
separated structural concerns from real runtime cost. The retained changes cut
the complete self-host workload by roughly 43-45% without changing emitted
program bytes or increasing memory.

The next measured candidates are `_coerce_name`, array wrapping, `_emit8`,
FastMap hashing and MLO U32 decoding. They remain high-volume helpers, but each
already has specialized paths; further changes should again start with a full
profile and preserve the existing byte-identity gates.
