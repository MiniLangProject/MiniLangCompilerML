# `mlc/minux_blob.ml`

[Home](README.md) · [Files](Files.md)

Generated MinUX runtime boundary bytes, labels and relocations.

Package: [`mlc.minux_blob`](Package-mlc-minux-blob-999462652.md)

Reachable from entry: **yes**

## Declarations

<a id="function-function-mlc-minux-blob-runtime-bytes-function-runtime-bytes-mlc-minux-blob-ml-1947129208"></a>
### runtime_bytes

```ml
function runtime_bytes()
```

Return the generated runtime machine-code bytes.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minux_blob.ml#L26)

<a id="function-function-mlc-minux-blob-runtime-labels-function-runtime-labels-mlc-minux-blob-ml-2091393396"></a>
### runtime_labels

```ml
function runtime_labels()
```

Return label offsets within the generated runtime fragment.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minux_blob.ml#L31)

<a id="function-function-mlc-minux-blob-runtime-patches-function-runtime-patches-mlc-minux-blob-ml-1861255586"></a>
### runtime_patches

```ml
function runtime_patches()
```

Return external relocations within the generated runtime fragment.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minux_blob.ml#L36)

<a id="function-function-mlc-minux-blob-startup-bytes-function-startup-bytes-mlc-minux-blob-ml-1726256706"></a>
### startup_bytes

```ml
function startup_bytes()
```

Return the generated startup machine-code bytes.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minux_blob.ml#L10)

<a id="function-function-mlc-minux-blob-startup-labels-function-startup-labels-mlc-minux-blob-ml-424523100"></a>
### startup_labels

```ml
function startup_labels()
```

Return label offsets within the generated startup fragment.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minux_blob.ml#L15)

<a id="function-function-mlc-minux-blob-startup-patches-function-startup-patches-mlc-minux-blob-ml-1315915472"></a>
### startup_patches

```ml
function startup_patches()
```

Return external relocations within the generated startup fragment.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/minux_blob.ml#L20)
