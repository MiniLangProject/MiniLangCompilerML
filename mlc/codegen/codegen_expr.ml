package mlc.codegen.codegen_expr
import std.string as s
import mlc.asm as a
import mlc.constants as c
import mlc.tools as t
import mlc.data as d
import mlc.codegen.codegen_scope as scope
import mlc.codegen.codegen_core as core
import mlc.codegen.codegen_memory as mem

struct ConstEvalResult
  ok,
  value,
end struct

function _opt_truthy(v)
  tv = typeof(v)
  if tv == "void" then return false end if
  if tv == "bool" then return v end if
  if tv == "int" or tv == "float" then return v != 0 end if
  if tv == "string" then return v != "" end if
  if tv == "array" then return len(v) != 0 end if
  if tv == "bytes" then return len(v) != 0 end if
  return true
end function

function _is_number_no_bool(v)
  tv = typeof(v)
  if tv == "int" or tv == "float" then return true end if
  return false
end function

function _is_int_no_bool(v)
  return typeof(v) == "int"
end function

function _coerce_name(v)
  if typeof(v) == "string" then return v end if
  if typeof(v) == "struct" then
    if typeof(v.name) == "string" then return v.name end if
    if typeof(v.value) == "string" then return v.value end if
  end if
  return "" + v
end function

function _named_array_get(arr, key)
  if typeof(arr) != "array" or len(arr) <= 0 then return 0 end if
  for i = 0 to len(arr) - 1
    it = arr[i]
    if typeof(it) == "struct" and it.key == key then
      if typeof(it.values) == "array" then return it.values end if
      return 0
    end if
    if typeof(it) == "array" and len(it) >= 2 and it[0] == key then
      if typeof(it[1]) == "array" then return it[1] end if
      return 0
    end if
  end for
  return 0
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

function _method_map_get(map_arr, method_name)
  if typeof(map_arr) != "array" or len(map_arr) <= 0 then return "" end if
  for i = 0 to len(map_arr) - 1
    it = map_arr[i]
    if typeof(it) == "array" and len(it) >= 2 and _coerce_name(it[0]) == method_name then
      return _coerce_name(it[1])
    end if
    if typeof(it) == "struct" and _coerce_name(it.key) == method_name then
      return _coerce_name(it.value)
    end if
  end for
  return ""
end function

function _user_function_get(state, qname)
  arr = state.user_functions
  if typeof(arr) != "array" or len(arr) <= 0 then return 0 end if
  for i = 0 to len(arr) - 1
    it = arr[i]
    if typeof(it) == "array" and len(it) == 2 and it[0] == qname then return it[1] end if
    if typeof(it) == "struct" and it.key == qname then return it.value end if
  end for
  return 0
end function

function _has_any_global_prefix(state, base)
  if typeof(base) != "string" or base == "" then return false end if
  pref = base + "."

  uf = state.user_functions
  if typeof(uf) == "array" and len(uf) > 0 then
    for i = 0 to len(uf) - 1
      it = uf[i]
      if typeof(it) == "array" and len(it) >= 1 and typeof(it[0]) == "string" then
        if s.startsWith(it[0], pref) then return true end if
      end if
      if typeof(it) == "struct" and typeof(it.key) == "string" then
        if s.startsWith(it.key, pref) then return true end if
      end if
    end for
  end if

  eids = state.enum_ids
  if typeof(eids) == "array" and len(eids) > 0 then
    for i = 0 to len(eids) - 1
      it2 = eids[i]
      if typeof(it2) == "struct" and typeof(it2.key) == "string" then
        if s.startsWith(it2.key, pref) then return true end if
      end if
    end for
  end if

  sids = state.struct_ids
  if typeof(sids) == "array" and len(sids) > 0 then
    for i = 0 to len(sids) - 1
      it3 = sids[i]
      if typeof(it3) == "struct" and typeof(it3.key) == "string" then
        if s.startsWith(it3.key, pref) then return true end if
      end if
    end for
  end if

  gls = state.globals
  if typeof(gls) == "array" and len(gls) > 0 then
    for i = 0 to len(gls) - 1
      g = gls[i]
      if typeof(g) == "struct" and typeof(g.name) == "string" then
        if s.startsWith(g.name, pref) then return true end if
      end if
    end for
  end if
  return false
end function

function _builtin_label(name)
  nm = name
  if typeof(nm) != "string" then return "" end if
  if nm == "len" then return "fn_builtin_len" end if
  if nm == "toNumber" then return "fn_toNumber" end if
  if nm == "typeof" then return "fn_typeof" end if
  if nm == "typeName" then return "fn_typeName" end if
  if nm == "input" then return "fn_builtin_input" end if
  if nm == "gc_collect" then return "fn_builtin_gc_collect" end if
  if nm == "gc_set_limit" then return "fn_builtin_gc_set_limit" end if
  if nm == "decode" then return "fn_decode" end if
  if nm == "decodeZ" then return "fn_decodeZ" end if
  if nm == "decode16Z" then return "fn_decode16Z" end if
  if nm == "hex" then return "fn_hex" end if
  if nm == "fromHex" then return "fn_fromHex" end if
  if nm == "slice" then return "fn_slice" end if
  if nm == "callStats" then return "fn_callStats" end if
  if nm == "heap_count" then return "fn_heap_count" end if
  if nm == "heap_bytes_used" then return "fn_heap_bytes_used" end if
  if nm == "heap_bytes_committed" then return "fn_heap_bytes_committed" end if
  if nm == "heap_bytes_reserved" then return "fn_heap_bytes_reserved" end if
  if nm == "heap_free_bytes" then return "fn_heap_free_bytes" end if
  if nm == "heap_free_blocks" then return "fn_heap_free_blocks" end if
  return ""
end function

function _next_lid(state)
  lid = state.label_id
  state.label_id = state.label_id + 1
  return lid
end function

function _alias_lookup(alias_map, key)
  if typeof(alias_map) != "array" or len(alias_map) <= 0 then return "" end if
  for i = 0 to len(alias_map) - 1
    p = alias_map[i]
    if typeof(p) == "struct" and p.key == key then
      if typeof(p.value) == "string" then return p.value end if
    end if
  end for
  return ""
end function

function _apply_import_alias(state, qname)
  if typeof(qname) != "string" then return "" end if
  if s.contains(qname, ".") == false then return qname end if
  parts = s.split(qname, ".")
  if len(parts) <= 1 then return qname end if
  alias = parts[0]
  target = _alias_lookup(state.import_aliases, alias)
  if target == "" then return qname end if
  tail_b = t.arr_chunk_new(8)
  for i = 1 to len(parts) - 1
    tail_b = t.arr_chunk_push(tail_b, _coerce_name(parts[i]))
  end for
  tail = t.arr_chunk_finish(tail_b)
  if typeof(tail) != "array" then tail = [] end if
  if len(tail) <= 0 then return target end if
  return target + "." + s.join(tail, ".")
end function

function _arr_has_str(arr, value)
  if typeof(arr) != "array" or len(arr) <= 0 then return false end if
  for i = 0 to len(arr) - 1
    if arr[i] == value then return true end if
  end for
  return false
end function

function _pool_has_key(pool, key)
  if typeof(pool) != "array" or len(pool) <= 0 then return false end if
  for i = 0 to len(pool) - 1
    it = pool[i]
    if typeof(it) == "array" and len(it) >= 1 then
      if _coerce_name(it[0]) == key then return true end if
    end if
  end for
  return false
end function

function _pool_collect_suffix(pool, prefix, suffix, matches)
  vals_out_b = t.arr_chunk_new(32)
  if typeof(matches) == "array" and len(matches) > 0 then
    vals_out_b = t.arr_chunk_push_all(vals_out_b, matches)
  end if
  vals_out = t.arr_chunk_finish(vals_out_b)
  if typeof(pool) != "array" or len(pool) <= 0 then return vals_out end if
  for i = 0 to len(pool) - 1
    it = pool[i]
    key = ""
    if typeof(it) == "array" and len(it) >= 1 then
      key = _coerce_name(it[0])
    end if
    if key == "" then continue end if
    if s.startsWith(key, prefix) and s.endsWith(key, suffix) then
      if _arr_has_str(vals_out, key) == false then
        vals_out_b = t.arr_chunk_push(vals_out_b, key)
        vals_out = t.arr_chunk_finish(vals_out_b)
      end if
    end if
  end for
  return vals_out
end function

function _qualify_identifier(state, name)
  if typeof(name) != "string" then return "" end if
  if name == "" then return "" end if
  n1 = _apply_import_alias(state, name)

  fn_pref = ""
  if typeof(state.current_qname_prefix) == "string" then fn_pref = state.current_qname_prefix end if
  pkg_pref = ""
  if typeof(state.current_file_prefix) == "string" then pkg_pref = state.current_file_prefix end if
  if pkg_pref == "" then pkg_pref = fn_pref end if

  cands_b = t.arr_chunk_new(8)
  cands_b = t.arr_chunk_push(cands_b, n1)
  if fn_pref != "" then
    if fn_pref[len(fn_pref) - 1] != "." then fn_pref = fn_pref + "." end if
    c1 = fn_pref + n1
    cands = t.arr_chunk_finish(cands_b)
    if _arr_has_str(cands, c1) == false then cands_b = t.arr_chunk_push(cands_b, c1) end if
  end if
  if pkg_pref != "" then
    if pkg_pref[len(pkg_pref) - 1] != "." then pkg_pref = pkg_pref + "." end if
    c2 = pkg_pref + n1
    cands2 = t.arr_chunk_finish(cands_b)
    if _arr_has_str(cands2, c2) == false then cands_b = t.arr_chunk_push(cands_b, c2) end if
  end if
  cands = t.arr_chunk_finish(cands_b)

  if len(cands) > 0 then
    for i = 0 to len(cands) - 1
      b = scope.cg_resolve_binding(state, cands[i])
      if typeof(b) == "struct" then return cands[i] end if
    end for
  end if

  pools = [state.user_functions, state.extern_sigs, state.struct_fields, state.enum_ids]
  if len(cands) > 0 then
    for ci = 0 to len(cands) - 1
      cand = cands[ci]
      for pi = 0 to len(pools) - 1
        if _pool_has_key(pools[pi], cand) then return cand end if
      end for
    end for
  end if

  if pkg_pref != "" then
    suffix = "." + n1
    hits = []
    for pi2 = 0 to len(pools) - 1
      hits = _pool_collect_suffix(pools[pi2], pkg_pref, suffix, hits)
    end for
    if typeof(hits) == "array" and len(hits) == 1 then
      return hits[0]
    end if
  end if

  return n1
end function

function _expr_to_qualname(state, expr)
  if typeof(expr) != "struct" then return "" end if
  if expr.node_kind == "Var" and typeof(expr.name) == "string" then
    nm = expr.name
    if s.contains(nm, ".") then return _qualify_identifier(state, _apply_import_alias(state, nm)) end if
    b = scope.cg_resolve_binding(state, nm)
    if typeof(b) == "struct" then return nm end if
    if _has_any_global_prefix(state, nm) then return nm end if
    return _qualify_identifier(state, nm)
  end if
  if expr.node_kind == "Member" and typeof(expr.name) == "string" then
    b = _expr_to_qualname(state, expr.target)
    if b == "" then return "" end if
    return _qualify_identifier(state, _apply_import_alias(state, b + "." + expr.name))
  end if
  return ""
end function

function _extern_sig_get(state, qname)
  if typeof(qname) != "string" or qname == "" then return 0 end if
  xs = state.extern_sigs
  if typeof(xs) != "array" or len(xs) <= 0 then return 0 end if
  for i = 0 to len(xs) - 1
    it = xs[i]
    if typeof(it) != "struct" then continue end if
    qn = _coerce_name(it.qname)
    if qn == "" then qn = _coerce_name(it.name) end if
    if qn == qname then return it end if
  end for
  return 0
end function

function _emit_struct_field_index_dispatch(state, field, struct_id_reg, out_reg, ok_label, fail_label, tag)
  pairs_b = t.arr_chunk_new(64)
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
  lid = _next_lid(state)
  hits_b = t.arr_chunk_new(64)

  for j = 0 to len(pairs) - 1
    sid2 = pairs[j][0]
    fidx2 = pairs[j][1]
    l_hit = tag + "_hit_" + lid + "_" + j
    hits_b = t.arr_chunk_push(hits_b, [l_hit, fidx2])
    state.asm = a.cmp_r32_imm(state.asm, struct_id_reg, sid2)
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

function _resolve_const_value(state, name)
  b = scope.cg_resolve_binding(state, name)
  if typeof(b) != "struct" then
    return ConstEvalResult(false, 0)
  end if
  if b.is_const == false then
    return ConstEvalResult(false, 0)
  end if
  if b.const_initialized == false then
    return ConstEvalResult(false, 0)
  end if
  return ConstEvalResult(true, b.const_value_py)
end function

function _try_const_bin(op, lv, rv)
  if op == "and" then return ConstEvalResult(true, _opt_truthy(lv) and _opt_truthy(rv)) end if
  if op == "or" then return ConstEvalResult(true, _opt_truthy(lv) or _opt_truthy(rv)) end if
  if op == "==" then return ConstEvalResult(true, lv == rv) end if
  if op == "!=" then return ConstEvalResult(true, lv != rv) end if

  if op == "<" or op == ">" or op == "<=" or op == ">=" then
    if _is_number_no_bool(lv) == false or _is_number_no_bool(rv) == false then
      return ConstEvalResult(false, 0)
    end if
    if op == "<" then return ConstEvalResult(true, lv < rv) end if
    if op == ">" then return ConstEvalResult(true, lv > rv) end if
    if op == "<=" then return ConstEvalResult(true, lv <= rv) end if
    return ConstEvalResult(true, lv >= rv)
  end if

  if op == "+" then
    if _is_number_no_bool(lv) and _is_number_no_bool(rv) then
      return ConstEvalResult(true, lv + rv)
    end if
    if typeof(lv) == "string" and typeof(rv) == "string" then
      return ConstEvalResult(true, lv + rv)
    end if
    return ConstEvalResult(false, 0)
  end if

  if op == "-" then
    if _is_number_no_bool(lv) and _is_number_no_bool(rv) then
      return ConstEvalResult(true, lv - rv)
    end if
    return ConstEvalResult(false, 0)
  end if

  if op == "*" then
    if _is_number_no_bool(lv) and _is_number_no_bool(rv) then
      return ConstEvalResult(true, lv * rv)
    end if
    return ConstEvalResult(false, 0)
  end if

  if op == "/" then
    if _is_number_no_bool(lv) and _is_number_no_bool(rv) then
      if rv == 0 then return ConstEvalResult(false, 0) end if
      return ConstEvalResult(true, lv / rv)
    end if
    return ConstEvalResult(false, 0)
  end if

  if op == "%" then
    if _is_int_no_bool(lv) and _is_int_no_bool(rv) then
      if rv == 0 then return ConstEvalResult(false, 0) end if
      return ConstEvalResult(true, lv % rv)
    end if
    return ConstEvalResult(false, 0)
  end if

  if op == "&" or op == "|" or op == "^" then
    if _is_int_no_bool(lv) == false or _is_int_no_bool(rv) == false then
      return ConstEvalResult(false, 0)
    end if
    if op == "&" then return ConstEvalResult(true, lv & rv) end if
    if op == "|" then return ConstEvalResult(true, lv | rv) end if
    return ConstEvalResult(true, lv ^ rv)
  end if

  if op == "<<" or op == ">>" then
    if _is_int_no_bool(lv) == false or _is_int_no_bool(rv) == false then
      return ConstEvalResult(false, 0)
    end if
    if rv < 0 then return ConstEvalResult(false, 0) end if
    if op == "<<" then return ConstEvalResult(true, lv << rv) end if
    return ConstEvalResult(true, lv >> rv)
  end if

  return ConstEvalResult(false, 0)
end function

function cg_expr_try_const_value(state, expr)
  if typeof(expr) != "struct" then return ConstEvalResult(false, 0) end if

  if expr.node_kind == "Num" or expr.node_kind == "Str" or expr.node_kind == "Bool" then
    return ConstEvalResult(true, expr.value)
  end if

  if expr.node_kind == "Var" then
    nm = _qualify_identifier(state, expr.name)
    v = _resolve_const_value(state, nm)
    if v.ok then return v end if
    if nm != expr.name then
      return _resolve_const_value(state, expr.name)
    end if
    return ConstEvalResult(false, 0)
  end if

  if expr.node_kind == "Member" then
    qn = _expr_to_qualname(state, expr)
    if qn == "" then return ConstEvalResult(false, 0) end if
    return _resolve_const_value(state, qn)
  end if

  if expr.node_kind == "Unary" then
    rv = cg_expr_try_const_value(state, expr.right)
    if rv.ok == false then return ConstEvalResult(false, 0) end if
    if expr.op == "not" then return ConstEvalResult(true, not _opt_truthy(rv.value)) end if
    if expr.op == "-" then
      if _is_number_no_bool(rv.value) == false then return ConstEvalResult(false, 0) end if
      return ConstEvalResult(true, 0 - rv.value)
    end if
    if expr.op == "~" then
      if _is_int_no_bool(rv.value) == false then return ConstEvalResult(false, 0) end if
      return ConstEvalResult(true, ~rv.value)
    end if
    return ConstEvalResult(false, 0)
  end if

  if expr.node_kind == "Bin" then
    lv = cg_expr_try_const_value(state, expr.left)
    if lv.ok == false then return ConstEvalResult(false, 0) end if

    if expr.op == "and" and _opt_truthy(lv.value) == false then
      return ConstEvalResult(true, false)
    end if
    if expr.op == "or" and _opt_truthy(lv.value) then
      return ConstEvalResult(true, true)
    end if

    rv = cg_expr_try_const_value(state, expr.right)
    if rv.ok == false then return ConstEvalResult(false, 0) end if
    return _try_const_bin(expr.op, lv.value, rv.value)
  end if

  return ConstEvalResult(false, 0)
end function

function cg_emit_expr(state, expr)
  if typeof(expr) != "struct" then
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return state
  end if

  cv = cg_expr_try_const_value(state, expr)
  if cv.ok then
    return _opt_emit_const_value(state, cv.value)
  end if

  k = expr.node_kind

  if k == "Num" then
    if typeof(expr.value) == "int" then
      state.asm = a.mov_rax_imm64(state.asm, t.enc_int(expr.value))
      return state
    end if
    if typeof(expr.value) == "float" then
      lbl_num = "flt_" + len(state.rdata.labels)
      state.rdata = d.rdata_add_obj_float(state.rdata, lbl_num, expr.value)
      state.asm = a.lea_rax_rip(state.asm, lbl_num)
      return state
    end if
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return state
  end if

  if k == "Bool" then
    state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(expr.value))
    return state
  end if

  if k == "Str" then
    lbl_str = "objstr_" + len(state.rdata.labels)
    state.rdata = d.rdata_add_obj_string(state.rdata, lbl_str, expr.value)
    state.asm = a.lea_rax_rip(state.asm, lbl_str)
    return state
  end if

  if k == "VoidLit" then
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return state
  end if

  if k == "IsType" then
    ty_raw = _coerce_name(expr.type_name)
    neg = false
    if typeof(expr.negated) == "bool" and expr.negated then neg = true end if

    ty_q = ty_raw
    if s.contains(ty_q, ".") then
      ty_q = _apply_import_alias(state, ty_q)
    else
      cand_s = _qualify_identifier(state, ty_q)
      sid_c = _named_int_get(state.struct_ids, cand_s, 0)
      if sid_c != 0 then
        ty_q = cand_s
      else
        cand_e = _qualify_identifier(state, ty_q)
        eid_c = _named_int_get(state.enum_ids, cand_e, -1)
        if eid_c >= 0 then
          ty_q = cand_e
        else
          ty_q = _apply_import_alias(state, ty_q)
        end if
      end if
    end if

    // If user wrote Enum.Variant, treat as Enum.
    if s.contains(ty_q, ".") then
      parts_ty = s.split(ty_q, ".")
      if typeof(parts_ty) == "array" and len(parts_ty) >= 2 then
        vname_ty = _coerce_name(parts_ty[len(parts_ty) - 1])
        base_parts_ty = slice(parts_ty, 0, len(parts_ty) - 1)
        if typeof(base_parts_ty) != "array" then base_parts_ty = [] end if
        base_ty = s.join(base_parts_ty, ".")
        vars_ty = _named_array_get(state.enum_variants, base_ty)
        if typeof(vars_ty) == "array" and len(vars_ty) > 0 then
          hit_var = false
          for vi_ty = 0 to len(vars_ty) - 1
            if _coerce_name(vars_ty[vi_ty]) == vname_ty then
              hit_var = true
              break
            end if
          end for
          if hit_var and _named_int_get(state.enum_ids, base_ty, -1) >= 0 then
            ty_q = base_ty
          end if
        end if
      end if
    end if

    sid = _named_int_get(state.struct_ids, ty_q, 0)
    if sid != 0 then
      state = cg_emit_expr(state, expr.expr)
      fid_s = _next_lid(state)
      l_false_s = "is_s_false_" + fid_s
      l_true_s = "is_s_true_" + fid_s
      l_done_s = "is_s_done_" + fid_s
      l_typeok_s = "is_s_typeok_" + fid_s

      state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
      state.asm = a.and_r64_imm(state.asm, "r10", 7)
      state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
      state.asm = a.jcc(state.asm, "ne", l_false_s)

      state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
      state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
      state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRUCT)
      state.asm = a.jcc(state.asm, "e", l_typeok_s)
      state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRUCTTYPE)
      state.asm = a.jcc(state.asm, "ne", l_false_s)

      state.asm = a.mark(state.asm, l_typeok_s)
      state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 8)
      state.asm = a.cmp_r32_imm(state.asm, "edx", sid)
      state.asm = a.jcc(state.asm, "e", l_true_s)
      state.asm = a.jmp(state.asm, l_false_s)

      state.asm = a.mark(state.asm, l_true_s)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
      state.asm = a.jmp(state.asm, l_done_s)

      state.asm = a.mark(state.asm, l_false_s)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
      state.asm = a.mark(state.asm, l_done_s)

      if neg then
        state.asm = a.xor_r64_imm8(state.asm, "rax", 8)
      end if
      return state
    end if

    eid = _named_int_get(state.enum_ids, ty_q, -1)
    if eid >= 0 then
      state = cg_emit_expr(state, expr.expr)
      fid_e = _next_lid(state)
      l_false_e = "is_e_false_" + fid_e
      l_true_e = "is_e_true_" + fid_e
      l_done_e = "is_e_done_" + fid_e

      state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
      state.asm = a.and_r64_imm(state.asm, "r10", 7)
      state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_ENUM)
      state.asm = a.jcc(state.asm, "ne", l_false_e)

      state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
      state.asm = a.shr_r64_imm8(state.asm, "r10", 3)
      state.asm = a.and_r64_imm(state.asm, "r10", 0xFFFF)
      state.asm = a.cmp_r64_imm(state.asm, "r10", eid)
      state.asm = a.jcc(state.asm, "e", l_true_e)
      state.asm = a.jmp(state.asm, l_false_e)

      state.asm = a.mark(state.asm, l_true_e)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
      state.asm = a.jmp(state.asm, l_done_e)

      state.asm = a.mark(state.asm, l_false_e)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
      state.asm = a.mark(state.asm, l_done_e)

      if neg then
        state.asm = a.xor_r64_imm8(state.asm, "rax", 8)
      end if
      return state
    end if

    // Value-enum check: `x is VEnum` means x equals one of VEnum.<member> values.
    vem = _named_array_get(state.value_enum_values, ty_q)
    if typeof(vem) == "array" and len(vem) > 0 then
      state = cg_emit_expr(state, expr.expr)
      fid_v = _next_lid(state)
      l_true_v = "is_ve_true_" + fid_v
      l_false_v = "is_ve_false_" + fid_v
      l_done_v = "is_ve_done_" + fid_v
      any_cmp_v = false

      for vi_v = 0 to len(vem) - 1
        it_v = vem[vi_v]
        vn_v = ""
        if typeof(it_v) == "struct" then
          vn_v = _coerce_name(it_v.key)
        else
          if typeof(it_v) == "array" and len(it_v) >= 1 then
            vn_v = _coerce_name(it_v[0])
          end if
        end if
        if vn_v == "" then continue end if
        qmem_v = ty_q + "." + vn_v
        cv_v = _resolve_const_value(state, qmem_v)
        if cv_v.ok == false then continue end if

        if typeof(cv_v.value) == "bool" then
          state.asm = a.cmp_r64_imm(state.asm, "rax", t.enc_bool(cv_v.value))
          state.asm = a.jcc(state.asm, "e", l_true_v)
          any_cmp_v = true
          continue
        end if
        if typeof(cv_v.value) == "int" then
          state.asm = a.cmp_r64_imm(state.asm, "rax", t.enc_int(cv_v.value))
          state.asm = a.jcc(state.asm, "e", l_true_v)
          any_cmp_v = true
          continue
        end if
      end for

      if any_cmp_v then
        state.asm = a.jmp(state.asm, l_false_v)
      else
        state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
        state.asm = a.jmp(state.asm, l_done_v)
      end if
      state.asm = a.mark(state.asm, l_true_v)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
      state.asm = a.jmp(state.asm, l_done_v)
      state.asm = a.mark(state.asm, l_false_v)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
      state.asm = a.mark(state.asm, l_done_v)
      if neg then
        state.asm = a.xor_r64_imm8(state.asm, "rax", 8)
      end if
      return state
    end if

    state.diagnostics = state.diagnostics +["Unknown type '" + ty_raw + "' in 'is' expression"]
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return state
  end if

  if k == "Var" then
    nm_raw = ""
    if typeof(expr.name) == "string" then nm_raw = expr.name end if
    if nm_raw == "" then
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return state
    end if

    nm = nm_raw
    if s.contains(nm_raw, ".") then
      nm = _apply_import_alias(state, nm_raw)
    else
      b0 = scope.cg_resolve_binding(state, nm_raw)
      if typeof(b0) != "struct" then
        nm = _qualify_identifier(state, nm_raw)
      end if
    end if
    return scope.emit_load_var_scoped(state, nm)
  end if

  if k == "Member" then
    mname = _coerce_name(expr.name)
    base_q = _expr_to_qualname(state, expr.target)
    if base_q != "" and mname != "" then
      base_q_m = _qualify_identifier(state, base_q)
      if base_q_m == "" then base_q_m = base_q end if

      // Static struct method reference: StructName.method -> StructName.__static__.method
      smap = _named_array_get(state.struct_static_methods, base_q_m)
      if typeof(smap) != "array" or len(smap) <= 0 then
        smap = _named_array_get(state.struct_static_methods, base_q)
      end if
      if typeof(smap) == "array" and len(smap) > 0 then
        sqfn = _method_map_get(smap, mname)
        if sqfn != "" then
          return scope.emit_load_var_scoped(state, sqfn)
        end if
      end if

      // Enum variant literal: Color.Red
      vars = _named_array_get(state.enum_variants, base_q_m)
      enum_base = base_q_m
      if typeof(vars) != "array" or len(vars) <= 0 then
        vars = _named_array_get(state.enum_variants, base_q)
        enum_base = base_q
      end if
      if typeof(vars) == "array" and len(vars) > 0 then
        for vi = 0 to len(vars) - 1
          if _coerce_name(vars[vi]) == mname then
            eid = _named_int_get(state.enum_ids, enum_base, -1)
            if eid >= 0 then
              state.asm = a.mov_rax_imm64(state.asm, t.enc_enum(eid, vi))
              return state
            end if
          end if
        end for
      end if

      // Namespace-qualified function/extern/struct/enum references.
      qmem = _apply_import_alias(state, base_q + "." + mname)
      qmem_q = _qualify_identifier(state, qmem)
      cands_b = t.arr_chunk_new(4)
      cands_b = t.arr_chunk_push(cands_b, qmem)
      cands = t.arr_chunk_finish(cands_b)
      if qmem_q != "" and _arr_has_str(cands, qmem_q) == false then
        cands_b = t.arr_chunk_push(cands_b, qmem_q)
        cands = t.arr_chunk_finish(cands_b)
      end if

      for ci = 0 to len(cands) - 1
        qc = cands[ci]
        bmem = scope.cg_resolve_binding(state, qc)
        if typeof(bmem) == "struct" then
          return scope.emit_load_var_scoped(state, qc)
        end if
        if typeof(_user_function_get(state, qc)) == "struct" then
          return scope.emit_load_var_scoped(state, qc)
        end if
        if _named_int_get(state.struct_ids, qc, 0) != 0 then
          return scope.emit_load_var_scoped(state, qc)
        end if
        if _named_int_get(state.enum_ids, qc, -1) >= 0 then
          return scope.emit_load_var_scoped(state, qc)
        end if
        if typeof(_extern_sig_get(state, qc)) == "struct" then
          return scope.emit_load_var_scoped(state, qc)
        end if
      end for
    end if

    // Runtime member read on struct instance.
    tgt = expr.target
    state = cg_emit_expr(state, tgt)

    fid_m = _next_lid(state)
    l_ok_m = "memb_ok_" + fid_m
    l_fail_m = "memb_fail_" + fid_m
    l_done_m = "memb_done_" + fid_m

    // TAG_PTR required
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_fail_m)

    // OBJ_STRUCT required
    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRUCT)
    state.asm = a.jcc(state.asm, "ne", l_fail_m)

    // edx = struct_id, dispatch -> ecx field index
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 8)
    state = _emit_struct_field_index_dispatch(state, mname, "edx", "ecx", l_ok_m, l_fail_m, "memb_" + fid_m)

    state.asm = a.mark(state.asm, l_ok_m)
    state.asm = a.mov_r64_mem_bis(state.asm, "rax", "r11", "rcx", 8, 16)
    state.asm = a.jmp(state.asm, l_done_m)

    state.asm = a.mark(state.asm, l_fail_m)
    lid_v = _next_lid(state)
    l_not_void = "memb_not_void_" + lid_v
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_VOID)
    state.asm = a.jcc(state.asm, "ne", l_not_void)
    state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot access member '" + mname + "' on void")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_done_m)

    state.asm = a.mark(state.asm, l_not_void)
    lid_t = _next_lid(state)
    l_is_ptr = "memb_isptr_" + lid_t
    l_is_struct = "memb_isstruct_" + lid_t

    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "e", l_is_ptr)
    state = _emit_make_error_const(state, c.ERR_MEMBER_TARGET_TYPE, "Cannot access member '" + mname + "' on non-struct value")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_done_m)

    state.asm = a.mark(state.asm, l_is_ptr)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRUCT)
    state.asm = a.jcc(state.asm, "e", l_is_struct)
    state = _emit_make_error_const(state, c.ERR_MEMBER_TARGET_TYPE, "Cannot access member '" + mname + "' on non-struct value")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_done_m)

    state.asm = a.mark(state.asm, l_is_struct)
    state = _emit_make_error_const(state, c.ERR_MEMBER_NOT_FOUND, "Struct has no member '" + mname + "'")
    state = _emit_auto_errprop(state)

    state.asm = a.mark(state.asm, l_done_m)
    return state
  end if

  if k == "Index" then
    tmp_idx_off = core.alloc_expr_temps(state, 16)
    tmp_idx_ok = true
    if typeof(tmp_idx_off) != "int" or tmp_idx_off <= 0 then
      tmp_idx_off = 0x180
      tmp_idx_ok = false
    end if
    tmp_tgt_off = tmp_idx_off
    tmp_sub_off = tmp_idx_off + 8

    state = cg_emit_expr(state, expr.target)
    state.asm = a.mov_rsp_disp32_rax(state.asm, tmp_tgt_off)
    state = cg_emit_expr(state, expr.index)
    state.asm = a.mov_rsp_disp32_rax(state.asm, tmp_sub_off)

    state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", tmp_tgt_off)  // target
    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", tmp_sub_off)  // index

    lid_ix = _next_lid(state)
    l_bad_target = "idx_bad_target_" + lid_ix
    l_bad_target_void = "idx_bad_target_void_" + lid_ix
    l_bad_index = "idx_bad_index_" + lid_ix
    l_bad_void = "idx_bad_void_" + lid_ix
    l_oob = "idx_oob_" + lid_ix
    l_isarr = "idx_isarr_" + lid_ix
    l_isbytes = "idx_isbytes_" + lid_ix
    l_isstr = "idx_isstr_" + lid_ix
    l_done = "idx_done_" + lid_ix

    // strict void index check
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_VOID)
    state.asm = a.jcc(state.asm, "e", l_bad_void)

    // strict index type check
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_bad_index)

    // target must be ptr and non-null
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_VOID)
    state.asm = a.jcc(state.asm, "e", l_bad_target_void)

    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_bad_target)
    state.asm = a.test_r64_r64(state.asm, "r10", "r10")
    state.asm = a.jcc(state.asm, "e", l_bad_target)

    // rcx = decoded index
    state.asm = a.mov_r64_r64(state.asm, "rcx", "r11")
    state.asm = a.sar_r64_imm8(state.asm, "rcx", 3)

    // dispatch by object type
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r10", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
    state.asm = a.jcc(state.asm, "e", l_isarr)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
    state.asm = a.jcc(state.asm, "e", l_isstr)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "e", l_isbytes)
    state.asm = a.jmp(state.asm, l_bad_target)

    state.asm = a.mark(state.asm, l_isarr)
    state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "r10", 4)
    lid_neg_a = _next_lid(state)
    l_nonneg_a = "idx_nonneg_a_" + lid_neg_a
    state.asm = a.cmp_r64_imm(state.asm, "rcx", 0)
    state.asm = a.jcc(state.asm, "ge", l_nonneg_a)
    state.asm = a.add_r64_r64(state.asm, "rcx", "r8")
    state.asm = a.mark(state.asm, l_nonneg_a)
    state.asm = a.cmp_r64_imm(state.asm, "rcx", 0)
    state.asm = a.jcc(state.asm, "l", l_oob)
    state.asm = a.cmp_r32_r32(state.asm, "ecx", "r8d")
    state.asm = a.jcc(state.asm, "ge", l_oob)
    state.asm = a.mov_r64_mem_bis(state.asm, "rax", "r10", "rcx", 8, 8)
    state.asm = a.jmp(state.asm, l_done)

    state.asm = a.mark(state.asm, l_isbytes)
    state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "r10", 4)
    lid_neg_b = _next_lid(state)
    l_nonneg_b = "idx_nonneg_b_" + lid_neg_b
    state.asm = a.cmp_r64_imm(state.asm, "rcx", 0)
    state.asm = a.jcc(state.asm, "ge", l_nonneg_b)
    state.asm = a.add_r64_r64(state.asm, "rcx", "r8")
    state.asm = a.mark(state.asm, l_nonneg_b)
    state.asm = a.cmp_r64_imm(state.asm, "rcx", 0)
    state.asm = a.jcc(state.asm, "l", l_oob)
    state.asm = a.cmp_r32_r32(state.asm, "ecx", "r8d")
    state.asm = a.jcc(state.asm, "ge", l_oob)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.add_r64_r64(state.asm, "rax", "rcx")
    state.asm = a.add_rax_imm8(state.asm, 8)
    state.asm = a.movzx_r32_membase_disp(state.asm, "eax", "rax", 0)
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
    state.asm = a.jmp(state.asm, l_done)

    state.asm = a.mark(state.asm, l_isstr)
    state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "r10", 4)
    lid_neg_s = _next_lid(state)
    l_nonneg_s = "idx_nonneg_s_" + lid_neg_s
    state.asm = a.cmp_r64_imm(state.asm, "rcx", 0)
    state.asm = a.jcc(state.asm, "ge", l_nonneg_s)
    state.asm = a.add_r64_r64(state.asm, "rcx", "r8")
    state.asm = a.mark(state.asm, l_nonneg_s)
    state.asm = a.cmp_r64_imm(state.asm, "rcx", 0)
    state.asm = a.jcc(state.asm, "l", l_oob)
    state.asm = a.cmp_r32_r32(state.asm, "ecx", "r8d")
    state.asm = a.jcc(state.asm, "ge", l_oob)

    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
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
    state.asm = a.jmp(state.asm, l_done)

    state.asm = a.mark(state.asm, l_bad_target)
    state = _emit_make_error_const(state, c.ERR_INDEX_TARGET_TYPE, "Indexing requires array, string, or bytes")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_done)

    state.asm = a.mark(state.asm, l_bad_target_void)
    state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot index void")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_done)

    state.asm = a.mark(state.asm, l_bad_index)
    state = _emit_make_error_const(state, c.ERR_INDEX_TYPE, "Index must be an int")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_done)

    state.asm = a.mark(state.asm, l_bad_void)
    state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot use void as index")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_done)

    state.asm = a.mark(state.asm, l_oob)
    state = _emit_make_error_const(state, c.ERR_INDEX_OOB, "Array index out of bounds")
    state = _emit_auto_errprop(state)

    state.asm = a.mark(state.asm, l_done)
    if tmp_idx_ok then state = core.free_expr_temps(state, 16) end if
    return state
  end if

  if k == "Unary" then
    state = cg_emit_expr(state, expr.right)
    if expr.op == "-" then
      lid_u = _next_lid(state)
      l_try_float_u = "uneg_try_float_" + lid_u
      l_fail_u = "uneg_fail_" + lid_u
      l_done_u = "uneg_done_" + lid_u
      state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
      state.asm = a.mov_r64_r64(state.asm, "r10", "r11")
      state.asm = a.and_r64_imm(state.asm, "r10", 7)
      state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
      state.asm = a.jcc(state.asm, "ne", l_try_float_u)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
      state.asm = a.neg_r64(state.asm, "rax")
      state.asm = a.shl_rax_imm8(state.asm, 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
      state.asm = a.jmp(state.asm, l_done_u)

      // float unary minus: 0.0 - x
      state.asm = a.mark(state.asm, l_try_float_u)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state = core.emit_to_double_xmm(state, 0, l_fail_u)
      state.asm = a.xorpd_xmm_xmm(state.asm, "xmm1", "xmm1")
      state.asm = a.subsd_xmm_xmm(state.asm, "xmm1", "xmm0")
      state.asm = a.movapd_xmm_xmm(state.asm, "xmm0", "xmm1")
      state = core.emit_normalize_xmm0_to_value(state)
      state.asm = a.jmp(state.asm, l_done_u)

      state.asm = a.mark(state.asm, l_fail_u)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      state.asm = a.mark(state.asm, l_done_u)
      return state
    end if
    if expr.op == "not" then
      lid_n = _next_lid(state)
      l_false = "not_false_" + lid_n
      l_end = "not_end_" + lid_n
      state = core.emit_jmp_if_false_rax(state, l_false)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
      state.asm = a.jmp(state.asm, l_end)
      state.asm = a.mark(state.asm, l_false)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
      state.asm = a.mark(state.asm, l_end)
      return state
    end if
    if expr.op == "~" then
      lid_b = _next_lid(state)
      l_done_b = "ubnot_done_" + lid_b
      l_end_b = "ubnot_end_" + lid_b
      state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
      state.asm = a.and_r64_imm(state.asm, "r10", 7)
      state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
      state.asm = a.jcc(state.asm, "ne", l_done_b)
      state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
      state.asm = a.xor_r64_imm(state.asm, "rax", -1)
      state.asm = a.shl_rax_imm8(state.asm, 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
      state.asm = a.jmp(state.asm, l_end_b)
      state.asm = a.mark(state.asm, l_done_b)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      state.asm = a.mark(state.asm, l_end_b)
      return state
    end if
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return state
  end if

  if k == "Bin" then
    if expr.op == "and" then
      lid_and = _next_lid(state)
      l_and_false = "and_false_" + lid_and
      l_and_end = "and_end_" + lid_and
      state = cg_emit_expr(state, expr.left)
      state = core.emit_jmp_if_false_rax(state, l_and_false)
      state = cg_emit_expr(state, expr.right)
      state = core.emit_jmp_if_false_rax(state, l_and_false)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
      state.asm = a.jmp(state.asm, l_and_end)
      state.asm = a.mark(state.asm, l_and_false)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
      state.asm = a.mark(state.asm, l_and_end)
      return state
    end if

    if expr.op == "or" then
      lid_or = _next_lid(state)
      l_or_eval = "or_eval_" + lid_or
      l_or_false = "or_false_" + lid_or
      l_or_end = "or_end_" + lid_or
      state = cg_emit_expr(state, expr.left)
      state = core.emit_jmp_if_false_rax(state, l_or_eval)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
      state.asm = a.jmp(state.asm, l_or_end)
      state.asm = a.mark(state.asm, l_or_eval)
      state = cg_emit_expr(state, expr.right)
      state = core.emit_jmp_if_false_rax(state, l_or_false)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
      state.asm = a.jmp(state.asm, l_or_end)
      state.asm = a.mark(state.asm, l_or_false)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
      state.asm = a.mark(state.asm, l_or_end)
      return state
    end if

    tmp_bin_off = core.alloc_expr_temps(state, 16)
    tmp_bin_ok = true
    if typeof(tmp_bin_off) != "int" or tmp_bin_off <= 0 then
      tmp_bin_off = 0x180
      tmp_bin_ok = false
    end if
    lhs_off = tmp_bin_off
    rhs_off = tmp_bin_off + 8

    state = cg_emit_expr(state, expr.left)
    state.asm = a.mov_rsp_disp32_rax(state.asm, lhs_off)
    state = cg_emit_expr(state, expr.right)
    state.asm = a.mov_rsp_disp32_rax(state.asm, rhs_off)

    state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", lhs_off)
    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", rhs_off)

    op = expr.op
    lid = _next_lid(state)
    l_int = "bin_int_" + lid
    l_float = "bin_float_" + lid
    l_str = "bin_str_" + lid
    l_cmp = "bin_cmp_" + lid
    l_fail = "bin_fail_" + lid
    l_done = "bin_done_" + lid

    if op == "==" or op == "!=" then
      l_lhs_not_bytes = "eq_lhs_not_bytes_" + lid
      l_bytes_only = "eq_bytes_only_" + lid
      l_call_val = "eq_call_val_" + lid
      l_done_eq = "eq_done_" + lid
      cc_enum = "e"
      if op == "!=" then cc_enum = "ne" end if
      eeid = _next_lid(state)
      l_no_enum = "eq_no_enum_" + eeid
      l_lhs_enum = "eq_lhs_enum_" + eeid
      l_rhs_enum = "eq_rhs_enum_" + eeid
      l_enum_enum = "eq_enum_enum_" + eeid
      l_enum_int = "eq_enum_int_" + eeid
      l_int_enum = "eq_int_enum_" + eeid

      // Enum equality extensions:
      // - enum == enum => compare ordinals only (cross-enum allowed)
      // - enum == int  => compare ordinal to int
      // - enum == other => false (or true for !=)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.and_rax_imm8(state.asm, 7)
      state.asm = a.cmp_rax_imm8(state.asm, c.TAG_ENUM)
      state.asm = a.jcc(state.asm, "e", l_lhs_enum)

      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state.asm = a.and_rax_imm8(state.asm, 7)
      state.asm = a.cmp_rax_imm8(state.asm, c.TAG_ENUM)
      state.asm = a.jcc(state.asm, "e", l_rhs_enum)
      state.asm = a.jmp(state.asm, l_no_enum)

      state.asm = a.mark(state.asm, l_lhs_enum)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state.asm = a.and_rax_imm8(state.asm, 7)
      state.asm = a.cmp_rax_imm8(state.asm, c.TAG_ENUM)
      state.asm = a.jcc(state.asm, "e", l_enum_enum)
      state.asm = a.cmp_rax_imm8(state.asm, c.TAG_INT)
      state.asm = a.jcc(state.asm, "e", l_enum_int)
      if op == "!=" then
        state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
      else
        state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
      end if
      state.asm = a.jmp(state.asm, l_done_eq)

      state.asm = a.mark(state.asm, l_rhs_enum)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.and_rax_imm8(state.asm, 7)
      state.asm = a.cmp_rax_imm8(state.asm, c.TAG_INT)
      state.asm = a.jcc(state.asm, "e", l_int_enum)
      if op == "!=" then
        state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
      else
        state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
      end if
      state.asm = a.jmp(state.asm, l_done_eq)

      state.asm = a.mark(state.asm, l_enum_enum)
      state.asm = a.mov_r64_r64(state.asm, "r8", "r10")
      state.asm = a.shr_r64_imm8(state.asm, "r8", 19)
      state.asm = a.mov_r64_r64(state.asm, "r9", "r11")
      state.asm = a.shr_r64_imm8(state.asm, "r9", 19)
      state.asm = a.cmp_r64_r64(state.asm, "r8", "r9")
      state.asm = a.setcc_al(state.asm, cc_enum)
      state.asm = a.movzx_eax_al(state.asm)
      state.asm = a.shl_rax_imm8(state.asm, 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_BOOL)
      state.asm = a.jmp(state.asm, l_done_eq)

      state.asm = a.mark(state.asm, l_enum_int)
      state.asm = a.mov_r64_r64(state.asm, "r8", "r10")
      state.asm = a.shr_r64_imm8(state.asm, "r8", 19)
      state.asm = a.mov_r64_r64(state.asm, "r9", "r11")
      state.asm = a.sar_r64_imm8(state.asm, "r9", 3)
      state.asm = a.cmp_r64_r64(state.asm, "r8", "r9")
      state.asm = a.setcc_al(state.asm, cc_enum)
      state.asm = a.movzx_eax_al(state.asm)
      state.asm = a.shl_rax_imm8(state.asm, 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_BOOL)
      state.asm = a.jmp(state.asm, l_done_eq)

      state.asm = a.mark(state.asm, l_int_enum)
      state.asm = a.mov_r64_r64(state.asm, "r8", "r10")
      state.asm = a.sar_r64_imm8(state.asm, "r8", 3)
      state.asm = a.mov_r64_r64(state.asm, "r9", "r11")
      state.asm = a.shr_r64_imm8(state.asm, "r9", 19)
      state.asm = a.cmp_r64_r64(state.asm, "r8", "r9")
      state.asm = a.setcc_al(state.asm, cc_enum)
      state.asm = a.movzx_eax_al(state.asm)
      state.asm = a.shl_rax_imm8(state.asm, 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_BOOL)
      state.asm = a.jmp(state.asm, l_done_eq)

      state.asm = a.mark(state.asm, l_no_enum)

      // lhs is bytes?
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.mov_r64_r64(state.asm, "r9", "rax")
      state.asm = a.and_r64_imm(state.asm, "r9", 7)
      state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_PTR)
      state.asm = a.jcc(state.asm, "ne", l_lhs_not_bytes)
      state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rax", 0)
      state.asm = a.cmp_r32_imm(state.asm, "r9d", c.OBJ_BYTES)
      state.asm = a.jcc(state.asm, "ne", l_lhs_not_bytes)

      // lhs bytes: rhs must also be bytes for value equality
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state.asm = a.mov_r64_r64(state.asm, "r9", "rax")
      state.asm = a.and_r64_imm(state.asm, "r9", 7)
      state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_PTR)
      state.asm = a.jcc(state.asm, "ne", l_bytes_only)
      state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rax", 0)
      state.asm = a.cmp_r32_imm(state.asm, "r9d", c.OBJ_BYTES)
      state.asm = a.jcc(state.asm, "ne", l_bytes_only)

      // both bytes -> content equality
      state.asm = a.mov_r64_r64(state.asm, "rcx", "r10")
      state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
      state.asm = a.call(state.asm, "fn_bytes_eq")
      if op == "!=" then
        state.asm = a.xor_r64_imm8(state.asm, "rax", 8)
      end if
      state.asm = a.jmp(state.asm, l_done_eq)

      // lhs not bytes: if rhs is bytes, result is false/true (== / !=)
      state.asm = a.mark(state.asm, l_lhs_not_bytes)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state.asm = a.mov_r64_r64(state.asm, "r9", "rax")
      state.asm = a.and_r64_imm(state.asm, "r9", 7)
      state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_PTR)
      state.asm = a.jcc(state.asm, "ne", l_call_val)
      state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rax", 0)
      state.asm = a.cmp_r32_imm(state.asm, "r9d", c.OBJ_BYTES)
      state.asm = a.jcc(state.asm, "e", l_bytes_only)

      // neither bytes -> generic value equality
      state.asm = a.mark(state.asm, l_call_val)
      state.asm = a.mov_r64_r64(state.asm, "rcx", "r10")
      state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
      state.asm = a.call(state.asm, "fn_val_eq")
      if op == "!=" then
        state.asm = a.xor_r64_imm8(state.asm, "rax", 8)
      end if
      state.asm = a.jmp(state.asm, l_done_eq)

      // one side bytes, the other not bytes
      state.asm = a.mark(state.asm, l_bytes_only)
      if op == "!=" then
        state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
      else
        state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
      end if

      state.asm = a.mark(state.asm, l_done_eq)
      if tmp_bin_ok then state = core.free_expr_temps(state, 16) end if
      return state
    end if

    if op == "/" then
      lid_divf = _next_lid(state)
      l_div_fail = "bin_div_fail_" + lid_divf
      l_div_done = "bin_div_done_" + lid_divf

      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state = core.emit_to_double_xmm(state, 0, l_div_fail)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state = core.emit_to_double_xmm(state, 1, l_div_fail)

      state.asm = a.xorpd_xmm_xmm(state.asm, "xmm2", "xmm2")
      state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm1", "xmm2")
      state.asm = a.jcc(state.asm, "e", l_div_fail)

      state.asm = a.divsd_xmm_xmm(state.asm, "xmm0", "xmm1")
      state = core.emit_normalize_xmm0_to_value(state)
      state.asm = a.jmp(state.asm, l_div_done)

      state.asm = a.mark(state.asm, l_div_fail)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      state.asm = a.mark(state.asm, l_div_done)
      if tmp_bin_ok then state = core.free_expr_temps(state, 16) end if
      return state
    end if

    if op == "<" or op == ">" or op == "<=" or op == ">=" then
      l_cmp_float = "bin_cmp_float_" + lid
      l_cmp_fail = "bin_cmp_fail_" + lid

      // int fast-path
      state.asm = a.mov_r64_r64(state.asm, "r9", "r10")
      state.asm = a.and_r64_imm(state.asm, "r9", 7)
      state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_INT)
      state.asm = a.jcc(state.asm, "ne", l_cmp_float)
      state.asm = a.mov_r64_r64(state.asm, "r9", "r11")
      state.asm = a.and_r64_imm(state.asm, "r9", 7)
      state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_INT)
      state.asm = a.jcc(state.asm, "ne", l_cmp_float)

      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
      state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
      state.asm = a.sar_r64_imm8(state.asm, "rdx", 3)
      state.asm = a.cmp_r64_r64(state.asm, "rax", "rdx")
      cc = "e"
      if op == "<" then cc = "l" end if
      if op == ">" then cc = "g" end if
      if op == "<=" then cc = "le" end if
      if op == ">=" then cc = "ge" end if
      state.asm = a.setcc_r8(state.asm, cc, "al")
      state.asm = a.movzx_eax_al(state.asm)
      state.asm = a.shl_rax_imm8(state.asm, 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_BOOL)
      state.asm = a.jmp(state.asm, l_done)

      // float numeric path
      state.asm = a.mark(state.asm, l_cmp_float)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state = core.emit_to_double_xmm(state, 0, l_cmp_fail)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state = core.emit_to_double_xmm(state, 1, l_cmp_fail)
      state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm1")

      ccf = "a"
      if op == "<" then ccf = "b" end if
      if op == "<=" then ccf = "be" end if
      if op == ">=" then ccf = "ae" end if
      state.asm = a.setcc_al(state.asm, ccf)
      state.asm = a.setcc_r8(state.asm, "p", "dl")
      state.asm = a.xor_r8_imm8(state.asm, "dl", 1)
      state.asm = a.and_r8_r8(state.asm, "al", "dl")
      state.asm = a.movzx_eax_al(state.asm)
      state.asm = a.shl_rax_imm8(state.asm, 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_BOOL)
      state.asm = a.jmp(state.asm, l_done)

      state.asm = a.mark(state.asm, l_cmp_fail)
      lid_cmpv = _next_lid(state)
      l_cmp_nvoid = "cmp_nvoid_" + lid_cmpv
      l_cmp_isvoid = "cmp_isvoid_" + lid_cmpv

      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.and_rax_imm8(state.asm, 7)
      state.asm = a.cmp_rax_imm8(state.asm, c.TAG_VOID)
      state.asm = a.jcc(state.asm, "e", l_cmp_isvoid)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state.asm = a.and_rax_imm8(state.asm, 7)
      state.asm = a.cmp_rax_imm8(state.asm, c.TAG_VOID)
      state.asm = a.jcc(state.asm, "ne", l_cmp_nvoid)

      state.asm = a.mark(state.asm, l_cmp_isvoid)
      state = core.emit_dbg_line(state, expr)
      state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot apply '" + op + "' to void")
      state = _emit_auto_errprop(state)
      state.asm = a.jmp(state.asm, l_done)

      state.asm = a.mark(state.asm, l_cmp_nvoid)
      state = core.emit_dbg_line(state, expr)
      state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot apply '" + op + "' to non-numeric values")
      state = _emit_auto_errprop(state)
      state.asm = a.jmp(state.asm, l_done)

      state.asm = a.mark(state.asm, l_done)
      if tmp_bin_ok then state = core.free_expr_temps(state, 16) end if
      return state
    end if

    want_float_arith = op == "+" or op == "-" or op == "*" or op == "%"

    // integer tag checks (for -,*,% we also allow numeric float fallback)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_INT)
    if want_float_arith then
      state.asm = a.jcc(state.asm, "ne", l_float)
    else
      state.asm = a.jcc(state.asm, "ne", l_fail)
    end if
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_INT)
    if want_float_arith then
      state.asm = a.jcc(state.asm, "ne", l_float)
    else
      state.asm = a.jcc(state.asm, "ne", l_fail)
    end if
    state.asm = a.jmp(state.asm, l_int)

    state.asm = a.mark(state.asm, l_int)
    if op == "+" then
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.add_r64_r64(state.asm, "rax", "r11")
      state.asm = a.sub_rax_imm8(state.asm, c.TAG_INT)
      state.asm = a.jmp(state.asm, l_done)
    end if
    if op == "-" then
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.sub_r64_r64(state.asm, "rax", "r11")
      state.asm = a.add_rax_imm8(state.asm, c.TAG_INT)
      state.asm = a.jmp(state.asm, l_done)
    end if
    if op == "*" then
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
      state.asm = a.mov_r64_r64(state.asm, "r11", "r11")
      state.asm = a.sar_r64_imm8(state.asm, "r11", 3)
      state.asm = a.imul_r64_r64(state.asm, "rax", "r11")
      state.asm = a.shl_rax_imm8(state.asm, 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
      state.asm = a.jmp(state.asm, l_done)
    end if
    if op == "/" then
      lid_div = _next_lid(state)
      l_divz = "bin_divz_" + lid_div
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
      state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
      state.asm = a.jcc(state.asm, "e", l_divz)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
      state.asm = a.mov_r64_r64(state.asm, "r11", "r11")
      state.asm = a.sar_r64_imm8(state.asm, "r11", 3)
      state.asm = a.cqo(state.asm)
      state.asm = a.idiv_r64(state.asm, "r11")
      state.asm = a.shl_rax_imm8(state.asm, 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
      state.asm = a.jmp(state.asm, l_done)
      state.asm = a.mark(state.asm, l_divz)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      state.asm = a.jmp(state.asm, l_done)
    end if
    if op == "%" then
      lid_mod = _next_lid(state)
      l_modz = "bin_modz_" + lid_mod
      l_modok = "bin_modok_" + lid_mod
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
      state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
      state.asm = a.jcc(state.asm, "e", l_modz)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
      state.asm = a.mov_r64_r64(state.asm, "r11", "r11")
      state.asm = a.sar_r64_imm8(state.asm, "r11", 3)
      state.asm = a.cqo(state.asm)
      state.asm = a.idiv_r64(state.asm, "r11")
      state.asm = a.test_r64_r64(state.asm, "rdx", "rdx")
      state.asm = a.jcc(state.asm, "e", l_modok)
      state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")
      state.asm = a.xor_r64_r64(state.asm, "rax", "r11")
      state.asm = a.test_r64_r64(state.asm, "rax", "rax")
      state.asm = a.jcc(state.asm, "ge", l_modok)
      state.asm = a.add_r64_r64(state.asm, "rdx", "r11")
      state.asm = a.mark(state.asm, l_modok)
      state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")
      state.asm = a.shl_rax_imm8(state.asm, 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
      state.asm = a.jmp(state.asm, l_done)
      state.asm = a.mark(state.asm, l_modz)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      state.asm = a.jmp(state.asm, l_done)
    end if
    if op == "&" then
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.and_r64_r64(state.asm, "rax", "r11")
      state.asm = a.jmp(state.asm, l_done)
    end if
    if op == "|" then
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.or_r64_r64(state.asm, "rax", "r11")
      state.asm = a.jmp(state.asm, l_done)
    end if
    if op == "^" then
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.xor_r64_r64(state.asm, "rax", "r11")
      state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
      state.asm = a.jmp(state.asm, l_done)
    end if
    if op == "<<" or op == ">>" then
      lid_sh = _next_lid(state)
      l_sh_bad = "bin_sh_bad_" + lid_sh
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
      state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
      state.asm = a.jcc(state.asm, "l", l_sh_bad)
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.and_r64_imm(state.asm, "rcx", 63)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
      if op == "<<" then
        state.asm = a.shl_r64_cl(state.asm, "rax")
      else
        state.asm = a.sar_r64_cl(state.asm, "rax")
      end if
      state.asm = a.shl_rax_imm8(state.asm, 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
      state.asm = a.jmp(state.asm, l_done)
      state.asm = a.mark(state.asm, l_sh_bad)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      state.asm = a.jmp(state.asm, l_done)
    end if

    if want_float_arith then
      state.asm = a.mark(state.asm, l_float)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state = core.emit_to_double_xmm(state, 0, l_fail)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state = core.emit_to_double_xmm(state, 1, l_fail)

      if op == "+" then
        state.asm = a.addsd_xmm_xmm(state.asm, "xmm0", "xmm1")
      end if
      if op == "-" then
        state.asm = a.subsd_xmm_xmm(state.asm, "xmm0", "xmm1")
      end if
      if op == "*" then
        state.asm = a.mulsd_xmm_xmm(state.asm, "xmm0", "xmm1")
      end if
      if op == "%" then
        // float modulo with Python semantics: r = a - floor(a/b)*b
        state.asm = a.xorpd_xmm_xmm(state.asm, "xmm2", "xmm2")
        state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm1", "xmm2")
        state.asm = a.jcc(state.asm, "e", l_fail)
        state.asm = a.movapd_xmm_xmm(state.asm, "xmm3", "xmm0")
        state.asm = a.divsd_xmm_xmm(state.asm, "xmm0", "xmm1")
        state.asm = a.roundsd_xmm_xmm_imm8(state.asm, "xmm2", "xmm0", 1)
        state.asm = a.mulsd_xmm_xmm(state.asm, "xmm2", "xmm1")
        state.asm = a.subsd_xmm_xmm(state.asm, "xmm3", "xmm2")
        state.asm = a.movapd_xmm_xmm(state.asm, "xmm0", "xmm3")
      end if

      state = core.emit_normalize_xmm0_to_value(state)
      state.asm = a.jmp(state.asm, l_done)
    end if

    if op == "<" or op == ">" or op == "<=" or op == ">=" then
      l_cmp_float = "bin_cmp_float_" + lid
      l_cmp_fail = "bin_cmp_fail_" + lid

      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
      state.asm = a.mov_r64_r64(state.asm, "r9", "r10")
      state.asm = a.and_r64_imm(state.asm, "r9", 7)
      state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_INT)
      state.asm = a.jcc(state.asm, "ne", l_cmp_float)

      state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
      state.asm = a.sar_r64_imm8(state.asm, "rdx", 3)
      state.asm = a.mov_r64_r64(state.asm, "r9", "r11")
      state.asm = a.and_r64_imm(state.asm, "r9", 7)
      state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_INT)
      state.asm = a.jcc(state.asm, "ne", l_cmp_float)

      state.asm = a.cmp_r64_r64(state.asm, "rax", "rdx")
      cc = "e"
      if op == "<" then cc = "l" end if
      if op == ">" then cc = "g" end if
      if op == "<=" then cc = "le" end if
      if op == ">=" then cc = "ge" end if
      state.asm = a.setcc_r8(state.asm, cc, "al")
      state.asm = a.movzx_eax_al(state.asm)
      state.asm = a.shl_rax_imm8(state.asm, 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_BOOL)
      state.asm = a.jmp(state.asm, l_done)

      state.asm = a.mark(state.asm, l_cmp_float)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state = core.emit_to_double_xmm(state, 0, l_cmp_fail)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state = core.emit_to_double_xmm(state, 1, l_cmp_fail)
      state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm1")

      ccf = "a"
      if op == "<" then ccf = "b" end if
      if op == "<=" then ccf = "be" end if
      if op == ">=" then ccf = "ae" end if
      state.asm = a.setcc_al(state.asm, ccf)
      state.asm = a.setcc_r8(state.asm, "p", "dl")
      state.asm = a.xor_r8_imm8(state.asm, "dl", 1)
      state.asm = a.and_r8_r8(state.asm, "al", "dl")
      state.asm = a.movzx_eax_al(state.asm)
      state.asm = a.shl_rax_imm8(state.asm, 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_BOOL)
      state.asm = a.jmp(state.asm, l_done)

      state.asm = a.mark(state.asm, l_cmp_fail)
      lid_cmpv = _next_lid(state)
      l_cmp_nvoid = "cmp_nvoid_" + lid_cmpv
      l_cmp_isvoid = "cmp_isvoid_" + lid_cmpv

      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.and_rax_imm8(state.asm, 7)
      state.asm = a.cmp_rax_imm8(state.asm, c.TAG_VOID)
      state.asm = a.jcc(state.asm, "e", l_cmp_isvoid)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state.asm = a.and_rax_imm8(state.asm, 7)
      state.asm = a.cmp_rax_imm8(state.asm, c.TAG_VOID)
      state.asm = a.jcc(state.asm, "ne", l_cmp_nvoid)

      state.asm = a.mark(state.asm, l_cmp_isvoid)
      state = core.emit_dbg_line(state, expr)
      state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot apply '" + op + "' to void")
      state = _emit_auto_errprop(state)
      state.asm = a.jmp(state.asm, l_done)

      state.asm = a.mark(state.asm, l_cmp_nvoid)
      state = core.emit_dbg_line(state, expr)
      state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot apply '" + op + "' to non-numeric values")
      state = _emit_auto_errprop(state)
      state.asm = a.jmp(state.asm, l_done)
    end if

    state.asm = a.jmp(state.asm, l_fail)

    state.asm = a.mark(state.asm, l_fail)
    if op == "+" then
      l_add_arr = "bin_add_arr_" + lid
      l_add_bytes = "bin_add_bytes_" + lid
      l_add_bytes_check2 = "bin_add_bytes_check2_" + lid
      l_add_bytes_after = "bin_add_bytes_after_" + lid
      l_add_bytes_fail = "bin_add_bytes_fail_" + lid
      l_add_str = "bin_add_str_" + lid

      // lhs bytes?
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.and_rax_imm8(state.asm, 7)
      state.asm = a.cmp_rax_imm8(state.asm, c.TAG_PTR)
      state.asm = a.jcc(state.asm, "ne", l_add_bytes_check2)
      state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r10", 0)
      state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
      state.asm = a.jcc(state.asm, "e", l_add_bytes)

      // lhs not bytes: if rhs is bytes, mixed add is an error.
      state.asm = a.mark(state.asm, l_add_bytes_check2)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state.asm = a.and_rax_imm8(state.asm, 7)
      state.asm = a.cmp_rax_imm8(state.asm, c.TAG_PTR)
      state.asm = a.jcc(state.asm, "ne", l_add_bytes_after)
      state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
      state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
      state.asm = a.jcc(state.asm, "e", l_add_bytes_fail)
      state.asm = a.mark(state.asm, l_add_bytes_after)

      // array + array -> fn_add_array
      state.asm = a.mark(state.asm, l_add_arr)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.and_rax_imm8(state.asm, 7)
      state.asm = a.cmp_rax_imm8(state.asm, c.TAG_PTR)
      state.asm = a.jcc(state.asm, "ne", l_add_str)
      state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r10", 0)
      state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
      state.asm = a.jcc(state.asm, "ne", l_add_str)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state.asm = a.and_rax_imm8(state.asm, 7)
      state.asm = a.cmp_rax_imm8(state.asm, c.TAG_PTR)
      state.asm = a.jcc(state.asm, "ne", l_add_str)
      state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
      state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
      state.asm = a.jcc(state.asm, "ne", l_add_str)
      state.asm = a.mov_r64_r64(state.asm, "rcx", "r10")
      state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
      state.asm = a.call(state.asm, "fn_add_array")
      state.asm = a.jmp(state.asm, l_done)

      // bytes + bytes
      state.asm = a.mark(state.asm, l_add_bytes)
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state.asm = a.and_rax_imm8(state.asm, 7)
      state.asm = a.cmp_rax_imm8(state.asm, c.TAG_PTR)
      state.asm = a.jcc(state.asm, "ne", l_add_bytes_fail)
      state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
      state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
      state.asm = a.jcc(state.asm, "ne", l_add_bytes_fail)
      state.asm = a.mov_r64_r64(state.asm, "rcx", "r10")
      state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
      state.asm = a.call(state.asm, "fn_add_bytes")
      state.asm = a.jmp(state.asm, l_done)

      // bytes mixed types => error
      state.asm = a.mark(state.asm, l_add_bytes_fail)
      state = core.emit_dbg_line(state, expr)
      state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot add bytes with non-bytes")
      state = _emit_auto_errprop(state)
      state.asm = a.jmp(state.asm, l_done)

      // fallback: string-style concatenation via value_to_string conversion.
      state.asm = a.mark(state.asm, l_add_str)
      state.asm = a.mov_r64_r64(state.asm, "rcx", "r10")
      state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
      state.asm = a.call(state.asm, "fn_add_string")
      state = _emit_auto_errprop(state)
      state.asm = a.jmp(state.asm, l_done)
    end if

    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    state.asm = a.mark(state.asm, l_done)
    if tmp_bin_ok then state = core.free_expr_temps(state, 16) end if
    return state
  end if

  if k == "Call" then
    // Keep callsite line current so runtime-created errors carry correct origin.
    state = core.emit_dbg_line(state, expr)
    state.call_total_count = state.call_total_count + 1
    cal = expr.callee
    if typeof(cal) != "struct" then cal = expr.func end if
    args = expr.args
    if typeof(args) != "array" then args = [] end if
    call_args = args
    nargs = len(call_args)
    member_runtime = false

    pre_raw = ""
    if typeof(cal) == "struct" and cal.node_kind == "Var" and typeof(cal.name) == "string" then
      pre_raw = cal.name
    end if
    if pre_raw == "try" and nargs == 1 then
      old_sup = 0
      if typeof(state.errprop_suppression) == "int" then old_sup = state.errprop_suppression end if
      state.errprop_suppression = old_sup + 1
      state = cg_emit_expr(state, args[0])
      state.errprop_suppression = old_sup
      return state
    end if

    callee = ""
    raw_name = ""
    if typeof(cal) == "struct" then
      if cal.node_kind == "Member" then
        tgt_rt = cal.target
        if typeof(tgt_rt) != "struct" then tgt_rt = cal.obj end if
        if typeof(tgt_rt) == "struct" then
          if tgt_rt.node_kind == "Var" then
            base_rt = _coerce_name(tgt_rt.name)
            if base_rt != "" then
              b_rt = scope.cg_resolve_binding(state, base_rt)
              if typeof(b_rt) == "struct" then
                bk_rt = _coerce_name(b_rt.kind)
                if bk_rt == "local" or bk_rt == "param" or bk_rt == "capture" then
                  member_runtime = true
                else
                  base_q_rt = _qualify_identifier(state, base_rt)
                  flds_rt = _named_array_get(state.struct_fields, base_q_rt)
                  if typeof(flds_rt) != "array" then
                    member_runtime = true
                  end if
                end if
              end if
            end if
          else
            tq_rt = _expr_to_qualname(state, tgt_rt)
            if tq_rt == "" then
              member_runtime = true
            else
              tq_a = _apply_import_alias(state, tq_rt)
              tq_q = _qualify_identifier(state, tq_a)
              target_compile = false
              if typeof(_named_array_get(state.struct_fields, tq_a)) == "array" then target_compile = true end if
              if typeof(_named_array_get(state.struct_fields, tq_q)) == "array" then target_compile = true end if
              if typeof(_user_function_get(state, tq_a)) == "struct" then target_compile = true end if
              if typeof(_user_function_get(state, tq_q)) == "struct" then target_compile = true end if
              if _named_int_get(state.struct_ids, tq_a, 0) != 0 then target_compile = true end if
              if _named_int_get(state.struct_ids, tq_q, 0) != 0 then target_compile = true end if
              if _named_int_get(state.enum_ids, tq_a, -1) >= 0 then target_compile = true end if
              if _named_int_get(state.enum_ids, tq_q, -1) >= 0 then target_compile = true end if
              if typeof(_extern_sig_get(state, tq_a)) == "struct" then target_compile = true end if
              if typeof(_extern_sig_get(state, tq_q)) == "struct" then target_compile = true end if
              if target_compile == false then
                member_runtime = true
              end if
            end if
          end if
        else
          member_runtime = true
        end if
      end if
      if cal.node_kind == "Var" then
        if typeof(cal.name) == "string" then raw_name = cal.name end if
        if raw_name == "try" or raw_name == "error" or raw_name == "bytes" or raw_name == "byteBuffer" then
          callee = raw_name
        else
          callee = _qualify_identifier(state, raw_name)
        end if
      else
        if cal.node_kind == "Member" then
          callee = _expr_to_qualname(state, cal)
        end if
      end if
    end if
    if callee == "" and raw_name != "" then callee = raw_name end if

    // OOP-style struct instance call: obj.method(args...)
    // Compile as dynamic dispatch on receiver.struct_id -> direct call of hoisted method body.
    if typeof(cal) == "struct" and cal.node_kind == "Member" and member_runtime then
      mname_dyn = _coerce_name(cal.name)
      if mname_dyn == "" then mname_dyn = _coerce_name(cal.field) end if
      tgt_dyn = cal.target
      if typeof(tgt_dyn) != "struct" then tgt_dyn = cal.obj end if

      if mname_dyn != "" and typeof(state.struct_methods) == "array" and len(state.struct_methods) > 0 then
        cand_b = t.arr_chunk_new(16)
        total_dyn = nargs + 1

        for smi = 0 to len(state.struct_methods) - 1
          sm_it = state.struct_methods[smi]
          sqn_dyn = ""
          md_dyn = 0
          if typeof(sm_it) == "struct" then
            sqn_dyn = _coerce_name(sm_it.key)
            md_dyn = sm_it.values
          else
            if typeof(sm_it) == "array" and len(sm_it) >= 2 then
              sqn_dyn = _coerce_name(sm_it[0])
              md_dyn = sm_it[1]
            end if
          end if
          if sqn_dyn == "" or typeof(md_dyn) != "array" or len(md_dyn) <= 0 then continue end if

          fnq_dyn = _method_map_get(md_dyn, mname_dyn)
          if fnq_dyn == "" then continue end if
          fndef_dyn = _user_function_get(state, fnq_dyn)
          if typeof(fndef_dyn) != "struct" then continue end if
          exp_dyn = 0
          if typeof(fndef_dyn.params) == "array" then exp_dyn = len(fndef_dyn.params) end if
          if exp_dyn != total_dyn then continue end if

          sid_dyn = _named_int_get(state.struct_ids, sqn_dyn, -1)
          if sid_dyn < 0 then continue end if
          cand_b = t.arr_chunk_push(cand_b, [sid_dyn, fnq_dyn])
        end for

        cands_dyn = t.arr_chunk_finish(cand_b)
        if typeof(cands_dyn) == "array" and len(cands_dyn) > 0 then
          base_dyn = core.alloc_expr_temps(state, total_dyn * 8)
          if typeof(base_dyn) != "int" or base_dyn <= 0 then
            base_dyn = 0x300
          end if

          // Evaluate receiver + args into temp slots (left-to-right).
          state = cg_emit_expr(state, tgt_dyn)
          state.asm = a.mov_rsp_disp32_rax(state.asm, base_dyn)
          if nargs > 0 then
            for ai_dyn = 0 to nargs - 1
              state = cg_emit_expr(state, call_args[ai_dyn])
              state.asm = a.mov_membase_disp_r64(state.asm, "rsp", base_dyn + (ai_dyn + 1) * 8, "rax")
            end for
          end if

          // Marshal args (rcx, rdx, r8, r9, then stack at rsp+0x20).
          if total_dyn >= 1 then state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", base_dyn + 0 * 8) end if
          if total_dyn >= 2 then state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", base_dyn + 1 * 8) end if
          if total_dyn >= 3 then state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", base_dyn + 2 * 8) end if
          if total_dyn >= 4 then state.asm = a.mov_r64_membase_disp(state.asm, "r9", "rsp", base_dyn + 3 * 8) end if
          dyn_stack_save_off = 0
          dyn_stack_save_count = 0
          dyn_stack_save_alloc = false
          if total_dyn > 8 then
            dyn_stack_save_count = total_dyn - 8
            dyn_stack_save_bytes = dyn_stack_save_count * 8
            dyn_stack_save_off = core.alloc_expr_temps(state, dyn_stack_save_bytes)
            if typeof(dyn_stack_save_off) == "int" and dyn_stack_save_off > 0 then
              dyn_stack_save_alloc = true
              for ssi_dyn = 0 to dyn_stack_save_count - 1
                state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x40 + ssi_dyn * 8)
                state.asm = a.mov_membase_disp_r64(state.asm, "rsp", dyn_stack_save_off + ssi_dyn * 8, "r10")
              end for
            else
              dyn_stack_save_count = 0
            end if
          end if
          if total_dyn > 4 then
            for si_dyn = 4 to total_dyn - 1
              state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", base_dyn + si_dyn * 8)
              disp_dyn = 0x20 + (si_dyn - 4) * 8
              state.asm = a.mov_membase_disp_r64(state.asm, "rsp", disp_dyn, "r10")
            end for
          end if

          fid_dyn = _next_lid(state)
          l_ok_dyn = "mcall_ok_" + fid_dyn
          l_fail_dyn = "mcall_fail_" + fid_dyn
          l_done_dyn = "mcall_done_" + fid_dyn

          // Receiver must be struct ptr.
          state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", base_dyn)
          state.asm = a.mov_r64_r64(state.asm, "r10", "r11")
          state.asm = a.and_r64_imm(state.asm, "r10", 7)
          state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
          state.asm = a.jcc(state.asm, "ne", l_fail_dyn)
          state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 0)
          state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_STRUCT)
          state.asm = a.jcc(state.asm, "ne", l_fail_dyn)
          // Keep argument registers intact (rdx carries arg1); use r10d for dispatch id.
          state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 8)

          for ci_dyn = 0 to len(cands_dyn) - 1
            c_dyn = cands_dyn[ci_dyn]
            sid_dyn2 = -1
            fnq_dyn2 = ""
            if typeof(c_dyn) == "array" and len(c_dyn) >= 2 then
              if typeof(c_dyn[0]) == "int" then sid_dyn2 = c_dyn[0] end if
              fnq_dyn2 = _coerce_name(c_dyn[1])
            end if
            if sid_dyn2 < 0 or fnq_dyn2 == "" then continue end if
            l_next_dyn = "mcall_next_" + fid_dyn + "_" + ci_dyn
            state.asm = a.cmp_r32_imm(state.asm, "r10d", sid_dyn2)
            state.asm = a.jcc(state.asm, "ne", l_next_dyn)
            state.asm = a.mov_r64_imm64(state.asm, "r10", t.enc_void())
            state.asm = a.call(state.asm, "fn_user_" + fnq_dyn2)
            state.asm = a.jmp(state.asm, l_ok_dyn)
            state.asm = a.mark(state.asm, l_next_dyn)
          end for

          state.asm = a.mark(state.asm, l_fail_dyn)
          state = _emit_make_error_const(state, c.ERR_METHOD_NOT_FOUND, "No matching method '" + mname_dyn + "' for receiver")
          state = _emit_auto_errprop(state)
          state.asm = a.jmp(state.asm, l_done_dyn)

          state.asm = a.mark(state.asm, l_ok_dyn)
          state.asm = a.mark(state.asm, l_done_dyn)
          if dyn_stack_save_count > 0 then
            for ssi_dyn2 = 0 to dyn_stack_save_count - 1
              state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", dyn_stack_save_off + ssi_dyn2 * 8)
              state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x40 + ssi_dyn2 * 8, "r10")
            end for
            if dyn_stack_save_alloc then
              state = core.release_expr_temps(state, dyn_stack_save_count * 8)
            end if
          end if
          state = core.free_expr_temps(state, total_dyn * 8)
          return state
        end if
      end if
    end if

    // Type-qualified helper instance method call without receiver:
    // allow `S.helper(x)` if helper does not use `this`.
    if callee != "" and _is_instance_method_qname(state, callee) then
      fnh = _user_function_get(state, callee)
      if typeof(fnh) == "struct" then
        expected_h = 0
        if typeof(fnh.params) == "array" then expected_h = len(fnh.params) end if
        if nargs == expected_h - 1 then
          if _fn_uses_this(fnh) == false then
            call_args = [0] + call_args
            nargs = len(call_args)
          else
            state.diagnostics = state.diagnostics + [
              "Cannot call instance method '" + callee + "' without receiver because it uses 'this'."
            ]
            state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
            return state
          end if
        else
          if nargs != expected_h then
            exp_implicit = expected_h - 1
            if exp_implicit < 0 then exp_implicit = 0 end if
            state.diagnostics = state.diagnostics + [
              "Method " + callee + " expects either " + exp_implicit + " args (implicit receiver) or " + expected_h + " args (explicit receiver), got " + nargs
            ]
            state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
            return state
          end if
        end if
      end if
    end if

    if nargs > 32 then
      state.diagnostics = state.diagnostics +["Too many call arguments: " + nargs]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return state
    end if

    // Direct extern calls are emitted through ABI conversion glue.
    ex_name = callee
    if ex_name == "" then ex_name = raw_name end if
    ex_sig = _extern_sig_get(state, ex_name)
    if typeof(ex_sig) != "struct" and raw_name != "" and raw_name != ex_name then
      ex_sig = _extern_sig_get(state, raw_name)
      if typeof(ex_sig) == "struct" then ex_name = raw_name end if
    end if
    if typeof(ex_sig) == "struct" then
      return _emit_extern_call(state, expr, call_args, "", ex_name, 0)
    end if

    // Builtin typeof/typeName must handle type identifiers without evaluating them as variables.
    if (callee == "typeof" or raw_name == "typeof") and nargs == 1 then
      arg0 = call_args[0]
      arg_name = _expr_to_qualname(state, arg0)
      if arg_name != "" then arg_name = _apply_import_alias(state, arg_name) end if
      if arg_name != "" then
        flds0 = _named_array_get(state.struct_fields, arg_name)
        if typeof(flds0) == "array" then
          state.asm = a.lea_rax_rip(state.asm, "obj_type_struct")
          return state
        end if
        if _named_int_get(state.enum_ids, arg_name, -1) >= 0 then
          state.asm = a.lea_rax_rip(state.asm, "obj_type_enum")
          return state
        end if
        if s.contains(arg_name, ".") then
          ps_t = s.split(arg_name, ".")
          if typeof(ps_t) == "array" and len(ps_t) >= 2 then
            v_t = _coerce_name(ps_t[len(ps_t) - 1])
            bp_t = slice(ps_t, 0, len(ps_t) - 1)
            if typeof(bp_t) != "array" then bp_t = [] end if
            b_t = _apply_import_alias(state, s.join(bp_t, "."))
            vars_t = _named_array_get(state.enum_variants, b_t)
            if _named_int_get(state.enum_ids, b_t, -1) >= 0 and typeof(vars_t) == "array" and _arr_has_str(vars_t, v_t) then
              state.asm = a.lea_rax_rip(state.asm, "obj_type_enum")
              return state
            end if
          end if
        end if
      end if
      state = cg_emit_expr(state, arg0)
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.call(state.asm, "fn_typeof")
      return state
    end if

    if (callee == "typeName" or raw_name == "typeName") and nargs == 1 then
      arg1 = call_args[0]
      argn = _expr_to_qualname(state, arg1)
      if argn != "" then argn = _apply_import_alias(state, argn) end if

      if argn != "" then
        flds1 = _named_array_get(state.struct_fields, argn)
        if typeof(flds1) == "array" then
          lbl_s = _strpair_get(state.typename_struct_by_qname, argn)
          if lbl_s != "" then
            state.asm = a.lea_rax_rip(state.asm, lbl_s)
          else
            state.asm = a.lea_rax_rip(state.asm, "obj_type_struct")
          end if
          return state
        end if

        if _named_int_get(state.enum_ids, argn, -1) >= 0 then
          lbl_e = _strpair_get(state.typename_enum_by_qname, argn)
          if lbl_e != "" then
            state.asm = a.lea_rax_rip(state.asm, lbl_e)
          else
            state.asm = a.lea_rax_rip(state.asm, "obj_type_enum")
          end if
          return state
        end if

        if s.contains(argn, ".") then
          ps_n = s.split(argn, ".")
          if typeof(ps_n) == "array" and len(ps_n) >= 2 then
            vn_n = _coerce_name(ps_n[len(ps_n) - 1])
            bp_n = slice(ps_n, 0, len(ps_n) - 1)
            if typeof(bp_n) != "array" then bp_n = [] end if
            b_n = _apply_import_alias(state, s.join(bp_n, "."))
            vars_n = _named_array_get(state.enum_variants, b_n)
            if _named_int_get(state.enum_ids, b_n, -1) >= 0 and typeof(vars_n) == "array" and _arr_has_str(vars_n, vn_n) then
              lbl_be = _strpair_get(state.typename_enum_by_qname, b_n)
              if lbl_be != "" then
                state.asm = a.lea_rax_rip(state.asm, lbl_be)
              else
                state.asm = a.lea_rax_rip(state.asm, "obj_type_enum")
              end if
              return state
            end if
          end if
        end if
      end if

      state = cg_emit_expr(state, arg1)
      lid_tn = _next_lid(state)
      l_tn_fallback = "tn_call_fallback_" + lid_tn
      l_tn_done = "tn_call_done_" + lid_tn
      l_tn_ptr = "tn_call_ptr_" + lid_tn
      l_tn_sid = "tn_call_sid_" + lid_tn

      // Fast path for struct instances/types with concrete names.
      state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
      state.asm = a.and_r64_imm(state.asm, "r10", 7)
      state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
      state.asm = a.jcc(state.asm, "ne", l_tn_fallback)

      state.asm = a.mark(state.asm, l_tn_ptr)
      state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "rax", 0)
      state.asm = a.cmp_r32_imm(state.asm, "r11d", c.OBJ_STRUCT)
      state.asm = a.jcc(state.asm, "e", l_tn_sid)
      state.asm = a.cmp_r32_imm(state.asm, "r11d", c.OBJ_STRUCTTYPE)
      state.asm = a.jcc(state.asm, "ne", l_tn_fallback)

      state.asm = a.mark(state.asm, l_tn_sid)
      state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 8)
      if typeof(state.typename_struct_by_id) == "array" and len(state.typename_struct_by_id) > 0 then
        for tsi = 0 to len(state.typename_struct_by_id) - 1
          it_tn = state.typename_struct_by_id[tsi]
          sid_tn = -1
          lbl_tn = ""
          if typeof(it_tn) == "array" and len(it_tn) >= 2 then
            if typeof(it_tn[0]) == "int" then sid_tn = it_tn[0] end if
            if typeof(it_tn[1]) == "string" then lbl_tn = it_tn[1] end if
          else
            if typeof(it_tn) == "struct" then
              if typeof(it_tn.key) == "int" then sid_tn = it_tn.key end if
              if typeof(it_tn.value) == "string" then lbl_tn = it_tn.value end if
            end if
          end if
          if sid_tn < 0 or lbl_tn == "" then continue end if
          l_tn_next = "tn_call_snext_" + sid_tn + "_" + lid_tn + "_" + tsi
          state.asm = a.cmp_r32_imm(state.asm, "edx", sid_tn)
          state.asm = a.jcc(state.asm, "ne", l_tn_next)
          state.asm = a.lea_rax_rip(state.asm, lbl_tn)
          state.asm = a.jmp(state.asm, l_tn_done)
          state.asm = a.mark(state.asm, l_tn_next)
        end for
      end if

      state.asm = a.mark(state.asm, l_tn_fallback)
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.call(state.asm, "fn_typeName")
      state.asm = a.mark(state.asm, l_tn_done)
      return state
    end if

    // Evaluate args left-to-right into a nested-safe temp area first.
    // Nested calls inside argument expressions can use rsp+0x20 too, so we
    // must not build the outer call argument vector there directly.
    call_args_base = 0
    call_args_alloc = false
    if nargs > 0 then
      call_args_base = core.alloc_expr_temps(state, nargs * 8)
      if typeof(call_args_base) == "int" and call_args_base > 0 then
        call_args_alloc = true
      else
        call_args_base = 0x300
      end if

      state = _emit_call_args_eval_recursive(state, call_args, 0, nargs, call_args_base)

      // Materialize canonical outgoing arg slots after all arg expressions ran.
      for cpi = 0 to nargs - 1
        state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", call_args_base + cpi * 8)
        if cpi < 4 then
          state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20 + cpi * 8, "rax")
        end if
      end for

      if call_args_alloc then
        state = core.release_expr_temps(state, nargs * 8)
      end if
    end if

    if nargs >= 1 then state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x20) end if
    if nargs >= 2 then state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", 0x28) end if
    if nargs >= 3 then state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", 0x30) end if
    if nargs >= 4 then state.asm = a.mov_r64_membase_disp(state.asm, "r9", "rsp", 0x38) end if

    if raw_name == "" and typeof(cal) == "struct" and cal.node_kind == "Member" then
      raw_name = _expr_to_qualname(state, cal)
    end if

    if callee == "bytes" or callee == "byteBuffer" then
      if nargs == 0 then
        state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
        state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
        state.asm = a.call(state.asm, "fn_bytes_alloc")
        return state
      end if

      if nargs == 2 then
        lid_b2 = _next_lid(state)
        l_fail_b2 = "bytes_fail_" + lid_b2
        l_done_b2 = "bytes_done_" + lid_b2

        // size: tagged int >= 0 and <= 0x7fffffff
        state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x20)
        state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
        state.asm = a.and_r64_imm(state.asm, "r10", 7)
        state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
        state.asm = a.jcc(state.asm, "ne", l_fail_b2)
        state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
        state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
        state.asm = a.jcc(state.asm, "l", l_fail_b2)
        state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
        state.asm = a.jcc(state.asm, "g", l_fail_b2)
        state.asm = a.mov_r32_r32(state.asm, "ecx", "eax")

        // fill: tagged int 0..255
        state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x28)
        state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
        state.asm = a.and_r64_imm(state.asm, "r10", 7)
        state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
        state.asm = a.jcc(state.asm, "ne", l_fail_b2)
        state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
        state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
        state.asm = a.jcc(state.asm, "l", l_fail_b2)
        state.asm = a.cmp_r64_imm(state.asm, "rax", 255)
        state.asm = a.jcc(state.asm, "g", l_fail_b2)
        state.asm = a.mov_r32_r32(state.asm, "edx", "eax")

        state.asm = a.call(state.asm, "fn_bytes_alloc")
        state.asm = a.jmp(state.asm, l_done_b2)
        state.asm = a.mark(state.asm, l_fail_b2)
        state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
        state.asm = a.mark(state.asm, l_done_b2)
        return state
      end if

      if nargs == 1 then
        lid_b1 = _next_lid(state)
        l_fail_b1 = "bytes1_fail_" + lid_b1
        l_done_b1 = "bytes1_done_" + lid_b1
        l_int_b1 = "bytes1_int_" + lid_b1
        l_ptr_b1 = "bytes1_ptr_" + lid_b1
        l_str_b1 = "bytes1_str_" + lid_b1
        l_bcopy_b1 = "bytes1_bcopy_" + lid_b1
        l_arr_b1 = "bytes1_arr_" + lid_b1

        state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x20)
        state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
        state.asm = a.and_r64_imm(state.asm, "r10", 7)
        state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
        state.asm = a.jcc(state.asm, "e", l_int_b1)
        state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
        state.asm = a.jcc(state.asm, "e", l_ptr_b1)
        state.asm = a.jmp(state.asm, l_fail_b1)

        state.asm = a.mark(state.asm, l_int_b1)
        state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
        state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
        state.asm = a.jcc(state.asm, "l", l_fail_b1)
        state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
        state.asm = a.jcc(state.asm, "g", l_fail_b1)
        state.asm = a.mov_r32_r32(state.asm, "ecx", "eax")
        state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
        state.asm = a.call(state.asm, "fn_bytes_alloc")
        state.asm = a.jmp(state.asm, l_done_b1)

        state.asm = a.mark(state.asm, l_ptr_b1)
        state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
        state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
        state.asm = a.jcc(state.asm, "e", l_str_b1)
        state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
        state.asm = a.jcc(state.asm, "e", l_bcopy_b1)
        state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
        state.asm = a.jcc(state.asm, "e", l_arr_b1)
        state.asm = a.jmp(state.asm, l_fail_b1)

        state.asm = a.mark(state.asm, l_str_b1)
        state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rax", 4)
        state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
        state.asm = a.call(state.asm, "fn_bytes_alloc")
        state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
        state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x20)
        state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "r11", 4)
        state.asm = a.push_reg(state.asm, "rsi")
        state.asm = a.push_reg(state.asm, "rdi")
        state.asm = a.lea_r64_membase_disp(state.asm, "rsi", "r11", 8)
        state.asm = a.lea_r64_membase_disp(state.asm, "rdi", "r10", 8)
        state.asm = a.rep_movsb(state.asm)
        state.asm = a.pop_reg(state.asm, "rdi")
        state.asm = a.pop_reg(state.asm, "rsi")
        state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
        state.asm = a.jmp(state.asm, l_done_b1)

        state.asm = a.mark(state.asm, l_bcopy_b1)
        state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rax", 4)
        state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
        state.asm = a.call(state.asm, "fn_bytes_alloc")
        state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
        state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x20)
        state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "r11", 4)
        state.asm = a.push_reg(state.asm, "rsi")
        state.asm = a.push_reg(state.asm, "rdi")
        state.asm = a.lea_r64_membase_disp(state.asm, "rsi", "r11", 8)
        state.asm = a.lea_r64_membase_disp(state.asm, "rdi", "r10", 8)
        state.asm = a.rep_movsb(state.asm)
        state.asm = a.pop_reg(state.asm, "rdi")
        state.asm = a.pop_reg(state.asm, "rsi")
        state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
        state.asm = a.jmp(state.asm, l_done_b1)

        state.asm = a.mark(state.asm, l_arr_b1)
        state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rax", 4)
        state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
        state.asm = a.call(state.asm, "fn_bytes_alloc")
        state.asm = a.mov_r64_r64(state.asm, "r10", "rax")

        state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x20)
        state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "r11", 4)
        state.asm = a.xor_r32_r32(state.asm, "r9d", "r9d")

        l_loop_arr_b1 = "bytes1_arr_loop_" + lid_b1
        l_done_arr_b1 = "bytes1_arr_done_" + lid_b1
        l_fail_arr_b1 = "bytes1_arr_fail_" + lid_b1

        state.asm = a.mark(state.asm, l_loop_arr_b1)
        state.asm = a.cmp_r32_r32(state.asm, "r9d", "r8d")
        state.asm = a.jcc(state.asm, "ge", l_done_arr_b1)

        state.asm = a.mov_r64_mem_bis(state.asm, "rax", "r11", "r9", 8, 8)
        state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
        state.asm = a.and_r64_imm(state.asm, "rdx", 7)
        state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_INT)
        state.asm = a.jcc(state.asm, "ne", l_fail_arr_b1)

        state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
        state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
        state.asm = a.jcc(state.asm, "l", l_fail_arr_b1)
        state.asm = a.cmp_r64_imm(state.asm, "rax", 255)
        state.asm = a.jcc(state.asm, "g", l_fail_arr_b1)

        state.asm = a.lea_r64_mem_bis(state.asm, "rdx", "r10", "r9", 1, 8)
        state.asm = a.mov_membase_disp_r8(state.asm, "rdx", 0, "al")

        state.asm = a.inc_r32(state.asm, "r9d")
        state.asm = a.jmp(state.asm, l_loop_arr_b1)

        state.asm = a.mark(state.asm, l_fail_arr_b1)
        state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
        state.asm = a.jmp(state.asm, l_done_b1)

        state.asm = a.mark(state.asm, l_done_arr_b1)
        state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
        state.asm = a.jmp(state.asm, l_done_b1)

        state.asm = a.mark(state.asm, l_fail_b1)
        state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
        state.asm = a.mark(state.asm, l_done_b1)
        return state
      end if

      state.diagnostics = state.diagnostics +["bytes()/byteBuffer() expects 0, 1 or 2 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return state
    end if

    if callee == "decode" then
      if nargs != 1 and nargs != 2 then
        state.diagnostics = state.diagnostics + ["decode() expects 1 or 2 arguments"]
        state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
        return state
      end if

      lid_dec = _next_lid(state)
      l_fail_dec = "decode_fail_" + lid_dec
      l_done_dec = "decode_done_" + lid_dec

      // Optional encoding arg must be a string.
      if nargs == 2 then
        state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x28)
        state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
        state.asm = a.and_r64_imm(state.asm, "r10", 7)
        state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
        state.asm = a.jcc(state.asm, "ne", l_fail_dec)
        state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
        state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
        state.asm = a.jcc(state.asm, "ne", l_fail_dec)
      end if

      state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x20)
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.call(state.asm, "fn_decode")
      state.asm = a.jmp(state.asm, l_done_dec)

      state.asm = a.mark(state.asm, l_fail_dec)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      state.asm = a.mark(state.asm, l_done_dec)
      return state
    end if

    if callee == "error" then
      if nargs != 2 and nargs != 5 then
        state.diagnostics = state.diagnostics +["error() expects 2 or 5 arguments"]
        state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
        return state
      end if

      state.asm = a.mov_rcx_imm32(state.asm, 56)
      state.asm = a.call(state.asm, "fn_alloc")
      state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRUCT, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, 5, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 8, c.ERROR_STRUCT_ID, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 12, 0, false)

      if nargs == 2 then
        state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x20)
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "r10")
        state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x28)
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 24, "r10")
        state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_script")
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 32, "rax")
        state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_func")
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 40, "rax")
        state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_line")
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 48, "rax")
      else
        for ei = 0 to 4
          if ei < 4 then
            state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x20 + ei * 8)
          else
            state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", call_args_base + ei * 8)
          end if
          state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16 + ei * 8, "r10")
        end for
      end if
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      return state
    end if

    // Strict-void parity with Python: len(void) must raise an error.
    if (callee == "len" or raw_name == "len") and nargs == 1 then
      lid_len = _next_lid(state)
      l_len_ok = "len_ok_" + lid_len
      l_len_done = "len_done_" + lid_len
      state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x20)
      state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
      state.asm = a.and_r64_imm(state.asm, "r10", 7)
      state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_VOID)
      state.asm = a.jcc(state.asm, "ne", l_len_ok)
      state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot apply 'len' to void")
      state = _emit_auto_errprop(state)
      state.asm = a.jmp(state.asm, l_len_done)

      state.asm = a.mark(state.asm, l_len_ok)
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.call(state.asm, "fn_builtin_len")

      state.asm = a.mark(state.asm, l_len_done)
      return state
    end if

    bname = _builtin_label(callee)
    if bname == "" and raw_name != "" then bname = _builtin_label(raw_name) end if
    if bname != "" then
      state.asm = a.mov_r32_imm32(state.asm, "r10d", nargs)
      state.asm = a.call(state.asm, bname)
      return state
    end if

    scallee = callee
    sid = _named_int_get(state.struct_ids, scallee, 0)
    if sid == 0 and raw_name != "" and raw_name != scallee then
      sid2 = _named_int_get(state.struct_ids, raw_name, 0)
      if sid2 != 0 then
        sid = sid2
        scallee = raw_name
      end if
    end if
    if sid != 0 then
      expected = 0
      flds = _named_array_get(state.struct_fields, scallee)
      if typeof(flds) == "array" then expected = len(flds) end if

      if sid == c.ERROR_STRUCT_ID then
        if nargs != 2 and nargs != 5 then
          state.diagnostics = state.diagnostics +["Struct " + scallee + " expects 2 args, got " + nargs]
          state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
          return state
        end if
      else
        if expected != nargs then
          state.diagnostics = state.diagnostics +["Struct " + scallee + " expects " + expected + " args, got " + nargs]
          state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
          return state
        end if
      end if

      if sid == c.ERROR_STRUCT_ID and nargs == 2 then
        state.asm = a.mov_rcx_imm32(state.asm, 56)
        state.asm = a.call(state.asm, "fn_alloc")
        state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
        state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRUCT, false)
        state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, 5, false)
        state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 8, c.ERROR_STRUCT_ID, false)
        state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 12, 0, false)
        state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x20)
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "r10")
        state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x28)
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 24, "r10")
        state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_script")
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 32, "rax")
        state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_func")
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 40, "rax")
        state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_line")
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 48, "rax")
        state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
        state = _emit_auto_errprop(state)
        return state
      end if

      state.asm = a.mov_rcx_imm32(state.asm, 16 + nargs * 8)
      state.asm = a.call(state.asm, "fn_alloc")
      state.asm = a.mov_membase_disp_imm32(state.asm, "rax", 0, c.OBJ_STRUCT, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "rax", 4, nargs, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "rax", 8, sid, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "rax", 12, 0, false)
      if nargs > 0 then
        for fi = 0 to nargs - 1
          if fi < 4 then
            state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x20 + fi * 8)
          else
            state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", call_args_base + fi * 8)
          end if
          state.asm = a.mov_membase_disp_r64(state.asm, "rax", 16 + fi * 8, "r10")
        end for
      end if
      state = _emit_auto_errprop(state)
      return state
    end if

    fn = _user_function_get(state, callee)
    if typeof(fn) != "struct" and raw_name != "" and raw_name != callee then
      fn = _user_function_get(state, raw_name)
      if typeof(fn) == "struct" then callee = raw_name end if
    end if
    if typeof(fn) == "struct" then
      fn_stack_save_off = 0
      fn_stack_save_count = 0
      fn_stack_save_alloc = false
      if nargs > 8 then
        fn_stack_save_count = nargs - 8
        fn_stack_save_bytes = fn_stack_save_count * 8
        fn_stack_save_off = core.alloc_expr_temps(state, fn_stack_save_bytes)
        if typeof(fn_stack_save_off) == "int" and fn_stack_save_off > 0 then
          fn_stack_save_alloc = true
          for ssi_fn = 0 to fn_stack_save_count - 1
            state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x40 + ssi_fn * 8)
            state.asm = a.mov_membase_disp_r64(state.asm, "rsp", fn_stack_save_off + ssi_fn * 8, "rax")
          end for
        else
          fn_stack_save_count = 0
        end if
      end if
      if nargs > 4 then
        for si_fn = 4 to nargs - 1
          state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", call_args_base + si_fn * 8)
          state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20 + (si_fn - 4) * 8, "rax")
        end for
      end if
      state.asm = a.mov_r64_imm64(state.asm, "r10", t.enc_void())
      state.asm = a.call(state.asm, "fn_user_" + callee)
      if fn_stack_save_count > 0 then
        state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
        for ssi_fn2 = 0 to fn_stack_save_count - 1
          state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", fn_stack_save_off + ssi_fn2 * 8)
          state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x40 + ssi_fn2 * 8, "r11")
        end for
        if fn_stack_save_alloc then
          state = core.release_expr_temps(state, fn_stack_save_count * 8)
        end if
        state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      end if
      state = _emit_auto_errprop(state)
      return state
    end if

    // Indirect callable dispatch (first-class function values).
    state.call_indirect_count = state.call_indirect_count + 1
    callee_is_member = false
    callee_desc = ""
    recv_desc = "receiver"
    meth_desc = "member"
    if typeof(cal) == "struct" and cal.node_kind == "Member" then
      callee_is_member = true
      callee_desc = _expr_to_qualname(state, cal)
      mnx = _coerce_name(cal.name)
      if mnx == "" then mnx = _coerce_name(cal.field) end if
      if mnx != "" then meth_desc = mnx end if
      if callee_desc != "" and s.contains(callee_desc, ".") then
        ppd = s.split(callee_desc, ".")
        if typeof(ppd) == "array" and len(ppd) > 1 then
          meth_desc = _coerce_name(ppd[len(ppd) - 1])
          head = slice(ppd, 0, len(ppd) - 1)
          if typeof(head) != "array" then head = [] end if
          recv_desc = s.join(head, ".")
        end if
      else
        tb = _expr_to_qualname(state, cal.target)
        if tb != "" then recv_desc = tb end if
      end if
      if recv_desc == "" then recv_desc = "receiver" end if
      if meth_desc == "" then meth_desc = "member" end if
    end if
    if callee_desc == "" then
      if callee != "" then
        callee_desc = callee
      else
        callee_desc = raw_name
      end if
    end if
    if callee_desc == "" then callee_desc = "<value>" end if

    // Preserve evaluated args across callee evaluation.
    if nargs > 0 then
      for pi2 = 0 to nargs - 1
        state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", call_args_base + pi2 * 8)
        state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x300 + pi2 * 8, "rax")
      end for
    end if

    state = cg_emit_expr(state, cal)
    state.asm = a.mov_rsp_disp32_rax(state.asm, 0x2F0)

    if nargs >= 1 then state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x300 + 0 * 8) end if
    if nargs >= 2 then state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", 0x300 + 1 * 8) end if
    if nargs >= 3 then state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", 0x300 + 2 * 8) end if
    if nargs >= 4 then state.asm = a.mov_r64_membase_disp(state.asm, "r9", "rsp", 0x300 + 3 * 8) end if
    ic_stack_save_off = 0
    ic_stack_save_count = 0
    ic_stack_save_alloc = false
    if nargs > 8 then
      ic_stack_save_count = nargs - 8
      ic_stack_save_bytes = ic_stack_save_count * 8
      ic_stack_save_off = core.alloc_expr_temps(state, ic_stack_save_bytes)
      if typeof(ic_stack_save_off) == "int" and ic_stack_save_off > 0 then
        ic_stack_save_alloc = true
        for ssi_ic = 0 to ic_stack_save_count - 1
          state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x40 + ssi_ic * 8)
          state.asm = a.mov_membase_disp_r64(state.asm, "rsp", ic_stack_save_off + ssi_ic * 8, "rax")
        end for
      else
        ic_stack_save_count = 0
      end if
    end if
    if nargs > 4 then
      for si2 = 4 to nargs - 1
        state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x300 + si2 * 8)
        state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20 + (si2 - 4) * 8, "rax")
      end for
    end if

    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x2F0)

    fid_ic = _next_lid(state)
    l_fail_ic = "icall_fail_" + fid_ic
    l_done_ic = "icall_done_" + fid_ic
    l_fun_ic = "icall_fun_" + fid_ic
    l_stt_ic = "icall_stt_" + fid_ic
    l_blt_ic = "icall_blt_" + fid_ic

    state.asm = a.mov_r64_r64(state.asm, "r10", "r11")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_fail_ic)

    state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 0)
    state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_FUNCTION)
    state.asm = a.jcc(state.asm, "e", l_fun_ic)
    state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_STRUCTTYPE)
    state.asm = a.jcc(state.asm, "e", l_stt_ic)
    state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_BUILTIN)
    state.asm = a.jcc(state.asm, "e", l_blt_ic)
    state.asm = a.jmp(state.asm, l_fail_ic)

    state.asm = a.mark(state.asm, l_fun_ic)
    state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 4)
    state.asm = a.cmp_r32_imm(state.asm, "r10d", nargs)
    state.asm = a.jcc(state.asm, "ne", l_fail_ic)
    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r11", 8)
    state.asm = a.mov_r64_membase_disp(state.asm, "r10", "r11", 16)
    state.asm = a.call_rax(state.asm)
    state.asm = a.jmp(state.asm, l_done_ic)

    state.asm = a.mark(state.asm, l_blt_ic)
    state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 4)
    state.asm = a.cmp_r32_imm(state.asm, "r10d", nargs)
    state.asm = a.jcc(state.asm, "g", l_fail_ic)
    state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 8)
    state.asm = a.cmp_r32_imm(state.asm, "r10d", nargs)
    state.asm = a.jcc(state.asm, "l", l_fail_ic)
    state.asm = a.mov_r32_imm32(state.asm, "r10d", nargs)
    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r11", 16)
    state.asm = a.call_rax(state.asm)
    state.asm = a.jmp(state.asm, l_done_ic)

    state.asm = a.mark(state.asm, l_stt_ic)
    state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 4)
    state.asm = a.cmp_r32_imm(state.asm, "r10d", nargs)
    state.asm = a.jcc(state.asm, "ne", l_fail_ic)

    if nargs == 2 then
      lid_errctor = _next_lid(state)
      l_stt_norm = "icall_stt_normal_" + lid_errctor
      state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 8)
      state.asm = a.cmp_r32_imm(state.asm, "r10d", c.ERROR_STRUCT_ID)
      state.asm = a.jcc(state.asm, "ne", l_stt_norm)

      state.asm = a.mov_rcx_imm32(state.asm, 56)
      state.asm = a.call(state.asm, "fn_alloc")
      state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRUCT, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, 5, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 8, c.ERROR_STRUCT_ID, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 12, 0, false)
      state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x300)
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "r10")
      state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x308)
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 24, "r10")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_script")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 32, "rax")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_func")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 40, "rax")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_line")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 48, "rax")
      state.asm = a.mov_rax_r11(state.asm)
      state.asm = a.jmp(state.asm, l_done_ic)

      state.asm = a.mark(state.asm, l_stt_norm)
      state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x2F0)
    end if

    state.asm = a.mov_rcx_imm32(state.asm, 16 + nargs * 8)
    state.asm = a.call(state.asm, "fn_alloc")
    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x2F0)
    state.asm = a.mov_membase_disp_imm32(state.asm, "rax", 0, c.OBJ_STRUCT, false)
    state.asm = a.mov_membase_disp_imm32(state.asm, "rax", 4, nargs, false)
    state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 8)
    state.asm = a.mov_membase_disp_r32(state.asm, "rax", 8, "r10d")
    state.asm = a.mov_membase_disp_imm32(state.asm, "rax", 12, 0, false)
    if nargs > 0 then
      for fi2 = 0 to nargs - 1
        state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x300 + fi2 * 8)
        state.asm = a.mov_membase_disp_r64(state.asm, "rax", 16 + fi2 * 8, "r10")
      end for
    end if
    state.asm = a.jmp(state.asm, l_done_ic)

    state.asm = a.mark(state.asm, l_fail_ic)
    lid_void = _next_lid(state)
    l_not_void = "icall_not_void_" + lid_void
    state.asm = a.mov_r64_r64(state.asm, "r10", "r11")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_VOID)
    state.asm = a.jcc(state.asm, "ne", l_not_void)

    if callee_is_member then
      state = _emit_make_error_const(state, c.ERR_CALL_NOT_CALLABLE, "'" + recv_desc + "' has no function '" + meth_desc + "'")
    else
      state = _emit_make_error_const(state, c.ERR_CALL_NOT_CALLABLE, "Cannot call void")
    end if
    state.asm = a.jmp(state.asm, l_done_ic)

    state.asm = a.mark(state.asm, l_not_void)
    if callee_is_member then
      lbl_desc = "objstr_" + len(state.rdata.labels)
      state.rdata = d.rdata_add_obj_string(state.rdata, lbl_desc, callee_desc)
      lbl_p0 = "objstr_" + len(state.rdata.labels)
      state.rdata = d.rdata_add_obj_string(state.rdata, lbl_p0, "Cannot call '")
      lbl_p1 = "objstr_" + len(state.rdata.labels)
      state.rdata = d.rdata_add_obj_string(state.rdata, lbl_p1, "' with ")
      lbl_p2 = "objstr_" + len(state.rdata.labels)
      state.rdata = d.rdata_add_obj_string(state.rdata, lbl_p2, " args (expected ")
      lbl_p3 = "objstr_" + len(state.rdata.labels)
      state.rdata = d.rdata_add_obj_string(state.rdata, lbl_p3, "..")
      lbl_p4 = "objstr_" + len(state.rdata.labels)
      state.rdata = d.rdata_add_obj_string(state.rdata, lbl_p4, ")")

      lid_mdiag = _next_lid(state)
      l_msimple = "icall_mdiag_simple_" + lid_mdiag
      l_mfun = "icall_mdiag_fun_" + lid_mdiag
      l_mblt = "icall_mdiag_blt_" + lid_mdiag
      l_mstt = "icall_mdiag_stt_" + lid_mdiag
      l_mdone = "icall_mdiag_done_" + lid_mdiag
      tmp_msg = 0x2D0
      tmp_min = 0x2D8
      tmp_max = 0x2E0

      state.asm = a.mov_r64_r64(state.asm, "r10", "r11")
      state.asm = a.and_r64_imm(state.asm, "r10", 7)
      state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
      state.asm = a.jcc(state.asm, "ne", l_msimple)
      state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 0)
      state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_FUNCTION)
      state.asm = a.jcc(state.asm, "e", l_mfun)
      state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_BUILTIN)
      state.asm = a.jcc(state.asm, "e", l_mblt)
      state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_STRUCTTYPE)
      state.asm = a.jcc(state.asm, "e", l_mstt)
      state.asm = a.jmp(state.asm, l_msimple)

      state.asm = a.mark(state.asm, l_mfun)
      state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 4)
      state.asm = a.mov_r64_r64(state.asm, "r10", "r10")
      state.asm = a.shl_r64_imm8(state.asm, "r10", 3)
      state.asm = a.or_r64_imm(state.asm, "r10", c.TAG_INT)
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_min, "r10")

      state.asm = a.lea_rax_rip(state.asm, lbl_p0)
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.lea_rax_rip(state.asm, lbl_desc)
      state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.lea_rax_rip(state.asm, lbl_p1)
      state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.mov_r64_imm64(state.asm, "rdx", t.enc_int(nargs))
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.lea_rax_rip(state.asm, lbl_p2)
      state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", tmp_min)
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.lea_rax_rip(state.asm, lbl_p4)
      state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_msg, "rax")

      state.asm = a.mov_rcx_imm32(state.asm, 56)
      state.asm = a.call(state.asm, "fn_alloc")
      state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRUCT, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, 5, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 8, c.ERROR_STRUCT_ID, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 12, 0, false)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_int(c.ERR_CALL_NOT_CALLABLE))
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "rax")
      state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", tmp_msg)
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 24, "r10")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_script")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 32, "rax")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_func")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 40, "rax")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_line")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 48, "rax")
      state.asm = a.mov_rax_r11(state.asm)
      state.asm = a.jmp(state.asm, l_mdone)

      state.asm = a.mark(state.asm, l_mblt)
      state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 4)
      state.asm = a.mov_r64_r64(state.asm, "r10", "r10")
      state.asm = a.shl_r64_imm8(state.asm, "r10", 3)
      state.asm = a.or_r64_imm(state.asm, "r10", c.TAG_INT)
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_min, "r10")
      state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 8)
      state.asm = a.mov_r64_r64(state.asm, "r10", "r10")
      state.asm = a.shl_r64_imm8(state.asm, "r10", 3)
      state.asm = a.or_r64_imm(state.asm, "r10", c.TAG_INT)
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_max, "r10")

      state.asm = a.lea_rax_rip(state.asm, lbl_p0)
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.lea_rax_rip(state.asm, lbl_desc)
      state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.lea_rax_rip(state.asm, lbl_p1)
      state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.mov_r64_imm64(state.asm, "rdx", t.enc_int(nargs))
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.lea_rax_rip(state.asm, lbl_p2)
      state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", tmp_min)
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.lea_rax_rip(state.asm, lbl_p3)
      state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", tmp_max)
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.lea_rax_rip(state.asm, lbl_p4)
      state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_msg, "rax")

      state.asm = a.mov_rcx_imm32(state.asm, 56)
      state.asm = a.call(state.asm, "fn_alloc")
      state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRUCT, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, 5, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 8, c.ERROR_STRUCT_ID, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 12, 0, false)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_int(c.ERR_CALL_NOT_CALLABLE))
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "rax")
      state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", tmp_msg)
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 24, "r10")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_script")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 32, "rax")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_func")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 40, "rax")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_line")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 48, "rax")
      state.asm = a.mov_rax_r11(state.asm)
      state.asm = a.jmp(state.asm, l_mdone)

      state.asm = a.mark(state.asm, l_mstt)
      state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 4)
      state.asm = a.mov_r64_r64(state.asm, "r10", "r10")
      state.asm = a.shl_r64_imm8(state.asm, "r10", 3)
      state.asm = a.or_r64_imm(state.asm, "r10", c.TAG_INT)
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_min, "r10")

      state.asm = a.lea_rax_rip(state.asm, lbl_p0)
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.lea_rax_rip(state.asm, lbl_desc)
      state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.lea_rax_rip(state.asm, lbl_p1)
      state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.mov_r64_imm64(state.asm, "rdx", t.enc_int(nargs))
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.lea_rax_rip(state.asm, lbl_p2)
      state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", tmp_min)
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.lea_rax_rip(state.asm, lbl_p4)
      state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_msg, "rax")

      state.asm = a.mov_rcx_imm32(state.asm, 56)
      state.asm = a.call(state.asm, "fn_alloc")
      state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRUCT, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, 5, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 8, c.ERROR_STRUCT_ID, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 12, 0, false)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_int(c.ERR_CALL_NOT_CALLABLE))
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "rax")
      state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", tmp_msg)
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 24, "r10")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_script")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 32, "rax")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_func")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 40, "rax")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_line")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 48, "rax")
      state.asm = a.mov_rax_r11(state.asm)
      state.asm = a.jmp(state.asm, l_mdone)

      state.asm = a.mark(state.asm, l_msimple)
      msg_simple = "Cannot call '" + callee_desc + "' with " + nargs + " args"
      state = _emit_make_error_const(state, c.ERR_CALL_NOT_CALLABLE, msg_simple)
      state.asm = a.mark(state.asm, l_mdone)
    else
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    end if

    state.asm = a.mark(state.asm, l_done_ic)
    if ic_stack_save_count > 0 then
      state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
      for ssi_ic2 = 0 to ic_stack_save_count - 1
        state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", ic_stack_save_off + ssi_ic2 * 8)
        state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x40 + ssi_ic2 * 8, "r11")
      end for
      if ic_stack_save_alloc then
        state = core.release_expr_temps(state, ic_stack_save_count * 8)
      end if
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    end if
    state = _emit_auto_errprop(state)
    if nargs > 4 then
      for si3 = 4 to nargs - 1
        state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20 + (si3 - 4) * 8, t.enc_void(), true)
      end for
    end if
    return state
  end if

  if k == "ArrayLit" then
    n = 0
    if typeof(expr.items) == "array" then n = len(expr.items) end if
    state.asm = a.mov_rcx_imm32(state.asm, 8 + n * 8)
    state.asm = a.call(state.asm, "fn_alloc")
    base_off = core.alloc_expr_temps(state, 8)
    if typeof(base_off) != "int" or base_off <= 0 then base_off = 0x2F8 end if
    state.asm = a.mov_rsp_disp32_rax(state.asm, base_off)
    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", base_off)
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_ARRAY, false)
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, n, false)
    if n > 0 then
      i = 0
      while i < n
        if i < 0 or i >= len(expr.items) then break end if
        state = cg_emit_expr(state, expr.items[i])
        state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", base_off)
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8 + i * 8, "rax")
        i = i + 1
      end while
    end if
    state.asm = a.mov_rax_rsp_disp32(state.asm, base_off)
    state = core.free_expr_temps(state, 8)
    return state
  end if

  state.diagnostics = state.diagnostics +["Unsupported expression type: " + k]
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  return state
end function

// ------------------------------------------------------------
// Compatibility wrappers (Python CodegenExpr parity)
// ------------------------------------------------------------

function _abi_ty_to_str(abi_ty)
  if typeof(abi_ty) == "string" then return s.toLowerAscii(abi_ty) end if
  if typeof(abi_ty) == "struct" then
    if typeof(abi_ty.ty) == "string" then return s.toLowerAscii(abi_ty.ty) end if
    if typeof(abi_ty.type) == "string" then return s.toLowerAscii(abi_ty.type) end if
    if typeof(abi_ty.name) == "string" then return s.toLowerAscii(abi_ty.name) end if
  end if
  return ""
end function

function _qname_parts(state, ex)
  qn = _expr_to_qualname(state, ex)
  if qn == "" then return [] end if
  return s.split(qn, ".")
end function

function _qname_parts_any(state, ex)
  return _qname_parts(state, ex)
end function

function _qname_of(state, ex)
  return _expr_to_qualname(state, ex)
end function

function _qname_with_prefixes(state, qname)
  if typeof(qname) != "string" or qname == "" then return [] end if
  vals_b = t.arr_chunk_new(4)
  vals_b = t.arr_chunk_push(vals_b, qname)
  vals = t.arr_chunk_finish(vals_b)
  if s.contains(qname, ".") then return vals end if

  p1 = state.current_qname_prefix
  if typeof(p1) == "string" and p1 != "" then
    if p1[len(p1) - 1] != "." then p1 = p1 + "." end if
    cand = p1 + qname
    if cand != qname then
      vals_b = t.arr_chunk_push(vals_b, cand)
      vals = t.arr_chunk_finish(vals_b)
    end if
  end if

  p2 = state.current_file_prefix
  if typeof(p2) == "string" and p2 != "" then
    if p2[len(p2) - 1] != "." then p2 = p2 + "." end if
    cand2 = p2 + qname
    hit = false
    for i = 0 to len(vals) - 1
      if vals[i] == cand2 then hit = true break end if
    end for
    if hit == false then
      vals_b = t.arr_chunk_push(vals_b, cand2)
      vals = t.arr_chunk_finish(vals_b)
    end if
  end if
  return vals
end function

function _qualify_dotted(state, name)
  return _qualify_identifier(state, name)
end function

function _qname_exists(state, qname)
  if typeof(qname) != "string" or qname == "" then return false end if
  b = scope.cg_resolve_binding(state, qname)
  return typeof(b) == "struct"
end function

function _has_global_prefix(state, name)
  if typeof(name) != "string" then return false end if
  pref = state.current_file_prefix
  if typeof(pref) != "string" or pref == "" then return false end if
  if pref[len(pref) - 1] != "." then pref = pref + "." end if
  return s.startsWith(name, pref)
end function

function _is_instance_method_qname(state, qname)
  if typeof(qname) != "string" then return false end if
  sm = state.struct_methods
  if typeof(sm) != "array" or len(sm) <= 0 then return false end if
  for i = 0 to len(sm) - 1
    it = sm[i]
    md = 0
    if typeof(it) == "struct" then
      md = it.values
    else
      if typeof(it) == "array" and len(it) >= 2 then md = it[1] end if
    end if
    if typeof(md) != "array" or len(md) <= 0 then continue end if
    for j = 0 to len(md) - 1
      ent = md[j]
      fnq = ""
      if typeof(ent) == "struct" then
        fnq = _coerce_name(ent.value)
      else
        if typeof(ent) == "array" and len(ent) >= 2 then fnq = _coerce_name(ent[1]) end if
      end if
      if fnq == qname then return true end if
    end for
  end for
  return false
end function

function _expr_has_this(ex)
  if typeof(ex) != "struct" then return false end if
  if ex.node_kind == "Var" and typeof(ex.name) == "string" and ex.name == "this" then
    return true
  end if
  if ex.node_kind == "IsType" then
    return _expr_has_this(ex.expr)
  end if
  if ex.node_kind == "Member" then
    if _expr_has_this(ex.target) then return true end if
  end if
  if ex.node_kind == "Unary" then
    return _expr_has_this(ex.right)
  end if
  if ex.node_kind == "Bin" then
    return _expr_has_this(ex.left) or _expr_has_this(ex.right)
  end if
  if ex.node_kind == "Call" then
    if _expr_has_this(ex.callee) then return true end if
    if typeof(ex.args) == "array" and len(ex.args) > 0 then
      for i = 0 to len(ex.args) - 1
        if _expr_has_this(ex.args[i]) then return true end if
      end for
    end if
  end if
  if ex.node_kind == "Index" then
    return _expr_has_this(ex.target) or _expr_has_this(ex.index)
  end if
  if ex.node_kind == "ArrayLit" then
    if typeof(ex.items) == "array" and len(ex.items) > 0 then
      for ai = 0 to len(ex.items) - 1
        if _expr_has_this(ex.items[ai]) then return true end if
      end for
    end if
    return false
  end if
  if ex.node_kind == "StructInit" then
    if typeof(ex.values) == "array" and len(ex.values) > 0 then
      for si = 0 to len(ex.values) - 1
        if _expr_has_this(ex.values[si]) then return true end if
      end for
    end if
    return false
  end if
  return false
end function

function _stmt_has_this(st)
  if typeof(st) != "struct" then return false end if
  k = _coerce_name(st.node_kind)

  if k == "Print" or k == "ExprStmt" or k == "ConstDecl" or k == "Return" then
    if _expr_has_this(st.expr) then return true end if
    return false
  end if

  if k == "Assign" then
    if _coerce_name(st.name) == "this" then return true end if
    if _expr_has_this(st.expr) then return true end if
    return false
  end if

  if k == "SetMember" then
    if _expr_has_this(st.obj) then return true end if
    if _expr_has_this(st.expr) then return true end if
    return false
  end if

  if k == "SetIndex" then
    if _expr_has_this(st.target) then return true end if
    if _expr_has_this(st.index) then return true end if
    if _expr_has_this(st.expr) then return true end if
    return false
  end if

  if k == "If" then
    if _expr_has_this(st.cond) then return true end if
    if typeof(st.then_body) == "array" and len(st.then_body) > 0 then
      for i = 0 to len(st.then_body) - 1
        if _stmt_has_this(st.then_body[i]) then return true end if
      end for
    end if
    if typeof(st.elifs) == "array" and len(st.elifs) > 0 then
      for ei = 0 to len(st.elifs) - 1
        el = st.elifs[ei]
        if typeof(el) == "array" and len(el) >= 2 then
          if _expr_has_this(el[0]) then return true end if
          if typeof(el[1]) == "array" and len(el[1]) > 0 then
            for bi = 0 to len(el[1]) - 1
              if _stmt_has_this(el[1][bi]) then return true end if
            end for
          end if
        end if
      end for
    end if
    if typeof(st.else_body) == "array" and len(st.else_body) > 0 then
      for i2 = 0 to len(st.else_body) - 1
        if _stmt_has_this(st.else_body[i2]) then return true end if
      end for
    end if
    return false
  end if

  if k == "While" then
    if _expr_has_this(st.cond) then return true end if
    if typeof(st.body) == "array" and len(st.body) > 0 then
      for wi = 0 to len(st.body) - 1
        if _stmt_has_this(st.body[wi]) then return true end if
      end for
    end if
    return false
  end if

  if k == "DoWhile" then
    if typeof(st.body) == "array" and len(st.body) > 0 then
      for dwi = 0 to len(st.body) - 1
        if _stmt_has_this(st.body[dwi]) then return true end if
      end for
    end if
    if _expr_has_this(st.cond) then return true end if
    return false
  end if

  if k == "For" then
    if _expr_has_this(st.start) then return true end if
    if _expr_has_this(st.end_expr) then return true end if
    if typeof(st.body) == "array" and len(st.body) > 0 then
      for fi = 0 to len(st.body) - 1
        if _stmt_has_this(st.body[fi]) then return true end if
      end for
    end if
    return false
  end if

  if k == "ForEach" then
    if _expr_has_this(st.iterable) then return true end if
    if typeof(st.body) == "array" and len(st.body) > 0 then
      for fei = 0 to len(st.body) - 1
        if _stmt_has_this(st.body[fei]) then return true end if
      end for
    end if
    return false
  end if

  if k == "Switch" then
    if _expr_has_this(st.expr) then return true end if
    if typeof(st.cases) == "array" and len(st.cases) > 0 then
      for ci = 0 to len(st.cases) - 1
        cs = st.cases[ci]
        if typeof(cs) != "struct" then continue end if
        if _coerce_name(cs.kind) == "values" then
          if typeof(cs.values) == "array" and len(cs.values) > 0 then
            for vi = 0 to len(cs.values) - 1
              if _expr_has_this(cs.values[vi]) then return true end if
            end for
          end if
        else
          if _expr_has_this(cs.range_start) then return true end if
          if _expr_has_this(cs.range_end) then return true end if
        end if
        if typeof(cs.body) == "array" and len(cs.body) > 0 then
          for sbi = 0 to len(cs.body) - 1
            if _stmt_has_this(cs.body[sbi]) then return true end if
          end for
        end if
      end for
    end if
    if typeof(st.default_body) == "array" and len(st.default_body) > 0 then
      for dbi = 0 to len(st.default_body) - 1
        if _stmt_has_this(st.default_body[dbi]) then return true end if
      end for
    end if
    return false
  end if

  if k == "FunctionDef" then
    if typeof(st.body) == "array" and len(st.body) > 0 then
      for nfi = 0 to len(st.body) - 1
        if _stmt_has_this(st.body[nfi]) then return true end if
      end for
    end if
    return false
  end if

  return false
end function

function _fn_uses_this(fn_node)
  if typeof(fn_node) != "struct" then return false end if
  uses = false
  if typeof(fn_node.body) == "array" and len(fn_node.body) > 0 then
    for i = 0 to len(fn_node.body) - 1
      if _stmt_has_this(fn_node.body[i]) then
        uses = true
        break
      end if
    end for
  end if
  return uses
end function

function _contains_nested_fn(node)
  if typeof(node) != "struct" then return false end if
  if node.node_kind == "FunctionDef" then return true end if

  if typeof(node.body) == "array" then
    for i = 0 to len(node.body) - 1
      if _contains_nested_fn(node.body[i]) then return true end if
    end for
  end if
  if typeof(node.then_body) == "array" then
    for i = 0 to len(node.then_body) - 1
      if _contains_nested_fn(node.then_body[i]) then return true end if
    end for
  end if
  if typeof(node.else_body) == "array" then
    for i = 0 to len(node.else_body) - 1
      if _contains_nested_fn(node.else_body[i]) then return true end if
    end for
  end if
  if typeof(node.expr) == "struct" then
    if _contains_nested_fn(node.expr) then return true end if
  end if
  if typeof(node.left) == "struct" then
    if _contains_nested_fn(node.left) then return true end if
  end if
  if typeof(node.right) == "struct" then
    if _contains_nested_fn(node.right) then return true end if
  end if
  if typeof(node.target) == "struct" then
    if _contains_nested_fn(node.target) then return true end if
  end if
  if typeof(node.args) == "array" then
    for i = 0 to len(node.args) - 1
      if _contains_nested_fn(node.args[i]) then return true end if
    end for
  end if

  return false
end function

function _extern_dll_base(dll)
  if typeof(dll) != "string" then return "dll" end if
  x = s.toLowerAscii(dll)
  x = s.replaceAll(x, "\\", "/")
  parts = s.split(x, "/")
  if len(parts) > 0 then x = parts[len(parts) - 1] end if
  if s.endsWith(x, ".dll") then
    x = s.substr(x, 0, len(x) - 4)
  end if
  x = s.replaceAll(x, "-", "_")
  x = s.replaceAll(x, " ", "_")
  x = s.replaceAll(x, ".", "_")
  while s.contains(x, "__")
    x = s.replaceAll(x, "__", "_")
  end while
  if x == "" then x = "dll" end if
  return x
end function

function _extern_iat_label(dll, sym)
  return "iat_" + _extern_dll_base(dll) + "_" + sym
end function

function _emit_make_error_const(state, code, message)
  err_code = 0
  if typeof(code) == "int" then err_code = code end if
  msg = "" + message

  lbl = "objstr_" + len(state.rdata.labels)
  state.rdata = d.rdata_add_obj_string(state.rdata, lbl, msg)

  state.asm = a.mov_rcx_imm32(state.asm, 56)
  state.asm = a.call(state.asm, "fn_alloc")
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")

  // header: type / nfields / struct_id / pad
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRUCT, false)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, 5, false)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 8, c.ERROR_STRUCT_ID, false)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 12, 0, false)

  // field0 = code
  state.asm = a.mov_rax_imm64(state.asm, t.enc_int(err_code))
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "rax")

  // field1 = message
  state.asm = a.lea_rax_rip(state.asm, lbl)
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 24, "rax")

  // field2 = script
  state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_script")
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 32, "rax")

  // field3 = func
  state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_func")
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 40, "rax")

  // field4 = line
  state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_line")
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 48, "rax")

  state.asm = a.mov_rax_r11(state.asm)
  return state
end function

function _emit_auto_errprop(state)
  sup = 0
  if typeof(state.errprop_suppression) == "int" then sup = state.errprop_suppression end if
  if sup > 0 then return state end if

  lid = _next_lid(state)
  l_noerr = "errprop_noerr_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_noerr)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_STRUCT)
  state.asm = a.jcc(state.asm, "ne", l_noerr)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "rax", 8)
  state.asm = a.cmp_r32_imm(state.asm, "r10d", c.ERROR_STRUCT_ID)
  state.asm = a.jcc(state.asm, "ne", l_noerr)

  if state.in_function and typeof(state.func_ret_label) == "string" and state.func_ret_label != "" then
    state.asm = a.jmp(state.asm, state.func_ret_label)
  else
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, "fn_unhandled_error_exit")
  end if

  state.asm = a.mark(state.asm, l_noerr)
  return state
end function

function _emit_extern_arg_to_native(state, abi_ty, fail_label, pos, wbuf_label)
  ty = s.toLowerAscii(s.trim(_abi_ty_to_str(abi_ty)))
  if typeof(wbuf_label) != "string" or wbuf_label == "" then wbuf_label = "widebuf" end if

  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)

  if ty == "int" or ty == "i64" or ty == "u64" or ty == "i32" or ty == "u32" then
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", fail_label)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    if ty == "u32" then
      state.asm = a.and_r64_imm(state.asm, "rax", 0xFFFFFFFF)
    end if
    return state
  end if

  if ty == "bool" then
    lid_b = _next_lid(state)
    l_is_bool = "extarg_bool_bool_" + lid_b
    l_done_bool = "extarg_bool_done_" + lid_b
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_BOOL)
    state.asm = a.jcc(state.asm, "e", l_is_bool)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", fail_label)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.jmp(state.asm, l_done_bool)
    state.asm = a.mark(state.asm, l_is_bool)
    state.asm = a.shr_r64_imm8(state.asm, "rax", 3)
    state.asm = a.mark(state.asm, l_done_bool)
    return state
  end if

  if ty == "ptr" or ty == "pointer" then
    lid_p = _next_lid(state)
    l_int = "extarg_ptr_int_" + lid_p
    l_ptr = "extarg_ptr_ptr_" + lid_p
    l_void = "extarg_ptr_void_" + lid_p
    l_ok = "extarg_ptr_ok_" + lid_p
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
    state.asm = a.jcc(state.asm, "e", l_int)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "e", l_ptr)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_VOID)
    state.asm = a.jcc(state.asm, "e", l_void)
    state.asm = a.jmp(state.asm, fail_label)
    state.asm = a.mark(state.asm, l_int)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.jmp(state.asm, l_ok)
    state.asm = a.mark(state.asm, l_ptr)
    state.asm = a.jmp(state.asm, l_ok)
    state.asm = a.mark(state.asm, l_void)
    state.asm = a.xor_eax_eax(state.asm)
    state.asm = a.jmp(state.asm, l_ok)
    state.asm = a.mark(state.asm, l_ok)
    return state
  end if

  if ty == "bytes" or ty == "buffer" or ty == "bytebuffer" then
    lid_bs = _next_lid(state)
    l_ptr_bs = "extarg_bytes_ptr_" + lid_bs
    l_void_bs = "extarg_bytes_void_" + lid_bs
    l_ok_bs = "extarg_bytes_ok_" + lid_bs
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "e", l_ptr_bs)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_VOID)
    state.asm = a.jcc(state.asm, "e", l_void_bs)
    state.asm = a.jmp(state.asm, fail_label)
    state.asm = a.mark(state.asm, l_void_bs)
    state.asm = a.xor_eax_eax(state.asm)
    state.asm = a.jmp(state.asm, l_ok_bs)
    state.asm = a.mark(state.asm, l_ptr_bs)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "ne", fail_label)
    state.asm = a.lea_r64_membase_disp(state.asm, "rax", "rax", 8)
    state.asm = a.jmp(state.asm, l_ok_bs)
    state.asm = a.mark(state.asm, l_ok_bs)
    return state
  end if

  if ty == "cstr" or ty == "cstring" then
    lid_cs = _next_lid(state)
    l_ptr_cs = "extarg_cstr_ptr_" + lid_cs
    l_void_cs = "extarg_cstr_void_" + lid_cs
    l_ok_cs = "extarg_cstr_ok_" + lid_cs
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "e", l_ptr_cs)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_VOID)
    state.asm = a.jcc(state.asm, "e", l_void_cs)
    state.asm = a.jmp(state.asm, fail_label)
    state.asm = a.mark(state.asm, l_void_cs)
    state.asm = a.xor_eax_eax(state.asm)
    state.asm = a.jmp(state.asm, l_ok_cs)
    state.asm = a.mark(state.asm, l_ptr_cs)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
    state.asm = a.jcc(state.asm, "ne", fail_label)
    state.asm = a.lea_r64_membase_disp(state.asm, "rax", "rax", 8)
    state.asm = a.jmp(state.asm, l_ok_cs)
    state.asm = a.mark(state.asm, l_ok_cs)
    return state
  end if

  if ty == "wstr" or ty == "wstring" then
    lid_ws = _next_lid(state)
    l_ptr_ws = "extarg_wstr_ptr_" + lid_ws
    l_void_ws = "extarg_wstr_void_" + lid_ws
    l_ok_ws = "extarg_wstr_ok_" + lid_ws
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "e", l_ptr_ws)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_VOID)
    state.asm = a.jcc(state.asm, "e", l_void_ws)
    state.asm = a.jmp(state.asm, fail_label)

    state.asm = a.mark(state.asm, l_void_ws)
    state.asm = a.xor_eax_eax(state.asm)
    state.asm = a.jmp(state.asm, l_ok_ws)

    state.asm = a.mark(state.asm, l_ptr_ws)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
    state.asm = a.jcc(state.asm, "ne", fail_label)
    state.asm = a.mov_rcx_imm32(state.asm, 65001)
    state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
    state.asm = a.lea_r64_membase_disp(state.asm, "r8", "rax", 8)
    state.asm = a.mov_r32_imm32(state.asm, "r9d", 0xFFFFFFFF)
    state.asm = a.lea_r11_rip(state.asm, wbuf_label)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "r11")
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x28, c.WIDEBUF_SIZE / 2, true)
    state.asm = a.mov_rax_rip_qword(state.asm, "iat_MultiByteToWideChar")
    state.asm = a.call_rax(state.asm)
    state.asm = a.lea_rax_rip(state.asm, wbuf_label)
    state.asm = a.jmp(state.asm, l_ok_ws)

    state.asm = a.mark(state.asm, l_ok_ws)
    return state
  end if

  state.diagnostics = state.diagnostics + ["Unsupported extern ABI type '" + ty + "'"]
  state.asm = a.jmp(state.asm, fail_label)
  return state
end function

function _emit_extern_ret_from_native(state, abi_ty, fail_label, pos)
  ty = s.toLowerAscii(s.trim(_abi_ty_to_str(abi_ty)))
  if ty == "" or ty == "void" or ty == "none" then
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return state
  end if

  if ty == "bool" then
    state.asm = a.test_r64_r64(state.asm, "rax", "rax")
    state.asm = a.setcc_r8(state.asm, "ne", "al")
    state.asm = a.movzx_r32_r8(state.asm, "eax", "al")
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_BOOL)
    return state
  end if

  if ty == "u32" then
    state.asm = a.and_r64_imm(state.asm, "rax", 0xFFFFFFFF)
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
    return state
  end if

  if ty == "i32" then
    state.asm = a.shl_rax_imm8(state.asm, 32)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 32)
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
    return state
  end if

  if ty == "int" or ty == "i64" or ty == "u64" or ty == "ptr" or ty == "pointer" then
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
    return state
  end if

  if ty == "cstr" or ty == "cstring" then
    state = mem.ensure_gc_data(state)
    lid = _next_lid(state)
    l_null = "extret_cstr_null_" + lid
    l_scan = "extret_cstr_scan_" + lid
    l_done = "extret_cstr_done_" + lid
    l_after = "extret_cstr_after_" + lid

    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.shl_r64_imm8(state.asm, "r10", 3)
    state.asm = a.or_r64_imm8(state.asm, "r10", c.TAG_INT)
    state.asm = a.mov_r64_r64(state.asm, "r11", "r10")
    state.asm = a.mov_rip_qword_r11(state.asm, "gc_tmp0")

    state.asm = a.test_r64_r64(state.asm, "rax", "rax")
    state.asm = a.jcc(state.asm, "e", l_null)

    state.asm = a.mov_rax_rip_qword(state.asm, "gc_tmp0")
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.sar_r64_imm8(state.asm, "r10", 3)
    state.asm = a.xor_r32_r32(state.asm, "r9d", "r9d")
    state.asm = a.mark(state.asm, l_scan)
    state.asm = a.mov_r64_r64(state.asm, "r11", "r10")
    state.asm = a.add_r64_r64(state.asm, "r11", "r9")
    state.asm = a.movzx_r32_membase_disp(state.asm, "eax", "r11", 0)
    state.asm = a.cmp_r8_imm8(state.asm, "al", 0)
    state.asm = a.jcc(state.asm, "e", l_done)
    state.asm = a.inc_r32(state.asm, "r9d")
    state.asm = a.jmp(state.asm, l_scan)

    state.asm = a.mark(state.asm, l_done)
    state.asm = a.mov_r64_r64(state.asm, "r11", "r9")
    state.asm = a.shl_r64_imm8(state.asm, "r11", 3)
    state.asm = a.or_r64_imm8(state.asm, "r11", c.TAG_INT)
    state.asm = a.mov_rip_qword_r11(state.asm, "gc_tmp1")

    state.asm = a.mov_r32_r32(state.asm, "ecx", "r9d")
    state.asm = a.add_r32_imm(state.asm, "ecx", 9)
    state.asm = a.call(state.asm, "fn_alloc")

    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.mov_rip_qword_r11(state.asm, "gc_tmp2")
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRING, false)
    state.asm = a.mov_rax_rip_qword(state.asm, "gc_tmp1")
    state.asm = a.mov_r64_r64(state.asm, "r9", "rax")
    state.asm = a.sar_r64_imm8(state.asm, "r9", 3)
    state.asm = a.mov_r32_r32(state.asm, "r9d", "r9d")
    state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "r9d")

    state.asm = a.mov_rax_rip_qword(state.asm, "gc_tmp0")
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.sar_r64_imm8(state.asm, "r10", 3)
    state.asm = a.push_reg(state.asm, "rsi")
    state.asm = a.push_reg(state.asm, "rdi")
    state.asm = a.mov_r64_r64(state.asm, "rsi", "r10")
    state.asm = a.lea_r64_membase_disp(state.asm, "rdi", "r11", 8)
    state.asm = a.mov_r32_r32(state.asm, "ecx", "r9d")
    state.asm = a.rep_movsb(state.asm)
    state.asm = a.pop_reg(state.asm, "rdi")
    state.asm = a.pop_reg(state.asm, "rsi")
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.add_r64_r64(state.asm, "rax", "r9")
    state.asm = a.add_rax_imm8(state.asm, 8)
    state.asm = a.mov_membase_disp_imm8(state.asm, "rax", 0, 0)
    state.asm = a.mov_rax_r11(state.asm)
    state.asm = a.jmp(state.asm, l_after)

    state.asm = a.mark(state.asm, l_null)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())

    state.asm = a.mark(state.asm, l_after)
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp0")
    state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp1")
    state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    return state
  end if

  if ty == "wstr" or ty == "wstring" then
    state = mem.ensure_gc_data(state)
    lidw = _next_lid(state)
    l_null_w = "extret_wstr_null_" + lidw
    l_fail_w = "extret_wstr_fail_" + lidw
    l_after_w = "extret_wstr_after_" + lidw

    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.shl_r64_imm8(state.asm, "r10", 3)
    state.asm = a.or_r64_imm8(state.asm, "r10", c.TAG_INT)
    state.asm = a.mov_r64_r64(state.asm, "r11", "r10")
    state.asm = a.mov_rip_qword_r11(state.asm, "gc_tmp0")

    state.asm = a.test_r64_r64(state.asm, "rax", "rax")
    state.asm = a.jcc(state.asm, "e", l_null_w)

    state.asm = a.mov_rcx_imm32(state.asm, 65001)
    state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
    state.asm = a.mov_rax_rip_qword(state.asm, "gc_tmp0")
    state.asm = a.mov_r64_r64(state.asm, "r8", "rax")
    state.asm = a.sar_r64_imm8(state.asm, "r8", 3)
    state.asm = a.mov_r32_imm32(state.asm, "r9d", 0xFFFFFFFF)
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x28, 0, true)
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x30, 0, true)
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x38, 0, true)
    state.asm = a.mov_rax_rip_qword(state.asm, "iat_WideCharToMultiByte")
    state.asm = a.call_rax(state.asm)

    state.asm = a.cmp_rax_imm8(state.asm, 0)
    state.asm = a.jcc(state.asm, "e", l_fail_w)

    state.asm = a.dec_r32(state.asm, "eax")
    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.shl_r64_imm8(state.asm, "r11", 3)
    state.asm = a.or_r64_imm8(state.asm, "r11", c.TAG_INT)
    state.asm = a.mov_rip_qword_r11(state.asm, "gc_tmp1")

    state.asm = a.mov_r32_r32(state.asm, "ecx", "eax")
    state.asm = a.add_r32_imm(state.asm, "ecx", 9)
    state.asm = a.call(state.asm, "fn_alloc")

    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.mov_rip_qword_r11(state.asm, "gc_tmp2")
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRING, false)
    state.asm = a.mov_rax_rip_qword(state.asm, "gc_tmp1")
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.sar_r64_imm8(state.asm, "r10", 3)
    state.asm = a.mov_r32_r32(state.asm, "r10d", "r10d")
    state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "r10d")

    state.asm = a.mov_rcx_imm32(state.asm, 65001)
    state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
    state.asm = a.mov_rax_rip_qword(state.asm, "gc_tmp0")
    state.asm = a.mov_r64_r64(state.asm, "r8", "rax")
    state.asm = a.sar_r64_imm8(state.asm, "r8", 3)
    state.asm = a.mov_r32_imm32(state.asm, "r9d", 0xFFFFFFFF)
    state.asm = a.mov_rax_rip_qword(state.asm, "gc_tmp2")
    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.lea_r64_membase_disp(state.asm, "rax", "r11", 8)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")
    state.asm = a.mov_rax_rip_qword(state.asm, "gc_tmp1")
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.inc_r32(state.asm, "eax")
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x28, "rax")
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x30, 0, true)
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x38, 0, true)
    state.asm = a.mov_rax_rip_qword(state.asm, "iat_WideCharToMultiByte")
    state.asm = a.call_rax(state.asm)

    state.asm = a.cmp_rax_imm8(state.asm, 0)
    state.asm = a.jcc(state.asm, "e", l_fail_w)
    state.asm = a.mov_rax_rip_qword(state.asm, "gc_tmp2")
    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.mov_rax_rip_qword(state.asm, "gc_tmp1")
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.sar_r64_imm8(state.asm, "r10", 3)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.add_r64_r64(state.asm, "rax", "r10")
    state.asm = a.add_rax_imm8(state.asm, 8)
    state.asm = a.mov_membase_disp_imm8(state.asm, "rax", 0, 0)
    state.asm = a.mov_rax_r11(state.asm)
    state.asm = a.jmp(state.asm, l_after_w)

    state.asm = a.mark(state.asm, l_fail_w)
    state = _emit_make_error_const(state, c.ERR_EXTERN_RET_WSTR_CONVERSION, "Extern return conversion failed: wstr (WideCharToMultiByte returned 0)")
    state.asm = a.jmp(state.asm, l_after_w)

    state.asm = a.mark(state.asm, l_null_w)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())

    state.asm = a.mark(state.asm, l_after_w)
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp0")
    state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp1")
    state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    return state
  end if

  state.diagnostics = state.diagnostics + ["Unsupported extern return type '" + ty + "'"]
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  return state
end function

function _emit_extern_call(state, call_node, args, out_kind, out_name, pos)
  qn = ""
  if typeof(out_name) == "string" then qn = out_name end if
  if qn == "" and typeof(call_node) == "struct" then
    cal = call_node.callee
    if typeof(cal) != "struct" then cal = call_node.func end if
    qn = _expr_to_qualname(state, cal)
  end if
  qn = _apply_import_alias(state, qn)
  sig = _extern_sig_get(state, qn)
  if typeof(sig) != "struct" then
    state.diagnostics = state.diagnostics + ["Unknown extern function '" + qn + "'"]
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return state
  end if

  ps = []
  if typeof(sig.params) == "array" then ps = sig.params end if
  if typeof(args) != "array" then args = [] end if
  nargs = len(args)
  if nargs != len(ps) then
    state.diagnostics = state.diagnostics + ["Extern call arity mismatch: " + qn + " expects " + len(ps) + " args, got " + nargs]
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return state
  end if

  dll = _coerce_name(sig.dll)
  sym = _coerce_name(sig.symbol_name)
  if sym == "" then
    qps = s.split(qn, ".")
    if typeof(qps) == "array" and len(qps) > 0 then
      sym = qps[len(qps) - 1]
    end if
  end if
  if sym == "" then sym = _coerce_name(sig.name) end if

  lid = _next_lid(state)
  l_fail = "extcall_fail_" + lid
  l_done = "extcall_done_" + lid
  wpool = ["widebuf", "widebuf1", "widebuf2", "widebuf3"]
  arg_base = 0
  arg_alloc = false
  if nargs > 0 then
    arg_base = core.alloc_expr_temps(state, nargs * 8)
    if typeof(arg_base) == "int" and arg_base > 0 then
      arg_alloc = true
    else
      arg_base = 0x320
    end if
  end if

  i = 0
  while i < nargs
    if i < 0 or i >= len(args) then break end if
    state = cg_emit_expr(state, args[i])
    aty = ""
    if i < 0 or i >= len(ps) then
      state.diagnostics = state.diagnostics + ["Extern signature mismatch while emitting call: " + qn]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return state
    end if
    pp = ps[i]
    if typeof(pp) == "struct" then
      aty = _coerce_name(pp.ty)
      if aty == "" then aty = _coerce_name(pp.type) end if
      if aty == "" then aty = _coerce_name(pp.abi_ty) end if
    else
      aty = _coerce_name(pp)
    end if
    wbuf = ""
    aty_l = s.toLowerAscii(s.trim(aty))
    if aty_l == "wstr" or aty_l == "wstring" then
      wbuf = wpool[i % len(wpool)]
    end if
    state = _emit_extern_arg_to_native(state, pp, l_fail, pos, wbuf)
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", arg_base + i * 8, "rax")
    i = i + 1
  end while

  if nargs >= 1 then
    state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", arg_base + 0 * 8)
    state.asm = a.sar_r64_imm8(state.asm, "rcx", 3)
  end if
  if nargs >= 2 then
    state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", arg_base + 1 * 8)
    state.asm = a.sar_r64_imm8(state.asm, "rdx", 3)
  end if
  if nargs >= 3 then
    state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", arg_base + 2 * 8)
    state.asm = a.sar_r64_imm8(state.asm, "r8", 3)
  end if
  if nargs >= 4 then
    state.asm = a.mov_r64_membase_disp(state.asm, "r9", "rsp", arg_base + 3 * 8)
    state.asm = a.sar_r64_imm8(state.asm, "r9", 3)
  end if
  ext_stack_save_off = 0
  ext_stack_save_count = 0
  ext_stack_save_alloc = false
  if nargs > 8 then
    ext_stack_save_count = nargs - 8
    ext_stack_save_bytes = ext_stack_save_count * 8
    ext_stack_save_off = core.alloc_expr_temps(state, ext_stack_save_bytes)
    if typeof(ext_stack_save_off) == "int" and ext_stack_save_off > 0 then
      ext_stack_save_alloc = true
      si_save = 0
      while si_save < ext_stack_save_count
        state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x40 + si_save * 8)
        state.asm = a.mov_membase_disp_r64(state.asm, "rsp", ext_stack_save_off + si_save * 8, "rax")
        si_save = si_save + 1
      end while
    else
      ext_stack_save_count = 0
    end if
  end if
  if nargs > 4 then
    si = 4
    while si < nargs
      state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", arg_base + si * 8)
      state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20 + (si - 4) * 8, "rax")
      si = si + 1
    end while
  end if

  state.asm = a.mov_rax_rip_qword(state.asm, _extern_iat_label(dll, sym))
  state.asm = a.call_rax(state.asm)
  state = _emit_extern_ret_from_native(state, sig.ret_ty, l_fail, pos)
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_fail)
  state = _emit_make_error_const(state, c.ERR_EXTERN_CONVERSION, "Extern call failed: " + qn + " (argument type mismatch or conversion failure)")

  state.asm = a.mark(state.asm, l_done)
  if ext_stack_save_count > 0 then
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    si_restore = 0
    while si_restore < ext_stack_save_count
      state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", ext_stack_save_off + si_restore * 8)
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x40 + si_restore * 8, "r11")
      si_restore = si_restore + 1
    end while
    if ext_stack_save_alloc then
      state = core.release_expr_temps(state, ext_stack_save_count * 8)
    end if
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  end if
  if arg_alloc then
    state = core.release_expr_temps(state, nargs * 8)
  end if
  return state
end function

function _emit_inline_call(state, callee, args)
  return state
end function

function _opt_try_const_value(state, ex)
  return cg_expr_try_const_value(state, ex)
end function

function _opt_emit_const_value(state, value)
  tv = typeof(value)
  if tv == "bool" then
    state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(value))
    return state
  end if
  if tv == "int" then
    state.asm = a.mov_rax_imm64(state.asm, t.enc_int(value))
    return state
  end if
  if tv == "float" then
    lbl = "cflt_" + len(state.rdata.labels)
    state.rdata = d.rdata_add_obj_float(state.rdata, lbl, value)
    state.asm = a.lea_rax_rip(state.asm, lbl)
    return state
  end if
  if tv == "string" then
    lbl2 = "cstr_" + len(state.rdata.labels)
    state.rdata = d.rdata_add_obj_string(state.rdata, lbl2, value)
    state.asm = a.lea_rax_rip(state.asm, lbl2)
    return state
  end if
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  return state
end function

function _emit_call_args_eval_recursive(state, call_args, idx, nargs, base_off)
  if typeof(nargs) != "int" then return state end if
  if idx < 0 or idx >= nargs then return state end if
  if typeof(call_args) != "array" or idx >= len(call_args) then return state end if
  if typeof(base_off) != "int" then return state end if

  argi = call_args[idx]

  if typeof(argi) == "struct" then
    state = cg_emit_expr(state, argi)
  else
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  end if
  state.asm = a.mov_rsp_disp32_rax(state.asm, base_off + idx * 8)
  return _emit_call_args_eval_recursive(state, call_args, idx + 1, nargs, base_off)
end function

function emit_expr(state, ex)
  return cg_emit_expr(state, ex)
end function

function emit_extern_stubs(state)
  xs = state.extern_sigs
  if typeof(xs) != "array" or len(xs) <= 0 then return state end if

  wpool = ["widebuf", "widebuf1", "widebuf2", "widebuf3"]

  for xi = 0 to len(xs) - 1
    sig = xs[xi]
    if typeof(sig) != "struct" then continue end if

    qn = _coerce_name(sig.qname)
    if qn == "" then qn = _coerce_name(sig.name) end if
    if qn == "" then continue end if

    dll = _coerce_name(sig.dll)
    sym = _coerce_name(sig.symbol_name)
    if sym == "" then
      psq = s.split(qn, ".")
      if typeof(psq) == "array" and len(psq) > 0 then
        sym = psq[len(psq) - 1]
      end if
    end if
    if sym == "" then sym = _coerce_name(sig.name) end if

    params = []
    if typeof(sig.params) == "array" then params = sig.params end if
    ret_ty = _coerce_name(sig.ret_ty)
    pos = 0

    nargs = len(params)
    out_args = nargs - 4
    if out_args < 0 then out_args = 0 end if

    stub_lbl = ""
    if typeof(state.extern_stub_labels) == "array" then
      stub_lbl = _strpair_get(state.extern_stub_labels, qn)
    end if
    if stub_lbl == "" then
      safe = s.replaceAll(qn, ".", "_")
      safe = s.replaceAll(safe, "-", "_")
      safe = s.replaceAll(safe, " ", "_")
      safe = s.replaceAll(safe, ":", "_")
      safe = s.replaceAll(safe, "\\", "_")
      safe = s.replaceAll(safe, "/", "_")
      while s.contains(safe, "__")
        safe = s.replaceAll(safe, "__", "_")
      end while
      if safe == "" then safe = "anon" end if
      stub_lbl = "fn_extern_" + safe
    end if

    lid = _next_lid(state)
    l_fail = "lbl_extern_stub_fail_" + lid
    l_done = "lbl_extern_stub_done_" + lid

    tag_off = t.align_up(0x40 + out_args * 8, 16)
    native_off = tag_off + nargs * 8
    required = native_off + nargs * 8
    if required < 0x40 then required = 0x40 end if
    min_req = 0x20 + out_args * 8 + 0x20
    if required < min_req then required = min_req end if
    frame = t.align_to_mod(required, 16, 8)

    state.asm = a.mark(state.asm, stub_lbl)
    if frame <= 0x7F then
      state.asm = a.sub_rsp_imm8(state.asm, frame)
    else
      state.asm = a.sub_rsp_imm32(state.asm, frame)
    end if

    if nargs >= 1 then state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tag_off + 0 * 8, "rcx") end if
    if nargs >= 2 then state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tag_off + 1 * 8, "rdx") end if
    if nargs >= 3 then state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tag_off + 2 * 8, "r8") end if
    if nargs >= 4 then state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tag_off + 3 * 8, "r9") end if
    if nargs > 4 then
      for ai = 4 to nargs - 1
        src_disp = frame + 0x28 + (ai - 4) * 8
        state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", src_disp)
        state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tag_off + ai * 8, "rax")
      end for
    end if

    if nargs > 0 then
      for ai2 = 0 to nargs - 1
        state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tag_off + ai2 * 8)
        pp = params[ai2]
        aty = ""
        if typeof(pp) == "struct" then
          aty = _coerce_name(pp.ty)
          if aty == "" then aty = _coerce_name(pp.type) end if
          if aty == "" then aty = _coerce_name(pp.abi_ty) end if
        else
          aty = _coerce_name(pp)
        end if
        wbuf = ""
        aty_l = s.toLowerAscii(s.trim(aty))
        if aty_l == "wstr" or aty_l == "wstring" then
          wbuf = wpool[ai2 % len(wpool)]
        end if
        state = _emit_extern_arg_to_native(state, pp, l_fail, pos, wbuf)
        state.asm = a.mov_membase_disp_r64(state.asm, "rsp", native_off + ai2 * 8, "rax")
      end for
    end if

    regs = ["rcx", "rdx", "r8", "r9"]
    lim = nargs
    if lim > 4 then lim = 4 end if
    if lim > 0 then
      for ri = 0 to lim - 1
        state.asm = a.mov_r64_membase_disp(state.asm, regs[ri], "rsp", native_off + ri * 8)
      end for
    end if
    if nargs > 4 then
      for si = 4 to nargs - 1
        state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", native_off + si * 8)
        state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20 + (si - 4) * 8, "rax")
      end for
    end if

    state.asm = a.mov_rax_rip_qword(state.asm, _extern_iat_label(dll, sym))
    state.asm = a.call_rax(state.asm)
    state = _emit_extern_ret_from_native(state, ret_ty, l_fail, pos)
    state.asm = a.jmp(state.asm, l_done)

    state.asm = a.mark(state.asm, l_fail)
    state = _emit_make_error_const(state, c.ERR_EXTERN_CONVERSION, "Extern call failed: " + qn + " (argument type mismatch or conversion failure)")

    state.asm = a.mark(state.asm, l_done)
    if frame <= 0x7F then
      state.asm = a.add_rsp_imm8(state.asm, frame)
    else
      state.asm = a.add_rsp_imm32(state.asm, frame)
    end if
    state.asm = a.ret(state.asm)
  end for
  return state
end function
