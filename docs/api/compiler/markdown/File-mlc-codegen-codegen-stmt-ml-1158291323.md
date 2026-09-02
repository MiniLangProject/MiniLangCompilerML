# `mlc/codegen/codegen_stmt.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc codegen codegen_stmt package.

Package: [`mlc.codegen.codegen_stmt`](Package-mlc-codegen-codegen-stmt-1832335268.md)

Reachable from entry: **yes**

## Imports

- `mlc/asm.ml` as `a` → [mlc/asm.ml](File-mlc-asm-ml-1368648960.md)
- `mlc/codegen/codegen_core.ml` as `core` → [mlc/codegen/codegen_core.ml](File-mlc-codegen-codegen-core-ml-528695596.md)
- `mlc/codegen/codegen_expr.ml` as `exprmod` → [mlc/codegen/codegen_expr.ml](File-mlc-codegen-codegen-expr-ml-59843844.md)
- `mlc/codegen/codegen_memory.ml` as `mem` → [mlc/codegen/codegen_memory.ml](File-mlc-codegen-codegen-memory-ml-2136639668.md)
- `mlc/codegen/codegen_scope.ml` as `scope` → [mlc/codegen/codegen_scope.ml](File-mlc-codegen-codegen-scope-ml-1124416197.md)
- `mlc/codegen/codegen_threads.ml` as `th` → [mlc/codegen/codegen_threads.ml](File-mlc-codegen-codegen-threads-ml-1261658982.md)
- `mlc/constants.ml` as `c` → [mlc/constants.ml](File-mlc-constants-ml-1024884042.md)
- `mlc/data.ml` as `d` → [mlc/data.ml](File-mlc-data-ml-557434521.md)
- `mlc/minilang_parser.ml` as `ml` → [mlc/minilang_parser.ml](File-mlc-minilang-parser-ml-1485036712.md)
- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)
- `std/string.ml` as `s` → `std/string.ml` — external dependency

## Declarations

<a id="function-function-mlc-codegen-codegen-stmt-all-function-entries-function-all-function-entries-state-mlc-codegen-codegen-stmt-ml-142948514"></a>
### _all_function_entries

```ml
function _all_function_entries(state)
```

Implements all function entries.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8486)

<a id="function-function-mlc-codegen-codegen-stmt-analysis-builtin-has-function-analysis-builtin-has-name-mlc-codegen-codegen-stmt-ml-1384222596"></a>
### _analysis_builtin_has

```ml
function _analysis_builtin_has(name)
```

Implements analysis builtin has.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5424)

<a id="function-function-mlc-codegen-codegen-stmt-analysis-call-args-function-analysis-call-args-ex-mlc-codegen-codegen-stmt-ml-1530729698"></a>
### _analysis_call_args

```ml
function _analysis_call_args(ex)
```

Implements analysis call args.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5406)

<a id="function-function-mlc-codegen-codegen-stmt-analysis-call-callee-function-analysis-call-callee-ex-mlc-codegen-codegen-stmt-ml-220972052"></a>
### _analysis_call_callee

```ml
function _analysis_call_callee(ex)
```

Implements analysis call callee.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5395)

<a id="function-function-mlc-codegen-codegen-stmt-analysis-for-end-expr-function-analysis-for-end-expr-st-mlc-codegen-codegen-stmt-ml-1858145608"></a>
### _analysis_for_end_expr

```ml
function _analysis_for_end_expr(st)
```

Implements analysis for end expr.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5415)

<a id="function-function-mlc-codegen-codegen-stmt-analysis-is-type-query-name-function-analysis-is-type-query-name-name-mlc-codegen-codegen-stmt-ml-277170088"></a>
### _analysis_is_type_query_name

```ml
function _analysis_is_type_query_name(name)
```

Implements analysis is type query name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5462)

<a id="function-function-mlc-codegen-codegen-stmt-analysis-known-callable-name-function-analysis-known-callable-name-state-name-mlc-codegen-codegen-stmt-ml-1512095307"></a>
### _analysis_known_callable_name

```ml
function _analysis_known_callable_name(state, name)
```

Implements analysis known callable name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5450)

<a id="function-function-mlc-codegen-codegen-stmt-analysis-mark-current-binding-boxed-function-analysis-mark-current-binding-boxed-state-name-mlc-codegen-codegen-stmt-ml-771418507"></a>
### _analysis_mark_current_binding_boxed

```ml
function _analysis_mark_current_binding_boxed(state, name)
```

Implements analysis mark current binding boxed.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5351)

<a id="function-function-mlc-codegen-codegen-stmt-analysis-member-target-function-analysis-member-target-ex-mlc-codegen-codegen-stmt-ml-729559442"></a>
### _analysis_member_target

```ml
function _analysis_member_target(ex)
```

Implements analysis member target.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5384)

<a id="function-function-mlc-codegen-codegen-stmt-analysis-prepare-function-function-analysis-prepare-function-state-fn-node-mlc-codegen-codegen-stmt-ml-1115148319"></a>
### _analysis_prepare_function

```ml
function _analysis_prepare_function(state, fn_node)
```

Implements analysis prepare function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `fn_node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5841)

<a id="function-function-mlc-codegen-codegen-stmt-analysis-register-fresh-local-decl-function-analysis-register-fresh-local-decl-state-decl-node-name-mlc-codegen-codegen-stmt-ml-1142350532"></a>
### _analysis_register_fresh_local_decl

```ml
function _analysis_register_fresh_local_decl(state, decl_node, name)
```

Implements analysis register fresh local decl.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `decl_node` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5337)

<a id="function-function-mlc-codegen-codegen-stmt-analysis-register-local-decl-function-analysis-register-local-decl-state-decl-node-name-mlc-codegen-codegen-stmt-ml-1545783478"></a>
### _analysis_register_local_decl

```ml
function _analysis_register_local_decl(state, decl_node, name)
```

Implements analysis register local decl.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `decl_node` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5306)

<a id="function-function-mlc-codegen-codegen-stmt-analysis-scan-block-function-analysis-scan-block-state-stmts-mlc-codegen-codegen-stmt-ml-1334106925"></a>
### _analysis_scan_block

```ml
function _analysis_scan_block(state, stmts)
```

Implements analysis scan block.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `stmts` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5829)

<a id="function-function-mlc-codegen-codegen-stmt-analysis-scan-expr-function-analysis-scan-expr-state-ex-allow-func-ident-mlc-codegen-codegen-stmt-ml-774877392"></a>
### _analysis_scan_expr

```ml
function _analysis_scan_expr(state, ex, allow_func_ident)
```

Implements analysis scan expr.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |
| `allow_func_ident` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5469)

<a id="function-function-mlc-codegen-codegen-stmt-analysis-scan-stmt-function-analysis-scan-stmt-state-st-mlc-codegen-codegen-stmt-ml-899640815"></a>
### _analysis_scan_stmt

```ml
function _analysis_scan_stmt(state, st)
```

Implements analysis scan stmt.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5639)

<a id="function-function-mlc-codegen-codegen-stmt-analyze-inline-only-functions-function-analyze-inline-only-functions-state-program-mlc-codegen-codegen-stmt-ml-2137680516"></a>
### _analyze_inline_only_functions

```ml
function _analyze_inline_only_functions(state, program)
```

Implements analyze inline only functions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `program` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4383)

<a id="function-function-mlc-codegen-codegen-stmt-arr-add-unique-inline-function-arr-add-unique-arr-value-mlc-codegen-codegen-stmt-ml-1668383150"></a>
### _arr_add_unique

```ml
inline function _arr_add_unique(arr, value)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4950)

<a id="function-function-mlc-codegen-codegen-stmt-arr-has-inline-function-arr-has-arr-value-mlc-codegen-codegen-stmt-ml-359581178"></a>
### _arr_has

```ml
inline function _arr_has(arr, value)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4940)

<a id="function-function-mlc-codegen-codegen-stmt-arr-remove-value-function-arr-remove-value-arr-value-mlc-codegen-codegen-stmt-ml-707931247"></a>
### _arr_remove_value

```ml
function _arr_remove_value(arr, value)
```

Implements arr remove value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4958)

<a id="function-function-mlc-codegen-codegen-stmt-arr-union-function-arr-union-a-b-mlc-codegen-codegen-stmt-ml-655469364"></a>
### _arr_union

```ml
function _arr_union(a, b)
```

Implements arr union.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4969)

<a id="function-function-mlc-codegen-codegen-stmt-as-name-inline-function-as-name-v-mlc-codegen-codegen-stmt-ml-1710050946"></a>
### _as_name

```ml
inline function _as_name(v)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L6937)

<a id="function-function-mlc-codegen-codegen-stmt-binding-global-label-function-binding-global-label-state-qname-mlc-codegen-codegen-stmt-ml-1926922966"></a>
### _binding_global_label

```ml
function _binding_global_label(state, qname)
```

Implements binding global label.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8190)

<a id="function-function-mlc-codegen-codegen-stmt-breakctx-break-depth-inline-function-breakctx-break-depth-ctx-fallback-mlc-codegen-codegen-stmt-ml-978797753"></a>
### _breakctx_break_depth

```ml
inline function _breakctx_break_depth(ctx, fallback)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ctx` | `dynamic` | — |  |
| `fallback` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L1146)

<a id="function-function-mlc-codegen-codegen-stmt-breakctx-break-label-inline-function-breakctx-break-label-ctx-mlc-codegen-codegen-stmt-ml-1712422467"></a>
### _breakctx_break_label

```ml
inline function _breakctx_break_label(ctx)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ctx` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L1126)

<a id="function-function-mlc-codegen-codegen-stmt-breakctx-continue-depth-inline-function-breakctx-continue-depth-ctx-fallback-mlc-codegen-codegen-stmt-ml-1088285325"></a>
### _breakctx_continue_depth

```ml
inline function _breakctx_continue_depth(ctx, fallback)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ctx` | `dynamic` | — |  |
| `fallback` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L1153)

<a id="function-function-mlc-codegen-codegen-stmt-breakctx-continue-label-inline-function-breakctx-continue-label-ctx-mlc-codegen-codegen-stmt-ml-549202169"></a>
### _breakctx_continue_label

```ml
inline function _breakctx_continue_label(ctx)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ctx` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L1136)

<a id="function-function-mlc-codegen-codegen-stmt-breakctx-kind-inline-function-breakctx-kind-ctx-mlc-codegen-codegen-stmt-ml-404657153"></a>
### _breakctx_kind

```ml
inline function _breakctx_kind(ctx)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ctx` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L1119)

<a id="function-function-mlc-codegen-codegen-stmt-breakctx-make-inline-function-breakctx-make-kind-break-label-continue-label-break-depth-continue-depth-mlc-codegen-codegen-stmt-ml-1478139546"></a>
### _breakctx_make

```ml
inline function _breakctx_make(kind, break_label, continue_label, break_depth, continue_depth)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — |  |
| `break_label` | `dynamic` | — |  |
| `continue_label` | `dynamic` | — |  |
| `break_depth` | `dynamic` | — |  |
| `continue_depth` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L1113)

<a id="function-function-mlc-codegen-codegen-stmt-breakstack-pop-function-breakstack-pop-state-mlc-codegen-codegen-stmt-ml-1353383254"></a>
### _breakstack_pop

```ml
function _breakstack_pop(state)
```

Implements breakstack pop.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L1160)

<a id="function-function-mlc-codegen-codegen-stmt-build-constexpr-env-function-build-constexpr-env-state-ex-mlc-codegen-codegen-stmt-ml-636233413"></a>
### _build_constexpr_env

```ml
function _build_constexpr_env(state, ex)
```

Creates build constexpr env.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L2960)

<a id="function-function-mlc-codegen-codegen-stmt-build-module-init-recs-function-build-module-init-recs-state-program-mlc-codegen-codegen-stmt-ml-689602694"></a>
### _build_module_init_recs

```ml
function _build_module_init_recs(state, program)
```

Creates build module init recs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `program` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8918)

<a id="function-function-mlc-codegen-codegen-stmt-builtin-code-label-for-name-function-builtin-code-label-for-name-state-name-mlc-codegen-codegen-stmt-ml-1336912939"></a>
### _builtin_code_label_for_name

```ml
function _builtin_code_label_for_name(state, name)
```

Implements builtin code label for name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8705)

<a id="function-function-mlc-codegen-codegen-stmt-builtin-specs-function-builtin-specs-mlc-codegen-codegen-stmt-ml-930177065"></a>
### _builtin_specs

```ml
function _builtin_specs()
```

Implements builtin specs.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8305)

<a id="function-function-mlc-codegen-codegen-stmt-check-expr-semantics-function-check-expr-semantics-state-ex-fn-arities-mlc-codegen-codegen-stmt-ml-1495781577"></a>
### _check_expr_semantics

```ml
function _check_expr_semantics(state, ex, fn_arities)
```

Implements check expr semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |
| `fn_arities` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L7881)

<a id="function-function-mlc-codegen-codegen-stmt-check-program-semantics-function-check-program-semantics-state-program-mlc-codegen-codegen-stmt-ml-2131531284"></a>
### _check_program_semantics

```ml
function _check_program_semantics(state, program)
```

Implements check program semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `program` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8179)

<a id="function-function-mlc-codegen-codegen-stmt-check-stmt-semantics-function-check-stmt-semantics-state-st-fn-arities-mlc-codegen-codegen-stmt-ml-1490398137"></a>
### _check_stmt_semantics

```ml
function _check_stmt_semantics(state, st, fn_arities)
```

Implements check stmt semantics.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `st` | `dynamic` | — |  |
| `fn_arities` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L7971)

<a id="function-function-mlc-codegen-codegen-stmt-chunked-len-function-chunked-len-chunks-tail-mlc-codegen-codegen-stmt-ml-363434457"></a>
### _chunked_len

```ml
function _chunked_len(chunks, tail)
```

Implements chunked len.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chunks` | `dynamic` | — |  |
| `tail` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L212)

<a id="function-function-mlc-codegen-codegen-stmt-clear-program-function-state-function-clear-program-function-state-state-mlc-codegen-codegen-stmt-ml-1190627538"></a>
### _clear_program_function_state

```ml
function _clear_program_function_state(state)
```

Releases or resets clear program function state.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8639)

<a id="function-function-mlc-codegen-codegen-stmt-clone-function-node-for-emit-function-clone-function-node-for-emit-fn-node-mlc-codegen-codegen-stmt-ml-2006114718"></a>
### _clone_function_node_for_emit

```ml
function _clone_function_node_for_emit(fn_node)
```

Implements clone function node for emit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fn_node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L531)

<a id="function-function-mlc-codegen-codegen-stmt-closure-analyze-function-function-closure-analyze-function-state-fn-node-mlc-codegen-codegen-stmt-ml-1085646639"></a>
### _closure_analyze_function

```ml
function _closure_analyze_function(state, fn_node)
```

Implements closure analyze function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `fn_node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L6726)

<a id="function-function-mlc-codegen-codegen-stmt-closure-analyze-function-rec-function-closure-analyze-function-rec-state-fn-node-outer-scopes-mlc-codegen-codegen-stmt-ml-1774134302"></a>
### _closure_analyze_function_rec

```ml
function _closure_analyze_function_rec(state, fn_node, outer_scopes)
```

Implements closure analyze function rec.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `fn_node` | `dynamic` | — |  |
| `outer_scopes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L6603)

<a id="function-function-mlc-codegen-codegen-stmt-closure-analyze-program-function-closure-analyze-program-state-program-mlc-codegen-codegen-stmt-ml-2024264772"></a>
### _closure_analyze_program

```ml
function _closure_analyze_program(state, program)
```

Implements closure analyze program.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `program` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L6733)

<a id="function-function-mlc-codegen-codegen-stmt-closure-assign-env-layout-function-closure-assign-env-layout-state-nested-fns-mlc-codegen-codegen-stmt-ml-725571093"></a>
### _closure_assign_env_layout

```ml
function _closure_assign_env_layout(state, nested_fns)
```

Implements closure assign env layout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `nested_fns` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L6806)

<a id="function-function-mlc-codegen-codegen-stmt-closure-collect-all-functions-function-closure-collect-all-functions-state-nested-fns-mlc-codegen-codegen-stmt-ml-1065698329"></a>
### _closure_collect_all_functions

```ml
function _closure_collect_all_functions(state, nested_fns)
```

Implements closure collect all functions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `nested_fns` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L6779)

<a id="function-function-mlc-codegen-codegen-stmt-closure-collect-locals-and-nested-function-closure-collect-locals-and-nested-fn-node-mlc-codegen-codegen-stmt-ml-731745426"></a>
### _closure_collect_locals_and_nested

```ml
function _closure_collect_locals_and_nested(fn_node)
```

Implements closure collect locals and nested.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fn_node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L6165)

<a id="function-function-mlc-codegen-codegen-stmt-closure-collect-locals-walk-function-closure-collect-locals-walk-stmts-locals-set-globals-decl-nested-mlc-codegen-codegen-stmt-ml-1396563895"></a>
### _closure_collect_locals_walk

```ml
function _closure_collect_locals_walk(stmts, locals_set, globals_decl, nested)
```

Implements closure collect locals walk.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stmts` | `dynamic` | — |  |
| `locals_set` | `dynamic` | — |  |
| `globals_decl` | `dynamic` | — |  |
| `nested` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L6051)

<a id="function-function-mlc-codegen-codegen-stmt-closure-collect-rbfw-walk-function-closure-collect-rbfw-walk-stmts-read-before-written-yet-mlc-codegen-codegen-stmt-ml-232031168"></a>
### _closure_collect_rbfw_walk

```ml
function _closure_collect_rbfw_walk(stmts, read_before, written_yet)
```

Implements closure collect rbfw walk.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stmts` | `dynamic` | — |  |
| `read_before` | `dynamic` | — |  |
| `written_yet` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L6398)

<a id="function-function-mlc-codegen-codegen-stmt-closure-collect-read-before-first-write-function-closure-collect-read-before-first-write-stmts-params-set-mlc-codegen-codegen-stmt-ml-1435465807"></a>
### _closure_collect_read_before_first_write

```ml
function _closure_collect_read_before_first_write(stmts, params_set)
```

Implements closure collect read before first write.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stmts` | `dynamic` | — |  |
| `params_set` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L6573)

<a id="function-function-mlc-codegen-codegen-stmt-closure-collect-uses-function-closure-collect-uses-stmts-mlc-codegen-codegen-stmt-ml-421357684"></a>
### _closure_collect_uses

```ml
function _closure_collect_uses(stmts)
```

Implements closure collect uses.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stmts` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L6186)

<a id="function-function-mlc-codegen-codegen-stmt-closure-collect-writes-function-closure-collect-writes-fn-node-mlc-codegen-codegen-stmt-ml-241843266"></a>
### _closure_collect_writes

```ml
function _closure_collect_writes(fn_node)
```

Implements closure collect writes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fn_node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L6311)

<a id="function-function-mlc-codegen-codegen-stmt-closure-declare-capture-bindings-function-closure-declare-capture-bindings-state-fn-node-mlc-codegen-codegen-stmt-ml-1321346537"></a>
### _closure_declare_capture_bindings

```ml
function _closure_declare_capture_bindings(state, fn_node)
```

Implements closure declare capture bindings.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `fn_node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L6943)

<a id="function-function-mlc-codegen-codegen-stmt-closure-expr-reads-function-closure-expr-reads-ex-used-mlc-codegen-codegen-stmt-ml-635722485"></a>
### _closure_expr_reads

```ml
function _closure_expr_reads(ex, used)
```

Implements closure expr reads.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |
| `used` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5969)

<a id="function-function-mlc-codegen-codegen-stmt-closure-owner-for-function-closure-owner-for-nf-depth-mlc-codegen-codegen-stmt-ml-721565674"></a>
### _closure_owner_for

```ml
function _closure_owner_for(nf, depth)
```

Implements closure owner for.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `nf` | `dynamic` | — |  |
| `depth` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L6589)

<a id="function-function-mlc-codegen-codegen-stmt-coerce-name-inline-function-coerce-name-v-mlc-codegen-codegen-stmt-ml-848807048"></a>
### _coerce_name

```ml
inline function _coerce_name(v)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L148)

<a id="function-function-mlc-codegen-codegen-stmt-collect-constexpr-refs-function-collect-constexpr-refs-ex-vals-mlc-codegen-codegen-stmt-ml-1024720348"></a>
### _collect_constexpr_refs

```ml
function _collect_constexpr_refs(ex, vals)
```

Implements collect constexpr refs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |
| `vals` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L2916)

<a id="function-function-mlc-codegen-codegen-stmt-collect-decls-function-collect-decls-program-mlc-codegen-codegen-stmt-ml-1547961433"></a>
### _collect_decls

```ml
function _collect_decls(program)
```

Implements collect decls.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4500)

<a id="function-function-mlc-codegen-codegen-stmt-collect-defer-sites-function-collect-defer-sites-state-fn-node-mlc-codegen-codegen-stmt-ml-1872785591"></a>
### _collect_defer_sites

```ml
function _collect_defer_sites(state, fn_node)
```

Implements collect defer sites.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `fn_node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L953)

<a id="function-function-mlc-codegen-codegen-stmt-collect-defer-walk-function-collect-defer-walk-state-stmts-in-loop-builder-count-mlc-codegen-codegen-stmt-ml-1036809617"></a>
### _collect_defer_walk

```ml
function _collect_defer_walk(state, stmts, in_loop, builder, count)
```

Implements collect defer walk.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `stmts` | `dynamic` | — |  |
| `in_loop` | `dynamic` | — |  |
| `builder` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L862)

<a id="function-function-mlc-codegen-codegen-stmt-collect-function-flow-inputs-function-collect-function-flow-inputs-fn-node-analysis-scratch-mlc-codegen-codegen-stmt-ml-397316837"></a>
### _collect_function_flow_inputs

```ml
function _collect_function_flow_inputs(fn_node, analysis_scratch)
```

Collect the statement facts shared by integer inference, value-type flow and local-register promotion in one deterministic traversal. These analyses used to repeat the same function-sized walk independently.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fn_node` | `dynamic` | — |  |
| `analysis_scratch` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3166)

<a id="function-function-mlc-codegen-codegen-stmt-collect-program-decls-function-collect-program-decls-state-stmts-prefix-current-file-file-prefixes-file-seen-nonpackage-next-sid-next-eid-in-ns-mlc-codegen-codegen-stmt-ml-124981865"></a>
### _collect_program_decls

```ml
function _collect_program_decls(state, stmts, prefix, current_file, file_prefixes, file_seen_nonpackage, next_sid, next_eid, in_ns)
```

Collect declarations before emission so package qualification, stable IDs and module initialization order agree with the Python reference frontend.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `stmts` | `dynamic` | — |  |
| `prefix` | `dynamic` | — |  |
| `current_file` | `dynamic` | — |  |
| `file_prefixes` | `dynamic` | — |  |
| `file_seen_nonpackage` | `dynamic` | — |  |
| `next_sid` | `dynamic` | — |  |
| `next_eid` | `dynamic` | — |  |
| `in_ns` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L7456)

<a id="function-function-mlc-codegen-codegen-stmt-copy-fn-array-field-function-copy-fn-array-field-v-mlc-codegen-codegen-stmt-ml-354764291"></a>
### _copy_fn_array_field

```ml
function _copy_fn_array_field(v)
```

Implements copy fn array field.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L516)

<a id="function-function-mlc-codegen-codegen-stmt-copy-fn-map-or-array-field-function-copy-fn-map-or-array-field-v-mlc-codegen-codegen-stmt-ml-192376733"></a>
### _copy_fn_map_or_array_field

```ml
function _copy_fn_map_or_array_field(v)
```

Implements copy fn map or array field.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L523)

<a id="function-function-mlc-codegen-codegen-stmt-decl-st-file-inline-function-decl-st-file-st-mlc-codegen-codegen-stmt-ml-1558153623"></a>
### _decl_st_file

```ml
inline function _decl_st_file(st)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L2846)

<a id="function-function-mlc-codegen-codegen-stmt-declare-object-top-level-global-bindings-function-declare-object-top-level-global-bindings-state-program-mlc-codegen-codegen-stmt-ml-368111222"></a>
### _declare_object_top_level_global_bindings

```ml
function _declare_object_top_level_global_bindings(state, program)
```

Implements declare object top level global bindings.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `program` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8232)

<a id="function-function-mlc-codegen-codegen-stmt-declare-top-level-global-bindings-function-declare-top-level-global-bindings-state-program-mlc-codegen-codegen-stmt-ml-1166872260"></a>
### _declare_top_level_global_bindings

```ml
function _declare_top_level_global_bindings(state, program)
```

Implements declare top level global bindings.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `program` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8210)

<a id="function-function-mlc-codegen-codegen-stmt-defer-capture-node-function-defer-capture-node-stmt-off-mlc-codegen-codegen-stmt-ml-1024801718"></a>
### _defer_capture_node

```ml
function _defer_capture_node(stmt, off)
```

Implements defer capture node.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stmt` | `dynamic` | — |  |
| `off` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L1012)

<a id="function-function-mlc-codegen-codegen-stmt-defer-replay-call-function-defer-replay-call-stmt-mlc-codegen-codegen-stmt-ml-9829135"></a>
### _defer_replay_call

```ml
function _defer_replay_call(stmt)
```

Implements defer replay call.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stmt` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L1018)

<a id="function-function-mlc-codegen-codegen-stmt-defer-static-callee-function-defer-static-callee-state-callee-mlc-codegen-codegen-stmt-ml-538336832"></a>
### _defer_static_callee

```ml
function _defer_static_callee(state, callee)
```

Implements defer static callee.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `callee` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L961)

<a id="function-function-mlc-codegen-codegen-stmt-diag-stmt-loc-function-diag-stmt-loc-st-mlc-codegen-codegen-stmt-ml-705800340"></a>
### _diag_stmt_loc

```ml
function _diag_stmt_loc(st)
```

Implements diag stmt loc.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L315)

<a id="function-function-mlc-codegen-codegen-stmt-dotted-name-inline-function-dotted-name-parts-mlc-codegen-codegen-stmt-ml-1631006126"></a>
### _dotted_name

```ml
inline function _dotted_name(parts)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parts` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L2852)

<a id="function-function-mlc-codegen-codegen-stmt-dotted-name-expr-function-dotted-name-expr-ex-mlc-codegen-codegen-stmt-ml-803823796"></a>
### _dotted_name_expr

```ml
function _dotted_name_expr(ex)
```

Implements dotted name expr.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L1399)

<a id="function-function-mlc-codegen-codegen-stmt-emit-condition-false-jump-function-emit-condition-false-jump-state-cond-expr-false-label-mlc-codegen-codegen-stmt-ml-1903303146"></a>
### _emit_condition_false_jump

```ml
function _emit_condition_false_jump(state, cond_expr, false_label)
```

Runs emit condition false jump.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `cond_expr` | `dynamic` | — |  |
| `false_label` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L790)

<a id="function-function-mlc-codegen-codegen-stmt-emit-condition-nonvoid-guard-function-emit-condition-nonvoid-guard-state-cond-expr-ok-label-false-label-mlc-codegen-codegen-stmt-ml-97600581"></a>
### _emit_condition_nonvoid_guard

```ml
function _emit_condition_nonvoid_guard(state, cond_expr, ok_label, false_label)
```

Runs emit condition nonvoid guard.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `cond_expr` | `dynamic` | — |  |
| `ok_label` | `dynamic` | — |  |
| `false_label` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L774)

<a id="function-function-mlc-codegen-codegen-stmt-emit-defer-cleanup-function-emit-defer-cleanup-state-sites-ret-off-mlc-codegen-codegen-stmt-ml-2042407121"></a>
### _emit_defer_cleanup

```ml
function _emit_defer_cleanup(state, sites, ret_off)
```

Runs emit defer cleanup.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `sites` | `dynamic` | — |  |
| `ret_off` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L1038)

<a id="function-function-mlc-codegen-codegen-stmt-emit-defer-registration-function-emit-defer-registration-state-stmt-mlc-codegen-codegen-stmt-ml-1625606816"></a>
### _emit_defer_registration

```ml
function _emit_defer_registration(state, stmt)
```

Runs emit defer registration.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `stmt` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L977)

<a id="function-function-mlc-codegen-codegen-stmt-emit-program-functions-all-function-emit-program-functions-all-state-mlc-codegen-codegen-stmt-ml-117873376"></a>
### _emit_program_functions_all

```ml
function _emit_program_functions_all(state)
```

Runs emit program functions all.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8589)

<a id="function-function-mlc-codegen-codegen-stmt-emit-program-module-inits-all-function-emit-program-module-inits-all-state-module-init-recs-mlc-codegen-codegen-stmt-ml-863515727"></a>
### _emit_program_module_inits_all

```ml
function _emit_program_module_inits_all(state, module_init_recs)
```

Runs emit program module inits all.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `module_init_recs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8575)

<a id="function-function-mlc-codegen-codegen-stmt-emit-program-via-objects-function-emit-program-via-objects-state-program-mlc-codegen-codegen-stmt-ml-981202462"></a>
### _emit_program_via_objects

```ml
function _emit_program_via_objects(state, program)
```

Runs emit program via objects.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `program` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8652)

<a id="function-function-mlc-codegen-codegen-stmt-emit-static-callable-objects-function-emit-static-callable-objects-state-mlc-codegen-codegen-stmt-ml-1628342340"></a>
### _emit_static_callable_objects

```ml
function _emit_static_callable_objects(state)
```

Runs emit static callable objects.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8744)

<a id="function-function-mlc-codegen-codegen-stmt-emit-static-global-slot-initializers-from-globals-function-emit-static-global-slot-initializers-from-globals-state-mlc-codegen-codegen-stmt-ml-1041849202"></a>
### _emit_static_global_slot_initializers_from_globals

```ml
function _emit_static_global_slot_initializers_from_globals(state)
```

Runs emit static global slot initializers from globals.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8721)

<a id="function-function-mlc-codegen-codegen-stmt-emit-stmt-list-function-emit-stmt-list-state-stmt-seq-emit-mlc-codegen-codegen-stmt-ml-909361712"></a>
### _emit_stmt_list

```ml
function _emit_stmt_list(state, stmt_seq_emit)
```

Runs emit stmt list.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `stmt_seq_emit` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L614)

<a id="function-function-mlc-codegen-codegen-stmt-emit-struct-field-index-dispatch-local-function-emit-struct-field-index-dispatch-local-state-field-struct-id-reg-out-reg-ok-label-fail-label-tag-mlc-codegen-codegen-stmt-ml-361373593"></a>
### _emit_struct_field_index_dispatch_local

```ml
function _emit_struct_field_index_dispatch_local(state, field, struct_id_reg, out_reg, ok_label, fail_label, tag)
```

Runs emit struct field index dispatch local.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `field` | `dynamic` | — |  |
| `struct_id_reg` | `dynamic` | — |  |
| `out_reg` | `dynamic` | — |  |
| `ok_label` | `dynamic` | — |  |
| `fail_label` | `dynamic` | — |  |
| `tag` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L1416)

<a id="function-function-mlc-codegen-codegen-stmt-emit-switch-stmt-function-emit-switch-stmt-state-stmt-mlc-codegen-codegen-stmt-ml-1805871756"></a>
### _emit_switch_stmt

```ml
function _emit_switch_stmt(state, stmt)
```

Runs emit switch stmt.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `stmt` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L1176)

<a id="function-function-mlc-codegen-codegen-stmt-ensure-global-binding-label-function-ensure-global-binding-label-state-qname-decl-node-mlc-codegen-codegen-stmt-ml-1483960385"></a>
### _ensure_global_binding_label

```ml
function _ensure_global_binding_label(state, qname, decl_node)
```

Implements ensure global binding label.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |
| `decl_node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8200)

<a id="function-function-mlc-codegen-codegen-stmt-eval-constexpr-function-eval-constexpr-state-ex-env-mlc-codegen-codegen-stmt-ml-1797563284"></a>
### _eval_constexpr

```ml
function _eval_constexpr(state, ex, env)
```

Implements eval constexpr.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |
| `env` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L2976)

<a id="function-function-mlc-codegen-codegen-stmt-expr-to-qualname-function-expr-to-qualname-state-ex-mlc-codegen-codegen-stmt-ml-1076155755"></a>
### _expr_to_qualname

```ml
function _expr_to_qualname(state, ex)
```

Implements expr to qualname.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L2873)

<a id="function-function-mlc-codegen-codegen-stmt-expr-uses-native-threads-function-expr-uses-native-threads-ex-mlc-codegen-codegen-stmt-ml-206341088"></a>
### _expr_uses_native_threads

```ml
function _expr_uses_native_threads(ex)
```

Implements expr uses native threads.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8964)

<a id="function-function-mlc-codegen-codegen-stmt-expr-uses-this-function-expr-uses-this-ex-mlc-codegen-codegen-stmt-ml-81408054"></a>
### _expr_uses_this

```ml
function _expr_uses_this(ex)
```

Implements expr uses this.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L7059)

<a id="function-function-mlc-codegen-codegen-stmt-fast-index-scan-expr-function-fast-index-scan-expr-ex-index-name-targets-mlc-codegen-codegen-stmt-ml-147632448"></a>
### _fast_index_scan_expr

```ml
function _fast_index_scan_expr(ex, index_name, targets)
```

Implements fast index scan expr.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |
| `index_name` | `dynamic` | — |  |
| `targets` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4000)

<a id="function-function-mlc-codegen-codegen-stmt-fast-index-scan-loop-function-fast-index-scan-loop-loop-node-index-name-mlc-codegen-codegen-stmt-ml-886051400"></a>
### _fast_index_scan_loop

```ml
function _fast_index_scan_loop(loop_node, index_name)
```

Implements fast index scan loop.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `loop_node` | `dynamic` | — |  |
| `index_name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4027)

<a id="function-function-mlc-codegen-codegen-stmt-fast-target-add-function-fast-target-add-items-name-expr-mlc-codegen-codegen-stmt-ml-549244681"></a>
### _fast_target_add

```ml
function _fast_target_add(items, name, expr)
```

Implements fast target add.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3991)

<a id="function-function-mlc-codegen-codegen-stmt-flatten-member-chain-function-flatten-member-chain-state-ex-mlc-codegen-codegen-stmt-ml-916530405"></a>
### _flatten_member_chain

```ml
function _flatten_member_chain(state, ex)
```

Implements flatten member chain.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L2879)

<a id="function-function-mlc-codegen-codegen-stmt-flatten-runtime-function-flatten-runtime-state-value-mlc-codegen-codegen-stmt-ml-1300938143"></a>
### _flatten_runtime

```ml
function _flatten_runtime(state, value)
```

Implements flatten runtime.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4910)

<a id="function-function-mlc-codegen-codegen-stmt-flatten-runtime-inner-function-flatten-runtime-inner-state-stmts-prefix-current-file-mlc-codegen-codegen-stmt-ml-1587557733"></a>
### _flatten_runtime_inner

```ml
function _flatten_runtime_inner(state, stmts, prefix, current_file)
```

Implements flatten runtime inner.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `stmts` | `dynamic` | — |  |
| `prefix` | `dynamic` | — |  |
| `current_file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4796)

<a id="function-function-mlc-codegen-codegen-stmt-fn-arity-map-function-fn-arity-map-state-mlc-codegen-codegen-stmt-ml-381953794"></a>
### _fn_arity_map

```ml
function _fn_arity_map(state)
```

Implements fn arity map.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L7843)

<a id="function-function-mlc-codegen-codegen-stmt-fn-codegen-key-inline-function-fn-codegen-key-fn-node-mlc-codegen-codegen-stmt-ml-448184147"></a>
### _fn_codegen_key

```ml
inline function _fn_codegen_key(fn_node)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fn_node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L164)

<a id="function-function-mlc-codegen-codegen-stmt-fn-codegen-name-inline-function-fn-codegen-name-state-fn-node-mlc-codegen-codegen-stmt-ml-176705580"></a>
### _fn_codegen_name

```ml
inline function _fn_codegen_name(state, fn_node)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `fn_node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L175)

<a id="function-function-mlc-codegen-codegen-stmt-for-end-proves-index-bounds-function-for-end-proves-index-bounds-state-loop-node-target-name-exact-len-start-value-mlc-codegen-codegen-stmt-ml-643445787"></a>
### _for_end_proves_index_bounds

```ml
function _for_end_proves_index_bounds(state, loop_node, target_name, exact_len, start_value)
```

Implements for end proves index bounds.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `loop_node` | `dynamic` | — |  |
| `target_name` | `dynamic` | — |  |
| `exact_len` | `dynamic` | — |  |
| `start_value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4063)

<a id="function-function-mlc-codegen-codegen-stmt-for-index-hoist-plans-function-for-index-hoist-plans-state-loop-node-index-binding-mlc-codegen-codegen-stmt-ml-877679523"></a>
### _for_index_hoist_plans

```ml
function _for_index_hoist_plans(state, loop_node, index_binding)
```

Implements for index hoist plans.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `loop_node` | `dynamic` | — |  |
| `index_binding` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4081)

<a id="function-function-mlc-codegen-codegen-stmt-for-state-names-function-for-state-names-st-mlc-codegen-codegen-stmt-ml-783394484"></a>
### _for_state_names

```ml
function _for_state_names(st)
```

Implements for state names.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3054)

<a id="function-function-mlc-codegen-codegen-stmt-for-unroll-body-ok-function-for-unroll-body-ok-stmts-loop-var-mlc-codegen-codegen-stmt-ml-674583386"></a>
### _for_unroll_body_ok

```ml
function _for_unroll_body_ok(stmts, loop_var)
```

Implements for unroll body ok.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stmts` | `dynamic` | — |  |
| `loop_var` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L731)

<a id="function-function-mlc-codegen-codegen-stmt-for-unroll-body-ok-budget-function-for-unroll-body-ok-budget-stmts-loop-var-budget-mlc-codegen-codegen-stmt-ml-1024577895"></a>
### _for_unroll_body_ok_budget

```ml
function _for_unroll_body_ok_budget(stmts, loop_var, budget)
```

Implements for unroll body ok budget.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stmts` | `dynamic` | — |  |
| `loop_var` | `dynamic` | — |  |
| `budget` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L693)

<a id="function-function-mlc-codegen-codegen-stmt-for-unroll-budget-take-function-for-unroll-budget-take-budget-mlc-codegen-codegen-stmt-ml-168957252"></a>
### _for_unroll_budget_take

```ml
function _for_unroll_budget_take(budget)
```

Implements for unroll budget take.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `budget` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L649)

<a id="function-function-mlc-codegen-codegen-stmt-for-unroll-expr-child-ok-function-for-unroll-expr-child-ok-child-budget-mlc-codegen-codegen-stmt-ml-1470564306"></a>
### _for_unroll_expr_child_ok

```ml
function _for_unroll_expr_child_ok(child, budget)
```

Walk expression children only to enforce the same conservative shared complexity budget as the reference compiler; this is not a semantic filter.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `dynamic` | — |  |
| `budget` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L657)

<a id="function-function-mlc-codegen-codegen-stmt-for-unroll-expr-ok-function-for-unroll-expr-ok-expr-budget-mlc-codegen-codegen-stmt-ml-1099314987"></a>
### _for_unroll_expr_ok

```ml
function _for_unroll_expr_ok(expr, budget)
```

Implements for unroll expr ok.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expr` | `dynamic` | — |  |
| `budget` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L672)

<a id="function-function-mlc-codegen-codegen-stmt-for-unroll-values-function-for-unroll-values-state-s-mlc-codegen-codegen-stmt-ml-2038202727"></a>
### _for_unroll_values

```ml
function _for_unroll_values(state, s)
```

Implements for unroll values.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `s` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L737)

<a id="function-function-mlc-codegen-codegen-stmt-foreach-body-inline-function-foreach-body-st-mlc-codegen-codegen-stmt-ml-874591791"></a>
### _foreach_body

```ml
inline function _foreach_body(st)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L603)

<a id="function-function-mlc-codegen-codegen-stmt-foreach-load-dword-eax-function-foreach-load-dword-eax-state-name-mlc-codegen-codegen-stmt-ml-1807123531"></a>
### _foreach_load_dword_eax

```ml
function _foreach_load_dword_eax(state, name)
```

Implements foreach load dword eax.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L1098)

<a id="function-function-mlc-codegen-codegen-stmt-foreach-state-names-function-foreach-state-names-st-mlc-codegen-codegen-stmt-ml-887966688"></a>
### _foreach_state_names

```ml
function _foreach_state_names(st)
```

Implements foreach state names.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3031)

<a id="function-function-mlc-codegen-codegen-stmt-foreach-store-dword-eax-function-foreach-store-dword-eax-state-name-mlc-codegen-codegen-stmt-ml-141710227"></a>
### _foreach_store_dword_eax

```ml
function _foreach_store_dword_eax(state, name)
```

Implements foreach store dword eax.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L1083)

<a id="function-function-mlc-codegen-codegen-stmt-foreach-var-name-function-foreach-var-name-st-mlc-codegen-codegen-stmt-ml-2036267774"></a>
### _foreach_var_name

```ml
function _foreach_var_name(st)
```

Implements foreach var name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3025)

<a id="function-function-mlc-codegen-codegen-stmt-forget-nested-function-by-codegen-name-function-forget-nested-function-by-codegen-name-state-code-name-mlc-codegen-codegen-stmt-ml-556689205"></a>
### _forget_nested_function_by_codegen_name

```ml
function _forget_nested_function_by_codegen_name(state, code_name)
```

Implements forget nested function by codegen name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `code_name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L567)

<a id="function-function-mlc-codegen-codegen-stmt-func-global-mapped-name-function-func-global-mapped-name-state-name-mlc-codegen-codegen-stmt-ml-1309857527"></a>
### _func_global_mapped_name

```ml
function _func_global_mapped_name(state, name)
```

Implements func global mapped name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5216)

<a id="function-function-mlc-codegen-codegen-stmt-group-program-by-file-function-group-program-by-file-program-mlc-codegen-codegen-stmt-ml-619418709"></a>
### _group_program_by_file

```ml
function _group_program_by_file(program)
```

Implements group program by file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4916)

<a id="function-function-mlc-codegen-codegen-stmt-has-dot-name-inline-function-has-dot-name-name-mlc-codegen-codegen-stmt-ml-571851239"></a>
### _has_dot_name

```ml
inline function _has_dot_name(name)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L7402)

<a id="function-function-mlc-codegen-codegen-stmt-has-reserved-segment-function-has-reserved-segment-state-name-mlc-codegen-codegen-stmt-ml-1563784123"></a>
### _has_reserved_segment

```ml
function _has_reserved_segment(state, name)
```

Reports whether has reserved segment.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4483)

<a id="function-function-mlc-codegen-codegen-stmt-heap-cfg-get-any-function-heap-cfg-get-any-state-key-mlc-codegen-codegen-stmt-ml-1697445733"></a>
### _heap_cfg_get_any

```ml
function _heap_cfg_get_any(state, key)
```

Implements heap cfg get any.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L226)

<a id="function-function-mlc-codegen-codegen-stmt-heap-cfg-get-bool-inline-function-heap-cfg-get-bool-state-key-defaultv-mlc-codegen-codegen-stmt-ml-358808291"></a>
### _heap_cfg_get_bool

```ml
inline function _heap_cfg_get_bool(state, key, defaultv)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L252)

<a id="function-function-mlc-codegen-codegen-stmt-heap-cfg-get-int-inline-function-heap-cfg-get-int-state-key-defaultv-mlc-codegen-codegen-stmt-ml-524944701"></a>
### _heap_cfg_get_int

```ml
inline function _heap_cfg_get_int(state, key, defaultv)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L244)

<a id="function-function-mlc-codegen-codegen-stmt-id-label-pair-id-function-id-label-pair-id-it-mlc-codegen-codegen-stmt-ml-708505754"></a>
### _id_label_pair_id

```ml
function _id_label_pair_id(it)
```

Implements id label pair id.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `it` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5233)

<a id="function-function-mlc-codegen-codegen-stmt-infer-known-int-names-function-infer-known-int-names-state-fn-node-flow-inputs-analysis-scratch-mlc-codegen-codegen-stmt-ml-2121391122"></a>
### _infer_known_int_names

```ml
function _infer_known_int_names(state, fn_node, flow_inputs, analysis_scratch)
```

Implements infer known int names.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `fn_node` | `dynamic` | — |  |
| `flow_inputs` | `dynamic` | — |  |
| `analysis_scratch` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3331)

<a id="function-function-mlc-codegen-codegen-stmt-infer-known-value-types-function-infer-known-value-types-state-fn-node-flow-inputs-analysis-scratch-mlc-codegen-codegen-stmt-ml-1006887738"></a>
### _infer_known_value_types

```ml
function _infer_known_value_types(state, fn_node, flow_inputs, analysis_scratch)
```

Implements infer known value types.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `fn_node` | `dynamic` | — |  |
| `flow_inputs` | `dynamic` | — |  |
| `analysis_scratch` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3763)

<a id="function-function-mlc-codegen-codegen-stmt-inline-ref-resolve-function-inline-ref-resolve-state-ex-owner-inline-names-mlc-codegen-codegen-stmt-ml-326035508"></a>
### _inline_ref_resolve

```ml
function _inline_ref_resolve(state, ex, owner, inline_names)
```

Implements inline ref resolve.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |
| `owner` | `dynamic` | — |  |
| `inline_names` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4235)

<a id="function-function-mlc-codegen-codegen-stmt-inline-scan-expr-uses-function-inline-scan-expr-uses-state-ex-owner-inline-names-address-taken-mlc-codegen-codegen-stmt-ml-2070699308"></a>
### _inline_scan_expr_uses

```ml
function _inline_scan_expr_uses(state, ex, owner, inline_names, address_taken)
```

Implements inline scan expr uses.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |
| `owner` | `dynamic` | — |  |
| `inline_names` | `dynamic` | — |  |
| `address_taken` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4270)

<a id="function-function-mlc-codegen-codegen-stmt-inline-scan-stmt-uses-function-inline-scan-stmt-uses-state-stmts-owner-inline-names-address-taken-mlc-codegen-codegen-stmt-ml-1795646560"></a>
### _inline_scan_stmt_uses

```ml
function _inline_scan_stmt_uses(state, stmts, owner, inline_names, address_taken)
```

Implements inline scan stmt uses.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `stmts` | `dynamic` | — |  |
| `owner` | `dynamic` | — |  |
| `inline_names` | `dynamic` | — |  |
| `address_taken` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4323)

<a id="function-function-mlc-codegen-codegen-stmt-intflow-const-int-function-intflow-const-int-state-ex-mlc-codegen-codegen-stmt-ml-403860833"></a>
### _intflow_const_int

```ml
function _intflow_const_int(state, ex)
```

Implements intflow const int.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3116)

<a id="function-function-mlc-codegen-codegen-stmt-intflow-expr-is-int-function-intflow-expr-is-int-state-ex-known-mlc-codegen-codegen-stmt-ml-392181256"></a>
### _intflow_expr_is_int

```ml
function _intflow_expr_is_int(state, ex, known)
```

Implements intflow expr is int.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |
| `known` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3127)

<a id="function-function-mlc-codegen-codegen-stmt-intflow-map-add-function-intflow-map-add-items-name-value-mlc-codegen-codegen-stmt-ml-623942249"></a>
### _intflow_map_add

```ml
function _intflow_map_add(items, name, value)
```

Implements intflow map add.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3082)

<a id="function-function-mlc-codegen-codegen-stmt-intflow-map-get-function-intflow-map-get-items-name-mlc-codegen-codegen-stmt-ml-1348486260"></a>
### _intflow_map_get

```ml
function _intflow_map_get(items, name)
```

Implements intflow map get.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3102)

<a id="function-function-mlc-codegen-codegen-stmt-is-constexpr-binary-function-is-constexpr-binary-op-mlc-codegen-codegen-stmt-ml-472368092"></a>
### _is_constexpr_binary

```ml
function _is_constexpr_binary(op)
```

Reports whether is constexpr binary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `op` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L2891)

<a id="function-function-mlc-codegen-codegen-stmt-is-constexpr-expr-function-is-constexpr-expr-state-ex-mlc-codegen-codegen-stmt-ml-1671617385"></a>
### _is_constexpr_expr

```ml
function _is_constexpr_expr(state, ex)
```

Reports whether is constexpr expr.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L2897)

<a id="function-function-mlc-codegen-codegen-stmt-is-constexpr-unary-function-is-constexpr-unary-op-mlc-codegen-codegen-stmt-ml-114885716"></a>
### _is_constexpr_unary

```ml
function _is_constexpr_unary(op)
```

Reports whether is constexpr unary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `op` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L2885)

<a id="function-function-mlc-codegen-codegen-stmt-is-foreach-stmt-function-is-foreach-stmt-st-mlc-codegen-codegen-stmt-ml-100590924"></a>
### _is_foreach_stmt

```ml
function _is_foreach_stmt(st)
```

Reports whether is foreach stmt.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3014)

<a id="function-function-mlc-codegen-codegen-stmt-is-node-inline-function-is-node-n-kind-mlc-codegen-codegen-stmt-ml-1691255182"></a>
### _is_node

```ml
inline function _is_node(n, kind)
```

Compatibility wrappers (Python CodegenStmt parity).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `n` | `dynamic` | — |  |
| `kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L2832)

<a id="function-function-mlc-codegen-codegen-stmt-is-stmt-inline-function-is-stmt-st-mlc-codegen-codegen-stmt-ml-790898425"></a>
### _is_stmt

```ml
inline function _is_stmt(st)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L2840)

<a id="function-function-mlc-codegen-codegen-stmt-join-qname-inline-function-join-qname-prefix-name-mlc-codegen-codegen-stmt-ml-1575961299"></a>
### _join_qname

```ml
inline function _join_qname(prefix, name)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `prefix` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L138)

<a id="function-function-mlc-codegen-codegen-stmt-map-int-get-inline-function-map-int-get-arr-key-defaultv-mlc-codegen-codegen-stmt-ml-780366809"></a>
### _map_int_get

```ml
inline function _map_int_get(arr, key, defaultv)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5079)

<a id="function-function-mlc-codegen-codegen-stmt-map-int-items-function-map-int-items-arr-mlc-codegen-codegen-stmt-ml-1842411288"></a>
### _map_int_items

```ml
function _map_int_items(arr)
```

Implements map int items.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5119)

<a id="function-function-mlc-codegen-codegen-stmt-map-int-set-function-map-int-set-arr-key-value-mlc-codegen-codegen-stmt-ml-40779000"></a>
### _map_int_set

```ml
function _map_int_set(arr, key, value)
```

Implements map int set.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5102)

<a id="function-function-mlc-codegen-codegen-stmt-max-calls-int-inline-function-max-calls-int-a-b-mlc-codegen-codegen-stmt-ml-1266126363"></a>
### _max_calls_int

```ml
inline function _max_calls_int(a, b)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L10555)

<a id="function-function-mlc-codegen-codegen-stmt-maybe-phase-gc-function-maybe-phase-gc-state-tag-min-bytes-mlc-codegen-codegen-stmt-ml-69525466"></a>
### _maybe_phase_gc

```ml
function _maybe_phase_gc(state, tag, min_bytes)
```

Implements maybe phase gc.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `tag` | `dynamic` | — |  |
| `min_bytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L584)

<a id="function-function-mlc-codegen-codegen-stmt-mem-probe-function-mem-probe-state-tag-mlc-codegen-codegen-stmt-ml-407291560"></a>
### _mem_probe

```ml
function _mem_probe(state, tag)
```

Implements mem probe.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `tag` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L201)

<a id="function-function-mlc-codegen-codegen-stmt-member-chain-name-function-member-chain-name-ex-mlc-codegen-codegen-stmt-ml-537776470"></a>
### _member_chain_name

```ml
function _member_chain_name(ex)
```

Implements member chain name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L7865)

<a id="function-function-mlc-codegen-codegen-stmt-member-qname-function-member-qname-ex-mlc-codegen-codegen-stmt-ml-1970389606"></a>
### _member_qname

```ml
function _member_qname(ex)
```

Implements member qname.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L2860)

<a id="function-function-mlc-codegen-codegen-stmt-module-file-eq-function-module-file-eq-a-b-mlc-codegen-codegen-stmt-ml-346527106"></a>
### _module_file_eq

```ml
function _module_file_eq(a, b)
```

Implements module file eq.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L9482)

<a id="global-global-mlc-codegen-codegen-stmt-module-function-entry-index-module-function-entry-index-mlc-codegen-codegen-stmt-ml-151888231"></a>
### _module_function_entry_index

```ml
_module_function_entry_index
```

Stores the module function entry index compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L41)

<a id="function-function-mlc-codegen-codegen-stmt-module-function-entry-index-add-function-module-function-entry-index-add-index-module-file-entry-mlc-codegen-codegen-stmt-ml-210430926"></a>
### _module_function_entry_index_add

```ml
function _module_function_entry_index_add(index, module_file, entry)
```

Implements module function entry index add.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `dynamic` | — |  |
| `module_file` | `dynamic` | — |  |
| `entry` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L9660)

<a id="function-function-mlc-codegen-codegen-stmt-name-set-add-function-name-set-add-setv-value-mlc-codegen-codegen-stmt-ml-811645358"></a>
### _name_set_add

```ml
function _name_set_add(setv, value)
```

Implements name set add.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `setv` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5027)

<a id="function-function-mlc-codegen-codegen-stmt-name-set-has-inline-function-name-set-has-setv-value-mlc-codegen-codegen-stmt-ml-925243813"></a>
### _name_set_has

```ml
inline function _name_set_has(setv, value)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `setv` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5019)

<a id="function-function-mlc-codegen-codegen-stmt-name-set-new-inline-function-name-set-new-initial-cap-mlc-codegen-codegen-stmt-ml-992272905"></a>
### _name_set_new

```ml
inline function _name_set_new(initial_cap)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `initial_cap` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4986)

<a id="function-function-mlc-codegen-codegen-stmt-name-set-remove-function-name-set-remove-setv-value-mlc-codegen-codegen-stmt-ml-1189746524"></a>
### _name_set_remove

```ml
function _name_set_remove(setv, value)
```

Implements name set remove.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `setv` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5039)

<a id="function-function-mlc-codegen-codegen-stmt-name-set-size-inline-function-name-set-size-setv-mlc-codegen-codegen-stmt-ml-632527980"></a>
### _name_set_size

```ml
inline function _name_set_size(setv)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `setv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4992)

<a id="function-function-mlc-codegen-codegen-stmt-name-set-to-array-function-name-set-to-array-setv-mlc-codegen-codegen-stmt-ml-596527571"></a>
### _name_set_to_array

```ml
function _name_set_to_array(setv)
```

Implements name set to array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `setv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5000)

<a id="function-function-mlc-codegen-codegen-stmt-name-set-union-function-name-set-union-a-b-mlc-codegen-codegen-stmt-ml-602953826"></a>
### _name_set_union

```ml
function _name_set_union(a, b)
```

Implements name set union.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5059)

<a id="function-function-mlc-codegen-codegen-stmt-named-array-get-inline-function-named-array-get-arr-key-mlc-codegen-codegen-stmt-ml-1584479416"></a>
### _named_array_get

```ml
inline function _named_array_get(arr, key)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L7282)

<a id="function-function-mlc-codegen-codegen-stmt-named-array-set-function-named-array-set-arr-key-values-mlc-codegen-codegen-stmt-ml-2133321669"></a>
### _named_array_set

```ml
function _named_array_set(arr, key, values)
```

Implements named array set.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `values` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L7299)

<a id="function-function-mlc-codegen-codegen-stmt-named-int-get-inline-function-named-int-get-arr-key-defaultv-mlc-codegen-codegen-stmt-ml-1986657559"></a>
### _named_int_get

```ml
inline function _named_int_get(arr, key, defaultv)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L7320)

<a id="function-function-mlc-codegen-codegen-stmt-named-int-set-function-named-int-set-arr-key-value-mlc-codegen-codegen-stmt-ml-704466436"></a>
### _named_int_set

```ml
function _named_int_set(arr, key, value)
```

Implements named int set.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L7343)

<a id="function-function-mlc-codegen-codegen-stmt-nested-function-codegen-names-sorted-function-nested-function-codegen-names-sorted-state-mlc-codegen-codegen-stmt-ml-1868487122"></a>
### _nested_function_codegen_names_sorted

```ml
function _nested_function_codegen_names_sorted(state)
```

Implements nested function codegen names sorted.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L390)

<a id="function-function-mlc-codegen-codegen-stmt-nested-function-get-by-codegen-name-function-nested-function-get-by-codegen-name-state-code-name-mlc-codegen-codegen-stmt-ml-1934076083"></a>
### _nested_function_get_by_codegen_name

```ml
function _nested_function_get_by_codegen_name(state, code_name)
```

Implements nested function get by codegen name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `code_name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L377)

<a id="function-function-mlc-codegen-codegen-stmt-new-analysis-map-function-new-analysis-map-initial-cap-mlc-codegen-codegen-stmt-ml-1171141238"></a>
### _new_analysis_map

```ml
function _new_analysis_map(initial_cap)
```

Reusable per-codegen workspaces for the serial function-analysis pipeline. The two fact maps remain distinct because both are live during body emission; dependency, queue, promotion and traversal storage is reset between functions. This backend phase is deliberately serial. Keeping the cache in one ordinary array avoids adding a compiler-only struct shape to generated GC metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `initial_cap` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L57)

<a id="function-function-mlc-codegen-codegen-stmt-new-function-analysis-scratch-function-new-function-analysis-scratch-mlc-codegen-codegen-stmt-ml-1130672213"></a>
### _new_function_analysis_scratch

```ml
function _new_function_analysis_scratch()
```

Creates new function analysis scratch.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L63)

<a id="function-function-mlc-codegen-codegen-stmt-next-enum-id-function-next-enum-id-state-mlc-codegen-codegen-stmt-ml-1332970734"></a>
### _next_enum_id

```ml
function _next_enum_id(state)
```

Implements next enum id.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L7380)

<a id="function-function-mlc-codegen-codegen-stmt-next-struct-id-function-next-struct-id-state-mlc-codegen-codegen-stmt-ml-542310398"></a>
### _next_struct_id

```ml
function _next_struct_id(state)
```

Implements next struct id.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L7364)

<a id="function-function-mlc-codegen-codegen-stmt-note-reads-function-note-reads-read-before-written-yet-names-mlc-codegen-codegen-stmt-ml-1723353151"></a>
### _note_reads

```ml
function _note_reads(read_before, written_yet, names)
```

Implements note reads.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `read_before` | `dynamic` | — |  |
| `written_yet` | `dynamic` | — |  |
| `names` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L6381)

<a id="function-function-mlc-codegen-codegen-stmt-opt-emit-known-setindex-function-opt-emit-known-setindex-state-stmt-plan-mlc-codegen-codegen-stmt-ml-1289404053"></a>
### _opt_emit_known_setindex

```ml
function _opt_emit_known_setindex(state, stmt, plan)
```

Implements opt emit known setindex.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `stmt` | `dynamic` | — |  |
| `plan` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4116)

<a id="function-function-mlc-codegen-codegen-stmt-opt-try-const-int-function-opt-try-const-int-state-ex-mlc-codegen-codegen-stmt-ml-1449335133"></a>
### _opt_try_const_int

```ml
function _opt_try_const_int(state, ex)
```

Implements opt try const int.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3073)

<a id="function-function-mlc-codegen-codegen-stmt-opt-try-truthy-function-opt-try-truthy-state-ex-mlc-codegen-codegen-stmt-ml-335132007"></a>
### _opt_try_truthy

```ml
function _opt_try_truthy(state, ex)
```

Implements opt try truthy.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3006)

<a id="function-function-mlc-codegen-codegen-stmt-owner-for-function-owner-for-st-mlc-codegen-codegen-stmt-ml-234824292"></a>
### _owner_for

```ml
function _owner_for(st)
```

Implements owner for.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4450)

<a id="global-global-mlc-codegen-codegen-stmt-phase-codegen-keepalive-phase-codegen-keepalive-mlc-codegen-codegen-stmt-ml-860703081"></a>
### _phase_codegen_keepalive

```ml
_phase_codegen_keepalive
```

Explicit native-GC calls inside the self-hosted compiler need a process root for the large codegen graph.  The generated liveness map is intentionally conservative for ordinary calls, but multi-thousand-function programs keep AST entries alive across dozens of manual collections and exposed a stale pointer in fn_typeof without this barrier. Stores the phase codegen keepalive compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L39)

<a id="function-function-mlc-codegen-codegen-stmt-precompute-top-level-const-bindings-function-precompute-top-level-const-bindings-state-program-mlc-codegen-codegen-stmt-ml-33778528"></a>
### _precompute_top_level_const_bindings

```ml
function _precompute_top_level_const_bindings(state, program)
```

Implements precompute top level const bindings.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `program` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8259)

<a id="function-function-mlc-codegen-codegen-stmt-pref-is-method-prefix-function-pref-is-method-prefix-state-pref-mlc-codegen-codegen-stmt-ml-80599409"></a>
### _pref_is_method_prefix

```ml
function _pref_is_method_prefix(state, pref)
```

Implements pref is method prefix.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `pref` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4462)

<a id="function-function-mlc-codegen-codegen-stmt-prepare-function-analysis-scratch-function-prepare-function-analysis-scratch-value-mlc-codegen-codegen-stmt-ml-1048575006"></a>
### _prepare_function_analysis_scratch

```ml
function _prepare_function_analysis_scratch(value)
```

Implements prepare function analysis scratch.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L79)

<a id="function-function-mlc-codegen-codegen-stmt-prepare-qualify-cache-function-prepare-qualify-cache-cache-min-cap-mlc-codegen-codegen-stmt-ml-318466726"></a>
### _prepare_qualify_cache

```ml
function _prepare_qualify_cache(cache, min_cap)
```

Implements prepare qualify cache.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cache` | `dynamic` | — |  |
| `min_cap` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L405)

<a id="function-function-mlc-codegen-codegen-stmt-program-main-name-function-program-main-name-state-mlc-codegen-codegen-stmt-ml-4678978"></a>
### _program_main_name

```ml
function _program_main_name(state)
```

Implements program main name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8561)

<a id="function-function-mlc-codegen-codegen-stmt-promotion-scan-stmts-function-promotion-scan-stmts-hot-names-stmts-loop-depth-mlc-codegen-codegen-stmt-ml-61457264"></a>
### _promotion_scan_stmts

```ml
function _promotion_scan_stmts(hot_names, stmts, loop_depth)
```

Collect only assignment targets inside loops. Scanning statements rather than every expression keeps this analysis cheap on compiler-sized programs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hot_names` | `dynamic` | — |  |
| `stmts` | `dynamic` | — |  |
| `loop_depth` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3901)

<a id="function-function-mlc-codegen-codegen-stmt-pyval-to-lit-expr-function-pyval-to-lit-expr-v-mlc-codegen-codegen-stmt-ml-734013847"></a>
### _pyval_to_lit_expr

```ml
function _pyval_to_lit_expr(v)
```

Implements pyval to lit expr.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L2982)

<a id="function-function-mlc-codegen-codegen-stmt-qname-parent-prefix-function-qname-parent-prefix-qn-mlc-codegen-codegen-stmt-ml-1260486740"></a>
### _qname_parent_prefix

```ml
function _qname_parent_prefix(qn)
```

Implements qname parent prefix.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `qn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4529)

<a id="function-function-mlc-codegen-codegen-stmt-rdata-label-offset-function-rdata-label-offset-rb-name-mlc-codegen-codegen-stmt-ml-414070096"></a>
### _rdata_label_offset

```ml
function _rdata_label_offset(rb, name)
```

Implements rdata label offset.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L634)

<a id="function-function-mlc-codegen-codegen-stmt-rebuild-lookup-indexes-function-rebuild-lookup-indexes-state-mlc-codegen-codegen-stmt-ml-1362748970"></a>
### _rebuild_lookup_indexes

```ml
function _rebuild_lookup_indexes(state)
```

Implements rebuild lookup indexes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8455)

<a id="function-function-mlc-codegen-codegen-stmt-rebuild-module-function-entry-index-function-rebuild-module-function-entry-index-state-mlc-codegen-codegen-stmt-ml-616471402"></a>
### _rebuild_module_function_entry_index

```ml
function _rebuild_module_function_entry_index(state)
```

Implements rebuild module function entry index.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L9672)

<a id="function-function-mlc-codegen-codegen-stmt-reindex-aliases-function-reindex-aliases-arr-cap-hint-mlc-codegen-codegen-stmt-ml-122821840"></a>
### _reindex_aliases

```ml
function _reindex_aliases(arr, cap_hint)
```

Implements reindex aliases.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `cap_hint` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8429)

<a id="function-function-mlc-codegen-codegen-stmt-reindex-extern-sigs-function-reindex-extern-sigs-arr-cap-hint-mlc-codegen-codegen-stmt-ml-1092584560"></a>
### _reindex_extern_sigs

```ml
function _reindex_extern_sigs(arr, cap_hint)
```

Implements reindex extern sigs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `cap_hint` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8413)

<a id="function-function-mlc-codegen-codegen-stmt-reindex-named-array-function-reindex-named-array-arr-cap-hint-mlc-codegen-codegen-stmt-ml-40034076"></a>
### _reindex_named_array

```ml
function _reindex_named_array(arr, cap_hint)
```

Implements reindex named array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `cap_hint` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8359)

<a id="function-function-mlc-codegen-codegen-stmt-reindex-named-int-function-reindex-named-int-arr-cap-hint-mlc-codegen-codegen-stmt-ml-941787576"></a>
### _reindex_named_int

```ml
function _reindex_named_int(arr, cap_hint)
```

Implements reindex named int.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `cap_hint` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8385)

<a id="function-function-mlc-codegen-codegen-stmt-release-analysis-map-function-release-analysis-map-value-initial-cap-retained-cap-mlc-codegen-codegen-stmt-ml-1105537908"></a>
### _release_analysis_map

```ml
function _release_analysis_map(value, initial_cap, retained_cap)
```

Releases or resets release analysis map.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |
| `initial_cap` | `dynamic` | — |  |
| `retained_cap` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L102)

<a id="function-function-mlc-codegen-codegen-stmt-release-analysis-vector-function-release-analysis-vector-value-initial-cap-retained-cap-mlc-codegen-codegen-stmt-ml-254467516"></a>
### _release_analysis_vector

```ml
function _release_analysis_vector(value, initial_cap, retained_cap)
```

Releases or resets release analysis vector.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |
| `initial_cap` | `dynamic` | — |  |
| `retained_cap` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L89)

<a id="function-function-mlc-codegen-codegen-stmt-release-emitted-fn-body-function-release-emitted-fn-body-fn-node-mlc-codegen-codegen-stmt-ml-465330978"></a>
### _release_emitted_fn_body

```ml
function _release_emitted_fn_body(fn_node)
```

Releases or resets release emitted fn body.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fn_node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L440)

<a id="function-function-mlc-codegen-codegen-stmt-release-emitted-fn-node-function-release-emitted-fn-node-fn-node-mlc-codegen-codegen-stmt-ml-1428385850"></a>
### _release_emitted_fn_node

```ml
function _release_emitted_fn_node(fn_node)
```

Releases or resets release emitted fn node.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fn_node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L424)

<a id="function-function-mlc-codegen-codegen-stmt-release-function-analysis-scratch-function-release-function-analysis-scratch-value-mlc-codegen-codegen-stmt-ml-2081524866"></a>
### _release_function_analysis_scratch

```ml
function _release_function_analysis_scratch(value)
```

End one function-object batch by dropping all references owned by its temporary analysis arena. Logical epoch resets alone are insufficient here: the tracing GC still sees stale keys and values in inactive map slots.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L111)

<a id="function-function-mlc-codegen-codegen-stmt-reset-analysis-map-function-reset-analysis-map-mapv-minimum-capacity-mlc-codegen-codegen-stmt-ml-1891273622"></a>
### _reset_analysis_map

```ml
function _reset_analysis_map(mapv, minimum_capacity)
```

Keep a map's high-water capacity and advance its epoch in O(1). A later insertion may still grow it, in which case the owning scratch field is updated before the analysis returns.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapv` | `dynamic` | — |  |
| `minimum_capacity` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L127)

<a id="function-function-mlc-codegen-codegen-stmt-resolve-const-binding-for-ref-function-resolve-const-binding-for-ref-state-ref-node-mlc-codegen-codegen-stmt-ml-1586008631"></a>
### _resolve_const_binding_for_ref

```ml
function _resolve_const_binding_for_ref(state, ref, node)
```

Implements resolve const binding for ref.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ref` | `dynamic` | — |  |
| `node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L2946)

<a id="function-function-mlc-codegen-codegen-stmt-resolve-global-target-function-resolve-global-target-state-name-mlc-codegen-codegen-stmt-ml-908348951"></a>
### _resolve_global_target

```ml
function _resolve_global_target(state, name)
```

Implements resolve global target.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4515)

<a id="function-function-mlc-codegen-codegen-stmt-resolve-global-target-scan-function-resolve-global-target-scan-state-raw-qpref-fpref-mlc-codegen-codegen-stmt-ml-2003976959"></a>
### _resolve_global_target_scan

```ml
function _resolve_global_target_scan(state, raw, qpref, fpref)
```

Implements resolve global target scan.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `raw` | `dynamic` | — |  |
| `qpref` | `dynamic` | — |  |
| `fpref` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4542)

<a id="function-function-mlc-codegen-codegen-stmt-scan-function-for-global-decls-function-scan-function-for-global-decls-state-fn-node-mlc-codegen-codegen-stmt-ml-1138690953"></a>
### _scan_function_for_global_decls

```ml
function _scan_function_for_global_decls(state, fn_node)
```

Implements scan function for global decls.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `fn_node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4714)

<a id="function-function-mlc-codegen-codegen-stmt-scan-stmt-children-into-function-scan-stmt-children-into-worklist-st-mlc-codegen-codegen-stmt-ml-1034922555"></a>
### _scan_stmt_children_into

```ml
function _scan_stmt_children_into(worklist, st)
```

Append nested statements directly to an existing capacity-backed worklist. Keeping the parser field order here preserves analysis determinism without materializing and repeatedly concatenating a temporary child array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `worklist` | `dynamic` | — |  |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4589)

<a id="function-function-mlc-codegen-codegen-stmt-scan-stmt-for-global-decls-lifo-function-scan-stmt-for-global-decls-lifo-state-st-qpref-fpref-mlc-codegen-codegen-stmt-ml-1986752124"></a>
### _scan_stmt_for_global_decls_lifo

```ml
function _scan_stmt_for_global_decls_lifo(state, st, qpref, fpref)
```

Implements scan stmt for global decls lifo.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `st` | `dynamic` | — |  |
| `qpref` | `dynamic` | — |  |
| `fpref` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4635)

<a id="function-function-mlc-codegen-codegen-stmt-select-promoted-local-registers-function-select-promoted-local-registers-state-fn-node-known-types-shared-hot-names-analysis-scratch-mlc-codegen-codegen-stmt-ml-1360027211"></a>
### _select_promoted_local_registers

```ml
function _select_promoted_local_registers(state, fn_node, known_types, shared_hot_names, analysis_scratch)
```

Mirror at most two unique, proven immediate-only locals in Win64 nonvolatile XMM registers. Pointer-like, boxed, captured and ambiguous bindings stay on the canonical stack path so no GC root can disappear into a register.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `fn_node` | `dynamic` | — |  |
| `known_types` | `dynamic` | — |  |
| `shared_hot_names` | `dynamic` | — |  |
| `analysis_scratch` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3946)

<a id="function-function-mlc-codegen-codegen-stmt-set-const-binding-value-function-set-const-binding-value-state-b-or-name-pyv-mlc-codegen-codegen-stmt-ml-36059455"></a>
### _set_const_binding_value

```ml
function _set_const_binding_value(state, b_or_name, pyv)
```

Updates set const binding value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `b_or_name` | `dynamic` | — |  |
| `pyv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L2988)

<a id="function-function-mlc-codegen-codegen-stmt-set-fn-codegen-name-function-set-fn-codegen-name-state-fn-node-code-name-mlc-codegen-codegen-stmt-ml-2052609164"></a>
### _set_fn_codegen_name

```ml
function _set_fn_codegen_name(state, fn_node, code_name)
```

Updates set fn codegen name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `fn_node` | `dynamic` | — |  |
| `code_name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L187)

<a id="function-function-mlc-codegen-codegen-stmt-set-user-function-function-set-user-function-state-qname-fn-node-mlc-codegen-codegen-stmt-ml-1324041717"></a>
### _set_user_function

```ml
function _set_user_function(state, qname, fn_node)
```

Updates set user function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |
| `fn_node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L260)

<a id="function-function-mlc-codegen-codegen-stmt-sort-id-label-pairs-function-sort-id-label-pairs-vals-mlc-codegen-codegen-stmt-ml-2106345417"></a>
### _sort_id_label_pairs

```ml
function _sort_id_label_pairs(vals)
```

Implements sort id label pairs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `vals` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5245)

<a id="function-function-mlc-codegen-codegen-stmt-sort-names-function-sort-names-vals-mlc-codegen-codegen-stmt-ml-1712205221"></a>
### _sort_names

```ml
function _sort_names(vals)
```

Implements sort names.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `vals` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5146)

<a id="function-function-mlc-codegen-codegen-stmt-st-file-inline-function-st-file-st-mlc-codegen-codegen-stmt-ml-1471140023"></a>
### _st_file

```ml
inline function _st_file(st)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L7396)

<a id="function-function-mlc-codegen-codegen-stmt-static-obj-label-for-global-name-function-static-obj-label-for-global-name-state-name-mlc-codegen-codegen-stmt-ml-1219702007"></a>
### _static_obj_label_for_global_name

```ml
function _static_obj_label_for_global_name(state, name)
```

Implements static obj label for global name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8689)

<a id="function-function-mlc-codegen-codegen-stmt-stmt-uses-this-function-stmt-uses-this-st-mlc-codegen-codegen-stmt-ml-1130920190"></a>
### _stmt_uses_this

```ml
function _stmt_uses_this(st)
```

Implements stmt uses this.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L7134)

<a id="function-function-mlc-codegen-codegen-stmt-stmts-use-native-threads-function-stmts-use-native-threads-stmts-mlc-codegen-codegen-stmt-ml-1780898312"></a>
### _stmts_use_native_threads

```ml
function _stmts_use_native_threads(stmts)
```

Implements stmts use native threads.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stmts` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L9006)

<a id="function-function-mlc-codegen-codegen-stmt-string-gt-function-string-gt-a-b-mlc-codegen-codegen-stmt-ml-363027788"></a>
### _string_gt

```ml
function _string_gt(a, b)
```

Implements string gt.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L5127)

<a id="function-function-mlc-codegen-codegen-stmt-strpair-get-inline-function-strpair-get-arr-key-mlc-codegen-codegen-stmt-ml-401819300"></a>
### _strpair_get

```ml
inline function _strpair_get(arr, key)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L7412)

<a id="function-function-mlc-codegen-codegen-stmt-strpair-set-function-strpair-set-arr-key-value-mlc-codegen-codegen-stmt-ml-737002348"></a>
### _strpair_set

```ml
function _strpair_set(arr, key, value)
```

Implements strpair set.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L7435)

<a id="function-function-mlc-codegen-codegen-stmt-struct-methods-any-has-function-struct-methods-any-has-state-mname-mlc-codegen-codegen-stmt-ml-789775902"></a>
### _struct_methods_any_has

```ml
function _struct_methods_any_has(state, mname)
```

Implements struct methods any has.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `mname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L10538)

<a id="function-function-mlc-codegen-codegen-stmt-synchronized-block-has-crossing-exit-function-synchronized-block-has-crossing-exit-stmts-break-depth-loop-depth-mlc-codegen-codegen-stmt-ml-1495297325"></a>
### _synchronized_block_has_crossing_exit

```ml
function _synchronized_block_has_crossing_exit(stmts, break_depth, loop_depth)
```

Implements synchronized block has crossing exit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stmts` | `dynamic` | — |  |
| `break_depth` | `dynamic` | — |  |
| `loop_depth` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L814)

<a id="function-function-mlc-codegen-codegen-stmt-tag-ns-function-tag-ns-ns-name-mlc-codegen-codegen-stmt-ml-1295770015"></a>
### _tag_ns

```ml
function _tag_ns(ns, name)
```

Implements tag ns.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ns` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4456)

<a id="function-function-mlc-codegen-codegen-stmt-tag-ns-prefix-function-tag-ns-prefix-node-pref-mlc-codegen-codegen-stmt-ml-1554950438"></a>
### _tag_ns_prefix

```ml
function _tag_ns_prefix(node, pref)
```

Implements tag ns prefix.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — |  |
| `pref` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4787)

<a id="function-function-mlc-codegen-codegen-stmt-truthy-function-truthy-v-mlc-codegen-codegen-stmt-ml-1730986865"></a>
### _truthy

```ml
function _truthy(v)
```

Implements truthy.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3000)

<a id="function-function-mlc-codegen-codegen-stmt-typeflow-base-inline-function-typeflow-base-type-name-mlc-codegen-codegen-stmt-ml-471557554"></a>
### _typeflow_base

```ml
inline function _typeflow_base(type_name)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `type_name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3407)

<a id="function-function-mlc-codegen-codegen-stmt-typeflow-dependency-add-function-typeflow-dependency-add-dependents-dependency-owner-mlc-codegen-codegen-stmt-ml-395466257"></a>
### _typeflow_dependency_add

```ml
function _typeflow_dependency_add(dependents, dependency, owner)
```

Implements typeflow dependency add.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dependents` | `dynamic` | — |  |
| `dependency` | `dynamic` | — |  |
| `owner` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3722)

<a id="function-function-mlc-codegen-codegen-stmt-typeflow-exact-length-function-typeflow-exact-length-type-name-mlc-codegen-codegen-stmt-ml-700789855"></a>
### _typeflow_exact_length

```ml
function _typeflow_exact_length(type_name)
```

Implements typeflow exact length.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `type_name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3417)

<a id="function-function-mlc-codegen-codegen-stmt-typeflow-expr-type-function-typeflow-expr-type-state-ex-known-mlc-codegen-codegen-stmt-ml-327640540"></a>
### _typeflow_expr_type

```ml
function _typeflow_expr_type(state, ex, known)
```

Implements typeflow expr type.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |
| `known` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3494)

<a id="function-function-mlc-codegen-codegen-stmt-typeflow-get-function-typeflow-get-items-name-mlc-codegen-codegen-stmt-ml-612873736"></a>
### _typeflow_get

```ml
function _typeflow_get(items, name)
```

Implements typeflow get.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3434)

<a id="function-function-mlc-codegen-codegen-stmt-typeflow-merge-function-typeflow-merge-inferred-mlc-codegen-codegen-stmt-ml-1861371564"></a>
### _typeflow_merge

```ml
function _typeflow_merge(inferred)
```

Implements typeflow merge.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `inferred` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3609)

<a id="function-function-mlc-codegen-codegen-stmt-typeflow-remove-function-typeflow-remove-items-name-mlc-codegen-codegen-stmt-ml-747969520"></a>
### _typeflow_remove

```ml
function _typeflow_remove(items, name)
```

Implements typeflow remove.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3466)

<a id="function-function-mlc-codegen-codegen-stmt-typeflow-scan-expr-dependencies-function-typeflow-scan-expr-dependencies-dependents-owner-ex-mlc-codegen-codegen-stmt-ml-1574720999"></a>
### _typeflow_scan_expr_dependencies

```ml
function _typeflow_scan_expr_dependencies(dependents, owner, ex)
```

Build reverse variable dependencies once so fixed-point propagation only revisits facts affected by a change instead of rescanning every candidate.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dependents` | `dynamic` | — |  |
| `owner` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3735)

<a id="function-function-mlc-codegen-codegen-stmt-typeflow-scan-read-expr-function-typeflow-scan-read-expr-ex-tracked-initialized-read-before-mlc-codegen-codegen-stmt-ml-184513138"></a>
### _typeflow_scan_read_expr

```ml
function _typeflow_scan_read_expr(ex, tracked, initialized, read_before)
```

Implements typeflow scan read expr.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |
| `tracked` | `dynamic` | — |  |
| `initialized` | `dynamic` | — |  |
| `read_before` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3633)

<a id="function-function-mlc-codegen-codegen-stmt-typeflow-scan-read-order-function-typeflow-scan-read-order-stmts-tracked-initialized-read-before-direct-mlc-codegen-codegen-stmt-ml-1105561529"></a>
### _typeflow_scan_read_order

```ml
function _typeflow_scan_read_order(stmts, tracked, initialized, read_before, direct)
```

Implements typeflow scan read order.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stmts` | `dynamic` | — |  |
| `tracked` | `dynamic` | — |  |
| `initialized` | `dynamic` | — |  |
| `read_before` | `dynamic` | — |  |
| `direct` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3663)

<a id="function-function-mlc-codegen-codegen-stmt-typeflow-set-function-typeflow-set-items-name-value-mlc-codegen-codegen-stmt-ml-1071418125"></a>
### _typeflow_set

```ml
function _typeflow_set(items, name, value)
```

Implements typeflow set.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3450)

<a id="function-function-mlc-codegen-codegen-stmt-typeflow-struct-qname-function-typeflow-struct-qname-state-callee-mlc-codegen-codegen-stmt-ml-440133360"></a>
### _typeflow_struct_qname

```ml
function _typeflow_struct_qname(state, callee)
```

Implements typeflow struct qname.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `callee` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L3478)

<a id="function-function-mlc-codegen-codegen-stmt-user-function-get-node-function-user-function-get-node-state-qname-mlc-codegen-codegen-stmt-ml-282345418"></a>
### _user_function_get_node

```ml
function _user_function_get_node(state, qname)
```

Implements user function get node.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L326)

<a id="function-function-mlc-codegen-codegen-stmt-user-function-has-inline-function-user-function-has-state-qname-mlc-codegen-codegen-stmt-ml-1533091489"></a>
### _user_function_has

```ml
inline function _user_function_has(state, qname)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L7019)

<a id="function-function-mlc-codegen-codegen-stmt-user-function-keys-sorted-function-user-function-keys-sorted-state-mlc-codegen-codegen-stmt-ml-1002511518"></a>
### _user_function_keys_sorted

```ml
function _user_function_keys_sorted(state)
```

Implements user function keys sorted.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L355)

<a id="function-function-mlc-codegen-codegen-stmt-walk-stmt-function-walk-stmt-st-vals-mlc-codegen-codegen-stmt-ml-950371960"></a>
### _walk_stmt

```ml
function _walk_stmt(st, vals)
```

Implements walk stmt.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |
| `vals` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4776)

<a id="function-function-mlc-codegen-codegen-stmt-walk-stmt-into-function-walk-stmt-into-st-vals-b-mlc-codegen-codegen-stmt-ml-781870235"></a>
### _walk_stmt_into

```ml
function _walk_stmt_into(st, vals_b)
```

Implements walk stmt into.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |
| `vals_b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L4741)

<a id="function-function-mlc-codegen-codegen-stmt-add-function-add-arr-value-mlc-codegen-codegen-stmt-ml-1901574475"></a>
### add

```ml
function add(arr, value)
```

Updates add.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — | Value supplied for `arr`. |
| `value` | `dynamic` | — | Value to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L10434)

<a id="function-function-mlc-codegen-codegen-stmt-all-function-entries-function-all-function-entries-state-mlc-codegen-codegen-stmt-ml-1219167550"></a>
### all_function_entries

```ml
function all_function_entries(state)
```

Expose the canonical monolithic function order to the object writer. The .mlo pipeline must partition this sequence without regrouping it by module; regrouping changes both native code layout and first-use constant order.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8555)

<a id="function-function-mlc-codegen-codegen-stmt-analyze-block-function-analyze-block-state-stmts-mlc-codegen-codegen-stmt-ml-1663709957"></a>
### analyze_block

```ml
function analyze_block(state, stmts)
```

Implements analyze block.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `stmts` | `dynamic` | — | Value supplied for `stmts`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L10504)

<a id="function-function-mlc-codegen-codegen-stmt-analyze-expr-function-analyze-expr-state-ex-mlc-codegen-codegen-stmt-ml-2070285797"></a>
### analyze_expr

```ml
function analyze_expr(state, ex)
```

Implements analyze expr.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `ex` | `dynamic` | — | Value supplied for `ex`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L10465)

<a id="function-function-mlc-codegen-codegen-stmt-analyze-read-var-function-analyze-read-var-state-name-mlc-codegen-codegen-stmt-ml-1275782887"></a>
### analyze_read_var

```ml
function analyze_read_var(state, name)
```

Implements analyze read var.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L10446)

<a id="function-function-mlc-codegen-codegen-stmt-analyze-write-var-function-analyze-write-var-state-name-mlc-codegen-codegen-stmt-ml-1115907147"></a>
### analyze_write_var

```ml
function analyze_write_var(state, name)
```

Implements analyze write var.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L10453)

<a id="function-function-mlc-codegen-codegen-stmt-cg-emit-stmt-function-cg-emit-stmt-state-stmt-mlc-codegen-codegen-stmt-ml-328079108"></a>
### cg_emit_stmt

```ml
function cg_emit_stmt(state, stmt)
```

Emit one statement without changing source-order semantics. Nested control flow owns its labels and must leave root/lock scopes balanced on every exit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `stmt` | `dynamic` | — | Value supplied for `stmt`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L1488)

- [mlc.codegen.codegen_stmt.DeferCollectResult](Type-mlc-codegen-codegen-stmt-defercollectresult-1309598497.md) — struct
<a id="function-function-mlc-codegen-codegen-stmt-emit-entry-object-function-emit-entry-object-state-module-init-recs-max-call-args-main-main-name-mlc-codegen-codegen-stmt-ml-891805571"></a>
### emit_entry_object

```ml
function emit_entry_object(state, module_init_recs, max_call_args_main, main_name)
```

Runs emit entry object.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `module_init_recs` | `dynamic` | — | Value supplied for `module_init_recs`. |
| `max_call_args_main` | `dynamic` | — | Value supplied for `max_call_args_main`. |
| `main_name` | `dynamic` | — | Value supplied for `main_name`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L9344)

<a id="function-function-mlc-codegen-codegen-stmt-emit-module-function-entries-function-emit-module-function-entries-state-entries-start-index-count-analysis-scratch-mlc-codegen-codegen-stmt-ml-1569217191"></a>
### emit_module_function_entries

```ml
function emit_module_function_entries(state, entries, start_index, count, analysis_scratch)
```

Runs emit module function entries.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `entries` | `dynamic` | — | Value supplied for `entries`. |
| `start_index` | `dynamic` | — | Value supplied for `start_index`. |
| `count` | `dynamic` | — | Number of items to process. |
| `analysis_scratch` | `dynamic` | — | Value supplied for `analysis_scratch`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L9743)

<a id="function-function-mlc-codegen-codegen-stmt-emit-module-functions-function-emit-module-functions-state-module-file-mlc-codegen-codegen-stmt-ml-678832221"></a>
### emit_module_functions

```ml
function emit_module_functions(state, module_file)
```

Runs emit module functions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `module_file` | `dynamic` | — | Value supplied for `module_file`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L9780)

<a id="function-function-mlc-codegen-codegen-stmt-emit-module-init-object-function-emit-module-init-object-state-module-rec-mlc-codegen-codegen-stmt-ml-2076069695"></a>
### emit_module_init_object

```ml
function emit_module_init_object(state, module_rec)
```

Runs emit module init object.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `module_rec` | `dynamic` | — | Value supplied for `module_rec`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L9492)

<a id="function-function-mlc-codegen-codegen-stmt-emit-program-function-emit-program-state-program-mlc-codegen-codegen-stmt-ml-1271724548"></a>
### emit_program

```ml
function emit_program(state, program)
```

Runs emit program.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `program` | `dynamic` | — | Value supplied for `program`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8683)

<a id="function-function-mlc-codegen-codegen-stmt-emit-stmt-function-emit-stmt-state-st-mlc-codegen-codegen-stmt-ml-1005594799"></a>
### emit_stmt

```ml
function emit_stmt(state, st)
```

Runs emit stmt.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `st` | `dynamic` | — | Value supplied for `st`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L7013)

<a id="function-function-mlc-codegen-codegen-stmt-emit-user-function-function-emit-user-function-state-fn-node-analysis-scratch-mlc-codegen-codegen-stmt-ml-731813178"></a>
### emit_user_function

```ml
function emit_user_function(state, fn_node, analysis_scratch)
```

Runs emit user function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `fn_node` | `dynamic` | — | Value supplied for `fn_node`. |
| `analysis_scratch` | `dynamic` | — | Value supplied for `analysis_scratch`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L9789)

<a id="function-function-mlc-codegen-codegen-stmt-expr-function-expr-state-ex-mlc-codegen-codegen-stmt-ml-841964937"></a>
### expr

```ml
function expr(state, ex)
```

Implements expr.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `ex` | `dynamic` | — | Value supplied for `ex`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L10519)

<a id="function-function-mlc-codegen-codegen-stmt-expr-reads-function-expr-reads-ex-mlc-codegen-codegen-stmt-ml-1421336922"></a>
### expr_reads

```ml
function expr_reads(ex)
```

Implements expr reads.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — | Value supplied for `ex`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L10525)

<a id="function-function-mlc-codegen-codegen-stmt-function-entry-count-function-function-entry-count-entries-mlc-codegen-codegen-stmt-ml-216196625"></a>
### function_entry_count

```ml
function function_entry_count(entries)
```

Implements function entry count.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entries` | `dynamic` | — | Value supplied for `entries`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8520)

<a id="function-function-mlc-codegen-codegen-stmt-function-entry-name-function-function-entry-name-entries-node-id-mlc-codegen-codegen-stmt-ml-915095903"></a>
### function_entry_name

```ml
function function_entry_name(entries, node_id)
```

Implements function entry name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entries` | `dynamic` | — | Value supplied for `entries`. |
| `node_id` | `dynamic` | — | Value supplied for `node_id`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8529)

<a id="function-function-mlc-codegen-codegen-stmt-function-entry-node-function-function-entry-node-entries-node-id-mlc-codegen-codegen-stmt-ml-1036856429"></a>
### function_entry_node

```ml
function function_entry_node(entries, node_id)
```

Implements function entry node.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entries` | `dynamic` | — | Value supplied for `entries`. |
| `node_id` | `dynamic` | — | Value supplied for `node_id`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L8545)

- [mlc.codegen.codegen_stmt.FunctionNodeArena](Type-mlc-codegen-codegen-stmt-functionnodearena-1818543593.md) — struct
<a id="function-function-mlc-codegen-codegen-stmt-max-calls-expr-function-max-calls-expr-state-ex-mlc-codegen-codegen-stmt-ml-426733429"></a>
### max_calls_expr

```ml
function max_calls_expr(state, ex)
```

Implements max calls expr.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `ex` | `dynamic` | — | Value supplied for `ex`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L10563)

<a id="function-function-mlc-codegen-codegen-stmt-max-calls-stmts-function-max-calls-stmts-state-stmts-mlc-codegen-codegen-stmt-ml-1628904277"></a>
### max_calls_stmts

```ml
function max_calls_stmts(state, stmts)
```

Implements max calls stmts.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `stmts` | `dynamic` | — | Value supplied for `stmts`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L10624)

<a id="function-function-mlc-codegen-codegen-stmt-module-function-entries-function-module-function-entries-state-module-file-mlc-codegen-codegen-stmt-ml-148202013"></a>
### module_function_entries

```ml
function module_function_entries(state, module_file)
```

Implements module function entries.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `module_file` | `dynamic` | — | Value supplied for `module_file`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L9705)

<a id="function-function-mlc-codegen-codegen-stmt-note-reads-function-note-reads-state-names-mlc-codegen-codegen-stmt-ml-1767882344"></a>
### note_reads

```ml
function note_reads(state, names)
```

Implements note reads.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `names` | `dynamic` | — | Value supplied for `names`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L10532)

<a id="function-function-mlc-codegen-codegen-stmt-prepare-program-for-objects-function-prepare-program-for-objects-state-program-mlc-codegen-codegen-stmt-ml-1341937234"></a>
### prepare_program_for_objects

```ml
function prepare_program_for_objects(state, program)
```

Implements prepare program for objects.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `program` | `dynamic` | — | Value supplied for `program`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L9064)

<a id="function-function-mlc-codegen-codegen-stmt-release-emitted-function-entries-function-release-emitted-function-entries-state-entries-start-index-count-mlc-codegen-codegen-stmt-ml-233935854"></a>
### release_emitted_function_entries

```ml
function release_emitted_function_entries(state, entries, start_index, count)
```

Release the bodies covered by one completed object fragment while keeping stable function signatures in the semantic indexes used by later callers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `entries` | `dynamic` | — | Value supplied for `entries`. |
| `start_index` | `dynamic` | — | Value supplied for `start_index`. |
| `count` | `dynamic` | — | Number of items to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L480)

<a id="function-function-mlc-codegen-codegen-stmt-stmt-list-function-stmt-list-state-stmts-mlc-codegen-codegen-stmt-ml-1329412459"></a>
### stmt_list

```ml
function stmt_list(state, stmts)
```

Implements stmt list.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `stmts` | `dynamic` | — | Value supplied for `stmts`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_stmt.ml#L10756)
