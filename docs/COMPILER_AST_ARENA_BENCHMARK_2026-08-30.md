# Compiler AST Arena and Lifetime Report (2026-08-30)

## Scope

This change evaluates five related compiler-memory improvements:

1. opt-in AST population and arena telemetry;
2. typed arenas with integer NodeIds for frequent immutable AST nodes;
3. compilation-wide symbol and source-file interning for compact nodes;
4. earlier release of parsed-module and emitted-function ownership graphs; and
5. correctness, binary-compatibility, time and process-tree memory validation
   on the compiler, MiniQuake and MiniSQL.

The compact representation is deliberately hybrid. Numeric, string, boolean,
void and variable leaves plus binary expressions use structure-of-arrays
arenas. Mutation-heavy statements, declarations and less frequent composite
expressions remain structs. This keeps the migration reviewable and preserves
the existing public parser/codegen behavior through shared AST accessors.

## Implementation

- `--profile-compiler-ast` prints the module/node population, per-kind counts,
  maximum depth, compact arena capacity/storage and intern-table populations.
  It implies `--profile-compiler` but does not change target bytes.
- Compact leaves and binary expressions use negative integer NodeIds. Separate
  handle ranges distinguish both arenas from ordinary MiniLang integer values.
- Leaf kinds and all source positions, file IDs and symbol IDs are packed into
  byte columns. Child NodeIds and literal payloads remain value arrays.
- Variable identifiers and binary operators share a compilation-wide symbol
  table; source filenames share a file table. Repeated spellings therefore do
  not allocate a string in every compact node.
- Parsed-module source/program containers are detached after their nodes and
  line maps enter the merged program. Frontend order/cache containers are not
  retained by code generation.
- Non-inline function bodies and analysis-only closure data are released after
  their canonical object fragment is serialized. Inline bodies remain live
  until all dependent call sites have been emitted.
- Explicit compiler roots now cover the full object-emission loop frontier and
  the streamed linker patch graph. This fixes two GC-liveness defects that
  extra profiling output could previously hide.
- Object-state cloning now carries `synchronized_globals`. Without it,
  object-pipeline builds omitted monitor operations that monolithic and Python
  builds emitted for synchronized global access.

## AST telemetry

| Target | Modules | AST nodes | Compact leaves | Compact bins | Arena storage | Symbols | Files | Max depth |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Self build | 28 | 261,628 | 145,649 | 20,686 | 6,422,528 B | 4,934 | 28 | 25 |
| MiniQuake | 113 | 246,250 | 135,945 | 25,331 | 6,422,528 B | 6,384 | 113 | 31 |
| MiniSQL | 88 | 195,560 | 103,776 | 17,372 | 3,670,016 B | 4,704 | 88 | 42 |

The arena-storage column includes reserved compact-node columns, not interned
string payloads or the remaining struct AST. It is therefore an arena footprint
measurement, not a claim about total compiler heap consumption.

## Correctness and binary compatibility

- Complete ML harness: **109 passed, 0 failed**.
- Full `scripts/run_tests.ps1`: **passed** on Windows and Linux, including PE,
  ELF, SysV/Win64 FFI, standard library, threading, crypto, GC stress, ABI and
  object-pipeline checks; total wall time was 100.172 s.
- The compact-arena regression target is byte-identical with and without
  `--profile-compiler-ast` (SHA-256
  `594871CA14E8B92F28BDB04D9B16F9A721D7A86A84F770E29543710D3810D77E`).
- A new `synchronized globals` case proves monolithic/object-pipeline byte
  identity and executes the native thread/synchronization runtime test.
- Python-bootstrap Stage 1, self-hosted Stage 2 and self-hosted Stage 3 are
  byte-identical: 61,828,096 bytes, SHA-256
  `5CD6D31971E3DA1225D8885AB48B06C65317E50C08B2DA968C32B60EB7EAF6E5`.
- MiniQuake Python/self-hosted object builds are byte-identical: 57,197,568
  bytes, SHA-256
  `363C22BC1E96DCECE1603297987C24DEF5C20F6F7D26D7AC15CC2D89B1D941E9`.
- MiniSQL Python/self-hosted object builds are byte-identical: 48,181,760
  bytes, SHA-256
  `06645D4AF7BBB58CFAEA1D510A1E05D0A85B6918FDC67683F728D847D8758826`.
  Both executables return exit code 0 and `MiniSQL 1.0.0 server` for
  `--version`.

MiniQuake was measured at clean commit
`59ac8cfc6c447c82b207100741512359f95e595c`. MiniSQL was intentionally measured
from its current development working tree at HEAD
`b4cc13f796e1818560d0ccc173a2ca953f248692`; that tree already contained local
user changes and was not modified by this compiler work.

## Compile-time and memory measurements

Peak values sum all matching compiler processes at 100 ms intervals so the
small object-pipeline coordinator cannot hide the fresh emitter/linker cost.
Values are single controlled runs on the same Windows x64 host and should be
treated as engineering measurements, not statistically stable microbenchmarks.

| Target/compiler | Time | Peak private bytes | Peak working set | Result |
|---|---:|---:|---:|---|
| Self-hosted compiler, final | 108.421 s | 2,098,556,928 B (2,001.3 MiB) | 1,732,382,720 B (1,652.1 MiB) | exact fixed point |
| Self-hosted compiler, preceding baseline | 105.422 s | 1,884,930,048 B (1,797.6 MiB) | 1,780,158,464 B (1,697.7 MiB) | reference |
| MiniQuake, self-hosted | 225.011 s | about 3,537.8 MiB | about 3,176.3 MiB | Python-identical image |
| MiniQuake, Python | 54.892 s | about 1,194.1 MiB | about 1,049.6 MiB | reference |
| MiniSQL, self-hosted | 139.502 s | 3,709,693,952 B (3,537.8 MiB) | 3,321,401,344 B (3,167.5 MiB) | Python-identical image |
| MiniSQL, Python | 45.401 s | about 947.0 MiB | about 948.6 MiB | reference |

The final self build is 2.8% slower than the preceding baseline. Peak working
set is 45.6 MiB (2.7%) lower, but peak private commit is 203.7 MiB (11.3%)
higher. Consequently this iteration validates a compact AST foundation and
safe ownership boundaries, but **does not yet demonstrate a large reduction in
overall compiler memory**. The object emitter's codegen/assembler state still
dominates total peak usage, and the self-hosted compiler remains roughly 4.1x
slower than Python for MiniQuake and 3.1x slower for MiniSQL.

## Recommended next measurement-driven migration

Telemetry identifies `Member`, `Call`, `Assign`, `Return` and `If` as the next
high-population composite nodes. Before migrating them, measure retained bytes
by phase and object batch rather than relying on node counts alone. The larger
opportunity remains reducing duplicated codegen/assembler state during object
emission; compacting another few megabytes of frontend AST cannot by itself
remove the multi-gigabyte peaks observed on MiniQuake and MiniSQL.
