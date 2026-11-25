# Binary compiler packages

Release 1.3.11 provides Windows x64 ZIP, Linux x64 tar.gz and MinUX x64 tar.gz
packages. Each contains a native compiler (`mlc.exe` or `mlc`), matching `std/`
sources, runtime libraries, a Hello example, license notices, documentation,
release notes and BUILD_INFO.json. Every download has a SHA-256 sidecar.
The compilers run without a Python installation.

## Release 1.3.11 checksums

The download archives are `MiniLangCompilerML-1.3.11-windows-x64.zip` and
`MiniLangCompilerML-1.3.11-linux-x64.tar.gz`, plus
`MiniLangCompilerML-1.3.11-minux-x64.tar.gz`. Verify each archive with its
adjacent `.sha256` download on the [release page](https://github.com/MiniLangProject/MiniLangCompilerML/releases/tag/v1.3.11).
The `BUILD_INFO.json` inside each archive records the executable SHA-256 and
the exact tagged compiler-source revision.

| Executable | Bytes | SHA-256 |
| --- | ---: | --- |
| Windows `mlc.exe` | 68,022,272 | `cadacd2b4d2425d492fea2e94b4d4db48b54cb07b3ae810b3247bcf42b9b1efc` |
| Linux `mlc` | 68,044,016 | `7a61fe5447d0e81d700c834c7f02dce2259c0bd2418050b056653bea742b8c67` |
| MinUX `mlc` (packed) | 15,240,011 | `65dd1c354b2d8e1a4e8b163f27466ab603522dc64465b6f00fa1eb0c85276e1c` |

Extract the whole package before use. From its directory, on Windows:

```powershell
./mlc.exe --version
./mlc.exe examples/hello.ml hello.exe --target windows-x64 -I .
./hello.exe
```

On Linux:

```sh
./mlc --version
./mlc examples/hello.ml hello --target linux-x64 -I .
./hello
```

On MinUX, first build/update the [required kernel changes](https://github.com/n1k0m0/MinUX/commit/3675df7)
and its matching driver modules, then install the included shared libraries in
`/lib`. Preserve `third-party/minux` and install a trusted CA bundle when using
TLS certificate verification. From the extracted package directory:

```sh
chmod +x mlc runtimes/minux-x64/*.so
./mlc --version
./mlc examples/hello.ml hello --target minux-x64 -I . --pack
./hello
```

The MinUX compiler is packed to satisfy the 16 MiB loader limit. Its runtime
manifest records every bundled library hash. See [MINUX.md](docs/MINUX.md) for
native filesystem, networking, media and GUI limits. Source for all MinUX
adapters and the Mbed TLS license are included.

The Linux tar archive preserves the executable bit. Release 1.3.11 was built
and executed on Debian 13.7 x86-64 (glibc 2.41). Windows and MinUX images were
cross-compiled and compared; this release's checks do not include execution
on Windows or in a MinUX guest. Older Linux distributions and musl-based
systems are not covered. See the [release verification matrix](docs/reports/release-1.3.11-version-matrix.json)
for the build and regression results. Keep `-I /path/to/extracted/package`
when building from another directory so standard-library imports resolve.
Windows remains the compiler's default output target; select `--target linux-x64`
explicitly when producing Linux applications. Either host compiler can emit
all three targets, but the resulting program runs on its selected target OS.

The manifest identifies the 1.3.11 compiler-source revision and executable hash.
Source archives remain available alongside the binary assets generated for this
release.

The accelerated IEEE CRC32 helper includes Intel ISA-L-derived code. Include
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) with distributions of generated
programs using that helper.

## Incremental builds

Add `--incremental-cache build/compiler-cache` to direct compiler invocations
to reuse compatible native functions after source edits. Project manifests
enable this automatically unless `incremental = false` is selected.
Use `--no-incremental` to bypass all cache reads and writes for one build.

The frontend and linker still run after edits; declaration, inline or layout
changes can require additional functions to be rebuilt. Cache population has
a time and memory cost. See the [included guide](docs/INCREMENTAL_BUILDS.md)
and [evaluation](docs/reports/INCREMENTAL_BUILDS_2026-10-29.md).

## Optional executable packing

The Windows/Linux compilers are unpacked; the MinUX compiler is packed. To pack your programs without external
tools, use `--pack`; the generated executable decompresses its code in memory
on startup. The older UPX method remains available with `--pack=upx --upx PATH`.
See [the included guide](docs/EXECUTABLE_PACKING.md) for exact unpacking,
startup/memory trade-offs and signing constraints.

## Native media runtime

Release 1.3.11 packages include the native-media
bridge source and the matching prebuilt runtime. BUILD_INFO.json records that
bridge's ABI, relative path and SHA-256.

The video and MinUX runtime sources are unchanged from 1.3.10. Their prebuilt
libraries are reused from the official 1.3.10 packages after verifying the
archive and library hashes. The compiler executables are newly built from
the 1.3.11 sources.

Applications importing `std.video` or `std.audio` must deploy the matching file from
`runtimes/<target>/` beside the generated executable. Windows supplies Media
Foundation. Linux additionally needs the GStreamer 1.x runtime and plugins for
the formats the application accepts. The portable bridge source and build
instructions are included under `native/video/`; cross-target builds can
build the other target's bridge from that source.

This package contains the native, self-hosted MiniLang compiler. Its
executable has no Python runtime dependency.

## Building binary releases

Build `build/mlc_win64.exe` with `build.ps1` on Windows and `build/mlc_linux_x64`
with `build.sh` on Linux. Build the target's native-video bridge before
running the development packaging helper:

```powershell
.\native\video\windows\build.ps1
python scripts/package_binary.py --binary build/mlc_win64.exe --platform windows-x64
```

```sh
sh native/video/linux/build.sh
python scripts/package_binary.py --binary build/mlc_linux_x64 --platform linux-x64
```

Archives and checksum sidecars are written to `build/releases`. Python is used
only for this packaging helper; the distributed compiler needs no Python.
The compiler-source version tag must be available locally for the manifest.
