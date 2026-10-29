# `mlc.incremental.Cache`

[Home](README.md) · [Source file](File-mlc-incremental-ml-857733037.md)

<a id="struct-struct-mlc-incremental-cache-struct-cache-mlc-incremental-ml-604525879"></a>
## Cache

```ml
struct Cache
```

One build's cache state; no frontend AST is retained here.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L16)

## Members

<a id="field-field-mlc-incremental-cache-castagnoli-castagnoli-mlc-incremental-ml-1445942187"></a>
### castagnoli

```ml
castagnoli
```


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L29)

<a id="field-field-mlc-incremental-cache-context-context-mlc-incremental-ml-2081066253"></a>
### context

```ml
context
```

Prepared global semantic fingerprint.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L24)

<a id="field-field-mlc-incremental-cache-declarations-declarations-mlc-incremental-ml-128487355"></a>
### declarations

```ml
declarations
```

Declaration and inline-body fingerprint.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L22)

<a id="field-field-mlc-incremental-cache-directory-directory-mlc-incremental-ml-926371373"></a>
### directory

```ml
directory
```

Persistent directory containing one last generation per function.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L18)

<a id="field-field-mlc-incremental-cache-files-files-mlc-incremental-ml-1256711089"></a>
### files

```ml
files
```

Per-module content identities.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L26)

<a id="field-field-mlc-incremental-cache-hits-hits-mlc-incremental-ml-1407742965"></a>
### hits

```ml
hits
```

Reused, compiled, and invalid-entry counts.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L33)

<a id="field-field-mlc-incremental-cache-ieee-ieee-mlc-incremental-ml-479185453"></a>
### ieee

```ml
ieee
```

Rolling section/pool mutation identities.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L28)

<a id="field-field-mlc-incremental-cache-initialized-initialized-mlc-incremental-ml-261357005"></a>
### initialized

```ml
initialized
```

Whether the initial section frontier has been fingerprinted.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L31)

<a id="field-field-mlc-incremental-cache-invalid-invalid-mlc-incremental-ml-1975146141"></a>
### invalid

```ml
invalid
```


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L35)

<a id="field-field-mlc-incremental-cache-misses-misses-mlc-incremental-ml-1574666013"></a>
### misses

```ml
misses
```


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L34)

<a id="field-field-mlc-incremental-cache-options-options-mlc-incremental-ml-1695239085"></a>
### options

```ml
options
```

Compiler identity and effective options.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/incremental.ml#L20)
