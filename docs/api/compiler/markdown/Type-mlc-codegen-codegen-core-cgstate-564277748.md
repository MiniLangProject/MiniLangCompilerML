# `mlc.codegen.codegen_core.CgState`

[Home](README.md) · [Source file](File-mlc-codegen-codegen-core-ml-528695596.md)

<a id="struct-struct-mlc-codegen-codegen-core-cgstate-struct-cgstate-mlc-codegen-codegen-core-ml-2139355928"></a>
## CgState

```ml
struct CgState
```

Complete mutable state threaded through every backend emission function. Collection fields use indexed/capacity-backed representations on hot paths.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L33)

## Members

<a id="field-field-mlc-codegen-codegen-core-cgstate-cold-block-stack-cold-block-stack-mlc-codegen-codegen-core-ml-993020703"></a>
### _cold_block_stack

```ml
_cold_block_stack
```

Stores the cold block stack member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L231)

<a id="field-field-mlc-codegen-codegen-core-cgstate-current-root-rec-off-current-root-rec-off-mlc-codegen-codegen-core-ml-1076754375"></a>
### _current_root_rec_off

```ml
_current_root_rec_off
```

Stores the current root rec off member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L219)

<a id="field-field-mlc-codegen-codegen-core-cgstate-current-root-static-qwords-current-root-static-qwords-mlc-codegen-codegen-core-ml-526326183"></a>
### _current_root_static_qwords

```ml
_current_root_static_qwords
```

Stores the current root static qwords member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L221)

<a id="field-field-mlc-codegen-codegen-core-cgstate-expr-temp-reg-live-expr-temp-reg-live-mlc-codegen-codegen-core-ml-1092112787"></a>
### _expr_temp_reg_live

```ml
_expr_temp_reg_live
```

Stores the expr temp reg live member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L225)

<a id="field-field-mlc-codegen-codegen-core-cgstate-expr-temp-reg-live-by-reg-expr-temp-reg-live-by-reg-mlc-codegen-codegen-core-ml-221282943"></a>
### _expr_temp_reg_live_by_reg

```ml
_expr_temp_reg_live_by_reg
```

Stores the expr temp reg live by reg member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L227)

<a id="field-field-mlc-codegen-codegen-core-cgstate-expr-temp-reg-order-expr-temp-reg-order-mlc-codegen-codegen-core-ml-604185373"></a>
### _expr_temp_reg_order

```ml
_expr_temp_reg_order
```

Stores the expr temp reg order member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L223)

<a id="field-field-mlc-codegen-codegen-core-cgstate-expr-temp-reg-reserved-expr-temp-reg-reserved-mlc-codegen-codegen-core-ml-1161986019"></a>
### _expr_temp_reg_reserved

```ml
_expr_temp_reg_reserved
```

Stores the expr temp reg reserved member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L229)

<a id="field-field-mlc-codegen-codegen-core-cgstate-global-owner-file-global-owner-file-mlc-codegen-codegen-core-ml-1537112657"></a>
### _global_owner_file

```ml
_global_owner_file
```

Stores the global owner file member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L261)

<a id="field-field-mlc-codegen-codegen-core-cgstate-inline-call-stack-inline-call-stack-mlc-codegen-codegen-core-ml-1778522559"></a>
### _inline_call_stack

```ml
_inline_call_stack
```

Stores the inline call stack member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L235)

<a id="field-field-mlc-codegen-codegen-core-cgstate-inline-emitted-bytes-inline-emitted-bytes-mlc-codegen-codegen-core-ml-29198759"></a>
### _inline_emitted_bytes

```ml
_inline_emitted_bytes
```

Stores the inline emitted bytes member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L237)

<a id="field-field-mlc-codegen-codegen-core-cgstate-inline-param-stack-inline-param-stack-mlc-codegen-codegen-core-ml-48385819"></a>
### _inline_param_stack

```ml
_inline_param_stack
```

Stores the inline param stack member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L233)

<a id="field-field-mlc-codegen-codegen-core-cgstate-module-init-active-module-init-active-mlc-codegen-codegen-core-ml-1828102383"></a>
### _module_init_active

```ml
_module_init_active
```

Stores the module init active member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L257)

<a id="field-field-mlc-codegen-codegen-core-cgstate-module-init-active-file-module-init-active-file-mlc-codegen-codegen-core-ml-995593119"></a>
### _module_init_active_file

```ml
_module_init_active_file
```

Stores the module init active file member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L259)

<a id="field-field-mlc-codegen-codegen-core-cgstate-module-init-status-labels-module-init-status-labels-mlc-codegen-codegen-core-ml-254256469"></a>
### _module_init_status_labels

```ml
_module_init_status_labels
```

Stores the module init status labels member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L263)

<a id="field-field-mlc-codegen-codegen-core-cgstate-analysis-mode-analysis-mode-mlc-codegen-codegen-core-ml-1892412971"></a>
### analysis_mode

```ml
analysis_mode
```

Stores the analysis mode member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L195)

<a id="field-field-mlc-codegen-codegen-core-cgstate-asm-asm-mlc-codegen-codegen-core-ml-1491427983"></a>
### asm

```ml
asm
```

Stores the asm member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L57)

<a id="field-field-mlc-codegen-codegen-core-cgstate-binding-id-binding-id-mlc-codegen-codegen-core-ml-1867614257"></a>
### binding_id

```ml
binding_id
```

Stores the binding id member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L93)

<a id="field-field-mlc-codegen-codegen-core-cgstate-break-stack-break-stack-mlc-codegen-codegen-core-ml-1394174107"></a>
### break_stack

```ml
break_stack
```

Stores the break stack member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L67)

<a id="field-field-mlc-codegen-codegen-core-cgstate-bss-bss-mlc-codegen-codegen-core-ml-976545931"></a>
### bss

```ml
bss
```

Stores the bss member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L61)

<a id="field-field-mlc-codegen-codegen-core-cgstate-builtin-global-labels-builtin-global-labels-mlc-codegen-codegen-core-ml-248736255"></a>
### builtin_global_labels

```ml
builtin_global_labels
```

Stores the builtin global labels member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L135)

<a id="field-field-mlc-codegen-codegen-core-cgstate-builtin-specs-builtin-specs-mlc-codegen-codegen-core-ml-329746143"></a>
### builtin_specs

```ml
builtin_specs
```

Stores the builtin specs member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L133)

<a id="field-field-mlc-codegen-codegen-core-cgstate-builtin-static-obj-labels-builtin-static-obj-labels-mlc-codegen-codegen-core-ml-790278303"></a>
### builtin_static_obj_labels

```ml
builtin_static_obj_labels
```

Stores the builtin static obj labels member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L145)

<a id="field-field-mlc-codegen-codegen-core-cgstate-call-indirect-count-call-indirect-count-mlc-codegen-codegen-core-ml-2119111663"></a>
### call_indirect_count

```ml
call_indirect_count
```

Stores the call indirect count member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L153)

<a id="field-field-mlc-codegen-codegen-core-cgstate-call-profile-call-profile-mlc-codegen-codegen-core-ml-1519264663"></a>
### call_profile

```ml
call_profile
```

Stores the call profile member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L49)

<a id="field-field-mlc-codegen-codegen-core-cgstate-call-temp-base-call-temp-base-mlc-codegen-codegen-core-ml-1215044337"></a>
### call_temp_base

```ml
call_temp_base
```

Stores the call temp base member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L215)

<a id="field-field-mlc-codegen-codegen-core-cgstate-call-total-count-call-total-count-mlc-codegen-codegen-core-ml-715405665"></a>
### call_total_count

```ml
call_total_count
```

Stores the call total count member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L151)

<a id="field-field-mlc-codegen-codegen-core-cgstate-callprof-entries-callprof-entries-mlc-codegen-codegen-core-ml-408289363"></a>
### callprof_entries

```ml
callprof_entries
```

Stores the callprof entries member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L155)

<a id="field-field-mlc-codegen-codegen-core-cgstate-callprof-index-callprof-index-mlc-codegen-codegen-core-ml-1607163355"></a>
### callprof_index

```ml
callprof_index
```

Stores the callprof index member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L157)

<a id="field-field-mlc-codegen-codegen-core-cgstate-callprof-n-callprof-n-mlc-codegen-codegen-core-ml-1668446111"></a>
### callprof_n

```ml
callprof_n
```

Stores the callprof n member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L161)

<a id="field-field-mlc-codegen-codegen-core-cgstate-callprof-name-labels-callprof-name-labels-mlc-codegen-codegen-core-ml-1580467261"></a>
### callprof_name_labels

```ml
callprof_name_labels
```

Stores the callprof name labels member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L159)

<a id="field-field-mlc-codegen-codegen-core-cgstate-current-env-root-off-current-env-root-off-mlc-codegen-codegen-core-ml-848647703"></a>
### current_env_root_off

```ml
current_env_root_off
```

Stores the current env root off member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L183)

<a id="field-field-mlc-codegen-codegen-core-cgstate-current-file-prefix-current-file-prefix-mlc-codegen-codegen-core-ml-1750218151"></a>
### current_file_prefix

```ml
current_file_prefix
```

Stores the current file prefix member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L109)

<a id="field-field-mlc-codegen-codegen-core-cgstate-current-fn-boxed-names-current-fn-boxed-names-mlc-codegen-codegen-core-ml-829703319"></a>
### current_fn_boxed_names

```ml
current_fn_boxed_names
```

Stores the current fn boxed names member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L179)

<a id="field-field-mlc-codegen-codegen-core-cgstate-current-fn-env-index-current-fn-env-index-mlc-codegen-codegen-core-ml-1832794165"></a>
### current_fn_env_index

```ml
current_fn_env_index
```

Stores the current fn env index member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L181)

<a id="field-field-mlc-codegen-codegen-core-cgstate-current-qname-prefix-current-qname-prefix-mlc-codegen-codegen-core-ml-1962095445"></a>
### current_qname_prefix

```ml
current_qname_prefix
```

Stores the current qname prefix member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L107)

<a id="field-field-mlc-codegen-codegen-core-cgstate-data-data-mlc-codegen-codegen-core-ml-1572418539"></a>
### data

```ml
data
```

Stores the data member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L59)

<a id="field-field-mlc-codegen-codegen-core-cgstate-dbg-line-starts-dbg-line-starts-mlc-codegen-codegen-core-ml-1365178319"></a>
### dbg_line_starts

```ml
dbg_line_starts
```

Stores the dbg line starts member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L173)

<a id="field-field-mlc-codegen-codegen-core-cgstate-decl-site-bindings-decl-site-bindings-mlc-codegen-codegen-core-ml-483045621"></a>
### decl_site_bindings

```ml
decl_site_bindings
```

Stores the decl site bindings member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L253)

<a id="field-field-mlc-codegen-codegen-core-cgstate-diagnostics-diagnostics-mlc-codegen-codegen-core-ml-1739972551"></a>
### diagnostics

```ml
diagnostics
```

Stores the diagnostics member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L149)

<a id="field-field-mlc-codegen-codegen-core-cgstate-emitted-helpers-emitted-helpers-mlc-codegen-codegen-core-ml-583503047"></a>
### emitted_helpers

```ml
emitted_helpers
```

Stores the emitted helpers member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L87)

<a id="field-field-mlc-codegen-codegen-core-cgstate-enum-ids-enum-ids-mlc-codegen-codegen-core-ml-2013339927"></a>
### enum_ids

```ml
enum_ids
```

Stores the enum ids member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L77)

<a id="field-field-mlc-codegen-codegen-core-cgstate-enum-ids-index-enum-ids-index-mlc-codegen-codegen-core-ml-395559953"></a>
### enum_ids_index

```ml
enum_ids_index
```

Stores the enum ids index member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L205)

<a id="field-field-mlc-codegen-codegen-core-cgstate-enum-variants-enum-variants-mlc-codegen-codegen-core-ml-1894729303"></a>
### enum_variants

```ml
enum_variants
```

Stores the enum variants member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L75)

<a id="field-field-mlc-codegen-codegen-core-cgstate-enum-variants-index-enum-variants-index-mlc-codegen-codegen-core-ml-1463747807"></a>
### enum_variants_index

```ml
enum_variants_index
```

Stores the enum variants index member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L203)

<a id="field-field-mlc-codegen-codegen-core-cgstate-errprop-suppression-errprop-suppression-mlc-codegen-codegen-core-ml-45486431"></a>
### errprop_suppression

```ml
errprop_suppression
```

Stores the errprop suppression member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L169)

<a id="field-field-mlc-codegen-codegen-core-cgstate-errprop-sync-depth-errprop-sync-depth-mlc-codegen-codegen-core-ml-2013591327"></a>
### errprop_sync_depth

```ml
errprop_sync_depth
```

Stores the errprop sync depth member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L171)

<a id="field-field-mlc-codegen-codegen-core-cgstate-expr-temp-base-expr-temp-base-mlc-codegen-codegen-core-ml-722322695"></a>
### expr_temp_base

```ml
expr_temp_base
```

Stores the expr temp base member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L175)

<a id="field-field-mlc-codegen-codegen-core-cgstate-expr-temp-max-expr-temp-max-mlc-codegen-codegen-core-ml-35834363"></a>
### expr_temp_max

```ml
expr_temp_max
```

Stores the expr temp max member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L217)

<a id="field-field-mlc-codegen-codegen-core-cgstate-expr-temp-top-expr-temp-top-mlc-codegen-codegen-core-ml-278652735"></a>
### expr_temp_top

```ml
expr_temp_top
```

Stores the expr temp top member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L177)

<a id="field-field-mlc-codegen-codegen-core-cgstate-ext-widebuf-labels-ext-widebuf-labels-mlc-codegen-codegen-core-ml-1345219663"></a>
### ext_widebuf_labels

```ml
ext_widebuf_labels
```

Stores the ext widebuf labels member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L251)

<a id="field-field-mlc-codegen-codegen-core-cgstate-extern-abi-structs-extern-abi-structs-mlc-codegen-codegen-core-ml-2012425343"></a>
### extern_abi_structs

```ml
extern_abi_structs
```

Stores the extern abi structs member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L43)

<a id="field-field-mlc-codegen-codegen-core-cgstate-extern-global-labels-extern-global-labels-mlc-codegen-codegen-core-ml-824226583"></a>
### extern_global_labels

```ml
extern_global_labels
```

Stores the extern global labels member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L137)

<a id="field-field-mlc-codegen-codegen-core-cgstate-extern-sig-index-extern-sig-index-mlc-codegen-codegen-core-ml-1164465629"></a>
### extern_sig_index

```ml
extern_sig_index
```

Stores the extern sig index member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L211)

<a id="field-field-mlc-codegen-codegen-core-cgstate-extern-sigs-extern-sigs-mlc-codegen-codegen-core-ml-1205527963"></a>
### extern_sigs

```ml
extern_sigs
```

Stores the extern sigs member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L41)

<a id="field-field-mlc-codegen-codegen-core-cgstate-extern-static-obj-labels-extern-static-obj-labels-mlc-codegen-codegen-core-ml-1438939129"></a>
### extern_static_obj_labels

```ml
extern_static_obj_labels
```

Stores the extern static obj labels member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L147)

<a id="field-field-mlc-codegen-codegen-core-cgstate-extern-structs-extern-structs-mlc-codegen-codegen-core-ml-1793615933"></a>
### extern_structs

```ml
extern_structs
```

Stores the extern structs member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L45)

<a id="field-field-mlc-codegen-codegen-core-cgstate-extern-stub-labels-extern-stub-labels-mlc-codegen-codegen-core-ml-1030537913"></a>
### extern_stub_labels

```ml
extern_stub_labels
```

Stores the extern stub labels member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L139)

<a id="field-field-mlc-codegen-codegen-core-cgstate-file-prefix-map-file-prefix-map-mlc-codegen-codegen-core-ml-1325618887"></a>
### file_prefix_map

```ml
file_prefix_map
```

Stores the file prefix map member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L111)

<a id="field-field-mlc-codegen-codegen-core-cgstate-filename-filename-mlc-codegen-codegen-core-ml-617792241"></a>
### filename

```ml
filename
```

Stores the filename member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L37)

<a id="field-field-mlc-codegen-codegen-core-cgstate-func-frame-size-func-frame-size-mlc-codegen-codegen-core-ml-870841691"></a>
### func_frame_size

```ml
func_frame_size
```

Stores the func frame size member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L167)

<a id="field-field-mlc-codegen-codegen-core-cgstate-func-global-map-func-global-map-mlc-codegen-codegen-core-ml-142341191"></a>
### func_global_map

```ml
func_global_map
```

Stores the func global map member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L103)

<a id="field-field-mlc-codegen-codegen-core-cgstate-func-global-map-index-func-global-map-index-mlc-codegen-codegen-core-ml-433919895"></a>
### func_global_map_index

```ml
func_global_map_index
```

Stores the func global map index member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L189)

<a id="field-field-mlc-codegen-codegen-core-cgstate-func-globals-func-globals-mlc-codegen-codegen-core-ml-1995370697"></a>
### func_globals

```ml
func_globals
```

Stores the func globals member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L101)

<a id="field-field-mlc-codegen-codegen-core-cgstate-func-ret-label-func-ret-label-mlc-codegen-codegen-core-ml-1949570421"></a>
### func_ret_label

```ml
func_ret_label
```

Stores the func ret label member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L165)

<a id="field-field-mlc-codegen-codegen-core-cgstate-function-codegen-name-map-function-codegen-name-map-mlc-codegen-codegen-core-ml-652813071"></a>
### function_codegen_name_map

```ml
function_codegen_name_map
```

Stores the function codegen name map member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L193)

<a id="field-field-mlc-codegen-codegen-core-cgstate-function-global-labels-function-global-labels-mlc-codegen-codegen-core-ml-991344963"></a>
### function_global_labels

```ml
function_global_labels
```

Stores the function global labels member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L129)

<a id="field-field-mlc-codegen-codegen-core-cgstate-function-local-ids-function-local-ids-mlc-codegen-codegen-core-ml-1896792313"></a>
### function_local_ids

```ml
function_local_ids
```

Stores the function local ids member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L255)

<a id="field-field-mlc-codegen-codegen-core-cgstate-function-locals-function-locals-mlc-codegen-codegen-core-ml-1481375079"></a>
### function_locals

```ml
function_locals
```

Stores the function locals member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L105)

<a id="field-field-mlc-codegen-codegen-core-cgstate-function-static-obj-labels-function-static-obj-labels-mlc-codegen-codegen-core-ml-382208033"></a>
### function_static_obj_labels

```ml
function_static_obj_labels
```

Stores the function static obj labels member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L141)

<a id="field-field-mlc-codegen-codegen-core-cgstate-global-slots-global-slots-mlc-codegen-codegen-core-ml-978148893"></a>
### global_slots

```ml
global_slots
```

Stores the global slots member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L95)

<a id="field-field-mlc-codegen-codegen-core-cgstate-globals-globals-mlc-codegen-codegen-core-ml-177096271"></a>
### globals

```ml
globals
```

Stores the globals member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L97)

<a id="field-field-mlc-codegen-codegen-core-cgstate-heap-config-heap-config-mlc-codegen-codegen-core-ml-644603631"></a>
### heap_config

```ml
heap_config
```

Stores the heap config member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L47)

<a id="field-field-mlc-codegen-codegen-core-cgstate-import-alias-index-import-alias-index-mlc-codegen-codegen-core-ml-631561985"></a>
### import_alias_index

```ml
import_alias_index
```

Stores the import alias index member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L213)

<a id="field-field-mlc-codegen-codegen-core-cgstate-import-aliases-import-aliases-mlc-codegen-codegen-core-ml-188295167"></a>
### import_aliases

```ml
import_aliases
```

Stores the import aliases member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L39)

<a id="field-field-mlc-codegen-codegen-core-cgstate-imports-imports-mlc-codegen-codegen-core-ml-853271119"></a>
### imports

```ml
imports
```

Stores the imports member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L55)

<a id="field-field-mlc-codegen-codegen-core-cgstate-in-function-in-function-mlc-codegen-codegen-core-ml-2100415467"></a>
### in_function

```ml
in_function
```

Stores the in function member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L99)

<a id="field-field-mlc-codegen-codegen-core-cgstate-inline-only-functions-inline-only-functions-mlc-codegen-codegen-core-ml-860078815"></a>
### inline_only_functions

```ml
inline_only_functions
```

Stores the inline only functions member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L247)

<a id="field-field-mlc-codegen-codegen-core-cgstate-is-linux-target-is-linux-target-mlc-codegen-codegen-core-ml-966497423"></a>
### is_linux_target

```ml
is_linux_target
```

Stores the is linux target member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L271)

<a id="field-field-mlc-codegen-codegen-core-cgstate-is-windows-subsystem-is-windows-subsystem-mlc-codegen-codegen-core-ml-772601695"></a>
### is_windows_subsystem

```ml
is_windows_subsystem
```

Stores the is windows subsystem member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L163)

<a id="field-field-mlc-codegen-codegen-core-cgstate-known-int-names-known-int-names-mlc-codegen-codegen-core-ml-2091869711"></a>
### known_int_names

```ml
known_int_names
```

Stores the known int names member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L241)

<a id="field-field-mlc-codegen-codegen-core-cgstate-known-value-types-known-value-types-mlc-codegen-codegen-core-ml-1246710971"></a>
### known_value_types

```ml
known_value_types
```

Stores the known value types member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L243)

<a id="field-field-mlc-codegen-codegen-core-cgstate-label-id-label-id-mlc-codegen-codegen-core-ml-895800375"></a>
### label_id

```ml
label_id
```

Stores the label id member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L83)

<a id="field-field-mlc-codegen-codegen-core-cgstate-loop-index-fast-stack-loop-index-fast-stack-mlc-codegen-codegen-core-ml-1315654287"></a>
### loop_index_fast_stack

```ml
loop_index_fast_stack
```

Stores the loop index fast stack member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L245)

<a id="field-field-mlc-codegen-codegen-core-cgstate-max-inline-call-args-global-max-inline-call-args-global-mlc-codegen-codegen-core-ml-2023219859"></a>
### max_inline_call_args_global

```ml
max_inline_call_args_global
```

Stores the max inline call args global member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L239)

<a id="field-field-mlc-codegen-codegen-core-cgstate-mem-probe-mem-probe-mlc-codegen-codegen-core-ml-270436295"></a>
### mem_probe

```ml
mem_probe
```

Stores the mem probe member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L53)

<a id="field-field-mlc-codegen-codegen-core-cgstate-native-threads-possible-native-threads-possible-mlc-codegen-codegen-core-ml-878101539"></a>
### native_threads_possible

```ml
native_threads_possible
```

Stores the native threads possible member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L265)

<a id="field-field-mlc-codegen-codegen-core-cgstate-nested-user-functions-nested-user-functions-mlc-codegen-codegen-core-ml-238506555"></a>
### nested_user_functions

```ml
nested_user_functions
```

Stores the nested user functions member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L123)

<a id="field-field-mlc-codegen-codegen-core-cgstate-pruned-inline-functions-pruned-inline-functions-mlc-codegen-codegen-core-ml-1773356663"></a>
### pruned_inline_functions

```ml
pruned_inline_functions
```

Stores the pruned inline functions member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L249)

<a id="field-field-mlc-codegen-codegen-core-cgstate-qualify-cache-qualify-cache-mlc-codegen-codegen-core-ml-475979343"></a>
### qualify_cache

```ml
qualify_cache
```

Stores the qualify cache member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L197)

<a id="field-field-mlc-codegen-codegen-core-cgstate-rdata-rdata-mlc-codegen-codegen-core-ml-1750247495"></a>
### rdata

```ml
rdata
```

Stores the rdata member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L63)

<a id="field-field-mlc-codegen-codegen-core-cgstate-reserved-identifiers-reserved-identifiers-mlc-codegen-codegen-core-ml-922563053"></a>
### reserved_identifiers

```ml
reserved_identifiers
```

Stores the reserved identifiers member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L81)

<a id="field-field-mlc-codegen-codegen-core-cgstate-scope-declared-scope-declared-mlc-codegen-codegen-core-ml-1007634773"></a>
### scope_declared

```ml
scope_declared
```

Stores the scope declared member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L91)

<a id="field-field-mlc-codegen-codegen-core-cgstate-scope-declared-index-stack-scope-declared-index-stack-mlc-codegen-codegen-core-ml-1221869181"></a>
### scope_declared_index_stack

```ml
scope_declared_index_stack
```

Stores the scope declared index stack member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L187)

<a id="field-field-mlc-codegen-codegen-core-cgstate-scope-index-stack-scope-index-stack-mlc-codegen-codegen-core-ml-1962602531"></a>
### scope_index_stack

```ml
scope_index_stack
```

Stores the scope index stack member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L185)

<a id="field-field-mlc-codegen-codegen-core-cgstate-scope-stack-scope-stack-mlc-codegen-codegen-core-ml-1039237223"></a>
### scope_stack

```ml
scope_stack
```

Stores the scope stack member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L89)

<a id="field-field-mlc-codegen-codegen-core-cgstate-source-source-mlc-codegen-codegen-core-ml-872290225"></a>
### source

```ml
source
```

Stores the source member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L35)

<a id="field-field-mlc-codegen-codegen-core-cgstate-struct-field-types-struct-field-types-mlc-codegen-codegen-core-ml-984046423"></a>
### struct_field_types

```ml
struct_field_types
```

Stores the struct field types member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L71)

<a id="field-field-mlc-codegen-codegen-core-cgstate-struct-fields-struct-fields-mlc-codegen-codegen-core-ml-769295967"></a>
### struct_fields

```ml
struct_fields
```

Stores the struct fields member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L69)

<a id="field-field-mlc-codegen-codegen-core-cgstate-struct-fields-index-struct-fields-index-mlc-codegen-codegen-core-ml-964953815"></a>
### struct_fields_index

```ml
struct_fields_index
```

Stores the struct fields index member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L199)

<a id="field-field-mlc-codegen-codegen-core-cgstate-struct-global-labels-struct-global-labels-mlc-codegen-codegen-core-ml-566087665"></a>
### struct_global_labels

```ml
struct_global_labels
```

Stores the struct global labels member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L131)

<a id="field-field-mlc-codegen-codegen-core-cgstate-struct-ids-struct-ids-mlc-codegen-codegen-core-ml-1178253487"></a>
### struct_ids

```ml
struct_ids
```

Stores the struct ids member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L73)

<a id="field-field-mlc-codegen-codegen-core-cgstate-struct-ids-index-struct-ids-index-mlc-codegen-codegen-core-ml-650404925"></a>
### struct_ids_index

```ml
struct_ids_index
```

Stores the struct ids index member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L201)

<a id="field-field-mlc-codegen-codegen-core-cgstate-struct-methods-struct-methods-mlc-codegen-codegen-core-ml-1433170811"></a>
### struct_methods

```ml
struct_methods
```

Stores the struct methods member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L125)

<a id="field-field-mlc-codegen-codegen-core-cgstate-struct-methods-index-struct-methods-index-mlc-codegen-codegen-core-ml-1418923049"></a>
### struct_methods_index

```ml
struct_methods_index
```

Stores the struct methods index member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L207)

<a id="field-field-mlc-codegen-codegen-core-cgstate-struct-static-methods-struct-static-methods-mlc-codegen-codegen-core-ml-1756916723"></a>
### struct_static_methods

```ml
struct_static_methods
```

Stores the struct static methods member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L127)

<a id="field-field-mlc-codegen-codegen-core-cgstate-struct-static-methods-index-struct-static-methods-index-mlc-codegen-codegen-core-ml-113557655"></a>
### struct_static_methods_index

```ml
struct_static_methods_index
```

Stores the struct static methods index member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L209)

<a id="field-field-mlc-codegen-codegen-core-cgstate-struct-static-obj-labels-struct-static-obj-labels-mlc-codegen-codegen-core-ml-724662519"></a>
### struct_static_obj_labels

```ml
struct_static_obj_labels
```

Stores the struct static obj labels member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L143)

<a id="field-field-mlc-codegen-codegen-core-cgstate-synchronized-globals-synchronized-globals-mlc-codegen-codegen-core-ml-408175677"></a>
### synchronized_globals

```ml
synchronized_globals
```

Stores the synchronized globals member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L267)

<a id="field-field-mlc-codegen-codegen-core-cgstate-target-target-mlc-codegen-codegen-core-ml-69228077"></a>
### target

```ml
target
```

Stores the target member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L269)

<a id="field-field-mlc-codegen-codegen-core-cgstate-trace-calls-trace-calls-mlc-codegen-codegen-core-ml-507625855"></a>
### trace_calls

```ml
trace_calls
```

Stores the trace calls member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L51)

<a id="field-field-mlc-codegen-codegen-core-cgstate-typename-enum-by-id-typename-enum-by-id-mlc-codegen-codegen-core-ml-442694963"></a>
### typename_enum_by_id

```ml
typename_enum_by_id
```

Stores the typename enum by id member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L117)

<a id="field-field-mlc-codegen-codegen-core-cgstate-typename-enum-by-qname-typename-enum-by-qname-mlc-codegen-codegen-core-ml-378078007"></a>
### typename_enum_by_qname

```ml
typename_enum_by_qname
```

Stores the typename enum by qname member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L119)

<a id="field-field-mlc-codegen-codegen-core-cgstate-typename-struct-by-id-typename-struct-by-id-mlc-codegen-codegen-core-ml-364376455"></a>
### typename_struct_by_id

```ml
typename_struct_by_id
```

Stores the typename struct by id member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L113)

<a id="field-field-mlc-codegen-codegen-core-cgstate-typename-struct-by-qname-typename-struct-by-qname-mlc-codegen-codegen-core-ml-1749066743"></a>
### typename_struct_by_qname

```ml
typename_struct_by_qname
```

Stores the typename struct by qname member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L115)

<a id="field-field-mlc-codegen-codegen-core-cgstate-used-helpers-used-helpers-mlc-codegen-codegen-core-ml-331095105"></a>
### used_helpers

```ml
used_helpers
```

Stores the used helpers member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L85)

<a id="field-field-mlc-codegen-codegen-core-cgstate-user-function-index-user-function-index-mlc-codegen-codegen-core-ml-1128188351"></a>
### user_function_index

```ml
user_function_index
```

Stores the user function index member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L191)

<a id="field-field-mlc-codegen-codegen-core-cgstate-user-functions-user-functions-mlc-codegen-codegen-core-ml-603078413"></a>
### user_functions

```ml
user_functions
```

Stores the user functions member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L121)

<a id="field-field-mlc-codegen-codegen-core-cgstate-value-enum-values-value-enum-values-mlc-codegen-codegen-core-ml-1996817439"></a>
### value_enum_values

```ml
value_enum_values
```

Stores the value enum values member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L79)

<a id="field-field-mlc-codegen-codegen-core-cgstate-var-slots-var-slots-mlc-codegen-codegen-core-ml-851708719"></a>
### var_slots

```ml
var_slots
```

Stores the var slots member of `CgState`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_core.ml#L65)
