# `mlc/codegen/codegen.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc codegen codegen package.

Package: [`mlc.codegen.codegen`](Package-mlc-codegen-codegen-123168249.md)

Reachable from entry: **yes**

## Imports

- `mlc/asm.ml` as `a` → [mlc/asm.ml](File-mlc-asm-ml-1368648960.md)
- `mlc/codegen/codegen_builtins_alloc.ml` as `bal` → [mlc/codegen/codegen_builtins_alloc.ml](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- `mlc/codegen/codegen_core.ml` as `core` → [mlc/codegen/codegen_core.ml](File-mlc-codegen-codegen-core-ml-528695596.md)
- `mlc/codegen/codegen_expr.ml` as `exprmod` → [mlc/codegen/codegen_expr.ml](File-mlc-codegen-codegen-expr-ml-59843844.md)
- `mlc/codegen/codegen_memory.ml` as `mem` → [mlc/codegen/codegen_memory.ml](File-mlc-codegen-codegen-memory-ml-2136639668.md)
- `mlc/codegen/codegen_runtime.ml` as `rt` → [mlc/codegen/codegen_runtime.ml](File-mlc-codegen-codegen-runtime-ml-1845689217.md)
- `mlc/codegen/codegen_scope.ml` as `scope` → [mlc/codegen/codegen_scope.ml](File-mlc-codegen-codegen-scope-ml-1124416197.md)
- `mlc/codegen/codegen_stmt.ml` as `stmt` → [mlc/codegen/codegen_stmt.ml](File-mlc-codegen-codegen-stmt-ml-1158291323.md)
- `mlc/constants.ml` as `c` → [mlc/constants.ml](File-mlc-constants-ml-1024884042.md)
- `mlc/data.ml` as `d` → [mlc/data.ml](File-mlc-data-ml-557434521.md)
- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)

## Declarations

<a id="function-function-mlc-codegen-codegen-init-function-init-cg-mlc-codegen-codegen-ml-841707717"></a>
### __init__

```ml
function __init__(cg)
```

Implements init.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cg` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L279)

<a id="function-function-mlc-codegen-codegen-arr-has-function-arr-has-arr-value-mlc-codegen-codegen-ml-1028508207"></a>
### _arr_has

```ml
function _arr_has(arr, value)
```

Implements arr has.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L41)

<a id="function-function-mlc-codegen-codegen-clone-state-for-object-function-clone-state-for-object-base-seed-runtime-mlc-codegen-codegen-ml-970806124"></a>
### _clone_state_for_object

```ml
function _clone_state_for_object(base, seed_runtime)
```

Implements clone state for object.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `base` | `dynamic` | — |  |
| `seed_runtime` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L304)

<a id="function-function-mlc-codegen-codegen-copy-array-function-copy-array-arr-mlc-codegen-codegen-ml-2074558282"></a>
### _copy_array

```ml
function _copy_array(arr)
```

Implements copy array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L108)

<a id="function-function-mlc-codegen-codegen-copy-bss-builder-function-copy-bss-builder-bb-mlc-codegen-codegen-ml-1612033673"></a>
### _copy_bss_builder

```ml
function _copy_bss_builder(bb)
```

Implements copy bss builder.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bb` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L190)

<a id="function-function-mlc-codegen-codegen-copy-bytes-function-copy-bytes-buf-mlc-codegen-codegen-ml-1774213728"></a>
### _copy_bytes

```ml
function _copy_bytes(buf)
```

Implements copy bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buf` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L97)

<a id="function-function-mlc-codegen-codegen-copy-data-builder-function-copy-data-builder-db-mlc-codegen-codegen-ml-122450253"></a>
### _copy_data_builder

```ml
function _copy_data_builder(db)
```

Implements copy data builder.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `db` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L178)

<a id="function-function-mlc-codegen-codegen-copy-fastmap-function-copy-fastmap-mapv-mlc-codegen-codegen-ml-1136249237"></a>
### _copy_fastmap

```ml
function _copy_fastmap(mapv)
```

Implements copy fastmap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L157)

<a id="function-function-mlc-codegen-codegen-copy-fastmap-stack-function-copy-fastmap-stack-frames-mlc-codegen-codegen-ml-731968205"></a>
### _copy_fastmap_stack

```ml
function _copy_fastmap_stack(frames)
```

Implements copy fastmap stack.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frames` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L137)

<a id="function-function-mlc-codegen-codegen-copy-frame-stack-function-copy-frame-stack-frames-mlc-codegen-codegen-ml-1246990299"></a>
### _copy_frame_stack

```ml
function _copy_frame_stack(frames)
```

Implements copy frame stack.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `frames` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L115)

<a id="function-function-mlc-codegen-codegen-copy-rdata-builder-function-copy-rdata-builder-rb-mlc-codegen-codegen-ml-1574846649"></a>
### _copy_rdata_builder

```ml
function _copy_rdata_builder(rb)
```

Implements copy rdata builder.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rb` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L200)

<a id="function-function-mlc-codegen-codegen-named-array-set-function-named-array-set-arr-key-values-mlc-codegen-codegen-ml-1981320995"></a>
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


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L51)

<a id="function-function-mlc-codegen-codegen-named-int-set-function-named-int-set-arr-key-value-mlc-codegen-codegen-ml-1790917330"></a>
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


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L65)

<a id="function-function-mlc-codegen-codegen-sparse-data-builder-function-sparse-data-builder-base-db-mlc-codegen-codegen-ml-1087127649"></a>
### _sparse_data_builder

```ml
function _sparse_data_builder(base_db)
```

Implements sparse data builder.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `base_db` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L216)

<a id="function-function-mlc-codegen-codegen-sparse-rdata-builder-function-sparse-rdata-builder-base-rb-mlc-codegen-codegen-ml-1887087327"></a>
### _sparse_rdata_builder

```ml
function _sparse_rdata_builder(base_rb)
```

Implements sparse rdata builder.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `base_rb` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L228)

<a id="function-function-mlc-codegen-codegen-all-function-entries-function-all-function-entries-cg-mlc-codegen-codegen-ml-274900665"></a>
### all_function_entries

```ml
function all_function_entries(cg)
```

Implements all function entries.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cg` | `dynamic` | — | Value supplied for `cg`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L529)

<a id="function-function-mlc-codegen-codegen-clear-program-function-state-function-clear-program-function-state-cg-mlc-codegen-codegen-ml-182666621"></a>
### clear_program_function_state

```ml
function clear_program_function_state(cg)
```

Drop program-analysis records once every user function has been emitted. Runtime helpers and extern stubs only need the prepared metadata and section builders; retaining the full function AST here makes large object builds repeatedly collect an almost entirely live compiler heap.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cg` | `dynamic` | — | Value supplied for `cg`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L605)

<a id="function-function-mlc-codegen-codegen-clone-for-object-function-clone-for-object-cg-seed-runtime-mlc-codegen-codegen-ml-2129459047"></a>
### clone_for_object

```ml
function clone_for_object(cg, seed_runtime)
```

Implements clone for object.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cg` | `dynamic` | — | Value supplied for `cg`. |
| `seed_runtime` | `dynamic` | — | Value supplied for `seed_runtime`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L447)

- [mlc.codegen.codegen.Codegen](Type-mlc-codegen-codegen-codegen-1040250862.md) — struct
<a id="function-function-mlc-codegen-codegen-emit-entry-object-function-emit-entry-object-cg-module-init-recs-max-call-args-main-main-name-mlc-codegen-codegen-ml-1084668338"></a>
### emit_entry_object

```ml
function emit_entry_object(cg, module_init_recs, max_call_args_main, main_name)
```

Runs emit entry object.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cg` | `dynamic` | — | Value supplied for `cg`. |
| `module_init_recs` | `dynamic` | — | Value supplied for `module_init_recs`. |
| `max_call_args_main` | `dynamic` | — | Value supplied for `max_call_args_main`. |
| `main_name` | `dynamic` | — | Value supplied for `main_name`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L488)

<a id="function-function-mlc-codegen-codegen-emit-extern-stubs-function-emit-extern-stubs-cg-mlc-codegen-codegen-ml-59230413"></a>
### emit_extern_stubs

```ml
function emit_extern_stubs(cg)
```

Runs emit extern stubs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cg` | `dynamic` | — | Value supplied for `cg`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L587)

<a id="function-function-mlc-codegen-codegen-emit-module-function-entries-function-emit-module-function-entries-cg-entries-start-index-count-analysis-scratch-mlc-codegen-codegen-ml-608867126"></a>
### emit_module_function_entries

```ml
function emit_module_function_entries(cg, entries, start_index, count, analysis_scratch)
```

Runs emit module function entries.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cg` | `dynamic` | — | Value supplied for `cg`. |
| `entries` | `dynamic` | — | Value supplied for `entries`. |
| `start_index` | `dynamic` | — | Value supplied for `start_index`. |
| `count` | `dynamic` | — | Number of items to process. |
| `analysis_scratch` | `dynamic` | — | Value supplied for `analysis_scratch`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L565)

<a id="function-function-mlc-codegen-codegen-emit-module-functions-function-emit-module-functions-cg-module-file-mlc-codegen-codegen-ml-1937406640"></a>
### emit_module_functions

```ml
function emit_module_functions(cg, module_file)
```

Runs emit module functions.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cg` | `dynamic` | — | Value supplied for `cg`. |
| `module_file` | `dynamic` | — | Value supplied for `module_file`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L510)

<a id="function-function-mlc-codegen-codegen-emit-module-init-object-function-emit-module-init-object-cg-module-rec-mlc-codegen-codegen-ml-168585754"></a>
### emit_module_init_object

```ml
function emit_module_init_object(cg, module_rec)
```

Runs emit module init object.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cg` | `dynamic` | — | Value supplied for `cg`. |
| `module_rec` | `dynamic` | — | Value supplied for `module_rec`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L499)

<a id="function-function-mlc-codegen-codegen-emit-program-function-emit-program-cg-program-mlc-codegen-codegen-ml-1765725431"></a>
### emit_program

```ml
function emit_program(cg, program)
```

Runs emit program.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cg` | `dynamic` | — | Value supplied for `cg`. |
| `program` | `dynamic` | — | Value supplied for `program`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L290)

<a id="function-function-mlc-codegen-codegen-emit-used-helpers-function-emit-used-helpers-cg-mlc-codegen-codegen-ml-858884679"></a>
### emit_used_helpers

```ml
function emit_used_helpers(cg)
```

Runs emit used helpers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cg` | `dynamic` | — | Value supplied for `cg`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L596)

<a id="function-function-mlc-codegen-codegen-enable-call-profile-metadata-function-enable-call-profile-metadata-cg-mlc-codegen-codegen-ml-1239671869"></a>
### enable_call_profile_metadata

```ml
function enable_call_profile_metadata(cg)
```

Implements enable call profile metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cg` | `dynamic` | — | Value supplied for `cg`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L79)

<a id="function-function-mlc-codegen-codegen-function-entry-count-function-function-entry-count-entries-mlc-codegen-codegen-ml-56127929"></a>
### function_entry_count

```ml
function function_entry_count(entries)
```

Implements function entry count.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entries` | `dynamic` | — | Value supplied for `entries`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L537)

<a id="function-function-mlc-codegen-codegen-function-entry-name-function-function-entry-name-entries-node-id-mlc-codegen-codegen-ml-1465721125"></a>
### function_entry_name

```ml
function function_entry_name(entries, node_id)
```

Implements function entry name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entries` | `dynamic` | — | Value supplied for `entries`. |
| `node_id` | `dynamic` | — | Value supplied for `node_id`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L544)

<a id="function-function-mlc-codegen-codegen-module-function-entries-function-module-function-entries-cg-module-file-mlc-codegen-codegen-ml-22499336"></a>
### module_function_entries

```ml
function module_function_entries(cg, module_file)
```

Implements module function entries.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cg` | `dynamic` | — | Value supplied for `cg`. |
| `module_file` | `dynamic` | — | Value supplied for `module_file`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L521)

<a id="function-function-mlc-codegen-codegen-new-function-analysis-scratch-function-new-function-analysis-scratch-mlc-codegen-codegen-ml-26912121"></a>
### new_function_analysis_scratch

```ml
function new_function_analysis_scratch()
```

Allocate one reusable workspace for the serial per-function analyses. Object emitters keep it outside cloned codegen state and pass it across fragments.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L549)

<a id="function-function-mlc-codegen-codegen-newcodegen-function-newcodegen-source-filename-import-aliases-extern-sigs-extern-structs-mlc-codegen-codegen-ml-882947353"></a>
### newCodegen

```ml
function newCodegen(source, filename, import_aliases, extern_sigs, extern_structs)
```

Creates new codegen.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Source value to process. |
| `filename` | `dynamic` | — | Value supplied for `filename`. |
| `import_aliases` | `dynamic` | — | Value supplied for `import_aliases`. |
| `extern_sigs` | `dynamic` | — | Value supplied for `extern_sigs`. |
| `extern_structs` | `dynamic` | — | Value supplied for `extern_structs`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L246)

<a id="function-function-mlc-codegen-codegen-newcodegenfortarget-function-newcodegenfortarget-source-filename-import-aliases-extern-sigs-extern-structs-target-heap-config-mlc-codegen-codegen-ml-16619175"></a>
### newCodegenForTarget

```ml
function newCodegenForTarget(source, filename, import_aliases, extern_sigs, extern_structs, target, heap_config)
```

Creates new codegen for target.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — | Source value to process. |
| `filename` | `dynamic` | — | Value supplied for `filename`. |
| `import_aliases` | `dynamic` | — | Value supplied for `import_aliases`. |
| `extern_sigs` | `dynamic` | — | Value supplied for `extern_sigs`. |
| `extern_structs` | `dynamic` | — | Value supplied for `extern_structs`. |
| `target` | `dynamic` | — | Value supplied for `target`. |
| `heap_config` | `dynamic` | — | Value supplied for `heap_config`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L260)

<a id="function-function-mlc-codegen-codegen-prepare-program-for-objects-function-prepare-program-for-objects-cg-program-mlc-codegen-codegen-ml-1263654913"></a>
### prepare_program_for_objects

```ml
function prepare_program_for_objects(cg, program)
```

Implements prepare program for objects.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cg` | `dynamic` | — | Value supplied for `cg`. |
| `program` | `dynamic` | — | Value supplied for `program`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L466)

<a id="function-function-mlc-codegen-codegen-release-emitted-function-entries-function-release-emitted-function-entries-cg-entries-start-index-count-mlc-codegen-codegen-ml-1994472837"></a>
### release_emitted_function_entries

```ml
function release_emitted_function_entries(cg, entries, start_index, count)
```

Releases or resets release emitted function entries.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cg` | `dynamic` | — | Value supplied for `cg`. |
| `entries` | `dynamic` | — | Value supplied for `entries`. |
| `start_index` | `dynamic` | — | Value supplied for `start_index`. |
| `count` | `dynamic` | — | Number of items to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L578)

<a id="function-function-mlc-codegen-codegen-release-function-analysis-scratch-function-release-function-analysis-scratch-value-mlc-codegen-codegen-ml-2060943192"></a>
### release_function_analysis_scratch

```ml
function release_function_analysis_scratch(value)
```

Releases or resets release function analysis scratch.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L555)

<a id="function-function-mlc-codegen-codegen-set-target-function-set-target-cg-target-mlc-codegen-codegen-ml-211183960"></a>
### set_target

```ml
function set_target(cg, target)
```

Configure target-only state without perturbing the historical Windows seed layout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cg` | `dynamic` | — | Value supplied for `cg`. |
| `target` | `dynamic` | — | Value supplied for `target`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L269)

<a id="function-function-mlc-codegen-codegen-start-object-fragment-function-start-object-fragment-cg-mlc-codegen-codegen-ml-288289155"></a>
### start_object_fragment

```ml
function start_object_fragment(cg)
```

Start a new serialized text fragment without resetting semantic codegen state. Re-root the statement callback because object serialization may run a collection between function batches.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cg` | `dynamic` | — | Value supplied for `cg`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L455)

<a id="function-function-mlc-codegen-codegen-track-helper-function-track-helper-cg-label-mlc-codegen-codegen-ml-1967167001"></a>
### track_helper

```ml
function track_helper(cg, label)
```

Implements track helper.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cg` | `dynamic` | — | Value supplied for `cg`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen.ml#L615)
