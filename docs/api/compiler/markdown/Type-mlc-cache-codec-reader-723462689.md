# `mlc.cache_codec.Reader`

[Home](README.md) · [Source file](File-mlc-cache-codec-ml-1019638308.md)

<a id="struct-struct-mlc-cache-codec-reader-struct-reader-mlc-cache-codec-ml-4146055"></a>
## Reader

```ml
struct Reader
```

Bounded reader; no executable source or native pointers are deserialized.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L22)

## Members

<a id="field-field-mlc-cache-codec-reader-data-data-mlc-cache-codec-ml-1498603574"></a>
### data

```ml
data
```

Input bytes.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L24)

<a id="field-field-mlc-cache-codec-reader-pos-pos-mlc-cache-codec-ml-378131110"></a>
### pos

```ml
pos
```

Next byte offset.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L26)

<a id="field-field-mlc-cache-codec-reader-remaining-remaining-mlc-cache-codec-ml-1957196990"></a>
### remaining

```ml
remaining
```

Remaining node budget to bound malicious nesting and array expansion.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L30)

<a id="field-field-mlc-cache-codec-reader-valid-valid-mlc-cache-codec-ml-39027574"></a>
### valid

```ml
valid
```

Whether all checks have passed.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/cache_codec.ml#L28)
