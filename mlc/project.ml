// TOML project manifests and content-validated incremental build metadata.
package mlc.project

import std.fs as fs
import std.process as process
import std.string as s
import std.sort as sort

#if TARGET_OS == "windows"
extern function GetFullPathNameW(path as wstr, bufferLen as u32, buffer as buffer, filePart as ptr) from "kernel32.dll" returns u32
extern function GetFileAttributesExW(path as wstr, level as int, info as bytes) from "kernel32.dll" returns bool
extern function CreateDirectoryW(path as wstr, securityAttributes as ptr) from "kernel32.dll" returns bool
extern function MoveFileExW(source as wstr, destination as wstr, flags as u32) from "kernel32.dll" returns bool
#else
extern function _project_mkdir(path as cstr, mode as u32) from "libc.so.6" symbol "mkdir" returns i32
extern function _project_stat(path as cstr, info as bytes) from "libc.so.6" symbol "stat" returns i32
extern function _project_rename(source as cstr, destination as cstr) from "libc.so.6" symbol "rename" returns i32
#endif

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
#if TARGET_OS == "linux"
  return a + "/" + b
#else
  return a + "\\" + b
#endif
end function

function _is_abs(path)
  if typeof(path) != "string" then return false end if
  if len(path) >= 2 and path[1] == ":" then return true end if
  if len(path) >= 2 and path[0] == "\\" and path[1] == "\\" then return true end if
  return len(path) >= 1 and (path[0] == "\\" or path[0] == "/")
end function

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

// Normalize a POSIX path lexically so output paths need not exist yet.
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
#if TARGET_OS == "linux"
  if _project_mkdir(path, 493) == 0 then return true end if
#else
  if CreateDirectoryW(path, 0) then return true end if
#endif
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
  return key == "entry" or key == "input" or key == "output" or key == "include" or key == "import_paths" or key == "subsystem" or key == "target" or key == "object_pipeline" or key == "incremental" or key == "cache_dir" or key == "compiler_args"
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
#if TARGET_OS == "linux"
      h = _hash_text(h, unique_files[fi])
#else
      h = _hash_text(h, s.toLowerAscii(unique_files[fi]))
#endif
      h = _hash_byte(h, 0)
      h = _hash_bytes(h, data)
    end for
  end if

  // Last-write time + size make compiler rebuilds invalidate the cache without
  // hashing a 50+ MiB self-hosted executable on every invocation.
  exe_path = process.executablePath()
  if typeof(exe_path) == "string" and exe_path != "" then
#if TARGET_OS == "windows"
    attr = bytes(36, 0)
    if typeof(exe_path) == "string" and GetFileAttributesExW(exe_path, 0, attr) then
      h = _hash_text(h, s.toLowerAscii(exe_path))
      // Do not hash last-access time: merely launching the compiler may update
      // it and would turn every invocation into a cache miss.
      h = _hash_bytes(h, slice(attr, 0, 12))
      h = _hash_bytes(h, slice(attr, 20, 16))
    end if
#else
    // Linux x86-64 struct stat stores size at 48 and mtime at 88. Avoid atime,
    // which may change merely because the compiler image was launched.
    attr = bytes(144, 0)
    if _project_stat(exe_path, attr) == 0 then
      h = _hash_text(h, exe_path)
      h = _hash_bytes(h, slice(attr, 48, 8))
      h = _hash_bytes(h, slice(attr, 88, 16))
    end if
#endif
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

function _object_cache_dir(pb, digest)
  return _join(_join(pb.cache_dir, "objects"), digest)
end function

// Return a complete immutable MLO set for this exact project fingerprint.
// Publication metadata is written last, so a crashed population is always a
// miss and can never feed a partial directory to the linker.
function restoreObjects(pb, digest)
  if typeof(pb) != "struct" or pb.incremental == false then return "" end if
  obj_dir = _object_cache_dir(pb, digest)
  state_path = _join(obj_dir, "objects.state")
  if fs.isFile(state_path) == false then return "" end if
  state = fs.readAllText(state_path)
  if typeof(state) != "string" then return "" end if
  state_lines = s.split(state, "\n")
  if len(state_lines) < 2 or s.trim(state_lines[0]) != digest then return "" end if
  expected_names = []
  for si = 1 to len(state_lines) - 1
    expected_name = s.trim(state_lines[si])
    if expected_name != "" then expected_names = expected_names + [expected_name] end if
  end for
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
  if len(expected_names) != len(mlo_names) then return "" end if
  for ni = 0 to len(mlo_names) - 1
    if expected_names[ni] != mlo_names[ni] then return "" end if
  end for
  if mlo_count <= 0 or support_count != 1 then return "" end if
  return obj_dir
end function

// Atomically update the cached artifact and its validation metadata.
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

function store(pb, digest, output_path)
  if typeof(pb) != "struct" or pb.incremental == false then return true end if
  if _ensure_dir(pb.cache_dir) == false then return error(1, "failed to create project cache directory") end if
  artifact_path = _join(pb.cache_dir, "build.exe")
  state_path = _join(pb.cache_dir, "build.state")
  artifact_tmp = artifact_path + ".tmp"
  state_tmp = state_path + ".tmp"
  copied = fs.copyFile(output_path, artifact_tmp, true)
  if typeof(copied) == "error" then return copied end if
  written = fs.writeAllText(state_tmp, digest + "\n")
  if typeof(written) == "error" then return written end if
  moved_artifact = _atomic_replace(artifact_tmp, artifact_path)
  if typeof(moved_artifact) == "error" then return moved_artifact end if
  // Publish metadata last. A crash between the two moves can only produce a
  // cache miss because the old digest no longer validates the new artifact.
  return _atomic_replace(state_tmp, state_path)
end function

// Populate the flat per-fingerprint object directory and publish its state
// marker only after every object copy succeeds.
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
  for i = 0 to len(names) - 1
    name = names[i]
    if typeof(name) != "string" or s.endsWith(s.toLowerAscii(name), ".mlo") == false then continue end if
    source_path = _join(source_dir, name)
    if fs.isFile(source_path) == false then continue end if
    copied = fs.copyFile(source_path, _join(obj_dir, name), true)
    if typeof(copied) == "error" then return copied end if
    cached_names = cached_names + [name]
    copied_count = copied_count + 1
    if s.endsWith(s.toLowerAscii(name), "_support.mlo") then support_count = support_count + 1 end if
  end for
  if copied_count <= 0 or support_count != 1 then return error(1, "object cache requires one complete support object") end if

  state_path = _join(obj_dir, "objects.state")
  state_tmp = state_path + ".tmp"
  state_text = digest + "\n"
  for ni = 0 to len(cached_names) - 1
    state_text = state_text + cached_names[ni] + "\n"
  end for
  written = fs.writeAllText(state_tmp, state_text)
  if typeof(written) == "error" then return written end if
  return _atomic_replace(state_tmp, state_path)
end function

// Create the parent directory required by a configured output path.
function ensureOutputDirectory(output_path)
  return _ensure_dir(_dirname(output_path))
end function
