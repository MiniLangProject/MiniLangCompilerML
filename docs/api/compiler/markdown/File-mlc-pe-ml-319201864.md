# `mlc/pe.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc pe package.

Package: [`mlc.pe`](Package-mlc-pe-1521258410.md)

Reachable from entry: **yes**

## Imports

- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)

## Declarations

<a id="function-function-mlc-pe-bytes-from-array-function-bytes-from-array-arr-mlc-pe-ml-1077762051"></a>
### _bytes_from_array

```ml
function _bytes_from_array(arr)
```

Implements bytes from array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pe.ml#L113)

<a id="function-function-mlc-pe-bytes-ljust-function-bytes-ljust-b-size-mlc-pe-ml-1363468897"></a>
### _bytes_ljust

```ml
function _bytes_ljust(b, size)
```

Implements bytes ljust.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `b` | `dynamic` | — |  |
| `size` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pe.ml#L131)

<a id="function-function-mlc-pe-bytes-pad-to-function-bytes-pad-to-b-size-mlc-pe-ml-863210917"></a>
### _bytes_pad_to

```ml
function _bytes_pad_to(b, size)
```

Implements bytes pad to.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `b` | `dynamic` | — |  |
| `size` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pe.ml#L124)

<a id="function-function-mlc-pe-bytes-write-at-function-bytes-write-at-dst-offset-src-mlc-pe-ml-671643854"></a>
### _bytes_write_at

```ml
function _bytes_write_at(dst, offset, src)
```

Implements bytes write at.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dst` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `src` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pe.ml#L137)

<a id="function-function-mlc-pe-find-section-by-name-function-find-section-by-name-pe-name-mlc-pe-ml-696213732"></a>
### _find_section_by_name

```ml
function _find_section_by_name(pe, name)
```

Returns find section by name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pe` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pe.ml#L208)

<a id="function-function-mlc-pe-imports-get-funcs-function-imports-get-funcs-imports-dll-mlc-pe-ml-734763102"></a>
### _imports_get_funcs

```ml
function _imports_get_funcs(imports, dll)
```

Implements imports get funcs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `imports` | `dynamic` | — |  |
| `dll` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pe.ml#L176)

<a id="function-function-mlc-pe-named-get-function-named-get-arr-name-default-value-mlc-pe-ml-1950578045"></a>
### _named_get

```ml
function _named_get(arr, name, default_value)
```

Implements named get.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `default_value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pe.ml#L145)

<a id="function-function-mlc-pe-named-set-function-named-set-arr-name-value-mlc-pe-ml-2095775155"></a>
### _named_set

```ml
function _named_set(arr, name, value)
```

Implements named set.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pe.ml#L158)

<a id="function-function-mlc-pe-next-section-raw-addr-function-next-section-raw-addr-pe-mlc-pe-ml-1712410717"></a>
### _next_section_raw_addr

```ml
function _next_section_raw_addr(pe)
```

Implements next section raw addr.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pe` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pe.ml#L198)

<a id="function-function-mlc-pe-section-name-bytes-function-section-name-bytes-name-mlc-pe-ml-427745929"></a>
### _section_name_bytes

```ml
function _section_name_bytes(name)
```

Implements section name bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pe.ml#L188)

<a id="function-function-mlc-pe-add-section-function-add-section-pe-name-data-characteristics-mlc-pe-ml-1626907056"></a>
### add_section

```ml
function add_section(pe, name, data, characteristics)
```

Append one section; layout() assigns its addresses later.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pe` | `dynamic` | — | Value supplied for `pe`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `data` | `dynamic` | — | Data to process. |
| `characteristics` | `dynamic` | — | Value supplied for `characteristics`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pe.ml#L237)

<a id="function-function-mlc-pe-build-function-build-pe-mlc-pe-ml-176955077"></a>
### build

```ml
function build(pe)
```

Serialize headers and aligned section payloads into the final PE bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pe` | `dynamic` | — | Value supplied for `pe`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pe.ml#L276)

<a id="function-function-mlc-pe-build-idata-function-build-idata-imports-base-rva-mlc-pe-ml-121533309"></a>
### build_idata

```ml
function build_idata(imports, base_rva)
```

Build a deterministic .idata section and resolved IAT symbol table.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `imports` | `dynamic` | — | Value supplied for `imports`. |
| `base_rva` | `dynamic` | — | Value supplied for `base_rva`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pe.ml#L428)

- [mlc.pe.IatSymbol](Type-mlc-pe-iatsymbol-1842609754.md) — struct
- [mlc.pe.IdataResult](Type-mlc-pe-idataresult-1462108830.md) — struct
<a id="constant-constant-mlc-pe-image-scn-cnt-code-const-image-scn-cnt-code-32-mlc-pe-ml-233951744"></a>
### IMAGE_SCN_CNT_CODE

```ml
const IMAGE_SCN_CNT_CODE = 32
```

Stores the image scn cnt code.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pe.ml#L29)

<a id="constant-constant-mlc-pe-image-scn-cnt-initialized-data-const-image-scn-cnt-initialized-data-64-mlc-pe-ml-277886275"></a>
### IMAGE_SCN_CNT_INITIALIZED_DATA

```ml
const IMAGE_SCN_CNT_INITIALIZED_DATA = 64
```

Stores the image scn cnt initialized data.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pe.ml#L31)

<a id="constant-constant-mlc-pe-image-scn-cnt-uninitialized-data-const-image-scn-cnt-uninitialized-data-128-mlc-pe-ml-841836798"></a>
### IMAGE_SCN_CNT_UNINITIALIZED_DATA

```ml
const IMAGE_SCN_CNT_UNINITIALIZED_DATA = 128
```

Stores the image scn cnt uninitialized data.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pe.ml#L33)

- [mlc.pe.ImportDll](Type-mlc-pe-importdll-591723743.md) — struct
<a id="constant-constant-mlc-pe-kernel32-const-kernel32-kernel32-dll-mlc-pe-ml-177326679"></a>
### KERNEL32

```ml
const KERNEL32 = "kernel32.dll"
```

Stores the kernel32.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pe.ml#L24)

<a id="function-function-mlc-pe-layout-function-layout-pe-mlc-pe-ml-1996787905"></a>
### layout

```ml
function layout(pe)
```

Assign deterministic virtual and file offsets to every section.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pe` | `dynamic` | — | Value supplied for `pe`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pe.ml#L245)

<a id="constant-constant-mlc-pe-msvcrt-const-msvcrt-msvcrt-dll-mlc-pe-ml-1991403726"></a>
### MSVCRT

```ml
const MSVCRT = "msvcrt.dll"
```

Stores the msvcrt.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pe.ml#L26)

- [mlc.pe.NamedInt](Type-mlc-pe-namedint-1783969514.md) — struct
<a id="function-function-mlc-pe-newpebuilder-function-newpebuilder-mlc-pe-ml-1520997444"></a>
### newPEBuilder

```ml
function newPEBuilder()
```

Create a Windows x64 image plan with stable alignment defaults.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pe.ml#L219)

- [mlc.pe.PEBuilder](Type-mlc-pe-pebuilder-621220002.md) — struct
- [mlc.pe.PESection](Type-mlc-pe-pesection-1478081814.md) — struct
