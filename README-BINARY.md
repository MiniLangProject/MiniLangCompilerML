# Binary compiler packages

Release 1.3.8 provides Windows x64 ZIP and Linux x64 tar.gz packages. Each
contains an executable compiler (`mlc.exe` or `mlc`), the matching `std/` library,
a hello example, license, third-party notices, release notes and a BUILD_INFO.json manifest. Every
download has a SHA-256 sidecar. No separate Python installation is needed to run
either native package.

## Release 1.3.8 checksums

The download archives are `MiniLangCompilerML-1.3.8-windows-x64.zip` and
`MiniLangCompilerML-1.3.8-linux-x64.tar.gz`. Verify each archive with its
adjacent `.sha256` download on the [release page](https://github.com/MiniLangProject/MiniLangCompilerML/releases/tag/v1.3.8).
The `BUILD_INFO.json` inside each archive records the executable SHA-256 and
the exact tagged compiler-source revision.

| Executable | Bytes | SHA-256 |
| --- | ---: | --- |
| Windows `mlc.exe` | 64,356,352 | `5684B8C01D0C3574FDDFE3C0E8BCD0CD1BB9B089323F949F12DEFE7A37030F33` |
| Linux `mlc` | 64,381,424 | `E11386C7F1C6209DA33C07F6FF54D3E28F736B8A7FD6874625811642000D3A2E` |

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

The Linux tar archive preserves the executable bit. These builds were tested on
Ubuntu 24.04 x86-64 (glibc 2.39) and Windows 11 x64. Older Linux distributions
and musl-based systems are not covered. Keep `-I /path/to/extracted/package`
when building from another directory so standard-library imports resolve.
Windows remains the compiler's default output target; select `--target linux-x64`
explicitly when producing Linux applications. Either host compiler can emit
either target, but the resulting program runs on its selected target OS.

The manifest identifies the 1.3.8 compiler-source revision and executable hash.
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

The distributed compiler is unpacked. To pack your programs without external
tools, use `--pack`; the generated executable decompresses its code in memory
on startup. The older UPX method remains available with `--pack=upx --upx PATH`.
See [the included guide](docs/EXECUTABLE_PACKING.md) for exact unpacking,
startup/memory trade-offs and signing constraints.

## Native media runtime

Release 1.3.8 packages include the native-media
bridge source and the matching prebuilt runtime. BUILD_INFO.json records that
bridge's ABI, relative path and SHA-256.

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
