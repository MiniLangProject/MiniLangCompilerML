# `mlc.cache_codec.Writer`

[Home](README.md) · [Source file](File-mlc-cache-codec-ml-1019638308.md)

<a id="struct-struct-mlc-cache-codec-writer-struct-writer-mlc-cache-codec-ml-547944987"></a>
## Writer

```ml
struct Writer
```

Compact growable encoder; small cache keys do not allocate a 64-KiB page.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L10)

## Members

<a id="field-field-mlc-cache-codec-writer-ast-depth-ast-depth-mlc-cache-codec-ml-139133714"></a>
### ast_depth

```ml
ast_depth
```

AST visitor recursion depth, independent of primitive array serialization.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L18)

<a id="field-field-mlc-cache-codec-writer-data-data-mlc-cache-codec-ml-767126018"></a>
### data

```ml
data
```

Capacity-backed bytes.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L12)

<a id="field-field-mlc-cache-codec-writer-used-used-mlc-cache-codec-ml-1271163960"></a>
### used

```ml
used
```

Logical byte count.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L14)

<a id="field-field-mlc-cache-codec-writer-valid-valid-mlc-cache-codec-ml-46479602"></a>
### valid

```ml
valid
```

Whether every value has a supported representation.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L16)
