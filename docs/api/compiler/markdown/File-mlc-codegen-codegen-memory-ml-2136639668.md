# `mlc/codegen/codegen_memory.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc codegen codegen_memory package.

Package: [`mlc.codegen.codegen_memory`](Package-mlc-codegen-codegen-memory-379518877.md)

Reachable from entry: **yes**

## Imports

- `mlc/asm.ml` as `a` → [mlc/asm.ml](File-mlc-asm-ml-1368648960.md)
- `mlc/constants.ml` as `c` → [mlc/constants.ml](File-mlc-constants-ml-1024884042.md)
- `mlc/data.ml` as `d` → [mlc/data.ml](File-mlc-data-ml-557434521.md)
- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)

## Declarations

<a id="function-function-mlc-codegen-codegen-memory-init-function-init-state-mlc-codegen-codegen-memory-ml-1566450084"></a>
### __init__

```ml
function __init__(state)
```

Emit init in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L203)

<a id="function-function-mlc-codegen-codegen-memory-append-unique-function-append-unique-values-value-mlc-codegen-codegen-memory-ml-484259326"></a>
### _append_unique

```ml
function _append_unique(values, value)
```

Updates append unique.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L96)

<a id="function-function-mlc-codegen-codegen-memory-configured-gc-limits-function-configured-gc-limits-state-mlc-codegen-codegen-memory-ml-968270226"></a>
### _configured_gc_limits

```ml
function _configured_gc_limits(state)
```

Emit configured gc limits in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L194)

<a id="function-function-mlc-codegen-codegen-memory-emit-mov-rax-i64-max-function-emit-mov-rax-i64-max-state-mlc-codegen-codegen-memory-ml-890611964"></a>
### _emit_mov_rax_i64_max

```ml
function _emit_mov_rax_i64_max(state)
```

Emit emit mov rax i64 max in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L71)

<a id="function-function-mlc-codegen-codegen-memory-ensure-data-u64-function-ensure-data-u64-db-name-value-mlc-codegen-codegen-memory-ml-426078861"></a>
### _ensure_data_u64

```ml
function _ensure_data_u64(db, name, value)
```

Emit ensure data u64 in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L107)

<a id="function-function-mlc-codegen-codegen-memory-ensure-gc-limit-data-function-ensure-gc-limit-data-db-name-value-mlc-codegen-codegen-memory-ml-1144680223"></a>
### _ensure_gc_limit_data

```ml
function _ensure_gc_limit_data(db, name, value)
```

Emit ensure gc limit data in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L114)

<a id="function-function-mlc-codegen-codegen-memory-ensure-rdata-str-function-ensure-rdata-str-rb-name-text-mlc-codegen-codegen-memory-ml-564754933"></a>
### _ensure_rdata_str

```ml
function _ensure_rdata_str(rb, name, text)
```

Emit ensure rdata str in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L124)

<a id="function-function-mlc-codegen-codegen-memory-has-label-function-has-label-labels-name-mlc-codegen-codegen-memory-ml-36410265"></a>
### _has_label

```ml
function _has_label(labels, name)
```

Reports whether has label.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `labels` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L85)

<a id="function-function-mlc-codegen-codegen-memory-heap-cfg-get-any-function-heap-cfg-get-any-state-key-mlc-codegen-codegen-memory-ml-462023885"></a>
### _heap_cfg_get_any

```ml
function _heap_cfg_get_any(state, key)
```

Emit heap cfg get any in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L152)

<a id="function-function-mlc-codegen-codegen-memory-heap-cfg-get-bool-function-heap-cfg-get-bool-state-key-defaultv-mlc-codegen-codegen-memory-ml-1588187098"></a>
### _heap_cfg_get_bool

```ml
function _heap_cfg_get_bool(state, key, defaultv)
```

Emit heap cfg get bool in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L178)

<a id="function-function-mlc-codegen-codegen-memory-heap-cfg-get-int-function-heap-cfg-get-int-state-key-defaultv-mlc-codegen-codegen-memory-ml-602328160"></a>
### _heap_cfg_get_int

```ml
function _heap_cfg_get_int(state, key, defaultv)
```

Emit heap cfg get int in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L170)

<a id="function-function-mlc-codegen-codegen-memory-heap-cfg-has-any-function-heap-cfg-has-any-state-mlc-codegen-codegen-memory-ml-907394156"></a>
### _heap_cfg_has_any

```ml
function _heap_cfg_has_any(state)
```

Emit heap cfg has any in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L186)

<a id="function-function-mlc-codegen-codegen-memory-mark-bitmap-bytes-for-heap-bytes-function-mark-bitmap-bytes-for-heap-bytes-heap-bytes-mlc-codegen-codegen-memory-ml-2018108057"></a>
### _mark_bitmap_bytes_for_heap_bytes

```ml
function _mark_bitmap_bytes_for_heap_bytes(heap_bytes)
```

Emit mark bitmap bytes for heap bytes in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `heap_bytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L131)

<a id="function-function-mlc-codegen-codegen-memory-rlabel-len-function-rlabel-len-labels-name-mlc-codegen-codegen-memory-ml-1815284927"></a>
### _rlabel_len

```ml
function _rlabel_len(labels, name)
```

Emit rlabel len in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `labels` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L138)

<a id="constant-constant-mlc-codegen-codegen-memory-alloc-min-split-const-alloc-min-split-32-mlc-codegen-codegen-memory-ml-1661056987"></a>
### ALLOC_MIN_SPLIT

```ml
const ALLOC_MIN_SPLIT = 32
```

Track alloc min split.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L41)

<a id="function-function-mlc-codegen-codegen-memory-cg-memory-init-function-cg-memory-init-state-mlc-codegen-codegen-memory-ml-2121417204"></a>
### cg_memory_init

```ml
function cg_memory_init(state)
```

Emit cg memory init in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L2268)

<a id="function-function-mlc-codegen-codegen-memory-emit-alloc-function-function-emit-alloc-function-state-mlc-codegen-codegen-memory-ml-1374636448"></a>
### emit_alloc_function

```ml
function emit_alloc_function(state)
```

Emit the shared-heap allocator, including the TLAB fast path and synchronized refill/GC fallback. Every successful return owns exactly one initialized block.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L545)

<a id="function-function-mlc-codegen-codegen-memory-emit-decref-function-function-emit-decref-function-state-mlc-codegen-codegen-memory-ml-848943548"></a>
### emit_decref_function

```ml
function emit_decref_function(state)
```

Emit emit decref function in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L1852)

<a id="function-function-mlc-codegen-codegen-memory-emit-gc-clear-root-slots-function-emit-gc-clear-root-slots-state-root-base-root-top-mlc-codegen-codegen-memory-ml-1049458376"></a>
### emit_gc_clear_root_slots

```ml
function emit_gc_clear_root_slots(state, root_base, root_top)
```

Emit emit gc clear root slots in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `root_base` | `dynamic` | — | Value supplied for `root_base`. |
| `root_top` | `dynamic` | — | Value supplied for `root_top`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L458)

<a id="function-function-mlc-codegen-codegen-memory-emit-gc-collect-function-function-emit-gc-collect-function-state-mlc-codegen-codegen-memory-ml-2043781588"></a>
### emit_gc_collect_function

```ml
function emit_gc_collect_function(state)
```

Emit stop-the-world mark/sweep collection. Thread roots are published before suspension and heap ownership remains held until sweep/shrink state is stable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L1190)

<a id="function-function-mlc-codegen-codegen-memory-emit-gc-init-globals-function-emit-gc-init-globals-state-disable-periodic-mlc-codegen-codegen-memory-ml-1041162440"></a>
### emit_gc_init_globals

```ml
function emit_gc_init_globals(state, disable_periodic)
```

Emit emit gc init globals in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `disable_periodic` | `dynamic` | — | Value supplied for `disable_periodic`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L427)

<a id="function-function-mlc-codegen-codegen-memory-emit-gc-pop-root-frame-function-emit-gc-pop-root-frame-state-root-rec-off-mlc-codegen-codegen-memory-ml-206505697"></a>
### emit_gc_pop_root_frame

```ml
function emit_gc_pop_root_frame(state, root_rec_off)
```

Emit emit gc pop root frame in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `root_rec_off` | `dynamic` | — | Value supplied for `root_rec_off`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L531)

<a id="function-function-mlc-codegen-codegen-memory-emit-gc-push-root-frame-function-emit-gc-push-root-frame-state-root-rec-off-root-base-root-top-mlc-codegen-codegen-memory-ml-545736239"></a>
### emit_gc_push_root_frame

```ml
function emit_gc_push_root_frame(state, root_rec_off, root_base, root_top)
```

Emit emit gc push root frame in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `root_rec_off` | `dynamic` | — | Value supplied for `root_rec_off`. |
| `root_base` | `dynamic` | — | Value supplied for `root_base`. |
| `root_top` | `dynamic` | — | Value supplied for `root_top`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L500)

<a id="function-function-mlc-codegen-codegen-memory-emit-heap-bytes-committed-function-function-emit-heap-bytes-committed-function-state-mlc-codegen-codegen-memory-ml-597269876"></a>
### emit_heap_bytes_committed_function

```ml
function emit_heap_bytes_committed_function(state)
```

Emit emit heap bytes committed function in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L1948)

<a id="function-function-mlc-codegen-codegen-memory-emit-heap-bytes-reserved-function-function-emit-heap-bytes-reserved-function-state-mlc-codegen-codegen-memory-ml-1925633220"></a>
### emit_heap_bytes_reserved_function

```ml
function emit_heap_bytes_reserved_function(state)
```

Emit emit heap bytes reserved function in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L1977)

<a id="function-function-mlc-codegen-codegen-memory-emit-heap-bytes-used-function-function-emit-heap-bytes-used-function-state-mlc-codegen-codegen-memory-ml-216011958"></a>
### emit_heap_bytes_used_function

```ml
function emit_heap_bytes_used_function(state)
```

Emit emit heap bytes used function in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L1919)

<a id="function-function-mlc-codegen-codegen-memory-emit-heap-count-function-function-emit-heap-count-function-state-mlc-codegen-codegen-memory-ml-2002706044"></a>
### emit_heap_count_function

```ml
function emit_heap_count_function(state)
```

Emit emit heap count function in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L1860)

<a id="function-function-mlc-codegen-codegen-memory-emit-heap-free-blocks-function-function-emit-heap-free-blocks-function-state-mlc-codegen-codegen-memory-ml-439642176"></a>
### emit_heap_free_blocks_function

```ml
function emit_heap_free_blocks_function(state)
```

Emit emit heap free blocks function in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L2006)

<a id="function-function-mlc-codegen-codegen-memory-emit-heap-free-bytes-function-function-emit-heap-free-bytes-function-state-mlc-codegen-codegen-memory-ml-1853574576"></a>
### emit_heap_free_bytes_function

```ml
function emit_heap_free_bytes_function(state)
```

Emit emit heap free bytes function in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L2076)

<a id="function-function-mlc-codegen-codegen-memory-emit-heap-grow-function-function-emit-heap-grow-function-state-mlc-codegen-codegen-memory-ml-759712978"></a>
### emit_heap_grow_function

```ml
function emit_heap_grow_function(state)
```

Emit emit heap grow function in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L2148)

<a id="function-function-mlc-codegen-codegen-memory-emit-heap-init-function-emit-heap-init-state-heap-size-mlc-codegen-codegen-memory-ml-438456146"></a>
### emit_heap_init

```ml
function emit_heap_init(state, heap_size)
```

Emit emit heap init in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `heap_size` | `dynamic` | — | Value supplied for `heap_size`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L267)

<a id="function-function-mlc-codegen-codegen-memory-emit-incref-function-function-emit-incref-function-state-mlc-codegen-codegen-memory-ml-2119130748"></a>
### emit_incref_function

```ml
function emit_incref_function(state)
```

Emit emit incref function in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L1844)

<a id="function-function-mlc-codegen-codegen-memory-ensure-gc-data-function-ensure-gc-data-state-mlc-codegen-codegen-memory-ml-2102654204"></a>
### ensure_gc_data

```ml
function ensure_gc_data(state)
```

Emit ensure gc data in the managed-memory runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L209)

<a id="constant-constant-mlc-codegen-codegen-memory-gc-default-bytes-limit-const-gc-default-bytes-limit-64-20-mlc-codegen-codegen-memory-ml-1557332908"></a>
### GC_DEFAULT_BYTES_LIMIT

```ml
const GC_DEFAULT_BYTES_LIMIT = 64 << 20
```

Track gc default bytes limit.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L59)

<a id="constant-constant-mlc-codegen-codegen-memory-gc-disable-periodic-limit-const-gc-disable-periodic-limit-1-mlc-codegen-codegen-memory-ml-154422672"></a>
### GC_DISABLE_PERIODIC_LIMIT

```ml
const GC_DISABLE_PERIODIC_LIMIT = -1
```

Sentinel for the unboxed signed-i64 maximum. Tagged MiniLang integers cannot represent 0x7FFFFFFFFFFFFFFF directly, so the data helper writes its bytes.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L61)

<a id="constant-constant-mlc-codegen-codegen-memory-gc-mark-stack-qwords-const-gc-mark-stack-qwords-8388608-mlc-codegen-codegen-memory-ml-1469030539"></a>
### GC_MARK_STACK_QWORDS

```ml
const GC_MARK_STACK_QWORDS = 8388608
```

Track gc mark stack qwords.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L57)

<a id="constant-constant-mlc-codegen-codegen-memory-gc-young-default-bytes-limit-const-gc-young-default-bytes-limit-8-20-mlc-codegen-codegen-memory-ml-448587362"></a>
### GC_YOUNG_DEFAULT_BYTES_LIMIT

```ml
const GC_YOUNG_DEFAULT_BYTES_LIMIT = 8 << 20
```

Track gc young default bytes limit.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L63)

<a id="constant-constant-mlc-codegen-codegen-memory-gc-young-object-max-bytes-const-gc-young-object-max-bytes-256-mlc-codegen-codegen-memory-ml-1923752761"></a>
### GC_YOUNG_OBJECT_MAX_BYTES

```ml
const GC_YOUNG_OBJECT_MAX_BYTES = 256
```

Track gc young object max bytes.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L65)

<a id="constant-constant-mlc-codegen-codegen-memory-heap-commit-default-const-heap-commit-default-heap-size-default-mlc-codegen-codegen-memory-ml-659206112"></a>
### HEAP_COMMIT_DEFAULT

```ml
const HEAP_COMMIT_DEFAULT = HEAP_SIZE_DEFAULT
```

Track heap commit default.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L33)

<a id="constant-constant-mlc-codegen-codegen-memory-heap-grow-min-const-heap-grow-min-16777216-mlc-codegen-codegen-memory-ml-107345601"></a>
### HEAP_GROW_MIN

```ml
const HEAP_GROW_MIN = 16777216
```

Track heap grow min.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L39)

<a id="constant-constant-mlc-codegen-codegen-memory-heap-reserve-default-const-heap-reserve-default-1024-1024-1024-4-mlc-codegen-codegen-memory-ml-1079043457"></a>
### HEAP_RESERVE_DEFAULT

```ml
const HEAP_RESERVE_DEFAULT = 1024 * 1024 * 1024 * 4
```

Track heap reserve default.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L35)

<a id="constant-constant-mlc-codegen-codegen-memory-heap-reserve-min-const-heap-reserve-min-heap-size-default-mlc-codegen-codegen-memory-ml-1756351446"></a>
### HEAP_RESERVE_MIN

```ml
const HEAP_RESERVE_MIN = HEAP_SIZE_DEFAULT
```

Track heap reserve min.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L37)

<a id="constant-constant-mlc-codegen-codegen-memory-heap-size-default-const-heap-size-default-33554432-mlc-codegen-codegen-memory-ml-1676170371"></a>
### HEAP_SIZE_DEFAULT

```ml
const HEAP_SIZE_DEFAULT = 33554432
```

Track heap size default.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L31)

<a id="constant-constant-mlc-codegen-codegen-memory-mem-page-size-const-mem-page-size-4096-mlc-codegen-codegen-memory-ml-1098872653"></a>
### MEM_PAGE_SIZE

```ml
const MEM_PAGE_SIZE = 4096
```

Track mem page size.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L27)

<a id="constant-constant-mlc-codegen-codegen-memory-mem-reserve-granularity-const-mem-reserve-granularity-65536-mlc-codegen-codegen-memory-ml-2139957261"></a>
### MEM_RESERVE_GRANULARITY

```ml
const MEM_RESERVE_GRANULARITY = 65536
```

Track mem reserve granularity.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L29)

<a id="constant-constant-mlc-codegen-codegen-memory-memory-enable-refcount-const-memory-enable-refcount-false-mlc-codegen-codegen-memory-ml-2124784781"></a>
### MEMORY_ENABLE_REFCOUNT

```ml
const MEMORY_ENABLE_REFCOUNT = false
```

Track memory enable refcount.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L67)

<a id="constant-constant-mlc-codegen-codegen-memory-thread-handoff-cursor-offset-const-thread-handoff-cursor-offset-136-mlc-codegen-codegen-memory-ml-2016575484"></a>
### THREAD_HANDOFF_CURSOR_OFFSET

```ml
const THREAD_HANDOFF_CURSOR_OFFSET = 136
```

Track thread handoff cursor offset.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L47)

<a id="constant-constant-mlc-codegen-codegen-memory-thread-handoff-root-base-offset-const-thread-handoff-root-base-offset-88-mlc-codegen-codegen-memory-ml-729268886"></a>
### THREAD_HANDOFF_ROOT_BASE_OFFSET

```ml
const THREAD_HANDOFF_ROOT_BASE_OFFSET = 88
```

Track thread handoff root base offset.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L49)

<a id="constant-constant-mlc-codegen-codegen-memory-thread-tlab-cursor-offset-const-thread-tlab-cursor-offset-184-mlc-codegen-codegen-memory-ml-1401318823"></a>
### THREAD_TLAB_CURSOR_OFFSET

```ml
const THREAD_TLAB_CURSOR_OFFSET = 184
```

Track thread tlab cursor offset.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L53)

<a id="constant-constant-mlc-codegen-codegen-memory-thread-tlab-end-offset-const-thread-tlab-end-offset-192-mlc-codegen-codegen-memory-ml-606307682"></a>
### THREAD_TLAB_END_OFFSET

```ml
const THREAD_TLAB_END_OFFSET = 192
```

Track thread tlab end offset.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L55)

<a id="constant-constant-mlc-codegen-codegen-memory-thread-tlab-start-offset-const-thread-tlab-start-offset-176-mlc-codegen-codegen-memory-ml-1746629478"></a>
### THREAD_TLAB_START_OFFSET

```ml
const THREAD_TLAB_START_OFFSET = 176
```

Track thread tlab start offset.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L51)

<a id="constant-constant-mlc-codegen-codegen-memory-tlab-max-object-size-const-tlab-max-object-size-256-mlc-codegen-codegen-memory-ml-1705675635"></a>
### TLAB_MAX_OBJECT_SIZE

```ml
const TLAB_MAX_OBJECT_SIZE = 256
```

Keep the lock-free path aligned with the runtime's young-object class. Larger arrays/strings/byte buffers go through the exact central path.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L45)

<a id="constant-constant-mlc-codegen-codegen-memory-tlab-size-const-tlab-size-65536-mlc-codegen-codegen-memory-ml-554456205"></a>
### TLAB_SIZE

```ml
const TLAB_SIZE = 65536
```

TLABs are formatted ranges inside the one shared heap, never private heaps.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_memory.ml#L43)
