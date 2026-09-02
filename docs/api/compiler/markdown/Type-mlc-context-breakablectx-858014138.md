# `mlc.context.BreakableCtx`

[Home](README.md) · [Source file](File-mlc-context-ml-1162383972.md)

<a id="struct-struct-mlc-context-breakablectx-struct-breakablectx-mlc-context-ml-1930572279"></a>
## BreakableCtx

```ml
struct BreakableCtx
```

Unified loop/switch target plus cleanup depths for non-local exits.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/context.ml#L43)

## Members

<a id="field-field-mlc-context-breakablectx-break-depth-break-depth-mlc-context-ml-320875135"></a>
### break_depth

```ml
break_depth
```

Break depth associated with `BreakableCtx`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/context.ml#L51)

<a id="field-field-mlc-context-breakablectx-break-label-break-label-mlc-context-ml-1119457559"></a>
### break_label

```ml
break_label
```

Break label associated with `BreakableCtx`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/context.ml#L47)

<a id="field-field-mlc-context-breakablectx-continue-depth-continue-depth-mlc-context-ml-1788871925"></a>
### continue_depth

```ml
continue_depth
```

Continue depth associated with `BreakableCtx`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/context.ml#L53)

<a id="field-field-mlc-context-breakablectx-continue-label-continue-label-mlc-context-ml-89466923"></a>
### continue_label

```ml
continue_label
```

Continue label associated with `BreakableCtx`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/context.ml#L49)

<a id="field-field-mlc-context-breakablectx-kind-kind-mlc-context-ml-686364311"></a>
### kind

```ml
kind
```

Kind associated with `BreakableCtx`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/context.ml#L45)
