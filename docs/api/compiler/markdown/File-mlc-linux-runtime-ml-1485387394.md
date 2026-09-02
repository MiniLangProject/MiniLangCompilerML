# `mlc/linux_runtime.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc linux_runtime package.

Package: [`mlc.linux_runtime`](Package-mlc-linux-runtime-1318353858.md)

Reachable from entry: **yes**

## Imports

- `mlc/asm.ml` as `a` → [mlc/asm.ml](File-mlc-asm-ml-1368648960.md)
- `mlc/data.ml` as `d` → [mlc/data.ml](File-mlc-data-ml-557434521.md)
- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)
- `std/string.ml` as `s` → `std/string.ml` — external dependency

## Declarations

<a id="function-function-mlc-linux-runtime-array-has-function-array-has-values-wanted-mlc-linux-runtime-ml-1454112207"></a>
### _array_has

```ml
function _array_has(values, wanted)
```

Emit array has for the Linux x64 runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |
| `wanted` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/linux_runtime.ml#L242)

<a id="function-function-mlc-linux-runtime-emit-extern-thunks-function-emit-extern-thunks-state-mlc-linux-runtime-ml-220175397"></a>
### _emit_extern_thunks

```ml
function _emit_extern_thunks(state)
```

Translate MiniLang's stable Win64-like native ABI to Linux SysV.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/linux_runtime.ml#L252)

<a id="function-function-mlc-linux-runtime-extern-dll-base-function-extern-dll-base-dll-mlc-linux-runtime-ml-1882968546"></a>
### _extern_dll_base

```ml
function _extern_dll_base(dll)
```

Emit extern dll base for the Linux x64 runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dll` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/linux_runtime.ml#L75)

<a id="function-function-mlc-linux-runtime-extern-param-type-function-extern-param-type-param-mlc-linux-runtime-ml-1745883699"></a>
### _extern_param_type

```ml
function _extern_param_type(param)
```

Emit extern param type for the Linux x64 runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `param` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/linux_runtime.ml#L229)

<a id="function-function-mlc-linux-runtime-pthread-runtime-blob-function-pthread-runtime-blob-mlc-linux-runtime-ml-494942306"></a>
### _pthread_runtime_blob

```ml
function _pthread_runtime_blob()
```

Generated pthread-backed replacement for the legacy CreateThread through CloseHandle portion of _runtime_blob. Internal branches are pre-resolved; the three dynamic pthread calls are registered as RIP patches by emit_runtime.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/linux_runtime.ml#L222)

<a id="function-function-mlc-linux-runtime-runtime-blob-raw-function-runtime-blob-raw-mlc-linux-runtime-ml-1501145666"></a>
### _runtime_blob_raw

```ml
function _runtime_blob_raw()
```

Emit runtime blob raw for the Linux x64 runtime.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/linux_runtime.ml#L202)

<a id="function-function-mlc-linux-runtime-runtime-labels-function-runtime-labels-mlc-linux-runtime-ml-971158720"></a>
### _runtime_labels

```ml
function _runtime_labels()
```

Emit runtime labels for the Linux x64 runtime.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/linux_runtime.ml#L173)

<a id="function-function-mlc-linux-runtime-runtime-non-thread-parts-function-runtime-non-thread-parts-mlc-linux-runtime-ml-513965488"></a>
### _runtime_non_thread_parts

```ml
function _runtime_non_thread_parts()
```

Split the stable non-thread helpers around the complete superseded native thread range. emit_runtime inserts the canonical pthread block between them.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/linux_runtime.ml#L213)

- [mlc.linux_runtime.DynamicImport](Type-mlc-linux-runtime-dynamicimport-249578260.md) — struct
- [mlc.linux_runtime.DynamicImportsResult](Type-mlc-linux-runtime-dynamicimportsresult-1949239652.md) — struct
<a id="function-function-mlc-linux-runtime-emit-runtime-function-emit-runtime-state-mlc-linux-runtime-ml-2109134943"></a>
### emit_runtime

```ml
function emit_runtime(state)
```

Emit emit runtime for the Linux x64 runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/linux_runtime.ml#L469)

<a id="function-function-mlc-linux-runtime-emit-startup-function-emit-startup-state-mlc-linux-runtime-ml-1287943791"></a>
### emit_startup

```ml
function emit_startup(state)
```

Emit emit startup for the Linux x64 runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/linux_runtime.ml#L133)

<a id="function-function-mlc-linux-runtime-prepare-dynamic-imports-function-prepare-dynamic-imports-state-mlc-linux-runtime-ml-221971075"></a>
### prepare_dynamic_imports

```ml
function prepare_dynamic_imports(state)
```

Allocate writable slots that the Linux dynamic loader fills for externs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/linux_runtime.ml#L81)

<a id="constant-constant-mlc-linux-runtime-runtime-exit-syscall-offset-const-runtime-exit-syscall-offset-123-mlc-linux-runtime-ml-984858735"></a>
### RUNTIME_EXIT_SYSCALL_OFFSET

```ml
const RUNTIME_EXIT_SYSCALL_OFFSET = 123
```

Stable boundaries inside the checked-in syscall blob. The legacy thread implementation is excluded as one named range and replaced below; keeping these values together prevents unrelated slice/relocation magic numbers.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/linux_runtime.ml#L61)

<a id="constant-constant-mlc-linux-runtime-runtime-legacy-thread-end-const-runtime-legacy-thread-end-1361-mlc-linux-runtime-ml-1726712644"></a>
### RUNTIME_LEGACY_THREAD_END

```ml
const RUNTIME_LEGACY_THREAD_END = 1361
```

Track runtime legacy thread end.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/linux_runtime.ml#L65)

<a id="constant-constant-mlc-linux-runtime-runtime-legacy-thread-start-const-runtime-legacy-thread-start-497-mlc-linux-runtime-ml-2054419007"></a>
### RUNTIME_LEGACY_THREAD_START

```ml
const RUNTIME_LEGACY_THREAD_START = 497
```

Track runtime legacy thread start.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/linux_runtime.ml#L63)

<a id="constant-constant-mlc-linux-runtime-runtime-pthread-close-patch-const-runtime-pthread-close-patch-1441-mlc-linux-runtime-ml-2122327885"></a>
### RUNTIME_PTHREAD_CLOSE_PATCH

```ml
const RUNTIME_PTHREAD_CLOSE_PATCH = 1441
```

Track runtime pthread close patch.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/linux_runtime.ml#L71)

<a id="constant-constant-mlc-linux-runtime-runtime-pthread-create-patch-const-runtime-pthread-create-patch-692-mlc-linux-runtime-ml-1010416920"></a>
### RUNTIME_PTHREAD_CREATE_PATCH

```ml
const RUNTIME_PTHREAD_CREATE_PATCH = 692
```

Track runtime pthread create patch.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/linux_runtime.ml#L67)

<a id="constant-constant-mlc-linux-runtime-runtime-pthread-wait-patch-const-runtime-pthread-wait-patch-1159-mlc-linux-runtime-ml-1111673989"></a>
### RUNTIME_PTHREAD_WAIT_PATCH

```ml
const RUNTIME_PTHREAD_WAIT_PATCH = 1159
```

Track runtime pthread wait patch.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/linux_runtime.ml#L69)

- [mlc.linux_runtime.RuntimeLabel](Type-mlc-linux-runtime-runtimelabel-1770338598.md) — struct
- [mlc.linux_runtime.ThunkDestination](Type-mlc-linux-runtime-thunkdestination-2076075712.md) — struct
