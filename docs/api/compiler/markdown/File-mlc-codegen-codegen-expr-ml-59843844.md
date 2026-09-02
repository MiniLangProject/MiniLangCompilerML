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


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8647)

<a id="function-function-mlc-codegen-codegen-expr-abi-ty-to-str-function-abi-ty-to-str-abi-ty-mlc-codegen-codegen-expr-ml-673719793"></a>
### _abi_ty_to_str

```ml
function _abi_ty_to_str(abi_ty)
```

Compatibility wrappers (Python CodegenExpr parity).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `abi_ty` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8127)

<a id="function-function-mlc-codegen-codegen-expr-alias-lookup-inline-function-alias-lookup-alias-map-key-mlc-codegen-codegen-expr-ml-837732516"></a>
### _alias_lookup

```ml
inline function _alias_lookup(alias_map, key)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `alias_map` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L751)

<a id="function-function-mlc-codegen-codegen-expr-alias-lookup-array-exact-inline-function-alias-lookup-array-exact-alias-map-key-mlc-codegen-codegen-expr-ml-108088364"></a>
### _alias_lookup_array_exact

```ml
inline function _alias_lookup_array_exact(alias_map, key)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `alias_map` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L769)

<a id="function-function-mlc-codegen-codegen-expr-alias-target-for-base-function-alias-target-for-base-state-base-mlc-codegen-codegen-expr-ml-677820043"></a>
### _alias_target_for_base

```ml
function _alias_target_for_base(state, base)
```

Implements alias target for base.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `base` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L837)

<a id="function-function-mlc-codegen-codegen-expr-apply-import-alias-function-apply-import-alias-state-qname-mlc-codegen-codegen-expr-ml-318875280"></a>
### _apply_import_alias

```ml
function _apply_import_alias(state, qname)
```

Implements apply import alias.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L782)

<a id="function-function-mlc-codegen-codegen-expr-arr-has-str-inline-function-arr-has-str-arr-value-mlc-codegen-codegen-expr-ml-1249794348"></a>
### _arr_has_str

```ml
inline function _arr_has_str(arr, value)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L816)

<a id="function-function-mlc-codegen-codegen-expr-builtin-label-inline-function-builtin-label-name-mlc-codegen-codegen-expr-ml-1717663613"></a>
### _builtin_label

```ml
inline function _builtin_label(name)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L578)

<a id="function-function-mlc-codegen-codegen-expr-call-args-have-stack-variadic-function-call-args-have-stack-variadic-args-mlc-codegen-codegen-expr-ml-1023336562"></a>
### _call_args_have_stack_variadic

```ml
function _call_args_have_stack_variadic(args)
```

Implements call args have stack variadic.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9673)

<a id="function-function-mlc-codegen-codegen-expr-cg-expr-try-const-value-function-cg-expr-try-const-value-state-expr-preserve-unary-float-mlc-codegen-codegen-expr-ml-27667210"></a>
### _cg_expr_try_const_value

```ml
function _cg_expr_try_const_value(state, expr, preserve_unary_float)
```

Implements cg expr try const value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |
| `preserve_unary_float` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1218)

<a id="function-function-mlc-codegen-codegen-expr-coerce-name-inline-function-coerce-name-v-mlc-codegen-codegen-expr-ml-2073764020"></a>
### _coerce_name

```ml
inline function _coerce_name(v)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L298)

<a id="function-function-mlc-codegen-codegen-expr-compile-symbol-has-inline-function-compile-symbol-has-state-key-mlc-codegen-codegen-expr-ml-1426967752"></a>
### _compile_symbol_has

```ml
inline function _compile_symbol_has(state, key)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L567)

<a id="function-function-mlc-codegen-codegen-expr-contains-nested-fn-function-contains-nested-fn-node-mlc-codegen-codegen-expr-ml-757988883"></a>
### _contains_nested_fn

```ml
function _contains_nested_fn(node)
```

Reports whether contains nested fn.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8596)

<a id="function-function-mlc-codegen-codegen-expr-direct-user-call-enabled-function-direct-user-call-enabled-state-qname-mlc-codegen-codegen-expr-ml-954144962"></a>
### _direct_user_call_enabled

```ml
function _direct_user_call_enabled(state, qname)
```

Implements direct user call enabled.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L7193)

<a id="function-function-mlc-codegen-codegen-expr-emit-auto-errprop-function-emit-auto-errprop-state-mlc-codegen-codegen-expr-ml-1427208816"></a>
### _emit_auto_errprop

```ml
function _emit_auto_errprop(state)
```

Runs emit auto errprop.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8704)

<a id="function-function-mlc-codegen-codegen-expr-emit-auto-errprop-cold-block-function-emit-auto-errprop-cold-block-state-mlc-codegen-codegen-expr-ml-2016839500"></a>
### _emit_auto_errprop_cold_block

```ml
function _emit_auto_errprop_cold_block(state)
```

Runs emit auto errprop cold block.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8753)

<a id="function-function-mlc-codegen-codegen-expr-emit-call-args-eval-recursive-function-emit-call-args-eval-recursive-state-call-args-idx-nargs-base-off-mlc-codegen-codegen-expr-ml-103569979"></a>
### _emit_call_args_eval_recursive

```ml
function _emit_call_args_eval_recursive(state, call_args, idx, nargs, base_off)
```

Runs emit call args eval recursive.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `call_args` | `dynamic` | — |  |
| `idx` | `dynamic` | — |  |
| `nargs` | `dynamic` | — |  |
| `base_off` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9951)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-array-lit-function-emit-expr-array-lit-state-expr-mlc-codegen-codegen-expr-ml-1916635897"></a>
### _emit_expr_array_lit

```ml
function _emit_expr_array_lit(state, expr)
```

Runs emit expr array lit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8031)

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


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L3081)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-bool-function-emit-expr-bool-state-expr-mlc-codegen-codegen-expr-ml-1473250299"></a>
### _emit_expr_bool

```ml
function _emit_expr_bool(state, expr)
```

Runs emit expr bool.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1748)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-call-function-emit-expr-call-state-expr-mlc-codegen-codegen-expr-ml-1220291383"></a>
### _emit_expr_call

```ml
function _emit_expr_call(state, expr)
```

Runs emit expr call.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L4340)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-call-early-builtins-function-emit-expr-call-early-builtins-state-callee-raw-name-call-args-nargs-mlc-codegen-codegen-expr-ml-1199270435"></a>
### _emit_expr_call_early_builtins

```ml
function _emit_expr_call_early_builtins(state, callee, raw_name, call_args, nargs)
```

Runs emit expr call early builtins.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `callee` | `dynamic` | — |  |
| `raw_name` | `dynamic` | — |  |
| `call_args` | `dynamic` | — |  |
| `nargs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L5032)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-call-generic-function-emit-expr-call-generic-state-cal-callee-raw-name-call-args-nargs-member-runtime-mlc-codegen-codegen-expr-ml-1620748138"></a>
### _emit_expr_call_generic

```ml
function _emit_expr_call_generic(state, cal, callee, raw_name, call_args, nargs, member_runtime)
```

Runs emit expr call generic.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `cal` | `dynamic` | — |  |
| `callee` | `dynamic` | — |  |
| `raw_name` | `dynamic` | — |  |
| `call_args` | `dynamic` | — |  |
| `nargs` | `dynamic` | — |  |
| `member_runtime` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L7202)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-coalesce-function-emit-expr-coalesce-state-expr-mlc-codegen-codegen-expr-ml-825042161"></a>
### _emit_expr_coalesce

```ml
function _emit_expr_coalesce(state, expr)
```

Runs emit expr coalesce.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1617)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-index-function-emit-expr-index-state-expr-mlc-codegen-codegen-expr-ml-871640929"></a>
### _emit_expr_index

```ml
function _emit_expr_index(state, expr)
```

Runs emit expr index.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2170)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-is-type-function-emit-expr-is-type-state-expr-mlc-codegen-codegen-expr-ml-359244241"></a>
### _emit_expr_is_type

```ml
function _emit_expr_is_type(state, expr)
```

Runs emit expr is type.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1771)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-member-function-emit-expr-member-state-expr-mlc-codegen-codegen-expr-ml-911124331"></a>
### _emit_expr_member

```ml
function _emit_expr_member(state, expr)
```

Runs emit expr member.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1992)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-num-function-emit-expr-num-state-expr-mlc-codegen-codegen-expr-ml-1983028885"></a>
### _emit_expr_num

```ml
function _emit_expr_num(state, expr)
```

Runs emit expr num.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1725)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-safe-call-function-emit-expr-safe-call-state-expr-mlc-codegen-codegen-expr-ml-1000404641"></a>
### _emit_expr_safe_call

```ml
function _emit_expr_safe_call(state, expr)
```

Runs emit expr safe call.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1652)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-safe-member-function-emit-expr-safe-member-state-expr-mlc-codegen-codegen-expr-ml-1807199021"></a>
### _emit_expr_safe_member

```ml
function _emit_expr_safe_member(state, expr)
```

Runs emit expr safe member.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1630)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-str-function-emit-expr-str-state-expr-mlc-codegen-codegen-expr-ml-1516643885"></a>
### _emit_expr_str

```ml
function _emit_expr_str(state, expr)
```

Runs emit expr str.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1755)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-type-guard-function-emit-expr-type-guard-state-expr-mlc-codegen-codegen-expr-ml-555431059"></a>
### _emit_expr_type_guard

```ml
function _emit_expr_type_guard(state, expr)
```

Runs emit expr type guard.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1676)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-unary-function-emit-expr-unary-state-expr-mlc-codegen-codegen-expr-ml-1385790597"></a>
### _emit_expr_unary

```ml
function _emit_expr_unary(state, expr)
```

Runs emit expr unary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2343)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-unsupported-function-emit-expr-unsupported-state-expr-k-mlc-codegen-codegen-expr-ml-1192983288"></a>
### _emit_expr_unsupported

```ml
function _emit_expr_unsupported(state, expr, k)
```

Runs emit expr unsupported.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |
| `k` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8094)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-var-function-emit-expr-var-state-expr-mlc-codegen-codegen-expr-ml-1466870729"></a>
### _emit_expr_var

```ml
function _emit_expr_var(state, expr)
```

Runs emit expr var.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1969)

<a id="function-function-mlc-codegen-codegen-expr-emit-expr-voidlit-function-emit-expr-voidlit-state-expr-mlc-codegen-codegen-expr-ml-950400181"></a>
### _emit_expr_voidlit

```ml
function _emit_expr_voidlit(state, expr)
```

Runs emit expr voidlit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1764)

<a id="function-function-mlc-codegen-codegen-expr-emit-extern-arg-to-native-function-emit-extern-arg-to-native-state-abi-ty-fail-label-pos-wbuf-label-mlc-codegen-codegen-expr-ml-211883222"></a>
### _emit_extern_arg_to_native

```ml
function _emit_extern_arg_to_native(state, abi_ty, fail_label, pos, wbuf_label)
```

Runs emit extern arg to native.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `abi_ty` | `dynamic` | — |  |
| `fail_label` | `dynamic` | — |  |
| `pos` | `dynamic` | — |  |
| `wbuf_label` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8765)

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


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9195)

<a id="function-function-mlc-codegen-codegen-expr-emit-extern-out-from-stack-function-emit-extern-out-from-stack-state-abi-ty-stack-off-pos-mlc-codegen-codegen-expr-ml-1941186936"></a>
### _emit_extern_out_from_stack

```ml
function _emit_extern_out_from_stack(state, abi_ty, stack_off, pos)
```

Runs emit extern out from stack.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `abi_ty` | `dynamic` | — |  |
| `stack_off` | `dynamic` | — |  |
| `pos` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9142)

<a id="function-function-mlc-codegen-codegen-expr-emit-extern-ret-from-native-function-emit-extern-ret-from-native-state-abi-ty-fail-label-pos-mlc-codegen-codegen-expr-ml-1961782407"></a>
### _emit_extern_ret_from_native

```ml
function _emit_extern_ret_from_native(state, abi_ty, fail_label, pos)
```

Runs emit extern ret from native.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `abi_ty` | `dynamic` | — |  |
| `fail_label` | `dynamic` | — |  |
| `pos` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8912)

<a id="function-function-mlc-codegen-codegen-expr-emit-generic-call-builtin-cases-function-emit-generic-call-builtin-cases-state-callee-raw-name-call-args-nargs-call-args-base-mlc-codegen-codegen-expr-ml-88256487"></a>
### _emit_generic_call_builtin_cases

```ml
function _emit_generic_call_builtin_cases(state, callee, raw_name, call_args, nargs, call_args_base)
```

Runs emit generic call builtin cases.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `callee` | `dynamic` | — |  |
| `raw_name` | `dynamic` | — |  |
| `call_args` | `dynamic` | — |  |
| `nargs` | `dynamic` | — |  |
| `call_args_base` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L6231)

<a id="function-function-mlc-codegen-codegen-expr-emit-inline-call-function-emit-inline-call-state-callee-args-mlc-codegen-codegen-expr-ml-2085079347"></a>
### _emit_inline_call

```ml
function _emit_inline_call(state, callee, args)
```

Runs emit inline call.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `callee` | `dynamic` | — |  |
| `args` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9713)

<a id="function-function-mlc-codegen-codegen-expr-emit-known-float-binop-function-emit-known-float-binop-state-expr-mlc-codegen-codegen-expr-ml-840624601"></a>
### _emit_known_float_binop

```ml
function _emit_known_float_binop(state, expr)
```

Runs emit known float binop.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L3002)

<a id="function-function-mlc-codegen-codegen-expr-emit-known-int-binop-function-emit-known-int-binop-state-op-lhs-ok-lhs-const-rhs-ok-rhs-const-mlc-codegen-codegen-expr-ml-1410301729"></a>
### _emit_known_int_binop

```ml
function _emit_known_int_binop(state, op, lhs_ok, lhs_const, rhs_ok, rhs_const)
```

Runs emit known int binop.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `op` | `dynamic` | — |  |
| `lhs_ok` | `dynamic` | — |  |
| `lhs_const` | `dynamic` | — |  |
| `rhs_ok` | `dynamic` | — |  |
| `rhs_const` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2778)

<a id="function-function-mlc-codegen-codegen-expr-emit-make-error-const-function-emit-make-error-const-state-code-message-mlc-codegen-codegen-expr-ml-556272336"></a>
### _emit_make_error_const

```ml
function _emit_make_error_const(state, code, message)
```

Runs emit make error const.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `code` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8662)

<a id="function-function-mlc-codegen-codegen-expr-emit-native-callback-ret-lresult-function-emit-native-callback-ret-lresult-state-l-zero-l-done-mlc-codegen-codegen-expr-ml-1354735082"></a>
### _emit_native_callback_ret_lresult

```ml
function _emit_native_callback_ret_lresult(state, l_zero, l_done)
```

Runs emit native callback ret lresult.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `l_zero` | `dynamic` | — |  |
| `l_done` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L660)

<a id="function-function-mlc-codegen-codegen-expr-emit-native-callback-wndproc-function-emit-native-callback-wndproc-state-fn-qn-mlc-codegen-codegen-expr-ml-1808900834"></a>
### _emit_native_callback_wndproc

```ml
function _emit_native_callback_wndproc(state, fn_qn)
```

Runs emit native callback wndproc.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `fn_qn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L682)

<a id="function-function-mlc-codegen-codegen-expr-emit-native-value-helper-call-function-emit-native-value-helper-call-state-callee-raw-name-call-args-nargs-mlc-codegen-codegen-expr-ml-1858423327"></a>
### _emit_native_value_helper_call

```ml
function _emit_native_value_helper_call(state, callee, raw_name, call_args, nargs)
```

Runs emit native value helper call.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `callee` | `dynamic` | — |  |
| `raw_name` | `dynamic` | — |  |
| `call_args` | `dynamic` | — |  |
| `nargs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L7054)

<a id="function-function-mlc-codegen-codegen-expr-emit-std-math-roundlike-intrinsic-function-emit-std-math-roundlike-intrinsic-state-callee-name-arg-mlc-codegen-codegen-expr-ml-983075872"></a>
### _emit_std_math_roundlike_intrinsic

```ml
function _emit_std_math_roundlike_intrinsic(state, callee_name, arg)
```

Runs emit std math roundlike intrinsic.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `callee_name` | `dynamic` | — |  |
| `arg` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1390)

<a id="function-function-mlc-codegen-codegen-expr-emit-struct-field-index-dispatch-function-emit-struct-field-index-dispatch-state-field-struct-id-reg-out-reg-ok-label-fail-label-tag-mlc-codegen-codegen-expr-ml-1144660167"></a>
### _emit_struct_field_index_dispatch

```ml
function _emit_struct_field_index_dispatch(state, field, struct_id_reg, out_reg, ok_label, fail_label, tag)
```

Runs emit struct field index dispatch.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `field` | `dynamic` | — |  |
| `struct_id_reg` | `dynamic` | — |  |
| `out_reg` | `dynamic` | — |  |
| `ok_label` | `dynamic` | — |  |
| `fail_label` | `dynamic` | — |  |
| `tag` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1053)

<a id="function-function-mlc-codegen-codegen-expr-expr-has-this-function-expr-has-this-ex-mlc-codegen-codegen-expr-ml-920096598"></a>
### _expr_has_this

```ml
function _expr_has_this(ex)
```

Implements expr has this.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8379)

<a id="function-function-mlc-codegen-codegen-expr-expr-heap-cfg-bool-function-expr-heap-cfg-bool-state-key-defaultv-mlc-codegen-codegen-expr-ml-1543416824"></a>
### _expr_heap_cfg_bool

```ml
function _expr_heap_cfg_bool(state, key, defaultv)
```

Implements expr heap cfg bool.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L7179)

<a id="function-function-mlc-codegen-codegen-expr-expr-to-qualname-function-expr-to-qualname-state-expr-mlc-codegen-codegen-expr-ml-757175447"></a>
### _expr_to_qualname

```ml
function _expr_to_qualname(state, expr)
```

Implements expr to qualname.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1005)

<a id="function-function-mlc-codegen-codegen-expr-extern-dll-base-function-extern-dll-base-dll-is-linux-mlc-codegen-codegen-expr-ml-205980928"></a>
### _extern_dll_base

```ml
function _extern_dll_base(dll, is_linux)
```

Implements extern dll base.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dll` | `dynamic` | — |  |
| `is_linux` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8639)

<a id="function-function-mlc-codegen-codegen-expr-extern-iat-label-function-extern-iat-label-dll-sym-is-linux-mlc-codegen-codegen-expr-ml-590011265"></a>
### _extern_iat_label

```ml
function _extern_iat_label(dll, sym, is_linux)
```

Implements extern iat label.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dll` | `dynamic` | — |  |
| `sym` | `dynamic` | — |  |
| `is_linux` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8656)

<a id="function-function-mlc-codegen-codegen-expr-extern-sig-get-function-extern-sig-get-state-qname-mlc-codegen-codegen-expr-ml-218103376"></a>
### _extern_sig_get

```ml
function _extern_sig_get(state, qname)
```

Implements extern sig get.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1033)

<a id="function-function-mlc-codegen-codegen-expr-extern-struct-get-function-extern-struct-get-state-qname-mlc-codegen-codegen-expr-ml-689162256"></a>
### _extern_struct_get

```ml
function _extern_struct_get(state, qname)
```

Implements extern struct get.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1486)

<a id="function-function-mlc-codegen-codegen-expr-filter-expr-list-separator-artifacts-function-filter-expr-list-separator-artifacts-items-mlc-codegen-codegen-expr-ml-1341294507"></a>
### _filter_expr_list_separator_artifacts

```ml
function _filter_expr_list_separator_artifacts(items)
```

Implements filter expr list separator artifacts.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1510)

<a id="function-function-mlc-codegen-codegen-expr-fn-uses-this-function-fn-uses-this-fn-node-mlc-codegen-codegen-expr-ml-1106344302"></a>
### _fn_uses_this

```ml
function _fn_uses_this(fn_node)
```

Implements fn uses this.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fn_node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8578)

<a id="function-function-mlc-codegen-codegen-expr-function-wants-inline-function-function-wants-inline-fn-mlc-codegen-codegen-expr-ml-476633721"></a>
### _function_wants_inline

```ml
function _function_wants_inline(fn)
```

Implements function wants inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9640)

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


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L472)

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


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8328)

<a id="function-function-mlc-codegen-codegen-expr-inline-call-eligible-function-inline-call-eligible-fn-mlc-codegen-codegen-expr-ml-1842661879"></a>
### _inline_call_eligible

```ml
function _inline_call_eligible(fn)
```

Implements inline call eligible.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9698)

<a id="function-function-mlc-codegen-codegen-expr-inline-collect-expr-stats-function-inline-collect-expr-stats-ex-stats-mlc-codegen-codegen-expr-ml-986013263"></a>
### _inline_collect_expr_stats

```ml
function _inline_collect_expr_stats(ex, stats)
```

Implements inline collect expr stats.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |
| `stats` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9510)

<a id="function-function-mlc-codegen-codegen-expr-inline-collect-stmt-list-stats-function-inline-collect-stmt-list-stats-stmts-stats-mlc-codegen-codegen-expr-ml-2145714289"></a>
### _inline_collect_stmt_list_stats

```ml
function _inline_collect_stmt_list_stats(stmts, stats)
```

Implements inline collect stmt list stats.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stmts` | `dynamic` | — |  |
| `stats` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9547)

<a id="function-function-mlc-codegen-codegen-expr-inline-collect-stmt-stats-function-inline-collect-stmt-stats-st-stats-mlc-codegen-codegen-expr-ml-217400541"></a>
### _inline_collect_stmt_stats

```ml
function _inline_collect_stmt_stats(st, stats)
```

Implements inline collect stmt stats.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |
| `stats` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9558)

<a id="function-function-mlc-codegen-codegen-expr-inline-declared-type-fact-function-inline-declared-type-fact-state-raw-type-mlc-codegen-codegen-expr-ml-1670431225"></a>
### _inline_declared_type_fact

```ml
function _inline_declared_type_fact(state, raw_type)
```

Implements inline declared type fact.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `raw_type` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9684)

<a id="function-function-mlc-codegen-codegen-expr-intflow-name-has-function-intflow-name-has-arr-name-mlc-codegen-codegen-expr-ml-326076909"></a>
### _intflow_name_has

```ml
function _intflow_name_has(arr, name)
```

Implements intflow name has.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2443)

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


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L826)

<a id="function-function-mlc-codegen-codegen-expr-is-expr-list-separator-artifact-function-is-expr-list-separator-artifact-ex-mlc-codegen-codegen-expr-ml-1185540350"></a>
### _is_expr_list_separator_artifact

```ml
function _is_expr_list_separator_artifact(ex)
```

Reports whether is expr list separator artifact.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1498)

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


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8338)

<a id="function-function-mlc-codegen-codegen-expr-is-int-no-bool-inline-function-is-int-no-bool-v-mlc-codegen-codegen-expr-ml-1740716338"></a>
### _is_int_no_bool

```ml
inline function _is_int_no_bool(v)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L292)

<a id="function-function-mlc-codegen-codegen-expr-is-number-no-bool-inline-function-is-number-no-bool-v-mlc-codegen-codegen-expr-ml-617520384"></a>
### _is_number_no_bool

```ml
inline function _is_number_no_bool(v)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L284)

<a id="function-function-mlc-codegen-codegen-expr-member-base-alias-shadowed-function-member-base-alias-shadowed-state-expr-mlc-codegen-codegen-expr-ml-530020817"></a>
### _member_base_alias_shadowed

```ml
function _member_base_alias_shadowed(state, expr)
```

Implements member base alias shadowed.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L853)

<a id="function-function-mlc-codegen-codegen-expr-method-map-get-inline-function-method-map-get-map-arr-method-name-mlc-codegen-codegen-expr-ml-1123945021"></a>
### _method_map_get

```ml
inline function _method_map_get(map_arr, method_name)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `map_arr` | `dynamic` | — |  |
| `method_name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L430)

<a id="function-function-mlc-codegen-codegen-expr-named-array-get-inline-function-named-array-get-arr-key-mlc-codegen-codegen-expr-ml-1881086926"></a>
### _named_array_get

```ml
inline function _named_array_get(arr, key)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L314)

<a id="function-function-mlc-codegen-codegen-expr-named-int-get-inline-function-named-int-get-arr-key-defaultv-mlc-codegen-codegen-expr-ml-696397625"></a>
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


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L330)

<a id="function-function-mlc-codegen-codegen-expr-native-callback-resolve-user-fn-function-native-callback-resolve-user-fn-state-ex-mlc-codegen-codegen-expr-ml-2104517683"></a>
### _native_callback_resolve_user_fn

```ml
function _native_callback_resolve_user_fn(state, ex)
```

Implements native callback resolve user fn.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L642)

<a id="function-function-mlc-codegen-codegen-expr-next-lid-inline-function-next-lid-state-mlc-codegen-codegen-expr-ml-1245044263"></a>
### _next_lid

```ml
inline function _next_lid(state)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L634)

<a id="function-function-mlc-codegen-codegen-expr-normalize-declared-call-args-function-normalize-declared-call-args-expr-fn-implicit-mlc-codegen-codegen-expr-ml-715104241"></a>
### _normalize_declared_call_args

```ml
function _normalize_declared_call_args(expr, fn, implicit)
```

Implements normalize declared call args.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expr` | `dynamic` | — |  |
| `fn` | `dynamic` | — |  |
| `implicit` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L184)

<a id="function-function-mlc-codegen-codegen-expr-opt-const-nonnegative-int-function-opt-const-nonnegative-int-state-ex-mlc-codegen-codegen-expr-ml-1783933275"></a>
### _opt_const_nonnegative_int

```ml
function _opt_const_nonnegative_int(state, ex)
```

Implements opt const nonnegative int.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2463)

<a id="function-function-mlc-codegen-codegen-expr-opt-const-nonzero-number-function-opt-const-nonzero-number-state-ex-mlc-codegen-codegen-expr-ml-692147035"></a>
### _opt_const_nonzero_number

```ml
function _opt_const_nonzero_number(state, ex)
```

Implements opt const nonzero number.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2454)

<a id="function-function-mlc-codegen-codegen-expr-opt-emit-const-value-function-opt-emit-const-value-state-value-mlc-codegen-codegen-expr-ml-1769433631"></a>
### _opt_emit_const_value

```ml
function _opt_emit_const_value(state, value)
```

Implements opt emit const value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9918)

<a id="function-function-mlc-codegen-codegen-expr-opt-emit-known-index-function-opt-emit-known-index-state-expr-plan-mlc-codegen-codegen-expr-ml-370978738"></a>
### _opt_emit_known_index

```ml
function _opt_emit_known_index(state, expr, plan)
```

Implements opt emit known index.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |
| `plan` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2677)

<a id="function-function-mlc-codegen-codegen-expr-opt-expr-known-int-function-opt-expr-known-int-state-ex-mlc-codegen-codegen-expr-ml-1139113643"></a>
### _opt_expr_known_int

```ml
function _opt_expr_known_int(state, ex)
```

Implements opt expr known int.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2470)

<a id="function-function-mlc-codegen-codegen-expr-opt-expr-known-type-function-opt-expr-known-type-state-ex-mlc-codegen-codegen-expr-ml-1657401667"></a>
### _opt_expr_known_type

```ml
function _opt_expr_known_type(state, ex)
```

Implements opt expr known type.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2548)

<a id="function-function-mlc-codegen-codegen-expr-opt-known-index-plan-function-opt-known-index-plan-state-ex-mlc-codegen-codegen-expr-ml-274133085"></a>
### _opt_known_index_plan

```ml
function _opt_known_index_plan(state, ex)
```

Implements opt known index plan.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2629)

<a id="function-function-mlc-codegen-codegen-expr-opt-truthy-inline-function-opt-truthy-v-mlc-codegen-codegen-expr-ml-510391714"></a>
### _opt_truthy

```ml
inline function _opt_truthy(v)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L271)

<a id="function-function-mlc-codegen-codegen-expr-opt-try-const-immediate-encoded-function-opt-try-const-immediate-encoded-state-expr-mlc-codegen-codegen-expr-ml-2129065573"></a>
### _opt_try_const_immediate_encoded

```ml
function _opt_try_const_immediate_encoded(state, expr)
```

Implements opt try const immediate encoded.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1293)

<a id="function-function-mlc-codegen-codegen-expr-opt-try-const-value-function-opt-try-const-value-state-ex-mlc-codegen-codegen-expr-ml-2030503603"></a>
### _opt_try_const_value

```ml
function _opt_try_const_value(state, ex)
```

Implements opt try const value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9912)

<a id="function-function-mlc-codegen-codegen-expr-opt-try-known-type-label-function-opt-try-known-type-label-state-expr-detailed-mlc-codegen-codegen-expr-ml-385000701"></a>
### _opt_try_known_type_label

```ml
function _opt_try_known_type_label(state, expr, detailed)
```

Implements opt try known type label.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |
| `detailed` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1325)

<a id="function-function-mlc-codegen-codegen-expr-opt-try-pure-const-array-len-function-opt-try-pure-const-array-len-state-expr-mlc-codegen-codegen-expr-ml-2032552391"></a>
### _opt_try_pure_const_array_len

```ml
function _opt_try_pure_const_array_len(state, expr)
```

Implements opt try pure const array len.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1310)

<a id="function-function-mlc-codegen-codegen-expr-opt-type-base-inline-function-opt-type-base-type-name-mlc-codegen-codegen-expr-ml-347057446"></a>
### _opt_type_base

```ml
inline function _opt_type_base(type_name)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `type_name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2505)

<a id="function-function-mlc-codegen-codegen-expr-opt-type-exact-length-function-opt-type-exact-length-type-name-mlc-codegen-codegen-expr-ml-513702245"></a>
### _opt_type_exact_length

```ml
function _opt_type_exact_length(type_name)
```

Implements opt type exact length.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `type_name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2515)

<a id="function-function-mlc-codegen-codegen-expr-opt-type-fact-get-function-opt-type-fact-get-items-name-mlc-codegen-codegen-expr-ml-857455814"></a>
### _opt_type_fact_get

```ml
function _opt_type_fact_get(items, name)
```

Implements opt type fact get.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2532)

<a id="function-function-mlc-codegen-codegen-expr-opt-type-query-can-elide-evaluation-function-opt-type-query-can-elide-evaluation-ex-mlc-codegen-codegen-expr-ml-81004822"></a>
### _opt_type_query_can_elide_evaluation

```ml
function _opt_type_query_can_elide_evaluation(ex)
```

Implements opt type query can elide evaluation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2621)

<a id="function-function-mlc-codegen-codegen-expr-pool-collect-suffix-function-pool-collect-suffix-pool-prefix-suffix-matches-mlc-codegen-codegen-expr-ml-241897643"></a>
### _pool_collect_suffix

```ml
function _pool_collect_suffix(pool, prefix, suffix, matches)
```

Implements pool collect suffix.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pool` | `dynamic` | — |  |
| `prefix` | `dynamic` | — |  |
| `suffix` | `dynamic` | — |  |
| `matches` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L890)

<a id="function-function-mlc-codegen-codegen-expr-pool-has-key-function-pool-has-key-pool-key-mlc-codegen-codegen-expr-ml-1833225956"></a>
### _pool_has_key

```ml
function _pool_has_key(pool, key)
```

Implements pool has key.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pool` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L877)

<a id="function-function-mlc-codegen-codegen-expr-positive-power-of-two-shift-function-positive-power-of-two-shift-value-mlc-codegen-codegen-expr-ml-1591859408"></a>
### _positive_power_of_two_shift

```ml
function _positive_power_of_two_shift(value)
```

Return log2(value), or -1 when value is not a positive power of two.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L2764)

<a id="function-function-mlc-codegen-codegen-expr-qname-exists-function-qname-exists-state-qname-mlc-codegen-codegen-expr-ml-11489112"></a>
### _qname_exists

```ml
function _qname_exists(state, qname)
```

Implements qname exists.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8316)

<a id="function-function-mlc-codegen-codegen-expr-qname-of-function-qname-of-state-ex-mlc-codegen-codegen-expr-ml-265331533"></a>
### _qname_of

```ml
function _qname_of(state, ex)
```

Implements qname of.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8147)

<a id="function-function-mlc-codegen-codegen-expr-qname-parts-function-qname-parts-state-ex-mlc-codegen-codegen-expr-ml-617631291"></a>
### _qname_parts

```ml
function _qname_parts(state, ex)
```

Implements qname parts.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `ex` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8139)

<a id="function-function-mlc-codegen-codegen-expr-qname-parts-any-function-qname-parts-any-expr-mlc-codegen-codegen-expr-ml-1463872372"></a>
### _qname_parts_any

```ml
function _qname_parts_any(expr)
```

Implements qname parts any.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1366)

<a id="function-function-mlc-codegen-codegen-expr-qname-with-prefixes-function-qname-with-prefixes-state-qname-mlc-codegen-codegen-expr-ml-130025352"></a>
### _qname_with_prefixes

```ml
function _qname_with_prefixes(state, qname)
```

Implements qname with prefixes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8276)

<a id="function-function-mlc-codegen-codegen-expr-qualify-dotted-function-qualify-dotted-state-name-mlc-codegen-codegen-expr-ml-2130487099"></a>
### _qualify_dotted

```ml
function _qualify_dotted(state, name)
```

Implements qualify dotted.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8310)

<a id="function-function-mlc-codegen-codegen-expr-qualify-identifier-function-qualify-identifier-state-name-mlc-codegen-codegen-expr-ml-1704406085"></a>
### _qualify_identifier

```ml
function _qualify_identifier(state, name)
```

Implements qualify identifier.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L916)

<a id="function-function-mlc-codegen-codegen-expr-resolve-const-value-function-resolve-const-value-state-name-mlc-codegen-codegen-expr-ml-1736193677"></a>
### _resolve_const_value

```ml
function _resolve_const_value(state, name)
```

Implements resolve const value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1123)

<a id="function-function-mlc-codegen-codegen-expr-state-enum-id-get-inline-function-state-enum-id-get-state-key-defaultv-mlc-codegen-codegen-expr-ml-1848184787"></a>
### _state_enum_id_get

```ml
inline function _state_enum_id_get(state, key, defaultv)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L358)

<a id="function-function-mlc-codegen-codegen-expr-state-enum-variants-get-inline-function-state-enum-variants-get-state-key-mlc-codegen-codegen-expr-ml-562053330"></a>
### _state_enum_variants_get

```ml
inline function _state_enum_variants_get(state, key)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L395)

<a id="function-function-mlc-codegen-codegen-expr-state-named-array-get-inline-function-state-named-array-get-index-map-arr-key-mlc-codegen-codegen-expr-ml-1817475941"></a>
### _state_named_array_get

```ml
inline function _state_named_array_get(index_map, arr, key)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index_map` | `dynamic` | — |  |
| `arr` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L368)

<a id="function-function-mlc-codegen-codegen-expr-state-struct-field-types-get-inline-function-state-struct-field-types-get-state-key-mlc-codegen-codegen-expr-ml-1860069308"></a>
### _state_struct_field_types_get

```ml
inline function _state_struct_field_types_get(state, key)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L383)

<a id="function-function-mlc-codegen-codegen-expr-state-struct-fields-get-inline-function-state-struct-fields-get-state-key-mlc-codegen-codegen-expr-ml-1661443136"></a>
### _state_struct_fields_get

```ml
inline function _state_struct_fields_get(state, key)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L377)

<a id="function-function-mlc-codegen-codegen-expr-state-struct-id-get-inline-function-state-struct-id-get-state-key-defaultv-mlc-codegen-codegen-expr-ml-607185971"></a>
### _state_struct_id_get

```ml
inline function _state_struct_id_get(state, key, defaultv)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L348)

<a id="function-function-mlc-codegen-codegen-expr-state-struct-methods-get-inline-function-state-struct-methods-get-state-key-mlc-codegen-codegen-expr-ml-1640907056"></a>
### _state_struct_methods_get

```ml
inline function _state_struct_methods_get(state, key)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L389)

<a id="function-function-mlc-codegen-codegen-expr-state-struct-static-methods-get-inline-function-state-struct-static-methods-get-state-key-mlc-codegen-codegen-expr-ml-644259028"></a>
### _state_struct_static_methods_get

```ml
inline function _state_struct_static_methods_get(state, key)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L401)

<a id="function-function-mlc-codegen-codegen-expr-stmt-has-this-function-stmt-has-this-st-mlc-codegen-codegen-expr-ml-1440660948"></a>
### _stmt_has_this

```ml
function _stmt_has_this(st)
```

Implements stmt has this.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L8436)

<a id="function-function-mlc-codegen-codegen-expr-strpair-get-inline-function-strpair-get-arr-key-mlc-codegen-codegen-expr-ml-1442572622"></a>
### _strpair_get

```ml
inline function _strpair_get(arr, key)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L407)

<a id="function-function-mlc-codegen-codegen-expr-try-const-bin-function-try-const-bin-op-lv-rv-mlc-codegen-codegen-expr-ml-847450350"></a>
### _try_const_bin

```ml
function _try_const_bin(op, lv, rv)
```

Implements try const bin.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `op` | `dynamic` | — |  |
| `lv` | `dynamic` | — |  |
| `rv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1139)

<a id="function-function-mlc-codegen-codegen-expr-user-function-get-function-user-function-get-state-qname-mlc-codegen-codegen-expr-ml-1226066976"></a>
### _user_function_get

```ml
function _user_function_get(state, qname)
```

Implements user function get.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L451)

<a id="function-function-mlc-codegen-codegen-expr-variadic-expr-safe-function-variadic-expr-safe-ex-name-allow-direct-mlc-codegen-codegen-expr-ml-1955139858"></a>
### _variadic_expr_safe

```ml
function _variadic_expr_safe(ex, name, allow_direct)
```

Implements variadic expr safe.

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

Implements variadic is direct var.

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

Implements variadic param stack safe.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fn` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L174)

<a id="function-function-mlc-codegen-codegen-expr-variadic-stmts-safe-function-variadic-stmts-safe-body-name-mlc-codegen-codegen-expr-ml-547146716"></a>
### _variadic_stmts_safe

```ml
function _variadic_stmts_safe(body, name)
```

Implements variadic stmts safe.

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

Implements cg emit expr.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `expr` | `dynamic` | — | Value supplied for `expr`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1530)

<a id="function-function-mlc-codegen-codegen-expr-cg-expr-try-const-decl-value-function-cg-expr-try-const-decl-value-state-expr-mlc-codegen-codegen-expr-ml-579064845"></a>
### cg_expr_try_const_decl_value

```ml
function cg_expr_try_const_decl_value(state, expr)
```

Implements cg expr try const decl value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `expr` | `dynamic` | — | Value supplied for `expr`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1479)

<a id="function-function-mlc-codegen-codegen-expr-cg-expr-try-const-value-function-cg-expr-try-const-value-state-expr-mlc-codegen-codegen-expr-ml-300093649"></a>
### cg_expr_try_const_value

```ml
function cg_expr_try_const_value(state, expr)
```

Implements cg expr try const value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `expr` | `dynamic` | — | Value supplied for `expr`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L1471)

- [mlc.codegen.codegen_expr.ConstEvalResult](Type-mlc-codegen-codegen-expr-constevalresult-1651772175.md) — struct
<a id="function-function-mlc-codegen-codegen-expr-emit-expr-function-emit-expr-state-ex-mlc-codegen-codegen-expr-ml-1588049625"></a>
### emit_expr

```ml
function emit_expr(state, ex)
```

Runs emit expr.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `ex` | `dynamic` | — | Value supplied for `ex`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9971)

<a id="function-function-mlc-codegen-codegen-expr-emit-extern-stubs-function-emit-extern-stubs-state-mlc-codegen-codegen-expr-ml-162750204"></a>
### emit_extern_stubs

```ml
function emit_extern_stubs(state)
```

Runs emit extern stubs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L9977)

- [mlc.codegen.codegen_expr.InlineStats](Type-mlc-codegen-codegen-expr-inlinestats-1176616483.md) — struct
