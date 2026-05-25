package mlc.codegen.codegen_core
import mlc.asm as a
import mlc.data as d
import mlc.tools as t
import mlc.constants as c
import std.string as s
import mlc.codegen.codegen_scope as scope
import mlc.codegen.codegen_runtime as rt
import mlc.codegen.codegen_memory as mem
import mlc.codegen.codegen_builtins_alloc as bal

struct CgState
  source,
  filename,
  import_aliases,
  extern_sigs,
  extern_structs,
  heap_config,
  call_profile,
  trace_calls,
  mem_probe,
  imports,
  asm,
  data,
  bss,
  rdata,
  var_slots,
  break_stack,
  struct_fields,
  struct_ids,
  enum_variants,
  enum_ids,
  value_enum_values,
  reserved_identifiers,
  label_id,
  used_helpers,
  emitted_helpers,
  scope_stack,
  scope_declared,
  binding_id,
  global_slots,
  globals,
  in_function,
  func_globals,
  func_global_map,
  function_locals,
  current_qname_prefix,
  current_file_prefix,
  file_prefix_map,
  typename_struct_by_id,
  typename_struct_by_qname,
  typename_enum_by_id,
  typename_enum_by_qname,
  user_functions,
  nested_user_functions,
  struct_methods,
  struct_static_methods,
  function_global_labels,
  struct_global_labels,
  builtin_specs,
  builtin_global_labels,
  extern_global_labels,
  extern_stub_labels,
  function_static_obj_labels,
  struct_static_obj_labels,
  builtin_static_obj_labels,
  extern_static_obj_labels,
  diagnostics,
  call_total_count,
  call_indirect_count,
  callprof_entries,
  callprof_index,
  callprof_name_labels,
  callprof_n,
  is_windows_subsystem,
  func_ret_label,
  func_frame_size,
  errprop_suppression,
  dbg_line_starts,
  expr_temp_base,
  expr_temp_top,
  current_fn_boxed_names,
  current_fn_env_index,
  current_env_root_off,
  scope_index_stack,
  scope_declared_index_stack,
  func_global_map_index,
  user_function_index,
  function_codegen_name_map,
  analysis_mode,
  qualify_cache,
  struct_fields_index,
  struct_ids_index,
  enum_variants_index,
  enum_ids_index,
  struct_methods_index,
  struct_static_methods_index,
  extern_sig_index,
  import_alias_index,
  call_temp_base,
  expr_temp_max,
  _current_root_rec_off,
  _current_root_static_qwords,
  _expr_temp_reg_order,
  _expr_temp_reg_live,
  _expr_temp_reg_live_by_reg,
  _expr_temp_reg_reserved,
  _cold_block_stack,
  _inline_param_stack,
  _inline_call_stack,
  ext_widebuf_labels,
  decl_site_bindings,
  function_local_ids,
  _module_init_active,
  _module_init_active_file,
  _global_owner_file,
  _module_init_status_labels,
end struct

struct NamedArray
  key,
  values,
end struct

struct NamedInt
  key,
  value,
end struct

struct NamedAny
  key,
  value,
end struct

struct ExprValueTemp
  off,
  reg,
  dirty,
end struct

function _append_unique(vals, v)
  if typeof(vals) != "array" then return [v] end if
  if len(vals) > 0 then
    for i = 0 to len(vals) - 1
      if vals[i] == v then return vals end if
    end for
  end if
  return vals +[v]
end function

function _expr_temp_named_get(entries, key, defaultv)
  if typeof(entries) != "array" or len(entries) <= 0 then return defaultv end if
  for i = 0 to len(entries) - 1
    it = entries[i]
    if typeof(it) == "struct" and it.key == key then return it.value end if
  end for
  return defaultv
end function

function _expr_temp_named_set(entries, key, value)
  if typeof(entries) != "array" then entries = [] end if
  if len(entries) > 0 then
    for i = 0 to len(entries) - 1
      it = entries[i]
      if typeof(it) == "struct" and it.key == key then
        entries[i] = NamedAny(key, value)
        return entries
      end if
    end for
  end if
  return entries +[NamedAny(key, value)]
end function

function _expr_temp_named_remove(entries, key)
  if typeof(entries) != "array" or len(entries) <= 0 then return [] end if
  outv = []
  for i = 0 to len(entries) - 1
    it = entries[i]
    if typeof(it) == "struct" and it.key == key then continue end if
    outv = outv +[it]
  end for
  return outv
end function

function _expr_temp_live_by_reg_get(state, reg)
  return _expr_temp_named_get(state._expr_temp_reg_live_by_reg, reg, 0)
end function

function _expr_temp_live_by_reg_set(state, reg, tmp)
  state._expr_temp_reg_live_by_reg = _expr_temp_named_set(state._expr_temp_reg_live_by_reg, reg, tmp)
  return state
end function

function _expr_temp_live_by_reg_remove(state, reg)
  state._expr_temp_reg_live_by_reg = _expr_temp_named_remove(state._expr_temp_reg_live_by_reg, reg)
  return state
end function

function _expr_temp_reserved_get(state, reg)
  return _expr_temp_named_get(state._expr_temp_reg_reserved, reg, 0)
end function

function _expr_temp_reserved_set(state, reg, value)
  state._expr_temp_reg_reserved = _expr_temp_named_set(state._expr_temp_reg_reserved, reg, value)
  return state
end function

function _expr_temp_reserved_dec(state, reg)
  cnt = _expr_temp_reserved_get(state, reg)
  if typeof(cnt) != "int" then cnt = 0 end if
  if cnt <= 1 then
    state._expr_temp_reg_reserved = _expr_temp_named_remove(state._expr_temp_reg_reserved, reg)
  else
    state._expr_temp_reg_reserved = _expr_temp_named_set(state._expr_temp_reg_reserved, reg, cnt - 1)
  end if
  return state
end function

function _sync_expr_temp_root_count(state)
  rec_off = state._current_root_rec_off
  if typeof(rec_off) != "int" or rec_off < 0 then return state end if
  base_qwords = state._current_root_static_qwords
  if typeof(base_qwords) != "int" then base_qwords = 0 end if
  dyn_qwords = state.expr_temp_top
  if typeof(dyn_qwords) != "int" then dyn_qwords = 0 end if
  dyn_qwords = dyn_qwords / 8
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", rec_off + 16, base_qwords + dyn_qwords, true)
  return state
end function

function _sync_asm_before_call_live(state)
  if typeof(state.asm) == "struct" then
    state.asm.before_call_live_temps = state._expr_temp_reg_live
  end if
  return state
end function

function _imports_get_funcs(imports, dll)
  if typeof(imports) != "array" or len(imports) <= 0 then return [] end if
  for i = 0 to len(imports) - 1
    it = imports[i]
    if typeof(it) == "struct" and it.key == dll then
      if typeof(it.values) == "array" then return it.values end if
      return []
    end if
  end for
  return []
end function

function _imports_set_funcs(imports, dll, funcs)
  if typeof(imports) != "array" then imports = [] end if
  for i = 0 to len(imports) - 1
    it = imports[i]
    if typeof(it) == "struct" and it.key == dll then
      imports[i] = NamedArray(dll, funcs)
      return imports
    end if
  end for
  return imports +[NamedArray(dll, funcs)]
end function

function _seed_rdata(cg)
  cg.rdata = d.rdata_add_bytes(cg.rdata, "nl", bytes("\n"))
  cg.rdata = d.rdata_add_str_nl(cg.rdata, "true_s", "true", true)
  cg.rdata = d.rdata_add_str_nl(cg.rdata, "false_s", "false", true)
  cg.rdata = d.rdata_add_str_nl(cg.rdata, "true_nn", "true", false)
  cg.rdata = d.rdata_add_str_nl(cg.rdata, "false_nn", "false", false)
  cg.rdata = d.rdata_add_str_nl(cg.rdata, "uns_nn", "<unsupported>", false)
  cg.rdata = d.rdata_add_str_nl(cg.rdata, "array_nn", "<array>", false)
  cg.rdata = d.rdata_add_bytes(cg.rdata, "uns_s", bytes("<unsupported>\n"))

  cg.rdata = d.rdata_add_obj_string(cg.rdata, "obj_true", "true")
  cg.rdata = d.rdata_add_obj_string(cg.rdata, "obj_false", "false")
  cg.rdata = d.rdata_add_obj_string(cg.rdata, "obj_uns", "<unsupported>")
  cg.rdata = d.rdata_add_obj_string(cg.rdata, "obj_array", "<array>")
  cg.rdata = d.rdata_add_obj_string(cg.rdata, "obj_bytes", "<bytes>")
  cg.rdata = d.rdata_add_obj_string(cg.rdata, "obj_void", "void")
  cg.rdata = d.rdata_add_obj_string(cg.rdata, "obj_empty_string", "")

  cg.rdata = d.rdata_pad_align(cg.rdata, 16)
  char_pages = t.byte_pages_new()
  for i = 0 to 255
    char_pages = t.byte_pages_append(char_pages, t.u32(c.OBJ_STRING))
    char_pages = t.byte_pages_append(char_pages, t.u32(1))
    char_pages = t.byte_pages_append(char_pages, bytes(1, i))
    char_pages = t.byte_pages_append(char_pages, bytes(1, 0))
    char_pages = t.byte_pages_append(char_pages, bytes(6, 0))
  end for
  char_objs = t.byte_pages_to_bytes(char_pages)
  cg.rdata = d.rdata_add_bytes(cg.rdata, "obj_char_table", char_objs)

  cg.rdata = d.rdata_add_obj_string(cg.rdata, "obj_type_int", "int")
  cg.rdata = d.rdata_add_obj_string(cg.rdata, "obj_type_bool", "bool")
  cg.rdata = d.rdata_add_obj_string(cg.rdata, "obj_type_void", "void")
  cg.rdata = d.rdata_add_obj_string(cg.rdata, "obj_type_enum", "enum")
  cg.rdata = d.rdata_add_obj_string(cg.rdata, "obj_type_string", "string")
  cg.rdata = d.rdata_add_obj_string(cg.rdata, "obj_type_array", "array")
  cg.rdata = d.rdata_add_obj_string(cg.rdata, "obj_type_bytes", "bytes")
  cg.rdata = d.rdata_add_obj_string(cg.rdata, "obj_type_float", "float")
  cg.rdata = d.rdata_add_obj_string(cg.rdata, "obj_type_function", "function")
  cg.rdata = d.rdata_add_obj_string(cg.rdata, "obj_type_struct", "struct")
  cg.rdata = d.rdata_add_obj_string(cg.rdata, "obj_type_error", "error")
  cg.rdata = d.rdata_add_obj_string(cg.rdata, "obj_type_unknown", "unknown")

  cg.rdata = d.rdata_add_bytes(cg.rdata, "hex_tbl", bytes("0123456789abcdef"))
  cg.rdata = d.rdata_add_bytes(cg.rdata, "lbrack", bytes("["))
  cg.rdata = d.rdata_add_bytes(cg.rdata, "rbrack", bytes("]"))
  cg.rdata = d.rdata_add_bytes(cg.rdata, "comma_sp", bytes(", "))
  cg.rdata = d.rdata_add_str_nl(cg.rdata, "err_occ_prefix", "Error occured: no=", false)
  cg.rdata = d.rdata_add_str_nl(cg.rdata, "err_occ_mid", " message=", false)
  cg.rdata = d.rdata_add_str_nl(cg.rdata, "err_occ_at", "  at ", false)
  cg.rdata = d.rdata_add_str_nl(cg.rdata, "err_occ_colon", ":", false)
  cg.rdata = d.rdata_add_str_nl(cg.rdata, "err_occ_in", " in ", false)
  cg.rdata = d.rdata_add_str_nl(cg.rdata, "printbuf_short_msg", "ERROR: print buffer (= 16192 bytes) too small to print given string", true)
  cg.rdata = d.rdata_add_str_nl(cg.rdata, "oom_msg", "ERROR: out of memory (MiniLang heap exhausted)", true)
  return cg
end function

function _seed_data(cg)
  cg.data = d.data_add_u64(cg.data, "dbg_loc_script", t.enc_void())
  cg.data = d.data_add_u64(cg.data, "dbg_loc_func", t.enc_void())
  cg.data = d.data_add_u64(cg.data, "dbg_loc_line", t.enc_int(0))
  cg.data = d.data_add_u32(cg.data, "cpu_has_avx2", 0)

  // Keep heap/GC control globals early in .data so accidental scratch-buffer
  // overruns do not corrupt allocator state.
  cg = mem.ensure_gc_data(cg)

  pad = 0
  if typeof(cg.data.used) == "int" then
    pad = (8 - (cg.data.used % 8)) % 8
  end if
  if pad > 0 then
    cg.data = d.data_add_bytes(cg.data, "_pad_obj_empty_bytes", bytes(pad, 0))
  end if
  cg.data = d.data_add_bytes(cg.data, "obj_empty_bytes", t.u32(c.OBJ_BYTES) + t.u32(0) + bytes(8, 0))

  cg.data = d.data_add_u32(cg.data, "bytesWritten", 0)
  cg.data = d.data_add_u32(cg.data, "bytesRead", 0)
  cg.data = d.data_add_u32(cg.data, "ml_argc", 0)
  cg.data = d.data_add_u64(cg.data, "ml_argvw", 0)
  cg.data = d.data_add_u64(cg.data, "printSrcPtr", 0)
  cg.data = d.data_add_u32(cg.data, "printSrcLen", 0)

  cg.data = d.data_add_bytes(cg.data, "intbuf", bytes(32, 0))
  // Alias label at current offset (end of intbuf) for fn_int_to_dec output pointer math.
  cg.data = d.data_add_bytes(cg.data, "intbuf_end", bytes(0))
  cg.data = d.data_add_bytes(cg.data, "floatbuf", bytes(64, 0))
  cg.data = d.data_add_bytes(cg.data, "widebuf", bytes(8096, 0))
  cg.data = d.data_add_bytes(cg.data, "widebuf1", bytes(8096, 0))
  cg.data = d.data_add_bytes(cg.data, "widebuf2", bytes(8096, 0))
  cg.data = d.data_add_bytes(cg.data, "widebuf3", bytes(8096, 0))
  cg.data = d.data_add_bytes(cg.data, "inbuf", bytes(4096, 0))
  return cg
end function

function cg_core_new(source, filename, import_aliases, extern_sigs, extern_structs)
  base_imports =[
  NamedArray("kernel32.dll", ["GetStdHandle", "ReadFile", "WriteFile", "WriteConsoleW", "MultiByteToWideChar", "SetConsoleOutputCP", "FreeConsole", "ExitProcess", "VirtualAlloc", "VirtualFree", "GetCommandLineW", "LocalFree", "WideCharToMultiByte"]),
  NamedArray("msvcrt.dll", ["_gcvt", "fmod"]),
  NamedArray("shell32.dll", ["CommandLineToArgvW"])
]
  cg = CgState(
  source,
  filename,
  import_aliases,
  extern_sigs,
  extern_structs,
  [],
  false,
  false,
  false,
  base_imports,
  a.newAsmBuilder(),
  d.newDataBuilder(),
  d.newBssBuilder(),
  d.newRDataBuilder(),
  [],
  [],
  [NamedArray("error", ["code", "message", "script", "func", "line"])],
  [NamedInt("error", 0xE0000001)],
  [],
  [],
  [],
  ["try", "error"],
  0,
  [],
  [],
  [[]],
  [[]],
  0,
  [],
  [],
  false,
  [],
  [],
  [],
  "",
  "",
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  0,
  0,
  [],
  [],
  [],
  0,
  false,
  "",
  0,
  0,
  [],
  0,
  0,
  [],
  [],
  0,
  [],
  [],
  t.fastmap_new(64),
  t.fastmap_new(256),
  t.fastmap_new(256),
  false,
  t.fastmap_new(1024),
  t.fastmap_new(256),
  t.fastmap_new(256),
  t.fastmap_new(256),
  t.fastmap_new(256),
  t.fastmap_new(256),
  t.fastmap_new(256),
  t.fastmap_new(256),
  t.fastmap_new(128),
  0x30,
  0x400,
  -1,
  0,
  ["r12", "r13", "r14"],
  [],
  [],
  [],
  [],
  [],
  [],
  ["widebuf", "widebuf1", "widebuf2", "widebuf3"],
  t.fastmap_new(128),
  t.fastmap_new(64),
  false,
  "",
  [],
  []
  )
  cg = _seed_rdata(cg)
  cg = _seed_data(cg)
  cg = _add_extern_imports(cg)
  return cg
end function

function cg_core_init(state)
  return state
end function

// ------------------------------------------------------------
// Python CodegenCore API compatibility surface
// ------------------------------------------------------------

function __init__(state)
  return cg_core_init(state)
end function

function _pretty_script(state, p)
  if typeof(p) != "string" or p == "" then return "<script>" end if
  rp = s.replaceAll(p, "\\", "/")
  rr = ""
  if typeof(state) == "struct" and typeof(state.filename) == "string" and state.filename != "" then
    rr = s.replaceAll(state.filename, "\\", "/")
    slash = -1
    for i = len(rr) - 1 to 0
      if rr[i] == "/" then
        slash = i
        break
      end if
    end for
    if slash >= 0 then
      rr = s.substr(rr, 0, slash)
    else
      rr = ""
    end if
  end if
  if rr != "" and s.startsWith(rp, rr + "/") then
    rel = s.substr(rp, len(rr) + 1, len(rp) - len(rr) - 1)
    if rel != "" then return rel end if
  end if
  return rp
end function

function _track_call_label(state, lbl)
  if typeof(lbl) != "string" or lbl == "" then return state end if
  if _is_internal_helper_label(lbl) == false then return state end if
  state.used_helpers = _append_unique(state.used_helpers, lbl)
  return state
end function

function in_function(state)
  return state.in_function
end function

function new_label_id(state)
  state.label_id = state.label_id + 1
  return state.label_id
end function

function add_import_symbol(state, dll, sym)
  if typeof(dll) != "string" or dll == "" then return state end if
  if typeof(sym) != "string" or sym == "" then return state end if
  funcs = _imports_get_funcs(state.imports, dll)
  funcs = _append_unique(funcs, sym)
  state.imports = _imports_set_funcs(state.imports, dll, funcs)
  return state
end function

function _import_string_gt(a, b)
  if typeof(a) != "string" or typeof(b) != "string" then return false end if
  ab = bytes(a)
  bb = bytes(b)
  an = len(ab)
  bn = len(bb)
  n = an
  if bn < n then n = bn end if
  for i = 0 to n - 1
    av = ab[i]
    bv = bb[i]
    if av == bv then continue end if
    return av > bv
  end for
  return an > bn
end function

function _import_pair_gt(a, b)
  if typeof(a) != "array" or len(a) < 2 then return false end if
  if typeof(b) != "array" or len(b) < 2 then return false end if
  ad = a[0]
  asym = a[1]
  bd = b[0]
  bsym = b[1]
  if typeof(ad) != "string" or typeof(asym) != "string" then return false end if
  if typeof(bd) != "string" or typeof(bsym) != "string" then return false end if
  if ad == bd then
    return _import_string_gt(asym, bsym)
  end if
  return _import_string_gt(ad, bd)
end function

function _sort_import_pairs(pairs)
  if typeof(pairs) != "array" or len(pairs) <= 1 then return pairs end if
  arr = pairs
  n = len(arr)
  for i = 0 to n - 2
    for j = 0 to n - 2 - i
      if _import_pair_gt(arr[j], arr[j + 1]) then
        tmp = arr[j]
        arr[j] = arr[j + 1]
        arr[j + 1] = tmp
      end if
    end for
  end for
  return arr
end function

function _add_extern_imports(state)
  xs = state.extern_sigs
  if typeof(xs) != "array" or len(xs) <= 0 then return state end if
  pairs = []
  for i = 0 to len(xs) - 1
    it = xs[i]
    if typeof(it) != "struct" then continue end if
    dll = ""
    sym = ""
    if typeof(it.dll) == "string" then dll = it.dll end if
    if typeof(it.symbol_name) == "string" then sym = it.symbol_name end if
    if sym == "" and typeof(it.name) == "string" then sym = it.name end if
    if sym == "" and typeof(it.qname) == "string" then
      qn = it.qname
      dot = -1
      for di = 0 to len(qn) - 1
        if qn[di] == "." then dot = di end if
      end for
      if dot >= 0 and dot + 1 < len(qn) then
        sym = ""
        for si = dot + 1 to len(qn) - 1
          sym = sym + qn[si]
        end for
      end if
    end if
    if dll != "" and sym != "" then
      pairs = pairs + [[s.toLowerAscii(dll), sym]]
    end if
  end for
  pairs = _sort_import_pairs(pairs)
  for i = 0 to len(pairs) - 1
    it = pairs[i]
    if typeof(it) != "array" or len(it) < 2 then continue end if
    state = add_import_symbol(state, it[0], it[1])
  end for
  return state
end function

function _pos(node)
  if typeof(node) == "struct" then
    p = try(node._pos)
    if typeof(p) == "int" then return p end if
  end if
  return 0
end function

function _source_for_dbg_filename(state, filename)
  if typeof(filename) == "string" and filename != "" then
    sources = state.dbg_line_starts
    if typeof(sources) == "array" and len(sources) > 0 then
      for i = 0 to len(sources) - 1
        it = sources[i]
        if typeof(it) == "struct" and typeof(it.key) == "string" and it.key == filename then
          return it.value
        end if
      end for
    end if
  end if
  source = state.source
  if typeof(source) == "string" then return source end if
  return ""
end function

function _line_from_pos(state, pos, filename)
  source = _source_for_dbg_filename(state, filename)
  if typeof(pos) != "int" then return 0 end if
  if typeof(source) == "array" then
    nstarts = len(source)
    if nstarts <= 0 then return 1 end if
    if pos < 0 then pos = 0 end if
    lo = 0
    hi = nstarts - 1
    best = 0
    while lo <= hi
      mid = lo + ((hi - lo) >> 1)
      start = source[mid]
      if typeof(start) != "int" then start = 0 end if
      if start <= pos then
        best = mid
        lo = mid + 1
      else
        hi = mid - 1
      end if
    end while
    return best + 1
  end if
  if typeof(source) != "string" then return 0 end if
  n = len(source)
  if pos < 0 then pos = 0 end if
  if pos > n then pos = n end if
  line = 1
  if pos <= 0 then return line end if
  for i = 0 to pos - 1
    if source[i] == "\n" then line = line + 1 end if
  end for
  return line
end function

function _flatten_member_chain_as_qualname(expr)
  if typeof(expr) != "struct" then return 0 end if
  if expr.node_kind == "Var" and typeof(expr.name) == "string" then
    return expr.name
  end if
  if expr.node_kind == "Member" and typeof(expr.name) == "string" then
    left = _flatten_member_chain_as_qualname(expr.target)
    if typeof(left) != "string" or left == "" then return 0 end if
    return left + "." + expr.name
  end if
  return 0
end function

function _apply_import_alias(state, qname)
  if typeof(qname) != "string" then return qname end if
  dot = -1
  for i = 0 to len(qname) - 1
    if qname[i] == "." then
      dot = i
      break
    end if
  end for
  head = qname
  tail = ""
  if dot >= 0 then
    head = ""
    if dot > 0 then
      for hi = 0 to dot - 1
        head = head + qname[hi]
      end for
    end if
    tail = ""
    if dot + 1 < len(qname) then
      for ti = dot + 1 to len(qname) - 1
        tail = tail + qname[ti]
      end for
    end if
  end if

  ia = state.import_aliases
  if typeof(ia) == "array" and len(ia) > 0 then
    for i = 0 to len(ia) - 1
      it = ia[i]
      if typeof(it) == "struct" and it.key == head and typeof(it.value) == "string" and it.value != "" then
        if tail == "" then return it.value end if
        return it.value + "." + tail
      end if
    end for
  end if
  return qname
end function

function _current_file_package_prefix(state)
  if typeof(state.current_file_prefix) == "string" then return state.current_file_prefix end if
  return ""
end function

function _current_function_prefix(state)
  if typeof(state.current_qname_prefix) == "string" and state.current_qname_prefix != "" then
    return state.current_qname_prefix
  end if
  return _current_file_package_prefix(state)
end function

function _qualify_identifier(state, name, node, kind)
  if typeof(name) != "string" then return name end if
  has_dot = false
  for i = 0 to len(name) - 1
    if name[i] == "." then
      has_dot = true
      break
    end if
  end for
  if has_dot then return _apply_import_alias(state, name) end if
  pref = _current_function_prefix(state)
  if typeof(pref) == "string" and pref != "" then
    return pref + name
  end if
  return _apply_import_alias(state, name)
end function

function alloc_expr_temps(state, size)
  sz = size
  if typeof(sz) != "int" then sz = 0 end if
  if sz <= 0 then return 0 end if
  sz = t.align_up(sz, 8)

  top = state.expr_temp_top
  if typeof(top) != "int" then top = 0 end if
  base = state.expr_temp_base
  if typeof(base) != "int" then base = 0 end if
  maxv = state.expr_temp_max
  if typeof(maxv) != "int" then maxv = 0 end if

  off = base + top
  top2 = top + sz
  if top2 > maxv then
    state.diagnostics = state.diagnostics + ["Expression temp overflow (increase expr_temp_max)"]
    return 0
  end if

  state.expr_temp_top = top2
  off2 = off
  while off2 < off + sz
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", off2, t.enc_void(), true)
    off2 = off2 + 8
  end while
  state = _sync_expr_temp_root_count(state)
  return off
end function

function free_expr_temps(state, size)
  sz = size
  if typeof(sz) != "int" then sz = 0 end if
  if sz <= 0 then return state end if
  sz = t.align_up(sz, 8)

  top = state.expr_temp_top
  if typeof(top) != "int" then top = 0 end if
  if top <= 0 then
    state.expr_temp_top = 0
    state = _sync_expr_temp_root_count(state)
    return state
  end if
  if sz > top then sz = top end if

  base = state.expr_temp_base
  if typeof(base) != "int" then base = 0 end if
  start = base + top - sz

  off = start
  while off < start + sz
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", off, t.enc_void(), true)
    off = off + 8
  end while

  state.expr_temp_top = top - sz
  if state.expr_temp_top <= 0 then state.expr_temp_top = 0 end if
  state = _sync_expr_temp_root_count(state)
  return state
end function

function release_expr_temps(state, size)
  sz = size
  if typeof(sz) != "int" then sz = 0 end if
  if sz <= 0 then return state end if
  sz = t.align_up(sz, 8)

  top = state.expr_temp_top
  if typeof(top) != "int" then top = 0 end if
  if top <= 0 then
    state.expr_temp_top = 0
    state = _sync_expr_temp_root_count(state)
    return state
  end if
  if sz > top then sz = top end if

  state.expr_temp_top = top - sz
  if state.expr_temp_top <= 0 then state.expr_temp_top = 0 end if
  state = _sync_expr_temp_root_count(state)
  return state
end function

function _spill_live_expr_value_temps(state)
  if typeof(state._expr_temp_reg_live) != "array" or len(state._expr_temp_reg_live) <= 0 then return state end if
  for i = 0 to len(state._expr_temp_reg_live) - 1
    tmp = state._expr_temp_reg_live[i]
    if typeof(tmp) != "struct" then continue end if
    if typeof(tmp.reg) != "string" or tmp.reg == "" then continue end if
    if typeof(tmp.dirty) != "bool" or tmp.dirty == false then continue end if
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp.off, tmp.reg)
    tmp.dirty = false
  end for
  return state
end function

function reserve_expr_temp_regs(state, regs)
  if typeof(regs) != "array" or len(regs) <= 0 then return state end if
  for i = 0 to len(regs) - 1
    reg = regs[i]
    if typeof(reg) != "string" or reg == "" then continue end if
    live = _expr_temp_live_by_reg_get(state, reg)
    if typeof(live) == "struct" then
      if typeof(live.dirty) == "bool" and live.dirty then
        state.asm = a.mov_membase_disp_r64(state.asm, "rsp", live.off, reg)
        live.dirty = false
      end if
      live.reg = ""
      out_live = []
      if typeof(state._expr_temp_reg_live) == "array" and len(state._expr_temp_reg_live) > 0 then
        for j = 0 to len(state._expr_temp_reg_live) - 1
          it = state._expr_temp_reg_live[j]
          if typeof(it) == "struct" and typeof(it.off) == "int" and it.off == live.off then continue end if
          out_live = out_live +[it]
        end for
      end if
      state._expr_temp_reg_live = out_live
      state = _expr_temp_live_by_reg_remove(state, reg)
    end if
    cnt = _expr_temp_reserved_get(state, reg)
    if typeof(cnt) != "int" then cnt = 0 end if
    state = _expr_temp_reserved_set(state, reg, cnt + 1)
  end for
  state = _sync_asm_before_call_live(state)
  return state
end function

function release_expr_temp_regs(state, regs)
  if typeof(regs) != "array" or len(regs) <= 0 then return state end if
  for i = 0 to len(regs) - 1
    reg = regs[i]
    if typeof(reg) != "string" or reg == "" then continue end if
    state = _expr_temp_reserved_dec(state, reg)
  end for
  return state
end function

function alloc_expr_value_temp(state, prefer_reg)
  if typeof(prefer_reg) != "bool" then prefer_reg = true end if
  off = alloc_expr_temps(state, 8)
  reg = ""
  if off <= 0 then
    reg = ""
  end if
  if off > 0 and prefer_reg and typeof(state._expr_temp_reg_order) == "array" and len(state._expr_temp_reg_order) > 0 then
    for i = 0 to len(state._expr_temp_reg_order) - 1
      cand = state._expr_temp_reg_order[i]
      if typeof(cand) != "string" or cand == "" then continue end if
      if typeof(_expr_temp_live_by_reg_get(state, cand)) == "struct" then continue end if
      if _expr_temp_reserved_get(state, cand) > 0 then continue end if
      reg = cand
      break
    end for
  end if
  tmp = ExprValueTemp(off, reg, false)
  if reg != "" then
    state._expr_temp_reg_live = _append_unique(state._expr_temp_reg_live, tmp)
    state = _expr_temp_live_by_reg_set(state, reg, tmp)
  end if
  state = _sync_asm_before_call_live(state)
  return tmp
end function

function expr_value_temp_store_rax(state, tmp)
  if typeof(tmp) != "struct" then return state end if
  if typeof(tmp.reg) == "string" and tmp.reg != "" then
    state.asm = a.mov_r64_r64(state.asm, tmp.reg, "rax")
    tmp.dirty = true
    return state
  end if
  state.asm = a.mov_rsp_disp32_rax(state.asm, tmp.off)
  return state
end function

function expr_value_temp_store_reg(state, tmp, reg)
  if typeof(tmp) != "struct" then return state end if
  if typeof(reg) != "string" then reg = "" end if
  if reg == "" then return state end if
  if typeof(tmp.reg) == "string" and tmp.reg != "" then
    state.asm = a.mov_r64_r64(state.asm, tmp.reg, reg)
    tmp.dirty = true
    return state
  end if
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp.off, reg)
  return state
end function

function expr_value_temp_load(state, dst, tmp)
  if typeof(tmp) != "struct" then return state end if
  if typeof(dst) != "string" then dst = "rax" end if
  if typeof(tmp.reg) == "string" and tmp.reg != "" then
    if dst != tmp.reg then
      state.asm = a.mov_r64_r64(state.asm, dst, tmp.reg)
    end if
    return state
  end if
  state.asm = a.mov_r64_membase_disp(state.asm, dst, "rsp", tmp.off)
  return state
end function

function expr_value_temp_offset(state, tmp)
  if typeof(tmp) != "struct" then return 0 end if
  if typeof(tmp) == "struct" and typeof(tmp.reg) == "string" and tmp.reg != "" and tmp.dirty then
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp.off, tmp.reg)
    tmp.dirty = false
  end if
  return tmp.off
end function

function free_expr_value_temp(state, tmp)
  if typeof(tmp) != "struct" then return state end if
  out_live = []
  if typeof(state._expr_temp_reg_live) == "array" and len(state._expr_temp_reg_live) > 0 then
    for i = 0 to len(state._expr_temp_reg_live) - 1
      it = state._expr_temp_reg_live[i]
      if typeof(it) == "struct" and typeof(it.off) == "int" and it.off == tmp.off then continue end if
      out_live = out_live +[it]
    end for
  end if
  state._expr_temp_reg_live = out_live
  if typeof(tmp.reg) == "string" and tmp.reg != "" then
    state = _expr_temp_live_by_reg_remove(state, tmp.reg)
    tmp.reg = ""
    tmp.dirty = false
  end if
  state = _sync_asm_before_call_live(state)
  state = free_expr_temps(state, 8)
  return state
end function

function push_cold_block_scope(state)
  if typeof(state._cold_block_stack) != "array" then state._cold_block_stack = [] end if
  state._cold_block_stack = state._cold_block_stack +[t.arr_chunk_new(64)]
  return state
end function

function _cold_block_frame_items(frame)
  if typeof(frame) == "struct" and typeof(frame.chunks) == "array" then
    return t.arr_chunk_finish(frame)
  end if
  if typeof(frame) == "array" then return frame end if
  return []
end function

function pop_cold_block_scope(state)
  if typeof(state._cold_block_stack) != "array" or len(state._cold_block_stack) <= 0 then return [] end if
  outv = _cold_block_frame_items(state._cold_block_stack[len(state._cold_block_stack) - 1])
  if len(state._cold_block_stack) <= 1 then
    state._cold_block_stack = []
  else
    nxt = []
    for i = 0 to len(state._cold_block_stack) - 2
      nxt = nxt +[state._cold_block_stack[i]]
    end for
    state._cold_block_stack = nxt
  end if
  return outv
end function

function defer_cold_block(state, label, emitter)
  if typeof(state._cold_block_stack) != "array" or len(state._cold_block_stack) <= 0 then return false end if
  if typeof(label) != "string" or label == "" then return false end if
  frame = state._cold_block_stack[len(state._cold_block_stack) - 1]
  if typeof(frame) == "struct" and typeof(frame.chunks) == "array" then
    frame = t.arr_chunk_push(frame, NamedAny(label, emitter))
  else
    b = t.arr_chunk_new(64)
    if typeof(frame) == "array" and len(frame) > 0 then
      for i = 0 to len(frame) - 1
        b = t.arr_chunk_push(b, frame[i])
      end for
    end if
    frame = t.arr_chunk_push(b, NamedAny(label, emitter))
  end if
  state._cold_block_stack[len(state._cold_block_stack) - 1] = frame
  return true
end function

function emit_deferred_cold_blocks(state)
  if typeof(state._cold_block_stack) != "array" or len(state._cold_block_stack) <= 0 then return state end if
  frame_idx = len(state._cold_block_stack) - 1
  blocks = _cold_block_frame_items(state._cold_block_stack[frame_idx])
  if typeof(blocks) != "array" or len(blocks) <= 0 then return state end if
  for bi = 0 to len(blocks) - 1
    it = blocks[bi]
    if typeof(it) == "struct" then
      state.asm = a.mark(state.asm, it.key)
      if typeof(it.value) == "function" then
        state = it.value(state)
      end if
    end if
  end for
  state._cold_block_stack[frame_idx] = t.arr_chunk_new(64)
  return state
end function

function ensure_var(state, name)
  if typeof(name) != "string" then return "" end if
  return name
end function

function core_error(state, msg, node)
  if typeof(msg) != "string" then msg = "" + msg end if
  state.diagnostics = state.diagnostics + [msg]
  return msg
end function

function emit_dbg_line(state, node)
  ln = 0
  if typeof(node) == "struct" then
    maybe_ln = try(node._line)
    if typeof(maybe_ln) == "int" then
      ln = maybe_ln
    end if
    if ln <= 0 then
      maybe_pos = try(node._pos)
      maybe_fn = try(node._filename)
      if typeof(maybe_pos) == "int" then
        ln = _line_from_pos(state, maybe_pos, maybe_fn)
      end if
    end if
  end if
  if ln > 0 then
    state.asm = a.mov_rax_imm64(state.asm, t.enc_int(ln))
    state.asm = a.mov_rip_qword_rax(state.asm, "dbg_loc_line")
  end if
  return state
end function

function emit_load_var(state, name, node)
  return scope.emit_load_var_scoped(state, name)
end function

function emit_store_var(state, name, node)
  return scope.emit_store_var_scoped(state, name, node)
end function

function emit_writefile(state, buf_label, length)
  state.asm = a.lea_rdx_rip(state.asm, buf_label)
  state.asm = a.mov_r8d_imm32(state.asm, length)
  return emit_writefile_ptr_len(state)
end function

function emit_writefile_ptr_len(state)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rbx")
  state.asm = a.lea_r9_rip(state.asm, "bytesWritten")
  state.asm = a.mov_qword_ptr_rsp20_rax_zero(state.asm)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WriteFile")
  state.asm = a.call_rax(state.asm)
  return state
end function

function emit_writefile_ptr_len_stderr(state)
  state.asm = a.mov_r64_r64(state.asm, "r10", "rdx")
  state.asm = a.mov_r32_r32(state.asm, "r11d", "r8d")
  state.asm = a.mov_rcx_imm32(state.asm, -12)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_GetStdHandle")
  state.asm = a.call_rax(state.asm)

  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "r10")
  state.asm = a.mov_r32_r32(state.asm, "r8d", "r11d")
  state.asm = a.lea_r9_rip(state.asm, "bytesWritten")
  state.asm = a.mov_qword_ptr_rsp20_rax_zero(state.asm)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WriteFile")
  state.asm = a.call_rax(state.asm)
  return state
end function

function emit_writefile_stderr(state, buf_label, length)
  state.asm = a.lea_rdx_rip(state.asm, buf_label)
  state.asm = a.mov_r8d_imm32(state.asm, length)
  return emit_writefile_ptr_len_stderr(state)
end function

function emit_normalize_xmm0_to_value(state)
  lid = new_label_id(state)
  l_int = "norm_int_" + lid
  l_try_immf = "norm_try_immf_" + lid
  l_box = "norm_box_" + lid
  l_end = "norm_end_" + lid

  state.asm = a.cvttsd2si_r64_xmm(state.asm, "rax", "xmm0")
  state.asm = a.cvtsi2sd_xmm_r64(state.asm, "xmm1", "rax")
  state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm1")
  state.asm = a.jcc(state.asm, "e", l_int)
  state.asm = a.jmp(state.asm, l_try_immf)
  state.asm = a.mark(state.asm, l_int)
  state.asm = a.shl_r64_imm8(state.asm, "rax", 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
  state.asm = a.jmp(state.asm, l_end)
  state.asm = a.mark(state.asm, l_try_immf)
  state.asm = a.cvtsd2ss_xmm_xmm(state.asm, "xmm2", "xmm0")
  state.asm = a.cvtss2sd_xmm_xmm(state.asm, "xmm3", "xmm2")
  state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm3")
  state.asm = a.jcc(state.asm, "ne", l_box)
  state.asm = a.jcc(state.asm, "p", l_box)
  state.asm = a.movd_r32_xmm(state.asm, "eax", "xmm2")
  state.asm = a.shl_r64_imm8(state.asm, "rax", 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_FLOAT)
  state.asm = a.jmp(state.asm, l_end)
  state.asm = a.mark(state.asm, l_box)
  state.asm = a.call(state.asm, "fn_box_float")
  state.asm = a.mark(state.asm, l_end)
  return state
end function

function emit_force_xmm0_to_float_value(state)
  lid = new_label_id(state)
  l_box = "forcef_box_" + lid
  l_end = "forcef_end_" + lid
  state.asm = a.cvtsd2ss_xmm_xmm(state.asm, "xmm2", "xmm0")
  state.asm = a.cvtss2sd_xmm_xmm(state.asm, "xmm3", "xmm2")
  state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm3")
  state.asm = a.jcc(state.asm, "ne", l_box)
  state.asm = a.jcc(state.asm, "p", l_box)
  state.asm = a.movd_r32_xmm(state.asm, "eax", "xmm2")
  state.asm = a.shl_r64_imm8(state.asm, "rax", 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_FLOAT)
  state.asm = a.jmp(state.asm, l_end)
  state.asm = a.mark(state.asm, l_box)
  state.asm = a.call(state.asm, "fn_box_float")
  state.asm = a.mark(state.asm, l_end)
  return state
end function

function emit_to_double_xmm(state, xmm, fail_label)
  lid = new_label_id(state)
  l_int = "todbl_int_" + lid
  l_immf = "todbl_immf_" + lid
  l_ptr = "todbl_ptr_" + lid
  l_done = "todbl_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.and_r64_imm(state.asm, "rdx", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_INT)
  state.asm = a.jcc(state.asm, "e", l_int)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_FLOAT)
  state.asm = a.jcc(state.asm, "e", l_immf)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "e", l_ptr)
  state.asm = a.jmp(state.asm, fail_label)

  state.asm = a.mark(state.asm, l_int)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.sar_r64_imm8(state.asm, "rcx", 3)
  if xmm == 1 or xmm == "xmm1" then
    state.asm = a.cvtsi2sd_xmm_r64(state.asm, "xmm1", "rcx")
  else
    state.asm = a.cvtsi2sd_xmm_r64(state.asm, "xmm0", "rcx")
  end if
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_immf)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.shr_r64_imm8(state.asm, "rcx", 3)
  if xmm == 1 or xmm == "xmm1" then
    state.asm = a.movq_xmm_r64(state.asm, "xmm1", "rcx")
    state.asm = a.cvtss2sd_xmm_xmm(state.asm, "xmm1", "xmm1")
  else
    state.asm = a.movq_xmm_r64(state.asm, "xmm0", "rcx")
    state.asm = a.cvtss2sd_xmm_xmm(state.asm, "xmm0", "xmm0")
  end if
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_ptr)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FLOAT)
  state.asm = a.jcc(state.asm, "ne", fail_label)
  if xmm == 1 or xmm == "xmm1" then
    state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm1", "rax", 8)
  else
    state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm0", "rax", 8)
  end if
  state.asm = a.mark(state.asm, l_done)
  return state
end function

function emit_jmp_if_false_rax(state, false_label)
  lid = new_label_id(state)
  l_int = "truthy_int_" + lid
  l_bool = "truthy_bool_" + lid
  l_immf = "truthy_immf_" + lid
  l_ptr = "truthy_ptr_" + lid
  l_checklen = "truthy_checklen_" + lid
  l_float = "truthy_float_" + lid
  l_end = "truthy_end_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)

  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
  state.asm = a.jcc(state.asm, "e", l_int)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_BOOL)
  state.asm = a.jcc(state.asm, "e", l_bool)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_FLOAT)
  state.asm = a.jcc(state.asm, "e", l_immf)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "e", l_ptr)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_VOID)
  state.asm = a.jcc(state.asm, "e", false_label)
  state.asm = a.jmp(state.asm, l_end)

  state.asm = a.mark(state.asm, l_int)
  state.asm = a.cmp_rax_imm8(state.asm, t.enc_int(0))
  state.asm = a.jcc(state.asm, "e", false_label)
  state.asm = a.jmp(state.asm, l_end)

  state.asm = a.mark(state.asm, l_bool)
  state.asm = a.test_rax_imm32(state.asm, 8)
  state.asm = a.jcc(state.asm, "z", false_label)
  state.asm = a.jmp(state.asm, l_end)

  state.asm = a.mark(state.asm, l_immf)
  state = emit_to_double_xmm(state, 0, false_label)
  state.asm = a.xorpd_xmm_xmm(state.asm, "xmm1", "xmm1")
  state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm1")
  state.asm = a.jcc(state.asm, "e", false_label)
  state.asm = a.jmp(state.asm, l_end)

  state.asm = a.mark(state.asm, l_ptr)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FLOAT)
  state.asm = a.jcc(state.asm, "e", l_float)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "e", l_checklen)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
  state.asm = a.jcc(state.asm, "e", l_checklen)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY_IMM)
  state.asm = a.jcc(state.asm, "e", l_checklen)
  state.asm = a.jmp(state.asm, l_end)

  state.asm = a.mark(state.asm, l_float)
  state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm0", "rax", 8)
  state.asm = a.xorpd_xmm_xmm(state.asm, "xmm1", "xmm1")
  state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm1")
  state.asm = a.jcc(state.asm, "e", false_label)
  state.asm = a.jmp(state.asm, l_end)

  state.asm = a.mark(state.asm, l_checklen)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 4)
  state.asm = a.test_r32_r32(state.asm, "edx", "edx")
  state.asm = a.jcc(state.asm, "z", false_label)
  state.asm = a.jmp(state.asm, l_end)

  state.asm = a.mark(state.asm, l_end)
  return state
end function

function emit_struct_field_index_dispatch(state, field)
  return 0
end function

function emit_struct_field_dispatch(state, field)
  return 0
end function

function reset_helper_tracking(state)
  state.used_helpers = []
  state.emitted_helpers = []
  state.asm = a.clear_calls(state.asm)
  state.asm.tracked_helpers = []
  return state
end function

function _starts_with(text, prefix)
  if typeof(text) != "string" then return false end if
  if typeof(prefix) != "string" then return false end if
  if len(prefix) <= 0 then return true end if
  if len(text) < len(prefix) then return false end if
  for i = 0 to len(prefix) - 1
    if text[i] != prefix[i] then return false end if
  end for
  return true
end function

function _arr_contains(arr, value)
  if typeof(arr) != "array" or len(arr) <= 0 then return false end if
  for i = 0 to len(arr) - 1
    if arr[i] == value then return true end if
  end for
  return false
end function

function _str_less_ascii(a, b)
  if typeof(a) != "string" then a = "" + a end if
  if typeof(b) != "string" then b = "" + b end if
  ab = bytes(a)
  bb = bytes(b)
  na = len(ab)
  nb = len(bb)
  n = na
  if nb < n then n = nb end if
  for i = 0 to n - 1
    av = ab[i]
    bv = bb[i]
    if av < bv then return true end if
    if av > bv then return false end if
  end for
  return na < nb
end function

function _is_internal_helper_label(lbl)
  if _starts_with(lbl, "fn_") == false then return false end if
  if _starts_with(lbl, "fn_user_") then return false end if
  if _starts_with(lbl, "fn_extern_") then return false end if
  return true
end function

function _helper_supported(lbl)
  if lbl == "fn_cpu_init" then return true end if
  if lbl == "fn_int_to_dec" then return true end if
  if lbl == "fn_strlen" then return true end if
  if lbl == "fn_alloc" then return true end if
  if lbl == "fn_init_argvw" then return true end if
  if lbl == "fn_build_args" then return true end if
  if lbl == "fn_incref" then return true end if
  if lbl == "fn_decref" then return true end if
  if lbl == "fn_input" then return true end if
  if lbl == "fn_toNumber" then return true end if
  if lbl == "fn_toFloat" then return true end if
  if lbl == "fn_typeof" then return true end if
  if lbl == "fn_typeName" then return true end if
  if lbl == "fn_unhandled_error_exit" then return true end if
  if lbl == "fn_heap_count" then return true end if
  if lbl == "fn_heap_bytes_used" then return true end if
  if lbl == "fn_heap_bytes_committed" then return true end if
  if lbl == "fn_heap_bytes_reserved" then return true end if
  if lbl == "fn_heap_free_bytes" then return true end if
  if lbl == "fn_heap_free_blocks" then return true end if
  if lbl == "fn_heap_grow" then return true end if
  if lbl == "fn_gc_collect" then return true end if
  if lbl == "fn_mem_eq_bytes" then return true end if
  if lbl == "fn_bytes_hash" then return true end if
  if lbl == "fn_string_hash" then return true end if
  if lbl == "fn_bytes_startswith" then return true end if
  if lbl == "fn_bytes_endswith" then return true end if
  if lbl == "fn_bytes_indexof" then return true end if
  if lbl == "fn_bytes_lastindexof" then return true end if
  if lbl == "fn_bytes_compare" then return true end if
  if lbl == "fn_scan_nul_bytes" then return true end if
  if lbl == "fn_scan_byte2_bytes" then return true end if
  if lbl == "fn_scan_nul_wchars" then return true end if
  if lbl == "fn_copy_bytes" then return true end if
  if lbl == "fn_fill_bytes" then return true end if
  if lbl == "fn_fill_qwords" then return true end if
  if lbl == "fn_box_float" then return true end if
  if lbl == "fn_value_to_string" then return true end if
  if lbl == "fn_str_eq" then return true end if
  if lbl == "fn_string_slice" then return true end if
  if lbl == "fn_string_indexof" then return true end if
  if lbl == "fn_string_lastindexof" then return true end if
  if lbl == "fn_string_startswith" then return true end if
  if lbl == "fn_string_endswith" then return true end if
  if lbl == "fn_string_repeat" then return true end if
  if lbl == "fn_string_ltrim_ascii" then return true end if
  if lbl == "fn_string_rtrim_ascii" then return true end if
  if lbl == "fn_string_trim_ascii" then return true end if
  if lbl == "fn_string_is_blank_ascii" then return true end if
  if lbl == "fn_string_reverse" then return true end if
  if lbl == "fn_string_to_lower_ascii" then return true end if
  if lbl == "fn_string_to_upper_ascii" then return true end if
  if lbl == "fn_string_eq_ignore_case_ascii" then return true end if
  if lbl == "fn_string_join" then return true end if
  if lbl == "fn_val_eq" then return true end if
  if lbl == "fn_add_string" then return true end if
  if lbl == "fn_add_array" then return true end if
  if lbl == "fn_bytes_alloc" then return true end if
  if lbl == "fn_add_bytes" then return true end if
  if lbl == "fn_bytes_eq" then return true end if
  if lbl == "fn_decode" then return true end if
  if lbl == "fn_decodeZ" then return true end if
  if lbl == "fn_decode16Z" then return true end if
  if lbl == "fn_hex" then return true end if
  if lbl == "fn_fromHex" then return true end if
  if lbl == "fn_slice" then return true end if
  if lbl == "fn_callStats" then return true end if
  if lbl == "fn_builtin_len" then return true end if
  if lbl == "fn_builtin_input" then return true end if
  if lbl == "fn_builtin_copyBytes" then return true end if
  if lbl == "fn_builtin_copyStringBytes" then return true end if
  if lbl == "fn_builtin_fillBytes" then return true end if
  if lbl == "fn_builtin_gc_collect" then return true end if
  if lbl == "fn_builtin_gc_set_limit" then return true end if
  return false
end function

function _emit_helper_by_label_group0(state, lbl)
  if lbl == "fn_cpu_init" then return rt.emit_cpu_init_function(state) end if
  if lbl == "fn_alloc" then return mem.emit_alloc_function(state) end if
  if lbl == "fn_heap_grow" then return mem.emit_heap_grow_function(state) end if
  if lbl == "fn_gc_collect" then return mem.emit_gc_collect_function(state) end if
  if lbl == "fn_copy_bytes" then return rt.emit_copy_bytes_function(state) end if
  if lbl == "fn_fill_bytes" then return rt.emit_fill_bytes_function(state) end if
  if lbl == "fn_fill_qwords" then return rt.emit_fill_qwords_function(state) end if
  if lbl == "fn_mem_eq_bytes" then return rt.emit_mem_eq_bytes_function(state) end if
  if lbl == "fn_bytes_hash" then return rt.emit_bytes_hash_function(state) end if
  if lbl == "fn_string_hash" then return rt.emit_string_hash_function(state) end if
  return state
end function

function _emit_helper_by_label_group1(state, lbl)
  if lbl == "fn_bytes_startswith" then return rt.emit_bytes_startswith_function(state) end if
  if lbl == "fn_bytes_endswith" then return rt.emit_bytes_endswith_function(state) end if
  if lbl == "fn_bytes_indexof" then return rt.emit_bytes_indexof_function(state) end if
  if lbl == "fn_bytes_lastindexof" then return rt.emit_bytes_lastindexof_function(state) end if
  if lbl == "fn_bytes_compare" then return rt.emit_bytes_compare_function(state) end if
  if lbl == "fn_str_eq" then return rt.emit_string_eq_function(state) end if
  if lbl == "fn_string_slice" then return bal.emit_string_slice_function(state) end if
  if lbl == "fn_string_indexof" then return bal.emit_string_indexof_function(state) end if
  if lbl == "fn_string_lastindexof" then return bal.emit_string_lastindexof_function(state) end if
  if lbl == "fn_string_startswith" then return bal.emit_string_startswith_function(state) end if
  return state
end function

function _emit_helper_by_label_group2(state, lbl)
  if lbl == "fn_string_endswith" then return bal.emit_string_endswith_function(state) end if
  if lbl == "fn_string_repeat" then return bal.emit_string_repeat_function(state) end if
  if lbl == "fn_string_ltrim_ascii" then return bal.emit_string_ltrim_ascii_function(state) end if
  if lbl == "fn_string_rtrim_ascii" then return bal.emit_string_rtrim_ascii_function(state) end if
  if lbl == "fn_string_trim_ascii" then return bal.emit_string_trim_ascii_function(state) end if
  if lbl == "fn_string_is_blank_ascii" then return bal.emit_string_is_blank_ascii_function(state) end if
  if lbl == "fn_string_reverse" then return bal.emit_string_reverse_function(state) end if
  if lbl == "fn_string_to_lower_ascii" then return bal.emit_string_to_lower_ascii_function(state) end if
  if lbl == "fn_string_to_upper_ascii" then return bal.emit_string_to_upper_ascii_function(state) end if
  if lbl == "fn_string_eq_ignore_case_ascii" then return bal.emit_string_eq_ignore_case_ascii_function(state) end if
  return state
end function

function _emit_helper_by_label_group3(state, lbl)
  if lbl == "fn_string_join" then return bal.emit_string_join_function(state) end if
  if lbl == "fn_bytes_eq" then return bal.emit_bytes_eq_function(state) end if
  if lbl == "fn_box_float" then return bal.emit_box_float_function(state) end if
  if lbl == "fn_value_to_string" then return bal.emit_value_to_string_function(state) end if
  if lbl == "fn_add_string" then return bal.emit_string_add_function(state) end if
  if lbl == "fn_add_array" then return bal.emit_array_add_function(state) end if
  if lbl == "fn_add_bytes" then return bal.emit_bytes_add_function(state) end if
  if lbl == "fn_toNumber" then return rt.emit_toNumber_function(state) end if
  if lbl == "fn_toFloat" then return rt.emit_toFloat_function(state) end if
  if lbl == "fn_typeof" then return rt.emit_typeof_function(state) end if
  return state
end function

function _emit_helper_by_label_group4(state, lbl)
  if lbl == "fn_typeName" then return rt.emit_typeName_function(state) end if
  if lbl == "fn_int_to_dec" then return rt.emit_int_to_dec_function(state) end if
  if lbl == "fn_strlen" then return rt.emit_strlen_function(state) end if
  if lbl == "fn_decode" then return bal.emit_decode_function(state) end if
  if lbl == "fn_decodeZ" then return bal.emit_decodeZ_function(state) end if
  if lbl == "fn_decode16Z" then return bal.emit_decode16Z_function(state) end if
  if lbl == "fn_hex" then return bal.emit_hex_function(state) end if
  if lbl == "fn_fromHex" then return bal.emit_fromHex_function(state) end if
  if lbl == "fn_slice" then return bal.emit_slice_function(state) end if
  if lbl == "fn_builtin_len" then return rt.emit_builtin_len_function(state) end if
  return state
end function

function _emit_helper_by_label_group5(state, lbl)
  if lbl == "fn_builtin_input" then return rt.emit_builtin_input_function(state) end if
  if lbl == "fn_builtin_copyBytes" then return rt.emit_builtin_copyBytes_function(state) end if
  if lbl == "fn_builtin_copyStringBytes" then return rt.emit_builtin_copyStringBytes_function(state) end if
  if lbl == "fn_builtin_fillBytes" then return rt.emit_builtin_fillBytes_function(state) end if
  if lbl == "fn_builtin_gc_collect" then return rt.emit_builtin_gc_collect_function(state) end if
  if lbl == "fn_builtin_gc_set_limit" then return rt.emit_builtin_gc_set_limit_function(state) end if
  if lbl == "fn_build_args" then return rt.emit_build_args_function(state) end if
  if lbl == "fn_init_argvw" then return rt.emit_init_argvw_function(state) end if
  if lbl == "fn_incref" then return mem.emit_incref_function(state) end if
  if lbl == "fn_decref" then return mem.emit_decref_function(state) end if
  return state
end function

function _emit_helper_by_label_group6(state, lbl)
  if lbl == "fn_callStats" then return rt.emit_callStats_function(state) end if
  if lbl == "fn_heap_count" then return mem.emit_heap_count_function(state) end if
  if lbl == "fn_heap_bytes_used" then return mem.emit_heap_bytes_used_function(state) end if
  if lbl == "fn_heap_bytes_committed" then return mem.emit_heap_bytes_committed_function(state) end if
  if lbl == "fn_heap_bytes_reserved" then return mem.emit_heap_bytes_reserved_function(state) end if
  if lbl == "fn_heap_free_bytes" then return mem.emit_heap_free_bytes_function(state) end if
  if lbl == "fn_heap_free_blocks" then return mem.emit_heap_free_blocks_function(state) end if
  if lbl == "fn_unhandled_error_exit" then return rt.emit_unhandled_error_exit_function(state) end if
  return state
end function

function _emit_helper_by_label_other(state, lbl)
  if lbl == "fn_input" then return bal.emit_input_function(state) end if
  if lbl == "fn_scan_nul_bytes" then return rt.emit_scan_nul_bytes_function(state) end if
  if lbl == "fn_scan_byte2_bytes" then return rt.emit_scan_byte2_bytes_function(state) end if
  if lbl == "fn_scan_nul_wchars" then return rt.emit_scan_nul_wchars_function(state) end if
  if lbl == "fn_val_eq" then return rt.emit_value_eq_function(state) end if
  if lbl == "fn_bytes_alloc" then return bal.emit_bytes_alloc_function(state) end if
  return state
end function

function _emit_helper_by_label(state, lbl)
  rank = _helper_rank(lbl)
  if rank < 10 then return _emit_helper_by_label_group0(state, lbl) end if
  if rank < 20 then return _emit_helper_by_label_group1(state, lbl) end if
  if rank < 30 then return _emit_helper_by_label_group2(state, lbl) end if
  if rank < 40 then return _emit_helper_by_label_group3(state, lbl) end if
  if rank < 50 then return _emit_helper_by_label_group4(state, lbl) end if
  if rank < 60 then return _emit_helper_by_label_group5(state, lbl) end if
  if rank < 1048576 then return _emit_helper_by_label_group6(state, lbl) end if
  return _emit_helper_by_label_other(state, lbl)
end function

function _helper_rank(lbl)
  ordered = [
    "fn_cpu_init", "fn_alloc", "fn_heap_grow", "fn_gc_collect", "fn_copy_bytes", "fn_fill_bytes",
    "fn_fill_qwords", "fn_mem_eq_bytes", "fn_bytes_hash", "fn_string_hash", "fn_bytes_startswith",
    "fn_bytes_endswith", "fn_bytes_indexof", "fn_bytes_lastindexof", "fn_bytes_compare", "fn_str_eq",
    "fn_string_slice", "fn_string_indexof", "fn_string_lastindexof", "fn_string_startswith",
    "fn_string_endswith", "fn_string_repeat", "fn_string_ltrim_ascii", "fn_string_rtrim_ascii",
    "fn_string_trim_ascii", "fn_string_is_blank_ascii", "fn_string_reverse", "fn_string_to_lower_ascii",
    "fn_string_to_upper_ascii", "fn_string_eq_ignore_case_ascii", "fn_string_join", "fn_bytes_eq",
    "fn_add_string", "fn_add_array", "fn_add_bytes", "fn_value_to_string", "fn_box_float", "fn_toNumber",
    "fn_toFloat",
    "fn_typeof", "fn_typeName", "fn_int_to_dec", "fn_strlen", "fn_decode", "fn_decodeZ", "fn_decode16Z", "fn_hex", "fn_fromHex",
    "fn_slice", "fn_builtin_len", "fn_builtin_input", "fn_builtin_copyBytes", "fn_builtin_copyStringBytes", "fn_builtin_fillBytes",
    "fn_builtin_gc_collect", "fn_builtin_gc_set_limit", "fn_build_args", "fn_init_argvw", "fn_incref",
    "fn_decref", "fn_callStats", "fn_heap_count", "fn_heap_bytes_used", "fn_heap_bytes_committed",
    "fn_heap_bytes_reserved", "fn_heap_free_bytes", "fn_heap_free_blocks", "fn_unhandled_error_exit"
  ]
  for i = 0 to len(ordered) - 1
    if ordered[i] == lbl then return i end if
  end for
  return 1 << 20
end function

function _collect_pending_helpers(state)
  vals = []
  tracked = a.get_tracked_helpers(state.asm)
  if typeof(tracked) == "array" and len(tracked) > 0 then
    for i = 0 to len(tracked) - 1
      lbl = tracked[i]
      if typeof(lbl) != "string" then continue end if
      if _is_internal_helper_label(lbl) == false then continue end if
      if _arr_contains(state.emitted_helpers, lbl) then continue end if
      vals = _append_unique(vals, lbl)
    end for
  end if

  hs = state.used_helpers
  if typeof(hs) == "array" and len(hs) > 0 then
    for j = 0 to len(hs) - 1
      lbl2 = hs[j]
      if typeof(lbl2) != "string" then continue end if
      if _is_internal_helper_label(lbl2) == false then continue end if
      if _arr_contains(state.emitted_helpers, lbl2) then continue end if
      vals = _append_unique(vals, lbl2)
    end for
  end if
  return vals
end function

function emit_used_helpers(state)
  if typeof(state.emitted_helpers) != "array" then state.emitted_helpers = [] end if

  while true
    pending = _collect_pending_helpers(state)
    if typeof(pending) != "array" or len(pending) <= 0 then
      break
    end if

    best = ""
    best_rank = 1048576
    for i = 0 to len(pending) - 1
      lbl = pending[i]
      if typeof(lbl) != "string" then continue end if
      if _arr_contains(state.emitted_helpers, lbl) then continue end if
      rank = _helper_rank(lbl)
      if typeof(rank) != "int" then rank = 1048576 end if
      if best == "" then
        best = lbl
        best_rank = rank
      else
        if rank < best_rank then
          best = lbl
          best_rank = rank
        else
          if rank == best_rank and _str_less_ascii(lbl, best) then
            best = lbl
            best_rank = rank
          end if
        end if
      end if
    end for

    if best == "" then break end if

    state.emitted_helpers = state.emitted_helpers + [best]
    if _helper_supported(best) == false then
      state.diagnostics = state.diagnostics + ["Unknown internal helper referenced: " + best]
      continue
    end if
    state = _emit_helper_by_label(state, best)
  end while

  return state
end function
