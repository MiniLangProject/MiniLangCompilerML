# `mlc.minilang_parser.LazyIteratorState`

[Home](README.md) · [Source file](File-mlc-minilang-parser-ml-1485036712.md)

<a id="struct-struct-mlc-minilang-parser-lazyiteratorstate-struct-lazyiteratorstate-mlc-minilang-parser-ml-4089679"></a>
## LazyIteratorState

```ml
struct LazyIteratorState
```

Mutable construction state for a lazy iterator's pull-closure state machine. Integer state IDs keep suspension/resumption explicit and avoid materializing yielded elements in an intermediate array.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5035)

## Members

<a id="field-field-mlc-minilang-parser-lazyiteratorstate-blocks-blocks-mlc-minilang-parser-ml-88808200"></a>
### blocks

```ml
blocks
```

Stores the blocks member of `LazyIteratorState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5041)

<a id="field-field-mlc-minilang-parser-lazyiteratorstate-fn-fn-mlc-minilang-parser-ml-215731472"></a>
### fn

```ml
fn
```

Stores the fn member of `LazyIteratorState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5037)

<a id="field-field-mlc-minilang-parser-lazyiteratorstate-globals-declared-globals-declared-mlc-minilang-parser-ml-1795633630"></a>
### globals_declared

```ml
globals_declared
```

Stores the globals declared member of `LazyIteratorState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5045)

<a id="field-field-mlc-minilang-parser-lazyiteratorstate-persistent-persistent-mlc-minilang-parser-ml-821199862"></a>
### persistent

```ml
persistent
```

Stores the persistent member of `LazyIteratorState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5043)

<a id="field-field-mlc-minilang-parser-lazyiteratorstate-state-name-state-name-mlc-minilang-parser-ml-2092761194"></a>
### state_name

```ml
state_name
```

Stores the state name member of `LazyIteratorState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5039)
