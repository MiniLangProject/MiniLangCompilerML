# `mlc/sysv_runtime.ml`

[Home](README.md) · [Files](Files.md)

Package: [`mlc.sysv_runtime`](Package-mlc-sysv-runtime-742954207.md)

Reachable from entry: **yes**

## Imports

- `mlc/asm.ml` as `a` → [mlc/asm.ml](File-mlc-asm-ml-1368648960.md)
- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)
- `std/string.ml` as `s` → `std/string.ml` — external dependency

## Declarations

<a id="function-function-mlc-sysv-runtime-array-has-function-array-has-values-wanted-mlc-sysv-runtime-ml-1149111971"></a>
### _array_has

```ml
function _array_has(values, wanted)
```

Emit array has for the Linux x64 runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `dynamic` | — |  |
| `wanted` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/sysv_runtime.ml#L51)

<a id="function-function-mlc-sysv-runtime-extern-param-type-function-extern-param-type-param-mlc-sysv-runtime-ml-1484235229"></a>
### _extern_param_type

```ml
function _extern_param_type(param)
```

Emit extern param type for the Linux x64 runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `param` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/sysv_runtime.ml#L38)

- [mlc.sysv_runtime.DynamicImport](Type-mlc-sysv-runtime-dynamicimport-919410613.md) — struct
- [mlc.sysv_runtime.DynamicImportsResult](Type-mlc-sysv-runtime-dynamicimportsresult-1387856203.md) — struct
<a id="function-function-mlc-sysv-runtime-emit-extern-thunks-function-emit-extern-thunks-state-eager-mlc-sysv-runtime-ml-1273104865"></a>
### emit_extern_thunks

```ml
function emit_extern_thunks(state, eager)
```

Translate MiniLang's stable Win64-like native ABI to SysV.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `eager` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/sysv_runtime.ml#L61)

- [mlc.sysv_runtime.ThunkDestination](Type-mlc-sysv-runtime-thunkdestination-1016988627.md) — struct
