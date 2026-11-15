# `mlc/minux_runtime.ml`

[Home](README.md) · [Files](Files.md)

Package: [`mlc.minux_runtime`](Package-mlc-minux-runtime-870572405.md)

Reachable from entry: **yes**

## Imports

- `mlc/asm.ml` as `a` → [mlc/asm.ml](File-mlc-asm-ml-1368648960.md)
- `mlc/data.ml` as `d` → [mlc/data.ml](File-mlc-data-ml-557434521.md)
- `mlc/minux_blob.ml` as `blob` → [mlc/minux_blob.ml](File-mlc-minux-blob-ml-360269822.md)
- `mlc/sysv_runtime.ml` as `sysv` → [mlc/sysv_runtime.ml](File-mlc-sysv-runtime-ml-545176255.md)
- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)
- `std/string.ml` as `s` → `std/string.ml` — external dependency

## Declarations

<a id="function-function-mlc-minux-runtime-fragment-function-fragment-state-raw-labels-patches-mlc-minux-runtime-ml-653365044"></a>
### _fragment

```ml
function _fragment(state, raw, labels, patches)
```

Append a generated runtime fragment and register its relocations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `raw` | `dynamic` | — |  |
| `labels` | `dynamic` | — |  |
| `patches` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minux_runtime.ml#L63)

<a id="function-function-mlc-minux-runtime-emit-runtime-function-emit-runtime-state-mlc-minux-runtime-ml-1791074751"></a>
### emit_runtime

```ml
function emit_runtime(state)
```

Emit MinUX services and shared SysV native marshalling.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minux_runtime.ml#L146)

<a id="function-function-mlc-minux-runtime-emit-startup-function-emit-startup-state-mlc-minux-runtime-ml-284874607"></a>
### emit_startup

```ml
function emit_startup(state)
```

Emit the MinUX process entry and argument boundary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minux_runtime.ml#L81)

<a id="function-function-mlc-minux-runtime-prepare-dynamic-imports-function-prepare-dynamic-imports-state-mlc-minux-runtime-ml-656821127"></a>
### prepare_dynamic_imports

```ml
function prepare_dynamic_imports(state)
```

Assign MinUX imports to their runtime slots.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minux_runtime.ml#L97)

<a id="function-function-mlc-minux-runtime-validate-extern-sigs-function-validate-extern-sigs-signatures-mlc-minux-runtime-ml-977346575"></a>
### validate_extern_sigs

```ml
function validate_extern_sigs(signatures)
```

Validate the native MinUX import namespace and ABI.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `signatures` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minux_runtime.ml#L15)
