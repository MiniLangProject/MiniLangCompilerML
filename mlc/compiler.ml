// High-level module loading, compilation, object pipeline, linker and CLI.
package mlc.compiler
import std.fs as fs
import std.string as s
import std.string_builder as sb
import std.process as process
import std.time as mtime
import mlc.frontend as frontend
import mlc.minilang_parser as parser
import mlc.codegen.codegen as codegen
import mlc.pe as pe
import mlc.tools as t
import mlc.project as project
import mlc.asm as a
import mlc.data as d
import mlc.elf as elf
import mlc.linux_runtime as linuxrt

const COMPILER_VERSION = "1.2.0"
const COMPILER_VERSION_TEXT = "MiniLang Compiler 1.2.0"
const DIRECT_SECTION_LABEL_THRESHOLD = 262144
const AUTO_OBJECT_PIPELINE_SCORE = 262144
const OBJECT_FUNCTION_BATCH_SIZE = 8
const OBJECT_COMPILER_BATCH_SIZE = 4
// Moderate function streams benefit from shorter allocation waves. Very large
// streams already peak while their early semantic graph is live, so extra
// collections only add work; retain the wider stride for those programs.
const OBJECT_EMISSION_GC_STRIDE = 32
const OBJECT_LARGE_EMISSION_GC_STRIDE = 64
const OBJECT_LARGE_EMISSION_FUNCTION_THRESHOLD = 2048
const LINK_LABEL_GC_OBJECT_STRIDE = 128
const LINK_SECTION_COPY_GC_OBJECT_STRIDE = 64
const MLO_WRITE_BATCH_BYTES = 1048576

#if TARGET_OS == "windows"
extern function GetFullPathNameW(path as wstr, bufferLen as u32, buffer as buffer, filePart as ptr) from "kernel32.dll" symbol "GetFullPathNameW" returns u32
extern function CreateDirectoryW(path as wstr, securityAttributes as ptr) from "kernel32.dll" symbol "CreateDirectoryW" returns bool
extern function _host_CreateProcessW(applicationName as wstr, commandLine as wstr, processAttributes as ptr, threadAttributes as ptr, inheritHandles as bool, creationFlags as u32, environment as ptr, currentDirectory as ptr, startupInfo as bytes, processInformation as bytes) from "kernel32.dll" symbol "CreateProcessW" returns bool
extern function _host_WaitForSingleObject(handle as ptr, milliseconds as u32) from "kernel32.dll" symbol "WaitForSingleObject" returns u32
extern function _host_GetExitCodeProcess(handle as ptr, exitCode as bytes) from "kernel32.dll" symbol "GetExitCodeProcess" returns bool
extern function _host_CloseHandle(handle as ptr) from "kernel32.dll" symbol "CloseHandle" returns bool
extern function _mlo_CreateFileW(path as wstr, access as int, share as int, security as ptr, creation as int, flags as int, template as ptr) from "kernel32.dll" symbol "CreateFileW" returns ptr
extern function _mlo_WriteFile(handle as ptr, input as bytes, count as int, written as bytes, overlapped as ptr) from "kernel32.dll" symbol "WriteFile" returns bool
extern function _mlo_CloseHandle(handle as ptr) from "kernel32.dll" symbol "CloseHandle" returns bool
#else
extern function _host_mkdir(path as cstr, mode as u32) from "libc.so.6" symbol "mkdir" returns i32
extern function _host_system(cmd as cstr) from "libc.so.6" symbol "system" returns i32
extern function _host_chmod(path as cstr, mode as u32) from "libc.so.6" symbol "chmod" returns i32
extern function _host_stat(path as cstr, info as bytes) from "libc.so.6" symbol "stat" returns i32
extern function _mlo_open(path as cstr, flags as int, mode as u32) from "libc.so.6" symbol "open" returns i32
extern function _mlo_write(fd as int, input as bytes, count as u64) from "libc.so.6" symbol "write" returns i64
extern function _mlo_close(fd as int) from "libc.so.6" symbol "close" returns i32
#endif

// Frontend diagnostics and keep-going results.
struct FrontDiag
  kind,
  filename,
  pos,
  message,
end struct

struct FrontCheckResult
  diagnostics,
  visited,
  modules,
  aliases,
  parsed_modules,
end struct

// Parsed module graph nodes and resolution candidates.
struct ModuleInfo
  path,
  package_name,
end struct

struct ParsedModule
  path,
  source,
  program,
end struct

struct StrPair
  key,
  value,
end struct

struct ResolveCand
  path,
  kind,
  root,
end struct

struct ResolveResult
  resolved,
  tried,
  matches,
  resolved_kind,
  resolved_root,
end struct

struct PathStackNode
  path,
  parent,
end struct

struct DeclCheckResult
  diagnostics,
  failed,
end struct

struct LoadProgramResult
  diagnostics,
  source,
  program,
  aliases,
  sources,
  visited,
  parsed_modules,
end struct

struct StrIntPair
  key,
  value,
end struct

// AST telemetry is opt-in so normal builds do not pay for a second tree walk.
struct CompilerAstProfile
  counts,
  total,
  max_depth,
end struct

// Normalized native ABI declarations used by validation and import planning.
struct ExternSigParam
  name,
  ty,
  is_out,
end struct

struct ExternSig
  qname,
  name,
  dll,
  symbol_name,
  params,
  ret_ty,
end struct

// Serializable object-pipeline records consumed by the fresh linker process.
struct MloLabel
  name,
  offset,
end struct

struct MloPatch
  offset,
  target,
  kind,
end struct

struct MloImportDll
  dll,
  funcs,
end struct

struct MloObject
  kind,
  module_file,
  entry_label,
  text,
  rdata,
  data,
  bss_size,
  asm_labels,
  asm_patches,
  rdata_labels,
  rdata_patches,
  data_labels,
  data_patches,
  bss_labels,
  imports,
end struct

// Metadata-only first-pass record. Section payloads are copied into their
// final combined buffers in a separate pass and never retained per object.
struct MloLayoutScan
  entry_label,
  text_size,
  rdata_size,
  data_size,
  bss_size,
  public_label_count,
  private_label_count,
  imports,
end struct

// Immutable section boundary used while one logical monolithic stream is
// spilled into independently serializable .mlo fragments.
struct MloStateCheckpoint
  rdata_used,
  data_used,
  bss_size,
  rdata_label_count,
  rdata_patch_count,
  data_label_count,
  data_patch_count,
  bss_label_count,
end struct

// Capacity-backed binary writer and reader for the .mlo file format.
struct ObjBuf
  parts,
  total,
end struct

struct ObjReader
  buf,
  pos,
  u32_result,
end struct

_mem_probe_enabled = false
_dump_labels_path = ""
_path_norm_cache = []
_front_visited_set = []
_front_resolve_cache = []
_mlo_write_scratch = 0
_pe_state_keepalive = 0
_compile_codegen_keepalive = 0
_link_patch_keepalive = 0
_object_pipeline_enabled = false
_object_emit_only = false
_asm_listing_enabled = false
_asm_listing_path = ""
_asm_show_addr = true
_asm_show_bytes = true
_asm_show_code = true
_asm_dump_data = false
_asm_dump_pe = false
_compiler_profile_enabled = false
_compiler_profile_batches_enabled = false
_compiler_profile_ast_enabled = false
_compile_target = "windows-x64"
_compiler_profile_started = 0
_compiler_profile_phase_started = 0
_compiler_profile_phase_name = ""

function _build_line_starts(source)
  if typeof(source) != "string" then return [0] end if
  starts_b = t.arr_chunk_new(128)
  starts_b = t.arr_chunk_push(starts_b, 0)
  if len(source) > 0 then
    for i = 0 to len(source) - 1
      if source[i] == "\n" then
        starts_b = t.arr_chunk_push(starts_b, i + 1)
      end if
    end for
  end if
  return t.arr_chunk_finish(starts_b)
end function

function _usage()
  print "MiniLang self-hosted compiler " + COMPILER_VERSION
  print "Usage:"
  print "  mlc_win64.exe <input.ml> <output.exe> [compiler options]"
  print "  mlc_win64.exe --project <minilang.toml> [compiler options]"
  print "  mlc_win64.exe <ignored> <output.exe> --link-obj-dir <tmp-dir> [compiler options]"
  print "  mlc_win64.exe -version | --version"
  print "Extra self-hosted checks:"
  print "  --self-frontcheck"
  print "  --self-frontcheck-keep-going"
  print "Debug:"
  print "  --mem-probe"
  print "  --profile-compiler    print wall-clock time for compiler phases"
  print "  --profile-compiler-batches  also print function-batch/module timings"
  print "  --profile-compiler-ast  also print AST arena and node-kind telemetry"
  print "Listings:"
  print "  --asm [--asm-out <path>] [--asm-cols addr,opcodes,code]"
  print "  --asm-no-addr --asm-no-opcodes --asm-no-code --asm-data --asm-pe"
  print "Build internals:"
  print "  --object-pipeline    force the memory-bounded .mlo pipeline"
  print "  --no-object-pipeline force the monolithic pipeline"
  print "  --target TARGET      windows-x64 (default) or linux-x64"
  print "Conditional compilation:"
  print "  -DNAME[=VALUE] | --define NAME[=VALUE]"
end function

function _get_flag_value(args, flag)
  i = 0
  while i < len(args)
    if args[i] == flag then
      if i + 1 < len(args) then return args[i + 1] end if
      return ""
    end if
    i = i + 1
  end while
  return ""
end function

function _compiler_profile_reset()
  global _compiler_profile_started
  global _compiler_profile_phase_started
  global _compiler_profile_phase_name
  if _compiler_profile_enabled == false then return void end if
  tick = mtime.ticks()
  _compiler_profile_started = tick
  _compiler_profile_phase_started = tick
  _compiler_profile_phase_name = ""
  return void
end function

function _compiler_profile_phase(msg)
  global _compiler_profile_phase_started
  global _compiler_profile_phase_name
  if _compiler_profile_enabled == false then return void end if
  tick = mtime.ticks()
  if _compiler_profile_phase_name != "" then
    print "[profile] phase=" + _compiler_profile_phase_name + " elapsed_ms=" + (tick - _compiler_profile_phase_started)
  end if
  _compiler_profile_phase_name = msg
  _compiler_profile_phase_started = tick
  return void
end function

function _compiler_profile_finish()
  global _compiler_profile_started
  global _compiler_profile_phase_started
  global _compiler_profile_phase_name
  if _compiler_profile_enabled == false then return void end if
  tick = mtime.ticks()
  if _compiler_profile_phase_name != "" then
    print "[profile] phase=" + _compiler_profile_phase_name + " elapsed_ms=" + (tick - _compiler_profile_phase_started)
  end if
  print "[profile] total_ms=" + (tick - _compiler_profile_started)
  _compiler_profile_phase_name = ""
  return void
end function

function _compiler_ast_profile_count(profile, kind)
  counts = profile.counts
  if typeof(counts) != "array" then counts = [] end if
  if len(counts) > 0 then
    for i = 0 to len(counts) - 1
      if counts[i].key == kind then
        item = counts[i]
        item.value = item.value + 1
        counts[i] = item
        profile.counts = counts
        profile.total = profile.total + 1
        return profile
      end if
    end for
  end if
  profile.counts = counts + [StrIntPair(kind, 1)]
  profile.total = profile.total + 1
  return profile
end function

function _compiler_ast_profile_visit_value(profile, value, depth)
  if t.ast_is_node(value) then return _compiler_ast_profile_visit_node(profile, value, depth) end if
  if typeof(value) != "array" or len(value) <= 0 then return profile end if
  for i = 0 to len(value) - 1
    profile = _compiler_ast_profile_visit_value(profile, value[i], depth)
  end for
  return profile
end function

// Traverse the public AST schema only when explicitly requested. Compact leaf
// NodeIds are terminal; composite structs are followed through every AST-bearing
// field shared by expressions, statements, declarations and switch containers.
function _compiler_ast_profile_visit_node(profile, node, depth)
  if t.ast_is_node(node) == false then return profile end if
  kind = t.ast_kind(node)
  profile = _compiler_ast_profile_count(profile, kind)
  if depth > profile.max_depth then profile.max_depth = depth end if
  if t.ast_is_leaf(node) then return profile end if

  profile = _compiler_ast_profile_visit_value(profile, try(node.items), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, t.ast_left(node), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, t.ast_right(node), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.expr), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.callee), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.args), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.target), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.index), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.obj), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.lock), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.cleanup), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.body), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.params), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.cond), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.then_body), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.elifs), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.else_body), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.start), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.end_expr), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.iterable), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.values), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.range_start), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.range_end), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.cases), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.default_body), depth + 1)
  profile = _compiler_ast_profile_visit_value(profile, try(node.methods), depth + 1)
  return profile
end function

function _compiler_ast_profile_report(program, module_count)
  global _compiler_profile_ast_enabled
  if _compiler_profile_ast_enabled == false then return void end if
  profile = CompilerAstProfile([], 0, 0)
  profile = _compiler_ast_profile_visit_value(profile, program, 1)
  stats = t.ast_leaf_stats()
  print "[profile-ast] modules=" + module_count + " nodes=" + profile.total + " compact_leaves=" + stats[0] + " compact_bins=" + stats[5] + " leaf_capacity=" + stats[1] + " bin_capacity=" + stats[6] + " arena_storage_bytes=" + stats[4] + " symbols=" + stats[2] + " files=" + stats[3] + " max_depth=" + profile.max_depth
  if len(profile.counts) > 0 then
    for i = 0 to len(profile.counts) - 1
      print "[profile-ast] kind=" + profile.counts[i].key + " count=" + profile.counts[i].value
    end for
  end if
  return void
end function

// Extract the package/type prefix shown on detailed object-batch profiles.
function _compiler_profile_owner(function_name)
  name = _coerce_name(function_name)
  split_at = s.lastIndexOf(name, ".")
  if split_at <= 0 then return "<root>" end if
  return s.substr(name, 0, split_at)
end function

function _progress_phase(msg)
  _compiler_profile_phase(msg)
  print "[phase] " + msg
end function

function _progress_obj(msg)
  print "[obj] " + msg
end function

function _progress_link(msg)
  print "[link] " + msg
end function

function inline _startsWith(text, pref)
  if typeof(text) != "string" or typeof(pref) != "string" then return false end if
  if len(pref) > len(text) then return false end if
  for i = 0 to len(pref) - 1
    if text[i] != pref[i] then return false end if
  end for
  return true
end function

function inline _endsWith(text, suf)
  if typeof(text) != "string" or typeof(suf) != "string" then return false end if
  if len(suf) > len(text) then return false end if
  off = len(text) - len(suf)
  for i = 0 to len(suf) - 1
    if text[off + i] != suf[i] then return false end if
  end for
  return true
end function

function inline _array_contains(arr, value)
  if len(arr) <= 0 then return false end if
  for i = 0 to len(arr) - 1
    if arr[i] == value then return true end if
  end for
  return false
end function

function inline _containsDot(txt)
  if typeof(txt) != "string" then return false end if
  for i = 0 to len(txt) - 1
    if txt[i] == "." then return true end if
  end for
  return false
end function

function inline _last_segment_after_dot(txt)
  if typeof(txt) != "string" then return "" end if
  i = len(txt) - 1
  while i >= 0
    if txt[i] == "." then
      return s.substr(txt, i + 1, len(txt) - i - 1)
    end if
    i = i - 1
  end while
  return txt
end function

function inline _to_int_or(defv, text)
  n = toNumber(text)
  if typeof(n) != "int" then return defv end if
  return n
end function

function _path_canon(p)
  if typeof(p) != "string" then return "" end if
#if TARGET_OS == "linux"
  if p == "" then return "." end if
  absolute = _startsWith(p, "/")
  parts = s.split(p, "/")
  stack = []
  if typeof(parts) == "array" and len(parts) > 0 then
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
  end if
  tail = s.join(stack, "/")
  if absolute then
    if tail == "" then return "/" end if
    return "/" + tail
  end if
  if tail == "" then return "." end if
  return tail
#else
  q = s.replaceAll(p, "/", "\\")
  if q == "" then return "." end if

  prefix = ""
  rest = q

  if len(rest) >= 2 and rest[1] == ":" then
    prefix = s.toLowerAscii(s.substr(rest, 0, 2))
    rest = s.substr(rest, 2, len(rest) - 2)
    if _startsWith(rest, "\\") then
      prefix = prefix + "\\"
      rest = s.substr(rest, 1, len(rest) - 1)
    end if
  else
    if _startsWith(rest, "\\\\") then
      prefix = "\\\\"
      rest = s.substr(rest, 2, len(rest) - 2)
    else
      if _startsWith(rest, "\\") then
        prefix = "\\"
        rest = s.substr(rest, 1, len(rest) - 1)
      end if
    end if
  end if

  parts = s.split(rest, "\\")
  stack =[]
  if typeof(parts) == "array" and len(parts) > 0 then
    for i = 0 to len(parts) - 1
      part = parts[i]
      if part == "" or part == "." then continue end if
      if part == ".." then
        if typeof(stack) != "array" then stack =[] end if
        if len(stack) > 0 and stack[len(stack) - 1] != ".." then
          stack = t.arr_drop_last(stack)
        else
          if prefix == "" then
            stack = stack +[".."]
          end if
        end if
        continue
      end if
      stack = stack +[part]
    end for
  end if

  tail = s.join(stack, "\\")
  if prefix != "" then
    if tail == "" then return prefix end if
    if prefix == "\\\\" then return "\\\\" + tail end if
    if _endsWith(prefix, "\\") then return prefix + tail end if
    return prefix + "\\" + tail
  end if
  if tail == "" then return "." end if
  return tail
#endif
end function

function _path_norm(p)
#if TARGET_OS == "linux"
  return _path_canon(p)
#else
  return s.toLowerAscii(_path_canon(p))
#endif
end function

function _path_abspath(p)
  if typeof(p) != "string" or p == "" then return "" end if
#if TARGET_OS == "linux"
  if _is_abs_path(p) then return _path_canon(p) end if
  cwd = process.currentDirectory()
  if typeof(cwd) != "string" or cwd == "" then return _path_canon(p) end if
  return _path_canon(_path_join(cwd, p))
#else
  buf = bytes(8192, 0)
  n = GetFullPathNameW(p, 4096, buf, 0)
  if typeof(n) != "int" or n <= 0 then
    return p
  end if
  abs_p = decode16Z(buf)
  if typeof(abs_p) != "string" or abs_p == "" then return p end if
  return abs_p
#endif
end function

function _self_exe_path()
  p = process.executablePath()
  if typeof(p) != "string" then return "" end if
  return p
end function

function _cmd_quote_arg(x)
  if typeof(x) != "string" then return "\"\"" end if
#if TARGET_OS == "linux"
  // POSIX shells do not interpret characters inside single quotes. Encode an
  // embedded quote as the standard close/escaped-quote/reopen sequence.
  return "'" + s.replaceAll(x, "'", "'\\''") + "'"
#else
  // CreateProcessW consumes one Windows CRT command line rather than an argv
  // array. Backslashes immediately before a quote are doubled, and trailing
  // backslashes are doubled again so they cannot escape the closing quote.
  bld = sb.StringBuilder.withCapacity(len(x) + 8)
  bld.appendString("\"")
  pending_slashes = 0
  raw = bytes(x)
  if len(raw) > 0 then
    for i = 0 to len(raw) - 1
      ch = raw[i]
      if ch == 92 then
        pending_slashes = pending_slashes + 1
        continue
      end if
      copies = pending_slashes
      if ch == 34 then copies = (pending_slashes * 2) + 1 end if
      while copies > 0
        bld.appendString("\\")
        copies = copies - 1
      end while
      pending_slashes = 0
      bld.appendSlice(x, i, 1)
    end for
  end if
  pending_slashes = pending_slashes * 2
  while pending_slashes > 0
    bld.appendString("\\")
    pending_slashes = pending_slashes - 1
  end while
  bld.appendString("\"")
  return bld.toString()
#endif
end function

function _u64le_host_at(buf, offset)
  if typeof(buf) != "bytes" or typeof(offset) != "int" or offset < 0 or offset + 8 > len(buf) then return 0 end if
  value = 0
  for i = 0 to 7
    value = value | (buf[offset + i] << (i * 8))
  end for
  return value
end function

// Launch a child compiler without a command shell on Windows. Besides avoiding
// cmd.exe expansion, this preserves every argument exactly across the object-
// emission and fresh-link process boundaries.
function _run_child_process(executable, args)
  if typeof(executable) != "string" or executable == "" then return -1 end if
  cmd = _cmd_quote_arg(executable)
  if typeof(args) == "array" and len(args) > 0 then
    for i = 0 to len(args) - 1
      cmd = cmd + " " + _cmd_quote_arg(args[i])
    end for
  end if
#if TARGET_OS == "linux"
  return _host_system(cmd)
#else
  startup = bytes(104, 0)
  startup[0] = 104
  process_info = bytes(24, 0)
  if _host_CreateProcessW(executable, cmd, 0, 0, false, 0, 0, 0, startup, process_info) == false then return -1 end if
  process_handle = _u64le_host_at(process_info, 0)
  thread_handle = _u64le_host_at(process_info, 8)
  if thread_handle != 0 then _host_CloseHandle(thread_handle) end if
  if process_handle == 0 then return -1 end if
  waited = _host_WaitForSingleObject(process_handle, 0xFFFFFFFF)
  exit_code = bytes(4, 0)
  got_exit = _host_GetExitCodeProcess(process_handle, exit_code)
  _host_CloseHandle(process_handle)
  if waited != 0 or got_exit == false then return -1 end if
  return _u32le_at(exit_code, 0)
#endif
end function

// Native Linux filesystems require execute permission in addition to valid ELF
// contents. Windows cross-builds cannot represent this bit and intentionally
// leave deployment-time chmod behavior unchanged.
function _make_linux_output_executable(path)
#if TARGET_OS == "linux"
  attr = bytes(144, 0)
  if _host_stat(path, attr) != 0 then return error(1, "stat failed for Linux executable") end if
  current_mode = _u32le_at(attr, 24) & 4095
  // Add execute only where the umask left a corresponding read permission.
  // A private 0600 output becomes 0700; a normal 0644 output becomes 0755.
  executable_mode = current_mode | ((current_mode & 292) >> 2)
  if _host_chmod(path, executable_mode) != 0 then return error(1, "chmod failed for Linux executable") end if
#endif
  return true
end function

function _path_norm_cached(p)
  global _path_norm_cache
  if typeof(p) != "string" then return _path_norm(p) end if
  if typeof(_path_norm_cache) != "struct" then _path_norm_cache = t.fastmap_new(4096) end if
  hit = t.fastmap_get(_path_norm_cache, p, 0)
  if typeof(hit) == "string" then return hit end if
  n = _path_norm(p)
  _path_norm_cache = t.fastmap_set(_path_norm_cache, p, n)
  return n
end function

function inline _path_eq(a, b)
  if a == b then return true end if
  return _path_norm_cached(a) == _path_norm_cached(b)
end function

function _append_unique_path(arr, value)
  if typeof(arr) != "array" then arr = [] end if
  if len(arr) > 0 then
    nv = _path_norm_cached(value)
    for i = 0 to len(arr) - 1
      if _path_norm_cached(arr[i]) == nv then return arr end if
    end for
  end if
  return arr +[value]
end function

function inline _is_abs_path(p)
  if typeof(p) != "string" then return false end if
  if len(p) >= 2 and p[1] == ":" then return true end if
  if len(p) >= 2 and p[0] == "\\" and p[1] == "\\" then return true end if
  if len(p) >= 1 and(p[0] == "/" or p[0] == "\\") then return true end if
  return false
end function

function inline _dirname(path)
  if typeof(path) != "string" then return "." end if
  i = len(path) - 1
  while i >= 0
    ch = path[i]
    if ch == "\\" or ch == "/" then
      if i <= 0 then return "." end if
      return s.substr(path, 0, i)
    end if
    i = i - 1
  end while
  return "."
end function

function inline _path_join(a, b)
  if typeof(a) != "string" or a == "" or a == "." then return b end if
  if typeof(b) != "string" or b == "" then return a end if
  last = a[len(a) - 1]
  if last == "\\" or last == "/" then
    return a + b
  end if
#if TARGET_OS == "linux"
  return a + "/" + b
#else
  return a + "\\" + b
#endif
end function

function inline _basename(path)
  if typeof(path) != "string" or path == "" then return "" end if
  i = len(path) - 1
  while i >= 0
    ch = path[i]
    if ch == "\\" or ch == "/" then
      if i + 1 >= len(path) then return "" end if
      return s.substr(path, i + 1, len(path) - i - 1)
    end if
    i = i - 1
  end while
  return path
end function

function inline _file_stem(path)
  base = _basename(path)
  if base == "" then return "module" end if
  i = len(base) - 1
  while i >= 0
    if base[i] == "." then
      if i <= 0 then return base end if
      return s.substr(base, 0, i)
    end if
    i = i - 1
  end while
  return base
end function

function _sanitize_fs_component(text)
  if typeof(text) != "string" or text == "" then return "module" end if
  safe = ""
  for i = 0 to len(text) - 1
    ch = text[i]
    cb = bytes(ch)
    cc = 0
    if len(cb) > 0 then cc = cb[0] end if
    keep = false
    if (cc >= 97 and cc <= 122) or (cc >= 65 and cc <= 90) then keep = true end if
    if cc >= 48 and cc <= 57 then keep = true end if
    if ch == "_" or ch == "-" or ch == "." then keep = true end if
    if keep then
      safe = safe + ch
    else
      safe = safe + "_"
    end if
  end for
  if safe == "" then return "module" end if
  return safe
end function

function _ensure_dir_recursive(path)
  if typeof(path) != "string" or path == "" or path == "." then return true end if
  if fs.exists(path) then
    return fs.isDir(path)
  end if

  parent = _dirname(path)
  if parent != "" and parent != "." and parent != path then
    if _ensure_dir_recursive(parent) == false then return false end if
  end if

#if TARGET_OS == "linux"
  ok = _host_mkdir(path, 493) == 0
#else
  ok = CreateDirectoryW(path, 0)
#endif
  if ok == true then return true end if
  return fs.isDir(path)
end function

function _tmp_obj_dir(output_exe)
  out_dir = _dirname(output_exe)
  if out_dir == "" then out_dir = "." end if
  tmp_root = _path_join(out_dir, "tmp")
  stem = _sanitize_fs_component(_file_stem(output_exe))
  return _path_join(tmp_root, stem)
end function

function _tmp_obj_path(tmp_dir, index, module_path, kind)
  stem = "module"
  if kind == "support" then
    stem = "support"
  else
    stem = _sanitize_fs_component(_file_stem(module_path))
  end if
  return _path_join(tmp_dir, index + "_" + stem + ".mlo")
end function

function _clear_tmp_obj_dir(tmp_dir)
  names = fs.listDir(tmp_dir)
  if typeof(names) != "array" or len(names) <= 0 then return true end if
  ok = true
  for i = 0 to len(names) - 1
    nm = names[i]
    if typeof(nm) != "string" or nm == "" then continue end if
    full = _path_join(tmp_dir, nm)
    if fs.isDir(full) then continue end if
    if fs.delete(full) == false then ok = false end if
  end for
  return ok
end function

function _section_has_payload(blob, labels, patches, size_hint)
  if typeof(blob) == "bytes" and len(blob) > 0 then return true end if
  if typeof(labels) == "array" and len(labels) > 0 then return true end if
  if typeof(patches) == "array" and len(patches) > 0 then return true end if
  if typeof(size_hint) == "int" and size_hint > 0 then return true end if
  return false
end function

function _append_zero_pad(parts_b, pad_bytes)
  if typeof(pad_bytes) != "int" or pad_bytes <= 0 then return parts_b end if
  return t.arr_chunk_push(parts_b, bytes(pad_bytes, 0))
end function

function _u32le_at(buf, off)
  if typeof(buf) != "bytes" then return 0 end if
  if typeof(off) != "int" or off < 0 or off + 3 >= len(buf) then return 0 end if
  return buf[off] | (buf[off + 1] << 8) | (buf[off + 2] << 16) | (buf[off + 3] << 24)
end function

function _objbuf_new()
  return ObjBuf(t.arr_chunk_new(64), 0)
end function

function _objbuf_push(ob, b)
  if typeof(b) != "bytes" or len(b) <= 0 then return ob end if
  ob.parts = t.arr_chunk_push(ob.parts, b)
  ob.total = ob.total + len(b)
  return ob
end function

function _objbuf_u32(ob, value)
  return _objbuf_push(ob, t.u32(value))
end function

function _objbuf_bytes(ob, b)
  if typeof(b) != "bytes" then b = bytes(0) end if
  ob = _objbuf_u32(ob, len(b))
  return _objbuf_push(ob, b)
end function

function _objbuf_string(ob, text)
  raw = bytes("")
  if typeof(text) == "string" then raw = bytes(text) end if
  return _objbuf_bytes(ob, raw)
end function

function _objbuf_finish(ob)
  buf = bytes(ob.total, 0)
  parts = t.arr_chunk_finish(ob.parts)
  off = 0
  if typeof(parts) == "array" and len(parts) > 0 then
    for i = 0 to len(parts) - 1
      part = parts[i]
      if typeof(part) != "bytes" then continue end if
      copyBytes(buf, off, part, 0, len(part))
      off = off + len(part)
    end for
  end if
  return buf
end function

function _objreader_new(buf)
  // Reuse the hot two-value result for this reader. Every caller consumes the
  // pair before issuing its next read, so MLO scans avoid allocating millions
  // of transient [reader, value] arrays without introducing shared state.
  return ObjReader(buf, 0, [0, 0])
end function

function _objreader_read_u32(rd)
  if rd is not ObjReader or typeof(rd.buf) != "bytes" then
    return error(1, "invalid object reader")
  end if
  if rd.pos < 0 or rd.pos + 4 > len(rd.buf) then
    return error(1, "truncated object file")
  end if
  p = rd.pos
  v = rd.buf[p] | (rd.buf[p + 1] << 8) | (rd.buf[p + 2] << 16) | (rd.buf[p + 3] << 24)
  rd.pos = rd.pos + 4
  result = rd.u32_result
  result[0] = rd
  result[1] = v
  return result
end function

function _objreader_read_bytes(rd)
  rlen = _objreader_read_u32(rd)
  if typeof(rlen) == "error" then return rlen end if
  rd = rlen[0]
  n = rlen[1]
  if typeof(n) != "int" or n < 0 then return error(1, "invalid object blob length") end if
  if rd.pos < 0 or rd.pos + n > len(rd.buf) then
    return error(1, "truncated object blob at pos=" + rd.pos + " len=" + n + " total=" + len(rd.buf))
  end if
  blob = bytes(n, 0)
  if n > 0 then
    copyBytes(blob, 0, rd.buf, rd.pos, n)
  end if
  rd.pos = rd.pos + n
  return [rd, blob]
end function

function _objreader_read_string(rd)
  rb = _objreader_read_bytes(rd)
  if typeof(rb) == "error" then return rb end if
  rd = rb[0]
  raw = rb[1]
  return [rd, decode(raw)]
end function

// Advance over a length-prefixed blob without allocating a copy. Layout scans
// and the patch applier often need only the following field position.
function _objreader_skip_bytes(rd)
  rlen = _objreader_read_u32(rd)
  if typeof(rlen) == "error" then return rlen end if
  rd = rlen[0]
  n = rlen[1]
  if typeof(n) != "int" or n < 0 or rd.pos < 0 or rd.pos + n > len(rd.buf) then
    return error(1, "truncated object blob while skipping")
  end if
  rd.pos = rd.pos + n
  return rd
end function

function _objreader_skip_bytes_len(rd)
  rlen = _objreader_read_u32(rd)
  if typeof(rlen) == "error" then return rlen end if
  rd = rlen[0]
  n = rlen[1]
  if typeof(n) != "int" or n < 0 or rd.pos < 0 or rd.pos + n > len(rd.buf) then
    return error(1, "truncated object blob while scanning length")
  end if
  rd.pos = rd.pos + n
  return [rd, n]
end function

// Copy one length-prefixed blob from the current raw MLO file directly into
// its final combined section. No intermediate per-object bytes value is made.
function _objreader_copy_bytes_into(rd, destination, destination_offset)
  rlen = _objreader_read_u32(rd)
  if typeof(rlen) == "error" then return rlen end if
  rd = rlen[0]
  n = rlen[1]
  if typeof(destination) != "bytes" or typeof(destination_offset) != "int" or destination_offset < 0 then
    return error(1, "invalid streamed object destination")
  end if
  if typeof(n) != "int" or n < 0 or rd.pos < 0 or rd.pos + n > len(rd.buf) then
    return error(1, "truncated streamed object blob")
  end if
  if destination_offset + n > len(destination) then return error(1, "streamed object section overflow") end if
  if n > 0 then copyBytes(destination, destination_offset, rd.buf, rd.pos, n) end if
  rd.pos = rd.pos + n
  return [rd, n]
end function

function inline _node_pos(st)
  if typeof(st) != "struct" then return 0 end if
  if typeof(st._pos) == "int" then return st._pos end if
  return 0
end function

function inline _node_file(st, fallback)
  if typeof(st) == "struct" and typeof(st._filename) == "string" then
    return st._filename
  end if
  return fallback
end function

function _add_diag(diags, kind, filename, pos, message)
  return diags +[FrontDiag(kind, filename, pos, message)]
end function

function _add_diag_from_stmt(diags, kind, st, fallback_file, message)
  return _add_diag(diags, kind, _node_file(st, fallback_file), _node_pos(st), message)
end function

function _module_get_package(modules, path)
  if typeof(modules) == "struct" then
    key = _path_norm_cached(path)
    v = t.fastmap_get(modules, key, "")
    if typeof(v) == "string" then return v end if
    return ""
  end if
  if len(modules) <= 0 then return "" end if
  for i = 0 to len(modules) - 1
    if _path_eq(modules[i].path, path) then
      return modules[i].package_name
    end if
  end for
  return ""
end function

function _module_set_package(modules, path, package_name)
  if typeof(modules) == "struct" then
    key = _path_norm_cached(path)
    return t.fastmap_set(modules, key, package_name)
  end if
  if len(modules) <= 0 then
    return [ModuleInfo(path, package_name)]
  end if
  for i = 0 to len(modules) - 1
    if _path_eq(modules[i].path, path) then
      modules[i] = ModuleInfo(path, package_name)
      return modules
    end if
  end for
  return modules +[ModuleInfo(path, package_name)]
end function

function inline _alias_get(aliases, key)
  if typeof(aliases) == "struct" then
    v = t.fastmap_get(aliases, key, "")
    if typeof(v) == "string" then return v end if
    return ""
  end if
  if len(aliases) <= 0 then return "" end if
  for i = 0 to len(aliases) - 1
    if aliases[i].key == key then return aliases[i].value end if
  end for
  return ""
end function

function _alias_set(aliases, key, value)
  if typeof(aliases) == "struct" then
    return t.fastmap_set(aliases, key, value)
  end if
  if len(aliases) <= 0 then
    return [StrPair(key, value)]
  end if
  for i = 0 to len(aliases) - 1
    if aliases[i].key == key then
      aliases[i] = StrPair(key, value)
      return aliases
    end if
  end for
  return aliases +[StrPair(key, value)]
end function

function _alias_to_array(aliases)
  if typeof(aliases) == "array" then return aliases end if
  if typeof(aliases) != "struct" then return [] end if
  items = t.fastmap_items(aliases)
  out_chunks = []
  out_tail = []
  if len(items) > 0 then
    for i = 0 to len(items) - 1
      it = items[i]
      if typeof(it) == "array" and len(it) >= 2 and typeof(it[0]) == "string" and typeof(it[1]) == "string" then
        app = t.arr_chunked_push(out_chunks, out_tail, StrPair(it[0], it[1]), 32)
        out_chunks = app[0]
        out_tail = app[1]
      end if
    end for
  end if
  return t.arr_chunked_finish(out_chunks, out_tail)
end function

function _path_to_package(rel_path)
  if typeof(rel_path) != "string" then return "" end if
  rp = s.replaceAll(rel_path, "\\", "/")
  while _startsWith(rp, "./")
    rp = s.substr(rp, 2, len(rp) - 2)
  end while
  while _startsWith(rp, "/")
    rp = s.substr(rp, 1, len(rp) - 1)
  end while
  if _startsWith(rp, "../") then return "" end if
  if s.contains(rp, "/../") then return "" end if
  if _endsWith(rp, ".ml") then
    rp = s.substr(rp, 0, len(rp) - 3)
  end if
  if rp == "" then return "" end if

  parts = s.split(rp, "/")
  clean_chunks = []
  clean_tail = []
  if len(parts) > 0 then
    for i = 0 to len(parts) - 1
      p = parts[i]
      if p == "" or p == "." then
        continue
      end if
      if p == ".." then
        return ""
      end if
      appc = t.arr_chunked_push(clean_chunks, clean_tail, p, 16)
      clean_chunks = appc[0]
      clean_tail = appc[1]
    end for
  end if
  clean = t.arr_chunked_finish(clean_chunks, clean_tail)
  if len(clean) <= 0 then return "" end if
  return s.join(clean, ".")
end function

function _relpath_from_root(path, root)
  p = s.replaceAll(path, "/", "\\")
  r = s.replaceAll(root, "/", "\\")
  if _path_eq(p, r) then return "" end if

  pref = r
  if _endsWith(pref, "\\") == false then
    pref = pref + "\\"
  end if
  np = _path_norm_cached(p)
  npr = _path_norm_cached(pref)
  if _startsWith(np, npr) then
    return s.substr(p, len(pref), len(p) - len(pref))
  end if
  return ""
end function

function _expected_package_for_file(abs_path, resolved_kind, resolved_root)
  if resolved_kind != "rel" and resolved_kind != "include" then return "" end if
  if typeof(resolved_root) != "string" or resolved_root == "" then return "" end if
  rel = _relpath_from_root(abs_path, resolved_root)
  if rel == "" then return "" end if
  return _path_to_package(rel)
end function

function _is_constexpr_unary(op)
  return op == "-" or op == "~" or op == "not"
end function

function _is_constexpr_binary(op)
  return op == "or" or op == "and" or op == "|" or op == "^" or op == "&" or op == "==" or op == "!=" or op == ">" or op == "<" or op == ">=" or op == "<=" or op == "<<" or op == ">>" or op == "+" or op == "-" or op == "*" or op == "/" or op == "%"
end function

function _expr_to_qualname(expr)
  if t.ast_is_node(expr) == false then return "" end if
  if t.ast_kind(expr) == "Var" and typeof(t.ast_name(expr)) == "string" then
    return t.ast_name(expr)
  end if
  if t.ast_kind(expr) == "Member" and typeof(expr.name) == "string" then
    base = _expr_to_qualname(expr.target)
    if base == "" then return "" end if
    return base + "." + expr.name
  end if
  return ""
end function

function _is_constexpr_expr(expr)
  if t.ast_is_node(expr) == false then return false end if
  k = t.ast_kind(expr)
  if k == "Num" or k == "Str" or k == "Bool" then return true end if
  if k == "Var" then return true end if
  if k == "Member" then return _expr_to_qualname(expr) != "" end if
  if k == "Unary" then
    if _is_constexpr_unary(t.ast_op(expr)) == false then return false end if
    return _is_constexpr_expr(t.ast_right(expr))
  end if
  if k == "Bin" then
    if _is_constexpr_binary(t.ast_op(expr)) == false then return false end if
    return _is_constexpr_expr(t.ast_left(expr)) and _is_constexpr_expr(t.ast_right(expr))
  end if
  return false
end function

function _is_decl_stmt(st)
  if typeof(st) != "struct" then return false end if
  k = st.node_kind
  return k == "FunctionDef" or k == "StructDef" or k == "EnumDef" or k == "NamespaceDef" or k == "NamespaceDecl" or k == "ExternFunctionDef" or k == "ExternFunctionDecl" or k == "ConstDecl" or k == "Assign" or k == "SynchronizedDecl" or k == "Import"
end function

function _check_decl_stmt(st, module_path, diags, keep_going, max_errors)
  if len(diags) >= max_errors then return DeclCheckResult(diags, true) end if
  if typeof(st) != "struct" then
    diags = _add_diag(diags, "CompileError", module_path, 0, "Imported module must be declaration-only: " + module_path)
    return DeclCheckResult(diags, true)
  end if

  if st.node_kind == "NamespaceDef" then
    body = st.body
    if typeof(body) == "array" and len(body) > 0 then
      for i = 0 to len(body) - 1
        sub = _check_decl_stmt(body[i], module_path, diags, keep_going, max_errors)
        diags = sub.diagnostics
        if sub.failed then
          if keep_going == false then return DeclCheckResult(diags, true) end if
        end if
        if len(diags) >= max_errors then return DeclCheckResult(diags, true) end if
      end for
    end if
    return DeclCheckResult(diags, false)
  end if

  if st.node_kind == "ConstDecl" then
    if _is_constexpr_expr(st.expr) == false then
      diags = _add_diag_from_stmt(diags, "CompileError", st, module_path, "Imported module const initializer must be constexpr: " + module_path)
      return DeclCheckResult(diags, true)
    end if
    return DeclCheckResult(diags, false)
  end if

  if st.node_kind == "EnumDef" then
    vals = st.values
    if typeof(vals) == "array" and len(vals) > 0 then
      for i = 0 to len(vals) - 1
        vx = vals[i]
        if typeof(vx) == "void" then continue end if
        if _is_constexpr_expr(vx) == false then
          diags = _add_diag_from_stmt(diags, "CompileError", st, module_path, "Imported module enum values must be constexpr: " + module_path)
          return DeclCheckResult(diags, true)
        end if
      end for
    end if
    return DeclCheckResult(diags, false)
  end if

  if _is_decl_stmt(st) then
    return DeclCheckResult(diags, false)
  end if

  diags = _add_diag_from_stmt(diags, "CompileError", st, module_path, "Imported module must be declaration-only: " + module_path)
  return DeclCheckResult(diags, true)
end function

function _declared_package(program)
  if typeof(program) != "array" or len(program) <= 0 then return "" end if
  for i = 0 to len(program) - 1
    st = program[i]
    if typeof(st) == "struct" and st.node_kind == "NamespaceDecl" and typeof(st.name) == "string" then
      return st.name
    end if
  end for
  return ""
end function

function _extract_imports(program)
  imports_chunks = []
  imports_tail = []
  if typeof(program) != "array" then return t.arr_chunked_finish(imports_chunks, imports_tail) end if
  if len(program) <= 0 then return t.arr_chunked_finish(imports_chunks, imports_tail) end if
  for i = 0 to len(program) - 1
    st = program[i]
    if typeof(st) == "struct" and st.node_kind == "Import" then
      appi = t.arr_chunked_push(imports_chunks, imports_tail, st, 32)
      imports_chunks = appi[0]
      imports_tail = appi[1]
    end if
  end for
  return t.arr_chunked_finish(imports_chunks, imports_tail)
end function

function _split_imports_nonimports(program)
  imports_chunks = []
  imports_tail = []
  body_chunks = []
  body_tail = []
  if typeof(program) != "array" then
    return [t.arr_chunked_finish(imports_chunks, imports_tail), t.arr_chunked_finish(body_chunks, body_tail)]
  end if
  if len(program) > 0 then
    for i = 0 to len(program) - 1
      st = program[i]
      if typeof(st) == "struct" and st.node_kind == "Import" then
        appi = t.arr_chunked_push(imports_chunks, imports_tail, st, 32)
        imports_chunks = appi[0]
        imports_tail = appi[1]
      else
        appb = t.arr_chunked_push(body_chunks, body_tail, st, 64)
        body_chunks = appb[0]
        body_tail = appb[1]
      end if
    end for
  end if
  return [t.arr_chunked_finish(imports_chunks, imports_tail), t.arr_chunked_finish(body_chunks, body_tail)]
end function

function _resolve_import(requested, base_dir, include_dirs)
  tried_seen = t.fastmap_new(128)
  matches_seen = t.fastmap_new(128)
  tried_b = t.arr_chunk_new(64)
  matches_b = t.arr_chunk_new(64)
  resolved = ""
  resolved_kind = ""
  resolved_root = ""
  if _is_abs_path(requested) then
    cpath = requested
    cnp = _path_norm_cached(cpath)
    if t.fastmap_has(tried_seen, cnp) == false then
      tried_seen = t.fastmap_set(tried_seen, cnp, 1)
      tried_b = t.arr_chunk_push(tried_b, cpath)
    end if
    if fs.exists(cpath) and t.fastmap_has(matches_seen, cnp) == false then
      matches_seen = t.fastmap_set(matches_seen, cnp, 1)
      matches_b = t.arr_chunk_push(matches_b, cpath)
      resolved = cpath
      resolved_kind = "abs"
      resolved_root = ""
    end if
  else
    cpath = fs.joinPath(base_dir, requested)
    cnp = _path_norm_cached(cpath)
    if t.fastmap_has(tried_seen, cnp) == false then
      tried_seen = t.fastmap_set(tried_seen, cnp, 1)
      tried_b = t.arr_chunk_push(tried_b, cpath)
    end if
    if fs.exists(cpath) and t.fastmap_has(matches_seen, cnp) == false then
      matches_seen = t.fastmap_set(matches_seen, cnp, 1)
      matches_b = t.arr_chunk_push(matches_b, cpath)
      if resolved == "" then
        resolved = cpath
        resolved_kind = "rel"
        resolved_root = base_dir
      end if
    end if

    if len(include_dirs) > 0 then
      for i = 0 to len(include_dirs) - 1
        cpath = fs.joinPath(include_dirs[i], requested)
        cnp = _path_norm_cached(cpath)
        if t.fastmap_has(tried_seen, cnp) == false then
          tried_seen = t.fastmap_set(tried_seen, cnp, 1)
          tried_b = t.arr_chunk_push(tried_b, cpath)
        end if
        if fs.exists(cpath) and t.fastmap_has(matches_seen, cnp) == false then
          matches_seen = t.fastmap_set(matches_seen, cnp, 1)
          matches_b = t.arr_chunk_push(matches_b, cpath)
          if resolved == "" then
            resolved = cpath
            resolved_kind = "include"
            resolved_root = include_dirs[i]
          end if
        end if
      end for
    end if
  end if

  // GetFullPathNameW canonicalizes mixed module-style separators to the
  // backslash form produced by Python's pathlib on Windows. Keep that display
  // path on AST nodes as well as using the case-folded form for lookup keys.
  if resolved != "" then
    resolved_abs = _path_abspath(resolved)
    if resolved_abs != "" then resolved = resolved_abs end if
  end if

  tried = t.arr_chunk_finish(tried_b)
  matches = t.arr_chunk_finish(matches_b)
  return ResolveResult(resolved, tried, matches, resolved_kind, resolved_root)
end function

function _resolve_import_cache_key(requested, base_dir)
  req = requested
  if typeof(req) != "string" then req = "" + req end if
#if TARGET_OS == "linux"
  return _path_norm_cached(base_dir) + "|" + req
#else
  return _path_norm_cached(base_dir) + "|" + s.toLowerAscii(req)
#endif
end function

function _resolve_import_cached(requested, base_dir, include_dirs)
  global _front_resolve_cache
  if typeof(_front_resolve_cache) != "struct" then _front_resolve_cache = t.fastmap_new(2048) end if
  key = _resolve_import_cache_key(requested, base_dir)
  hit = t.fastmap_get(_front_resolve_cache, key, 0)
  if typeof(hit) == "struct" then return hit end if
  rr = _resolve_import(requested, base_dir, include_dirs)
  _front_resolve_cache = t.fastmap_set(_front_resolve_cache, key, rr)
  return rr
end function

function _stack_contains(stack, path)
  cur = stack
  while typeof(cur) == "struct"
    if _path_eq(cur.path, path) then return true end if
    cur = cur.parent
  end while
  return false
end function

function _visited_contains(path)
  global _front_visited_set
  if typeof(_front_visited_set) != "struct" then return false end if
  return t.fastmap_has(_front_visited_set, _path_norm_cached(path))
end function

function _visited_add(visited, path)
  global _front_visited_set
  np = _path_norm_cached(path)
  if typeof(_front_visited_set) != "struct" then _front_visited_set = t.fastmap_new(4096) end if
  if t.fastmap_has(_front_visited_set, np) then return visited end if
  _front_visited_set = t.fastmap_set(_front_visited_set, np, 1)
  if typeof(visited) != "struct" then
    vb = t.arr_chunk_new(256)
    if typeof(visited) == "array" and len(visited) > 0 then
      for vi = 0 to len(visited) - 1
        vb = t.arr_chunk_push(vb, visited[vi])
      end for
    end if
    visited = vb
  end if
  return t.arr_chunk_push(visited, path)
end function

function _visited_finish(visited, fallback_entry)
  resv = visited
  if typeof(resv) == "struct" then resv = t.arr_chunk_finish(resv) end if
  if typeof(resv) != "array" or len(resv) <= 0 then
    resv = [fallback_entry]
  end if
  return resv
end function

function _parsed_module_get(parsed_modules, path)
  if typeof(parsed_modules) == "struct" then
    return t.fastmap_get(parsed_modules, _path_norm_cached(path), 0)
  end if
  if typeof(parsed_modules) != "array" or len(parsed_modules) <= 0 then return 0 end if
  for i = 0 to len(parsed_modules) - 1
    it = parsed_modules[i]
    if typeof(it) == "struct" and _path_eq(it.path, path) then
      return it
    end if
  end for
  return 0
end function

function _parsed_module_set(parsed_modules, path, source, program)
  if typeof(parsed_modules) != "struct" then
    pm = t.fastmap_new(256)
    if typeof(parsed_modules) == "array" and len(parsed_modules) > 0 then
      for pi = 0 to len(parsed_modules) - 1
        it0 = parsed_modules[pi]
        if typeof(it0) == "struct" and typeof(it0.path) == "string" then
          pm = t.fastmap_set(pm, _path_norm_cached(it0.path), it0)
        end if
      end for
    end if
    parsed_modules = pm
  end if
  rec = ParsedModule(path, source, program)
  return t.fastmap_set(parsed_modules, _path_norm_cached(path), rec)
end function

function _module_visit(path, entry_path, include_dirs, stack, visited, modules, aliases, parsed_modules, diags, keep_going, max_errors)
  if len(diags) >= max_errors then
    return FrontCheckResult(diags, visited, modules, aliases, parsed_modules)
  end if

  if _stack_contains(stack, path) then
    // import cycles are tolerated at loader level
    return FrontCheckResult(diags, visited, modules, aliases, parsed_modules)
  end if

  if _visited_contains(path) then
    return FrontCheckResult(diags, visited, modules, aliases, parsed_modules)
  end if

  if fs.exists(path) == false then
    diags = _add_diag(diags, "CompileError", path, 0, "Import file not found: " + path)
    return FrontCheckResult(diags, visited, modules, aliases, parsed_modules)
  end if

  parsed = 0
  if keep_going then
    parsed = frontend.parse_program_keepgoing(path, max_errors)
  else
    parsed = frontend.parse_program(path)
  end if

  if typeof(parsed) != "struct" then
    diags = _add_diag(diags, "CompileError", path, 0, "frontend.parse_program returned non-struct")
    return FrontCheckResult(diags, visited, modules, aliases, parsed_modules)
  end if

  if typeof(parsed.errors) == "array" and len(parsed.errors) > 0 then
    for ei = 0 to len(parsed.errors) - 1
      if len(diags) >= max_errors then break end if
      e = parsed.errors[ei]
      if typeof(e) == "struct" and typeof(e.message) == "string" then
        fn = path
        if typeof(e.filename) == "string" then fn = e.filename end if
        ep = 0
        if typeof(e.pos) == "int" then ep = e.pos end if
        diags = _add_diag(diags, "ParseError", fn, ep, e.message)
      else
        diags = _add_diag(diags, "ParseError", path, 0, "Unknown parser error")
      end if
    end for
    if keep_going == false then
      return FrontCheckResult(diags, visited, modules, aliases, parsed_modules)
    end if
    // keep-going mode: mark module as visited and continue with other files
    visited = _visited_add(visited, path)
    return FrontCheckResult(diags, visited, modules, aliases, parsed_modules)
  end if

  program = parsed.program
  pkg = _declared_package(program)
  modules = _module_set_package(modules, path, pkg)

  if _path_eq(path, entry_path) == false then
    if typeof(program) == "array" and len(program) > 0 then
      for si = 0 to len(program) - 1
        stx = program[si]
        // Fast-path for common declaration-only node kinds to avoid expensive helper calls.
        if typeof(stx) == "struct" then
          kx = stx.node_kind
          if kx == "FunctionDef" or kx == "StructDef" or kx == "NamespaceDecl" or kx == "ExternFunctionDef" or kx == "ExternFunctionDecl" or kx == "Assign" or kx == "SynchronizedDecl" or kx == "Import" then
            continue
          end if
        end if
        cr = _check_decl_stmt(stx, path, diags, keep_going, max_errors)
        diags = cr.diagnostics
        if cr.failed then
          if keep_going == false then
            return FrontCheckResult(diags, visited, modules, aliases, parsed_modules)
          end if
          visited = _visited_add(visited, path)
          return FrontCheckResult(diags, visited, modules, aliases, parsed_modules)
        end if
        if len(diags) >= max_errors then
          return FrontCheckResult(diags, visited, modules, aliases, parsed_modules)
        end if
      end for
    end if
  end if

  stack2 = PathStackNode(path, stack)
  base_dir = _dirname(path)
  splitp = _split_imports_nonimports(program)
  imports = splitp[0]
  part_for_codegen = splitp[1]
  source_text = ""
  if typeof(parsed.source) == "string" then source_text = parsed.source end if
  parsed_modules = _parsed_module_set(parsed_modules, path, source_text, part_for_codegen)
  // Keep the parsed AST rooted while recursive imports are loaded. The codegen
  // cache references these nodes later; dropping the local root here can let
  // nested expression nodes be reclaimed under GC pressure.
  if len(imports) > 0 then
    ii_box = [0]
    while ii_box[0] < len(imports)
      ii = ii_box[0]
      ii_box[0] = ii + 1
      if len(diags) >= max_errors then break end if
      if ii < 0 or ii >= len(imports) then break end if
      st = imports[ii]
      if typeof(st) != "struct" then continue end if
      req = st.path
      if typeof(req) != "string" then
        diags = _add_diag_from_stmt(diags, "CompileError", st, path, "Import statement missing path")
        if keep_going == false then
          return FrontCheckResult(diags, visited, modules, aliases, parsed_modules)
        end if
        continue
      end if

      rr = _resolve_import_cached(req, base_dir, include_dirs)
      if rr.resolved == "" then
        diags = _add_diag_from_stmt(diags, "CompileError", st, path, "Import file not found: " + req)
        if keep_going == false then
          return FrontCheckResult(diags, visited, modules, aliases, parsed_modules)
        end if
        continue
      end if
      if len(rr.matches) > 1 then
        diags = _add_diag_from_stmt(diags, "CompileError", st, path, "Ambiguous import: " + req)
        if keep_going == false then
          return FrontCheckResult(diags, visited, modules, aliases, parsed_modules)
        end if
        continue
      end if

      sub = _module_visit(rr.resolved, entry_path, include_dirs, stack2, visited, modules, aliases, parsed_modules, diags, keep_going, max_errors)
      diags = sub.diagnostics
      visited = sub.visited
      modules = sub.modules
      aliases = sub.aliases
      parsed_modules = sub.parsed_modules

      declared_pkg = _module_get_package(modules, rr.resolved)
      expected_pkg = _expected_package_for_file(rr.resolved, rr.resolved_kind, rr.resolved_root)
      // An aliased explicit file import is a code-behind import: the alias is
      // the compile-time package name, so the file need not live in a
      // package-shaped directory tree. Module imports still enforce it.
      alias_for_file_import = typeof(st.alias) == "string" and st.alias != "" and typeof(st.module) != "string"

      if declared_pkg != "" and expected_pkg != "" and declared_pkg != expected_pkg and alias_for_file_import == false then
        diags = _add_diag_from_stmt(
        diags,
        "CompileError",
        st,
        path,
        "File declares package " + declared_pkg + ", but was found as " + expected_pkg + ": " + rr.resolved
      )
        if keep_going == false then
          return FrontCheckResult(diags, visited, modules, aliases, parsed_modules)
        end if
      end if

      expected_mod = ""
      if typeof(st.module) == "string" then expected_mod = st.module end if
      if expected_mod != "" and declared_pkg != "" and declared_pkg != expected_mod then
        diags = _add_diag_from_stmt(
        diags,
        "CompileError",
        st,
        path,
        "Module import " + expected_mod + " points to file declaring package " + declared_pkg + ": " + rr.resolved
      )
        if keep_going == false then
          return FrontCheckResult(diags, visited, modules, aliases, parsed_modules)
        end if
      end if

      alias = ""
      if typeof(st.alias) == "string" then alias = st.alias end if
      if alias != "" then
        if alias == "try" or alias == "error" then
          diags = _add_diag_from_stmt(diags, "CompileError", st, path, "import alias '" + alias + "' is reserved")
          if keep_going == false then
            return FrontCheckResult(diags, visited, modules, aliases, parsed_modules)
          end if
          continue
        end if
        if declared_pkg == "" then
          diags = _add_diag_from_stmt(
          diags,
          "CompileError",
          st,
          path,
          "import ... as " + alias + " requires imported file to declare `package`: " + rr.resolved
        )
          if keep_going == false then
            return FrontCheckResult(diags, visited, modules, aliases, parsed_modules)
          end if
          continue
        end if
        prev = _alias_get(aliases, alias)
        if prev != "" and prev != declared_pkg then
          diags = _add_diag_from_stmt(
          diags,
          "CompileError",
          st,
          path,
          "import alias " + alias + " refers to multiple packages: " + prev + " and " + declared_pkg
        )
          if keep_going == false then
            return FrontCheckResult(diags, visited, modules, aliases, parsed_modules)
          end if
          continue
        end if
        aliases = _alias_set(aliases, alias, declared_pkg)
      else
        if declared_pkg != "" and _containsDot(declared_pkg) then
          implicit = _last_segment_after_dot(declared_pkg)
          if implicit != "try" and implicit != "error" then
            prev2 = _alias_get(aliases, implicit)
            if prev2 == "" then
              aliases = _alias_set(aliases, implicit, declared_pkg)
            else
              if prev2 != declared_pkg then
                diags = _add_diag_from_stmt(
                diags,
                "CompileError",
                st,
                path,
                "Implicit import alias '" + implicit + "' is ambiguous between packages " + prev2 + " and " + declared_pkg + ". Use 'import ... as <alias>' to disambiguate."
              )
                if keep_going == false then
                  return FrontCheckResult(diags, visited, modules, aliases, parsed_modules)
                end if
              end if
            end if
          end if
        end if
      end if
    end while
  end if

  visited = _visited_add(visited, path)
  return FrontCheckResult(diags, visited, modules, aliases, parsed_modules)
end function

function _front_body_contains_async(body)
  if typeof(body) != "array" or len(body) <= 0 then return false end if
  for i = 0 to len(body) - 1
    if _front_node_contains_async(body[i]) then return true end if
  end for
  return false
end function

// Async lowering uses the standard shared thread pool. Discover it before
// language lowering so programs do not need a synthetic source-level import.
function _front_node_contains_async(node)
  if typeof(node) != "struct" then return false end if
  kind = try(node.node_kind)
  if kind == "FunctionDef" then
    if typeof(try(node.is_async)) == "bool" and node.is_async then return true end if
    return _front_body_contains_async(try(node.body))
  end if
  if kind == "NamespaceDef" then return _front_body_contains_async(try(node.body)) end if
  if kind == "StructDef" then
    methods = try(node.methods)
    if typeof(methods) == "array" and len(methods) > 0 then
      for i = 0 to len(methods) - 1
        if _front_node_contains_async(methods[i]) then return true end if
      end for
    end if
    return false
  end if
  if kind == "If" then
    if _front_body_contains_async(try(node.then_body)) then return true end if
    elifs = try(node.elifs)
    if typeof(elifs) == "array" and len(elifs) > 0 then
      for i = 0 to len(elifs) - 1
        if typeof(elifs[i]) == "array" and len(elifs[i]) >= 2 and _front_body_contains_async(elifs[i][1]) then return true end if
      end for
    end if
    return _front_body_contains_async(try(node.else_body))
  end if
  if kind == "Switch" then
    cases = try(node.cases)
    if typeof(cases) == "array" and len(cases) > 0 then
      for i = 0 to len(cases) - 1
        if _front_body_contains_async(try(cases[i].body)) then return true end if
      end for
    end if
    return _front_body_contains_async(try(node.default_body))
  end if
  nested = try(node.body)
  if typeof(nested) == "array" then return _front_body_contains_async(nested) end if
  return false
end function

function _run_frontcheck(entry, include_dirs, keep_going, max_errors)
  global _path_norm_cache, _front_visited_set, _front_resolve_cache
  _path_norm_cache = t.fastmap_new(4096)
  _front_visited_set = t.fastmap_new(4096)
  _front_resolve_cache = t.fastmap_new(2048)

  entry_abs = _path_abspath(entry)
  if entry_abs == "" then entry_abs = entry end if

  dirs_seen = t.fastmap_new(128)
  dirs_chunks = []
  dirs_tail = []
  d0 = _dirname(entry_abs)
  nd0 = _path_norm_cached(d0)
  dirs_seen = t.fastmap_set(dirs_seen, nd0, 1)
  appd0 = t.arr_chunked_push(dirs_chunks, dirs_tail, d0, 8)
  dirs_chunks = appd0[0]
  dirs_tail = appd0[1]
  if len(include_dirs) > 0 then
    for i = 0 to len(include_dirs) - 1
      di = _path_abspath(include_dirs[i])
      if di == "" then di = include_dirs[i] end if
      ndi = _path_norm_cached(di)
      if t.fastmap_has(dirs_seen, ndi) == false then
        dirs_seen = t.fastmap_set(dirs_seen, ndi, 1)
        appdi = t.arr_chunked_push(dirs_chunks, dirs_tail, di, 8)
        dirs_chunks = appdi[0]
        dirs_tail = appdi[1]
      end if
    end for
  end if
  dirs = t.arr_chunked_finish(dirs_chunks, dirs_tail)
  res = _module_visit(
    entry_abs,
    entry_abs,
    dirs,
    0,
    t.arr_chunk_new(256),
    t.fastmap_new(512),
    t.fastmap_new(128),
    t.fastmap_new(256),
    [],
    keep_going,
    max_errors
  )
  scan_paths = _visited_finish(res.visited, entry_abs)
  needs_async_pool = false
  if len(scan_paths) > 0 then
    for spi = 0 to len(scan_paths) - 1
      module_rec = _parsed_module_get(res.parsed_modules, scan_paths[spi])
      if typeof(module_rec) == "struct" and _front_body_contains_async(module_rec.program) then
        needs_async_pool = true
        break
      end if
    end for
  end if
  if needs_async_pool then
    pool_resolve = _resolve_import_cached("std/concurrent/thread_pool.ml", d0, dirs)
    if pool_resolve.resolved == "" then
      res.diagnostics = _add_diag(res.diagnostics, "CompileError", entry_abs, 0, "Import file not found: std/concurrent/thread_pool.ml")
    else
      res = _module_visit(pool_resolve.resolved, entry_abs, dirs, 0, res.visited, res.modules, res.aliases, res.parsed_modules, res.diagnostics, keep_going, max_errors)
    end if
  end if
  return FrontCheckResult(res.diagnostics, _visited_finish(res.visited, entry_abs), res.modules, _alias_to_array(res.aliases), res.parsed_modules)
end function

function _print_diag(d)
  if typeof(d) != "struct" then
    print "CompileError: invalid diagnostic"
    return
  end if

  fn = d.filename
  if typeof(fn) != "string" then fn = "<unknown>" end if
  pos = d.pos
  if typeof(pos) != "int" then pos = 0 end if
  msg = d.message
  if typeof(msg) != "string" then msg = "unknown error" end if
  kind = d.kind
  if typeof(kind) != "string" then kind = "CompileError" end if

  if fs.exists(fn) then
    src = fs.readAllText(fn)
    if typeof(src) == "string" then
      src = frontend.normalize_code_for_tokenizer(src)
      print parser.format_error(src, fn, pos, msg, kind)
      return
    end if
  end if

  print kind + ": " + msg + "\n  at " + fn + " pos=" + pos
end function

function _collect_include_dirs(args)
  dirs =[]
  i = 0
  while i < len(args)
    a = args[i]
    if a == "-I" or a == "--import-path" then
      if i + 1 < len(args) then
        dirs = _append_unique_path(dirs, args[i + 1])
      end if
      i = i + 2
      continue
    end if
    if _startsWith(a, "-I") and len(a) > 2 then
      dirs = _append_unique_path(dirs, s.substr(a, 2, len(a) - 2))
      i = i + 1
      continue
    end if
    i = i + 1
  end while
  return dirs
end function

function _has_flag(args, flag)
  if len(args) <= 0 then return false end if
  for i = 0 to len(args) - 1
    if args[i] == flag then return true end if
  end for
  return false
end function

function _get_self_max_errors(args)
  i = 0
  while i < len(args)
    if args[i] == "--self-max-errors" then
      if i + 1 < len(args) then
        n = _to_int_or(20, args[i + 1])
        if n > 0 then return n end if
      end if
      return 20
    end if
    i = i + 1
  end while
  return 20
end function

function _get_max_errors(args)
  i = 0
  while i < len(args)
    if args[i] == "--max-errors" then
      if i + 1 < len(args) then
        n = _to_int_or(20, args[i + 1])
        if n > 0 then return n end if
      end if
      return 20
    end if
    i = i + 1
  end while
  return 20
end function

function _size_suffix_mul(ch)
  if ch == "k" then return 1024 end if
  if ch == "m" then return 1024 * 1024 end if
  if ch == "g" then return 1024 * 1024 * 1024 end if
  return -1
end function

function _parse_size_text(txt)
  if typeof(txt) != "string" or txt == "" then
    return ["", -1]
  end if
  x = s.toLowerAscii(txt)
  n = len(x)
  if n <= 0 then return ["", -1] end if

  last = x[n - 1]
  mul = _size_suffix_mul(last)
  numtxt = x
  if mul > 0 then
    if n <= 1 then return ["invalid size", -1] end if
    numtxt = s.substr(x, 0, n - 1)
  else
    b = bytes(last)
    c = 0
    if len(b) > 0 then c = b[0] end if
    if c < 48 or c > 57 then
      return ["invalid size suffix", -1]
    end if
    mul = 1
  end if

  base = toNumber(numtxt)
  if typeof(base) != "int" then
    return ["invalid size", -1]
  end if
  if base <= 0 then
    return ["invalid size", -1]
  end if
  return ["", base * mul]
end function

function _validate_size_flags(args)
  i = 0
  while i < len(args)
    a = args[i]
    if a == "--heap-reserve" or a == "--heap-commit" or a == "--heap-grow" or a == "--heap-shrink-min" or a == "--gc-limit" then
      if i + 1 >= len(args) then
        return "invalid size"
      end if
      pv = _parse_size_text(args[i + 1])
      if pv[0] != "" then
        return pv[0] + ": " + args[i + 1]
      end if
      i = i + 2
      continue
    end if
    i = i + 1
  end while
  return ""
end function

function _cfg_set(cfg, key, value)
  if typeof(cfg) != "array" then cfg = [] end if
  if len(cfg) > 0 then
    for i = 0 to len(cfg) - 1
      it = cfg[i]
      if typeof(it) == "array" and len(it) >= 2 and typeof(it[0]) == "string" and it[0] == key then
        cfg[i] = [key, value]
        return cfg
      end if
      if typeof(it) == "struct" and typeof(it.key) == "string" and it.key == key then
        cfg[i] = [key, value]
        return cfg
      end if
    end for
  end if
  return cfg + [[key, value]]
end function

function _cfg_get_int(cfg, key, defaultv)
  if typeof(cfg) != "array" or len(cfg) <= 0 then return defaultv end if
  for i = 0 to len(cfg) - 1
    it = cfg[i]
    if typeof(it) == "array" and len(it) >= 2 and typeof(it[0]) == "string" and it[0] == key then
      if typeof(it[1]) == "int" then return it[1] end if
      return defaultv
    end if
    if typeof(it) == "struct" and typeof(it.key) == "string" and it.key == key then
      if typeof(it.value) == "int" then return it.value end if
      return defaultv
    end if
  end for
  return defaultv
end function

function _collect_runtime_config(args)
  cfg = []
  i = 0
  while i < len(args)
    a = args[i]

    if a == "--heap-shrink" then
      cfg = _cfg_set(cfg, "shrink_enabled", true)
      i = i + 1
      continue
    end if
    if a == "--no-gc-periodic" then
      cfg = _cfg_set(cfg, "gc_disable_periodic", true)
      i = i + 1
      continue
    end if

    key = ""
    if a == "--heap-reserve" then key = "reserve_bytes" end if
    if a == "--heap-commit" then key = "commit_bytes" end if
    if a == "--heap-grow" then key = "grow_min_bytes" end if
    if a == "--heap-shrink-min" then key = "shrink_min_bytes" end if
    if a == "--gc-limit" then key = "gc_bytes_limit" end if
    if key != "" then
      if i + 1 < len(args) then
        pv = _parse_size_text(args[i + 1])
        if pv[0] == "" and typeof(pv[1]) == "int" and pv[1] > 0 then
          cfg = _cfg_set(cfg, key, pv[1])
        end if
      end if
      i = i + 2
      continue
    end if

    i = i + 1
  end while
  return cfg
end function

function _compiler_gc_limit_from_config(runtime_config)
  compiler_gc_limit = _cfg_get_int(runtime_config, "compiler_gc_limit_bytes", 0)
  if compiler_gc_limit <= 0 then
    // `gc_bytes_limit` belongs to the generated target.  Reusing it for the
    // self-hosted compiler made target flags such as `--gc-limit 1m` trigger
    // collections inside virtually every emitter call and could change the
    // generated program. Canonical object builds retain shared section pages
    // until the support tail is complete; the compiler image itself can make
    // that live set exceed 1.5 GiB. Large phases perform explicit, rooted
    // collections, so keep automatic compiler GC above that live set.
    compiler_gc_limit = 3072 << 20
  end if
  return compiler_gc_limit
end function

// Extract the path-like portion of a top-level import for the lightweight
// automatic-pipeline graph scan. The real parser still owns validation.
function _auto_import_request(line)
  text = s.trim(line)
  if _startsWith(text, "import ") == false then return "" end if
  text = s.trim(s.substr(text, 7, len(text) - 7))
  if text == "" then return "" end if
  if text[0] == "\"" then
    close = s.indexOf(text, "\"", 1)
    if typeof(close) != "int" or close <= 1 then return "" end if
    return s.substr(text, 1, close - 1)
  end if
  stop = len(text)
  for i = 0 to len(text) - 1
    if text[i] == " " or text[i] == "\t" or text[i] == "\r" then
      stop = i
      break
    end if
  end for
  module_name = s.substr(text, 0, stop)
  if module_name == "" then return "" end if
  return s.replaceAll(module_name, ".", "/") + ".ml"
end function

// Walk only enough of the import graph to cross the large-build threshold.
// This avoids a second parse while still seeing thin entrypoints that import a
// large compiler or application module. Read/resolve failures merely keep the
// conservative monolithic default; the real frontend reports them later.
function _auto_object_pipeline_score_visit(path, include_dirs, seen, score)
  if score >= AUTO_OBJECT_PIPELINE_SCORE then return [AUTO_OBJECT_PIPELINE_SCORE, seen] end if
  absolute = _path_abspath(path)
  if absolute == "" then absolute = path end if
  key = _path_norm_cached(absolute)
  if t.fastmap_has(seen, key) then return [score, seen] end if
  seen = t.fastmap_set(seen, key, 1)
  source = fs.readAllText(absolute)
  if typeof(source) != "string" then return [score, seen] end if
  score = score + len(source)
  if score >= AUTO_OBJECT_PIPELINE_SCORE then return [AUTO_OBJECT_PIPELINE_SCORE, seen] end if
  lines = s.split(source, "\n")
  if typeof(lines) == "array" and len(lines) > 0 then
    for i = 0 to len(lines) - 1
      request = _auto_import_request(lines[i])
      if request == "" then continue end if
      rr = _resolve_import(request, _dirname(absolute), include_dirs)
      if typeof(rr) == "struct" and typeof(rr.resolved) == "string" and rr.resolved != "" then
        visited = _auto_object_pipeline_score_visit(rr.resolved, include_dirs, seen, score)
        score = visited[0]
        seen = visited[1]
        if score >= AUTO_OBJECT_PIPELINE_SCORE then break end if
      end if
    end for
  end if
  return [score, seen]
end function

function _auto_object_pipeline_score(input_ml, include_dirs)
  result = _auto_object_pipeline_score_visit(input_ml, include_dirs, t.fastmap_new(128), 0)
  return result[0]
end function

function _collect_compile_defines(args)
  specs = []
  i = 0
  while i < len(args)
    value = args[i]
    if value == "-D" or value == "--define" then
      if i + 1 >= len(args) then return parser.newParseError(value + " expects NAME[=VALUE]", 0, "<command-line>") end if
      specs = specs + [args[i + 1]]
      i = i + 2
      continue
    end if
    if _startsWith(value, "-D") and len(value) > 2 then
      specs = specs + [s.substr(value, 2, len(value) - 2)]
    else if _startsWith(value, "--define=") and len(value) > 9 then
      specs = specs + [s.substr(value, 9, len(value) - 9)]
    end if
    i = i + 1
  end while
  return parser.set_compile_defines(specs)
end function

function _fresh_link_gc_limit_from_config(runtime_config)
  limit = _compiler_gc_limit_from_config(runtime_config)
  // Linking a self-host build keeps combined sections and a million-label
  // index alive at once.  A 128 MiB cap guarantees repeated full collections.
  link_limit = 1536 << 20
  if limit <= 0 then return link_limit end if
  if limit > link_limit then return link_limit end if
  return limit
end function

function _parse_subsystem_value(v)
  x = s.toLowerAscii(s.trim("" + v))
  if x == "console" or x == "cui" then return [true, 3] end if
  if x == "windows" or x == "window" or x == "gui" then return [true, 2] end if
  n = toNumber(x)
  if typeof(n) == "int" and (n == 2 or n == 3) then return [true, n] end if
  return [false, 3]
end function

function _get_subsystem(args)
  i = 0
  while i < len(args)
    if args[i] == "--subsystem" then
      if i + 1 >= len(args) then return [false, 3] end if
      return _parse_subsystem_value(args[i + 1])
    end if
    i = i + 1
  end while
  return [true, 3]
end function

function _stmt_is_import(st)
  if typeof(st) != "struct" then return false end if
  return st.node_kind == "Import"
end function

function _compact_codegen_state_for_pe(st)
  if typeof(st) != "struct" then return st end if
  st.source = ""
  st.filename = ""
  st.import_aliases = []
  st.extern_sigs = []
  st.extern_abi_structs = []
  st.extern_structs = []
  st.heap_config = []
  st.break_stack = []
  st.struct_fields = []
  st.struct_ids = []
  st.enum_variants = []
  st.enum_ids = []
  st.value_enum_values = []
  st.reserved_identifiers = []
  st.used_helpers = []
  st.scope_stack = []
  st.scope_declared = []
  st.global_slots = []
  st.globals = []
  st.func_globals = []
  st.func_global_map = []
  st.function_locals = []
  st.current_qname_prefix = ""
  st.current_file_prefix = ""
  st.file_prefix_map = []
  st.typename_struct_by_id = []
  st.typename_struct_by_qname = []
  st.typename_enum_by_id = []
  st.typename_enum_by_qname = []
  st.user_functions = []
  st.nested_user_functions = []
  st.struct_methods = []
  st.struct_static_methods = []
  st.function_global_labels = []
  st.struct_global_labels = []
  st.builtin_specs = []
  st.builtin_global_labels = []
  st.extern_global_labels = []
  st.extern_stub_labels = []
  st.function_static_obj_labels = []
  st.struct_static_obj_labels = []
  st.builtin_static_obj_labels = []
  st.extern_static_obj_labels = []
  st.diagnostics = []
  st.dbg_line_starts = []
  st.current_fn_boxed_names = []
  st.current_fn_env_index = []
  st.scope_index_stack = []
  st.scope_declared_index_stack = []
  st.func_global_map_index = []
  st.user_function_index = []
  st.function_codegen_name_map = []
  st.qualify_cache = []
  st.struct_fields_index = []
  st.struct_ids_index = []
  st.enum_variants_index = []
  st.enum_ids_index = []
  st.struct_methods_index = []
  st.struct_static_methods_index = []
  st.extern_sig_index = []
  st.import_alias_index = []
  st._expr_temp_reg_order = []
  st._expr_temp_reg_live = []
  st._expr_temp_reg_live_by_reg = []
  st._expr_temp_reg_reserved = []
  st._cold_block_stack = []
  st._inline_param_stack = []
  st._inline_call_stack = []
  st._inline_emitted_bytes = t.fastmap_new(128)
  st.known_int_names = []
  st.known_value_types = []
  st.loop_index_fast_stack = []
  st.inline_only_functions = []
  st.pruned_inline_functions = []
  st._global_owner_file = []
  st._module_init_status_labels = []
  st.ext_widebuf_labels = []
  st.decl_site_bindings = []
  st.function_local_ids = []
  st._module_init_active = false
  st._module_init_active_file = ""
  st._global_owner_file = ""
  st._module_init_status_labels = []
  return st
end function

function _filter_non_import_stmts(program)
  vals_chunks = []
  vals_tail = []
  if typeof(program) != "array" then return t.arr_chunked_finish(vals_chunks, vals_tail) end if
  if len(program) <= 0 then return t.arr_chunked_finish(vals_chunks, vals_tail) end if
  for i = 0 to len(program) - 1
    st = program[i]
    if _stmt_is_import(st) then continue end if
    appv = t.arr_chunked_push(vals_chunks, vals_tail, st, 64)
    vals_chunks = appv[0]
    vals_tail = appv[1]
  end for
  return t.arr_chunked_finish(vals_chunks, vals_tail)
end function

function _merge_array_chunks_balanced(chunks)
  return t.arr_merge_chunks_balanced(chunks)
end function

function _label_get(arr, key, defaultv)
  if typeof(arr) != "array" or len(arr) <= 0 then return defaultv end if
  i = len(arr) - 1
  while i >= 0
    it = arr[i]
    if typeof(it) == "struct" and it.key == key then
      if typeof(it.value) == "int" then return it.value end if
      return defaultv
    end if
    i = i - 1
  end while
  return defaultv
end function

function _label_set(arr, key, value)
  if typeof(arr) != "array" then arr =[] end if
  if len(arr) > 0 then
    for i = 0 to len(arr) - 1
      it = arr[i]
      if typeof(it) == "struct" and it.key == key then
        arr[i] = StrIntPair(key, value)
        return arr
      end if
    end for
  end if
  return arr +[StrIntPair(key, value)]
end function

function _label_get_chunked(chunks, tail, key, defaultv)
  if typeof(tail) == "array" and len(tail) > 0 then
    i = len(tail) - 1
    while i >= 0
      it = tail[i]
      if typeof(it) == "struct" and it.key == key then
        if typeof(it.value) == "int" then return it.value end if
        return defaultv
      end if
      i = i - 1
    end while
  end if
  if typeof(chunks) == "array" and len(chunks) > 0 then
    ci = len(chunks) - 1
    while ci >= 0
      ch = chunks[ci]
      if typeof(ch) == "array" and len(ch) > 0 then
        j = len(ch) - 1
        while j >= 0
          it2 = ch[j]
          if typeof(it2) == "struct" and it2.key == key then
            if typeof(it2.value) == "int" then return it2.value end if
            return defaultv
          end if
          j = j - 1
        end while
      end if
      ci = ci - 1
    end while
  end if
  return defaultv
end function

function _imports_to_pe_imports(imports)
  vals_chunks = []
  vals_tail = []
  if typeof(imports) != "array" or len(imports) <= 0 then return t.arr_chunked_finish(vals_chunks, vals_tail) end if
  for i = 0 to len(imports) - 1
    it = imports[i]
    dll = ""
    funcs = []
    if typeof(it) == "array" and len(it) >= 2 then
      dll = _coerce_name(it[0])
      if typeof(it[1]) == "array" then funcs = it[1] end if
    else
      if typeof(it) != "struct" then continue end if
      if typeof(it.key) == "string" then dll = it.key end if
      if typeof(it.values) == "array" then funcs = it.values end if
    end if
    if dll == "" then continue end if
    appv = t.arr_chunked_push(vals_chunks, vals_tail, pe.ImportDll(dll, funcs), 16)
    vals_chunks = appv[0]
    vals_tail = appv[1]
  end for
  return t.arr_chunked_finish(vals_chunks, vals_tail)
end function

function _dll_base(dll)
  if typeof(dll) != "string" then return "dll" end if
  x = s.toLowerAscii(s.replaceAll(dll, "\\", "/"))
  parts = s.split(x, "/")
  if typeof(parts) == "array" and len(parts) > 0 then
    x = parts[len(parts) - 1]
  end if
  if _endsWith(x, ".dll") then
    x = s.substr(x, 0, len(x) - 4)
  end if
  name = ""
  for i = 0 to len(x) - 1
    ch = x[i]
    b = bytes(ch)
    c = 0
    if len(b) > 0 then c = b[0] end if
    if (c >= 97 and c <= 122) or (c >= 48 and c <= 57) or ch == "_" then
      name = name + ch
    else
      name = name + "_"
    end if
  end for
  if name == "" then name = "dll" end if
  return name
end function

function _coerce_name(v)
  if typeof(v) == "string" then return v end if
  if typeof(v) == "struct" then
    nm = try(v.name)
    if typeof(nm) == "string" then return nm end if
    vv = try(v.value)
    if typeof(vv) == "string" then return vv end if
    key = try(v.key)
    if typeof(key) == "string" then return key end if
    nk = try(v.node_kind)
    if typeof(nk) == "string" then
      fn = try(v._filename)
      pos = try(v._pos)
      if typeof(fn) == "string" and fn != "" and typeof(pos) == "int" then
        return nk + "@" + fn + ":" + pos
      end if
      return nk
    end if
    kind = try(v.kind)
    if typeof(kind) == "string" then return kind end if
    return "struct"
  end if
  if typeof(v) == "array" then return "array:" + len(v) end if
  if typeof(v) == "void" then return "void" end if
  return typeof(v)
end function

function _st_file(st)
  if typeof(st) == "struct" and typeof(st._filename) == "string" then return st._filename end if
  return ""
end function

function _mlo_import_get_funcs(imports, dll)
  if typeof(imports) != "array" or len(imports) <= 0 then return [] end if
  for i = 0 to len(imports) - 1
    it = imports[i]
    if typeof(it) != "array" or len(it) < 2 then continue end if
    if _coerce_name(it[0]) != dll then continue end if
    if typeof(it[1]) == "array" then return it[1] end if
    return []
  end for
  return []
end function

function _mlo_import_set_funcs(imports, dll, funcs)
  if typeof(imports) != "array" then imports = [] end if
  if len(imports) > 0 then
    for i = 0 to len(imports) - 1
      it = imports[i]
      if typeof(it) != "array" or len(it) < 2 then continue end if
      if _coerce_name(it[0]) == dll then
        imports[i] = [dll, funcs]
        return imports
      end if
    end for
  end if
  return imports + [[dll, funcs]]
end function

function _mlo_merge_imports(dst, src)
  if typeof(src) != "array" or len(src) <= 0 then return dst end if
  merged = dst
  if typeof(merged) != "array" then merged = [] end if
  for i = 0 to len(src) - 1
    it = src[i]
    if typeof(it) != "array" or len(it) < 2 then continue end if
    dll = _coerce_name(it[0])
    funcs = []
    if typeof(it[1]) == "array" then funcs = it[1] end if
    if dll == "" then continue end if
    cur = _mlo_import_get_funcs(merged, dll)
    if typeof(funcs) == "array" and len(funcs) > 0 then
      for fi = 0 to len(funcs) - 1
        fn = _coerce_name(funcs[fi])
        if fn == "" then continue end if
        if _array_contains(cur, fn) == false then
          cur = cur + [fn]
        end if
      end for
    end if
    merged = _mlo_import_set_funcs(merged, dll, cur)
  end for
  return merged
end function

function _mlo_labels_from_arr(arr)
  out_b = t.arr_chunk_new(64)
  if typeof(arr) == "array" and len(arr) > 0 then
    for i = 0 to len(arr) - 1
      it = arr[i]
      if typeof(it) != "struct" then continue end if
      nm = _coerce_name(try(it.name))
      off = 0
      off0 = try(it.offset)
      if typeof(off0) == "int" then
        off = off0
      else
        pos0 = try(it.pos)
        if typeof(pos0) == "int" then off = pos0 end if
      end if
      if nm == "" then continue end if
      out_b = t.arr_chunk_push(out_b, MloLabel(nm, off))
    end for
  end if
  return t.arr_chunk_finish(out_b)
end function

function _mlo_labels_from_asm_labels(arr)
  out_b = t.arr_chunk_new(64)
  if typeof(arr) == "array" and len(arr) > 0 then
    for i = 0 to len(arr) - 1
      it = arr[i]
      if typeof(it) != "struct" then continue end if
      nm = _coerce_name(try(it.name))
      off = 0
      pos0 = try(it.pos)
      if typeof(pos0) == "int" then
        off = pos0
      else
        off0 = try(it.offset)
        if typeof(off0) == "int" then off = off0 end if
      end if
      if nm == "" then continue end if
      out_b = t.arr_chunk_push(out_b, MloLabel(nm, off))
    end for
  end if
  return t.arr_chunk_finish(out_b)
end function

// Resolve targets already defined in this text fragment directly in the
// materialized bytes. Only cross-fragment relocations need to survive in an
// MLO object, which avoids serializing and later retaining millions of local
// branch records during large self-hosted builds. The reader still accepts
// numeric MLO v2 targets written by older compilers.
function _mlo_patches_from_asm(arr, label_pos_map, text_buf)
  out_b = t.arr_chunk_new(64)
  if typeof(arr) == "array" and len(arr) > 0 then
    for i = 0 to len(arr) - 1
      it = arr[i]
      if typeof(it) != "struct" then continue end if
      pos = 0
      pos0 = try(it.pos)
      if typeof(pos0) == "int" then
        pos = pos0
      else
        off0 = try(it.offset)
        if typeof(off0) == "int" then pos = off0 end if
      end if
      trg = _coerce_name(try(it.target))
      kind = _coerce_name(try(it.kind))
      if trg == "" or trg == "unknown" or kind == "" or kind == "unknown" then continue end if
      local_target = -1
      if typeof(label_pos_map) == "struct" then
        local_target = t.fastmap_get(label_pos_map, trg, -1)
      end if
      if typeof(local_target) == "int" and local_target >= 0 then
        // Both supported text relocation kinds use an x64 signed rel32 whose
        // origin is the byte immediately following the four-byte field.
        if (kind == "rel32" or kind == "rip32") and typeof(text_buf) == "bytes" and pos >= 0 and pos + 3 < len(text_buf) then
          disp = local_target - (pos + 4)
          text_buf[pos] = disp & 0xFF
          text_buf[pos + 1] = (disp >> 8) & 0xFF
          text_buf[pos + 2] = (disp >> 16) & 0xFF
          text_buf[pos + 3] = (disp >> 24) & 0xFF
        else
          // Preserve malformed or future relocation kinds for link-time
          // validation rather than silently discarding them.
          out_b = t.arr_chunk_push(out_b, MloPatch(pos, local_target, kind))
        end if
      else
        out_b = t.arr_chunk_push(out_b, MloPatch(pos, trg, kind))
      end if
    end for
  end if
  return t.arr_chunk_finish(out_b)
end function

function _mlo_patches_from_data(arr)
  out_b = t.arr_chunk_new(64)
  if typeof(arr) == "array" and len(arr) > 0 then
    for i = 0 to len(arr) - 1
      it = arr[i]
      if typeof(it) != "struct" then continue end if
      pos = 0
      off0 = try(it.offset)
      if typeof(off0) == "int" then
        pos = off0
      else
        pos0 = try(it.pos)
        if typeof(pos0) == "int" then pos = pos0 end if
      end if
      trg = _coerce_name(try(it.target))
      kind = _coerce_name(try(it.kind))
      if trg == "" or trg == "unknown" or kind == "" or kind == "unknown" then continue end if
      out_b = t.arr_chunk_push(out_b, MloPatch(pos, trg, kind))
    end for
  end if
  return t.arr_chunk_finish(out_b)
end function

function _mlo_imports_from_state(imports)
  out_b = t.arr_chunk_new(16)
  if typeof(imports) == "array" and len(imports) > 0 then
    for i = 0 to len(imports) - 1
      it = imports[i]
      if typeof(it) != "struct" then continue end if
      dll = ""
      funcs = []
      if typeof(it.key) == "string" then dll = it.key end if
      if typeof(it.values) == "array" then funcs = it.values end if
      if dll == "" then continue end if
      out_b = t.arr_chunk_push(out_b, [dll, funcs])
    end for
  end if
  return t.arr_chunk_finish(out_b)
end function

function _slice_used_bytes(buf, used)
  if typeof(buf) != "bytes" then return bytes(0) end if
  n = len(buf)
  if typeof(used) == "int" and used >= 0 and used <= n then
    n = used
  end if
  if n == len(buf) then return buf end if
  compact = bytes(n, 0)
  if n > 0 then copyBytes(compact, 0, buf, 0, n) end if
  return compact
end function

function _mlo_from_state(kind, module_file, entry_label, st)
  asm_labels = []
  asm_patches = []
  asm_label_pos_map = 0
  text_buf = bytes(0)
  if typeof(st.asm) == "struct" then
    asm_label_pos_map = st.asm.label_pos_map
    asm_labels = a.get_labels(st.asm)
    folded_asm = a.materialize_and_fold_local_patches(st.asm)
    st.asm = folded_asm[0]
    asm_patches = folded_asm[1]
    if typeof(st.asm.buf) == "bytes" then
      text_buf = _slice_used_bytes(st.asm.buf, st.asm.size)
    end if
  end if

  rdata_buf = bytes(0)
  if typeof(st.rdata) == "struct" then
    rdata_buf = _slice_used_bytes(st.rdata.data, st.rdata.used)
  end if

  data_buf = bytes(0)
  if typeof(st.data) == "struct" then
    data_buf = _slice_used_bytes(st.data.data, st.data.used)
  end if

  bss_size = 0
  bss_labels = []
  if typeof(st.bss) == "struct" then
    if typeof(st.bss.size) == "int" then bss_size = st.bss.size end if
    bss_labels = _mlo_labels_from_arr(st.bss.labels)
  end if

  rdata_labels = []
  rdata_patches = []
  if typeof(st.rdata) == "struct" then
    rdata_labels = _mlo_labels_from_arr(d.rdata_get_labels(st.rdata))
    rdata_patches = _mlo_patches_from_data(d.rdata_get_patches(st.rdata))
  end if

  data_labels = []
  data_patches = []
  if typeof(st.data) == "struct" then
    data_labels = _mlo_labels_from_arr(d.data_get_labels(st.data))
    data_patches = _mlo_patches_from_data(d.data_get_patches(st.data))
  end if

  return MloObject(
    kind,
    module_file,
    entry_label,
    text_buf,
    rdata_buf,
    data_buf,
    bss_size,
    _mlo_exported_text_labels(asm_labels, entry_label, rdata_patches, data_patches),
    _mlo_patches_from_asm(asm_patches, asm_label_pos_map, text_buf),
    rdata_labels,
    rdata_patches,
    data_labels,
    data_patches,
    bss_labels,
    _mlo_imports_from_state(st.imports)
  )
end function

function _mlo_labels_after(labels, prefix_off)
  out_b = t.arr_chunk_new(64)
  if typeof(labels) == "array" and len(labels) > 0 then
    for i = 0 to len(labels) - 1
      lb = labels[i]
      if typeof(lb) != "struct" then continue end if
      if typeof(lb.offset) != "int" or lb.offset < prefix_off then continue end if
      out_b = t.arr_chunk_push(out_b, MloLabel(_coerce_name(lb.name), lb.offset - prefix_off))
    end for
  end if
  return t.arr_chunk_finish(out_b)
end function

function _mlo_patches_after(patches, prefix_off)
  out_b = t.arr_chunk_new(64)
  if typeof(patches) == "array" and len(patches) > 0 then
    for i = 0 to len(patches) - 1
      pt = patches[i]
      if typeof(pt) != "struct" then continue end if
      off0 = try(pt.offset)
      if typeof(off0) != "int" or off0 < prefix_off then continue end if
      trg = _coerce_name(try(pt.target))
      kind = _coerce_name(try(pt.kind))
      if trg == "" or trg == "unknown" or kind == "" or kind == "unknown" then continue end if
      out_b = t.arr_chunk_push(out_b, MloPatch(off0 - prefix_off, trg, kind))
    end for
  end if
  return t.arr_chunk_finish(out_b)
end function

// Only labels that can be referenced from another canonical object need to
// enter the MLO symbol table. Same-fragment rel32/rip32 targets are carried as
// numeric MLO-v2 offsets, so their private control-flow names are no longer
// needed. Keeping them made the linker hash more than a million dead names
// during a compiler self-build.
function _mlo_is_exported_text_label(name, entry_label, required_targets)
  if typeof(name) != "string" or name == "" then return false end if
  if name == entry_label or name == "__ml_entry" or name == "_start" then return true end if
  if _startsWith(name, "modinit_") then return true end if
  if _startsWith(name, "fn_") then
    if _startsWith(name, "fn_ret_") or _startsWith(name, "fn_defer_") then return false end if
    return true
  end if
  if typeof(required_targets) == "struct" and t.fastmap_has(required_targets, name) then return true end if
  return false
end function

function _mlo_exported_text_labels(asm_labels, entry_label, rdata_patches, data_patches)
  global _dump_labels_path
  // A label dump is a debugging contract and intentionally retains internal
  // control-flow names. They do not change the linked executable bytes.
  if typeof(_dump_labels_path) == "string" and _dump_labels_path != "" then
    return _mlo_labels_from_asm_labels(asm_labels)
  end if

  required_targets = t.fastmap_new(64)
  patch_sets = [rdata_patches, data_patches]
  for psi = 0 to len(patch_sets) - 1
    patches = patch_sets[psi]
    if typeof(patches) != "array" or len(patches) <= 0 then continue end if
    for pi = 0 to len(patches) - 1
      pt = patches[pi]
      if typeof(pt) != "struct" then continue end if
      target = _coerce_name(try(pt.target))
      if target != "" then required_targets = t.fastmap_set(required_targets, target, 1) end if
    end for
  end for

  out_b = t.arr_chunk_new(64)
  if typeof(asm_labels) == "array" and len(asm_labels) > 0 then
    for i = 0 to len(asm_labels) - 1
      it = asm_labels[i]
      if typeof(it) != "struct" then continue end if
      name = _coerce_name(try(it.name))
      if _mlo_is_exported_text_label(name, entry_label, required_targets) == false then continue end if
      pos = try(it.pos)
      if typeof(pos) != "int" then pos = try(it.offset) end if
      if typeof(pos) != "int" then pos = 0 end if
      out_b = t.arr_chunk_push(out_b, MloLabel(name, pos))
    end for
  end if
  return t.arr_chunk_finish(out_b)
end function

function _bss_label_offset_map(st)
  count = 0
  if typeof(st) == "struct" and typeof(st.bss) == "struct" and typeof(st.bss.labels) == "array" then
    count = len(st.bss.labels)
  end if
  result_map = t.fastmap_new((count * 2) + 16)
  if count > 0 then
    for i = 0 to count - 1
      lb = st.bss.labels[i]
      if typeof(lb) == "struct" and typeof(lb.name) == "string" and typeof(lb.offset) == "int" then
        result_map = t.fastmap_set(result_map, lb.name, lb.offset)
      end if
    end for
  end if
  return result_map
end function

// Resolve directly against the indexes already maintained by each section
// builder. This avoids rebuilding a second million-entry combined map during
// monolithic linking while retaining the original last-section-wins order.
function _monolithic_label_rva(st, iat_label_map, bss_label_map, text_rva, rdata_rva, data_rva, bss_rva, name)
  hit = t.fastmap_get(iat_label_map, name, -1)
  if typeof(hit) == "int" and hit >= 0 then return hit end if

  bss_off = t.fastmap_get(bss_label_map, name, -1)
  if typeof(bss_off) == "int" and bss_off >= 0 then return bss_rva + bss_off end if

  if typeof(st) == "struct" and typeof(st.data) == "struct" then
    data_rec = d.data_label_record(st.data, name)
    if typeof(data_rec) == "struct" and typeof(data_rec.offset) == "int" then return data_rva + data_rec.offset end if
  end if
  if typeof(st) == "struct" and typeof(st.rdata) == "struct" then
    rdata_rec = d.rdata_label_record(st.rdata, name)
    if typeof(rdata_rec) == "struct" and typeof(rdata_rec.offset) == "int" then return rdata_rva + rdata_rec.offset end if
  end if
  if typeof(st) == "struct" and typeof(st.asm) == "struct" and typeof(st.asm.label_pos_map) == "struct" then
    text_off = t.fastmap_get(st.asm.label_pos_map, name, -1)
    if typeof(text_off) == "int" and text_off >= 0 then return text_rva + text_off end if
  end if
  return -1
end function

// Encode ELF imports in the existing platform-neutral string-list field. PE
// readers ignore the tagged entries; the ELF linker reconstructs the exact
// library/symbol/data-slot triplets without adding target-specific fields.
function _mlo_linux_import_records(dynamic_imports)
  records = []
  if typeof(dynamic_imports) != "array" or len(dynamic_imports) <= 0 then return records end if
  for i = 0 to len(dynamic_imports) - 1
    item = dynamic_imports[i]
    if typeof(item) != "struct" then continue end if
    library = _coerce_name(try(item.library))
    symbol_name = _coerce_name(try(item.symbol_name))
    slot = try(item.slot_offset)
    if library == "" or symbol_name == "" or typeof(slot) != "int" or slot < 0 then continue end if
    funcs = _mlo_import_get_funcs(records, library)
    // Preserve the monolithic import order even though the stable MLO import
    // container groups records by library. ELF string/symbol table order is
    // observable in the final bytes and therefore part of compiler parity.
    tagged = "@elf\t" + i + "\t" + symbol_name + "\t" + slot
    if _array_contains(funcs, tagged) == false then funcs = funcs + [tagged] end if
    records = _mlo_import_set_funcs(records, library, funcs)
  end for
  return records
end function

function _mlo_linux_dynamic_imports(imports)
  ordered_b = t.arr_chunk_new(16)
  if typeof(imports) != "array" or len(imports) <= 0 then return [] end if
  sequence = 0
  for i = 0 to len(imports) - 1
    item = imports[i]
    if typeof(item) != "array" or len(item) < 2 then continue end if
    library = _coerce_name(item[0])
    funcs = item[1]
    if library == "" or typeof(funcs) != "array" or len(funcs) == 0 then continue end if
    for fi = 0 to len(funcs) - 1
      tagged = _coerce_name(funcs[fi])
      if _startsWith(tagged, "@elf\t") == false then continue end if
      parts = s.split(tagged, "\t")
      if typeof(parts) != "array" or (len(parts) != 3 and len(parts) != 4) then continue end if
      ordinal = sequence
      symbol_name = ""
      slot_text = ""
      if len(parts) == 4 then
        ordinal = toNumber(parts[1])
        symbol_name = parts[2]
        slot_text = parts[3]
      else
        // Read legacy records produced before the explicit-order field.
        symbol_name = parts[1]
        slot_text = parts[2]
      end if
      slot = toNumber(slot_text)
      if typeof(ordinal) != "int" then ordinal = sequence end if
      if typeof(slot) != "int" or slot < 0 or symbol_name == "" then continue end if
      ordered_b = t.arr_chunk_push(ordered_b, [ordinal, sequence, linuxrt.DynamicImport(library, symbol_name, slot)])
      sequence = sequence + 1
    end for
  end for
  ordered = t.arr_chunk_finish(ordered_b)
  // Stable insertion sort is tiny here (normally tens of native imports) and
  // avoids pulling an ordering dependency into the compiler bootstrap graph.
  if len(ordered) > 1 then
    for i = 1 to len(ordered) - 1
      current = ordered[i]
      j = i - 1
      while j >= 0 and (ordered[j][0] > current[0] or (ordered[j][0] == current[0] and ordered[j][1] > current[1]))
        ordered[j + 1] = ordered[j]
        j = j - 1
      end while
      ordered[j + 1] = current
    end for
  end if
  out_b = t.arr_chunk_new(16)
  if len(ordered) > 0 then
    for i = 0 to len(ordered) - 1 out_b = t.arr_chunk_push(out_b, ordered[i][2]) end for
  end if
  return t.arr_chunk_finish(out_b)
end function

function _get_target(args)
  i = 0
  while i < len(args)
    if args[i] == "--target" then
      if i + 1 >= len(args) then return [false, "windows-x64"] end if
      value = s.toLowerAscii(s.trim(args[i + 1]))
      if value == "windows-x64" or value == "linux-x64" then return [true, value] end if
      return [false, value]
    end if
    i = i + 1
  end while
  return [true, "windows-x64"]
end function

function _mlo_label_name_at(labels, offset)
  if typeof(labels) != "array" or len(labels) <= 0 then return "" end if
  for i = 0 to len(labels) - 1
    lb = labels[i]
    if typeof(lb) != "struct" then continue end if
    if typeof(lb.offset) == "int" and lb.offset == offset then
      return _coerce_name(lb.name)
    end if
  end for
  return ""
end function

// A later canonical fragment may intern a constant that was first emitted by
// an earlier fragment.  Its new source-level label then aliases an offset that
// is not part of the later .mlo payload.  Redirect relocations to the original
// label so cross-fragment pooling remains byte-identical to monolithic output.
function _mlo_rdata_alias_map(labels, base_labels, prefix_off)
  aliases = t.fastmap_new(64)
  if typeof(labels) != "array" or len(labels) <= 0 then return aliases end if
  for i = 0 to len(labels) - 1
    lb = labels[i]
    if typeof(lb) != "struct" then continue end if
    if typeof(lb.offset) != "int" or lb.offset >= prefix_off then continue end if
    old_name = _coerce_name(lb.name)
    if old_name == "" then continue end if
    canonical_name = _mlo_label_name_at(base_labels, lb.offset)
    if canonical_name != "" and canonical_name != old_name then
      aliases = t.fastmap_set(aliases, old_name, canonical_name)
    end if
  end for
  return aliases
end function

function _mlo_resolve_rdata_alias_patches(patches, rb)
  if typeof(patches) != "array" or len(patches) <= 0 then return patches end if
  out_b = t.arr_chunk_new(64)
  for i = 0 to len(patches) - 1
    pt = patches[i]
    if typeof(pt) != "struct" then continue end if
    raw_target = try(pt.target)
    kind = _coerce_name(try(pt.kind))
    offset = try(pt.offset)
    if typeof(offset) != "int" then offset = 0 end if
    if typeof(raw_target) == "int" then
      if raw_target >= 0 and kind != "" then
        out_b = t.arr_chunk_push(out_b, MloPatch(offset, raw_target, kind))
      end if
      continue
    end if
    target = _coerce_name(raw_target)
    if target == "" or kind == "" then continue end if
    out_b = t.arr_chunk_push(out_b, MloPatch(offset, d.rdata_resolve_alias(rb, target), kind))
  end for
  return t.arr_chunk_finish(out_b)
end function

function _mlo_state_checkpoint(st)
  rdata_used = 0
  data_used = 0
  bss_size = 0
  rdata_label_count = 0
  rdata_patch_count = 0
  data_label_count = 0
  data_patch_count = 0
  bss_label_count = 0
  if typeof(st) != "struct" then
    return MloStateCheckpoint(rdata_used, data_used, bss_size, rdata_label_count, rdata_patch_count, data_label_count, data_patch_count, bss_label_count)
  end if
  if typeof(st.rdata) == "struct" then
    if typeof(st.rdata.used) == "int" then rdata_used = st.rdata.used end if
    rdata_label_count = d.rdata_label_count(st.rdata)
    rdata_patch_count = d.rdata_patch_count(st.rdata)
  end if
  if typeof(st.data) == "struct" then
    if typeof(st.data.used) == "int" then data_used = st.data.used end if
    data_label_count = d.data_label_count(st.data)
    data_patch_count = d.data_patch_count(st.data)
  end if
  if typeof(st.bss) == "struct" then
    if typeof(st.bss.size) == "int" then bss_size = st.bss.size end if
    if typeof(st.bss.labels) == "array" then bss_label_count = len(st.bss.labels) end if
  end if
  return MloStateCheckpoint(rdata_used, data_used, bss_size, rdata_label_count, rdata_patch_count, data_label_count, data_patch_count, bss_label_count)
end function

function _mlo_align_down8(value)
  v = value
  if typeof(v) != "int" or v <= 0 then return 0 end if
  return v - (v % 8)
end function

function _mlo_labels_after_cut(labels, min_off, cut_off)
  out_b = t.arr_chunk_new(64)
  if typeof(labels) == "array" and len(labels) > 0 then
    for i = 0 to len(labels) - 1
      lb = labels[i]
      if typeof(lb) != "struct" then continue end if
      if typeof(lb.offset) != "int" or lb.offset < min_off then continue end if
      out_b = t.arr_chunk_push(out_b, MloLabel(_coerce_name(lb.name), lb.offset - cut_off))
    end for
  end if
  return t.arr_chunk_finish(out_b)
end function

function _mlo_patches_after_cut(patches, min_off, cut_off)
  out_b = t.arr_chunk_new(64)
  if typeof(patches) == "array" and len(patches) > 0 then
    for i = 0 to len(patches) - 1
      pt = patches[i]
      if typeof(pt) != "struct" then continue end if
      off0 = try(pt.offset)
      if typeof(off0) != "int" or off0 < min_off then continue end if
      trg = _coerce_name(try(pt.target))
      kind = _coerce_name(try(pt.kind))
      if trg == "" or trg == "unknown" or kind == "" or kind == "unknown" then continue end if
      out_b = t.arr_chunk_push(out_b, MloPatch(off0 - cut_off, trg, kind))
    end for
  end if
  return t.arr_chunk_finish(out_b)
end function

function _mlo_from_state_delta(kind, module_file, entry_label, st, base_state)
  if typeof(base_state) != "struct" then return _mlo_from_state(kind, module_file, entry_label, st) end if

  asm_labels = []
  asm_patches = []
  asm_label_pos_map = 0
  text_buf = bytes(0)
  if typeof(st.asm) == "struct" then
    asm_label_pos_map = st.asm.label_pos_map
    asm_labels = a.get_labels(st.asm)
    folded_asm = a.materialize_and_fold_local_patches(st.asm)
    st.asm = folded_asm[0]
    asm_patches = folded_asm[1]
    if typeof(st.asm.buf) == "bytes" then text_buf = _slice_used_bytes(st.asm.buf, st.asm.size) end if
  end if

  rdata_prefix = base_state.rdata_used
  rdata_used = rdata_prefix
  rdata_buf = bytes(0)
  rdata_labels = []
  rdata_patches = []
  if typeof(st.rdata) == "struct" then
    if typeof(st.rdata.used) == "int" then rdata_used = st.rdata.used end if
    if rdata_used > rdata_prefix then rdata_buf = slice(st.rdata.data, rdata_prefix, rdata_used - rdata_prefix) end if
    raw_rdata_labels = d.rdata_get_labels_after(st.rdata, base_state.rdata_label_count)
    rdata_labels = _mlo_labels_after(_mlo_labels_from_arr(raw_rdata_labels), rdata_prefix)
    raw_rdata_patches = d.rdata_get_patches_after(st.rdata, base_state.rdata_patch_count)
    rdata_patches = _mlo_patches_after(_mlo_patches_from_data(raw_rdata_patches), rdata_prefix)
  end if

  data_prefix = base_state.data_used
  data_used = data_prefix
  data_buf = bytes(0)
  data_labels = []
  data_patches = []
  if typeof(st.data) == "struct" then
    if typeof(st.data.used) == "int" then data_used = st.data.used end if
    if data_used > data_prefix then data_buf = slice(st.data.data, data_prefix, data_used - data_prefix) end if
    raw_data_labels = d.data_get_labels_after(st.data, base_state.data_label_count)
    data_labels = _mlo_labels_after(_mlo_labels_from_arr(raw_data_labels), data_prefix)
    raw_data_patches = d.data_get_patches_after(st.data, base_state.data_patch_count)
    data_patches = _mlo_patches_after(_mlo_patches_from_data(raw_data_patches), data_prefix)
  end if

  bss_prefix = base_state.bss_size
  bss_size = 0
  bss_labels_b = t.arr_chunk_new(16)
  if typeof(st.bss) == "struct" then
    if typeof(st.bss.size) == "int" and st.bss.size >= bss_prefix then bss_size = st.bss.size - bss_prefix end if
    if typeof(st.bss.labels) == "array" and len(st.bss.labels) > base_state.bss_label_count then
      for bi = base_state.bss_label_count to len(st.bss.labels) - 1
        lb = st.bss.labels[bi]
        if typeof(lb) != "struct" then continue end if
        bss_labels_b = t.arr_chunk_push(bss_labels_b, MloLabel(_coerce_name(lb.name), lb.offset - bss_prefix))
      end for
    end if
  end if

  obj = MloObject(
    kind, module_file, entry_label,
    text_buf, rdata_buf, data_buf, bss_size,
    _mlo_exported_text_labels(asm_labels, entry_label, rdata_patches, data_patches), _mlo_patches_from_asm(asm_patches, asm_label_pos_map, text_buf),
    rdata_labels, rdata_patches, data_labels, data_patches,
    t.arr_chunk_finish(bss_labels_b), _mlo_imports_from_state(st.imports)
  )

  // Resolve pooled aliases in O(1) through the builder index. Only patches in
  // this fragment are visited; prior labels and relocations are never rescanned.
  if typeof(st.rdata) == "struct" then
    obj.asm_patches = _mlo_resolve_rdata_alias_patches(obj.asm_patches, st.rdata)
    obj.rdata_patches = _mlo_resolve_rdata_alias_patches(obj.rdata_patches, st.rdata)
    obj.data_patches = _mlo_resolve_rdata_alias_patches(obj.data_patches, st.rdata)
  end if
  return obj
end function

function _mlo_from_sparse_state_delta(kind, module_file, entry_label, st, base_state)
  obj = _mlo_from_state(kind, module_file, entry_label, st)
  if typeof(base_state) != "struct" then return obj end if

  bss_prefix = 0
  if typeof(base_state.bss) == "struct" and typeof(base_state.bss.size) == "int" then bss_prefix = base_state.bss.size end if
  if obj.bss_size >= bss_prefix then
    bss_cut = _mlo_align_down8(bss_prefix)
    obj.bss_size = obj.bss_size - bss_cut
    obj.bss_labels = _mlo_labels_after_cut(obj.bss_labels, bss_prefix, bss_cut)
  end if
  return obj
end function

function _mlo_preserve_module_label(name)
  if typeof(name) != "string" or name == "" then return false end if
  if _startsWith(name, "fn_user_") then return true end if
  if _startsWith(name, "modinit_") then return true end if
  if _startsWith(name, "cstr_") then return true end if
  if _startsWith(name, "cflt_") then return true end if
  if _startsWith(name, "flt_") then return true end if
  if _startsWith(name, "objstr_") then return true end if
  if _startsWith(name, "str_") then return true end if
  if _startsWith(name, "obj_fn_static_") then return true end if
  if _startsWith(name, "obj_structtype_static_") then return true end if
  if _startsWith(name, "obj_builtin_static_") then return true end if
  if _startsWith(name, "obj_extern_static_") then return true end if
  return false
end function

function _mlo_is_shared_runtime_data_label(name)
  if typeof(name) != "string" or name == "" then return false end if
  if name == "gc_roots_head" or name == "gc_free_head" then return true end if
  if name == "gc_bytes_since" or name == "gc_bytes_limit" then return true end if
  if name == "gc_young_bytes_since" or name == "gc_young_bytes_limit" then return true end if
  if name == "gc_mark_top" then return true end if
  if _startsWith(name, "gc_tmp") then return true end if
  if _startsWith(name, "gc_mark_bits_") then return true end if
  if _startsWith(name, "heap_") then return true end if
  return false
end function

function _mlo_strip_shared_runtime_data_labels(labels)
  out_b = t.arr_chunk_new(64)
  if typeof(labels) == "array" and len(labels) > 0 then
    for i = 0 to len(labels) - 1
      lb = labels[i]
      if typeof(lb) != "struct" then continue end if
      nm = _coerce_name(lb.name)
      if _mlo_is_shared_runtime_data_label(nm) then continue end if
      out_b = t.arr_chunk_push(out_b, lb)
    end for
  end if
  return t.arr_chunk_finish(out_b)
end function

function _mlo_label_map_add(mapv, old_name, new_name)
  if old_name == new_name or old_name == "" or new_name == "" then return mapv end if
  return t.fastmap_set(mapv, old_name, new_name)
end function

function _mlo_rename_labels(labels, prefix, preserve_public, label_map)
  renamed = labels
  if typeof(renamed) != "array" or len(renamed) <= 0 then return [renamed, label_map] end if
  for i = 0 to len(renamed) - 1
    lb = renamed[i]
    if typeof(lb) != "struct" then continue end if
    nm = _coerce_name(lb.name)
    if nm == "" then continue end if
    if preserve_public and _mlo_preserve_module_label(nm) then continue end if
    new_nm = prefix + "__" + nm
    label_map = _mlo_label_map_add(label_map, nm, new_nm)
    renamed[i] = MloLabel(new_nm, lb.offset)
  end for
  return [renamed, label_map]
end function

function _mlo_rename_patches(patches, label_map)
  if typeof(patches) != "array" or len(patches) <= 0 then return patches end if
  renamed_b = t.arr_chunk_new(64)
  for i = 0 to len(patches) - 1
    pt = patches[i]
    if typeof(pt) != "struct" then continue end if
    raw_target = try(pt.target)
    off = try(pt.offset)
    if typeof(off) != "int" then off = 0 end if
    kind = _coerce_name(try(pt.kind))
    if kind == "" then continue end if
    if typeof(raw_target) == "int" then
      if raw_target >= 0 then renamed_b = t.arr_chunk_push(renamed_b, MloPatch(off, raw_target, kind)) end if
      continue
    end if
    trg = _coerce_name(raw_target)
    if trg == "" then continue end if
    new_trg = t.fastmap_get(label_map, trg, trg)
    renamed_b = t.arr_chunk_push(renamed_b, MloPatch(off, new_trg, kind))
  end for
  return t.arr_chunk_finish(renamed_b)
end function

function _mlo_label_count(labels)
  if typeof(labels) != "array" then return 0 end if
  return len(labels)
end function

function _mlo_namespace_object(obj, prefix, preserve_public)
  if typeof(obj) != "struct" then return obj end if
  if typeof(prefix) != "string" or prefix == "" then return obj end if
  label_count = _mlo_label_count(obj.asm_labels) + _mlo_label_count(obj.rdata_labels) + _mlo_label_count(obj.data_labels) + _mlo_label_count(obj.bss_labels)
  label_map_cap = (label_count * 4) + 64
  if label_map_cap < 256 then label_map_cap = 256 end if
  label_map = t.fastmap_new(label_map_cap)

  rr = _mlo_rename_labels(obj.asm_labels, prefix, preserve_public, label_map)
  obj.asm_labels = rr[0]
  label_map = rr[1]

  rr = _mlo_rename_labels(obj.rdata_labels, prefix, preserve_public, label_map)
  obj.rdata_labels = rr[0]
  label_map = rr[1]

  rr = _mlo_rename_labels(obj.data_labels, prefix, false, label_map)
  obj.data_labels = rr[0]
  label_map = rr[1]

  rr = _mlo_rename_labels(obj.bss_labels, prefix, false, label_map)
  obj.bss_labels = rr[0]
  label_map = rr[1]

  obj.asm_patches = _mlo_rename_patches(obj.asm_patches, label_map)
  obj.rdata_patches = _mlo_rename_patches(obj.rdata_patches, label_map)
  obj.data_patches = _mlo_rename_patches(obj.data_patches, label_map)
  obj.entry_label = t.fastmap_get(label_map, obj.entry_label, obj.entry_label)
  return obj
end function

function _mlo_write_labels(ob, labels)
  count = 0
  if typeof(labels) == "array" then count = len(labels) end if
  ob = _objbuf_u32(ob, count)
  if count > 0 then
    for i = 0 to count - 1
      lb = labels[i]
      if typeof(lb) != "struct" then
        ob = _objbuf_string(ob, "")
        ob = _objbuf_u32(ob, 0)
        continue
      end if
      ob = _objbuf_string(ob, _coerce_name(lb.name))
      ob = _objbuf_u32(ob, lb.offset)
    end for
  end if
  return ob
end function

function _mlo_bp_push(bp, b)
  if typeof(b) != "bytes" or len(b) <= 0 then return bp end if
  return t.byte_pages_append(bp, b)
end function

function _mlo_bp_u32(bp as struct, value as int) returns struct
  return t.byte_pages_append_u32(bp, value)
end function

function _mlo_bp_bytes(bp, b)
  raw = b
  if typeof(raw) != "bytes" then raw = bytes(0) end if
  bp = _mlo_bp_u32(bp, len(raw))
  return _mlo_bp_push(bp, raw)
end function

function _mlo_bp_string(bp, text)
  if typeof(text) != "string" then text = "" end if
  bp = _mlo_bp_u32(bp, len(text))
  return t.byte_pages_append_string(bp, text)
end function

function _mlo_bp_write_labels(bp, labels)
  count = 0
  if typeof(labels) == "array" then count = len(labels) end if
  bp = _mlo_bp_u32(bp, count)
  if count > 0 then
    for i = 0 to count - 1
      lb = labels[i]
      if typeof(lb) != "struct" then
        bp = _mlo_bp_string(bp, "")
        bp = _mlo_bp_u32(bp, 0)
        continue
      end if
      bp = _mlo_bp_string(bp, _coerce_name(lb.name))
      bp = _mlo_bp_u32(bp, lb.offset)
    end for
  end if
  return bp
end function

function _mlo_bp_write_patches(bp, patches)
  count = 0
  if typeof(patches) == "array" then count = len(patches) end if
  bp = _mlo_bp_u32(bp, count)
  if count > 0 then
    for i = 0 to count - 1
      pt = patches[i]
      if typeof(pt) != "struct" then
        bp = _mlo_bp_u32(bp, 0)
        bp = _mlo_bp_u32(bp, 0)
        bp = _mlo_bp_string(bp, "")
        bp = _mlo_bp_string(bp, "")
        continue
      end if
      off = try(pt.offset)
      if typeof(off) != "int" then off = 0 end if
      bp = _mlo_bp_u32(bp, off)
      target = try(pt.target)
      if typeof(target) == "int" and target >= 0 then
        bp = _mlo_bp_u32(bp, 1)
        bp = _mlo_bp_u32(bp, target)
      else
        bp = _mlo_bp_u32(bp, 0)
        bp = _mlo_bp_string(bp, _coerce_name(target))
      end if
      bp = _mlo_bp_string(bp, _coerce_name(try(pt.kind)))
    end for
  end if
  return bp
end function

function _mlo_bp_write_imports(bp, imports)
  count = 0
  if typeof(imports) == "array" then count = len(imports) end if
  bp = _mlo_bp_u32(bp, count)
  if count > 0 then
    for i = 0 to count - 1
      it = imports[i]
      dll = ""
      funcs = []
      if typeof(it) == "array" and len(it) >= 2 then
        dll = _coerce_name(it[0])
        if typeof(it[1]) == "array" then funcs = it[1] end if
      end if
      bp = _mlo_bp_string(bp, dll)
      fcount = 0
      if typeof(funcs) == "array" then fcount = len(funcs) end if
      bp = _mlo_bp_u32(bp, fcount)
      if fcount > 0 then
        for fi = 0 to fcount - 1
          bp = _mlo_bp_string(bp, _coerce_name(funcs[fi]))
        end for
      end if
    end for
  end if
  return bp
end function

function _mlo_write_patches(ob, patches)
  count = 0
  if typeof(patches) == "array" then count = len(patches) end if
  ob = _objbuf_u32(ob, count)
  if count > 0 then
    for i = 0 to count - 1
      pt = patches[i]
      if typeof(pt) != "struct" then
        ob = _objbuf_u32(ob, 0)
        ob = _objbuf_u32(ob, 0)
        ob = _objbuf_string(ob, "")
        ob = _objbuf_string(ob, "")
        continue
      end if
      off = try(pt.offset)
      if typeof(off) != "int" then off = 0 end if
      ob = _objbuf_u32(ob, off)
      target = try(pt.target)
      if typeof(target) == "int" and target >= 0 then
        ob = _objbuf_u32(ob, 1)
        ob = _objbuf_u32(ob, target)
      else
        ob = _objbuf_u32(ob, 0)
        ob = _objbuf_string(ob, _coerce_name(target))
      end if
      ob = _objbuf_string(ob, _coerce_name(try(pt.kind)))
    end for
  end if
  return ob
end function

function _mlo_write_imports(ob, imports)
  count = 0
  if typeof(imports) == "array" then count = len(imports) end if
  ob = _objbuf_u32(ob, count)
  if count > 0 then
    for i = 0 to count - 1
      it = imports[i]
      dll = ""
      funcs = []
      if typeof(it) == "array" and len(it) >= 2 then
        dll = _coerce_name(it[0])
        if typeof(it[1]) == "array" then funcs = it[1] end if
      end if
      ob = _objbuf_string(ob, dll)
      fcount = 0
      if typeof(funcs) == "array" then fcount = len(funcs) end if
      ob = _objbuf_u32(ob, fcount)
      if fcount > 0 then
        for fi = 0 to fcount - 1
          ob = _objbuf_string(ob, _coerce_name(funcs[fi]))
        end for
      end if
    end for
  end if
  return ob
end function

function _mlo_write_scratch_buffer()
  global _mlo_write_scratch
  if typeof(_mlo_write_scratch) != "bytes" or len(_mlo_write_scratch) != MLO_WRITE_BATCH_BYTES then
    _mlo_write_scratch = bytes(MLO_WRITE_BATCH_BYTES, 0)
  end if
  return _mlo_write_scratch
end function

// Complete one bounded native write even if the host reports a short write.
// The common regular-file path passes the shared buffer without slicing.
function _mlo_write_handle_all(handle, input, count)
  position = 0
  while position < count
    remaining = count - position
    part = input
    if position > 0 then part = slice(input, position, remaining) end if
#if TARGET_OS == "windows"
    written = bytes(4, 0)
    ok = _mlo_WriteFile(handle, part, remaining, written, 0)
    actual = _u32le_at(written, 0)
    if ok == false or actual <= 0 or actual > remaining then return false end if
#else
    actual = _mlo_write(handle, part, remaining)
    if actual <= 0 or actual > remaining then return false end if
#endif
    position = position + actual
  end while
  return true
end function

// Serialize through a reusable bounded staging buffer. A one-megabyte batch
// keeps native write-call overhead low while avoiding the old full-object
// contiguous duplicate, whose size grew without bound with an MLO fragment.
function _mlo_write_pages_file(path, bp)
  if typeof(path) != "string" or typeof(bp) != "struct" then return error(1, "invalid paged MLO write") end if
#if TARGET_OS == "windows"
  handle = _mlo_CreateFileW(path, 0x40000000, 5, 0, 2, 0x80, 0)
  if handle == -1 then return error(1, "CreateFileW failed") end if
#else
  handle = _mlo_open(path, 577, 0x1B6)
  if handle < 0 then return error(1, "open failed during paged MLO write") end if
#endif
  scratch = _mlo_write_scratch_buffer()
  batch_used = 0
  page_count = t.byte_pages_page_count(bp)
  for page_index = 0 to page_count - 1
    page = t.byte_pages_page(bp, page_index)
    used = t.byte_pages_page_used(bp, page_index)
    if used <= 0 then continue end if
    if batch_used + used > len(scratch) then
      if _mlo_write_handle_all(handle, scratch, batch_used) == false then
#if TARGET_OS == "windows"
        _mlo_CloseHandle(handle)
#else
        _mlo_close(handle)
#endif
        return error(1, "native write failed during batched MLO serialization")
      end if
      batch_used = 0
    end if
    copyBytes(scratch, batch_used, page, 0, used)
    batch_used = batch_used + used
    if batch_used == len(scratch) then
      if _mlo_write_handle_all(handle, scratch, batch_used) == false then
#if TARGET_OS == "windows"
        _mlo_CloseHandle(handle)
#else
        _mlo_close(handle)
#endif
        return error(1, "native write failed during batched MLO serialization")
      end if
      batch_used = 0
    end if
  end for
  if batch_used > 0 and _mlo_write_handle_all(handle, scratch, batch_used) == false then
#if TARGET_OS == "windows"
    _mlo_CloseHandle(handle)
#else
    _mlo_close(handle)
#endif
    return error(1, "native write failed during final MLO batch")
  end if
#if TARGET_OS == "windows"
  _mlo_CloseHandle(handle)
#else
  _mlo_close(handle)
#endif
  return true
end function

function _write_mlo_file(path, obj)
  bp = t.byte_pages_new()
  bp = _mlo_bp_string(bp, "MLO1")
  bp = _mlo_bp_u32(bp, 2)
  bp = _mlo_bp_string(bp, obj.kind)
  bp = _mlo_bp_string(bp, obj.module_file)
  bp = _mlo_bp_string(bp, obj.entry_label)
  bp = _mlo_bp_bytes(bp, obj.text)
  bp = _mlo_bp_bytes(bp, obj.rdata)
  bp = _mlo_bp_bytes(bp, obj.data)
  bp = _mlo_bp_u32(bp, obj.bss_size)
  bp = _mlo_bp_write_labels(bp, obj.asm_labels)
  bp = _mlo_bp_write_patches(bp, obj.asm_patches)
  bp = _mlo_bp_write_labels(bp, obj.rdata_labels)
  bp = _mlo_bp_write_patches(bp, obj.rdata_patches)
  bp = _mlo_bp_write_labels(bp, obj.data_labels)
  bp = _mlo_bp_write_patches(bp, obj.data_patches)
  bp = _mlo_bp_write_labels(bp, obj.bss_labels)
  bp = _mlo_bp_write_imports(bp, obj.imports)
  return _mlo_write_pages_file(path, bp)
end function

function _mlo_read_labels(rd)
  rc = _objreader_read_u32(rd)
  if typeof(rc) == "error" then return rc end if
  rd = rc[0]
  count = rc[1]
  out_b = t.arr_chunk_new(64)
  if count > 0 then
    for i = 0 to count - 1
      rn = _objreader_read_string(rd)
      if typeof(rn) == "error" then return rn end if
      rd = rn[0]
      name = rn[1]
      ro = _objreader_read_u32(rd)
      if typeof(ro) == "error" then return ro end if
      rd = ro[0]
      off = ro[1]
      out_b = t.arr_chunk_push(out_b, MloLabel(name, off))
    end for
  end if
  return [rd, t.arr_chunk_finish(out_b)]
end function

function _mlo_read_patches(rd, version)
  rc = _objreader_read_u32(rd)
  if typeof(rc) == "error" then return rc end if
  rd = rc[0]
  count = rc[1]
  out_b = t.arr_chunk_new(64)
  if count > 0 then
    for i = 0 to count - 1
      ro = _objreader_read_u32(rd)
      if typeof(ro) == "error" then return ro end if
      rd = ro[0]
      off = ro[1]
      trg = ""
      if version == 1 then
        rt = _objreader_read_string(rd)
        if typeof(rt) == "error" then return rt end if
        rd = rt[0]
        trg = rt[1]
      else
        rtag = _objreader_read_u32(rd)
        if typeof(rtag) == "error" then return rtag end if
        rd = rtag[0]
        target_tag = rtag[1]
        if target_tag == 0 then
          rt = _objreader_read_string(rd)
          if typeof(rt) == "error" then return rt end if
          rd = rt[0]
          trg = rt[1]
        else
          if target_tag != 1 then return error(1, "invalid MiniLang object patch target tag") end if
          rt = _objreader_read_u32(rd)
          if typeof(rt) == "error" then return rt end if
          rd = rt[0]
          trg = rt[1]
        end if
      end if
      rk = _objreader_read_string(rd)
      if typeof(rk) == "error" then return rk end if
      rd = rk[0]
      kind = rk[1]
      out_b = t.arr_chunk_push(out_b, MloPatch(off, trg, kind))
    end for
  end if
  return [rd, t.arr_chunk_finish(out_b)]
end function

function _mlo_read_imports(rd)
  rc = _objreader_read_u32(rd)
  if typeof(rc) == "error" then return rc end if
  rd = rc[0]
  count = rc[1]
  out_b = t.arr_chunk_new(16)
  if count > 0 then
    for i = 0 to count - 1
      rdll = _objreader_read_string(rd)
      if typeof(rdll) == "error" then return rdll end if
      rd = rdll[0]
      dll = rdll[1]
      rf = _objreader_read_u32(rd)
      if typeof(rf) == "error" then return rf end if
      rd = rf[0]
      fcount = rf[1]
      funcs_b = t.arr_chunk_new(8)
      if fcount > 0 then
        for fi = 0 to fcount - 1
          rs = _objreader_read_string(rd)
          if typeof(rs) == "error" then return rs end if
          rd = rs[0]
          funcs_b = t.arr_chunk_push(funcs_b, rs[1])
        end for
      end if
      out_b = t.arr_chunk_push(out_b, [dll, t.arr_chunk_finish(funcs_b)])
    end for
  end if
  return [rd, t.arr_chunk_finish(out_b)]
end function

function _read_mlo_file(path)
  raw = fs.readAllBytes(path)
  if typeof(raw) == "error" then return raw end if
  rd = _objreader_new(raw)
  rmagic = _objreader_read_string(rd)
  if typeof(rmagic) == "error" then return rmagic end if
  rd = rmagic[0]
  magic = rmagic[1]
  if magic != "MLO1" then return error(1, "invalid MiniLang object magic") end if
  rver = _objreader_read_u32(rd)
  if typeof(rver) == "error" then return rver end if
  rd = rver[0]
  version = rver[1]
  if version != 1 and version != 2 then return error(1, "unsupported MiniLang object version") end if

  rk = _objreader_read_string(rd)
  if typeof(rk) == "error" then return rk end if
  rd = rk[0]
  kind = rk[1]

  rm = _objreader_read_string(rd)
  if typeof(rm) == "error" then return rm end if
  rd = rm[0]
  module_file = rm[1]

  re = _objreader_read_string(rd)
  if typeof(re) == "error" then return re end if
  rd = re[0]
  entry_label = re[1]

  rt = _objreader_read_bytes(rd)
  if typeof(rt) == "error" then return rt end if
  rd = rt[0]
  text = rt[1]

  rr = _objreader_read_bytes(rd)
  if typeof(rr) == "error" then return rr end if
  rd = rr[0]
  rdata = rr[1]

  rdv = _objreader_read_bytes(rd)
  if typeof(rdv) == "error" then return rdv end if
  rd = rdv[0]
  data = rdv[1]

  rb = _objreader_read_u32(rd)
  if typeof(rb) == "error" then return rb end if
  rd = rb[0]
  bss_size = rb[1]

  r1 = _mlo_read_labels(rd)
  if typeof(r1) == "error" then return r1 end if
  rd = r1[0]
  asm_labels = r1[1]

  r2 = _mlo_read_patches(rd, version)
  if typeof(r2) == "error" then return r2 end if
  rd = r2[0]
  asm_patches = r2[1]

  r3 = _mlo_read_labels(rd)
  if typeof(r3) == "error" then return r3 end if
  rd = r3[0]
  rdata_labels = r3[1]

  r4 = _mlo_read_patches(rd, version)
  if typeof(r4) == "error" then return r4 end if
  rd = r4[0]
  rdata_patches = r4[1]

  r5 = _mlo_read_labels(rd)
  if typeof(r5) == "error" then return r5 end if
  rd = r5[0]
  data_labels = r5[1]

  r6 = _mlo_read_patches(rd, version)
  if typeof(r6) == "error" then return r6 end if
  rd = r6[0]
  data_patches = r6[1]

  r7 = _mlo_read_labels(rd)
  if typeof(r7) == "error" then return r7 end if
  rd = r7[0]
  bss_labels = r7[1]

  r8 = _mlo_read_imports(rd)
  if typeof(r8) == "error" then return r8 end if
  rd = r8[0]
  imports = r8[1]

  return MloObject(kind, module_file, entry_label, text, rdata, data, bss_size, asm_labels, asm_patches, rdata_labels, rdata_patches, data_labels, data_patches, bss_labels, imports)
end function

function _debug_validate_patch_names(label, patches)
  if typeof(patches) != "array" or len(patches) <= 0 then return end if
  for i = 0 to len(patches) - 1
    pt = patches[i]
    if typeof(pt) != "struct" then
      print "[dbg][mlo] non-struct patch in " + label + " at " + i + " type=" + typeof(pt)
      return
    end if
    pt_target = try(pt.target)
    pt_kind = try(pt.kind)
    if (typeof(pt_target) != "string" and typeof(pt_target) != "int") or typeof(pt_kind) != "string" then
      print "[dbg][mlo] bad patch in " + label + " at " + i + " target_type=" + typeof(pt_target) + " target_name=" + _coerce_name(pt_target) + " kind_type=" + typeof(pt_kind) + " kind_name=" + _coerce_name(pt_kind)
      return
    end if
  end for
end function

function _label_lookup_fallback(labels, name, defaultv)
  if typeof(name) != "string" or name == "" then return defaultv end if
  if typeof(labels) != "array" or len(labels) <= 0 then return defaultv end if
  for i = 0 to len(labels) - 1
    it = labels[i]
    if typeof(it) == "struct" then
      nm = try(it.name)
      off = try(it.offset)
      if typeof(nm) == "string" and typeof(off) == "int" then
        if nm == name then return off end if
      end if
      key = try(it.key)
      value = try(it.value)
      if typeof(key) == "string" and typeof(value) == "int" then
        if key == name then return value end if
      end if
    else
      if typeof(it) == "array" and len(it) >= 2 then
        if _coerce_name(it[0]) == name and typeof(it[1]) == "int" then
          return it[1]
        end if
      end if
    end if
  end for
  return defaultv
end function

function _link_target_obj_index(name)
  if typeof(name) != "string" or s.startsWith(name, "objm_") == false then return "" end if
  p = s.indexOf(name, "__", 5)
  if typeof(p) != "int" or p <= 5 then return "" end if
  return s.substr(name, 5, p - 5)
end function

function _link_target_obj_index_num(name)
  if typeof(name) != "string" or s.startsWith(name, "objm_") == false then return -1 end if
  acc = 0
  saw = false
  i = 5
  while i < len(name)
    ch = name[i]
    if ch == "_" and i + 1 < len(name) and name[i + 1] == "_" then
      if saw then return acc end if
      return -1
    end if
    digit = s.indexOf("0123456789", ch, 0)
    if typeof(digit) != "int" or digit < 0 or digit > 9 then return -1 end if
    acc = (acc * 10) + digit
    saw = true
    i = i + 1
  end while
  return -1
end function

function _link_obj_label_map_set(obj_index_map, name, value)
  idx = _link_target_obj_index_num(name)
  if idx < 0 then return obj_index_map end if
  while idx >= len(obj_index_map)
    obj_index_map = obj_index_map + [0]
  end while
  lm = obj_index_map[idx]
  if typeof(lm) != "struct" then lm = t.fastmap_new(256) end if
  lm = t.fastmap_set(lm, name, value)
  obj_index_map[idx] = lm
  return obj_index_map
end function

function _link_obj_label_map_get(obj_index_map, name, defaultv)
  idx = _link_target_obj_index_num(name)
  if idx < 0 or typeof(obj_index_map) != "array" or idx >= len(obj_index_map) then return defaultv end if
  lm = obj_index_map[idx]
  if typeof(lm) != "struct" then return defaultv end if
  return t.fastmap_get(lm, name, defaultv)
end function

function _link_obj_label_list_set(obj_index_lists, name, value)
  idx = _link_target_obj_index_num(name)
  if idx < 0 then return obj_index_lists end if
  while idx >= len(obj_index_lists)
    obj_index_lists = obj_index_lists + [0]
  end while
  b = obj_index_lists[idx]
  if typeof(b) != "struct" or typeof(b.chunks) != "array" then b = t.arr_chunk_new(256) end if
  b = t.arr_chunk_push(b, StrIntPair(name, value))
  obj_index_lists[idx] = b
  return obj_index_lists
end function

function _link_obj_label_list_get(obj_index_lists, name, defaultv)
  idx = _link_target_obj_index_num(name)
  if idx < 0 or typeof(obj_index_lists) != "array" or idx >= len(obj_index_lists) then return defaultv end if
  arr = obj_index_lists[idx]
  if typeof(arr) == "struct" and typeof(arr.chunks) == "array" then arr = t.arr_chunk_finish(arr) end if
  if typeof(arr) != "array" or len(arr) <= 0 then return defaultv end if
  for i = 0 to len(arr) - 1
    it = arr[i]
    if typeof(it) == "struct" and typeof(try(it.key)) == "string" and try(it.key) == name then
      if typeof(try(it.value)) == "int" then return try(it.value) end if
    end if
  end for
  return defaultv
end function

function _link_rec_labels_lookup(recs, text_rva, rdata_rva, data_rva, bss_rva, name, defaultv)
  if typeof(name) != "string" or name == "" then return defaultv end if
  if typeof(recs) != "array" or len(recs) <= 0 then return defaultv end if
  want_obj = _link_target_obj_index(name)
  for i = 0 to len(recs) - 1
    rec = recs[i]
    if typeof(rec) != "array" or len(rec) < 5 then continue end if
    obj_path = _coerce_name(rec[0])
    if want_obj != "" then
      base_obj = _basename(obj_path)
      if s.startsWith(base_obj, want_obj + "_") == false then continue end if
    end if
    text_off = rec[1]
    rdata_off = rec[2]
    data_off = rec[3]
    bss_off = rec[4]

    asm_labels = []
    rdata_labels = []
    data_labels = []
    bss_labels = []
    if len(rec) >= 9 then
      asm_labels = rec[5]
      rdata_labels = rec[6]
      data_labels = rec[7]
      bss_labels = rec[8]
    else
      ro = _read_mlo_file_for_layout(obj_path)
      if typeof(ro) == "error" then continue end if
      asm_labels = ro.asm_labels
      rdata_labels = ro.rdata_labels
      data_labels = ro.data_labels
      bss_labels = ro.bss_labels
    end if

    if typeof(asm_labels) == "array" and len(asm_labels) > 0 then
      for li = 0 to len(asm_labels) - 1
        lb = asm_labels[li]
        if typeof(lb) != "struct" then continue end if
        if _coerce_name(lb.name) == name and typeof(lb.offset) == "int" then
          return text_rva + text_off + lb.offset
        end if
      end for
    end if

    if typeof(rdata_labels) == "array" and len(rdata_labels) > 0 then
      for li = 0 to len(rdata_labels) - 1
        lb = rdata_labels[li]
        if typeof(lb) != "struct" then continue end if
        if _coerce_name(lb.name) == name and typeof(lb.offset) == "int" then
          return rdata_rva + rdata_off + lb.offset
        end if
      end for
    end if

    if typeof(data_labels) == "array" and len(data_labels) > 0 then
      for li = 0 to len(data_labels) - 1
        lb = data_labels[li]
        if typeof(lb) != "struct" then continue end if
        if _coerce_name(lb.name) == name and typeof(lb.offset) == "int" then
          return data_rva + data_off + lb.offset
        end if
      end for
    end if

    if typeof(bss_labels) == "array" and len(bss_labels) > 0 then
      for li = 0 to len(bss_labels) - 1
        lb = bss_labels[li]
        if typeof(lb) != "struct" then continue end if
        if _coerce_name(lb.name) == name and typeof(lb.offset) == "int" then
          return bss_rva + bss_off + lb.offset
        end if
      end for
    end if
  end for
  return defaultv
end function

function _patch_triplets_for_link(patches, default_kind)
  out_b = t.arr_chunk_new(64)
  if typeof(patches) == "array" and len(patches) > 0 then
    for i = 0 to len(patches) - 1
      pt = patches[i]
      off = 0
      trg = ""
      kind = ""
      if typeof(pt) == "struct" then
        roff = try(pt.offset)
        if typeof(roff) == "int" then off = roff end if
        trg = _coerce_name(try(pt.target))
        kind = _coerce_name(try(pt.kind))
      else
        if typeof(pt) == "array" and len(pt) >= 2 then
          if typeof(pt[0]) == "int" then off = pt[0] end if
          trg = _coerce_name(pt[1])
          if len(pt) >= 3 then kind = _coerce_name(pt[2]) end if
        else
          continue
        end if
      end if
      if typeof(trg) != "string" or trg == "" or trg == "unknown" then continue end if
      if typeof(kind) != "string" or kind == "" or kind == "unknown" then
        kind = default_kind
      end if
      out_b = t.arr_chunk_push(out_b, [off, trg, kind])
    end for
  end if
  return t.arr_chunk_finish(out_b)
end function

function _apply_link_patches(patches, obj_off, label_map, labels, obj_label_recs, text_rva, rdata_rva, data_rva, bss_rva, image_base, section_buf, is_rel32, patch_index, unknown_prefix, invalid_prefix)
  if typeof(patches) != "array" or len(patches) <= 0 then
    return [0, label_map, patch_index]
  end if

  last_target = ""
  last_value = -1
  for i = 0 to len(patches) - 1
    pt = patches[i]

    pt_off = 0
    pt_target = ""
    if typeof(pt) == "struct" then
      pt_off = try(pt.offset)
      if typeof(pt_off) != "int" then pt_off = 0 end if
      pt_target = _coerce_name(try(pt.target))
    else
      if typeof(pt) == "array" and len(pt) >= 2 then
        if typeof(pt[0]) == "int" then pt_off = pt[0] end if
        pt_target = _coerce_name(pt[1])
      else
        continue
      end if
    end if
    if typeof(pt_target) != "string" or pt_target == "" then continue end if

    trg = -1
    if pt_target == last_target then
      trg = last_value
    else
      trg = t.fastmap_get(label_map, _label_key(pt_target), -1)
      if typeof(trg) != "int" or trg < 0 then
        trg = _label_lookup_fallback(labels, pt_target, -1)
      end if
      if typeof(trg) != "int" or trg < 0 then
        trg = _link_rec_labels_lookup(obj_label_recs, text_rva, rdata_rva, data_rva, bss_rva, pt_target, -1)
        if typeof(trg) == "int" and trg >= 0 then
          label_map = t.fastmap_set(label_map, _label_key(pt_target), trg)
        end if
      end if
      last_target = pt_target
      last_value = trg
    end if
    if typeof(trg) != "int" or trg < 0 then
      print unknown_prefix + pt_target
      return [2, label_map, patch_index]
    end if

    abs_off = obj_off + pt_off
    if is_rel32 then
      if abs_off < 0 or abs_off + 3 >= len(section_buf) then
        print invalid_prefix + pt_target
        return [2, label_map, patch_index]
      end if
      src_next = text_rva + abs_off + 4
      disp = trg - src_next
      b4 = t.u32(disp)
      section_buf[abs_off] = b4[0]
      section_buf[abs_off + 1] = b4[1]
      section_buf[abs_off + 2] = b4[2]
      section_buf[abs_off + 3] = b4[3]
      patch_index = patch_index + 1
    else
      if abs_off < 0 or abs_off + 7 >= len(section_buf) then
        print invalid_prefix + pt_target
        return [2, label_map, patch_index]
      end if
      target_va = image_base + trg
      b8 = t.u64(target_va)
      for bi = 0 to 7
        section_buf[abs_off + bi] = b8[bi]
      end for
    end if
  end for

  return [0, label_map, patch_index]
end function

function _char_code_local(ch)
  b = bytes(ch)
  if typeof(b) != "bytes" or len(b) <= 0 then return -1 end if
  return b[0]
end function

function _mlo_sort_rank(name)
  if typeof(name) != "string" then name = _coerce_name(name) end if
  if name == "" then return 2147483647 end if
  acc = 0
  saw = false
  for i = 0 to len(name) - 1
    c = _char_code_local(name[i])
    if c >= 48 and c <= 57 then
      saw = true
      acc = (acc * 10) + (c - 48)
      continue
    end if
    break
  end for
  if saw then return acc end if
  return 2147483647
end function

function _string_leq(a, b)
  if typeof(a) != "string" then a = _coerce_name(a) end if
  if typeof(b) != "string" then b = _coerce_name(b) end if
  na = len(a)
  nb = len(b)
  n = na
  if nb < n then n = nb end if
  if n > 0 then
    for i = 0 to n - 1
      ca = _char_code_local(a[i])
      cb = _char_code_local(b[i])
      if ca < cb then return true end if
      if ca > cb then return false end if
    end for
  end if
  return na <= nb
end function

function _sort_strings_inplace(items)
  if typeof(items) != "array" or len(items) <= 1 then return items end if
  for i = 1 to len(items) - 1
    cur = items[i]
    cur_key = _coerce_name(cur)
    cur_rank = _mlo_sort_rank(cur_key)
    j = i - 1
    while j >= 0
      prev_key = _coerce_name(items[j])
      prev_rank = _mlo_sort_rank(prev_key)
      if prev_rank < cur_rank then break end if
      if prev_rank == cur_rank and _string_leq(prev_key, cur_key) then break end if
      items[j + 1] = items[j]
      j = j - 1
    end while
    items[j + 1] = cur
  end for
  return items
end function

function _collect_mlo_paths_from_dir(obj_dir)
  if typeof(obj_dir) != "string" or obj_dir == "" then
    return error(1, "missing object directory")
  end if
  if fs.isDir(obj_dir) == false then
    return error(1, "object directory not found: " + obj_dir)
  end if

  names = fs.listDir(obj_dir)
  if typeof(names) == "error" then return names end if
  names = _sort_strings_inplace(names)

  out_b = t.arr_chunk_new(64)
  if len(names) > 0 then
    for i = 0 to len(names) - 1
      nm = _coerce_name(names[i])
      if _endsWith(nm, ".mlo") == false then continue end if
      full = _path_join(obj_dir, nm)
      if fs.isFile(full) == false then continue end if
      out_b = t.arr_chunk_push(out_b, full)
    end for
  end if
  obj_paths = t.arr_chunk_finish(out_b)
  if len(obj_paths) <= 0 then
    return error(1, "no .mlo files found in object directory: " + obj_dir)
  end if
  return obj_paths
end function

function _mlo_skip_labels(rd)
  rc = _objreader_read_u32(rd)
  if typeof(rc) == "error" then return rc end if
  rd = rc[0]
  count = rc[1]
  if count > 0 then
    for i = 0 to count - 1
      rn = _objreader_skip_bytes(rd)
      if typeof(rn) == "error" then return rn end if
      rd = rn
      ro = _objreader_read_u32(rd)
      if typeof(ro) == "error" then return ro end if
      rd = ro[0]
    end for
  end if
  return rd
end function

function _mlo_skip_patches(rd, version)
  rc = _objreader_read_u32(rd)
  if typeof(rc) == "error" then return rc end if
  rd = rc[0]
  count = rc[1]
  if count > 0 then
    for i = 0 to count - 1
      ro = _objreader_read_u32(rd)
      if typeof(ro) == "error" then return ro end if
      rd = ro[0]
      if version == 1 then
        rt = _objreader_skip_bytes(rd)
        if typeof(rt) == "error" then return rt end if
        rd = rt
      else
        rtag = _objreader_read_u32(rd)
        if typeof(rtag) == "error" then return rtag end if
        rd = rtag[0]
        target_tag = rtag[1]
        if target_tag == 0 then
          rt = _objreader_skip_bytes(rd)
          if typeof(rt) == "error" then return rt end if
          rd = rt
        else
          if target_tag != 1 then return error(1, "invalid MiniLang object patch target tag") end if
          rt = _objreader_read_u32(rd)
          if typeof(rt) == "error" then return rt end if
          rd = rt[0]
        end if
      end if
      rk = _objreader_skip_bytes(rd)
      if typeof(rk) == "error" then return rk end if
      rd = rk
    end for
  end if
  return rd
end function

// Count serialized labels without decoding their names or allocating wrapper
// structs. The private namespace is identified directly from the UTF-8 bytes
// of the `objm_` prefix.
function _mlo_scan_label_counts(rd)
  rc = _objreader_read_u32(rd)
  if typeof(rc) == "error" then return rc end if
  rd = rc[0]
  count = rc[1]
  public_count = 0
  private_count = 0
  if count > 0 then
    for i = 0 to count - 1
      rlen = _objreader_read_u32(rd)
      if typeof(rlen) == "error" then return rlen end if
      rd = rlen[0]
      name_len = rlen[1]
      if typeof(name_len) != "int" or name_len < 0 or rd.pos < 0 or rd.pos + name_len > len(rd.buf) then
        return error(1, "invalid serialized MLO label")
      end if
      is_private = false
      if name_len >= 5 then
        p = rd.pos
        is_private = rd.buf[p] == 111 and rd.buf[p + 1] == 98 and rd.buf[p + 2] == 106 and rd.buf[p + 3] == 109 and rd.buf[p + 4] == 95
      end if
      if name_len > 0 then
        if is_private then private_count = private_count + 1 else public_count = public_count + 1 end if
      end if
      rd.pos = rd.pos + name_len
      ro = _objreader_read_u32(rd)
      if typeof(ro) == "error" then return ro end if
      rd = ro[0]
    end for
  end if
  return [rd, public_count, private_count]
end function

// First linker pass: retain only section sizes, import metadata and label
// capacity hints. Section payloads and label wrappers remain in the MLO file.
function _read_mlo_layout_scan(path)
  raw = fs.readAllBytes(path)
  if typeof(raw) == "error" then return raw end if
  rd = _objreader_new(raw)
  rmagic = _objreader_read_string(rd)
  if typeof(rmagic) == "error" then return rmagic end if
  rd = rmagic[0]
  if rmagic[1] != "MLO1" then return error(1, "invalid MiniLang object magic") end if
  rver = _objreader_read_u32(rd)
  if typeof(rver) == "error" then return rver end if
  rd = rver[0]
  version = rver[1]
  if version != 1 and version != 2 then return error(1, "unsupported MiniLang object version") end if

  rkind = _objreader_skip_bytes(rd)
  if typeof(rkind) == "error" then return rkind end if
  rd = rkind
  rmodule = _objreader_skip_bytes(rd)
  if typeof(rmodule) == "error" then return rmodule end if
  rd = rmodule
  rentry = _objreader_read_string(rd)
  if typeof(rentry) == "error" then return rentry end if
  rd = rentry[0]
  entry_label = rentry[1]

  rt = _objreader_skip_bytes_len(rd)
  if typeof(rt) == "error" then return rt end if
  rd = rt[0]
  text_size = rt[1]
  rr = _objreader_skip_bytes_len(rd)
  if typeof(rr) == "error" then return rr end if
  rd = rr[0]
  rdata_size = rr[1]
  rdt = _objreader_skip_bytes_len(rd)
  if typeof(rdt) == "error" then return rdt end if
  rd = rdt[0]
  data_size = rdt[1]
  rbss = _objreader_read_u32(rd)
  if typeof(rbss) == "error" then return rbss end if
  rd = rbss[0]
  bss_size = rbss[1]

  public_labels = 0
  private_labels = 0
  for section_index = 0 to 2
    rlabels = _mlo_scan_label_counts(rd)
    if typeof(rlabels) == "error" then return rlabels end if
    rd = rlabels[0]
    public_labels = public_labels + rlabels[1]
    private_labels = private_labels + rlabels[2]
    rpatches = _mlo_skip_patches(rd, version)
    if typeof(rpatches) == "error" then return rpatches end if
    rd = rpatches
  end for
  rbss_labels = _mlo_scan_label_counts(rd)
  if typeof(rbss_labels) == "error" then return rbss_labels end if
  rd = rbss_labels[0]
  public_labels = public_labels + rbss_labels[1]
  private_labels = private_labels + rbss_labels[2]
  rimports = _mlo_read_imports(rd)
  if typeof(rimports) == "error" then return rimports end if
  return MloLayoutScan(entry_label, text_size, rdata_size, data_size, bss_size, public_labels, private_labels, rimports[1])
end function

function _copy_mlo_sections_from_file(path, text_buf, text_off, rdata_buf, rdata_off, data_buf, data_off)
  raw = fs.readAllBytes(path)
  if typeof(raw) == "error" then return raw end if
  rd = _objreader_new(raw)
  rmagic = _objreader_read_string(rd)
  if typeof(rmagic) == "error" then return rmagic end if
  rd = rmagic[0]
  if rmagic[1] != "MLO1" then return error(1, "invalid MiniLang object magic") end if
  rver = _objreader_read_u32(rd)
  if typeof(rver) == "error" then return rver end if
  rd = rver[0]
  if rver[1] != 1 and rver[1] != 2 then return error(1, "unsupported MiniLang object version") end if
  for i = 0 to 2
    rs = _objreader_skip_bytes(rd)
    if typeof(rs) == "error" then return rs end if
    rd = rs
  end for
  rt = _objreader_copy_bytes_into(rd, text_buf, text_off)
  if typeof(rt) == "error" then return rt end if
  rd = rt[0]
  rr = _objreader_copy_bytes_into(rd, rdata_buf, rdata_off)
  if typeof(rr) == "error" then return rr end if
  rd = rr[0]
  rdt = _objreader_copy_bytes_into(rd, data_buf, data_off)
  if typeof(rdt) == "error" then return rdt end if
  return true
end function

// Count public and private labels while an object is already decoded during
// the section pass. The later linker pass can then allocate only the maps and
// capacities that the object actually needs.
function _mlo_label_counts(obj)
  public_total = 0
  private_total = 0
  section_sets = [try(obj.asm_labels), try(obj.rdata_labels), try(obj.data_labels), try(obj.bss_labels)]
  for si = 0 to len(section_sets) - 1
    section_labels = section_sets[si]
    if typeof(section_labels) != "array" or len(section_labels) <= 0 then continue end if
    for li = 0 to len(section_labels) - 1
      lb = section_labels[li]
      if typeof(lb) != "struct" then continue end if
      nm = try(lb.name)
      if typeof(nm) == "string" and nm != "" then
        if s.startsWith(nm, "objm_") then
          private_total = private_total + 1
        else
          public_total = public_total + 1
        end if
      end if
    end for
  end for
  return [public_total, private_total]
end function

function _read_mlo_file_for_layout(path)
  raw = fs.readAllBytes(path)
  if typeof(raw) == "error" then return raw end if
  rd = _objreader_new(raw)

  rmagic = _objreader_read_string(rd)
  if typeof(rmagic) == "error" then return rmagic end if
  rd = rmagic[0]
  if rmagic[1] != "MLO1" then return error(1, "invalid MiniLang object magic") end if

  rver = _objreader_read_u32(rd)
  if typeof(rver) == "error" then return rver end if
  rd = rver[0]
  version = rver[1]
  if version != 1 and version != 2 then return error(1, "unsupported MiniLang object version") end if

  rkind = _objreader_read_string(rd)
  if typeof(rkind) == "error" then return rkind end if
  rd = rkind[0]
  kind = rkind[1]

  rmod = _objreader_read_string(rd)
  if typeof(rmod) == "error" then return rmod end if
  rd = rmod[0]
  module_file = rmod[1]

  rentry = _objreader_read_string(rd)
  if typeof(rentry) == "error" then return rentry end if
  rd = rentry[0]
  entry_label = rentry[1]

  rtext = _objreader_skip_bytes(rd)
  if typeof(rtext) == "error" then return rtext end if
  rd = rtext

  rrdata = _objreader_skip_bytes(rd)
  if typeof(rrdata) == "error" then return rrdata end if
  rd = rrdata

  rdata2 = _objreader_skip_bytes(rd)
  if typeof(rdata2) == "error" then return rdata2 end if
  rd = rdata2

  rbss = _objreader_read_u32(rd)
  if typeof(rbss) == "error" then return rbss end if
  rd = rbss[0]
  bss_size = rbss[1]

  r1 = _mlo_read_labels(rd)
  if typeof(r1) == "error" then return r1 end if
  rd = r1[0]
  asm_labels = r1[1]

  r2 = _mlo_skip_patches(rd, version)
  if typeof(r2) == "error" then return r2 end if
  rd = r2

  r3 = _mlo_read_labels(rd)
  if typeof(r3) == "error" then return r3 end if
  rd = r3[0]
  rdata_labels = r3[1]

  r4 = _mlo_skip_patches(rd, version)
  if typeof(r4) == "error" then return r4 end if
  rd = r4

  r5 = _mlo_read_labels(rd)
  if typeof(r5) == "error" then return r5 end if
  rd = r5[0]
  data_labels = r5[1]

  r6 = _mlo_skip_patches(rd, version)
  if typeof(r6) == "error" then return r6 end if
  rd = r6

  r7 = _mlo_read_labels(rd)
  if typeof(r7) == "error" then return r7 end if
  rd = r7[0]
  bss_labels = r7[1]

  r8 = _mlo_read_imports(rd)
  if typeof(r8) == "error" then return r8 end if
  imports = r8[1]

  return MloObject(kind, module_file, entry_label, bytes(0), bytes(0), bytes(0), bss_size, asm_labels, [], rdata_labels, [], data_labels, [], bss_labels, imports)
end function

function _label_key(name)
  txt = _coerce_name(name)
  if txt == "" then return "" end if
  return txt
end function

function _link_resolve_target(label_map, labels, link_patch_recs, text_rva, rdata_rva, data_rva, bss_rva, target)
  trg = t.fastmap_get(label_map, _label_key(target), -1)
  if typeof(trg) != "int" or trg < 0 then
    trg = _label_lookup_fallback(labels, target, -1)
    if typeof(trg) == "int" and trg >= 0 then
      label_map = t.fastmap_set(label_map, _label_key(target), trg)
    end if
  end if
  if typeof(trg) != "int" or trg < 0 then
    trg = _link_rec_labels_lookup(link_patch_recs, text_rva, rdata_rva, data_rva, bss_rva, target, -1)
    if typeof(trg) == "int" and trg >= 0 then
      label_map = t.fastmap_set(label_map, _label_key(target), trg)
    end if
  end if
  return [label_map, trg]
end function

function _link_local_labels_get(local_label_map, local_labels, target)
  trg = t.fastmap_get(local_label_map, _label_key(target), -1)
  if typeof(trg) == "int" and trg >= 0 then return trg end if
  return -1
end function

function _link_local_patch_target(src_patch, target)
  if typeof(src_patch) != "string" or typeof(target) != "string" then return "" end if
  if target == "" or s.startsWith(target, "objm_") then return "" end if
  base = _basename(src_patch)
  sep = s.indexOf(base, "_", 0)
  if typeof(sep) != "int" or sep <= 0 then return "" end if
  idx = s.substr(base, 0, sep)
  if idx == "" then return "" end if
  return "objm_" + idx + "__" + target
end function

function _link_target_prefers_global(target)
  if typeof(target) != "string" or target == "" then return true end if
  if s.startsWith(target, "objm_") then return true end if
  if s.startsWith(target, "fn_") then return true end if
  if s.startsWith(target, "g_") then return true end if
  if s.startsWith(target, "gc_") then return true end if
  if s.startsWith(target, "heap_") then return true end if
  if s.startsWith(target, "iat_") then return true end if
  if s.startsWith(target, "modinit_") then return true end if
  if s.startsWith(target, "dbg_loc_") then return true end if
  return false
end function

function _link_resolve_patch_target(label_map, obj_index_map, obj_index_lists, local_label_map, local_labels, labels, link_patch_recs, text_rva, rdata_rva, data_rva, bss_rva, src_patch, target)
  if s.startsWith(target, "objm_") then
    trg_obj = _link_local_labels_get(local_label_map, local_labels, target)
    if typeof(trg_obj) == "int" and trg_obj >= 0 then return [label_map, trg_obj] end if
    trg_obj = _link_obj_label_map_get(obj_index_map, target, -1)
    if typeof(trg_obj) != "int" or trg_obj < 0 then
      trg_obj = _link_obj_label_list_get(obj_index_lists, target, -1)
    end if
    if typeof(trg_obj) != "int" or trg_obj < 0 then
      trg_obj = _link_rec_labels_lookup(link_patch_recs, text_rva, rdata_rva, data_rva, bss_rva, target, -1)
    end if
    return [label_map, trg_obj]
  end if

  local_target = _link_local_patch_target(src_patch, target)
  if _link_target_prefers_global(target) == false then
    trg = _link_local_labels_get(local_label_map, local_labels, target)
    if typeof(trg) == "int" and trg >= 0 then return [label_map, trg] end if
  end if

  if local_target != "" and local_target != target and _link_target_prefers_global(target) == false then
    trg = _link_local_labels_get(local_label_map, local_labels, local_target)
    if typeof(trg) == "int" and trg >= 0 then return [label_map, trg] end if
    trg = _link_obj_label_map_get(obj_index_map, local_target, -1)
    if typeof(trg) == "int" and trg >= 0 then return [label_map, trg] end if
  end if

  rr = _link_resolve_target(label_map, labels, link_patch_recs, text_rva, rdata_rva, data_rva, bss_rva, target)
  label_map = rr[0]
  trg = rr[1]
  if typeof(trg) == "int" and trg >= 0 then return [label_map, trg] end if

  if local_target != "" and local_target != target and _link_target_prefers_global(target) then
    trg = _link_local_labels_get(local_label_map, local_labels, target)
    if typeof(trg) == "int" and trg >= 0 then return [label_map, trg] end if
    trg = _link_local_labels_get(local_label_map, local_labels, local_target)
    if typeof(trg) == "int" and trg >= 0 then return [label_map, trg] end if
    trg = _link_obj_label_map_get(obj_index_map, local_target, -1)
  end if
  return [label_map, trg]
end function

function _link_resolve_patch_target_cached(label_map, target_cache, obj_index_map, obj_index_lists, local_label_map, local_labels, labels, link_patch_recs, text_rva, rdata_rva, data_rva, bss_rva, src_patch, target)
  cached = t.fastmap_get(target_cache, target, -1)
  if typeof(cached) == "int" and cached >= 0 then
    return [label_map, target_cache, cached]
  end if

  rr = _link_resolve_patch_target(label_map, obj_index_map, obj_index_lists, local_label_map, local_labels, labels, link_patch_recs, text_rva, rdata_rva, data_rva, bss_rva, src_patch, target)
  label_map = rr[0]
  trg = rr[1]
  if typeof(trg) == "int" and trg >= 0 then
    target_cache = t.fastmap_set(target_cache, target, trg)
  end if
  return [label_map, target_cache, trg]
end function

function _link_direct_patch_target(label_map, obj_index_map, source_obj_map, source_obj_prefix, target)
  if s.startsWith(target, "objm_") then
    // Most private relocations stay inside their source fragment. Bypass the
    // repeated decimal objm_N__ parser for that overwhelmingly common case.
    if source_obj_prefix != "" and s.startsWith(target, source_obj_prefix) then
      return t.fastmap_get(source_obj_map, target, -1)
    end if
    return _link_obj_label_map_get(obj_index_map, target, -1)
  end if
  return t.fastmap_get(label_map, target, -1)
end function

function _apply_mlo_patches_from_file(src_patch, obj_text_off, obj_rdata_off, obj_data_off, obj_bss_off, label_map, obj_index_map, obj_index_lists, labels, link_patch_recs, text_rva, rdata_rva, data_rva, bss_rva, image_base, buf, rdata_buf, data_buf, patch_index)
  raw = fs.readAllBytes(src_patch)
  if typeof(raw) == "error" then
    msg = "failed to read MiniLang object file during patching"
    if typeof(raw.message) == "string" then msg = raw.message end if
    print "CompileError: " + msg + " (" + src_patch + ")"
    return [2, label_map, patch_index]
  end if

  rd = _objreader_new(raw)
  rmagic = _objreader_read_string(rd)
  if typeof(rmagic) == "error" then return [2, label_map, patch_index] end if
  rd = rmagic[0]
  if rmagic[1] != "MLO1" then
    print "CompileError: invalid MiniLang object magic (" + src_patch + ")"
    return [2, label_map, patch_index]
  end if
  rver = _objreader_read_u32(rd)
  if typeof(rver) == "error" then return [2, label_map, patch_index] end if
  rd = rver[0]
  version = rver[1]
  if version != 1 and version != 2 then
    print "CompileError: unsupported MiniLang object version (" + src_patch + ")"
    return [2, label_map, patch_index]
  end if

  for i = 0 to 2
    rs = _objreader_read_string(rd)
    if typeof(rs) == "error" then return [2, label_map, patch_index] end if
    rd = rs[0]
  end for
  for i = 0 to 2
    rb = _objreader_skip_bytes(rd)
    if typeof(rb) == "error" then return [2, label_map, patch_index] end if
    rd = rb
  end for
  rbss = _objreader_read_u32(rd)
  if typeof(rbss) == "error" then return [2, label_map, patch_index] end if
  rd = rbss[0]
  // MLO v2 represents same-fragment text targets as direct offsets. Named
  // labels are already in the combined map, so avoid decoding and hashing the
  // label table a second time. Legacy v1 and namespaced resolution paths below
  // remain available on a genuine map miss.
  local_label_map = t.fastmap_new(16)
  local_labels = []
  last_target = ""
  last_value = -1
  // This cache contains only uncommon legacy targets that miss the direct
  // global/object indexes. Keeping it compact avoids oversized empty tables.
  target_cache = t.fastmap_new(1024)
  source_obj_map = t.fastmap_new(16)
  source_obj_prefix = ""
  source_obj_index = _mlo_sort_rank(_basename(src_patch))
  if source_obj_index >= 0 and source_obj_index < 2147483647 and source_obj_index < len(obj_index_map) then
    source_obj_candidate = obj_index_map[source_obj_index]
    if typeof(source_obj_candidate) == "struct" then
      source_obj_map = source_obj_candidate
      source_obj_prefix = "objm_" + source_obj_index + "__"
    end if
  end if

  rskip1 = _mlo_skip_labels(rd)
  if typeof(rskip1) == "error" then return [2, label_map, patch_index] end if
  rd = rskip1
  rct = _objreader_read_u32(rd)
  if typeof(rct) == "error" then return [2, label_map, patch_index] end if
  rd = rct[0]
  text_patch_count = rct[1]
  if text_patch_count > 0 then
    for i = 0 to text_patch_count - 1
      pt_target = ""
      pt_local = -1
      pt_off = 0
      ro = _objreader_read_u32(rd)
      if typeof(ro) == "error" then return [2, label_map, patch_index] end if
      rd = ro[0]
      pt_off = ro[1]
      if version == 1 then
        rt = _objreader_read_string(rd)
        if typeof(rt) == "error" then return [2, label_map, patch_index] end if
        rd = rt[0]
        pt_target = rt[1]
      else
        rtag = _objreader_read_u32(rd)
        if typeof(rtag) == "error" then return [2, label_map, patch_index] end if
        rd = rtag[0]
        target_tag = rtag[1]
        if target_tag == 0 then
          rt = _objreader_read_string(rd)
          if typeof(rt) == "error" then return [2, label_map, patch_index] end if
          rd = rt[0]
          pt_target = rt[1]
        else
          if target_tag != 1 then return [2, label_map, patch_index] end if
          rt = _objreader_read_u32(rd)
          if typeof(rt) == "error" then return [2, label_map, patch_index] end if
          rd = rt[0]
          pt_local = rt[1]
        end if
      end if
      rk = _objreader_skip_bytes(rd)
      if typeof(rk) == "error" then return [2, label_map, patch_index] end if
      rd = rk
      if pt_local < 0 and (typeof(pt_target) != "string" or pt_target == "" or pt_target == "unknown") then
        continue
      end if

      trg = -1
      if pt_local >= 0 then
        trg = text_rva + obj_text_off + pt_local
      else
        if pt_target == last_target then
        trg = last_value
      else
        // Nearly all streamed patches reference an exact, already-namespaced
        // label.  Resolve that without allocating the multi-value fallback
        // result or populating a redundant per-file cache.
        trg = _link_direct_patch_target(label_map, obj_index_map, source_obj_map, source_obj_prefix, pt_target)
        if typeof(trg) != "int" or trg < 0 then
          rr = _link_resolve_patch_target_cached(label_map, target_cache, obj_index_map, obj_index_lists, local_label_map, local_labels, labels, link_patch_recs, text_rva, rdata_rva, data_rva, bss_rva, src_patch, pt_target)
          label_map = rr[0]
          target_cache = rr[1]
          trg = rr[2]
        end if
        last_target = pt_target
        last_value = trg
        end if
      end if
      if typeof(trg) != "int" or trg < 0 then
        print "CompileError: unknown patch target: " + pt_target
        return [2, label_map, patch_index]
      end if
      abs_off = obj_text_off + pt_off
      if abs_off < 0 or abs_off + 3 >= len(buf) then
        print "CompileError: invalid patch position for: " + pt_target
        return [2, label_map, patch_index]
      end if
      src_next = text_rva + abs_off + 4
      disp = trg - src_next
      buf[abs_off] = disp & 0xFF
      buf[abs_off + 1] = (disp >> 8) & 0xFF
      buf[abs_off + 2] = (disp >> 16) & 0xFF
      buf[abs_off + 3] = (disp >> 24) & 0xFF
      patch_index = patch_index + 1
    end for
  end if

  rskip2 = _mlo_skip_labels(rd)
  if typeof(rskip2) == "error" then return [2, label_map, patch_index] end if
  rd = rskip2
  rcr = _objreader_read_u32(rd)
  if typeof(rcr) == "error" then return [2, label_map, patch_index] end if
  rd = rcr[0]
  rdata_patch_count = rcr[1]
  if rdata_patch_count > 0 then
    for i = 0 to rdata_patch_count - 1
      pt_target = ""
      pt_local = -1
      pt_off = 0
      ro = _objreader_read_u32(rd)
      if typeof(ro) == "error" then return [2, label_map, patch_index] end if
      rd = ro[0]
      pt_off = ro[1]
      if version == 1 then
        rt = _objreader_read_string(rd)
        if typeof(rt) == "error" then return [2, label_map, patch_index] end if
        rd = rt[0]
        pt_target = rt[1]
      else
        rtag = _objreader_read_u32(rd)
        if typeof(rtag) == "error" then return [2, label_map, patch_index] end if
        rd = rtag[0]
        target_tag = rtag[1]
        if target_tag == 0 then
          rt = _objreader_read_string(rd)
          if typeof(rt) == "error" then return [2, label_map, patch_index] end if
          rd = rt[0]
          pt_target = rt[1]
        else
          if target_tag != 1 then return [2, label_map, patch_index] end if
          rt = _objreader_read_u32(rd)
          if typeof(rt) == "error" then return [2, label_map, patch_index] end if
          rd = rt[0]
          pt_local = rt[1]
        end if
      end if
      rk = _objreader_skip_bytes(rd)
      if typeof(rk) == "error" then return [2, label_map, patch_index] end if
      rd = rk
      if pt_local < 0 and (typeof(pt_target) != "string" or pt_target == "" or pt_target == "unknown") then
        continue
      end if

      trg = -1
      if pt_local >= 0 then
        trg = text_rva + obj_text_off + pt_local
      else
        if pt_target == last_target then
        trg = last_value
      else
        trg = _link_direct_patch_target(label_map, obj_index_map, source_obj_map, source_obj_prefix, pt_target)
        if typeof(trg) != "int" or trg < 0 then
          rr = _link_resolve_patch_target_cached(label_map, target_cache, obj_index_map, obj_index_lists, local_label_map, local_labels, labels, link_patch_recs, text_rva, rdata_rva, data_rva, bss_rva, src_patch, pt_target)
          label_map = rr[0]
          target_cache = rr[1]
          trg = rr[2]
        end if
        last_target = pt_target
        last_value = trg
        end if
      end if
      if typeof(trg) != "int" or trg < 0 then
        print "CompileError: unknown data patch target: " + pt_target
        return [2, label_map, patch_index]
      end if
      abs_off = obj_rdata_off + pt_off
      if abs_off < 0 or abs_off + 7 >= len(rdata_buf) then
        print "CompileError: invalid data patch position for: " + pt_target
        return [2, label_map, patch_index]
      end if
      target_va = image_base + trg
      b8 = t.u64(target_va)
      for bi = 0 to 7
        rdata_buf[abs_off + bi] = b8[bi]
      end for
    end for
  end if

  rskip3 = _mlo_skip_labels(rd)
  if typeof(rskip3) == "error" then return [2, label_map, patch_index] end if
  rd = rskip3
  rcd = _objreader_read_u32(rd)
  if typeof(rcd) == "error" then return [2, label_map, patch_index] end if
  rd = rcd[0]
  data_patch_count = rcd[1]
  if data_patch_count > 0 then
    for i = 0 to data_patch_count - 1
      pt_target = ""
      pt_local = -1
      pt_off = 0
      ro = _objreader_read_u32(rd)
      if typeof(ro) == "error" then return [2, label_map, patch_index] end if
      rd = ro[0]
      pt_off = ro[1]
      if version == 1 then
        rt = _objreader_read_string(rd)
        if typeof(rt) == "error" then return [2, label_map, patch_index] end if
        rd = rt[0]
        pt_target = rt[1]
      else
        rtag = _objreader_read_u32(rd)
        if typeof(rtag) == "error" then return [2, label_map, patch_index] end if
        rd = rtag[0]
        target_tag = rtag[1]
        if target_tag == 0 then
          rt = _objreader_read_string(rd)
          if typeof(rt) == "error" then return [2, label_map, patch_index] end if
          rd = rt[0]
          pt_target = rt[1]
        else
          if target_tag != 1 then return [2, label_map, patch_index] end if
          rt = _objreader_read_u32(rd)
          if typeof(rt) == "error" then return [2, label_map, patch_index] end if
          rd = rt[0]
          pt_local = rt[1]
        end if
      end if
      rk = _objreader_skip_bytes(rd)
      if typeof(rk) == "error" then return [2, label_map, patch_index] end if
      rd = rk
      if pt_local < 0 and (typeof(pt_target) != "string" or pt_target == "" or pt_target == "unknown") then
        continue
      end if

      trg = -1
      if pt_local >= 0 then
        trg = text_rva + obj_text_off + pt_local
      else
        if pt_target == last_target then
        trg = last_value
      else
        trg = _link_direct_patch_target(label_map, obj_index_map, source_obj_map, source_obj_prefix, pt_target)
        if typeof(trg) != "int" or trg < 0 then
          rr = _link_resolve_patch_target_cached(label_map, target_cache, obj_index_map, obj_index_lists, local_label_map, local_labels, labels, link_patch_recs, text_rva, rdata_rva, data_rva, bss_rva, src_patch, pt_target)
          label_map = rr[0]
          target_cache = rr[1]
          trg = rr[2]
        end if
        last_target = pt_target
        last_value = trg
        end if
      end if
      if typeof(trg) != "int" or trg < 0 then
        print "CompileError: unknown data patch target: " + pt_target
        return [2, label_map, patch_index]
      end if
      abs_off = obj_data_off + pt_off
      if abs_off < 0 or abs_off + 7 >= len(data_buf) then
        print "CompileError: invalid data patch position for: " + pt_target
        return [2, label_map, patch_index]
      end if
      target_va = image_base + trg
      b8 = t.u64(target_va)
      for bi = 0 to 7
        data_buf[abs_off + bi] = b8[bi]
      end for
    end for
  end if

  return [0, label_map, patch_index]
end function

function _concat_bytes_parts(parts_builder)
  parts = t.arr_chunk_finish(parts_builder)
  total = 0
  if typeof(parts) == "array" and len(parts) > 0 then
    for i = 0 to len(parts) - 1
      if typeof(parts[i]) == "bytes" then total = total + len(parts[i]) end if
    end for
  end if
  buf = bytes(total, 0)
  off = 0
  if typeof(parts) == "array" and len(parts) > 0 then
    for i = 0 to len(parts) - 1
      part = parts[i]
      if typeof(part) != "bytes" then continue end if
      copyBytes(buf, off, part, 0, len(part))
      off = off + len(part)
    end for
  end if
  return buf
end function

function _module_init_rec_for_file(module_init_recs, module_file)
  if typeof(module_init_recs) != "array" or len(module_init_recs) <= 0 then return 0 end if
  for i = 0 to len(module_init_recs) - 1
    it = module_init_recs[i]
    if typeof(it) != "array" or len(it) < 5 then continue end if
    if _path_eq(_coerce_name(it[0]), module_file) then return it end if
  end for
  return 0
end function

function _find_main_name(state)
  if typeof(state.user_functions) != "array" or len(state.user_functions) <= 0 then return "" end if
  for i = 0 to len(state.user_functions) - 1
    it = state.user_functions[i]
    if typeof(it) == "array" and len(it) == 2 and _coerce_name(it[0]) == "main" then
      return "main"
    end if
  end for
  return ""
end function

function _merge_string_arrays(dst, src)
  merged = dst
  if typeof(merged) != "array" then merged = [] end if
  if typeof(src) != "array" or len(src) <= 0 then return merged end if
  for i = 0 to len(src) - 1
    v = _coerce_name(src[i])
    if v == "" then continue end if
    if _array_contains(merged, v) == false then
      merged = merged + [v]
    end if
  end for
  return merged
end function

function _is_internal_helper_label_local(lbl)
  if typeof(lbl) != "string" then return false end if
  if _startsWith(lbl, "fn_") == false then return false end if
  if _startsWith(lbl, "fn_user_") then return false end if
  if _startsWith(lbl, "fn_extern_") then return false end if
  // These are local control-flow labels, not runtime support routines. A
  // MiniQuake-sized build has roughly one return label per user function;
  // admitting them here turns the iterative helper closure into O(n^2) work.
  if _startsWith(lbl, "fn_ret_") then return false end if
  if _startsWith(lbl, "fn_defer_") then return false end if
  return true
end function

function _collect_internal_helper_targets(dst, patches)
  merged = dst
  if typeof(merged) != "array" then merged = [] end if
  if typeof(patches) != "array" or len(patches) <= 0 then return merged end if
  for i = 0 to len(patches) - 1
    pt = patches[i]
    if typeof(pt) != "struct" then continue end if
    raw_target = try(pt.target)
    // Numeric targets are local MLO-v2 text relocations and cannot introduce
    // a new runtime-helper dependency outside this fragment.
    if typeof(raw_target) != "string" then continue end if
    trg = raw_target
    if _is_internal_helper_label_local(trg) == false then continue end if
    if _array_contains(merged, trg) then continue end if
    merged = merged + [trg]
  end for
  return merged
end function

function _extern_symbol_default(qname)
  if typeof(qname) != "string" then return "" end if
  return _last_segment_after_dot(qname)
end function

function _abi_param_type_supported(ty)
  t0 = s.toLowerAscii(s.trim(ty))
  return t0 == "int" or t0 == "i64" or t0 == "u64" or t0 == "i32" or t0 == "u32" or t0 == "i16" or t0 == "u16" or t0 == "i8" or t0 == "u8" or t0 == "double" or t0 == "bool" or t0 == "ptr" or t0 == "pointer" or t0 == "cstr" or t0 == "cstring" or t0 == "wstr" or t0 == "wstring" or t0 == "void" or t0 == "none" or t0 == "bytes" or t0 == "buffer" or t0 == "bytebuffer"
end function

function _abi_return_type_supported(ty)
  t0 = s.toLowerAscii(s.trim(ty))
  return t0 == "void" or t0 == "none" or t0 == "bool" or t0 == "int" or t0 == "i64" or t0 == "u64" or t0 == "i32" or t0 == "u32" or t0 == "i16" or t0 == "u16" or t0 == "i8" or t0 == "u8" or t0 == "double" or t0 == "ptr" or t0 == "pointer" or t0 == "cstr" or t0 == "wstr"
end function

function _extern_struct_field_type_supported(ty)
  t0 = s.toLowerAscii(s.trim(ty))
  return t0 == "i8" or t0 == "u8" or t0 == "i16" or t0 == "u16" or t0 == "i32" or t0 == "u32" or t0 == "i64" or t0 == "u64" or t0 == "int" or t0 == "bool" or t0 == "ptr" or t0 == "pointer"
end function

struct ExternStructLayout
  qname,
  fields,
  types,
  offsets,
  size,
  align,
end struct

function _extern_struct_type_size(ty)
  t0 = s.toLowerAscii(s.trim(ty))
  if t0 == "i8" or t0 == "u8" then return 1 end if
  if t0 == "i16" or t0 == "u16" then return 2 end if
  if t0 == "i32" or t0 == "u32" or t0 == "bool" then return 4 end if
  if t0 == "i64" or t0 == "u64" or t0 == "int" or t0 == "ptr" or t0 == "pointer" then return 8 end if
  return 0
end function

function _extern_struct_layout_find(layouts, qname)
  if typeof(layouts) != "array" or len(layouts) <= 0 then return 0 end if
  for eli = 0 to len(layouts) - 1
    it = layouts[eli]
    if typeof(it) == "struct" and it.qname == qname then return it end if
  end for
  return 0
end function

function _collect_file_package_prefixes(program)
  acc = []
  cur_file = ""
  seen_nonpkg = []
  cur_pref = ""

  if typeof(program) != "array" or len(program) <= 0 then return acc end if

  for i = 0 to len(program) - 1
    st = program[i]
    if typeof(st) != "struct" then continue end if

    sf = _st_file(st)
    if sf != "" and _path_eq(sf, cur_file) == false then
      cur_file = sf
      cur_pref = ""
      file_key = cur_file
      if file_key == "" then file_key = "<entry>" end if
      if _label_get(seen_nonpkg, file_key, 0) != 0 then
        cur_pref = _alias_get(acc, file_key)
      end if
    end if

    k = st.node_kind
    file_key2 = cur_file
    if file_key2 == "" then file_key2 = "<entry>" end if

    if k == "NamespaceDecl" then
      if _label_get(seen_nonpkg, file_key2, 0) == 0 then
        ns = _coerce_name(st.name)
        if ns != "" then
          cur_pref = ns + "."
          acc = _alias_set(acc, file_key2, cur_pref)
        end if
      end if
      continue
    end if

    seen_nonpkg = _label_set(seen_nonpkg, file_key2, 1)
  end for

  return acc
end function

function _collect_extern_structs_walk(stmts, prefix, current_file, file_prefixes, names)
  if typeof(names) != "array" then names = [] end if
  if typeof(stmts) != "array" or len(stmts) <= 0 then return names end if
  cur_file = current_file
  pref = prefix
  for i = 0 to len(stmts) - 1
    st = stmts[i]
    if typeof(st) != "struct" then continue end if
    sf = _st_file(st)
    if sf == "" then sf = cur_file end if
    if cur_file == "" or (sf != "" and _path_eq(sf, cur_file) == false) then
      cur_file = sf
      pref = prefix
      fk = cur_file
      if fk == "" then fk = "<entry>" end if
      p0 = _alias_get(file_prefixes, fk)
      if p0 != "" then pref = p0 end if
    end if
    if st.node_kind == "NamespaceDecl" then
      nsd = _coerce_name(st.name)
      if nsd != "" then pref = nsd + "." end if
      continue
    end if
    if st.node_kind == "NamespaceDef" then
      ns = _coerce_name(st.name)
      sub_pref = pref
      if ns != "" then sub_pref = pref + ns + "." end if
      names = _collect_extern_structs_walk(st.body, sub_pref, cur_file, file_prefixes, names)
      if typeof(names) == "error" then return names end if
      continue
    end if
    if st.node_kind != "StructDef" or typeof(st._extern_field_types) != "array" or len(st._extern_field_types) <= 0 then
      continue
    end if
    if typeof(st.fields) != "array" or len(st.fields) != len(st._extern_field_types) then
      return error(1, "extern struct " + st.name + ": field/type count mismatch")
    end if
    for fi = 0 to len(st._extern_field_types) - 1
      fty = st._extern_field_types[fi]
      if _extern_struct_field_type_supported(fty) == false then
        return error(1, "extern struct " + st.name + ": unsupported field type '" + fty + "'")
      end if
    end for
    qn = pref + st.name
    if typeof(_extern_struct_layout_find(names, qn)) == "struct" then return error(1, "Duplicate extern struct declaration: " + qn) end if
    offs_b = t.arr_chunk_new(len(st.fields))
    struct_off = 0
    struct_align = 1
    for lfi = 0 to len(st.fields) - 1
      fsize = _extern_struct_type_size(st._extern_field_types[lfi])
      falign = fsize
      if falign > 8 then falign = 8 end if
      if falign > struct_align then struct_align = falign end if
      if struct_off % falign != 0 then struct_off = struct_off + (falign - (struct_off % falign)) end if
      offs_b = t.arr_chunk_push(offs_b, struct_off)
      struct_off = struct_off + fsize
    end for
    if struct_off % struct_align != 0 then struct_off = struct_off + (struct_align - (struct_off % struct_align)) end if
    names = names + [ExternStructLayout(qn, st.fields, st._extern_field_types, t.arr_chunk_finish(offs_b), struct_off, struct_align)]
  end for
  return names
end function

// Collect native struct declarations before validating extern signatures.
function collect_extern_structs(program)
  prefixes = _collect_file_package_prefixes(program)
  return _collect_extern_structs_walk(program, "", "", prefixes, [])
end function

// Validate supported ABI types, out parameters and native struct references.
function validate_extern_sigs(extern_sigs, extern_struct_names)
  if typeof(extern_sigs) != "array" or len(extern_sigs) <= 0 then return "" end if
  for si = 0 to len(extern_sigs) - 1
    sig = extern_sigs[si]
    if typeof(sig) != "struct" then continue end if
    if typeof(sig.dll) != "string" or s.trim(sig.dll) == "" then
      return "extern function " + sig.qname + " missing DLL name"
    end if
    if _compile_target == "linux-x64" and s.endsWith(s.toLowerAscii(s.trim(sig.dll)), ".dll") then
      return "extern function " + sig.qname + ": Windows DLL '" + sig.dll + "' cannot be imported by the linux-x64 target; guard the declaration with TARGET_OS or use a Linux shared library"
    end if
    seen_out = false
    if typeof(sig.params) == "array" and len(sig.params) > 0 then
      for pi = 0 to len(sig.params) - 1
        p = sig.params[pi]
        if typeof(p) != "struct" then continue end if
        ty = ""
        if typeof(p.ty) == "string" then ty = p.ty end if
        if s.trim(ty) == "" then return "extern function " + sig.qname + ": missing ABI type for parameter #" + (pi + 1) end if
        is_out = typeof(p.is_out) == "bool" and p.is_out
        if is_out then
          seen_out = true
          if _abi_param_type_supported(ty) == false and typeof(_extern_struct_layout_find(extern_struct_names, ty)) != "struct" then
            return "extern function " + sig.qname + ": unsupported out parameter type '" + ty + "'"
          end if
        else
          if seen_out then return "extern function " + sig.qname + ": out-parameters must appear at the end of the parameter list" end if
          if _abi_param_type_supported(ty) == false then
            return "extern function " + sig.qname + ": unsupported ABI type '" + ty + "'"
          end if
        end if
      end for
    end if
    ret_ty = sig.ret_ty
    if typeof(ret_ty) != "string" or s.trim(ret_ty) == "" then ret_ty = "void" end if
    if _abi_return_type_supported(ret_ty) == false then
      return "extern function " + sig.qname + ": unsupported return type '" + ret_ty + "'"
    end if
  end for
  return ""
end function

function _collect_extern_sigs_walk(stmts, prefix, current_file, file_prefixes, acc)
  if typeof(acc) != "struct" then acc = t.arr_chunk_new(64) end if
  if typeof(stmts) != "array" or len(stmts) <= 0 then return acc end if

  cur_file = current_file
  pref = prefix

  for i = 0 to len(stmts) - 1
    if i < 0 or i >= len(stmts) then break end if
    st = stmts[i]
    if typeof(st) != "struct" then continue end if

    sf = _st_file(st)
    if sf == "" then sf = cur_file end if
    if cur_file == "" or (sf != "" and _path_eq(sf, cur_file) == false) then
      cur_file = sf
      pref = prefix
      fk = cur_file
      if fk == "" then fk = "<entry>" end if
      p0 = _alias_get(file_prefixes, fk)
      if p0 != "" then pref = p0 end if
    end if

    k = st.node_kind
    if k == "NamespaceDecl" then
      nsd = _coerce_name(st.name)
      if nsd != "" then
        pref = nsd + "."
        fk2 = cur_file
        if fk2 == "" then fk2 = "<entry>" end if
        file_prefixes = _alias_set(file_prefixes, fk2, pref)
      end if
      continue
    end if

    if k == "NamespaceDef" then
      ns = _coerce_name(st.name)
      sub_pref = pref
      if ns != "" then sub_pref = pref + ns + "." end if
      acc = _collect_extern_sigs_walk(st.body, sub_pref, cur_file, file_prefixes, acc)
      continue
    end if

    if k == "ExternFunctionDef" then
      nm = _coerce_name(st.name)
      if nm == "" then continue end if

      qn = nm
      if _containsDot(nm) == false and pref != "" then
        qn = pref + nm
      end if

      dll = ""
      if typeof(st.dll) == "string" then dll = st.dll end if

      sym = ""
      if typeof(st.symbol_name) == "string" then sym = st.symbol_name end if
      if sym == "" then sym = _extern_symbol_default(qn) end if

      rt = ""
      if typeof(st.ret_ty) == "string" then rt = st.ret_ty end if

      ps_chunks = []
      ps_tail = []
      if typeof(st.params) == "array" and len(st.params) > 0 then
        for pi = 0 to len(st.params) - 1
          if pi < 0 or pi >= len(st.params) then break end if
          p = st.params[pi]
          if typeof(p) != "struct" then continue end if
          pn = _coerce_name(p.name)
          pt = ""
          if typeof(p.ty) == "string" then pt = p.ty end if
          pout = false
          if typeof(p.is_out) == "bool" and p.is_out then pout = true end if
          appp = t.arr_chunked_push(ps_chunks, ps_tail, ExternSigParam(pn, pt, pout), 8)
          ps_chunks = appp[0]
          ps_tail = appp[1]
        end for
      end if
      ps = t.arr_chunked_finish(ps_chunks, ps_tail)

      acc = t.arr_chunk_push(acc, ExternSig(qn, _extern_symbol_default(qn), dll, sym, ps, rt))
      continue
    end if
  end for

  return acc
end function

// Normalize all extern declarations into deterministic signature records.
function collect_extern_sigs(program)
  file_prefixes = _collect_file_package_prefixes(program)
  b = _collect_extern_sigs_walk(program, "", "", file_prefixes, t.arr_chunk_new(64))
  return t.arr_chunk_finish(b)
end function

function _heap_probe(tag)
  global _mem_probe_enabled
  if _mem_probe_enabled == false then return end if
  label = tag
  if typeof(label) != "string" then label = "" + label end if
  print "[mem] " + label + " used=" + heap_bytes_used() + " committed=" + heap_bytes_committed() + " reserved=" + heap_bytes_reserved() + " free=" + heap_free_bytes() + " blocks=" + heap_count()
end function

// End the parsing/semantic ownership phase in one operation. Generated code,
// relocations and runtime metadata no longer refer to compact AST NodeIds at
// the two call sites below, so the typed arenas and resolution caches can be
// unrooted before the next full collection instead of surviving until exit.
function _release_frontend_phase_arenas()
  global _path_norm_cache, _front_visited_set, _front_resolve_cache
  t.ast_arena_release()
  _path_norm_cache = 0
  _front_visited_set = 0
  _front_resolve_cache = 0
end function

function _load_program_for_codegen(entry, include_dirs, keep_going, max_errors)
  entry_abs = _path_abspath(entry)
  if entry_abs == "" then entry_abs = entry end if
  // Each compilation owns one compact AST arena. Reset before parsing so a
  // preceding frontcheck in the same process cannot retain obsolete NodeIds.
  t.ast_leaf_reset()
  _heap_probe("load:start")
  check = _run_frontcheck(entry_abs, include_dirs, keep_going, max_errors)
  _heap_probe("load:frontcheck_done")
  diags = check.diagnostics
  if len(diags) > 0 then
    return LoadProgramResult(diags, "", [], check.aliases, [], check.visited, check.parsed_modules)
  end if

  merged_b = t.arr_chunk_new(2048)
  entry_source = ""
  source_pairs_b = t.arr_chunk_new(128)
  visited = check.visited
  parsed_modules = check.parsed_modules
  if typeof(parsed_modules) != "array" and typeof(parsed_modules) != "struct" then parsed_modules = [] end if
  if typeof(visited) != "array" or len(visited) <= 0 then
    visited = [entry_abs]
  end if
  module_count = len(visited)
  probe_stride = 128

  for i = 0 to len(visited) - 1
    path = visited[i]
    parsed = _parsed_module_get(parsed_modules, path)
    if typeof(parsed) != "struct" then
      diags = _add_diag(diags, "CompileError", path, 0, "internal frontend cache miss for: " + path)
      return LoadProgramResult(diags, "", t.arr_chunk_finish(merged_b), check.aliases, t.arr_chunk_finish(source_pairs_b), visited, parsed_modules)
    end if

    if _path_eq(path, entry_abs) and typeof(parsed.source) == "string" then
      entry_source = parsed.source
    else
      if typeof(parsed.source) == "string" and parsed.source != "" then
        source_pairs_b = t.arr_chunk_push(source_pairs_b, StrPair(path, _build_line_starts(parsed.source)))
      end if
    end if

    part = parsed.program
    if typeof(part) == "array" and len(part) > 0 then
      for pi = 0 to len(part) - 1
        merged_b = t.arr_chunk_push(merged_b, part[pi])
      end for
    end if
    // The merged program now owns every node. Drop each module's duplicate
    // array and source buffer as soon as its line map has been materialized.
    parsed.source = ""
    parsed.program = []
    if probe_stride > 0 and (i % probe_stride) == 0 then _heap_probe("load:file_" + i) end if
  end for

  if entry_source == "" and fs.exists(entry_abs) then
    src = fs.readAllText(entry_abs)
    if typeof(src) == "string" then
      entry_source = frontend.normalize_code_for_tokenizer(src)
    end if
  end if

  merged = t.arr_chunk_finish(merged_b)
  source_pairs = t.arr_chunk_finish(source_pairs_b)
  aliases = check.aliases
  _compiler_ast_profile_report(merged, module_count)
  _heap_probe("load:done")
  // Import order and parsed-module caches are frontend-only. Inline dependency
  // closure is derived from the merged AST, so neither container is needed by
  // code generation and both can become collectible at this ownership boundary.
  return LoadProgramResult(diags, entry_source, merged, aliases, source_pairs, [], [])
end function

// Link canonical MLO fragments into the same fixed-address ELF image as the
// monolithic backend. Section offsets, rather than PE RVAs, form the common
// label space; this makes rel32/rip32 and abs64 patching deterministic.
function _link_build_label_maps(patch_file_recs, text_rva, rdata_rva, data_rva, bss_rva, include_private_dump)
  public_label_hint = 0
  if typeof(patch_file_recs) == "array" and len(patch_file_recs) > 0 then
    for ri = 0 to len(patch_file_recs) - 1
      rec = patch_file_recs[ri]
      if typeof(rec) == "array" and len(rec) >= 6 and typeof(rec[5]) == "int" and rec[5] > 0 then
        public_label_hint = public_label_hint + rec[5]
      end if
    end for
  end if
  global_map_capacity = 262144
  if public_label_hint > 0 then
    // FastMap grows at 80% occupancy. A 1.5x hint reaches the final power of
    // two capacity without the memory excess of a blanket 2x allocation.
    global_map_capacity = public_label_hint + (public_label_hint >> 1) + 64
  end if
  label_map = t.fastmap_new(global_map_capacity)
  obj_index_map = []
  obj_index_lists = []
  labels_b = t.arr_chunk_new(512)
  dump_b = t.arr_chunk_new(512)
  private_label_count = 0
  public_label_count = 0
  private_shard_count = 0
  label_gc_count = 0

  if typeof(patch_file_recs) == "array" and len(patch_file_recs) > 0 then
    // Object indices are dense and encoded in objm_N__ labels. Pre-sizing the
    // shard arrays avoids repeated concatenation while each file is streamed.
    obj_index_map = array(len(patch_file_recs) + 1, 0)
    obj_index_lists = array(len(patch_file_recs) + 1, 0)

    for ri = 0 to len(patch_file_recs) - 1
      rec = patch_file_recs[ri]
      if typeof(rec) != "array" or len(rec) < 5 then continue end if
      obj_path = _coerce_name(rec[0])
      obj = _read_mlo_file_for_layout(obj_path)
      if typeof(obj) == "error" then
        print "CompileError: failed to read MiniLang object labels (" + obj_path + ")"
        return [2]
      end if

      section_sets = [
        [obj.asm_labels, text_rva + rec[1]],
        [obj.rdata_labels, rdata_rva + rec[2]],
        [obj.data_labels, data_rva + rec[3]],
        [obj.bss_labels, bss_rva + rec[4]]
      ]
      // Canonical object filenames start with the same dense numeric index as
      // their objm_N__ private labels. Allocate that shard once at its final
      // capacity instead of parsing N and repeatedly rehashing for every label.
      object_index = _mlo_sort_rank(_basename(obj_path))
      private_prefix = ""
      object_private_hint = 0
      if len(rec) >= 7 and typeof(rec[6]) == "int" and rec[6] > 0 then object_private_hint = rec[6] end if
      if object_private_hint > 0 and object_index >= 0 and object_index < 2147483647 and object_index < len(obj_index_map) then
        private_prefix = "objm_" + object_index + "__"
        object_label_capacity = object_private_hint + (object_private_hint >> 1) + 16
        obj_index_map[object_index] = t.fastmap_new(object_label_capacity)
        private_shard_count = private_shard_count + 1
      end if
      for si = 0 to len(section_sets) - 1
        section_labels = section_sets[si][0]
        section_base = section_sets[si][1]
        if typeof(section_labels) != "array" or len(section_labels) == 0 then continue end if
        for li = 0 to len(section_labels) - 1
          lb = section_labels[li]
          if typeof(lb) != "struct" then continue end if
          nm = _label_key(try(lb.name))
          lb_off = try(lb.offset)
          if nm == "" or typeof(lb_off) != "int" or lb_off < 0 then continue end if
          final_v = section_base + lb_off
          if s.startsWith(nm, "objm_") then
            if private_prefix != "" and s.startsWith(nm, private_prefix) then
              private_map = obj_index_map[object_index]
              private_map = t.fastmap_set(private_map, nm, final_v)
              obj_index_map[object_index] = private_map
            else
              // Retain compatibility with hand-authored or legacy MLO files
              // whose filename and private-label namespace do not correspond.
              obj_index_map = _link_obj_label_map_set(obj_index_map, nm, final_v)
            end if
            private_label_count = private_label_count + 1
            if include_private_dump then dump_b = t.arr_chunk_push(dump_b, StrIntPair(nm, final_v)) end if
          else
            label_map = t.fastmap_set(label_map, nm, final_v)
            labels_b = t.arr_chunk_push(labels_b, StrIntPair(nm, final_v))
            public_label_count = public_label_count + 1
            if include_private_dump then dump_b = t.arr_chunk_push(dump_b, StrIntPair(nm, final_v)) end if
          end if
        end for
      end for

      // Only the maps retain label names and offsets. The decoded file-local
      // wrappers can be reclaimed before the next large object is opened.
      obj = 0
      section_sets = 0
      section_labels = 0
      if ((ri + 1) % LINK_LABEL_GC_OBJECT_STRIDE) == 0 then
        gc_collect()
        label_gc_count = label_gc_count + 1
      end if
    end for
  end if

  if _compiler_profile_enabled then
    print "[profile] link_labels_private=" + private_label_count + " public=" + public_label_count + " hint=" + public_label_hint + " shards=" + private_shard_count + " gc=" + label_gc_count
  end if

  return [0, label_map, obj_index_map, obj_index_lists, t.arr_chunk_finish(labels_b), t.arr_chunk_finish(dump_b)]
end function

function _link_mlo_linux_sections(obj_paths, output_exe, text_buf, rdata_buf, data_buf, bss_size, patch_file_recs, imports)
  dynamic_imports = _mlo_linux_dynamic_imports(imports)
  layout = elf.plan(len(text_buf), len(rdata_buf), len(data_buf), elf.dynamic_size(dynamic_imports))
  want_labels_dump = typeof(_dump_labels_path) == "string" and _dump_labels_path != ""
  maps = _link_build_label_maps(
    patch_file_recs, layout.text_off, layout.rdata_off, layout.data_off,
    layout.bss_off, want_labels_dump
  )
  if typeof(maps) != "array" or len(maps) < 6 or maps[0] != 0 then return 2 end if
  label_map = maps[1]
  obj_index_map = maps[2]
  obj_index_lists = maps[3]
  labels = maps[4]
  label_dump = maps[5]

  if want_labels_dump then
    dump_builder = sb.StringBuilder.withCapacity(1048576)
    dump_builder.appendLine("[section] .text raw=" + len(text_buf))
    dump_builder.appendLine("[section] .rdata raw=" + len(rdata_buf))
    dump_builder.appendLine("[section] .data raw=" + len(data_buf))
    if typeof(label_dump) == "array" and len(label_dump) > 0 then
      for li = 0 to len(label_dump) - 1
        item = label_dump[li]
        dump_builder.appendLine("[label] " + item.key + " " + item.value)
      end for
    end if
    wrdump = fs.writeAllText(_dump_labels_path, dump_builder.toString())
    if typeof(wrdump) == "error" then
      print "CompileError: writeAllText failed for ELF label dump: " + _dump_labels_path
      return 2
    end if
  end if

  _compiler_profile_phase("link: applying ELF patches")
  patch_index = 0
  for oi = 0 to len(patch_file_recs) - 1
    rec = patch_file_recs[oi]
    if typeof(rec) != "array" or len(rec) < 5 then continue end if
    src_patch = _coerce_name(rec[0])
    apr = _apply_mlo_patches_from_file(
      src_patch, rec[1], rec[2], rec[3], rec[4], label_map,
      obj_index_map, obj_index_lists, labels, patch_file_recs,
      layout.text_off, layout.rdata_off, layout.data_off, layout.bss_off,
      layout.base, text_buf, rdata_buf, data_buf, patch_index
    )
    if typeof(apr) != "array" or len(apr) < 3 or apr[0] != 0 then return 2 end if
    label_map = apr[1]
    patch_index = apr[2]
    if ((oi + 1) % 128) == 0 then gc_collect() end if
  end for

  entry_file_off = t.fastmap_get(label_map, "_start", -1)
  if typeof(entry_file_off) != "int" or entry_file_off < layout.text_off then
    print "CompileError: missing Linux _start label in linked objects"
    return 2
  end if
  image = elf.build(text_buf, rdata_buf, data_buf, bss_size, entry_file_off - layout.text_off, dynamic_imports)
  if typeof(image) == "error" then
    print "CompileError: failed to build linked ELF image: " + image.message
    return 2
  end if
  wr = fs.writeAllBytes(output_exe, image)
  if typeof(wr) == "error" then
    print "CompileError: writeAllBytes failed for linked ELF image"
    return 2
  end if
  executable_result = _make_linux_output_executable(output_exe)
  if typeof(executable_result) == "error" then
    print "CompileError: " + executable_result.message
    return 2
  end if
  print "OK: wrote " + output_exe + " (native x64 ELF, MiniLang self-hosted compiler " + COMPILER_VERSION + ", MLO pipeline)"
  return 0
end function

function _link_mlo_files(obj_paths, output_exe, subsystem)
  global _dump_labels_path
  global _link_patch_keepalive
  patch_file_recs_b = t.arr_chunk_new(64)
  obj_label_recs_b = t.arr_chunk_new(64)
  imports = []
  entry_label = ""
  text_off = 0
  rdata_off = 0
  data_off = 0
  bss_off = 0

  if typeof(obj_paths) != "array" or len(obj_paths) <= 0 then
    print "CompileError: no MiniLang object files to link"
    return 2
  end if

  _progress_phase("linking")
  _progress_link("objects=" + len(obj_paths) + " output=" + output_exe)
  _compiler_profile_phase("link: collecting objects")
  _progress_link("scanning section sizes, labels and imports")
  for oi = 0 to len(obj_paths) - 1
    obj_path = obj_paths[oi]
    _progress_link("scan object " + (oi + 1) + "/" + len(obj_paths) + ": " + obj_path)
    scan = _read_mlo_layout_scan(obj_path)
    if typeof(scan) == "error" then
      msg = "failed to read MiniLang object file"
      if typeof(scan.message) == "string" then msg = scan.message end if
      print "CompileError: " + msg + " (" + obj_path + ")"
      return 2
    end if

    if entry_label == "" and typeof(scan.entry_label) == "string" and scan.entry_label != "" then
      entry_label = scan.entry_label
    end if

    text_obj_off = text_off
    rdata_obj_off = rdata_off
    data_obj_off = data_off
    bss_obj_off = bss_off

    patch_file_recs_b = t.arr_chunk_push(patch_file_recs_b, [obj_path, text_obj_off, rdata_obj_off, data_obj_off, bss_obj_off, scan.public_label_count, scan.private_label_count])
    // Keep only the file and section offsets. Label maps are built in a second,
    // streaming pass after section layout, and `_link_rec_labels_lookup`
    // reopens one object only on an actual defensive fallback miss. Retaining
    // every decoded label array here would make the following section-buffer
    // allocation trigger an exceptionally expensive large-heap collection.
    obj_label_recs_b = t.arr_chunk_push(obj_label_recs_b, [obj_path, text_obj_off, rdata_obj_off, data_obj_off, bss_obj_off])

    imports = _mlo_merge_imports(imports, scan.imports)
    text_off = text_obj_off + scan.text_size
    rdata_off = rdata_obj_off + scan.rdata_size
    data_off = data_obj_off + scan.data_size
    bss_off = bss_obj_off + scan.bss_size

    if (oi % 32) == 0 then
      _heap_probe("link:obj_" + oi)
    end if
  end for

  _compiler_profile_phase("link: streaming sections")
  _progress_link("allocating final section buffers")
  text_buf = bytes(text_off, 0)
  rdata_buf = bytes(rdata_off, 0)
  data_buf = bytes(data_off, 0)
  patch_file_recs = t.arr_chunk_finish(patch_file_recs_b)
  obj_label_recs = t.arr_chunk_finish(obj_label_recs_b)
  patch_file_recs_b = 0
  obj_label_recs_b = 0

  // The first pass retained metadata only. Reopen one object at a time and
  // copy its three payloads directly into their final offsets. Keep the output
  // buffers explicitly rooted across stride collections.
  _link_patch_keepalive = [text_buf, rdata_buf, data_buf, patch_file_recs, obj_label_recs, imports]
  for oi = 0 to len(patch_file_recs) - 1
    rec_copy = patch_file_recs[oi]
    if typeof(rec_copy) != "array" or len(rec_copy) < 4 then continue end if
    obj_path_copy = _coerce_name(rec_copy[0])
    copy_result = _copy_mlo_sections_from_file(obj_path_copy, text_buf, rec_copy[1], rdata_buf, rec_copy[2], data_buf, rec_copy[3])
    if typeof(copy_result) == "error" then
      msg_copy = "failed to stream MiniLang object sections"
      if typeof(copy_result.message) == "string" then msg_copy = copy_result.message end if
      print "CompileError: " + msg_copy + " (" + obj_path_copy + ")"
      return 2
    end if
    copy_result = 0
    if ((oi + 1) % LINK_SECTION_COPY_GC_OBJECT_STRIDE) == 0 then gc_collect() end if
  end for
  rec_copy = 0
  obj_path_copy = ""
  gc_collect()

  if _compile_target == "linux-x64" then
    return _link_mlo_linux_sections(
      obj_paths, output_exe, text_buf, rdata_buf, data_buf, bss_off,
      patch_file_recs, imports
    )
  end if

  p = pe.newPEBuilder()
  p.subsystem = subsystem
  p = pe.add_section(p, ".text", text_buf, 0x60000020)
  p = pe.add_section(p, ".rdata", rdata_buf, 0x40000040)
  p = pe.add_section(p, ".data", data_buf, 0xC0000040)
  p = pe.add_section(p, ".bss", bytes(0), 0xC0000080)
  p = pe.add_section(p, ".idata", bytes(0), 0xC0000040)

  if len(p.sections) > 3 then
    bs = p.sections[3]
    bs.virt_size = bss_off
    p.sections[3] = bs
  end if

  p = pe.layout(p)
  pe_imports = _imports_to_pe_imports(imports)
  if len(p.sections) <= 4 then
    print "CompileError: internal section layout error (.idata missing)"
    return 2
  end if

  idsec = p.sections[4]
  idr = pe.build_idata(pe_imports, idsec.virt_addr)
  idsec.data = idr.data
  p.sections[4] = idsec
  p.import_rva = idr.import_dir_rva
  p.import_size = idr.idata_total_size

  p = pe.layout(p)
  _heap_probe("link:pe_ready")
  _compiler_profile_phase("link: resolving labels")
  _progress_link("PE layout ready")

  text_rva = p.sections[0].virt_addr
  rdata_rva = p.sections[1].virt_addr
  data_rva = p.sections[2].virt_addr
  bss_rva = p.sections[3].virt_addr

  want_labels_dump = typeof(_dump_labels_path) == "string" and _dump_labels_path != ""
  maps = _link_build_label_maps(
    patch_file_recs, text_rva, rdata_rva, data_rva, bss_rva, false
  )
  if typeof(maps) != "array" or len(maps) < 6 or maps[0] != 0 then return 2 end if
  label_map = maps[1]
  obj_index_map = maps[2]
  obj_index_lists = maps[3]
  labels = maps[4]
  labels_b = t.arr_chunk_push_all(t.arr_chunk_new(512), labels)
  if typeof(idr.iat_symbols) == "array" and len(idr.iat_symbols) > 0 then
    for i = 0 to len(idr.iat_symbols) - 1
      it = idr.iat_symbols[i]
      if typeof(it) != "struct" then continue end if
      if typeof(it.func) != "string" or typeof(it.rva) != "int" then continue end if
      nm1 = "iat_" + it.func
      label_map = t.fastmap_set(label_map, _label_key(nm1), it.rva)
      labels_b = t.arr_chunk_push(labels_b, StrIntPair(nm1, it.rva))
      if typeof(it.dll) == "string" then
        nm2 = "iat_" + _dll_base(it.dll) + "_" + it.func
        label_map = t.fastmap_set(label_map, _label_key(nm2), it.rva)
        labels_b = t.arr_chunk_push(labels_b, StrIntPair(nm2, it.rva))
      end if
    end for
  end if
  labels = t.arr_chunk_finish(labels_b)
  _heap_probe("link:labels_done")
  _progress_link("labels resolved")

  // Address maps and the compact public fallback list now contain everything
  // patching needs. Drop transient builders before streaming relocations. Do
  // not force a full collection here: label-map values still reference decoded
  // object strings and an eager scan at this boundary can overlap their final
  // liveness wave. The normal allocation limit collects them after patching.
  maps = 0
  labels_b = 0

  entry_rva = t.fastmap_get(label_map, _label_key(entry_label), -1)
  if typeof(entry_rva) != "int" or entry_rva < 0 then
    entry_rva = t.fastmap_get(label_map, _label_key("__ml_entry"), -1)
  end if
  if typeof(entry_rva) != "int" or entry_rva < 0 then
    print "CompileError: missing program entry label in linked objects"
    return 2
  end if
  p.entry_rva = entry_rva

  if typeof(_dump_labels_path) == "string" and _dump_labels_path != "" then
    dump_builder = sb.StringBuilder.withCapacity(1048576)
    dump_builder.appendLine("[section] .text raw=" + len(text_buf))
    dump_builder.appendLine("[section] .rdata raw=" + len(rdata_buf))
    dump_builder.appendLine("[section] .data raw=" + len(data_buf))
    if typeof(labels) == "array" and len(labels) > 0 then
      for li = 0 to len(labels) - 1
        lbi = labels[li]
        if typeof(lbi) == "struct" and typeof(lbi.key) == "string" and typeof(lbi.value) == "int" then
          dump_builder.appendLine("[label] " + lbi.key + " " + lbi.value)
        end if
      end for
    end if
    wrdump = fs.writeAllText(_dump_labels_path, dump_builder.toString())
    if typeof(wrdump) == "error" then
      print "CompileError: writeAllText failed for label dump: " + _dump_labels_path
      return 2
    end if
  end if

  buf = text_buf
  // Streamed patching periodically collects a large heap. Keep every mutable
  // section and lookup graph rooted independently of native stack-slot liveness;
  // diagnostic heap probes must not be required to make these references live.
  _link_patch_keepalive = [p, buf, rdata_buf, data_buf, label_map, obj_index_map, obj_index_lists, labels, obj_label_recs, patch_file_recs]
  if typeof(patch_file_recs) == "array" and len(patch_file_recs) > 0 then
    _compiler_profile_phase("link: applying patches")
    _progress_link("applying patches")
    patch_index = 0
    for ri = 0 to len(patch_file_recs) - 1
      rec = patch_file_recs[ri]
      if typeof(rec) != "array" or len(rec) < 4 then continue end if
      src_patch = _coerce_name(rec[0])
      obj_text_off = rec[1]
      obj_rdata_off = rec[2]
      obj_data_off = rec[3]
      obj_bss_off = 0
      if len(rec) >= 5 and typeof(rec[4]) == "int" then obj_bss_off = rec[4] end if

      apr = _apply_mlo_patches_from_file(src_patch, obj_text_off, obj_rdata_off, obj_data_off, obj_bss_off, label_map, obj_index_map, obj_index_lists, labels, obj_label_recs, text_rva, rdata_rva, data_rva, bss_rva, p.image_base, buf, rdata_buf, data_buf, patch_index)
      if typeof(apr) != "array" or len(apr) < 3 then
        print "CompileError: internal streamed patch application failed"
        return 2
      end if
      if apr[0] != 0 then return apr[0] end if
      label_map = apr[1]
      patch_index = apr[2]
      // Streamed patching drops the current raw object on return. Avoid a full
      // collection inside this loop: the large live label/section graph makes
      // the scan expensive, and allocation-limit collection after the patch
      // phase has a simpler root boundary.
      _heap_probe("link:patch_obj_" + (ri + 1))
    end for
  end if
  _link_patch_keepalive = 0
  _heap_probe("link:patches_done")
  _progress_link("patches applied")

  tx = p.sections[0]
  tx.data = buf
  p.sections[0] = tx
  rd = p.sections[1]
  rd.data = rdata_buf
  p.sections[1] = rd
  dt = p.sections[2]
  dt.data = data_buf
  p.sections[2] = dt

  exe = pe.build(p)
  _heap_probe("link:pe_built")
  listing_result = _write_asm_listing_if_enabled(output_exe, p, buf, rdata_buf, data_buf, idsec.data)
  if typeof(listing_result) == "error" then
    print "CompileError: failed to write assembly listing"
    return 2
  end if
  _compiler_profile_phase("link: writing executable")
  _progress_link("writing executable " + output_exe)
  wr = fs.writeAllBytes(output_exe, exe)
  if typeof(wr) == "error" then
    msg = "writeAllBytes failed"
    if typeof(wr.message) == "string" then msg = wr.message end if
    print "CompileError: " + msg
    return 2
  end if

  print "OK: wrote " + output_exe + " (native x64 PE, MiniLang self-hosted compiler " + COMPILER_VERSION + ")"
  return 0
end function

function _subsystem_cli_name(subsystem)
  if subsystem == 2 then return "windows" end if
  return "console"
end function

function _link_should_use_fresh_process(obj_paths)
  if typeof(obj_paths) != "array" then return false end if
  return len(obj_paths) > 128
end function

function _link_obj_dir_in_fresh_process(input_ml, obj_dir, output_exe, subsystem, runtime_config)
  global _dump_labels_path
  global _compiler_profile_enabled
  global _compiler_profile_batches_enabled
  self_exe = _self_exe_path()
  if self_exe == "" then return -1 end if

  child_args = [
    input_ml, output_exe,
    "--link-obj-dir", obj_dir,
    "--subsystem", _subsystem_cli_name(subsystem),
    "--target", _compile_target
  ]

  compiler_gc_limit = _fresh_link_gc_limit_from_config(runtime_config)
  if typeof(compiler_gc_limit) == "int" and compiler_gc_limit > 0 then
    child_args = child_args + ["--gc-limit", "" + compiler_gc_limit]
  end if
  if typeof(_dump_labels_path) == "string" and _dump_labels_path != "" then
    child_args = child_args + ["--dump-labels", _dump_labels_path]
  end if
  if _compiler_profile_batches_enabled then
    child_args = child_args + ["--profile-compiler-batches"]
  else if _compiler_profile_enabled then
    child_args = child_args + ["--profile-compiler"]
  end if

  _progress_phase("linking in fresh compiler process")
  _progress_link("object dir=" + obj_dir)
  _progress_link("output=" + output_exe)
  _progress_link("fresh linker gc-limit=" + compiler_gc_limit)
  rc = _run_child_process(self_exe, child_args)
  if typeof(rc) != "int" then
    print "CompileError: failed to run link subprocess"
    return 2
  end if
  if rc != 0 then
    print "CompileError: link subprocess failed with exit code " + rc
    return 2
  end if
  return 0
end function

function _finish_module_mlo(tmp_dir, obj_index, module_file, entry_label, mod_cg, base_state, helper_union, module_obj_paths_b)
  if typeof(mod_cg) != "struct" or typeof(mod_cg.state) != "struct" then
    return [2, "failed to build module object", helper_union, module_obj_paths_b, 0]
  end if

  mst = mod_cg.state
  if typeof(mst.diagnostics) == "array" and len(mst.diagnostics) > 0 then
    msg = mst.diagnostics[0]
    if typeof(msg) != "string" then msg = "" + msg end if
    return [2, msg, helper_union, module_obj_paths_b, mst.label_id]
  end if

  helper_union = _merge_string_arrays(helper_union, mst.used_helpers)
  mod_obj = _mlo_from_state_delta("module", module_file, entry_label, mst, base_state)
  // Canonical fragments share one global label-id stream and therefore need
  // no per-object namespace. Keeping original names also lets pooled-constant
  // aliases target labels emitted by an earlier fragment.
  helper_union = _collect_internal_helper_targets(helper_union, mod_obj.asm_patches)
  helper_union = _collect_internal_helper_targets(helper_union, mod_obj.rdata_patches)
  helper_union = _collect_internal_helper_targets(helper_union, mod_obj.data_patches)

  mod_path = _tmp_obj_path(tmp_dir, obj_index, module_file, "module")
  wr_mod = _write_mlo_file(mod_path, mod_obj)
  if typeof(wr_mod) == "error" then
    msg2 = "writeAllBytes failed"
    if typeof(wr_mod.message) == "string" then msg2 = wr_mod.message end if
    return [2, msg2 + " (" + mod_path + ")", helper_union, module_obj_paths_b, mst.label_id]
  end if

  module_obj_paths_b = t.arr_chunk_push(module_obj_paths_b, mod_path)
  _progress_obj("wrote " + mod_path)
  label_id = mst.label_id
  mod_obj = 0
  mst = 0
  wr_mod = 0
  // The caller owns collection cadence across emitted objects.  Collecting
  // here forced a full-heap scan after every two-function compiler chunk.
  return [0, "", helper_union, module_obj_paths_b, label_id]
end function

// Compile and link one complete program in memory.
function _write_linux_image(st, asm_labels, patches, text_buf, rdata_buf, data_buf, output_exe, dynamic_imports)
  layout = elf.plan(len(text_buf), len(rdata_buf), len(data_buf), elf.dynamic_size(dynamic_imports))
  use_combined_label_map = typeof(asm_labels) == "array" and len(asm_labels) > 0
  rdlabels = d.rdata_get_labels(st.rdata)
  dtlabels = d.data_get_labels(st.data)
  bss_label_count = 0
  if typeof(st.bss) == "struct" and typeof(st.bss.labels) == "array" then bss_label_count = len(st.bss.labels) end if
  label_map = t.fastmap_new(16)
  direct_relocation_map = t.fastmap_new(16)
  if use_combined_label_map == false then
    direct_relocation_map = t.fastmap_new(((len(rdlabels) + len(dtlabels) + bss_label_count) * 2) + 64)
  end if
  if use_combined_label_map then
    label_count_hint = len(asm_labels) + len(rdlabels) + len(dtlabels) + bss_label_count
    label_map = t.fastmap_new((label_count_hint * 2) + 64)
    for i = 0 to len(asm_labels) - 1
      lb = asm_labels[i]
      if typeof(lb) == "struct" and typeof(lb.name) == "string" and typeof(lb.pos) == "int" then
        label_map = t.fastmap_set(label_map, lb.name, layout.text_off + lb.pos)
      end if
    end for
  end if
  for i = 0 to len(rdlabels) - 1
    lb2 = rdlabels[i]
    if use_combined_label_map then
      label_map = t.fastmap_set(label_map, lb2.name, layout.rdata_off + lb2.offset)
    else
      direct_relocation_map = t.fastmap_set(direct_relocation_map, lb2.name, layout.rdata_off + lb2.offset)
    end if
  end for
  for i = 0 to len(dtlabels) - 1
    lb3 = dtlabels[i]
    if use_combined_label_map then
      label_map = t.fastmap_set(label_map, lb3.name, layout.data_off + lb3.offset)
    else
      direct_relocation_map = t.fastmap_set(direct_relocation_map, lb3.name, layout.data_off + lb3.offset)
    end if
  end for
  if typeof(st.bss) == "struct" and typeof(st.bss.labels) == "array" then
    for i = 0 to len(st.bss.labels) - 1
      lb4 = st.bss.labels[i]
      if use_combined_label_map then
        label_map = t.fastmap_set(label_map, lb4.name, layout.bss_off + lb4.offset)
      else
        direct_relocation_map = t.fastmap_set(direct_relocation_map, lb4.name, layout.bss_off + lb4.offset)
      end if
    end for
  end if

  if typeof(patches) == "array" and len(patches) > 0 then
    for i = 0 to len(patches) - 1
      pt = patches[i]
      trg = -1
      if use_combined_label_map then
        trg = t.fastmap_get(label_map, pt.target, -1)
      else
        trg = t.fastmap_get(direct_relocation_map, pt.target, -1)
        if typeof(trg) != "int" or trg < 0 then
          text_target_off = t.fastmap_get(st.asm.label_pos_map, pt.target, -1)
          if typeof(text_target_off) == "int" and text_target_off >= 0 then trg = layout.text_off + text_target_off end if
        end if
      end if
      if typeof(trg) != "int" or trg < 0 then
        print "CompileError: unknown Linux patch target: " + pt.target
        return 2
      end if
      if pt.kind != "rip32" and pt.kind != "rel32" then
        print "CompileError: unknown Linux patch kind: " + pt.kind
        return 2
      end if
      b4 = t.u32(trg - (layout.text_off + pt.pos + 4))
      for bi = 0 to 3 text_buf[pt.pos + bi] = b4[bi] end for
    end for
  end if

  patch_sets = [[rdata_buf, d.rdata_get_patches(st.rdata)], [data_buf, d.data_get_patches(st.data)]]
  for psi = 0 to 1
    blob = patch_sets[psi][0]
    dpatches = patch_sets[psi][1]
    if len(dpatches) > 0 then
      for j = 0 to len(dpatches) - 1
        pt = dpatches[j]
        trg = -1
        if use_combined_label_map then
          trg = t.fastmap_get(label_map, pt.target, -1)
        else
          trg = t.fastmap_get(direct_relocation_map, pt.target, -1)
          if typeof(trg) != "int" or trg < 0 then
            text_target_off = t.fastmap_get(st.asm.label_pos_map, pt.target, -1)
            if typeof(text_target_off) == "int" and text_target_off >= 0 then trg = layout.text_off + text_target_off end if
          end if
        end if
        if typeof(trg) != "int" or trg < 0 then
          print "CompileError: unknown Linux data patch target: " + pt.target
          return 2
        end if
        if pt.kind != "abs64" then
          print "CompileError: unknown Linux data patch kind: " + pt.kind
          return 2
        end if
        b8 = t.u64(layout.base + trg)
        for bi = 0 to 7 blob[pt.offset + bi] = b8[bi] end for
      end for
    end if
    if psi == 0 then rdata_buf = blob else data_buf = blob end if
  end for

  bss_size = 0
  if typeof(st.bss) == "struct" and typeof(st.bss.size) == "int" then bss_size = st.bss.size end if
  entry_rva = -1
  if use_combined_label_map then
    entry_rva = t.fastmap_get(label_map, "_start", -1)
  else
    entry_text_off = t.fastmap_get(st.asm.label_pos_map, "_start", -1)
    if typeof(entry_text_off) == "int" and entry_text_off >= 0 then entry_rva = layout.text_off + entry_text_off end if
  end if
  entry = entry_rva - layout.text_off
  image = elf.build(text_buf, rdata_buf, data_buf, bss_size, entry, dynamic_imports)
  if typeof(image) == "error" then
    print "CompileError: failed to build ELF image: " + image.message
    return 2
  end if
  wr = fs.writeAllBytes(output_exe, image)
  if typeof(wr) == "error" then
    print "CompileError: writeAllBytes failed"
    return 2
  end if
  executable_result = _make_linux_output_executable(output_exe)
  if typeof(executable_result) == "error" then
    print "CompileError: " + executable_result.message
    return 2
  end if
  print "OK: wrote " + output_exe + " (native x64 ELF, MiniLang self-hosted compiler " + COMPILER_VERSION + ")"
  return 0
end function

// Run only object emission in a child compiler. The small coordinating parent
// then links after the emitter has exited, so two multi-gigabyte managed heaps
// are never resident at the same time.
function _emit_obj_dir_in_fresh_process(args)
  self_exe = _self_exe_path()
  if self_exe == "" then return 2 end if
  child_args = ["--object-pipeline", "--object-emit-only"]
  if typeof(args) == "array" then child_args = args + child_args end if
  _progress_phase("emitting objects in fresh compiler process")
  rc = _run_child_process(self_exe, child_args)
  if typeof(rc) != "int" or rc != 0 then
    print "CompileError: object-emission subprocess failed"
    return 2
  end if
  return 0
end function

// Compile and link one complete program in memory.
function compile_to_exe_opts_monolithic(input_ml, output_exe, include_dirs, keep_going, max_errors, runtime_config, call_profile, trace_calls, subsystem)
  global _dump_labels_path
  global _pe_state_keepalive
  global _compile_codegen_keepalive
  compiler_gc_limit = _compiler_gc_limit_from_config(runtime_config)
  gc_set_limit(compiler_gc_limit)
  _heap_probe("compile:start")
  if _mem_probe_enabled then
    runtime_config = _cfg_set(runtime_config, "cg_mem_probe", true)
  end if
  input_abs = _path_abspath(input_ml)
  if input_abs == "" then input_abs = input_ml end if
  _compiler_profile_phase("loading modules")
  load = _load_program_for_codegen(input_abs, include_dirs, keep_going, max_errors)
  // Code generation can allocate enough temporary objects to trigger an
  // automatic collection inside deeply nested emitter calls.  Keep the full
  // parsed program reachable independently of compiler-stack liveness until
  // emit_program returns; otherwise very large function bodies can leave a
  // stale AST pointer that fails in the native typeof helper.
  _compile_codegen_keepalive = load
  _heap_probe("compile:load_program_done")
  if len(load.diagnostics) > 0 then
    for i = 0 to len(load.diagnostics) - 1
      _print_diag(load.diagnostics[i])
    end for
    if len(load.diagnostics) >= max_errors then
      print "Note: stopped after " + len(load.diagnostics) + " diagnostics (max-errors)."
    end if
    return 2
  end if

  prepared_program = ml.prepare_language_features(load.program)
  if typeof(prepared_program) == "error" then
    print "CompileError: " + prepared_program.message
    return 2
  end if
  load.program = prepared_program
  _compile_codegen_keepalive = load

  _compiler_profile_phase("collecting extern declarations")
  extern_sigs = collect_extern_sigs(load.program)
  _heap_probe("compile:extern_sigs_done")
  extern_struct_names = collect_extern_structs(load.program)
  if typeof(extern_struct_names) == "error" then
    print "CompileError: " + extern_struct_names.message
    return 2
  end if
  extern_validation = validate_extern_sigs(extern_sigs, extern_struct_names)
  if extern_validation != "" then
    print "CompileError: " + extern_validation
    return 2
  end if
  _compiler_profile_phase("initializing code generator")
  cg = codegen.newCodegenForTarget(load.source, input_abs, load.aliases, extern_sigs, extern_struct_names, _compile_target, runtime_config)
  cg = codegen.set_target(cg, _compile_target)
  if typeof(cg) == "struct" and typeof(cg.state) == "struct" then
    cg.state.dbg_line_starts = load.sources
    cg.state.call_profile = call_profile
    cg.state.trace_calls = trace_calls
    cg.state.is_windows_subsystem = (subsystem == 2)
  end if
  // The monolithic/default path needs the same synthetic callStat metadata as
  // the object pipeline before member access is planned.
  cg = codegen.enable_call_profile_metadata(cg)
  if _compile_target == "linux-x64" then cg.state = linuxrt.emit_startup(cg.state) end if
  _compile_codegen_keepalive = [load, cg]
  _compiler_profile_phase("emitting program")
  cg = codegen.emit_program(cg, load.program)
  if _compile_target == "linux-x64" then cg.state = linuxrt.emit_runtime(cg.state) end if
  _heap_probe("compile:codegen_done")
  st = cg.state
  linux_dynamic_imports = []
  if _compile_target == "linux-x64" then
    prepared_imports = linuxrt.prepare_dynamic_imports(st)
    st = prepared_imports.state
    linux_dynamic_imports = prepared_imports.imports
    cg.state = st
  end if
  _compile_codegen_keepalive = st
  _pe_state_keepalive = st
  load.program = []
  load.source = ""
  load.aliases = []
  load.sources = []
  load.diagnostics = []
  if _mem_probe_enabled then
    gc_collect()
    st = _pe_state_keepalive
  end if
  _heap_probe("compile:post_load_release")
  if typeof(st) != "struct" then
    print "CompileError: codegen returned invalid state"
    return 2
  end if
  if typeof(st.diagnostics) == "array" and len(st.diagnostics) > 0 then
    for di = 0 to len(st.diagnostics) - 1
      msg = st.diagnostics[di]
      if typeof(msg) != "string" then msg = "" + msg end if
      print "CompileError: " + msg
    end for
    return 2
  end if
  asm_labels = []
  asm_label_count = 0
  use_direct_section_lookup = false
  patches = []
  if typeof(st.asm) == "struct" then
    if typeof(st.asm.label_pos_map) == "struct" then asm_label_count = t.fastmap_size(st.asm.label_pos_map) end if
    // Small programs are fastest with one combined relocation map. Above this
    // point, materializing that map costs more than probing the section maps.
    use_direct_section_lookup = asm_label_count > DIRECT_SECTION_LABEL_THRESHOLD
    if use_direct_section_lookup == false or (typeof(_dump_labels_path) == "string" and _dump_labels_path != "") or _mem_probe_enabled then
      asm_labels = a.get_labels(st.asm)
    end if
    patches = a.get_patches(st.asm)
    if _compiler_profile_enabled then
      print "[profile] text_labels=" + asm_label_count + " deferred_patches=" + len(patches) + " direct_section_lookup=" + use_direct_section_lookup
    end if
    st.asm.labels = []
    st.asm.labels_chunks = []
    st.asm.labels_tail = []
    st.asm.patches_chunks = []
    st.asm.patches_tail = []
    st.asm.deferred_patches_chunks = []
    st.asm.deferred_patches_tail = []
    st.asm.calls_chunks = []
    st.asm.calls_tail = []
    st.asm.before_call_live_temps = []
    st.asm.peephole_last_jump = []
  end if
  _compiler_profile_phase("compacting codegen state")
  st = _compact_codegen_state_for_pe(st)
  _pe_state_keepalive = st
  st = _pe_state_keepalive
  load = 0
  cg = 0
  extern_sigs = 0
  extern_struct_names = 0
  _release_frontend_phase_arenas()
  gc_collect()
  st = _pe_state_keepalive
  _heap_probe("compile:frontend_arenas_released")
  if typeof(st.asm) == "struct" then
    st.asm = a.materialize(st.asm)
  end if
  if typeof(st.asm) != "struct" or typeof(st.asm.buf) != "bytes" or len(st.asm.buf) <= 0 then
    print "CompileError: native backend emitted empty .text section (compiler port incomplete for this input)."
    return 2
  end if

  text_buf = st.asm.buf
  if typeof(st.asm.size) == "int" and st.asm.size >= 0 and st.asm.size <= len(text_buf) then
    text_buf = slice(text_buf, 0, st.asm.size)
  end if
  if typeof(text_buf) != "bytes" or len(text_buf) <= 0 then
    print "CompileError: native backend emitted empty code buffer."
    return 2
  end if

  rdata_buf = st.rdata.data
  if typeof(st.rdata.used) == "int" and st.rdata.used >= 0 and st.rdata.used <= len(rdata_buf) then
    rdata_buf = slice(rdata_buf, 0, st.rdata.used)
  end if

  data_buf = st.data.data
  if typeof(st.data.used) == "int" and st.data.used >= 0 and st.data.used <= len(data_buf) then
    data_buf = slice(data_buf, 0, st.data.used)
  end if

  // Replace oversized backing buffers with compact slices before PE assembly.
  if typeof(st.asm) == "struct" then
    st.asm.buf = text_buf
    st.asm.size = len(text_buf)
    if typeof(st.asm.chunk_pages) == "array" then st.asm.chunk_pages = [] end if
    if typeof(st.asm.chunk_tail) == "array" or typeof(st.asm.chunk_tail) == "struct" then st.asm.chunk_tail = [] end if
    // Keep labels/patches until relocation patching is done below.
    if typeof(st.asm.calls_chunks) == "array" then st.asm.calls_chunks = [] end if
    if typeof(st.asm.calls_tail) == "array" or typeof(st.asm.calls_tail) == "struct" then st.asm.calls_tail = [] end if
    st.asm.buf_valid = true
  end if
  if typeof(st.rdata) == "struct" then
    st.rdata.data = rdata_buf
    st.rdata.used = len(rdata_buf)
  end if
  if typeof(st.data) == "struct" then
    st.data.data = data_buf
    st.data.used = len(data_buf)
  end if
  if _mem_probe_enabled then
    gc_collect()
  end if
  _heap_probe("compile:buffers_compacted")

  if _compile_target == "linux-x64" then
    return _write_linux_image(st, asm_labels, patches, text_buf, rdata_buf, data_buf, output_exe, linux_dynamic_imports)
  end if

  _compiler_profile_phase("building PE layout")
  p = pe.newPEBuilder()
  p.subsystem = subsystem
  p = pe.add_section(p, ".text", text_buf, 0x60000020)
  p = pe.add_section(p, ".rdata", rdata_buf, 0x40000040)
  p = pe.add_section(p, ".data", data_buf, 0xC0000040)
  p = pe.add_section(p, ".bss", bytes(0), 0xC0000080)
  p = pe.add_section(p, ".idata", bytes(0), 0xC0000040)

  if len(p.sections) > 3 then
    bs = p.sections[3]
    if typeof(st.bss) == "struct" and typeof(st.bss.size) == "int" then
      bs.virt_size = st.bss.size
    else
      bs.virt_size = 0
    end if
    p.sections[3] = bs
  end if

  p = pe.layout(p)

  imports = _imports_to_pe_imports(st.imports)
  st.imports = []
  if len(p.sections) <= 4 then
    print "CompileError: internal section layout error (.idata missing)"
    return 2
  end if

  idsec = p.sections[4]
  idr = pe.build_idata(imports, idsec.virt_addr)
  idsec.data = idr.data
  p.sections[4] = idsec
  p.import_rva = idr.import_dir_rva
  p.import_size = idr.idata_total_size

  p = pe.layout(p)
  _heap_probe("compile:pe_ready")

  text_rva = p.sections[0].virt_addr
  rdata_rva = p.sections[1].virt_addr
  data_rva = p.sections[2].virt_addr
  bss_rva = p.sections[3].virt_addr
  p.entry_rva = text_rva

  _compiler_profile_phase("resolving labels and patches")
  rdata_label_list = []
  if typeof(st.rdata) == "struct" then rdata_label_list = d.rdata_get_labels(st.rdata) end if
  data_label_list = []
  if typeof(st.data) == "struct" then data_label_list = d.data_get_labels(st.data) end if
  bss_label_count = 0
  if typeof(st.bss) == "struct" and typeof(st.bss.labels) == "array" then bss_label_count = len(st.bss.labels) end if
  iat_label_count = 0
  if typeof(idr.iat_symbols) == "array" then iat_label_count = len(idr.iat_symbols) * 2 end if
  label_count_hint = asm_label_count + len(rdata_label_list) + len(data_label_list) + bss_label_count + iat_label_count
  collect_label_list = typeof(_dump_labels_path) == "string" and _dump_labels_path != ""
  build_combined_label_map = use_direct_section_lookup == false or collect_label_list
  label_map = t.fastmap_new(16)
  if build_combined_label_map then label_map = t.fastmap_new((label_count_hint * 2) + 64) end if
  direct_relocation_map = t.fastmap_new(16)
  if use_direct_section_lookup then
    non_text_label_count = len(rdata_label_list) + len(data_label_list) + bss_label_count + iat_label_count
    direct_relocation_map = t.fastmap_new((non_text_label_count * 2) + 64)
  end if
  labels_chunks = []
  labels_tail = []
  if (build_combined_label_map or _mem_probe_enabled) and typeof(asm_labels) == "array" and len(asm_labels) > 0 then
    for i = 0 to len(asm_labels) - 1
      lb = asm_labels[i]
      if typeof(lb) == "struct" and typeof(lb.name) == "string" and typeof(lb.pos) == "int" then
        if _mem_probe_enabled then
          print "[dbg][label] " + lb.name + " " + lb.pos
        end if
        label_value = text_rva + lb.pos
        if build_combined_label_map then
          label_map = t.fastmap_set(label_map, lb.name, label_value)
        end if
        if collect_label_list then
          app_lb = t.arr_chunked_push(labels_chunks, labels_tail, StrIntPair(lb.name, label_value), 1024)
          labels_chunks = app_lb[0]
          labels_tail = app_lb[1]
        end if
      end if
    end for
  end if
  if typeof(rdata_label_list) == "array" and len(rdata_label_list) > 0 then
    for i = 0 to len(rdata_label_list) - 1
      lb2 = rdata_label_list[i]
      if typeof(lb2) == "struct" and typeof(lb2.name) == "string" and typeof(lb2.offset) == "int" then
        label_value2 = rdata_rva + lb2.offset
        if build_combined_label_map then
          label_map = t.fastmap_set(label_map, lb2.name, label_value2)
        else
          direct_relocation_map = t.fastmap_set(direct_relocation_map, lb2.name, label_value2)
        end if
        if collect_label_list then
          app_lb2 = t.arr_chunked_push(labels_chunks, labels_tail, StrIntPair(lb2.name, label_value2), 1024)
          labels_chunks = app_lb2[0]
          labels_tail = app_lb2[1]
        end if
      end if
    end for
  end if
  if typeof(data_label_list) == "array" and len(data_label_list) > 0 then
    for i = 0 to len(data_label_list) - 1
      lb3 = data_label_list[i]
      if typeof(lb3) == "struct" and typeof(lb3.name) == "string" and typeof(lb3.offset) == "int" then
        label_value3 = data_rva + lb3.offset
        if build_combined_label_map then
          label_map = t.fastmap_set(label_map, lb3.name, label_value3)
        else
          direct_relocation_map = t.fastmap_set(direct_relocation_map, lb3.name, label_value3)
        end if
        if collect_label_list then
          app_lb3 = t.arr_chunked_push(labels_chunks, labels_tail, StrIntPair(lb3.name, label_value3), 1024)
          labels_chunks = app_lb3[0]
          labels_tail = app_lb3[1]
        end if
      end if
    end for
  end if
  if typeof(st.bss) == "struct" and typeof(st.bss.labels) == "array" and len(st.bss.labels) > 0 then
    for i = 0 to len(st.bss.labels) - 1
      lb4 = st.bss.labels[i]
      if typeof(lb4) == "struct" and typeof(lb4.name) == "string" and typeof(lb4.offset) == "int" then
        label_value4 = bss_rva + lb4.offset
        if build_combined_label_map then
          label_map = t.fastmap_set(label_map, lb4.name, label_value4)
        else
          direct_relocation_map = t.fastmap_set(direct_relocation_map, lb4.name, label_value4)
        end if
        if collect_label_list then
          app_lb4 = t.arr_chunked_push(labels_chunks, labels_tail, StrIntPair(lb4.name, label_value4), 1024)
          labels_chunks = app_lb4[0]
          labels_tail = app_lb4[1]
        end if
      end if
    end for
  end if
  if typeof(idr.iat_symbols) == "array" and len(idr.iat_symbols) > 0 then
    for i = 0 to len(idr.iat_symbols) - 1
      it = idr.iat_symbols[i]
      if typeof(it) != "struct" then continue end if
      if typeof(it.func) != "string" or typeof(it.rva) != "int" then continue end if
      iat_name = "iat_" + it.func
      section_iat_hit = -1
      if build_combined_label_map then
        section_iat_hit = t.fastmap_get(label_map, iat_name, -1)
      else
        section_iat_hit = t.fastmap_get(direct_relocation_map, iat_name, -1)
        if typeof(section_iat_hit) != "int" or section_iat_hit < 0 then
          text_iat_off = t.fastmap_get(st.asm.label_pos_map, iat_name, -1)
          if typeof(text_iat_off) == "int" and text_iat_off >= 0 then section_iat_hit = text_rva + text_iat_off end if
        end if
      end if
      if section_iat_hit < 0 then
        if build_combined_label_map then
          label_map = t.fastmap_set(label_map, iat_name, it.rva)
        else
          direct_relocation_map = t.fastmap_set(direct_relocation_map, iat_name, it.rva)
        end if
        if collect_label_list then
          app_lb5 = t.arr_chunked_push(labels_chunks, labels_tail, StrIntPair(iat_name, it.rva), 1024)
          labels_chunks = app_lb5[0]
          labels_tail = app_lb5[1]
        end if
      end if
      if typeof(it.dll) == "string" then
        iat_dll_name = "iat_" + _dll_base(it.dll) + "_" + it.func
        if build_combined_label_map then
          label_map = t.fastmap_set(label_map, iat_dll_name, it.rva)
        else
          direct_relocation_map = t.fastmap_set(direct_relocation_map, iat_dll_name, it.rva)
        end if
        if collect_label_list then
          app_lb6 = t.arr_chunked_push(labels_chunks, labels_tail, StrIntPair(iat_dll_name, it.rva), 1024)
          labels_chunks = app_lb6[0]
          labels_tail = app_lb6[1]
        end if
      end if
    end for
  end if
  imports = []
  labels = []
  if collect_label_list then labels = t.arr_chunked_finish(labels_chunks, labels_tail) end if

  if typeof(_dump_labels_path) == "string" and _dump_labels_path != "" then
    dump_builder = sb.StringBuilder.withCapacity(1048576)
    dump_builder.appendLine("[section] .text raw=" + len(text_buf))
    dump_builder.appendLine("[section] .rdata raw=" + len(rdata_buf))
    dump_builder.appendLine("[section] .data raw=" + len(data_buf))
    if typeof(st.emitted_helpers) == "array" and len(st.emitted_helpers) > 0 then
      for hi = 0 to len(st.emitted_helpers) - 1
        h = st.emitted_helpers[hi]
        if typeof(h) == "string" then
          dump_builder.appendLine("[helper] " + hi + " " + h)
        end if
      end for
    end if
    if typeof(labels) == "array" and len(labels) > 0 then
      for li = 0 to len(labels) - 1
        lbi = labels[li]
        if typeof(lbi) == "struct" and typeof(lbi.key) == "string" and typeof(lbi.value) == "int" then
          dump_builder.appendLine("[label] " + lbi.key + " " + lbi.value)
        end if
      end for
    end if
    wrdump = fs.writeAllText(_dump_labels_path, dump_builder.toString())
    if typeof(wrdump) == "error" then
      print "CompileError: writeAllText failed for label dump: " + _dump_labels_path
      return 2
    end if
  end if

  buf = text_buf
  if typeof(patches) == "array" and len(patches) > 0 then
    for i = 0 to len(patches) - 1
      pt = patches[i]
      if typeof(pt) != "struct" then continue end if
      if typeof(pt.target) != "string" or typeof(pt.pos) != "int" then continue end if

      trg = -1
      if build_combined_label_map then
        trg = t.fastmap_get(label_map, pt.target, -1)
      else
        trg = t.fastmap_get(direct_relocation_map, pt.target, -1)
        if typeof(trg) != "int" or trg < 0 then
          text_target_off = t.fastmap_get(st.asm.label_pos_map, pt.target, -1)
          if typeof(text_target_off) == "int" and text_target_off >= 0 then trg = text_rva + text_target_off end if
        end if
      end if
      if trg < 0 then
        print "CompileError: unknown patch target: " + pt.target
        return 2
      end if
      if pt.pos < 0 or pt.pos + 3 >= len(buf) then
        print "CompileError: invalid patch position for: " + pt.target
        return 2
      end if

      if pt.kind != "rip32" and pt.kind != "rel32" then
        print "CompileError: unknown patch kind: " + pt.kind
        return 2
      end if

      src_next = text_rva + pt.pos + 4
      disp = trg - src_next
      b4 = t.u32(disp)
      buf[pt.pos] = b4[0]
      buf[pt.pos + 1] = b4[1]
      buf[pt.pos + 2] = b4[2]
      buf[pt.pos + 3] = b4[3]
    end for
  end if

  patch_sets = [[rdata_buf, d.rdata_get_patches(st.rdata)], [data_buf, d.data_get_patches(st.data)]]
  for psi = 0 to len(patch_sets) - 1
    pack = patch_sets[psi]
    if typeof(pack) != "array" or len(pack) < 2 then continue end if
    blob = pack[0]
    dpatches = pack[1]
    if typeof(blob) != "bytes" then continue end if
    if typeof(dpatches) != "array" or len(dpatches) <= 0 then
      if psi == 0 then
        rdata_buf = blob
      else
        data_buf = blob
      end if
      continue
    end if

    for j = 0 to len(dpatches) - 1
      pt2 = dpatches[j]
      if typeof(pt2) != "struct" then continue end if
      if typeof(pt2.target) != "string" or typeof(pt2.offset) != "int" then continue end if

      trg2 = -1
      if build_combined_label_map then
        trg2 = t.fastmap_get(label_map, pt2.target, -1)
      else
        trg2 = t.fastmap_get(direct_relocation_map, pt2.target, -1)
        if typeof(trg2) != "int" or trg2 < 0 then
          text_target_off2 = t.fastmap_get(st.asm.label_pos_map, pt2.target, -1)
          if typeof(text_target_off2) == "int" and text_target_off2 >= 0 then trg2 = text_rva + text_target_off2 end if
        end if
      end if
      if trg2 < 0 then
        print "CompileError: unknown data patch target: " + pt2.target
        return 2
      end if
      if pt2.kind != "abs64" then
        print "CompileError: unknown data patch kind: " + pt2.kind
        return 2
      end if
      if pt2.offset < 0 or pt2.offset + 7 >= len(blob) then
        print "CompileError: invalid data patch position for: " + pt2.target
        return 2
      end if

      target_va = p.image_base + trg2
      b8 = t.u64(target_va)
      for bi = 0 to 7
        blob[pt2.offset + bi] = b8[bi]
      end for
    end for

    if psi == 0 then
      rdata_buf = blob
    else
      data_buf = blob
    end if
  end for

  if typeof(st.asm) == "struct" then
    st.asm.buf = buf
  end if
  if typeof(st.rdata) == "struct" then
    st.rdata.data = rdata_buf
  end if
  if typeof(st.data) == "struct" then
    st.data.data = data_buf
  end if
  asm_labels = []
  patches = []
  labels = []
  label_map = t.fastmap_new(16)
  direct_relocation_map = t.fastmap_new(16)
  if typeof(st.rdata) == "struct" then
    st.rdata = d.rdata_clear_labels(st.rdata)
    st.rdata = d.rdata_clear_patches(st.rdata)
  end if
  if typeof(st.data) == "struct" then
    st.data = d.data_clear_labels(st.data)
    st.data = d.data_clear_patches(st.data)
  end if
  if typeof(st.bss) == "struct" then
    st.bss.labels = []
  end if
  if typeof(idr) == "struct" then
    idr.iat_symbols = []
  end if

  tx = p.sections[0]
  tx.data = st.asm.buf
  p.sections[0] = tx
  rd = p.sections[1]
  rd.data = st.rdata.data
  p.sections[1] = rd
  dt = p.sections[2]
  dt.data = st.data.data
  p.sections[2] = dt

  _compiler_profile_phase("building and writing executable")
  exe = pe.build(p)
  _heap_probe("compile:pe_built")
  listing_result = _write_asm_listing_if_enabled(output_exe, p, st.asm.buf, st.rdata.data, st.data.data, idsec.data)
  if typeof(listing_result) == "error" then
    print "CompileError: failed to write assembly listing"
    return 2
  end if
  wr = fs.writeAllBytes(output_exe, exe)
  if typeof(wr) == "error" then
    msg = "writeAllBytes failed"
    if typeof(wr.message) == "string" then msg = wr.message end if
    print "CompileError: " + msg
    return 2
  end if

  _pe_state_keepalive = 0
  _compile_codegen_keepalive = 0

  print "OK: wrote " + output_exe + " (native x64 PE, MiniLang self-hosted compiler " + COMPILER_VERSION + ")"
  return 0
end function

function _hex_u32_fixed(value)
  digits = "0123456789ABCDEF"
  v = value & 0xFFFFFFFF
  out_text = ""
  shift = 28
  while shift >= 0
    out_text = out_text + digits[(v >> shift) & 15]
    shift = shift - 4
  end while
  return out_text
end function

function _asm_default_path(output_exe)
  if _endsWith(output_exe, ".exe") then
    return s.substr(output_exe, 0, len(output_exe) - 4) + ".asm"
  end if
  return output_exe + ".asm"
end function

function _asm_db_text(hex_text)
  out_text = "db "
  i = 0
  first = true
  while i + 1 < len(hex_text)
    if first == false then out_text = out_text + "," end if
    out_text = out_text + "0x" + hex_text[i] + hex_text[i + 1]
    first = false
    i = i + 2
  end while
  return out_text
end function

function _asm_append_section(bld, name, buf, rva)
  bld.appendLine("; section " + name + " RVA=0x" + _hex_u32_fixed(rva) + " size=" + len(buf))
  off = 0
  while off < len(buf)
    take = 16
    if off + take > len(buf) then take = len(buf) - off end if
    hx = hex(slice(buf, off, take))
    line = ""
    if _asm_show_addr then line = line + _hex_u32_fixed(rva + off) end if
    if _asm_show_bytes then
      if line != "" then line = line + "  " end if
      line = line + hx
    end if
    if _asm_show_code then
      if line != "" then line = line + "  " end if
      line = line + _asm_db_text(hx)
    end if
    bld.appendLine(line)
    off = off + take
  end while
  bld.appendLine("")
end function

function _write_asm_listing_if_enabled(output_exe, peb, text_buf, rdata_buf, data_buf, idata_buf)
  if _asm_listing_enabled == false then return true end if
  out_path = _asm_listing_path
  if out_path == "" then out_path = _asm_default_path(output_exe) end if
  bld = sb.StringBuilder.withCapacity(len(text_buf) * 4 + 4096)
  bld.appendLine("; MiniLang native x64 PE listing")
  if _asm_dump_pe then
    bld.appendLine("; image-base=0x" + _hex_u32_fixed(peb.image_base))
    bld.appendLine("; entry-rva=0x" + _hex_u32_fixed(peb.entry_rva))
    bld.appendLine("; sections=" + len(peb.sections))
    bld.appendLine("")
  end if
  _asm_append_section(bld, ".text", text_buf, peb.sections[0].virt_addr)
  if _asm_dump_data then
    _asm_append_section(bld, ".rdata", rdata_buf, peb.sections[1].virt_addr)
    _asm_append_section(bld, ".data", data_buf, peb.sections[2].virt_addr)
    _asm_append_section(bld, ".idata", idata_buf, peb.sections[4].virt_addr)
  end if
  wr = fs.writeAllText(out_path, bld.toString())
  if typeof(wr) == "error" then return wr end if
  print "OK: wrote " + out_path
  return true
end function

// Emit bounded .mlo batches and link them in a fresh compiler process.
function compile_to_exe_opts_object(input_ml, output_exe, include_dirs, keep_going, max_errors, runtime_config, call_profile, trace_calls, subsystem)
  global _dump_labels_path
  global _compile_codegen_keepalive
  global _object_emit_only
  runtime_config = _cfg_set(runtime_config, "cg_object_pipeline", true)
  compiler_gc_limit = _compiler_gc_limit_from_config(runtime_config)
  gc_set_limit(compiler_gc_limit)
  _heap_probe("compile:start")
  _progress_phase("compile")
  _progress_obj("input=" + input_ml)
  _progress_obj("output=" + output_exe)
  if _mem_probe_enabled then
    runtime_config = _cfg_set(runtime_config, "cg_mem_probe", true)
  end if
  input_abs = _path_abspath(input_ml)
  if input_abs == "" then input_abs = input_ml end if
  _progress_phase("loading modules")
  load = _load_program_for_codegen(input_abs, include_dirs, keep_going, max_errors)
  _compile_codegen_keepalive = load
  _heap_probe("compile:load_program_done")
  if len(load.diagnostics) > 0 then
    for i = 0 to len(load.diagnostics) - 1
      _print_diag(load.diagnostics[i])
    end for
    if len(load.diagnostics) >= max_errors then
      print "Note: stopped after " + len(load.diagnostics) + " diagnostics (max-errors)."
    end if
    return 2
  end if


  prepared_program = ml.prepare_language_features(load.program)
  if typeof(prepared_program) == "error" then
    print "CompileError: " + prepared_program.message
    return 2
  end if
  load.program = prepared_program
  _compile_codegen_keepalive = load

  _progress_phase("collecting extern declarations")
  extern_sigs = collect_extern_sigs(load.program)
  _heap_probe("compile:extern_sigs_done")
  extern_struct_names = collect_extern_structs(load.program)
  if typeof(extern_struct_names) == "error" then
    print "CompileError: " + extern_struct_names.message
    return 2
  end if
  extern_validation = validate_extern_sigs(extern_sigs, extern_struct_names)
  if extern_validation != "" then
    print "CompileError: " + extern_validation
    return 2
  end if
  _progress_phase("initializing code generator")
  _heap_probe("compile:before_new_codegen")
  cg = codegen.newCodegenForTarget(load.source, input_abs, load.aliases, extern_sigs, extern_struct_names, _compile_target, runtime_config)
  cg = codegen.set_target(cg, _compile_target)
  _heap_probe("compile:new_codegen_done")
  if typeof(cg) != "struct" or typeof(cg.state) != "struct" then
    print "CompileError: failed to initialize code generator"
    return 2
  end if

  cg.state.dbg_line_starts = load.sources
  cg.state.call_profile = call_profile
  cg.state.trace_calls = trace_calls
  cg.state.is_windows_subsystem = (subsystem == 2)
  _heap_probe("compile:before_call_profile_metadata")
  cg = codegen.enable_call_profile_metadata(cg)
  // Linux startup reserves data as well as emitting _start. Do this before
  // object planning so section allocation order matches monolithic codegen.
  if _compile_target == "linux-x64" then cg.state = linuxrt.emit_startup(cg.state) end if
  _compile_codegen_keepalive = [load, cg]
  _heap_probe("compile:call_profile_metadata_done")

  _progress_phase("planning object pipeline")
  _heap_probe("compile:before_prepare_program")
  prep = codegen.prepare_program_for_objects(cg, load.program)
  if typeof(prep) != "array" or len(prep) < 3 then
    print "CompileError: failed to prepare object-code pipeline"
    return 2
  end if
  cg = prep[0]
  _compile_codegen_keepalive = [load, cg]
  module_init_recs = prep[1]
  max_call_args_main = prep[2]
  _heap_probe("compile:plan_done")

  st = cg.state
  if typeof(st) != "struct" then
    print "CompileError: invalid codegen state after planning"
    return 2
  end if
  if typeof(st.diagnostics) == "array" and len(st.diagnostics) > 0 then
    for di = 0 to len(st.diagnostics) - 1
      msg = st.diagnostics[di]
      if typeof(msg) != "string" then msg = "" + msg end if
      print "CompileError: " + msg
    end for
    return 2
  end if

  tmp_dir = _tmp_obj_dir(output_exe)
  if _ensure_dir_recursive(tmp_dir) == false then
    print "CompileError: failed to create object tmp dir: " + tmp_dir
    return 2
  end if
  if _clear_tmp_obj_dir(tmp_dir) == false then
    print "CompileError: failed to clean object tmp dir: " + tmp_dir
    return 2
  end if
  _progress_obj("object dir=" + tmp_dir)

  main_name = _find_main_name(st)
  helper_union = []
  if typeof(st.used_helpers) == "array" then helper_union = st.used_helpers end if
  module_obj_paths_b = t.arr_chunk_new(128)
  entry_path = _tmp_obj_path(tmp_dir, "000", input_abs, "entry")
  module_object_seq = 1

  // Keep the merged AST rooted while canonical fragments are emitted.  The
  // large assembler graph is still bounded to one entry/function chunk/tail.
  _heap_probe("compile:post_plan_gc")

  _progress_phase("emitting canonical entry object")
  cg = codegen.emit_entry_object(cg, module_init_recs, max_call_args_main, main_name)
  st = cg.state
  if typeof(st) != "struct" then
    print "CompileError: invalid entry codegen state"
    return 2
  end if
  if typeof(st.diagnostics) == "array" and len(st.diagnostics) > 0 then
    for di = 0 to len(st.diagnostics) - 1
      msg = st.diagnostics[di]
      if typeof(msg) != "string" then msg = "" + msg end if
      print "CompileError: " + msg
    end for
    return 2
  end if

  helper_union = _merge_string_arrays(helper_union, st.used_helpers)
  object_entry_label = "__ml_entry"
  if _compile_target == "linux-x64" then object_entry_label = "_start" end if
  entry_obj = _mlo_from_state("entry", input_abs, object_entry_label, st)
  helper_union = _collect_internal_helper_targets(helper_union, entry_obj.asm_patches)
  helper_union = _collect_internal_helper_targets(helper_union, entry_obj.rdata_patches)
  helper_union = _collect_internal_helper_targets(helper_union, entry_obj.data_patches)
  // Function objects use local assembler buffers. Carry the canonical text
  // offset so their leading alignment padding matches monolithic emission.
  text_stream_offset = len(entry_obj.text)
  wr_entry = _write_mlo_file(entry_path, entry_obj)
  if typeof(wr_entry) == "error" then
    msg = "writeAllBytes failed"
    if typeof(wr_entry.message) == "string" then msg = wr_entry.message end if
    print "CompileError: " + msg + " (" + entry_path + ")"
    return 2
  end if
  _progress_obj("wrote " + entry_path)

  fn_entries = codegen.all_function_entries(cg)
  fn_entry_count = codegen.function_entry_count(fn_entries)
  fn_analysis_scratch = codegen.new_function_analysis_scratch()
  // Keep the reusable analysis buffers live across the explicit collections in
  // the object loop without adding compiler-only fields to generated CgState.
  _compile_codegen_keepalive = [load, cg, fn_analysis_scratch]
  _progress_phase("emitting canonical function objects")
  fn_batch_count = 0
  fn_setup_ms = 0
  fn_codegen_ms = 0
  fn_serialize_ms = 0
  fn_start = 0
  fn_gc_stride = OBJECT_EMISSION_GC_STRIDE
  if fn_entry_count > OBJECT_LARGE_EMISSION_FUNCTION_THRESHOLD then fn_gc_stride = OBJECT_LARGE_EMISSION_GC_STRIDE end if
  // Materialize the prepared semantic state once, then reuse it for every
  // serial text fragment. Re-cloning the global scope/maps for each batch
  // creates large short-lived graphs and advances the non-moving compiler
  // heap even though only the assembler buffer is fragment-local.
  mod_cg = 0
  while fn_start < fn_entry_count
    // Small text fragments keep assembler growth linear. Compiler functions
    // are larger still and therefore retain the narrower historical batch.
    fn_chunk_size = OBJECT_FUNCTION_BATCH_SIZE
    first_name = ""
    first_name = codegen.function_entry_name(fn_entries, fn_start)
    if _startsWith(first_name, "mlc.codegen.codegen_builtins_alloc.") or _startsWith(first_name, "mlc.codegen.codegen_expr.") or _startsWith(first_name, "mlc.codegen.codegen_stmt.") or _startsWith(first_name, "mlc.compiler.") then
      fn_chunk_size = OBJECT_COMPILER_BATCH_SIZE
    end if
    fn_step_started = 0
    fn_step_finished = 0
    fn_batch_started = 0
    fn_batch_setup_ms = 0
    fn_batch_codegen_ms = 0
    fn_batch_serialize_ms = 0
    if _compiler_profile_enabled then
      fn_step_started = mtime.ticks()
      fn_batch_started = fn_step_started
    end if
    section_checkpoint = _mlo_state_checkpoint(cg.state)
    if typeof(mod_cg) != "struct" or typeof(mod_cg.state) != "struct" then
      mod_cg = codegen.clone_for_object(cg, false)
    else
      mod_cg = codegen.start_object_fragment(mod_cg)
      // These fields are local to one serialized fragment. Stream-wide label,
      // inline and call accounting deliberately remain on the reused state.
      mod_cg.state.used_helpers = []
      mod_cg.state.emitted_helpers = []
      mod_cg.state.diagnostics = []
      mod_cg.state.break_stack = []
      mod_cg.state._cold_block_stack = []
      mod_cg.state._inline_call_stack = []
      // Historical clones restarted lexical binding ids from the canonical
      // prepared state for every batch; preserve that deterministic behavior.
      mod_cg.state.binding_id = cg.state.binding_id
    end if
    if typeof(mod_cg) != "struct" or typeof(mod_cg.state) != "struct" then
      print "CompileError: failed to clone function codegen state"
      return 2
    end if
    mod_cg.state.label_id = cg.state.label_id
    // Section builders are append-only across the canonical stream. Share
    // them directly so a batch does not copy every prior byte, label and pool
    // entry merely to append its own delta.
    mod_cg.state.rdata = cg.state.rdata
    mod_cg.state.data = cg.state.data
    mod_cg.state.bss = cg.state.bss
    mod_cg.state.heap_config = _cfg_set(mod_cg.state.heap_config, "cg_object_text_base", text_stream_offset)
    if _compiler_profile_enabled then
      fn_step_finished = mtime.ticks()
      fn_batch_setup_ms = fn_step_finished - fn_step_started
      fn_setup_ms = fn_setup_ms + fn_batch_setup_ms
      fn_step_started = fn_step_finished
    end if
    mod_cg = codegen.emit_module_function_entries(mod_cg, fn_entries, fn_start, fn_chunk_size, fn_analysis_scratch)
    fragment_text_size = a.pos(mod_cg.state.asm)
    if _compiler_profile_enabled then
      fn_step_finished = mtime.ticks()
      fn_batch_codegen_ms = fn_step_finished - fn_step_started
      fn_codegen_ms = fn_codegen_ms + fn_batch_codegen_ms
      fn_step_started = fn_step_finished
    end if
    fin = _finish_module_mlo(tmp_dir, "" + module_object_seq, first_name, "", mod_cg, section_checkpoint, helper_union, module_obj_paths_b)
    if _compiler_profile_enabled then
      fn_step_finished = mtime.ticks()
      fn_batch_serialize_ms = fn_step_finished - fn_step_started
      fn_serialize_ms = fn_serialize_ms + fn_batch_serialize_ms
    end if
    if fin[0] != 0 then
      print "CompileError: " + fin[1]
      return fin[0]
    end if
    helper_union = fin[2]
    module_obj_paths_b = fin[3]
    cg.state.label_id = fin[4]
    // Carry stream-wide optimization accounting into the next fragment. The
    // monolithic backend applies one cumulative inline budget and call count;
    // resetting either at an .mlo boundary changes generated instructions.
    cg.state._inline_emitted_bytes = mod_cg.state._inline_emitted_bytes
    cg.state.call_total_count = mod_cg.state.call_total_count
    cg.state.call_indirect_count = mod_cg.state.call_indirect_count
    cg.state.inline_only_functions = mod_cg.state.inline_only_functions
    cg.state.pruned_inline_functions = mod_cg.state.pruned_inline_functions
    // Preserve canonical section bytes and the shared constant pools while
    // dropping analysis state that is local to the completed function batch.
    cg.state.rdata = mod_cg.state.rdata
    cg.state.data = mod_cg.state.data
    cg.state.bss = mod_cg.state.bss
    // The serialized fragment no longer needs non-inline function bodies or
    // references retained by its temporary analysis arena. Release both at the
    // batch ownership boundary so later collections see only live compiler IR.
    cg = codegen.release_emitted_function_entries(cg, fn_entries, fn_start, fn_chunk_size)
    fn_analysis_scratch = codegen.release_function_analysis_scratch(fn_analysis_scratch)
    // The explicit stride collection runs at the bottom of this loop, where
    // native stack-slot liveness has historically been conservative only for
    // values referenced by the current straight-line block.  The next
    // iteration still needs the reusable fragment state, function-entry arena
    // and accumulated object-path/helper builders.  Root the complete loop
    // frontier explicitly so a collection cannot turn one of those values
    // into a stale pointer.  Compiler profiling used to hide this bug by
    // extending several local live ranges through its diagnostic print.
    // The output paths and runtime configuration also cross this collection
    // boundary. They are not referenced again until serialization or linking,
    // so relying on native stack-slot liveness made the first stride GC turn
    // tmp_dir into a stale pointer in large, non-instrumented self-builds.
    _compile_codegen_keepalive = [load, cg, mod_cg, fn_entries, fn_analysis_scratch, helper_union, module_obj_paths_b, tmp_dir, input_abs, entry_path, runtime_config, output_exe]
    text_stream_offset = text_stream_offset + fragment_text_size
    if _compiler_profile_batches_enabled then
      fn_batch_function_count = fn_chunk_size
      if fn_start + fn_batch_function_count > fn_entry_count then fn_batch_function_count = fn_entry_count - fn_start end if
      fn_batch_total_ms = fn_step_finished - fn_batch_started
      fn_owner = _compiler_profile_owner(first_name)
      print "[profile] object_function_batch=" + fn_batch_count + " module=" + fn_owner + " first=" + first_name + " functions=" + fn_batch_function_count + " text_bytes=" + fragment_text_size + " setup_ms=" + fn_batch_setup_ms + " codegen_ms=" + fn_batch_codegen_ms + " serialize_ms=" + fn_batch_serialize_ms + " total_ms=" + fn_batch_total_ms
    end if
    module_object_seq = module_object_seq + 1
    fn_start = fn_start + fn_chunk_size
    fn_batch_count = fn_batch_count + 1
    section_checkpoint = 0
    fin = 0
    if (module_object_seq % fn_gc_stride) == 0 then
      gc_collect()
      // Reload every managed loop value from the global root after the
      // collection.  Merely publishing the frontier keeps the objects alive,
      // but a native self-host build may otherwise continue through stale
      // stack slots whose liveness ended at the gc_collect call.
      object_gc_roots = _compile_codegen_keepalive
      load = object_gc_roots[0]
      cg = object_gc_roots[1]
      mod_cg = object_gc_roots[2]
      fn_entries = object_gc_roots[3]
      fn_analysis_scratch = object_gc_roots[4]
      helper_union = object_gc_roots[5]
      module_obj_paths_b = object_gc_roots[6]
      tmp_dir = object_gc_roots[7]
      input_abs = object_gc_roots[8]
      entry_path = object_gc_roots[9]
      runtime_config = object_gc_roots[10]
      output_exe = object_gc_roots[11]
      object_gc_roots = 0
    end if
  end while
  if _compiler_profile_enabled then
    print "[profile] object_function_batches=" + fn_batch_count + " setup_ms=" + fn_setup_ms + " codegen_ms=" + fn_codegen_ms + " serialize_ms=" + fn_serialize_ms
  end if
  mod_cg = 0

  // The function stream is complete. Release its AST/index roots before
  // emitting the support tail; otherwise a large self-build reaches the
  // compiler GC limit with almost exclusively live analysis data and spends
  // most of the tail phase rescanning it. This mirrors the monolithic cleanup
  // and cannot affect already serialized text or section order.
  fn_entries = 0
  fn_analysis_scratch = []
  load.source = ""
  load.program = []
  load.aliases = []
  load.sources = []
  load.visited = []
  load.parsed_modules = []
  load.diagnostics = []
  module_init_recs = []
  prep = 0
  st = 0
  cg = codegen.clear_program_function_state(cg)
  _compile_codegen_keepalive = [load, cg]
  extern_sigs = 0
  extern_struct_names = 0
  _release_frontend_phase_arenas()
  gc_collect()
  _heap_probe("compile:frontend_arenas_released")

  _progress_phase("emitting canonical support tail")
  tail_checkpoint = _mlo_state_checkpoint(cg.state)
  tail_cg = codegen.clone_for_object(cg, false)
  if typeof(tail_cg) != "struct" or typeof(tail_cg.state) != "struct" then
    print "CompileError: failed to clone support codegen state"
    return 2
  end if
  tail_cg.state.label_id = cg.state.label_id
  tail_cg.state.rdata = cg.state.rdata
  tail_cg.state.data = cg.state.data
  tail_cg.state.bss = cg.state.bss
  tail_cg.state.used_helpers = helper_union
  _progress_phase("emitting canonical extern stubs")
  tail_cg = codegen.emit_extern_stubs(tail_cg)
  _progress_phase("emitting canonical runtime helpers")
  tail_cg = codegen.emit_used_helpers(tail_cg)
  linux_dynamic_imports = []
  if _compile_target == "linux-x64" then
    tail_cg.state = linuxrt.emit_runtime(tail_cg.state)
    prepared_linux_imports = linuxrt.prepare_dynamic_imports(tail_cg.state)
    tail_cg.state = prepared_linux_imports.state
    linux_dynamic_imports = prepared_linux_imports.imports
  end if
  _progress_phase("serializing canonical support tail")
  tail_obj = _mlo_from_state_delta("support", input_abs, "", tail_cg.state, tail_checkpoint)
  if _compile_target == "linux-x64" then tail_obj.imports = _mlo_linux_import_records(linux_dynamic_imports) end if
  tail_path = _tmp_obj_path(tmp_dir, "" + module_object_seq, input_abs, "support")
  wr_tail = _write_mlo_file(tail_path, tail_obj)
  if typeof(wr_tail) == "error" then
    msg2 = "writeAllBytes failed"
    if typeof(wr_tail.message) == "string" then msg2 = wr_tail.message end if
    print "CompileError: " + msg2 + " (" + tail_path + ")"
    return 2
  end if
  _progress_obj("wrote " + tail_path)

  obj_paths = [entry_path]
  module_obj_paths = t.arr_chunk_finish(module_obj_paths_b)
  if typeof(module_obj_paths) == "array" and len(module_obj_paths) > 0 then
    obj_paths = obj_paths + module_obj_paths
  end if
  obj_paths = obj_paths + [tail_path]
  _progress_phase("object emission complete")
  _progress_obj("objects=" + len(obj_paths))

  load.source = ""
  load.program = []
  load.aliases = []
  load.sources = []
  load.visited = []
  load.parsed_modules = []
  load.diagnostics = []
  module_init_recs = []
  module_obj_paths_b = 0
  module_obj_paths = []
  entry_obj = 0
  wr_entry = 0
  tail_obj = 0
  wr_tail = 0
  tail_cg = 0
  tail_checkpoint = 0
  helper_union = []
  prep = 0
  st = 0
  cg = 0
  load = 0
  _compile_codegen_keepalive = 0
  _heap_probe("compile:pre_link_gc")

  if _object_emit_only then
    print "OK: wrote " + len(obj_paths) + " canonical object files to " + tmp_dir
    return 0
  end if

  if _link_should_use_fresh_process(obj_paths) then
    gc_collect()
    fresh_link = _link_obj_dir_in_fresh_process(input_abs, tmp_dir, output_exe, subsystem, runtime_config)
    if fresh_link != -1 then return fresh_link end if
  end if
  _progress_phase("linking in current compiler process")
  return _link_mlo_files(obj_paths, output_exe, subsystem)
end function

// Dispatch to the selected monolithic or object-pipeline implementation.
function compile_to_exe_opts(input_ml, output_exe, include_dirs, keep_going, max_errors, runtime_config, call_profile, trace_calls, subsystem)
  if _object_pipeline_enabled then
    return compile_to_exe_opts_object(input_ml, output_exe, include_dirs, keep_going, max_errors, runtime_config, call_profile, trace_calls, subsystem)
  end if
  return compile_to_exe_opts_monolithic(input_ml, output_exe, include_dirs, keep_going, max_errors, runtime_config, call_profile, trace_calls, subsystem)
end function

// Compile with default include, diagnostic, runtime and subsystem options.
function compile_to_exe(input_ml, output_exe)
  return compile_to_exe_opts(input_ml, output_exe, [], false, 20, [], false, false, 3)
end function

// Link an existing object directory without parsing source again.
function link_obj_dir_to_exe(obj_dir, output_exe, subsystem)
  _progress_phase("link object directory")
  _progress_link("object dir=" + obj_dir)
  obj_paths = _collect_mlo_paths_from_dir(obj_dir)
  if typeof(obj_paths) == "error" then
    msg = "failed to enumerate object files"
    if typeof(obj_paths.message) == "string" then msg = obj_paths.message end if
    print "CompileError: " + msg
    return 2
  end if
  return _link_mlo_files(obj_paths, output_exe, subsystem)
end function

// Parse command-line arguments and execute project, compile or link mode.
function run_cli(args)
  global _mem_probe_enabled
  global _dump_labels_path
  global _object_pipeline_enabled
  global _object_emit_only
  global _asm_listing_enabled
  global _asm_listing_path
  global _asm_show_addr
  global _asm_show_bytes
  global _asm_show_code
  global _asm_dump_data
  global _asm_dump_pe
  global _compiler_profile_enabled
  global _compiler_profile_batches_enabled
  global _compiler_profile_ast_enabled
  global _compile_target
  if len(args) == 1 and (args[0] == "-version" or args[0] == "--version") then
    print COMPILER_VERSION_TEXT
    return 0
  end if
  expanded_project = project.expandArgs(args)
  if typeof(expanded_project) != "struct" or expanded_project.ok == false then
    msg_project = "invalid project manifest"
    if typeof(expanded_project) == "struct" and typeof(expanded_project.message) == "string" then msg_project = expanded_project.message end if
    print "ProjectError: " + msg_project
    return 2
  end if
  args = expanded_project.args
  project_build = expanded_project.project
  project_digest = ""
  project_cache_enabled = false
  project_object_cache_dir = ""
  _mem_probe_enabled = _has_flag(args, "--mem-probe")
  _compiler_profile_batches_enabled = _has_flag(args, "--profile-compiler-batches")
  _compiler_profile_ast_enabled = _has_flag(args, "--profile-compiler-ast")
  _compiler_profile_enabled = _has_flag(args, "--profile-compiler") or _compiler_profile_batches_enabled or _compiler_profile_ast_enabled
  _compiler_profile_reset()
  _dump_labels_path = _get_flag_value(args, "--dump-labels")
  _object_pipeline_enabled = false
  _object_emit_only = _has_flag(args, "--object-emit-only")
  _asm_listing_enabled = _has_flag(args, "--asm") and _has_flag(args, "--no-asm") == false
  _asm_listing_path = _get_flag_value(args, "--asm-out")
  _asm_show_addr = true
  _asm_show_bytes = true
  _asm_show_code = true
  asm_cols = _get_flag_value(args, "--asm-cols")
  if asm_cols != "" then
    _asm_show_addr = false
    _asm_show_bytes = false
    _asm_show_code = false
    col_parts = s.split(asm_cols, ",")
    for ci = 0 to len(col_parts) - 1
      col = s.toLowerAscii(s.trim(col_parts[ci]))
      if col == "addr" or col == "address" or col == "a" then
        _asm_show_addr = true
      else if col == "opcodes" or col == "bytes" or col == "b" or col == "opc" then
        _asm_show_bytes = true
      else if col == "code" or col == "asm" or col == "text" or col == "c" then
        _asm_show_code = true
      else if col != "" then
        print "CompileError: unknown --asm-cols token: " + col
        return 2
      end if
    end for
  end if
  if _has_flag(args, "--asm-no-addr") then _asm_show_addr = false end if
  if _has_flag(args, "--asm-no-opcodes") then _asm_show_bytes = false end if
  if _has_flag(args, "--asm-no-code") then _asm_show_code = false end if
  if _asm_show_addr == false and _asm_show_bytes == false and _asm_show_code == false then
    _asm_show_code = true
  end if
  _asm_dump_data = _has_flag(args, "--asm-data")
  _asm_dump_pe = _has_flag(args, "--asm-pe")
  if len(args) < 2 then
    _usage()
    return 1
  end if

  target_result = _get_target(args)
  if target_result[0] == false then
    print "CompileError: invalid target (use windows-x64 or linux-x64)"
    return 2
  end if
  _compile_target = target_result[1]
  configured_target = parser.set_compile_target(_compile_target)
  if typeof(configured_target) == "struct" and typeof(try(configured_target.message)) == "string" then
    print "CompileOptionError: " + configured_target.message
    return 2
  end if

  compile_define_result = _collect_compile_defines(args)
  if typeof(compile_define_result) == "struct" and typeof(try(compile_define_result.message)) == "string" then
    print "CompileOptionError: " + compile_define_result.message
    return 2
  end if

  inp = args[0]
  out_path = args[1]
  include_dirs = _collect_include_dirs(args)
  force_object_pipeline = _has_flag(args, "--object-pipeline")
  force_monolithic = _has_flag(args, "--no-object-pipeline")
  if force_object_pipeline and force_monolithic then
    print "CompileError: --object-pipeline and --no-object-pipeline are mutually exclusive"
    return 2
  end if
  object_score = 0
  if force_object_pipeline then
    _object_pipeline_enabled = true
  else if force_monolithic == false and _asm_listing_enabled == false and _dump_labels_path == "" and _has_flag(args, "--link-obj-dir") == false then
    object_score = _auto_object_pipeline_score(inp, include_dirs)
    _object_pipeline_enabled = object_score >= AUTO_OBJECT_PIPELINE_SCORE
  end if
  if _compiler_profile_enabled then
    object_mode = "monolithic"
    if _object_pipeline_enabled then object_mode = "object" end if
    object_reason = "auto"
    if force_object_pipeline then object_reason = "forced" end if
    if force_monolithic then object_reason = "disabled" end if
    print "[profile] object_pipeline=" + object_mode + " selection=" + object_reason + " score=" + object_score + " threshold=" + AUTO_OBJECT_PIPELINE_SCORE
  end if
  if typeof(project_build) == "struct" then
    if project.ensureOutputDirectory(out_path) == false then
      print "ProjectError: failed to create output directory"
      return 2
    end if
  end if
  keep_going = _has_flag(args, "--keep-going")
  max_errors = _get_max_errors(args)
  size_err = _validate_size_flags(args)
  if size_err != "" then
    print "CompileError: " + size_err
    return 2
  end if

  self_front = _has_flag(args, "--self-frontcheck")
  self_keep = _has_flag(args, "--self-frontcheck-keep-going")
  self_enabled = self_front or self_keep
  self_max = _get_self_max_errors(args)

  if self_enabled then
    include_dirs = _collect_include_dirs(args)
    check = _run_frontcheck(inp, include_dirs, self_keep, self_max)
    if len(check.diagnostics) > 0 then
      for di = 0 to len(check.diagnostics) - 1
        _print_diag(check.diagnostics[di])
      end for
      if len(check.diagnostics) >= self_max then
        print "Note: stopped after " + len(check.diagnostics) + " diagnostics (self-max-errors)."
      end if
      return 2
    end if
  end if

  runtime_config = _collect_runtime_config(args)
  gc_set_limit(_compiler_gc_limit_from_config(runtime_config))
  call_profile = _has_flag(args, "--profile-calls")
  trace_calls = _has_flag(args, "--trace-calls")
  ss = _get_subsystem(args)
  if ss[0] == false then
    print "CompileError: invalid subsystem (use console/cui or windows/window/gui)"
    return 2
  end if
  subsystem = ss[1]

  if typeof(project_build) == "struct" and project_build.incremental then
    project_cache_enabled = _asm_listing_enabled == false and _dump_labels_path == "" and self_enabled == false and _has_flag(args, "--link-obj-dir") == false
    if project_cache_enabled then
      project_digest = project.fingerprint(project_build, inp, include_dirs)
      if typeof(project_digest) == "error" then
        print "ProjectError: cannot fingerprint project"
        return 2
      end if
      if project.restore(project_build, project_digest, out_path) then
        print "OK: cache hit; restored " + out_path
        _compiler_profile_finish()
        return 0
      end if
    end if
  end if

  link_obj_dir = _get_flag_value(args, "--link-obj-dir")
  if link_obj_dir != "" then
    link_rc = link_obj_dir_to_exe(link_obj_dir, out_path, subsystem)
    _compiler_profile_finish()
    return link_rc
  end if

  compile_rc = 0
  if _object_pipeline_enabled and _object_emit_only == false then
    if project_cache_enabled then project_object_cache_dir = project.restoreObjects(project_build, project_digest) end if
    if project_object_cache_dir != "" then
      print "OK: object cache hit; linking " + project_object_cache_dir
      compile_rc = link_obj_dir_to_exe(project_object_cache_dir, out_path, subsystem)
    else
      // The coordinator no longer needs import-scan source buffers while the
      // emitter owns the large compiler heap. Collect before spawning so those
      // two memory sets do not overlap for the duration of code generation.
      gc_collect()
      compile_rc = _emit_obj_dir_in_fresh_process(args)
      emitted_obj_dir = _tmp_obj_dir(out_path)
      if compile_rc == 0 and project_cache_enabled then
        object_cache_store = project.storeObjects(project_build, project_digest, emitted_obj_dir)
        if typeof(object_cache_store) == "error" then
          print "ProjectError: cannot update incremental object cache"
          return 2
        end if
      end if
      if compile_rc == 0 then
        compile_rc = link_obj_dir_to_exe(emitted_obj_dir, out_path, subsystem)
      end if
    end if
  else
    compile_rc = compile_to_exe_opts(inp, out_path, include_dirs, keep_going, max_errors, runtime_config, call_profile, trace_calls, subsystem)
  end if
  if compile_rc == 0 and project_cache_enabled then
    cache_store = project.store(project_build, project_digest, out_path)
    if typeof(cache_store) == "error" then
      print "ProjectError: cannot update incremental cache"
      return 2
    end if
  end if
  _compiler_profile_finish()
  return compile_rc
end function
