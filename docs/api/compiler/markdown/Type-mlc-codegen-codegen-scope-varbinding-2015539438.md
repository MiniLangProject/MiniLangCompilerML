# `mlc.codegen.codegen_scope.VarBinding`

[Home](README.md) · [Source file](File-mlc-codegen-codegen-scope-ml-1124416197.md)

<a id="struct-struct-mlc-codegen-codegen-scope-varbinding-struct-varbinding-mlc-codegen-codegen-scope-ml-1270474888"></a>
## VarBinding

```ml
struct VarBinding
```

One resolved variable binding, including storage, capture and const metadata. promoted_xmm is an optional nonvolatile register mirror; the stack slot stays authoritative so GC metadata, diagnostics and native interop remain stable.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L27)

## Members

<a id="field-field-mlc-codegen-codegen-scope-varbinding-boxed-boxed-mlc-codegen-codegen-scope-ml-24671854"></a>
### boxed

```ml
boxed
```

Boxed associated with `VarBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L41)

<a id="field-field-mlc-codegen-codegen-scope-varbinding-capture-depth-capture-depth-mlc-codegen-codegen-scope-ml-785376450"></a>
### capture_depth

```ml
capture_depth
```

Capture depth associated with `VarBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L43)

<a id="field-field-mlc-codegen-codegen-scope-varbinding-capture-index-capture-index-mlc-codegen-codegen-scope-ml-2055509194"></a>
### capture_index

```ml
capture_index
```

Capture index associated with `VarBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L45)

<a id="field-field-mlc-codegen-codegen-scope-varbinding-const-expr-const-expr-mlc-codegen-codegen-scope-ml-97666140"></a>
### const_expr

```ml
const_expr
```

Const expr associated with `VarBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L51)

<a id="field-field-mlc-codegen-codegen-scope-varbinding-const-initialized-const-initialized-mlc-codegen-codegen-scope-ml-600623374"></a>
### const_initialized

```ml
const_initialized
```

Const initialized associated with `VarBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L53)

<a id="field-field-mlc-codegen-codegen-scope-varbinding-const-value-encoded-const-value-encoded-mlc-codegen-codegen-scope-ml-460275758"></a>
### const_value_encoded

```ml
const_value_encoded
```

Const value encoded associated with `VarBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L57)

<a id="field-field-mlc-codegen-codegen-scope-varbinding-const-value-label-const-value-label-mlc-codegen-codegen-scope-ml-344663934"></a>
### const_value_label

```ml
const_value_label
```

Const value label associated with `VarBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L59)

<a id="field-field-mlc-codegen-codegen-scope-varbinding-const-value-py-const-value-py-mlc-codegen-codegen-scope-ml-125023200"></a>
### const_value_py

```ml
const_value_py
```

Const value py associated with `VarBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L55)

<a id="field-field-mlc-codegen-codegen-scope-varbinding-decl-node-decl-node-mlc-codegen-codegen-scope-ml-1486028474"></a>
### decl_node

```ml
decl_node
```

Decl node associated with `VarBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L47)

<a id="field-field-mlc-codegen-codegen-scope-varbinding-depth-depth-mlc-codegen-codegen-scope-ml-200427166"></a>
### depth

```ml
depth
```

Depth associated with `VarBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L39)

<a id="field-field-mlc-codegen-codegen-scope-varbinding-id-id-mlc-codegen-codegen-scope-ml-1891362068"></a>
### id

```ml
id
```

Id associated with `VarBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L29)

<a id="field-field-mlc-codegen-codegen-scope-varbinding-is-const-is-const-mlc-codegen-codegen-scope-ml-542711602"></a>
### is_const

```ml
is_const
```

Whether `VarBinding.is_const` indicates const.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L49)

<a id="field-field-mlc-codegen-codegen-scope-varbinding-kind-kind-mlc-codegen-codegen-scope-ml-1576309774"></a>
### kind

```ml
kind
```

Kind associated with `VarBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L33)

<a id="field-field-mlc-codegen-codegen-scope-varbinding-label-label-mlc-codegen-codegen-scope-ml-274096078"></a>
### label

```ml
label
```

Label associated with `VarBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L35)

<a id="field-field-mlc-codegen-codegen-scope-varbinding-name-name-mlc-codegen-codegen-scope-ml-1570852852"></a>
### name

```ml
name
```

Name associated with `VarBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L31)

<a id="field-field-mlc-codegen-codegen-scope-varbinding-offset-offset-mlc-codegen-codegen-scope-ml-1379472116"></a>
### offset

```ml
offset
```

Offset associated with `VarBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L37)

<a id="field-field-mlc-codegen-codegen-scope-varbinding-promoted-xmm-promoted-xmm-mlc-codegen-codegen-scope-ml-365647944"></a>
### promoted_xmm

```ml
promoted_xmm
```

Promoted xmm associated with `VarBinding`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L61)
