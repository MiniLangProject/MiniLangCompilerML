# `mlc/codegen/codegen_concurrent_gc.ml`

[Home](README.md) · [Files](Files.md)

Optional Windows SATB collector. The worker never executes managed code.

Package: [`mlc.codegen.codegen_concurrent_gc`](Package-mlc-codegen-codegen-concurrent-gc-197838730.md)

Reachable from entry: **yes**

## Imports

- `mlc/asm.ml` as `a` → [mlc/asm.ml](File-mlc-asm-ml-1368648960.md)
- `mlc/codegen/codegen_memory.ml` as `mem` → [mlc/codegen/codegen_memory.ml](File-mlc-codegen-codegen-memory-ml-2136639668.md)
- `mlc/data.ml` as `d` → [mlc/data.ml](File-mlc-data-ml-557434521.md)

## Declarations

<a id="function-function-mlc-codegen-codegen-concurrent-gc-emit-collect-function-emit-collect-state-mlc-codegen-codegen-concurrent-gc-ml-1862035436"></a>
### emit_collect

```ml
function emit_collect(state)
```

Keep gc_collect synchronous while other managed threads continue running. Emergency waiters release all recursive heap locks and restore the original depth.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Backend state receiving the completion-wait helper. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_concurrent_gc.ml#L248)

<a id="function-function-mlc-codegen-codegen-concurrent-gc-emit-request-function-emit-request-state-mlc-codegen-codegen-concurrent-gc-ml-1529982796"></a>
### emit_request

```ml
function emit_request(state)
```

Return the completion sequence to wait for, coalescing already-active requests. Initialization and publication use the reentrant heap monitor, including fn_alloc calls.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Backend state receiving the asynchronous request helper. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_concurrent_gc.ml#L178)

<a id="function-function-mlc-codegen-codegen-concurrent-gc-emit-satb-pop-function-emit-satb-pop-state-mlc-codegen-codegen-concurrent-gc-ml-2098694756"></a>
### emit_satb_pop

```ml
function emit_satb_pop(state)
```

The worker consumes one logged value at a time without holding the heap lock. Pop a logged reference under the spinlock, or return zero when empty.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Backend state receiving the collector-only pop helper. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_concurrent_gc.ml#L130)

<a id="function-function-mlc-codegen-codegen-concurrent-gc-emit-satb-record-function-emit-satb-record-state-mlc-codegen-codegen-concurrent-gc-ml-1227143900"></a>
### emit_satb_record

```ml
function emit_satb_record(state)
```

Record RAX as an overwritten tagged value while preserving all registers. No allocation, OS call or safepoint may separate logging from the managed store.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Backend state receiving the SATB leaf helper. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_concurrent_gc.ml#L59)

<a id="function-function-mlc-codegen-codegen-concurrent-gc-emit-worker-function-emit-worker-state-mlc-codegen-codegen-concurrent-gc-ml-1044421100"></a>
### emit_worker

```ml
function emit_worker(state)
```

Emit a persistent native worker waiting on an auto-reset event between cycles.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Backend state receiving the private worker loop. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_concurrent_gc.ml#L157)

<a id="function-function-mlc-codegen-codegen-concurrent-gc-enabled-function-enabled-state-mlc-codegen-codegen-concurrent-gc-ml-1973447018"></a>
### enabled

```ml
function enabled(state)
```

Test whether this image uses the optional Windows background collector.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Backend state containing the target heap configuration. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_concurrent_gc.ml#L35)

<a id="function-function-mlc-codegen-codegen-concurrent-gc-ensure-data-function-ensure-data-state-mlc-codegen-codegen-concurrent-gc-ml-2106950210"></a>
### ensure_data

```ml
function ensure_data(state)
```

Materialize the private collector context, event handles and deletion-log storage once.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Backend state receiving data and BSS labels. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_concurrent_gc.ml#L41)

<a id="constant-constant-mlc-codegen-codegen-concurrent-gc-heap-lock-depth-const-heap-lock-depth-208-mlc-codegen-codegen-concurrent-gc-ml-313737406"></a>
### HEAP_LOCK_DEPTH

```ml
const HEAP_LOCK_DEPTH = 208
```


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_concurrent_gc.ml#L13)

<a id="constant-constant-mlc-codegen-codegen-concurrent-gc-satb-capacity-const-satb-capacity-1048576-mlc-codegen-codegen-concurrent-gc-ml-35798459"></a>
### SATB_CAPACITY

```ml
const SATB_CAPACITY = 1048576
```


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_concurrent_gc.ml#L12)

<a id="function-function-mlc-codegen-codegen-concurrent-gc-satb-capacity-function-satb-capacity-state-mlc-codegen-codegen-concurrent-gc-ml-2026097214"></a>
### satb_capacity

```ml
function satb_capacity(state)
```

Return deletion-log capacity in qwords, clamped before byte-to-entry conversion.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Backend state containing the optional diagnostic byte limit. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_concurrent_gc.ml#L17)
