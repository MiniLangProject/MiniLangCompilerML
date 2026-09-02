# `mlc.codegen.codegen_scope.CallableBinding`

[Home](README.md) · [Source file](File-mlc-codegen-codegen-scope-ml-1124416197.md)

<a id="struct-struct-mlc-codegen-codegen-scope-callablebinding-struct-callablebinding-mlc-codegen-codegen-scope-ml-1396830488"></a>
## CallableBinding

```ml
struct CallableBinding
```

Compact immutable-signature binding for function/struct/builtin/extern objects. These globals can be rebound at runtime but never participate in constexpr initialization, so retaining five const-evaluation fields per callable only inflates the compiler's permanent root scope.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L65)

## Members

<a id="field-field-mlc-codegen-codegen-scope-callablebinding-boxed-boxed-mlc-codegen-codegen-scope-ml-2021301123"></a>
### boxed

```ml
boxed
```

Boxed associated with `CallableBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L79)

<a id="field-field-mlc-codegen-codegen-scope-callablebinding-capture-depth-capture-depth-mlc-codegen-codegen-scope-ml-1570044095"></a>
### capture_depth

```ml
capture_depth
```

Capture depth associated with `CallableBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L81)

<a id="field-field-mlc-codegen-codegen-scope-callablebinding-capture-index-capture-index-mlc-codegen-codegen-scope-ml-885718087"></a>
### capture_index

```ml
capture_index
```

Capture index associated with `CallableBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L83)

<a id="field-field-mlc-codegen-codegen-scope-callablebinding-decl-node-decl-node-mlc-codegen-codegen-scope-ml-444473599"></a>
### decl_node

```ml
decl_node
```

Decl node associated with `CallableBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L85)

<a id="field-field-mlc-codegen-codegen-scope-callablebinding-depth-depth-mlc-codegen-codegen-scope-ml-262426003"></a>
### depth

```ml
depth
```

Depth associated with `CallableBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L77)

<a id="field-field-mlc-codegen-codegen-scope-callablebinding-id-id-mlc-codegen-codegen-scope-ml-920435481"></a>
### id

```ml
id
```

Id associated with `CallableBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L67)

<a id="field-field-mlc-codegen-codegen-scope-callablebinding-is-const-is-const-mlc-codegen-codegen-scope-ml-1723750147"></a>
### is_const

```ml
is_const
```

Whether `CallableBinding.is_const` indicates const.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L87)

<a id="field-field-mlc-codegen-codegen-scope-callablebinding-kind-kind-mlc-codegen-codegen-scope-ml-1450759655"></a>
### kind

```ml
kind
```

Kind associated with `CallableBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L71)

<a id="field-field-mlc-codegen-codegen-scope-callablebinding-label-label-mlc-codegen-codegen-scope-ml-1887916387"></a>
### label

```ml
label
```

Label associated with `CallableBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L73)

<a id="field-field-mlc-codegen-codegen-scope-callablebinding-name-name-mlc-codegen-codegen-scope-ml-648500421"></a>
### name

```ml
name
```

Name associated with `CallableBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L69)

<a id="field-field-mlc-codegen-codegen-scope-callablebinding-offset-offset-mlc-codegen-codegen-scope-ml-1624834369"></a>
### offset

```ml
offset
```

Offset associated with `CallableBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L75)

<a id="field-field-mlc-codegen-codegen-scope-callablebinding-promoted-xmm-promoted-xmm-mlc-codegen-codegen-scope-ml-312877277"></a>
### promoted_xmm

```ml
promoted_xmm
```

Promoted xmm associated with `CallableBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L89)
