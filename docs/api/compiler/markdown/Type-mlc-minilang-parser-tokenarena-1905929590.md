# `mlc.minilang_parser.TokenArena`

[Home](README.md) · [Source file](File-mlc-minilang-parser-ml-1485036712.md)

<a id="struct-struct-mlc-minilang-parser-tokenarena-struct-tokenarena-mlc-minilang-parser-ml-152883319"></a>
## TokenArena

```ml
struct TokenArena
```

Structure-of-arrays token arena. Parser cursors are integer IDs; kinds use one byte and positions/text IDs use packed u32 columns. Identifier, keyword and operator spellings are module-local symbols instead of per-token strings.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L56)

## Members

<a id="field-field-mlc-minilang-parser-tokenarena-cap-cap-mlc-minilang-parser-ml-2091069103"></a>
### cap

```ml
cap
```

Allocated capacity of `TokenArena`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L70)

<a id="field-field-mlc-minilang-parser-tokenarena-count-count-mlc-minilang-parser-ml-1566796063"></a>
### count

```ml
count
```

Count associated with `TokenArena`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L68)

<a id="field-field-mlc-minilang-parser-tokenarena-kinds-kinds-mlc-minilang-parser-ml-403319639"></a>
### kinds

```ml
kinds
```

Kinds associated with `TokenArena`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L58)

<a id="field-field-mlc-minilang-parser-tokenarena-positions-positions-mlc-minilang-parser-ml-349866527"></a>
### positions

```ml
positions
```

Positions associated with `TokenArena`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L62)

<a id="field-field-mlc-minilang-parser-tokenarena-text-index-text-index-mlc-minilang-parser-ml-1463337103"></a>
### text_index

```ml
text_index
```

Text index associated with `TokenArena`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L66)

<a id="field-field-mlc-minilang-parser-tokenarena-texts-texts-mlc-minilang-parser-ml-119586551"></a>
### texts

```ml
texts
```

Texts associated with `TokenArena`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L64)

<a id="field-field-mlc-minilang-parser-tokenarena-value-ids-value-ids-mlc-minilang-parser-ml-1879296103"></a>
### value_ids

```ml
value_ids
```

Value ids associated with `TokenArena`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L60)
