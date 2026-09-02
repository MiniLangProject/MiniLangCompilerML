# `mlc.tools.ArrayVector`

[Home](README.md) · [Source file](File-mlc-tools-ml-988451276.md)

<a id="struct-struct-mlc-tools-arrayvector-struct-arrayvector-mlc-tools-ml-1802077997"></a>
## ArrayVector

```ml
struct ArrayVector
```

Capacity-backed mutable sequence for compiler-internal hot paths. MiniLang arrays have exact length, so repeatedly doing `items = items + [value]` copies the complete prefix. ArrayVector grows geometrically and is materialized only at API boundaries.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L89)

## Members

<a id="field-field-mlc-tools-arrayvector-cap-cap-mlc-tools-ml-1286179697"></a>
### cap

```ml
cap
```

Allocated capacity of `ArrayVector`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L95)

<a id="field-field-mlc-tools-arrayvector-data-data-mlc-tools-ml-575517417"></a>
### data

```ml
data
```

Backing data owned by `ArrayVector`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L91)

<a id="field-field-mlc-tools-arrayvector-size-size-mlc-tools-ml-761290395"></a>
### size

```ml
size
```

Current logical size of `ArrayVector`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L93)
