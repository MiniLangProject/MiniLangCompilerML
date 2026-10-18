# `mlc/packing.ml`

[Home](README.md) · [Files](Files.md)

Optional UPX packing with a deterministic, byte-exact restoration overlay.

Package: [`mlc.packing`](Package-mlc-packing-810428052.md)

Reachable from entry: **yes**

## Imports

- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)
- `std/checksum/crc32.ml` as `crc` → `std/checksum/crc32.ml` — external dependency
- `std/fs.ml` as `fs` → `std/fs.ml` — external dependency
- `std/process.ml` as `process` → `std/process.ml` — external dependency
- `std/string.ml` as `s` → `std/string.ml` — external dependency

## Declarations

<a id="extern_function-extern-function-mlc-packing-memcmp-extern-function-memcmp-left-as-ptr-right-as-ptr-count-as-u64-from-msvcrt-dll-symbol-memcmp-returns-i32-mlc-packing-ml-1830735743"></a>
### _memcmp

```ml
extern function _memcmp(left as ptr, right as ptr, count as u64) from "msvcrt.dll" symbol "memcmp" returns i32
```

Compare bounded blocks without allocating temporary byte slices.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `ptr` | — | First readable memory range. |
| `right` | `ptr` | — | Second readable memory range. |
| `count` | `u64` | — | Number of bytes available in both ranges. |


**Returns:** Zero for equal bytes, otherwise their comparison order.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/packing.ml#L66)

<a id="extern_function-extern-function-mlc-packing-mkdir-extern-function-mkdir-path-as-wstr-security-as-ptr-from-kernel32-dll-symbol-createdirectoryw-returns-bool-mlc-packing-ml-1008703363"></a>
### _mkdir

```ml
extern function _mkdir(path as wstr, security as ptr) from "kernel32.dll" symbol "CreateDirectoryW" returns bool
```

Reserve one exclusive staging directory beside the requested destination.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `wstr` | — | UTF-16 path to a new directory. |
| `security` | `ptr` | — | Optional Windows security attributes; zero uses defaults. |


**Returns:** True if the directory was created.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/packing.ml#L45)

<a id="extern_function-extern-function-mlc-packing-move-extern-function-move-source-as-wstr-destination-as-wstr-from-kernel32-dll-symbol-movefilew-returns-bool-mlc-packing-ml-438214367"></a>
### _move

```ml
extern function _move(source as wstr, destination as wstr) from "kernel32.dll" symbol "MoveFileW" returns bool
```

Atomically publish without replacing another file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `wstr` | — | UTF-16 staging-file path. |
| `destination` | `wstr` | — | UTF-16 destination that must not already exist. |


**Returns:** True if the move completed.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/packing.ml#L54)

<a id="extern_function-extern-function-mlc-packing-replace-extern-function-replace-source-as-wstr-destination-as-wstr-flags-as-u32-from-kernel32-dll-symbol-movefileexw-returns-bool-mlc-packing-ml-1546605675"></a>
### _replace

```ml
extern function _replace(source as wstr, destination as wstr, flags as u32) from "kernel32.dll" symbol "MoveFileExW" returns bool
```

Atomically replace a successfully compiled, explicitly packed output.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `wstr` | — | UTF-16 staging-file path. |
| `destination` | `wstr` | — | UTF-16 compiler-owned output path. |
| `flags` | `u32` | — | Windows move options permitting replacement. |


**Returns:** True if publication completed.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/packing.ml#L60)

<a id="extern_function-extern-function-mlc-packing-rmdir-extern-function-rmdir-path-as-wstr-from-kernel32-dll-symbol-removedirectoryw-returns-bool-mlc-packing-ml-482861645"></a>
### _rmdir

```ml
extern function _rmdir(path as wstr) from "kernel32.dll" symbol "RemoveDirectoryW" returns bool
```

Remove only an empty, exclusively owned staging directory.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `wstr` | — | UTF-16 path to an empty owned directory. |


**Returns:** True if the directory was removed.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/packing.ml#L49)

<a id="constant-constant-mlc-packing-block-size-const-block-size-4096-mlc-packing-ml-450465958"></a>
### BLOCK_SIZE

```ml
const BLOCK_SIZE = 4096
```


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/packing.ml#L28)

<a id="function-function-mlc-packing-cleanup-function-cleanup-folder-mlc-packing-ml-1209133486"></a>
### cleanup

```ml
function cleanup(folder)
```

Remove only four exact private files and their empty parent; no recursion.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `folder` | `dynamic` | — | Exclusively owned staging directory to remove if empty. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/packing.ml#L254)

<a id="constant-constant-mlc-packing-image-limit-const-image-limit-1073741824-mlc-packing-ml-107107674"></a>
### IMAGE_LIMIT

```ml
const IMAGE_LIMIT = 1073741824
```

Bound all executable buffers and restoration metadata before allocation.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/packing.ml#L26)

<a id="function-function-mlc-packing-makeoverlay-function-makeoverlay-original-packed-restored-mlc-packing-ml-446939783"></a>
### makeOverlay

```ml
function makeOverlay(original, packed, restored)
```

Store only original 4-KiB blocks normalized by UPX, plus whole-file CRCs. CRCs detect accidental corruption; they do not authenticate hostile files.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `original` | `dynamic` | — | Unmodified executable bytes before packing. |
| `packed` | `dynamic` | — | UPX-packed executable bytes before adding metadata. |
| `restored` | `dynamic` | — | UPX-unpacked bytes used to identify normalized blocks. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/packing.ml#L161)

<a id="constant-constant-mlc-packing-meta-limit-const-meta-limit-16777216-mlc-packing-ml-596282758"></a>
### META_LIMIT

```ml
const META_LIMIT = 16777216
```


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/packing.ml#L27)

- [mlc.packing.Options](Type-mlc-packing-options-1916277472.md) — struct
<a id="function-function-mlc-packing-parseoptions-function-parseoptions-args-mlc-packing-ml-2049723595"></a>
### parseOptions

```ml
function parseOptions(args)
```

Parse optional packing modes before normal compilation/project caching.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — | Original command-line argument vector without the executable name. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/packing.ml#L114)

<a id="function-function-mlc-packing-parseoverlay-function-parseoverlay-image-mlc-packing-ml-1994926891"></a>
### parseOverlay

```ml
function parseOverlay(image)
```

Validate lengths, checksums and all sorted non-overlapping restoration blocks before running UPX. Only trusted executables belong in this workflow.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `image` | `dynamic` | — | Packed executable bytes including the restoration footer. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/packing.ml#L186)

<a id="function-function-mlc-packing-readimage-function-readimage-path-mlc-packing-ml-187032787"></a>
### readImage

```ml
function readImage(path)
```

Read an image only after validating its on-disk size.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Existing executable file to read within the image-size limit. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/packing.ml#L150)

<a id="function-function-mlc-packing-restoreimage-function-restoreimage-restored-info-mlc-packing-ml-8737460"></a>
### restoreImage

```ml
function restoreImage(restored, info)
```

Restore original bytes, including header/import-table normalization by UPX.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `restored` | `dynamic` | — | Raw bytes produced by the UPX decompressor. |
| `info` | `dynamic` | — | Validated restoration metadata returned by the overlay parser. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/packing.ml#L227)

<a id="function-function-mlc-packing-runtool-function-runtool-upx-arguments-runner-mlc-packing-ml-1641203203"></a>
### runTool

```ml
function runTool(upx, arguments, runner)
```

Execute the trusted external packer with fixed, reproducible options.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `upx` | `dynamic` | — | Explicit trusted host-compatible UPX executable path. |
| `arguments` | `dynamic` | — | Fixed packing, testing or unpacking arguments. |
| `runner` | `dynamic` | — | Host command-execution callback supplied by the compiler driver. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/packing.ml#L266)

<a id="function-function-mlc-packing-stagedirectory-function-stagedirectory-destination-mlc-packing-ml-456493542"></a>
### stageDirectory

```ml
function stageDirectory(destination)
```

Create an exclusive sibling directory; never reuse another invocation's files.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `dynamic` | — | Output path whose parent will hold private staging files. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/packing.ml#L240)

<a id="function-function-mlc-packing-transform-function-transform-source-destination-upx-unpack-replace-runner-mlc-packing-ml-1386066656"></a>
### transform

```ml
function transform(source, destination, upx, unpack, replace, runner)
```

Stage, validate and atomically publish a packed/unpacked executable. Standalone mode never overwrites a destination, even on publication races.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Existing input executable path. |
| `destination` | `dynamic` | — | Requested output executable path. |
| `upx` | `dynamic` | — | Explicit trusted host-compatible UPX executable path. |
| `unpack` | `dynamic` | — | True to restore an image; false to pack it. |
| `replace` | `dynamic` | — | True only when compile mode may replace its own output. |
| `runner` | `dynamic` | — | Host command-execution callback supplied by the compiler driver. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/packing.ml#L280)

<a id="function-function-mlc-packing-u32at-function-u32at-data-offset-mlc-packing-ml-1484204415"></a>
### u32at

```ml
function u32at(data, offset)
```

Decode a previously bounds-checked little-endian u32 field.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Byte buffer whose field bounds have already been validated. |
| `offset` | `dynamic` | — | Zero-based byte offset of the four-byte field. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/packing.ml#L108)
