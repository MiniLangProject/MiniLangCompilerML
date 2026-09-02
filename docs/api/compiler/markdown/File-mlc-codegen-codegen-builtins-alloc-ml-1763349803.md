# `mlc/codegen/codegen_builtins_alloc.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc codegen codegen_builtins_alloc package.

Package: [`mlc.codegen.codegen_builtins_alloc`](Package-mlc-codegen-codegen-builtins-alloc-457082396.md)

Reachable from entry: **yes**

## Imports

- `mlc/asm.ml` as `a` → [mlc/asm.ml](File-mlc-asm-ml-1368648960.md)
- `mlc/codegen/codegen_core.ml` as `core` → [mlc/codegen/codegen_core.ml](File-mlc-codegen-codegen-core-ml-528695596.md)
- `mlc/codegen/codegen_memory.ml` as `mem` → [mlc/codegen/codegen_memory.ml](File-mlc-codegen-codegen-memory-ml-2136639668.md)
- `mlc/constants.ml` as `c` → [mlc/constants.ml](File-mlc-constants-ml-1024884042.md)
- `mlc/data.ml` as `d` → [mlc/data.ml](File-mlc-data-ml-557434521.md)
- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)

## Declarations

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-addstr-error-function-emit-addstr-error-state-msg-lbl-mlc-codegen-codegen-builtins-alloc-ml-866812356"></a>
### _emit_addstr_error

```ml
function _emit_addstr_error(state, msg_lbl)
```

Runs emit addstr error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `msg_lbl` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L33)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-ensure-enum-obj-strings-function-ensure-enum-obj-strings-state-mlc-codegen-codegen-builtins-alloc-ml-2013020058"></a>
### _ensure_enum_obj_strings

```ml
function _ensure_enum_obj_strings(state)
```

Implements ensure enum obj strings.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L70)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-enum-variants-of-function-enum-variants-of-state-qname-mlc-codegen-codegen-builtins-alloc-ml-1426592110"></a>
### _enum_variants_of

```ml
function _enum_variants_of(state, qname)
```

Implements enum variants of.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L51)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-has-label-function-has-label-labels-name-mlc-codegen-codegen-builtins-alloc-ml-562228589"></a>
### _has_label

```ml
function _has_label(labels, name)
```

Reports whether has label.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `labels` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L40)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-cg-emit-builtins-alloc-function-cg-emit-builtins-alloc-state-mlc-codegen-codegen-builtins-alloc-ml-85017614"></a>
### cg_emit_builtins_alloc

```ml
function cg_emit_builtins_alloc(state)
```

Implements cg emit builtins alloc.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L3013)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-array-add-function-function-emit-array-add-function-state-mlc-codegen-codegen-builtins-alloc-ml-404836874"></a>
### emit_array_add_function

```ml
function emit_array_add_function(state)
```

Runs emit array add function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L1297)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-box-float-function-function-emit-box-float-function-state-mlc-codegen-codegen-builtins-alloc-ml-1552409924"></a>
### emit_box_float_function

```ml
function emit_box_float_function(state)
```

Runs emit box float function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L838)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-bytes-add-function-function-emit-bytes-add-function-state-mlc-codegen-codegen-builtins-alloc-ml-671638674"></a>
### emit_bytes_add_function

```ml
function emit_bytes_add_function(state)
```

Runs emit bytes add function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L1414)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-bytes-alloc-function-function-emit-bytes-alloc-function-state-mlc-codegen-codegen-builtins-alloc-ml-1267821362"></a>
### emit_bytes_alloc_function

```ml
function emit_bytes_alloc_function(state)
```

Runs emit bytes alloc function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L1371)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-bytes-eq-function-function-emit-bytes-eq-function-state-mlc-codegen-codegen-builtins-alloc-ml-1120651394"></a>
### emit_bytes_eq_function

```ml
function emit_bytes_eq_function(state)
```

Runs emit bytes eq function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L1484)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-decode16z-function-function-emit-decode16z-function-state-mlc-codegen-codegen-builtins-alloc-ml-788400018"></a>
### emit_decode16Z_function

```ml
function emit_decode16Z_function(state)
```

Runs emit decode16 z function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L365)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-decode-function-function-emit-decode-function-state-mlc-codegen-codegen-builtins-alloc-ml-751969402"></a>
### emit_decode_function

```ml
function emit_decode_function(state)
```

Runs emit decode function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L225)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-decodez-function-function-emit-decodez-function-state-mlc-codegen-codegen-builtins-alloc-ml-102628784"></a>
### emit_decodeZ_function

```ml
function emit_decodeZ_function(state)
```

Runs emit decode z function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L293)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-fromhex-function-function-emit-fromhex-function-state-mlc-codegen-codegen-builtins-alloc-ml-2013090778"></a>
### emit_fromHex_function

```ml
function emit_fromHex_function(state)
```

Runs emit from hex function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L580)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-hex-function-function-emit-hex-function-state-mlc-codegen-codegen-builtins-alloc-ml-2059201050"></a>
### emit_hex_function

```ml
function emit_hex_function(state)
```

Runs emit hex function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L467)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-input-function-function-emit-input-function-state-mlc-codegen-codegen-builtins-alloc-ml-858520024"></a>
### emit_input_function

```ml
function emit_input_function(state)
```

Runs emit input function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L102)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-slice-function-function-emit-slice-function-state-mlc-codegen-codegen-builtins-alloc-ml-1961768308"></a>
### emit_slice_function

```ml
function emit_slice_function(state)
```

Runs emit slice function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L1552)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-string-add-function-function-emit-string-add-function-state-mlc-codegen-codegen-builtins-alloc-ml-732887898"></a>
### emit_string_add_function

```ml
function emit_string_add_function(state)
```

Runs emit string add function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L1102)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-string-endswith-function-function-emit-string-endswith-function-state-mlc-codegen-codegen-builtins-alloc-ml-655638304"></a>
### emit_string_endswith_function

```ml
function emit_string_endswith_function(state)
```

Runs emit string endswith function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L2007)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-string-eq-ignore-case-ascii-function-function-emit-string-eq-ignore-case-ascii-function-state-mlc-codegen-codegen-builtins-alloc-ml-2092485688"></a>
### emit_string_eq_ignore_case_ascii_function

```ml
function emit_string_eq_ignore_case_ascii_function(state)
```

Runs emit string eq ignore case ascii function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L2783)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-string-indexof-function-function-emit-string-indexof-function-state-mlc-codegen-codegen-builtins-alloc-ml-418389098"></a>
### emit_string_indexof_function

```ml
function emit_string_indexof_function(state)
```

Runs emit string indexof function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L1787)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-string-is-blank-ascii-function-function-emit-string-is-blank-ascii-function-state-mlc-codegen-codegen-builtins-alloc-ml-576081770"></a>
### emit_string_is_blank_ascii_function

```ml
function emit_string_is_blank_ascii_function(state)
```

Runs emit string is blank ascii function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L2434)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-string-join-function-function-emit-string-join-function-state-mlc-codegen-codegen-builtins-alloc-ml-295930736"></a>
### emit_string_join_function

```ml
function emit_string_join_function(state)
```

Runs emit string join function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L2857)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-string-lastindexof-function-function-emit-string-lastindexof-function-state-mlc-codegen-codegen-builtins-alloc-ml-1650872574"></a>
### emit_string_lastindexof_function

```ml
function emit_string_lastindexof_function(state)
```

Runs emit string lastindexof function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L1880)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-string-ltrim-ascii-function-function-emit-string-ltrim-ascii-function-state-mlc-codegen-codegen-builtins-alloc-ml-1420755194"></a>
### emit_string_ltrim_ascii_function

```ml
function emit_string_ltrim_ascii_function(state)
```

Runs emit string ltrim ascii function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L2178)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-string-repeat-function-function-emit-string-repeat-function-state-mlc-codegen-codegen-builtins-alloc-ml-445144794"></a>
### emit_string_repeat_function

```ml
function emit_string_repeat_function(state)
```

Runs emit string repeat function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L2066)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-string-reverse-function-function-emit-string-reverse-function-state-mlc-codegen-codegen-builtins-alloc-ml-1806498462"></a>
### emit_string_reverse_function

```ml
function emit_string_reverse_function(state)
```

Runs emit string reverse function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L2482)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-string-rtrim-ascii-function-function-emit-string-rtrim-ascii-function-state-mlc-codegen-codegen-builtins-alloc-ml-386542674"></a>
### emit_string_rtrim_ascii_function

```ml
function emit_string_rtrim_ascii_function(state)
```

Runs emit string rtrim ascii function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L2255)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-string-slice-function-function-emit-string-slice-function-state-mlc-codegen-codegen-builtins-alloc-ml-670650374"></a>
### emit_string_slice_function

```ml
function emit_string_slice_function(state)
```

Runs emit string slice function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L1658)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-string-startswith-function-function-emit-string-startswith-function-state-mlc-codegen-codegen-builtins-alloc-ml-1295344506"></a>
### emit_string_startswith_function

```ml
function emit_string_startswith_function(state)
```

Runs emit string startswith function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L1950)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-string-to-lower-ascii-function-function-emit-string-to-lower-ascii-function-state-mlc-codegen-codegen-builtins-alloc-ml-1846023914"></a>
### emit_string_to_lower_ascii_function

```ml
function emit_string_to_lower_ascii_function(state)
```

Runs emit string to lower ascii function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L2569)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-string-to-upper-ascii-function-function-emit-string-to-upper-ascii-function-state-mlc-codegen-codegen-builtins-alloc-ml-367254172"></a>
### emit_string_to_upper_ascii_function

```ml
function emit_string_to_upper_ascii_function(state)
```

Runs emit string to upper ascii function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L2676)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-string-trim-ascii-function-function-emit-string-trim-ascii-function-state-mlc-codegen-codegen-builtins-alloc-ml-1979931772"></a>
### emit_string_trim_ascii_function

```ml
function emit_string_trim_ascii_function(state)
```

Runs emit string trim ascii function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L2330)

<a id="function-function-mlc-codegen-codegen-builtins-alloc-emit-value-to-string-function-function-emit-value-to-string-function-state-mlc-codegen-codegen-builtins-alloc-ml-586077162"></a>
### emit_value_to_string_function

```ml
function emit_value_to_string_function(state)
```

Runs emit value to string function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L859)

<a id="constant-constant-mlc-codegen-codegen-builtins-alloc-input-read-max-const-input-read-max-4095-mlc-codegen-codegen-builtins-alloc-ml-1286234778"></a>
### INPUT_READ_MAX

```ml
const INPUT_READ_MAX = 4095
```

Stores the input read max.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_builtins_alloc.ml#L29)
