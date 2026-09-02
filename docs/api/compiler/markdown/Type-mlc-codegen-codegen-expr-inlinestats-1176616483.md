# `mlc.codegen.codegen_expr.InlineStats`

[Home](README.md) · [Source file](File-mlc-codegen-codegen-expr-ml-59843844.md)

<a id="struct-struct-mlc-codegen-codegen-expr-inlinestats-struct-inlinestats-mlc-codegen-codegen-expr-ml-571876906"></a>
## InlineStats

```ml
struct InlineStats
```

Cost and control-flow summary used by the bounded inliner.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L41)

## Members

<a id="field-field-mlc-codegen-codegen-expr-inlinestats-branch-count-branch-count-mlc-codegen-codegen-expr-ml-85126360"></a>
### branch_count

```ml
branch_count
```

Branch count associated with `InlineStats`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L49)

<a id="field-field-mlc-codegen-codegen-expr-inlinestats-call-count-call-count-mlc-codegen-codegen-expr-ml-1393056208"></a>
### call_count

```ml
call_count
```

Call count associated with `InlineStats`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L47)

<a id="field-field-mlc-codegen-codegen-expr-inlinestats-cost-cost-mlc-codegen-codegen-expr-ml-581327742"></a>
### cost

```ml
cost
```

Cost associated with `InlineStats`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L43)

<a id="field-field-mlc-codegen-codegen-expr-inlinestats-has-loop-has-loop-mlc-codegen-codegen-expr-ml-1273341610"></a>
### has_loop

```ml
has_loop
```

Whether `InlineStats.has_loop` contains loop.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L53)

<a id="field-field-mlc-codegen-codegen-expr-inlinestats-has-nested-fn-has-nested-fn-mlc-codegen-codegen-expr-ml-1926387004"></a>
### has_nested_fn

```ml
has_nested_fn
```

Whether `InlineStats.has_nested_fn` contains nested fn.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L57)

<a id="field-field-mlc-codegen-codegen-expr-inlinestats-has-switch-has-switch-mlc-codegen-codegen-expr-ml-306072994"></a>
### has_switch

```ml
has_switch
```

Whether `InlineStats.has_switch` contains switch.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L55)

<a id="field-field-mlc-codegen-codegen-expr-inlinestats-max-call-args-max-call-args-mlc-codegen-codegen-expr-ml-755543288"></a>
### max_call_args

```ml
max_call_args
```

Max call args associated with `InlineStats`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L51)

<a id="field-field-mlc-codegen-codegen-expr-inlinestats-stmt-count-stmt-count-mlc-codegen-codegen-expr-ml-1754222768"></a>
### stmt_count

```ml
stmt_count
```

Stmt count associated with `InlineStats`.


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/codegen/codegen_expr.ml#L45)
