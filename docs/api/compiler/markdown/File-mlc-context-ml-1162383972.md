# `mlc/context.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc context package.

Package: [`mlc.context`](Package-mlc-context-1811740896.md)

Reachable from entry: **no**

## Declarations

<a id="function-function-mlc-context-normalizebreakablectx-function-normalizebreakablectx-kind-break-label-continue-label-break-depth-continue-depth-mlc-context-ml-1778684944"></a>
### _normalizeBreakableCtx

```ml
function _normalizeBreakableCtx(kind, break_label, continue_label, break_depth, continue_depth)
```

Track normalize breakable ctx in the compiler context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — |  |
| `break_label` | `dynamic` | — |  |
| `continue_label` | `dynamic` | — |  |
| `break_depth` | `dynamic` | — |  |
| `continue_depth` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/context.ml#L65)

<a id="constant-constant-mlc-context-breakable-ctx-default-break-depth-const-breakable-ctx-default-break-depth-0-mlc-context-ml-881131455"></a>
### BREAKABLE_CTX_DEFAULT_BREAK_DEPTH

```ml
const BREAKABLE_CTX_DEFAULT_BREAK_DEPTH = 0
```

Track breakable ctx default break depth.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/context.ml#L30)

<a id="constant-constant-mlc-context-breakable-ctx-default-continue-depth-const-breakable-ctx-default-continue-depth-0-mlc-context-ml-556584491"></a>
### BREAKABLE_CTX_DEFAULT_CONTINUE_DEPTH

```ml
const BREAKABLE_CTX_DEFAULT_CONTINUE_DEPTH = 0
```

Track breakable ctx default continue depth.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/context.ml#L32)

<a id="constant-constant-mlc-context-breakable-ctx-default-continue-label-const-breakable-ctx-default-continue-label-void-mlc-context-ml-435094119"></a>
### BREAKABLE_CTX_DEFAULT_CONTINUE_LABEL

```ml
const BREAKABLE_CTX_DEFAULT_CONTINUE_LABEL = void
```

Track breakable ctx default continue label.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/context.ml#L28)

<a id="constant-constant-mlc-context-breakable-kind-loop-const-breakable-kind-loop-loop-mlc-context-ml-955076737"></a>
### BREAKABLE_KIND_LOOP

```ml
const BREAKABLE_KIND_LOOP = "loop"
```

Track breakable kind loop.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/context.ml#L23)

<a id="constant-constant-mlc-context-breakable-kind-switch-const-breakable-kind-switch-switch-mlc-context-ml-1493795447"></a>
### BREAKABLE_KIND_SWITCH

```ml
const BREAKABLE_KIND_SWITCH = "switch"
```

Track breakable kind switch.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/context.ml#L25)

- [mlc.context.BreakableCtx](Type-mlc-context-breakablectx-858014138.md) — struct
- [mlc.context.LoopCtx](Type-mlc-context-loopctx-1851161813.md) — struct
<a id="function-function-mlc-context-newbreakablectx-function-newbreakablectx-kind-break-label-continue-label-break-depth-continue-depth-mlc-context-ml-1200315452"></a>
### newBreakableCtx

```ml
function newBreakableCtx(kind, break_label, continue_label, break_depth, continue_depth)
```

Construct a validated breakable-region descriptor.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — | Value supplied for `kind`. |
| `break_label` | `dynamic` | — | Value supplied for `break_label`. |
| `continue_label` | `dynamic` | — | Value supplied for `continue_label`. |
| `break_depth` | `dynamic` | — | Value supplied for `break_depth`. |
| `continue_depth` | `dynamic` | — | Value supplied for `continue_depth`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/context.ml#L85)

<a id="function-function-mlc-context-newloopctx-function-newloopctx-break-label-continue-label-mlc-context-ml-832310252"></a>
### newLoopCtx

```ml
function newLoopCtx(break_label, continue_label)
```

Construct the compact legacy loop context.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `break_label` | `dynamic` | — | Value supplied for `break_label`. |
| `continue_label` | `dynamic` | — | Value supplied for `continue_label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/context.ml#L59)
