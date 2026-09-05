# `mlc/codegen/codegen_expr.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc codegen codegen_expr package.

Package: [`mlc.codegen.codegen_expr`](Package-mlc-codegen-codegen-expr-1165427189.md)

Reachable from entry: **yes**

## Imports

- `mlc/asm.ml` as `a` → [mlc/asm.ml](File-mlc-asm-ml-1368648960.md)
- `mlc/codegen/codegen_core.ml` as `core` → [mlc/codegen/codegen_core.ml](File-mlc-codegen-codegen-core-ml-528695596.md)
- `mlc/codegen/codegen_memory.ml` as `mem` → [mlc/codegen/codegen_memory.ml](File-mlc-codegen-codegen-memory-ml-2136639668.md)
- `mlc/codegen/codegen_scope.ml` as `scope` → [mlc/codegen/codegen_scope.ml](File-mlc-codegen-codegen-scope-ml-1124416197.md)
- `mlc/codegen/codegen_threads.ml` as `th` → [mlc/codegen/codegen_threads.ml](File-mlc-codegen-codegen-threads-ml-1261658982.md)
- `mlc/constants.ml` as `c` → [mlc/constants.ml](File-mlc-constants-ml-1024884042.md)
- `mlc/data.ml` as `d` → [mlc/data.ml](File-mlc-data-ml-557434521.md)
- `mlc/minilang_parser.ml` as `ml` → [mlc/minilang_parser.ml](File-mlc-minilang-parser-ml-1485036712.md)
- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)
- `std/string.ml` as `s` → `std/string.ml` — external dependency

## Declarations

<a id="function-function-mlc-codegen-codegen-expr-abi-param-is-double-function-abi-param-is-double-abi-ty-mlc-codegen-codegen-expr-ml-1010111637"></a>
### _abi_param_is_double

```ml
function _abi_param_is_double(abi_ty)
```

Out parameters always carry an address, even when their pointee is double. Keep that pointer in the integer ABI class on every target.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `abi_ty` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8851)

<a id="function-function-mlc-codegen-codegen-expr-abi-ty-to-str-function-abi-ty-to-str-abi-ty-mlc-codegen-codegen-expr-ml-673719793"></a>
### _abi_ty_to_str

```ml
function _abi_ty_to_str(abi_ty)
```

Compatibility wrappers (Python CodegenExpr parity).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `abi_ty` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8331)

<a id="function-function-mlc-codegen-codegen-expr-alias-lookup-inline-function-alias-lookup-alias-map-key-mlc-codegen-codegen-expr-ml-837732516"></a>
### _alias_lookup

```ml
inline function _alias_lookup(alias_map, key)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `alias_map` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L757)

<a id="function-function-mlc-codegen-codegen-expr-alias-lookup-array-exact-inline-function-alias-lookup-array-exact-alias-map-key-mlc-codegen-codegen-expr-ml-108088364"></a>
### _alias_lookup_array_exact

```ml
inline function _alias_lookup_array_exact(alias_map, key)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `alias_map` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L775)

<a id="function-function-mlc-codegen-codegen-expr-alias-target-for-base-function-alias-target-for-base-state-base-mlc-codegen-codegen-expr-ml-677820043"></a>
### _alias_target_for_base

```ml
function _alias_target_for_base(state, base)
```

Lower alias target for base expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `base` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L843)

<a id="function-function-mlc-codegen-codegen-expr-apply-import-alias-function-apply-import-alias-state-qname-mlc-codegen-codegen-expr-ml-318875280"></a>
### _apply_import_alias

```ml
function _apply_import_alias(state, qname)
```

Lower apply import alias expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L788)

<a id="function-function-mlc-codegen-codegen-expr-arr-has-str-inline-function-arr-has-str-arr-value-mlc-codegen-codegen-expr-ml-1249794348"></a>
### _arr_has_str

```ml
inline function _arr_has_str(arr, value)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L822)

<a id="function-function-mlc-codegen-codegen-expr-builtin-label-inline-function-builtin-label-name-mlc-codegen-codegen-expr-ml-1717663613"></a>
### _builtin_label

```ml
inline function _builtin_label(name)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L584)

<a id="function-function-mlc-codegen-codegen-expr-call-args-have-stack-variadic-function-call-args-have-stack-variadic-args-mlc-codegen-codegen-expr-ml-1023336562"></a>
### _call_args_have_stack_variadic

```ml
function _call_args_have_stack_variadic(args)
```

Lower call args have stack variadic expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9877)

<a id="function-function-mlc-codegen-codegen-expr-cg-expr-try-const-value-function-cg-expr-try-const-value-state-expr-preserve-unary-float-mlc-codegen-codegen-expr-ml-27667210"></a>
### _cg_expr_try_const_value

```ml
function _cg_expr_try_const_value(state, expr, preserve_unary_float)
```

Lower cg expr try const value expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |
| `preserve_unary_float` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1247)

<a id="function-function-mlc-codegen-codegen-expr-coerce-name-inline-function-coerce-name-v-mlc-codegen-codegen-expr-ml-2073764020"></a>
### _coerce_name

```ml
inline function _coerce_name(v)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L304)

<a id="function-function-mlc-codegen-codegen-expr-compile-symbol-has-inline-function-compile-symbol-has-state-key-mlc-codegen-codegen-expr-ml-1426967752"></a>
### _compile_symbol_has

```ml
inline function _compile_symbol_has(state, key)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L573)

<a id="function-function-mlc-codegen-codegen-expr-contains-nested-fn-function-contains-nested-fn-node-mlc-codegen-codegen-expr-ml-757988883"></a>
### _contains_nested_fn

```ml
function _contains_nested_fn(node)
```

Reports whether contains nested fn.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8800)

<a id="function-function-mlc-codegen-codegen-expr-direct-user-call-enabled-function-direct-user-call-enabled-state-qname-mlc-codegen-codegen-expr-ml-954144962"></a>
### _direct_user_call_enabled

```ml
function _direct_user_call_enabled(state, qname)
```

Lower direct user call enabled expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L7374)

<a id="function-function-mlc-codegen-codegen-expr-emit-auto-errprop-function-emit-auto-errprop-state-mlc-codegen-codegen-expr-ml-1427208816"></a>
### _emit_auto_errprop

```ml
function _emit_auto_errprop(state)
```

Lower emit auto errprop expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8908)

<a id="function-function-mlc-codegen-codegen-expr-emit-auto-errprop-cold-block-function-emit-auto-errprop-cold-block-state-mlc-codegen-codegen-expr-ml-2016839500"></a>
### _emit_auto_errprop_cold_block

```ml
function _emit_auto_errprop_cold_block(state)
```

Lower emit auto errprop cold block expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8957)

<a id="function-function-mlc-codegen-codegen-expr-emit-call-args-eval-recursive-function-emit-call-args-eval-recursive-state-call-args-idx-nargs-base-off-mlc-codegen-codegen-expr-ml-103569979"></a>
### _emit_call_args_eval_recursive

```ml
function _emit_call_args_eval_recursive(state, call_args, idx, nargs, base_off)
```

Lower emit call args eval recursive expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `call_args` | `dynamic` | — |  |
| `idx` | `dynamic` | — |  |
| `nargs` | `dynamic` | — |  |
| `base_off` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L10155)

<a id="function-function-mlc-codegen-codegen-expr-emit-direct-struct-constructor-function-emit-direct-struct-constructor-state-scallee-sid-call-args-nargs-mlc-codegen-codegen-expr-ml-935619048"></a>
### _emit_direct_struct_constructor

```ml
function _emit_direct_struct_constructor(state, scallee, sid, call_args, nargs)
```

Emit a statically resolved struct construction while preserving field guards.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `scallee` | `dynamic` | — |  |
| `sid` | `dynamic` | — |  |
| `call_args` | `dynamic` | — |  |
| `nargs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L7538)

<a id="function-function-mlc-codegen-codegen-expr-emit-direct-user-call-function-emit-direct-user-call-state-direct-user-name-call-args-nargs-mlc-codegen-codegen-expr-ml-265201574"></a>
### _emit_direct_user_call

```ml
function _emit_direct_user_call(state, direct_user_name, call_args, nargs)
```

Emit an unguarded direct call selected by the explicit compiler fast-path option.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `direct_user_name` | `dynamic` | — |  |
| `call_args` | `dynamic` | — |  |
| `nargs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L7616)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-array-lit-function-emit-expr-array-lit-state-expr-mlc-codegen-codegen-expr-ml-1916635897"></a>
### _emit_expr_array_lit

```ml
function _emit_expr_array_lit(state, expr)
```

Lower emit expr array lit expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8235)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-bin-function-emit-expr-bin-state-expr-mlc-codegen-codegen-expr-ml-1874814489"></a>
### _emit_expr_bin

```ml
function _emit_expr_bin(state, expr)
```

Emit binary operators, preserving left-to-right effects and routing dynamic type/error cases through the same helpers used by the reference compiler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L3259)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-bool-function-emit-expr-bool-state-expr-mlc-codegen-codegen-expr-ml-1473250299"></a>
### _emit_expr_bool

```ml
function _emit_expr_bool(state, expr)
```

Lower emit expr bool expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1777)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-call-function-emit-expr-call-state-expr-mlc-codegen-codegen-expr-ml-1220291383"></a>
### _emit_expr_call

```ml
function _emit_expr_call(state, expr)
```

Lower emit expr call expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L4521)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-call-early-builtins-function-emit-expr-call-early-builtins-state-callee-raw-name-call-args-nargs-mlc-codegen-codegen-expr-ml-1199270435"></a>
### _emit_expr_call_early_builtins

```ml
function _emit_expr_call_early_builtins(state, callee, raw_name, call_args, nargs)
```

Lower emit expr call early builtins expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `callee` | `dynamic` | — |  |
| `raw_name` | `dynamic` | — |  |
| `call_args` | `dynamic` | — |  |
| `nargs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L5213)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-call-generic-function-emit-expr-call-generic-state-cal-callee-raw-name-call-args-nargs-member-runtime-mlc-codegen-codegen-expr-ml-1620748138"></a>
### _emit_expr_call_generic

```ml
function _emit_expr_call_generic(state, cal, callee, raw_name, call_args, nargs, member_runtime)
```

Select constructor, direct-call, extern, or indirect-call lowering for a generic call.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `cal` | `dynamic` | — |  |
| `callee` | `dynamic` | — |  |
| `raw_name` | `dynamic` | — |  |
| `call_args` | `dynamic` | — |  |
| `nargs` | `dynamic` | — |  |
| `member_runtime` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L7383)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-coalesce-function-emit-expr-coalesce-state-expr-mlc-codegen-codegen-expr-ml-825042161"></a>
### _emit_expr_coalesce

```ml
function _emit_expr_coalesce(state, expr)
```

Lower emit expr coalesce expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1646)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-index-function-emit-expr-index-state-expr-mlc-codegen-codegen-expr-ml-871640929"></a>
### _emit_expr_index

```ml
function _emit_expr_index(state, expr)
```

Lower emit expr index expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2199)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-is-type-function-emit-expr-is-type-state-expr-mlc-codegen-codegen-expr-ml-359244241"></a>
### _emit_expr_is_type

```ml
function _emit_expr_is_type(state, expr)
```

Lower emit expr is type expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1800)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-member-function-emit-expr-member-state-expr-mlc-codegen-codegen-expr-ml-911124331"></a>
### _emit_expr_member

```ml
function _emit_expr_member(state, expr)
```

Lower emit expr member expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2021)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-num-function-emit-expr-num-state-expr-mlc-codegen-codegen-expr-ml-1983028885"></a>
### _emit_expr_num

```ml
function _emit_expr_num(state, expr)
```

Lower emit expr num expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1754)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-safe-call-function-emit-expr-safe-call-state-expr-mlc-codegen-codegen-expr-ml-1000404641"></a>
### _emit_expr_safe_call

```ml
function _emit_expr_safe_call(state, expr)
```

Lower emit expr safe call expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1681)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-safe-member-function-emit-expr-safe-member-state-expr-mlc-codegen-codegen-expr-ml-1807199021"></a>
### _emit_expr_safe_member

```ml
function _emit_expr_safe_member(state, expr)
```

Lower emit expr safe member expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1659)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-str-function-emit-expr-str-state-expr-mlc-codegen-codegen-expr-ml-1516643885"></a>
### _emit_expr_str

```ml
function _emit_expr_str(state, expr)
```

Lower emit expr str expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1784)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-type-guard-function-emit-expr-type-guard-state-expr-mlc-codegen-codegen-expr-ml-555431059"></a>
### _emit_expr_type_guard

```ml
function _emit_expr_type_guard(state, expr)
```

Lower emit expr type guard expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1705)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-unary-function-emit-expr-unary-state-expr-mlc-codegen-codegen-expr-ml-1385790597"></a>
### _emit_expr_unary

```ml
function _emit_expr_unary(state, expr)
```

Lower emit expr unary expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2372)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-unsupported-function-emit-expr-unsupported-state-expr-k-mlc-codegen-codegen-expr-ml-1192983288"></a>
### _emit_expr_unsupported

```ml
function _emit_expr_unsupported(state, expr, k)
```

Lower emit expr unsupported expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |
| `k` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8298)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-var-function-emit-expr-var-state-expr-mlc-codegen-codegen-expr-ml-1466870729"></a>
### _emit_expr_var

```ml
function _emit_expr_var(state, expr)
```

Lower emit expr var expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1998)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-voidlit-function-emit-expr-voidlit-state-expr-mlc-codegen-codegen-expr-ml-950400181"></a>
### _emit_expr_voidlit

```ml
function _emit_expr_voidlit(state, expr)
```

Lower emit expr voidlit expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1793)

<a id="function-function-mlc-codegen-codegen-expr-emit-extern-arg-to-native-function-emit-extern-arg-to-native-state-abi-ty-fail-label-pos-wbuf-label-mlc-codegen-codegen-expr-ml-211883222"></a>
### _emit_extern_arg_to_native

```ml
function _emit_extern_arg_to_native(state, abi_ty, fail_label, pos, wbuf_label)
```

Lower emit extern arg to native expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `abi_ty` | `dynamic` | — |  |
| `fail_label` | `dynamic` | — |  |
| `pos` | `dynamic` | — |  |
| `wbuf_label` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8969)

<a id="function-function-mlc-codegen-codegen-expr-emit-extern-call-function-emit-extern-call-state-call-node-args-out-kind-out-name-pos-mlc-codegen-codegen-expr-ml-14918519"></a>
### _emit_extern_call

```ml
function _emit_extern_call(state, call_node, args, out_kind, out_name, pos)
```

Marshal one MiniLang call frame to the declared native ABI. Managed roots remain published across the call and out-values are normalized on return.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `call_node` | `dynamic` | — |  |
| `args` | `dynamic` | — |  |
| `out_kind` | `dynamic` | — |  |
| `out_name` | `dynamic` | — |  |
| `pos` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9399)

<a id="function-function-mlc-codegen-codegen-expr-emit-extern-out-from-stack-function-emit-extern-out-from-stack-state-abi-ty-stack-off-pos-mlc-codegen-codegen-expr-ml-1941186936"></a>
### _emit_extern_out_from_stack

```ml
function _emit_extern_out_from_stack(state, abi_ty, stack_off, pos)
```

Lower emit extern out from stack expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `abi_ty` | `dynamic` | — |  |
| `stack_off` | `dynamic` | — |  |
| `pos` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9346)

<a id="function-function-mlc-codegen-codegen-expr-emit-extern-ret-from-native-function-emit-extern-ret-from-native-state-abi-ty-fail-label-pos-mlc-codegen-codegen-expr-ml-1961782407"></a>
### _emit_extern_ret_from_native

```ml
function _emit_extern_ret_from_native(state, abi_ty, fail_label, pos)
```

Lower emit extern ret from native expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `abi_ty` | `dynamic` | — |  |
| `fail_label` | `dynamic` | — |  |
| `pos` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9116)

<a id="function-function-mlc-codegen-codegen-expr-emit-generic-call-builtin-cases-function-emit-generic-call-builtin-cases-state-callee-raw-name-call-args-nargs-call-args-base-mlc-codegen-codegen-expr-ml-88256487"></a>
### _emit_generic_call_builtin_cases

```ml
function _emit_generic_call_builtin_cases(state, callee, raw_name, call_args, nargs, call_args_base)
```

Lower emit generic call builtin cases expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `callee` | `dynamic` | — |  |
| `raw_name` | `dynamic` | — |  |
| `call_args` | `dynamic` | — |  |
| `nargs` | `dynamic` | — |  |
| `call_args_base` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L6412)

<a id="function-function-mlc-codegen-codegen-expr-emit-indirect-callable-call-function-emit-indirect-callable-call-state-cal-callee-raw-name-call-args-nargs-call-args-base-skip-call-args-eval-mlc-codegen-codegen-expr-ml-1902005148"></a>
### _emit_indirect_callable_call

```ml
function _emit_indirect_callable_call(state, cal, callee, raw_name, call_args, nargs, call_args_base, skip_call_args_eval)
```

Emit the runtime-tag dispatch shared by first-class and member callables.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `cal` | `dynamic` | — |  |
| `callee` | `dynamic` | — |  |
| `raw_name` | `dynamic` | — |  |
| `call_args` | `dynamic` | — |  |
| `nargs` | `dynamic` | — |  |
| `call_args_base` | `dynamic` | — |  |
| `skip_call_args_eval` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L7705)

<a id="function-function-mlc-codegen-codegen-expr-emit-inline-call-function-emit-inline-call-state-callee-args-mlc-codegen-codegen-expr-ml-2085079347"></a>
### _emit_inline_call

```ml
function _emit_inline_call(state, callee, args)
```

Lower emit inline call expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `callee` | `dynamic` | — |  |
| `args` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9917)

<a id="function-function-mlc-codegen-codegen-expr-emit-known-float-binop-function-emit-known-float-binop-state-expr-mlc-codegen-codegen-expr-ml-840624601"></a>
### _emit_known_float_binop

```ml
function _emit_known_float_binop(state, expr)
```

Lower emit known float binop expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L3180)

<a id="function-function-mlc-codegen-codegen-expr-emit-known-int-binop-function-emit-known-int-binop-state-op-lhs-ok-lhs-const-rhs-ok-rhs-const-mlc-codegen-codegen-expr-ml-1410301729"></a>
### _emit_known_int_binop

```ml
function _emit_known_int_binop(state, op, lhs_ok, lhs_const, rhs_ok, rhs_const)
```

Lower emit known int binop expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `op` | `dynamic` | — |  |
| `lhs_ok` | `dynamic` | — |  |
| `lhs_const` | `dynamic` | — |  |
| `rhs_ok` | `dynamic` | — |  |
| `rhs_const` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2956)

<a id="function-function-mlc-codegen-codegen-expr-emit-make-error-const-function-emit-make-error-const-state-code-message-mlc-codegen-codegen-expr-ml-556272336"></a>
### _emit_make_error_const

```ml
function _emit_make_error_const(state, code, message)
```

Lower emit make error const expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `code` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8866)

<a id="function-function-mlc-codegen-codegen-expr-emit-native-callback-ret-lresult-function-emit-native-callback-ret-lresult-state-l-zero-l-done-mlc-codegen-codegen-expr-ml-1354735082"></a>
### _emit_native_callback_ret_lresult

```ml
function _emit_native_callback_ret_lresult(state, l_zero, l_done)
```

Lower emit native callback ret lresult expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `l_zero` | `dynamic` | — |  |
| `l_done` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L666)

<a id="function-function-mlc-codegen-codegen-expr-emit-native-callback-wndproc-function-emit-native-callback-wndproc-state-fn-qn-mlc-codegen-codegen-expr-ml-1808900834"></a>
### _emit_native_callback_wndproc

```ml
function _emit_native_callback_wndproc(state, fn_qn)
```

Lower emit native callback wndproc expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `fn_qn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L688)

<a id="function-function-mlc-codegen-codegen-expr-emit-native-value-helper-call-function-emit-native-value-helper-call-state-callee-raw-name-call-args-nargs-mlc-codegen-codegen-expr-ml-1858423327"></a>
### _emit_native_value_helper_call

```ml
function _emit_native_value_helper_call(state, callee, raw_name, call_args, nargs)
```

Lower emit native value helper call expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `callee` | `dynamic` | — |  |
| `raw_name` | `dynamic` | — |  |
| `call_args` | `dynamic` | — |  |
| `nargs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L7235)

<a id="function-function-mlc-codegen-codegen-expr-emit-operator-overload-function-emit-operator-overload-state-op-symbol-operands-node-mlc-codegen-codegen-expr-ml-1607236390"></a>
### _emit_operator_overload

```ml
function _emit_operator_overload(state, op_symbol, operands, node)
```

Emit a resolved operator through the ordinary direct-call/inlining path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `op_symbol` | `dynamic` | — |  |
| `operands` | `dynamic` | — |  |
| `node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2695)

<a id="function-function-mlc-codegen-codegen-expr-emit-std-math-roundlike-intrinsic-function-emit-std-math-roundlike-intrinsic-state-callee-name-arg-mlc-codegen-codegen-expr-ml-983075872"></a>
### _emit_std_math_roundlike_intrinsic

```ml
function _emit_std_math_roundlike_intrinsic(state, callee_name, arg)
```

Lower emit std math roundlike intrinsic expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `callee_name` | `dynamic` | — |  |
| `arg` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1419)

<a id="function-function-mlc-codegen-codegen-expr-emit-struct-field-index-dispatch-function-emit-struct-field-index-dispatch-state-field-struct-id-reg-out-reg-ok-label-fail-label-tag-mlc-codegen-codegen-expr-ml-1144660167"></a>
### _emit_struct_field_index_dispatch

```ml
function _emit_struct_field_index_dispatch(state, field, struct_id_reg, out_reg, ok_label, fail_label, tag)
```

Lower emit struct field index dispatch expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `field` | `dynamic` | — |  |
| `struct_id_reg` | `dynamic` | — |  |
| `out_reg` | `dynamic` | — |  |
| `ok_label` | `dynamic` | — |  |
| `fail_label` | `dynamic` | — |  |
| `tag` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1082)

<a id="function-function-mlc-codegen-codegen-expr-expr-has-this-function-expr-has-this-ex-mlc-codegen-codegen-expr-ml-920096598"></a>
### _expr_has_this

```ml
function _expr_has_this(ex)
```

Lower expr has this expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8583)

<a id="function-function-mlc-codegen-codegen-expr-expr-heap-cfg-bool-function-expr-heap-cfg-bool-state-key-defaultv-mlc-codegen-codegen-expr-ml-1543416824"></a>
### _expr_heap_cfg_bool

```ml
function _expr_heap_cfg_bool(state, key, defaultv)
```

Lower expr heap cfg bool expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L7360)

<a id="function-function-mlc-codegen-codegen-expr-expr-to-qualname-function-expr-to-qualname-state-expr-mlc-codegen-codegen-expr-ml-757175447"></a>
### _expr_to_qualname

```ml
function _expr_to_qualname(state, expr)
```

Lower expr to qualname expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1034)

<a id="function-function-mlc-codegen-codegen-expr-extern-dll-base-function-extern-dll-base-dll-is-linux-mlc-codegen-codegen-expr-ml-205980928"></a>
### _extern_dll_base

```ml
function _extern_dll_base(dll, is_linux)
```

Lower extern dll base expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dll` | `dynamic` | — |  |
| `is_linux` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8843)

<a id="function-function-mlc-codegen-codegen-expr-extern-iat-label-function-extern-iat-label-dll-sym-is-linux-mlc-codegen-codegen-expr-ml-590011265"></a>
### _extern_iat_label

```ml
function _extern_iat_label(dll, sym, is_linux)
```

Lower extern iat label expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dll` | `dynamic` | — |  |
| `sym` | `dynamic` | — |  |
| `is_linux` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8860)

<a id="function-function-mlc-codegen-codegen-expr-extern-sig-get-function-extern-sig-get-state-qname-mlc-codegen-codegen-expr-ml-218103376"></a>
### _extern_sig_get

```ml
function _extern_sig_get(state, qname)
```

Lower extern sig get expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1062)

<a id="function-function-mlc-codegen-codegen-expr-extern-struct-get-function-extern-struct-get-state-qname-mlc-codegen-codegen-expr-ml-689162256"></a>
### _extern_struct_get

```ml
function _extern_struct_get(state, qname)
```

Lower extern struct get expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1515)

<a id="function-function-mlc-codegen-codegen-expr-filter-expr-list-separator-artifacts-function-filter-expr-list-separator-artifacts-items-mlc-codegen-codegen-expr-ml-1341294507"></a>
### _filter_expr_list_separator_artifacts

```ml
function _filter_expr_list_separator_artifacts(items)
```

Lower filter expr list separator artifacts expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1539)

<a id="function-function-mlc-codegen-codegen-expr-fn-uses-this-function-fn-uses-this-fn-node-mlc-codegen-codegen-expr-ml-1106344302"></a>
### _fn_uses_this

```ml
function _fn_uses_this(fn_node)
```

Lower fn uses this expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fn_node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8782)

<a id="function-function-mlc-codegen-codegen-expr-function-wants-inline-function-function-wants-inline-fn-mlc-codegen-codegen-expr-ml-476633721"></a>
### _function_wants_inline

```ml
function _function_wants_inline(fn)
```

Lower function wants inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9844)

<a id="function-function-mlc-codegen-codegen-expr-has-any-global-prefix-function-has-any-global-prefix-state-base-mlc-codegen-codegen-expr-ml-1707511383"></a>
### _has_any_global_prefix

```ml
function _has_any_global_prefix(state, base)
```

Reports whether has any global prefix.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `base` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L478)

<a id="function-function-mlc-codegen-codegen-expr-has-global-prefix-function-has-global-prefix-state-name-mlc-codegen-codegen-expr-ml-237481325"></a>
### _has_global_prefix

```ml
function _has_global_prefix(state, name)
```

Reports whether has global prefix.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8532)

<a id="function-function-mlc-codegen-codegen-expr-inline-call-eligible-function-inline-call-eligible-fn-mlc-codegen-codegen-expr-ml-1842661879"></a>
### _inline_call_eligible

```ml
function _inline_call_eligible(fn)
```

Lower inline call eligible expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9902)

<a id="function-function-mlc-codegen-codegen-expr-inline-collect-expr-stats-function-inline-collect-expr-stats-ex-stats-mlc-codegen-codegen-expr-ml-986013263"></a>
### _inline_collect_expr_stats

```ml
function _inline_collect_expr_stats(ex, stats)
```

Lower inline collect expr stats expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |
| `stats` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9714)

<a id="function-function-mlc-codegen-codegen-expr-inline-collect-stmt-list-stats-function-inline-collect-stmt-list-stats-stmts-stats-mlc-codegen-codegen-expr-ml-2145714289"></a>
### _inline_collect_stmt_list_stats

```ml
function _inline_collect_stmt_list_stats(stmts, stats)
```

Lower inline collect stmt list stats expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stmts` | `dynamic` | — |  |
| `stats` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9751)

<a id="function-function-mlc-codegen-codegen-expr-inline-collect-stmt-stats-function-inline-collect-stmt-stats-st-stats-mlc-codegen-codegen-expr-ml-217400541"></a>
### _inline_collect_stmt_stats

```ml
function _inline_collect_stmt_stats(st, stats)
```

Lower inline collect stmt stats expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |
| `stats` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9762)

<a id="function-function-mlc-codegen-codegen-expr-inline-declared-type-fact-function-inline-declared-type-fact-state-raw-type-mlc-codegen-codegen-expr-ml-1670431225"></a>
### _inline_declared_type_fact

```ml
function _inline_declared_type_fact(state, raw_type)
```

Lower inline declared type fact expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `raw_type` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9888)

<a id="function-function-mlc-codegen-codegen-expr-intflow-name-has-function-intflow-name-has-arr-name-mlc-codegen-codegen-expr-ml-326076909"></a>
### _intflow_name_has

```ml
function _intflow_name_has(arr, name)
```

Lower intflow name has expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2498)

<a id="function-function-mlc-codegen-codegen-expr-is-current-localish-name-function-is-current-localish-name-state-name-mlc-codegen-codegen-expr-ml-1422143"></a>
### _is_current_localish_name

```ml
function _is_current_localish_name(state, name)
```

Reports whether is current localish name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L832)

<a id="function-function-mlc-codegen-codegen-expr-is-expr-list-separator-artifact-function-is-expr-list-separator-artifact-ex-mlc-codegen-codegen-expr-ml-1185540350"></a>
### _is_expr_list_separator_artifact

```ml
function _is_expr_list_separator_artifact(ex)
```

Reports whether is expr list separator artifact.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1527)

<a id="function-function-mlc-codegen-codegen-expr-is-instance-method-qname-function-is-instance-method-qname-state-qname-mlc-codegen-codegen-expr-ml-1989414416"></a>
### _is_instance_method_qname

```ml
function _is_instance_method_qname(state, qname)
```

Reports whether is instance method qname.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8542)

<a id="function-function-mlc-codegen-codegen-expr-is-int-no-bool-inline-function-is-int-no-bool-v-mlc-codegen-codegen-expr-ml-1740716338"></a>
### _is_int_no_bool

```ml
inline function _is_int_no_bool(v)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L298)

<a id="function-function-mlc-codegen-codegen-expr-is-number-no-bool-inline-function-is-number-no-bool-v-mlc-codegen-codegen-expr-ml-617520384"></a>
### _is_number_no_bool

```ml
inline function _is_number_no_bool(v)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L290)

<a id="function-function-mlc-codegen-codegen-expr-member-base-alias-shadowed-function-member-base-alias-shadowed-state-expr-mlc-codegen-codegen-expr-ml-530020817"></a>
### _member_base_alias_shadowed

```ml
function _member_base_alias_shadowed(state, expr)
```

Lower member base alias shadowed expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L859)

<a id="function-function-mlc-codegen-codegen-expr-method-map-get-inline-function-method-map-get-map-arr-method-name-mlc-codegen-codegen-expr-ml-1123945021"></a>
### _method_map_get

```ml
inline function _method_map_get(map_arr, method_name)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map_arr` | `dynamic` | — |  |
| `method_name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L436)

<a id="function-function-mlc-codegen-codegen-expr-named-array-get-inline-function-named-array-get-arr-key-mlc-codegen-codegen-expr-ml-1881086926"></a>
### _named_array_get

```ml
inline function _named_array_get(arr, key)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L320)

<a id="function-function-mlc-codegen-codegen-expr-named-int-get-inline-function-named-int-get-arr-key-defaultv-mlc-codegen-codegen-expr-ml-696397625"></a>
### _named_int_get

```ml
inline function _named_int_get(arr, key, defaultv)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L336)

<a id="function-function-mlc-codegen-codegen-expr-native-callback-resolve-user-fn-function-native-callback-resolve-user-fn-state-ex-mlc-codegen-codegen-expr-ml-2104517683"></a>
### _native_callback_resolve_user_fn

```ml
function _native_callback_resolve_user_fn(state, ex)
```

Lower native callback resolve user fn expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L648)

<a id="function-function-mlc-codegen-codegen-expr-next-lid-inline-function-next-lid-state-mlc-codegen-codegen-expr-ml-1245044263"></a>
### _next_lid

```ml
inline function _next_lid(state)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L640)

<a id="function-function-mlc-codegen-codegen-expr-normalize-declared-call-args-function-normalize-declared-call-args-expr-fn-implicit-mlc-codegen-codegen-expr-ml-715104241"></a>
### _normalize_declared_call_args

```ml
function _normalize_declared_call_args(expr, fn, implicit)
```

Lower normalize declared call args expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expr` | `dynamic` | — |  |
| `fn` | `dynamic` | — |  |
| `implicit` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L190)

<a id="function-function-mlc-codegen-codegen-expr-operator-declared-type-fact-function-operator-declared-type-fact-state-raw-type-owner-qname-node-mlc-codegen-codegen-expr-ml-573527031"></a>
### _operator_declared_type_fact

```ml
function _operator_declared_type_fact(state, raw_type, owner_qname, node)
```

Convert a declared operator type into the optimizer's canonical type fact.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `raw_type` | `dynamic` | — |  |
| `owner_qname` | `dynamic` | — |  |
| `node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2603)

<a id="function-function-mlc-codegen-codegen-expr-opt-const-nonnegative-int-function-opt-const-nonnegative-int-state-ex-mlc-codegen-codegen-expr-ml-1783933275"></a>
### _opt_const_nonnegative_int

```ml
function _opt_const_nonnegative_int(state, ex)
```

Lower opt const nonnegative int expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2518)

<a id="function-function-mlc-codegen-codegen-expr-opt-const-nonzero-number-function-opt-const-nonzero-number-state-ex-mlc-codegen-codegen-expr-ml-692147035"></a>
### _opt_const_nonzero_number

```ml
function _opt_const_nonzero_number(state, ex)
```

Lower opt const nonzero number expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2509)

<a id="function-function-mlc-codegen-codegen-expr-opt-emit-const-value-function-opt-emit-const-value-state-value-mlc-codegen-codegen-expr-ml-1769433631"></a>
### _opt_emit_const_value

```ml
function _opt_emit_const_value(state, value)
```

Lower opt emit const value expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L10122)

<a id="function-function-mlc-codegen-codegen-expr-opt-emit-known-index-function-opt-emit-known-index-state-expr-plan-mlc-codegen-codegen-expr-ml-370978738"></a>
### _opt_emit_known_index

```ml
function _opt_emit_known_index(state, expr, plan)
```

Lower opt emit known index expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |
| `plan` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2855)

<a id="function-function-mlc-codegen-codegen-expr-opt-expr-known-int-function-opt-expr-known-int-state-ex-mlc-codegen-codegen-expr-ml-1139113643"></a>
### _opt_expr_known_int

```ml
function _opt_expr_known_int(state, ex)
```

Lower opt expr known int expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2525)

<a id="function-function-mlc-codegen-codegen-expr-opt-expr-known-type-function-opt-expr-known-type-state-ex-mlc-codegen-codegen-expr-ml-1657401667"></a>
### _opt_expr_known_type

```ml
function _opt_expr_known_type(state, ex)
```

Lower opt expr known type expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2709)

<a id="function-function-mlc-codegen-codegen-expr-opt-known-index-plan-function-opt-known-index-plan-state-ex-mlc-codegen-codegen-expr-ml-274133085"></a>
### _opt_known_index_plan

```ml
function _opt_known_index_plan(state, ex)
```

Lower opt known index plan expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2807)

<a id="function-function-mlc-codegen-codegen-expr-opt-truthy-inline-function-opt-truthy-v-mlc-codegen-codegen-expr-ml-510391714"></a>
### _opt_truthy

```ml
inline function _opt_truthy(v)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L277)

<a id="function-function-mlc-codegen-codegen-expr-opt-try-const-immediate-encoded-function-opt-try-const-immediate-encoded-state-expr-mlc-codegen-codegen-expr-ml-2129065573"></a>
### _opt_try_const_immediate_encoded

```ml
function _opt_try_const_immediate_encoded(state, expr)
```

Lower opt try const immediate encoded expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1322)

<a id="function-function-mlc-codegen-codegen-expr-opt-try-const-value-function-opt-try-const-value-state-ex-mlc-codegen-codegen-expr-ml-2030503603"></a>
### _opt_try_const_value

```ml
function _opt_try_const_value(state, ex)
```

Lower opt try const value expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L10116)

<a id="function-function-mlc-codegen-codegen-expr-opt-try-known-type-label-function-opt-try-known-type-label-state-expr-detailed-mlc-codegen-codegen-expr-ml-385000701"></a>
### _opt_try_known_type_label

```ml
function _opt_try_known_type_label(state, expr, detailed)
```

Lower opt try known type label expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |
| `detailed` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1354)

<a id="function-function-mlc-codegen-codegen-expr-opt-try-pure-const-array-len-function-opt-try-pure-const-array-len-state-expr-mlc-codegen-codegen-expr-ml-2032552391"></a>
### _opt_try_pure_const_array_len

```ml
function _opt_try_pure_const_array_len(state, expr)
```

Lower opt try pure const array len expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1339)

<a id="function-function-mlc-codegen-codegen-expr-opt-type-base-inline-function-opt-type-base-type-name-mlc-codegen-codegen-expr-ml-347057446"></a>
### _opt_type_base

```ml
inline function _opt_type_base(type_name)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `type_name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2560)

<a id="function-function-mlc-codegen-codegen-expr-opt-type-exact-length-function-opt-type-exact-length-type-name-mlc-codegen-codegen-expr-ml-513702245"></a>
### _opt_type_exact_length

```ml
function _opt_type_exact_length(type_name)
```

Lower opt type exact length expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `type_name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2570)

<a id="function-function-mlc-codegen-codegen-expr-opt-type-fact-get-function-opt-type-fact-get-items-name-mlc-codegen-codegen-expr-ml-857455814"></a>
### _opt_type_fact_get

```ml
function _opt_type_fact_get(items, name)
```

Lower opt type fact get expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2587)

<a id="function-function-mlc-codegen-codegen-expr-opt-type-query-can-elide-evaluation-function-opt-type-query-can-elide-evaluation-ex-mlc-codegen-codegen-expr-ml-81004822"></a>
### _opt_type_query_can_elide_evaluation

```ml
function _opt_type_query_can_elide_evaluation(ex)
```

Lower opt type query can elide evaluation expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2799)

<a id="function-function-mlc-codegen-codegen-expr-pool-collect-suffix-function-pool-collect-suffix-pool-prefix-suffix-matches-mlc-codegen-codegen-expr-ml-241897643"></a>
### _pool_collect_suffix

```ml
function _pool_collect_suffix(pool, prefix, suffix, matches)
```

Append unique qualified names whose package prefix and final component match.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pool` | `dynamic` | — | Static symbol pool containing `[qualifiedName, value]` entries. |
| `prefix` | `dynamic` | — | Required package prefix. |
| `suffix` | `dynamic` | — | Required dotted final component. |
| `matches` | `dynamic` | — | Matches already collected from preceding pools. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L900)

<a id="function-function-mlc-codegen-codegen-expr-pool-has-key-function-pool-has-key-pool-key-mlc-codegen-codegen-expr-ml-1833225956"></a>
### _pool_has_key

```ml
function _pool_has_key(pool, key)
```

Lower pool has key expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pool` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L883)

<a id="function-function-mlc-codegen-codegen-expr-positive-power-of-two-shift-function-positive-power-of-two-shift-value-mlc-codegen-codegen-expr-ml-1591859408"></a>
### _positive_power_of_two_shift

```ml
function _positive_power_of_two_shift(value)
```

Return log2(value), or -1 when value is not a positive power of two.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2942)

<a id="function-function-mlc-codegen-codegen-expr-qname-exists-function-qname-exists-state-qname-mlc-codegen-codegen-expr-ml-11489112"></a>
### _qname_exists

```ml
function _qname_exists(state, qname)
```

Lower qname exists expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8520)

<a id="function-function-mlc-codegen-codegen-expr-qname-of-function-qname-of-state-ex-mlc-codegen-codegen-expr-ml-265331533"></a>
### _qname_of

```ml
function _qname_of(state, ex)
```

Lower qname of expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8351)

<a id="function-function-mlc-codegen-codegen-expr-qname-parts-function-qname-parts-state-ex-mlc-codegen-codegen-expr-ml-617631291"></a>
### _qname_parts

```ml
function _qname_parts(state, ex)
```

Lower qname parts expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8343)

<a id="function-function-mlc-codegen-codegen-expr-qname-parts-any-function-qname-parts-any-expr-mlc-codegen-codegen-expr-ml-1463872372"></a>
### _qname_parts_any

```ml
function _qname_parts_any(expr)
```

Lower qname parts any expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1395)

<a id="function-function-mlc-codegen-codegen-expr-qname-with-prefixes-function-qname-with-prefixes-state-qname-mlc-codegen-codegen-expr-ml-130025352"></a>
### _qname_with_prefixes

```ml
function _qname_with_prefixes(state, qname)
```

Lower qname with prefixes expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8480)

<a id="function-function-mlc-codegen-codegen-expr-qualify-dotted-function-qualify-dotted-state-name-mlc-codegen-codegen-expr-ml-2130487099"></a>
### _qualify_dotted

```ml
function _qualify_dotted(state, name)
```

Lower qualify dotted expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8514)

<a id="function-function-mlc-codegen-codegen-expr-qualify-identifier-function-qualify-identifier-state-name-mlc-codegen-codegen-expr-ml-1704406085"></a>
### _qualify_identifier

```ml
function _qualify_identifier(state, name)
```

Resolve a source identifier against lexical bindings, aliases and static symbol pools.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Current code-generation state and qualification caches. |
| `name` | `dynamic` | — | Source identifier to qualify. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L928)

<a id="function-function-mlc-codegen-codegen-expr-resolve-const-value-function-resolve-const-value-state-name-mlc-codegen-codegen-expr-ml-1736193677"></a>
### _resolve_const_value

```ml
function _resolve_const_value(state, name)
```

Lower resolve const value expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1152)

<a id="function-function-mlc-codegen-codegen-expr-resolve-operator-overload-function-resolve-operator-overload-state-op-symbol-operands-node-strict-mlc-codegen-codegen-expr-ml-1017853369"></a>
### _resolve_operator_overload

```ml
function _resolve_operator_overload(state, op_symbol, operands, node, strict)
```

Resolve an operator using the emission-time facts for its operand ASTs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `op_symbol` | `dynamic` | — |  |
| `operands` | `dynamic` | — |  |
| `node` | `dynamic` | — |  |
| `strict` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2684)

<a id="function-function-mlc-codegen-codegen-expr-resolve-operator-overload-facts-function-resolve-operator-overload-facts-state-op-symbol-facts-node-strict-mlc-codegen-codegen-expr-ml-737130842"></a>
### _resolve_operator_overload_facts

```ml
function _resolve_operator_overload_facts(state, op_symbol, facts, node, strict)
```

Resolve a statically typed struct operator from precomputed flow facts.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `op_symbol` | `dynamic` | — |  |
| `facts` | `dynamic` | — |  |
| `node` | `dynamic` | — |  |
| `strict` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2628)

<a id="function-function-mlc-codegen-codegen-expr-state-enum-id-get-inline-function-state-enum-id-get-state-key-defaultv-mlc-codegen-codegen-expr-ml-1848184787"></a>
### _state_enum_id_get

```ml
inline function _state_enum_id_get(state, key, defaultv)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L364)

<a id="function-function-mlc-codegen-codegen-expr-state-enum-variants-get-inline-function-state-enum-variants-get-state-key-mlc-codegen-codegen-expr-ml-562053330"></a>
### _state_enum_variants_get

```ml
inline function _state_enum_variants_get(state, key)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L401)

<a id="function-function-mlc-codegen-codegen-expr-state-named-array-get-inline-function-state-named-array-get-index-map-arr-key-mlc-codegen-codegen-expr-ml-1817475941"></a>
### _state_named_array_get

```ml
inline function _state_named_array_get(index_map, arr, key)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index_map` | `dynamic` | — |  |
| `arr` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L374)

<a id="function-function-mlc-codegen-codegen-expr-state-struct-field-types-get-inline-function-state-struct-field-types-get-state-key-mlc-codegen-codegen-expr-ml-1860069308"></a>
### _state_struct_field_types_get

```ml
inline function _state_struct_field_types_get(state, key)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L389)

<a id="function-function-mlc-codegen-codegen-expr-state-struct-fields-get-inline-function-state-struct-fields-get-state-key-mlc-codegen-codegen-expr-ml-1661443136"></a>
### _state_struct_fields_get

```ml
inline function _state_struct_fields_get(state, key)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L383)

<a id="function-function-mlc-codegen-codegen-expr-state-struct-id-get-inline-function-state-struct-id-get-state-key-defaultv-mlc-codegen-codegen-expr-ml-607185971"></a>
### _state_struct_id_get

```ml
inline function _state_struct_id_get(state, key, defaultv)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L354)

<a id="function-function-mlc-codegen-codegen-expr-state-struct-methods-get-inline-function-state-struct-methods-get-state-key-mlc-codegen-codegen-expr-ml-1640907056"></a>
### _state_struct_methods_get

```ml
inline function _state_struct_methods_get(state, key)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L395)

<a id="function-function-mlc-codegen-codegen-expr-state-struct-static-methods-get-inline-function-state-struct-static-methods-get-state-key-mlc-codegen-codegen-expr-ml-644259028"></a>
### _state_struct_static_methods_get

```ml
inline function _state_struct_static_methods_get(state, key)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L407)

<a id="function-function-mlc-codegen-codegen-expr-stmt-has-this-function-stmt-has-this-st-mlc-codegen-codegen-expr-ml-1440660948"></a>
### _stmt_has_this

```ml
function _stmt_has_this(st)
```

Lower stmt has this expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8640)

<a id="function-function-mlc-codegen-codegen-expr-strpair-get-inline-function-strpair-get-arr-key-mlc-codegen-codegen-expr-ml-1442572622"></a>
### _strpair_get

```ml
inline function _strpair_get(arr, key)
```

Lower inline expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L413)

<a id="function-function-mlc-codegen-codegen-expr-try-const-bin-function-try-const-bin-op-lv-rv-mlc-codegen-codegen-expr-ml-847450350"></a>
### _try_const_bin

```ml
function _try_const_bin(op, lv, rv)
```

Lower try const bin expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `op` | `dynamic` | — |  |
| `lv` | `dynamic` | — |  |
| `rv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1168)

<a id="function-function-mlc-codegen-codegen-expr-try-emit-direct-extern-call-function-try-emit-direct-extern-call-state-cal-callee-raw-name-call-args-nargs-mlc-codegen-codegen-expr-ml-1409846107"></a>
### _try_emit_direct_extern_call

```ml
function _try_emit_direct_extern_call(state, cal, callee, raw_name, call_args, nargs)
```

Try the shortened extern-call form that supplies omitted trailing `out` arguments.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `cal` | `dynamic` | — |  |
| `callee` | `dynamic` | — |  |
| `raw_name` | `dynamic` | — |  |
| `call_args` | `dynamic` | — |  |
| `nargs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L7665)

<a id="function-function-mlc-codegen-codegen-expr-user-function-get-function-user-function-get-state-qname-mlc-codegen-codegen-expr-ml-1226066976"></a>
### _user_function_get

```ml
function _user_function_get(state, qname)
```

Lower user function get expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L457)

<a id="function-function-mlc-codegen-codegen-expr-variadic-expr-safe-function-variadic-expr-safe-ex-name-allow-direct-mlc-codegen-codegen-expr-ml-1955139858"></a>
### _variadic_expr_safe

```ml
function _variadic_expr_safe(ex, name, allow_direct)
```

Lower variadic expr safe expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `allow_direct` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L78)

<a id="function-function-mlc-codegen-codegen-expr-variadic-is-direct-var-function-variadic-is-direct-var-ex-name-mlc-codegen-codegen-expr-ml-1449843501"></a>
### _variadic_is_direct_var

```ml
function _variadic_is_direct_var(ex, name)
```

Lower variadic is direct var expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L72)

<a id="function-function-mlc-codegen-codegen-expr-variadic-param-stack-safe-function-variadic-param-stack-safe-fn-mlc-codegen-codegen-expr-ml-1579967441"></a>
### _variadic_param_stack_safe

```ml
function _variadic_param_stack_safe(fn)
```

Lower variadic param stack safe expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L174)

<a id="function-function-mlc-codegen-codegen-expr-variadic-stmts-safe-function-variadic-stmts-safe-body-name-mlc-codegen-codegen-expr-ml-547146716"></a>
### _variadic_stmts_safe

```ml
function _variadic_stmts_safe(body, name)
```

Lower variadic stmts safe expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `body` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L127)

- [mlc.codegen.codegen_expr.ArgNormalizeResult](Type-mlc-codegen-codegen-expr-argnormalizeresult-1648891655.md) — struct
<a id="function-function-mlc-codegen-codegen-expr-cg-emit-expr-function-cg-emit-expr-state-expr-mlc-codegen-codegen-expr-ml-1314099505"></a>
### cg_emit_expr

```ml
function cg_emit_expr(state, expr)
```

Lower cg emit expr expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `expr` | `dynamic` | — | Value supplied for `expr`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1559)

<a id="function-function-mlc-codegen-codegen-expr-cg-expr-try-const-decl-value-function-cg-expr-try-const-decl-value-state-expr-mlc-codegen-codegen-expr-ml-579064845"></a>
### cg_expr_try_const_decl_value

```ml
function cg_expr_try_const_decl_value(state, expr)
```

Lower cg expr try const decl value expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `expr` | `dynamic` | — | Value supplied for `expr`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1508)

<a id="function-function-mlc-codegen-codegen-expr-cg-expr-try-const-value-function-cg-expr-try-const-value-state-expr-mlc-codegen-codegen-expr-ml-300093649"></a>
### cg_expr_try_const_value

```ml
function cg_expr_try_const_value(state, expr)
```

Lower cg expr try const value expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `expr` | `dynamic` | — | Value supplied for `expr`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1500)

- [mlc.codegen.codegen_expr.ConstEvalResult](Type-mlc-codegen-codegen-expr-constevalresult-1651772175.md) — struct
<a id="function-function-mlc-codegen-codegen-expr-emit-expr-function-emit-expr-state-ex-mlc-codegen-codegen-expr-ml-1588049625"></a>
### emit_expr

```ml
function emit_expr(state, ex)
```

Lower emit expr expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `ex` | `dynamic` | — | Value supplied for `ex`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L10175)

<a id="function-function-mlc-codegen-codegen-expr-emit-extern-stubs-function-emit-extern-stubs-state-mlc-codegen-codegen-expr-ml-162750204"></a>
### emit_extern_stubs

```ml
function emit_extern_stubs(state)
```

Lower emit extern stubs expression behavior to native x64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L10181)

- [mlc.codegen.codegen_expr.InlineStats](Type-mlc-codegen-codegen-expr-inlinestats-1176616483.md) — struct
