# MiniLang Compiler 1.2.12

This patch release fixes pathological compilation times for long expressions
when the program declares or imports overloaded operators. It includes the
HollowKeep mixed-string-concatenation fix in both compiler implementations.

## Fixes and regression coverage

- Linux packages now set POSIX archive modes explicitly when assembled on
  Windows, preserving executable permissions after extraction on Linux.

- Unary and binary type inference now reuses operand facts instead of
  recursively computing them twice. Qualified struct types remain intact for
  overload selection; evaluation order and emitted program semantics are
  unchanged.
- New tests cover long mixed/literal-first concatenation, deep unary nesting,
  real operator overloads, side effects and early error propagation. A
  visit-count regression guard detects exponential inference without relying
  on wall-clock thresholds.
- The Python test runner now avoids a collision with third-party packages
  named `tests` when discovering the Linux dynamic-library regression module.
- Both CLI version switches and the compile-time `MINILANG_VERSION` report
  **1.2.12**. The identical 53-module standard library and media ABI remain
  unchanged.

## Measured improvement

In the original HollowKeep menu reproduction, code generation for the
affected function package fell from **57.062 s to 0.187 s**. The isolated
build fell from **73.969 s to 14.313 s**, with byte-identical executable output.
A complete HollowKeep source build finished in **96.438 s**.

In a bounded 20-addition A/B benchmark (three runs, median), compilation fell
from **4.821 s to 0.157 s** with Python and **4.203 s to 0.055 s** with the
monolithic self-hosted compiler. These are local compile-time measurements,
not runtime-speed claims. See the
[full methodology and regression report](https://github.com/MiniLangProject/MiniLangCompilerML/blob/v1.2.12/docs/reports/HOLLOWKEEP_STRING_CONCAT_FIX_2026-09-28.md).

## Validation and downloads

The Python suite passes **153/153**. The self-hosted suite passes its
**136/136** embedded MiniLang tests and the additional platform, CLI and
pipeline checks. The concatenation regression is exercised on Windows and
Linux; Python and ML output is byte-identical for each target and pipeline
option.

Python-bootstrap and native self-hosted compiler images are byte-identical
on each platform:

| Compiler image | Bytes | SHA-256 |
| --- | ---: | --- |
| Windows x64 | 65,327,616 | `DAF2419DECC054DF1DA04B86212C138670458CB93273BD6467C47CAD73329AEB` |
| Linux x64 | 65,335,104 | `58328CD3EAD5905A9AA95CBDB974F8E9D824455C6C0916381C5A68BFC1E96695` |

Ready-to-run Windows x64 ZIP and Linux x64 tar.gz packages include the matching
standard library, native media runtime, quick-start example, license,
`BUILD_INFO.json` with the tagged source revision, and SHA-256 sidecars.
Extract the entire package and run `mlc.exe` or `./mlc`; Python is not required.
