# `mlc/codegen/codegen_threads.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc codegen codegen_threads package.

Package: [`mlc.codegen.codegen_threads`](Package-mlc-codegen-codegen-threads-258920687.md)

Reachable from entry: **yes**

## Imports

- `mlc/asm.ml` as `a` → [mlc/asm.ml](File-mlc-asm-ml-1368648960.md)
- `mlc/constants.ml` as `c` → [mlc/constants.ml](File-mlc-constants-ml-1024884042.md)
- `mlc/data.ml` as `d` → [mlc/data.ml](File-mlc-data-ml-557434521.md)
- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)

## Declarations

<a id="function-function-mlc-codegen-codegen-threads-append-unique-function-append-unique-values-value-mlc-codegen-codegen-threads-ml-1480911850"></a>
### _append_unique

```ml
function _append_unique(values, value)
```

Updates append unique.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L115)

<a id="function-function-mlc-codegen-codegen-threads-emit-managed-thread-count-delta-function-emit-managed-thread-count-delta-state-delta-mlc-codegen-codegen-threads-ml-956712758"></a>
### _emit_managed_thread_count_delta

```ml
function _emit_managed_thread_count_delta(state, delta)
```

Runs emit managed thread count delta.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `delta` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L245)

<a id="function-function-mlc-codegen-codegen-threads-has-label-function-has-label-labels-name-mlc-codegen-codegen-threads-ml-923041515"></a>
### _has_label

```ml
function _has_label(labels, name)
```

Reports whether has label.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `labels` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L105)

<a id="function-function-mlc-codegen-codegen-threads-new-label-id-function-new-label-id-state-mlc-codegen-codegen-threads-ml-1951519124"></a>
### _new_label_id

```ml
function _new_label_id(state)
```

Creates new label id.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L126)

<a id="function-function-mlc-codegen-codegen-threads-emit-gc-managed-exit-function-function-emit-gc-managed-exit-function-state-mlc-codegen-codegen-threads-ml-363662000"></a>
### emit_gc_managed_exit_function

```ml
function emit_gc_managed_exit_function(state)
```

Remove a terminating managed worker from collector participation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L412)

<a id="function-function-mlc-codegen-codegen-threads-emit-gc-native-enter-function-function-emit-gc-native-enter-function-state-mlc-codegen-codegen-threads-ml-1448965312"></a>
### emit_gc_native_enter_function

```ml
function emit_gc_native_enter_function(state)
```

Mark the current thread native so the collector does not wait for a poll.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L328)

<a id="function-function-mlc-codegen-codegen-threads-emit-gc-native-leave-function-function-emit-gc-native-leave-function-state-mlc-codegen-codegen-threads-ml-2055070818"></a>
### emit_gc_native_leave_function

```ml
function emit_gc_native_leave_function(state)
```

Rejoin managed execution, parking first when a collection is active.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L364)

<a id="function-function-mlc-codegen-codegen-threads-emit-gc-safepoint-function-function-emit-gc-safepoint-function-state-mlc-codegen-codegen-threads-ml-380093628"></a>
### emit_gc_safepoint_function

```ml
function emit_gc_safepoint_function(state)
```

Emit the slow path that publishes a parked state until GC resumes the world.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L264)

<a id="function-function-mlc-codegen-codegen-threads-emit-gc-safepoint-poll-function-emit-gc-safepoint-poll-state-mlc-codegen-codegen-threads-ml-330151080"></a>
### emit_gc_safepoint_poll

```ml
function emit_gc_safepoint_poll(state)
```

Emit a cheap conditional call that parks when collection was requested.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L208)

<a id="function-function-mlc-codegen-codegen-threads-emit-gc-world-resume-function-function-emit-gc-world-resume-function-state-mlc-codegen-codegen-threads-ml-1826587852"></a>
### emit_gc_world_resume_function

```ml
function emit_gc_world_resume_function(state)
```

Clear the collection request and make parked threads runnable again.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L584)

<a id="function-function-mlc-codegen-codegen-threads-emit-gc-world-stop-function-function-emit-gc-world-stop-function-state-mlc-codegen-codegen-threads-ml-1429773454"></a>
### emit_gc_world_stop_function

```ml
function emit_gc_world_stop_function(state)
```

Request collection and wait until every other managed thread is safe.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L520)

<a id="function-function-mlc-codegen-codegen-threads-emit-heap-enter-function-function-emit-heap-enter-function-state-mlc-codegen-codegen-threads-ml-1367045632"></a>
### emit_heap_enter_function

```ml
function emit_heap_enter_function(state)
```

Serialize heap mutation while preserving re-entrant allocation depth.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L433)

<a id="function-function-mlc-codegen-codegen-threads-emit-heap-leave-function-function-emit-heap-leave-function-state-mlc-codegen-codegen-threads-ml-1998760952"></a>
### emit_heap_leave_function

```ml
function emit_heap_leave_function(state)
```

Release the heap monitor at the outermost allocation depth.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L491)

<a id="function-function-mlc-codegen-codegen-threads-emit-sync-enter-function-function-emit-sync-enter-function-state-mlc-codegen-codegen-threads-ml-1105104072"></a>
### emit_sync_enter_function

```ml
function emit_sync_enter_function(state)
```

Enter the process-wide monitor used by synchronized language constructs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L607)

<a id="function-function-mlc-codegen-codegen-threads-emit-sync-init-function-emit-sync-init-state-mlc-codegen-codegen-threads-ml-304841148"></a>
### emit_sync_init

```ml
function emit_sync_init(state)
```

Initialize the main thread context and all process-wide critical sections.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L170)

<a id="function-function-mlc-codegen-codegen-threads-emit-sync-leave-function-function-emit-sync-leave-function-state-mlc-codegen-codegen-threads-ml-88544024"></a>
### emit_sync_leave_function

```ml
function emit_sync_leave_function(state)
```

Leave the process-wide synchronized monitor.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L626)

<a id="function-function-mlc-codegen-codegen-threads-emit-thread-alive-function-function-emit-thread-alive-function-state-mlc-codegen-codegen-threads-ml-2003955440"></a>
### emit_thread_alive_function

```ml
function emit_thread_alive_function(state)
```

Runs emit thread alive function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L940)

<a id="function-function-mlc-codegen-codegen-threads-emit-thread-alloc-function-function-emit-thread-alloc-function-state-mlc-codegen-codegen-threads-ml-1525487468"></a>
### emit_thread_alloc_function

```ml
function emit_thread_alloc_function(state)
```

Runs emit thread alloc function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L1170)

<a id="function-function-mlc-codegen-codegen-threads-emit-thread-cancellation-poll-function-emit-thread-cancellation-poll-state-mlc-codegen-codegen-threads-ml-1629970156"></a>
### emit_thread_cancellation_poll

```ml
function emit_thread_cancellation_poll(state)
```

Cooperatively turn a stop request into an early function return.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L222)

<a id="function-function-mlc-codegen-codegen-threads-emit-thread-close-function-function-emit-thread-close-function-state-mlc-codegen-codegen-threads-ml-1564354248"></a>
### emit_thread_close_function

```ml
function emit_thread_close_function(state)
```

Runs emit thread close function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L1059)

<a id="function-function-mlc-codegen-codegen-threads-emit-thread-current-logical-id-function-function-emit-thread-current-logical-id-function-state-mlc-codegen-codegen-threads-ml-710568386"></a>
### emit_thread_current_logical_id_function

```ml
function emit_thread_current_logical_id_function(state)
```

Runs emit thread current logical id function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L1015)

<a id="function-function-mlc-codegen-codegen-threads-emit-thread-entry-function-function-emit-thread-entry-function-state-mlc-codegen-codegen-threads-ml-411978532"></a>
### emit_thread_entry_function

```ml
function emit_thread_entry_function(state)
```

Bridge the target's native worker entrypoint to managed code and publish its result.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L1179)

<a id="function-function-mlc-codegen-codegen-threads-emit-thread-id-function-function-emit-thread-id-function-state-mlc-codegen-codegen-threads-ml-460353190"></a>
### emit_thread_id_function

```ml
function emit_thread_id_function(state)
```

Runs emit thread id function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L963)

<a id="function-function-mlc-codegen-codegen-threads-emit-thread-join-function-function-emit-thread-join-function-state-mlc-codegen-codegen-threads-ml-168611108"></a>
### emit_thread_join_function

```ml
function emit_thread_join_function(state)
```

Runs emit thread join function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L844)

<a id="function-function-mlc-codegen-codegen-threads-emit-thread-logical-id-function-function-emit-thread-logical-id-function-state-mlc-codegen-codegen-threads-ml-2085745974"></a>
### emit_thread_logical_id_function

```ml
function emit_thread_logical_id_function(state)
```

Runs emit thread logical id function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L974)

<a id="function-function-mlc-codegen-codegen-threads-emit-thread-new-function-function-emit-thread-new-function-state-mlc-codegen-codegen-threads-ml-855205780"></a>
### emit_thread_new_function

```ml
function emit_thread_new_function(state)
```

Allocate and initialize a managed Thread object without starting it.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L643)

<a id="function-function-mlc-codegen-codegen-threads-emit-thread-result-function-function-emit-thread-result-function-state-mlc-codegen-codegen-threads-ml-991759054"></a>
### emit_thread_result_function

```ml
function emit_thread_result_function(state)
```

Runs emit thread result function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L1006)

<a id="function-function-mlc-codegen-codegen-threads-emit-thread-set-logical-id-function-function-emit-thread-set-logical-id-function-state-mlc-codegen-codegen-threads-ml-149940160"></a>
### emit_thread_set_logical_id_function

```ml
function emit_thread_set_logical_id_function(state)
```

Runs emit thread set logical id function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L983)

<a id="function-function-mlc-codegen-codegen-threads-emit-thread-start-function-function-emit-thread-start-function-state-mlc-codegen-codegen-threads-ml-1457904124"></a>
### emit_thread_start_function

```ml
function emit_thread_start_function(state)
```

Publish the argument and create the native worker exactly once.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L738)

<a id="function-function-mlc-codegen-codegen-threads-emit-thread-status-function-function-emit-thread-status-function-state-mlc-codegen-codegen-threads-ml-1292778052"></a>
### emit_thread_status_function

```ml
function emit_thread_status_function(state)
```

Runs emit thread status function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L1025)

<a id="function-function-mlc-codegen-codegen-threads-emit-thread-stop-function-function-emit-thread-stop-function-state-mlc-codegen-codegen-threads-ml-1794962392"></a>
### emit_thread_stop_function

```ml
function emit_thread_stop_function(state)
```

Runs emit thread stop function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L806)

<a id="function-function-mlc-codegen-codegen-threads-emit-thread-stop-requested-function-function-emit-thread-stop-requested-function-state-mlc-codegen-codegen-threads-ml-1119595898"></a>
### emit_thread_stop_requested_function

```ml
function emit_thread_stop_requested_function(state)
```

Runs emit thread stop requested function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L1147)

<a id="function-function-mlc-codegen-codegen-threads-ensure-thread-data-function-ensure-thread-data-state-mlc-codegen-codegen-threads-ml-14057176"></a>
### ensure_thread_data

```ml
function ensure_thread_data(state)
```

Materialize global monitors, the main context and coordination counters once.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L133)

<a id="constant-constant-mlc-codegen-codegen-threads-gc-thread-collector-const-gc-thread-collector-4-mlc-codegen-codegen-threads-ml-1010319348"></a>
### GC_THREAD_COLLECTOR

```ml
const GC_THREAD_COLLECTOR = 4
```

Stores the gc thread collector.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L101)

<a id="constant-constant-mlc-codegen-codegen-threads-gc-thread-inactive-const-gc-thread-inactive-3-mlc-codegen-codegen-threads-ml-272758931"></a>
### GC_THREAD_INACTIVE

```ml
const GC_THREAD_INACTIVE = 3
```

Stores the gc thread inactive.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L99)

<a id="constant-constant-mlc-codegen-codegen-threads-gc-thread-native-const-gc-thread-native-2-mlc-codegen-codegen-threads-ml-788931986"></a>
### GC_THREAD_NATIVE

```ml
const GC_THREAD_NATIVE = 2
```

Stores the gc thread native.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L97)

<a id="constant-constant-mlc-codegen-codegen-threads-gc-thread-parked-const-gc-thread-parked-1-mlc-codegen-codegen-threads-ml-367300213"></a>
### GC_THREAD_PARKED

```ml
const GC_THREAD_PARKED = 1
```

Stores the gc thread parked.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L95)

<a id="constant-constant-mlc-codegen-codegen-threads-gc-thread-running-const-gc-thread-running-0-mlc-codegen-codegen-threads-ml-898647272"></a>
### GC_THREAD_RUNNING

```ml
const GC_THREAD_RUNNING = 0
```

Collector-facing states used by cooperative stop-the-world coordination.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L93)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-alloc-cursor-const-thread-alloc-cursor-thread-handoff-cursor-mlc-codegen-codegen-threads-ml-6837516"></a>
### THREAD_ALLOC_CURSOR

```ml
const THREAD_ALLOC_CURSOR = THREAD_HANDOFF_CURSOR
```

Stores the thread alloc cursor.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L51)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-arg-const-thread-arg-144-mlc-codegen-codegen-threads-ml-1838539437"></a>
### THREAD_ARG

```ml
const THREAD_ARG = 144
```

Stores the thread arg.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L53)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-arity-const-thread-arity-160-mlc-codegen-codegen-threads-ml-2025374685"></a>
### THREAD_ARITY

```ml
const THREAD_ARITY = 160
```

Stores the thread arity.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L57)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-code-const-thread-code-24-mlc-codegen-codegen-threads-ml-1735192876"></a>
### THREAD_CODE

```ml
const THREAD_CODE = 24
```

Stores the thread code.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L35)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-completed-const-thread-completed-3-mlc-codegen-codegen-threads-ml-1426983449"></a>
### THREAD_COMPLETED

```ml
const THREAD_COMPLETED = 3
```

Stores the thread completed.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L82)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-configuring-const-thread-configuring-7-mlc-codegen-codegen-threads-ml-45006421"></a>
### THREAD_CONFIGURING

```ml
const THREAD_CONFIGURING = 7
```

Stores the thread configuring.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L90)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-context-pool-size-const-thread-context-pool-size-65536-mlc-codegen-codegen-threads-ml-1114858823"></a>
### THREAD_CONTEXT_POOL_SIZE

```ml
const THREAD_CONTEXT_POOL_SIZE = 65536
```

Stores the thread context pool size.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L73)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-context-size-const-thread-context-size-208-mlc-codegen-codegen-threads-ml-599108086"></a>
### THREAD_CONTEXT_SIZE

```ml
const THREAD_CONTEXT_SIZE = 208
```

Stores the thread context size.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L69)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-context-stride-const-thread-context-stride-208-mlc-codegen-codegen-threads-ml-2013311814"></a>
### THREAD_CONTEXT_STRIDE

```ml
const THREAD_CONTEXT_STRIDE = 208
```

Stores the thread context stride.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L71)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-created-const-thread-created-0-mlc-codegen-codegen-threads-ml-1374504008"></a>
### THREAD_CREATED

```ml
const THREAD_CREATED = 0
```

Public lifecycle states stored in THREAD_STATUS.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L76)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-failed-const-thread-failed-5-mlc-codegen-codegen-threads-ml-78784233"></a>
### THREAD_FAILED

```ml
const THREAD_FAILED = 5
```

Stores the thread failed.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L86)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-gc-state-const-thread-gc-state-128-mlc-codegen-codegen-threads-ml-1088683627"></a>
### THREAD_GC_STATE

```ml
const THREAD_GC_STATE = 128
```

Stores the thread gc state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L47)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-handle-const-thread-handle-8-mlc-codegen-codegen-threads-ml-566563596"></a>
### THREAD_HANDLE

```ml
const THREAD_HANDLE = 8
```

Stores the thread handle.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L31)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-handle-users-const-thread-handle-users-200-mlc-codegen-codegen-threads-ml-1900942902"></a>
### THREAD_HANDLE_USERS

```ml
const THREAD_HANDLE_USERS = 200
```

Active Join() operations retain THREAD_HANDLE until their native wait ends.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L67)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-handoff-cursor-const-thread-handoff-cursor-136-mlc-codegen-codegen-threads-ml-1497024434"></a>
### THREAD_HANDOFF_CURSOR

```ml
const THREAD_HANDOFF_CURSOR = 136
```

Cursor for the four allocation-handoff roots at THREAD_TMP0+32.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L49)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-heap-bypass-depth-const-thread-heap-bypass-depth-168-mlc-codegen-codegen-threads-ml-2065440141"></a>
### THREAD_HEAP_BYPASS_DEPTH

```ml
const THREAD_HEAP_BYPASS_DEPTH = 168
```

Stores the thread heap bypass depth.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L59)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-id-const-thread-id-16-mlc-codegen-codegen-threads-ml-1008940095"></a>
### THREAD_ID

```ml
const THREAD_ID = 16
```

Stores the thread id.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L33)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-logical-id-const-thread-logical-id-152-mlc-codegen-codegen-threads-ml-213743944"></a>
### THREAD_LOGICAL_ID

```ml
const THREAD_LOGICAL_ID = 152
```

Stores the thread logical id.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L55)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-next-const-thread-next-120-mlc-codegen-codegen-threads-ml-1436166595"></a>
### THREAD_NEXT

```ml
const THREAD_NEXT = 120
```

Stores the thread next.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L45)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-result-const-thread-result-40-mlc-codegen-codegen-threads-ml-1609688882"></a>
### THREAD_RESULT

```ml
const THREAD_RESULT = 40
```

Stores the thread result.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L39)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-roots-const-thread-roots-48-mlc-codegen-codegen-threads-ml-2086099880"></a>
### THREAD_ROOTS

```ml
const THREAD_ROOTS = 48
```

Stores the thread roots.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L41)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-running-const-thread-running-1-mlc-codegen-codegen-threads-ml-850239583"></a>
### THREAD_RUNNING

```ml
const THREAD_RUNNING = 1
```

Stores the thread running.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L78)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-starting-const-thread-starting-6-mlc-codegen-codegen-threads-ml-1357765630"></a>
### THREAD_STARTING

```ml
const THREAD_STARTING = 6
```

Private states used while publishing a native worker/configuration update. Status() maps them to stable public strings rather than exposing new states.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L88)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-status-const-thread-status-4-mlc-codegen-codegen-threads-ml-1311542868"></a>
### THREAD_STATUS

```ml
const THREAD_STATUS = 4
```

Stores the thread status.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L29)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-stop-const-thread-stop-32-mlc-codegen-codegen-threads-ml-811565457"></a>
### THREAD_STOP

```ml
const THREAD_STOP = 32
```

Stores the thread stop.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L37)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-stop-requested-const-thread-stop-requested-2-mlc-codegen-codegen-threads-ml-981688830"></a>
### THREAD_STOP_REQUESTED

```ml
const THREAD_STOP_REQUESTED = 2
```

Stores the thread stop requested.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L80)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-stopped-const-thread-stopped-4-mlc-codegen-codegen-threads-ml-1019797446"></a>
### THREAD_STOPPED

```ml
const THREAD_STOPPED = 4
```

Stores the thread stopped.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L84)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-tlab-cursor-const-thread-tlab-cursor-184-mlc-codegen-codegen-threads-ml-1074270817"></a>
### THREAD_TLAB_CURSOR

```ml
const THREAD_TLAB_CURSOR = 184
```

Stores the thread tlab cursor.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L63)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-tlab-end-const-thread-tlab-end-192-mlc-codegen-codegen-threads-ml-351329260"></a>
### THREAD_TLAB_END

```ml
const THREAD_TLAB_END = 192
```

Stores the thread tlab end.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L65)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-tlab-start-const-thread-tlab-start-176-mlc-codegen-codegen-threads-ml-626405522"></a>
### THREAD_TLAB_START

```ml
const THREAD_TLAB_START = 176
```

Per-thread allocation ranges carved from the shared process heap.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L61)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-tmp0-const-thread-tmp0-56-mlc-codegen-codegen-threads-ml-379722647"></a>
### THREAD_TMP0

```ml
const THREAD_TMP0 = 56
```

Stores the thread tmp0.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L43)

<a id="constant-constant-mlc-codegen-codegen-threads-thread-type-const-thread-type-0-mlc-codegen-codegen-threads-ml-102616968"></a>
### THREAD_TYPE

```ml
const THREAD_TYPE = 0
```

Native thread-context layout. Tagged managed values occupy qword fields and are scanned as GC roots; status and counters use native integer fields.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_threads.ml#L27)
