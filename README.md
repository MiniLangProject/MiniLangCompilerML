# MiniLang self-hosted compiler

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](LICENSE)
[![Language: MiniLang](https://img.shields.io/badge/written%20in-MiniLang-5b5bd6.svg)](.)

This compiler is written in MiniLang and compiles `.ml` programs to native
**Windows x64 (PE32+)** and **Linux x64 (ELF64)** executables. It can rebuild
itself. The [Python reference compiler](https://github.com/MiniLangProject/MiniLangCompilerPy)
provides the bootstrap implementation and a second code-generation path.

Download the [latest native compiler packages](https://github.com/MiniLangProject/MiniLangCompilerML/releases/latest)
or read the [binary installation guide](README-BINARY.md). Version 1.3.2
includes Windows and Linux packages with SHA-256 sidecars; see the
[release notes](RELEASE_NOTES_1.3.2.md) and [changelog](CHANGELOG.md).

## Quick start with a release package

Extract the **whole** Windows ZIP or Linux tar archive. The package includes
`std/`, an example and the compiler executable. From its directory, on Windows:

```powershell
.\mlc.exe examples/hello.ml hello.exe --target windows-x64 -I .
.\hello.exe
```

On Linux:

```sh
./mlc examples/hello.ml hello --target linux-x64 -I .
./hello
```

The output target defaults to Windows x64 on either host. Set
`--target linux-x64` for Linux programs. The generated executable runs on
its selected target OS. See [README-BINARY.md](README-BINARY.md) for package
contents, verification, platform requirements and native media deployment.

## Build the compiler from source

A fresh checkout needs a bootstrap compiler. Put
[MiniLangCompilerPy](https://github.com/MiniLangProject/MiniLangCompilerPy)
beside this repository or pass an existing native compiler to the build script.
The scripts stage and smoke-test the output before installing it.

Windows PowerShell:

```powershell
.\build.ps1
.\build\mlc_win64.exe --version
.\build\mlc_win64.exe hello.ml hello.exe -I .
```

Linux shell:

```sh
./build.sh
./build/mlc_linux_x64 --version
./build/mlc_linux_x64 hello.ml hello --target linux-x64 -I .
```

Create `hello.ml` with `print "Hello from MiniLang!"` before compiling the
last command. `build.ps1 -Compiler PATH` and `./build.sh --compiler PATH`
select a bootstrap compiler explicitly. The Windows script uses a local native
compiler if available and otherwise the sibling Python compiler. The Linux
script follows the same pattern for `build/mlc_linux_x64` and the sibling
Python compiler. Run `-NoReplace` on Windows or `--no-replace` on Linux to
keep an existing compiler untouched while inspecting the new build.

## Language and compiler features

- Classes with single inheritance, virtual dispatch, `override`, `super`,
  constructors, visibility, abstract/final members and inherited interfaces.
  See the [OOP guide](docs/OOP.md).
- Functions, closures, optional checked types, structs, enums, arrays, bytes,
  packages, imports and conditional compilation.
- Native threads, tasks and synchronization with a shared garbage-collected
  heap on Windows and Linux.
- Standard-library modules, native FFI, typed inline x64 assembly, and
  `error`/`try` propagation.
- Monolithic compilation and a memory-bounded `.mlo` object/link pipeline.
  The compiler chooses a path for the import graph; `--object-pipeline` or
  `--no-object-pipeline` forces one for verification or measurement.

The [language reference](docs/LANGUAGE_REFERENCE.md) covers syntax and runtime
behavior. Generated [compiler API](docs/api/compiler/markdown/README.md) and
[`std` API](docs/api/std/markdown/README.md) documentation are checked in.

## Compile a project

```powershell
.\build\mlc_win64.exe src/main.ml build/app.exe -I . -I src
.\build\mlc_win64.exe --project minilang.toml
.\build\mlc_win64.exe --help
```

The same conservative TOML manifest works with both compilers:

```toml
[project]
entry = "src/main.ml"
output = "build/app.exe"
include = ["src", "vendor"]
target = "windows-x64"
incremental = true
cache_dir = ".minilang-cache"
```

Paths are relative to the manifest. The native compiler accepts a shared TOML
subset; see the [incremental-build guide](docs/INCREMENTAL_BUILDS.md) for
manifest syntax, cache validation and reuse limits. Direct builds can use
`--incremental-cache DIR`. Use `--no-incremental` to bypass caches for one build.

| Option | Use |
| --- | --- |
| `--target windows-x64\|linux-x64` | Select the output platform. |
| `-I DIR` | Add an import root; repeat as needed. |
| `-DNAME[=VALUE]` | Set a typed conditional-compilation option. |
| `--subsystem windows` | Build a Windows GUI application. |
| `--object-pipeline` | Force `.mlo` object generation and linking. |
| `--asm`, `--asm-data` | Emit an assembly listing and optional data sections. |
| `--heap-reserve SIZE`, `--gc-limit SIZE` | Configure the native runtime. |
| `--profile-calls`, `--pgo-profile FILE` | Collect call counts and guide inlining. |
| `--profile-compiler` | Report compiler phase timings. |

For the same supported inputs, options and target, the Python compiler,
self-hosted monolithic compiler and self-hosted `.mlo` pipeline are expected
to emit identical target bytes. Version 1.3.2 restored this for the OOP
regression programs on both targets. See the [parity guide](COMPILER_PARITY.md),
[OOP regression](tests/check_oop_binary_parity.py) and
[release verification matrix](docs/reports/release-1.3.2-version-matrix.json).

## Documentation and development

| Topic | Document |
| --- | --- |
| Classes and interfaces | [OOP guide](docs/OOP.md) |
| Language syntax, standard library and FFI | [Language reference](docs/LANGUAGE_REFERENCE.md) |
| Binary packages and checksums | [Binary installation](README-BINARY.md) |
| Incremental builds | [Guide](docs/INCREMENTAL_BUILDS.md) |
| Typed inline assembly | [Guide](docs/INLINE_ASM.md) |
| Native crypto, checksums and CPU features | [Native primitives](docs/NATIVE_PRIMITIVES.md) |
| Compression and platform services | [Platform services](docs/PLATFORM_SERVICES.md) |
| Executable packing | [Packing guide](docs/EXECUTABLE_PACKING.md) |
| Generated APIs | [Compiler](docs/api/compiler/markdown/README.md) · [Standard library](docs/api/std/markdown/README.md) |
| Changes and releases | [Changelog](CHANGELOG.md) · [Releases](https://github.com/MiniLangProject/MiniLangCompilerML/releases) |

After building the compiler, run the native regression suite on Windows:

```powershell
.\scripts\run_tests.ps1
```

Both compiler implementations and their documentation were developed with the
assistance of generative AI. Licensed under [Apache 2.0](LICENSE); see
[third-party notices](THIRD_PARTY_NOTICES.md) for bundled or generated-code
components that require attribution.
