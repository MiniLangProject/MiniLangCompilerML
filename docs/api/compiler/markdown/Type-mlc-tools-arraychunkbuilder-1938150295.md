# `mlc.tools.ArrayChunkBuilder`

[Home](README.md) · [Source file](File-mlc-tools-ml-988451276.md)

<a id="struct-struct-mlc-tools-arraychunkbuilder-struct-arraychunkbuilder-mlc-tools-ml-2135845315"></a>
## ArrayChunkBuilder

```ml
struct ArrayChunkBuilder
```

Append-only array builder that avoids copying a growing prefix.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L63)

## Members

<a id="field-field-mlc-tools-arraychunkbuilder-cap-cap-mlc-tools-ml-2049237472"></a>
### cap

```ml
cap
```

Stores the cap member of `ArrayChunkBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L69)

<a id="field-field-mlc-tools-arraychunkbuilder-chunks-chunks-mlc-tools-ml-1064649448"></a>
### chunks

```ml
chunks
```

Stores the chunks member of `ArrayChunkBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L65)

<a id="field-field-mlc-tools-arraychunkbuilder-tail-tail-mlc-tools-ml-69832856"></a>
### tail

```ml
tail
```

Stores the tail member of `ArrayChunkBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L67)
