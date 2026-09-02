# `mlc.tools.FastMap`

[Home](README.md) · [Source file](File-mlc-tools-ml-988451276.md)

<a id="struct-struct-mlc-tools-fastmap-struct-fastmap-mlc-tools-ml-329754129"></a>
## FastMap

```ml
struct FastMap
```

Compiler-internal open-addressing map with power-of-two capacity.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L109)

## Members

<a id="field-field-mlc-tools-fastmap-cap-cap-mlc-tools-ml-1332144711"></a>
### cap

```ml
cap
```

Allocated capacity of `FastMap`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L117)

<a id="field-field-mlc-tools-fastmap-epoch-epoch-mlc-tools-ml-301254399"></a>
### epoch

```ml
epoch
```

Epoch associated with `FastMap`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L121)

<a id="field-field-mlc-tools-fastmap-keys-keys-mlc-tools-ml-618080287"></a>
### keys

```ml
keys
```

Keys associated with `FastMap`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L111)

<a id="field-field-mlc-tools-fastmap-size-size-mlc-tools-ml-1112622089"></a>
### size

```ml
size
```

Current logical size of `FastMap`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L119)

<a id="field-field-mlc-tools-fastmap-touched-touched-mlc-tools-ml-618640747"></a>
### touched

```ml
touched
```

Touched associated with `FastMap`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L123)

<a id="field-field-mlc-tools-fastmap-used-used-mlc-tools-ml-1092092001"></a>
### used

```ml
used
```

Number of populated entries in `FastMap`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L115)

<a id="field-field-mlc-tools-fastmap-values-values-mlc-tools-ml-329853099"></a>
### values

```ml
values
```

Values associated with `FastMap`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/tools.ml#L113)
