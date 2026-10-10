# Windows background collector, 2026-10-10

The self-hosted compiler now accepts `--gc-concurrent` for `windows-x64`.
The installed development compiler is `build/mlc_win64.exe`; its previous
executable is preserved in `build/gc-concurrent-2026-10-10/mlc-before.exe`.
The public version remains 1.2.18; this is a local development build.

```powershell
.\build\mlc_win64.exe program.ml program.exe --gc-concurrent
python tests/check_concurrent_gc.py build/mlc_win64.exe
```

`gc_collect_async()` requests a cycle without waiting for tracing or sweeping.
An active cycle absorbs another asynchronous request without queuing a second
snapshot. `gc_collect()` retains its synchronous completion contract. Without
the option, the asynchronous builtin falls back to synchronous collection.

## Runtime behavior

A persistent native Windows worker waits on an event between collections. It
uses a private runtime context and never enters managed application code.
Periodic allocation pressure requests work; emergency allocation waits for it.

The worker briefly stops managed threads to capture roots, clear the bitmap and
freeze the allocation frontier. It then traces concurrently. Deletion barriers
record overwritten references in array/member stores, captured-variable boxes,
Thread reference fields and `copyArray`. The worker drains those references
while marking and uses a short termination handshake to finish the snapshot.
Weak Thread registry cleanup also runs under that handshake.

New allocations remain above the frozen frontier and are protected for the
current cycle. Old free blocks remain unavailable until the worker completes
its two sweep passes and publishes a private free list under a final handshake.
Free TLAB tails created after the snapshot are merged into that publication.

An emergency waiter releases every recursive heap-monitor acquisition before
waiting. It restores the original depth afterwards. If another waiter has
started a new snapshot meanwhile, it waits for that cycle before allowing the
allocator to retry, so hidden free blocks do not cause a false OOM.

The deletion log defaults to 8 MiB, outside the managed heap. The diagnostic
`--gc-satb-limit` option clamps capacities to 64 bytes through 64 MiB. Overflow
retains all allocated snapshot blocks for that cycle and increments a counter.
It does not silently lose a reference and reclaim the pointed-to object.

## Scope and limits

- Both compiler implementations now support Windows x64. The Linux target
  rejects this mode; its default collector remains supported. See the later
  [cross-compiler verification](CONCURRENT_GC_PARITY_2026-10-10.md).
- Collection still has cooperative pauses. Native or managed scheduling delays
  can lengthen a handshake; the worker does not eliminate all rendering stalls.
- `--heap-shrink` is rejected. Dead blocks are reused, but committed pages and
  the heap frontier stay at their high-water marks. Floating garbage and frozen
  free blocks require extra memory headroom.
- Native extensions can read rooted objects and mutate byte buffers. Raw writes
  into managed reference slots bypass deletion barriers and are unsupported.
- An explicit synchronous request can still stall its calling thread. Use the
  asynchronous builtin where the application can continue without its result.

## Validation

- The existing regression suite completed all 379 logged steps successfully
  with the new compiler in its default mode. The later changes emit code only
  for the concurrent option.
- `tests/check_concurrent_gc.py` passed 18 fixtures in both monolithic and object
  pipelines. Each pair of generated executables is byte-identical. Coverage
  includes reference transfers, closure writes, bulk copies, allocations during
  marking, Thread results/lifetimes, floating roots, TLABs, heap growth and
  emergency recycling. It also checks exactly one default-mode collection per
  asynchronous API call, rejects incorrect arity, and rejects Linux/concurrent
  and shrink/concurrent combinations. The normal transfer fixture asserts that
  its default-sized log has no overflow, so conservative retention cannot hide
  a missing deletion barrier.
- The 64-MiB shared-heap pressure fixture passed 20 consecutive runs with two
  allocation workers. The forced 64-byte-log fixture passed 10 runs and reported
  an overflow in every run while retaining all transferred payloads.
- Self-hosting and smoke tests passed. Successive final builds v9 and v10 are
  identical: SHA-256
  `68c3da20756dca30b7c2cb4ec46f7720825f596511ccc507cfebd8402107f373`.

Raw artifacts and logs are in `build/gc-concurrent-2026-10-10/`. The standalone
pause comparison uses `benchmarks/concurrent_gc_pauses.ml` with 800,000 retained
nodes and twelve collections on another managed thread.

## Pause comparison

Three interleaved runs used the same fixture with the previous compiler, the
updated compiler's default collector, and the optional background collector.
Builds finished before timing began.

| Collector | Longest observed main-thread interval, three runs |
| --- | --- |
| Previous synchronous | 12.6994, 12.4685, 12.8839 ms |
| Updated synchronous | 12.9160, 13.0787, 13.5133 ms |
| Updated concurrent | 0.0489, 0.0981, 0.4112 ms |

The background runs recorded roughly 1.97–2.08 million main-thread iterations
during marking. The runtime's longest handshake measurements were 0.0895,
0.0935 and 0.0931 ms, including the initial collection before timing the main
loop. These are local measurements, not worst-case guarantees.
The observed main-thread interval also includes OS scheduling and native-counter
call overhead. The benchmark checks the final graph payload and successful
worker completion; raw results are in `build/gc-concurrent-2026-10-10/pauses-final.log`.
