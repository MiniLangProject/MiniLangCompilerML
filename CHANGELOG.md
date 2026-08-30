# Changelog

All notable changes to the MiniLang compiler are documented here.

## 1.1.0 - 2026-08-24

- Bounded serial object-emission allocation waves adaptively: compiler-sized
  programs collect completed fragment graphs every 32 batches, while function
  streams above 2,048 entries retain the 64-batch stride to avoid unnecessary
  GC work in very large targets. Native compiler builds now start with a
  512 MiB committed heap while retaining the 8 GiB reserve. On the same final
  self-host source this reduced process-tree private peak from 3,551.6 to
  2,281.8 MiB (35.75%) and wall time from 145.527 to 133.109 seconds (8.53%).
  MiniQuake retained its 64-batch path, improved from 259.279 to 258.089
  seconds and emitted the exact existing target image.
- Reused capacity-backed statement/depth/pending worklists and epoch-cleared
  integer, type-flow, dependency, queue and promotion maps across the serial
  per-function analysis pipeline. A controlled same-configuration self-build
  median fell from 130.483 to 110.108 seconds (15.61%), while sampled process-
  tree private peak fell from 5,363.0 to 5,330.8 MiB. A controlled MiniQuake
  build fell from 283.945 to 224.695 seconds (20.87%) and retained the exact
  57,197,056-byte target image.
- Restored self-hosted `--heap-shrink` parity with the Python backend by
  emitting the post-GC top-of-heap decommit block and applying the same 4 MiB
  default threshold when no explicit value exists. Dedicated Windows and Linux
  runtime tests verify both decommit and the configured minimum. Python-built
  and self-hosted Stage 2/3 compiler images are now byte-identical.
- Reused one fully materialized semantic codegen state across the serial
  function-object stream, resetting only the assembler and batch-local fields.
  This removes 294 repeated global scope/map clones without adding GC work;
  binding ids still restart at the canonical value for byte stability. On the
  exact same self-host source, the median of two object emissions fell from
  171.633 to 135.993 seconds (20.77%) and sampled private peak memory fell by
  48.8 MiB. MiniQuake object emission fell from a 239.610-second median to
  215.477 seconds (10.07%) with a slightly lower sampled working-set peak.
  Stages 1-3, all 297 compiler MLOs, all 497 MiniQuake MLOs and the final target
  executables remain byte-identical.
- Streamed local-relocation folding over the assembler's fixed-size patch
  groups instead of first flattening every patch record into a second managed
  array. On the current 297-object self-build, two fixed-point runs averaged
  17.224 seconds in object serialization versus 21.296 seconds for the
  preceding flattened writer (19.12% less); sampled emitter peak working set
  fell from 3,316.6 to 3,286.5 MiB. Stages 2 and 3, including every individual
  MLO file, are byte-identical. A controlled MiniQuake check remained
  byte-identical and showed no build regression; its direct object-emission run
  improved from 243.201 to 240.737 seconds with effectively unchanged memory.
- Folded same-fragment x64 `rel32`/`rip32` relocations directly into each
  materialized text fragment before MLO v2 serialization. New objects retain
  only named cross-fragment/cross-section patches, while readers still accept
  v1 and the earlier numeric-target v2 encoding. On the same current 296-object
  compiler source this reduced retained objects from 158,603,878 to 107,016,076
  bytes (32.53%). Three alternating relinks averaged 5.753 versus 2.617 seconds
  (54.52% less), and average sampled peak working set fell from 875.5 to 481.4
  MiB (45.01%). Both object sets emitted the same 60,443,136-byte executable.
- Added the backward-readable MLO v2 relocation encoding. Same-fragment text
  targets are stored as direct U32 offsets and their local labels are omitted
  from normal object symbol tables; named cross-object and cross-section
  targets retain the existing resolution path. On the same current 296-object
  compiler source, retained objects shrank from 213.30 to 151.20 MiB (29.11%).
  Two alternating relinks with the same final compiler averaged 22.370 seconds
  for v1 and 5.808 seconds for v2 (74.04% less, 3.85x throughput), while one
  sampled linker peak fell from 1,471.0 to 835.5 MiB (43.20%). The v1 and v2
  object sets linked to the same byte-identical compiler image, and readers
  continue to accept existing v1 caches.
- Retained converged integer-flow and value-type lattices as function-local
  hash indexes during emission instead of converting them back to arrays for
  repeated linear lookup. This reduced the fixed-point self-build from 149.766
  to 126.951 seconds and a cold MiniQuake build from 286.077 to 244.399 seconds
  while preserving exact Python/self-host target bytes.
- Combined integer-flow collection, value-type collection and loop-hot-local
  discovery into one deterministic function-statement traversal. On the final
  fixed-point compiler this reduced a cold MiniQuake build from 352.740 to
  286.077 seconds (18.90%) without changing one target byte; the self-build
  improved from 188.948 to 149.766 seconds (20.74%).
- Reduced self-hosted analysis and `.mlo` allocation traffic: nested-statement
  scans now append directly into capacity-backed worklists, while the paged
  writer supports direct little-endian 16-, 32- and 64-bit fields and UTF-8
  strings without temporary byte objects. MLO serialization uses the direct
  U32 and string paths. Target bytes and the MLO1 format remain unchanged.
- Added `--profile-compiler-batches`, which extends compiler phase profiling
  with deterministic per-function-batch setup, codegen, serialization and
  total timings tagged by module/type prefix.
- Added a deterministic per-fingerprint `.mlo` project cache beneath the exact
  final-artifact cache. If the cached executable is absent, the compiler can
  relink the validated sorted object set without repeating frontend/codegen
  work; publication remains atomic and partial populations are rejected.
- Evaluated and removed a parallel object-writer prototype after it regressed a
  compiler self-build beyond six minutes and roughly 3.6 GiB working set. The
  retained implementation remains serial and deterministic.
- Reduced large `.mlo` link time by pre-sizing global and per-object label maps,
  resolving same-object private relocations through their current shard and
  spacing full label-index collections at bounded 128-object intervals. The
  MLO1 format, section order and emitted target bytes remain unchanged.
- Added a standalone retained-object relink gate that verifies byte identity
  independently of the object-emission coordinator.
- Added fine-grained `synchronized(lock)` blocks with exactly-once lock
  evaluation and guaranteed release on normal, return and propagated-error
  exits, while retaining synchronized variables/functions unchanged.
- Added cross-platform futures/tasks, cooperative cancellation tokens,
  `whenAll`/`whenAny` completion helpers and bounded MPMC channels with
  backpressure, timeouts, close/drain semantics and valid `void` messages.
- Added a native Linux self-host script and completed canonical `.mlo` linking
  for ELF. Large links now stream sections, labels and relocations by object;
  dynamic-import ordering preserves byte identity with monolithic ELF output.
- Fixed self-hosted array-stack truncation that incorrectly called the
  bytes-only `slice()` builtin. Parent-path normalization, assembler patch
  rollback and namespaced enum type-query optimization now retain array values;
  the Linux self-build also verifies project-manifest path handling.
- Aligned package-qualified enum-variant resolution in the Python compiler with
  the self-hosted compiler while preserving local shadowing, restoring exact
  target bytes for the complete language acceptance suite.
- Added `--target windows-x64|linux-x64` and manifest `target` selection. The
  new deterministic ELF64 backend includes the managed runtime, global GC heap,
  TLABs, native Linux threads/synchronization and glibc-compatible `.so` FFI.
- Made the complete public standard library usable on Windows and Linux:
  filesystem, IPv4 TCP/UDP, monotonic/calendar time, locks/semaphores/events and
  shared-value storage use native platform adapters, while cryptography selects
  Windows CNG or Linux OpenSSL 3 behind the same API.
- Added target-neutral platform, path, process and console modules; durable
  positional file I/O with advisory locks and atomic replacement; explicit
  socket options and listener addresses; UUID v4; PBKDF2-SHA-256/SHA-384; and a
  provider-neutral TLS stream contract. Linux builds now diagnose unguarded
  Windows `.dll` imports during validation.
- Completed `std.tls` with native Schannel and OpenSSL 3 client/server
  providers, system or explicit trust, DNS-name verification, SHA-256 leaf
  pinning, TLS 1.2/1.3 minimums, server identities and clean shutdown. Added
  real cross-target handshake tests and fixed the Linux null-address `accept`
  FFI signature exposed by TLS listeners.
- Hardened Linux servers by ignoring `SIGPIPE`, made nonblocking OpenSSL reads
  report retryable readiness, and made exact leaf-pin validation independent
  of a machine CA store while retaining hostname, validity-period and TLS
  server-purpose checks.
- Replaced raw `clone(2)` workers with `pthread_create`/`pthread_join` so every
  Linux thread owns valid glibc TLS for malloc, pthread synchronization and
  native providers. The SysV bridge now preserves MiniLang's nonvolatile XMM
  contract, process termination uses `exit_group`, and Linux thread-pool/GC
  regressions run as part of the target gate.
- Kept extern lookup package-qualified when user functions share a native
  symbol's basename, and synchronized the conservative small-loop unroll
  complexity budget across both compilers. This prevents TLS-heavy Windows
  code bloat while preserving byte-identical Python/self-host targets.
- Made committed-heap growth precede the one emergency full collection at the
  reserved ceiling, so normal heap expansion does not bypass `--gc-limit` or
  repeatedly scan large retained object graphs.
- Fixed `--gc-limit` and `--no-gc-periodic` so generated runtime pressure
  counters receive the requested values in both compilers, including the
  unboxed signed-64-bit disable sentinel used by the self-hosted backend.
- Fixed inactive empty lines shifting source/debug locations in the self-hosted
  conditional preprocessor, and removed quadratic label-array copying from the
  self-hosted ELF linker for large, FFI-heavy Linux programs.
- Removed the remaining large-program relocation bottleneck in the self-hosted
  compiler. Very large monolithic builds now resolve text labels directly and
  materialize only section/IAT overrides, codegen assemblers omit unused full
  call histories while retaining helper discovery, and the `.mlo` linker
  preallocates its object-patch index. These changes preserve target bytes.
- Added real Windows threads over a process-wide, thread-safe managed heap,
  per-thread stacks, cooperative stop-the-world GC and synchronization.
- Added 64 KiB thread-local allocation buffers for lock-free small-object
  allocation in threaded programs while preserving the single global heap.
- Fixed a rare high-CPU safepoint livelock under back-to-back collections by
  atomically republishing resumed workers as parked for the next GC request.
- Added thread arguments, logical thread IDs, status inspection, worker pools,
  locks, semaphores and thread-safe list, hash map and shared-value modules.
- Added `defer`, native FFI output parameters and project manifests with
  content-validated incremental builds.
- Added typed, nested conditional compilation with `#option`, `#const`,
  `#if/#elif/#else/#endif`, `#error`, CLI `-D` overrides and manifest
  `[defines]`, while preserving Python/self-host target-byte parity.
- Added CPU feature detection, native byte-search primitives, CRC-32,
  hardware-dispatched CRC-32C and platform-native cryptography helpers.
- Improved generated-code optimization with known-struct method
  devirtualization/inlining, hot primitive XMM register homes and constant
  integer strength reduction; also improved global/object initialization and
  the memory-bounded self-hosted `.mlo` pipeline while preserving cross-compiler
  target-byte parity.
- Added guarded type-flow specialization for fallible `bytes(...)` results and
  16-byte user-function alignment. This restores compact byte-processing hot
  paths without weakening runtime errors and prevents local size wins from
  shifting later functions onto unstable instruction-cache boundaries.
- Replaced the self-hosted type-flow pass's repeated whole-function fixed-point
  scans with indexed facts and a dependency worklist, keeping compiler-sized
  source builds bounded while preserving emitted target bytes.
- Made package-qualified enum constants available to integer-flow analysis and
  replaced repeated self-hosted candidate-membership scans with indexed,
  monotone validation. This restores Python/self-host target parity without
  slowing large generated programs.
- Expanded cross-compiler, runtime, standard-library, fixed-point and large
  application regression coverage.

## 1.0.0 - 2026-08-22

- First stable, source-only release of the Python reference compiler and the
  self-hosted MiniLang compiler.
