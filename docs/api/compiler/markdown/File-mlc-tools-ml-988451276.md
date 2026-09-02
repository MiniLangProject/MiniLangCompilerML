# `mlc/tools.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc tools package.

Package: [`mlc.tools`](Package-mlc-tools-1049496424.md)

Reachable from entry: **yes**

## Imports

- `mlc/constants.ml` as `c` → [mlc/constants.ml](File-mlc-constants-ml-1024884042.md)

## Declarations

<a id="function-function-mlc-tools-arr-concat-chunks-balanced-function-arr-concat-chunks-balanced-parts-mlc-tools-ml-2039363910"></a>
### _arr_concat_chunks_balanced

```ml
function _arr_concat_chunks_balanced(parts)
```

Provide the arr concat chunks balanced compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parts` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1325)

<a id="function-function-mlc-tools-arr-copy-prefix-function-arr-copy-prefix-arr-n-mlc-tools-ml-728550065"></a>
### _arr_copy_prefix

```ml
function _arr_copy_prefix(arr, n)
```

Provide the arr copy prefix compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `n` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1222)

<a id="function-function-mlc-tools-arr-fill-function-arr-fill-n-fill-mlc-tools-ml-178556933"></a>
### _arr_fill

```ml
function _arr_fill(n, fill)
```

Provide the arr fill compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `n` | `dynamic` | — |  |
| `fill` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1213)

<a id="function-function-mlc-tools-arr-tail-from-array-function-arr-tail-from-array-arr-cap-mlc-tools-ml-1753405711"></a>
### _arr_tail_from_array

```ml
function _arr_tail_from_array(arr, cap)
```

Provide the arr tail from array compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `cap` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1262)

<a id="function-function-mlc-tools-arr-tail-new-function-arr-tail-new-cap-mlc-tools-ml-1217985466"></a>
### _arr_tail_new

```ml
function _arr_tail_new(cap)
```

Provide the arr tail new compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cap` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1254)

<a id="function-function-mlc-tools-arr-tail-to-array-function-arr-tail-to-array-tail-mlc-tools-ml-1979359264"></a>
### _arr_tail_to_array

```ml
function _arr_tail_to_array(tail)
```

Provide the arr tail to array compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tail` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1346)

<a id="function-function-mlc-tools-arr-unwrap-value-function-arr-unwrap-value-value-mlc-tools-ml-92285567"></a>
### _arr_unwrap_value

```ml
function _arr_unwrap_value(value)
```

Provide the arr unwrap value compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1242)

<a id="global-global-mlc-tools-arr-void-sentinel-arr-void-sentinel-mlc-tools-ml-2039927258"></a>
### _arr_void_sentinel

```ml
_arr_void_sentinel
```

Track arr void sentinel compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L127)

<a id="function-function-mlc-tools-arr-wrap-value-function-arr-wrap-value-value-mlc-tools-ml-1234776493"></a>
### _arr_wrap_value

```ml
function _arr_wrap_value(value)
```

Provide the arr wrap value compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1233)

<a id="global-global-mlc-tools-ast-bin-cap-ast-bin-cap-mlc-tools-ml-941289098"></a>
### _ast_bin_cap

```ml
_ast_bin_cap
```

Track ast bin cap compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L177)

<a id="global-global-mlc-tools-ast-bin-count-ast-bin-count-mlc-tools-ml-76033892"></a>
### _ast_bin_count

```ml
_ast_bin_count
```

Track ast bin count compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L175)

<a id="function-function-mlc-tools-ast-bin-ensure-function-ast-bin-ensure-need-mlc-tools-ml-1325192418"></a>
### _ast_bin_ensure

```ml
function _ast_bin_ensure(need)
```

Provide the ast bin ensure compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `need` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L247)

<a id="global-global-mlc-tools-ast-bin-file-ids-ast-bin-file-ids-mlc-tools-ml-73051726"></a>
### _ast_bin_file_ids

```ml
_ast_bin_file_ids
```

Track ast bin file ids compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L173)

<a id="global-global-mlc-tools-ast-bin-lefts-ast-bin-lefts-mlc-tools-ml-841676970"></a>
### _ast_bin_lefts

```ml
_ast_bin_lefts
```

Track ast bin lefts compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L165)

<a id="global-global-mlc-tools-ast-bin-op-ids-ast-bin-op-ids-mlc-tools-ml-2044148894"></a>
### _ast_bin_op_ids

```ml
_ast_bin_op_ids
```

Track ast bin op ids compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L169)

<a id="global-global-mlc-tools-ast-bin-positions-ast-bin-positions-mlc-tools-ml-1812288762"></a>
### _ast_bin_positions

```ml
_ast_bin_positions
```

Track ast bin positions compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L171)

<a id="global-global-mlc-tools-ast-bin-rights-ast-bin-rights-mlc-tools-ml-170189134"></a>
### _ast_bin_rights

```ml
_ast_bin_rights
```

Track ast bin rights compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L167)

<a id="global-global-mlc-tools-ast-filename-index-ast-filename-index-mlc-tools-ml-1541953594"></a>
### _ast_filename_index

```ml
_ast_filename_index
```

Track ast filename index compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L159)

<a id="global-global-mlc-tools-ast-filenames-ast-filenames-mlc-tools-ml-154345774"></a>
### _ast_filenames

```ml
_ast_filenames
```

Track ast filenames compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L157)

<a id="function-function-mlc-tools-ast-intern-function-ast-intern-index-map-values-text-mlc-tools-ml-385940662"></a>
### _ast_intern

```ml
function _ast_intern(index_map, values, text)
```

Provide the ast intern compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index_map` | `dynamic` | — |  |
| `values` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L317)

<a id="global-global-mlc-tools-ast-leaf-cap-ast-leaf-cap-mlc-tools-ml-503526226"></a>
### _ast_leaf_cap

```ml
_ast_leaf_cap
```

Track ast leaf cap compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L155)

<a id="global-global-mlc-tools-ast-leaf-count-ast-leaf-count-mlc-tools-ml-959413690"></a>
### _ast_leaf_count

```ml
_ast_leaf_count
```

Track ast leaf count compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L153)

<a id="function-function-mlc-tools-ast-leaf-ensure-function-ast-leaf-ensure-need-mlc-tools-ml-826634498"></a>
### _ast_leaf_ensure

```ml
function _ast_leaf_ensure(need)
```

Provide the ast leaf ensure compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `need` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L282)

<a id="global-global-mlc-tools-ast-leaf-file-ids-ast-leaf-file-ids-mlc-tools-ml-1959874838"></a>
### _ast_leaf_file_ids

```ml
_ast_leaf_file_ids
```

Track ast leaf file ids compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L149)

<a id="function-function-mlc-tools-ast-leaf-kind-id-function-ast-leaf-kind-id-kind-mlc-tools-ml-133961742"></a>
### _ast_leaf_kind_id

```ml
function _ast_leaf_kind_id(kind)
```

Provide the ast leaf kind id compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L328)

<a id="function-function-mlc-tools-ast-leaf-kind-name-function-ast-leaf-kind-name-kind-id-mlc-tools-ml-625233154"></a>
### _ast_leaf_kind_name

```ml
function _ast_leaf_kind_name(kind_id)
```

Provide the ast leaf kind name compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind_id` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L339)

<a id="global-global-mlc-tools-ast-leaf-kinds-ast-leaf-kinds-mlc-tools-ml-534973234"></a>
### _ast_leaf_kinds

```ml
_ast_leaf_kinds
```

Track ast leaf kinds compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L143)

<a id="global-global-mlc-tools-ast-leaf-payloads-ast-leaf-payloads-mlc-tools-ml-1910594698"></a>
### _ast_leaf_payloads

```ml
_ast_leaf_payloads
```

Track ast leaf payloads compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L145)

<a id="global-global-mlc-tools-ast-leaf-positions-ast-leaf-positions-mlc-tools-ml-471134074"></a>
### _ast_leaf_positions

```ml
_ast_leaf_positions
```

Track ast leaf positions compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L147)

<a id="global-global-mlc-tools-ast-leaf-symbol-ids-ast-leaf-symbol-ids-mlc-tools-ml-1339808842"></a>
### _ast_leaf_symbol_ids

```ml
_ast_leaf_symbol_ids
```

Track ast leaf symbol ids compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L151)

<a id="global-global-mlc-tools-ast-symbol-index-ast-symbol-index-mlc-tools-ml-1912089510"></a>
### _ast_symbol_index

```ml
_ast_symbol_index
```

Track ast symbol index compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L163)

<a id="global-global-mlc-tools-ast-symbols-ast-symbols-mlc-tools-ml-1838507476"></a>
### _ast_symbols

```ml
_ast_symbols
```

Track ast symbols compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L161)

<a id="function-function-mlc-tools-ast-u32-read-inline-function-ast-u32-read-buf-index-mlc-tools-ml-525585164"></a>
### _ast_u32_read

```ml
inline function _ast_u32_read(buf, index)
```

Reads a packed unsigned 32-bit value from an AST byte column.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buf` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L191)

<a id="function-function-mlc-tools-ast-u32-write-function-ast-u32-write-buf-index-value-mlc-tools-ml-2014669730"></a>
### _ast_u32_write

```ml
function _ast_u32_write(buf, index, value)
```

Provide the ast u32 write compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buf` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L181)

<a id="function-function-mlc-tools-bp-chunk-count-inline-function-bp-chunk-count-bp-mlc-tools-ml-2054420897"></a>
### _bp_chunk_count

```ml
inline function _bp_chunk_count(bp)
```

Provide the inline compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1781)

<a id="function-function-mlc-tools-bp-chunk-get-function-bp-chunk-get-bp-idx-mlc-tools-ml-1210112987"></a>
### _bp_chunk_get

```ml
function _bp_chunk_get(bp, idx)
```

Provide the bp chunk get compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — |  |
| `idx` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1801)

<a id="function-function-mlc-tools-bp-chunk-push-function-bp-chunk-push-bp-page-mlc-tools-ml-22882391"></a>
### _bp_chunk_push

```ml
function _bp_chunk_push(bp, page)
```

Provide the bp chunk push compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — |  |
| `page` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1842)

<a id="function-function-mlc-tools-bp-chunk-set-function-bp-chunk-set-bp-idx-page-mlc-tools-ml-702734724"></a>
### _bp_chunk_set

```ml
function _bp_chunk_set(bp, idx, page)
```

Provide the bp chunk set compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — |  |
| `idx` | `dynamic` | — |  |
| `page` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1826)

<a id="function-function-mlc-tools-bp-ensure-function-bp-ensure-bp-need-mlc-tools-ml-395796612"></a>
### _bp_ensure

```ml
function _bp_ensure(bp, need)
```

Provide the bp ensure compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — |  |
| `need` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1851)

<a id="function-function-mlc-tools-chunks-is-paged-inline-function-chunks-is-paged-chunks-mlc-tools-ml-133065431"></a>
### _chunks_is_paged

```ml
inline function _chunks_is_paged(chunks)
```

Provide the inline compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chunks` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1392)

<a id="function-function-mlc-tools-chunks-materialize-function-chunks-materialize-chunks-mlc-tools-ml-629470818"></a>
### _chunks_materialize

```ml
function _chunks_materialize(chunks)
```

Provide the chunks materialize compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chunks` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1465)

<a id="function-function-mlc-tools-chunks-paged-from-array-function-chunks-paged-from-array-chunks-mlc-tools-ml-1180778236"></a>
### _chunks_paged_from_array

```ml
function _chunks_paged_from_array(chunks)
```

Provide the chunks paged from array compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chunks` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1438)

<a id="function-function-mlc-tools-chunks-paged-new-function-chunks-paged-new-mlc-tools-ml-1761353226"></a>
### _chunks_paged_new

```ml
function _chunks_paged_new()
```

Provide the chunks paged new compiler utility operation.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1400)

<a id="function-function-mlc-tools-chunks-paged-push-function-chunks-paged-push-chunks-chunk-mlc-tools-ml-560933513"></a>
### _chunks_paged_push

```ml
function _chunks_paged_push(chunks, chunk)
```

Provide the chunks paged push compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chunks` | `dynamic` | — |  |
| `chunk` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1406)

<a id="function-function-mlc-tools-chunks-paged-tag-inline-function-chunks-paged-tag-mlc-tools-ml-312589883"></a>
### _chunks_paged_tag

```ml
inline function _chunks_paged_tag()
```

Provide the inline compiler utility operation.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1386)

<a id="function-function-mlc-tools-chunks-push-chunk-function-chunks-push-chunk-chunks-chunk-mlc-tools-ml-1249179521"></a>
### _chunks_push_chunk

```ml
function _chunks_push_chunk(chunks, chunk)
```

Provide the chunks push chunk compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chunks` | `dynamic` | — |  |
| `chunk` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1449)

<a id="extern_function-extern-function-mlc-tools-copy-native-bytes-extern-function-copy-native-bytes-destination-as-ptr-source-as-ptr-count-as-u64-from-kernel32-dll-symbol-rtlmovememory-returns-ptr-mlc-tools-ml-458524297"></a>
### _copy_native_bytes

```ml
extern function _copy_native_bytes(destination as ptr, source as ptr, count as u64) from "kernel32.dll" symbol "RtlMoveMemory" returns ptr
```

Provide the copy native bytes compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `destination` | `ptr` | — |  |
| `source` | `ptr` | — |  |
| `count` | `u64` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L44)

<a id="function-function-mlc-tools-f32-is-inf-inline-function-f32-is-inf-v-mlc-tools-ml-1561788679"></a>
### _f32_is_inf

```ml
inline function _f32_is_inf(v)
```

Provide the inline compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1106)

<a id="function-function-mlc-tools-f32-is-nan-inline-function-f32-is-nan-v-mlc-tools-ml-216685591"></a>
### _f32_is_nan

```ml
inline function _f32_is_nan(v)
```

Reports whether a float value is NaN.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1100)

<a id="function-function-mlc-tools-fm-hash-any-function-fm-hash-any-key-mlc-tools-ml-406633905"></a>
### _fm_hash_any

```ml
function _fm_hash_any(key)
```

Provide the fm hash any compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L723)

<a id="function-function-mlc-tools-fm-insert-no-resize-function-fm-insert-no-resize-mapv-key-value-mlc-tools-ml-1526516226"></a>
### _fm_insert_no_resize

```ml
function _fm_insert_no_resize(mapv, key, value)
```

Provide the fm insert no resize compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapv` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L895)

<a id="function-function-mlc-tools-fm-is-valid-function-fm-is-valid-mapv-mlc-tools-ml-1950842590"></a>
### _fm_is_valid

```ml
function _fm_is_valid(mapv)
```

Provide the fm is valid compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L779)

<a id="function-function-mlc-tools-fm-next-pow2-function-fm-next-pow2-n-mlc-tools-ml-582127918"></a>
### _fm_next_pow2

```ml
function _fm_next_pow2(n)
```

Provide the fm next pow2 compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `n` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L712)

<a id="function-function-mlc-tools-fm-probe-slot-function-fm-probe-slot-mapv-key-mlc-tools-ml-175160969"></a>
### _fm_probe_slot

```ml
function _fm_probe_slot(mapv, key)
```

Provide the fm probe slot compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapv` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L879)

<a id="function-function-mlc-tools-fm-rehash-function-fm-rehash-mapv-new-cap-mlc-tools-ml-1223263127"></a>
### _fm_rehash

```ml
function _fm_rehash(mapv, new_cap)
```

Provide the fm rehash compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapv` | `dynamic` | — |  |
| `new_cap` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L931)

<a id="function-function-mlc-tools-u64-mask-function-u64-mask-returns-int-mlc-tools-ml-205450594"></a>
### _u64_mask

```ml
function _u64_mask() returns int
```

Provide the u64 mask compiler utility operation.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L705)

<a id="function-function-mlc-tools-align-to-mod-function-align-to-mod-n-mod-target-mlc-tools-ml-61304145"></a>
### align_to_mod

```ml
function align_to_mod(n, mod, target)
```

Provide the align to mod compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `n` | `dynamic` | — | Value supplied for `n`. |
| `mod` | `dynamic` | — | Value supplied for `mod`. |
| `target` | `dynamic` | — | Value supplied for `target`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1024)

<a id="function-function-mlc-tools-align-up-function-align-up-n-as-int-a-as-int-returns-int-mlc-tools-ml-1373993483"></a>
### align_up

```ml
function align_up(n as int, a as int) returns int
```

Round n upward to the next power-of-two alignment boundary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `n` | `int` | — | Value supplied for `n`. |
| `a` | `int` | — | First input value. |


**Returns:** The resulting `int` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1016)

<a id="function-function-mlc-tools-arr-chunk-count-function-arr-chunk-count-builder-mlc-tools-ml-1500029251"></a>
### arr_chunk_count

```ml
function arr_chunk_count(builder)
```

Provide the arr chunk count compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `builder` | `dynamic` | — | Value supplied for `builder`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1748)

<a id="function-function-mlc-tools-arr-chunk-finish-function-arr-chunk-finish-builder-mlc-tools-ml-432097025"></a>
### arr_chunk_finish

```ml
function arr_chunk_finish(builder)
```

Provide the arr chunk finish compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `builder` | `dynamic` | — | Value supplied for `builder`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1740)

<a id="function-function-mlc-tools-arr-chunk-get-function-arr-chunk-get-builder-idx-defaultv-mlc-tools-ml-1773739253"></a>
### arr_chunk_get

```ml
function arr_chunk_get(builder, idx, defaultv)
```

Provide the arr chunk get compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `builder` | `dynamic` | — | Value supplied for `builder`. |
| `idx` | `dynamic` | — | Value supplied for `idx`. |
| `defaultv` | `dynamic` | — | Value supplied for `defaultv`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1757)

<a id="function-function-mlc-tools-arr-chunk-new-function-arr-chunk-new-cap-mlc-tools-ml-928944558"></a>
### arr_chunk_new

```ml
function arr_chunk_new(cap)
```

Create a chunked array builder with the requested tail capacity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cap` | `dynamic` | — | Value supplied for `cap`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1488)

<a id="function-function-mlc-tools-arr-chunk-push-function-arr-chunk-push-builder-value-mlc-tools-ml-4942530"></a>
### arr_chunk_push

```ml
function arr_chunk_push(builder, value)
```

Provide the arr chunk push compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `builder` | `dynamic` | — | Value supplied for `builder`. |
| `value` | `dynamic` | — | Value to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1536)

<a id="function-function-mlc-tools-arr-chunk-push-all-function-arr-chunk-push-all-builder-values-mlc-tools-ml-1045375835"></a>
### arr_chunk_push_all

```ml
function arr_chunk_push_all(builder, values)
```

Provide the arr chunk push all compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `builder` | `dynamic` | — | Value supplied for `builder`. |
| `values` | `dynamic` | — | Values to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1765)

<a id="function-function-mlc-tools-arr-chunk-tail-get-function-arr-chunk-tail-get-tail-idx-defaultv-mlc-tools-ml-814018366"></a>
### arr_chunk_tail_get

```ml
function arr_chunk_tail_get(tail, idx, defaultv)
```

Provide the arr chunk tail get compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tail` | `dynamic` | — | Value supplied for `tail`. |
| `idx` | `dynamic` | — | Value supplied for `idx`. |
| `defaultv` | `dynamic` | — | Value supplied for `defaultv`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1291)

<a id="function-function-mlc-tools-arr-chunk-tail-len-inline-function-arr-chunk-tail-len-tail-mlc-tools-ml-1369721375"></a>
### arr_chunk_tail_len

```ml
inline function arr_chunk_tail_len(tail)
```

Returns the number of live elements in a chunk tail.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tail` | `dynamic` | — | Value supplied for `tail`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1276)

<a id="function-function-mlc-tools-arr-chunk-tail-set-function-arr-chunk-tail-set-tail-idx-value-mlc-tools-ml-969163644"></a>
### arr_chunk_tail_set

```ml
function arr_chunk_tail_set(tail, idx, value)
```

Provide the arr chunk tail set compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tail` | `dynamic` | — | Value supplied for `tail`. |
| `idx` | `dynamic` | — | Value supplied for `idx`. |
| `value` | `dynamic` | — | Value to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1307)

<a id="function-function-mlc-tools-arr-chunked-count-function-arr-chunked-count-chunks-tail-cap-mlc-tools-ml-2019348862"></a>
### arr_chunked_count

```ml
function arr_chunked_count(chunks, tail, cap)
```

Provide the arr chunked count compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chunks` | `dynamic` | — | Value supplied for `chunks`. |
| `tail` | `dynamic` | — | Value supplied for `tail`. |
| `cap` | `dynamic` | — | Value supplied for `cap`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1672)

<a id="function-function-mlc-tools-arr-chunked-finish-function-arr-chunked-finish-chunks-tail-mlc-tools-ml-746745258"></a>
### arr_chunked_finish

```ml
function arr_chunked_finish(chunks, tail)
```

Provide the arr chunked finish compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chunks` | `dynamic` | — | Value supplied for `chunks`. |
| `tail` | `dynamic` | — | Value supplied for `tail`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1639)

<a id="function-function-mlc-tools-arr-chunked-get-function-arr-chunked-get-chunks-tail-idx-cap-defaultv-mlc-tools-ml-245430672"></a>
### arr_chunked_get

```ml
function arr_chunked_get(chunks, tail, idx, cap, defaultv)
```

Provide the arr chunked get compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chunks` | `dynamic` | — | Value supplied for `chunks`. |
| `tail` | `dynamic` | — | Value supplied for `tail`. |
| `idx` | `dynamic` | — | Value supplied for `idx`. |
| `cap` | `dynamic` | — | Value supplied for `cap`. |
| `defaultv` | `dynamic` | — | Value supplied for `defaultv`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1697)

<a id="function-function-mlc-tools-arr-chunked-groups-function-arr-chunked-groups-chunks-tail-mlc-tools-ml-456156734"></a>
### arr_chunked_groups

```ml
function arr_chunked_groups(chunks, tail)
```

Return the storage groups of a chunked sequence without flattening their elements. Hot consumers can traverse the small outer array and each fixed chunk directly, avoiding an indexed lookup and shape validation per value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chunks` | `dynamic` | — | Value supplied for `chunks`. |
| `tail` | `dynamic` | — | Value supplied for `tail`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1654)

<a id="function-function-mlc-tools-arr-chunked-push-function-arr-chunked-push-chunks-tail-value-cap-mlc-tools-ml-1590641689"></a>
### arr_chunked_push

```ml
function arr_chunked_push(chunks, tail, value, cap)
```

Provide the arr chunked push compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chunks` | `dynamic` | — | Value supplied for `chunks`. |
| `tail` | `dynamic` | — | Value supplied for `tail`. |
| `value` | `dynamic` | — | Value to process. |
| `cap` | `dynamic` | — | Value supplied for `cap`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1499)

<a id="function-function-mlc-tools-arr-drop-last-function-arr-drop-last-values-mlc-tools-ml-425046980"></a>
### arr_drop_last

```ml
function arr_drop_last(values)
```

Return every array element except the last one. The builtin slice() operates on bytes, so compiler data structures must use an explicit array copy.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | Values to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L53)

<a id="function-function-mlc-tools-arr-merge-chunk-groups-with-tail-function-arr-merge-chunk-groups-with-tail-groups-tail-arr-mlc-tools-ml-914227352"></a>
### arr_merge_chunk_groups_with_tail

```ml
function arr_merge_chunk_groups_with_tail(groups, tail_arr)
```

Flatten existing chunk groups plus the active tail directly into the final array. This avoids allocating and copying a temporary outer `groups + tail` array at every builder finalization.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `groups` | `dynamic` | — | Value supplied for `groups`. |
| `tail_arr` | `dynamic` | — | Value supplied for `tail_arr`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1577)

<a id="function-function-mlc-tools-arr-merge-chunks-balanced-function-arr-merge-chunks-balanced-chunks-mlc-tools-ml-1076984976"></a>
### arr_merge_chunks_balanced

```ml
function arr_merge_chunks_balanced(chunks)
```

Provide the arr merge chunks balanced compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chunks` | `dynamic` | — | Value supplied for `chunks`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1547)

<a id="function-function-mlc-tools-arr-merge-variadic-parts-function-arr-merge-variadic-parts-parts-mlc-tools-ml-1010500314"></a>
### arr_merge_variadic_parts

```ml
function arr_merge_variadic_parts(parts...)
```

Merge short-lived call-site parts without first allocating an outer array. The variadic tail is read-only and never escapes, so the compiler represents it as an immutable view over the caller's argument slots.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parts...` | `dynamic` | — | Value supplied for `parts`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1609)

<a id="function-function-mlc-tools-arr-vec-clear-function-arr-vec-clear-vec-mlc-tools-ml-1133666688"></a>
### arr_vec_clear

```ml
function arr_vec_clear(vec)
```

Reset a compiler-internal vector without discarding its capacity. Stale backing slots are intentionally left in place: compiler worklists normally reference the still-live AST, and overwriting the active prefix on the next pass is cheaper than clearing the complete high-water capacity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `vec` | `dynamic` | — | Value supplied for `vec`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L581)

<a id="function-function-mlc-tools-arr-vec-count-function-arr-vec-count-vec-mlc-tools-ml-2146057648"></a>
### arr_vec_count

```ml
function arr_vec_count(vec)
```

Provide the arr vec count compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `vec` | `dynamic` | — | Value supplied for `vec`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L564)

<a id="function-function-mlc-tools-arr-vec-count-trusted-inline-function-arr-vec-count-trusted-vec-returns-int-mlc-tools-ml-1209367981"></a>
### arr_vec_count_trusted

```ml
inline function arr_vec_count_trusted(vec) returns int
```

Trusted variants are used only after one nominal ArrayVector check. They retain logical bounds handling but omit redundant shape validation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `vec` | `dynamic` | — | Value supplied for `vec`. |


**Returns:** The resulting `int` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L572)

<a id="function-function-mlc-tools-arr-vec-finish-function-arr-vec-finish-vec-mlc-tools-ml-1093773168"></a>
### arr_vec_finish

```ml
function arr_vec_finish(vec)
```

Provide the arr vec finish compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `vec` | `dynamic` | — | Value supplied for `vec`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L690)

<a id="function-function-mlc-tools-arr-vec-from-array-function-arr-vec-from-array-values-extra-cap-mlc-tools-ml-728204753"></a>
### arr_vec_from_array

```ml
function arr_vec_from_array(values, extra_cap)
```

Provide the arr vec from array compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — | Values to process. |
| `extra_cap` | `dynamic` | — | Value supplied for `extra_cap`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L673)

<a id="function-function-mlc-tools-arr-vec-get-function-arr-vec-get-vec-idx-defaultv-mlc-tools-ml-1183303272"></a>
### arr_vec_get

```ml
function arr_vec_get(vec, idx, defaultv)
```

Provide the arr vec get compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `vec` | `dynamic` | — | Value supplied for `vec`. |
| `idx` | `dynamic` | — | Value supplied for `idx`. |
| `defaultv` | `dynamic` | — | Value supplied for `defaultv`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L606)

<a id="function-function-mlc-tools-arr-vec-get-trusted-inline-function-arr-vec-get-trusted-vec-idx-defaultv-mlc-tools-ml-1052342831"></a>
### arr_vec_get_trusted

```ml
inline function arr_vec_get_trusted(vec, idx, defaultv)
```

Returns a trusted array-vector element without shape validation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `vec` | `dynamic` | — | Value supplied for `vec`. |
| `idx` | `dynamic` | — | Value supplied for `idx`. |
| `defaultv` | `dynamic` | — | Value supplied for `defaultv`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L615)

<a id="function-function-mlc-tools-arr-vec-is-inline-function-arr-vec-is-value-returns-bool-mlc-tools-ml-1457786993"></a>
### arr_vec_is

```ml
inline function arr_vec_is(value) returns bool
```

ArrayVector is compiler-internal and always created by arr_vec_new. A nominal test avoids repeated guarded member probes on hot accesses while still rejecting unrelated structs deterministically.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value to process. |


**Returns:** The resulting `bool` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L550)

<a id="function-function-mlc-tools-arr-vec-new-function-arr-vec-new-initial-cap-mlc-tools-ml-1594685863"></a>
### arr_vec_new

```ml
function arr_vec_new(initial_cap)
```

Provide the arr vec new compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `initial_cap` | `dynamic` | — | Value supplied for `initial_cap`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L556)

<a id="function-function-mlc-tools-arr-vec-push-function-arr-vec-push-vec-value-mlc-tools-ml-78424841"></a>
### arr_vec_push

```ml
function arr_vec_push(vec, value)
```

Provide the arr vec push compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `vec` | `dynamic` | — | Value supplied for `vec`. |
| `value` | `dynamic` | — | Value to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L646)

<a id="function-function-mlc-tools-arr-vec-release-refs-function-arr-vec-release-refs-vec-mlc-tools-ml-1572066892"></a>
### arr_vec_release_refs

```ml
function arr_vec_release_refs(vec)
```

Reset a transient vector and remove every managed reference from its backing store. Ordinary arr_vec_clear deliberately retains stale slots for speed; compiler phase arenas must use this stronger form before a collection so a high-water worklist cannot keep already emitted AST nodes alive.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `vec` | `dynamic` | — | Value supplied for `vec`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L590)

<a id="function-function-mlc-tools-arr-vec-set-function-arr-vec-set-vec-idx-value-mlc-tools-ml-1560746662"></a>
### arr_vec_set

```ml
function arr_vec_set(vec, idx, value)
```

Provide the arr vec set compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `vec` | `dynamic` | — | Value supplied for `vec`. |
| `idx` | `dynamic` | — | Value supplied for `idx`. |
| `value` | `dynamic` | — | Value to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L625)

<a id="function-function-mlc-tools-arr-vec-set-trusted-inline-function-arr-vec-set-trusted-vec-idx-value-mlc-tools-ml-1365473039"></a>
### arr_vec_set_trusted

```ml
inline function arr_vec_set_trusted(vec, idx, value)
```

Updates a trusted array-vector element without shape validation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `vec` | `dynamic` | — | Value supplied for `vec`. |
| `idx` | `dynamic` | — | Value supplied for `idx`. |
| `value` | `dynamic` | — | Value to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L635)

- [mlc.tools.ArrayChunkBuilder](Type-mlc-tools-arraychunkbuilder-1938150295.md) — struct
- [mlc.tools.ArrayChunkTail](Type-mlc-tools-arraychunktail-561106194.md) — struct
- [mlc.tools.ArrayChunkVoidSentinel](Type-mlc-tools-arraychunkvoidsentinel-571833950.md) — struct
- [mlc.tools.ArrayVector](Type-mlc-tools-arrayvector-1058682992.md) — struct
<a id="function-function-mlc-tools-ast-arena-release-function-ast-arena-release-mlc-tools-ml-867495298"></a>
### ast_arena_release

```ml
function ast_arena_release()
```

Drop every compilation-owned compact AST column and intern table. This is a bulk ownership boundary: callers must release only after code generation no longer holds or dereferences NodeIds from this arena.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L197)

<a id="constant-constant-mlc-tools-ast-bin-handle-base-const-ast-bin-handle-base-1073741824-mlc-tools-ml-699262622"></a>
### AST_BIN_HANDLE_BASE

```ml
const AST_BIN_HANDLE_BASE = 1073741824
```

Track ast bin handle base.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L140)

<a id="function-function-mlc-tools-ast-bin-new-function-ast-bin-new-left-op-right-pos-filename-mlc-tools-ml-1134644039"></a>
### ast_bin_new

```ml
function ast_bin_new(left, op, right, pos, filename)
```

Binary expressions are the most frequent composite AST node. Store their children and metadata in a typed structure-of-arrays arena while retaining the same accessors for compiler-created legacy structs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | Left input value. |
| `op` | `dynamic` | — | Value supplied for `op`. |
| `right` | `dynamic` | — | Right input value. |
| `pos` | `dynamic` | — | Value supplied for `pos`. |
| `filename` | `dynamic` | — | Value supplied for `filename`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L400)

<a id="function-function-mlc-tools-ast-filename-function-ast-filename-node-mlc-tools-ml-2050532786"></a>
### ast_filename

```ml
function ast_filename(node)
```

Provide the ast filename compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — | Value supplied for `node`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L498)

<a id="function-function-mlc-tools-ast-is-bin-inline-function-ast-is-bin-node-mlc-tools-ml-816544171"></a>
### ast_is_bin

```ml
inline function ast_is_bin(node)
```

Reports whether a value is a compact binary-expression handle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — | Value supplied for `node`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L442)

<a id="function-function-mlc-tools-ast-is-leaf-inline-function-ast-is-leaf-node-mlc-tools-ml-579049887"></a>
### ast_is_leaf

```ml
inline function ast_is_leaf(node)
```

Reports whether a value is a compact leaf-AST handle.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — | Value supplied for `node`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L434)

<a id="function-function-mlc-tools-ast-is-node-function-ast-is-node-node-mlc-tools-ml-416585694"></a>
### ast_is_node

```ml
function ast_is_node(node)
```

Provide the ast is node compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — | Value supplied for `node`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L450)

<a id="function-function-mlc-tools-ast-kind-function-ast-kind-node-mlc-tools-ml-1801568570"></a>
### ast_kind

```ml
function ast_kind(node)
```

Provide the ast kind compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — | Value supplied for `node`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L457)

<a id="constant-constant-mlc-tools-ast-leaf-bool-const-ast-leaf-bool-3-mlc-tools-ml-457078068"></a>
### AST_LEAF_BOOL

```ml
const AST_LEAF_BOOL = 3
```

Track ast leaf bool.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L134)

<a id="function-function-mlc-tools-ast-leaf-new-function-ast-leaf-new-kind-value-pos-filename-mlc-tools-ml-1436561924"></a>
### ast_leaf_new

```ml
function ast_leaf_new(kind, value, pos, filename)
```

Provide the ast leaf new compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — | Value supplied for `kind`. |
| `value` | `dynamic` | — | Value to process. |
| `pos` | `dynamic` | — | Value supplied for `pos`. |
| `filename` | `dynamic` | — | Value supplied for `filename`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L353)

<a id="constant-constant-mlc-tools-ast-leaf-num-const-ast-leaf-num-1-mlc-tools-ml-1972280032"></a>
### AST_LEAF_NUM

```ml
const AST_LEAF_NUM = 1
```

Compact arena for immutable expression leaves. Negative integers are stable NodeIds; ordinary non-negative MiniLang values therefore never collide with compiler AST handles. The structure-of-arrays layout keeps source locations, variable symbols and kinds out of individual managed structs.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L130)

<a id="function-function-mlc-tools-ast-leaf-reset-function-ast-leaf-reset-mlc-tools-ml-156576674"></a>
### ast_leaf_reset

```ml
function ast_leaf_reset()
```

Provide the ast leaf reset compiler utility operation.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L234)

<a id="function-function-mlc-tools-ast-leaf-stats-function-ast-leaf-stats-mlc-tools-ml-1006204234"></a>
### ast_leaf_stats

```ml
function ast_leaf_stats()
```

Provide the ast leaf stats compiler utility operation.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L540)

<a id="constant-constant-mlc-tools-ast-leaf-str-const-ast-leaf-str-2-mlc-tools-ml-366944421"></a>
### AST_LEAF_STR

```ml
const AST_LEAF_STR = 2
```

Track ast leaf str.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L132)

<a id="constant-constant-mlc-tools-ast-leaf-var-const-ast-leaf-var-5-mlc-tools-ml-1720761230"></a>
### AST_LEAF_VAR

```ml
const AST_LEAF_VAR = 5
```

Track ast leaf var.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L138)

<a id="constant-constant-mlc-tools-ast-leaf-void-const-ast-leaf-void-4-mlc-tools-ml-1244132631"></a>
### AST_LEAF_VOID

```ml
const AST_LEAF_VOID = 4
```

Track ast leaf void.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L136)

<a id="function-function-mlc-tools-ast-left-function-ast-left-node-mlc-tools-ml-2028300670"></a>
### ast_left

```ml
function ast_left(node)
```

Provide the ast left compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — | Value supplied for `node`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L513)

<a id="function-function-mlc-tools-ast-name-function-ast-name-node-mlc-tools-ml-1877619406"></a>
### ast_name

```ml
function ast_name(node)
```

Provide the ast name compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — | Value supplied for `node`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L476)

<a id="function-function-mlc-tools-ast-op-function-ast-op-node-mlc-tools-ml-26669406"></a>
### ast_op

```ml
function ast_op(node)
```

Provide the ast op compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — | Value supplied for `node`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L529)

<a id="function-function-mlc-tools-ast-pos-function-ast-pos-node-mlc-tools-ml-1507811196"></a>
### ast_pos

```ml
function ast_pos(node)
```

Provide the ast pos compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — | Value supplied for `node`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L489)

<a id="function-function-mlc-tools-ast-right-function-ast-right-node-mlc-tools-ml-1380446152"></a>
### ast_right

```ml
function ast_right(node)
```

Provide the ast right compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — | Value supplied for `node`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L521)

<a id="function-function-mlc-tools-ast-value-function-ast-value-node-mlc-tools-ml-792916190"></a>
### ast_value

```ml
function ast_value(node)
```

Provide the ast value compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — | Value supplied for `node`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L468)

<a id="function-function-mlc-tools-byte-pages-append-function-byte-pages-append-bp-src-mlc-tools-ml-1426180094"></a>
### byte_pages_append

```ml
function byte_pages_append(bp, src)
```

Provide the byte pages append compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — | Value supplied for `bp`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1905)

<a id="function-function-mlc-tools-byte-pages-append-string-function-byte-pages-append-string-bp-text-mlc-tools-ml-1531761367"></a>
### byte_pages_append_string

```ml
function byte_pages_append_string(bp, text)
```

Append a string's UTF-8 payload without first allocating an equally large temporary bytes value. String length is stored in bytes by the runtime, and the payload immediately follows the common eight-byte object header.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — | Value supplied for `bp`. |
| `text` | `dynamic` | — | Text to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1936)

<a id="function-function-mlc-tools-byte-pages-append-u16-function-byte-pages-append-u16-bp-value-mlc-tools-ml-8321011"></a>
### byte_pages_append_u16

```ml
function byte_pages_append_u16(bp, value)
```

Append one little-endian 16-bit value without a temporary bytes object.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — | Value supplied for `bp`. |
| `value` | `dynamic` | — | Value to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1966)

<a id="function-function-mlc-tools-byte-pages-append-u32-function-byte-pages-append-u32-bp-value-mlc-tools-ml-903967159"></a>
### byte_pages_append_u32

```ml
function byte_pages_append_u32(bp, value)
```

Append one little-endian 32-bit value without allocating a temporary four-byte object. Object serialization writes several integers per label and relocation, so avoiding that allocation materially reduces allocator and GC traffic on large programs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — | Value supplied for `bp`. |
| `value` | `dynamic` | — | Value to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1991)

<a id="function-function-mlc-tools-byte-pages-append-u64-function-byte-pages-append-u64-bp-value-mlc-tools-ml-753763469"></a>
### byte_pages_append_u64

```ml
function byte_pages_append_u64(bp, value)
```

Append one little-endian 64-bit value. MiniLang integers carry 61 payload bits; the writer deliberately preserves their sign-extended bit pattern.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — | Value supplied for `bp`. |
| `value` | `dynamic` | — | Value to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L2022)

<a id="function-function-mlc-tools-byte-pages-get-byte-function-byte-pages-get-byte-bp-idx-defaultv-mlc-tools-ml-327960060"></a>
### byte_pages_get_byte

```ml
function byte_pages_get_byte(bp, idx, defaultv)
```

Provide the byte pages get byte compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — | Value supplied for `bp`. |
| `idx` | `dynamic` | — | Value supplied for `idx`. |
| `defaultv` | `dynamic` | — | Value supplied for `defaultv`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L2135)

<a id="function-function-mlc-tools-byte-pages-len-function-byte-pages-len-bp-mlc-tools-ml-1492352224"></a>
### byte_pages_len

```ml
function byte_pages_len(bp)
```

Provide the byte pages len compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — | Value supplied for `bp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1863)

<a id="function-function-mlc-tools-byte-pages-new-function-byte-pages-new-mlc-tools-ml-454273826"></a>
### byte_pages_new

```ml
function byte_pages_new()
```

Create an empty paged byte buffer.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1775)

<a id="function-function-mlc-tools-byte-pages-page-function-byte-pages-page-bp-page-index-mlc-tools-ml-1020656758"></a>
### byte_pages_page

```ml
function byte_pages_page(bp, page_index)
```

Provide the byte pages page compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — | Value supplied for `bp`. |
| `page_index` | `dynamic` | — | Value supplied for `page_index`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1883)

<a id="function-function-mlc-tools-byte-pages-page-count-function-byte-pages-page-count-bp-mlc-tools-ml-818479086"></a>
### byte_pages_page_count

```ml
function byte_pages_page_count(bp)
```

Expose read-only pages to streaming serializers. The final page may contain spare capacity; byte_pages_page_used() reports the exact writable prefix.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — | Value supplied for `bp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1871)

<a id="function-function-mlc-tools-byte-pages-page-used-function-byte-pages-page-used-bp-page-index-mlc-tools-ml-64526912"></a>
### byte_pages_page_used

```ml
function byte_pages_page_used(bp, page_index)
```

Provide the byte pages page used compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — | Value supplied for `bp`. |
| `page_index` | `dynamic` | — | Value supplied for `page_index`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1892)

<a id="function-function-mlc-tools-byte-pages-set-byte-function-byte-pages-set-byte-bp-idx-value-mlc-tools-ml-1066816434"></a>
### byte_pages_set_byte

```ml
function byte_pages_set_byte(bp, idx, value)
```

Provide the byte pages set byte compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — | Value supplied for `bp`. |
| `idx` | `dynamic` | — | Value supplied for `idx`. |
| `value` | `dynamic` | — | Value to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L2115)

<a id="function-function-mlc-tools-byte-pages-to-bytes-function-byte-pages-to-bytes-bp-mlc-tools-ml-1090167482"></a>
### byte_pages_to_bytes

```ml
function byte_pages_to_bytes(bp)
```

Provide the byte pages to bytes compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — | Value supplied for `bp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L2087)

<a id="function-function-mlc-tools-byte-pages-write-at-function-byte-pages-write-at-bp-offset-src-mlc-tools-ml-949290513"></a>
### byte_pages_write_at

```ml
function byte_pages_write_at(bp, offset, src)
```

Provide the byte pages write at compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — | Value supplied for `bp`. |
| `offset` | `dynamic` | — | Zero-based starting offset. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L2055)

- [mlc.tools.BytePages](Type-mlc-tools-bytepages-121699952.md) — struct
<a id="function-function-mlc-tools-enc-bool-function-enc-bool-b-mlc-tools-ml-1930511380"></a>
### enc_bool

```ml
function enc_bool(b)
```

Provide the enc bool compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `b` | `dynamic` | — | Second input value. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1077)

<a id="function-function-mlc-tools-enc-enum-function-enc-enum-enum-id-variant-id-mlc-tools-ml-1300503830"></a>
### enc_enum

```ml
function enc_enum(enum_id, variant_id)
```

Provide the enc enum compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `enum_id` | `dynamic` | — | Value supplied for `enum_id`. |
| `variant_id` | `dynamic` | — | Value supplied for `variant_id`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1093)

<a id="function-function-mlc-tools-enc-int-function-enc-int-x-as-int-returns-int-mlc-tools-ml-202911073"></a>
### enc_int

```ml
function enc_int(x as int) returns int
```

Provide the enc int compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `int` | — | Value supplied for `x`. |


**Returns:** The resulting `int` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1071)

<a id="function-function-mlc-tools-enc-void-function-enc-void-returns-int-mlc-tools-ml-1182839604"></a>
### enc_void

```ml
function enc_void() returns int
```

Provide the enc void compiler utility operation.


**Returns:** The resulting `int` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1086)

<a id="function-function-mlc-tools-extern-library-label-token-function-extern-library-label-token-library-mlc-tools-ml-919117945"></a>
### extern_library_label_token

```ml
function extern_library_label_token(library)
```

Encode the exact UTF-8 library spelling into a reversible assembler-label token. Paths and punctuation must not collapse to one dynamic-import slot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `library` | `dynamic` | — | Value supplied for `library`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L26)

- [mlc.tools.FastMap](Type-mlc-tools-fastmap-534878990.md) — struct
<a id="function-function-mlc-tools-fastmap-clear-function-fastmap-clear-mapv-mlc-tools-ml-1478478050"></a>
### fastmap_clear

```ml
function fastmap_clear(mapv)
```

Provide the fastmap clear compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapv` | `dynamic` | — | Value supplied for `mapv`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L823)

<a id="function-function-mlc-tools-fastmap-get-function-fastmap-get-mapv-key-defaultv-mlc-tools-ml-81050054"></a>
### fastmap_get

```ml
function fastmap_get(mapv, key, defaultv)
```

Provide the fastmap get compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapv` | `dynamic` | — | Value supplied for `mapv`. |
| `key` | `dynamic` | — | Value supplied for `key`. |
| `defaultv` | `dynamic` | — | Value supplied for `defaultv`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L960)

<a id="function-function-mlc-tools-fastmap-has-function-fastmap-has-mapv-key-mlc-tools-ml-1099750807"></a>
### fastmap_has

```ml
function fastmap_has(mapv, key)
```

Provide the fastmap has compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapv` | `dynamic` | — | Value supplied for `mapv`. |
| `key` | `dynamic` | — | Value supplied for `key`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L977)

<a id="function-function-mlc-tools-fastmap-items-function-fastmap-items-mapv-mlc-tools-ml-1300381568"></a>
### fastmap_items

```ml
function fastmap_items(mapv)
```

Provide the fastmap items compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapv` | `dynamic` | — | Value supplied for `mapv`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1001)

<a id="function-function-mlc-tools-fastmap-new-function-fastmap-new-initial-cap-mlc-tools-ml-1434987787"></a>
### fastmap_new

```ml
function fastmap_new(initial_cap)
```

FastMap operations use deterministic hashing and linear probing.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `initial_cap` | `dynamic` | — | Value supplied for `initial_cap`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L794)

<a id="function-function-mlc-tools-fastmap-release-refs-function-fastmap-release-refs-mapv-mlc-tools-ml-849986326"></a>
### fastmap_release_refs

```ml
function fastmap_release_refs(mapv)
```

Reset a transient map including stale generations. Epoch-only clearing is O(1), but its old key/value cells remain visible to the tracing collector. Batch arenas call this at ownership boundaries, trading one linear sweep for prompt reclamation of large analysis graphs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapv` | `dynamic` | — | Value supplied for `mapv`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L844)

<a id="function-function-mlc-tools-fastmap-set-function-fastmap-set-mapv-key-value-mlc-tools-ml-480505188"></a>
### fastmap_set

```ml
function fastmap_set(mapv, key, value)
```

Provide the fastmap set compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapv` | `dynamic` | — | Value supplied for `mapv`. |
| `key` | `dynamic` | — | Value supplied for `key`. |
| `value` | `dynamic` | — | Value to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L947)

<a id="function-function-mlc-tools-fastmap-size-function-fastmap-size-mapv-mlc-tools-ml-1083147314"></a>
### fastmap_size

```ml
function fastmap_size(mapv)
```

Provide the fastmap size compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapv` | `dynamic` | — | Value supplied for `mapv`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L993)

<a id="function-function-mlc-tools-fastmap-track-refs-function-fastmap-track-refs-mapv-mlc-tools-ml-1619771010"></a>
### fastmap_track_refs

```ml
function fastmap_track_refs(mapv)
```

Enable precise reference release only for phase-local maps. Production symbol and label indexes retain the O(1) insertion path and do not pay for a touched-slot side vector they never need to reset strongly.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapv` | `dynamic` | — | Value supplied for `mapv`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L804)

<a id="function-function-mlc-tools-try-enc-float-immediate-function-try-enc-float-immediate-x-mlc-tools-ml-1655021100"></a>
### try_enc_float_immediate

```ml
function try_enc_float_immediate(x)
```

Provide the try enc float immediate compiler utility operation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | Value supplied for `x`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1115)

<a id="function-function-mlc-tools-u16-function-u16-x-mlc-tools-ml-1877433222"></a>
### u16

```ml
function u16(x)
```

Serialize an unsigned 16-bit value in little-endian order.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | Value supplied for `x`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1032)

<a id="function-function-mlc-tools-u32-function-u32-x-mlc-tools-ml-1177186146"></a>
### u32

```ml
function u32(x)
```

Serialize an unsigned 32-bit value in little-endian order.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | Value supplied for `x`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1042)

<a id="function-function-mlc-tools-u64-function-u64-x-mlc-tools-ml-1374782380"></a>
### u64

```ml
function u64(x)
```

Serialize the low 64 bits of a value in little-endian order.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — | Value supplied for `x`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L1054)
