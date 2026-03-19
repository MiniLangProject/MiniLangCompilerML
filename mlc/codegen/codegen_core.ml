package mlc.codegen.codegen_core
import mlc.asm as a
import mlc.data as d
import mlc.tools as t
import mlc.constants as c
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
  qualify_cache,
  struct_fields_index,
  struct_ids_index,
  enum_variants_index,
  enum_ids_index,
  struct_methods_index,
  struct_static_methods_index,
  extern_sig_index,
  import_alias_index,
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

function _append_unique(vals, v)
  if typeof(vals) != "array" then return [v] end if
  if len(vals) > 0 then
    for i = 0 to len(vals) - 1
      if vals[i] == v then return vals end if
    end for
  end if
  return vals +[v]
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
  return cg
end function

function _seed_data(cg)
  cg.data = d.data_add_u64(cg.data, "dbg_loc_script", t.enc_void())
  cg.data = d.data_add_u64(cg.data, "dbg_loc_func", t.enc_void())
  cg.data = d.data_add_u64(cg.data, "dbg_loc_line", t.enc_int(0))

  // Keep heap/GC control globals early in .data so accidental scratch-buffer
  // overruns do not corrupt allocator state.
  cg = mem.ensure_gc_data(cg)

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
  NamedArray("kernel32.dll", ["GetStdHandle", "ReadFile", "WriteFile", "WriteConsoleW", "MultiByteToWideChar", "SetConsoleOutputCP", "FreeConsole", "ExitProcess", "VirtualAlloc", "VirtualFree", "GetCommandLineW", "LocalFree", "WideCharToMultiByte", "GetLocalTime", "GetSystemTime"]),
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
  [NamedArray("error", ["code", "message", "script", "func", "line"]), NamedArray("callStat", ["name", "calls"])],
  [NamedInt("error", 0xE0000001), NamedInt("callStat", c.CALLSTAT_STRUCT_ID)],
  [],
  [],
  [],
  ["try", "error", "callStats", "callStat"],
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
  t.fastmap_new(1024),
  t.fastmap_new(256),
  t.fastmap_new(256),
  t.fastmap_new(256),
  t.fastmap_new(256),
  t.fastmap_new(256),
  t.fastmap_new(256),
  t.fastmap_new(256),
  t.fastmap_new(128)
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

function _pretty_script(p)
  if typeof(p) != "string" or p == "" then return "<script>" end if
  return p
end function

function _track_call_label(state, lbl)
  if typeof(lbl) != "string" or lbl == "" then return state end if
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

function _add_extern_imports(state)
  xs = state.extern_sigs
  if typeof(xs) != "array" or len(xs) <= 0 then return state end if
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
      state = add_import_symbol(state, dll, sym)
    end if
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

function _line_from_pos(state, pos)
  source = state.source
  if typeof(source) != "string" then return 0 end if
  if typeof(pos) != "int" then return 0 end if
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

  // Recompute base at start of a temp-allocation burst so we stay above locals.
  if top <= 0 then
    vslots = state.var_slots
    if typeof(vslots) != "int" then vslots = 0 end if
    base = t.align_up(0x100 + vslots + 0x80, 16)
    // Keep expression temps above fixed call spill area (0x300..0x3F8).
    if base < 0x440 then base = 0x440 end if
    state.expr_temp_base = base
    top = 0
  end if

  frame_limit = 0x5C0
  if state.in_function and typeof(state.func_frame_size) == "int" and state.func_frame_size > 0 then
    // Keep clear of debug-save slots near frame tail.
    frame_limit = state.func_frame_size - 0x60
  end if
  if frame_limit < base then frame_limit = base end if

  off = base + top
  if off + sz > frame_limit then
    state.diagnostics = state.diagnostics + ["Expression temp overflow"]
    return 0
  end if

  state.expr_temp_top = top + sz
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
    state.expr_temp_base = 0
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
  if state.expr_temp_top <= 0 then
    state.expr_temp_top = 0
    state.expr_temp_base = 0
  end if
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
    state.expr_temp_base = 0
    return state
  end if
  if sz > top then sz = top end if

  state.expr_temp_top = top - sz
  if state.expr_temp_top <= 0 then
    state.expr_temp_top = 0
    state.expr_temp_base = 0
  end if
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
      if typeof(maybe_pos) == "int" then
        ln = _line_from_pos(state, maybe_pos)
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
  return scope.emit_store_var_scoped(state, name)
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
  l_end = "norm_end_" + lid

  state.asm = a.cvttsd2si_r64_xmm(state.asm, "rax", "xmm0")
  state.asm = a.cvtsi2sd_xmm_r64(state.asm, "xmm1", "rax")
  state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm1")
  state.asm = a.jcc(state.asm, "e", l_int)
  state.asm = a.call(state.asm, "fn_box_float")
  state.asm = a.jmp(state.asm, l_end)
  state.asm = a.mark(state.asm, l_int)
  state.asm = a.shl_r64_imm8(state.asm, "rax", 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
  state.asm = a.mark(state.asm, l_end)
  return state
end function

function emit_to_double_xmm(state, xmm, fail_label)
  lid = new_label_id(state)
  l_int = "todbl_int_" + lid
  l_ptr = "todbl_ptr_" + lid
  l_done = "todbl_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.and_r64_imm(state.asm, "rdx", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_INT)
  state.asm = a.jcc(state.asm, "e", l_int)
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

  state.asm = a.mark(state.asm, l_ptr)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FLOAT)
  state.asm = a.jcc(state.asm, "e", l_float)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "e", l_checklen)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
  state.asm = a.jcc(state.asm, "e", l_checklen)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
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

function _is_internal_helper_label(lbl)
  if _starts_with(lbl, "fn_") == false then return false end if
  if _starts_with(lbl, "fn_user_") then return false end if
  return true
end function

function _helper_supported(lbl)
  if lbl == "fn_int_to_dec" then return true end if
  if lbl == "fn_strlen" then return true end if
  if lbl == "fn_alloc" then return true end if
  if lbl == "fn_init_argvw" then return true end if
  if lbl == "fn_build_args" then return true end if
  if lbl == "fn_incref" then return true end if
  if lbl == "fn_decref" then return true end if
  if lbl == "fn_input" then return true end if
  if lbl == "fn_toNumber" then return true end if
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
  if lbl == "fn_box_float" then return true end if
  if lbl == "fn_value_to_string" then return true end if
  if lbl == "fn_str_eq" then return true end if
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
  if lbl == "fn_builtin_gc_collect" then return true end if
  if lbl == "fn_builtin_gc_set_limit" then return true end if
  return false
end function

function _emit_helper_by_label(state, lbl)
  if lbl == "fn_int_to_dec" then return rt.emit_int_to_dec_function(state) end if
  if lbl == "fn_strlen" then return rt.emit_strlen_function(state) end if
  if lbl == "fn_alloc" then return mem.emit_alloc_function(state) end if
  if lbl == "fn_init_argvw" then return rt.emit_init_argvw_function(state) end if
  if lbl == "fn_build_args" then return rt.emit_build_args_function(state) end if
  if lbl == "fn_incref" then return mem.emit_incref_function(state) end if
  if lbl == "fn_decref" then return mem.emit_decref_function(state) end if
  if lbl == "fn_input" then return bal.emit_input_function(state) end if
  if lbl == "fn_toNumber" then return rt.emit_toNumber_function(state) end if
  if lbl == "fn_typeof" then return rt.emit_typeof_function(state) end if
  if lbl == "fn_typeName" then return rt.emit_typeName_function(state) end if
  if lbl == "fn_unhandled_error_exit" then return rt.emit_unhandled_error_exit_function(state) end if
  if lbl == "fn_heap_count" then return mem.emit_heap_count_function(state) end if
  if lbl == "fn_heap_bytes_used" then return mem.emit_heap_bytes_used_function(state) end if
  if lbl == "fn_heap_bytes_committed" then return mem.emit_heap_bytes_committed_function(state) end if
  if lbl == "fn_heap_bytes_reserved" then return mem.emit_heap_bytes_reserved_function(state) end if
  if lbl == "fn_heap_free_bytes" then return mem.emit_heap_free_bytes_function(state) end if
  if lbl == "fn_heap_free_blocks" then return mem.emit_heap_free_blocks_function(state) end if
  if lbl == "fn_heap_grow" then return mem.emit_heap_grow_function(state) end if
  if lbl == "fn_gc_collect" then return mem.emit_gc_collect_function(state) end if
  if lbl == "fn_box_float" then return bal.emit_box_float_function(state) end if
  if lbl == "fn_value_to_string" then return bal.emit_value_to_string_function(state) end if
  if lbl == "fn_str_eq" then return rt.emit_string_eq_function(state) end if
  if lbl == "fn_val_eq" then return rt.emit_value_eq_function(state) end if
  if lbl == "fn_add_string" then return bal.emit_string_add_function(state) end if
  if lbl == "fn_add_array" then return bal.emit_array_add_function(state) end if
  if lbl == "fn_bytes_alloc" then return bal.emit_bytes_alloc_function(state) end if
  if lbl == "fn_add_bytes" then return bal.emit_bytes_add_function(state) end if
  if lbl == "fn_bytes_eq" then return bal.emit_bytes_eq_function(state) end if
  if lbl == "fn_decode" then return bal.emit_decode_function(state) end if
  if lbl == "fn_decodeZ" then return bal.emit_decodeZ_function(state) end if
  if lbl == "fn_decode16Z" then return bal.emit_decode16Z_function(state) end if
  if lbl == "fn_hex" then return bal.emit_hex_function(state) end if
  if lbl == "fn_fromHex" then return bal.emit_fromHex_function(state) end if
  if lbl == "fn_slice" then return bal.emit_slice_function(state) end if
  if lbl == "fn_callStats" then return rt.emit_callStats_function(state) end if
  if lbl == "fn_builtin_len" then return rt.emit_builtin_len_function(state) end if
  if lbl == "fn_builtin_input" then return rt.emit_builtin_input_function(state) end if
  if lbl == "fn_builtin_gc_collect" then return rt.emit_builtin_gc_collect_function(state) end if
  if lbl == "fn_builtin_gc_set_limit" then return rt.emit_builtin_gc_set_limit_function(state) end if
  return state
end function

function _collect_pending_helpers(state)
  vals = []
  calls = a.get_calls(state.asm)
  if typeof(calls) == "array" and len(calls) > 0 then
    for i = 0 to len(calls) - 1
      lbl = calls[i]
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

    emitted_any = false
    for i = 0 to len(pending) - 1
      lbl = pending[i]
      if typeof(lbl) != "string" then continue end if
      if _arr_contains(state.emitted_helpers, lbl) then continue end if

      state.emitted_helpers = state.emitted_helpers + [lbl]
      if _helper_supported(lbl) == false then
        state.diagnostics = state.diagnostics + ["Unknown internal helper referenced: " + lbl]
        continue
      end if
      state = _emit_helper_by_label(state, lbl)
      emitted_any = true
    end for

    if emitted_any == false then
      break
    end if
  end while

  return state
end function
