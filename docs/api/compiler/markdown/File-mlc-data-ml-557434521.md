# `mlc/data.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc data package.

Package: [`mlc.data`](Package-mlc-data-1782371337.md)

Reachable from entry: **yes**

## Imports

- `mlc/constants.ml` as `c` → [mlc/constants.ml](File-mlc-constants-ml-1024884042.md)
- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)

## Declarations

<a id="function-function-mlc-data-buf-append-function-buf-append-db-b-mlc-data-ml-20902164"></a>
### _buf_append

```ml
function _buf_append(db, b)
```

Implements buf append.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L604)

<a id="function-function-mlc-data-buf-ensure-function-buf-ensure-db-need-mlc-data-ml-1065897560"></a>
### _buf_ensure

```ml
function _buf_ensure(db, need)
```

Implements buf ensure.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — |  |
| `need` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L581)

<a id="function-function-mlc-data-buf-used-function-buf-used-db-mlc-data-ml-1527058378"></a>
### _buf_used

```ml
function _buf_used(db)
```

Implements buf used.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L567)

<a id="function-function-mlc-data-data-upsert-label-function-data-upsert-label-db-name-offset-mlc-data-ml-1632477370"></a>
### _data_upsert_label

```ml
function _data_upsert_label(db, name, offset)
```

Implements data upsert label.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L297)

<a id="function-function-mlc-data-find-data-label-index-function-find-data-label-index-labels-name-mlc-data-ml-1927555520"></a>
### _find_data_label_index

```ml
function _find_data_label_index(labels, name)
```

Returns find data label index.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `labels` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L114)

<a id="function-function-mlc-data-find-pool-entry-function-find-pool-entry-pool-key-mlc-data-ml-1472859613"></a>
### _find_pool_entry

```ml
function _find_pool_entry(pool, key)
```

Returns find pool entry.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pool` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L160)

<a id="function-function-mlc-data-find-range-label-index-function-find-range-label-index-labels-name-mlc-data-ml-1927866608"></a>
### _find_range_label_index

```ml
function _find_range_label_index(labels, name)
```

Returns find range label index.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `labels` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L137)

<a id="function-function-mlc-data-float-to-f64le-function-float-to-f64le-value-mlc-data-ml-83527747"></a>
### _float_to_f64le

```ml
function _float_to_f64le(value)
```

Implements float to f64le.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L784)

<a id="function-function-mlc-data-rdata-intern-raw-function-rdata-intern-raw-rb-name-raw-mlc-data-ml-860567281"></a>
### _rdata_intern_raw

```ml
function _rdata_intern_raw(rb, name, raw)
```

Implements rdata intern raw.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `raw` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L712)

<a id="function-function-mlc-data-rdata-upsert-label-function-rdata-upsert-label-rb-name-offset-length-mlc-data-ml-1319191444"></a>
### _rdata_upsert_label

```ml
function _rdata_upsert_label(rb, name, offset, length)
```

Implements rdata upsert label.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `length` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L548)

<a id="function-function-mlc-data-upsert-data-label-function-upsert-data-label-labels-name-offset-mlc-data-ml-2030093549"></a>
### _upsert_data_label

```ml
function _upsert_data_label(labels, name, offset)
```

Implements upsert data label.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `labels` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L126)

<a id="function-function-mlc-data-upsert-range-label-function-upsert-range-label-labels-name-offset-length-mlc-data-ml-1508479519"></a>
### _upsert_range_label

```ml
function _upsert_range_label(labels, name, offset, length)
```

Implements upsert range label.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `labels` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |
| `length` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L149)

<a id="function-function-mlc-data-bss-pad-align-function-bss-pad-align-bb-align-mlc-data-ml-515523841"></a>
### bss_pad_align

```ml
function bss_pad_align(bb, align)
```

Implements bss pad align.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bb` | `dynamic` | — | Value supplied for `bb`. |
| `align` | `dynamic` | — | Value supplied for `align`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L674)

<a id="function-function-mlc-data-bss-reserve-function-bss-reserve-bb-name-size-align-mlc-data-ml-887598105"></a>
### bss_reserve

```ml
function bss_reserve(bb, name, size, align)
```

Implements bss reserve.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bb` | `dynamic` | — | Value supplied for `bb`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `size` | `dynamic` | — | Value supplied for `size`. |
| `align` | `dynamic` | — | Value supplied for `align`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L688)

- [mlc.data.BssBuilder](Type-mlc-data-bssbuilder-146145698.md) — struct
<a id="function-function-mlc-data-data-add-abs64-patch-function-data-add-abs64-patch-db-offset-target-mlc-data-ml-1447675864"></a>
### data_add_abs64_patch

```ml
function data_add_abs64_patch(db, offset, target)
```

Implements data add abs64 patch.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — | Value supplied for `db`. |
| `offset` | `dynamic` | — | Zero-based starting offset. |
| `target` | `dynamic` | — | Value supplied for `target`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L652)

<a id="function-function-mlc-data-data-add-bytes-function-data-add-bytes-db-name-b-mlc-data-ml-415684585"></a>
### data_add_bytes

```ml
function data_add_bytes(db, name, b)
```

Implements data add bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — | Value supplied for `db`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `b` | `dynamic` | — | Second input value. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L641)

<a id="function-function-mlc-data-data-add-u32-function-data-add-u32-db-name-value-mlc-data-ml-291177912"></a>
### data_add_u32

```ml
function data_add_u32(db, name, value)
```

Implements data add u32.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — | Value supplied for `db`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `value` | `dynamic` | — | Value to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L619)

<a id="function-function-mlc-data-data-add-u64-function-data-add-u64-db-name-value-mlc-data-ml-569087744"></a>
### data_add_u64

```ml
function data_add_u64(db, name, value)
```

Implements data add u64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — | Value supplied for `db`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `value` | `dynamic` | — | Value to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L630)

<a id="function-function-mlc-data-data-clear-labels-function-data-clear-labels-db-mlc-data-ml-1216296822"></a>
### data_clear_labels

```ml
function data_clear_labels(db)
```

Implements data clear labels.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — | Value supplied for `db`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L291)

<a id="function-function-mlc-data-data-clear-patches-function-data-clear-patches-db-mlc-data-ml-1447455518"></a>
### data_clear_patches

```ml
function data_clear_patches(db)
```

Implements data clear patches.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — | Value supplied for `db`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L375)

<a id="function-function-mlc-data-data-get-labels-function-data-get-labels-db-mlc-data-ml-566606188"></a>
### data_get_labels

```ml
function data_get_labels(db)
```

Implements data get labels.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — | Value supplied for `db`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L204)

<a id="function-function-mlc-data-data-get-labels-after-function-data-get-labels-after-db-start-index-mlc-data-ml-1658270713"></a>
### data_get_labels_after

```ml
function data_get_labels_after(db, start_index)
```

Implements data get labels after.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — | Value supplied for `db`. |
| `start_index` | `dynamic` | — | Value supplied for `start_index`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L214)

<a id="function-function-mlc-data-data-get-patches-function-data-get-patches-db-mlc-data-ml-852810518"></a>
### data_get_patches

```ml
function data_get_patches(db)
```

Implements data get patches.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — | Value supplied for `db`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L325)

<a id="function-function-mlc-data-data-get-patches-after-function-data-get-patches-after-db-start-index-mlc-data-ml-176177417"></a>
### data_get_patches_after

```ml
function data_get_patches_after(db, start_index)
```

Implements data get patches after.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — | Value supplied for `db`. |
| `start_index` | `dynamic` | — | Value supplied for `start_index`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L344)

<a id="function-function-mlc-data-data-has-label-function-data-has-label-db-as-struct-name-as-string-returns-bool-mlc-data-ml-1847281964"></a>
### data_has_label

```ml
function data_has_label(db as struct, name as string) returns bool
```

Implements data has label.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `struct` | — | Value supplied for `db`. |
| `name` | `string` | — | Name of the requested item. |


**Returns:** The resulting `bool` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L264)

<a id="function-function-mlc-data-data-label-count-function-data-label-count-db-mlc-data-ml-1151563258"></a>
### data_label_count

```ml
function data_label_count(db)
```

Implements data label count.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — | Value supplied for `db`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L231)

<a id="function-function-mlc-data-data-label-record-function-data-label-record-db-name-mlc-data-ml-2142507393"></a>
### data_label_record

```ml
function data_label_record(db, name)
```

Implements data label record.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — | Value supplied for `db`. |
| `name` | `dynamic` | — | Name of the requested item. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L240)

<a id="function-function-mlc-data-data-pad-align-function-data-pad-align-db-align-mlc-data-ml-1631589451"></a>
### data_pad_align

```ml
function data_pad_align(db, align)
```

Implements data pad align.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — | Value supplied for `db`. |
| `align` | `dynamic` | — | Value supplied for `align`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L661)

<a id="function-function-mlc-data-data-patch-count-function-data-patch-count-db-mlc-data-ml-1095699350"></a>
### data_patch_count

```ml
function data_patch_count(db)
```

Implements data patch count.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — | Value supplied for `db`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L334)

<a id="function-function-mlc-data-data-set-labels-function-data-set-labels-db-labels-mlc-data-ml-1702903773"></a>
### data_set_labels

```ml
function data_set_labels(db, labels)
```

Implements data set labels.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — | Value supplied for `db`. |
| `labels` | `dynamic` | — | Value supplied for `labels`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L271)

<a id="function-function-mlc-data-data-set-patches-function-data-set-patches-db-patches-mlc-data-ml-1103417598"></a>
### data_set_patches

```ml
function data_set_patches(db, patches)
```

Implements data set patches.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — | Value supplied for `db`. |
| `patches` | `dynamic` | — | Value supplied for `patches`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L362)

- [mlc.data.DataBuilder](Type-mlc-data-databuilder-1524220800.md) — struct
- [mlc.data.DataLabel](Type-mlc-data-datalabel-1280347453.md) — struct
- [mlc.data.DataPatch](Type-mlc-data-datapatch-341029609.md) — struct
- [mlc.data.DataRangeLabel](Type-mlc-data-datarangelabel-1620708168.md) — struct
<a id="function-function-mlc-data-newbssbuilder-function-newbssbuilder-mlc-data-ml-1108300550"></a>
### newBssBuilder

```ml
function newBssBuilder()
```

Create an empty zero-initialized-data builder.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L314)

<a id="function-function-mlc-data-newdatabuilder-function-newdatabuilder-mlc-data-ml-1281909056"></a>
### newDataBuilder

```ml
function newDataBuilder()
```

Create an empty writable-data builder with production-sized capacities.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L198)

<a id="function-function-mlc-data-newrdatabuilder-function-newrdatabuilder-mlc-data-ml-1676082786"></a>
### newRDataBuilder

```ml
function newRDataBuilder()
```

Create an empty read-only-data builder and its constant pools.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L319)

- [mlc.data.PoolEntry](Type-mlc-data-poolentry-400419453.md) — struct
<a id="function-function-mlc-data-rdata-add-abs64-patch-function-rdata-add-abs64-patch-rb-offset-target-mlc-data-ml-1320401438"></a>
### rdata_add_abs64_patch

```ml
function rdata_add_abs64_patch(rb, offset, target)
```

Implements rdata add abs64 patch.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |
| `offset` | `dynamic` | — | Zero-based starting offset. |
| `target` | `dynamic` | — | Value supplied for `target`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L776)

<a id="function-function-mlc-data-rdata-add-bytes-function-rdata-add-bytes-rb-name-raw-mlc-data-ml-2106952383"></a>
### rdata_add_bytes

```ml
function rdata_add_bytes(rb, name, raw)
```

Implements rdata add bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `raw` | `dynamic` | — | Value supplied for `raw`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L755)

<a id="function-function-mlc-data-rdata-add-bytes-unique-function-rdata-add-bytes-unique-rb-name-raw-mlc-data-ml-2040410875"></a>
### rdata_add_bytes_unique

```ml
function rdata_add_bytes_unique(rb, name, raw)
```

Implements rdata add bytes unique.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `raw` | `dynamic` | — | Value supplied for `raw`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L763)

<a id="function-function-mlc-data-rdata-add-obj-float-function-rdata-add-obj-float-rb-name-value-mlc-data-ml-609974008"></a>
### rdata_add_obj_float

```ml
function rdata_add_obj_float(rb, name, value)
```

Implements rdata add obj float.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `value` | `dynamic` | — | Value to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L923)

<a id="function-function-mlc-data-rdata-add-obj-string-function-rdata-add-obj-string-rb-name-text-mlc-data-ml-745948924"></a>
### rdata_add_obj_string

```ml
function rdata_add_obj_string(rb, name, text)
```

Implements rdata add obj string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `text` | `dynamic` | — | Text to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L867)

<a id="function-function-mlc-data-rdata-add-obj-string-unique-function-rdata-add-obj-string-unique-rb-name-text-mlc-data-ml-550307040"></a>
### rdata_add_obj_string_unique

```ml
function rdata_add_obj_string_unique(rb, name, text)
```

Implements rdata add obj string unique.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `text` | `dynamic` | — | Text to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L895)

<a id="function-function-mlc-data-rdata-add-str-function-rdata-add-str-rb-name-text-mlc-data-ml-46031888"></a>
### rdata_add_str

```ml
function rdata_add_str(rb, name, text)
```

Implements rdata add str.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `text` | `dynamic` | — | Text to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L734)

<a id="function-function-mlc-data-rdata-add-str-nl-function-rdata-add-str-nl-rb-name-text-add-newline-mlc-data-ml-1983537838"></a>
### rdata_add_str_nl

```ml
function rdata_add_str_nl(rb, name, text, add_newline)
```

Implements rdata add str nl.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `text` | `dynamic` | — | Text to process. |
| `add_newline` | `dynamic` | — | Value supplied for `add_newline`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L743)

<a id="function-function-mlc-data-rdata-clear-labels-function-rdata-clear-labels-rb-mlc-data-ml-1305272588"></a>
### rdata_clear_labels

```ml
function rdata_clear_labels(rb)
```

Implements rdata clear labels.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L542)

<a id="function-function-mlc-data-rdata-clear-patches-function-rdata-clear-patches-rb-mlc-data-ml-1556851698"></a>
### rdata_clear_patches

```ml
function rdata_clear_patches(rb)
```

Implements rdata clear patches.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L431)

<a id="function-function-mlc-data-rdata-get-labels-function-rdata-get-labels-rb-mlc-data-ml-14203796"></a>
### rdata_get_labels

```ml
function rdata_get_labels(rb)
```

Implements rdata get labels.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L437)

<a id="function-function-mlc-data-rdata-get-labels-after-function-rdata-get-labels-after-rb-start-index-mlc-data-ml-343597091"></a>
### rdata_get_labels_after

```ml
function rdata_get_labels_after(rb, start_index)
```

Implements rdata get labels after.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |
| `start_index` | `dynamic` | — | Value supplied for `start_index`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L447)

<a id="function-function-mlc-data-rdata-get-patches-function-rdata-get-patches-rb-mlc-data-ml-277419204"></a>
### rdata_get_patches

```ml
function rdata_get_patches(rb)
```

Implements rdata get patches.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L381)

<a id="function-function-mlc-data-rdata-get-patches-after-function-rdata-get-patches-after-rb-start-index-mlc-data-ml-475352069"></a>
### rdata_get_patches_after

```ml
function rdata_get_patches_after(rb, start_index)
```

Implements rdata get patches after.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |
| `start_index` | `dynamic` | — | Value supplied for `start_index`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L400)

<a id="function-function-mlc-data-rdata-has-label-function-rdata-has-label-rb-name-mlc-data-ml-1579051377"></a>
### rdata_has_label

```ml
function rdata_has_label(rb, name)
```

Implements rdata has label.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |
| `name` | `dynamic` | — | Name of the requested item. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L506)

<a id="function-function-mlc-data-rdata-label-count-function-rdata-label-count-rb-mlc-data-ml-779307070"></a>
### rdata_label_count

```ml
function rdata_label_count(rb)
```

Implements rdata label count.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L473)

<a id="function-function-mlc-data-rdata-label-length-function-rdata-label-length-rb-name-mlc-data-ml-1681488389"></a>
### rdata_label_length

```ml
function rdata_label_length(rb, name)
```

Implements rdata label length.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |
| `name` | `dynamic` | — | Name of the requested item. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L513)

<a id="function-function-mlc-data-rdata-label-record-function-rdata-label-record-rb-name-mlc-data-ml-1938418297"></a>
### rdata_label_record

```ml
function rdata_label_record(rb, name)
```

Implements rdata label record.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |
| `name` | `dynamic` | — | Name of the requested item. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L483)

<a id="function-function-mlc-data-rdata-pad-align-function-rdata-pad-align-rb-align-mlc-data-ml-814922757"></a>
### rdata_pad_align

```ml
function rdata_pad_align(rb, align)
```

Implements rdata pad align.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |
| `align` | `dynamic` | — | Value supplied for `align`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L701)

<a id="function-function-mlc-data-rdata-patch-count-function-rdata-patch-count-rb-mlc-data-ml-186349378"></a>
### rdata_patch_count

```ml
function rdata_patch_count(rb)
```

Implements rdata patch count.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L390)

<a id="function-function-mlc-data-rdata-resolve-alias-function-rdata-resolve-alias-rb-name-mlc-data-ml-1358680033"></a>
### rdata_resolve_alias

```ml
function rdata_resolve_alias(rb, name)
```

Implements rdata resolve alias.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |
| `name` | `dynamic` | — | Name of the requested item. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L465)

<a id="function-function-mlc-data-rdata-set-labels-function-rdata-set-labels-rb-labels-mlc-data-ml-1865594797"></a>
### rdata_set_labels

```ml
function rdata_set_labels(rb, labels)
```

Implements rdata set labels.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |
| `labels` | `dynamic` | — | Value supplied for `labels`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L522)

<a id="function-function-mlc-data-rdata-set-patches-function-rdata-set-patches-rb-patches-mlc-data-ml-1982356328"></a>
### rdata_set_patches

```ml
function rdata_set_patches(rb, patches)
```

Implements rdata set patches.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |
| `patches` | `dynamic` | — | Value supplied for `patches`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L418)

<a id="function-function-mlc-data-rdata-used-function-rdata-used-rb-mlc-data-ml-813016988"></a>
### rdata_used

```ml
function rdata_used(rb)
```

Implements rdata used.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — | Value supplied for `rb`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/data.ml#L575)

- [mlc.data.RDataBuilder](Type-mlc-data-rdatabuilder-1547105200.md) — struct
