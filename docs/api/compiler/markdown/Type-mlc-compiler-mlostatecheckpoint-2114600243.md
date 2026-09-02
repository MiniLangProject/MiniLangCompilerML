# `mlc.compiler.MloStateCheckpoint`

[Home](README.md) · [Source file](File-mlc-compiler-ml-344018962.md)

<a id="struct-struct-mlc-compiler-mlostatecheckpoint-struct-mlostatecheckpoint-mlc-compiler-ml-1921654081"></a>
## MloStateCheckpoint

```ml
struct MloStateCheckpoint
```

Immutable section boundary used while one logical monolithic stream is spilled into independently serializable .mlo fragments.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L349)

## Members

<a id="field-field-mlc-compiler-mlostatecheckpoint-bss-label-count-bss-label-count-mlc-compiler-ml-1947207886"></a>
### bss_label_count

```ml
bss_label_count
```

Bss label count associated with `MloStateCheckpoint`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L365)

<a id="field-field-mlc-compiler-mlostatecheckpoint-bss-size-bss-size-mlc-compiler-ml-1227431158"></a>
### bss_size

```ml
bss_size
```

Bss size associated with `MloStateCheckpoint`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L355)

<a id="field-field-mlc-compiler-mlostatecheckpoint-data-label-count-data-label-count-mlc-compiler-ml-850501888"></a>
### data_label_count

```ml
data_label_count
```

Data label count associated with `MloStateCheckpoint`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L361)

<a id="field-field-mlc-compiler-mlostatecheckpoint-data-patch-count-data-patch-count-mlc-compiler-ml-1739758116"></a>
### data_patch_count

```ml
data_patch_count
```

Data patch count associated with `MloStateCheckpoint`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L363)

<a id="field-field-mlc-compiler-mlostatecheckpoint-data-used-data-used-mlc-compiler-ml-1077556526"></a>
### data_used

```ml
data_used
```

Data used associated with `MloStateCheckpoint`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L353)

<a id="field-field-mlc-compiler-mlostatecheckpoint-rdata-label-count-rdata-label-count-mlc-compiler-ml-1806275170"></a>
### rdata_label_count

```ml
rdata_label_count
```

Rdata label count associated with `MloStateCheckpoint`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L357)

<a id="field-field-mlc-compiler-mlostatecheckpoint-rdata-patch-count-rdata-patch-count-mlc-compiler-ml-1699396934"></a>
### rdata_patch_count

```ml
rdata_patch_count
```

Rdata patch count associated with `MloStateCheckpoint`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L359)

<a id="field-field-mlc-compiler-mlostatecheckpoint-rdata-used-rdata-used-mlc-compiler-ml-2147011894"></a>
### rdata_used

```ml
rdata_used
```

Rdata used associated with `MloStateCheckpoint`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/compiler.ml#L351)
