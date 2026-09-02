# `mlc/errors.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc errors package.

Package: [`mlc.errors`](Package-mlc-errors-1767385834.md)

Reachable from entry: **no**

## Declarations

- [mlc.errors.CompileError](Type-mlc-errors-compileerror-1561902893.md) — struct
- [mlc.errors.Diagnostic](Type-mlc-errors-diagnostic-936437267.md) — struct
- [mlc.errors.MultiCompileError](Type-mlc-errors-multicompileerror-1671925724.md) — struct
<a id="function-function-mlc-errors-newcompileerror-function-newcompileerror-message-pos-filename-mlc-errors-ml-1839399204"></a>
### newCompileError

```ml
function newCompileError(message, pos, filename)
```

Construct a fatal compile error record.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `message` | `dynamic` | — | Value supplied for `message`. |
| `pos` | `dynamic` | — | Value supplied for `pos`. |
| `filename` | `dynamic` | — | Value supplied for `filename`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/errors.ml#L56)

<a id="function-function-mlc-errors-newdiagnostic-function-newdiagnostic-kind-message-filename-pos-source-mlc-errors-ml-794180763"></a>
### newDiagnostic

```ml
function newDiagnostic(kind, message, filename, pos, source)
```

Construct one normalized source diagnostic.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — | Value supplied for `kind`. |
| `message` | `dynamic` | — | Value supplied for `message`. |
| `filename` | `dynamic` | — | Value supplied for `filename`. |
| `pos` | `dynamic` | — | Value supplied for `pos`. |
| `source` | `dynamic` | — | Source value to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/errors.ml#L66)

<a id="function-function-mlc-errors-newmulticompileerror-function-newmulticompileerror-diags-mlc-errors-ml-2045908612"></a>
### newMultiCompileError

```ml
function newMultiCompileError(diags)
```

Wrap an ordered diagnostic collection as one error value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `diags` | `dynamic` | — | Value supplied for `diags`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/errors.ml#L72)
