# `mlc/incremental_ast.ml`

[Home](README.md) · [Files](Files.md)

Deterministic AST declaration projection for incremental invalidation.

Package: [`mlc.incremental_ast`](Package-mlc-incremental-ast-980390788.md)

Reachable from entry: **yes**

## Imports

- `mlc/cache_codec.ml` as `codec` → [mlc/cache_codec.ml](File-mlc-cache-codec-ml-1019638308.md)
- `mlc/data.ml` as `d` → [mlc/data.ml](File-mlc-data-ml-557434521.md)
- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)
- `std/string.ml` as `s` → `std/string.ml` — external dependency

## Declarations

<a id="function-function-mlc-incremental-ast-interfacekey-function-interfacekey-program-mlc-incremental-ast-ml-1340762618"></a>
### interfaceKey

```ml
function interfaceKey(program)
```

Hash the declaration view without retaining the source AST in the cache.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — | Combined current AST before function bodies are released. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental_ast.ml#L328)

<a id="function-function-mlc-incremental-ast-write-function-write-w-node-headers-only-mlc-incremental-ast-ml-1222827436"></a>
### write

```ml
function write(w, node, headers_only)
```

Write a complete AST value or an headers_only with ordinary function bodies omitted. Source positions are excluded: per-module content identities cover debug locations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `w` | `dynamic` | — | Mutable primitive encoder. |
| `node` | `dynamic` | — | AST value to project. |
| `headers_only` | `dynamic` | — | Whether ordinary function bodies should be excluded. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental_ast.ml#L15)

<a id="function-function-mlc-incremental-ast-writenode-function-writenode-w-node-headers-only-mlc-incremental-ast-ml-1871518616"></a>
### writeNode

```ml
function writeNode(w, node, headers_only)
```

Project one node after checking the recursion budget in write().

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `w` | `dynamic` | — | Mutable primitive encoder. |
| `node` | `dynamic` | — | AST value to project. |
| `headers_only` | `dynamic` | — | Whether ordinary function bodies should be excluded. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental_ast.ml#L28)
