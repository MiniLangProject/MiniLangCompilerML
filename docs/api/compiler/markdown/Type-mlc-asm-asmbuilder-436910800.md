# `mlc.asm.AsmBuilder`

[Home](README.md) · [Source file](File-mlc-asm-ml-1368648960.md)

<a id="struct-struct-mlc-asm-asmbuilder-struct-asmbuilder-mlc-asm-ml-58495319"></a>
## AsmBuilder

```ml
struct AsmBuilder
```

Paged instruction stream plus chunked labels, patches and call metadata.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L42)

## Members

<a id="field-field-mlc-asm-asmbuilder-active-chunk-active-chunk-mlc-asm-ml-1925196109"></a>
### active_chunk

```ml
active_chunk
```

Stores the active chunk member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L88)

<a id="field-field-mlc-asm-asmbuilder-active-chunk-index-active-chunk-index-mlc-asm-ml-1386766115"></a>
### active_chunk_index

```ml
active_chunk_index
```

Stores the active chunk index member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L90)

<a id="field-field-mlc-asm-asmbuilder-before-call-live-temps-before-call-live-temps-mlc-asm-ml-408406967"></a>
### before_call_live_temps

```ml
before_call_live_temps
```

Stores the before call live temps member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L74)

<a id="field-field-mlc-asm-asmbuilder-buf-buf-mlc-asm-ml-1512533089"></a>
### buf

```ml
buf
```

Stores the buf member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L44)

<a id="field-field-mlc-asm-asmbuilder-buf-valid-buf-valid-mlc-asm-ml-571993529"></a>
### buf_valid

```ml
buf_valid
```

Stores the buf valid member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L72)

<a id="field-field-mlc-asm-asmbuilder-calls-chunks-calls-chunks-mlc-asm-ml-749416697"></a>
### calls_chunks

```ml
calls_chunks
```

Stores the calls chunks member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L62)

<a id="field-field-mlc-asm-asmbuilder-calls-tail-calls-tail-mlc-asm-ml-1808364553"></a>
### calls_tail

```ml
calls_tail
```

Stores the calls tail member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L64)

<a id="field-field-mlc-asm-asmbuilder-chunk-pages-chunk-pages-mlc-asm-ml-1108671849"></a>
### chunk_pages

```ml
chunk_pages
```

Stores the chunk pages member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L66)

<a id="field-field-mlc-asm-asmbuilder-chunk-size-chunk-size-mlc-asm-ml-1581864071"></a>
### chunk_size

```ml
chunk_size
```

Stores the chunk size member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L70)

<a id="field-field-mlc-asm-asmbuilder-chunk-tail-chunk-tail-mlc-asm-ml-450546197"></a>
### chunk_tail

```ml
chunk_tail
```

Stores the chunk tail member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L68)

<a id="field-field-mlc-asm-asmbuilder-deferred-patches-chunks-deferred-patches-chunks-mlc-asm-ml-2075829621"></a>
### deferred_patches_chunks

```ml
deferred_patches_chunks
```

Stores the deferred patches chunks member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L58)

<a id="field-field-mlc-asm-asmbuilder-deferred-patches-tail-deferred-patches-tail-mlc-asm-ml-1377104573"></a>
### deferred_patches_tail

```ml
deferred_patches_tail
```

Stores the deferred patches tail member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L60)

<a id="field-field-mlc-asm-asmbuilder-label-pos-map-label-pos-map-mlc-asm-ml-1962644617"></a>
### label_pos_map

```ml
label_pos_map
```

Stores the label pos map member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L78)

<a id="field-field-mlc-asm-asmbuilder-labels-labels-mlc-asm-ml-843981347"></a>
### labels

```ml
labels
```

Stores the labels member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L48)

<a id="field-field-mlc-asm-asmbuilder-labels-chunks-labels-chunks-mlc-asm-ml-2019547049"></a>
### labels_chunks

```ml
labels_chunks
```

Stores the labels chunks member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L50)

<a id="field-field-mlc-asm-asmbuilder-labels-tail-labels-tail-mlc-asm-ml-1461714185"></a>
### labels_tail

```ml
labels_tail
```

Stores the labels tail member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L52)

<a id="field-field-mlc-asm-asmbuilder-patches-chunks-patches-chunks-mlc-asm-ml-225921227"></a>
### patches_chunks

```ml
patches_chunks
```

Stores the patches chunks member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L54)

<a id="field-field-mlc-asm-asmbuilder-patches-tail-patches-tail-mlc-asm-ml-179515267"></a>
### patches_tail

```ml
patches_tail
```

Stores the patches tail member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L56)

<a id="field-field-mlc-asm-asmbuilder-peephole-last-jump-peephole-last-jump-mlc-asm-ml-366573497"></a>
### peephole_last_jump

```ml
peephole_last_jump
```

Stores the peephole last jump member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L80)

<a id="field-field-mlc-asm-asmbuilder-peephole-last-push-peephole-last-push-mlc-asm-ml-1049860393"></a>
### peephole_last_push

```ml
peephole_last_push
```

Stores the peephole last push member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L82)

<a id="field-field-mlc-asm-asmbuilder-record-calls-record-calls-mlc-asm-ml-1704893651"></a>
### record_calls

```ml
record_calls
```

Stores the record calls member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L84)

<a id="field-field-mlc-asm-asmbuilder-size-size-mlc-asm-ml-648870399"></a>
### size

```ml
size
```

Stores the size member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L46)

<a id="field-field-mlc-asm-asmbuilder-tracked-helper-map-tracked-helper-map-mlc-asm-ml-615846337"></a>
### tracked_helper_map

```ml
tracked_helper_map
```

Stores the tracked helper map member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L86)

<a id="field-field-mlc-asm-asmbuilder-tracked-helpers-tracked-helpers-mlc-asm-ml-1908449057"></a>
### tracked_helpers

```ml
tracked_helpers
```

Stores the tracked helpers member of `AsmBuilder`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/asm.ml#L76)
