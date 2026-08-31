# Compiler modern-constructs benchmark (2026-08-31)

## Scope

This pass evaluated five ways to use MiniLang's newer language and runtime
features inside the self-hosted compiler without changing generated program
semantics:

1. profile-selected type contracts that unlock bounded automatic inlining,
2. lazy iterators for one-pass compiler collections,
3. non-escaping variadic argument views,
4. removal of remaining hot array concatenation/materialization paths, and
5. asynchronous or threaded object emission.

Changes were retained only when they improved the complete compiler workload.
The lazy-iterator and asynchronous-emission experiments were deliberately not
kept; their results are recorded below.

## Retained changes

### Typed hot leaves

Call profiling identified small, concrete leaf helpers in the assembler,
parser, MLO writer, data-label lookup and tagged-value utilities. Twenty-nine
of these functions now declare exact parameter and result contracts. This
makes them eligible for the existing bounded automatic inliner while retaining
their normal callable bodies. Dynamic AST and map helpers were not annotated,
because their accepted value shapes are intentionally polymorphic.

The selected group includes `asm.pos` (about 13.6 million calls in the profile),
the MLO U32 writer (about 6.0 million), and compact ModRM/range helpers used by
the encoder. Opcode smoke tests cover the annotated assembler wrappers.

### Non-escaping variadic merge

`arr_merge_variadic_parts(parts...)` is used for short-lived merge inputs. The
callee only reads the tail and never publishes it, so direct calls use the
compiler's immutable stack-backed variadic view instead of allocating a
temporary outer argument array. A regression test covers scalar and array
parts, order, length and real `void` elements.

### Native array initialization and direct finalization

The compiler's internal `_arr_fill` now uses `array(size, fill)`. The previous
bootstrap-era implementation repeatedly doubled and concatenated arrays,
copying all already-built elements at every level. Current runtimes allocate
and initialize the final storage in one native operation.

Chunk tails containing `void` are materialized into `array(size, void)` and
only their non-void cells are assigned. Parser and general compiler builders
now flatten chunk groups plus their active tail directly into the final array;
they no longer construct `groups + [tail]` or a hierarchy of 256-element
temporary arrays first. `copyArray` performs the bulk copies. The hot-path
concatenation guard and new array-vector regressions cover these paths.

## Evaluated but rejected

### Lazy closure-function stream

Closure layout needs the same canonical function set three times. A lazy
iterator removed one small snapshot but traversed the source collections three
times and added iterator state/code. Its fixed-point self-builds took 136.102
and 143.723 seconds, while the restored materialized-snapshot variant completed
a direct fixed-point build in 123.484 seconds. Removing the iterator also
reduced the compiler image by 39,936 bytes. The original snapshot is therefore
the better representation for this multi-pass consumer.

### Asynchronous object emission

Object emission remains serial. The previously measured full self-build
prototype with a background writer exceeded six minutes and roughly 3.6 GiB
working set. Competing managed heaps and GC coordination outweighed any
codegen/serialization overlap, and deterministic ordering became harder. This
path should only be reconsidered with isolated heaps and a deterministic merge
boundary; no asynchronous code was retained in this pass.

## Correctness and binary compatibility

- The complete Windows and WSL/Linux regression suite passes.
- The Python bootstrap, self-hosted Stage 2 and self-hosted Stage 3 produce the
  same 65,654,784-byte compiler image with SHA-256
  `DF65FD5091ADEFA200F15BB5E3BABC127923BA41081F263993B2282F19965341`.
- A Windows language-performance fixture is byte-identical between Python and
  self-hosted compilers: 585,216 bytes, SHA-256
  `0DD2A247A336E7AE1C2D697B3D69309D9A241D4288C43311902A8A43C0CCD9E1`.
- The corresponding Linux x64 ELF is also byte-identical: 667,216 bytes,
  SHA-256
  `3DC0F8C2CCF8D2B83782200E3A14F8D84975987F0ED156A2ECA11537D893B9D1`.
- Both representative Windows and Linux executables run successfully.
- Monolithic/object-pipeline parity, direct encoder smoke, type/optimizer,
  threads/GC, standard-library and platform gates remain green.

## Self-build measurements

Measurements were taken on Windows x64 with a warm filesystem cache, fresh
object directories and the same production object-pipeline heap configuration:
8 GiB reserve, 512 MiB initial commit, heap shrinking, 16 MiB shrink floor and
a 1.5 GiB target GC limit. `--mem-probe` and `--profile-compiler` were enabled.
Process-tree memory was sampled during the complete build. These are engineering
measurements, not a statistically stable microbenchmark.

| Metric | Pre-pass fixed point | Retained result | Change |
| --- | ---: | ---: | ---: |
| Wall time | 149.977 s | 138.124 s | -7.90% |
| Compiler-reported total | 149.828 s | 137.859 s | -7.99% |
| Canonical function objects | 131.250 s | 125.500 s | -4.38% |
| Runtime helpers | 7.469 s | 0.781 s | -89.54% |
| Peak private bytes | 1,830.3 MiB | 902.6 MiB | -50.69% |
| Peak working set | 1,728.3 MiB | 792.1 MiB | -54.17% |
| Compiler image | 65,384,448 B | 65,654,784 B | +0.41% |

The large memory reduction and runtime-helper speedup come primarily from
native final-size array allocation and removal of concatenation-based `void`
materialization. Typed hot leaves and direct group/tail copying reduce work in
canonical object emission. The final image grows by one small helper/object
fragment and the retained contracts, but target programs remain byte-identical
between both compiler implementations.

For reference, the Python bootstrap built the final compiler in 74.537 seconds
and produced the exact fixed-point hash above. A direct self-host run without
diagnostic memory logging completed in 123.484 seconds.
