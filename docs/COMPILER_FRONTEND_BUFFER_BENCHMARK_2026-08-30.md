# Compiler Frontend Buffer and Coordinator Heap Report (2026-08-30)

## Scope

This iteration targets the next large compiler-memory owner found by direct
frontend profiling. `normalize_code_for_tokenizer()` previously represented
the normalized source as one managed string and one array slot per input
character before joining all pieces. Loading the self-hosted compiler reached
roughly 9.75 million allocated blocks before code generation began.

The generated program format, MLO v2 format and PE/ELF layouts are unchanged.

## Capacity-backed source normalization

The normalizer now processes the UTF-8 input in one capacity-backed byte
buffer. The pass still performs the same two transformations:

- CRLF pairs become LF, including pairs inside strings and comments; and
- unambiguous compact subtraction such as `value-1` becomes `value - 1`, while
  negative literals, strings, escapes and line comments retain their previous
  meaning.

Inputs containing neither a minus byte nor CRLF return the original string
without a second source copy. Rewritten inputs allocate at most one bounded
working buffer and one final decoded string instead of millions of character
strings and array elements. A dedicated regression covers the no-op UTF-8 path
and the combined newline, comment, escaped-string, negative-literal, index and
subtraction cases.

## Coordinator heap calibration

The object pipeline deliberately retains process isolation: a small
coordinator starts the allocation-heavy emitter, waits for it to exit and then
links the emitted objects. A tested single-process replacement made the
streamed link scan much slower in the fragmented emitter heap, so it was
discarded.

Immediately before spawning, the coordinator performs a full collection. The
compiler build now allows that collection to decommit down to 16 MiB rather
than retaining at least 256 MiB. The initial 512 MiB commit remains in place so
the emitter can start without repeated commit operations; the 8 GiB reserved
address space and 1.5 GiB generated-target GC limit are unchanged.

Calibration used otherwise identical new-frontend compiler images:

| Initial/minimum commit | Time | Peak private | Peak working set |
|---|---:|---:|---:|
| 512/256 MiB | 87.761 s | 2,061.2 MiB | 1,828.7 MiB |
| **512/16 MiB** | **88.776 s** | **1,841.1 MiB** | 1,849.2 MiB |
| 128/16 MiB | 89.355 s | 1,835.1 MiB | 1,842.8 MiB |
| 512/64 MiB | 89.771 s | 1,889.2 MiB | 1,840.9 MiB |

These are single process-tree samples. The 16 MiB setting was selected because
it removes about 220 MiB of private commit relative to the same frontend with
the old minimum while keeping the fastest startup configuration. Working-set
differences of about 20 MiB between the calibrated builds are OS residency
noise rather than a matching change in private commit.

## Correctness and binary compatibility

- Complete ML harness: **110 passed, 0 failed**.
- Full `scripts/run_tests.ps1`: **passed** in 91.000 s, including Windows and
  Linux targets, PE/ELF, Win64/SysV FFI, standard library, threading, crypto,
  GC stress, ABI, deterministic relink and monolithic/MLO parity.
- Windows Python Stage 1 and self-hosted Stages 2/3 are byte-identical:
  62,047,232 bytes, SHA-256
  `8DE03C4E6994364A25661D1CEE775CC5F9FC7B13D598F860447BACA60A7887A1`.
- All 309 canonical MLO files from Windows Stage 2 and Stage 3 are
  byte-identical.
- A native Linux Python bootstrap and Linux self-hosted Stage 2 are
  byte-identical: 62,036,512 bytes, SHA-256
  `3653D9904E05CCFFF8EAFFB3EA2AF0AB3045D94C9013E2F69BD6B02E1A24984E`.
  The Linux build script also passed monolithic, object-pipeline and project
  smoke tests.
- Current Python and self-hosted MiniQuake builds are byte-identical:
  57,197,568 bytes, SHA-256
  `363C22BC1E96DCECE1603297987C24DEF5C20F6F7D26D7AC15CC2D89B1D941E9`.

## Performance

Peak values sum the complete compiler process tree. Measurements are single
controlled Windows x64 engineering runs on the same host.

| Workload | Previous documented build | Final build | Change |
|---|---:|---:|---:|
| Self-build time | 105.570 s | 88.776 s | -16.794 s (-15.9%) |
| Self-build peak private | 1,972.3 MiB | 1,841.1 MiB | -131.2 MiB (-6.7%) |
| Self-build peak working set | 1,614.7 MiB | 1,849.2 MiB | +234.5 MiB (+14.5%) |
| MiniQuake time | 225.011 s | 185.406 s | -39.605 s (-17.6%) |
| MiniQuake peak private | 3,537.8 MiB | 3,288.7 MiB | -249.1 MiB (-7.0%) |
| MiniQuake peak working set | 3,176.3 MiB | 3,172.8 MiB | -3.5 MiB (-0.1%) |

The self-build working-set sample increased even though private commit fell.
Working set is controlled by the Windows memory manager and changed with the
shorter allocation/collection history; it is not a reliable claim of a larger
required heap. MiniQuake's almost unchanged working set and lower private peak
provide the more representative large-project result.

## Conclusion

This is a large practical frontend win: it removes millions of transient
objects, shortens both the self-build and MiniQuake by roughly 16-18%, and
reduces their private peaks while preserving exact Python/self-hosted output.
The remaining multi-gigabyte peak occurs during canonical function codegen, so
the next major memory project should compact retained assembler fragments and
relocation/label metadata rather than further shrinking the now-bounded
frontend source pass.
