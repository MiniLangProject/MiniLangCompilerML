# `mlc/codegen/codegen_opt.ml`

[Home](README.md) · [Files](Files.md)

Bounded, fail-closed local lifetime and escape analysis.

Package: [`mlc.codegen.codegen_opt`](Package-mlc-codegen-codegen-opt-461512947.md)

Reachable from entry: **yes**

## Imports

- `mlc/codegen/codegen_scope.ml` as `scope` → [mlc/codegen/codegen_scope.ml](File-mlc-codegen-codegen-scope-ml-1124416197.md)
- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)
- `std/fs.ml` as `fs` → `std/fs.ml` — external dependency
- `std/string.ml` as `s` → `std/string.ml` — external dependency

## Declarations

- [mlc.codegen.codegen_opt.Access](Type-mlc-codegen-codegen-opt-access-1882272245.md) — struct
<a id="function-function-mlc-codegen-codegen-opt-accesses-function-accesses-body-mlc-codegen-codegen-opt-ml-1916638795"></a>
### accesses

```ml
function accesses(body)
```

Return bounded AST uses, or void for unsupported syntax. Loops stay atomic.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `body` | `dynamic` | — | Ordered top-level statements of one function. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_opt.ml#L119)

<a id="function-function-mlc-codegen-codegen-opt-children-function-children-node-mlc-codegen-codegen-opt-ml-1600104443"></a>
### children

```ml
function children(node)
```

Enumerate supported semantic children. Unknown syntax disables optimization.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — | AST node or arena handle to inspect. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_opt.ml#L94)

<a id="function-function-mlc-codegen-codegen-opt-intervals-function-intervals-body-mlc-codegen-codegen-opt-ml-1010342363"></a>
### intervals

```ml
function intervals(body)
```

Whole-top-level-statement lifetimes, conservative across loops and branches.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `body` | `dynamic` | — | Ordered function statements used to bound local lifetimes. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_opt.ml#L145)

<a id="function-function-mlc-codegen-codegen-opt-name-byte-function-name-byte-value-mlc-codegen-codegen-opt-ml-1142459016"></a>
### name_byte

```ml
function name_byte(value)
```

ASCII token predicate; non-ASCII declaration names are never pruned.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | ASCII byte value to classify. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_opt.ml#L26)

<a id="function-function-mlc-codegen-codegen-opt-scalar-slot-function-scalar-slot-state-target-field-mlc-codegen-codegen-opt-ml-1131777581"></a>
### scalar_slot

```ml
function scalar_slot(state, target, field)
```

Resolve a scalar field only for its original lexical binding, not inline shadows.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Current lexical bindings and scalar-replacement plans. |
| `target` | `dynamic` | — | Receiver expression of the field access. |
| `field` | `dynamic` | — | Field name to resolve to a rooted stack slot. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_opt.ml#L205)

<a id="function-function-mlc-codegen-codegen-opt-scalar-uses-function-scalar-uses-records-declaration-index-fields-mlc-codegen-codegen-opt-ml-1870508664"></a>
### scalar_uses

```ml
function scalar_uses(records, declaration, index, fields)
```

Reject every use except known field reads/writes after the constructor.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `records` | `dynamic` | — | Bounded AST access records for the function. |
| `declaration` | `dynamic` | — | Original local constructor assignment. |
| `index` | `dynamic` | — | Top-level statement index of the constructor. |
| `fields` | `dynamic` | — | Known untyped field names in declaration order. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_opt.ml#L181)

<a id="function-function-mlc-codegen-codegen-opt-unused-functions-function-unused-functions-state-mlc-codegen-codegen-opt-ml-320904552"></a>
### unused_functions

```ml
function unused_functions(state)
```

Prove source-unreferenced functions, conservatively counting comments and strings too. Methods, generated names and profiling retain native bodies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Code-generation state with loaded source and declaration metadata. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_opt.ml#L33)
