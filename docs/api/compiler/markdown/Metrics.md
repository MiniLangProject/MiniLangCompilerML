# Metrics

[Home](README.md)

Static metrics are calculated from target-specific preprocessed MiniLang files inside the configured source roots. External imported modules, generated documentation, and excluded paths are not measured.

## Project summary

| Metric | Value |
| --- | ---: |
| Blank lines | 4987 |
| Clone groups | 1122 |
| Cognitive complexity | 21442 (maximum per function: 523) |
| Comment lines | 6932 |
| Cyclomatic complexity | 14567 (average: 8.27, maximum: 197) |
| Documentation coverage | 100% (3221 of 3221 documentation items) |
| Duplicated lines | 6036 (12.51%) |
| Files | 25 |
| Functions | 1762 |
| Maintainability index | 0.27 / 100 |
| Physical lines | 60150 |
| Source lines | 48236 |
| Statements | 42508 |

## Documentation coverage

Coverage is split by documentation contract so strong API summaries cannot hide undocumented parameters or data members.

| Category | Documented | Total | Coverage |
| --- | ---: | ---: | ---: |
| API declarations | 830 | 830 | 100% |
| Constants | 158 | 158 | 100% |
| Enum variants | 0 | 0 | 100% |
| Fields | 756 | 756 | 100% |
| Globals | 78 | 78 | 100% |
| Overall | 3221 | 3221 | 100% |
| Parameters | 1399 | 1399 | 100% |

## Halstead metrics

| Distinct operators | Distinct operands | Total operators | Total operands | Vocabulary | Length | Volume | Difficulty | Effort | Estimated defects |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 55 | 9484 | 255132 | 207394 | 9539 | 462526 | 6114419.03 | 601.36 | 3676990728.48 | 2038.14 |

## Files

| File | SLOC | Functions | Cyclomatic total / avg / max | Cognitive total / max | Duplication | Halstead volume | MI |
| --- | ---: | ---: | --- | --- | --- | ---: | ---: |
| [`mlc/__init__.ml`](File-mlc-init-ml-1795718751.md) | 2 | 0 | 0 / 0. / 0 | 0 / 0 | 0 (0%) | 24 | 83.77 |
| [`mlc/asm.ml`](File-mlc-asm-ml-1368648960.md) | 2411 | 320 | 888 / 2.78 / 49 | 673 / 48 | 313 (12.98%) | 201631.76 | 0 |
| [`mlc/codegen/__init__.ml`](File-mlc-codegen-init-ml-1019260381.md) | 2 | 0 | 0 / 0. / 0 | 0 / 0 | 0 (0%) | 31.7 | 82.92 |
| [`mlc/codegen/codegen.ml`](File-mlc-codegen-codegen-ml-1154886880.md) | 435 | 38 | 124 / 3.26 / 11 | 99 / 12 | 6 (1.38%) | 28742.83 | 0 |
| [`mlc/codegen/codegen_builtins_alloc.ml`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md) | 2515 | 34 | 83 / 2.44 / 18 | 102 / 41 | 579 (23.02%) | 332953.18 | 0 |
| [`mlc/codegen/codegen_core.ml`](File-mlc-codegen-codegen-core-ml-528695596.md) | 1682 | 86 | 655 / 7.62 / 113 | 727 / 112 | 158 (9.39%) | 137088.95 | 0 |
| [`mlc/codegen/codegen_expr.ml`](File-mlc-codegen-codegen-expr-ml-59843844.md) | 8860 | 132 | 2563 / 19.42 / 197 | 4327 / 523 | 1173 (13.24%) | 1068451.13 | 0 |
| [`mlc/codegen/codegen_memory.ml`](File-mlc-codegen-codegen-memory-ml-2136639668.md) | 1821 | 32 | 144 / 4.5 / 18 | 125 / 21 | 314 (17.24%) | 214774.6 | 0 |
| [`mlc/codegen/codegen_runtime.ml`](File-mlc-codegen-codegen-runtime-ml-1845689217.md) | 3346 | 60 | 122 / 2.03 / 37 | 135 / 102 | 656 (19.61%) | 454486.84 | 0 |
| [`mlc/codegen/codegen_scope.ml`](File-mlc-codegen-codegen-scope-ml-1124416197.md) | 1470 | 69 | 660 / 9.57 / 53 | 814 / 73 | 250 (17.01%) | 108626.96 | 0 |
| [`mlc/codegen/codegen_stmt.ml`](File-mlc-codegen-codegen-stmt-ml-1158291323.md) | 9278 | 260 | 3713 / 14.28 / 167 | 6445 / 417 | 1047 (11.28%) | 925360.05 | 0 |
| [`mlc/codegen/codegen_threads.ml`](File-mlc-codegen-codegen-threads-ml-1261658982.md) | 1070 | 33 | 64 / 1.94 / 10 | 34 / 9 | 165 (15.42%) | 117841.91 | 0 |
| [`mlc/compiler.ml`](File-mlc-compiler-ml-344018962.md) | 6578 | 249 | 2452 / 9.85 / 179 | 3768 / 322 | 716 (10.88%) | 549148.54 | 0 |
| [`mlc/constants.ml`](File-mlc-constants-ml-1024884042.md) | 50 | 0 | 0 / 0. / 0 | 0 / 0 | 0 (0%) | 1324.03 | 41.08 |
| [`mlc/context.ml`](File-mlc-context-ml-1162383972.md) | 35 | 3 | 9 / 3 / 7 | 6 / 6 | 0 (0%) | 927.48 | 44.33 |
| [`mlc/data.ml`](File-mlc-data-ml-557434521.md) | 639 | 58 | 249 / 4.29 / 24 | 255 / 46 | 74 (11.58%) | 40586.07 | 0 |
| [`mlc/elf.ml`](File-mlc-elf-ml-1082822254.md) | 174 | 8 | 42 / 5.25 / 21 | 55 / 39 | 7 (4.02%) | 12549.74 | 16.78 |
| [`mlc/errors.ml`](File-mlc-errors-ml-1747911852.md) | 25 | 3 | 3 / 1 / 1 | 0 / 0 | 0 (0%) | 425.21 | 50.7 |
| [`mlc/frontend.ml`](File-mlc-frontend-ml-1929241497.md) | 186 | 9 | 62 / 6.89 / 37 | 79 / 62 | 18 (9.68%) | 7936.71 | 14.85 |
| [`mlc/linux_runtime.ml`](File-mlc-linux-runtime-ml-1485387394.md) | 396 | 11 | 68 / 6.18 / 31 | 112 / 71 | 7 (1.77%) | 36448.71 | 2.25 |
| [`mlc/minilang_parser.ml`](File-mlc-minilang-parser-ml-1485036712.md) | 4572 | 180 | 1610 / 8.94 / 93 | 2472 / 161 | 410 (8.97%) | 351174.33 | 0 |
| [`mlc/pe.ml`](File-mlc-pe-ml-319201864.md) | 394 | 15 | 82 / 5.47 / 22 | 123 / 47 | 6 (1.52%) | 22450.99 | 1.89 |
| [`mlc/project.ml`](File-mlc-project-ml-1332928426.md) | 736 | 43 | 378 / 8.79 / 54 | 483 / 95 | 7 (0.95%) | 57821.19 | 0 |
| [`mlc/tools.ml`](File-mlc-tools-ml-988451276.md) | 1552 | 117 | 594 / 5.08 / 24 | 608 / 40 | 130 (8.38%) | 99359.94 | 0 |
| [`mlc_win64.ml`](File-mlc-win64-ml-1630996773.md) | 7 | 2 | 2 / 1 / 1 | 0 / 0 | 0 (0%) | 121.84 | 66.69 |

## Functions

| Function | Location | LOC | Statements | Cyclomatic | Cognitive | Max nesting | Halstead volume | MI |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| [`main`](File-mlc-win64-ml-1630996773.md#function-function-main-function-main-args-mlc-win64-ml-1802758867) | `mlc_win64.ml:29` | 3 | 1 | 1 | 0 | 0 | 36 | 78.56 |
| [`mlc.asm._alloc_zero_bytes_keepalive`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-alloc-zero-bytes-keepalive-function-alloc-zero-bytes-keepalive-keepalive-size-mlc-asm-ml-1846823705) | `mlc/asm.ml:147` | 3 | 1 | 1 | 0 | 0 | 55.35 | 77.25 |
| [`mlc.asm._array_contains_text`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-array-contains-text-function-array-contains-text-arr-value-mlc-asm-ml-1782568426) | `mlc/asm.ml:131` | 7 | 6 | 5 | 5 | 2 | 267.19 | 63.9 |
| [`mlc.asm._byte_at`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-byte-at-function-byte-at-asm-idx-mlc-asm-ml-1250101900) | `mlc/asm.ml:481` | 31 | 25 | 24 | 41 | 5 | 1714.96 | 41.59 |
| [`mlc.asm._call_push`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-call-push-function-call-push-asm-label-mlc-asm-ml-613941761) | `mlc/asm.ml:357` | 6 | 4 | 1 | 0 | 0 | 197.65 | 66.82 |
| [`mlc.asm._chunk_count`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-chunk-count-function-chunk-count-asm-mlc-asm-ml-1851627509) | `mlc/asm.ml:567` | 6 | 5 | 2 | 1 | 1 | 229.25 | 66.23 |
| [`mlc.asm._chunk_get`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-chunk-get-function-chunk-get-asm-idx-mlc-asm-ml-1612250432) | `mlc/asm.ml:576` | 27 | 19 | 15 | 18 | 3 | 1276.9 | 45.01 |
| [`mlc.asm._chunk_push`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-chunk-push-function-chunk-push-asm-chunk-mlc-asm-ml-606385708) | `mlc/asm.ml:624` | 6 | 4 | 1 | 0 | 0 | 197.65 | 66.82 |
| [`mlc.asm._chunk_set`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-chunk-set-function-chunk-set-asm-idx-chunk-mlc-asm-ml-1543979153) | `mlc/asm.ml:606` | 15 | 12 | 2 | 1 | 1 | 503.66 | 55.16 |
| [`mlc.asm._drop_last_patch`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-drop-last-patch-function-drop-last-patch-asm-mlc-asm-ml-1532661093) | `mlc/asm.ml:552` | 12 | 9 | 4 | 3 | 1 | 348.29 | 58.12 |
| [`mlc.asm._emit`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-emit-function-emit-asm-b-mlc-asm-ml-1930020033) | `mlc/asm.ml:749` | 25 | 23 | 6 | 7 | 2 | 925.59 | 47.93 |
| [`mlc.asm._emit32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-emit32-function-emit32-asm-x-mlc-asm-ml-1113740717) | `mlc/asm.ml:806` | 22 | 19 | 2 | 1 | 1 | 937.57 | 49.64 |
| [`mlc.asm._emit64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-emit64-function-emit64-asm-x-mlc-asm-ml-1860428419) | `mlc/asm.ml:840` | 26 | 22 | 3 | 2 | 1 | 1191.41 | 47.19 |
| [`mlc.asm._emit8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-emit8-function-emit8-asm-x-mlc-asm-ml-1284744155) | `mlc/asm.ml:777` | 20 | 16 | 5 | 4 | 1 | 617.34 | 51.41 |
| [`mlc.asm._emit_bin_rr`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-emit-bin-rr-function-emit-bin-rr-asm-op-dst-src-w-mlc-asm-ml-1848370970) | `mlc/asm.ml:1889` | 9 | 8 | 3 | 2 | 1 | 461.25 | 60.13 |
| [`mlc.asm._emit_bytes_u8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-emit-bytes-u8-function-emit-bytes-u8-v-mlc-asm-ml-1443579904) | `mlc/asm.ml:911` | 5 | 3 | 1 | 0 | 0 | 102.19 | 70.55 |
| [`mlc.asm._emit_modrm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-emit-modrm-function-emit-modrm-asm-mod-reg-rm-mlc-asm-ml-1252926862) | `mlc/asm.ml:886` | 4 | 2 | 1 | 0 | 0 | 203.13 | 70.57 |
| [`mlc.asm._emit_rex`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-emit-rex-function-emit-rex-asm-w-r-x-b-force-mlc-asm-ml-1575744541) | `mlc/asm.ml:876` | 7 | 4 | 3 | 2 | 1 | 408.07 | 62.88 |
| [`mlc.asm._emit_shift_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-emit-shift-imm8-function-emit-shift-imm8-asm-subop-reg-name-imm-w-mlc-asm-ml-2024202764) | `mlc/asm.ml:2107` | 9 | 8 | 2 | 1 | 1 | 408.07 | 60.63 |
| [`mlc.asm._emit_sse_rr`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-emit-sse-rr-function-emit-sse-rr-asm-prefix1-prefix2-opcode-dst-xmm-src-xmm-mlc-asm-ml-877527765) | `mlc/asm.ml:3237` | 12 | 13 | 5 | 4 | 1 | 675.95 | 55.97 |
| [`mlc.asm._encode_mem`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-encode-mem-function-encode-mem-reg-field-base-id-disp-mlc-asm-ml-809964036) | `mlc/asm.ml:919` | 35 | 28 | 9 | 9 | 2 | 1066.48 | 43.91 |
| [`mlc.asm._encode_mem_bis`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-encode-mem-bis-function-encode-mem-bis-reg-field-base-id-index-id-scale-disp-mlc-asm-ml-25078216) | `mlc/asm.ml:971` | 32 | 26 | 9 | 9 | 2 | 1044.11 | 44.82 |
| [`mlc.asm._ensure_capacity`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-ensure-capacity-function-ensure-capacity-asm-need-mlc-asm-ml-710290421) | `mlc/asm.ml:662` | 17 | 18 | 10 | 9 | 1 | 803.09 | 51.47 |
| [`mlc.asm._fits_i8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-fits-i8-function-fits-i8-x-as-int-returns-bool-mlc-asm-ml-581218552) | `mlc/asm.ml:905` | 3 | 1 | 1 | 0 | 0 | 81.75 | 76.07 |
| [`mlc.asm._fmt_disp`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-fmt-disp-function-fmt-disp-disp-mlc-asm-ml-615676156) | `mlc/asm.ml:3747` | 3 | 1 | 1 | 0 | 0 | 27 | 79.44 |
| [`mlc.asm._fmt_mem`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-fmt-mem-function-fmt-mem-base-disp-mlc-asm-ml-455923723) | `mlc/asm.ml:3753` | 3 | 1 | 1 | 0 | 0 | 36.54 | 78.52 |
| [`mlc.asm._fmt_mem_sib`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-fmt-mem-sib-function-fmt-mem-sib-base-index-reg-scale-disp-mlc-asm-ml-1478242070) | `mlc/asm.ml:3759` | 3 | 1 | 1 | 0 | 0 | 53.77 | 77.34 |
| [`mlc.asm._fold_materialized_patch_set`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-fold-materialized-patch-set-function-fold-materialized-patch-set-asm-patch-chunks-patch-tail-out-b-mlc-asm-ml-337632046) | `mlc/asm.ml:187` | 35 | 29 | 18 | 46 | 7 | 2005.5 | 40.77 |
| [`mlc.asm._format_call`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-format-call-function-format-call-name-args-kwargs-mlc-asm-ml-1522458895) | `mlc/asm.ml:3765` | 3 | 1 | 1 | 0 | 0 | 44.97 | 77.88 |
| [`mlc.asm._gc_tmp_context_offset`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-gc-tmp-context-offset-function-gc-tmp-context-offset-label-mlc-asm-ml-492348028) | `mlc/asm.ml:1133` | 11 | 17 | 9 | 8 | 1 | 394.2 | 57.9 |
| [`mlc.asm._grp1_imm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-grp1-imm-function-grp1-imm-asm-size-subop-rm-imm-mlc-asm-ml-1131576307) | `mlc/asm.ml:1723` | 32 | 28 | 9 | 10 | 2 | 1139.86 | 44.55 |
| [`mlc.asm._grp1_r8_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-grp1-r8-imm8-function-grp1-r8-imm8-asm-subop-reg8-imm-mlc-asm-ml-817252349) | `mlc/asm.ml:2503` | 10 | 9 | 2 | 1 | 1 | 427.5 | 59.5 |
| [`mlc.asm._is_force_rex_8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-is-force-rex-8-function-is-force-rex-8-name-as-string-returns-bool-mlc-asm-ml-1735187869) | `mlc/asm.ml:475` | 3 | 1 | 1 | 0 | 0 | 110.36 | 75.15 |
| [`mlc.asm._is_r32_name`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-is-r32-name-function-is-r32-name-name-as-string-returns-bool-mlc-asm-ml-809474229) | `mlc/asm.ml:469` | 3 | 1 | 1 | 0 | 0 | 364.35 | 71.52 |
| [`mlc.asm._is_r8_name`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-is-r8-name-function-is-r8-name-name-as-string-returns-bool-mlc-asm-ml-790496333) | `mlc/asm.ml:463` | 3 | 1 | 1 | 0 | 0 | 364.35 | 71.52 |
| [`mlc.asm._jcc_mnemonic`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-jcc-mnemonic-function-jcc-mnemonic-cc-mlc-asm-ml-1301070904) | `mlc/asm.ml:3741` | 3 | 1 | 1 | 0 | 0 | 25.27 | 79.64 |
| [`mlc.asm._keepalive_barrier`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-keepalive-barrier-function-keepalive-barrier-value-mlc-asm-ml-59488951) | `mlc/asm.ml:141` | 3 | 1 | 1 | 0 | 0 | 25.27 | 79.64 |
| [`mlc.asm._label_index`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-label-index-function-label-index-labels-name-mlc-asm-ml-22519306) | `mlc/asm.ml:423` | 7 | 6 | 4 | 4 | 2 | 238.42 | 64.38 |
| [`mlc.asm._label_pos`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-label-pos-function-label-pos-labels-name-mlc-asm-ml-1728841002) | `mlc/asm.ml:433` | 5 | 4 | 2 | 1 | 1 | 151.62 | 69.21 |
| [`mlc.asm._label_push`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-label-push-function-label-push-asm-label-mlc-asm-ml-566373889) | `mlc/asm.ml:414` | 6 | 4 | 1 | 0 | 0 | 197.65 | 66.82 |
| [`mlc.asm._last_patch`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-last-patch-function-last-patch-asm-mlc-asm-ml-1493029077) | `mlc/asm.ml:544` | 5 | 4 | 2 | 1 | 1 | 180.09 | 68.69 |
| [`mlc.asm._materialize_buffer`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-materialize-buffer-function-materialize-buffer-asm-mlc-asm-ml-1600056139) | `mlc/asm.ml:698` | 45 | 42 | 11 | 12 | 2 | 1523.07 | 40.17 |
| [`mlc.asm._modrm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-modrm-function-modrm-mod-reg-rm-mlc-asm-ml-786224505) | `mlc/asm.ml:3729` | 3 | 1 | 1 | 0 | 0 | 82.45 | 76.04 |
| [`mlc.asm._modrm_byte`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-modrm-byte-function-modrm-byte-mod-as-int-reg-as-int-rm-as-int-returns-int-mlc-asm-ml-51179326) | `mlc/asm.ml:893` | 3 | 1 | 1 | 0 | 0 | 191.16 | 73.48 |
| [`mlc.asm._patch_push`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-patch-push-function-patch-push-asm-patch-mlc-asm-ml-1045153109) | `mlc/asm.ml:348` | 6 | 4 | 1 | 0 | 0 | 197.65 | 66.82 |
| [`mlc.asm._patches_replace`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-patches-replace-function-patches-replace-asm-patches-mlc-asm-ml-1863022165) | `mlc/asm.ml:515` | 11 | 9 | 3 | 2 | 1 | 348.39 | 59.08 |
| [`mlc.asm._peephole_trim_tail`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-peephole-trim-tail-function-peephole-trim-tail-asm-n-mlc-asm-ml-1495235887) | `mlc/asm.ml:3676` | 8 | 8 | 5 | 4 | 1 | 329.71 | 62 |
| [`mlc.asm._remove_patch_at`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-remove-patch-at-function-remove-patch-at-asm-idx-mlc-asm-ml-2107070144) | `mlc/asm.ml:529` | 12 | 10 | 6 | 6 | 2 | 420 | 57.28 |
| [`mlc.asm._resolve_patch_set`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-resolve-patch-set-function-resolve-patch-set-asm-patch-chunks-patch-tail-kept-chunks-kept-tail-mlc-asm-ml-1415396307) | `mlc/asm.ml:243` | 32 | 27 | 12 | 20 | 4 | 1750.53 | 42.84 |
| [`mlc.asm._restore_materialized_chunks`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-restore-materialized-chunks-function-restore-materialized-chunks-asm-mlc-asm-ml-1366154781) | `mlc/asm.ml:633` | 25 | 28 | 12 | 12 | 2 | 1197.02 | 46.34 |
| [`mlc.asm._rex`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-rex-function-rex-w-r-x-b-force-mlc-asm-ml-1532133820) | `mlc/asm.ml:3720` | 6 | 3 | 3 | 2 | 1 | 380.39 | 64.56 |
| [`mlc.asm._rid_any`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-rid-any-function-rid-any-name-mlc-asm-ml-1601508049) | `mlc/asm.ml:441` | 19 | 33 | 49 | 48 | 1 | 1761.92 | 42.79 |
| [`mlc.asm._scale_bits`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-scale-bits-function-scale-bits-scale-mlc-asm-ml-1350604720) | `mlc/asm.ml:961` | 7 | 9 | 5 | 4 | 1 | 224.74 | 64.43 |
| [`mlc.asm._set_chunk_byte`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-set-chunk-byte-function-set-chunk-byte-asm-idx-value-mlc-asm-ml-58383037) | `mlc/asm.ml:685` | 10 | 8 | 1 | 0 | 0 | 307.67 | 60.63 |
| [`mlc.asm._sib`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-sib-function-sib-scale-index-base-mlc-asm-ml-719836301) | `mlc/asm.ml:3735` | 3 | 1 | 1 | 0 | 0 | 82.45 | 76.04 |
| [`mlc.asm._sib_byte`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-sib-byte-function-sib-byte-scale-as-int-index-as-int-base-as-int-returns-int-mlc-asm-ml-133039292) | `mlc/asm.ml:899` | 3 | 1 | 1 | 0 | 0 | 191.16 | 73.48 |
| [`mlc.asm._spill_before_call`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-spill-before-call-function-spill-before-call-asm-mlc-asm-ml-495611853) | `mlc/asm.ml:398` | 13 | 14 | 9 | 11 | 2 | 653.62 | 54.78 |
| [`mlc.asm._starts_with_text`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-starts-with-text-function-starts-with-text-text-prefix-mlc-asm-ml-634186839) | `mlc/asm.ml:118` | 10 | 12 | 7 | 7 | 2 | 432.66 | 58.79 |
| [`mlc.asm._track_helper_label`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-track-helper-label-function-track-helper-label-asm-label-mlc-asm-ml-656463849) | `mlc/asm.ml:366` | 25 | 25 | 14 | 19 | 4 | 1294.22 | 45.83 |
| [`mlc.asm._vex3`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-vex3-function-vex3-m-w-vvvv-l-pp-r-x-b-mlc-asm-ml-1694335052) | `mlc/asm.ml:1009` | 17 | 16 | 5 | 4 | 1 | 856.73 | 51.95 |
| [`mlc.asm._xmm_id`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-xmm-id-function-xmm-id-name-mlc-asm-ml-1056018291) | `mlc/asm.ml:1029` | 19 | 33 | 17 | 16 | 1 | 835.64 | 49.36 |
| [`mlc.asm._ymm_id`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-ymm-id-function-ymm-id-name-mlc-asm-ml-446720225) | `mlc/asm.ml:1051` | 19 | 33 | 17 | 16 | 1 | 835.64 | 49.36 |
| [`mlc.asm.add_patch`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-add-patch-function-add-patch-asm-position-label-kind-mlc-asm-ml-1666246762) | `mlc/asm.ml:834` | 3 | 1 | 1 | 0 | 0 | 99.91 | 75.46 |
| [`mlc.asm.add_r32_imm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-add-r32-imm-function-add-r32-imm-asm-reg-name-imm-mlc-asm-ml-1236754780) | `mlc/asm.ml:1845` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.add_r32_r32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-add-r32-r32-function-add-r32-r32-asm-dst-src-mlc-asm-ml-441334020) | `mlc/asm.ml:1913` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.add_r64_imm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-add-r64-imm-function-add-r64-imm-asm-reg-name-imm-mlc-asm-ml-526115370) | `mlc/asm.ml:1760` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.add_r64_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-add-r64-imm8-function-add-r64-imm8-asm-reg-name-imm-mlc-asm-ml-1865708626) | `mlc/asm.ml:1796` | 3 | 1 | 1 | 0 | 0 | 69.19 | 76.57 |
| [`mlc.asm.add_r64_r64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-add-r64-r64-function-add-r64-r64-asm-dst-src-mlc-asm-ml-606237132) | `mlc/asm.ml:1903` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.add_r8_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-add-r8-imm8-function-add-r8-imm8-asm-reg8-imm-mlc-asm-ml-1379506176) | `mlc/asm.ml:2533` | 1 | 1 | 1 | 0 | 0 | 78.87 | 86.58 |
| [`mlc.asm.add_rax_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-add-rax-imm8-function-add-rax-imm8-asm-imm-mlc-asm-ml-1294979934) | `mlc/asm.ml:2091` | 1 | 1 | 1 | 0 | 0 | 62.27 | 87.3 |
| [`mlc.asm.add_rax_r10`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-add-rax-r10-function-add-rax-r10-asm-mlc-asm-ml-1577336883) | `mlc/asm.ml:2084` | 1 | 1 | 1 | 0 | 0 | 55.35 | 87.66 |
| [`mlc.asm.add_rcx_imm32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-add-rcx-imm32-function-add-rcx-imm32-asm-imm-mlc-asm-ml-936260126) | `mlc/asm.ml:2230` | 3 | 1 | 1 | 0 | 0 | 62.27 | 76.89 |
| [`mlc.asm.add_rcx_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-add-rcx-imm8-function-add-rcx-imm8-asm-imm-mlc-asm-ml-1756460366) | `mlc/asm.ml:2223` | 3 | 1 | 1 | 0 | 0 | 62.27 | 76.89 |
| [`mlc.asm.add_rsp_imm32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-add-rsp-imm32-function-add-rsp-imm32-asm-imm-mlc-asm-ml-1850344526) | `mlc/asm.ml:2260` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.asm.add_rsp_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-add-rsp-imm8-function-add-rsp-imm8-asm-imm-mlc-asm-ml-2144943166) | `mlc/asm.ml:2245` | 4 | 3 | 2 | 1 | 1 | 105.49 | 72.43 |
| [`mlc.asm.addsd_xmm_xmm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-addsd-xmm-xmm-function-addsd-xmm-xmm-asm-dst-xmm-src-xmm-mlc-asm-ml-579743080) | `mlc/asm.ml:3262` | 3 | 1 | 1 | 0 | 0 | 105.49 | 75.29 |
| [`mlc.asm.and_r32_imm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-and-r32-imm-function-and-r32-imm-asm-reg-name-imm-mlc-asm-ml-1221207828) | `mlc/asm.ml:1855` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.and_r32_r32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-and-r32-r32-function-and-r32-r32-asm-dst-src-mlc-asm-ml-458899852) | `mlc/asm.ml:1938` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.and_r64_imm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-and-r64-imm-function-and-r64-imm-asm-reg-name-imm-mlc-asm-ml-292145406) | `mlc/asm.ml:1770` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.and_r64_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-and-r64-imm8-function-and-r64-imm8-asm-as-struct-reg-name-as-string-imm-as-int-returns-struct-mlc-asm-ml-221705171) | `mlc/asm.ml:1814` | 3 | 1 | 1 | 0 | 0 | 112 | 75.11 |
| [`mlc.asm.and_r64_r64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-and-r64-r64-function-and-r64-r64-asm-dst-src-mlc-asm-ml-1545923012) | `mlc/asm.ml:1933` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.and_r8_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-and-r8-imm8-function-and-r8-imm8-asm-reg8-imm-mlc-asm-ml-852967172) | `mlc/asm.ml:2518` | 1 | 1 | 1 | 0 | 0 | 78.87 | 86.58 |
| [`mlc.asm.and_r8_r8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-and-r8-r8-function-and-r8-r8-asm-dst-src-mlc-asm-ml-1341814340) | `mlc/asm.ml:1953` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.and_rax_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-and-rax-imm8-function-and-rax-imm8-asm-imm-mlc-asm-ml-363316942) | `mlc/asm.ml:2099` | 1 | 1 | 1 | 0 | 0 | 62.27 | 87.3 |
| [`mlc.asm.bsf_r32_r32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-bsf-r32-r32-function-bsf-r32-r32-asm-dst32-src32-mlc-asm-ml-1189041242) | `mlc/asm.ml:2625` | 14 | 15 | 5 | 4 | 1 | 635.9 | 54.7 |
| [`mlc.asm.bsr_r32_r32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-bsr-r32-r32-function-bsr-r32-r32-asm-dst32-src32-mlc-asm-ml-869848634) | `mlc/asm.ml:2644` | 14 | 15 | 5 | 4 | 1 | 635.9 | 54.7 |
| [`mlc.asm.call`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-call-function-call-asm-label-mlc-asm-ml-332714073) | `mlc/asm.ml:1360` | 12 | 10 | 3 | 3 | 2 | 422.64 | 57.67 |
| [`mlc.asm.call_membase_disp`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-call-membase-disp-function-call-membase-disp-asm-base-disp-mlc-asm-ml-677240064) | `mlc/asm.ml:1386` | 10 | 9 | 2 | 1 | 1 | 402.36 | 59.68 |
| [`mlc.asm.call_rax`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-call-rax-function-call-rax-asm-mlc-asm-ml-1240620053) | `mlc/asm.ml:1375` | 6 | 4 | 1 | 0 | 0 | 114.71 | 68.47 |
| [`mlc.asm.call_rip_qword`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-call-rip-qword-function-call-rip-qword-asm-label-mlc-asm-ml-1481692961) | `mlc/asm.ml:1400` | 9 | 7 | 1 | 0 | 0 | 272.32 | 62 |
| [`mlc.asm.clear_calls`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-clear-calls-function-clear-calls-asm-mlc-asm-ml-319950115) | `mlc/asm.ml:326` | 5 | 3 | 1 | 0 | 0 | 77.71 | 71.38 |
| [`mlc.asm.clear_tracked_helpers`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-clear-tracked-helpers-function-clear-tracked-helpers-asm-mlc-asm-ml-805444525) | `mlc/asm.ml:334` | 5 | 3 | 1 | 0 | 0 | 100 | 70.61 |
| [`mlc.asm.cmp_membase_disp_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-cmp-membase-disp-imm8-function-cmp-membase-disp-imm8-asm-base-disp-imm-mlc-asm-ml-492106309) | `mlc/asm.ml:2590` | 10 | 9 | 2 | 1 | 1 | 421.99 | 59.53 |
| [`mlc.asm.cmp_r32_imm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-cmp-r32-imm-function-cmp-r32-imm-asm-reg-name-imm-mlc-asm-ml-45694778) | `mlc/asm.ml:1870` | 6 | 3 | 2 | 1 | 1 | 166.8 | 67.2 |
| [`mlc.asm.cmp_r32_imm32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-cmp-r32-imm32-function-cmp-r32-imm32-asm-reg-name-imm-mlc-asm-ml-1636248900) | `mlc/asm.ml:1880` | 1 | 1 | 1 | 0 | 0 | 69.19 | 86.98 |
| [`mlc.asm.cmp_r32_r32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-cmp-r32-r32-function-cmp-r32-r32-asm-left-right-mlc-asm-ml-211470546) | `mlc/asm.ml:1969` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.cmp_r64_imm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-cmp-r64-imm-function-cmp-r64-imm-asm-reg-name-imm-mlc-asm-ml-1783015044) | `mlc/asm.ml:1785` | 6 | 3 | 2 | 1 | 1 | 166.8 | 67.2 |
| [`mlc.asm.cmp_r64_imm32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-cmp-r64-imm32-function-cmp-r64-imm32-asm-reg-name-imm-mlc-asm-ml-1486450838) | `mlc/asm.ml:1885` | 1 | 1 | 1 | 0 | 0 | 69.19 | 86.98 |
| [`mlc.asm.cmp_r64_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-cmp-r64-imm8-function-cmp-r64-imm8-asm-as-struct-reg-name-as-string-imm-as-int-returns-struct-mlc-asm-ml-1127591647) | `mlc/asm.ml:1837` | 3 | 1 | 1 | 0 | 0 | 112 | 75.11 |
| [`mlc.asm.cmp_r64_r64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-cmp-r64-r64-function-cmp-r64-r64-asm-left-right-mlc-asm-ml-502250) | `mlc/asm.ml:1964` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.cmp_r8_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-cmp-r8-imm8-function-cmp-r8-imm8-asm-reg8-imm-mlc-asm-ml-921352058) | `mlc/asm.ml:2544` | 6 | 3 | 2 | 1 | 1 | 155.32 | 67.41 |
| [`mlc.asm.cmp_r8_membase_disp`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-cmp-r8-membase-disp-function-cmp-r8-membase-disp-asm-reg8-base-disp-mlc-asm-ml-1368943660) | `mlc/asm.ml:2570` | 14 | 15 | 5 | 4 | 1 | 683.71 | 54.48 |
| [`mlc.asm.cmp_rax_imm32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-cmp-rax-imm32-function-cmp-rax-imm32-asm-imm-mlc-asm-ml-819904964) | `mlc/asm.ml:2192` | 3 | 1 | 1 | 0 | 0 | 62.27 | 76.89 |
| [`mlc.asm.cmp_rax_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-cmp-rax-imm8-function-cmp-rax-imm8-asm-as-struct-imm-as-int-returns-struct-mlc-asm-ml-1064240996) | `mlc/asm.ml:2185` | 3 | 1 | 1 | 0 | 0 | 93.77 | 75.65 |
| [`mlc.asm.cmp_rax_r10`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-cmp-rax-r10-function-cmp-rax-r10-asm-mlc-asm-ml-478965601) | `mlc/asm.ml:2177` | 3 | 1 | 1 | 0 | 0 | 55.35 | 77.25 |
| [`mlc.asm.cpuid`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-cpuid-function-cpuid-asm-mlc-asm-ml-960815007) | `mlc/asm.ml:3220` | 5 | 3 | 1 | 0 | 0 | 89.62 | 70.95 |
| [`mlc.asm.cqo`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-cqo-function-cqo-asm-mlc-asm-ml-246911879) | `mlc/asm.ml:3146` | 5 | 3 | 1 | 0 | 0 | 128.93 | 69.84 |
| [`mlc.asm.crc32_r32_membase_disp8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-crc32-r32-membase-disp8-function-crc32-r32-membase-disp8-asm-dst32-base-disp-mlc-asm-ml-719330366) | `mlc/asm.ml:2683` | 14 | 14 | 4 | 3 | 1 | 743.4 | 54.36 |
| [`mlc.asm.crc32_r64_membase_disp`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-crc32-r64-membase-disp-function-crc32-r64-membase-disp-asm-dst64-base-disp-mlc-asm-ml-1760457167) | `mlc/asm.ml:2664` | 13 | 12 | 3 | 2 | 1 | 634.25 | 55.68 |
| [`mlc.asm.cvtsd2ss_xmm_xmm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-cvtsd2ss-xmm-xmm-function-cvtsd2ss-xmm-xmm-asm-dst-src-mlc-asm-ml-302972442) | `mlc/asm.ml:3542` | 11 | 10 | 3 | 2 | 1 | 525.14 | 57.83 |
| [`mlc.asm.cvtsi2sd_xmm_r64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-cvtsi2sd-xmm-r64-function-cvtsi2sd-xmm-r64-asm-dst-xmm-src-reg-mlc-asm-ml-1035364584) | `mlc/asm.ml:3357` | 11 | 10 | 3 | 2 | 1 | 530 | 57.8 |
| [`mlc.asm.cvtss2sd_xmm_xmm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-cvtss2sd-xmm-xmm-function-cvtss2sd-xmm-xmm-asm-dst-src-mlc-asm-ml-977744022) | `mlc/asm.ml:3558` | 11 | 10 | 3 | 2 | 1 | 525.14 | 57.83 |
| [`mlc.asm.cvttsd2si_r64_xmm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-cvttsd2si-r64-xmm-function-cvttsd2si-r64-xmm-asm-dst-reg-src-xmm-mlc-asm-ml-1942516160) | `mlc/asm.ml:3373` | 11 | 10 | 3 | 2 | 1 | 530 | 57.8 |
| [`mlc.asm.dec_membase_disp_qword`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-dec-membase-disp-qword-function-dec-membase-disp-qword-asm-base-disp-mlc-asm-ml-1642462268) | `mlc/asm.ml:2764` | 9 | 8 | 2 | 1 | 1 | 369.21 | 60.94 |
| [`mlc.asm.dec_r32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-dec-r32-function-dec-r32-asm-reg-name-mlc-asm-ml-1829827573) | `mlc/asm.ml:2737` | 8 | 7 | 2 | 1 | 1 | 329.03 | 62.41 |
| [`mlc.asm.dec_r64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-dec-r64-function-dec-r64-asm-reg-name-mlc-asm-ml-342211095) | `mlc/asm.ml:2713` | 8 | 7 | 2 | 1 | 1 | 329.03 | 62.41 |
| [`mlc.asm.disable_listing`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-disable-listing-function-disable-listing-asm-mlc-asm-ml-1312507739) | `mlc/asm.ml:3697` | 3 | 1 | 1 | 0 | 0 | 25.27 | 79.64 |
| [`mlc.asm.div_r64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-div-r64-function-div-r64-asm-reg-name-mlc-asm-ml-806295681) | `mlc/asm.ml:3167` | 8 | 7 | 2 | 1 | 1 | 332.84 | 62.37 |
| [`mlc.asm.divsd_xmm_xmm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-divsd-xmm-xmm-function-divsd-xmm-xmm-asm-dst-xmm-src-xmm-mlc-asm-ml-788105124) | `mlc/asm.ml:3286` | 3 | 1 | 1 | 0 | 0 | 105.49 | 75.29 |
| [`mlc.asm.emit`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-emit-function-emit-asm-b-mlc-asm-ml-892766301) | `mlc/asm.ml:1074` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.asm.emit32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-emit32-function-emit32-asm-x-mlc-asm-ml-875885211) | `mlc/asm.ml:1088` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.asm.emit64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-emit64-function-emit64-asm-x-mlc-asm-ml-1942395999) | `mlc/asm.ml:1095` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.asm.emit8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-emit8-function-emit8-asm-x-mlc-asm-ml-1396847481) | `mlc/asm.ml:1081` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.asm.emit_placeholder`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-emit-placeholder-function-emit-placeholder-asm-text-mlc-asm-ml-1552718002) | `mlc/asm.ml:3779` | 3 | 1 | 1 | 0 | 0 | 34.87 | 78.66 |
| [`mlc.asm.enable_listing`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-enable-listing-function-enable-listing-asm-path-show-addr-show-bytes-show-text-mlc-asm-ml-429631043) | `mlc/asm.ml:3691` | 3 | 1 | 1 | 0 | 0 | 60.94 | 76.96 |
| [`mlc.asm.finalize`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-finalize-function-finalize-asm-mlc-asm-ml-1223055845) | `mlc/asm.ml:1177` | 37 | 30 | 12 | 21 | 3 | 1969.31 | 41.11 |
| [`mlc.asm.get_calls`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-get-calls-function-get-calls-asm-mlc-asm-ml-1257997533) | `mlc/asm.ml:311` | 3 | 1 | 1 | 0 | 0 | 74.01 | 76.37 |
| [`mlc.asm.get_labels`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-get-labels-function-get-labels-asm-mlc-asm-ml-1671839357) | `mlc/asm.ml:317` | 6 | 3 | 3 | 2 | 1 | 203.56 | 66.46 |
| [`mlc.asm.get_patches`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-get-patches-function-get-patches-asm-mlc-asm-ml-1802592391) | `mlc/asm.ml:168` | 16 | 10 | 5 | 6 | 2 | 722.42 | 53.04 |
| [`mlc.asm.get_tracked_helpers`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-get-tracked-helpers-function-get-tracked-helpers-asm-mlc-asm-ml-233960775) | `mlc/asm.ml:342` | 3 | 1 | 1 | 0 | 0 | 34.87 | 78.66 |
| [`mlc.asm.gpr`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-gpr-function-gpr-name-mlc-asm-ml-897082947) | `mlc/asm.ml:3703` | 14 | 9 | 4 | 3 | 1 | 403.82 | 56.21 |
| [`mlc.asm.idiv_r64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-idiv-r64-function-idiv-r64-asm-reg-name-mlc-asm-ml-772090109) | `mlc/asm.ml:3155` | 8 | 7 | 2 | 1 | 1 | 329.03 | 62.41 |
| [`mlc.asm.imul_r64_r64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-imul-r64-r64-function-imul-r64-r64-asm-dst-src-mlc-asm-ml-107696754) | `mlc/asm.ml:3111` | 10 | 9 | 3 | 2 | 1 | 480.88 | 59 |
| [`mlc.asm.imul_r64_r64_imm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-imul-r64-r64-imm-function-imul-r64-r64-imm-asm-dst-src-imm-mlc-asm-ml-2034570803) | `mlc/asm.ml:3127` | 16 | 14 | 5 | 4 | 1 | 766.2 | 52.86 |
| [`mlc.asm.inc_membase_disp_qword`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-inc-membase-disp-qword-function-inc-membase-disp-qword-asm-base-disp-mlc-asm-ml-2113439912) | `mlc/asm.ml:2750` | 9 | 8 | 2 | 1 | 1 | 369.21 | 60.94 |
| [`mlc.asm.inc_r32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-inc-r32-function-inc-r32-asm-reg-name-mlc-asm-ml-1991958713) | `mlc/asm.ml:2725` | 8 | 7 | 2 | 1 | 1 | 329.03 | 62.41 |
| [`mlc.asm.inc_r64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-inc-r64-function-inc-r64-asm-reg-name-mlc-asm-ml-1857234975) | `mlc/asm.ml:2701` | 8 | 7 | 2 | 1 | 1 | 329.03 | 62.41 |
| [`mlc.asm.ja`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-ja-function-ja-asm-label-mlc-asm-ml-1629144245) | `mlc/asm.ml:1351` | 1 | 1 | 1 | 0 | 0 | 62.27 | 87.3 |
| [`mlc.asm.jae`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-jae-function-jae-asm-label-mlc-asm-ml-103205741) | `mlc/asm.ml:1355` | 1 | 1 | 1 | 0 | 0 | 62.27 | 87.3 |
| [`mlc.asm.jb`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-jb-function-jb-asm-label-mlc-asm-ml-328316909) | `mlc/asm.ml:1343` | 1 | 1 | 1 | 0 | 0 | 62.27 | 87.3 |
| [`mlc.asm.jbe`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-jbe-function-jbe-asm-label-mlc-asm-ml-180839243) | `mlc/asm.ml:1347` | 1 | 1 | 1 | 0 | 0 | 62.27 | 87.3 |
| [`mlc.asm.jcc`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-jcc-function-jcc-asm-cc-label-mlc-asm-ml-225047267) | `mlc/asm.ml:1264` | 41 | 54 | 25 | 26 | 2 | 2332.73 | 37.87 |
| [`mlc.asm.je`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-je-function-je-asm-label-mlc-asm-ml-604694101) | `mlc/asm.ml:1311` | 1 | 1 | 1 | 0 | 0 | 62.27 | 87.3 |
| [`mlc.asm.jg`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-jg-function-jg-asm-label-mlc-asm-ml-783503489) | `mlc/asm.ml:1335` | 1 | 1 | 1 | 0 | 0 | 62.27 | 87.3 |
| [`mlc.asm.jge`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-jge-function-jge-asm-label-mlc-asm-ml-761932241) | `mlc/asm.ml:1339` | 1 | 1 | 1 | 0 | 0 | 62.27 | 87.3 |
| [`mlc.asm.jl`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-jl-function-jl-asm-label-mlc-asm-ml-481496257) | `mlc/asm.ml:1327` | 1 | 1 | 1 | 0 | 0 | 62.27 | 87.3 |
| [`mlc.asm.jle`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-jle-function-jle-asm-label-mlc-asm-ml-257641171) | `mlc/asm.ml:1331` | 1 | 1 | 1 | 0 | 0 | 62.27 | 87.3 |
| [`mlc.asm.jmp`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-jmp-function-jmp-asm-label-mlc-asm-ml-1247247907) | `mlc/asm.ml:1224` | 22 | 18 | 6 | 7 | 2 | 905.86 | 49.2 |
| [`mlc.asm.jmp_r64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-jmp-r64-function-jmp-r64-asm-reg-mlc-asm-ml-1944190845) | `mlc/asm.ml:1251` | 8 | 7 | 2 | 1 | 1 | 332.84 | 62.37 |
| [`mlc.asm.jne`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-jne-function-jne-asm-label-mlc-asm-ml-532552035) | `mlc/asm.ml:1319` | 1 | 1 | 1 | 0 | 0 | 62.27 | 87.3 |
| [`mlc.asm.jnz`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-jnz-function-jnz-asm-label-mlc-asm-ml-1967950889) | `mlc/asm.ml:1323` | 1 | 1 | 1 | 0 | 0 | 62.27 | 87.3 |
| [`mlc.asm.jz`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-jz-function-jz-asm-label-mlc-asm-ml-201224317) | `mlc/asm.ml:1315` | 1 | 1 | 1 | 0 | 0 | 62.27 | 87.3 |
| [`mlc.asm.lea_r11_rip`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-lea-r11-rip-function-lea-r11-rip-asm-label-mlc-asm-ml-1655740875) | `mlc/asm.ml:1471` | 3 | 1 | 1 | 0 | 0 | 62.27 | 76.89 |
| [`mlc.asm.lea_r64_mem_bis`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-lea-r64-mem-bis-function-lea-r64-mem-bis-asm-dst-base-index-reg-scale-disp-mlc-asm-ml-26051556) | `mlc/asm.ml:3057` | 13 | 13 | 5 | 4 | 1 | 643.95 | 55.36 |
| [`mlc.asm.lea_r64_membase_disp`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-lea-r64-membase-disp-function-lea-r64-membase-disp-asm-dst-base-disp-mlc-asm-ml-613633253) | `mlc/asm.ml:2458` | 12 | 12 | 4 | 3 | 1 | 536.57 | 56.81 |
| [`mlc.asm.lea_r64_rip`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-lea-r64-rip-function-lea-r64-rip-asm-dst-label-mlc-asm-ml-859437180) | `mlc/asm.ml:1426` | 11 | 10 | 2 | 1 | 1 | 513.83 | 58.03 |
| [`mlc.asm.lea_r8_rip`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-lea-r8-rip-function-lea-r8-rip-asm-label-mlc-asm-ml-524136109) | `mlc/asm.ml:1457` | 3 | 1 | 1 | 0 | 0 | 62.27 | 76.89 |
| [`mlc.asm.lea_r9_rip`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-lea-r9-rip-function-lea-r9-rip-asm-label-mlc-asm-ml-1511291985) | `mlc/asm.ml:1464` | 3 | 1 | 1 | 0 | 0 | 62.27 | 76.89 |
| [`mlc.asm.lea_rax_rip`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-lea-rax-rip-function-lea-rax-rip-asm-as-struct-label-as-string-returns-struct-mlc-asm-ml-1441810659) | `mlc/asm.ml:1443` | 3 | 1 | 1 | 0 | 0 | 93.77 | 75.65 |
| [`mlc.asm.lea_rdx_rip`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-lea-rdx-rip-function-lea-rdx-rip-asm-label-mlc-asm-ml-2075327575) | `mlc/asm.ml:1450` | 3 | 1 | 1 | 0 | 0 | 62.27 | 76.89 |
| [`mlc.asm.leave`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-leave-function-leave-asm-mlc-asm-ml-1220138275) | `mlc/asm.ml:1418` | 3 | 1 | 1 | 0 | 0 | 46.51 | 77.78 |
| [`mlc.asm.lock_cmpxchg_membase_disp_r32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-lock-cmpxchg-membase-disp-r32-function-lock-cmpxchg-membase-disp-r32-asm-base-disp-src-mlc-asm-ml-2099308470) | `mlc/asm.ml:2341` | 14 | 14 | 4 | 3 | 1 | 628.96 | 54.86 |
| [`mlc.asm.lock_cmpxchg_membase_disp_r64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-lock-cmpxchg-membase-disp-r64-function-lock-cmpxchg-membase-disp-r64-asm-base-disp-src-mlc-asm-ml-1265994932) | `mlc/asm.ml:2361` | 14 | 14 | 4 | 3 | 1 | 628.96 | 54.86 |
| [`mlc.asm.mark`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mark-function-mark-asm-name-mlc-asm-ml-1003268770) | `mlc/asm.ml:1148` | 25 | 22 | 9 | 11 | 3 | 1134.17 | 46.91 |
| [`mlc.asm.materialize`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-materialize-function-materialize-asm-mlc-asm-ml-1305979579) | `mlc/asm.ml:800` | 3 | 1 | 1 | 0 | 0 | 36 | 78.56 |
| [`mlc.asm.materialize_and_fold_local_patches`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-materialize-and-fold-local-patches-function-materialize-and-fold-local-patches-asm-mlc-asm-ml-1626421277) | `mlc/asm.ml:225` | 13 | 11 | 1 | 0 | 0 | 498.25 | 56.68 |
| [`mlc.asm.mov_eax_rip_dword`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-eax-rip-dword-function-mov-eax-rip-dword-asm-label-mlc-asm-ml-628017397) | `mlc/asm.ml:2798` | 8 | 6 | 1 | 0 | 0 | 242.03 | 63.47 |
| [`mlc.asm.mov_gs_qword_28_rax`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-gs-qword-28-rax-function-mov-gs-qword-28-rax-asm-mlc-asm-ml-61670697) | `mlc/asm.ml:1125` | 5 | 4 | 2 | 1 | 1 | 253.82 | 67.65 |
| [`mlc.asm.mov_mem_bis_r32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-mem-bis-r32-function-mov-mem-bis-r32-asm-base-index-reg-scale-disp-src-mlc-asm-ml-1479592515) | `mlc/asm.ml:3036` | 13 | 13 | 5 | 4 | 1 | 643.95 | 55.36 |
| [`mlc.asm.mov_mem_bis_r64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-mem-bis-r64-function-mov-mem-bis-r64-asm-base-index-reg-scale-disp-src-mlc-asm-ml-1183844457) | `mlc/asm.ml:2994` | 13 | 13 | 5 | 4 | 1 | 643.95 | 55.36 |
| [`mlc.asm.mov_membase_disp_imm32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-membase-disp-imm32-function-mov-membase-disp-imm32-asm-base-disp-imm-qword-mlc-asm-ml-1249385460) | `mlc/asm.ml:2424` | 12 | 12 | 3 | 2 | 1 | 499.4 | 57.16 |
| [`mlc.asm.mov_membase_disp_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-membase-disp-imm8-function-mov-membase-disp-imm8-asm-base-disp-imm-mlc-asm-ml-1208277533) | `mlc/asm.ml:2442` | 10 | 9 | 2 | 1 | 1 | 417.79 | 59.57 |
| [`mlc.asm.mov_membase_disp_r32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-membase-disp-r32-function-mov-membase-disp-r32-asm-base-disp-src-mlc-asm-ml-685623958) | `mlc/asm.ml:2323` | 12 | 12 | 4 | 3 | 1 | 536.57 | 56.81 |
| [`mlc.asm.mov_membase_disp_r64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-membase-disp-r64-function-mov-membase-disp-r64-asm-base-disp-src-mlc-asm-ml-458693250) | `mlc/asm.ml:2287` | 12 | 12 | 4 | 3 | 1 | 536.57 | 56.81 |
| [`mlc.asm.mov_membase_disp_r8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-membase-disp-r8-function-mov-membase-disp-r8-asm-base-disp-src-mlc-asm-ml-1028143956) | `mlc/asm.ml:2403` | 14 | 15 | 5 | 4 | 1 | 683.71 | 54.48 |
| [`mlc.asm.mov_qword_ptr_rsp20_rax_zero`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-qword-ptr-rsp20-rax-zero-function-mov-qword-ptr-rsp20-rax-zero-asm-mlc-asm-ml-367685549) | `mlc/asm.ml:2789` | 5 | 3 | 1 | 0 | 0 | 121.11 | 70.03 |
| [`mlc.asm.mov_r10_gs_qword_28`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-r10-gs-qword-28-function-mov-r10-gs-qword-28-asm-mlc-asm-ml-1215678217) | `mlc/asm.ml:1117` | 5 | 4 | 2 | 1 | 1 | 253.82 | 67.65 |
| [`mlc.asm.mov_r10_rax`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-r10-rax-function-mov-r10-rax-asm-mlc-asm-ml-1449439221) | `mlc/asm.ml:2071` | 1 | 1 | 1 | 0 | 0 | 55.35 | 87.66 |
| [`mlc.asm.mov_r11_gs_qword_28`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-r11-gs-qword-28-function-mov-r11-gs-qword-28-asm-mlc-asm-ml-1509164471) | `mlc/asm.ml:1109` | 5 | 4 | 2 | 1 | 1 | 253.82 | 67.65 |
| [`mlc.asm.mov_r11_rax`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-r11-rax-function-mov-r11-rax-asm-mlc-asm-ml-1397694019) | `mlc/asm.ml:2074` | 1 | 1 | 1 | 0 | 0 | 55.35 | 87.66 |
| [`mlc.asm.mov_r32_imm32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-r32-imm32-function-mov-r32-imm32-asm-dst-imm-mlc-asm-ml-169497319) | `mlc/asm.ml:1593` | 10 | 8 | 3 | 2 | 1 | 350.94 | 59.96 |
| [`mlc.asm.mov_r32_mem_bis`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-r32-mem-bis-function-mov-r32-mem-bis-asm-dst-base-index-reg-scale-disp-mlc-asm-ml-1049579638) | `mlc/asm.ml:3015` | 13 | 13 | 5 | 4 | 1 | 643.95 | 55.36 |
| [`mlc.asm.mov_r32_membase_disp`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-r32-membase-disp-function-mov-r32-membase-disp-asm-dst-base-disp-mlc-asm-ml-1325186121) | `mlc/asm.ml:2305` | 12 | 12 | 4 | 3 | 1 | 536.57 | 56.81 |
| [`mlc.asm.mov_r32_r32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-r32-r32-function-mov-r32-r32-asm-dst-src-mlc-asm-ml-1598840574) | `mlc/asm.ml:1693` | 10 | 10 | 4 | 3 | 1 | 485.78 | 58.84 |
| [`mlc.asm.mov_r64_imm64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-r64-imm64-function-mov-r64-imm64-asm-dst-imm-mlc-asm-ml-1310864951) | `mlc/asm.ml:1564` | 24 | 21 | 6 | 5 | 1 | 1039.37 | 47.96 |
| [`mlc.asm.mov_r64_mem_bis`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-r64-mem-bis-function-mov-r64-mem-bis-asm-dst-base-index-reg-scale-disp-mlc-asm-ml-142204508) | `mlc/asm.ml:2973` | 13 | 13 | 5 | 4 | 1 | 643.95 | 55.36 |
| [`mlc.asm.mov_r64_membase_disp`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-r64-membase-disp-function-mov-r64-membase-disp-asm-dst-base-disp-mlc-asm-ml-1782241665) | `mlc/asm.ml:2269` | 12 | 12 | 4 | 3 | 1 | 536.57 | 56.81 |
| [`mlc.asm.mov_r64_r64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-r64-r64-function-mov-r64-r64-asm-dst-src-mlc-asm-ml-148248406) | `mlc/asm.ml:1678` | 10 | 10 | 4 | 3 | 1 | 485.78 | 58.84 |
| [`mlc.asm.mov_r64_tagged_int`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-r64-tagged-int-function-mov-r64-tagged-int-asm-dst-value-mlc-asm-ml-1688631105) | `mlc/asm.ml:1616` | 8 | 5 | 3 | 2 | 1 | 359.05 | 62.01 |
| [`mlc.asm.mov_r64_u64_hi_lo_exact`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-r64-u64-hi-lo-exact-function-mov-r64-u64-hi-lo-exact-asm-dst-hi32-lo32-mlc-asm-ml-1052138660) | `mlc/asm.ml:1641` | 9 | 8 | 2 | 1 | 1 | 398.35 | 60.71 |
| [`mlc.asm.mov_r8_membase_disp`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-r8-membase-disp-function-mov-r8-membase-disp-asm-dst-base-disp-mlc-asm-ml-738477459) | `mlc/asm.ml:2383` | 14 | 15 | 5 | 4 | 1 | 683.71 | 54.48 |
| [`mlc.asm.mov_r8_r8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-r8-r8-function-mov-r8-r8-asm-dst-src-mlc-asm-ml-414949710) | `mlc/asm.ml:1708` | 12 | 13 | 6 | 5 | 1 | 687.32 | 55.79 |
| [`mlc.asm.mov_r8d_edx`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-r8d-edx-function-mov-r8d-edx-asm-mlc-asm-ml-1968024003) | `mlc/asm.ml:2783` | 3 | 1 | 1 | 0 | 0 | 55.35 | 77.25 |
| [`mlc.asm.mov_r8d_imm32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-r8d-imm32-function-mov-r8d-imm32-asm-imm-mlc-asm-ml-740310858) | `mlc/asm.ml:1670` | 3 | 1 | 1 | 0 | 0 | 62.27 | 76.89 |
| [`mlc.asm.mov_r9d_imm32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-r9d-imm32-function-mov-r9d-imm32-asm-imm-mlc-asm-ml-1767898340) | `mlc/asm.ml:2777` | 3 | 1 | 1 | 0 | 0 | 62.27 | 76.89 |
| [`mlc.asm.mov_rax_gs_qword_28`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rax-gs-qword-28-function-mov-rax-gs-qword-28-asm-mlc-asm-ml-142508073) | `mlc/asm.ml:1101` | 5 | 4 | 2 | 1 | 1 | 253.82 | 67.65 |
| [`mlc.asm.mov_rax_imm64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rax-imm64-function-mov-rax-imm64-asm-as-struct-imm-as-int-returns-struct-mlc-asm-ml-1640675460) | `mlc/asm.ml:1608` | 3 | 1 | 1 | 0 | 0 | 93.77 | 75.65 |
| [`mlc.asm.mov_rax_r10`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rax-r10-function-mov-rax-r10-asm-mlc-asm-ml-1093562805) | `mlc/asm.ml:2077` | 1 | 1 | 1 | 0 | 0 | 55.35 | 87.66 |
| [`mlc.asm.mov_rax_r11`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rax-r11-function-mov-rax-r11-asm-mlc-asm-ml-1630066275) | `mlc/asm.ml:2080` | 1 | 1 | 1 | 0 | 0 | 55.35 | 87.66 |
| [`mlc.asm.mov_rax_rip_qword`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rax-rip-qword-function-mov-rax-rip-qword-asm-label-mlc-asm-ml-1876247681) | `mlc/asm.ml:2822` | 17 | 14 | 2 | 1 | 1 | 615.58 | 53.36 |
| [`mlc.asm.mov_rax_rsp_disp32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rax-rsp-disp32-function-mov-rax-rsp-disp32-asm-as-struct-disp-as-int-returns-struct-mlc-asm-ml-1973125325) | `mlc/asm.ml:2489` | 3 | 1 | 1 | 0 | 0 | 104 | 75.33 |
| [`mlc.asm.mov_rax_rsp_disp8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rax-rsp-disp8-function-mov-rax-rsp-disp8-asm-disp-mlc-asm-ml-49401983) | `mlc/asm.ml:2474` | 3 | 1 | 1 | 0 | 0 | 71.7 | 76.47 |
| [`mlc.asm.mov_rax_tagged_int`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rax-tagged-int-function-mov-rax-tagged-int-asm-as-struct-value-as-int-returns-struct-mlc-asm-ml-1077351336) | `mlc/asm.ml:1632` | 3 | 1 | 1 | 0 | 0 | 93.77 | 75.65 |
| [`mlc.asm.mov_rax_u64_hi_lo_exact`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rax-u64-hi-lo-exact-function-mov-rax-u64-hi-lo-exact-asm-hi32-lo32-mlc-asm-ml-695477375) | `mlc/asm.ml:1655` | 3 | 1 | 1 | 0 | 0 | 78.87 | 76.18 |
| [`mlc.asm.mov_rbp_rsp`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rbp-rsp-function-mov-rbp-rsp-asm-mlc-asm-ml-1836418983) | `mlc/asm.ml:1556` | 3 | 1 | 1 | 0 | 0 | 55.35 | 77.25 |
| [`mlc.asm.mov_rbx_rax`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rbx-rax-function-mov-rbx-rax-asm-mlc-asm-ml-1330816591) | `mlc/asm.ml:2062` | 1 | 1 | 1 | 0 | 0 | 55.35 | 87.66 |
| [`mlc.asm.mov_rcx_imm32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rcx-imm32-function-mov-rcx-imm32-asm-as-struct-imm-as-int-returns-struct-mlc-asm-ml-414152510) | `mlc/asm.ml:1663` | 3 | 1 | 1 | 0 | 0 | 93.77 | 75.65 |
| [`mlc.asm.mov_rcx_rbx`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rcx-rbx-function-mov-rcx-rbx-asm-mlc-asm-ml-1629593247) | `mlc/asm.ml:2065` | 1 | 1 | 1 | 0 | 0 | 55.35 | 87.66 |
| [`mlc.asm.mov_rdx_rax`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rdx-rax-function-mov-rdx-rax-asm-mlc-asm-ml-1191991607) | `mlc/asm.ml:2068` | 1 | 1 | 1 | 0 | 0 | 55.35 | 87.66 |
| [`mlc.asm.mov_rdx_rip_qword`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rdx-rip-qword-function-mov-rdx-rip-qword-asm-label-mlc-asm-ml-141231447) | `mlc/asm.ml:2843` | 17 | 14 | 2 | 1 | 1 | 615.58 | 53.36 |
| [`mlc.asm.mov_rip_dword_eax`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rip-dword-eax-function-mov-rip-dword-eax-asm-label-mlc-asm-ml-641073653) | `mlc/asm.ml:2810` | 8 | 6 | 1 | 0 | 0 | 242.03 | 63.47 |
| [`mlc.asm.mov_rip_qword_r11`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rip-qword-r11-function-mov-rip-qword-r11-asm-label-mlc-asm-ml-457063355) | `mlc/asm.ml:2906` | 17 | 14 | 2 | 1 | 1 | 615.58 | 53.36 |
| [`mlc.asm.mov_rip_qword_r8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rip-qword-r8-function-mov-rip-qword-r8-asm-label-mlc-asm-ml-381099973) | `mlc/asm.ml:2927` | 17 | 14 | 2 | 1 | 1 | 615.58 | 53.36 |
| [`mlc.asm.mov_rip_qword_r9`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rip-qword-r9-function-mov-rip-qword-r9-asm-label-mlc-asm-ml-1250695393) | `mlc/asm.ml:2948` | 17 | 14 | 2 | 1 | 1 | 615.58 | 53.36 |
| [`mlc.asm.mov_rip_qword_rax`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rip-qword-rax-function-mov-rip-qword-rax-asm-label-mlc-asm-ml-52223953) | `mlc/asm.ml:2864` | 17 | 14 | 2 | 1 | 1 | 615.58 | 53.36 |
| [`mlc.asm.mov_rip_qword_rdx`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rip-qword-rdx-function-mov-rip-qword-rdx-asm-label-mlc-asm-ml-148857199) | `mlc/asm.ml:2885` | 17 | 14 | 2 | 1 | 1 | 615.58 | 53.36 |
| [`mlc.asm.mov_rsp_disp32_rax`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rsp-disp32-rax-function-mov-rsp-disp32-rax-asm-as-struct-disp-as-int-returns-struct-mlc-asm-ml-1597720757) | `mlc/asm.ml:2497` | 3 | 1 | 1 | 0 | 0 | 104 | 75.33 |
| [`mlc.asm.mov_rsp_disp8_rax`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mov-rsp-disp8-rax-function-mov-rsp-disp8-rax-asm-disp-mlc-asm-ml-1247760079) | `mlc/asm.ml:2481` | 3 | 1 | 1 | 0 | 0 | 71.7 | 76.47 |
| [`mlc.asm.movapd_xmm_xmm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-movapd-xmm-xmm-function-movapd-xmm-xmm-asm-dst-xmm-src-xmm-mlc-asm-ml-979594844) | `mlc/asm.ml:3312` | 4 | 3 | 2 | 1 | 1 | 150.12 | 71.36 |
| [`mlc.asm.movd_r32_xmm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-movd-r32-xmm-function-movd-r32-xmm-asm-dst-src-mlc-asm-ml-1735264306) | `mlc/asm.ml:3440` | 12 | 12 | 4 | 3 | 1 | 635.9 | 56.29 |
| [`mlc.asm.movdqu_membase_disp_xmm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-movdqu-membase-disp-xmm-function-movdqu-membase-disp-xmm-asm-base-disp-src-mlc-asm-ml-560316024) | `mlc/asm.ml:3476` | 12 | 11 | 3 | 2 | 1 | 591.97 | 56.64 |
| [`mlc.asm.movdqu_xmm_membase_disp`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-movdqu-xmm-membase-disp-function-movdqu-xmm-membase-disp-asm-dst-base-disp-mlc-asm-ml-1044452691) | `mlc/asm.ml:3458` | 12 | 11 | 3 | 2 | 1 | 591.97 | 56.64 |
| [`mlc.asm.movq_r64_xmm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-movq-r64-xmm-function-movq-r64-xmm-asm-dst-reg-src-xmm-mlc-asm-ml-1852506596) | `mlc/asm.ml:3424` | 11 | 10 | 3 | 2 | 1 | 530 | 57.8 |
| [`mlc.asm.movq_xmm_r64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-movq-xmm-r64-function-movq-xmm-r64-asm-dst-xmm-src-reg-mlc-asm-ml-360973076) | `mlc/asm.ml:3408` | 11 | 10 | 3 | 2 | 1 | 530 | 57.8 |
| [`mlc.asm.movsd_membase_disp_xmm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-movsd-membase-disp-xmm-function-movsd-membase-disp-xmm-asm-base-disp-src-xmm-mlc-asm-ml-1171982343) | `mlc/asm.ml:3340` | 12 | 11 | 3 | 2 | 1 | 591.97 | 56.64 |
| [`mlc.asm.movsd_xmm_membase_disp`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-movsd-xmm-membase-disp-function-movsd-xmm-membase-disp-asm-dst-xmm-base-disp-mlc-asm-ml-536705176) | `mlc/asm.ml:3322` | 12 | 11 | 3 | 2 | 1 | 591.97 | 56.64 |
| [`mlc.asm.movsd_xmm_xmm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-movsd-xmm-xmm-function-movsd-xmm-xmm-asm-dst-xmm-src-xmm-mlc-asm-ml-510813534) | `mlc/asm.ml:3254` | 3 | 1 | 1 | 0 | 0 | 105.49 | 75.29 |
| [`mlc.asm.movzx_eax_al`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-movzx-eax-al-function-movzx-eax-al-asm-as-struct-returns-struct-mlc-asm-ml-1256030034) | `mlc/asm.ml:2056` | 3 | 1 | 1 | 0 | 0 | 76.15 | 76.28 |
| [`mlc.asm.movzx_r32_membase_disp`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-movzx-r32-membase-disp-function-movzx-r32-membase-disp-asm-dst32-base-disp-mlc-asm-ml-1997771456) | `mlc/asm.ml:2606` | 14 | 15 | 5 | 4 | 1 | 690.22 | 54.45 |
| [`mlc.asm.movzx_r32_r8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-movzx-r32-r8-function-movzx-r32-r8-asm-dst-src8-mlc-asm-ml-1686395618) | `mlc/asm.ml:2041` | 11 | 10 | 3 | 2 | 1 | 594.54 | 57.45 |
| [`mlc.asm.mulsd_xmm_xmm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-mulsd-xmm-xmm-function-mulsd-xmm-xmm-asm-dst-xmm-src-xmm-mlc-asm-ml-1083944914) | `mlc/asm.ml:3278` | 3 | 1 | 1 | 0 | 0 | 105.49 | 75.29 |
| [`mlc.asm.neg_r64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-neg-r64-function-neg-r64-asm-reg-name-mlc-asm-ml-2043155571) | `mlc/asm.ml:2160` | 8 | 7 | 2 | 1 | 1 | 329.03 | 62.41 |
| [`mlc.asm.neg_rax`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-neg-rax-function-neg-rax-asm-mlc-asm-ml-1373429613) | `mlc/asm.ml:2171` | 3 | 1 | 1 | 0 | 0 | 46.51 | 77.78 |
| [`mlc.asm.newAsmBuilder`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-newasmbuilder-function-newasmbuilder-mlc-asm-ml-1431619198) | `mlc/asm.ml:152` | 6 | 4 | 1 | 0 | 0 | 452.36 | 64.3 |
| [`mlc.asm.newCodegenAsmBuilder`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-newcodegenasmbuilder-function-newcodegenasmbuilder-mlc-asm-ml-938104422) | `mlc/asm.ml:160` | 5 | 3 | 1 | 0 | 0 | 64.53 | 71.95 |
| [`mlc.asm.nop`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-nop-function-nop-asm-mlc-asm-ml-2087544563) | `mlc/asm.ml:1217` | 3 | 1 | 1 | 0 | 0 | 46.51 | 77.78 |
| [`mlc.asm.or_r32_imm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-or-r32-imm-function-or-r32-imm-asm-reg-name-imm-mlc-asm-ml-2119945822) | `mlc/asm.ml:1860` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.or_r32_r32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-or-r32-r32-function-or-r32-r32-asm-dst-src-mlc-asm-ml-524216550) | `mlc/asm.ml:1948` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.or_r64_imm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-or-r64-imm-function-or-r64-imm-asm-reg-name-imm-mlc-asm-ml-482312102) | `mlc/asm.ml:1775` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.or_r64_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-or-r64-imm8-function-or-r64-imm8-asm-as-struct-reg-name-as-string-imm-as-int-returns-struct-mlc-asm-ml-1883212291) | `mlc/asm.ml:1822` | 3 | 1 | 1 | 0 | 0 | 112 | 75.11 |
| [`mlc.asm.or_r64_r64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-or-r64-r64-function-or-r64-r64-asm-dst-src-mlc-asm-ml-1307837550) | `mlc/asm.ml:1943` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.or_r8_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-or-r8-imm8-function-or-r8-imm8-asm-reg8-imm-mlc-asm-ml-306939044) | `mlc/asm.ml:2523` | 1 | 1 | 1 | 0 | 0 | 78.87 | 86.58 |
| [`mlc.asm.or_r8_r8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-or-r8-r8-function-or-r8-r8-asm-dst-src-mlc-asm-ml-1924097734) | `mlc/asm.ml:1958` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.or_rax_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-or-rax-imm8-function-or-rax-imm8-asm-imm-mlc-asm-ml-1120167116) | `mlc/asm.ml:2103` | 1 | 1 | 1 | 0 | 0 | 62.27 | 87.3 |
| [`mlc.asm.pcmpeqb_xmm_xmm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-pcmpeqb-xmm-xmm-function-pcmpeqb-xmm-xmm-asm-dst-src-mlc-asm-ml-2108371974) | `mlc/asm.ml:3501` | 3 | 1 | 1 | 0 | 0 | 105.49 | 75.29 |
| [`mlc.asm.pcmpeqw_xmm_xmm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-pcmpeqw-xmm-xmm-function-pcmpeqw-xmm-xmm-asm-dst-src-mlc-asm-ml-1576300584) | `mlc/asm.ml:3509` | 3 | 1 | 1 | 0 | 0 | 105.49 | 75.29 |
| [`mlc.asm.pmovmskb_r32_xmm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-pmovmskb-r32-xmm-function-pmovmskb-r32-xmm-asm-dst32-src-mlc-asm-ml-619996841) | `mlc/asm.ml:3517` | 12 | 12 | 4 | 3 | 1 | 635.9 | 56.29 |
| [`mlc.asm.pop_r12`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-pop-r12-function-pop-r12-asm-mlc-asm-ml-1042614159) | `mlc/asm.ml:1528` | 1 | 1 | 1 | 0 | 0 | 46.51 | 88.19 |
| [`mlc.asm.pop_r13`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-pop-r13-function-pop-r13-asm-mlc-asm-ml-1838337293) | `mlc/asm.ml:1534` | 1 | 1 | 1 | 0 | 0 | 46.51 | 88.19 |
| [`mlc.asm.pop_r14`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-pop-r14-function-pop-r14-asm-mlc-asm-ml-358460295) | `mlc/asm.ml:1540` | 1 | 1 | 1 | 0 | 0 | 46.51 | 88.19 |
| [`mlc.asm.pop_r15`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-pop-r15-function-pop-r15-asm-mlc-asm-ml-2094100481) | `mlc/asm.ml:1546` | 1 | 1 | 1 | 0 | 0 | 46.51 | 88.19 |
| [`mlc.asm.pop_rbp`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-pop-rbp-function-pop-rbp-asm-mlc-asm-ml-422139573) | `mlc/asm.ml:1552` | 1 | 1 | 1 | 0 | 0 | 46.51 | 88.19 |
| [`mlc.asm.pop_rbx`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-pop-rbx-function-pop-rbx-asm-mlc-asm-ml-1671558325) | `mlc/asm.ml:1522` | 1 | 1 | 1 | 0 | 0 | 46.51 | 88.19 |
| [`mlc.asm.pop_reg`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-pop-reg-function-pop-reg-asm-reg-mlc-asm-ml-1393436341) | `mlc/asm.ml:1494` | 22 | 21 | 15 | 17 | 2 | 1077.9 | 47.46 |
| [`mlc.asm.pos`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-pos-function-pos-asm-as-struct-returns-int-mlc-asm-ml-1706267734) | `mlc/asm.ml:870` | 3 | 1 | 1 | 0 | 0 | 55.51 | 77.24 |
| [`mlc.asm.punpcklqdq_xmm_xmm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-punpcklqdq-xmm-xmm-function-punpcklqdq-xmm-xmm-asm-dst-src-mlc-asm-ml-1607809610) | `mlc/asm.ml:3534` | 3 | 1 | 1 | 0 | 0 | 105.49 | 75.29 |
| [`mlc.asm.push_r12`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-push-r12-function-push-r12-asm-mlc-asm-ml-46261877) | `mlc/asm.ml:1525` | 1 | 1 | 1 | 0 | 0 | 46.51 | 88.19 |
| [`mlc.asm.push_r13`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-push-r13-function-push-r13-asm-mlc-asm-ml-633460721) | `mlc/asm.ml:1531` | 1 | 1 | 1 | 0 | 0 | 46.51 | 88.19 |
| [`mlc.asm.push_r14`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-push-r14-function-push-r14-asm-mlc-asm-ml-482627021) | `mlc/asm.ml:1537` | 1 | 1 | 1 | 0 | 0 | 46.51 | 88.19 |
| [`mlc.asm.push_r15`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-push-r15-function-push-r15-asm-mlc-asm-ml-705463233) | `mlc/asm.ml:1543` | 1 | 1 | 1 | 0 | 0 | 46.51 | 88.19 |
| [`mlc.asm.push_rbp`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-push-rbp-function-push-rbp-asm-mlc-asm-ml-1777877629) | `mlc/asm.ml:1549` | 1 | 1 | 1 | 0 | 0 | 46.51 | 88.19 |
| [`mlc.asm.push_rbx`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-push-rbx-function-push-rbx-asm-mlc-asm-ml-659445613) | `mlc/asm.ml:1519` | 1 | 1 | 1 | 0 | 0 | 46.51 | 88.19 |
| [`mlc.asm.push_reg`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-push-reg-function-push-reg-asm-reg-mlc-asm-ml-717522433) | `mlc/asm.ml:1478` | 12 | 10 | 3 | 2 | 1 | 370 | 58.07 |
| [`mlc.asm.pxor_xmm_xmm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-pxor-xmm-xmm-function-pxor-xmm-xmm-asm-dst-src-mlc-asm-ml-699906910) | `mlc/asm.ml:3493` | 3 | 1 | 1 | 0 | 0 | 105.49 | 75.29 |
| [`mlc.asm.rep_movsb`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-rep-movsb-function-rep-movsb-asm-mlc-asm-ml-1261806823) | `mlc/asm.ml:3178` | 5 | 3 | 1 | 0 | 0 | 89.62 | 70.95 |
| [`mlc.asm.rep_movsq`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-rep-movsq-function-rep-movsq-asm-mlc-asm-ml-1056503325) | `mlc/asm.ml:3186` | 6 | 4 | 1 | 0 | 0 | 122.11 | 68.28 |
| [`mlc.asm.rep_stosb`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-rep-stosb-function-rep-stosb-asm-mlc-asm-ml-1069603535) | `mlc/asm.ml:3195` | 5 | 3 | 1 | 0 | 0 | 89.62 | 70.95 |
| [`mlc.asm.rep_stosq`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-rep-stosq-function-rep-stosq-asm-mlc-asm-ml-2133024377) | `mlc/asm.ml:3203` | 6 | 4 | 1 | 0 | 0 | 122.11 | 68.28 |
| [`mlc.asm.repe_cmpsb`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-repe-cmpsb-function-repe-cmpsb-asm-mlc-asm-ml-1180550533) | `mlc/asm.ml:3212` | 5 | 3 | 1 | 0 | 0 | 89.62 | 70.95 |
| [`mlc.asm.resolve_all_defined_patches`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-resolve-all-defined-patches-function-resolve-all-defined-patches-asm-mlc-asm-ml-714751327) | `mlc/asm.ml:294` | 12 | 10 | 1 | 0 | 0 | 443.31 | 57.79 |
| [`mlc.asm.resolve_defined_patches`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-resolve-defined-patches-function-resolve-defined-patches-asm-mlc-asm-ml-480973383) | `mlc/asm.ml:278` | 10 | 8 | 1 | 0 | 0 | 316.65 | 60.54 |
| [`mlc.asm.ret`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-ret-function-ret-asm-mlc-asm-ml-346769639) | `mlc/asm.ml:1412` | 3 | 1 | 1 | 0 | 0 | 46.51 | 77.78 |
| [`mlc.asm.roundsd_xmm_xmm_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-roundsd-xmm-xmm-imm8-function-roundsd-xmm-xmm-imm8-asm-dst-xmm-src-xmm-imm8-mlc-asm-ml-583451099) | `mlc/asm.ml:3390` | 13 | 12 | 3 | 2 | 1 | 625.5 | 55.72 |
| [`mlc.asm.sar_r32_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-sar-r32-imm8-function-sar-r32-imm8-asm-reg-name-imm-mlc-asm-ml-847216226) | `mlc/asm.ml:2141` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.sar_r64_cl`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-sar-r64-cl-function-sar-r64-cl-asm-reg-name-mlc-asm-ml-938518801) | `mlc/asm.ml:3098` | 8 | 7 | 2 | 1 | 1 | 329.03 | 62.41 |
| [`mlc.asm.sar_r64_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-sar-r64-imm8-function-sar-r64-imm8-asm-reg-name-imm-mlc-asm-ml-998880162) | `mlc/asm.ml:2131` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.sar_rax_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-sar-rax-imm8-function-sar-rax-imm8-asm-imm-mlc-asm-ml-1716300758) | `mlc/asm.ml:2151` | 1 | 1 | 1 | 0 | 0 | 62.27 | 87.3 |
| [`mlc.asm.setcc_al`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-setcc-al-function-setcc-al-asm-as-struct-cc-as-string-returns-struct-mlc-asm-ml-492450819) | `mlc/asm.ml:2033` | 3 | 1 | 1 | 0 | 0 | 93.77 | 75.65 |
| [`mlc.asm.setcc_r8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-setcc-r8-function-setcc-r8-asm-cc-dst8-mlc-asm-ml-1154957978) | `mlc/asm.ml:2000` | 28 | 44 | 21 | 20 | 1 | 1739.92 | 42.92 |
| [`mlc.asm.shl_r32_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-shl-r32-imm8-function-shl-r32-imm8-asm-reg-name-imm-mlc-asm-ml-647376018) | `mlc/asm.ml:2136` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.shl_r64_cl`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-shl-r64-cl-function-shl-r64-cl-asm-reg-name-mlc-asm-ml-114711749) | `mlc/asm.ml:3074` | 8 | 7 | 2 | 1 | 1 | 332.84 | 62.37 |
| [`mlc.asm.shl_r64_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-shl-r64-imm8-function-shl-r64-imm8-asm-reg-name-imm-mlc-asm-ml-1909873058) | `mlc/asm.ml:2121` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.shl_rax_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-shl-rax-imm8-function-shl-rax-imm8-asm-imm-mlc-asm-ml-417650282) | `mlc/asm.ml:2155` | 1 | 1 | 1 | 0 | 0 | 62.27 | 87.3 |
| [`mlc.asm.shr_r32_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-shr-r32-imm8-function-shr-r32-imm8-asm-reg-name-imm-mlc-asm-ml-753174902) | `mlc/asm.ml:2146` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.shr_r64_cl`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-shr-r64-cl-function-shr-r64-cl-asm-reg-name-mlc-asm-ml-2076990297) | `mlc/asm.ml:3086` | 8 | 7 | 2 | 1 | 1 | 332.84 | 62.37 |
| [`mlc.asm.shr_r64_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-shr-r64-imm8-function-shr-r64-imm8-asm-reg-name-imm-mlc-asm-ml-2146344306) | `mlc/asm.ml:2126` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.sub_r32_imm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-sub-r32-imm-function-sub-r32-imm-asm-reg-name-imm-mlc-asm-ml-523102558) | `mlc/asm.ml:1850` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.sub_r32_r32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-sub-r32-r32-function-sub-r32-r32-asm-dst-src-mlc-asm-ml-1020021374) | `mlc/asm.ml:1918` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.sub_r64_imm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-sub-r64-imm-function-sub-r64-imm-asm-reg-name-imm-mlc-asm-ml-488582696) | `mlc/asm.ml:1765` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.sub_r64_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-sub-r64-imm8-function-sub-r64-imm8-asm-reg-name-imm-mlc-asm-ml-2039558970) | `mlc/asm.ml:1806` | 3 | 1 | 1 | 0 | 0 | 69.19 | 76.57 |
| [`mlc.asm.sub_r64_r64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-sub-r64-r64-function-sub-r64-r64-asm-dst-src-mlc-asm-ml-1393772758) | `mlc/asm.ml:1908` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.sub_r8_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-sub-r8-imm8-function-sub-r8-imm8-asm-reg8-imm-mlc-asm-ml-2002575582) | `mlc/asm.ml:2538` | 1 | 1 | 1 | 0 | 0 | 78.87 | 86.58 |
| [`mlc.asm.sub_rax_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-sub-rax-imm8-function-sub-rax-imm8-asm-imm-mlc-asm-ml-1877733982) | `mlc/asm.ml:2095` | 1 | 1 | 1 | 0 | 0 | 62.27 | 87.3 |
| [`mlc.asm.sub_rax_r11`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-sub-rax-r11-function-sub-rax-r11-asm-mlc-asm-ml-2138846559) | `mlc/asm.ml:2087` | 1 | 1 | 1 | 0 | 0 | 55.35 | 87.66 |
| [`mlc.asm.sub_rsp_imm32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-sub-rsp-imm32-function-sub-rsp-imm32-asm-imm-mlc-asm-ml-1228510736) | `mlc/asm.ml:2253` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.asm.sub_rsp_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-sub-rsp-imm8-function-sub-rsp-imm8-asm-imm-mlc-asm-ml-542282190) | `mlc/asm.ml:2237` | 4 | 3 | 2 | 1 | 1 | 105.49 | 72.43 |
| [`mlc.asm.subsd_xmm_xmm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-subsd-xmm-xmm-function-subsd-xmm-xmm-asm-dst-xmm-src-xmm-mlc-asm-ml-1553390274) | `mlc/asm.ml:3270` | 3 | 1 | 1 | 0 | 0 | 105.49 | 75.29 |
| [`mlc.asm.test_r32_r32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-test-r32-r32-function-test-r32-r32-asm-left-right-mlc-asm-ml-1179640542) | `mlc/asm.ml:1979` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.test_r64_imm32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-test-r64-imm32-function-test-r64-imm32-asm-reg-name-imm-mlc-asm-ml-1887492770) | `mlc/asm.ml:2555` | 9 | 8 | 2 | 1 | 1 | 384.59 | 60.81 |
| [`mlc.asm.test_r64_r64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-test-r64-r64-function-test-r64-r64-asm-left-right-mlc-asm-ml-1283886030) | `mlc/asm.ml:1974` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.test_r8_r8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-test-r8-r8-function-test-r8-r8-asm-left-right-mlc-asm-ml-1004369990) | `mlc/asm.ml:1985` | 10 | 9 | 3 | 2 | 1 | 569.8 | 58.49 |
| [`mlc.asm.test_rax_imm32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-test-rax-imm32-function-test-rax-imm32-asm-imm-mlc-asm-ml-616207034) | `mlc/asm.ml:2199` | 8 | 6 | 1 | 0 | 0 | 320.43 | 62.62 |
| [`mlc.asm.ucomisd_xmm_xmm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-ucomisd-xmm-xmm-function-ucomisd-xmm-xmm-asm-as-struct-left-xmm-as-string-right-xmm-as-string-returns-struct-mlc-asm-ml-1513138393) | `mlc/asm.ml:3295` | 3 | 1 | 1 | 0 | 0 | 148.68 | 74.25 |
| [`mlc.asm.vmovdqu_membase_disp_ymm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-vmovdqu-membase-disp-ymm-function-vmovdqu-membase-disp-ymm-asm-base-disp-src-mlc-asm-ml-1709641806) | `mlc/asm.ml:3591` | 10 | 9 | 3 | 2 | 1 | 551.03 | 58.59 |
| [`mlc.asm.vmovdqu_ymm_membase_disp`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-vmovdqu-ymm-membase-disp-function-vmovdqu-ymm-membase-disp-asm-dst-base-disp-mlc-asm-ml-1163881377) | `mlc/asm.ml:3575` | 10 | 9 | 3 | 2 | 1 | 551.03 | 58.59 |
| [`mlc.asm.vpcmpeqb_ymm_ymm_ymm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-vpcmpeqb-ymm-ymm-ymm-function-vpcmpeqb-ymm-ymm-ymm-asm-dst-src1-src2-mlc-asm-ml-144417041) | `mlc/asm.ml:3607` | 10 | 9 | 4 | 3 | 1 | 549.92 | 58.46 |
| [`mlc.asm.vpcmpeqw_ymm_ymm_ymm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-vpcmpeqw-ymm-ymm-ymm-function-vpcmpeqw-ymm-ymm-ymm-asm-dst-src1-src2-mlc-asm-ml-191103173) | `mlc/asm.ml:3623` | 10 | 9 | 4 | 3 | 1 | 549.92 | 58.46 |
| [`mlc.asm.vpmovmskb_r32_ymm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-vpmovmskb-r32-ymm-function-vpmovmskb-r32-ymm-asm-dst32-src-mlc-asm-ml-643392095) | `mlc/asm.ml:3638` | 10 | 10 | 4 | 3 | 1 | 599.71 | 58.2 |
| [`mlc.asm.vpxor_ymm_ymm_ymm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-vpxor-ymm-ymm-ymm-function-vpxor-ymm-ymm-ymm-asm-dst-src1-src2-mlc-asm-ml-173507307) | `mlc/asm.ml:3654` | 10 | 9 | 4 | 3 | 1 | 549.92 | 58.46 |
| [`mlc.asm.vzeroupper`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-vzeroupper-function-vzeroupper-asm-mlc-asm-ml-1059775613) | `mlc/asm.ml:3667` | 6 | 4 | 1 | 0 | 0 | 122.11 | 68.28 |
| [`mlc.asm.write_listing`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-write-listing-function-write-listing-asm-path-mlc-asm-ml-1316893246) | `mlc/asm.ml:3772` | 3 | 1 | 1 | 0 | 0 | 34.87 | 78.66 |
| [`mlc.asm.xgetbv`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-xgetbv-function-xgetbv-asm-mlc-asm-ml-2016278405) | `mlc/asm.ml:3228` | 6 | 4 | 1 | 0 | 0 | 122.11 | 68.28 |
| [`mlc.asm.xor_eax_eax`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-xor-eax-eax-function-xor-eax-eax-asm-mlc-asm-ml-1366683683) | `mlc/asm.ml:2216` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.asm.xor_ecx_ecx`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-xor-ecx-ecx-function-xor-ecx-ecx-asm-mlc-asm-ml-1641165587) | `mlc/asm.ml:2210` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.asm.xor_r32_imm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-xor-r32-imm-function-xor-r32-imm-asm-reg-name-imm-mlc-asm-ml-264693208) | `mlc/asm.ml:1865` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.xor_r32_r32`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-xor-r32-r32-function-xor-r32-r32-asm-dst-src-mlc-asm-ml-166464732) | `mlc/asm.ml:1928` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.xor_r64_imm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-xor-r64-imm-function-xor-r64-imm-asm-reg-name-imm-mlc-asm-ml-753519682) | `mlc/asm.ml:1780` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.xor_r64_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-xor-r64-imm8-function-xor-r64-imm8-asm-reg-name-imm-mlc-asm-ml-246689566) | `mlc/asm.ml:1829` | 3 | 1 | 1 | 0 | 0 | 69.19 | 76.57 |
| [`mlc.asm.xor_r64_r64`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-xor-r64-r64-function-xor-r64-r64-asm-dst-src-mlc-asm-ml-2140562780) | `mlc/asm.ml:1923` | 1 | 1 | 1 | 0 | 0 | 88.81 | 86.22 |
| [`mlc.asm.xor_r8_imm8`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-xor-r8-imm8-function-xor-r8-imm8-asm-reg8-imm-mlc-asm-ml-1404167300) | `mlc/asm.ml:2528` | 1 | 1 | 1 | 0 | 0 | 78.87 | 86.58 |
| [`mlc.asm.xorpd_xmm_xmm`](File-mlc-asm-ml-1368648960.md#function-function-mlc-asm-xorpd-xmm-xmm-function-xorpd-xmm-xmm-asm-as-struct-dst-xmm-as-string-src-xmm-as-string-returns-struct-mlc-asm-ml-681801965) | `mlc/asm.ml:3304` | 3 | 1 | 1 | 0 | 0 | 148.68 | 74.25 |
| [`mlc.codegen.codegen.__init__`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-init-function-init-cg-mlc-codegen-codegen-ml-841707717) | `mlc/codegen/codegen.ml:279` | 7 | 5 | 3 | 2 | 1 | 187.65 | 65.24 |
| [`mlc.codegen.codegen._arr_has`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-arr-has-function-arr-has-arr-value-mlc-codegen-codegen-ml-1028508207) | `mlc/codegen/codegen.ml:41` | 7 | 6 | 5 | 5 | 2 | 267.19 | 63.9 |
| [`mlc.codegen.codegen._clone_state_for_object`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-clone-state-for-object-function-clone-state-for-object-base-seed-runtime-mlc-codegen-codegen-ml-970806124) | `mlc/codegen/codegen.ml:304` | 126 | 121 | 3 | 2 | 1 | 6715.96 | 26.98 |
| [`mlc.codegen.codegen._copy_array`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-copy-array-function-copy-array-arr-mlc-codegen-codegen-ml-2074558282) | `mlc/codegen/codegen.ml:108` | 4 | 3 | 2 | 1 | 1 | 97.67 | 72.67 |
| [`mlc.codegen.codegen._copy_bss_builder`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-copy-bss-builder-function-copy-bss-builder-bb-mlc-codegen-codegen-ml-1612033673) | `mlc/codegen/codegen.ml:190` | 7 | 6 | 2 | 1 | 1 | 194.49 | 65.27 |
| [`mlc.codegen.codegen._copy_bytes`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-copy-bytes-function-copy-bytes-buf-mlc-codegen-codegen-ml-1774213728) | `mlc/codegen/codegen.ml:97` | 8 | 6 | 3 | 2 | 1 | 259.32 | 62.99 |
| [`mlc.codegen.codegen._copy_data_builder`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-copy-data-builder-function-copy-data-builder-db-mlc-codegen-codegen-ml-122450253) | `mlc/codegen/codegen.ml:178` | 9 | 8 | 2 | 1 | 1 | 348.29 | 61.12 |
| [`mlc.codegen.codegen._copy_fastmap`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-copy-fastmap-function-copy-fastmap-mapv-mlc-codegen-codegen-ml-1136249237) | `mlc/codegen/codegen.ml:157` | 18 | 19 | 11 | 10 | 1 | 964.31 | 50.24 |
| [`mlc.codegen.codegen._copy_fastmap_stack`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-copy-fastmap-stack-function-copy-fastmap-stack-frames-mlc-codegen-codegen-ml-731968205) | `mlc/codegen/codegen.ml:137` | 17 | 13 | 7 | 9 | 3 | 739.34 | 52.13 |
| [`mlc.codegen.codegen._copy_frame_stack`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-copy-frame-stack-function-copy-frame-stack-frames-mlc-codegen-codegen-ml-1246990299) | `mlc/codegen/codegen.ml:115` | 19 | 14 | 8 | 12 | 3 | 798.29 | 50.71 |
| [`mlc.codegen.codegen._copy_rdata_builder`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-copy-rdata-builder-function-copy-rdata-builder-rb-mlc-codegen-codegen-ml-1574846649) | `mlc/codegen/codegen.ml:200` | 13 | 12 | 2 | 1 | 1 | 564.29 | 56.17 |
| [`mlc.codegen.codegen._named_array_set`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-named-array-set-function-named-array-set-arr-key-values-mlc-codegen-codegen-ml-1981320995) | `mlc/codegen/codegen.ml:51` | 11 | 11 | 5 | 6 | 2 | 465 | 57.93 |
| [`mlc.codegen.codegen._named_int_set`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-named-int-set-function-named-int-set-arr-key-value-mlc-codegen-codegen-ml-1790917330) | `mlc/codegen/codegen.ml:65` | 11 | 11 | 5 | 6 | 2 | 465 | 57.93 |
| [`mlc.codegen.codegen._sparse_data_builder`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-sparse-data-builder-function-sparse-data-builder-base-db-mlc-codegen-codegen-ml-1087127649) | `mlc/codegen/codegen.ml:216` | 7 | 6 | 2 | 1 | 1 | 175.69 | 65.58 |
| [`mlc.codegen.codegen._sparse_rdata_builder`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-sparse-rdata-builder-function-sparse-rdata-builder-base-rb-mlc-codegen-codegen-ml-1887087327) | `mlc/codegen/codegen.ml:228` | 11 | 10 | 2 | 1 | 1 | 388.64 | 58.88 |
| [`mlc.codegen.codegen.all_function_entries`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-all-function-entries-function-all-function-entries-cg-mlc-codegen-codegen-ml-274900665) | `mlc/codegen/codegen.ml:529` | 5 | 5 | 3 | 2 | 1 | 179.85 | 68.56 |
| [`mlc.codegen.codegen.clear_program_function_state`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-clear-program-function-state-function-clear-program-function-state-cg-mlc-codegen-codegen-ml-182666621) | `mlc/codegen/codegen.ml:605` | 6 | 6 | 3 | 2 | 1 | 192.11 | 66.63 |
| [`mlc.codegen.codegen.clone_for_object`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-clone-for-object-function-clone-for-object-cg-seed-runtime-mlc-codegen-codegen-ml-2129459047) | `mlc/codegen/codegen.ml:447` | 5 | 5 | 3 | 2 | 1 | 195.99 | 68.3 |
| [`mlc.codegen.codegen.emit_entry_object`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-emit-entry-object-function-emit-entry-object-cg-module-init-recs-max-call-args-main-main-name-mlc-codegen-codegen-ml-1084668338) | `mlc/codegen/codegen.ml:488` | 7 | 7 | 3 | 2 | 1 | 272.32 | 64.11 |
| [`mlc.codegen.codegen.emit_extern_stubs`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-emit-extern-stubs-function-emit-extern-stubs-cg-mlc-codegen-codegen-ml-59230413) | `mlc/codegen/codegen.ml:587` | 6 | 6 | 3 | 2 | 1 | 188 | 66.7 |
| [`mlc.codegen.codegen.emit_module_function_entries`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-emit-module-function-entries-function-emit-module-function-entries-cg-entries-start-index-count-analysis-scratch-mlc-codegen-codegen-ml-608867126) | `mlc/codegen/codegen.ml:565` | 7 | 7 | 3 | 2 | 1 | 294.32 | 63.87 |
| [`mlc.codegen.codegen.emit_module_functions`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-emit-module-functions-function-emit-module-functions-cg-module-file-mlc-codegen-codegen-ml-1937406640) | `mlc/codegen/codegen.ml:510` | 7 | 7 | 3 | 2 | 1 | 229.39 | 64.63 |
| [`mlc.codegen.codegen.emit_module_init_object`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-emit-module-init-object-function-emit-module-init-object-cg-module-rec-mlc-codegen-codegen-ml-168585754) | `mlc/codegen/codegen.ml:499` | 7 | 7 | 3 | 2 | 1 | 229.39 | 64.63 |
| [`mlc.codegen.codegen.emit_program`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-emit-program-function-emit-program-cg-program-mlc-codegen-codegen-ml-1765725431) | `mlc/codegen/codegen.ml:290` | 9 | 9 | 3 | 2 | 1 | 312.13 | 61.32 |
| [`mlc.codegen.codegen.emit_used_helpers`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-emit-used-helpers-function-emit-used-helpers-cg-mlc-codegen-codegen-ml-858884679) | `mlc/codegen/codegen.ml:596` | 6 | 6 | 3 | 2 | 1 | 188 | 66.7 |
| [`mlc.codegen.codegen.enable_call_profile_metadata`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-enable-call-profile-metadata-function-enable-call-profile-metadata-cg-mlc-codegen-codegen-ml-1239671869) | `mlc/codegen/codegen.ml:79` | 14 | 13 | 6 | 5 | 1 | 773.29 | 53.97 |
| [`mlc.codegen.codegen.function_entry_count`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-function-entry-count-function-function-entry-count-entries-mlc-codegen-codegen-ml-56127929) | `mlc/codegen/codegen.ml:537` | 3 | 1 | 1 | 0 | 0 | 44.38 | 77.92 |
| [`mlc.codegen.codegen.function_entry_name`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-function-entry-name-function-function-entry-name-entries-node-id-mlc-codegen-codegen-ml-1465721125) | `mlc/codegen/codegen.ml:544` | 3 | 1 | 1 | 0 | 0 | 62.27 | 76.89 |
| [`mlc.codegen.codegen.module_function_entries`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-module-function-entries-function-module-function-entries-cg-module-file-mlc-codegen-codegen-ml-22499336) | `mlc/codegen/codegen.ml:521` | 5 | 5 | 3 | 2 | 1 | 203.9 | 68.18 |
| [`mlc.codegen.codegen.new_function_analysis_scratch`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-new-function-analysis-scratch-function-new-function-analysis-scratch-mlc-codegen-codegen-ml-26912121) | `mlc/codegen/codegen.ml:549` | 3 | 1 | 1 | 0 | 0 | 38.04 | 78.39 |
| [`mlc.codegen.codegen.newCodegen`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-newcodegen-function-newcodegen-source-filename-import-aliases-extern-sigs-extern-structs-mlc-codegen-codegen-ml-882947353) | `mlc/codegen/codegen.ml:246` | 5 | 3 | 1 | 0 | 0 | 221.65 | 68.19 |
| [`mlc.codegen.codegen.newCodegenForTarget`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-newcodegenfortarget-function-newcodegenfortarget-source-filename-import-aliases-extern-sigs-extern-structs-target-heap-config-mlc-codegen-codegen-ml-16619175) | `mlc/codegen/codegen.ml:260` | 5 | 3 | 1 | 0 | 0 | 231.89 | 68.06 |
| [`mlc.codegen.codegen.prepare_program_for_objects`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-prepare-program-for-objects-function-prepare-program-for-objects-cg-program-mlc-codegen-codegen-ml-1263654913) | `mlc/codegen/codegen.ml:466` | 13 | 12 | 5 | 4 | 1 | 656.28 | 55.3 |
| [`mlc.codegen.codegen.release_emitted_function_entries`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-release-emitted-function-entries-function-release-emitted-function-entries-cg-entries-start-index-count-mlc-codegen-codegen-ml-1994472837) | `mlc/codegen/codegen.ml:578` | 6 | 6 | 3 | 2 | 1 | 254.99 | 65.77 |
| [`mlc.codegen.codegen.release_function_analysis_scratch`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-release-function-analysis-scratch-function-release-function-analysis-scratch-value-mlc-codegen-codegen-ml-2060943192) | `mlc/codegen/codegen.ml:555` | 3 | 1 | 1 | 0 | 0 | 46.51 | 77.78 |
| [`mlc.codegen.codegen.set_target`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-set-target-function-set-target-cg-target-mlc-codegen-codegen-ml-211183960) | `mlc/codegen/codegen.ml:269` | 7 | 6 | 3 | 2 | 1 | 243 | 64.46 |
| [`mlc.codegen.codegen.start_object_fragment`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-start-object-fragment-function-start-object-fragment-cg-mlc-codegen-codegen-ml-288289155) | `mlc/codegen/codegen.ml:455` | 7 | 7 | 3 | 2 | 1 | 241.58 | 64.48 |
| [`mlc.codegen.codegen.track_helper`](File-mlc-codegen-codegen-ml-1154886880.md#function-function-mlc-codegen-codegen-track-helper-function-track-helper-cg-label-mlc-codegen-codegen-ml-1967167001) | `mlc/codegen/codegen.ml:615` | 6 | 6 | 3 | 2 | 1 | 216.64 | 66.27 |
| [`mlc.codegen.codegen_builtins_alloc._emit_addstr_error`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-addstr-error-function-emit-addstr-error-state-msg-lbl-mlc-codegen-codegen-builtins-alloc-ml-866812356) | `mlc/codegen/codegen_builtins_alloc.ml:33` | 4 | 2 | 1 | 0 | 0 | 95.18 | 72.88 |
| [`mlc.codegen.codegen_builtins_alloc._ensure_enum_obj_strings`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-ensure-enum-obj-strings-function-ensure-enum-obj-strings-state-mlc-codegen-codegen-builtins-alloc-ml-2013020058) | `mlc/codegen/codegen_builtins_alloc.ml:70` | 29 | 29 | 18 | 37 | 4 | 1604.04 | 43.24 |
| [`mlc.codegen.codegen_builtins_alloc._enum_variants_of`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-enum-variants-of-function-enum-variants-of-state-qname-mlc-codegen-codegen-builtins-alloc-ml-1426592110) | `mlc/codegen/codegen_builtins_alloc.ml:51` | 16 | 14 | 11 | 16 | 3 | 708.49 | 52.3 |
| [`mlc.codegen.codegen_builtins_alloc._has_label`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-has-label-function-has-label-labels-name-mlc-codegen-codegen-builtins-alloc-ml-562228589) | `mlc/codegen/codegen_builtins_alloc.ml:40` | 8 | 7 | 6 | 6 | 2 | 337.97 | 61.79 |
| [`mlc.codegen.codegen_builtins_alloc.cg_emit_builtins_alloc`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-cg-emit-builtins-alloc-function-cg-emit-builtins-alloc-state-mlc-codegen-codegen-builtins-alloc-ml-85017614) | `mlc/codegen/codegen_builtins_alloc.ml:3013` | 32 | 30 | 1 | 0 | 0 | 953.33 | 46.17 |
| [`mlc.codegen.codegen_builtins_alloc.emit_array_add_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-array-add-function-function-emit-array-add-function-state-mlc-codegen-codegen-builtins-alloc-ml-404836874) | `mlc/codegen/codegen_builtins_alloc.ml:1297` | 60 | 58 | 1 | 0 | 0 | 5682.37 | 34.79 |
| [`mlc.codegen.codegen_builtins_alloc.emit_box_float_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-box-float-function-function-emit-box-float-function-state-mlc-codegen-codegen-builtins-alloc-ml-1552409924) | `mlc/codegen/codegen_builtins_alloc.ml:838` | 15 | 13 | 1 | 0 | 0 | 1015.84 | 53.16 |
| [`mlc.codegen.codegen_builtins_alloc.emit_bytes_add_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-bytes-add-function-function-emit-bytes-add-function-state-mlc-codegen-codegen-builtins-alloc-ml-671638674) | `mlc/codegen/codegen_builtins_alloc.ml:1414` | 53 | 51 | 1 | 0 | 0 | 4821.27 | 36.46 |
| [`mlc.codegen.codegen_builtins_alloc.emit_bytes_alloc_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-bytes-alloc-function-function-emit-bytes-alloc-function-state-mlc-codegen-codegen-builtins-alloc-ml-1267821362) | `mlc/codegen/codegen_builtins_alloc.ml:1371` | 32 | 30 | 1 | 0 | 0 | 2541.3 | 43.19 |
| [`mlc.codegen.codegen_builtins_alloc.emit_bytes_eq_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-bytes-eq-function-function-emit-bytes-eq-function-state-mlc-codegen-codegen-builtins-alloc-ml-1120651394) | `mlc/codegen/codegen_builtins_alloc.ml:1484` | 52 | 50 | 1 | 0 | 0 | 4537.43 | 36.83 |
| [`mlc.codegen.codegen_builtins_alloc.emit_decode16Z_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-decode16z-function-function-emit-decode16z-function-state-mlc-codegen-codegen-builtins-alloc-ml-788400018) | `mlc/codegen/codegen_builtins_alloc.ml:365` | 80 | 78 | 1 | 0 | 0 | 7959.03 | 31.04 |
| [`mlc.codegen.codegen_builtins_alloc.emit_decode_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-decode-function-function-emit-decode-function-state-mlc-codegen-codegen-builtins-alloc-ml-751969402) | `mlc/codegen/codegen_builtins_alloc.ml:225` | 51 | 49 | 1 | 0 | 0 | 4528.35 | 37.02 |
| [`mlc.codegen.codegen_builtins_alloc.emit_decodeZ_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-decodez-function-function-emit-decodez-function-state-mlc-codegen-codegen-builtins-alloc-ml-102628784) | `mlc/codegen/codegen_builtins_alloc.ml:293` | 54 | 52 | 1 | 0 | 0 | 4844.23 | 36.27 |
| [`mlc.codegen.codegen_builtins_alloc.emit_fromHex_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-fromhex-function-function-emit-fromhex-function-state-mlc-codegen-codegen-builtins-alloc-ml-2013090778) | `mlc/codegen/codegen_builtins_alloc.ml:580` | 215 | 213 | 1 | 0 | 0 | 22335.16 | 18.53 |
| [`mlc.codegen.codegen_builtins_alloc.emit_hex_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-hex-function-function-emit-hex-function-state-mlc-codegen-codegen-builtins-alloc-ml-2059201050) | `mlc/codegen/codegen_builtins_alloc.ml:467` | 85 | 83 | 1 | 0 | 0 | 8308.98 | 30.33 |
| [`mlc.codegen.codegen_builtins_alloc.emit_input_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-input-function-function-emit-input-function-state-mlc-codegen-codegen-builtins-alloc-ml-858520024) | `mlc/codegen/codegen_builtins_alloc.ml:102` | 98 | 95 | 3 | 2 | 1 | 9186.05 | 28.41 |
| [`mlc.codegen.codegen_builtins_alloc.emit_slice_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-slice-function-function-emit-slice-function-state-mlc-codegen-codegen-builtins-alloc-ml-1961768308) | `mlc/codegen/codegen_builtins_alloc.ml:1552` | 84 | 82 | 1 | 0 | 0 | 8167.02 | 30.5 |
| [`mlc.codegen.codegen_builtins_alloc.emit_string_add_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-string-add-function-function-emit-string-add-function-state-mlc-codegen-codegen-builtins-alloc-ml-732887898) | `mlc/codegen/codegen_builtins_alloc.ml:1102` | 156 | 154 | 1 | 0 | 0 | 16176.06 | 22.55 |
| [`mlc.codegen.codegen_builtins_alloc.emit_string_endswith_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-string-endswith-function-function-emit-string-endswith-function-state-mlc-codegen-codegen-builtins-alloc-ml-655638304) | `mlc/codegen/codegen_builtins_alloc.ml:2007` | 49 | 47 | 1 | 0 | 0 | 4278.24 | 37.57 |
| [`mlc.codegen.codegen_builtins_alloc.emit_string_eq_ignore_case_ascii_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-string-eq-ignore-case-ascii-function-function-emit-string-eq-ignore-case-ascii-function-state-mlc-codegen-codegen-builtins-alloc-ml-2092485688) | `mlc/codegen/codegen_builtins_alloc.ml:2783` | 65 | 63 | 1 | 0 | 0 | 6004.26 | 33.86 |
| [`mlc.codegen.codegen_builtins_alloc.emit_string_indexof_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-string-indexof-function-function-emit-string-indexof-function-state-mlc-codegen-codegen-builtins-alloc-ml-418389098) | `mlc/codegen/codegen_builtins_alloc.ml:1787` | 80 | 78 | 1 | 0 | 0 | 7554.28 | 31.2 |
| [`mlc.codegen.codegen_builtins_alloc.emit_string_is_blank_ascii_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-string-is-blank-ascii-function-function-emit-string-is-blank-ascii-function-state-mlc-codegen-codegen-builtins-alloc-ml-576081770) | `mlc/codegen/codegen_builtins_alloc.ml:2434` | 41 | 39 | 1 | 0 | 0 | 3444 | 39.92 |
| [`mlc.codegen.codegen_builtins_alloc.emit_string_join_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-string-join-function-function-emit-string-join-function-state-mlc-codegen-codegen-builtins-alloc-ml-295930736) | `mlc/codegen/codegen_builtins_alloc.ml:2857` | 139 | 137 | 1 | 0 | 0 | 14779.54 | 23.92 |
| [`mlc.codegen.codegen_builtins_alloc.emit_string_lastindexof_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-string-lastindexof-function-function-emit-string-lastindexof-function-state-mlc-codegen-codegen-builtins-alloc-ml-1650872574) | `mlc/codegen/codegen_builtins_alloc.ml:1880` | 59 | 57 | 1 | 0 | 0 | 5267.17 | 35.18 |
| [`mlc.codegen.codegen_builtins_alloc.emit_string_ltrim_ascii_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-string-ltrim-ascii-function-function-emit-string-ltrim-ascii-function-state-mlc-codegen-codegen-builtins-alloc-ml-1420755194) | `mlc/codegen/codegen_builtins_alloc.ml:2178` | 67 | 65 | 1 | 0 | 0 | 6104.95 | 33.52 |
| [`mlc.codegen.codegen_builtins_alloc.emit_string_repeat_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-string-repeat-function-function-emit-string-repeat-function-state-mlc-codegen-codegen-builtins-alloc-ml-445144794) | `mlc/codegen/codegen_builtins_alloc.ml:2066` | 97 | 95 | 1 | 0 | 0 | 9561.59 | 28.65 |
| [`mlc.codegen.codegen_builtins_alloc.emit_string_reverse_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-string-reverse-function-function-emit-string-reverse-function-state-mlc-codegen-codegen-builtins-alloc-ml-1806498462) | `mlc/codegen/codegen_builtins_alloc.ml:2482` | 74 | 72 | 1 | 0 | 0 | 7262.95 | 32.05 |
| [`mlc.codegen.codegen_builtins_alloc.emit_string_rtrim_ascii_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-string-rtrim-ascii-function-function-emit-string-rtrim-ascii-function-state-mlc-codegen-codegen-builtins-alloc-ml-386542674) | `mlc/codegen/codegen_builtins_alloc.ml:2255` | 64 | 62 | 1 | 0 | 0 | 5807.66 | 34.11 |
| [`mlc.codegen.codegen_builtins_alloc.emit_string_slice_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-string-slice-function-function-emit-string-slice-function-state-mlc-codegen-codegen-builtins-alloc-ml-670650374) | `mlc/codegen/codegen_builtins_alloc.ml:1658` | 114 | 112 | 1 | 0 | 0 | 11388.7 | 26.59 |
| [`mlc.codegen.codegen_builtins_alloc.emit_string_startswith_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-string-startswith-function-function-emit-string-startswith-function-state-mlc-codegen-codegen-builtins-alloc-ml-1295344506) | `mlc/codegen/codegen_builtins_alloc.ml:1950` | 47 | 45 | 1 | 0 | 0 | 4025.57 | 38.15 |
| [`mlc.codegen.codegen_builtins_alloc.emit_string_to_lower_ascii_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-string-to-lower-ascii-function-function-emit-string-to-lower-ascii-function-state-mlc-codegen-codegen-builtins-alloc-ml-1846023914) | `mlc/codegen/codegen_builtins_alloc.ml:2569` | 94 | 92 | 1 | 0 | 0 | 9488.99 | 28.98 |
| [`mlc.codegen.codegen_builtins_alloc.emit_string_to_upper_ascii_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-string-to-upper-ascii-function-function-emit-string-to-upper-ascii-function-state-mlc-codegen-codegen-builtins-alloc-ml-367254172) | `mlc/codegen/codegen_builtins_alloc.ml:2676` | 94 | 92 | 1 | 0 | 0 | 9507.47 | 28.97 |
| [`mlc.codegen.codegen_builtins_alloc.emit_string_trim_ascii_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-string-trim-ascii-function-function-emit-string-trim-ascii-function-state-mlc-codegen-codegen-builtins-alloc-ml-1979931772) | `mlc/codegen/codegen_builtins_alloc.ml:2330` | 91 | 89 | 1 | 0 | 0 | 8697.94 | 29.55 |
| [`mlc.codegen.codegen_builtins_alloc.emit_value_to_string_function`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md#function-function-mlc-codegen-codegen-builtins-alloc-emit-value-to-string-function-function-emit-value-to-string-function-state-mlc-codegen-codegen-builtins-alloc-ml-586077162) | `mlc/codegen/codegen_builtins_alloc.ml:859` | 208 | 206 | 16 | 41 | 5 | 21623.91 | 16.93 |
| [`mlc.codegen.codegen_core.__init__`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-init-function-init-state-mlc-codegen-codegen-core-ml-601790500) | `mlc/codegen/codegen_core.ml:715` | 3 | 1 | 1 | 0 | 0 | 36 | 78.56 |
| [`mlc.codegen.codegen_core._add_extern_imports`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-add-extern-imports-function-add-extern-imports-state-mlc-codegen-codegen-core-ml-1096554156) | `mlc/codegen/codegen_core.ml:847` | 37 | 35 | 21 | 37 | 4 | 1766.75 | 40.23 |
| [`mlc.codegen.codegen_core._append_unique`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-append-unique-function-append-unique-vals-v-mlc-codegen-codegen-core-ml-2130500377) | `mlc/codegen/codegen_core.ml:310` | 9 | 7 | 5 | 7 | 3 | 304.31 | 61.12 |
| [`mlc.codegen.codegen_core._apply_import_alias`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-apply-import-alias-function-apply-import-alias-state-qname-mlc-codegen-codegen-core-ml-976862152) | `mlc/codegen/codegen_core.ml:965` | 37 | 27 | 17 | 29 | 4 | 1237.28 | 41.85 |
| [`mlc.codegen.codegen_core._arr_contains`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-arr-contains-function-arr-contains-arr-value-mlc-codegen-codegen-core-ml-1072187305) | `mlc/codegen/codegen_core.ml:1722` | 7 | 6 | 5 | 5 | 2 | 267.19 | 63.9 |
| [`mlc.codegen.codegen_core._cold_block_frame_items`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-cold-block-frame-items-function-cold-block-frame-items-frame-mlc-codegen-codegen-core-ml-257496788) | `mlc/codegen/codegen_core.ml:1307` | 7 | 5 | 4 | 3 | 1 | 207.45 | 64.8 |
| [`mlc.codegen.codegen_core._collect_pending_helpers`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-collect-pending-helpers-function-collect-pending-helpers-state-emitted-index-mlc-codegen-codegen-core-ml-2122030713) | `mlc/codegen/codegen_core.ml:2091` | 29 | 31 | 15 | 32 | 3 | 1369.99 | 44.12 |
| [`mlc.codegen.codegen_core._current_file_package_prefix`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-current-file-package-prefix-function-current-file-package-prefix-state-mlc-codegen-codegen-core-ml-405124012) | `mlc/codegen/codegen_core.ml:1006` | 4 | 3 | 2 | 1 | 1 | 97.67 | 72.67 |
| [`mlc.codegen.codegen_core._current_function_prefix`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-current-function-prefix-function-current-function-prefix-state-mlc-codegen-codegen-core-ml-1933834288) | `mlc/codegen/codegen_core.ml:1013` | 6 | 3 | 3 | 2 | 1 | 141.78 | 67.56 |
| [`mlc.codegen.codegen_core._emit_helper_by_label`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-helper-by-label-function-emit-helper-by-label-state-lbl-mlc-codegen-codegen-core-ml-1375139322) | `mlc/codegen/codegen_core.ml:2041` | 11 | 16 | 8 | 7 | 1 | 588.83 | 56.81 |
| [`mlc.codegen.codegen_core._emit_helper_by_label_group0`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-helper-by-label-group0-function-emit-helper-by-label-group0-state-lbl-mlc-codegen-codegen-core-ml-601287338) | `mlc/codegen/codegen_core.ml:1881` | 50 | 95 | 48 | 47 | 1 | 4536.73 | 30.88 |
| [`mlc.codegen.codegen_core._emit_helper_by_label_group1`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-helper-by-label-group1-function-emit-helper-by-label-group1-state-lbl-mlc-codegen-codegen-core-ml-1866673370) | `mlc/codegen/codegen_core.ml:1934` | 13 | 21 | 11 | 10 | 1 | 774.52 | 53.99 |
| [`mlc.codegen.codegen_core._emit_helper_by_label_group2`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-helper-by-label-group2-function-emit-helper-by-label-group2-state-lbl-mlc-codegen-codegen-core-ml-1090914018) | `mlc/codegen/codegen_core.ml:1950` | 13 | 21 | 11 | 10 | 1 | 768.21 | 54.02 |
| [`mlc.codegen.codegen_core._emit_helper_by_label_group3`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-helper-by-label-group3-function-emit-helper-by-label-group3-state-lbl-mlc-codegen-codegen-core-ml-831714354) | `mlc/codegen/codegen_core.ml:1966` | 13 | 21 | 11 | 10 | 1 | 774.52 | 53.99 |
| [`mlc.codegen.codegen_core._emit_helper_by_label_group4`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-helper-by-label-group4-function-emit-helper-by-label-group4-state-lbl-mlc-codegen-codegen-core-ml-1676083794) | `mlc/codegen/codegen_core.ml:1982` | 13 | 21 | 11 | 10 | 1 | 774.52 | 53.99 |
| [`mlc.codegen.codegen_core._emit_helper_by_label_group5`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-helper-by-label-group5-function-emit-helper-by-label-group5-state-lbl-mlc-codegen-codegen-core-ml-1758662258) | `mlc/codegen/codegen_core.ml:1998` | 14 | 23 | 12 | 11 | 1 | 859.56 | 52.84 |
| [`mlc.codegen.codegen_core._emit_helper_by_label_group6`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-helper-by-label-group6-function-emit-helper-by-label-group6-state-lbl-mlc-codegen-codegen-core-ml-1657138890) | `mlc/codegen/codegen_core.ml:2015` | 11 | 17 | 9 | 8 | 1 | 609.37 | 56.57 |
| [`mlc.codegen.codegen_core._emit_helper_by_label_other`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-helper-by-label-other-function-emit-helper-by-label-other-state-lbl-mlc-codegen-codegen-core-ml-2101739024) | `mlc/codegen/codegen_core.ml:2029` | 9 | 13 | 7 | 6 | 1 | 451.71 | 59.65 |
| [`mlc.codegen.codegen_core._expr_temp_live_by_reg_get`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-expr-temp-live-by-reg-get-function-expr-temp-live-by-reg-get-state-reg-mlc-codegen-codegen-core-ml-1843874942) | `mlc/codegen/codegen_core.ml:362` | 3 | 1 | 1 | 0 | 0 | 74.01 | 76.37 |
| [`mlc.codegen.codegen_core._expr_temp_live_by_reg_remove`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-expr-temp-live-by-reg-remove-function-expr-temp-live-by-reg-remove-state-reg-mlc-codegen-codegen-core-ml-1774523718) | `mlc/codegen/codegen_core.ml:375` | 4 | 2 | 1 | 0 | 0 | 85.11 | 73.22 |
| [`mlc.codegen.codegen_core._expr_temp_live_by_reg_set`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-expr-temp-live-by-reg-set-function-expr-temp-live-by-reg-set-state-reg-tmp-mlc-codegen-codegen-core-ml-1426865513) | `mlc/codegen/codegen_core.ml:368` | 4 | 2 | 1 | 0 | 0 | 102.8 | 72.64 |
| [`mlc.codegen.codegen_core._expr_temp_named_get`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-expr-temp-named-get-function-expr-temp-named-get-entries-key-defaultv-mlc-codegen-codegen-core-ml-411406927) | `mlc/codegen/codegen_core.ml:322` | 8 | 7 | 6 | 6 | 2 | 358.15 | 61.61 |
| [`mlc.codegen.codegen_core._expr_temp_named_remove`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-expr-temp-named-remove-function-expr-temp-named-remove-entries-key-mlc-codegen-codegen-core-ml-555371812) | `mlc/codegen/codegen_core.ml:349` | 10 | 9 | 6 | 6 | 2 | 396.82 | 59.18 |
| [`mlc.codegen.codegen_core._expr_temp_named_set`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-expr-temp-named-set-function-expr-temp-named-set-entries-key-value-mlc-codegen-codegen-core-ml-1101421503) | `mlc/codegen/codegen_core.ml:333` | 13 | 9 | 6 | 8 | 3 | 474.17 | 56.16 |
| [`mlc.codegen.codegen_core._expr_temp_reserved_dec`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-expr-temp-reserved-dec-function-expr-temp-reserved-dec-state-reg-mlc-codegen-codegen-core-ml-2003649144) | `mlc/codegen/codegen_core.ml:395` | 10 | 7 | 3 | 2 | 1 | 319.63 | 60.24 |
| [`mlc.codegen.codegen_core._expr_temp_reserved_get`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-expr-temp-reserved-get-function-expr-temp-reserved-get-state-reg-mlc-codegen-codegen-core-ml-294996296) | `mlc/codegen/codegen_core.ml:382` | 3 | 1 | 1 | 0 | 0 | 74.01 | 76.37 |
| [`mlc.codegen.codegen_core._expr_temp_reserved_set`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-expr-temp-reserved-set-function-expr-temp-reserved-set-state-reg-value-mlc-codegen-codegen-core-ml-24002835) | `mlc/codegen/codegen_core.ml:388` | 4 | 2 | 1 | 0 | 0 | 102.8 | 72.64 |
| [`mlc.codegen.codegen_core._flatten_member_chain_as_qualname`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-flatten-member-chain-as-qualname-function-flatten-member-chain-as-qualname-expr-mlc-codegen-codegen-core-ml-1396342940) | `mlc/codegen/codegen_core.ml:950` | 12 | 10 | 8 | 8 | 2 | 530.1 | 56.31 |
| [`mlc.codegen.codegen_core._helper_rank`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-helper-rank-function-helper-rank-lbl-mlc-codegen-codegen-core-ml-1240378861) | `mlc/codegen/codegen_core.ml:2055` | 33 | 5 | 3 | 3 | 2 | 1762.61 | 43.74 |
| [`mlc.codegen.codegen_core._helper_supported`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-helper-supported-function-helper-supported-lbl-mlc-codegen-codegen-core-ml-877322769) | `mlc/codegen/codegen_core.ml:1763` | 115 | 225 | 113 | 112 | 1 | 7072.42 | 12.89 |
| [`mlc.codegen.codegen_core._import_pair_gt`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-import-pair-gt-function-import-pair-gt-a-b-mlc-codegen-codegen-core-ml-1977412070) | `mlc/codegen/codegen_core.ml:812` | 14 | 15 | 10 | 9 | 1 | 644.05 | 53.99 |
| [`mlc.codegen.codegen_core._import_string_gt`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-import-string-gt-function-import-string-gt-a-b-mlc-codegen-codegen-core-ml-1926425052) | `mlc/codegen/codegen_core.ml:793` | 16 | 16 | 6 | 6 | 2 | 540.54 | 53.79 |
| [`mlc.codegen.codegen_core._imports_get_funcs`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-imports-get-funcs-function-imports-get-funcs-imports-dll-mlc-codegen-codegen-core-ml-1430142115) | `mlc/codegen/codegen_core.ml:431` | 11 | 9 | 7 | 9 | 3 | 433.82 | 57.88 |
| [`mlc.codegen.codegen_core._imports_set_funcs`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-imports-set-funcs-function-imports-set-funcs-imports-dll-funcs-mlc-codegen-codegen-core-ml-902529964) | `mlc/codegen/codegen_core.ml:445` | 11 | 8 | 5 | 5 | 2 | 423.73 | 58.22 |
| [`mlc.codegen.codegen_core._is_internal_helper_label`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-is-internal-helper-label-function-is-internal-helper-label-lbl-mlc-codegen-codegen-core-ml-214788387) | `mlc/codegen/codegen_core.ml:1752` | 8 | 11 | 6 | 5 | 1 | 301.6 | 62.13 |
| [`mlc.codegen.codegen_core._line_from_pos`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-line-from-pos-function-line-from-pos-state-pos-filename-mlc-codegen-codegen-core-ml-282494713) | `mlc/codegen/codegen_core.ml:912` | 33 | 34 | 13 | 19 | 3 | 1137.85 | 43.73 |
| [`mlc.codegen.codegen_core._pos`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-pos-function-pos-node-mlc-codegen-codegen-core-ml-339808289) | `mlc/codegen/codegen_core.ml:887` | 3 | 1 | 1 | 0 | 0 | 46.51 | 77.78 |
| [`mlc.codegen.codegen_core._pretty_script`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-pretty-script-function-pretty-script-state-p-mlc-codegen-codegen-core-ml-148685144) | `mlc/codegen/codegen_core.ml:721` | 34 | 26 | 14 | 20 | 3 | 1508.87 | 42.45 |
| [`mlc.codegen.codegen_core._qualify_identifier`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-qualify-identifier-function-qualify-identifier-state-name-node-kind-mlc-codegen-codegen-core-ml-2040422059) | `mlc/codegen/codegen_core.ml:1022` | 16 | 13 | 7 | 7 | 2 | 514.3 | 53.81 |
| [`mlc.codegen.codegen_core._seed_data`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-seed-data-function-seed-data-cg-mlc-codegen-codegen-core-ml-907394887) | `mlc/codegen/codegen_core.ml:519` | 37 | 32 | 4 | 3 | 1 | 3281.14 | 40.63 |
| [`mlc.codegen.codegen_core._seed_rdata`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-seed-rdata-function-seed-rdata-cg-mlc-codegen-codegen-core-ml-1559276861) | `mlc/codegen/codegen_core.ml:459` | 53 | 50 | 2 | 1 | 1 | 5451.19 | 35.95 |
| [`mlc.codegen.codegen_core._sort_import_pairs`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-sort-import-pairs-function-sort-import-pairs-pairs-mlc-codegen-codegen-core-ml-150756412) | `mlc/codegen/codegen_core.ml:829` | 15 | 11 | 6 | 8 | 3 | 510 | 54.58 |
| [`mlc.codegen.codegen_core._source_for_dbg_filename`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-source-for-dbg-filename-function-source-for-dbg-filename-state-filename-mlc-codegen-codegen-core-ml-276669219) | `mlc/codegen/codegen_core.ml:893` | 16 | 11 | 10 | 15 | 4 | 583.46 | 53.02 |
| [`mlc.codegen.codegen_core._spill_live_expr_value_temps`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-spill-live-expr-value-temps-function-spill-live-expr-value-temps-state-mlc-codegen-codegen-core-ml-1066639104) | `mlc/codegen/codegen_core.ml:1124` | 12 | 13 | 9 | 11 | 2 | 706.39 | 55.3 |
| [`mlc.codegen.codegen_core._starts_with`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-starts-with-function-starts-with-text-prefix-mlc-codegen-codegen-core-ml-1683870160) | `mlc/codegen/codegen_core.ml:1709` | 10 | 12 | 7 | 7 | 2 | 432.66 | 58.79 |
| [`mlc.codegen.codegen_core._str_less_ascii`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-str-less-ascii-function-str-less-ascii-a-b-mlc-codegen-codegen-core-ml-181873084) | `mlc/codegen/codegen_core.ml:1732` | 17 | 19 | 7 | 8 | 2 | 629.75 | 52.62 |
| [`mlc.codegen.codegen_core._sync_asm_before_call_live`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-sync-asm-before-call-live-function-sync-asm-before-call-live-state-mlc-codegen-codegen-core-ml-1220244748) | `mlc/codegen/codegen_core.ml:422` | 6 | 3 | 2 | 1 | 1 | 122.62 | 68.13 |
| [`mlc.codegen.codegen_core._sync_expr_temp_root_count`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-sync-expr-temp-root-count-function-sync-expr-temp-root-count-state-mlc-codegen-codegen-core-ml-1801879420) | `mlc/codegen/codegen_core.ml:408` | 11 | 12 | 5 | 4 | 1 | 479.22 | 57.84 |
| [`mlc.codegen.codegen_core._track_call_label`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-track-call-label-function-track-call-label-state-lbl-mlc-codegen-codegen-core-ml-1543685810) | `mlc/codegen/codegen_core.ml:758` | 6 | 6 | 4 | 3 | 1 | 230.7 | 65.94 |
| [`mlc.codegen.codegen_core.add_import_symbol`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-add-import-symbol-function-add-import-symbol-state-dll-sym-mlc-codegen-codegen-core-ml-1069918773) | `mlc/codegen/codegen_core.ml:782` | 8 | 8 | 5 | 4 | 1 | 357.58 | 61.75 |
| [`mlc.codegen.codegen_core.alloc_expr_temps`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-alloc-expr-temps-function-alloc-expr-temps-state-size-mlc-codegen-codegen-core-ml-2015718275) | `mlc/codegen/codegen_core.ml:1042` | 26 | 27 | 8 | 7 | 1 | 999.76 | 47.05 |
| [`mlc.codegen.codegen_core.alloc_expr_value_temp`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-alloc-expr-value-temp-function-alloc-expr-value-temp-state-prefer-reg-mlc-codegen-codegen-core-ml-1136061953) | `mlc/codegen/codegen_core.ml:1187` | 25 | 23 | 13 | 19 | 3 | 1071.68 | 46.54 |
| [`mlc.codegen.codegen_core.cg_core_init`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-cg-core-init-function-cg-core-init-state-mlc-codegen-codegen-core-ml-121868868) | `mlc/codegen/codegen_core.ml:709` | 3 | 1 | 1 | 0 | 0 | 25.27 | 79.64 |
| [`mlc.codegen.codegen_core.cg_core_new`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-cg-core-new-function-cg-core-new-source-filename-import-aliases-extern-sigs-extern-structs-target-heap-config-mlc-codegen-codegen-core-ml-166396853) | `mlc/codegen/codegen_core.ml:574` | 132 | 6 | 1 | 0 | 0 | 3622.45 | 28.69 |
| [`mlc.codegen.codegen_core.core_error`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-core-error-function-core-error-state-msg-node-mlc-codegen-codegen-core-ml-458624551) | `mlc/codegen/codegen_core.ml:1387` | 5 | 4 | 2 | 1 | 1 | 173.92 | 68.8 |
| [`mlc.codegen.codegen_core.defer_cold_block`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-defer-cold-block-function-defer-cold-block-state-label-emitter-mlc-codegen-codegen-core-ml-464817104) | `mlc/codegen/codegen_core.ml:1336` | 18 | 14 | 10 | 12 | 3 | 1010.81 | 50.23 |
| [`mlc.codegen.codegen_core.emit_dbg_line`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-dbg-line-function-emit-dbg-line-state-node-mlc-codegen-codegen-core-ml-1632173688) | `mlc/codegen/codegen_core.ml:1396` | 35 | 28 | 12 | 17 | 3 | 1705.97 | 42.07 |
| [`mlc.codegen.codegen_core.emit_deferred_cold_blocks`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-deferred-cold-blocks-function-emit-deferred-cold-blocks-state-mlc-codegen-codegen-core-ml-348961366) | `mlc/codegen/codegen_core.ml:1357` | 17 | 14 | 8 | 10 | 3 | 808.85 | 51.72 |
| [`mlc.codegen.codegen_core.emit_force_xmm0_to_float_value`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-force-xmm0-to-float-value-function-emit-force-xmm0-to-float-value-state-mlc-codegen-codegen-core-ml-239107252) | `mlc/codegen/codegen_core.ml:1534` | 18 | 16 | 1 | 0 | 0 | 1112.28 | 51.15 |
| [`mlc.codegen.codegen_core.emit_jmp_if_false_rax`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-jmp-if-false-rax-function-emit-jmp-if-false-rax-state-false-label-mlc-codegen-codegen-core-ml-1085469272) | `mlc/codegen/codegen_core.ml:1612` | 61 | 59 | 1 | 0 | 0 | 5131.73 | 34.94 |
| [`mlc.codegen.codegen_core.emit_load_var`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-load-var-function-emit-load-var-state-name-node-mlc-codegen-codegen-core-ml-1640032077) | `mlc/codegen/codegen_core.ml:1436` | 3 | 1 | 1 | 0 | 0 | 74.01 | 76.37 |
| [`mlc.codegen.codegen_core.emit_normalize_xmm0_to_value`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-normalize-xmm0-to-value-function-emit-normalize-xmm0-to-value-state-mlc-codegen-codegen-core-ml-1541917136) | `mlc/codegen/codegen_core.ml:1500` | 30 | 28 | 1 | 0 | 0 | 2083.06 | 44.41 |
| [`mlc.codegen.codegen_core.emit_store_var`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-store-var-function-emit-store-var-state-name-node-mlc-codegen-codegen-core-ml-681696745) | `mlc/codegen/codegen_core.ml:1444` | 3 | 1 | 1 | 0 | 0 | 81.41 | 76.08 |
| [`mlc.codegen.codegen_core.emit_struct_field_dispatch`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-struct-field-dispatch-function-emit-struct-field-dispatch-state-field-mlc-codegen-codegen-core-ml-821142380) | `mlc/codegen/codegen_core.ml:1693` | 3 | 1 | 1 | 0 | 0 | 36.54 | 78.52 |
| [`mlc.codegen.codegen_core.emit_struct_field_index_dispatch`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-struct-field-index-dispatch-function-emit-struct-field-index-dispatch-state-field-mlc-codegen-codegen-core-ml-1713913244) | `mlc/codegen/codegen_core.ml:1686` | 3 | 1 | 1 | 0 | 0 | 36.54 | 78.52 |
| [`mlc.codegen.codegen_core.emit_to_double_xmm`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-to-double-xmm-function-emit-to-double-xmm-state-xmm-fail-label-mlc-codegen-codegen-core-ml-1685662773) | `mlc/codegen/codegen_core.ml:1557` | 47 | 39 | 7 | 6 | 1 | 3304.58 | 37.94 |
| [`mlc.codegen.codegen_core.emit_used_helpers`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-used-helpers-function-emit-used-helpers-state-mlc-codegen-codegen-core-ml-1846412650) | `mlc/codegen/codegen_core.ml:2124` | 55 | 45 | 21 | 45 | 5 | 2104 | 35.94 |
| [`mlc.codegen.codegen_core.emit_writefile`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-writefile-function-emit-writefile-state-buf-label-length-mlc-codegen-codegen-core-ml-669236840) | `mlc/codegen/codegen_core.ml:1452` | 5 | 3 | 1 | 0 | 0 | 179.85 | 68.83 |
| [`mlc.codegen.codegen_core.emit_writefile_ptr_len`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-writefile-ptr-len-function-emit-writefile-ptr-len-state-mlc-codegen-codegen-core-ml-1259094248) | `mlc/codegen/codegen_core.ml:1460` | 8 | 6 | 1 | 0 | 0 | 338.21 | 62.46 |
| [`mlc.codegen.codegen_core.emit_writefile_ptr_len_stderr`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-writefile-ptr-len-stderr-function-emit-writefile-ptr-len-stderr-state-mlc-codegen-codegen-core-ml-1237776810) | `mlc/codegen/codegen_core.ml:1471` | 15 | 13 | 1 | 0 | 0 | 893.05 | 53.55 |
| [`mlc.codegen.codegen_core.emit_writefile_stderr`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-emit-writefile-stderr-function-emit-writefile-stderr-state-buf-label-length-mlc-codegen-codegen-core-ml-754523848) | `mlc/codegen/codegen_core.ml:1492` | 5 | 3 | 1 | 0 | 0 | 179.85 | 68.83 |
| [`mlc.codegen.codegen_core.ensure_var`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-ensure-var-function-ensure-var-state-name-mlc-codegen-codegen-core-ml-264316497) | `mlc/codegen/codegen_core.ml:1378` | 4 | 3 | 2 | 1 | 1 | 89.86 | 72.92 |
| [`mlc.codegen.codegen_core.expr_value_temp_load`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-expr-value-temp-load-function-expr-value-temp-load-state-dst-tmp-mlc-codegen-codegen-core-ml-53924732) | `mlc/codegen/codegen_core.ml:1248` | 12 | 10 | 6 | 6 | 2 | 510.09 | 56.69 |
| [`mlc.codegen.codegen_core.expr_value_temp_offset`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-expr-value-temp-offset-function-expr-value-temp-offset-state-tmp-mlc-codegen-codegen-core-ml-584030763) | `mlc/codegen/codegen_core.ml:1264` | 8 | 6 | 6 | 5 | 1 | 393.5 | 61.32 |
| [`mlc.codegen.codegen_core.expr_value_temp_store_rax`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-expr-value-temp-store-rax-function-expr-value-temp-store-rax-state-tmp-mlc-codegen-codegen-core-ml-2049784547) | `mlc/codegen/codegen_core.ml:1216` | 10 | 8 | 4 | 3 | 1 | 398.35 | 59.44 |
| [`mlc.codegen.codegen_core.expr_value_temp_store_reg`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-expr-value-temp-store-reg-function-expr-value-temp-store-reg-state-tmp-reg-mlc-codegen-codegen-core-ml-550453229) | `mlc/codegen/codegen_core.ml:1231` | 12 | 12 | 6 | 5 | 1 | 534.38 | 56.55 |
| [`mlc.codegen.codegen_core.free_expr_temps`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-free-expr-temps-function-free-expr-temps-state-size-mlc-codegen-codegen-core-ml-683362087) | `mlc/codegen/codegen_core.ml:1075` | 18 | 20 | 7 | 6 | 1 | 575.34 | 52.35 |
| [`mlc.codegen.codegen_core.free_expr_value_temp`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-free-expr-value-temp-function-free-expr-value-temp-state-tmp-mlc-codegen-codegen-core-ml-1510979115) | `mlc/codegen/codegen_core.ml:1276` | 20 | 17 | 10 | 12 | 3 | 895.17 | 49.61 |
| [`mlc.codegen.codegen_core.in_function`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-in-function-function-in-function-state-mlc-codegen-codegen-core-ml-1199782140) | `mlc/codegen/codegen_core.ml:767` | 3 | 1 | 1 | 0 | 0 | 33 | 78.82 |
| [`mlc.codegen.codegen_core.new_label_id`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-new-label-id-function-new-label-id-state-mlc-codegen-codegen-core-ml-995776928) | `mlc/codegen/codegen_core.ml:773` | 4 | 2 | 1 | 0 | 0 | 71.7 | 73.74 |
| [`mlc.codegen.codegen_core.pop_cold_block_scope`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-pop-cold-block-scope-function-pop-cold-block-scope-state-mlc-codegen-codegen-core-ml-880099660) | `mlc/codegen/codegen_core.ml:1317` | 14 | 10 | 5 | 5 | 2 | 530 | 55.25 |
| [`mlc.codegen.codegen_core.push_cold_block_scope`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-push-cold-block-scope-function-push-cold-block-scope-state-mlc-codegen-codegen-core-ml-1356668072) | `mlc/codegen/codegen_core.ml:1299` | 5 | 4 | 2 | 1 | 1 | 188.87 | 68.55 |
| [`mlc.codegen.codegen_core.release_expr_temp_regs`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-release-expr-temp-regs-function-release-expr-temp-regs-state-regs-mlc-codegen-codegen-core-ml-1676246493) | `mlc/codegen/codegen_core.ml:1174` | 9 | 8 | 6 | 6 | 2 | 360 | 60.48 |
| [`mlc.codegen.codegen_core.release_expr_temps`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-release-expr-temps-function-release-expr-temps-state-size-mlc-codegen-codegen-core-ml-1399238923) | `mlc/codegen/codegen_core.ml:1101` | 18 | 20 | 7 | 6 | 1 | 575.34 | 52.35 |
| [`mlc.codegen.codegen_core.reserve_expr_temp_regs`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-reserve-expr-temp-regs-function-reserve-expr-temp-regs-state-regs-mlc-codegen-codegen-core-ml-1262042661) | `mlc/codegen/codegen_core.ml:1140` | 30 | 27 | 16 | 29 | 5 | 1527.33 | 43.33 |
| [`mlc.codegen.codegen_core.reset_helper_tracking`](File-mlc-codegen-codegen-core-ml-528695596.md#function-function-mlc-codegen-codegen-core-reset-helper-tracking-function-reset-helper-tracking-state-mlc-codegen-codegen-core-ml-2008871044) | `mlc/codegen/codegen_core.ml:1699` | 7 | 5 | 1 | 0 | 0 | 183.94 | 65.57 |
| [`mlc.codegen.codegen_expr._abi_param_is_double`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-abi-param-is-double-function-abi-param-is-double-abi-ty-mlc-codegen-codegen-expr-ml-1010111637) | `mlc/codegen/codegen_expr.ml:8693` | 6 | 3 | 4 | 3 | 1 | 235.23 | 65.88 |
| [`mlc.codegen.codegen_expr._abi_ty_to_str`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-abi-ty-to-str-function-abi-ty-to-str-abi-ty-mlc-codegen-codegen-expr-ml-673719793) | `mlc/codegen/codegen_expr.ml:8173` | 9 | 10 | 6 | 8 | 2 | 329.42 | 60.75 |
| [`mlc.codegen.codegen_expr._alias_lookup`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-alias-lookup-inline-function-alias-lookup-alias-map-key-mlc-codegen-codegen-expr-ml-837732516) | `mlc/codegen/codegen_expr.ml:751` | 15 | 13 | 9 | 12 | 3 | 619.26 | 53.59 |
| [`mlc.codegen.codegen_expr._alias_lookup_array_exact`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-alias-lookup-array-exact-inline-function-alias-lookup-array-exact-alias-map-key-mlc-codegen-codegen-expr-ml-108088364) | `mlc/codegen/codegen_expr.ml:769` | 10 | 8 | 7 | 9 | 3 | 420.6 | 58.87 |
| [`mlc.codegen.codegen_expr._alias_target_for_base`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-alias-target-for-base-function-alias-target-for-base-state-base-mlc-codegen-codegen-expr-ml-677820043) | `mlc/codegen/codegen_expr.ml:837` | 13 | 12 | 7 | 7 | 2 | 519.8 | 55.74 |
| [`mlc.codegen.codegen_expr._apply_import_alias`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-apply-import-alias-function-apply-import-alias-state-qname-mlc-codegen-codegen-expr-ml-318875280) | `mlc/codegen/codegen_expr.ml:782` | 31 | 30 | 13 | 17 | 3 | 1241.65 | 44.05 |
| [`mlc.codegen.codegen_expr._arr_has_str`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-arr-has-str-inline-function-arr-has-str-arr-value-mlc-codegen-codegen-expr-ml-1249794348) | `mlc/codegen/codegen_expr.ml:816` | 7 | 6 | 5 | 5 | 2 | 274.79 | 63.81 |
| [`mlc.codegen.codegen_expr._builtin_label`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-builtin-label-inline-function-builtin-label-name-mlc-codegen-codegen-expr-ml-1717663613) | `mlc/codegen/codegen_expr.ml:578` | 53 | 100 | 50 | 49 | 1 | 3116.82 | 31.2 |
| [`mlc.codegen.codegen_expr._call_args_have_stack_variadic`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-call-args-have-stack-variadic-function-call-args-have-stack-variadic-args-mlc-codegen-codegen-expr-ml-1023336562) | `mlc/codegen/codegen_expr.ml:9719` | 8 | 7 | 8 | 8 | 2 | 437.59 | 60.73 |
| [`mlc.codegen.codegen_expr._cg_expr_try_const_value`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-cg-expr-try-const-value-function-cg-expr-try-const-value-state-expr-preserve-unary-float-mlc-codegen-codegen-expr-ml-27667210) | `mlc/codegen/codegen_expr.ml:1241` | 60 | 56 | 28 | 48 | 4 | 3367.63 | 32.75 |
| [`mlc.codegen.codegen_expr._coerce_name`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-coerce-name-inline-function-coerce-name-v-mlc-codegen-codegen-expr-ml-2073764020) | `mlc/codegen/codegen_expr.ml:298` | 13 | 14 | 8 | 9 | 2 | 447.08 | 56.07 |
| [`mlc.codegen.codegen_expr._compile_symbol_has`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-compile-symbol-has-inline-function-compile-symbol-has-state-key-mlc-codegen-codegen-expr-ml-1426967752) | `mlc/codegen/codegen_expr.ml:567` | 8 | 11 | 7 | 6 | 1 | 471.06 | 60.64 |
| [`mlc.codegen.codegen_expr._contains_nested_fn`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-contains-nested-fn-function-contains-nested-fn-node-mlc-codegen-codegen-expr-ml-757988883) | `mlc/codegen/codegen_expr.ml:8642` | 38 | 34 | 23 | 38 | 3 | 1719.77 | 39.79 |
| [`mlc.codegen.codegen_expr._direct_user_call_enabled`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-direct-user-call-enabled-function-direct-user-call-enabled-state-qname-mlc-codegen-codegen-expr-ml-954144962) | `mlc/codegen/codegen_expr.ml:7216` | 3 | 1 | 1 | 0 | 0 | 64.53 | 76.79 |
| [`mlc.codegen.codegen_expr._emit_auto_errprop`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-auto-errprop-function-emit-auto-errprop-state-mlc-codegen-codegen-expr-ml-1427208816) | `mlc/codegen/codegen_expr.ml:8750` | 42 | 35 | 13 | 15 | 2 | 2738.11 | 38.77 |
| [`mlc.codegen.codegen_expr._emit_auto_errprop_cold_block`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-auto-errprop-cold-block-function-emit-auto-errprop-cold-block-state-mlc-codegen-codegen-expr-ml-2016839500) | `mlc/codegen/codegen_expr.ml:8799` | 9 | 5 | 4 | 3 | 1 | 378.92 | 60.59 |
| [`mlc.codegen.codegen_expr._emit_call_args_eval_recursive`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-call-args-eval-recursive-function-emit-call-args-eval-recursive-state-call-args-idx-nargs-base-off-mlc-codegen-codegen-expr-ml-103569979) | `mlc/codegen/codegen_expr.ml:9997` | 14 | 14 | 8 | 7 | 1 | 792.67 | 53.62 |
| [`mlc.codegen.codegen_expr._emit_direct_struct_constructor`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-direct-struct-constructor-function-emit-direct-struct-constructor-state-scallee-sid-call-args-nargs-mlc-codegen-codegen-expr-ml-935619048) | `mlc/codegen/codegen_expr.ml:7380` | 72 | 66 | 19 | 28 | 4 | 5847.4 | 30.55 |
| [`mlc.codegen.codegen_expr._emit_direct_user_call`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-direct-user-call-function-emit-direct-user-call-state-direct-user-name-call-args-nargs-mlc-codegen-codegen-expr-ml-265201574) | `mlc/codegen/codegen_expr.ml:7458` | 42 | 38 | 15 | 35 | 4 | 2691.71 | 38.56 |
| [`mlc.codegen.codegen_expr._emit_expr_array_lit`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-expr-array-lit-function-emit-expr-array-lit-state-expr-mlc-codegen-codegen-expr-ml-1916635897) | `mlc/codegen/codegen_expr.ml:8077` | 52 | 40 | 12 | 22 | 4 | 2465.42 | 37.2 |
| [`mlc.codegen.codegen_expr._emit_expr_bin`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-expr-bin-function-emit-expr-bin-state-expr-mlc-codegen-codegen-expr-ml-1874814489) | `mlc/codegen/codegen_expr.ml:3104` | 1132 | 1087 | 99 | 153 | 5 | 121708.69 | 0 |
| [`mlc.codegen.codegen_expr._emit_expr_bool`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-expr-bool-function-emit-expr-bool-state-expr-mlc-codegen-codegen-expr-ml-1473250299) | `mlc/codegen/codegen_expr.ml:1771` | 4 | 2 | 1 | 0 | 0 | 143.06 | 71.64 |
| [`mlc.codegen.codegen_expr._emit_expr_call`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-expr-call-function-emit-expr-call-state-expr-mlc-codegen-codegen-expr-ml-1220291383) | `mlc/codegen/codegen_expr.ml:4363` | 636 | 577 | 197 | 523 | 6 | 51866.07 | 0 |
| [`mlc.codegen.codegen_expr._emit_expr_call_early_builtins`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-expr-call-early-builtins-function-emit-expr-call-early-builtins-state-callee-raw-name-call-args-nargs-mlc-codegen-codegen-expr-ml-1199270435) | `mlc/codegen/codegen_expr.ml:5055` | 1035 | 979 | 167 | 293 | 6 | 115278.81 | 0 |
| [`mlc.codegen.codegen_expr._emit_expr_call_generic`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-expr-call-generic-function-emit-expr-call-generic-state-cal-callee-raw-name-call-args-nargs-member-runtime-mlc-codegen-codegen-expr-ml-1620748138) | `mlc/codegen/codegen_expr.ml:7225` | 131 | 125 | 89 | 159 | 4 | 7710.85 | 14.63 |
| [`mlc.codegen.codegen_expr._emit_expr_coalesce`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-expr-coalesce-function-emit-expr-coalesce-state-expr-mlc-codegen-codegen-expr-ml-825042161) | `mlc/codegen/codegen_expr.ml:1640` | 10 | 8 | 1 | 0 | 0 | 427.94 | 59.63 |
| [`mlc.codegen.codegen_expr._emit_expr_index`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-expr-index-function-emit-expr-index-state-expr-mlc-codegen-codegen-expr-ml-871640929) | `mlc/codegen/codegen_expr.ml:2193` | 151 | 142 | 12 | 14 | 2 | 13402.39 | 21.96 |
| [`mlc.codegen.codegen_expr._emit_expr_is_type`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-expr-is-type-function-emit-expr-is-type-state-expr-mlc-codegen-codegen-expr-ml-359244241) | `mlc/codegen/codegen_expr.ml:1794` | 171 | 144 | 34 | 71 | 5 | 12345.17 | 18.07 |
| [`mlc.codegen.codegen_expr._emit_expr_member`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-expr-member-function-emit-expr-member-state-expr-mlc-codegen-codegen-expr-ml-911124331) | `mlc/codegen/codegen_expr.ml:2015` | 150 | 129 | 41 | 76 | 5 | 10906.25 | 18.74 |
| [`mlc.codegen.codegen_expr._emit_expr_num`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-expr-num-function-emit-expr-num-state-expr-mlc-codegen-codegen-expr-ml-1983028885) | `mlc/codegen/codegen_expr.ml:1748` | 20 | 14 | 4 | 4 | 2 | 754.81 | 50.93 |
| [`mlc.codegen.codegen_expr._emit_expr_safe_call`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-expr-safe-call-function-emit-expr-safe-call-state-expr-mlc-codegen-codegen-expr-ml-1000404641) | `mlc/codegen/codegen_expr.ml:1675` | 21 | 19 | 1 | 0 | 0 | 1369.66 | 49.06 |
| [`mlc.codegen.codegen_expr._emit_expr_safe_member`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-expr-safe-member-function-emit-expr-safe-member-state-expr-mlc-codegen-codegen-expr-ml-1807199021) | `mlc/codegen/codegen_expr.ml:1653` | 19 | 17 | 1 | 0 | 0 | 1143.38 | 50.56 |
| [`mlc.codegen.codegen_expr._emit_expr_str`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-expr-str-function-emit-expr-str-state-expr-mlc-codegen-codegen-expr-ml-1516643885) | `mlc/codegen/codegen_expr.ml:1778` | 6 | 4 | 1 | 0 | 0 | 244.27 | 66.17 |
| [`mlc.codegen.codegen_expr._emit_expr_type_guard`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-expr-type-guard-function-emit-expr-type-guard-state-expr-mlc-codegen-codegen-expr-ml-555431059) | `mlc/codegen/codegen_expr.ml:1699` | 44 | 43 | 10 | 12 | 2 | 3256.14 | 38.21 |
| [`mlc.codegen.codegen_expr._emit_expr_unary`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-expr-unary-function-emit-expr-unary-state-expr-mlc-codegen-codegen-expr-ml-1385790597) | `mlc/codegen/codegen_expr.ml:2366` | 95 | 90 | 4 | 3 | 1 | 7265.77 | 29.28 |
| [`mlc.codegen.codegen_expr._emit_expr_unsupported`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-expr-unsupported-function-emit-expr-unsupported-state-expr-k-mlc-codegen-codegen-expr-ml-1192983288) | `mlc/codegen/codegen_expr.ml:8140` | 29 | 28 | 10 | 10 | 2 | 1661.22 | 44.2 |
| [`mlc.codegen.codegen_expr._emit_expr_var`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-expr-var-function-emit-expr-var-state-expr-mlc-codegen-codegen-expr-ml-1466870729) | `mlc/codegen/codegen_expr.ml:1992` | 19 | 14 | 5 | 5 | 2 | 635 | 51.81 |
| [`mlc.codegen.codegen_expr._emit_expr_voidlit`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-expr-voidlit-function-emit-expr-voidlit-state-expr-mlc-codegen-codegen-expr-ml-950400181) | `mlc/codegen/codegen_expr.ml:1787` | 4 | 2 | 1 | 0 | 0 | 116 | 72.28 |
| [`mlc.codegen.codegen_expr._emit_extern_arg_to_native`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-extern-arg-to-native-function-emit-extern-arg-to-native-state-abi-ty-fail-label-pos-wbuf-label-mlc-codegen-codegen-expr-ml-211883222) | `mlc/codegen/codegen_expr.ml:8811` | 133 | 126 | 20 | 20 | 2 | 11504.21 | 22.55 |
| [`mlc.codegen.codegen_expr._emit_extern_call`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-extern-call-function-emit-extern-call-state-call-node-args-out-kind-out-name-pos-mlc-codegen-codegen-expr-ml-14918519) | `mlc/codegen/codegen_expr.ml:9241` | 297 | 257 | 91 | 166 | 4 | 22250.04 | 3.38 |
| [`mlc.codegen.codegen_expr._emit_extern_out_from_stack`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-extern-out-from-stack-function-emit-extern-out-from-stack-state-abi-ty-stack-off-pos-mlc-codegen-codegen-expr-ml-1941186936) | `mlc/codegen/codegen_expr.ml:9188` | 49 | 40 | 17 | 21 | 3 | 3522.72 | 36.01 |
| [`mlc.codegen.codegen_expr._emit_extern_ret_from_native`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-extern-ret-from-native-function-emit-extern-ret-from-native-state-abi-ty-fail-label-pos-mlc-codegen-codegen-expr-ml-1961782407) | `mlc/codegen/codegen_expr.ml:8958` | 198 | 188 | 17 | 16 | 1 | 19348.26 | 17.6 |
| [`mlc.codegen.codegen_expr._emit_generic_call_builtin_cases`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-generic-call-builtin-cases-function-emit-generic-call-builtin-cases-state-callee-raw-name-call-args-nargs-call-args-base-mlc-codegen-codegen-expr-ml-88256487) | `mlc/codegen/codegen_expr.ml:6254` | 711 | 658 | 78 | 113 | 3 | 75781.46 | 0 |
| [`mlc.codegen.codegen_expr._emit_indirect_callable_call`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-indirect-callable-call-function-emit-indirect-callable-call-state-cal-callee-raw-name-call-args-nargs-call-args-base-skip-call-args-eval-mlc-codegen-codegen-expr-ml-1902005148) | `mlc/codegen/codegen_expr.ml:7547` | 480 | 442 | 91 | 284 | 8 | 46296.53 | 0 |
| [`mlc.codegen.codegen_expr._emit_inline_call`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-inline-call-function-emit-inline-call-state-callee-args-mlc-codegen-codegen-expr-ml-2085079347) | `mlc/codegen/codegen_expr.ml:9759` | 174 | 171 | 53 | 71 | 3 | 11186.31 | 15.65 |
| [`mlc.codegen.codegen_expr._emit_known_float_binop`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-known-float-binop-function-emit-known-float-binop-state-expr-mlc-codegen-codegen-expr-ml-840624601) | `mlc/codegen/codegen_expr.ml:3025` | 71 | 70 | 19 | 30 | 4 | 6087.54 | 30.56 |
| [`mlc.codegen.codegen_expr._emit_known_int_binop`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-known-int-binop-function-emit-known-int-binop-state-op-lhs-ok-lhs-const-rhs-ok-rhs-const-mlc-codegen-codegen-expr-ml-1410301729) | `mlc/codegen/codegen_expr.ml:2801` | 212 | 177 | 64 | 116 | 4 | 13609.77 | 11.7 |
| [`mlc.codegen.codegen_expr._emit_make_error_const`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-make-error-const-function-emit-make-error-const-state-code-message-mlc-codegen-codegen-expr-ml-556272336) | `mlc/codegen/codegen_expr.ml:8708` | 24 | 23 | 2 | 1 | 1 | 1892.13 | 46.68 |
| [`mlc.codegen.codegen_expr._emit_native_callback_ret_lresult`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-native-callback-ret-lresult-function-emit-native-callback-ret-lresult-state-l-zero-l-done-mlc-codegen-codegen-expr-ml-1354735082) | `mlc/codegen/codegen_expr.ml:660` | 17 | 15 | 1 | 0 | 0 | 1225.9 | 51.4 |
| [`mlc.codegen.codegen_expr._emit_native_callback_wndproc`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-native-callback-wndproc-function-emit-native-callback-wndproc-state-fn-qn-mlc-codegen-codegen-expr-ml-1808900834) | `mlc/codegen/codegen_expr.ml:682` | 58 | 55 | 4 | 3 | 1 | 4444.23 | 35.45 |
| [`mlc.codegen.codegen_expr._emit_native_value_helper_call`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-native-value-helper-call-function-emit-native-value-helper-call-state-callee-raw-name-call-args-nargs-mlc-codegen-codegen-expr-ml-1858423327) | `mlc/codegen/codegen_expr.ml:7077` | 118 | 92 | 30 | 29 | 1 | 3675.33 | 25.8 |
| [`mlc.codegen.codegen_expr._emit_std_math_roundlike_intrinsic`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-std-math-roundlike-intrinsic-function-emit-std-math-roundlike-intrinsic-state-callee-name-arg-mlc-codegen-codegen-expr-ml-983075872) | `mlc/codegen/codegen_expr.ml:1413` | 68 | 61 | 9 | 8 | 1 | 4992.59 | 32.92 |
| [`mlc.codegen.codegen_expr._emit_struct_field_index_dispatch`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-struct-field-index-dispatch-function-emit-struct-field-index-dispatch-state-field-struct-id-reg-out-reg-ok-label-fail-label-tag-mlc-codegen-codegen-expr-ml-1144660167) | `mlc/codegen/codegen_expr.ml:1076` | 60 | 51 | 20 | 38 | 4 | 3136.02 | 34.04 |
| [`mlc.codegen.codegen_expr._expr_has_this`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-expr-has-this-function-expr-has-this-ex-mlc-codegen-codegen-expr-ml-920096598) | `mlc/codegen/codegen_expr.ml:8425` | 54 | 45 | 29 | 50 | 4 | 2449.39 | 34.58 |
| [`mlc.codegen.codegen_expr._expr_heap_cfg_bool`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-expr-heap-cfg-bool-function-expr-heap-cfg-bool-state-key-defaultv-mlc-codegen-codegen-expr-ml-1543416824) | `mlc/codegen/codegen_expr.ml:7202` | 11 | 9 | 10 | 12 | 3 | 625.13 | 56.36 |
| [`mlc.codegen.codegen_expr._expr_to_qualname`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-expr-to-qualname-function-expr-to-qualname-state-expr-mlc-codegen-codegen-expr-ml-757175447) | `mlc/codegen/codegen_expr.ml:1028` | 25 | 30 | 14 | 20 | 2 | 1448.6 | 45.49 |
| [`mlc.codegen.codegen_expr._extern_dll_base`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-extern-dll-base-function-extern-dll-base-dll-is-linux-mlc-codegen-codegen-expr-ml-205980928) | `mlc/codegen/codegen_expr.ml:8685` | 5 | 4 | 2 | 1 | 1 | 185.47 | 68.6 |
| [`mlc.codegen.codegen_expr._extern_iat_label`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-extern-iat-label-function-extern-iat-label-dll-sym-is-linux-mlc-codegen-codegen-expr-ml-590011265) | `mlc/codegen/codegen_expr.ml:8702` | 3 | 1 | 1 | 0 | 0 | 91.38 | 75.73 |
| [`mlc.codegen.codegen_expr._extern_sig_get`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-extern-sig-get-function-extern-sig-get-state-qname-mlc-codegen-codegen-expr-ml-218103376) | `mlc/codegen/codegen_expr.ml:1056` | 17 | 19 | 11 | 14 | 2 | 814.24 | 51.3 |
| [`mlc.codegen.codegen_expr._extern_struct_get`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-extern-struct-get-function-extern-struct-get-state-qname-mlc-codegen-codegen-expr-ml-689162256) | `mlc/codegen/codegen_expr.ml:1509` | 9 | 8 | 6 | 6 | 2 | 400.08 | 60.16 |
| [`mlc.codegen.codegen_expr._filter_expr_list_separator_artifacts`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-filter-expr-list-separator-artifacts-function-filter-expr-list-separator-artifacts-items-mlc-codegen-codegen-expr-ml-1341294507) | `mlc/codegen/codegen_expr.ml:1533` | 16 | 15 | 6 | 6 | 2 | 536.57 | 53.81 |
| [`mlc.codegen.codegen_expr._fn_uses_this`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-fn-uses-this-function-fn-uses-this-fn-node-mlc-codegen-codegen-expr-ml-1106344302) | `mlc/codegen/codegen_expr.ml:8624` | 15 | 12 | 7 | 9 | 3 | 505.32 | 54.47 |
| [`mlc.codegen.codegen_expr._function_wants_inline`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-function-wants-inline-function-function-wants-inline-fn-mlc-codegen-codegen-expr-ml-476633721) | `mlc/codegen/codegen_expr.ml:9686` | 30 | 35 | 27 | 32 | 3 | 2208 | 40.73 |
| [`mlc.codegen.codegen_expr._has_any_global_prefix`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-has-any-global-prefix-function-has-any-global-prefix-state-base-mlc-codegen-codegen-expr-ml-1707511383) | `mlc/codegen/codegen_expr.ml:472` | 87 | 61 | 41 | 90 | 5 | 3463.53 | 27.39 |
| [`mlc.codegen.codegen_expr._has_global_prefix`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-has-global-prefix-function-has-global-prefix-state-name-mlc-codegen-codegen-expr-ml-237481325) | `mlc/codegen/codegen_expr.ml:8374` | 7 | 8 | 5 | 4 | 1 | 351.75 | 63.06 |
| [`mlc.codegen.codegen_expr._inline_call_eligible`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-inline-call-eligible-function-inline-call-eligible-fn-mlc-codegen-codegen-expr-ml-1842661879) | `mlc/codegen/codegen_expr.ml:9744` | 12 | 15 | 11 | 10 | 1 | 803.46 | 54.64 |
| [`mlc.codegen.codegen_expr._inline_collect_expr_stats`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-inline-collect-expr-stats-function-inline-collect-expr-stats-ex-stats-mlc-codegen-codegen-expr-ml-986013263) | `mlc/codegen/codegen_expr.ml:9556` | 34 | 35 | 21 | 28 | 3 | 2215.84 | 40.34 |
| [`mlc.codegen.codegen_expr._inline_collect_stmt_list_stats`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-inline-collect-stmt-list-stats-function-inline-collect-stmt-list-stats-stmts-stats-mlc-codegen-codegen-expr-ml-2145714289) | `mlc/codegen/codegen_expr.ml:9593` | 8 | 6 | 4 | 3 | 1 | 286.62 | 62.56 |
| [`mlc.codegen.codegen_expr._inline_collect_stmt_stats`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-inline-collect-stmt-stats-function-inline-collect-stmt-stats-st-stats-mlc-codegen-codegen-expr-ml-217400541) | `mlc/codegen/codegen_expr.ml:9604` | 79 | 75 | 39 | 62 | 5 | 5288.51 | 27.29 |
| [`mlc.codegen.codegen_expr._inline_declared_type_fact`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-inline-declared-type-fact-function-inline-declared-type-fact-state-raw-type-mlc-codegen-codegen-expr-ml-1670431225) | `mlc/codegen/codegen_expr.ml:9730` | 11 | 15 | 17 | 16 | 1 | 682.23 | 55.15 |
| [`mlc.codegen.codegen_expr._intflow_name_has`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-intflow-name-has-function-intflow-name-has-arr-name-mlc-codegen-codegen-expr-ml-326076909) | `mlc/codegen/codegen_expr.ml:2466` | 8 | 8 | 6 | 6 | 2 | 393.46 | 61.32 |
| [`mlc.codegen.codegen_expr._is_current_localish_name`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-is-current-localish-name-function-is-current-localish-name-state-name-mlc-codegen-codegen-expr-ml-1422143) | `mlc/codegen/codegen_expr.ml:826` | 6 | 6 | 4 | 3 | 1 | 218.26 | 66.11 |
| [`mlc.codegen.codegen_expr._is_expr_list_separator_artifact`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-is-expr-list-separator-artifact-function-is-expr-list-separator-artifact-ex-mlc-codegen-codegen-expr-ml-1185540350) | `mlc/codegen/codegen_expr.ml:1521` | 9 | 10 | 6 | 5 | 1 | 402.36 | 60.14 |
| [`mlc.codegen.codegen_expr._is_instance_method_qname`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-is-instance-method-qname-function-is-instance-method-qname-state-qname-mlc-codegen-codegen-expr-ml-1989414416) | `mlc/codegen/codegen_expr.ml:8384` | 38 | 35 | 22 | 47 | 5 | 1697.69 | 39.96 |
| [`mlc.codegen.codegen_expr._is_int_no_bool`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-is-int-no-bool-inline-function-is-int-no-bool-v-mlc-codegen-codegen-expr-ml-1740716338) | `mlc/codegen/codegen_expr.ml:292` | 3 | 1 | 1 | 0 | 0 | 51.89 | 77.45 |
| [`mlc.codegen.codegen_expr._is_number_no_bool`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-is-number-no-bool-inline-function-is-number-no-bool-v-mlc-codegen-codegen-expr-ml-617520384) | `mlc/codegen/codegen_expr.ml:284` | 5 | 4 | 3 | 2 | 1 | 123.19 | 69.71 |
| [`mlc.codegen.codegen_expr._member_base_alias_shadowed`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-member-base-alias-shadowed-function-member-base-alias-shadowed-state-expr-mlc-codegen-codegen-expr-ml-530020817) | `mlc/codegen/codegen_expr.ml:853` | 19 | 20 | 10 | 11 | 2 | 868.16 | 50.18 |
| [`mlc.codegen.codegen_expr._method_map_get`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-method-map-get-inline-function-method-map-get-map-arr-method-name-mlc-codegen-codegen-expr-ml-1123945021) | `mlc/codegen/codegen_expr.ml:430` | 18 | 14 | 11 | 13 | 2 | 792.67 | 50.84 |
| [`mlc.codegen.codegen_expr._named_array_get`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-named-array-get-inline-function-named-array-get-arr-key-mlc-codegen-codegen-expr-ml-1881086926) | `mlc/codegen/codegen_expr.ml:314` | 13 | 9 | 9 | 10 | 2 | 507.8 | 55.54 |
| [`mlc.codegen.codegen_expr._named_int_get`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-named-int-get-inline-function-named-int-get-arr-key-defaultv-mlc-codegen-codegen-expr-ml-696397625) | `mlc/codegen/codegen_expr.ml:330` | 15 | 13 | 11 | 16 | 3 | 677.23 | 53.04 |
| [`mlc.codegen.codegen_expr._native_callback_resolve_user_fn`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-native-callback-resolve-user-fn-function-native-callback-resolve-user-fn-state-ex-mlc-codegen-codegen-expr-ml-2104517683) | `mlc/codegen/codegen_expr.ml:642` | 15 | 15 | 8 | 12 | 3 | 651.18 | 53.57 |
| [`mlc.codegen.codegen_expr._next_lid`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-next-lid-inline-function-next-lid-state-mlc-codegen-codegen-expr-ml-1245044263) | `mlc/codegen/codegen_expr.ml:634` | 5 | 3 | 1 | 0 | 0 | 91.38 | 70.89 |
| [`mlc.codegen.codegen_expr._normalize_declared_call_args`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-normalize-declared-call-args-function-normalize-declared-call-args-expr-fn-implicit-mlc-codegen-codegen-expr-ml-715104241) | `mlc/codegen/codegen_expr.ml:184` | 84 | 85 | 38 | 90 | 5 | 4700.1 | 27.2 |
| [`mlc.codegen.codegen_expr._opt_const_nonnegative_int`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-opt-const-nonnegative-int-function-opt-const-nonnegative-int-state-ex-mlc-codegen-codegen-expr-ml-1783933275) | `mlc/codegen/codegen_expr.ml:2486` | 4 | 2 | 1 | 0 | 0 | 191.76 | 70.75 |
| [`mlc.codegen.codegen_expr._opt_const_nonzero_number`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-opt-const-nonzero-number-function-opt-const-nonzero-number-state-ex-mlc-codegen-codegen-expr-ml-692147035) | `mlc/codegen/codegen_expr.ml:2477` | 6 | 5 | 3 | 2 | 1 | 283.63 | 65.45 |
| [`mlc.codegen.codegen_expr._opt_emit_const_value`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-opt-emit-const-value-function-opt-emit-const-value-state-value-mlc-codegen-codegen-expr-ml-1769433631) | `mlc/codegen/codegen_expr.ml:9964` | 30 | 22 | 6 | 6 | 2 | 1141.16 | 45.56 |
| [`mlc.codegen.codegen_expr._opt_emit_known_index`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-opt-emit-known-index-function-opt-emit-known-index-state-expr-plan-mlc-codegen-codegen-expr-ml-370978738) | `mlc/codegen/codegen_expr.ml:2700` | 82 | 68 | 16 | 16 | 2 | 5866.75 | 29.71 |
| [`mlc.codegen.codegen_expr._opt_expr_known_int`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-opt-expr-known-int-function-opt-expr-known-int-state-ex-mlc-codegen-codegen-expr-ml-1139113643) | `mlc/codegen/codegen_expr.ml:2493` | 32 | 37 | 26 | 33 | 2 | 2097.06 | 40.41 |
| [`mlc.codegen.codegen_expr._opt_expr_known_type`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-opt-expr-known-type-function-opt-expr-known-type-state-ex-mlc-codegen-codegen-expr-ml-1657401667) | `mlc/codegen/codegen_expr.ml:2571` | 67 | 86 | 82 | 104 | 2 | 5493.64 | 22.95 |
| [`mlc.codegen.codegen_expr._opt_known_index_plan`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-opt-known-index-plan-function-opt-known-index-plan-state-ex-mlc-codegen-codegen-expr-ml-274133085) | `mlc/codegen/codegen_expr.ml:2652` | 44 | 41 | 30 | 51 | 7 | 2609.88 | 36.19 |
| [`mlc.codegen.codegen_expr._opt_truthy`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-opt-truthy-inline-function-opt-truthy-v-mlc-codegen-codegen-expr-ml-510391714) | `mlc/codegen/codegen_expr.ml:271` | 10 | 14 | 8 | 7 | 1 | 423.05 | 58.72 |
| [`mlc.codegen.codegen_expr._opt_try_const_immediate_encoded`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-opt-try-const-immediate-encoded-function-opt-try-const-immediate-encoded-state-expr-mlc-codegen-codegen-expr-ml-2129065573) | `mlc/codegen/codegen_expr.ml:1316` | 14 | 14 | 8 | 9 | 2 | 636.03 | 54.29 |
| [`mlc.codegen.codegen_expr._opt_try_const_value`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-opt-try-const-value-function-opt-try-const-value-state-ex-mlc-codegen-codegen-expr-ml-2030503603) | `mlc/codegen/codegen_expr.ml:9958` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.codegen.codegen_expr._opt_try_known_type_label`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-opt-try-known-type-label-function-opt-try-known-type-label-state-expr-detailed-mlc-codegen-codegen-expr-ml-385000701) | `mlc/codegen/codegen_expr.ml:1348` | 36 | 42 | 20 | 34 | 4 | 1650.12 | 40.83 |
| [`mlc.codegen.codegen_expr._opt_try_pure_const_array_len`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-opt-try-pure-const-array-len-function-opt-try-pure-const-array-len-state-expr-mlc-codegen-codegen-expr-ml-2032552391) | `mlc/codegen/codegen_expr.ml:1333` | 12 | 11 | 6 | 6 | 2 | 502.67 | 56.74 |
| [`mlc.codegen.codegen_expr._opt_type_base`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-opt-type-base-inline-function-opt-type-base-type-name-mlc-codegen-codegen-expr-ml-347057446) | `mlc/codegen/codegen_expr.ml:2528` | 7 | 6 | 5 | 5 | 2 | 297.25 | 63.58 |
| [`mlc.codegen.codegen_expr._opt_type_exact_length`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-opt-type-exact-length-function-opt-type-exact-length-type-name-mlc-codegen-codegen-expr-ml-513702245) | `mlc/codegen/codegen_expr.ml:2538` | 14 | 17 | 10 | 10 | 2 | 748.82 | 53.53 |
| [`mlc.codegen.codegen_expr._opt_type_fact_get`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-opt-type-fact-get-function-opt-type-fact-get-items-name-mlc-codegen-codegen-expr-ml-857455814) | `mlc/codegen/codegen_expr.ml:2555` | 13 | 12 | 10 | 11 | 2 | 650.74 | 54.66 |
| [`mlc.codegen.codegen_expr._opt_type_query_can_elide_evaluation`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-opt-type-query-can-elide-evaluation-function-opt-type-query-can-elide-evaluation-ex-mlc-codegen-codegen-expr-ml-81004822) | `mlc/codegen/codegen_expr.ml:2644` | 5 | 4 | 2 | 1 | 1 | 217.13 | 68.12 |
| [`mlc.codegen.codegen_expr._pool_collect_suffix`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-pool-collect-suffix-function-pool-collect-suffix-pool-prefix-suffix-matches-mlc-codegen-codegen-expr-ml-241897643) | `mlc/codegen/codegen_expr.ml:894` | 23 | 18 | 12 | 16 | 3 | 1043.73 | 47.55 |
| [`mlc.codegen.codegen_expr._pool_has_key`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-pool-has-key-function-pool-has-key-pool-key-mlc-codegen-codegen-expr-ml-1833225956) | `mlc/codegen/codegen_expr.ml:877` | 10 | 8 | 7 | 9 | 3 | 408.6 | 58.96 |
| [`mlc.codegen.codegen_expr._positive_power_of_two_shift`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-positive-power-of-two-shift-function-positive-power-of-two-shift-value-mlc-codegen-codegen-expr-ml-1591859408) | `mlc/codegen/codegen_expr.ml:2787` | 11 | 10 | 5 | 5 | 2 | 287.92 | 59.39 |
| [`mlc.codegen.codegen_expr._qname_exists`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-qname-exists-function-qname-exists-state-qname-mlc-codegen-codegen-expr-ml-11489112) | `mlc/codegen/codegen_expr.ml:8362` | 9 | 12 | 7 | 6 | 1 | 559.62 | 59 |
| [`mlc.codegen.codegen_expr._qname_of`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-qname-of-function-qname-of-state-ex-mlc-codegen-codegen-expr-ml-265331533) | `mlc/codegen/codegen_expr.ml:8193` | 111 | 97 | 58 | 110 | 4 | 5628.32 | 21.32 |
| [`mlc.codegen.codegen_expr._qname_parts`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-qname-parts-function-qname-parts-state-ex-mlc-codegen-codegen-expr-ml-617631291) | `mlc/codegen/codegen_expr.ml:8185` | 5 | 4 | 2 | 1 | 1 | 160.54 | 69.04 |
| [`mlc.codegen.codegen_expr._qname_parts_any`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-qname-parts-any-function-qname-parts-any-expr-mlc-codegen-codegen-expr-ml-1463872372) | `mlc/codegen/codegen_expr.ml:1389` | 19 | 20 | 9 | 12 | 2 | 840.75 | 50.42 |
| [`mlc.codegen.codegen_expr._qname_with_prefixes`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-qname-with-prefixes-function-qname-with-prefixes-state-qname-mlc-codegen-codegen-expr-ml-130025352) | `mlc/codegen/codegen_expr.ml:8322` | 29 | 27 | 13 | 19 | 3 | 1239.86 | 44.69 |
| [`mlc.codegen.codegen_expr._qualify_dotted`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-qualify-dotted-function-qualify-dotted-state-name-mlc-codegen-codegen-expr-ml-2130487099) | `mlc/codegen/codegen_expr.ml:8356` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.codegen.codegen_expr._qualify_identifier`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-qualify-identifier-function-qualify-identifier-state-name-mlc-codegen-codegen-expr-ml-1704406085) | `mlc/codegen/codegen_expr.ml:922` | 83 | 78 | 31 | 49 | 3 | 4901.35 | 28.13 |
| [`mlc.codegen.codegen_expr._resolve_const_value`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-resolve-const-value-function-resolve-const-value-state-name-mlc-codegen-codegen-expr-ml-1736193677) | `mlc/codegen/codegen_expr.ml:1146` | 13 | 8 | 4 | 3 | 1 | 366.13 | 57.21 |
| [`mlc.codegen.codegen_expr._state_enum_id_get`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-state-enum-id-get-inline-function-state-enum-id-get-state-key-defaultv-mlc-codegen-codegen-expr-ml-1848184787) | `mlc/codegen/codegen_expr.ml:358` | 7 | 5 | 3 | 3 | 2 | 283.28 | 63.99 |
| [`mlc.codegen.codegen_expr._state_enum_variants_get`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-state-enum-variants-get-inline-function-state-enum-variants-get-state-key-mlc-codegen-codegen-expr-ml-562053330) | `mlc/codegen/codegen_expr.ml:395` | 3 | 1 | 1 | 0 | 0 | 87.57 | 75.86 |
| [`mlc.codegen.codegen_expr._state_named_array_get`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-state-named-array-get-inline-function-state-named-array-get-index-map-arr-key-mlc-codegen-codegen-expr-ml-1817475941) | `mlc/codegen/codegen_expr.ml:368` | 6 | 3 | 2 | 1 | 1 | 175.69 | 67.04 |
| [`mlc.codegen.codegen_expr._state_struct_field_types_get`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-state-struct-field-types-get-inline-function-state-struct-field-types-get-state-key-mlc-codegen-codegen-expr-ml-1860069308) | `mlc/codegen/codegen_expr.ml:383` | 3 | 1 | 1 | 0 | 0 | 79.95 | 76.13 |
| [`mlc.codegen.codegen_expr._state_struct_fields_get`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-state-struct-fields-get-inline-function-state-struct-fields-get-state-key-mlc-codegen-codegen-expr-ml-1661443136) | `mlc/codegen/codegen_expr.ml:377` | 3 | 1 | 1 | 0 | 0 | 87.57 | 75.86 |
| [`mlc.codegen.codegen_expr._state_struct_id_get`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-state-struct-id-get-inline-function-state-struct-id-get-state-key-defaultv-mlc-codegen-codegen-expr-ml-607185971) | `mlc/codegen/codegen_expr.ml:348` | 7 | 5 | 3 | 3 | 2 | 283.28 | 63.99 |
| [`mlc.codegen.codegen_expr._state_struct_methods_get`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-state-struct-methods-get-inline-function-state-struct-methods-get-state-key-mlc-codegen-codegen-expr-ml-1640907056) | `mlc/codegen/codegen_expr.ml:389` | 3 | 1 | 1 | 0 | 0 | 87.57 | 75.86 |
| [`mlc.codegen.codegen_expr._state_struct_static_methods_get`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-state-struct-static-methods-get-inline-function-state-struct-static-methods-get-state-key-mlc-codegen-codegen-expr-ml-644259028) | `mlc/codegen/codegen_expr.ml:401` | 3 | 1 | 1 | 0 | 0 | 87.57 | 75.86 |
| [`mlc.codegen.codegen_expr._stmt_has_this`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-stmt-has-this-function-stmt-has-this-st-mlc-codegen-codegen-expr-ml-1440660948) | `mlc/codegen/codegen_expr.ml:8482` | 127 | 116 | 88 | 219 | 7 | 6821.16 | 15.43 |
| [`mlc.codegen.codegen_expr._strpair_get`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-strpair-get-inline-function-strpair-get-arr-key-mlc-codegen-codegen-expr-ml-1442572622) | `mlc/codegen/codegen_expr.ml:407` | 20 | 18 | 13 | 19 | 3 | 872.8 | 49.28 |
| [`mlc.codegen.codegen_expr._try_const_bin`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-try-const-bin-function-try-const-bin-op-lv-rv-mlc-codegen-codegen-expr-ml-847450350) | `mlc/codegen/codegen_expr.ml:1162` | 67 | 61 | 46 | 65 | 3 | 3394.74 | 29.26 |
| [`mlc.codegen.codegen_expr._try_emit_direct_extern_call`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-try-emit-direct-extern-call-function-try-emit-direct-extern-call-state-cal-callee-raw-name-call-args-nargs-mlc-codegen-codegen-expr-ml-1409846107) | `mlc/codegen/codegen_expr.ml:7507` | 35 | 30 | 15 | 29 | 4 | 1771.45 | 41.56 |
| [`mlc.codegen.codegen_expr._user_function_get`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-user-function-get-function-user-function-get-state-qname-mlc-codegen-codegen-expr-ml-1226066976) | `mlc/codegen/codegen_expr.ml:451` | 18 | 17 | 17 | 21 | 3 | 1065.42 | 49.13 |
| [`mlc.codegen.codegen_expr._variadic_expr_safe`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-variadic-expr-safe-function-variadic-expr-safe-ex-name-allow-direct-mlc-codegen-codegen-expr-ml-1955139858) | `mlc/codegen/codegen_expr.ml:78` | 44 | 50 | 34 | 50 | 4 | 3096 | 35.13 |
| [`mlc.codegen.codegen_expr._variadic_is_direct_var`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-variadic-is-direct-var-function-variadic-is-direct-var-ex-name-mlc-codegen-codegen-expr-ml-1449843501) | `mlc/codegen/codegen_expr.ml:72` | 3 | 1 | 1 | 0 | 0 | 154.29 | 74.13 |
| [`mlc.codegen.codegen_expr._variadic_param_stack_safe`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-variadic-param-stack-safe-function-variadic-param-stack-safe-fn-mlc-codegen-codegen-expr-ml-1579967441) | `mlc/codegen/codegen_expr.ml:174` | 7 | 7 | 6 | 5 | 1 | 415 | 62.43 |
| [`mlc.codegen.codegen_expr._variadic_stmts_safe`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-variadic-stmts-safe-function-variadic-stmts-safe-body-name-mlc-codegen-codegen-expr-ml-547146716) | `mlc/codegen/codegen_expr.ml:127` | 44 | 42 | 50 | 96 | 5 | 4072.15 | 32.15 |
| [`mlc.codegen.codegen_expr.cg_emit_expr`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-cg-emit-expr-function-cg-emit-expr-state-expr-mlc-codegen-codegen-expr-ml-1314099505) | `mlc/codegen/codegen_expr.ml:1553` | 61 | 48 | 23 | 23 | 2 | 2443.29 | 34.24 |
| [`mlc.codegen.codegen_expr.cg_expr_try_const_decl_value`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-cg-expr-try-const-decl-value-function-cg-expr-try-const-decl-value-state-expr-mlc-codegen-codegen-expr-ml-579064845) | `mlc/codegen/codegen_expr.ml:1502` | 3 | 1 | 1 | 0 | 0 | 62.27 | 76.89 |
| [`mlc.codegen.codegen_expr.cg_expr_try_const_value`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-cg-expr-try-const-value-function-cg-expr-try-const-value-state-expr-mlc-codegen-codegen-expr-ml-300093649) | `mlc/codegen/codegen_expr.ml:1494` | 3 | 1 | 1 | 0 | 0 | 62.27 | 76.89 |
| [`mlc.codegen.codegen_expr.emit_expr`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-expr-function-emit-expr-state-ex-mlc-codegen-codegen-expr-ml-1588049625) | `mlc/codegen/codegen_expr.ml:10017` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.codegen.codegen_expr.emit_extern_stubs`](File-mlc-codegen-codegen-expr-ml-59843844.md#function-function-mlc-codegen-codegen-expr-emit-extern-stubs-function-emit-extern-stubs-state-mlc-codegen-codegen-expr-ml-162750204) | `mlc/codegen/codegen_expr.ml:10023` | 152 | 144 | 49 | 122 | 5 | 11323.42 | 17.43 |
| [`mlc.codegen.codegen_memory.__init__`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-init-function-init-state-mlc-codegen-codegen-memory-ml-1566450084) | `mlc/codegen/codegen_memory.ml:203` | 3 | 1 | 1 | 0 | 0 | 25.27 | 79.64 |
| [`mlc.codegen.codegen_memory._append_unique`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-append-unique-function-append-unique-values-value-mlc-codegen-codegen-memory-ml-484259326) | `mlc/codegen/codegen_memory.ml:96` | 8 | 8 | 5 | 5 | 2 | 323.33 | 62.05 |
| [`mlc.codegen.codegen_memory._configured_gc_limits`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-configured-gc-limits-function-configured-gc-limits-state-mlc-codegen-codegen-memory-ml-968270226) | `mlc/codegen/codegen_memory.ml:194` | 6 | 4 | 1 | 0 | 0 | 124 | 68.23 |
| [`mlc.codegen.codegen_memory._emit_mov_rax_i64_max`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-emit-mov-rax-i64-max-function-emit-mov-rax-i64-max-state-mlc-codegen-codegen-memory-ml-890611964) | `mlc/codegen/codegen_memory.ml:71` | 11 | 8 | 2 | 1 | 1 | 413.68 | 58.69 |
| [`mlc.codegen.codegen_memory._ensure_data_u64`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-ensure-data-u64-function-ensure-data-u64-db-name-value-mlc-codegen-codegen-memory-ml-426078861) | `mlc/codegen/codegen_memory.ml:107` | 4 | 3 | 2 | 1 | 1 | 144 | 71.48 |
| [`mlc.codegen.codegen_memory._ensure_gc_limit_data`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-ensure-gc-limit-data-function-ensure-gc-limit-data-db-name-value-mlc-codegen-codegen-memory-ml-1144680223) | `mlc/codegen/codegen_memory.ml:114` | 7 | 5 | 3 | 2 | 1 | 334.7 | 63.48 |
| [`mlc.codegen.codegen_memory._ensure_rdata_str`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-ensure-rdata-str-function-ensure-rdata-str-rb-name-text-mlc-codegen-codegen-memory-ml-564754933) | `mlc/codegen/codegen_memory.ml:124` | 4 | 3 | 2 | 1 | 1 | 155.32 | 71.25 |
| [`mlc.codegen.codegen_memory._has_label`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-has-label-function-has-label-labels-name-mlc-codegen-codegen-memory-ml-36410265) | `mlc/codegen/codegen_memory.ml:85` | 8 | 7 | 6 | 6 | 2 | 337.97 | 61.79 |
| [`mlc.codegen.codegen_memory._heap_cfg_get_any`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-heap-cfg-get-any-function-heap-cfg-get-any-state-key-mlc-codegen-codegen-memory-ml-462023885) | `mlc/codegen/codegen_memory.ml:152` | 15 | 12 | 12 | 13 | 2 | 703.28 | 52.8 |
| [`mlc.codegen.codegen_memory._heap_cfg_get_bool`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-heap-cfg-get-bool-function-heap-cfg-get-bool-state-key-defaultv-mlc-codegen-codegen-memory-ml-1588187098) | `mlc/codegen/codegen_memory.ml:178` | 5 | 4 | 2 | 1 | 1 | 137.61 | 69.51 |
| [`mlc.codegen.codegen_memory._heap_cfg_get_int`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-heap-cfg-get-int-function-heap-cfg-get-int-state-key-defaultv-mlc-codegen-codegen-memory-ml-602328160) | `mlc/codegen/codegen_memory.ml:170` | 5 | 4 | 2 | 1 | 1 | 137.61 | 69.51 |
| [`mlc.codegen.codegen_memory._heap_cfg_has_any`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-heap-cfg-has-any-function-heap-cfg-has-any-state-mlc-codegen-codegen-memory-ml-907394156) | `mlc/codegen/codegen_memory.ml:186` | 5 | 4 | 2 | 1 | 1 | 171.3 | 68.84 |
| [`mlc.codegen.codegen_memory._mark_bitmap_bytes_for_heap_bytes`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-mark-bitmap-bytes-for-heap-bytes-function-mark-bitmap-bytes-for-heap-bytes-heap-bytes-mlc-codegen-codegen-memory-ml-2018108057) | `mlc/codegen/codegen_memory.ml:131` | 4 | 3 | 2 | 1 | 1 | 100 | 72.59 |
| [`mlc.codegen.codegen_memory._rlabel_len`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-rlabel-len-function-rlabel-len-labels-name-mlc-codegen-codegen-memory-ml-1815284927) | `mlc/codegen/codegen_memory.ml:138` | 11 | 9 | 7 | 9 | 3 | 418.68 | 57.98 |
| [`mlc.codegen.codegen_memory.cg_memory_init`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-cg-memory-init-function-cg-memory-init-state-mlc-codegen-codegen-memory-ml-2121417204) | `mlc/codegen/codegen_memory.ml:2268` | 3 | 1 | 1 | 0 | 0 | 36 | 78.56 |
| [`mlc.codegen.codegen_memory.emit_alloc_function`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-emit-alloc-function-function-emit-alloc-function-state-mlc-codegen-codegen-memory-ml-1374636448) | `mlc/codegen/codegen_memory.ml:545` | 545 | 543 | 11 | 10 | 1 | 61909.83 | 5.28 |
| [`mlc.codegen.codegen_memory.emit_decref_function`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-emit-decref-function-function-emit-decref-function-state-mlc-codegen-codegen-memory-ml-848943548) | `mlc/codegen/codegen_memory.ml:1852` | 5 | 3 | 1 | 0 | 0 | 136.74 | 69.66 |
| [`mlc.codegen.codegen_memory.emit_gc_clear_root_slots`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-emit-gc-clear-root-slots-function-emit-gc-clear-root-slots-state-root-base-root-top-mlc-codegen-codegen-memory-ml-1049458376) | `mlc/codegen/codegen_memory.ml:458` | 32 | 29 | 4 | 4 | 2 | 2390.09 | 42.97 |
| [`mlc.codegen.codegen_memory.emit_gc_collect_function`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-emit-gc-collect-function-function-emit-gc-collect-function-state-mlc-codegen-codegen-memory-ml-2043781588) | `mlc/codegen/codegen_memory.ml:1190` | 549 | 534 | 18 | 21 | 3 | 63806.07 | 4.17 |
| [`mlc.codegen.codegen_memory.emit_gc_init_globals`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-emit-gc-init-globals-function-emit-gc-init-globals-state-disable-periodic-mlc-codegen-codegen-memory-ml-1041162440) | `mlc/codegen/codegen_memory.ml:427` | 22 | 18 | 3 | 2 | 1 | 1107.93 | 49 |
| [`mlc.codegen.codegen_memory.emit_gc_pop_root_frame`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-emit-gc-pop-root-frame-function-emit-gc-pop-root-frame-state-root-rec-off-mlc-codegen-codegen-memory-ml-206505697) | `mlc/codegen/codegen_memory.ml:531` | 11 | 7 | 2 | 1 | 1 | 432.36 | 58.56 |
| [`mlc.codegen.codegen_memory.emit_gc_push_root_frame`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-emit-gc-push-root-frame-function-emit-gc-push-root-frame-state-root-rec-off-root-base-root-top-mlc-codegen-codegen-memory-ml-545736239) | `mlc/codegen/codegen_memory.ml:500` | 23 | 18 | 4 | 3 | 1 | 1218.66 | 48.15 |
| [`mlc.codegen.codegen_memory.emit_heap_bytes_committed_function`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-emit-heap-bytes-committed-function-function-emit-heap-bytes-committed-function-state-mlc-codegen-codegen-memory-ml-597269876) | `mlc/codegen/codegen_memory.ml:1948` | 26 | 21 | 4 | 3 | 1 | 1314.52 | 46.76 |
| [`mlc.codegen.codegen_memory.emit_heap_bytes_reserved_function`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-emit-heap-bytes-reserved-function-function-emit-heap-bytes-reserved-function-state-mlc-codegen-codegen-memory-ml-1925633220) | `mlc/codegen/codegen_memory.ml:1977` | 26 | 21 | 4 | 3 | 1 | 1314.52 | 46.76 |
| [`mlc.codegen.codegen_memory.emit_heap_bytes_used_function`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-emit-heap-bytes-used-function-function-emit-heap-bytes-used-function-state-mlc-codegen-codegen-memory-ml-216011958) | `mlc/codegen/codegen_memory.ml:1919` | 26 | 21 | 4 | 3 | 1 | 1301.89 | 46.79 |
| [`mlc.codegen.codegen_memory.emit_heap_count_function`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-emit-heap-count-function-function-emit-heap-count-function-state-mlc-codegen-codegen-memory-ml-2002706044) | `mlc/codegen/codegen_memory.ml:1860` | 48 | 43 | 4 | 3 | 1 | 3287.82 | 38.16 |
| [`mlc.codegen.codegen_memory.emit_heap_free_blocks_function`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-emit-heap-free-blocks-function-function-emit-heap-free-blocks-function-state-mlc-codegen-codegen-memory-ml-439642176) | `mlc/codegen/codegen_memory.ml:2006` | 54 | 49 | 4 | 3 | 1 | 3911.2 | 36.52 |
| [`mlc.codegen.codegen_memory.emit_heap_free_bytes_function`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-emit-heap-free-bytes-function-function-emit-heap-free-bytes-function-state-mlc-codegen-codegen-memory-ml-1853574576) | `mlc/codegen/codegen_memory.ml:2076` | 56 | 51 | 4 | 3 | 1 | 4173.51 | 35.98 |
| [`mlc.codegen.codegen_memory.emit_heap_grow_function`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-emit-heap-grow-function-function-emit-heap-grow-function-state-mlc-codegen-codegen-memory-ml-759712978) | `mlc/codegen/codegen_memory.ml:2148` | 93 | 92 | 3 | 2 | 1 | 8248.54 | 29.23 |
| [`mlc.codegen.codegen_memory.emit_heap_init`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-emit-heap-init-function-emit-heap-init-state-heap-size-mlc-codegen-codegen-memory-ml-438456146) | `mlc/codegen/codegen_memory.ml:267` | 131 | 125 | 16 | 16 | 2 | 10050.69 | 23.64 |
| [`mlc.codegen.codegen_memory.emit_incref_function`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-emit-incref-function-function-emit-incref-function-state-mlc-codegen-codegen-memory-ml-2119130748) | `mlc/codegen/codegen_memory.ml:1844` | 5 | 3 | 1 | 0 | 0 | 136.74 | 69.66 |
| [`mlc.codegen.codegen_memory.ensure_gc_data`](File-mlc-codegen-codegen-memory-ml-2136639668.md#function-function-mlc-codegen-codegen-memory-ensure-gc-data-function-ensure-gc-data-state-mlc-codegen-codegen-memory-ml-2102654204) | `mlc/codegen/codegen_memory.ml:209` | 44 | 38 | 7 | 6 | 1 | 1998.67 | 40.1 |
| [`mlc.codegen.codegen_runtime._emit_build_args_linux`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-build-args-linux-function-emit-build-args-linux-state-mlc-codegen-codegen-runtime-ml-745727140) | `mlc/codegen/codegen_runtime.ml:3197` | 79 | 77 | 1 | 0 | 0 | 7824.7 | 31.21 |
| [`mlc.codegen.codegen_runtime._emit_force_xmm0_to_float_value`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-force-xmm0-to-float-value-function-emit-force-xmm0-to-float-value-state-mlc-codegen-codegen-runtime-ml-26923332) | `mlc/codegen/codegen_runtime.ml:155` | 19 | 17 | 1 | 0 | 0 | 1144.21 | 50.56 |
| [`mlc.codegen.codegen_runtime._emit_mov_rax_i64_max`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-mov-rax-i64-max-function-emit-mov-rax-i64-max-state-mlc-codegen-codegen-runtime-ml-2102702944) | `mlc/codegen/codegen_runtime.ml:46` | 11 | 8 | 2 | 1 | 1 | 413.68 | 58.69 |
| [`mlc.codegen.codegen_runtime._emit_mov_rax_u64_hi_lo`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-mov-rax-u64-hi-lo-function-emit-mov-rax-u64-hi-lo-state-hi32-lo32-mlc-codegen-codegen-runtime-ml-1071085340) | `mlc/codegen/codegen_runtime.ml:34` | 9 | 6 | 2 | 1 | 1 | 385.44 | 60.81 |
| [`mlc.codegen.codegen_runtime._emit_native_crc_wrapper`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-native-crc-wrapper-function-emit-native-crc-wrapper-state-label-raw-label-mlc-codegen-codegen-runtime-ml-65970373) | `mlc/codegen/codegen_runtime.ml:940` | 61 | 59 | 1 | 0 | 0 | 5759.18 | 34.59 |
| [`mlc.codegen.codegen_runtime._emit_normalize_xmm0_to_value`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-normalize-xmm0-to-value-function-emit-normalize-xmm0-to-value-state-mlc-codegen-codegen-runtime-ml-2037712558) | `mlc/codegen/codegen_runtime.ml:116` | 31 | 29 | 1 | 0 | 0 | 2116.45 | 44.05 |
| [`mlc.codegen.codegen_runtime._emit_to_double_xmm`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-to-double-xmm-function-emit-to-double-xmm-state-xmm-fail-label-mlc-codegen-codegen-runtime-ml-1880184763) | `mlc/codegen/codegen_runtime.ml:60` | 48 | 40 | 7 | 6 | 1 | 3352.21 | 37.7 |
| [`mlc.codegen.codegen_runtime._ensure_byte_search_table`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-ensure-byte-search-table-function-ensure-byte-search-table-state-mlc-codegen-codegen-runtime-ml-19967732) | `mlc/codegen/codegen_runtime.ml:502` | 11 | 8 | 4 | 4 | 2 | 385 | 58.64 |
| [`mlc.codegen.codegen_runtime._ensure_crc_tables`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-ensure-crc-tables-function-ensure-crc-tables-state-mlc-codegen-codegen-runtime-ml-1516024476) | `mlc/codegen/codegen_runtime.ml:839` | 9 | 5 | 3 | 2 | 1 | 343.38 | 61.03 |
| [`mlc.codegen.codegen_runtime._make_crc_table`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-make-crc-table-function-make-crc-table-poly-mlc-codegen-codegen-runtime-ml-672147517) | `mlc/codegen/codegen_runtime.ml:821` | 15 | 13 | 4 | 6 | 3 | 622.67 | 54.24 |
| [`mlc.codegen.codegen_runtime.cg_runtime_init`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-cg-runtime-init-function-cg-runtime-init-state-mlc-codegen-codegen-runtime-ml-2039830360) | `mlc/codegen/codegen_runtime.ml:28` | 3 | 1 | 1 | 0 | 0 | 25.27 | 79.64 |
| [`mlc.codegen.codegen_runtime.emit_build_args_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-build-args-function-function-emit-build-args-function-state-mlc-codegen-codegen-runtime-ml-534829940) | `mlc/codegen/codegen_runtime.ml:3285` | 126 | 125 | 2 | 1 | 1 | 13212.88 | 25.06 |
| [`mlc.codegen.codegen_runtime.emit_builtin_copyArray_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-builtin-copyarray-function-function-emit-builtin-copyarray-function-state-mlc-codegen-codegen-runtime-ml-1370754338) | `mlc/codegen/codegen_runtime.ml:3563` | 103 | 101 | 1 | 0 | 0 | 10037.83 | 27.94 |
| [`mlc.codegen.codegen_runtime.emit_builtin_copyBytes_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-builtin-copybytes-function-function-emit-builtin-copybytes-function-state-mlc-codegen-codegen-runtime-ml-367431250) | `mlc/codegen/codegen_runtime.ml:3457` | 91 | 89 | 1 | 0 | 0 | 8685.77 | 29.55 |
| [`mlc.codegen.codegen_runtime.emit_builtin_copyStringBytes_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-builtin-copystringbytes-function-function-emit-builtin-copystringbytes-function-state-mlc-codegen-codegen-runtime-ml-1181575084) | `mlc/codegen/codegen_runtime.ml:1742` | 91 | 89 | 1 | 0 | 0 | 8711.57 | 29.54 |
| [`mlc.codegen.codegen_runtime.emit_builtin_fillBytes_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-builtin-fillbytes-function-function-emit-builtin-fillbytes-function-state-mlc-codegen-codegen-runtime-ml-1031161770) | `mlc/codegen/codegen_runtime.ml:3681` | 69 | 67 | 1 | 0 | 0 | 6297.89 | 33.15 |
| [`mlc.codegen.codegen_runtime.emit_builtin_gc_collect_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-builtin-gc-collect-function-function-emit-builtin-gc-collect-function-state-mlc-codegen-codegen-runtime-ml-1836857400) | `mlc/codegen/codegen_runtime.ml:3829` | 7 | 5 | 1 | 0 | 0 | 289.57 | 64.19 |
| [`mlc.codegen.codegen_runtime.emit_builtin_gc_set_limit_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-builtin-gc-set-limit-function-function-emit-builtin-gc-set-limit-function-state-mlc-codegen-codegen-runtime-ml-1019220532) | `mlc/codegen/codegen_runtime.ml:3839` | 48 | 46 | 1 | 0 | 0 | 3670.74 | 38.23 |
| [`mlc.codegen.codegen_runtime.emit_builtin_input_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-builtin-input-function-function-emit-builtin-input-function-state-mlc-codegen-codegen-runtime-ml-1368324302) | `mlc/codegen/codegen_runtime.ml:3803` | 19 | 17 | 1 | 0 | 0 | 1063.28 | 50.78 |
| [`mlc.codegen.codegen_runtime.emit_builtin_len_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-builtin-len-function-function-emit-builtin-len-function-state-mlc-codegen-codegen-runtime-ml-919784296) | `mlc/codegen/codegen_runtime.ml:3762` | 32 | 30 | 1 | 0 | 0 | 2445.49 | 43.31 |
| [`mlc.codegen.codegen_runtime.emit_bytes_compare_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-bytes-compare-function-function-emit-bytes-compare-function-state-mlc-codegen-codegen-runtime-ml-170599544) | `mlc/codegen/codegen_runtime.ml:1664` | 66 | 64 | 1 | 0 | 0 | 6272.92 | 33.58 |
| [`mlc.codegen.codegen_runtime.emit_bytes_constant_time_eq_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-bytes-constant-time-eq-function-function-emit-bytes-constant-time-eq-function-state-mlc-codegen-codegen-runtime-ml-1957626140) | `mlc/codegen/codegen_runtime.ml:446` | 53 | 51 | 1 | 0 | 0 | 4636.05 | 36.58 |
| [`mlc.codegen.codegen_runtime.emit_bytes_endswith_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-bytes-endswith-function-function-emit-bytes-endswith-function-state-mlc-codegen-codegen-runtime-ml-619147724) | `mlc/codegen/codegen_runtime.ml:1442` | 50 | 48 | 1 | 0 | 0 | 4346.45 | 37.33 |
| [`mlc.codegen.codegen_runtime.emit_bytes_hash_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-bytes-hash-function-function-emit-bytes-hash-function-state-mlc-codegen-codegen-runtime-ml-1093074800) | `mlc/codegen/codegen_runtime.ml:1298` | 37 | 35 | 1 | 0 | 0 | 3057.31 | 41.25 |
| [`mlc.codegen.codegen_runtime.emit_bytes_indexof_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-bytes-indexof-function-function-emit-bytes-indexof-function-state-mlc-codegen-codegen-runtime-ml-2096478812) | `mlc/codegen/codegen_runtime.ml:1501` | 80 | 78 | 1 | 0 | 0 | 7554.28 | 31.2 |
| [`mlc.codegen.codegen_runtime.emit_bytes_lastindexof_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-bytes-lastindexof-function-function-emit-bytes-lastindexof-function-state-mlc-codegen-codegen-runtime-ml-1410025644) | `mlc/codegen/codegen_runtime.ml:1594` | 59 | 57 | 1 | 0 | 0 | 5267.17 | 35.18 |
| [`mlc.codegen.codegen_runtime.emit_bytes_startswith_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-bytes-startswith-function-function-emit-bytes-startswith-function-state-mlc-codegen-codegen-runtime-ml-1583047876) | `mlc/codegen/codegen_runtime.ml:1386` | 47 | 45 | 1 | 0 | 0 | 4025.57 | 38.15 |
| [`mlc.codegen.codegen_runtime.emit_callStats_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-callstats-function-function-emit-callstats-function-state-mlc-codegen-codegen-runtime-ml-1296788652) | `mlc/codegen/codegen_runtime.ml:3903` | 50 | 45 | 10 | 12 | 3 | 4299.17 | 36.15 |
| [`mlc.codegen.codegen_runtime.emit_copy_bytes_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-copy-bytes-function-function-emit-copy-bytes-function-state-mlc-codegen-codegen-runtime-ml-710271692) | `mlc/codegen/codegen_runtime.ml:1854` | 109 | 107 | 1 | 0 | 0 | 10023.42 | 27.41 |
| [`mlc.codegen.codegen_runtime.emit_cpu_init_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-cpu-init-function-function-emit-cpu-init-function-state-mlc-codegen-codegen-runtime-ml-156433868) | `mlc/codegen/codegen_runtime.ml:180` | 88 | 86 | 1 | 0 | 0 | 7853.95 | 30.18 |
| [`mlc.codegen.codegen_runtime.emit_crc32_update_raw_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-crc32-update-raw-function-function-emit-crc32-update-raw-function-state-mlc-codegen-codegen-runtime-ml-549775004) | `mlc/codegen/codegen_runtime.ml:908` | 29 | 27 | 1 | 0 | 0 | 2090.69 | 44.72 |
| [`mlc.codegen.codegen_runtime.emit_crc32c_update_raw_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-crc32c-update-raw-function-function-emit-crc32c-update-raw-function-state-mlc-codegen-codegen-runtime-ml-1330212860) | `mlc/codegen/codegen_runtime.ml:851` | 54 | 52 | 1 | 0 | 0 | 4398.14 | 36.56 |
| [`mlc.codegen.codegen_runtime.emit_fill_bytes_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-fill-bytes-function-function-emit-fill-bytes-function-state-mlc-codegen-codegen-runtime-ml-665054572) | `mlc/codegen/codegen_runtime.ml:1978` | 89 | 87 | 1 | 0 | 0 | 7857.93 | 30.07 |
| [`mlc.codegen.codegen_runtime.emit_fill_qwords_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-fill-qwords-function-function-emit-fill-qwords-function-state-mlc-codegen-codegen-runtime-ml-1398510114) | `mlc/codegen/codegen_runtime.ml:2082` | 38 | 36 | 1 | 0 | 0 | 2928.11 | 41.13 |
| [`mlc.codegen.codegen_runtime.emit_find_byte_forward_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-find-byte-forward-function-function-emit-find-byte-forward-function-state-mlc-codegen-codegen-runtime-ml-948367850) | `mlc/codegen/codegen_runtime.ml:516` | 87 | 85 | 1 | 0 | 0 | 7752.43 | 30.32 |
| [`mlc.codegen.codegen_runtime.emit_find_byte_reverse_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-find-byte-reverse-function-function-emit-find-byte-reverse-function-state-mlc-codegen-codegen-runtime-ml-1832090052) | `mlc/codegen/codegen_runtime.ml:606` | 85 | 83 | 1 | 0 | 0 | 7502.1 | 30.64 |
| [`mlc.codegen.codegen_runtime.emit_init_argvw_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-init-argvw-function-function-emit-init-argvw-function-state-mlc-codegen-codegen-runtime-ml-1233742276) | `mlc/codegen/codegen_runtime.ml:3162` | 25 | 23 | 1 | 0 | 0 | 1599.61 | 46.94 |
| [`mlc.codegen.codegen_runtime.emit_int_to_dec_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-int-to-dec-function-function-emit-int-to-dec-function-state-mlc-codegen-codegen-runtime-ml-1742139360) | `mlc/codegen/codegen_runtime.ml:2129` | 44 | 42 | 1 | 0 | 0 | 3692.22 | 39.04 |
| [`mlc.codegen.codegen_runtime.emit_mem_eq_bytes_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-mem-eq-bytes-function-function-emit-mem-eq-bytes-function-state-mlc-codegen-codegen-runtime-ml-261482808) | `mlc/codegen/codegen_runtime.ml:345` | 86 | 84 | 1 | 0 | 0 | 7575.07 | 30.5 |
| [`mlc.codegen.codegen_runtime.emit_mem_indexof_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-mem-indexof-function-function-emit-mem-indexof-function-state-mlc-codegen-codegen-runtime-ml-148236232) | `mlc/codegen/codegen_runtime.ml:694` | 65 | 63 | 1 | 0 | 0 | 6010.18 | 33.86 |
| [`mlc.codegen.codegen_runtime.emit_mem_lastindexof_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-mem-lastindexof-function-function-emit-mem-lastindexof-function-state-mlc-codegen-codegen-runtime-ml-263126932) | `mlc/codegen/codegen_runtime.ml:762` | 56 | 54 | 1 | 0 | 0 | 4911.68 | 35.88 |
| [`mlc.codegen.codegen_runtime.emit_native_crc32_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-native-crc32-function-function-emit-native-crc32-function-state-mlc-codegen-codegen-runtime-ml-296402724) | `mlc/codegen/codegen_runtime.ml:1010` | 3 | 1 | 1 | 0 | 0 | 55.35 | 77.25 |
| [`mlc.codegen.codegen_runtime.emit_native_crc32c_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-native-crc32c-function-function-emit-native-crc32c-function-state-mlc-codegen-codegen-runtime-ml-581375542) | `mlc/codegen/codegen_runtime.ml:1004` | 3 | 1 | 1 | 0 | 0 | 55.35 | 77.25 |
| [`mlc.codegen.codegen_runtime.emit_runtime_cpu_active_features_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-runtime-cpu-active-features-function-function-emit-runtime-cpu-active-features-function-state-mlc-codegen-codegen-runtime-ml-698579582) | `mlc/codegen/codegen_runtime.ml:294` | 8 | 6 | 1 | 0 | 0 | 352.3 | 62.33 |
| [`mlc.codegen.codegen_runtime.emit_runtime_cpu_features_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-runtime-cpu-features-function-function-emit-runtime-cpu-features-function-state-mlc-codegen-codegen-runtime-ml-1281190268) | `mlc/codegen/codegen_runtime.ml:283` | 8 | 6 | 1 | 0 | 0 | 352.3 | 62.33 |
| [`mlc.codegen.codegen_runtime.emit_runtime_cpu_set_mask_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-runtime-cpu-set-mask-function-function-emit-runtime-cpu-set-mask-function-state-mlc-codegen-codegen-runtime-ml-1204335896) | `mlc/codegen/codegen_runtime.ml:305` | 37 | 35 | 1 | 0 | 0 | 2788.4 | 41.53 |
| [`mlc.codegen.codegen_runtime.emit_scan_byte2_bytes_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-scan-byte2-bytes-function-function-emit-scan-byte2-bytes-function-state-mlc-codegen-codegen-runtime-ml-339157064) | `mlc/codegen/codegen_runtime.ml:1109` | 77 | 75 | 1 | 0 | 0 | 6883.08 | 31.84 |
| [`mlc.codegen.codegen_runtime.emit_scan_nul_bytes_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-scan-nul-bytes-function-function-emit-scan-nul-bytes-function-state-mlc-codegen-codegen-runtime-ml-1043760700) | `mlc/codegen/codegen_runtime.ml:1016` | 80 | 78 | 1 | 0 | 0 | 6979.83 | 31.44 |
| [`mlc.codegen.codegen_runtime.emit_scan_nul_wchars_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-scan-nul-wchars-function-function-emit-scan-nul-wchars-function-state-mlc-codegen-codegen-runtime-ml-831721098) | `mlc/codegen/codegen_runtime.ml:1198` | 87 | 85 | 1 | 0 | 0 | 7706.12 | 30.34 |
| [`mlc.codegen.codegen_runtime.emit_string_eq_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-string-eq-function-function-emit-string-eq-function-state-mlc-codegen-codegen-runtime-ml-2116402438) | `mlc/codegen/codegen_runtime.ml:2749` | 30 | 28 | 1 | 0 | 0 | 2155.95 | 44.3 |
| [`mlc.codegen.codegen_runtime.emit_string_hash_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-string-hash-function-function-emit-string-hash-function-state-mlc-codegen-codegen-runtime-ml-325949198) | `mlc/codegen/codegen_runtime.ml:1342` | 37 | 35 | 1 | 0 | 0 | 3057.31 | 41.25 |
| [`mlc.codegen.codegen_runtime.emit_strlen_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-strlen-function-function-emit-strlen-function-state-mlc-codegen-codegen-runtime-ml-1167218460) | `mlc/codegen/codegen_runtime.ml:2739` | 7 | 5 | 1 | 0 | 0 | 280.93 | 64.29 |
| [`mlc.codegen.codegen_runtime.emit_toFloat_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-tofloat-function-function-emit-tofloat-function-state-mlc-codegen-codegen-runtime-ml-1619213004) | `mlc/codegen/codegen_runtime.ml:2379` | 22 | 20 | 1 | 0 | 0 | 1334.52 | 48.7 |
| [`mlc.codegen.codegen_runtime.emit_toNumber_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-tonumber-function-function-emit-tonumber-function-state-mlc-codegen-codegen-runtime-ml-612955968) | `mlc/codegen/codegen_runtime.ml:2184` | 166 | 164 | 1 | 0 | 0 | 16355.83 | 21.93 |
| [`mlc.codegen.codegen_runtime.emit_typeName_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-typename-function-function-emit-typename-function-state-mlc-codegen-codegen-runtime-ml-604461264) | `mlc/codegen/codegen_runtime.ml:2540` | 178 | 176 | 37 | 102 | 5 | 15716.96 | 16.55 |
| [`mlc.codegen.codegen_runtime.emit_typeof_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-typeof-function-function-emit-typeof-function-state-mlc-codegen-codegen-runtime-ml-884885964) | `mlc/codegen/codegen_runtime.ml:2407` | 111 | 109 | 1 | 0 | 0 | 9645.71 | 27.35 |
| [`mlc.codegen.codegen_runtime.emit_unhandled_error_exit_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-unhandled-error-exit-function-function-emit-unhandled-error-exit-function-state-mlc-codegen-codegen-runtime-ml-856176908) | `mlc/codegen/codegen_runtime.ml:3006` | 115 | 100 | 1 | 0 | 0 | 10837.09 | 26.66 |
| [`mlc.codegen.codegen_runtime.emit_unhandled_error_exit_function.local._emit_writefile`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#nested_function-nested-function-mlc-codegen-codegen-runtime-emit-unhandled-error-exit-function-local-emit-writefile-function-emit-writefile-state2-lbl-ln-mlc-codegen-codegen-runtime-ml-54962409) | `mlc/codegen/codegen_runtime.ml:3023` | 5 | 3 | 1 | 0 | 0 | 179.85 | 68.83 |
| [`mlc.codegen.codegen_runtime.emit_unhandled_error_exit_function.local._emit_writefile_ptr_len`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#nested_function-nested-function-mlc-codegen-codegen-runtime-emit-unhandled-error-exit-function-local-emit-writefile-ptr-len-function-emit-writefile-ptr-len-state2-mlc-codegen-codegen-runtime-ml-338525475) | `mlc/codegen/codegen_runtime.ml:3012` | 8 | 6 | 1 | 0 | 0 | 338.21 | 62.46 |
| [`mlc.codegen.codegen_runtime.emit_value_eq_function`](File-mlc-codegen-codegen-runtime-ml-1845689217.md#function-function-mlc-codegen-codegen-runtime-emit-value-eq-function-function-emit-value-eq-function-state-mlc-codegen-codegen-runtime-ml-183796344) | `mlc/codegen/codegen_runtime.ml:2788` | 193 | 191 | 1 | 0 | 0 | 20659.17 | 19.79 |
| [`mlc.codegen.codegen_scope._add_binding_to_current_scope`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-add-binding-to-current-scope-function-add-binding-to-current-scope-state-b-mlc-codegen-codegen-scope-ml-1481177074) | `mlc/codegen/codegen_scope.ml:983` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.codegen.codegen_scope._append_unique`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-append-unique-function-append-unique-items-value-mlc-codegen-codegen-scope-ml-873548608) | `mlc/codegen/codegen_scope.ml:261` | 18 | 14 | 9 | 17 | 4 | 646.29 | 51.73 |
| [`mlc.codegen.codegen_scope._arr_has`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-arr-has-inline-function-arr-has-arr-value-mlc-codegen-codegen-scope-ml-625151476) | `mlc/codegen/codegen_scope.ml:282` | 7 | 6 | 5 | 5 | 2 | 274.79 | 63.81 |
| [`mlc.codegen.codegen_scope._check_reserved_ident`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-check-reserved-ident-function-check-reserved-ident-state-name-decl-node-mlc-codegen-codegen-scope-ml-1092621700) | `mlc/codegen/codegen_scope.ml:989` | 8 | 5 | 2 | 1 | 1 | 201.74 | 63.89 |
| [`mlc.codegen.codegen_scope._coerce_name`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-coerce-name-function-coerce-name-name-mlc-codegen-codegen-scope-ml-986629978) | `mlc/codegen/codegen_scope.ml:860` | 13 | 14 | 8 | 9 | 2 | 432.44 | 56.17 |
| [`mlc.codegen.codegen_scope._decl_key`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-decl-key-function-decl-key-node-name-mlc-codegen-codegen-scope-ml-966656368) | `mlc/codegen/codegen_scope.ml:963` | 3 | 1 | 1 | 0 | 0 | 77.71 | 76.22 |
| [`mlc.codegen.codegen_scope._decl_node_key`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-decl-node-key-inline-function-decl-node-key-node-mlc-codegen-codegen-scope-ml-188869874) | `mlc/codegen/codegen_scope.ml:324` | 38 | 48 | 24 | 38 | 3 | 1838.57 | 39.45 |
| [`mlc.codegen.codegen_scope._declare_in_current_scope`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-declare-in-current-scope-function-declare-in-current-scope-state-b-mlc-codegen-codegen-scope-ml-949818152) | `mlc/codegen/codegen_scope.ml:598` | 36 | 29 | 9 | 10 | 2 | 1611.37 | 42.38 |
| [`mlc.codegen.codegen_scope._drop_last_frame`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-drop-last-frame-function-drop-last-frame-arr-mlc-codegen-codegen-scope-ml-1384258026) | `mlc/codegen/codegen_scope.ml:232` | 14 | 16 | 8 | 7 | 1 | 708.49 | 53.96 |
| [`mlc.codegen.codegen_scope._emit_make_error_const`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-emit-make-error-const-function-emit-make-error-const-state-code-message-mlc-codegen-codegen-scope-ml-556035598) | `mlc/codegen/codegen_scope.ml:397` | 26 | 25 | 2 | 1 | 1 | 1972.9 | 45.79 |
| [`mlc.codegen.codegen_scope._emit_module_init_dependency_error`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-emit-module-init-dependency-error-function-emit-module-init-dependency-error-state-target-name-target-file-target-state-node-mlc-codegen-codegen-scope-ml-67747104) | `mlc/codegen/codegen_scope.ml:1486` | 14 | 15 | 6 | 5 | 1 | 763.6 | 54.01 |
| [`mlc.codegen.codegen_scope._frame_last_binding`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-frame-last-binding-inline-function-frame-last-binding-frame-name-mlc-codegen-codegen-scope-ml-1237157440) | `mlc/codegen/codegen_scope.ml:191` | 13 | 10 | 5 | 5 | 2 | 335.2 | 57.35 |
| [`mlc.codegen.codegen_scope._func_global_lookup`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-func-global-lookup-inline-function-func-global-lookup-arr-name-mlc-codegen-codegen-scope-ml-480068282) | `mlc/codegen/codegen_scope.ml:365` | 18 | 15 | 13 | 17 | 3 | 841.14 | 50.39 |
| [`mlc.codegen.codegen_scope._has_data_label`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-has-data-label-function-has-data-label-labels-name-mlc-codegen-codegen-scope-ml-312136563) | `mlc/codegen/codegen_scope.ml:386` | 8 | 7 | 6 | 6 | 2 | 337.97 | 61.79 |
| [`mlc.codegen.codegen_scope._heap_cfg_get_any`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-heap-cfg-get-any-inline-function-heap-cfg-get-any-state-key-mlc-codegen-codegen-scope-ml-681445032) | `mlc/codegen/codegen_scope.ml:207` | 14 | 10 | 11 | 12 | 2 | 665.96 | 53.75 |
| [`mlc.codegen.codegen_scope._heap_cfg_get_bool`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-heap-cfg-get-bool-inline-function-heap-cfg-get-bool-state-key-defaultv-mlc-codegen-codegen-scope-ml-263182827) | `mlc/codegen/codegen_scope.ml:224` | 5 | 4 | 2 | 1 | 1 | 144.43 | 69.36 |
| [`mlc.codegen.codegen_scope._is_ascii_alpha`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-is-ascii-alpha-inline-function-is-ascii-alpha-ch-mlc-codegen-codegen-scope-ml-1897055775) | `mlc/codegen/codegen_scope.ml:100` | 7 | 9 | 53 | 52 | 1 | 1438.57 | 52.32 |
| [`mlc.codegen.codegen_scope._is_ascii_digit`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-is-ascii-digit-inline-function-is-ascii-digit-ch-mlc-codegen-codegen-scope-ml-1063018823) | `mlc/codegen/codegen_scope.ml:94` | 3 | 1 | 1 | 0 | 0 | 207.45 | 73.23 |
| [`mlc.codegen.codegen_scope._is_reserved_identifier`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-is-reserved-identifier-inline-function-is-reserved-identifier-state-name-mlc-codegen-codegen-scope-ml-529530772) | `mlc/codegen/codegen_scope.ml:249` | 9 | 9 | 5 | 5 | 2 | 330 | 60.88 |
| [`mlc.codegen.codegen_scope._map_int_get`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-map-int-get-inline-function-map-int-get-arr-key-defaultv-mlc-codegen-codegen-scope-ml-1228131745) | `mlc/codegen/codegen_scope.ml:292` | 18 | 14 | 13 | 15 | 2 | 830.22 | 50.43 |
| [`mlc.codegen.codegen_scope._maybe_emit_module_init_guard_for_global_read`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-maybe-emit-module-init-guard-for-global-read-function-maybe-emit-module-init-guard-for-global-read-state-binding-target-name-node-mlc-codegen-codegen-scope-ml-147704174) | `mlc/codegen/codegen_scope.ml:1503` | 27 | 29 | 7 | 6 | 1 | 1647.69 | 45.31 |
| [`mlc.codegen.codegen_scope._name_has_dot`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-name-has-dot-inline-function-name-has-dot-name-mlc-codegen-codegen-scope-ml-1624076743) | `mlc/codegen/codegen_scope.ml:313` | 8 | 8 | 5 | 5 | 2 | 269.21 | 62.61 |
| [`mlc.codegen.codegen_scope._next_binding_id`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-next-binding-id-function-next-binding-id-state-mlc-codegen-codegen-scope-ml-1544857556) | `mlc/codegen/codegen_scope.ml:957` | 3 | 1 | 1 | 0 | 0 | 36 | 78.56 |
| [`mlc.codegen.codegen_scope._sanitize_ident`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-sanitize-ident-function-sanitize-ident-name-mlc-codegen-codegen-scope-ml-2003671040) | `mlc/codegen/codegen_scope.ml:110` | 23 | 22 | 10 | 12 | 2 | 697.67 | 49.04 |
| [`mlc.codegen.codegen_scope._scope_depth`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-scope-depth-inline-function-scope-depth-state-mlc-codegen-codegen-scope-ml-367959883) | `mlc/codegen/codegen_scope.ml:138` | 4 | 3 | 2 | 1 | 1 | 131.69 | 71.76 |
| [`mlc.codegen.codegen_scope.accept`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-accept-function-accept-s-mlc-codegen-codegen-scope-ml-941567756) | `mlc/codegen/codegen_scope.ml:892` | 7 | 9 | 16 | 15 | 1 | 466.15 | 60.73 |
| [`mlc.codegen.codegen_scope.analysis_layout_function_locals`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-analysis-layout-function-locals-function-analysis-layout-function-locals-state-base-offset-mlc-codegen-codegen-scope-ml-965038881) | `mlc/codegen/codegen_scope.ml:1838` | 23 | 23 | 10 | 12 | 2 | 873.63 | 48.36 |
| [`mlc.codegen.codegen_scope.analysis_reset_function`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-analysis-reset-function-function-analysis-reset-function-state-mlc-codegen-codegen-scope-ml-1837008426) | `mlc/codegen/codegen_scope.ml:1825` | 9 | 7 | 1 | 0 | 0 | 275.94 | 61.96 |
| [`mlc.codegen.codegen_scope.bind_param`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-bind-param-function-bind-param-state-name-offset-decl-node-mlc-codegen-codegen-scope-ml-1044192007) | `mlc/codegen/codegen_scope.ml:1350` | 31 | 24 | 11 | 20 | 5 | 1236 | 44.34 |
| [`mlc.codegen.codegen_scope.cg_declare_binding`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-cg-declare-binding-function-cg-declare-binding-state-name-kind-is-const-const-expr-const-value-py-decl-node-mlc-codegen-codegen-scope-ml-79290834) | `mlc/codegen/codegen_scope.ml:646` | 70 | 37 | 34 | 43 | 3 | 3060.33 | 30.77 |
| [`mlc.codegen.codegen_scope.cg_next_binding_id`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-cg-next-binding-id-function-cg-next-binding-id-state-mlc-codegen-codegen-scope-ml-843506688) | `mlc/codegen/codegen_scope.ml:520` | 4 | 2 | 1 | 0 | 0 | 71.7 | 73.74 |
| [`mlc.codegen.codegen_scope.cg_precompute_const_binding_value`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-cg-precompute-const-binding-value-function-cg-precompute-const-binding-value-state-name-pyv-mlc-codegen-codegen-scope-ml-632647422) | `mlc/codegen/codegen_scope.ml:799` | 36 | 31 | 12 | 21 | 5 | 1341.28 | 42.54 |
| [`mlc.codegen.codegen_scope.cg_resolve_binding`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-cg-resolve-binding-function-cg-resolve-binding-state-name-mlc-codegen-codegen-scope-ml-1169968655) | `mlc/codegen/codegen_scope.ml:528` | 27 | 26 | 11 | 17 | 3 | 1103.86 | 45.99 |
| [`mlc.codegen.codegen_scope.cg_resolve_binding_for_write`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-cg-resolve-binding-for-write-function-cg-resolve-binding-for-write-state-name-mlc-codegen-codegen-scope-ml-346787647) | `mlc/codegen/codegen_scope.ml:564` | 22 | 18 | 10 | 14 | 3 | 630.55 | 49.77 |
| [`mlc.codegen.codegen_scope.cg_scope_depth`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-cg-scope-depth-function-cg-scope-depth-state-mlc-codegen-codegen-scope-ml-2035357288) | `mlc/codegen/codegen_scope.ml:465` | 3 | 1 | 1 | 0 | 0 | 36 | 78.56 |
| [`mlc.codegen.codegen_scope.cg_scope_enter`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-cg-scope-enter-function-cg-scope-enter-state-mlc-codegen-codegen-scope-ml-208897180) | `mlc/codegen/codegen_scope.ml:471` | 19 | 13 | 5 | 4 | 1 | 794.37 | 51.13 |
| [`mlc.codegen.codegen_scope.cg_scope_leave`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-cg-scope-leave-function-cg-scope-leave-state-emit-cleanup-mlc-codegen-codegen-scope-ml-265549576) | `mlc/codegen/codegen_scope.ml:494` | 21 | 18 | 12 | 12 | 2 | 1012.85 | 48.5 |
| [`mlc.codegen.codegen_scope.cg_scope_setup`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-cg-scope-setup-function-cg-scope-setup-state-mlc-codegen-codegen-scope-ml-985598392) | `mlc/codegen/codegen_scope.ml:442` | 20 | 18 | 1 | 0 | 0 | 791.84 | 51.19 |
| [`mlc.codegen.codegen_scope.cg_set_const_binding_value`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-cg-set-const-binding-value-function-cg-set-const-binding-value-state-name-pyv-mlc-codegen-codegen-scope-ml-2050073468) | `mlc/codegen/codegen_scope.ml:729` | 64 | 55 | 25 | 72 | 6 | 2914.41 | 32.98 |
| [`mlc.codegen.codegen_scope.declare_callable_binding_root`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-declare-callable-binding-root-function-declare-callable-binding-root-state-name-decl-node-mlc-codegen-codegen-scope-ml-641440390) | `mlc/codegen/codegen_scope.ml:1109` | 41 | 47 | 18 | 17 | 1 | 3152.19 | 37.9 |
| [`mlc.codegen.codegen_scope.declare_const_binding_root_deferred`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-declare-const-binding-root-deferred-function-declare-const-binding-root-deferred-state-name-decl-node-const-expr-mlc-codegen-codegen-scope-ml-1213810991) | `mlc/codegen/codegen_scope.ml:1161` | 63 | 40 | 16 | 15 | 1 | 2577.57 | 34.71 |
| [`mlc.codegen.codegen_scope.declare_fresh_binding`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-declare-fresh-binding-function-declare-fresh-binding-state-name-decl-node-kind-mlc-codegen-codegen-scope-ml-1423674534) | `mlc/codegen/codegen_scope.ml:1317` | 24 | 19 | 8 | 7 | 1 | 956.66 | 47.94 |
| [`mlc.codegen.codegen_scope.declare_function_global`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-declare-function-global-function-declare-function-global-state-local-name-qualified-name-mlc-codegen-codegen-scope-ml-1108792341) | `mlc/codegen/codegen_scope.ml:1866` | 30 | 27 | 16 | 16 | 2 | 1631.87 | 43.13 |
| [`mlc.codegen.codegen_scope.declare_global_binding`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-declare-global-binding-function-declare-global-binding-state-name-decl-node-is-const-const-expr-mlc-codegen-codegen-scope-ml-353176841) | `mlc/codegen/codegen_scope.ml:1004` | 4 | 2 | 1 | 0 | 0 | 158.46 | 71.33 |
| [`mlc.codegen.codegen_scope.declare_global_binding_root`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-declare-global-binding-root-function-declare-global-binding-root-state-name-decl-node-is-const-const-expr-mlc-codegen-codegen-scope-ml-924585051) | `mlc/codegen/codegen_scope.ml:1015` | 82 | 54 | 23 | 23 | 2 | 3674.67 | 30.19 |
| [`mlc.codegen.codegen_scope.declare_local_binding`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-declare-local-binding-function-declare-local-binding-state-name-decl-node-is-const-const-expr-mlc-codegen-codegen-scope-ml-431201897) | `mlc/codegen/codegen_scope.ml:1307` | 4 | 2 | 1 | 0 | 0 | 158.46 | 71.33 |
| [`mlc.codegen.codegen_scope.emit_cleanup_bindings`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-emit-cleanup-bindings-function-emit-cleanup-bindings-state-bindings-mlc-codegen-codegen-scope-ml-1409007752) | `mlc/codegen/codegen_scope.ml:1441` | 21 | 21 | 10 | 17 | 3 | 998.96 | 48.81 |
| [`mlc.codegen.codegen_scope.emit_cleanup_to_depth`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-emit-cleanup-to-depth-function-emit-cleanup-to-depth-state-target-depth-mlc-codegen-codegen-scope-ml-649807815) | `mlc/codegen/codegen_scope.ml:1466` | 17 | 15 | 9 | 11 | 3 | 589.37 | 52.55 |
| [`mlc.codegen.codegen_scope.emit_load_var_scoped`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-emit-load-var-scoped-function-emit-load-var-scoped-state-name-mlc-codegen-codegen-scope-ml-2048837639) | `mlc/codegen/codegen_scope.ml:1535` | 120 | 105 | 48 | 73 | 3 | 7591.28 | 21.02 |
| [`mlc.codegen.codegen_scope.emit_store_existing_global`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-emit-store-existing-global-function-emit-store-existing-global-state-binding-mlc-codegen-codegen-scope-ml-2015630335) | `mlc/codegen/codegen_scope.ml:1804` | 18 | 13 | 6 | 5 | 1 | 702.96 | 51.88 |
| [`mlc.codegen.codegen_scope.emit_store_var_scoped`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-emit-store-var-scoped-function-emit-store-var-scoped-state-name-node-mlc-codegen-codegen-scope-ml-1932595927) | `mlc/codegen/codegen_scope.ml:1670` | 117 | 101 | 43 | 64 | 3 | 7373.06 | 22.02 |
| [`mlc.codegen.codegen_scope.ensure_binding_for_write`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-ensure-binding-for-write-function-ensure-binding-for-write-state-name-decl-node-mlc-codegen-codegen-scope-ml-150283678) | `mlc/codegen/codegen_scope.ml:1400` | 33 | 27 | 13 | 16 | 3 | 1373.9 | 43.15 |
| [`mlc.codegen.codegen_scope.frame_count`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-frame-count-inline-function-frame-count-frame-mlc-codegen-codegen-scope-ml-2061155255) | `mlc/codegen/codegen_scope.ml:145` | 5 | 5 | 3 | 2 | 1 | 178.41 | 68.58 |
| [`mlc.codegen.codegen_scope.frame_finish`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-frame-finish-inline-function-frame-finish-frame-mlc-codegen-codegen-scope-ml-98807871) | `mlc/codegen/codegen_scope.ml:183` | 5 | 5 | 3 | 2 | 1 | 169.92 | 68.73 |
| [`mlc.codegen.codegen_scope.frame_get`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-frame-get-inline-function-frame-get-frame-idx-mlc-codegen-codegen-scope-ml-734111256) | `mlc/codegen/codegen_scope.ml:154` | 5 | 5 | 6 | 5 | 1 | 317.29 | 66.43 |
| [`mlc.codegen.codegen_scope.frame_push`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-frame-push-inline-function-frame-push-frame-value-mlc-codegen-codegen-scope-ml-338635704) | `mlc/codegen/codegen_scope.ml:173` | 7 | 6 | 3 | 3 | 2 | 296.13 | 63.86 |
| [`mlc.codegen.codegen_scope.frame_set`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-frame-set-inline-function-frame-set-frame-idx-value-mlc-codegen-codegen-scope-ml-982770623) | `mlc/codegen/codegen_scope.ml:164` | 5 | 5 | 6 | 5 | 1 | 335.2 | 66.26 |
| [`mlc.codegen.codegen_scope.is_ident`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-is-ident-function-is-ident-s-mlc-codegen-codegen-scope-ml-624417624) | `mlc/codegen/codegen_scope.ml:876` | 13 | 14 | 6 | 6 | 2 | 733.98 | 54.83 |
| [`mlc.codegen.codegen_scope.materialize_global_binding_root`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-materialize-global-binding-root-function-materialize-global-binding-root-state-name-mlc-codegen-codegen-scope-ml-124725415) | `mlc/codegen/codegen_scope.ml:1237` | 57 | 52 | 25 | 28 | 3 | 2977.38 | 34.01 |
| [`mlc.codegen.codegen_scope.new_label_id`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-new-label-id-function-new-label-id-state-mlc-codegen-codegen-scope-ml-673792072) | `mlc/codegen/codegen_scope.ml:435` | 4 | 2 | 1 | 0 | 0 | 71.7 | 73.74 |
| [`mlc.codegen.codegen_scope.pop_scope`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-pop-scope-function-pop-scope-state-emit-cleanup-mlc-codegen-codegen-scope-ml-756384492) | `mlc/codegen/codegen_scope.ml:951` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.codegen.codegen_scope.push_scope`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-push-scope-function-push-scope-state-mlc-codegen-codegen-scope-ml-533749804) | `mlc/codegen/codegen_scope.ml:944` | 3 | 1 | 1 | 0 | 0 | 36 | 78.56 |
| [`mlc.codegen.codegen_scope.register_decl_site_binding`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-register-decl-site-binding-function-register-decl-site-binding-state-node-name-binding-mlc-codegen-codegen-scope-ml-1681346154) | `mlc/codegen/codegen_scope.ml:1387` | 8 | 5 | 2 | 1 | 1 | 283.28 | 62.86 |
| [`mlc.codegen.codegen_scope.resolve_binding`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-resolve-binding-function-resolve-binding-state-name-mlc-codegen-codegen-scope-ml-808967299) | `mlc/codegen/codegen_scope.ml:970` | 3 | 1 | 1 | 0 | 0 | 65.73 | 76.73 |
| [`mlc.codegen.codegen_scope.resolve_binding_for_write`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-resolve-binding-for-write-function-resolve-binding-for-write-state-name-mlc-codegen-codegen-scope-ml-1783653563) | `mlc/codegen/codegen_scope.ml:977` | 3 | 1 | 1 | 0 | 0 | 65.73 | 76.73 |
| [`mlc.codegen.codegen_scope.scope_depth`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-scope-depth-function-scope-depth-state-mlc-codegen-codegen-scope-ml-1470761636) | `mlc/codegen/codegen_scope.ml:848` | 3 | 1 | 1 | 0 | 0 | 36 | 78.56 |
| [`mlc.codegen.codegen_scope.scope_global_slots`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-scope-global-slots-function-scope-global-slots-state-mlc-codegen-codegen-scope-ml-2126650844) | `mlc/codegen/codegen_scope.ml:854` | 3 | 1 | 1 | 0 | 0 | 46.51 | 77.78 |
| [`mlc.codegen.codegen_scope.scope_setup`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-scope-setup-function-scope-setup-state-mlc-codegen-codegen-scope-ml-788759876) | `mlc/codegen/codegen_scope.ml:842` | 3 | 1 | 1 | 0 | 0 | 36 | 78.56 |
| [`mlc.codegen.codegen_scope.search`](File-mlc-codegen-codegen-scope-ml-1124416197.md#function-function-mlc-codegen-codegen-scope-search-function-search-obj-depth-mlc-codegen-codegen-scope-ml-1738047943) | `mlc/codegen/codegen_scope.ml:903` | 32 | 37 | 27 | 38 | 3 | 1692.42 | 40.93 |
| [`mlc.codegen.codegen_stmt._all_function_entries`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-all-function-entries-function-all-function-entries-state-mlc-codegen-codegen-stmt-ml-142948514) | `mlc/codegen/codegen_stmt.ml:8526` | 31 | 27 | 7 | 8 | 2 | 1076.4 | 45.3 |
| [`mlc.codegen.codegen_stmt._analysis_builtin_has`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-analysis-builtin-has-function-analysis-builtin-has-name-mlc-codegen-codegen-stmt-ml-1384222596) | `mlc/codegen/codegen_stmt.ml:5464` | 23 | 40 | 20 | 19 | 1 | 1012.85 | 46.56 |
| [`mlc.codegen.codegen_stmt._analysis_call_args`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-analysis-call-args-function-analysis-call-args-ex-mlc-codegen-codegen-stmt-ml-1530729698) | `mlc/codegen/codegen_stmt.ml:5446` | 6 | 6 | 3 | 2 | 1 | 188.87 | 66.68 |
| [`mlc.codegen.codegen_stmt._analysis_call_callee`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-analysis-call-callee-function-analysis-call-callee-ex-mlc-codegen-codegen-stmt-ml-220972052) | `mlc/codegen/codegen_stmt.ml:5435` | 8 | 9 | 4 | 3 | 1 | 272.03 | 62.71 |
| [`mlc.codegen.codegen_stmt._analysis_for_end_expr`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-analysis-for-end-expr-function-analysis-for-end-expr-st-mlc-codegen-codegen-stmt-ml-1858145608) | `mlc/codegen/codegen_stmt.ml:5455` | 6 | 6 | 3 | 2 | 1 | 177.2 | 66.88 |
| [`mlc.codegen.codegen_stmt._analysis_is_type_query_name`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-analysis-is-type-query-name-function-analysis-is-type-query-name-name-mlc-codegen-codegen-stmt-ml-277170088) | `mlc/codegen/codegen_stmt.ml:5502` | 4 | 2 | 1 | 0 | 0 | 79.95 | 73.41 |
| [`mlc.codegen.codegen_stmt._analysis_known_callable_name`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-analysis-known-callable-name-function-analysis-known-callable-name-state-name-mlc-codegen-codegen-stmt-ml-1512095307) | `mlc/codegen/codegen_stmt.ml:5490` | 9 | 12 | 6 | 5 | 1 | 432.66 | 59.92 |
| [`mlc.codegen.codegen_stmt._analysis_mark_current_binding_boxed`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-analysis-mark-current-binding-boxed-function-analysis-mark-current-binding-boxed-state-name-mlc-codegen-codegen-stmt-ml-771418507) | `mlc/codegen/codegen_stmt.ml:5391` | 30 | 29 | 12 | 14 | 3 | 1306.36 | 44.35 |
| [`mlc.codegen.codegen_stmt._analysis_member_target`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-analysis-member-target-function-analysis-member-target-ex-mlc-codegen-codegen-stmt-ml-729559442) | `mlc/codegen/codegen_stmt.ml:5424` | 8 | 9 | 4 | 3 | 1 | 272.03 | 62.71 |
| [`mlc.codegen.codegen_stmt._analysis_prepare_function`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-analysis-prepare-function-function-analysis-prepare-function-state-fn-node-mlc-codegen-codegen-stmt-ml-1115148319) | `mlc/codegen/codegen_stmt.ml:5881` | 116 | 102 | 40 | 52 | 4 | 5788.3 | 23.24 |
| [`mlc.codegen.codegen_stmt._analysis_register_fresh_local_decl`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-analysis-register-fresh-local-decl-function-analysis-register-fresh-local-decl-state-decl-node-name-mlc-codegen-codegen-stmt-ml-1142350532) | `mlc/codegen/codegen_stmt.ml:5377` | 11 | 9 | 3 | 2 | 1 | 413.43 | 58.56 |
| [`mlc.codegen.codegen_stmt._analysis_register_local_decl`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-analysis-register-local-decl-function-analysis-register-local-decl-state-decl-node-name-mlc-codegen-codegen-stmt-ml-1545783478) | `mlc/codegen/codegen_stmt.ml:5346` | 28 | 24 | 12 | 14 | 2 | 1305.97 | 45 |
| [`mlc.codegen.codegen_stmt._analysis_scan_block`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-analysis-scan-block-function-analysis-scan-block-state-stmts-mlc-codegen-codegen-stmt-ml-1334106925) | `mlc/codegen/codegen_stmt.ml:5869` | 9 | 8 | 6 | 6 | 2 | 341.84 | 60.64 |
| [`mlc.codegen.codegen_stmt._analysis_scan_expr`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-analysis-scan-expr-function-analysis-scan-expr-state-ex-allow-func-ident-mlc-codegen-codegen-stmt-ml-774877392) | `mlc/codegen/codegen_stmt.ml:5509` | 146 | 133 | 66 | 148 | 5 | 7729.59 | 16.68 |
| [`mlc.codegen.codegen_stmt._analysis_scan_stmt`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-analysis-scan-stmt-function-analysis-scan-stmt-state-st-mlc-codegen-codegen-stmt-ml-899640815) | `mlc/codegen/codegen_stmt.ml:5679` | 167 | 139 | 61 | 115 | 7 | 9708.06 | 15.39 |
| [`mlc.codegen.codegen_stmt._analyze_inline_only_functions`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-analyze-inline-only-functions-function-analyze-inline-only-functions-state-program-mlc-codegen-codegen-stmt-ml-2137680516) | `mlc/codegen/codegen_stmt.ml:4423` | 54 | 55 | 34 | 73 | 5 | 3409.04 | 32.9 |
| [`mlc.codegen.codegen_stmt._arr_add_unique`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-arr-add-unique-inline-function-arr-add-unique-arr-value-mlc-codegen-codegen-stmt-ml-1668383150) | `mlc/codegen/codegen_stmt.ml:4990` | 5 | 5 | 3 | 2 | 1 | 181.52 | 68.53 |
| [`mlc.codegen.codegen_stmt._arr_has`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-arr-has-inline-function-arr-has-arr-value-mlc-codegen-codegen-stmt-ml-359581178) | `mlc/codegen/codegen_stmt.ml:4980` | 7 | 6 | 5 | 5 | 2 | 274.79 | 63.81 |
| [`mlc.codegen.codegen_stmt._arr_remove_value`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-arr-remove-value-function-arr-remove-value-arr-value-mlc-codegen-codegen-stmt-ml-707931247) | `mlc/codegen/codegen_stmt.ml:4998` | 8 | 7 | 5 | 5 | 2 | 403.55 | 61.38 |
| [`mlc.codegen.codegen_stmt._arr_union`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-arr-union-function-arr-union-a-b-mlc-codegen-codegen-stmt-ml-655469364) | `mlc/codegen/codegen_stmt.ml:5009` | 14 | 8 | 7 | 8 | 2 | 466.31 | 55.37 |
| [`mlc.codegen.codegen_stmt._as_name`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-as-name-inline-function-as-name-v-mlc-codegen-codegen-stmt-ml-1710050946) | `mlc/codegen/codegen_stmt.ml:6977` | 3 | 1 | 1 | 0 | 0 | 41.21 | 78.15 |
| [`mlc.codegen.codegen_stmt._binding_global_label`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-binding-global-label-function-binding-global-label-state-qname-mlc-codegen-codegen-stmt-ml-1926922966) | `mlc/codegen/codegen_stmt.ml:8230` | 7 | 4 | 5 | 4 | 1 | 263.22 | 63.95 |
| [`mlc.codegen.codegen_stmt._breakctx_break_depth`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-breakctx-break-depth-inline-function-breakctx-break-depth-ctx-fallback-mlc-codegen-codegen-stmt-ml-978797753) | `mlc/codegen/codegen_stmt.ml:1146` | 4 | 3 | 4 | 3 | 1 | 199.04 | 70.23 |
| [`mlc.codegen.codegen_stmt._breakctx_break_label`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-breakctx-break-label-inline-function-breakctx-break-label-ctx-mlc-codegen-codegen-stmt-ml-1712422467) | `mlc/codegen/codegen_stmt.ml:1126` | 7 | 6 | 7 | 8 | 2 | 361.88 | 62.71 |
| [`mlc.codegen.codegen_stmt._breakctx_continue_depth`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-breakctx-continue-depth-inline-function-breakctx-continue-depth-ctx-fallback-mlc-codegen-codegen-stmt-ml-1088285325) | `mlc/codegen/codegen_stmt.ml:1153` | 4 | 3 | 4 | 3 | 1 | 199.04 | 70.23 |
| [`mlc.codegen.codegen_stmt._breakctx_continue_label`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-breakctx-continue-label-inline-function-breakctx-continue-label-ctx-mlc-codegen-codegen-stmt-ml-549202169) | `mlc/codegen/codegen_stmt.ml:1136` | 7 | 6 | 7 | 8 | 2 | 366.8 | 62.67 |
| [`mlc.codegen.codegen_stmt._breakctx_kind`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-breakctx-kind-inline-function-breakctx-kind-ctx-mlc-codegen-codegen-stmt-ml-404657153) | `mlc/codegen/codegen_stmt.ml:1119` | 4 | 3 | 4 | 3 | 1 | 187.3 | 70.42 |
| [`mlc.codegen.codegen_stmt._breakctx_make`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-breakctx-make-inline-function-breakctx-make-kind-break-label-continue-label-break-depth-continue-depth-mlc-codegen-codegen-stmt-ml-1478139546) | `mlc/codegen/codegen_stmt.ml:1113` | 3 | 1 | 1 | 0 | 0 | 109.39 | 75.18 |
| [`mlc.codegen.codegen_stmt._breakstack_pop`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-breakstack-pop-function-breakstack-pop-state-mlc-codegen-codegen-stmt-ml-1353383254) | `mlc/codegen/codegen_stmt.ml:1160` | 13 | 10 | 5 | 4 | 1 | 431.81 | 56.58 |
| [`mlc.codegen.codegen_stmt._build_constexpr_env`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-build-constexpr-env-function-build-constexpr-env-state-ex-mlc-codegen-codegen-stmt-ml-636233413) | `mlc/codegen/codegen_stmt.ml:3000` | 13 | 8 | 6 | 8 | 3 | 564.12 | 55.63 |
| [`mlc.codegen.codegen_stmt._build_module_init_recs`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-build-module-init-recs-function-build-module-init-recs-state-program-mlc-codegen-codegen-stmt-ml-689602694) | `mlc/codegen/codegen_stmt.ml:8958` | 43 | 39 | 9 | 15 | 3 | 2028.31 | 40 |
| [`mlc.codegen.codegen_stmt._builtin_code_label_for_name`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-builtin-code-label-for-name-function-builtin-code-label-for-name-state-name-mlc-codegen-codegen-stmt-ml-1336912939) | `mlc/codegen/codegen_stmt.ml:8745` | 13 | 12 | 8 | 9 | 2 | 578.25 | 55.28 |
| [`mlc.codegen.codegen_stmt._builtin_specs`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-builtin-specs-function-builtin-specs-mlc-codegen-codegen-stmt-ml-930177065) | `mlc/codegen/codegen_stmt.ml:8345` | 51 | 1 | 1 | 0 | 0 | 3241.96 | 38.03 |
| [`mlc.codegen.codegen_stmt._check_expr_semantics`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-check-expr-semantics-function-check-expr-semantics-state-ex-fn-arities-mlc-codegen-codegen-stmt-ml-1495781577) | `mlc/codegen/codegen_stmt.ml:7921` | 79 | 60 | 38 | 78 | 5 | 4110.26 | 28.19 |
| [`mlc.codegen.codegen_stmt._check_program_semantics`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-check-program-semantics-function-check-program-semantics-state-program-mlc-codegen-codegen-stmt-ml-2131531284) | `mlc/codegen/codegen_stmt.ml:8219` | 8 | 6 | 4 | 3 | 1 | 301.19 | 62.41 |
| [`mlc.codegen.codegen_stmt._check_stmt_semantics`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-check-stmt-semantics-function-check-stmt-semantics-state-st-fn-arities-mlc-codegen-codegen-stmt-ml-1490398137) | `mlc/codegen/codegen_stmt.ml:8011` | 192 | 146 | 121 | 290 | 8 | 10871.22 | 5.66 |
| [`mlc.codegen.codegen_stmt._chunked_len`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-chunked-len-function-chunked-len-chunks-tail-mlc-codegen-codegen-stmt-ml-363434457) | `mlc/codegen/codegen_stmt.ml:212` | 11 | 8 | 5 | 7 | 3 | 390 | 58.47 |
| [`mlc.codegen.codegen_stmt._clear_program_function_state`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-clear-program-function-state-function-clear-program-function-state-state-mlc-codegen-codegen-stmt-ml-1190627538) | `mlc/codegen/codegen_stmt.ml:8679` | 10 | 8 | 1 | 0 | 0 | 343.13 | 60.3 |
| [`mlc.codegen.codegen_stmt._clone_function_node_for_emit`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-clone-function-node-for-emit-function-clone-function-node-for-emit-fn-node-mlc-codegen-codegen-stmt-ml-2006114718) | `mlc/codegen/codegen_stmt.ml:531` | 33 | 3 | 2 | 1 | 1 | 1513.52 | 44.34 |
| [`mlc.codegen.codegen_stmt._closure_analyze_function`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-closure-analyze-function-function-closure-analyze-function-state-fn-node-mlc-codegen-codegen-stmt-ml-1085646639) | `mlc/codegen/codegen_stmt.ml:6766` | 4 | 2 | 1 | 0 | 0 | 97.67 | 72.8 |
| [`mlc.codegen.codegen_stmt._closure_analyze_function_rec`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-closure-analyze-function-rec-function-closure-analyze-function-rec-state-fn-node-outer-scopes-mlc-codegen-codegen-stmt-ml-1774134302) | `mlc/codegen/codegen_stmt.ml:6643` | 107 | 101 | 38 | 102 | 5 | 5506.46 | 24.43 |
| [`mlc.codegen.codegen_stmt._closure_analyze_program`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-closure-analyze-program-function-closure-analyze-program-state-program-mlc-codegen-codegen-stmt-ml-2024264772) | `mlc/codegen/codegen_stmt.ml:6773` | 43 | 33 | 20 | 44 | 5 | 1969 | 38.61 |
| [`mlc.codegen.codegen_stmt._closure_assign_env_layout`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-closure-assign-env-layout-function-closure-assign-env-layout-state-nested-fns-mlc-codegen-codegen-stmt-ml-725571093) | `mlc/codegen/codegen_stmt.ml:6846` | 121 | 111 | 53 | 139 | 5 | 6231.41 | 20.87 |
| [`mlc.codegen.codegen_stmt._closure_collect_all_functions`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-closure-collect-all-functions-function-closure-collect-all-functions-state-nested-fns-mlc-codegen-codegen-stmt-ml-1065698329) | `mlc/codegen/codegen_stmt.ml:6819` | 24 | 14 | 13 | 21 | 4 | 1040.72 | 47.02 |
| [`mlc.codegen.codegen_stmt._closure_collect_locals_and_nested`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-closure-collect-locals-and-nested-function-closure-collect-locals-and-nested-fn-node-mlc-codegen-codegen-stmt-ml-731745426) | `mlc/codegen/codegen_stmt.ml:6205` | 16 | 16 | 9 | 13 | 3 | 845.1 | 52.03 |
| [`mlc.codegen.codegen_stmt._closure_collect_locals_walk`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-closure-collect-locals-walk-function-closure-collect-locals-walk-stmts-locals-set-globals-decl-nested-mlc-codegen-codegen-stmt-ml-1396563895) | `mlc/codegen/codegen_stmt.ml:6091` | 101 | 93 | 43 | 82 | 5 | 5095.6 | 24.54 |
| [`mlc.codegen.codegen_stmt._closure_collect_rbfw_walk`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-closure-collect-rbfw-walk-function-closure-collect-rbfw-walk-stmts-read-before-written-yet-mlc-codegen-codegen-stmt-ml-232031168) | `mlc/codegen/codegen_stmt.ml:6438` | 159 | 144 | 45 | 96 | 6 | 8925.43 | 18.26 |
| [`mlc.codegen.codegen_stmt._closure_collect_read_before_first_write`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-closure-collect-read-before-first-write-function-closure-collect-read-before-first-write-stmts-params-set-mlc-codegen-codegen-stmt-ml-1435465807) | `mlc/codegen/codegen_stmt.ml:6613` | 13 | 12 | 8 | 12 | 3 | 640.3 | 54.97 |
| [`mlc.codegen.codegen_stmt._closure_collect_uses`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-closure-collect-uses-function-closure-collect-uses-stmts-mlc-codegen-codegen-stmt-ml-421357684) | `mlc/codegen/codegen_stmt.ml:6226` | 110 | 91 | 38 | 82 | 6 | 5420.13 | 24.21 |
| [`mlc.codegen.codegen_stmt._closure_collect_writes`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-closure-collect-writes-function-closure-collect-writes-fn-node-mlc-codegen-codegen-stmt-ml-241843266) | `mlc/codegen/codegen_stmt.ml:6351` | 61 | 52 | 28 | 54 | 5 | 2681.29 | 33.28 |
| [`mlc.codegen.codegen_stmt._closure_declare_capture_bindings`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-closure-declare-capture-bindings-function-closure-declare-capture-bindings-state-fn-node-mlc-codegen-codegen-stmt-ml-1321346537) | `mlc/codegen/codegen_stmt.ml:6983` | 61 | 42 | 14 | 18 | 2 | 2357.61 | 35.56 |
| [`mlc.codegen.codegen_stmt._closure_expr_reads`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-closure-expr-reads-function-closure-expr-reads-ex-used-mlc-codegen-codegen-stmt-ml-635722485) | `mlc/codegen/codegen_stmt.ml:6009` | 68 | 56 | 31 | 49 | 4 | 3030.21 | 31.48 |
| [`mlc.codegen.codegen_stmt._closure_owner_for`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-closure-owner-for-function-closure-owner-for-nf-depth-mlc-codegen-codegen-stmt-ml-721565674) | `mlc/codegen/codegen_stmt.ml:6629` | 11 | 12 | 6 | 6 | 2 | 347.11 | 58.69 |
| [`mlc.codegen.codegen_stmt._coerce_name`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-coerce-name-inline-function-coerce-name-v-mlc-codegen-codegen-stmt-ml-848807048) | `mlc/codegen/codegen_stmt.ml:148` | 13 | 14 | 8 | 9 | 2 | 447.08 | 56.07 |
| [`mlc.codegen.codegen_stmt._collect_constexpr_refs`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-collect-constexpr-refs-function-collect-constexpr-refs-ex-vals-mlc-codegen-codegen-stmt-ml-1024720348) | `mlc/codegen/codegen_stmt.ml:2956` | 23 | 22 | 15 | 16 | 2 | 1414.03 | 46.22 |
| [`mlc.codegen.codegen_stmt._collect_decls`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-collect-decls-function-collect-decls-program-mlc-codegen-codegen-stmt-ml-1547961433) | `mlc/codegen/codegen_stmt.ml:4540` | 12 | 10 | 8 | 9 | 2 | 569.45 | 56.09 |
| [`mlc.codegen.codegen_stmt._collect_defer_sites`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-collect-defer-sites-function-collect-defer-sites-state-fn-node-mlc-codegen-codegen-stmt-ml-1872785591) | `mlc/codegen/codegen_stmt.ml:953` | 5 | 3 | 1 | 0 | 0 | 236.84 | 67.99 |
| [`mlc.codegen.codegen_stmt._collect_defer_walk`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-collect-defer-walk-function-collect-defer-walk-state-stmts-in-loop-builder-count-mlc-codegen-codegen-stmt-ml-1036809617) | `mlc/codegen/codegen_stmt.ml:862` | 88 | 73 | 26 | 52 | 5 | 4624.95 | 28.42 |
| [`mlc.codegen.codegen_stmt._collect_function_flow_inputs`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-collect-function-flow-inputs-function-collect-function-flow-inputs-fn-node-analysis-scratch-mlc-codegen-codegen-stmt-ml-397316837) | `mlc/codegen/codegen_stmt.ml:3206` | 154 | 133 | 63 | 112 | 4 | 8963.96 | 16.13 |
| [`mlc.codegen.codegen_stmt._collect_program_decls`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-collect-program-decls-function-collect-program-decls-state-stmts-prefix-current-file-file-prefixes-file-seen-nonpackage-next-sid-next-eid-in-ns-mlc-codegen-codegen-stmt-ml-124981865) | `mlc/codegen/codegen_stmt.ml:7496` | 347 | 300 | 127 | 417 | 8 | 19714.17 | 0 |
| [`mlc.codegen.codegen_stmt._copy_fn_array_field`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-copy-fn-array-field-function-copy-fn-array-field-v-mlc-codegen-codegen-stmt-ml-354764291) | `mlc/codegen/codegen_stmt.ml:516` | 4 | 3 | 2 | 1 | 1 | 83.76 | 73.13 |
| [`mlc.codegen.codegen_stmt._copy_fn_map_or_array_field`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-copy-fn-map-or-array-field-function-copy-fn-map-or-array-field-v-mlc-codegen-codegen-stmt-ml-192376733) | `mlc/codegen/codegen_stmt.ml:523` | 5 | 5 | 3 | 2 | 1 | 148 | 69.15 |
| [`mlc.codegen.codegen_stmt._decl_st_file`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-decl-st-file-inline-function-decl-st-file-st-mlc-codegen-codegen-stmt-ml-1558153623) | `mlc/codegen/codegen_stmt.ml:2886` | 3 | 1 | 1 | 0 | 0 | 51.89 | 77.45 |
| [`mlc.codegen.codegen_stmt._declare_object_top_level_global_bindings`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-declare-object-top-level-global-bindings-function-declare-object-top-level-global-bindings-state-program-mlc-codegen-codegen-stmt-ml-368111222) | `mlc/codegen/codegen_stmt.ml:8272` | 20 | 19 | 13 | 18 | 3 | 1014.68 | 48.82 |
| [`mlc.codegen.codegen_stmt._declare_top_level_global_bindings`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-declare-top-level-global-bindings-function-declare-top-level-global-bindings-state-program-mlc-codegen-codegen-stmt-ml-1166872260) | `mlc/codegen/codegen_stmt.ml:8250` | 15 | 17 | 9 | 12 | 2 | 745.68 | 53.02 |
| [`mlc.codegen.codegen_stmt._defer_capture_node`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-defer-capture-node-function-defer-capture-node-stmt-off-mlc-codegen-codegen-stmt-ml-1024801718) | `mlc/codegen/codegen_stmt.ml:1012` | 3 | 1 | 1 | 0 | 0 | 128 | 74.7 |
| [`mlc.codegen.codegen_stmt._defer_replay_call`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-defer-replay-call-function-defer-replay-call-stmt-mlc-codegen-codegen-stmt-ml-9829135) | `mlc/codegen/codegen_stmt.ml:1018` | 17 | 11 | 5 | 5 | 2 | 1021.54 | 51.42 |
| [`mlc.codegen.codegen_stmt._defer_static_callee`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-defer-static-callee-function-defer-static-callee-state-callee-mlc-codegen-codegen-stmt-ml-538336832) | `mlc/codegen/codegen_stmt.ml:961` | 13 | 14 | 7 | 7 | 2 | 645.97 | 55.08 |
| [`mlc.codegen.codegen_stmt._diag_stmt_loc`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-diag-stmt-loc-function-diag-stmt-loc-st-mlc-codegen-codegen-stmt-ml-705800340) | `mlc/codegen/codegen_stmt.ml:315` | 8 | 9 | 5 | 4 | 1 | 347.11 | 61.84 |
| [`mlc.codegen.codegen_stmt._dotted_name`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-dotted-name-inline-function-dotted-name-parts-mlc-codegen-codegen-stmt-ml-1631006126) | `mlc/codegen/codegen_stmt.ml:2892` | 5 | 5 | 4 | 3 | 1 | 222.91 | 67.77 |
| [`mlc.codegen.codegen_stmt._dotted_name_expr`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-dotted-name-expr-function-dotted-name-expr-ex-mlc-codegen-codegen-stmt-ml-803823796) | `mlc/codegen/codegen_stmt.ml:1399` | 14 | 13 | 6 | 7 | 2 | 461.22 | 55.54 |
| [`mlc.codegen.codegen_stmt._emit_condition_false_jump`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-condition-false-jump-function-emit-condition-false-jump-state-cond-expr-false-label-mlc-codegen-codegen-stmt-ml-1903303146) | `mlc/codegen/codegen_stmt.ml:790` | 11 | 8 | 2 | 1 | 1 | 558.35 | 57.78 |
| [`mlc.codegen.codegen_stmt._emit_condition_nonvoid_guard`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-condition-nonvoid-guard-function-emit-condition-nonvoid-guard-state-cond-expr-ok-label-false-label-mlc-codegen-codegen-stmt-ml-97600581) | `mlc/codegen/codegen_stmt.ml:774` | 12 | 11 | 2 | 1 | 1 | 797.68 | 55.87 |
| [`mlc.codegen.codegen_stmt._emit_control_stmt`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-control-stmt-function-emit-control-stmt-state-stmt-k-mlc-codegen-codegen-stmt-ml-1195429889) | `mlc/codegen/codegen_stmt.ml:2780` | 78 | 69 | 29 | 57 | 4 | 4448.57 | 29.28 |
| [`mlc.codegen.codegen_stmt._emit_defer_cleanup`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-defer-cleanup-function-emit-defer-cleanup-state-sites-ret-off-mlc-codegen-codegen-stmt-ml-2042407121) | `mlc/codegen/codegen_stmt.ml:1038` | 42 | 39 | 5 | 5 | 2 | 2881.35 | 39.69 |
| [`mlc.codegen.codegen_stmt._emit_defer_registration`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-defer-registration-function-emit-defer-registration-state-stmt-mlc-codegen-codegen-stmt-ml-1625606816) | `mlc/codegen/codegen_stmt.ml:977` | 32 | 25 | 8 | 8 | 2 | 1725.84 | 43.43 |
| [`mlc.codegen.codegen_stmt._emit_execution_stmt`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-execution-stmt-function-emit-execution-stmt-state-stmt-k-mlc-codegen-codegen-stmt-ml-1336324873) | `mlc/codegen/codegen_stmt.ml:2063` | 300 | 287 | 14 | 19 | 3 | 27956.43 | 12.95 |
| [`mlc.codegen.codegen_stmt._emit_for_stmt`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-for-stmt-function-emit-for-stmt-state-stmt-mlc-codegen-codegen-stmt-ml-424464908) | `mlc/codegen/codegen_stmt.ml:2401` | 340 | 319 | 27 | 51 | 3 | 29686.1 | 9.83 |
| [`mlc.codegen.codegen_stmt._emit_program_functions_all`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-program-functions-all-function-emit-program-functions-all-state-mlc-codegen-codegen-stmt-ml-117873376) | `mlc/codegen/codegen_stmt.ml:8629` | 37 | 31 | 5 | 7 | 2 | 1145.4 | 43.7 |
| [`mlc.codegen.codegen_stmt._emit_program_module_inits_all`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-program-module-inits-all-function-emit-program-module-inits-all-state-module-init-recs-mlc-codegen-codegen-stmt-ml-863515727) | `mlc/codegen/codegen_stmt.ml:8615` | 11 | 6 | 5 | 7 | 3 | 405.21 | 58.35 |
| [`mlc.codegen.codegen_stmt._emit_program_via_objects`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-program-via-objects-function-emit-program-via-objects-state-program-mlc-codegen-codegen-stmt-ml-981202462) | `mlc/codegen/codegen_stmt.ml:8692` | 21 | 20 | 3 | 2 | 1 | 720.64 | 50.74 |
| [`mlc.codegen.codegen_stmt._emit_static_callable_objects`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-static-callable-objects-function-emit-static-callable-objects-state-mlc-codegen-codegen-stmt-ml-1628342340) | `mlc/codegen/codegen_stmt.ml:8784` | 162 | 157 | 54 | 128 | 5 | 11180.18 | 16.19 |
| [`mlc.codegen.codegen_stmt._emit_static_global_slot_initializers_from_globals`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-static-global-slot-initializers-from-globals-function-emit-static-global-slot-initializers-from-globals-state-mlc-codegen-codegen-stmt-ml-1041849202) | `mlc/codegen/codegen_stmt.ml:8761` | 20 | 21 | 10 | 14 | 2 | 999.42 | 49.27 |
| [`mlc.codegen.codegen_stmt._emit_stmt_list`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-stmt-list-function-emit-stmt-list-state-stmt-seq-emit-mlc-codegen-codegen-stmt-ml-909361712) | `mlc/codegen/codegen_stmt.ml:614` | 17 | 13 | 8 | 10 | 3 | 519.54 | 53.07 |
| [`mlc.codegen.codegen_stmt._emit_storage_stmt`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-storage-stmt-function-emit-storage-stmt-state-stmt-k-mlc-codegen-codegen-stmt-ml-2055789413) | `mlc/codegen/codegen_stmt.ml:1724` | 287 | 265 | 59 | 115 | 5 | 24682.94 | 7.69 |
| [`mlc.codegen.codegen_stmt._emit_struct_field_index_dispatch_local`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-struct-field-index-dispatch-local-function-emit-struct-field-index-dispatch-local-state-field-struct-id-reg-out-reg-ok-label-fail-label-tag-mlc-codegen-codegen-stmt-ml-361373593) | `mlc/codegen/codegen_stmt.ml:1416` | 61 | 52 | 20 | 38 | 4 | 3200.28 | 33.82 |
| [`mlc.codegen.codegen_stmt._emit_switch_stmt`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-switch-stmt-function-emit-switch-stmt-state-stmt-mlc-codegen-codegen-stmt-ml-1805871756) | `mlc/codegen/codegen_stmt.ml:1176` | 200 | 173 | 52 | 129 | 7 | 14579.31 | 13.66 |
| [`mlc.codegen.codegen_stmt._ensure_global_binding_label`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-ensure-global-binding-label-function-ensure-global-binding-label-state-qname-decl-node-mlc-codegen-codegen-stmt-ml-1483960385) | `mlc/codegen/codegen_stmt.ml:8240` | 7 | 6 | 2 | 1 | 1 | 258.65 | 64.4 |
| [`mlc.codegen.codegen_stmt._eval_constexpr`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-eval-constexpr-function-eval-constexpr-state-ex-env-mlc-codegen-codegen-stmt-ml-1797563284) | `mlc/codegen/codegen_stmt.ml:3016` | 3 | 1 | 1 | 0 | 0 | 74.01 | 76.37 |
| [`mlc.codegen.codegen_stmt._expr_to_qualname`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-expr-to-qualname-function-expr-to-qualname-state-ex-mlc-codegen-codegen-stmt-ml-1076155755) | `mlc/codegen/codegen_stmt.ml:2913` | 3 | 1 | 1 | 0 | 0 | 62.27 | 76.89 |
| [`mlc.codegen.codegen_stmt._expr_uses_native_threads`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-expr-uses-native-threads-function-expr-uses-native-threads-ex-mlc-codegen-codegen-stmt-ml-206341088) | `mlc/codegen/codegen_stmt.ml:9004` | 39 | 37 | 24 | 40 | 4 | 1882.84 | 39.13 |
| [`mlc.codegen.codegen_stmt._expr_uses_this`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-expr-uses-this-function-expr-uses-this-ex-mlc-codegen-codegen-stmt-ml-81408054) | `mlc/codegen/codegen_stmt.ml:7099` | 72 | 76 | 47 | 87 | 4 | 3793.39 | 28.1 |
| [`mlc.codegen.codegen_stmt._fast_index_scan_expr`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-fast-index-scan-expr-function-fast-index-scan-expr-ex-index-name-targets-mlc-codegen-codegen-stmt-ml-147632448) | `mlc/codegen/codegen_stmt.ml:4040` | 24 | 40 | 20 | 22 | 2 | 2457.28 | 43.46 |
| [`mlc.codegen.codegen_stmt._fast_index_scan_loop`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-fast-index-scan-loop-function-fast-index-scan-loop-loop-node-index-name-mlc-codegen-codegen-stmt-ml-886051400) | `mlc/codegen/codegen_stmt.ml:4067` | 33 | 48 | 20 | 33 | 3 | 2825.6 | 40.02 |
| [`mlc.codegen.codegen_stmt._fast_target_add`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-fast-target-add-function-fast-target-add-items-name-expr-mlc-codegen-codegen-stmt-ml-549244681) | `mlc/codegen/codegen_stmt.ml:4031` | 6 | 9 | 6 | 8 | 3 | 398.35 | 64.01 |
| [`mlc.codegen.codegen_stmt._flatten_member_chain`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-flatten-member-chain-function-flatten-member-chain-state-ex-mlc-codegen-codegen-stmt-ml-916530405) | `mlc/codegen/codegen_stmt.ml:2919` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.codegen.codegen_stmt._flatten_runtime`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-flatten-runtime-function-flatten-runtime-state-value-mlc-codegen-codegen-stmt-ml-1300938143) | `mlc/codegen/codegen_stmt.ml:4950` | 3 | 1 | 1 | 0 | 0 | 69.19 | 76.57 |
| [`mlc.codegen.codegen_stmt._flatten_runtime_inner`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-flatten-runtime-inner-function-flatten-runtime-inner-state-stmts-prefix-current-file-mlc-codegen-codegen-stmt-ml-1587557733) | `mlc/codegen/codegen_stmt.ml:4836` | 100 | 83 | 41 | 96 | 7 | 4504.62 | 25.27 |
| [`mlc.codegen.codegen_stmt._fn_arity_map`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-fn-arity-map-function-fn-arity-map-state-mlc-codegen-codegen-stmt-ml-381953794) | `mlc/codegen/codegen_stmt.ml:7883` | 19 | 19 | 10 | 13 | 2 | 851.92 | 50.24 |
| [`mlc.codegen.codegen_stmt._fn_codegen_key`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-fn-codegen-key-inline-function-fn-codegen-key-fn-node-mlc-codegen-codegen-stmt-ml-448184147) | `mlc/codegen/codegen_stmt.ml:164` | 8 | 8 | 3 | 2 | 1 | 313.82 | 62.41 |
| [`mlc.codegen.codegen_stmt._fn_codegen_name`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-fn-codegen-name-inline-function-fn-codegen-name-state-fn-node-mlc-codegen-codegen-stmt-ml-176705580) | `mlc/codegen/codegen_stmt.ml:175` | 9 | 8 | 6 | 6 | 2 | 393.5 | 60.21 |
| [`mlc.codegen.codegen_stmt._for_end_proves_index_bounds`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-for-end-proves-index-bounds-function-for-end-proves-index-bounds-state-loop-node-target-name-exact-len-start-value-mlc-codegen-codegen-stmt-ml-643445787) | `mlc/codegen/codegen_stmt.ml:4103` | 15 | 19 | 13 | 12 | 1 | 1283.46 | 50.83 |
| [`mlc.codegen.codegen_stmt._for_index_hoist_plans`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-for-index-hoist-plans-function-for-index-hoist-plans-state-loop-node-index-binding-mlc-codegen-codegen-stmt-ml-877679523) | `mlc/codegen/codegen_stmt.ml:4121` | 32 | 43 | 23 | 30 | 3 | 2373.18 | 40.44 |
| [`mlc.codegen.codegen_stmt._for_state_names`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-for-state-names-function-for-state-names-st-mlc-codegen-codegen-stmt-ml-783394484) | `mlc/codegen/codegen_stmt.ml:3094` | 15 | 9 | 4 | 5 | 2 | 395 | 55.63 |
| [`mlc.codegen.codegen_stmt._for_unroll_body_ok`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-for-unroll-body-ok-function-for-unroll-body-ok-stmts-loop-var-mlc-codegen-codegen-stmt-ml-674583386) | `mlc/codegen/codegen_stmt.ml:731` | 3 | 1 | 1 | 0 | 0 | 74.01 | 76.37 |
| [`mlc.codegen.codegen_stmt._for_unroll_body_ok_budget`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-for-unroll-body-ok-budget-function-for-unroll-body-ok-budget-stmts-loop-var-budget-mlc-codegen-codegen-stmt-ml-1024577895) | `mlc/codegen/codegen_stmt.ml:693` | 35 | 36 | 32 | 64 | 6 | 2139.72 | 38.69 |
| [`mlc.codegen.codegen_stmt._for_unroll_budget_take`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-for-unroll-budget-take-function-for-unroll-budget-take-budget-mlc-codegen-codegen-stmt-ml-168957252) | `mlc/codegen/codegen_stmt.ml:649` | 5 | 4 | 4 | 3 | 1 | 208.08 | 67.98 |
| [`mlc.codegen.codegen_stmt._for_unroll_expr_child_ok`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-for-unroll-expr-child-ok-function-for-unroll-expr-child-ok-child-budget-mlc-codegen-codegen-stmt-ml-1470564306) | `mlc/codegen/codegen_stmt.ml:657` | 12 | 9 | 7 | 12 | 4 | 482.15 | 56.73 |
| [`mlc.codegen.codegen_stmt._for_unroll_expr_ok`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-for-unroll-expr-ok-function-for-unroll-expr-ok-expr-budget-mlc-codegen-codegen-stmt-ml-1099314987) | `mlc/codegen/codegen_stmt.ml:672` | 18 | 31 | 17 | 16 | 1 | 1494.11 | 48.1 |
| [`mlc.codegen.codegen_stmt._for_unroll_values`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-for-unroll-values-function-for-unroll-values-state-s-mlc-codegen-codegen-stmt-ml-2038202727) | `mlc/codegen/codegen_stmt.ml:737` | 30 | 30 | 11 | 12 | 2 | 1027.18 | 45.21 |
| [`mlc.codegen.codegen_stmt._foreach_body`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-foreach-body-inline-function-foreach-body-st-mlc-codegen-codegen-stmt-ml-874591791) | `mlc/codegen/codegen_stmt.ml:603` | 8 | 4 | 5 | 5 | 2 | 240.81 | 62.95 |
| [`mlc.codegen.codegen_stmt._foreach_load_dword_eax`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-foreach-load-dword-eax-function-foreach-load-dword-eax-state-name-mlc-codegen-codegen-stmt-ml-1807123531) | `mlc/codegen/codegen_stmt.ml:1098` | 12 | 8 | 5 | 5 | 2 | 478.22 | 57.02 |
| [`mlc.codegen.codegen_stmt._foreach_state_names`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-foreach-state-names-function-foreach-state-names-st-mlc-codegen-codegen-stmt-ml-887966688) | `mlc/codegen/codegen_stmt.ml:3071` | 19 | 10 | 4 | 5 | 2 | 485.97 | 52.76 |
| [`mlc.codegen.codegen_stmt._foreach_store_dword_eax`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-foreach-store-dword-eax-function-foreach-store-dword-eax-state-name-mlc-codegen-codegen-stmt-ml-141710227) | `mlc/codegen/codegen_stmt.ml:1083` | 12 | 8 | 5 | 5 | 2 | 478.22 | 57.02 |
| [`mlc.codegen.codegen_stmt._foreach_var_name`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-foreach-var-name-function-foreach-var-name-st-mlc-codegen-codegen-stmt-ml-2036267774) | `mlc/codegen/codegen_stmt.ml:3065` | 3 | 1 | 1 | 0 | 0 | 46.51 | 77.78 |
| [`mlc.codegen.codegen_stmt._forget_nested_function_by_codegen_name`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-forget-nested-function-by-codegen-name-function-forget-nested-function-by-codegen-name-state-code-name-mlc-codegen-codegen-stmt-ml-556689205) | `mlc/codegen/codegen_stmt.ml:567` | 14 | 12 | 6 | 7 | 2 | 457.87 | 55.56 |
| [`mlc.codegen.codegen_stmt._func_global_mapped_name`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-func-global-mapped-name-function-func-global-mapped-name-state-name-mlc-codegen-codegen-stmt-ml-1309857527) | `mlc/codegen/codegen_stmt.ml:5256` | 14 | 11 | 10 | 13 | 3 | 675.05 | 53.84 |
| [`mlc.codegen.codegen_stmt._group_program_by_file`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-group-program-by-file-function-group-program-by-file-program-mlc-codegen-codegen-stmt-ml-619418709) | `mlc/codegen/codegen_stmt.ml:4956` | 21 | 18 | 8 | 9 | 2 | 698.07 | 50.17 |
| [`mlc.codegen.codegen_stmt._has_dot_name`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-has-dot-name-inline-function-has-dot-name-name-mlc-codegen-codegen-stmt-ml-571851239) | `mlc/codegen/codegen_stmt.ml:7442` | 7 | 6 | 4 | 4 | 2 | 223.48 | 64.58 |
| [`mlc.codegen.codegen_stmt._has_reserved_segment`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-has-reserved-segment-function-has-reserved-segment-state-name-mlc-codegen-codegen-stmt-ml-1563784123) | `mlc/codegen/codegen_stmt.ml:4523` | 14 | 13 | 9 | 14 | 4 | 645.5 | 54.11 |
| [`mlc.codegen.codegen_stmt._heap_cfg_get_any`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-heap-cfg-get-any-function-heap-cfg-get-any-state-key-mlc-codegen-codegen-stmt-ml-1697445733) | `mlc/codegen/codegen_stmt.ml:226` | 15 | 12 | 12 | 13 | 2 | 703.28 | 52.8 |
| [`mlc.codegen.codegen_stmt._heap_cfg_get_bool`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-heap-cfg-get-bool-inline-function-heap-cfg-get-bool-state-key-defaultv-mlc-codegen-codegen-stmt-ml-358808291) | `mlc/codegen/codegen_stmt.ml:252` | 5 | 4 | 2 | 1 | 1 | 144.43 | 69.36 |
| [`mlc.codegen.codegen_stmt._heap_cfg_get_int`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-heap-cfg-get-int-inline-function-heap-cfg-get-int-state-key-defaultv-mlc-codegen-codegen-stmt-ml-524944701) | `mlc/codegen/codegen_stmt.ml:244` | 5 | 4 | 2 | 1 | 1 | 144.43 | 69.36 |
| [`mlc.codegen.codegen_stmt._id_label_pair_id`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-id-label-pair-id-function-id-label-pair-id-it-mlc-codegen-codegen-stmt-ml-708505754) | `mlc/codegen/codegen_stmt.ml:5273` | 9 | 5 | 6 | 5 | 1 | 301.85 | 61.01 |
| [`mlc.codegen.codegen_stmt._infer_known_int_names`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-infer-known-int-names-function-infer-known-int-names-state-fn-node-flow-inputs-analysis-scratch-mlc-codegen-codegen-stmt-ml-2121391122) | `mlc/codegen/codegen_stmt.ml:3371` | 61 | 56 | 29 | 63 | 5 | 3139.28 | 32.67 |
| [`mlc.codegen.codegen_stmt._infer_known_value_types`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-infer-known-value-types-function-infer-known-value-types-state-fn-node-flow-inputs-analysis-scratch-mlc-codegen-codegen-stmt-ml-1006887738) | `mlc/codegen/codegen_stmt.ml:3803` | 119 | 119 | 51 | 91 | 4 | 8329.95 | 20.41 |
| [`mlc.codegen.codegen_stmt._inline_ref_resolve`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-inline-ref-resolve-function-inline-ref-resolve-state-ex-owner-inline-names-mlc-codegen-codegen-stmt-ml-326035508) | `mlc/codegen/codegen_stmt.ml:4275` | 32 | 34 | 16 | 30 | 4 | 1677.56 | 42.44 |
| [`mlc.codegen.codegen_stmt._inline_scan_expr_uses`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-inline-scan-expr-uses-function-inline-scan-expr-uses-state-ex-owner-inline-names-address-taken-mlc-codegen-codegen-stmt-ml-2070699308) | `mlc/codegen/codegen_stmt.ml:4310` | 49 | 55 | 25 | 34 | 3 | 3518.93 | 34.94 |
| [`mlc.codegen.codegen_stmt._inline_scan_stmt_uses`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-inline-scan-stmt-uses-function-inline-scan-stmt-uses-state-stmts-owner-inline-names-address-taken-mlc-codegen-codegen-stmt-ml-1795646560) | `mlc/codegen/codegen_stmt.ml:4363` | 56 | 44 | 20 | 53 | 7 | 3775.94 | 34.13 |
| [`mlc.codegen.codegen_stmt._intflow_const_int`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-intflow-const-int-function-intflow-const-int-state-ex-mlc-codegen-codegen-stmt-ml-403860833) | `mlc/codegen/codegen_stmt.ml:3156` | 8 | 6 | 5 | 4 | 1 | 363.11 | 61.7 |
| [`mlc.codegen.codegen_stmt._intflow_expr_is_int`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-intflow-expr-is-int-function-intflow-expr-is-int-state-ex-known-mlc-codegen-codegen-stmt-ml-392181256) | `mlc/codegen/codegen_stmt.ml:3167` | 35 | 30 | 19 | 23 | 2 | 2258.45 | 40.28 |
| [`mlc.codegen.codegen_stmt._intflow_map_add`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-intflow-map-add-function-intflow-map-add-items-name-value-mlc-codegen-codegen-stmt-ml-623942249) | `mlc/codegen/codegen_stmt.ml:3122` | 17 | 15 | 10 | 15 | 4 | 744.47 | 51.71 |
| [`mlc.codegen.codegen_stmt._intflow_map_get`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-intflow-map-get-function-intflow-map-get-items-name-mlc-codegen-codegen-stmt-ml-1348486260) | `mlc/codegen/codegen_stmt.ml:3142` | 11 | 9 | 8 | 10 | 3 | 475.6 | 57.46 |
| [`mlc.codegen.codegen_stmt._is_constexpr_binary`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-is-constexpr-binary-function-is-constexpr-binary-op-mlc-codegen-codegen-stmt-ml-472368092) | `mlc/codegen/codegen_stmt.ml:2931` | 3 | 1 | 1 | 0 | 0 | 375.64 | 71.43 |
| [`mlc.codegen.codegen_stmt._is_constexpr_expr`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-is-constexpr-expr-function-is-constexpr-expr-state-ex-mlc-codegen-codegen-stmt-ml-1671617385) | `mlc/codegen/codegen_stmt.ml:2937` | 16 | 18 | 11 | 12 | 2 | 817.88 | 51.86 |
| [`mlc.codegen.codegen_stmt._is_constexpr_unary`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-is-constexpr-unary-function-is-constexpr-unary-op-mlc-codegen-codegen-stmt-ml-114885716) | `mlc/codegen/codegen_stmt.ml:2925` | 3 | 1 | 1 | 0 | 0 | 68.11 | 76.62 |
| [`mlc.codegen.codegen_stmt._is_foreach_stmt`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-is-foreach-stmt-function-is-foreach-stmt-st-mlc-codegen-codegen-stmt-ml-100590924) | `mlc/codegen/codegen_stmt.ml:3054` | 8 | 7 | 6 | 6 | 2 | 252.17 | 62.68 |
| [`mlc.codegen.codegen_stmt._is_node`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-is-node-inline-function-is-node-n-kind-mlc-codegen-codegen-stmt-ml-1691255182) | `mlc/codegen/codegen_stmt.ml:2872` | 5 | 5 | 4 | 3 | 1 | 253.32 | 67.38 |
| [`mlc.codegen.codegen_stmt._is_stmt`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-is-stmt-inline-function-is-stmt-st-mlc-codegen-codegen-stmt-ml-790898425) | `mlc/codegen/codegen_stmt.ml:2880` | 3 | 1 | 1 | 0 | 0 | 51.89 | 77.45 |
| [`mlc.codegen.codegen_stmt._join_qname`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-join-qname-inline-function-join-qname-prefix-name-mlc-codegen-codegen-stmt-ml-1575961299) | `mlc/codegen/codegen_stmt.ml:138` | 7 | 5 | 4 | 3 | 1 | 236.84 | 64.4 |
| [`mlc.codegen.codegen_stmt._map_int_get`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-map-int-get-inline-function-map-int-get-arr-key-defaultv-mlc-codegen-codegen-stmt-ml-780366809) | `mlc/codegen/codegen_stmt.ml:5119` | 20 | 18 | 13 | 19 | 3 | 883.44 | 49.24 |
| [`mlc.codegen.codegen_stmt._map_int_items`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-map-int-items-function-map-int-items-arr-mlc-codegen-codegen-stmt-ml-1842411288) | `mlc/codegen/codegen_stmt.ml:5159` | 5 | 5 | 3 | 2 | 1 | 162.63 | 68.87 |
| [`mlc.codegen.codegen_stmt._map_int_set`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-map-int-set-function-map-int-set-arr-key-value-mlc-codegen-codegen-stmt-ml-40779000) | `mlc/codegen/codegen_stmt.ml:5142` | 14 | 11 | 7 | 9 | 3 | 574.88 | 54.73 |
| [`mlc.codegen.codegen_stmt._max_calls_int`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-max-calls-int-inline-function-max-calls-int-a-b-mlc-codegen-codegen-stmt-ml-1266126363) | `mlc/codegen/codegen_stmt.ml:10595` | 4 | 3 | 2 | 1 | 1 | 77.71 | 73.36 |
| [`mlc.codegen.codegen_stmt._maybe_phase_gc`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-maybe-phase-gc-function-maybe-phase-gc-state-tag-min-bytes-mlc-codegen-codegen-stmt-ml-69525466) | `mlc/codegen/codegen_stmt.ml:584` | 14 | 12 | 5 | 4 | 1 | 375 | 56.3 |
| [`mlc.codegen.codegen_stmt._mem_probe`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-mem-probe-function-mem-probe-state-tag-mlc-codegen-codegen-stmt-ml-407291560) | `mlc/codegen/codegen_stmt.ml:201` | 8 | 9 | 4 | 3 | 1 | 466.76 | 61.07 |
| [`mlc.codegen.codegen_stmt._member_chain_name`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-member-chain-name-function-member-chain-name-ex-mlc-codegen-codegen-stmt-ml-537776470) | `mlc/codegen/codegen_stmt.ml:7905` | 13 | 11 | 6 | 6 | 2 | 442.28 | 56.37 |
| [`mlc.codegen.codegen_stmt._member_qname`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-member-qname-function-member-qname-ex-mlc-codegen-codegen-stmt-ml-1970389606) | `mlc/codegen/codegen_stmt.ml:2900` | 10 | 10 | 7 | 7 | 2 | 480.74 | 58.47 |
| [`mlc.codegen.codegen_stmt._module_file_eq`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-module-file-eq-function-module-file-eq-a-b-mlc-codegen-codegen-stmt-ml-346527106) | `mlc/codegen/codegen_stmt.ml:9522` | 6 | 5 | 3 | 2 | 1 | 161.42 | 67.16 |
| [`mlc.codegen.codegen_stmt._module_function_entry_index_add`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-module-function-entry-index-add-function-module-function-entry-index-add-index-module-file-entry-mlc-codegen-codegen-stmt-ml-210430926) | `mlc/codegen/codegen_stmt.ml:9700` | 9 | 10 | 4 | 3 | 1 | 489.31 | 59.81 |
| [`mlc.codegen.codegen_stmt._name_set_add`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-name-set-add-function-name-set-add-setv-value-mlc-codegen-codegen-stmt-ml-811645358) | `mlc/codegen/codegen_stmt.ml:5067` | 9 | 9 | 7 | 7 | 2 | 413.68 | 59.92 |
| [`mlc.codegen.codegen_stmt._name_set_has`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-name-set-has-inline-function-name-set-has-setv-value-mlc-codegen-codegen-stmt-ml-925243813) | `mlc/codegen/codegen_stmt.ml:5059` | 5 | 5 | 4 | 3 | 1 | 238.42 | 67.57 |
| [`mlc.codegen.codegen_stmt._name_set_new`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-name-set-new-inline-function-name-set-new-initial-cap-mlc-codegen-codegen-stmt-ml-992272905) | `mlc/codegen/codegen_stmt.ml:5026` | 3 | 1 | 1 | 0 | 0 | 51.89 | 77.45 |
| [`mlc.codegen.codegen_stmt._name_set_remove`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-name-set-remove-function-name-set-remove-setv-value-mlc-codegen-codegen-stmt-ml-1189746524) | `mlc/codegen/codegen_stmt.ml:5079` | 17 | 15 | 12 | 20 | 4 | 927.1 | 50.77 |
| [`mlc.codegen.codegen_stmt._name_set_size`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-name-set-size-inline-function-name-set-size-setv-mlc-codegen-codegen-stmt-ml-632527980) | `mlc/codegen/codegen_stmt.ml:5032` | 5 | 5 | 3 | 2 | 1 | 178.41 | 68.58 |
| [`mlc.codegen.codegen_stmt._name_set_to_array`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-name-set-to-array-function-name-set-to-array-setv-mlc-codegen-codegen-stmt-ml-596527571) | `mlc/codegen/codegen_stmt.ml:5040` | 16 | 14 | 10 | 18 | 4 | 755.41 | 52.24 |
| [`mlc.codegen.codegen_stmt._name_set_union`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-name-set-union-function-name-set-union-a-b-mlc-codegen-codegen-stmt-ml-602953826) | `mlc/codegen/codegen_stmt.ml:5099` | 17 | 12 | 9 | 10 | 2 | 792.97 | 51.65 |
| [`mlc.codegen.codegen_stmt._named_array_get`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-named-array-get-inline-function-named-array-get-arr-key-mlc-codegen-codegen-stmt-ml-1584479416) | `mlc/codegen/codegen_stmt.ml:7322` | 14 | 11 | 10 | 11 | 2 | 625.13 | 54.08 |
| [`mlc.codegen.codegen_stmt._named_array_set`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-named-array-set-function-named-array-set-arr-key-values-mlc-codegen-codegen-stmt-ml-2133321669) | `mlc/codegen/codegen_stmt.ml:7339` | 18 | 14 | 10 | 14 | 3 | 770.32 | 51.06 |
| [`mlc.codegen.codegen_stmt._named_int_get`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-named-int-get-inline-function-named-int-get-arr-key-defaultv-mlc-codegen-codegen-stmt-ml-1986657559) | `mlc/codegen/codegen_stmt.ml:7360` | 20 | 18 | 13 | 19 | 3 | 883.44 | 49.24 |
| [`mlc.codegen.codegen_stmt._named_int_set`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-named-int-set-function-named-int-set-arr-key-value-mlc-codegen-codegen-stmt-ml-704466436) | `mlc/codegen/codegen_stmt.ml:7383` | 18 | 14 | 10 | 14 | 3 | 770.32 | 51.06 |
| [`mlc.codegen.codegen_stmt._nested_function_codegen_names_sorted`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-nested-function-codegen-names-sorted-function-nested-function-codegen-names-sorted-state-mlc-codegen-codegen-stmt-ml-1868487122) | `mlc/codegen/codegen_stmt.ml:390` | 12 | 12 | 6 | 7 | 2 | 562.54 | 56.4 |
| [`mlc.codegen.codegen_stmt._nested_function_get_by_codegen_name`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-nested-function-get-by-codegen-name-function-nested-function-get-by-codegen-name-state-code-name-mlc-codegen-codegen-stmt-ml-1934076083) | `mlc/codegen/codegen_stmt.ml:377` | 10 | 10 | 6 | 7 | 2 | 401.91 | 59.14 |
| [`mlc.codegen.codegen_stmt._new_analysis_map`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-new-analysis-map-function-new-analysis-map-initial-cap-mlc-codegen-codegen-stmt-ml-1171141238) | `mlc/codegen/codegen_stmt.ml:57` | 3 | 1 | 1 | 0 | 0 | 65.73 | 76.73 |
| [`mlc.codegen.codegen_stmt._new_function_analysis_scratch`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-new-function-analysis-scratch-function-new-function-analysis-scratch-mlc-codegen-codegen-stmt-ml-1130672213) | `mlc/codegen/codegen_stmt.ml:63` | 13 | 1 | 1 | 0 | 0 | 230.51 | 59.02 |
| [`mlc.codegen.codegen_stmt._next_enum_id`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-next-enum-id-function-next-enum-id-state-mlc-codegen-codegen-stmt-ml-1332970734) | `mlc/codegen/codegen_stmt.ml:7420` | 13 | 9 | 7 | 12 | 4 | 443.91 | 56.22 |
| [`mlc.codegen.codegen_stmt._next_struct_id`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-next-struct-id-function-next-struct-id-state-mlc-codegen-codegen-stmt-ml-542310398) | `mlc/codegen/codegen_stmt.ml:7404` | 13 | 9 | 9 | 14 | 4 | 536.57 | 55.38 |
| [`mlc.codegen.codegen_stmt._note_reads`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-note-reads-function-note-reads-read-before-written-yet-names-mlc-codegen-codegen-stmt-ml-1723353151) | `mlc/codegen/codegen_stmt.ml:6421` | 14 | 18 | 14 | 16 | 2 | 879.05 | 52.5 |
| [`mlc.codegen.codegen_stmt._opt_emit_known_setindex`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-opt-emit-known-setindex-function-opt-emit-known-setindex-state-stmt-plan-mlc-codegen-codegen-stmt-ml-1289404053) | `mlc/codegen/codegen_stmt.ml:4156` | 114 | 105 | 13 | 12 | 1 | 9279.78 | 25.6 |
| [`mlc.codegen.codegen_stmt._opt_try_const_int`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-opt-try-const-int-function-opt-try-const-int-state-ex-mlc-codegen-codegen-stmt-ml-1449335133) | `mlc/codegen/codegen_stmt.ml:3113` | 6 | 6 | 3 | 2 | 1 | 220.08 | 66.22 |
| [`mlc.codegen.codegen_stmt._opt_try_truthy`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-opt-try-truthy-function-opt-try-truthy-state-ex-mlc-codegen-codegen-stmt-ml-335132007) | `mlc/codegen/codegen_stmt.ml:3046` | 5 | 4 | 2 | 1 | 1 | 165 | 68.96 |
| [`mlc.codegen.codegen_stmt._owner_for`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-owner-for-function-owner-for-st-mlc-codegen-codegen-stmt-ml-234824292) | `mlc/codegen/codegen_stmt.ml:4490` | 3 | 1 | 1 | 0 | 0 | 36 | 78.56 |
| [`mlc.codegen.codegen_stmt._precompute_top_level_const_bindings`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-precompute-top-level-const-bindings-function-precompute-top-level-const-bindings-state-program-mlc-codegen-codegen-stmt-ml-33778528) | `mlc/codegen/codegen_stmt.ml:8299` | 35 | 37 | 15 | 29 | 3 | 1540.13 | 41.98 |
| [`mlc.codegen.codegen_stmt._pref_is_method_prefix`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-pref-is-method-prefix-function-pref-is-method-prefix-state-pref-mlc-codegen-codegen-stmt-ml-80599409) | `mlc/codegen/codegen_stmt.ml:4502` | 18 | 22 | 13 | 19 | 3 | 1049.48 | 49.72 |
| [`mlc.codegen.codegen_stmt._prepare_function_analysis_scratch`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-prepare-function-analysis-scratch-function-prepare-function-analysis-scratch-value-mlc-codegen-codegen-stmt-ml-1048575006) | `mlc/codegen/codegen_stmt.ml:79` | 7 | 4 | 5 | 4 | 1 | 278.83 | 63.77 |
| [`mlc.codegen.codegen_stmt._prepare_qualify_cache`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-prepare-qualify-cache-function-prepare-qualify-cache-cache-min-cap-mlc-codegen-codegen-stmt-ml-318466726) | `mlc/codegen/codegen_stmt.ml:405` | 16 | 13 | 10 | 12 | 2 | 595 | 52.96 |
| [`mlc.codegen.codegen_stmt._program_main_name`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-program-main-name-function-program-main-name-state-mlc-codegen-codegen-stmt-ml-4678978) | `mlc/codegen/codegen_stmt.ml:8601` | 11 | 6 | 7 | 9 | 3 | 387.64 | 58.22 |
| [`mlc.codegen.codegen_stmt._promotion_scan_stmts`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-promotion-scan-stmts-function-promotion-scan-stmts-hot-names-stmts-loop-depth-mlc-codegen-codegen-stmt-ml-61457264) | `mlc/codegen/codegen_stmt.ml:3941` | 42 | 36 | 24 | 51 | 5 | 2262.65 | 37.87 |
| [`mlc.codegen.codegen_stmt._pyval_to_lit_expr`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-pyval-to-lit-expr-function-pyval-to-lit-expr-v-mlc-codegen-codegen-stmt-ml-734013847) | `mlc/codegen/codegen_stmt.ml:3022` | 3 | 1 | 1 | 0 | 0 | 25.27 | 79.64 |
| [`mlc.codegen.codegen_stmt._qname_parent_prefix`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-qname-parent-prefix-function-qname-parent-prefix-qn-mlc-codegen-codegen-stmt-ml-1260486740) | `mlc/codegen/codegen_stmt.ml:4569` | 10 | 11 | 6 | 6 | 2 | 400 | 59.16 |
| [`mlc.codegen.codegen_stmt._rdata_label_offset`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-rdata-label-offset-function-rdata-label-offset-rb-name-mlc-codegen-codegen-stmt-ml-414070096) | `mlc/codegen/codegen_stmt.ml:634` | 12 | 11 | 8 | 10 | 3 | 544.36 | 56.23 |
| [`mlc.codegen.codegen_stmt._rebuild_lookup_indexes`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-rebuild-lookup-indexes-function-rebuild-lookup-indexes-state-mlc-codegen-codegen-stmt-ml-1362748970) | `mlc/codegen/codegen_stmt.ml:8495` | 27 | 33 | 9 | 8 | 1 | 1911.61 | 44.59 |
| [`mlc.codegen.codegen_stmt._rebuild_module_function_entry_index`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-rebuild-module-function-entry-index-function-rebuild-module-function-entry-index-state-mlc-codegen-codegen-stmt-ml-616471402) | `mlc/codegen/codegen_stmt.ml:9712` | 23 | 19 | 9 | 14 | 3 | 988.72 | 48.11 |
| [`mlc.codegen.codegen_stmt._reindex_aliases`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-reindex-aliases-function-reindex-aliases-arr-cap-hint-mlc-codegen-codegen-stmt-ml-122821840) | `mlc/codegen/codegen_stmt.ml:8469` | 23 | 20 | 11 | 14 | 3 | 948.89 | 47.97 |
| [`mlc.codegen.codegen_stmt._reindex_extern_sigs`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-reindex-extern-sigs-function-reindex-extern-sigs-arr-cap-hint-mlc-codegen-codegen-stmt-ml-1092584560) | `mlc/codegen/codegen_stmt.ml:8453` | 13 | 14 | 8 | 9 | 2 | 620.12 | 55.07 |
| [`mlc.codegen.codegen_stmt._reindex_named_array`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-reindex-named-array-function-reindex-named-array-arr-cap-hint-mlc-codegen-codegen-stmt-ml-40034076) | `mlc/codegen/codegen_stmt.ml:8399` | 23 | 20 | 10 | 13 | 3 | 892.74 | 48.29 |
| [`mlc.codegen.codegen_stmt._reindex_named_int`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-reindex-named-int-function-reindex-named-int-arr-cap-hint-mlc-codegen-codegen-stmt-ml-941787576) | `mlc/codegen/codegen_stmt.ml:8425` | 25 | 21 | 12 | 17 | 3 | 1016.26 | 46.84 |
| [`mlc.codegen.codegen_stmt._release_analysis_map`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-release-analysis-map-function-release-analysis-map-value-initial-cap-retained-cap-mlc-codegen-codegen-stmt-ml-1105537908) | `mlc/codegen/codegen_stmt.ml:102` | 6 | 6 | 4 | 3 | 1 | 291.43 | 65.23 |
| [`mlc.codegen.codegen_stmt._release_analysis_vector`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-release-analysis-vector-function-release-analysis-vector-value-initial-cap-retained-cap-mlc-codegen-codegen-stmt-ml-254467516) | `mlc/codegen/codegen_stmt.ml:89` | 8 | 6 | 4 | 3 | 1 | 305.53 | 62.36 |
| [`mlc.codegen.codegen_stmt._release_emitted_fn_body`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-release-emitted-fn-body-function-release-emitted-fn-body-fn-node-mlc-codegen-codegen-stmt-ml-465330978) | `mlc/codegen/codegen_stmt.ml:440` | 30 | 26 | 8 | 13 | 4 | 993.8 | 45.71 |
| [`mlc.codegen.codegen_stmt._release_emitted_fn_node`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-release-emitted-fn-node-function-release-emitted-fn-node-fn-node-mlc-codegen-codegen-stmt-ml-1428385850) | `mlc/codegen/codegen_stmt.ml:424` | 13 | 12 | 2 | 1 | 1 | 348.29 | 57.63 |
| [`mlc.codegen.codegen_stmt._release_function_analysis_scratch`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-release-function-analysis-scratch-function-release-function-analysis-scratch-value-mlc-codegen-codegen-stmt-ml-2081524866) | `mlc/codegen/codegen_stmt.ml:111` | 13 | 11 | 1 | 0 | 0 | 764.37 | 55.38 |
| [`mlc.codegen.codegen_stmt._reset_analysis_map`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-reset-analysis-map-function-reset-analysis-map-mapv-minimum-capacity-mlc-codegen-codegen-stmt-ml-1891273622) | `mlc/codegen/codegen_stmt.ml:127` | 8 | 6 | 6 | 5 | 1 | 335.2 | 61.81 |
| [`mlc.codegen.codegen_stmt._resolve_const_binding_for_ref`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-resolve-const-binding-for-ref-function-resolve-const-binding-for-ref-state-ref-node-mlc-codegen-codegen-stmt-ml-1586008631) | `mlc/codegen/codegen_stmt.ml:2986` | 11 | 9 | 6 | 8 | 3 | 505.32 | 57.55 |
| [`mlc.codegen.codegen_stmt._resolve_global_target`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-resolve-global-target-function-resolve-global-target-state-name-mlc-codegen-codegen-stmt-ml-908348951) | `mlc/codegen/codegen_stmt.ml:4555` | 11 | 8 | 5 | 5 | 2 | 363.11 | 58.69 |
| [`mlc.codegen.codegen_stmt._resolve_global_target_scan`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-resolve-global-target-scan-function-resolve-global-target-scan-state-raw-qpref-fpref-mlc-codegen-codegen-stmt-ml-2003976959) | `mlc/codegen/codegen_stmt.ml:4582` | 41 | 41 | 24 | 38 | 4 | 2117.27 | 38.3 |
| [`mlc.codegen.codegen_stmt._scan_function_for_global_decls`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-scan-function-for-global-decls-function-scan-function-for-global-decls-state-fn-node-mlc-codegen-codegen-stmt-ml-1138690953) | `mlc/codegen/codegen_stmt.ml:4754` | 20 | 20 | 7 | 7 | 2 | 791.62 | 50.38 |
| [`mlc.codegen.codegen_stmt._scan_stmt_children_into`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-scan-stmt-children-into-function-scan-stmt-children-into-worklist-st-mlc-codegen-codegen-stmt-ml-1034922555) | `mlc/codegen/codegen_stmt.ml:4629` | 40 | 35 | 29 | 44 | 4 | 2232.9 | 37.7 |
| [`mlc.codegen.codegen_stmt._scan_stmt_for_global_decls_lifo`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-scan-stmt-for-global-decls-lifo-function-scan-stmt-for-global-decls-lifo-state-st-qpref-fpref-mlc-codegen-codegen-stmt-ml-1986752124) | `mlc/codegen/codegen_stmt.ml:4675` | 64 | 52 | 26 | 37 | 3 | 2978.45 | 32.78 |
| [`mlc.codegen.codegen_stmt._select_promoted_local_registers`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-select-promoted-local-registers-function-select-promoted-local-registers-state-fn-node-known-types-shared-hot-names-analysis-scratch-mlc-codegen-codegen-stmt-ml-1360027211) | `mlc/codegen/codegen_stmt.ml:3986` | 42 | 42 | 18 | 33 | 3 | 2388.45 | 38.52 |
| [`mlc.codegen.codegen_stmt._set_const_binding_value`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-set-const-binding-value-function-set-const-binding-value-state-b-or-name-pyv-mlc-codegen-codegen-stmt-ml-36059455) | `mlc/codegen/codegen_stmt.ml:3028` | 9 | 5 | 4 | 3 | 1 | 289.89 | 61.41 |
| [`mlc.codegen.codegen_stmt._set_fn_codegen_name`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-set-fn-codegen-name-function-set-fn-codegen-name-state-fn-node-code-name-mlc-codegen-codegen-stmt-ml-2052609164) | `mlc/codegen/codegen_stmt.ml:187` | 11 | 11 | 6 | 5 | 1 | 451.89 | 57.89 |
| [`mlc.codegen.codegen_stmt._set_user_function`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-set-user-function-function-set-user-function-state-qname-fn-node-mlc-codegen-codegen-stmt-ml-1324041717) | `mlc/codegen/codegen_stmt.ml:260` | 52 | 49 | 23 | 37 | 4 | 2728.98 | 35.41 |
| [`mlc.codegen.codegen_stmt._sort_id_label_pairs`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-sort-id-label-pairs-function-sort-id-label-pairs-vals-mlc-codegen-codegen-stmt-ml-2106345417) | `mlc/codegen/codegen_stmt.ml:5285` | 58 | 50 | 18 | 44 | 5 | 1803.83 | 36.31 |
| [`mlc.codegen.codegen_stmt._sort_names`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-sort-names-function-sort-names-vals-mlc-codegen-codegen-stmt-ml-1712205221) | `mlc/codegen/codegen_stmt.ml:5186` | 62 | 55 | 21 | 38 | 4 | 2288.35 | 34.55 |
| [`mlc.codegen.codegen_stmt._st_file`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-st-file-inline-function-st-file-st-mlc-codegen-codegen-stmt-ml-1471140023) | `mlc/codegen/codegen_stmt.ml:7436` | 3 | 1 | 1 | 0 | 0 | 51.89 | 77.45 |
| [`mlc.codegen.codegen_stmt._static_obj_label_for_global_name`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-static-obj-label-for-global-name-function-static-obj-label-for-global-name-state-name-mlc-codegen-codegen-stmt-ml-1219702007) | `mlc/codegen/codegen_stmt.ml:8729` | 13 | 16 | 6 | 5 | 1 | 467.67 | 56.2 |
| [`mlc.codegen.codegen_stmt._stmt_uses_this`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-stmt-uses-this-function-stmt-uses-this-st-mlc-codegen-codegen-stmt-ml-1130920190) | `mlc/codegen/codegen_stmt.ml:7174` | 143 | 145 | 112 | 278 | 7 | 8095.06 | 10.55 |
| [`mlc.codegen.codegen_stmt._stmts_use_native_threads`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-stmts-use-native-threads-function-stmts-use-native-threads-stmts-mlc-codegen-codegen-stmt-ml-1780898312) | `mlc/codegen/codegen_stmt.ml:9046` | 51 | 43 | 31 | 96 | 7 | 2614.48 | 34.65 |
| [`mlc.codegen.codegen_stmt._string_gt`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-string-gt-function-string-gt-a-b-mlc-codegen-codegen-stmt-ml-363027788) | `mlc/codegen/codegen_stmt.ml:5167` | 16 | 16 | 6 | 6 | 2 | 540.54 | 53.79 |
| [`mlc.codegen.codegen_stmt._strpair_get`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-strpair-get-inline-function-strpair-get-arr-key-mlc-codegen-codegen-stmt-ml-401819300) | `mlc/codegen/codegen_stmt.ml:7452` | 20 | 18 | 13 | 19 | 3 | 872.8 | 49.28 |
| [`mlc.codegen.codegen_stmt._strpair_set`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-strpair-set-function-strpair-set-arr-key-value-mlc-codegen-codegen-stmt-ml-737002348) | `mlc/codegen/codegen_stmt.ml:7475` | 18 | 11 | 12 | 20 | 4 | 940.8 | 50.18 |
| [`mlc.codegen.codegen_stmt._struct_methods_any_has`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-struct-methods-any-has-function-struct-methods-any-has-state-mname-mlc-codegen-codegen-stmt-ml-789775902) | `mlc/codegen/codegen_stmt.ml:10578` | 14 | 17 | 10 | 12 | 2 | 737.97 | 53.57 |
| [`mlc.codegen.codegen_stmt._synchronized_block_has_crossing_exit`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-synchronized-block-has-crossing-exit-function-synchronized-block-has-crossing-exit-stmts-break-depth-loop-depth-mlc-codegen-codegen-stmt-ml-1495297325) | `mlc/codegen/codegen_stmt.ml:814` | 45 | 44 | 31 | 64 | 5 | 2493.16 | 35.98 |
| [`mlc.codegen.codegen_stmt._tag_ns`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-tag-ns-function-tag-ns-ns-name-mlc-codegen-codegen-stmt-ml-1295770015) | `mlc/codegen/codegen_stmt.ml:4496` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.codegen.codegen_stmt._tag_ns_prefix`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-tag-ns-prefix-function-tag-ns-prefix-node-pref-mlc-codegen-codegen-stmt-ml-1554950438) | `mlc/codegen/codegen_stmt.ml:4827` | 6 | 3 | 3 | 2 | 1 | 140.18 | 67.59 |
| [`mlc.codegen.codegen_stmt._truthy`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-truthy-function-truthy-v-mlc-codegen-codegen-stmt-ml-1730986865) | `mlc/codegen/codegen_stmt.ml:3040` | 3 | 1 | 1 | 0 | 0 | 46.51 | 77.78 |
| [`mlc.codegen.codegen_stmt._typeflow_base`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-typeflow-base-inline-function-typeflow-base-type-name-mlc-codegen-codegen-stmt-ml-471557554) | `mlc/codegen/codegen_stmt.ml:3447` | 7 | 6 | 5 | 5 | 2 | 297.25 | 63.58 |
| [`mlc.codegen.codegen_stmt._typeflow_dependency_add`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-typeflow-dependency-add-function-typeflow-dependency-add-dependents-dependency-owner-mlc-codegen-codegen-stmt-ml-395466257) | `mlc/codegen/codegen_stmt.ml:3762` | 10 | 9 | 5 | 4 | 1 | 408.07 | 59.23 |
| [`mlc.codegen.codegen_stmt._typeflow_exact_length`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-typeflow-exact-length-function-typeflow-exact-length-type-name-mlc-codegen-codegen-stmt-ml-700789855) | `mlc/codegen/codegen_stmt.ml:3457` | 14 | 17 | 10 | 10 | 2 | 748.82 | 53.53 |
| [`mlc.codegen.codegen_stmt._typeflow_expr_type`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-typeflow-expr-type-function-typeflow-expr-type-state-ex-known-mlc-codegen-codegen-stmt-ml-327640540) | `mlc/codegen/codegen_stmt.ml:3534` | 109 | 132 | 113 | 163 | 4 | 8912.07 | 12.7 |
| [`mlc.codegen.codegen_stmt._typeflow_get`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-typeflow-get-function-typeflow-get-items-name-mlc-codegen-codegen-stmt-ml-612873736) | `mlc/codegen/codegen_stmt.ml:3474` | 13 | 12 | 10 | 11 | 2 | 650.74 | 54.66 |
| [`mlc.codegen.codegen_stmt._typeflow_merge`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-typeflow-merge-function-typeflow-merge-inferred-mlc-codegen-codegen-stmt-ml-1861371564) | `mlc/codegen/codegen_stmt.ml:3649` | 21 | 27 | 19 | 22 | 2 | 965.22 | 47.7 |
| [`mlc.codegen.codegen_stmt._typeflow_remove`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-typeflow-remove-function-typeflow-remove-items-name-mlc-codegen-codegen-stmt-ml-747969520) | `mlc/codegen/codegen_stmt.ml:3506` | 9 | 8 | 7 | 7 | 2 | 416.15 | 59.9 |
| [`mlc.codegen.codegen_stmt._typeflow_scan_expr_dependencies`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-typeflow-scan-expr-dependencies-function-typeflow-scan-expr-dependencies-dependents-owner-ex-mlc-codegen-codegen-stmt-ml-1574720999) | `mlc/codegen/codegen_stmt.ml:3775` | 25 | 38 | 17 | 20 | 3 | 2170.7 | 43.86 |
| [`mlc.codegen.codegen_stmt._typeflow_scan_read_expr`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-typeflow-scan-read-expr-function-typeflow-scan-read-expr-ex-tracked-initialized-read-before-mlc-codegen-codegen-stmt-ml-184513138) | `mlc/codegen/codegen_stmt.ml:3673` | 27 | 41 | 19 | 23 | 3 | 2441.22 | 42.5 |
| [`mlc.codegen.codegen_stmt._typeflow_scan_read_order`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-typeflow-scan-read-order-function-typeflow-scan-read-order-stmts-tracked-initialized-read-before-direct-mlc-codegen-codegen-stmt-ml-1105561529) | `mlc/codegen/codegen_stmt.ml:3703` | 53 | 52 | 22 | 37 | 4 | 3495.89 | 34.62 |
| [`mlc.codegen.codegen_stmt._typeflow_set`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-typeflow-set-function-typeflow-set-items-name-value-mlc-codegen-codegen-stmt-ml-1071418125) | `mlc/codegen/codegen_stmt.ml:3490` | 13 | 9 | 7 | 9 | 3 | 495 | 55.89 |
| [`mlc.codegen.codegen_stmt._typeflow_struct_qname`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-typeflow-struct-qname-function-typeflow-struct-qname-state-callee-mlc-codegen-codegen-stmt-ml-440133360) | `mlc/codegen/codegen_stmt.ml:3518` | 11 | 13 | 6 | 5 | 1 | 646.24 | 56.8 |
| [`mlc.codegen.codegen_stmt._user_function_get_node`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-user-function-get-node-function-user-function-get-node-state-qname-mlc-codegen-codegen-stmt-ml-282345418) | `mlc/codegen/codegen_stmt.ml:326` | 26 | 24 | 19 | 25 | 3 | 1425.08 | 44.5 |
| [`mlc.codegen.codegen_stmt._user_function_has`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-user-function-has-inline-function-user-function-has-state-qname-mlc-codegen-codegen-stmt-ml-1533091489) | `mlc/codegen/codegen_stmt.ml:7059` | 37 | 32 | 20 | 30 | 3 | 1803.78 | 40.3 |
| [`mlc.codegen.codegen_stmt._user_function_keys_sorted`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-user-function-keys-sorted-function-user-function-keys-sorted-state-mlc-codegen-codegen-stmt-ml-1002511518) | `mlc/codegen/codegen_stmt.ml:355` | 19 | 16 | 10 | 11 | 2 | 911.39 | 50.04 |
| [`mlc.codegen.codegen_stmt._walk_stmt`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-walk-stmt-function-walk-stmt-st-vals-mlc-codegen-codegen-stmt-ml-950371960) | `mlc/codegen/codegen_stmt.ml:4816` | 8 | 5 | 3 | 2 | 1 | 280.54 | 62.76 |
| [`mlc.codegen.codegen_stmt._walk_stmt_into`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-walk-stmt-into-function-walk-stmt-into-st-vals-b-mlc-codegen-codegen-stmt-ml-781870235) | `mlc/codegen/codegen_stmt.ml:4781` | 31 | 25 | 12 | 14 | 2 | 1165.04 | 44.38 |
| [`mlc.codegen.codegen_stmt.add`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-add-function-add-arr-value-mlc-codegen-codegen-stmt-ml-1901574475) | `mlc/codegen/codegen_stmt.ml:10474` | 8 | 8 | 5 | 5 | 2 | 323.33 | 62.05 |
| [`mlc.codegen.codegen_stmt.all_function_entries`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-all-function-entries-function-all-function-entries-state-mlc-codegen-codegen-stmt-ml-1219167550) | `mlc/codegen/codegen_stmt.ml:8595` | 3 | 1 | 1 | 0 | 0 | 36 | 78.56 |
| [`mlc.codegen.codegen_stmt.analyze_block`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-analyze-block-function-analyze-block-state-stmts-mlc-codegen-codegen-stmt-ml-1663709957) | `mlc/codegen/codegen_stmt.ml:10544` | 11 | 8 | 6 | 6 | 2 | 479.27 | 57.71 |
| [`mlc.codegen.codegen_stmt.analyze_expr`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-analyze-expr-function-analyze-expr-state-ex-mlc-codegen-codegen-stmt-ml-2070285797) | `mlc/codegen/codegen_stmt.ml:10505` | 35 | 26 | 14 | 17 | 3 | 1497.37 | 42.2 |
| [`mlc.codegen.codegen_stmt.analyze_read_var`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-analyze-read-var-function-analyze-read-var-state-name-mlc-codegen-codegen-stmt-ml-1275782887) | `mlc/codegen/codegen_stmt.ml:10486` | 3 | 1 | 1 | 0 | 0 | 34.87 | 78.66 |
| [`mlc.codegen.codegen_stmt.analyze_write_var`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-analyze-write-var-function-analyze-write-var-state-name-mlc-codegen-codegen-stmt-ml-1115907147) | `mlc/codegen/codegen_stmt.ml:10493` | 8 | 8 | 3 | 2 | 1 | 364.35 | 61.96 |
| [`mlc.codegen.codegen_stmt.cg_emit_stmt`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-cg-emit-stmt-function-cg-emit-stmt-state-stmt-mlc-codegen-codegen-stmt-ml-328079108) | `mlc/codegen/codegen_stmt.ml:1488` | 203 | 182 | 70 | 110 | 4 | 13608.04 | 11.3 |
| [`mlc.codegen.codegen_stmt.emit_entry_object`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-entry-object-function-emit-entry-object-state-module-init-recs-max-call-args-main-main-name-mlc-codegen-codegen-stmt-ml-891805571) | `mlc/codegen/codegen_stmt.ml:9384` | 111 | 106 | 17 | 26 | 4 | 8222.38 | 25.68 |
| [`mlc.codegen.codegen_stmt.emit_module_function_entries`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-module-function-entries-function-emit-module-function-entries-state-entries-start-index-count-analysis-scratch-mlc-codegen-codegen-stmt-ml-1569217191) | `mlc/codegen/codegen_stmt.ml:9783` | 33 | 29 | 14 | 20 | 4 | 1248.81 | 43.31 |
| [`mlc.codegen.codegen_stmt.emit_module_functions`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-module-functions-function-emit-module-functions-state-module-file-mlc-codegen-codegen-stmt-ml-678832221) | `mlc/codegen/codegen_stmt.ml:9820` | 4 | 2 | 1 | 0 | 0 | 140 | 71.7 |
| [`mlc.codegen.codegen_stmt.emit_module_init_object`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-module-init-object-function-emit-module-init-object-state-module-rec-mlc-codegen-codegen-stmt-ml-2076069695) | `mlc/codegen/codegen_stmt.ml:9532` | 153 | 156 | 20 | 20 | 2 | 9944.53 | 21.66 |
| [`mlc.codegen.codegen_stmt.emit_program`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-program-function-emit-program-state-program-mlc-codegen-codegen-stmt-ml-1271724548) | `mlc/codegen/codegen_stmt.ml:8723` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.codegen.codegen_stmt.emit_stmt`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-stmt-function-emit-stmt-state-st-mlc-codegen-codegen-stmt-ml-1005594799) | `mlc/codegen/codegen_stmt.ml:7053` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.codegen.codegen_stmt.emit_user_function`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-emit-user-function-function-emit-user-function-state-fn-node-analysis-scratch-mlc-codegen-codegen-stmt-ml-731813178) | `mlc/codegen/codegen_stmt.ml:9829` | 584 | 526 | 167 | 312 | 8 | 42147.01 | 0 |
| [`mlc.codegen.codegen_stmt.expr`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-expr-function-expr-state-ex-mlc-codegen-codegen-stmt-ml-841964937) | `mlc/codegen/codegen_stmt.ml:10559` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.codegen.codegen_stmt.expr_reads`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-expr-reads-function-expr-reads-ex-mlc-codegen-codegen-stmt-ml-1421336922) | `mlc/codegen/codegen_stmt.ml:10565` | 3 | 1 | 1 | 0 | 0 | 51.89 | 77.45 |
| [`mlc.codegen.codegen_stmt.function_entry_count`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-function-entry-count-function-function-entry-count-entries-mlc-codegen-codegen-stmt-ml-216196625) | `mlc/codegen/codegen_stmt.ml:8560` | 5 | 5 | 4 | 3 | 1 | 216.1 | 67.87 |
| [`mlc.codegen.codegen_stmt.function_entry_name`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-function-entry-name-function-function-entry-name-entries-node-id-mlc-codegen-codegen-stmt-ml-915095903) | `mlc/codegen/codegen_stmt.ml:8569` | 12 | 11 | 11 | 12 | 2 | 651.42 | 55.28 |
| [`mlc.codegen.codegen_stmt.function_entry_node`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-function-entry-node-function-function-entry-node-entries-node-id-mlc-codegen-codegen-stmt-ml-1036856429) | `mlc/codegen/codegen_stmt.ml:8585` | 7 | 6 | 7 | 7 | 2 | 355.74 | 62.76 |
| [`mlc.codegen.codegen_stmt.max_calls_expr`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-max-calls-expr-function-max-calls-expr-state-ex-mlc-codegen-codegen-stmt-ml-426733429) | `mlc/codegen/codegen_stmt.ml:10603` | 57 | 45 | 23 | 38 | 4 | 2724.4 | 34.55 |
| [`mlc.codegen.codegen_stmt.max_calls_stmts`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-max-calls-stmts-function-max-calls-stmts-state-stmts-mlc-codegen-codegen-stmt-ml-1628904277) | `mlc/codegen/codegen_stmt.ml:10664` | 128 | 108 | 47 | 122 | 8 | 7382.02 | 20.63 |
| [`mlc.codegen.codegen_stmt.module_function_entries`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-module-function-entries-function-module-function-entries-state-module-file-mlc-codegen-codegen-stmt-ml-148202013) | `mlc/codegen/codegen_stmt.ml:9745` | 28 | 26 | 13 | 23 | 3 | 1451.84 | 44.54 |
| [`mlc.codegen.codegen_stmt.note_reads`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-note-reads-function-note-reads-state-names-mlc-codegen-codegen-stmt-ml-1767882344) | `mlc/codegen/codegen_stmt.ml:10572` | 3 | 1 | 1 | 0 | 0 | 34.87 | 78.66 |
| [`mlc.codegen.codegen_stmt.prepare_program_for_objects`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-prepare-program-for-objects-function-prepare-program-for-objects-state-program-mlc-codegen-codegen-stmt-ml-1341937234) | `mlc/codegen/codegen_stmt.ml:9104` | 244 | 232 | 96 | 197 | 5 | 16121.65 | 5.55 |
| [`mlc.codegen.codegen_stmt.release_emitted_function_entries`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-release-emitted-function-entries-function-release-emitted-function-entries-state-entries-start-index-count-mlc-codegen-codegen-stmt-ml-233935854) | `mlc/codegen/codegen_stmt.ml:480` | 33 | 32 | 16 | 31 | 5 | 1433.78 | 42.62 |
| [`mlc.codegen.codegen_stmt.stmt_list`](File-mlc-codegen-codegen-stmt-ml-1158291323.md#function-function-mlc-codegen-codegen-stmt-stmt-list-function-stmt-list-state-stmts-mlc-codegen-codegen-stmt-ml-1329412459) | `mlc/codegen/codegen_stmt.ml:10796` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.codegen.codegen_threads._append_unique`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-append-unique-function-append-unique-values-value-mlc-codegen-codegen-threads-ml-1480911850) | `mlc/codegen/codegen_threads.ml:115` | 8 | 8 | 5 | 5 | 2 | 323.33 | 62.05 |
| [`mlc.codegen.codegen_threads._emit_managed_thread_count_delta`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-managed-thread-count-delta-function-emit-managed-thread-count-delta-state-delta-mlc-codegen-codegen-threads-ml-956712758) | `mlc/codegen/codegen_threads.ml:245` | 16 | 12 | 2 | 1 | 1 | 796.17 | 53.15 |
| [`mlc.codegen.codegen_threads._has_label`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-has-label-function-has-label-labels-name-mlc-codegen-codegen-threads-ml-923041515) | `mlc/codegen/codegen_threads.ml:105` | 7 | 6 | 5 | 5 | 2 | 279.69 | 63.76 |
| [`mlc.codegen.codegen_threads._new_label_id`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-new-label-id-function-new-label-id-state-mlc-codegen-codegen-threads-ml-1951519124) | `mlc/codegen/codegen_threads.ml:126` | 4 | 2 | 1 | 0 | 0 | 71.7 | 73.74 |
| [`mlc.codegen.codegen_threads.emit_gc_managed_exit_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-gc-managed-exit-function-function-emit-gc-managed-exit-function-state-mlc-codegen-codegen-threads-ml-363662000) | `mlc/codegen/codegen_threads.ml:412` | 18 | 16 | 1 | 0 | 0 | 1083.63 | 51.23 |
| [`mlc.codegen.codegen_threads.emit_gc_native_enter_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-gc-native-enter-function-function-emit-gc-native-enter-function-state-mlc-codegen-codegen-threads-ml-1448965312) | `mlc/codegen/codegen_threads.ml:328` | 33 | 31 | 1 | 0 | 0 | 2251.9 | 43.27 |
| [`mlc.codegen.codegen_threads.emit_gc_native_leave_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-gc-native-leave-function-function-emit-gc-native-leave-function-state-mlc-codegen-codegen-threads-ml-2055070818) | `mlc/codegen/codegen_threads.ml:364` | 45 | 43 | 1 | 0 | 0 | 3463.55 | 39.02 |
| [`mlc.codegen.codegen_threads.emit_gc_safepoint_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-gc-safepoint-function-function-emit-gc-safepoint-function-state-mlc-codegen-codegen-threads-ml-380093628) | `mlc/codegen/codegen_threads.ml:264` | 57 | 55 | 1 | 0 | 0 | 4239.37 | 36.16 |
| [`mlc.codegen.codegen_threads.emit_gc_safepoint_poll`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-gc-safepoint-poll-function-emit-gc-safepoint-poll-state-mlc-codegen-codegen-threads-ml-330151080) | `mlc/codegen/codegen_threads.ml:208` | 11 | 10 | 2 | 1 | 1 | 570 | 57.72 |
| [`mlc.codegen.codegen_threads.emit_gc_world_resume_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-gc-world-resume-function-function-emit-gc-world-resume-function-state-mlc-codegen-codegen-threads-ml-1826587852) | `mlc/codegen/codegen_threads.ml:584` | 20 | 18 | 1 | 0 | 0 | 1275.25 | 49.74 |
| [`mlc.codegen.codegen_threads.emit_gc_world_stop_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-gc-world-stop-function-function-emit-gc-world-stop-function-state-mlc-codegen-codegen-threads-ml-1429773454) | `mlc/codegen/codegen_threads.ml:520` | 61 | 59 | 1 | 0 | 0 | 4842.13 | 35.12 |
| [`mlc.codegen.codegen_threads.emit_heap_enter_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-heap-enter-function-function-emit-heap-enter-function-state-mlc-codegen-codegen-threads-ml-1367045632) | `mlc/codegen/codegen_threads.ml:433` | 55 | 53 | 1 | 0 | 0 | 4176 | 36.55 |
| [`mlc.codegen.codegen_threads.emit_heap_leave_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-heap-leave-function-function-emit-heap-leave-function-state-mlc-codegen-codegen-threads-ml-1998760952) | `mlc/codegen/codegen_threads.ml:491` | 26 | 24 | 1 | 0 | 0 | 1851.18 | 46.12 |
| [`mlc.codegen.codegen_threads.emit_sync_enter_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-sync-enter-function-function-emit-sync-enter-function-state-mlc-codegen-codegen-threads-ml-1105104072) | `mlc/codegen/codegen_threads.ml:607` | 16 | 14 | 1 | 0 | 0 | 885 | 52.96 |
| [`mlc.codegen.codegen_threads.emit_sync_init`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-sync-init-function-emit-sync-init-state-mlc-codegen-codegen-threads-ml-304841148) | `mlc/codegen/codegen_threads.ml:170` | 35 | 31 | 3 | 2 | 1 | 3166.5 | 41.4 |
| [`mlc.codegen.codegen_threads.emit_sync_leave_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-sync-leave-function-function-emit-sync-leave-function-state-mlc-codegen-codegen-threads-ml-88544024) | `mlc/codegen/codegen_threads.ml:626` | 14 | 12 | 1 | 0 | 0 | 743.27 | 54.76 |
| [`mlc.codegen.codegen_threads.emit_thread_alive_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-thread-alive-function-function-emit-thread-alive-function-state-mlc-codegen-codegen-threads-ml-2003955440) | `mlc/codegen/codegen_threads.ml:940` | 20 | 18 | 1 | 0 | 0 | 1285.74 | 49.71 |
| [`mlc.codegen.codegen_threads.emit_thread_alloc_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-thread-alloc-function-function-emit-thread-alloc-function-state-mlc-codegen-codegen-threads-ml-1525487468) | `mlc/codegen/codegen_threads.ml:1170` | 6 | 4 | 1 | 0 | 0 | 204.33 | 66.71 |
| [`mlc.codegen.codegen_threads.emit_thread_cancellation_poll`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-thread-cancellation-poll-function-emit-thread-cancellation-poll-state-mlc-codegen-codegen-threads-ml-1629970156) | `mlc/codegen/codegen_threads.ml:222` | 20 | 21 | 5 | 4 | 1 | 1429.75 | 48.85 |
| [`mlc.codegen.codegen_threads.emit_thread_close_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-thread-close-function-function-emit-thread-close-function-state-mlc-codegen-codegen-threads-ml-1564354248) | `mlc/codegen/codegen_threads.ml:1059` | 77 | 74 | 2 | 1 | 1 | 7401.5 | 31.49 |
| [`mlc.codegen.codegen_threads.emit_thread_current_logical_id_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-thread-current-logical-id-function-function-emit-thread-current-logical-id-function-state-mlc-codegen-codegen-threads-ml-710568386) | `mlc/codegen/codegen_threads.ml:1015` | 7 | 5 | 1 | 0 | 0 | 280.93 | 64.29 |
| [`mlc.codegen.codegen_threads.emit_thread_entry_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-thread-entry-function-function-emit-thread-entry-function-state-mlc-codegen-codegen-threads-ml-411978532) | `mlc/codegen/codegen_threads.ml:1179` | 70 | 68 | 1 | 0 | 0 | 6355.72 | 32.99 |
| [`mlc.codegen.codegen_threads.emit_thread_id_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-thread-id-function-function-emit-thread-id-function-state-mlc-codegen-codegen-threads-ml-460353190) | `mlc/codegen/codegen_threads.ml:963` | 8 | 6 | 1 | 0 | 0 | 366.41 | 62.21 |
| [`mlc.codegen.codegen_threads.emit_thread_join_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-thread-join-function-function-emit-thread-join-function-state-mlc-codegen-codegen-threads-ml-168611108) | `mlc/codegen/codegen_threads.ml:844` | 89 | 87 | 1 | 0 | 0 | 8245.17 | 29.92 |
| [`mlc.codegen.codegen_threads.emit_thread_logical_id_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-thread-logical-id-function-function-emit-thread-logical-id-function-state-mlc-codegen-codegen-threads-ml-2085745974) | `mlc/codegen/codegen_threads.ml:974` | 6 | 4 | 1 | 0 | 0 | 225.14 | 66.42 |
| [`mlc.codegen.codegen_threads.emit_thread_new_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-thread-new-function-function-emit-thread-new-function-state-mlc-codegen-codegen-threads-ml-855205780) | `mlc/codegen/codegen_threads.ml:643` | 90 | 87 | 2 | 1 | 1 | 9166.11 | 29.36 |
| [`mlc.codegen.codegen_threads.emit_thread_result_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-thread-result-function-function-emit-thread-result-function-state-mlc-codegen-codegen-threads-ml-991759054) | `mlc/codegen/codegen_threads.ml:1006` | 6 | 4 | 1 | 0 | 0 | 225.14 | 66.42 |
| [`mlc.codegen.codegen_threads.emit_thread_set_logical_id_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-thread-set-logical-id-function-function-emit-thread-set-logical-id-function-state-mlc-codegen-codegen-threads-ml-149940160) | `mlc/codegen/codegen_threads.ml:983` | 20 | 18 | 1 | 0 | 0 | 1361.99 | 49.54 |
| [`mlc.codegen.codegen_threads.emit_thread_start_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-thread-start-function-function-emit-thread-start-function-state-mlc-codegen-codegen-threads-ml-1457904124) | `mlc/codegen/codegen_threads.ml:738` | 63 | 61 | 1 | 0 | 0 | 5853.74 | 34.24 |
| [`mlc.codegen.codegen_threads.emit_thread_status_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-thread-status-function-function-emit-thread-status-function-state-mlc-codegen-codegen-threads-ml-1292778052) | `mlc/codegen/codegen_threads.ml:1025` | 31 | 25 | 5 | 5 | 2 | 2262.65 | 43.31 |
| [`mlc.codegen.codegen_threads.emit_thread_stop_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-thread-stop-function-function-emit-thread-stop-function-state-mlc-codegen-codegen-threads-ml-1794962392) | `mlc/codegen/codegen_threads.ml:806` | 35 | 33 | 1 | 0 | 0 | 2452.46 | 42.45 |
| [`mlc.codegen.codegen_threads.emit_thread_stop_requested_function`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-emit-thread-stop-requested-function-function-emit-thread-stop-requested-function-state-mlc-codegen-codegen-threads-ml-1119595898) | `mlc/codegen/codegen_threads.ml:1147` | 20 | 18 | 1 | 0 | 0 | 1303.87 | 49.67 |
| [`mlc.codegen.codegen_threads.ensure_thread_data`](File-mlc-codegen-codegen-threads-ml-1261658982.md#function-function-mlc-codegen-codegen-threads-ensure-thread-data-function-ensure-thread-data-state-mlc-codegen-codegen-threads-ml-14057176) | `mlc/codegen/codegen_threads.ml:133` | 34 | 23 | 10 | 9 | 1 | 1913.22 | 42.27 |
| [`mlc.compiler._abi_param_type_supported`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-abi-param-type-supported-function-abi-param-type-supported-ty-mlc-compiler-ml-692046171) | `mlc/compiler.ml:5570` | 4 | 2 | 1 | 0 | 0 | 562.62 | 67.48 |
| [`mlc.compiler._abi_return_type_supported`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-abi-return-type-supported-function-abi-return-type-supported-ty-mlc-compiler-ml-855809217) | `mlc/compiler.ml:5577` | 4 | 2 | 1 | 0 | 0 | 440 | 68.22 |
| [`mlc.compiler._add_diag`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-add-diag-function-add-diag-diags-kind-filename-pos-message-mlc-compiler-ml-1139238326) | `mlc/compiler.ml:1361` | 3 | 1 | 1 | 0 | 0 | 120 | 74.9 |
| [`mlc.compiler._add_diag_from_stmt`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-add-diag-from-stmt-function-add-diag-from-stmt-diags-kind-st-fallback-file-message-mlc-compiler-ml-1107149111) | `mlc/compiler.ml:1367` | 3 | 1 | 1 | 0 | 0 | 140.65 | 74.42 |
| [`mlc.compiler._alias_get`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-alias-get-inline-function-alias-get-aliases-key-mlc-compiler-ml-824542376) | `mlc/compiler.ml:1410` | 12 | 11 | 6 | 7 | 2 | 464.08 | 56.98 |
| [`mlc.compiler._alias_set`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-alias-set-function-alias-set-aliases-key-value-mlc-compiler-ml-2126573452) | `mlc/compiler.ml:1425` | 15 | 9 | 5 | 5 | 2 | 495.42 | 54.8 |
| [`mlc.compiler._alias_to_array`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-alias-to-array-function-alias-to-array-aliases-mlc-compiler-ml-1816199482) | `mlc/compiler.ml:1443` | 18 | 15 | 9 | 11 | 3 | 862.77 | 50.85 |
| [`mlc.compiler._append_unique_path`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-append-unique-path-function-append-unique-path-arr-value-mlc-compiler-ml-1766843518) | `mlc/compiler.ml:991` | 10 | 8 | 5 | 7 | 3 | 354.63 | 59.66 |
| [`mlc.compiler._append_zero_pad`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-append-zero-pad-function-append-zero-pad-parts-b-pad-bytes-mlc-compiler-ml-1243409404) | `mlc/compiler.ml:1172` | 4 | 3 | 3 | 2 | 1 | 171.3 | 70.82 |
| [`mlc.compiler._apply_link_patches`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-apply-link-patches-function-apply-link-patches-patches-obj-off-label-map-labels-obj-label-recs-text-rva-rdata-rva-data-rva-bss-rva-image-base-section-buf-is-rel32-patch-index-unknown-prefix-invalid-prefix-mlc-compiler-ml-863587305) | `mlc/compiler.ml:4525` | 72 | 56 | 26 | 50 | 4 | 3303.06 | 31.35 |
| [`mlc.compiler._apply_mlo_patches_from_file`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-apply-mlo-patches-from-file-function-apply-mlo-patches-from-file-src-patch-obj-text-off-obj-rdata-off-obj-data-off-obj-bss-off-label-map-obj-index-map-obj-index-lists-labels-link-patch-recs-text-rva-rdata-rva-data-rva-bss-rva-image-base-buf-rdata-buf-data-buf-patch-index-mlc-compiler-ml-1410354060) | `mlc/compiler.ml:5149` | 293 | 273 | 94 | 230 | 5 | 15192.5 | 4.26 |
| [`mlc.compiler._array_contains`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-array-contains-inline-function-array-contains-arr-value-mlc-compiler-ml-173352891) | `mlc/compiler.ml:699` | 7 | 6 | 4 | 4 | 2 | 230.32 | 64.49 |
| [`mlc.compiler._asm_append_section`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-asm-append-section-function-asm-append-section-bld-name-buf-rva-mlc-compiler-ml-495946549) | `mlc/compiler.ml:7418` | 22 | 21 | 8 | 15 | 3 | 878.12 | 49.03 |
| [`mlc.compiler._asm_db_text`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-asm-db-text-function-asm-db-text-hex-text-mlc-compiler-ml-2037720179) | `mlc/compiler.ml:7403` | 12 | 10 | 3 | 3 | 2 | 317.29 | 58.54 |
| [`mlc.compiler._asm_default_path`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-asm-default-path-function-asm-default-path-output-exe-mlc-compiler-ml-913898962) | `mlc/compiler.ml:7394` | 6 | 3 | 2 | 1 | 1 | 171.3 | 67.12 |
| [`mlc.compiler._auto_import_request`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-auto-import-request-function-auto-import-request-line-mlc-compiler-ml-64664794) | `mlc/compiler.ml:2517` | 21 | 20 | 11 | 12 | 2 | 1083.62 | 48.43 |
| [`mlc.compiler._auto_object_pipeline_score`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-auto-object-pipeline-score-function-auto-object-pipeline-score-input-ml-include-dirs-mlc-compiler-ml-701246303) | `mlc/compiler.ml:2571` | 4 | 2 | 1 | 0 | 0 | 131.69 | 71.89 |
| [`mlc.compiler._auto_object_pipeline_score_visit`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-auto-object-pipeline-score-visit-function-auto-object-pipeline-score-visit-path-include-dirs-seen-score-mlc-compiler-ml-138090143) | `mlc/compiler.ml:2541` | 27 | 29 | 14 | 21 | 4 | 1517.72 | 44.62 |
| [`mlc.compiler._basename`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-basename-inline-function-basename-path-mlc-compiler-ml-1156646834) | `mlc/compiler.ml:1046` | 13 | 11 | 7 | 9 | 3 | 488.4 | 55.93 |
| [`mlc.compiler._bss_label_offset_map`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-bss-label-offset-map-function-bss-label-offset-map-st-mlc-compiler-ml-985219835) | `mlc/compiler.ml:3260` | 16 | 10 | 9 | 11 | 3 | 743.4 | 52.42 |
| [`mlc.compiler._build_line_starts`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-build-line-starts-function-build-line-starts-source-mlc-compiler-ml-1272233503) | `mlc/compiler.ml:439` | 13 | 9 | 5 | 7 | 3 | 462.96 | 56.36 |
| [`mlc.compiler._cfg_get_int`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-cfg-get-int-function-cfg-get-int-cfg-key-defaultv-mlc-compiler-ml-1062035064) | `mlc/compiler.ml:2441` | 15 | 13 | 13 | 18 | 3 | 771 | 52.38 |
| [`mlc.compiler._cfg_set`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-cfg-set-function-cfg-set-cfg-key-value-mlc-compiler-ml-150436822) | `mlc/compiler.ml:2421` | 17 | 12 | 11 | 15 | 3 | 754 | 51.53 |
| [`mlc.compiler._char_code_local`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-char-code-local-function-char-code-local-ch-mlc-compiler-ml-716348357) | `mlc/compiler.ml:4605` | 5 | 4 | 3 | 2 | 1 | 171.9 | 68.7 |
| [`mlc.compiler._check_decl_stmt`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-check-decl-stmt-function-check-decl-stmt-st-module-path-diags-keep-going-max-errors-mlc-compiler-ml-1530621207) | `mlc/compiler.ml:1587` | 47 | 37 | 19 | 41 | 5 | 2153.05 | 37.63 |
| [`mlc.compiler._clear_tmp_obj_dir`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-clear-tmp-obj-dir-function-clear-tmp-obj-dir-tmp-dir-mlc-compiler-ml-1516932251) | `mlc/compiler.ml:1146` | 13 | 14 | 8 | 10 | 2 | 573.26 | 55.31 |
| [`mlc.compiler._cmd_quote_arg`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-cmd-quote-arg-function-cmd-quote-arg-x-mlc-compiler-ml-2062684824) | `mlc/compiler.ml:870` | 31 | 26 | 8 | 14 | 3 | 976.96 | 45.46 |
| [`mlc.compiler._coerce_name`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-coerce-name-function-coerce-name-v-mlc-compiler-ml-454480438) | `mlc/compiler.ml:2857` | 26 | 28 | 13 | 19 | 3 | 1120.51 | 46.03 |
| [`mlc.compiler._collect_compile_defines`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-collect-compile-defines-function-collect-compile-defines-args-mlc-compiler-ml-1044622911) | `mlc/compiler.ml:2578` | 20 | 15 | 9 | 13 | 3 | 928.1 | 49.63 |
| [`mlc.compiler._collect_extern_sigs_walk`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-collect-extern-sigs-walk-function-collect-extern-sigs-walk-stmts-prefix-current-file-file-prefixes-acc-mlc-compiler-ml-206002127) | `mlc/compiler.ml:5864` | 75 | 82 | 36 | 86 | 5 | 3988.67 | 29.04 |
| [`mlc.compiler._collect_extern_structs_walk`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-collect-extern-structs-walk-function-collect-extern-structs-walk-stmts-prefix-current-file-file-prefixes-names-mlc-compiler-ml-1711984290) | `mlc/compiler.ml:5675` | 62 | 65 | 30 | 58 | 3 | 3595.16 | 31.97 |
| [`mlc.compiler._collect_file_package_prefixes`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-collect-file-package-prefixes-function-collect-file-package-prefixes-program-mlc-compiler-ml-361790580) | `mlc/compiler.ml:5629` | 36 | 32 | 13 | 25 | 4 | 1242.99 | 42.63 |
| [`mlc.compiler._collect_include_dirs`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-collect-include-dirs-function-collect-include-dirs-args-mlc-compiler-ml-1090717049) | `mlc/compiler.ml:2286` | 21 | 15 | 7 | 10 | 3 | 635.9 | 50.59 |
| [`mlc.compiler._collect_internal_helper_targets`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-collect-internal-helper-targets-function-collect-internal-helper-targets-dst-patches-mlc-compiler-ml-537354521) | `mlc/compiler.ml:5542` | 16 | 19 | 9 | 12 | 2 | 685.77 | 52.66 |
| [`mlc.compiler._collect_mlo_paths_from_dir`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-collect-mlo-paths-from-dir-function-collect-mlo-paths-from-dir-obj-dir-mlc-compiler-ml-1614947159) | `mlc/compiler.ml:4675` | 26 | 22 | 10 | 14 | 3 | 1091.78 | 46.52 |
| [`mlc.compiler._collect_runtime_config`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-collect-runtime-config-function-collect-runtime-config-args-mlc-compiler-ml-470783061) | `mlc/compiler.ml:2459` | 35 | 32 | 14 | 26 | 4 | 1190.85 | 42.9 |
| [`mlc.compiler._compact_codegen_state_for_pe`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-compact-codegen-state-for-pe-function-compact-codegen-state-for-pe-st-mlc-compiler-ml-417983873) | `mlc/compiler.ml:2645` | 87 | 86 | 2 | 1 | 1 | 3442.97 | 32.66 |
| [`mlc.compiler._compiler_ast_profile_count`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-compiler-ast-profile-count-function-compiler-ast-profile-count-profile-kind-mlc-compiler-ml-1933012955) | `mlc/compiler.ml:558` | 19 | 15 | 5 | 7 | 3 | 635.93 | 51.8 |
| [`mlc.compiler._compiler_ast_profile_report`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-compiler-ast-profile-report-function-compiler-ast-profile-report-program-module-count-mlc-compiler-ml-158976708) | `mlc/compiler.ml:629` | 14 | 11 | 4 | 4 | 2 | 960.71 | 53.58 |
| [`mlc.compiler._compiler_ast_profile_visit_node`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-compiler-ast-profile-visit-node-function-compiler-ast-profile-visit-node-profile-node-depth-mlc-compiler-ml-1944309926) | `mlc/compiler.ml:591` | 34 | 35 | 4 | 3 | 1 | 2940.75 | 41.77 |
| [`mlc.compiler._compiler_ast_profile_visit_value`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-compiler-ast-profile-visit-value-function-compiler-ast-profile-visit-value-profile-value-depth-mlc-compiler-ml-1431652711) | `mlc/compiler.ml:580` | 8 | 7 | 5 | 4 | 1 | 381.47 | 61.55 |
| [`mlc.compiler._compiler_gc_limit_from_config`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-compiler-gc-limit-from-config-function-compiler-gc-limit-from-config-runtime-config-mlc-compiler-ml-807328653) | `mlc/compiler.ml:2500` | 7 | 4 | 2 | 1 | 1 | 131.69 | 66.45 |
| [`mlc.compiler._compiler_profile_finish`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-compiler-profile-finish-function-compiler-profile-finish-mlc-compiler-ml-574503584) | `mlc/compiler.ml:536` | 13 | 11 | 3 | 2 | 1 | 291.48 | 58.04 |
| [`mlc.compiler._compiler_profile_owner`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-compiler-profile-owner-function-compiler-profile-owner-function-name-mlc-compiler-ml-257235730) | `mlc/compiler.ml:648` | 6 | 5 | 2 | 1 | 1 | 191.76 | 66.77 |
| [`mlc.compiler._compiler_profile_phase`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-compiler-profile-phase-function-compiler-profile-phase-msg-mlc-compiler-ml-1978660419) | `mlc/compiler.ml:517` | 12 | 10 | 3 | 2 | 1 | 259.6 | 59.15 |
| [`mlc.compiler._compiler_profile_reset`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-compiler-profile-reset-function-compiler-profile-reset-mlc-compiler-ml-1039725596) | `mlc/compiler.ml:497` | 11 | 10 | 2 | 1 | 1 | 173.92 | 61.33 |
| [`mlc.compiler._concat_bytes_parts`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-concat-bytes-parts-function-concat-bytes-parts-parts-builder-mlc-compiler-ml-217154310) | `mlc/compiler.ml:5463` | 20 | 16 | 9 | 14 | 3 | 819.24 | 50.01 |
| [`mlc.compiler._containsDot`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-containsdot-inline-function-containsdot-txt-mlc-compiler-ml-1491136537) | `mlc/compiler.ml:709` | 7 | 6 | 4 | 4 | 2 | 223.48 | 64.58 |
| [`mlc.compiler._copy_mlo_sections_from_file`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-copy-mlo-sections-from-file-function-copy-mlo-sections-from-file-path-text-buf-text-off-rdata-buf-rdata-off-data-buf-data-off-mlc-compiler-ml-1850064193) | `mlc/compiler.ml:4867` | 27 | 33 | 12 | 12 | 2 | 1378.4 | 45.18 |
| [`mlc.compiler._debug_validate_patch_names`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-debug-validate-patch-names-function-debug-validate-patch-names-label-patches-mlc-compiler-ml-1794564394) | `mlc/compiler.ml:4275` | 16 | 12 | 8 | 9 | 2 | 843.33 | 52.17 |
| [`mlc.compiler._declared_package`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-declared-package-function-declared-package-program-mlc-compiler-ml-740817108) | `mlc/compiler.ml:1642` | 10 | 7 | 7 | 7 | 2 | 386.65 | 59.13 |
| [`mlc.compiler._dirname`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-dirname-inline-function-dirname-path-mlc-compiler-ml-378090410) | `mlc/compiler.ml:1014` | 13 | 11 | 6 | 8 | 3 | 396.82 | 56.7 |
| [`mlc.compiler._dll_base`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-dll-base-function-dll-base-dll-mlc-compiler-ml-225803642) | `mlc/compiler.ml:2851` | 3 | 1 | 1 | 0 | 0 | 101.58 | 75.41 |
| [`mlc.compiler._emit_obj_dir_in_fresh_process`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-emit-obj-dir-in-fresh-process-function-emit-obj-dir-in-fresh-process-args-mlc-compiler-ml-644495903) | `mlc/compiler.ml:6777` | 13 | 12 | 5 | 4 | 1 | 381.56 | 56.95 |
| [`mlc.compiler._endsWith`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-endswith-inline-function-endswith-text-suf-mlc-compiler-ml-1942805904) | `mlc/compiler.ml:687` | 9 | 9 | 6 | 6 | 2 | 431.01 | 59.93 |
| [`mlc.compiler._ensure_dir_recursive`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-ensure-dir-recursive-function-ensure-dir-recursive-path-mlc-compiler-ml-1440746033) | `mlc/compiler.ml:1102` | 13 | 12 | 10 | 10 | 2 | 495.6 | 55.48 |
| [`mlc.compiler._expected_package_for_file`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-expected-package-for-file-function-expected-package-for-file-abs-path-resolved-kind-resolved-root-mlc-compiler-ml-1224950754) | `mlc/compiler.ml:1523` | 7 | 8 | 6 | 5 | 1 | 287.92 | 63.54 |
| [`mlc.compiler._expr_to_qualname`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-expr-to-qualname-function-expr-to-qualname-expr-mlc-compiler-ml-283262203) | `mlc/compiler.ml:1545` | 12 | 10 | 7 | 7 | 2 | 480.74 | 56.74 |
| [`mlc.compiler._extern_physical_abi_class`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-extern-physical-abi-class-function-extern-physical-abi-class-ty-is-out-mlc-compiler-ml-33626924) | `mlc/compiler.ml:5747` | 15 | 10 | 7 | 9 | 2 | 391.38 | 55.25 |
| [`mlc.compiler._extern_struct_field_type_supported`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-extern-struct-field-type-supported-function-extern-struct-field-type-supported-ty-mlc-compiler-ml-299838385) | `mlc/compiler.ml:5584` | 4 | 2 | 1 | 0 | 0 | 323.33 | 69.16 |
| [`mlc.compiler._extern_struct_layout_find`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-extern-struct-layout-find-function-extern-struct-layout-find-layouts-qname-mlc-compiler-ml-1032279295) | `mlc/compiler.ml:5618` | 8 | 7 | 6 | 6 | 2 | 331.93 | 61.84 |
| [`mlc.compiler._extern_struct_type_size`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-extern-struct-type-size-function-extern-struct-type-size-ty-mlc-compiler-ml-674070153) | `mlc/compiler.ml:5607` | 8 | 10 | 13 | 12 | 1 | 457.87 | 59.92 |
| [`mlc.compiler._extern_symbol_default`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-extern-symbol-default-function-extern-symbol-default-qname-mlc-compiler-ml-970146300) | `mlc/compiler.ml:5563` | 4 | 3 | 2 | 1 | 1 | 91.38 | 72.87 |
| [`mlc.compiler._extract_imports`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-extract-imports-function-extract-imports-program-mlc-compiler-ml-284265888) | `mlc/compiler.ml:1655` | 15 | 13 | 6 | 6 | 2 | 645.5 | 53.86 |
| [`mlc.compiler._file_stem`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-file-stem-inline-function-file-stem-path-mlc-compiler-ml-424489790) | `mlc/compiler.ml:1062` | 13 | 11 | 5 | 7 | 3 | 366.61 | 57.07 |
| [`mlc.compiler._filter_non_import_stmts`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-filter-non-import-stmts-function-filter-non-import-stmts-program-mlc-compiler-ml-245481808) | `mlc/compiler.ml:2735` | 14 | 14 | 5 | 5 | 2 | 595 | 54.9 |
| [`mlc.compiler._find_main_name`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-find-main-name-function-find-main-name-state-mlc-compiler-ml-1439989011) | `mlc/compiler.ml:5498` | 10 | 7 | 7 | 7 | 2 | 423.73 | 58.85 |
| [`mlc.compiler._finish_module_mlo`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-finish-module-mlo-function-finish-module-mlo-tmp-dir-obj-index-module-file-entry-label-mod-cg-base-state-helper-union-module-obj-paths-b-mlc-compiler-ml-825171063) | `mlc/compiler.ml:6597` | 30 | 27 | 8 | 9 | 2 | 1686 | 44.11 |
| [`mlc.compiler._fresh_link_gc_limit_from_config`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-fresh-link-gc-limit-from-config-function-fresh-link-gc-limit-from-config-runtime-config-mlc-compiler-ml-1336064053) | `mlc/compiler.ml:2601` | 7 | 7 | 3 | 2 | 1 | 161.42 | 65.7 |
| [`mlc.compiler._front_body_contains_async`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-front-body-contains-async-function-front-body-contains-async-body-mlc-compiler-ml-1702280268) | `mlc/compiler.ml:2133` | 7 | 6 | 5 | 5 | 2 | 256.76 | 64.02 |
| [`mlc.compiler._front_node_contains_async`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-front-node-contains-async-function-front-node-contains-async-node-mlc-compiler-ml-125579356) | `mlc/compiler.ml:2143` | 40 | 36 | 25 | 44 | 4 | 1952.77 | 38.65 |
| [`mlc.compiler._get_flag_value`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-get-flag-value-function-get-flag-value-args-flag-mlc-compiler-ml-1164071017) | `mlc/compiler.ml:483` | 11 | 8 | 4 | 6 | 3 | 266.89 | 59.76 |
| [`mlc.compiler._get_max_errors`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-get-max-errors-function-get-max-errors-args-mlc-compiler-ml-1184557171) | `mlc/compiler.ml:2337` | 14 | 10 | 5 | 10 | 4 | 338.43 | 56.61 |
| [`mlc.compiler._get_self_max_errors`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-get-self-max-errors-function-get-self-max-errors-args-mlc-compiler-ml-837337519) | `mlc/compiler.ml:2320` | 14 | 10 | 5 | 10 | 4 | 338.43 | 56.61 |
| [`mlc.compiler._get_subsystem`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-get-subsystem-function-get-subsystem-args-mlc-compiler-ml-289457571) | `mlc/compiler.ml:2624` | 11 | 8 | 4 | 6 | 3 | 323.33 | 59.17 |
| [`mlc.compiler._get_target`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-get-target-function-get-target-args-mlc-compiler-ml-1708391121) | `mlc/compiler.ml:3383` | 13 | 11 | 6 | 10 | 3 | 499.4 | 56 |
| [`mlc.compiler._has_flag`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-has-flag-function-has-flag-args-flag-mlc-compiler-ml-967893053) | `mlc/compiler.ml:2310` | 7 | 6 | 4 | 4 | 2 | 222.91 | 64.59 |
| [`mlc.compiler._heap_probe`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-heap-probe-function-heap-probe-tag-mlc-compiler-ml-1444294572) | `mlc/compiler.ml:5963` | 7 | 7 | 3 | 2 | 1 | 345 | 63.39 |
| [`mlc.compiler._hex_u32_fixed`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-hex-u32-fixed-function-hex-u32-fixed-value-mlc-compiler-ml-92299427) | `mlc/compiler.ml:7380` | 11 | 8 | 2 | 1 | 1 | 228.23 | 60.5 |
| [`mlc.compiler._imports_to_pe_imports`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-imports-to-pe-imports-function-imports-to-pe-imports-imports-mlc-compiler-ml-900684606) | `mlc/compiler.ml:2825` | 23 | 24 | 11 | 20 | 3 | 1173.92 | 47.32 |
| [`mlc.compiler._is_abs_path`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-is-abs-path-inline-function-is-abs-path-p-mlc-compiler-ml-1545033215) | `mlc/compiler.ml:1004` | 7 | 9 | 10 | 9 | 1 | 456.7 | 61.6 |
| [`mlc.compiler._is_constexpr_binary`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-is-constexpr-binary-function-is-constexpr-binary-op-mlc-compiler-ml-137385609) | `mlc/compiler.ml:1539` | 3 | 1 | 1 | 0 | 0 | 375.64 | 71.43 |
| [`mlc.compiler._is_constexpr_expr`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-is-constexpr-expr-function-is-constexpr-expr-expr-mlc-compiler-ml-1370891045) | `mlc/compiler.ml:1560` | 16 | 18 | 11 | 12 | 2 | 764.26 | 52.07 |
| [`mlc.compiler._is_constexpr_unary`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-is-constexpr-unary-function-is-constexpr-unary-op-mlc-compiler-ml-1449472673) | `mlc/compiler.ml:1533` | 3 | 1 | 1 | 0 | 0 | 68.11 | 76.62 |
| [`mlc.compiler._is_decl_stmt`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-is-decl-stmt-function-is-decl-stmt-st-mlc-compiler-ml-829712851) | `mlc/compiler.ml:1579` | 5 | 4 | 2 | 1 | 1 | 356.7 | 66.61 |
| [`mlc.compiler._is_internal_helper_label_local`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-is-internal-helper-label-local-function-is-internal-helper-label-local-lbl-mlc-compiler-ml-1847962924) | `mlc/compiler.ml:5527` | 9 | 13 | 7 | 6 | 1 | 370.13 | 60.26 |
| [`mlc.compiler._label_get`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-label-get-function-label-get-arr-key-defaultv-mlc-compiler-ml-1399089917) | `mlc/compiler.ml:2758` | 13 | 11 | 7 | 9 | 3 | 462.96 | 56.09 |
| [`mlc.compiler._label_get_chunked`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-label-get-chunked-function-label-get-chunked-chunks-tail-key-defaultv-mlc-compiler-ml-328574482) | `mlc/compiler.ml:2790` | 32 | 24 | 16 | 36 | 6 | 1088.78 | 43.75 |
| [`mlc.compiler._label_key`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-label-key-function-label-key-name-mlc-compiler-ml-1561260305) | `mlc/compiler.ml:5011` | 5 | 4 | 2 | 1 | 1 | 91.38 | 70.75 |
| [`mlc.compiler._label_lookup_fallback`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-label-lookup-fallback-function-label-lookup-fallback-labels-name-defaultv-mlc-compiler-ml-1302650439) | `mlc/compiler.ml:4294` | 26 | 21 | 17 | 32 | 4 | 1136.81 | 45.45 |
| [`mlc.compiler._label_set`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-label-set-function-label-set-arr-key-value-mlc-compiler-ml-605281853) | `mlc/compiler.ml:2774` | 13 | 9 | 6 | 8 | 3 | 474.17 | 56.16 |
| [`mlc.compiler._last_segment_after_dot`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-last-segment-after-dot-inline-function-last-segment-after-dot-txt-mlc-compiler-ml-172396209) | `mlc/compiler.ml:719` | 11 | 8 | 4 | 4 | 2 | 351.75 | 58.92 |
| [`mlc.compiler._link_build_label_maps`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-link-build-label-maps-function-link-build-label-maps-patch-file-recs-text-rva-rdata-rva-data-rva-bss-rva-include-private-dump-mlc-compiler-ml-2070833041) | `mlc/compiler.ml:6062` | 94 | 78 | 37 | 85 | 6 | 5384.85 | 25.86 |
| [`mlc.compiler._link_direct_patch_target`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-link-direct-patch-target-function-link-direct-patch-target-label-map-obj-index-map-source-obj-map-source-obj-prefix-target-mlc-compiler-ml-451365211) | `mlc/compiler.ml:5135` | 9 | 5 | 4 | 4 | 2 | 361.93 | 60.73 |
| [`mlc.compiler._link_local_labels_get`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-link-local-labels-get-function-link-local-labels-get-local-label-map-local-labels-target-mlc-compiler-ml-1347228779) | `mlc/compiler.ml:5038` | 5 | 4 | 3 | 2 | 1 | 216.22 | 68 |
| [`mlc.compiler._link_local_patch_target`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-link-local-patch-target-function-link-local-patch-target-src-patch-target-mlc-compiler-ml-1611963866) | `mlc/compiler.ml:5046` | 10 | 12 | 8 | 7 | 1 | 554.53 | 57.9 |
| [`mlc.compiler._link_mlo_files`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-link-mlo-files-function-link-mlo-files-obj-paths-output-exe-subsystem-mlc-compiler-ml-1561935609) | `mlc/compiler.ml:6253` | 227 | 206 | 55 | 88 | 4 | 14169.15 | 12.14 |
| [`mlc.compiler._link_mlo_linux_sections`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-link-mlo-linux-sections-function-link-mlo-linux-sections-obj-paths-output-exe-text-buf-rdata-buf-data-buf-bss-size-patch-file-recs-imports-mlc-compiler-ml-1487032232) | `mlc/compiler.ml:6176` | 71 | 56 | 21 | 27 | 3 | 4012.58 | 31.56 |
| [`mlc.compiler._link_obj_dir_in_fresh_process`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-link-obj-dir-in-fresh-process-function-link-obj-dir-in-fresh-process-input-ml-obj-dir-output-exe-subsystem-runtime-config-mlc-compiler-ml-1660364315) | `mlc/compiler.ml:6546` | 39 | 27 | 10 | 9 | 1 | 1145.94 | 42.53 |
| [`mlc.compiler._link_obj_label_list_get`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-link-obj-label-list-get-function-link-obj-label-list-get-obj-index-lists-name-defaultv-mlc-compiler-ml-1422148126) | `mlc/compiler.ml:4394` | 14 | 14 | 13 | 15 | 3 | 911.65 | 52.53 |
| [`mlc.compiler._link_obj_label_list_set`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-link-obj-label-list-set-function-link-obj-label-list-set-obj-index-lists-name-value-mlc-compiler-ml-1415819144) | `mlc/compiler.ml:4379` | 12 | 11 | 5 | 4 | 1 | 506.65 | 56.85 |
| [`mlc.compiler._link_obj_label_map_get`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-link-obj-label-map-get-function-link-obj-label-map-get-obj-index-map-name-defaultv-mlc-compiler-ml-219458575) | `mlc/compiler.ml:4369` | 7 | 7 | 5 | 4 | 1 | 338.58 | 63.18 |
| [`mlc.compiler._link_obj_label_map_set`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-link-obj-label-map-set-function-link-obj-label-map-set-obj-index-map-name-value-mlc-compiler-ml-802697151) | `mlc/compiler.ml:4354` | 12 | 11 | 4 | 3 | 1 | 430 | 57.48 |
| [`mlc.compiler._link_rec_labels_lookup`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-link-rec-labels-lookup-function-link-rec-labels-lookup-recs-text-rva-rdata-rva-data-rva-bss-rva-name-defaultv-mlc-compiler-ml-728873654) | `mlc/compiler.ml:4411` | 72 | 63 | 36 | 78 | 4 | 3471.8 | 29.85 |
| [`mlc.compiler._link_resolve_patch_target`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-link-resolve-patch-target-function-link-resolve-patch-target-label-map-obj-index-map-obj-index-lists-local-label-map-local-labels-labels-link-patch-recs-text-rva-rdata-rva-data-rva-bss-rva-src-patch-target-mlc-compiler-ml-119289233) | `mlc/compiler.ml:5074` | 37 | 36 | 27 | 34 | 2 | 2405.73 | 38.48 |
| [`mlc.compiler._link_resolve_patch_target_cached`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-link-resolve-patch-target-cached-function-link-resolve-patch-target-cached-label-map-target-cache-obj-index-map-obj-index-lists-local-label-map-local-labels-labels-link-patch-recs-text-rva-rdata-rva-data-rva-bss-rva-src-patch-target-mlc-compiler-ml-1474262157) | `mlc/compiler.ml:5118` | 13 | 9 | 5 | 4 | 1 | 776.49 | 54.79 |
| [`mlc.compiler._link_resolve_target`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-link-resolve-target-function-link-resolve-target-label-map-labels-link-patch-recs-text-rva-rdata-rva-data-rva-bss-rva-target-mlc-compiler-ml-1812062059) | `mlc/compiler.ml:5019` | 16 | 10 | 9 | 10 | 2 | 840.38 | 52.05 |
| [`mlc.compiler._link_should_use_fresh_process`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-link-should-use-fresh-process-function-link-should-use-fresh-process-obj-paths-mlc-compiler-ml-253646810) | `mlc/compiler.ml:6539` | 4 | 3 | 2 | 1 | 1 | 104 | 72.47 |
| [`mlc.compiler._link_target_obj_index`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-link-target-obj-index-function-link-target-obj-index-name-mlc-compiler-ml-1406105421) | `mlc/compiler.ml:4323` | 6 | 6 | 5 | 4 | 1 | 348.39 | 64.55 |
| [`mlc.compiler._link_target_obj_index_num`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-link-target-obj-index-num-function-link-target-obj-index-num-name-mlc-compiler-ml-369823433) | `mlc/compiler.ml:4332` | 19 | 18 | 11 | 14 | 3 | 789.87 | 50.34 |
| [`mlc.compiler._link_target_prefers_global`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-link-target-prefers-global-function-link-target-prefers-global-target-mlc-compiler-ml-47347529) | `mlc/compiler.ml:5059` | 12 | 19 | 11 | 10 | 1 | 665.54 | 55.21 |
| [`mlc.compiler._load_program_for_codegen`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-load-program-for-codegen-function-load-program-for-codegen-entry-include-dirs-keep-going-max-errors-mlc-compiler-ml-496796531) | `mlc/compiler.ml:5987` | 59 | 49 | 21 | 29 | 3 | 3157.04 | 34.04 |
| [`mlc.compiler._make_linux_output_executable`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-make-linux-output-executable-function-make-linux-output-executable-path-mlc-compiler-ml-511131019) | `mlc/compiler.ml:954` | 3 | 1 | 1 | 0 | 0 | 27 | 79.44 |
| [`mlc.compiler._merge_array_chunks_balanced`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-merge-array-chunks-balanced-function-merge-array-chunks-balanced-chunks-mlc-compiler-ml-556259610) | `mlc/compiler.ml:2752` | 3 | 1 | 1 | 0 | 0 | 46.51 | 77.78 |
| [`mlc.compiler._merge_string_arrays`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-merge-string-arrays-function-merge-string-arrays-dst-src-mlc-compiler-ml-1197263937) | `mlc/compiler.ml:5511` | 13 | 12 | 7 | 8 | 2 | 492.41 | 55.91 |
| [`mlc.compiler._mlo_align_down8`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-align-down8-function-mlo-align-down8-value-mlc-compiler-ml-1922818819) | `mlc/compiler.ml:3488` | 5 | 4 | 3 | 2 | 1 | 146.95 | 69.17 |
| [`mlc.compiler._mlo_bp_bytes`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-bp-bytes-function-mlo-bp-bytes-bp-b-mlc-compiler-ml-1512682124) | `mlc/compiler.ml:3796` | 6 | 5 | 2 | 1 | 1 | 202.05 | 66.61 |
| [`mlc.compiler._mlo_bp_push`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-bp-push-function-mlo-bp-push-bp-b-mlc-compiler-ml-1054535656) | `mlc/compiler.ml:3783` | 4 | 3 | 3 | 2 | 1 | 162.52 | 70.98 |
| [`mlc.compiler._mlo_bp_string`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-bp-string-function-mlo-bp-string-bp-text-mlc-compiler-ml-2097234175) | `mlc/compiler.ml:3805` | 5 | 4 | 2 | 1 | 1 | 184.48 | 68.62 |
| [`mlc.compiler._mlo_bp_u32`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-bp-u32-function-mlo-bp-u32-bp-as-struct-value-as-int-returns-struct-mlc-compiler-ml-1462241957) | `mlc/compiler.ml:3790` | 3 | 1 | 1 | 0 | 0 | 96 | 75.58 |
| [`mlc.compiler._mlo_bp_write_imports`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-bp-write-imports-function-mlo-bp-write-imports-bp-imports-mlc-compiler-ml-865796838) | `mlc/compiler.ml:3867` | 26 | 22 | 10 | 22 | 4 | 939.38 | 46.97 |
| [`mlc.compiler._mlo_bp_write_labels`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-bp-write-labels-function-mlo-bp-write-labels-bp-labels-mlc-compiler-ml-1770535327) | `mlc/compiler.ml:3813` | 18 | 14 | 5 | 7 | 3 | 578.25 | 52.6 |
| [`mlc.compiler._mlo_bp_write_patches`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-bp-write-patches-function-mlo-bp-write-patches-bp-patches-mlc-compiler-ml-1687164426) | `mlc/compiler.ml:3834` | 30 | 25 | 8 | 14 | 3 | 1130.1 | 45.32 |
| [`mlc.compiler._mlo_exported_text_labels`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-exported-text-labels-function-mlo-exported-text-labels-asm-labels-entry-label-rdata-patches-data-patches-mlc-compiler-ml-519380520) | `mlc/compiler.ml:3219` | 32 | 32 | 16 | 30 | 3 | 1728 | 42.35 |
| [`mlc.compiler._mlo_from_sparse_state_delta`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-from-sparse-state-delta-function-mlo-from-sparse-state-delta-kind-module-file-entry-label-st-base-state-mlc-compiler-ml-1604485930) | `mlc/compiler.ml:3608` | 12 | 11 | 5 | 4 | 1 | 574.48 | 56.47 |
| [`mlc.compiler._mlo_from_state`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-from-state-function-mlo-from-state-kind-module-file-entry-label-st-mlc-compiler-ml-1965939219) | `mlc/compiler.ml:3103` | 59 | 35 | 9 | 10 | 2 | 2253.43 | 36.68 |
| [`mlc.compiler._mlo_from_state_delta`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-from-state-delta-function-mlo-from-state-delta-kind-module-file-entry-label-st-base-state-mlc-compiler-ml-743819148) | `mlc/compiler.ml:3530` | 67 | 60 | 18 | 29 | 4 | 4417.97 | 32.22 |
| [`mlc.compiler._mlo_import_get_funcs`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-import-get-funcs-function-mlo-import-get-funcs-imports-dll-mlc-compiler-ml-1713904010) | `mlc/compiler.ml:2893` | 11 | 12 | 8 | 10 | 2 | 520 | 57.19 |
| [`mlc.compiler._mlo_import_set_funcs`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-import-set-funcs-function-mlo-import-set-funcs-imports-dll-funcs-mlc-compiler-ml-1224324127) | `mlc/compiler.ml:2907` | 14 | 11 | 7 | 11 | 3 | 544.36 | 54.9 |
| [`mlc.compiler._mlo_imports_from_state`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-imports-from-state-function-mlo-imports-from-state-imports-mlc-compiler-ml-117809312) | `mlc/compiler.ml:3070` | 16 | 16 | 8 | 16 | 3 | 711.79 | 52.69 |
| [`mlc.compiler._mlo_is_exported_text_label`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-is-exported-text-label-function-mlo-is-exported-text-label-name-entry-label-required-targets-mlc-compiler-ml-985551130) | `mlc/compiler.ml:3205` | 11 | 13 | 12 | 12 | 2 | 550 | 56.48 |
| [`mlc.compiler._mlo_is_shared_runtime_data_label`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-is-shared-runtime-data-label-function-mlo-is-shared-runtime-data-label-name-mlc-compiler-ml-1586034127) | `mlc/compiler.ml:3642` | 11 | 17 | 13 | 12 | 1 | 529.52 | 56.46 |
| [`mlc.compiler._mlo_label_count`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-label-count-function-mlo-label-count-labels-mlc-compiler-ml-954472133) | `mlc/compiler.ml:3722` | 4 | 3 | 2 | 1 | 1 | 91.38 | 72.87 |
| [`mlc.compiler._mlo_label_counts`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-label-counts-function-mlo-label-counts-obj-mlc-compiler-ml-1025075401) | `mlc/compiler.ml:4897` | 22 | 17 | 9 | 17 | 4 | 914.3 | 48.77 |
| [`mlc.compiler._mlo_label_map_add`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-label-map-add-function-mlo-label-map-add-mapv-old-name-new-name-mlc-compiler-ml-1461943887) | `mlc/compiler.ml:3672` | 4 | 3 | 4 | 3 | 1 | 162.63 | 70.85 |
| [`mlc.compiler._mlo_label_name_at`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-label-name-at-function-mlo-label-name-at-labels-offset-mlc-compiler-ml-389508652) | `mlc/compiler.ml:3399` | 11 | 9 | 7 | 8 | 2 | 439.44 | 57.84 |
| [`mlc.compiler._mlo_labels_after`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-labels-after-function-mlo-labels-after-labels-prefix-off-mlc-compiler-ml-1247578143) | `mlc/compiler.ml:3171` | 12 | 10 | 7 | 11 | 3 | 622.38 | 55.95 |
| [`mlc.compiler._mlo_labels_after_cut`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-labels-after-cut-function-mlo-labels-after-cut-labels-min-off-cut-off-mlc-compiler-ml-1494665179) | `mlc/compiler.ml:3496` | 12 | 10 | 7 | 11 | 3 | 637.05 | 55.88 |
| [`mlc.compiler._mlo_labels_from_arr`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-labels-from-arr-function-mlo-labels-from-arr-arr-mlc-compiler-ml-1353576965) | `mlc/compiler.ml:2952` | 21 | 18 | 8 | 17 | 4 | 836.59 | 49.62 |
| [`mlc.compiler._mlo_labels_from_asm_labels`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-labels-from-asm-labels-function-mlo-labels-from-asm-labels-arr-mlc-compiler-ml-876071085) | `mlc/compiler.ml:2976` | 21 | 18 | 8 | 17 | 4 | 836.59 | 49.62 |
| [`mlc.compiler._mlo_linux_dynamic_imports`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-linux-dynamic-imports-function-mlo-linux-dynamic-imports-imports-mlc-compiler-ml-1454922454) | `mlc/compiler.ml:3326` | 51 | 49 | 27 | 43 | 3 | 2914.98 | 34.86 |
| [`mlc.compiler._mlo_linux_import_records`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-linux-import-records-function-mlo-linux-import-records-dynamic-imports-mlc-compiler-ml-1912162558) | `mlc/compiler.ml:3303` | 17 | 18 | 10 | 12 | 2 | 926.43 | 51.04 |
| [`mlc.compiler._mlo_merge_imports`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-merge-imports-function-mlo-merge-imports-dst-src-mlc-compiler-ml-1597348397) | `mlc/compiler.ml:2924` | 25 | 25 | 14 | 25 | 4 | 1148.9 | 46.19 |
| [`mlc.compiler._mlo_namespace_object`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-namespace-object-function-mlo-namespace-object-obj-prefix-preserve-public-mlc-compiler-ml-2093183111) | `mlc/compiler.ml:3729` | 25 | 26 | 5 | 4 | 1 | 1484.33 | 46.63 |
| [`mlc.compiler._mlo_patches_after`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-patches-after-function-mlo-patches-after-patches-prefix-off-mlc-compiler-ml-1269989564) | `mlc/compiler.ml:3186` | 16 | 15 | 11 | 17 | 3 | 874.8 | 51.65 |
| [`mlc.compiler._mlo_patches_after_cut`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-patches-after-cut-function-mlo-patches-after-cut-patches-min-off-cut-off-mlc-compiler-ml-1279546186) | `mlc/compiler.ml:3511` | 16 | 15 | 11 | 17 | 3 | 890.57 | 51.6 |
| [`mlc.compiler._mlo_patches_from_asm`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-patches-from-asm-function-mlo-patches-from-asm-arr-label-pos-map-text-buf-mlc-compiler-ml-1454512896) | `mlc/compiler.ml:3000` | 38 | 30 | 19 | 35 | 4 | 2029.42 | 39.82 |
| [`mlc.compiler._mlo_patches_from_data`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-patches-from-data-function-mlo-patches-from-data-arr-mlc-compiler-ml-1735370677) | `mlc/compiler.ml:3045` | 22 | 19 | 11 | 20 | 4 | 987 | 48.27 |
| [`mlc.compiler._mlo_preserve_module_label`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-preserve-module-label-function-mlo-preserve-module-label-name-mlc-compiler-ml-1696765693) | `mlc/compiler.ml:3624` | 15 | 25 | 14 | 13 | 1 | 770.38 | 52.25 |
| [`mlc.compiler._mlo_rdata_alias_map`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-rdata-alias-map-function-mlo-rdata-alias-map-labels-base-labels-prefix-off-mlc-compiler-ml-850361702) | `mlc/compiler.ml:3413` | 16 | 16 | 10 | 13 | 2 | 766.53 | 52.19 |
| [`mlc.compiler._mlo_read_imports`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-read-imports-function-mlo-read-imports-rd-mlc-compiler-ml-1640456904) | `mlc/compiler.ml:4147` | 30 | 28 | 9 | 22 | 5 | 1153.96 | 45.13 |
| [`mlc.compiler._mlo_read_labels`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-read-labels-function-mlo-read-labels-rd-mlc-compiler-ml-237931306) | `mlc/compiler.ml:4075` | 21 | 20 | 6 | 10 | 3 | 782.24 | 50.09 |
| [`mlc.compiler._mlo_read_patches`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-read-patches-function-mlo-read-patches-rd-version-mlc-compiler-ml-878001772) | `mlc/compiler.ml:4099` | 45 | 45 | 13 | 40 | 5 | 1712.49 | 39.55 |
| [`mlc.compiler._mlo_rename_labels`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-rename-labels-function-mlo-rename-labels-labels-prefix-preserve-public-label-map-mlc-compiler-ml-1844507524) | `mlc/compiler.ml:3679` | 15 | 16 | 8 | 10 | 2 | 729.11 | 53.22 |
| [`mlc.compiler._mlo_rename_patches`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-rename-patches-function-mlo-rename-patches-patches-label-map-mlc-compiler-ml-169494085) | `mlc/compiler.ml:3697` | 22 | 24 | 10 | 16 | 3 | 1128.81 | 48 |
| [`mlc.compiler._mlo_resolve_rdata_alias_patches`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-resolve-rdata-alias-patches-function-mlo-resolve-rdata-alias-patches-patches-rb-mlc-compiler-ml-781016918) | `mlc/compiler.ml:3432` | 22 | 21 | 11 | 16 | 3 | 1094.91 | 47.96 |
| [`mlc.compiler._mlo_scan_label_counts`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-scan-label-counts-function-mlo-scan-label-counts-rd-mlc-compiler-ml-739012686) | `mlc/compiler.ml:4766` | 32 | 30 | 13 | 26 | 4 | 1534.05 | 43.11 |
| [`mlc.compiler._mlo_skip_labels`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-skip-labels-function-mlo-skip-labels-rd-mlc-compiler-ml-345885774) | `mlc/compiler.ml:4706` | 17 | 16 | 6 | 10 | 3 | 485.54 | 53.54 |
| [`mlc.compiler._mlo_skip_patches`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-skip-patches-function-mlo-skip-patches-rd-version-mlc-compiler-ml-1789404426) | `mlc/compiler.ml:4726` | 37 | 37 | 13 | 40 | 5 | 1192.96 | 42.5 |
| [`mlc.compiler._mlo_sort_rank`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-sort-rank-function-mlo-sort-rank-name-mlc-compiler-ml-1514524973) | `mlc/compiler.ml:4613` | 17 | 16 | 7 | 7 | 2 | 528.45 | 53.15 |
| [`mlc.compiler._mlo_state_checkpoint`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-state-checkpoint-function-mlo-state-checkpoint-st-mlc-compiler-ml-381999345) | `mlc/compiler.ml:3457` | 28 | 26 | 9 | 12 | 2 | 1251.12 | 45.53 |
| [`mlc.compiler._mlo_strip_shared_runtime_data_labels`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-strip-shared-runtime-data-labels-function-mlo-strip-shared-runtime-data-labels-labels-mlc-compiler-ml-204408577) | `mlc/compiler.ml:3656` | 13 | 11 | 6 | 10 | 3 | 510.91 | 55.93 |
| [`mlc.compiler._mlo_write_handle_all`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-write-handle-all-function-mlo-write-handle-all-handle-input-count-mlc-compiler-ml-1377244467) | `mlc/compiler.ml:3970` | 14 | 13 | 6 | 7 | 2 | 507.8 | 55.25 |
| [`mlc.compiler._mlo_write_imports`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-write-imports-function-mlo-write-imports-ob-imports-mlc-compiler-ml-1659589699) | `mlc/compiler.ml:3929` | 26 | 22 | 10 | 22 | 4 | 939.38 | 46.97 |
| [`mlc.compiler._mlo_write_labels`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-write-labels-function-mlo-write-labels-ob-labels-mlc-compiler-ml-2107975812) | `mlc/compiler.ml:3762` | 18 | 14 | 5 | 7 | 3 | 578.25 | 52.6 |
| [`mlc.compiler._mlo_write_pages_file`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-write-pages-file-function-mlo-write-pages-file-path-bp-mlc-compiler-ml-1707510849) | `mlc/compiler.ml:3992` | 35 | 30 | 12 | 18 | 3 | 1458.22 | 42.55 |
| [`mlc.compiler._mlo_write_patches`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-write-patches-function-mlo-write-patches-ob-patches-mlc-compiler-ml-1835208615) | `mlc/compiler.ml:3896` | 30 | 25 | 8 | 14 | 3 | 1130.1 | 45.32 |
| [`mlc.compiler._mlo_write_scratch_buffer`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-mlo-write-scratch-buffer-function-mlo-write-scratch-buffer-mlc-compiler-ml-634194338) | `mlc/compiler.ml:3958` | 7 | 4 | 3 | 2 | 1 | 151.27 | 65.9 |
| [`mlc.compiler._module_get_package`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-module-get-package-function-module-get-package-modules-path-mlc-compiler-ml-1680995644) | `mlc/compiler.ml:1373` | 15 | 12 | 6 | 7 | 2 | 512.93 | 54.56 |
| [`mlc.compiler._module_init_rec_for_file`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-module-init-rec-for-file-function-module-init-rec-for-file-module-init-recs-module-file-mlc-compiler-ml-1206492218) | `mlc/compiler.ml:5486` | 9 | 9 | 7 | 8 | 2 | 425 | 59.84 |
| [`mlc.compiler._module_set_package`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-module-set-package-function-module-set-package-modules-path-package-name-mlc-compiler-ml-1273017774) | `mlc/compiler.ml:1391` | 16 | 10 | 5 | 5 | 2 | 554.53 | 53.85 |
| [`mlc.compiler._module_visit`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-module-visit-function-module-visit-path-entry-path-include-dirs-stack-visited-modules-aliases-parsed-modules-diags-keep-going-max-errors-mlc-compiler-ml-1467070084) | `mlc/compiler.ml:1891` | 214 | 145 | 76 | 191 | 8 | 10877.81 | 10.68 |
| [`mlc.compiler._monolithic_label_rva`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-monolithic-label-rva-function-monolithic-label-rva-st-iat-label-map-bss-label-map-text-rva-rdata-rva-data-rva-bss-rva-name-mlc-compiler-ml-963077817) | `mlc/compiler.ml:3279` | 19 | 19 | 18 | 20 | 2 | 1424.91 | 47.6 |
| [`mlc.compiler._node_file`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-node-file-inline-function-node-file-st-fallback-mlc-compiler-ml-1013201426) | `mlc/compiler.ml:1352` | 6 | 3 | 3 | 2 | 1 | 148.68 | 67.41 |
| [`mlc.compiler._node_pos`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-node-pos-inline-function-node-pos-st-mlc-compiler-ml-1797920714) | `mlc/compiler.ml:1344` | 5 | 5 | 3 | 2 | 1 | 158.46 | 68.95 |
| [`mlc.compiler._objbuf_bytes`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-objbuf-bytes-function-objbuf-bytes-ob-b-mlc-compiler-ml-1520772709) | `mlc/compiler.ml:1208` | 5 | 4 | 2 | 1 | 1 | 185.84 | 68.6 |
| [`mlc.compiler._objbuf_finish`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-objbuf-finish-function-objbuf-finish-ob-mlc-compiler-ml-1114479623) | `mlc/compiler.ml:1224` | 14 | 11 | 5 | 7 | 3 | 539.11 | 55.2 |
| [`mlc.compiler._objbuf_new`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-objbuf-new-function-objbuf-new-mlc-compiler-ml-35563964) | `mlc/compiler.ml:1187` | 3 | 1 | 1 | 0 | 0 | 66.61 | 76.69 |
| [`mlc.compiler._objbuf_push`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-objbuf-push-function-objbuf-push-ob-b-mlc-compiler-ml-1571754415) | `mlc/compiler.ml:1193` | 6 | 5 | 3 | 2 | 1 | 260.06 | 65.71 |
| [`mlc.compiler._objbuf_string`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-objbuf-string-function-objbuf-string-ob-text-mlc-compiler-ml-1085854178) | `mlc/compiler.ml:1216` | 5 | 4 | 2 | 1 | 1 | 161.42 | 69.02 |
| [`mlc.compiler._objbuf_u32`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-objbuf-u32-function-objbuf-u32-ob-value-mlc-compiler-ml-1893406978) | `mlc/compiler.ml:1202` | 3 | 1 | 1 | 0 | 0 | 77.71 | 76.22 |
| [`mlc.compiler._objreader_copy_bytes_into`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-objreader-copy-bytes-into-function-objreader-copy-bytes-into-rd-destination-destination-offset-mlc-compiler-ml-101675532) | `mlc/compiler.ml:1325` | 16 | 15 | 11 | 10 | 1 | 877.38 | 51.65 |
| [`mlc.compiler._objreader_new`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-objreader-new-function-objreader-new-buf-mlc-compiler-ml-1966087975) | `mlc/compiler.ml:1241` | 3 | 1 | 1 | 0 | 0 | 71.7 | 76.47 |
| [`mlc.compiler._objreader_read_bytes`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-objreader-read-bytes-function-objreader-read-bytes-rd-mlc-compiler-ml-1133032730) | `mlc/compiler.ml:1268` | 16 | 14 | 7 | 6 | 1 | 792.81 | 52.49 |
| [`mlc.compiler._objreader_read_string`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-objreader-read-string-function-objreader-read-string-rd-mlc-compiler-ml-545749058) | `mlc/compiler.ml:1287` | 7 | 6 | 2 | 1 | 1 | 205.13 | 65.11 |
| [`mlc.compiler._objreader_read_u32`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-objreader-read-u32-function-objreader-read-u32-rd-mlc-compiler-ml-1003061300) | `mlc/compiler.ml:1250` | 15 | 11 | 5 | 4 | 1 | 764.32 | 53.48 |
| [`mlc.compiler._objreader_skip_bytes`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-objreader-skip-bytes-function-objreader-skip-bytes-rd-mlc-compiler-ml-1128000936) | `mlc/compiler.ml:1297` | 11 | 9 | 6 | 5 | 1 | 443.91 | 57.94 |
| [`mlc.compiler._objreader_skip_bytes_len`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-objreader-skip-bytes-len-function-objreader-skip-bytes-len-rd-mlc-compiler-ml-1405562828) | `mlc/compiler.ml:1311` | 11 | 9 | 6 | 5 | 1 | 464.08 | 57.8 |
| [`mlc.compiler._parse_size_text`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-parse-size-text-function-parse-size-text-txt-mlc-compiler-ml-699541748) | `mlc/compiler.ml:2363` | 31 | 26 | 11 | 13 | 2 | 1116.99 | 44.65 |
| [`mlc.compiler._parse_subsystem_value`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-parse-subsystem-value-function-parse-subsystem-value-v-mlc-compiler-ml-791604422) | `mlc/compiler.ml:2613` | 8 | 9 | 9 | 8 | 1 | 506.65 | 60.15 |
| [`mlc.compiler._parsed_module_get`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-parsed-module-get-function-parsed-module-get-parsed-modules-path-mlc-compiler-ml-2040243512) | `mlc/compiler.ml:1856` | 13 | 9 | 7 | 7 | 2 | 482.15 | 55.97 |
| [`mlc.compiler._parsed_module_set`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-parsed-module-set-function-parsed-module-set-parsed-modules-path-source-program-mlc-compiler-ml-759289937) | `mlc/compiler.ml:1872` | 16 | 10 | 7 | 12 | 4 | 696.48 | 52.89 |
| [`mlc.compiler._patch_triplets_for_link`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-patch-triplets-for-link-function-patch-triplets-for-link-patches-default-kind-mlc-compiler-ml-792962418) | `mlc/compiler.ml:4491` | 31 | 26 | 16 | 36 | 5 | 1409.95 | 43.26 |
| [`mlc.compiler._path_abspath`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-path-abspath-function-path-abspath-p-mlc-compiler-ml-1816170412) | `mlc/compiler.ml:841` | 11 | 10 | 7 | 6 | 1 | 399.01 | 58.13 |
| [`mlc.compiler._path_canon`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-path-canon-function-path-canon-p-mlc-compiler-ml-409939596) | `mlc/compiler.ml:741` | 54 | 47 | 23 | 44 | 5 | 2313.9 | 35.56 |
| [`mlc.compiler._path_eq`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-path-eq-inline-function-path-eq-a-b-mlc-compiler-ml-1481866142) | `mlc/compiler.ml:984` | 4 | 3 | 2 | 1 | 1 | 113.3 | 72.21 |
| [`mlc.compiler._path_join`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-path-join-inline-function-path-join-a-b-mlc-compiler-ml-1842731202) | `mlc/compiler.ml:1030` | 9 | 8 | 8 | 7 | 1 | 378.92 | 60.05 |
| [`mlc.compiler._path_norm`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-path-norm-function-path-norm-p-mlc-compiler-ml-341681976) | `mlc/compiler.ml:831` | 3 | 1 | 1 | 0 | 0 | 58.81 | 77.07 |
| [`mlc.compiler._path_norm_cached`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-path-norm-cached-function-path-norm-cached-p-mlc-compiler-ml-1366494444) | `mlc/compiler.ml:969` | 10 | 11 | 4 | 3 | 1 | 413.43 | 59.33 |
| [`mlc.compiler._path_to_package`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-path-to-package-function-path-to-package-rel-path-mlc-compiler-ml-210385537) | `mlc/compiler.ml:1464` | 36 | 32 | 14 | 18 | 3 | 1594.86 | 41.74 |
| [`mlc.compiler._print_diag`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-print-diag-function-print-diag-d-mlc-compiler-ml-554318608) | `mlc/compiler.ml:2257` | 23 | 22 | 8 | 8 | 2 | 851.99 | 48.7 |
| [`mlc.compiler._progress_link`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-progress-link-function-progress-link-msg-mlc-compiler-ml-1776810627) | `mlc/compiler.ml:670` | 3 | 1 | 1 | 0 | 0 | 34.87 | 78.66 |
| [`mlc.compiler._progress_obj`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-progress-obj-function-progress-obj-msg-mlc-compiler-ml-1590633327) | `mlc/compiler.ml:664` | 3 | 1 | 1 | 0 | 0 | 34.87 | 78.66 |
| [`mlc.compiler._progress_phase`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-progress-phase-function-progress-phase-msg-mlc-compiler-ml-445961155) | `mlc/compiler.ml:657` | 4 | 2 | 1 | 0 | 0 | 49.83 | 74.85 |
| [`mlc.compiler._read_mlo_file`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-read-mlo-file-function-read-mlo-file-path-mlc-compiler-ml-253951209) | `mlc/compiler.ml:4180` | 76 | 94 | 22 | 21 | 1 | 3788.33 | 30.96 |
| [`mlc.compiler._read_mlo_file_for_layout`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-read-mlo-file-for-layout-function-read-mlo-file-for-layout-path-mlc-compiler-ml-485790537) | `mlc/compiler.ml:4922` | 68 | 86 | 22 | 21 | 1 | 3402.99 | 32.34 |
| [`mlc.compiler._read_mlo_layout_scan`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-read-mlo-layout-scan-function-read-mlo-layout-scan-path-mlc-compiler-ml-67084131) | `mlc/compiler.ml:4801` | 60 | 73 | 19 | 20 | 2 | 2826 | 34.49 |
| [`mlc.compiler._release_frontend_phase_arenas`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-release-frontend-phase-arenas-function-release-frontend-phase-arenas-mlc-compiler-ml-1853291156) | `mlc/compiler.ml:5975` | 7 | 5 | 1 | 0 | 0 | 101.58 | 67.38 |
| [`mlc.compiler._relpath_from_root`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-relpath-from-root-function-relpath-from-root-path-root-mlc-compiler-ml-2063510905) | `mlc/compiler.ml:1504` | 15 | 12 | 4 | 3 | 1 | 559.93 | 54.56 |
| [`mlc.compiler._resolve_import`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-resolve-import-function-resolve-import-requested-base-dir-include-dirs-mlc-compiler-ml-1694187082) | `mlc/compiler.ml:1700` | 66 | 52 | 17 | 36 | 5 | 2734.07 | 33.96 |
| [`mlc.compiler._resolve_import_cache_key`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-resolve-import-cache-key-function-resolve-import-cache-key-requested-base-dir-mlc-compiler-ml-2037318335) | `mlc/compiler.ml:1775` | 5 | 4 | 2 | 1 | 1 | 185.47 | 68.6 |
| [`mlc.compiler._resolve_import_cached`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-resolve-import-cached-function-resolve-import-cached-requested-base-dir-include-dirs-mlc-compiler-ml-1292690496) | `mlc/compiler.ml:1787` | 10 | 10 | 3 | 2 | 1 | 431.01 | 59.34 |
| [`mlc.compiler._run_child_process`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-run-child-process-function-run-child-process-executable-args-mlc-compiler-ml-252036971) | `mlc/compiler.ml:924` | 23 | 24 | 11 | 11 | 2 | 1231.55 | 47.18 |
| [`mlc.compiler._run_frontcheck`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-run-frontcheck-function-run-frontcheck-entry-include-dirs-keep-going-max-errors-mlc-compiler-ml-194788579) | `mlc/compiler.ml:2186` | 64 | 43 | 12 | 20 | 3 | 3024.17 | 34.61 |
| [`mlc.compiler._sanitize_fs_component`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-sanitize-fs-component-function-sanitize-fs-component-text-mlc-compiler-ml-1860839945) | `mlc/compiler.ml:1078` | 21 | 22 | 16 | 20 | 2 | 887.12 | 48.36 |
| [`mlc.compiler._section_has_payload`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-section-has-payload-function-section-has-payload-blob-labels-patches-size-hint-mlc-compiler-ml-507673919) | `mlc/compiler.ml:1162` | 7 | 9 | 9 | 8 | 1 | 403.48 | 62.11 |
| [`mlc.compiler._self_exe_path`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-self-exe-path-function-self-exe-path-mlc-compiler-ml-1093858620) | `mlc/compiler.ml:862` | 5 | 4 | 2 | 1 | 1 | 110.36 | 70.18 |
| [`mlc.compiler._size_suffix_mul`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-size-suffix-mul-function-size-suffix-mul-ch-mlc-compiler-ml-536638073) | `mlc/compiler.ml:2354` | 6 | 7 | 4 | 3 | 1 | 175.76 | 66.77 |
| [`mlc.compiler._slice_used_bytes`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-slice-used-bytes-function-slice-used-bytes-buf-used-mlc-compiler-ml-1052477882) | `mlc/compiler.ml:3089` | 11 | 11 | 7 | 6 | 1 | 437.45 | 57.85 |
| [`mlc.compiler._sort_strings_inplace`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-sort-strings-inplace-function-sort-strings-inplace-items-mlc-compiler-ml-412098514) | `mlc/compiler.ml:4653` | 19 | 18 | 8 | 12 | 3 | 707.2 | 51.08 |
| [`mlc.compiler._split_imports_nonimports`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-split-imports-nonimports-function-split-imports-nonimports-program-mlc-compiler-ml-582628644) | `mlc/compiler.ml:1673` | 24 | 17 | 6 | 8 | 3 | 927.89 | 48.31 |
| [`mlc.compiler._st_file`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-st-file-function-st-file-st-mlc-compiler-ml-1026336493) | `mlc/compiler.ml:2886` | 4 | 3 | 3 | 2 | 1 | 130.8 | 71.64 |
| [`mlc.compiler._stack_contains`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-stack-contains-function-stack-contains-stack-path-mlc-compiler-ml-611540415) | `mlc/compiler.ml:1802` | 8 | 6 | 3 | 3 | 2 | 187.3 | 63.98 |
| [`mlc.compiler._startsWith`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-startswith-inline-function-startswith-text-pref-mlc-compiler-ml-2058755977) | `mlc/compiler.ml:676` | 8 | 8 | 6 | 6 | 2 | 359.49 | 61.6 |
| [`mlc.compiler._stmt_is_import`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-stmt-is-import-function-stmt-is-import-st-mlc-compiler-ml-814118837) | `mlc/compiler.ml:2638` | 4 | 3 | 2 | 1 | 1 | 102.19 | 72.53 |
| [`mlc.compiler._string_leq`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-string-leq-function-string-leq-a-b-mlc-compiler-ml-1298070979) | `mlc/compiler.ml:4633` | 17 | 18 | 8 | 12 | 3 | 635.9 | 52.45 |
| [`mlc.compiler._subsystem_cli_name`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-subsystem-cli-name-function-subsystem-cli-name-subsystem-mlc-compiler-ml-1234191263) | `mlc/compiler.ml:6532` | 4 | 3 | 2 | 1 | 1 | 66.61 | 73.83 |
| [`mlc.compiler._tmp_obj_dir`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-tmp-obj-dir-function-tmp-obj-dir-output-exe-mlc-compiler-ml-1440771438) | `mlc/compiler.ml:1124` | 7 | 6 | 2 | 1 | 1 | 209.59 | 65.04 |
| [`mlc.compiler._tmp_obj_path`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-tmp-obj-path-function-tmp-obj-path-tmp-dir-index-module-path-kind-mlc-compiler-ml-1247524343) | `mlc/compiler.ml:1134` | 9 | 5 | 2 | 1 | 1 | 227.55 | 62.41 |
| [`mlc.compiler._to_int_or`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-to-int-or-inline-function-to-int-or-defv-text-mlc-compiler-ml-787562953) | `mlc/compiler.ml:733` | 5 | 4 | 2 | 1 | 1 | 125.1 | 69.8 |
| [`mlc.compiler._u32le_at`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-u32le-at-function-u32le-at-buf-off-mlc-compiler-ml-1095299402) | `mlc/compiler.ml:1179` | 5 | 5 | 5 | 4 | 1 | 416.15 | 65.74 |
| [`mlc.compiler._u64le_host_at`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-u64le-host-at-function-u64le-host-at-buf-offset-mlc-compiler-ml-1917120694) | `mlc/compiler.ml:913` | 8 | 6 | 6 | 5 | 1 | 363.2 | 61.57 |
| [`mlc.compiler._usage`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-usage-function-usage-mlc-compiler-ml-562835044) | `mlc/compiler.ml:455` | 25 | 23 | 1 | 0 | 0 | 267.53 | 52.37 |
| [`mlc.compiler._validate_size_flags`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-validate-size-flags-function-validate-size-flags-args-mlc-compiler-ml-1229837971) | `mlc/compiler.ml:2399` | 19 | 13 | 9 | 13 | 3 | 568.69 | 51.61 |
| [`mlc.compiler._visited_add`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-visited-add-function-visited-add-visited-path-mlc-compiler-ml-1453632043) | `mlc/compiler.ml:1823` | 17 | 14 | 7 | 9 | 3 | 722.57 | 52.2 |
| [`mlc.compiler._visited_contains`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-visited-contains-function-visited-contains-path-mlc-compiler-ml-514826259) | `mlc/compiler.ml:1813` | 5 | 4 | 2 | 1 | 1 | 142.62 | 69.4 |
| [`mlc.compiler._visited_finish`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-visited-finish-function-visited-finish-visited-fallback-entry-mlc-compiler-ml-1473036643) | `mlc/compiler.ml:1845` | 8 | 6 | 4 | 3 | 1 | 256.76 | 62.89 |
| [`mlc.compiler._write_asm_listing_if_enabled`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-write-asm-listing-if-enabled-function-write-asm-listing-if-enabled-output-exe-peb-text-buf-rdata-buf-data-buf-idata-buf-mlc-compiler-ml-1869766975) | `mlc/compiler.ml:7443` | 23 | 22 | 6 | 5 | 1 | 1320 | 47.64 |
| [`mlc.compiler._write_linux_image`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-write-linux-image-function-write-linux-image-st-asm-labels-patches-text-buf-rdata-buf-data-buf-output-exe-dynamic-imports-mlc-compiler-ml-923279549) | `mlc/compiler.ml:6639` | 132 | 105 | 51 | 100 | 6 | 8297.01 | 19.44 |
| [`mlc.compiler._write_mlo_file`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-write-mlo-file-function-write-mlo-file-path-obj-mlc-compiler-ml-2048967472) | `mlc/compiler.ml:4051` | 21 | 19 | 1 | 0 | 0 | 991.86 | 50.04 |
| [`mlc.compiler.collect_extern_sigs`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-collect-extern-sigs-function-collect-extern-sigs-program-mlc-compiler-ml-800703984) | `mlc/compiler.ml:5955` | 5 | 3 | 1 | 0 | 0 | 165.67 | 69.08 |
| [`mlc.compiler.collect_extern_structs`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-collect-extern-structs-function-collect-extern-structs-program-mlc-compiler-ml-1133109776) | `mlc/compiler.ml:5740` | 4 | 2 | 1 | 0 | 0 | 105.49 | 72.57 |
| [`mlc.compiler.compile_to_exe`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-compile-to-exe-function-compile-to-exe-input-ml-output-exe-mlc-compiler-ml-1488227210) | `mlc/compiler.ml:7934` | 3 | 1 | 1 | 0 | 0 | 125.02 | 74.77 |
| [`mlc.compiler.compile_to_exe_opts`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-compile-to-exe-opts-function-compile-to-exe-opts-input-ml-output-exe-include-dirs-keep-going-max-errors-runtime-config-call-profile-trace-calls-subsystem-mlc-compiler-ml-1428728650) | `mlc/compiler.ml:7924` | 6 | 3 | 2 | 1 | 1 | 307.46 | 65.34 |
| [`mlc.compiler.compile_to_exe_opts_monolithic`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-compile-to-exe-opts-monolithic-function-compile-to-exe-opts-monolithic-input-ml-output-exe-include-dirs-keep-going-max-errors-runtime-config-call-profile-trace-calls-subsystem-mlc-compiler-ml-1267162196) | `mlc/compiler.ml:6801` | 529 | 446 | 179 | 322 | 5 | 34755.26 | 0 |
| [`mlc.compiler.compile_to_exe_opts_object`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-compile-to-exe-opts-object-function-compile-to-exe-opts-object-input-ml-output-exe-include-dirs-keep-going-max-errors-runtime-config-call-profile-trace-calls-subsystem-mlc-compiler-ml-1252125628) | `mlc/compiler.ml:7477` | 362 | 335 | 60 | 82 | 3 | 19265.73 | 6.11 |
| [`mlc.compiler.link_obj_dir_to_exe`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-link-obj-dir-to-exe-function-link-obj-dir-to-exe-obj-dir-output-exe-subsystem-mlc-compiler-ml-58988272) | `mlc/compiler.ml:7942` | 12 | 10 | 3 | 3 | 2 | 360 | 58.16 |
| [`mlc.compiler.run_cli`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-run-cli-function-run-cli-args-mlc-compiler-ml-1299205999) | `mlc/compiler.ml:7957` | 212 | 179 | 70 | 103 | 4 | 9372.54 | 12.03 |
| [`mlc.compiler.validate_extern_sigs`](File-mlc-compiler-ml-344018962.md#function-function-mlc-compiler-validate-extern-sigs-function-validate-extern-sigs-extern-sigs-extern-struct-names-mlc-compiler-ml-1523605262) | `mlc/compiler.ml:5769` | 87 | 75 | 35 | 90 | 5 | 4616.06 | 27.33 |
| [`mlc.context._normalizeBreakableCtx`](File-mlc-context-ml-1162383972.md#function-function-mlc-context-normalizebreakablectx-function-normalizebreakablectx-kind-break-label-continue-label-break-depth-continue-depth-mlc-context-ml-1778684944) | `mlc/context.ml:65` | 12 | 7 | 7 | 6 | 1 | 394.2 | 57.34 |
| [`mlc.context.newBreakableCtx`](File-mlc-context-ml-1162383972.md#function-function-mlc-context-newbreakablectx-function-newbreakablectx-kind-break-label-continue-label-break-depth-continue-depth-mlc-context-ml-1200315452) | `mlc/context.ml:85` | 3 | 1 | 1 | 0 | 0 | 103.61 | 75.35 |
| [`mlc.context.newLoopCtx`](File-mlc-context-ml-1162383972.md#function-function-mlc-context-newloopctx-function-newloopctx-break-label-continue-label-mlc-context-ml-832310252) | `mlc/context.ml:59` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.data._buf_append`](File-mlc-data-ml-557434521.md#function-function-mlc-data-buf-append-function-buf-append-db-b-mlc-data-ml-20902164) | `mlc/data.ml:604` | 10 | 8 | 4 | 3 | 1 | 428.77 | 59.22 |
| [`mlc.data._buf_ensure`](File-mlc-data-ml-557434521.md#function-function-mlc-data-buf-ensure-function-buf-ensure-db-need-mlc-data-ml-1065897560) | `mlc/data.ml:581` | 18 | 18 | 7 | 6 | 1 | 649.28 | 51.98 |
| [`mlc.data._buf_used`](File-mlc-data-ml-557434521.md#function-function-mlc-data-buf-used-function-buf-used-db-mlc-data-ml-1527058378) | `mlc/data.ml:567` | 5 | 5 | 4 | 3 | 1 | 216.1 | 67.87 |
| [`mlc.data._data_upsert_label`](File-mlc-data-ml-557434521.md#function-function-mlc-data-data-upsert-label-function-data-upsert-label-db-name-offset-mlc-data-ml-1632477370) | `mlc/data.ml:297` | 15 | 12 | 7 | 6 | 1 | 691.08 | 53.52 |
| [`mlc.data._find_data_label_index`](File-mlc-data-ml-557434521.md#function-function-mlc-data-find-data-label-index-function-find-data-label-index-labels-name-mlc-data-ml-1927555520) | `mlc/data.ml:114` | 9 | 9 | 5 | 6 | 2 | 338.58 | 60.8 |
| [`mlc.data._find_pool_entry`](File-mlc-data-ml-557434521.md#function-function-mlc-data-find-pool-entry-function-find-pool-entry-pool-key-mlc-data-ml-1472859613) | `mlc/data.ml:160` | 33 | 27 | 24 | 46 | 5 | 1684.71 | 41.05 |
| [`mlc.data._find_range_label_index`](File-mlc-data-ml-557434521.md#function-function-mlc-data-find-range-label-index-function-find-range-label-index-labels-name-mlc-data-ml-1927866608) | `mlc/data.ml:137` | 9 | 9 | 5 | 6 | 2 | 338.58 | 60.8 |
| [`mlc.data._float_to_f64le`](File-mlc-data-ml-557434521.md#function-function-mlc-data-float-to-f64le-function-float-to-f64le-value-mlc-data-ml-83527747) | `mlc/data.ml:784` | 70 | 56 | 15 | 21 | 4 | 2347.17 | 34.13 |
| [`mlc.data._rdata_intern_raw`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-intern-raw-function-rdata-intern-raw-rb-name-raw-mlc-data-ml-860567281) | `mlc/data.ml:712` | 16 | 14 | 3 | 3 | 2 | 802.26 | 52.99 |
| [`mlc.data._rdata_upsert_label`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-upsert-label-function-rdata-upsert-label-rb-name-offset-length-mlc-data-ml-1319191444) | `mlc/data.ml:548` | 16 | 13 | 7 | 6 | 1 | 742.77 | 52.69 |
| [`mlc.data._upsert_data_label`](File-mlc-data-ml-557434521.md#function-function-mlc-data-upsert-data-label-function-upsert-data-label-labels-name-offset-mlc-data-ml-2030093549) | `mlc/data.ml:126` | 8 | 5 | 2 | 1 | 1 | 219.62 | 63.63 |
| [`mlc.data._upsert_range_label`](File-mlc-data-ml-557434521.md#function-function-mlc-data-upsert-range-label-function-upsert-range-label-labels-name-offset-length-mlc-data-ml-1508479519) | `mlc/data.ml:149` | 8 | 5 | 2 | 1 | 1 | 249.73 | 63.24 |
| [`mlc.data.bss_pad_align`](File-mlc-data-ml-557434521.md#function-function-mlc-data-bss-pad-align-function-bss-pad-align-bb-align-mlc-data-ml-515523841) | `mlc/data.ml:674` | 8 | 6 | 3 | 2 | 1 | 202.05 | 63.75 |
| [`mlc.data.bss_reserve`](File-mlc-data-ml-557434521.md#function-function-mlc-data-bss-reserve-function-bss-reserve-bb-name-size-align-mlc-data-ml-887598105) | `mlc/data.ml:688` | 9 | 6 | 2 | 1 | 1 | 302.61 | 61.54 |
| [`mlc.data.data_add_abs64_patch`](File-mlc-data-ml-557434521.md#function-function-mlc-data-data-add-abs64-patch-function-data-add-abs64-patch-db-offset-target-mlc-data-ml-1447675864) | `mlc/data.ml:652` | 5 | 4 | 2 | 1 | 1 | 261.34 | 67.56 |
| [`mlc.data.data_add_bytes`](File-mlc-data-ml-557434521.md#function-function-mlc-data-data-add-bytes-function-data-add-bytes-db-name-b-mlc-data-ml-415684585) | `mlc/data.ml:641` | 6 | 4 | 1 | 0 | 0 | 144.55 | 67.77 |
| [`mlc.data.data_add_u32`](File-mlc-data-ml-557434521.md#function-function-mlc-data-data-add-u32-function-data-add-u32-db-name-value-mlc-data-ml-291177912) | `mlc/data.ml:619` | 6 | 4 | 1 | 0 | 0 | 175.14 | 67.18 |
| [`mlc.data.data_add_u64`](File-mlc-data-ml-557434521.md#function-function-mlc-data-data-add-u64-function-data-add-u64-db-name-value-mlc-data-ml-569087744) | `mlc/data.ml:630` | 6 | 4 | 1 | 0 | 0 | 175.14 | 67.18 |
| [`mlc.data.data_clear_labels`](File-mlc-data-ml-557434521.md#function-function-mlc-data-data-clear-labels-function-data-clear-labels-db-mlc-data-ml-1216296822) | `mlc/data.ml:291` | 3 | 1 | 1 | 0 | 0 | 51.89 | 77.45 |
| [`mlc.data.data_clear_patches`](File-mlc-data-ml-557434521.md#function-function-mlc-data-data-clear-patches-function-data-clear-patches-db-mlc-data-ml-1447455518) | `mlc/data.ml:375` | 3 | 1 | 1 | 0 | 0 | 51.89 | 77.45 |
| [`mlc.data.data_get_labels`](File-mlc-data-ml-557434521.md#function-function-mlc-data-data-get-labels-function-data-get-labels-db-mlc-data-ml-566606188) | `mlc/data.ml:204` | 6 | 7 | 4 | 3 | 1 | 259.32 | 65.59 |
| [`mlc.data.data_get_labels_after`](File-mlc-data-ml-557434521.md#function-function-mlc-data-data-get-labels-after-function-data-get-labels-after-db-start-index-mlc-data-ml-1658270713) | `mlc/data.ml:214` | 14 | 15 | 8 | 9 | 2 | 808.85 | 53.56 |
| [`mlc.data.data_get_patches`](File-mlc-data-ml-557434521.md#function-function-mlc-data-data-get-patches-function-data-get-patches-db-mlc-data-ml-852810518) | `mlc/data.ml:325` | 6 | 7 | 4 | 3 | 1 | 259.32 | 65.59 |
| [`mlc.data.data_get_patches_after`](File-mlc-data-ml-557434521.md#function-function-mlc-data-data-get-patches-after-function-data-get-patches-after-db-start-index-mlc-data-ml-176177417) | `mlc/data.ml:344` | 14 | 15 | 8 | 9 | 2 | 808.85 | 53.56 |
| [`mlc.data.data_has_label`](File-mlc-data-ml-557434521.md#function-function-mlc-data-data-has-label-function-data-has-label-db-as-struct-name-as-string-returns-bool-mlc-data-ml-1847281964) | `mlc/data.ml:264` | 3 | 1 | 1 | 0 | 0 | 112.59 | 75.09 |
| [`mlc.data.data_label_count`](File-mlc-data-ml-557434521.md#function-function-mlc-data-data-label-count-function-data-label-count-db-mlc-data-ml-1151563258) | `mlc/data.ml:231` | 5 | 5 | 3 | 2 | 1 | 207.45 | 68.13 |
| [`mlc.data.data_label_record`](File-mlc-data-ml-557434521.md#function-function-mlc-data-data-label-record-function-data-label-record-db-name-mlc-data-ml-2142507393) | `mlc/data.ml:240` | 19 | 17 | 12 | 16 | 3 | 889.35 | 49.84 |
| [`mlc.data.data_pad_align`](File-mlc-data-ml-557434521.md#function-function-mlc-data-data-pad-align-function-data-pad-align-db-align-mlc-data-ml-1631589451) | `mlc/data.ml:661` | 9 | 7 | 3 | 2 | 1 | 240.81 | 62.1 |
| [`mlc.data.data_patch_count`](File-mlc-data-ml-557434521.md#function-function-mlc-data-data-patch-count-function-data-patch-count-db-mlc-data-ml-1095699350) | `mlc/data.ml:334` | 6 | 7 | 4 | 3 | 1 | 263.64 | 65.54 |
| [`mlc.data.data_set_labels`](File-mlc-data-ml-557434521.md#function-function-mlc-data-data-set-labels-function-data-set-labels-db-labels-mlc-data-ml-1702903773) | `mlc/data.ml:271` | 17 | 16 | 9 | 11 | 3 | 938.27 | 51.14 |
| [`mlc.data.data_set_patches`](File-mlc-data-ml-557434521.md#function-function-mlc-data-data-set-patches-function-data-set-patches-db-patches-mlc-data-ml-1103417598) | `mlc/data.ml:362` | 10 | 7 | 5 | 5 | 2 | 403.55 | 59.27 |
| [`mlc.data.newBssBuilder`](File-mlc-data-ml-557434521.md#function-function-mlc-data-newbssbuilder-function-newbssbuilder-mlc-data-ml-1108300550) | `mlc/data.ml:314` | 3 | 1 | 1 | 0 | 0 | 48.43 | 77.66 |
| [`mlc.data.newDataBuilder`](File-mlc-data-ml-557434521.md#function-function-mlc-data-newdatabuilder-function-newdatabuilder-mlc-data-ml-1281909056) | `mlc/data.ml:198` | 3 | 1 | 1 | 0 | 0 | 167.59 | 73.88 |
| [`mlc.data.newRDataBuilder`](File-mlc-data-ml-557434521.md#function-function-mlc-data-newrdatabuilder-function-newrdatabuilder-mlc-data-ml-1676082786) | `mlc/data.ml:319` | 3 | 1 | 1 | 0 | 0 | 282.03 | 72.3 |
| [`mlc.data.rdata_add_abs64_patch`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-add-abs64-patch-function-rdata-add-abs64-patch-rb-offset-target-mlc-data-ml-1320401438) | `mlc/data.ml:776` | 5 | 4 | 2 | 1 | 1 | 261.34 | 67.56 |
| [`mlc.data.rdata_add_bytes`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-add-bytes-function-rdata-add-bytes-rb-name-raw-mlc-data-ml-2106952383) | `mlc/data.ml:755` | 3 | 1 | 1 | 0 | 0 | 69.19 | 76.57 |
| [`mlc.data.rdata_add_bytes_unique`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-add-bytes-unique-function-rdata-add-bytes-unique-rb-name-raw-mlc-data-ml-2040410875) | `mlc/data.ml:763` | 6 | 4 | 1 | 0 | 0 | 168 | 67.31 |
| [`mlc.data.rdata_add_obj_float`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-add-obj-float-function-rdata-add-obj-float-rb-name-value-mlc-data-ml-609974008) | `mlc/data.ml:923` | 19 | 17 | 3 | 3 | 2 | 1048.21 | 50.55 |
| [`mlc.data.rdata_add_obj_string`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-add-obj-string-function-rdata-add-obj-string-rb-name-text-mlc-data-ml-745948924) | `mlc/data.ml:867` | 20 | 18 | 3 | 3 | 2 | 1148.9 | 49.79 |
| [`mlc.data.rdata_add_obj_string_unique`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-add-obj-string-unique-function-rdata-add-obj-string-unique-rb-name-text-mlc-data-ml-550307040) | `mlc/data.ml:895` | 20 | 18 | 3 | 3 | 2 | 1148.9 | 49.79 |
| [`mlc.data.rdata_add_str`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-add-str-function-rdata-add-str-rb-name-text-mlc-data-ml-46031888) | `mlc/data.ml:734` | 3 | 1 | 1 | 0 | 0 | 78.87 | 76.18 |
| [`mlc.data.rdata_add_str_nl`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-add-str-nl-function-rdata-add-str-nl-rb-name-text-add-newline-mlc-data-ml-1983537838) | `mlc/data.ml:743` | 7 | 4 | 2 | 1 | 1 | 161.42 | 65.84 |
| [`mlc.data.rdata_clear_labels`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-clear-labels-function-rdata-clear-labels-rb-mlc-data-ml-1305272588) | `mlc/data.ml:542` | 3 | 1 | 1 | 0 | 0 | 51.89 | 77.45 |
| [`mlc.data.rdata_clear_patches`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-clear-patches-function-rdata-clear-patches-rb-mlc-data-ml-1556851698) | `mlc/data.ml:431` | 3 | 1 | 1 | 0 | 0 | 51.89 | 77.45 |
| [`mlc.data.rdata_get_labels`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-get-labels-function-rdata-get-labels-rb-mlc-data-ml-14203796) | `mlc/data.ml:437` | 6 | 7 | 4 | 3 | 1 | 259.32 | 65.59 |
| [`mlc.data.rdata_get_labels_after`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-get-labels-after-function-rdata-get-labels-after-rb-start-index-mlc-data-ml-343597091) | `mlc/data.ml:447` | 14 | 15 | 8 | 9 | 2 | 808.85 | 53.56 |
| [`mlc.data.rdata_get_patches`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-get-patches-function-rdata-get-patches-rb-mlc-data-ml-277419204) | `mlc/data.ml:381` | 6 | 7 | 4 | 3 | 1 | 259.32 | 65.59 |
| [`mlc.data.rdata_get_patches_after`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-get-patches-after-function-rdata-get-patches-after-rb-start-index-mlc-data-ml-475352069) | `mlc/data.ml:400` | 14 | 15 | 8 | 9 | 2 | 808.85 | 53.56 |
| [`mlc.data.rdata_has_label`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-has-label-function-rdata-has-label-rb-name-mlc-data-ml-1579051377) | `mlc/data.ml:506` | 3 | 1 | 1 | 0 | 0 | 77.71 | 76.22 |
| [`mlc.data.rdata_label_count`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-label-count-function-rdata-label-count-rb-mlc-data-ml-779307070) | `mlc/data.ml:473` | 6 | 6 | 3 | 2 | 1 | 227.43 | 66.12 |
| [`mlc.data.rdata_label_length`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-label-length-function-rdata-label-length-rb-name-mlc-data-ml-1681488389) | `mlc/data.ml:513` | 5 | 4 | 3 | 2 | 1 | 187.3 | 68.44 |
| [`mlc.data.rdata_label_record`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-label-record-function-rdata-label-record-rb-name-mlc-data-ml-1938418297) | `mlc/data.ml:483` | 19 | 17 | 12 | 16 | 3 | 889.35 | 49.84 |
| [`mlc.data.rdata_pad_align`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-pad-align-function-rdata-pad-align-rb-align-mlc-data-ml-814922757) | `mlc/data.ml:701` | 8 | 6 | 3 | 2 | 1 | 224.01 | 63.44 |
| [`mlc.data.rdata_patch_count`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-patch-count-function-rdata-patch-count-rb-mlc-data-ml-186349378) | `mlc/data.ml:390` | 6 | 7 | 4 | 3 | 1 | 263.64 | 65.54 |
| [`mlc.data.rdata_resolve_alias`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-resolve-alias-function-rdata-resolve-alias-rb-name-mlc-data-ml-1358680033) | `mlc/data.ml:465` | 5 | 5 | 5 | 4 | 1 | 263.11 | 67.13 |
| [`mlc.data.rdata_set_labels`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-set-labels-function-rdata-set-labels-rb-labels-mlc-data-ml-1865594797) | `mlc/data.ml:522` | 17 | 16 | 9 | 11 | 3 | 938.27 | 51.14 |
| [`mlc.data.rdata_set_patches`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-set-patches-function-rdata-set-patches-rb-patches-mlc-data-ml-1982356328) | `mlc/data.ml:418` | 10 | 7 | 5 | 5 | 2 | 403.55 | 59.27 |
| [`mlc.data.rdata_used`](File-mlc-data-ml-557434521.md#function-function-mlc-data-rdata-used-function-rdata-used-rb-mlc-data-ml-813016988) | `mlc/data.ml:575` | 3 | 1 | 1 | 0 | 0 | 36 | 78.56 |
| [`mlc.elf._array_has`](File-mlc-elf-ml-1082822254.md#function-function-mlc-elf-array-has-function-array-has-values-wanted-mlc-elf-ml-1543624131) | `mlc/elf.ml:77` | 7 | 6 | 4 | 4 | 2 | 222.91 | 64.59 |
| [`mlc.elf._dynamic_blob`](File-mlc-elf-ml-1082822254.md#function-function-mlc-elf-dynamic-blob-function-dynamic-blob-imports-image-base-data-off-blob-off-mlc-elf-ml-1212129740) | `mlc/elf.ml:105` | 83 | 70 | 21 | 39 | 4 | 4890.37 | 29.48 |
| [`mlc.elf._pad_blob`](File-mlc-elf-ml-1082822254.md#function-function-mlc-elf-pad-blob-function-pad-blob-blob-alignment-mlc-elf-ml-405074902) | `mlc/elf.ml:97` | 5 | 4 | 2 | 1 | 1 | 218.51 | 68.1 |
| [`mlc.elf._ph`](File-mlc-elf-ml-1082822254.md#function-function-mlc-elf-ph-function-ph-kind-flags-off-filesz-memsz-base-alignment-mlc-elf-ml-1707200603) | `mlc/elf.ml:204` | 4 | 1 | 1 | 0 | 0 | 335.59 | 69.05 |
| [`mlc.elf._string_offset`](File-mlc-elf-ml-1082822254.md#function-function-mlc-elf-string-offset-function-string-offset-offsets-wanted-mlc-elf-ml-1708932397) | `mlc/elf.ml:87` | 7 | 6 | 4 | 4 | 2 | 267.93 | 64.03 |
| [`mlc.elf.build`](File-mlc-elf-ml-1082822254.md#function-function-mlc-elf-build-function-build-text-rdata-data-bss-size-entry-offset-imports-mlc-elf-ml-1364924151) | `mlc/elf.ml:216` | 35 | 32 | 6 | 5 | 1 | 3456.16 | 40.73 |
| [`mlc.elf.dynamic_size`](File-mlc-elf-ml-1082822254.md#function-function-mlc-elf-dynamic-size-function-dynamic-size-imports-mlc-elf-ml-265787200) | `mlc/elf.ml:197` | 4 | 3 | 3 | 2 | 1 | 181.52 | 70.65 |
| [`mlc.elf.plan`](File-mlc-elf-ml-1082822254.md#function-function-mlc-elf-plan-function-plan-text-size-rdata-size-data-size-dynamic-size-mlc-elf-ml-825164840) | `mlc/elf.ml:66` | 8 | 6 | 1 | 0 | 0 | 371.33 | 62.17 |
| [`mlc.errors.newCompileError`](File-mlc-errors-ml-1747911852.md#function-function-mlc-errors-newcompileerror-function-newcompileerror-message-pos-filename-mlc-errors-ml-1839399204) | `mlc/errors.ml:56` | 3 | 1 | 1 | 0 | 0 | 69.19 | 76.57 |
| [`mlc.errors.newDiagnostic`](File-mlc-errors-ml-1747911852.md#function-function-mlc-errors-newdiagnostic-function-newdiagnostic-kind-message-filename-pos-source-mlc-errors-ml-794180763) | `mlc/errors.ml:66` | 3 | 1 | 1 | 0 | 0 | 103.61 | 75.35 |
| [`mlc.errors.newMultiCompileError`](File-mlc-errors-ml-1747911852.md#function-function-mlc-errors-newmulticompileerror-function-newmulticompileerror-diags-mlc-errors-ml-2045908612) | `mlc/errors.ml:72` | 3 | 1 | 1 | 0 | 0 | 36 | 78.56 |
| [`mlc.frontend._is_alnum_byte`](File-mlc-frontend-ml-1929241497.md#function-function-mlc-frontend-is-alnum-byte-inline-function-is-alnum-byte-ch-mlc-frontend-ml-1295318798) | `mlc/frontend.ml:49` | 3 | 1 | 1 | 0 | 0 | 158.46 | 74.05 |
| [`mlc.frontend._is_digit_byte`](File-mlc-frontend-ml-1929241497.md#function-function-mlc-frontend-is-digit-byte-inline-function-is-digit-byte-ch-mlc-frontend-ml-1062943722) | `mlc/frontend.ml:43` | 3 | 1 | 1 | 0 | 0 | 59.21 | 77.05 |
| [`mlc.frontend._is_space_byte`](File-mlc-frontend-ml-1929241497.md#function-function-mlc-frontend-is-space-byte-inline-function-is-space-byte-ch-mlc-frontend-ml-418837300) | `mlc/frontend.ml:37` | 3 | 1 | 1 | 0 | 0 | 91.38 | 75.73 |
| [`mlc.frontend._normalize_frontend_error`](File-mlc-frontend-ml-1929241497.md#function-function-mlc-frontend-normalize-frontend-error-function-normalize-frontend-error-err-fallback-path-mlc-frontend-ml-726009547) | `mlc/frontend.ml:55` | 20 | 13 | 6 | 5 | 1 | 466.31 | 52.13 |
| [`mlc.frontend._normalize_frontend_errors`](File-mlc-frontend-ml-1929241497.md#function-function-mlc-frontend-normalize-frontend-errors-function-normalize-frontend-errors-errors-fallback-path-mlc-frontend-ml-1936042109) | `mlc/frontend.ml:78` | 14 | 10 | 4 | 3 | 1 | 496.31 | 55.58 |
| [`mlc.frontend.load_minilang_frontend`](File-mlc-frontend-ml-1929241497.md#function-function-mlc-frontend-load-minilang-frontend-function-load-minilang-frontend-path-mlc-frontend-ml-1616731493) | `mlc/frontend.ml:235` | 3 | 1 | 1 | 0 | 0 | 27 | 79.44 |
| [`mlc.frontend.normalize_code_for_tokenizer`](File-mlc-frontend-ml-1929241497.md#function-function-mlc-frontend-normalize-code-for-tokenizer-function-normalize-code-for-tokenizer-src-mlc-frontend-ml-2075062608) | `mlc/frontend.ml:96` | 99 | 89 | 37 | 62 | 5 | 3291.42 | 26.86 |
| [`mlc.frontend.parse_program`](File-mlc-frontend-ml-1929241497.md#function-function-mlc-frontend-parse-program-function-parse-program-path-mlc-frontend-ml-452933877) | `mlc/frontend.ml:216` | 16 | 11 | 6 | 5 | 1 | 696.13 | 53.02 |
| [`mlc.frontend.parse_program_keepgoing`](File-mlc-frontend-ml-1929241497.md#function-function-mlc-frontend-parse-program-keepgoing-function-parse-program-keepgoing-path-max-errors-mlc-frontend-ml-1135170373) | `mlc/frontend.ml:244` | 16 | 11 | 5 | 4 | 1 | 771.68 | 52.84 |
| [`mlc.linux_runtime._array_has`](File-mlc-linux-runtime-ml-1485387394.md#function-function-mlc-linux-runtime-array-has-function-array-has-values-wanted-mlc-linux-runtime-ml-1454112207) | `mlc/linux_runtime.ml:242` | 7 | 6 | 4 | 4 | 2 | 222.91 | 64.59 |
| [`mlc.linux_runtime._emit_extern_thunks`](File-mlc-linux-runtime-ml-1485387394.md#function-function-mlc-linux-runtime-emit-extern-thunks-function-emit-extern-thunks-state-mlc-linux-runtime-ml-220175397) | `mlc/linux_runtime.ml:252` | 193 | 173 | 31 | 71 | 5 | 14539.56 | 16.83 |
| [`mlc.linux_runtime._extern_dll_base`](File-mlc-linux-runtime-ml-1485387394.md#function-function-mlc-linux-runtime-extern-dll-base-function-extern-dll-base-dll-mlc-linux-runtime-ml-1882968546) | `mlc/linux_runtime.ml:75` | 3 | 1 | 1 | 0 | 0 | 46.51 | 77.78 |
| [`mlc.linux_runtime._extern_param_type`](File-mlc-linux-runtime-ml-1485387394.md#function-function-mlc-linux-runtime-extern-param-type-function-extern-param-type-param-mlc-linux-runtime-ml-1745883699) | `mlc/linux_runtime.ml:229` | 10 | 10 | 6 | 8 | 2 | 519.19 | 58.37 |
| [`mlc.linux_runtime._pthread_runtime_blob`](File-mlc-linux-runtime-ml-1485387394.md#function-function-mlc-linux-runtime-pthread-runtime-blob-function-pthread-runtime-blob-mlc-linux-runtime-ml-494942306) | `mlc/linux_runtime.ml:222` | 3 | 1 | 1 | 0 | 0 | 33 | 78.82 |
| [`mlc.linux_runtime._runtime_blob_raw`](File-mlc-linux-runtime-ml-1485387394.md#function-function-mlc-linux-runtime-runtime-blob-raw-function-runtime-blob-raw-mlc-linux-runtime-ml-1501145666) | `mlc/linux_runtime.ml:202` | 3 | 1 | 1 | 0 | 0 | 33 | 78.82 |
| [`mlc.linux_runtime._runtime_labels`](File-mlc-linux-runtime-ml-1485387394.md#function-function-mlc-linux-runtime-runtime-labels-function-runtime-labels-mlc-linux-runtime-ml-971158720) | `mlc/linux_runtime.ml:173` | 26 | 1 | 1 | 0 | 0 | 3177.49 | 44.48 |
| [`mlc.linux_runtime._runtime_non_thread_parts`](File-mlc-linux-runtime-ml-1485387394.md#function-function-mlc-linux-runtime-runtime-non-thread-parts-function-runtime-non-thread-parts-mlc-linux-runtime-ml-513965488) | `mlc/linux_runtime.ml:213` | 6 | 4 | 1 | 0 | 0 | 181.52 | 67.07 |
| [`mlc.linux_runtime.emit_runtime`](File-mlc-linux-runtime-ml-1485387394.md#function-function-mlc-linux-runtime-emit-runtime-function-emit-runtime-state-mlc-linux-runtime-ml-2109134943) | `mlc/linux_runtime.ml:469` | 36 | 33 | 6 | 7 | 2 | 2746.37 | 41.17 |
| [`mlc.linux_runtime.emit_startup`](File-mlc-linux-runtime-ml-1485387394.md#function-function-mlc-linux-runtime-emit-startup-function-emit-startup-state-mlc-linux-runtime-ml-1287943791) | `mlc/linux_runtime.ml:133` | 34 | 31 | 2 | 1 | 1 | 3002.71 | 41.97 |
| [`mlc.linux_runtime.prepare_dynamic_imports`](File-mlc-linux-runtime-ml-1485387394.md#function-function-mlc-linux-runtime-prepare-dynamic-imports-function-prepare-dynamic-imports-state-mlc-linux-runtime-ml-221971075) | `mlc/linux_runtime.ml:81` | 47 | 42 | 14 | 21 | 2 | 3429.61 | 36.89 |
| [`mlc.minilang_parser._advance`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-advance-function-advance-mlc-minilang-parser-ml-854342850) | `mlc/minilang_parser.ml:1816` | 6 | 5 | 2 | 1 | 1 | 135.93 | 67.82 |
| [`mlc.minilang_parser._canonical_type_name`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-canonical-type-name-function-canonical-type-name-raw-ty-mlc-minilang-parser-ml-248541986) | `mlc/minilang_parser.ml:2458` | 6 | 7 | 4 | 3 | 1 | 144 | 67.37 |
| [`mlc.minilang_parser._charCode`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-charcode-function-charcode-ch-mlc-minilang-parser-ml-121231781) | `mlc/minilang_parser.ml:957` | 5 | 4 | 2 | 1 | 1 | 131.69 | 69.64 |
| [`mlc.minilang_parser._charFromCode`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-charfromcode-function-charfromcode-v-mlc-minilang-parser-ml-1255810508) | `mlc/minilang_parser.ml:1885` | 27 | 24 | 9 | 8 | 1 | 1348.88 | 45.65 |
| [`mlc.minilang_parser._chunked_finish`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-chunked-finish-function-chunked-finish-chunks-tail-mlc-minilang-parser-ml-1957454160) | `mlc/minilang_parser.ml:1228` | 8 | 6 | 4 | 3 | 1 | 272.63 | 62.71 |
| [`mlc.minilang_parser._chunked_merge_balanced`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-chunked-merge-balanced-function-chunked-merge-balanced-chunks-mlc-minilang-parser-ml-1612726450) | `mlc/minilang_parser.ml:1164` | 26 | 21 | 8 | 9 | 2 | 837.37 | 47.59 |
| [`mlc.minilang_parser._chunked_merge_with_tail`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-chunked-merge-with-tail-function-chunked-merge-with-tail-chunks-tail-arr-mlc-minilang-parser-ml-1736823946) | `mlc/minilang_parser.ml:1196` | 29 | 24 | 13 | 18 | 3 | 1148.96 | 44.92 |
| [`mlc.minilang_parser._chunked_push`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-chunked-push-function-chunked-push-chunks-tail-value-cap-mlc-minilang-parser-ml-859819469) | `mlc/minilang_parser.ml:1138` | 23 | 24 | 14 | 14 | 2 | 1202.76 | 46.84 |
| [`mlc.minilang_parser._clear_error`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-clear-error-function-clear-error-mlc-minilang-parser-ml-595574162) | `mlc/minilang_parser.ml:1753` | 5 | 3 | 1 | 0 | 0 | 57.36 | 72.3 |
| [`mlc.minilang_parser._compile_argument_pos`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-argument-pos-function-compile-argument-pos-line-argument-line-start-hash-col-mlc-minilang-parser-ml-1844994201) | `mlc/minilang_parser.ml:4505` | 6 | 6 | 4 | 3 | 1 | 283.63 | 65.31 |
| [`mlc.minilang_parser._compile_block_comment_state`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-block-comment-state-function-compile-block-comment-state-line-in-block-mlc-minilang-parser-ml-1936692993) | `mlc/minilang_parser.ml:4445` | 39 | 31 | 16 | 28 | 3 | 1070.05 | 41.93 |
| [`mlc.minilang_parser._compile_env_find`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-env-find-function-compile-env-find-env-name-mlc-minilang-parser-ml-1948646458) | `mlc/minilang_parser.ml:4136` | 7 | 6 | 6 | 6 | 2 | 356.7 | 62.89 |
| [`mlc.minilang_parser._compile_env_get`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-env-get-function-compile-env-get-env-name-mlc-minilang-parser-ml-910740190) | `mlc/minilang_parser.ml:4152` | 5 | 4 | 2 | 1 | 1 | 144.95 | 69.35 |
| [`mlc.minilang_parser._compile_env_has`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-env-has-function-compile-env-has-env-name-mlc-minilang-parser-ml-1596409926) | `mlc/minilang_parser.ml:4146` | 3 | 1 | 1 | 0 | 0 | 64.53 | 76.79 |
| [`mlc.minilang_parser._compile_env_set`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-env-set-function-compile-env-set-env-name-value-mlc-minilang-parser-ml-323738911) | `mlc/minilang_parser.ml:4160` | 10 | 7 | 2 | 1 | 1 | 253.32 | 61.09 |
| [`mlc.minilang_parser._compile_eval`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-eval-function-compile-eval-text-env-filename-base-pos-mlc-minilang-parser-ml-704938159) | `mlc/minilang_parser.ml:4344` | 8 | 5 | 2 | 1 | 1 | 224.01 | 63.57 |
| [`mlc.minilang_parser._compile_eval_node`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-eval-node-function-compile-eval-node-expr-env-filename-base-pos-mlc-minilang-parser-ml-307143249) | `mlc/minilang_parser.ml:4240` | 100 | 119 | 71 | 138 | 4 | 8165.3 | 19.43 |
| [`mlc.minilang_parser._compile_external_has`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-external-has-function-compile-external-has-name-mlc-minilang-parser-ml-1852269799) | `mlc/minilang_parser.ml:4417` | 3 | 1 | 1 | 0 | 0 | 46.51 | 77.78 |
| [`mlc.minilang_parser._compile_frames_active`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-frames-active-function-compile-frames-active-frames-mlc-minilang-parser-ml-1694676040) | `mlc/minilang_parser.ml:4487` | 4 | 3 | 3 | 2 | 1 | 171.9 | 70.81 |
| [`mlc.minilang_parser._compile_frames_pop`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-frames-pop-function-compile-frames-pop-frames-mlc-minilang-parser-ml-326002130) | `mlc/minilang_parser.ml:4494` | 8 | 6 | 4 | 3 | 1 | 266.27 | 62.78 |
| [`mlc.minilang_parser._compile_is_error`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-is-error-function-compile-is-error-value-mlc-minilang-parser-ml-1836513363) | `mlc/minilang_parser.ml:4104` | 3 | 1 | 1 | 0 | 0 | 155.32 | 74.11 |
| [`mlc.minilang_parser._compile_is_predefined`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-is-predefined-function-compile-is-predefined-name-mlc-minilang-parser-ml-1217994489) | `mlc/minilang_parser.ml:4130` | 3 | 1 | 1 | 0 | 0 | 121.11 | 74.87 |
| [`mlc.minilang_parser._compile_ltrim_index`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-ltrim-index-function-compile-ltrim-index-line-mlc-minilang-parser-ml-1908960260) | `mlc/minilang_parser.ml:4423` | 7 | 4 | 4 | 3 | 1 | 187.3 | 65.11 |
| [`mlc.minilang_parser._compile_maybe_has_directive`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-maybe-has-directive-function-compile-maybe-has-directive-code-mlc-minilang-parser-ml-1924446191) | `mlc/minilang_parser.ml:4535` | 14 | 12 | 9 | 11 | 2 | 539.11 | 54.66 |
| [`mlc.minilang_parser._compile_node_pos`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-node-pos-function-compile-node-pos-expr-base-pos-mlc-minilang-parser-ml-1928481161) | `mlc/minilang_parser.ml:4214` | 5 | 4 | 2 | 1 | 1 | 149.34 | 69.26 |
| [`mlc.minilang_parser._compile_numeric_text`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-numeric-text-function-compile-numeric-text-raw-mlc-minilang-parser-ml-1435050776) | `mlc/minilang_parser.ml:4355` | 9 | 8 | 5 | 5 | 2 | 287.92 | 61.29 |
| [`mlc.minilang_parser._compile_option_parts`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-option-parts-function-compile-option-parts-argument-filename-argument-pos-mlc-minilang-parser-ml-311068180) | `mlc/minilang_parser.ml:4514` | 18 | 13 | 12 | 11 | 1 | 1239.86 | 49.34 |
| [`mlc.minilang_parser._compile_parse_cli_value`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-parse-cli-value-function-compile-parse-cli-value-raw-mlc-minilang-parser-ml-1275912900) | `mlc/minilang_parser.ml:4367` | 15 | 18 | 11 | 13 | 2 | 862.22 | 52.31 |
| [`mlc.minilang_parser._compile_predefined_values`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-predefined-values-function-compile-predefined-values-mlc-minilang-parser-ml-758642802) | `mlc/minilang_parser.ml:4173` | 10 | 1 | 1 | 0 | 0 | 222.97 | 61.61 |
| [`mlc.minilang_parser._compile_split_command`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-split-command-function-compile-split-command-body-mlc-minilang-parser-ml-203604230) | `mlc/minilang_parser.ml:4433` | 9 | 6 | 4 | 3 | 1 | 408.07 | 60.37 |
| [`mlc.minilang_parser._compile_string_compare`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-string-compare-function-compile-string-compare-left-right-mlc-minilang-parser-ml-1113506839) | `mlc/minilang_parser.ml:4222` | 15 | 16 | 8 | 12 | 3 | 589.61 | 53.87 |
| [`mlc.minilang_parser._compile_valid_name`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-valid-name-function-compile-valid-name-name-mlc-minilang-parser-ml-1605972099) | `mlc/minilang_parser.ml:4110` | 9 | 7 | 7 | 9 | 3 | 372.92 | 60.24 |
| [`mlc.minilang_parser._compile_value_type`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-compile-value-type-function-compile-value-type-value-mlc-minilang-parser-ml-995657421) | `mlc/minilang_parser.ml:4122` | 5 | 4 | 4 | 3 | 1 | 133.44 | 69.33 |
| [`mlc.minilang_parser._contains`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-contains-function-contains-arr-value-mlc-minilang-parser-ml-2103954146) | `mlc/minilang_parser.ml:2854` | 7 | 6 | 4 | 4 | 2 | 222.91 | 64.59 |
| [`mlc.minilang_parser._containsDot`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-containsdot-function-containsdot-text-mlc-minilang-parser-ml-1728333545) | `mlc/minilang_parser.ml:2356` | 7 | 6 | 4 | 4 | 2 | 210.91 | 64.75 |
| [`mlc.minilang_parser._decode_string_raw`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-decode-string-raw-function-decode-string-raw-raw-pos-mlc-minilang-parser-ml-1493201470) | `mlc/minilang_parser.ml:1917` | 63 | 87 | 24 | 56 | 4 | 3365.52 | 32.82 |
| [`mlc.minilang_parser._decode_string_token`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-decode-string-token-function-decode-string-token-tok-mlc-minilang-parser-ml-445520760) | `mlc/minilang_parser.ml:1999` | 9 | 6 | 2 | 1 | 1 | 272.63 | 61.86 |
| [`mlc.minilang_parser._expect_block_nl`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-expect-block-nl-function-expect-block-nl-mlc-minilang-parser-ml-1670597970) | `mlc/minilang_parser.ml:2585` | 6 | 3 | 3 | 2 | 1 | 85.11 | 69.11 |
| [`mlc.minilang_parser._expect_end_of`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-expect-end-of-function-expect-end-of-what-mlc-minilang-parser-ml-804933884) | `mlc/minilang_parser.ml:2601` | 11 | 9 | 5 | 4 | 1 | 338.58 | 58.9 |
| [`mlc.minilang_parser._expect_kind`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-expect-kind-function-expect-kind-kind-mlc-minilang-parser-ml-1844846740) | `mlc/minilang_parser.ml:1846` | 8 | 5 | 2 | 1 | 1 | 255.41 | 63.18 |
| [`mlc.minilang_parser._expect_value`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-expect-value-function-expect-value-kind-value-mlc-minilang-parser-ml-731699205) | `mlc/minilang_parser.ml:1857` | 8 | 5 | 3 | 2 | 1 | 326.9 | 62.29 |
| [`mlc.minilang_parser._has_error`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-has-error-function-has-error-mlc-minilang-parser-ml-1971325894) | `mlc/minilang_parser.ml:1763` | 4 | 2 | 1 | 0 | 0 | 30 | 76.39 |
| [`mlc.minilang_parser._hex_value`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-hex-value-function-hex-value-ch-mlc-minilang-parser-ml-1017679913) | `mlc/minilang_parser.ml:1875` | 7 | 8 | 7 | 6 | 1 | 301.85 | 63.26 |
| [`mlc.minilang_parser._is_allowed_type_name`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-is-allowed-type-name-function-is-allowed-type-name-ty-mlc-minilang-parser-ml-162027275) | `mlc/minilang_parser.ml:2467` | 3 | 1 | 1 | 0 | 0 | 263.11 | 72.51 |
| [`mlc.minilang_parser._is_case_value_continuation_start`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-is-case-value-continuation-start-function-is-case-value-continuation-start-tok-mlc-minilang-parser-ml-68020650) | `mlc/minilang_parser.ml:2913` | 12 | 7 | 12 | 11 | 1 | 499.26 | 55.95 |
| [`mlc.minilang_parser._is_end_of`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-is-end-of-function-is-end-of-what-mlc-minilang-parser-ml-1035425624) | `mlc/minilang_parser.ml:2594` | 4 | 2 | 1 | 0 | 0 | 220.89 | 70.32 |
| [`mlc.minilang_parser._isAlpha`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-isalpha-function-isalpha-ch-mlc-minilang-parser-ml-393200357) | `mlc/minilang_parser.ml:979` | 4 | 2 | 1 | 0 | 0 | 137.61 | 71.76 |
| [`mlc.minilang_parser._isDigit`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-isdigit-function-isdigit-ch-mlc-minilang-parser-ml-110395897) | `mlc/minilang_parser.ml:965` | 4 | 2 | 1 | 0 | 0 | 82.04 | 73.33 |
| [`mlc.minilang_parser._isHexDigit`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-ishexdigit-function-ishexdigit-ch-mlc-minilang-parser-ml-9886191) | `mlc/minilang_parser.ml:972` | 4 | 2 | 1 | 0 | 0 | 185.84 | 70.84 |
| [`mlc.minilang_parser._isIdentPart`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-isidentpart-function-isidentpart-ch-as-string-returns-bool-mlc-minilang-parser-ml-51937513) | `mlc/minilang_parser.ml:992` | 3 | 1 | 1 | 0 | 0 | 79.95 | 76.13 |
| [`mlc.minilang_parser._isIdentStart`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-isidentstart-function-isidentstart-ch-as-string-returns-bool-mlc-minilang-parser-ml-121077475) | `mlc/minilang_parser.ml:986` | 3 | 1 | 1 | 0 | 0 | 78.14 | 76.2 |
| [`mlc.minilang_parser._isKeyword`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-iskeyword-function-iskeyword-word-mlc-minilang-parser-ml-228355970) | `mlc/minilang_parser.ml:998` | 8 | 4 | 3 | 3 | 2 | 153.8 | 64.58 |
| [`mlc.minilang_parser._lang_add_unique`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-add-unique-function-lang-add-unique-items-value-mlc-minilang-parser-ml-1937050863) | `mlc/minilang_parser.ml:5050` | 4 | 3 | 2 | 1 | 1 | 125.1 | 71.91 |
| [`mlc.minilang_parser._lang_apply_contracts`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-apply-contracts-function-lang-apply-contracts-fn-mlc-minilang-parser-ml-1085961450) | `mlc/minilang_parser.ml:4834` | 5 | 4 | 2 | 1 | 1 | 181.52 | 68.67 |
| [`mlc.minilang_parser._lang_apply_parameter_contracts`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-apply-parameter-contracts-function-lang-apply-parameter-contracts-fn-mlc-minilang-parser-ml-975369642) | `mlc/minilang_parser.ml:4810` | 18 | 16 | 10 | 16 | 3 | 1217.52 | 49.67 |
| [`mlc.minilang_parser._lang_await_helper`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-await-helper-function-lang-await-helper-mlc-minilang-parser-ml-1301921598) | `mlc/minilang_parser.ml:5454` | 13 | 11 | 1 | 0 | 0 | 1919.02 | 52.58 |
| [`mlc.minilang_parser._lang_call`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-call-function-lang-call-name-args-node-mlc-minilang-parser-ml-1883001620) | `mlc/minilang_parser.ml:4752` | 3 | 1 | 1 | 0 | 0 | 157.17 | 74.08 |
| [`mlc.minilang_parser._lang_collect_contracts`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-collect-contracts-function-lang-collect-contracts-body-prefix-mlc-minilang-parser-ml-1632823090) | `mlc/minilang_parser.ml:5663` | 15 | 10 | 7 | 9 | 2 | 663.26 | 53.65 |
| [`mlc.minilang_parser._lang_fail`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-fail-function-lang-fail-message-mlc-minilang-parser-ml-1582786325) | `mlc/minilang_parser.ml:4715` | 4 | 3 | 2 | 1 | 1 | 70.31 | 73.66 |
| [`mlc.minilang_parser._lang_find_interface`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-find-interface-function-lang-find-interface-raw-name-prefix-mlc-minilang-parser-ml-339764222) | `mlc/minilang_parser.ml:5683` | 18 | 18 | 9 | 13 | 3 | 824.37 | 50.99 |
| [`mlc.minilang_parser._lang_fresh`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-fresh-function-lang-fresh-stem-mlc-minilang-parser-ml-625788787) | `mlc/minilang_parser.ml:4724` | 5 | 3 | 1 | 0 | 0 | 83.76 | 71.15 |
| [`mlc.minilang_parser._lang_guard_returns`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-guard-returns-function-lang-guard-returns-body-return-type-return-optional-mlc-minilang-parser-ml-24790194) | `mlc/minilang_parser.ml:4761` | 46 | 39 | 21 | 37 | 4 | 2313.21 | 37.35 |
| [`mlc.minilang_parser._lang_interface_signature_matches`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-interface-signature-matches-function-lang-interface-signature-matches-required-actual-mlc-minilang-parser-ml-1141437533) | `mlc/minilang_parser.ml:5704` | 21 | 26 | 18 | 28 | 3 | 1414.03 | 46.68 |
| [`mlc.minilang_parser._lang_iterator_append`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-iterator-append-function-lang-iterator-append-yield-stmt-fn-names-mlc-minilang-parser-ml-1781774224) | `mlc/minilang_parser.ml:4937` | 26 | 24 | 4 | 3 | 1 | 3255.17 | 44 |
| [`mlc.minilang_parser._lang_lazy_collect_names`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-lazy-collect-names-function-lang-lazy-collect-names-state-body-mlc-minilang-parser-ml-1375518483) | `mlc/minilang_parser.ml:5155` | 43 | 29 | 20 | 42 | 4 | 1980 | 38.59 |
| [`mlc.minilang_parser._lang_lazy_compile_seq`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-lazy-compile-seq-function-lang-lazy-compile-seq-state-body-cont-break-target-continue-target-mlc-minilang-parser-ml-1854624785) | `mlc/minilang_parser.ml:5201` | 172 | 157 | 31 | 61 | 4 | 14361 | 17.96 |
| [`mlc.minilang_parser._lang_lazy_contains_yield`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-lazy-contains-yield-function-lang-lazy-contains-yield-st-mlc-minilang-parser-ml-940831165) | `mlc/minilang_parser.ml:5099` | 53 | 41 | 33 | 83 | 6 | 2289.88 | 34.42 |
| [`mlc.minilang_parser._lang_lazy_jump`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-lazy-jump-function-lang-lazy-jump-state-target-node-mlc-minilang-parser-ml-46189424) | `mlc/minilang_parser.ml:5090` | 6 | 4 | 1 | 0 | 0 | 293.25 | 65.62 |
| [`mlc.minilang_parser._lang_lazy_reserve`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-lazy-reserve-function-lang-lazy-reserve-state-mlc-minilang-parser-ml-79448599) | `mlc/minilang_parser.ml:5083` | 4 | 2 | 1 | 0 | 0 | 130.8 | 71.91 |
| [`mlc.minilang_parser._lang_lower_async`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-lower-async-function-lang-lower-async-fn-mlc-minilang-parser-ml-1610227462) | `mlc/minilang_parser.ml:5417` | 28 | 22 | 5 | 6 | 2 | 2847.32 | 43.57 |
| [`mlc.minilang_parser._lang_lower_block`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-lower-block-function-lang-lower-block-body-function-depth-mlc-minilang-parser-ml-809020114) | `mlc/minilang_parser.ml:5639` | 16 | 12 | 6 | 8 | 3 | 610.05 | 53.42 |
| [`mlc.minilang_parser._lang_lower_expr`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-lower-expr-function-lang-lower-expr-expr-prelude-mlc-minilang-parser-ml-824621110) | `mlc/minilang_parser.ml:4842` | 88 | 71 | 26 | 38 | 3 | 4997.05 | 28.19 |
| [`mlc.minilang_parser._lang_lower_iterator`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-lower-iterator-function-lang-lower-iterator-fn-mlc-minilang-parser-ml-1990187370) | `mlc/minilang_parser.ml:5011` | 22 | 22 | 2 | 1 | 1 | 2199.07 | 47.05 |
| [`mlc.minilang_parser._lang_lower_lazy_iterator`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-lower-lazy-iterator-function-lang-lower-lazy-iterator-fn-mlc-minilang-parser-ml-1036584840) | `mlc/minilang_parser.ml:5376` | 38 | 35 | 9 | 12 | 3 | 3412.35 | 39.59 |
| [`mlc.minilang_parser._lang_lower_stmt`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-lower-stmt-function-lang-lower-stmt-st-function-depth-mlc-minilang-parser-ml-1800530555) | `mlc/minilang_parser.ml:5503` | 133 | 105 | 50 | 104 | 6 | 7318.82 | 19.89 |
| [`mlc.minilang_parser._lang_num`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-num-function-lang-num-value-node-mlc-minilang-parser-ml-448227959) | `mlc/minilang_parser.ml:4740` | 3 | 1 | 1 | 0 | 0 | 125.02 | 74.77 |
| [`mlc.minilang_parser._lang_remove_interfaces`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-remove-interfaces-function-lang-remove-interfaces-body-mlc-minilang-parser-ml-1622339556) | `mlc/minilang_parser.ml:5767` | 11 | 11 | 6 | 7 | 2 | 478.22 | 57.71 |
| [`mlc.minilang_parser._lang_rewrite_yields`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-rewrite-yields-function-lang-rewrite-yields-body-fn-names-mlc-minilang-parser-ml-1323349854) | `mlc/minilang_parser.ml:4966` | 42 | 33 | 18 | 33 | 4 | 1953.04 | 39.13 |
| [`mlc.minilang_parser._lang_select_helper`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-select-helper-function-lang-select-helper-mlc-minilang-parser-ml-1613669244) | `mlc/minilang_parser.ml:5472` | 26 | 24 | 1 | 0 | 0 | 4099.91 | 43.7 |
| [`mlc.minilang_parser._lang_sort_strings`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-sort-strings-function-lang-sort-strings-items-mlc-minilang-parser-ml-356175926) | `mlc/minilang_parser.ml:5057` | 23 | 18 | 9 | 20 | 5 | 723.79 | 49.06 |
| [`mlc.minilang_parser._lang_validate_interfaces`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-validate-interfaces-function-lang-validate-interfaces-program-mlc-minilang-parser-ml-171382428) | `mlc/minilang_parser.ml:5728` | 34 | 33 | 14 | 39 | 6 | 1709.5 | 42.07 |
| [`mlc.minilang_parser._lang_var`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-var-function-lang-var-name-node-mlc-minilang-parser-ml-172090983) | `mlc/minilang_parser.ml:4734` | 3 | 1 | 1 | 0 | 0 | 125.02 | 74.77 |
| [`mlc.minilang_parser._lang_void`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-lang-void-function-lang-void-node-mlc-minilang-parser-ml-1408191438) | `mlc/minilang_parser.ml:4746` | 3 | 1 | 1 | 0 | 0 | 117.21 | 74.97 |
| [`mlc.minilang_parser._line_col`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-line-col-function-line-col-source-pos-mlc-minilang-parser-ml-36477455) | `mlc/minilang_parser.ml:1622` | 15 | 12 | 5 | 5 | 2 | 393.5 | 55.5 |
| [`mlc.minilang_parser._match_kind`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-match-kind-function-match-kind-kind-mlc-minilang-parser-ml-1282613646) | `mlc/minilang_parser.ml:1827` | 6 | 5 | 2 | 1 | 1 | 118.54 | 68.24 |
| [`mlc.minilang_parser._match_number_has_dot`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-match-number-has-dot-function-match-number-has-dot-text-mlc-minilang-parser-ml-193975663) | `mlc/minilang_parser.ml:2346` | 7 | 6 | 4 | 4 | 2 | 210.91 | 64.75 |
| [`mlc.minilang_parser._match_value`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-match-value-function-match-value-kind-value-mlc-minilang-parser-ml-1343077697) | `mlc/minilang_parser.ml:1836` | 7 | 7 | 3 | 2 | 1 | 185.84 | 65.27 |
| [`mlc.minilang_parser._new_function_node`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-new-function-node-function-new-function-node-name-params-body-is-static-is-inline-is-synchronized-param-types-param-optional-param-defaults-variadic-index-return-type-return-optional-is-async-is-iterator-pos-filename-mlc-minilang-parser-ml-1740795503) | `mlc/minilang_parser.ml:942` | 3 | 1 | 1 | 0 | 0 | 510.09 | 70.5 |
| [`mlc.minilang_parser._parse_base_int`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-base-int-function-parse-base-int-raw-start-index-base-mlc-minilang-parser-ml-17195282) | `mlc/minilang_parser.ml:2011` | 9 | 7 | 4 | 4 | 2 | 279.69 | 61.51 |
| [`mlc.minilang_parser._parse_block_until`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-block-until-function-parse-block-until-stop-keywords-end-type-start-pos-mlc-minilang-parser-ml-2139376230) | `mlc/minilang_parser.ml:2928` | 38 | 30 | 12 | 24 | 4 | 1259.9 | 42.22 |
| [`mlc.minilang_parser._parse_block_until_end`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-block-until-end-function-parse-block-until-end-end-type-start-pos-mlc-minilang-parser-ml-1915823777) | `mlc/minilang_parser.ml:2819` | 32 | 25 | 8 | 17 | 4 | 927.1 | 45.31 |
| [`mlc.minilang_parser._parse_call_arguments`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-call-arguments-function-parse-call-arguments-mlc-minilang-parser-ml-684252158) | `mlc/minilang_parser.ml:2305` | 38 | 36 | 11 | 17 | 3 | 1312.11 | 42.23 |
| [`mlc.minilang_parser._parse_dotted_name`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-dotted-name-function-parse-dotted-name-mlc-minilang-parser-ml-475088762) | `mlc/minilang_parser.ml:2615` | 11 | 10 | 4 | 4 | 2 | 259.15 | 59.85 |
| [`mlc.minilang_parser._parse_expr`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-expr-function-parse-expr-min-prec-mlc-minilang-parser-ml-1451801121) | `mlc/minilang_parser.ml:2473` | 66 | 61 | 25 | 50 | 4 | 3132.26 | 32.47 |
| [`mlc.minilang_parser._parse_expr_list`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-expr-list-function-parse-expr-list-end-kind-mlc-minilang-parser-ml-471735646) | `mlc/minilang_parser.ml:2060` | 23 | 23 | 7 | 11 | 3 | 595 | 49.93 |
| [`mlc.minilang_parser._parse_extern_param`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-extern-param-function-parse-extern-param-mlc-minilang-parser-ml-1936636852) | `mlc/minilang_parser.ml:2645` | 24 | 18 | 9 | 9 | 2 | 830.94 | 48.24 |
| [`mlc.minilang_parser._parse_extern_param_list`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-extern-param-list-function-parse-extern-param-list-end-kind-mlc-minilang-parser-ml-889062222) | `mlc/minilang_parser.ml:2672` | 23 | 23 | 7 | 11 | 3 | 590 | 49.95 |
| [`mlc.minilang_parser._parse_float_literal`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-float-literal-function-parse-float-literal-raw-mlc-minilang-parser-ml-1448544044) | `mlc/minilang_parser.ml:2035` | 3 | 1 | 1 | 0 | 0 | 46.51 | 77.78 |
| [`mlc.minilang_parser._parse_ident_list`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-ident-list-function-parse-ident-list-end-kind-mlc-minilang-parser-ml-791848414) | `mlc/minilang_parser.ml:2549` | 23 | 23 | 7 | 11 | 3 | 615.42 | 49.82 |
| [`mlc.minilang_parser._parse_int_literal`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-int-literal-function-parse-int-literal-raw-mlc-minilang-parser-ml-1603272168) | `mlc/minilang_parser.ml:2023` | 9 | 5 | 5 | 4 | 1 | 356.75 | 60.64 |
| [`mlc.minilang_parser._parse_namespace_def`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-namespace-def-function-parse-namespace-def-start-pos-mlc-minilang-parser-ml-467393215) | `mlc/minilang_parser.ml:2698` | 111 | 93 | 34 | 76 | 5 | 3589.26 | 25.92 |
| [`mlc.minilang_parser._parse_parameter_list`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-parameter-list-function-parse-parameter-list-mlc-minilang-parser-ml-351279608) | `mlc/minilang_parser.ml:2224` | 76 | 76 | 22 | 42 | 4 | 3227.91 | 31.44 |
| [`mlc.minilang_parser._parse_postfix`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-postfix-function-parse-postfix-mlc-minilang-parser-ml-956530126) | `mlc/minilang_parser.ml:2366` | 49 | 52 | 17 | 38 | 3 | 1938.99 | 37.82 |
| [`mlc.minilang_parser._parse_primary`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-primary-function-parse-primary-mlc-minilang-parser-ml-186727750) | `mlc/minilang_parser.ml:2086` | 107 | 104 | 42 | 70 | 4 | 5836.48 | 23.71 |
| [`mlc.minilang_parser._parse_stmt`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-function-parse-stmt-mlc-minilang-parser-ml-1644404112) | `mlc/minilang_parser.ml:2969` | 78 | 53 | 54 | 53 | 1 | 3562.95 | 26.59 |
| [`mlc.minilang_parser._parse_stmt_break`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-break-function-parse-stmt-break-start-pos-t-mlc-minilang-parser-ml-1876806755) | `mlc/minilang_parser.ml:3198` | 12 | 11 | 5 | 6 | 2 | 545.78 | 56.62 |
| [`mlc.minilang_parser._parse_stmt_const`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-const-function-parse-stmt-const-start-pos-t-mlc-minilang-parser-ml-1610490731) | `mlc/minilang_parser.ml:3142` | 11 | 12 | 4 | 3 | 1 | 403.55 | 58.5 |
| [`mlc.minilang_parser._parse_stmt_continue`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-continue-function-parse-stmt-continue-start-pos-t-mlc-minilang-parser-ml-1042039421) | `mlc/minilang_parser.ml:3215` | 5 | 3 | 1 | 0 | 0 | 131.69 | 69.78 |
| [`mlc.minilang_parser._parse_stmt_defer`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-defer-function-parse-stmt-defer-start-pos-t-mlc-minilang-parser-ml-999751397) | `mlc/minilang_parser.ml:3295` | 15 | 12 | 5 | 4 | 1 | 535.02 | 54.57 |
| [`mlc.minilang_parser._parse_stmt_enum`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-enum-function-parse-stmt-enum-start-pos-t-mlc-minilang-parser-ml-817767041) | `mlc/minilang_parser.ml:3621` | 67 | 60 | 18 | 38 | 4 | 2505.42 | 33.95 |
| [`mlc.minilang_parser._parse_stmt_extern`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-extern-function-parse-stmt-extern-start-pos-t-mlc-minilang-parser-ml-403281573) | `mlc/minilang_parser.ml:3315` | 82 | 84 | 29 | 44 | 3 | 3730.46 | 29.34 |
| [`mlc.minilang_parser._parse_stmt_for`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-for-function-parse-stmt-for-start-pos-t-mlc-minilang-parser-ml-1144812571) | `mlc/minilang_parser.ml:3961` | 35 | 44 | 15 | 19 | 2 | 1456.11 | 42.15 |
| [`mlc.minilang_parser._parse_stmt_function`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-function-function-parse-stmt-function-start-pos-t-mlc-minilang-parser-ml-95524909) | `mlc/minilang_parser.ml:3696` | 53 | 60 | 22 | 30 | 3 | 2427.62 | 35.72 |
| [`mlc.minilang_parser._parse_stmt_global`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-global-function-parse-stmt-global-start-pos-t-mlc-minilang-parser-ml-2138045605) | `mlc/minilang_parser.ml:3225` | 26 | 23 | 8 | 9 | 2 | 1053.14 | 46.89 |
| [`mlc.minilang_parser._parse_stmt_ident`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-ident-function-parse-stmt-ident-start-pos-first-tok-mlc-minilang-parser-ml-1453814254) | `mlc/minilang_parser.ml:4001` | 41 | 34 | 14 | 20 | 3 | 1826.3 | 40.1 |
| [`mlc.minilang_parser._parse_stmt_if`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-if-function-parse-stmt-if-start-pos-t-mlc-minilang-parser-ml-1322990389) | `mlc/minilang_parser.ml:3902` | 35 | 39 | 13 | 20 | 3 | 1496.27 | 42.34 |
| [`mlc.minilang_parser._parse_stmt_import`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-import-function-parse-stmt-import-start-pos-t-mlc-minilang-parser-ml-662978865) | `mlc/minilang_parser.ml:3110` | 27 | 24 | 9 | 11 | 2 | 930.28 | 46.78 |
| [`mlc.minilang_parser._parse_stmt_interface`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-interface-function-parse-stmt-interface-start-pos-tok-mlc-minilang-parser-ml-1030662077) | `mlc/minilang_parser.ml:3409` | 45 | 51 | 16 | 29 | 4 | 2199.93 | 38.38 |
| [`mlc.minilang_parser._parse_stmt_loop`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-loop-function-parse-stmt-loop-start-pos-t-mlc-minilang-parser-ml-117125565) | `mlc/minilang_parser.ml:3754` | 43 | 42 | 13 | 29 | 4 | 1499.05 | 40.38 |
| [`mlc.minilang_parser._parse_stmt_namespace`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-namespace-function-parse-stmt-namespace-start-pos-t-mlc-minilang-parser-ml-1071847403) | `mlc/minilang_parser.ml:3101` | 4 | 2 | 1 | 0 | 0 | 96 | 72.85 |
| [`mlc.minilang_parser._parse_stmt_package`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-package-function-parse-stmt-package-start-pos-t-mlc-minilang-parser-ml-421259793) | `mlc/minilang_parser.ml:3076` | 20 | 16 | 6 | 5 | 1 | 508.75 | 51.86 |
| [`mlc.minilang_parser._parse_stmt_print`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-print-function-parse-stmt-print-start-pos-t-mlc-minilang-parser-ml-256477979) | `mlc/minilang_parser.ml:3186` | 7 | 6 | 2 | 1 | 1 | 220.92 | 64.88 |
| [`mlc.minilang_parser._parse_stmt_recover`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-recover-function-parse-stmt-recover-stop-keywords-end-type-mlc-minilang-parser-ml-1546652525) | `mlc/minilang_parser.ml:4048` | 16 | 12 | 4 | 4 | 2 | 322.02 | 55.64 |
| [`mlc.minilang_parser._parse_stmt_return`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-return-function-parse-stmt-return-start-pos-t-mlc-minilang-parser-ml-86255477) | `mlc/minilang_parser.ml:3256` | 14 | 11 | 10 | 9 | 1 | 739.34 | 53.57 |
| [`mlc.minilang_parser._parse_stmt_struct`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-struct-function-parse-stmt-struct-start-pos-t-mlc-minilang-parser-ml-1886394821) | `mlc/minilang_parser.ml:3459` | 151 | 146 | 45 | 106 | 5 | 6972.32 | 19.5 |
| [`mlc.minilang_parser._parse_stmt_switch`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-switch-function-parse-stmt-switch-start-pos-t-mlc-minilang-parser-ml-1183801933) | `mlc/minilang_parser.ml:3807` | 82 | 79 | 22 | 59 | 5 | 3155.27 | 30.79 |
| [`mlc.minilang_parser._parse_stmt_synchronized`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-synchronized-function-parse-stmt-synchronized-start-pos-t-mlc-minilang-parser-ml-2088041877) | `mlc/minilang_parser.ml:3158` | 23 | 27 | 9 | 12 | 2 | 873.51 | 48.49 |
| [`mlc.minilang_parser._parse_stmt_while`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-while-function-parse-stmt-while-start-pos-t-mlc-minilang-parser-ml-272909159) | `mlc/minilang_parser.ml:3944` | 12 | 13 | 4 | 3 | 1 | 396.34 | 57.73 |
| [`mlc.minilang_parser._parse_stmt_yield`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-stmt-yield-function-parse-stmt-yield-start-pos-tok-mlc-minilang-parser-ml-1674674669) | `mlc/minilang_parser.ml:3275` | 15 | 14 | 11 | 10 | 1 | 766.36 | 52.67 |
| [`mlc.minilang_parser._parse_type_ref`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-type-ref-function-parse-type-ref-mlc-minilang-parser-ml-430222728) | `mlc/minilang_parser.ml:2206` | 15 | 12 | 5 | 5 | 2 | 474.06 | 54.94 |
| [`mlc.minilang_parser._parse_unary`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-unary-function-parse-unary-mlc-minilang-parser-ml-704063402) | `mlc/minilang_parser.ml:2418` | 37 | 35 | 13 | 16 | 2 | 1341.13 | 42.14 |
| [`mlc.minilang_parser._parser_chunk_tail_from_array`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parser-chunk-tail-from-array-function-parser-chunk-tail-from-array-arr-cap-mlc-minilang-parser-ml-1785272287) | `mlc/minilang_parser.ml:1075` | 11 | 10 | 5 | 4 | 1 | 432.43 | 58.15 |
| [`mlc.minilang_parser._parser_chunk_tail_len`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parser-chunk-tail-len-function-parser-chunk-tail-len-tail-mlc-minilang-parser-ml-1487200976) | `mlc/minilang_parser.ml:1089` | 10 | 14 | 11 | 10 | 1 | 626.68 | 57.12 |
| [`mlc.minilang_parser._parser_chunk_tail_new`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parser-chunk-tail-new-function-parser-chunk-tail-new-cap-mlc-minilang-parser-ml-299071438) | `mlc/minilang_parser.ml:1067` | 5 | 4 | 3 | 2 | 1 | 180.09 | 68.56 |
| [`mlc.minilang_parser._parser_chunk_tail_to_array`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parser-chunk-tail-to-array-function-parser-chunk-tail-to-array-tail-mlc-minilang-parser-ml-974082346) | `mlc/minilang_parser.ml:1102` | 33 | 30 | 15 | 19 | 2 | 1128.66 | 43.48 |
| [`mlc.minilang_parser._parser_chunk_unwrap_value`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parser-chunk-unwrap-value-function-parser-chunk-unwrap-value-value-mlc-minilang-parser-ml-257964935) | `mlc/minilang_parser.ml:1055` | 9 | 5 | 4 | 3 | 1 | 136.74 | 63.69 |
| [`mlc.minilang_parser._parser_chunk_wrap_value`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parser-chunk-wrap-value-function-parser-chunk-wrap-value-value-mlc-minilang-parser-ml-1167373083) | `mlc/minilang_parser.ml:1046` | 6 | 3 | 2 | 1 | 1 | 77.71 | 69.52 |
| [`mlc.minilang_parser._peek`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-peek-function-peek-mlc-minilang-parser-ml-336315198) | `mlc/minilang_parser.ml:1792` | 7 | 7 | 3 | 2 | 1 | 168.56 | 65.57 |
| [`mlc.minilang_parser._peek2`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-peek2-function-peek2-mlc-minilang-parser-ml-947026934) | `mlc/minilang_parser.ml:1804` | 7 | 7 | 3 | 2 | 1 | 188.87 | 65.22 |
| [`mlc.minilang_parser._peek3`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-peek3-function-peek3-mlc-minilang-parser-ml-1307291770) | `mlc/minilang_parser.ml:1987` | 7 | 7 | 3 | 2 | 1 | 191.76 | 65.18 |
| [`mlc.minilang_parser._peek_non_nl`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-peek-non-nl-function-peek-non-nl-mlc-minilang-parser-ml-267832150) | `mlc/minilang_parser.ml:2629` | 11 | 7 | 4 | 3 | 1 | 246.12 | 60 |
| [`mlc.minilang_parser._precedence`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-precedence-function-precedence-op-mlc-minilang-parser-ml-311473671) | `mlc/minilang_parser.ml:2043` | 14 | 23 | 21 | 20 | 1 | 786.81 | 51.9 |
| [`mlc.minilang_parser._record_error`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-record-error-function-record-error-err-mlc-minilang-parser-ml-104933803) | `mlc/minilang_parser.ml:2864` | 6 | 6 | 3 | 2 | 1 | 178.38 | 66.86 |
| [`mlc.minilang_parser._repeat`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-repeat-function-repeat-text-n-mlc-minilang-parser-ml-457637029) | `mlc/minilang_parser.ml:1608` | 8 | 6 | 4 | 3 | 1 | 199.69 | 63.65 |
| [`mlc.minilang_parser._replaceDotsWithSlash`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-replacedotswithslash-function-replacedotswithslash-name-mlc-minilang-parser-ml-1287845457) | `mlc/minilang_parser.ml:4069` | 12 | 8 | 4 | 4 | 2 | 290.05 | 58.68 |
| [`mlc.minilang_parser._reset`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-reset-function-reset-tokens-source-filename-collect-errors-max-errors-mlc-minilang-parser-ml-1225112460) | `mlc/minilang_parser.ml:1772` | 15 | 13 | 1 | 0 | 0 | 359.49 | 56.32 |
| [`mlc.minilang_parser._set_error`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-set-error-function-set-error-message-pos-mlc-minilang-parser-ml-1563176001) | `mlc/minilang_parser.ml:1742` | 6 | 5 | 2 | 1 | 1 | 141.78 | 67.69 |
| [`mlc.minilang_parser._skip_newlines`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-skip-newlines-function-skip-newlines-mlc-minilang-parser-ml-1349351774) | `mlc/minilang_parser.ml:1868` | 4 | 1 | 2 | 1 | 1 | 39 | 75.46 |
| [`mlc.minilang_parser._skip_stmt_seps`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-skip-stmt-seps-function-skip-stmt-seps-mlc-minilang-parser-ml-447601712) | `mlc/minilang_parser.ml:2575` | 7 | 6 | 4 | 5 | 2 | 110.41 | 66.72 |
| [`mlc.minilang_parser._substr`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-substr-function-substr-text-start-length-mlc-minilang-parser-ml-1655674179) | `mlc/minilang_parser.ml:948` | 6 | 7 | 5 | 4 | 1 | 282.03 | 65.2 |
| [`mlc.minilang_parser._sync_stmt`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-sync-stmt-function-sync-stmt-stop-keywords-end-type-mlc-minilang-parser-ml-1693418281) | `mlc/minilang_parser.ml:2875` | 30 | 20 | 15 | 24 | 3 | 803.38 | 45.42 |
| [`mlc.minilang_parser._tok_desc`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-tok-desc-function-tok-desc-tok-mlc-minilang-parser-ml-353689570) | `mlc/minilang_parser.ml:87` | 6 | 5 | 3 | 2 | 1 | 215.49 | 66.28 |
| [`mlc.minilang_parser._tok_kind`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-tok-kind-function-tok-kind-tok-mlc-minilang-parser-ml-830102320) | `mlc/minilang_parser.ml:1711` | 3 | 1 | 1 | 0 | 0 | 47.55 | 77.71 |
| [`mlc.minilang_parser._tok_kind_id`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-tok-kind-id-inline-function-tok-kind-id-tok-mlc-minilang-parser-ml-940568509) | `mlc/minilang_parser.ml:1701` | 5 | 4 | 4 | 3 | 1 | 181.11 | 68.4 |
| [`mlc.minilang_parser._tok_pos`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-tok-pos-inline-function-tok-pos-tok-mlc-minilang-parser-ml-1463903453) | `mlc/minilang_parser.ml:1732` | 5 | 4 | 4 | 3 | 1 | 187.98 | 68.29 |
| [`mlc.minilang_parser._tok_text_part`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-tok-text-part-function-tok-text-part-v-mlc-minilang-parser-ml-396664280) | `mlc/minilang_parser.ml:75` | 9 | 12 | 6 | 5 | 1 | 289.89 | 61.14 |
| [`mlc.minilang_parser._tok_value`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-tok-value-inline-function-tok-value-tok-mlc-minilang-parser-ml-1239632543) | `mlc/minilang_parser.ml:1717` | 10 | 8 | 5 | 5 | 2 | 398.84 | 59.3 |
| [`mlc.minilang_parser._token_arena_grow`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-token-arena-grow-function-token-arena-grow-arena-mlc-minilang-parser-ml-2029556189) | `mlc/minilang_parser.ml:1335` | 16 | 13 | 2 | 1 | 1 | 607.25 | 53.98 |
| [`mlc.minilang_parser._token_arena_new`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-token-arena-new-function-token-arena-new-source-len-mlc-minilang-parser-ml-349777331) | `mlc/minilang_parser.ml:1259` | 5 | 4 | 2 | 1 | 1 | 388.64 | 66.35 |
| [`mlc.minilang_parser._token_count`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-token-count-inline-function-token-count-tokens-mlc-minilang-parser-ml-93148851) | `mlc/minilang_parser.ml:1695` | 3 | 1 | 1 | 0 | 0 | 39.86 | 78.25 |
| [`mlc.minilang_parser._token_fixed_value`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-token-fixed-value-inline-function-token-fixed-value-kind-mlc-minilang-parser-ml-1959595933) | `mlc/minilang_parser.ml:1321` | 11 | 17 | 9 | 8 | 1 | 394.2 | 57.9 |
| [`mlc.minilang_parser._token_kind_name`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-token-kind-name-function-token-kind-name-kind-id-mlc-minilang-parser-ml-1488996580) | `mlc/minilang_parser.ml:1239` | 17 | 29 | 15 | 14 | 1 | 713.53 | 51.16 |
| [`mlc.minilang_parser._token_pos_read`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-token-pos-read-inline-function-token-pos-read-buf-index-mlc-minilang-parser-ml-680922676) | `mlc/minilang_parser.ml:1293` | 3 | 1 | 1 | 0 | 0 | 58.81 | 77.07 |
| [`mlc.minilang_parser._token_pos_write`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-token-pos-write-function-token-pos-write-buf-index-value-mlc-minilang-parser-ml-800373794) | `mlc/minilang_parser.ml:1287` | 3 | 1 | 1 | 0 | 0 | 63.12 | 76.85 |
| [`mlc.minilang_parser._token_push`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-token-push-function-token-push-arena-tail-kind-value-pos-mlc-minilang-parser-ml-55978270) | `mlc/minilang_parser.ml:1354` | 13 | 12 | 2 | 1 | 1 | 528.32 | 56.37 |
| [`mlc.minilang_parser._token_text_store`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-token-text-store-function-token-text-store-arena-kind-value-mlc-minilang-parser-ml-1527974076) | `mlc/minilang_parser.ml:1299` | 16 | 16 | 19 | 19 | 2 | 1117.47 | 49.83 |
| [`mlc.minilang_parser._token_u32_read`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-token-u32-read-inline-function-token-u32-read-buf-index-mlc-minilang-parser-ml-1385632836) | `mlc/minilang_parser.ml:1280` | 4 | 2 | 1 | 0 | 0 | 239.75 | 70.07 |
| [`mlc.minilang_parser._token_u32_write`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-token-u32-write-function-token-u32-write-buf-index-value-mlc-minilang-parser-ml-1588777074) | `mlc/minilang_parser.ml:1270` | 7 | 5 | 1 | 0 | 0 | 302.61 | 64.06 |
| [`mlc.minilang_parser._unknownChar`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-unknownchar-function-unknownchar-code-pos-mlc-minilang-parser-ml-1408950211) | `mlc/minilang_parser.ml:1009` | 3 | 1 | 1 | 0 | 0 | 116 | 75 |
| [`mlc.minilang_parser.format_error`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-format-error-function-format-error-source-filename-pos-message-kind-mlc-minilang-parser-ml-307693077) | `mlc/minilang_parser.ml:1644` | 18 | 16 | 7 | 6 | 1 | 895.35 | 51.01 |
| [`mlc.minilang_parser.newParseError`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-newparseerror-function-newparseerror-message-pos-filename-mlc-minilang-parser-ml-282004966) | `mlc/minilang_parser.ml:936` | 3 | 1 | 1 | 0 | 0 | 69.19 | 76.57 |
| [`mlc.minilang_parser.newToken`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-newtoken-function-newtoken-kind-value-pos-mlc-minilang-parser-ml-1173034097) | `mlc/minilang_parser.ml:928` | 3 | 1 | 1 | 0 | 0 | 69.19 | 76.57 |
| [`mlc.minilang_parser.parse_expression`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-expression-function-parse-expression-source-filename-mlc-minilang-parser-ml-299887402) | `mlc/minilang_parser.ml:4085` | 16 | 13 | 5 | 4 | 1 | 551.03 | 53.87 |
| [`mlc.minilang_parser.parse_program`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-program-function-parse-program-source-filename-mlc-minilang-parser-ml-1849808790) | `mlc/minilang_parser.ml:5822` | 23 | 19 | 7 | 8 | 2 | 801.43 | 49.02 |
| [`mlc.minilang_parser.parse_program_keepgoing`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-parse-program-keepgoing-function-parse-program-keepgoing-source-filename-max-errors-mlc-minilang-parser-ml-2140012046) | `mlc/minilang_parser.ml:5850` | 36 | 26 | 11 | 15 | 3 | 1225.34 | 42.95 |
| [`mlc.minilang_parser.prepare_language_features`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-prepare-language-features-function-prepare-language-features-program-mlc-minilang-parser-ml-495971202) | `mlc/minilang_parser.ml:5781` | 32 | 33 | 6 | 5 | 1 | 1632.06 | 43.86 |
| [`mlc.minilang_parser.preprocess_compile_directives`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-preprocess-compile-directives-function-preprocess-compile-directives-code-filename-mlc-minilang-parser-ml-1776364800) | `mlc/minilang_parser.ml:4553` | 135 | 145 | 54 | 159 | 5 | 9662.9 | 18.36 |
| [`mlc.minilang_parser.set_compile_defines`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-set-compile-defines-function-set-compile-defines-specs-mlc-minilang-parser-ml-651058748) | `mlc/minilang_parser.ml:4385` | 27 | 26 | 10 | 21 | 4 | 1306.33 | 45.61 |
| [`mlc.minilang_parser.set_compile_target`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-set-compile-target-function-set-compile-target-target-mlc-minilang-parser-ml-1786509371) | `mlc/minilang_parser.ml:4186` | 19 | 15 | 7 | 6 | 1 | 477.56 | 52.41 |
| [`mlc.minilang_parser.tokenize`](File-mlc-minilang-parser-ml-1485036712.md#function-function-mlc-minilang-parser-tokenize-function-tokenize-code-mlc-minilang-parser-ml-697094663) | `mlc/minilang_parser.ml:1370` | 218 | 174 | 93 | 161 | 5 | 10044.35 | 8.46 |
| [`mlc.pe._bytes_from_array`](File-mlc-pe-ml-319201864.md#function-function-mlc-pe-bytes-from-array-function-bytes-from-array-arr-mlc-pe-ml-1077762051) | `mlc/pe.ml:113` | 8 | 6 | 3 | 2 | 1 | 260.06 | 62.99 |
| [`mlc.pe._bytes_ljust`](File-mlc-pe-ml-319201864.md#function-function-mlc-pe-bytes-ljust-function-bytes-ljust-b-size-mlc-pe-ml-1363468897) | `mlc/pe.ml:131` | 3 | 1 | 1 | 0 | 0 | 53.15 | 77.38 |
| [`mlc.pe._bytes_pad_to`](File-mlc-pe-ml-319201864.md#function-function-mlc-pe-bytes-pad-to-function-bytes-pad-to-b-size-mlc-pe-ml-863210917) | `mlc/pe.ml:124` | 4 | 3 | 2 | 1 | 1 | 143.06 | 71.5 |
| [`mlc.pe._bytes_write_at`](File-mlc-pe-ml-319201864.md#function-function-mlc-pe-bytes-write-at-function-bytes-write-at-dst-offset-src-mlc-pe-ml-671643854) | `mlc/pe.ml:137` | 5 | 4 | 2 | 1 | 1 | 160 | 69.05 |
| [`mlc.pe._find_section_by_name`](File-mlc-pe-ml-319201864.md#function-function-mlc-pe-find-section-by-name-function-find-section-by-name-pe-name-mlc-pe-ml-696213732) | `mlc/pe.ml:208` | 9 | 6 | 4 | 4 | 2 | 283.28 | 61.48 |
| [`mlc.pe._imports_get_funcs`](File-mlc-pe-ml-319201864.md#function-function-mlc-pe-imports-get-funcs-function-imports-get-funcs-imports-dll-mlc-pe-ml-734763102) | `mlc/pe.ml:176` | 9 | 6 | 4 | 4 | 2 | 264.7 | 61.68 |
| [`mlc.pe._named_get`](File-mlc-pe-ml-319201864.md#function-function-mlc-pe-named-get-function-named-get-arr-name-default-value-mlc-pe-ml-1950578045) | `mlc/pe.ml:145` | 10 | 8 | 5 | 5 | 2 | 382.74 | 59.43 |
| [`mlc.pe._named_set`](File-mlc-pe-ml-319201864.md#function-function-mlc-pe-named-set-function-named-set-arr-name-value-mlc-pe-ml-2095775155) | `mlc/pe.ml:158` | 15 | 9 | 7 | 12 | 4 | 593.88 | 53.98 |
| [`mlc.pe._next_section_raw_addr`](File-mlc-pe-ml-319201864.md#function-function-mlc-pe-next-section-raw-addr-function-next-section-raw-addr-pe-mlc-pe-ml-1712410717) | `mlc/pe.ml:198` | 7 | 4 | 2 | 1 | 1 | 199.04 | 65.2 |
| [`mlc.pe._section_name_bytes`](File-mlc-pe-ml-319201864.md#function-function-mlc-pe-section-name-bytes-function-section-name-bytes-name-mlc-pe-ml-427745929) | `mlc/pe.ml:188` | 7 | 4 | 2 | 1 | 1 | 130.8 | 66.48 |
| [`mlc.pe.add_section`](File-mlc-pe-ml-319201864.md#function-function-mlc-pe-add-section-function-add-section-pe-name-data-characteristics-mlc-pe-ml-1626907056) | `mlc/pe.ml:237` | 5 | 3 | 1 | 0 | 0 | 190.16 | 68.66 |
| [`mlc.pe.build`](File-mlc-pe-ml-319201864.md#function-function-mlc-pe-build-function-build-pe-mlc-pe-ml-176955077) | `mlc/pe.ml:276` | 127 | 110 | 22 | 39 | 3 | 7590.67 | 23.98 |
| [`mlc.pe.build_idata`](File-mlc-pe-ml-319201864.md#function-function-mlc-pe-build-idata-function-build-idata-imports-base-rva-mlc-pe-ml-121533309) | `mlc/pe.ml:428` | 103 | 80 | 22 | 47 | 5 | 5642.47 | 26.87 |
| [`mlc.pe.layout`](File-mlc-pe-ml-319201864.md#function-function-mlc-pe-layout-function-layout-pe-mlc-pe-ml-1996787905) | `mlc/pe.ml:245` | 25 | 20 | 4 | 6 | 3 | 1010.65 | 47.93 |
| [`mlc.pe.newPEBuilder`](File-mlc-pe-ml-319201864.md#function-function-mlc-pe-newpebuilder-function-newpebuilder-mlc-pe-ml-1520997444) | `mlc/pe.ml:219` | 12 | 1 | 1 | 0 | 0 | 101.58 | 62.27 |
| [`mlc.project._abspath`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-abspath-function-abspath-path-mlc-project-ml-1572840265) | `mlc/project.ml:143` | 8 | 8 | 5 | 4 | 1 | 322.09 | 62.07 |
| [`mlc.project._append_unique_path`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-append-unique-path-function-append-unique-path-paths-path-mlc-project-ml-91913875) | `mlc/project.ml:510` | 9 | 6 | 4 | 6 | 3 | 302.86 | 61.27 |
| [`mlc.project._atomic_replace`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-atomic-replace-function-atomic-replace-source-path-destination-path-mlc-project-ml-2036966507) | `mlc/project.ml:907` | 4 | 3 | 2 | 1 | 1 | 122.62 | 71.97 |
| [`mlc.project._cache_artifact_path`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-cache-artifact-path-function-cache-artifact-path-pb-digest-mlc-project-ml-423707984) | `mlc/project.ml:749` | 3 | 1 | 1 | 0 | 0 | 85.95 | 75.91 |
| [`mlc.project._canon_linux`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-canon-linux-function-canon-linux-path-mlc-project-ml-1761756277) | `mlc/project.ml:161` | 26 | 23 | 13 | 20 | 4 | 966.62 | 46.48 |
| [`mlc.project._collect_import_dependencies`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-collect-import-dependencies-function-collect-import-dependencies-collector-include-dirs-excluded-mlc-project-ml-1279196130) | `mlc/project.ml:636` | 25 | 19 | 9 | 20 | 5 | 1081.92 | 47.05 |
| [`mlc.project._collect_ml_files`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-collect-ml-files-function-collect-ml-files-path-excluded-collector-mlc-project-ml-349996124) | `mlc/project.ml:502` | 3 | 1 | 1 | 0 | 0 | 78.87 | 76.18 |
| [`mlc.project._collect_ml_files_inner`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-collect-ml-files-inner-function-collect-ml-files-inner-path-excluded-collector-follow-directory-link-mlc-project-ml-1921535988) | `mlc/project.ml:470` | 26 | 28 | 16 | 17 | 2 | 1577.14 | 44.59 |
| [`mlc.project._collector_add_import_file`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-collector-add-import-file-function-collector-add-import-file-collector-path-excluded-mlc-project-ml-1071809644) | `mlc/project.ml:617` | 12 | 10 | 5 | 4 | 1 | 557.41 | 56.56 |
| [`mlc.project._copy_file_preserve_mode`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-copy-file-preserve-mode-function-copy-file-preserve-mode-source-path-destination-path-mlc-project-ml-1481878617) | `mlc/project.ml:755` | 5 | 4 | 2 | 1 | 1 | 151.27 | 69.22 |
| [`mlc.project._dirname`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-dirname-function-dirname-path-mlc-project-ml-1922658205) | `mlc/project.ml:106` | 12 | 10 | 6 | 8 | 3 | 385 | 57.55 |
| [`mlc.project._ensure_dir`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-ensure-dir-function-ensure-dir-path-mlc-project-ml-636457735) | `mlc/project.ml:197` | 10 | 11 | 9 | 9 | 2 | 446.93 | 58.42 |
| [`mlc.project._file_content_id`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-file-content-id-function-file-content-id-path-mlc-project-ml-1934850017) | `mlc/project.ml:732` | 3 | 1 | 1 | 0 | 0 | 68.11 | 76.62 |
| [`mlc.project._file_content_id_with_buffer`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-file-content-id-with-buffer-function-file-content-id-with-buffer-path-buffer-mlc-project-ml-1790270063) | `mlc/project.ml:704` | 25 | 27 | 10 | 11 | 2 | 1316 | 46.32 |
| [`mlc.project._hash_byte`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-hash-byte-function-hash-byte-h-value-mlc-project-ml-2106437887) | `mlc/project.ml:419` | 5 | 3 | 1 | 0 | 0 | 206.44 | 68.41 |
| [`mlc.project._hash_bytes`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-hash-bytes-function-hash-bytes-h-value-mlc-project-ml-1455792965) | `mlc/project.ml:427` | 8 | 7 | 4 | 3 | 1 | 277.33 | 62.66 |
| [`mlc.project._hash_text`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-hash-text-function-hash-text-h-value-mlc-project-ml-260538367) | `mlc/project.ml:438` | 4 | 3 | 2 | 1 | 1 | 144.43 | 71.48 |
| [`mlc.project._hex32`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-hex32-function-hex32-value-mlc-project-ml-1227518279) | `mlc/project.ml:664` | 10 | 7 | 2 | 1 | 1 | 199.69 | 61.81 |
| [`mlc.project._is_abs`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-is-abs-function-is-abs-path-mlc-project-ml-642925041) | `mlc/project.ml:134` | 6 | 7 | 7 | 6 | 1 | 413.68 | 63.76 |
| [`mlc.project._is_directory_link`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-is-directory-link-function-is-directory-link-path-mlc-project-ml-1407735777) | `mlc/project.ml:455` | 5 | 4 | 2 | 1 | 1 | 166.91 | 68.92 |
| [`mlc.project._is_known_key`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-is-known-key-function-is-known-key-key-mlc-project-ml-1385337063) | `mlc/project.ml:269` | 3 | 1 | 1 | 0 | 0 | 220.42 | 73.05 |
| [`mlc.project._join`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-join-function-join-a-b-mlc-project-ml-1487255859) | `mlc/project.ml:121` | 6 | 7 | 8 | 7 | 1 | 385.44 | 63.84 |
| [`mlc.project._object_cache_dir`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-object-cache-dir-function-object-cache-dir-pb-digest-mlc-project-ml-1184984058) | `mlc/project.ml:849` | 3 | 1 | 1 | 0 | 0 | 85.11 | 75.94 |
| [`mlc.project._parse_string_array`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-parse-string-array-function-parse-string-array-value-mlc-project-ml-804613051) | `mlc/project.ml:225` | 41 | 38 | 28 | 44 | 3 | 2376 | 37.41 |
| [`mlc.project._path_key`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-path-key-function-path-key-path-mlc-project-ml-1639727953) | `mlc/project.ml:445` | 3 | 1 | 1 | 0 | 0 | 46.51 | 77.78 |
| [`mlc.project._project_u32le`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-project-u32le-function-project-u32le-value-offset-mlc-project-ml-2074318368) | `mlc/project.ml:698` | 3 | 1 | 1 | 0 | 0 | 203.13 | 73.3 |
| [`mlc.project._project_word_char`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-project-word-char-function-project-word-char-source-index-mlc-project-ml-2072998205) | `mlc/project.ml:530` | 5 | 4 | 3 | 2 | 1 | 355 | 66.49 |
| [`mlc.project._quoted_import_paths`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-quoted-import-paths-function-quoted-import-paths-source-mlc-project-ml-1344714487) | `mlc/project.ml:582` | 32 | 24 | 19 | 31 | 5 | 1568.99 | 42.24 |
| [`mlc.project._relative_path`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-relative-path-function-relative-path-base-value-mlc-project-ml-1890277016) | `mlc/project.ml:190` | 4 | 3 | 2 | 1 | 1 | 121.84 | 71.99 |
| [`mlc.project._skip_import_trivia`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-skip-import-trivia-function-skip-import-trivia-source-index-mlc-project-ml-141654301) | `mlc/project.ml:538` | 26 | 20 | 18 | 26 | 3 | 1058.19 | 45.53 |
| [`mlc.project._skip_project_string`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-skip-project-string-function-skip-project-string-source-index-mlc-project-ml-2029185969) | `mlc/project.ml:567` | 12 | 9 | 4 | 5 | 2 | 292.56 | 58.65 |
| [`mlc.project._string_less`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-string-less-function-string-less-left-right-mlc-project-ml-2012463843) | `mlc/project.ml:677` | 13 | 12 | 6 | 10 | 3 | 550 | 55.71 |
| [`mlc.project._unquote`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-unquote-function-unquote-value-mlc-project-ml-2065359739) | `mlc/project.ml:214` | 8 | 7 | 4 | 3 | 1 | 470 | 61.05 |
| [`mlc.project._valid_define_name`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-valid-define-name-function-valid-define-name-name-mlc-project-ml-1269587149) | `mlc/project.ml:275` | 12 | 11 | 17 | 19 | 3 | 803.61 | 53.83 |
| [`mlc.project._valid_define_value`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-valid-define-value-function-valid-define-value-value-mlc-project-ml-812173753) | `mlc/project.ml:290` | 15 | 14 | 9 | 9 | 2 | 659.92 | 53.39 |
| [`mlc.project._valid_project_digest`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-valid-project-digest-function-valid-project-digest-value-mlc-project-ml-928786795) | `mlc/project.ml:738` | 8 | 7 | 8 | 8 | 2 | 418.76 | 60.86 |
| [`mlc.project.ensureOutputDirectory`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-ensureoutputdirectory-function-ensureoutputdirectory-output-path-mlc-project-ml-196881123) | `mlc/project.ml:1019` | 3 | 1 | 1 | 0 | 0 | 47.55 | 77.71 |
| [`mlc.project.expandArgs`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-expandargs-function-expandargs-args-mlc-project-ml-1114332615) | `mlc/project.ml:308` | 106 | 106 | 54 | 95 | 3 | 7167.06 | 21.56 |
| [`mlc.project.fingerprint`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-fingerprint-function-fingerprint-pb-input-path-include-dirs-mlc-project-ml-1921258819) | `mlc/project.ml:771` | 45 | 38 | 15 | 20 | 3 | 2590.85 | 38.02 |
| [`mlc.project.restore`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-restore-function-restore-pb-digest-output-path-mlc-project-ml-1242055481) | `mlc/project.ml:829` | 17 | 22 | 12 | 11 | 1 | 1122.67 | 50.19 |
| [`mlc.project.restoreObjects`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-restoreobjects-function-restoreobjects-pb-digest-mlc-project-ml-1176711488) | `mlc/project.ml:856` | 46 | 56 | 26 | 32 | 2 | 2943.87 | 35.94 |
| [`mlc.project.store`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-store-function-store-pb-digest-output-path-mlc-project-ml-1878511363) | `mlc/project.ml:922` | 31 | 34 | 14 | 16 | 3 | 1734.23 | 42.9 |
| [`mlc.project.storeObjects`](File-mlc-project-ml-1332928426.md#function-function-mlc-project-storeobjects-function-storeobjects-pb-digest-source-dir-mlc-project-ml-833177017) | `mlc/project.ml:960` | 51 | 53 | 24 | 31 | 3 | 3273.56 | 34.91 |
| [`mlc.tools._arr_concat_chunks_balanced`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-concat-chunks-balanced-function-arr-concat-chunks-balanced-parts-mlc-tools-ml-2039363910) | `mlc/tools.ml:1325` | 18 | 13 | 6 | 8 | 3 | 630.85 | 52.21 |
| [`mlc.tools._arr_copy_prefix`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-copy-prefix-function-arr-copy-prefix-arr-n-mlc-tools-ml-728550065) | `mlc/tools.ml:1222` | 8 | 6 | 4 | 3 | 1 | 261.52 | 62.83 |
| [`mlc.tools._arr_fill`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-fill-function-arr-fill-n-fill-mlc-tools-ml-178556933) | `mlc/tools.ml:1213` | 4 | 3 | 3 | 2 | 1 | 142.62 | 71.38 |
| [`mlc.tools._arr_tail_from_array`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-tail-from-array-function-arr-tail-from-array-arr-cap-mlc-tools-ml-1753405711) | `mlc/tools.ml:1262` | 11 | 10 | 5 | 4 | 1 | 432.43 | 58.15 |
| [`mlc.tools._arr_tail_new`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-tail-new-function-arr-tail-new-cap-mlc-tools-ml-1217985466) | `mlc/tools.ml:1254` | 5 | 4 | 3 | 2 | 1 | 180.09 | 68.56 |
| [`mlc.tools._arr_tail_to_array`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-tail-to-array-function-arr-tail-to-array-tail-mlc-tools-ml-1979359264) | `mlc/tools.ml:1346` | 34 | 32 | 15 | 19 | 2 | 1161.22 | 43.11 |
| [`mlc.tools._arr_unwrap_value`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-unwrap-value-function-arr-unwrap-value-value-mlc-tools-ml-92285567) | `mlc/tools.ml:1242` | 9 | 5 | 4 | 3 | 1 | 136.74 | 63.69 |
| [`mlc.tools._arr_wrap_value`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-wrap-value-function-arr-wrap-value-value-mlc-tools-ml-1234776493) | `mlc/tools.ml:1233` | 6 | 3 | 2 | 1 | 1 | 77.71 | 69.52 |
| [`mlc.tools._ast_bin_ensure`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-bin-ensure-function-ast-bin-ensure-need-mlc-tools-ml-1325192418) | `mlc/tools.ml:247` | 28 | 26 | 6 | 5 | 1 | 1034.01 | 46.52 |
| [`mlc.tools._ast_intern`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-intern-function-ast-intern-index-map-values-text-mlc-tools-ml-385940662) | `mlc/tools.ml:317` | 8 | 7 | 3 | 2 | 1 | 374.06 | 61.88 |
| [`mlc.tools._ast_leaf_ensure`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-leaf-ensure-function-ast-leaf-ensure-need-mlc-tools-ml-826634498) | `mlc/tools.ml:282` | 28 | 26 | 6 | 5 | 1 | 1034.01 | 46.52 |
| [`mlc.tools._ast_leaf_kind_id`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-leaf-kind-id-function-ast-leaf-kind-id-kind-mlc-tools-ml-133961742) | `mlc/tools.ml:328` | 8 | 11 | 6 | 5 | 1 | 237.19 | 62.86 |
| [`mlc.tools._ast_leaf_kind_name`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-leaf-kind-name-function-ast-leaf-kind-name-kind-id-mlc-tools-ml-625233154) | `mlc/tools.ml:339` | 8 | 11 | 6 | 5 | 1 | 237.19 | 62.86 |
| [`mlc.tools._ast_u32_read`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-u32-read-inline-function-ast-u32-read-buf-index-mlc-tools-ml-525585164) | `mlc/tools.ml:191` | 4 | 2 | 1 | 0 | 0 | 239.75 | 70.07 |
| [`mlc.tools._ast_u32_write`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-u32-write-function-ast-u32-write-buf-index-value-mlc-tools-ml-2014669730) | `mlc/tools.ml:181` | 7 | 5 | 1 | 0 | 0 | 302.61 | 64.06 |
| [`mlc.tools._bp_chunk_count`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-bp-chunk-count-inline-function-bp-chunk-count-bp-mlc-tools-ml-2054420897) | `mlc/tools.ml:1781` | 17 | 16 | 11 | 17 | 3 | 816.85 | 51.29 |
| [`mlc.tools._bp_chunk_get`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-bp-chunk-get-function-bp-chunk-get-bp-idx-mlc-tools-ml-1210112987) | `mlc/tools.ml:1801` | 22 | 14 | 11 | 14 | 3 | 965.88 | 48.34 |
| [`mlc.tools._bp_chunk_push`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-bp-chunk-push-function-bp-chunk-push-bp-page-mlc-tools-ml-22882391) | `mlc/tools.ml:1842` | 6 | 4 | 1 | 0 | 0 | 185.84 | 67 |
| [`mlc.tools._bp_chunk_set`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-bp-chunk-set-function-bp-chunk-set-bp-idx-page-mlc-tools-ml-702734724) | `mlc/tools.ml:1826` | 13 | 10 | 2 | 1 | 1 | 431.01 | 56.98 |
| [`mlc.tools._bp_ensure`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-bp-ensure-function-bp-ensure-bp-need-mlc-tools-ml-395796612) | `mlc/tools.ml:1851` | 9 | 8 | 4 | 3 | 1 | 302.86 | 61.27 |
| [`mlc.tools._chunks_is_paged`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-chunks-is-paged-inline-function-chunks-is-paged-chunks-mlc-tools-ml-133065431) | `mlc/tools.ml:1392` | 5 | 5 | 4 | 3 | 1 | 233.83 | 67.63 |
| [`mlc.tools._chunks_materialize`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-chunks-materialize-function-chunks-materialize-chunks-mlc-tools-ml-629470818) | `mlc/tools.ml:1465` | 17 | 17 | 7 | 7 | 2 | 575 | 52.89 |
| [`mlc.tools._chunks_paged_from_array`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-chunks-paged-from-array-function-chunks-paged-from-array-chunks-mlc-tools-ml-1180778236) | `mlc/tools.ml:1438` | 8 | 6 | 4 | 3 | 1 | 274.02 | 62.69 |
| [`mlc.tools._chunks_paged_new`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-chunks-paged-new-function-chunks-paged-new-mlc-tools-ml-1761353226) | `mlc/tools.ml:1400` | 3 | 1 | 1 | 0 | 0 | 71.7 | 76.47 |
| [`mlc.tools._chunks_paged_push`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-chunks-paged-push-function-chunks-paged-push-chunks-chunk-mlc-tools-ml-560933513) | `mlc/tools.ml:1406` | 26 | 27 | 12 | 13 | 2 | 1307.73 | 45.7 |
| [`mlc.tools._chunks_paged_tag`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-chunks-paged-tag-inline-function-chunks-paged-tag-mlc-tools-ml-312589883) | `mlc/tools.ml:1386` | 3 | 1 | 1 | 0 | 0 | 27 | 79.44 |
| [`mlc.tools._chunks_push_chunk`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-chunks-push-chunk-function-chunks-push-chunk-chunks-chunk-mlc-tools-ml-1249179521) | `mlc/tools.ml:1449` | 13 | 8 | 4 | 3 | 1 | 311.14 | 57.71 |
| [`mlc.tools._f32_is_inf`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-f32-is-inf-inline-function-f32-is-inf-v-mlc-tools-ml-1561788679) | `mlc/tools.ml:1106` | 6 | 6 | 3 | 2 | 1 | 155.32 | 67.28 |
| [`mlc.tools._f32_is_nan`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-f32-is-nan-inline-function-f32-is-nan-v-mlc-tools-ml-216685591) | `mlc/tools.ml:1100` | 3 | 1 | 1 | 0 | 0 | 70.31 | 76.52 |
| [`mlc.tools._fm_hash_any`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-fm-hash-any-function-fm-hash-any-key-mlc-tools-ml-406633905) | `mlc/tools.ml:723` | 48 | 47 | 24 | 40 | 3 | 1982.66 | 37.01 |
| [`mlc.tools._fm_insert_no_resize`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-fm-insert-no-resize-function-fm-insert-no-resize-mapv-key-value-mlc-tools-ml-1526516226) | `mlc/tools.ml:895` | 33 | 32 | 8 | 11 | 3 | 1158.78 | 44.34 |
| [`mlc.tools._fm_is_valid`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-fm-is-valid-function-fm-is-valid-mapv-mlc-tools-ml-1950842590) | `mlc/tools.ml:779` | 12 | 19 | 12 | 11 | 1 | 717.99 | 54.85 |
| [`mlc.tools._fm_next_pow2`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-fm-next-pow2-function-fm-next-pow2-n-mlc-tools-ml-582127918) | `mlc/tools.ml:712` | 8 | 6 | 4 | 3 | 1 | 173.92 | 64.08 |
| [`mlc.tools._fm_probe_slot`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-fm-probe-slot-function-fm-probe-slot-mapv-key-mlc-tools-ml-175160969) | `mlc/tools.ml:879` | 13 | 13 | 5 | 6 | 2 | 569.35 | 55.73 |
| [`mlc.tools._fm_rehash`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-fm-rehash-function-fm-rehash-mapv-new-cap-mlc-tools-ml-1223263127) | `mlc/tools.ml:931` | 11 | 9 | 5 | 5 | 2 | 485.97 | 57.8 |
| [`mlc.tools._u64_mask`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-u64-mask-function-u64-mask-returns-int-mlc-tools-ml-205450594) | `mlc/tools.ml:705` | 3 | 1 | 1 | 0 | 0 | 41.51 | 78.13 |
| [`mlc.tools.align_to_mod`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-align-to-mod-function-align-to-mod-n-mod-target-mlc-tools-ml-61304145) | `mlc/tools.ml:1024` | 5 | 3 | 1 | 0 | 0 | 116 | 70.16 |
| [`mlc.tools.align_up`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-align-up-function-align-up-n-as-int-a-as-int-returns-int-mlc-tools-ml-1373993483) | `mlc/tools.ml:1016` | 3 | 1 | 1 | 0 | 0 | 130.8 | 74.64 |
| [`mlc.tools.arr_chunk_count`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-chunk-count-function-arr-chunk-count-builder-mlc-tools-ml-1500029251) | `mlc/tools.ml:1748` | 4 | 3 | 2 | 1 | 1 | 144.43 | 71.48 |
| [`mlc.tools.arr_chunk_finish`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-chunk-finish-function-arr-chunk-finish-builder-mlc-tools-ml-432097025) | `mlc/tools.ml:1740` | 5 | 4 | 2 | 1 | 1 | 149.34 | 69.26 |
| [`mlc.tools.arr_chunk_get`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-chunk-get-function-arr-chunk-get-builder-idx-defaultv-mlc-tools-ml-1773739253) | `mlc/tools.ml:1757` | 4 | 3 | 2 | 1 | 1 | 181.52 | 70.78 |
| [`mlc.tools.arr_chunk_new`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-chunk-new-function-arr-chunk-new-cap-mlc-tools-ml-928944558) | `mlc/tools.ml:1488` | 5 | 4 | 3 | 2 | 1 | 180.94 | 68.54 |
| [`mlc.tools.arr_chunk_push`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-chunk-push-function-arr-chunk-push-builder-value-mlc-tools-ml-4942530) | `mlc/tools.ml:1536` | 8 | 7 | 2 | 1 | 1 | 307.67 | 62.61 |
| [`mlc.tools.arr_chunk_push_all`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-chunk-push-all-function-arr-chunk-push-all-builder-values-mlc-tools-ml-1045375835) | `mlc/tools.ml:1765` | 8 | 6 | 4 | 3 | 1 | 274.02 | 62.69 |
| [`mlc.tools.arr_chunk_tail_get`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-chunk-tail-get-function-arr-chunk-tail-get-tail-idx-defaultv-mlc-tools-ml-814018366) | `mlc/tools.ml:1291` | 11 | 12 | 8 | 8 | 2 | 495.42 | 57.34 |
| [`mlc.tools.arr_chunk_tail_len`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-chunk-tail-len-inline-function-arr-chunk-tail-len-tail-mlc-tools-ml-1369721375) | `mlc/tools.ml:1276` | 10 | 14 | 11 | 10 | 1 | 637.9 | 57.07 |
| [`mlc.tools.arr_chunk_tail_set`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-chunk-tail-set-function-arr-chunk-tail-set-tail-idx-value-mlc-tools-ml-969163644) | `mlc/tools.ml:1307` | 15 | 19 | 14 | 14 | 2 | 918.14 | 51.72 |
| [`mlc.tools.arr_chunked_count`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-chunked-count-function-arr-chunked-count-chunks-tail-cap-mlc-tools-ml-2019348862) | `mlc/tools.ml:1672` | 18 | 15 | 9 | 15 | 4 | 749.53 | 51.28 |
| [`mlc.tools.arr_chunked_finish`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-chunked-finish-function-arr-chunked-finish-chunks-tail-mlc-tools-ml-746745258) | `mlc/tools.ml:1639` | 11 | 7 | 6 | 5 | 1 | 394.2 | 58.3 |
| [`mlc.tools.arr_chunked_get`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-chunked-get-function-arr-chunked-get-chunks-tail-idx-cap-defaultv-mlc-tools-ml-245430672) | `mlc/tools.ml:1697` | 38 | 34 | 18 | 26 | 3 | 1633.21 | 40.62 |
| [`mlc.tools.arr_chunked_groups`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-chunked-groups-function-arr-chunked-groups-chunks-tail-mlc-tools-ml-456156734) | `mlc/tools.ml:1654` | 13 | 12 | 5 | 6 | 2 | 480 | 56.25 |
| [`mlc.tools.arr_chunked_push`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-chunked-push-function-arr-chunked-push-chunks-tail-value-cap-mlc-tools-ml-1590641689) | `mlc/tools.ml:1499` | 30 | 30 | 19 | 21 | 2 | 1691.49 | 42.62 |
| [`mlc.tools.arr_drop_last`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-drop-last-function-arr-drop-last-values-mlc-tools-ml-425046980) | `mlc/tools.ml:53` | 8 | 6 | 4 | 3 | 1 | 307.67 | 62.34 |
| [`mlc.tools.arr_merge_chunk_groups_with_tail`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-merge-chunk-groups-with-tail-function-arr-merge-chunk-groups-with-tail-groups-tail-arr-mlc-tools-ml-914227352) | `mlc/tools.ml:1577` | 29 | 24 | 13 | 18 | 3 | 1148.96 | 44.92 |
| [`mlc.tools.arr_merge_chunks_balanced`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-merge-chunks-balanced-function-arr-merge-chunks-balanced-chunks-mlc-tools-ml-1076984976) | `mlc/tools.ml:1547` | 26 | 20 | 8 | 9 | 2 | 813.99 | 47.68 |
| [`mlc.tools.arr_merge_variadic_parts`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-merge-variadic-parts-function-arr-merge-variadic-parts-parts-mlc-tools-ml-1010500314) | `mlc/tools.ml:1609` | 26 | 20 | 7 | 8 | 2 | 776.84 | 47.95 |
| [`mlc.tools.arr_vec_clear`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-vec-clear-function-arr-vec-clear-vec-mlc-tools-ml-1133666688) | `mlc/tools.ml:581` | 6 | 5 | 2 | 1 | 1 | 135.93 | 67.82 |
| [`mlc.tools.arr_vec_count`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-vec-count-function-arr-vec-count-vec-mlc-tools-ml-2146057648) | `mlc/tools.ml:564` | 4 | 3 | 2 | 1 | 1 | 114.45 | 72.18 |
| [`mlc.tools.arr_vec_count_trusted`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-vec-count-trusted-inline-function-arr-vec-count-trusted-vec-returns-int-mlc-tools-ml-1209367981) | `mlc/tools.ml:572` | 6 | 6 | 3 | 2 | 1 | 197.65 | 66.55 |
| [`mlc.tools.arr_vec_finish`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-vec-finish-function-arr-vec-finish-vec-mlc-tools-ml-1093773168) | `mlc/tools.ml:690` | 9 | 8 | 4 | 4 | 2 | 330.34 | 61.01 |
| [`mlc.tools.arr_vec_from_array`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-vec-from-array-function-arr-vec-from-array-values-extra-cap-mlc-tools-ml-728204753) | `mlc/tools.ml:673` | 14 | 12 | 6 | 6 | 2 | 493.31 | 55.33 |
| [`mlc.tools.arr_vec_get`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-vec-get-function-arr-vec-get-vec-idx-defaultv-mlc-tools-ml-1183303272) | `mlc/tools.ml:606` | 4 | 3 | 2 | 1 | 1 | 152.93 | 71.3 |
| [`mlc.tools.arr_vec_get_trusted`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-vec-get-trusted-inline-function-arr-vec-get-trusted-vec-idx-defaultv-mlc-tools-ml-1052342831) | `mlc/tools.ml:615` | 5 | 4 | 4 | 3 | 1 | 255.16 | 67.36 |
| [`mlc.tools.arr_vec_is`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-vec-is-inline-function-arr-vec-is-value-returns-bool-mlc-tools-ml-1457786993) | `mlc/tools.ml:550` | 3 | 1 | 1 | 0 | 0 | 50.19 | 77.55 |
| [`mlc.tools.arr_vec_new`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-vec-new-function-arr-vec-new-initial-cap-mlc-tools-ml-1594685863) | `mlc/tools.ml:556` | 5 | 4 | 3 | 2 | 1 | 182.84 | 68.51 |
| [`mlc.tools.arr_vec_push`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-vec-push-function-arr-vec-push-vec-value-mlc-tools-ml-78424841) | `mlc/tools.ml:646` | 23 | 19 | 8 | 12 | 3 | 837.74 | 48.75 |
| [`mlc.tools.arr_vec_release_refs`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-vec-release-refs-function-arr-vec-release-refs-vec-mlc-tools-ml-1572066892) | `mlc/tools.ml:590` | 11 | 8 | 5 | 5 | 2 | 383.37 | 58.52 |
| [`mlc.tools.arr_vec_set`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-vec-set-function-arr-vec-set-vec-idx-value-mlc-tools-ml-1560746662) | `mlc/tools.ml:625` | 5 | 4 | 2 | 1 | 1 | 171.3 | 68.84 |
| [`mlc.tools.arr_vec_set_trusted`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-arr-vec-set-trusted-inline-function-arr-vec-set-trusted-vec-idx-value-mlc-tools-ml-1365473039) | `mlc/tools.ml:635` | 7 | 6 | 4 | 3 | 1 | 287.34 | 63.81 |
| [`mlc.tools.ast_arena_release`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-arena-release-function-ast-arena-release-mlc-tools-ml-867495298) | `mlc/tools.ml:197` | 25 | 23 | 1 | 0 | 0 | 588.83 | 49.98 |
| [`mlc.tools.ast_bin_new`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-bin-new-function-ast-bin-new-left-op-right-pos-filename-mlc-tools-ml-1134644039) | `mlc/tools.ml:400` | 25 | 26 | 4 | 3 | 1 | 1072.31 | 47.75 |
| [`mlc.tools.ast_filename`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-filename-function-ast-filename-node-mlc-tools-ml-2050532786) | `mlc/tools.ml:498` | 12 | 9 | 5 | 4 | 1 | 515 | 56.8 |
| [`mlc.tools.ast_is_bin`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-is-bin-inline-function-ast-is-bin-node-mlc-tools-ml-816544171) | `mlc/tools.ml:442` | 5 | 4 | 3 | 2 | 1 | 199.69 | 68.24 |
| [`mlc.tools.ast_is_leaf`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-is-leaf-inline-function-ast-is-leaf-node-mlc-tools-ml-579049887) | `mlc/tools.ml:434` | 5 | 4 | 3 | 2 | 1 | 187.98 | 68.43 |
| [`mlc.tools.ast_is_node`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-is-node-function-ast-is-node-node-mlc-tools-ml-416585694) | `mlc/tools.ml:450` | 4 | 3 | 3 | 2 | 1 | 180.09 | 70.67 |
| [`mlc.tools.ast_kind`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-kind-function-ast-kind-node-mlc-tools-ml-1801568570) | `mlc/tools.ml:457` | 8 | 7 | 5 | 4 | 1 | 322.09 | 62.07 |
| [`mlc.tools.ast_leaf_new`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-leaf-new-function-ast-leaf-new-kind-value-pos-filename-mlc-tools-ml-1436561924) | `mlc/tools.ml:353` | 34 | 35 | 6 | 6 | 2 | 1277.59 | 44.03 |
| [`mlc.tools.ast_leaf_reset`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-leaf-reset-function-ast-leaf-reset-mlc-tools-ml-156576674) | `mlc/tools.ml:234` | 8 | 6 | 1 | 0 | 0 | 174.17 | 64.47 |
| [`mlc.tools.ast_leaf_stats`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-leaf-stats-function-ast-leaf-stats-mlc-tools-ml-1006204234) | `mlc/tools.ml:540` | 6 | 4 | 1 | 0 | 0 | 227.55 | 66.39 |
| [`mlc.tools.ast_left`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-left-function-ast-left-node-mlc-tools-ml-2028300670) | `mlc/tools.ml:513` | 5 | 5 | 5 | 4 | 1 | 298.06 | 66.76 |
| [`mlc.tools.ast_name`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-name-function-ast-name-node-mlc-tools-ml-1877619406) | `mlc/tools.ml:476` | 10 | 9 | 4 | 4 | 2 | 373.29 | 59.64 |
| [`mlc.tools.ast_op`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-op-function-ast-op-node-mlc-tools-ml-26669406) | `mlc/tools.ml:529` | 9 | 8 | 8 | 8 | 2 | 520.95 | 59.09 |
| [`mlc.tools.ast_pos`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-pos-function-ast-pos-node-mlc-tools-ml-1507811196) | `mlc/tools.ml:489` | 6 | 7 | 5 | 4 | 1 | 375.64 | 64.32 |
| [`mlc.tools.ast_right`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-right-function-ast-right-node-mlc-tools-ml-1380446152) | `mlc/tools.ml:521` | 5 | 5 | 6 | 5 | 1 | 343.48 | 66.19 |
| [`mlc.tools.ast_value`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-ast-value-function-ast-value-node-mlc-tools-ml-792916190) | `mlc/tools.ml:468` | 5 | 5 | 3 | 2 | 1 | 203.56 | 68.18 |
| [`mlc.tools.byte_pages_append`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-byte-pages-append-function-byte-pages-append-bp-src-mlc-tools-ml-1426180094) | `mlc/tools.ml:1905` | 26 | 25 | 7 | 8 | 2 | 991.88 | 47.21 |
| [`mlc.tools.byte_pages_append_string`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-byte-pages-append-string-function-byte-pages-append-string-bp-text-mlc-tools-ml-1531761367) | `mlc/tools.ml:1936` | 25 | 25 | 6 | 6 | 2 | 987 | 47.73 |
| [`mlc.tools.byte_pages_append_u16`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-byte-pages-append-u16-function-byte-pages-append-u16-bp-value-mlc-tools-ml-8321011) | `mlc/tools.ml:1966` | 20 | 17 | 3 | 2 | 1 | 732.55 | 51.16 |
| [`mlc.tools.byte_pages_append_u32`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-byte-pages-append-u32-function-byte-pages-append-u32-bp-value-mlc-tools-ml-903967159) | `mlc/tools.ml:1991` | 24 | 21 | 3 | 2 | 1 | 1055 | 48.32 |
| [`mlc.tools.byte_pages_append_u64`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-byte-pages-append-u64-function-byte-pages-append-u64-bp-value-mlc-tools-ml-753763469) | `mlc/tools.ml:2022` | 27 | 23 | 4 | 4 | 2 | 1294.61 | 46.45 |
| [`mlc.tools.byte_pages_get_byte`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-byte-pages-get-byte-function-byte-pages-get-byte-bp-idx-defaultv-mlc-tools-ml-327960060) | `mlc/tools.ml:2135` | 9 | 10 | 5 | 4 | 1 | 370 | 60.53 |
| [`mlc.tools.byte_pages_len`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-byte-pages-len-function-byte-pages-len-bp-mlc-tools-ml-1492352224) | `mlc/tools.ml:1863` | 5 | 5 | 4 | 3 | 1 | 179.31 | 68.43 |
| [`mlc.tools.byte_pages_new`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-byte-pages-new-function-byte-pages-new-mlc-tools-ml-454273826) | `mlc/tools.ml:1775` | 3 | 1 | 1 | 0 | 0 | 58.81 | 77.07 |
| [`mlc.tools.byte_pages_page`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-byte-pages-page-function-byte-pages-page-bp-page-index-mlc-tools-ml-1020656758) | `mlc/tools.ml:1883` | 5 | 5 | 5 | 4 | 1 | 254.19 | 67.24 |
| [`mlc.tools.byte_pages_page_count`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-byte-pages-page-count-function-byte-pages-page-count-bp-mlc-tools-ml-818479086) | `mlc/tools.ml:1871` | 8 | 9 | 4 | 3 | 1 | 261.34 | 62.84 |
| [`mlc.tools.byte_pages_page_used`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-byte-pages-page-used-function-byte-pages-page-used-bp-page-index-mlc-tools-ml-64526912) | `mlc/tools.ml:1892` | 9 | 11 | 7 | 6 | 1 | 382.74 | 60.16 |
| [`mlc.tools.byte_pages_set_byte`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-byte-pages-set-byte-function-byte-pages-set-byte-bp-idx-value-mlc-tools-ml-1066816434) | `mlc/tools.ml:2115` | 14 | 15 | 5 | 4 | 1 | 598.55 | 54.88 |
| [`mlc.tools.byte_pages_to_bytes`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-byte-pages-to-bytes-function-byte-pages-to-bytes-bp-mlc-tools-ml-1090167482) | `mlc/tools.ml:2087` | 22 | 21 | 7 | 8 | 2 | 738.75 | 49.69 |
| [`mlc.tools.byte_pages_write_at`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-byte-pages-write-at-function-byte-pages-write-at-bp-offset-src-mlc-tools-ml-949290513) | `mlc/tools.ml:2055` | 26 | 27 | 10 | 11 | 2 | 1127.96 | 46.42 |
| [`mlc.tools.enc_bool`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-enc-bool-function-enc-bool-b-mlc-tools-ml-1930511380) | `mlc/tools.ml:1077` | 6 | 3 | 2 | 1 | 1 | 133.44 | 67.88 |
| [`mlc.tools.enc_enum`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-enc-enum-function-enc-enum-enum-id-variant-id-mlc-tools-ml-1300503830) | `mlc/tools.ml:1093` | 4 | 2 | 1 | 0 | 0 | 155.59 | 71.38 |
| [`mlc.tools.enc_int`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-enc-int-function-enc-int-x-as-int-returns-int-mlc-tools-ml-202911073) | `mlc/tools.ml:1071` | 3 | 1 | 1 | 0 | 0 | 112.59 | 75.09 |
| [`mlc.tools.enc_void`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-enc-void-function-enc-void-returns-int-mlc-tools-ml-1182839604) | `mlc/tools.ml:1086` | 3 | 1 | 1 | 0 | 0 | 41.51 | 78.13 |
| [`mlc.tools.extern_library_label_token`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-extern-library-label-token-function-extern-library-label-token-library-mlc-tools-ml-919117945) | `mlc/tools.ml:26` | 11 | 9 | 3 | 2 | 1 | 361.21 | 58.97 |
| [`mlc.tools.fastmap_clear`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-fastmap-clear-function-fastmap-clear-mapv-mlc-tools-ml-1478478050) | `mlc/tools.ml:823` | 16 | 12 | 7 | 9 | 3 | 539.11 | 53.66 |
| [`mlc.tools.fastmap_get`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-fastmap-get-function-fastmap-get-mapv-key-defaultv-mlc-tools-ml-81050054) | `mlc/tools.ml:960` | 13 | 13 | 5 | 6 | 2 | 516.99 | 56.03 |
| [`mlc.tools.fastmap_has`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-fastmap-has-function-fastmap-has-mapv-key-mlc-tools-ml-1099750807) | `mlc/tools.ml:977` | 13 | 13 | 5 | 6 | 2 | 477.02 | 56.27 |
| [`mlc.tools.fastmap_items`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-fastmap-items-function-fastmap-items-mapv-mlc-tools-ml-1300381568) | `mlc/tools.ml:1001` | 10 | 7 | 4 | 4 | 2 | 408.6 | 59.36 |
| [`mlc.tools.fastmap_new`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-fastmap-new-function-fastmap-new-initial-cap-mlc-tools-ml-1434987787) | `mlc/tools.ml:794` | 4 | 2 | 1 | 0 | 0 | 183.94 | 70.87 |
| [`mlc.tools.fastmap_release_refs`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-fastmap-release-refs-function-fastmap-release-refs-mapv-mlc-tools-ml-849986326) | `mlc/tools.ml:844` | 31 | 23 | 10 | 18 | 4 | 1089.26 | 44.86 |
| [`mlc.tools.fastmap_set`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-fastmap-set-function-fastmap-set-mapv-key-value-mlc-tools-ml-480505188) | `mlc/tools.ml:947` | 8 | 6 | 3 | 2 | 1 | 346.79 | 62.11 |
| [`mlc.tools.fastmap_size`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-fastmap-size-function-fastmap-size-mapv-mlc-tools-ml-1083147314) | `mlc/tools.ml:993` | 5 | 5 | 3 | 2 | 1 | 154.29 | 69.03 |
| [`mlc.tools.fastmap_track_refs`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-fastmap-track-refs-function-fastmap-track-refs-mapv-mlc-tools-ml-1619771010) | `mlc/tools.ml:804` | 13 | 10 | 6 | 11 | 4 | 510.53 | 55.93 |
| [`mlc.tools.try_enc_float_immediate`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-try-enc-float-immediate-function-try-enc-float-immediate-x-mlc-tools-ml-1655021100) | `mlc/tools.ml:1115` | 84 | 67 | 24 | 33 | 3 | 2590.01 | 30.9 |
| [`mlc.tools.u16`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-u16-function-u16-x-mlc-tools-ml-1877433222) | `mlc/tools.ml:1032` | 7 | 5 | 1 | 0 | 0 | 187.3 | 65.52 |
| [`mlc.tools.u32`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-u32-function-u32-x-mlc-tools-ml-1177186146) | `mlc/tools.ml:1042` | 9 | 7 | 1 | 0 | 0 | 310.23 | 61.6 |
| [`mlc.tools.u64`](File-mlc-tools-ml-988451276.md#function-function-mlc-tools-u64-function-u64-x-mlc-tools-ml-1374782380) | `mlc/tools.ml:1054` | 13 | 11 | 1 | 0 | 0 | 585.15 | 56.19 |
| [`run`](File-mlc-win64-ml-1630996773.md#function-function-run-function-run-args-mlc-win64-ml-1658120285) | `mlc_win64.ml:23` | 3 | 1 | 1 | 0 | 0 | 46.51 | 77.78 |

## Code duplication

A clone group is an exact sequence of 6 normalized, contiguous code lines found more than once. Comments and formatting whitespace are ignored. Duplicated-line totals count overlapping windows only once.

Found 1122 clone group(s). At most 200 groups are shown.

<details>
<summary>Clone 1 — 2 occurrences</summary>

    if typeof ( text ) != "string" then return false end if
    if typeof ( prefix ) != "string" then return false end if
    if len ( prefix ) <= 0 then return true end if
    if len ( text ) < len ( prefix ) then return false end if
    for i = 0 to len ( prefix ) - 1
    if text [ i ] != prefix [ i ] then return false end if

- [`mlc/asm.ml:119`](File-mlc-asm-ml-1368648960.md)
- [`mlc/codegen/codegen_core.ml:1710`](File-mlc-codegen-codegen-core-ml-528695596.md)

</details>

<details>
<summary>Clone 2 — 2 occurrences</summary>

    if typeof ( prefix ) != "string" then return false end if
    if len ( prefix ) <= 0 then return true end if
    if len ( text ) < len ( prefix ) then return false end if
    for i = 0 to len ( prefix ) - 1
    if text [ i ] != prefix [ i ] then return false end if
    end for

- [`mlc/asm.ml:120`](File-mlc-asm-ml-1368648960.md)
- [`mlc/codegen/codegen_core.ml:1711`](File-mlc-codegen-codegen-core-ml-528695596.md)

</details>

<details>
<summary>Clone 3 — 2 occurrences</summary>

    if len ( prefix ) <= 0 then return true end if
    if len ( text ) < len ( prefix ) then return false end if
    for i = 0 to len ( prefix ) - 1
    if text [ i ] != prefix [ i ] then return false end if
    end for
    return true

- [`mlc/asm.ml:121`](File-mlc-asm-ml-1368648960.md)
- [`mlc/codegen/codegen_core.ml:1712`](File-mlc-codegen-codegen-core-ml-528695596.md)

</details>

<details>
<summary>Clone 4 — 2 occurrences</summary>

    if len ( text ) < len ( prefix ) then return false end if
    for i = 0 to len ( prefix ) - 1
    if text [ i ] != prefix [ i ] then return false end if
    end for
    return true
    end function

- [`mlc/asm.ml:122`](File-mlc-asm-ml-1368648960.md)
- [`mlc/codegen/codegen_core.ml:1713`](File-mlc-codegen-codegen-core-ml-528695596.md)

</details>

<details>
<summary>Clone 5 — 2 occurrences</summary>

    target = - 1
    if typeof ( asm . label_pos_map ) == "struct" then
    target = t . fastmap_get ( asm . label_pos_map , label , - 1 )
    if typeof ( target ) != "int" then target = - 1 end if
    end if
    if target >= 0 then

- [`mlc/asm.ml:1225`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:1284`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 6 — 2 occurrences</summary>

    if typeof ( asm . label_pos_map ) == "struct" then
    target = t . fastmap_get ( asm . label_pos_map , label , - 1 )
    if typeof ( target ) != "int" then target = - 1 end if
    end if
    if target >= 0 then
    disp8 = target - ( pos ( asm ) + 2 )

- [`mlc/asm.ml:1226`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:1285`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 7 — 2 occurrences</summary>

    target = t . fastmap_get ( asm . label_pos_map , label , - 1 )
    if typeof ( target ) != "int" then target = - 1 end if
    end if
    if target >= 0 then
    disp8 = target - ( pos ( asm ) + 2 )
    if disp8 >= - 128 and disp8 <= 127 then

- [`mlc/asm.ml:1227`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:1286`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 8 — 2 occurrences</summary>

    p = pos ( asm )
    asm = _emit32 ( asm , 0 )
    asm = _patch_push ( asm , AsmPatch ( p , label , "rel32" ) )
    asm . peephole_last_jump = [ start , pos ( asm ) , label , p ]
    return asm
    end function

- [`mlc/asm.ml:1241`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:1301`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 9 — 6 occurrences</summary>

    if typeof ( arr ) != "array" or len ( arr ) <= 0 then return false end if
    for i = 0 to len ( arr ) - 1
    if arr [ i ] == value then return true end if
    end for
    return false
    end function

- [`mlc/asm.ml:132`](File-mlc-asm-ml-1368648960.md)
- [`mlc/codegen/codegen.ml:42`](File-mlc-codegen-codegen-ml-1154886880.md)
- [`mlc/codegen/codegen_core.ml:1723`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_expr.ml:817`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_scope.ml:283`](File-mlc-codegen-codegen-scope-ml-1124416197.md)
- [`mlc/codegen/codegen_stmt.ml:4981`](File-mlc-codegen-codegen-stmt-ml-1158291323.md)

</details>

<details>
<summary>Clone 10 — 3 occurrences</summary>

    asm = _emit8 ( asm , 0x15 )
    p = pos ( asm )
    asm = _emit32 ( asm , 0 )
    asm = _patch_push ( asm , AsmPatch ( p , label , "rip32" ) )
    return asm
    end function

- [`mlc/asm.ml:1403`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2854`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2896`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 11 — 3 occurrences</summary>

    d = _rid_any ( dst )
    b = _rid_any ( base )
    if d < 0 or b < 0 then return asm end if
    enc = _encode_mem ( d & 7 , b , disp )
    rex_r = 0
    if d >= 8 then rex_r = 1 end if

- [`mlc/asm.ml:2270`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2306`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2459`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 12 — 2 occurrences</summary>

    b = _rid_any ( base )
    if d < 0 or b < 0 then return asm end if
    enc = _encode_mem ( d & 7 , b , disp )
    rex_r = 0
    if d >= 8 then rex_r = 1 end if
    asm = _emit_rex ( asm , 1 , rex_r , enc . rex_x , enc . rex_b , false )

- [`mlc/asm.ml:2271`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2460`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 13 — 2 occurrences</summary>

    rex_r = 0
    if d >= 8 then rex_r = 1 end if
    asm = _emit_rex ( asm , 1 , rex_r , enc . rex_x , enc . rex_b , false )
    asm = _emit8 ( asm , 0x8B )
    asm = _emit ( asm , enc . tail )
    return asm

- [`mlc/asm.ml:2274`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2979`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 14 — 2 occurrences</summary>

    if d >= 8 then rex_r = 1 end if
    asm = _emit_rex ( asm , 1 , rex_r , enc . rex_x , enc . rex_b , false )
    asm = _emit8 ( asm , 0x8B )
    asm = _emit ( asm , enc . tail )
    return asm
    end function

- [`mlc/asm.ml:2275`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2980`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 15 — 4 occurrences</summary>

    sreg = _rid_any ( src )
    b = _rid_any ( base )
    if sreg < 0 or b < 0 then return asm end if
    enc = _encode_mem ( sreg & 7 , b , disp )
    rex_r = 0
    if sreg >= 8 then rex_r = 1 end if

- [`mlc/asm.ml:2288`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2324`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2342`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2364`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 16 — 2 occurrences</summary>

    rex_r = 0
    if sreg >= 8 then rex_r = 1 end if
    asm = _emit_rex ( asm , 1 , rex_r , enc . rex_x , enc . rex_b , false )
    asm = _emit8 ( asm , 0x89 )
    asm = _emit ( asm , enc . tail )
    return asm

- [`mlc/asm.ml:2292`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:3000`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 17 — 2 occurrences</summary>

    if sreg >= 8 then rex_r = 1 end if
    asm = _emit_rex ( asm , 1 , rex_r , enc . rex_x , enc . rex_b , false )
    asm = _emit8 ( asm , 0x89 )
    asm = _emit ( asm , enc . tail )
    return asm
    end function

- [`mlc/asm.ml:2293`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:3001`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 18 — 2 occurrences</summary>

    b = _rid_any ( base )
    if d < 0 or b < 0 then return asm end if
    enc = _encode_mem ( d & 7 , b , disp )
    rex_r = 0
    if d >= 8 then rex_r = 1 end if
    asm = _emit_rex ( asm , 0 , rex_r , enc . rex_x , enc . rex_b , false )

- [`mlc/asm.ml:2307`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2609`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 19 — 2 occurrences</summary>

    rex_r = 0
    if d >= 8 then rex_r = 1 end if
    asm = _emit_rex ( asm , 0 , rex_r , enc . rex_x , enc . rex_b , false )
    asm = _emit8 ( asm , 0x8B )
    asm = _emit ( asm , enc . tail )
    return asm

- [`mlc/asm.ml:2310`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:3021`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 20 — 2 occurrences</summary>

    if d >= 8 then rex_r = 1 end if
    asm = _emit_rex ( asm , 0 , rex_r , enc . rex_x , enc . rex_b , false )
    asm = _emit8 ( asm , 0x8B )
    asm = _emit ( asm , enc . tail )
    return asm
    end function

- [`mlc/asm.ml:2311`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:3022`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 21 — 2 occurrences</summary>

    rex_r = 0
    if sreg >= 8 then rex_r = 1 end if
    asm = _emit_rex ( asm , 0 , rex_r , enc . rex_x , enc . rex_b , false )
    asm = _emit8 ( asm , 0x89 )
    asm = _emit ( asm , enc . tail )
    return asm

- [`mlc/asm.ml:2328`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:3042`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 22 — 2 occurrences</summary>

    if sreg >= 8 then rex_r = 1 end if
    asm = _emit_rex ( asm , 0 , rex_r , enc . rex_x , enc . rex_b , false )
    asm = _emit8 ( asm , 0x89 )
    asm = _emit ( asm , enc . tail )
    return asm
    end function

- [`mlc/asm.ml:2329`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:3043`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 23 — 2 occurrences</summary>

    b = _rid_any ( base )
    if sreg < 0 or b < 0 then return asm end if
    enc = _encode_mem ( sreg & 7 , b , disp )
    rex_r = 0
    if sreg >= 8 then rex_r = 1 end if
    asm = _emit8 ( asm , 0xF0 )

- [`mlc/asm.ml:2343`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2365`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 24 — 2 occurrences</summary>

    rex_r = 0
    if d >= 8 then rex_r = 1 end if
    asm = _emit_rex ( asm , 1 , rex_r , enc . rex_x , enc . rex_b , false )
    asm = _emit8 ( asm , 0x8D )
    asm = _emit ( asm , enc . tail )
    return asm

- [`mlc/asm.ml:2463`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:3063`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 25 — 2 occurrences</summary>

    if d >= 8 then rex_r = 1 end if
    asm = _emit_rex ( asm , 1 , rex_r , enc . rex_x , enc . rex_b , false )
    asm = _emit8 ( asm , 0x8D )
    asm = _emit ( asm , enc . tail )
    return asm
    end function

- [`mlc/asm.ml:2464`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:3064`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 26 — 2 occurrences</summary>

    d = _rid_any ( dst32 )
    s = _rid_any ( src32 )
    rex_r = 0
    if d >= 8 then rex_r = 1 end if
    rex_b = 0
    if s >= 8 then rex_b = 1 end if

- [`mlc/asm.ml:2627`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2646`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 27 — 2 occurrences</summary>

    s = _rid_any ( src32 )
    rex_r = 0
    if d >= 8 then rex_r = 1 end if
    rex_b = 0
    if s >= 8 then rex_b = 1 end if
    asm = _emit_rex ( asm , 0 , rex_r , 0 , rex_b , false )

- [`mlc/asm.ml:2628`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2647`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 28 — 2 occurrences</summary>

    rex_r = 0
    if d >= 8 then rex_r = 1 end if
    rex_b = 0
    if s >= 8 then rex_b = 1 end if
    asm = _emit_rex ( asm , 0 , rex_r , 0 , rex_b , false )
    asm = _emit8 ( asm , 0x0F )

- [`mlc/asm.ml:2629`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2648`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 29 — 2 occurrences</summary>

    b = _rid_any ( base )
    if d < 0 or b < 0 then return asm end if
    enc = _encode_mem ( d & 7 , b , disp )
    asm = _emit8 ( asm , 0xF2 )
    asm = _emit_rex ( asm , 0 , ( d >> 3 ) & 1 , enc . rex_x , enc . rex_b , false )
    asm = _emit8 ( asm , 0x0F )

- [`mlc/asm.ml:2686`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:3324`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 30 — 2 occurrences</summary>

    asm = _emit8 ( asm , 0x8B )
    asm = _emit8 ( asm , 0x05 )
    p = pos ( asm )
    asm = _emit32 ( asm , 0 )
    asm = _patch_push ( asm , AsmPatch ( p , label , "rip32" ) )
    return asm

- [`mlc/asm.ml:2799`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2832`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 31 — 5 occurrences</summary>

    asm = _emit8 ( asm , 0x05 )
    p = pos ( asm )
    asm = _emit32 ( asm , 0 )
    asm = _patch_push ( asm , AsmPatch ( p , label , "rip32" ) )
    return asm
    end function

- [`mlc/asm.ml:2800`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2812`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2833`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2875`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2938`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 32 — 3 occurrences</summary>

    asm = _emit8 ( asm , 0x89 )
    asm = _emit8 ( asm , 0x05 )
    p = pos ( asm )
    asm = _emit32 ( asm , 0 )
    asm = _patch_push ( asm , AsmPatch ( p , label , "rip32" ) )
    return asm

- [`mlc/asm.ml:2811`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2874`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:2937`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 33 — 2 occurrences</summary>

    asm = r [ 0 ]
    asm . deferred_patches_chunks = r [ 1 ]
    asm . deferred_patches_tail = r [ 2 ]
    asm . patches_chunks = [ ]
    asm . patches_tail = [ ]
    asm . buf_valid = false

- [`mlc/asm.ml:283`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:300`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 34 — 2 occurrences</summary>

    asm . deferred_patches_chunks = r [ 1 ]
    asm . deferred_patches_tail = r [ 2 ]
    asm . patches_chunks = [ ]
    asm . patches_tail = [ ]
    asm . buf_valid = false
    return asm

- [`mlc/asm.ml:284`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:301`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 35 — 2 occurrences</summary>

    asm . deferred_patches_tail = r [ 2 ]
    asm . patches_chunks = [ ]
    asm . patches_tail = [ ]
    asm . buf_valid = false
    return asm
    end function

- [`mlc/asm.ml:285`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:302`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 36 — 3 occurrences</summary>

    d = _rid_any ( dst )
    b = _rid_any ( base )
    idx = _rid_any ( index_reg )
    if d < 0 or b < 0 or idx < 0 then return asm end if
    enc = _encode_mem_bis ( d & 7 , b , idx , scale , disp )
    rex_r = 0

- [`mlc/asm.ml:2974`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:3016`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:3058`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 37 — 3 occurrences</summary>

    b = _rid_any ( base )
    idx = _rid_any ( index_reg )
    if d < 0 or b < 0 or idx < 0 then return asm end if
    enc = _encode_mem_bis ( d & 7 , b , idx , scale , disp )
    rex_r = 0
    if d >= 8 then rex_r = 1 end if

- [`mlc/asm.ml:2975`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:3017`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:3059`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 38 — 2 occurrences</summary>

    idx = _rid_any ( index_reg )
    if d < 0 or b < 0 or idx < 0 then return asm end if
    enc = _encode_mem_bis ( d & 7 , b , idx , scale , disp )
    rex_r = 0
    if d >= 8 then rex_r = 1 end if
    asm = _emit_rex ( asm , 1 , rex_r , enc . rex_x , enc . rex_b , false )

- [`mlc/asm.ml:2976`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:3060`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 39 — 2 occurrences</summary>

    sreg = _rid_any ( src )
    b = _rid_any ( base )
    idx = _rid_any ( index_reg )
    if sreg < 0 or b < 0 or idx < 0 then return asm end if
    enc = _encode_mem_bis ( sreg & 7 , b , idx , scale , disp )
    rex_r = 0

- [`mlc/asm.ml:2995`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:3037`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 40 — 2 occurrences</summary>

    b = _rid_any ( base )
    idx = _rid_any ( index_reg )
    if sreg < 0 or b < 0 or idx < 0 then return asm end if
    enc = _encode_mem_bis ( sreg & 7 , b , idx , scale , disp )
    rex_r = 0
    if sreg >= 8 then rex_r = 1 end if

- [`mlc/asm.ml:2996`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:3038`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 41 — 2 occurrences</summary>

    asm = _emit_rex ( asm , 0 , ( d >> 3 ) & 1 , 0 , ( s >> 3 ) & 1 , false )
    asm = _emit8 ( asm , 0x0F )
    asm = _emit8 ( asm , 0x5A )
    asm = _emit_modrm ( asm , 3 , d & 7 , s & 7 )
    return asm
    end function

- [`mlc/asm.ml:3547`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:3563`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 42 — 2 occurrences</summary>

    mod = 0
    disp_bytes = bytes ( 0 )
    if disp == 0 and base_lo != 5 then
    mod = 0
    else
    if _fits_i8 ( disp ) then

- [`mlc/asm.ml:928`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:982`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 43 — 2 occurrences</summary>

    disp_bytes = bytes ( 0 )
    if disp == 0 and base_lo != 5 then
    mod = 0
    else
    if _fits_i8 ( disp ) then
    mod = 1

- [`mlc/asm.ml:929`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:983`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 44 — 2 occurrences</summary>

    if disp == 0 and base_lo != 5 then
    mod = 0
    else
    if _fits_i8 ( disp ) then
    mod = 1
    disp_bytes = _emit_bytes_u8 ( disp )

- [`mlc/asm.ml:930`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:984`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 45 — 2 occurrences</summary>

    mod = 0
    else
    if _fits_i8 ( disp ) then
    mod = 1
    disp_bytes = _emit_bytes_u8 ( disp )
    else

- [`mlc/asm.ml:931`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:985`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 46 — 2 occurrences</summary>

    else
    if _fits_i8 ( disp ) then
    mod = 1
    disp_bytes = _emit_bytes_u8 ( disp )
    else
    mod = 2

- [`mlc/asm.ml:932`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:986`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 47 — 2 occurrences</summary>

    if _fits_i8 ( disp ) then
    mod = 1
    disp_bytes = _emit_bytes_u8 ( disp )
    else
    mod = 2
    disp_bytes = t . u32 ( disp )

- [`mlc/asm.ml:933`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:987`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 48 — 2 occurrences</summary>

    mod = 1
    disp_bytes = _emit_bytes_u8 ( disp )
    else
    mod = 2
    disp_bytes = t . u32 ( disp )
    end if

- [`mlc/asm.ml:934`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:988`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 49 — 2 occurrences</summary>

    disp_bytes = _emit_bytes_u8 ( disp )
    else
    mod = 2
    disp_bytes = t . u32 ( disp )
    end if
    end if

- [`mlc/asm.ml:935`](File-mlc-asm-ml-1368648960.md)
- [`mlc/asm.ml:989`](File-mlc-asm-ml-1368648960.md)

</details>

<details>
<summary>Clone 50 — 2 occurrences</summary>

    state . asm = a . lea_r64_membase_disp ( state . asm , "rcx" , "rdx" , 8 )
    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "r10" , 4 )
    state . asm = a . add_r64_r64 ( state . asm , "rcx" , "rax" )
    state . asm = a . lea_r64_membase_disp ( state . asm , "rdx" , "r11" , 8 )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r8d" , "r11" , 4 )
    state . asm = a . call ( state . asm , "fn_copy_bytes" )

- [`mlc/codegen/codegen_builtins_alloc.ml:1223`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1469`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 51 — 2 occurrences</summary>

    state . asm = a . mov_rax_imm64 ( state . asm , t . enc_void ( ) )
    state . asm = a . mov_rip_qword_rax ( state . asm , "gc_tmp2" )
    state . asm = a . mov_rip_qword_rax ( state . asm , "gc_tmp3" )
    state . asm = a . mov_rcx_imm32 ( state . asm , 48 )
    state . asm = a . call ( state . asm , "fn_alloc" )
    state . asm = a . mov_r64_r64 ( state . asm , "r11" , "rax" )

- [`mlc/codegen/codegen_builtins_alloc.ml:1248`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1271`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 52 — 2 occurrences</summary>

    state . asm = a . mov_rip_qword_rax ( state . asm , "gc_tmp2" )
    state . asm = a . mov_rip_qword_rax ( state . asm , "gc_tmp3" )
    state . asm = a . mov_rcx_imm32 ( state . asm , 48 )
    state . asm = a . call ( state . asm , "fn_alloc" )
    state . asm = a . mov_r64_r64 ( state . asm , "r11" , "rax" )
    state . asm = a . mov_membase_disp_imm32 ( state . asm , "r11" , 0 , c . OBJ_STRUCT , false )

- [`mlc/codegen/codegen_builtins_alloc.ml:1249`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1272`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 53 — 2 occurrences</summary>

    state . asm = a . mov_rip_qword_rax ( state . asm , "gc_tmp3" )
    state . asm = a . mov_rcx_imm32 ( state . asm , 48 )
    state . asm = a . call ( state . asm , "fn_alloc" )
    state . asm = a . mov_r64_r64 ( state . asm , "r11" , "rax" )
    state . asm = a . mov_membase_disp_imm32 ( state . asm , "r11" , 0 , c . OBJ_STRUCT , false )
    state . asm = a . mov_membase_disp_imm32 ( state . asm , "r11" , 4 , c . ERROR_STRUCT_ID , false )

- [`mlc/codegen/codegen_builtins_alloc.ml:1250`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1273`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 54 — 2 occurrences</summary>

    state . asm = a . mov_rcx_imm32 ( state . asm , 48 )
    state . asm = a . call ( state . asm , "fn_alloc" )
    state . asm = a . mov_r64_r64 ( state . asm , "r11" , "rax" )
    state . asm = a . mov_membase_disp_imm32 ( state . asm , "r11" , 0 , c . OBJ_STRUCT , false )
    state . asm = a . mov_membase_disp_imm32 ( state . asm , "r11" , 4 , c . ERROR_STRUCT_ID , false )
    state . asm = a . mov_rax_imm64 ( state . asm , t . enc_int ( c . ERR_STRINGIFY_UNSUPPORTED ) )

- [`mlc/codegen/codegen_builtins_alloc.ml:1251`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1274`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 55 — 2 occurrences</summary>

    state . asm = a . call ( state . asm , "fn_alloc" )
    state . asm = a . mov_r64_r64 ( state . asm , "r11" , "rax" )
    state . asm = a . mov_membase_disp_imm32 ( state . asm , "r11" , 0 , c . OBJ_STRUCT , false )
    state . asm = a . mov_membase_disp_imm32 ( state . asm , "r11" , 4 , c . ERROR_STRUCT_ID , false )
    state . asm = a . mov_rax_imm64 ( state . asm , t . enc_int ( c . ERR_STRINGIFY_UNSUPPORTED ) )
    state . asm = a . mov_membase_disp_r64 ( state . asm , "r11" , 8 , "rax" )

- [`mlc/codegen/codegen_builtins_alloc.ml:1252`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1275`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 56 — 2 occurrences</summary>

    state . asm = a . mov_membase_disp_r64 ( state . asm , "r11" , 16 , "rax" )
    state . asm = a . mov_rax_rip_qword ( state . asm , "dbg_loc_script" )
    state . asm = a . mov_membase_disp_r64 ( state . asm , "r11" , 24 , "rax" )
    state . asm = a . mov_rax_rip_qword ( state . asm , "dbg_loc_func" )
    state . asm = a . mov_membase_disp_r64 ( state . asm , "r11" , 32 , "rax" )
    state . asm = a . mov_rax_rip_qword ( state . asm , "dbg_loc_line" )

- [`mlc/codegen/codegen_builtins_alloc.ml:1259`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1282`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 57 — 8 occurrences</summary>

    state . asm = a . mov_rax_rip_qword ( state . asm , "dbg_loc_script" )
    state . asm = a . mov_membase_disp_r64 ( state . asm , "r11" , 24 , "rax" )
    state . asm = a . mov_rax_rip_qword ( state . asm , "dbg_loc_func" )
    state . asm = a . mov_membase_disp_r64 ( state . asm , "r11" , 32 , "rax" )
    state . asm = a . mov_rax_rip_qword ( state . asm , "dbg_loc_line" )
    state . asm = a . mov_membase_disp_r64 ( state . asm , "r11" , 40 , "rax" )

- [`mlc/codegen/codegen_builtins_alloc.ml:1260`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1283`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_expr.ml:6059`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:7416`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:7858`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:7957`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:8004`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:8039`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 58 — 2 occurrences</summary>

    state . asm = a . mov_membase_disp_r64 ( state . asm , "r11" , 24 , "rax" )
    state . asm = a . mov_rax_rip_qword ( state . asm , "dbg_loc_func" )
    state . asm = a . mov_membase_disp_r64 ( state . asm , "r11" , 32 , "rax" )
    state . asm = a . mov_rax_rip_qword ( state . asm , "dbg_loc_line" )
    state . asm = a . mov_membase_disp_r64 ( state . asm , "r11" , 40 , "rax" )
    state . asm = a . mov_rax_r11 ( state . asm )

- [`mlc/codegen/codegen_builtins_alloc.ml:1261`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1284`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 59 — 2 occurrences</summary>

    state . asm = a . mov_rax_rip_qword ( state . asm , "dbg_loc_func" )
    state . asm = a . mov_membase_disp_r64 ( state . asm , "r11" , 32 , "rax" )
    state . asm = a . mov_rax_rip_qword ( state . asm , "dbg_loc_line" )
    state . asm = a . mov_membase_disp_r64 ( state . asm , "r11" , 40 , "rax" )
    state . asm = a . mov_rax_r11 ( state . asm )
    state . asm = a . add_rsp_imm8 ( state . asm , 0x38 )

- [`mlc/codegen/codegen_builtins_alloc.ml:1262`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1285`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 60 — 2 occurrences</summary>

    state . asm = a . mov_membase_disp_r64 ( state . asm , "r11" , 32 , "rax" )
    state . asm = a . mov_rax_rip_qword ( state . asm , "dbg_loc_line" )
    state . asm = a . mov_membase_disp_r64 ( state . asm , "r11" , 40 , "rax" )
    state . asm = a . mov_rax_r11 ( state . asm )
    state . asm = a . add_rsp_imm8 ( state . asm , 0x38 )
    state . asm = a . ret ( state . asm )

- [`mlc/codegen/codegen_builtins_alloc.ml:1263`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1286`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 61 — 3 occurrences</summary>

    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "rdx" )
    state . asm = a . mov_r64_r64 ( state . asm , "r10" , "rax" )
    state . asm = a . and_r64_imm ( state . asm , "r10" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "r10" , c . TAG_INT )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . sar_r64_imm8 ( state . asm , "rax" , 3 )

- [`mlc/codegen/codegen_builtins_alloc.ml:1582`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1687`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2097`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 62 — 2 occurrences</summary>

    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r8" )
    state . asm = a . mov_r64_r64 ( state . asm , "r10" , "rax" )
    state . asm = a . and_r64_imm ( state . asm , "r10" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "r10" , c . TAG_INT )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . sar_r64_imm8 ( state . asm , "rax" , 3 )

- [`mlc/codegen/codegen_builtins_alloc.ml:1590`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1707`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 63 — 4 occurrences</summary>

    state . asm = a . mov_r64_r64 ( state . asm , "r10" , "rax" )
    state . asm = a . and_r64_imm ( state . asm , "r10" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "r10" , c . TAG_INT )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . sar_r64_imm8 ( state . asm , "rax" , 3 )
    state . asm = a . cmp_r64_imm ( state . asm , "rax" , 0 )

- [`mlc/codegen/codegen_builtins_alloc.ml:1591`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1688`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1708`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2098`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 64 — 5 occurrences</summary>

    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "rcx" )
    state . asm = a . mov_r64_r64 ( state . asm , "r10" , "rax" )
    state . asm = a . and_r64_imm ( state . asm , "r10" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "r10" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r11d" , "rax" , 0 )

- [`mlc/codegen/codegen_builtins_alloc.ml:1674`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2080`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2493`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2582`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2689`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 65 — 5 occurrences</summary>

    state . asm = a . mov_r64_r64 ( state . asm , "r10" , "rax" )
    state . asm = a . and_r64_imm ( state . asm , "r10" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "r10" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r11d" , "rax" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "r11d" , c . OBJ_STRING )

- [`mlc/codegen/codegen_builtins_alloc.ml:1675`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2081`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2494`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2583`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2690`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 66 — 5 occurrences</summary>

    state . asm = a . and_r64_imm ( state . asm , "r10" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "r10" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r11d" , "rax" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "r11d" , c . OBJ_STRING )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )

- [`mlc/codegen/codegen_builtins_alloc.ml:1676`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2082`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2495`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2584`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2691`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 67 — 2 occurrences</summary>

    state . asm = a . mark ( state . asm , l_done )
    state . asm = a . mov_r11_rax ( state . asm )
    state . asm = a . mov_rax_imm64 ( state . asm , t . enc_void ( ) )
    state . asm = a . mov_rip_qword_rax ( state . asm , "gc_tmp2" )
    state . asm = a . mov_rax_r11 ( state . asm )
    state . asm = a . add_rsp_imm8 ( state . asm , 0x48 )

- [`mlc/codegen/codegen_builtins_alloc.ml:1769`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2166`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 68 — 2 occurrences</summary>

    state . asm = a . mov_r11_rax ( state . asm )
    state . asm = a . mov_rax_imm64 ( state . asm , t . enc_void ( ) )
    state . asm = a . mov_rip_qword_rax ( state . asm , "gc_tmp2" )
    state . asm = a . mov_rax_r11 ( state . asm )
    state . asm = a . add_rsp_imm8 ( state . asm , 0x48 )
    state . asm = a . ret ( state . asm )

- [`mlc/codegen/codegen_builtins_alloc.ml:1770`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2167`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 69 — 7 occurrences</summary>

    state . asm = a . mov_r64_r64 ( state . asm , "r11" , "rcx" )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r11" )
    state . asm = a . and_r64_imm ( state . asm , "rax" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "rax" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "r11" , 0 )

- [`mlc/codegen/codegen_builtins_alloc.ml:1801`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1892`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2190`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2266`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2343`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_runtime.ml:1515`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)
- [`mlc/codegen/codegen_runtime.ml:1606`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)

</details>

<details>
<summary>Clone 70 — 5 occurrences</summary>

    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r11" )
    state . asm = a . and_r64_imm ( state . asm , "rax" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "rax" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "r11" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "eax" , c . OBJ_STRING )

- [`mlc/codegen/codegen_builtins_alloc.ml:1802`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1893`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2191`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2267`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2344`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 71 — 5 occurrences</summary>

    state . asm = a . and_r64_imm ( state . asm , "rax" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "rax" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "r11" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "eax" , c . OBJ_STRING )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )

- [`mlc/codegen/codegen_builtins_alloc.ml:1803`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1894`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2192`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2268`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2345`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 72 — 5 occurrences</summary>

    state . asm = a . cmp_r64_imm ( state . asm , "rax" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "r11" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "eax" , c . OBJ_STRING )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r9d" , "r11" , 4 )

- [`mlc/codegen/codegen_builtins_alloc.ml:1804`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1895`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2193`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2269`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2346`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 73 — 4 occurrences</summary>

    state . asm = a . mov_r64_r64 ( state . asm , "r10" , "rdx" )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r10" )
    state . asm = a . and_r64_imm ( state . asm , "rax" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "rax" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "r10" , 0 )

- [`mlc/codegen/codegen_builtins_alloc.ml:1811`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1902`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_runtime.ml:1525`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)
- [`mlc/codegen/codegen_runtime.ml:1616`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)

</details>

<details>
<summary>Clone 74 — 2 occurrences</summary>

    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r10" )
    state . asm = a . and_r64_imm ( state . asm , "rax" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "rax" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "r10" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "eax" , c . OBJ_STRING )

- [`mlc/codegen/codegen_builtins_alloc.ml:1812`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1903`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 75 — 2 occurrences</summary>

    state . asm = a . and_r64_imm ( state . asm , "rax" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "rax" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "r10" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "eax" , c . OBJ_STRING )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )

- [`mlc/codegen/codegen_builtins_alloc.ml:1813`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:1904`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 76 — 5 occurrences</summary>

    state . asm = a . mov_r64_r64 ( state . asm , "r8" , "rcx" )
    state . asm = a . mov_r64_r64 ( state . asm , "r9" , "rdx" )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r8" )
    state . asm = a . and_r64_imm ( state . asm , "rax" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "rax" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_false )

- [`mlc/codegen/codegen_builtins_alloc.ml:1960`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2017`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2794`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_runtime.ml:1396`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)
- [`mlc/codegen/codegen_runtime.ml:1452`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)

</details>

<details>
<summary>Clone 77 — 5 occurrences</summary>

    state . asm = a . mov_r64_r64 ( state . asm , "r9" , "rdx" )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r8" )
    state . asm = a . and_r64_imm ( state . asm , "rax" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "rax" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_false )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r9" )

- [`mlc/codegen/codegen_builtins_alloc.ml:1961`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2018`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2795`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_runtime.ml:1397`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)
- [`mlc/codegen/codegen_runtime.ml:1453`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)

</details>

<details>
<summary>Clone 78 — 5 occurrences</summary>

    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r8" )
    state . asm = a . and_r64_imm ( state . asm , "rax" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "rax" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_false )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r9" )
    state . asm = a . and_r64_imm ( state . asm , "rax" , 7 )

- [`mlc/codegen/codegen_builtins_alloc.ml:1962`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2019`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2796`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_runtime.ml:1398`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)
- [`mlc/codegen/codegen_runtime.ml:1454`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)

</details>

<details>
<summary>Clone 79 — 5 occurrences</summary>

    state . asm = a . and_r64_imm ( state . asm , "rax" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "rax" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_false )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r9" )
    state . asm = a . and_r64_imm ( state . asm , "rax" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "rax" , c . TAG_PTR )

- [`mlc/codegen/codegen_builtins_alloc.ml:1963`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2020`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2797`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_runtime.ml:1399`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)
- [`mlc/codegen/codegen_runtime.ml:1455`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)

</details>

<details>
<summary>Clone 80 — 5 occurrences</summary>

    state . asm = a . cmp_r64_imm ( state . asm , "rax" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_false )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r9" )
    state . asm = a . and_r64_imm ( state . asm , "rax" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "rax" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_false )

- [`mlc/codegen/codegen_builtins_alloc.ml:1964`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2021`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2798`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_runtime.ml:1400`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)
- [`mlc/codegen/codegen_runtime.ml:1456`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)

</details>

<details>
<summary>Clone 81 — 5 occurrences</summary>

    state . asm = a . jcc ( state . asm , "ne" , l_false )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r9" )
    state . asm = a . and_r64_imm ( state . asm , "rax" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "rax" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_false )
    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "r8" , 0 )

- [`mlc/codegen/codegen_builtins_alloc.ml:1965`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2022`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2799`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_runtime.ml:1401`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)
- [`mlc/codegen/codegen_runtime.ml:1457`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)

</details>

<details>
<summary>Clone 82 — 3 occurrences</summary>

    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r9" )
    state . asm = a . and_r64_imm ( state . asm , "rax" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "rax" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_false )
    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "r8" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "eax" , c . OBJ_STRING )

- [`mlc/codegen/codegen_builtins_alloc.ml:1966`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2023`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2800`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 83 — 4 occurrences</summary>

    state . asm = a . and_r64_imm ( state . asm , "rax" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "rax" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_false )
    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "r8" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "eax" , c . OBJ_STRING )
    state . asm = a . jcc ( state . asm , "ne" , l_false )

- [`mlc/codegen/codegen_builtins_alloc.ml:1967`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2024`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2445`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2801`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 84 — 3 occurrences</summary>

    state . asm = a . cmp_r64_imm ( state . asm , "rax" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_false )
    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "r8" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "eax" , c . OBJ_STRING )
    state . asm = a . jcc ( state . asm , "ne" , l_false )
    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "r9" , 0 )

- [`mlc/codegen/codegen_builtins_alloc.ml:1968`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2025`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2802`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 85 — 3 occurrences</summary>

    state . asm = a . jcc ( state . asm , "ne" , l_false )
    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "r8" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "eax" , c . OBJ_STRING )
    state . asm = a . jcc ( state . asm , "ne" , l_false )
    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "r9" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "eax" , c . OBJ_STRING )

- [`mlc/codegen/codegen_builtins_alloc.ml:1969`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2026`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2803`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 86 — 3 occurrences</summary>

    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "r8" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "eax" , c . OBJ_STRING )
    state . asm = a . jcc ( state . asm , "ne" , l_false )
    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "r9" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "eax" , c . OBJ_STRING )
    state . asm = a . jcc ( state . asm , "ne" , l_false )

- [`mlc/codegen/codegen_builtins_alloc.ml:1970`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2027`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2804`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 87 — 4 occurrences</summary>

    state . asm = a . mov_r32_membase_disp ( state . asm , "r10d" , "r8" , 4 )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r11d" , "r9" , 4 )
    state . asm = a . test_r32_r32 ( state . asm , "r11d" , "r11d" )
    state . asm = a . jcc ( state . asm , "e" , l_true )
    state . asm = a . cmp_r32_r32 ( state . asm , "r11d" , "r10d" )
    state . asm = a . jcc ( state . asm , "g" , l_false )

- [`mlc/codegen/codegen_builtins_alloc.ml:1980`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2037`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_runtime.ml:1415`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)
- [`mlc/codegen/codegen_runtime.ml:1471`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)

</details>

<details>
<summary>Clone 88 — 3 occurrences</summary>

    state . asm = a . mov_r32_membase_disp ( state . asm , "r11d" , "r9" , 4 )
    state . asm = a . test_r32_r32 ( state . asm , "r11d" , "r11d" )
    state . asm = a . jcc ( state . asm , "e" , l_true )
    state . asm = a . cmp_r32_r32 ( state . asm , "r11d" , "r10d" )
    state . asm = a . jcc ( state . asm , "g" , l_false )
    state . asm = a . lea_r64_membase_disp ( state . asm , "rcx" , "r8" , 8 )

- [`mlc/codegen/codegen_builtins_alloc.ml:1981`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2038`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_runtime.ml:1416`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)

</details>

<details>
<summary>Clone 89 — 3 occurrences</summary>

    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "r11" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "eax" , c . OBJ_STRING )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r9d" , "r11" , 4 )
    state . asm = a . test_r32_r32 ( state . asm , "r9d" , "r9d" )

- [`mlc/codegen/codegen_builtins_alloc.ml:2194`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2270`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2347`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 90 — 3 occurrences</summary>

    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "r11" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "eax" , c . OBJ_STRING )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r9d" , "r11" , 4 )
    state . asm = a . test_r32_r32 ( state . asm , "r9d" , "r9d" )
    state . asm = a . jcc ( state . asm , "e" , l_done + "_empty" )

- [`mlc/codegen/codegen_builtins_alloc.ml:2195`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2271`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2348`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 91 — 2 occurrences</summary>

    state . asm = a . cmp_r32_imm ( state . asm , "eax" , c . OBJ_STRING )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r9d" , "r11" , 4 )
    state . asm = a . test_r32_r32 ( state . asm , "r9d" , "r9d" )
    state . asm = a . jcc ( state . asm , "e" , l_done + "_empty" )
    state . asm = a . xor_r32_r32 ( state . asm , "r8d" , "r8d" )

- [`mlc/codegen/codegen_builtins_alloc.ml:2196`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2349`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 92 — 2 occurrences</summary>

    state . asm = a . cmp_r32_imm ( state . asm , "r9d" , 0 )
    state . asm = a . jcc ( state . asm , "ne" , l_nonempty )
    state . asm = a . lea_rax_rip ( state . asm , "obj_empty_string" )
    state . asm = a . add_rsp_imm8 ( state . asm , 0x28 )
    state . asm = a . ret ( state . asm )
    state . asm = a . mark ( state . asm , l_nonempty )

- [`mlc/codegen/codegen_builtins_alloc.ml:249`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:320`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 93 — 3 occurrences</summary>

    state . asm = a . cmp_r64_imm ( state . asm , "r10" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r11d" , "rax" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "r11d" , c . OBJ_STRING )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r9d" , "rax" , 4 )

- [`mlc/codegen/codegen_builtins_alloc.ml:2496`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2585`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2692`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 94 — 3 occurrences</summary>

    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r11d" , "rax" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "r11d" , c . OBJ_STRING )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r9d" , "rax" , 4 )
    state . asm = a . test_r32_r32 ( state . asm , "r9d" , "r9d" )

- [`mlc/codegen/codegen_builtins_alloc.ml:2497`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2586`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2693`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 95 — 3 occurrences</summary>

    state . asm = a . mov_r32_membase_disp ( state . asm , "r11d" , "rax" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "r11d" , c . OBJ_STRING )
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r9d" , "rax" , 4 )
    state . asm = a . test_r32_r32 ( state . asm , "r9d" , "r9d" )
    state . asm = a . jcc ( state . asm , "e" , l_done + "_empty" )

- [`mlc/codegen/codegen_builtins_alloc.ml:2498`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2587`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2694`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 96 — 3 occurrences</summary>

    state . asm = a . mov_rip_qword_rax ( state . asm , "gc_tmp2" )
    state . asm = a . mov_membase_disp_r64 ( state . asm , "rsp" , 0x20 , "rax" )
    state . asm = a . mov_membase_disp_r32 ( state . asm , "rsp" , 0x28 , "r9d" )
    state . asm = a . mov_r32_r32 ( state . asm , "ecx" , "r9d" )
    state . asm = a . add_r32_imm ( state . asm , "ecx" , 9 )
    state . asm = a . call ( state . asm , "fn_alloc" )

- [`mlc/codegen/codegen_builtins_alloc.ml:2507`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2609`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2716`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 97 — 3 occurrences</summary>

    state . asm = a . mark ( state . asm , l_loop + "_done" )
    state . asm = a . mov_r64_membase_disp ( state . asm , "r11" , "rsp" , 0x30 )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r10d" , "rsp" , 0x28 )
    state . asm = a . lea_r64_membase_disp ( state . asm , "rax" , "r11" , 8 )
    state . asm = a . add_r64_r64 ( state . asm , "rax" , "r10" )
    state . asm = a . mov_membase_disp_imm8 ( state . asm , "rax" , 0 , 0 )

- [`mlc/codegen/codegen_builtins_alloc.ml:2537`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2644`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2751`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 98 — 3 occurrences</summary>

    state . asm = a . mov_r64_membase_disp ( state . asm , "r11" , "rsp" , 0x30 )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r10d" , "rsp" , 0x28 )
    state . asm = a . lea_r64_membase_disp ( state . asm , "rax" , "r11" , 8 )
    state . asm = a . add_r64_r64 ( state . asm , "rax" , "r10" )
    state . asm = a . mov_membase_disp_imm8 ( state . asm , "rax" , 0 , 0 )
    state . asm = a . mov_rax_r11 ( state . asm )

- [`mlc/codegen/codegen_builtins_alloc.ml:2538`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2645`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2752`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 99 — 3 occurrences</summary>

    state . asm = a . mov_r32_membase_disp ( state . asm , "r10d" , "rsp" , 0x28 )
    state . asm = a . lea_r64_membase_disp ( state . asm , "rax" , "r11" , 8 )
    state . asm = a . add_r64_r64 ( state . asm , "rax" , "r10" )
    state . asm = a . mov_membase_disp_imm8 ( state . asm , "rax" , 0 , 0 )
    state . asm = a . mov_rax_r11 ( state . asm )
    state . asm = a . jmp ( state . asm , l_done )

- [`mlc/codegen/codegen_builtins_alloc.ml:2539`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2646`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2753`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 100 — 3 occurrences</summary>

    state . asm = a . mark ( state . asm , l_done )
    state . asm = a . mov_r11_rax ( state . asm )
    state . asm = a . mov_rax_imm64 ( state . asm , t . enc_void ( ) )
    state . asm = a . mov_rip_qword_rax ( state . asm , "gc_tmp2" )
    state . asm = a . mov_rax_r11 ( state . asm )
    state . asm = a . add_rsp_imm8 ( state . asm , 0x38 )

- [`mlc/codegen/codegen_builtins_alloc.ml:2557`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2664`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2771`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 101 — 3 occurrences</summary>

    state . asm = a . mov_r11_rax ( state . asm )
    state . asm = a . mov_rax_imm64 ( state . asm , t . enc_void ( ) )
    state . asm = a . mov_rip_qword_rax ( state . asm , "gc_tmp2" )
    state . asm = a . mov_rax_r11 ( state . asm )
    state . asm = a . add_rsp_imm8 ( state . asm , 0x38 )
    state . asm = a . ret ( state . asm )

- [`mlc/codegen/codegen_builtins_alloc.ml:2558`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2665`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2772`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 102 — 3 occurrences</summary>

    state . asm = a . mov_rax_imm64 ( state . asm , t . enc_void ( ) )
    state . asm = a . mov_rip_qword_rax ( state . asm , "gc_tmp2" )
    state . asm = a . mov_rax_r11 ( state . asm )
    state . asm = a . add_rsp_imm8 ( state . asm , 0x38 )
    state . asm = a . ret ( state . asm )
    return state

- [`mlc/codegen/codegen_builtins_alloc.ml:2559`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2666`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2773`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 103 — 3 occurrences</summary>

    state . asm = a . mov_rip_qword_rax ( state . asm , "gc_tmp2" )
    state . asm = a . mov_rax_r11 ( state . asm )
    state . asm = a . add_rsp_imm8 ( state . asm , 0x38 )
    state . asm = a . ret ( state . asm )
    return state
    end function

- [`mlc/codegen/codegen_builtins_alloc.ml:2560`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2667`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2774`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 104 — 2 occurrences</summary>

    state . asm = a . xor_r32_r32 ( state . asm , "r8d" , "r8d" )
    state . asm = a . mark ( state . asm , l_scan )
    state . asm = a . cmp_r32_r32 ( state . asm , "r8d" , "r9d" )
    state . asm = a . jcc ( state . asm , "ge" , l_done + "_same" )
    state . asm = a . lea_r64_mem_bis ( state . asm , "r10" , "rax" , "r8" , 1 , 8 )
    state . asm = a . movzx_r32_membase_disp ( state . asm , "edx" , "r10" , 0 )

- [`mlc/codegen/codegen_builtins_alloc.ml:2594`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2701`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 105 — 2 occurrences</summary>

    state . asm = a . mark ( state . asm , l_has_change )
    state . asm = a . mov_rip_qword_rax ( state . asm , "gc_tmp2" )
    state . asm = a . mov_membase_disp_r64 ( state . asm , "rsp" , 0x20 , "rax" )
    state . asm = a . mov_membase_disp_r32 ( state . asm , "rsp" , 0x28 , "r9d" )
    state . asm = a . mov_r32_r32 ( state . asm , "ecx" , "r9d" )
    state . asm = a . add_r32_imm ( state . asm , "ecx" , 9 )

- [`mlc/codegen/codegen_builtins_alloc.ml:2608`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2715`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 106 — 2 occurrences</summary>

    state . asm = a . mov_membase_disp_r64 ( state . asm , "rsp" , 0x20 , "rax" )
    state . asm = a . mov_membase_disp_r32 ( state . asm , "rsp" , 0x28 , "r9d" )
    state . asm = a . mov_r32_r32 ( state . asm , "ecx" , "r9d" )
    state . asm = a . add_r32_imm ( state . asm , "ecx" , 9 )
    state . asm = a . call ( state . asm , "fn_alloc" )
    state . asm = a . mov_r11_rax ( state . asm )

- [`mlc/codegen/codegen_builtins_alloc.ml:2610`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2717`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 107 — 2 occurrences</summary>

    state . asm = a . mov_membase_disp_r32 ( state . asm , "rsp" , 0x28 , "r9d" )
    state . asm = a . mov_r32_r32 ( state . asm , "ecx" , "r9d" )
    state . asm = a . add_r32_imm ( state . asm , "ecx" , 9 )
    state . asm = a . call ( state . asm , "fn_alloc" )
    state . asm = a . mov_r11_rax ( state . asm )
    state . asm = a . mov_membase_disp_imm32 ( state . asm , "r11" , 0 , c . OBJ_STRING , false )

- [`mlc/codegen/codegen_builtins_alloc.ml:2611`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2718`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 108 — 2 occurrences</summary>

    state . asm = a . mov_r32_r32 ( state . asm , "ecx" , "r9d" )
    state . asm = a . add_r32_imm ( state . asm , "ecx" , 9 )
    state . asm = a . call ( state . asm , "fn_alloc" )
    state . asm = a . mov_r11_rax ( state . asm )
    state . asm = a . mov_membase_disp_imm32 ( state . asm , "r11" , 0 , c . OBJ_STRING , false )
    state . asm = a . mov_r32_membase_disp ( state . asm , "edx" , "rsp" , 0x28 )

- [`mlc/codegen/codegen_builtins_alloc.ml:2612`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2719`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 109 — 2 occurrences</summary>

    state . asm = a . add_r32_imm ( state . asm , "ecx" , 9 )
    state . asm = a . call ( state . asm , "fn_alloc" )
    state . asm = a . mov_r11_rax ( state . asm )
    state . asm = a . mov_membase_disp_imm32 ( state . asm , "r11" , 0 , c . OBJ_STRING , false )
    state . asm = a . mov_r32_membase_disp ( state . asm , "edx" , "rsp" , 0x28 )
    state . asm = a . mov_membase_disp_r32 ( state . asm , "r11" , 4 , "edx" )

- [`mlc/codegen/codegen_builtins_alloc.ml:2613`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2720`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 110 — 2 occurrences</summary>

    state . asm = a . call ( state . asm , "fn_alloc" )
    state . asm = a . mov_r11_rax ( state . asm )
    state . asm = a . mov_membase_disp_imm32 ( state . asm , "r11" , 0 , c . OBJ_STRING , false )
    state . asm = a . mov_r32_membase_disp ( state . asm , "edx" , "rsp" , 0x28 )
    state . asm = a . mov_membase_disp_r32 ( state . asm , "r11" , 4 , "edx" )
    state . asm = a . mov_membase_disp_r64 ( state . asm , "rsp" , 0x30 , "r11" )

- [`mlc/codegen/codegen_builtins_alloc.ml:2614`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2721`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 111 — 2 occurrences</summary>

    state . asm = a . mov_r11_rax ( state . asm )
    state . asm = a . mov_membase_disp_imm32 ( state . asm , "r11" , 0 , c . OBJ_STRING , false )
    state . asm = a . mov_r32_membase_disp ( state . asm , "edx" , "rsp" , 0x28 )
    state . asm = a . mov_membase_disp_r32 ( state . asm , "r11" , 4 , "edx" )
    state . asm = a . mov_membase_disp_r64 ( state . asm , "rsp" , 0x30 , "r11" )
    state . asm = a . lea_r64_membase_disp ( state . asm , "rcx" , "r11" , 8 )

- [`mlc/codegen/codegen_builtins_alloc.ml:2615`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2722`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 112 — 2 occurrences</summary>

    state . asm = a . mov_membase_disp_imm32 ( state . asm , "r11" , 0 , c . OBJ_STRING , false )
    state . asm = a . mov_r32_membase_disp ( state . asm , "edx" , "rsp" , 0x28 )
    state . asm = a . mov_membase_disp_r32 ( state . asm , "r11" , 4 , "edx" )
    state . asm = a . mov_membase_disp_r64 ( state . asm , "rsp" , 0x30 , "r11" )
    state . asm = a . lea_r64_membase_disp ( state . asm , "rcx" , "r11" , 8 )
    state . asm = a . mov_r64_membase_disp ( state . asm , "rdx" , "rsp" , 0x20 )

- [`mlc/codegen/codegen_builtins_alloc.ml:2616`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2723`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 113 — 2 occurrences</summary>

    state . asm = a . mov_r32_membase_disp ( state . asm , "edx" , "rsp" , 0x28 )
    state . asm = a . mov_membase_disp_r32 ( state . asm , "r11" , 4 , "edx" )
    state . asm = a . mov_membase_disp_r64 ( state . asm , "rsp" , 0x30 , "r11" )
    state . asm = a . lea_r64_membase_disp ( state . asm , "rcx" , "r11" , 8 )
    state . asm = a . mov_r64_membase_disp ( state . asm , "rdx" , "rsp" , 0x20 )
    state . asm = a . lea_r64_membase_disp ( state . asm , "rdx" , "rdx" , 8 )

- [`mlc/codegen/codegen_builtins_alloc.ml:2617`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2724`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 114 — 2 occurrences</summary>

    state . asm = a . mov_membase_disp_r32 ( state . asm , "r11" , 4 , "edx" )
    state . asm = a . mov_membase_disp_r64 ( state . asm , "rsp" , 0x30 , "r11" )
    state . asm = a . lea_r64_membase_disp ( state . asm , "rcx" , "r11" , 8 )
    state . asm = a . mov_r64_membase_disp ( state . asm , "rdx" , "rsp" , 0x20 )
    state . asm = a . lea_r64_membase_disp ( state . asm , "rdx" , "rdx" , 8 )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r8d" , "rsp" , 0x28 )

- [`mlc/codegen/codegen_builtins_alloc.ml:2618`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2725`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 115 — 2 occurrences</summary>

    state . asm = a . mov_membase_disp_r64 ( state . asm , "rsp" , 0x30 , "r11" )
    state . asm = a . lea_r64_membase_disp ( state . asm , "rcx" , "r11" , 8 )
    state . asm = a . mov_r64_membase_disp ( state . asm , "rdx" , "rsp" , 0x20 )
    state . asm = a . lea_r64_membase_disp ( state . asm , "rdx" , "rdx" , 8 )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r8d" , "rsp" , 0x28 )
    state . asm = a . call ( state . asm , "fn_copy_bytes" )

- [`mlc/codegen/codegen_builtins_alloc.ml:2619`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2726`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 116 — 2 occurrences</summary>

    state . asm = a . lea_r64_membase_disp ( state . asm , "rcx" , "r11" , 8 )
    state . asm = a . mov_r64_membase_disp ( state . asm , "rdx" , "rsp" , 0x20 )
    state . asm = a . lea_r64_membase_disp ( state . asm , "rdx" , "rdx" , 8 )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r8d" , "rsp" , 0x28 )
    state . asm = a . call ( state . asm , "fn_copy_bytes" )
    state . asm = a . xor_r32_r32 ( state . asm , "r8d" , "r8d" )

- [`mlc/codegen/codegen_builtins_alloc.ml:2620`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2727`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 117 — 2 occurrences</summary>

    state . asm = a . mark ( state . asm , l_loop )
    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "rsp" , 0x28 )
    state . asm = a . cmp_r32_r32 ( state . asm , "r8d" , "eax" )
    state . asm = a . jcc ( state . asm , "ge" , l_loop + "_done" )
    state . asm = a . mov_r64_membase_disp ( state . asm , "r11" , "rsp" , 0x30 )
    state . asm = a . lea_r64_mem_bis ( state . asm , "r10" , "r11" , "r8" , 1 , 8 )

- [`mlc/codegen/codegen_builtins_alloc.ml:2627`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2734`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 118 — 2 occurrences</summary>

    state . asm = a . mov_r32_membase_disp ( state . asm , "eax" , "rsp" , 0x28 )
    state . asm = a . cmp_r32_r32 ( state . asm , "r8d" , "eax" )
    state . asm = a . jcc ( state . asm , "ge" , l_loop + "_done" )
    state . asm = a . mov_r64_membase_disp ( state . asm , "r11" , "rsp" , 0x30 )
    state . asm = a . lea_r64_mem_bis ( state . asm , "r10" , "r11" , "r8" , 1 , 8 )
    state . asm = a . movzx_r32_membase_disp ( state . asm , "edx" , "r10" , 0 )

- [`mlc/codegen/codegen_builtins_alloc.ml:2628`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2735`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 119 — 2 occurrences</summary>

    state . asm = a . mark ( state . asm , l_fail )
    state . asm = a . mov_rax_imm64 ( state . asm , t . enc_void ( ) )
    state . asm = a . add_rsp_imm8 ( state . asm , 0x28 )
    state . asm = a . ret ( state . asm )
    return state
    end function

- [`mlc/codegen/codegen_builtins_alloc.ml:284`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:356`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 120 — 2 occurrences</summary>

    state . asm = a . mov_membase_disp_r32 ( state . asm , "rsp" , 0x30 , "r10d" )
    state . asm = a . lea_r64_membase_disp ( state . asm , "rcx" , "r14" , 8 )
    state . asm = a . add_r64_r64 ( state . asm , "rcx" , "r13" )
    state . asm = a . lea_r64_membase_disp ( state . asm , "rdx" , "rdx" , 8 )
    state . asm = a . mov_r32_r32 ( state . asm , "r8d" , "r10d" )
    state . asm = a . call ( state . asm , "fn_copy_bytes" )

- [`mlc/codegen/codegen_builtins_alloc.ml:2956`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2971`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 121 — 2 occurrences</summary>

    state . asm = a . lea_r64_membase_disp ( state . asm , "rcx" , "r14" , 8 )
    state . asm = a . add_r64_r64 ( state . asm , "rcx" , "r13" )
    state . asm = a . lea_r64_membase_disp ( state . asm , "rdx" , "rdx" , 8 )
    state . asm = a . mov_r32_r32 ( state . asm , "r8d" , "r10d" )
    state . asm = a . call ( state . asm , "fn_copy_bytes" )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r10d" , "rsp" , 0x30 )

- [`mlc/codegen/codegen_builtins_alloc.ml:2957`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2972`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 122 — 2 occurrences</summary>

    state . asm = a . add_r64_r64 ( state . asm , "rcx" , "r13" )
    state . asm = a . lea_r64_membase_disp ( state . asm , "rdx" , "rdx" , 8 )
    state . asm = a . mov_r32_r32 ( state . asm , "r8d" , "r10d" )
    state . asm = a . call ( state . asm , "fn_copy_bytes" )
    state . asm = a . mov_r32_membase_disp ( state . asm , "r10d" , "rsp" , 0x30 )
    state . asm = a . add_r64_r64 ( state . asm , "r13" , "r10" )

- [`mlc/codegen/codegen_builtins_alloc.ml:2958`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:2973`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 123 — 2 occurrences</summary>

    state . asm = a . push_reg ( state . asm , "rsi" )
    state . asm = a . push_reg ( state . asm , "rdi" )
    state . asm = a . push_reg ( state . asm , "r12" )
    state . asm = a . push_reg ( state . asm , "r13" )
    state . asm = a . push_reg ( state . asm , "r14" )
    state . asm = a . push_reg ( state . asm , "r15" )

- [`mlc/codegen/codegen_builtins_alloc.ml:584`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_expr.ml:711`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 124 — 2 occurrences</summary>

    state . asm = a . add_rsp_imm8 ( state . asm , 0x58 )
    state . asm = a . pop_reg ( state . asm , "r15" )
    state . asm = a . pop_reg ( state . asm , "r14" )
    state . asm = a . pop_reg ( state . asm , "r13" )
    state . asm = a . pop_reg ( state . asm , "r12" )
    state . asm = a . pop_reg ( state . asm , "rdi" )

- [`mlc/codegen/codegen_builtins_alloc.ml:814`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:825`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 125 — 3 occurrences</summary>

    state . asm = a . pop_reg ( state . asm , "r15" )
    state . asm = a . pop_reg ( state . asm , "r14" )
    state . asm = a . pop_reg ( state . asm , "r13" )
    state . asm = a . pop_reg ( state . asm , "r12" )
    state . asm = a . pop_reg ( state . asm , "rdi" )
    state . asm = a . pop_reg ( state . asm , "rsi" )

- [`mlc/codegen/codegen_builtins_alloc.ml:815`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:826`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_expr.ml:735`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 126 — 2 occurrences</summary>

    state . asm = a . pop_reg ( state . asm , "r14" )
    state . asm = a . pop_reg ( state . asm , "r13" )
    state . asm = a . pop_reg ( state . asm , "r12" )
    state . asm = a . pop_reg ( state . asm , "rdi" )
    state . asm = a . pop_reg ( state . asm , "rsi" )
    state . asm = a . ret ( state . asm )

- [`mlc/codegen/codegen_builtins_alloc.ml:816`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:827`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 127 — 2 occurrences</summary>

    end if
    end if
    if eqn == "" or eid < 0 then continue end if
    vals = _enum_variants_of ( state , eqn )
    if typeof ( vals ) != "array" or len ( vals ) <= 0 then continue end if
    for vid = 0 to len ( vals ) - 1

- [`mlc/codegen/codegen_builtins_alloc.ml:83`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)
- [`mlc/codegen/codegen_builtins_alloc.ml:959`](File-mlc-codegen-codegen-builtins-alloc-ml-1763349803.md)

</details>

<details>
<summary>Clone 128 — 2 occurrences</summary>

    top = state . expr_temp_top
    if typeof ( top ) != "int" then top = 0 end if
    if top <= 0 then
    state . expr_temp_top = 0
    state = _sync_expr_temp_root_count ( state )
    return state

- [`mlc/codegen/codegen_core.ml:1081`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:1107`](File-mlc-codegen-codegen-core-ml-528695596.md)

</details>

<details>
<summary>Clone 129 — 2 occurrences</summary>

    if typeof ( top ) != "int" then top = 0 end if
    if top <= 0 then
    state . expr_temp_top = 0
    state = _sync_expr_temp_root_count ( state )
    return state
    end if

- [`mlc/codegen/codegen_core.ml:1082`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:1108`](File-mlc-codegen-codegen-core-ml-528695596.md)

</details>

<details>
<summary>Clone 130 — 2 occurrences</summary>

    if top <= 0 then
    state . expr_temp_top = 0
    state = _sync_expr_temp_root_count ( state )
    return state
    end if
    if sz > top then sz = top end if

- [`mlc/codegen/codegen_core.ml:1083`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:1109`](File-mlc-codegen-codegen-core-ml-528695596.md)

</details>

<details>
<summary>Clone 131 — 2 occurrences</summary>

    state . asm = a . lea_r9_rip ( state . asm , "bytesWritten" )
    state . asm = a . mov_qword_ptr_rsp20_rax_zero ( state . asm )
    state . asm = a . mov_rax_rip_qword ( state . asm , "iat_WriteFile" )
    state . asm = a . call_rax ( state . asm )
    return state
    end function

- [`mlc/codegen/codegen_core.ml:1462`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:1481`](File-mlc-codegen-codegen-core-ml-528695596.md)

</details>

<details>
<summary>Clone 132 — 4 occurrences</summary>

    state . asm = a . cvtsd2ss_xmm_xmm ( state . asm , "xmm2" , "xmm0" )
    state . asm = a . cvtss2sd_xmm_xmm ( state . asm , "xmm3" , "xmm2" )
    state . asm = a . ucomisd_xmm_xmm ( state . asm , "xmm0" , "xmm3" )
    state . asm = a . jcc ( state . asm , "ne" , l_box )
    state . asm = a . jcc ( state . asm , "p" , l_box )
    state . asm = a . movd_r32_xmm ( state . asm , "eax" , "xmm2" )

- [`mlc/codegen/codegen_core.ml:1517`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:1538`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_runtime.ml:136`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)
- [`mlc/codegen/codegen_runtime.ml:161`](File-mlc-codegen-codegen-runtime-ml-1845689217.md)

</details>

<details>
<summary>Clone 133 — 2 occurrences</summary>

    state . asm = a . cvtss2sd_xmm_xmm ( state . asm , "xmm3" , "xmm2" )
    state . asm = a . ucomisd_xmm_xmm ( state . asm , "xmm0" , "xmm3" )
    state . asm = a . jcc ( state . asm , "ne" , l_box )
    state . asm = a . jcc ( state . asm , "p" , l_box )
    state . asm = a . movd_r32_xmm ( state . asm , "eax" , "xmm2" )
    state . asm = a . shl_r64_imm8 ( state . asm , "rax" , 3 )

- [`mlc/codegen/codegen_core.ml:1518`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:1539`](File-mlc-codegen-codegen-core-ml-528695596.md)

</details>

<details>
<summary>Clone 134 — 2 occurrences</summary>

    state . asm = a . ucomisd_xmm_xmm ( state . asm , "xmm0" , "xmm3" )
    state . asm = a . jcc ( state . asm , "ne" , l_box )
    state . asm = a . jcc ( state . asm , "p" , l_box )
    state . asm = a . movd_r32_xmm ( state . asm , "eax" , "xmm2" )
    state . asm = a . shl_r64_imm8 ( state . asm , "rax" , 3 )
    state . asm = a . or_rax_imm8 ( state . asm , c . TAG_FLOAT )

- [`mlc/codegen/codegen_core.ml:1519`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:1540`](File-mlc-codegen-codegen-core-ml-528695596.md)

</details>

<details>
<summary>Clone 135 — 2 occurrences</summary>

    state . asm = a . jcc ( state . asm , "ne" , l_box )
    state . asm = a . jcc ( state . asm , "p" , l_box )
    state . asm = a . movd_r32_xmm ( state . asm , "eax" , "xmm2" )
    state . asm = a . shl_r64_imm8 ( state . asm , "rax" , 3 )
    state . asm = a . or_rax_imm8 ( state . asm , c . TAG_FLOAT )
    state . asm = a . jmp ( state . asm , l_end )

- [`mlc/codegen/codegen_core.ml:1520`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:1541`](File-mlc-codegen-codegen-core-ml-528695596.md)

</details>

<details>
<summary>Clone 136 — 2 occurrences</summary>

    state . asm = a . jcc ( state . asm , "p" , l_box )
    state . asm = a . movd_r32_xmm ( state . asm , "eax" , "xmm2" )
    state . asm = a . shl_r64_imm8 ( state . asm , "rax" , 3 )
    state . asm = a . or_rax_imm8 ( state . asm , c . TAG_FLOAT )
    state . asm = a . jmp ( state . asm , l_end )
    state . asm = a . mark ( state . asm , l_box )

- [`mlc/codegen/codegen_core.ml:1521`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:1542`](File-mlc-codegen-codegen-core-ml-528695596.md)

</details>

<details>
<summary>Clone 137 — 2 occurrences</summary>

    state . asm = a . movd_r32_xmm ( state . asm , "eax" , "xmm2" )
    state . asm = a . shl_r64_imm8 ( state . asm , "rax" , 3 )
    state . asm = a . or_rax_imm8 ( state . asm , c . TAG_FLOAT )
    state . asm = a . jmp ( state . asm , l_end )
    state . asm = a . mark ( state . asm , l_box )
    state . asm = a . call ( state . asm , "fn_box_float" )

- [`mlc/codegen/codegen_core.ml:1522`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:1543`](File-mlc-codegen-codegen-core-ml-528695596.md)

</details>

<details>
<summary>Clone 138 — 2 occurrences</summary>

    state . asm = a . shl_r64_imm8 ( state . asm , "rax" , 3 )
    state . asm = a . or_rax_imm8 ( state . asm , c . TAG_FLOAT )
    state . asm = a . jmp ( state . asm , l_end )
    state . asm = a . mark ( state . asm , l_box )
    state . asm = a . call ( state . asm , "fn_box_float" )
    state . asm = a . mark ( state . asm , l_end )

- [`mlc/codegen/codegen_core.ml:1523`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:1544`](File-mlc-codegen-codegen-core-ml-528695596.md)

</details>

<details>
<summary>Clone 139 — 2 occurrences</summary>

    state . asm = a . or_rax_imm8 ( state . asm , c . TAG_FLOAT )
    state . asm = a . jmp ( state . asm , l_end )
    state . asm = a . mark ( state . asm , l_box )
    state . asm = a . call ( state . asm , "fn_box_float" )
    state . asm = a . mark ( state . asm , l_end )
    return state

- [`mlc/codegen/codegen_core.ml:1524`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:1545`](File-mlc-codegen-codegen-core-ml-528695596.md)

</details>

<details>
<summary>Clone 140 — 2 occurrences</summary>

    state . asm = a . jmp ( state . asm , l_end )
    state . asm = a . mark ( state . asm , l_box )
    state . asm = a . call ( state . asm , "fn_box_float" )
    state . asm = a . mark ( state . asm , l_end )
    return state
    end function

- [`mlc/codegen/codegen_core.ml:1525`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:1546`](File-mlc-codegen-codegen-core-ml-528695596.md)

</details>

<details>
<summary>Clone 141 — 16 occurrences</summary>

    [ ] ,
    [ ] ,
    [ ] ,
    [ ] ,
    [ ] ,
    [ ] ,

- [`mlc/codegen/codegen_core.ml:619`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:620`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:621`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:622`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:623`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:624`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:625`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:626`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:627`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:628`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:629`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:630`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:631`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:632`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:633`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:676`](File-mlc-codegen-codegen-core-ml-528695596.md)

</details>

<details>
<summary>Clone 142 — 2 occurrences</summary>

    t . fastmap_new ( 256 ) ,
    t . fastmap_new ( 256 ) ,
    t . fastmap_new ( 256 ) ,
    t . fastmap_new ( 256 ) ,
    t . fastmap_new ( 256 ) ,
    t . fastmap_new ( 256 ) ,

- [`mlc/codegen/codegen_core.ml:663`](File-mlc-codegen-codegen-core-ml-528695596.md)
- [`mlc/codegen/codegen_core.ml:664`](File-mlc-codegen-codegen-core-ml-528695596.md)

</details>

<details>
<summary>Clone 143 — 2 occurrences</summary>

    state . asm = a . jmp ( state . asm , l_done )
    state . asm = a . mark ( state . asm , l_void )
    state . asm = a . mov_rax_imm64 ( state . asm , t . enc_void ( ) )
    state . asm = a . mark ( state . asm , l_done )
    state = core . free_expr_temps ( state , 8 )
    return state

- [`mlc/codegen/codegen_expr.ml:1665`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:1689`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 144 — 2 occurrences</summary>

    state . asm = a . mark ( state . asm , l_void )
    state . asm = a . mov_rax_imm64 ( state . asm , t . enc_void ( ) )
    state . asm = a . mark ( state . asm , l_done )
    state = core . free_expr_temps ( state , 8 )
    return state
    end function

- [`mlc/codegen/codegen_expr.ml:1666`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:1690`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 145 — 2 occurrences</summary>

    state . asm = a . cmp_r32_imm ( state . asm , "ecx" , 0 )
    state . asm = a . jcc ( state . asm , "l" , l_oob )
    state . asm = a . cmp_r32_r32 ( state . asm , "ecx" , "edx" )
    state . asm = a . jcc ( state . asm , "ge" , l_oob )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r11" )
    state . asm = a . add_r64_r64 ( state . asm , "rax" , "rcx" )

- [`mlc/codegen/codegen_expr.ml:2317`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:2336`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 146 — 2 occurrences</summary>

    state . asm = a . jcc ( state . asm , "l" , l_oob )
    state . asm = a . cmp_r32_r32 ( state . asm , "ecx" , "edx" )
    state . asm = a . jcc ( state . asm , "ge" , l_oob )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r11" )
    state . asm = a . add_r64_r64 ( state . asm , "rax" , "rcx" )
    state . asm = a . add_rax_imm8 ( state . asm , 8 )

- [`mlc/codegen/codegen_expr.ml:2318`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:2337`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 147 — 2 occurrences</summary>

    state . asm = a . cmp_r32_r32 ( state . asm , "ecx" , "edx" )
    state . asm = a . jcc ( state . asm , "ge" , l_oob )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r11" )
    state . asm = a . add_r64_r64 ( state . asm , "rax" , "rcx" )
    state . asm = a . add_rax_imm8 ( state . asm , 8 )
    state . asm = a . movzx_r32_membase_disp ( state . asm , "eax" , "rax" , 0 )

- [`mlc/codegen/codegen_expr.ml:2319`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:2338`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 148 — 2 occurrences</summary>

    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r10" )
    if op == "&" then
    state . asm = a . and_r64_r64 ( state . asm , "rax" , "r11" )
    else
    if op == "|" then
    state . asm = a . or_r64_r64 ( state . asm , "rax" , "r11" )

- [`mlc/codegen/codegen_expr.ml:2949`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3882`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 149 — 2 occurrences</summary>

    if op == "&" then
    state . asm = a . and_r64_r64 ( state . asm , "rax" , "r11" )
    else
    if op == "|" then
    state . asm = a . or_r64_r64 ( state . asm , "rax" , "r11" )
    else

- [`mlc/codegen/codegen_expr.ml:2950`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3883`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 150 — 2 occurrences</summary>

    state . asm = a . and_r64_r64 ( state . asm , "rax" , "r11" )
    else
    if op == "|" then
    state . asm = a . or_r64_r64 ( state . asm , "rax" , "r11" )
    else
    state . asm = a . xor_r64_r64 ( state . asm , "rax" , "r11" )

- [`mlc/codegen/codegen_expr.ml:2951`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3884`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 151 — 2 occurrences</summary>

    else
    if op == "|" then
    state . asm = a . or_r64_r64 ( state . asm , "rax" , "r11" )
    else
    state . asm = a . xor_r64_r64 ( state . asm , "rax" , "r11" )
    state . asm = a . or_rax_imm8 ( state . asm , c . TAG_INT )

- [`mlc/codegen/codegen_expr.ml:2952`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3885`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 152 — 2 occurrences</summary>

    if op == "|" then
    state . asm = a . or_r64_r64 ( state . asm , "rax" , "r11" )
    else
    state . asm = a . xor_r64_r64 ( state . asm , "rax" , "r11" )
    state . asm = a . or_rax_imm8 ( state . asm , c . TAG_INT )
    end if

- [`mlc/codegen/codegen_expr.ml:2953`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3886`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 153 — 2 occurrences</summary>

    state . asm = a . or_r64_r64 ( state . asm , "rax" , "r11" )
    else
    state . asm = a . xor_r64_r64 ( state . asm , "rax" , "r11" )
    state . asm = a . or_rax_imm8 ( state . asm , c . TAG_INT )
    end if
    end if

- [`mlc/codegen/codegen_expr.ml:2954`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3887`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 154 — 2 occurrences</summary>

    if op == "<<" then
    state . asm = a . shl_r64_cl ( state . asm , "rax" )
    else
    state . asm = a . sar_r64_cl ( state . asm , "rax" )
    end if
    state . asm = a . shl_rax_imm8 ( state . asm , 3 )

- [`mlc/codegen/codegen_expr.ml:2993`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4101`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 155 — 2 occurrences</summary>

    state . asm = a . shl_r64_cl ( state . asm , "rax" )
    else
    state . asm = a . sar_r64_cl ( state . asm , "rax" )
    end if
    state . asm = a . shl_rax_imm8 ( state . asm , 3 )
    state . asm = a . or_rax_imm8 ( state . asm , c . TAG_INT )

- [`mlc/codegen/codegen_expr.ml:2994`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4102`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 156 — 3 occurrences</summary>

    state . asm = a . movapd_xmm_xmm ( state . asm , "xmm3" , "xmm0" )
    state . asm = a . divsd_xmm_xmm ( state . asm , "xmm0" , "xmm1" )
    state . asm = a . roundsd_xmm_xmm_imm8 ( state . asm , "xmm2" , "xmm0" , 1 )
    state . asm = a . mulsd_xmm_xmm ( state . asm , "xmm2" , "xmm1" )
    state . asm = a . subsd_xmm_xmm ( state . asm , "xmm3" , "xmm2" )
    state . asm = a . movapd_xmm_xmm ( state . asm , "xmm0" , "xmm3" )

- [`mlc/codegen/codegen_expr.ml:3055`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3772`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4134`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 157 — 3 occurrences</summary>

    state . asm = a . divsd_xmm_xmm ( state . asm , "xmm0" , "xmm1" )
    state . asm = a . roundsd_xmm_xmm_imm8 ( state . asm , "xmm2" , "xmm0" , 1 )
    state . asm = a . mulsd_xmm_xmm ( state . asm , "xmm2" , "xmm1" )
    state . asm = a . subsd_xmm_xmm ( state . asm , "xmm3" , "xmm2" )
    state . asm = a . movapd_xmm_xmm ( state . asm , "xmm0" , "xmm3" )
    end if

- [`mlc/codegen/codegen_expr.ml:3056`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3773`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4135`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 158 — 2 occurrences</summary>

    state . asm = a . ucomisd_xmm_xmm ( state . asm , "xmm0" , "xmm1" )
    if op == "==" then
    state . asm = a . setcc_al ( state . asm , "e" )
    state . asm = a . setcc_r8 ( state . asm , "p" , "dl" )
    state . asm = a . xor_r8_imm8 ( state . asm , "dl" , 1 )
    state . asm = a . and_r8_r8 ( state . asm , "al" , "dl" )

- [`mlc/codegen/codegen_expr.ml:3065`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3258`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 159 — 2 occurrences</summary>

    if op == "==" then
    state . asm = a . setcc_al ( state . asm , "e" )
    state . asm = a . setcc_r8 ( state . asm , "p" , "dl" )
    state . asm = a . xor_r8_imm8 ( state . asm , "dl" , 1 )
    state . asm = a . and_r8_r8 ( state . asm , "al" , "dl" )
    else

- [`mlc/codegen/codegen_expr.ml:3066`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3259`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 160 — 3 occurrences</summary>

    state . asm = a . mark ( state . asm , l_cmp_float )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r10" )
    state = core . emit_to_double_xmm ( state , 0 , l_cmp_fail )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r11" )
    state = core . emit_to_double_xmm ( state , 1 , l_cmp_fail )
    state . asm = a . ucomisd_xmm_xmm ( state . asm , "xmm0" , "xmm1" )

- [`mlc/codegen/codegen_expr.ml:3253`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3817`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4176`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 161 — 3 occurrences</summary>

    state . asm = a . xor_r32_r32 ( state . asm , "eax" , "eax" )
    if op == "!=" then
    state . asm = a . inc_r32 ( state . asm , "eax" )
    end if
    state . asm = a . shl_rax_imm8 ( state . asm , 3 )
    state . asm = a . or_rax_imm8 ( state . asm , c . TAG_BOOL )

- [`mlc/codegen/codegen_expr.ml:3311`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3324`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3415`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 162 — 2 occurrences</summary>

    if op == "!=" then
    state . asm = a . inc_r32 ( state . asm , "eax" )
    end if
    state . asm = a . shl_rax_imm8 ( state . asm , 3 )
    state . asm = a . or_rax_imm8 ( state . asm , c . TAG_BOOL )
    state . asm = a . jmp ( state . asm , l_done_eq )

- [`mlc/codegen/codegen_expr.ml:3312`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3325`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 163 — 2 occurrences</summary>

    state . asm = a . mov_r64_r64 ( state . asm , "r9" , "r11" )
    state . asm = a . shr_r64_imm8 ( state . asm , "r9" , 19 )
    state . asm = a . cmp_r64_r64 ( state . asm , "r8" , "r9" )
    state . asm = a . setcc_al ( state . asm , cc_enum )
    state . asm = a . movzx_eax_al ( state . asm )
    state . asm = a . shl_rax_imm8 ( state . asm , 3 )

- [`mlc/codegen/codegen_expr.ml:3335`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3359`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 164 — 2 occurrences</summary>

    state . asm = a . shr_r64_imm8 ( state . asm , "r9" , 19 )
    state . asm = a . cmp_r64_r64 ( state . asm , "r8" , "r9" )
    state . asm = a . setcc_al ( state . asm , cc_enum )
    state . asm = a . movzx_eax_al ( state . asm )
    state . asm = a . shl_rax_imm8 ( state . asm , 3 )
    state . asm = a . or_rax_imm8 ( state . asm , c . TAG_BOOL )

- [`mlc/codegen/codegen_expr.ml:3336`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3360`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 165 — 3 occurrences</summary>

    state . asm = a . cmp_r64_r64 ( state . asm , "r8" , "r9" )
    state . asm = a . setcc_al ( state . asm , cc_enum )
    state . asm = a . movzx_eax_al ( state . asm )
    state . asm = a . shl_rax_imm8 ( state . asm , 3 )
    state . asm = a . or_rax_imm8 ( state . asm , c . TAG_BOOL )
    state . asm = a . jmp ( state . asm , l_done_eq )

- [`mlc/codegen/codegen_expr.ml:3337`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3349`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3361`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 166 — 2 occurrences</summary>

    state . asm = a . mov_r64_r64 ( state . asm , "rdx" , "rax" )
    state . asm = a . and_r64_imm ( state . asm , "rdx" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "rdx" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_isvoid )
    state . asm = a . mov_r32_membase_disp ( state . asm , "edx" , "rax" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "edx" , c . OBJ_STRING )

- [`mlc/codegen/codegen_expr.ml:3506`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3517`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 167 — 2 occurrences</summary>

    state . asm = a . and_r64_imm ( state . asm , "rdx" , 7 )
    state . asm = a . cmp_r64_imm ( state . asm , "rdx" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_isvoid )
    state . asm = a . mov_r32_membase_disp ( state . asm , "edx" , "rax" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "edx" , c . OBJ_STRING )
    state . asm = a . jcc ( state . asm , "e" , l_nvoid )

- [`mlc/codegen/codegen_expr.ml:3507`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3518`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 168 — 2 occurrences</summary>

    state . asm = a . cmp_r64_imm ( state . asm , "rdx" , c . TAG_PTR )
    state . asm = a . jcc ( state . asm , "ne" , l_isvoid )
    state . asm = a . mov_r32_membase_disp ( state . asm , "edx" , "rax" , 0 )
    state . asm = a . cmp_r32_imm ( state . asm , "edx" , c . OBJ_STRING )
    state . asm = a . jcc ( state . asm , "e" , l_nvoid )
    state . asm = a . jmp ( state . asm , l_isvoid )

- [`mlc/codegen/codegen_expr.ml:3508`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3519`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 169 — 2 occurrences</summary>

    cc = "e"
    if op == "<" then cc = "l" end if
    if op == ">" then cc = "g" end if
    if op == "<=" then cc = "le" end if
    if op == ">=" then cc = "ge" end if
    state . asm = a . setcc_r8 ( state . asm , cc , "al" )

- [`mlc/codegen/codegen_expr.ml:3805`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4165`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 170 — 2 occurrences</summary>

    if op == "<" then cc = "l" end if
    if op == ">" then cc = "g" end if
    if op == "<=" then cc = "le" end if
    if op == ">=" then cc = "ge" end if
    state . asm = a . setcc_r8 ( state . asm , cc , "al" )
    state . asm = a . movzx_eax_al ( state . asm )

- [`mlc/codegen/codegen_expr.ml:3806`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4166`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 171 — 2 occurrences</summary>

    if op == ">" then cc = "g" end if
    if op == "<=" then cc = "le" end if
    if op == ">=" then cc = "ge" end if
    state . asm = a . setcc_r8 ( state . asm , cc , "al" )
    state . asm = a . movzx_eax_al ( state . asm )
    state . asm = a . shl_rax_imm8 ( state . asm , 3 )

- [`mlc/codegen/codegen_expr.ml:3807`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4167`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 172 — 2 occurrences</summary>

    if op == "<=" then cc = "le" end if
    if op == ">=" then cc = "ge" end if
    state . asm = a . setcc_r8 ( state . asm , cc , "al" )
    state . asm = a . movzx_eax_al ( state . asm )
    state . asm = a . shl_rax_imm8 ( state . asm , 3 )
    state . asm = a . or_rax_imm8 ( state . asm , c . TAG_BOOL )

- [`mlc/codegen/codegen_expr.ml:3808`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4168`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 173 — 2 occurrences</summary>

    if op == ">=" then cc = "ge" end if
    state . asm = a . setcc_r8 ( state . asm , cc , "al" )
    state . asm = a . movzx_eax_al ( state . asm )
    state . asm = a . shl_rax_imm8 ( state . asm , 3 )
    state . asm = a . or_rax_imm8 ( state . asm , c . TAG_BOOL )
    state . asm = a . jmp ( state . asm , l_done )

- [`mlc/codegen/codegen_expr.ml:3809`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4169`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 174 — 2 occurrences</summary>

    ccf = "a"
    if op == "<" then ccf = "b" end if
    if op == "<=" then ccf = "be" end if
    if op == ">=" then ccf = "ae" end if
    state . asm = a . setcc_al ( state . asm , ccf )
    state . asm = a . setcc_r8 ( state . asm , "p" , "dl" )

- [`mlc/codegen/codegen_expr.ml:3824`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4183`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 175 — 2 occurrences</summary>

    if op == "<" then ccf = "b" end if
    if op == "<=" then ccf = "be" end if
    if op == ">=" then ccf = "ae" end if
    state . asm = a . setcc_al ( state . asm , ccf )
    state . asm = a . setcc_r8 ( state . asm , "p" , "dl" )
    state . asm = a . xor_r8_imm8 ( state . asm , "dl" , 1 )

- [`mlc/codegen/codegen_expr.ml:3825`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4184`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 176 — 2 occurrences</summary>

    if op == "<=" then ccf = "be" end if
    if op == ">=" then ccf = "ae" end if
    state . asm = a . setcc_al ( state . asm , ccf )
    state . asm = a . setcc_r8 ( state . asm , "p" , "dl" )
    state . asm = a . xor_r8_imm8 ( state . asm , "dl" , 1 )
    state . asm = a . and_r8_r8 ( state . asm , "al" , "dl" )

- [`mlc/codegen/codegen_expr.ml:3826`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4185`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 177 — 2 occurrences</summary>

    if op == ">=" then ccf = "ae" end if
    state . asm = a . setcc_al ( state . asm , ccf )
    state . asm = a . setcc_r8 ( state . asm , "p" , "dl" )
    state . asm = a . xor_r8_imm8 ( state . asm , "dl" , 1 )
    state . asm = a . and_r8_r8 ( state . asm , "al" , "dl" )
    state . asm = a . movzx_eax_al ( state . asm )

- [`mlc/codegen/codegen_expr.ml:3827`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4186`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 178 — 2 occurrences</summary>

    state . asm = a . setcc_al ( state . asm , ccf )
    state . asm = a . setcc_r8 ( state . asm , "p" , "dl" )
    state . asm = a . xor_r8_imm8 ( state . asm , "dl" , 1 )
    state . asm = a . and_r8_r8 ( state . asm , "al" , "dl" )
    state . asm = a . movzx_eax_al ( state . asm )
    state . asm = a . shl_rax_imm8 ( state . asm , 3 )

- [`mlc/codegen/codegen_expr.ml:3828`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4187`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 179 — 2 occurrences</summary>

    state . asm = a . setcc_r8 ( state . asm , "p" , "dl" )
    state . asm = a . xor_r8_imm8 ( state . asm , "dl" , 1 )
    state . asm = a . and_r8_r8 ( state . asm , "al" , "dl" )
    state . asm = a . movzx_eax_al ( state . asm )
    state . asm = a . shl_rax_imm8 ( state . asm , 3 )
    state . asm = a . or_rax_imm8 ( state . asm , c . TAG_BOOL )

- [`mlc/codegen/codegen_expr.ml:3829`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4188`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 180 — 2 occurrences</summary>

    state . asm = a . xor_r8_imm8 ( state . asm , "dl" , 1 )
    state . asm = a . and_r8_r8 ( state . asm , "al" , "dl" )
    state . asm = a . movzx_eax_al ( state . asm )
    state . asm = a . shl_rax_imm8 ( state . asm , 3 )
    state . asm = a . or_rax_imm8 ( state . asm , c . TAG_BOOL )
    state . asm = a . jmp ( state . asm , l_done )

- [`mlc/codegen/codegen_expr.ml:3830`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4189`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 181 — 2 occurrences</summary>

    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r10" )
    state . asm = a . and_rax_imm8 ( state . asm , 7 )
    state . asm = a . cmp_rax_imm8 ( state . asm , c . TAG_VOID )
    state . asm = a . jcc ( state . asm , "e" , l_cmp_isvoid )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r11" )
    state . asm = a . and_rax_imm8 ( state . asm , 7 )

- [`mlc/codegen/codegen_expr.ml:3842`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4201`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 182 — 2 occurrences</summary>

    state . asm = a . and_rax_imm8 ( state . asm , 7 )
    state . asm = a . cmp_rax_imm8 ( state . asm , c . TAG_VOID )
    state . asm = a . jcc ( state . asm , "e" , l_cmp_isvoid )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r11" )
    state . asm = a . and_rax_imm8 ( state . asm , 7 )
    state . asm = a . cmp_rax_imm8 ( state . asm , c . TAG_VOID )

- [`mlc/codegen/codegen_expr.ml:3843`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4202`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 183 — 2 occurrences</summary>

    state . asm = a . cmp_rax_imm8 ( state . asm , c . TAG_VOID )
    state . asm = a . jcc ( state . asm , "e" , l_cmp_isvoid )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r11" )
    state . asm = a . and_rax_imm8 ( state . asm , 7 )
    state . asm = a . cmp_rax_imm8 ( state . asm , c . TAG_VOID )
    state . asm = a . jcc ( state . asm , "ne" , l_cmp_nvoid )

- [`mlc/codegen/codegen_expr.ml:3844`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4203`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 184 — 2 occurrences</summary>

    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r10" )
    state . asm = a . and_rax_imm8 ( state . asm , 7 )
    state . asm = a . cmp_rax_imm8 ( state . asm , c . TAG_VOID )
    state . asm = a . jcc ( state . asm , "e" , l_bit_isvoid )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r11" )
    state . asm = a . and_rax_imm8 ( state . asm , 7 )

- [`mlc/codegen/codegen_expr.ml:3899`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4230`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 185 — 2 occurrences</summary>

    state . asm = a . and_rax_imm8 ( state . asm , 7 )
    state . asm = a . cmp_rax_imm8 ( state . asm , c . TAG_VOID )
    state . asm = a . jcc ( state . asm , "e" , l_bit_isvoid )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r11" )
    state . asm = a . and_rax_imm8 ( state . asm , 7 )
    state . asm = a . cmp_rax_imm8 ( state . asm , c . TAG_VOID )

- [`mlc/codegen/codegen_expr.ml:3900`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4231`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 186 — 2 occurrences</summary>

    state . asm = a . cmp_rax_imm8 ( state . asm , c . TAG_VOID )
    state . asm = a . jcc ( state . asm , "e" , l_bit_isvoid )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r11" )
    state . asm = a . and_rax_imm8 ( state . asm , 7 )
    state . asm = a . cmp_rax_imm8 ( state . asm , c . TAG_VOID )
    state . asm = a . jcc ( state . asm , "ne" , l_bit_nvoid )

- [`mlc/codegen/codegen_expr.ml:3901`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4232`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 187 — 2 occurrences</summary>

    state . asm = a . jcc ( state . asm , "e" , l_bit_isvoid )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r11" )
    state . asm = a . and_rax_imm8 ( state . asm , 7 )
    state . asm = a . cmp_rax_imm8 ( state . asm , c . TAG_VOID )
    state . asm = a . jcc ( state . asm , "ne" , l_bit_nvoid )
    state . asm = a . mark ( state . asm , l_bit_isvoid )

- [`mlc/codegen/codegen_expr.ml:3902`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4233`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 188 — 2 occurrences</summary>

    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r11" )
    state . asm = a . and_rax_imm8 ( state . asm , 7 )
    state . asm = a . cmp_rax_imm8 ( state . asm , c . TAG_VOID )
    state . asm = a . jcc ( state . asm , "ne" , l_bit_nvoid )
    state . asm = a . mark ( state . asm , l_bit_isvoid )
    state = core . emit_dbg_line ( state , expr )

- [`mlc/codegen/codegen_expr.ml:3903`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4234`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 189 — 2 occurrences</summary>

    state . asm = a . and_rax_imm8 ( state . asm , 7 )
    state . asm = a . cmp_rax_imm8 ( state . asm , c . TAG_VOID )
    state . asm = a . jcc ( state . asm , "ne" , l_bit_nvoid )
    state . asm = a . mark ( state . asm , l_bit_isvoid )
    state = core . emit_dbg_line ( state , expr )
    state = _emit_make_error_const ( state , c . ERR_VOID_OP , "Cannot apply '" + op + "' to void" )

- [`mlc/codegen/codegen_expr.ml:3904`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4235`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 190 — 2 occurrences</summary>

    state . asm = a . cmp_rax_imm8 ( state . asm , c . TAG_VOID )
    state . asm = a . jcc ( state . asm , "ne" , l_bit_nvoid )
    state . asm = a . mark ( state . asm , l_bit_isvoid )
    state = core . emit_dbg_line ( state , expr )
    state = _emit_make_error_const ( state , c . ERR_VOID_OP , "Cannot apply '" + op + "' to void" )
    state = _emit_auto_errprop ( state )

- [`mlc/codegen/codegen_expr.ml:3905`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4236`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 191 — 2 occurrences</summary>

    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r10" )
    state . asm = a . and_rax_imm8 ( state . asm , 7 )
    state . asm = a . cmp_rax_imm8 ( state . asm , c . TAG_VOID )
    state . asm = a . jcc ( state . asm , "e" , l_sh_isvoid )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r11" )
    state . asm = a . and_rax_imm8 ( state . asm , 7 )

- [`mlc/codegen/codegen_expr.ml:3955`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4251`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 192 — 2 occurrences</summary>

    state . asm = a . and_rax_imm8 ( state . asm , 7 )
    state . asm = a . cmp_rax_imm8 ( state . asm , c . TAG_VOID )
    state . asm = a . jcc ( state . asm , "e" , l_sh_isvoid )
    state . asm = a . mov_r64_r64 ( state . asm , "rax" , "r11" )
    state . asm = a . and_rax_imm8 ( state . asm , 7 )
    state . asm = a . cmp_rax_imm8 ( state . asm , c . TAG_VOID )

- [`mlc/codegen/codegen_expr.ml:3956`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:4252`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 193 — 2 occurrences</summary>

    state . asm = a . and_rax_imm8 ( state . asm , 7 )
    state . asm = a . cmp_rax_imm8 ( state . asm , c . TAG_INT )
    if want_float_arith then
    state . asm = a . jcc ( state . asm , "ne" , l_float )
    else
    state . asm = a . jcc ( state . asm , "ne" , l_fail )

- [`mlc/codegen/codegen_expr.ml:3978`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3986`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 194 — 2 occurrences</summary>

    state . asm = a . cmp_rax_imm8 ( state . asm , c . TAG_INT )
    if want_float_arith then
    state . asm = a . jcc ( state . asm , "ne" , l_float )
    else
    state . asm = a . jcc ( state . asm , "ne" , l_fail )
    end if

- [`mlc/codegen/codegen_expr.ml:3979`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:3987`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 195 — 4 occurrences</summary>

    found = true
    break
    end if
    end if
    end for
    end if

- [`mlc/codegen/codegen_expr.ml:496`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:510`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:525`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:547`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 196 — 3 occurrences</summary>

    break
    end if
    end if
    end for
    end if
    end if

- [`mlc/codegen/codegen_expr.ml:511`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:526`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:548`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 197 — 2 occurrences</summary>

    if typeof ( alias_map ) != "array" or len ( alias_map ) <= 0 then return "" end if
    for i = 0 to len ( alias_map ) - 1
    p = alias_map [ i ]
    if typeof ( p ) == "struct" and p . key == key then
    if typeof ( p . value ) == "string" then return p . value end if
    end if

- [`mlc/codegen/codegen_expr.ml:757`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:770`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 198 — 2 occurrences</summary>

    for i = 0 to len ( alias_map ) - 1
    p = alias_map [ i ]
    if typeof ( p ) == "struct" and p . key == key then
    if typeof ( p . value ) == "string" then return p . value end if
    end if
    end for

- [`mlc/codegen/codegen_expr.ml:758`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:771`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 199 — 2 occurrences</summary>

    p = alias_map [ i ]
    if typeof ( p ) == "struct" and p . key == key then
    if typeof ( p . value ) == "string" then return p . value end if
    end if
    end for
    return ""

- [`mlc/codegen/codegen_expr.ml:759`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:772`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>

<details>
<summary>Clone 200 — 2 occurrences</summary>

    if typeof ( p ) == "struct" and p . key == key then
    if typeof ( p . value ) == "string" then return p . value end if
    end if
    end for
    return ""
    end function

- [`mlc/codegen/codegen_expr.ml:760`](File-mlc-codegen-codegen-expr-ml-59843844.md)
- [`mlc/codegen/codegen_expr.ml:773`](File-mlc-codegen-codegen-expr-ml-59843844.md)

</details>


## Definitions

- **Cognitive complexity:** decision complexity weighted by nesting; logical `and`/`or` operators add one.
- **Cyclomatic complexity:** one plus decisions from conditions, loops, switch cases, and logical `and`/`or` operators.
- **Documentation coverage:** percentage of documented API summaries, parameter contracts, fields, constants, globals, and enum variants. Empty categories report 100% and do not affect the overall ratio.
- **Halstead metrics:** operators and operands are counted from MiniLang lexical tokens. Estimated defects are volume divided by 3,000.
- **Maintainability index:** normalized 0–100 index based on Halstead volume, cyclomatic complexity, and source lines. Project MI is source-line weighted across files.
- **SLOC:** non-empty lines containing MiniLang tokens after conditional preprocessing; comment-only lines are excluded.
