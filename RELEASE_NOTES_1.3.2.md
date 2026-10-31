# MiniLang Compiler 1.3.2

This patch release restores byte-identical output for OOP programs compiled by
the Python reference compiler and the self-hosted compiler. It supersedes the
cross-compiler binary-parity limitation documented for 1.3.1.

The compilers now agree on direct class factory calls, generated constructor
source positions and parameter checks, and inferred return types of static
class methods, including qualified private methods. Constructor calls with
more than four arguments use the same x64 calling convention in both hosts.

The new [binary-parity regression](tests/check_oop_binary_parity.py) compiles
eleven class and interface programs for Windows x64 and Linux x64 through both
monolithic and object pipelines, compares SHA-256 hashes, and runs each
program. The [release matrix](docs/reports/release-1.3.2-version-matrix.json)
records the compiler and fixture hashes, including byte-identical Python and
self-hosted compiler builds and a self-hosted fixed point on each target.
This release includes Windows x64 ZIP and Linux x64 tar.gz packages with
SHA-256 sidecars. The
[Python compiler release](https://github.com/MiniLangProject/MiniLangCompilerPy/releases/tag/v1.3.2)
contains source.
