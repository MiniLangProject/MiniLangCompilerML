# `mlc/elf.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc elf package.

Package: [`mlc.elf`](Package-mlc-elf-485226986.md)

Reachable from entry: **yes**

## Imports

- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)

## Declarations

<a id="function-function-mlc-elf-array-has-function-array-has-values-wanted-mlc-elf-ml-1543624131"></a>
### _array_has

```ml
function _array_has(values, wanted)
```

Emit array has in the Linux ELF image.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |
| `wanted` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/elf.ml#L80)

<a id="function-function-mlc-elf-dynamic-blob-function-dynamic-blob-imports-image-base-data-off-blob-off-target-mlc-elf-ml-27897697"></a>
### _dynamic_blob

```ml
function _dynamic_blob(imports, image_base, data_off, blob_off, target)
```

Serialize PT_INTERP contents, SysV symbol/hash tables, RELA relocations and the DT_* vector as one deterministic data-segment blob. Import order remains significant because it is part of Python/self-hosted binary parity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `imports` | `dynamic` | — |  |
| `image_base` | `dynamic` | — |  |
| `data_off` | `dynamic` | — |  |
| `blob_off` | `dynamic` | — |  |
| `target` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/elf.ml#L108)

<a id="function-function-mlc-elf-pad-blob-function-pad-blob-blob-alignment-mlc-elf-ml-405074902"></a>
### _pad_blob

```ml
function _pad_blob(blob, alignment)
```

Extend a serialized metadata blob to the alignment required by ELF64 words.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `blob` | `dynamic` | — |  |
| `alignment` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/elf.ml#L100)

<a id="function-function-mlc-elf-ph-function-ph-kind-flags-off-filesz-memsz-base-alignment-mlc-elf-ml-1707200603"></a>
### _ph

```ml
function _ph(kind, flags, off, filesz, memsz, base, alignment)
```

Encode one ELF64 program header. File and virtual offsets intentionally use the same fixed-address layout so no section-header table is required.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — |  |
| `flags` | `dynamic` | — |  |
| `off` | `dynamic` | — |  |
| `filesz` | `dynamic` | — |  |
| `memsz` | `dynamic` | — |  |
| `base` | `dynamic` | — |  |
| `alignment` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/elf.ml#L209)

<a id="function-function-mlc-elf-string-offset-function-string-offset-offsets-wanted-mlc-elf-ml-1708932397"></a>
### _string_offset

```ml
function _string_offset(offsets, wanted)
```

Resolve one already-interned dynamic string without allocating a map for the normally small Linux import surface.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `offsets` | `dynamic` | — |  |
| `wanted` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/elf.ml#L90)

<a id="function-function-mlc-elf-build-function-build-text-rdata-data-bss-size-entry-offset-imports-mlc-elf-ml-1364924151"></a>
### build

```ml
function build(text, rdata, data, bss_size, entry_offset, imports)
```

Assemble a Linux ELF image using the compatibility entry point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Executable text bytes. |
| `rdata` | `dynamic` | — | Read-only data bytes. |
| `data` | `dynamic` | — | Initialized writable data bytes. |
| `bss_size` | `dynamic` | — | Uninitialized storage length. |
| `entry_offset` | `dynamic` | — | Entry offset within text. |
| `imports` | `dynamic` | — | Native symbols to import. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/elf.ml#L280)

<a id="function-function-mlc-elf-build-for-target-function-build-for-target-text-rdata-data-bss-size-entry-offset-imports-target-mlc-elf-ml-1002357110"></a>
### build_for_target

```ml
function build_for_target(text, rdata, data, bss_size, entry_offset, imports, target)
```

Assemble a minimal deterministic ET_EXEC image with RX text, read-only data, RW initialized/BSS storage and optional dynamic-loader metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — | Text to process. |
| `rdata` | `dynamic` | — | Value supplied for `rdata`. |
| `data` | `dynamic` | — | Data to process. |
| `bss_size` | `dynamic` | — | Value supplied for `bss_size`. |
| `entry_offset` | `dynamic` | — | Value supplied for `entry_offset`. |
| `imports` | `dynamic` | — | Value supplied for `imports`. |
| `target` | `dynamic` | — | ELF platform, linux-x64 or minux-x64. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/elf.ml#L222)

<a id="function-function-mlc-elf-dynamic-size-function-dynamic-size-imports-mlc-elf-ml-265787200"></a>
### dynamic_size

```ml
function dynamic_size(imports)
```

Measure dynamic-loader metadata for a Linux ELF image.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `imports` | `dynamic` | — | Native symbols to import. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/elf.ml#L270)

<a id="function-function-mlc-elf-dynamic-size-for-target-function-dynamic-size-for-target-imports-target-mlc-elf-ml-1490428907"></a>
### dynamic_size_for_target

```ml
function dynamic_size_for_target(imports, target)
```

Measure the exact metadata payload with the same serializer used by build().

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `imports` | `dynamic` | — | Value supplied for `imports`. |
| `target` | `dynamic` | — | ELF platform, linux-x64 or minux-x64. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/elf.ml#L202)

- [mlc.elf.DynamicBlob](Type-mlc-elf-dynamicblob-658310402.md) — struct
- [mlc.elf.ELFLayout](Type-mlc-elf-elflayout-1439135715.md) — struct
<a id="function-function-mlc-elf-plan-function-plan-text-size-rdata-size-data-size-dynamic-size-mlc-elf-ml-825164840"></a>
### plan

```ml
function plan(text_size, rdata_size, data_size, dynamic_size)
```

Lay out a Linux ELF image using the compatibility entry point.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text_size` | `dynamic` | — | Length of executable text. |
| `rdata_size` | `dynamic` | — | Length of read-only data. |
| `data_size` | `dynamic` | — | Length of initialized writable data. |
| `dynamic_size` | `dynamic` | — | Length of dynamic-loader metadata. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/elf.ml#L265)

<a id="function-function-mlc-elf-plan-for-target-function-plan-for-target-text-size-rdata-size-data-size-dynamic-size-target-mlc-elf-ml-513833887"></a>
### plan_for_target

```ml
function plan_for_target(text_size, rdata_size, data_size, dynamic_size, target)
```

Lay out page-aligned load segments and keep the dynamic table adjacent to initialized data. Offsets are RVAs relative to the fixed image base.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text_size` | `dynamic` | — | Value supplied for `text_size`. |
| `rdata_size` | `dynamic` | — | Value supplied for `rdata_size`. |
| `data_size` | `dynamic` | — | Value supplied for `data_size`. |
| `dynamic_size` | `dynamic` | — | Value supplied for `dynamic_size`. |
| `target` | `dynamic` | — | ELF platform, linux-x64 or minux-x64. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/elf.ml#L67)

- [mlc.elf.StringOffset](Type-mlc-elf-stringoffset-806023362.md) — struct
