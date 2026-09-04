# `mlc/minilang_parser.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc minilang_parser package.

Package: [`mlc.minilang_parser`](Package-mlc-minilang-parser-1725130264.md)

Reachable from entry: **yes**

## Imports

- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)
- `std/string.ml` as `s` → `std/string.ml` — external dependency
- `std/string_builder.ml` as `sb` → `std/string_builder.ml` — external dependency

## Declarations

<a id="function-function-mlc-minilang-parser-advance-function-advance-mlc-minilang-parser-ml-854342850"></a>
### _advance

```ml
function _advance()
```

Parse or represent advance in the MiniLang front end.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1827)

<a id="function-function-mlc-minilang-parser-canonical-type-name-function-canonical-type-name-raw-ty-mlc-minilang-parser-ml-248541986"></a>
### _canonical_type_name

```ml
function _canonical_type_name(raw_ty)
```

Reports whether canonical type name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `raw_ty` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2523)

<a id="function-function-mlc-minilang-parser-charcode-function-charcode-ch-mlc-minilang-parser-ml-121231781"></a>
### _charCode

```ml
function _charCode(ch)
```

Parse or represent char code in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ch` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L957)

<a id="function-function-mlc-minilang-parser-charfromcode-function-charfromcode-v-mlc-minilang-parser-ml-1255810508"></a>
### _charFromCode

```ml
function _charFromCode(v)
```

Parse or represent char from code in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1896)

<a id="function-function-mlc-minilang-parser-chunked-finish-function-chunked-finish-chunks-tail-mlc-minilang-parser-ml-1957454160"></a>
### _chunked_finish

```ml
function _chunked_finish(chunks, tail)
```

Parse or represent chunked finish in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chunks` | `dynamic` | — |  |
| `tail` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1228)

<a id="function-function-mlc-minilang-parser-chunked-merge-balanced-function-chunked-merge-balanced-chunks-mlc-minilang-parser-ml-1612726450"></a>
### _chunked_merge_balanced

```ml
function _chunked_merge_balanced(chunks)
```

Parse or represent chunked merge balanced in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chunks` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1164)

<a id="function-function-mlc-minilang-parser-chunked-merge-with-tail-function-chunked-merge-with-tail-chunks-tail-arr-mlc-minilang-parser-ml-1736823946"></a>
### _chunked_merge_with_tail

```ml
function _chunked_merge_with_tail(chunks, tail_arr)
```

Parse or represent chunked merge with tail in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chunks` | `dynamic` | — |  |
| `tail_arr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1196)

<a id="function-function-mlc-minilang-parser-chunked-push-function-chunked-push-chunks-tail-value-cap-mlc-minilang-parser-ml-859819469"></a>
### _chunked_push

```ml
function _chunked_push(chunks, tail, value, cap)
```

Parse or represent chunked push in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chunks` | `dynamic` | — |  |
| `tail` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |
| `cap` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1138)

<a id="function-function-mlc-minilang-parser-clear-error-function-clear-error-mlc-minilang-parser-ml-595574162"></a>
### _clear_error

```ml
function _clear_error()
```

Releases or resets clear error.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1764)

<a id="global-global-mlc-minilang-parser-collect-errors-collect-errors-mlc-minilang-parser-ml-878934478"></a>
### _collect_errors

```ml
_collect_errors
```

Track collect errors compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1698)

<a id="function-function-mlc-minilang-parser-compile-argument-pos-function-compile-argument-pos-line-argument-line-start-hash-col-mlc-minilang-parser-ml-1844994201"></a>
### _compile_argument_pos

```ml
function _compile_argument_pos(line, argument, line_start, hash_col)
```

Parse or represent compile argument pos in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `line` | `dynamic` | — |  |
| `argument` | `dynamic` | — |  |
| `line_start` | `dynamic` | — |  |
| `hash_col` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4692)

<a id="function-function-mlc-minilang-parser-compile-block-comment-state-function-compile-block-comment-state-line-in-block-mlc-minilang-parser-ml-1936692993"></a>
### _compile_block_comment_state

```ml
function _compile_block_comment_state(line, in_block)
```

Parse or represent compile block comment state in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `line` | `dynamic` | — |  |
| `in_block` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4632)

<a id="function-function-mlc-minilang-parser-compile-env-find-function-compile-env-find-env-name-mlc-minilang-parser-ml-1948646458"></a>
### _compile_env_find

```ml
function _compile_env_find(env, name)
```

Parse or represent compile env find in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `env` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4323)

<a id="function-function-mlc-minilang-parser-compile-env-get-function-compile-env-get-env-name-mlc-minilang-parser-ml-910740190"></a>
### _compile_env_get

```ml
function _compile_env_get(env, name)
```

Parse or represent compile env get in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `env` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4339)

<a id="function-function-mlc-minilang-parser-compile-env-has-function-compile-env-has-env-name-mlc-minilang-parser-ml-1596409926"></a>
### _compile_env_has

```ml
function _compile_env_has(env, name)
```

Parse or represent compile env has in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `env` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4333)

<a id="function-function-mlc-minilang-parser-compile-env-set-function-compile-env-set-env-name-value-mlc-minilang-parser-ml-323738911"></a>
### _compile_env_set

```ml
function _compile_env_set(env, name, value)
```

Parse or represent compile env set in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `env` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4347)

<a id="function-function-mlc-minilang-parser-compile-eval-function-compile-eval-text-env-filename-base-pos-mlc-minilang-parser-ml-704938159"></a>
### _compile_eval

```ml
function _compile_eval(text, env, filename, base_pos)
```

Parse or represent compile eval in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |
| `env` | `dynamic` | — |  |
| `filename` | `dynamic` | — |  |
| `base_pos` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4531)

<a id="function-function-mlc-minilang-parser-compile-eval-node-function-compile-eval-node-expr-env-filename-base-pos-mlc-minilang-parser-ml-307143249"></a>
### _compile_eval_node

```ml
function _compile_eval_node(expr, env, filename, base_pos)
```

Parse or represent compile eval node in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expr` | `dynamic` | — |  |
| `env` | `dynamic` | — |  |
| `filename` | `dynamic` | — |  |
| `base_pos` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4427)

<a id="function-function-mlc-minilang-parser-compile-external-has-function-compile-external-has-name-mlc-minilang-parser-ml-1852269799"></a>
### _compile_external_has

```ml
function _compile_external_has(name)
```

Parse or represent compile external has in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4604)

<a id="global-global-mlc-minilang-parser-compile-external-values-compile-external-values-mlc-minilang-parser-ml-679147876"></a>
### _compile_external_values

```ml
_compile_external_values
```

Track compile external values compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L907)

<a id="function-function-mlc-minilang-parser-compile-frames-active-function-compile-frames-active-frames-mlc-minilang-parser-ml-1694676040"></a>
### _compile_frames_active

```ml
function _compile_frames_active(frames)
```

Parse or represent compile frames active in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frames` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4674)

<a id="function-function-mlc-minilang-parser-compile-frames-pop-function-compile-frames-pop-frames-mlc-minilang-parser-ml-326002130"></a>
### _compile_frames_pop

```ml
function _compile_frames_pop(frames)
```

Parse or represent compile frames pop in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frames` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4681)

<a id="function-function-mlc-minilang-parser-compile-is-error-function-compile-is-error-value-mlc-minilang-parser-ml-1836513363"></a>
### _compile_is_error

```ml
function _compile_is_error(value)
```

Parse or represent compile is error in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4291)

<a id="function-function-mlc-minilang-parser-compile-is-predefined-function-compile-is-predefined-name-mlc-minilang-parser-ml-1217994489"></a>
### _compile_is_predefined

```ml
function _compile_is_predefined(name)
```

Parse or represent compile is predefined in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4317)

<a id="function-function-mlc-minilang-parser-compile-ltrim-index-function-compile-ltrim-index-line-mlc-minilang-parser-ml-1908960260"></a>
### _compile_ltrim_index

```ml
function _compile_ltrim_index(line)
```

Parse or represent compile ltrim index in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `line` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4610)

<a id="function-function-mlc-minilang-parser-compile-maybe-has-directive-function-compile-maybe-has-directive-code-mlc-minilang-parser-ml-1924446191"></a>
### _compile_maybe_has_directive

```ml
function _compile_maybe_has_directive(code)
```

Parse or represent compile maybe has directive in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4722)

<a id="function-function-mlc-minilang-parser-compile-node-pos-function-compile-node-pos-expr-base-pos-mlc-minilang-parser-ml-1928481161"></a>
### _compile_node_pos

```ml
function _compile_node_pos(expr, base_pos)
```

Parse or represent compile node pos in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expr` | `dynamic` | — |  |
| `base_pos` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4401)

<a id="function-function-mlc-minilang-parser-compile-numeric-text-function-compile-numeric-text-raw-mlc-minilang-parser-ml-1435050776"></a>
### _compile_numeric_text

```ml
function _compile_numeric_text(raw)
```

Parse or represent compile numeric text in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `raw` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4542)

<a id="function-function-mlc-minilang-parser-compile-option-parts-function-compile-option-parts-argument-filename-argument-pos-mlc-minilang-parser-ml-311068180"></a>
### _compile_option_parts

```ml
function _compile_option_parts(argument, filename, argument_pos)
```

Parse or represent compile option parts in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `argument` | `dynamic` | — |  |
| `filename` | `dynamic` | — |  |
| `argument_pos` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4701)

<a id="function-function-mlc-minilang-parser-compile-parse-cli-value-function-compile-parse-cli-value-raw-mlc-minilang-parser-ml-1275912900"></a>
### _compile_parse_cli_value

```ml
function _compile_parse_cli_value(raw)
```

Parse or represent compile parse cli value in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `raw` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4554)

<a id="function-function-mlc-minilang-parser-compile-predefined-values-function-compile-predefined-values-mlc-minilang-parser-ml-758642802"></a>
### _compile_predefined_values

```ml
function _compile_predefined_values()
```

Parse or represent compile predefined values in the MiniLang front end.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4360)

<a id="function-function-mlc-minilang-parser-compile-split-command-function-compile-split-command-body-mlc-minilang-parser-ml-203604230"></a>
### _compile_split_command

```ml
function _compile_split_command(body)
```

Parse or represent compile split command in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `body` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4620)

<a id="function-function-mlc-minilang-parser-compile-string-compare-function-compile-string-compare-left-right-mlc-minilang-parser-ml-1113506839"></a>
### _compile_string_compare

```ml
function _compile_string_compare(left, right)
```

Parse or represent compile string compare in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4409)

<a id="global-global-mlc-minilang-parser-compile-target-abi-compile-target-abi-mlc-minilang-parser-ml-1281193878"></a>
### _compile_target_abi

```ml
_compile_target_abi
```

Track compile target abi compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L911)

<a id="global-global-mlc-minilang-parser-compile-target-format-compile-target-format-mlc-minilang-parser-ml-1012778146"></a>
### _compile_target_format

```ml
_compile_target_format
```

Track compile target format compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L913)

<a id="global-global-mlc-minilang-parser-compile-target-os-compile-target-os-mlc-minilang-parser-ml-172422456"></a>
### _compile_target_os

```ml
_compile_target_os
```

Track compile target os compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L909)

<a id="function-function-mlc-minilang-parser-compile-valid-name-function-compile-valid-name-name-mlc-minilang-parser-ml-1605972099"></a>
### _compile_valid_name

```ml
function _compile_valid_name(name)
```

Parse or represent compile valid name in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4297)

<a id="function-function-mlc-minilang-parser-compile-value-type-function-compile-value-type-value-mlc-minilang-parser-ml-995657421"></a>
### _compile_value_type

```ml
function _compile_value_type(value)
```

Parse or represent compile value type in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4309)

<a id="function-function-mlc-minilang-parser-compound-assignment-base-function-compound-assignment-base-op-symbol-mlc-minilang-parser-ml-1157181954"></a>
### _compound_assignment_base

```ml
function _compound_assignment_base(op_symbol)
```

Returns the binary operator represented by a compound assignment token.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `op_symbol` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2101)

<a id="function-function-mlc-minilang-parser-contains-function-contains-arr-value-mlc-minilang-parser-ml-2103954146"></a>
### _contains

```ml
function _contains(arr, value)
```

Reports whether contains.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2919)

<a id="function-function-mlc-minilang-parser-containsdot-function-containsdot-text-mlc-minilang-parser-ml-1728333545"></a>
### _containsDot

```ml
function _containsDot(text)
```

Reports whether contains dot.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2413)

<a id="function-function-mlc-minilang-parser-decode-string-raw-function-decode-string-raw-raw-pos-mlc-minilang-parser-ml-1493201470"></a>
### _decode_string_raw

```ml
function _decode_string_raw(raw, pos)
```

Returns decode string raw.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `raw` | `dynamic` | — |  |
| `pos` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1928)

<a id="function-function-mlc-minilang-parser-decode-string-token-function-decode-string-token-tok-mlc-minilang-parser-ml-445520760"></a>
### _decode_string_token

```ml
function _decode_string_token(tok)
```

Returns decode string token.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tok` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2010)

<a id="global-global-mlc-minilang-parser-errors-errors-mlc-minilang-parser-ml-1686618474"></a>
### _errors

```ml
_errors
```

Track errors compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1702)

<a id="function-function-mlc-minilang-parser-expect-block-nl-function-expect-block-nl-mlc-minilang-parser-ml-1670597970"></a>
### _expect_block_nl

```ml
function _expect_block_nl()
```

Parse or represent expect block nl in the MiniLang front end.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2650)

<a id="function-function-mlc-minilang-parser-expect-end-of-function-expect-end-of-what-mlc-minilang-parser-ml-804933884"></a>
### _expect_end_of

```ml
function _expect_end_of(what)
```

Parse or represent expect end of in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `what` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2666)

<a id="function-function-mlc-minilang-parser-expect-kind-function-expect-kind-kind-mlc-minilang-parser-ml-1844846740"></a>
### _expect_kind

```ml
function _expect_kind(kind)
```

Parse or represent expect kind in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1857)

<a id="function-function-mlc-minilang-parser-expect-value-function-expect-value-kind-value-mlc-minilang-parser-ml-731699205"></a>
### _expect_value

```ml
function _expect_value(kind, value)
```

Parse or represent expect value in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1868)

<a id="global-global-mlc-minilang-parser-filename-filename-mlc-minilang-parser-ml-1544493118"></a>
### _filename

```ml
_filename
```

Track filename compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1684)

<a id="global-global-mlc-minilang-parser-func-depth-func-depth-mlc-minilang-parser-ml-1324726842"></a>
### _func_depth

```ml
_func_depth
```

Track func depth compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1690)

<a id="function-function-mlc-minilang-parser-has-error-function-has-error-mlc-minilang-parser-ml-1971325894"></a>
### _has_error

```ml
function _has_error()
```

Reports whether has error.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1774)

<a id="global-global-mlc-minilang-parser-has-last-error-has-last-error-mlc-minilang-parser-ml-2092681210"></a>
### _has_last_error

```ml
_has_last_error
```

Track has last error compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1688)

<a id="function-function-mlc-minilang-parser-hex-value-function-hex-value-ch-mlc-minilang-parser-ml-1017679913"></a>
### _hex_value

```ml
function _hex_value(ch)
```

Parse or represent hex value in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ch` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1886)

<a id="global-global-mlc-minilang-parser-i-i-mlc-minilang-parser-ml-828257026"></a>
### _i

```ml
_i
```

Track i compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1680)

<a id="function-function-mlc-minilang-parser-is-allowed-type-name-function-is-allowed-type-name-ty-mlc-minilang-parser-ml-162027275"></a>
### _is_allowed_type_name

```ml
function _is_allowed_type_name(ty)
```

Reports whether is allowed type name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ty` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2532)

<a id="function-function-mlc-minilang-parser-is-case-value-continuation-start-function-is-case-value-continuation-start-tok-mlc-minilang-parser-ml-68020650"></a>
### _is_case_value_continuation_start

```ml
function _is_case_value_continuation_start(tok)
```

Reports whether is case value continuation start.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tok` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2978)

<a id="function-function-mlc-minilang-parser-is-end-of-function-is-end-of-what-mlc-minilang-parser-ml-1035425624"></a>
### _is_end_of

```ml
function _is_end_of(what)
```

Reports whether is end of.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `what` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2659)

<a id="function-function-mlc-minilang-parser-isalpha-function-isalpha-ch-mlc-minilang-parser-ml-393200357"></a>
### _isAlpha

```ml
function _isAlpha(ch)
```

Reports whether is alpha.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ch` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L979)

<a id="function-function-mlc-minilang-parser-isdigit-function-isdigit-ch-mlc-minilang-parser-ml-110395897"></a>
### _isDigit

```ml
function _isDigit(ch)
```

Reports whether is digit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ch` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L965)

<a id="function-function-mlc-minilang-parser-ishexdigit-function-ishexdigit-ch-mlc-minilang-parser-ml-9886191"></a>
### _isHexDigit

```ml
function _isHexDigit(ch)
```

Reports whether is hex digit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ch` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L972)

<a id="function-function-mlc-minilang-parser-isidentpart-function-isidentpart-ch-as-string-returns-bool-mlc-minilang-parser-ml-51937513"></a>
### _isIdentPart

```ml
function _isIdentPart(ch as string) returns bool
```

Reports whether is ident part.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ch` | `string` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L992)

<a id="function-function-mlc-minilang-parser-isidentstart-function-isidentstart-ch-as-string-returns-bool-mlc-minilang-parser-ml-121077475"></a>
### _isIdentStart

```ml
function _isIdentStart(ch as string) returns bool
```

Reports whether is ident start.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ch` | `string` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L986)

<a id="function-function-mlc-minilang-parser-iskeyword-function-iskeyword-word-mlc-minilang-parser-ml-228355970"></a>
### _isKeyword

```ml
function _isKeyword(word)
```

Reports whether is keyword.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `word` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L998)

<a id="global-global-mlc-minilang-parser-keywords-keywords-mlc-minilang-parser-ml-717974546"></a>
### _keywords

```ml
_keywords
```

Track keywords compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L916)

<a id="function-function-mlc-minilang-parser-lang-add-unique-function-lang-add-unique-items-value-mlc-minilang-parser-ml-1937050863"></a>
### _lang_add_unique

```ml
function _lang_add_unique(items, value)
```

Parse or represent lang add unique in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5237)

<a id="function-function-mlc-minilang-parser-lang-apply-contracts-function-lang-apply-contracts-fn-mlc-minilang-parser-ml-1085961450"></a>
### _lang_apply_contracts

```ml
function _lang_apply_contracts(fn)
```

Parse or represent lang apply contracts in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5021)

<a id="function-function-mlc-minilang-parser-lang-apply-parameter-contracts-function-lang-apply-parameter-contracts-fn-mlc-minilang-parser-ml-975369642"></a>
### _lang_apply_parameter_contracts

```ml
function _lang_apply_parameter_contracts(fn)
```

Parse or represent lang apply parameter contracts in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4997)

<a id="function-function-mlc-minilang-parser-lang-await-helper-function-lang-await-helper-mlc-minilang-parser-ml-1301921598"></a>
### _lang_await_helper

```ml
function _lang_await_helper()
```

Parse or represent lang await helper in the MiniLang front end.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5641)

<a id="function-function-mlc-minilang-parser-lang-call-function-lang-call-name-args-node-mlc-minilang-parser-ml-1883001620"></a>
### _lang_call

```ml
function _lang_call(name, args, node)
```

Parse or represent lang call in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |
| `args` | `dynamic` | — |  |
| `node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4939)

<a id="function-function-mlc-minilang-parser-lang-collect-contracts-function-lang-collect-contracts-body-prefix-mlc-minilang-parser-ml-1632823090"></a>
### _lang_collect_contracts

```ml
function _lang_collect_contracts(body, prefix)
```

Parse or represent lang collect contracts in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `body` | `dynamic` | — |  |
| `prefix` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5850)

<a id="function-function-mlc-minilang-parser-lang-fail-function-lang-fail-message-mlc-minilang-parser-ml-1582786325"></a>
### _lang_fail

```ml
function _lang_fail(message)
```

Parse or represent lang fail in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4902)

<a id="function-function-mlc-minilang-parser-lang-find-interface-function-lang-find-interface-raw-name-prefix-mlc-minilang-parser-ml-339764222"></a>
### _lang_find_interface

```ml
function _lang_find_interface(raw_name, prefix)
```

Parse or represent lang find interface in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `raw_name` | `dynamic` | — |  |
| `prefix` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5870)

<a id="function-function-mlc-minilang-parser-lang-fresh-function-lang-fresh-stem-mlc-minilang-parser-ml-625788787"></a>
### _lang_fresh

```ml
function _lang_fresh(stem)
```

Parse or represent lang fresh in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stem` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4911)

<a id="function-function-mlc-minilang-parser-lang-guard-returns-function-lang-guard-returns-body-return-type-return-optional-mlc-minilang-parser-ml-24790194"></a>
### _lang_guard_returns

```ml
function _lang_guard_returns(body, return_type, return_optional)
```

Parse or represent lang guard returns in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `body` | `dynamic` | — |  |
| `return_type` | `dynamic` | — |  |
| `return_optional` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4948)

<a id="function-function-mlc-minilang-parser-lang-interface-signature-matches-function-lang-interface-signature-matches-required-actual-mlc-minilang-parser-ml-1141437533"></a>
### _lang_interface_signature_matches

```ml
function _lang_interface_signature_matches(required, actual)
```

Parse or represent lang interface signature matches in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `required` | `dynamic` | — |  |
| `actual` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5891)

<a id="function-function-mlc-minilang-parser-lang-iterator-append-function-lang-iterator-append-yield-stmt-fn-names-mlc-minilang-parser-ml-1781774224"></a>
### _lang_iterator_append

```ml
function _lang_iterator_append(yield_stmt, fn, names)
```

Parse or represent lang iterator append in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `yield_stmt` | `dynamic` | — |  |
| `fn` | `dynamic` | — |  |
| `names` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5124)

<a id="function-function-mlc-minilang-parser-lang-lazy-collect-names-function-lang-lazy-collect-names-state-body-mlc-minilang-parser-ml-1375518483"></a>
### _lang_lazy_collect_names

```ml
function _lang_lazy_collect_names(state, body)
```

Parse or represent lang lazy collect names in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `body` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5342)

<a id="function-function-mlc-minilang-parser-lang-lazy-compile-seq-function-lang-lazy-compile-seq-state-body-cont-break-target-continue-target-mlc-minilang-parser-ml-1854624785"></a>
### _lang_lazy_compile_seq

```ml
function _lang_lazy_compile_seq(state, body, cont, break_target, continue_target)
```

Parse or represent lang lazy compile seq in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `body` | `dynamic` | — |  |
| `cont` | `dynamic` | — |  |
| `break_target` | `dynamic` | — |  |
| `continue_target` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5388)

<a id="function-function-mlc-minilang-parser-lang-lazy-contains-yield-function-lang-lazy-contains-yield-st-mlc-minilang-parser-ml-940831165"></a>
### _lang_lazy_contains_yield

```ml
function _lang_lazy_contains_yield(st)
```

Parse or represent lang lazy contains yield in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5286)

<a id="function-function-mlc-minilang-parser-lang-lazy-jump-function-lang-lazy-jump-state-target-node-mlc-minilang-parser-ml-46189424"></a>
### _lang_lazy_jump

```ml
function _lang_lazy_jump(state, target, node)
```

Parse or represent lang lazy jump in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `target` | `dynamic` | — |  |
| `node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5277)

<a id="function-function-mlc-minilang-parser-lang-lazy-reserve-function-lang-lazy-reserve-state-mlc-minilang-parser-ml-79448599"></a>
### _lang_lazy_reserve

```ml
function _lang_lazy_reserve(state)
```

Parse or represent lang lazy reserve in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5270)

<a id="function-function-mlc-minilang-parser-lang-lower-async-function-lang-lower-async-fn-mlc-minilang-parser-ml-1610227462"></a>
### _lang_lower_async

```ml
function _lang_lower_async(fn)
```

Parse or represent lang lower async in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5604)

<a id="function-function-mlc-minilang-parser-lang-lower-block-function-lang-lower-block-body-function-depth-mlc-minilang-parser-ml-809020114"></a>
### _lang_lower_block

```ml
function _lang_lower_block(body, function_depth)
```

Parse or represent lang lower block in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `body` | `dynamic` | — |  |
| `function_depth` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5826)

<a id="function-function-mlc-minilang-parser-lang-lower-expr-function-lang-lower-expr-expr-prelude-mlc-minilang-parser-ml-824621110"></a>
### _lang_lower_expr

```ml
function _lang_lower_expr(expr, prelude)
```

Parse or represent lang lower expr in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expr` | `dynamic` | — |  |
| `prelude` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5029)

<a id="function-function-mlc-minilang-parser-lang-lower-iterator-function-lang-lower-iterator-fn-mlc-minilang-parser-ml-1990187370"></a>
### _lang_lower_iterator

```ml
function _lang_lower_iterator(fn)
```

Parse or represent lang lower iterator in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5198)

<a id="function-function-mlc-minilang-parser-lang-lower-lazy-iterator-function-lang-lower-lazy-iterator-fn-mlc-minilang-parser-ml-1036584840"></a>
### _lang_lower_lazy_iterator

```ml
function _lang_lower_lazy_iterator(fn)
```

Parse or represent lang lower lazy iterator in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5563)

<a id="function-function-mlc-minilang-parser-lang-lower-stmt-function-lang-lower-stmt-st-function-depth-mlc-minilang-parser-ml-1800530555"></a>
### _lang_lower_stmt

```ml
function _lang_lower_stmt(st, function_depth)
```

Parse or represent lang lower stmt in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |
| `function_depth` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5690)

<a id="function-function-mlc-minilang-parser-lang-num-function-lang-num-value-node-mlc-minilang-parser-ml-448227959"></a>
### _lang_num

```ml
function _lang_num(value, node)
```

Parse or represent lang num in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |
| `node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4927)

<a id="function-function-mlc-minilang-parser-lang-remove-interfaces-function-lang-remove-interfaces-body-mlc-minilang-parser-ml-1622339556"></a>
### _lang_remove_interfaces

```ml
function _lang_remove_interfaces(body)
```

Parse or represent lang remove interfaces in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `body` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5954)

<a id="function-function-mlc-minilang-parser-lang-rewrite-yields-function-lang-rewrite-yields-body-fn-names-mlc-minilang-parser-ml-1323349854"></a>
### _lang_rewrite_yields

```ml
function _lang_rewrite_yields(body, fn, names)
```

Parse or represent lang rewrite yields in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `body` | `dynamic` | — |  |
| `fn` | `dynamic` | — |  |
| `names` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5153)

<a id="function-function-mlc-minilang-parser-lang-select-helper-function-lang-select-helper-mlc-minilang-parser-ml-1613669244"></a>
### _lang_select_helper

```ml
function _lang_select_helper()
```

Parse or represent lang select helper in the MiniLang front end.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5659)

<a id="function-function-mlc-minilang-parser-lang-sort-strings-function-lang-sort-strings-items-mlc-minilang-parser-ml-356175926"></a>
### _lang_sort_strings

```ml
function _lang_sort_strings(items)
```

Parse or represent lang sort strings in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5244)

<a id="function-function-mlc-minilang-parser-lang-validate-interfaces-function-lang-validate-interfaces-program-mlc-minilang-parser-ml-171382428"></a>
### _lang_validate_interfaces

```ml
function _lang_validate_interfaces(program)
```

Parse or represent lang validate interfaces in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5915)

<a id="function-function-mlc-minilang-parser-lang-var-function-lang-var-name-node-mlc-minilang-parser-ml-172090983"></a>
### _lang_var

```ml
function _lang_var(name, node)
```

Parse or represent lang var in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |
| `node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4921)

<a id="function-function-mlc-minilang-parser-lang-void-function-lang-void-node-mlc-minilang-parser-ml-1408191438"></a>
### _lang_void

```ml
function _lang_void(node)
```

Parse or represent lang void in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4933)

<a id="global-global-mlc-minilang-parser-language-async-pool-name-language-async-pool-name-mlc-minilang-parser-ml-535461006"></a>
### _language_async_pool_name

```ml
_language_async_pool_name
```

Track language async pool name compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4888)

<a id="global-global-mlc-minilang-parser-language-await-file-language-await-file-mlc-minilang-parser-ml-1159632028"></a>
### _language_await_file

```ml
_language_await_file
```

Track language await file compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4892)

<a id="global-global-mlc-minilang-parser-language-await-pos-language-await-pos-mlc-minilang-parser-ml-1335344342"></a>
### _language_await_pos

```ml
_language_await_pos
```

Track language await pos compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4890)

<a id="global-global-mlc-minilang-parser-language-failure-language-failure-mlc-minilang-parser-ml-1700825578"></a>
### _language_failure

```ml
_language_failure
```

Track language failure compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4898)

<a id="global-global-mlc-minilang-parser-language-interfaces-language-interfaces-mlc-minilang-parser-ml-2141610586"></a>
### _language_interfaces

```ml
_language_interfaces
```

Track language interfaces compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5844)

<a id="global-global-mlc-minilang-parser-language-needs-async-pool-language-needs-async-pool-mlc-minilang-parser-ml-1338149912"></a>
### _language_needs_async_pool

```ml
_language_needs_async_pool
```

Track language needs async pool compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4886)

<a id="global-global-mlc-minilang-parser-language-needs-await-language-needs-await-mlc-minilang-parser-ml-1576626934"></a>
### _language_needs_await

```ml
_language_needs_await
```

Track language needs await compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4882)

<a id="global-global-mlc-minilang-parser-language-needs-select-language-needs-select-mlc-minilang-parser-ml-432760030"></a>
### _language_needs_select

```ml
_language_needs_select
```

Track language needs select compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4884)

<a id="global-global-mlc-minilang-parser-language-select-file-language-select-file-mlc-minilang-parser-ml-1251553414"></a>
### _language_select_file

```ml
_language_select_file
```

Track language select file compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4896)

<a id="global-global-mlc-minilang-parser-language-select-pos-language-select-pos-mlc-minilang-parser-ml-1275235008"></a>
### _language_select_pos

```ml
_language_select_pos
```

Track language select pos compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4894)

<a id="global-global-mlc-minilang-parser-language-serial-language-serial-mlc-minilang-parser-ml-1058830922"></a>
### _language_serial

```ml
_language_serial
```

Track language serial compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4880)

<a id="global-global-mlc-minilang-parser-language-structs-language-structs-mlc-minilang-parser-ml-201932106"></a>
### _language_structs

```ml
_language_structs
```

Track language structs compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5846)

<a id="global-global-mlc-minilang-parser-last-error-last-error-mlc-minilang-parser-ml-1321459950"></a>
### _last_error

```ml
_last_error
```

Track last error compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1686)

<a id="function-function-mlc-minilang-parser-line-col-function-line-col-source-pos-mlc-minilang-parser-ml-36477455"></a>
### _line_col

```ml
function _line_col(source, pos)
```

Parse or represent line col in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |
| `pos` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1633)

<a id="function-function-mlc-minilang-parser-match-kind-function-match-kind-kind-mlc-minilang-parser-ml-1282613646"></a>
### _match_kind

```ml
function _match_kind(kind)
```

Parse or represent match kind in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1838)

<a id="function-function-mlc-minilang-parser-match-number-has-dot-function-match-number-has-dot-text-mlc-minilang-parser-ml-193975663"></a>
### _match_number_has_dot

```ml
function _match_number_has_dot(text)
```

Parse or represent match number has dot in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2403)

<a id="function-function-mlc-minilang-parser-match-value-function-match-value-kind-value-mlc-minilang-parser-ml-1343077697"></a>
### _match_value

```ml
function _match_value(kind, value)
```

Parse or represent match value in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1847)

<a id="global-global-mlc-minilang-parser-max-errors-max-errors-mlc-minilang-parser-ml-1741374078"></a>
### _max_errors

```ml
_max_errors
```

Track max errors compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1700)

<a id="function-function-mlc-minilang-parser-new-function-node-function-new-function-node-name-params-body-is-static-is-inline-is-synchronized-param-types-param-optional-param-defaults-variadic-index-return-type-return-optional-is-async-is-iterator-pos-filename-mlc-minilang-parser-ml-1740795503"></a>
### _new_function_node

```ml
function _new_function_node(name, params, body, is_static, is_inline, is_synchronized, param_types, param_optional, param_defaults, variadic_index, return_type, return_optional, is_async, is_iterator, pos, filename)
```

Keep compiler-internal closure fields centralized when surface syntax creates ordinary, lambda, iterator or async functions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |
| `params` | `dynamic` | — |  |
| `body` | `dynamic` | — |  |
| `is_static` | `dynamic` | — |  |
| `is_inline` | `dynamic` | — |  |
| `is_synchronized` | `dynamic` | — |  |
| `param_types` | `dynamic` | — |  |
| `param_optional` | `dynamic` | — |  |
| `param_defaults` | `dynamic` | — |  |
| `variadic_index` | `dynamic` | — |  |
| `return_type` | `dynamic` | — |  |
| `return_optional` | `dynamic` | — |  |
| `is_async` | `dynamic` | — |  |
| `is_iterator` | `dynamic` | — |  |
| `pos` | `dynamic` | — |  |
| `filename` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L942)

<a id="global-global-mlc-minilang-parser-ns-depth-ns-depth-mlc-minilang-parser-ml-736680906"></a>
### _ns_depth

```ml
_ns_depth
```

Track ns depth compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1692)

<a id="function-function-mlc-minilang-parser-parse-base-int-function-parse-base-int-raw-start-index-base-mlc-minilang-parser-ml-17195282"></a>
### _parse_base_int

```ml
function _parse_base_int(raw, start_index, base)
```

Returns parse base int.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `raw` | `dynamic` | — |  |
| `start_index` | `dynamic` | — |  |
| `base` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2022)

<a id="function-function-mlc-minilang-parser-parse-block-until-function-parse-block-until-stop-keywords-end-type-start-pos-mlc-minilang-parser-ml-2139376230"></a>
### _parse_block_until

```ml
function _parse_block_until(stop_keywords, end_type, start_pos)
```

Returns parse block until.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stop_keywords` | `dynamic` | — |  |
| `end_type` | `dynamic` | — |  |
| `start_pos` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2993)

<a id="function-function-mlc-minilang-parser-parse-block-until-end-function-parse-block-until-end-end-type-start-pos-mlc-minilang-parser-ml-1915823777"></a>
### _parse_block_until_end

```ml
function _parse_block_until_end(end_type, start_pos)
```

Returns parse block until end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `end_type` | `dynamic` | — |  |
| `start_pos` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2884)

<a id="function-function-mlc-minilang-parser-parse-call-arguments-function-parse-call-arguments-mlc-minilang-parser-ml-684252158"></a>
### _parse_call_arguments

```ml
function _parse_call_arguments()
```

Returns parse call arguments.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2362)

<a id="function-function-mlc-minilang-parser-parse-dotted-name-function-parse-dotted-name-mlc-minilang-parser-ml-475088762"></a>
### _parse_dotted_name

```ml
function _parse_dotted_name()
```

Returns parse dotted name.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2680)

<a id="function-function-mlc-minilang-parser-parse-expr-function-parse-expr-min-prec-mlc-minilang-parser-ml-1451801121"></a>
### _parse_expr

```ml
function _parse_expr(min_prec)
```

Returns parse expr.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `min_prec` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2538)

<a id="function-function-mlc-minilang-parser-parse-expr-list-function-parse-expr-list-end-kind-mlc-minilang-parser-ml-471735646"></a>
### _parse_expr_list

```ml
function _parse_expr_list(end_kind)
```

Returns parse expr list.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `end_kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2117)

<a id="function-function-mlc-minilang-parser-parse-extern-param-function-parse-extern-param-mlc-minilang-parser-ml-1936636852"></a>
### _parse_extern_param

```ml
function _parse_extern_param()
```

Returns parse extern param.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2710)

<a id="function-function-mlc-minilang-parser-parse-extern-param-list-function-parse-extern-param-list-end-kind-mlc-minilang-parser-ml-889062222"></a>
### _parse_extern_param_list

```ml
function _parse_extern_param_list(end_kind)
```

Returns parse extern param list.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `end_kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2737)

<a id="function-function-mlc-minilang-parser-parse-float-literal-function-parse-float-literal-raw-mlc-minilang-parser-ml-1448544044"></a>
### _parse_float_literal

```ml
function _parse_float_literal(raw)
```

Returns parse float literal.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `raw` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2046)

<a id="function-function-mlc-minilang-parser-parse-ident-list-function-parse-ident-list-end-kind-mlc-minilang-parser-ml-791848414"></a>
### _parse_ident_list

```ml
function _parse_ident_list(end_kind)
```

Returns parse ident list.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `end_kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2614)

<a id="function-function-mlc-minilang-parser-parse-int-literal-function-parse-int-literal-raw-mlc-minilang-parser-ml-1603272168"></a>
### _parse_int_literal

```ml
function _parse_int_literal(raw)
```

Returns parse int literal.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `raw` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2034)

<a id="function-function-mlc-minilang-parser-parse-namespace-def-function-parse-namespace-def-start-pos-mlc-minilang-parser-ml-467393215"></a>
### _parse_namespace_def

```ml
function _parse_namespace_def(start_pos)
```

Returns parse namespace def.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2763)

<a id="function-function-mlc-minilang-parser-parse-parameter-list-function-parse-parameter-list-mlc-minilang-parser-ml-351279608"></a>
### _parse_parameter_list

```ml
function _parse_parameter_list()
```

Returns parse parameter list.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2281)

<a id="function-function-mlc-minilang-parser-parse-postfix-function-parse-postfix-mlc-minilang-parser-ml-956530126"></a>
### _parse_postfix

```ml
function _parse_postfix()
```

Returns parse postfix.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2423)

<a id="function-function-mlc-minilang-parser-parse-primary-function-parse-primary-mlc-minilang-parser-ml-186727750"></a>
### _parse_primary

```ml
function _parse_primary()
```

Returns parse primary.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2143)

<a id="function-function-mlc-minilang-parser-parse-stmt-function-parse-stmt-mlc-minilang-parser-ml-1644404112"></a>
### _parse_stmt

```ml
function _parse_stmt()
```

Returns parse stmt.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L3034)

<a id="function-function-mlc-minilang-parser-parse-stmt-break-function-parse-stmt-break-start-pos-t-mlc-minilang-parser-ml-1876806755"></a>
### _parse_stmt_break

```ml
function _parse_stmt_break(start_pos, t)
```

Returns parse stmt break.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `t` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L3263)

<a id="function-function-mlc-minilang-parser-parse-stmt-const-function-parse-stmt-const-start-pos-t-mlc-minilang-parser-ml-1610490731"></a>
### _parse_stmt_const

```ml
function _parse_stmt_const(start_pos, t)
```

Returns parse stmt const.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `t` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L3207)

<a id="function-function-mlc-minilang-parser-parse-stmt-continue-function-parse-stmt-continue-start-pos-t-mlc-minilang-parser-ml-1042039421"></a>
### _parse_stmt_continue

```ml
function _parse_stmt_continue(start_pos, t)
```

Returns parse stmt continue.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `t` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L3280)

<a id="function-function-mlc-minilang-parser-parse-stmt-defer-function-parse-stmt-defer-start-pos-t-mlc-minilang-parser-ml-999751397"></a>
### _parse_stmt_defer

```ml
function _parse_stmt_defer(start_pos, t)
```

Returns parse stmt defer.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `t` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L3360)

<a id="function-function-mlc-minilang-parser-parse-stmt-enum-function-parse-stmt-enum-start-pos-t-mlc-minilang-parser-ml-817767041"></a>
### _parse_stmt_enum

```ml
function _parse_stmt_enum(start_pos, t)
```

Returns parse stmt enum.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `t` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L3790)

<a id="function-function-mlc-minilang-parser-parse-stmt-extern-function-parse-stmt-extern-start-pos-t-mlc-minilang-parser-ml-403281573"></a>
### _parse_stmt_extern

```ml
function _parse_stmt_extern(start_pos, t)
```

Returns parse stmt extern.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `t` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L3380)

<a id="function-function-mlc-minilang-parser-parse-stmt-for-function-parse-stmt-for-start-pos-t-mlc-minilang-parser-ml-1144812571"></a>
### _parse_stmt_for

```ml
function _parse_stmt_for(start_pos, t)
```

Returns parse stmt for.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `t` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4130)

<a id="function-function-mlc-minilang-parser-parse-stmt-function-function-parse-stmt-function-start-pos-t-mlc-minilang-parser-ml-95524909"></a>
### _parse_stmt_function

```ml
function _parse_stmt_function(start_pos, t)
```

Returns parse stmt function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `t` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L3865)

<a id="function-function-mlc-minilang-parser-parse-stmt-global-function-parse-stmt-global-start-pos-t-mlc-minilang-parser-ml-2138045605"></a>
### _parse_stmt_global

```ml
function _parse_stmt_global(start_pos, t)
```

Returns parse stmt global.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `t` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L3290)

<a id="function-function-mlc-minilang-parser-parse-stmt-ident-function-parse-stmt-ident-start-pos-first-tok-mlc-minilang-parser-ml-1453814254"></a>
### _parse_stmt_ident

```ml
function _parse_stmt_ident(start_pos, first_tok)
```

Returns parse stmt ident.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `first_tok` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4170)

<a id="function-function-mlc-minilang-parser-parse-stmt-if-function-parse-stmt-if-start-pos-t-mlc-minilang-parser-ml-1322990389"></a>
### _parse_stmt_if

```ml
function _parse_stmt_if(start_pos, t)
```

Returns parse stmt if.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `t` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4071)

<a id="function-function-mlc-minilang-parser-parse-stmt-import-function-parse-stmt-import-start-pos-t-mlc-minilang-parser-ml-662978865"></a>
### _parse_stmt_import

```ml
function _parse_stmt_import(start_pos, t)
```

Returns parse stmt import.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `t` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L3175)

<a id="function-function-mlc-minilang-parser-parse-stmt-interface-function-parse-stmt-interface-start-pos-tok-mlc-minilang-parser-ml-1030662077"></a>
### _parse_stmt_interface

```ml
function _parse_stmt_interface(start_pos, tok)
```

Returns parse stmt interface.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `tok` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L3474)

<a id="function-function-mlc-minilang-parser-parse-stmt-loop-function-parse-stmt-loop-start-pos-t-mlc-minilang-parser-ml-117125565"></a>
### _parse_stmt_loop

```ml
function _parse_stmt_loop(start_pos, t)
```

Returns parse stmt loop.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `t` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L3923)

<a id="function-function-mlc-minilang-parser-parse-stmt-namespace-function-parse-stmt-namespace-start-pos-t-mlc-minilang-parser-ml-1071847403"></a>
### _parse_stmt_namespace

```ml
function _parse_stmt_namespace(start_pos, t)
```

Returns parse stmt namespace.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `t` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L3166)

<a id="function-function-mlc-minilang-parser-parse-stmt-package-function-parse-stmt-package-start-pos-t-mlc-minilang-parser-ml-421259793"></a>
### _parse_stmt_package

```ml
function _parse_stmt_package(start_pos, t)
```

Returns parse stmt package.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `t` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L3141)

<a id="function-function-mlc-minilang-parser-parse-stmt-print-function-parse-stmt-print-start-pos-t-mlc-minilang-parser-ml-256477979"></a>
### _parse_stmt_print

```ml
function _parse_stmt_print(start_pos, t)
```

Returns parse stmt print.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `t` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L3251)

<a id="function-function-mlc-minilang-parser-parse-stmt-recover-function-parse-stmt-recover-stop-keywords-end-type-mlc-minilang-parser-ml-1546652525"></a>
### _parse_stmt_recover

```ml
function _parse_stmt_recover(stop_keywords, end_type)
```

Returns parse stmt recover.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stop_keywords` | `dynamic` | — |  |
| `end_type` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4235)

<a id="function-function-mlc-minilang-parser-parse-stmt-return-function-parse-stmt-return-start-pos-t-mlc-minilang-parser-ml-86255477"></a>
### _parse_stmt_return

```ml
function _parse_stmt_return(start_pos, t)
```

Returns parse stmt return.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `t` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L3321)

<a id="function-function-mlc-minilang-parser-parse-stmt-struct-function-parse-stmt-struct-start-pos-t-mlc-minilang-parser-ml-1886394821"></a>
### _parse_stmt_struct

```ml
function _parse_stmt_struct(start_pos, t)
```

Returns parse stmt struct.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `t` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L3524)

<a id="function-function-mlc-minilang-parser-parse-stmt-switch-function-parse-stmt-switch-start-pos-t-mlc-minilang-parser-ml-1183801933"></a>
### _parse_stmt_switch

```ml
function _parse_stmt_switch(start_pos, t)
```

Returns parse stmt switch.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `t` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L3976)

<a id="function-function-mlc-minilang-parser-parse-stmt-synchronized-function-parse-stmt-synchronized-start-pos-t-mlc-minilang-parser-ml-2088041877"></a>
### _parse_stmt_synchronized

```ml
function _parse_stmt_synchronized(start_pos, t)
```

Returns parse stmt synchronized.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `t` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L3223)

<a id="function-function-mlc-minilang-parser-parse-stmt-while-function-parse-stmt-while-start-pos-t-mlc-minilang-parser-ml-272909159"></a>
### _parse_stmt_while

```ml
function _parse_stmt_while(start_pos, t)
```

Returns parse stmt while.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `t` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4113)

<a id="function-function-mlc-minilang-parser-parse-stmt-yield-function-parse-stmt-yield-start-pos-tok-mlc-minilang-parser-ml-1674674669"></a>
### _parse_stmt_yield

```ml
function _parse_stmt_yield(start_pos, tok)
```

Returns parse stmt yield.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `start_pos` | `dynamic` | — |  |
| `tok` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L3340)

<a id="extern_function-extern-function-mlc-minilang-parser-parse-strtod-extern-function-parse-strtod-text-as-cstr-endptr-as-ptr-from-msvcrt-dll-symbol-strtod-returns-double-mlc-minilang-parser-ml-2007867238"></a>
### _parse_strtod

```ml
extern function _parse_strtod(text as cstr, endptr as ptr) from "msvcrt.dll" symbol "strtod" returns double
```

Returns parse strtod.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `cstr` | — |  |
| `endptr` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L28)

<a id="function-function-mlc-minilang-parser-parse-type-ref-function-parse-type-ref-mlc-minilang-parser-ml-430222728"></a>
### _parse_type_ref

```ml
function _parse_type_ref()
```

Returns parse type ref.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2263)

<a id="function-function-mlc-minilang-parser-parse-unary-function-parse-unary-mlc-minilang-parser-ml-704063402"></a>
### _parse_unary

```ml
function _parse_unary()
```

Returns parse unary.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2475)

<a id="function-function-mlc-minilang-parser-parser-chunk-tail-from-array-function-parser-chunk-tail-from-array-arr-cap-mlc-minilang-parser-ml-1785272287"></a>
### _parser_chunk_tail_from_array

```ml
function _parser_chunk_tail_from_array(arr, cap)
```

Returns parser chunk tail from array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `cap` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1075)

<a id="function-function-mlc-minilang-parser-parser-chunk-tail-len-function-parser-chunk-tail-len-tail-mlc-minilang-parser-ml-1487200976"></a>
### _parser_chunk_tail_len

```ml
function _parser_chunk_tail_len(tail)
```

Returns parser chunk tail len.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tail` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1089)

<a id="function-function-mlc-minilang-parser-parser-chunk-tail-new-function-parser-chunk-tail-new-cap-mlc-minilang-parser-ml-299071438"></a>
### _parser_chunk_tail_new

```ml
function _parser_chunk_tail_new(cap)
```

Returns parser chunk tail new.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cap` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1067)

<a id="function-function-mlc-minilang-parser-parser-chunk-tail-to-array-function-parser-chunk-tail-to-array-tail-mlc-minilang-parser-ml-974082346"></a>
### _parser_chunk_tail_to_array

```ml
function _parser_chunk_tail_to_array(tail)
```

Returns parser chunk tail to array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tail` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1102)

<a id="function-function-mlc-minilang-parser-parser-chunk-unwrap-value-function-parser-chunk-unwrap-value-value-mlc-minilang-parser-ml-257964935"></a>
### _parser_chunk_unwrap_value

```ml
function _parser_chunk_unwrap_value(value)
```

Returns parser chunk unwrap value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1055)

<a id="global-global-mlc-minilang-parser-parser-chunk-void-sentinel-parser-chunk-void-sentinel-mlc-minilang-parser-ml-745592910"></a>
### _parser_chunk_void_sentinel

```ml
_parser_chunk_void_sentinel
```

Track parser chunk void sentinel compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1042)

<a id="function-function-mlc-minilang-parser-parser-chunk-wrap-value-function-parser-chunk-wrap-value-value-mlc-minilang-parser-ml-1167373083"></a>
### _parser_chunk_wrap_value

```ml
function _parser_chunk_wrap_value(value)
```

Returns parser chunk wrap value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1046)

<a id="function-function-mlc-minilang-parser-peek-function-peek-mlc-minilang-parser-ml-336315198"></a>
### _peek

```ml
function _peek()
```

Parse or represent peek in the MiniLang front end.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1803)

<a id="function-function-mlc-minilang-parser-peek2-function-peek2-mlc-minilang-parser-ml-947026934"></a>
### _peek2

```ml
function _peek2()
```

Parse or represent peek2 in the MiniLang front end.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1815)

<a id="function-function-mlc-minilang-parser-peek3-function-peek3-mlc-minilang-parser-ml-1307291770"></a>
### _peek3

```ml
function _peek3()
```

Parse or represent peek3 in the MiniLang front end.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1998)

<a id="function-function-mlc-minilang-parser-peek-non-nl-function-peek-non-nl-mlc-minilang-parser-ml-267832150"></a>
### _peek_non_nl

```ml
function _peek_non_nl()
```

Parse or represent peek non nl in the MiniLang front end.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2694)

<a id="function-function-mlc-minilang-parser-precedence-function-precedence-op-mlc-minilang-parser-ml-311473671"></a>
### _precedence

```ml
function _precedence(op)
```

Parse or represent precedence in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `op` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2054)

<a id="function-function-mlc-minilang-parser-record-error-function-record-error-err-mlc-minilang-parser-ml-104933803"></a>
### _record_error

```ml
function _record_error(err)
```

Parse or represent record error in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `err` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2929)

<a id="function-function-mlc-minilang-parser-repeat-function-repeat-text-n-mlc-minilang-parser-ml-457637029"></a>
### _repeat

```ml
function _repeat(text, n)
```

Parse or represent repeat in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |
| `n` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1619)

<a id="function-function-mlc-minilang-parser-replacedotswithslash-function-replacedotswithslash-name-mlc-minilang-parser-ml-1287845457"></a>
### _replaceDotsWithSlash

```ml
function _replaceDotsWithSlash(name)
```

Parse or represent replace dots with slash in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4256)

<a id="function-function-mlc-minilang-parser-reset-function-reset-tokens-source-filename-collect-errors-max-errors-mlc-minilang-parser-ml-1225112460"></a>
### _reset

```ml
function _reset(tokens, source, filename, collect_errors, max_errors)
```

Releases or resets reset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tokens` | `dynamic` | — |  |
| `source` | `dynamic` | — |  |
| `filename` | `dynamic` | — |  |
| `collect_errors` | `dynamic` | — |  |
| `max_errors` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1783)

<a id="global-global-mlc-minilang-parser-seen-nonpackage-toplevel-stmt-seen-nonpackage-toplevel-stmt-mlc-minilang-parser-ml-2079644968"></a>
### _seen_nonpackage_toplevel_stmt

```ml
_seen_nonpackage_toplevel_stmt
```

Track seen nonpackage toplevel stmt compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1696)

<a id="global-global-mlc-minilang-parser-seen-package-seen-package-mlc-minilang-parser-ml-153827270"></a>
### _seen_package

```ml
_seen_package
```

Track seen package compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1694)

<a id="function-function-mlc-minilang-parser-set-error-function-set-error-message-pos-mlc-minilang-parser-ml-1563176001"></a>
### _set_error

```ml
function _set_error(message, pos)
```

Updates set error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `message` | `dynamic` | — |  |
| `pos` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1753)

<a id="function-function-mlc-minilang-parser-skip-newlines-function-skip-newlines-mlc-minilang-parser-ml-1349351774"></a>
### _skip_newlines

```ml
function _skip_newlines()
```

Parse or represent skip newlines in the MiniLang front end.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1879)

<a id="function-function-mlc-minilang-parser-skip-stmt-seps-function-skip-stmt-seps-mlc-minilang-parser-ml-447601712"></a>
### _skip_stmt_seps

```ml
function _skip_stmt_seps()
```

Parse or represent skip stmt seps in the MiniLang front end.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2640)

<a id="global-global-mlc-minilang-parser-source-source-mlc-minilang-parser-ml-434310726"></a>
### _source

```ml
_source
```

Track source compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1682)

<a id="function-function-mlc-minilang-parser-substr-function-substr-text-start-length-mlc-minilang-parser-ml-1655674179"></a>
### _substr

```ml
function _substr(text, start, length)
```

Parse or represent substr in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |
| `start` | `dynamic` | — |  |
| `length` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L948)

<a id="function-function-mlc-minilang-parser-sync-stmt-function-sync-stmt-stop-keywords-end-type-mlc-minilang-parser-ml-1693418281"></a>
### _sync_stmt

```ml
function _sync_stmt(stop_keywords, end_type)
```

Parse or represent sync stmt in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stop_keywords` | `dynamic` | — |  |
| `end_type` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2940)

<a id="function-function-mlc-minilang-parser-tok-desc-function-tok-desc-tok-mlc-minilang-parser-ml-353689570"></a>
### _tok_desc

```ml
function _tok_desc(tok)
```

Converts tok desc.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tok` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L87)

<a id="function-function-mlc-minilang-parser-tok-kind-function-tok-kind-tok-mlc-minilang-parser-ml-830102320"></a>
### _tok_kind

```ml
function _tok_kind(tok)
```

Converts tok kind.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tok` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1722)

<a id="function-function-mlc-minilang-parser-tok-kind-id-inline-function-tok-kind-id-tok-mlc-minilang-parser-ml-940568509"></a>
### _tok_kind_id

```ml
inline function _tok_kind_id(tok)
```

Parse or represent inline in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tok` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1712)

<a id="function-function-mlc-minilang-parser-tok-pos-inline-function-tok-pos-tok-mlc-minilang-parser-ml-1463903453"></a>
### _tok_pos

```ml
inline function _tok_pos(tok)
```

Parse or represent inline in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tok` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1743)

<a id="function-function-mlc-minilang-parser-tok-text-part-function-tok-text-part-v-mlc-minilang-parser-ml-396664280"></a>
### _tok_text_part

```ml
function _tok_text_part(v)
```

Converts tok text part.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L75)

<a id="function-function-mlc-minilang-parser-tok-value-inline-function-tok-value-tok-mlc-minilang-parser-ml-1239632543"></a>
### _tok_value

```ml
inline function _tok_value(tok)
```

Parse or represent inline in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tok` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1728)

<a id="function-function-mlc-minilang-parser-token-arena-grow-function-token-arena-grow-arena-mlc-minilang-parser-ml-2029556189"></a>
### _token_arena_grow

```ml
function _token_arena_grow(arena)
```

Converts token arena grow.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arena` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1335)

<a id="function-function-mlc-minilang-parser-token-arena-new-function-token-arena-new-source-len-mlc-minilang-parser-ml-349777331"></a>
### _token_arena_new

```ml
function _token_arena_new(source_len)
```

Converts token arena new.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source_len` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1259)

<a id="function-function-mlc-minilang-parser-token-count-inline-function-token-count-tokens-mlc-minilang-parser-ml-93148851"></a>
### _token_count

```ml
inline function _token_count(tokens)
```

Parse or represent inline in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tokens` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1706)

<a id="function-function-mlc-minilang-parser-token-fixed-value-inline-function-token-fixed-value-kind-mlc-minilang-parser-ml-1959595933"></a>
### _token_fixed_value

```ml
inline function _token_fixed_value(kind)
```

Parse or represent inline in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1321)

<a id="function-function-mlc-minilang-parser-token-kind-name-function-token-kind-name-kind-id-mlc-minilang-parser-ml-1488996580"></a>
### _token_kind_name

```ml
function _token_kind_name(kind_id)
```

Converts token kind name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind_id` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1239)

<a id="function-function-mlc-minilang-parser-token-pos-read-inline-function-token-pos-read-buf-index-mlc-minilang-parser-ml-680922676"></a>
### _token_pos_read

```ml
inline function _token_pos_read(buf, index)
```

Parse or represent inline in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buf` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1293)

<a id="function-function-mlc-minilang-parser-token-pos-write-function-token-pos-write-buf-index-value-mlc-minilang-parser-ml-800373794"></a>
### _token_pos_write

```ml
function _token_pos_write(buf, index, value)
```

Converts token pos write.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buf` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1287)

<a id="function-function-mlc-minilang-parser-token-push-function-token-push-arena-tail-kind-value-pos-mlc-minilang-parser-ml-55978270"></a>
### _token_push

```ml
function _token_push(arena, tail, kind, value, pos)
```

Converts token push.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arena` | `dynamic` | — |  |
| `tail` | `dynamic` | — |  |
| `kind` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |
| `pos` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1354)

<a id="function-function-mlc-minilang-parser-token-text-store-function-token-text-store-arena-kind-value-mlc-minilang-parser-ml-1527974076"></a>
### _token_text_store

```ml
function _token_text_store(arena, kind, value)
```

Converts token text store.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arena` | `dynamic` | — |  |
| `kind` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1299)

<a id="function-function-mlc-minilang-parser-token-u32-read-inline-function-token-u32-read-buf-index-mlc-minilang-parser-ml-1385632836"></a>
### _token_u32_read

```ml
inline function _token_u32_read(buf, index)
```

Parse or represent inline in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buf` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1280)

<a id="function-function-mlc-minilang-parser-token-u32-write-function-token-u32-write-buf-index-value-mlc-minilang-parser-ml-1588777074"></a>
### _token_u32_write

```ml
function _token_u32_write(buf, index, value)
```

Converts token u32 write.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buf` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1270)

<a id="global-global-mlc-minilang-parser-tokens-tokens-mlc-minilang-parser-ml-2015272622"></a>
### _tokens

```ml
_tokens
```

Track tokens compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1678)

<a id="function-function-mlc-minilang-parser-unknownchar-function-unknownchar-code-pos-mlc-minilang-parser-ml-1408950211"></a>
### _unknownChar

```ml
function _unknownChar(code, pos)
```

Parse or represent unknown char in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — |  |
| `pos` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1009)

- [mlc.minilang_parser.ArrayLit](Type-mlc-minilang-parser-arraylit-656474808.md) — struct
- [mlc.minilang_parser.Assign](Type-mlc-minilang-parser-assign-1007761259.md) — struct
- [mlc.minilang_parser.Bin](Type-mlc-minilang-parser-bin-1998589439.md) — struct
- [mlc.minilang_parser.Bool](Type-mlc-minilang-parser-bool-603315534.md) — struct
- [mlc.minilang_parser.Break](Type-mlc-minilang-parser-break-1655790281.md) — struct
- [mlc.minilang_parser.Call](Type-mlc-minilang-parser-call-1897501670.md) — struct
- [mlc.minilang_parser.CallArguments](Type-mlc-minilang-parser-callarguments-1742386262.md) — struct
- [mlc.minilang_parser.Coalesce](Type-mlc-minilang-parser-coalesce-494772053.md) — struct
- [mlc.minilang_parser.CompileFrame](Type-mlc-minilang-parser-compileframe-374349488.md) — struct
- [mlc.minilang_parser.CompileValue](Type-mlc-minilang-parser-compilevalue-2038743176.md) — struct
- [mlc.minilang_parser.ConstDecl](Type-mlc-minilang-parser-constdecl-754746585.md) — struct
- [mlc.minilang_parser.Continue](Type-mlc-minilang-parser-continue-985699467.md) — struct
- [mlc.minilang_parser.Defer](Type-mlc-minilang-parser-defer-1019681826.md) — struct
- [mlc.minilang_parser.DeferredCapture](Type-mlc-minilang-parser-deferredcapture-1728292781.md) — struct
- [mlc.minilang_parser.DoWhile](Type-mlc-minilang-parser-dowhile-251897496.md) — struct
- [mlc.minilang_parser.EnumDef](Type-mlc-minilang-parser-enumdef-15919810.md) — struct
- [mlc.minilang_parser.ExprStmt](Type-mlc-minilang-parser-exprstmt-450737835.md) — struct
- [mlc.minilang_parser.ExternFunctionDef](Type-mlc-minilang-parser-externfunctiondef-1997863891.md) — struct
- [mlc.minilang_parser.ExternParam](Type-mlc-minilang-parser-externparam-1182507013.md) — struct
- [mlc.minilang_parser.For](Type-mlc-minilang-parser-for-1070243377.md) — struct
- [mlc.minilang_parser.ForEach](Type-mlc-minilang-parser-foreach-1349937804.md) — struct
<a id="function-function-mlc-minilang-parser-format-error-function-format-error-source-filename-pos-message-kind-mlc-minilang-parser-ml-307693077"></a>
### format_error

```ml
function format_error(source, filename, pos, message, kind)
```

Converts format error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Source value to process. |
| `filename` | `dynamic` | — | Value supplied for `filename`. |
| `pos` | `dynamic` | — | Value supplied for `pos`. |
| `message` | `dynamic` | — | Value supplied for `message`. |
| `kind` | `dynamic` | — | Value supplied for `kind`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1655)

- [mlc.minilang_parser.FunctionDef](Type-mlc-minilang-parser-functiondef-216648509.md) — struct
- [mlc.minilang_parser.GlobalDecl](Type-mlc-minilang-parser-globaldecl-403376821.md) — struct
- [mlc.minilang_parser.If](Type-mlc-minilang-parser-if-362822741.md) — struct
- [mlc.minilang_parser.Import](Type-mlc-minilang-parser-import-1360417695.md) — struct
- [mlc.minilang_parser.Index](Type-mlc-minilang-parser-index-874095030.md) — struct
- [mlc.minilang_parser.InterfaceDef](Type-mlc-minilang-parser-interfacedef-539778880.md) — struct
- [mlc.minilang_parser.IsType](Type-mlc-minilang-parser-istype-489143510.md) — struct
- [mlc.minilang_parser.Lambda](Type-mlc-minilang-parser-lambda-1603308297.md) — struct
- [mlc.minilang_parser.LazyIteratorState](Type-mlc-minilang-parser-lazyiteratorstate-395155783.md) — struct
- [mlc.minilang_parser.Member](Type-mlc-minilang-parser-member-2130365468.md) — struct
- [mlc.minilang_parser.NamespaceDecl](Type-mlc-minilang-parser-namespacedecl-283089097.md) — struct
- [mlc.minilang_parser.NamespaceDef](Type-mlc-minilang-parser-namespacedef-1316150784.md) — struct
<a id="function-function-mlc-minilang-parser-newparseerror-function-newparseerror-message-pos-filename-mlc-minilang-parser-ml-282004966"></a>
### newParseError

```ml
function newParseError(message, pos, filename)
```

Creates new parse error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `message` | `dynamic` | — | Value supplied for `message`. |
| `pos` | `dynamic` | — | Value supplied for `pos`. |
| `filename` | `dynamic` | — | Value supplied for `filename`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L936)

<a id="function-function-mlc-minilang-parser-newtoken-function-newtoken-kind-value-pos-mlc-minilang-parser-ml-1173034097"></a>
### newToken

```ml
function newToken(kind, value, pos)
```

Creates new token.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — | Value supplied for `kind`. |
| `value` | `dynamic` | — | Value to process. |
| `pos` | `dynamic` | — | Value supplied for `pos`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L928)

- [mlc.minilang_parser.Num](Type-mlc-minilang-parser-num-328799274.md) — struct
<a id="function-function-mlc-minilang-parser-operator-method-name-function-operator-method-name-op-symbol-arity-mlc-minilang-parser-ml-311626071"></a>
### operator_method_name

```ml
function operator_method_name(op_symbol, arity)
```

Maps one supported source operator and arity to its reserved static method.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `op_symbol` | `dynamic` | — |  |
| `arity` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L2071)

- [mlc.minilang_parser.ParameterList](Type-mlc-minilang-parser-parameterlist-241020273.md) — struct
<a id="function-function-mlc-minilang-parser-parse-expression-function-parse-expression-source-filename-mlc-minilang-parser-ml-299887402"></a>
### parse_expression

```ml
function parse_expression(source, filename)
```

Returns parse expression.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Source value to process. |
| `filename` | `dynamic` | — | Value supplied for `filename`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4272)

<a id="function-function-mlc-minilang-parser-parse-program-function-parse-program-source-filename-mlc-minilang-parser-ml-1849808790"></a>
### parse_program

```ml
function parse_program(source, filename)
```

Returns parse program.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Source value to process. |
| `filename` | `dynamic` | — | Value supplied for `filename`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L6009)

<a id="function-function-mlc-minilang-parser-parse-program-keepgoing-function-parse-program-keepgoing-source-filename-max-errors-mlc-minilang-parser-ml-2140012046"></a>
### parse_program_keepgoing

```ml
function parse_program_keepgoing(source, filename, max_errors)
```

Returns parse program keepgoing.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Source value to process. |
| `filename` | `dynamic` | — | Value supplied for `filename`. |
| `max_errors` | `dynamic` | — | Value supplied for `max_errors`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L6037)

- [mlc.minilang_parser.ParseError](Type-mlc-minilang-parser-parseerror-782081393.md) — struct
- [mlc.minilang_parser.ParseKeepResult](Type-mlc-minilang-parser-parsekeepresult-1025636913.md) — struct
- [mlc.minilang_parser.ParserChunkTail](Type-mlc-minilang-parser-parserchunktail-1446198500.md) — struct
- [mlc.minilang_parser.ParserChunkVoidSentinel](Type-mlc-minilang-parser-parserchunkvoidsentinel-1142311564.md) — struct
<a id="function-function-mlc-minilang-parser-prepare-language-features-function-prepare-language-features-program-mlc-minilang-parser-ml-495971202"></a>
### prepare_language_features

```ml
function prepare_language_features(program)
```

Parse or represent prepare language features in the MiniLang front end.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — | Value supplied for `program`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L5968)

<a id="function-function-mlc-minilang-parser-preprocess-compile-directives-function-preprocess-compile-directives-code-filename-mlc-minilang-parser-ml-1776364800"></a>
### preprocess_compile_directives

```ml
function preprocess_compile_directives(code, filename)
```

Evaluate line-oriented directives and retain every original byte offset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | Source code to process. |
| `filename` | `dynamic` | — | Value supplied for `filename`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4740)

- [mlc.minilang_parser.Print](Type-mlc-minilang-parser-print-631789685.md) — struct
- [mlc.minilang_parser.Return](Type-mlc-minilang-parser-return-1467374892.md) — struct
- [mlc.minilang_parser.SafeMember](Type-mlc-minilang-parser-safemember-1978010909.md) — struct
<a id="function-function-mlc-minilang-parser-set-compile-defines-function-set-compile-defines-specs-mlc-minilang-parser-ml-651058748"></a>
### set_compile_defines

```ml
function set_compile_defines(specs)
```

Install command-line/project values. Later -D occurrences override earlier ones.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `specs` | `dynamic` | — | Value supplied for `specs`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4572)

<a id="function-function-mlc-minilang-parser-set-compile-target-function-set-compile-target-target-mlc-minilang-parser-ml-1786509371"></a>
### set_compile_target

```ml
function set_compile_target(target)
```

Select immutable values for subsequent source parses.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `target` | `dynamic` | — | Value supplied for `target`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L4373)

- [mlc.minilang_parser.SetIndex](Type-mlc-minilang-parser-setindex-553174214.md) — struct
- [mlc.minilang_parser.SetMember](Type-mlc-minilang-parser-setmember-1055617036.md) — struct
- [mlc.minilang_parser.Str](Type-mlc-minilang-parser-str-1070175973.md) — struct
- [mlc.minilang_parser.StructDef](Type-mlc-minilang-parser-structdef-1454499606.md) — struct
- [mlc.minilang_parser.Switch](Type-mlc-minilang-parser-switch-1024024746.md) — struct
- [mlc.minilang_parser.SwitchCase](Type-mlc-minilang-parser-switchcase-1317797750.md) — struct
- [mlc.minilang_parser.SynchronizedBlock](Type-mlc-minilang-parser-synchronizedblock-142144157.md) — struct
- [mlc.minilang_parser.SynchronizedDecl](Type-mlc-minilang-parser-synchronizeddecl-462840584.md) — struct
<a id="constant-constant-mlc-minilang-parser-tk-comma-const-tk-comma-12-mlc-minilang-parser-ml-499748098"></a>
### TK_COMMA

```ml
const TK_COMMA = 12
```

Track tk comma.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1036)

<a id="constant-constant-mlc-minilang-parser-tk-dot-const-tk-dot-7-mlc-minilang-parser-ml-490268796"></a>
### TK_DOT

```ml
const TK_DOT = 7
```

Track tk dot.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1026)

<a id="constant-constant-mlc-minilang-parser-tk-eof-const-tk-eof-14-mlc-minilang-parser-ml-605410542"></a>
### TK_EOF

```ml
const TK_EOF = 14
```

Track tk eof.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1040)

<a id="constant-constant-mlc-minilang-parser-tk-ident-const-tk-ident-5-mlc-minilang-parser-ml-1806349288"></a>
### TK_IDENT

```ml
const TK_IDENT = 5
```

Track tk ident.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1022)

<a id="constant-constant-mlc-minilang-parser-tk-kw-const-tk-kw-4-mlc-minilang-parser-ml-628864999"></a>
### TK_KW

```ml
const TK_KW = 4
```

Track tk kw.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1020)

<a id="constant-constant-mlc-minilang-parser-tk-lbrack-const-tk-lbrack-10-mlc-minilang-parser-ml-1186816136"></a>
### TK_LBRACK

```ml
const TK_LBRACK = 10
```

Track tk lbrack.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1032)

<a id="constant-constant-mlc-minilang-parser-tk-lparen-const-tk-lparen-8-mlc-minilang-parser-ml-1975969363"></a>
### TK_LPAREN

```ml
const TK_LPAREN = 8
```

Track tk lparen.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1028)

<a id="constant-constant-mlc-minilang-parser-tk-nl-const-tk-nl-1-mlc-minilang-parser-ml-1302957582"></a>
### TK_NL

```ml
const TK_NL = 1
```

Compact discriminants stored in the token arena's byte kind column.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1014)

<a id="constant-constant-mlc-minilang-parser-tk-number-const-tk-number-2-mlc-minilang-parser-ml-1801718313"></a>
### TK_NUMBER

```ml
const TK_NUMBER = 2
```

Track tk number.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1016)

<a id="constant-constant-mlc-minilang-parser-tk-op-const-tk-op-6-mlc-minilang-parser-ml-381245417"></a>
### TK_OP

```ml
const TK_OP = 6
```

Track tk op.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1024)

<a id="constant-constant-mlc-minilang-parser-tk-rbrack-const-tk-rbrack-11-mlc-minilang-parser-ml-2101395197"></a>
### TK_RBRACK

```ml
const TK_RBRACK = 11
```

Track tk rbrack.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1034)

<a id="constant-constant-mlc-minilang-parser-tk-rparen-const-tk-rparen-9-mlc-minilang-parser-ml-1884949334"></a>
### TK_RPAREN

```ml
const TK_RPAREN = 9
```

Track tk rparen.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1030)

<a id="constant-constant-mlc-minilang-parser-tk-semi-const-tk-semi-13-mlc-minilang-parser-ml-1445543147"></a>
### TK_SEMI

```ml
const TK_SEMI = 13
```

Track tk semi.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1038)

<a id="constant-constant-mlc-minilang-parser-tk-string-const-tk-string-3-mlc-minilang-parser-ml-1919192320"></a>
### TK_STRING

```ml
const TK_STRING = 3
```

Track tk string.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1018)

- [mlc.minilang_parser.Token](Type-mlc-minilang-parser-token-1078023415.md) — struct
- [mlc.minilang_parser.TokenArena](Type-mlc-minilang-parser-tokenarena-1905929590.md) — struct
<a id="function-function-mlc-minilang-parser-tokenize-function-tokenize-code-mlc-minilang-parser-ml-697094663"></a>
### tokenize

```ml
function tokenize(code)
```

Converts tokenize.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | Source code to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minilang_parser.ml#L1370)

- [mlc.minilang_parser.TypeGuard](Type-mlc-minilang-parser-typeguard-538254235.md) — struct
- [mlc.minilang_parser.Unary](Type-mlc-minilang-parser-unary-1983916477.md) — struct
- [mlc.minilang_parser.Var](Type-mlc-minilang-parser-var-95406095.md) — struct
- [mlc.minilang_parser.VoidLit](Type-mlc-minilang-parser-voidlit-556229069.md) — struct
- [mlc.minilang_parser.While](Type-mlc-minilang-parser-while-1382365767.md) — struct
- [mlc.minilang_parser.Yield](Type-mlc-minilang-parser-yield-794322735.md) — struct
