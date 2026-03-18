package mlc.codegen.codegen_stmt
import std.string as s
import mlc.asm as a
import mlc.constants as c
import mlc.tools as t
import mlc.data as d
import mlc.minilang_parser as ml
import mlc.codegen.codegen_scope as scope
import mlc.codegen.codegen_expr as exprmod
import mlc.codegen.codegen_core as core
import mlc.codegen.codegen_memory as mem

function _join_qname(prefix, name)
  if typeof(prefix) != "string" or prefix == "" then return name end if
  if prefix[len(prefix) - 1] == "." then
    return prefix + name
  end if
  return prefix + "." + name
end function

function _coerce_name(v)
  if typeof(v) == "string" then return v end if
  if typeof(v) == "struct" then
    if typeof(v.name) == "string" then return v.name end if
    if typeof(v.value) == "string" then return v.value end if
  end if
  return "" + v
end function

function _mem_probe(state, tag)
  if typeof(state) != "struct" then return state end if
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) == false then return state end if
  lbl = tag
  if typeof(lbl) != "string" then lbl = "" + lbl end if
  print "[mem][cg] " + lbl + " used=" + heap_bytes_used() + " committed=" + heap_bytes_committed() + " reserved=" + heap_bytes_reserved() + " free=" + heap_free_bytes() + " blocks=" + heap_count()
  return state
end function

function _chunked_len(chunks, tail)
  n = 0
  if typeof(chunks) == "array" and len(chunks) > 0 then
    for i = 0 to len(chunks) - 1
      ch = chunks[i]
      if typeof(ch) == "array" then n = n + len(ch) end if
    end for
  end if
  n = n + t.arr_chunk_tail_len(tail)
  return n
end function

function _heap_cfg_get_any(state, key)
  cfg = 0
  if typeof(state) == "struct" then cfg = state.heap_config end if
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

function _heap_cfg_get_int(state, key, defaultv)
  v = _heap_cfg_get_any(state, key)
  if typeof(v) == "int" then return v end if
  return defaultv
end function

function _heap_cfg_get_bool(state, key, defaultv)
  v = _heap_cfg_get_any(state, key)
  if typeof(v) == "bool" then return v end if
  return defaultv
end function

function _set_user_function(state, qname, fn_node)
  arr = state.user_functions
  if typeof(arr) != "array" then arr =[] end if
  if len(arr) > 0 then
    for i = 0 to len(arr) - 1
      p = arr[i]
      if typeof(p) == "array" and len(p) == 2 and p[0] == qname then
        arr[i] =[qname, fn_node]
        state.user_functions = arr
        return state
      end if
    end for
  end if
  state.user_functions = arr +[[qname, fn_node]]
  return state
end function

function _foreach_body(st)
  if typeof(st) == "struct" and typeof(st.body) == "array" then
    if typeof(st.iterable) != "void" and typeof(st.var) != "void" then
      return st.body
    end if
  end if
  return 0
end function

function _emit_stmt_list(state, stmt_seq_emit)
  emit_items = stmt_seq_emit
  if typeof(emit_items) != "array" or len(emit_items) <= 0 then return state end if
  emit_count = len(emit_items)
  emit_idx = 0
  while emit_idx < emit_count
    state = cg_emit_stmt(state, emit_items[emit_idx])
    emit_idx = emit_idx + 1
  end while
  return state
end function

function _emit_condition_nonvoid_guard(state, cond_expr, ok_label, false_label)
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_VOID)
  state.asm = a.jcc(state.asm, "ne", ok_label)
  state = core.emit_dbg_line(state, cond_expr)
  state = exprmod._emit_make_error_const(state, c.ERR_VOID_OP, "Cannot use void as condition")
  state = exprmod._emit_auto_errprop(state)
  // If not propagated (e.g. top-level), continue control flow as false.
  state.asm = a.jmp(state.asm, false_label)
  state.asm = a.mark(state.asm, ok_label)
  return state
end function

function _breakctx_make(kind, break_label, continue_label, break_depth, continue_depth)
  return [kind, break_label, continue_label, break_depth, continue_depth]
end function

function _breakctx_kind(ctx)
  if typeof(ctx) == "array" and len(ctx) >= 1 and typeof(ctx[0]) == "string" then return ctx[0] end if
  return "loop"
end function

function _breakctx_break_label(ctx)
  if typeof(ctx) == "array" then
    if len(ctx) >= 2 and typeof(ctx[0]) == "string" and typeof(ctx[1]) == "string" then return ctx[1] end if
    if len(ctx) >= 1 and typeof(ctx[0]) == "string" then return ctx[0] end if
  end if
  return ""
end function

function _breakctx_continue_label(ctx)
  if typeof(ctx) == "array" then
    if len(ctx) >= 3 and typeof(ctx[0]) == "string" and typeof(ctx[2]) == "string" then return ctx[2] end if
    if len(ctx) >= 2 and typeof(ctx[1]) == "string" then return ctx[1] end if
  end if
  return ""
end function

function _breakctx_break_depth(ctx, fallback)
  if typeof(ctx) == "array" and len(ctx) >= 4 and typeof(ctx[3]) == "int" then return ctx[3] end if
  return fallback
end function

function _breakctx_continue_depth(ctx, fallback)
  if typeof(ctx) == "array" and len(ctx) >= 5 and typeof(ctx[4]) == "int" then return ctx[4] end if
  return fallback
end function

function _breakstack_pop(state)
  if typeof(state.break_stack) != "array" or len(state.break_stack) <= 0 then return state end if
  tmp = slice(state.break_stack, 0, len(state.break_stack) - 1)
  if typeof(tmp) == "array" then
    state.break_stack = tmp
  else
    state.break_stack = []
  end if
  return state
end function

function _emit_switch_stmt(state, stmt)
  sid = state.label_id
  state.label_id = state.label_id + 1
  l_end = "switch_end_" + sid
  l_default = "switch_default_" + sid

  depth_before = scope.cg_scope_depth(state)
  state.break_stack = state.break_stack + [_breakctx_make("switch", l_end, "", depth_before, depth_before)]

  state = exprmod.cg_emit_expr(state, stmt.expr)
  state.asm = a.mov_r64_r64(state.asm, "r12", "rax")

  cases = []
  if typeof(stmt.cases) == "array" then cases = stmt.cases end if

  body_labels_chunks = []
  body_labels_tail = []
  if len(cases) > 0 then
    for i = 0 to len(cases) - 1
      appbl = t.arr_chunked_push(body_labels_chunks, body_labels_tail, "switch_case_body_" + sid + "_" + i, 32)
      body_labels_chunks = appbl[0]
      body_labels_tail = appbl[1]
    end for
  end if
  body_labels = t.arr_chunked_finish(body_labels_chunks, body_labels_tail)

  if len(cases) > 0 then
    for i = 0 to len(cases) - 1
      cs = cases[i]
      if typeof(cs) != "struct" then continue end if

      l_next = "switch_case_next_" + sid + "_" + i
      l_hit = body_labels[i]

      if typeof(cs.kind) == "string" and cs.kind == "values" then
        vals = []
        if typeof(cs.values) == "array" then vals = cs.values end if
        if len(vals) > 0 then
          for j = 0 to len(vals) - 1
            l_val_next = "switch_val_next_" + sid + "_" + i + "_" + j
            state = exprmod.cg_emit_expr(state, vals[j])
            state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
            state.asm = a.mov_r64_r64(state.asm, "rcx", "r12")
            state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
            state.asm = a.call(state.asm, "fn_val_eq")
            state = core.emit_jmp_if_false_rax(state, l_val_next)
            state.asm = a.jmp(state.asm, l_hit)
            state.asm = a.mark(state.asm, l_val_next)
          end for
        end if
        state.asm = a.jmp(state.asm, l_next)
      else
        if typeof(cs.kind) == "string" and cs.kind == "range" then
          state = exprmod.cg_emit_expr(state, cs.range_start)
          state.asm = a.mov_rsp_disp32_rax(state.asm, 0x1B0)
          state = exprmod.cg_emit_expr(state, cs.range_end)
          state.asm = a.mov_rsp_disp32_rax(state.asm, 0x1B8)

          state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x1B0)
          state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x1B8)

          state.asm = a.mov_r64_r64(state.asm, "r8", "r10")
          state.asm = a.and_r64_imm(state.asm, "r8", 7)
          state.asm = a.cmp_r64_imm(state.asm, "r8", c.TAG_INT)
          state.asm = a.jcc(state.asm, "ne", l_next)

          state.asm = a.mov_r64_r64(state.asm, "r8", "r11")
          state.asm = a.and_r64_imm(state.asm, "r8", 7)
          state.asm = a.cmp_r64_imm(state.asm, "r8", c.TAG_INT)
          state.asm = a.jcc(state.asm, "ne", l_next)

          l_noswap = "switch_rng_noswap_" + sid + "_" + i
          state.asm = a.cmp_r64_r64(state.asm, "r10", "r11")
          state.asm = a.jcc(state.asm, "le", l_noswap)
          state.asm = a.mov_r64_r64(state.asm, "r8", "r10")
          state.asm = a.mov_r64_r64(state.asm, "r10", "r11")
          state.asm = a.mov_r64_r64(state.asm, "r11", "r8")
          state.asm = a.mark(state.asm, l_noswap)

          state.asm = a.mov_r64_r64(state.asm, "rax", "r12")
          state.asm = a.mov_r64_r64(state.asm, "r8", "rax")
          state.asm = a.and_r64_imm(state.asm, "r8", 7)
          state.asm = a.cmp_r64_imm(state.asm, "r8", c.TAG_INT)
          state.asm = a.jcc(state.asm, "ne", l_next)

          state.asm = a.cmp_r64_r64(state.asm, "rax", "r10")
          state.asm = a.jcc(state.asm, "l", l_next)
          state.asm = a.cmp_r64_r64(state.asm, "rax", "r11")
          state.asm = a.jcc(state.asm, "g", l_next)
          state.asm = a.jmp(state.asm, l_hit)
        else
          state.asm = a.jmp(state.asm, l_next)
        end if
      end if

      state.asm = a.mark(state.asm, l_next)
    end for
  end if

  if typeof(stmt.default_body) == "array" and len(stmt.default_body) > 0 then
    state.asm = a.jmp(state.asm, l_default)
  else
    state.asm = a.jmp(state.asm, l_end)
  end if

  if len(cases) > 0 then
    for ci = 0 to len(cases) - 1
      cs2 = cases[ci]
      state.asm = a.mark(state.asm, body_labels[ci])
      state = scope.cg_scope_enter(state)
      if typeof(cs2) == "struct" and typeof(cs2.body) == "array" and len(cs2.body) > 0 then
        state = _emit_stmt_list(state, cs2.body)
      end if
      state = scope.cg_scope_leave(state)
      state.asm = a.jmp(state.asm, l_end)
    end for
  end if

  state.asm = a.mark(state.asm, l_default)
  state = scope.cg_scope_enter(state)
  if typeof(stmt.default_body) == "array" and len(stmt.default_body) > 0 then
    state = _emit_stmt_list(state, stmt.default_body)
  end if
  state = scope.cg_scope_leave(state)

  state.asm = a.mark(state.asm, l_end)
  state = _breakstack_pop(state)
  return state
end function

function _dotted_name_expr(ex)
  if typeof(ex) != "struct" then return "" end if
  if ex.node_kind == "Var" then
    return _coerce_name(ex.name)
  end if
  if ex.node_kind == "Member" then
    left = _dotted_name_expr(ex.target)
    if left == "" then return "" end if
    right = _coerce_name(ex.name)
    if right == "" then return "" end if
    return left + "." + right
  end if
  return ""
end function

function _emit_struct_field_index_dispatch_local(state, field, struct_id_reg, out_reg, ok_label, fail_label, tag)
  pairs_b = t.arr_chunk_new(32)
  arr = state.struct_fields
  if typeof(arr) == "array" and len(arr) > 0 then
    for i = 0 to len(arr) - 1
      it = arr[i]
      sname = ""
      flds = 0
      if typeof(it) == "struct" then
        sname = _coerce_name(it.key)
        flds = it.values
      else
        if typeof(it) == "array" and len(it) >= 2 then
          sname = _coerce_name(it[0])
          flds = it[1]
        end if
      end if
      if sname == "" then continue end if
      if typeof(flds) != "array" or len(flds) <= 0 then continue end if

      fidx = -1
      for fi = 0 to len(flds) - 1
        if _coerce_name(flds[fi]) == field then
          fidx = fi
          break
        end if
      end for
      if fidx < 0 then continue end if

      sid = _named_int_get(state.struct_ids, sname, 0)
      if sid != 0 then
        pairs_b = t.arr_chunk_push(pairs_b, [sid, fidx])
      end if
    end for
  end if
  pairs = t.arr_chunk_finish(pairs_b)

  if typeof(pairs) != "array" or len(pairs) <= 0 then
    state.asm = a.jmp(state.asm, fail_label)
    return state
  end if

  if typeof(tag) != "string" or tag == "" then tag = "sfid" end if
  lid = state.label_id
  state.label_id = state.label_id + 1
  hits_b = t.arr_chunk_new(32)

  for j = 0 to len(pairs) - 1
    sid = pairs[j][0]
    fidx2 = pairs[j][1]
    l_hit = tag + "_hit_" + lid + "_" + j
    hits_b = t.arr_chunk_push(hits_b, [l_hit, fidx2])
    state.asm = a.cmp_r32_imm(state.asm, struct_id_reg, sid)
    state.asm = a.jcc(state.asm, "e", l_hit)
  end for
  hits = t.arr_chunk_finish(hits_b)

  state.asm = a.jmp(state.asm, fail_label)

  for h = 0 to len(hits) - 1
    l_hit2 = hits[h][0]
    fidx3 = hits[h][1]
    state.asm = a.mark(state.asm, l_hit2)
    state.asm = a.mov_r32_imm32(state.asm, out_reg, fidx3)
    state.asm = a.jmp(state.asm, ok_label)
  end for
  return state
end function

function cg_emit_stmt(state, stmt)
  if typeof(stmt) != "struct" then return state end if
  k = stmt.node_kind

  sf0 = _decl_st_file(stmt)
  if typeof(sf0) == "string" and sf0 != "" then
    state.current_file_prefix = _strpair_get(state.file_prefix_map, sf0)
  else
    state.current_file_prefix = ""
  end if

  if k == "NamespaceDecl" then
    if typeof(stmt.name) == "string" then state.current_file_prefix = stmt.name end if
    return state
  end if

  if k == "NamespaceDef" then
    old_pref = state.current_qname_prefix
    state.current_qname_prefix = _join_qname(old_pref, _coerce_name(stmt.name))
    state = scope.cg_scope_enter(state)
    state = _emit_stmt_list(state, stmt.body)
    state = scope.cg_scope_leave(state)
    state.current_qname_prefix = old_pref
    return state
  end if

  if k == "Import" then return state end if
  if k == "ImportStmt" then return state end if
  if k == "StructDef" then return state end if
  if k == "EnumDef" then return state end if
  if k == "ExternFunctionDef" then return state end if

  if k == "FunctionDef" then
    qn_fn = _coerce_name(stmt.name)
    if s.contains(qn_fn, ".") == false then
      qn_fn = _join_qname(state.current_qname_prefix, qn_fn)
    end if
    if qn_fn == "" then return state end if

    if state.in_function == false then
      state = _set_user_function(state, qn_fn, stmt)
      bfn = scope.cg_resolve_binding(state, qn_fn)
      if typeof(bfn) != "struct" then
        state = scope.declare_global_binding_root(state, qn_fn, stmt, true, 0)
      end if
      return state
    end if

    // Nested function statement: create first-class function value at runtime.
    local_name = _coerce_name(stmt.name)
    if local_name == "" then local_name = qn_fn end if

    nested_id = state.label_id
    state.label_id = state.label_id + 1
    code_name = qn_fn + ".__n" + nested_id
    stmt.name = code_name
    state = _set_user_function(state, code_name, stmt)

    ar = 0
    if typeof(stmt.params) == "array" then ar = len(stmt.params) end if
    state.asm = a.mov_rcx_imm32(state.asm, 24)
    state.asm = a.call(state.asm, "fn_alloc")
    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_FUNCTION, false)
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, ar, false)
    state.asm = a.lea_rdx_rip(state.asm, "fn_user_" + code_name)
    state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8, "rdx")
    need_parent = false
    if typeof(stmt._ml_captures) == "array" and len(stmt._ml_captures) > 0 then need_parent = true end if
    if typeof(stmt._ml_env_hop) == "bool" and stmt._ml_env_hop then need_parent = true end if
    if need_parent then
      env_root = state.current_env_root_off
      if typeof(env_root) == "int" and env_root > 0 then
        state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", env_root)
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "r10")
      else
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "r15")
      end if
    else
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 16, t.enc_void(), true)
    end if
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state = scope.emit_store_var_scoped(state, local_name)
    return state
  end if

  if k == "Switch" then
    return _emit_switch_stmt(state, stmt)
  end if

  if k == "If" then
    lid_if = state.label_id
    state.label_id = state.label_id + 1
    l_else = "if_else_" + lid_if
    l_end = "if_end_" + lid_if
    has_elifs = typeof(stmt.elifs) == "array" and len(stmt.elifs) > 0
    l_first_false = l_else
    if has_elifs then
      l_first_false = "if_elif_" + lid_if + "_0"
    end if

    state = exprmod.cg_emit_expr(state, stmt.cond)
    l_if_ok = "if_head_cond_ok_" + lid_if
    state = _emit_condition_nonvoid_guard(state, stmt.cond, l_if_ok, l_first_false)
    state = core.emit_jmp_if_false_rax(state, l_first_false)
    state = scope.cg_scope_enter(state)
    state = _emit_stmt_list(state, stmt.then_body)
    state = scope.cg_scope_leave(state)
    state.asm = a.jmp(state.asm, l_end)

    if has_elifs then
      for if_ei = 0 to len(stmt.elifs) - 1
        curr_lbl = "if_elif_" + lid_if + "_" + if_ei
        next_lbl = l_else
        if if_ei + 1 < len(stmt.elifs) then
          next_lbl = "if_elif_" + lid_if + "_" + (if_ei + 1)
        end if
        state.asm = a.mark(state.asm, curr_lbl)

        eb = stmt.elifs[if_ei]
        if typeof(eb) != "array" or len(eb) < 2 then
          state.asm = a.jmp(state.asm, next_lbl)
          continue
        end if

        state = exprmod.cg_emit_expr(state, eb[0])
        l_elif_ok = "if_cond_ok_" + lid_if + "_" + if_ei
        state = _emit_condition_nonvoid_guard(state, eb[0], l_elif_ok, next_lbl)
        state = core.emit_jmp_if_false_rax(state, next_lbl)
        state = scope.cg_scope_enter(state)
        state = _emit_stmt_list(state, eb[1])
        state = scope.cg_scope_leave(state)
        state.asm = a.jmp(state.asm, l_end)
      end for
    end if

    state.asm = a.mark(state.asm, l_else)
    if typeof(stmt.else_body) == "array" and len(stmt.else_body) > 0 then
      state = scope.cg_scope_enter(state)
      state = _emit_stmt_list(state, stmt.else_body)
      state = scope.cg_scope_leave(state)
    end if
    state.asm = a.mark(state.asm, l_end)
    return state
  end if

  if k == "GlobalDecl" then
    if state.in_function == false then
      state.diagnostics = state.diagnostics +["'global' is only allowed inside functions"]
      return state
    end if
    if typeof(stmt.names) == "array" and len(stmt.names) > 0 then
      for gi = 0 to len(stmt.names) - 1
        gnm = _coerce_name(stmt.names[gi])
        if gnm == "" then continue end if
        gq = _resolve_global_target(state, gnm)
        state = scope.declare_function_global(state, gnm, gq)
      end for
    end if
    return state
  end if

  if k == "ConstDecl" then
    nm_c = _coerce_name(stmt.name)
    if nm_c == "" then return state end if
    qn_c = nm_c
    if state.in_function == false and s.contains(qn_c, ".") == false then
      qn_c = _join_qname(state.current_qname_prefix, qn_c)
    end if

    if state.in_function then
      bc = scope.cg_resolve_binding_for_write(state, qn_c)
      if typeof(bc) != "struct" then
        state = scope.cg_declare_binding(state, qn_c, "local", true, stmt.expr, void, stmt)
      end if
      state = exprmod.cg_emit_expr(state, stmt.expr)
      state = scope.emit_store_var_scoped(state, qn_c)
      return state
    end if

    if _is_constexpr_expr(state, stmt.expr) == false then
      state.diagnostics = state.diagnostics + ["const initializer must be constexpr: " + qn_c]
      return state
    end if

    cv = exprmod.cg_expr_try_const_value(state, stmt.expr)
    bct = scope.cg_resolve_binding(state, qn_c)
    if typeof(bct) != "struct" then
      state = scope.declare_global_binding_root(state, qn_c, stmt, true, stmt.expr)
    end if

    if cv.ok == false then
      state.diagnostics = state.diagnostics + ["const '" + qn_c + "' is not constexpr-evaluable"]
      return state
    end if

    state = scope.cg_set_const_binding_value(state, qn_c, cv.value)
    return state
  end if

  if k == "Assign" then
    nm_a = _coerce_name(stmt.name)
    if nm_a == "" then return state end if
    qn_a = nm_a
    if state.in_function == false and s.contains(qn_a, ".") == false then
      qn_a = _join_qname(state.current_qname_prefix, qn_a)
    end if
    state = exprmod.cg_emit_expr(state, stmt.expr)
    state = scope.emit_store_var_scoped(state, qn_a)
    return state
  end if

  if k == "SetMember" then
    obj_expr = stmt.obj
    if typeof(obj_expr) != "struct" and typeof(stmt.target) == "struct" then
      obj_expr = stmt.target
    end if
    field = _coerce_name(stmt.field)
    if field == "" then field = _coerce_name(stmt.name) end if

    qobj = _dotted_name_expr(obj_expr)
    if qobj != "" then
      parts = s.split(qobj, ".")
      root = ""
      if typeof(parts) == "array" and len(parts) > 0 then root = _coerce_name(parts[0]) end if
      bound = false
      if root != "" then
        rb = scope.cg_resolve_binding(state, root)
        if typeof(rb) != "struct" then
          rq = exprmod._qualify_identifier(state, root)
          if typeof(rq) == "string" and rq != "" and rq != root then
            rb = scope.cg_resolve_binding(state, rq)
          end if
        end if
        bound = typeof(rb) == "struct"
      end if
      if bound == false and field != "" then
        full = exprmod._apply_import_alias(state, qobj + "." + field)
        state = exprmod.cg_emit_expr(state, stmt.expr)
        state = scope.emit_store_existing_global(state, full)
        return state
      end if
    end if

    state = exprmod.cg_emit_expr(state, obj_expr)
    state.asm = a.mov_r64_r64(state.asm, "r12", "rax")
    state = exprmod.cg_emit_expr(state, stmt.expr)
    state.asm = a.mov_r64_r64(state.asm, "r13", "rax")

    lid_sm = state.label_id
    state.label_id = state.label_id + 1
    l_fail_sm = "setm_fail_" + lid_sm
    l_ok_sm = "setm_ok_" + lid_sm
    l_done_sm = "setm_done_" + lid_sm

    state.asm = a.mov_r64_r64(state.asm, "r10", "r12")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_fail_sm)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r12", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRUCT)
    state.asm = a.jcc(state.asm, "ne", l_fail_sm)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r12", 8)

    state = _emit_struct_field_index_dispatch_local(state, field, "edx", "ecx", l_ok_sm, l_fail_sm, "setm_" + lid_sm)

    state.asm = a.mark(state.asm, l_ok_sm)
    state.asm = a.mov_mem_bis_r64(state.asm, "r12", "rcx", 8, 16, "r13")
    state.asm = a.jmp(state.asm, l_done_sm)

    state.asm = a.mark(state.asm, l_fail_sm)
    state.asm = a.mark(state.asm, l_done_sm)
    return state
  end if

  if k == "SetIndex" then
    lid_si = state.label_id
    state.label_id = state.label_id + 1
    l_rhs_void = "seti_rhs_void_" + lid_si
    l_bad_target = "seti_bad_target_" + lid_si
    l_bad_index = "seti_bad_index_" + lid_si
    l_oob = "seti_oob_" + lid_si
    l_bad_byte = "seti_bad_byte_" + lid_si
    l_done_si = "seti_done_" + lid_si
    l_type_ok = "seti_type_ok_" + lid_si
    l_idx_ok = "seti_ok_" + lid_si
    l_store_bytes = "seti_store_bytes_" + lid_si

    tmp_seti_off = core.alloc_expr_temps(state, 16)
    tmp_seti_ok = true
    if typeof(tmp_seti_off) != "int" or tmp_seti_off <= 0 then
      tmp_seti_off = 0x190
      tmp_seti_ok = false
    end if
    target_off = tmp_seti_off
    index_off = tmp_seti_off + 8

    state = exprmod.cg_emit_expr(state, stmt.target)
    state.asm = a.mov_rsp_disp32_rax(state.asm, target_off)
    state = exprmod.cg_emit_expr(state, stmt.index)
    state.asm = a.mov_rsp_disp32_rax(state.asm, index_off)
    state = exprmod.cg_emit_expr(state, stmt.expr)
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")

    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", target_off)
    state.asm = a.mov_rax_rsp_disp32(state.asm, index_off)
    if tmp_seti_ok then state = core.free_expr_temps(state, 16) end if

    state.asm = a.cmp_r64_imm(state.asm, "r10", t.enc_void())
    state.asm = a.jcc(state.asm, "e", l_rhs_void)

    state.asm = a.mov_r64_r64(state.asm, "r8", "r11")
    state.asm = a.and_r64_imm(state.asm, "r8", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r8", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_bad_target)
    state.asm = a.test_r64_r64(state.asm, "r11", "r11")
    state.asm = a.jcc(state.asm, "e", l_bad_target)

    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
    state.asm = a.jcc(state.asm, "e", l_type_ok)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "e", l_type_ok)
    state.asm = a.jmp(state.asm, l_bad_target)
    state.asm = a.mark(state.asm, l_type_ok)

    state.asm = a.mov_r64_r64(state.asm, "r8", "rax")
    state.asm = a.and_r64_imm(state.asm, "r8", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r8", c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_bad_index)

    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.sar_r64_imm8(state.asm, "rcx", 3)

    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 4)
    state.asm = a.cmp_r32_imm(state.asm, "ecx", 0)
    state.asm = a.jcc(state.asm, "ge", l_idx_ok)
    state.asm = a.add_r64_r64(state.asm, "rcx", "rdx")
    state.asm = a.mark(state.asm, l_idx_ok)
    state.asm = a.cmp_r32_imm(state.asm, "ecx", 0)
    state.asm = a.jcc(state.asm, "l", l_oob)
    state.asm = a.cmp_r32_r32(state.asm, "ecx", "edx")
    state.asm = a.jcc(state.asm, "ge", l_oob)

    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "e", l_store_bytes)

    state.asm = a.mov_mem_bis_r64(state.asm, "r11", "rcx", 8, 8, "r10")
    state.asm = a.jmp(state.asm, l_done_si)

    state.asm = a.mark(state.asm, l_store_bytes)
    state.asm = a.mov_r64_r64(state.asm, "r8", "r10")
    state.asm = a.and_r64_imm(state.asm, "r8", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r8", c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_bad_byte)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
    state.asm = a.jcc(state.asm, "l", l_bad_byte)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 255)
    state.asm = a.jcc(state.asm, "g", l_bad_byte)
    // Preserve low byte before reusing RAX for address arithmetic.
    state.asm = a.mov_r8_r8(state.asm, "dl", "al")
    // Use RAX as byte-store base to avoid extended-reg byte-store encoding pitfalls.
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.add_r64_r64(state.asm, "rax", "rcx")
    state.asm = a.add_r64_imm(state.asm, "rax", 8)
    state.asm = a.mov_membase_disp_r8(state.asm, "rax", 0, "dl")
    state.asm = a.jmp(state.asm, l_done_si)

    state.asm = a.mark(state.asm, l_rhs_void)
    state = core.emit_dbg_line(state, stmt)
    state = exprmod._emit_make_error_const(state, c.ERR_VOID_OP, "Cannot assign void via index")
    state = exprmod._emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_done_si)

    state.asm = a.mark(state.asm, l_bad_target)
    state = core.emit_dbg_line(state, stmt)
    state = exprmod._emit_make_error_const(state, c.ERR_INDEX_TARGET_TYPE, "Index assignment requires array or bytes")
    state = exprmod._emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_done_si)

    state.asm = a.mark(state.asm, l_bad_index)
    state = core.emit_dbg_line(state, stmt)
    state = exprmod._emit_make_error_const(state, c.ERR_INDEX_TYPE, "Index must be an int")
    state = exprmod._emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_done_si)

    state.asm = a.mark(state.asm, l_oob)
    state = core.emit_dbg_line(state, stmt)
    state = exprmod._emit_make_error_const(state, c.ERR_INDEX_OOB, "Array index out of bounds")
    state = exprmod._emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_done_si)

    state.asm = a.mark(state.asm, l_bad_byte)
    state = core.emit_dbg_line(state, stmt)
    state = exprmod._emit_make_error_const(state, c.ERR_VOID_OP, "Byte value must be an int in range 0..255")
    state = exprmod._emit_auto_errprop(state)

    state.asm = a.mark(state.asm, l_done_si)
    return state
  end if

  if k == "ExprStmt" then
    return exprmod.cg_emit_expr(state, stmt.expr)
  end if

  if k == "Print" then
    if typeof(stmt.expr) == "struct" and stmt.expr.node_kind == "Str" then
      lbl_p = "str_" + len(state.rdata.labels)
      state.rdata = d.rdata_add_str_nl(state.rdata, lbl_p, stmt.expr.value, true)
      ln_p = 0
      if typeof(state.rdata.labels) == "array" then
        for li = 0 to len(state.rdata.labels) - 1
          lbi = state.rdata.labels[li]
          if typeof(lbi) == "struct" and lbi.name == lbl_p then
            if typeof(lbi.length) == "int" then ln_p = lbi.length end if
            break
          end if
        end for
      end if
      return core.emit_writefile(state, lbl_p, ln_p)
    end if

    state = exprmod.cg_emit_expr(state, stmt.expr)
    lid_p = state.label_id
    state.label_id = state.label_id + 1
    l_int = "print_int_" + lid_p
    l_bool = "print_bool_" + lid_p
    l_enum = "print_enum_" + lid_p
    l_ptr = "print_ptr_" + lid_p
    l_uns = "print_uns_" + lid_p
    l_end = "print_end_" + lid_p

    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
    state.asm = a.jcc(state.asm, "e", l_int)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_BOOL)
    state.asm = a.jcc(state.asm, "e", l_bool)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_ENUM)
    state.asm = a.jcc(state.asm, "e", l_enum)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "e", l_ptr)
    state.asm = a.jmp(state.asm, l_uns)

    state.asm = a.mark(state.asm, l_int)
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, "fn_int_to_dec")
    state.asm = a.mov_r32_r32(state.asm, "r8d", "edx")
    state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
    state = core.emit_writefile_ptr_len(state)
    state = core.emit_writefile(state, "nl", 1)
    state.asm = a.jmp(state.asm, l_end)

    state.asm = a.mark(state.asm, l_bool)
    state.asm = a.test_rax_imm32(state.asm, 8)
    l_bfalse = "print_bfalse_" + lid_p
    state.asm = a.jcc(state.asm, "z", l_bfalse)
    state = core.emit_writefile(state, "true_nn", 4)
    state = core.emit_writefile(state, "nl", 1)
    state.asm = a.jmp(state.asm, l_end)
    state.asm = a.mark(state.asm, l_bfalse)
    state = core.emit_writefile(state, "false_nn", 5)
    state = core.emit_writefile(state, "nl", 1)
    state.asm = a.jmp(state.asm, l_end)

    state.asm = a.mark(state.asm, l_enum)
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, "fn_value_to_string")
    state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rax", 4)
    state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "rax", 8)
    state = core.emit_writefile_ptr_len(state)
    state = core.emit_writefile(state, "nl", 1)
    state.asm = a.jmp(state.asm, l_end)

    state.asm = a.mark(state.asm, l_ptr)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
    l_pstr = "print_pstr_" + lid_p
    l_parr = "print_parr_" + lid_p
    l_pbytes = "print_pbytes_" + lid_p
    l_pflt = "print_pflt_" + lid_p
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
    state.asm = a.jcc(state.asm, "e", l_pstr)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
    state.asm = a.jcc(state.asm, "e", l_parr)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "e", l_pbytes)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FLOAT)
    state.asm = a.jcc(state.asm, "e", l_pflt)
    state.asm = a.jmp(state.asm, l_uns)

    state.asm = a.mark(state.asm, l_pstr)
    state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rax", 4)
    state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "rax", 8)
    state = core.emit_writefile_ptr_len(state)
    state = core.emit_writefile(state, "nl", 1)
    state.asm = a.jmp(state.asm, l_end)

    state.asm = a.mark(state.asm, l_parr)
    state = core.emit_writefile(state, "array_nn", 7)
    state = core.emit_writefile(state, "nl", 1)
    state.asm = a.jmp(state.asm, l_end)

    state.asm = a.mark(state.asm, l_pbytes)
    state = core.emit_writefile(state, "uns_nn", 13)
    state = core.emit_writefile(state, "nl", 1)
    state.asm = a.jmp(state.asm, l_end)

    state.asm = a.mark(state.asm, l_pflt)
    state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm0", "rax", 8)
    state.asm = a.mov_r32_imm32(state.asm, "edx", 15)
    state.asm = a.lea_rax_rip(state.asm, "floatbuf")
    state.asm = a.mov_r64_r64(state.asm, "r8", "rax")
    state.asm = a.mov_rax_rip_qword(state.asm, "iat__gcvt")
    state.asm = a.call_rax(state.asm)
    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, "fn_strlen")
    state.asm = a.mov_r32_r32(state.asm, "r8d", "edx")
    state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
    state = core.emit_writefile_ptr_len(state)
    state = core.emit_writefile(state, "nl", 1)
    state.asm = a.jmp(state.asm, l_end)

    state.asm = a.mark(state.asm, l_uns)
    state = core.emit_writefile(state, "uns_nn", 13)
    state = core.emit_writefile(state, "nl", 1)

    state.asm = a.mark(state.asm, l_end)
    return state
  end if

  if k == "While" then
    lid_w = state.label_id
    state.label_id = state.label_id + 1
    l_top = "while_top_" + lid_w
    l_cont = "while_cont_" + lid_w
    l_end = "while_end_" + lid_w

    depth_w = scope.cg_scope_depth(state)
    state.break_stack = state.break_stack + [_breakctx_make("loop", l_end, l_cont, depth_w, depth_w)]
    state.asm = a.mark(state.asm, l_top)
    state = exprmod.cg_emit_expr(state, stmt.cond)
    l_wcond_ok = "while_cond_ok_" + lid_w
    state = _emit_condition_nonvoid_guard(state, stmt.cond, l_wcond_ok, l_end)
    state = core.emit_jmp_if_false_rax(state, l_end)
    state = scope.cg_scope_enter(state)
    state = _emit_stmt_list(state, stmt.body)
    state = scope.cg_scope_leave(state)
    state.asm = a.mark(state.asm, l_cont)
    state.asm = a.jmp(state.asm, l_top)
    state.asm = a.mark(state.asm, l_end)
    state = _breakstack_pop(state)
    return state
  end if

  if k == "DoWhile" then
    lid_dw = state.label_id
    state.label_id = state.label_id + 1
    l_body = "dowhile_body_" + lid_dw
    l_cont = "dowhile_cont_" + lid_dw
    l_end = "dowhile_end_" + lid_dw

    depth_dw = scope.cg_scope_depth(state)
    state.break_stack = state.break_stack + [_breakctx_make("loop", l_end, l_cont, depth_dw, depth_dw)]
    state.asm = a.mark(state.asm, l_body)
    state = scope.cg_scope_enter(state)
    state = _emit_stmt_list(state, stmt.body)
    state = scope.cg_scope_leave(state)
    state.asm = a.mark(state.asm, l_cont)
    state = exprmod.cg_emit_expr(state, stmt.cond)
    l_dwcond_ok = "dowhile_cond_ok_" + lid_dw
    state = _emit_condition_nonvoid_guard(state, stmt.cond, l_dwcond_ok, l_end)
    state = core.emit_jmp_if_false_rax(state, l_end)
    state.asm = a.jmp(state.asm, l_body)
    state.asm = a.mark(state.asm, l_end)
    state = _breakstack_pop(state)
    return state
  end if

  if k == "For" then
    v = _coerce_name(stmt.var)
    if v == "" then return state end if
    qv = v
    if state.in_function == false then
      qv = _join_qname(state.current_qname_prefix, v)
    end if
    state = scope.cg_scope_enter(state)
    bind_kind_for = "local"
    if state.in_function == false then bind_kind_for = "global" end if
    // For-loop variable is a fresh declaration in loop scope (Python parity).
    state = scope.cg_declare_binding(state, qv, bind_kind_for, false, 0, 0, stmt)
    state = exprmod.cg_emit_expr(state, stmt.start)
    state = scope.emit_store_var_scoped(state, qv)

    lid_f = state.label_id
    state.label_id = state.label_id + 1
    l_top_f = "for_top_" + lid_f
    l_cont_f = "for_cont_" + lid_f
    l_end_f = "for_end_" + lid_f
    l_step_pos_f = "for_step_pos_" + lid_f
    l_step_done_f = "for_step_done_" + lid_f
    q_end_f = "__for_end_" + lid_f
    q_step_f = "__for_step_" + lid_f
    if state.in_function == false then
      q_end_f = _join_qname(state.current_qname_prefix, q_end_f)
      q_step_f = _join_qname(state.current_qname_prefix, q_step_f)
    end if
    state = scope.cg_declare_binding(state, q_end_f, bind_kind_for, false, 0, 0, stmt)
    state = scope.cg_declare_binding(state, q_step_f, bind_kind_for, false, 0, 0, stmt)

    depth_for_outer = scope.cg_scope_depth(state) - 1
    depth_for_loop = scope.cg_scope_depth(state)
    state.break_stack = state.break_stack + [_breakctx_make("loop", l_end_f, l_cont_f, depth_for_outer, depth_for_loop)]

    state = exprmod.cg_emit_expr(state, stmt.end_expr)
    state = scope.emit_store_var_scoped(state, q_end_f)

    // step = (start <= end) ? +1 : -1  (encoded int)
    state = scope.emit_load_var_scoped(state, qv)
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state = scope.emit_load_var_scoped(state, q_end_f)
    state.asm = a.cmp_r64_r64(state.asm, "rax", "r10")
    state.asm = a.jcc(state.asm, "ge", l_step_pos_f)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_int(-1))
    state = scope.emit_store_var_scoped(state, q_step_f)
    state.asm = a.jmp(state.asm, l_step_done_f)
    state.asm = a.mark(state.asm, l_step_pos_f)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_int(1))
    state = scope.emit_store_var_scoped(state, q_step_f)
    state.asm = a.mark(state.asm, l_step_done_f)

    state.asm = a.mark(state.asm, l_top_f)
    state = scope.cg_scope_enter(state)
    state = _emit_stmt_list(state, stmt.body)
    state = scope.cg_scope_leave(state)

    state.asm = a.mark(state.asm, l_cont_f)
    state = scope.emit_load_var_scoped(state, qv)
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state = scope.emit_load_var_scoped(state, q_end_f)
    state.asm = a.cmp_r64_r64(state.asm, "rax", "r10")
    state.asm = a.jcc(state.asm, "e", l_end_f)

    state = scope.emit_load_var_scoped(state, qv)
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state = scope.emit_load_var_scoped(state, q_step_f)
    state.asm = a.add_r64_r64(state.asm, "rax", "r10")
    state.asm = a.sub_rax_imm8(state.asm, 1)
    state = scope.emit_store_var_scoped(state, qv)
    state.asm = a.jmp(state.asm, l_top_f)

    state.asm = a.mark(state.asm, l_end_f)
    state = _breakstack_pop(state)
    state = scope.cg_scope_leave(state)
    return state
  end if

  if k == "ForEach" then
    fid_fe = state.label_id
    state.label_id = state.label_id + 1
    it_lbl = "__foreach_it_" + fid_fe
    i_lbl = "__foreach_i_" + fid_fe

    state.data = d.data_add_u64(state.data, it_lbl, 0)
    state.data = d.data_add_u32(state.data, i_lbl, 0)

    state = exprmod.cg_emit_expr(state, stmt.iterable)
    state.asm = a.mov_rip_qword_rax(state.asm, it_lbl)
    state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
    state.asm = a.mov_rip_dword_eax(state.asm, i_lbl)

    l_top_fe = "foreach_top_" + fid_fe
    l_body_fe = "foreach_body_" + fid_fe
    l_cont_fe = "foreach_cont_" + fid_fe
    l_end_fe = "foreach_end_" + fid_fe
    l_arr_fe = "foreach_is_arr_" + fid_fe
    l_bytes_fe = "foreach_is_bytes_" + fid_fe
    l_str_fe = "foreach_is_str_" + fid_fe

    vname_fe = _foreach_var_name(stmt)
    state = scope.cg_scope_enter(state)
    bind_kind_fe = "local"
    if state.in_function == false then bind_kind_fe = "global" end if
    state = scope.declare_fresh_binding(state, vname_fe, stmt, bind_kind_fe)
    depth_fe_outer = scope.cg_scope_depth(state) - 1
    depth_fe_loop = scope.cg_scope_depth(state)
    state.break_stack = state.break_stack + [_breakctx_make("loop", l_end_fe, l_cont_fe, depth_fe_outer, depth_fe_loop)]

    state.asm = a.mark(state.asm, l_top_fe)
    state.asm = a.mov_eax_rip_dword(state.asm, i_lbl)
    state.asm = a.mov_r32_r32(state.asm, "ecx", "eax")
    state.asm = a.mov_rax_rip_qword(state.asm, it_lbl)
    state.asm = a.mov_r64_r64(state.asm, "r14", "rax")
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r14", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
    state.asm = a.jcc(state.asm, "e", l_arr_fe)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "e", l_bytes_fe)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
    state.asm = a.jcc(state.asm, "e", l_str_fe)
    state.asm = a.jmp(state.asm, l_end_fe)

    state.asm = a.mark(state.asm, l_arr_fe)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r14", 4)
    state.asm = a.cmp_r32_r32(state.asm, "ecx", "edx")
    state.asm = a.jcc(state.asm, "ge", l_end_fe)
    state.asm = a.mov_r64_mem_bis(state.asm, "rax", "r14", "rcx", 8, 8)
    state = scope.emit_store_var_scoped(state, vname_fe)
    state.asm = a.jmp(state.asm, l_body_fe)

    state.asm = a.mark(state.asm, l_bytes_fe)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r14", 4)
    state.asm = a.cmp_r32_r32(state.asm, "ecx", "edx")
    state.asm = a.jcc(state.asm, "ge", l_end_fe)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r14")
    state.asm = a.add_r64_r64(state.asm, "rax", "rcx")
    state.asm = a.add_rax_imm8(state.asm, 8)
    state.asm = a.movzx_r32_membase_disp(state.asm, "eax", "rax", 0)
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
    state = scope.emit_store_var_scoped(state, vname_fe)
    state.asm = a.jmp(state.asm, l_body_fe)

    state.asm = a.mark(state.asm, l_str_fe)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r14", 4)
    state.asm = a.cmp_r32_r32(state.asm, "ecx", "edx")
    state.asm = a.jcc(state.asm, "ge", l_end_fe)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r14")
    state.asm = a.add_r64_r64(state.asm, "rax", "rcx")
    state.asm = a.add_rax_imm8(state.asm, 8)
    state.asm = a.mov_r8_membase_disp(state.asm, "dl", "rax", 0)
    state.asm = a.mov_membase_disp_r8(state.asm, "rsp", 0x20, "dl")
    state.asm = a.mov_rcx_imm32(state.asm, 10)
    state.asm = a.call(state.asm, "fn_alloc")
    state.asm = a.mov_r11_rax(state.asm)
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRING, false)
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, 1, false)
    state.asm = a.mov_r8_membase_disp(state.asm, "dl", "rsp", 0x20)
    state.asm = a.mov_membase_disp_r8(state.asm, "r11", 8, "dl")
    state.asm = a.mov_membase_disp_imm8(state.asm, "r11", 9, 0)
    state.asm = a.mov_rax_r11(state.asm)
    state = scope.emit_store_var_scoped(state, vname_fe)

    state.asm = a.mark(state.asm, l_body_fe)
    state = scope.cg_scope_enter(state)
    state = _emit_stmt_list(state, stmt.body)
    state = scope.cg_scope_leave(state)

    state.asm = a.mark(state.asm, l_cont_fe)
    state.asm = a.mov_eax_rip_dword(state.asm, i_lbl)
    state.asm = a.mov_r32_r32(state.asm, "ecx", "eax")
    state.asm = a.inc_r32(state.asm, "ecx")
    state.asm = a.mov_r32_r32(state.asm, "eax", "ecx")
    state.asm = a.mov_rip_dword_eax(state.asm, i_lbl)
    state.asm = a.jmp(state.asm, l_top_fe)

    state.asm = a.mark(state.asm, l_end_fe)
    state = _breakstack_pop(state)
    state = scope.cg_scope_leave(state)
    return state
  end if

  if k == "Break" then
    if typeof(state.break_stack) != "array" or len(state.break_stack) <= 0 then
      state.diagnostics = state.diagnostics +["break outside loop/switch"]
      return state
    end if

    n = 1
    if typeof(stmt.count) == "int" and stmt.count > 0 then n = stmt.count end if
    idx = len(state.break_stack) - n
    if idx < 0 then idx = 0 end if
    ctx = state.break_stack[idx]

    depth_now = scope.cg_scope_depth(state)
    depth_break = _breakctx_break_depth(ctx, depth_now)
    state = scope.emit_cleanup_to_depth(state, depth_break)
    lbl_break = _breakctx_break_label(ctx)
    if lbl_break != "" then state.asm = a.jmp(state.asm, lbl_break) end if
    return state
  end if

  if k == "Continue" then
    if typeof(state.break_stack) != "array" or len(state.break_stack) <= 0 then
      state.diagnostics = state.diagnostics +["continue outside loop"]
      return state
    end if

    i2 = len(state.break_stack) - 1
    while i2 >= 0
      ctx2 = state.break_stack[i2]
      k2 = _breakctx_kind(ctx2)
      if k2 == "loop" then
        depth_now2 = scope.cg_scope_depth(state)
        depth_cont = _breakctx_continue_depth(ctx2, depth_now2)
        state = scope.emit_cleanup_to_depth(state, depth_cont)
        lbl_cont = _breakctx_continue_label(ctx2)
        if lbl_cont != "" then state.asm = a.jmp(state.asm, lbl_cont) end if
        return state
      end if
      i2 = i2 - 1
    end while

    state.diagnostics = state.diagnostics +["continue outside loop"]
    return state
  end if

  if k == "Return" then
    if state.in_function == false then
      state.diagnostics = state.diagnostics +["return outside function"]
      return state
    end if
    if typeof(stmt.expr) == "struct" then
      state = exprmod.cg_emit_expr(state, stmt.expr)
    else
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    end if
    if typeof(state.func_ret_label) == "string" and state.func_ret_label != "" then
      state.asm = a.jmp(state.asm, state.func_ret_label)
    else
      state.asm = a.ret(state.asm)
    end if
    return state
  end if

  state.diagnostics = state.diagnostics +["Unsupported statement in native backend: " + k]
  return state
end function

// ------------------------------------------------------------
// Compatibility wrappers (Python CodegenStmt parity)
// ------------------------------------------------------------

function _is_node(n, kind)
  if typeof(n) != "struct" then return false end if
  if typeof(kind) == "string" and kind != "" then return n.node_kind == kind end if
  return typeof(n.node_kind) == "string"
end function

function _is_stmt(st)
  return _is_node(st, 0)
end function

function _decl_st_file(st)
  if typeof(st) == "struct" and typeof(st._filename) == "string" then return st._filename end if
  return ""
end function

function _dotted_name(parts)
  if typeof(parts) == "string" then return parts end if
  if typeof(parts) != "array" or len(parts) <= 0 then return "" end if
  return s.join(parts, ".")
end function

function _member_qname(ex)
  if typeof(ex) != "struct" then return "" end if
  if ex.node_kind == "Var" and typeof(ex.name) == "string" then return ex.name end if
  if ex.node_kind == "Member" and typeof(ex.name) == "string" then
    b = _member_qname(ex.target)
    if b == "" then return "" end if
    return b + "." + ex.name
  end if
  return ""
end function

function _expr_to_qualname(state, ex)
  return exprmod._expr_to_qualname(state, ex)
end function

function _flatten_member_chain(state, ex)
  return _expr_to_qualname(state, ex)
end function

function _is_constexpr_unary(op)
  return op == "-" or op == "~" or op == "not"
end function

function _is_constexpr_binary(op)
  return op == "or" or op == "and" or op == "|" or op == "^" or op == "&" or op == "==" or op == "!=" or op == ">" or op == "<" or op == ">=" or op == "<=" or op == "<<" or op == ">>" or op == "+" or op == "-" or op == "*" or op == "/" or op == "%"
end function

function _is_constexpr_expr(state, ex)
  if typeof(ex) != "struct" then return false end if
  k = ex.node_kind
  if k == "Num" or k == "Str" or k == "Bool" then return true end if
  if k == "Var" then return true end if
  if k == "Member" then return _member_qname(ex) != "" end if
  if k == "Unary" then
    if _is_constexpr_unary(ex.op) == false then return false end if
    return _is_constexpr_expr(state, ex.right)
  end if
  if k == "Bin" then
    if _is_constexpr_binary(ex.op) == false then return false end if
    return _is_constexpr_expr(state, ex.left) and _is_constexpr_expr(state, ex.right)
  end if
  return false
end function

function _collect_constexpr_refs(ex, vals)
  if typeof(vals) != "array" then vals =[] end if
  if typeof(ex) != "struct" then return vals end if

  if ex.node_kind == "Var" and typeof(ex.name) == "string" then
    return _arr_add_unique(vals, ex.name)
  end if

  if ex.node_kind == "Member" then
    qn = _member_qname(ex)
    if typeof(qn) == "string" and qn != "" then
      return _arr_add_unique(vals, qn)
    end if
  end if

  if typeof(ex.left) == "struct" then vals = _collect_constexpr_refs(ex.left, vals) end if
  if typeof(ex.right) == "struct" then vals = _collect_constexpr_refs(ex.right, vals) end if
  if typeof(ex.target) == "struct" then vals = _collect_constexpr_refs(ex.target, vals) end if
  if typeof(ex.args) == "array" and len(ex.args) > 0 then
    for k = 0 to len(ex.args) - 1
      vals = _collect_constexpr_refs(ex.args[k], vals)
    end for
  end if
  return vals
end function

function _resolve_const_binding_for_ref(state, ref, node)
  if typeof(ref) != "string" then return 0 end if
  cands = exprmod._qname_with_prefixes(state, ref)
  if typeof(cands) == "array" and len(cands) > 0 then
    for i = 0 to len(cands) - 1
      b = scope.cg_resolve_binding(state, cands[i])
      if typeof(b) == "struct" then return b end if
    end for
  end if
  return scope.cg_resolve_binding(state, ref)
end function

function _build_constexpr_env(state, ex)
  refs = _collect_constexpr_refs(ex,[])
  env_b = t.arr_chunk_new(32)
  if len(refs) > 0 then
    for i = 0 to len(refs) - 1
      b = _resolve_const_binding_for_ref(state, refs[i], ex)
      if typeof(b) == "struct" and b.is_const and b.const_initialized then
        env_b = t.arr_chunk_push(env_b, [refs[i], b.const_value_py])
      end if
    end for
  end if
  return t.arr_chunk_finish(env_b)
end function

function _eval_constexpr(state, ex, env)
  return exprmod.cg_expr_try_const_value(state, ex)
end function

function _pyval_to_lit_expr(v)
  return v
end function

function _set_const_binding_value(state, b_or_name, pyv)
  if typeof(b_or_name) == "struct" and typeof(b_or_name.name) == "string" then
    return scope.cg_set_const_binding_value(state, b_or_name.name, pyv)
  end if
  if typeof(b_or_name) == "string" then
    return scope.cg_set_const_binding_value(state, b_or_name, pyv)
  end if
  return state
end function

function _truthy(v)
  return exprmod._opt_truthy(v)
end function

function _opt_try_truthy(state, ex)
  r = exprmod.cg_expr_try_const_value(state, ex)
  if r.ok == false then return 0 end if
  return _truthy(r.value)
end function

function _is_foreach_stmt(st)
  if typeof(st) != "struct" then return false end if
  return st.node_kind == "ForEach"
end function

function _foreach_var_name(st)
  return _coerce_name(st.var)
end function

function _owner_for(st)
  return _st_file(st)
end function

function _tag_ns(ns, name)
  return _join_qname(ns, name)
end function

function _pref_is_method_prefix(pref)
  if typeof(pref) != "string" then return false end if
  if pref == "" then return false end if
  return s.contains(pref, ".")
end function

function _has_reserved_segment(state, name)
  if typeof(name) != "string" then return false end if
  parts = s.split(name, ".")
  if typeof(parts) != "array" then return false end if
  if len(parts) <= 0 then return false end if
  if typeof(state.reserved_identifiers) == "array" and len(state.reserved_identifiers) > 0 then
    for i = 0 to len(parts) - 1
      for j = 0 to len(state.reserved_identifiers) - 1
        if parts[i] == state.reserved_identifiers[j] then return true end if
      end for
    end for
  end if
  return false
end function

function _collect_decls(program)
  vals_b = t.arr_chunk_new(64)
  if typeof(program) != "array" or len(program) <= 0 then return t.arr_chunk_finish(vals_b) end if
  for i = 0 to len(program) - 1
    st = program[i]
    if typeof(st) != "struct" then continue end if
    if st.node_kind == "FunctionDef" or st.node_kind == "StructDef" or st.node_kind == "EnumDef" then
      vals_b = t.arr_chunk_push(vals_b, st)
    end if
  end for
  return t.arr_chunk_finish(vals_b)
end function

function _resolve_global_target(state, name)
  if typeof(name) != "string" then return "" end if
  pref = state.current_qname_prefix
  if typeof(pref) == "string" and pref != "" then
    if pref[len(pref) - 1] == "." then
      return pref + name
    end if
    return pref + "." + name
  end if
  return _join_qname(state.current_file_prefix, name)
end function

function _scan_function_for_global_decls(fn_node)
  vals_b = t.arr_chunk_new(32)
  if typeof(fn_node) != "struct" or typeof(fn_node.body) != "array" then return t.arr_chunk_finish(vals_b) end if
  if len(fn_node.body) > 0 then
    for i = 0 to len(fn_node.body) - 1
      st = fn_node.body[i]
      if typeof(st) == "struct" and st.node_kind == "GlobalDecl" and typeof(st.names) == "array" then
        for j = 0 to len(st.names) - 1
          nm = _coerce_name(st.names[j])
          if nm != "" then vals_b = t.arr_chunk_push(vals_b, nm) end if
        end for
      end if
    end for
  end if
  return t.arr_chunk_finish(vals_b)
end function

function _walk_stmt_into(st, vals_b)
  b = vals_b
  if typeof(b) != "struct" then b = t.arr_chunk_new(64) end if
  if typeof(st) != "struct" then return b end if
  b = t.arr_chunk_push(b, st)

  if typeof(st.body) == "array" and len(st.body) > 0 then
    i = 0
    n = len(st.body)
    while i < n
      b = _walk_stmt_into(st.body[i], b)
      i = i + 1
    end while
  end if
  if typeof(st.then_body) == "array" and len(st.then_body) > 0 then
    i = 0
    n = len(st.then_body)
    while i < n
      b = _walk_stmt_into(st.then_body[i], b)
      i = i + 1
    end while
  end if
  if typeof(st.else_body) == "array" and len(st.else_body) > 0 then
    i = 0
    n = len(st.else_body)
    while i < n
      b = _walk_stmt_into(st.else_body[i], b)
      i = i + 1
    end while
  end if
  return b
end function

function _walk_stmt(st, vals)
  vals_b = t.arr_chunk_new(64)
  if typeof(vals) == "array" and len(vals) > 0 then
    vals_b = t.arr_chunk_push_all(vals_b, vals)
  end if
  vals_b = _walk_stmt_into(st, vals_b)
  return t.arr_chunk_finish(vals_b)
end function

function _tag_ns_prefix(node, pref)
  if typeof(node) == "struct" and typeof(pref) == "string" then
    node._ml_ns_prefix = pref
  end if
  return node
end function

function _flatten_runtime_inner(state, stmts, prefix, current_file)
  vals_out_b = t.arr_chunk_new(64)
  if typeof(stmts) != "array" or len(stmts) <= 0 then return t.arr_chunk_finish(vals_out_b) end if

  cur_file = current_file
  pref = prefix
  if typeof(pref) != "string" then pref = "" end if
  if typeof(cur_file) != "string" then cur_file = "" end if

  i = 0
  n = len(stmts)
  while i < n
    st = stmts[i]
    i = i + 1
    sf = _st_file(st)
    if sf == "" then sf = cur_file end if
    if cur_file == "" or (sf != "" and sf != cur_file) then
      cur_file = sf
      if cur_file != "" then
        pref = _strpair_get(state.file_prefix_map, cur_file)
      else
        pref = ""
      end if
    end if

    if typeof(st) != "struct" then
      vals_out_b = t.arr_chunk_push(vals_out_b, st)
      continue
    end if

    st = _tag_ns_prefix(st, pref)
    k = st.node_kind

    handled = false

    if k == "NamespaceDecl" then
      vals_out_b = t.arr_chunk_push(vals_out_b, st)
      handled = true
    end if

    if handled == false and k == "NamespaceDef" then
      vals_out_b = t.arr_chunk_push(vals_out_b, st)
      ns = _coerce_name(st.name)
      body = st.body
      if ns != "" and typeof(body) == "array" and len(body) > 0 then
        sub_pref = pref + ns + "."
        sub_vals = _flatten_runtime_inner(state, body, sub_pref, cur_file)
        if typeof(sub_vals) == "array" and len(sub_vals) > 0 then
          vals_out_b = t.arr_chunk_push_all(vals_out_b, sub_vals)
        end if
      end if
      handled = true
    end if

    if handled == false and k == "EnumDef" then
      vals_out_b = t.arr_chunk_push(vals_out_b, st)
      qn = _coerce_name(st.name)
      if qn != "" then
        members = _named_array_get(state.value_enum_values, qn)
        if typeof(members) == "array" and len(members) > 0 then
          mi = 0
          mn = len(members)
          while mi < mn
            mm = members[mi]
            vn = ""
            vx = void
            if typeof(mm) == "struct" then
              vn = _coerce_name(mm.key)
              vx = mm.value
            else
              if typeof(mm) == "array" and len(mm) >= 2 then
                vn = _coerce_name(mm[0])
                vx = mm[1]
              end if
            end if
            if vn != "" then
              p0 = 0
              if typeof(st._pos) == "int" then p0 = st._pos end if
              f0 = ""
              if typeof(st._filename) == "string" then f0 = st._filename end if
              cd = ml.ConstDecl("ConstDecl", qn + "." + vn, vx, p0, f0)
              cd = _tag_ns_prefix(cd, pref)
              vals_out_b = t.arr_chunk_push(vals_out_b, cd)
            end if
            mi = mi + 1
          end while
        end if
      end if
      handled = true
    end if

    if handled == false and (k == "ConstDecl" or k == "Assign") then
      nm = _coerce_name(st.name)
      if pref != "" and nm != "" and _has_dot_name(nm) == false then
        st.name = pref + nm
      end if
      vals_out_b = t.arr_chunk_push(vals_out_b, st)
      handled = true
    end if

    if handled == false then
      vals_out_b = t.arr_chunk_push(vals_out_b, st)
    end if
  end while

  return t.arr_chunk_finish(vals_out_b)
end function

function _flatten_runtime(state, value)
  return _flatten_runtime_inner(state, value, "", "")
end function

function _group_program_by_file(program)
  vals =[]
  if typeof(program) != "array" or len(program) <= 0 then return vals end if
  files = []
  groups = []

  for i = 0 to len(program) - 1
    st = program[i]
    fn = _st_file(st)
    if fn == "" then fn = "<entry>" end if

    hit = -1
    for j = 0 to len(files) - 1
      if files[j] == fn then hit = j break end if
    end for

    if hit < 0 then
      files = files +[fn]
      groups = groups +[t.arr_chunk_new(64)]
      hit = len(groups) - 1
    end if
    gb = groups[hit]
    gb = t.arr_chunk_push(gb, st)
    groups[hit] = gb
  end for

  vals_b = t.arr_chunk_new(16)
  for vi = 0 to len(files) - 1
    vals_b = t.arr_chunk_push(vals_b, [files[vi], t.arr_chunk_finish(groups[vi])])
  end for
  vals = t.arr_chunk_finish(vals_b)
  return vals
end function

function _arr_has(arr, value)
  if typeof(arr) != "array" or len(arr) <= 0 then return false end if
  for i = 0 to len(arr) - 1
    if arr[i] == value then return true end if
  end for
  return false
end function

function _arr_add_unique(arr, value)
  if typeof(arr) != "array" then arr = [] end if
  if _arr_has(arr, value) then return arr end if
  return arr + [value]
end function

function _arr_remove_value(arr, value)
  if typeof(arr) != "array" or len(arr) <= 0 then return [] end if
  vals_b = t.arr_chunk_new(32)
  for i = 0 to len(arr) - 1
    if arr[i] != value then vals_b = t.arr_chunk_push(vals_b, arr[i]) end if
  end for
  return t.arr_chunk_finish(vals_b)
end function

function _arr_union(a, b)
  vals_out = []
  if typeof(a) == "array" and len(a) > 0 then
    for i = 0 to len(a) - 1
      vals_out = _arr_add_unique(vals_out, a[i])
    end for
  end if
  if typeof(b) == "array" and len(b) > 0 then
    for i = 0 to len(b) - 1
      vals_out = _arr_add_unique(vals_out, b[i])
    end for
  end if
  return vals_out
end function

function _map_int_get(arr, key, defaultv)
  if typeof(arr) != "array" or len(arr) <= 0 then return defaultv end if
  for i = 0 to len(arr) - 1
    it = arr[i]
    if typeof(it) == "array" and len(it) >= 2 and it[0] == key then
      if typeof(it[1]) == "int" then return it[1] end if
      return defaultv
    end if
    if typeof(it) == "struct" and it.key == key then
      if typeof(it.value) == "int" then return it.value end if
      return defaultv
    end if
  end for
  return defaultv
end function

function _map_int_set(arr, key, value)
  if typeof(arr) != "array" then arr = [] end if
  if len(arr) > 0 then
    for i = 0 to len(arr) - 1
      it = arr[i]
      if typeof(it) == "struct" and it.key == key then
        arr[i] = [key, value]
        return arr
      end if
    end for
  end if
  return arr + [[key, value]]
end function

function _sort_names(vals)
  if typeof(vals) != "array" or len(vals) <= 1 then return vals end if
  arr = []
  for i = 0 to len(vals) - 1
    if typeof(vals[i]) == "string" and vals[i] != "" then
      arr = _arr_add_unique(arr, vals[i])
    end if
  end for
  n = len(arr)
  if n <= 1 then return arr end if
  for i = 0 to n - 2
    for j = 0 to n - 2 - i
      a = arr[j]
      b = arr[j + 1]
      if a > b then
        tmp = arr[j]
        arr[j] = arr[j + 1]
        arr[j + 1] = tmp
      end if
    end for
  end for
  return arr
end function

function _closure_expr_reads(ex, used)
  if typeof(used) != "array" then used = [] end if
  if typeof(ex) != "struct" then return used end if

  k = ex.node_kind
  if k == "Var" and typeof(ex.name) == "string" then
    return _arr_add_unique(used, ex.name)
  end if

  if k == "Unary" then
    return _closure_expr_reads(ex.right, used)
  end if

  if k == "Bin" then
    used = _closure_expr_reads(ex.left, used)
    used = _closure_expr_reads(ex.right, used)
    return used
  end if

  if k == "Call" then
    cal = ex.callee
    if typeof(cal) != "struct" then cal = ex.func end if
    used = _closure_expr_reads(cal, used)
    if typeof(ex.args) == "array" and len(ex.args) > 0 then
      for i = 0 to len(ex.args) - 1
        if i < 0 or i >= len(ex.args) then break end if
        used = _closure_expr_reads(ex.args[i], used)
      end for
    end if
    return used
  end if

  if k == "Index" then
    used = _closure_expr_reads(ex.target, used)
    used = _closure_expr_reads(ex.index, used)
    return used
  end if

  if k == "Member" then
    tgt = ex.target
    if typeof(tgt) != "struct" then tgt = ex.obj end if
    return _closure_expr_reads(tgt, used)
  end if

  if k == "ArrayLit" and typeof(ex.items) == "array" and len(ex.items) > 0 then
    for i = 0 to len(ex.items) - 1
      if i < 0 or i >= len(ex.items) then break end if
      used = _closure_expr_reads(ex.items[i], used)
    end for
    return used
  end if

  if k == "StructInit" and typeof(ex.values) == "array" and len(ex.values) > 0 then
    for i = 0 to len(ex.values) - 1
      if i < 0 or i >= len(ex.values) then break end if
      used = _closure_expr_reads(ex.values[i], used)
    end for
    return used
  end if

  return used
end function

function _closure_collect_locals_walk(stmts, locals_set, globals_decl, nested)
  if typeof(locals_set) != "array" then locals_set = [] end if
  if typeof(globals_decl) != "array" then globals_decl = [] end if
  if typeof(nested) != "array" then nested = [] end if
  if typeof(stmts) != "array" or len(stmts) <= 0 then return [locals_set, globals_decl, nested] end if

  i = 0
  n = len(stmts)
  while i < n
    st = stmts[i]
    i = i + 1
    if typeof(st) != "struct" then continue end if
    k = st.node_kind

    if k == "GlobalDecl" and typeof(st.names) == "array" and len(st.names) > 0 then
      j = 0
      jn = len(st.names)
      while j < jn
        nm = _coerce_name(st.names[j])
        if nm != "" then globals_decl = _arr_add_unique(globals_decl, nm) end if
        j = j + 1
      end while
      continue
    end if

    if k == "Assign" then
      nm2 = _coerce_name(st.name)
      if nm2 != "" and _arr_has(globals_decl, nm2) == false then
        locals_set = _arr_add_unique(locals_set, nm2)
      end if
    end if

    if k == "For" then
      v = _coerce_name(st.var)
      if v != "" then locals_set = _arr_add_unique(locals_set, v) end if
    end if

    if _is_foreach_stmt(st) then
      fv = _foreach_var_name(st)
      if fv != "" then locals_set = _arr_add_unique(locals_set, fv) end if
    end if

    if k == "FunctionDef" then
      nested = _arr_add_unique(nested, st)
      fnn = _coerce_name(st.name)
      if fnn != "" then locals_set = _arr_add_unique(locals_set, fnn) end if
      continue
    end if

    if k == "If" then
      sub = _closure_collect_locals_walk(st.then_body, locals_set, globals_decl, nested)
      locals_set = sub[0]
      globals_decl = sub[1]
      nested = sub[2]
      if typeof(st.elifs) == "array" and len(st.elifs) > 0 then
        ei = 0
        en = len(st.elifs)
        while ei < en
          eb = st.elifs[ei]
          body = []
          if typeof(eb) == "array" and len(eb) >= 2 and typeof(eb[1]) == "array" then body = eb[1] end if
          sub2 = _closure_collect_locals_walk(body, locals_set, globals_decl, nested)
          locals_set = sub2[0]
          globals_decl = sub2[1]
          nested = sub2[2]
          ei = ei + 1
        end while
      end if
      sub3 = _closure_collect_locals_walk(st.else_body, locals_set, globals_decl, nested)
      locals_set = sub3[0]
      globals_decl = sub3[1]
      nested = sub3[2]
      continue
    end if

    if k == "While" or k == "DoWhile" or k == "For" or _is_foreach_stmt(st) then
      sub4 = _closure_collect_locals_walk(st.body, locals_set, globals_decl, nested)
      locals_set = sub4[0]
      globals_decl = sub4[1]
      nested = sub4[2]
      continue
    end if

    if k == "Switch" then
      if typeof(st.cases) == "array" and len(st.cases) > 0 then
        ci = 0
        cn = len(st.cases)
        while ci < cn
          cs = st.cases[ci]
          if typeof(cs) == "struct" and typeof(cs.body) == "array" then
            sub5 = _closure_collect_locals_walk(cs.body, locals_set, globals_decl, nested)
            locals_set = sub5[0]
            globals_decl = sub5[1]
            nested = sub5[2]
          end if
          ci = ci + 1
        end while
      end if
      sub6 = _closure_collect_locals_walk(st.default_body, locals_set, globals_decl, nested)
      locals_set = sub6[0]
      globals_decl = sub6[1]
      nested = sub6[2]
      continue
    end if
  end while

  return [locals_set, globals_decl, nested]
end function

function _closure_collect_locals_and_nested(fn_node)
  locals_set = []
  globals_decl = []
  nested = []
  if typeof(fn_node) != "struct" then return [locals_set, globals_decl, nested] end if

  if typeof(fn_node.params) == "array" and len(fn_node.params) > 0 then
    for i = 0 to len(fn_node.params) - 1
      if i < 0 or i >= len(fn_node.params) then break end if
      nm = _coerce_name(fn_node.params[i])
      if nm != "" then locals_set = _arr_add_unique(locals_set, nm) end if
    end for
  end if

  body = fn_node.body
  if typeof(body) != "array" then body = [] end if
  return _closure_collect_locals_walk(body, locals_set, globals_decl, nested)
end function

function _closure_collect_uses(stmts)
  used = []
  if typeof(stmts) != "array" or len(stmts) <= 0 then return used end if

  i = 0
  n = len(stmts)
  while i < n
    st = stmts[i]
    i = i + 1
    if typeof(st) != "struct" then continue end if
    k = st.node_kind
    if k == "FunctionDef" then continue end if

    if k == "Assign" or k == "Print" or k == "ExprStmt" or k == "Return" then
      used = _closure_expr_reads(st.expr, used)
      continue
    end if

    if k == "SetMember" then
      tgt = st.obj
      if typeof(tgt) != "struct" then tgt = st.target end if
      used = _closure_expr_reads(tgt, used)
      used = _closure_expr_reads(st.expr, used)
      continue
    end if

    if k == "SetIndex" then
      used = _closure_expr_reads(st.target, used)
      used = _closure_expr_reads(st.index, used)
      used = _closure_expr_reads(st.expr, used)
      continue
    end if

    if k == "If" then
      used = _closure_expr_reads(st.cond, used)
      used = _arr_union(used, _closure_collect_uses(st.then_body))
      if typeof(st.elifs) == "array" and len(st.elifs) > 0 then
        ei = 0
        en = len(st.elifs)
        while ei < en
          eb = st.elifs[ei]
          if typeof(eb) == "array" and len(eb) >= 1 then
            used = _closure_expr_reads(eb[0], used)
          end if
          if typeof(eb) == "array" and len(eb) >= 2 and typeof(eb[1]) == "array" then
            used = _arr_union(used, _closure_collect_uses(eb[1]))
          end if
          ei = ei + 1
        end while
      end if
      used = _arr_union(used, _closure_collect_uses(st.else_body))
      continue
    end if

    if k == "While" then
      used = _closure_expr_reads(st.cond, used)
      used = _arr_union(used, _closure_collect_uses(st.body))
      continue
    end if

    if k == "DoWhile" then
      used = _arr_union(used, _closure_collect_uses(st.body))
      used = _closure_expr_reads(st.cond, used)
      continue
    end if

    if k == "For" then
      used = _closure_expr_reads(st.start, used)
      used = _closure_expr_reads(st.end_expr, used)
      used = _arr_union(used, _closure_collect_uses(st.body))
      continue
    end if

    if _is_foreach_stmt(st) then
      used = _closure_expr_reads(st.iterable, used)
      used = _arr_union(used, _closure_collect_uses(st.body))
      continue
    end if

    if k == "Switch" then
      used = _closure_expr_reads(st.expr, used)
      if typeof(st.cases) == "array" and len(st.cases) > 0 then
        ci = 0
        cn = len(st.cases)
        while ci < cn
          cs = st.cases[ci]
          if typeof(cs) != "struct" then
            ci = ci + 1
            continue
          end if
          if cs.kind == "values" and typeof(cs.values) == "array" and len(cs.values) > 0 then
            vi = 0
            vn = len(cs.values)
            while vi < vn
              used = _closure_expr_reads(cs.values[vi], used)
              vi = vi + 1
            end while
          else
            used = _closure_expr_reads(cs.range_start, used)
            used = _closure_expr_reads(cs.range_end, used)
          end if
          used = _arr_union(used, _closure_collect_uses(cs.body))
          ci = ci + 1
        end while
      end if
      used = _arr_union(used, _closure_collect_uses(st.default_body))
      continue
    end if
  end while

  return used
end function

function _closure_collect_writes(fn_node)
  written = []
  stmts = fn_node
  if typeof(fn_node) == "struct" and typeof(fn_node.body) == "array" then
    stmts = fn_node.body
  end if
  if typeof(stmts) != "array" or len(stmts) <= 0 then return written end if

  i = 0
  n = len(stmts)
  while i < n
    st = stmts[i]
    i = i + 1
    if typeof(st) != "struct" then continue end if
    k = st.node_kind
    if k == "FunctionDef" then continue end if

    if k == "Assign" and typeof(st.name) == "string" then
      written = _arr_add_unique(written, st.name)
      continue
    end if

    if k == "If" then
      written = _arr_union(written, _closure_collect_writes(st.then_body))
      if typeof(st.elifs) == "array" and len(st.elifs) > 0 then
        ei = 0
        en = len(st.elifs)
        while ei < en
          eb = st.elifs[ei]
          if typeof(eb) == "array" and len(eb) >= 2 and typeof(eb[1]) == "array" then
            written = _arr_union(written, _closure_collect_writes(eb[1]))
          end if
          ei = ei + 1
        end while
      end if
      written = _arr_union(written, _closure_collect_writes(st.else_body))
      continue
    end if

    if k == "While" or k == "DoWhile" or k == "For" or _is_foreach_stmt(st) then
      written = _arr_union(written, _closure_collect_writes(st.body))
      continue
    end if

    if k == "Switch" then
      if typeof(st.cases) == "array" and len(st.cases) > 0 then
        ci = 0
        cn = len(st.cases)
        while ci < cn
          cs = st.cases[ci]
          if typeof(cs) == "struct" then
            written = _arr_union(written, _closure_collect_writes(cs.body))
          end if
          ci = ci + 1
        end while
      end if
      written = _arr_union(written, _closure_collect_writes(st.default_body))
      continue
    end if
  end while

  return written
end function

function _note_reads(read_before, written_yet, names)
  if typeof(read_before) != "array" then read_before = [] end if
  if typeof(written_yet) != "array" then written_yet = [] end if
  if typeof(names) != "array" or len(names) <= 0 then return read_before end if
  for i = 0 to len(names) - 1
    if i < 0 or i >= len(names) then break end if
    nm = names[i]
    if typeof(nm) != "string" or nm == "" then continue end if
    if _arr_has(written_yet, nm) then continue end if
    read_before = _arr_add_unique(read_before, nm)
  end for
  return read_before
end function

function _closure_collect_rbfw_walk(stmts, read_before, written_yet)
  if typeof(read_before) != "array" then read_before = [] end if
  if typeof(written_yet) != "array" then written_yet = [] end if
  if typeof(stmts) != "array" or len(stmts) <= 0 then return [read_before, written_yet] end if

  i = 0
  n = len(stmts)
  while i < n
    st = stmts[i]
    i = i + 1
    if typeof(st) != "struct" then continue end if
    k = st.node_kind
    if k == "FunctionDef" then continue end if

    if k == "Assign" then
      rr = _closure_expr_reads(st.expr, [])
      read_before = _note_reads(read_before, written_yet, rr)
      nm = _coerce_name(st.name)
      if nm != "" then written_yet = _arr_add_unique(written_yet, nm) end if
      continue
    end if

    if k == "Print" or k == "ExprStmt" or k == "Return" then
      rr2 = _closure_expr_reads(st.expr, [])
      read_before = _note_reads(read_before, written_yet, rr2)
      continue
    end if

    if k == "SetMember" then
      rr3 = []
      tgt = st.obj
      if typeof(tgt) != "struct" then tgt = st.target end if
      rr3 = _closure_expr_reads(tgt, rr3)
      rr3 = _closure_expr_reads(st.expr, rr3)
      read_before = _note_reads(read_before, written_yet, rr3)
      continue
    end if

    if k == "SetIndex" then
      rr4 = []
      rr4 = _closure_expr_reads(st.target, rr4)
      rr4 = _closure_expr_reads(st.index, rr4)
      rr4 = _closure_expr_reads(st.expr, rr4)
      read_before = _note_reads(read_before, written_yet, rr4)
      continue
    end if

    if k == "If" then
      rc = _closure_expr_reads(st.cond, [])
      read_before = _note_reads(read_before, written_yet, rc)
      sub = _closure_collect_rbfw_walk(st.then_body, read_before, written_yet)
      read_before = sub[0]
      written_yet = sub[1]
      if typeof(st.elifs) == "array" and len(st.elifs) > 0 then
        ei = 0
        en = len(st.elifs)
        while ei < en
          eb = st.elifs[ei]
          if typeof(eb) == "array" and len(eb) >= 1 then
            rc2 = _closure_expr_reads(eb[0], [])
            read_before = _note_reads(read_before, written_yet, rc2)
          end if
          if typeof(eb) == "array" and len(eb) >= 2 and typeof(eb[1]) == "array" then
            sub2 = _closure_collect_rbfw_walk(eb[1], read_before, written_yet)
            read_before = sub2[0]
            written_yet = sub2[1]
          end if
          ei = ei + 1
        end while
      end if
      sub3 = _closure_collect_rbfw_walk(st.else_body, read_before, written_yet)
      read_before = sub3[0]
      written_yet = sub3[1]
      continue
    end if

    if k == "While" then
      rc3 = _closure_expr_reads(st.cond, [])
      read_before = _note_reads(read_before, written_yet, rc3)
      sub4 = _closure_collect_rbfw_walk(st.body, read_before, written_yet)
      read_before = sub4[0]
      written_yet = sub4[1]
      continue
    end if

    if k == "DoWhile" then
      sub5 = _closure_collect_rbfw_walk(st.body, read_before, written_yet)
      read_before = sub5[0]
      written_yet = sub5[1]
      rc4 = _closure_expr_reads(st.cond, [])
      read_before = _note_reads(read_before, written_yet, rc4)
      continue
    end if

    if k == "For" then
      rr5 = []
      rr5 = _closure_expr_reads(st.start, rr5)
      rr5 = _closure_expr_reads(st.end_expr, rr5)
      read_before = _note_reads(read_before, written_yet, rr5)
      v = _coerce_name(st.var)
      if v != "" then written_yet = _arr_add_unique(written_yet, v) end if
      sub6 = _closure_collect_rbfw_walk(st.body, read_before, written_yet)
      read_before = sub6[0]
      written_yet = sub6[1]
      continue
    end if

    if _is_foreach_stmt(st) then
      rr6 = _closure_expr_reads(st.iterable, [])
      read_before = _note_reads(read_before, written_yet, rr6)
      fv = _foreach_var_name(st)
      if fv != "" then written_yet = _arr_add_unique(written_yet, fv) end if
      sub7 = _closure_collect_rbfw_walk(st.body, read_before, written_yet)
      read_before = sub7[0]
      written_yet = sub7[1]
      continue
    end if

    if k == "Switch" then
      rr7 = _closure_expr_reads(st.expr, [])
      read_before = _note_reads(read_before, written_yet, rr7)
      if typeof(st.cases) == "array" and len(st.cases) > 0 then
        ci = 0
        cn = len(st.cases)
        while ci < cn
          cs = st.cases[ci]
          if typeof(cs) != "struct" then
            ci = ci + 1
            continue
          end if
          if cs.kind == "values" and typeof(cs.values) == "array" and len(cs.values) > 0 then
            vi = 0
            vn = len(cs.values)
            while vi < vn
              rr8 = _closure_expr_reads(cs.values[vi], [])
              read_before = _note_reads(read_before, written_yet, rr8)
              vi = vi + 1
            end while
          else
            rr9 = []
            rr9 = _closure_expr_reads(cs.range_start, rr9)
            rr9 = _closure_expr_reads(cs.range_end, rr9)
            read_before = _note_reads(read_before, written_yet, rr9)
          end if
          sub8 = _closure_collect_rbfw_walk(cs.body, read_before, written_yet)
          read_before = sub8[0]
          written_yet = sub8[1]
          ci = ci + 1
        end while
      end if
      sub9 = _closure_collect_rbfw_walk(st.default_body, read_before, written_yet)
      read_before = sub9[0]
      written_yet = sub9[1]
      continue
    end if
  end while

  return [read_before, written_yet]
end function

function _closure_collect_read_before_first_write(stmts, params_set)
  written_yet = []
  if typeof(params_set) == "array" and len(params_set) > 0 then
    for i = 0 to len(params_set) - 1
      if i < 0 or i >= len(params_set) then break end if
      nm = _coerce_name(params_set[i])
      if nm != "" then written_yet = _arr_add_unique(written_yet, nm) end if
    end for
  end if
  res = _closure_collect_rbfw_walk(stmts, [], written_yet)
  return res[0]
end function

function _closure_owner_for(nf, depth)
  if depth <= 0 then return 0 end if
  cur = nf._ml_parent_fn
  if typeof(cur) != "struct" then return 0 end if
  if depth == 1 then return cur end if
  for i = 0 to depth - 2
    cur = cur._ml_parent_fn
    if typeof(cur) != "struct" then return 0 end if
  end for
  return cur
end function

function _closure_analyze_function_rec(state, fn_node, outer_scopes)
  if typeof(fn_node) != "struct" then return [state, [], fn_node] end if
  if typeof(outer_scopes) != "array" then outer_scopes = [] end if

  info = _closure_collect_locals_and_nested(fn_node)
  locals_set = info[0]
  globals_decl = info[1]
  nested = info[2]

  body_stmts = fn_node.body
  if typeof(body_stmts) != "array" then body_stmts = [] end if
  uses = _closure_collect_uses(body_stmts)
  writes = _closure_collect_writes(body_stmts)

  params_set = []
  if typeof(fn_node.params) == "array" and len(fn_node.params) > 0 then
    for pi = 0 to len(fn_node.params) - 1
      pn = _coerce_name(fn_node.params[pi])
      if pn != "" then params_set = _arr_add_unique(params_set, pn) end if
    end for
  end if
  read_before_write = _closure_collect_read_before_first_write(body_stmts, params_set)

  captures = []
  capture_depth = []

  if len(writes) > 0 and len(outer_scopes) > 0 then
    for i = 0 to len(writes) - 1
      name = writes[i]
      if typeof(name) != "string" or name == "" then continue end if
      if _arr_has(params_set, name) then continue end if
      if _arr_has(globals_decl, name) then continue end if
      if _has_dot_name(name) then continue end if
      if _arr_has(read_before_write, name) == false then continue end if
      for d = 0 to len(outer_scopes) - 1
        oscope = outer_scopes[d]
        if _arr_has(oscope, name) then
          locals_set = _arr_remove_value(locals_set, name)
          captures = _arr_add_unique(captures, name)
          capture_depth = _map_int_set(capture_depth, name, d + 1)
          break
        end if
      end for
    end for
  end if

  uw = _arr_union(uses, writes)
  if len(uw) > 0 and len(outer_scopes) > 0 then
    for i = 0 to len(uw) - 1
      nm = uw[i]
      if typeof(nm) != "string" or nm == "" then continue end if
      if _arr_has(locals_set, nm) then continue end if
      if _arr_has(globals_decl, nm) then continue end if
      if _has_dot_name(nm) then continue end if
      if _arr_has(captures, nm) then continue end if
      for d2 = 0 to len(outer_scopes) - 1
        os2 = outer_scopes[d2]
        if _arr_has(os2, nm) then
          captures = _arr_add_unique(captures, nm)
          capture_depth = _map_int_set(capture_depth, nm, d2 + 1)
          break
        end if
      end for
    end for
  end if

  fn_node._ml_locals = locals_set
  fn_node._ml_globals_declared = globals_decl
  fn_node._ml_captures = captures
  fn_node._ml_capture_depth = capture_depth
  fn_node._ml_nested_functions = nested

  found_b = t.arr_chunk_new(32)
  if len(nested) > 0 then
    ni = 0
    nn = len(nested)
    while ni < nn
      nf = nested[ni]
      if typeof(nf) != "struct" then
        ni = ni + 1
        continue
      end if
      nf._ml_parent_fn = fn_node
      sub_outer = [locals_set] + outer_scopes
      sub = _closure_analyze_function_rec(state, nf, sub_outer)
      state = sub[0]
      if typeof(sub[2]) == "struct" then
        nested[ni] = sub[2]
        found_b = t.arr_chunk_push(found_b, sub[2])
      else
        found_b = t.arr_chunk_push(found_b, nf)
      end if
      if typeof(sub[1]) == "array" and len(sub[1]) > 0 then
        found_b = t.arr_chunk_push_all(found_b, sub[1])
      end if
      ni = ni + 1
    end while
  end if

  fn_node._ml_nested_functions = nested
  return [state, t.arr_chunk_finish(found_b), fn_node]
end function

function _closure_analyze_function(state, fn_node)
  res = _closure_analyze_function_rec(state, fn_node, [])
  return res[0]
end function

function _closure_analyze_program(state, program)
  nested_all_b = t.arr_chunk_new(64)
  ufs = state.user_functions
  if typeof(ufs) == "array" and len(ufs) > 0 then
    for i = 0 to len(ufs) - 1
      it = ufs[i]
      fn_node = 0
      qname = ""
      if typeof(it) == "array" and len(it) >= 2 and typeof(it[1]) == "struct" then
        if typeof(it[0]) == "string" then qname = it[0] end if
        fn_node = it[1]
      else
        if typeof(it) == "struct" and typeof(it.value) == "struct" then
          if typeof(it.key) == "string" then qname = it.key end if
          fn_node = it.value
        end if
      end if
      if typeof(fn_node) == "struct" then
        sub = _closure_analyze_function_rec(state, fn_node, [])
        state = sub[0]
        if typeof(sub[2]) == "struct" and qname != "" then
          state = _set_user_function(state, qname, sub[2])
        end if
        if typeof(sub[1]) == "array" and len(sub[1]) > 0 then
          nested_all_b = t.arr_chunk_push_all(nested_all_b, sub[1])
        end if
      end if
    end for
  end if
  state.nested_user_functions = t.arr_chunk_finish(nested_all_b)
  return state
end function

function _closure_collect_all_functions(state, nested_fns)
  allf_b = t.arr_chunk_new(64)
  ufs = state.user_functions
  if typeof(ufs) == "array" and len(ufs) > 0 then
    for i = 0 to len(ufs) - 1
      it = ufs[i]
      if typeof(it) == "array" and len(it) >= 2 and typeof(it[1]) == "struct" then
        allf_b = t.arr_chunk_push(allf_b, it[1])
      else
        if typeof(it) == "struct" and typeof(it.value) == "struct" then
          allf_b = t.arr_chunk_push(allf_b, it.value)
        end if
      end if
    end for
  end if
  if typeof(nested_fns) == "array" and len(nested_fns) > 0 then
    for j = 0 to len(nested_fns) - 1
      if typeof(nested_fns[j]) == "struct" then
        allf_b = t.arr_chunk_push(allf_b, nested_fns[j])
      end if
    end for
  end if
  return t.arr_chunk_finish(allf_b)
end function

function _closure_assign_env_layout(state, nested_fns)
  if typeof(nested_fns) != "array" then nested_fns = state.nested_user_functions end if
  if typeof(nested_fns) != "array" then nested_fns = [] end if

  all_fns = _closure_collect_all_functions(state, nested_fns)
  if len(all_fns) > 0 then
    for i = 0 to len(all_fns) - 1
      fn = all_fns[i]
      if typeof(fn) != "struct" then continue end if
      if typeof(fn._ml_boxed) != "array" then fn._ml_boxed = [] end if
      if typeof(fn._ml_env_slots) != "array" then fn._ml_env_slots = [] end if
      if typeof(fn._ml_env_index) != "array" then fn._ml_env_index = [] end if
    end for
  end if

  if len(nested_fns) > 0 then
    for i = 0 to len(nested_fns) - 1
      nf = nested_fns[i]
      if typeof(nf) != "struct" then continue end if
      caps = nf._ml_captures
      cdepth = nf._ml_capture_depth
      if typeof(caps) != "array" or len(caps) <= 0 then continue end if
      for ci = 0 to len(caps) - 1
        name = _as_name(caps[ci])
        depth = _map_int_get(cdepth, name, 0)
        if depth <= 0 then continue end if
        owner = _closure_owner_for(nf, depth)
        if typeof(owner) != "struct" then
          state.diagnostics = state.diagnostics + ["Internal error: could not resolve owner for capture '" + name + "'"]
          continue
        end if
        boxed = owner._ml_boxed
        if typeof(boxed) != "array" then boxed = [] end if
        owner._ml_boxed = _arr_add_unique(boxed, name)
      end for
    end for
  end if

  if len(all_fns) > 0 then
    for i = 0 to len(all_fns) - 1
      fn2 = all_fns[i]
      if typeof(fn2) != "struct" then continue end if
      boxed2 = fn2._ml_boxed
      if typeof(boxed2) != "array" then boxed2 = [] end if
      slots = []
      if len(boxed2) > 0 then
        for bi = 0 to len(boxed2) - 1
          bn = _as_name(boxed2[bi])
          if bn != "" then slots = _arr_add_unique(slots, bn) end if
        end for
      end if
      slots = _sort_names(slots)
      fn2._ml_env_slots = slots
      env_index = []
      if len(slots) > 0 then
        for si = 0 to len(slots) - 1
          env_index = _map_int_set(env_index, slots[si], si)
        end for
      end if
      fn2._ml_env_index = env_index
    end for
  end if

  if len(nested_fns) > 0 then
    for i = 0 to len(nested_fns) - 1
      nf2 = nested_fns[i]
      if typeof(nf2) != "struct" then continue end if
      caps2 = nf2._ml_captures
      cdepth2 = nf2._ml_capture_depth
      cap_idx = []
      if typeof(caps2) == "array" and len(caps2) > 0 then
        for ci2 = 0 to len(caps2) - 1
          nm = _as_name(caps2[ci2])
          depth2 = _map_int_get(cdepth2, nm, 0)
          owner2 = _closure_owner_for(nf2, depth2)
          if typeof(owner2) != "struct" then
            state.diagnostics = state.diagnostics + ["Internal error: could not resolve owner for capture '" + nm + "'"]
            continue
          end if
          idx = _map_int_get(owner2._ml_env_index, nm, -1)
          if idx < 0 then
            state.diagnostics = state.diagnostics + ["Internal error: capture '" + nm + "' missing env index in owner function"]
            continue
          end if
          cap_idx = _map_int_set(cap_idx, nm, idx)
        end for
      end if
      nf2._ml_capture_index = cap_idx
    end for
  end if

  if len(all_fns) > 0 then
    for i = 0 to len(all_fns) - 1
      fn3 = all_fns[i]
      if typeof(fn3) == "struct" then fn3._ml_env_hop = false end if
    end for
  end if

  if len(nested_fns) > 0 then
    for i = 0 to len(nested_fns) - 1
      nf3 = nested_fns[i]
      if typeof(nf3) != "struct" then continue end if
      cdepth3 = nf3._ml_capture_depth
      if typeof(cdepth3) != "array" or len(cdepth3) <= 0 then continue end if
      for ci3 = 0 to len(cdepth3) - 1
        it = cdepth3[ci3]
        depth3 = 0
        if typeof(it) == "struct" and typeof(it.value) == "int" then
          depth3 = it.value
        else
          if typeof(it) == "array" and len(it) >= 2 and typeof(it[1]) == "int" then
            depth3 = it[1]
          end if
        end if
        if depth3 <= 1 then continue end if
        cur = nf3._ml_parent_fn
        for hi = 0 to depth3 - 2
          if typeof(cur) != "struct" then break end if
          cur._ml_env_hop = true
          cur = cur._ml_parent_fn
        end for
      end for
    end for
  end if

  return state
end function

function _as_name(v)
  return _coerce_name(v)
end function

function _closure_declare_capture_bindings(state, fn_node)
  if typeof(fn_node) != "struct" then return state end if
  caps = fn_node._ml_captures
  if typeof(caps) != "array" or len(caps) <= 0 then return state end if
  cap_depth = fn_node._ml_capture_depth
  cap_index = fn_node._ml_capture_index
  names = _sort_names(caps)

  if typeof(state.scope_stack) != "array" or len(state.scope_stack) <= 0 then
    state.diagnostics = state.diagnostics + ["Internal error: scope stack not initialized"]
    return state
  end if

  for i = 0 to len(names) - 1
    name = _as_name(names[i])
    if name == "" then continue end if
    depth = _map_int_get(cap_depth, name, 0)
    idx = _map_int_get(cap_index, name, -1)
    if idx < 0 then
      state.diagnostics = state.diagnostics + ["Internal error: capture '" + name + "' missing index"]
      continue
    end if

    bid = scope.cg_next_binding_id(state)
    dep = scope.cg_scope_depth(state)
    b = scope.VarBinding(
      bid,
      name,
      "capture",
      "",
      0,
      dep,
      true,
      depth,
      idx,
      fn_node,
      false,
      0,
      false,
      0,
      0,
      ""
    )

    ss = state.scope_stack
    si = len(ss) - 1
    fr = ss[si]
    if typeof(fr) != "array" then fr = [] end if
    fr_b = t.arr_chunk_new(16)
    if len(fr) > 0 then fr_b = t.arr_chunk_push_all(fr_b, fr) end if
    fr_b = t.arr_chunk_push(fr_b, b)
    fr = t.arr_chunk_finish(fr_b)
    ss[si] = fr
    state.scope_stack = ss
  end for

  return state
end function

function emit_stmt(state, st)
  return cg_emit_stmt(state, st)
end function

function _user_function_has(state, qname)
  arr = state.user_functions
  if typeof(arr) != "array" or len(arr) <= 0 then return false end if
  for i = 0 to len(arr) - 1
    p = arr[i]
    if typeof(p) == "array" and len(p) == 2 and p[0] == qname then
      return true
    end if
  end for
  return false
end function

function _expr_uses_this(ex)
  if typeof(ex) != "struct" then return false end if
  k = ex.node_kind
  if k == "Var" then
    return _coerce_name(ex.name) == "this"
  end if
  if k == "Unary" then return _expr_uses_this(ex.right) end if
  if k == "Bin" then
    if _expr_uses_this(ex.left) then return true end if
    return _expr_uses_this(ex.right)
  end if
  if k == "Call" then
    if _expr_uses_this(ex.callee) then return true end if
    if typeof(ex.args) == "array" and len(ex.args) > 0 then
      for i = 0 to len(ex.args) - 1
        if i < 0 or i >= len(ex.args) then break end if
        if _expr_uses_this(ex.args[i]) then return true end if
      end for
    end if
    return false
  end if
  if k == "Member" then return _expr_uses_this(ex.target) end if
  if k == "Index" then
    if _expr_uses_this(ex.target) then return true end if
    return _expr_uses_this(ex.index)
  end if
  if k == "ArrayLit" then
    if typeof(ex.items) == "array" and len(ex.items) > 0 then
      for i = 0 to len(ex.items) - 1
        if i < 0 or i >= len(ex.items) then break end if
        if _expr_uses_this(ex.items[i]) then return true end if
      end for
    end if
    return false
  end if
  if k == "StructInit" then
    if typeof(ex.values) == "array" and len(ex.values) > 0 then
      for i = 0 to len(ex.values) - 1
        if i < 0 or i >= len(ex.values) then break end if
        if _expr_uses_this(ex.values[i]) then return true end if
      end for
    end if
    return false
  end if
  return false
end function

function _stmt_uses_this(st)
  if typeof(st) != "struct" then return false end if
  k = st.node_kind

  if k == "Print" or k == "ExprStmt" or k == "Assign" or k == "ConstDecl" or k == "Return" then
    return _expr_uses_this(st.expr)
  end if
  if k == "SetMember" then
    if _expr_uses_this(st.obj) then return true end if
    return _expr_uses_this(st.expr)
  end if
  if k == "SetIndex" then
    if _expr_uses_this(st.target) then return true end if
    if _expr_uses_this(st.index) then return true end if
    return _expr_uses_this(st.expr)
  end if
  if k == "If" then
    if _expr_uses_this(st.cond) then return true end if
    if typeof(st.then_body) == "array" and len(st.then_body) > 0 then
      for i = 0 to len(st.then_body) - 1
        if i < 0 or i >= len(st.then_body) then break end if
        if _stmt_uses_this(st.then_body[i]) then return true end if
      end for
    end if
    if typeof(st.elifs) == "array" and len(st.elifs) > 0 then
      for i = 0 to len(st.elifs) - 1
        if i < 0 or i >= len(st.elifs) then break end if
        eb = st.elifs[i]
        if typeof(eb) == "array" and len(eb) >= 2 then
          if _expr_uses_this(eb[0]) then return true end if
          if typeof(eb[1]) == "array" and len(eb[1]) > 0 then
            for j = 0 to len(eb[1]) - 1
              if j < 0 or j >= len(eb[1]) then break end if
              if _stmt_uses_this(eb[1][j]) then return true end if
            end for
          end if
        end if
      end for
    end if
    if typeof(st.else_body) == "array" and len(st.else_body) > 0 then
      for i = 0 to len(st.else_body) - 1
        if i < 0 or i >= len(st.else_body) then break end if
        if _stmt_uses_this(st.else_body[i]) then return true end if
      end for
    end if
    return false
  end if
  if k == "While" or k == "DoWhile" then
    if _expr_uses_this(st.cond) then return true end if
    if typeof(st.body) == "array" and len(st.body) > 0 then
      for i = 0 to len(st.body) - 1
        if i < 0 or i >= len(st.body) then break end if
        if _stmt_uses_this(st.body[i]) then return true end if
      end for
    end if
    return false
  end if
  if k == "For" then
    if _expr_uses_this(st.start) then return true end if
    if _expr_uses_this(st.end_expr) then return true end if
    if typeof(st.body) == "array" and len(st.body) > 0 then
      for i = 0 to len(st.body) - 1
        if i < 0 or i >= len(st.body) then break end if
        if _stmt_uses_this(st.body[i]) then return true end if
      end for
    end if
    return false
  end if
  if k == "ForEach" then
    if _expr_uses_this(st.iterable) then return true end if
    if typeof(st.body) == "array" and len(st.body) > 0 then
      for i = 0 to len(st.body) - 1
        if i < 0 or i >= len(st.body) then break end if
        if _stmt_uses_this(st.body[i]) then return true end if
      end for
    end if
    return false
  end if
  if k == "Switch" then
    if _expr_uses_this(st.expr) then return true end if
    if typeof(st.cases) == "array" and len(st.cases) > 0 then
      for i = 0 to len(st.cases) - 1
        if i < 0 or i >= len(st.cases) then break end if
        cs = st.cases[i]
        if typeof(cs) != "struct" then continue end if
        if cs.kind == "range" then
          if _expr_uses_this(cs.range_start) then return true end if
          if _expr_uses_this(cs.range_end) then return true end if
        end if
        if typeof(cs.values) == "array" and len(cs.values) > 0 then
          for j = 0 to len(cs.values) - 1
            if j < 0 or j >= len(cs.values) then break end if
            if _expr_uses_this(cs.values[j]) then return true end if
          end for
        end if
        if typeof(cs.body) == "array" and len(cs.body) > 0 then
          for j = 0 to len(cs.body) - 1
            if j < 0 or j >= len(cs.body) then break end if
            if _stmt_uses_this(cs.body[j]) then return true end if
          end for
        end if
      end for
    end if
    if typeof(st.default_body) == "array" and len(st.default_body) > 0 then
      for i = 0 to len(st.default_body) - 1
        if i < 0 or i >= len(st.default_body) then break end if
        if _stmt_uses_this(st.default_body[i]) then return true end if
      end for
    end if
    return false
  end if

  return false
end function

function _named_array_get(arr, key)
  if typeof(arr) != "array" or len(arr) <= 0 then return 0 end if
  for i = 0 to len(arr) - 1
    it = arr[i]
    if typeof(it) == "struct" and it.key == key then
      return it.values
    end if
    if typeof(it) == "array" and len(it) >= 2 and it[0] == key then
      return it[1]
    end if
  end for
  return 0
end function

function _named_array_set(arr, key, values)
  if typeof(arr) != "array" then arr =[] end if
  if len(arr) > 0 then
    for i = 0 to len(arr) - 1
      it = arr[i]
      if typeof(it) == "struct" and it.key == key then
        arr[i] = [key, values]
        return arr
      end if
      if typeof(it) == "array" and len(it) >= 2 and it[0] == key then
        arr[i] = [key, values]
        return arr
      end if
    end for
  end if
  return arr + [[key, values]]
end function

function _named_int_get(arr, key, defaultv)
  if typeof(arr) != "array" or len(arr) <= 0 then return defaultv end if
  for i = 0 to len(arr) - 1
    it = arr[i]
    if typeof(it) == "struct" and it.key == key then
      if typeof(it.value) == "int" then return it.value end if
      return defaultv
    end if
    if typeof(it) == "array" and len(it) >= 2 and it[0] == key then
      if typeof(it[1]) == "int" then return it[1] end if
      return defaultv
    end if
  end for
  return defaultv
end function

function _named_int_set(arr, key, value)
  if typeof(arr) != "array" then arr =[] end if
  if len(arr) > 0 then
    for i = 0 to len(arr) - 1
      it = arr[i]
      if typeof(it) == "struct" and it.key == key then
        arr[i] = [key, value]
        return arr
      end if
      if typeof(it) == "array" and len(it) >= 2 and it[0] == key then
        arr[i] = [key, value]
        return arr
      end if
    end for
  end if
  return arr + [[key, value]]
end function

function _next_struct_id(state)
  mx = 0
  arr = state.struct_ids
  if typeof(arr) == "array" and len(arr) > 0 then
    for i = 0 to len(arr) - 1
      it = arr[i]
      if typeof(it) == "struct" and typeof(it.key) == "string" and typeof(it.value) == "int" then
        if it.key != "error" and it.value > mx then mx = it.value end if
      end if
    end for
  end if
  return mx + 1
end function

function _next_enum_id(state)
  mx = 0
  arr = state.enum_ids
  if typeof(arr) == "array" and len(arr) > 0 then
    for i = 0 to len(arr) - 1
      it = arr[i]
      if typeof(it) == "struct" and typeof(it.value) == "int" then
        if it.value > mx then mx = it.value end if
      end if
    end for
  end if
  return mx + 1
end function

function _st_file(st)
  if typeof(st) == "struct" and typeof(st._filename) == "string" then return st._filename end if
  return ""
end function

function _has_dot_name(name)
  if typeof(name) != "string" then return false end if
  for i = 0 to len(name) - 1
    if name[i] == "." then return true end if
  end for
  return false
end function

function _strpair_get(arr, key)
  if typeof(arr) != "array" or len(arr) <= 0 then return "" end if
  for i = 0 to len(arr) - 1
    it = arr[i]
    if typeof(it) == "struct" and it.key == key then
      if typeof(it.value) == "string" then return it.value end if
      return ""
    end if
    if typeof(it) == "array" and len(it) >= 2 and it[0] == key then
      if typeof(it[1]) == "string" then return it[1] end if
      return ""
    end if
  end for
  return ""
end function

function _strpair_set(arr, key, value)
  if typeof(arr) != "array" then arr =[] end if
  if len(arr) > 0 then
    for i = 0 to len(arr) - 1
      it = arr[i]
      if typeof(it) == "struct" and it.key == key then
        arr[i] = [key, value]
        return arr
      end if
      if typeof(it) == "array" and len(it) >= 2 and it[0] == key then
        arr[i] = [key, value]
        return arr
      end if
    end for
  end if
  return arr + [[key, value]]
end function

function _collect_program_decls(state, stmts, prefix, current_file, file_prefixes, file_seen_nonpackage, next_sid, next_eid, in_ns)
  if typeof(stmts) != "array" or len(stmts) <= 0 then
    return [state, current_file, file_prefixes, file_seen_nonpackage, next_sid, next_eid]
  end if

  cur_file = current_file
  pref = prefix

  i = 0
  n = len(stmts)
  while i < n
    st = stmts[i]
    i = i + 1
    if typeof(st) != "struct" then continue end if

    sf = _decl_st_file(st)
    if sf == "" then sf = cur_file end if
    if cur_file == "" or (sf != "" and sf != cur_file) then
      cur_file = sf
      pref = prefix
      if cur_file != "" then
        fp = _strpair_get(file_prefixes, cur_file)
        if fp != "" then pref = fp end if
      end if
    end if

    k = st.node_kind
    file_key = cur_file
    if file_key == "" then file_key = "<entry>" end if

    if k != "NamespaceDecl" and in_ns == false then
      file_seen_nonpackage = _named_int_set(file_seen_nonpackage, file_key, 1)
    end if

    if k == "NamespaceDecl" then
      seen_nonpkg = _named_int_get(file_seen_nonpackage, file_key, 0)
      if seen_nonpkg != 0 then
        state.diagnostics = state.diagnostics +["'package' must be the first statement in the file"]
        continue
      end if
      prev_pkg = _strpair_get(file_prefixes, file_key)
      if prev_pkg != "" then
        state.diagnostics = state.diagnostics +["'package' may only appear once per file"]
        continue
      end if

      ns = _coerce_name(st.name)
      if ns != "" then
        fp2 = ns + "."
        file_prefixes = _strpair_set(file_prefixes, file_key, fp2)
        pref = fp2
      end if
      continue
    end if

    if k == "NamespaceDef" then
      nsd = _coerce_name(st.name)
      if _has_reserved_segment(state, nsd) then
        state.diagnostics = state.diagnostics +["namespace name '" + nsd + "' is reserved"]
      end if
      sub_pref = pref
      if nsd != "" then sub_pref = pref + nsd + "." end if
      body = st.body
      sub = _collect_program_decls(state, body, sub_pref, cur_file, file_prefixes, file_seen_nonpackage, next_sid, next_eid, true)
      state = sub[0]
      cur_file = sub[1]
      file_prefixes = sub[2]
      file_seen_nonpackage = sub[3]
      next_sid = sub[4]
      next_eid = sub[5]
      continue
    end if

    if k == "FunctionDef" then
      base_name = _coerce_name(st.name)
      if base_name != "main" and _has_reserved_segment(state, base_name) then
        state.diagnostics = state.diagnostics +["function name '" + base_name + "' is reserved"]
      end if

      if base_name == "main" then
        if pref != "" then
          state.diagnostics = state.diagnostics +["main(args) must be declared at top-level"]
        end if
        pcount = 0
        if typeof(st.params) == "array" then pcount = len(st.params) end if
        if pcount != 1 then
          state.diagnostics = state.diagnostics +["main(args) expects exactly 1 parameter"]
        end if
      end if

      qname = base_name
      if pref != "" and base_name != "main" then qname = pref + base_name end if
      if _user_function_has(state, qname) then
        state.diagnostics = state.diagnostics +["duplicate function: " + qname]
        continue
      end if
      st.name = qname
      state = _set_user_function(state, qname, st)
      continue
    end if

    if k == "StructDef" then
      sbase = _coerce_name(st.name)
      if _has_reserved_segment(state, sbase) then
        state.diagnostics = state.diagnostics +["struct name '" + sbase + "' is reserved"]
      end if
      sqn = sbase
      if pref != "" then sqn = pref + sbase end if
      st.name = sqn

      flds = st.fields
      if typeof(flds) != "array" then flds = [] end if
      vals = _named_array_get(state.struct_fields, sqn)
      if typeof(vals) == "array" then
        state.diagnostics = state.diagnostics +["duplicate struct: " + sqn]
      else
        seen_fields = []
        dup_field = ""
        if len(flds) > 0 then
          for fi = 0 to len(flds) - 1
            fnm = _coerce_name(flds[fi])
            if _arr_has(seen_fields, fnm) then
              dup_field = fnm
              break
            end if
            seen_fields = _arr_add_unique(seen_fields, fnm)
          end for
        end if
        if dup_field != "" then
          state.diagnostics = state.diagnostics +["duplicate field " + dup_field + " in struct " + sqn]
        else
          state.struct_fields = _named_array_set(state.struct_fields, sqn, flds)
        end if
      end if

      methods_using_this = []
      mdict = []
      sdict = []
      seen_mnames = []
      if typeof(st.methods) == "array" and len(st.methods) > 0 then
        for mi = 0 to len(st.methods) - 1
          if mi < 0 or mi >= len(st.methods) then break end if
          mfn = st.methods[mi]
          if typeof(mfn) != "struct" then continue end if

          mname = _coerce_name(mfn.name)
          if mname == "" then
            state.diagnostics = state.diagnostics +["invalid method name in struct " + sqn]
            continue
          end if
          if _arr_has(seen_mnames, mname) then
            state.diagnostics = state.diagnostics +["duplicate method " + mname + " in struct " + sqn]
            continue
          end if
          if _arr_has(flds, mname) then
            state.diagnostics = state.diagnostics +["method name '" + mname + "' conflicts with field in struct " + sqn]
            continue
          end if
          seen_mnames = _arr_add_unique(seen_mnames, mname)

          is_static = false
          if typeof(mfn.is_static) == "bool" and mfn.is_static then is_static = true end if

          qfn = ""
          params_new = []
          if typeof(mfn.params) == "array" then params_new = mfn.params else params_new = [] end if
          if is_static then
            qfn = sqn + ".__static__." + mname
            sdict = _strpair_set(sdict, mname, qfn)
          else
            qfn = sqn + "." + mname
            params_new = ["this"] + params_new
            mdict = _strpair_set(mdict, mname, qfn)
          end if

          mfn.name = qfn
          mfn.params = params_new

          if _user_function_has(state, qfn) then
            state.diagnostics = state.diagnostics +["method name conflicts with function: " + qfn]
          else
            state = _set_user_function(state, qfn, mfn)
          end if

          if is_static == false then
            uses_this = false
            if typeof(mfn.body) == "array" and len(mfn.body) > 0 then
              for bi = 0 to len(mfn.body) - 1
                if bi < 0 or bi >= len(mfn.body) then break end if
                if _stmt_uses_this(mfn.body[bi]) then
                  uses_this = true
                  break
                end if
              end for
            end if
            if uses_this then
              methods_using_this = _arr_add_unique(methods_using_this, mname)
            end if
          end if
        end for
      end if
      if typeof(mdict) == "array" and len(mdict) > 0 then
        state.struct_methods = _named_array_set(state.struct_methods, sqn, mdict)
      end if
      if typeof(sdict) == "array" and len(sdict) > 0 then
        state.struct_static_methods = _named_array_set(state.struct_static_methods, sqn, sdict)
      end if
      if typeof(methods_using_this) == "array" and len(methods_using_this) > 0 then
        state.extern_structs = _named_array_set(state.extern_structs, sqn, methods_using_this)
      end if

      sid = _named_int_get(state.struct_ids, sqn, -1)
      if sid < 0 then
        state.struct_ids = _named_int_set(state.struct_ids, sqn, next_sid)
        next_sid = next_sid + 1
      end if
      continue
    end if

    if k == "EnumDef" then
      ebase = _coerce_name(st.name)
      if _has_reserved_segment(state, ebase) then
        state.diagnostics = state.diagnostics +["enum name '" + ebase + "' is reserved"]
      end if
      eqn = ebase
      if pref != "" then eqn = pref + ebase end if
      st.name = eqn

      vars = st.variants
      if typeof(vars) != "array" then vars = [] end if
      if len(vars) > 65536 then
        state.diagnostics = state.diagnostics +["enum " + eqn + " has too many variants (max 65536)"]
        continue
      end if

      if typeof(_named_array_get(state.enum_variants, eqn)) == "array" or typeof(_named_array_get(state.value_enum_values, eqn)) == "array" then
        state.diagnostics = state.diagnostics +["duplicate enum: " + eqn]
        continue
      end if
      if _user_function_has(state, eqn) then
        state.diagnostics = state.diagnostics +["enum name conflicts with function: " + eqn]
        continue
      end if
      if typeof(_named_array_get(state.struct_fields, eqn)) == "array" then
        state.diagnostics = state.diagnostics +["enum name conflicts with struct: " + eqn]
        continue
      end if

      dup_variant = ""
      seen_variants = []
      if len(vars) > 0 then
        for vi = 0 to len(vars) - 1
          vn = _coerce_name(vars[vi])
          if vn == "" then
            dup_variant = "<invalid>"
            break
          end if
          if _arr_has(seen_variants, vn) then
            dup_variant = vn
            break
          end if
          seen_variants = _arr_add_unique(seen_variants, vn)
        end for
      end if
      if dup_variant != "" then
        if dup_variant == "<invalid>" then
          state.diagnostics = state.diagnostics +["invalid enum variant in " + eqn]
        else
          state.diagnostics = state.diagnostics +["duplicate variant " + dup_variant + " in enum " + eqn]
        end if
        continue
      end if

      vals = st.values
      if typeof(vals) != "array" then vals = [] end if
      has_value_enum = false
      if len(vals) > 0 then
        for vvi = 0 to len(vals) - 1
          if typeof(vals[vvi]) != "void" then
            has_value_enum = true
            break
          end if
        end for
      end if

      if has_value_enum then
        if len(vals) != len(vars) then
          state.diagnostics = state.diagnostics +["enum " + eqn + " value list length mismatch"]
          continue
        end if

        member_map = []
        prev_int_member = ""
        bad_value_enum = false

        for vi2 = 0 to len(vars) - 1
          vname = _coerce_name(vars[vi2])
          vx = vals[vi2]
          expr_node = void

          if typeof(vx) != "void" then
            if _is_constexpr_expr(state, vx) == false then
              state.diagnostics = state.diagnostics +["enum " + eqn + " value for " + vname + " must be constexpr"]
              bad_value_enum = true
              continue
            end if
            expr_node = vx
          else
            p0 = 0
            if typeof(st._pos) == "int" then p0 = st._pos end if
            f0 = ""
            if typeof(st._filename) == "string" then f0 = st._filename end if

            if prev_int_member == "" then
              expr_node = ml.Num("Num", 0, p0, f0)
            else
              vref = ml.Var("Var", eqn + "." + prev_int_member, p0, f0)
              one = ml.Num("Num", 1, p0, f0)
              expr_node = ml.Bin("Bin", vref, "+", one, p0, f0)
              expr_node._ml_enum_autoinc_prev = eqn + "." + prev_int_member
            end if
          end if

          member_map = _named_array_set(member_map, vname, expr_node)

          if typeof(vx) == "void" then
            prev_int_member = vname
          else
            if typeof(vx) != "struct" or vx.node_kind != "Str" then
              prev_int_member = vname
            end if
          end if
        end for

        if bad_value_enum == false then
          state.value_enum_values = _named_array_set(state.value_enum_values, eqn, member_map)
        end if
        continue
      end if

      state.enum_variants = _named_array_set(state.enum_variants, eqn, vars)
      eid = _named_int_get(state.enum_ids, eqn, -1)
      if eid < 0 then
        state.enum_ids = _named_int_set(state.enum_ids, eqn, next_eid)
        next_eid = next_eid + 1
      end if
      continue
    end if

    if k == "ConstDecl" or k == "Assign" then
      nm = _coerce_name(st.name)
      if pref != "" and nm != "" and _has_dot_name(nm) == false then
        st.name = pref + nm
      end if
      continue
    end if
  end while

  return [state, cur_file, file_prefixes, file_seen_nonpackage, next_sid, next_eid]
end function

function _fn_arity_map(state)
  vals =[]
  arr = state.user_functions
  if typeof(arr) != "array" or len(arr) <= 0 then return vals end if
  for i = 0 to len(arr) - 1
    it = arr[i]
    if typeof(it) != "array" or len(it) != 2 then continue end if
    qn = _coerce_name(it[0])
    fn = it[1]
    if qn == "" or typeof(fn) != "struct" then continue end if
    ar = 0
    if typeof(fn.params) == "array" then ar = len(fn.params) end if
    vals = _named_int_set(vals, qn, ar)
    if _has_dot_name(qn) == false then
      vals = _named_int_set(vals, qn, ar)
    end if
  end for
  return vals
end function

function _member_chain_name(ex)
  if typeof(ex) != "struct" then return "" end if
  if ex.node_kind == "Var" then
    return _coerce_name(ex.name)
  end if
  if ex.node_kind == "Member" then
    b = _member_chain_name(ex.target)
    n = _coerce_name(ex.name)
    if b == "" or n == "" then return "" end if
    return b + "." + n
  end if
  return ""
end function

function _check_expr_semantics(state, ex, fn_arities)
  if typeof(ex) != "struct" then return state end if
  k = ex.node_kind

  if k == "Call" then
    cal = ex.callee
    if typeof(cal) == "struct" and cal.node_kind == "Var" then
      nm = _coerce_name(cal.name)
      if nm != "" then
        exp = _named_int_get(fn_arities, nm, -1)
        if exp >= 0 then
          got = 0
          if typeof(ex.args) == "array" then got = len(ex.args) end if
          if got != exp then
            state.diagnostics = state.diagnostics +["Function " + nm + " expects " + exp + " arguments, got " + got]
          end if
        end if
      end if
    end if
    if typeof(cal) == "struct" and cal.node_kind == "Member" then
      owner = _member_chain_name(cal.target)
      mn = _coerce_name(cal.name)
      if owner != "" and mn != "" then
        need_recv = _named_array_get(state.extern_structs, owner)
        if typeof(need_recv) == "array" and _arr_has(need_recv, mn) then
          state.diagnostics = state.diagnostics +["Cannot call '" + owner + "." + mn + "' without receiver because it uses 'this'"]
        end if
      end if
    end if
    state = _check_expr_semantics(state, cal, fn_arities)
    if typeof(ex.args) == "array" and len(ex.args) > 0 then
      for i = 0 to len(ex.args) - 1
        if i < 0 or i >= len(ex.args) then break end if
        state = _check_expr_semantics(state, ex.args[i], fn_arities)
      end for
    end if
    return state
  end if

  if k == "Member" then
    base = _member_chain_name(ex.target)
    mem = _coerce_name(ex.name)
    if base != "" and mem != "" then
      vars = _named_array_get(state.enum_variants, base)
      if typeof(vars) == "array" and _arr_has(vars, mem) == false then
        state.diagnostics = state.diagnostics +["Enum " + base + " has no variant " + mem]
      end if
    end if
    return _check_expr_semantics(state, ex.target, fn_arities)
  end if

  if k == "Unary" then
    return _check_expr_semantics(state, ex.right, fn_arities)
  end if

  if k == "Bin" then
    state = _check_expr_semantics(state, ex.left, fn_arities)
    return _check_expr_semantics(state, ex.right, fn_arities)
  end if

  if k == "Index" then
    state = _check_expr_semantics(state, ex.target, fn_arities)
    return _check_expr_semantics(state, ex.index, fn_arities)
  end if

  if k == "ArrayLit" then
    if typeof(ex.items) == "array" and len(ex.items) > 0 then
      for i = 0 to len(ex.items) - 1
        if i < 0 or i >= len(ex.items) then break end if
        state = _check_expr_semantics(state, ex.items[i], fn_arities)
      end for
    end if
    return state
  end if

  if k == "StructInit" then
    if typeof(ex.values) == "array" and len(ex.values) > 0 then
      for i = 0 to len(ex.values) - 1
        if i < 0 or i >= len(ex.values) then break end if
        state = _check_expr_semantics(state, ex.values[i], fn_arities)
      end for
    end if
    return state
  end if

  return state
end function

function _check_stmt_semantics(state, st, fn_arities)
  if typeof(st) != "struct" then return state end if
  k = st.node_kind

  if k == "Print" or k == "ExprStmt" or k == "Assign" or k == "ConstDecl" or k == "Return" then
    if typeof(st.expr) == "struct" then
      state = _check_expr_semantics(state, st.expr, fn_arities)
    end if
    return state
  end if

  if k == "SetMember" then
    if typeof(st.obj) == "struct" then
      state = _check_expr_semantics(state, st.obj, fn_arities)
    end if
    if typeof(st.expr) == "struct" then
      state = _check_expr_semantics(state, st.expr, fn_arities)
    end if
    return state
  end if

  if k == "SetIndex" then
    if typeof(st.target) == "struct" then
      state = _check_expr_semantics(state, st.target, fn_arities)
    end if
    if typeof(st.index) == "struct" then
      state = _check_expr_semantics(state, st.index, fn_arities)
    end if
    if typeof(st.expr) == "struct" then
      state = _check_expr_semantics(state, st.expr, fn_arities)
    end if
    return state
  end if

  if k == "FunctionDef" then
    if typeof(st.body) == "array" and len(st.body) > 0 then
      for i = 0 to len(st.body) - 1
        if i < 0 or i >= len(st.body) then break end if
        state = _check_stmt_semantics(state, st.body[i], fn_arities)
      end for
    end if
    return state
  end if

  if k == "NamespaceDef" then
    if typeof(st.body) == "array" and len(st.body) > 0 then
      for i = 0 to len(st.body) - 1
        if i < 0 or i >= len(st.body) then break end if
        state = _check_stmt_semantics(state, st.body[i], fn_arities)
      end for
    end if
    return state
  end if

  if k == "StructDef" then
    if typeof(st.methods) == "array" and len(st.methods) > 0 then
      for i = 0 to len(st.methods) - 1
        if i < 0 or i >= len(st.methods) then break end if
        state = _check_stmt_semantics(state, st.methods[i], fn_arities)
      end for
    end if
    return state
  end if

  if k == "If" then
    if typeof(st.cond) == "struct" then
      state = _check_expr_semantics(state, st.cond, fn_arities)
    end if
    if typeof(st.then_body) == "array" and len(st.then_body) > 0 then
      for i = 0 to len(st.then_body) - 1
        if i < 0 or i >= len(st.then_body) then break end if
        state = _check_stmt_semantics(state, st.then_body[i], fn_arities)
      end for
    end if
    if typeof(st.elifs) == "array" and len(st.elifs) > 0 then
      for i = 0 to len(st.elifs) - 1
        if i < 0 or i >= len(st.elifs) then break end if
        eb = st.elifs[i]
        if typeof(eb) == "array" and len(eb) >= 2 then
          if typeof(eb[0]) == "struct" then
            state = _check_expr_semantics(state, eb[0], fn_arities)
          end if
          if typeof(eb[1]) == "array" and len(eb[1]) > 0 then
            for j = 0 to len(eb[1]) - 1
              if j < 0 or j >= len(eb[1]) then break end if
              state = _check_stmt_semantics(state, eb[1][j], fn_arities)
            end for
          end if
        end if
      end for
    end if
    if typeof(st.else_body) == "array" and len(st.else_body) > 0 then
      for i = 0 to len(st.else_body) - 1
        if i < 0 or i >= len(st.else_body) then break end if
        state = _check_stmt_semantics(state, st.else_body[i], fn_arities)
      end for
    end if
    return state
  end if

  if k == "While" or k == "DoWhile" then
    if typeof(st.cond) == "struct" then
      state = _check_expr_semantics(state, st.cond, fn_arities)
    end if
    if typeof(st.body) == "array" and len(st.body) > 0 then
      for i = 0 to len(st.body) - 1
        if i < 0 or i >= len(st.body) then break end if
        state = _check_stmt_semantics(state, st.body[i], fn_arities)
      end for
    end if
    return state
  end if

  if k == "For" then
    if typeof(st.start) == "struct" then
      state = _check_expr_semantics(state, st.start, fn_arities)
    end if
    if typeof(st.end_expr) == "struct" then
      state = _check_expr_semantics(state, st.end_expr, fn_arities)
    end if
    if typeof(st.body) == "array" and len(st.body) > 0 then
      for i = 0 to len(st.body) - 1
        if i < 0 or i >= len(st.body) then break end if
        state = _check_stmt_semantics(state, st.body[i], fn_arities)
      end for
    end if
    return state
  end if

  if k == "ForEach" then
    if typeof(st.iterable) == "struct" then
      state = _check_expr_semantics(state, st.iterable, fn_arities)
    end if
    if typeof(st.body) == "array" and len(st.body) > 0 then
      for i = 0 to len(st.body) - 1
        if i < 0 or i >= len(st.body) then break end if
        state = _check_stmt_semantics(state, st.body[i], fn_arities)
      end for
    end if
    return state
  end if

  if k == "Switch" then
    if typeof(st.expr) == "struct" then
      state = _check_expr_semantics(state, st.expr, fn_arities)
    end if
    if typeof(st.cases) == "array" and len(st.cases) > 0 then
      for i = 0 to len(st.cases) - 1
        if i < 0 or i >= len(st.cases) then break end if
      cs = st.cases[i]
      if typeof(cs) != "struct" then continue end if
      if cs.kind == "range" then
        if typeof(cs.range_start) == "struct" then
          state = _check_expr_semantics(state, cs.range_start, fn_arities)
        end if
        if typeof(cs.range_end) == "struct" then
          state = _check_expr_semantics(state, cs.range_end, fn_arities)
        end if
      end if
      if typeof(cs.values) == "array" and len(cs.values) > 0 then
        for vi = 0 to len(cs.values) - 1
          if vi < 0 or vi >= len(cs.values) then break end if
          vv = cs.values[vi]
          if typeof(vv) == "struct" then
            state = _check_expr_semantics(state, vv, fn_arities)
          else
            if typeof(vv) == "array" and len(vv) >= 2 then
              if typeof(vv[0]) == "struct" then state = _check_expr_semantics(state, vv[0], fn_arities) end if
              if typeof(vv[1]) == "struct" then state = _check_expr_semantics(state, vv[1], fn_arities) end if
            end if
          end if
        end for
      end if
      if typeof(cs.body) == "array" and len(cs.body) > 0 then
        for bi = 0 to len(cs.body) - 1
          if bi < 0 or bi >= len(cs.body) then break end if
          state = _check_stmt_semantics(state, cs.body[bi], fn_arities)
        end for
      end if
      end for
    end if
    if typeof(st.default_body) == "array" and len(st.default_body) > 0 then
      for i = 0 to len(st.default_body) - 1
        if i < 0 or i >= len(st.default_body) then break end if
        state = _check_stmt_semantics(state, st.default_body[i], fn_arities)
      end for
    end if
    return state
  end if

  return state
end function

function _check_program_semantics(state, program)
  fn_arities = _fn_arity_map(state)
  if typeof(program) != "array" or len(program) <= 0 then return state end if
  for i = 0 to len(program) - 1
    state = _check_stmt_semantics(state, program[i], fn_arities)
  end for
  return state
end function

function _binding_global_label(state, qname)
  b = scope.resolve_binding(state, qname)
  if typeof(b) == "struct" and b.kind == "global" and typeof(b.label) == "string" and b.label != "" then
    return b.label
  end if
  return ""
end function

function _ensure_global_binding_label(state, qname, decl_node)
  lbl = _binding_global_label(state, qname)
  if lbl != "" then return [state, lbl] end if
  state = scope.declare_global_binding_root(state, qname, decl_node, false, 0)
  lbl = _binding_global_label(state, qname)
  return [state, lbl]
end function

function _builtin_specs()
  return [
    ["len", 1, 1, "fn_builtin_len"],
    ["toNumber", 1, 1, "fn_toNumber"],
    ["typeof", 1, 1, "fn_typeof"],
    ["typeName", 1, 1, "fn_typeName"],
    ["input", 0, 1, "fn_builtin_input"],
    ["decode", 1, 2, "fn_decode"],
    ["decodeZ", 1, 1, "fn_decodeZ"],
    ["decode16Z", 1, 1, "fn_decode16Z"],
    ["hex", 1, 1, "fn_hex"],
    ["fromHex", 1, 1, "fn_fromHex"],
    ["slice", 3, 3, "fn_slice"],
    ["gc_collect", 0, 0, "fn_builtin_gc_collect"],
    ["gc_set_limit", 1, 1, "fn_builtin_gc_set_limit"],
    ["heap_count", 0, 0, "fn_heap_count"],
    ["heap_bytes_used", 0, 0, "fn_heap_bytes_used"],
    ["heap_bytes_committed", 0, 0, "fn_heap_bytes_committed"],
    ["heap_bytes_reserved", 0, 0, "fn_heap_bytes_reserved"],
    ["heap_free_bytes", 0, 0, "fn_heap_free_bytes"],
    ["heap_free_blocks", 0, 0, "fn_heap_free_blocks"],
  ]
end function

function emit_program(state, program)
  state.extern_structs = []
  state.value_enum_values = []
  nsid = _next_struct_id(state)
  neid = _next_enum_id(state)
  decl_file_prefixes = []
  decl_seen_nonpackage = []
  next_sid = nsid
  next_eid = neid

  res = _collect_program_decls(
    state,
    program,
    "",
    "",
    decl_file_prefixes,
    decl_seen_nonpackage,
    next_sid,
    next_eid,
    false
  )
  state = res[0]
  decl_file_prefixes = res[2]
  decl_seen_nonpackage = res[3]
  next_sid = res[4]
  next_eid = res[5]
  state = _mem_probe(state, "decls_done")

  state.file_prefix_map = decl_file_prefixes
  state.nested_user_functions = []
  // Closure analysis metadata (captures/env layout) for nested functions.
  state = _closure_analyze_program(state, program)
  state = _closure_assign_env_layout(state, state.nested_user_functions)
  state = _mem_probe(state, "closure_done")
  state.typename_struct_by_id = []
  state.typename_struct_by_qname = []
  state.typename_enum_by_id = []
  state.typename_enum_by_qname = []
  state.function_global_labels = []
  state.struct_global_labels = []
  state.builtin_specs = _builtin_specs()
  state.builtin_global_labels = []
  state.extern_global_labels = []
  state.extern_stub_labels = []
  state.callprof_entries = []
  state.callprof_index = []
  state.callprof_name_labels = []
  state.callprof_n = 0

  if state.call_profile then
    cp_entries_b = t.arr_chunk_new(64)
    if typeof(state.user_functions) == "array" and len(state.user_functions) > 0 then
      for cpi = 0 to len(state.user_functions) - 1
        cp_it = state.user_functions[cpi]
        if typeof(cp_it) != "array" or len(cp_it) != 2 then continue end if
        cp_name = _coerce_name(cp_it[0])
        if cp_name == "" then continue end if
        cp_entries_b = t.arr_chunk_push(cp_entries_b, [cp_name, cp_name])
      end for
    end if
    cp_entries = t.arr_chunk_finish(cp_entries_b)

    state.callprof_entries = cp_entries
    state.callprof_n = len(cp_entries)

    if state.callprof_n > 0 then
      cp_name_labels_b = t.arr_chunk_new(64)
      state.data = d.data_add_bytes(state.data, "callprof_counts", bytes(8 * state.callprof_n, 0))
      for cpi = 0 to state.callprof_n - 1
        cp_lbl = "callprof_name_" + cpi
        cp_disp = cp_entries[cpi][1]
        state.rdata = d.rdata_add_obj_string(state.rdata, cp_lbl, cp_disp)
        cp_name_labels_b = t.arr_chunk_push(cp_name_labels_b, cp_lbl)
        cp_code = cp_entries[cpi][0]
        state.callprof_index = _named_int_set(state.callprof_index, cp_code, cpi)
      end for
      state.callprof_name_labels = t.arr_chunk_finish(cp_name_labels_b)
    end if
  end if

  // Materialize boxed concrete type-name strings for typeName(x).
  typename_struct_by_id_b = t.arr_chunk_new(64)
  if typeof(state.struct_ids) == "array" and len(state.struct_ids) > 0 then
    for tsi = 0 to len(state.struct_ids) - 1
      it_sid = state.struct_ids[tsi]
      sqn_t = ""
      sid_t = -1
      if typeof(it_sid) == "struct" then
        sqn_t = _coerce_name(it_sid.key)
        if typeof(it_sid.value) == "int" then sid_t = it_sid.value end if
      else
        if typeof(it_sid) == "array" and len(it_sid) >= 2 then
          sqn_t = _coerce_name(it_sid[0])
          if typeof(it_sid[1]) == "int" then sid_t = it_sid[1] end if
        end if
      end if
      if sqn_t == "" or sid_t < 0 then continue end if
      lbl_t = "obj_typename_struct_" + sid_t
      state.rdata = d.rdata_add_obj_string(state.rdata, lbl_t, sqn_t)
      typename_struct_by_id_b = t.arr_chunk_push(typename_struct_by_id_b, [sid_t, lbl_t])
      state.typename_struct_by_qname = _strpair_set(state.typename_struct_by_qname, sqn_t, lbl_t)
    end for
  end if
  state.typename_struct_by_id = t.arr_chunk_finish(typename_struct_by_id_b)

  typename_enum_by_id_b = t.arr_chunk_new(64)
  if typeof(state.enum_ids) == "array" and len(state.enum_ids) > 0 then
    for tei = 0 to len(state.enum_ids) - 1
      it_eid = state.enum_ids[tei]
      eqn_t = ""
      eid_t = -1
      if typeof(it_eid) == "struct" then
        eqn_t = _coerce_name(it_eid.key)
        if typeof(it_eid.value) == "int" then eid_t = it_eid.value end if
      else
        if typeof(it_eid) == "array" and len(it_eid) >= 2 then
          eqn_t = _coerce_name(it_eid[0])
          if typeof(it_eid[1]) == "int" then eid_t = it_eid[1] end if
        end if
      end if
      if eqn_t == "" or eid_t < 0 then continue end if
      lbl_e = "obj_typename_enum_" + eid_t
      state.rdata = d.rdata_add_obj_string(state.rdata, lbl_e, eqn_t)
      typename_enum_by_id_b = t.arr_chunk_push(typename_enum_by_id_b, [eid_t, lbl_e])
      state.typename_enum_by_qname = _strpair_set(state.typename_enum_by_qname, eqn_t, lbl_e)
    end for
  end if
  state.typename_enum_by_id = t.arr_chunk_finish(typename_enum_by_id_b)

  // Hoist function identifiers as first-class callable globals.
  if typeof(state.user_functions) == "array" and len(state.user_functions) > 0 then
    for i = 0 to len(state.user_functions) - 1
      it = state.user_functions[i]
      if typeof(it) != "array" or len(it) != 2 then continue end if
      fn_qn = _coerce_name(it[0])
      fn_node = it[1]
      if fn_qn == "" then continue end if
      r0 = _ensure_global_binding_label(state, fn_qn, fn_node)
      state = r0[0]
      lbl0 = r0[1]
      if lbl0 != "" then
        state.function_global_labels = _strpair_set(state.function_global_labels, fn_qn, lbl0)
      end if
    end for
  end if

  // Hoist struct identifiers as first-class type/ctor globals.
  if typeof(state.struct_fields) == "array" and len(state.struct_fields) > 0 then
    for si = 0 to len(state.struct_fields) - 1
      sf = state.struct_fields[si]
      sqn = ""
      if typeof(sf) == "struct" then sqn = _coerce_name(sf.key) end if
      if typeof(sf) == "array" and len(sf) >= 2 then sqn = _coerce_name(sf[0]) end if
      if sqn == "" then continue end if
      r1 = _ensure_global_binding_label(state, sqn, 0)
      state = r1[0]
      lbl1 = r1[1]
      if lbl1 != "" then
        state.struct_global_labels = _strpair_set(state.struct_global_labels, sqn, lbl1)
      end if
    end for
  end if

  // Hoist selected builtins as first-class callable globals when name is otherwise unused.
  if typeof(state.builtin_specs) == "array" and len(state.builtin_specs) > 0 then
    for bi = 0 to len(state.builtin_specs) - 1
      sp = state.builtin_specs[bi]
      if typeof(sp) != "array" or len(sp) < 4 then continue end if
      bname = _coerce_name(sp[0])
      if bname == "" then continue end if
      bx = scope.resolve_binding(state, bname)
      if typeof(bx) == "struct" then continue end if
      r2 = _ensure_global_binding_label(state, bname, 0)
      state = r2[0]
      lbl2 = r2[1]
      if lbl2 != "" then
        state.builtin_global_labels = _strpair_set(state.builtin_global_labels, bname, lbl2)
      end if
    end for
  end if

  // Hoist extern identifiers as stub-callable OBJ_BUILTIN globals.
  if typeof(state.extern_sigs) == "array" and len(state.extern_sigs) > 0 then
    for ei = 0 to len(state.extern_sigs) - 1
      sig = state.extern_sigs[ei]
      if typeof(sig) != "struct" then continue end if
      qn = _coerce_name(sig.qname)
      if qn == "" then qn = _coerce_name(sig.name) end if
      if qn == "" then continue end if
      ex = scope.resolve_binding(state, qn)
      if typeof(ex) == "struct" then continue end if
      r3 = _ensure_global_binding_label(state, qn, 0)
      state = r3[0]
      lbl3 = r3[1]
      if lbl3 != "" then
        state.extern_global_labels = _strpair_set(state.extern_global_labels, qn, lbl3)
        state.extern_stub_labels = _strpair_set(state.extern_stub_labels, qn, "fn_extern_" + lbl3)
      end if
    end for
  end if
  state = _mem_probe(state, "pre_flatten")

  program = _flatten_runtime(state, program)
  state = _mem_probe(state, "flatten_done")

  state = _check_program_semantics(state, program)
  state = _mem_probe(state, "semantic_done")

  // Entry RSP is 8 mod 16 on Windows process start.
  // Keep pre-call alignment at 16-byte by reserving a frame that's 8 mod 16.
  main_frame = 0x608
  main_root_rec_off = main_frame - 0x20
  main_root_base = 0x40
  main_root_top = main_root_rec_off
  state.asm = a.sub_rsp_imm32(state.asm, main_frame)
  state = mem.emit_gc_clear_root_slots(state, main_root_base, main_root_top)
  state = mem.emit_gc_push_root_frame(state, main_root_rec_off, main_root_base, main_root_top)

  // stdout handle in rbx
  state.asm = a.mov_rcx_imm32(state.asm, 0xFFFFFFF5)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_GetStdHandle")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_r64_r64(state.asm, "rbx", "rax")

  // UTF-8 console mode
  state.asm = a.mov_rcx_imm32(state.asm, 65001)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_SetConsoleOutputCP")
  state.asm = a.call_rax(state.asm)

  // Heap / GC init
  heap_reserve = _heap_cfg_get_int(state, "reserve_bytes", 0x02000000)
  state = mem.emit_heap_init(state, heap_reserve)
  disable_periodic = _heap_cfg_get_bool(state, "gc_disable_periodic", false)
  state = mem.emit_gc_init_globals(state, disable_periodic)
  gc_limit = _heap_cfg_get_int(state, "gc_bytes_limit", 0)
  if gc_limit > 0 then
    state.asm = a.mov_rax_imm64(state.asm, gc_limit)
    state.asm = a.mov_rip_qword_rax(state.asm, "gc_bytes_limit")
    state.asm = a.mov_rax_imm64(state.asm, 0)
    state.asm = a.mov_rip_qword_rax(state.asm, "gc_bytes_since")
  end if

  // Initialize first-class function values (OBJ_FUNCTION).
  if typeof(state.user_functions) == "array" and len(state.user_functions) > 0 then
    for i = 0 to len(state.user_functions) - 1
      itf = state.user_functions[i]
      if typeof(itf) != "array" or len(itf) != 2 then continue end if
      fn_qn = _coerce_name(itf[0])
      fn_node = itf[1]
      if fn_qn == "" or typeof(fn_node) != "struct" then continue end if
      lblf = _strpair_get(state.function_global_labels, fn_qn)
      if lblf == "" then continue end if
      ar = 0
      if typeof(fn_node.params) == "array" then ar = len(fn_node.params) end if
      state.asm = a.mov_rcx_imm32(state.asm, 24)
      state.asm = a.call(state.asm, "fn_alloc")
      state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_FUNCTION, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, ar, false)
      state.asm = a.lea_rax_rip(state.asm, "fn_user_" + fn_qn)
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8, "rax")
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 16, t.enc_void(), true)
      state.asm = a.mov_rip_qword_r11(state.asm, lblf)
    end for
  end if

  // Initialize first-class struct type values (OBJ_STRUCTTYPE).
  if typeof(state.struct_fields) == "array" and len(state.struct_fields) > 0 then
    for si = 0 to len(state.struct_fields) - 1
      sf = state.struct_fields[si]
      sqn = ""
      flds = []
      if typeof(sf) == "struct" then
        sqn = _coerce_name(sf.key)
        if typeof(sf.values) == "array" then flds = sf.values end if
      else
        if typeof(sf) == "array" and len(sf) >= 2 then
          sqn = _coerce_name(sf[0])
          if typeof(sf[1]) == "array" then flds = sf[1] end if
        end if
      end if
      if sqn == "" then continue end if
      lbls = _strpair_get(state.struct_global_labels, sqn)
      if lbls == "" then continue end if
      sid = _named_int_get(state.struct_ids, sqn, 0)
      state.asm = a.mov_rcx_imm32(state.asm, 16)
      state.asm = a.call(state.asm, "fn_alloc")
      state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRUCTTYPE, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, len(flds), false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 8, sid, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 12, 0, false)
      state.asm = a.mov_rip_qword_r11(state.asm, lbls)
    end for
  end if

  // Initialize first-class builtin values (OBJ_BUILTIN).
  if typeof(state.builtin_specs) == "array" and len(state.builtin_specs) > 0 then
    for bi = 0 to len(state.builtin_specs) - 1
      sp = state.builtin_specs[bi]
      if typeof(sp) != "array" or len(sp) < 4 then continue end if
      bname = _coerce_name(sp[0])
      bmin = sp[1]
      bmax = sp[2]
      blbl = _coerce_name(sp[3])
      if bname == "" or blbl == "" then continue end if
      gbl = _strpair_get(state.builtin_global_labels, bname)
      if gbl == "" then continue end if
      state.used_helpers = add(state.used_helpers, blbl)
      state.asm = a.mov_rcx_imm32(state.asm, 24)
      state.asm = a.call(state.asm, "fn_alloc")
      state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_BUILTIN, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, bmin, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 8, bmax, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 12, 0, false)
      state.asm = a.lea_rax_rip(state.asm, blbl)
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "rax")
      state.asm = a.mov_rip_qword_r11(state.asm, gbl)
    end for
  end if

  // Initialize first-class extern values (OBJ_BUILTIN stubs).
  if typeof(state.extern_sigs) == "array" and len(state.extern_sigs) > 0 then
    for ei = 0 to len(state.extern_sigs) - 1
      sig = state.extern_sigs[ei]
      if typeof(sig) != "struct" then continue end if
      qn = _coerce_name(sig.qname)
      if qn == "" then qn = _coerce_name(sig.name) end if
      if qn == "" then continue end if
      gbl2 = _strpair_get(state.extern_global_labels, qn)
      stub_lbl = _strpair_get(state.extern_stub_labels, qn)
      if gbl2 == "" or stub_lbl == "" then continue end if

      arity = 0
      if typeof(sig.params) == "array" and len(sig.params) > 0 then
        for pi = 0 to len(sig.params) - 1
          pp = sig.params[pi]
          is_out = false
          if typeof(pp) == "struct" and typeof(pp.is_out) == "bool" and pp.is_out then
            is_out = true
          end if
          if is_out then continue end if
          arity = arity + 1
        end for
      end if

      state.asm = a.mov_rcx_imm32(state.asm, 24)
      state.asm = a.call(state.asm, "fn_alloc")
      state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_BUILTIN, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, arity, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 8, arity, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 12, 0, false)
      state.asm = a.lea_rax_rip(state.asm, stub_lbl)
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "rax")
      state.asm = a.mov_rip_qword_r11(state.asm, gbl2)
    end for
  end if

  // Emit top-level runtime statements
  if typeof(program) == "array" and len(program) > 0 then
    rt_prog_items = program
    rt_prog_count = len(rt_prog_items)
    for rt_prog_idx = 0 to rt_prog_count - 1
      if rt_prog_idx < 0 or rt_prog_idx >= rt_prog_count then break end if
      state = cg_emit_stmt(state, rt_prog_items[rt_prog_idx])
    end for
  end if
  state = _mem_probe(state, "top_level_done")
  gc_collect()
  state = _mem_probe(state, "post_top_level_gc")

  // Call main(args) if present (top-level only)
  main_name = ""
  if typeof(state.user_functions) == "array" and len(state.user_functions) > 0 then
    for i = 0 to len(state.user_functions) - 1
      it = state.user_functions[i]
      if typeof(it) == "array" and len(it) == 2 and it[0] == "main" then
        main_name = "main"
        break
      end if
    end for
  end if

  if main_name != "" then
    state.asm = a.call(state.asm, "fn_build_args")
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.mov_r64_imm64(state.asm, "r10", t.enc_void())
    state.asm = a.call(state.asm, "fn_user_" + main_name)

    // Unhandled error from main(args): print + exit(1)
    lid_main_err = state.label_id
    state.label_id = state.label_id + 1
    l_main_noerr = "main_noerr_" + lid_main_err
    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.and_r64_imm(state.asm, "r11", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r11", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_main_noerr)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRUCT)
    state.asm = a.jcc(state.asm, "ne", l_main_noerr)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 8)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.ERROR_STRUCT_ID)
    state.asm = a.jcc(state.asm, "ne", l_main_noerr)
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, "fn_unhandled_error_exit")
    state.asm = a.mark(state.asm, l_main_noerr)

    lidm = state.label_id
    state.label_id = state.label_id + 1
    l_int = "main_ret_int_" + lidm
    l_void = "main_ret_void_" + lidm

    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
    state.asm = a.jcc(state.asm, "e", l_int)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_VOID)
    state.asm = a.jcc(state.asm, "e", l_void)

    state.asm = a.mov_rcx_imm32(state.asm, 1)
    state.asm = a.mov_rax_rip_qword(state.asm, "iat_ExitProcess")
    state.asm = a.call_rax(state.asm)

    state.asm = a.mark(state.asm, l_void)
    state.asm = a.xor_ecx_ecx(state.asm)
    state.asm = a.mov_rax_rip_qword(state.asm, "iat_ExitProcess")
    state.asm = a.call_rax(state.asm)

    state.asm = a.mark(state.asm, l_int)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.mov_rax_rip_qword(state.asm, "iat_ExitProcess")
    state.asm = a.call_rax(state.asm)
  end if

  // Default process exit (no main)
  state.asm = a.xor_ecx_ecx(state.asm)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_ExitProcess")
  state.asm = a.call_rax(state.asm)

  // Emit all user function bodies (dynamic queue so nested functions discovered
  // during emission are emitted in the same pass).
  uf_i = 0
  state = _mem_probe(state, "user_fn_emit_start")
  while typeof(state.user_functions) == "array" and uf_i < len(state.user_functions)
    if uf_i < 0 or uf_i >= len(state.user_functions) then break end if
    if _heap_cfg_get_bool(state, "cg_mem_probe", false) and (uf_i % 100) == 0 then
      asmsz = 0
      if typeof(state.asm) == "struct" and typeof(state.asm.size) == "int" then asmsz = state.asm.size end if
      dlen = 0
      if typeof(state.diagnostics) == "array" then dlen = len(state.diagnostics) end if
      sn = 0
      if typeof(state.scope_stack) == "array" then sn = len(state.scope_stack) end if
      sdn = 0
      if typeof(state.scope_declared) == "array" then sdn = len(state.scope_declared) end if
      gn = 0
      if typeof(state.globals) == "array" then gn = len(state.globals) end if
      rused = 0
      rcap = 0
      if typeof(state.rdata) == "struct" then
        if typeof(state.rdata.used) == "int" then rused = state.rdata.used end if
        if typeof(state.rdata.data) == "bytes" then rcap = len(state.rdata.data) end if
      end if
      dused = 0
      dcap = 0
      if typeof(state.data) == "struct" then
        if typeof(state.data.used) == "int" then dused = state.data.used end if
        if typeof(state.data.data) == "bytes" then dcap = len(state.data.data) end if
      end if
      fln = 0
      if typeof(state.function_locals) == "array" then fln = len(state.function_locals) end if
      lbln = 0
      pcn = 0
      ccn = 0
      if typeof(state.asm) == "struct" then
        if typeof(state.asm.labels) == "array" then lbln = len(state.asm.labels) end if
        if lbln <= 0 then lbln = _chunked_len(state.asm.labels_chunks, state.asm.labels_tail) end if
        pcn = _chunked_len(state.asm.patches_chunks, state.asm.patches_tail)
        ccn = _chunked_len(state.asm.calls_chunks, state.asm.calls_tail)
      end if
      print "[mem][cg] user_fn_idx=" + uf_i + " total=" + len(state.user_functions) + " asm_size=" + asmsz + " labels=" + lbln + " patches=" + pcn + " calls=" + ccn + " diags=" + dlen + " scopes=" + sn + "/" + sdn + " globals=" + gn + " fn_locals=" + fln + " rdata=" + rused + "/" + rcap + " data=" + dused + "/" + dcap + " used=" + heap_bytes_used() + " committed=" + heap_bytes_committed() + " reserved=" + heap_bytes_reserved()
    end if
    it2 = state.user_functions[uf_i]
    if typeof(it2) == "array" and len(it2) == 2 and typeof(it2[1]) == "struct" then
      state = emit_user_function(state, it2[1])
    end if
    uf_i = uf_i + 1
    if (uf_i % 8) == 0 then
      gc_collect()
    end if
  end while
  state = _mem_probe(state, "user_fn_emit_done")

  // Emit extern stub bodies (extern callable values).
  state = exprmod.emit_extern_stubs(state)

  // Emit runtime/builtin helper bodies
  state = core.emit_used_helpers(state)
  return state
end function

function emit_user_function(state, fn_node)
  if typeof(fn_node) != "struct" then return state end if
  qn = _coerce_name(fn_node.name)
  if qn == "" then return state end if

  fn_lbl = "fn_user_" + qn
  ret_lbl = "fn_ret_" + qn
  frame = 0x600
  root_rec_off = frame - 0x20
  root_base = 0x40
  root_top = root_rec_off
  dbg_save_base = frame - 0x50
  env_root_off = frame - 0x58
  dbg_save_script = dbg_save_base + 0
  dbg_save_func = dbg_save_base + 8
  dbg_save_line = dbg_save_base + 16

  old_in = state.in_function
  old_pref = state.current_qname_prefix
  old_file_pref = state.current_file_prefix
  old_var_slots = state.var_slots
  old_ret = state.func_ret_label
  old_frame = state.func_frame_size
  old_expr_base = state.expr_temp_base
  old_expr_top = state.expr_temp_top
  old_boxed_names = state.current_fn_boxed_names
  old_env_index = state.current_fn_env_index
  old_env_root = state.current_env_root_off
  old_func_globals = state.func_globals
  old_func_global_map = state.func_global_map

  boxed_names = fn_node._ml_boxed
  if typeof(boxed_names) != "array" then boxed_names = [] end if
  env_slots = fn_node._ml_env_slots
  if typeof(env_slots) != "array" then env_slots = [] end if
  env_index = fn_node._ml_env_index
  if typeof(env_index) != "array" then env_index = [] end if
  caps_list = fn_node._ml_captures
  if typeof(caps_list) != "array" then caps_list = [] end if
  env_hop_flag = false
  if typeof(fn_node._ml_env_hop) == "bool" and fn_node._ml_env_hop then env_hop_flag = true end if
  need_env = false
  if len(caps_list) > 0 then need_env = true end if
  if env_hop_flag then need_env = true end if
  if len(env_slots) > 0 then need_env = true end if
  state.in_function = true
  state.func_ret_label = ret_lbl
  state.func_frame_size = frame
  state.var_slots = 0
  // Isolate expression-temp arena per function; do not leak allocator state across functions.
  state.expr_temp_base = 0
  state.expr_temp_top = 0
  state.current_fn_boxed_names = boxed_names
  state.current_fn_env_index = env_index
  state.current_env_root_off = env_root_off
  state.func_globals = []
  state.func_global_map = []
  state = scope.cg_scope_enter(state)

  state.asm = a.mark(state.asm, fn_lbl)
  state.asm = a.push_rbx(state.asm)
  state.asm = a.push_r12(state.asm)
  state.asm = a.push_r13(state.asm)
  state.asm = a.push_r14(state.asm)
  state.asm = a.push_r15(state.asm)
  state.asm = a.sub_rsp_imm32(state.asm, frame)
  state = mem.emit_gc_clear_root_slots(state, root_base, root_top)
  state = mem.emit_gc_push_root_frame(state, root_rec_off, root_base, root_top)
  // Incoming closure environment is passed in r10.
  state.asm = a.mov_r64_r64(state.asm, "r14", "r10")
  // Keep incoming env in a rooted stack slot so helper calls cannot lose it.
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.mov_rsp_disp32_rax(state.asm, env_root_off)

  if state.call_profile then
    cp_idx = _named_int_get(state.callprof_index, qn, -1)
    if cp_idx >= 0 then
      state.asm = a.lea_r11_rip(state.asm, "callprof_counts")
      state.asm = a.inc_membase_disp_qword(state.asm, "r11", cp_idx * 8)
    end if
  end if

  // Save caller debug-location context and set current function context.
  state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_script")
  state.asm = a.mov_rsp_disp32_rax(state.asm, dbg_save_script)
  state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_func")
  state.asm = a.mov_rsp_disp32_rax(state.asm, dbg_save_func)
  state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_line")
  state.asm = a.mov_rsp_disp32_rax(state.asm, dbg_save_line)

  dbg_file = _st_file(fn_node)
  dbg_script = ""
  if typeof(dbg_file) == "string" and dbg_file != "" then
    dbg_script = core._pretty_script(dbg_file)
  end if
  if typeof(dbg_script) != "string" or dbg_script == "" then
    if typeof(state.filename) == "string" and state.filename != "" then
      dbg_script = state.filename
    else
      dbg_script = "<script>"
    end if
  end if
  dbg_func = qn
  if typeof(dbg_func) != "string" or dbg_func == "" then dbg_func = "<function>" end if

  dbg_lid = state.label_id
  state.label_id = state.label_id + 1
  lbl_sc = "dbg_sc_" + dbg_lid
  lbl_fn = "dbg_fn_" + dbg_lid

  state.rdata = d.rdata_add_obj_string(state.rdata, lbl_sc, dbg_script)
  state.asm = a.lea_rax_rip(state.asm, lbl_sc)
  state.asm = a.mov_rip_qword_rax(state.asm, "dbg_loc_script")

  state.rdata = d.rdata_add_obj_string(state.rdata, lbl_fn, dbg_func)
  state.asm = a.lea_rax_rip(state.asm, lbl_fn)
  state.asm = a.mov_rip_qword_rax(state.asm, "dbg_loc_func")

  // Declare capture bindings in function scope before body emission.
  state = _closure_declare_capture_bindings(state, fn_node)

  // Spill incoming params to stack slots and bind them.
  if typeof(fn_node.params) == "array" and len(fn_node.params) > 0 then
    for i = 0 to len(fn_node.params) - 1
      pn = _coerce_name(fn_node.params[i])
      poff = 0x40 + i * 8
      if i == 0 then
        state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
      else
        if i == 1 then
          state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")
        else
          if i == 2 then
            state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
          else
            if i == 3 then
              state.asm = a.mov_r64_r64(state.asm, "rax", "r9")
            else
              state.asm = a.mov_rax_rsp_disp32(state.asm, frame + 0x50 + (i - 4) * 8)
            end if
          end if
        end if
      end if
      state.asm = a.mov_rsp_disp32_rax(state.asm, poff)
      state = scope.bind_param(state, pn, poff, fn_node)
      if _arr_has(boxed_names, pn) then
        // Mark parameter binding as boxed.
        ssb = state.scope_stack
        if typeof(ssb) == "array" and len(ssb) > 0 then
          sib = len(ssb) - 1
          frb = ssb[sib]
          if typeof(frb) == "array" and len(frb) > 0 then
            jb = len(frb) - 1
            while jb >= 0
              bb = frb[jb]
              if typeof(bb) == "struct" and bb.name == pn and bb.kind == "param" then
                bb.boxed = true
                frb[jb] = bb
                ssb[sib] = frb
                state.scope_stack = ssb
                break
              end if
              jb = jb - 1
            end while
          end if
        end if

        // Box parameter value now so captured reads/writes go through shared cell.
        state.asm = a.mov_r64_membase_disp(state.asm, "r12", "rsp", poff)
        state.asm = a.mov_rcx_imm32(state.asm, 16)
        state.asm = a.call(state.asm, "fn_alloc")
        state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
        state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_BOX, false)
        state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, 0, false)
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8, "r12")
        state.asm = a.mov_membase_disp_r64(state.asm, "rsp", poff, "r11")
      end if
    end for
  end if

  // Materialize current environment frame (owner env) when needed.
  if need_env then
    env_n = len(env_slots)
    state.asm = a.mov_rcx_imm32(state.asm, 16 + env_n * 8)
    state.asm = a.call(state.asm, "fn_alloc")
    state.asm = a.mov_r64_r64(state.asm, "r15", "rax")
    state.asm = a.mov_membase_disp_imm32(state.asm, "r15", 0, c.OBJ_ENV, false)
    state.asm = a.mov_membase_disp_imm32(state.asm, "r15", 4, env_n, false)
    state.asm = a.mov_membase_disp_r64(state.asm, "r15", 8, "r14")
    if env_n > 0 then
      for esi = 0 to env_n - 1
        state.asm = a.mov_membase_disp_imm32(state.asm, "r15", 16 + esi * 8, t.enc_void(), true)
      end for
    end if

    // Seed env slots from already-boxed parameters.
    if typeof(fn_node.params) == "array" and len(fn_node.params) > 0 then
      for epi = 0 to len(fn_node.params) - 1
        epn = _coerce_name(fn_node.params[epi])
        eidx = _map_int_get(env_index, epn, -1)
        if eidx < 0 then continue end if
        eoff = 0x40 + epi * 8
        state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", eoff)
        state.asm = a.mov_membase_disp_r64(state.asm, "r15", 16 + eidx * 8, "r10")
      end for
    end if

    state.asm = a.mov_r64_r64(state.asm, "rax", "r15")
    state.asm = a.mov_rsp_disp32_rax(state.asm, env_root_off)
  else
    state.asm = a.mov_r64_imm64(state.asm, "r15", t.enc_void())
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    state.asm = a.mov_rsp_disp32_rax(state.asm, env_root_off)
  end if

  if s.contains(qn, ".") then
    parts = s.split(qn, ".")
    if len(parts) > 1 then
      qpref = ""
      for pi = 0 to len(parts) - 2
        segp = _coerce_name(parts[pi])
        if segp == "" then continue end if
        if qpref != "" then qpref = qpref + "." end if
        qpref = qpref + segp
      end for
      if qpref != "" then
        state.current_qname_prefix = qpref + "."
      else
        state.current_qname_prefix = ""
      end if
    else
      state.current_qname_prefix = ""
    end if
  else
    state.current_qname_prefix = ""
  end if

  fn_file = _st_file(fn_node)
  if typeof(fn_file) == "string" and fn_file != "" then
    state.current_file_prefix = _strpair_get(state.file_prefix_map, fn_file)
  else
    state.current_file_prefix = ""
  end if

  if typeof(fn_node.body) == "array" and len(fn_node.body) > 0 then
    uf_body_items = fn_node.body
    uf_body_count = len(uf_body_items)
    for uf_body_idx = 0 to uf_body_count - 1
      if uf_body_idx < 0 or uf_body_idx >= uf_body_count then break end if
      state = cg_emit_stmt(state, uf_body_items[uf_body_idx])
    end for
  end if

  // implicit return void
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.jmp(state.asm, ret_lbl)

  state.asm = a.mark(state.asm, ret_lbl)
  state = mem.emit_gc_pop_root_frame(state, root_rec_off)
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", dbg_save_script)
  state.asm = a.mov_rip_qword_r11(state.asm, "dbg_loc_script")
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", dbg_save_func)
  state.asm = a.mov_rip_qword_r11(state.asm, "dbg_loc_func")
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", dbg_save_line)
  state.asm = a.mov_rip_qword_r11(state.asm, "dbg_loc_line")
  state.asm = a.add_rsp_imm32(state.asm, frame)
  state.asm = a.pop_r15(state.asm)
  state.asm = a.pop_r14(state.asm)
  state.asm = a.pop_r13(state.asm)
  state.asm = a.pop_r12(state.asm)
  state.asm = a.pop_rbx(state.asm)
  state.asm = a.ret(state.asm)

  state = scope.cg_scope_leave(state)
  state.in_function = old_in
  state.current_qname_prefix = old_pref
  state.current_file_prefix = old_file_pref
  state.var_slots = old_var_slots
  state.func_ret_label = old_ret
  state.func_frame_size = old_frame
  state.expr_temp_base = old_expr_base
  state.expr_temp_top = old_expr_top
  state.current_fn_boxed_names = old_boxed_names
  state.current_fn_env_index = old_env_index
  state.current_env_root_off = old_env_root
  state.func_globals = old_func_globals
  state.func_global_map = old_func_global_map
  if qn == "" then return state end if
  return state
end function

function add(arr, value)
  if typeof(arr) != "array" then return [value] end if
  if len(arr) <= 0 then return [value] end if
  for i = 0 to len(arr) - 1
    if arr[i] == value then return arr end if
  end for
  return arr +[value]
end function

function analyze_read_var(state, name)
  return state
end function

function analyze_write_var(state, name)
  nm = _coerce_name(name)
  if nm == "" then return state end if
  qn = _join_qname(state.current_qname_prefix, nm)
  b = scope.cg_resolve_binding_for_write(state, qn)
  if typeof(b) == "struct" then return state end if
  return scope.cg_declare_binding(state, qn, "local", false, 0, 0, 0)
end function

function analyze_expr(state, ex)
  if typeof(ex) != "struct" then return state end if
  if ex.node_kind == "Var" and typeof(ex.name) == "string" then
    state = analyze_read_var(state, ex.name)
  end if
  if ex.node_kind == "Member" and typeof(ex.target) == "struct" then
    state = analyze_expr(state, ex.target)
  end if
  if ex.node_kind == "Unary" then
    state = analyze_expr(state, ex.right)
  end if
  if ex.node_kind == "Bin" then
    state = analyze_expr(state, ex.left)
    state = analyze_expr(state, ex.right)
  end if
  if ex.node_kind == "Call" then
    state = analyze_expr(state, ex.func)
    if typeof(ex.args) == "array" and len(ex.args) > 0 then
      for i = 0 to len(ex.args) - 1
        state = analyze_expr(state, ex.args[i])
      end for
    end if
  end if
  return state
end function

function analyze_block(state, stmts)
  if typeof(stmts) != "array" or len(stmts) <= 0 then return state end if
  for i = 0 to len(stmts) - 1
    st = stmts[i]
    if typeof(st) == "struct" and typeof(st.expr) == "struct" then
      state = analyze_expr(state, st.expr)
    end if
    state = cg_emit_stmt(state, st)
  end for
  return state
end function

function expr(state, ex)
  return analyze_expr(state, ex)
end function

function expr_reads(ex)
  return _collect_constexpr_refs(ex,[])
end function

function note_reads(state, names)
  return state
end function

function max_calls_expr(ex)
  if typeof(ex) != "struct" then return 0 end if
  c = 0
  if ex.node_kind == "Call" then c = 1 end if
  if typeof(ex.func) == "struct" then c = c + max_calls_expr(ex.func) end if
  if typeof(ex.left) == "struct" then c = c + max_calls_expr(ex.left) end if
  if typeof(ex.right) == "struct" then c = c + max_calls_expr(ex.right) end if
  if typeof(ex.target) == "struct" then c = c + max_calls_expr(ex.target) end if
  if typeof(ex.args) == "array" and len(ex.args) > 0 then
    for i = 0 to len(ex.args) - 1
      c = c + max_calls_expr(ex.args[i])
    end for
  end if
  return c
end function

function max_calls_stmts(stmts)
  if typeof(stmts) != "array" or len(stmts) <= 0 then return 0 end if
  c = 0
  for i = 0 to len(stmts) - 1
    st = stmts[i]
    if typeof(st) != "struct" then continue end if
    if typeof(st.expr) == "struct" then c = c + max_calls_expr(st.expr) end if
    if typeof(st.cond) == "struct" then c = c + max_calls_expr(st.cond) end if
    if typeof(st.body) == "array" then c = c + max_calls_stmts(st.body) end if
    if typeof(st.then_body) == "array" then c = c + max_calls_stmts(st.then_body) end if
    if typeof(st.else_body) == "array" then c = c + max_calls_stmts(st.else_body) end if
  end for
  return c
end function

function stmt_list(state, stmts)
  return _emit_stmt_list(state, stmts)
end function
