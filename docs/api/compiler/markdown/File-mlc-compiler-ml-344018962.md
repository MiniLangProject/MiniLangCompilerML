# `mlc/compiler.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc compiler package.

Package: [`mlc.compiler`](Package-mlc-compiler-953928568.md)

Reachable from entry: **yes**

## Imports

- `mlc/asm.ml` as `a` → [mlc/asm.ml](File-mlc-asm-ml-1368648960.md)
- `mlc/codegen/codegen.ml` as `codegen` → [mlc/codegen/codegen.ml](File-mlc-codegen-codegen-ml-1154886880.md)
- `mlc/data.ml` as `d` → [mlc/data.ml](File-mlc-data-ml-557434521.md)
- `mlc/elf.ml` as `elf` → [mlc/elf.ml](File-mlc-elf-ml-1082822254.md)
- `mlc/frontend.ml` as `frontend` → [mlc/frontend.ml](File-mlc-frontend-ml-1929241497.md)
- `mlc/linux_runtime.ml` as `linuxrt` → [mlc/linux_runtime.ml](File-mlc-linux-runtime-ml-1485387394.md)
- `mlc/minilang_parser.ml` as `parser` → [mlc/minilang_parser.ml](File-mlc-minilang-parser-ml-1485036712.md)
- `mlc/pe.ml` as `pe` → [mlc/pe.ml](File-mlc-pe-ml-319201864.md)
- `mlc/project.ml` as `project` → [mlc/project.ml](File-mlc-project-ml-1332928426.md)
- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)
- `std/fs.ml` as `fs` → `std/fs.ml` — external dependency
- `std/process.ml` as `process` → `std/process.ml` — external dependency
- `std/string.ml` as `s` → `std/string.ml` — external dependency
- `std/string_builder.ml` as `sb` → `std/string_builder.ml` — external dependency
- `std/time.ml` as `mtime` → `std/time.ml` — external dependency

## Declarations

<a id="function-function-mlc-compiler-abi-param-type-supported-function-abi-param-type-supported-ty-mlc-compiler-ml-692046171"></a>
### _abi_param_type_supported

```ml
function _abi_param_type_supported(ty)
```

Perform the abi param type supported compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ty` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5570)

<a id="function-function-mlc-compiler-abi-return-type-supported-function-abi-return-type-supported-ty-mlc-compiler-ml-855809217"></a>
### _abi_return_type_supported

```ml
function _abi_return_type_supported(ty)
```

Perform the abi return type supported compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ty` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5577)

<a id="function-function-mlc-compiler-add-diag-function-add-diag-diags-kind-filename-pos-message-mlc-compiler-ml-1139238326"></a>
### _add_diag

```ml
function _add_diag(diags, kind, filename, pos, message)
```

Updates add diag.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `diags` | `dynamic` | — |  |
| `kind` | `dynamic` | — |  |
| `filename` | `dynamic` | — |  |
| `pos` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1361)

<a id="function-function-mlc-compiler-add-diag-from-stmt-function-add-diag-from-stmt-diags-kind-st-fallback-file-message-mlc-compiler-ml-1107149111"></a>
### _add_diag_from_stmt

```ml
function _add_diag_from_stmt(diags, kind, st, fallback_file, message)
```

Updates add diag from stmt.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `diags` | `dynamic` | — |  |
| `kind` | `dynamic` | — |  |
| `st` | `dynamic` | — |  |
| `fallback_file` | `dynamic` | — |  |
| `message` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1367)

<a id="function-function-mlc-compiler-alias-get-inline-function-alias-get-aliases-key-mlc-compiler-ml-824542376"></a>
### _alias_get

```ml
inline function _alias_get(aliases, key)
```

Perform the inline compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `aliases` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1410)

<a id="function-function-mlc-compiler-alias-set-function-alias-set-aliases-key-value-mlc-compiler-ml-2126573452"></a>
### _alias_set

```ml
function _alias_set(aliases, key, value)
```

Perform the alias set compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `aliases` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1425)

<a id="function-function-mlc-compiler-alias-to-array-function-alias-to-array-aliases-mlc-compiler-ml-1816199482"></a>
### _alias_to_array

```ml
function _alias_to_array(aliases)
```

Perform the alias to array compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `aliases` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1443)

<a id="function-function-mlc-compiler-append-unique-path-function-append-unique-path-arr-value-mlc-compiler-ml-1766843518"></a>
### _append_unique_path

```ml
function _append_unique_path(arr, value)
```

Updates append unique path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L991)

<a id="function-function-mlc-compiler-append-zero-pad-function-append-zero-pad-parts-b-pad-bytes-mlc-compiler-ml-1243409404"></a>
### _append_zero_pad

```ml
function _append_zero_pad(parts_b, pad_bytes)
```

Updates append zero pad.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parts_b` | `dynamic` | — |  |
| `pad_bytes` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1172)

<a id="function-function-mlc-compiler-apply-link-patches-function-apply-link-patches-patches-obj-off-label-map-labels-obj-label-recs-text-rva-rdata-rva-data-rva-bss-rva-image-base-section-buf-is-rel32-patch-index-unknown-prefix-invalid-prefix-mlc-compiler-ml-863587305"></a>
### _apply_link_patches

```ml
function _apply_link_patches(patches, obj_off, label_map, labels, obj_label_recs, text_rva, rdata_rva, data_rva, bss_rva, image_base, section_buf, is_rel32, patch_index, unknown_prefix, invalid_prefix)
```

Perform the apply link patches compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `patches` | `dynamic` | — |  |
| `obj_off` | `dynamic` | — |  |
| `label_map` | `dynamic` | — |  |
| `labels` | `dynamic` | — |  |
| `obj_label_recs` | `dynamic` | — |  |
| `text_rva` | `dynamic` | — |  |
| `rdata_rva` | `dynamic` | — |  |
| `data_rva` | `dynamic` | — |  |
| `bss_rva` | `dynamic` | — |  |
| `image_base` | `dynamic` | — |  |
| `section_buf` | `dynamic` | — |  |
| `is_rel32` | `dynamic` | — |  |
| `patch_index` | `dynamic` | — |  |
| `unknown_prefix` | `dynamic` | — |  |
| `invalid_prefix` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4525)

<a id="function-function-mlc-compiler-apply-mlo-patches-from-file-function-apply-mlo-patches-from-file-src-patch-obj-text-off-obj-rdata-off-obj-data-off-obj-bss-off-label-map-obj-index-map-obj-index-lists-labels-link-patch-recs-text-rva-rdata-rva-data-rva-bss-rva-image-base-buf-rdata-buf-data-buf-patch-index-mlc-compiler-ml-1410354060"></a>
### _apply_mlo_patches_from_file

```ml
function _apply_mlo_patches_from_file(src_patch, obj_text_off, obj_rdata_off, obj_data_off, obj_bss_off, label_map, obj_index_map, obj_index_lists, labels, link_patch_recs, text_rva, rdata_rva, data_rva, bss_rva, image_base, buf, rdata_buf, data_buf, patch_index)
```

Stream one object's relocations into final section buffers. Private labels stay object-relative; public/section/IAT targets resolve through shared maps.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `src_patch` | `dynamic` | — |  |
| `obj_text_off` | `dynamic` | — |  |
| `obj_rdata_off` | `dynamic` | — |  |
| `obj_data_off` | `dynamic` | — |  |
| `obj_bss_off` | `dynamic` | — |  |
| `label_map` | `dynamic` | — |  |
| `obj_index_map` | `dynamic` | — |  |
| `obj_index_lists` | `dynamic` | — |  |
| `labels` | `dynamic` | — |  |
| `link_patch_recs` | `dynamic` | — |  |
| `text_rva` | `dynamic` | — |  |
| `rdata_rva` | `dynamic` | — |  |
| `data_rva` | `dynamic` | — |  |
| `bss_rva` | `dynamic` | — |  |
| `image_base` | `dynamic` | — |  |
| `buf` | `dynamic` | — |  |
| `rdata_buf` | `dynamic` | — |  |
| `data_buf` | `dynamic` | — |  |
| `patch_index` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5149)

<a id="function-function-mlc-compiler-array-contains-inline-function-array-contains-arr-value-mlc-compiler-ml-173352891"></a>
### _array_contains

```ml
inline function _array_contains(arr, value)
```

Perform the inline compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L699)

<a id="function-function-mlc-compiler-asm-append-section-function-asm-append-section-bld-name-buf-rva-mlc-compiler-ml-495946549"></a>
### _asm_append_section

```ml
function _asm_append_section(bld, name, buf, rva)
```

Perform the asm append section compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bld` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `buf` | `dynamic` | — |  |
| `rva` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L7418)

<a id="function-function-mlc-compiler-asm-db-text-function-asm-db-text-hex-text-mlc-compiler-ml-2037720179"></a>
### _asm_db_text

```ml
function _asm_db_text(hex_text)
```

Perform the asm db text compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `hex_text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L7403)

<a id="function-function-mlc-compiler-asm-default-path-function-asm-default-path-output-exe-mlc-compiler-ml-913898962"></a>
### _asm_default_path

```ml
function _asm_default_path(output_exe)
```

Perform the asm default path compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `output_exe` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L7394)

<a id="global-global-mlc-compiler-asm-dump-data-asm-dump-data-mlc-compiler-ml-232683154"></a>
### _asm_dump_data

```ml
_asm_dump_data
```

Track asm dump data compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L419)

<a id="global-global-mlc-compiler-asm-dump-pe-asm-dump-pe-mlc-compiler-ml-1501664368"></a>
### _asm_dump_pe

```ml
_asm_dump_pe
```

Track asm dump pe compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L421)

<a id="global-global-mlc-compiler-asm-listing-enabled-asm-listing-enabled-mlc-compiler-ml-1066708500"></a>
### _asm_listing_enabled

```ml
_asm_listing_enabled
```

Track asm listing enabled compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L409)

<a id="global-global-mlc-compiler-asm-listing-path-asm-listing-path-mlc-compiler-ml-1574506214"></a>
### _asm_listing_path

```ml
_asm_listing_path
```

Track asm listing path compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L411)

<a id="global-global-mlc-compiler-asm-show-addr-asm-show-addr-mlc-compiler-ml-841709166"></a>
### _asm_show_addr

```ml
_asm_show_addr
```

Track asm show addr compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L413)

<a id="global-global-mlc-compiler-asm-show-bytes-asm-show-bytes-mlc-compiler-ml-530322702"></a>
### _asm_show_bytes

```ml
_asm_show_bytes
```

Track asm show bytes compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L415)

<a id="global-global-mlc-compiler-asm-show-code-asm-show-code-mlc-compiler-ml-1377549234"></a>
### _asm_show_code

```ml
_asm_show_code
```

Track asm show code compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L417)

<a id="function-function-mlc-compiler-auto-import-request-function-auto-import-request-line-mlc-compiler-ml-64664794"></a>
### _auto_import_request

```ml
function _auto_import_request(line)
```

Extract the path-like portion of a top-level import for the lightweight automatic-pipeline graph scan. The real parser still owns validation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `line` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2517)

<a id="function-function-mlc-compiler-auto-object-pipeline-score-function-auto-object-pipeline-score-input-ml-include-dirs-mlc-compiler-ml-701246303"></a>
### _auto_object_pipeline_score

```ml
function _auto_object_pipeline_score(input_ml, include_dirs)
```

Perform the auto object pipeline score compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input_ml` | `dynamic` | — |  |
| `include_dirs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2571)

<a id="function-function-mlc-compiler-auto-object-pipeline-score-visit-function-auto-object-pipeline-score-visit-path-include-dirs-seen-score-mlc-compiler-ml-138090143"></a>
### _auto_object_pipeline_score_visit

```ml
function _auto_object_pipeline_score_visit(path, include_dirs, seen, score)
```

Walk only enough of the import graph to cross the large-build threshold. This avoids a second parse while still seeing thin entrypoints that import a large compiler or application module. Read/resolve failures merely keep the conservative monolithic default; the real frontend reports them later.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `include_dirs` | `dynamic` | — |  |
| `seen` | `dynamic` | — |  |
| `score` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2541)

<a id="function-function-mlc-compiler-basename-inline-function-basename-path-mlc-compiler-ml-1156646834"></a>
### _basename

```ml
inline function _basename(path)
```

Perform the inline compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1046)

<a id="function-function-mlc-compiler-bss-label-offset-map-function-bss-label-offset-map-st-mlc-compiler-ml-985219835"></a>
### _bss_label_offset_map

```ml
function _bss_label_offset_map(st)
```

Perform the bss label offset map compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3260)

<a id="function-function-mlc-compiler-build-line-starts-function-build-line-starts-source-mlc-compiler-ml-1272233503"></a>
### _build_line_starts

```ml
function _build_line_starts(source)
```

Creates build line starts.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L439)

<a id="function-function-mlc-compiler-cfg-get-int-function-cfg-get-int-cfg-key-defaultv-mlc-compiler-ml-1062035064"></a>
### _cfg_get_int

```ml
function _cfg_get_int(cfg, key, defaultv)
```

Perform the cfg get int compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cfg` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2441)

<a id="function-function-mlc-compiler-cfg-set-function-cfg-set-cfg-key-value-mlc-compiler-ml-150436822"></a>
### _cfg_set

```ml
function _cfg_set(cfg, key, value)
```

Perform the cfg set compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cfg` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2421)

<a id="function-function-mlc-compiler-char-code-local-function-char-code-local-ch-mlc-compiler-ml-716348357"></a>
### _char_code_local

```ml
function _char_code_local(ch)
```

Perform the char code local compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ch` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4605)

<a id="function-function-mlc-compiler-check-decl-stmt-function-check-decl-stmt-st-module-path-diags-keep-going-max-errors-mlc-compiler-ml-1530621207"></a>
### _check_decl_stmt

```ml
function _check_decl_stmt(st, module_path, diags, keep_going, max_errors)
```

Perform the check decl stmt compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |
| `module_path` | `dynamic` | — |  |
| `diags` | `dynamic` | — |  |
| `keep_going` | `dynamic` | — |  |
| `max_errors` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1587)

<a id="function-function-mlc-compiler-clear-tmp-obj-dir-function-clear-tmp-obj-dir-tmp-dir-mlc-compiler-ml-1516932251"></a>
### _clear_tmp_obj_dir

```ml
function _clear_tmp_obj_dir(tmp_dir)
```

Releases or resets clear tmp obj dir.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tmp_dir` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1146)

<a id="function-function-mlc-compiler-cmd-quote-arg-function-cmd-quote-arg-x-mlc-compiler-ml-2062684824"></a>
### _cmd_quote_arg

```ml
function _cmd_quote_arg(x)
```

Perform the cmd quote arg compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L870)

<a id="function-function-mlc-compiler-coerce-name-function-coerce-name-v-mlc-compiler-ml-454480438"></a>
### _coerce_name

```ml
function _coerce_name(v)
```

Perform the coerce name compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2857)

<a id="function-function-mlc-compiler-collect-compile-defines-function-collect-compile-defines-args-mlc-compiler-ml-1044622911"></a>
### _collect_compile_defines

```ml
function _collect_compile_defines(args)
```

Perform the collect compile defines compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2578)

<a id="function-function-mlc-compiler-collect-extern-sigs-walk-function-collect-extern-sigs-walk-stmts-prefix-current-file-file-prefixes-acc-mlc-compiler-ml-206002127"></a>
### _collect_extern_sigs_walk

```ml
function _collect_extern_sigs_walk(stmts, prefix, current_file, file_prefixes, acc)
```

Perform the collect extern sigs walk compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stmts` | `dynamic` | — |  |
| `prefix` | `dynamic` | — |  |
| `current_file` | `dynamic` | — |  |
| `file_prefixes` | `dynamic` | — |  |
| `acc` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5864)

<a id="function-function-mlc-compiler-collect-extern-structs-walk-function-collect-extern-structs-walk-stmts-prefix-current-file-file-prefixes-names-mlc-compiler-ml-1711984290"></a>
### _collect_extern_structs_walk

```ml
function _collect_extern_structs_walk(stmts, prefix, current_file, file_prefixes, names)
```

Perform the collect extern structs walk compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stmts` | `dynamic` | — |  |
| `prefix` | `dynamic` | — |  |
| `current_file` | `dynamic` | — |  |
| `file_prefixes` | `dynamic` | — |  |
| `names` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5675)

<a id="function-function-mlc-compiler-collect-file-package-prefixes-function-collect-file-package-prefixes-program-mlc-compiler-ml-361790580"></a>
### _collect_file_package_prefixes

```ml
function _collect_file_package_prefixes(program)
```

Perform the collect file package prefixes compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5629)

<a id="function-function-mlc-compiler-collect-include-dirs-function-collect-include-dirs-args-mlc-compiler-ml-1090717049"></a>
### _collect_include_dirs

```ml
function _collect_include_dirs(args)
```

Perform the collect include dirs compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2286)

<a id="function-function-mlc-compiler-collect-internal-helper-targets-function-collect-internal-helper-targets-dst-patches-mlc-compiler-ml-537354521"></a>
### _collect_internal_helper_targets

```ml
function _collect_internal_helper_targets(dst, patches)
```

Perform the collect internal helper targets compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dst` | `dynamic` | — |  |
| `patches` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5542)

<a id="function-function-mlc-compiler-collect-mlo-paths-from-dir-function-collect-mlo-paths-from-dir-obj-dir-mlc-compiler-ml-1614947159"></a>
### _collect_mlo_paths_from_dir

```ml
function _collect_mlo_paths_from_dir(obj_dir)
```

Perform the collect mlo paths from dir compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `obj_dir` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4675)

<a id="function-function-mlc-compiler-collect-runtime-config-function-collect-runtime-config-args-mlc-compiler-ml-470783061"></a>
### _collect_runtime_config

```ml
function _collect_runtime_config(args)
```

Perform the collect runtime config compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2459)

<a id="function-function-mlc-compiler-compact-codegen-state-for-pe-function-compact-codegen-state-for-pe-st-mlc-compiler-ml-417983873"></a>
### _compact_codegen_state_for_pe

```ml
function _compact_codegen_state_for_pe(st)
```

Perform the compact codegen state for pe compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2645)

<a id="global-global-mlc-compiler-compile-codegen-keepalive-compile-codegen-keepalive-mlc-compiler-ml-794093768"></a>
### _compile_codegen_keepalive

```ml
_compile_codegen_keepalive
```

Track compile codegen keepalive compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L401)

<a id="global-global-mlc-compiler-compile-target-compile-target-mlc-compiler-ml-517273874"></a>
### _compile_target

```ml
_compile_target
```

Track compile target compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L429)

<a id="function-function-mlc-compiler-compiler-ast-profile-count-function-compiler-ast-profile-count-profile-kind-mlc-compiler-ml-1933012955"></a>
### _compiler_ast_profile_count

```ml
function _compiler_ast_profile_count(profile, kind)
```

Perform the compiler ast profile count compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `profile` | `dynamic` | — |  |
| `kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L558)

<a id="function-function-mlc-compiler-compiler-ast-profile-report-function-compiler-ast-profile-report-program-module-count-mlc-compiler-ml-158976708"></a>
### _compiler_ast_profile_report

```ml
function _compiler_ast_profile_report(program, module_count)
```

Perform the compiler ast profile report compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — |  |
| `module_count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L629)

<a id="function-function-mlc-compiler-compiler-ast-profile-visit-node-function-compiler-ast-profile-visit-node-profile-node-depth-mlc-compiler-ml-1944309926"></a>
### _compiler_ast_profile_visit_node

```ml
function _compiler_ast_profile_visit_node(profile, node, depth)
```

Traverse the public AST schema only when explicitly requested. Compact leaf NodeIds are terminal; composite structs are followed through every AST-bearing field shared by expressions, statements, declarations and switch containers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `profile` | `dynamic` | — |  |
| `node` | `dynamic` | — |  |
| `depth` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L591)

<a id="function-function-mlc-compiler-compiler-ast-profile-visit-value-function-compiler-ast-profile-visit-value-profile-value-depth-mlc-compiler-ml-1431652711"></a>
### _compiler_ast_profile_visit_value

```ml
function _compiler_ast_profile_visit_value(profile, value, depth)
```

Perform the compiler ast profile visit value compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `profile` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |
| `depth` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L580)

<a id="function-function-mlc-compiler-compiler-gc-limit-from-config-function-compiler-gc-limit-from-config-runtime-config-mlc-compiler-ml-807328653"></a>
### _compiler_gc_limit_from_config

```ml
function _compiler_gc_limit_from_config(runtime_config)
```

Perform the compiler gc limit from config compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `runtime_config` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2500)

<a id="global-global-mlc-compiler-compiler-profile-ast-enabled-compiler-profile-ast-enabled-mlc-compiler-ml-2143703602"></a>
### _compiler_profile_ast_enabled

```ml
_compiler_profile_ast_enabled
```

Track compiler profile ast enabled compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L427)

<a id="global-global-mlc-compiler-compiler-profile-batches-enabled-compiler-profile-batches-enabled-mlc-compiler-ml-1428869154"></a>
### _compiler_profile_batches_enabled

```ml
_compiler_profile_batches_enabled
```

Track compiler profile batches enabled compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L425)

<a id="global-global-mlc-compiler-compiler-profile-enabled-compiler-profile-enabled-mlc-compiler-ml-2080037782"></a>
### _compiler_profile_enabled

```ml
_compiler_profile_enabled
```

Track compiler profile enabled compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L423)

<a id="function-function-mlc-compiler-compiler-profile-finish-function-compiler-profile-finish-mlc-compiler-ml-574503584"></a>
### _compiler_profile_finish

```ml
function _compiler_profile_finish()
```

Perform the compiler profile finish compiler phase.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L536)

<a id="function-function-mlc-compiler-compiler-profile-owner-function-compiler-profile-owner-function-name-mlc-compiler-ml-257235730"></a>
### _compiler_profile_owner

```ml
function _compiler_profile_owner(function_name)
```

Extract the package/type prefix shown on detailed object-batch profiles.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `function_name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L648)

<a id="function-function-mlc-compiler-compiler-profile-phase-function-compiler-profile-phase-msg-mlc-compiler-ml-1978660419"></a>
### _compiler_profile_phase

```ml
function _compiler_profile_phase(msg)
```

Perform the compiler profile phase compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `msg` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L517)

<a id="global-global-mlc-compiler-compiler-profile-phase-name-compiler-profile-phase-name-mlc-compiler-ml-1042093082"></a>
### _compiler_profile_phase_name

```ml
_compiler_profile_phase_name
```

Track compiler profile phase name compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L435)

<a id="global-global-mlc-compiler-compiler-profile-phase-started-compiler-profile-phase-started-mlc-compiler-ml-1334381910"></a>
### _compiler_profile_phase_started

```ml
_compiler_profile_phase_started
```

Track compiler profile phase started compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L433)

<a id="function-function-mlc-compiler-compiler-profile-reset-function-compiler-profile-reset-mlc-compiler-ml-1039725596"></a>
### _compiler_profile_reset

```ml
function _compiler_profile_reset()
```

Perform the compiler profile reset compiler phase.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L497)

<a id="global-global-mlc-compiler-compiler-profile-started-compiler-profile-started-mlc-compiler-ml-365990430"></a>
### _compiler_profile_started

```ml
_compiler_profile_started
```

Track compiler profile started compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L431)

<a id="function-function-mlc-compiler-concat-bytes-parts-function-concat-bytes-parts-parts-builder-mlc-compiler-ml-217154310"></a>
### _concat_bytes_parts

```ml
function _concat_bytes_parts(parts_builder)
```

Perform the concat bytes parts compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parts_builder` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5463)

<a id="function-function-mlc-compiler-containsdot-inline-function-containsdot-txt-mlc-compiler-ml-1491136537"></a>
### _containsDot

```ml
inline function _containsDot(txt)
```

Perform the inline compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `txt` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L709)

<a id="function-function-mlc-compiler-copy-mlo-sections-from-file-function-copy-mlo-sections-from-file-path-text-buf-text-off-rdata-buf-rdata-off-data-buf-data-off-mlc-compiler-ml-1850064193"></a>
### _copy_mlo_sections_from_file

```ml
function _copy_mlo_sections_from_file(path, text_buf, text_off, rdata_buf, rdata_off, data_buf, data_off)
```

Perform the copy mlo sections from file compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `text_buf` | `dynamic` | — |  |
| `text_off` | `dynamic` | — |  |
| `rdata_buf` | `dynamic` | — |  |
| `rdata_off` | `dynamic` | — |  |
| `data_buf` | `dynamic` | — |  |
| `data_off` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4867)

<a id="function-function-mlc-compiler-debug-validate-patch-names-function-debug-validate-patch-names-label-patches-mlc-compiler-ml-1794564394"></a>
### _debug_validate_patch_names

```ml
function _debug_validate_patch_names(label, patches)
```

Perform the debug validate patch names compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `dynamic` | — |  |
| `patches` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4275)

<a id="function-function-mlc-compiler-declared-package-function-declared-package-program-mlc-compiler-ml-740817108"></a>
### _declared_package

```ml
function _declared_package(program)
```

Perform the declared package compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1642)

<a id="function-function-mlc-compiler-dirname-inline-function-dirname-path-mlc-compiler-ml-378090410"></a>
### _dirname

```ml
inline function _dirname(path)
```

Perform the inline compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1014)

<a id="function-function-mlc-compiler-dll-base-function-dll-base-dll-mlc-compiler-ml-225803642"></a>
### _dll_base

```ml
function _dll_base(dll)
```

Perform the dll base compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dll` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2851)

<a id="global-global-mlc-compiler-dump-labels-path-dump-labels-path-mlc-compiler-ml-41038030"></a>
### _dump_labels_path

```ml
_dump_labels_path
```

Track dump labels path compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L389)

<a id="function-function-mlc-compiler-emit-obj-dir-in-fresh-process-function-emit-obj-dir-in-fresh-process-args-mlc-compiler-ml-644495903"></a>
### _emit_obj_dir_in_fresh_process

```ml
function _emit_obj_dir_in_fresh_process(args)
```

Run only object emission in a child compiler. The small coordinating parent then links after the emitter has exited, so two multi-gigabyte managed heaps are never resident at the same time.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L6777)

<a id="function-function-mlc-compiler-endswith-inline-function-endswith-text-suf-mlc-compiler-ml-1942805904"></a>
### _endsWith

```ml
inline function _endsWith(text, suf)
```

Perform the inline compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |
| `suf` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L687)

<a id="function-function-mlc-compiler-ensure-dir-recursive-function-ensure-dir-recursive-path-mlc-compiler-ml-1440746033"></a>
### _ensure_dir_recursive

```ml
function _ensure_dir_recursive(path)
```

Perform the ensure dir recursive compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1102)

<a id="function-function-mlc-compiler-expected-package-for-file-function-expected-package-for-file-abs-path-resolved-kind-resolved-root-mlc-compiler-ml-1224950754"></a>
### _expected_package_for_file

```ml
function _expected_package_for_file(abs_path, resolved_kind, resolved_root)
```

Perform the expected package for file compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `abs_path` | `dynamic` | — |  |
| `resolved_kind` | `dynamic` | — |  |
| `resolved_root` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1523)

<a id="function-function-mlc-compiler-expr-to-qualname-function-expr-to-qualname-expr-mlc-compiler-ml-283262203"></a>
### _expr_to_qualname

```ml
function _expr_to_qualname(expr)
```

Perform the expr to qualname compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1545)

<a id="function-function-mlc-compiler-extern-physical-abi-class-function-extern-physical-abi-class-ty-is-out-mlc-compiler-ml-33626924"></a>
### _extern_physical_abi_class

```ml
function _extern_physical_abi_class(ty, is_out)
```

Perform the extern physical abi class compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ty` | `dynamic` | — |  |
| `is_out` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5747)

<a id="function-function-mlc-compiler-extern-struct-field-type-supported-function-extern-struct-field-type-supported-ty-mlc-compiler-ml-299838385"></a>
### _extern_struct_field_type_supported

```ml
function _extern_struct_field_type_supported(ty)
```

Perform the extern struct field type supported compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ty` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5584)

<a id="function-function-mlc-compiler-extern-struct-layout-find-function-extern-struct-layout-find-layouts-qname-mlc-compiler-ml-1032279295"></a>
### _extern_struct_layout_find

```ml
function _extern_struct_layout_find(layouts, qname)
```

Perform the extern struct layout find compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `layouts` | `dynamic` | — |  |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5618)

<a id="function-function-mlc-compiler-extern-struct-type-size-function-extern-struct-type-size-ty-mlc-compiler-ml-674070153"></a>
### _extern_struct_type_size

```ml
function _extern_struct_type_size(ty)
```

Perform the extern struct type size compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ty` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5607)

<a id="function-function-mlc-compiler-extern-symbol-default-function-extern-symbol-default-qname-mlc-compiler-ml-970146300"></a>
### _extern_symbol_default

```ml
function _extern_symbol_default(qname)
```

Perform the extern symbol default compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `qname` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5563)

<a id="function-function-mlc-compiler-extract-imports-function-extract-imports-program-mlc-compiler-ml-284265888"></a>
### _extract_imports

```ml
function _extract_imports(program)
```

Perform the extract imports compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1655)

<a id="function-function-mlc-compiler-file-stem-inline-function-file-stem-path-mlc-compiler-ml-424489790"></a>
### _file_stem

```ml
inline function _file_stem(path)
```

Perform the inline compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1062)

<a id="function-function-mlc-compiler-filter-non-import-stmts-function-filter-non-import-stmts-program-mlc-compiler-ml-245481808"></a>
### _filter_non_import_stmts

```ml
function _filter_non_import_stmts(program)
```

Perform the filter non import stmts compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2735)

<a id="function-function-mlc-compiler-find-main-name-function-find-main-name-state-mlc-compiler-ml-1439989011"></a>
### _find_main_name

```ml
function _find_main_name(state)
```

Returns find main name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5498)

<a id="function-function-mlc-compiler-finish-module-mlo-function-finish-module-mlo-tmp-dir-obj-index-module-file-entry-label-mod-cg-base-state-helper-union-module-obj-paths-b-mlc-compiler-ml-825171063"></a>
### _finish_module_mlo

```ml
function _finish_module_mlo(tmp_dir, obj_index, module_file, entry_label, mod_cg, base_state, helper_union, module_obj_paths_b)
```

Perform the finish module mlo compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tmp_dir` | `dynamic` | — |  |
| `obj_index` | `dynamic` | — |  |
| `module_file` | `dynamic` | — |  |
| `entry_label` | `dynamic` | — |  |
| `mod_cg` | `dynamic` | — |  |
| `base_state` | `dynamic` | — |  |
| `helper_union` | `dynamic` | — |  |
| `module_obj_paths_b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L6597)

<a id="function-function-mlc-compiler-fresh-link-gc-limit-from-config-function-fresh-link-gc-limit-from-config-runtime-config-mlc-compiler-ml-1336064053"></a>
### _fresh_link_gc_limit_from_config

```ml
function _fresh_link_gc_limit_from_config(runtime_config)
```

Perform the fresh link gc limit from config compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `runtime_config` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2601)

<a id="function-function-mlc-compiler-front-body-contains-async-function-front-body-contains-async-body-mlc-compiler-ml-1702280268"></a>
### _front_body_contains_async

```ml
function _front_body_contains_async(body)
```

Perform the front body contains async compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `body` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2133)

<a id="function-function-mlc-compiler-front-node-contains-async-function-front-node-contains-async-node-mlc-compiler-ml-125579356"></a>
### _front_node_contains_async

```ml
function _front_node_contains_async(node)
```

Async lowering uses the standard shared thread pool. Discover it before language lowering so programs do not need a synthetic source-level import.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `node` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2143)

<a id="global-global-mlc-compiler-front-resolve-cache-front-resolve-cache-mlc-compiler-ml-186136586"></a>
### _front_resolve_cache

```ml
_front_resolve_cache
```

Track front resolve cache compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L395)

<a id="global-global-mlc-compiler-front-visited-set-front-visited-set-mlc-compiler-ml-1756960694"></a>
### _front_visited_set

```ml
_front_visited_set
```

Track front visited set compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L393)

<a id="function-function-mlc-compiler-get-flag-value-function-get-flag-value-args-flag-mlc-compiler-ml-1164071017"></a>
### _get_flag_value

```ml
function _get_flag_value(args, flag)
```

Returns get flag value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — |  |
| `flag` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L483)

<a id="function-function-mlc-compiler-get-max-errors-function-get-max-errors-args-mlc-compiler-ml-1184557171"></a>
### _get_max_errors

```ml
function _get_max_errors(args)
```

Returns get max errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2337)

<a id="function-function-mlc-compiler-get-self-max-errors-function-get-self-max-errors-args-mlc-compiler-ml-837337519"></a>
### _get_self_max_errors

```ml
function _get_self_max_errors(args)
```

Returns get self max errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2320)

<a id="function-function-mlc-compiler-get-subsystem-function-get-subsystem-args-mlc-compiler-ml-289457571"></a>
### _get_subsystem

```ml
function _get_subsystem(args)
```

Returns get subsystem.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2624)

<a id="function-function-mlc-compiler-get-target-function-get-target-args-mlc-compiler-ml-1708391121"></a>
### _get_target

```ml
function _get_target(args)
```

Returns get target.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3383)

<a id="function-function-mlc-compiler-has-flag-function-has-flag-args-flag-mlc-compiler-ml-967893053"></a>
### _has_flag

```ml
function _has_flag(args, flag)
```

Reports whether has flag.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — |  |
| `flag` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2310)

<a id="function-function-mlc-compiler-heap-probe-function-heap-probe-tag-mlc-compiler-ml-1444294572"></a>
### _heap_probe

```ml
function _heap_probe(tag)
```

Perform the heap probe compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tag` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5963)

<a id="function-function-mlc-compiler-hex-u32-fixed-function-hex-u32-fixed-value-mlc-compiler-ml-92299427"></a>
### _hex_u32_fixed

```ml
function _hex_u32_fixed(value)
```

Perform the hex u32 fixed compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L7380)

<a id="extern_function-extern-function-mlc-compiler-host-closehandle-extern-function-host-closehandle-handle-as-ptr-from-kernel32-dll-symbol-closehandle-returns-bool-mlc-compiler-ml-1426532138"></a>
### _host_CloseHandle

```ml
extern function _host_CloseHandle(handle as ptr) from "kernel32.dll" symbol "CloseHandle" returns bool
```

Perform the host close handle compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L80)

<a id="extern_function-extern-function-mlc-compiler-host-createprocessw-extern-function-host-createprocessw-applicationname-as-wstr-commandline-as-wstr-processattributes-as-ptr-threadattributes-as-ptr-inherithandles-as-bool-creationflags-as-u32-environment-as-ptr-currentdirectory-as-ptr-startupinfo-as-bytes-processinformation-as-bytes-from-kernel32-dll-symbol-createprocessw-returns-bool-mlc-compiler-ml-1590835126"></a>
### _host_CreateProcessW

```ml
extern function _host_CreateProcessW(applicationName as wstr, commandLine as wstr, processAttributes as ptr, threadAttributes as ptr, inheritHandles as bool, creationFlags as u32, environment as ptr, currentDirectory as ptr, startupInfo as bytes, processInformation as bytes) from "kernel32.dll" symbol "CreateProcessW" returns bool
```

Perform the host create process w compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `applicationName` | `wstr` | — |  |
| `commandLine` | `wstr` | — |  |
| `processAttributes` | `ptr` | — |  |
| `threadAttributes` | `ptr` | — |  |
| `inheritHandles` | `bool` | — |  |
| `creationFlags` | `u32` | — |  |
| `environment` | `ptr` | — |  |
| `currentDirectory` | `ptr` | — |  |
| `startupInfo` | `bytes` | — |  |
| `processInformation` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L71)

<a id="extern_function-extern-function-mlc-compiler-host-getexitcodeprocess-extern-function-host-getexitcodeprocess-handle-as-ptr-exitcode-as-bytes-from-kernel32-dll-symbol-getexitcodeprocess-returns-bool-mlc-compiler-ml-1485837496"></a>
### _host_GetExitCodeProcess

```ml
extern function _host_GetExitCodeProcess(handle as ptr, exitCode as bytes) from "kernel32.dll" symbol "GetExitCodeProcess" returns bool
```

Perform the host get exit code process compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — |  |
| `exitCode` | `bytes` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L77)

<a id="extern_function-extern-function-mlc-compiler-host-waitforsingleobject-extern-function-host-waitforsingleobject-handle-as-ptr-milliseconds-as-u32-from-kernel32-dll-symbol-waitforsingleobject-returns-u32-mlc-compiler-ml-684679051"></a>
### _host_WaitForSingleObject

```ml
extern function _host_WaitForSingleObject(handle as ptr, milliseconds as u32) from "kernel32.dll" symbol "WaitForSingleObject" returns u32
```

Perform the host wait for single object compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — |  |
| `milliseconds` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L74)

<a id="function-function-mlc-compiler-imports-to-pe-imports-function-imports-to-pe-imports-imports-mlc-compiler-ml-900684606"></a>
### _imports_to_pe_imports

```ml
function _imports_to_pe_imports(imports)
```

Perform the imports to pe imports compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `imports` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2825)

<a id="function-function-mlc-compiler-is-abs-path-inline-function-is-abs-path-p-mlc-compiler-ml-1545033215"></a>
### _is_abs_path

```ml
inline function _is_abs_path(p)
```

Perform the inline compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `p` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1004)

<a id="function-function-mlc-compiler-is-constexpr-binary-function-is-constexpr-binary-op-mlc-compiler-ml-137385609"></a>
### _is_constexpr_binary

```ml
function _is_constexpr_binary(op)
```

Reports whether is constexpr binary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `op` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1539)

<a id="function-function-mlc-compiler-is-constexpr-expr-function-is-constexpr-expr-expr-mlc-compiler-ml-1370891045"></a>
### _is_constexpr_expr

```ml
function _is_constexpr_expr(expr)
```

Reports whether is constexpr expr.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1560)

<a id="function-function-mlc-compiler-is-constexpr-unary-function-is-constexpr-unary-op-mlc-compiler-ml-1449472673"></a>
### _is_constexpr_unary

```ml
function _is_constexpr_unary(op)
```

Reports whether is constexpr unary.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `op` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1533)

<a id="function-function-mlc-compiler-is-decl-stmt-function-is-decl-stmt-st-mlc-compiler-ml-829712851"></a>
### _is_decl_stmt

```ml
function _is_decl_stmt(st)
```

Reports whether is decl stmt.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1579)

<a id="function-function-mlc-compiler-is-internal-helper-label-local-function-is-internal-helper-label-local-lbl-mlc-compiler-ml-1847962924"></a>
### _is_internal_helper_label_local

```ml
function _is_internal_helper_label_local(lbl)
```

Reports whether is internal helper label local.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lbl` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5527)

<a id="function-function-mlc-compiler-label-get-function-label-get-arr-key-defaultv-mlc-compiler-ml-1399089917"></a>
### _label_get

```ml
function _label_get(arr, key, defaultv)
```

Perform the label get compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2758)

<a id="function-function-mlc-compiler-label-get-chunked-function-label-get-chunked-chunks-tail-key-defaultv-mlc-compiler-ml-328574482"></a>
### _label_get_chunked

```ml
function _label_get_chunked(chunks, tail, key, defaultv)
```

Perform the label get chunked compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chunks` | `dynamic` | — |  |
| `tail` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2790)

<a id="function-function-mlc-compiler-label-key-function-label-key-name-mlc-compiler-ml-1561260305"></a>
### _label_key

```ml
function _label_key(name)
```

Perform the label key compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5011)

<a id="function-function-mlc-compiler-label-lookup-fallback-function-label-lookup-fallback-labels-name-defaultv-mlc-compiler-ml-1302650439"></a>
### _label_lookup_fallback

```ml
function _label_lookup_fallback(labels, name, defaultv)
```

Perform the label lookup fallback compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `labels` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4294)

<a id="function-function-mlc-compiler-label-set-function-label-set-arr-key-value-mlc-compiler-ml-605281853"></a>
### _label_set

```ml
function _label_set(arr, key, value)
```

Perform the label set compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `key` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2774)

<a id="function-function-mlc-compiler-last-segment-after-dot-inline-function-last-segment-after-dot-txt-mlc-compiler-ml-172396209"></a>
### _last_segment_after_dot

```ml
inline function _last_segment_after_dot(txt)
```

Perform the inline compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `txt` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L719)

<a id="function-function-mlc-compiler-link-build-label-maps-function-link-build-label-maps-patch-file-recs-text-rva-rdata-rva-data-rva-bss-rva-include-private-dump-mlc-compiler-ml-2070833041"></a>
### _link_build_label_maps

```ml
function _link_build_label_maps(patch_file_recs, text_rva, rdata_rva, data_rva, bss_rva, include_private_dump)
```

Link canonical MLO fragments into the same fixed-address ELF image as the monolithic backend. Section offsets, rather than PE RVAs, form the common label space; this makes rel32/rip32 and abs64 patching deterministic.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `patch_file_recs` | `dynamic` | — |  |
| `text_rva` | `dynamic` | — |  |
| `rdata_rva` | `dynamic` | — |  |
| `data_rva` | `dynamic` | — |  |
| `bss_rva` | `dynamic` | — |  |
| `include_private_dump` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L6062)

<a id="function-function-mlc-compiler-link-direct-patch-target-function-link-direct-patch-target-label-map-obj-index-map-source-obj-map-source-obj-prefix-target-mlc-compiler-ml-451365211"></a>
### _link_direct_patch_target

```ml
function _link_direct_patch_target(label_map, obj_index_map, source_obj_map, source_obj_prefix, target)
```

Perform the link direct patch target compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label_map` | `dynamic` | — |  |
| `obj_index_map` | `dynamic` | — |  |
| `source_obj_map` | `dynamic` | — |  |
| `source_obj_prefix` | `dynamic` | — |  |
| `target` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5135)

<a id="function-function-mlc-compiler-link-local-labels-get-function-link-local-labels-get-local-label-map-local-labels-target-mlc-compiler-ml-1347228779"></a>
### _link_local_labels_get

```ml
function _link_local_labels_get(local_label_map, local_labels, target)
```

Perform the link local labels get compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `local_label_map` | `dynamic` | — |  |
| `local_labels` | `dynamic` | — |  |
| `target` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5038)

<a id="function-function-mlc-compiler-link-local-patch-target-function-link-local-patch-target-src-patch-target-mlc-compiler-ml-1611963866"></a>
### _link_local_patch_target

```ml
function _link_local_patch_target(src_patch, target)
```

Perform the link local patch target compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `src_patch` | `dynamic` | — |  |
| `target` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5046)

<a id="function-function-mlc-compiler-link-mlo-files-function-link-mlo-files-obj-paths-output-exe-subsystem-mlc-compiler-ml-1561935609"></a>
### _link_mlo_files

```ml
function _link_mlo_files(obj_paths, output_exe, subsystem)
```

Link canonical MLO fragments in input order while retaining only compact label/patch metadata; this ordering is part of byte-for-byte parity.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `obj_paths` | `dynamic` | — |  |
| `output_exe` | `dynamic` | — |  |
| `subsystem` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L6253)

<a id="function-function-mlc-compiler-link-mlo-linux-sections-function-link-mlo-linux-sections-obj-paths-output-exe-text-buf-rdata-buf-data-buf-bss-size-patch-file-recs-imports-mlc-compiler-ml-1487032232"></a>
### _link_mlo_linux_sections

```ml
function _link_mlo_linux_sections(obj_paths, output_exe, text_buf, rdata_buf, data_buf, bss_size, patch_file_recs, imports)
```

Perform the link mlo linux sections compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `obj_paths` | `dynamic` | — |  |
| `output_exe` | `dynamic` | — |  |
| `text_buf` | `dynamic` | — |  |
| `rdata_buf` | `dynamic` | — |  |
| `data_buf` | `dynamic` | — |  |
| `bss_size` | `dynamic` | — |  |
| `patch_file_recs` | `dynamic` | — |  |
| `imports` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L6176)

<a id="function-function-mlc-compiler-link-obj-dir-in-fresh-process-function-link-obj-dir-in-fresh-process-input-ml-obj-dir-output-exe-subsystem-runtime-config-mlc-compiler-ml-1660364315"></a>
### _link_obj_dir_in_fresh_process

```ml
function _link_obj_dir_in_fresh_process(input_ml, obj_dir, output_exe, subsystem, runtime_config)
```

Perform the link obj dir in fresh process compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input_ml` | `dynamic` | — |  |
| `obj_dir` | `dynamic` | — |  |
| `output_exe` | `dynamic` | — |  |
| `subsystem` | `dynamic` | — |  |
| `runtime_config` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L6546)

<a id="function-function-mlc-compiler-link-obj-label-list-get-function-link-obj-label-list-get-obj-index-lists-name-defaultv-mlc-compiler-ml-1422148126"></a>
### _link_obj_label_list_get

```ml
function _link_obj_label_list_get(obj_index_lists, name, defaultv)
```

Perform the link obj label list get compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `obj_index_lists` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4394)

<a id="function-function-mlc-compiler-link-obj-label-list-set-function-link-obj-label-list-set-obj-index-lists-name-value-mlc-compiler-ml-1415819144"></a>
### _link_obj_label_list_set

```ml
function _link_obj_label_list_set(obj_index_lists, name, value)
```

Perform the link obj label list set compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `obj_index_lists` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4379)

<a id="function-function-mlc-compiler-link-obj-label-map-get-function-link-obj-label-map-get-obj-index-map-name-defaultv-mlc-compiler-ml-219458575"></a>
### _link_obj_label_map_get

```ml
function _link_obj_label_map_get(obj_index_map, name, defaultv)
```

Perform the link obj label map get compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `obj_index_map` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4369)

<a id="function-function-mlc-compiler-link-obj-label-map-set-function-link-obj-label-map-set-obj-index-map-name-value-mlc-compiler-ml-802697151"></a>
### _link_obj_label_map_set

```ml
function _link_obj_label_map_set(obj_index_map, name, value)
```

Perform the link obj label map set compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `obj_index_map` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4354)

<a id="global-global-mlc-compiler-link-patch-keepalive-link-patch-keepalive-mlc-compiler-ml-365601846"></a>
### _link_patch_keepalive

```ml
_link_patch_keepalive
```

Track link patch keepalive compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L403)

<a id="function-function-mlc-compiler-link-rec-labels-lookup-function-link-rec-labels-lookup-recs-text-rva-rdata-rva-data-rva-bss-rva-name-defaultv-mlc-compiler-ml-728873654"></a>
### _link_rec_labels_lookup

```ml
function _link_rec_labels_lookup(recs, text_rva, rdata_rva, data_rva, bss_rva, name, defaultv)
```

Perform the link rec labels lookup compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `recs` | `dynamic` | — |  |
| `text_rva` | `dynamic` | — |  |
| `rdata_rva` | `dynamic` | — |  |
| `data_rva` | `dynamic` | — |  |
| `bss_rva` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |
| `defaultv` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4411)

<a id="function-function-mlc-compiler-link-resolve-patch-target-function-link-resolve-patch-target-label-map-obj-index-map-obj-index-lists-local-label-map-local-labels-labels-link-patch-recs-text-rva-rdata-rva-data-rva-bss-rva-src-patch-target-mlc-compiler-ml-119289233"></a>
### _link_resolve_patch_target

```ml
function _link_resolve_patch_target(label_map, obj_index_map, obj_index_lists, local_label_map, local_labels, labels, link_patch_recs, text_rva, rdata_rva, data_rva, bss_rva, src_patch, target)
```

Perform the link resolve patch target compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label_map` | `dynamic` | — |  |
| `obj_index_map` | `dynamic` | — |  |
| `obj_index_lists` | `dynamic` | — |  |
| `local_label_map` | `dynamic` | — |  |
| `local_labels` | `dynamic` | — |  |
| `labels` | `dynamic` | — |  |
| `link_patch_recs` | `dynamic` | — |  |
| `text_rva` | `dynamic` | — |  |
| `rdata_rva` | `dynamic` | — |  |
| `data_rva` | `dynamic` | — |  |
| `bss_rva` | `dynamic` | — |  |
| `src_patch` | `dynamic` | — |  |
| `target` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5074)

<a id="function-function-mlc-compiler-link-resolve-patch-target-cached-function-link-resolve-patch-target-cached-label-map-target-cache-obj-index-map-obj-index-lists-local-label-map-local-labels-labels-link-patch-recs-text-rva-rdata-rva-data-rva-bss-rva-src-patch-target-mlc-compiler-ml-1474262157"></a>
### _link_resolve_patch_target_cached

```ml
function _link_resolve_patch_target_cached(label_map, target_cache, obj_index_map, obj_index_lists, local_label_map, local_labels, labels, link_patch_recs, text_rva, rdata_rva, data_rva, bss_rva, src_patch, target)
```

Perform the link resolve patch target cached compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label_map` | `dynamic` | — |  |
| `target_cache` | `dynamic` | — |  |
| `obj_index_map` | `dynamic` | — |  |
| `obj_index_lists` | `dynamic` | — |  |
| `local_label_map` | `dynamic` | — |  |
| `local_labels` | `dynamic` | — |  |
| `labels` | `dynamic` | — |  |
| `link_patch_recs` | `dynamic` | — |  |
| `text_rva` | `dynamic` | — |  |
| `rdata_rva` | `dynamic` | — |  |
| `data_rva` | `dynamic` | — |  |
| `bss_rva` | `dynamic` | — |  |
| `src_patch` | `dynamic` | — |  |
| `target` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5118)

<a id="function-function-mlc-compiler-link-resolve-target-function-link-resolve-target-label-map-labels-link-patch-recs-text-rva-rdata-rva-data-rva-bss-rva-target-mlc-compiler-ml-1812062059"></a>
### _link_resolve_target

```ml
function _link_resolve_target(label_map, labels, link_patch_recs, text_rva, rdata_rva, data_rva, bss_rva, target)
```

Perform the link resolve target compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label_map` | `dynamic` | — |  |
| `labels` | `dynamic` | — |  |
| `link_patch_recs` | `dynamic` | — |  |
| `text_rva` | `dynamic` | — |  |
| `rdata_rva` | `dynamic` | — |  |
| `data_rva` | `dynamic` | — |  |
| `bss_rva` | `dynamic` | — |  |
| `target` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5019)

<a id="function-function-mlc-compiler-link-should-use-fresh-process-function-link-should-use-fresh-process-obj-paths-mlc-compiler-ml-253646810"></a>
### _link_should_use_fresh_process

```ml
function _link_should_use_fresh_process(obj_paths)
```

Perform the link should use fresh process compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `obj_paths` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L6539)

<a id="function-function-mlc-compiler-link-target-obj-index-function-link-target-obj-index-name-mlc-compiler-ml-1406105421"></a>
### _link_target_obj_index

```ml
function _link_target_obj_index(name)
```

Perform the link target obj index compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4323)

<a id="function-function-mlc-compiler-link-target-obj-index-num-function-link-target-obj-index-num-name-mlc-compiler-ml-369823433"></a>
### _link_target_obj_index_num

```ml
function _link_target_obj_index_num(name)
```

Perform the link target obj index num compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4332)

<a id="function-function-mlc-compiler-link-target-prefers-global-function-link-target-prefers-global-target-mlc-compiler-ml-47347529"></a>
### _link_target_prefers_global

```ml
function _link_target_prefers_global(target)
```

Perform the link target prefers global compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `target` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5059)

<a id="function-function-mlc-compiler-load-program-for-codegen-function-load-program-for-codegen-entry-include-dirs-keep-going-max-errors-mlc-compiler-ml-496796531"></a>
### _load_program_for_codegen

```ml
function _load_program_for_codegen(entry, include_dirs, keep_going, max_errors)
```

Returns load program for codegen.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entry` | `dynamic` | — |  |
| `include_dirs` | `dynamic` | — |  |
| `keep_going` | `dynamic` | — |  |
| `max_errors` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5987)

<a id="function-function-mlc-compiler-make-linux-output-executable-function-make-linux-output-executable-path-mlc-compiler-ml-511131019"></a>
### _make_linux_output_executable

```ml
function _make_linux_output_executable(path)
```

Native Linux filesystems require execute permission in addition to valid ELF contents. Windows cross-builds cannot represent this bit and intentionally leave deployment-time chmod behavior unchanged.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L954)

<a id="global-global-mlc-compiler-mem-probe-enabled-mem-probe-enabled-mlc-compiler-ml-1129308368"></a>
### _mem_probe_enabled

```ml
_mem_probe_enabled
```

Track mem probe enabled compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L387)

<a id="function-function-mlc-compiler-merge-array-chunks-balanced-function-merge-array-chunks-balanced-chunks-mlc-compiler-ml-556259610"></a>
### _merge_array_chunks_balanced

```ml
function _merge_array_chunks_balanced(chunks)
```

Perform the merge array chunks balanced compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `chunks` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2752)

<a id="function-function-mlc-compiler-merge-string-arrays-function-merge-string-arrays-dst-src-mlc-compiler-ml-1197263937"></a>
### _merge_string_arrays

```ml
function _merge_string_arrays(dst, src)
```

Perform the merge string arrays compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dst` | `dynamic` | — |  |
| `src` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5511)

<a id="function-function-mlc-compiler-mlo-align-down8-function-mlo-align-down8-value-mlc-compiler-ml-1922818819"></a>
### _mlo_align_down8

```ml
function _mlo_align_down8(value)
```

Perform the mlo align down8 compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3488)

<a id="function-function-mlc-compiler-mlo-bp-bytes-function-mlo-bp-bytes-bp-b-mlc-compiler-ml-1512682124"></a>
### _mlo_bp_bytes

```ml
function _mlo_bp_bytes(bp, b)
```

Perform the mlo bp bytes compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3796)

<a id="function-function-mlc-compiler-mlo-bp-push-function-mlo-bp-push-bp-b-mlc-compiler-ml-1054535656"></a>
### _mlo_bp_push

```ml
function _mlo_bp_push(bp, b)
```

Perform the mlo bp push compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3783)

<a id="function-function-mlc-compiler-mlo-bp-string-function-mlo-bp-string-bp-text-mlc-compiler-ml-2097234175"></a>
### _mlo_bp_string

```ml
function _mlo_bp_string(bp, text)
```

Perform the mlo bp string compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3805)

<a id="function-function-mlc-compiler-mlo-bp-u32-function-mlo-bp-u32-bp-as-struct-value-as-int-returns-struct-mlc-compiler-ml-1462241957"></a>
### _mlo_bp_u32

```ml
function _mlo_bp_u32(bp as struct, value as int) returns struct
```

Perform the mlo bp u32 compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `struct` | — |  |
| `value` | `int` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3790)

<a id="function-function-mlc-compiler-mlo-bp-write-imports-function-mlo-bp-write-imports-bp-imports-mlc-compiler-ml-865796838"></a>
### _mlo_bp_write_imports

```ml
function _mlo_bp_write_imports(bp, imports)
```

Perform the mlo bp write imports compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — |  |
| `imports` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3867)

<a id="function-function-mlc-compiler-mlo-bp-write-labels-function-mlo-bp-write-labels-bp-labels-mlc-compiler-ml-1770535327"></a>
### _mlo_bp_write_labels

```ml
function _mlo_bp_write_labels(bp, labels)
```

Perform the mlo bp write labels compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — |  |
| `labels` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3813)

<a id="function-function-mlc-compiler-mlo-bp-write-patches-function-mlo-bp-write-patches-bp-patches-mlc-compiler-ml-1687164426"></a>
### _mlo_bp_write_patches

```ml
function _mlo_bp_write_patches(bp, patches)
```

Perform the mlo bp write patches compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `bp` | `dynamic` | — |  |
| `patches` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3834)

<a id="extern_function-extern-function-mlc-compiler-mlo-closehandle-extern-function-mlo-closehandle-handle-as-ptr-from-kernel32-dll-symbol-closehandle-returns-bool-mlc-compiler-ml-2048781322"></a>
### _mlo_CloseHandle

```ml
extern function _mlo_CloseHandle(handle as ptr) from "kernel32.dll" symbol "CloseHandle" returns bool
```

Perform the mlo close handle compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L89)

<a id="extern_function-extern-function-mlc-compiler-mlo-createfilew-extern-function-mlo-createfilew-path-as-wstr-access-as-int-share-as-int-security-as-ptr-creation-as-int-flags-as-int-template-as-ptr-from-kernel32-dll-symbol-createfilew-returns-ptr-mlc-compiler-ml-1503582081"></a>
### _mlo_CreateFileW

```ml
extern function _mlo_CreateFileW(path as wstr, access as int, share as int, security as ptr, creation as int, flags as int, template as ptr) from "kernel32.dll" symbol "CreateFileW" returns ptr
```

Perform the mlo create file w compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `wstr` | — |  |
| `access` | `int` | — |  |
| `share` | `int` | — |  |
| `security` | `ptr` | — |  |
| `creation` | `int` | — |  |
| `flags` | `int` | — |  |
| `template` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L83)

<a id="function-function-mlc-compiler-mlo-exported-text-labels-function-mlo-exported-text-labels-asm-labels-entry-label-rdata-patches-data-patches-mlc-compiler-ml-519380520"></a>
### _mlo_exported_text_labels

```ml
function _mlo_exported_text_labels(asm_labels, entry_label, rdata_patches, data_patches)
```

Perform the mlo exported text labels compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm_labels` | `dynamic` | — |  |
| `entry_label` | `dynamic` | — |  |
| `rdata_patches` | `dynamic` | — |  |
| `data_patches` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3219)

<a id="function-function-mlc-compiler-mlo-from-sparse-state-delta-function-mlo-from-sparse-state-delta-kind-module-file-entry-label-st-base-state-mlc-compiler-ml-1604485930"></a>
### _mlo_from_sparse_state_delta

```ml
function _mlo_from_sparse_state_delta(kind, module_file, entry_label, st, base_state)
```

Perform the mlo from sparse state delta compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — |  |
| `module_file` | `dynamic` | — |  |
| `entry_label` | `dynamic` | — |  |
| `st` | `dynamic` | — |  |
| `base_state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3608)

<a id="function-function-mlc-compiler-mlo-from-state-function-mlo-from-state-kind-module-file-entry-label-st-mlc-compiler-ml-1965939219"></a>
### _mlo_from_state

```ml
function _mlo_from_state(kind, module_file, entry_label, st)
```

Perform the mlo from state compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — |  |
| `module_file` | `dynamic` | — |  |
| `entry_label` | `dynamic` | — |  |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3103)

<a id="function-function-mlc-compiler-mlo-from-state-delta-function-mlo-from-state-delta-kind-module-file-entry-label-st-base-state-mlc-compiler-ml-743819148"></a>
### _mlo_from_state_delta

```ml
function _mlo_from_state_delta(kind, module_file, entry_label, st, base_state)
```

Perform the mlo from state delta compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `kind` | `dynamic` | — |  |
| `module_file` | `dynamic` | — |  |
| `entry_label` | `dynamic` | — |  |
| `st` | `dynamic` | — |  |
| `base_state` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3530)

<a id="function-function-mlc-compiler-mlo-import-get-funcs-function-mlo-import-get-funcs-imports-dll-mlc-compiler-ml-1713904010"></a>
### _mlo_import_get_funcs

```ml
function _mlo_import_get_funcs(imports, dll)
```

Perform the mlo import get funcs compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `imports` | `dynamic` | — |  |
| `dll` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2893)

<a id="function-function-mlc-compiler-mlo-import-set-funcs-function-mlo-import-set-funcs-imports-dll-funcs-mlc-compiler-ml-1224324127"></a>
### _mlo_import_set_funcs

```ml
function _mlo_import_set_funcs(imports, dll, funcs)
```

Perform the mlo import set funcs compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `imports` | `dynamic` | — |  |
| `dll` | `dynamic` | — |  |
| `funcs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2907)

<a id="function-function-mlc-compiler-mlo-imports-from-state-function-mlo-imports-from-state-imports-mlc-compiler-ml-117809312"></a>
### _mlo_imports_from_state

```ml
function _mlo_imports_from_state(imports)
```

Perform the mlo imports from state compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `imports` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3070)

<a id="function-function-mlc-compiler-mlo-is-exported-text-label-function-mlo-is-exported-text-label-name-entry-label-required-targets-mlc-compiler-ml-985551130"></a>
### _mlo_is_exported_text_label

```ml
function _mlo_is_exported_text_label(name, entry_label, required_targets)
```

Only labels that can be referenced from another canonical object need to enter the MLO symbol table. Same-fragment rel32/rip32 targets are carried as numeric MLO-v2 offsets, so their private control-flow names are no longer needed. Keeping them made the linker hash more than a million dead names during a compiler self-build.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |
| `entry_label` | `dynamic` | — |  |
| `required_targets` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3205)

<a id="function-function-mlc-compiler-mlo-is-shared-runtime-data-label-function-mlo-is-shared-runtime-data-label-name-mlc-compiler-ml-1586034127"></a>
### _mlo_is_shared_runtime_data_label

```ml
function _mlo_is_shared_runtime_data_label(name)
```

Perform the mlo is shared runtime data label compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3642)

<a id="function-function-mlc-compiler-mlo-label-count-function-mlo-label-count-labels-mlc-compiler-ml-954472133"></a>
### _mlo_label_count

```ml
function _mlo_label_count(labels)
```

Perform the mlo label count compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `labels` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3722)

<a id="function-function-mlc-compiler-mlo-label-counts-function-mlo-label-counts-obj-mlc-compiler-ml-1025075401"></a>
### _mlo_label_counts

```ml
function _mlo_label_counts(obj)
```

Count public and private labels while an object is already decoded during the section pass. The later linker pass can then allocate only the maps and capacities that the object actually needs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `obj` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4897)

<a id="function-function-mlc-compiler-mlo-label-map-add-function-mlo-label-map-add-mapv-old-name-new-name-mlc-compiler-ml-1461943887"></a>
### _mlo_label_map_add

```ml
function _mlo_label_map_add(mapv, old_name, new_name)
```

Perform the mlo label map add compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mapv` | `dynamic` | — |  |
| `old_name` | `dynamic` | — |  |
| `new_name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3672)

<a id="function-function-mlc-compiler-mlo-label-name-at-function-mlo-label-name-at-labels-offset-mlc-compiler-ml-389508652"></a>
### _mlo_label_name_at

```ml
function _mlo_label_name_at(labels, offset)
```

Perform the mlo label name at compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `labels` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3399)

<a id="function-function-mlc-compiler-mlo-labels-after-function-mlo-labels-after-labels-prefix-off-mlc-compiler-ml-1247578143"></a>
### _mlo_labels_after

```ml
function _mlo_labels_after(labels, prefix_off)
```

Perform the mlo labels after compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `labels` | `dynamic` | — |  |
| `prefix_off` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3171)

<a id="function-function-mlc-compiler-mlo-labels-after-cut-function-mlo-labels-after-cut-labels-min-off-cut-off-mlc-compiler-ml-1494665179"></a>
### _mlo_labels_after_cut

```ml
function _mlo_labels_after_cut(labels, min_off, cut_off)
```

Perform the mlo labels after cut compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `labels` | `dynamic` | — |  |
| `min_off` | `dynamic` | — |  |
| `cut_off` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3496)

<a id="function-function-mlc-compiler-mlo-labels-from-arr-function-mlo-labels-from-arr-arr-mlc-compiler-ml-1353576965"></a>
### _mlo_labels_from_arr

```ml
function _mlo_labels_from_arr(arr)
```

Perform the mlo labels from arr compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2952)

<a id="function-function-mlc-compiler-mlo-labels-from-asm-labels-function-mlo-labels-from-asm-labels-arr-mlc-compiler-ml-876071085"></a>
### _mlo_labels_from_asm_labels

```ml
function _mlo_labels_from_asm_labels(arr)
```

Perform the mlo labels from asm labels compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2976)

<a id="function-function-mlc-compiler-mlo-linux-dynamic-imports-function-mlo-linux-dynamic-imports-imports-mlc-compiler-ml-1454922454"></a>
### _mlo_linux_dynamic_imports

```ml
function _mlo_linux_dynamic_imports(imports)
```

Perform the mlo linux dynamic imports compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `imports` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3326)

<a id="function-function-mlc-compiler-mlo-linux-import-records-function-mlo-linux-import-records-dynamic-imports-mlc-compiler-ml-1912162558"></a>
### _mlo_linux_import_records

```ml
function _mlo_linux_import_records(dynamic_imports)
```

Encode ELF imports in the existing platform-neutral string-list field. PE readers ignore the tagged entries; the ELF linker reconstructs the exact library/symbol/data-slot triplets without adding target-specific fields.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dynamic_imports` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3303)

<a id="function-function-mlc-compiler-mlo-merge-imports-function-mlo-merge-imports-dst-src-mlc-compiler-ml-1597348397"></a>
### _mlo_merge_imports

```ml
function _mlo_merge_imports(dst, src)
```

Perform the mlo merge imports compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `dst` | `dynamic` | — |  |
| `src` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2924)

<a id="function-function-mlc-compiler-mlo-namespace-object-function-mlo-namespace-object-obj-prefix-preserve-public-mlc-compiler-ml-2093183111"></a>
### _mlo_namespace_object

```ml
function _mlo_namespace_object(obj, prefix, preserve_public)
```

Perform the mlo namespace object compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `obj` | `dynamic` | — |  |
| `prefix` | `dynamic` | — |  |
| `preserve_public` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3729)

<a id="function-function-mlc-compiler-mlo-patches-after-function-mlo-patches-after-patches-prefix-off-mlc-compiler-ml-1269989564"></a>
### _mlo_patches_after

```ml
function _mlo_patches_after(patches, prefix_off)
```

Perform the mlo patches after compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `patches` | `dynamic` | — |  |
| `prefix_off` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3186)

<a id="function-function-mlc-compiler-mlo-patches-after-cut-function-mlo-patches-after-cut-patches-min-off-cut-off-mlc-compiler-ml-1279546186"></a>
### _mlo_patches_after_cut

```ml
function _mlo_patches_after_cut(patches, min_off, cut_off)
```

Perform the mlo patches after cut compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `patches` | `dynamic` | — |  |
| `min_off` | `dynamic` | — |  |
| `cut_off` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3511)

<a id="function-function-mlc-compiler-mlo-patches-from-asm-function-mlo-patches-from-asm-arr-label-pos-map-text-buf-mlc-compiler-ml-1454512896"></a>
### _mlo_patches_from_asm

```ml
function _mlo_patches_from_asm(arr, label_pos_map, text_buf)
```

Resolve targets already defined in this text fragment directly in the materialized bytes. Only cross-fragment relocations need to survive in an MLO object, which avoids serializing and later retaining millions of local branch records during large self-hosted builds. The reader still accepts numeric MLO v2 targets written by older compilers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `label_pos_map` | `dynamic` | — |  |
| `text_buf` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3000)

<a id="function-function-mlc-compiler-mlo-patches-from-data-function-mlo-patches-from-data-arr-mlc-compiler-ml-1735370677"></a>
### _mlo_patches_from_data

```ml
function _mlo_patches_from_data(arr)
```

Perform the mlo patches from data compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3045)

<a id="function-function-mlc-compiler-mlo-preserve-module-label-function-mlo-preserve-module-label-name-mlc-compiler-ml-1696765693"></a>
### _mlo_preserve_module_label

```ml
function _mlo_preserve_module_label(name)
```

Perform the mlo preserve module label compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3624)

<a id="function-function-mlc-compiler-mlo-rdata-alias-map-function-mlo-rdata-alias-map-labels-base-labels-prefix-off-mlc-compiler-ml-850361702"></a>
### _mlo_rdata_alias_map

```ml
function _mlo_rdata_alias_map(labels, base_labels, prefix_off)
```

A later canonical fragment may intern a constant that was first emitted by an earlier fragment. Its new source-level label then aliases an offset that is not part of the later .mlo payload. Redirect relocations to the original label so cross-fragment pooling remains byte-identical to monolithic output.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `labels` | `dynamic` | — |  |
| `base_labels` | `dynamic` | — |  |
| `prefix_off` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3413)

<a id="function-function-mlc-compiler-mlo-read-imports-function-mlo-read-imports-rd-mlc-compiler-ml-1640456904"></a>
### _mlo_read_imports

```ml
function _mlo_read_imports(rd)
```

Perform the mlo read imports compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4147)

<a id="function-function-mlc-compiler-mlo-read-labels-function-mlo-read-labels-rd-mlc-compiler-ml-237931306"></a>
### _mlo_read_labels

```ml
function _mlo_read_labels(rd)
```

Perform the mlo read labels compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4075)

<a id="function-function-mlc-compiler-mlo-read-patches-function-mlo-read-patches-rd-version-mlc-compiler-ml-878001772"></a>
### _mlo_read_patches

```ml
function _mlo_read_patches(rd, version)
```

Perform the mlo read patches compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rd` | `dynamic` | — |  |
| `version` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4099)

<a id="function-function-mlc-compiler-mlo-rename-labels-function-mlo-rename-labels-labels-prefix-preserve-public-label-map-mlc-compiler-ml-1844507524"></a>
### _mlo_rename_labels

```ml
function _mlo_rename_labels(labels, prefix, preserve_public, label_map)
```

Perform the mlo rename labels compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `labels` | `dynamic` | — |  |
| `prefix` | `dynamic` | — |  |
| `preserve_public` | `dynamic` | — |  |
| `label_map` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3679)

<a id="function-function-mlc-compiler-mlo-rename-patches-function-mlo-rename-patches-patches-label-map-mlc-compiler-ml-169494085"></a>
### _mlo_rename_patches

```ml
function _mlo_rename_patches(patches, label_map)
```

Perform the mlo rename patches compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `patches` | `dynamic` | — |  |
| `label_map` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3697)

<a id="function-function-mlc-compiler-mlo-resolve-rdata-alias-patches-function-mlo-resolve-rdata-alias-patches-patches-rb-mlc-compiler-ml-781016918"></a>
### _mlo_resolve_rdata_alias_patches

```ml
function _mlo_resolve_rdata_alias_patches(patches, rb)
```

Perform the mlo resolve rdata alias patches compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `patches` | `dynamic` | — |  |
| `rb` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3432)

<a id="function-function-mlc-compiler-mlo-scan-label-counts-function-mlo-scan-label-counts-rd-mlc-compiler-ml-739012686"></a>
### _mlo_scan_label_counts

```ml
function _mlo_scan_label_counts(rd)
```

Count serialized labels without decoding their names or allocating wrapper structs. The private namespace is identified directly from the UTF-8 bytes of the `objm_` prefix.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4766)

<a id="function-function-mlc-compiler-mlo-skip-labels-function-mlo-skip-labels-rd-mlc-compiler-ml-345885774"></a>
### _mlo_skip_labels

```ml
function _mlo_skip_labels(rd)
```

Perform the mlo skip labels compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4706)

<a id="function-function-mlc-compiler-mlo-skip-patches-function-mlo-skip-patches-rd-version-mlc-compiler-ml-1789404426"></a>
### _mlo_skip_patches

```ml
function _mlo_skip_patches(rd, version)
```

Perform the mlo skip patches compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rd` | `dynamic` | — |  |
| `version` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4726)

<a id="function-function-mlc-compiler-mlo-sort-rank-function-mlo-sort-rank-name-mlc-compiler-ml-1514524973"></a>
### _mlo_sort_rank

```ml
function _mlo_sort_rank(name)
```

Perform the mlo sort rank compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4613)

<a id="function-function-mlc-compiler-mlo-state-checkpoint-function-mlo-state-checkpoint-st-mlc-compiler-ml-381999345"></a>
### _mlo_state_checkpoint

```ml
function _mlo_state_checkpoint(st)
```

Perform the mlo state checkpoint compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3457)

<a id="function-function-mlc-compiler-mlo-strip-shared-runtime-data-labels-function-mlo-strip-shared-runtime-data-labels-labels-mlc-compiler-ml-204408577"></a>
### _mlo_strip_shared_runtime_data_labels

```ml
function _mlo_strip_shared_runtime_data_labels(labels)
```

Perform the mlo strip shared runtime data labels compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `labels` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3656)

<a id="function-function-mlc-compiler-mlo-write-handle-all-function-mlo-write-handle-all-handle-input-count-mlc-compiler-ml-1377244467"></a>
### _mlo_write_handle_all

```ml
function _mlo_write_handle_all(handle, input, count)
```

Complete one bounded native write even if the host reports a short write. The common regular-file path passes the shared buffer without slicing.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `dynamic` | — |  |
| `input` | `dynamic` | — |  |
| `count` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3970)

<a id="function-function-mlc-compiler-mlo-write-imports-function-mlo-write-imports-ob-imports-mlc-compiler-ml-1659589699"></a>
### _mlo_write_imports

```ml
function _mlo_write_imports(ob, imports)
```

Perform the mlo write imports compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ob` | `dynamic` | — |  |
| `imports` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3929)

<a id="function-function-mlc-compiler-mlo-write-labels-function-mlo-write-labels-ob-labels-mlc-compiler-ml-2107975812"></a>
### _mlo_write_labels

```ml
function _mlo_write_labels(ob, labels)
```

Perform the mlo write labels compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ob` | `dynamic` | — |  |
| `labels` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3762)

<a id="function-function-mlc-compiler-mlo-write-pages-file-function-mlo-write-pages-file-path-bp-mlc-compiler-ml-1707510849"></a>
### _mlo_write_pages_file

```ml
function _mlo_write_pages_file(path, bp)
```

Serialize through a reusable bounded staging buffer. A one-megabyte batch keeps native write-call overhead low while avoiding the old full-object contiguous duplicate, whose size grew without bound with an MLO fragment.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `bp` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3992)

<a id="function-function-mlc-compiler-mlo-write-patches-function-mlo-write-patches-ob-patches-mlc-compiler-ml-1835208615"></a>
### _mlo_write_patches

```ml
function _mlo_write_patches(ob, patches)
```

Perform the mlo write patches compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ob` | `dynamic` | — |  |
| `patches` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3896)

<a id="global-global-mlc-compiler-mlo-write-scratch-mlo-write-scratch-mlc-compiler-ml-1745366234"></a>
### _mlo_write_scratch

```ml
_mlo_write_scratch
```

Track mlo write scratch compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L397)

<a id="function-function-mlc-compiler-mlo-write-scratch-buffer-function-mlo-write-scratch-buffer-mlc-compiler-ml-634194338"></a>
### _mlo_write_scratch_buffer

```ml
function _mlo_write_scratch_buffer()
```

Perform the mlo write scratch buffer compiler phase.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3958)

<a id="extern_function-extern-function-mlc-compiler-mlo-writefile-extern-function-mlo-writefile-handle-as-ptr-input-as-bytes-count-as-int-written-as-bytes-overlapped-as-ptr-from-kernel32-dll-symbol-writefile-returns-bool-mlc-compiler-ml-2102317366"></a>
### _mlo_WriteFile

```ml
extern function _mlo_WriteFile(handle as ptr, input as bytes, count as int, written as bytes, overlapped as ptr) from "kernel32.dll" symbol "WriteFile" returns bool
```

Perform the mlo write file compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `handle` | `ptr` | — |  |
| `input` | `bytes` | — |  |
| `count` | `int` | — |  |
| `written` | `bytes` | — |  |
| `overlapped` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L86)

<a id="function-function-mlc-compiler-module-get-package-function-module-get-package-modules-path-mlc-compiler-ml-1680995644"></a>
### _module_get_package

```ml
function _module_get_package(modules, path)
```

Perform the module get package compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `modules` | `dynamic` | — |  |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1373)

<a id="function-function-mlc-compiler-module-init-rec-for-file-function-module-init-rec-for-file-module-init-recs-module-file-mlc-compiler-ml-1206492218"></a>
### _module_init_rec_for_file

```ml
function _module_init_rec_for_file(module_init_recs, module_file)
```

Perform the module init rec for file compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `module_init_recs` | `dynamic` | — |  |
| `module_file` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5486)

<a id="function-function-mlc-compiler-module-set-package-function-module-set-package-modules-path-package-name-mlc-compiler-ml-1273017774"></a>
### _module_set_package

```ml
function _module_set_package(modules, path, package_name)
```

Perform the module set package compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `modules` | `dynamic` | — |  |
| `path` | `dynamic` | — |  |
| `package_name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1391)

<a id="function-function-mlc-compiler-module-visit-function-module-visit-path-entry-path-include-dirs-stack-visited-modules-aliases-parsed-modules-diags-keep-going-max-errors-mlc-compiler-ml-1467070084"></a>
### _module_visit

```ml
function _module_visit(path, entry_path, include_dirs, stack, visited, modules, aliases, parsed_modules, diags, keep_going, max_errors)
```

Perform the module visit compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `entry_path` | `dynamic` | — |  |
| `include_dirs` | `dynamic` | — |  |
| `stack` | `dynamic` | — |  |
| `visited` | `dynamic` | — |  |
| `modules` | `dynamic` | — |  |
| `aliases` | `dynamic` | — |  |
| `parsed_modules` | `dynamic` | — |  |
| `diags` | `dynamic` | — |  |
| `keep_going` | `dynamic` | — |  |
| `max_errors` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1891)

<a id="function-function-mlc-compiler-monolithic-label-rva-function-monolithic-label-rva-st-iat-label-map-bss-label-map-text-rva-rdata-rva-data-rva-bss-rva-name-mlc-compiler-ml-963077817"></a>
### _monolithic_label_rva

```ml
function _monolithic_label_rva(st, iat_label_map, bss_label_map, text_rva, rdata_rva, data_rva, bss_rva, name)
```

Resolve directly against the indexes already maintained by each section builder. This avoids rebuilding a second million-entry combined map during monolithic linking while retaining the original last-section-wins order.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |
| `iat_label_map` | `dynamic` | — |  |
| `bss_label_map` | `dynamic` | — |  |
| `text_rva` | `dynamic` | — |  |
| `rdata_rva` | `dynamic` | — |  |
| `data_rva` | `dynamic` | — |  |
| `bss_rva` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3279)

<a id="function-function-mlc-compiler-node-file-inline-function-node-file-st-fallback-mlc-compiler-ml-1013201426"></a>
### _node_file

```ml
inline function _node_file(st, fallback)
```

Perform the inline compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |
| `fallback` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1352)

<a id="function-function-mlc-compiler-node-pos-inline-function-node-pos-st-mlc-compiler-ml-1797920714"></a>
### _node_pos

```ml
inline function _node_pos(st)
```

Perform the inline compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1344)

<a id="function-function-mlc-compiler-objbuf-bytes-function-objbuf-bytes-ob-b-mlc-compiler-ml-1520772709"></a>
### _objbuf_bytes

```ml
function _objbuf_bytes(ob, b)
```

Perform the objbuf bytes compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ob` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1208)

<a id="function-function-mlc-compiler-objbuf-finish-function-objbuf-finish-ob-mlc-compiler-ml-1114479623"></a>
### _objbuf_finish

```ml
function _objbuf_finish(ob)
```

Perform the objbuf finish compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ob` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1224)

<a id="function-function-mlc-compiler-objbuf-new-function-objbuf-new-mlc-compiler-ml-35563964"></a>
### _objbuf_new

```ml
function _objbuf_new()
```

Perform the objbuf new compiler phase.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1187)

<a id="function-function-mlc-compiler-objbuf-push-function-objbuf-push-ob-b-mlc-compiler-ml-1571754415"></a>
### _objbuf_push

```ml
function _objbuf_push(ob, b)
```

Perform the objbuf push compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ob` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1193)

<a id="function-function-mlc-compiler-objbuf-string-function-objbuf-string-ob-text-mlc-compiler-ml-1085854178"></a>
### _objbuf_string

```ml
function _objbuf_string(ob, text)
```

Perform the objbuf string compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ob` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1216)

<a id="function-function-mlc-compiler-objbuf-u32-function-objbuf-u32-ob-value-mlc-compiler-ml-1893406978"></a>
### _objbuf_u32

```ml
function _objbuf_u32(ob, value)
```

Perform the objbuf u32 compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ob` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1202)

<a id="global-global-mlc-compiler-object-emit-only-object-emit-only-mlc-compiler-ml-476433834"></a>
### _object_emit_only

```ml
_object_emit_only
```

Track object emit only compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L407)

<a id="global-global-mlc-compiler-object-pipeline-enabled-object-pipeline-enabled-mlc-compiler-ml-653714652"></a>
### _object_pipeline_enabled

```ml
_object_pipeline_enabled
```

Track object pipeline enabled compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L405)

<a id="function-function-mlc-compiler-objreader-copy-bytes-into-function-objreader-copy-bytes-into-rd-destination-destination-offset-mlc-compiler-ml-101675532"></a>
### _objreader_copy_bytes_into

```ml
function _objreader_copy_bytes_into(rd, destination, destination_offset)
```

Copy one length-prefixed blob from the current raw MLO file directly into its final combined section. No intermediate per-object bytes value is made.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rd` | `dynamic` | — |  |
| `destination` | `dynamic` | — |  |
| `destination_offset` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1325)

<a id="function-function-mlc-compiler-objreader-new-function-objreader-new-buf-mlc-compiler-ml-1966087975"></a>
### _objreader_new

```ml
function _objreader_new(buf)
```

Perform the objreader new compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buf` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1241)

<a id="function-function-mlc-compiler-objreader-read-bytes-function-objreader-read-bytes-rd-mlc-compiler-ml-1133032730"></a>
### _objreader_read_bytes

```ml
function _objreader_read_bytes(rd)
```

Perform the objreader read bytes compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1268)

<a id="function-function-mlc-compiler-objreader-read-string-function-objreader-read-string-rd-mlc-compiler-ml-545749058"></a>
### _objreader_read_string

```ml
function _objreader_read_string(rd)
```

Perform the objreader read string compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1287)

<a id="function-function-mlc-compiler-objreader-read-u32-function-objreader-read-u32-rd-mlc-compiler-ml-1003061300"></a>
### _objreader_read_u32

```ml
function _objreader_read_u32(rd)
```

Perform the objreader read u32 compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1250)

<a id="function-function-mlc-compiler-objreader-skip-bytes-function-objreader-skip-bytes-rd-mlc-compiler-ml-1128000936"></a>
### _objreader_skip_bytes

```ml
function _objreader_skip_bytes(rd)
```

Advance over a length-prefixed blob without allocating a copy. Layout scans and the patch applier often need only the following field position.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1297)

<a id="function-function-mlc-compiler-objreader-skip-bytes-len-function-objreader-skip-bytes-len-rd-mlc-compiler-ml-1405562828"></a>
### _objreader_skip_bytes_len

```ml
function _objreader_skip_bytes_len(rd)
```

Perform the objreader skip bytes len compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rd` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1311)

<a id="function-function-mlc-compiler-parse-size-text-function-parse-size-text-txt-mlc-compiler-ml-699541748"></a>
### _parse_size_text

```ml
function _parse_size_text(txt)
```

Returns parse size text.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `txt` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2363)

<a id="function-function-mlc-compiler-parse-subsystem-value-function-parse-subsystem-value-v-mlc-compiler-ml-791604422"></a>
### _parse_subsystem_value

```ml
function _parse_subsystem_value(v)
```

Returns parse subsystem value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2613)

<a id="function-function-mlc-compiler-parsed-module-get-function-parsed-module-get-parsed-modules-path-mlc-compiler-ml-2040243512"></a>
### _parsed_module_get

```ml
function _parsed_module_get(parsed_modules, path)
```

Returns parsed module get.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parsed_modules` | `dynamic` | — |  |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1856)

<a id="function-function-mlc-compiler-parsed-module-set-function-parsed-module-set-parsed-modules-path-source-program-mlc-compiler-ml-759289937"></a>
### _parsed_module_set

```ml
function _parsed_module_set(parsed_modules, path, source, program)
```

Returns parsed module set.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `parsed_modules` | `dynamic` | — |  |
| `path` | `dynamic` | — |  |
| `source` | `dynamic` | — |  |
| `program` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1872)

<a id="function-function-mlc-compiler-patch-triplets-for-link-function-patch-triplets-for-link-patches-default-kind-mlc-compiler-ml-792962418"></a>
### _patch_triplets_for_link

```ml
function _patch_triplets_for_link(patches, default_kind)
```

Perform the patch triplets for link compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `patches` | `dynamic` | — |  |
| `default_kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4491)

<a id="function-function-mlc-compiler-path-abspath-function-path-abspath-p-mlc-compiler-ml-1816170412"></a>
### _path_abspath

```ml
function _path_abspath(p)
```

Perform the path abspath compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `p` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L841)

<a id="function-function-mlc-compiler-path-canon-function-path-canon-p-mlc-compiler-ml-409939596"></a>
### _path_canon

```ml
function _path_canon(p)
```

Perform the path canon compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `p` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L741)

<a id="function-function-mlc-compiler-path-eq-inline-function-path-eq-a-b-mlc-compiler-ml-1481866142"></a>
### _path_eq

```ml
inline function _path_eq(a, b)
```

Perform the inline compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L984)

<a id="function-function-mlc-compiler-path-join-inline-function-path-join-a-b-mlc-compiler-ml-1842731202"></a>
### _path_join

```ml
inline function _path_join(a, b)
```

Perform the inline compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1030)

<a id="function-function-mlc-compiler-path-norm-function-path-norm-p-mlc-compiler-ml-341681976"></a>
### _path_norm

```ml
function _path_norm(p)
```

Perform the path norm compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `p` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L831)

<a id="global-global-mlc-compiler-path-norm-cache-path-norm-cache-mlc-compiler-ml-271022090"></a>
### _path_norm_cache

```ml
_path_norm_cache
```

Track path norm cache compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L391)

<a id="function-function-mlc-compiler-path-norm-cached-function-path-norm-cached-p-mlc-compiler-ml-1366494444"></a>
### _path_norm_cached

```ml
function _path_norm_cached(p)
```

Perform the path norm cached compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `p` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L969)

<a id="function-function-mlc-compiler-path-to-package-function-path-to-package-rel-path-mlc-compiler-ml-210385537"></a>
### _path_to_package

```ml
function _path_to_package(rel_path)
```

Perform the path to package compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rel_path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1464)

<a id="global-global-mlc-compiler-pe-state-keepalive-pe-state-keepalive-mlc-compiler-ml-590325790"></a>
### _pe_state_keepalive

```ml
_pe_state_keepalive
```

Track pe state keepalive compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L399)

<a id="function-function-mlc-compiler-print-diag-function-print-diag-d-mlc-compiler-ml-554318608"></a>
### _print_diag

```ml
function _print_diag(d)
```

Perform the print diag compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `d` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2257)

<a id="function-function-mlc-compiler-progress-link-function-progress-link-msg-mlc-compiler-ml-1776810627"></a>
### _progress_link

```ml
function _progress_link(msg)
```

Perform the progress link compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `msg` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L670)

<a id="function-function-mlc-compiler-progress-obj-function-progress-obj-msg-mlc-compiler-ml-1590633327"></a>
### _progress_obj

```ml
function _progress_obj(msg)
```

Perform the progress obj compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `msg` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L664)

<a id="function-function-mlc-compiler-progress-phase-function-progress-phase-msg-mlc-compiler-ml-445961155"></a>
### _progress_phase

```ml
function _progress_phase(msg)
```

Perform the progress phase compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `msg` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L657)

<a id="function-function-mlc-compiler-read-mlo-file-function-read-mlo-file-path-mlc-compiler-ml-253951209"></a>
### _read_mlo_file

```ml
function _read_mlo_file(path)
```

Returns read mlo file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4180)

<a id="function-function-mlc-compiler-read-mlo-file-for-layout-function-read-mlo-file-for-layout-path-mlc-compiler-ml-485790537"></a>
### _read_mlo_file_for_layout

```ml
function _read_mlo_file_for_layout(path)
```

Returns read mlo file for layout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4922)

<a id="function-function-mlc-compiler-read-mlo-layout-scan-function-read-mlo-layout-scan-path-mlc-compiler-ml-67084131"></a>
### _read_mlo_layout_scan

```ml
function _read_mlo_layout_scan(path)
```

First linker pass: retain only section sizes, import metadata and label capacity hints. Section payloads and label wrappers remain in the MLO file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4801)

<a id="function-function-mlc-compiler-release-frontend-phase-arenas-function-release-frontend-phase-arenas-mlc-compiler-ml-1853291156"></a>
### _release_frontend_phase_arenas

```ml
function _release_frontend_phase_arenas()
```

End the parsing/semantic ownership phase in one operation. Generated code, relocations and runtime metadata no longer refer to compact AST NodeIds at the two call sites below, so the typed arenas and resolution caches can be unrooted before the next full collection instead of surviving until exit.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5975)

<a id="function-function-mlc-compiler-relpath-from-root-function-relpath-from-root-path-root-mlc-compiler-ml-2063510905"></a>
### _relpath_from_root

```ml
function _relpath_from_root(path, root)
```

Perform the relpath from root compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `root` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1504)

<a id="function-function-mlc-compiler-resolve-import-function-resolve-import-requested-base-dir-include-dirs-mlc-compiler-ml-1694187082"></a>
### _resolve_import

```ml
function _resolve_import(requested, base_dir, include_dirs)
```

Perform the resolve import compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `requested` | `dynamic` | — |  |
| `base_dir` | `dynamic` | — |  |
| `include_dirs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1700)

<a id="function-function-mlc-compiler-resolve-import-cache-key-function-resolve-import-cache-key-requested-base-dir-mlc-compiler-ml-2037318335"></a>
### _resolve_import_cache_key

```ml
function _resolve_import_cache_key(requested, base_dir)
```

Perform the resolve import cache key compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `requested` | `dynamic` | — |  |
| `base_dir` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1775)

<a id="function-function-mlc-compiler-resolve-import-cached-function-resolve-import-cached-requested-base-dir-include-dirs-mlc-compiler-ml-1292690496"></a>
### _resolve_import_cached

```ml
function _resolve_import_cached(requested, base_dir, include_dirs)
```

Perform the resolve import cached compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `requested` | `dynamic` | — |  |
| `base_dir` | `dynamic` | — |  |
| `include_dirs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1787)

<a id="function-function-mlc-compiler-run-child-process-function-run-child-process-executable-args-mlc-compiler-ml-252036971"></a>
### _run_child_process

```ml
function _run_child_process(executable, args)
```

Launch a child compiler without a command shell on Windows. Besides avoiding cmd.exe expansion, this preserves every argument exactly across the object- emission and fresh-link process boundaries.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `executable` | `dynamic` | — |  |
| `args` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L924)

<a id="function-function-mlc-compiler-run-frontcheck-function-run-frontcheck-entry-include-dirs-keep-going-max-errors-mlc-compiler-ml-194788579"></a>
### _run_frontcheck

```ml
function _run_frontcheck(entry, include_dirs, keep_going, max_errors)
```

Perform the run frontcheck compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `entry` | `dynamic` | — |  |
| `include_dirs` | `dynamic` | — |  |
| `keep_going` | `dynamic` | — |  |
| `max_errors` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2186)

<a id="function-function-mlc-compiler-sanitize-fs-component-function-sanitize-fs-component-text-mlc-compiler-ml-1860839945"></a>
### _sanitize_fs_component

```ml
function _sanitize_fs_component(text)
```

Perform the sanitize fs component compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1078)

<a id="function-function-mlc-compiler-section-has-payload-function-section-has-payload-blob-labels-patches-size-hint-mlc-compiler-ml-507673919"></a>
### _section_has_payload

```ml
function _section_has_payload(blob, labels, patches, size_hint)
```

Perform the section has payload compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `blob` | `dynamic` | — |  |
| `labels` | `dynamic` | — |  |
| `patches` | `dynamic` | — |  |
| `size_hint` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1162)

<a id="function-function-mlc-compiler-self-exe-path-function-self-exe-path-mlc-compiler-ml-1093858620"></a>
### _self_exe_path

```ml
function _self_exe_path()
```

Perform the self exe path compiler phase.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L862)

<a id="function-function-mlc-compiler-size-suffix-mul-function-size-suffix-mul-ch-mlc-compiler-ml-536638073"></a>
### _size_suffix_mul

```ml
function _size_suffix_mul(ch)
```

Perform the size suffix mul compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `ch` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2354)

<a id="function-function-mlc-compiler-slice-used-bytes-function-slice-used-bytes-buf-used-mlc-compiler-ml-1052477882"></a>
### _slice_used_bytes

```ml
function _slice_used_bytes(buf, used)
```

Perform the slice used bytes compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buf` | `dynamic` | — |  |
| `used` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L3089)

<a id="function-function-mlc-compiler-sort-strings-inplace-function-sort-strings-inplace-items-mlc-compiler-ml-412098514"></a>
### _sort_strings_inplace

```ml
function _sort_strings_inplace(items)
```

Perform the sort strings inplace compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4653)

<a id="function-function-mlc-compiler-split-imports-nonimports-function-split-imports-nonimports-program-mlc-compiler-ml-582628644"></a>
### _split_imports_nonimports

```ml
function _split_imports_nonimports(program)
```

Perform the split imports nonimports compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1673)

<a id="function-function-mlc-compiler-st-file-function-st-file-st-mlc-compiler-ml-1026336493"></a>
### _st_file

```ml
function _st_file(st)
```

Perform the st file compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2886)

<a id="function-function-mlc-compiler-stack-contains-function-stack-contains-stack-path-mlc-compiler-ml-611540415"></a>
### _stack_contains

```ml
function _stack_contains(stack, path)
```

Perform the stack contains compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stack` | `dynamic` | — |  |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1802)

<a id="function-function-mlc-compiler-startswith-inline-function-startswith-text-pref-mlc-compiler-ml-2058755977"></a>
### _startsWith

```ml
inline function _startsWith(text, pref)
```

Perform the inline compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |
| `pref` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L676)

<a id="function-function-mlc-compiler-stmt-is-import-function-stmt-is-import-st-mlc-compiler-ml-814118837"></a>
### _stmt_is_import

```ml
function _stmt_is_import(st)
```

Perform the stmt is import compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2638)

<a id="function-function-mlc-compiler-string-leq-function-string-leq-a-b-mlc-compiler-ml-1298070979"></a>
### _string_leq

```ml
function _string_leq(a, b)
```

Perform the string leq compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4633)

<a id="function-function-mlc-compiler-subsystem-cli-name-function-subsystem-cli-name-subsystem-mlc-compiler-ml-1234191263"></a>
### _subsystem_cli_name

```ml
function _subsystem_cli_name(subsystem)
```

Perform the subsystem cli name compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `subsystem` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L6532)

<a id="function-function-mlc-compiler-tmp-obj-dir-function-tmp-obj-dir-output-exe-mlc-compiler-ml-1440771438"></a>
### _tmp_obj_dir

```ml
function _tmp_obj_dir(output_exe)
```

Perform the tmp obj dir compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `output_exe` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1124)

<a id="function-function-mlc-compiler-tmp-obj-path-function-tmp-obj-path-tmp-dir-index-module-path-kind-mlc-compiler-ml-1247524343"></a>
### _tmp_obj_path

```ml
function _tmp_obj_path(tmp_dir, index, module_path, kind)
```

Perform the tmp obj path compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tmp_dir` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |
| `module_path` | `dynamic` | — |  |
| `kind` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1134)

<a id="function-function-mlc-compiler-to-int-or-inline-function-to-int-or-defv-text-mlc-compiler-ml-787562953"></a>
### _to_int_or

```ml
inline function _to_int_or(defv, text)
```

Perform the inline compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `defv` | `dynamic` | — |  |
| `text` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L733)

<a id="function-function-mlc-compiler-u32le-at-function-u32le-at-buf-off-mlc-compiler-ml-1095299402"></a>
### _u32le_at

```ml
function _u32le_at(buf, off)
```

Perform the u32le at compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buf` | `dynamic` | — |  |
| `off` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1179)

<a id="function-function-mlc-compiler-u64le-host-at-function-u64le-host-at-buf-offset-mlc-compiler-ml-1917120694"></a>
### _u64le_host_at

```ml
function _u64le_host_at(buf, offset)
```

Perform the u64le host at compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `buf` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L913)

<a id="function-function-mlc-compiler-usage-function-usage-mlc-compiler-ml-562835044"></a>
### _usage

```ml
function _usage()
```

Perform the usage compiler phase.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L455)

<a id="function-function-mlc-compiler-validate-size-flags-function-validate-size-flags-args-mlc-compiler-ml-1229837971"></a>
### _validate_size_flags

```ml
function _validate_size_flags(args)
```

Perform the validate size flags compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L2399)

<a id="function-function-mlc-compiler-visited-add-function-visited-add-visited-path-mlc-compiler-ml-1453632043"></a>
### _visited_add

```ml
function _visited_add(visited, path)
```

Perform the visited add compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `visited` | `dynamic` | — |  |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1823)

<a id="function-function-mlc-compiler-visited-contains-function-visited-contains-path-mlc-compiler-ml-514826259"></a>
### _visited_contains

```ml
function _visited_contains(path)
```

Perform the visited contains compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1813)

<a id="function-function-mlc-compiler-visited-finish-function-visited-finish-visited-fallback-entry-mlc-compiler-ml-1473036643"></a>
### _visited_finish

```ml
function _visited_finish(visited, fallback_entry)
```

Perform the visited finish compiler phase.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `visited` | `dynamic` | — |  |
| `fallback_entry` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L1845)

<a id="function-function-mlc-compiler-write-asm-listing-if-enabled-function-write-asm-listing-if-enabled-output-exe-peb-text-buf-rdata-buf-data-buf-idata-buf-mlc-compiler-ml-1869766975"></a>
### _write_asm_listing_if_enabled

```ml
function _write_asm_listing_if_enabled(output_exe, peb, text_buf, rdata_buf, data_buf, idata_buf)
```

Updates write asm listing if enabled.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `output_exe` | `dynamic` | — |  |
| `peb` | `dynamic` | — |  |
| `text_buf` | `dynamic` | — |  |
| `rdata_buf` | `dynamic` | — |  |
| `data_buf` | `dynamic` | — |  |
| `idata_buf` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L7443)

<a id="function-function-mlc-compiler-write-linux-image-function-write-linux-image-st-asm-labels-patches-text-buf-rdata-buf-data-buf-output-exe-dynamic-imports-mlc-compiler-ml-923279549"></a>
### _write_linux_image

```ml
function _write_linux_image(st, asm_labels, patches, text_buf, rdata_buf, data_buf, output_exe, dynamic_imports)
```

Compile and link one complete program in memory.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `st` | `dynamic` | — |  |
| `asm_labels` | `dynamic` | — |  |
| `patches` | `dynamic` | — |  |
| `text_buf` | `dynamic` | — |  |
| `rdata_buf` | `dynamic` | — |  |
| `data_buf` | `dynamic` | — |  |
| `output_exe` | `dynamic` | — |  |
| `dynamic_imports` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L6639)

<a id="function-function-mlc-compiler-write-mlo-file-function-write-mlo-file-path-obj-mlc-compiler-ml-2048967472"></a>
### _write_mlo_file

```ml
function _write_mlo_file(path, obj)
```

Updates write mlo file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `obj` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L4051)

<a id="constant-constant-mlc-compiler-auto-object-pipeline-score-const-auto-object-pipeline-score-262144-mlc-compiler-ml-2065354566"></a>
### AUTO_OBJECT_PIPELINE_SCORE

```ml
const AUTO_OBJECT_PIPELINE_SCORE = 262144
```

Track auto object pipeline score.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L44)

<a id="function-function-mlc-compiler-collect-extern-sigs-function-collect-extern-sigs-program-mlc-compiler-ml-800703984"></a>
### collect_extern_sigs

```ml
function collect_extern_sigs(program)
```

Normalize all extern declarations into deterministic signature records.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — | Value supplied for `program`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5955)

<a id="function-function-mlc-compiler-collect-extern-structs-function-collect-extern-structs-program-mlc-compiler-ml-1133109776"></a>
### collect_extern_structs

```ml
function collect_extern_structs(program)
```

Collect native struct declarations before validating extern signatures.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `program` | `dynamic` | — | Value supplied for `program`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5740)

<a id="function-function-mlc-compiler-compile-to-exe-function-compile-to-exe-input-ml-output-exe-mlc-compiler-ml-1488227210"></a>
### compile_to_exe

```ml
function compile_to_exe(input_ml, output_exe)
```

Compile with default include, diagnostic, runtime and subsystem options.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input_ml` | `dynamic` | — | Value supplied for `input_ml`. |
| `output_exe` | `dynamic` | — | Value supplied for `output_exe`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L7934)

<a id="function-function-mlc-compiler-compile-to-exe-opts-function-compile-to-exe-opts-input-ml-output-exe-include-dirs-keep-going-max-errors-runtime-config-call-profile-trace-calls-subsystem-mlc-compiler-ml-1428728650"></a>
### compile_to_exe_opts

```ml
function compile_to_exe_opts(input_ml, output_exe, include_dirs, keep_going, max_errors, runtime_config, call_profile, trace_calls, subsystem)
```

Dispatch to the selected monolithic or object-pipeline implementation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input_ml` | `dynamic` | — | Value supplied for `input_ml`. |
| `output_exe` | `dynamic` | — | Value supplied for `output_exe`. |
| `include_dirs` | `dynamic` | — | Value supplied for `include_dirs`. |
| `keep_going` | `dynamic` | — | Value supplied for `keep_going`. |
| `max_errors` | `dynamic` | — | Value supplied for `max_errors`. |
| `runtime_config` | `dynamic` | — | Value supplied for `runtime_config`. |
| `call_profile` | `dynamic` | — | Value supplied for `call_profile`. |
| `trace_calls` | `dynamic` | — | Value supplied for `trace_calls`. |
| `subsystem` | `dynamic` | — | Value supplied for `subsystem`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L7924)

<a id="function-function-mlc-compiler-compile-to-exe-opts-monolithic-function-compile-to-exe-opts-monolithic-input-ml-output-exe-include-dirs-keep-going-max-errors-runtime-config-call-profile-trace-calls-subsystem-mlc-compiler-ml-1267162196"></a>
### compile_to_exe_opts_monolithic

```ml
function compile_to_exe_opts_monolithic(input_ml, output_exe, include_dirs, keep_going, max_errors, runtime_config, call_profile, trace_calls, subsystem)
```

Compile and link one complete program in memory.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input_ml` | `dynamic` | — | Value supplied for `input_ml`. |
| `output_exe` | `dynamic` | — | Value supplied for `output_exe`. |
| `include_dirs` | `dynamic` | — | Value supplied for `include_dirs`. |
| `keep_going` | `dynamic` | — | Value supplied for `keep_going`. |
| `max_errors` | `dynamic` | — | Value supplied for `max_errors`. |
| `runtime_config` | `dynamic` | — | Value supplied for `runtime_config`. |
| `call_profile` | `dynamic` | — | Value supplied for `call_profile`. |
| `trace_calls` | `dynamic` | — | Value supplied for `trace_calls`. |
| `subsystem` | `dynamic` | — | Value supplied for `subsystem`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L6801)

<a id="function-function-mlc-compiler-compile-to-exe-opts-object-function-compile-to-exe-opts-object-input-ml-output-exe-include-dirs-keep-going-max-errors-runtime-config-call-profile-trace-calls-subsystem-mlc-compiler-ml-1252125628"></a>
### compile_to_exe_opts_object

```ml
function compile_to_exe_opts_object(input_ml, output_exe, include_dirs, keep_going, max_errors, runtime_config, call_profile, trace_calls, subsystem)
```

Emit bounded .mlo batches and link them in a fresh compiler process.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `input_ml` | `dynamic` | — | Value supplied for `input_ml`. |
| `output_exe` | `dynamic` | — | Value supplied for `output_exe`. |
| `include_dirs` | `dynamic` | — | Value supplied for `include_dirs`. |
| `keep_going` | `dynamic` | — | Value supplied for `keep_going`. |
| `max_errors` | `dynamic` | — | Value supplied for `max_errors`. |
| `runtime_config` | `dynamic` | — | Value supplied for `runtime_config`. |
| `call_profile` | `dynamic` | — | Value supplied for `call_profile`. |
| `trace_calls` | `dynamic` | — | Value supplied for `trace_calls`. |
| `subsystem` | `dynamic` | — | Value supplied for `subsystem`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L7477)

<a id="constant-constant-mlc-compiler-compiler-version-const-compiler-version-1-2-5-mlc-compiler-ml-281213255"></a>
### COMPILER_VERSION

```ml
const COMPILER_VERSION = "1.2.5"
```

Track compiler version.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L38)

<a id="constant-constant-mlc-compiler-compiler-version-text-const-compiler-version-text-minilang-compiler-1-2-5-mlc-compiler-ml-1778368293"></a>
### COMPILER_VERSION_TEXT

```ml
const COMPILER_VERSION_TEXT = "MiniLang Compiler 1.2.5"
```

Track compiler version text.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L40)

- [mlc.compiler.CompilerAstProfile](Type-mlc-compiler-compilerastprofile-228645018.md) — struct
<a id="extern_function-extern-function-mlc-compiler-createdirectoryw-extern-function-createdirectoryw-path-as-wstr-securityattributes-as-ptr-from-kernel32-dll-symbol-createdirectoryw-returns-bool-mlc-compiler-ml-1426705578"></a>
### CreateDirectoryW

```ml
extern function CreateDirectoryW(path as wstr, securityAttributes as ptr) from "kernel32.dll" symbol "CreateDirectoryW" returns bool
```

Creates create directory w.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `wstr` | — |  |
| `securityAttributes` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L68)

- [mlc.compiler.DeclCheckResult](Type-mlc-compiler-declcheckresult-2060192611.md) — struct
<a id="constant-constant-mlc-compiler-direct-section-label-threshold-const-direct-section-label-threshold-262144-mlc-compiler-ml-1543865588"></a>
### DIRECT_SECTION_LABEL_THRESHOLD

```ml
const DIRECT_SECTION_LABEL_THRESHOLD = 262144
```

Track direct section label threshold.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L42)

- [mlc.compiler.ExternSig](Type-mlc-compiler-externsig-560598825.md) — struct
- [mlc.compiler.ExternSigParam](Type-mlc-compiler-externsigparam-2135589990.md) — struct
- [mlc.compiler.ExternStructLayout](Type-mlc-compiler-externstructlayout-1581820847.md) — struct
- [mlc.compiler.FrontCheckResult](Type-mlc-compiler-frontcheckresult-868725246.md) — struct
- [mlc.compiler.FrontDiag](Type-mlc-compiler-frontdiag-1077463726.md) — struct
<a id="extern_function-extern-function-mlc-compiler-getfullpathnamew-extern-function-getfullpathnamew-path-as-wstr-bufferlen-as-u32-buffer-as-buffer-filepart-as-ptr-from-kernel32-dll-symbol-getfullpathnamew-returns-u32-mlc-compiler-ml-1815946993"></a>
### GetFullPathNameW

```ml
extern function GetFullPathNameW(path as wstr, bufferLen as u32, buffer as buffer, filePart as ptr) from "kernel32.dll" symbol "GetFullPathNameW" returns u32
```

Returns get full path name w.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `wstr` | — |  |
| `bufferLen` | `u32` | — |  |
| `buffer` | `buffer` | — |  |
| `filePart` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L65)

<a id="constant-constant-mlc-compiler-link-label-gc-object-stride-const-link-label-gc-object-stride-128-mlc-compiler-ml-2141431186"></a>
### LINK_LABEL_GC_OBJECT_STRIDE

```ml
const LINK_LABEL_GC_OBJECT_STRIDE = 128
```

Track link label gc object stride.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L56)

<a id="function-function-mlc-compiler-link-obj-dir-to-exe-function-link-obj-dir-to-exe-obj-dir-output-exe-subsystem-mlc-compiler-ml-58988272"></a>
### link_obj_dir_to_exe

```ml
function link_obj_dir_to_exe(obj_dir, output_exe, subsystem)
```

Link an existing object directory without parsing source again.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `obj_dir` | `dynamic` | — | Value supplied for `obj_dir`. |
| `output_exe` | `dynamic` | — | Value supplied for `output_exe`. |
| `subsystem` | `dynamic` | — | Value supplied for `subsystem`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L7942)

<a id="constant-constant-mlc-compiler-link-section-copy-gc-object-stride-const-link-section-copy-gc-object-stride-64-mlc-compiler-ml-1937426613"></a>
### LINK_SECTION_COPY_GC_OBJECT_STRIDE

```ml
const LINK_SECTION_COPY_GC_OBJECT_STRIDE = 64
```

Track link section copy gc object stride.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L58)

- [mlc.compiler.LoadProgramResult](Type-mlc-compiler-loadprogramresult-1061201331.md) — struct
<a id="constant-constant-mlc-compiler-mlo-write-batch-bytes-const-mlo-write-batch-bytes-1048576-mlc-compiler-ml-748603514"></a>
### MLO_WRITE_BATCH_BYTES

```ml
const MLO_WRITE_BATCH_BYTES = 1048576
```

Track mlo write batch bytes.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L60)

- [mlc.compiler.MloImportDll](Type-mlc-compiler-mloimportdll-110197463.md) — struct
- [mlc.compiler.MloLabel](Type-mlc-compiler-mlolabel-136786370.md) — struct
- [mlc.compiler.MloLayoutScan](Type-mlc-compiler-mlolayoutscan-1181540575.md) — struct
- [mlc.compiler.MloObject](Type-mlc-compiler-mloobject-1390614547.md) — struct
- [mlc.compiler.MloPatch](Type-mlc-compiler-mlopatch-190785186.md) — struct
- [mlc.compiler.MloStateCheckpoint](Type-mlc-compiler-mlostatecheckpoint-2114600243.md) — struct
- [mlc.compiler.ModuleInfo](Type-mlc-compiler-moduleinfo-1562856510.md) — struct
- [mlc.compiler.ObjBuf](Type-mlc-compiler-objbuf-1790717392.md) — struct
<a id="constant-constant-mlc-compiler-object-compiler-batch-size-const-object-compiler-batch-size-4-mlc-compiler-ml-2126982721"></a>
### OBJECT_COMPILER_BATCH_SIZE

```ml
const OBJECT_COMPILER_BATCH_SIZE = 4
```

Track object compiler batch size.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L48)

<a id="constant-constant-mlc-compiler-object-emission-gc-stride-const-object-emission-gc-stride-32-mlc-compiler-ml-1351999330"></a>
### OBJECT_EMISSION_GC_STRIDE

```ml
const OBJECT_EMISSION_GC_STRIDE = 32
```

Moderate function streams benefit from shorter allocation waves. Very large streams already peak while their early semantic graph is live, so extra collections only add work; retain the wider stride for those programs.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L50)

<a id="constant-constant-mlc-compiler-object-function-batch-size-const-object-function-batch-size-8-mlc-compiler-ml-1834323807"></a>
### OBJECT_FUNCTION_BATCH_SIZE

```ml
const OBJECT_FUNCTION_BATCH_SIZE = 8
```

Track object function batch size.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L46)

<a id="constant-constant-mlc-compiler-object-large-emission-function-threshold-const-object-large-emission-function-threshold-2048-mlc-compiler-ml-341021555"></a>
### OBJECT_LARGE_EMISSION_FUNCTION_THRESHOLD

```ml
const OBJECT_LARGE_EMISSION_FUNCTION_THRESHOLD = 2048
```

Track object large emission function threshold.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L54)

<a id="constant-constant-mlc-compiler-object-large-emission-gc-stride-const-object-large-emission-gc-stride-64-mlc-compiler-ml-545059213"></a>
### OBJECT_LARGE_EMISSION_GC_STRIDE

```ml
const OBJECT_LARGE_EMISSION_GC_STRIDE = 64
```

Track object large emission gc stride.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L52)

- [mlc.compiler.ObjReader](Type-mlc-compiler-objreader-1403613952.md) — struct
- [mlc.compiler.ParsedModule](Type-mlc-compiler-parsedmodule-244165215.md) — struct
- [mlc.compiler.PathStackNode](Type-mlc-compiler-pathstacknode-1479685739.md) — struct
- [mlc.compiler.ResolveCand](Type-mlc-compiler-resolvecand-2094759108.md) — struct
- [mlc.compiler.ResolveResult](Type-mlc-compiler-resolveresult-2042725723.md) — struct
<a id="function-function-mlc-compiler-run-cli-function-run-cli-args-mlc-compiler-ml-1299205999"></a>
### run_cli

```ml
function run_cli(args)
```

Parse command-line arguments and execute project, compile or link mode.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — | Command-line or call arguments. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L7957)

- [mlc.compiler.StrIntPair](Type-mlc-compiler-strintpair-989620974.md) — struct
- [mlc.compiler.StrPair](Type-mlc-compiler-strpair-1219907985.md) — struct
<a id="function-function-mlc-compiler-validate-extern-sigs-function-validate-extern-sigs-extern-sigs-extern-struct-names-mlc-compiler-ml-1523605262"></a>
### validate_extern_sigs

```ml
function validate_extern_sigs(extern_sigs, extern_struct_names)
```

Validate supported ABI types, out parameters, native struct references and ABI compatibility of aliases that share one physical import slot/thunk.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `extern_sigs` | `dynamic` | — | Value supplied for `extern_sigs`. |
| `extern_struct_names` | `dynamic` | — | Value supplied for `extern_struct_names`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L5769)
