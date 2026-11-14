# `mlc/pack_loader_bytes.ml`

[Home](README.md) · [Files](Files.md)

Embedded fixed-layout x64 loader bytes for dependency-free packing.

Package: [`mlc.pack_loader_bytes`](Package-mlc-pack-loader-bytes-179377110.md)

Reachable from entry: **yes**

## Declarations

<a id="function-function-mlc-pack-loader-bytes-linux-function-linux-mlc-pack-loader-bytes-ml-16190598"></a>
### linux

```ml
function linux()
```

Decode the Linux startup stub generated from pack_stubs/loader.S.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pack_loader_bytes.ml#L26)

<a id="function-function-mlc-pack-loader-bytes-windows-function-windows-mlc-pack-loader-bytes-ml-1464735648"></a>
### windows

```ml
function windows()
```

Decode the Windows startup stub generated from pack_stubs/loader.S.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/pack_loader_bytes.ml#L21)
