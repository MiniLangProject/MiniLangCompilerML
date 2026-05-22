package mlc.codegen.codegen_scope
import mlc.asm as a
import mlc.constants as c
import mlc.data as d
import mlc.tools as t

struct VarBinding
  id,
  name,
  kind,
  label,
  offset,
  depth,
  boxed,
  capture_depth,
  capture_index,
  decl_node,
  is_const,
  const_expr,
  const_initialized,
  const_value_py,
  const_value_encoded,
  const_value_label,
end struct

function inline _is_ascii_digit(ch)
  return ch == "0" or ch == "1" or ch == "2" or ch == "3" or ch == "4" or ch == "5" or ch == "6" or ch == "7" or ch == "8" or ch == "9"
end function

function inline _is_ascii_alpha(ch)
  if ch == "a" or ch == "b" or ch == "c" or ch == "d" or ch == "e" or ch == "f" or ch == "g" or ch == "h" or ch == "i" or ch == "j" or ch == "k" or ch == "l" or ch == "m" then return true end if
  if ch == "n" or ch == "o" or ch == "p" or ch == "q" or ch == "r" or ch == "s" or ch == "t" or ch == "u" or ch == "v" or ch == "w" or ch == "x" or ch == "y" or ch == "z" then return true end if
  if ch == "A" or ch == "B" or ch == "C" or ch == "D" or ch == "E" or ch == "F" or ch == "G" or ch == "H" or ch == "I" or ch == "J" or ch == "K" or ch == "L" or ch == "M" then return true end if
  if ch == "N" or ch == "O" or ch == "P" or ch == "Q" or ch == "R" or ch == "S" or ch == "T" or ch == "U" or ch == "V" or ch == "W" or ch == "X" or ch == "Y" or ch == "Z" then return true end if
  return false
end function

function _sanitize_ident(name)
  raw = _coerce_name(name)
  if typeof(raw) != "string" then return "v" end if
  if raw == "" then return "v" end if

  sanitized = ""
  for i = 0 to len(raw) - 1
    ch = raw[i]
    keep = false
    if ch == "_" then keep = true end if
    if _is_ascii_alpha(ch) or _is_ascii_digit(ch) then keep = true end if
    if keep then
      sanitized = sanitized + ch
    else
      sanitized = sanitized + "_"
    end if
  end for

  if sanitized == "" then sanitized = "v" end if
  c0 = sanitized[0]
  if _is_ascii_digit(c0) then
    sanitized = "_" + sanitized
  end if
  return sanitized
end function

function inline _scope_depth(state)
  if typeof(state.scope_stack) != "array" then return 0 end if
  return len(state.scope_stack) - 1
end function

function inline _frame_last_binding(frame, name)
  if typeof(frame) != "array" or len(frame) <= 0 then return 0 end if
  i = len(frame) - 1
  while i >= 0
    b = frame[i]
    if typeof(b) == "struct" and b.name == name then
      return b
    end if
    i = i - 1
  end while
  return 0
end function

function inline _heap_cfg_get_any(state, key)
  cfg = try(state.heap_cfg)
  if typeof(cfg) != "array" or len(cfg) <= 0 then return 0 end if
  for i = 0 to len(cfg) - 1
    it = cfg[i]
    if typeof(it) == "struct" and typeof(it.key) == "string" and it.key == key then
      return it.value
    end if
    if typeof(it) == "array" and len(it) >= 2 and typeof(it[0]) == "string" and it[0] == key then
      return it[1]
    end if
  end for
  return 0
end function

function inline _heap_cfg_get_bool(state, key, defaultv)
  v = _heap_cfg_get_any(state, key)
  if typeof(v) == "bool" then return v end if
  return defaultv
end function

function _drop_last_frame(arr)
  if typeof(arr) != "array" then return [[]] end if
  n = len(arr)
  if n <= 1 then return [[]] end if
  if n == 2 then return [arr[0]] end if
  if n == 3 then return [arr[0], arr[1]] end if
  out_b = t.arr_chunk_new(8)
  for i = 0 to n - 2
    out_b = t.arr_chunk_push(out_b, arr[i])
  end for
  outv = t.arr_chunk_finish(out_b)
  if typeof(outv) != "array" or len(outv) <= 0 then return [[]] end if
  return outv
end function

function inline _is_reserved_identifier(state, name)
  rs = state.reserved_identifiers
  if typeof(rs) != "array" then return false end if
  if len(rs) <= 0 then return false end if
  for i = 0 to len(rs) - 1
    if rs[i] == name then return true end if
  end for
  return false
end function

function _append_unique(items, value)
  if typeof(items) != "array" then return [value] end if
  if len(items) > 0 then
    for i = 0 to len(items) - 1
      if items[i] == value then return items end if
    end for
  end if
  return items +[value]
end function

function inline _arr_has(arr, value)
  if typeof(arr) != "array" or len(arr) <= 0 then return false end if
  for i = 0 to len(arr) - 1
    if arr[i] == value then return true end if
  end for
  return false
end function

function inline _map_int_get(arr, key, defaultv)
  if typeof(arr) == "struct" then
    v0 = t.fastmap_get(arr, key, defaultv)
    if typeof(v0) == "int" then return v0 end if
    return defaultv
  end if
  if typeof(arr) != "array" or len(arr) <= 0 then return defaultv end if
  for i = 0 to len(arr) - 1
    it = arr[i]
    if typeof(it) == "struct" and it.key == key and typeof(it.value) == "int" then
      return it.value
    end if
    if typeof(it) == "array" and len(it) >= 2 and it[0] == key and typeof(it[1]) == "int" then
      return it[1]
    end if
  end for
  return defaultv
end function

function inline _name_has_dot(name)
  if typeof(name) != "string" then return false end if
  if name == "" then return false end if
  for i = 0 to len(name) - 1
    if name[i] == "." then return true end if
  end for
  return false
end function

function inline _decl_node_key(node)
  if typeof(node) == "void" then return "void" end if
  if typeof(node) == "string" then return node end if
  if typeof(node) == "int" then return "" + node end if
  if typeof(node) == "bool" then
    if node then return "true" end if
    return "false"
  end if
  if typeof(node) == "struct" then
    k = ""
    if typeof(node.node_kind) == "string" then k = node.node_kind end if
    if k == "" and typeof(node.kind) == "string" then k = node.kind end if
    file_s = ""
    if typeof(node._filename) == "string" then file_s = node._filename end if
    if file_s == "" and typeof(node.filename) == "string" then file_s = node.filename end if
    pos_s = ""
    if typeof(node._pos) == "int" then pos_s = "" + node._pos end if
    if pos_s == "" and typeof(node.pos) == "int" then pos_s = "" + node.pos end if
    if pos_s != "" then
      if file_s == "" then file_s = "?" end if
      if k == "" then k = "struct" end if
      return file_s + ":" + pos_s + ":" + k
    end if
    if k == "" and typeof(node.name) == "string" then k = node.name end if
    if k == "" and typeof(node.value) == "string" then k = node.value end if
    if k == "" then k = "" + node end if
    return k
  end if
  return "" + node
end function

function inline _func_global_lookup(arr, name)
  if typeof(arr) == "struct" then
    v0 = t.fastmap_get(arr, name, "")
    if typeof(v0) == "string" then return v0 end if
    return ""
  end if
  if typeof(arr) != "array" or len(arr) <= 0 then return "" end if
  for i = 0 to len(arr) - 1
    it = arr[i]
    if typeof(it) == "array" and len(it) >= 2 then
      if it[0] == name and typeof(it[1]) == "string" then return it[1] end if
    end if
    if typeof(it) == "struct" and it.key == name and typeof(it.value) == "string" then
      return it.value
    end if
  end for
  return ""
end function

function _has_data_label(labels, name)
  if typeof(labels) != "array" or len(labels) <= 0 then return false end if
  for i = 0 to len(labels) - 1
    it = labels[i]
    if typeof(it) == "struct" and it.name == name then return true end if
  end for
  return false
end function

function _emit_make_error_const(state, code, message)
  err_code = 0
  if typeof(code) == "int" then err_code = code end if
  msg = "" + message

  lbl = "objstr_" + len(state.rdata.labels)
  state.rdata = d.rdata_add_obj_string(state.rdata, lbl, msg)

  state.asm = a.mov_rcx_imm32(state.asm, 48)
  state.asm = a.call(state.asm, "fn_alloc")
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")

  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRUCT, false)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, c.ERROR_STRUCT_ID, false)

  state.asm = a.mov_rax_imm64(state.asm, t.enc_int(err_code))
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8, "rax")

  state.asm = a.lea_rax_rip(state.asm, lbl)
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "rax")

  state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_script")
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 24, "rax")

  state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_func")
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 32, "rax")

  state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_line")
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 40, "rax")

  state.asm = a.mov_rax_r11(state.asm)
  return state
end function

function new_label_id(state)
  state.label_id = state.label_id + 1
  return state.label_id
end function

function cg_scope_setup(state)
  state.scope_stack =[[]]
  state.scope_declared =[[]]
  state.scope_index_stack = [t.fastmap_new(128)]
  state.scope_declared_index_stack = [t.fastmap_new(128)]
  state.decl_site_bindings = t.fastmap_new(128)
  state.binding_id = 0
  state.global_slots =[]
  state.globals =[]
  state.func_globals =[]
  state.func_global_map =[]
  state.func_global_map_index = t.fastmap_new(64)
  state.function_locals =[]
  state.function_local_ids = t.fastmap_new(64)
  state.current_qname_prefix = ""
  state.current_file_prefix = ""
  state.current_fn_boxed_names = []
  state.current_fn_env_index = []
  return state
end function

function cg_scope_depth(state)
  return _scope_depth(state)
end function

function cg_scope_enter(state)
  if typeof(state.scope_stack) != "array" then
    state.scope_stack =[[]]
  end if
  if typeof(state.scope_declared) != "array" then
    state.scope_declared =[[]]
  end if
  if typeof(state.scope_index_stack) != "array" then
    state.scope_index_stack = [t.fastmap_new(128)]
  end if
  if typeof(state.scope_declared_index_stack) != "array" then
    state.scope_declared_index_stack = [t.fastmap_new(128)]
  end if
  state.scope_stack = state.scope_stack +[[]]
  state.scope_declared = state.scope_declared +[[]]
  state.scope_index_stack = state.scope_index_stack + [t.fastmap_new(128)]
  state.scope_declared_index_stack = state.scope_declared_index_stack + [t.fastmap_new(128)]
  return state
end function

function cg_scope_leave(state, emit_cleanup)
  if typeof(state.scope_stack) != "array" or len(state.scope_stack) <= 1 then return state end if
  if typeof(state.scope_declared) != "array" or len(state.scope_declared) <= 1 then return state end if

  cleanup = true
  if typeof(emit_cleanup) == "bool" then cleanup = emit_cleanup end if
  if cleanup then
    bindings = state.scope_declared[len(state.scope_declared) - 1]
    if typeof(bindings) == "array" and len(bindings) > 0 then
      state = emit_cleanup_bindings(state, bindings)
    end if
  end if

  state.scope_stack = _drop_last_frame(state.scope_stack)
  state.scope_declared = _drop_last_frame(state.scope_declared)
  if typeof(state.scope_index_stack) == "array" and len(state.scope_index_stack) > 1 then
    state.scope_index_stack = _drop_last_frame(state.scope_index_stack)
  end if
  if typeof(state.scope_declared_index_stack) == "array" and len(state.scope_declared_index_stack) > 1 then
    state.scope_declared_index_stack = _drop_last_frame(state.scope_declared_index_stack)
  end if
  return state
end function

function cg_next_binding_id(state)
  state.binding_id = state.binding_id + 1
  return state.binding_id
end function

function cg_resolve_binding(state, name)
  if typeof(name) != "string" then return 0 end if
  sis = state.scope_index_stack
  if typeof(sis) == "array" and len(sis) > 0 then
    si = len(sis) - 1
    while si >= 0
      hit0 = t.fastmap_get(sis[si], name, 0)
      if typeof(hit0) == "struct" then return hit0 end if
      si = si - 1
    end while
  end if
  ss = state.scope_stack
  if typeof(ss) != "array" or len(ss) <= 0 then return 0 end if
  i = len(ss) - 1
  while i >= 0
    hit = _frame_last_binding(ss[i], name)
    if typeof(hit) == "struct" then return hit end if
    i = i - 1
  end while
  return 0
end function

function cg_resolve_binding_for_write(state, name)
  if typeof(name) != "string" then return 0 end if
  b = cg_resolve_binding(state, name)
  if typeof(b) != "struct" then return 0 end if

  // Inside functions, plain assignments must create/update locals by default.
  // A global binding is writable only when it is explicitly mapped via `global x`
  // (func_global_map) or when the target is already qualified (contains dot).
  if state.in_function then
    mapped = _func_global_lookup(state.func_global_map_index, name)
    if mapped == "" then
      mapped = _func_global_lookup(state.func_global_map, name)
    end if
    if mapped == "" and _name_has_dot(name) == false then
      if b.kind == "global" then
        return 0
      end if
    end if
  end if
  return b
end function

function _declare_in_current_scope(state, b)
  sd = state.scope_declared
  ss = state.scope_stack
  si = len(ss) - 1
  di = len(sd) - 1
  ss[si] = ss[si] +[b]
  sd[di] = sd[di] +[b]
  state.scope_stack = ss
  state.scope_declared = sd

  sis = state.scope_index_stack
  if typeof(sis) == "array" and len(sis) > 0 then
    sidx = len(sis) - 1
    fm = sis[sidx]
    fm = t.fastmap_set(fm, b.name, b)
    sis[sidx] = fm
    state.scope_index_stack = sis
  end if

  sds = state.scope_declared_index_stack
  if typeof(sds) == "array" and len(sds) > 0 then
    didx = len(sds) - 1
    fmd = sds[didx]
    fmd = t.fastmap_set(fmd, b.name, b)
    sds[didx] = fmd
    state.scope_declared_index_stack = sds
  end if

  if b.kind == "local" and state.in_function then
    if typeof(state.function_local_ids) != "struct" then
      state.function_local_ids = t.fastmap_new(64)
    end if
    if t.fastmap_has(state.function_local_ids, b.id) == false then
      state.function_local_ids = t.fastmap_set(state.function_local_ids, b.id, 1)
      state.function_locals = state.function_locals +[b]
    end if
  end if
  return state
end function

function cg_declare_binding(state, name, kind, is_const, const_expr, const_value_py, decl_node)
  if typeof(name) != "string" then return state end if
  if name == "" then return state end if
  if _is_reserved_identifier(state, name) then
    state.diagnostics = state.diagnostics +["Reserved identifier: " + name]
    return state
  end if

  bid = cg_next_binding_id(state)
  depth = _scope_depth(state)
  b = VarBinding(
  bid,
  name,
  kind,
  "",
  0,
  depth,
  false,
  -1,
  -1,
  decl_node,
  is_const,
  const_expr,
  false,
  const_value_py,
  void,
  ""
  )

  if state.in_function and (kind == "local" or kind == "param") then
    boxed_names = state.current_fn_boxed_names
    if _arr_has(boxed_names, name) then
      b.boxed = true
    end if
  end if

  if kind == "global" then
    b.label = "g_" + _sanitize_ident(name) + "_" + bid
    if typeof(state.data) == "struct" then
      if _has_data_label(state.data.labels, b.label) == false then
        state.data = d.data_add_u64(state.data, b.label, t.enc_void())
      end if
    end if
  end if

  if kind == "local" and state.in_function then
    if state.analysis_mode == true and _heap_cfg_get_bool(state, "cg_mem_probe", false) then
      if name == "n" or name == "m" or name == "i0" or name == "last" or name == "b0" or name == "i" or name == "shift" or name == "j" or name == "lastByte" or name == "tail" then
        print "[mem][cg][scope] declare_local name=" + name + " depth=" + depth + " qpref=" + state.current_qname_prefix
      end if
    end if
    // Match the Python compiler: local bindings stay offset-less until the
    // function layout pass assigns compact contiguous stack slots.
  end if

  if is_const then
    if typeof(const_value_py) != "void" then
      b.const_initialized = true
    end if
  end if

  state = _declare_in_current_scope(state, b)
  if kind == "global" and typeof(b.label) == "string" and b.label != "" then
    state.global_slots = _append_unique(state.global_slots, b.label)
    state.globals = _append_unique(state.globals, b)
  end if
  if kind == "local" and state.in_function then
    if typeof(state.function_local_ids) != "struct" then
      state.function_local_ids = t.fastmap_new(64)
    end if
    if t.fastmap_has(state.function_local_ids, bid) == false then
      state.function_local_ids = t.fastmap_set(state.function_local_ids, bid, 1)
      state.function_locals = state.function_locals +[b]
    end if
  end if
  return state
end function

function cg_set_const_binding_value(state, name, pyv)
  if typeof(name) != "string" then return state end if
  ss = state.scope_stack
  if typeof(ss) != "array" or len(ss) <= 0 then return state end if

  i = len(ss) - 1
  while i >= 0
    fr = ss[i]
    if typeof(fr) == "array" and len(fr) > 0 then
      j = len(fr) - 1
      while j >= 0
        b = fr[j]
        if typeof(b) == "struct" and b.name == name then
          b.is_const = true
          b.const_initialized = true
          b.const_value_py = pyv
          b.const_value_encoded = void
          b.const_value_label = ""
          if typeof(pyv) == "bool" then
            b.const_value_encoded = t.enc_bool(pyv)
          else if typeof(pyv) == "int" then
            b.const_value_encoded = t.enc_int(pyv)
          else if typeof(pyv) == "float" then
            enc = t.try_enc_float_immediate(pyv)
            if typeof(enc) == "int" then
              b.const_value_encoded = enc
            else
              lbl = "cflt_" + len(state.rdata.labels)
              state.rdata = d.rdata_add_obj_float(state.rdata, lbl, pyv)
              b.const_value_label = lbl
            end if
          else if typeof(pyv) == "string" then
            lbl2 = "cstr_" + len(state.rdata.labels)
            state.rdata = d.rdata_add_obj_string(state.rdata, lbl2, pyv)
            b.const_value_label = lbl2
          end if
          fr[j] = b
          ss[i] = fr
          state.scope_stack = ss
          sis = state.scope_index_stack
          if typeof(sis) == "array" and i >= 0 and i < len(sis) then
            fmi = sis[i]
            fmi = t.fastmap_set(fmi, b.name, b)
            sis[i] = fmi
            state.scope_index_stack = sis
          end if
          return state
        end if
        j = j - 1
      end while
    end if
    i = i - 1
  end while
  return state
end function

// ------------------------------------------------------------
// Compatibility wrappers (Python CodegenScope parity)
// ------------------------------------------------------------

function scope_setup(state)
  return cg_scope_setup(state)
end function

function scope_depth(state)
  return cg_scope_depth(state)
end function

function scope_global_slots(state)
  return state.global_slots
end function

function _coerce_name(name)
  tv = typeof(name)
  if tv == "string" then return name end if
  if tv == "struct" then
    nm = try(name.name)
    if typeof(nm) == "string" then return nm end if
    vv = try(name.value)
    if typeof(vv) == "string" then return vv end if
    return ""
  end if
  if tv == "int" or tv == "bool" or tv == "float" then return "" + name end if
  return ""
end function

function is_ident(s)
  if typeof(s) != "string" then return false end if
  if s == "" then return false end if
  c0 = s[0]
  ok0 = (c0 == "_") or (c0 >= "a" and c0 <= "z") or (c0 >= "A" and c0 <= "Z")
  if ok0 == false then return false end if
  for i = 1 to len(s) - 1
    ch = s[i]
    ok = (ch == "_") or (ch >= "a" and ch <= "z") or (ch >= "A" and ch <= "Z") or (ch >= "0" and ch <= "9")
    if ok == false then return false end if
  end for
  return true
end function

function accept(s)
  if typeof(s) != "string" or s == "" then return false end if
  if is_ident(s) == false then return false end if
  if s == "IDENT" or s == "IDENTIFIER" or s == "NAME" or s == "Token" or s == "VAR" or s == "KIND" or s == "TOK" or s == "TOKEN" then return false end if
  if s == "Var" or s == "Name" or s == "Id" or s == "ID" then return false end if
  return true
end function

function search(obj, depth)
  if depth < 0 or typeof(obj) == "void" then return 0 end if
  if typeof(obj) == "string" then
    if accept(obj) then return obj end if
    return 0
  end if

  if typeof(obj) == "array" and len(obj) > 0 then
    for i = 0 to len(obj) - 1
      r = search(obj[i], depth - 1)
      if typeof(r) == "string" and r != "" then return r end if
    end for
  end if

  if typeof(obj) == "struct" then
    v = obj.value
    if typeof(v) == "string" and accept(v) then return v end if
    r = search(v, depth - 1)
    if typeof(r) == "string" and r != "" then return r end if

    t = obj.text
    if typeof(t) == "string" and accept(t) then return t end if
    r = search(t, depth - 1)
    if typeof(r) == "string" and r != "" then return r end if

    lx = obj.lexeme
    if typeof(lx) == "string" and accept(lx) then return lx end if
    r = search(lx, depth - 1)
    if typeof(r) == "string" and r != "" then return r end if

    nm = obj.name
    if typeof(nm) == "string" and accept(nm) then return nm end if
    r = search(nm, depth - 1)
    if typeof(r) == "string" and r != "" then return r end if
  end if

  return 0
end function

function push_scope(state)
  return cg_scope_enter(state)
end function

function pop_scope(state, emit_cleanup)
  return cg_scope_leave(state, emit_cleanup)
end function

function _next_binding_id(state)
  return cg_next_binding_id(state)
end function

function _decl_key(node, name)
  return _coerce_name(name) + "|" + _decl_node_key(node)
end function

function resolve_binding(state, name)
  return cg_resolve_binding(state, _coerce_name(name))
end function

function resolve_binding_for_write(state, name)
  return cg_resolve_binding_for_write(state, _coerce_name(name))
end function

function _add_binding_to_current_scope(state, b)
  return _declare_in_current_scope(state, b)
end function

function _check_reserved_ident(state, name, decl_node)
  nm = _coerce_name(name)
  if _is_reserved_identifier(state, nm) then
    state.diagnostics = state.diagnostics +["Reserved identifier: " + nm]
    return false
  end if
  return true
end function

function declare_global_binding(state, name, decl_node, is_const, const_expr)
  nm = _coerce_name(name)
  return cg_declare_binding(state, nm, "global", is_const, const_expr, void, decl_node)
end function

function declare_global_binding_root(state, name, decl_node, is_const, const_expr)
  nm = _coerce_name(name)
  if nm == "" then return state end if
  if _check_reserved_ident(state, nm, decl_node) == false then return state end if

  if typeof(state.scope_stack) != "array" or len(state.scope_stack) <= 0 then
    state.scope_stack =[[]]
  end if
  if typeof(state.scope_declared) != "array" or len(state.scope_declared) <= 0 then
    state.scope_declared =[[]]
  end if
  if typeof(state.scope_index_stack) != "array" or len(state.scope_index_stack) <= 0 then
    state.scope_index_stack = [t.fastmap_new(128)]
  end if
  if typeof(state.scope_declared_index_stack) != "array" or len(state.scope_declared_index_stack) <= 0 then
    state.scope_declared_index_stack = [t.fastmap_new(128)]
  end if

  root = state.scope_stack[0]
  if typeof(root) != "array" then root = [] end if
  existing = t.fastmap_get(state.scope_index_stack[0], nm, 0)
  if typeof(existing) != "struct" then
    existing = _frame_last_binding(root, nm)
  end if
  if typeof(existing) == "struct" and existing.kind == "global" then
    return state
  end if

  bid = cg_next_binding_id(state)
  b = VarBinding(
  bid,
  nm,
  "global",
  "",
  0,
  0,
  false,
  -1,
  -1,
  decl_node,
  is_const,
  const_expr,
  false,
  void,
  void,
  ""
  )

  b.label = "g_" + _sanitize_ident(nm) + "_" + bid
  if typeof(state.data) == "struct" then
    if _has_data_label(state.data.labels, b.label) == false then
      state.data = d.data_add_u64(state.data, b.label, t.enc_void())
    end if
  end if
  if is_const then
    b.const_initialized = false
  end if

  ss = state.scope_stack
  sd = state.scope_declared
  rf = ss[0]
  if typeof(rf) != "array" then rf = [] end if
  rf = rf + [b]
  ss[0] = rf

  rd = sd[0]
  if typeof(rd) != "array" then rd = [] end if
  rd = rd + [b]
  sd[0] = rd

  state.scope_stack = ss
  state.scope_declared = sd
  sis = state.scope_index_stack
  if typeof(sis) == "array" and len(sis) > 0 then
    rsi = sis[0]
    rsi = t.fastmap_set(rsi, nm, b)
    sis[0] = rsi
    state.scope_index_stack = sis
  end if
  sds = state.scope_declared_index_stack
  if typeof(sds) == "array" and len(sds) > 0 then
    rsd = sds[0]
    rsd = t.fastmap_set(rsd, nm, b)
    sds[0] = rsd
    state.scope_declared_index_stack = sds
  end if
  state.global_slots = _append_unique(state.global_slots, b.label)
  state.globals = _append_unique(state.globals, b)
  return state
end function

function declare_local_binding(state, name, decl_node, is_const, const_expr)
  nm = _coerce_name(name)
  return cg_declare_binding(state, nm, "local", is_const, const_expr, void, decl_node)
end function

function declare_fresh_binding(state, name, decl_node, kind)
  nm = _coerce_name(name)
  if nm == "" then return state end if
  if _check_reserved_ident(state, nm, decl_node) == false then return state end if

  if typeof(state.decl_site_bindings) != "struct" then
    state.decl_site_bindings = t.fastmap_new(128)
  end if
  key = _decl_key(decl_node, nm)
  pre = t.fastmap_get(state.decl_site_bindings, key, 0)
  if typeof(pre) == "struct" then
    state = _declare_in_current_scope(state, pre)
    return state
  end if

  if kind == "global" then
    return declare_global_binding(state, nm, decl_node, false, 0)
  end if
  if kind == "local" then
    return declare_local_binding(state, nm, decl_node, false, 0)
  end if

  if state.in_function then
    return declare_local_binding(state, nm, decl_node, false, 0)
  end if
  return declare_global_binding(state, nm, decl_node, false, 0)
end function

function bind_param(state, name, offset, decl_node)
  nm = _coerce_name(name)
  state = cg_declare_binding(state, nm, "param", false, 0, 0, decl_node)
  ss = state.scope_stack
  if typeof(ss) == "array" and len(ss) > 0 then
    si = len(ss) - 1
    fr = ss[si]
    if typeof(fr) == "array" and len(fr) > 0 then
      i = len(fr) - 1
      while i >= 0
        b = fr[i]
        if typeof(b) == "struct" and b.name == nm and b.kind == "param" then
          b.offset = offset
          fr[i] = b
          ss[si] = fr
          state.scope_stack = ss
          sis = state.scope_index_stack
          if typeof(sis) == "array" and si >= 0 and si < len(sis) then
            fm = sis[si]
            fm = t.fastmap_set(fm, b.name, b)
            sis[si] = fm
            state.scope_index_stack = sis
          end if
          return state
        end if
        i = i - 1
      end while
    end if
  end if
  return state
end function

function register_decl_site_binding(state, node, name, binding)
  if typeof(state.decl_site_bindings) != "struct" then
    state.decl_site_bindings = t.fastmap_new(128)
  end if
  key = _decl_key(node, name)
  state.decl_site_bindings = t.fastmap_set(state.decl_site_bindings, key, binding)
  return state
end function

function ensure_binding_for_write(state, name, decl_node)
  nm = _coerce_name(name)
  if nm == "" then return state end if
  if _check_reserved_ident(state, nm, decl_node) == false then return state end if

  if state.in_function then
    mapped = _func_global_lookup(state.func_global_map_index, nm)
    if mapped == "" then
      mapped = _func_global_lookup(state.func_global_map, nm)
    end if
    if mapped != "" then
      b = resolve_binding(state, mapped)
      if typeof(b) != "struct" or b.kind != "global" or b.depth != 0 then
        state = declare_global_binding_root(state, mapped, decl_node, false, 0)
      end if
      return state
    end if
  end if

  b = resolve_binding_for_write(state, nm)
  if typeof(b) == "struct" then return state end if

  if typeof(state.decl_site_bindings) != "struct" then
    state.decl_site_bindings = t.fastmap_new(128)
  end if
  key = _decl_key(decl_node, nm)
  pre = t.fastmap_get(state.decl_site_bindings, key, 0)
  if typeof(pre) == "struct" then
    state = _declare_in_current_scope(state, pre)
    return state
  end if

  if state.in_function then
    return declare_local_binding(state, nm, decl_node, false, 0)
  end if
  return declare_global_binding(state, nm, decl_node, false, 0)
end function

function emit_cleanup_bindings(state, bindings)
  if typeof(bindings) != "array" or len(bindings) <= 0 then return state end if
  voidv = t.enc_void()
  for i = 0 to len(bindings) - 1
    b = bindings[i]
    if typeof(b) != "struct" then continue end if
    if b.kind == "param" then continue end if
    if b.kind == "local" then
      if typeof(b.offset) != "int" then continue end if
      state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", b.offset, voidv, true)
      continue
    end if
    if b.kind == "global" then
      if typeof(b.label) != "string" or b.label == "" then continue end if
      state.asm = a.mov_r64_imm64(state.asm, "r11", voidv)
      state.asm = a.mov_rip_qword_r11(state.asm, b.label)
    end if
  end for
  return state
end function

function emit_cleanup_to_depth(state, target_depth)
  if typeof(target_depth) != "int" then target_depth = 0 end if
  if target_depth < 0 then target_depth = 0 end if
  cur = cg_scope_depth(state)
  if target_depth >= cur then return state end if
  d = cur
  while d > target_depth
    if typeof(state.scope_declared) == "array" and d >= 0 and d < len(state.scope_declared) then
      bindings = state.scope_declared[d]
      if typeof(bindings) == "array" and len(bindings) > 0 then
        state = emit_cleanup_bindings(state, bindings)
      end if
    end if
    d = d - 1
  end while
  return state
end function

function _emit_module_init_dependency_error(state, target_name, target_file, target_state, node)
  state_txt = "not initialized"
  if target_state == 1 then state_txt = "initializing" end if
  cur_file = state._module_init_active_file
  cur_disp = "<entry>"
  if typeof(cur_file) == "string" and cur_file != "" then cur_disp = cur_file end if
  tgt_disp = "<unknown>"
  if typeof(target_file) == "string" and target_file != "" then tgt_disp = target_file end if
  msg = "Cyclic/invalid module initialization dependency while reading '" + target_name + "': module '" + tgt_disp + "' is " + state_txt + " (from '" + cur_disp + "')"
  state = _emit_make_error_const(state, c.ERR_MODULE_INIT_CYCLE, msg)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.call(state.asm, "fn_unhandled_error_exit")
  return state
end function

function _maybe_emit_module_init_guard_for_global_read(state, binding, target_name, node)
  if typeof(state._module_init_active) != "bool" or state._module_init_active == false then return state end if
  owner_map = state._global_owner_file
  tgt_file = _func_global_lookup(owner_map, target_name)
  if tgt_file == "" then return state end if
  cur_file = state._module_init_active_file
  if typeof(cur_file) == "string" and cur_file == tgt_file then return state end if
  status_map = state._module_init_status_labels
  status_lbl = _func_global_lookup(status_map, tgt_file)
  if status_lbl == "" then return state end if

  lid = new_label_id(state)
  ok_lbl = "lbl_modinit_read_ok_" + lid
  state.asm = a.mov_rax_rip_qword(state.asm, status_lbl)
  state.asm = a.cmp_rax_imm8(state.asm, 2)
  state.asm = a.jcc(state.asm, "e", ok_lbl)
  st_init_lbl = "lbl_modinit_read_initializing_" + new_label_id(state)
  st_after_lbl = "lbl_modinit_read_state_after_" + new_label_id(state)
  state.asm = a.cmp_rax_imm8(state.asm, 1)
  state.asm = a.jcc(state.asm, "e", st_init_lbl)
  state = _emit_module_init_dependency_error(state, target_name, tgt_file, 0, node)
  state.asm = a.jmp(state.asm, st_after_lbl)
  state.asm = a.mark(state.asm, st_init_lbl)
  state = _emit_module_init_dependency_error(state, target_name, tgt_file, 1, node)
  state.asm = a.mark(state.asm, st_after_lbl)
  state.asm = a.mark(state.asm, ok_lbl)
  return state
end function

function emit_load_var_scoped(state, name)
  nm = _coerce_name(name)
  target = nm
  mapped = ""

  if state.in_function then
    mapped = _func_global_lookup(state.func_global_map_index, nm)
    if mapped == "" then
      mapped = _func_global_lookup(state.func_global_map, nm)
    end if
    if mapped != "" then target = mapped end if
  end if

  b = resolve_binding(state, target)

  if typeof(b) != "struct" and _name_has_dot(nm) == false then
    qpref = state.current_qname_prefix
    if typeof(qpref) == "string" and qpref != "" then
      if qpref[len(qpref) - 1] != "." then qpref = qpref + "." end if
      b = resolve_binding(state, qpref + nm)
    end if
  end if

  if typeof(b) != "struct" and _name_has_dot(nm) == false then
    fpref = state.current_file_prefix
    if typeof(fpref) == "string" and fpref != "" then
      if fpref[len(fpref) - 1] != "." then fpref = fpref + "." end if
      b = resolve_binding(state, fpref + nm)
    end if
  end if

  if typeof(b) != "struct" and mapped != "" then
    state = declare_global_binding_root(state, mapped, 0, false, 0)
    b = resolve_binding(state, mapped)
  end if

  if typeof(b) != "struct" then
    state.diagnostics = state.diagnostics + ["Undefined variable '" + nm + "'"]
    return state
  end if
  if b.is_const and b.const_initialized then
    if typeof(b.const_value_encoded) == "int" then
      state.asm = a.mov_rax_imm64(state.asm, b.const_value_encoded)
      return state
    end if
    if typeof(b.const_value_label) == "string" and b.const_value_label != "" then
      state.asm = a.lea_rax_rip(state.asm, b.const_value_label)
      return state
    end if
  end if
  if b.kind == "global" and b.is_const and b.const_initialized == false then
    state.diagnostics = state.diagnostics + ["const '" + nm + "' is not constexpr-evaluable"]
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return state
  end if

  if b.kind == "capture" or (typeof(b.capture_index) == "int" and b.capture_index >= 0) then
    depth = 0
    if typeof(b.capture_depth) == "int" then depth = b.capture_depth end if
    idx = -1
    if typeof(b.capture_index) == "int" then idx = b.capture_index end if
    if idx < 0 then
      state.diagnostics = state.diagnostics + ["Internal error: capture missing index for '" + nm + "'"]
      return state
    end if
    state.asm = a.mov_r64_r64(state.asm, "r11", "r15")
    if depth > 0 then
      for i = 0 to depth - 1
        state.asm = a.mov_r64_membase_disp(state.asm, "r11", "r11", 8)
      end for
    end if
    lidc = state.label_id
    state.label_id = state.label_id + 1
    l_cap_full = "cap_load_full_" + lidc
    l_cap_done = "cap_load_done_" + lidc
    state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 0)
    state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_ENV_LOCAL)
    state.asm = a.jcc(state.asm, "ne", l_cap_full)
    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "r11", 8 + idx * 8)
    state.asm = a.jmp(state.asm, l_cap_done)
    state.asm = a.mark(state.asm, l_cap_full)
    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "r11", 16 + idx * 8)
    state.asm = a.mark(state.asm, l_cap_done)
    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r11", 8)
    return state
  end if

  if b.kind == "param" or b.kind == "local" then
    off = 0
    if typeof(b.offset) == "int" then off = b.offset end if
    state.asm = a.mov_rax_rsp_disp32(state.asm, off)
    if b.boxed then
      state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rax", 8)
    end if
    return state
  end if

  if b.kind == "global" then
    if typeof(b.label) != "string" or b.label == "" then
      state.diagnostics = state.diagnostics + ["Internal error: missing global label for '" + nm + "'"]
      return state
    end if
    state = _maybe_emit_module_init_guard_for_global_read(state, b, nm, 0)
    state.asm = a.mov_rax_rip_qword(state.asm, b.label)
    return state
  end if

  state.diagnostics = state.diagnostics + ["Internal error: unknown binding kind for '" + nm + "'"]
  return state
end function

function emit_store_var_scoped(state, name, node)
  nm = _coerce_name(name)
  target = nm
  mapped = ""
  if state.in_function then
    mapped = _func_global_lookup(state.func_global_map_index, nm)
    if mapped == "" then
      mapped = _func_global_lookup(state.func_global_map, nm)
    end if
    if mapped != "" then target = mapped end if
  end if

  state = ensure_binding_for_write(state, target, node)
  b = resolve_binding_for_write(state, target)

  if typeof(b) != "struct" and mapped != "" then
    state = declare_global_binding_root(state, mapped, node, false, 0)
    b = resolve_binding_for_write(state, mapped)
  end if

  if typeof(b) != "struct" then
    if state.in_function then
      state = declare_local_binding(state, nm, node, false, 0)
    else
      state = declare_global_binding(state, nm, node, false, 0)
    end if
    b = resolve_binding_for_write(state, nm)
  end if

  if typeof(b) != "struct" then
    state.diagnostics = state.diagnostics + ["Undefined variable '" + nm + "'"]
    return state
  end if

  if b.is_const then
    if b.const_initialized then
      state.diagnostics = state.diagnostics + ["Cannot assign to const '" + nm + "'"]
      return state
    end if
    b.const_initialized = true
  end if

  if b.kind == "capture" or (typeof(b.capture_index) == "int" and b.capture_index >= 0) then
    depth = 0
    if typeof(b.capture_depth) == "int" then depth = b.capture_depth end if
    idx = -1
    if typeof(b.capture_index) == "int" then idx = b.capture_index end if
    if idx < 0 then
      state.diagnostics = state.diagnostics + ["Internal error: capture missing index for '" + nm + "'"]
      return state
    end if
    state.asm = a.mov_r64_r64(state.asm, "r11", "r15")
    if depth > 0 then
      for i = 0 to depth - 1
        state.asm = a.mov_r64_membase_disp(state.asm, "r11", "r11", 8)
      end for
    end if
    lids = state.label_id
    state.label_id = state.label_id + 1
    l_cap_full_store = "cap_store_full_" + lids
    l_cap_done_store = "cap_store_done_" + lids
    state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 0)
    state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_ENV_LOCAL)
    state.asm = a.jcc(state.asm, "ne", l_cap_full_store)
    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "r11", 8 + idx * 8)
    state.asm = a.jmp(state.asm, l_cap_done_store)
    state.asm = a.mark(state.asm, l_cap_full_store)
    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "r11", 16 + idx * 8)
    state.asm = a.mark(state.asm, l_cap_done_store)
    state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8, "rax")
    return state
  end if

  if b.kind == "param" or b.kind == "local" then
    off = 0
    if typeof(b.offset) == "int" then off = b.offset end if
    if b.boxed then
      state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", off)
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8, "rax")
      return state
    end if
    state.asm = a.mov_rsp_disp32_rax(state.asm, off)
    return state
  end if

  if b.kind == "global" then
    if typeof(b.label) != "string" or b.label == "" then
      state.diagnostics = state.diagnostics + ["Internal error: missing global label for '" + nm + "'"]
      return state
    end if
    state.asm = a.mov_rip_qword_rax(state.asm, b.label)
    return state
  end if

  state.diagnostics = state.diagnostics + ["Internal error: unknown binding kind for '" + nm + "'"]
  return state
end function

function emit_store_existing_global(state, binding)
  nm = _coerce_name(binding)
  b = resolve_binding(state, nm)
  if typeof(b) != "struct" or b.kind != "global" then
    state.diagnostics = state.diagnostics + ["Undefined global variable '" + nm + "'"]
    return state
  end if
  if b.is_const then
    state.diagnostics = state.diagnostics + ["Cannot assign to const '" + nm + "'"]
    return state
  end if
  if typeof(b.label) != "string" or b.label == "" then
    state.diagnostics = state.diagnostics + ["Internal error: missing global label for '" + nm + "'"]
    return state
  end if
  state.asm = a.mov_rip_qword_rax(state.asm, b.label)
  return state
end function

function analysis_reset_function(state)
  state.decl_site_bindings = t.fastmap_new(128)
  state.function_locals =[]
  state.function_local_ids = t.fastmap_new(64)
  state.func_globals =[]
  state.func_global_map =[]
  state.func_global_map_index = t.fastmap_new(64)
  return state
end function

function analysis_layout_function_locals(state, base_offset)
  off = 0
  if typeof(base_offset) != "int" then base_offset = 0 end if
  fl = state.function_locals
  if typeof(fl) != "array" then return state end if
  if len(fl) <= 0 then return state end if
  for i = 0 to len(fl) - 1
    b = fl[i]
    if typeof(b) != "struct" then continue end if
    if b.kind != "local" then continue end if
    if typeof(b.offset) != "int" or b.offset == 0 then
      b.offset = base_offset + off
      off = off + 8
      fl[i] = b
    end if
  end for
  state.function_locals = fl
  return state
end function

function declare_function_global(state, local_name, qualified_name)
  ln = _coerce_name(local_name)
  qn = _coerce_name(qualified_name)
  if ln == "" then return state end if
  if state.in_function == false then
    state.diagnostics = state.diagnostics + ["'global' is only allowed inside functions"]
    return state
  end if
  if _check_reserved_ident(state, ln, 0) == false then return state end if
  if qn == "" then qn = ln end if
  if _check_reserved_ident(state, qn, 0) == false then return state end if

  existing = resolve_binding(state, ln)
  if typeof(existing) == "struct" then
    if existing.kind == "local" or existing.kind == "param" or existing.kind == "capture" or (typeof(existing.capture_index) == "int" and existing.capture_index >= 0) then
      state.diagnostics = state.diagnostics + ["global '" + ln + "' conflicts with an existing local/param binding"]
      return state
    end if
  end if

  b = resolve_binding(state, qn)
  if typeof(b) != "struct" or b.kind != "global" or b.depth != 0 then
    state = declare_global_binding_root(state, qn, 0, false, 0)
  end if

  state.func_globals = _append_unique(state.func_globals, ln)
  if typeof(state.func_global_map_index) != "struct" then
    state.func_global_map_index = t.fastmap_new(64)
  end if
  state.func_global_map_index = t.fastmap_set(state.func_global_map_index, ln, qn)
  state.func_global_map = _append_unique(state.func_global_map, [ln, qn])
  return state
end function
