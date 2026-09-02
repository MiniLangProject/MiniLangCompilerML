# `mlc/codegen/codegen_runtime.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc codegen codegen_runtime package.

Package: [`mlc.codegen.codegen_runtime`](Package-mlc-codegen-codegen-runtime-776404906.md)

Reachable from entry: **yes**

## Imports

- `mlc/asm.ml` as `a` → [mlc/asm.ml](File-mlc-asm-ml-1368648960.md)
- `mlc/constants.ml` as `c` → [mlc/constants.ml](File-mlc-constants-ml-1024884042.md)
- `mlc/data.ml` as `d` → [mlc/data.ml](File-mlc-data-ml-557434521.md)
- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)

## Declarations

<a id="function-function-mlc-codegen-codegen-runtime-emit-build-args-linux-function-emit-build-args-linux-state-mlc-codegen-codegen-runtime-ml-745727140"></a>
### _emit_build_args_linux

```ml
function _emit_build_args_linux(state)
```

Runs emit build args linux.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L3197)

<a id="function-function-mlc-codegen-codegen-runtime-emit-force-xmm0-to-float-value-function-emit-force-xmm0-to-float-value-state-mlc-codegen-codegen-runtime-ml-26923332"></a>
### _emit_force_xmm0_to_float_value

```ml
function _emit_force_xmm0_to_float_value(state)
```

Runs emit force xmm0 to float value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L155)

<a id="function-function-mlc-codegen-codegen-runtime-emit-mov-rax-i64-max-function-emit-mov-rax-i64-max-state-mlc-codegen-codegen-runtime-ml-2102702944"></a>
### _emit_mov_rax_i64_max

```ml
function _emit_mov_rax_i64_max(state)
```

RAX = 0x7FFFFFFFFFFFFFFF without using an out-of-range source literal.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L46)

<a id="function-function-mlc-codegen-codegen-runtime-emit-mov-rax-u64-hi-lo-function-emit-mov-rax-u64-hi-lo-state-hi32-lo32-mlc-codegen-codegen-runtime-ml-1071085340"></a>
### _emit_mov_rax_u64_hi_lo

```ml
function _emit_mov_rax_u64_hi_lo(state, hi32, lo32)
```

Build an exact 64-bit immediate in RAX from two 32-bit halves. This avoids out-of-range MiniLang integer literals in compiler source.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `hi32` | `dynamic` | — |  |
| `lo32` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L34)

<a id="function-function-mlc-codegen-codegen-runtime-emit-native-crc-wrapper-function-emit-native-crc-wrapper-state-label-raw-label-mlc-codegen-codegen-runtime-ml-65970373"></a>
### _emit_native_crc_wrapper

```ml
function _emit_native_crc_wrapper(state, label, raw_label)
```

Validate tagged arguments once before entering a raw CRC hot loop.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `label` | `dynamic` | — |  |
| `raw_label` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L940)

<a id="function-function-mlc-codegen-codegen-runtime-emit-normalize-xmm0-to-value-function-emit-normalize-xmm0-to-value-state-mlc-codegen-codegen-runtime-ml-2037712558"></a>
### _emit_normalize_xmm0_to_value

```ml
function _emit_normalize_xmm0_to_value(state)
```

Runs emit normalize xmm0 to value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L116)

<a id="function-function-mlc-codegen-codegen-runtime-emit-to-double-xmm-function-emit-to-double-xmm-state-xmm-fail-label-mlc-codegen-codegen-runtime-ml-1880184763"></a>
### _emit_to_double_xmm

```ml
function _emit_to_double_xmm(state, xmm, fail_label)
```

Runs emit to double xmm.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `xmm` | `dynamic` | — |  |
| `fail_label` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L60)

<a id="function-function-mlc-codegen-codegen-runtime-ensure-byte-search-table-function-ensure-byte-search-table-state-mlc-codegen-codegen-runtime-ml-19967732"></a>
### _ensure_byte_search_table

```ml
function _ensure_byte_search_table(state)
```

Implements ensure byte search table.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L502)

<a id="function-function-mlc-codegen-codegen-runtime-ensure-crc-tables-function-ensure-crc-tables-state-mlc-codegen-codegen-runtime-ml-1516024476"></a>
### _ensure_crc_tables

```ml
function _ensure_crc_tables(state)
```

Implements ensure crc tables.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L839)

<a id="function-function-mlc-codegen-codegen-runtime-make-crc-table-function-make-crc-table-poly-mlc-codegen-codegen-runtime-ml-672147517"></a>
### _make_crc_table

```ml
function _make_crc_table(poly)
```

Creates make crc table.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `poly` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L821)

<a id="function-function-mlc-codegen-codegen-runtime-cg-runtime-init-function-cg-runtime-init-state-mlc-codegen-codegen-runtime-ml-2039830360"></a>
### cg_runtime_init

```ml
function cg_runtime_init(state)
```

Implements cg runtime init.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L28)

<a id="function-function-mlc-codegen-codegen-runtime-emit-build-args-function-function-emit-build-args-function-state-mlc-codegen-codegen-runtime-ml-534829940"></a>
### emit_build_args_function

```ml
function emit_build_args_function(state)
```

Runs emit build args function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L3285)

<a id="function-function-mlc-codegen-codegen-runtime-emit-builtin-copyarray-function-function-emit-builtin-copyarray-function-state-mlc-codegen-codegen-runtime-ml-1370754338"></a>
### emit_builtin_copyArray_function

```ml
function emit_builtin_copyArray_function(state)
```

Copy tagged array cells in one native bulk operation. Bounds and type handling deliberately match copyBytes(): invalid inputs are a no-op and the requested length is clipped to both remaining array tails.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L3563)

<a id="function-function-mlc-codegen-codegen-runtime-emit-builtin-copybytes-function-function-emit-builtin-copybytes-function-state-mlc-codegen-codegen-runtime-ml-367431250"></a>
### emit_builtin_copyBytes_function

```ml
function emit_builtin_copyBytes_function(state)
```

Runs emit builtin copy bytes function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L3457)

<a id="function-function-mlc-codegen-codegen-runtime-emit-builtin-copystringbytes-function-function-emit-builtin-copystringbytes-function-state-mlc-codegen-codegen-runtime-ml-1181575084"></a>
### emit_builtin_copyStringBytes_function

```ml
function emit_builtin_copyStringBytes_function(state)
```

Runs emit builtin copy string bytes function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L1742)

<a id="function-function-mlc-codegen-codegen-runtime-emit-builtin-fillbytes-function-function-emit-builtin-fillbytes-function-state-mlc-codegen-codegen-runtime-ml-1031161770"></a>
### emit_builtin_fillBytes_function

```ml
function emit_builtin_fillBytes_function(state)
```

Runs emit builtin fill bytes function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L3681)

<a id="function-function-mlc-codegen-codegen-runtime-emit-builtin-gc-collect-function-function-emit-builtin-gc-collect-function-state-mlc-codegen-codegen-runtime-ml-1836857400"></a>
### emit_builtin_gc_collect_function

```ml
function emit_builtin_gc_collect_function(state)
```

Runs emit builtin gc collect function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L3829)

<a id="function-function-mlc-codegen-codegen-runtime-emit-builtin-gc-set-limit-function-function-emit-builtin-gc-set-limit-function-state-mlc-codegen-codegen-runtime-ml-1019220532"></a>
### emit_builtin_gc_set_limit_function

```ml
function emit_builtin_gc_set_limit_function(state)
```

Runs emit builtin gc set limit function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L3839)

<a id="function-function-mlc-codegen-codegen-runtime-emit-builtin-input-function-function-emit-builtin-input-function-state-mlc-codegen-codegen-runtime-ml-1368324302"></a>
### emit_builtin_input_function

```ml
function emit_builtin_input_function(state)
```

Runs emit builtin input function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L3803)

<a id="function-function-mlc-codegen-codegen-runtime-emit-builtin-len-function-function-emit-builtin-len-function-state-mlc-codegen-codegen-runtime-ml-919784296"></a>
### emit_builtin_len_function

```ml
function emit_builtin_len_function(state)
```

Runs emit builtin len function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L3762)

<a id="function-function-mlc-codegen-codegen-runtime-emit-bytes-compare-function-function-emit-bytes-compare-function-state-mlc-codegen-codegen-runtime-ml-170599544"></a>
### emit_bytes_compare_function

```ml
function emit_bytes_compare_function(state)
```

Runs emit bytes compare function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L1664)

<a id="function-function-mlc-codegen-codegen-runtime-emit-bytes-constant-time-eq-function-function-emit-bytes-constant-time-eq-function-state-mlc-codegen-codegen-runtime-ml-1957626140"></a>
### emit_bytes_constant_time_eq_function

```ml
function emit_bytes_constant_time_eq_function(state)
```

Compare byte buffers without value-dependent early exits.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L446)

<a id="function-function-mlc-codegen-codegen-runtime-emit-bytes-endswith-function-function-emit-bytes-endswith-function-state-mlc-codegen-codegen-runtime-ml-619147724"></a>
### emit_bytes_endswith_function

```ml
function emit_bytes_endswith_function(state)
```

Runs emit bytes endswith function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L1442)

<a id="function-function-mlc-codegen-codegen-runtime-emit-bytes-hash-function-function-emit-bytes-hash-function-state-mlc-codegen-codegen-runtime-ml-1093074800"></a>
### emit_bytes_hash_function

```ml
function emit_bytes_hash_function(state)
```

Runs emit bytes hash function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L1298)

<a id="function-function-mlc-codegen-codegen-runtime-emit-bytes-indexof-function-function-emit-bytes-indexof-function-state-mlc-codegen-codegen-runtime-ml-2096478812"></a>
### emit_bytes_indexof_function

```ml
function emit_bytes_indexof_function(state)
```

Runs emit bytes indexof function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L1501)

<a id="function-function-mlc-codegen-codegen-runtime-emit-bytes-lastindexof-function-function-emit-bytes-lastindexof-function-state-mlc-codegen-codegen-runtime-ml-1410025644"></a>
### emit_bytes_lastindexof_function

```ml
function emit_bytes_lastindexof_function(state)
```

Runs emit bytes lastindexof function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L1594)

<a id="function-function-mlc-codegen-codegen-runtime-emit-bytes-startswith-function-function-emit-bytes-startswith-function-state-mlc-codegen-codegen-runtime-ml-1583047876"></a>
### emit_bytes_startswith_function

```ml
function emit_bytes_startswith_function(state)
```

Runs emit bytes startswith function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L1386)

<a id="function-function-mlc-codegen-codegen-runtime-emit-callstats-function-function-emit-callstats-function-state-mlc-codegen-codegen-runtime-ml-1296788652"></a>
### emit_callStats_function

```ml
function emit_callStats_function(state)
```

Runs emit call stats function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L3903)

<a id="function-function-mlc-codegen-codegen-runtime-emit-copy-bytes-function-function-emit-copy-bytes-function-state-mlc-codegen-codegen-runtime-ml-710271692"></a>
### emit_copy_bytes_function

```ml
function emit_copy_bytes_function(state)
```

Runs emit copy bytes function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L1854)

<a id="function-function-mlc-codegen-codegen-runtime-emit-cpu-init-function-function-emit-cpu-init-function-state-mlc-codegen-codegen-runtime-ml-156433868"></a>
### emit_cpu_init_function

```ml
function emit_cpu_init_function(state)
```

Runs emit cpu init function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L180)

<a id="function-function-mlc-codegen-codegen-runtime-emit-crc32-update-raw-function-function-emit-crc32-update-raw-function-state-mlc-codegen-codegen-runtime-ml-549775004"></a>
### emit_crc32_update_raw_function

```ml
function emit_crc32_update_raw_function(state)
```

Runs emit crc32 update raw function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L908)

<a id="function-function-mlc-codegen-codegen-runtime-emit-crc32c-update-raw-function-function-emit-crc32c-update-raw-function-state-mlc-codegen-codegen-runtime-ml-1330212860"></a>
### emit_crc32c_update_raw_function

```ml
function emit_crc32c_update_raw_function(state)
```

Runs emit crc32c update raw function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L851)

<a id="function-function-mlc-codegen-codegen-runtime-emit-fill-bytes-function-function-emit-fill-bytes-function-state-mlc-codegen-codegen-runtime-ml-665054572"></a>
### emit_fill_bytes_function

```ml
function emit_fill_bytes_function(state)
```

Runs emit fill bytes function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L1978)

<a id="function-function-mlc-codegen-codegen-runtime-emit-fill-qwords-function-function-emit-fill-qwords-function-state-mlc-codegen-codegen-runtime-ml-1398510114"></a>
### emit_fill_qwords_function

```ml
function emit_fill_qwords_function(state)
```

Runs emit fill qwords function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L2082)

<a id="function-function-mlc-codegen-codegen-runtime-emit-find-byte-forward-function-function-emit-find-byte-forward-function-state-mlc-codegen-codegen-runtime-ml-948367850"></a>
### emit_find_byte_forward_function

```ml
function emit_find_byte_forward_function(state)
```

Raw dynamic byte search with AVX2, SSE2, and scalar dispatch.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L516)

<a id="function-function-mlc-codegen-codegen-runtime-emit-find-byte-reverse-function-function-emit-find-byte-reverse-function-state-mlc-codegen-codegen-runtime-ml-1832090052"></a>
### emit_find_byte_reverse_function

```ml
function emit_find_byte_reverse_function(state)
```

Runs emit find byte reverse function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L606)

<a id="function-function-mlc-codegen-codegen-runtime-emit-init-argvw-function-function-emit-init-argvw-function-state-mlc-codegen-codegen-runtime-ml-1233742276"></a>
### emit_init_argvw_function

```ml
function emit_init_argvw_function(state)
```

Runs emit init argvw function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L3162)

<a id="function-function-mlc-codegen-codegen-runtime-emit-int-to-dec-function-function-emit-int-to-dec-function-state-mlc-codegen-codegen-runtime-ml-1742139360"></a>
### emit_int_to_dec_function

```ml
function emit_int_to_dec_function(state)
```

Runs emit int to dec function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L2129)

<a id="function-function-mlc-codegen-codegen-runtime-emit-mem-eq-bytes-function-function-emit-mem-eq-bytes-function-state-mlc-codegen-codegen-runtime-ml-261482808"></a>
### emit_mem_eq_bytes_function

```ml
function emit_mem_eq_bytes_function(state)
```

Runs emit mem eq bytes function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L345)

<a id="function-function-mlc-codegen-codegen-runtime-emit-mem-indexof-function-function-emit-mem-indexof-function-state-mlc-codegen-codegen-runtime-ml-148236232"></a>
### emit_mem_indexof_function

```ml
function emit_mem_indexof_function(state)
```

Raw substring search built on SIMD first-byte candidate discovery.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L694)

<a id="function-function-mlc-codegen-codegen-runtime-emit-mem-lastindexof-function-function-emit-mem-lastindexof-function-state-mlc-codegen-codegen-runtime-ml-263126932"></a>
### emit_mem_lastindexof_function

```ml
function emit_mem_lastindexof_function(state)
```

Runs emit mem lastindexof function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L762)

<a id="function-function-mlc-codegen-codegen-runtime-emit-native-crc32-function-function-emit-native-crc32-function-state-mlc-codegen-codegen-runtime-ml-296402724"></a>
### emit_native_crc32_function

```ml
function emit_native_crc32_function(state)
```

Runs emit native crc32 function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L1010)

<a id="function-function-mlc-codegen-codegen-runtime-emit-native-crc32c-function-function-emit-native-crc32c-function-state-mlc-codegen-codegen-runtime-ml-581375542"></a>
### emit_native_crc32c_function

```ml
function emit_native_crc32c_function(state)
```

Runs emit native crc32c function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L1004)

<a id="function-function-mlc-codegen-codegen-runtime-emit-runtime-cpu-active-features-function-function-emit-runtime-cpu-active-features-function-state-mlc-codegen-codegen-runtime-ml-698579582"></a>
### emit_runtime_cpu_active_features_function

```ml
function emit_runtime_cpu_active_features_function(state)
```

Runs emit runtime cpu active features function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L294)

<a id="function-function-mlc-codegen-codegen-runtime-emit-runtime-cpu-features-function-function-emit-runtime-cpu-features-function-state-mlc-codegen-codegen-runtime-ml-1281190268"></a>
### emit_runtime_cpu_features_function

```ml
function emit_runtime_cpu_features_function(state)
```

Runs emit runtime cpu features function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L283)

<a id="function-function-mlc-codegen-codegen-runtime-emit-runtime-cpu-set-mask-function-function-emit-runtime-cpu-set-mask-function-state-mlc-codegen-codegen-runtime-ml-1204335896"></a>
### emit_runtime_cpu_set_mask_function

```ml
function emit_runtime_cpu_set_mask_function(state)
```

Limit dispatch to detected features. A negative mask restores all features.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L305)

<a id="function-function-mlc-codegen-codegen-runtime-emit-scan-byte2-bytes-function-function-emit-scan-byte2-bytes-function-state-mlc-codegen-codegen-runtime-ml-339157064"></a>
### emit_scan_byte2_bytes_function

```ml
function emit_scan_byte2_bytes_function(state)
```

Runs emit scan byte2 bytes function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L1109)

<a id="function-function-mlc-codegen-codegen-runtime-emit-scan-nul-bytes-function-function-emit-scan-nul-bytes-function-state-mlc-codegen-codegen-runtime-ml-1043760700"></a>
### emit_scan_nul_bytes_function

```ml
function emit_scan_nul_bytes_function(state)
```

Runs emit scan nul bytes function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L1016)

<a id="function-function-mlc-codegen-codegen-runtime-emit-scan-nul-wchars-function-function-emit-scan-nul-wchars-function-state-mlc-codegen-codegen-runtime-ml-831721098"></a>
### emit_scan_nul_wchars_function

```ml
function emit_scan_nul_wchars_function(state)
```

Runs emit scan nul wchars function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L1198)

<a id="function-function-mlc-codegen-codegen-runtime-emit-string-eq-function-function-emit-string-eq-function-state-mlc-codegen-codegen-runtime-ml-2116402438"></a>
### emit_string_eq_function

```ml
function emit_string_eq_function(state)
```

Runs emit string eq function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L2749)

<a id="function-function-mlc-codegen-codegen-runtime-emit-string-hash-function-function-emit-string-hash-function-state-mlc-codegen-codegen-runtime-ml-325949198"></a>
### emit_string_hash_function

```ml
function emit_string_hash_function(state)
```

Runs emit string hash function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L1342)

<a id="function-function-mlc-codegen-codegen-runtime-emit-strlen-function-function-emit-strlen-function-state-mlc-codegen-codegen-runtime-ml-1167218460"></a>
### emit_strlen_function

```ml
function emit_strlen_function(state)
```

Runs emit strlen function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L2739)

<a id="function-function-mlc-codegen-codegen-runtime-emit-tofloat-function-function-emit-tofloat-function-state-mlc-codegen-codegen-runtime-ml-1619213004"></a>
### emit_toFloat_function

```ml
function emit_toFloat_function(state)
```

Runs emit to float function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L2379)

<a id="function-function-mlc-codegen-codegen-runtime-emit-tonumber-function-function-emit-tonumber-function-state-mlc-codegen-codegen-runtime-ml-612955968"></a>
### emit_toNumber_function

```ml
function emit_toNumber_function(state)
```

Runs emit to number function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L2184)

<a id="function-function-mlc-codegen-codegen-runtime-emit-typename-function-function-emit-typename-function-state-mlc-codegen-codegen-runtime-ml-604461264"></a>
### emit_typeName_function

```ml
function emit_typeName_function(state)
```

Runs emit type name function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L2540)

<a id="function-function-mlc-codegen-codegen-runtime-emit-typeof-function-function-emit-typeof-function-state-mlc-codegen-codegen-runtime-ml-884885964"></a>
### emit_typeof_function

```ml
function emit_typeof_function(state)
```

Runs emit typeof function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L2407)

<a id="function-function-mlc-codegen-codegen-runtime-emit-unhandled-error-exit-function-function-emit-unhandled-error-exit-function-state-mlc-codegen-codegen-runtime-ml-856176908"></a>
### emit_unhandled_error_exit_function

```ml
function emit_unhandled_error_exit_function(state)
```

Runs emit unhandled error exit function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L3006)

<a id="nested_function-nested-function-mlc-codegen-codegen-runtime-emit-unhandled-error-exit-function-local-emit-writefile-function-emit-writefile-state2-lbl-ln-mlc-codegen-codegen-runtime-ml-54962409"></a>
### _emit_writefile

```ml
function _emit_writefile(state2, lbl, ln)
```

Runs emit writefile.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state2` | `dynamic` | — |  |
| `lbl` | `dynamic` | — |  |
| `ln` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L3023)

<a id="nested_function-nested-function-mlc-codegen-codegen-runtime-emit-unhandled-error-exit-function-local-emit-writefile-ptr-len-function-emit-writefile-ptr-len-state2-mlc-codegen-codegen-runtime-ml-338525475"></a>
### _emit_writefile_ptr_len

```ml
function _emit_writefile_ptr_len(state2)
```

Runs emit writefile ptr len.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state2` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L3012)

<a id="function-function-mlc-codegen-codegen-runtime-emit-value-eq-function-function-emit-value-eq-function-state-mlc-codegen-codegen-runtime-ml-183796344"></a>
### emit_value_eq_function

```ml
function emit_value_eq_function(state)
```

Runs emit value eq function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_runtime.ml#L2788)
