package mlc.codegen.codegen
import mlc.asm as a
import mlc.constants as c
import mlc.codegen.codegen_builtins_alloc as bal
import mlc.codegen.codegen_core as core
import mlc.codegen.codegen_expr as exprmod
import mlc.codegen.codegen_memory as mem
import mlc.codegen.codegen_runtime as rt
import mlc.codegen.codegen_stmt as stmt
import mlc.codegen.codegen_scope as scope
import mlc.data as d
import mlc.tools as t

// Facade module that mirrors the Python `Codegen` composition surface.
// The actual implementation still lives in the mixin-style modules; this file
// only wires construction and program emission together.
struct Codegen
  state,
end struct

function _arr_has(arr, value)
  if typeof(arr) != "array" or len(arr) <= 0 then return false end if
  for i = 0 to len(arr) - 1
    if arr[i] == value then return true end if
  end for
  return false
end function

function _named_array_set(arr, key, values)
  if typeof(arr) != "array" then arr = [] end if
  for i = 0 to len(arr) - 1
    it = arr[i]
    if typeof(it) != "struct" then continue end if
    if it.key != key then continue end if
    arr[i] = core.NamedArray(key, values)
    return arr
  end for
  return arr + [core.NamedArray(key, values)]
end function

function _named_int_set(arr, key, value)
  if typeof(arr) != "array" then arr = [] end if
  for i = 0 to len(arr) - 1
    it = arr[i]
    if typeof(it) != "struct" then continue end if
    if it.key != key then continue end if
    arr[i] = core.NamedInt(key, value)
    return arr
  end for
  return arr + [core.NamedInt(key, value)]
end function

function enable_call_profile_metadata(cg)
  if typeof(cg) != "struct" then return cg end if
  if typeof(cg.state) != "struct" then return cg end if
  if cg.state.call_profile == false then return cg end if

  if _arr_has(cg.state.reserved_identifiers, "callStats") == false then
    cg.state.reserved_identifiers = cg.state.reserved_identifiers + ["callStats"]
  end if
  if _arr_has(cg.state.reserved_identifiers, "callStat") == false then
    cg.state.reserved_identifiers = cg.state.reserved_identifiers + ["callStat"]
  end if
  cg.state.struct_fields = _named_array_set(cg.state.struct_fields, "callStat", ["name", "calls"])
  cg.state.struct_ids = _named_int_set(cg.state.struct_ids, "callStat", c.CALLSTAT_STRUCT_ID)
  return cg
end function

function _copy_bytes(buf)
  if typeof(buf) != "bytes" then return bytes(0) end if
  out_buf = bytes(len(buf), 0)
  if len(buf) > 0 then
    copyBytes(out_buf, 0, buf, 0, len(buf))
  end if
  return out_buf
end function

function _copy_array(arr)
  if typeof(arr) != "array" then return [] end if
  return arr + []
end function

function _copy_frame_stack(frames)
  if typeof(frames) != "array" then return [[]] end if
  out_b = t.arr_chunk_new(8)
  if len(frames) > 0 then
    for i = 0 to len(frames) - 1
      fr = frames[i]
      if typeof(fr) == "array" then
        out_b = t.arr_chunk_push(out_b, fr + [])
      else
        out_b = t.arr_chunk_push(out_b, [])
      end if
    end for
  end if
  outv = t.arr_chunk_finish(out_b)
  if typeof(outv) != "array" or len(outv) <= 0 then return [[]] end if
  return outv
end function

function _copy_fastmap_stack(frames)
  if typeof(frames) != "array" then return [t.fastmap_new(128)] end if
  out_b = t.arr_chunk_new(8)
  if len(frames) > 0 then
    for i = 0 to len(frames) - 1
      fm = frames[i]
      if typeof(fm) == "struct" then
        out_b = t.arr_chunk_push(out_b, _copy_fastmap(fm))
      else
        out_b = t.arr_chunk_push(out_b, t.fastmap_new(128))
      end if
    end for
  end if
  outv = t.arr_chunk_finish(out_b)
  if typeof(outv) != "array" or len(outv) <= 0 then return [t.fastmap_new(128)] end if
  return outv
end function

function _copy_fastmap(mapv)
  if typeof(mapv) != "struct" then return t.fastmap_new(16) end if
  if typeof(mapv.keys) != "array" or typeof(mapv.values) != "array" or typeof(mapv.used) != "array" then
    return t.fastmap_new(16)
  end if
  cap = 16
  if typeof(mapv.cap) == "int" and mapv.cap > 0 then cap = mapv.cap end if
  size = 0
  if typeof(mapv.size) == "int" and mapv.size >= 0 then size = mapv.size end if
  out_map = t.fastmap_new(cap)
  out_map.keys = _copy_array(mapv.keys)
  out_map.values = _copy_array(mapv.values)
  out_map.used = _copy_array(mapv.used)
  out_map.cap = cap
  out_map.size = size
  return out_map
end function

function _copy_data_builder(db)
  out_db = d.newDataBuilder()
  if typeof(db) != "struct" then return out_db end if
  out_db.data = _copy_bytes(db.data)
  out_db.labels = _copy_array(db.labels)
  out_db.patches = _copy_array(db.patches)
  out_db.used = db.used
  return out_db
end function

function _copy_bss_builder(bb)
  out_bb = d.newBssBuilder()
  if typeof(bb) != "struct" then return out_bb end if
  out_bb.size = bb.size
  out_bb.labels = _copy_array(bb.labels)
  return out_bb
end function

function _copy_rdata_builder(rb)
  out_rb = d.newRDataBuilder()
  if typeof(rb) != "struct" then return out_rb end if
  out_rb.data = _copy_bytes(rb.data)
  out_rb.labels = _copy_array(rb.labels)
  out_rb.patches = _copy_array(rb.patches)
  out_rb.pool_raw = _copy_fastmap(rb.pool_raw)
  out_rb.pool_obj_string = _copy_fastmap(rb.pool_obj_string)
  out_rb.pool_obj_float = _copy_fastmap(rb.pool_obj_float)
  out_rb.used = rb.used
  return out_rb
end function

function newCodegen(source, filename, import_aliases, extern_sigs, extern_structs)
  st = core.cg_core_new(source, filename, import_aliases, extern_sigs, extern_structs)
  st = scope.cg_scope_setup(st)
  return Codegen(st)
end function

function __init__(cg)
  if typeof(cg) != "struct" then return cg end if
  if typeof(cg.state) == "struct" then
    cg.state = core.cg_core_init(cg.state)
  end if
  return cg
end function

function emit_program(cg, program)
  if typeof(cg) != "struct" then return cg end if
  if typeof(cg.state) != "struct" then return cg end if
  st = core.cg_core_init(cg.state)
  st = stmt.emit_program(st, program)
  cg.state = st
  return cg
end function

function _clone_state_for_object(base, seed_runtime)
  if typeof(base) != "struct" then
    return core.cg_core_new("", "", [], [], [])
  end if

  st = core.cg_core_new(base.source, base.filename, base.import_aliases, base.extern_sigs, base.extern_structs)
  st.heap_config = base.heap_config
  st.call_profile = base.call_profile
  st.trace_calls = base.trace_calls
  st.mem_probe = base.mem_probe
  st.imports = _copy_array(base.imports)
  st.var_slots = _copy_array(base.var_slots)
  st.break_stack = []
  st.struct_fields = base.struct_fields
  st.struct_ids = base.struct_ids
  st.enum_variants = base.enum_variants
  st.enum_ids = base.enum_ids
  st.value_enum_values = base.value_enum_values
  st.reserved_identifiers = base.reserved_identifiers
  st.label_id = base.label_id
  st.used_helpers = []
  st.emitted_helpers = []
  st.scope_stack = _copy_frame_stack(base.scope_stack)
  st.scope_declared = _copy_frame_stack(base.scope_declared)
  st.binding_id = base.binding_id
  st.global_slots = _copy_array(base.global_slots)
  st.globals = _copy_array(base.globals)
  st.in_function = false
  st.func_globals = []
  st.func_global_map = []
  st.function_locals = []
  st.current_qname_prefix = ""
  st.current_file_prefix = ""
  st.file_prefix_map = base.file_prefix_map
  st.typename_struct_by_id = base.typename_struct_by_id
  st.typename_struct_by_qname = base.typename_struct_by_qname
  st.typename_enum_by_id = base.typename_enum_by_id
  st.typename_enum_by_qname = base.typename_enum_by_qname
  st.user_functions = base.user_functions
  st.nested_user_functions = base.nested_user_functions
  st.struct_methods = base.struct_methods
  st.struct_static_methods = base.struct_static_methods
  st.function_global_labels = base.function_global_labels
  st.struct_global_labels = base.struct_global_labels
  st.builtin_specs = base.builtin_specs
  st.builtin_global_labels = base.builtin_global_labels
  st.extern_global_labels = base.extern_global_labels
  st.extern_stub_labels = base.extern_stub_labels
  st.function_static_obj_labels = base.function_static_obj_labels
  st.struct_static_obj_labels = base.struct_static_obj_labels
  st.builtin_static_obj_labels = base.builtin_static_obj_labels
  st.extern_static_obj_labels = base.extern_static_obj_labels
  st.diagnostics = []
  st.call_total_count = 0
  st.call_indirect_count = 0
  st.callprof_entries = base.callprof_entries
  st.callprof_index = base.callprof_index
  st.callprof_name_labels = base.callprof_name_labels
  st.callprof_n = base.callprof_n
  st.is_windows_subsystem = base.is_windows_subsystem
  st.func_ret_label = ""
  st.func_frame_size = 0
  st.errprop_suppression = 0
  st.dbg_line_starts = base.dbg_line_starts
  st.expr_temp_base = 0
  st.expr_temp_top = 0
  st.current_fn_boxed_names = []
  st.current_fn_env_index = []
  st.current_env_root_off = 0
  st.scope_index_stack = _copy_fastmap_stack(base.scope_index_stack)
  st.scope_declared_index_stack = _copy_fastmap_stack(base.scope_declared_index_stack)
  st.func_global_map_index = t.fastmap_new(64)
  st.user_function_index = base.user_function_index
  st.function_codegen_name_map = base.function_codegen_name_map
  st.analysis_mode = false
  st.qualify_cache = stmt._prepare_qualify_cache([], 2048)
  st.struct_fields_index = base.struct_fields_index
  st.struct_ids_index = base.struct_ids_index
  st.enum_variants_index = base.enum_variants_index
  st.enum_ids_index = base.enum_ids_index
  st.struct_methods_index = base.struct_methods_index
  st.struct_static_methods_index = base.struct_static_methods_index
  st.extern_sig_index = base.extern_sig_index
  st.import_alias_index = base.import_alias_index
  st.call_temp_base = 0
  st.expr_temp_max = base.expr_temp_max
  st._current_root_rec_off = 0
  st._current_root_static_qwords = 0
  st._expr_temp_reg_order = []
  st._expr_temp_reg_live = []
  st._expr_temp_reg_live_by_reg = []
  st._expr_temp_reg_reserved = []
  st._cold_block_stack = []
  st._inline_param_stack = []
  st._inline_call_stack = []
  st.ext_widebuf_labels = base.ext_widebuf_labels
  st.decl_site_bindings = []
  st.function_local_ids = []
  st._module_init_active = false
  st._module_init_active_file = ""
  st._global_owner_file = _copy_fastmap(base._global_owner_file)
  st._module_init_status_labels = _copy_fastmap(base._module_init_status_labels)

  st.asm = a.newAsmBuilder()
  if seed_runtime then
    st.data = _copy_data_builder(base.data)
    st.bss = _copy_bss_builder(base.bss)
    st.rdata = _copy_rdata_builder(base.rdata)
  else
    st.data = d.newDataBuilder()
    st.bss = d.newBssBuilder()
    st.rdata = d.newRDataBuilder()
  end if

  return st
end function

function clone_for_object(cg, seed_runtime)
  if typeof(cg) != "struct" then return cg end if
  if typeof(cg.state) != "struct" then return cg end if
  return Codegen(_clone_state_for_object(cg.state, seed_runtime))
end function

function prepare_program_for_objects(cg, program)
  if typeof(cg) != "struct" then return [cg, [], 0] end if
  if typeof(cg.state) != "struct" then return [cg, [], 0] end if
  st = core.cg_core_init(cg.state)
  prep = stmt.prepare_program_for_objects(st, program)
  if typeof(prep) != "array" or len(prep) < 3 then
    cg.state = st
    return [cg, [], 0]
  end if
  cg.state = prep[0]
  return [cg, prep[1], prep[2]]
end function

function emit_entry_object(cg, module_init_recs, max_call_args_main, main_name)
  if typeof(cg) != "struct" then return cg end if
  if typeof(cg.state) != "struct" then return cg end if
  st = stmt.emit_entry_object(cg.state, module_init_recs, max_call_args_main, main_name)
  cg.state = st
  return cg
end function

function emit_module_init_object(cg, module_rec)
  if typeof(cg) != "struct" then return cg end if
  if typeof(cg.state) != "struct" then return cg end if
  st = stmt.emit_module_init_object(cg.state, module_rec)
  cg.state = st
  return cg
end function

function emit_module_functions(cg, module_file)
  if typeof(cg) != "struct" then return cg end if
  if typeof(cg.state) != "struct" then return cg end if
  st = stmt.emit_module_functions(cg.state, module_file)
  cg.state = st
  return cg
end function

function emit_extern_stubs(cg)
  if typeof(cg) != "struct" then return cg end if
  if typeof(cg.state) != "struct" then return cg end if
  cg.state = exprmod.emit_extern_stubs(cg.state)
  return cg
end function

function emit_used_helpers(cg)
  if typeof(cg) != "struct" then return cg end if
  if typeof(cg.state) != "struct" then return cg end if
  cg.state = core.emit_used_helpers(cg.state)
  return cg
end function

function track_helper(cg, label)
  if typeof(cg) != "struct" then return cg end if
  if typeof(cg.state) != "struct" then return cg end if
  cg.state = core._track_call_label(cg.state, label)
  return cg
end function
