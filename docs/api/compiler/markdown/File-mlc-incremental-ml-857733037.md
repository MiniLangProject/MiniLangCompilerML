# `mlc/incremental.ml`

[Home](README.md) · [Files](Files.md)

Persistent native-function fragments with semantic and layout validation.

Package: [`mlc.incremental`](Package-mlc-incremental-1536089303.md)

Reachable from entry: **yes**

## Imports

- `mlc/asm.ml` as `a` → [mlc/asm.ml](File-mlc-asm-ml-1368648960.md)
- `mlc/cache_codec.ml` as `codec` → [mlc/cache_codec.ml](File-mlc-cache-codec-ml-1019638308.md)
- `mlc/data.ml` as `d` → [mlc/data.ml](File-mlc-data-ml-557434521.md)
- `mlc/incremental_ast.ml` as `ast` → [mlc/incremental_ast.ml](File-mlc-incremental-ast-ml-368481696.md)
- `mlc/project.ml` as `project` → [mlc/project.ml](File-mlc-project-ml-1332928426.md)
- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)
- `std/checksum/crc32.ml` as `crc32` → `std/checksum/crc32.ml` — external dependency
- `std/checksum/crc32c.ml` as `crc32c` → `std/checksum/crc32c.ml` — external dependency
- `std/fs.ml` as `fs` → `std/fs.ml` — external dependency
- `std/process.ml` as `process` → `std/process.ml` — external dependency

## Declarations

<a id="global-global-mlc-incremental-cache-cache-mlc-incremental-ml-12946432"></a>
### _cache

```ml
_cache
```

Active cache is globally rooted across object-emitter collections.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L39)

<a id="function-function-mlc-incremental-advance-function-advance-value-mlc-incremental-ml-1125236979"></a>
### advance

```ml
function advance(value)
```

Fold section changes into the next fragment's input fingerprint.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Primitive value to encode or fingerprint. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L125)

<a id="function-function-mlc-incremental-begin-function-begin-state-fn-code-name-mlc-incremental-ml-1711623808"></a>
### begin

```ml
function begin(state, fn, code_name)
```

Start a fragment transaction and return its validated record, if any.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Prepared code generator and its canonical output stream. |
| `fn` | `dynamic` | — | Function declaration selected for lowering. |
| `code_name` | `dynamic` | — | Unique native symbol, including nested-function ownership. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L201)

- [mlc.incremental.Cache](Type-mlc-incremental-cache-1516575215.md) — struct
<a id="function-function-mlc-incremental-codeslice-function-codeslice-asm-start-mlc-incremental-ml-1122641071"></a>
### codeSlice

```ml
function codeSlice(asm, start)
```

Read only the new paged instruction bytes; never materialize the whole stream.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Assembler whose appended bytes or optimizer state is inspected. |
| `start` | `dynamic` | — | First byte or record offset to include. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L318)

<a id="function-function-mlc-incremental-configure-function-configure-directory-options-mlc-incremental-ml-1520143719"></a>
### configure

```ml
function configure(directory, options)
```

Configure optional caching. Compiler bytes, not version strings, identify codegen.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `directory` | `dynamic` | — | Persistent cache root selected by the caller. |
| `options` | `dynamic` | — | Effective compiler options used for invalidation. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L44)

<a id="function-function-mlc-incremental-count-function-count-chunks-tail-mlc-incremental-ml-1332936426"></a>
### count

```ml
function count(chunks, tail)
```

Count chunked records without flattening an accumulated assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chunks` | `dynamic` | — | Completed assembler record chunks. |
| `tail` | `dynamic` | — | Current partial assembler record chunk. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L161)

<a id="function-function-mlc-incremental-datapatches-function-datapatches-items-mlc-incremental-ml-1706264950"></a>
### dataPatches

```ml
function dataPatches(items)
```

Project data relocations without native pointers or class names.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — | Relocation records to project or validate. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L351)

<a id="function-function-mlc-incremental-enabled-function-enabled-mlc-incremental-ml-134257110"></a>
### enabled

```ml
function enabled()
```

Whether fragment caching is configured for this compilation.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L56)

<a id="function-function-mlc-incremental-finish-function-finish-state-transaction-mlc-incremental-ml-1599860015"></a>
### finish

```ml
function finish(state, transaction)
```

Complete a successful emission, atomically publish it, and advance the frontier.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Prepared code generator and its canonical output stream. |
| `transaction` | `dynamic` | — | Cache key, checkpoint and optional saved fragment. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L362)

<a id="function-function-mlc-incremental-initialize-function-initialize-state-mlc-incremental-ml-742290395"></a>
### initialize

```ml
function initialize(state)
```

Summarize initial labels, bytes, and pool entries once, not per function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Prepared code generator and its canonical output stream. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L134)

<a id="function-function-mlc-incremental-patches-function-patches-chunks-tail-start-mlc-incremental-ml-228459118"></a>
### patches

```ml
function patches(chunks, tail, start)
```

Project appended relocation records to primitive cache data.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chunks` | `dynamic` | — | Completed assembler record chunks. |
| `tail` | `dynamic` | — | Current partial assembler record chunk. |
| `start` | `dynamic` | — | First byte or record offset to include. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L337)

<a id="function-function-mlc-incremental-peephole-function-peephole-asm-mlc-incremental-ml-1459237629"></a>
### peephole

```ml
function peephole(asm)
```

Optimizer state crossing a function boundary (normally empty after RET).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Assembler whose appended bytes or optimizer state is inspected. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L167)

<a id="function-function-mlc-incremental-prepare-function-prepare-program-mlc-incremental-ml-2039093288"></a>
### prepare

```ml
function prepare(program)
```

Capture declarations before the frontend releases or mutates function bodies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — | Combined current AST before function bodies are released. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L62)

<a id="function-function-mlc-incremental-recordsource-function-recordsource-filename-source-mlc-incremental-ml-1694551292"></a>
### recordSource

```ml
function recordSource(filename, source)
```

Capture exactly the input parsed by the frontend, including line mappings. Re-reading later could publish old machine code under a newly saved file's key.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Canonical source path recorded by the frontend. |
| `source` | `dynamic` | — | Exact text read for parsing this module. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L193)

<a id="function-function-mlc-incremental-replay-function-replay-state-transaction-mlc-incremental-ml-624128703"></a>
### replay

```ml
function replay(state, transaction)
```

Restore code, relocation and accounting effects without rerunning lowering.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Prepared code generator and its canonical output stream. |
| `transaction` | `dynamic` | — | Cache key, checkpoint and optional saved fragment. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L447)

<a id="function-function-mlc-incremental-replaysections-function-replaysections-state-sections-mlc-incremental-ml-1099688919"></a>
### replaySections

```ml
function replaySections(state, sections)
```

Replay a previously validated append-only section journal.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Prepared code generator and its canonical output stream. |
| `sections` | `dynamic` | — | Validated section bytes, labels, pools and relocations. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L413)

<a id="function-function-mlc-incremental-report-function-report-mlc-incremental-ml-1561375244"></a>
### report

```ml
function report()
```

Report real codegen reuse separately from the whole-build artifact cache.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L483)

<a id="function-function-mlc-incremental-restorestate-function-restorestate-state-values-mlc-incremental-ml-1938508197"></a>
### restoreState

```ml
function restoreState(state, values)
```

Restore exactly the persistent effects that normal function lowering produces.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Prepared code generator and its canonical output stream. |
| `values` | `dynamic` | — | Previously validated stream-wide accounting values. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L98)

<a id="function-function-mlc-incremental-seal-function-seal-state-contracts-mlc-incremental-ml-961346152"></a>
### seal

```ml
function seal(state, contracts)
```

Include body-derived whole-program facts in every reuse decision.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Prepared code generator and its canonical output stream. |
| `contracts` | `dynamic` | — | Body-derived callee contracts that can affect callers. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L70)

<a id="function-function-mlc-incremental-sourceidentity-function-sourceidentity-filename-mlc-incremental-ml-2078511529"></a>
### sourceIdentity

```ml
function sourceIdentity(filename)
```

Memoize source identities, including inline dependency debug locations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filename` | `dynamic` | — | Canonical source path recorded by the frontend. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L183)

<a id="function-function-mlc-incremental-statevalues-function-statevalues-state-mlc-incremental-ml-204097125"></a>
### stateValues

```ml
function stateValues(state)
```

Snapshot stream-wide effects, excluding disposable analysis arenas.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Prepared code generator and its canonical output stream. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L87)

<a id="function-function-mlc-incremental-validpatches-function-validpatches-items-mlc-incremental-ml-1719536750"></a>
### validPatches

```ml
function validPatches(items)
```

Check primitive relocation tuples before touching live codegen state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — | Relocation records to project or validate. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L246)

<a id="function-function-mlc-incremental-validrecord-function-validrecord-record-start-mlc-incremental-ml-1966938323"></a>
### validRecord

```ml
function validRecord(record, start)
```

Verify record shape and bounded offsets; a malformed cache is a miss.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `record` | `dynamic` | — | Candidate primitive cache record to validate. |
| `start` | `dynamic` | — | First byte or record offset to include. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L259)
