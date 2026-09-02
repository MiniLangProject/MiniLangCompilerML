/*
Copyright 2026 Nils Kopal

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// TOML project manifests and content-validated incremental build metadata.
//! Provides the mlc project package.

package mlc.project

import std.fs as fs
import std.process as process
import std.string as s
import std.sort as sort
import std.io.file as fileio
import std.checksum.crc32 as crc32
import std.checksum.crc32c as crc32c
import mlc.tools as t

#if TARGET_OS == "windows"
/// Returns get full path name w.
/// @internal
extern function GetFullPathNameW(path as wstr, bufferLen as u32, buffer as buffer, filePart as ptr) from "kernel32.dll" returns u32
/// Returns get file attributes w.
/// @internal
extern function GetFileAttributesW(path as wstr) from "kernel32.dll" returns u32
/// Creates create directory w.
/// @internal
extern function CreateDirectoryW(path as wstr, securityAttributes as ptr) from "kernel32.dll" returns bool
/// Implements move file ex w.
/// @internal
extern function MoveFileExW(source as wstr, destination as wstr, flags as u32) from "kernel32.dll" returns bool
#else
/// Implements project mkdir.
/// @internal
extern function _project_mkdir(path as cstr, mode as u32) from "libc.so.6" symbol "mkdir" returns i32
/// Implements project stat.
/// @internal
extern function _project_stat(path as cstr, info as bytes) from "libc.so.6" symbol "stat" returns i32
/// Implements project lstat.
/// @internal
extern function _project_lstat(path as cstr, info as bytes) from "libc.so.6" symbol "lstat" returns i32
/// Implements project chmod.
/// @internal
extern function _project_chmod(path as cstr, mode as u32) from "libc.so.6" symbol "chmod" returns i32
/// Implements project rename.
/// @internal
extern function _project_rename(source as cstr, destination as cstr) from "libc.so.6" symbol "rename" returns i32
#endif

/// Expanded project configuration carried through compilation and caching.
struct ProjectBuild
  /// Stores the manifest member of `ProjectBuild`.
  manifest,
  /// Stores the cache dir member of `ProjectBuild`.
  cache_dir,
  /// Stores the incremental member of `ProjectBuild`.
  incremental,
  /// Stores the expanded args member of `ProjectBuild`.
  expanded_args,
end struct

/// Success/error envelope for command-line manifest expansion.
struct ProjectExpansion
  /// Stores the ok member of `ProjectExpansion`.
  ok,
  /// Stores the args member of `ProjectExpansion`.
  args,
  /// Stores the project member of `ProjectExpansion`.
  project,
  /// Stores the message member of `ProjectExpansion`.
  message,
end struct

/// Two-lane deterministic hash state used for cache fingerprints.
struct ProjectHash
  /// Stores the a member of `ProjectHash`.
  a,
  /// Stores the b member of `ProjectHash`.
  b,
end struct

/// Capacity-backed, indexed state for one recursive source-tree traversal.
struct ProjectFileCollector
  /// Stores the files member of `ProjectFileCollector`.
  files,
  /// Stores the seen files member of `ProjectFileCollector`.
  seen_files,
  /// Stores the seen dirs member of `ProjectFileCollector`.
  seen_dirs,
end struct

/// Implements dirname.
/// @internal
function _dirname(path)
  if typeof(path) != "string" then return "." end if
  i = len(path) - 1
  while i >= 0
    if path[i] == "\\" or path[i] == "/" then
      if i <= 0 then return "." end if
      return s.substr(path, 0, i)
    end if
    i = i - 1
  end while
  return "."
end function

/// Implements join.
/// @internal
function _join(a, b)
  if typeof(a) != "string" or a == "" or a == "." then return b end if
  if typeof(b) != "string" or b == "" then return a end if
  if a[len(a) - 1] == "\\" or a[len(a) - 1] == "/" then return a + b end if
#if TARGET_OS == "linux"
  return a + "/" + b
#else
  return a + "\\" + b
#endif
end function

/// Reports whether is abs.
/// @internal
function _is_abs(path)
  if typeof(path) != "string" then return false end if
  if len(path) >= 2 and path[1] == ":" then return true end if
  if len(path) >= 2 and path[0] == "\\" and path[1] == "\\" then return true end if
  return len(path) >= 1 and (path[0] == "\\" or path[0] == "/")
end function

/// Implements abspath.
/// @internal
function _abspath(path)
#if TARGET_OS == "linux"
  if _is_abs(path) then return _canon_linux(path) end if
  cwd = process.currentDirectory()
  if typeof(cwd) != "string" or cwd == "" then return _canon_linux(path) end if
  return _canon_linux(_join(cwd, path))
#else
  buf = bytes(8192, 0)
  n = GetFullPathNameW(path, 4096, buf, 0)
  if typeof(n) != "int" or n <= 0 then return path end if
  abs_value = decode16Z(buf)
  if typeof(abs_value) != "string" or abs_value == "" then return path end if
  return abs_value
#endif
end function

/// Normalize a POSIX path lexically so output paths need not exist yet.
/// @internal
function _canon_linux(path)
  if typeof(path) != "string" or path == "" then return "." end if
  absolute = path[0] == "/"
  parts = s.split(path, "/")
  stack = []
  for i = 0 to len(parts) - 1
    part = parts[i]
    if part == "" or part == "." then continue end if
    if part == ".." then
      if len(stack) > 0 and stack[len(stack) - 1] != ".." then
        stack = t.arr_drop_last(stack)
      else
        if absolute == false then stack = stack + [".."] end if
      end if
    else
      stack = stack + [part]
    end if
  end for
  tail = s.join(stack, "/")
  if absolute then
    if tail == "" then return "/" end if
    return "/" + tail
  end if
  if tail == "" then return "." end if
  return tail
end function

/// Implements relative path.
/// @internal
function _relative_path(base, value)
  if _is_abs(value) then return _abspath(value) end if
  return _abspath(_join(base, value))
end function

/// Implements ensure dir.
/// @internal
function _ensure_dir(path)
  if typeof(path) != "string" or path == "" or path == "." then return true end if
  if fs.exists(path) then return fs.isDir(path) end if
  parent = _dirname(path)
  if parent != path and parent != "." then
    if _ensure_dir(parent) == false then return false end if
  end if
#if TARGET_OS == "linux"
  if _project_mkdir(path, 493) == 0 then return true end if
#else
  if CreateDirectoryW(path, 0) then return true end if
#endif
  return fs.isDir(path)
end function

/// Implements unquote.
/// @internal
function _unquote(value)
  value = s.trim(value)
  if len(value) < 2 or value[0] != "\"" or value[len(value) - 1] != "\"" then return error(1, "expected quoted string") end if
  value = s.substr(value, 1, len(value) - 2)
  value = s.replaceAll(value, "\\\"", "\"")
  value = s.replaceAll(value, "\\\\", "\\")
  return value
end function

/// Returns parse string array.
/// @internal
function _parse_string_array(value)
  value = s.trim(value)
  if len(value) < 2 or value[0] != "[" or value[len(value) - 1] != "]" then return error(1, "expected array of strings") end if
  inner = s.trim(s.substr(value, 1, len(value) - 2))
  if inner == "" then return [] end if
  result_items = t.arr_vec_new(8)
  i = 0
  while i < len(inner)
    while i < len(inner) and (inner[i] == " " or inner[i] == "\t" or inner[i] == "\r" or inner[i] == "\n")
      i = i + 1
    end while
    if i >= len(inner) or inner[i] != "\"" then return error(1, "expected quoted string") end if
    start = i
    i = i + 1
    escaped = false
    while i < len(inner)
      if escaped then
        escaped = false
      else if inner[i] == "\\" then
        escaped = true
      else if inner[i] == "\"" then
        break
      end if
      i = i + 1
    end while
    if i >= len(inner) or inner[i] != "\"" then return error(1, "unterminated quoted string") end if
    item = _unquote(s.substr(inner, start, i - start + 1))
    if typeof(item) == "error" then return item end if
    result_items = t.arr_vec_push(result_items, item)
    i = i + 1
    while i < len(inner) and (inner[i] == " " or inner[i] == "\t" or inner[i] == "\r" or inner[i] == "\n")
      i = i + 1
    end while
    if i < len(inner) then
      if inner[i] != "," then return error(1, "expected comma between strings") end if
      i = i + 1
      if i >= len(inner) then return error(1, "trailing comma is not supported in project arrays") end if
    end if
  end while
  return t.arr_vec_finish(result_items)
end function

/// Reports whether is known key.
/// @internal
function _is_known_key(key)
  return key == "entry" or key == "input" or key == "output" or key == "include" or key == "import_paths" or key == "subsystem" or key == "target" or key == "object_pipeline" or key == "incremental" or key == "cache_dir" or key == "compiler_args"
end function

/// Implements valid define name.
/// @internal
function _valid_define_name(name)
  if typeof(name) != "string" or len(name) <= 0 then return false end if
  first = bytes(name[0])[0]
  if ((first >= 65 and first <= 90) or (first >= 97 and first <= 122) or first == 95) == false then return false end if
  if len(name) > 1 then
    for i = 1 to len(name) - 1
      c = bytes(name[i])[0]
      if ((c >= 65 and c <= 90) or (c >= 97 and c <= 122) or (c >= 48 and c <= 57) or c == 95) == false then return false end if
    end for
  end if
  return true
end function

/// Implements valid define value.
/// @internal
function _valid_define_value(value)
  value = s.trim(value)
  if value == "true" or value == "false" then return true end if
  if len(value) >= 2 and value[0] == "\"" and value[len(value) - 1] == "\"" then
    return typeof(_unquote(value)) == "string"
  end if
  if value == "" then return false end if
  i = 0
  if value[0] == "-" then
    if len(value) <= 1 then return false end if
    i = 1
  end if
  c = bytes(value[i])[0]
  return c >= 48 and c <= 57
end function

/// Replace --project arguments with validated ordinary compiler arguments.
/// @param args Command-line or call arguments.
function expandArgs(args)
  if typeof(args) != "array" or len(args) < 1 or args[0] != "--project" then
    return ProjectExpansion(true, args, void, "")
  end if
  if len(args) < 2 then return ProjectExpansion(false, [], void, "--project expects a TOML manifest path") end if
  manifest = _abspath(args[1])
  if fs.isFile(manifest) == false then return ProjectExpansion(false, [], void, "project manifest not found: " + manifest) end if
  text = fs.readAllText(manifest)
  if typeof(text) == "error" then return ProjectExpansion(false, [], void, "cannot read project manifest: " + manifest) end if

  entry = ""
  output = ""
  include_dirs = []
  subsystem = ""
  target = ""
  object_pipeline = false
  object_pipeline_set = false
  incremental = true
  cache_dir_value = ".minilang-cache"
  compiler_args = []
  define_args = []
  in_project = false
  in_defines = false
  lines = s.split(text, "\n")
  for li = 0 to len(lines) - 1
    line = s.trim(lines[li])
    if line == "" or line[0] == "#" then continue end if
    if line[0] == "[" then
      in_project = line == "[project]"
      in_defines = line == "[defines]"
      continue
    end if
    eq = s.indexOf(line, "=", 0)
    if in_project == false and in_defines == false then continue end if
    if typeof(eq) != "int" or eq <= 0 then return ProjectExpansion(false, [], void, "invalid project line " + (li + 1)) end if
    key = s.trim(s.substr(line, 0, eq))
    value = s.trim(s.substr(line, eq + 1, len(line) - eq - 1))
    if in_defines then
      if _valid_define_name(key) == false then return ProjectExpansion(false, [], void, "invalid compile definition name: " + key) end if
      if _valid_define_value(value) == false then return ProjectExpansion(false, [], void, "compile definition " + key + " must be bool, int, or string") end if
      define_args = define_args + ["-D", key + "=" + value]
      continue
    end if
    if _is_known_key(key) == false then return ProjectExpansion(false, [], void, "unknown project field: " + key) end if
    if key == "entry" or key == "input" then
      entry = _unquote(value)
      if typeof(entry) == "error" then return ProjectExpansion(false, [], void, "entry must be a quoted string") end if
    else if key == "output" then
      output = _unquote(value)
      if typeof(output) == "error" then return ProjectExpansion(false, [], void, "output must be a quoted string") end if
    else if key == "include" or key == "import_paths" then
      include_dirs = _parse_string_array(value)
      if typeof(include_dirs) == "error" then return ProjectExpansion(false, [], void, "include must be an array of strings") end if
    else if key == "subsystem" then
      subsystem = _unquote(value)
      if typeof(subsystem) == "error" then return ProjectExpansion(false, [], void, "subsystem must be a quoted string") end if
    else if key == "target" then
      target = _unquote(value)
      if typeof(target) == "error" then return ProjectExpansion(false, [], void, "target must be a quoted string") end if
    else if key == "cache_dir" then
      cache_dir_value = _unquote(value)
      if typeof(cache_dir_value) == "error" then return ProjectExpansion(false, [], void, "cache_dir must be a quoted string") end if
    else if key == "compiler_args" then
      compiler_args = _parse_string_array(value)
      if typeof(compiler_args) == "error" then return ProjectExpansion(false, [], void, "compiler_args must be an array of strings") end if
    else if key == "object_pipeline" then
      if value != "true" and value != "false" then return ProjectExpansion(false, [], void, "object_pipeline must be true or false") end if
      object_pipeline = value == "true"
      object_pipeline_set = true
    else if key == "incremental" then
      if value != "true" and value != "false" then return ProjectExpansion(false, [], void, "incremental must be true or false") end if
      incremental = value == "true"
    end if
  end for
  if entry == "" then return ProjectExpansion(false, [], void, "project field 'entry' is required") end if
  if output == "" then return ProjectExpansion(false, [], void, "project field 'output' is required") end if

  base = _dirname(manifest)
  expanded = [_relative_path(base, entry), _relative_path(base, output)]
  if len(include_dirs) > 0 then
    for ii = 0 to len(include_dirs) - 1
      expanded = expanded + ["-I", _relative_path(base, include_dirs[ii])]
    end for
  end if
  if subsystem != "" then expanded = expanded + ["--subsystem", subsystem] end if
  if target != "" then expanded = expanded + ["--target", target] end if
  if object_pipeline_set then
    if object_pipeline then
      expanded = expanded + ["--object-pipeline"]
    else
      expanded = expanded + ["--no-object-pipeline"]
    end if
  end if
  if len(define_args) > 0 then expanded = expanded + define_args end if
  if len(compiler_args) > 0 then expanded = expanded + compiler_args end if
  if len(args) > 2 then
    for ai = 2 to len(args) - 1
      if args[ai] == "--no-incremental" then
        incremental = false
      else
        expanded = expanded + [args[ai]]
      end if
    end for
  end if
  cache_dir = _relative_path(base, cache_dir_value)
  pb = ProjectBuild(manifest, cache_dir, incremental, expanded)
  return ProjectExpansion(true, expanded, pb, "")
end function

/// Reports whether hash byte.
/// @internal
function _hash_byte(h, value)
  h.a = ((h.a ^ value) * 16777619) & 0xFFFFFFFF
  h.b = ((h.b + value + 1) * 2246822519) & 0xFFFFFFFF
  return h
end function

/// Reports whether hash bytes.
/// @internal
function _hash_bytes(h, value)
  if typeof(value) != "bytes" then return h end if
  if len(value) <= 0 then return h end if
  for i = 0 to len(value) - 1
    h = _hash_byte(h, value[i])
  end for
  return h
end function

/// Reports whether hash text.
/// @internal
function _hash_text(h, value)
  if typeof(value) != "string" then value = "" + value end if
  return _hash_bytes(h, bytes(value))
end function

/// Windows paths are case-insensitive; POSIX paths must retain exact spelling.
/// @internal
function _path_key(path)
#if TARGET_OS == "linux"
  return path
#else
  return s.toLowerAscii(path)
#endif
end function

/// Broad source-root discovery deliberately does not descend into directory links. This matches Python Path.rglob(), bounds traversal, and prevents a junction/symlink cycle from manufacturing endlessly different lexical paths. Explicitly imported files still follow their exact path in the second pass.
/// @internal
function _is_directory_link(path)
#if TARGET_OS == "windows"
  attributes = GetFileAttributesW(path)
  if attributes == 0xFFFFFFFF then return false end if
  return (attributes & 0x10) != 0 and (attributes & 0x400) != 0
#else
  info = bytes(144, 0)
  if _project_lstat(path, info) != 0 then return false end if
  mode = _project_u32le(info, 24)
  return (mode & 61440) == 40960 and fs.isDir(path)
#endif
end function

/// Collect every MiniLang source below a root once. Indexed directory/file sets make overlapping include roots linear instead of repeatedly deduplicating immutable arrays.
/// @internal
function _collect_ml_files_inner(path, excluded, collector, follow_directory_link)
  if typeof(path) != "string" or path == "" then return collector end if
  // fingerprint() makes every root absolute before traversal. Children joined
  // below therefore remain absolute; repeating lexical normalization for every
  // directory entry adds syscall overhead without changing the key.
  absolute = path
  path_key = _path_key(absolute)
  if path_key == _path_key(excluded) then return collector end if
  if fs.isFile(absolute) then
    if s.endsWith(s.toLowerAscii(absolute), ".ml") and t.fastmap_has(collector.seen_files, path_key) == false then
      collector.seen_files = t.fastmap_set(collector.seen_files, path_key, 1)
      collector.files = t.arr_vec_push(collector.files, absolute)
    end if
    return collector
  end if
  if fs.isDir(absolute) == false then return collector end if
  if follow_directory_link == false and _is_directory_link(absolute) then return collector end if
  if t.fastmap_has(collector.seen_dirs, path_key) then return collector end if
  collector.seen_dirs = t.fastmap_set(collector.seen_dirs, path_key, 1)
  names = fs.listDir(absolute)
  if typeof(names) != "array" or len(names) <= 0 then return collector end if
  for i = 0 to len(names) - 1
    name = names[i]
    low = s.toLowerAscii(name)
    if low == ".git" or low == "__pycache__" then continue end if
    collector = _collect_ml_files_inner(_join(absolute, name), excluded, collector, false)
  end for
  return collector
end function

/// Implements collect ml files.
/// @internal
function _collect_ml_files(path, excluded, collector)
  // An explicitly configured root may itself be a link; only links discovered
  // below that root are skipped, matching Path.rglob's root behavior.
  return _collect_ml_files_inner(path, excluded, collector, true)
end function

/// Updates append unique path.
/// @internal
function _append_unique_path(paths, path)
#if TARGET_OS == "linux"
  key = path
#else
  key = s.toLowerAscii(path)
#endif
  if len(paths) > 0 then
    for i = 0 to len(paths) - 1
#if TARGET_OS == "linux"
      if paths[i] == key then return paths end if
#else
      if s.toLowerAscii(paths[i]) == key then return paths end if
#endif
    end for
  end if
  return paths + [path]
end function

/// Implements project word char.
/// @internal
function _project_word_char(source, index)
  if index < 0 or index >= len(source) then return false end if
  value = bytes(source[index])[0]
  return (value >= 65 and value <= 90) or (value >= 97 and value <= 122) or (value >= 48 and value <= 57) or value == 95
end function

/// Advance past whitespace and comments between the import keyword and path.
/// @internal
function _skip_import_trivia(source, index)
  i = index
  while i < len(source)
    if source[i] == " " or source[i] == "\t" or source[i] == "\r" or source[i] == "\n" then
      i = i + 1
      continue
    end if
    if i + 1 < len(source) and source[i] == "/" and source[i + 1] == "/" then
      i = i + 2
      while i < len(source) and source[i] != "\n"
        i = i + 1
      end while
      continue
    end if
    if i + 1 < len(source) and source[i] == "/" and source[i + 1] == "*" then
      i = i + 2
      while i + 1 < len(source) and (source[i] != "*" or source[i + 1] != "/")
        i = i + 1
      end while
      if i + 1 < len(source) then i = i + 2 else i = len(source) end if
      continue
    end if
    break
  end while
  return i
end function

/// Implements skip project string.
/// @internal
function _skip_project_string(source, index)
  i = index + 1
  while i < len(source)
    if source[i] == "\\" then
      i = i + 2
      continue
    end if
    if source[i] == "\"" then return i + 1 end if
    i = i + 1
  end while
  return len(source)
end function

/// Extract quoted import paths without treating strings or comments as source. False positives would only make the cache more conservative; misses could return stale code, so comments between the keyword and path are supported.
/// @internal
function _quoted_import_paths(source)
  result = t.arr_vec_new(16)
  i = 0
  while i < len(source)
    if i + 1 < len(source) and source[i] == "/" and source[i + 1] == "/" then
      i = _skip_import_trivia(source, i)
      continue
    end if
    if i + 1 < len(source) and source[i] == "/" and source[i + 1] == "*" then
      i = _skip_import_trivia(source, i)
      continue
    end if
    if source[i] == "\"" then
      i = _skip_project_string(source, i)
      continue
    end if
    if i + 6 <= len(source) and s.substr(source, i, 6) == "import" and not _project_word_char(source, i - 1) and not _project_word_char(source, i + 6) then
      path_start = _skip_import_trivia(source, i + 6)
      if path_start < len(source) and source[path_start] == "\"" then
        path_end = _skip_project_string(source, path_start)
        if path_end > path_start + 1 and path_end <= len(source) and source[path_end - 1] == "\"" then
          value = _unquote(s.substr(source, path_start, path_end - path_start))
          if typeof(value) == "string" then result = t.arr_vec_push(result, value) end if
        end if
        i = path_end
        continue
      end if
    end if
    i = i + 1
  end while
  return t.arr_vec_finish(result)
end function

/// Implements collector add import file.
/// @internal
function _collector_add_import_file(collector, path, excluded)
  absolute = _abspath(path)
  key = _path_key(absolute)
  excluded_key = _path_key(excluded)
#if TARGET_OS == "linux"
  separator = "/"
#else
  separator = "\\"
#endif
  if key == excluded_key or s.startsWith(key, excluded_key + separator) then return collector end if
  if fs.isFile(absolute) and t.fastmap_has(collector.seen_files, key) == false then
    collector.seen_files = t.fastmap_set(collector.seen_files, key, 1)
    collector.files = t.arr_vec_push(collector.files, absolute)
  end if
  return collector
end function

/// Broad root traversal covers inactive package imports. This second pass follows quoted imports recursively so absolute and parent-relative imports outside those roots also participate in the exact cache fingerprint.
/// @internal
function _collect_import_dependencies(collector, include_dirs, excluded)
  scan_index = 0
  while scan_index < t.arr_vec_count(collector.files)
    importer = t.arr_vec_get(collector.files, scan_index, "")
    scan_index = scan_index + 1
    source = fs.readAllText(importer)
    if typeof(source) != "string" then continue end if
    requests = _quoted_import_paths(source)
    if len(requests) <= 0 then continue end if
    for request_index = 0 to len(requests) - 1
      requested = requests[request_index]
      if _is_abs(requested) then
        collector = _collector_add_import_file(collector, requested, excluded)
      else
        collector = _collector_add_import_file(collector, _join(_dirname(importer), requested), excluded)
        if typeof(include_dirs) == "array" and len(include_dirs) > 0 then
          for include_index = 0 to len(include_dirs) - 1
            collector = _collector_add_import_file(collector, _join(include_dirs[include_index], requested), excluded)
          end for
        end if
      end if
    end for
  end while
  return collector
end function

/// Implements hex32.
/// @internal
function _hex32(value)
  digits = "0123456789ABCDEF"
  hex_value = ""
  shift = 28
  while shift >= 0
    hex_value = hex_value + digits[(value >> shift) & 15]
    shift = shift - 4
  end while
  return hex_value
end function

/// Implements string less.
/// @internal
function _string_less(left, right)
#if TARGET_OS == "linux"
  left_bytes = bytes(left)
  right_bytes = bytes(right)
#else
  left_bytes = bytes(s.toLowerAscii(left))
  right_bytes = bytes(s.toLowerAscii(right))
#endif
  count = len(left_bytes)
  if len(right_bytes) < count then count = len(right_bytes) end if
  if count > 0 then
    for i = 0 to count - 1
      if left_bytes[i] < right_bytes[i] then return true end if
      if left_bytes[i] > right_bytes[i] then return false end if
    end for
  end if
  return len(left_bytes) < len(right_bytes)
end function

/// Implements project u32le.
/// @internal
function _project_u32le(value, offset)
  return value[offset] | (value[offset + 1] << 8) | (value[offset + 2] << 16) | (value[offset + 3] << 24)
end function

/// Two native CRC polynomials plus the exact length provide a fast bounded- memory content identity. Native checksum instructions avoid interpreting every byte in MiniLang when hashing the 50+ MiB compiler executable.
/// @internal
function _file_content_id_with_buffer(path, buffer)
  if typeof(buffer) != "bytes" or len(buffer) <= 0 then return error(1, "invalid cache hash buffer") end if
  file = fileio.openRead(path)
  if typeof(file) == "error" then return file end if
  count = fileio.size(file)
  if typeof(count) == "error" then ignored = fileio.close(file); return count end if
  offset = 0
  ieee = 0
  castagnoli = 0
  while offset < count
    requested = count - offset
    if requested > len(buffer) then requested = len(buffer) end if
    actual = fileio.readAt(file, offset, buffer, 0, requested)
    if typeof(actual) == "error" or actual <= 0 then
      ignored = fileio.close(file)
      return error(1, "failed to hash cache file")
    end if
    ieee = crc32.update(ieee, buffer, 0, actual)
    castagnoli = crc32c.update(castagnoli, buffer, 0, actual)
    offset = offset + actual
  end while
  closed = fileio.close(file)
  if typeof(closed) == "error" then return closed end if
  return count + ":" + _hex32(ieee) + ":" + _hex32(castagnoli)
end function

/// Single-artifact callers retain the simple API; object-set validation reuses one scratch buffer across every file to avoid one 1-MiB allocation per MLO.
/// @internal
function _file_content_id(path)
  return _file_content_id_with_buffer(path, bytes(1048576, 0))
end function

/// Implements valid project digest.
/// @internal
function _valid_project_digest(value)
  if typeof(value) != "string" or len(value) != 16 then return false end if
  for i = 0 to len(value) - 1
    ch = bytes(value[i])[0]
    if not ((ch >= 48 and ch <= 57) or (ch >= 65 and ch <= 70)) then return false end if
  end for
  return true
end function

/// Implements cache artifact path.
/// @internal
function _cache_artifact_path(pb, digest)
  return _join(pb.cache_dir, "build." + digest + ".exe")
end function

/// Std.fs.copyFile intentionally copies bytes only. Cache artifacts additionally retain their POSIX mode so a native Linux cache hit remains executable.
/// @internal
function _copy_file_preserve_mode(source_path, destination_path)
  copied = fs.copyFile(source_path, destination_path, true)
  if typeof(copied) == "error" then return copied end if
#if TARGET_OS == "linux"
  attr = bytes(144, 0)
  if _project_stat(source_path, attr) != 0 then return error(1, "failed to read cached file mode") end if
  mode = _project_u32le(attr, 24) & 4095
  if _project_chmod(destination_path, mode) != 0 then return error(1, "failed to preserve cached file mode") end if
#endif
  return true
end function

/// Hash the manifest, effective arguments and all broad-root/imported sources. The broad set is intentionally conservative: changing a currently inactive conditional import must still invalidate the cache.
/// @param pb Value supplied for `pb`.
/// @param input_path Value supplied for `input_path`.
/// @param include_dirs Value supplied for `include_dirs`.
function fingerprint(pb, input_path, include_dirs)
  h = ProjectHash(2166136261, 3266489917)
  h = _hash_text(h, "MiniLang-project-cache-v2")
  for ai = 0 to len(pb.expanded_args) - 1
    h = _hash_byte(h, 0)
    h = _hash_text(h, pb.expanded_args[ai])
  end for
  if typeof(pb.manifest) == "string" and pb.manifest != "" then
    manifest_bytes = fs.readAllBytes(pb.manifest)
    if typeof(manifest_bytes) == "error" then return manifest_bytes end if
    h = _hash_bytes(h, manifest_bytes)
  end if

  roots = [_dirname(input_path)]
  if typeof(include_dirs) == "array" and len(include_dirs) > 0 then
    for ri = 0 to len(include_dirs) - 1
      roots = _append_unique_path(roots, include_dirs[ri])
    end for
  end if
  collector = ProjectFileCollector(t.arr_vec_new(256), t.fastmap_new(512), t.fastmap_new(256))
  for ri = 0 to len(roots) - 1
    collector = _collect_ml_files(roots[ri], pb.cache_dir, collector)
  end for
  collector = _collect_import_dependencies(collector, include_dirs, pb.cache_dir)
  unique_files = t.arr_vec_finish(collector.files)
  unique_files = sort.sortBy(unique_files, _string_less)
  if len(unique_files) > 0 then
    for fi = 0 to len(unique_files) - 1
      data = fs.readAllBytes(unique_files[fi])
      if typeof(data) == "error" then return data end if
      h = _hash_byte(h, 0)
#if TARGET_OS == "linux"
      h = _hash_text(h, unique_files[fi])
#else
      h = _hash_text(h, s.toLowerAscii(unique_files[fi]))
#endif
      h = _hash_byte(h, 0)
      h = _hash_bytes(h, data)
    end for
  end if

  // Compiler identity is content-based. Size/mtime alone can survive release
  // replacement tools which preserve metadata and would then restore stale code.
  exe_path = process.executablePath()
  if typeof(exe_path) == "string" and exe_path != "" then
    compiler_id = _file_content_id(exe_path)
    if typeof(compiler_id) == "error" then return compiler_id end if
    h = _hash_text(h, _path_key(exe_path))
    h = _hash_byte(h, 0)
    h = _hash_text(h, compiler_id)
  end if
  return _hex32(h.a) + _hex32(h.b)
end function

/// Restore only a checksum-validated artifact from the requested generation.
/// @param pb Value supplied for `pb`.
/// @param digest Value supplied for `digest`.
/// @param output_path Value supplied for `output_path`.
function restore(pb, digest, output_path)
  if typeof(pb) != "struct" or pb.incremental == false then return false end if
  state_path = _join(pb.cache_dir, "build.state")
  artifact_path = _cache_artifact_path(pb, digest)
  if fs.isFile(state_path) == false or fs.isFile(artifact_path) == false then return false end if
  state = fs.readAllText(state_path)
  if typeof(state) != "string" then return false end if
  state_lines = s.split(state, "\n")
  if len(state_lines) < 2 or s.trim(state_lines[0]) != digest then return false end if
  expected_artifact_id = s.trim(state_lines[1])
  if expected_artifact_id == "" then return false end if
  artifact_id = _file_content_id(artifact_path)
  if typeof(artifact_id) != "string" or artifact_id != expected_artifact_id then return false end if
  if _ensure_dir(_dirname(output_path)) == false then return false end if
  copied = _copy_file_preserve_mode(artifact_path, output_path)
  return typeof(copied) != "error"
end function

/// Implements object cache dir.
/// @internal
function _object_cache_dir(pb, digest)
  return _join(_join(pb.cache_dir, "objects"), digest)
end function

/// Return a complete immutable MLO set for this exact project fingerprint. Publication metadata is written last, so a crashed population is always a miss and can never feed a partial directory to the linker.
/// @param pb Value supplied for `pb`.
/// @param digest Value supplied for `digest`.
function restoreObjects(pb, digest)
  if typeof(pb) != "struct" or pb.incremental == false then return "" end if
  obj_dir = _object_cache_dir(pb, digest)
  state_path = _join(obj_dir, "objects.state")
  if fs.isFile(state_path) == false then return "" end if
  state = fs.readAllText(state_path)
  if typeof(state) != "string" then return "" end if
  state_lines = s.split(state, "\n")
  // Version two pairs every canonical filename with its bounded-memory content
  // identity. Older name-only manifests are treated as misses and rebuilt.
  if len(state_lines) < 4 or s.trim(state_lines[0]) != digest or s.trim(state_lines[1]) != "MLO-CACHE-2" then return "" end if
  expected_names = []
  expected_ids = []
  si = 2
  while si + 1 < len(state_lines)
    expected_name = s.trim(state_lines[si])
    if expected_name == "" then break end if
    expected_id = s.trim(state_lines[si + 1])
    if expected_id == "" then return "" end if
    expected_names = expected_names + [expected_name]
    expected_ids = expected_ids + [expected_id]
    si = si + 2
  end while
  if len(expected_names) <= 0 or len(expected_names) != len(expected_ids) then return "" end if
  names = fs.listDir(obj_dir)
  if typeof(names) != "array" then return "" end if
  mlo_names = []
  mlo_count = 0
  support_count = 0
  for i = 0 to len(names) - 1
    name = names[i]
    if typeof(name) != "string" or s.endsWith(s.toLowerAscii(name), ".mlo") == false then continue end if
    if fs.isFile(_join(obj_dir, name)) == false then return "" end if
    mlo_names = mlo_names + [name]
    mlo_count = mlo_count + 1
    if s.endsWith(s.toLowerAscii(name), "_support.mlo") then support_count = support_count + 1 end if
  end for
  mlo_names = sort.sortBy(mlo_names, _string_less)
  if mlo_count <= 0 or support_count != 1 then return "" end if
  if len(expected_names) != len(mlo_names) then return "" end if
  content_buffer = bytes(1048576, 0)
  for ni = 0 to len(mlo_names) - 1
    if expected_names[ni] != mlo_names[ni] then return "" end if
    actual_id = _file_content_id_with_buffer(_join(obj_dir, mlo_names[ni]), content_buffer)
    if typeof(actual_id) != "string" or actual_id != expected_ids[ni] then return "" end if
  end for
  return obj_dir
end function

/// Atomically update the cached artifact and its validation metadata.
/// @internal
function _atomic_replace(source_path, destination_path)
#if TARGET_OS == "windows"
  // REPLACE_EXISTING | WRITE_THROUGH publishes the completed temporary file
  // as one durable directory-entry update.
  if MoveFileExW(source_path, destination_path, 9) then return true end if
#else
  if _project_rename(source_path, destination_path) == 0 then return true end if
#endif
  return error(1, "failed to atomically publish cache file")
end function

/// Updates store.
/// @param pb Value supplied for `pb`.
/// @param digest Value supplied for `digest`.
/// @param output_path Value supplied for `output_path`.
function store(pb, digest, output_path)
  if typeof(pb) != "struct" or pb.incremental == false then return true end if
  if _ensure_dir(pb.cache_dir) == false then return error(1, "failed to create project cache directory") end if
  artifact_path = _cache_artifact_path(pb, digest)
  state_path = _join(pb.cache_dir, "build.state")
  suffix = "." + process.id() + ".tmp"
  artifact_tmp = artifact_path + suffix
  state_tmp = state_path + suffix
  old_digest = ""
  if fs.isFile(state_path) then
    old_state = fs.readAllText(state_path)
    if typeof(old_state) == "string" then
      old_lines = s.split(old_state, "\n")
      if len(old_lines) > 0 then old_digest = s.trim(old_lines[0]) end if
    end if
  end if
  copied = _copy_file_preserve_mode(output_path, artifact_tmp)
  if typeof(copied) == "error" then return copied end if
  artifact_id = _file_content_id(artifact_tmp)
  if typeof(artifact_id) == "error" then return artifact_id end if
  written = fs.writeAllText(state_tmp, digest + "\n" + artifact_id + "\n")
  if typeof(written) == "error" then return written end if
  moved_artifact = _atomic_replace(artifact_tmp, artifact_path)
  if typeof(moved_artifact) == "error" then return moved_artifact end if
  // Content-addressed generations keep the previous state's artifact valid
  // until this final atomic pointer publication succeeds.
  moved_state = _atomic_replace(state_tmp, state_path)
  if typeof(moved_state) == "error" then return moved_state end if
  if old_digest != digest and _valid_project_digest(old_digest) then
    ignored_delete = fs.delete(_cache_artifact_path(pb, old_digest))
  end if
  return true
end function

/// Populate the flat per-fingerprint object directory and publish its state marker only after every object copy succeeds.
/// @param pb Value supplied for `pb`.
/// @param digest Value supplied for `digest`.
/// @param source_dir Value supplied for `source_dir`.
function storeObjects(pb, digest, source_dir)
  if typeof(pb) != "struct" or pb.incremental == false then return true end if
  if fs.isDir(source_dir) == false then return error(1, "object source directory does not exist") end if
  objects_root = _join(pb.cache_dir, "objects")
  obj_dir = _object_cache_dir(pb, digest)
  if _ensure_dir(pb.cache_dir) == false or _ensure_dir(objects_root) == false or _ensure_dir(obj_dir) == false then
    return error(1, "failed to create project object cache directory")
  end if

  // Clear an earlier unpublished attempt for the same content key. Complete
  // entries return before this function is called and are never rewritten.
  old_names = fs.listDir(obj_dir)
  if typeof(old_names) == "array" and len(old_names) > 0 then
    for oi = 0 to len(old_names) - 1
      old_path = _join(obj_dir, old_names[oi])
      if fs.isDir(old_path) == false and fs.delete(old_path) == false then
        return error(1, "failed to clear incomplete project object cache")
      end if
    end for
  end if

  names = fs.listDir(source_dir)
  if typeof(names) != "array" then return error(1, "failed to enumerate object source directory") end if
  names = sort.sortBy(names, _string_less)
  copied_count = 0
  support_count = 0
  cached_names = []
  cached_ids = []
  content_buffer = bytes(1048576, 0)
  for i = 0 to len(names) - 1
    name = names[i]
    if typeof(name) != "string" or s.endsWith(s.toLowerAscii(name), ".mlo") == false then continue end if
    source_path = _join(source_dir, name)
    if fs.isFile(source_path) == false then continue end if
    destination_path = _join(obj_dir, name)
    copied = fs.copyFile(source_path, destination_path, true)
    if typeof(copied) == "error" then return copied end if
    content_id = _file_content_id_with_buffer(destination_path, content_buffer)
    if typeof(content_id) == "error" then return content_id end if
    cached_names = cached_names + [name]
    cached_ids = cached_ids + [content_id]
    copied_count = copied_count + 1
    if s.endsWith(s.toLowerAscii(name), "_support.mlo") then support_count = support_count + 1 end if
  end for
  if copied_count <= 0 or support_count != 1 then return error(1, "object cache requires one complete support object") end if

  state_path = _join(obj_dir, "objects.state")
  state_tmp = state_path + "." + process.id() + ".tmp"
  state_text = digest + "\nMLO-CACHE-2\n"
  for ni = 0 to len(cached_names) - 1
    state_text = state_text + cached_names[ni] + "\n" + cached_ids[ni] + "\n"
  end for
  written = fs.writeAllText(state_tmp, state_text)
  if typeof(written) == "error" then return written end if
  return _atomic_replace(state_tmp, state_path)
end function

/// Create the parent directory required by a configured output path.
/// @param output_path Value supplied for `output_path`.
function ensureOutputDirectory(output_path)
  return _ensure_dir(_dirname(output_path))
end function
