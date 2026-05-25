package mlc.compiler
import std.fs as fs
import std.string as s
import mlc.frontend as frontend
import mlc.minilang_parser as parser
import mlc.codegen.codegen as codegen
import mlc.pe as pe
import mlc.tools as t
import mlc.asm as a

extern function GetFullPathNameW(path as wstr, bufferLen as u32, buffer as buffer, filePart as ptr) from "kernel32.dll" symbol "GetFullPathNameW" returns u32
extern function CreateDirectoryW(path as wstr, securityAttributes as ptr) from "kernel32.dll" symbol "CreateDirectoryW" returns bool
extern function GetModuleFileNameW(module as ptr, buffer as buffer, bufferLen as u32) from "kernel32.dll" symbol "GetModuleFileNameW" returns u32
extern function _wsystem(cmd as wstr) from "msvcrt.dll" returns int

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

struct ObjBuf
  parts,
  total,
end struct

struct ObjReader
  buf,
  pos,
end struct

_mem_probe_enabled = false
_dump_labels_path = ""
_path_norm_cache = []
_front_visited_set = []
_front_resolve_cache = []
_pe_state_keepalive = 0

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
  print "MiniLang self-hosted compiler (bootstrap frontend)"
  print "Usage:"
  print "  mlc_win64.exe <input.ml> <output.exe> [compiler options]"
  print "  mlc_win64.exe <ignored> <output.exe> --link-obj-dir <tmp-dir> [compiler options]"
  print "Extra self-hosted checks:"
  print "  --self-frontcheck"
  print "  --self-frontcheck-keep-going"
  print "Debug:"
  print "  --mem-probe"
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
          ns = slice(stack, 0, len(stack) - 1)
          if typeof(ns) == "array" then
            stack = ns
          else
            stack =[]
          end if
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
end function

function _path_norm(p)
  return s.toLowerAscii(_path_canon(p))
end function

function _path_abspath(p)
  if typeof(p) != "string" or p == "" then return "" end if
  buf = bytes(8192, 0)
  n = GetFullPathNameW(p, 4096, buf, 0)
  if typeof(n) != "int" or n <= 0 then
    return p
  end if
  abs_p = decode16Z(buf)
  if typeof(abs_p) != "string" or abs_p == "" then return p end if
  return abs_p
end function

function _self_exe_path()
  buf = bytes(8192, 0)
  n = GetModuleFileNameW(0, buf, 4096)
  if typeof(n) != "int" or n <= 0 then return "" end if
  p = decode16Z(buf)
  if typeof(p) != "string" then return "" end if
  return p
end function

function _cmd_quote_arg(x)
  if typeof(x) != "string" then return "\"\"" end if
  return "\"" + x + "\""
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
  return a + "\\" + b
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

  ok = CreateDirectoryW(path, 0)
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
  return ObjReader(buf, 0)
end function

function _objreader_read_u32(rd)
  if typeof(rd) != "struct" or typeof(rd.buf) != "bytes" then
    return error(1, "invalid object reader")
  end if
  if rd.pos < 0 or rd.pos + 4 > len(rd.buf) then
    return error(1, "truncated object file")
  end if
  v = _u32le_at(rd.buf, rd.pos)
  rd.pos = rd.pos + 4
  return [rd, v]
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
  if typeof(expr) != "struct" then return "" end if
  if expr.node_kind == "Var" and typeof(expr.name) == "string" then
    return expr.name
  end if
  if expr.node_kind == "Member" and typeof(expr.name) == "string" then
    base = _expr_to_qualname(expr.target)
    if base == "" then return "" end if
    return base + "." + expr.name
  end if
  return ""
end function

function _is_constexpr_expr(expr)
  if typeof(expr) != "struct" then return false end if
  k = expr.node_kind
  if k == "Num" or k == "Str" or k == "Bool" then return true end if
  if k == "Var" then return true end if
  if k == "Member" then return _expr_to_qualname(expr) != "" end if
  if k == "Unary" then
    if _is_constexpr_unary(expr.op) == false then return false end if
    return _is_constexpr_expr(expr.right)
  end if
  if k == "Bin" then
    if _is_constexpr_binary(expr.op) == false then return false end if
    return _is_constexpr_expr(expr.left) and _is_constexpr_expr(expr.right)
  end if
  return false
end function

function _is_decl_stmt(st)
  if typeof(st) != "struct" then return false end if
  k = st.node_kind
  return k == "FunctionDef" or k == "StructDef" or k == "EnumDef" or k == "NamespaceDef" or k == "NamespaceDecl" or k == "ExternFunctionDef" or k == "ExternFunctionDecl" or k == "ConstDecl" or k == "Assign" or k == "Import"
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

  tried = t.arr_chunk_finish(tried_b)
  matches = t.arr_chunk_finish(matches_b)
  return ResolveResult(resolved, tried, matches, resolved_kind, resolved_root)
end function

function _resolve_import_cache_key(requested, base_dir)
  req = requested
  if typeof(req) != "string" then req = "" + req end if
  return _path_norm_cached(base_dir) + "|" + s.toLowerAscii(req)
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
          if kx == "FunctionDef" or kx == "StructDef" or kx == "NamespaceDecl" or kx == "ExternFunctionDef" or kx == "ExternFunctionDecl" or kx == "Assign" or kx == "Import" then
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

      if declared_pkg != "" and expected_pkg != "" and declared_pkg != expected_pkg then
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
    compiler_gc_limit = _cfg_get_int(runtime_config, "gc_bytes_limit", 0)
  end if
  if compiler_gc_limit <= 0 then
    compiler_gc_limit = _cfg_get_int(runtime_config, "commit_bytes", 64 << 20)
    if compiler_gc_limit < (64 << 20) then compiler_gc_limit = 64 << 20 end if
    if compiler_gc_limit > (256 << 20) then compiler_gc_limit = 256 << 20 end if
  end if
  return compiler_gc_limit
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

function _mlo_patches_from_asm(arr)
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
      out_b = t.arr_chunk_push(out_b, MloPatch(pos, trg, kind))
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
  text_buf = bytes(0)
  if typeof(st.asm) == "struct" then
    asm_labels = a.get_labels(st.asm)
    asm_patches = a.get_patches(st.asm)
    st.asm = a.materialize(st.asm)
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
    rdata_labels = _mlo_labels_from_arr(st.rdata.labels)
    rdata_patches = _mlo_patches_from_data(st.rdata.patches)
  end if

  data_labels = []
  data_patches = []
  if typeof(st.data) == "struct" then
    data_labels = _mlo_labels_from_arr(st.data.labels)
    data_patches = _mlo_patches_from_data(st.data.patches)
  end if

  return MloObject(
    kind,
    module_file,
    entry_label,
    text_buf,
    rdata_buf,
    data_buf,
    bss_size,
    _mlo_labels_from_asm_labels(asm_labels),
    _mlo_patches_from_asm(asm_patches),
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
  obj = _mlo_from_state(kind, module_file, entry_label, st)
  if typeof(base_state) != "struct" then return obj end if

  rdata_prefix = 0
  if typeof(base_state.rdata) == "struct" and typeof(base_state.rdata.used) == "int" then
    rdata_prefix = base_state.rdata.used
  end if
  if rdata_prefix > 0 and len(obj.rdata) >= rdata_prefix then
    rdata_cut = _mlo_align_down8(rdata_prefix)
    obj.rdata = slice(obj.rdata, rdata_cut, len(obj.rdata) - rdata_cut)
    obj.rdata_labels = _mlo_labels_after_cut(obj.rdata_labels, rdata_prefix, rdata_cut)
    obj.rdata_patches = _mlo_patches_after_cut(obj.rdata_patches, rdata_prefix, rdata_cut)
  end if

  data_prefix = 0
  if typeof(base_state.data) == "struct" and typeof(base_state.data.used) == "int" then
    data_prefix = base_state.data.used
  end if
  if data_prefix > 0 and len(obj.data) >= data_prefix then
    data_cut = _mlo_align_down8(data_prefix)
    obj.data = slice(obj.data, data_cut, len(obj.data) - data_cut)
    obj.data_labels = _mlo_labels_after_cut(obj.data_labels, data_prefix, data_cut)
    obj.data_patches = _mlo_patches_after_cut(obj.data_patches, data_prefix, data_cut)
  end if

  bss_prefix = 0
  if typeof(base_state.bss) == "struct" and typeof(base_state.bss.size) == "int" then
    bss_prefix = base_state.bss.size
  end if
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
    trg = _coerce_name(try(pt.target))
    if trg == "" then continue end if
    new_trg = t.fastmap_get(label_map, trg, trg)
    off = try(pt.offset)
    if typeof(off) != "int" then off = 0 end if
    kind = _coerce_name(try(pt.kind))
    if kind == "" then continue end if
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

function _mlo_bp_u32(bp, value)
  return _mlo_bp_push(bp, t.u32(value))
end function

function _mlo_bp_bytes(bp, b)
  raw = b
  if typeof(raw) != "bytes" then raw = bytes(0) end if
  bp = _mlo_bp_u32(bp, len(raw))
  return _mlo_bp_push(bp, raw)
end function

function _mlo_bp_string(bp, text)
  raw = bytes("")
  if typeof(text) == "string" then raw = bytes(text) end if
  return _mlo_bp_bytes(bp, raw)
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
        bp = _mlo_bp_string(bp, "")
        bp = _mlo_bp_string(bp, "")
        continue
      end if
      off = try(pt.offset)
      if typeof(off) != "int" then off = 0 end if
      bp = _mlo_bp_u32(bp, off)
      bp = _mlo_bp_string(bp, _coerce_name(try(pt.target)))
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
        ob = _objbuf_string(ob, "")
        ob = _objbuf_string(ob, "")
        continue
      end if
      off = try(pt.offset)
      if typeof(off) != "int" then off = 0 end if
      ob = _objbuf_u32(ob, off)
      ob = _objbuf_string(ob, _coerce_name(try(pt.target)))
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

function _write_mlo_file(path, obj)
  bp = t.byte_pages_new()
  bp = _mlo_bp_string(bp, "MLO1")
  bp = _mlo_bp_u32(bp, 1)
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
  return fs.writeAllBytes(path, t.byte_pages_to_bytes(bp))
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

function _mlo_read_patches(rd)
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
      rt = _objreader_read_string(rd)
      if typeof(rt) == "error" then return rt end if
      rd = rt[0]
      trg = rt[1]
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
  if rver[1] != 1 then return error(1, "unsupported MiniLang object version") end if

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

  r2 = _mlo_read_patches(rd)
  if typeof(r2) == "error" then return r2 end if
  rd = r2[0]
  asm_patches = r2[1]

  r3 = _mlo_read_labels(rd)
  if typeof(r3) == "error" then return r3 end if
  rd = r3[0]
  rdata_labels = r3[1]

  r4 = _mlo_read_patches(rd)
  if typeof(r4) == "error" then return r4 end if
  rd = r4[0]
  rdata_patches = r4[1]

  r5 = _mlo_read_labels(rd)
  if typeof(r5) == "error" then return r5 end if
  rd = r5[0]
  data_labels = r5[1]

  r6 = _mlo_read_patches(rd)
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
    if typeof(pt_target) != "string" or typeof(pt_kind) != "string" then
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
  idx = _link_target_obj_index(name)
  if idx == "" then return -1 end if
  acc = 0
  for i = 0 to len(idx) - 1
    c = _char_code_local(idx[i])
    if c < 48 or c > 57 then return -1 end if
    acc = (acc * 10) + (c - 48)
  end for
  return acc
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
      rn = _objreader_read_string(rd)
      if typeof(rn) == "error" then return rn end if
      rd = rn[0]
      ro = _objreader_read_u32(rd)
      if typeof(ro) == "error" then return ro end if
      rd = ro[0]
    end for
  end if
  return rd
end function

function _mlo_skip_patches(rd)
  rc = _objreader_read_u32(rd)
  if typeof(rc) == "error" then return rc end if
  rd = rc[0]
  count = rc[1]
  if count > 0 then
    for i = 0 to count - 1
      ro = _objreader_read_u32(rd)
      if typeof(ro) == "error" then return ro end if
      rd = ro[0]
      rt = _objreader_read_string(rd)
      if typeof(rt) == "error" then return rt end if
      rd = rt[0]
      rk = _objreader_read_string(rd)
      if typeof(rk) == "error" then return rk end if
      rd = rk[0]
    end for
  end if
  return rd
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
  if rver[1] != 1 then return error(1, "unsupported MiniLang object version") end if

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

  rtext = _objreader_read_bytes(rd)
  if typeof(rtext) == "error" then return rtext end if
  rd = rtext[0]
  text = rtext[1]

  rrdata = _objreader_read_bytes(rd)
  if typeof(rrdata) == "error" then return rrdata end if
  rd = rrdata[0]
  rdata = rrdata[1]

  rdata2 = _objreader_read_bytes(rd)
  if typeof(rdata2) == "error" then return rdata2 end if
  rd = rdata2[0]
  data = rdata2[1]

  rbss = _objreader_read_u32(rd)
  if typeof(rbss) == "error" then return rbss end if
  rd = rbss[0]
  bss_size = rbss[1]

  r1 = _mlo_read_labels(rd)
  if typeof(r1) == "error" then return r1 end if
  rd = r1[0]
  asm_labels = r1[1]

  r2 = _mlo_skip_patches(rd)
  if typeof(r2) == "error" then return r2 end if
  rd = r2

  r3 = _mlo_read_labels(rd)
  if typeof(r3) == "error" then return r3 end if
  rd = r3[0]
  rdata_labels = r3[1]

  r4 = _mlo_skip_patches(rd)
  if typeof(r4) == "error" then return r4 end if
  rd = r4

  r5 = _mlo_read_labels(rd)
  if typeof(r5) == "error" then return r5 end if
  rd = r5[0]
  data_labels = r5[1]

  r6 = _mlo_skip_patches(rd)
  if typeof(r6) == "error" then return r6 end if
  rd = r6

  r7 = _mlo_read_labels(rd)
  if typeof(r7) == "error" then return r7 end if
  rd = r7[0]
  bss_labels = r7[1]

  r8 = _mlo_read_imports(rd)
  if typeof(r8) == "error" then return r8 end if
  imports = r8[1]

  return MloObject(kind, module_file, entry_label, text, rdata, data, bss_size, asm_labels, [], rdata_labels, [], data_labels, [], bss_labels, imports)
end function

function _mlo_read_patch_triplets(rd, default_kind)
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
      rt = _objreader_read_string(rd)
      if typeof(rt) == "error" then return rt end if
      rd = rt[0]
      trg = rt[1]
      rk = _objreader_read_string(rd)
      if typeof(rk) == "error" then return rk end if
      rd = rk[0]
      kind = rk[1]
      if typeof(trg) != "string" or trg == "" or trg == "unknown" then
        continue
      end if
      if typeof(kind) != "string" or kind == "" or kind == "unknown" then
        kind = default_kind
      end if
      out_b = t.arr_chunk_push(out_b, [off, trg, kind])
    end for
  end if
  return [rd, t.arr_chunk_finish(out_b)]
end function

function _read_mlo_patch_triplets(path)
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
  if rver[1] != 1 then return error(1, "unsupported MiniLang object version") end if

  for i = 0 to 2
    rs = _objreader_read_string(rd)
    if typeof(rs) == "error" then return rs end if
    rd = rs[0]
  end for
  for i = 0 to 2
    rb = _objreader_read_bytes(rd)
    if typeof(rb) == "error" then return rb end if
    rd = rb[0]
  end for
  rbss = _objreader_read_u32(rd)
  if typeof(rbss) == "error" then return rbss end if
  rd = rbss[0]

  r1 = _mlo_skip_labels(rd)
  if typeof(r1) == "error" then return r1 end if
  rd = r1

  r2 = _mlo_read_patch_triplets(rd, "rel32")
  if typeof(r2) == "error" then return r2 end if
  rd = r2[0]
  asm_patches = r2[1]

  r3 = _mlo_skip_labels(rd)
  if typeof(r3) == "error" then return r3 end if
  rd = r3

  r4 = _mlo_read_patch_triplets(rd, "abs64")
  if typeof(r4) == "error" then return r4 end if
  rd = r4[0]
  rdata_patches = r4[1]

  r5 = _mlo_skip_labels(rd)
  if typeof(r5) == "error" then return r5 end if
  rd = r5

  r6 = _mlo_read_patch_triplets(rd, "abs64")
  if typeof(r6) == "error" then return r6 end if
  data_patches = r6[1]

  return [asm_patches, rdata_patches, data_patches]
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

function _link_local_label_add(local_label_map, local_labels_b, name, value)
  nm = _label_key(name)
  if nm == "" then return [local_label_map, local_labels_b] end if
  local_label_map = t.fastmap_set(local_label_map, nm, value)
  local_labels_b = t.arr_chunk_push(local_labels_b, StrIntPair(nm, value))
  return [local_label_map, local_labels_b]
end function

function _link_scan_local_labels(raw, obj_text_off, obj_rdata_off, obj_data_off, obj_bss_off, text_rva, rdata_rva, data_rva, bss_rva)
  local_label_cap = 2048
  if typeof(raw) == "bytes" then
    if len(raw) > 1000000 then
      local_label_cap = 65536
    else
      if len(raw) > 200000 then local_label_cap = 16384 end if
    end if
  end if
  local_label_map = t.fastmap_new(local_label_cap)
  local_labels_b = t.arr_chunk_new(128)
  rd = _objreader_new(raw)

  rmagic = _objreader_read_string(rd)
  if typeof(rmagic) == "error" then return [local_label_map, t.arr_chunk_finish(local_labels_b)] end if
  rd = rmagic[0]
  rver = _objreader_read_u32(rd)
  if typeof(rver) == "error" then return [local_label_map, t.arr_chunk_finish(local_labels_b)] end if
  rd = rver[0]
  for i = 0 to 2
    rs = _objreader_read_string(rd)
    if typeof(rs) == "error" then return [local_label_map, t.arr_chunk_finish(local_labels_b)] end if
    rd = rs[0]
  end for
  for i = 0 to 2
    rb = _objreader_read_bytes(rd)
    if typeof(rb) == "error" then return [local_label_map, t.arr_chunk_finish(local_labels_b)] end if
    rd = rb[0]
  end for
  rbss = _objreader_read_u32(rd)
  if typeof(rbss) == "error" then return [local_label_map, t.arr_chunk_finish(local_labels_b)] end if
  rd = rbss[0]

  r1 = _mlo_read_labels(rd)
  if typeof(r1) == "error" then return [local_label_map, t.arr_chunk_finish(local_labels_b)] end if
  rd = r1[0]
  labs = r1[1]
  if typeof(labs) == "array" and len(labs) > 0 then
    for li = 0 to len(labs) - 1
      lb = labs[li]
      if typeof(lb) != "struct" then continue end if
      lb_name = _coerce_name(try(lb.name))
      lb_off = try(lb.offset)
      if lb_name == "" or typeof(lb_off) != "int" then continue end if
      rr = _link_local_label_add(local_label_map, local_labels_b, lb_name, text_rva + obj_text_off + lb_off)
      local_label_map = rr[0]
      local_labels_b = rr[1]
    end for
  end if
  rd = _mlo_skip_patches(rd)
  if typeof(rd) == "error" then return [local_label_map, t.arr_chunk_finish(local_labels_b)] end if

  r2 = _mlo_read_labels(rd)
  if typeof(r2) == "error" then return [local_label_map, t.arr_chunk_finish(local_labels_b)] end if
  rd = r2[0]
  labs = r2[1]
  if typeof(labs) == "array" and len(labs) > 0 then
    for li = 0 to len(labs) - 1
      lb = labs[li]
      if typeof(lb) != "struct" then continue end if
      lb_name = _coerce_name(try(lb.name))
      lb_off = try(lb.offset)
      if lb_name == "" or typeof(lb_off) != "int" then continue end if
      rr = _link_local_label_add(local_label_map, local_labels_b, lb_name, rdata_rva + obj_rdata_off + lb_off)
      local_label_map = rr[0]
      local_labels_b = rr[1]
    end for
  end if
  rd = _mlo_skip_patches(rd)
  if typeof(rd) == "error" then return [local_label_map, t.arr_chunk_finish(local_labels_b)] end if

  r3 = _mlo_read_labels(rd)
  if typeof(r3) == "error" then return [local_label_map, t.arr_chunk_finish(local_labels_b)] end if
  rd = r3[0]
  labs = r3[1]
  if typeof(labs) == "array" and len(labs) > 0 then
    for li = 0 to len(labs) - 1
      lb = labs[li]
      if typeof(lb) != "struct" then continue end if
      lb_name = _coerce_name(try(lb.name))
      lb_off = try(lb.offset)
      if lb_name == "" or typeof(lb_off) != "int" then continue end if
      rr = _link_local_label_add(local_label_map, local_labels_b, lb_name, data_rva + obj_data_off + lb_off)
      local_label_map = rr[0]
      local_labels_b = rr[1]
    end for
  end if
  rd = _mlo_skip_patches(rd)
  if typeof(rd) == "error" then return [local_label_map, t.arr_chunk_finish(local_labels_b)] end if

  r4 = _mlo_read_labels(rd)
  if typeof(r4) == "error" then return [local_label_map, t.arr_chunk_finish(local_labels_b)] end if
  labs = r4[1]
  if typeof(labs) == "array" and len(labs) > 0 then
    for li = 0 to len(labs) - 1
      lb = labs[li]
      if typeof(lb) != "struct" then continue end if
      lb_name = _coerce_name(try(lb.name))
      lb_off = try(lb.offset)
      if lb_name == "" or typeof(lb_off) != "int" then continue end if
      rr = _link_local_label_add(local_label_map, local_labels_b, lb_name, bss_rva + obj_bss_off + lb_off)
      local_label_map = rr[0]
      local_labels_b = rr[1]
    end for
  end if

  return [local_label_map, t.arr_chunk_finish(local_labels_b)]
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
  if rver[1] != 1 then
    print "CompileError: unsupported MiniLang object version (" + src_patch + ")"
    return [2, label_map, patch_index]
  end if

  for i = 0 to 2
    rs = _objreader_read_string(rd)
    if typeof(rs) == "error" then return [2, label_map, patch_index] end if
    rd = rs[0]
  end for
  for i = 0 to 2
    rb = _objreader_read_bytes(rd)
    if typeof(rb) == "error" then return [2, label_map, patch_index] end if
    rd = rb[0]
  end for
  rbss = _objreader_read_u32(rd)
  if typeof(rbss) == "error" then return [2, label_map, patch_index] end if
  rd = rbss[0]
  local_scan = _link_scan_local_labels(raw, obj_text_off, obj_rdata_off, obj_data_off, obj_bss_off, text_rva, rdata_rva, data_rva, bss_rva)
  local_label_map = local_scan[0]
  local_labels = local_scan[1]
  last_target = ""
  last_value = -1
  target_cache_cap = 4096
  if typeof(raw) == "bytes" then
    if len(raw) > 1000000 then
      target_cache_cap = 65536
    else
      if len(raw) > 200000 then target_cache_cap = 16384 end if
    end if
  end if
  target_cache = t.fastmap_new(target_cache_cap)

  rskip1 = _mlo_skip_labels(rd)
  if typeof(rskip1) == "error" then return [2, label_map, patch_index] end if
  rd = rskip1
  rct = _objreader_read_u32(rd)
  if typeof(rct) == "error" then return [2, label_map, patch_index] end if
  rd = rct[0]
  text_patch_count = rct[1]
  if text_patch_count > 0 then
    for i = 0 to text_patch_count - 1
      ro = _objreader_read_u32(rd)
      if typeof(ro) == "error" then return [2, label_map, patch_index] end if
      rd = ro[0]
      pt_off = ro[1]
      rt = _objreader_read_string(rd)
      if typeof(rt) == "error" then return [2, label_map, patch_index] end if
      rd = rt[0]
      pt_target = rt[1]
      rk = _objreader_read_string(rd)
      if typeof(rk) == "error" then return [2, label_map, patch_index] end if
      rd = rk[0]
      if typeof(pt_target) != "string" or pt_target == "" or pt_target == "unknown" then
        continue
      end if

      trg = -1
      if pt_target == last_target then
        trg = last_value
      else
        rr = _link_resolve_patch_target_cached(label_map, target_cache, obj_index_map, obj_index_lists, local_label_map, local_labels, labels, link_patch_recs, text_rva, rdata_rva, data_rva, bss_rva, src_patch, pt_target)
        label_map = rr[0]
        target_cache = rr[1]
        trg = rr[2]
        last_target = pt_target
        last_value = trg
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
      b4 = t.u32(disp)
      buf[abs_off] = b4[0]
      buf[abs_off + 1] = b4[1]
      buf[abs_off + 2] = b4[2]
      buf[abs_off + 3] = b4[3]
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
      ro = _objreader_read_u32(rd)
      if typeof(ro) == "error" then return [2, label_map, patch_index] end if
      rd = ro[0]
      pt_off = ro[1]
      rt = _objreader_read_string(rd)
      if typeof(rt) == "error" then return [2, label_map, patch_index] end if
      rd = rt[0]
      pt_target = rt[1]
      rk = _objreader_read_string(rd)
      if typeof(rk) == "error" then return [2, label_map, patch_index] end if
      rd = rk[0]
      if typeof(pt_target) != "string" or pt_target == "" or pt_target == "unknown" then
        continue
      end if

      trg = -1
      if pt_target == last_target then
        trg = last_value
      else
        rr = _link_resolve_patch_target_cached(label_map, target_cache, obj_index_map, obj_index_lists, local_label_map, local_labels, labels, link_patch_recs, text_rva, rdata_rva, data_rva, bss_rva, src_patch, pt_target)
        label_map = rr[0]
        target_cache = rr[1]
        trg = rr[2]
        last_target = pt_target
        last_value = trg
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
      ro = _objreader_read_u32(rd)
      if typeof(ro) == "error" then return [2, label_map, patch_index] end if
      rd = ro[0]
      pt_off = ro[1]
      rt = _objreader_read_string(rd)
      if typeof(rt) == "error" then return [2, label_map, patch_index] end if
      rd = rt[0]
      pt_target = rt[1]
      rk = _objreader_read_string(rd)
      if typeof(rk) == "error" then return [2, label_map, patch_index] end if
      rd = rk[0]
      if typeof(pt_target) != "string" or pt_target == "" or pt_target == "unknown" then
        continue
      end if

      trg = -1
      if pt_target == last_target then
        trg = last_value
      else
        rr = _link_resolve_patch_target_cached(label_map, target_cache, obj_index_map, obj_index_lists, local_label_map, local_labels, labels, link_patch_recs, text_rva, rdata_rva, data_rva, bss_rva, src_patch, pt_target)
        label_map = rr[0]
        target_cache = rr[1]
        trg = rr[2]
        last_target = pt_target
        last_value = trg
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
  return true
end function

function _collect_internal_helper_targets(dst, patches)
  merged = dst
  if typeof(merged) != "array" then merged = [] end if
  if typeof(patches) != "array" or len(patches) <= 0 then return merged end if
  for i = 0 to len(patches) - 1
    pt = patches[i]
    if typeof(pt) != "struct" then continue end if
    trg = _coerce_name(try(pt.target))
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

function _load_program_for_codegen(entry, include_dirs, keep_going, max_errors)
  entry_abs = _path_abspath(entry)
  if entry_abs == "" then entry_abs = entry end if
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
    if _path_eq(path, entry_abs) == false then
      parsed.source = ""
      parsed_modules = _parsed_module_set(parsed_modules, path, "", parsed.program)
    end if
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
  _heap_probe("load:done")
  return LoadProgramResult(diags, entry_source, merged, aliases, source_pairs, visited, parsed_modules)
end function

function _link_mlo_files(obj_paths, output_exe, subsystem)
  global _dump_labels_path
  text_parts_b = t.arr_chunk_new(64)
  rdata_parts_b = t.arr_chunk_new(64)
  data_parts_b = t.arr_chunk_new(64)
  patch_file_recs_b = t.arr_chunk_new(64)
  obj_label_recs_b = t.arr_chunk_new(64)
  text_labels_b = t.arr_chunk_new(4096)
  rdata_labels_b = t.arr_chunk_new(4096)
  data_labels_b = t.arr_chunk_new(4096)
  bss_labels_b = t.arr_chunk_new(4096)
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

  for oi = 0 to len(obj_paths) - 1
    obj_path = obj_paths[oi]
    ro = _read_mlo_file_for_layout(obj_path)
    if typeof(ro) == "error" then
      msg = "failed to read MiniLang object file"
      if typeof(ro.message) == "string" then msg = ro.message end if
      print "CompileError: " + msg + " (" + obj_path + ")"
      return 2
    end if
    obj = ro
    _debug_validate_patch_names("obj_text " + obj_path, obj.asm_patches)
    _debug_validate_patch_names("obj_rdata " + obj_path, obj.rdata_patches)
    _debug_validate_patch_names("obj_data " + obj_path, obj.data_patches)

    if entry_label == "" and typeof(obj.entry_label) == "string" and obj.entry_label != "" then
      entry_label = obj.entry_label
    end if

    text_obj_off = text_off
    if _section_has_payload(obj.text, obj.asm_labels, obj.asm_patches, 0) then
      text_pad = t.align_up(text_off, 16) - text_off
      text_parts_b = _append_zero_pad(text_parts_b, text_pad)
      text_obj_off = text_off + text_pad
      text_off = text_obj_off
    end if

    rdata_obj_off = rdata_off
    if _section_has_payload(obj.rdata, obj.rdata_labels, obj.rdata_patches, 0) then
      rdata_pad = t.align_up(rdata_off, 8) - rdata_off
      rdata_parts_b = _append_zero_pad(rdata_parts_b, rdata_pad)
      rdata_obj_off = rdata_off + rdata_pad
      rdata_off = rdata_obj_off
    end if

    data_obj_off = data_off
    if _section_has_payload(obj.data, obj.data_labels, obj.data_patches, 0) then
      data_pad = t.align_up(data_off, 8) - data_off
      data_parts_b = _append_zero_pad(data_parts_b, data_pad)
      data_obj_off = data_off + data_pad
      data_off = data_obj_off
    end if

    bss_obj_off = bss_off
    if _section_has_payload(bytes(0), obj.bss_labels, [], obj.bss_size) then
      bss_pad = t.align_up(bss_off, 8) - bss_off
      bss_obj_off = bss_off + bss_pad
      bss_off = bss_obj_off
    end if

    text_parts_b = t.arr_chunk_push(text_parts_b, obj.text)
    rdata_parts_b = t.arr_chunk_push(rdata_parts_b, obj.rdata)
    data_parts_b = t.arr_chunk_push(data_parts_b, obj.data)

    if typeof(obj.asm_labels) == "array" and len(obj.asm_labels) > 0 then
      for li = 0 to len(obj.asm_labels) - 1
        lb = obj.asm_labels[li]
        if typeof(lb) != "struct" then continue end if
        lb_name = _coerce_name(try(lb.name))
        lb_off = try(lb.offset)
        if lb_name == "" or typeof(lb_off) != "int" then continue end if
        text_labels_b = t.arr_chunk_push(text_labels_b, MloLabel(lb_name, text_obj_off + lb_off))
      end for
    end if
    if typeof(obj.rdata_labels) == "array" and len(obj.rdata_labels) > 0 then
      for li = 0 to len(obj.rdata_labels) - 1
        lb = obj.rdata_labels[li]
        if typeof(lb) != "struct" then continue end if
        lb_name = _coerce_name(try(lb.name))
        lb_off = try(lb.offset)
        if lb_name == "" or typeof(lb_off) != "int" then continue end if
        rdata_labels_b = t.arr_chunk_push(rdata_labels_b, MloLabel(lb_name, rdata_obj_off + lb_off))
      end for
    end if
    if typeof(obj.data_labels) == "array" and len(obj.data_labels) > 0 then
      for li = 0 to len(obj.data_labels) - 1
        lb = obj.data_labels[li]
        if typeof(lb) != "struct" then continue end if
        lb_name = _coerce_name(try(lb.name))
        lb_off = try(lb.offset)
        if lb_name == "" or typeof(lb_off) != "int" then continue end if
        data_labels_b = t.arr_chunk_push(data_labels_b, MloLabel(lb_name, data_obj_off + lb_off))
      end for
    end if
    if typeof(obj.bss_labels) == "array" and len(obj.bss_labels) > 0 then
      for li = 0 to len(obj.bss_labels) - 1
        lb = obj.bss_labels[li]
        if typeof(lb) != "struct" then continue end if
        lb_name = _coerce_name(try(lb.name))
        lb_off = try(lb.offset)
        if lb_name == "" or typeof(lb_off) != "int" then continue end if
        bss_labels_b = t.arr_chunk_push(bss_labels_b, MloLabel(lb_name, bss_obj_off + lb_off))
      end for
    end if

    patch_file_recs_b = t.arr_chunk_push(patch_file_recs_b, [obj_path, text_obj_off, rdata_obj_off, data_obj_off, bss_obj_off])
    obj_label_recs_b = t.arr_chunk_push(obj_label_recs_b, [obj_path, text_obj_off, rdata_obj_off, data_obj_off, bss_obj_off])

    imports = _mlo_merge_imports(imports, obj.imports)
    text_off = text_obj_off + len(obj.text)
    rdata_off = rdata_obj_off + len(obj.rdata)
    data_off = data_obj_off + len(obj.data)
    bss_off = bss_obj_off + obj.bss_size

    if (oi % 8) == 0 then
      gc_collect()
    end if
    if (oi % 32) == 0 then
      _heap_probe("link:obj_" + oi)
    end if
  end for

  text_buf = _concat_bytes_parts(text_parts_b)
  rdata_buf = _concat_bytes_parts(rdata_parts_b)
  data_buf = _concat_bytes_parts(data_parts_b)
  patch_file_recs = t.arr_chunk_finish(patch_file_recs_b)
  obj_label_recs = t.arr_chunk_finish(obj_label_recs_b)

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

  text_rva = p.sections[0].virt_addr
  rdata_rva = p.sections[1].virt_addr
  data_rva = p.sections[2].virt_addr
  bss_rva = p.sections[3].virt_addr

  text_labels = t.arr_chunk_finish(text_labels_b)
  rdata_labels = t.arr_chunk_finish(rdata_labels_b)
  data_labels = t.arr_chunk_finish(data_labels_b)
  bss_labels = t.arr_chunk_finish(bss_labels_b)

  label_map = t.fastmap_new(65536)
  obj_index_map = []
  obj_index_lists = []
  if typeof(obj_label_recs) == "array" and len(obj_label_recs) > 0 then
    for oi = 0 to len(obj_label_recs)
      obj_index_map = obj_index_map + [0]
      obj_index_lists = obj_index_lists + [0]
    end for
  end if
  want_labels_dump = typeof(_dump_labels_path) == "string" and _dump_labels_path != ""
  labels_b = t.arr_chunk_new(512)

  if len(text_labels) > 0 then
    for li = 0 to len(text_labels) - 1
      lb = text_labels[li]
      if typeof(lb) != "struct" then continue end if
      lb_off = try(lb.offset)
      if typeof(lb_off) != "int" then continue end if
      final_v = text_rva + lb_off
      nm = _label_key(try(lb.name))
      if nm == "" then continue end if
      if s.startsWith(nm, "objm_") then
        obj_index_map = _link_obj_label_map_set(obj_index_map, nm, final_v)
      else
        label_map = t.fastmap_set(label_map, nm, final_v)
        labels_b = t.arr_chunk_push(labels_b, StrIntPair(nm, final_v))
      end if
    end for
  end if
  if len(rdata_labels) > 0 then
    for li = 0 to len(rdata_labels) - 1
      lb = rdata_labels[li]
      if typeof(lb) != "struct" then continue end if
      lb_off = try(lb.offset)
      if typeof(lb_off) != "int" then continue end if
      final_v = rdata_rva + lb_off
      nm = _label_key(try(lb.name))
      if nm == "" then continue end if
      if s.startsWith(nm, "objm_") then
        obj_index_map = _link_obj_label_map_set(obj_index_map, nm, final_v)
      else
        label_map = t.fastmap_set(label_map, nm, final_v)
        labels_b = t.arr_chunk_push(labels_b, StrIntPair(nm, final_v))
      end if
    end for
  end if
  if len(data_labels) > 0 then
    for li = 0 to len(data_labels) - 1
      lb = data_labels[li]
      if typeof(lb) != "struct" then continue end if
      lb_off = try(lb.offset)
      if typeof(lb_off) != "int" then continue end if
      final_v = data_rva + lb_off
      nm = _label_key(try(lb.name))
      if nm == "" then continue end if
      if s.startsWith(nm, "objm_") then
        obj_index_map = _link_obj_label_map_set(obj_index_map, nm, final_v)
      else
        label_map = t.fastmap_set(label_map, nm, final_v)
        labels_b = t.arr_chunk_push(labels_b, StrIntPair(nm, final_v))
      end if
    end for
  end if
  if len(bss_labels) > 0 then
    for li = 0 to len(bss_labels) - 1
      lb = bss_labels[li]
      if typeof(lb) != "struct" then continue end if
      lb_off = try(lb.offset)
      if typeof(lb_off) != "int" then continue end if
      final_v = bss_rva + lb_off
      nm = _label_key(try(lb.name))
      if nm == "" then continue end if
      if s.startsWith(nm, "objm_") then
        obj_index_map = _link_obj_label_map_set(obj_index_map, nm, final_v)
      else
        label_map = t.fastmap_set(label_map, nm, final_v)
        labels_b = t.arr_chunk_push(labels_b, StrIntPair(nm, final_v))
      end if
    end for
  end if
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
    dump = ""
    dump = dump + "[section] .text raw=" + len(text_buf) + "\n"
    dump = dump + "[section] .rdata raw=" + len(rdata_buf) + "\n"
    dump = dump + "[section] .data raw=" + len(data_buf) + "\n"
    if typeof(labels) == "array" and len(labels) > 0 then
      for li = 0 to len(labels) - 1
        lbi = labels[li]
        if typeof(lbi) == "struct" and typeof(lbi.key) == "string" and typeof(lbi.value) == "int" then
          dump = dump + "[label] " + lbi.key + " " + lbi.value + "\n"
        end if
      end for
    end if
    wrdump = fs.writeAllText(_dump_labels_path, dump)
    if typeof(wrdump) == "error" then
      print "CompileError: writeAllText failed for label dump: " + _dump_labels_path
      return 2
    end if
  end if

  buf = text_buf
  if typeof(patch_file_recs) == "array" and len(patch_file_recs) > 0 then
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
      if ((ri + 1) % 8) == 0 then
        gc_collect()
      end if
      _heap_probe("link:patch_obj_" + (ri + 1))
    end for
  end if
  _heap_probe("link:patches_done")

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
  wr = fs.writeAllBytes(output_exe, exe)
  if typeof(wr) == "error" then
    msg = "writeAllBytes failed"
    if typeof(wr.message) == "string" then msg = wr.message end if
    print "CompileError: " + msg
    return 2
  end if

  print "OK: wrote " + output_exe + " (native x64 PE, MiniLang self-hosted compiler)"
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
  self_exe = _self_exe_path()
  if self_exe == "" then return -1 end if

  cmd = "call " + _cmd_quote_arg(self_exe)
  cmd = cmd + " " + _cmd_quote_arg(input_ml)
  cmd = cmd + " " + _cmd_quote_arg(output_exe)
  cmd = cmd + " --link-obj-dir " + _cmd_quote_arg(obj_dir)
  cmd = cmd + " --subsystem " + _subsystem_cli_name(subsystem)

  compiler_gc_limit = _compiler_gc_limit_from_config(runtime_config)
  if typeof(compiler_gc_limit) == "int" and compiler_gc_limit > 0 then
    cmd = cmd + " --gc-limit " + compiler_gc_limit
  end if
  if typeof(_dump_labels_path) == "string" and _dump_labels_path != "" then
    cmd = cmd + " --dump-labels " + _cmd_quote_arg(_dump_labels_path)
  end if

  print "Linking in fresh compiler process..."
  rc = _wsystem(cmd)
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
  mod_obj.data_labels = _mlo_strip_shared_runtime_data_labels(mod_obj.data_labels)
  mod_obj = _mlo_namespace_object(mod_obj, "objm_" + obj_index, true)
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
  label_id = mst.label_id
  mod_obj = 0
  mst = 0
  wr_mod = 0
  gc_collect()
  return [0, "", helper_union, module_obj_paths_b, label_id]
end function

function compile_to_exe_opts(input_ml, output_exe, include_dirs, keep_going, max_errors, runtime_config, call_profile, trace_calls, subsystem)
  global _dump_labels_path
  compiler_gc_limit = _compiler_gc_limit_from_config(runtime_config)
  gc_set_limit(compiler_gc_limit)
  _heap_probe("compile:start")
  if _mem_probe_enabled then
    runtime_config = _cfg_set(runtime_config, "cg_mem_probe", true)
  end if
  input_abs = _path_abspath(input_ml)
  if input_abs == "" then input_abs = input_ml end if
  load = _load_program_for_codegen(input_abs, include_dirs, keep_going, max_errors)
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

  extern_sigs = collect_extern_sigs(load.program)
  _heap_probe("compile:extern_sigs_done")
  _heap_probe("compile:before_new_codegen")
  cg = codegen.newCodegen(load.source, input_abs, load.aliases, extern_sigs, [])
  _heap_probe("compile:new_codegen_done")
  if typeof(cg) != "struct" or typeof(cg.state) != "struct" then
    print "CompileError: failed to initialize code generator"
    return 2
  end if

  cg.state.dbg_line_starts = load.sources
  cg.state.heap_config = runtime_config
  cg.state.call_profile = call_profile
  cg.state.trace_calls = trace_calls
  cg.state.is_windows_subsystem = (subsystem == 2)
  _heap_probe("compile:before_call_profile_metadata")
  cg = codegen.enable_call_profile_metadata(cg)
  _heap_probe("compile:call_profile_metadata_done")

  _heap_probe("compile:before_prepare_program")
  prep = codegen.prepare_program_for_objects(cg, load.program)
  if typeof(prep) != "array" or len(prep) < 3 then
    print "CompileError: failed to prepare object-code pipeline"
    return 2
  end if
  cg = prep[0]
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

  main_name = _find_main_name(st)
  helper_union = []
  if typeof(st.used_helpers) == "array" then helper_union = st.used_helpers end if
  module_obj_paths_b = t.arr_chunk_new(128)
  support_path = _tmp_obj_path(tmp_dir, "000", input_abs, "support")
  module_object_seq = 1
  module_fn_chunk_size = 2

  visited = load.visited
  if typeof(visited) != "array" or len(visited) <= 0 then
    visited = [input_abs]
  end if

  // Keep the merged AST rooted while module objects are emitted.  The object
  // pipeline still references function bodies through the codegen state; if the
  // original program root is dropped here, deeply nested expression nodes can be
  // collected and later reused as unrelated compiler objects.
  _heap_probe("compile:post_plan_gc")

  for mi = 0 to len(visited) - 1
    module_file = visited[mi]
    mrec = _module_init_rec_for_file(module_init_recs, module_file)
    if typeof(mrec) == "array" and len(mrec) >= 5 then
      entry_label = _coerce_name(mrec[2])
      mod_cg = codegen.clone_for_object(cg, true)
      if typeof(mod_cg) != "struct" or typeof(mod_cg.state) != "struct" then
        print "CompileError: failed to clone module codegen state"
        return 2
      end if
      mod_cg.state.label_id = cg.state.label_id
      mod_cg = codegen.emit_module_init_object(mod_cg, mrec)
      fin = _finish_module_mlo(tmp_dir, "" + module_object_seq, module_file, entry_label, mod_cg, cg.state, helper_union, module_obj_paths_b)
      if fin[0] != 0 then
        print "CompileError: " + fin[1]
        return fin[0]
      end if
      helper_union = fin[2]
      module_obj_paths_b = fin[3]
      cg.state.label_id = fin[4]
      module_object_seq = module_object_seq + 1
      mod_cg = 0
      fin = 0
      gc_collect()
    end if

    fn_entries = codegen.module_function_entries(cg, module_file)
    fn_start = 0
    while typeof(fn_entries) == "array" and fn_start < len(fn_entries)
      mod_cg = codegen.clone_for_object(cg, true)
      if typeof(mod_cg) != "struct" or typeof(mod_cg.state) != "struct" then
        print "CompileError: failed to clone module codegen state"
        return 2
      end if
      mod_cg.state.label_id = cg.state.label_id
      mod_cg = codegen.emit_module_function_entries(mod_cg, fn_entries, fn_start, module_fn_chunk_size)
      fin = _finish_module_mlo(tmp_dir, "" + module_object_seq, module_file, "", mod_cg, cg.state, helper_union, module_obj_paths_b)
      if fin[0] != 0 then
        print "CompileError: " + fin[1]
        return fin[0]
      end if
      helper_union = fin[2]
      module_obj_paths_b = fin[3]
      cg.state.label_id = fin[4]
      module_object_seq = module_object_seq + 1
      fn_start = fn_start + module_fn_chunk_size
      mod_cg = 0
      fin = 0
      gc_collect()
    end while

    if typeof(module_init_recs) == "array" and len(module_init_recs) > 0 then
      for ri = 0 to len(module_init_recs) - 1
        r = module_init_recs[ri]
        if typeof(r) != "array" or len(r) < 5 then continue end if
        if _path_eq(_coerce_name(r[0]), module_file) then
          r[1] = []
          module_init_recs[ri] = r
        end if
      end for
    end if
    if typeof(load.parsed_modules) == "struct" or typeof(load.parsed_modules) == "array" then
      pm = _parsed_module_get(load.parsed_modules, module_file)
      if typeof(pm) == "struct" then
        load.parsed_modules = _parsed_module_set(load.parsed_modules, module_file, "", [])
      end if
    end if
    // Module object emission creates large transient asm/rdata/patch arrays.
    // Drop those roots immediately; waiting several modules can exhaust the
    // 2GB runtime heap while self-compiling the compiler's codegen modules.
    mod_cg = 0
    mrec = 0
    fn_entries = 0
    pm = 0
    gc_collect()
    if ((mi + 1) % 4) == 0 then
      _heap_probe("compile:module_" + (mi + 1))
    end if
  end for

  cg.state.used_helpers = helper_union
  cg = codegen.emit_entry_object(cg, module_init_recs, max_call_args_main, main_name)
  cg = codegen.emit_extern_stubs(cg)
  cg = codegen.emit_used_helpers(cg)
  _heap_probe("compile:support_done")

  st = cg.state
  if typeof(st) != "struct" then
    print "CompileError: invalid support codegen state"
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

  support_obj = _mlo_from_state("support", input_abs, "__ml_entry", st)
  wr_sup = _write_mlo_file(support_path, support_obj)
  if typeof(wr_sup) == "error" then
    msg = "writeAllBytes failed"
    if typeof(wr_sup.message) == "string" then msg = wr_sup.message end if
    print "CompileError: " + msg + " (" + support_path + ")"
    return 2
  end if

  obj_paths = [support_path]
  module_obj_paths = t.arr_chunk_finish(module_obj_paths_b)
  if typeof(module_obj_paths) == "array" and len(module_obj_paths) > 0 then
    obj_paths = obj_paths + module_obj_paths
  end if

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
  support_obj = 0
  wr_sup = 0
  helper_union = []
  prep = 0
  st = 0
  cg = 0
  load = 0
  _heap_probe("compile:pre_link_gc")

  if _link_should_use_fresh_process(obj_paths) then
    gc_collect()
    fresh_link = _link_obj_dir_in_fresh_process(input_abs, tmp_dir, output_exe, subsystem, runtime_config)
    if fresh_link != -1 then return fresh_link end if
  end if
  return _link_mlo_files(obj_paths, output_exe, subsystem)
end function

function compile_to_exe(input_ml, output_exe)
  return compile_to_exe_opts(input_ml, output_exe, [], false, 20, [], false, false, 3)
end function

function link_obj_dir_to_exe(obj_dir, output_exe, subsystem)
  obj_paths = _collect_mlo_paths_from_dir(obj_dir)
  if typeof(obj_paths) == "error" then
    msg = "failed to enumerate object files"
    if typeof(obj_paths.message) == "string" then msg = obj_paths.message end if
    print "CompileError: " + msg
    return 2
  end if
  return _link_mlo_files(obj_paths, output_exe, subsystem)
end function

function run_cli(args)
  global _mem_probe_enabled
  global _dump_labels_path
  _mem_probe_enabled = _has_flag(args, "--mem-probe")
  _dump_labels_path = _get_flag_value(args, "--dump-labels")
  if len(args) < 2 then
    _usage()
    return 1
  end if

  inp = args[0]
  out_path = args[1]
  include_dirs = _collect_include_dirs(args)
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

  link_obj_dir = _get_flag_value(args, "--link-obj-dir")
  if link_obj_dir != "" then
    return link_obj_dir_to_exe(link_obj_dir, out_path, subsystem)
  end if

  return compile_to_exe_opts(inp, out_path, include_dirs, keep_going, max_errors, runtime_config, call_profile, trace_calls, subsystem)
end function
