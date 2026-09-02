# `mlc/codegen/codegen_core.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc codegen codegen_core package.

Package: [`mlc.codegen.codegen_core`](Package-mlc-codegen-codegen-core-1455908485.md)

Reachable from entry: **yes**

## Imports

- `mlc/asm.ml` as `a` → [mlc/asm.ml](File-mlc-asm-ml-1368648960.md)
- `mlc/codegen/codegen_builtins_alloc.ml` as `bal` → [mlc/codegen/codegen_builtins_alloc.ml](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- `mlc/codegen/codegen_memory.ml` as `mem` → [mlc/codegen/codegen_memory.ml](File-mlc-codegen-codegen-memory-ml-2136639668.md)
- `mlc/codegen/codegen_runtime.ml` as `rt` → [mlc/codegen/codegen_runtime.ml](File-mlc-codegen-codegen-runtime-ml-1845689217.md)
- `mlc/codegen/codegen_scope.ml` as `scope` → [mlc/codegen/codegen_scope.ml](File-mlc-codegen-codegen-scope-ml-1124416197.md)
- `mlc/codegen/codegen_threads.ml` as `th` → [mlc/codegen/codegen_threads.ml](File-mlc-codegen-codegen-threads-ml-1261658982.md)
- `mlc/constants.ml` as `c` → [mlc/constants.ml](File-mlc-constants-ml-1024884042.md)
- `mlc/data.ml` as `d` → [mlc/data.ml](File-mlc-data-ml-557434521.md)
- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)
- `std/string.ml` as `s` → `std/string.ml` — external dependency

## Declarations

<a id="function-function-mlc-codegen-codegen-core-init-function-init-state-mlc-codegen-codegen-core-ml-601790500"></a>
### __init__

```ml
function __init__(state)
```

Python CodegenCore API compatibility surface.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L715)

<a id="function-function-mlc-codegen-codegen-core-add-extern-imports-function-add-extern-imports-state-mlc-codegen-codegen-core-ml-1096554156"></a>
### _add_extern_imports

```ml
function _add_extern_imports(state)
```

Updates add extern imports.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L847)

<a id="function-function-mlc-codegen-codegen-core-append-unique-function-append-unique-vals-v-mlc-codegen-codegen-core-ml-2130500377"></a>
### _append_unique

```ml
function _append_unique(vals, v)
```

Updates append unique.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `vals` | `dynamic` | — |  |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L310)

<a id="function-function-mlc-codegen-codegen-core-apply-import-alias-function-apply-import-alias-state-qname-mlc-codegen-codegen-core-ml-976862152"></a>
### _apply_import_alias

```ml
function _apply_import_alias(state, qname)
```

Emit apply import alias as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L965)

<a id="function-function-mlc-codegen-codegen-core-arr-contains-function-arr-contains-arr-value-mlc-codegen-codegen-core-ml-1072187305"></a>
### _arr_contains

```ml
function _arr_contains(arr, value)
```

Emit arr contains as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1722)

<a id="function-function-mlc-codegen-codegen-core-cold-block-frame-items-function-cold-block-frame-items-frame-mlc-codegen-codegen-core-ml-257496788"></a>
### _cold_block_frame_items

```ml
function _cold_block_frame_items(frame)
```

Emit cold block frame items as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frame` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1307)

<a id="function-function-mlc-codegen-codegen-core-collect-pending-helpers-function-collect-pending-helpers-state-emitted-index-mlc-codegen-codegen-core-ml-2122030713"></a>
### _collect_pending_helpers

```ml
function _collect_pending_helpers(state, emitted_index)
```

Emit collect pending helpers as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `emitted_index` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L2091)

<a id="function-function-mlc-codegen-codegen-core-current-file-package-prefix-function-current-file-package-prefix-state-mlc-codegen-codegen-core-ml-405124012"></a>
### _current_file_package_prefix

```ml
function _current_file_package_prefix(state)
```

Emit current file package prefix as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1006)

<a id="function-function-mlc-codegen-codegen-core-current-function-prefix-function-current-function-prefix-state-mlc-codegen-codegen-core-ml-1933834288"></a>
### _current_function_prefix

```ml
function _current_function_prefix(state)
```

Emit current function prefix as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1013)

<a id="function-function-mlc-codegen-codegen-core-emit-helper-by-label-function-emit-helper-by-label-state-lbl-mlc-codegen-codegen-core-ml-1375139322"></a>
### _emit_helper_by_label

```ml
function _emit_helper_by_label(state, lbl)
```

Emit emit helper by label as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `lbl` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L2041)

<a id="function-function-mlc-codegen-codegen-core-emit-helper-by-label-group0-function-emit-helper-by-label-group0-state-lbl-mlc-codegen-codegen-core-ml-601287338"></a>
### _emit_helper_by_label_group0

```ml
function _emit_helper_by_label_group0(state, lbl)
```

Emit emit helper by label group0 as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `lbl` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1881)

<a id="function-function-mlc-codegen-codegen-core-emit-helper-by-label-group1-function-emit-helper-by-label-group1-state-lbl-mlc-codegen-codegen-core-ml-1866673370"></a>
### _emit_helper_by_label_group1

```ml
function _emit_helper_by_label_group1(state, lbl)
```

Emit emit helper by label group1 as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `lbl` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1934)

<a id="function-function-mlc-codegen-codegen-core-emit-helper-by-label-group2-function-emit-helper-by-label-group2-state-lbl-mlc-codegen-codegen-core-ml-1090914018"></a>
### _emit_helper_by_label_group2

```ml
function _emit_helper_by_label_group2(state, lbl)
```

Emit emit helper by label group2 as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `lbl` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1950)

<a id="function-function-mlc-codegen-codegen-core-emit-helper-by-label-group3-function-emit-helper-by-label-group3-state-lbl-mlc-codegen-codegen-core-ml-831714354"></a>
### _emit_helper_by_label_group3

```ml
function _emit_helper_by_label_group3(state, lbl)
```

Emit emit helper by label group3 as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `lbl` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1966)

<a id="function-function-mlc-codegen-codegen-core-emit-helper-by-label-group4-function-emit-helper-by-label-group4-state-lbl-mlc-codegen-codegen-core-ml-1676083794"></a>
### _emit_helper_by_label_group4

```ml
function _emit_helper_by_label_group4(state, lbl)
```

Emit emit helper by label group4 as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `lbl` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1982)

<a id="function-function-mlc-codegen-codegen-core-emit-helper-by-label-group5-function-emit-helper-by-label-group5-state-lbl-mlc-codegen-codegen-core-ml-1758662258"></a>
### _emit_helper_by_label_group5

```ml
function _emit_helper_by_label_group5(state, lbl)
```

Emit emit helper by label group5 as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `lbl` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1998)

<a id="function-function-mlc-codegen-codegen-core-emit-helper-by-label-group6-function-emit-helper-by-label-group6-state-lbl-mlc-codegen-codegen-core-ml-1657138890"></a>
### _emit_helper_by_label_group6

```ml
function _emit_helper_by_label_group6(state, lbl)
```

Emit emit helper by label group6 as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `lbl` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L2015)

<a id="function-function-mlc-codegen-codegen-core-emit-helper-by-label-other-function-emit-helper-by-label-other-state-lbl-mlc-codegen-codegen-core-ml-2101739024"></a>
### _emit_helper_by_label_other

```ml
function _emit_helper_by_label_other(state, lbl)
```

Emit emit helper by label other as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `lbl` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L2029)

<a id="function-function-mlc-codegen-codegen-core-expr-temp-live-by-reg-get-function-expr-temp-live-by-reg-get-state-reg-mlc-codegen-codegen-core-ml-1843874942"></a>
### _expr_temp_live_by_reg_get

```ml
function _expr_temp_live_by_reg_get(state, reg)
```

Emit expr temp live by reg get as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `reg` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L362)

<a id="function-function-mlc-codegen-codegen-core-expr-temp-live-by-reg-remove-function-expr-temp-live-by-reg-remove-state-reg-mlc-codegen-codegen-core-ml-1774523718"></a>
### _expr_temp_live_by_reg_remove

```ml
function _expr_temp_live_by_reg_remove(state, reg)
```

Emit expr temp live by reg remove as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `reg` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L375)

<a id="function-function-mlc-codegen-codegen-core-expr-temp-live-by-reg-set-function-expr-temp-live-by-reg-set-state-reg-tmp-mlc-codegen-codegen-core-ml-1426865513"></a>
### _expr_temp_live_by_reg_set

```ml
function _expr_temp_live_by_reg_set(state, reg, tmp)
```

Emit expr temp live by reg set as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `reg` | `dynamic` | — |  |
| `tmp` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L368)

<a id="function-function-mlc-codegen-codegen-core-expr-temp-named-get-function-expr-temp-named-get-entries-key-defaultv-mlc-codegen-codegen-core-ml-411406927"></a>
### _expr_temp_named_get

```ml
function _expr_temp_named_get(entries, key, defaultv)
```

Emit expr temp named get as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entries` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L322)

<a id="function-function-mlc-codegen-codegen-core-expr-temp-named-remove-function-expr-temp-named-remove-entries-key-mlc-codegen-codegen-core-ml-555371812"></a>
### _expr_temp_named_remove

```ml
function _expr_temp_named_remove(entries, key)
```

Emit expr temp named remove as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entries` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L349)

<a id="function-function-mlc-codegen-codegen-core-expr-temp-named-set-function-expr-temp-named-set-entries-key-value-mlc-codegen-codegen-core-ml-1101421503"></a>
### _expr_temp_named_set

```ml
function _expr_temp_named_set(entries, key, value)
```

Emit expr temp named set as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entries` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L333)

<a id="function-function-mlc-codegen-codegen-core-expr-temp-reserved-dec-function-expr-temp-reserved-dec-state-reg-mlc-codegen-codegen-core-ml-2003649144"></a>
### _expr_temp_reserved_dec

```ml
function _expr_temp_reserved_dec(state, reg)
```

Emit expr temp reserved dec as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `reg` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L395)

<a id="function-function-mlc-codegen-codegen-core-expr-temp-reserved-get-function-expr-temp-reserved-get-state-reg-mlc-codegen-codegen-core-ml-294996296"></a>
### _expr_temp_reserved_get

```ml
function _expr_temp_reserved_get(state, reg)
```

Emit expr temp reserved get as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `reg` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L382)

<a id="function-function-mlc-codegen-codegen-core-expr-temp-reserved-set-function-expr-temp-reserved-set-state-reg-value-mlc-codegen-codegen-core-ml-24002835"></a>
### _expr_temp_reserved_set

```ml
function _expr_temp_reserved_set(state, reg, value)
```

Emit expr temp reserved set as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `reg` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L388)

<a id="function-function-mlc-codegen-codegen-core-flatten-member-chain-as-qualname-function-flatten-member-chain-as-qualname-expr-mlc-codegen-codegen-core-ml-1396342940"></a>
### _flatten_member_chain_as_qualname

```ml
function _flatten_member_chain_as_qualname(expr)
```

Emit flatten member chain as qualname as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L950)

<a id="function-function-mlc-codegen-codegen-core-helper-rank-function-helper-rank-lbl-mlc-codegen-codegen-core-ml-1240378861"></a>
### _helper_rank

```ml
function _helper_rank(lbl)
```

Emit helper rank as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lbl` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L2055)

<a id="function-function-mlc-codegen-codegen-core-helper-supported-function-helper-supported-lbl-mlc-codegen-codegen-core-ml-877322769"></a>
### _helper_supported

```ml
function _helper_supported(lbl)
```

Emit helper supported as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lbl` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1763)

<a id="function-function-mlc-codegen-codegen-core-import-pair-gt-function-import-pair-gt-a-b-mlc-codegen-codegen-core-ml-1977412070"></a>
### _import_pair_gt

```ml
function _import_pair_gt(a, b)
```

Emit import pair gt as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L812)

<a id="function-function-mlc-codegen-codegen-core-import-string-gt-function-import-string-gt-a-b-mlc-codegen-codegen-core-ml-1926425052"></a>
### _import_string_gt

```ml
function _import_string_gt(a, b)
```

Emit import string gt as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L793)

<a id="function-function-mlc-codegen-codegen-core-imports-get-funcs-function-imports-get-funcs-imports-dll-mlc-codegen-codegen-core-ml-1430142115"></a>
### _imports_get_funcs

```ml
function _imports_get_funcs(imports, dll)
```

Emit imports get funcs as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `imports` | `dynamic` | — |  |
| `dll` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L431)

<a id="function-function-mlc-codegen-codegen-core-imports-set-funcs-function-imports-set-funcs-imports-dll-funcs-mlc-codegen-codegen-core-ml-902529964"></a>
### _imports_set_funcs

```ml
function _imports_set_funcs(imports, dll, funcs)
```

Emit imports set funcs as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `imports` | `dynamic` | — |  |
| `dll` | `dynamic` | — |  |
| `funcs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L445)

<a id="function-function-mlc-codegen-codegen-core-is-internal-helper-label-function-is-internal-helper-label-lbl-mlc-codegen-codegen-core-ml-214788387"></a>
### _is_internal_helper_label

```ml
function _is_internal_helper_label(lbl)
```

Reports whether is internal helper label.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lbl` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1752)

<a id="function-function-mlc-codegen-codegen-core-line-from-pos-function-line-from-pos-state-pos-filename-mlc-codegen-codegen-core-ml-282494713"></a>
### _line_from_pos

```ml
function _line_from_pos(state, pos, filename)
```

Emit line from pos as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `pos` | `dynamic` | — |  |
| `filename` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L912)

<a id="function-function-mlc-codegen-codegen-core-pos-function-pos-node-mlc-codegen-codegen-core-ml-339808289"></a>
### _pos

```ml
function _pos(node)
```

Emit pos as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L887)

<a id="function-function-mlc-codegen-codegen-core-pretty-script-function-pretty-script-state-p-mlc-codegen-codegen-core-ml-148685144"></a>
### _pretty_script

```ml
function _pretty_script(state, p)
```

Emit pretty script as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `p` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L721)

<a id="function-function-mlc-codegen-codegen-core-qualify-identifier-function-qualify-identifier-state-name-node-kind-mlc-codegen-codegen-core-ml-2040422059"></a>
### _qualify_identifier

```ml
function _qualify_identifier(state, name, node, kind)
```

Emit qualify identifier as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `node` | `dynamic` | — |  |
| `kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1022)

<a id="function-function-mlc-codegen-codegen-core-seed-data-function-seed-data-cg-mlc-codegen-codegen-core-ml-907394887"></a>
### _seed_data

```ml
function _seed_data(cg)
```

Emit seed data as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cg` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L519)

<a id="function-function-mlc-codegen-codegen-core-seed-rdata-function-seed-rdata-cg-mlc-codegen-codegen-core-ml-1559276861"></a>
### _seed_rdata

```ml
function _seed_rdata(cg)
```

Emit seed rdata as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cg` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L459)

<a id="function-function-mlc-codegen-codegen-core-sort-import-pairs-function-sort-import-pairs-pairs-mlc-codegen-codegen-core-ml-150756412"></a>
### _sort_import_pairs

```ml
function _sort_import_pairs(pairs)
```

Emit sort import pairs as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pairs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L829)

<a id="function-function-mlc-codegen-codegen-core-source-for-dbg-filename-function-source-for-dbg-filename-state-filename-mlc-codegen-codegen-core-ml-276669219"></a>
### _source_for_dbg_filename

```ml
function _source_for_dbg_filename(state, filename)
```

Emit source for dbg filename as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `filename` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L893)

<a id="function-function-mlc-codegen-codegen-core-spill-live-expr-value-temps-function-spill-live-expr-value-temps-state-mlc-codegen-codegen-core-ml-1066639104"></a>
### _spill_live_expr_value_temps

```ml
function _spill_live_expr_value_temps(state)
```

Emit spill live expr value temps as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1124)

<a id="function-function-mlc-codegen-codegen-core-starts-with-function-starts-with-text-prefix-mlc-codegen-codegen-core-ml-1683870160"></a>
### _starts_with

```ml
function _starts_with(text, prefix)
```

Emit starts with as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |
| `prefix` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1709)

<a id="function-function-mlc-codegen-codegen-core-str-less-ascii-function-str-less-ascii-a-b-mlc-codegen-codegen-core-ml-181873084"></a>
### _str_less_ascii

```ml
function _str_less_ascii(a, b)
```

Emit str less ascii as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1732)

<a id="function-function-mlc-codegen-codegen-core-sync-asm-before-call-live-function-sync-asm-before-call-live-state-mlc-codegen-codegen-core-ml-1220244748"></a>
### _sync_asm_before_call_live

```ml
function _sync_asm_before_call_live(state)
```

Emit sync asm before call live as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L422)

<a id="function-function-mlc-codegen-codegen-core-sync-expr-temp-root-count-function-sync-expr-temp-root-count-state-mlc-codegen-codegen-core-ml-1801879420"></a>
### _sync_expr_temp_root_count

```ml
function _sync_expr_temp_root_count(state)
```

Emit sync expr temp root count as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L408)

<a id="function-function-mlc-codegen-codegen-core-track-call-label-function-track-call-label-state-lbl-mlc-codegen-codegen-core-ml-1543685810"></a>
### _track_call_label

```ml
function _track_call_label(state, lbl)
```

Emit track call label as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `lbl` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L758)

<a id="function-function-mlc-codegen-codegen-core-add-import-symbol-function-add-import-symbol-state-dll-sym-mlc-codegen-codegen-core-ml-1069918773"></a>
### add_import_symbol

```ml
function add_import_symbol(state, dll, sym)
```

Updates add import symbol.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `dll` | `dynamic` | — | Value supplied for `dll`. |
| `sym` | `dynamic` | — | Value supplied for `sym`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L782)

<a id="function-function-mlc-codegen-codegen-core-alloc-expr-temps-function-alloc-expr-temps-state-size-mlc-codegen-codegen-core-ml-2015718275"></a>
### alloc_expr_temps

```ml
function alloc_expr_temps(state, size)
```

Creates alloc expr temps.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `size` | `dynamic` | — | Value supplied for `size`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1042)

<a id="function-function-mlc-codegen-codegen-core-alloc-expr-value-temp-function-alloc-expr-value-temp-state-prefer-reg-mlc-codegen-codegen-core-ml-1136061953"></a>
### alloc_expr_value_temp

```ml
function alloc_expr_value_temp(state, prefer_reg)
```

Creates alloc expr value temp.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `prefer_reg` | `dynamic` | — | Value supplied for `prefer_reg`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1187)

<a id="function-function-mlc-codegen-codegen-core-cg-core-init-function-cg-core-init-state-mlc-codegen-codegen-core-ml-121868868"></a>
### cg_core_init

```ml
function cg_core_init(state)
```

Emit cg core init as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L709)

<a id="function-function-mlc-codegen-codegen-core-cg-core-new-function-cg-core-new-source-filename-import-aliases-extern-sigs-extern-structs-target-heap-config-mlc-codegen-codegen-core-ml-166396853"></a>
### cg_core_new

```ml
function cg_core_new(source, filename, import_aliases, extern_sigs, extern_structs, target, heap_config)
```

Emit cg core new as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Source value to process. |
| `filename` | `dynamic` | — | Value supplied for `filename`. |
| `import_aliases` | `dynamic` | — | Value supplied for `import_aliases`. |
| `extern_sigs` | `dynamic` | — | Value supplied for `extern_sigs`. |
| `extern_structs` | `dynamic` | — | Value supplied for `extern_structs`. |
| `target` | `dynamic` | — | Value supplied for `target`. |
| `heap_config` | `dynamic` | — | Value supplied for `heap_config`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L574)

- [mlc.codegen.codegen_core.CgState](Type-mlc-codegen-codegen-core-cgstate-564277748.md) — struct
<a id="function-function-mlc-codegen-codegen-core-core-error-function-core-error-state-msg-node-mlc-codegen-codegen-core-ml-458624551"></a>
### core_error

```ml
function core_error(state, msg, node)
```

Emit core error as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `msg` | `dynamic` | — | Value supplied for `msg`. |
| `node` | `dynamic` | — | Value supplied for `node`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1387)

<a id="function-function-mlc-codegen-codegen-core-defer-cold-block-function-defer-cold-block-state-label-emitter-mlc-codegen-codegen-core-ml-464817104"></a>
### defer_cold_block

```ml
function defer_cold_block(state, label, emitter)
```

Emit defer cold block as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `label` | `dynamic` | — | Value supplied for `label`. |
| `emitter` | `dynamic` | — | Value supplied for `emitter`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1336)

<a id="function-function-mlc-codegen-codegen-core-emit-dbg-line-function-emit-dbg-line-state-node-mlc-codegen-codegen-core-ml-1632173688"></a>
### emit_dbg_line

```ml
function emit_dbg_line(state, node)
```

Emit emit dbg line as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `node` | `dynamic` | — | Value supplied for `node`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1396)

<a id="function-function-mlc-codegen-codegen-core-emit-deferred-cold-blocks-function-emit-deferred-cold-blocks-state-mlc-codegen-codegen-core-ml-348961366"></a>
### emit_deferred_cold_blocks

```ml
function emit_deferred_cold_blocks(state)
```

Emit emit deferred cold blocks as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1357)

<a id="function-function-mlc-codegen-codegen-core-emit-force-xmm0-to-float-value-function-emit-force-xmm0-to-float-value-state-mlc-codegen-codegen-core-ml-239107252"></a>
### emit_force_xmm0_to_float_value

```ml
function emit_force_xmm0_to_float_value(state)
```

Emit emit force xmm0 to float value as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1534)

<a id="function-function-mlc-codegen-codegen-core-emit-jmp-if-false-rax-function-emit-jmp-if-false-rax-state-false-label-mlc-codegen-codegen-core-ml-1085469272"></a>
### emit_jmp_if_false_rax

```ml
function emit_jmp_if_false_rax(state, false_label)
```

Emit emit jmp if false rax as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `false_label` | `dynamic` | — | Value supplied for `false_label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1612)

<a id="function-function-mlc-codegen-codegen-core-emit-load-var-function-emit-load-var-state-name-node-mlc-codegen-codegen-core-ml-1640032077"></a>
### emit_load_var

```ml
function emit_load_var(state, name, node)
```

Emit emit load var as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `node` | `dynamic` | — | Value supplied for `node`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1436)

<a id="function-function-mlc-codegen-codegen-core-emit-normalize-xmm0-to-value-function-emit-normalize-xmm0-to-value-state-mlc-codegen-codegen-core-ml-1541917136"></a>
### emit_normalize_xmm0_to_value

```ml
function emit_normalize_xmm0_to_value(state)
```

Emit emit normalize xmm0 to value as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1500)

<a id="function-function-mlc-codegen-codegen-core-emit-store-var-function-emit-store-var-state-name-node-mlc-codegen-codegen-core-ml-681696745"></a>
### emit_store_var

```ml
function emit_store_var(state, name, node)
```

Emit emit store var as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `node` | `dynamic` | — | Value supplied for `node`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1444)

<a id="function-function-mlc-codegen-codegen-core-emit-struct-field-dispatch-function-emit-struct-field-dispatch-state-field-mlc-codegen-codegen-core-ml-821142380"></a>
### emit_struct_field_dispatch

```ml
function emit_struct_field_dispatch(state, field)
```

Emit emit struct field dispatch as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `field` | `dynamic` | — | Value supplied for `field`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1693)

<a id="function-function-mlc-codegen-codegen-core-emit-struct-field-index-dispatch-function-emit-struct-field-index-dispatch-state-field-mlc-codegen-codegen-core-ml-1713913244"></a>
### emit_struct_field_index_dispatch

```ml
function emit_struct_field_index_dispatch(state, field)
```

Emit emit struct field index dispatch as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `field` | `dynamic` | — | Value supplied for `field`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1686)

<a id="function-function-mlc-codegen-codegen-core-emit-to-double-xmm-function-emit-to-double-xmm-state-xmm-fail-label-mlc-codegen-codegen-core-ml-1685662773"></a>
### emit_to_double_xmm

```ml
function emit_to_double_xmm(state, xmm, fail_label)
```

Emit emit to double xmm as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `xmm` | `dynamic` | — | Value supplied for `xmm`. |
| `fail_label` | `dynamic` | — | Value supplied for `fail_label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1557)

<a id="function-function-mlc-codegen-codegen-core-emit-used-helpers-function-emit-used-helpers-state-mlc-codegen-codegen-core-ml-1846412650"></a>
### emit_used_helpers

```ml
function emit_used_helpers(state)
```

Emit emit used helpers as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L2124)

<a id="function-function-mlc-codegen-codegen-core-emit-writefile-function-emit-writefile-state-buf-label-length-mlc-codegen-codegen-core-ml-669236840"></a>
### emit_writefile

```ml
function emit_writefile(state, buf_label, length)
```

Emit emit writefile as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `buf_label` | `dynamic` | — | Value supplied for `buf_label`. |
| `length` | `dynamic` | — | Number of elements or bytes to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1452)

<a id="function-function-mlc-codegen-codegen-core-emit-writefile-ptr-len-function-emit-writefile-ptr-len-state-mlc-codegen-codegen-core-ml-1259094248"></a>
### emit_writefile_ptr_len

```ml
function emit_writefile_ptr_len(state)
```

Emit emit writefile ptr len as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1460)

<a id="function-function-mlc-codegen-codegen-core-emit-writefile-ptr-len-stderr-function-emit-writefile-ptr-len-stderr-state-mlc-codegen-codegen-core-ml-1237776810"></a>
### emit_writefile_ptr_len_stderr

```ml
function emit_writefile_ptr_len_stderr(state)
```

Emit emit writefile ptr len stderr as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1471)

<a id="function-function-mlc-codegen-codegen-core-emit-writefile-stderr-function-emit-writefile-stderr-state-buf-label-length-mlc-codegen-codegen-core-ml-754523848"></a>
### emit_writefile_stderr

```ml
function emit_writefile_stderr(state, buf_label, length)
```

Emit emit writefile stderr as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `buf_label` | `dynamic` | — | Value supplied for `buf_label`. |
| `length` | `dynamic` | — | Number of elements or bytes to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1492)

<a id="function-function-mlc-codegen-codegen-core-ensure-var-function-ensure-var-state-name-mlc-codegen-codegen-core-ml-264316497"></a>
### ensure_var

```ml
function ensure_var(state, name)
```

Emit ensure var as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1378)

<a id="function-function-mlc-codegen-codegen-core-expr-value-temp-load-function-expr-value-temp-load-state-dst-tmp-mlc-codegen-codegen-core-ml-53924732"></a>
### expr_value_temp_load

```ml
function expr_value_temp_load(state, dst, tmp)
```

Emit expr value temp load as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `tmp` | `dynamic` | — | Value supplied for `tmp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1248)

<a id="function-function-mlc-codegen-codegen-core-expr-value-temp-offset-function-expr-value-temp-offset-state-tmp-mlc-codegen-codegen-core-ml-584030763"></a>
### expr_value_temp_offset

```ml
function expr_value_temp_offset(state, tmp)
```

Emit expr value temp offset as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `tmp` | `dynamic` | — | Value supplied for `tmp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1264)

<a id="function-function-mlc-codegen-codegen-core-expr-value-temp-store-rax-function-expr-value-temp-store-rax-state-tmp-mlc-codegen-codegen-core-ml-2049784547"></a>
### expr_value_temp_store_rax

```ml
function expr_value_temp_store_rax(state, tmp)
```

Emit expr value temp store rax as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `tmp` | `dynamic` | — | Value supplied for `tmp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1216)

<a id="function-function-mlc-codegen-codegen-core-expr-value-temp-store-reg-function-expr-value-temp-store-reg-state-tmp-reg-mlc-codegen-codegen-core-ml-550453229"></a>
### expr_value_temp_store_reg

```ml
function expr_value_temp_store_reg(state, tmp, reg)
```

Emit expr value temp store reg as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `tmp` | `dynamic` | — | Value supplied for `tmp`. |
| `reg` | `dynamic` | — | Value supplied for `reg`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1231)

- [mlc.codegen.codegen_core.ExprValueTemp](Type-mlc-codegen-codegen-core-exprvaluetemp-797235005.md) — struct
<a id="function-function-mlc-codegen-codegen-core-free-expr-temps-function-free-expr-temps-state-size-mlc-codegen-codegen-core-ml-683362087"></a>
### free_expr_temps

```ml
function free_expr_temps(state, size)
```

Releases or resets free expr temps.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `size` | `dynamic` | — | Value supplied for `size`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1075)

<a id="function-function-mlc-codegen-codegen-core-free-expr-value-temp-function-free-expr-value-temp-state-tmp-mlc-codegen-codegen-core-ml-1510979115"></a>
### free_expr_value_temp

```ml
function free_expr_value_temp(state, tmp)
```

Releases or resets free expr value temp.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `tmp` | `dynamic` | — | Value supplied for `tmp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1276)

<a id="function-function-mlc-codegen-codegen-core-in-function-function-in-function-state-mlc-codegen-codegen-core-ml-1199782140"></a>
### in_function

```ml
function in_function(state)
```

Emit in function as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L767)

- [mlc.codegen.codegen_core.NamedAny](Type-mlc-codegen-codegen-core-namedany-1758903068.md) — struct
- [mlc.codegen.codegen_core.NamedArray](Type-mlc-codegen-codegen-core-namedarray-1264240587.md) — struct
- [mlc.codegen.codegen_core.NamedInt](Type-mlc-codegen-codegen-core-namedint-1998004339.md) — struct
<a id="function-function-mlc-codegen-codegen-core-new-label-id-function-new-label-id-state-mlc-codegen-codegen-core-ml-995776928"></a>
### new_label_id

```ml
function new_label_id(state)
```

Creates new label id.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L773)

<a id="function-function-mlc-codegen-codegen-core-pop-cold-block-scope-function-pop-cold-block-scope-state-mlc-codegen-codegen-core-ml-880099660"></a>
### pop_cold_block_scope

```ml
function pop_cold_block_scope(state)
```

Emit pop cold block scope as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1317)

<a id="function-function-mlc-codegen-codegen-core-push-cold-block-scope-function-push-cold-block-scope-state-mlc-codegen-codegen-core-ml-1356668072"></a>
### push_cold_block_scope

```ml
function push_cold_block_scope(state)
```

Updates push cold block scope.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1299)

<a id="function-function-mlc-codegen-codegen-core-release-expr-temp-regs-function-release-expr-temp-regs-state-regs-mlc-codegen-codegen-core-ml-1676246493"></a>
### release_expr_temp_regs

```ml
function release_expr_temp_regs(state, regs)
```

Releases or resets release expr temp regs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `regs` | `dynamic` | — | Value supplied for `regs`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1174)

<a id="function-function-mlc-codegen-codegen-core-release-expr-temps-function-release-expr-temps-state-size-mlc-codegen-codegen-core-ml-1399238923"></a>
### release_expr_temps

```ml
function release_expr_temps(state, size)
```

Releases or resets release expr temps.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `size` | `dynamic` | — | Value supplied for `size`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1101)

<a id="function-function-mlc-codegen-codegen-core-reserve-expr-temp-regs-function-reserve-expr-temp-regs-state-regs-mlc-codegen-codegen-core-ml-1262042661"></a>
### reserve_expr_temp_regs

```ml
function reserve_expr_temp_regs(state, regs)
```

Emit reserve expr temp regs as shared native-codegen support.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `regs` | `dynamic` | — | Value supplied for `regs`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1140)

<a id="function-function-mlc-codegen-codegen-core-reset-helper-tracking-function-reset-helper-tracking-state-mlc-codegen-codegen-core-ml-2008871044"></a>
### reset_helper_tracking

```ml
function reset_helper_tracking(state)
```

Releases or resets reset helper tracking.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L1699)
