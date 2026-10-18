# Package `mlc.packing`

[Home](README.md) · [Packages](Packages.md)

## Files

- [mlc/packing.ml](File-mlc-packing-ml-1689146092.md)

## Symbols

- [`mlc.packing._memcmp`](File-mlc-packing-ml-1689146092.md#extern_function-extern-function-mlc-packing-memcmp-extern-function-memcmp-left-as-ptr-right-as-ptr-count-as-u64-from-msvcrt-dll-symbol-memcmp-returns-i32-mlc-packing-ml-1830735743) — extern_function
- [`mlc.packing._mkdir`](File-mlc-packing-ml-1689146092.md#extern_function-extern-function-mlc-packing-mkdir-extern-function-mkdir-path-as-wstr-security-as-ptr-from-kernel32-dll-symbol-createdirectoryw-returns-bool-mlc-packing-ml-1008703363) — extern_function
- [`mlc.packing._move`](File-mlc-packing-ml-1689146092.md#extern_function-extern-function-mlc-packing-move-extern-function-move-source-as-wstr-destination-as-wstr-from-kernel32-dll-symbol-movefilew-returns-bool-mlc-packing-ml-438214367) — extern_function
- [`mlc.packing._replace`](File-mlc-packing-ml-1689146092.md#extern_function-extern-function-mlc-packing-replace-extern-function-replace-source-as-wstr-destination-as-wstr-flags-as-u32-from-kernel32-dll-symbol-movefileexw-returns-bool-mlc-packing-ml-1546605675) — extern_function
- [`mlc.packing._rmdir`](File-mlc-packing-ml-1689146092.md#extern_function-extern-function-mlc-packing-rmdir-extern-function-rmdir-path-as-wstr-from-kernel32-dll-symbol-removedirectoryw-returns-bool-mlc-packing-ml-482861645) — extern_function
- [`mlc.packing.BLOCK_SIZE`](File-mlc-packing-ml-1689146092.md#constant-constant-mlc-packing-block-size-const-block-size-4096-mlc-packing-ml-450465958) — constant
- [`mlc.packing.cleanup`](File-mlc-packing-ml-1689146092.md#function-function-mlc-packing-cleanup-function-cleanup-folder-mlc-packing-ml-1209133486) — function
- [`mlc.packing.IMAGE_LIMIT`](File-mlc-packing-ml-1689146092.md#constant-constant-mlc-packing-image-limit-const-image-limit-1073741824-mlc-packing-ml-107107674) — constant
- [`mlc.packing.makeOverlay`](File-mlc-packing-ml-1689146092.md#function-function-mlc-packing-makeoverlay-function-makeoverlay-original-packed-restored-mlc-packing-ml-446939783) — function
- [`mlc.packing.META_LIMIT`](File-mlc-packing-ml-1689146092.md#constant-constant-mlc-packing-meta-limit-const-meta-limit-16777216-mlc-packing-ml-596282758) — constant
- [`mlc.packing.Options`](Type-mlc-packing-options-1916277472.md) — struct
- [`mlc.packing.parseOptions`](File-mlc-packing-ml-1689146092.md#function-function-mlc-packing-parseoptions-function-parseoptions-args-mlc-packing-ml-2049723595) — function
- [`mlc.packing.parseOverlay`](File-mlc-packing-ml-1689146092.md#function-function-mlc-packing-parseoverlay-function-parseoverlay-image-mlc-packing-ml-1994926891) — function
- [`mlc.packing.readImage`](File-mlc-packing-ml-1689146092.md#function-function-mlc-packing-readimage-function-readimage-path-mlc-packing-ml-187032787) — function
- [`mlc.packing.restoreImage`](File-mlc-packing-ml-1689146092.md#function-function-mlc-packing-restoreimage-function-restoreimage-restored-info-mlc-packing-ml-8737460) — function
- [`mlc.packing.runTool`](File-mlc-packing-ml-1689146092.md#function-function-mlc-packing-runtool-function-runtool-upx-arguments-runner-mlc-packing-ml-1641203203) — function
- [`mlc.packing.stageDirectory`](File-mlc-packing-ml-1689146092.md#function-function-mlc-packing-stagedirectory-function-stagedirectory-destination-mlc-packing-ml-456493542) — function
- [`mlc.packing.transform`](File-mlc-packing-ml-1689146092.md#function-function-mlc-packing-transform-function-transform-source-destination-upx-unpack-replace-runner-mlc-packing-ml-1386066656) — function
- [`mlc.packing.u32at`](File-mlc-packing-ml-1689146092.md#function-function-mlc-packing-u32at-function-u32at-data-offset-mlc-packing-ml-1484204415) — function
