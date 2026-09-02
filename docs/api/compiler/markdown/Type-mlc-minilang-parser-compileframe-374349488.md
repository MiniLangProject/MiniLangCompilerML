# `mlc.minilang_parser.CompileFrame`

[Home](README.md) · [Source file](File-mlc-minilang-parser-ml-1485036712.md)

<a id="struct-struct-mlc-minilang-parser-compileframe-struct-compileframe-mlc-minilang-parser-ml-1091659711"></a>
## CompileFrame

```ml
struct CompileFrame
```

Mutable state for one nested #if/#elif/#else group.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L893)

## Members

<a id="field-field-mlc-minilang-parser-compileframe-active-active-mlc-minilang-parser-ml-1509600313"></a>
### active

```ml
active
```

Stores the active member of `CompileFrame`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L897)

<a id="field-field-mlc-minilang-parser-compileframe-else-seen-else-seen-mlc-minilang-parser-ml-1791076837"></a>
### else_seen

```ml
else_seen
```

Stores the else seen member of `CompileFrame`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L901)

<a id="field-field-mlc-minilang-parser-compileframe-parent-active-parent-active-mlc-minilang-parser-ml-2105685761"></a>
### parent_active

```ml
parent_active
```

Stores the parent active member of `CompileFrame`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L895)

<a id="field-field-mlc-minilang-parser-compileframe-pos-pos-mlc-minilang-parser-ml-1487026313"></a>
### pos

```ml
pos
```

Stores the pos member of `CompileFrame`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L903)

<a id="field-field-mlc-minilang-parser-compileframe-taken-taken-mlc-minilang-parser-ml-1984627149"></a>
### taken

```ml
taken
```

Stores the taken member of `CompileFrame`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L899)
