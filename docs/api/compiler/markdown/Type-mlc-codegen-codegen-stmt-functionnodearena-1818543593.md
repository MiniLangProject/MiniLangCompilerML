# `mlc.codegen.codegen_stmt.FunctionNodeArena`

[Home](README.md) · [Source file](File-mlc-codegen-codegen-stmt-ml-1158291323.md)

<a id="struct-struct-mlc-codegen-codegen-stmt-functionnodearena-struct-functionnodearena-mlc-codegen-codegen-stmt-ml-1800301380"></a>
## FunctionNodeArena

```ml
struct FunctionNodeArena
```

Typed arena for the immutable function-definition roots consumed by object emission. The integer cursor is the NodeId; parallel byte/name/node columns avoid allocating one two-element descriptor array per function.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L44)

## Members

<a id="field-field-mlc-codegen-codegen-stmt-functionnodearena-count-count-mlc-codegen-codegen-stmt-ml-696784025"></a>
### count

```ml
count
```

Stores the count member of `FunctionNodeArena`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L52)

<a id="field-field-mlc-codegen-codegen-stmt-functionnodearena-kinds-kinds-mlc-codegen-codegen-stmt-ml-1352787081"></a>
### kinds

```ml
kinds
```

Stores the kinds member of `FunctionNodeArena`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L46)

<a id="field-field-mlc-codegen-codegen-stmt-functionnodearena-names-names-mlc-codegen-codegen-stmt-ml-1351476469"></a>
### names

```ml
names
```

Stores the names member of `FunctionNodeArena`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L48)

<a id="field-field-mlc-codegen-codegen-stmt-functionnodearena-nodes-nodes-mlc-codegen-codegen-stmt-ml-1827194389"></a>
### nodes

```ml
nodes
```

Stores the nodes member of `FunctionNodeArena`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L50)
