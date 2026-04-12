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

function inline _join_qname(prefix, name)
  if typeof(prefix) != "string" or prefix == "" then return name end if
  if prefix[len(prefix) - 1] == "." then
    return prefix + name
  end if
  return prefix + "." + name
end function

function inline _coerce_name(v)
  if typeof(v) == "string" then return v end if
  if typeof(v) == "struct" then
    if typeof(v.name) == "string" then return v.name end if
    if typeof(v.value) == "string" then return v.value end if
  end if
  return "" + v
end function

function inline _fn_codegen_key(fn_node)
  if typeof(fn_node) != "struct" then return "" end if
  pos = 0
  if typeof(fn_node._pos) == "int" then pos = fn_node._pos end if
  file = _coerce_name(fn_node._filename)
  name = _coerce_name(fn_node.name)
  return file + "|" + pos + "|" + name
end function

function inline _fn_codegen_name(state, fn_node)
  if typeof(fn_node) != "struct" then return "" end if
  key = _fn_codegen_key(fn_node)
  if key != "" and typeof(state.function_codegen_name_map) == "struct" then
    hit = t.fastmap_get(state.function_codegen_name_map, key, "")
    if typeof(hit) == "string" and hit != "" then return hit end if
  end if
  return _coerce_name(fn_node.name)
end function

function _set_fn_codegen_name(state, fn_node, code_name)
  if typeof(fn_node) != "struct" then return state end if
  if typeof(code_name) != "string" or code_name == "" then return state end if
  key = _fn_codegen_key(fn_node)
  if key == "" then return state end if
  if typeof(state.function_codegen_name_map) != "struct" then
    state.function_codegen_name_map = t.fastmap_new(256)
  end if
  state.function_codegen_name_map = t.fastmap_set(state.function_codegen_name_map, key, code_name)
  return state
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

function inline _heap_cfg_get_int(state, key, defaultv)
  v = _heap_cfg_get_any(state, key)
  if typeof(v) == "int" then return v end if
  return defaultv
end function

function inline _heap_cfg_get_bool(state, key, defaultv)
  v = _heap_cfg_get_any(state, key)
  if typeof(v) == "bool" then return v end if
  return defaultv
end function

function _set_user_function(state, qname, fn_node)
  arr = state.user_functions
  if typeof(arr) != "array" then arr =[] end if
  idx_map = state.user_function_index
  if typeof(idx_map) != "struct" then idx_map = t.fastmap_new(256) end if
  idx = t.fastmap_get(idx_map, qname, -1)
  if typeof(idx) == "int" and idx >= 0 and idx < len(arr) then
    arr[idx] =[qname, fn_node]
    state.user_functions = arr
    state.user_function_index = idx_map
    return state
  end if
  if len(arr) > 0 then
    for i = 0 to len(arr) - 1
      p = arr[i]
      if typeof(p) == "array" and len(p) == 2 and p[0] == qname then
        arr[i] =[qname, fn_node]
        idx_map = t.fastmap_set(idx_map, qname, i)
        state.user_functions = arr
        state.user_function_index = idx_map
        return state
      end if
    end for
  end if
  app = t.arr_chunked_push([], [], [qname, fn_node], 1)
  tail = t.arr_chunked_finish(app[0], app[1])
  if typeof(tail) == "array" and len(tail) == 1 then
    arr = arr + tail
  else
    arr = arr + [[qname, fn_node]]
  end if
  idx_map = t.fastmap_set(idx_map, qname, len(arr) - 1)
  state.user_function_index = idx_map
  state.user_functions = arr
  return state
end function

function _user_function_get_node(state, qname)
  arr = state.user_functions
  if typeof(arr) != "array" or len(arr) <= 0 then return 0 end if
  if typeof(state.user_function_index) == "struct" then
    idx = t.fastmap_get(state.user_function_index, qname, -1)
    if typeof(idx) == "int" and idx >= 0 and idx < len(arr) then
      it = arr[idx]
      if typeof(it) == "array" and len(it) == 2 and typeof(it[1]) == "struct" then return it[1] end if
    end if
  end if
  for i = 0 to len(arr) - 1
    it2 = arr[i]
    if typeof(it2) == "array" and len(it2) == 2 and it2[0] == qname and typeof(it2[1]) == "struct" then
      return it2[1]
    end if
  end for
  return 0
end function

function _user_function_keys_sorted(state)
  keys = []
  arr = state.user_functions
  if typeof(arr) != "array" or len(arr) <= 0 then return keys end if
  for i = 0 to len(arr) - 1
    it = arr[i]
    if typeof(it) == "array" and len(it) == 2 and typeof(it[0]) == "string" and it[0] != "" then
      keys = keys + [it[0]]
    end if
  end for
  return _sort_names(keys)
end function

function _nested_function_get_by_codegen_name(state, code_name)
  arr = state.nested_user_functions
  if typeof(arr) != "array" or len(arr) <= 0 then return 0 end if
  for i = 0 to len(arr) - 1
    nf = arr[i]
    if typeof(nf) != "struct" then continue end if
    if _fn_codegen_name(state, nf) == code_name then return nf end if
  end for
  return 0
end function

function _nested_function_codegen_names_sorted(state)
  keys = []
  arr = state.nested_user_functions
  if typeof(arr) != "array" or len(arr) <= 0 then return keys end if
  for i = 0 to len(arr) - 1
    nf = arr[i]
    if typeof(nf) != "struct" then continue end if
    code_name = _fn_codegen_name(state, nf)
    if code_name != "" then keys = keys + [code_name] end if
  end for
  return _sort_names(keys)
end function

function _prepare_qualify_cache(cache, min_cap)
  need = min_cap
  if typeof(need) != "int" or need <= 0 then need = 256 end if
  if typeof(cache) == "struct" and typeof(cache.cap) == "int" then
    cap = cache.cap
    keep_cap = need << 3
    if typeof(keep_cap) != "int" or keep_cap < need then keep_cap = need end if
    if cap >= need and cap <= keep_cap then
      return t.fastmap_clear(cache)
    end if
    if cap > keep_cap then
      return t.fastmap_new(need << 1)
    end if
  end if
  return t.fastmap_new(need)
end function

function _release_emitted_fn_node(fn_node)
  if typeof(fn_node) != "struct" then return fn_node end if
  fn_node.body = []
  fn_node.params = []
  fn_node._ml_boxed = []
  fn_node._ml_env_slots = []
  fn_node._ml_env_index = []
  fn_node._ml_captures = []
  fn_node._ml_capture_depth = []
  fn_node._ml_capture_index = []
  fn_node._ml_nested_functions = []
  return fn_node
end function

function _forget_nested_function_by_codegen_name(state, code_name)
  arr = state.nested_user_functions
  if typeof(arr) != "array" or len(arr) <= 0 then return state end if
  for i = 0 to len(arr) - 1
    nf = arr[i]
    if typeof(nf) != "struct" then continue end if
    if _fn_codegen_name(state, nf) == code_name then
      arr[i] = 0
      state.nested_user_functions = arr
      return state
    end if
  end for
  return state
end function

function _maybe_phase_gc(state, tag, min_bytes)
  need = min_bytes
  if typeof(need) != "int" or need <= 0 then need = 256 << 20 end if
  used = heap_bytes_used()
  if typeof(used) == "int" and used >= need then
    gc_collect()
    return _mem_probe(state, tag)
  end if
  return state
end function

function inline _foreach_body(st)
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
    st = emit_items[emit_idx]
    state = cg_emit_stmt(state, st)
    emit_idx = emit_idx + 1
    if typeof(st) == "struct" then
      if st.node_kind == "Return" or st.node_kind == "Break" or st.node_kind == "Continue" then
        break
      end if
    end if
  end while
  return state
end function

function _rdata_label_offset(rb, name)
  if typeof(rb) != "struct" then return -1 end if
  if typeof(rb.labels) != "array" or len(rb.labels) <= 0 then return -1 end if
  for i = 0 to len(rb.labels) - 1
    it = rb.labels[i]
    if typeof(it) == "struct" and it.name == name then
      if typeof(it.offset) == "int" then return it.offset end if
      return -1
    end if
  end for
  return -1
end function

function _for_unroll_body_ok(stmts, loop_var)
  if typeof(stmts) != "array" then return false end if
  if len(stmts) > 12 then return false end if
  n = len(stmts)
  i = 0
  while i < n
    if i < 0 or i >= len(stmts) then break end if
    st = try(stmts[i])
    i = i + 1
    if typeof(st) != "struct" then return false end if
    nk = st.node_kind
    if nk == "Break" or nk == "Continue" or nk == "FunctionDef" or nk == "Switch" or nk == "While" or nk == "DoWhile" or nk == "For" or _is_foreach_stmt(st) then
      return false
    end if
    if nk == "Assign" then
      if _coerce_name(st.name) == loop_var then return false end if
    end if
    if nk == "If" then
      if typeof(st.then_body) == "array" and _for_unroll_body_ok(st.then_body, loop_var) == false then return false end if
      if typeof(st.elifs) == "array" and len(st.elifs) > 0 then
        for j = 0 to len(st.elifs) - 1
          eb = st.elifs[j]
          if typeof(eb) == "array" and len(eb) >= 2 then
            eb_body = try(eb[1])
            if typeof(eb_body) == "array" and _for_unroll_body_ok(eb_body, loop_var) == false then return false end if
          end if
        end for
      end if
      if typeof(st.else_body) == "array" and _for_unroll_body_ok(st.else_body, loop_var) == false then return false end if
    end if
  end while
  return true
end function

function _for_unroll_values(state, s)
  start_ex = s.start
  end_ex = s.end_expr

  start_v = _opt_try_const_int(state, start_ex)
  if typeof(start_v) != "int" then return void end if
  end_v = _opt_try_const_int(state, end_ex)
  if typeof(end_v) != "int" then return void end if

  trips = end_v - start_v
  if trips < 0 then trips = -trips end if
  trips = trips + 1
  if trips <= 0 or trips > 6 then return void end if

  loop_var = _coerce_name(s.var)
  if loop_var == "" then return void end if
  if _for_unroll_body_ok(s.body, loop_var) == false then return void end if

  vals = []
  if start_v <= end_v then
    iv = start_v
    while iv <= end_v
      vals = vals + [iv]
      iv = iv + 1
    end while
  else
    iv2 = start_v
    while iv2 >= end_v
      vals = vals + [iv2]
      iv2 = iv2 - 1
    end while
  end if
  return vals
end function

function _emit_condition_nonvoid_guard(state, cond_expr, ok_label, false_label)
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_VOID)
  state.asm = a.jcc(state.asm, "ne", ok_label)
  state = exprmod._emit_make_error_const(state, c.ERR_VOID_OP, "Cannot use void as condition")
  state = exprmod._emit_auto_errprop(state)
  // If not propagated (e.g. top-level), continue control flow as false.
  state.asm = a.jmp(state.asm, false_label)
  state.asm = a.mark(state.asm, ok_label)
  return state
end function

function inline _breakctx_make(kind, break_label, continue_label, break_depth, continue_depth)
  return [kind, break_label, continue_label, break_depth, continue_depth]
end function

function inline _breakctx_kind(ctx)
  if typeof(ctx) == "array" and len(ctx) >= 1 and typeof(ctx[0]) == "string" then return ctx[0] end if
  return "loop"
end function

function inline _breakctx_break_label(ctx)
  if typeof(ctx) == "array" then
    if len(ctx) >= 2 and typeof(ctx[0]) == "string" and typeof(ctx[1]) == "string" then return ctx[1] end if
    if len(ctx) >= 1 and typeof(ctx[0]) == "string" then return ctx[0] end if
  end if
  return ""
end function

function inline _breakctx_continue_label(ctx)
  if typeof(ctx) == "array" then
    if len(ctx) >= 3 and typeof(ctx[0]) == "string" and typeof(ctx[2]) == "string" then return ctx[2] end if
    if len(ctx) >= 2 and typeof(ctx[1]) == "string" then return ctx[1] end if
  end if
  return ""
end function

function inline _breakctx_break_depth(ctx, fallback)
  if typeof(ctx) == "array" and len(ctx) >= 4 and typeof(ctx[3]) == "int" then return ctx[3] end if
  return fallback
end function

function inline _breakctx_continue_depth(ctx, fallback)
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

  dense_pairs = []
  dense_keys = []
  dense_switch = false
  total_keys = 0
  if len(cases) > 0 then
    dense_ok = true
    for i = 0 to len(cases) - 1
      cs = cases[i]
      if typeof(cs) != "struct" or typeof(cs.kind) != "string" or cs.kind != "values" then
        dense_ok = false
        break
      end if
      vals = []
      if typeof(cs.values) == "array" then vals = cs.values end if
      for j = 0 to len(vals) - 1
        vv = _opt_try_const_int(state, vals[j])
        if typeof(vv) != "int" then
          dense_ok = false
          break
        end if
        if _arr_has(dense_keys, vv) then
          dense_ok = false
          break
        end if
        dense_pairs = dense_pairs + [[vv, body_labels[i]]]
        dense_keys = dense_keys + [vv]
        total_keys = total_keys + 1
      end for
      if dense_ok == false then break end if
    end for
    if dense_ok and total_keys >= 4 then
      min_v = dense_pairs[0][0]
      max_v = dense_pairs[0][0]
      for di = 0 to len(dense_pairs) - 1
        kv = dense_pairs[di][0]
        if kv < min_v then min_v = kv end if
        if kv > max_v then max_v = kv end if
      end for
      span = max_v - min_v + 1
      if min_v >= -2147483648 and min_v <= 2147483647 and span > 0 and span <= 4096 and span <= total_keys * 2 then
        dense_switch = true
        miss_lbl = l_end
        if typeof(stmt.default_body) == "array" and len(stmt.default_body) > 0 then miss_lbl = l_default end if
        tbl_lbl = "switch_jtbl_" + sid
        state.rdata = d.rdata_pad_align(state.rdata, 8)
        state.rdata = d.rdata_add_bytes_unique(state.rdata, tbl_lbl, bytes(8 * span, 0))
        tbl_off = _rdata_label_offset(state.rdata, tbl_lbl)
        if tbl_off >= 0 then
          for ti = 0 to span - 1
            key = min_v + ti
            tgt_lbl = miss_lbl
            for pj = 0 to len(dense_pairs) - 1
              if dense_pairs[pj][0] == key then
                tgt_lbl = dense_pairs[pj][1]
                break
              end if
            end for
            state.rdata = d.rdata_add_abs64_patch(state.rdata, tbl_off + ti * 8, tgt_lbl)
          end for

          state.asm = a.mov_r64_r64(state.asm, "r10", "r12")
          state.asm = a.and_r64_imm(state.asm, "r10", 7)
          state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
          state.asm = a.jcc(state.asm, "ne", miss_lbl)
          state.asm = a.mov_r64_r64(state.asm, "rcx", "r12")
          state.asm = a.sar_r64_imm8(state.asm, "rcx", 3)
          if min_v > 0 then
            state.asm = a.sub_r64_imm(state.asm, "rcx", min_v)
          else
            if min_v < 0 then
              state.asm = a.add_r64_imm(state.asm, "rcx", -min_v)
            end if
          end if
          state.asm = a.cmp_r64_imm(state.asm, "rcx", span - 1)
          state.asm = a.jcc(state.asm, "a", miss_lbl)
          state.asm = a.lea_rax_rip(state.asm, tbl_lbl)
          state.asm = a.mov_r64_mem_bis(state.asm, "rax", "rax", "rcx", 8, 0)
          state.asm = a.jmp_r64(state.asm, "rax")
        else
          dense_switch = false
        end if
      end if
    end if
  end if

  if dense_switch == false and len(cases) > 0 then
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
      state = scope.cg_scope_leave(state, true)
      state.asm = a.jmp(state.asm, l_end)
    end for
  end if

  state.asm = a.mark(state.asm, l_default)
  state = scope.cg_scope_enter(state)
  if typeof(stmt.default_body) == "array" and len(stmt.default_body) > 0 then
    state = _emit_stmt_list(state, stmt.default_body)
  end if
  state = scope.cg_scope_leave(state, true)

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
    state = scope.cg_scope_leave(state, true)
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

    code_name = _fn_codegen_name(state, stmt)
    if code_name == "" then
      nested_id = state.label_id
      state.label_id = state.label_id + 1
      code_name = qn_fn + ".__n" + nested_id
      state = _set_fn_codegen_name(state, stmt, code_name)
    end if

    ar = 0
    if typeof(stmt.params) == "array" then ar = len(stmt.params) end if
    need_parent = false
    if typeof(stmt._ml_captures) == "array" and len(stmt._ml_captures) > 0 then need_parent = true end if
    if typeof(stmt._ml_env_hop) == "bool" and stmt._ml_env_hop then need_parent = true end if
    obj_size = 16
    obj_type = c.OBJ_FUNCTION
    if need_parent then
      obj_size = 24
      obj_type = c.OBJ_CLOSURE
    end if
    state.asm = a.mov_rcx_imm32(state.asm, obj_size)
    state.asm = a.call(state.asm, "fn_alloc")
    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, obj_type, false)
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, ar, false)
    state.asm = a.lea_rdx_rip(state.asm, "fn_user_" + code_name)
    state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8, "rdx")
    if need_parent then
      env_root = state.current_env_root_off
      if typeof(env_root) == "int" and env_root > 0 then
        state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", env_root)
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "r10")
      else
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "r15")
      end if
    end if
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state = scope.emit_store_var_scoped(state, local_name, stmt)
    return state
  end if

  if k == "Switch" then
    return _emit_switch_stmt(state, stmt)
  end if

  if k == "If" then
    cases = [[stmt.cond, stmt.then_body]]
    if typeof(stmt.elifs) == "array" and len(stmt.elifs) > 0 then
      for if_ei0 = 0 to len(stmt.elifs) - 1
        eb0 = stmt.elifs[if_ei0]
        if typeof(eb0) == "array" and len(eb0) >= 2 then
          cases = cases + [eb0]
        end if
      end for
    end if

    else_body = []
    if typeof(stmt.else_body) == "array" then
      else_body = stmt.else_body
    end if

    start_idx = 0
    if len(cases) > 0 then
      for if_ci = 0 to len(cases) - 1
        cs0 = cases[if_ci]
        if typeof(cs0) != "array" or len(cs0) < 2 then
          break
        end if
        tv0 = _opt_try_truthy(state, cs0[0])
        if typeof(tv0) == "bool" and tv0 == false then
          start_idx = if_ci + 1
          continue
        end if
        break
      end for
    end if

    if start_idx >= len(cases) then
      state = scope.cg_scope_enter(state)
      state = _emit_stmt_list(state, else_body)
      state = scope.cg_scope_leave(state, true)
      return state
    end if

    lid_if = state.label_id
    state.label_id = state.label_id + 1
    l_end = "if_end_" + lid_if

    for if_ci2 = start_idx to len(cases) - 1
      cs = cases[if_ci2]
      if typeof(cs) != "array" or len(cs) < 2 then
        continue
      end if

      cond = cs[0]
      body = cs[1]
      tv = _opt_try_truthy(state, cond)
      if typeof(tv) == "bool" and tv == false then
        continue
      end if

      if typeof(tv) == "bool" and tv == true then
        state = scope.cg_scope_enter(state)
        state = _emit_stmt_list(state, body)
        state = scope.cg_scope_leave(state, true)
        state.asm = a.jmp(state.asm, l_end)
        break
      end if

      next_lbl = "if_next_" + lid_if + "_" + (if_ci2 - start_idx)
      state = exprmod.cg_emit_expr(state, cond)
      l_cond_ok = "if_cond_ok_" + lid_if + "_" + (if_ci2 - start_idx)
      state = _emit_condition_nonvoid_guard(state, cond, l_cond_ok, next_lbl)
      state = core.emit_jmp_if_false_rax(state, next_lbl)
      state = scope.cg_scope_enter(state)
      state = _emit_stmt_list(state, body)
      state = scope.cg_scope_leave(state, true)
      state.asm = a.jmp(state.asm, l_end)
      state.asm = a.mark(state.asm, next_lbl)
    end for

    state = scope.cg_scope_enter(state)
    state = _emit_stmt_list(state, else_body)
    state = scope.cg_scope_leave(state, true)
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
      state = scope.emit_store_var_scoped(state, qn_c, stmt)
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
    state = scope.emit_store_var_scoped(state, qn_a, stmt)
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

    state = exprmod.cg_emit_expr(state, stmt.target)
    base_off = core.alloc_expr_temps(state, 8)
    state.asm = a.mov_rsp_disp32_rax(state.asm, base_off)

    state = exprmod.cg_emit_expr(state, stmt.index)
    idx_off = core.alloc_expr_temps(state, 8)
    state.asm = a.mov_rsp_disp32_rax(state.asm, idx_off)

    state = exprmod.cg_emit_expr(state, stmt.expr)
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")

    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", base_off)
    state.asm = a.mov_rax_rsp_disp32(state.asm, idx_off)

    state = core.free_expr_temps(state, 16)

    state.asm = a.cmp_r64_imm(state.asm, "r10", t.enc_void())
    state.asm = a.jcc(state.asm, "e", l_rhs_void)

    state.asm = a.mov_r64_r64(state.asm, "r8", "r11")
    state.asm = a.and_r64_imm(state.asm, "r8", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r8", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_bad_target)
    state.asm = a.test_r64_r64(state.asm, "r11", "r11")
    state.asm = a.jcc(state.asm, "e", l_bad_target)

    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
    l_type_ok = "seti_type_ok_" + lid_si
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
    state.asm = a.jcc(state.asm, "e", l_type_ok)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY_IMM)
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
    l_ok = "seti_ok_" + lid_si
    state.asm = a.cmp_r32_imm(state.asm, "ecx", 0)
    state.asm = a.jcc(state.asm, "ge", l_ok)
    state.asm = a.add_r32_r32(state.asm, "ecx", "edx")
    state.asm = a.mark(state.asm, l_ok)
    state.asm = a.cmp_r32_imm(state.asm, "ecx", 0)
    state.asm = a.jcc(state.asm, "l", l_oob)
    state.asm = a.cmp_r32_r32(state.asm, "ecx", "edx")
    state.asm = a.jcc(state.asm, "ge", l_oob)

    l_store_bytes = "seti_store_bytes_" + lid_si
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "e", l_store_bytes)

    l_store_array = "seti_store_array_" + lid_si
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY_IMM)
    state.asm = a.jcc(state.asm, "ne", l_store_array)
    state.asm = a.mov_r64_r64(state.asm, "r8", "r10")
    state.asm = a.and_r64_imm(state.asm, "r8", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r8", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_store_array)
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_ARRAY, false)
    state.asm = a.mark(state.asm, l_store_array)
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

    state.asm = a.mov_r64_r64(state.asm, "r8", "r11")
    state.asm = a.add_r64_r64(state.asm, "r8", "rcx")
    state.asm = a.add_r64_imm(state.asm, "r8", 8)
    state.asm = a.mov_membase_disp_r8(state.asm, "r8", 0, "al")
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
    l_float = "print_float_" + lid_p
    l_void = "print_void_" + lid_p
    l_uns = "print_uns_" + lid_p
    l_end = "print_end_" + lid_p

    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_VOID)
    state.asm = a.jcc(state.asm, "e", l_void)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
    state.asm = a.jcc(state.asm, "e", l_int)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_BOOL)
    state.asm = a.jcc(state.asm, "e", l_bool)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_ENUM)
    state.asm = a.jcc(state.asm, "e", l_enum)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_FLOAT)
    state.asm = a.jcc(state.asm, "e", l_float)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "e", l_ptr)
    state.asm = a.jmp(state.asm, l_uns)

    state.asm = a.mark(state.asm, l_void)
    state = core.emit_dbg_line(state, stmt)
    state = exprmod._emit_make_error_const(state, c.ERR_PRINT_UNSUPPORTED, "Cannot print void")
    state = exprmod._emit_auto_errprop(state)
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
    l_pstr = "print_ptr_str_" + lid_p
    l_parr = "print_ptr_arr_" + lid_p
    l_pflt = "print_ptr_flt_" + lid_p
    l_pbytes = "print_ptr_bytes_" + lid_p
    l_pstt = "print_ptr_stt_" + lid_p
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
    state.asm = a.jcc(state.asm, "e", l_pstr)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
    state.asm = a.jcc(state.asm, "e", l_parr)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY_IMM)
    state.asm = a.jcc(state.asm, "e", l_parr)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FLOAT)
    state.asm = a.jcc(state.asm, "e", l_pflt)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "e", l_pbytes)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRUCTTYPE)
    state.asm = a.jcc(state.asm, "e", l_pstt)
    state.asm = a.jmp(state.asm, l_uns)

    state.asm = a.mark(state.asm, l_pstt)
    state.asm = a.lea_rax_rip(state.asm, "obj_type_struct")
    state.asm = a.jmp(state.asm, l_pstr)

    state.asm = a.mark(state.asm, l_pstr)
    state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rax", 4)
    state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "rax", 8)
    state = core.emit_writefile_ptr_len(state)
    state = core.emit_writefile(state, "nl", 1)
    state.asm = a.jmp(state.asm, l_end)

    state.asm = a.mark(state.asm, l_pflt)
    state = core.emit_to_double_xmm(state, 0, l_uns)
    state.asm = a.mov_r32_imm32(state.asm, "edx", 15)
    state.asm = a.lea_rax_rip(state.asm, "floatbuf")
    state.asm = a.mov_r64_r64(state.asm, "r8", "rax")
    state.asm = a.mov_rax_rip_qword(state.asm, "iat__gcvt")
    state.asm = a.call_rax(state.asm)
    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, "fn_strlen")
    state.asm = a.mov_r8d_edx(state.asm)
    state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
    state = core.emit_writefile_ptr_len(state)
    state = core.emit_writefile(state, "nl", 1)
    state.asm = a.jmp(state.asm, l_end)

    state.asm = a.mark(state.asm, l_float)
    state = core.emit_to_double_xmm(state, 0, l_uns)
    state.asm = a.mov_r32_imm32(state.asm, "edx", 15)
    state.asm = a.lea_rax_rip(state.asm, "floatbuf")
    state.asm = a.mov_r64_r64(state.asm, "r8", "rax")
    state.asm = a.mov_rax_rip_qword(state.asm, "iat__gcvt")
    state.asm = a.call_rax(state.asm)
    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, "fn_strlen")
    state.asm = a.mov_r8d_edx(state.asm)
    state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
    state = core.emit_writefile_ptr_len(state)
    state = core.emit_writefile(state, "nl", 1)
    state.asm = a.jmp(state.asm, l_end)

    state.asm = a.mark(state.asm, l_pbytes)
    state.asm = a.lea_rax_rip(state.asm, "obj_bytes")
    state.asm = a.jmp(state.asm, l_pstr)

    state.asm = a.mark(state.asm, l_parr)
    state.asm = a.mov_r64_r64(state.asm, "r14", "rax")
    state = core.emit_writefile(state, "lbrack", 1)
    state.asm = a.mov_r32_membase_disp(state.asm, "r13d", "r14", 4)
    state.asm = a.xor_r32_r32(state.asm, "r12d", "r12d")

    lid_arr = state.label_id
    state.label_id = state.label_id + 1
    l_top = "arrprint_top_" + lid_arr
    l_done = "arrprint_done_" + lid_arr
    l_skip_comma = "arrprint_skipcomma_" + lid_arr
    state.asm = a.mark(state.asm, l_top)
    state.asm = a.cmp_r32_r32(state.asm, "r12d", "r13d")
    state.asm = a.jcc(state.asm, "ge", l_done)
    state.asm = a.mov_r64_r64(state.asm, "r11", "r12")
    state.asm = a.mov_r64_mem_bis(state.asm, "rax", "r14", "r11", 8, 8)

    elem_id = state.label_id
    state.label_id = state.label_id + 1
    el_int = "arr_el_int_" + elem_id
    el_bool = "arr_el_bool_" + elem_id
    el_enum = "arr_el_enum_" + elem_id
    el_ptr = "arr_el_ptr_" + elem_id
    el_uns = "arr_el_uns_" + elem_id
    el_end = "arr_el_end_" + elem_id

    state.asm = a.mov_r10_rax(state.asm)
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
    state.asm = a.jcc(state.asm, "e", el_int)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_BOOL)
    state.asm = a.jcc(state.asm, "e", el_bool)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_ENUM)
    state.asm = a.jcc(state.asm, "e", el_enum)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "e", el_ptr)
    state.asm = a.jmp(state.asm, el_uns)

    state.asm = a.mark(state.asm, el_int)
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, "fn_int_to_dec")
    state.asm = a.mov_r8d_edx(state.asm)
    state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
    state = core.emit_writefile_ptr_len(state)
    state.asm = a.jmp(state.asm, el_end)

    state.asm = a.mark(state.asm, el_bool)
    state.asm = a.test_rax_imm32(state.asm, 8)
    el_false = "arr_el_false_" + elem_id
    state.asm = a.jcc(state.asm, "z", el_false)
    state = core.emit_writefile(state, "true_nn", 4)
    state.asm = a.jmp(state.asm, el_end)
    state.asm = a.mark(state.asm, el_false)
    state = core.emit_writefile(state, "false_nn", 5)
    state.asm = a.jmp(state.asm, el_end)

    state.asm = a.mark(state.asm, el_enum)
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, "fn_value_to_string")
    state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rax", 4)
    state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "rax", 8)
    state = core.emit_writefile_ptr_len(state)
    state.asm = a.jmp(state.asm, el_end)

    state.asm = a.mark(state.asm, el_ptr)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
    l_el_str = "arr_el_str_" + elem_id
    l_el_arr = "arr_el_arr_" + elem_id
    l_el_bytes = "arr_el_bytes_" + elem_id
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
    state.asm = a.jcc(state.asm, "e", l_el_str)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
    state.asm = a.jcc(state.asm, "e", l_el_arr)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY_IMM)
    state.asm = a.jcc(state.asm, "e", l_el_arr)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "e", l_el_bytes)
    state.asm = a.jmp(state.asm, el_uns)

    state.asm = a.mark(state.asm, l_el_str)
    state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rax", 4)
    state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "rax", 8)
    state = core.emit_writefile_ptr_len(state)
    state.asm = a.jmp(state.asm, el_end)

    state.asm = a.mark(state.asm, l_el_arr)
    state = core.emit_writefile(state, "array_nn", 7)
    state.asm = a.jmp(state.asm, el_end)

    state.asm = a.mark(state.asm, l_el_bytes)
    state.asm = a.lea_rax_rip(state.asm, "obj_bytes")
    state.asm = a.jmp(state.asm, l_el_str)

    state.asm = a.mark(state.asm, el_uns)
    state = core.emit_dbg_line(state, stmt)
    state = exprmod._emit_make_error_const(state, c.ERR_PRINT_UNSUPPORTED, "Cannot print unsupported array element")
    state = exprmod._emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_end)

    state.asm = a.mark(state.asm, el_end)
    state.asm = a.inc_r32(state.asm, "r12d")
    state.asm = a.cmp_r32_r32(state.asm, "r12d", "r13d")
    state.asm = a.jcc(state.asm, "e", l_skip_comma)
    state = core.emit_writefile(state, "comma_sp", 2)
    state.asm = a.mark(state.asm, l_skip_comma)
    state.asm = a.jmp(state.asm, l_top)

    state.asm = a.mark(state.asm, l_done)
    state = core.emit_writefile(state, "rbrack", 1)
    state = core.emit_writefile(state, "nl", 1)
    state.asm = a.jmp(state.asm, l_end)

    state.asm = a.mark(state.asm, l_uns)
    state = core.emit_dbg_line(state, stmt)
    state = exprmod._emit_make_error_const(state, c.ERR_PRINT_UNSUPPORTED, "Cannot print unsupported value")
    state = exprmod._emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_end)

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
    l_bfalse = "print_bool_false_" + lid_p
    state.asm = a.jcc(state.asm, "z", l_bfalse)
    state = core.emit_writefile(state, "true_s", 5)
    state.asm = a.jmp(state.asm, l_end)
    state.asm = a.mark(state.asm, l_bfalse)
    state = core.emit_writefile(state, "false_s", 6)

    state.asm = a.mark(state.asm, l_end)
    return state
  end if

  if k == "While" then
    tv_w = _opt_try_truthy(state, stmt.cond)
    if typeof(tv_w) == "bool" and tv_w == false then
      return state
    end if

    lid_w = state.label_id
    state.label_id = state.label_id + 1
    l_top = "while_top_" + lid_w
    l_end = "while_end_" + lid_w

    depth_w = scope.cg_scope_depth(state)
    state.break_stack = state.break_stack + [_breakctx_make("loop", l_end, l_top, depth_w, depth_w)]
    state.asm = a.mark(state.asm, l_top)
    if typeof(tv_w) != "bool" or tv_w != true then
      state = exprmod.cg_emit_expr(state, stmt.cond)
      l_wcond_ok = "while_cond_ok_" + lid_w
      state = _emit_condition_nonvoid_guard(state, stmt.cond, l_wcond_ok, l_end)
      state = core.emit_jmp_if_false_rax(state, l_end)
    end if
    state = scope.cg_scope_enter(state)
    state = _emit_stmt_list(state, stmt.body)
    state = scope.cg_scope_leave(state, true)
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
    state = scope.cg_scope_leave(state, true)
    state.asm = a.mark(state.asm, l_cont)
    tv_dw = _opt_try_truthy(state, stmt.cond)
    if typeof(tv_dw) == "bool" and tv_dw == true then
      state.asm = a.jmp(state.asm, l_body)
    else
      if typeof(tv_dw) == "bool" and tv_dw == false then
        state.asm = a.jmp(state.asm, l_end)
      else
        state = exprmod.cg_emit_expr(state, stmt.cond)
        l_dwcond_ok = "dowhile_cond_ok_" + lid_dw
        state = _emit_condition_nonvoid_guard(state, stmt.cond, l_dwcond_ok, l_end)
        state = core.emit_jmp_if_false_rax(state, l_end)
        state.asm = a.jmp(state.asm, l_body)
      end if
    end if
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
    bind_kind_for = "local"
    if state.in_function == false then bind_kind_for = "global" end if
    unroll_vals = _for_unroll_values(state, stmt)
    if typeof(unroll_vals) == "array" and len(unroll_vals) > 0 then
      depth_for_outer = scope.cg_scope_depth(state)
      state = scope.cg_scope_enter(state)
      state = scope.declare_fresh_binding(state, qv, stmt, bind_kind_for)
      for ui = 0 to len(unroll_vals) - 1
        state.asm = a.mov_rax_imm64(state.asm, t.enc_int(unroll_vals[ui]))
        state = scope.emit_store_var_scoped(state, qv, stmt)
        state = scope.cg_scope_enter(state)
        state = _emit_stmt_list(state, stmt.body)
        state = scope.cg_scope_leave(state, true)
      end for
      state = scope.cg_scope_leave(state, true)
      return state
    end if

    state = scope.cg_scope_enter(state)
    // For-loop variable is a fresh declaration in loop scope (Python parity).
    state = scope.declare_fresh_binding(state, qv, stmt, bind_kind_for)
    fstate_names = _for_state_names(stmt)
    end_name_f = ""
    step_name_f = ""
    if typeof(fstate_names) == "array" and len(fstate_names) >= 2 then
      end_name_f = _coerce_name(fstate_names[0])
      step_name_f = _coerce_name(fstate_names[1])
    end if
    if end_name_f != "" then
      state = scope.declare_fresh_binding(state, end_name_f, stmt, bind_kind_for)
    end if
    if step_name_f != "" then
      state = scope.declare_fresh_binding(state, step_name_f, stmt, bind_kind_for)
    end if
    state = exprmod.cg_emit_expr(state, stmt.start)
    state = scope.emit_store_var_scoped(state, qv, stmt)

    lid_f = state.label_id
    state.label_id = state.label_id + 1
    l_top_f = "for_top_" + lid_f
    l_cont_f = "for_cont_" + lid_f
    l_end_f = "for_end_" + lid_f
    l_step_pos_f = "for_step_pos_" + lid_f
    l_step_done_f = "for_step_done_" + lid_f

    depth_for_outer = scope.cg_scope_depth(state) - 1
    depth_for_loop = scope.cg_scope_depth(state)
    state.break_stack = state.break_stack + [_breakctx_make("loop", l_end_f, l_cont_f, depth_for_outer, depth_for_loop)]

    end_ex_f = stmt.end_expr
    state = exprmod.cg_emit_expr(state, end_ex_f)
    state = scope.emit_store_var_scoped(state, end_name_f, stmt)

    // step = (start <= end) ? +1 : -1  (encoded int)
    state = scope.emit_load_var_scoped(state, qv)
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state = scope.emit_load_var_scoped(state, end_name_f)
    state.asm = a.cmp_r64_r64(state.asm, "rax", "r10")
    state.asm = a.jcc(state.asm, "ge", l_step_pos_f)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_int(-1))
    state = scope.emit_store_var_scoped(state, step_name_f, stmt)
    state.asm = a.jmp(state.asm, l_step_done_f)
    state.asm = a.mark(state.asm, l_step_pos_f)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_int(1))
    state = scope.emit_store_var_scoped(state, step_name_f, stmt)
    state.asm = a.mark(state.asm, l_step_done_f)

    state.asm = a.mark(state.asm, l_top_f)
    state = scope.cg_scope_enter(state)
    state = _emit_stmt_list(state, stmt.body)
    state = scope.cg_scope_leave(state, true)

    state.asm = a.mark(state.asm, l_cont_f)
    state = scope.emit_load_var_scoped(state, qv)
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state = scope.emit_load_var_scoped(state, end_name_f)
    state.asm = a.cmp_r64_r64(state.asm, "rax", "r10")
    state.asm = a.jcc(state.asm, "e", l_end_f)

    state = scope.emit_load_var_scoped(state, qv)
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state = scope.emit_load_var_scoped(state, step_name_f)
    state.asm = a.add_r64_r64(state.asm, "rax", "r10")
    state.asm = a.sub_rax_imm8(state.asm, 1)
    state = scope.emit_store_var_scoped(state, qv, stmt)
    state.asm = a.jmp(state.asm, l_top_f)

    state.asm = a.mark(state.asm, l_end_f)
    state = _breakstack_pop(state)
    state = scope.cg_scope_leave(state, true)
    return state
  end if

  if _is_foreach_stmt(stmt) then
    fid_fe = state.label_id
    state.label_id = state.label_id + 1
    fe_names = _foreach_state_names(stmt)
    it_name = fe_names[0]
    i_name = fe_names[1]
    len_name = fe_names[2]
    top_ptr_name = fe_names[3]
    base_ptr_name = fe_names[4]

    l_setup_arr_fe = "foreach_setup_arr_" + fid_fe
    l_setup_bytes_fe = "foreach_setup_bytes_" + fid_fe
    l_setup_str_fe = "foreach_setup_str_" + fid_fe
    l_top_arr_fe = "foreach_top_arr_" + fid_fe
    l_top_bytes_fe = "foreach_top_bytes_" + fid_fe
    l_top_str_fe = "foreach_top_str_" + fid_fe
    l_body_fe = "foreach_body_" + fid_fe
    l_cont_fe = "foreach_cont_" + fid_fe
    l_end_fe = "foreach_end_" + fid_fe

    vname_fe = _foreach_var_name(stmt)
    bind_kind_fe = "local"
    if state.in_function == false then bind_kind_fe = "global" end if
    depth_fe_outer = scope.cg_scope_depth(state)
    state = scope.cg_scope_enter(state)
    depth_fe_loop = scope.cg_scope_depth(state)
    state = scope.declare_fresh_binding(state, vname_fe, stmt, bind_kind_fe)
    state = scope.declare_fresh_binding(state, it_name, stmt, bind_kind_fe)
    state = scope.declare_fresh_binding(state, i_name, stmt, bind_kind_fe)
    state = scope.declare_fresh_binding(state, len_name, stmt, bind_kind_fe)
    state = scope.declare_fresh_binding(state, top_ptr_name, stmt, bind_kind_fe)
    state = scope.declare_fresh_binding(state, base_ptr_name, stmt, bind_kind_fe)
    state.break_stack = state.break_stack + [_breakctx_make("loop", l_end_fe, l_cont_fe, depth_fe_outer, depth_fe_loop)]

    state = exprmod.cg_emit_expr(state, stmt.iterable)
    state = scope.emit_store_var_scoped(state, it_name, stmt)
    state.asm = a.mov_rax_imm64(state.asm, 0)
    state = scope.emit_store_var_scoped(state, i_name, stmt)
    state = scope.emit_store_var_scoped(state, len_name, stmt)
    state = scope.emit_store_var_scoped(state, top_ptr_name, stmt)
    state = scope.emit_store_var_scoped(state, base_ptr_name, stmt)

    state = scope.emit_load_var_scoped(state, it_name)
    state.asm = a.mov_r64_r64(state.asm, "r14", "rax")
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r14", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
    state.asm = a.jcc(state.asm, "e", l_setup_arr_fe)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY_IMM)
    state.asm = a.jcc(state.asm, "e", l_setup_arr_fe)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "e", l_setup_bytes_fe)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
    state.asm = a.jcc(state.asm, "e", l_setup_str_fe)
    state.asm = a.jmp(state.asm, l_end_fe)

    state.asm = a.mark(state.asm, l_setup_arr_fe)
    state = scope.emit_load_var_scoped(state, it_name)
    state.asm = a.mov_r64_r64(state.asm, "r14", "rax")
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r14", 4)
    state.asm = a.mov_r32_r32(state.asm, "eax", "edx")
    state = scope.emit_store_var_scoped(state, len_name, stmt)
    state.asm = a.lea_r64_membase_disp(state.asm, "rax", "r14", 8)
    state = scope.emit_store_var_scoped(state, base_ptr_name, stmt)
    state.asm = a.lea_rax_rip(state.asm, l_top_arr_fe)
    state = scope.emit_store_var_scoped(state, top_ptr_name, stmt)
    state.asm = a.jmp(state.asm, l_top_arr_fe)

    state.asm = a.mark(state.asm, l_setup_bytes_fe)
    state = scope.emit_load_var_scoped(state, it_name)
    state.asm = a.mov_r64_r64(state.asm, "r14", "rax")
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r14", 4)
    state.asm = a.mov_r32_r32(state.asm, "eax", "edx")
    state = scope.emit_store_var_scoped(state, len_name, stmt)
    state.asm = a.lea_r64_membase_disp(state.asm, "rax", "r14", 8)
    state = scope.emit_store_var_scoped(state, base_ptr_name, stmt)
    state.asm = a.lea_rax_rip(state.asm, l_top_bytes_fe)
    state = scope.emit_store_var_scoped(state, top_ptr_name, stmt)
    state.asm = a.jmp(state.asm, l_top_bytes_fe)

    state.asm = a.mark(state.asm, l_setup_str_fe)
    state = scope.emit_load_var_scoped(state, it_name)
    state.asm = a.mov_r64_r64(state.asm, "r14", "rax")
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r14", 4)
    state.asm = a.mov_r32_r32(state.asm, "eax", "edx")
    state = scope.emit_store_var_scoped(state, len_name, stmt)
    state.asm = a.lea_r64_membase_disp(state.asm, "rax", "r14", 8)
    state = scope.emit_store_var_scoped(state, base_ptr_name, stmt)
    state.asm = a.lea_rax_rip(state.asm, l_top_str_fe)
    state = scope.emit_store_var_scoped(state, top_ptr_name, stmt)
    state.asm = a.jmp(state.asm, l_top_str_fe)

    state.asm = a.mark(state.asm, l_top_arr_fe)
    state = scope.emit_load_var_scoped(state, i_name)
    state.asm = a.mov_r32_r32(state.asm, "ecx", "eax")
    state = scope.emit_load_var_scoped(state, len_name)
    state.asm = a.mov_r32_r32(state.asm, "edx", "eax")
    state.asm = a.cmp_r32_r32(state.asm, "ecx", "edx")
    state.asm = a.jcc(state.asm, "ge", l_end_fe)
    state = scope.emit_load_var_scoped(state, base_ptr_name)
    state.asm = a.mov_r64_r64(state.asm, "r14", "rax")
    state.asm = a.mov_r64_mem_bis(state.asm, "rax", "r14", "rcx", 8, 8)
    state = scope.emit_store_var_scoped(state, vname_fe, stmt)
    state.asm = a.jmp(state.asm, l_body_fe)

    state.asm = a.mark(state.asm, l_top_bytes_fe)
    state = scope.emit_load_var_scoped(state, i_name)
    state.asm = a.mov_r32_r32(state.asm, "ecx", "eax")
    state = scope.emit_load_var_scoped(state, len_name)
    state.asm = a.mov_r32_r32(state.asm, "edx", "eax")
    state.asm = a.cmp_r32_r32(state.asm, "ecx", "edx")
    state.asm = a.jcc(state.asm, "ge", l_end_fe)
    state = scope.emit_load_var_scoped(state, base_ptr_name)
    state.asm = a.mov_r64_r64(state.asm, "r14", "rax")
    state.asm = a.mov_r64_r64(state.asm, "rax", "r14")
    state.asm = a.add_r64_r64(state.asm, "rax", "rcx")
    state.asm = a.movzx_r32_membase_disp(state.asm, "eax", "rax", 0)
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
    state = scope.emit_store_var_scoped(state, vname_fe, stmt)
    state.asm = a.jmp(state.asm, l_body_fe)

    state.asm = a.mark(state.asm, l_top_str_fe)
    state = scope.emit_load_var_scoped(state, i_name)
    state.asm = a.mov_r32_r32(state.asm, "ecx", "eax")
    state = scope.emit_load_var_scoped(state, len_name)
    state.asm = a.mov_r32_r32(state.asm, "edx", "eax")
    state.asm = a.cmp_r32_r32(state.asm, "ecx", "edx")
    state.asm = a.jcc(state.asm, "ge", l_end_fe)
    state = scope.emit_load_var_scoped(state, base_ptr_name)
    state.asm = a.mov_r64_r64(state.asm, "r14", "rax")
    state.asm = a.mov_r64_r64(state.asm, "rax", "r14")
    state.asm = a.add_r64_r64(state.asm, "rax", "rcx")
    state.asm = a.movzx_r32_membase_disp(state.asm, "eax", "rax", 0)
    state.asm = a.mov_membase_disp_r8(state.asm, "rsp", 0x20, "al")
    state.asm = a.mov_rcx_imm32(state.asm, 10)
    state.asm = a.call(state.asm, "fn_alloc")
    state.asm = a.mov_r11_rax(state.asm)
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRING, false)
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, 1, false)
    state.asm = a.mov_r8_membase_disp(state.asm, "al", "rsp", 0x20)
    state.asm = a.mov_membase_disp_r8(state.asm, "r11", 8, "al")
    state.asm = a.mov_membase_disp_imm8(state.asm, "r11", 9, 0)
    state.asm = a.mov_rax_r11(state.asm)
    state = scope.emit_store_var_scoped(state, vname_fe, stmt)

    state.asm = a.mark(state.asm, l_body_fe)
    state = scope.cg_scope_enter(state)
    state = _emit_stmt_list(state, stmt.body)
    state = scope.cg_scope_leave(state, true)

    state.asm = a.mark(state.asm, l_cont_fe)
    state = scope.emit_load_var_scoped(state, i_name)
    state.asm = a.mov_r32_r32(state.asm, "ecx", "eax")
    state.asm = a.inc_r32(state.asm, "ecx")
    state.asm = a.mov_r32_r32(state.asm, "eax", "ecx")
    state = scope.emit_store_var_scoped(state, i_name, stmt)
    state = scope.emit_load_var_scoped(state, top_ptr_name)
    state.asm = a.jmp_r64(state.asm, "rax")

    state.asm = a.mark(state.asm, l_end_fe)
    state = _breakstack_pop(state)
    state = scope.cg_scope_leave(state, true)
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

function inline _is_node(n, kind)
  if typeof(n) != "struct" then return false end if
  if typeof(kind) == "string" and kind != "" then return n.node_kind == kind end if
  return typeof(n.node_kind) == "string"
end function

function inline _is_stmt(st)
  return _is_node(st, 0)
end function

function inline _decl_st_file(st)
  if typeof(st) == "struct" and typeof(st._filename) == "string" then return st._filename end if
  return ""
end function

function inline _dotted_name(parts)
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
  if r.ok == false then return void end if
  return _truthy(r.value)
end function

function _is_foreach_stmt(st)
  if typeof(st) != "struct" then return false end if
  if typeof(st.node_kind) == "string" then
    nk = st.node_kind
    if nk == "ForEach" or nk == "ForEachArray" or nk == "ForEachString" then return true end if
  end if
  return false
end function

function _foreach_var_name(st)
  return _coerce_name(st.var)
end function

function _foreach_state_names(st)
  fid = "n_" + _foreach_var_name(st)
  if typeof(st) == "struct" then
    p0 = 0
    p_try = try(st._pos)
    if typeof(p_try) == "int" then p0 = p_try end if
    if p0 > 0 then
      fid = "p" + p0 + "_" + _foreach_var_name(st)
    end if
  end if

  names = [
    "__foreach_it_" + fid,
    "__foreach_i_" + fid,
    "__foreach_len_" + fid,
    "__foreach_top_ptr_" + fid,
    "__foreach_base_ptr_" + fid,
  ]
  return names
end function

function _for_state_names(st)
  fid = "n_" + _foreach_var_name(st)
  if typeof(st) == "struct" then
    p0 = 0
    p_try = try(st._pos)
    if typeof(p_try) == "int" then p0 = p_try end if
    if p0 > 0 then
      fid = "p" + p0 + "_" + _foreach_var_name(st)
    end if
  end if

  return [
    "__for_end_" + fid,
    "__for_step_" + fid,
  ]
end function

function _opt_try_const_int(state, ex)
  r = exprmod.cg_expr_try_const_value(state, ex)
  if r.ok == false then return void end if
  if typeof(r.value) != "int" then return void end if
  return r.value
end function

function _owner_for(st)
  return _st_file(st)
end function

function _tag_ns(ns, name)
  return _join_qname(ns, name)
end function

function _pref_is_method_prefix(state, pref)
  if typeof(pref) != "string" then return false end if
  if pref == "" then return false end if
  qn0 = pref
  if qn0[len(qn0) - 1] == "." then qn0 = s.substr(qn0, 0, len(qn0) - 1) end if
  if qn0 == "" then return false end if
  if s.contains(qn0, ".__static__") then return true end if
  if typeof(state.struct_fields) == "array" and len(state.struct_fields) > 0 then
    for i = 0 to len(state.struct_fields) - 1
      sf = state.struct_fields[i]
      sqn = ""
      if typeof(sf) == "struct" then sqn = _coerce_name(sf.key) end if
      if typeof(sf) == "array" and len(sf) >= 2 then sqn = _coerce_name(sf[0]) end if
      if sqn == qn0 then return true end if
    end for
  end if
  return false
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

function _qname_parent_prefix(qn)
  if typeof(qn) != "string" then return "" end if
  if qn == "" then return "" end if
  dot = -1
  for i = 0 to len(qn) - 1
    if qn[i] == "." then dot = i end if
  end for
  if dot < 0 then return "" end if
  return s.substr(qn, 0, dot + 1)
end function

function _resolve_global_target_scan(state, raw, qpref, fpref)
  raw2 = _coerce_name(raw)
  if raw2 == "" then return "" end if
  if _has_dot_name(raw2) then return raw2 end if

  cands_b = t.arr_chunk_new(4)
  if typeof(qpref) == "string" and qpref != "" then
    pref_q = qpref
    if pref_q[len(pref_q) - 1] != "." then pref_q = pref_q + "." end if
    cands_b = t.arr_chunk_push(cands_b, pref_q + raw2)
  end if
  if typeof(fpref) == "string" and fpref != "" then
    pref_f = fpref
    if pref_f[len(pref_f) - 1] != "." then pref_f = pref_f + "." end if
    cands_b = t.arr_chunk_push(cands_b, pref_f + raw2)
  end if
  cands_b = t.arr_chunk_push(cands_b, raw2)
  cands = t.arr_chunk_finish(cands_b)

  if typeof(cands) == "array" and len(cands) > 0 then
    for i = 0 to len(cands) - 1
      cand = _coerce_name(cands[i])
      if cand == "" then continue end if
      b = scope.resolve_binding(state, cand)
      if typeof(b) == "struct" and b.kind == "global" then
        depth0 = 0
        if typeof(b.depth) == "int" then depth0 = b.depth end if
        if depth0 == 0 then return cand end if
      end if
    end for
  end if

  if typeof(qpref) == "string" and qpref != "" and _pref_is_method_prefix(state, qpref) == false then
    pref_q2 = qpref
    if pref_q2[len(pref_q2) - 1] != "." then pref_q2 = pref_q2 + "." end if
    return pref_q2 + raw2
  end if
  if typeof(fpref) == "string" and fpref != "" then
    pref_f2 = fpref
    if pref_f2[len(pref_f2) - 1] != "." then pref_f2 = pref_f2 + "." end if
    return pref_f2 + raw2
  end if
  return raw2
end function

function _scan_stmt_children(st)
  kids = []
  if typeof(st) != "struct" then return kids end if

  body0 = try(st.body)
  if typeof(body0) == "array" and len(body0) > 0 then
    kids = kids + body0
  end if
  then0 = try(st.then_body)
  if typeof(then0) == "array" and len(then0) > 0 then
    kids = kids + then0
  end if
  else0 = try(st.else_body)
  if typeof(else0) == "array" and len(else0) > 0 then
    kids = kids + else0
  end if
  def0 = try(st.default_body)
  if typeof(def0) == "array" and len(def0) > 0 then
    kids = kids + def0
  end if

  cases0 = try(st.cases)
  if typeof(cases0) == "array" and len(cases0) > 0 then
    for ci = 0 to len(cases0) - 1
      cs = cases0[ci]
      cs_body = try(cs.body)
      if typeof(cs) == "struct" and typeof(cs_body) == "array" and len(cs_body) > 0 then
        kids = kids + cs_body
      end if
    end for
  end if

  elifs0 = try(st.elifs)
  if typeof(elifs0) == "array" and len(elifs0) > 0 then
    for ei = 0 to len(elifs0) - 1
      eb = elifs0[ei]
      if typeof(eb) == "array" and len(eb) >= 2 and typeof(eb[1]) == "array" and len(eb[1]) > 0 then
        kids = kids + eb[1]
      end if
    end for
  end if

  return kids
end function

function _scan_function_for_global_decls(state, fn_node)
  if typeof(fn_node) != "struct" then return state end if

  fn_qn = _coerce_name(fn_node.name)
  qpref = _qname_parent_prefix(fn_qn)

  fn_file = _st_file(fn_node)
  if fn_file == "" then
    p = fn_node._ml_parent_fn
    if typeof(p) == "struct" then fn_file = _st_file(p) end if
  end if
  fpref = ""
  if fn_file != "" then fpref = _strpair_get(state.file_prefix_map, fn_file) end if

  declared0 = try(fn_node._ml_globals_declared)
  if typeof(declared0) == "array" and len(declared0) > 0 then
    for di = 0 to len(declared0) - 1
      nm0 = _coerce_name(declared0[di])
      if nm0 == "" then continue end if
      tgt0 = _resolve_global_target_scan(state, nm0, qpref, fpref)
      if tgt0 == "" then continue end if
      state = scope.declare_global_binding_root(state, tgt0, fn_node, false, 0)
    end for
  end if

  stack = []
  body_fn = try(fn_node.body)
  if typeof(body_fn) != "array" then return state end if
  if typeof(body_fn) == "array" and len(body_fn) > 0 then stack = body_fn end if

  while typeof(stack) == "array" and len(stack) > 0
    top_i = len(stack) - 1
    st = stack[top_i]
    if top_i <= 0 then
      stack = []
    else
      stack2 = slice(stack, 0, top_i)
      if typeof(stack2) == "array" then
        stack = stack2
      else
        stack = []
      end if
    end if
    if typeof(st) != "struct" then continue end if

    st_kind = _coerce_name(st.node_kind)
    if st_kind == "GlobalDecl" then
      names0 = try(st.names)
      if typeof(names0) != "array" or len(names0) <= 0 then continue end if
      for j = 0 to len(names0) - 1
        nm = _coerce_name(names0[j])
        if nm == "" then continue end if
        tgt = _resolve_global_target_scan(state, nm, qpref, fpref)
        if tgt == "" then continue end if
        state = scope.declare_global_binding_root(state, tgt, st, false, 0)
      end for
      continue
    end if

    kids = _scan_stmt_children(st)
    if typeof(kids) == "array" and len(kids) > 0 then
      for ki = 0 to len(kids) - 1
        child = kids[ki]
        if typeof(child) == "struct" then
          if typeof(stack) != "array" then stack = [] end if
          stack = stack + [child]
        end if
      end for
    end if
  end while

  return state
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
  cur_file = "<module:entry>"
  cur_items = []
  for i = 0 to len(program) - 1
    st = program[i]
    fn = _st_file(st)
    if fn == "" then fn = "<module:entry>" end if
    if len(cur_items) > 0 and fn != cur_file then
      vals = vals +[[cur_file, cur_items]]
      cur_items = []
    end if
    cur_file = fn
    cur_items = cur_items +[st]
  end for
  if len(cur_items) > 0 then
    vals = vals +[[cur_file, cur_items]]
  end if
  return vals
end function

function inline _arr_has(arr, value)
  if typeof(arr) != "array" or len(arr) <= 0 then return false end if
  for i = 0 to len(arr) - 1
    if arr[i] == value then return true end if
  end for
  return false
end function

function inline _arr_add_unique(arr, value)
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

function inline _name_set_new(initial_cap)
  return t.fastmap_new(initial_cap)
end function

function inline _name_set_size(setv)
  if typeof(setv) == "struct" then return t.fastmap_size(setv) end if
  if typeof(setv) == "array" then return len(setv) end if
  return 0
end function

function _name_set_to_array(setv)
  if typeof(setv) == "array" then return setv end if
  out_b = t.arr_chunk_new(32)
  if typeof(setv) == "struct" then
    items = t.fastmap_items(setv)
    if typeof(items) == "array" and len(items) > 0 then
      for i = 0 to len(items) - 1
        it = items[i]
        key = ""
        if typeof(it) == "array" and len(it) >= 1 and typeof(it[0]) == "string" then key = it[0] end if
        if key != "" then out_b = t.arr_chunk_push(out_b, key) end if
      end for
    end if
  end if
  return t.arr_chunk_finish(out_b)
end function

function inline _name_set_has(setv, value)
  if typeof(value) != "string" or value == "" then return false end if
  if typeof(setv) == "struct" then return t.fastmap_has(setv, value) end if
  return _arr_has(setv, value)
end function

function _name_set_add(setv, value)
  if typeof(value) != "string" or value == "" then
    if typeof(setv) == "struct" or typeof(setv) == "array" then return setv end if
    return []
  end if
  if typeof(setv) == "struct" then return t.fastmap_set(setv, value, true) end if
  if typeof(setv) != "array" then setv = [] end if
  return _arr_add_unique(setv, value)
end function

function _name_set_remove(setv, value)
  if typeof(value) != "string" or value == "" then return setv end if
  if typeof(setv) == "struct" then
    items = t.fastmap_items(setv)
    outv = t.fastmap_new((t.fastmap_size(setv) * 2) + 16)
    if typeof(items) == "array" and len(items) > 0 then
      for i = 0 to len(items) - 1
        it = items[i]
        key = ""
        if typeof(it) == "array" and len(it) >= 1 and typeof(it[0]) == "string" then key = it[0] end if
        if key != "" and key != value then outv = t.fastmap_set(outv, key, true) end if
      end for
    end if
    return outv
  end if
  return _arr_remove_value(setv, value)
end function

function _name_set_union(a, b)
  if typeof(a) != "struct" and typeof(b) != "struct" then return _arr_union(a, b) end if
  outv = _name_set_new((_name_set_size(a) + _name_set_size(b)) * 2 + 16)
  aa = _name_set_to_array(a)
  if typeof(aa) == "array" and len(aa) > 0 then
    for i = 0 to len(aa) - 1
      outv = _name_set_add(outv, aa[i])
    end for
  end if
  bb = _name_set_to_array(b)
  if typeof(bb) == "array" and len(bb) > 0 then
    for i = 0 to len(bb) - 1
      outv = _name_set_add(outv, bb[i])
    end for
  end if
  return outv
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
  if typeof(arr) == "struct" then return t.fastmap_set(arr, key, value) end if
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

function _map_int_items(arr)
  if typeof(arr) == "struct" then return t.fastmap_items(arr) end if
  if typeof(arr) == "array" then return arr end if
  return []
end function

function _string_gt(a, b)
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

function _sort_names(vals)
  if typeof(vals) == "struct" then vals = _name_set_to_array(vals) end if
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
      if _string_gt(a, b) then
        tmp = arr[j]
        arr[j] = arr[j + 1]
        arr[j + 1] = tmp
      end if
    end for
  end for
  return arr
end function

function _id_label_pair_id(it)
  if typeof(it) == "array" and len(it) >= 2 and typeof(it[0]) == "int" then
    return it[0]
  end if
  if typeof(it) == "struct" and typeof(it.key) == "int" then
    return it.key
  end if
  return -1
end function

function _sort_id_label_pairs(vals)
  if typeof(vals) != "array" or len(vals) <= 1 then return vals end if
  arr = []
  for i = 0 to len(vals) - 1
    arr = arr + [vals[i]]
  end for
  n = len(arr)
  if n <= 1 then return arr end if
  for i = 0 to n - 2
    for j = 0 to n - 2 - i
      a = arr[j]
      b = arr[j + 1]
      aid = _id_label_pair_id(a)
      bid = _id_label_pair_id(b)
      swap = false
      if aid < 0 then
        if bid >= 0 then swap = true end if
      else
        if bid >= 0 and aid > bid then swap = true end if
      end if
      if swap then
        tmp = arr[j]
        arr[j] = arr[j + 1]
        arr[j + 1] = tmp
      end if
    end for
  end for
  return arr
end function

function _analysis_register_local_decl(state, decl_node, name)
  nm = _coerce_name(name)
  if nm == "" then return state end if
  existing = scope.resolve_binding_for_write(state, nm)
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and state.current_qname_prefix == "std.string." then
    ex_kind = ""
    if typeof(existing) == "struct" and typeof(existing.kind) == "string" then ex_kind = existing.kind end if
    print "[mem][cg][analysis] local_decl name=" + nm + " existing=" + ex_kind
  end if
  if typeof(existing) == "struct" then return state end if
  state = scope.declare_local_binding(state, nm, decl_node, false, 0)
  state = _analysis_mark_current_binding_boxed(state, nm)
  b = scope.resolve_binding(state, nm)
  if typeof(b) == "struct" then
    state = scope.register_decl_site_binding(state, decl_node, nm, b)
  end if
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and state.current_qname_prefix == "std.string." then
    fl = state.function_locals
    flen = 0
    if typeof(fl) == "array" then flen = len(fl) end if
    print "[mem][cg][analysis] local_decl_after name=" + nm + " fn_locals=" + flen
  end if
  return state
end function

function _analysis_register_fresh_local_decl(state, decl_node, name)
  nm = _coerce_name(name)
  if nm == "" then return state end if
  state = scope.declare_local_binding(state, nm, decl_node, false, 0)
  state = _analysis_mark_current_binding_boxed(state, nm)
  b = scope.resolve_binding(state, nm)
  if typeof(b) == "struct" then
    state = scope.register_decl_site_binding(state, decl_node, nm, b)
  end if
  return state
end function

function _analysis_mark_current_binding_boxed(state, name)
  nm = _coerce_name(name)
  if nm == "" then return state end if
  if _arr_has(state.current_fn_boxed_names, nm) == false then return state end if
  ss = state.scope_stack
  if typeof(ss) != "array" or len(ss) <= 0 then return state end if
  si = len(ss) - 1
  fr = ss[si]
  if typeof(fr) != "array" or len(fr) <= 0 then return state end if
  jb = len(fr) - 1
  while jb >= 0
    bb = fr[jb]
    if typeof(bb) == "struct" and bb.name == nm then
      bb.boxed = true
      fr[jb] = bb
      ss[si] = fr
      state.scope_stack = ss
      sisb = state.scope_index_stack
      if typeof(sisb) == "array" and si >= 0 and si < len(sisb) then
        fmb = sisb[si]
        fmb = t.fastmap_set(fmb, bb.name, bb)
        sisb[si] = fmb
        state.scope_index_stack = sisb
      end if
      break
    end if
    jb = jb - 1
  end while
  return state
end function

function _analysis_member_target(ex)
  if typeof(ex) != "struct" then return 0 end if
  t0 = try(ex.target)
  if typeof(t0) == "struct" then return t0 end if
  o0 = try(ex.obj)
  if typeof(o0) == "struct" then return o0 end if
  return 0
end function

function _analysis_call_callee(ex)
  if typeof(ex) != "struct" then return 0 end if
  c0 = try(ex.callee)
  if typeof(c0) == "struct" then return c0 end if
  f0 = try(ex.func)
  if typeof(f0) == "struct" then return f0 end if
  return 0
end function

function _analysis_call_args(ex)
  if typeof(ex) != "struct" then return [] end if
  aa = try(ex.args)
  if typeof(aa) == "array" then return aa end if
  return []
end function

function _analysis_for_end_expr(st)
  if typeof(st) != "struct" then return 0 end if
  e1 = try(st.end_expr)
  if typeof(e1) == "struct" then return e1 end if
  return 0
end function

function _analysis_builtin_has(name)
  nm = _coerce_name(name)
  if nm == "" then return false end if
  if nm == "try" then return true end if
  if nm == "array" then return true end if
  if nm == "bytes" then return true end if
  if nm == "byteBuffer" then return true end if
  return exprmod._builtin_label(nm) != ""
end function

function _analysis_known_callable_name(state, name)
  nm = _coerce_name(name)
  if nm == "" then return false end if
  if _analysis_builtin_has(nm) then return true end if
  if typeof(_user_function_get_node(state, nm)) == "struct" then return true end if
  if exprmod._state_struct_id_get(state, nm, 0) != 0 then return true end if
  if typeof(exprmod._extern_sig_get(state, nm)) == "struct" then return true end if
  return false
end function

function _analysis_is_type_query_name(name)
  nm = _coerce_name(name)
  return nm == "typeof" or nm == "typeName"
end function

function _analysis_scan_expr(state, ex, allow_func_ident)
  if typeof(ex) != "struct" then return state end if
  nk = _coerce_name(ex.node_kind)

  if nk == "Var" then
    nm0 = _coerce_name(try(ex.name))
    if nm0 == "" then return state end if
    nm1 = exprmod._apply_import_alias(state, nm0)
    if nm1 == "" then nm1 = nm0 end if
    nm2 = exprmod._qualify_identifier(state, nm1)
    nm = nm1
    if nm2 != "" then nm = nm2 end if

    if allow_func_ident then
      if _analysis_known_callable_name(state, nm0) then return state end if
      if _analysis_known_callable_name(state, nm1) then return state end if
      if _analysis_known_callable_name(state, nm) then return state end if
    end if

    b = scope.resolve_binding(state, nm)
    if typeof(b) != "struct" and nm != nm0 then
      b = scope.resolve_binding(state, nm0)
    end if
    if typeof(b) != "struct" then
      state.diagnostics = state.diagnostics + ["Undefined variable '" + nm + "'"]
    end if
    return state
  end if

  if nk == "Call" then
    cal = _analysis_call_callee(ex)
    args = _analysis_call_args(ex)
    cal_kind = ""
    if typeof(cal) == "struct" then cal_kind = _coerce_name(cal.node_kind) end if

    if cal_kind == "Var" then
      raw_name = _coerce_name(try(cal.name))
      cal_name = exprmod._apply_import_alias(state, raw_name)
      if cal_name == "" then cal_name = raw_name end if
      cal_q = exprmod._qualify_identifier(state, cal_name)
      if cal_q == "" then cal_q = cal_name end if
      if _analysis_known_callable_name(state, raw_name) or _analysis_known_callable_name(state, cal_name) or _analysis_known_callable_name(state, cal_q) then
        allow_ident = _analysis_is_type_query_name(raw_name) or _analysis_is_type_query_name(cal_name) or _analysis_is_type_query_name(cal_q)
        if len(args) > 0 then
          for i = 0 to len(args) - 1
            state = _analysis_scan_expr(state, args[i], allow_ident)
          end for
        end if
        return state
      end if
    end if

    if cal_kind == "Member" then
      qn0 = exprmod._expr_to_qualname(state, cal)
      qn1 = exprmod._apply_import_alias(state, qn0)
      if qn1 == "" then qn1 = qn0 end if
      qn2 = exprmod._qualify_identifier(state, qn1)
      if qn2 == "" then qn2 = qn1 end if
      if _analysis_known_callable_name(state, qn0) or _analysis_known_callable_name(state, qn1) or _analysis_known_callable_name(state, qn2) then
        if len(args) > 0 then
          for i = 0 to len(args) - 1
            state = _analysis_scan_expr(state, args[i], false)
          end for
        end if
        return state
      end if
    end if

    state = _analysis_scan_expr(state, cal, false)
    if len(args) > 0 then
      for i = 0 to len(args) - 1
        state = _analysis_scan_expr(state, args[i], false)
      end for
    end if
    return state
  end if

  if nk == "Unary" then
    return _analysis_scan_expr(state, try(ex.right), false)
  end if

  if nk == "Bin" then
    state = _analysis_scan_expr(state, try(ex.left), false)
    state = _analysis_scan_expr(state, try(ex.right), false)
    return state
  end if

  if nk == "ArrayLit" then
    items = try(ex.items)
    if typeof(items) == "array" and len(items) > 0 then
      for i = 0 to len(items) - 1
        state = _analysis_scan_expr(state, items[i], false)
      end for
    end if
    return state
  end if

  if nk == "Index" then
    state = _analysis_scan_expr(state, try(ex.target), false)
    state = _analysis_scan_expr(state, try(ex.index), false)
    return state
  end if

  if nk == "StructInit" then
    vals = try(ex.values)
    if typeof(vals) == "array" and len(vals) > 0 then
      for i = 0 to len(vals) - 1
        state = _analysis_scan_expr(state, vals[i], false)
      end for
    end if
    return state
  end if

  if nk == "Member" then
    qraw = _member_chain_name(ex)
    q1 = exprmod._apply_import_alias(state, qraw)
    if q1 == "" then q1 = qraw end if
    q2 = exprmod._qualify_identifier(state, q1)
    if q2 == "" then q2 = q1 end if

    if _analysis_known_callable_name(state, qraw) or _analysis_known_callable_name(state, q1) or _analysis_known_callable_name(state, q2) then
      return state
    end if

    if typeof(scope.resolve_binding(state, q2)) == "struct" then return state end if
    if q2 != q1 and typeof(scope.resolve_binding(state, q1)) == "struct" then return state end if
    if q1 != qraw and typeof(scope.resolve_binding(state, qraw)) == "struct" then return state end if

    mem = _coerce_name(try(ex.name))
    tgt = _analysis_member_target(ex)
    base0 = _member_chain_name(tgt)
    if mem != "" and base0 != "" then
      base1 = exprmod._apply_import_alias(state, base0)
      if base1 == "" then base1 = base0 end if
      base2 = exprmod._qualify_identifier(state, base1)
      if base2 == "" then base2 = base1 end if

      vars2 = _named_array_get(state.enum_variants, base2)
      if typeof(vars2) == "array" then
        if _arr_has(vars2, mem) then return state end if
        state.diagnostics = state.diagnostics +["Enum " + base2 + " has no variant " + mem]
        return state
      end if

      if base2 != base1 then
        vars1 = _named_array_get(state.enum_variants, base1)
        if typeof(vars1) == "array" then
          if _arr_has(vars1, mem) then return state end if
          state.diagnostics = state.diagnostics +["Enum " + base1 + " has no variant " + mem]
          return state
        end if
      end if

      if base1 != base0 then
        vars0 = _named_array_get(state.enum_variants, base0)
        if typeof(vars0) == "array" then
          if _arr_has(vars0, mem) then return state end if
          state.diagnostics = state.diagnostics +["Enum " + base0 + " has no variant " + mem]
          return state
        end if
      end if
    end if

    return _analysis_scan_expr(state, tgt, false)
  end if

  return state
end function

function _analysis_scan_stmt(state, st)
  if typeof(st) != "struct" then return state end if
  k = _coerce_name(try(st.node_kind))

  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and state.current_qname_prefix == "std.string." then
    print "[mem][cg][analysis] scan_stmt type=" + typeof(st) + " kind=" + k
  end if

  if k == "GlobalDecl" then
    if typeof(st.names) == "array" and len(st.names) > 0 then
      gn = len(st.names)
      for gi = 0 to gn - 1
        if gi < 0 or gi >= gn then break end if
        gnm = _coerce_name(st.names[gi])
        if gnm == "" then continue end if
        state = scope.declare_function_global(state, gnm, gnm)
      end for
    end if
    return state
  end if

  if k == "ConstDecl" then
    state = _analysis_scan_expr(state, try(st.expr), false)
    state = _analysis_register_local_decl(state, st, st.name)
    return state
  end if

  if k == "Assign" then
    if _heap_cfg_get_bool(state, "cg_mem_probe", false) and state.current_qname_prefix == "std.string." then
      print "[mem][cg][analysis] scan_assign name=" + _coerce_name(try(st.name))
    end if
    state = _analysis_scan_expr(state, try(st.expr), false)
    state = _analysis_register_local_decl(state, st, st.name)
    return state
  end if

  if k == "SetMember" then
    obj_expr = try(st.obj)
    if typeof(obj_expr) != "struct" then obj_expr = try(st.target) end if
    state = _analysis_scan_expr(state, obj_expr, false)
    state = _analysis_scan_expr(state, try(st.expr), false)
    return state
  end if

  if k == "SetIndex" then
    state = _analysis_scan_expr(state, try(st.target), false)
    state = _analysis_scan_expr(state, try(st.index), false)
    state = _analysis_scan_expr(state, try(st.expr), false)
    return state
  end if

  if k == "Print" or k == "ExprStmt" or k == "Return" then
    state = _analysis_scan_expr(state, try(st.expr), false)
    return state
  end if

  if k == "If" then
    state = _analysis_scan_expr(state, try(st.cond), false)
    state = scope.cg_scope_enter(state)
    state = _analysis_scan_block(state, st.then_body)
    state = scope.cg_scope_leave(state, false)
    if typeof(st.elifs) == "array" and len(st.elifs) > 0 then
      en = len(st.elifs)
      for ei = 0 to en - 1
        if ei < 0 or ei >= en then break end if
        eb = st.elifs[ei]
        if typeof(eb) != "array" or len(eb) < 2 or typeof(eb[1]) != "array" then continue end if
        state = _analysis_scan_expr(state, eb[0], false)
        state = scope.cg_scope_enter(state)
        state = _analysis_scan_block(state, eb[1])
        state = scope.cg_scope_leave(state, false)
      end for
    end if
    if typeof(st.else_body) == "array" and len(st.else_body) > 0 then
      state = scope.cg_scope_enter(state)
      state = _analysis_scan_block(state, st.else_body)
      state = scope.cg_scope_leave(state, false)
    end if
    return state
  end if

  if k == "While" then
    state = _analysis_scan_expr(state, try(st.cond), false)
    state = scope.cg_scope_enter(state)
    state = _analysis_scan_block(state, st.body)
    state = scope.cg_scope_leave(state, false)
    return state
  end if

  if k == "DoWhile" then
    state = scope.cg_scope_enter(state)
    state = _analysis_scan_block(state, st.body)
    state = scope.cg_scope_leave(state, false)
    state = _analysis_scan_expr(state, try(st.cond), false)
    return state
  end if

  if k == "For" then
    state = _analysis_scan_expr(state, try(st.start), false)
    state = _analysis_scan_expr(state, _analysis_for_end_expr(st), false)
    state = scope.cg_scope_enter(state)
    state = _analysis_register_fresh_local_decl(state, st, st.var)
    hidden_for = _for_state_names(st)
    if typeof(hidden_for) == "array" and len(hidden_for) > 0 then
      for hi_for = 0 to len(hidden_for) - 1
        state = _analysis_register_fresh_local_decl(state, st, hidden_for[hi_for])
      end for
    end if
    state = _analysis_scan_block(state, st.body)
    state = scope.cg_scope_leave(state, false)
    return state
  end if

  if _is_foreach_stmt(st) then
    state = _analysis_scan_expr(state, try(st.iterable), false)
    state = scope.cg_scope_enter(state)
    state = _analysis_register_fresh_local_decl(state, st, st.var)
    hidden = _foreach_state_names(st)
    if typeof(hidden) == "array" and len(hidden) > 0 then
      for hi = 0 to len(hidden) - 1
        state = _analysis_register_fresh_local_decl(state, st, hidden[hi])
      end for
    end if
    state = _analysis_scan_block(state, st.body)
    state = scope.cg_scope_leave(state, false)
    return state
  end if

  if k == "Switch" then
    state = _analysis_scan_expr(state, try(st.expr), false)
    if typeof(st.cases) == "array" and len(st.cases) > 0 then
      sn = len(st.cases)
      for si = 0 to sn - 1
        if si < 0 or si >= sn then break end if
        cs = st.cases[si]
        if typeof(cs) != "struct" then continue end if
        ckind = _coerce_name(try(cs.kind))
        if ckind == "values" then
          vals = try(cs.values)
          if typeof(vals) == "array" and len(vals) > 0 then
            for vi = 0 to len(vals) - 1
              vv = vals[vi]
              if typeof(vv) == "array" and len(vv) >= 2 then
                state = _analysis_scan_expr(state, vv[0], false)
                state = _analysis_scan_expr(state, vv[1], false)
              else
                state = _analysis_scan_expr(state, vv, false)
              end if
            end for
          end if
        else
          state = _analysis_scan_expr(state, try(cs.range_start), false)
          state = _analysis_scan_expr(state, try(cs.range_end), false)
        end if
        state = scope.cg_scope_enter(state)
        state = _analysis_scan_block(state, cs.body)
        state = scope.cg_scope_leave(state, false)
      end for
    end if
    if typeof(st.default_body) == "array" and len(st.default_body) > 0 then
      state = scope.cg_scope_enter(state)
      state = _analysis_scan_block(state, st.default_body)
      state = scope.cg_scope_leave(state, false)
    end if
    return state
  end if

  if k == "FunctionDef" then
    state = _analysis_register_local_decl(state, st, st.name)
    return state
  end if

  return state
end function

function _analysis_scan_block(state, stmts)
  if typeof(stmts) != "array" or len(stmts) <= 0 then return state end if
  n = len(stmts)
  for i = 0 to n - 1
    if i < 0 or i >= n then break end if
    state = _analysis_scan_stmt(state, stmts[i])
  end for
  return state
end function

function _analysis_prepare_function(state, fn_node)
  boxed_names = fn_node._ml_boxed
  if typeof(boxed_names) != "array" then boxed_names = [] end if
  fn_qn_dbg = _coerce_name(fn_node.name)
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and fn_qn_dbg == "std.string.isBlank" then
    print "[dbg][analysis] " + fn_qn_dbg + " enter"
  end if

  saved_stack = state.scope_stack
  saved_declared = state.scope_declared
  saved_idx_stack = state.scope_index_stack
  saved_decl_idx_stack = state.scope_declared_index_stack
  saved_in_fn = state.in_function
  saved_analysis_mode = state.analysis_mode
  saved_var_slots = state.var_slots
  saved_boxed = state.current_fn_boxed_names
  saved_qpref = state.current_qname_prefix
  saved_file_pref = state.current_file_prefix
  saved_qualify = state.qualify_cache
  saved_func_globals = state.func_globals
  saved_func_global_map = state.func_global_map
  saved_func_global_map_index = state.func_global_map_index

  state = scope.analysis_reset_function(state)
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and fn_qn_dbg == "std.string.isBlank" then
    print "[dbg][analysis] " + fn_qn_dbg + " reset_done"
  end if
  state.analysis_mode = true
  state.in_function = true
  state.var_slots = 0
  state.current_fn_boxed_names = boxed_names
  state.qualify_cache = _prepare_qualify_cache(saved_qualify, 2048)
  state.func_globals = []
  state.func_global_map = []
  state.func_global_map_index = t.fastmap_new(64)

  base_globals = []
  base_global_index = t.fastmap_new(128)
  base_decl_index = t.fastmap_new(128)
  if typeof(saved_stack) == "array" and len(saved_stack) > 0 then base_globals = saved_stack[0] end if
  if typeof(saved_idx_stack) == "array" and len(saved_idx_stack) > 0 then base_global_index = saved_idx_stack[0] end if
  if typeof(saved_decl_idx_stack) == "array" and len(saved_decl_idx_stack) > 0 then base_decl_index = saved_decl_idx_stack[0] end if
  state.scope_stack = [base_globals, []]
  state.scope_declared = [[], []]
  state.scope_index_stack = [base_global_index, t.fastmap_new(128)]
  state.scope_declared_index_stack = [base_decl_index, t.fastmap_new(128)]
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and fn_qn_dbg == "std.string.isBlank" then
    print "[dbg][analysis] " + fn_qn_dbg + " scope_setup_done"
  end if

  fn_qn = _coerce_name(fn_node.name)
  if fn_qn != "" and s.contains(fn_qn, ".") then
    parts = s.split(fn_qn, ".")
    qpref = ""
    if len(parts) > 1 then
      for pi = 0 to len(parts) - 2
        segp = _coerce_name(parts[pi])
        if segp == "" then continue end if
        if qpref != "" then qpref = qpref + "." end if
        qpref = qpref + segp
      end for
    end if
    if qpref != "" then
      state.current_qname_prefix = qpref + "."
    else
      state.current_qname_prefix = ""
    end if
  else
    state.current_qname_prefix = ""
  end if
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and fn_qn_dbg == "std.string.isBlank" then
    print "[dbg][analysis] " + fn_qn_dbg + " qprefix_done=" + state.current_qname_prefix
  end if

  fn_file = _st_file(fn_node)
  if typeof(fn_file) == "string" and fn_file != "" then
    state.current_file_prefix = _strpair_get(state.file_prefix_map, fn_file)
  else
    state.current_file_prefix = ""
  end if
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and fn_qn_dbg == "std.string.isBlank" then
    print "[dbg][analysis] " + fn_qn_dbg + " fileprefix_done=" + state.current_file_prefix
  end if

  state = _closure_declare_capture_bindings(state, fn_node)
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and fn_qn_dbg == "std.string.isBlank" then
    print "[dbg][analysis] " + fn_qn_dbg + " capture_bindings_done"
  end if

  if typeof(fn_node.params) == "array" and len(fn_node.params) > 0 then
    pn_count = len(fn_node.params)
    for i = 0 to pn_count - 1
      if i < 0 or i >= pn_count then break end if
      state = scope.bind_param(state, fn_node.params[i], 0, fn_node)
      state = _analysis_mark_current_binding_boxed(state, fn_node.params[i])
    end for
  end if
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and fn_qn_dbg == "std.string.isBlank" then
    print "[dbg][analysis] " + fn_qn_dbg + " params_done"
  end if

  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and fn_qn_dbg == "std.string.isBlank" then
    print "[dbg][analysis] " + fn_qn_dbg + " scan_block_begin"
  end if
  state = _analysis_scan_block(state, fn_node.body)
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and fn_qn_dbg == "std.string.isBlank" then
    print "[dbg][analysis] " + fn_qn_dbg + " scan_block_done"
  end if

  state.scope_stack = saved_stack
  state.scope_declared = saved_declared
  state.scope_index_stack = saved_idx_stack
  state.scope_declared_index_stack = saved_decl_idx_stack
  state.in_function = saved_in_fn
  state.analysis_mode = saved_analysis_mode
  state.var_slots = saved_var_slots
  state.current_fn_boxed_names = saved_boxed
  state.current_qname_prefix = saved_qpref
  state.current_file_prefix = saved_file_pref
  state.qualify_cache = saved_qualify
  state.func_globals = saved_func_globals
  state.func_global_map = saved_func_global_map
  state.func_global_map_index = saved_func_global_map_index
  return state
end function

function _closure_expr_reads(ex, used)
  if typeof(used) != "array" and typeof(used) != "struct" then used = _name_set_new(64) end if
  if typeof(ex) != "struct" then return used end if

  k = ex.node_kind
  if k == "Var" and typeof(ex.name) == "string" then
    return _name_set_add(used, ex.name)
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
  if typeof(locals_set) != "array" and typeof(locals_set) != "struct" then locals_set = _name_set_new(64) end if
  if typeof(globals_decl) != "array" and typeof(globals_decl) != "struct" then globals_decl = _name_set_new(32) end if
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
        if nm != "" then globals_decl = _name_set_add(globals_decl, nm) end if
        j = j + 1
      end while
      continue
    end if

    if k == "Assign" then
      nm2 = _coerce_name(st.name)
      if nm2 != "" and _name_set_has(globals_decl, nm2) == false then
        locals_set = _name_set_add(locals_set, nm2)
      end if
    end if

    if k == "For" then
      v = _coerce_name(st.var)
      if v != "" then locals_set = _name_set_add(locals_set, v) end if
    end if

    if _is_foreach_stmt(st) then
      fv = _foreach_var_name(st)
      if fv != "" then locals_set = _name_set_add(locals_set, fv) end if
    end if

    if k == "FunctionDef" then
      nested = _arr_add_unique(nested, st)
      fnn = _coerce_name(st.name)
      if fnn != "" then locals_set = _name_set_add(locals_set, fnn) end if
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
  locals_set = _name_set_new(32)
  globals_decl = _name_set_new(16)
  nested = []
  if typeof(fn_node) != "struct" then return [locals_set, globals_decl, nested] end if

  if typeof(fn_node.params) == "array" and len(fn_node.params) > 0 then
    for i = 0 to len(fn_node.params) - 1
      if i < 0 or i >= len(fn_node.params) then break end if
      nm = _coerce_name(fn_node.params[i])
      if nm != "" then locals_set = _name_set_add(locals_set, nm) end if
    end for
  end if

  body = fn_node.body
  if typeof(body) != "array" then body = [] end if
  return _closure_collect_locals_walk(body, locals_set, globals_decl, nested)
end function

function _closure_collect_uses(stmts)
  used = _name_set_new(64)
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
      used = _name_set_union(used, _closure_collect_uses(st.then_body))
      if typeof(st.elifs) == "array" and len(st.elifs) > 0 then
        ei = 0
        en = len(st.elifs)
        while ei < en
          eb = st.elifs[ei]
          if typeof(eb) == "array" and len(eb) >= 1 then
            used = _closure_expr_reads(eb[0], used)
          end if
          if typeof(eb) == "array" and len(eb) >= 2 and typeof(eb[1]) == "array" then
            used = _name_set_union(used, _closure_collect_uses(eb[1]))
          end if
          ei = ei + 1
        end while
      end if
      used = _name_set_union(used, _closure_collect_uses(st.else_body))
      continue
    end if

    if k == "While" then
      used = _closure_expr_reads(st.cond, used)
      used = _name_set_union(used, _closure_collect_uses(st.body))
      continue
    end if

    if k == "DoWhile" then
      used = _name_set_union(used, _closure_collect_uses(st.body))
      used = _closure_expr_reads(st.cond, used)
      continue
    end if

    if k == "For" then
      used = _closure_expr_reads(st.start, used)
      used = _closure_expr_reads(st.end_expr, used)
      used = _name_set_union(used, _closure_collect_uses(st.body))
      continue
    end if

    if _is_foreach_stmt(st) then
      used = _closure_expr_reads(st.iterable, used)
      used = _name_set_union(used, _closure_collect_uses(st.body))
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
          used = _name_set_union(used, _closure_collect_uses(cs.body))
          ci = ci + 1
        end while
      end if
      used = _name_set_union(used, _closure_collect_uses(st.default_body))
      continue
    end if
  end while

  return used
end function

function _closure_collect_writes(fn_node)
  written = _name_set_new(64)
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
      written = _name_set_add(written, st.name)
      continue
    end if

    if k == "If" then
      written = _name_set_union(written, _closure_collect_writes(st.then_body))
      if typeof(st.elifs) == "array" and len(st.elifs) > 0 then
        ei = 0
        en = len(st.elifs)
        while ei < en
          eb = st.elifs[ei]
          if typeof(eb) == "array" and len(eb) >= 2 and typeof(eb[1]) == "array" then
            written = _name_set_union(written, _closure_collect_writes(eb[1]))
          end if
          ei = ei + 1
        end while
      end if
      written = _name_set_union(written, _closure_collect_writes(st.else_body))
      continue
    end if

    if k == "While" or k == "DoWhile" or k == "For" or _is_foreach_stmt(st) then
      written = _name_set_union(written, _closure_collect_writes(st.body))
      continue
    end if

    if k == "Switch" then
      if typeof(st.cases) == "array" and len(st.cases) > 0 then
        ci = 0
        cn = len(st.cases)
        while ci < cn
          cs = st.cases[ci]
          if typeof(cs) == "struct" then
            written = _name_set_union(written, _closure_collect_writes(cs.body))
          end if
          ci = ci + 1
        end while
      end if
      written = _name_set_union(written, _closure_collect_writes(st.default_body))
      continue
    end if
  end while

  return written
end function

function _note_reads(read_before, written_yet, names)
  if typeof(read_before) != "array" and typeof(read_before) != "struct" then read_before = _name_set_new(64) end if
  if typeof(written_yet) != "array" and typeof(written_yet) != "struct" then written_yet = _name_set_new(32) end if
  if typeof(names) == "struct" then names = _name_set_to_array(names) end if
  if typeof(names) != "array" or len(names) <= 0 then return read_before end if
  for i = 0 to len(names) - 1
    if i < 0 or i >= len(names) then break end if
    nm = names[i]
    if typeof(nm) != "string" or nm == "" then continue end if
    if _name_set_has(written_yet, nm) then continue end if
    read_before = _name_set_add(read_before, nm)
  end for
  return read_before
end function

function _closure_collect_rbfw_walk(stmts, read_before, written_yet)
  if typeof(read_before) != "array" and typeof(read_before) != "struct" then read_before = _name_set_new(64) end if
  if typeof(written_yet) != "array" and typeof(written_yet) != "struct" then written_yet = _name_set_new(32) end if
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
      rr = _closure_expr_reads(st.expr, _name_set_new(16))
      read_before = _note_reads(read_before, written_yet, rr)
      nm = _coerce_name(st.name)
      if nm != "" then written_yet = _name_set_add(written_yet, nm) end if
      continue
    end if

    if k == "Print" or k == "ExprStmt" or k == "Return" then
      rr2 = _closure_expr_reads(st.expr, _name_set_new(16))
      read_before = _note_reads(read_before, written_yet, rr2)
      continue
    end if

    if k == "SetMember" then
      rr3 = _name_set_new(16)
      tgt = st.obj
      if typeof(tgt) != "struct" then tgt = st.target end if
      rr3 = _closure_expr_reads(tgt, rr3)
      rr3 = _closure_expr_reads(st.expr, rr3)
      read_before = _note_reads(read_before, written_yet, rr3)
      continue
    end if

    if k == "SetIndex" then
      rr4 = _name_set_new(16)
      rr4 = _closure_expr_reads(st.target, rr4)
      rr4 = _closure_expr_reads(st.index, rr4)
      rr4 = _closure_expr_reads(st.expr, rr4)
      read_before = _note_reads(read_before, written_yet, rr4)
      continue
    end if

    if k == "If" then
      rc = _closure_expr_reads(st.cond, _name_set_new(16))
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
            rc2 = _closure_expr_reads(eb[0], _name_set_new(16))
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
      rc3 = _closure_expr_reads(st.cond, _name_set_new(16))
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
      rc4 = _closure_expr_reads(st.cond, _name_set_new(16))
      read_before = _note_reads(read_before, written_yet, rc4)
      continue
    end if

    if k == "For" then
      rr5 = _name_set_new(16)
      rr5 = _closure_expr_reads(st.start, rr5)
      rr5 = _closure_expr_reads(st.end_expr, rr5)
      read_before = _note_reads(read_before, written_yet, rr5)
      v = _coerce_name(st.var)
      if v != "" then written_yet = _name_set_add(written_yet, v) end if
      sub6 = _closure_collect_rbfw_walk(st.body, read_before, written_yet)
      read_before = sub6[0]
      written_yet = sub6[1]
      continue
    end if

    if _is_foreach_stmt(st) then
      rr6 = _closure_expr_reads(st.iterable, _name_set_new(16))
      read_before = _note_reads(read_before, written_yet, rr6)
      fv = _foreach_var_name(st)
      if fv != "" then written_yet = _name_set_add(written_yet, fv) end if
      sub7 = _closure_collect_rbfw_walk(st.body, read_before, written_yet)
      read_before = sub7[0]
      written_yet = sub7[1]
      continue
    end if

    if k == "Switch" then
      rr7 = _closure_expr_reads(st.expr, _name_set_new(16))
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
              rr8 = _closure_expr_reads(cs.values[vi], _name_set_new(16))
              read_before = _note_reads(read_before, written_yet, rr8)
              vi = vi + 1
            end while
          else
            rr9 = _name_set_new(16)
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
  written_yet = _name_set_new(32)
  if typeof(params_set) == "struct" then params_set = _name_set_to_array(params_set) end if
  if typeof(params_set) == "array" and len(params_set) > 0 then
    for i = 0 to len(params_set) - 1
      if i < 0 or i >= len(params_set) then break end if
      nm = _coerce_name(params_set[i])
      if nm != "" then written_yet = _name_set_add(written_yet, nm) end if
    end for
  end if
  res = _closure_collect_rbfw_walk(stmts, _name_set_new(64), written_yet)
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

  params_set = _name_set_new(16)
  if typeof(fn_node.params) == "array" and len(fn_node.params) > 0 then
    for pi = 0 to len(fn_node.params) - 1
      pn = _coerce_name(fn_node.params[pi])
      if pn != "" then params_set = _name_set_add(params_set, pn) end if
    end for
  end if
  read_before_write = _closure_collect_read_before_first_write(body_stmts, params_set)

  captures = _name_set_new(16)
  capture_depth = t.fastmap_new(16)

  write_names = _name_set_to_array(writes)
  if len(write_names) > 0 and len(outer_scopes) > 0 then
    for i = 0 to len(write_names) - 1
      name = write_names[i]
      if typeof(name) != "string" or name == "" then continue end if
      if _name_set_has(params_set, name) then continue end if
      if _name_set_has(globals_decl, name) then continue end if
      if _has_dot_name(name) then continue end if
      if _name_set_has(read_before_write, name) == false then continue end if
      for d = 0 to len(outer_scopes) - 1
        oscope = outer_scopes[d]
        if _name_set_has(oscope, name) then
          locals_set = _name_set_remove(locals_set, name)
          captures = _name_set_add(captures, name)
          capture_depth = _map_int_set(capture_depth, name, d + 1)
          break
        end if
      end for
    end for
  end if

  uw = _name_set_union(uses, writes)
  uw_names = _name_set_to_array(uw)
  if len(uw_names) > 0 and len(outer_scopes) > 0 then
    for i = 0 to len(uw_names) - 1
      nm = uw_names[i]
      if typeof(nm) != "string" or nm == "" then continue end if
      if _name_set_has(locals_set, nm) then continue end if
      if _name_set_has(globals_decl, nm) then continue end if
      if _has_dot_name(nm) then continue end if
      if _name_set_has(captures, nm) then continue end if
      for d2 = 0 to len(outer_scopes) - 1
        os2 = outer_scopes[d2]
        if _name_set_has(os2, nm) then
          captures = _name_set_add(captures, nm)
          capture_depth = _map_int_set(capture_depth, nm, d2 + 1)
          break
        end if
      end for
    end for
  end if

  fn_node._ml_locals = _sort_names(locals_set)
  fn_node._ml_globals_declared = _sort_names(globals_decl)
  fn_node._ml_captures = _sort_names(captures)
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
      if typeof(fn._ml_env_index) != "array" and typeof(fn._ml_env_index) != "struct" then fn._ml_env_index = [] end if
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
      env_index = t.fastmap_new((len(slots) * 2) + 16)
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
      cap_idx = t.fastmap_new(16)
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
      cdepth_items = _map_int_items(cdepth3)
      if typeof(cdepth_items) != "array" or len(cdepth_items) <= 0 then continue end if
      for ci3 = 0 to len(cdepth_items) - 1
        it = cdepth_items[ci3]
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

function inline _as_name(v)
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
    sis = state.scope_index_stack
    if typeof(sis) == "array" and si >= 0 and si < len(sis) then
      fm = sis[si]
      fm = t.fastmap_set(fm, b.name, b)
      sis[si] = fm
      state.scope_index_stack = sis
    end if
  end for

  return state
end function

function emit_stmt(state, st)
  return cg_emit_stmt(state, st)
end function

function inline _user_function_has(state, qname)
  if typeof(state.user_function_index) == "struct" then
    idx0 = t.fastmap_get(state.user_function_index, qname, -1)
    if typeof(idx0) == "int" and idx0 >= 0 then return true end if
  end if
  arr = state.user_functions
  if typeof(arr) != "array" or len(arr) <= 0 then return false end if
  for i = 0 to len(arr) - 1
    p = arr[i]
    if typeof(p) == "array" and len(p) == 2 and p[0] == qname then
      if typeof(state.user_function_index) != "struct" then
        state.user_function_index = t.fastmap_new(256)
      end if
      state.user_function_index = t.fastmap_set(state.user_function_index, qname, i)
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

function inline _named_array_get(arr, key)
  if typeof(arr) == "struct" then return t.fastmap_get(arr, key, 0) end if
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
  if typeof(arr) == "struct" then return t.fastmap_set(arr, key, values) end if
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

function inline _named_int_get(arr, key, defaultv)
  if typeof(arr) == "struct" then
    v0 = t.fastmap_get(arr, key, defaultv)
    if typeof(v0) == "int" then return v0 end if
    return defaultv
  end if
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
  if typeof(arr) == "struct" then return t.fastmap_set(arr, key, value) end if
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

function inline _st_file(st)
  if typeof(st) == "struct" and typeof(st._filename) == "string" then return st._filename end if
  return ""
end function

function inline _has_dot_name(name)
  if typeof(name) != "string" then return false end if
  for i = 0 to len(name) - 1
    if name[i] == "." then return true end if
  end for
  return false
end function

function inline _strpair_get(arr, key)
  if typeof(arr) == "struct" then
    v0 = t.fastmap_get(arr, key, "")
    if typeof(v0) == "string" then return v0 end if
    return ""
  end if
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
  mapv = arr
  if typeof(mapv) != "struct" then
    mapv = t.fastmap_new(64)
    if typeof(arr) == "array" and len(arr) > 0 then
      for i = 0 to len(arr) - 1
        it = arr[i]
        if typeof(it) == "struct" and typeof(it.key) == "string" and typeof(it.value) == "string" then
          mapv = t.fastmap_set(mapv, it.key, it.value)
        end if
        if typeof(it) == "array" and len(it) >= 2 and typeof(it[0]) == "string" and typeof(it[1]) == "string" then
          mapv = t.fastmap_set(mapv, it[0], it[1])
        end if
      end for
    end if
  end if
  return t.fastmap_set(mapv, key, value)
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
      mdict_nonempty = false
      if typeof(mdict) == "array" and len(mdict) > 0 then mdict_nonempty = true end if
      if typeof(mdict) == "struct" and t.fastmap_size(mdict) > 0 then mdict_nonempty = true end if
      if mdict_nonempty then
        state.struct_methods = _named_array_set(state.struct_methods, sqn, mdict)
      end if
      sdict_nonempty = false
      if typeof(sdict) == "array" and len(sdict) > 0 then sdict_nonempty = true end if
      if typeof(sdict) == "struct" and t.fastmap_size(sdict) > 0 then sdict_nonempty = true end if
      if sdict_nonempty then
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
    ["copyBytes", 5, 5, "fn_builtin_copyBytes"],
    ["fillBytes", 4, 4, "fn_builtin_fillBytes"],
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

function _reindex_named_array(arr, cap_hint)
  cap = cap_hint
  if typeof(cap) != "int" or cap < 64 then cap = 64 end if
  idx = t.fastmap_new(cap)
  if typeof(arr) != "array" or len(arr) <= 0 then return idx end if
  for i = 0 to len(arr) - 1
    it = arr[i]
    k = ""
    v = 0
    if typeof(it) == "struct" then
      k = _coerce_name(it.key)
      v = it.values
    else
      if typeof(it) == "array" and len(it) >= 2 then
        k = _coerce_name(it[0])
        v = it[1]
      end if
    end if
    if k == "" then continue end if
    idx = t.fastmap_set(idx, k, v)
  end for
  return idx
end function

function _reindex_named_int(arr, cap_hint)
  cap = cap_hint
  if typeof(cap) != "int" or cap < 64 then cap = 64 end if
  idx = t.fastmap_new(cap)
  if typeof(arr) != "array" or len(arr) <= 0 then return idx end if
  for i = 0 to len(arr) - 1
    it = arr[i]
    k = ""
    v = 0
    if typeof(it) == "struct" then
      if typeof(it.value) == "int" then
        k = _coerce_name(it.key)
        v = it.value
      end if
    else
      if typeof(it) == "array" and len(it) >= 2 and typeof(it[1]) == "int" then
        k = _coerce_name(it[0])
        v = it[1]
      end if
    end if
    if k == "" then continue end if
    idx = t.fastmap_set(idx, k, v)
  end for
  return idx
end function

function _reindex_extern_sigs(arr, cap_hint)
  cap = cap_hint
  if typeof(cap) != "int" or cap < 64 then cap = 64 end if
  idx = t.fastmap_new(cap)
  if typeof(arr) != "array" or len(arr) <= 0 then return idx end if
  for i = 0 to len(arr) - 1
    it = arr[i]
    if typeof(it) != "struct" then continue end if
    qn = _coerce_name(it.qname)
    nm = _coerce_name(it.name)
    if qn != "" then idx = t.fastmap_set(idx, qn, it) end if
    if nm != "" then idx = t.fastmap_set(idx, nm, it) end if
  end for
  return idx
end function

function _reindex_aliases(arr, cap_hint)
  cap = cap_hint
  if typeof(cap) != "int" or cap < 32 then cap = 32 end if
  idx = t.fastmap_new(cap)
  if typeof(arr) != "array" or len(arr) <= 0 then return idx end if
  for i = 0 to len(arr) - 1
    it = arr[i]
    k = ""
    v = ""
    if typeof(it) == "struct" then
      k = _coerce_name(it.key)
      v = _coerce_name(it.value)
    else
      if typeof(it) == "array" and len(it) >= 2 then
        k = _coerce_name(it[0])
        v = _coerce_name(it[1])
      end if
    end if
    if k == "" or v == "" then continue end if
    idx = t.fastmap_set(idx, k, v)
  end for
  return idx
end function

function _rebuild_lookup_indexes(state)
  n_sf = 0
  if typeof(state.struct_fields) == "array" then n_sf = len(state.struct_fields) end if
  n_sid = 0
  if typeof(state.struct_ids) == "array" then n_sid = len(state.struct_ids) end if
  n_ev = 0
  if typeof(state.enum_variants) == "array" then n_ev = len(state.enum_variants) end if
  n_eid = 0
  if typeof(state.enum_ids) == "array" then n_eid = len(state.enum_ids) end if
  n_sm = 0
  if typeof(state.struct_methods) == "array" then n_sm = len(state.struct_methods) end if
  n_ssm = 0
  if typeof(state.struct_static_methods) == "array" then n_ssm = len(state.struct_static_methods) end if
  n_ex = 0
  if typeof(state.extern_sigs) == "array" then n_ex = len(state.extern_sigs) end if
  n_al = 0
  if typeof(state.import_aliases) == "array" then n_al = len(state.import_aliases) end if

  state.struct_fields_index = _reindex_named_array(state.struct_fields, (n_sf * 2) + 64)
  state.struct_ids_index = _reindex_named_int(state.struct_ids, (n_sid * 2) + 64)
  state.enum_variants_index = _reindex_named_array(state.enum_variants, (n_ev * 2) + 64)
  state.enum_ids_index = _reindex_named_int(state.enum_ids, (n_eid * 2) + 64)
  state.struct_methods_index = _reindex_named_array(state.struct_methods, (n_sm * 2) + 64)
  state.struct_static_methods_index = _reindex_named_array(state.struct_static_methods, (n_ssm * 2) + 64)
  state.extern_sig_index = _reindex_extern_sigs(state.extern_sigs, (n_ex * 3) + 64)
  state.import_alias_index = _reindex_aliases(state.import_aliases, (n_al * 2) + 32)
  return state
end function

function emit_program(state, program)
  state.extern_structs = []
  state.value_enum_values = []
  state.user_function_index = t.fastmap_new(256)
  state.function_codegen_name_map = t.fastmap_new(512)
  state.qualify_cache = _prepare_qualify_cache(state.qualify_cache, 4096)
  nsid = _next_struct_id(state)
  neid = _next_enum_id(state)
  decl_file_prefixes = t.fastmap_new(64)
  decl_seen_nonpackage = t.fastmap_new(64)
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
  state = _rebuild_lookup_indexes(state)
  state = _mem_probe(state, "decls_done")

  state.file_prefix_map = decl_file_prefixes
  state.nested_user_functions = []
  // Closure analysis metadata (captures/env layout) for nested functions.
  state = _closure_analyze_program(state, program)
  if typeof(state.user_functions) == "array" and len(state.user_functions) > 0 then
    for ufi = 0 to len(state.user_functions) - 1
      uf_it = state.user_functions[ufi]
      if typeof(uf_it) != "array" or len(uf_it) != 2 then continue end if
      if typeof(uf_it[0]) != "string" or typeof(uf_it[1]) != "struct" then continue end if
      uf_node = uf_it[1]
      state = _set_fn_codegen_name(state, uf_node, uf_it[0])
    end for
  end if
  if typeof(state.nested_user_functions) == "array" and len(state.nested_user_functions) > 0 then
    nested_counter = 1
    for nfi = 0 to len(state.nested_user_functions) - 1
      nf = state.nested_user_functions[nfi]
      if typeof(nf) != "struct" then continue end if
      parent = nf._ml_parent_fn
      parent_code = "toplevel"
      if typeof(parent) == "struct" then
        parent_code = _fn_codegen_name(state, parent)
        if parent_code == "" then parent_code = _coerce_name(parent.name) end if
      end if
      base = _coerce_name(nf.name)
      if base == "" then base = "fn" end if
      state = _set_fn_codegen_name(state, nf, parent_code + "__" + base + "__n" + nested_counter)
      nested_counter = nested_counter + 1
    end for
  end if
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
  // Match Python codegen: reserve global callable/type slots before static object
  // materialization so label order stays stable when externs are present.
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

  if typeof(state.struct_fields) == "array" and len(state.struct_fields) > 0 then
    for si = 0 to len(state.struct_fields) - 1
      sf = state.struct_fields[si]
      sqn = ""
      if typeof(sf) == "struct" then sqn = _coerce_name(sf.key) end if
      if typeof(sf) == "array" and len(sf) >= 2 then sqn = _coerce_name(sf[0]) end if
      if sqn == "" then continue end if
      if _arr_has(state.reserved_identifiers, sqn) then continue end if
      r1 = _ensure_global_binding_label(state, sqn, 0)
      state = r1[0]
      lbl1 = r1[1]
      if lbl1 != "" then
        state.struct_global_labels = _strpair_set(state.struct_global_labels, sqn, lbl1)
      end if
    end for
  end if

  if typeof(state.builtin_specs) == "array" and len(state.builtin_specs) > 0 then
    for bi = 0 to len(state.builtin_specs) - 1
      sp = state.builtin_specs[bi]
      if typeof(sp) != "array" or len(sp) < 4 then continue end if
      bname = _coerce_name(sp[0])
      if bname == "" then continue end if
      if _arr_has(state.reserved_identifiers, bname) then continue end if
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
  state.typename_struct_by_id = _sort_id_label_pairs(t.arr_chunk_finish(typename_struct_by_id_b))

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
  state.typename_enum_by_id = _sort_id_label_pairs(t.arr_chunk_finish(typename_enum_by_id_b))
  // Materialize immutable first-class callable/type objects in .rdata.
  state.function_static_obj_labels = []
  if typeof(state.user_functions) == "array" and len(state.user_functions) > 0 then
    for i = 0 to len(state.user_functions) - 1
      it = state.user_functions[i]
      if typeof(it) != "array" or len(it) != 2 then continue end if
      fn_qn = _coerce_name(it[0])
      fn_node = it[1]
      if fn_qn == "" then continue end if
      arity = 0
      if typeof(fn_node) == "struct" and typeof(fn_node.params) == "array" then arity = len(fn_node.params) end if
      obj_lbl = "obj_fn_static_" + len(state.rdata.labels)
      state.rdata = d.rdata_pad_align(state.rdata, 8)
      state.rdata = d.rdata_add_bytes_unique(state.rdata, obj_lbl, t.u32(c.OBJ_FUNCTION) + t.u32(arity) + bytes(8, 0))
      off = _rdata_label_offset(state.rdata, obj_lbl)
      if off >= 0 then
        state.rdata = d.rdata_add_abs64_patch(state.rdata, off + 8, "fn_user_" + fn_qn)
        state.function_static_obj_labels = _strpair_set(state.function_static_obj_labels, fn_qn, obj_lbl)
      end if
    end for
  end if

  state.struct_static_obj_labels = []
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
      sid = _named_int_get(state.struct_ids, sqn, 0)
      obj_lbl = "obj_structtype_static_" + len(state.rdata.labels)
      state.rdata = d.rdata_pad_align(state.rdata, 8)
      state.rdata = d.rdata_add_bytes_unique(state.rdata, obj_lbl, t.u32(c.OBJ_STRUCTTYPE) + t.u32(len(flds)) + t.u32(sid) + t.u32(0))
      state.struct_static_obj_labels = _strpair_set(state.struct_static_obj_labels, sqn, obj_lbl)
    end for
  end if

  state.builtin_static_obj_labels = []
  if typeof(state.builtin_specs) == "array" and len(state.builtin_specs) > 0 then
    for bi = 0 to len(state.builtin_specs) - 1
      sp = state.builtin_specs[bi]
      if typeof(sp) != "array" or len(sp) < 4 then continue end if
      bname = _coerce_name(sp[0])
      if bname == "" then continue end if
      min_a = sp[1]
      max_a = sp[2]
      blbl = _coerce_name(sp[3])
      if blbl == "" then continue end if
      obj_lbl = "obj_builtin_static_" + len(state.rdata.labels)
      state.rdata = d.rdata_pad_align(state.rdata, 8)
      state.rdata = d.rdata_add_bytes_unique(state.rdata, obj_lbl, t.u32(c.OBJ_BUILTIN) + t.u32(min_a) + t.u32(max_a) + t.u32(0) + bytes(8, 0))
      off = _rdata_label_offset(state.rdata, obj_lbl)
      if off >= 0 then
        state.rdata = d.rdata_add_abs64_patch(state.rdata, off + 16, blbl)
        state.builtin_static_obj_labels = _strpair_set(state.builtin_static_obj_labels, bname, obj_lbl)
        state.used_helpers = add(state.used_helpers, blbl)
      end if
    end for
  end if
  state.extern_global_labels = []
  state.extern_stub_labels = []
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
  state.extern_static_obj_labels = []
  if typeof(state.extern_sigs) == "array" and len(state.extern_sigs) > 0 then
    for ei = 0 to len(state.extern_sigs) - 1
      sig = state.extern_sigs[ei]
      if typeof(sig) != "struct" then continue end if
      qn = _coerce_name(sig.qname)
      if qn == "" then qn = _coerce_name(sig.name) end if
      if qn == "" then continue end if
      stub_lbl = _strpair_get(state.extern_stub_labels, qn)
      if stub_lbl == "" then continue end if
      arity = 0
      if typeof(sig.params) == "array" then arity = len(sig.params) end if
      obj_lbl = "obj_extern_static_" + len(state.rdata.labels)
      state.rdata = d.rdata_pad_align(state.rdata, 8)
      state.rdata = d.rdata_add_bytes_unique(state.rdata, obj_lbl, t.u32(c.OBJ_BUILTIN) + t.u32(arity) + t.u32(arity) + t.u32(0) + bytes(8, 0))
      off = _rdata_label_offset(state.rdata, obj_lbl)
      if off >= 0 then
        state.rdata = d.rdata_add_abs64_patch(state.rdata, off + 16, stub_lbl)
        state.extern_static_obj_labels = _strpair_set(state.extern_static_obj_labels, qn, obj_lbl)
      end if
    end for
  end if
  state.callprof_entries = []
  state.callprof_index = []
  state.callprof_name_labels = []
  state.callprof_n = 0

  if state.call_profile then
    cp_entries_b = t.arr_chunk_new(64)
    cp_user_names = _user_function_keys_sorted(state)
    if len(cp_user_names) > 0 then
      for cpi = 0 to len(cp_user_names) - 1
        cp_name = cp_user_names[cpi]
        cp_fn = _user_function_get_node(state, cp_name)
        cp_code = _fn_codegen_name(state, cp_fn)
        if cp_code == "" then cp_code = cp_name end if
        cp_entries_b = t.arr_chunk_push(cp_entries_b, [cp_code, cp_name])
      end for
    end if
    cp_nested_names = _nested_function_codegen_names_sorted(state)
    if len(cp_nested_names) > 0 then
      for cpi2 = 0 to len(cp_nested_names) - 1
        cp_code2 = cp_nested_names[cpi2]
        cp_fn2 = _nested_function_get_by_codegen_name(state, cp_code2)
        cp_disp2 = ""
        if typeof(cp_fn2) == "struct" then cp_disp2 = _coerce_name(cp_fn2.name) end if
        if cp_disp2 == "" then cp_disp2 = cp_code2 end if
        cp_entries_b = t.arr_chunk_push(cp_entries_b, [cp_code2, cp_disp2])
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
      if _arr_has(state.reserved_identifiers, sqn) then continue end if
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
      if _arr_has(state.reserved_identifiers, bname) then continue end if
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

  state = _mem_probe(state, "pre_flatten")

  program = _flatten_runtime(state, program)
  state = _mem_probe(state, "flatten_done")

  // Track owning file for flattened top-level globals.
  state._global_owner_file = t.fastmap_new(256)
  state._module_init_status_labels = t.fastmap_new(64)
  state._module_init_active = false
  state._module_init_active_file = ""
  if typeof(program) == "array" and len(program) > 0 then
    for pgi = 0 to len(program) - 1
      pst = program[pgi]
      if typeof(pst) != "struct" then continue end if
      pst_file = _st_file(pst)
      if pst_file == "" then continue end if
      if pst.node_kind != "Assign" and pst.node_kind != "ConstDecl" then continue end if
      pst_name = _coerce_name(pst.name)
      if pst_name == "" then continue end if
      state._global_owner_file = _strpair_set(state._global_owner_file, pst_name, pst_file)
    end for
  end if
  state = _mem_probe(state, "owner_map_done")

  // Match Python codegen: reserve only globals referenced by `global ...`
  // declarations inside functions before module-init flags are allocated.
  if typeof(state.user_functions) == "array" and len(state.user_functions) > 0 then
    for sfi = 0 to len(state.user_functions) - 1
      uf_scan = state.user_functions[sfi]
      if typeof(uf_scan) != "array" or len(uf_scan) != 2 then continue end if
      if typeof(uf_scan[1]) != "struct" then continue end if
      state = _scan_function_for_global_decls(state, uf_scan[1])
    end for
  end if
  if typeof(state.nested_user_functions) == "array" and len(state.nested_user_functions) > 0 then
    for sni = 0 to len(state.nested_user_functions) - 1
      nf_scan = state.nested_user_functions[sni]
      if typeof(nf_scan) != "struct" then continue end if
      state = _scan_function_for_global_decls(state, nf_scan)
    end for
  end if
  state = _mem_probe(state, "func_globals_bound")

  if _heap_cfg_get_bool(state, "cg_semantic_pass", false) then
    state = _check_program_semantics(state, program)
    state = _mem_probe(state, "semantic_done")
  end if

  module_init_recs_b = t.arr_chunk_new(64)
  cur_mod_file = ""
  cur_mod_items_b = t.arr_chunk_new(64)
  cur_mod_count = 0
  mod_index = 0
  if typeof(program) == "array" and len(program) > 0 then
    for pmi = 0 to len(program) - 1
      pst2 = program[pmi]
      mod_file = _st_file(pst2)
      if mod_file == "" then mod_file = "<module:entry>" end if
      if cur_mod_count <= 0 then cur_mod_file = mod_file end if
      if cur_mod_count > 0 and mod_file != cur_mod_file then
        mod_index = mod_index + 1
        mstmts = t.arr_chunk_finish(cur_mod_items_b)
        fn_lbl = "modinit_" + mod_index
        flag_lbl = "modinit_done_" + mod_index
        status_lbl = "modinit_status_" + mod_index
        state.data = d.data_add_u64(state.data, flag_lbl, 0)
        state.data = d.data_add_u64(state.data, status_lbl, 0)
        state._module_init_status_labels = _strpair_set(state._module_init_status_labels, cur_mod_file, status_lbl)
        module_init_recs_b = t.arr_chunk_push(module_init_recs_b, [cur_mod_file, mstmts, fn_lbl, flag_lbl, status_lbl])
        cur_mod_file = mod_file
        cur_mod_items_b = t.arr_chunk_new(64)
        cur_mod_count = 0
      end if
      cur_mod_items_b = t.arr_chunk_push(cur_mod_items_b, pst2)
      cur_mod_count = cur_mod_count + 1
    end for
  end if
  if cur_mod_count > 0 then
    mod_index = mod_index + 1
    mstmts2 = t.arr_chunk_finish(cur_mod_items_b)
    fn_lbl2 = "modinit_" + mod_index
    flag_lbl2 = "modinit_done_" + mod_index
    status_lbl2 = "modinit_status_" + mod_index
    state.data = d.data_add_u64(state.data, flag_lbl2, 0)
    state.data = d.data_add_u64(state.data, status_lbl2, 0)
    state._module_init_status_labels = _strpair_set(state._module_init_status_labels, cur_mod_file, status_lbl2)
    module_init_recs_b = t.arr_chunk_push(module_init_recs_b, [cur_mod_file, mstmts2, fn_lbl2, flag_lbl2, status_lbl2])
  end if
  module_init_recs = t.arr_chunk_finish(module_init_recs_b)
  state = _mem_probe(state, "module_init_recs_done")

  max_call_args_main = max_calls_stmts(state, program)
  if typeof(max_call_args_main) != "int" or max_call_args_main < 0 then max_call_args_main = 0 end if
  program = []
  out_stack_args = max_call_args_main - 4
  if out_stack_args < 0 then out_stack_args = 0 end if
  out_reserve = out_stack_args * 8
  if out_reserve < 8 then out_reserve = 8 end if
  state.call_temp_base = t.align_up(0x20 + out_reserve, 16)
  call_temp_bytes = max_call_args_main * 8
  if call_temp_bytes < 0x40 then call_temp_bytes = 0x40 end if
  call_temp_bytes = t.align_up(call_temp_bytes, 16)
  state.expr_temp_base = state.call_temp_base + call_temp_bytes
  state.expr_temp_top = 0
  frame_end = state.expr_temp_base + state.expr_temp_max
  // Entry RSP is 8 mod 16 on Windows process start.
  main_frame = t.align_to_mod(frame_end + 0x20, 16, 8)
  state.asm = a.sub_rsp_imm32(state.asm, main_frame)

  if state.is_windows_subsystem then
    state.asm = a.mov_rax_rip_qword(state.asm, "iat_FreeConsole")
    state.asm = a.call_rax(state.asm)
  end if

  // stdout handle in rbx
  state.asm = a.mov_rcx_imm32(state.asm, 0xFFFFFFF5)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_GetStdHandle")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_r64_r64(state.asm, "rbx", "rax")

  // UTF-8 console mode
  if state.is_windows_subsystem == false then
    state.asm = a.mov_rcx_imm32(state.asm, 65001)
    state.asm = a.mov_rax_rip_qword(state.asm, "iat_SetConsoleOutputCP")
    state.asm = a.call_rax(state.asm)
  end if

  // Heap / GC init
  state = mem.emit_heap_init(state, 0)
  state.asm = a.call(state.asm, "fn_cpu_init")

  // Point global callable/type slots at immutable .rdata objects.
  if typeof(state.user_functions) == "array" and len(state.user_functions) > 0 then
    for i = 0 to len(state.user_functions) - 1
      itf = state.user_functions[i]
      if typeof(itf) != "array" or len(itf) != 2 then continue end if
      fn_qn = _coerce_name(itf[0])
      fn_node = itf[1]
      if fn_qn == "" or typeof(fn_node) != "struct" then continue end if
      lblf = _strpair_get(state.function_global_labels, fn_qn)
      if lblf == "" then continue end if
      objf = _strpair_get(state.function_static_obj_labels, fn_qn)
      if objf == "" then continue end if
      state.asm = a.lea_rax_rip(state.asm, objf)
      state.asm = a.mov_rip_qword_rax(state.asm, lblf)
    end for
  end if

  // Point struct globals at immutable .rdata objects.
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
      objs = _strpair_get(state.struct_static_obj_labels, sqn)
      if objs == "" then continue end if
      state.asm = a.lea_rax_rip(state.asm, objs)
      state.asm = a.mov_rip_qword_rax(state.asm, lbls)
    end for
  end if

  // Point builtin globals at immutable .rdata objects.
  if typeof(state.builtin_specs) == "array" and len(state.builtin_specs) > 0 then
    for bi = 0 to len(state.builtin_specs) - 1
      sp = state.builtin_specs[bi]
      if typeof(sp) != "array" or len(sp) < 4 then continue end if
      bname = _coerce_name(sp[0])
      blbl = _coerce_name(sp[3])
      if bname == "" or blbl == "" then continue end if
      gbl = _strpair_get(state.builtin_global_labels, bname)
      if gbl == "" then continue end if
      objb = _strpair_get(state.builtin_static_obj_labels, bname)
      if objb == "" then continue end if
      state.used_helpers = add(state.used_helpers, blbl)
      state.asm = a.lea_rax_rip(state.asm, objb)
      state.asm = a.mov_rip_qword_rax(state.asm, gbl)
    end for
  end if

  // Point extern globals at immutable .rdata objects.
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
      obja = _strpair_get(state.extern_static_obj_labels, qn)
      if obja == "" then continue end if
      state.asm = a.lea_rax_rip(state.asm, obja)
      state.asm = a.mov_rip_qword_rax(state.asm, gbl2)
    end for
  end if
  state = _mem_probe(state, "static_globals_done")

  // Emit per-file module init blocks inline inside the entry frame.
  state = core.push_cold_block_scope(state)
  if typeof(module_init_recs) == "array" and len(module_init_recs) > 0 then
    for mri = 0 to len(module_init_recs) - 1
      mr = module_init_recs[mri]
      if typeof(mr) != "array" or len(mr) < 5 then continue end if
      mfile2 = _coerce_name(mr[0])
      mstmts2 = mr[1]
      fn_lbl2 = _coerce_name(mr[2])
      flag_lbl2 = _coerce_name(mr[3])
      status_lbl2 = _coerce_name(mr[4])
      done_lbl2 = fn_lbl2 + "_done"
      if _heap_cfg_get_bool(state, "cg_mem_probe", false) then
        stmt_count2 = 0
        if typeof(mstmts2) == "array" then stmt_count2 = len(mstmts2) end if
        print "[mem][cg] modinit_begin idx=" + mri + " file=" + mfile2 + " stmts=" + stmt_count2
      end if
      state.asm = a.mov_rax_rip_qword(state.asm, flag_lbl2)
      state.asm = a.test_r64_r64(state.asm, "rax", "rax")
      state.asm = a.jcc(state.asm, "ne", done_lbl2)
      state.asm = a.mov_r64_imm64(state.asm, "rax", 1)
      state.asm = a.mov_rip_qword_rax(state.asm, flag_lbl2)
      state.asm = a.mov_r64_imm64(state.asm, "rax", 1)
      state.asm = a.mov_rip_qword_rax(state.asm, status_lbl2)
      prev_active = state._module_init_active
      prev_file = state._module_init_active_file
      state._module_init_active = true
      state._module_init_active_file = mfile2
      if typeof(mstmts2) == "array" and len(mstmts2) > 0 then
        for msi = 0 to len(mstmts2) - 1
          if _heap_cfg_get_bool(state, "cg_mem_probe", false) and mri == 6 and ((msi % 50) == 0 or msi >= 600) then
            st_kind2 = "<non-struct>"
            if typeof(mstmts2[msi]) == "struct" then st_kind2 = _coerce_name(mstmts2[msi].node_kind) end if
            print "[mem][cg] modinit_stmt idx=" + mri + " stmt=" + msi + " kind=" + st_kind2
          end if
          state = cg_emit_stmt(state, mstmts2[msi])
        end for
      end if
      state._module_init_active = prev_active
      state._module_init_active_file = prev_file
      state.asm = a.mov_r64_imm64(state.asm, "rax", 2)
      state.asm = a.mov_rip_qword_rax(state.asm, status_lbl2)
      state.asm = a.mark(state.asm, done_lbl2)
      mr[1] = []
      module_init_recs[mri] = mr
      if _heap_cfg_get_bool(state, "cg_mem_probe", false) then
        print "[mem][cg] modinit_done idx=" + mri + " file=" + mfile2
      end if
    end for
  end if
  module_init_recs = []
  state = _mem_probe(state, "top_level_done")
  state = _maybe_phase_gc(state, "post_top_level_phase_gc", 256 << 20)
  if _heap_cfg_get_bool(state, "cg_collect_after_top_level", false) then
    gc_collect()
    state = _mem_probe(state, "post_top_level_gc")
  end if

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
    state = exprmod._emit_auto_errprop(state)

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
  state = core.emit_deferred_cold_blocks(state)
  core.pop_cold_block_scope(state)

  // Emit user function bodies in the same sorted order as the Python compiler.
  uf_names = _user_function_keys_sorted(state)
  state = _mem_probe(state, "user_fn_emit_start")
  uf_total = len(uf_names)
  uf_i = 0
  while uf_i < uf_total
    if _heap_cfg_get_bool(state, "cg_mem_probe", false) and (uf_i % 100) == 0 then
      uf_name_dbg = uf_names[uf_i]
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
      print "[mem][cg] user_fn_idx=" + uf_i + " total=" + uf_total + " name=" + uf_name_dbg + " asm_size=" + asmsz + " labels=" + lbln + " patches=" + pcn + " calls=" + ccn + " diags=" + dlen + " scopes=" + sn + "/" + sdn + " globals=" + gn + " fn_locals=" + fln + " rdata=" + rused + "/" + rcap + " data=" + dused + "/" + dcap + " used=" + heap_bytes_used() + " committed=" + heap_bytes_committed() + " reserved=" + heap_bytes_reserved()
    end if
    uf_name = uf_names[uf_i]
    uf_node = _user_function_get_node(state, uf_name)
    if typeof(uf_node) == "struct" then
      state = emit_user_function(state, uf_node)
      uf_node = _release_emitted_fn_node(uf_node)
      state = _set_user_function(state, uf_name, uf_node)
    end if
    uf_i = uf_i + 1
    if (uf_i % 16) == 0 then
      state = _maybe_phase_gc(state, "mid_user_fn_phase_gc", 512 << 20)
    end if
    if _heap_cfg_get_bool(state, "cg_collect_during_codegen", false) and (uf_i % 8) == 0 then
      gc_collect()
    end if
  end while
  nested_names = _nested_function_codegen_names_sorted(state)
  if len(nested_names) > 0 then
    for nfi = 0 to len(nested_names) - 1
      nf = _nested_function_get_by_codegen_name(state, nested_names[nfi])
      if typeof(nf) == "struct" then
        state = emit_user_function(state, nf)
        nf = _release_emitted_fn_node(nf)
        state = _forget_nested_function_by_codegen_name(state, nested_names[nfi])
      end if
      if ((nfi + 1) % 16) == 0 then
        state = _maybe_phase_gc(state, "mid_nested_fn_phase_gc", 512 << 20)
      end if
    end for
  end if
  state = _mem_probe(state, "user_fn_emit_done")
  state.user_functions = []
  state.nested_user_functions = []
  state.user_function_index = t.fastmap_new(16)
  state.function_codegen_name_map = t.fastmap_new(16)
  state._global_owner_file = t.fastmap_new(16)
  state._module_init_status_labels = t.fastmap_new(16)
  uf_names = []
  nested_names = []
  state = _maybe_phase_gc(state, "post_user_fn_phase_gc", 256 << 20)

  // Emit extern stub bodies (extern callable values).
  state = exprmod.emit_extern_stubs(state)

  // Emit runtime/builtin helper bodies
  state = core.emit_used_helpers(state)
  return state
end function

function emit_user_function(state, fn_node)
  if typeof(fn_node) != "struct" then return state end if
  qn = _coerce_name(fn_node.name)
  code_name = _fn_codegen_name(state, fn_node)
  if code_name == "" then return state end if
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) then
    print "[mem][cg] emit_user_function_start name=" + code_name
  end if
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and s.startsWith(code_name, "std.string.") then
    print "[dbg][fn] start " + code_name
  end if

  fn_lbl = "fn_user_" + code_name
  ret_lbl = "fn_ret_" + code_name
  max_call_args = max_calls_stmts(state, fn_node.body)
  if typeof(max_call_args) != "int" or max_call_args < 0 then max_call_args = 0 end if

  old_decl_site = state.decl_site_bindings
  old_fn_locals = state.function_locals
  old_fn_local_ids = state.function_local_ids
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and code_name == "std.string.isBlank" then
    print "[dbg][stage] " + code_name + " analysis_prepare_begin"
  end if
  state = _analysis_prepare_function(state, fn_node)
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and code_name == "std.string.isBlank" then
    print "[dbg][stage] " + code_name + " analysis_prepare_done"
  end if
  n_locals = 0
  if typeof(state.function_locals) == "array" then n_locals = len(state.function_locals) end if

  out_stack_args = max_call_args - 4
  if out_stack_args < 0 then out_stack_args = 0 end if
  out_scratch = 8
  out_stack_bytes = out_stack_args * 8
  out_overlap = out_scratch
  if out_stack_bytes > out_overlap then out_overlap = out_stack_bytes end if
  dbg_save_size = 24
  dbg_save_base = 0x20 + out_overlap
  out_reserve = out_overlap + dbg_save_size
  local_base = t.align_up(0x20 + out_reserve, 16)
  env_root_off = local_base
  locals_base = local_base + 8
  local_bytes = n_locals * 8
  params_base = locals_base + local_bytes
  call_temp_base = params_base
  if typeof(fn_node.params) == "array" then call_temp_base = params_base + len(fn_node.params) * 8 end if
  call_temp_bytes = max_call_args * 8
  if call_temp_bytes < 0x40 then call_temp_bytes = 0x40 end if
  call_temp_bytes = t.align_up(call_temp_bytes, 16)
  expr_temp_base = call_temp_base + call_temp_bytes
  frame_end = expr_temp_base + state.expr_temp_max
  frame = t.align_up(frame_end + 0x20, 16)
  root_rec_off = frame - 0x20
  root_base = local_base
  root_top = expr_temp_base
  dbg_save_script = dbg_save_base + 0
  dbg_save_func = dbg_save_base + 8
  dbg_save_line = dbg_save_base + 16
  state = scope.analysis_layout_function_locals(state, locals_base)
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and code_name == "std.string.isBlank" then
    print "[dbg][stage] " + code_name + " analysis_layout_done"
  end if
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and code_name == "std.string.join" then
    print "[dbg][join][layout] begin"
    if typeof(state.function_locals) == "array" and len(state.function_locals) > 0 then
      for ji = 0 to len(state.function_locals) - 1
        jb = state.function_locals[ji]
        if typeof(jb) != "struct" then continue end if
        print "[dbg][join][local] i=" + ji + " name=" + _coerce_name(jb.name) + " kind=" + _coerce_name(jb.kind) + " off=" + jb.offset + " key=" + scope._decl_key(jb.decl_node, jb.name)
      end for
    end if
  end if
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and code_name == "std.string.contains" then
    print "[mem][cg] fn_stage name=" + code_name + " stage=analysis_layout_done"
  end if

  old_in = state.in_function
  old_pref = state.current_qname_prefix
  old_file_pref = state.current_file_prefix
  old_var_slots = state.var_slots
  old_ret = state.func_ret_label
  old_frame = state.func_frame_size
  old_call_temp_base = state.call_temp_base
  old_expr_base = state.expr_temp_base
  old_expr_top = state.expr_temp_top
  old_root_rec_off = state._current_root_rec_off
  old_root_static_qwords = state._current_root_static_qwords
  old_boxed_names = state.current_fn_boxed_names
  old_env_index = state.current_fn_env_index
  old_env_root = state.current_env_root_off
  old_func_globals = state.func_globals
  old_func_global_map = state.func_global_map
  old_func_global_map_index = state.func_global_map_index
  saved_emit_stack = state.scope_stack
  saved_emit_declared = state.scope_declared
  saved_emit_idx_stack = state.scope_index_stack
  saved_emit_decl_idx_stack = state.scope_declared_index_stack

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
  state.call_temp_base = call_temp_base
  state.expr_temp_base = expr_temp_base
  state.expr_temp_top = 0
  state._current_root_rec_off = root_rec_off
  state._current_root_static_qwords = (root_top - root_base) / 8
  state.current_fn_boxed_names = boxed_names
  state.current_fn_env_index = env_index
  state.current_env_root_off = env_root_off
  state.qualify_cache = _prepare_qualify_cache(state.qualify_cache, 2048)
  state.func_globals = []
  state.func_global_map = []
  state.func_global_map_index = t.fastmap_new(64)
  base_globals_emit = []
  base_global_index_emit = t.fastmap_new(128)
  base_decl_index_emit = t.fastmap_new(128)
  if typeof(saved_emit_stack) == "array" and len(saved_emit_stack) > 0 then base_globals_emit = saved_emit_stack[0] end if
  if typeof(saved_emit_idx_stack) == "array" and len(saved_emit_idx_stack) > 0 then base_global_index_emit = saved_emit_idx_stack[0] end if
  if typeof(saved_emit_decl_idx_stack) == "array" and len(saved_emit_decl_idx_stack) > 0 then base_decl_index_emit = saved_emit_decl_idx_stack[0] end if
  state.scope_stack = [base_globals_emit, []]
  state.scope_declared = [[], []]
  state.scope_index_stack = [base_global_index_emit, t.fastmap_new(128)]
  state.scope_declared_index_stack = [base_decl_index_emit, t.fastmap_new(128)]

  state.asm = a.mark(state.asm, fn_lbl)
  state.asm = a.push_rbx(state.asm)
  state.asm = a.push_r12(state.asm)
  state.asm = a.push_r13(state.asm)
  state.asm = a.push_r14(state.asm)
  state.asm = a.push_r15(state.asm)
  state.asm = a.sub_rsp_imm32(state.asm, frame)

  if state.call_profile then
    cp_idx = _named_int_get(state.callprof_index, code_name, -1)
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
    dbg_script = core._pretty_script(state, dbg_file)
  end if
  if typeof(dbg_script) != "string" or dbg_script == "" then
    if typeof(state.filename) == "string" and state.filename != "" then
      dbg_script = state.filename
    else
      dbg_script = "<script>"
    end if
  end if
  dbg_func = qn
  if typeof(dbg_func) != "string" or dbg_func == "" then dbg_func = code_name end if
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
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and code_name == "std.string.contains" then
    print "[mem][cg] fn_stage name=" + code_name + " stage=dbg_labels_done"
  end if

  state = mem.emit_gc_clear_root_slots(state, root_base, root_top)
  state = mem.emit_gc_push_root_frame(state, root_rec_off, root_base, root_top)
  // Incoming closure environment is passed in r10.
  state.asm = a.mov_r64_r64(state.asm, "r14", "r10")
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and code_name == "std.string.contains" then
    print "[mem][cg] fn_stage name=" + code_name + " stage=prologue_done"
  end if

  // Declare capture bindings in function scope before body emission.
  state = _closure_declare_capture_bindings(state, fn_node)

  // Spill incoming params to stack slots and bind them.
  if typeof(fn_node.params) == "array" and len(fn_node.params) > 0 then
    for i = 0 to len(fn_node.params) - 1
      pn = _coerce_name(fn_node.params[i])
      poff = params_base + i * 8
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
                sisb = state.scope_index_stack
                if typeof(sisb) == "array" and sib >= 0 and sib < len(sisb) then
                  fmb = sisb[sib]
                  fmb = t.fastmap_set(fmb, bb.name, bb)
                  sisb[sib] = fmb
                  state.scope_index_stack = sisb
                end if
                break
              end if
              jb = jb - 1
            end while
          end if
        end if
      end if
    end for
  end if
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and code_name == "std.string.contains" then
    print "[mem][cg] fn_stage name=" + code_name + " stage=params_done"
  end if

  // Materialize current environment frame (owner env) when needed.
  has_parent_env = false
  if len(caps_list) > 0 then has_parent_env = true end if
  if env_hop_flag then has_parent_env = true end if
  if need_env then
    env_n = len(env_slots)
    param_off = t.fastmap_new((env_n * 2) + 16)
    if typeof(fn_node.params) == "array" and len(fn_node.params) > 0 then
      for epi0 = 0 to len(fn_node.params) - 1
        epn0 = _coerce_name(fn_node.params[epi0])
        if epn0 == "" then continue end if
        param_off = _map_int_set(param_off, epn0, params_base + epi0 * 8)
      end for
    end if

    local_off = t.fastmap_new((env_n * 2) + 16)
    local_count = t.fastmap_new((env_n * 2) + 16)
    if typeof(state.function_locals) == "array" and len(state.function_locals) > 0 then
      for lfi = 0 to len(state.function_locals) - 1
        lf = state.function_locals[lfi]
        if typeof(lf) != "struct" then continue end if
        lnm = _coerce_name(lf.name)
        if lnm == "" then continue end if
        if typeof(lf.offset) != "int" then continue end if
        lcnt = _map_int_get(local_count, lnm, 0)
        local_count = _map_int_set(local_count, lnm, lcnt + 1)
        if _map_int_get(local_off, lnm, -1) < 0 then
          local_off = _map_int_set(local_off, lnm, lf.offset)
        end if
      end for
    end if

    slot_off = t.fastmap_new((env_n * 2) + 16)
    if env_n > 0 then
      for esi0 = 0 to env_n - 1
        snm = _coerce_name(env_slots[esi0])
        if snm == "" then continue end if
        poff0 = _map_int_get(param_off, snm, -1)
        lcnt0 = _map_int_get(local_count, snm, 0)
        if (poff0 >= 0 and lcnt0 > 0) or lcnt0 > 1 then
          state.diagnostics = state.diagnostics + ["Shadowing of captured variable '" + snm + "' is not supported yet"]
          continue
        end if
        if poff0 >= 0 then
          slot_off = _map_int_set(slot_off, snm, poff0)
        else
          if lcnt0 == 1 then
            slot_off = _map_int_set(slot_off, snm, _map_int_get(local_off, snm, -1))
          else
            state.diagnostics = state.diagnostics + ["Internal compiler error: captured name '" + snm + "' has no slot"]
          end if
        end if
      end for
    end if

    if env_n > 0 then
      for esi1 = 0 to env_n - 1
        snm2 = _coerce_name(env_slots[esi1])
        soff = _map_int_get(slot_off, snm2, -1)
        if soff < 0 then continue end if
        state.asm = a.mov_r64_membase_disp(state.asm, "r12", "rsp", soff)
        state.asm = a.mov_rcx_imm32(state.asm, 16)
        state.asm = a.call(state.asm, "fn_alloc")
        state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
        state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_BOX, false)
        state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, 0, false)
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8, "r12")
        state.asm = a.mov_membase_disp_r64(state.asm, "rsp", soff, "r11")
      end for
    end if

    slot_base = 8
    env_obj_type = c.OBJ_ENV_LOCAL
    env_size = 8 + env_n * 8
    if has_parent_env then
      slot_base = 16
      env_obj_type = c.OBJ_ENV
      env_size = 16 + env_n * 8
    end if

    state.asm = a.mov_rcx_imm32(state.asm, env_size)
    state.asm = a.call(state.asm, "fn_alloc")
    state.asm = a.mov_r64_r64(state.asm, "r15", "rax")
    state.asm = a.mov_membase_disp_imm32(state.asm, "r15", 0, env_obj_type, false)
    state.asm = a.mov_membase_disp_imm32(state.asm, "r15", 4, env_n, false)
    if has_parent_env then
      state.asm = a.mov_membase_disp_r64(state.asm, "r15", 8, "r14")
    end if

    if env_n > 0 then
      for esi2 = 0 to env_n - 1
        snm3 = _coerce_name(env_slots[esi2])
        soff2 = _map_int_get(slot_off, snm3, -1)
        if soff2 < 0 then continue end if
        state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", soff2)
        state.asm = a.mov_membase_disp_r64(state.asm, "r15", slot_base + esi2 * 8, "r10")
      end for
    end if

    state.asm = a.mov_r64_r64(state.asm, "rax", "r15")
    state.asm = a.mov_rsp_disp32_rax(state.asm, env_root_off)
  else
    state.asm = a.mov_r64_imm64(state.asm, "r15", t.enc_void())
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    state.asm = a.mov_rsp_disp32_rax(state.asm, env_root_off)
  end if
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and code_name == "std.string.contains" then
    print "[mem][cg] fn_stage name=" + code_name + " stage=env_done"
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

  state = core.push_cold_block_scope(state)
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and code_name == "std.string.contains" then
    print "[mem][cg] fn_stage name=" + code_name + " stage=body_enter"
  end if
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and code_name == "std.string.isBlank" then
    print "[dbg][stage] " + code_name + " body_enter"
  end if
  if typeof(fn_node.body) == "array" and len(fn_node.body) > 0 then
    uf_body_items = fn_node.body
    uf_body_count = len(uf_body_items)
    for uf_body_idx = 0 to uf_body_count - 1
      if uf_body_idx < 0 or uf_body_idx >= uf_body_count then break end if
      if _heap_cfg_get_bool(state, "cg_mem_probe", false) then
        st_kind_dbg = ""
        if typeof(uf_body_items[uf_body_idx]) == "struct" and typeof(uf_body_items[uf_body_idx].node_kind) == "string" then
          st_kind_dbg = uf_body_items[uf_body_idx].node_kind
        end if
        print "[mem][cg] body_stmt name=" + code_name + " idx=" + uf_body_idx + " kind=" + st_kind_dbg
      end if
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and code_name == "std.string.isBlank" then
        st_kind_dbg2 = ""
        if typeof(uf_body_items[uf_body_idx]) == "struct" and typeof(uf_body_items[uf_body_idx].node_kind) == "string" then
          st_kind_dbg2 = uf_body_items[uf_body_idx].node_kind
        end if
        print "[dbg][stage] " + code_name + " body_stmt idx=" + uf_body_idx + " kind=" + st_kind_dbg2
      end if
      state = cg_emit_stmt(state, uf_body_items[uf_body_idx])
    end for
  end if

  // implicit return void
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.jmp(state.asm, ret_lbl)
  state = core.emit_deferred_cold_blocks(state)
  core.pop_cold_block_scope(state)

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

  state.scope_stack = saved_emit_stack
  state.scope_declared = saved_emit_declared
  state.scope_index_stack = saved_emit_idx_stack
  state.scope_declared_index_stack = saved_emit_decl_idx_stack
  state.in_function = old_in
  state.current_qname_prefix = old_pref
  state.current_file_prefix = old_file_pref
  state.var_slots = old_var_slots
  state.func_ret_label = old_ret
  state.func_frame_size = old_frame
  state.call_temp_base = old_call_temp_base
  state.expr_temp_base = old_expr_base
  state.expr_temp_top = old_expr_top
  state._current_root_rec_off = old_root_rec_off
  state._current_root_static_qwords = old_root_static_qwords
  state.current_fn_boxed_names = old_boxed_names
  state.current_fn_env_index = old_env_index
  state.current_env_root_off = old_env_root
  state.func_globals = old_func_globals
  state.func_global_map = old_func_global_map
  state.func_global_map_index = old_func_global_map_index
  state.decl_site_bindings = old_decl_site
  state.function_locals = old_fn_locals
  state.function_local_ids = old_fn_local_ids
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) then
    print "[mem][cg] emit_user_function_done name=" + code_name
  end if
  if _heap_cfg_get_bool(state, "cg_mem_probe", false) and s.startsWith(code_name, "std.string.") then
    print "[dbg][fn] done " + code_name
  end if
  state.qualify_cache = _prepare_qualify_cache(state.qualify_cache, 512)
  if code_name == "" then return state end if
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

function _struct_methods_any_has(state, mname)
  if mname == "" then return false end if
  items = state.struct_methods
  if typeof(items) == "struct" then items = t.fastmap_items(items) end if
  if typeof(items) != "array" or len(items) <= 0 then return false end if
  for i = 0 to len(items) - 1
    entry = items[i]
    mdict = 0
    if typeof(entry) == "struct" then mdict = entry.values end if
    if typeof(entry) == "array" and len(entry) >= 2 then mdict = entry[1] end if
    if _strpair_get(mdict, mname) != "" then return true end if
  end for
  return false
end function

function inline _max_calls_int(a, b)
  if a > b then return a end if
  return b
end function

function max_calls_expr(state, ex)
  if typeof(ex) != "struct" then return 0 end if
  nk = _coerce_name(ex.node_kind)
  m = 0
  if nk == "Call" then
    args = _analysis_call_args(ex)
    cal = _analysis_call_callee(ex)
    call_arity = len(args)
    if typeof(cal) == "struct" and _coerce_name(cal.node_kind) == "Member" then
      mname = _coerce_name(try(cal.name))
      if _struct_methods_any_has(state, mname) then
        call_arity = call_arity + 1
      end if
    end if
    m = _max_calls_int(m, call_arity)
    m = _max_calls_int(m, max_calls_expr(state, cal))
    if len(args) > 0 then
      for each aa in args
        if typeof(aa) == "struct" then
          m = _max_calls_int(m, max_calls_expr(state, aa))
        end if
      end for
    end if
    return m
  end if
  if nk == "Unary" then return max_calls_expr(state, try(ex.right)) end if
  if nk == "Bin" then return _max_calls_int(max_calls_expr(state, try(ex.left)), max_calls_expr(state, try(ex.right))) end if
  if nk == "ArrayLit" then
    items_mc = try(ex.items)
    if typeof(items_mc) == "array" and len(items_mc) > 0 then
      for each it in items_mc
        m = _max_calls_int(m, max_calls_expr(state, it))
      end for
    end if
    return m
  end if
  if nk == "Index" then return _max_calls_int(max_calls_expr(state, try(ex.target)), max_calls_expr(state, try(ex.index))) end if
  if nk == "Member" then
    return max_calls_expr(state, _analysis_member_target(ex))
  end if
  if nk == "StructInit" then
    vals_mc = try(ex.values)
    if typeof(vals_mc) == "array" and len(vals_mc) > 0 then
      for each vv in vals_mc
        m = _max_calls_int(m, max_calls_expr(state, vv))
      end for
    end if
    return m
  end if
  return 0
end function

function max_calls_stmts(state, stmts)
  if typeof(stmts) != "array" or len(stmts) <= 0 then return 0 end if
  m = 0
  for i = 0 to len(stmts) - 1
    if i < 0 or i >= len(stmts) then break end if
    st = stmts[i]
    if typeof(st) != "struct" then continue end if
    nk = _coerce_name(st.node_kind)
    if nk == "Assign" then
      m = _max_calls_int(m, max_calls_expr(state, try(st.expr)))
      continue
    end if
    if nk == "ConstDecl" then
      m = _max_calls_int(m, max_calls_expr(state, try(st.expr)))
      continue
    end if
    if nk == "Print" then
      m = _max_calls_int(m, max_calls_expr(state, try(st.expr)))
      continue
    end if
    if nk == "ExprStmt" then
      m = _max_calls_int(m, max_calls_expr(state, try(st.expr)))
      continue
    end if
    if nk == "SetMember" then
      obj_expr = 0
      obj_try = try(st.obj)
      tgt_try = try(st.target)
      if typeof(obj_try) == "struct" then obj_expr = obj_try end if
      if typeof(obj_expr) != "struct" and typeof(tgt_try) == "struct" then obj_expr = tgt_try end if
      m = _max_calls_int(m, max_calls_expr(state, obj_expr))
      m = _max_calls_int(m, max_calls_expr(state, try(st.expr)))
      continue
    end if
    if nk == "SetIndex" then
      m = _max_calls_int(m, max_calls_expr(state, try(st.target)))
      m = _max_calls_int(m, max_calls_expr(state, try(st.index)))
      m = _max_calls_int(m, max_calls_expr(state, try(st.expr)))
      continue
    end if
    if nk == "If" then
      then_body_mc = try(st.then_body)
      elifs_mc = try(st.elifs)
      else_body_mc = try(st.else_body)
      m = _max_calls_int(m, max_calls_expr(state, try(st.cond)))
      m = _max_calls_int(m, max_calls_stmts(state, then_body_mc))
      if typeof(elifs_mc) == "array" and len(elifs_mc) > 0 then
        for ei = 0 to len(elifs_mc) - 1
          if ei < 0 or ei >= len(elifs_mc) then break end if
          eb = elifs_mc[ei]
          if typeof(eb) == "array" and len(eb) >= 2 then
            m = _max_calls_int(m, max_calls_expr(state, eb[0]))
            m = _max_calls_int(m, max_calls_stmts(state, eb[1]))
          end if
        end for
      end if
      m = _max_calls_int(m, max_calls_stmts(state, else_body_mc))
      continue
    end if
    if nk == "While" then
      m = _max_calls_int(m, max_calls_expr(state, try(st.cond)))
      m = _max_calls_int(m, max_calls_stmts(state, try(st.body)))
      continue
    end if
    if nk == "DoWhile" then
      m = _max_calls_int(m, max_calls_stmts(state, try(st.body)))
      m = _max_calls_int(m, max_calls_expr(state, try(st.cond)))
      continue
    end if
    if nk == "For" then
      m = _max_calls_int(m, max_calls_expr(state, try(st.start)))
      m = _max_calls_int(m, max_calls_expr(state, _analysis_for_end_expr(st)))
      m = _max_calls_int(m, max_calls_stmts(state, try(st.body)))
      continue
    end if
    if nk == "ForEach" then
      m = _max_calls_int(m, max_calls_expr(state, try(st.iterable)))
      m = _max_calls_int(m, max_calls_stmts(state, try(st.body)))
      continue
    end if
    if nk == "Switch" then
      cases_mc = try(st.cases)
      m = _max_calls_int(m, max_calls_expr(state, try(st.expr)))
      if typeof(cases_mc) == "array" and len(cases_mc) > 0 then
        for ci = 0 to len(cases_mc) - 1
          if ci < 0 or ci >= len(cases_mc) then break end if
          cs = cases_mc[ci]
          if typeof(cs) != "struct" then continue end if
          if _coerce_name(try(cs.kind)) == "values" then
            vals = try(cs.values)
            if typeof(vals) == "array" and len(vals) > 0 then
              for vi = 0 to len(vals) - 1
                if vi < 0 or vi >= len(vals) then break end if
                vv = vals[vi]
                if typeof(vv) == "array" and len(vv) >= 2 then
                  m = _max_calls_int(m, max_calls_expr(state, vv[0]))
                  m = _max_calls_int(m, max_calls_expr(state, vv[1]))
                else
                  m = _max_calls_int(m, max_calls_expr(state, vv))
                end if
              end for
            end if
          else
            m = _max_calls_int(m, max_calls_expr(state, try(cs.range_start)))
            m = _max_calls_int(m, max_calls_expr(state, try(cs.range_end)))
          end if
          m = _max_calls_int(m, max_calls_stmts(state, cs.body))
        end for
      end if
      m = _max_calls_int(m, max_calls_stmts(state, try(st.default_body)))
      continue
    end if
    if nk == "Return" then
      m = _max_calls_int(m, max_calls_expr(state, try(st.expr)))
      continue
    end if
  end for
  return m
end function

function stmt_list(state, stmts)
  return _emit_stmt_list(state, stmts)
end function
