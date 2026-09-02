# `mlc/codegen/codegen_scope.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc codegen codegen_scope package.

Package: [`mlc.codegen.codegen_scope`](Package-mlc-codegen-codegen-scope-545400582.md)

Reachable from entry: **yes**

## Imports

- `mlc/asm.ml` as `a` → [mlc/asm.ml](File-mlc-asm-ml-1368648960.md)
- `mlc/constants.ml` as `c` → [mlc/constants.ml](File-mlc-constants-ml-1024884042.md)
- `mlc/data.ml` as `d` → [mlc/data.ml](File-mlc-data-ml-557434521.md)
- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)

## Declarations

<a id="function-function-mlc-codegen-codegen-scope-add-binding-to-current-scope-function-add-binding-to-current-scope-state-b-mlc-codegen-codegen-scope-ml-1481177074"></a>
### _add_binding_to_current_scope

```ml
function _add_binding_to_current_scope(state, b)
```

Updates add binding to current scope.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L983)

<a id="function-function-mlc-codegen-codegen-scope-append-unique-function-append-unique-items-value-mlc-codegen-codegen-scope-ml-873548608"></a>
### _append_unique

```ml
function _append_unique(items, value)
```

Updates append unique.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L261)

<a id="function-function-mlc-codegen-codegen-scope-arr-has-inline-function-arr-has-arr-value-mlc-codegen-codegen-scope-ml-625151476"></a>
### _arr_has

```ml
inline function _arr_has(arr, value)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L282)

<a id="function-function-mlc-codegen-codegen-scope-check-reserved-ident-function-check-reserved-ident-state-name-decl-node-mlc-codegen-codegen-scope-ml-1092621700"></a>
### _check_reserved_ident

```ml
function _check_reserved_ident(state, name, decl_node)
```

Implements check reserved ident.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `decl_node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L989)

<a id="function-function-mlc-codegen-codegen-scope-coerce-name-function-coerce-name-name-mlc-codegen-codegen-scope-ml-986629978"></a>
### _coerce_name

```ml
function _coerce_name(name)
```

Implements coerce name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L860)

<a id="function-function-mlc-codegen-codegen-scope-decl-key-function-decl-key-node-name-mlc-codegen-codegen-scope-ml-966656368"></a>
### _decl_key

```ml
function _decl_key(node, name)
```

Implements decl key.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L963)

<a id="function-function-mlc-codegen-codegen-scope-decl-node-key-inline-function-decl-node-key-node-mlc-codegen-codegen-scope-ml-188869874"></a>
### _decl_node_key

```ml
inline function _decl_node_key(node)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L324)

<a id="function-function-mlc-codegen-codegen-scope-declare-in-current-scope-function-declare-in-current-scope-state-b-mlc-codegen-codegen-scope-ml-949818152"></a>
### _declare_in_current_scope

```ml
function _declare_in_current_scope(state, b)
```

Implements declare in current scope.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L598)

<a id="function-function-mlc-codegen-codegen-scope-drop-last-frame-function-drop-last-frame-arr-mlc-codegen-codegen-scope-ml-1384258026"></a>
### _drop_last_frame

```ml
function _drop_last_frame(arr)
```

Implements drop last frame.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L232)

<a id="function-function-mlc-codegen-codegen-scope-emit-make-error-const-function-emit-make-error-const-state-code-message-mlc-codegen-codegen-scope-ml-556035598"></a>
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


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L397)

<a id="function-function-mlc-codegen-codegen-scope-emit-module-init-dependency-error-function-emit-module-init-dependency-error-state-target-name-target-file-target-state-node-mlc-codegen-codegen-scope-ml-67747104"></a>
### _emit_module_init_dependency_error

```ml
function _emit_module_init_dependency_error(state, target_name, target_file, target_state, node)
```

Runs emit module init dependency error.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `target_name` | `dynamic` | — |  |
| `target_file` | `dynamic` | — |  |
| `target_state` | `dynamic` | — |  |
| `node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L1486)

<a id="function-function-mlc-codegen-codegen-scope-frame-last-binding-inline-function-frame-last-binding-frame-name-mlc-codegen-codegen-scope-ml-1237157440"></a>
### _frame_last_binding

```ml
inline function _frame_last_binding(frame, name)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frame` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L191)

<a id="function-function-mlc-codegen-codegen-scope-func-global-lookup-inline-function-func-global-lookup-arr-name-mlc-codegen-codegen-scope-ml-480068282"></a>
### _func_global_lookup

```ml
inline function _func_global_lookup(arr, name)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L365)

<a id="function-function-mlc-codegen-codegen-scope-has-data-label-function-has-data-label-labels-name-mlc-codegen-codegen-scope-ml-312136563"></a>
### _has_data_label

```ml
function _has_data_label(labels, name)
```

Reports whether has data label.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `labels` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L386)

<a id="function-function-mlc-codegen-codegen-scope-heap-cfg-get-any-inline-function-heap-cfg-get-any-state-key-mlc-codegen-codegen-scope-ml-681445032"></a>
### _heap_cfg_get_any

```ml
inline function _heap_cfg_get_any(state, key)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L207)

<a id="function-function-mlc-codegen-codegen-scope-heap-cfg-get-bool-inline-function-heap-cfg-get-bool-state-key-defaultv-mlc-codegen-codegen-scope-ml-263182827"></a>
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


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L224)

<a id="function-function-mlc-codegen-codegen-scope-is-ascii-alpha-inline-function-is-ascii-alpha-ch-mlc-codegen-codegen-scope-ml-1897055775"></a>
### _is_ascii_alpha

```ml
inline function _is_ascii_alpha(ch)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ch` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L100)

<a id="function-function-mlc-codegen-codegen-scope-is-ascii-digit-inline-function-is-ascii-digit-ch-mlc-codegen-codegen-scope-ml-1063018823"></a>
### _is_ascii_digit

```ml
inline function _is_ascii_digit(ch)
```

Reports whether a character is an ASCII digit.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ch` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L94)

<a id="function-function-mlc-codegen-codegen-scope-is-reserved-identifier-inline-function-is-reserved-identifier-state-name-mlc-codegen-codegen-scope-ml-529530772"></a>
### _is_reserved_identifier

```ml
inline function _is_reserved_identifier(state, name)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L249)

<a id="function-function-mlc-codegen-codegen-scope-map-int-get-inline-function-map-int-get-arr-key-defaultv-mlc-codegen-codegen-scope-ml-1228131745"></a>
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


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L292)

<a id="function-function-mlc-codegen-codegen-scope-maybe-emit-module-init-guard-for-global-read-function-maybe-emit-module-init-guard-for-global-read-state-binding-target-name-node-mlc-codegen-codegen-scope-ml-147704174"></a>
### _maybe_emit_module_init_guard_for_global_read

```ml
function _maybe_emit_module_init_guard_for_global_read(state, binding, target_name, node)
```

Implements maybe emit module init guard for global read.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |
| `binding` | `dynamic` | — |  |
| `target_name` | `dynamic` | — |  |
| `node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L1503)

<a id="function-function-mlc-codegen-codegen-scope-name-has-dot-inline-function-name-has-dot-name-mlc-codegen-codegen-scope-ml-1624076743"></a>
### _name_has_dot

```ml
inline function _name_has_dot(name)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L313)

<a id="function-function-mlc-codegen-codegen-scope-next-binding-id-function-next-binding-id-state-mlc-codegen-codegen-scope-ml-1544857556"></a>
### _next_binding_id

```ml
function _next_binding_id(state)
```

Implements next binding id.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L957)

<a id="function-function-mlc-codegen-codegen-scope-sanitize-ident-function-sanitize-ident-name-mlc-codegen-codegen-scope-ml-2003671040"></a>
### _sanitize_ident

```ml
function _sanitize_ident(name)
```

Implements sanitize ident.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L110)

<a id="function-function-mlc-codegen-codegen-scope-scope-depth-inline-function-scope-depth-state-mlc-codegen-codegen-scope-ml-367959883"></a>
### _scope_depth

```ml
inline function _scope_depth(state)
```

Implements inline.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L138)

<a id="function-function-mlc-codegen-codegen-scope-accept-function-accept-s-mlc-codegen-codegen-scope-ml-941567756"></a>
### accept

```ml
function accept(s)
```

Implements accept.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `s` | `dynamic` | — | Value supplied for `s`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L892)

<a id="function-function-mlc-codegen-codegen-scope-analysis-layout-function-locals-function-analysis-layout-function-locals-state-base-offset-mlc-codegen-codegen-scope-ml-965038881"></a>
### analysis_layout_function_locals

```ml
function analysis_layout_function_locals(state, base_offset)
```

Implements analysis layout function locals.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `base_offset` | `dynamic` | — | Value supplied for `base_offset`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L1838)

<a id="function-function-mlc-codegen-codegen-scope-analysis-reset-function-function-analysis-reset-function-state-mlc-codegen-codegen-scope-ml-1837008426"></a>
### analysis_reset_function

```ml
function analysis_reset_function(state)
```

Implements analysis reset function.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L1825)

<a id="function-function-mlc-codegen-codegen-scope-bind-param-function-bind-param-state-name-offset-decl-node-mlc-codegen-codegen-scope-ml-1044192007"></a>
### bind_param

```ml
function bind_param(state, name, offset, decl_node)
```

Implements bind param.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `offset` | `dynamic` | — | Zero-based starting offset. |
| `decl_node` | `dynamic` | — | Value supplied for `decl_node`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L1350)

- [mlc.codegen.codegen_scope.CallableBinding](Type-mlc-codegen-codegen-scope-callablebinding-1922308849.md) — struct
<a id="function-function-mlc-codegen-codegen-scope-cg-declare-binding-function-cg-declare-binding-state-name-kind-is-const-const-expr-const-value-py-decl-node-mlc-codegen-codegen-scope-ml-79290834"></a>
### cg_declare_binding

```ml
function cg_declare_binding(state, name, kind, is_const, const_expr, const_value_py, decl_node)
```

Implements cg declare binding.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `kind` | `dynamic` | — | Value supplied for `kind`. |
| `is_const` | `dynamic` | — | Value supplied for `is_const`. |
| `const_expr` | `dynamic` | — | Value supplied for `const_expr`. |
| `const_value_py` | `dynamic` | — | Value supplied for `const_value_py`. |
| `decl_node` | `dynamic` | — | Value supplied for `decl_node`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L646)

<a id="function-function-mlc-codegen-codegen-scope-cg-next-binding-id-function-cg-next-binding-id-state-mlc-codegen-codegen-scope-ml-843506688"></a>
### cg_next_binding_id

```ml
function cg_next_binding_id(state)
```

Implements cg next binding id.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L520)

<a id="function-function-mlc-codegen-codegen-scope-cg-precompute-const-binding-value-function-cg-precompute-const-binding-value-state-name-pyv-mlc-codegen-codegen-scope-ml-632647422"></a>
### cg_precompute_const_binding_value

```ml
function cg_precompute_const_binding_value(state, name, pyv)
```

Implements cg precompute const binding value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `pyv` | `dynamic` | — | Value supplied for `pyv`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L799)

<a id="function-function-mlc-codegen-codegen-scope-cg-resolve-binding-function-cg-resolve-binding-state-name-mlc-codegen-codegen-scope-ml-1169968655"></a>
### cg_resolve_binding

```ml
function cg_resolve_binding(state, name)
```

Resolve the nearest visible binding through the per-scope indexes. A complete index stack is authoritative; the linear frame scan remains only for partially constructed legacy/test states.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Code-generation state containing parallel scope and index stacks. |
| `name` | `dynamic` | — | Identifier to resolve. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L528)

<a id="function-function-mlc-codegen-codegen-scope-cg-resolve-binding-for-write-function-cg-resolve-binding-for-write-state-name-mlc-codegen-codegen-scope-ml-346787647"></a>
### cg_resolve_binding_for_write

```ml
function cg_resolve_binding_for_write(state, name)
```

Implements cg resolve binding for write.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L564)

<a id="function-function-mlc-codegen-codegen-scope-cg-scope-depth-function-cg-scope-depth-state-mlc-codegen-codegen-scope-ml-2035357288"></a>
### cg_scope_depth

```ml
function cg_scope_depth(state)
```

Implements cg scope depth.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L465)

<a id="function-function-mlc-codegen-codegen-scope-cg-scope-enter-function-cg-scope-enter-state-mlc-codegen-codegen-scope-ml-208897180"></a>
### cg_scope_enter

```ml
function cg_scope_enter(state)
```

Implements cg scope enter.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L471)

<a id="function-function-mlc-codegen-codegen-scope-cg-scope-leave-function-cg-scope-leave-state-emit-cleanup-mlc-codegen-codegen-scope-ml-265549576"></a>
### cg_scope_leave

```ml
function cg_scope_leave(state, emit_cleanup)
```

Implements cg scope leave.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `emit_cleanup` | `dynamic` | — | Value supplied for `emit_cleanup`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L494)

<a id="function-function-mlc-codegen-codegen-scope-cg-scope-setup-function-cg-scope-setup-state-mlc-codegen-codegen-scope-ml-985598392"></a>
### cg_scope_setup

```ml
function cg_scope_setup(state)
```

Implements cg scope setup.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L442)

<a id="function-function-mlc-codegen-codegen-scope-cg-set-const-binding-value-function-cg-set-const-binding-value-state-name-pyv-mlc-codegen-codegen-scope-ml-2050073468"></a>
### cg_set_const_binding_value

```ml
function cg_set_const_binding_value(state, name, pyv)
```

Implements cg set const binding value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `pyv` | `dynamic` | — | Value supplied for `pyv`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L729)

<a id="function-function-mlc-codegen-codegen-scope-declare-callable-binding-root-function-declare-callable-binding-root-state-name-decl-node-mlc-codegen-codegen-scope-ml-641440390"></a>
### declare_callable_binding_root

```ml
function declare_callable_binding_root(state, name, decl_node)
```

Implements declare callable binding root.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `decl_node` | `dynamic` | — | Value supplied for `decl_node`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L1109)

<a id="function-function-mlc-codegen-codegen-scope-declare-const-binding-root-deferred-function-declare-const-binding-root-deferred-state-name-decl-node-const-expr-mlc-codegen-codegen-scope-ml-1213810991"></a>
### declare_const_binding_root_deferred

```ml
function declare_const_binding_root_deferred(state, name, decl_node, const_expr)
```

Implements declare const binding root deferred.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `decl_node` | `dynamic` | — | Value supplied for `decl_node`. |
| `const_expr` | `dynamic` | — | Value supplied for `const_expr`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L1161)

<a id="function-function-mlc-codegen-codegen-scope-declare-fresh-binding-function-declare-fresh-binding-state-name-decl-node-kind-mlc-codegen-codegen-scope-ml-1423674534"></a>
### declare_fresh_binding

```ml
function declare_fresh_binding(state, name, decl_node, kind)
```

Implements declare fresh binding.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `decl_node` | `dynamic` | — | Value supplied for `decl_node`. |
| `kind` | `dynamic` | — | Value supplied for `kind`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L1317)

<a id="function-function-mlc-codegen-codegen-scope-declare-function-global-function-declare-function-global-state-local-name-qualified-name-mlc-codegen-codegen-scope-ml-1108792341"></a>
### declare_function_global

```ml
function declare_function_global(state, local_name, qualified_name)
```

Implements declare function global.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `local_name` | `dynamic` | — | Value supplied for `local_name`. |
| `qualified_name` | `dynamic` | — | Value supplied for `qualified_name`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L1866)

<a id="function-function-mlc-codegen-codegen-scope-declare-global-binding-function-declare-global-binding-state-name-decl-node-is-const-const-expr-mlc-codegen-codegen-scope-ml-353176841"></a>
### declare_global_binding

```ml
function declare_global_binding(state, name, decl_node, is_const, const_expr)
```

Implements declare global binding.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `decl_node` | `dynamic` | — | Value supplied for `decl_node`. |
| `is_const` | `dynamic` | — | Value supplied for `is_const`. |
| `const_expr` | `dynamic` | — | Value supplied for `const_expr`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L1004)

<a id="function-function-mlc-codegen-codegen-scope-declare-global-binding-root-function-declare-global-binding-root-state-name-decl-node-is-const-const-expr-mlc-codegen-codegen-scope-ml-924585051"></a>
### declare_global_binding_root

```ml
function declare_global_binding_root(state, name, decl_node, is_const, const_expr)
```

Implements declare global binding root.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `decl_node` | `dynamic` | — | Value supplied for `decl_node`. |
| `is_const` | `dynamic` | — | Value supplied for `is_const`. |
| `const_expr` | `dynamic` | — | Value supplied for `const_expr`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L1015)

<a id="function-function-mlc-codegen-codegen-scope-declare-local-binding-function-declare-local-binding-state-name-decl-node-is-const-const-expr-mlc-codegen-codegen-scope-ml-431201897"></a>
### declare_local_binding

```ml
function declare_local_binding(state, name, decl_node, is_const, const_expr)
```

Implements declare local binding.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `decl_node` | `dynamic` | — | Value supplied for `decl_node`. |
| `is_const` | `dynamic` | — | Value supplied for `is_const`. |
| `const_expr` | `dynamic` | — | Value supplied for `const_expr`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L1307)

<a id="function-function-mlc-codegen-codegen-scope-emit-cleanup-bindings-function-emit-cleanup-bindings-state-bindings-mlc-codegen-codegen-scope-ml-1409007752"></a>
### emit_cleanup_bindings

```ml
function emit_cleanup_bindings(state, bindings)
```

Runs emit cleanup bindings.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `bindings` | `dynamic` | — | Value supplied for `bindings`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L1441)

<a id="function-function-mlc-codegen-codegen-scope-emit-cleanup-to-depth-function-emit-cleanup-to-depth-state-target-depth-mlc-codegen-codegen-scope-ml-649807815"></a>
### emit_cleanup_to_depth

```ml
function emit_cleanup_to_depth(state, target_depth)
```

Runs emit cleanup to depth.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `target_depth` | `dynamic` | — | Value supplied for `target_depth`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L1466)

<a id="function-function-mlc-codegen-codegen-scope-emit-load-var-scoped-function-emit-load-var-scoped-state-name-mlc-codegen-codegen-scope-ml-2048837639"></a>
### emit_load_var_scoped

```ml
function emit_load_var_scoped(state, name)
```

Runs emit load var scoped.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L1535)

<a id="function-function-mlc-codegen-codegen-scope-emit-store-existing-global-function-emit-store-existing-global-state-binding-mlc-codegen-codegen-scope-ml-2015630335"></a>
### emit_store_existing_global

```ml
function emit_store_existing_global(state, binding)
```

Runs emit store existing global.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `binding` | `dynamic` | — | Value supplied for `binding`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L1804)

<a id="function-function-mlc-codegen-codegen-scope-emit-store-var-scoped-function-emit-store-var-scoped-state-name-node-mlc-codegen-codegen-scope-ml-1932595927"></a>
### emit_store_var_scoped

```ml
function emit_store_var_scoped(state, name, node)
```

Runs emit store var scoped.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `node` | `dynamic` | — | Value supplied for `node`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L1670)

<a id="function-function-mlc-codegen-codegen-scope-ensure-binding-for-write-function-ensure-binding-for-write-state-name-decl-node-mlc-codegen-codegen-scope-ml-150283678"></a>
### ensure_binding_for_write

```ml
function ensure_binding_for_write(state, name, decl_node)
```

Implements ensure binding for write.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `decl_node` | `dynamic` | — | Value supplied for `decl_node`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L1400)

<a id="function-function-mlc-codegen-codegen-scope-frame-count-inline-function-frame-count-frame-mlc-codegen-codegen-scope-ml-2061155255"></a>
### frame_count

```ml
inline function frame_count(frame)
```

Returns the number of bindings stored in a compiler frame.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frame` | `dynamic` | — | Value supplied for `frame`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L145)

<a id="function-function-mlc-codegen-codegen-scope-frame-finish-inline-function-frame-finish-frame-mlc-codegen-codegen-scope-ml-98807871"></a>
### frame_finish

```ml
inline function frame_finish(frame)
```

Materializes the live bindings from a compiler frame.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frame` | `dynamic` | — | Value supplied for `frame`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L183)

<a id="function-function-mlc-codegen-codegen-scope-frame-get-inline-function-frame-get-frame-idx-mlc-codegen-codegen-scope-ml-734111256"></a>
### frame_get

```ml
inline function frame_get(frame, idx)
```

Returns one binding from a compiler frame.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frame` | `dynamic` | — | Value supplied for `frame`. |
| `idx` | `dynamic` | — | Value supplied for `idx`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L154)

<a id="function-function-mlc-codegen-codegen-scope-frame-push-inline-function-frame-push-frame-value-mlc-codegen-codegen-scope-ml-338635704"></a>
### frame_push

```ml
inline function frame_push(frame, value)
```

Appends a binding to a compiler frame.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frame` | `dynamic` | — | Value supplied for `frame`. |
| `value` | `dynamic` | — | Value to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L173)

<a id="function-function-mlc-codegen-codegen-scope-frame-set-inline-function-frame-set-frame-idx-value-mlc-codegen-codegen-scope-ml-982770623"></a>
### frame_set

```ml
inline function frame_set(frame, idx, value)
```

Updates one binding in a compiler frame.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frame` | `dynamic` | — | Value supplied for `frame`. |
| `idx` | `dynamic` | — | Value supplied for `idx`. |
| `value` | `dynamic` | — | Value to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L164)

<a id="function-function-mlc-codegen-codegen-scope-is-ident-function-is-ident-s-mlc-codegen-codegen-scope-ml-624417624"></a>
### is_ident

```ml
function is_ident(s)
```

Reports whether is ident.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `s` | `dynamic` | — | Value supplied for `s`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L876)

<a id="function-function-mlc-codegen-codegen-scope-materialize-global-binding-root-function-materialize-global-binding-root-state-name-mlc-codegen-codegen-scope-ml-124725415"></a>
### materialize_global_binding_root

```ml
function materialize_global_binding_root(state, name)
```

Implements materialize global binding root.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L1237)

<a id="function-function-mlc-codegen-codegen-scope-new-label-id-function-new-label-id-state-mlc-codegen-codegen-scope-ml-673792072"></a>
### new_label_id

```ml
function new_label_id(state)
```

Creates new label id.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L435)

<a id="function-function-mlc-codegen-codegen-scope-pop-scope-function-pop-scope-state-emit-cleanup-mlc-codegen-codegen-scope-ml-756384492"></a>
### pop_scope

```ml
function pop_scope(state, emit_cleanup)
```

Implements pop scope.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `emit_cleanup` | `dynamic` | — | Value supplied for `emit_cleanup`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L951)

<a id="function-function-mlc-codegen-codegen-scope-push-scope-function-push-scope-state-mlc-codegen-codegen-scope-ml-533749804"></a>
### push_scope

```ml
function push_scope(state)
```

Updates push scope.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L944)

<a id="function-function-mlc-codegen-codegen-scope-register-decl-site-binding-function-register-decl-site-binding-state-node-name-binding-mlc-codegen-codegen-scope-ml-1681346154"></a>
### register_decl_site_binding

```ml
function register_decl_site_binding(state, node, name, binding)
```

Implements register decl site binding.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `node` | `dynamic` | — | Value supplied for `node`. |
| `name` | `dynamic` | — | Name of the requested item. |
| `binding` | `dynamic` | — | Value supplied for `binding`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L1387)

<a id="function-function-mlc-codegen-codegen-scope-resolve-binding-function-resolve-binding-state-name-mlc-codegen-codegen-scope-ml-808967299"></a>
### resolve_binding

```ml
function resolve_binding(state, name)
```

Implements resolve binding.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L970)

<a id="function-function-mlc-codegen-codegen-scope-resolve-binding-for-write-function-resolve-binding-for-write-state-name-mlc-codegen-codegen-scope-ml-1783653563"></a>
### resolve_binding_for_write

```ml
function resolve_binding_for_write(state, name)
```

Implements resolve binding for write.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |
| `name` | `dynamic` | — | Name of the requested item. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L977)

<a id="function-function-mlc-codegen-codegen-scope-scope-depth-function-scope-depth-state-mlc-codegen-codegen-scope-ml-1470761636"></a>
### scope_depth

```ml
function scope_depth(state)
```

Implements scope depth.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L848)

<a id="function-function-mlc-codegen-codegen-scope-scope-global-slots-function-scope-global-slots-state-mlc-codegen-codegen-scope-ml-2126650844"></a>
### scope_global_slots

```ml
function scope_global_slots(state)
```

Implements scope global slots.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L854)

<a id="function-function-mlc-codegen-codegen-scope-scope-setup-function-scope-setup-state-mlc-codegen-codegen-scope-ml-788759876"></a>
### scope_setup

```ml
function scope_setup(state)
```

Compatibility wrappers (Python CodegenScope parity).

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — | Value supplied for `state`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L842)

<a id="function-function-mlc-codegen-codegen-scope-search-function-search-obj-depth-mlc-codegen-codegen-scope-ml-1738047943"></a>
### search

```ml
function search(obj, depth)
```

Implements search.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `obj` | `dynamic` | — | Value supplied for `obj`. |
| `depth` | `dynamic` | — | Value supplied for `depth`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_scope.ml#L903)

- [mlc.codegen.codegen_scope.VarBinding](Type-mlc-codegen-codegen-scope-varbinding-2015539438.md) — struct
