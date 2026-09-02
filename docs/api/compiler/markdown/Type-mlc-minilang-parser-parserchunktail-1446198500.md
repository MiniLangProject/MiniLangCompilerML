# `mlc.minilang_parser.ParserChunkTail`

[Home](README.md) · [Source file](File-mlc-minilang-parser-ml-1485036712.md)

<a id="struct-struct-mlc-minilang-parser-parserchunktail-struct-parserchunktail-mlc-minilang-parser-ml-2130274237"></a>
## ParserChunkTail

```ml
struct ParserChunkTail
```

Capacity-backed parser list tail used to avoid repeated array concatenation.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L95)

## Members

<a id="field-field-mlc-minilang-parser-parserchunktail-cap-cap-mlc-minilang-parser-ml-593279469"></a>
### cap

```ml
cap
```

Allocated capacity of `ParserChunkTail`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L101)

<a id="field-field-mlc-minilang-parser-parserchunktail-data-data-mlc-minilang-parser-ml-1840746533"></a>
### data

```ml
data
```

Backing data owned by `ParserChunkTail`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L97)

<a id="field-field-mlc-minilang-parser-parserchunktail-used-used-mlc-minilang-parser-ml-141898887"></a>
### used

```ml
used
```

Number of populated entries in `ParserChunkTail`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L99)
