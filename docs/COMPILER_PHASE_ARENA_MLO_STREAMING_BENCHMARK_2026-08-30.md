# Compiler Phase Release and MLO Streaming Report (2026-08-30)

## Scope

This iteration implements the remaining two memory-reduction items from the
compact AST work:

1. release complete frontend arenas and caches at a proven phase boundary; and
2. keep the object-pipeline writer and linker from retaining object-sized
   duplicate byte buffers or all per-object section payloads at once.

The on-disk MLO v2 format and generated PE/ELF layout are unchanged.

## Phase-owned frontend storage

`ast_arena_release()` drops every compact leaf/binary column, its capacities
and counts, and the filename/symbol intern tables in one operation. The compiler
calls the release only after the last code-generation use of AST NodeIds. At the
same boundary it detaches path normalization, visited-module and import
resolution caches, clears the remaining frontend-only signature references and
runs a full collection.

The monolithic pipeline releases this graph before executable section
materialization. The object pipeline releases it after all canonical user
functions have been serialized and before the support tail. A regression test
asserts zero arena statistics after release and successful lazy reuse in a
subsequent parse.

## Bounded MLO serialization

MLO records are still assembled in the existing 64 KiB `BytePages` structure,
but writing no longer calls `byte_pages_to_bytes()` and therefore no longer
creates a second contiguous copy as large as the complete object. Read-only page
accessors feed one reusable 1 MiB staging buffer. Native Windows `WriteFile` and
Linux `write` loops handle short writes and use a bounded number of calls.

An initial implementation wrote every 64 KiB page separately. On the measured
MiniSQL tree that increased object serialization from 9.155 s to 24.864 s. The
bounded batch was therefore added before validation; the final path takes
7.220 s on the same tree, 21.1% less than the preceding implementation.

## Metadata-first streamed linker

The first link pass now retains only section sizes, entry/import metadata and
public/private label-count hints. After exact final text, read-only-data and
data buffers are allocated, a second pass reopens one MLO at a time and copies
each length-prefixed payload directly to its final offset. Label and relocation
passes skip section payloads and decode only the records they consume.

Consequently the linker no longer holds all per-object section byte arrays and
then allocates a second concatenated copy. The final target sections still have
to coexist with one current raw MLO file; removing that last bounded overlap
would require a seekable/chunked file-reader API rather than the current
`fs.readAllBytes` interface.

## Correctness and binary compatibility

- Complete ML harness: **109 passed, 0 failed**.
- Full `scripts/run_tests.ps1`: **passed** for Windows and Linux targets in
  94.556 s, including runtime, standard-library, threading, crypto, GC, ABI,
  object parity, deterministic relink and retained-object tests.
- Python bootstrap, regular self-hosted Stage 2, self-hosted Stage 3 and a
  separately measured self-build are byte-identical: 62,072,320 bytes,
  SHA-256 `9558536E3B6BEA610F1AFEA68266EB554D0CF41409210B87339CC6ED45B19E43`.
- Relinking the same 309 MLO files with the preceding and the streamed linker
  produces that same compiler image and hash.
- The measured MiniSQL baseline and final compiler images are byte-identical:
  48,181,760 bytes, SHA-256
  `A5C1CC5B1714FC32FC7D3446CD638770058062D5C3ED66FF2DAA79C88A5D05F0`.
- A Python-bootstrapped native Linux compiler passed version, monolithic,
  object-pipeline and project-manifest smoke tests. The three generated smoke
  ELFs were byte-identical and executed with the expected output. The bootstrap
  and smoke sequence completed in 79 s.

## Memory and time measurements

Peak process-tree values were sampled every 100 ms on the same Windows x64
host. These are single engineering runs; small timing differences are not
statistically significant.

| Workload | Preceding implementation | Phase release + streaming | Change |
|---|---:|---:|---:|
| Self-build time | 108.421 s | 105.570 s | -2.6% |
| Self-build peak private | 2,001.3 MiB | 1,972.3 MiB | -29.0 MiB (-1.4%) |
| Self-build peak working set | 1,652.1 MiB | 1,614.7 MiB | -37.4 MiB (-2.3%) |
| Same-309-MLO link time | 2.580 s | 2.560 s | -0.8% |
| Same-309-MLO link peak private | 761.2 MiB | 706.7 MiB | -54.5 MiB (-7.2%) |
| Same-309-MLO link peak working set | 808.3 MiB | 645.4 MiB | -162.9 MiB (-20.2%) |

The current, already-dirty MiniSQL development tree also completed with exact
binary identity. Its paired wall time changed from 158.485 s to 127.486 s, but
the code-generation phase varied substantially between the single runs, so the
19.6% total reduction must not be attributed wholly to these changes. Peak
private memory remained emitter-bound at about 3,537.8 MiB. Peak working set
was 3,172.0 MiB in the baseline run and 3,290.0 MiB in the final run, which is
also evidence that a single full-build working-set sample is too noisy to claim
a MiniSQL peak reduction.

## Conclusion

Both changes are kept because they remove unbounded duplicate ownership,
preserve exact output bytes and improve the isolated linker peak without a
time regression. They produce a modest full self-build reduction rather than a
multi-gigabyte step: the largest applications still reach their peak during
canonical code generation, before the new phase boundary can release frontend
storage. Further large reductions therefore need to target live assembler and
code-generation state, not another few megabytes of compact frontend AST.
