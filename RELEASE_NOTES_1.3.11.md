# MiniLang 1.3.11

Released on 2026-11-25.

This correctness release makes overlapping byte and array copies reliable,
corrects native-helper dispatch, and aligns both compilers on UTF-8 byte
lengths. Both compiler CLIs and the `MINILANG_VERSION` conditional-compilation
constant report **1.3.11**.

## Overlap-safe copies

`copyBytes` and `copyArray` now preserve the original source values when the
source and destination ranges overlap. Direct calls and calls through stored
function values have the same behavior. For example:

```minilang
values = [1, 2, 3, 4, 5]
copyArray(values, 1, values, 0, 4)
print values == [1, 1, 2, 3, 4]  // true
```

Overlapping ranges use a directional copy without allocating a temporary
buffer. Disjoint ranges retain the optimized copy path. Array copies preserve
the existing garbage-collector write barrier and use whole aligned cells.
Existing clipping and invalid-argument behavior is retained.

## Consistent UTF-8 string lengths

Native `len(string)` counts **UTF-8 bytes**. The companion Python compiler now
uses this rule for constant folding, matching the self-hosted compiler and
the native runtime:

```minilang
text = "Grüße 🌍"
print len("Grüße 🌍")  // 12
print len(text)        // 12
```

String metadata, byte-based indexing and standard-library buffer sizing keep
their existing semantics. Embedded NULs are included in the length. The
separate WebAssembly compiler retains its own documented length policy.

## Native compiler fixes

- Register the overlap-safe move helper in the same canonical order as the
  Python compiler and retain its dependency on the optimized copy helper.
- Correct helper-dispatch group boundaries, including the `fn_decref` entry.
- Preserve the source address before assigning the byte-count register in
  the generic direct `copyBytes` path.
- Add shared regressions for direct and indirect copies, Unicode lengths,
  copied references surviving collection, initializer scope, and
  Boolean/integer equality. The existing initializer and comparison rules
  are preserved.

## Validation and packages

The [implementation validation report](docs/reports/NATIVE_COPY_AND_LENGTH_2026-11-25.md)
records the checks completed before the version bump: 1,446 copy cases in the
shared fixture, 8,820 independent native-helper comparisons including guard
pages, and byte parity across the Python, native monolithic, and native MLO
paths. Executable checks in that report ran on Linux; Windows and MinUX images
were cross-compiled and compared. A Linux bootstrap and self-build also
produced identical compiler bytes in that tested configuration.

The [1.3.11 release verification matrix](docs/reports/release-1.3.11-version-matrix.json)
records version-specific build and regression results. Final archive checks
run after the source commit and are reported separately in
`release-1.3.11-package-verification.json` on both 1.3.11 release pages.
Native Windows x64, Linux x64 and packed MinUX x64 packages include the matching
standard library,
manifests and SHA-256 sidecars. Read the
[binary installation guide](README-BINARY.md) for package contents and checksums,
and the [MinUX guide](docs/MINUX.md) for platform prerequisites.

- [Changelog](CHANGELOG.md)
- [Language reference](docs/LANGUAGE_REFERENCE.md)
- [Native copy and runtime primitives](docs/NATIVE_PRIMITIVES.md)
- [Python reference compiler 1.3.11](https://github.com/MiniLangProject/MiniLangCompilerPy/releases/tag/v1.3.11)
