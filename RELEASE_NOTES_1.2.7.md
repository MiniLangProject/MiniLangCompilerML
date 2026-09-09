# MiniLang Compiler 1.2.7

This release adds cross-platform ECDSA P-256 signature verification to the
shared MiniLang standard library. `std.crypto.ecdsa_p256.verify` hashes the
message with SHA-256 and verifies fixed-width raw public keys and signatures
through Windows CNG or OpenSSL 3 on Linux.

Both compiler repositories contain matching standard-library implementations,
documentation and positive/negative regression fixtures. The Python compiler,
self-hosted monolithic pipeline and self-hosted object pipeline produce
byte-identical Windows PE and Linux ELF images for the ECDSA fixture. The full
Python suite passes 145/145 tests and the self-hosted ported suite passes
136/136 tests.

Both CLI version switches and `MINILANG_VERSION` report 1.2.7.

## Binary downloads

- [Windows x64 ZIP](https://github.com/MiniLangProject/MiniLangCompilerML/releases/download/v1.2.7/MiniLangCompilerML-1.2.7-windows-x64.zip)
- [Linux x64 tar.gz](https://github.com/MiniLangProject/MiniLangCompilerML/releases/download/v1.2.7/MiniLangCompilerML-1.2.7-linux-x64.tar.gz)

Extract the complete package, including `std/`. Run `mlc.exe` on Windows or
`./mlc` on Linux. Compile with `-I .` from the package directory and select the
desired target explicitly when cross-compiling. Each archive has a SHA-256
sidecar and includes a quick-start guide. No installed Python is required.

This package contains the native, self-hosted MiniLang compiler.
