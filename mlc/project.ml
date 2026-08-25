// TOML project manifests and content-validated incremental build metadata.
package mlc.project

import std.fs as fs
import std.string as s
import std.sort as sort

extern function GetFullPathNameW(path as wstr, bufferLen as u32, buffer as buffer, filePart as ptr) from "kernel32.dll" returns u32
extern function GetModuleFileNameW(module as ptr, buffer as buffer, bufferLen as u32) from "kernel32.dll" returns u32
extern function GetFileAttributesExW(path as wstr, level as int, info as bytes) from "kernel32.dll" returns bool
extern function CreateDirectoryW(path as wstr, securityAttributes as ptr) from "kernel32.dll" returns bool

// Expanded project configuration carried through compilation and caching.
struct ProjectBuild
  manifest,
  cache_dir,
  incremental,
  expanded_args,
end struct

// Success/error envelope for command-line manifest expansion.
struct ProjectExpansion
  ok,
  args,
  project,
  message,
end struct

// Two-lane deterministic hash state used for cache fingerprints.
struct ProjectHash
  a,
  b,
end struct

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

function _join(a, b)
  if typeof(a) != "string" or a == "" or a == "." then return b end if
  if typeof(b) != "string" or b == "" then return a end if
  if a[len(a) - 1] == "\\" or a[len(a) - 1] == "/" then return a + b end if
  return a + "\\" + b
end function

function _is_abs(path)
  if typeof(path) != "string" then return false end if
  if len(path) >= 2 and path[1] == ":" then return true end if
  if len(path) >= 2 and path[0] == "\\" and path[1] == "\\" then return true end if
  return len(path) >= 1 and (path[0] == "\\" or path[0] == "/")
end function

function _abspath(path)
  buf = bytes(8192, 0)
  n = GetFullPathNameW(path, 4096, buf, 0)
  if typeof(n) != "int" or n <= 0 then return path end if
  abs_value = decode16Z(buf)
  if typeof(abs_value) != "string" or abs_value == "" then return path end if
  return abs_value
end function

function _relative_path(base, value)
  if _is_abs(value) then return _abspath(value) end if
  return _abspath(_join(base, value))
end function

function _ensure_dir(path)
  if typeof(path) != "string" or path == "" or path == "." then return true end if
  if fs.exists(path) then return fs.isDir(path) end if
  parent = _dirname(path)
  if parent != path and parent != "." then
    if _ensure_dir(parent) == false then return false end if
  end if
  if CreateDirectoryW(path, 0) then return true end if
  return fs.isDir(path)
end function

function _unquote(value)
  value = s.trim(value)
  if len(value) < 2 or value[0] != "\"" or value[len(value) - 1] != "\"" then return error(1, "expected quoted string") end if
  value = s.substr(value, 1, len(value) - 2)
  value = s.replaceAll(value, "\\\"", "\"")
  value = s.replaceAll(value, "\\\\", "\\")
  return value
end function

function _parse_string_array(value)
  value = s.trim(value)
  if len(value) < 2 or value[0] != "[" or value[len(value) - 1] != "]" then return error(1, "expected array of strings") end if
  inner = s.trim(s.substr(value, 1, len(value) - 2))
  if inner == "" then return [] end if
  raw = s.split(inner, ",")
  result_items = []
  for i = 0 to len(raw) - 1
    item = _unquote(raw[i])
    if typeof(item) == "error" then return item end if
    result_items = result_items + [item]
  end for
  return result_items
end function

function _is_known_key(key)
  return key == "entry" or key == "input" or key == "output" or key == "include" or key == "import_paths" or key == "subsystem" or key == "object_pipeline" or key == "incremental" or key == "cache_dir" or key == "compiler_args"
end function

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

// Replace --project arguments with validated ordinary compiler arguments.
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
  object_pipeline = false
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
    else if key == "cache_dir" then
      cache_dir_value = _unquote(value)
      if typeof(cache_dir_value) == "error" then return ProjectExpansion(false, [], void, "cache_dir must be a quoted string") end if
    else if key == "compiler_args" then
      compiler_args = _parse_string_array(value)
      if typeof(compiler_args) == "error" then return ProjectExpansion(false, [], void, "compiler_args must be an array of strings") end if
    else if key == "object_pipeline" then
      if value != "true" and value != "false" then return ProjectExpansion(false, [], void, "object_pipeline must be true or false") end if
      object_pipeline = value == "true"
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
  if object_pipeline then expanded = expanded + ["--object-pipeline"] end if
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

function _hash_byte(h, value)
  h.a = ((h.a ^ value) * 16777619) & 0xFFFFFFFF
  h.b = ((h.b + value + 1) * 2246822519) & 0xFFFFFFFF
  return h
end function

function _hash_bytes(h, value)
  if typeof(value) != "bytes" then return h end if
  if len(value) <= 0 then return h end if
  for i = 0 to len(value) - 1
    h = _hash_byte(h, value[i])
  end for
  return h
end function

function _hash_text(h, value)
  if typeof(value) != "string" then value = "" + value end if
  return _hash_bytes(h, bytes(value))
end function

function _collect_ml_files(path, excluded, result_paths)
  if typeof(path) != "string" or path == "" then return result_paths end if
  if s.toLowerAscii(path) == s.toLowerAscii(excluded) then return result_paths end if
  if fs.isFile(path) then
    if s.endsWith(s.toLowerAscii(path), ".ml") then result_paths = result_paths + [path] end if
    return result_paths
  end if
  if fs.isDir(path) == false then return result_paths end if
  names = fs.listDir(path)
  if typeof(names) != "array" or len(names) <= 0 then return result_paths end if
  for i = 0 to len(names) - 1
    name = names[i]
    low = s.toLowerAscii(name)
    if low == ".git" or low == "__pycache__" then continue end if
    result_paths = _collect_ml_files(_join(path, name), excluded, result_paths)
  end for
  return result_paths
end function

function _append_unique_path(paths, path)
  key = s.toLowerAscii(path)
  if len(paths) > 0 then
    for i = 0 to len(paths) - 1
      if s.toLowerAscii(paths[i]) == key then return paths end if
    end for
  end if
  return paths + [path]
end function

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

function _string_less(left, right)
  left_bytes = bytes(s.toLowerAscii(left))
  right_bytes = bytes(s.toLowerAscii(right))
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

// Hash the manifest, effective arguments and every reachable MiniLang source.
function fingerprint(pb, input_path, include_dirs)
  h = ProjectHash(2166136261, 3266489917)
  h = _hash_text(h, "MiniLang-project-cache-v1")
  for ai = 0 to len(pb.expanded_args) - 1
    h = _hash_byte(h, 0)
    h = _hash_text(h, pb.expanded_args[ai])
  end for
  manifest_bytes = fs.readAllBytes(pb.manifest)
  if typeof(manifest_bytes) == "error" then return manifest_bytes end if
  h = _hash_bytes(h, manifest_bytes)

  roots = [_dirname(input_path)]
  if typeof(include_dirs) == "array" and len(include_dirs) > 0 then
    for ri = 0 to len(include_dirs) - 1
      roots = _append_unique_path(roots, include_dirs[ri])
    end for
  end if
  files = []
  for ri = 0 to len(roots) - 1
    files = _collect_ml_files(roots[ri], pb.cache_dir, files)
  end for
  unique_files = []
  if len(files) > 0 then
    for fi = 0 to len(files) - 1
      unique_files = _append_unique_path(unique_files, _abspath(files[fi]))
    end for
  end if
  unique_files = sort.sortBy(unique_files, _string_less)
  if len(unique_files) > 0 then
    for fi = 0 to len(unique_files) - 1
      data = fs.readAllBytes(unique_files[fi])
      if typeof(data) == "error" then return data end if
      h = _hash_byte(h, 0)
      h = _hash_text(h, s.toLowerAscii(unique_files[fi]))
      h = _hash_byte(h, 0)
      h = _hash_bytes(h, data)
    end for
  end if

  // Last-write time + size make compiler rebuilds invalidate the cache without
  // hashing a 50+ MiB self-hosted executable on every invocation.
  exe_buf = bytes(8192, 0)
  exe_len = GetModuleFileNameW(0, exe_buf, 4096)
  if typeof(exe_len) == "int" and exe_len > 0 then
    exe_path = decode16Z(exe_buf)
    attr = bytes(36, 0)
    if typeof(exe_path) == "string" and GetFileAttributesExW(exe_path, 0, attr) then
      h = _hash_text(h, s.toLowerAscii(exe_path))
      // Do not hash last-access time: merely launching the compiler may update
      // it and would turn every invocation into a cache miss.
      h = _hash_bytes(h, slice(attr, 0, 12))
      h = _hash_bytes(h, slice(attr, 20, 16))
    end if
  end if
  return _hex32(h.a) + _hex32(h.b)
end function

// Restore a cached artifact only when its recorded digest matches exactly.
function restore(pb, digest, output_path)
  if typeof(pb) != "struct" or pb.incremental == false then return false end if
  state_path = _join(pb.cache_dir, "build.state")
  artifact_path = _join(pb.cache_dir, "build.exe")
  if fs.isFile(state_path) == false or fs.isFile(artifact_path) == false then return false end if
  state = fs.readAllText(state_path)
  if typeof(state) != "string" or s.trim(state) != digest then return false end if
  if _ensure_dir(_dirname(output_path)) == false then return false end if
  copied = fs.copyFile(artifact_path, output_path, true)
  return typeof(copied) != "error"
end function

// Atomically update the cached artifact and its validation metadata.
function store(pb, digest, output_path)
  if typeof(pb) != "struct" or pb.incremental == false then return true end if
  if _ensure_dir(pb.cache_dir) == false then return error(1, "failed to create project cache directory") end if
  artifact_path = _join(pb.cache_dir, "build.exe")
  copied = fs.copyFile(output_path, artifact_path, true)
  if typeof(copied) == "error" then return copied end if
  return fs.writeAllText(_join(pb.cache_dir, "build.state"), digest + "\n")
end function

// Create the parent directory required by a configured output path.
function ensureOutputDirectory(output_path)
  return _ensure_dir(_dirname(output_path))
end function
