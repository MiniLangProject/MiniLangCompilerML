# `mlc/frontend.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc frontend package.

Package: [`mlc.frontend`](Package-mlc-frontend-839095705.md)

Reachable from entry: **yes**

## Imports

- `mlc/incremental.ml` as `incremental` → [mlc/incremental.ml](File-mlc-incremental-ml-857733037.md)
- `mlc/minilang_parser.ml` as `parser` → [mlc/minilang_parser.ml](File-mlc-minilang-parser-ml-1485036712.md)
- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)
- `std/fs.ml` as `fs` → `std/fs.ml` — external dependency

## Declarations

<a id="function-function-mlc-frontend-is-alnum-byte-inline-function-is-alnum-byte-ch-mlc-frontend-ml-1295318798"></a>
### _is_alnum_byte

```ml
inline function _is_alnum_byte(ch)
```

Process inline in the shared MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ch` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/frontend.ml#L50)

<a id="function-function-mlc-frontend-is-digit-byte-inline-function-is-digit-byte-ch-mlc-frontend-ml-1062943722"></a>
### _is_digit_byte

```ml
inline function _is_digit_byte(ch)
```

Process inline in the shared MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ch` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/frontend.ml#L44)

<a id="function-function-mlc-frontend-is-space-byte-inline-function-is-space-byte-ch-mlc-frontend-ml-418837300"></a>
### _is_space_byte

```ml
inline function _is_space_byte(ch)
```

Process inline in the shared MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ch` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/frontend.ml#L38)

<a id="function-function-mlc-frontend-normalize-frontend-error-function-normalize-frontend-error-err-fallback-path-mlc-frontend-ml-726009547"></a>
### _normalize_frontend_error

```ml
function _normalize_frontend_error(err, fallback_path)
```

Process normalize frontend error in the shared MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `err` | `dynamic` | — |  |
| `fallback_path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/frontend.ml#L56)

<a id="function-function-mlc-frontend-normalize-frontend-errors-function-normalize-frontend-errors-errors-fallback-path-mlc-frontend-ml-1936042109"></a>
### _normalize_frontend_errors

```ml
function _normalize_frontend_errors(errors, fallback_path)
```

Process normalize frontend errors in the shared MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `errors` | `dynamic` | — |  |
| `fallback_path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/frontend.ml#L79)

- [mlc.frontend.FrontendParseResult](Type-mlc-frontend-frontendparseresult-671687677.md) — struct
<a id="function-function-mlc-frontend-load-minilang-frontend-function-load-minilang-frontend-path-mlc-frontend-ml-1616731493"></a>
### load_minilang_frontend

```ml
function load_minilang_frontend(path)
```

Report frontend availability; the self-host build links it statically.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path to operate on. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/frontend.ml#L249)

<a id="function-function-mlc-frontend-normalize-code-for-tokenizer-function-normalize-code-for-tokenizer-src-mlc-frontend-ml-2075062608"></a>
### normalize_code_for_tokenizer

```ml
function normalize_code_for_tokenizer(src)
```

Normalize comments/newlines while preserving source offsets for diagnostics. Operate on one capacity-backed UTF-8 byte buffer: the previous character- string builder allocated one managed string and one array slot per source byte, which dominated frontend memory on large self-hosted compilations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/frontend.ml#L97)

<a id="function-function-mlc-frontend-parse-program-function-parse-program-path-mlc-frontend-ml-452933877"></a>
### parse_program

```ml
function parse_program(path)
```

Load and parse one file, returning syntax failures in the result record.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path to operate on. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/frontend.ml#L217)

<a id="function-function-mlc-frontend-parse-program-keepgoing-function-parse-program-keepgoing-path-max-errors-mlc-frontend-ml-1135170373"></a>
### parse_program_keepgoing

```ml
function parse_program_keepgoing(path, max_errors)
```

Parse one file while collecting up to max_errors syntax diagnostics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — | Path to operate on. |
| `max_errors` | `dynamic` | — | Value supplied for `max_errors`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/frontend.ml#L258)
