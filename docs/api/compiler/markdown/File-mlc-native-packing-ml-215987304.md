# `mlc/native_packing.ml`

[Home](README.md) · [Files](Files.md)

Dependency-free packing for compiler-generated fixed-address PE and ELF.

Package: [`mlc.native_packing`](Package-mlc-native-packing-309385890.md)

Reachable from entry: **yes**

## Imports

- `mlc/pack_loader_bytes.ml` as `loaders` → [mlc/pack_loader_bytes.ml](File-mlc-pack-loader-bytes-ml-1442657874.md)
- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)
- `std/checksum/crc32.ml` as `crc` → `std/checksum/crc32.ml` — external dependency
- `std/compress/lz4.ml` as `lz4` → `std/compress/lz4.ml` — external dependency

## Declarations

<a id="function-function-mlc-native-packing-align-function-align-value-alignment-mlc-native-packing-ml-1597715110"></a>
### _align

```ml
function _align(value, alignment)
```

Align a positive file offset or virtual address to a power-of-two boundary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Offset or address to align. |
| `alignment` | `dynamic` | — | Required power-of-two alignment. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/native_packing.ml#L31)

<a id="function-function-mlc-native-packing-elf-rows-function-elf-rows-image-mlc-native-packing-ml-1930365519"></a>
### _elf_rows

```ml
function _elf_rows(image)
```

Read generated ELF64 program headers, including the dynamic loader records.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `image` | `dynamic` | — | Compiler-generated ELF image bytes. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/native_packing.ml#L253)

<a id="function-function-mlc-native-packing-fnv32-function-fnv32-data-mlc-native-packing-ml-1420346868"></a>
### _fnv32

```ml
function _fnv32(data)
```

Mirror the embedded loader's 32-bit FNV-1a payload check.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Compressed code bytes to hash. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/native_packing.ml#L103)

<a id="function-function-mlc-native-packing-pack-elf-function-pack-elf-original-mlc-native-packing-ml-55534729"></a>
### _pack_elf

```ml
function _pack_elf(original)
```

Keep original virtual addresses so all text/data references remain valid.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `original` | `dynamic` | — | Compiler-generated ELF image bytes. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/native_packing.ml#L269)

<a id="function-function-mlc-native-packing-pack-pe-function-pack-pe-original-mlc-native-packing-ml-1162043777"></a>
### _pack_pe

```ml
function _pack_pe(original)
```

Build a PE with unchanged original RVAs and a separate unpacking entry.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `original` | `dynamic` | — | Compiler-generated PE image bytes. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/native_packing.ml#L179)

<a id="function-function-mlc-native-packing-patch-loader-function-patch-loader-template-values-mlc-native-packing-ml-368903442"></a>
### _patch_loader

```ml
function _patch_loader(template, values)
```

Replace all eight-byte parameter markers in one checked-in loader image.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `template` | `dynamic` | — | Original loader bytes with placeholder markers. |
| `values` | `dynamic` | — | Addresses and lengths for the startup loader. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/native_packing.ml#L87)

<a id="function-function-mlc-native-packing-pe-file-offset-function-pe-file-offset-rows-rva-mlc-native-packing-ml-435006358"></a>
### _pe_file_offset

```ml
function _pe_file_offset(rows, rva)
```

Convert an original PE import RVA to its file offset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `dynamic` | — | Parsed PE section descriptions. |
| `rva` | `dynamic` | — | Virtual address relative to the image base. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/native_packing.ml#L134)

<a id="function-function-mlc-native-packing-pe-loader-imports-function-pe-loader-imports-image-pe-rows-mlc-native-packing-ml-1990242493"></a>
### _pe_loader_imports

```ml
function _pe_loader_imports(image, pe, rows)
```

Locate the loader's two existing kernel32 IAT slots by imported symbol.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `image` | `dynamic` | — | PE image bytes. |
| `pe` | `dynamic` | — | File offset of the PE header. |
| `rows` | `dynamic` | — | Parsed PE section descriptions. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/native_packing.ml#L147)

<a id="function-function-mlc-native-packing-pe-sections-function-pe-sections-image-mlc-native-packing-ml-380116091"></a>
### _pe_sections

```ml
function _pe_sections(image)
```

Enumerate the six fixed fields of each original PE section header.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `image` | `dynamic` | — | Compiler-generated PE image bytes. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/native_packing.ml#L113)

<a id="function-function-mlc-native-packing-set16-function-set16-data-offset-value-mlc-native-packing-ml-480924136"></a>
### _set16

```ml
function _set16(data, offset, value)
```

Overwrite fixed-size integer fields without growing the image buffer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Image byte array to update. |
| `offset` | `dynamic` | — | Start of the 16-bit field. |
| `value` | `dynamic` | — | Unsigned value to store. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/native_packing.ml#L60)

<a id="function-function-mlc-native-packing-set32-function-set32-data-offset-value-mlc-native-packing-ml-641855400"></a>
### _set32

```ml
function _set32(data, offset, value)
```

Store a little-endian 32-bit field in an existing image.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Image byte array to update. |
| `offset` | `dynamic` | — | Start of the field. |
| `value` | `dynamic` | — | Unsigned value to store. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/native_packing.ml#L70)

<a id="function-function-mlc-native-packing-set64-function-set64-data-offset-value-mlc-native-packing-ml-1178362336"></a>
### _set64

```ml
function _set64(data, offset, value)
```

Store a little-endian 64-bit field in an existing image.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Image byte array to update. |
| `offset` | `dynamic` | — | Start of the field. |
| `value` | `dynamic` | — | Unsigned value to store. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/native_packing.ml#L79)

<a id="function-function-mlc-native-packing-u16-function-u16-data-offset-mlc-native-packing-ml-1117809505"></a>
### _u16

```ml
function _u16(data, offset)
```

Read little-endian fields only after the caller has checked their bounds.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Source byte array. |
| `offset` | `dynamic` | — | Start of the 16-bit field. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/native_packing.ml#L38)

<a id="function-function-mlc-native-packing-u32-function-u32-data-offset-mlc-native-packing-ml-1008249225"></a>
### _u32

```ml
function _u32(data, offset)
```

Read a little-endian 32-bit field from a validated span.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Source byte array. |
| `offset` | `dynamic` | — | Start of the field. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/native_packing.ml#L45)

<a id="function-function-mlc-native-packing-u64-function-u64-data-offset-mlc-native-packing-ml-319186753"></a>
### _u64

```ml
function _u64(data, offset)
```

Read a little-endian 64-bit field from a validated span.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Source byte array. |
| `offset` | `dynamic` | — | Start of the field. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/native_packing.ml#L52)

<a id="constant-constant-mlc-native-packing-footer-size-const-footer-size-48-mlc-native-packing-ml-240271247"></a>
### FOOTER_SIZE

```ml
const FOOTER_SIZE = 48
```


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/native_packing.ml#L26)

<a id="constant-constant-mlc-native-packing-image-limit-const-image-limit-1073741824-mlc-native-packing-ml-1630346612"></a>
### IMAGE_LIMIT

```ml
const IMAGE_LIMIT = 1073741824
```


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/native_packing.ml#L24)

<a id="constant-constant-mlc-native-packing-magic-const-magic-mlnpack1-mlc-native-packing-ml-1062832882"></a>
### MAGIC

```ml
const MAGIC = "MLNPACK1"
```


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/native_packing.ml#L25)

<a id="function-function-mlc-native-packing-packimage-function-packimage-original-mlc-native-packing-ml-1001617017"></a>
### packImage

```ml
function packImage(original)
```

Compress only code; leave OS imports and dynamic linker tables readable. No external compressor or decompression library is used on either host.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `original` | `dynamic` | — | Compiler-generated PE or ELF bytes. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/native_packing.ml#L422)

<a id="function-function-mlc-native-packing-unpackimage-function-unpackimage-image-mlc-native-packing-ml-580444269"></a>
### unpackImage

```ml
function unpackImage(image)
```

Restore a native-packed image exactly, including original file padding. This is also run before publication to prove the supported layout roundtrips.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `image` | `dynamic` | — | Complete packed PE or ELF bytes. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/native_packing.ml#L354)
