# Compiler parity and self-hosting

Verified through 1 September 2026 against the matching 1.2.0 revisions of:

- `MiniLangCompilerPy`, the Python bootstrap/reference compiler; and
- `MiniLangCompilerML`, the compiler implemented in MiniLang.

## Compatibility result

There are two compatibility claims:

1. **Target-output parity:** for the same sources, include-root order and
   compiler options, the Python compiler and the normal self-hosted path emit
   byte-identical Windows x64 PE or Linux x64 ELF files. The self-hosted `.mlo`
   path adds the same guarantee for Windows PE and Linux ELF.
2. **Compiler-image layout contract:** compiler sources use the same canonical
   entry/function/support and section layout as every other target. Historical
   full fixed-point measurements are listed separately from current automated
   and MiniQuake target-output measurements.

Python accepts `--object-pipeline` for project/CLI parity and emits its
equivalent monolithic image. The self-hosted compiler streams canonical `.mlo`
sections, labels and relocations into either PE or ELF. Dynamic-import order is
encoded explicitly, so Linux object builds retain the monolithic image's exact
bytes.

## Post-release ownership and cache hardening fixed point

Verified on 1 September 2026 after the compiler, comment and documentation
audit and its follow-up concurrency/FFI hardening. Thread construction now
publishes `Running` only after the native handle exists, `SetLogicalId` is
atomic with respect to `Start`, `Stop` owns the startup-publication window,
concurrent Linux joins share one native `pthread_join`, and `Close` waits for
the native epilogue after atomically claiming a handle. Per-handle waiter
references make concurrent `Join`/`Close` safe, while blocking cleanup leaves
GC participation until it re-enters managed code. Thread contexts are packed
into synchronized 64-KiB arenas. Linux FFI treats every `out` parameter,
including `out double`, as a pointer-class argument, rejects conflicting ABI
aliases and preserves the exact declared library identity. Ordinary strings
whose text equals an internal conversion sentinel remain ordinary strings.
The self-hosted Linux runtime uses named, automatically checked blob boundaries
and relocation sites. Process-wide socket initialization is serialized and an
explicit Windows UDP reuse request now overrides the ordinary exclusive-bind
default. The self-hosted object cache validates every MLO's content identity,
while build and test cleanup is restricted to invocation-owned staging trees.

| Compiler image | Size | SHA-256 | Build time |
| --- | ---: | --- | ---: |
| Windows Stage 1, built by Python | 66,393,088 | `6000AAE0787F3A9B8C93B1206AEEE07D91B5F831ED11E0609A278BBD0212F780` | 92.286 s |
| Windows Stage 2, built by Stage 1 | 66,393,088 | `6000AAE0787F3A9B8C93B1206AEEE07D91B5F831ED11E0609A278BBD0212F780` | 187.630 s |
| Windows Stage 3, built by Stage 2 | 66,393,088 | `6000AAE0787F3A9B8C93B1206AEEE07D91B5F831ED11E0609A278BBD0212F780` | 188.809 s |

The three identical images establish the Windows self-host fixed point. The
Python suite passes 132/132. The self-hosted inner harness passes 126/126 in
89.167 seconds, while the complete Windows/WSL wrapper passes every outer
Linux, FFI, GC, object-pipeline, blob-layout and relink gate in 132.080 seconds.
All 46 standard-library files are byte-identical between repositories.

The current targeted cross-compiler matrix is also byte-identical:

| Regression / target | Size | SHA-256 |
| --- | ---: | --- |
| Thread lifecycle races, Windows PE | 230,912 | `FB4C00740E4D0D182C935A53F8FCE0F2F8A031068227D44675E50307182FAAA3` |
| Thread lifecycle races, Linux ELF | 235,280 | `0C6E2F9BC502CDA56377667DCE8F5EED680578A2469A33D9067EBE2A0ACF254C` |
| Linux `out double` FFI | 87,664 | `3735604564E7F6723DE85E1D477974A67BC0C11FF9AB816254394A1B754F6876` |
| Exact Linux library spelling | 87,664 | `A91C44BE93B14FB651625989402F772377F28A7FBBA0BEA2CB1FA3F15F22A9BD` |
| Language extensions, Windows PE | 655,360 | `FC740384B74B7064803E5C657F6B0BD68D12C6F33F0442B20F57E69231FD629E` |
| Language extensions, Linux ELF | 743,984 | `94B8DC43E546F7F8F72F28C1F154D15BEB1A8E668462085E56D242948CD9BA1E` |
| Standard-library suite, Windows PE | 4,528,128 | `87B1294EA0903BC42934220C01C4F2D622A0D8AB79B65D51A6925F9C864DE2E9` |
| Standard-library suite, Linux ELF | 4,493,296 | `AFA6384DF05A2C90C47C55EDFD825EFF85BD5C8F60DFE6EDC846826BD98192DB` |

The Linux monolithic/`.mlo` smoke gate retains exact object-pipeline parity at
SHA-256 `749A3483B6B711DF6DA0B6AF932EAD090F71542684435DCB7572F272E948544B`.


## 1.2.0 release fixed point

Verified on 1 September 2026 after the release version update, reusable
assembler hardening and bounded conservative GC object scans. Every compiler
reports `MiniLang Compiler 1.2.0`.

| Compiler image | Size | SHA-256 | Build time |
| --- | ---: | --- | ---: |
| Windows Stage 1, built by Python | 65,695,232 | `13D485D2FA64B97794BB30F0E25B093BAE84BF3EECF3C8FB07C034044CDF429A` | 94.399 s |
| Windows Stage 2, built by Stage 1 | 65,695,232 | `13D485D2FA64B97794BB30F0E25B093BAE84BF3EECF3C8FB07C034044CDF429A` | 231.758 s |
| Windows Stage 3, built by Stage 2 | 65,695,232 | `13D485D2FA64B97794BB30F0E25B093BAE84BF3EECF3C8FB07C034044CDF429A` | 218.076 s |
| Linux Stage 1, cross-built by Windows Stage 3 | 65,651,952 | `55F63603A034740ECD3C2C479A8DD550EB6F2594D4BD6F27DD084BC04750E784` | 122.282 s |
| Linux Stage 2, built natively by Linux Stage 1 | 65,651,952 | `55F63603A034740ECD3C2C479A8DD550EB6F2594D4BD6F27DD084BC04750E784` | 418 s |

All three Windows images are byte-identical. The cross-built and natively
self-hosted Linux images are also byte-identical. The Linux time includes WSL2
I/O against the mounted Windows checkout and the build script's monolithic,
object-pipeline and project-manifest smoke tests; it is not a compiler-only
performance baseline.

The release regression suite additionally constructs a conservative interior
heap pointer whose payload mimics an environment with an impossible slot
count. The previous scanner crashed with an access violation; both release
backends now reject the count against the candidate block size on Windows and
Linux.

## Historical modern-constructs fixed point

Verified on 31 August 2026 after adding profile-selected type contracts,
non-escaping variadic compiler helpers, native final-size array allocation and
direct chunk/tail materialization:

| Compiler image | Size | SHA-256 |
| --- | ---: | --- |
| Stage 1, built by Python | 65,654,784 | `DF65FD5091ADEFA200F15BB5E3BABC127923BA41081F263993B2282F19965341` |
| Stage 2, built by Stage 1 | 65,654,784 | `DF65FD5091ADEFA200F15BB5E3BABC127923BA41081F263993B2282F19965341` |
| Stage 3, built by Stage 2 | 65,654,784 | `DF65FD5091ADEFA200F15BB5E3BABC127923BA41081F263993B2282F19965341` |

The complete Windows/WSL regression gate passes. Direct cross-compiler target
checks are byte-identical and execute successfully:

| Target fixture | Size | SHA-256 |
| --- | ---: | --- |
| Windows PE `language_performance_features.ml` | 585,216 | `0DD2A247A336E7AE1C2D697B3D69309D9A241D4288C43311902A8A43C0CCD9E1` |
| Linux x64 ELF `language_performance_features.ml` | 667,216 | `3DC0F8C2CCF8D2B83782200E3A14F8D84975987F0ED156A2ECA11537D893B9D1` |

The measured self-host build fell from 149.977 to 138.124 seconds. Sampled
process-tree private peak fell from 1,830.3 to 902.6 MiB and working-set peak
from 1,728.3 to 792.1 MiB. The complete methodology, per-phase data and the
lazy-iterator/background-emission experiments that were rejected are in
[the modern-constructs report](docs/COMPILER_MODERN_CONSTRUCTS_BENCHMARK_2026-08-31.md).

## Modern language-extension parity

The combined gradual-types, richer-calls, lambda, `match`, iterator,
interface and async acceptance fixture has exact parity across the Python,
self-hosted monolithic and self-hosted `.mlo` paths:

| Target | Size | SHA-256 |
| --- | ---: | --- |
| Windows x64 PE | 216,064 | `7B5FB76064E5C7274A7F4E647C3BFA29388D092AC267DE191CBDEC1B55036E98` |
| Linux x64 ELF | 226,880 | `7837B2A4F75307A482F1E98C57E55139229FCEADF86FE9B08553EBB7A07C3BA3` |

The object-pipeline regression also verifies that typed struct-field contracts
survive fragment-state cloning. Invalid constructor values therefore retain
runtime error 1308 instead of silently bypassing their type guard.

The complete compiler was bootstrapped again after adding these constructs.
The Python-built Stage 1 and its self-hosted Stage 2 are byte-identical:

| Compiler image | Size | SHA-256 |
| --- | ---: | --- |
| Stage 1, built by Python | 64,539,136 | `CF695355E7D4213FEB3DB751FEC9B4BD5F452E2533E7E49828AA23E0CC9F6BAB` |
| Stage 2, built by Stage 1 | 64,539,136 | `CF695355E7D4213FEB3DB751FEC9B4BD5F452E2533E7E49828AA23E0CC9F6BAB` |

The self-hosted Stage 2 build completed in 189.795 seconds. Since the two
compiler images are identical, this revision reaches its deterministic fixed
point after the bootstrap stage.

## Historical compact-index fixed point

Verified on 30 August 2026 after replacing the self-hosted compiler's tagged
`FastMap` generation arrays with byte buffers and allowing deterministic maps
to reach 80% occupancy before rehashing:

| Compiler image | Size | SHA-256 |
| --- | ---: | --- |
| Stage 1, built by Python | 60,690,432 | `5E2518E16AC783F90F8E72E353338629088035D35A7870A15DEA283D7C605E20` |
| Stage 2, built by Stage 1 | 60,690,432 | `5E2518E16AC783F90F8E72E353338629088035D35A7870A15DEA283D7C605E20` |
| Stage 3, built by Stage 2 | 60,690,432 | `5E2518E16AC783F90F8E72E353338629088035D35A7870A15DEA283D7C605E20` |

The controlled object-emission comparison used the same source and options:

| Self-host build | Wall time | Private peak | Working-set peak |
| --- | ---: | ---: | ---: |
| Tagged generation arrays, 70% occupancy | 107.143 s | 1,944.2 MiB | 1,904.3 MiB |
| Byte generations, 80% occupancy | 104.266 s | 1,823.9 MiB | 1,792.1 MiB |
| Change | -2.68% | -120.3 MiB (-6.19%) | -112.2 MiB (-5.89%) |

A second final Stage-3 emission completed in 102.678 seconds at the same
1,823.9 MiB private peak. Python and self-hosted builds of the Windows language
suite are also byte-identical at 1,623,040 bytes with SHA-256
`93B7FEBC4DCF15D84E3A090FE3A0057E409ABCA6B77A8FA948C35F702EC9E01B`.
The ML harness explicitly covers the byte-generation wrap, stale-slot removal,
80% density and rehash behavior.

## TLAB allocator fixed point before compact indexes

Verified on 30 August 2026 after adding O(1) right-neighbor coalescing when a
thread retires its unused TLAB tail:

| Artifact | Size | SHA-256 |
| --- | ---: | --- |
| Compiler Stage 1, built by Python | 60,690,944 | `E508C72C4131CC5341656E473AA96E93EBBABDE3B11719F774D4BF7792F8B679` |
| Compiler Stage 2, built by Stage 1 | 60,690,944 | `E508C72C4131CC5341656E473AA96E93EBBABDE3B11719F774D4BF7792F8B679` |
| Windows `tlab_shared_heap.ml`, Python/self-hosted | 123,392 | `D155B97DF4D6E5F0085E3917B858A96CBEAC757AC79C5E1F32EE236764AB99DF` |

The targeted threaded fixture completed under both generated images. The
Python and MiniLang test harnesses additionally require the new
`tlab_retire_publish_*` block, so parity covers the coalescing path rather than
only the pre-existing TLAB fast path.

## Historical Windows/Linux target fixed point

The final cross-target compiler source was bootstrapped and self-compiled on
27 August 2026. The Windows compiler image is identical from the Python stage
onward:

| Compiler image | Size | SHA-256 |
| --- | ---: | --- |
| Stage 1, built by Python | 59,691,520 | `35C5B77A752E2B53F1FC76F618D05A5F27B700A77E8636566A6CDA645AC1F199` |
| Stage 2, built by Stage 1 | 59,691,520 | `35C5B77A752E2B53F1FC76F618D05A5F27B700A77E8636566A6CDA645AC1F199` |

Stage 1 and Stage 2 are byte-identical, so the compiler is already at its fixed
point: Stage 2 is the same executable, and a deterministic Stage 3 invocation
therefore emits the same bytes.
Direct Python/self-hosted comparisons also
produced identical target files:

| Target fixture | Size | SHA-256 |
| --- | ---: | --- |
| Windows PE `language_suite.ml` | 1,623,040 | `8E1571FD5077ACF0F978B493A56A900F708BD50CDBB8F01D22BB4C77A8F50E08` |
| Static Linux ELF smoke | 87,008 | `DA98B53BE2E374B6B48283EB5CDA7BD11A421DF3C6F6C30442D93B1761B3E376` |
| Dynamic Linux ELF FFI | 87,440 | `BCAAA93565F5A20D52C7AFDF058D1AD1A017E5EE22B3CE3326E9A55C223418D0` |

The ELF tests ran under WSL and cover process arguments, managed allocation,
threads/GC, `libc` integer/pointer calls and `libm` floating-point calls. The
complete suites report Python 114/114 and MiniLang 104/104, with additional
self-hosted Linux static, FFI, thread/GC and object-flag compatibility gates.

On 26 August 2026 the Linux worker runtime moved from raw `clone(2)` to pthreads.
The Python compiler and a freshly Python-bootstrapped self-hosted compiler both
emitted the same `thread_pool.ml` Linux ELF with SHA-256
`A81E1715E563E9B9C15D6740E22B6F7A26C6D1FC8C600E13178DB149239FB3AE`.
That image completed 20 consecutive thread/GC/pool runs under WSL2.

## Native Linux `.mlo` fixed point and concurrency surface

Verified on 27 August 2026, the native Linux self-build now uses the canonical
ELF `.mlo` linker rather than redirecting to a monolithic build. The linker
combines section bytes first, then streams labels into public/per-object maps
and applies relocations one object at a time. The Python-bootstrap Stage 2 and
self-hosted Stage 3 results are byte-identical:

| Compiler image | Size | SHA-256 | Build time | Max RSS |
| --- | ---: | --- | ---: | ---: |
| Linux Stage 2 | 59,684,080 | `DF4BA2E90A73FFA222733742846EC16DC2D5CB5C217C484209E6178F74520BAA` | 203.41 s | 3,303,360 KiB |
| Linux Stage 3 | 59,684,080 | `DF4BA2E90A73FFA222733742846EC16DC2D5CB5C217C484209E6178F74520BAA` | 210.48 s | 3,303,360 KiB |

Threaded `synchronized(lock)` and task/channel fixtures are byte-identical
between the self-hosted monolithic and `.mlo` ELF paths. They cover exactly-once
lock evaluation, return/error cleanup, acquire failure, tasks/futures,
cooperative queued/running cancellation, `whenAll`/`whenAny`, bounded MPMC
backpressure, close/drain/dispose behavior and valid `void` messages.

The final Python, self-hosted monolithic and self-hosted `.mlo` builds produced
one identical hash per target for every new acceptance fixture:

| Fixture | Windows SHA-256 | Linux SHA-256 |
| --- | --- | --- |
| `synchronized(lock)` | `5C3D167EE6B6962875D65325AF6F29F6EDEFCF2EB883A918169C26234DD13E11` | `04EFF0595B9EA2BC59FA9AEEBEDA8137B4449340CB50EB46A029FBDFFA7E36FC` |
| tasks, cancellation and channel | `A1FFE4C64A800F44381E6F3A602D4F6B3FFFCEFBF6B00E99D0FE4BEBD6A6901C` | `86442515EE993FDA9551D13FAACFC62ACCAA3853B02A070CEC1029BA681F7738` |
| portable platform services | `4DA34EF30ADCF18B9430B57FDDF38D97BA0A0179A1872C74B1704F50BC31F9FA` | `94DA76CF24BD6F33FB58568D36BF699961D119E88E6D4081AA86C4AA1C4FC3EE` |

The same bootstrap smoke also compiles a project whose output contains a
parent-path component. This guards Linux path canonicalization and the
self-hosted compiler's explicit array-stack truncation helper.

The repeatable concurrency benchmark is byte-identical across Python and
self-hosted `.mlo` output: Windows SHA-256
`42ABE01A4F780735B2620FC750800E3B2C53BC5CAB7AF2C8C97D4F255D0B6B39`, Linux
SHA-256 `507CDA78FD30E0426B35DC8C8437EC2D89746A6CB91428D66D271B0363F67044`.
Five fresh-process runs on the same WSL2 host measured these medians:

| Workload | Windows | Linux |
| --- | ---: | ---: |
| 10,000 tasks | 94 ms | 282 ms |
| 250,000 bounded-channel messages | 5,766 ms | 1,441 ms |
| 400,000 `synchronized(lock)` updates | 1,750 ms | 312 ms |

These are platform comparisons, not pass/fail thresholds; the benchmark checks
all counts and checksums before reporting time.

## 1.1.0 release fixed point

The release compiler was rebuilt through the complete trust chain. All stages
report `MiniLang Compiler 1.1.0`.

| Compiler image | Size | SHA-256 |
| --- | ---: | --- |
| Stage 1, built by Python | 55,712,256 | `3453273F217CBD24BC38777B4AF5255AC1117C6E00DB803DFC0C94654212A8EE` |
| Stage 2, built by Stage 1 | 55,712,256 | `431C7E74BB0A200EA17BB1831D726C8CB5755DB3008A07687916375E717AD71F` |
| Stage 3, built by Stage 2 | 55,712,256 | `431C7E74BB0A200EA17BB1831D726C8CB5755DB3008A07687916375E717AD71F` |

Stage 2 and Stage 3 are byte-identical, establishing the self-hosted fixed
point. The equally sized Python bootstrap image has a different layout; it is
the bootstrap input, not the fixed-point claim.

The representative `language_suite.ml` target was then built by Python, by the
Stage 3 monolithic path and by the Stage 3 `.mlo` path. All three files ran
successfully and were byte-identical: 1,620,480 bytes, SHA-256
`6E7BF4DCA93339C95B6EB4587613918053EE827A178A4055124599978FF94C67`.

## Historical TLAB and safepoint fixed-point verification

The post-release TLAB implementation and the back-to-back GC safepoint fix were
bootstrapped and self-compiled again on 24 August 2026. The compiler image
stabilized after the first self-hosted stage:

| Compiler image | Size | SHA-256 |
| --- | ---: | --- |
| Stage 1, built by Python | 56,076,800 | `FF9ABB3004E780C7B0CF0295AB5F4CA02197CA508F2C87E51F76C5B0CE222BEE` |
| Stage 2, built by Stage 1 | 56,076,288 | `4CA9E4030FAC128DCFCDD3AAB6D885C1E29F04DBC9A9DCD006D48EC96682907B` |
| Stage 3, built by Stage 2 | 56,076,288 | `4CA9E4030FAC128DCFCDD3AAB6D885C1E29F04DBC9A9DCD006D48EC96682907B` |

The parallel short-lived-allocation target built by Python and Stage 2 is
byte-identical at 170,496 bytes with SHA-256
`191A6FA983B7F9E83236E9AE970DB1174927D7D98F9AAB061AD73B9BC07DC8FB`.
Its 24-thread, 48-million-allocation workload completed 50 consecutive runs
without a timeout after the fix. The dedicated back-to-back GC regression is
also byte-identical at 112,128 bytes with SHA-256
`F2AE65320F4A92C2EA5232B04F4CE8B83BC335DDF552870FD50DEBDD38468F82`.

## Historical optimizer-audit fixed point

The comment, optimizer-safety and code-hygiene audit was bootstrapped again on
24 August 2026. The compiler stabilized at the first self-hosted stage:

| Compiler image | Size | SHA-256 |
| --- | ---: | --- |
| Stage 1, built by Python | 56,525,824 | `5429DF4838EE38CE8C21D401EADF06DA3E5727063AB5F9B3375F7D788DBA5FA9` |
| Stage 2, built by Stage 1 | 56,525,312 | `BA5286D04184C3C9BD74E8EAE44BD41B7FD4AF7777810B10757CDB39969E9AE6` |
| Stage 3, built by Stage 2 | 56,525,312 | `BA5286D04184C3C9BD74E8EAE44BD41B7FD4AF7777810B10757CDB39969E9AE6` |

The representative `language_suite.ml` target built by Python, by Stage 3's
monolithic path and by its `.mlo` path is byte-identical in all three cases:
1,622,016 bytes, SHA-256
`AC1C08B988A0B8A8987F487B2DFB2D95553733D8F0A41DBB86F597D29F4F6029`.

## Historical performance-hardening fixed point

The guarded fallible-bytes specialization, 16-byte user-function alignment,
package-aware integer flow and indexed self-hosted analyses were bootstrapped
on 25 August 2026:

| Compiler image | Size | SHA-256 |
| --- | ---: | --- |
| Stage 1, built by Python | 56,743,936 | `5E84848F01D6147C1EE0D7BA47FE610DBF9093E05299AF2EF029B34B594B26D2` |
| Stage 2, built by Stage 1 | 56,743,936 | `E85E3A6EE515DC8605A10752DA953E0FBF92C5992CC354179CA7A471E11AFFEF` |
| Stage 3, built by Stage 2 | 56,743,936 | `E85E3A6EE515DC8605A10752DA953E0FBF92C5992CC354179CA7A471E11AFFEF` |

Stages 2 and 3 are byte-identical. Their object-pipeline self-builds completed
in 283.065 and 304.742 seconds. The optimization fixture built by Python, by
Stage 3 monolithically and through `.mlo` is byte-identical in all three cases:
466,944 bytes, SHA-256
`99C21E99AC0A2BC194B2C49858CA04798FC52B4AA097C5CFADDC0DF1BE2CF565`.
The complete suites report Python 104/104 and MiniLang 97/97.

The MiniSQL 1 GiB offline checker is also byte-identical when built by Python
and by Stage 3: 23,589,888 bytes, SHA-256
`C0A226BB6E25427A9819A5F3056919515DFB1CADD99BDA577A0F2708B9E5C8E6`.
Seven interleaved runs measured a 3,749.1 ms median for the pre-optimization
compiler and 3,764.9 ms for this revision (+0.42%, within run-to-run noise),
removing the previously observed 3.5% regression.

The broader MiniSQL recheck also removed the reported storage regression and
substantially reduced the parallel-scan regression. Seven interleaved 64 MiB
writes measured 2,891 ms with the previous
compiler and 2,844 ms here (+1.7% throughput). At 4, 8 and 16 concurrent
`SUM(id)` clients the remaining deltas were -1.3%, +0.2% and -2.3%; a longer
two-client run retained a smaller -2.5% delta. The earlier consistent 5-8%
multi-client slowdown is therefore gone, while the residual low-concurrency
variance remains visible rather than being treated as a speedup.

## Historical regression binary record

The following exact hashes record the earlier broad parity pass. The programs
remain in the automated suites; the table is retained as a reproducible
historical record rather than relabelled with unmeasured release hashes.

| Program | Size | SHA-256 |
| --- | ---: | --- |
| `language_suite.ml` | 1,611,264 | `EFAB37BAE26C94D37F86251DF06A3C9C2BA8B5EFF783C036D4103F3134FAB39A` |
| `stdlib_unit_tests.ml` | 3,762,688 | `FCD7C73C89A485D248B7CAD91903BFEFDB8036E1A88705646A914DA12058FA3E` |
| `gc_periodic_test.ml` | 161,280 | `4876C18B4E367688A26090E6EC947921E1543EB60052618E063C794DACC78E99` |
| `gc_heap_stress.ml` | 83,456 | `F466A0EE8CE26C2BD71D365C600CECBF8F00152F655323A95FB02119BE51D718` |
| `gc_box_float_safepoint.ml` | 365,056 | `EF8DFCFB90DD57D2E9778DCFE6715DA1E6A0E1CBDE240F0BB8D891C68F062A72` |
| `gc_float_call_roots.ml` | 411,648 | `F505F887117B069766A88A1311C84F516B7005F7A3662E9999BA2288121C996B` |
| `gc_nested_graph_roots.ml` | 271,872 | `F2F7C04AD3E0F907EDBB25D4E0959FA8E314DD6CD0BFD1FA17B3CFED360DF07B` |
| `gc_reference_write_roots.ml` | 132,608 | `4C1AA70AA4501458C576AA6F619BBCDD41542FDC3AE1F2A8AD5F537D4ED25355` |
| `aes128_ecb_nist_kat.ml` | 331,776 | `D257F6F7F75036384DB08F6AA22C9D9CCDCAF9CA1E7146B245A799CA2B0A08F4` |
| `winapi_extern_smoke.ml` | 64,512 | `944BA64C4D8C5A27CCE8E17ADB0E0A7683D128D13D3EEC0F08526B255AA19564` |
| `native_bytes_ptr_smoke.ml` | 84,480 | `2F2D64A74A5258B6A633A9354D8D39AC825A8030E4C350C2471E9351AD60676C` |
| `native_raw_value_smoke.ml` | 82,944 | `1615B1278569E998597F4E2C2317513E9BA9ABE368846D7FB5FAEC7F4D6AE21F` |
| `native_callback_wndproc_smoke.ml` | 86,528 | `82FC4B0ECA563535841D8ED1EA1A2446E30E18A0FB52A11A09552BBC690419E3` |
| `global_function_rebind.ml` | 69,120 | `A3D4661966A7AC7E7E57DC11FD7C1C39E7499DD8C49D1B49489F225DB72B1891` |
| `thread_features.ml` | 239,104 | `AC62897033463B3E33BACC25B77E160A76ED71EFD74B1D9499742AAC16EF93C9` |
| `threading_stdlib.ml` | 908,800 | `89AFECFE6DF68134D54B7F914DB7275A466615F3A9ED0455C1FB025D2DB12D19` |
| `extern_abi_validation_valid.ml` | 70,656 | `05387489F45AEE34BF227E4965281A93137159AB84B7C4BA09565A32920EE6D8` |
| `codegen_optimizations.ml` | 331,776 | `34478CFA76A8B1493B92B99C099F7ED0A5939589FB5CC045C0E667059B38B6AF` |
| `thread_pool.ml` | 656,896 | `294AF95CD24BDD72DFBF0258F05C9B21A8542BB097531049F4E92571B601EBE2` |
| `type_checks.ml` | 135,680 | `CABA11CACCCC9A15946172085489C50D0452AD15E2EF20F5B4EC7A8C7F8A4BCA` |
| `member_callable_direct.ml` | 72,704 | `99EB4C4FD38EBBCB82A8EA994E9F815C31C59BED2C0B0117246DC032C69BD886` |
| `codegen_phase_gc.ml` | 404,480 | `70D9F9145CFAA29716E72160B760DDA31B992A56750D6A000AB87ED7A4622D03` |
| `compiler_gc_liveness.ml` (`--gc-limit 1m`) | 164,864 | `0A6617023A0EB39691AEAE6BB8CBF2749E2C745550FE431603B1B61578C3B3E4` |
| `defer_features.ml` | 83,456 | `D5ADFC76E2BD6FA08AE1313CBA75D38C77FD48FDA0A0D9A231C5EF23ABB069C7` |
| `extern_out_runtime.ml` | 74,240 | `A3317E95D46637027B7DBD6BCF493D6ED3CE1FBB84C618FD27E693371834168D` |

This coverage includes imports and the standard library, closures, inline
functions, structs, enums, GC, extern declarations, native interop, real Win32
threads, one process-wide managed heap, per-thread stacks and GC root chains,
cooperative stop-the-world collection, synchronization primitives and
thread-safe collections that preserve shared object identity, one-value thread
arguments, logical thread ids, 64 KiB thread-local allocation buffers and
managed worker pools with backpressure.
It also exhaustively covers every public `is` runtime category, including
case-insensitive `Thread`/`thread` checks and their negated forms.
Compiler-scale coverage crosses repeated phased collections and verifies that
target GC options cannot alter compiler-internal collection or target bytes.

All 46 files below `std/` also have matching relative paths and byte-for-byte
identical contents in both repositories. This includes `std.threading`, the
concurrent collection modules, CPU feature dispatch, CRC-32/CRC-32C checksum
modules and the CNG-backed cryptography modules.

## Historical pre-canonical bootstrap and self-build stages

The same `MiniLangCompilerML/mlc_win64.ml` source tree was compiled with the
same heap and GC options for this comparison.

| Compiler image | Size | SHA-256 |
| --- | ---: | --- |
| Python-built MiniLang compiler | 54,161,920 | `92363D1BC22A2B7EA648C189A563B6EC86B9BBCDF1D5861DA29D528593B1FC3C` |
| MiniLang self-build through `build.ps1` / `.mlo` | 54,650,368 | `C6365921E6112AEEEA7F32DFF9E846A1AD358448582C72A6579EFAB6F67E4B00` |

The table above records the last release artifact comparison before canonical
object layout was introduced. Current `.mlo` linking concatenates fragments in
the exact monolithic entry/function/support and section order, shares the
global constant pools, and therefore no longer introduces an image-layout
difference. The historical compiler-image rows are retained for comparison;
they are not presented as a fresh fixed-point measurement of this revision.

Both compilers report `MiniLang Compiler 1.2.0` for `-version` and
`--version`. The repositories and GitHub releases are source-only; generated
compiler and test executables are intentionally excluded.

Self-builds should use `MiniLangCompilerML/build.ps1` on Windows or `build.sh`
on Linux. Both keep the large assembler graph bounded by spilling canonical
`.mlo` fragments, and the memory-management strategy does not change the
resulting compiler image.

## Parity work included in this revision

No existing feature was removed. The synchronized surface includes:

- aliased explicit-file and relative imports;
- stricter extern ABI validation and positive/negative fixtures;
- native scalar/managed-struct marshaling for omitted trailing `out`
  parameters, including BOOL failure propagation;
- LIFO `defer` cleanup with call-time captures on return, fall-through and
  automatic error propagation;
- TOML project manifests with content-validated incremental artifact caching
  and optional self-hosted `.mlo` builds;
- typed conditional compilation with identical predefined target values,
  per-file options/constants, CLI/project overrides and cache identity;
- native bytes pointers, raw-value conversion and callback smoke coverage;
- `array(size[, fill])` construction;
- global function-value rebinding;
- inline-function lowering and eligibility checks;
- real Win32 threads with cooperative stop/join/status operations, optional
  one-value arguments/results and separate native/logical ids;
- one global, thread-safe managed heap with private thread stacks and
  cooperative GC safepoints;
- synchronized globals of any value type and synchronized functions;
- native locks, semaphores and events plus thread-safe list/hash-map types;
- reusable managed thread pools with bounded/unbounded queues, job lifecycle,
  backpressure and graceful/immediate shutdown;
- `Thread` as a first-class, case-insensitive `is` runtime category, verified
  together with every other public primitive, struct and enum category;
- closures, captures, boxed variables and environment hops;
- optimizer-backed type contracts, bounded automatic inline candidates for
  typed expression functions/lambdas, eager and lazy pull iterators,
  non-escaping variadic stack views, and pooled async jobs;
- `foreach`, `switch`, namespaces and module initialization;
- explicit-value enums, struct construction and constant folding;
- call profiling/tracing;
- deterministic constant/data layout and canonicalized debug paths; and
- synchronized assembler coverage with 229 golden opcode vectors.

Generated-code optimization is synchronized as part of the same parity
contract: both backends use the same inline expansion budget with unconditional
callable fallback bodies, local representation flow for integers, floats,
booleans, strings, arrays, bytes and concrete structs, constant-loop lowering,
known-struct method devirtualization and inline expansion, two ABI-preserved
XMM register homes for proven hot primitive locals, constant integer strength
reduction, guarded specialization of fallible byte-buffer results, 16-byte
user-function alignment, loop-invariant container-base hoisting, proven bounds-check
elimination, GC-root/prologue sizing and short-back-edge selection. Stack sizing also
accounts for calls hidden inside eligible inline bodies, so an expanded wide
call cannot overwrite caller locals, debug saves or the root-frame record. The shared
`tests/codegen_optimizations.ml` and
`tests/language_performance_features.ml` fixtures cover optimized behavior and
fallback semantics, including a narrow caller around a hidden ten-argument call. Listing
checks additionally verify float/bool/struct fast paths, specialized array and
bytes indexing, invariant hoists, eliminated in-range loop checks, retained
negative-index normalization, all inline fallback bodies and both the small and
expanded loop/root forms. Structural listing checks also assert direct known
method targets, removal of the polymorphic method cache in those paths,
XMM-backed hot-local loads, ABI save/restore across a promoted user-function
call and the absence of division/multiply/CL setup for the covered constant
integer cases.

Canonical object batches also carry the cumulative inline byte budget and call
accounting and the cumulative text offset for function alignment from one
fragment to the next. Local `fn_ret_*` and `fn_defer_*`
control-flow labels are excluded from runtime-helper discovery. The shared
optimization fixture crosses multiple object batches to guard this state.

The self-hosted compiler additionally retains `.mlo` production/linking,
`--object-pipeline`, assembly/PE/data listings and its direct encoder helpers.

## Self-host performance work

The MiniLang implementation was optimized without changing target bytes. The
main changes are native string/bytes hashing for compiler-internal fast maps,
paged byte/array builders, chunked/indexed `.rdata` and `.data` label tables,
chunked section-relocation records, direct 32/64-bit assembler emission,
pre-sized label maps and generational text-fixup resolution. Each bounded phase
scans only newly emitted patches; unresolved forward references are revisited
once after helper emission instead of after every function batch. The parsed
AST and active codegen graph are explicit roots through function emission and
are released before the support-helper tail. The compiler's internal periodic
GC limit is 3 GiB for large canonical builds and remains independent of the
target's `--gc-limit`. These are implementation details of the
self-hosted compiler, not additions to the language-level compatibility
contract.

The append optimization pass additionally replaces the growing
function, global, scope and local arrays with geometrically growing internal
vectors and builds the per-module function index once. The canonical object
writer isolates short-lived function-analysis batches while advancing shared,
append-only read-only/data/BSS builders and constant pools. Fragment boundaries
therefore cannot alter data order or deduplication, and prior section state is
never copied merely to append the next delta.
`--profile-compiler` exposes phase timings without affecting generated target
bytes.

The large-label throughput pass removes two remaining sources of avoidable
work. Codegen assemblers no longer retain the complete call-site list when
only runtime-helper discovery is needed, and helper uniqueness is maintained
by the existing fast map. For monolithic programs above 262,144 text labels,
relocation now consults the assembler's text-label map directly and builds a
small override map only for `.rdata`, `.data`, BSS and IAT labels. Label dumps
still select the historical fully materialized map and ordering. The `.mlo`
linker also preallocates its per-object patch-index arrays instead of repeatedly
copying growing arrays. None of these changes alter instruction selection,
section layout or relocation precedence.

On the compiler source graph used for profiling, the old fixed-point compiler
spent 805.000 seconds emitting the program and 700.828 seconds resolving
labels and patches, for 1,510.172 seconds total. The optimized compiler took
618.063 seconds for emission and 1.844 seconds for 1,007,242 deferred patches,
for 623.735 seconds total: 58.7% less wall time overall and 99.7% less time in
the former relocation bottleneck. Observed peak working set fell from about
3,286 MiB to 3,168 MiB.

On the same compiler source and heap flags, an instrumented object-pipeline
self-build improved from 336.073 seconds (286.172 seconds object emission) to
218.330 seconds (166.438 seconds object emission), a 35.0% total and 41.8%
object-emission reduction. A consecutive second self-build took 230.850
seconds; both 52,948,992-byte compiler images were byte-identical with SHA-256
`0325E633D03B2BBAACBEB47F503CB0E774580D3F9CB0F5F6E7047FD64387F9B3`.

After the earlier GC-root parity synchronization, that source revision was
validated through two consecutive self-host stages. They completed in
162.501 and 208.573 seconds and produced identical 53,514,752-byte compiler
images with SHA-256
`1C15CC446E1A15C16CE84938B6961A287245750FD4072501313409BEFC5E9F05`.

With the type-flow, invariant-hoisting and bounds-check pass included, the last
pre-canonical two stages took 181.644 and 470.513 seconds, emitted 301 objects each
and were byte-identical at 54,650,368 bytes with SHA-256
`C6365921E6112AEEEA7F32DFF9E846A1AD358448582C72A6579EFAB6F67E4B00`.

With method devirtualization, hot primitive register homes and integer strength
reduction included, consecutive self-host stages completed in 160.022 and
128.441 seconds. They produced byte-identical 56,409,600-byte compiler images
with SHA-256
`DB0DB8DB532F340DC4A126D4C64EC8E8D5AF7F1D3412F2DFA5155339F8FA07DB`.

## Tests

Historical acceptance snapshot for the feature set described above (newer
results are recorded in the dated sections below):

```text
Python harness:    PASS 129, FAIL 0, SKIP 0
MiniLang harness:  PASS 125, FAIL 0
ML opcode smoke:   synchronized golden vectors and direct encoder passed
Outer ML gates:    CRC/SIMD/platform crypto/shared values, ABI, PE/ELF and Linux passed
```

The 2026-08-25 conditional-compilation bootstrap produced byte-identical
57,467,904-byte Stage 2 and Stage 3 compiler images with SHA-256
`F0300E7F1C542204974018DF56E97155EC0BDE6BF43E32DB927BEB9139280209`.
The shared nested-directive fixture compiled to identical Python, self-hosted
monolithic and `.mlo` target bytes.

The 2026-08-25 cross-platform platform-services acceptance covered the
byte-identical 41-module `std/` trees plus `stdlib_unit_tests`,
`threading_stdlib`, platform crypto, shared-value snapshots and the new durable
I/O/process/console/network/TLS-contract suite. Every program compiled and ran
on Windows x64 and Linux x64 with both compilers. The final platform-services
outputs were byte-identical between Python and Stage 3: the 2,022,912-byte PE
had SHA-256
`6D33E1751CF76C2DAE6932D09521FE06922CFBE911E106D60CF182CC51C2C3F5`;
the 1,857,872-byte ELF had SHA-256
`0F8257F85485D3FA1745845A8897E2E74620BC9C1CF29EE4231EB009A8F9ADD5`.
The complete Python harness remained at PASS 108/FAIL 0/SKIP 0, and the
complete self-hosted outer harness passed all Windows, Linux, `.mlo`, ABI and
runtime gates.

A fresh bootstrap after the platform-services work converged at Stage 2.
Stage 2 and Stage 3 were byte-identical 58,567,680-byte compiler images with
SHA-256
`6D209F144E38C99168976AD566B5EF40E096AF331E9F32623F3BB779486DBCF3`.
The resulting Stage 3 compiler emitted the Windows and Linux acceptance hashes
above, and both outputs ran successfully on their native targets.

Explicit target-GC settings are also cross-compiler identical. With
`--gc-limit 96m`, both compilers emitted the same 2,022,912-byte PE with
SHA-256 `CDB05600CC1B8BDF266B6D0FAD87C32FC60ADBD29D1567D8AB9AD63D4E03155E`.
With `--no-gc-periodic`, both emitted the same 1,857,872-byte ELF with SHA-256
`4659174CCB340B0DC6F2D6425C4751C96AD9C711B0224AFA68F183E5C6958EB5`.

The 2026-08-24 MiniQuake check used clean commit
`7e8d0f614f7ad33f423e88873c210b7f846bbced`. Python compiled the 142-source
target in 66.368 seconds and the self-hosted monolithic compiler in 932.680
seconds. Both produced the same 57,156,608-byte PE with SHA-256
`A2E36E0A572B394FCE4A531AED4C3574E4D21A83E0F9761238DA72A0B2200923`.
Both the previous and optimized PE passed a 120-frame retail E1M1 headless
smoke. In an alternating two-run A/B check with 300 warm-up and 10,000 measured
frames per run, average measured frame time fell from 12,665.0 to 12,262.5 ms,
approximately 790 to 815 frames/s (+3.3%). Individual runs varied, so this is a
local performance check rather than a release-grade statistical claim.

The 1.1.0 MiniQuake acceptance input was a frozen 142-file source snapshot from
commit `1036b1c3b551d00de777c67293d262a6cc5c2739` plus 18 dirty worktree
entries. Its source-tree SHA-256 was
`9EE5DD4ACC9DAAC7D6A810DA497D7DA385A80D2934A4EE2EC2DE0D897A44B285`.
Python compiled it in 67.528 seconds, the self-hosted monolithic path in
2,024.375 seconds and the canonical `.mlo` pipeline in 431.789 seconds. The
`.mlo` path is 4.69 times faster than the self-hosted monolith; Python remains
6.39 times faster than `.mlo` on this input.

All three outputs are byte-identical 57,005,568-byte PE files with SHA-256
`3071B78B6F2C72B8C3036E5D62010831758F6EA3E7FFA3F6AF908BB9756003B3`.
The `.mlo` run emitted 494 function fragments in 361.500 seconds, runtime
helpers in 3.781 seconds and completed its fresh-process link in 42.375
seconds. Retail Quake `id1` data passed a 120-frame runtime smoke and a
120-frame deterministic compatibility trace with rolling hash `74dc3dc9`.
The same target completed 1,000 E1M1 headless frames in 712 ms and 1,000
rendered frames in 5,995 ms, approximately 1,404.5 frames/s and 166.8 FPS.

The final 27 August 2026 large-project check used the clean MiniQuake commit
`b5fe23f17bd5e861f22afd72b2e83aa4b73b9bd5`. Python compiled it in 67.713
seconds, the self-hosted monolithic path in 1,687.367 seconds and the `.mlo`
path in 537.440 seconds. The object path was 3.14 times faster than the
self-hosted monolith; Python remained 7.94 times faster than `.mlo` on this
input. All three emitted the same 57,197,056-byte PE with SHA-256
`8E5D38689481FC7D0FC6CACD6FFD015EEBA3C2B875A9B19E0CC790A142970E63`, and
the self-hosted output passed the MiniQuake `--version` startup smoke.

The throughput-optimized remeasurement on the same clean commit used the same
source/include roots and heap/diagnostic flags. Python completed in 77.757
seconds, the self-hosted monolith in 874.519 seconds and `.mlo` in 351.937
seconds. Relative to the immediately preceding self-host figures above, that
is a 48.2% monolithic reduction and a 34.5% object-pipeline reduction; `.mlo`
is now 2.48 times faster than the optimized monolith. The monolithic profile
reported 1,234,125 text labels and 926,660 deferred patches: program emission
took 867.750 seconds while direct relocation took only 3.203 seconds. The
`.mlo` path emitted 495 function objects in 278.468 seconds and linked 497
objects in a fresh process in 54.875 seconds. All three outputs remained
byte-identical at 57,197,056 bytes with the same SHA-256 above, and all three
passed the MiniQuake `--version` startup smoke.

The resulting optimizer bootstrap converged at Stage 2. Stage 2 and Stage 3
completed in 357.656 and 258.750 seconds and are byte-identical 59,923,456-byte
compiler images with SHA-256
`FB6D921349BBE248A88726910CE72396651B2372179ADC36D7913FC7240ECF3D`.

The 2026-08-25 native-TLS acceptance exercised real localhost client/server
handshakes through Windows Schannel and Linux OpenSSL 3, including fail-closed
wrong-hostname cases. An initial comparison exposed three bounded Schannel ABI
buffer scans that the self-hosted optimizer unrolled while the Python optimizer
kept as loops. Expressing those scans as explicit `while` loops restored target
parity and avoided about 50 KiB of duplicated Windows code. The final Python
and self-hosted outputs are byte-identical:

- Windows server: 2,379,776 bytes, SHA-256
  `B6970220CFB4D2AC9B4E273F48E1D7E70482B33AE0C4164D9C1E857F29DEEFC6`
- Windows client: 2,378,752 bytes, SHA-256
  `AA9AA57E10DF3BFE33F5CF72D79997DF204C402B927FA7687D76550206907DCC`
- Linux server: 735,216 bytes, SHA-256
  `C86900C35931D38054F478C1CB77E72124ECFD872C04084A1D3F7FC69D6FB737`
- Linux client: 1,200,288 bytes, SHA-256
  `531D7D6880CAF897C8F493E5F1D22EDB41C09B40CA3F99529654E85934320EF2`

The final allocator-parity synchronization makes heap growth precede the one
emergency full collection at the reserved ceiling. Consecutive self-hosted
Stages 5 and 6 are byte-identical 58,552,832-byte compiler images with SHA-256
`082DD04118450A4FE2F3D746FF4D1FA96B9146279353F7CB8FFA5360149F7C4B`.
The four TLS artifacts above were rebuilt with this fixed-point compiler and
remain byte-identical to the corresponding current Python compiler outputs.

The counters differ because the Python runner counts host-side tests
individually while the MiniLang harness groups several checks into compiled
programs.

## Large-object linker fast path

The 28 August 2026 linker acceptance reused one retained canonical 497-object
MiniQuake directory for every A/B run, excluding object generation from the
measurement. The preceding self-hosted compiler linked it in 58.891 seconds:
44.407 seconds built label indexes and 12.281 seconds applied relocations. The
optimized linker completed repeat runs in 18.922 and 21.579 seconds. Label
indexing took 8.469-9.047 seconds and relocation application took
8.219-9.407 seconds, a total reduction of 63.4-67.9%.

Every run emitted the same 57,197,056-byte PE with SHA-256
`8E5D38689481FC7D0FC6CACD6FFD015EEBA3C2B875A9B19E0CC790A142970E63`.
A second retained 656-object layout with 1,203,475 private and 185,700 public
labels also linked successfully and remained byte-identical to its baseline
57,456,128-byte image with SHA-256
`F6619A60E7A25DC6497AEFB6173E2F9640CF942362D460FF3CA318BB9656E0C9`.
The MiniLang harness reports 106 passed and 0 failed; host-side gates also
cover Windows/Linux object parity and standalone retained-directory relinking.

The optimized source was then bootstrapped once with Python and compiled twice
through its own object pipeline. Self-hosted Stage 2 and Stage 3 completed in
231.251 and 227.517 seconds and are byte-identical 59,981,824-byte compiler
images with SHA-256
`86447CBFB07AF960EA970E3770927F5F6D0C780E61730303B194883F634E21DB`.
The Python-bootstrap Stage 1 has the same size but a distinct compiler-image
hash; target-output parity and the Stage 2/3 fixed point both hold.

## Object emission and cache follow-up

The 29 August 2026 follow-up addressed four self-host bottlenecks without
changing target semantics or the MLO1 format:

- object integers are serialized directly into paged byte storage instead of
  allocating one temporary four-byte object per field;
- the remaining large nested-statement scans use capacity-backed worklists and
  the hot-path guard rejects copying `stack = stack + children` regressions;
- project builds retain a deterministic per-fingerprint MLO set beneath the
  final-executable cache, validate its published sorted file manifest and can
  relink it when the final artifact is missing;
- a background MLO-writer prototype was evaluated and removed. A compiler
  self-build exceeded six minutes and about 3.6 GiB working set because the
  extra managed heap and GC coordination outweighed serialization overlap.

The same-source MiniQuake A/B used clean commit
`59ac8cfc6c447c82b207100741512359f95e595c`, the same include roots, heap
settings and automatic object-pipeline selection in both runs:

| Build | Wall/profile time | Change |
| --- | ---: | ---: |
| preceding self-hosted fixed-point compiler | 419.078 s | baseline |
| final optimized fixed-point compiler | 388.859 s | -30.219 s (-7.21%) |
| retained 497-object relink | 18.672 s | -95.20% vs full optimized build |

The final full build spent 12.237 seconds in batch setup, 282.524 seconds in
function code generation and 40.473 seconds in object serialization. The
retained-object path was 20.83 times faster than the full optimized build and
emitted the exact same image.

The old self-host, final self-host, Python compiler and retained-object relink
all produced one byte-identical 57,197,056-byte PE with SHA-256
`9AF2B206162B7BD2E632379CA4F6D2598FDD390F8177EDA801668B9EA35C66C8`.
The final and Python images both passed the MiniQuake `--version` startup
smoke. Because their complete executable bytes match, this compiler-only work
cannot introduce a generated-code runtime-performance difference.

Three full builds of the final compiler source took 204.969, 213.574 and
190.267 seconds (median 204.969 seconds). The single preceding-source baseline
was 194.437 seconds, so the nominal median is 5.42% higher; that comparison also
includes the newly added cache implementation and falls inside the observed
self-build spread, so it is not treated as a throughput win. Correctness is
stronger: consecutive final Stages 4, 5 and 6 are byte-identical 60,135,936-byte
compiler images with SHA-256
`A7CC35492AC4E2A0F470EEB683AC5DC5DF6B7C192A14365B52252E6430322B70`.

The complete final-compiler acceptance run finished in 70.698 seconds. The
MiniLang harness reported 107 passed and 0 failed, while all Windows and WSL
Linux host gates passed, including monolithic/object byte identity, standalone
retained-directory relinking, GC, threads, SIMD, standard-library and project
cache coverage. The project test explicitly removes both executable copies and
successfully restores the result through an `object cache hit` relink.

## Allocation-free analysis and direct paged writers

The 29 August 2026 follow-up removed the remaining temporary child-array path
from nested-statement analysis. Parser fields are flattened once into a
capacity-backed vector, and the read-order scan consumes either that vector or
an ordinary array without repeated concatenation or one recursive call per
field. The static hot-path gate now rejects the obsolete allocating helper.

The paged writer now supports direct little-endian U16, U32 and U64 values.
MLO serialization uses its U32 path and copies UTF-8 string payloads straight
from native text storage across page boundaries instead of first materializing
a bytes value. Boundary tests cover all widths and a multibyte string crossing
the 64 KiB page edge. `--profile-compiler-batches` adds diagnostic-only setup, codegen,
serialization and total times per function batch, including its module/type
prefix.

Two consecutive self-hosted builds of the final source completed in 202.187
and 188.948 seconds and produced byte-identical 60,238,848-byte compiler images
with SHA-256
`C68FF1E7487A2F47513DA2508D839A46F9352D46A34FB7F456CBE97ACF4E75BB`.
The first run used the preceding compiler generation; the second used the new
compiler, a 6.55% reduction on the same final source. A Python bootstrap took
74.759 seconds, and its native Stage 2 converged to the identical fixed-point
image in 185.547 seconds.

The same-source MiniQuake A/B used identical include roots and release heap
arguments. The Python compiler completed in 71.915 seconds and the final
self-hosted compiler in 360.959 seconds. The latter is 7.18% faster than the
previous documented 388.859-second self-host baseline. Both emitted the same
57,197,056-byte PE with SHA-256
`9AF2B206162B7BD2E632379CA4F6D2598FDD390F8177EDA801668B9EA35C66C8`;
both `--version` startup smokes passed. Complete byte identity also proves that
runtime performance of the two generated MiniQuake executables is identical.

The final acceptance run finished in 81.720 seconds. The MiniLang harness
reported 107 passed and 0 failed, and all Windows and WSL Linux host gates
passed, including monolithic/object byte identity, retained-object relinking,
GC, threads, SIMD and standard-library coverage.

## Shared function-flow collection

Profiling the fixed-point compiler on 29 August 2026 showed that MiniQuake's
495 function-object batches still spent most of their time in code generation.
Integer inference, value-type inference and local-register promotion each
walked the same function statements to collect overlapping facts. The compiler
now collects their immutable inputs in one deterministic traversal while the
three consumers retain their existing inference and selection rules.

The directly comparable cold profiled MiniQuake build improved from 352.740 to
286.077 seconds, a reduction of 66.663 seconds (18.90%). Function-batch codegen
fell from 261.878 to 211.235 seconds, serialization from 35.606 to 29.591
seconds, and object-pipeline planning from 20.844 to 9.468 seconds. Both builds
used the same source tree, include roots, release heap settings and diagnostic
batch profiling.

The final self-hosted Stage 3 compiled the same final compiler source in
149.766 seconds, down from the preceding fixed-point compiler's 188.948 seconds
(20.74%). Consecutive Stages 2 and 3 are byte-identical 60,258,304-byte images
with SHA-256
`6189DCD8D470E7970D3ECAE11580640024E757BE66346C63F45FEE682B04BBC1`.

The optimized self-host and Python compiler emitted the same 57,197,056-byte
MiniQuake PE with SHA-256
`9AF2B206162B7BD2E632379CA4F6D2598FDD390F8177EDA801668B9EA35C66C8`.
Its `--version` startup smoke passed. The complete final-compiler acceptance run
reported 107 passed and 0 failed in 64.142 seconds internally (64.731 seconds
including the PowerShell harness), with every Windows and WSL/Linux host gate
green.

## Indexed emission facts

The next 29 August 2026 pass kept the already-converged integer-flow and
value-type inference tables in their compact hash-index representation through
function emission. The previous path materialized ordered arrays after analysis
and then linearly searched them for every relevant variable expression. Legacy
array lookup remains accepted for bootstrap compatibility, but current compiler
stages use exact-name O(1) lookup and avoid the conversion allocation.

Consecutive final Stages 2 and 3 completed in 126.449 and 126.951 seconds and
produced byte-identical 60,251,648-byte compiler images with SHA-256
`F3A0C48208DCE5446F815A5039ADA3609A20ED8A71EF44D84A6B93C676E42B5B`.
Using the stable Stage 3 comparison, this is 15.23% faster than the preceding
149.766-second fixed point and 32.81% faster than the 188.948-second compiler
before shared flow collection.

The directly comparable cold profiled MiniQuake build improved from 286.077 to
244.399 seconds (14.57%). Function-batch codegen fell from 211.235 to 177.229
seconds (16.10%); all 495 canonical function batches were emitted. Relative to
the 352.740-second baseline before both flow optimizations, the cumulative
MiniQuake reduction is 30.72%.

The resulting MiniQuake executable is byte-identical to both the preceding
self-host image and the Python compiler output: 57,197,056 bytes with SHA-256
`9AF2B206162B7BD2E632379CA4F6D2598FDD390F8177EDA801668B9EA35C66C8`.
Its `--version` startup smoke passed. The full acceptance run reported 107
passed and 0 failed in 63.517 seconds internally (64.084 seconds including the
PowerShell wrapper), with all Windows and WSL/Linux host gates green.

A direct parser-struct-id expression-dispatch prototype was also measured. Its
extra type checks and inlined dispatch expansion increased the compiler build
to 309.264 seconds, so it was removed completely; no unmeasured numeric-tag
path remains in the final source.

## Local MLO relocations and label pruning

The next serial object-pipeline pass introduced MLO version 2. A text patch
whose target is already defined in its source fragment now stores the target's
U32 text offset instead of its label string. Cross-object and cross-section
targets remain named. Only externally reachable text labels are serialized in
normal builds; `--dump-labels` keeps the complete diagnostic label surface.
The `MLO1` family magic remains stable, and all object readers accept both
versions 1 and 2 so retained v1 caches can still be linked.

The comparison used exactly the same current compiler source and 296 canonical
objects. The preceding fixed-point compiler emitted v1; the new fixed-point
compiler emitted v2. Both sets linked to the same 60,421,120-byte executable:

`933BB2B5EB1C1285860CC22DF4ADB99DB7FB62897760080BB446A95FF6143032`

| Metric | MLO v1 | MLO v2 | Change |
| --- | ---: | ---: | ---: |
| Retained object bytes | 223,663,521 | 158,547,517 | -29.11% |
| Retained object size | 213.30 MiB | 151.20 MiB | -29.11% |
| Mean of two alternating relinks | 22.370 s | 5.808 s | -74.04% |
| Sampled linker peak working set | 1,471.0 MiB | 835.5 MiB | -43.20% |

The v1 relinks measured 22.598 and 22.142 seconds; v2 measured 5.805 and
5.811 seconds with the same final compiler and alternating run order. The new
linker also relinked the previous 1,231,724-label v1 compiler object directory
to its original SHA-256 exactly, directly exercising backward compatibility.

Consecutive v2 Stages 2 and 3 are byte-identical at the size and hash above.
The complete acceptance run reported 107 passed and 0 failed; all Windows and
WSL/Linux gates passed, including object/monolithic identity and retained v2
relinking. Direct Python/self-host comparisons remained byte-identical for the
Windows language suite
(`8E1571FD5077ACF0F978B493A56A900F708BD50CDBB8F01D22BB4C77A8F50E08`),
the optimization suite
(`C75143B7183C03578E6C63BC58A8E0DB1336062F25DE913D6707BDB5A2307F0C`)
and Linux target smoke
(`731030F6885FFA88149A2D908E505C9D571EDFFC54B1979ECEE800DE581F4489`).

## Direct local MLO relocation folding

The subsequent writer pass resolves same-fragment x64 `rel32` and `rip32`
fields directly in the once-materialized text buffer. These local relocations
are no longer serialized at all; only named cross-fragment and cross-section
patches reach the linker. The wire version remains MLO v2, and readers retain
support for both MLO v1 and numeric-target objects written by the earlier v2
compiler.

The acceptance comparison used the exact same current compiler source and 296
canonical objects. The preceding compiler wrote numeric-target v2 objects and
the new fixed-point compiler wrote folded v2 objects. Both linked to the same
60,443,136-byte executable with SHA-256:

`101C11E9E17D19A58A01C8EABF5E6B4CB7971DC28FB3A66472C12BF8642D6A25`

| Metric | Numeric MLO v2 | Folded MLO v2 | Change |
| --- | ---: | ---: | ---: |
| Retained object bytes | 158,603,878 | 107,016,076 | -32.53% |
| Retained object size | 151.26 MiB | 102.06 MiB | -32.53% |
| Mean of three alternating relinks | 5.753 s | 2.617 s | -54.52% |
| Mean sampled peak working set | 875.5 MiB | 481.4 MiB | -45.01% |

The numeric runs measured 6.32, 5.51 and 5.43 seconds; folded runs measured
2.71, 2.54 and 2.60 seconds in alternating order. The new linker also relinked
retained v1 and earlier numeric-v2 compiler directories to their original
byte-identical executable, directly exercising both compatibility paths.

Folded Stages 2 and 3 are byte-identical at the size and hash above. The
complete MiniLang harness again reported 107 passed and 0 failed, all Windows
and WSL/Linux gates passed, and a targeted MLO structural test verifies that
new text patch tables contain no numeric same-fragment targets. Direct
Python/self-host checks remain byte-identical for the Windows language suite,
Windows optimizer suite and Linux target smoke at the hashes recorded above.

## Group-streamed MLO patch folding

The next writer pass removes the remaining full patch-array materialization.
After text is materialized once, the assembler exposes a shallow ordered view
of its fixed-size patch groups. Object emission walks each group directly,
writes locally resolved `rel32`/`rip32` displacements into the text bytes and
retains only unresolved cross-fragment/cross-section records. It therefore
avoids a per-patch indexed chunk lookup as well as the second managed array of
all local patch structs. The MLO v2 wire format is unchanged.

The preceding fixed-point compiler built the updated source with the flattened
writer in 163.599 seconds, including 21.296 seconds of object serialization and
a 3,316.6 MiB sampled peak. Two consecutive updated fixed-point emissions took
164.742 and 169.253 seconds; their serialization phases took 17.366 and 17.082
seconds, averaging 17.224 seconds (19.12% less), while both peaks were 3,286.5
MiB. Codegen/setup variation dominates the total elapsed time, so only the
isolated writer reduction is attributed to this change.

Stages 2 and 3 contain 297 individually byte-identical objects totaling
107,138,078 bytes (102.17 MiB). Both link to the same 60,513,792-byte compiler:

`6D73F77D48BDD66D38A85C55312D42C1A166563F3938CAEB5901D2A8C49F4391`

The MiniQuake comparison used the same clean sources, include roots, release
heap arguments and forced object pipeline. A direct old/new emission measured
243.201 versus 240.737 seconds and 3,165.2 versus 3,157.6 MiB. Two alternating
complete-build samples showed high per-phase variance; their serialization
means were effectively neutral (14.582 versus 14.739 seconds), so no
MiniQuake writer-speed claim is made. The overall build did not regress. Both
writers emitted the same 497 MLO files totaling 101,771,769 bytes and the same
57,197,056-byte PE:

`9AF2B206162B7BD2E632379CA4F6D2598FDD390F8177EDA801668B9EA35C66C8`

The full harness passed 107/107 plus every Windows and WSL/Linux host gate. The
new compiler relinked retained MLO v1 and numeric-target v2 directories to the
same bytes as the preceding linker. Direct Python, self-hosted monolithic and
self-hosted MLO comparisons were byte-identical for the Windows optimizer,
Linux static and Linux FFI fixtures.

## Reused serial function-fragment state

The following object-emission pass keeps one fully materialized semantic
codegen state alive throughout the serial function stream. Each new object
resets its assembler, helper/diagnostic lists and other batch-local stacks,
while cumulative labels, inline budgets, call accounting and append-only
sections remain in place. Lexical binding ids are explicitly restored from the
canonical prepared state at every batch boundary, matching the former
clone-per-batch behavior exactly. No extra collection or heap scan was added.

The controlled self-host comparison used the exact same final source and
forced object-emission path. Baseline runs took 190.734 and 152.531 seconds;
reused-state runs took 123.531 and 148.454 seconds. Their medians are 171.633
and 135.993 seconds respectively, a 20.77% reduction. Median batch setup fell
from 13.110 seconds to 0.070 seconds. A directly sampled private-memory peak
fell from 3,240.3 to 3,191.5 MiB, and the instrumented pre-link heap high-water
fell from the preceding 3,111.8 MiB baseline to 3,063.7 MiB (about 48.1 MiB).

Stages 1, 2 and 3 are byte-identical 60,527,104-byte executables with SHA-256:

`E22718A62809CEED3919E723467A43E756237DA6B184B24246FC114D38B83810`

All 297 Stage 1/2/3 MLO files are individually byte-identical. The complete
self-hosted harness passed 107/107 plus every Windows and WSL/Linux host gate.
The Python suite passed every compiler/codegen check; its one immediate UDP
bind failure after the host suite passed on the isolated two-test network
standard-library rerun.

The MiniQuake A/B used clean commit
`59ac8cfc6c447c82b207100741512359f95e595c`, identical include roots, release
heap arguments and a forced object pipeline. Baseline object runs took 242.016
and 237.203 seconds; reused-state runs took 215.422 and 215.531 seconds. The
median therefore fell from 239.610 to 215.477 seconds (10.07%), while median
batch setup fell from 8.268 to 0.071 seconds. The directly comparable sampled
working-set peak changed from 3,157.6 to 3,154.5 MiB. All 497 MLO files are
byte-identical and link to the same 57,197,056-byte PE with SHA-256:

`9AF2B206162B7BD2E632379CA4F6D2598FDD390F8177EDA801668B9EA35C66C8`

## Reusable analysis scratch and heap-shrink fixed point (2026-08-29)

The self-hosted serial function analyzer now reuses one compiler-local
workspace across function fragments. Statement/depth/pending vectors retain
their high-water capacity, while integer facts, type facts, dependencies,
queue membership and promotion counts use epoch-cleared maps. The workspace is
passed explicitly and rooted through the existing phase keepalive; it is not a
module global or a generated `CgState` field.

A controlled same-configuration self-build comparison measured medians of
130.483 seconds before and 110.108 seconds after the change (15.61% less).
Sampled process-tree private peak fell from 5,363.0 to 5,330.8 MiB (32.3 MiB,
0.60%), and sampled working-set peak fell from about 3,198.0 to 3,162.5 MiB.
A controlled MiniQuake build fell from 283.945 to 224.695 seconds (20.87%) and
retained the exact 57,197,056-byte PE with SHA-256
`9AF2B206162B7BD2E632379CA4F6D2598FDD390F8177EDA801668B9EA35C66C8`.

This pass also exposed a pre-existing optional-runtime discrepancy: Python
emitted the `--heap-shrink` post-GC decommit block, while the self-hosted
backend omitted it. After porting the block, the compact config reader's
missing integer was initially interpreted as zero; it now matches Python's
4 MiB default threshold. The final Python bootstrap and self-hosted Stages 2
and 3 are byte-identical 60,660,224-byte compiler images with SHA-256:

`344CE78BB6C03307A594FB4843642669083432AD2FF744772CE6086BA4A7629E`

The dedicated heap-shrink fixture is byte-identical across compilers on both
targets: Windows PE
`FB3F0FFDADD6BF0CFFEF5C31077A1F625E64DC813116DC2CAC21707FDC094B36`
and Linux ELF
`D391A8FEFB38FAD7A6F17EB6FF4960595B0BA2CC65D31F00BE999EF9A5410439`.
Both executables decommit unused pages without crossing the configured 16 MiB
minimum. The complete self-hosted harness passed 107/107 plus every Windows
and WSL/Linux host gate in 70.271 seconds; the Python suite passed 115/115.

## Adaptive object-emission memory bound (2026-08-30)

The serial object emitter uses a deterministic GC stride selected from the
prepared function count. Compiler-sized streams collect completed fragment
graphs every 32 batches. Streams above 2,048 functions retain the historical
64-batch cadence: MiniQuake peaks while its early semantic graph is still live,
so collecting twice as often did not reduce that peak materially and regressed
its build time. Windows and Linux compiler build scripts now commit 512 MiB
initially while retaining the same 8 GiB reserved address range and on-demand
growth.

On the same final compiler source and output configuration, adjacent sampled
process-tree runs measured:

| Self-host build | Wall time | Private peak | Working-set peak |
| --- | ---: | ---: | ---: |
| Previous 64-batch compiler | 145.527 s | 3,551.6 MiB | 3,179.8 MiB |
| Adaptive compiler | 133.109 s | 2,281.8 MiB | 1,928.8 MiB |
| Change | -8.53% | -35.75% | -39.34% |

The Python bootstrap and adaptive self-hosted fixed point are byte-identical
60,663,808-byte PE images with SHA-256:

`EFF138E771E6D2136D075E88863E6E3B0077481CEE6954A9794A0E48C931D370`

Clean MiniQuake commit `59ac8cfc6c447c82b207100741512359f95e595c`
selects the 64-batch path. Its adjacent A/B changed from 259.279 to 258.089
seconds and from 3,570.8 to 3,531.4 MiB private peak. Both compilers emitted
the same 57,197,056-byte PE with SHA-256:

`9AF2B206162B7BD2E632379CA4F6D2598FDD390F8177EDA801668B9EA35C66C8`

The complete self-hosted harness passed 107/107 plus all Windows and WSL/Linux
host gates in 80.255 seconds. The Python compiler suite passed 115/115.

## Compact compiler graph and packed symbol IDs (2026-08-30)

The self-hosted frontend and serial object emitter now reduce retained managed
references at five boundaries without changing the generated-code contract:

1. token payloads are packed U32 text/symbol IDs and repeated identifier,
   keyword and operator spellings are interned once per module;
2. canonical function roots live in a typed structure-of-arrays arena and are
   addressed by integer node IDs;
3. callable globals use a compact callable binding containing only fields read
   by call resolution and emission;
4. phase-local analysis maps track exactly the occupied reference slots and
   release those references after a serialized batch; and
5. serialized non-inline function roots release body and closure-analysis
   references immediately, while inline bodies remain live for later callers.

On the controlled full self-build, wall time improved from 111.922 to 105.422
seconds (5.81%). The internal post-user-function heap high-water fell from
1,735,693,608 to 1,659,852,560 bytes (75,841,048 bytes, 4.37%). A separate
process-tree sample recorded a 1,884,930,048-byte private peak (1.76 GiB) and a
1,780,158,464-byte working-set peak (1.66 GiB), roughly 15-16% below the
preceding approximately 2.09 GiB private-memory reference. Process sampling
distorts wall time, so the sampled run is used only for memory figures.

The Python-bootstrap Stage 1 and self-hosted Stages 2 and 3 are byte-identical:

| Compiler image | Bytes | SHA-256 |
| --- | ---: | --- |
| Stage 1, built by Python | 61,230,592 | `6512E5AD675018FF7244A455D7199A45FA81772367A48CF90E339DFA6B8ABCF2` |
| Stage 2, built by Stage 1 | 61,230,592 | `6512E5AD675018FF7244A455D7199A45FA81772367A48CF90E339DFA6B8ABCF2` |
| Stage 3, built by Stage 2 | 61,230,592 | `6512E5AD675018FF7244A455D7199A45FA81772367A48CF90E339DFA6B8ABCF2` |

Cross-compiler target checks remain byte-identical on both targets. The Windows
`codegen_optimizations.ml` image has SHA-256
`622B9E6F33ACCD73D0F4EF7F34B91A072D287B5E50B52B31D808055D99DD2B3F`;
the Linux `linux_target_smoke.ml` image has SHA-256
`73F7AD0753F8613A1A5E3162D5E0E2D07715A81BD1C1C970B93CA68176197459`.
The complete self-hosted harness passes 108/108, including explicit packed
token-column, repeated-symbol-ID and map-reference-release coverage. The
hot-path allocation guard and monolithic/object-pipeline identity gates pass.

## Reproducing target-output parity

From a workspace containing both repositories as siblings:

```powershell
cd MiniLangCompilerPy
python .\mlc_win64.py .\tests\language_suite.ml .\build\suite-py.exe -I .

cd ..\MiniLangCompilerML
.\build.ps1
.\build\mlc_win64.exe .\tests\language_suite.ml .\build\suite-ml.exe -I .

$pythonHash = (Get-FileHash ..\MiniLangCompilerPy\build\suite-py.exe -Algorithm SHA256).Hash
$miniLangHash = (Get-FileHash .\build\suite-ml.exe -Algorithm SHA256).Hash
.\build\mlc_win64.exe .\tests\language_suite.ml .\build\suite-mlo.exe -I . --object-pipeline
$objectHash = (Get-FileHash .\build\suite-mlo.exe -Algorithm SHA256).Hash
($pythonHash -eq $miniLangHash) -and ($miniLangHash -eq $objectHash)

cd ..\MiniLangCompilerPy
python .\mlc_win64.py .\tests\linux_ffi.ml .\build\ffi-py --target linux-x64 -I .
cd ..\MiniLangCompilerML
.\build\mlc_win64.exe .\tests\linux_ffi.ml .\build\ffi-ml --target linux-x64 -I .
(Get-FileHash ..\MiniLangCompilerPy\build\ffi-py -Algorithm SHA256).Hash -eq `
  (Get-FileHash .\build\ffi-ml -Algorithm SHA256).Hash
```

The final expression must be `True`. Equality is guaranteed only when source
contents, imported files, include-root order, compiler options and canonical
source names are equivalent.

## Host-boundary and review hardening (2026-08-30)

The general self-hosted compiler review fixed four host-boundary correctness
issues and two avoidable nonlinear frontend paths:

- Windows object/link subprocesses bypass `cmd.exe` and use `CreateProcessW`
  with Windows CRT quoting, preserving trailing backslashes, quotes and shell
  metacharacters exactly.
- Linux import and incremental-cache identities remain case-sensitive, so
  `Foo.ml`/`foo.ml` and `Cache`/`cache` cannot alias.
- A native Linux compiler applies executable mode to both monolithic and MLO
  ELF outputs.
- The project source collector uses indexed directory/file sets and a
  capacity-backed vector, while string escape decoding uses `StringBuilder`.
- The object emitter roots temporary/output paths and runtime configuration
  across its stride GC. Without that root frontier a plain large self-build
  failed immediately after object 127; diagnostic `--mem-probe` changed heap
  shape and accidentally hid the stale reference.

The fix was bootstrapped from Python and then rebuilt through the normal MLO
pipeline without `--mem-probe`. The compiler output is already a fixed point:

| Compiler image | Build path | Seconds | Bytes | SHA-256 |
| --- | --- | ---: | ---: | --- |
| Stage 1 | Python compiler | 64.037 | 62,086,144 | `A740265D2978D8262EA421D8719C836E5E7993A04AA0EC2ECE22563BD85A038E` |
| Stage 2 | Stage 1, MLO, no mem probe | 95.412 | 62,086,144 | `A740265D2978D8262EA421D8719C836E5E7993A04AA0EC2ECE22563BD85A038E` |

Python, self-hosted monolithic and self-hosted MLO target builds remain
byte-identical. `codegen_optimizations.ml` produces a 467,456-byte Windows PE
with SHA-256
`622B9E6F33ACCD73D0F4EF7F34B91A072D287B5E50B52B31D808055D99DD2B3F`;
`linux_target_smoke.ml` produces a 91,552-byte Linux ELF with SHA-256
`73F7AD0753F8613A1A5E3162D5E0E2D07715A81BD1C1C970B93CA68176197459`.
The complete self-hosted harness passes 111/111 plus all outer Windows/Linux,
FFI, GC, object-relocation and byte-identity gates. Native Linux-only tests
add executable-mode, case-sensitive-import and case-distinct-cache coverage.

## Synchronization and project-cache hardening (2026-09-01)

The cross-compiler audit closed a Linux semaphore handoff race, made all
portable millisecond timeouts reject values outside `0..2147483647`, and
hardened the self-hosted project walker against linked-directory recursion.
The standard-library trees are byte-identical (46/46 files), and both
compilers emit the same Linux threading test image with SHA-256
`6656188D58E0905494398EEA9F5F6ACCFDC7CD281D0F8ADE635A05ED69824683`.

The Python suite passes 132/132. The self-hosted wrapper passes its 126/126
inner tests plus every outer Windows/Linux, FFI, GC, SIMD, object-pipeline and
byte-identity gate in 152.314 seconds. A 20,000-handoff Linux semaphore stress
run completes without a lost or spurious release in 18.828 seconds.

Self-hosting remains a byte-for-byte fixed point:

| Compiler image | Build path | Seconds | Peak working set | Bytes | SHA-256 |
| --- | --- | ---: | ---: | ---: | --- |
| Stage 1 | Python compiler | 74.771 | not sampled | 66,446,848 | `7B364F4BD511119CC5CA421449EAD9B80C9F7C647F83B7A581C208E90C8EE15A` |
| Stage 2 | Stage 1 | 148.891 | not sampled | 66,446,848 | `7B364F4BD511119CC5CA421449EAD9B80C9F7C647F83B7A581C208E90C8EE15A` |
| Stage 3 | Stage 2 | 147.133 | 881.7 MiB | 66,446,848 | `7B364F4BD511119CC5CA421449EAD9B80C9F7C647F83B7A581C208E90C8EE15A` |

The self-hosted MLO cache now reuses one 1 MiB hashing buffer. On a 49-object
restore benchmark, measured in-loop heap growth falls from 61,981,440 to
10,600,432 bytes, saving 51,381,008 bytes of transient allocation per pass.
