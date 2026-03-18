package mlc.compiler
import std.fs as fs
import std.string as s
import mlc.frontend as frontend
import mlc.minilang_parser as parser
import mlc.codegen.codegen as codegen
import mlc.pe as pe
import mlc.tools as t
import mlc.asm as a

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
end struct

struct ModuleInfo
  path,
  package_name,
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

struct DeclCheckResult
  diagnostics,
  failed,
end struct

struct LoadProgramResult
  diagnostics,
  source,
  program,
  aliases,
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

_mem_probe_enabled = false

function _usage()
  print "MiniLang self-hosted compiler (bootstrap frontend)"
  print "Usage:"
  print "  mlc_win64.exe <input.ml> <output.exe> [compiler options]"
  print "Extra self-hosted checks:"
  print "  --self-frontcheck"
  print "  --self-frontcheck-keep-going"
  print "Debug:"
  print "  --mem-probe"
end function

function _startsWith(text, pref)
  if len(pref) > len(text) then return false end if
  for i = 0 to len(pref) - 1
    if text[i] != pref[i] then return false end if
  end for
  return true
end function

function _endsWith(text, suf)
  if len(suf) > len(text) then return false end if
  off = len(text) - len(suf)
  for i = 0 to len(suf) - 1
    if text[off + i] != suf[i] then return false end if
  end for
  return true
end function

function _array_contains(arr, value)
  if len(arr) <= 0 then return false end if
  for i = 0 to len(arr) - 1
    if arr[i] == value then return true end if
  end for
  return false
end function

function _containsDot(txt)
  if typeof(txt) != "string" then return false end if
  for i = 0 to len(txt) - 1
    if txt[i] == "." then return true end if
  end for
  return false
end function

function _last_segment_after_dot(txt)
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

function _to_int_or(defv, text)
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

function _path_eq(a, b)
  return _path_norm(a) == _path_norm(b)
end function

function _path_in(arr, value)
  if len(arr) <= 0 then return false end if
  for i = 0 to len(arr) - 1
    if _path_eq(arr[i], value) then return true end if
  end for
  return false
end function

function _append_unique_path(arr, value)
  if _path_in(arr, value) then return arr end if
  return arr +[value]
end function

function _is_abs_path(p)
  if typeof(p) != "string" then return false end if
  if len(p) >= 2 and p[1] == ":" then return true end if
  if len(p) >= 2 and p[0] == "\\" and p[1] == "\\" then return true end if
  if len(p) >= 1 and(p[0] == "/" or p[0] == "\\") then return true end if
  return false
end function

function _dirname(path)
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

function _node_pos(st)
  if typeof(st) != "struct" then return 0 end if
  if typeof(st._pos) == "int" then return st._pos end if
  return 0
end function

function _node_file(st, fallback)
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
  if len(modules) <= 0 then return "" end if
  for i = 0 to len(modules) - 1
    if _path_eq(modules[i].path, path) then
      return modules[i].package_name
    end if
  end for
  return ""
end function

function _module_set_package(modules, path, package_name)
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

function _alias_get(aliases, key)
  if len(aliases) <= 0 then return "" end if
  for i = 0 to len(aliases) - 1
    if aliases[i].key == key then return aliases[i].value end if
  end for
  return ""
end function

function _alias_set(aliases, key, value)
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
  if _startsWith(_path_norm(p), _path_norm(pref)) then
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

function _resolve_import(requested, base_dir, include_dirs)
  cands_chunks = []
  cands_tail = []
  if _is_abs_path(requested) then
    appa = t.arr_chunked_push(cands_chunks, cands_tail, ResolveCand(requested, "abs", ""), 16)
    cands_chunks = appa[0]
    cands_tail = appa[1]
  else
    appr = t.arr_chunked_push(cands_chunks, cands_tail, ResolveCand(fs.joinPath(base_dir, requested), "rel", base_dir), 16)
    cands_chunks = appr[0]
    cands_tail = appr[1]
    if len(include_dirs) > 0 then
      for i = 0 to len(include_dirs) - 1
        appi = t.arr_chunked_push(cands_chunks, cands_tail, ResolveCand(fs.joinPath(include_dirs[i], requested), "include", include_dirs[i]), 16)
        cands_chunks = appi[0]
        cands_tail = appi[1]
      end for
    end if
  end if
  cands = t.arr_chunked_finish(cands_chunks, cands_tail)

  tried =[]
  matches = []
  resolved = ""
  resolved_kind = ""
  resolved_root = ""

  if len(cands) > 0 then
    for i = 0 to len(cands) - 1
      cand = cands[i]
      tried = _append_unique_path(tried, cand.path)
      if fs.exists(cand.path) then
        if _path_in(matches, cand.path) == false then
          matches = matches +[cand.path]
          if resolved == "" then
            resolved = cand.path
            resolved_kind = cand.kind
            resolved_root = cand.root
          end if
        end if
      end if
    end for
  end if

  return ResolveResult(resolved, tried, matches, resolved_kind, resolved_root)
end function

function _stack_contains(stack, path)
  return _path_in(stack, path)
end function

function _visited_contains(visited, path)
  return _path_in(visited, path)
end function

function _module_visit(path, entry_path, include_dirs, stack, visited, modules, aliases, diags, keep_going, max_errors)
  if len(diags) >= max_errors then
    return FrontCheckResult(diags, visited, modules, aliases)
  end if

  if _stack_contains(stack, path) then
    // import cycles are tolerated at loader level
    return FrontCheckResult(diags, visited, modules, aliases)
  end if

  if _visited_contains(visited, path) then
    return FrontCheckResult(diags, visited, modules, aliases)
  end if

  if fs.exists(path) == false then
    diags = _add_diag(diags, "CompileError", path, 0, "Import file not found: " + path)
    return FrontCheckResult(diags, visited, modules, aliases)
  end if

  parsed = 0
  if keep_going then
    parsed = frontend.parse_program_keepgoing(path, max_errors)
  else
    parsed = frontend.parse_program(path)
  end if

  if typeof(parsed) != "struct" then
    diags = _add_diag(diags, "CompileError", path, 0, "frontend.parse_program returned non-struct")
    return FrontCheckResult(diags, visited, modules, aliases)
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
      return FrontCheckResult(diags, visited, modules, aliases)
    end if
    // keep-going mode: mark module as visited and continue with other files
    visited = _append_unique_path(visited, path)
    return FrontCheckResult(diags, visited, modules, aliases)
  end if

  program = parsed.program
  pkg = _declared_package(program)
  modules = _module_set_package(modules, path, pkg)

  if _path_eq(path, entry_path) == false then
    if typeof(program) == "array" and len(program) > 0 then
      for si = 0 to len(program) - 1
        cr = _check_decl_stmt(program[si], path, diags, keep_going, max_errors)
        diags = cr.diagnostics
        if cr.failed then
          if keep_going == false then
            return FrontCheckResult(diags, visited, modules, aliases)
          end if
          visited = _append_unique_path(visited, path)
          return FrontCheckResult(diags, visited, modules, aliases)
        end if
        if len(diags) >= max_errors then
          return FrontCheckResult(diags, visited, modules, aliases)
        end if
      end for
    end if
  end if

  stack2 = stack +[path]
  imports = _extract_imports(program)
  // Drop full AST early: below we only need import nodes.
  parsed.program = []
  program = []
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
          return FrontCheckResult(diags, visited, modules, aliases)
        end if
        continue
      end if

      rr = _resolve_import(req, _dirname(path), include_dirs)
      if rr.resolved == "" then
        diags = _add_diag_from_stmt(diags, "CompileError", st, path, "Import file not found: " + req)
        if keep_going == false then
          return FrontCheckResult(diags, visited, modules, aliases)
        end if
        continue
      end if
      if len(rr.matches) > 1 then
        diags = _add_diag_from_stmt(diags, "CompileError", st, path, "Ambiguous import: " + req)
        if keep_going == false then
          return FrontCheckResult(diags, visited, modules, aliases)
        end if
        continue
      end if

      sub = _module_visit(rr.resolved, entry_path, include_dirs, stack2, visited, modules, aliases, diags, keep_going, max_errors)
      diags = sub.diagnostics
      visited = sub.visited
      modules = sub.modules
      aliases = sub.aliases

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
          return FrontCheckResult(diags, visited, modules, aliases)
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
          return FrontCheckResult(diags, visited, modules, aliases)
        end if
      end if

      alias = ""
      if typeof(st.alias) == "string" then alias = st.alias end if
      if alias != "" then
        if alias == "try" or alias == "error" then
          diags = _add_diag_from_stmt(diags, "CompileError", st, path, "import alias '" + alias + "' is reserved")
          if keep_going == false then
            return FrontCheckResult(diags, visited, modules, aliases)
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
            return FrontCheckResult(diags, visited, modules, aliases)
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
            return FrontCheckResult(diags, visited, modules, aliases)
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
                  return FrontCheckResult(diags, visited, modules, aliases)
                end if
              end if
            end if
          end if
        end if
      end if
    end while
  end if

  visited = _append_unique_path(visited, path)
  return FrontCheckResult(diags, visited, modules, aliases)
end function

function _run_frontcheck(entry, include_dirs, keep_going, max_errors)
  dirs =[]
  dirs = _append_unique_path(dirs, _dirname(entry))
  if len(include_dirs) > 0 then
    for i = 0 to len(include_dirs) - 1
      dirs = _append_unique_path(dirs, include_dirs[i])
    end for
  end if
  return _module_visit(entry, entry, dirs,[], [],[], [],[], keep_going, max_errors)
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
    if typeof(it) != "struct" then continue end if
    dll = ""
    funcs = []
    if typeof(it.key) == "string" then dll = it.key end if
    if typeof(it.values) == "array" then funcs = it.values end if
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
    if typeof(v.name) == "string" then return v.name end if
    if typeof(v.value) == "string" then return v.value end if
  end if
  return "" + v
end function

function _st_file(st)
  if typeof(st) == "struct" and typeof(st._filename) == "string" then return st._filename end if
  return ""
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
  _heap_probe("load:start")
  check = _run_frontcheck(entry, include_dirs, keep_going, max_errors)
  _heap_probe("load:frontcheck_done")
  diags = check.diagnostics
  if len(diags) > 0 then
    return LoadProgramResult(diags, "",[], check.aliases)
  end if

  merged_chunks = []
  merged_chunks_tail = []
  entry_source = ""
  visited = check.visited
  if typeof(visited) != "array" or len(visited) <= 0 then
    visited =[entry]
  end if

  for i = 0 to len(visited) - 1
    path = visited[i]
    parsed = 0
    if keep_going then
      parsed = frontend.parse_program_keepgoing(path, max_errors)
    else
      parsed = frontend.parse_program(path)
    end if

    if typeof(parsed) != "struct" then
      diags = _add_diag(diags, "CompileError", path, 0, "frontend.parse_program returned non-struct")
      if keep_going == false then
        return LoadProgramResult(diags, "", _merge_array_chunks_balanced(t.arr_chunked_finish(merged_chunks, merged_chunks_tail)), check.aliases)
      end if
      if len(diags) >= max_errors then
        return LoadProgramResult(diags, "", _merge_array_chunks_balanced(t.arr_chunked_finish(merged_chunks, merged_chunks_tail)), check.aliases)
      end if
      continue
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

      parsed.program = []
      parsed.source = ""
      if i % 4 == 0 then gc_collect() end if

      if keep_going == false then
        return LoadProgramResult(diags, "", _merge_array_chunks_balanced(t.arr_chunked_finish(merged_chunks, merged_chunks_tail)), check.aliases)
      end if
      if len(diags) >= max_errors then
        return LoadProgramResult(diags, "", _merge_array_chunks_balanced(t.arr_chunked_finish(merged_chunks, merged_chunks_tail)), check.aliases)
      end if
      continue
    end if

    if _path_eq(path, entry) then
      if typeof(parsed.source) == "string" then entry_source = parsed.source end if
    end if
    part = _filter_non_import_stmts(parsed.program)
    if typeof(part) == "array" and len(part) > 0 then
      appm = t.arr_chunked_push(merged_chunks, merged_chunks_tail, part, 16)
      merged_chunks = appm[0]
      merged_chunks_tail = appm[1]
    end if
    parsed.program = []
    parsed.source = ""
    part = []
    if i % 4 == 0 then gc_collect() end if
    if i % 16 == 0 then _heap_probe("load:file_" + i) end if
  end for

  if entry_source == "" and fs.exists(entry) then
    src = fs.readAllText(entry)
    if typeof(src) == "string" then
      entry_source = frontend.normalize_code_for_tokenizer(src)
    end if
  end if

  merged_lists = t.arr_chunked_finish(merged_chunks, merged_chunks_tail)
  merged_chunks = []
  merged_chunks_tail = []
  merged = _merge_array_chunks_balanced(merged_lists)
  merged_lists = []
  visited = []
  gc_collect()
  _heap_probe("load:done")
  return LoadProgramResult(diags, entry_source, merged, check.aliases)
end function

function compile_to_exe_opts(input_ml, output_exe, include_dirs, keep_going, max_errors, runtime_config, call_profile, trace_calls, subsystem)
  _heap_probe("compile:start")
  if _mem_probe_enabled then
    runtime_config = _cfg_set(runtime_config, "cg_mem_probe", true)
  end if
  print "[phase] load_program"
  load = _load_program_for_codegen(input_ml, include_dirs, keep_going, max_errors)
  print "[phase] load_program_done"
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
  cg = codegen.newCodegen(load.source, input_ml, load.aliases, extern_sigs, [])
  if typeof(cg) == "struct" and typeof(cg.state) == "struct" then
    cg.state.heap_config = runtime_config
    cg.state.call_profile = call_profile
    cg.state.trace_calls = trace_calls
    cg.state.is_windows_subsystem = (subsystem == 2)
  end if
  print "[phase] codegen_emit"
  cg = codegen.emit_program(cg, load.program)
  print "[phase] codegen_emit_done"
  _heap_probe("compile:codegen_done")
  load.program = []
  load.source = ""
  gc_collect()
  _heap_probe("compile:post_load_release")
  st = cg.state
  cg = 0
  gc_collect()
  _heap_probe("compile:post_cg_release")

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
  gc_collect()
  _heap_probe("compile:buffers_compacted")

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
  print "[phase] pe_layout_done"

  imports = _imports_to_pe_imports(st.imports)
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
  print "[phase] pe_import_done"
  _heap_probe("compile:pe_ready")

  text_rva = p.sections[0].virt_addr
  rdata_rva = p.sections[1].virt_addr
  data_rva = p.sections[2].virt_addr
  bss_rva = p.sections[3].virt_addr
  p.entry_rva = text_rva

  labels_chunks = []
  labels_tail = []
  asm_labels = a.get_labels(st.asm)
  if typeof(asm_labels) == "array" and len(asm_labels) > 0 then
    for i = 0 to len(asm_labels) - 1
      lb = asm_labels[i]
      if typeof(lb) == "struct" and typeof(lb.name) == "string" and typeof(lb.pos) == "int" then
        app_lb = t.arr_chunked_push(labels_chunks, labels_tail, StrIntPair(lb.name, text_rva + lb.pos), 1024)
        labels_chunks = app_lb[0]
        labels_tail = app_lb[1]
      end if
    end for
  end if
  if typeof(st.rdata.labels) == "array" and len(st.rdata.labels) > 0 then
    for i = 0 to len(st.rdata.labels) - 1
      lb2 = st.rdata.labels[i]
      if typeof(lb2) == "struct" and typeof(lb2.name) == "string" and typeof(lb2.offset) == "int" then
        app_lb2 = t.arr_chunked_push(labels_chunks, labels_tail, StrIntPair(lb2.name, rdata_rva + lb2.offset), 1024)
        labels_chunks = app_lb2[0]
        labels_tail = app_lb2[1]
      end if
    end for
  end if
  if typeof(st.data.labels) == "array" and len(st.data.labels) > 0 then
    for i = 0 to len(st.data.labels) - 1
      lb3 = st.data.labels[i]
      if typeof(lb3) == "struct" and typeof(lb3.name) == "string" and typeof(lb3.offset) == "int" then
        app_lb3 = t.arr_chunked_push(labels_chunks, labels_tail, StrIntPair(lb3.name, data_rva + lb3.offset), 1024)
        labels_chunks = app_lb3[0]
        labels_tail = app_lb3[1]
      end if
    end for
  end if
  if typeof(st.bss.labels) == "array" and len(st.bss.labels) > 0 then
    for i = 0 to len(st.bss.labels) - 1
      lb4 = st.bss.labels[i]
      if typeof(lb4) == "struct" and typeof(lb4.name) == "string" and typeof(lb4.offset) == "int" then
        app_lb4 = t.arr_chunked_push(labels_chunks, labels_tail, StrIntPair(lb4.name, bss_rva + lb4.offset), 1024)
        labels_chunks = app_lb4[0]
        labels_tail = app_lb4[1]
      end if
    end for
  end if
  if typeof(idr.iat_symbols) == "array" and len(idr.iat_symbols) > 0 then
    for i = 0 to len(idr.iat_symbols) - 1
      it = idr.iat_symbols[i]
      if typeof(it) != "struct" then continue end if
      if typeof(it.func) != "string" or typeof(it.rva) != "int" then continue end if
      app_lb5 = t.arr_chunked_push(labels_chunks, labels_tail, StrIntPair("iat_" + it.func, it.rva), 1024)
      labels_chunks = app_lb5[0]
      labels_tail = app_lb5[1]
      if typeof(it.dll) == "string" then
        app_lb6 = t.arr_chunked_push(labels_chunks, labels_tail, StrIntPair("iat_" + _dll_base(it.dll) + "_" + it.func, it.rva), 1024)
        labels_chunks = app_lb6[0]
        labels_tail = app_lb6[1]
      end if
    end for
  end if
  labels = t.arr_chunked_finish(labels_chunks, labels_tail)

  buf = text_buf
  patches = a.get_patches(st.asm)
  if typeof(patches) == "array" and len(patches) > 0 then
    for i = 0 to len(patches) - 1
      pt = patches[i]
      if typeof(pt) != "struct" then continue end if
      if typeof(pt.target) != "string" or typeof(pt.pos) != "int" then continue end if

      trg = _label_get(labels, pt.target, -1)
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

  tx = p.sections[0]
  tx.data = buf
  p.sections[0] = tx

  exe = pe.build(p)
  print "[phase] pe_build_done"
  _heap_probe("compile:pe_built")
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

function compile_to_exe(input_ml, output_exe)
  return compile_to_exe_opts(input_ml, output_exe, [], false, 20, [], false, false, 3)
end function

function run_cli(args)
  global _mem_probe_enabled
  _mem_probe_enabled = _has_flag(args, "--mem-probe")
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
  call_profile = _has_flag(args, "--profile-calls")
  trace_calls = _has_flag(args, "--trace-calls")
  ss = _get_subsystem(args)
  if ss[0] == false then
    print "CompileError: invalid subsystem (use console/cui or windows/window/gui)"
    return 2
  end if
  subsystem = ss[1]

  return compile_to_exe_opts(inp, out_path, include_dirs, keep_going, max_errors, runtime_config, call_profile, trace_calls, subsystem)
end function
