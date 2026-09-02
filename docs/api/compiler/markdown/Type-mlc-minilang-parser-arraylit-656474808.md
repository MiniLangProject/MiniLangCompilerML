# `mlc.minilang_parser.ArrayLit`

[Home](README.md) · [Source file](File-mlc-minilang-parser-ml-1485036712.md)

<a id="struct-struct-mlc-minilang-parser-arraylit-struct-arraylit-mlc-minilang-parser-ml-464518227"></a>
## ArrayLit

```ml
struct ArrayLit
```

Represents array lit.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L169)

## Members

<a id="field-field-mlc-minilang-parser-arraylit-filename-filename-mlc-minilang-parser-ml-353602957"></a>
### _filename

```ml
_filename
```

Filename associated with `ArrayLit`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L181)

<a id="field-field-mlc-minilang-parser-arraylit-pos-pos-mlc-minilang-parser-ml-730523727"></a>
### _pos

```ml
_pos
```

Pos associated with `ArrayLit`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L179)

<a id="field-field-mlc-minilang-parser-arraylit-items-items-mlc-minilang-parser-ml-479284597"></a>
### items

```ml
items
```

Items associated with `ArrayLit`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L173)

<a id="field-field-mlc-minilang-parser-arraylit-node-kind-node-kind-mlc-minilang-parser-ml-896999065"></a>
### node_kind

```ml
node_kind
```

Node kind associated with `ArrayLit`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L171)

<a id="field-field-mlc-minilang-parser-arraylit-stack-variadic-stack-variadic-mlc-minilang-parser-ml-1151634857"></a>
### stack_variadic

```ml
stack_variadic
```

Internal-only marker: a proven non-escaping variadic tail may live in the caller's rooted expression stack instead of allocating a heap array. Stack variadic associated with `ArrayLit`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L177)
