# Binary compiler packages

Release 1.2.18 provides Windows x64 ZIP and Linux x64 tar.gz packages. Each
contains an executable compiler (`mlc.exe` or `mlc`), the matching `std/` library,
a hello example, license, release notes and a BUILD_INFO.json manifest. Every
download has a SHA-256 sidecar. No separate Python installation is needed to run
either compiler distribution.

## Release 1.2.18 checksums

The download archives are `MiniLangCompilerML-1.2.18-windows-x64.zip` and
`MiniLangCompilerML-1.2.18-linux-x64.tar.gz`. Verify each archive with its
adjacent `.sha256` download on the [release page](https://github.com/MiniLangProject/MiniLangCompilerML/releases/tag/v1.2.18).
The `BUILD_INFO.json` inside each archive records the executable SHA-256 and
the exact tagged compiler-source revision.

| Executable | Bytes | SHA-256 |
| --- | ---: | --- |
| Windows `mlc.exe` | 55,379,968 | `D2C03E5C02BFC5F455FE1078EDBCD6FD7A34A4C3130E6D4F1E570749719B30AA` |
| Linux `mlc` | 55,382,096 | `730F85B06CA42833B0C15560256607E97AC3D0BDE950273836C3357B47EB2F38` |

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

The manifest identifies the 1.2.18 compiler-source revision and executable hash.
Source archives remain available alongside the binary assets generated for this
release.

## Native media runtime

Release 1.2.18 packages include the native-media
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
