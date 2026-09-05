# Binary compiler packages

Release 1.2.6 provides Windows x64 ZIP and Linux x64 tar.gz packages. Each
contains an executable compiler (`mlc.exe` or `mlc`), the matching `std/` library,
a hello example, license, release notes and a BUILD_INFO.json manifest. Every
download has a SHA-256 sidecar. No separate Python installation is needed to run
either compiler distribution.

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

The manifest identifies the 1.2.6 compiler-source revision and executable hash.
Compiler sources are unchanged by this binary-packaging update. Source archives
remain available alongside the binary assets generated for this release.

This package contains the native, self-hosted MiniLang compiler. Its
executable has no Python runtime dependency.

## Building binary releases

Build `build/mlc_win64.exe` with `build.ps1` on Windows and `build/mlc_linux_x64`
with `build.sh` on Linux. Then run the development packaging helper:

```sh
python scripts/package_binary.py --binary build/mlc_win64.exe --platform windows-x64
python scripts/package_binary.py --binary build/mlc_linux_x64 --platform linux-x64
```

Archives and checksum sidecars are written to `build/releases`. Python is used
only for this packaging helper; the distributed compiler needs no Python.
The compiler-source version tag must be available locally for the manifest.
