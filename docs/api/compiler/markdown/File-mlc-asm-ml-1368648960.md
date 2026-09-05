# `mlc/asm.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc asm package.

Package: [`mlc.asm`](Package-mlc-asm-1639159108.md)

Reachable from entry: **yes**

## Imports

- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)

## Declarations

<a id="function-function-mlc-asm-alloc-zero-bytes-keepalive-function-alloc-zero-bytes-keepalive-keepalive-size-mlc-asm-ml-1846823705"></a>
### _alloc_zero_bytes_keepalive

```ml
function _alloc_zero_bytes_keepalive(keepalive, size)
```

Creates alloc zero bytes keepalive.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `keepalive` | `dynamic` | — |  |
| `size` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L149)

<a id="function-function-mlc-asm-array-contains-text-function-array-contains-text-arr-value-mlc-asm-ml-1782568426"></a>
### _array_contains_text

```ml
function _array_contains_text(arr, value)
```

Encode or manage array contains text in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `arr` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L133)

<a id="function-function-mlc-asm-byte-at-function-byte-at-asm-idx-mlc-asm-ml-1250101900"></a>
### _byte_at

```ml
function _byte_at(asm, idx)
```

Encode or manage byte at in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `idx` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L483)

<a id="function-function-mlc-asm-call-push-function-call-push-asm-label-mlc-asm-ml-613941761"></a>
### _call_push

```ml
function _call_push(asm, label)
```

Encode or manage call push in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `label` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L359)

<a id="function-function-mlc-asm-chunk-count-function-chunk-count-asm-mlc-asm-ml-1851627509"></a>
### _chunk_count

```ml
function _chunk_count(asm)
```

Encode or manage chunk count in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L569)

<a id="function-function-mlc-asm-chunk-get-function-chunk-get-asm-idx-mlc-asm-ml-1612250432"></a>
### _chunk_get

```ml
function _chunk_get(asm, idx)
```

Encode or manage chunk get in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `idx` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L578)

<a id="function-function-mlc-asm-chunk-push-function-chunk-push-asm-chunk-mlc-asm-ml-606385708"></a>
### _chunk_push

```ml
function _chunk_push(asm, chunk)
```

Encode or manage chunk push in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `chunk` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L626)

<a id="function-function-mlc-asm-chunk-set-function-chunk-set-asm-idx-chunk-mlc-asm-ml-1543979153"></a>
### _chunk_set

```ml
function _chunk_set(asm, idx, chunk)
```

Encode or manage chunk set in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `idx` | `dynamic` | — |  |
| `chunk` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L608)

<a id="function-function-mlc-asm-drop-last-patch-function-drop-last-patch-asm-mlc-asm-ml-1532661093"></a>
### _drop_last_patch

```ml
function _drop_last_patch(asm)
```

Encode or manage drop last patch in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L554)

<a id="function-function-mlc-asm-emit-function-emit-asm-b-mlc-asm-ml-1930020033"></a>
### _emit

```ml
function _emit(asm, b)
```

Encode or manage emit in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L751)

<a id="function-function-mlc-asm-emit32-function-emit32-asm-x-mlc-asm-ml-1113740717"></a>
### _emit32

```ml
function _emit32(asm, x)
```

Encode or manage emit32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L808)

<a id="function-function-mlc-asm-emit64-function-emit64-asm-x-mlc-asm-ml-1860428419"></a>
### _emit64

```ml
function _emit64(asm, x)
```

Encode or manage emit64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L842)

<a id="function-function-mlc-asm-emit8-function-emit8-asm-x-mlc-asm-ml-1284744155"></a>
### _emit8

```ml
function _emit8(asm, x)
```

Encode or manage emit8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L779)

<a id="function-function-mlc-asm-emit-bin-rr-function-emit-bin-rr-asm-op-dst-src-w-mlc-asm-ml-1848370970"></a>
### _emit_bin_rr

```ml
function _emit_bin_rr(asm, op, dst, src, w)
```

Encode or manage emit bin rr in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `op` | `dynamic` | — |  |
| `dst` | `dynamic` | — |  |
| `src` | `dynamic` | — |  |
| `w` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1932)

<a id="function-function-mlc-asm-emit-bytes-u8-function-emit-bytes-u8-v-mlc-asm-ml-1443579904"></a>
### _emit_bytes_u8

```ml
function _emit_bytes_u8(v)
```

Encode or manage emit bytes u8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `v` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L913)

<a id="function-function-mlc-asm-emit-modrm-function-emit-modrm-asm-mod-reg-rm-mlc-asm-ml-1252926862"></a>
### _emit_modrm

```ml
function _emit_modrm(asm, mod, reg, rm)
```

Encode or manage emit modrm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `mod` | `dynamic` | — |  |
| `reg` | `dynamic` | — |  |
| `rm` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L888)

<a id="function-function-mlc-asm-emit-rex-function-emit-rex-asm-w-r-x-b-force-mlc-asm-ml-1575744541"></a>
### _emit_rex

```ml
function _emit_rex(asm, w, r, x, b, force)
```

Encode or manage emit rex in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `w` | `dynamic` | — |  |
| `r` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |
| `force` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L878)

<a id="function-function-mlc-asm-emit-shift-imm8-function-emit-shift-imm8-asm-subop-reg-name-imm-w-mlc-asm-ml-2024202764"></a>
### _emit_shift_imm8

```ml
function _emit_shift_imm8(asm, subop, reg_name, imm, w)
```

Encode or manage emit shift imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `subop` | `dynamic` | — |  |
| `reg_name` | `dynamic` | — |  |
| `imm` | `dynamic` | — |  |
| `w` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2150)

<a id="function-function-mlc-asm-emit-sse-rr-function-emit-sse-rr-asm-prefix1-prefix2-opcode-dst-xmm-src-xmm-mlc-asm-ml-877527765"></a>
### _emit_sse_rr

```ml
function _emit_sse_rr(asm, prefix1, prefix2, opcode, dst_xmm, src_xmm)
```

Encode or manage emit sse rr in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `prefix1` | `dynamic` | — |  |
| `prefix2` | `dynamic` | — |  |
| `opcode` | `dynamic` | — |  |
| `dst_xmm` | `dynamic` | — |  |
| `src_xmm` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3292)

<a id="function-function-mlc-asm-encode-mem-function-encode-mem-reg-field-base-id-disp-mlc-asm-ml-809964036"></a>
### _encode_mem

```ml
function _encode_mem(reg_field, base_id, disp)
```

Converts encode mem.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reg_field` | `dynamic` | — |  |
| `base_id` | `dynamic` | — |  |
| `disp` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L921)

<a id="function-function-mlc-asm-encode-mem-bis-function-encode-mem-bis-reg-field-base-id-index-id-scale-disp-mlc-asm-ml-25078216"></a>
### _encode_mem_bis

```ml
function _encode_mem_bis(reg_field, base_id, index_id, scale, disp)
```

Converts encode mem bis.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `reg_field` | `dynamic` | — |  |
| `base_id` | `dynamic` | — |  |
| `index_id` | `dynamic` | — |  |
| `scale` | `dynamic` | — |  |
| `disp` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L973)

<a id="function-function-mlc-asm-ensure-capacity-function-ensure-capacity-asm-need-mlc-asm-ml-710290421"></a>
### _ensure_capacity

```ml
function _ensure_capacity(asm, need)
```

Encode or manage ensure capacity in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `need` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L664)

<a id="function-function-mlc-asm-fits-i8-function-fits-i8-x-as-int-returns-bool-mlc-asm-ml-581218552"></a>
### _fits_i8

```ml
function _fits_i8(x as int) returns bool
```

Encode or manage fits i8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `x` | `int` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L907)

<a id="function-function-mlc-asm-fmt-disp-function-fmt-disp-disp-mlc-asm-ml-615676156"></a>
### _fmt_disp

```ml
function _fmt_disp(disp)
```

Encode or manage fmt disp in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `disp` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3802)

<a id="function-function-mlc-asm-fmt-mem-function-fmt-mem-base-disp-mlc-asm-ml-455923723"></a>
### _fmt_mem

```ml
function _fmt_mem(base, disp)
```

Encode or manage fmt mem in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `base` | `dynamic` | — |  |
| `disp` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3808)

<a id="function-function-mlc-asm-fmt-mem-sib-function-fmt-mem-sib-base-index-reg-scale-disp-mlc-asm-ml-1478242070"></a>
### _fmt_mem_sib

```ml
function _fmt_mem_sib(base, index_reg, scale, disp)
```

Encode or manage fmt mem sib in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `base` | `dynamic` | — |  |
| `index_reg` | `dynamic` | — |  |
| `scale` | `dynamic` | — |  |
| `disp` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3814)

<a id="function-function-mlc-asm-fold-materialized-patch-set-function-fold-materialized-patch-set-asm-patch-chunks-patch-tail-out-b-mlc-asm-ml-337632046"></a>
### _fold_materialized_patch_set

```ml
function _fold_materialized_patch_set(asm, patch_chunks, patch_tail, out_b)
```

Fold same-fragment x64 PC-relative patches after materialization while walking the assembler's paged patch storage directly. Returning only the unresolved records prevents object emission from first flattening millions of local patches into a second managed array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `patch_chunks` | `dynamic` | — |  |
| `patch_tail` | `dynamic` | — |  |
| `out_b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L189)

<a id="function-function-mlc-asm-format-call-function-format-call-name-args-kwargs-mlc-asm-ml-1522458895"></a>
### _format_call

```ml
function _format_call(name, args, kwargs)
```

Converts format call.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |
| `args` | `dynamic` | — |  |
| `kwargs` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3820)

<a id="function-function-mlc-asm-gc-tmp-context-offset-function-gc-tmp-context-offset-label-mlc-asm-ml-492348028"></a>
### _gc_tmp_context_offset

```ml
function _gc_tmp_context_offset(label)
```

Encode or manage gc tmp context offset in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1135)

<a id="function-function-mlc-asm-grp1-imm-function-grp1-imm-asm-size-subop-rm-imm-mlc-asm-ml-1131576307"></a>
### _grp1_imm

```ml
function _grp1_imm(asm, size, subop, rm, imm)
```

Encode or manage grp1 imm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `size` | `dynamic` | — |  |
| `subop` | `dynamic` | — |  |
| `rm` | `dynamic` | — |  |
| `imm` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1753)

<a id="function-function-mlc-asm-grp1-r8-imm8-function-grp1-r8-imm8-asm-subop-reg8-imm-mlc-asm-ml-817252349"></a>
### _grp1_r8_imm8

```ml
function _grp1_r8_imm8(asm, subop, reg8, imm)
```

Encode or manage grp1 r8 imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `subop` | `dynamic` | — |  |
| `reg8` | `dynamic` | — |  |
| `imm` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2548)

<a id="function-function-mlc-asm-is-force-rex-8-function-is-force-rex-8-name-as-string-returns-bool-mlc-asm-ml-1735187869"></a>
### _is_force_rex_8

```ml
function _is_force_rex_8(name as string) returns bool
```

Reports whether is force rex 8.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `string` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L477)

<a id="function-function-mlc-asm-is-r32-name-function-is-r32-name-name-as-string-returns-bool-mlc-asm-ml-809474229"></a>
### _is_r32_name

```ml
function _is_r32_name(name as string) returns bool
```

Reports whether is r32 name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `string` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L471)

<a id="function-function-mlc-asm-is-r8-name-function-is-r8-name-name-as-string-returns-bool-mlc-asm-ml-790496333"></a>
### _is_r8_name

```ml
function _is_r8_name(name as string) returns bool
```

Reports whether is r8 name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `string` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L465)

<a id="function-function-mlc-asm-jcc-mnemonic-function-jcc-mnemonic-cc-mlc-asm-ml-1301070904"></a>
### _jcc_mnemonic

```ml
function _jcc_mnemonic(cc)
```

Encode or manage jcc mnemonic in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `cc` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3796)

<a id="function-function-mlc-asm-keepalive-barrier-function-keepalive-barrier-value-mlc-asm-ml-59488951"></a>
### _keepalive_barrier

```ml
function _keepalive_barrier(value)
```

Encode or manage keepalive barrier in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L143)

<a id="function-function-mlc-asm-label-index-function-label-index-labels-name-mlc-asm-ml-22519306"></a>
### _label_index

```ml
function _label_index(labels, name)
```

Encode or manage label index in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `labels` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L425)

<a id="function-function-mlc-asm-label-pos-function-label-pos-labels-name-mlc-asm-ml-1728841002"></a>
### _label_pos

```ml
function _label_pos(labels, name)
```

Encode or manage label pos in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `labels` | `dynamic` | — |  |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L435)

<a id="function-function-mlc-asm-label-push-function-label-push-asm-label-mlc-asm-ml-566373889"></a>
### _label_push

```ml
function _label_push(asm, label)
```

Encode or manage label push in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `label` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L416)

<a id="function-function-mlc-asm-last-patch-function-last-patch-asm-mlc-asm-ml-1493029077"></a>
### _last_patch

```ml
function _last_patch(asm)
```

Encode or manage last patch in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L546)

<a id="function-function-mlc-asm-materialize-buffer-function-materialize-buffer-asm-mlc-asm-ml-1600056139"></a>
### _materialize_buffer

```ml
function _materialize_buffer(asm)
```

Encode or manage materialize buffer in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L700)

<a id="global-global-mlc-asm-materialize-keepalive-materialize-keepalive-mlc-asm-ml-315293872"></a>
### _materialize_keepalive

```ml
_materialize_keepalive
```

Track materialize keepalive compiler state.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L116)

<a id="function-function-mlc-asm-modrm-function-modrm-mod-reg-rm-mlc-asm-ml-786224505"></a>
### _modrm

```ml
function _modrm(mod, reg, rm)
```

Encode or manage modrm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mod` | `dynamic` | — |  |
| `reg` | `dynamic` | — |  |
| `rm` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3784)

<a id="function-function-mlc-asm-modrm-byte-function-modrm-byte-mod-as-int-reg-as-int-rm-as-int-returns-int-mlc-asm-ml-51179326"></a>
### _modrm_byte

```ml
function _modrm_byte(mod as int, reg as int, rm as int) returns int
```

Encode or manage modrm byte in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `mod` | `int` | — |  |
| `reg` | `int` | — |  |
| `rm` | `int` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L895)

<a id="function-function-mlc-asm-patch-push-function-patch-push-asm-patch-mlc-asm-ml-1045153109"></a>
### _patch_push

```ml
function _patch_push(asm, patch)
```

Encode or manage patch push in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `patch` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L350)

<a id="function-function-mlc-asm-patches-replace-function-patches-replace-asm-patches-mlc-asm-ml-1863022165"></a>
### _patches_replace

```ml
function _patches_replace(asm, patches)
```

Encode or manage patches replace in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `patches` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L517)

<a id="function-function-mlc-asm-peephole-trim-tail-function-peephole-trim-tail-asm-n-mlc-asm-ml-1495235887"></a>
### _peephole_trim_tail

```ml
function _peephole_trim_tail(asm, n)
```

Encode or manage peephole trim tail in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `n` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3731)

<a id="function-function-mlc-asm-remove-patch-at-function-remove-patch-at-asm-idx-mlc-asm-ml-2107070144"></a>
### _remove_patch_at

```ml
function _remove_patch_at(asm, idx)
```

Releases or resets remove patch at.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `idx` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L531)

<a id="function-function-mlc-asm-resolve-patch-set-function-resolve-patch-set-asm-patch-chunks-patch-tail-kept-chunks-kept-tail-mlc-asm-ml-1415396307"></a>
### _resolve_patch_set

```ml
function _resolve_patch_set(asm, patch_chunks, patch_tail, kept_chunks, kept_tail)
```

Apply every currently resolvable rel32 patch and retain forward references.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `patch_chunks` | `dynamic` | — |  |
| `patch_tail` | `dynamic` | — |  |
| `kept_chunks` | `dynamic` | — |  |
| `kept_tail` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L245)

<a id="function-function-mlc-asm-restore-materialized-chunks-function-restore-materialized-chunks-asm-mlc-asm-ml-1366154781"></a>
### _restore_materialized_chunks

```ml
function _restore_materialized_chunks(asm)
```

Materialization releases the paged backing store to reduce compiler peak memory. Recreate it lazily if a caller later resumes emission or patching. This keeps materialize() reusable without retaining both representations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L635)

<a id="function-function-mlc-asm-rex-function-rex-w-r-x-b-force-mlc-asm-ml-1532133820"></a>
### _rex

```ml
function _rex(w, r, x, b, force)
```

Encode or manage rex in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `w` | `dynamic` | — |  |
| `r` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |
| `force` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3775)

<a id="function-function-mlc-asm-rid-any-function-rid-any-name-mlc-asm-ml-1601508049"></a>
### _rid_any

```ml
function _rid_any(name)
```

Encode or manage rid any in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L443)

<a id="function-function-mlc-asm-scale-bits-function-scale-bits-scale-mlc-asm-ml-1350604720"></a>
### _scale_bits

```ml
function _scale_bits(scale)
```

Encode or manage scale bits in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `scale` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L963)

<a id="function-function-mlc-asm-set-chunk-byte-function-set-chunk-byte-asm-idx-value-mlc-asm-ml-58383037"></a>
### _set_chunk_byte

```ml
function _set_chunk_byte(asm, idx, value)
```

Updates set chunk byte.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `idx` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L687)

<a id="function-function-mlc-asm-sib-function-sib-scale-index-base-mlc-asm-ml-719836301"></a>
### _sib

```ml
function _sib(scale, index, base)
```

Encode or manage sib in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `scale` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |
| `base` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3790)

<a id="function-function-mlc-asm-sib-byte-function-sib-byte-scale-as-int-index-as-int-base-as-int-returns-int-mlc-asm-ml-133039292"></a>
### _sib_byte

```ml
function _sib_byte(scale as int, index as int, base as int) returns int
```

Encode or manage sib byte in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `scale` | `int` | — |  |
| `index` | `int` | — |  |
| `base` | `int` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L901)

<a id="function-function-mlc-asm-spill-before-call-function-spill-before-call-asm-mlc-asm-ml-495611853"></a>
### _spill_before_call

```ml
function _spill_before_call(asm)
```

Encode or manage spill before call in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L400)

<a id="function-function-mlc-asm-starts-with-text-function-starts-with-text-text-prefix-mlc-asm-ml-634186839"></a>
### _starts_with_text

```ml
function _starts_with_text(text, prefix)
```

Encode or manage starts with text in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `dynamic` | — |  |
| `prefix` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L120)

<a id="function-function-mlc-asm-track-helper-label-function-track-helper-label-asm-label-mlc-asm-ml-656463849"></a>
### _track_helper_label

```ml
function _track_helper_label(asm, label)
```

Encode or manage track helper label in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — |  |
| `label` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L368)

<a id="function-function-mlc-asm-vex3-function-vex3-m-w-vvvv-l-pp-r-x-b-mlc-asm-ml-1694335052"></a>
### _vex3

```ml
function _vex3(m, w, vvvv, l, pp, r, x, b)
```

Encode or manage vex3 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `m` | `dynamic` | — |  |
| `w` | `dynamic` | — |  |
| `vvvv` | `dynamic` | — |  |
| `l` | `dynamic` | — |  |
| `pp` | `dynamic` | — |  |
| `r` | `dynamic` | — |  |
| `x` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1011)

<a id="function-function-mlc-asm-xmm-id-function-xmm-id-name-mlc-asm-ml-1056018291"></a>
### _xmm_id

```ml
function _xmm_id(name)
```

Encode or manage xmm id in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1031)

<a id="function-function-mlc-asm-ymm-id-function-ymm-id-name-mlc-asm-ml-446720225"></a>
### _ymm_id

```ml
function _ymm_id(name)
```

Encode or manage ymm id in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1053)

<a id="function-function-mlc-asm-add-patch-function-add-patch-asm-position-label-kind-mlc-asm-ml-1666246762"></a>
### add_patch

```ml
function add_patch(asm, position, label, kind)
```

Add a relocation owned by a separately assembled fragment. This keeps large parent assemblers out of the fragment's per-instruction update path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `position` | `dynamic` | — | Value supplied for `position`. |
| `label` | `dynamic` | — | Value supplied for `label`. |
| `kind` | `dynamic` | — | Value supplied for `kind`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L836)

<a id="function-function-mlc-asm-add-r32-imm-function-add-r32-imm-asm-reg-name-imm-mlc-asm-ml-1236754780"></a>
### add_r32_imm

```ml
function add_r32_imm(asm, reg_name, imm)
```

Updates add r32 imm.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1888)

<a id="function-function-mlc-asm-add-r32-r32-function-add-r32-r32-asm-dst-src-mlc-asm-ml-441334020"></a>
### add_r32_r32

```ml
function add_r32_r32(asm, dst, src)
```

Updates add r32 r32.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1956)

<a id="function-function-mlc-asm-add-r64-imm-function-add-r64-imm-asm-reg-name-imm-mlc-asm-ml-526115370"></a>
### add_r64_imm

```ml
function add_r64_imm(asm, reg_name, imm)
```

Updates add r64 imm.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1803)

<a id="function-function-mlc-asm-add-r64-imm8-function-add-r64-imm8-asm-reg-name-imm-mlc-asm-ml-1865708626"></a>
### add_r64_imm8

```ml
function add_r64_imm8(asm, reg_name, imm)
```

Updates add r64 imm8.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1839)

<a id="function-function-mlc-asm-add-r64-r64-function-add-r64-r64-asm-dst-src-mlc-asm-ml-606237132"></a>
### add_r64_r64

```ml
function add_r64_r64(asm, dst, src)
```

Updates add r64 r64.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1946)

<a id="function-function-mlc-asm-add-r8-imm8-function-add-r8-imm8-asm-reg8-imm-mlc-asm-ml-1379506176"></a>
### add_r8_imm8

```ml
function add_r8_imm8(asm, reg8, imm)
```

Updates add r8 imm8.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg8` | `dynamic` | — | Value supplied for `reg8`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2583)

<a id="function-function-mlc-asm-add-rax-imm8-function-add-rax-imm8-asm-imm-mlc-asm-ml-1294979934"></a>
### add_rax_imm8

```ml
function add_rax_imm8(asm, imm)
```

Updates add rax imm8.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2134)

<a id="function-function-mlc-asm-add-rax-r10-function-add-rax-r10-asm-mlc-asm-ml-1577336883"></a>
### add_rax_r10

```ml
function add_rax_r10(asm)
```

Updates add rax r10.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2127)

<a id="function-function-mlc-asm-add-rcx-imm32-function-add-rcx-imm32-asm-imm-mlc-asm-ml-936260126"></a>
### add_rcx_imm32

```ml
function add_rcx_imm32(asm, imm)
```

Updates add rcx imm32.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2275)

<a id="function-function-mlc-asm-add-rcx-imm8-function-add-rcx-imm8-asm-imm-mlc-asm-ml-1756460366"></a>
### add_rcx_imm8

```ml
function add_rcx_imm8(asm, imm)
```

Updates add rcx imm8.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2268)

<a id="function-function-mlc-asm-add-rsp-imm32-function-add-rsp-imm32-asm-imm-mlc-asm-ml-1850344526"></a>
### add_rsp_imm32

```ml
function add_rsp_imm32(asm, imm)
```

Updates add rsp imm32.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2305)

<a id="function-function-mlc-asm-add-rsp-imm8-function-add-rsp-imm8-asm-imm-mlc-asm-ml-2144943166"></a>
### add_rsp_imm8

```ml
function add_rsp_imm8(asm, imm)
```

Updates add rsp imm8.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2290)

<a id="function-function-mlc-asm-addsd-xmm-xmm-function-addsd-xmm-xmm-asm-dst-xmm-src-xmm-mlc-asm-ml-579743080"></a>
### addsd_xmm_xmm

```ml
function addsd_xmm_xmm(asm, dst_xmm, src_xmm)
```

Updates addsd xmm xmm.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst_xmm` | `dynamic` | — | Value supplied for `dst_xmm`. |
| `src_xmm` | `dynamic` | — | Value supplied for `src_xmm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3317)

<a id="function-function-mlc-asm-and-r32-imm-function-and-r32-imm-asm-reg-name-imm-mlc-asm-ml-1221207828"></a>
### and_r32_imm

```ml
function and_r32_imm(asm, reg_name, imm)
```

Encode or manage and r32 imm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1898)

<a id="function-function-mlc-asm-and-r32-r32-function-and-r32-r32-asm-dst-src-mlc-asm-ml-458899852"></a>
### and_r32_r32

```ml
function and_r32_r32(asm, dst, src)
```

Encode or manage and r32 r32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1981)

<a id="function-function-mlc-asm-and-r64-imm-function-and-r64-imm-asm-reg-name-imm-mlc-asm-ml-292145406"></a>
### and_r64_imm

```ml
function and_r64_imm(asm, reg_name, imm)
```

Encode or manage and r64 imm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1813)

<a id="function-function-mlc-asm-and-r64-imm8-function-and-r64-imm8-asm-as-struct-reg-name-as-string-imm-as-int-returns-struct-mlc-asm-ml-221705171"></a>
### and_r64_imm8

```ml
function and_r64_imm8(asm as struct, reg_name as string, imm as int) returns struct
```

Encode or manage and r64 imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `struct` | — | Value supplied for `asm`. |
| `reg_name` | `string` | — | Value supplied for `reg_name`. |
| `imm` | `int` | — | Value supplied for `imm`. |


**Returns:** The resulting `struct` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1857)

<a id="function-function-mlc-asm-and-r64-r64-function-and-r64-r64-asm-dst-src-mlc-asm-ml-1545923012"></a>
### and_r64_r64

```ml
function and_r64_r64(asm, dst, src)
```

Encode or manage and r64 r64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1976)

<a id="function-function-mlc-asm-and-r8-imm8-function-and-r8-imm8-asm-reg8-imm-mlc-asm-ml-852967172"></a>
### and_r8_imm8

```ml
function and_r8_imm8(asm, reg8, imm)
```

Encode or manage and r8 imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg8` | `dynamic` | — | Value supplied for `reg8`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2568)

<a id="function-function-mlc-asm-and-r8-r8-function-and-r8-r8-asm-dst-src-mlc-asm-ml-1341814340"></a>
### and_r8_r8

```ml
function and_r8_r8(asm, dst, src)
```

Encode or manage and r8 r8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1996)

<a id="function-function-mlc-asm-and-rax-imm8-function-and-rax-imm8-asm-imm-mlc-asm-ml-363316942"></a>
### and_rax_imm8

```ml
function and_rax_imm8(asm, imm)
```

Encode or manage and rax imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2142)

- [mlc.asm.AsmBuilder](Type-mlc-asm-asmbuilder-436910800.md) — struct
- [mlc.asm.AsmLabel](Type-mlc-asm-asmlabel-1991674317.md) — struct
- [mlc.asm.AsmPatch](Type-mlc-asm-asmpatch-681509561.md) — struct
<a id="function-function-mlc-asm-bsf-r32-r32-function-bsf-r32-r32-asm-dst32-src32-mlc-asm-ml-1189041242"></a>
### bsf_r32_r32

```ml
function bsf_r32_r32(asm, dst32, src32)
```

Encode or manage bsf r32 r32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst32` | `dynamic` | — | Value supplied for `dst32`. |
| `src32` | `dynamic` | — | Value supplied for `src32`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2680)

<a id="function-function-mlc-asm-bsr-r32-r32-function-bsr-r32-r32-asm-dst32-src32-mlc-asm-ml-869848634"></a>
### bsr_r32_r32

```ml
function bsr_r32_r32(asm, dst32, src32)
```

Encode or manage bsr r32 r32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst32` | `dynamic` | — | Value supplied for `dst32`. |
| `src32` | `dynamic` | — | Value supplied for `src32`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2699)

<a id="function-function-mlc-asm-call-function-call-asm-label-mlc-asm-ml-332714073"></a>
### call

```ml
function call(asm, label)
```

Encode or manage call in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1390)

<a id="function-function-mlc-asm-call-membase-disp-function-call-membase-disp-asm-base-disp-mlc-asm-ml-677240064"></a>
### call_membase_disp

```ml
function call_membase_disp(asm, base, disp)
```

Encode or manage call membase disp in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1416)

<a id="function-function-mlc-asm-call-rax-function-call-rax-asm-mlc-asm-ml-1240620053"></a>
### call_rax

```ml
function call_rax(asm)
```

Encode or manage call rax in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1405)

<a id="function-function-mlc-asm-call-rip-qword-function-call-rip-qword-asm-label-mlc-asm-ml-1481692961"></a>
### call_rip_qword

```ml
function call_rip_qword(asm, label)
```

Encode or manage call rip qword in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1430)

<a id="function-function-mlc-asm-clear-calls-function-clear-calls-asm-mlc-asm-ml-319950115"></a>
### clear_calls

```ml
function clear_calls(asm)
```

Releases or resets clear calls.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L328)

<a id="function-function-mlc-asm-clear-tracked-helpers-function-clear-tracked-helpers-asm-mlc-asm-ml-805444525"></a>
### clear_tracked_helpers

```ml
function clear_tracked_helpers(asm)
```

Releases or resets clear tracked helpers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L336)

<a id="function-function-mlc-asm-cmp-membase-disp-imm8-function-cmp-membase-disp-imm8-asm-base-disp-imm-mlc-asm-ml-492106309"></a>
### cmp_membase_disp_imm8

```ml
function cmp_membase_disp_imm8(asm, base, disp, imm)
```

Encode or manage cmp membase disp imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2645)

<a id="function-function-mlc-asm-cmp-r32-imm-function-cmp-r32-imm-asm-reg-name-imm-mlc-asm-ml-45694778"></a>
### cmp_r32_imm

```ml
function cmp_r32_imm(asm, reg_name, imm)
```

Encode or manage cmp r32 imm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1913)

<a id="function-function-mlc-asm-cmp-r32-imm32-function-cmp-r32-imm32-asm-reg-name-imm-mlc-asm-ml-1636248900"></a>
### cmp_r32_imm32

```ml
function cmp_r32_imm32(asm, reg_name, imm)
```

Encode or manage cmp r32 imm32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1923)

<a id="function-function-mlc-asm-cmp-r32-r32-function-cmp-r32-r32-asm-left-right-mlc-asm-ml-211470546"></a>
### cmp_r32_r32

```ml
function cmp_r32_r32(asm, left, right)
```

Encode or manage cmp r32 r32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `left` | `dynamic` | — | Left input value. |
| `right` | `dynamic` | — | Right input value. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2012)

<a id="function-function-mlc-asm-cmp-r64-imm-function-cmp-r64-imm-asm-reg-name-imm-mlc-asm-ml-1783015044"></a>
### cmp_r64_imm

```ml
function cmp_r64_imm(asm, reg_name, imm)
```

Encode or manage cmp r64 imm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1828)

<a id="function-function-mlc-asm-cmp-r64-imm32-function-cmp-r64-imm32-asm-reg-name-imm-mlc-asm-ml-1486450838"></a>
### cmp_r64_imm32

```ml
function cmp_r64_imm32(asm, reg_name, imm)
```

Encode or manage cmp r64 imm32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1928)

<a id="function-function-mlc-asm-cmp-r64-imm8-function-cmp-r64-imm8-asm-as-struct-reg-name-as-string-imm-as-int-returns-struct-mlc-asm-ml-1127591647"></a>
### cmp_r64_imm8

```ml
function cmp_r64_imm8(asm as struct, reg_name as string, imm as int) returns struct
```

Encode or manage cmp r64 imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `struct` | — | Value supplied for `asm`. |
| `reg_name` | `string` | — | Value supplied for `reg_name`. |
| `imm` | `int` | — | Value supplied for `imm`. |


**Returns:** The resulting `struct` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1880)

<a id="function-function-mlc-asm-cmp-r64-r64-function-cmp-r64-r64-asm-left-right-mlc-asm-ml-502250"></a>
### cmp_r64_r64

```ml
function cmp_r64_r64(asm, left, right)
```

Encode or manage cmp r64 r64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `left` | `dynamic` | — | Left input value. |
| `right` | `dynamic` | — | Right input value. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2007)

<a id="function-function-mlc-asm-cmp-r8-imm8-function-cmp-r8-imm8-asm-reg8-imm-mlc-asm-ml-921352058"></a>
### cmp_r8_imm8

```ml
function cmp_r8_imm8(asm, reg8, imm)
```

Encode or manage cmp r8 imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg8` | `dynamic` | — | Value supplied for `reg8`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2594)

<a id="function-function-mlc-asm-cmp-r8-membase-disp-function-cmp-r8-membase-disp-asm-reg8-base-disp-mlc-asm-ml-1368943660"></a>
### cmp_r8_membase_disp

```ml
function cmp_r8_membase_disp(asm, reg8, base, disp)
```

Encode or manage cmp r8 membase disp in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg8` | `dynamic` | — | Value supplied for `reg8`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2625)

<a id="function-function-mlc-asm-cmp-rax-imm32-function-cmp-rax-imm32-asm-imm-mlc-asm-ml-819904964"></a>
### cmp_rax_imm32

```ml
function cmp_rax_imm32(asm, imm)
```

Encode or manage cmp rax imm32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2241)

<a id="function-function-mlc-asm-cmp-rax-imm8-function-cmp-rax-imm8-asm-as-struct-imm-as-int-returns-struct-mlc-asm-ml-1064240996"></a>
### cmp_rax_imm8

```ml
function cmp_rax_imm8(asm as struct, imm as int) returns struct
```

Encode or manage cmp rax imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `struct` | — | Value supplied for `asm`. |
| `imm` | `int` | — | Value supplied for `imm`. |


**Returns:** The resulting `struct` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2234)

<a id="function-function-mlc-asm-cmp-rax-r10-function-cmp-rax-r10-asm-mlc-asm-ml-478965601"></a>
### cmp_rax_r10

```ml
function cmp_rax_r10(asm)
```

Encode or manage cmp rax r10 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2226)

<a id="function-function-mlc-asm-cpuid-function-cpuid-asm-mlc-asm-ml-960815007"></a>
### cpuid

```ml
function cpuid(asm)
```

Encode or manage cpuid in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3275)

<a id="function-function-mlc-asm-cqo-function-cqo-asm-mlc-asm-ml-246911879"></a>
### cqo

```ml
function cqo(asm)
```

Encode or manage cqo in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3201)

<a id="function-function-mlc-asm-crc32-r32-membase-disp8-function-crc32-r32-membase-disp8-asm-dst32-base-disp-mlc-asm-ml-719330366"></a>
### crc32_r32_membase_disp8

```ml
function crc32_r32_membase_disp8(asm, dst32, base, disp)
```

Encode or manage crc32 r32 membase disp8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst32` | `dynamic` | — | Value supplied for `dst32`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2738)

<a id="function-function-mlc-asm-crc32-r64-membase-disp-function-crc32-r64-membase-disp-asm-dst64-base-disp-mlc-asm-ml-1760457167"></a>
### crc32_r64_membase_disp

```ml
function crc32_r64_membase_disp(asm, dst64, base, disp)
```

Emit SSE4.2 CRC32 r64, qword [base+disp]. Callers must dispatch on CPUID.SSE4.2; this instruction implements CRC-32C, not CRC-32/IEEE.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst64` | `dynamic` | — | Value supplied for `dst64`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2719)

<a id="function-function-mlc-asm-cvtsd2ss-xmm-xmm-function-cvtsd2ss-xmm-xmm-asm-dst-src-mlc-asm-ml-302972442"></a>
### cvtsd2ss_xmm_xmm

```ml
function cvtsd2ss_xmm_xmm(asm, dst, src)
```

Encode or manage cvtsd2ss xmm xmm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3597)

<a id="function-function-mlc-asm-cvtsi2sd-xmm-r64-function-cvtsi2sd-xmm-r64-asm-dst-xmm-src-reg-mlc-asm-ml-1035364584"></a>
### cvtsi2sd_xmm_r64

```ml
function cvtsi2sd_xmm_r64(asm, dst_xmm, src_reg)
```

Encode or manage cvtsi2sd xmm r64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst_xmm` | `dynamic` | — | Value supplied for `dst_xmm`. |
| `src_reg` | `dynamic` | — | Value supplied for `src_reg`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3412)

<a id="function-function-mlc-asm-cvtss2sd-xmm-xmm-function-cvtss2sd-xmm-xmm-asm-dst-src-mlc-asm-ml-977744022"></a>
### cvtss2sd_xmm_xmm

```ml
function cvtss2sd_xmm_xmm(asm, dst, src)
```

Encode or manage cvtss2sd xmm xmm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3613)

<a id="function-function-mlc-asm-cvttsd2si-r64-xmm-function-cvttsd2si-r64-xmm-asm-dst-reg-src-xmm-mlc-asm-ml-1942516160"></a>
### cvttsd2si_r64_xmm

```ml
function cvttsd2si_r64_xmm(asm, dst_reg, src_xmm)
```

Encode or manage cvttsd2si r64 xmm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst_reg` | `dynamic` | — | Value supplied for `dst_reg`. |
| `src_xmm` | `dynamic` | — | Value supplied for `src_xmm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3428)

<a id="function-function-mlc-asm-dec-membase-disp-qword-function-dec-membase-disp-qword-asm-base-disp-mlc-asm-ml-1642462268"></a>
### dec_membase_disp_qword

```ml
function dec_membase_disp_qword(asm, base, disp)
```

Encode or manage dec membase disp qword in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2819)

<a id="function-function-mlc-asm-dec-r32-function-dec-r32-asm-reg-name-mlc-asm-ml-1829827573"></a>
### dec_r32

```ml
function dec_r32(asm, reg_name)
```

Encode or manage dec r32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2792)

<a id="function-function-mlc-asm-dec-r64-function-dec-r64-asm-reg-name-mlc-asm-ml-342211095"></a>
### dec_r64

```ml
function dec_r64(asm, reg_name)
```

Encode or manage dec r64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2768)

<a id="function-function-mlc-asm-disable-listing-function-disable-listing-asm-mlc-asm-ml-1312507739"></a>
### disable_listing

```ml
function disable_listing(asm)
```

Encode or manage disable listing in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3752)

<a id="function-function-mlc-asm-div-r64-function-div-r64-asm-reg-name-mlc-asm-ml-806295681"></a>
### div_r64

```ml
function div_r64(asm, reg_name)
```

Encode or manage div r64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3222)

<a id="function-function-mlc-asm-divsd-xmm-xmm-function-divsd-xmm-xmm-asm-dst-xmm-src-xmm-mlc-asm-ml-788105124"></a>
### divsd_xmm_xmm

```ml
function divsd_xmm_xmm(asm, dst_xmm, src_xmm)
```

Encode or manage divsd xmm xmm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst_xmm` | `dynamic` | — | Value supplied for `dst_xmm`. |
| `src_xmm` | `dynamic` | — | Value supplied for `src_xmm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3341)

<a id="function-function-mlc-asm-emit-function-emit-asm-b-mlc-asm-ml-892766301"></a>
### emit

```ml
function emit(asm, b)
```

Encode or manage emit in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `b` | `dynamic` | — | Second input value. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1076)

<a id="function-function-mlc-asm-emit32-function-emit32-asm-x-mlc-asm-ml-875885211"></a>
### emit32

```ml
function emit32(asm, x)
```

Encode or manage emit32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `x` | `dynamic` | — | Value supplied for `x`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1090)

<a id="function-function-mlc-asm-emit64-function-emit64-asm-x-mlc-asm-ml-1942395999"></a>
### emit64

```ml
function emit64(asm, x)
```

Encode or manage emit64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `x` | `dynamic` | — | Value supplied for `x`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1097)

<a id="function-function-mlc-asm-emit8-function-emit8-asm-x-mlc-asm-ml-1396847481"></a>
### emit8

```ml
function emit8(asm, x)
```

Encode or manage emit8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `x` | `dynamic` | — | Value supplied for `x`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1083)

<a id="function-function-mlc-asm-emit-placeholder-function-emit-placeholder-asm-text-mlc-asm-ml-1552718002"></a>
### emit_placeholder

```ml
function emit_placeholder(asm, text)
```

Encode or manage emit placeholder in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `text` | `dynamic` | — | Text to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3834)

<a id="function-function-mlc-asm-enable-listing-function-enable-listing-asm-path-show-addr-show-bytes-show-text-mlc-asm-ml-429631043"></a>
### enable_listing

```ml
function enable_listing(asm, path, show_addr, show_bytes, show_text)
```

Encode or manage enable listing in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `path` | `dynamic` | — | Path to operate on. |
| `show_addr` | `dynamic` | — | Value supplied for `show_addr`. |
| `show_bytes` | `dynamic` | — | Value supplied for `show_bytes`. |
| `show_text` | `dynamic` | — | Value supplied for `show_text`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3746)

- [mlc.asm.EncMem](Type-mlc-asm-encmem-428679303.md) — struct
<a id="function-function-mlc-asm-finalize-function-finalize-asm-mlc-asm-ml-1223055845"></a>
### finalize

```ml
function finalize(asm)
```

Encode or manage finalize in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1194)

<a id="function-function-mlc-asm-get-calls-function-get-calls-asm-mlc-asm-ml-1257997533"></a>
### get_calls

```ml
function get_calls(asm)
```

Returns get calls.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L313)

<a id="function-function-mlc-asm-get-labels-function-get-labels-asm-mlc-asm-ml-1671839357"></a>
### get_labels

```ml
function get_labels(asm)
```

Returns get labels.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L319)

<a id="function-function-mlc-asm-get-patches-function-get-patches-asm-mlc-asm-ml-1802592391"></a>
### get_patches

```ml
function get_patches(asm)
```

Materialize unresolved and active patch chunks in deterministic order.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L170)

<a id="function-function-mlc-asm-get-tracked-helpers-function-get-tracked-helpers-asm-mlc-asm-ml-233960775"></a>
### get_tracked_helpers

```ml
function get_tracked_helpers(asm)
```

Returns get tracked helpers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L344)

<a id="function-function-mlc-asm-gpr-function-gpr-name-mlc-asm-ml-897082947"></a>
### gpr

```ml
function gpr(name)
```

Encode or manage gpr in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — | Name of the requested item. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3758)

- [mlc.asm.GPR](Type-mlc-asm-gpr-1509225273.md) — struct
<a id="function-function-mlc-asm-idiv-r64-function-idiv-r64-asm-reg-name-mlc-asm-ml-772090109"></a>
### idiv_r64

```ml
function idiv_r64(asm, reg_name)
```

Encode or manage idiv r64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3210)

<a id="function-function-mlc-asm-imul-r64-r64-function-imul-r64-r64-asm-dst-src-mlc-asm-ml-107696754"></a>
### imul_r64_r64

```ml
function imul_r64_r64(asm, dst, src)
```

Encode or manage imul r64 r64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3166)

<a id="function-function-mlc-asm-imul-r64-r64-imm-function-imul-r64-r64-imm-asm-dst-src-imm-mlc-asm-ml-2034570803"></a>
### imul_r64_r64_imm

```ml
function imul_r64_r64_imm(asm, dst, src, imm)
```

Encode or manage imul r64 r64 imm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3182)

<a id="function-function-mlc-asm-inc-membase-disp-qword-function-inc-membase-disp-qword-asm-base-disp-mlc-asm-ml-2113439912"></a>
### inc_membase_disp_qword

```ml
function inc_membase_disp_qword(asm, base, disp)
```

Encode or manage inc membase disp qword in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2805)

<a id="function-function-mlc-asm-inc-r32-function-inc-r32-asm-reg-name-mlc-asm-ml-1991958713"></a>
### inc_r32

```ml
function inc_r32(asm, reg_name)
```

Encode or manage inc r32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2780)

<a id="function-function-mlc-asm-inc-r64-function-inc-r64-asm-reg-name-mlc-asm-ml-1857234975"></a>
### inc_r64

```ml
function inc_r64(asm, reg_name)
```

Encode or manage inc r64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2756)

<a id="function-function-mlc-asm-ja-function-ja-asm-label-mlc-asm-ml-1629144245"></a>
### ja

```ml
function ja(asm, label)
```

Encode or manage ja in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1381)

<a id="function-function-mlc-asm-jae-function-jae-asm-label-mlc-asm-ml-103205741"></a>
### jae

```ml
function jae(asm, label)
```

Encode or manage jae in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1385)

<a id="function-function-mlc-asm-jb-function-jb-asm-label-mlc-asm-ml-328316909"></a>
### jb

```ml
function jb(asm, label)
```

Encode or manage jb in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1373)

<a id="function-function-mlc-asm-jbe-function-jbe-asm-label-mlc-asm-ml-180839243"></a>
### jbe

```ml
function jbe(asm, label)
```

Encode or manage jbe in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1377)

<a id="function-function-mlc-asm-jcc-function-jcc-asm-cc-label-mlc-asm-ml-225047267"></a>
### jcc

```ml
function jcc(asm, cc, label)
```

Encode or manage jcc in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `cc` | `dynamic` | — | Value supplied for `cc`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1294)

<a id="function-function-mlc-asm-je-function-je-asm-label-mlc-asm-ml-604694101"></a>
### je

```ml
function je(asm, label)
```

Encode or manage je in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1341)

<a id="function-function-mlc-asm-jg-function-jg-asm-label-mlc-asm-ml-783503489"></a>
### jg

```ml
function jg(asm, label)
```

Encode or manage jg in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1365)

<a id="function-function-mlc-asm-jge-function-jge-asm-label-mlc-asm-ml-761932241"></a>
### jge

```ml
function jge(asm, label)
```

Encode or manage jge in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1369)

<a id="function-function-mlc-asm-jl-function-jl-asm-label-mlc-asm-ml-481496257"></a>
### jl

```ml
function jl(asm, label)
```

Encode or manage jl in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1357)

<a id="function-function-mlc-asm-jle-function-jle-asm-label-mlc-asm-ml-257641171"></a>
### jle

```ml
function jle(asm, label)
```

Encode or manage jle in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1361)

<a id="function-function-mlc-asm-jmp-function-jmp-asm-label-mlc-asm-ml-1247247907"></a>
### jmp

```ml
function jmp(asm, label)
```

Encode or manage jmp in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1241)

<a id="function-function-mlc-asm-jmp-r64-function-jmp-r64-asm-reg-mlc-asm-ml-1944190845"></a>
### jmp_r64

```ml
function jmp_r64(asm, reg)
```

Encode or manage jmp r64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg` | `dynamic` | — | Value supplied for `reg`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1281)

<a id="function-function-mlc-asm-jne-function-jne-asm-label-mlc-asm-ml-532552035"></a>
### jne

```ml
function jne(asm, label)
```

Encode or manage jne in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1349)

<a id="function-function-mlc-asm-jnz-function-jnz-asm-label-mlc-asm-ml-1967950889"></a>
### jnz

```ml
function jnz(asm, label)
```

Encode or manage jnz in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1353)

<a id="function-function-mlc-asm-jz-function-jz-asm-label-mlc-asm-ml-201224317"></a>
### jz

```ml
function jz(asm, label)
```

Encode or manage jz in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1345)

<a id="function-function-mlc-asm-lea-r11-rip-function-lea-r11-rip-asm-label-mlc-asm-ml-1655740875"></a>
### lea_r11_rip

```ml
function lea_r11_rip(asm, label)
```

Encode or manage lea r11 rip in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1501)

<a id="function-function-mlc-asm-lea-r64-mem-bis-function-lea-r64-mem-bis-asm-dst-base-index-reg-scale-disp-mlc-asm-ml-26051556"></a>
### lea_r64_mem_bis

```ml
function lea_r64_mem_bis(asm, dst, base, index_reg, scale, disp)
```

Encode or manage lea r64 mem bis in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `index_reg` | `dynamic` | — | Value supplied for `index_reg`. |
| `scale` | `dynamic` | — | Value supplied for `scale`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3112)

<a id="function-function-mlc-asm-lea-r64-membase-disp-function-lea-r64-membase-disp-asm-dst-base-disp-mlc-asm-ml-613633253"></a>
### lea_r64_membase_disp

```ml
function lea_r64_membase_disp(asm, dst, base, disp)
```

Encode or manage lea r64 membase disp in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2503)

<a id="function-function-mlc-asm-lea-r64-rip-function-lea-r64-rip-asm-dst-label-mlc-asm-ml-859437180"></a>
### lea_r64_rip

```ml
function lea_r64_rip(asm, dst, label)
```

Encode or manage lea r64 rip in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1456)

<a id="function-function-mlc-asm-lea-r8-rip-function-lea-r8-rip-asm-label-mlc-asm-ml-524136109"></a>
### lea_r8_rip

```ml
function lea_r8_rip(asm, label)
```

Encode or manage lea r8 rip in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1487)

<a id="function-function-mlc-asm-lea-r9-rip-function-lea-r9-rip-asm-label-mlc-asm-ml-1511291985"></a>
### lea_r9_rip

```ml
function lea_r9_rip(asm, label)
```

Encode or manage lea r9 rip in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1494)

<a id="function-function-mlc-asm-lea-rax-rip-function-lea-rax-rip-asm-as-struct-label-as-string-returns-struct-mlc-asm-ml-1441810659"></a>
### lea_rax_rip

```ml
function lea_rax_rip(asm as struct, label as string) returns struct
```

Encode or manage lea rax rip in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `struct` | — | Value supplied for `asm`. |
| `label` | `string` | — | Value supplied for `label`. |


**Returns:** The resulting `struct` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1473)

<a id="function-function-mlc-asm-lea-rdx-rip-function-lea-rdx-rip-asm-label-mlc-asm-ml-2075327575"></a>
### lea_rdx_rip

```ml
function lea_rdx_rip(asm, label)
```

Encode or manage lea rdx rip in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1480)

<a id="function-function-mlc-asm-leave-function-leave-asm-mlc-asm-ml-1220138275"></a>
### leave

```ml
function leave(asm)
```

Encode or manage leave in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1448)

<a id="function-function-mlc-asm-lock-cmpxchg-membase-disp-r32-function-lock-cmpxchg-membase-disp-r32-asm-base-disp-src-mlc-asm-ml-2099308470"></a>
### lock_cmpxchg_membase_disp_r32

```ml
function lock_cmpxchg_membase_disp_r32(asm, base, disp, src)
```

Encode or manage lock cmpxchg membase disp r32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2386)

<a id="function-function-mlc-asm-lock-cmpxchg-membase-disp-r64-function-lock-cmpxchg-membase-disp-r64-asm-base-disp-src-mlc-asm-ml-1265994932"></a>
### lock_cmpxchg_membase_disp_r64

```ml
function lock_cmpxchg_membase_disp_r64(asm, base, disp, src)
```

Encode or manage lock cmpxchg membase disp r64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2406)

<a id="function-function-mlc-asm-mark-function-mark-asm-name-mlc-asm-ml-1003268770"></a>
### mark

```ml
function mark(asm, name)
```

Encode or manage mark in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `name` | `dynamic` | — | Name of the requested item. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1150)

<a id="function-function-mlc-asm-materialize-function-materialize-asm-mlc-asm-ml-1305979579"></a>
### materialize

```ml
function materialize(asm)
```

Encode or manage materialize in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L802)

<a id="function-function-mlc-asm-materialize-and-fold-local-patches-function-materialize-and-fold-local-patches-asm-mlc-asm-ml-1626421277"></a>
### materialize_and_fold_local_patches

```ml
function materialize_and_fold_local_patches(asm)
```

Encode or manage materialize and fold local patches in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L227)

<a id="function-function-mlc-asm-mov-eax-rip-dword-function-mov-eax-rip-dword-asm-label-mlc-asm-ml-628017397"></a>
### mov_eax_rip_dword

```ml
function mov_eax_rip_dword(asm, label)
```

Encode or manage mov eax rip dword in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2853)

<a id="function-function-mlc-asm-mov-gs-qword-28-rax-function-mov-gs-qword-28-rax-asm-mlc-asm-ml-61670697"></a>
### mov_gs_qword_28_rax

```ml
function mov_gs_qword_28_rax(asm)
```

Encode or manage mov gs qword 28 rax in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1127)

<a id="function-function-mlc-asm-mov-mem-bis-r32-function-mov-mem-bis-r32-asm-base-index-reg-scale-disp-src-mlc-asm-ml-1479592515"></a>
### mov_mem_bis_r32

```ml
function mov_mem_bis_r32(asm, base, index_reg, scale, disp, src)
```

Encode or manage mov mem bis r32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `index_reg` | `dynamic` | — | Value supplied for `index_reg`. |
| `scale` | `dynamic` | — | Value supplied for `scale`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3091)

<a id="function-function-mlc-asm-mov-mem-bis-r64-function-mov-mem-bis-r64-asm-base-index-reg-scale-disp-src-mlc-asm-ml-1183844457"></a>
### mov_mem_bis_r64

```ml
function mov_mem_bis_r64(asm, base, index_reg, scale, disp, src)
```

Encode or manage mov mem bis r64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `index_reg` | `dynamic` | — | Value supplied for `index_reg`. |
| `scale` | `dynamic` | — | Value supplied for `scale`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3049)

<a id="function-function-mlc-asm-mov-membase-disp-imm32-function-mov-membase-disp-imm32-asm-base-disp-imm-qword-mlc-asm-ml-1249385460"></a>
### mov_membase_disp_imm32

```ml
function mov_membase_disp_imm32(asm, base, disp, imm, qword)
```

Encode or manage mov membase disp imm32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |
| `qword` | `dynamic` | — | Value supplied for `qword`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2469)

<a id="function-function-mlc-asm-mov-membase-disp-imm8-function-mov-membase-disp-imm8-asm-base-disp-imm-mlc-asm-ml-1208277533"></a>
### mov_membase_disp_imm8

```ml
function mov_membase_disp_imm8(asm, base, disp, imm)
```

Encode or manage mov membase disp imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2487)

<a id="function-function-mlc-asm-mov-membase-disp-r32-function-mov-membase-disp-r32-asm-base-disp-src-mlc-asm-ml-685623958"></a>
### mov_membase_disp_r32

```ml
function mov_membase_disp_r32(asm, base, disp, src)
```

Encode or manage mov membase disp r32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2368)

<a id="function-function-mlc-asm-mov-membase-disp-r64-function-mov-membase-disp-r64-asm-base-disp-src-mlc-asm-ml-458693250"></a>
### mov_membase_disp_r64

```ml
function mov_membase_disp_r64(asm, base, disp, src)
```

Encode or manage mov membase disp r64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2332)

<a id="function-function-mlc-asm-mov-membase-disp-r8-function-mov-membase-disp-r8-asm-base-disp-src-mlc-asm-ml-1028143956"></a>
### mov_membase_disp_r8

```ml
function mov_membase_disp_r8(asm, base, disp, src)
```

Encode or manage mov membase disp r8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2448)

<a id="function-function-mlc-asm-mov-qword-ptr-rsp20-rax-zero-function-mov-qword-ptr-rsp20-rax-zero-asm-mlc-asm-ml-367685549"></a>
### mov_qword_ptr_rsp20_rax_zero

```ml
function mov_qword_ptr_rsp20_rax_zero(asm)
```

Encode or manage mov qword ptr rsp20 rax zero in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2844)

<a id="function-function-mlc-asm-mov-r10-gs-qword-28-function-mov-r10-gs-qword-28-asm-mlc-asm-ml-1215678217"></a>
### mov_r10_gs_qword_28

```ml
function mov_r10_gs_qword_28(asm)
```

Encode or manage mov r10 gs qword 28 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1119)

<a id="function-function-mlc-asm-mov-r10-rax-function-mov-r10-rax-asm-mlc-asm-ml-1449439221"></a>
### mov_r10_rax

```ml
function mov_r10_rax(asm)
```

Encode or manage mov r10 rax in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2114)

<a id="function-function-mlc-asm-mov-r11-gs-qword-28-function-mov-r11-gs-qword-28-asm-mlc-asm-ml-1509164471"></a>
### mov_r11_gs_qword_28

```ml
function mov_r11_gs_qword_28(asm)
```

Encode or manage mov r11 gs qword 28 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1111)

<a id="function-function-mlc-asm-mov-r11-rax-function-mov-r11-rax-asm-mlc-asm-ml-1397694019"></a>
### mov_r11_rax

```ml
function mov_r11_rax(asm)
```

Encode or manage mov r11 rax in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2117)

<a id="function-function-mlc-asm-mov-r32-imm32-function-mov-r32-imm32-asm-dst-imm-mlc-asm-ml-169497319"></a>
### mov_r32_imm32

```ml
function mov_r32_imm32(asm, dst, imm)
```

Encode or manage mov r32 imm32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1623)

<a id="function-function-mlc-asm-mov-r32-mem-bis-function-mov-r32-mem-bis-asm-dst-base-index-reg-scale-disp-mlc-asm-ml-1049579638"></a>
### mov_r32_mem_bis

```ml
function mov_r32_mem_bis(asm, dst, base, index_reg, scale, disp)
```

Encode or manage mov r32 mem bis in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `index_reg` | `dynamic` | — | Value supplied for `index_reg`. |
| `scale` | `dynamic` | — | Value supplied for `scale`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3070)

<a id="function-function-mlc-asm-mov-r32-membase-disp-function-mov-r32-membase-disp-asm-dst-base-disp-mlc-asm-ml-1325186121"></a>
### mov_r32_membase_disp

```ml
function mov_r32_membase_disp(asm, dst, base, disp)
```

Encode or manage mov r32 membase disp in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2350)

<a id="function-function-mlc-asm-mov-r32-r32-function-mov-r32-r32-asm-dst-src-mlc-asm-ml-1598840574"></a>
### mov_r32_r32

```ml
function mov_r32_r32(asm, dst, src)
```

Encode or manage mov r32 r32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1723)

<a id="function-function-mlc-asm-mov-r64-imm64-function-mov-r64-imm64-asm-dst-imm-mlc-asm-ml-1310864951"></a>
### mov_r64_imm64

```ml
function mov_r64_imm64(asm, dst, imm)
```

Encode or manage mov r64 imm64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1594)

<a id="function-function-mlc-asm-mov-r64-mem-bis-function-mov-r64-mem-bis-asm-dst-base-index-reg-scale-disp-mlc-asm-ml-142204508"></a>
### mov_r64_mem_bis

```ml
function mov_r64_mem_bis(asm, dst, base, index_reg, scale, disp)
```

Encode or manage mov r64 mem bis in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `index_reg` | `dynamic` | — | Value supplied for `index_reg`. |
| `scale` | `dynamic` | — | Value supplied for `scale`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3028)

<a id="function-function-mlc-asm-mov-r64-membase-disp-function-mov-r64-membase-disp-asm-dst-base-disp-mlc-asm-ml-1782241665"></a>
### mov_r64_membase_disp

```ml
function mov_r64_membase_disp(asm, dst, base, disp)
```

Encode or manage mov r64 membase disp in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2314)

<a id="function-function-mlc-asm-mov-r64-r64-function-mov-r64-r64-asm-dst-src-mlc-asm-ml-148248406"></a>
### mov_r64_r64

```ml
function mov_r64_r64(asm, dst, src)
```

Encode or manage mov r64 r64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1708)

<a id="function-function-mlc-asm-mov-r64-tagged-int-function-mov-r64-tagged-int-asm-dst-value-mlc-asm-ml-1688631105"></a>
### mov_r64_tagged_int

```ml
function mov_r64_tagged_int(asm, dst, value)
```

Encode or manage mov r64 tagged int in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `value` | `dynamic` | — | Value to process. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1646)

<a id="function-function-mlc-asm-mov-r64-u64-hi-lo-exact-function-mov-r64-u64-hi-lo-exact-asm-dst-hi32-lo32-mlc-asm-ml-1052138660"></a>
### mov_r64_u64_hi_lo_exact

```ml
function mov_r64_u64_hi_lo_exact(asm, dst, hi32, lo32)
```

Encode or manage mov r64 u64 hi lo exact in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `hi32` | `dynamic` | — | Value supplied for `hi32`. |
| `lo32` | `dynamic` | — | Value supplied for `lo32`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1671)

<a id="function-function-mlc-asm-mov-r8-membase-disp-function-mov-r8-membase-disp-asm-dst-base-disp-mlc-asm-ml-738477459"></a>
### mov_r8_membase_disp

```ml
function mov_r8_membase_disp(asm, dst, base, disp)
```

Encode or manage mov r8 membase disp in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2428)

<a id="function-function-mlc-asm-mov-r8-r8-function-mov-r8-r8-asm-dst-src-mlc-asm-ml-414949710"></a>
### mov_r8_r8

```ml
function mov_r8_r8(asm, dst, src)
```

Encode or manage mov r8 r8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1738)

<a id="function-function-mlc-asm-mov-r8d-edx-function-mov-r8d-edx-asm-mlc-asm-ml-1968024003"></a>
### mov_r8d_edx

```ml
function mov_r8d_edx(asm)
```

Encode or manage mov r8d edx in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2838)

<a id="function-function-mlc-asm-mov-r8d-imm32-function-mov-r8d-imm32-asm-imm-mlc-asm-ml-740310858"></a>
### mov_r8d_imm32

```ml
function mov_r8d_imm32(asm, imm)
```

Encode or manage mov r8d imm32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1700)

<a id="function-function-mlc-asm-mov-r9d-imm32-function-mov-r9d-imm32-asm-imm-mlc-asm-ml-1767898340"></a>
### mov_r9d_imm32

```ml
function mov_r9d_imm32(asm, imm)
```

Encode or manage mov r9d imm32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2832)

<a id="function-function-mlc-asm-mov-rax-gs-qword-28-function-mov-rax-gs-qword-28-asm-mlc-asm-ml-142508073"></a>
### mov_rax_gs_qword_28

```ml
function mov_rax_gs_qword_28(asm)
```

Encode or manage mov rax gs qword 28 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1103)

<a id="function-function-mlc-asm-mov-rax-imm64-function-mov-rax-imm64-asm-as-struct-imm-as-int-returns-struct-mlc-asm-ml-1640675460"></a>
### mov_rax_imm64

```ml
function mov_rax_imm64(asm as struct, imm as int) returns struct
```

Encode or manage mov rax imm64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `struct` | — | Value supplied for `asm`. |
| `imm` | `int` | — | Value supplied for `imm`. |


**Returns:** The resulting `struct` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1638)

<a id="function-function-mlc-asm-mov-rax-r10-function-mov-rax-r10-asm-mlc-asm-ml-1093562805"></a>
### mov_rax_r10

```ml
function mov_rax_r10(asm)
```

Encode or manage mov rax r10 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2120)

<a id="function-function-mlc-asm-mov-rax-r11-function-mov-rax-r11-asm-mlc-asm-ml-1630066275"></a>
### mov_rax_r11

```ml
function mov_rax_r11(asm)
```

Encode or manage mov rax r11 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2123)

<a id="function-function-mlc-asm-mov-rax-rip-qword-function-mov-rax-rip-qword-asm-label-mlc-asm-ml-1876247681"></a>
### mov_rax_rip_qword

```ml
function mov_rax_rip_qword(asm, label)
```

Encode or manage mov rax rip qword in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2877)

<a id="function-function-mlc-asm-mov-rax-rsp-disp32-function-mov-rax-rsp-disp32-asm-as-struct-disp-as-int-returns-struct-mlc-asm-ml-1973125325"></a>
### mov_rax_rsp_disp32

```ml
function mov_rax_rsp_disp32(asm as struct, disp as int) returns struct
```

Encode or manage mov rax rsp disp32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `struct` | — | Value supplied for `asm`. |
| `disp` | `int` | — | Value supplied for `disp`. |


**Returns:** The resulting `struct` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2534)

<a id="function-function-mlc-asm-mov-rax-rsp-disp8-function-mov-rax-rsp-disp8-asm-disp-mlc-asm-ml-49401983"></a>
### mov_rax_rsp_disp8

```ml
function mov_rax_rsp_disp8(asm, disp)
```

Encode or manage mov rax rsp disp8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2519)

<a id="function-function-mlc-asm-mov-rax-tagged-int-function-mov-rax-tagged-int-asm-as-struct-value-as-int-returns-struct-mlc-asm-ml-1077351336"></a>
### mov_rax_tagged_int

```ml
function mov_rax_tagged_int(asm as struct, value as int) returns struct
```

Encode or manage mov rax tagged int in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `struct` | — | Value supplied for `asm`. |
| `value` | `int` | — | Value to process. |


**Returns:** The resulting `struct` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1662)

<a id="function-function-mlc-asm-mov-rax-u64-hi-lo-exact-function-mov-rax-u64-hi-lo-exact-asm-hi32-lo32-mlc-asm-ml-695477375"></a>
### mov_rax_u64_hi_lo_exact

```ml
function mov_rax_u64_hi_lo_exact(asm, hi32, lo32)
```

Encode or manage mov rax u64 hi lo exact in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `hi32` | `dynamic` | — | Value supplied for `hi32`. |
| `lo32` | `dynamic` | — | Value supplied for `lo32`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1685)

<a id="function-function-mlc-asm-mov-rbp-rsp-function-mov-rbp-rsp-asm-mlc-asm-ml-1836418983"></a>
### mov_rbp_rsp

```ml
function mov_rbp_rsp(asm)
```

Encode or manage mov rbp rsp in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1586)

<a id="function-function-mlc-asm-mov-rbx-rax-function-mov-rbx-rax-asm-mlc-asm-ml-1330816591"></a>
### mov_rbx_rax

```ml
function mov_rbx_rax(asm)
```

Encode or manage mov rbx rax in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2105)

<a id="function-function-mlc-asm-mov-rcx-imm32-function-mov-rcx-imm32-asm-as-struct-imm-as-int-returns-struct-mlc-asm-ml-414152510"></a>
### mov_rcx_imm32

```ml
function mov_rcx_imm32(asm as struct, imm as int) returns struct
```

Encode or manage mov rcx imm32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `struct` | — | Value supplied for `asm`. |
| `imm` | `int` | — | Value supplied for `imm`. |


**Returns:** The resulting `struct` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1693)

<a id="function-function-mlc-asm-mov-rcx-rbx-function-mov-rcx-rbx-asm-mlc-asm-ml-1629593247"></a>
### mov_rcx_rbx

```ml
function mov_rcx_rbx(asm)
```

Encode or manage mov rcx rbx in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2108)

<a id="function-function-mlc-asm-mov-rdx-rax-function-mov-rdx-rax-asm-mlc-asm-ml-1191991607"></a>
### mov_rdx_rax

```ml
function mov_rdx_rax(asm)
```

Encode or manage mov rdx rax in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2111)

<a id="function-function-mlc-asm-mov-rdx-rip-qword-function-mov-rdx-rip-qword-asm-label-mlc-asm-ml-141231447"></a>
### mov_rdx_rip_qword

```ml
function mov_rdx_rip_qword(asm, label)
```

Encode or manage mov rdx rip qword in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2898)

<a id="function-function-mlc-asm-mov-rip-dword-eax-function-mov-rip-dword-eax-asm-label-mlc-asm-ml-641073653"></a>
### mov_rip_dword_eax

```ml
function mov_rip_dword_eax(asm, label)
```

Encode or manage mov rip dword eax in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2865)

<a id="function-function-mlc-asm-mov-rip-qword-r11-function-mov-rip-qword-r11-asm-label-mlc-asm-ml-457063355"></a>
### mov_rip_qword_r11

```ml
function mov_rip_qword_r11(asm, label)
```

Encode or manage mov rip qword r11 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2961)

<a id="function-function-mlc-asm-mov-rip-qword-r8-function-mov-rip-qword-r8-asm-label-mlc-asm-ml-381099973"></a>
### mov_rip_qword_r8

```ml
function mov_rip_qword_r8(asm, label)
```

Encode or manage mov rip qword r8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2982)

<a id="function-function-mlc-asm-mov-rip-qword-r9-function-mov-rip-qword-r9-asm-label-mlc-asm-ml-1250695393"></a>
### mov_rip_qword_r9

```ml
function mov_rip_qword_r9(asm, label)
```

Encode or manage mov rip qword r9 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3003)

<a id="function-function-mlc-asm-mov-rip-qword-rax-function-mov-rip-qword-rax-asm-label-mlc-asm-ml-52223953"></a>
### mov_rip_qword_rax

```ml
function mov_rip_qword_rax(asm, label)
```

Encode or manage mov rip qword rax in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2919)

<a id="function-function-mlc-asm-mov-rip-qword-rdx-function-mov-rip-qword-rdx-asm-label-mlc-asm-ml-148857199"></a>
### mov_rip_qword_rdx

```ml
function mov_rip_qword_rdx(asm, label)
```

Encode or manage mov rip qword rdx in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `label` | `dynamic` | — | Value supplied for `label`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2940)

<a id="function-function-mlc-asm-mov-rsp-disp32-rax-function-mov-rsp-disp32-rax-asm-as-struct-disp-as-int-returns-struct-mlc-asm-ml-1597720757"></a>
### mov_rsp_disp32_rax

```ml
function mov_rsp_disp32_rax(asm as struct, disp as int) returns struct
```

Encode or manage mov rsp disp32 rax in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `struct` | — | Value supplied for `asm`. |
| `disp` | `int` | — | Value supplied for `disp`. |


**Returns:** The resulting `struct` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2542)

<a id="function-function-mlc-asm-mov-rsp-disp8-rax-function-mov-rsp-disp8-rax-asm-disp-mlc-asm-ml-1247760079"></a>
### mov_rsp_disp8_rax

```ml
function mov_rsp_disp8_rax(asm, disp)
```

Encode or manage mov rsp disp8 rax in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2526)

<a id="function-function-mlc-asm-movapd-xmm-xmm-function-movapd-xmm-xmm-asm-dst-xmm-src-xmm-mlc-asm-ml-979594844"></a>
### movapd_xmm_xmm

```ml
function movapd_xmm_xmm(asm, dst_xmm, src_xmm)
```

Encode or manage movapd xmm xmm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst_xmm` | `dynamic` | — | Value supplied for `dst_xmm`. |
| `src_xmm` | `dynamic` | — | Value supplied for `src_xmm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3367)

<a id="function-function-mlc-asm-movd-r32-xmm-function-movd-r32-xmm-asm-dst-src-mlc-asm-ml-1735264306"></a>
### movd_r32_xmm

```ml
function movd_r32_xmm(asm, dst, src)
```

Encode or manage movd r32 xmm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3495)

<a id="function-function-mlc-asm-movdqu-membase-disp-xmm-function-movdqu-membase-disp-xmm-asm-base-disp-src-mlc-asm-ml-560316024"></a>
### movdqu_membase_disp_xmm

```ml
function movdqu_membase_disp_xmm(asm, base, disp, src)
```

Encode or manage movdqu membase disp xmm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3531)

<a id="function-function-mlc-asm-movdqu-xmm-membase-disp-function-movdqu-xmm-membase-disp-asm-dst-base-disp-mlc-asm-ml-1044452691"></a>
### movdqu_xmm_membase_disp

```ml
function movdqu_xmm_membase_disp(asm, dst, base, disp)
```

Encode or manage movdqu xmm membase disp in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3513)

<a id="function-function-mlc-asm-movq-r64-xmm-function-movq-r64-xmm-asm-dst-reg-src-xmm-mlc-asm-ml-1852506596"></a>
### movq_r64_xmm

```ml
function movq_r64_xmm(asm, dst_reg, src_xmm)
```

Restore one tagged 64-bit value from the low qword of an XMM register.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst_reg` | `dynamic` | — | Value supplied for `dst_reg`. |
| `src_xmm` | `dynamic` | — | Value supplied for `src_xmm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3479)

<a id="function-function-mlc-asm-movq-xmm-r64-function-movq-xmm-r64-asm-dst-xmm-src-reg-mlc-asm-ml-360973076"></a>
### movq_xmm_r64

```ml
function movq_xmm_r64(asm, dst_xmm, src_reg)
```

Move one tagged 64-bit value into the low qword of an XMM register.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst_xmm` | `dynamic` | — | Value supplied for `dst_xmm`. |
| `src_reg` | `dynamic` | — | Value supplied for `src_reg`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3463)

<a id="function-function-mlc-asm-movsd-membase-disp-xmm-function-movsd-membase-disp-xmm-asm-base-disp-src-xmm-mlc-asm-ml-1171982343"></a>
### movsd_membase_disp_xmm

```ml
function movsd_membase_disp_xmm(asm, base, disp, src_xmm)
```

Encode or manage movsd membase disp xmm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |
| `src_xmm` | `dynamic` | — | Value supplied for `src_xmm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3395)

<a id="function-function-mlc-asm-movsd-xmm-membase-disp-function-movsd-xmm-membase-disp-asm-dst-xmm-base-disp-mlc-asm-ml-536705176"></a>
### movsd_xmm_membase_disp

```ml
function movsd_xmm_membase_disp(asm, dst_xmm, base, disp)
```

Encode or manage movsd xmm membase disp in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst_xmm` | `dynamic` | — | Value supplied for `dst_xmm`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3377)

<a id="function-function-mlc-asm-movsd-xmm-xmm-function-movsd-xmm-xmm-asm-dst-xmm-src-xmm-mlc-asm-ml-510813534"></a>
### movsd_xmm_xmm

```ml
function movsd_xmm_xmm(asm, dst_xmm, src_xmm)
```

Encode or manage movsd xmm xmm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst_xmm` | `dynamic` | — | Value supplied for `dst_xmm`. |
| `src_xmm` | `dynamic` | — | Value supplied for `src_xmm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3309)

<a id="function-function-mlc-asm-movzx-eax-al-function-movzx-eax-al-asm-as-struct-returns-struct-mlc-asm-ml-1256030034"></a>
### movzx_eax_al

```ml
function movzx_eax_al(asm as struct) returns struct
```

Encode or manage movzx eax al in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `struct` | — | Value supplied for `asm`. |


**Returns:** The resulting `struct` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2099)

<a id="function-function-mlc-asm-movzx-r32-membase-disp-function-movzx-r32-membase-disp-asm-dst32-base-disp-mlc-asm-ml-1997771456"></a>
### movzx_r32_membase_disp

```ml
function movzx_r32_membase_disp(asm, dst32, base, disp)
```

Encode or manage movzx r32 membase disp in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst32` | `dynamic` | — | Value supplied for `dst32`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2661)

<a id="function-function-mlc-asm-movzx-r32-r8-function-movzx-r32-r8-asm-dst-src8-mlc-asm-ml-1686395618"></a>
### movzx_r32_r8

```ml
function movzx_r32_r8(asm, dst, src8)
```

Encode or manage movzx r32 r8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src8` | `dynamic` | — | Value supplied for `src8`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2084)

<a id="function-function-mlc-asm-mulsd-xmm-xmm-function-mulsd-xmm-xmm-asm-dst-xmm-src-xmm-mlc-asm-ml-1083944914"></a>
### mulsd_xmm_xmm

```ml
function mulsd_xmm_xmm(asm, dst_xmm, src_xmm)
```

Encode or manage mulsd xmm xmm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst_xmm` | `dynamic` | — | Value supplied for `dst_xmm`. |
| `src_xmm` | `dynamic` | — | Value supplied for `src_xmm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3333)

<a id="function-function-mlc-asm-neg-r64-function-neg-r64-asm-reg-name-mlc-asm-ml-2043155571"></a>
### neg_r64

```ml
function neg_r64(asm, reg_name)
```

Encode or manage neg r64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2209)

<a id="function-function-mlc-asm-neg-rax-function-neg-rax-asm-mlc-asm-ml-1373429613"></a>
### neg_rax

```ml
function neg_rax(asm)
```

Encode or manage neg rax in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2220)

<a id="function-function-mlc-asm-newasmbuilder-function-newasmbuilder-mlc-asm-ml-1431619198"></a>
### newAsmBuilder

```ml
function newAsmBuilder()
```

Create an empty assembler with production-sized page and index capacities.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L154)

<a id="function-function-mlc-asm-newcodegenasmbuilder-function-newcodegenasmbuilder-mlc-asm-ml-938104422"></a>
### newCodegenAsmBuilder

```ml
function newCodegenAsmBuilder()
```

Code generation discovers runtime helpers separately and never consumes the complete call history. Avoid retaining one string for every emitted call in large monolithic builds while preserving call recording for assembler users.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L162)

<a id="function-function-mlc-asm-nop-function-nop-asm-mlc-asm-ml-2087544563"></a>
### nop

```ml
function nop(asm)
```

Encode or manage nop in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1234)

<a id="function-function-mlc-asm-or-r32-imm-function-or-r32-imm-asm-reg-name-imm-mlc-asm-ml-2119945822"></a>
### or_r32_imm

```ml
function or_r32_imm(asm, reg_name, imm)
```

Encode or manage or r32 imm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1903)

<a id="function-function-mlc-asm-or-r32-r32-function-or-r32-r32-asm-dst-src-mlc-asm-ml-524216550"></a>
### or_r32_r32

```ml
function or_r32_r32(asm, dst, src)
```

Encode or manage or r32 r32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1991)

<a id="function-function-mlc-asm-or-r64-imm-function-or-r64-imm-asm-reg-name-imm-mlc-asm-ml-482312102"></a>
### or_r64_imm

```ml
function or_r64_imm(asm, reg_name, imm)
```

Encode or manage or r64 imm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1818)

<a id="function-function-mlc-asm-or-r64-imm8-function-or-r64-imm8-asm-as-struct-reg-name-as-string-imm-as-int-returns-struct-mlc-asm-ml-1883212291"></a>
### or_r64_imm8

```ml
function or_r64_imm8(asm as struct, reg_name as string, imm as int) returns struct
```

Encode or manage or r64 imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `struct` | — | Value supplied for `asm`. |
| `reg_name` | `string` | — | Value supplied for `reg_name`. |
| `imm` | `int` | — | Value supplied for `imm`. |


**Returns:** The resulting `struct` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1865)

<a id="function-function-mlc-asm-or-r64-r64-function-or-r64-r64-asm-dst-src-mlc-asm-ml-1307837550"></a>
### or_r64_r64

```ml
function or_r64_r64(asm, dst, src)
```

Encode or manage or r64 r64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1986)

<a id="function-function-mlc-asm-or-r8-imm8-function-or-r8-imm8-asm-reg8-imm-mlc-asm-ml-306939044"></a>
### or_r8_imm8

```ml
function or_r8_imm8(asm, reg8, imm)
```

Encode or manage or r8 imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg8` | `dynamic` | — | Value supplied for `reg8`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2573)

<a id="function-function-mlc-asm-or-r8-r8-function-or-r8-r8-asm-dst-src-mlc-asm-ml-1924097734"></a>
### or_r8_r8

```ml
function or_r8_r8(asm, dst, src)
```

Encode or manage or r8 r8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2001)

<a id="function-function-mlc-asm-or-rax-imm8-function-or-rax-imm8-asm-imm-mlc-asm-ml-1120167116"></a>
### or_rax_imm8

```ml
function or_rax_imm8(asm, imm)
```

Encode or manage or rax imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2146)

<a id="function-function-mlc-asm-pcmpeqb-xmm-xmm-function-pcmpeqb-xmm-xmm-asm-dst-src-mlc-asm-ml-2108371974"></a>
### pcmpeqb_xmm_xmm

```ml
function pcmpeqb_xmm_xmm(asm, dst, src)
```

Encode or manage pcmpeqb xmm xmm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3556)

<a id="function-function-mlc-asm-pcmpeqw-xmm-xmm-function-pcmpeqw-xmm-xmm-asm-dst-src-mlc-asm-ml-1576300584"></a>
### pcmpeqw_xmm_xmm

```ml
function pcmpeqw_xmm_xmm(asm, dst, src)
```

Encode or manage pcmpeqw xmm xmm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3564)

<a id="function-function-mlc-asm-pmovmskb-r32-xmm-function-pmovmskb-r32-xmm-asm-dst32-src-mlc-asm-ml-619996841"></a>
### pmovmskb_r32_xmm

```ml
function pmovmskb_r32_xmm(asm, dst32, src)
```

Encode or manage pmovmskb r32 xmm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst32` | `dynamic` | — | Value supplied for `dst32`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3572)

<a id="function-function-mlc-asm-pop-r12-function-pop-r12-asm-mlc-asm-ml-1042614159"></a>
### pop_r12

```ml
function pop_r12(asm)
```

Encode or manage pop r12 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1558)

<a id="function-function-mlc-asm-pop-r13-function-pop-r13-asm-mlc-asm-ml-1838337293"></a>
### pop_r13

```ml
function pop_r13(asm)
```

Encode or manage pop r13 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1564)

<a id="function-function-mlc-asm-pop-r14-function-pop-r14-asm-mlc-asm-ml-358460295"></a>
### pop_r14

```ml
function pop_r14(asm)
```

Encode or manage pop r14 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1570)

<a id="function-function-mlc-asm-pop-r15-function-pop-r15-asm-mlc-asm-ml-2094100481"></a>
### pop_r15

```ml
function pop_r15(asm)
```

Encode or manage pop r15 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1576)

<a id="function-function-mlc-asm-pop-rbp-function-pop-rbp-asm-mlc-asm-ml-422139573"></a>
### pop_rbp

```ml
function pop_rbp(asm)
```

Encode or manage pop rbp in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1582)

<a id="function-function-mlc-asm-pop-rbx-function-pop-rbx-asm-mlc-asm-ml-1671558325"></a>
### pop_rbx

```ml
function pop_rbx(asm)
```

Encode or manage pop rbx in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1552)

<a id="function-function-mlc-asm-pop-reg-function-pop-reg-asm-reg-mlc-asm-ml-1393436341"></a>
### pop_reg

```ml
function pop_reg(asm, reg)
```

Encode or manage pop reg in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg` | `dynamic` | — | Value supplied for `reg`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1524)

<a id="function-function-mlc-asm-pos-function-pos-asm-as-struct-returns-int-mlc-asm-ml-1706267734"></a>
### pos

```ml
function pos(asm as struct) returns int
```

Encode or manage pos in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `struct` | — | Value supplied for `asm`. |


**Returns:** The resulting `int` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L872)

<a id="function-function-mlc-asm-punpcklqdq-xmm-xmm-function-punpcklqdq-xmm-xmm-asm-dst-src-mlc-asm-ml-1607809610"></a>
### punpcklqdq_xmm_xmm

```ml
function punpcklqdq_xmm_xmm(asm, dst, src)
```

Encode or manage punpcklqdq xmm xmm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3589)

<a id="function-function-mlc-asm-push-r12-function-push-r12-asm-mlc-asm-ml-46261877"></a>
### push_r12

```ml
function push_r12(asm)
```

Updates push r12.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1555)

<a id="function-function-mlc-asm-push-r13-function-push-r13-asm-mlc-asm-ml-633460721"></a>
### push_r13

```ml
function push_r13(asm)
```

Updates push r13.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1561)

<a id="function-function-mlc-asm-push-r14-function-push-r14-asm-mlc-asm-ml-482627021"></a>
### push_r14

```ml
function push_r14(asm)
```

Updates push r14.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1567)

<a id="function-function-mlc-asm-push-r15-function-push-r15-asm-mlc-asm-ml-705463233"></a>
### push_r15

```ml
function push_r15(asm)
```

Updates push r15.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1573)

<a id="function-function-mlc-asm-push-rbp-function-push-rbp-asm-mlc-asm-ml-1777877629"></a>
### push_rbp

```ml
function push_rbp(asm)
```

Updates push rbp.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1579)

<a id="function-function-mlc-asm-push-rbx-function-push-rbx-asm-mlc-asm-ml-659445613"></a>
### push_rbx

```ml
function push_rbx(asm)
```

Updates push rbx.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1549)

<a id="function-function-mlc-asm-push-reg-function-push-reg-asm-reg-mlc-asm-ml-717522433"></a>
### push_reg

```ml
function push_reg(asm, reg)
```

Updates push reg.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg` | `dynamic` | — | Value supplied for `reg`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1508)

<a id="function-function-mlc-asm-pxor-xmm-xmm-function-pxor-xmm-xmm-asm-dst-src-mlc-asm-ml-699906910"></a>
### pxor_xmm_xmm

```ml
function pxor_xmm_xmm(asm, dst, src)
```

Encode or manage pxor xmm xmm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3548)

<a id="function-function-mlc-asm-rep-movsb-function-rep-movsb-asm-mlc-asm-ml-1261806823"></a>
### rep_movsb

```ml
function rep_movsb(asm)
```

Encode or manage rep movsb in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3233)

<a id="function-function-mlc-asm-rep-movsq-function-rep-movsq-asm-mlc-asm-ml-1056503325"></a>
### rep_movsq

```ml
function rep_movsq(asm)
```

Encode or manage rep movsq in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3241)

<a id="function-function-mlc-asm-rep-stosb-function-rep-stosb-asm-mlc-asm-ml-1069603535"></a>
### rep_stosb

```ml
function rep_stosb(asm)
```

Encode or manage rep stosb in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3250)

<a id="function-function-mlc-asm-rep-stosq-function-rep-stosq-asm-mlc-asm-ml-2133024377"></a>
### rep_stosq

```ml
function rep_stosq(asm)
```

Encode or manage rep stosq in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3258)

<a id="function-function-mlc-asm-repe-cmpsb-function-repe-cmpsb-asm-mlc-asm-ml-1180550533"></a>
### repe_cmpsb

```ml
function repe_cmpsb(asm)
```

Encode or manage repe cmpsb in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3267)

<a id="function-function-mlc-asm-resolve-all-defined-patches-function-resolve-all-defined-patches-asm-mlc-asm-ml-714751327"></a>
### resolve_all_defined_patches

```ml
function resolve_all_defined_patches(asm)
```

Encode or manage resolve all defined patches in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L296)

<a id="function-function-mlc-asm-resolve-defined-patches-function-resolve-defined-patches-asm-mlc-asm-ml-480973383"></a>
### resolve_defined_patches

```ml
function resolve_defined_patches(asm)
```

Encode or manage resolve defined patches in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L280)

<a id="function-function-mlc-asm-ret-function-ret-asm-mlc-asm-ml-346769639"></a>
### ret

```ml
function ret(asm)
```

Encode or manage ret in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1442)

<a id="function-function-mlc-asm-roundsd-xmm-xmm-imm8-function-roundsd-xmm-xmm-imm8-asm-dst-xmm-src-xmm-imm8-mlc-asm-ml-583451099"></a>
### roundsd_xmm_xmm_imm8

```ml
function roundsd_xmm_xmm_imm8(asm, dst_xmm, src_xmm, imm8)
```

Encode or manage roundsd xmm xmm imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst_xmm` | `dynamic` | — | Value supplied for `dst_xmm`. |
| `src_xmm` | `dynamic` | — | Value supplied for `src_xmm`. |
| `imm8` | `dynamic` | — | Value supplied for `imm8`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3445)

<a id="function-function-mlc-asm-sar-r32-imm8-function-sar-r32-imm8-asm-reg-name-imm-mlc-asm-ml-847216226"></a>
### sar_r32_imm8

```ml
function sar_r32_imm8(asm, reg_name, imm)
```

Encode or manage sar r32 imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2190)

<a id="function-function-mlc-asm-sar-r64-cl-function-sar-r64-cl-asm-reg-name-mlc-asm-ml-938518801"></a>
### sar_r64_cl

```ml
function sar_r64_cl(asm, reg_name)
```

Encode or manage sar r64 cl in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3153)

<a id="function-function-mlc-asm-sar-r64-imm8-function-sar-r64-imm8-asm-reg-name-imm-mlc-asm-ml-998880162"></a>
### sar_r64_imm8

```ml
function sar_r64_imm8(asm, reg_name, imm)
```

Encode or manage sar r64 imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2180)

<a id="function-function-mlc-asm-sar-rax-imm8-function-sar-rax-imm8-asm-imm-mlc-asm-ml-1716300758"></a>
### sar_rax_imm8

```ml
function sar_rax_imm8(asm, imm)
```

Encode or manage sar rax imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2200)

<a id="function-function-mlc-asm-setcc-al-function-setcc-al-asm-as-struct-cc-as-string-returns-struct-mlc-asm-ml-492450819"></a>
### setcc_al

```ml
function setcc_al(asm as struct, cc as string) returns struct
```

Updates setcc al.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `struct` | — | Value supplied for `asm`. |
| `cc` | `string` | — | Value supplied for `cc`. |


**Returns:** The resulting `struct` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2076)

<a id="function-function-mlc-asm-setcc-r8-function-setcc-r8-asm-cc-dst8-mlc-asm-ml-1154957978"></a>
### setcc_r8

```ml
function setcc_r8(asm, cc, dst8)
```

Updates setcc r8.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `cc` | `dynamic` | — | Value supplied for `cc`. |
| `dst8` | `dynamic` | — | Value supplied for `dst8`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2043)

<a id="function-function-mlc-asm-shl-r32-imm8-function-shl-r32-imm8-asm-reg-name-imm-mlc-asm-ml-647376018"></a>
### shl_r32_imm8

```ml
function shl_r32_imm8(asm, reg_name, imm)
```

Encode or manage shl r32 imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2185)

<a id="function-function-mlc-asm-shl-r64-cl-function-shl-r64-cl-asm-reg-name-mlc-asm-ml-114711749"></a>
### shl_r64_cl

```ml
function shl_r64_cl(asm, reg_name)
```

Encode or manage shl r64 cl in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3129)

<a id="function-function-mlc-asm-shl-r64-imm8-function-shl-r64-imm8-asm-reg-name-imm-mlc-asm-ml-1909873058"></a>
### shl_r64_imm8

```ml
function shl_r64_imm8(asm, reg_name, imm)
```

Encode or manage shl r64 imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2170)

<a id="function-function-mlc-asm-shl-rax-imm8-function-shl-rax-imm8-asm-imm-mlc-asm-ml-417650282"></a>
### shl_rax_imm8

```ml
function shl_rax_imm8(asm, imm)
```

Encode or manage shl rax imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2204)

<a id="function-function-mlc-asm-shr-r32-imm8-function-shr-r32-imm8-asm-reg-name-imm-mlc-asm-ml-753174902"></a>
### shr_r32_imm8

```ml
function shr_r32_imm8(asm, reg_name, imm)
```

Encode or manage shr r32 imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2195)

<a id="function-function-mlc-asm-shr-r64-cl-function-shr-r64-cl-asm-reg-name-mlc-asm-ml-2076990297"></a>
### shr_r64_cl

```ml
function shr_r64_cl(asm, reg_name)
```

Encode or manage shr r64 cl in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3141)

<a id="function-function-mlc-asm-shr-r64-imm8-function-shr-r64-imm8-asm-reg-name-imm-mlc-asm-ml-2146344306"></a>
### shr_r64_imm8

```ml
function shr_r64_imm8(asm, reg_name, imm)
```

Encode or manage shr r64 imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2175)

<a id="function-function-mlc-asm-sub-r32-imm-function-sub-r32-imm-asm-reg-name-imm-mlc-asm-ml-523102558"></a>
### sub_r32_imm

```ml
function sub_r32_imm(asm, reg_name, imm)
```

Encode or manage sub r32 imm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1893)

<a id="function-function-mlc-asm-sub-r32-r32-function-sub-r32-r32-asm-dst-src-mlc-asm-ml-1020021374"></a>
### sub_r32_r32

```ml
function sub_r32_r32(asm, dst, src)
```

Encode or manage sub r32 r32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1961)

<a id="function-function-mlc-asm-sub-r64-imm-function-sub-r64-imm-asm-reg-name-imm-mlc-asm-ml-488582696"></a>
### sub_r64_imm

```ml
function sub_r64_imm(asm, reg_name, imm)
```

Encode or manage sub r64 imm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1808)

<a id="function-function-mlc-asm-sub-r64-imm8-function-sub-r64-imm8-asm-reg-name-imm-mlc-asm-ml-2039558970"></a>
### sub_r64_imm8

```ml
function sub_r64_imm8(asm, reg_name, imm)
```

Encode or manage sub r64 imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1849)

<a id="function-function-mlc-asm-sub-r64-r64-function-sub-r64-r64-asm-dst-src-mlc-asm-ml-1393772758"></a>
### sub_r64_r64

```ml
function sub_r64_r64(asm, dst, src)
```

Encode or manage sub r64 r64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1951)

<a id="function-function-mlc-asm-sub-r8-imm8-function-sub-r8-imm8-asm-reg8-imm-mlc-asm-ml-2002575582"></a>
### sub_r8_imm8

```ml
function sub_r8_imm8(asm, reg8, imm)
```

Encode or manage sub r8 imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg8` | `dynamic` | — | Value supplied for `reg8`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2588)

<a id="function-function-mlc-asm-sub-rax-imm8-function-sub-rax-imm8-asm-imm-mlc-asm-ml-1877733982"></a>
### sub_rax_imm8

```ml
function sub_rax_imm8(asm, imm)
```

Encode or manage sub rax imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2138)

<a id="function-function-mlc-asm-sub-rax-r11-function-sub-rax-r11-asm-mlc-asm-ml-2138846559"></a>
### sub_rax_r11

```ml
function sub_rax_r11(asm)
```

Encode or manage sub rax r11 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2130)

<a id="function-function-mlc-asm-sub-rsp-imm32-function-sub-rsp-imm32-asm-imm-mlc-asm-ml-1228510736"></a>
### sub_rsp_imm32

```ml
function sub_rsp_imm32(asm, imm)
```

Encode or manage sub rsp imm32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2298)

<a id="function-function-mlc-asm-sub-rsp-imm8-function-sub-rsp-imm8-asm-imm-mlc-asm-ml-542282190"></a>
### sub_rsp_imm8

```ml
function sub_rsp_imm8(asm, imm)
```

Encode or manage sub rsp imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2282)

<a id="function-function-mlc-asm-subsd-xmm-xmm-function-subsd-xmm-xmm-asm-dst-xmm-src-xmm-mlc-asm-ml-1553390274"></a>
### subsd_xmm_xmm

```ml
function subsd_xmm_xmm(asm, dst_xmm, src_xmm)
```

Encode or manage subsd xmm xmm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst_xmm` | `dynamic` | — | Value supplied for `dst_xmm`. |
| `src_xmm` | `dynamic` | — | Value supplied for `src_xmm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3325)

<a id="function-function-mlc-asm-test-r32-r32-function-test-r32-r32-asm-left-right-mlc-asm-ml-1179640542"></a>
### test_r32_r32

```ml
function test_r32_r32(asm, left, right)
```

Encode or manage test r32 r32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `left` | `dynamic` | — | Left input value. |
| `right` | `dynamic` | — | Right input value. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2022)

<a id="function-function-mlc-asm-test-r64-imm32-function-test-r64-imm32-asm-reg-name-imm-mlc-asm-ml-1887492770"></a>
### test_r64_imm32

```ml
function test_r64_imm32(asm, reg_name, imm)
```

Encode or manage test r64 imm32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2605)

<a id="function-function-mlc-asm-test-r64-r64-function-test-r64-r64-asm-left-right-mlc-asm-ml-1283886030"></a>
### test_r64_r64

```ml
function test_r64_r64(asm, left, right)
```

Encode or manage test r64 r64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `left` | `dynamic` | — | Left input value. |
| `right` | `dynamic` | — | Right input value. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2017)

<a id="function-function-mlc-asm-test-r8-r8-function-test-r8-r8-asm-left-right-mlc-asm-ml-1004369990"></a>
### test_r8_r8

```ml
function test_r8_r8(asm, left, right)
```

Encode or manage test r8 r8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `left` | `dynamic` | — | Left input value. |
| `right` | `dynamic` | — | Right input value. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2028)

<a id="function-function-mlc-asm-test-rax-imm32-function-test-rax-imm32-asm-imm-mlc-asm-ml-616207034"></a>
### test_rax_imm32

```ml
function test_rax_imm32(asm, imm)
```

Encode or manage test rax imm32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2248)

<a id="function-function-mlc-asm-ucomisd-xmm-xmm-function-ucomisd-xmm-xmm-asm-as-struct-left-xmm-as-string-right-xmm-as-string-returns-struct-mlc-asm-ml-1513138393"></a>
### ucomisd_xmm_xmm

```ml
function ucomisd_xmm_xmm(asm as struct, left_xmm as string, right_xmm as string) returns struct
```

Encode or manage ucomisd xmm xmm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `struct` | — | Value supplied for `asm`. |
| `left_xmm` | `string` | — | Value supplied for `left_xmm`. |
| `right_xmm` | `string` | — | Value supplied for `right_xmm`. |


**Returns:** The resulting `struct` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3350)

<a id="function-function-mlc-asm-vmovdqu-membase-disp-ymm-function-vmovdqu-membase-disp-ymm-asm-base-disp-src-mlc-asm-ml-1709641806"></a>
### vmovdqu_membase_disp_ymm

```ml
function vmovdqu_membase_disp_ymm(asm, base, disp, src)
```

Encode or manage vmovdqu membase disp ymm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3646)

<a id="function-function-mlc-asm-vmovdqu-ymm-membase-disp-function-vmovdqu-ymm-membase-disp-asm-dst-base-disp-mlc-asm-ml-1163881377"></a>
### vmovdqu_ymm_membase_disp

```ml
function vmovdqu_ymm_membase_disp(asm, dst, base, disp)
```

Encode or manage vmovdqu ymm membase disp in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `base` | `dynamic` | — | Value supplied for `base`. |
| `disp` | `dynamic` | — | Value supplied for `disp`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3630)

<a id="function-function-mlc-asm-vpcmpeqb-ymm-ymm-ymm-function-vpcmpeqb-ymm-ymm-ymm-asm-dst-src1-src2-mlc-asm-ml-144417041"></a>
### vpcmpeqb_ymm_ymm_ymm

```ml
function vpcmpeqb_ymm_ymm_ymm(asm, dst, src1, src2)
```

Encode or manage vpcmpeqb ymm ymm ymm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src1` | `dynamic` | — | Value supplied for `src1`. |
| `src2` | `dynamic` | — | Value supplied for `src2`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3662)

<a id="function-function-mlc-asm-vpcmpeqw-ymm-ymm-ymm-function-vpcmpeqw-ymm-ymm-ymm-asm-dst-src1-src2-mlc-asm-ml-191103173"></a>
### vpcmpeqw_ymm_ymm_ymm

```ml
function vpcmpeqw_ymm_ymm_ymm(asm, dst, src1, src2)
```

Encode or manage vpcmpeqw ymm ymm ymm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src1` | `dynamic` | — | Value supplied for `src1`. |
| `src2` | `dynamic` | — | Value supplied for `src2`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3678)

<a id="function-function-mlc-asm-vpmovmskb-r32-ymm-function-vpmovmskb-r32-ymm-asm-dst32-src-mlc-asm-ml-643392095"></a>
### vpmovmskb_r32_ymm

```ml
function vpmovmskb_r32_ymm(asm, dst32, src)
```

Encode or manage vpmovmskb r32 ymm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst32` | `dynamic` | — | Value supplied for `dst32`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3693)

<a id="function-function-mlc-asm-vpxor-ymm-ymm-ymm-function-vpxor-ymm-ymm-ymm-asm-dst-src1-src2-mlc-asm-ml-173507307"></a>
### vpxor_ymm_ymm_ymm

```ml
function vpxor_ymm_ymm_ymm(asm, dst, src1, src2)
```

Encode or manage vpxor ymm ymm ymm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src1` | `dynamic` | — | Value supplied for `src1`. |
| `src2` | `dynamic` | — | Value supplied for `src2`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3709)

<a id="function-function-mlc-asm-vzeroupper-function-vzeroupper-asm-mlc-asm-ml-1059775613"></a>
### vzeroupper

```ml
function vzeroupper(asm)
```

Encode or manage vzeroupper in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3722)

<a id="function-function-mlc-asm-write-listing-function-write-listing-asm-path-mlc-asm-ml-1316893246"></a>
### write_listing

```ml
function write_listing(asm, path)
```

Updates write listing.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `path` | `dynamic` | — | Path to operate on. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3827)

<a id="function-function-mlc-asm-xgetbv-function-xgetbv-asm-mlc-asm-ml-2016278405"></a>
### xgetbv

```ml
function xgetbv(asm)
```

Encode or manage xgetbv in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3283)

<a id="function-function-mlc-asm-xor-eax-eax-function-xor-eax-eax-asm-mlc-asm-ml-1366683683"></a>
### xor_eax_eax

```ml
function xor_eax_eax(asm)
```

Encode or manage xor eax eax in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2261)

<a id="function-function-mlc-asm-xor-ecx-ecx-function-xor-ecx-ecx-asm-mlc-asm-ml-1641165587"></a>
### xor_ecx_ecx

```ml
function xor_ecx_ecx(asm)
```

Encode or manage xor ecx ecx in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2255)

<a id="function-function-mlc-asm-xor-r32-imm-function-xor-r32-imm-asm-reg-name-imm-mlc-asm-ml-264693208"></a>
### xor_r32_imm

```ml
function xor_r32_imm(asm, reg_name, imm)
```

Encode or manage xor r32 imm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1908)

<a id="function-function-mlc-asm-xor-r32-r32-function-xor-r32-r32-asm-dst-src-mlc-asm-ml-166464732"></a>
### xor_r32_r32

```ml
function xor_r32_r32(asm, dst, src)
```

Encode or manage xor r32 r32 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1971)

<a id="function-function-mlc-asm-xor-r64-imm-function-xor-r64-imm-asm-reg-name-imm-mlc-asm-ml-753519682"></a>
### xor_r64_imm

```ml
function xor_r64_imm(asm, reg_name, imm)
```

Encode or manage xor r64 imm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1823)

<a id="function-function-mlc-asm-xor-r64-imm8-function-xor-r64-imm8-asm-reg-name-imm-mlc-asm-ml-246689566"></a>
### xor_r64_imm8

```ml
function xor_r64_imm8(asm, reg_name, imm)
```

Encode or manage xor r64 imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg_name` | `dynamic` | — | Value supplied for `reg_name`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1872)

<a id="function-function-mlc-asm-xor-r64-r64-function-xor-r64-r64-asm-dst-src-mlc-asm-ml-2140562780"></a>
### xor_r64_r64

```ml
function xor_r64_r64(asm, dst, src)
```

Encode or manage xor r64 r64 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `dst` | `dynamic` | — | Value supplied for `dst`. |
| `src` | `dynamic` | — | Value supplied for `src`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L1966)

<a id="function-function-mlc-asm-xor-r8-imm8-function-xor-r8-imm8-asm-reg8-imm-mlc-asm-ml-1404167300"></a>
### xor_r8_imm8

```ml
function xor_r8_imm8(asm, reg8, imm)
```

Encode or manage xor r8 imm8 in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `dynamic` | — | Value supplied for `asm`. |
| `reg8` | `dynamic` | — | Value supplied for `reg8`. |
| `imm` | `dynamic` | — | Value supplied for `imm`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L2578)

<a id="function-function-mlc-asm-xorpd-xmm-xmm-function-xorpd-xmm-xmm-asm-as-struct-dst-xmm-as-string-src-xmm-as-string-returns-struct-mlc-asm-ml-681801965"></a>
### xorpd_xmm_xmm

```ml
function xorpd_xmm_xmm(asm as struct, dst_xmm as string, src_xmm as string) returns struct
```

Encode or manage xorpd xmm xmm in the native x64 assembler.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `asm` | `struct` | — | Value supplied for `asm`. |
| `dst_xmm` | `string` | — | Value supplied for `dst_xmm`. |
| `src_xmm` | `string` | — | Value supplied for `src_xmm`. |


**Returns:** The resulting `struct` value.

[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L3359)
