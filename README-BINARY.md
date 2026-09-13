# Binary compiler packages

Release 1.2.8 provides Windows x64 ZIP and Linux x64 tar.gz packages. Each
contains an executable compiler (`mlc.exe` or `mlc`), the matching `std/` library,
a hello example, license, release notes and a BUILD_INFO.json manifest. Every
download has a SHA-256 sidecar. No separate Python installation is needed to run
either compiler distribution.

## Release 1.2.8 checksums

| Download or executable | Bytes | SHA-256 |
| --- | ---: | --- |
| `MiniLangCompilerML-1.2.8-windows-x64.zip` | 9,666,181 | `0CA1D2C37AB0D35FE123666C9A226DB3F43B4772FA913E9BDD01B84F08046E09` |
| Windows `mlc.exe` inside the ZIP | 65,274,880 | `60DB15723F1D33AFCCBAF81657E91569811C38CF54A320117857C29027700E0B` |
| `MiniLangCompilerML-1.2.8-linux-x64.tar.gz` | 9,635,572 | `A30F590339D977A3B1ECDDCD1BFAA17DDF326F707689541AC268ED4CAF077B66` |
| Linux `mlc` inside the tarball | 65,244,848 | `8BF4FDDDB7D68F2B5B3613D0FA715AA69A1B7FC68E7EC392F67B319141893DB8` |

The two archive hashes match their adjacent `.sha256` downloads. Each
`BUILD_INFO.json` records the contained executable hash and source revision
`6ac0bd31a8055ba21495a01ebd1a7d1a305dd2eb`.

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

The manifest identifies the 1.2.8 compiler-source revision and executable hash.
Source archives remain available alongside the binary assets generated for this
release.

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
