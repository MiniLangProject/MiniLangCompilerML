# `mlc/cache_codec.ml`

[Home](README.md) · [Files](Files.md)

Bounded data-only encoding for disposable compiler cache records.

Package: [`mlc.cache_codec`](Package-mlc-cache-codec-1414213508.md)

Reachable from entry: **yes**

## Imports

- `mlc/project.ml` as `project` → [mlc/project.ml](File-mlc-project-ml-1332928426.md)
- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)
- `std/checksum/crc32.ml` as `crc32` → `std/checksum/crc32.ml` — external dependency
- `std/checksum/crc32c.ml` as `crc32c` → `std/checksum/crc32c.ml` — external dependency

## Declarations

<a id="function-function-mlc-cache-codec-appendnumber-function-appendnumber-w-value-width-mlc-cache-codec-ml-159849596"></a>
### appendNumber

```ml
function appendNumber(w, value, width)
```

Append a little-endian scalar without a temporary bytes allocation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `w` | `dynamic` | — | Mutable primitive-value encoder. |
| `value` | `dynamic` | — | Primitive value to encode or fingerprint. |
| `width` | `dynamic` | — | Little-endian integer width in bytes. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L59)

<a id="function-function-mlc-cache-codec-appendpayload-function-appendpayload-w-value-mlc-cache-codec-ml-1507493800"></a>
### appendPayload

```ml
function appendPayload(w, value)
```

Copy a string/bytes payload after its length has been written.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `w` | `dynamic` | — | Mutable primitive-value encoder. |
| `value` | `dynamic` | — | Primitive value to encode or fingerprint. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L70)

<a id="function-function-mlc-cache-codec-decoderecord-function-decoderecord-data-mlc-cache-codec-ml-946455406"></a>
### decodeRecord

```ml
function decodeRecord(data)
```

Decode the entire payload; trailing data and truncated records are invalid.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Encoded bytes to validate or copy. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L206)

<a id="function-function-mlc-cache-codec-encode-function-encode-value-mlc-cache-codec-ml-1700177987"></a>
### encode

```ml
function encode(value)
```

Encode one complete primitive value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Primitive value to encode or fingerprint. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L124)

<a id="function-function-mlc-cache-codec-ensure-function-ensure-w-additional-mlc-cache-codec-ml-847958730"></a>
### ensure

```ml
function ensure(w, additional)
```

Grow geometrically with a bounded native copy, preserving only used bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `w` | `dynamic` | — | Mutable primitive-value encoder. |
| `additional` | `dynamic` | — | Number of bytes needed by the next write. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L41)

<a id="function-function-mlc-cache-codec-finish-function-finish-w-mlc-cache-codec-ml-1495014703"></a>
### finish

```ml
function finish(w)
```

Finish a record, returning void for unsupported values.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `w` | `dynamic` | — | Mutable primitive-value encoder. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L117)

<a id="function-function-mlc-cache-codec-identity-function-identity-data-mlc-cache-codec-ml-473877778"></a>
### identity

```ml
function identity(data)
```

Identify cache data using length and two independent native CRC polynomials.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Encoded bytes to validate or copy. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L132)

<a id="function-function-mlc-cache-codec-key-function-key-value-mlc-cache-codec-ml-2075300665"></a>
### key

```ml
function key(value)
```

Return a filename-safe identity for a primitive key.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Primitive value to encode or fingerprint. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L139)

<a id="function-function-mlc-cache-codec-number-function-number-rd-width-mlc-cache-codec-ml-1026519852"></a>
### number

```ml
function number(rd, width)
```

Read a small unsigned integer, validating bounds before each access.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rd` | `dynamic` | — | Bounded reader and its remaining input budget. |
| `width` | `dynamic` | — | Little-endian integer width in bytes. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L159)

<a id="function-function-mlc-cache-codec-read-function-read-rd-depth-mlc-cache-codec-ml-760660517"></a>
### read

```ml
function read(rd, depth)
```

Decode one bounded tree. MiniLang integer payloads naturally wrap to 61 bits.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rd` | `dynamic` | — | Bounded reader and its remaining input budget. |
| `depth` | `dynamic` | — | Current nesting depth in the encoded value. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L172)

- [mlc.cache_codec.Reader](Type-mlc-cache-codec-reader-723462689.md) — struct
<a id="function-function-mlc-cache-codec-slice-function-slice-data-start-count-mlc-cache-codec-ml-596564237"></a>
### slice

```ml
function slice(data, start, count)
```

Copy a checked byte slice without per-byte interpreter work.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `dynamic` | — | Encoded bytes to validate or copy. |
| `start` | `dynamic` | — | First byte or record offset to include. |
| `count` | `dynamic` | — | Number of bytes to copy. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L149)

<a id="function-function-mlc-cache-codec-write-function-write-w-value-mlc-cache-codec-ml-721713486"></a>
### write

```ml
function write(w, value)
```

Encode primitive data and arrays. Structs require an explicit projection.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `w` | `dynamic` | — | Mutable primitive-value encoder. |
| `value` | `dynamic` | — | Primitive value to encode or fingerprint. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L84)

<a id="function-function-mlc-cache-codec-writer-function-writer-mlc-cache-codec-ml-416518610"></a>
### writer

```ml
function writer()
```

Start a new primitive-value encoder.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L34)

- [mlc.cache_codec.Writer](Type-mlc-cache-codec-writer-1105957265.md) — struct
