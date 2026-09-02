# `mlc/project.ml`

[Home](README.md) · [Files](Files.md)

Provides the mlc project package.

Package: [`mlc.project`](Package-mlc-project-1794969042.md)

Reachable from entry: **yes**

## Imports

- `mlc/tools.ml` as `t` → [mlc/tools.ml](File-mlc-tools-ml-988451276.md)
- `std/checksum/crc32.ml` as `crc32` → `std/checksum/crc32.ml` — external dependency
- `std/checksum/crc32c.ml` as `crc32c` → `std/checksum/crc32c.ml` — external dependency
- `std/fs.ml` as `fs` → `std/fs.ml` — external dependency
- `std/io/file.ml` as `fileio` → `std/io/file.ml` — external dependency
- `std/process.ml` as `process` → `std/process.ml` — external dependency
- `std/sort.ml` as `sort` → `std/sort.ml` — external dependency
- `std/string.ml` as `s` → `std/string.ml` — external dependency

## Declarations

<a id="function-function-mlc-project-abspath-function-abspath-path-mlc-project-ml-1572840265"></a>
### _abspath

```ml
function _abspath(path)
```

Implements abspath.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L143)

<a id="function-function-mlc-project-append-unique-path-function-append-unique-path-paths-path-mlc-project-ml-91913875"></a>
### _append_unique_path

```ml
function _append_unique_path(paths, path)
```

Updates append unique path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `paths` | `dynamic` | — |  |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L510)

<a id="function-function-mlc-project-atomic-replace-function-atomic-replace-source-path-destination-path-mlc-project-ml-2036966507"></a>
### _atomic_replace

```ml
function _atomic_replace(source_path, destination_path)
```

Atomically update the cached artifact and its validation metadata.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source_path` | `dynamic` | — |  |
| `destination_path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L907)

<a id="function-function-mlc-project-cache-artifact-path-function-cache-artifact-path-pb-digest-mlc-project-ml-423707984"></a>
### _cache_artifact_path

```ml
function _cache_artifact_path(pb, digest)
```

Implements cache artifact path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pb` | `dynamic` | — |  |
| `digest` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L749)

<a id="function-function-mlc-project-canon-linux-function-canon-linux-path-mlc-project-ml-1761756277"></a>
### _canon_linux

```ml
function _canon_linux(path)
```

Normalize a POSIX path lexically so output paths need not exist yet.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L161)

<a id="function-function-mlc-project-collect-import-dependencies-function-collect-import-dependencies-collector-include-dirs-excluded-mlc-project-ml-1279196130"></a>
### _collect_import_dependencies

```ml
function _collect_import_dependencies(collector, include_dirs, excluded)
```

Broad root traversal covers inactive package imports. This second pass follows quoted imports recursively so absolute and parent-relative imports outside those roots also participate in the exact cache fingerprint.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `collector` | `dynamic` | — |  |
| `include_dirs` | `dynamic` | — |  |
| `excluded` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L636)

<a id="function-function-mlc-project-collect-ml-files-function-collect-ml-files-path-excluded-collector-mlc-project-ml-349996124"></a>
### _collect_ml_files

```ml
function _collect_ml_files(path, excluded, collector)
```

Implements collect ml files.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `excluded` | `dynamic` | — |  |
| `collector` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L502)

<a id="function-function-mlc-project-collect-ml-files-inner-function-collect-ml-files-inner-path-excluded-collector-follow-directory-link-mlc-project-ml-1921535988"></a>
### _collect_ml_files_inner

```ml
function _collect_ml_files_inner(path, excluded, collector, follow_directory_link)
```

Collect every MiniLang source below a root once. Indexed directory/file sets make overlapping include roots linear instead of repeatedly deduplicating immutable arrays.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `excluded` | `dynamic` | — |  |
| `collector` | `dynamic` | — |  |
| `follow_directory_link` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L470)

<a id="function-function-mlc-project-collector-add-import-file-function-collector-add-import-file-collector-path-excluded-mlc-project-ml-1071809644"></a>
### _collector_add_import_file

```ml
function _collector_add_import_file(collector, path, excluded)
```

Implements collector add import file.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `collector` | `dynamic` | — |  |
| `path` | `dynamic` | — |  |
| `excluded` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L617)

<a id="function-function-mlc-project-copy-file-preserve-mode-function-copy-file-preserve-mode-source-path-destination-path-mlc-project-ml-1481878617"></a>
### _copy_file_preserve_mode

```ml
function _copy_file_preserve_mode(source_path, destination_path)
```

Std.fs.copyFile intentionally copies bytes only. Cache artifacts additionally retain their POSIX mode so a native Linux cache hit remains executable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source_path` | `dynamic` | — |  |
| `destination_path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L755)

<a id="function-function-mlc-project-dirname-function-dirname-path-mlc-project-ml-1922658205"></a>
### _dirname

```ml
function _dirname(path)
```

Implements dirname.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L106)

<a id="function-function-mlc-project-ensure-dir-function-ensure-dir-path-mlc-project-ml-636457735"></a>
### _ensure_dir

```ml
function _ensure_dir(path)
```

Implements ensure dir.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L197)

<a id="function-function-mlc-project-file-content-id-function-file-content-id-path-mlc-project-ml-1934850017"></a>
### _file_content_id

```ml
function _file_content_id(path)
```

Single-artifact callers retain the simple API; object-set validation reuses one scratch buffer across every file to avoid one 1-MiB allocation per MLO.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L732)

<a id="function-function-mlc-project-file-content-id-with-buffer-function-file-content-id-with-buffer-path-buffer-mlc-project-ml-1790270063"></a>
### _file_content_id_with_buffer

```ml
function _file_content_id_with_buffer(path, buffer)
```

Two native CRC polynomials plus the exact length provide a fast bounded- memory content identity. Native checksum instructions avoid interpreting every byte in MiniLang when hashing the 50+ MiB compiler executable.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |
| `buffer` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L704)

<a id="function-function-mlc-project-hash-byte-function-hash-byte-h-value-mlc-project-ml-2106437887"></a>
### _hash_byte

```ml
function _hash_byte(h, value)
```

Reports whether hash byte.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `h` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L419)

<a id="function-function-mlc-project-hash-bytes-function-hash-bytes-h-value-mlc-project-ml-1455792965"></a>
### _hash_bytes

```ml
function _hash_bytes(h, value)
```

Reports whether hash bytes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `h` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L427)

<a id="function-function-mlc-project-hash-text-function-hash-text-h-value-mlc-project-ml-260538367"></a>
### _hash_text

```ml
function _hash_text(h, value)
```

Reports whether hash text.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `h` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L438)

<a id="function-function-mlc-project-hex32-function-hex32-value-mlc-project-ml-1227518279"></a>
### _hex32

```ml
function _hex32(value)
```

Implements hex32.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L664)

<a id="function-function-mlc-project-is-abs-function-is-abs-path-mlc-project-ml-642925041"></a>
### _is_abs

```ml
function _is_abs(path)
```

Reports whether is abs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L134)

<a id="function-function-mlc-project-is-directory-link-function-is-directory-link-path-mlc-project-ml-1407735777"></a>
### _is_directory_link

```ml
function _is_directory_link(path)
```

Broad source-root discovery deliberately does not descend into directory links. This matches Python Path.rglob(), bounds traversal, and prevents a junction/symlink cycle from manufacturing endlessly different lexical paths. Explicitly imported files still follow their exact path in the second pass.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L455)

<a id="function-function-mlc-project-is-known-key-function-is-known-key-key-mlc-project-ml-1385337063"></a>
### _is_known_key

```ml
function _is_known_key(key)
```

Reports whether is known key.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L269)

<a id="function-function-mlc-project-join-function-join-a-b-mlc-project-ml-1487255859"></a>
### _join

```ml
function _join(a, b)
```

Implements join.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `a` | `dynamic` | — |  |
| `b` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L121)

<a id="function-function-mlc-project-object-cache-dir-function-object-cache-dir-pb-digest-mlc-project-ml-1184984058"></a>
### _object_cache_dir

```ml
function _object_cache_dir(pb, digest)
```

Implements object cache dir.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pb` | `dynamic` | — |  |
| `digest` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L849)

<a id="function-function-mlc-project-parse-string-array-function-parse-string-array-value-mlc-project-ml-804613051"></a>
### _parse_string_array

```ml
function _parse_string_array(value)
```

Returns parse string array.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L225)

<a id="function-function-mlc-project-path-key-function-path-key-path-mlc-project-ml-1639727953"></a>
### _path_key

```ml
function _path_key(path)
```

Windows paths are case-insensitive; POSIX paths must retain exact spelling.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L445)

<a id="function-function-mlc-project-project-u32le-function-project-u32le-value-offset-mlc-project-ml-2074318368"></a>
### _project_u32le

```ml
function _project_u32le(value, offset)
```

Implements project u32le.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |
| `offset` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L698)

<a id="function-function-mlc-project-project-word-char-function-project-word-char-source-index-mlc-project-ml-2072998205"></a>
### _project_word_char

```ml
function _project_word_char(source, index)
```

Implements project word char.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L530)

<a id="function-function-mlc-project-quoted-import-paths-function-quoted-import-paths-source-mlc-project-ml-1344714487"></a>
### _quoted_import_paths

```ml
function _quoted_import_paths(source)
```

Extract quoted import paths without treating strings or comments as source. False positives would only make the cache more conservative; misses could return stale code, so comments between the keyword and path are supported.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L582)

<a id="function-function-mlc-project-relative-path-function-relative-path-base-value-mlc-project-ml-1890277016"></a>
### _relative_path

```ml
function _relative_path(base, value)
```

Implements relative path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `base` | `dynamic` | — |  |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L190)

<a id="function-function-mlc-project-skip-import-trivia-function-skip-import-trivia-source-index-mlc-project-ml-141654301"></a>
### _skip_import_trivia

```ml
function _skip_import_trivia(source, index)
```

Advance past whitespace and comments between the import keyword and path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L538)

<a id="function-function-mlc-project-skip-project-string-function-skip-project-string-source-index-mlc-project-ml-2029185969"></a>
### _skip_project_string

```ml
function _skip_project_string(source, index)
```

Implements skip project string.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `dynamic` | — |  |
| `index` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L567)

<a id="function-function-mlc-project-string-less-function-string-less-left-right-mlc-project-ml-2012463843"></a>
### _string_less

```ml
function _string_less(left, right)
```

Implements string less.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — |  |
| `right` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L677)

<a id="function-function-mlc-project-unquote-function-unquote-value-mlc-project-ml-2065359739"></a>
### _unquote

```ml
function _unquote(value)
```

Implements unquote.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L214)

<a id="function-function-mlc-project-valid-define-name-function-valid-define-name-name-mlc-project-ml-1269587149"></a>
### _valid_define_name

```ml
function _valid_define_name(name)
```

Implements valid define name.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L275)

<a id="function-function-mlc-project-valid-define-value-function-valid-define-value-value-mlc-project-ml-812173753"></a>
### _valid_define_value

```ml
function _valid_define_value(value)
```

Implements valid define value.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L290)

<a id="function-function-mlc-project-valid-project-digest-function-valid-project-digest-value-mlc-project-ml-928786795"></a>
### _valid_project_digest

```ml
function _valid_project_digest(value)
```

Implements valid project digest.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L738)

<a id="extern_function-extern-function-mlc-project-createdirectoryw-extern-function-createdirectoryw-path-as-wstr-securityattributes-as-ptr-from-kernel32-dll-returns-bool-mlc-project-ml-1626609254"></a>
### CreateDirectoryW

```ml
extern function CreateDirectoryW(path as wstr, securityAttributes as ptr) from "kernel32.dll" returns bool
```

Creates create directory w.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `wstr` | — |  |
| `securityAttributes` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L40)

<a id="function-function-mlc-project-ensureoutputdirectory-function-ensureoutputdirectory-output-path-mlc-project-ml-196881123"></a>
### ensureOutputDirectory

```ml
function ensureOutputDirectory(output_path)
```

Create the parent directory required by a configured output path.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `output_path` | `dynamic` | — | Value supplied for `output_path`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L1019)

<a id="function-function-mlc-project-expandargs-function-expandargs-args-mlc-project-ml-1114332615"></a>
### expandArgs

```ml
function expandArgs(args)
```

Replace --project arguments with validated ordinary compiler arguments.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — | Command-line or call arguments. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L308)

<a id="function-function-mlc-project-fingerprint-function-fingerprint-pb-input-path-include-dirs-mlc-project-ml-1921258819"></a>
### fingerprint

```ml
function fingerprint(pb, input_path, include_dirs)
```

Hash the manifest, effective arguments and all broad-root/imported sources. The broad set is intentionally conservative: changing a currently inactive conditional import must still invalidate the cache.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pb` | `dynamic` | — | Value supplied for `pb`. |
| `input_path` | `dynamic` | — | Value supplied for `input_path`. |
| `include_dirs` | `dynamic` | — | Value supplied for `include_dirs`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L771)

<a id="extern_function-extern-function-mlc-project-getfileattributesw-extern-function-getfileattributesw-path-as-wstr-from-kernel32-dll-returns-u32-mlc-project-ml-636884157"></a>
### GetFileAttributesW

```ml
extern function GetFileAttributesW(path as wstr) from "kernel32.dll" returns u32
```

Returns get file attributes w.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `wstr` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L37)

<a id="extern_function-extern-function-mlc-project-getfullpathnamew-extern-function-getfullpathnamew-path-as-wstr-bufferlen-as-u32-buffer-as-buffer-filepart-as-ptr-from-kernel32-dll-returns-u32-mlc-project-ml-1571675165"></a>
### GetFullPathNameW

```ml
extern function GetFullPathNameW(path as wstr, bufferLen as u32, buffer as buffer, filePart as ptr) from "kernel32.dll" returns u32
```

Returns get full path name w.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `path` | `wstr` | — |  |
| `bufferLen` | `u32` | — |  |
| `buffer` | `buffer` | — |  |
| `filePart` | `ptr` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L34)

<a id="extern_function-extern-function-mlc-project-movefileexw-extern-function-movefileexw-source-as-wstr-destination-as-wstr-flags-as-u32-from-kernel32-dll-returns-bool-mlc-project-ml-1805939892"></a>
### MoveFileExW

```ml
extern function MoveFileExW(source as wstr, destination as wstr, flags as u32) from "kernel32.dll" returns bool
```

Implements move file ex w.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `source` | `wstr` | — |  |
| `destination` | `wstr` | — |  |
| `flags` | `u32` | — |  |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L43)

- [mlc.project.ProjectBuild](Type-mlc-project-projectbuild-645380487.md) — struct
- [mlc.project.ProjectExpansion](Type-mlc-project-projectexpansion-663805966.md) — struct
- [mlc.project.ProjectFileCollector](Type-mlc-project-projectfilecollector-1536015482.md) — struct
- [mlc.project.ProjectHash](Type-mlc-project-projecthash-1222175013.md) — struct
<a id="function-function-mlc-project-restore-function-restore-pb-digest-output-path-mlc-project-ml-1242055481"></a>
### restore

```ml
function restore(pb, digest, output_path)
```

Restore only a checksum-validated artifact from the requested generation.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pb` | `dynamic` | — | Value supplied for `pb`. |
| `digest` | `dynamic` | — | Value supplied for `digest`. |
| `output_path` | `dynamic` | — | Value supplied for `output_path`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L829)

<a id="function-function-mlc-project-restoreobjects-function-restoreobjects-pb-digest-mlc-project-ml-1176711488"></a>
### restoreObjects

```ml
function restoreObjects(pb, digest)
```

Return a complete immutable MLO set for this exact project fingerprint. Publication metadata is written last, so a crashed population is always a miss and can never feed a partial directory to the linker.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pb` | `dynamic` | — | Value supplied for `pb`. |
| `digest` | `dynamic` | — | Value supplied for `digest`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L856)

<a id="function-function-mlc-project-store-function-store-pb-digest-output-path-mlc-project-ml-1878511363"></a>
### store

```ml
function store(pb, digest, output_path)
```

Updates store.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pb` | `dynamic` | — | Value supplied for `pb`. |
| `digest` | `dynamic` | — | Value supplied for `digest`. |
| `output_path` | `dynamic` | — | Value supplied for `output_path`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L922)

<a id="function-function-mlc-project-storeobjects-function-storeobjects-pb-digest-source-dir-mlc-project-ml-833177017"></a>
### storeObjects

```ml
function storeObjects(pb, digest, source_dir)
```

Populate the flat per-fingerprint object directory and publish its state marker only after every object copy succeeds.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `pb` | `dynamic` | — | Value supplied for `pb`. |
| `digest` | `dynamic` | — | Value supplied for `digest`. |
| `source_dir` | `dynamic` | — | Value supplied for `source_dir`. |


[View source](https://github.com/MiniLangProject/MiniLangCompilerML/blob/main/mlc/project.ml#L960)
