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

_F64_POS_HALF_BITS = 4602678819172646912

function inline _opt_truthy(v)
  tv = typeof(v)
  if tv == "void" then return false end if
  if tv == "bool" then return v end if
  if tv == "int" or tv == "float" then return v != 0 end if
  if tv == "string" then return v != "" end if
  if tv == "array" then return len(v) != 0 end if
  if tv == "bytes" then return len(v) != 0 end if
  return true
end function

function inline _is_number_no_bool(v)
  tv = typeof(v)
  if tv == "int" or tv == "float" then return true end if
  return false
end function

function inline _is_int_no_bool(v)
  return typeof(v) == "int"
end function

function inline _coerce_name(v)
  tv = typeof(v)
  if tv == "string" then return v end if
  if tv == "struct" then
    nm = try(v.name)
    if typeof(nm) == "string" then return nm end if
    vv = try(v.value)
    if typeof(vv) == "string" then return vv end if
    return ""
  end if
  if tv == "int" or tv == "bool" or tv == "float" then return "" + v end if
  return ""
end function

function inline _named_array_get(arr, key)
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

function inline _named_int_get(arr, key, defaultv)
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

function inline _state_struct_id_get(state, key, defaultv)
  if typeof(state.struct_ids_index) == "struct" then
    v0 = t.fastmap_get(state.struct_ids_index, key, defaultv)
    if typeof(v0) == "int" then return v0 end if
  end if
  return _named_int_get(state.struct_ids, key, defaultv)
end function

function inline _state_enum_id_get(state, key, defaultv)
  if typeof(state.enum_ids_index) == "struct" then
    v0 = t.fastmap_get(state.enum_ids_index, key, defaultv)
    if typeof(v0) == "int" then return v0 end if
  end if
  return _named_int_get(state.enum_ids, key, defaultv)
end function

function inline _state_named_array_get(index_map, arr, key)
  if typeof(index_map) == "struct" then
    return t.fastmap_get(index_map, key, 0)
  end if
  return _named_array_get(arr, key)
end function

function inline _state_struct_fields_get(state, key)
  return _state_named_array_get(state.struct_fields_index, state.struct_fields, key)
end function

function inline _state_enum_variants_get(state, key)
  return _state_named_array_get(state.enum_variants_index, state.enum_variants, key)
end function

function inline _state_struct_static_methods_get(state, key)
  return _state_named_array_get(state.struct_static_methods_index, state.struct_static_methods, key)
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

function inline _method_map_get(map_arr, method_name)
  if typeof(map_arr) == "struct" then
    mv = t.fastmap_get(map_arr, method_name, "")
    if typeof(mv) == "string" then return mv end if
    return ""
  end if
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
  idx_map = state.user_function_index
  if typeof(idx_map) == "struct" and typeof(arr) == "array" then
    idx = t.fastmap_get(idx_map, qname, -1)
    if typeof(idx) == "int" and idx >= 0 and idx < len(arr) then
      it0 = arr[idx]
      if typeof(it0) == "array" and len(it0) == 2 and it0[0] == qname then return it0[1] end if
    end if
  end if
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
  if typeof(state.qualify_cache) == "struct" then
    hit_cached = t.fastmap_get(state.qualify_cache, "@pref|" + base, -1)
    if typeof(hit_cached) == "int" then
      if hit_cached != 0 then return true end if
      return false
    end if
  end if
  pref = base + "."
  found = false

  uf = state.user_functions
  if typeof(uf) == "array" and len(uf) > 0 then
    for i = 0 to len(uf) - 1
      it = uf[i]
      if typeof(it) == "array" and len(it) >= 1 and typeof(it[0]) == "string" then
        if s.startsWith(it[0], pref) then
          found = true
          break
        end if
      end if
      if typeof(it) == "struct" and typeof(it.key) == "string" then
        if s.startsWith(it.key, pref) then
          found = true
          break
        end if
      end if
    end for
  end if

  if found == false then
    eids = state.enum_ids
    if typeof(eids) == "array" and len(eids) > 0 then
      for i = 0 to len(eids) - 1
        it2 = eids[i]
        if typeof(it2) == "struct" and typeof(it2.key) == "string" then
          if s.startsWith(it2.key, pref) then
            found = true
            break
          end if
        end if
      end for
    end if
  end if

  if found == false then
    sids = state.struct_ids
    if typeof(sids) == "array" and len(sids) > 0 then
      for i = 0 to len(sids) - 1
        it3 = sids[i]
        if typeof(it3) == "struct" and typeof(it3.key) == "string" then
          if s.startsWith(it3.key, pref) then
            found = true
            break
          end if
        end if
      end for
    end if
  end if

  if found == false then
    gls = state.globals
    if typeof(gls) == "array" and len(gls) > 0 then
      for i = 0 to len(gls) - 1
        g = gls[i]
        if typeof(g) == "struct" and typeof(g.name) == "string" then
          if s.startsWith(g.name, pref) then
            found = true
            break
          end if
        end if
      end for
    end if
  end if

  if typeof(state.qualify_cache) == "struct" then
    if found then
      state.qualify_cache = t.fastmap_set(state.qualify_cache, "@pref|" + base, 1)
    else
      state.qualify_cache = t.fastmap_set(state.qualify_cache, "@pref|" + base, 0)
    end if
  end if
  return found
end function

function inline _compile_symbol_has(state, key)
  if typeof(key) != "string" or key == "" then return false end if
  if typeof(_user_function_get(state, key)) == "struct" then return true end if
  if typeof(_extern_sig_get(state, key)) == "struct" then return true end if
  if typeof(_state_struct_fields_get(state, key)) == "array" then return true end if
  if _state_enum_id_get(state, key, -1) >= 0 then return true end if
  return false
end function

function inline _builtin_label(name)
  nm = name
  if typeof(nm) != "string" then return "" end if
  if nm == "len" then return "fn_builtin_len" end if
  if nm == "toNumber" then return "fn_toNumber" end if
  if nm == "toFloat" then return "fn_toFloat" end if
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
  if nm == "bytesHash" then return "fn_bytes_hash" end if
  if nm == "stringHash" then return "fn_string_hash" end if
  if nm == "bytesStartsWith" then return "fn_bytes_startswith" end if
  if nm == "bytesEndsWith" then return "fn_bytes_endswith" end if
  if nm == "bytesIndexOf" then return "fn_bytes_indexof" end if
  if nm == "bytesLastIndexOf" then return "fn_bytes_lastindexof" end if
  if nm == "bytesCompare" then return "fn_bytes_compare" end if
  if nm == "str" then return "fn_value_to_string" end if
  if nm == "stringSlice" then return "fn_string_slice" end if
  if nm == "stringIndexOf" then return "fn_string_indexof" end if
  if nm == "stringLastIndexOf" then return "fn_string_lastindexof" end if
  if nm == "stringStartsWith" then return "fn_string_startswith" end if
  if nm == "stringEndsWith" then return "fn_string_endswith" end if
  if nm == "stringRepeat" then return "fn_string_repeat" end if
  if nm == "stringTrimLeftAscii" then return "fn_string_ltrim_ascii" end if
  if nm == "stringTrimRightAscii" then return "fn_string_rtrim_ascii" end if
  if nm == "stringTrimAscii" then return "fn_string_trim_ascii" end if
  if nm == "stringIsBlankAscii" then return "fn_string_is_blank_ascii" end if
  if nm == "stringReverse" then return "fn_string_reverse" end if
  if nm == "stringToLowerAscii" then return "fn_string_to_lower_ascii" end if
  if nm == "stringToUpperAscii" then return "fn_string_to_upper_ascii" end if
  if nm == "stringEqualsIgnoreCaseAscii" then return "fn_string_eq_ignore_case_ascii" end if
  if nm == "stringJoin" then return "fn_string_join" end if
  if nm == "copyBytes" then return "fn_builtin_copyBytes" end if
  if nm == "copyStringBytes" then return "fn_builtin_copyStringBytes" end if
  if nm == "fillBytes" then return "fn_builtin_fillBytes" end if
  if nm == "callStats" then return "fn_callStats" end if
  if nm == "heap_count" then return "fn_heap_count" end if
  if nm == "heap_bytes_used" then return "fn_heap_bytes_used" end if
  if nm == "heap_bytes_committed" then return "fn_heap_bytes_committed" end if
  if nm == "heap_bytes_reserved" then return "fn_heap_bytes_reserved" end if
  if nm == "heap_free_bytes" then return "fn_heap_free_bytes" end if
  if nm == "heap_free_blocks" then return "fn_heap_free_blocks" end if
  return ""
end function

function inline _next_lid(state)
  lid = state.label_id
  state.label_id = state.label_id + 1
  return lid
end function

function inline _alias_lookup(alias_map, key)
  if typeof(alias_map) == "struct" then
    v0 = t.fastmap_get(alias_map, key, "")
    if typeof(v0) == "string" then return v0 end if
    return ""
  end if
  if typeof(alias_map) != "array" or len(alias_map) <= 0 then return "" end if
  for i = 0 to len(alias_map) - 1
    p = alias_map[i]
    if typeof(p) == "struct" and p.key == key then
      if typeof(p.value) == "string" then return p.value end if
    end if
  end for
  return ""
end function

function inline _alias_lookup_array_exact(alias_map, key)
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
  qn_len = len(qname)
  if qn_len <= 0 then return qname end if
  dot = -1
  for i = 0 to qn_len - 1
    if qname[i] == "." then
      dot = i
      break
    end if
  end for
  if dot < 0 then return qname end if
  alias = s.substr(qname, 0, dot)
  target = ""
  if typeof(state.import_aliases) == "array" then
    target = _alias_lookup_array_exact(state.import_aliases, alias)
  else
    if typeof(state.import_alias_index) == "struct" then
      t0 = t.fastmap_get(state.import_alias_index, alias, "")
      if typeof(t0) == "string" then target = t0 end if
    end if
    if target == "" then
      target = _alias_lookup(state.import_aliases, alias)
    end if
  end if
  if target == "" then return qname end if
  if dot + 1 >= qn_len then return target end if
  tail = s.substr(qname, dot + 1, qn_len - dot - 1)
  if tail == "" then return target end if
  return target + "." + tail
end function

function inline _arr_has_str(arr, value)
  if typeof(arr) != "array" or len(arr) <= 0 then return false end if
  for i = 0 to len(arr) - 1
    if arr[i] == value then return true end if
  end for
  return false
end function

function _is_current_localish_name(state, name)
  if typeof(name) != "string" or name == "" then return false end if

  params = try(state.current_fn_param_names)
  if _arr_has_str(params, name) then return true end if

  return false
end function

function _alias_target_for_base(state, base)
  if typeof(base) != "string" or base == "" then return "" end if
  if typeof(state.import_aliases) == "array" then
    return _alias_lookup_array_exact(state.import_aliases, base)
  end if
  target = ""
  if typeof(state.import_alias_index) == "struct" then
    t0 = t.fastmap_get(state.import_alias_index, base, "")
    if typeof(t0) == "string" then target = t0 end if
  end if
  if target == "" then target = _alias_lookup(state.import_aliases, base) end if
  return target
end function

function _member_base_alias_shadowed(state, expr)
  cur = expr
  while typeof(cur) == "struct" and _coerce_name(try(cur.node_kind)) == "Member"
    nxt = try(cur.target)
    obj = try(cur.obj)
    if typeof(nxt) != "struct" and typeof(obj) == "struct" then nxt = obj end if
    cur = nxt
  end while
  if typeof(cur) != "struct" or _coerce_name(try(cur.node_kind)) != "Var" then return false end if
  base = _coerce_name(try(cur.name))
  if base == "" then return false end if
  if _alias_target_for_base(state, base) == "" then return false end if

  b = scope.cg_resolve_binding(state, base)
  if typeof(b) == "struct" then
    k = _coerce_name(try(b.kind))
    if k != "" and k != "global" then return true end if
  end if

  return _is_current_localish_name(state, base)
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

  qpref0 = ""
  if typeof(state.current_qname_prefix) == "string" then qpref0 = state.current_qname_prefix end if
  fpref0 = ""
  if typeof(state.current_file_prefix) == "string" then fpref0 = state.current_file_prefix end if
  bid0 = 0
  if typeof(state.binding_id) == "int" then bid0 = state.binding_id end if
  qkey = bid0 + "|" + qpref0 + "|" + fpref0 + "|" + name
  if typeof(state.qualify_cache) == "struct" then
    hitq = t.fastmap_get(state.qualify_cache, qkey, 0)
    if typeof(hitq) == "string" then return hitq end if
  else
    state.qualify_cache = t.fastmap_new(1024)
  end if

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
      if typeof(b) == "struct" then
        state.qualify_cache = t.fastmap_set(state.qualify_cache, qkey, cands[i])
        return cands[i]
      end if
    end for
  end if

  if len(cands) > 0 then
    for ci = 0 to len(cands) - 1
      cand = cands[ci]
      if _compile_symbol_has(state, cand) then
        state.qualify_cache = t.fastmap_set(state.qualify_cache, qkey, cand)
        return cand
      end if
    end for
  end if

  pools = [state.user_functions, state.extern_sigs, state.struct_fields, state.enum_ids]
  if pkg_pref != "" then
    suffix = "." + n1
    hits = []
    for pi2 = 0 to len(pools) - 1
      hits = _pool_collect_suffix(pools[pi2], pkg_pref, suffix, hits)
    end for
    if typeof(hits) == "array" and len(hits) == 1 then
      out1 = hits[0]
      state.qualify_cache = t.fastmap_set(state.qualify_cache, qkey, out1)
      return out1
    end if
  end if

  state.qualify_cache = t.fastmap_set(state.qualify_cache, qkey, n1)
  return n1
end function

function _expr_to_qualname(state, expr)
  if typeof(expr) != "struct" then return "" end if
  qn0 = _qname_of(state, expr)
  if typeof(qn0) == "string" and qn0 != "" then return qn0 end if
  k0 = _coerce_name(try(expr.node_kind))
  if k0 == "Var" and typeof(try(expr.name)) == "string" then
    nm = try(expr.name)
    if s.contains(nm, ".") then return _qualify_identifier(state, _apply_import_alias(state, nm)) end if
    b = scope.cg_resolve_binding(state, nm)
    if typeof(b) == "struct" then return nm end if
    if _has_any_global_prefix(state, nm) then return nm end if
    return _qualify_identifier(state, nm)
  end if
  if k0 == "Member" then
    mt = try(expr.target)
    if typeof(mt) != "struct" then mt = try(expr.obj) end if
    b = _expr_to_qualname(state, mt)
    if b == "" then return "" end if
    mn0 = _coerce_name(try(expr.name))
    if mn0 == "" then mn0 = _coerce_name(try(expr.field)) end if
    if mn0 == "" then return "" end if
    return _qualify_identifier(state, _apply_import_alias(state, b + "." + mn0))
  end if
  return ""
end function

function _extern_sig_get(state, qname)
  if typeof(qname) != "string" or qname == "" then return 0 end if
  if typeof(state.extern_sig_index) == "struct" then
    hit = t.fastmap_get(state.extern_sig_index, qname, 0)
    if typeof(hit) == "struct" then return hit end if
  end if
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

      sid = _state_struct_id_get(state, sname, 0)
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

  k = _coerce_name(try(expr.node_kind))

  if k == "Num" or k == "Str" or k == "Bool" then
    return ConstEvalResult(true, try(expr.value))
  end if

  if k == "Var" then
    raw_nm = _coerce_name(try(expr.name))
    if raw_nm == "" then return ConstEvalResult(false, 0) end if
    nm = _qualify_identifier(state, raw_nm)
    v = _resolve_const_value(state, nm)
    if v.ok then return v end if
    if nm != raw_nm then
      return _resolve_const_value(state, raw_nm)
    end if
    return ConstEvalResult(false, 0)
  end if

  if k == "Member" then
    qn = _expr_to_qualname(state, expr)
    if qn == "" then return ConstEvalResult(false, 0) end if
    return _resolve_const_value(state, qn)
  end if

  if k == "Unary" then
    rv = cg_expr_try_const_value(state, try(expr.right))
    if rv.ok == false then return ConstEvalResult(false, 0) end if
    opu = _coerce_name(try(expr.op))
    if opu == "not" then return ConstEvalResult(true, not _opt_truthy(rv.value)) end if
    if opu == "-" then
      if _is_number_no_bool(rv.value) == false then return ConstEvalResult(false, 0) end if
      return ConstEvalResult(true, 0 - rv.value)
    end if
    if opu == "~" then
      if _is_int_no_bool(rv.value) == false then return ConstEvalResult(false, 0) end if
      return ConstEvalResult(true, ~rv.value)
    end if
    return ConstEvalResult(false, 0)
  end if

  if k == "Bin" then
    lv = cg_expr_try_const_value(state, try(expr.left))
    if lv.ok == false then return ConstEvalResult(false, 0) end if

    opb = _coerce_name(try(expr.op))
    if opb == "and" and _opt_truthy(lv.value) == false then
      return ConstEvalResult(true, false)
    end if
    if opb == "or" and _opt_truthy(lv.value) then
      return ConstEvalResult(true, true)
    end if

    rv = cg_expr_try_const_value(state, try(expr.right))
    if rv.ok == false then return ConstEvalResult(false, 0) end if
    return _try_const_bin(opb, lv.value, rv.value)
  end if

  return ConstEvalResult(false, 0)
end function

function _opt_try_const_immediate_encoded(state, expr)
  cv = cg_expr_try_const_value(state, expr)
  if cv.ok == false then return 0 end if
  if typeof(cv.value) == "bool" then return t.enc_bool(cv.value) end if
  if typeof(cv.value) == "int" then return t.enc_int(cv.value) end if
  if typeof(cv.value) == "float" then
    enc = t.try_enc_float_immediate(cv.value)
    if typeof(enc) == "int" then return enc end if
  end if
  return 0
end function

function _opt_try_pure_const_array_len(state, expr)
  if typeof(expr) != "struct" then return -1 end if
  if _coerce_name(try(expr.node_kind)) != "ArrayLit" then return -1 end if
  items = try(expr.items)
  if typeof(items) != "array" then return 0 end if
  for i = 0 to len(items) - 1
    if cg_expr_try_const_value(state, items[i]).ok == false then
      return -1
    end if
  end for
  return len(items)
end function

function _opt_try_known_type_label(state, expr, detailed)
  cv = cg_expr_try_const_value(state, expr)
  if cv.ok then
    if typeof(cv.value) == "bool" then return "obj_type_bool" end if
    if typeof(cv.value) == "int" then return "obj_type_int" end if
    if typeof(cv.value) == "float" then return "obj_type_float" end if
    if typeof(cv.value) == "string" then return "obj_type_string" end if
  end if

  if _opt_try_pure_const_array_len(state, expr) >= 0 then
    return "obj_type_array"
  end if

  if typeof(expr) == "struct" and _coerce_name(try(expr.node_kind)) == "VoidLit" then
    return "obj_type_void"
  end if
  return ""
end function

function _qname_parts_any(expr)
  if typeof(expr) != "struct" then return 0 end if
  k = _coerce_name(try(expr.node_kind))
  if k == "Var" then
    nm = _coerce_name(try(expr.name))
    if nm == "" then return 0 end if
    return s.split(nm, ".")
  end if
  if k == "Member" then
    tgt2 = try(expr.target)
    obj2 = try(expr.obj)
    if typeof(tgt2) != "struct" and typeof(obj2) == "struct" then
      tgt2 = obj2
    end if
    base2 = _qname_parts_any(tgt2)
    if typeof(base2) != "array" or len(base2) <= 0 then return 0 end if
    nm2 = _coerce_name(try(expr.name))
    if nm2 == "" then nm2 = _coerce_name(try(expr.field)) end if
    if nm2 == "" then return 0 end if
    return base2 +[nm2]
  end if
  return 0
end function

function _emit_std_math_roundlike_intrinsic(state, callee_name, arg)
  // Conservative selfhost fallback: keep std.math floor/ceil/trunc/round on the
  // MiniLang stdlib implementation until the direct SSE lowering is proven
  // parity-correct on the ML compiler too.
  return [state, false]
end function

function _is_expr_list_separator_artifact(ex)
  if typeof(ex) != "struct" then return false end if
  nk = _coerce_name(try(ex.node_kind))
  kk = _coerce_name(try(ex.kind))
  vv = _coerce_name(try(ex.value))
  if nk == "COMMA" then return true end if
  if kk == "COMMA" and (vv == "" or vv == ",") then return true end if
  return false
end function

function _filter_expr_list_separator_artifacts(items)
  if typeof(items) != "array" then return [] end if
  if len(items) <= 0 then return items end if
  out_b = t.arr_chunk_new(len(items))
  changed = false
  for i = 0 to len(items) - 1
    it = items[i]
    if _is_expr_list_separator_artifact(it) then
      changed = true
      continue
    end if
    out_b = t.arr_chunk_push(out_b, it)
  end for
  if changed == false then return items end if
  return t.arr_chunk_finish(out_b)
end function

function cg_emit_expr(state, expr)
  if typeof(expr) != "struct" then
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return state
  end if

  k = _coerce_name(try(expr.node_kind))
  if k == "" then k = _coerce_name(try(expr.kind)) end if

  if k == "COMMA" then
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return state
  end if

  if k == "Num" then
    return _emit_expr_num(state, expr)
  end if

  if k == "Bool" then
    return _emit_expr_bool(state, expr)
  end if

  if k == "Str" then
    return _emit_expr_str(state, expr)
  end if

  if k == "VoidLit" then
    return _emit_expr_voidlit(state, expr)
  end if

  if k == "IsType" then
    return _emit_expr_is_type(state, expr)
  end if

  if k == "Var" then
    return _emit_expr_var(state, expr)
  end if

  if k == "Member" then
    return _emit_expr_member(state, expr)
  end if

  if k == "Index" then
    return _emit_expr_index(state, expr)
  end if

  if k == "Unary" then
    return _emit_expr_unary(state, expr)
  end if

  if k == "Bin" then
    return _emit_expr_bin(state, expr)
  end if

  if k == "Call" then
    return _emit_expr_call(state, expr)
  end if

  if k == "ArrayLit" then
    return _emit_expr_array_lit(state, expr)
  end if

  cv = cg_expr_try_const_value(state, expr)
  if cv.ok then
    return _opt_emit_const_value(state, cv.value)
  end if

  return _emit_expr_unsupported(state, expr, k)
end function

function _emit_expr_num(state, expr)
  val_num = try(expr.value)
  if typeof(val_num) == "int" then
    state.asm = a.mov_rax_imm64(state.asm, t.enc_int(val_num))
    return state
  end if
  if typeof(val_num) == "float" then
    enc_num = t.try_enc_float_immediate(val_num)
    if typeof(enc_num) == "int" then
      state.asm = a.mov_rax_imm64(state.asm, enc_num)
    else
      lbl_num = "flt_" + _next_lid(state)
      state.rdata = d.rdata_add_obj_float(state.rdata, lbl_num, val_num)
      state.asm = a.lea_rax_rip(state.asm, lbl_num)
    end if
    return state
  end if
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  return state
end function

function _emit_expr_bool(state, expr)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(try(expr.value)))
  return state
end function

function _emit_expr_str(state, expr)
  lbl_str = "objstr_" + _next_lid(state)
  state.rdata = d.rdata_add_obj_string(state.rdata, lbl_str, try(expr.value))
  state.asm = a.lea_rax_rip(state.asm, lbl_str)
  return state
end function

function _emit_expr_voidlit(state, expr)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  return state
end function

function _emit_expr_is_type(state, expr)
  ty_raw = _coerce_name(expr.type_name)
  neg = false
  if typeof(expr.negated) == "bool" and expr.negated then neg = true end if

  ty_q = ty_raw
  if s.contains(ty_q, ".") then
    ty_q = _apply_import_alias(state, ty_q)
  else
    cand_s = _qualify_identifier(state, ty_q)
    sid_c = _state_struct_id_get(state, cand_s, 0)
    if sid_c != 0 then
      ty_q = cand_s
    else
      cand_e = _qualify_identifier(state, ty_q)
      eid_c = _state_enum_id_get(state, cand_e, -1)
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
      vars_ty = _state_enum_variants_get(state, base_ty)
      if typeof(vars_ty) == "array" and len(vars_ty) > 0 then
        hit_var = false
        for vi_ty = 0 to len(vars_ty) - 1
          if _coerce_name(vars_ty[vi_ty]) == vname_ty then
            hit_var = true
            break
          end if
        end for
        if hit_var and _state_enum_id_get(state, base_ty, -1) >= 0 then
          ty_q = base_ty
        end if
      end if
    end if
  end if

  sid = _state_struct_id_get(state, ty_q, 0)
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
    l_struct_inst_s = "is_type_struct_inst_" + fid_s
    l_struct_sid_s = "is_type_struct_sid_" + fid_s
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRUCT)
    state.asm = a.jcc(state.asm, "e", l_struct_inst_s)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRUCTTYPE)
    state.asm = a.jcc(state.asm, "ne", l_false_s)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 8)
    state.asm = a.jmp(state.asm, l_struct_sid_s)

    state.asm = a.mark(state.asm, l_struct_inst_s)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 4)

    state.asm = a.mark(state.asm, l_struct_sid_s)
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

  eid = _state_enum_id_get(state, ty_q, -1)
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
end function

function _emit_expr_var(state, expr)
  nm_raw = ""
  nm_try = try(expr.name)
  if typeof(nm_try) == "string" then nm_raw = nm_try end if
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
end function

function _emit_expr_member(state, expr)
  mname = _coerce_name(try(expr.name))
  if mname == "" then mname = _coerce_name(try(expr.field)) end if
  tgt_m = try(expr.target)
  obj_m = try(expr.obj)
  if typeof(tgt_m) != "struct" and typeof(obj_m) == "struct" then tgt_m = obj_m end if

  base_alias_shadowed = _member_base_alias_shadowed(state, expr)
  if base_alias_shadowed == false then
    qmem0 = _qname_of(state, expr)
    if qmem0 != "" then
      return scope.emit_load_var_scoped(state, qmem0)
    end if
  end if

  base_q = _expr_to_qualname(state, tgt_m)
  if base_alias_shadowed == false and base_q != "" and mname != "" then
    base_q_m = _qualify_identifier(state, base_q)
    if base_q_m == "" then base_q_m = base_q end if

    // Static struct method reference: StructName.method -> StructName.__static__.method
    smap = _state_struct_static_methods_get(state, base_q_m)
    if (typeof(smap) != "array" and typeof(smap) != "struct") or (typeof(smap) == "array" and len(smap) <= 0) then
      smap = _state_struct_static_methods_get(state, base_q)
    end if
    if (typeof(smap) == "array" and len(smap) > 0) or typeof(smap) == "struct" then
      sqfn = _method_map_get(smap, mname)
      if sqfn != "" then
        return scope.emit_load_var_scoped(state, sqfn)
      end if
    end if

    // Enum variant literal: Color.Red
    vars = _state_enum_variants_get(state, base_q_m)
    enum_base = base_q_m
    if typeof(vars) != "array" or len(vars) <= 0 then
      vars = _state_enum_variants_get(state, base_q)
      enum_base = base_q
    end if
    if typeof(vars) == "array" and len(vars) > 0 then
      for vi = 0 to len(vars) - 1
        if _coerce_name(vars[vi]) == mname then
          eid = _state_enum_id_get(state, enum_base, -1)
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
      if _state_struct_id_get(state, qc, 0) != 0 then
        return scope.emit_load_var_scoped(state, qc)
      end if
      if _state_enum_id_get(state, qc, -1) >= 0 then
        return scope.emit_load_var_scoped(state, qc)
      end if
      if typeof(_extern_sig_get(state, qc)) == "struct" then
        return scope.emit_load_var_scoped(state, qc)
      end if
    end for
  end if

  // Runtime member read on struct instance.
  tgt = tgt_m
  if typeof(tgt) != "struct" then
    tgt = try(expr.target)
    obj_rt = try(expr.obj)
    if typeof(tgt) != "struct" and typeof(obj_rt) == "struct" then tgt = obj_rt end if
  end if
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
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 4)
  state = _emit_struct_field_index_dispatch(state, mname, "edx", "ecx", l_ok_m, l_fail_m, "memb_" + fid_m)

  state.asm = a.mark(state.asm, l_ok_m)
  state.asm = a.mov_r64_mem_bis(state.asm, "rax", "r11", "rcx", 8, 8)
  state.asm = a.jmp(state.asm, l_done_m)

  state.asm = a.mark(state.asm, l_fail_m)
  lid_v = _next_lid(state)
  l_not_void = "memb_not_void_" + lid_v
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_VOID)
  state.asm = a.jcc(state.asm, "ne", l_not_void)
  state = core.emit_dbg_line(state, expr)
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
  state = core.emit_dbg_line(state, expr)
  state = _emit_make_error_const(state, c.ERR_MEMBER_TARGET_TYPE, "Cannot access member '" + mname + "' on non-struct value")
  state = _emit_auto_errprop(state)
  state.asm = a.jmp(state.asm, l_done_m)

  state.asm = a.mark(state.asm, l_is_ptr)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRUCT)
  state.asm = a.jcc(state.asm, "e", l_is_struct)
  state = core.emit_dbg_line(state, expr)
  state = _emit_make_error_const(state, c.ERR_MEMBER_TARGET_TYPE, "Cannot access member '" + mname + "' on non-struct value")
  state = _emit_auto_errprop(state)
  state.asm = a.jmp(state.asm, l_done_m)

  state.asm = a.mark(state.asm, l_is_struct)
  state = core.emit_dbg_line(state, expr)
  state = _emit_make_error_const(state, c.ERR_MEMBER_NOT_FOUND, "Struct has no member '" + mname + "'")
  state = _emit_auto_errprop(state)

  state.asm = a.mark(state.asm, l_done_m)
  return state
end function

function _emit_expr_index(state, expr)
  lid_ix = _next_lid(state)
  l_arr = "idx_arr_" + lid_ix
  l_bytes = "idx_bytes_" + lid_ix
  l_str = "idx_str_" + lid_ix
  l_bad_target = "idx_bad_target_" + lid_ix
  l_oob = "idx_oob_" + lid_ix
  l_done = "idx_done_" + lid_ix

  state = cg_emit_expr(state, try(expr.target))

  vid = _next_lid(state)
  l_nvoid = "idx_nvoid_" + vid
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_VOID)
  state.asm = a.jcc(state.asm, "ne", l_nvoid)
  state = core.emit_dbg_line(state, expr)
  state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot index void")
  state = _emit_auto_errprop(state)
  state.asm = a.jmp(state.asm, l_done)
  state.asm = a.mark(state.asm, l_nvoid)

  base_off = core.alloc_expr_temps(state, 8)
  need_top = 0
  if typeof(base_off) == "int" and base_off > 0 then
    if typeof(state.expr_temp_base) == "int" then
      need_top = base_off - state.expr_temp_base + 8
    else
      need_top = base_off + 8
    end if
    if typeof(state.expr_temp_top) != "int" or state.expr_temp_top < need_top then
      state.expr_temp_top = need_top
      state = core._sync_expr_temp_root_count(state)
    end if
  end if
  state.asm = a.mov_rsp_disp32_rax(state.asm, base_off)

  state = cg_emit_expr(state, try(expr.index))

  if typeof(need_top) == "int" and need_top > 0 then
    if typeof(state.expr_temp_top) != "int" or state.expr_temp_top < need_top then
      state.expr_temp_top = need_top
      state = core._sync_expr_temp_root_count(state)
    end if
  end if

  vid2 = _next_lid(state)
  l_iok = "idx_iok_" + vid2
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_VOID)
  state.asm = a.jcc(state.asm, "ne", l_iok)
  state = core.emit_dbg_line(state, expr)
  state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot use void as index")
  state = _emit_auto_errprop(state)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", base_off, t.enc_void(), true)
  state.asm = a.jmp(state.asm, l_done)
  state.asm = a.mark(state.asm, l_iok)

  vid3 = _next_lid(state)
  l_int_idx = "idx_intidx_" + vid3
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
  state.asm = a.jcc(state.asm, "e", l_int_idx)
  state = core.emit_dbg_line(state, expr)
  state = _emit_make_error_const(state, c.ERR_INDEX_TYPE, "Index must be an int")
  state = _emit_auto_errprop(state)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", base_off, t.enc_void(), true)
  state.asm = a.jmp(state.asm, l_done)
  state.asm = a.mark(state.asm, l_int_idx)

  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.sar_r64_imm8(state.asm, "rcx", 3)

  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", base_off)

  state = core.free_expr_temps(state, 8)

  state.asm = a.mov_r64_r64(state.asm, "r10", "r11")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_bad_target)
  state.asm = a.test_r64_r64(state.asm, "r11", "r11")
  state.asm = a.jcc(state.asm, "e", l_bad_target)

  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
  state.asm = a.jcc(state.asm, "e", l_arr)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY_IMM)
  state.asm = a.jcc(state.asm, "e", l_arr)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "e", l_str)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "e", l_bytes)
  state.asm = a.jmp(state.asm, l_bad_target)

  state.asm = a.mark(state.asm, l_arr)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 4)
  l_a_ok = "idx_a_ok_" + lid_ix
  state.asm = a.cmp_r32_imm(state.asm, "ecx", 0)
  state.asm = a.jcc(state.asm, "ge", l_a_ok)
  state.asm = a.add_r32_r32(state.asm, "ecx", "edx")
  state.asm = a.mark(state.asm, l_a_ok)
  state.asm = a.cmp_r32_imm(state.asm, "ecx", 0)
  state.asm = a.jcc(state.asm, "l", l_oob)
  state.asm = a.cmp_r32_r32(state.asm, "ecx", "edx")
  state.asm = a.jcc(state.asm, "ge", l_oob)
  state.asm = a.mov_r64_mem_bis(state.asm, "rax", "r11", "rcx", 8, 8)
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_bytes)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 4)
  l_b_ok = "idx_b_ok_" + lid_ix
  state.asm = a.cmp_r32_imm(state.asm, "ecx", 0)
  state.asm = a.jcc(state.asm, "ge", l_b_ok)
  state.asm = a.add_r32_r32(state.asm, "ecx", "edx")
  state.asm = a.mark(state.asm, l_b_ok)
  state.asm = a.cmp_r32_imm(state.asm, "ecx", 0)
  state.asm = a.jcc(state.asm, "l", l_oob)
  state.asm = a.cmp_r32_r32(state.asm, "ecx", "edx")
  state.asm = a.jcc(state.asm, "ge", l_oob)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
  state.asm = a.add_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.add_rax_imm8(state.asm, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "eax", "rax", 0)
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_str)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 4)
  l_s_ok = "idx_s_ok_" + lid_ix
  state.asm = a.cmp_r32_imm(state.asm, "ecx", 0)
  state.asm = a.jcc(state.asm, "ge", l_s_ok)
  state.asm = a.add_r32_r32(state.asm, "ecx", "edx")
  state.asm = a.mark(state.asm, l_s_ok)
  state.asm = a.cmp_r32_imm(state.asm, "ecx", 0)
  state.asm = a.jcc(state.asm, "l", l_oob)
  state.asm = a.cmp_r32_r32(state.asm, "ecx", "edx")
  state.asm = a.jcc(state.asm, "ge", l_oob)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
  state.asm = a.add_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.add_rax_imm8(state.asm, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "eax", "rax", 0)
  state.asm = a.lea_r11_rip(state.asm, "obj_char_table")
  state.asm = a.shl_rax_imm8(state.asm, 4)
  state.asm = a.add_r64_r64(state.asm, "rax", "r11")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_bad_target)
  state = core.emit_dbg_line(state, expr)
  state = _emit_make_error_const(state, c.ERR_INDEX_TARGET_TYPE, "Indexing requires array, string, or bytes")
  state = _emit_auto_errprop(state)
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_oob)
  state = core.emit_dbg_line(state, expr)
  state = _emit_make_error_const(state, c.ERR_INDEX_OOB, "Array index out of bounds")
  state = _emit_auto_errprop(state)

  state.asm = a.mark(state.asm, l_done)
  return state
end function

function _emit_expr_unary(state, expr)
  state = cg_emit_expr(state, expr.right)
  if expr.op == "-" then
    lid_u = _next_lid(state)
    lid_uv = _next_lid(state)
    l_int_u = "uminus_int_" + lid_u
    l_fail_u = "uminus_fail_" + lid_u
    l_done_u = "uminus_end_" + lid_u
    l_nvoid_u = "uminus_nvoid_" + lid_uv
    state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
    state.asm = a.and_r64_imm(state.asm, "rdx", 7)
    state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_INT)
    state.asm = a.jcc(state.asm, "e", l_int_u)
    state = core.emit_to_double_xmm(state, 0, l_fail_u)
    state.asm = a.xorpd_xmm_xmm(state.asm, "xmm1", "xmm1")
    state.asm = a.subsd_xmm_xmm(state.asm, "xmm1", "xmm0")
    state.asm = a.movapd_xmm_xmm(state.asm, "xmm0", "xmm1")
    state = core.emit_normalize_xmm0_to_value(state)
    state.asm = a.jmp(state.asm, l_done_u)

    state.asm = a.mark(state.asm, l_int_u)
    state.asm = a.neg_rax(state.asm)
    state.asm = a.add_rax_imm8(state.asm, 2)
    state.asm = a.jmp(state.asm, l_done_u)

    state.asm = a.mark(state.asm, l_fail_u)
    state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
    state.asm = a.and_r64_imm(state.asm, "rdx", 7)
    state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_VOID)
    state.asm = a.jcc(state.asm, "ne", l_nvoid_u)
    state = core.emit_dbg_line(state, expr)
    state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot apply unary '-' to void")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_done_u)
    state.asm = a.mark(state.asm, l_nvoid_u)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    state.asm = a.mark(state.asm, l_done_u)
    return state
  end if
  if expr.op == "not" then
    lid_n = _next_lid(state)
    lid_nv = _next_lid(state)
    l_false = "not_false_" + lid_n
    l_end = "not_end_" + lid_n
    l_nvoid = "not_nvoid_" + lid_nv
    state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
    state.asm = a.and_r64_imm(state.asm, "rdx", 7)
    state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_VOID)
    state.asm = a.jcc(state.asm, "ne", l_nvoid)
    state = core.emit_dbg_line(state, expr)
    state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot apply unary 'not' to void")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_end)
    state.asm = a.mark(state.asm, l_nvoid)
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
    lid_v = _next_lid(state)
    l_done_b = "ubnot_done_" + lid_b
    l_end_b = "ubnot_end_" + lid_b
    l_nvoid_b = "bnot_nvoid_" + lid_v
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
    state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
    state.asm = a.and_r64_imm(state.asm, "rdx", 7)
    state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_VOID)
    state.asm = a.jcc(state.asm, "ne", l_nvoid_b)
    state = core.emit_dbg_line(state, expr)
    state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot apply unary '~' to void")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_end_b)
    state.asm = a.mark(state.asm, l_nvoid_b)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    state.asm = a.mark(state.asm, l_end_b)
    return state
  end if
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  return state
end function

function _emit_expr_bin(state, expr)
  if expr.op == "and" then
    lid_and = _next_lid(state)
    lid_and_v = _next_lid(state)
    lid_and_rv = _next_lid(state)
    l_and_false = "and_false_" + lid_and
    l_and_end = "and_end_" + lid_and
    l_and_nvoid = "and_nvoid_" + lid_and_v
    l_and_rnvoid = "and_rnvoid_" + lid_and_rv
    l_and_rfalse = "and_rfalse_" + lid_and
    state = cg_emit_expr(state, expr.left)
    state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
    state.asm = a.and_r64_imm(state.asm, "rdx", 7)
    state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_VOID)
    state.asm = a.jcc(state.asm, "ne", l_and_nvoid)
    state = core.emit_dbg_line(state, expr)
    state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot apply 'and' to void")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_and_end)
    state.asm = a.mark(state.asm, l_and_nvoid)
    state = core.emit_jmp_if_false_rax(state, l_and_false)
    state = cg_emit_expr(state, expr.right)
    state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
    state.asm = a.and_r64_imm(state.asm, "rdx", 7)
    state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_VOID)
    state.asm = a.jcc(state.asm, "ne", l_and_rnvoid)
    state = core.emit_dbg_line(state, expr)
    state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot apply 'and' to void")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_and_end)
    state.asm = a.mark(state.asm, l_and_rnvoid)
    state = core.emit_jmp_if_false_rax(state, l_and_rfalse)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
    state.asm = a.jmp(state.asm, l_and_end)
    state.asm = a.mark(state.asm, l_and_rfalse)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
    state.asm = a.jmp(state.asm, l_and_end)
    state.asm = a.mark(state.asm, l_and_false)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
    state.asm = a.mark(state.asm, l_and_end)
    return state
  end if

  if expr.op == "or" then
    lid_or = _next_lid(state)
    lid_or_v = _next_lid(state)
    lid_or_rv = _next_lid(state)
    l_or_eval = "or_eval_" + lid_or
    l_or_false = "or_rfalse_" + lid_or
    l_or_end = "or_end_" + lid_or
    l_or_nvoid = "or_nvoid_" + lid_or_v
    l_or_rnvoid = "or_rnvoid_" + lid_or_rv
    state = cg_emit_expr(state, expr.left)
    state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
    state.asm = a.and_r64_imm(state.asm, "rdx", 7)
    state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_VOID)
    state.asm = a.jcc(state.asm, "ne", l_or_nvoid)
    state = core.emit_dbg_line(state, expr)
    state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot apply 'or' to void")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_or_end)
    state.asm = a.mark(state.asm, l_or_nvoid)
    state = core.emit_jmp_if_false_rax(state, l_or_eval)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
    state.asm = a.jmp(state.asm, l_or_end)
    state.asm = a.mark(state.asm, l_or_eval)
    state = cg_emit_expr(state, expr.right)
    state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
    state.asm = a.and_r64_imm(state.asm, "rdx", 7)
    state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_VOID)
    state.asm = a.jcc(state.asm, "ne", l_or_rnvoid)
    state = core.emit_dbg_line(state, expr)
    state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot apply 'or' to void")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_or_end)
    state.asm = a.mark(state.asm, l_or_rnvoid)
    state = core.emit_jmp_if_false_rax(state, l_or_false)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
    state.asm = a.jmp(state.asm, l_or_end)
    state.asm = a.mark(state.asm, l_or_false)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
    state.asm = a.mark(state.asm, l_or_end)
    return state
  end if

  left_tmp = core.alloc_expr_temps(state, 8)
  right_tmp = core.alloc_expr_temps(state, 8)
  state = cg_emit_expr(state, expr.left)
  state.asm = a.mov_rsp_disp32_rax(state.asm, left_tmp)
  state = cg_emit_expr(state, expr.right)
  state.asm = a.mov_rsp_disp32_rax(state.asm, right_tmp)

  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", left_tmp)
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", right_tmp)
  state = core.free_expr_temps(state, 16)
  tmp_bin_ok = false

  lhs_const = _opt_try_const_value(state, expr.left)
  rhs_const = _opt_try_const_value(state, expr.right)
  lhs_const_int_ok = lhs_const.ok and typeof(lhs_const.value) == "int"
  rhs_const_int_ok = rhs_const.ok and typeof(rhs_const.value) == "int"
  lhs_const_int = 0
  rhs_const_int = 0
  if lhs_const_int_ok then lhs_const_int = lhs_const.value end if
  if rhs_const_int_ok then rhs_const_int = rhs_const.value end if

  op = expr.op
  lid = _next_lid(state)
  l_int = "bin_int_" + lid
  l_float = "bin_float_" + lid
  l_str = "bin_str_" + lid
  l_cmp = "bin_cmp_" + lid
  l_fail = "bin_fail_" + lid
  l_done = "bin_done_" + lid

  if op == "==" or op == "!=" then
    l_cmp_float = "cmp_float_" + lid
    l_cmp_fail = "cmp_fail_" + lid
    l_cmp_done = "cmp_done_" + lid
    int_cc = "e"
    if op == "!=" then int_cc = "ne" end if

    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_cmp_float)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_cmp_float)

    state.asm = a.cmp_r64_r64(state.asm, "r10", "r11")
    state.asm = a.setcc_al(state.asm, int_cc)
    state.asm = a.movzx_eax_al(state.asm)
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_BOOL)
    state.asm = a.jmp(state.asm, l_cmp_done)

    state.asm = a.mark(state.asm, l_cmp_float)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state = core.emit_to_double_xmm(state, 0, l_cmp_fail)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state = core.emit_to_double_xmm(state, 1, l_cmp_fail)
    state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm1")
    if op == "==" then
      state.asm = a.setcc_al(state.asm, "e")
      state.asm = a.setcc_r8(state.asm, "p", "dl")
      state.asm = a.xor_r8_imm8(state.asm, "dl", 1)
      state.asm = a.and_r8_r8(state.asm, "al", "dl")
    else
      state.asm = a.setcc_al(state.asm, "ne")
      state.asm = a.setcc_r8(state.asm, "p", "dl")
      state.asm = a.or_r8_r8(state.asm, "al", "dl")
    end if
    state.asm = a.movzx_eax_al(state.asm)
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_BOOL)
    state.asm = a.jmp(state.asm, l_cmp_done)

    state.asm = a.mark(state.asm, l_cmp_fail)
    eid = _next_lid(state)
    l_lhs_not_bytes = "eq_lhs_not_bytes_" + eid
    l_bytes_only = "eq_bytes_only_" + eid
    l_call_val = "eq_call_val_" + eid
    l_done_eq = "eq_done_" + eid
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
    state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
    if op == "!=" then
      state.asm = a.inc_r32(state.asm, "eax")
    end if
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_BOOL)
    state.asm = a.jmp(state.asm, l_done_eq)

    state.asm = a.mark(state.asm, l_rhs_enum)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_INT)
    state.asm = a.jcc(state.asm, "e", l_int_enum)
    state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
    if op == "!=" then
      state.asm = a.inc_r32(state.asm, "eax")
    end if
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_BOOL)
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
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.mov_r64_r64(state.asm, "r9", "rax")
    state.asm = a.and_r64_imm(state.asm, "r9", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_lhs_not_bytes)
    state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rax", 0)
    state.asm = a.cmp_r32_imm(state.asm, "r9d", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "ne", l_lhs_not_bytes)

    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.mov_r64_r64(state.asm, "r9", "rax")
    state.asm = a.and_r64_imm(state.asm, "r9", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_bytes_only)
    state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rax", 0)
    state.asm = a.cmp_r32_imm(state.asm, "r9d", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "ne", l_bytes_only)

    state.asm = a.mov_r64_r64(state.asm, "rcx", "r10")
    state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
    state.asm = a.call(state.asm, "fn_bytes_eq")
    if op == "!=" then
      state.asm = a.xor_r64_imm8(state.asm, "rax", 8)
    end if
    state.asm = a.jmp(state.asm, l_done_eq)

    state.asm = a.mark(state.asm, l_lhs_not_bytes)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.mov_r64_r64(state.asm, "r9", "rax")
    state.asm = a.and_r64_imm(state.asm, "r9", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_call_val)
    state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rax", 0)
    state.asm = a.cmp_r32_imm(state.asm, "r9d", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "e", l_bytes_only)

    state.asm = a.mark(state.asm, l_call_val)
    state.asm = a.mov_r64_r64(state.asm, "rcx", "r10")
    state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
    state.asm = a.call(state.asm, "fn_val_eq")
    if op == "!=" then
      state.asm = a.xor_r64_imm8(state.asm, "rax", 8)
    end if
    state.asm = a.jmp(state.asm, l_done_eq)

    state.asm = a.mark(state.asm, l_bytes_only)
    state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
    if op == "!=" then
      state.asm = a.inc_r32(state.asm, "eax")
    end if
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_BOOL)

    state.asm = a.mark(state.asm, l_done_eq)
    state.asm = a.mark(state.asm, l_cmp_done)
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

  if op == "+" then
    lid_add = _next_lid(state)
    l_check_numeric = "add_checknum_" + lid_add
    l_num2_check = "add_checknum2_" + lid_add
    l_float_add = "add_float_" + lid_add
    l_bytes = "add_bytes_" + lid_add
    l_bytes_fail = "add_bytes_fail_" + lid_add
    l_bytes_check2 = "add_bytes_check2_" + lid_add
    l_bytes_after = "add_bytes_after_" + lid_add
    l_add_str = "add_str_" + lid_add
    l_add_done = "add_done_" + lid_add
    l_arrcheck = "add_arrcheck_" + lid_add

    vidv = _next_lid(state)
    l_nvoid = "add_nvoid_" + vidv
    l_isvoid = "add_isvoid_" + vidv
    l_void_lhs = "add_voidlhs_" + vidv
    l_void_rhs = "add_voidrhs_" + vidv

    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_VOID)
    state.asm = a.jcc(state.asm, "e", l_void_lhs)

    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_VOID)
    state.asm = a.jcc(state.asm, "e", l_void_rhs)
    state.asm = a.jmp(state.asm, l_nvoid)

    state.asm = a.mark(state.asm, l_void_lhs)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
    state.asm = a.and_r64_imm(state.asm, "rdx", 7)
    state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_isvoid)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
    state.asm = a.jcc(state.asm, "e", l_nvoid)
    state.asm = a.jmp(state.asm, l_isvoid)

    state.asm = a.mark(state.asm, l_void_rhs)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
    state.asm = a.and_r64_imm(state.asm, "rdx", 7)
    state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_isvoid)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
    state.asm = a.jcc(state.asm, "e", l_nvoid)
    state.asm = a.jmp(state.asm, l_isvoid)

    state.asm = a.mark(state.asm, l_isvoid)
    state = core.emit_dbg_line(state, expr)
    state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot apply '+' to void")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_add_done)
    state.asm = a.mark(state.asm, l_nvoid)

    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_check_numeric)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_check_numeric)

    if rhs_const_int_ok and rhs_const_int == 1 then
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.add_rax_imm8(state.asm, 8)
    else
      if rhs_const_int_ok and rhs_const_int == -1 then
        state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
        state.asm = a.sub_rax_imm8(state.asm, 8)
      else
        if lhs_const_int_ok and lhs_const_int == 1 then
          state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
          state.asm = a.add_rax_imm8(state.asm, 8)
        else
          if lhs_const_int_ok and lhs_const_int == -1 then
            state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
            state.asm = a.sub_rax_imm8(state.asm, 8)
          else
            state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
            state.asm = a.add_r64_r64(state.asm, "rax", "r11")
            state.asm = a.sub_rax_imm8(state.asm, 1)
          end if
        end if
      end if
    end if
    state.asm = a.jmp(state.asm, l_add_done)

    state.asm = a.mark(state.asm, l_check_numeric)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
    state.asm = a.and_r64_imm(state.asm, "rdx", 7)
    state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_INT)
    state.asm = a.jcc(state.asm, "e", l_num2_check)
    state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_FLOAT)
    state.asm = a.jcc(state.asm, "e", l_num2_check)
    state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_arrcheck)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FLOAT)
    state.asm = a.jcc(state.asm, "ne", l_arrcheck)

    state.asm = a.mark(state.asm, l_num2_check)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
    state.asm = a.and_r64_imm(state.asm, "rdx", 7)
    state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_INT)
    state.asm = a.jcc(state.asm, "e", l_float_add)
    state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_FLOAT)
    state.asm = a.jcc(state.asm, "e", l_float_add)
    state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_arrcheck)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FLOAT)
    state.asm = a.jcc(state.asm, "ne", l_arrcheck)

    state.asm = a.mark(state.asm, l_float_add)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state = core.emit_to_double_xmm(state, 0, l_add_str)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state = core.emit_to_double_xmm(state, 1, l_add_str)
    state.asm = a.addsd_xmm_xmm(state.asm, "xmm0", "xmm1")
    state = core.emit_normalize_xmm0_to_value(state)
    state.asm = a.jmp(state.asm, l_add_done)

    state.asm = a.mark(state.asm, l_arrcheck)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_bytes_check2)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "e", l_bytes)

    state.asm = a.mark(state.asm, l_bytes_check2)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_bytes_after)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "e", l_bytes_fail)

    state.asm = a.mark(state.asm, l_bytes_after)
    l_arr_ok1 = "arr_add_ok1_" + lid_add
    l_arr_ok2 = "arr_add_ok2_" + lid_add
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_add_str)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
    state.asm = a.jcc(state.asm, "e", l_arr_ok1)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY_IMM)
    state.asm = a.jcc(state.asm, "ne", l_add_str)

    state.asm = a.mark(state.asm, l_arr_ok1)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_add_str)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
    state.asm = a.jcc(state.asm, "e", l_arr_ok2)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY_IMM)
    state.asm = a.jcc(state.asm, "ne", l_add_str)

    state.asm = a.mark(state.asm, l_arr_ok2)
    state.asm = a.mov_r64_r64(state.asm, "rcx", "r10")
    state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
    state.asm = a.call(state.asm, "fn_add_array")
    state.asm = a.jmp(state.asm, l_add_done)

    state.asm = a.mark(state.asm, l_bytes)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_bytes_fail)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "ne", l_bytes_fail)

    state.asm = a.mov_r64_r64(state.asm, "rcx", "r10")
    state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
    state.asm = a.call(state.asm, "fn_add_bytes")
    state.asm = a.jmp(state.asm, l_add_done)

    state.asm = a.mark(state.asm, l_bytes_fail)
    state = core.emit_dbg_line(state, expr)
    state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot add bytes with non-bytes")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_add_done)

    state.asm = a.mark(state.asm, l_add_str)
    state.asm = a.mov_r64_r64(state.asm, "rcx", "r10")
    state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
    state.asm = a.call(state.asm, "fn_add_string")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_add_done)

    state.asm = a.mark(state.asm, l_add_done)
    return state
  end if

  if op == "-" or op == "*" or op == "%" then
    lid_arith = _next_lid(state)
    l_arith_float = "arith_float_" + lid_arith
    l_arith_fail = "arith_fail_" + lid_arith
    l_arith_done = "arith_done_" + lid_arith

    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_arith_float)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_arith_float)

    if op == "-" then
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      if rhs_const_int_ok and rhs_const_int == 1 then
        state.asm = a.sub_rax_imm8(state.asm, 8)
      else
        if rhs_const_int_ok and rhs_const_int == -1 then
          state.asm = a.add_rax_imm8(state.asm, 8)
        else
          state.asm = a.sub_r64_r64(state.asm, "rax", "r11")
          state.asm = a.add_rax_imm8(state.asm, 1)
        end if
      end if
      state.asm = a.jmp(state.asm, l_arith_done)
    end if

    if op == "*" then
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
      state.asm = a.sar_r64_imm8(state.asm, "r11", 3)
      state.asm = a.imul_r64_r64(state.asm, "rax", "r11")
      state.asm = a.shl_rax_imm8(state.asm, 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
      state.asm = a.jmp(state.asm, l_arith_done)
    end if

    if op == "%" then
      l_mod_ok = "mod_ok_" + lid_arith
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
      state.asm = a.sar_r64_imm8(state.asm, "r11", 3)
      state.asm = a.test_r64_r64(state.asm, "r11", "r11")
      state.asm = a.jcc(state.asm, "e", l_arith_fail)
      state.asm = a.cqo(state.asm)
      state.asm = a.idiv_r64(state.asm, "r11")
      state.asm = a.test_r64_r64(state.asm, "rdx", "rdx")
      state.asm = a.jcc(state.asm, "e", l_mod_ok)
      state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")
      state.asm = a.xor_r64_r64(state.asm, "rax", "r11")
      state.asm = a.test_r64_r64(state.asm, "rax", "rax")
      state.asm = a.jcc(state.asm, "ge", l_mod_ok)
      state.asm = a.add_r64_r64(state.asm, "rdx", "r11")
      state.asm = a.mark(state.asm, l_mod_ok)
      state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")
      state.asm = a.shl_rax_imm8(state.asm, 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
      state.asm = a.jmp(state.asm, l_arith_done)
    end if

    state.asm = a.mark(state.asm, l_arith_float)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state = core.emit_to_double_xmm(state, 0, l_arith_fail)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state = core.emit_to_double_xmm(state, 1, l_arith_fail)

    if op == "-" then
      state.asm = a.subsd_xmm_xmm(state.asm, "xmm0", "xmm1")
    else
      if op == "*" then
        state.asm = a.mulsd_xmm_xmm(state.asm, "xmm0", "xmm1")
      else
        state.asm = a.xorpd_xmm_xmm(state.asm, "xmm2", "xmm2")
        state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm1", "xmm2")
        state.asm = a.jcc(state.asm, "e", l_arith_fail)
        state.asm = a.movapd_xmm_xmm(state.asm, "xmm3", "xmm0")
        state.asm = a.divsd_xmm_xmm(state.asm, "xmm0", "xmm1")
        state.asm = a.roundsd_xmm_xmm_imm8(state.asm, "xmm2", "xmm0", 1)
        state.asm = a.mulsd_xmm_xmm(state.asm, "xmm2", "xmm1")
        state.asm = a.subsd_xmm_xmm(state.asm, "xmm3", "xmm2")
        state.asm = a.movapd_xmm_xmm(state.asm, "xmm0", "xmm3")
      end if
    end if

    state = core.emit_normalize_xmm0_to_value(state)
    state.asm = a.jmp(state.asm, l_arith_done)

    state.asm = a.mark(state.asm, l_arith_fail)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    state.asm = a.mark(state.asm, l_arith_done)
    return state
  end if

  if op == "<" or op == ">" or op == "<=" or op == ">=" then
    l_cmp_float = "bin_cmp_float_" + lid
    l_cmp_fail = "bin_cmp_fail_" + lid

    // int fast-path
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.and_r64_imm(state.asm, "rax", 7)
    state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_cmp_float)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.and_r64_imm(state.asm, "rax", 7)
    state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_cmp_float)

    state.asm = a.cmp_r64_r64(state.asm, "r10", "r11")
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

  if op == "&" or op == "|" or op == "^" then
    lid_bit = _next_lid(state)
    l_bit_fail = "bit_fail_" + lid_bit
    l_bit_done = "bit_done_" + lid_bit

    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_bit_fail)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_bit_fail)

    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    if op == "&" then
      state.asm = a.and_r64_r64(state.asm, "rax", "r11")
    else
      if op == "|" then
        state.asm = a.or_r64_r64(state.asm, "rax", "r11")
      else
        state.asm = a.xor_r64_r64(state.asm, "rax", "r11")
        state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
      end if
    end if
    state.asm = a.jmp(state.asm, l_bit_done)

    state.asm = a.mark(state.asm, l_bit_fail)
    lid_void = _next_lid(state)
    l_bit_nvoid = "bit_nvoid_" + lid_void
    l_bit_isvoid = "bit_isvoid_" + lid_void
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_VOID)
    state.asm = a.jcc(state.asm, "e", l_bit_isvoid)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_VOID)
    state.asm = a.jcc(state.asm, "ne", l_bit_nvoid)
    state.asm = a.mark(state.asm, l_bit_isvoid)
    state = core.emit_dbg_line(state, expr)
    state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot apply '" + op + "' to void")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_bit_done)
    state.asm = a.mark(state.asm, l_bit_nvoid)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    state.asm = a.mark(state.asm, l_bit_done)
    return state
  end if

  if op == "<<" or op == ">>" then
    lid_sh = _next_lid(state)
    l_sh_fail = "sh_fail_" + lid_sh
    l_sh_done = "sh_done_" + lid_sh

    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_sh_fail)

    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_sh_fail)

    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.mov_r64_r64(state.asm, "rcx", "r11")
    state.asm = a.sar_r64_imm8(state.asm, "rcx", 3)
    state.asm = a.cmp_r64_imm(state.asm, "rcx", 0)
    state.asm = a.jcc(state.asm, "l", l_sh_fail)
    state.asm = a.and_r64_imm(state.asm, "rcx", 63)

    if op == "<<" then
      state.asm = a.shl_r64_cl(state.asm, "rax")
    else
      state.asm = a.sar_r64_cl(state.asm, "rax")
    end if

    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
    state.asm = a.jmp(state.asm, l_sh_done)

    state.asm = a.mark(state.asm, l_sh_fail)
    lid_sh_void = _next_lid(state)
    l_sh_nvoid = "sh_nvoid_" + lid_sh_void
    l_sh_isvoid = "sh_isvoid_" + lid_sh_void
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_VOID)
    state.asm = a.jcc(state.asm, "e", l_sh_isvoid)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_VOID)
    state.asm = a.jcc(state.asm, "ne", l_sh_nvoid)
    state.asm = a.mark(state.asm, l_sh_isvoid)
    state = core.emit_dbg_line(state, expr)
    state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot apply '" + op + "' to void")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_sh_done)
    state.asm = a.mark(state.asm, l_sh_nvoid)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    state.asm = a.mark(state.asm, l_sh_done)
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
    state.asm = a.jmp(state.asm, l_fail)
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
  if op == "&" or op == "|" or op == "^" then
    lid_bit = _next_lid(state)
    l_bit_nvoid = "bit_nvoid_" + lid_bit
    l_bit_isvoid = "bit_isvoid_" + lid_bit
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_VOID)
    state.asm = a.jcc(state.asm, "e", l_bit_isvoid)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_VOID)
    state.asm = a.jcc(state.asm, "ne", l_bit_nvoid)
    state.asm = a.mark(state.asm, l_bit_isvoid)
    state = core.emit_dbg_line(state, expr)
    state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot apply '" + op + "' to void")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_done)
    state.asm = a.mark(state.asm, l_bit_nvoid)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    state.asm = a.jmp(state.asm, l_done)
  end if
  if op == "<<" or op == ">>" then
    lid_shf = _next_lid(state)
    l_sh_nvoid = "sh_nvoid_" + lid_shf
    l_sh_isvoid = "sh_isvoid_" + lid_shf
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_VOID)
    state.asm = a.jcc(state.asm, "e", l_sh_isvoid)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_VOID)
    state.asm = a.jcc(state.asm, "ne", l_sh_nvoid)
    state.asm = a.mark(state.asm, l_sh_isvoid)
    state = core.emit_dbg_line(state, expr)
    state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot apply '" + op + "' to void")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_done)
    state.asm = a.mark(state.asm, l_sh_nvoid)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    state.asm = a.jmp(state.asm, l_done)
  end if
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
    l_arr_ok1 = "arr_add_ok1_" + lid
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
    state.asm = a.jcc(state.asm, "e", l_arr_ok1)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY_IMM)
    state.asm = a.jcc(state.asm, "ne", l_add_str)
    state.asm = a.mark(state.asm, l_arr_ok1)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_add_str)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
    l_arr_ok2 = "arr_add_ok2_" + lid
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
    state.asm = a.jcc(state.asm, "e", l_arr_ok2)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY_IMM)
    state.asm = a.jcc(state.asm, "ne", l_add_str)
    state.asm = a.mark(state.asm, l_arr_ok2)
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
end function

function _emit_expr_call(state, expr)
  // Keep callsite line current so runtime-created errors carry correct origin.
  state = core.emit_dbg_line(state, expr)
  state.call_total_count = state.call_total_count + 1
  cal = try(expr.callee)
  if typeof(cal) != "struct" then cal = try(expr.func) end if
  args = try(expr.args)
  if typeof(args) != "array" then args = [] end if
  call_args = _filter_expr_list_separator_artifacts(args)
  nargs = len(call_args)
  member_runtime = false
  compiletime_callee_qn = ""

  pre_raw = ""
  cal_kind = ""
  if typeof(cal) == "struct" then cal_kind = _coerce_name(try(cal.node_kind)) end if
  if typeof(cal) == "struct" and cal_kind == "Var" and typeof(try(cal.name)) == "string" then
    pre_raw = try(cal.name)
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
    compiletime_callee_qn = _qname_of(state, cal)
    cal_kind = _coerce_name(try(cal.node_kind))
    if cal_kind == "Member" then
      member_runtime = compiletime_callee_qn == ""
      callee = compiletime_callee_qn
    end if
    if cal_kind == "Var" then
      cal_name_try = try(cal.name)
      if typeof(cal_name_try) == "string" then raw_name = cal_name_try end if
      if raw_name == "try" or raw_name == "error" or raw_name == "bytes" or raw_name == "byteBuffer" then
        callee = raw_name
      else
        if compiletime_callee_qn != "" then
          callee = compiletime_callee_qn
        else
          callee = _qualify_identifier(state, raw_name)
        end if
      end if
    end if
  end if
  if callee == "" and raw_name != "" then callee = raw_name end if

  math_callee = callee
  if math_callee == "" then math_callee = raw_name end if
  if nargs == 1 and (math_callee == "std.math.floor" or math_callee == "std.math.ceil" or math_callee == "std.math.trunc" or math_callee == "std.math.round") then
    rr_math = _emit_std_math_roundlike_intrinsic(state, math_callee, call_args[0])
    if typeof(rr_math) == "array" and len(rr_math) >= 2 and rr_math[1] == true then
      return rr_math[0]
    end if
    if typeof(rr_math) == "array" and len(rr_math) >= 1 then
      state = rr_math[0]
    end if
  end if

  // OOP-style struct instance call: obj.method(args...)
  // Compile as dynamic dispatch on receiver.struct_id -> direct call of hoisted method body.
  if typeof(cal) == "struct" and _coerce_name(try(cal.node_kind)) == "Member" and member_runtime then
    mname_dyn = _coerce_name(try(cal.name))
    if mname_dyn == "" then mname_dyn = _coerce_name(try(cal.field)) end if
    tgt_dyn = try(cal.target)
    obj_dyn = try(cal.obj)
    if typeof(tgt_dyn) != "struct" then tgt_dyn = obj_dyn end if

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
        if sqn_dyn == "" then continue end if
        if typeof(md_dyn) != "array" and typeof(md_dyn) != "struct" then continue end if
        if typeof(md_dyn) == "array" and len(md_dyn) <= 0 then continue end if

        fnq_dyn = _method_map_get(md_dyn, mname_dyn)
        if fnq_dyn == "" then continue end if
        fndef_dyn = _user_function_get(state, fnq_dyn)
        if typeof(fndef_dyn) != "struct" then continue end if
        exp_dyn = 0
        if typeof(fndef_dyn.params) == "array" then exp_dyn = len(fndef_dyn.params) end if
        if exp_dyn != total_dyn then continue end if

        sid_dyn = _state_struct_id_get(state, sqn_dyn, -1)
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
        state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 4)

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

  early_call = _emit_expr_call_early_builtins(state, callee, raw_name, call_args, nargs)
  if typeof(early_call) == "array" and len(early_call) >= 2 then
    state = early_call[0]
    if early_call[1] == true then return state end if
  end if

  return _emit_expr_call_generic(state, cal, callee, raw_name, call_args, nargs, member_runtime)
end function

function _emit_expr_call_early_builtins(state, callee, raw_name, call_args, nargs)
  // Builtin toNumber(x)
  if (callee == "toNumber" or raw_name == "toNumber") and nargs == 1 then
    state = cg_emit_expr(state, call_args[0])
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, "fn_toNumber")
    return [state, true]
  end if

  // Builtin toFloat(x): parse/coerce numerics but preserve exact
  // integer-valued floats as floats instead of normalizing them to TAG_INT.
  if (callee == "toFloat" or raw_name == "toFloat") and nargs == 1 then
    state = cg_emit_expr(state, call_args[0])
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, "fn_toFloat")
    return [state, true]
  end if

  // Builtin typeof/typeName must handle type identifiers without evaluating them as variables.
  if (callee == "typeof" or raw_name == "typeof") and nargs == 1 then
    arg0 = call_args[0]
    known_ty = _opt_try_known_type_label(state, arg0, false)
    if known_ty != "" then
      state.asm = a.lea_rax_rip(state.asm, known_ty)
      return [state, true]
    end if
    arg_name = _expr_to_qualname(state, arg0)
    if arg_name != "" then arg_name = _apply_import_alias(state, arg_name) end if
    if arg_name != "" then
      flds0 = _state_struct_fields_get(state, arg_name)
      if typeof(flds0) == "array" then
        state.asm = a.lea_rax_rip(state.asm, "obj_type_struct")
        return [state, true]
      end if
      if _state_enum_id_get(state, arg_name, -1) >= 0 then
        state.asm = a.lea_rax_rip(state.asm, "obj_type_enum")
        return [state, true]
      end if
      if s.contains(arg_name, ".") then
        ps_t = s.split(arg_name, ".")
        if typeof(ps_t) == "array" and len(ps_t) >= 2 then
          v_t = _coerce_name(ps_t[len(ps_t) - 1])
          bp_t = slice(ps_t, 0, len(ps_t) - 1)
          if typeof(bp_t) != "array" then bp_t = [] end if
          b_t = _apply_import_alias(state, s.join(bp_t, "."))
          vars_t = _state_enum_variants_get(state, b_t)
          if _state_enum_id_get(state, b_t, -1) >= 0 and typeof(vars_t) == "array" and _arr_has_str(vars_t, v_t) then
            state.asm = a.lea_rax_rip(state.asm, "obj_type_enum")
            return [state, true]
          end if
        end if
      end if
    end if
    state = cg_emit_expr(state, arg0)
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, "fn_typeof")
    return [state, true]
  end if

  if (callee == "typeName" or raw_name == "typeName") and nargs == 1 then
    arg1 = call_args[0]
    known_tn = _opt_try_known_type_label(state, arg1, true)
    if known_tn != "" then
      state.asm = a.lea_rax_rip(state.asm, known_tn)
      return [state, true]
    end if
    argn = _expr_to_qualname(state, arg1)
    if argn != "" then argn = _apply_import_alias(state, argn) end if

    if argn != "" then
      flds1 = _state_struct_fields_get(state, argn)
      if typeof(flds1) == "array" then
        lbl_s = _strpair_get(state.typename_struct_by_qname, argn)
        if lbl_s != "" then
          state.asm = a.lea_rax_rip(state.asm, lbl_s)
        else
          state.asm = a.lea_rax_rip(state.asm, "obj_type_struct")
        end if
        return [state, true]
      end if

      if _state_enum_id_get(state, argn, -1) >= 0 then
        lbl_e = _strpair_get(state.typename_enum_by_qname, argn)
        if lbl_e != "" then
          state.asm = a.lea_rax_rip(state.asm, lbl_e)
        else
          state.asm = a.lea_rax_rip(state.asm, "obj_type_enum")
        end if
        return [state, true]
      end if

      if s.contains(argn, ".") then
        ps_n = s.split(argn, ".")
        if typeof(ps_n) == "array" and len(ps_n) >= 2 then
          vn_n = _coerce_name(ps_n[len(ps_n) - 1])
          bp_n = slice(ps_n, 0, len(ps_n) - 1)
          if typeof(bp_n) != "array" then bp_n = [] end if
          b_n = _apply_import_alias(state, s.join(bp_n, "."))
          vars_n = _state_enum_variants_get(state, b_n)
          if _state_enum_id_get(state, b_n, -1) >= 0 and typeof(vars_n) == "array" and _arr_has_str(vars_n, vn_n) then
            lbl_be = _strpair_get(state.typename_enum_by_qname, b_n)
            if lbl_be != "" then
              state.asm = a.lea_rax_rip(state.asm, lbl_be)
            else
              state.asm = a.lea_rax_rip(state.asm, "obj_type_enum")
            end if
            return [state, true]
          end if
        end if
      end if
    end if

    state = cg_emit_expr(state, arg1)
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, "fn_typeName")
    return [state, true]
  end if

  if (callee == "input" or raw_name == "input") then
    if nargs == 1 then
      state = cg_emit_expr(state, call_args[0])
      lid_inp = _next_lid(state)
      l_inp_done = "in_prompt_done_" + lid_inp
      state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
      state.asm = a.and_r64_imm(state.asm, "r10", 7)
      state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
      state.asm = a.jcc(state.asm, "ne", l_inp_done)
      state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
      state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
      state.asm = a.jcc(state.asm, "ne", l_inp_done)
      state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rax", 4)
      state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "rax", 8)
      state = core.emit_writefile_ptr_len(state)
      state.asm = a.mark(state.asm, l_inp_done)
      state.asm = a.call(state.asm, "fn_input")
      return [state, true]
    end if
    if nargs == 0 then
      state.asm = a.call(state.asm, "fn_input")
      return [state, true]
    end if
    state.diagnostics = state.diagnostics +["input() expects 0 or 1 arguments"]
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return [state, true]
  end if

  // Builtin len(x)
  if (callee == "len" or raw_name == "len") and nargs == 1 then
    arg_len = call_args[0]
    const_len = -1
    cv_len = _opt_try_const_value(state, arg_len)
    if typeof(cv_len) == "struct" and cv_len.ok then
      if typeof(cv_len.value) == "string" then
        const_len = len(cv_len.value)
      else
        const_len = _opt_try_pure_const_array_len(state, arg_len)
      end if
    else
      const_len = _opt_try_pure_const_array_len(state, arg_len)
    end if
    if const_len >= 0 then
      state.asm = a.mov_rax_imm64(state.asm, t.enc_int(const_len))
      return [state, true]
    end if

    state = cg_emit_expr(state, arg_len)

    lid_len_early = _next_lid(state)
    l_len_ok_early = "len_ok_" + lid_len_early
    l_len_done_early = "len_done_" + lid_len_early
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_VOID)
    state.asm = a.jcc(state.asm, "ne", l_len_ok_early)
    state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot apply 'len' to void")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_len_done_early)

    state.asm = a.mark(state.asm, l_len_ok_early)
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, "fn_builtin_len")
    state.asm = a.mark(state.asm, l_len_done_early)
    return [state, true]
  end if

  // Builtin decode(bytes[, encoding]) -> string
  if (callee == "decode" or raw_name == "decode") then
    if nargs != 1 and nargs != 2 then
      state.diagnostics = state.diagnostics +["decode() expects 1 or 2 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if

    tmp_dec = core.alloc_expr_temps(state, 8 + ((nargs - 1) * 8))
    tmp_dec_ok = typeof(tmp_dec) == "int" and tmp_dec > 0
    if not tmp_dec_ok then tmp_dec = 0x2F0 end if

    state = cg_emit_expr(state, call_args[0])
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_dec, "rax")
    if nargs == 2 then
      state = cg_emit_expr(state, call_args[1])
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_dec + 8, "rax")
    end if

    lid_dec = _next_lid(state)
    l_dec_fail = "decode_fail_" + lid_dec
    l_dec_done = "decode_done_" + lid_dec

    if nargs == 2 then
      state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tmp_dec + 8)
      state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
      state.asm = a.and_r64_imm(state.asm, "r10", 7)
      state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
      state.asm = a.jcc(state.asm, "ne", l_dec_fail)
      state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
      state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
      state.asm = a.jcc(state.asm, "ne", l_dec_fail)
    end if

    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tmp_dec)
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, "fn_decode")
    state.asm = a.jmp(state.asm, l_dec_done)

    state.asm = a.mark(state.asm, l_dec_fail)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    state.asm = a.mark(state.asm, l_dec_done)
    if tmp_dec_ok then state = core.free_expr_temps(state, 8 + ((nargs - 1) * 8)) end if
    return [state, true]
  end if

  if (callee == "hex" or raw_name == "hex") and nargs == 1 then
    state = cg_emit_expr(state, call_args[0])
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, "fn_hex")
    return [state, true]
  end if

  if (callee == "fromHex" or raw_name == "fromHex") and nargs == 1 then
    state = cg_emit_expr(state, call_args[0])
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, "fn_fromHex")
    return [state, true]
  end if

  if (callee == "slice" or raw_name == "slice") then
    if nargs != 3 then
      state.diagnostics = state.diagnostics +["slice() expects exactly 3 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if

    tmp_slice = core.alloc_expr_temps(state, 24)
    tmp_slice_ok = typeof(tmp_slice) == "int" and tmp_slice > 0
    if not tmp_slice_ok then tmp_slice = 0x2F0 end if

    state = cg_emit_expr(state, call_args[0])
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_slice, "rax")
    state = cg_emit_expr(state, call_args[1])
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_slice + 8, "rax")
    state = cg_emit_expr(state, call_args[2])
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_slice + 16, "rax")

    state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", tmp_slice)
    state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", tmp_slice + 8)
    state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", tmp_slice + 16)
    state.asm = a.call(state.asm, "fn_slice")

    if tmp_slice_ok then state = core.free_expr_temps(state, 24) end if
    return [state, true]
  end if

  if callee == "array" then
    if nargs != 1 and nargs != 2 then
      state.diagnostics = state.diagnostics +["array() expects 1 or 2 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if

    tmp_arr_bytes = 8
    if nargs == 2 then tmp_arr_bytes = 16 end if
    tmp_arr = core.alloc_expr_temps(state, tmp_arr_bytes)
    tmp_arr_ok = typeof(tmp_arr) == "int" and tmp_arr > 0
    if not tmp_arr_ok then tmp_arr = 0x300 end if

    state = cg_emit_expr(state, call_args[0])
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_arr, "rax")

    if nargs == 2 then
      state = cg_emit_expr(state, call_args[1])
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_arr + 8, "rax")
    end if

    state = mem.ensure_gc_data(state)

    lid_arr = _next_lid(state)
    l_fail_arr = "array_init_fail_" + lid_arr
    l_done_arr = "array_init_done_" + lid_arr

    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tmp_arr)
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_fail_arr)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
    state.asm = a.jcc(state.asm, "l", l_fail_arr)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
    state.asm = a.jcc(state.asm, "g", l_fail_arr)

    if nargs == 2 then
      state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tmp_arr + 8)
      state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp0")
    end if

    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tmp_arr)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.shl_r64_imm8(state.asm, "rcx", 3)
    state.asm = a.add_r64_imm(state.asm, "rcx", 8)
    state.asm = a.call(state.asm, "fn_alloc")

    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    if nargs == 2 then
      lidt_arr = _next_lid(state)
      l_arr_imm = "array_init_imm_" + lidt_arr
      l_arr_type_done = "array_init_type_done_" + lidt_arr
      state.asm = a.mov_rax_rip_qword(state.asm, "gc_tmp0")
      state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
      state.asm = a.and_r64_imm(state.asm, "r10", 7)
      state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
      state.asm = a.jcc(state.asm, "ne", l_arr_imm)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_ARRAY, false)
      state.asm = a.jmp(state.asm, l_arr_type_done)
      state.asm = a.mark(state.asm, l_arr_imm)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_ARRAY_IMM, false)
      state.asm = a.mark(state.asm, l_arr_type_done)
    else
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_ARRAY_IMM, false)
    end if

    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tmp_arr)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.mov_r32_r32(state.asm, "edx", "eax")
    state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "edx")

    if nargs == 2 then
      state.asm = a.mov_rdx_rip_qword(state.asm, "gc_tmp0")
    else
      state.asm = a.mov_r64_imm64(state.asm, "rdx", t.enc_void())
    end if

    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_arr, "r11")
    state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r11", 8)
    state.asm = a.mov_r64_r64(state.asm, "r8", "rdx")
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 4)
    state.asm = a.call(state.asm, "fn_fill_qwords")
    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", tmp_arr)

    if nargs == 2 then
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp0")
    end if

    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.jmp(state.asm, l_done_arr)

    state.asm = a.mark(state.asm, l_fail_arr)
    if nargs == 2 then
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp0")
    end if
    state = _emit_make_error_const(state, c.ERR_ARRAY_INIT_SIZE, "array() size must be an int in range 0..2147483647")
    state = _emit_auto_errprop(state)

    state.asm = a.mark(state.asm, l_done_arr)
    if tmp_arr_ok then
      state = core.free_expr_temps(state, tmp_arr_bytes)
    end if
    return [state, true]
  end if

  if (callee == "copyBytes" or raw_name == "copyBytes") then
    if nargs != 5 then
      state.diagnostics = state.diagnostics +["copyBytes() expects exactly 5 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if

    tmp_cb = core.alloc_expr_temps(state, 40)
    tmp_cb_ok = typeof(tmp_cb) == "int" and tmp_cb > 0
    if not tmp_cb_ok then tmp_cb = 0x300 end if

    for cbi = 0 to nargs - 1
      state = cg_emit_expr(state, call_args[cbi])
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_cb + cbi * 8, "rax")
    end for

    lid_cb = _next_lid(state)
    l_cb_done = "copybytes_done_" + lid_cb
    l_cb_fail = "copybytes_fail_" + lid_cb
    l_cb_min_dst = "copybytes_min_dst_" + lid_cb
    l_cb_min_src = "copybytes_min_src_" + lid_cb

    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", tmp_cb)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_cb_fail)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "ne", l_cb_fail)

    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tmp_cb + 8)
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_cb_fail)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
    state.asm = a.jcc(state.asm, "l", l_cb_fail)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
    state.asm = a.jcc(state.asm, "g", l_cb_fail)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_cb + 8, "rax")

    state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", tmp_cb + 16)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.mov_r64_r64(state.asm, "r9", "rax")
    state.asm = a.and_r64_imm(state.asm, "r9", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_cb_fail)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r10", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "ne", l_cb_fail)

    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tmp_cb + 24)
    state.asm = a.mov_r64_r64(state.asm, "r9", "rax")
    state.asm = a.and_r64_imm(state.asm, "r9", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_cb_fail)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
    state.asm = a.jcc(state.asm, "l", l_cb_fail)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
    state.asm = a.jcc(state.asm, "g", l_cb_fail)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_cb + 24, "rax")

    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tmp_cb + 32)
    state.asm = a.mov_r64_r64(state.asm, "r9", "rax")
    state.asm = a.and_r64_imm(state.asm, "r9", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_cb_fail)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
    state.asm = a.jcc(state.asm, "l", l_cb_fail)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
    state.asm = a.jcc(state.asm, "g", l_cb_fail)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_cb + 32, "rax")

    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", tmp_cb)
    state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", tmp_cb + 16)

    state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "r11", 4)
    state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rsp", tmp_cb + 8)
    state.asm = a.cmp_r32_r32(state.asm, "eax", "r9d")
    state.asm = a.jcc(state.asm, "ge", l_cb_done)
    state.asm = a.sub_r32_r32(state.asm, "r9d", "eax")

    state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "r10", 4)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rsp", tmp_cb + 24)
    state.asm = a.cmp_r32_r32(state.asm, "edx", "r8d")
    state.asm = a.jcc(state.asm, "ge", l_cb_done)
    state.asm = a.sub_r32_r32(state.asm, "r8d", "edx")

    state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rsp", tmp_cb + 32)
    state.asm = a.cmp_r32_r32(state.asm, "ecx", "r9d")
    state.asm = a.jcc(state.asm, "le", l_cb_min_dst)
    state.asm = a.mov_r32_r32(state.asm, "ecx", "r9d")
    state.asm = a.mark(state.asm, l_cb_min_dst)
    state.asm = a.cmp_r32_r32(state.asm, "ecx", "r8d")
    state.asm = a.jcc(state.asm, "le", l_cb_min_src)
    state.asm = a.mov_r32_r32(state.asm, "ecx", "r8d")
    state.asm = a.mark(state.asm, l_cb_min_src)
    state.asm = a.test_r32_r32(state.asm, "ecx", "ecx")
    state.asm = a.jcc(state.asm, "le", l_cb_done)

    state.asm = a.mov_r32_r32(state.asm, "r9d", "ecx")
    state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r11", 8)
    state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rsp", tmp_cb + 8)
    state.asm = a.add_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r10", 8)
    state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rsp", tmp_cb + 24)
    state.asm = a.add_r64_r64(state.asm, "rdx", "rax")
    state.asm = a.mov_r32_r32(state.asm, "r8d", "r9d")
    state.asm = a.call(state.asm, "fn_copy_bytes")
    state.asm = a.jmp(state.asm, l_cb_done)

    state.asm = a.mark(state.asm, l_cb_fail)
    state.asm = a.mark(state.asm, l_cb_done)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    if tmp_cb_ok then state = core.free_expr_temps(state, 40) end if
    return [state, true]
  end if

  if (callee == "fillBytes" or raw_name == "fillBytes") then
    if nargs != 4 then
      state.diagnostics = state.diagnostics +["fillBytes() expects exactly 4 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if

    tmp_fb = core.alloc_expr_temps(state, 32)
    tmp_fb_ok = typeof(tmp_fb) == "int" and tmp_fb > 0
    if not tmp_fb_ok then tmp_fb = 0x300 end if

    for fbi = 0 to nargs - 1
      state = cg_emit_expr(state, call_args[fbi])
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_fb + fbi * 8, "rax")
    end for

    lid_fb = _next_lid(state)
    l_fb_done = "fillbytes_done_" + lid_fb
    l_fb_fail = "fillbytes_fail_" + lid_fb
    l_fb_len_ok = "fillbytes_len_ok_" + lid_fb

    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", tmp_fb)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_fb_fail)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "ne", l_fb_fail)

    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tmp_fb + 8)
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_fb_fail)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
    state.asm = a.jcc(state.asm, "l", l_fb_fail)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
    state.asm = a.jcc(state.asm, "g", l_fb_fail)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_fb + 8, "rax")

    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tmp_fb + 16)
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_fb_fail)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
    state.asm = a.jcc(state.asm, "l", l_fb_fail)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
    state.asm = a.jcc(state.asm, "g", l_fb_fail)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_fb + 16, "rax")

    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tmp_fb + 24)
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_fb_fail)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
    state.asm = a.jcc(state.asm, "l", l_fb_fail)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 255)
    state.asm = a.jcc(state.asm, "g", l_fb_fail)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_fb + 24, "rax")

    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", tmp_fb)
    state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "r11", 4)
    state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rsp", tmp_fb + 8)
    state.asm = a.cmp_r32_r32(state.asm, "eax", "r9d")
    state.asm = a.jcc(state.asm, "ge", l_fb_done)
    state.asm = a.sub_r32_r32(state.asm, "r9d", "eax")

    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rsp", tmp_fb + 16)
    state.asm = a.cmp_r32_r32(state.asm, "edx", "r9d")
    state.asm = a.jcc(state.asm, "le", l_fb_len_ok)
    state.asm = a.mov_r32_r32(state.asm, "edx", "r9d")
    state.asm = a.mark(state.asm, l_fb_len_ok)
    state.asm = a.test_r32_r32(state.asm, "edx", "edx")
    state.asm = a.jcc(state.asm, "le", l_fb_done)

    state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r11", 8)
    state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rsp", tmp_fb + 8)
    state.asm = a.add_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rsp", tmp_fb + 24)
    state.asm = a.call(state.asm, "fn_fill_bytes")
    state.asm = a.jmp(state.asm, l_fb_done)

    state.asm = a.mark(state.asm, l_fb_fail)
    state.asm = a.mark(state.asm, l_fb_done)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    if tmp_fb_ok then state = core.free_expr_temps(state, 32) end if
    return [state, true]
  end if

  if callee == "bytes" or callee == "byteBuffer" then
    if nargs == 0 then
      state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
      state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
      state.asm = a.call(state.asm, "fn_bytes_alloc")
      return [state, true]
    end if

    if nargs == 2 then
      tmp_b2 = core.alloc_expr_temps(state, 16)
      tmp_b2_ok = typeof(tmp_b2) == "int" and tmp_b2 > 0
      if not tmp_b2_ok then tmp_b2 = 0x300 end if

      state = cg_emit_expr(state, call_args[0])
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_b2, "rax")
      state = cg_emit_expr(state, call_args[1])
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_b2 + 8, "rax")

      lid_b2 = _next_lid(state)
      l_fail_b2 = "bytes_fail_" + lid_b2
      l_done_b2 = "bytes_done_" + lid_b2

      state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tmp_b2)
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

      state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tmp_b2 + 8)
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
      if tmp_b2_ok then state = core.free_expr_temps(state, 16) end if
      return [state, true]
    end if

    if nargs == 1 then
      tmp_b1 = core.alloc_expr_temps(state, 16)
      tmp_b1_ok = typeof(tmp_b1) == "int" and tmp_b1 > 0
      if not tmp_b1_ok then tmp_b1 = 0x300 end if

      state = cg_emit_expr(state, call_args[0])
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_b1, "rax")

      lid_b1 = _next_lid(state)
      l_fail_b1 = "bytes1_fail_" + lid_b1
      l_done_b1 = "bytes1_done_" + lid_b1
      l_int_b1 = "bytes1_int_" + lid_b1
      l_ptr_b1 = "bytes1_ptr_" + lid_b1
      l_str_b1 = "bytes1_str_" + lid_b1
      l_bcopy_b1 = "bytes1_bcopy_" + lid_b1
      l_arr_b1 = "bytes1_arr_" + lid_b1

      state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tmp_b1)
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
      state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY_IMM)
      state.asm = a.jcc(state.asm, "e", l_arr_b1)
      state.asm = a.jmp(state.asm, l_fail_b1)

      state.asm = a.mark(state.asm, l_str_b1)
      state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rax", 4)
      state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
      state.asm = a.call(state.asm, "fn_bytes_alloc")
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_b1 + 8, "rax")
      state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", tmp_b1)
      state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "r11", 4)
      state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", tmp_b1 + 8)
      state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r10", 8)
      state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r11", 8)
      state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "r11", 4)
      state.asm = a.call(state.asm, "fn_copy_bytes")
      state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tmp_b1 + 8)
      state.asm = a.jmp(state.asm, l_done_b1)

      state.asm = a.mark(state.asm, l_arr_b1)
      state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rax", 4)
      state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
      state.asm = a.call(state.asm, "fn_bytes_alloc")
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_b1 + 8, "rax")
      state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", tmp_b1)
      state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", tmp_b1 + 8)
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
      state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tmp_b1 + 8)
      state.asm = a.jmp(state.asm, l_done_b1)

      state.asm = a.mark(state.asm, l_bcopy_b1)
      state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rax", 4)
      state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
      state.asm = a.call(state.asm, "fn_bytes_alloc")
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_b1 + 8, "rax")
      state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", tmp_b1)
      state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "r11", 4)
      state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", tmp_b1 + 8)
      state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r10", 8)
      state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r11", 8)
      state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "r11", 4)
      state.asm = a.call(state.asm, "fn_copy_bytes")
      state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tmp_b1 + 8)
      state.asm = a.jmp(state.asm, l_done_b1)

      state.asm = a.mark(state.asm, l_fail_b1)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      state.asm = a.mark(state.asm, l_done_b1)
      if tmp_b1_ok then state = core.free_expr_temps(state, 16) end if
      return [state, true]
    end if

    state.diagnostics = state.diagnostics +["bytes()/byteBuffer() expects 0, 1 or 2 arguments"]
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return [state, true]
  end if

  if (callee == "gc_set_limit" or raw_name == "gc_set_limit") then
    if nargs != 1 then
      state.diagnostics = state.diagnostics +["gc_set_limit() expects exactly 1 argument"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    state = cg_emit_expr(state, call_args[0])
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.mov_r32_imm32(state.asm, "r10d", 1)
    state.asm = a.call(state.asm, "fn_builtin_gc_set_limit")
    return [state, true]
  end if

  if callee == "error" then
    if nargs != 2 then
      state.diagnostics = state.diagnostics +["Struct error expects 2 args, got " + nargs]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if

    state.asm = a.mov_rcx_imm32(state.asm, 48)
    state.asm = a.call(state.asm, "fn_alloc")

    base_err = core.alloc_expr_temps(state, 8)
    base_err_ok = typeof(base_err) == "int" and base_err > 0
    if not base_err_ok then base_err = 0x2F8 end if

    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", base_err, "rax")
    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRUCT, false)
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, c.ERROR_STRUCT_ID, false)

    state = cg_emit_expr(state, call_args[0])
    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", base_err)
    state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8, "rax")

    state = cg_emit_expr(state, call_args[1])
    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", base_err)
    state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "rax")

    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", base_err)
    state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_script")
    state.asm = a.mov_membase_disp_r64(state.asm, "r11", 24, "rax")
    state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_func")
    state.asm = a.mov_membase_disp_r64(state.asm, "r11", 32, "rax")
    state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_line")
    state.asm = a.mov_membase_disp_r64(state.asm, "r11", 40, "rax")

    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", base_err)
    if base_err_ok then state = core.free_expr_temps(state, 8) end if
    return [state, true]
  end if

  if callee == "decodeZ" and nargs == 1 then
    tmp_dz_direct = core.alloc_expr_temps(state, 16)
    tmp_dz_direct_ok = typeof(tmp_dz_direct) == "int" and tmp_dz_direct > 0
    if not tmp_dz_direct_ok then tmp_dz_direct = 0x2F0 end if

    state = cg_emit_expr(state, call_args[0])

    lid_dz_direct = _next_lid(state)
    l_dz_fail_direct = "decodeZ_fail_" + lid_dz_direct
    l_dz_done_direct = "decodeZ_done_" + lid_dz_direct
    l_dz_after_direct = "decodeZ_after_" + lid_dz_direct

    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_dz_fail_direct)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "ne", l_dz_fail_direct)

    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_dz_direct, "rax")
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 4)
    state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "rax", 8)
    state.asm = a.call(state.asm, "fn_scan_nul_bytes")
    state.asm = a.mov_r32_r32(state.asm, "r8d", "edx")

    state.asm = a.mark(state.asm, l_dz_done_direct)

    state.asm = a.mov_r64_r64(state.asm, "r11", "r8")
    state.asm = a.shl_r64_imm8(state.asm, "r11", 3)
    state.asm = a.or_r64_imm8(state.asm, "r11", c.TAG_INT)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_dz_direct + 8, "r11")

    state.asm = a.mov_r32_r32(state.asm, "ecx", "r8d")
    state.asm = a.add_r32_imm(state.asm, "ecx", 9)
    state.asm = a.call(state.asm, "fn_alloc")

    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRING, false)

    state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", tmp_dz_direct + 8)
    state.asm = a.sar_r64_imm8(state.asm, "r8", 3)
    state.asm = a.mov_r32_r32(state.asm, "r8d", "r8d")
    state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "r8d")

    state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", tmp_dz_direct)

    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_dz_direct, "r11")
    state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r11", 8)
    state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r10", 8)
    state.asm = a.mov_r32_r32(state.asm, "r8d", "r8d")
    state.asm = a.call(state.asm, "fn_copy_bytes")
    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", tmp_dz_direct)

    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.add_r64_r64(state.asm, "rax", "r8")
    state.asm = a.add_rax_imm8(state.asm, 8)
    state.asm = a.mov_membase_disp_imm8(state.asm, "rax", 0, 0)

    state.asm = a.mov_rax_r11(state.asm)
    state.asm = a.jmp(state.asm, l_dz_after_direct)

    state.asm = a.mark(state.asm, l_dz_fail_direct)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())

    state.asm = a.mark(state.asm, l_dz_after_direct)
    if tmp_dz_direct_ok then state = core.free_expr_temps(state, 16) end if
    return [state, true]
  end if

  if callee == "decode16Z" and nargs == 1 then
    tmp_d16_direct = core.alloc_expr_temps(state, 32)
    tmp_d16_direct_ok = typeof(tmp_d16_direct) == "int" and tmp_d16_direct > 0
    if not tmp_d16_direct_ok then tmp_d16_direct = 0x2D0 end if

    state = cg_emit_expr(state, call_args[0])

    lid_d16_direct = _next_lid(state)
    l_d16_fail_direct = "decode16Z_fail_" + lid_d16_direct
    l_d16_done_direct = "decode16Z_done_" + lid_d16_direct
    l_d16_after_direct = "decode16Z_after_" + lid_d16_direct

    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_d16_fail_direct)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "ne", l_d16_fail_direct)

    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_d16_direct, "rax")
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 4)
    state.asm = a.shr_r32_imm8(state.asm, "edx", 1)
    state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "rax", 8)
    state.asm = a.call(state.asm, "fn_scan_nul_wchars")
    state.asm = a.mov_r32_r32(state.asm, "r8d", "edx")

    state.asm = a.mark(state.asm, l_d16_done_direct)

    state.asm = a.mov_r64_r64(state.asm, "r11", "r8")
    state.asm = a.shl_r64_imm8(state.asm, "r11", 3)
    state.asm = a.or_r64_imm8(state.asm, "r11", c.TAG_INT)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_d16_direct + 8, "r11")

    state.asm = a.mov_rcx_imm32(state.asm, 65001)
    state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
    state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", tmp_d16_direct)
    state.asm = a.lea_r64_membase_disp(state.asm, "r8", "r8", 8)
    state.asm = a.mov_r64_membase_disp(state.asm, "r9", "rsp", tmp_d16_direct + 8)
    state.asm = a.sar_r64_imm8(state.asm, "r9", 3)
    state.asm = a.mov_r32_r32(state.asm, "r9d", "r9d")
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x28, 0, true)
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x30, 0, true)
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x38, 0, true)
    state.asm = a.call_rip_qword(state.asm, "iat_WideCharToMultiByte")

    state.asm = a.cmp_rax_imm8(state.asm, 0)
    state.asm = a.jcc(state.asm, "e", l_d16_fail_direct)

    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.shl_r64_imm8(state.asm, "r10", 3)
    state.asm = a.or_r64_imm8(state.asm, "r10", c.TAG_INT)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_d16_direct + 16, "r10")

    state.asm = a.mov_r32_r32(state.asm, "ecx", "eax")
    state.asm = a.add_r32_imm(state.asm, "ecx", 9)
    state.asm = a.call(state.asm, "fn_alloc")

    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRING, false)

    state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", tmp_d16_direct + 16)
    state.asm = a.sar_r64_imm8(state.asm, "r10", 3)
    state.asm = a.mov_r32_r32(state.asm, "r10d", "r10d")
    state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "r10d")

    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_d16_direct + 24, "r11")

    state.asm = a.mov_rcx_imm32(state.asm, 65001)
    state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
    state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", tmp_d16_direct)
    state.asm = a.lea_r64_membase_disp(state.asm, "r8", "r8", 8)
    state.asm = a.mov_r64_membase_disp(state.asm, "r9", "rsp", tmp_d16_direct + 8)
    state.asm = a.sar_r64_imm8(state.asm, "r9", 3)
    state.asm = a.mov_r32_r32(state.asm, "r9d", "r9d")

    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", tmp_d16_direct + 24)
    state.asm = a.lea_r64_membase_disp(state.asm, "rax", "r11", 8)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")
    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tmp_d16_direct + 16)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x28, "rax")
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x30, 0, true)
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x38, 0, true)
    state.asm = a.call_rip_qword(state.asm, "iat_WideCharToMultiByte")

    state.asm = a.cmp_rax_imm8(state.asm, 0)
    state.asm = a.jcc(state.asm, "e", l_d16_fail_direct)

    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", tmp_d16_direct + 24)
    state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", tmp_d16_direct + 16)
    state.asm = a.sar_r64_imm8(state.asm, "r10", 3)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.add_r64_r64(state.asm, "rax", "r10")
    state.asm = a.add_rax_imm8(state.asm, 8)
    state.asm = a.mov_membase_disp_imm8(state.asm, "rax", 0, 0)

    state.asm = a.mov_rax_r11(state.asm)
    state.asm = a.jmp(state.asm, l_d16_after_direct)

    state.asm = a.mark(state.asm, l_d16_fail_direct)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())

    state.asm = a.mark(state.asm, l_d16_after_direct)
    if tmp_d16_direct_ok then state = core.free_expr_temps(state, 32) end if
    return [state, true]
  end if
  return [state, false]
end function

function _emit_generic_call_builtin_cases(state, callee, raw_name, call_args, nargs, call_args_base)
  if callee == "array" then
    if nargs != 1 and nargs != 2 then
      state.diagnostics = state.diagnostics +["array() expects 1 or 2 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if

    if nargs == 2 then
      state = mem.ensure_gc_data(state)
    end if

    lid_arr = _next_lid(state)
    l_fail_arr = "array_init_fail_" + lid_arr
    l_arr_imm = "array_init_imm_" + lid_arr
    l_arr_type_done = "array_init_type_done_" + lid_arr
    l_done_arr = "array_init_done_" + lid_arr

    // validate + decode size (tagged int >= 0 and <= 0x7fffffff)
    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x20)
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_fail_arr)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
    state.asm = a.jcc(state.asm, "l", l_fail_arr)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
    state.asm = a.jcc(state.asm, "g", l_fail_arr)

    // optional fill root across fn_alloc (allocator can trigger GC)
    if nargs == 2 then
      state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x28)
      state.asm = a.mov_rip_qword_r11(state.asm, "gc_tmp0")
    end if

    // allocate payload bytes = 8 + len*8
    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x20)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.shl_r64_imm8(state.asm, "rcx", 3)
    state.asm = a.add_r64_imm(state.asm, "rcx", 8)
    state.asm = a.call(state.asm, "fn_alloc")

    // r11 = array base
    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    if nargs == 2 then
      state.asm = a.mov_rax_rip_qword(state.asm, "gc_tmp0")
      state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
      state.asm = a.and_r64_imm(state.asm, "r10", 7)
      state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
      state.asm = a.jcc(state.asm, "ne", l_arr_imm)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_ARRAY, false)
      state.asm = a.jmp(state.asm, l_arr_type_done)
      state.asm = a.mark(state.asm, l_arr_imm)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_ARRAY_IMM, false)
      state.asm = a.mark(state.asm, l_arr_type_done)
    else
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_ARRAY_IMM, false)
    end if

    // header len (u32)
    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x20)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.mov_r32_r32(state.asm, "edx", "eax")
    state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "edx")

    // fill value in rdx
    if nargs == 2 then
      state.asm = a.mov_rdx_rip_qword(state.asm, "gc_tmp0")
    else
      state.asm = a.mov_r64_imm64(state.asm, "rdx", t.enc_void())
    end if

    // fill payload with rdx
    state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r11", 8)
    state.asm = a.mov_r64_r64(state.asm, "r8", "rdx")
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 4)
    state.asm = a.call(state.asm, "fn_fill_qwords")

    if nargs == 2 then
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp0")
    end if

    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.jmp(state.asm, l_done_arr)

    state.asm = a.mark(state.asm, l_fail_arr)
    if nargs == 2 then
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp0")
    end if
    state = _emit_make_error_const(state, c.ERR_ARRAY_INIT_SIZE, "array() size must be an int in range 0..2147483647")
    state = _emit_auto_errprop(state)

    state.asm = a.mark(state.asm, l_done_arr)
    return [state, true]
  end if

  if callee == "bytes" or callee == "byteBuffer" then
    if nargs == 0 then
      state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
      state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
      state.asm = a.call(state.asm, "fn_bytes_alloc")
      return [state, true]
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
      return [state, true]
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
      state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY_IMM)
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
      return [state, true]
    end if

    state.diagnostics = state.diagnostics +["bytes()/byteBuffer() expects 0, 1 or 2 arguments"]
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return [state, true]
  end if

  if callee == "decode" then
    if nargs != 1 and nargs != 2 then
      state.diagnostics = state.diagnostics + ["decode() expects 1 or 2 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
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
    return [state, true]
  end if

  // Strict-void parity with Python: len(void) must raise an error.
  if (callee == "len" or raw_name == "len") and nargs == 1 then
    arg0 = call_args[0]
    const_len = -1
    cv0 = _opt_try_const_value(state, arg0)
    if typeof(cv0) == "struct" and cv0.ok then
      if typeof(cv0.value) == "string" then
        const_len = len(cv0.value)
      else
        const_len = _opt_try_pure_const_array_len(state, arg0)
      end if
    else
      const_len = _opt_try_pure_const_array_len(state, arg0)
    end if
    if const_len >= 0 then
      state.asm = a.mov_rax_imm64(state.asm, t.enc_int(const_len))
      return [state, true]
    end if

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
    return [state, true]
  end if

  if (callee == "hex" or raw_name == "hex") then
    if nargs != 1 then
      state.diagnostics = state.diagnostics +["hex() expects exactly 1 argument"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    state.asm = a.call(state.asm, "fn_hex")
    return [state, true]
  end if

  if (callee == "fromHex" or raw_name == "fromHex") then
    if nargs != 1 then
      state.diagnostics = state.diagnostics +["fromHex() expects exactly 1 argument"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    state.asm = a.call(state.asm, "fn_fromHex")
    return [state, true]
  end if

  if (callee == "slice" or raw_name == "slice") then
    if nargs != 3 then
      state.diagnostics = state.diagnostics +["slice() expects exactly 3 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    state.asm = a.call(state.asm, "fn_slice")
    return [state, true]
  end if

  if (callee == "gc_collect" or raw_name == "gc_collect") then
    if nargs != 0 then
      state.diagnostics = state.diagnostics +["gc_collect() expects 0 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    state.asm = a.call(state.asm, "fn_gc_collect")
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return [state, true]
  end if

  if (callee == "gc_set_limit" or raw_name == "gc_set_limit") then
    if nargs != 1 then
      state.diagnostics = state.diagnostics +["gc_set_limit() expects exactly 1 argument"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    state.asm = a.mov_r32_imm32(state.asm, "r10d", 1)
    state.asm = a.call(state.asm, "fn_builtin_gc_set_limit")
    return [state, true]
  end if

  if (callee == "callStats" or raw_name == "callStats") then
    if nargs != 0 then
      state.diagnostics = state.diagnostics +["callStats() expects 0 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    state.asm = a.call(state.asm, "fn_callStats")
    return [state, true]
  end if

  if (callee == "heap_count" or raw_name == "heap_count") then
    if nargs != 0 then
      state.diagnostics = state.diagnostics +["heap_count() expects 0 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    state.asm = a.call(state.asm, "fn_heap_count")
    return [state, true]
  end if

  if (callee == "heap_bytes_used" or raw_name == "heap_bytes_used") then
    if nargs != 0 then
      state.diagnostics = state.diagnostics +["heap_bytes_used() expects 0 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    state.asm = a.call(state.asm, "fn_heap_bytes_used")
    return [state, true]
  end if

  if (callee == "heap_free_bytes" or raw_name == "heap_free_bytes") then
    if nargs != 0 then
      state.diagnostics = state.diagnostics +["heap_free_bytes() expects 0 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    state.asm = a.call(state.asm, "fn_heap_free_bytes")
    return [state, true]
  end if

  if (callee == "heap_free_blocks" or raw_name == "heap_free_blocks") then
    if nargs != 0 then
      state.diagnostics = state.diagnostics +["heap_free_blocks() expects 0 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    state.asm = a.call(state.asm, "fn_heap_free_blocks")
    return [state, true]
  end if

  if (callee == "heap_bytes_committed" or raw_name == "heap_bytes_committed") then
    if nargs != 0 then
      state.diagnostics = state.diagnostics +["heap_bytes_committed() expects 0 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    state.asm = a.mov_rax_rip_qword(state.asm, "heap_end")
    state.asm = a.mov_rdx_rip_qword(state.asm, "heap_base")
    state.asm = a.sub_r64_r64(state.asm, "rax", "rdx")
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
    return [state, true]
  end if

  if (callee == "heap_bytes_reserved" or raw_name == "heap_bytes_reserved") then
    if nargs != 0 then
      state.diagnostics = state.diagnostics +["heap_bytes_reserved() expects 0 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    state.asm = a.mov_rax_rip_qword(state.asm, "heap_reserve_end")
    state.asm = a.mov_rdx_rip_qword(state.asm, "heap_base")
    state.asm = a.sub_r64_r64(state.asm, "rax", "rdx")
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
    return [state, true]
  end if

  if (callee == "copyBytes" or raw_name == "copyBytes") then
    if nargs != 5 then
      state.diagnostics = state.diagnostics +["copyBytes() expects exactly 5 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if

    lid_cb = _next_lid(state)
    l_cb_done = "copybytes_done_" + lid_cb
    l_cb_fail = "copybytes_fail_" + lid_cb
    l_cb_min_dst = "copybytes_min_dst_" + lid_cb
    l_cb_min_src = "copybytes_min_src_" + lid_cb

    state.asm = a.mov_r64_r64(state.asm, "r11", "rcx")
    state.asm = a.mov_r64_r64(state.asm, "r10", "r11")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_cb_fail)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "ne", l_cb_fail)

    state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_cb_fail)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
    state.asm = a.jcc(state.asm, "l", l_cb_fail)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
    state.asm = a.jcc(state.asm, "g", l_cb_fail)

    state.asm = a.mov_r64_r64(state.asm, "r8", "r8")
    state.asm = a.mov_r64_r64(state.asm, "r10", "r8")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_cb_fail)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r8", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "ne", l_cb_fail)

    state.asm = a.mov_r64_r64(state.asm, "r10", "r9")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_cb_fail)
    state.asm = a.sar_r64_imm8(state.asm, "r9", 3)
    state.asm = a.cmp_r64_imm(state.asm, "r9", 0)
    state.asm = a.jcc(state.asm, "l", l_cb_fail)
    state.asm = a.cmp_r64_imm(state.asm, "r9", 0x7FFFFFFF)
    state.asm = a.jcc(state.asm, "g", l_cb_fail)

    state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", call_args_base + 32)
    state.asm = a.mov_r64_r64(state.asm, "r10", "rcx")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_cb_fail)
    state.asm = a.sar_r64_imm8(state.asm, "rcx", 3)
    state.asm = a.cmp_r64_imm(state.asm, "rcx", 0)
    state.asm = a.jcc(state.asm, "l", l_cb_fail)
    state.asm = a.cmp_r64_imm(state.asm, "rcx", 0x7FFFFFFF)
    state.asm = a.jcc(state.asm, "g", l_cb_fail)

    state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 4)
    state.asm = a.cmp_r32_r32(state.asm, "eax", "r10d")
    state.asm = a.jcc(state.asm, "ge", l_cb_done)
    state.asm = a.sub_r32_r32(state.asm, "r10d", "eax")

    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r8", 4)
    state.asm = a.cmp_r32_r32(state.asm, "r9d", "edx")
    state.asm = a.jcc(state.asm, "ge", l_cb_done)
    state.asm = a.sub_r32_r32(state.asm, "edx", "r9d")

    state.asm = a.cmp_r32_r32(state.asm, "ecx", "r10d")
    state.asm = a.jcc(state.asm, "le", l_cb_min_dst)
    state.asm = a.mov_r32_r32(state.asm, "ecx", "r10d")
    state.asm = a.mark(state.asm, l_cb_min_dst)
    state.asm = a.cmp_r32_r32(state.asm, "ecx", "edx")
    state.asm = a.jcc(state.asm, "le", l_cb_min_src)
    state.asm = a.mov_r32_r32(state.asm, "ecx", "edx")
    state.asm = a.mark(state.asm, l_cb_min_src)
    state.asm = a.test_r32_r32(state.asm, "ecx", "ecx")
    state.asm = a.jcc(state.asm, "le", l_cb_done)

    state.asm = a.mov_r32_r32(state.asm, "r8d", "ecx")
    state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r11", 8)
    state.asm = a.add_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r8", 8)
    state.asm = a.add_r64_r64(state.asm, "rdx", "r9")
    state.asm = a.call(state.asm, "fn_copy_bytes")
    state.asm = a.jmp(state.asm, l_cb_done)

    state.asm = a.mark(state.asm, l_cb_fail)
    state.asm = a.mark(state.asm, l_cb_done)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return [state, true]
  end if

  if (callee == "fillBytes" or raw_name == "fillBytes") then
    if nargs != 4 then
      state.diagnostics = state.diagnostics +["fillBytes() expects exactly 4 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if

    lid_fb = _next_lid(state)
    l_fb_done = "fillbytes_done_" + lid_fb
    l_fb_fail = "fillbytes_fail_" + lid_fb
    l_fb_len_ok = "fillbytes_len_ok_" + lid_fb

    state.asm = a.mov_r64_r64(state.asm, "r11", "rcx")
    state.asm = a.mov_r64_r64(state.asm, "r10", "r11")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_fb_fail)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "ne", l_fb_fail)

    state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")
    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_fb_fail)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
    state.asm = a.jcc(state.asm, "l", l_fb_fail)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
    state.asm = a.jcc(state.asm, "g", l_fb_fail)

    state.asm = a.mov_r64_r64(state.asm, "rcx", "r8")
    state.asm = a.mov_r64_r64(state.asm, "r10", "rcx")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_fb_fail)
    state.asm = a.sar_r64_imm8(state.asm, "rcx", 3)
    state.asm = a.cmp_r64_imm(state.asm, "rcx", 0)
    state.asm = a.jcc(state.asm, "l", l_fb_fail)
    state.asm = a.cmp_r64_imm(state.asm, "rcx", 0x7FFFFFFF)
    state.asm = a.jcc(state.asm, "g", l_fb_fail)

    state.asm = a.mov_r64_r64(state.asm, "r9", "r9")
    state.asm = a.mov_r64_r64(state.asm, "r10", "r9")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
    state.asm = a.jcc(state.asm, "ne", l_fb_fail)
    state.asm = a.sar_r64_imm8(state.asm, "r9", 3)
    state.asm = a.cmp_r64_imm(state.asm, "r9", 0)
    state.asm = a.jcc(state.asm, "l", l_fb_fail)
    state.asm = a.cmp_r64_imm(state.asm, "r9", 255)
    state.asm = a.jcc(state.asm, "g", l_fb_fail)

    state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 4)
    state.asm = a.cmp_r32_r32(state.asm, "eax", "r10d")
    state.asm = a.jcc(state.asm, "ge", l_fb_done)
    state.asm = a.sub_r32_r32(state.asm, "r10d", "eax")

    state.asm = a.mov_r32_r32(state.asm, "edx", "ecx")
    state.asm = a.cmp_r32_r32(state.asm, "edx", "r10d")
    state.asm = a.jcc(state.asm, "le", l_fb_len_ok)
    state.asm = a.mov_r32_r32(state.asm, "edx", "r10d")
    state.asm = a.mark(state.asm, l_fb_len_ok)
    state.asm = a.test_r32_r32(state.asm, "edx", "edx")
    state.asm = a.jcc(state.asm, "le", l_fb_done)

    state.asm = a.mov_r32_r32(state.asm, "r8d", "r9d")
    state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r11", 8)
    state.asm = a.add_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, "fn_fill_bytes")
    state.asm = a.jmp(state.asm, l_fb_done)

    state.asm = a.mark(state.asm, l_fb_fail)
    state.asm = a.mark(state.asm, l_fb_done)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return [state, true]
  end if

  if (callee == "decodeZ" or raw_name == "decodeZ") then
    if nargs != 1 then
      state.diagnostics = state.diagnostics +["decodeZ() expects exactly 1 argument"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    lid_dz = _next_lid(state)
    l_dz_fail = "decodeZ_fail_" + lid_dz
    l_dz_after = "decodeZ_after_" + lid_dz
    tmp_dz = core.alloc_expr_temps(state, 16)
    tmp_dz_ok = typeof(tmp_dz) == "int" and tmp_dz > 0
    if not tmp_dz_ok then tmp_dz = 0x2F0 end if

    state.asm = a.mov_r64_r64(state.asm, "r10", "rcx")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_dz_fail)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rcx", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "ne", l_dz_fail)

    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_dz, "rcx")
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rcx", 4)
    state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "rcx", 8)
    state.asm = a.call(state.asm, "fn_scan_nul_bytes")
    state.asm = a.mov_r32_r32(state.asm, "r8d", "edx")

    state.asm = a.mov_r64_r64(state.asm, "r11", "r8")
    state.asm = a.shl_r64_imm8(state.asm, "r11", 3)
    state.asm = a.or_r64_imm8(state.asm, "r11", c.TAG_INT)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_dz + 8, "r11")

    state.asm = a.mov_r32_r32(state.asm, "ecx", "r8d")
    state.asm = a.add_r32_imm(state.asm, "ecx", 9)
    state.asm = a.call(state.asm, "fn_alloc")
    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRING, false)
    state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", tmp_dz + 8)
    state.asm = a.sar_r64_imm8(state.asm, "r8", 3)
    state.asm = a.mov_r32_r32(state.asm, "r8d", "r8d")
    state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "r8d")
    state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", tmp_dz)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_dz, "r11")
    state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r11", 8)
    state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r10", 8)
    state.asm = a.mov_r32_r32(state.asm, "r8d", "r8d")
    state.asm = a.call(state.asm, "fn_copy_bytes")
    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", tmp_dz)
    state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", tmp_dz + 8)
    state.asm = a.sar_r64_imm8(state.asm, "r8", 3)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.add_r64_r64(state.asm, "rax", "r8")
    state.asm = a.add_rax_imm8(state.asm, 8)
    state.asm = a.mov_membase_disp_imm8(state.asm, "rax", 0, 0)
    state.asm = a.mov_rax_r11(state.asm)
    state.asm = a.jmp(state.asm, l_dz_after)

    state.asm = a.mark(state.asm, l_dz_fail)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())

    state.asm = a.mark(state.asm, l_dz_after)
    if tmp_dz_ok then state = core.release_expr_temps(state, 16) end if
    return [state, true]
  end if

  if (callee == "decode16Z" or raw_name == "decode16Z") then
    if nargs != 1 then
      state.diagnostics = state.diagnostics +["decode16Z() expects exactly 1 argument"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    lid_d16 = _next_lid(state)
    l_d16_fail = "decode16Z_fail_" + lid_d16
    l_d16_after = "decode16Z_after_" + lid_d16
    tmp_d16 = core.alloc_expr_temps(state, 32)
    tmp_d16_ok = typeof(tmp_d16) == "int" and tmp_d16 > 0
    if not tmp_d16_ok then tmp_d16 = 0x2D0 end if

    state.asm = a.mov_r64_r64(state.asm, "r10", "rcx")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_d16_fail)
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rcx", 0)
    state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "ne", l_d16_fail)

    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_d16, "rcx")
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rcx", 4)
    state.asm = a.sar_r64_imm8(state.asm, "rdx", 1)
    state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "rcx", 8)
    state.asm = a.call(state.asm, "fn_scan_nul_wchars")
    state.asm = a.mov_r32_r32(state.asm, "r8d", "edx")

    state.asm = a.mov_r64_r64(state.asm, "r11", "r8")
    state.asm = a.shl_r64_imm8(state.asm, "r11", 3)
    state.asm = a.or_r64_imm8(state.asm, "r11", c.TAG_INT)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_d16 + 8, "r11")

    state.asm = a.mov_rcx_imm32(state.asm, 65001)
    state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
    state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", tmp_d16)
    state.asm = a.lea_r64_membase_disp(state.asm, "r8", "r8", 8)
    state.asm = a.mov_r64_membase_disp(state.asm, "r9", "rsp", tmp_d16 + 8)
    state.asm = a.sar_r64_imm8(state.asm, "r9", 3)
    state.asm = a.mov_r32_r32(state.asm, "r9d", "r9d")
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x28, 0, true)
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x30, 0, true)
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x38, 0, true)
    state.asm = a.mov_rax_rip_qword(state.asm, "iat_WideCharToMultiByte")
    state.asm = a.call_rax(state.asm)
    state.asm = a.cmp_rax_imm8(state.asm, 0)
    state.asm = a.jcc(state.asm, "e", l_d16_fail)

    state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
    state.asm = a.shl_r64_imm8(state.asm, "r10", 3)
    state.asm = a.or_r64_imm8(state.asm, "r10", c.TAG_INT)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_d16 + 16, "r10")

    state.asm = a.mov_r32_r32(state.asm, "ecx", "eax")
    state.asm = a.add_r32_imm(state.asm, "ecx", 9)
    state.asm = a.call(state.asm, "fn_alloc")
    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRING, false)
    state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", tmp_d16 + 16)
    state.asm = a.sar_r64_imm8(state.asm, "r10", 3)
    state.asm = a.mov_r32_r32(state.asm, "r10d", "r10d")
    state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "r10d")
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_d16 + 24, "r11")

    state.asm = a.mov_rcx_imm32(state.asm, 65001)
    state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
    state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", tmp_d16)
    state.asm = a.lea_r64_membase_disp(state.asm, "r8", "r8", 8)
    state.asm = a.mov_r64_membase_disp(state.asm, "r9", "rsp", tmp_d16 + 8)
    state.asm = a.sar_r64_imm8(state.asm, "r9", 3)
    state.asm = a.mov_r32_r32(state.asm, "r9d", "r9d")
    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", tmp_d16 + 24)
    state.asm = a.lea_r64_membase_disp(state.asm, "rax", "r11", 8)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")
    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", tmp_d16 + 16)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x28, "rax")
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x30, 0, true)
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x38, 0, true)
    state.asm = a.mov_rax_rip_qword(state.asm, "iat_WideCharToMultiByte")
    state.asm = a.call_rax(state.asm)
    state.asm = a.cmp_rax_imm8(state.asm, 0)
    state.asm = a.jcc(state.asm, "e", l_d16_fail)

    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", tmp_d16 + 24)
    state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", tmp_d16 + 16)
    state.asm = a.sar_r64_imm8(state.asm, "r10", 3)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.add_r64_r64(state.asm, "rax", "r10")
    state.asm = a.add_rax_imm8(state.asm, 8)
    state.asm = a.mov_membase_disp_imm8(state.asm, "rax", 0, 0)
    state.asm = a.mov_rax_r11(state.asm)
    state.asm = a.jmp(state.asm, l_d16_after)

    state.asm = a.mark(state.asm, l_d16_fail)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())

    state.asm = a.mark(state.asm, l_d16_after)
    if tmp_d16_ok then state = core.release_expr_temps(state, 32) end if
    return [state, true]
  end if

  return [state, false]
end function

function _direct_user_call_enabled(qname)
  return true
end function

function _emit_expr_call_generic(state, cal, callee, raw_name, call_args, nargs, member_runtime)
  skip_call_args_eval = false
  direct_struct_constructor = false
  direct_user_global = false
  direct_user_name = ""
  generic_nonmember_candidate = false
  compiletime_member_callable = false
  cal_kind_skip = ""
  if typeof(cal) == "struct" then cal_kind_skip = _coerce_name(try(cal.node_kind)) end if
  if typeof(cal) == "struct" and cal_kind_skip == "Member" and member_runtime == false then
    compiletime_member_callable = true
  end if
  if typeof(cal) == "struct" and cal_kind_skip != "Member" then
    skip_qn = callee
    if skip_qn == "" then skip_qn = raw_name end if
    if skip_qn != "" then
      skip_fn = _user_function_get(state, skip_qn)
      if typeof(skip_fn) == "struct" then
        skip_bind = scope.cg_resolve_binding(state, skip_qn)
        if (typeof(skip_bind) != "struct" or skip_bind.kind == "global") and _direct_user_call_enabled(skip_qn) then
          direct_user_global = true
          direct_user_name = skip_qn
        end if
      end if
    end if

    if direct_user_global == false then
      special_qn = skip_qn
      if special_qn == "" then
        generic_nonmember_candidate = true
      else
        is_special = false
        if special_qn == "array" then is_special = true end if
        if special_qn == "bytes" or special_qn == "byteBuffer" then is_special = true end if
        if special_qn == "len" or special_qn == "typeof" or special_qn == "typeName" then is_special = true end if
        if special_qn == "input" or special_qn == "decode" or special_qn == "decodeZ" or special_qn == "decode16Z" then is_special = true end if
        if special_qn == "slice" or special_qn == "copyBytes" or special_qn == "fillBytes" then is_special = true end if
        if special_qn == "hex" or special_qn == "fromHex" or special_qn == "error" then is_special = true end if
        if special_qn == "gc_collect" or special_qn == "gc_set_limit" or special_qn == "callStats" then is_special = true end if
        if special_qn == "heap_count" or special_qn == "heap_bytes_used" or special_qn == "heap_free_bytes" or special_qn == "heap_free_blocks" then is_special = true end if
        if special_qn == "heap_bytes_committed" or special_qn == "heap_bytes_reserved" then is_special = true end if
        if is_special == false and _state_struct_id_get(state, special_qn, 0) == 0 then
          generic_nonmember_candidate = true
        end if
      end if
    end if
  end if
  skip_scallee = callee
  skip_sid = _state_struct_id_get(state, skip_scallee, 0)
  if skip_sid == 0 and raw_name != "" and raw_name != skip_scallee then
    skip_sid2 = _state_struct_id_get(state, raw_name, 0)
    if skip_sid2 != 0 then
      skip_sid = skip_sid2
    end if
  end if
  if skip_sid != 0 then direct_struct_constructor = true end if
  // Generic indirect calls materialize [callee, arg0, ...] in one dedicated temp area later.
  // Runtime member function values like state.action.acp2 must also use that path,
  // otherwise the later callee temp can reuse and overwrite the pre-evaluated args.
  // If we pre-evaluate args into a temporary buffer here and release it before callee eval,
  // the callee expression can reuse the same expr-temp slots and corrupt the saved args.
  if compiletime_member_callable or member_runtime or direct_struct_constructor or generic_nonmember_candidate or direct_user_global then skip_call_args_eval = true end if

  // Evaluate args left-to-right into a nested-safe temp area first.
  // Nested calls inside argument expressions can use rsp+0x20 too, so we
  // must not build the outer call argument vector there directly.
  call_args_base = 0
  call_args_alloc = false
  if nargs > 0 then
    if skip_call_args_eval then
      // Generic indirect-call lowering evaluates arguments directly into rooted temp slots later.
    else
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
  end if

  if skip_call_args_eval then
    // Indirect/devirtualized call paths reload directly from rooted temp slots.
  else
    if nargs >= 1 then state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x20) end if
    if nargs >= 2 then state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", 0x28) end if
    if nargs >= 3 then state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", 0x30) end if
    if nargs >= 4 then state.asm = a.mov_r64_membase_disp(state.asm, "r9", "rsp", 0x38) end if
  end if

  if raw_name == "" and typeof(cal) == "struct" and _coerce_name(try(cal.node_kind)) == "Member" then
    raw_name = _expr_to_qualname(state, cal)
  end if

  handled_generic_builtin = _emit_generic_call_builtin_cases(state, callee, raw_name, call_args, nargs, call_args_base)
  if typeof(handled_generic_builtin) == "array" and len(handled_generic_builtin) >= 2 then
    state = handled_generic_builtin[0]
    if handled_generic_builtin[1] then return state end if
  end if

  scallee = callee
  sid = _state_struct_id_get(state, scallee, 0)
  if sid == 0 and raw_name != "" and raw_name != scallee then
    sid2 = _state_struct_id_get(state, raw_name, 0)
    if sid2 != 0 then
      sid = sid2
      scallee = raw_name
    end if
  end if
  if sid != 0 then
    expected = 0
    flds = _state_struct_fields_get(state, scallee)
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
      state.asm = a.mov_rcx_imm32(state.asm, 48)
      state.asm = a.call(state.asm, "fn_alloc")
      base_err = core.alloc_expr_temps(state, 8)
      base_err_ok = typeof(base_err) == "int" and base_err > 0
      if not base_err_ok then base_err = 0x2F8 end if
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", base_err, "rax")
      state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRUCT, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, c.ERROR_STRUCT_ID, false)
      state = cg_emit_expr(state, call_args[0])
      state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", base_err)
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8, "rax")
      state = cg_emit_expr(state, call_args[1])
      state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", base_err)
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "rax")
      state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", base_err)
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_script")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 24, "rax")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_func")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 32, "rax")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_line")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 40, "rax")
      state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", base_err)
      if base_err_ok then state = core.release_expr_temps(state, 8) end if
      return state
    end if

    arg_base_struct = 0
    arg_base_struct_ok = false
    if nargs > 0 then
      arg_base_struct = core.alloc_expr_temps(state, nargs * 8)
      arg_base_struct_ok = typeof(arg_base_struct) == "int" and arg_base_struct > 0
      if not arg_base_struct_ok then arg_base_struct = 0x300 end if
      for fi_eval = 0 to nargs - 1
        state = cg_emit_expr(state, call_args[fi_eval])
        state.asm = a.mov_membase_disp_r64(state.asm, "rsp", arg_base_struct + fi_eval * 8, "rax")
      end for
    end if

    state.asm = a.mov_rcx_imm32(state.asm, 8 + nargs * 8)
    state.asm = a.call(state.asm, "fn_alloc")
    base_struct = core.alloc_expr_temps(state, 8)
    base_struct_ok = typeof(base_struct) == "int" and base_struct > 0
    if not base_struct_ok then base_struct = 0x2F8 end if
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", base_struct, "rax")
    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRUCT, false)
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, sid, false)
    if nargs > 0 then
      for fi = 0 to nargs - 1
        state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", arg_base_struct + fi * 8)
        state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", base_struct)
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8 + fi * 8, "rax")
      end for
    end if
    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", base_struct)
    if base_struct_ok then state = core.free_expr_temps(state, 8) end if
    if arg_base_struct_ok then state = core.free_expr_temps(state, nargs * 8) end if
    return state
  end if

  if direct_user_global and direct_user_name != "" then
    direct_fn = _user_function_get(state, direct_user_name)
    if typeof(direct_fn) == "struct" then
      direct_expected = 0
      if typeof(direct_fn.params) == "array" then direct_expected = len(direct_fn.params) end if
      if nargs != direct_expected then
        state.diagnostics = state.diagnostics + ["Function " + direct_user_name + " expects " + direct_expected + " args, got " + nargs]
        state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
        return state
      end if

      direct_base = 0
      direct_base_ok = false
      if nargs > 0 then
        direct_base = core.alloc_expr_temps(state, nargs * 8)
        if typeof(direct_base) == "int" and direct_base > 0 then
          direct_base_ok = true
        else
          direct_base = 0x300
        end if

        for direct_ai = 0 to nargs - 1
          state = cg_emit_expr(state, call_args[direct_ai])
          state.asm = a.mov_membase_disp_r64(state.asm, "rsp", direct_base + direct_ai * 8, "rax")
        end for

        if nargs >= 1 then state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", direct_base + 0) end if
        if nargs >= 2 then state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", direct_base + 8) end if
        if nargs >= 3 then state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", direct_base + 16) end if
        if nargs >= 4 then state.asm = a.mov_r64_membase_disp(state.asm, "r9", "rsp", direct_base + 24) end if
        if nargs > 4 then
          for direct_si = 4 to nargs - 1
            state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", direct_base + direct_si * 8)
            state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20 + (direct_si - 4) * 8, "r10")
          end for
        end if
      end if

      state.asm = a.mov_r64_imm64(state.asm, "r10", t.enc_void())
      state.asm = a.call(state.asm, "fn_user_" + direct_user_name)
      state = _emit_auto_errprop(state)
      if direct_base_ok then state = core.free_expr_temps(state, nargs * 8) end if
      return state
    end if
  end if

  // Indirect callable dispatch (first-class function values).
  state.call_indirect_count = state.call_indirect_count + 1
  callee_is_member = false
  direct_guard_obj_lbl = ""
  direct_guard_call_lbl = ""
  direct_guard_builtin_nargs = false
  callee_desc = ""
  recv_desc = "receiver"
  meth_desc = "member"
  if typeof(cal) == "struct" and _coerce_name(try(cal.node_kind)) == "Member" then
    callee_is_member = true
    ppq = _qname_parts_any(cal)
    if typeof(ppq) == "array" and len(ppq) > 0 then
      callee_desc = s.join(ppq, ".")
    end if
    if callee_desc == "" then
      mnx0 = _coerce_name(try(cal.name))
      if mnx0 == "" then mnx0 = _coerce_name(try(cal.field)) end if
      callee_desc = mnx0
    end if
    if callee_desc != "" then
      last_dot = -1
      for di = 0 to len(callee_desc) - 1
        if callee_desc[di] == "." then last_dot = di end if
      end for
      if last_dot >= 0 then
        recv_desc = s.substr(callee_desc, 0, last_dot)
        meth_desc = s.substr(callee_desc, last_dot + 1, len(callee_desc) - last_dot - 1)
      else
        meth_desc = callee_desc
      end if
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

  if callee_is_member == false then
    dg_name = callee
    if dg_name == "" then dg_name = raw_name end if
    if dg_name != "" then
      b_dg = scope.cg_resolve_binding(state, dg_name)
      if typeof(b_dg) != "struct" or b_dg.kind == "global" then
        fn = _user_function_get(state, dg_name)
        if typeof(fn) == "struct" then
          expected_args_dg = 0
          if typeof(fn.params) == "array" then expected_args_dg = len(fn.params) end if
          if nargs != expected_args_dg then
            state.diagnostics = state.diagnostics + ["Function " + dg_name + " expects " + expected_args_dg + " args, got " + nargs]
            state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
            return state
          end if
          // User-function guarded devirtualization is temporarily disabled in the
          // selfhost object pipeline. Cross-module direct rel32 calls are not yet
          // reliable here, while the generic function-object dispatch is correct.
        else
          sp_code = ""
          sp_min = 0
          sp_max = -1
          if typeof(state.builtin_specs) == "array" then
            for bi_dg = 0 to len(state.builtin_specs) - 1
              sp = state.builtin_specs[bi_dg]
              if typeof(sp) != "array" or len(sp) < 4 then continue end if
              if _coerce_name(sp[0]) != dg_name then continue end if
              if typeof(sp[1]) == "int" then sp_min = sp[1] end if
              if typeof(sp[2]) == "int" then sp_max = sp[2] end if
              sp_code = _coerce_name(sp[3])
              break
            end for
          end if
          if sp_code != "" then
            obj_lbl_dg = _strpair_get(state.builtin_static_obj_labels, dg_name)
            if obj_lbl_dg != "" and nargs >= sp_min and nargs <= sp_max then
              direct_guard_obj_lbl = obj_lbl_dg
              direct_guard_call_lbl = sp_code
              direct_guard_builtin_nargs = true
            end if
          else
            obj_lbl_dg = _strpair_get(state.extern_static_obj_labels, dg_name)
            stub_lbl_dg = _strpair_get(state.extern_stub_labels, dg_name)
            if obj_lbl_dg != "" and stub_lbl_dg != "" then
              direct_guard_obj_lbl = obj_lbl_dg
              direct_guard_call_lbl = stub_lbl_dg
              direct_guard_builtin_nargs = true
            end if
          end if
        end if
      end if
    end if
  end if
  // Unified indirect-call lowering for member and non-member calls.
  if true then
    diag_extra_nm = 0
    if callee_is_member then diag_extra_nm = 24 end if
    base_nm = core.alloc_expr_temps(state, (nargs + 1) * 8 + diag_extra_nm)
    if typeof(base_nm) != "int" or base_nm <= 0 then
      state.diagnostics = state.diagnostics + ["Expression temp overflow in indirect call lowering"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return state
    end if
    if callee_is_member then
      void_imm_diag = t.enc_void()
      state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", base_nm + (nargs + 1) * 8 + 0, void_imm_diag, true)
      state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", base_nm + (nargs + 1) * 8 + 8, void_imm_diag, true)
      state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", base_nm + (nargs + 1) * 8 + 16, void_imm_diag, true)
    end if

    state = cg_emit_expr(state, cal)
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", base_nm, "rax")

    if nargs > 0 then
      for argi_nm = 0 to nargs - 1
        if skip_call_args_eval then
          arg_nm = call_args[argi_nm]
          if typeof(arg_nm) == "int" and arg_nm == 0 then
            state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
          else
            state = cg_emit_expr(state, arg_nm)
          end if
        else
          state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", call_args_base + argi_nm * 8)
        end if
        state.asm = a.mov_membase_disp_r64(state.asm, "rsp", base_nm + (argi_nm + 1) * 8, "rax")
      end for
    end if

    devirt_done_lbl_nm = ""
    if direct_guard_obj_lbl != "" and direct_guard_call_lbl != "" then
      l_devirt_indirect_nm = "icall_devirt_indirect_" + _next_lid(state)
      devirt_done_lbl_nm = "icall_devirt_done_" + _next_lid(state)

      state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", base_nm)
      state.asm = a.lea_rax_rip(state.asm, direct_guard_obj_lbl)
      state.asm = a.cmp_r64_r64(state.asm, "r11", "rax")
      state.asm = a.jcc(state.asm, "ne", l_devirt_indirect_nm)

      if nargs >= 1 then state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", base_nm + 8) end if
      if nargs >= 2 then state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", base_nm + 16) end if
      if nargs >= 3 then state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", base_nm + 24) end if
      if nargs >= 4 then state.asm = a.mov_r64_membase_disp(state.asm, "r9", "rsp", base_nm + 32) end if
      if nargs > 4 then
        for si_nm = 4 to nargs - 1
          state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", base_nm + (si_nm + 1) * 8)
          state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20 + (si_nm - 4) * 8, "r10")
        end for
      end if

      if direct_guard_builtin_nargs then
        state.asm = a.mov_r32_imm32(state.asm, "r10d", nargs)
      else
        state.asm = a.mov_r64_imm64(state.asm, "r10", t.enc_void())
      end if
      state.asm = a.call(state.asm, direct_guard_call_lbl)
      state = _emit_auto_errprop(state)
      state.asm = a.jmp(state.asm, devirt_done_lbl_nm)
      state.asm = a.mark(state.asm, l_devirt_indirect_nm)
    end if

    if nargs >= 1 then state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", base_nm + 8) end if
    if nargs >= 2 then state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", base_nm + 16) end if
    if nargs >= 3 then state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", base_nm + 24) end if
    if nargs >= 4 then state.asm = a.mov_r64_membase_disp(state.asm, "r9", "rsp", base_nm + 32) end if
    if nargs > 4 then
      for so_nm = 4 to nargs - 1
        state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", base_nm + (so_nm + 1) * 8)
        state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20 + (so_nm - 4) * 8, "r10")
      end for
    end if

    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", base_nm)

    fid_nm = _next_lid(state)
    l_fail_nm = "icall_fail_" + fid_nm
    l_done_nm = "icall_done_" + fid_nm
    l_fun_nm = "icall_fun_" + fid_nm
    l_clo_nm = "icall_clo_" + fid_nm
    l_stt_nm = "icall_stt_" + fid_nm
    l_blt_nm = "icall_blt_" + fid_nm

    state.asm = a.mov_r64_r64(state.asm, "r10", "r11")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_fail_nm)

    state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 0)
    state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_FUNCTION)
    state.asm = a.jcc(state.asm, "e", l_fun_nm)
    state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_CLOSURE)
    state.asm = a.jcc(state.asm, "e", l_clo_nm)
    state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_STRUCTTYPE)
    state.asm = a.jcc(state.asm, "e", l_stt_nm)
    state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_BUILTIN)
    state.asm = a.jcc(state.asm, "e", l_blt_nm)
    state.asm = a.jmp(state.asm, l_fail_nm)

    state.asm = a.mark(state.asm, l_fun_nm)
    state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 4)
    state.asm = a.cmp_r32_imm(state.asm, "r10d", nargs)
    state.asm = a.jcc(state.asm, "ne", l_fail_nm)
    state.asm = a.mov_r64_imm64(state.asm, "r10", t.enc_void())
    state.asm = a.call_membase_disp(state.asm, "r11", 8)
    state.asm = a.jmp(state.asm, l_done_nm)

    state.asm = a.mark(state.asm, l_clo_nm)
    state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 4)
    state.asm = a.cmp_r32_imm(state.asm, "r10d", nargs)
    state.asm = a.jcc(state.asm, "ne", l_fail_nm)
    state.asm = a.mov_r64_membase_disp(state.asm, "r10", "r11", 16)
    state.asm = a.call_membase_disp(state.asm, "r11", 8)
    state.asm = a.jmp(state.asm, l_done_nm)

    state.asm = a.mark(state.asm, l_blt_nm)
    state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 4)
    state.asm = a.cmp_r32_imm(state.asm, "r10d", nargs)
    state.asm = a.jcc(state.asm, "g", l_fail_nm)
    state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 8)
    state.asm = a.cmp_r32_imm(state.asm, "r10d", nargs)
    state.asm = a.jcc(state.asm, "l", l_fail_nm)
    state.asm = a.mov_r32_imm32(state.asm, "r10d", nargs)
    state.asm = a.call_membase_disp(state.asm, "r11", 16)
    state.asm = a.jmp(state.asm, l_done_nm)

    state.asm = a.mark(state.asm, l_stt_nm)
    state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 4)
    state.asm = a.cmp_r32_imm(state.asm, "r10d", nargs)
    state.asm = a.jcc(state.asm, "ne", l_fail_nm)

    if nargs == 2 then
      lid_err_nm = _next_lid(state)
      l_stt_norm_nm = "icall_stt_normal_" + lid_err_nm

      state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 8)
      state.asm = a.cmp_r32_imm(state.asm, "r10d", c.ERROR_STRUCT_ID)
      state.asm = a.jcc(state.asm, "ne", l_stt_norm_nm)

      state.asm = a.mov_rcx_imm32(state.asm, 48)
      state.asm = a.call(state.asm, "fn_alloc")
      state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRUCT, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, c.ERROR_STRUCT_ID, false)
      state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", base_nm + 8)
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8, "r10")
      state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", base_nm + 16)
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "r10")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_script")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 24, "rax")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_func")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 32, "rax")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_line")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 40, "rax")
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state.asm = a.jmp(state.asm, l_done_nm)

      state.asm = a.mark(state.asm, l_stt_norm_nm)
    end if

    state.asm = a.mov_rcx_imm32(state.asm, 8 + nargs * 8)
    state.asm = a.call(state.asm, "fn_alloc")
    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", base_nm)
    state.asm = a.mov_membase_disp_imm32(state.asm, "rax", 0, c.OBJ_STRUCT, false)
    state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 8)
    state.asm = a.mov_membase_disp_r32(state.asm, "rax", 4, "r10d")
    if nargs > 0 then
      for fi_nm = 0 to nargs - 1
        state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", base_nm + (fi_nm + 1) * 8)
        state.asm = a.mov_membase_disp_r64(state.asm, "rax", 8 + fi_nm * 8, "r10")
      end for
    end if
    state.asm = a.jmp(state.asm, l_done_nm)

    state.asm = a.mark(state.asm, l_fail_nm)
    lid_void_nm = _next_lid(state)
    l_not_void_nm = "icall_not_void_" + lid_void_nm
    state.asm = a.mov_r64_r64(state.asm, "r10", "r11")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_VOID)
    state.asm = a.jcc(state.asm, "ne", l_not_void_nm)
    if callee_is_member then
      state = _emit_make_error_const(state, c.ERR_CALL_NOT_CALLABLE, "'" + recv_desc + "' has no function '" + meth_desc + "'")
    else
      state = _emit_make_error_const(state, c.ERR_CALL_NOT_CALLABLE, "Cannot call void")
    end if
    state.asm = a.jmp(state.asm, l_done_nm)

    state.asm = a.mark(state.asm, l_not_void_nm)
    if callee_is_member then
      if callee_desc == "" then callee_desc = "member" end if
      lbl_pref_nm = "objstr_" + _next_lid(state)
      state.rdata = d.rdata_add_obj_string(state.rdata, lbl_pref_nm, "Cannot call '" + callee_desc + "' with " + nargs + " args (expected ")
      lbl_p3_nm = "objstr_" + _next_lid(state)
      state.rdata = d.rdata_add_obj_string(state.rdata, lbl_p3_nm, "..")
      lbl_p4_nm = "objstr_" + _next_lid(state)
      state.rdata = d.rdata_add_obj_string(state.rdata, lbl_p4_nm, ")")

      tmp_nm = base_nm + (nargs + 1) * 8
      lid_mdiag_nm = _next_lid(state)
      l_msimple_nm = "icall_mdiag_simple_" + lid_mdiag_nm
      l_mfun_nm = "icall_mdiag_fun_" + lid_mdiag_nm
      l_mblt_nm = "icall_mdiag_blt_" + lid_mdiag_nm
      l_mstt_nm = "icall_mdiag_stt_" + lid_mdiag_nm
      l_mdone_nm = "icall_mdiag_done_" + lid_mdiag_nm

      state.asm = a.mov_r64_r64(state.asm, "r10", "r11")
      state.asm = a.and_r64_imm(state.asm, "r10", 7)
      state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
      state.asm = a.jcc(state.asm, "ne", l_msimple_nm)
      state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 0)
      state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_FUNCTION)
      state.asm = a.jcc(state.asm, "e", l_mfun_nm)
      state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_CLOSURE)
      state.asm = a.jcc(state.asm, "e", l_mfun_nm)
      state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_BUILTIN)
      state.asm = a.jcc(state.asm, "e", l_mblt_nm)
      state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_STRUCTTYPE)
      state.asm = a.jcc(state.asm, "e", l_mstt_nm)
      state.asm = a.jmp(state.asm, l_msimple_nm)

      state.asm = a.mark(state.asm, l_mfun_nm)
      state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 4)
      state.asm = a.mov_r64_r64(state.asm, "r10", "r10")
      state.asm = a.shl_r64_imm8(state.asm, "r10", 3)
      state.asm = a.or_r64_imm(state.asm, "r10", c.TAG_INT)
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_nm + 8, "r10")

      state.asm = a.lea_rax_rip(state.asm, lbl_pref_nm)
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", tmp_nm + 8)
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.lea_rax_rip(state.asm, lbl_p4_nm)
      state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_nm, "rax")

      state.asm = a.mov_rcx_imm32(state.asm, 48)
      state.asm = a.call(state.asm, "fn_alloc")
      state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRUCT, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, c.ERROR_STRUCT_ID, false)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_int(c.ERR_CALL_NOT_CALLABLE))
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8, "rax")
      state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", tmp_nm)
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "r10")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_script")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 24, "rax")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_func")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 32, "rax")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_line")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 40, "rax")
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state.asm = a.jmp(state.asm, l_mdone_nm)

      state.asm = a.mark(state.asm, l_mblt_nm)
      state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 4)
      state.asm = a.mov_r64_r64(state.asm, "r10", "r10")
      state.asm = a.shl_r64_imm8(state.asm, "r10", 3)
      state.asm = a.or_r64_imm(state.asm, "r10", c.TAG_INT)
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_nm + 8, "r10")
      state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 8)
      state.asm = a.mov_r64_r64(state.asm, "r10", "r10")
      state.asm = a.shl_r64_imm8(state.asm, "r10", 3)
      state.asm = a.or_r64_imm(state.asm, "r10", c.TAG_INT)
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_nm + 16, "r10")

      state.asm = a.lea_rax_rip(state.asm, lbl_pref_nm)
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", tmp_nm + 8)
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.lea_rax_rip(state.asm, lbl_p3_nm)
      state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", tmp_nm + 16)
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.lea_rax_rip(state.asm, lbl_p4_nm)
      state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_nm, "rax")

      state.asm = a.mov_rcx_imm32(state.asm, 48)
      state.asm = a.call(state.asm, "fn_alloc")
      state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRUCT, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, c.ERROR_STRUCT_ID, false)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_int(c.ERR_CALL_NOT_CALLABLE))
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8, "rax")
      state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", tmp_nm)
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "r10")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_script")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 24, "rax")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_func")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 32, "rax")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_line")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 40, "rax")
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state.asm = a.jmp(state.asm, l_mdone_nm)

      state.asm = a.mark(state.asm, l_mstt_nm)
      state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 4)
      state.asm = a.mov_r64_r64(state.asm, "r10", "r10")
      state.asm = a.shl_r64_imm8(state.asm, "r10", 3)
      state.asm = a.or_r64_imm(state.asm, "r10", c.TAG_INT)
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_nm + 8, "r10")

      state.asm = a.lea_rax_rip(state.asm, lbl_pref_nm)
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", tmp_nm + 8)
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.lea_rax_rip(state.asm, lbl_p4_nm)
      state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
      state.asm = a.call(state.asm, "fn_add_string")
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_nm, "rax")

      state.asm = a.mov_rcx_imm32(state.asm, 48)
      state.asm = a.call(state.asm, "fn_alloc")
      state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRUCT, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, c.ERROR_STRUCT_ID, false)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_int(c.ERR_CALL_NOT_CALLABLE))
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8, "rax")
      state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", tmp_nm)
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "r10")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_script")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 24, "rax")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_func")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 32, "rax")
      state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_line")
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 40, "rax")
      state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
      state.asm = a.jmp(state.asm, l_mdone_nm)

      state.asm = a.mark(state.asm, l_msimple_nm)
      msg_simple_nm = "Cannot call '" + callee_desc + "' with " + nargs + " args"
      state = _emit_make_error_const(state, c.ERR_CALL_NOT_CALLABLE, msg_simple_nm)
      state.asm = a.mark(state.asm, l_mdone_nm)
    else
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    end if

    state.asm = a.mark(state.asm, l_done_nm)
    state = _emit_auto_errprop(state)
    if devirt_done_lbl_nm != "" then
      state.asm = a.mark(state.asm, devirt_done_lbl_nm)
    end if

    state = core.free_expr_temps(state, (nargs + 1) * 8 + diag_extra_nm)
    void_imm_nm = t.enc_void()
    if nargs > 4 then
      for clr_nm = 4 to nargs - 1
        state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20 + (clr_nm - 4) * 8, void_imm_nm, true)
      end for
    end if
    return state
  end if

end function


function _emit_expr_array_lit(state, expr)
  n = 0
  items_lit = try(expr.items)
  if typeof(items_lit) == "array" then
    items_lit = _filter_expr_list_separator_artifacts(items_lit)
    n = len(items_lit)
  end if

  imm_items = []
  all_imm = true
  if n > 0 then
    for i = 0 to n - 1
      enc = _opt_try_const_immediate_encoded(state, items_lit[i])
      if enc == 0 then
        all_imm = false
        break
      end if
      imm_items = imm_items + [enc]
    end for
  end if

  state.asm = a.mov_rcx_imm32(state.asm, 8 + n * 8)
  state.asm = a.call(state.asm, "fn_alloc")
  base_tmp = core.alloc_expr_value_temp(state, true)
  state = core.expr_value_temp_store_rax(state, base_tmp)
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")

  if all_imm then
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_ARRAY_IMM, false)
  else
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_ARRAY, false)
  end if
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, n, false)

  if n > 0 then
    if all_imm then
      for i = 0 to n - 1
        state.asm = a.mov_rax_imm64(state.asm, imm_items[i])
        state = core.expr_value_temp_load(state, "r11", base_tmp)
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8 + i * 8, "rax")
      end for
    else
      i = 0
      while i < n
        if i < 0 or i >= len(items_lit) then break end if
        state = cg_emit_expr(state, items_lit[i])
        state = core.expr_value_temp_load(state, "r11", base_tmp)
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8 + i * 8, "rax")
        i = i + 1
      end while
    end if
  end if
  state = core.expr_value_temp_load(state, "rax", base_tmp)
  state = core.free_expr_value_temp(state, base_tmp)
  return state
end function

function _emit_expr_unsupported(state, expr, k)
  loc = ""
  fn_dbg = _coerce_name(try(expr._filename))
  pos_dbg = try(expr._pos)
  if fn_dbg != "" and typeof(pos_dbg) == "int" then loc = " at " + fn_dbg + ":" + pos_dbg end if
  if fn_dbg != "" and loc == "" then loc = " at " + fn_dbg end if
  ctx_dbg = _coerce_name(try(state._debug_current_function))
  if ctx_dbg == "" then ctx_dbg = _coerce_name(try(state.current_qname_prefix)) end if
  if ctx_dbg != "" then loc = loc + " in " + ctx_dbg end if
  extra = ""
  if k == "" then
    type_dbg = typeName(expr)
    kind_dbg = _coerce_name(try(expr.kind))
    name_dbg = _coerce_name(try(expr.name))
    value_dbg = _coerce_name(try(expr.value))
    value_ty_dbg = typeof(try(expr.value))
    extra = "<missing node_kind> type=" + type_dbg + " kind=" + kind_dbg + " name=" + name_dbg + " value_type=" + value_ty_dbg + " value=" + value_dbg
  else
    value_dbg2 = _coerce_name(try(expr.value))
    kind_dbg2 = _coerce_name(try(expr.kind))
    extra = k
    if kind_dbg2 != "" or value_dbg2 != "" then
      extra = extra + " kind=" + kind_dbg2 + " value=" + value_dbg2
    end if
  end if
  state.diagnostics = state.diagnostics +["Unsupported expression type: " + extra + loc]
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

function _qname_of(state, ex)
  if typeof(ex) != "struct" then return "" end if

  ex_kind = _coerce_name(try(ex.node_kind))
  if ex_kind == "Var" then
    return _qualify_identifier(state, _coerce_name(try(ex.name)))
  end if

  if ex_kind != "Member" then return "" end if

  parts2 = _qname_parts_any(ex)
  if typeof(parts2) != "array" or len(parts2) <= 0 then return "" end if

  full = s.join(parts2, ".")
  full_m = _apply_import_alias(state, full)

  base0 = _coerce_name(parts2[0])
  b0 = scope.cg_resolve_binding(state, base0)
  kind0 = ""
  if typeof(b0) == "struct" then kind0 = _coerce_name(b0.kind) end if
  base_localish = typeof(b0) == "struct" and kind0 != "" and kind0 != "global"
  if base_localish == false and _is_current_localish_name(state, base0) then base_localish = true end if
  if base_localish then return "" end if

  meth = _coerce_name(parts2[len(parts2) - 1])
  struct_qn = ""
  if len(parts2) >= 2 then
    for pi = 0 to len(parts2) - 2
      if struct_qn != "" then struct_qn = struct_qn + "." end if
      struct_qn = struct_qn + _coerce_name(parts2[pi])
    end for
  end if
  struct_qn_m = _apply_import_alias(state, struct_qn)

  sqs = _qname_with_prefixes(state, struct_qn_m)
  if typeof(sqs) == "array" and len(sqs) > 0 then
    for sqi = 0 to len(sqs) - 1
      md = _state_struct_static_methods_get(state, sqs[sqi])
      if (typeof(md) == "array" and len(md) > 0) or typeof(md) == "struct" then
        fn_qn = _method_map_get(md, meth)
        if fn_qn != "" then return fn_qn end if
      end if
    end for
  end if

  is_struct_type_ref = false
  if typeof(sqs) == "array" and len(sqs) > 0 then
    for sqi2 = 0 to len(sqs) - 1
      if typeof(_state_struct_fields_get(state, sqs[sqi2])) == "array" then
        if base_localish == false then is_struct_type_ref = true end if
        break
      end if
    end for
  end if

  alias_target0 = ""
  if typeof(state.import_aliases) == "array" then
    alias_target0 = _alias_lookup_array_exact(state.import_aliases, base0)
  else
    if typeof(state.import_alias_index) == "struct" then
      at0 = t.fastmap_get(state.import_alias_index, base0, "")
      if typeof(at0) == "string" then alias_target0 = at0 end if
    end if
    if alias_target0 == "" then
      alias_target0 = _alias_lookup(state.import_aliases, base0)
    end if
  end if

  if base_localish == false and alias_target0 == "" and _has_any_global_prefix(state, base0) == false then
    base_known_static = false
    base_cands0 = _qname_with_prefixes(state, base0)
    if typeof(base_cands0) == "array" and len(base_cands0) > 0 then
      for bci0 = 0 to len(base_cands0) - 1
        bq0 = _coerce_name(base_cands0[bci0])
        if bq0 == "" then continue end if
        if typeof(_state_struct_fields_get(state, bq0)) == "array" then
          base_known_static = true
          break
        end if
        if _state_enum_id_get(state, bq0, -1) >= 0 then
          base_known_static = true
          break
        end if
        bmd0 = _state_struct_static_methods_get(state, bq0)
        if typeof(bmd0) == "struct" then
          base_known_static = true
          break
        end if
        if typeof(bmd0) == "array" and len(bmd0) > 0 then
          base_known_static = true
          break
        end if
      end for
    end if
    if base_known_static == false then return "" end if
  end if

  full_cands = _qname_with_prefixes(state, full_m)
  if alias_target0 != "" and base_localish == false then
    if typeof(full_cands) == "array" and len(full_cands) > 0 then
      for fci = 0 to len(full_cands) - 1
        if _qname_exists(state, full_cands[fci]) then return full_cands[fci] end if
      end for
    end if
    return ""
  end if

  if is_struct_type_ref then
    if typeof(full_cands) == "array" and len(full_cands) > 0 then
      for fci2 = 0 to len(full_cands) - 1
        if _qname_exists(state, full_cands[fci2]) then return full_cands[fci2] end if
      end for
    end if
    return ""
  end if

  if typeof(b0) == "struct" then return "" end if

  if typeof(full_cands) == "array" and len(full_cands) > 0 then
    for fci3 = 0 to len(full_cands) - 1
      if _qname_exists(state, full_cands[fci3]) then return full_cands[fci3] end if
    end for
  end if

  return ""
end function

function _qname_with_prefixes(state, qname)
  if typeof(qname) != "string" or qname == "" then return [] end if
  vals_b = t.arr_chunk_new(4)
  vals_b = t.arr_chunk_push(vals_b, qname)
  vals = t.arr_chunk_finish(vals_b)

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
  if typeof(_user_function_get(state, qname)) == "struct" then return true end if
  if typeof(_extern_sig_get(state, qname)) == "struct" then return true end if
  if typeof(_state_struct_fields_get(state, qname)) == "array" then return true end if
  if _state_enum_id_get(state, qname, -1) >= 0 then return true end if
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
    if typeof(md) == "struct" then
      md_items = t.fastmap_items(md)
      if typeof(md_items) == "array" and len(md_items) > 0 then
        for j = 0 to len(md_items) - 1
          entm = md_items[j]
          fnq2 = ""
          if typeof(entm) == "array" and len(entm) >= 2 then fnq2 = _coerce_name(entm[1]) end if
          if fnq2 == qname then return true end if
        end for
      end if
      continue
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
  k = _coerce_name(try(ex.node_kind))
  if k == "Var" and typeof(try(ex.name)) == "string" and try(ex.name) == "this" then
    return true
  end if
  if k == "IsType" then
    return _expr_has_this(try(ex.expr))
  end if
  if k == "Member" then
    mt = try(ex.target)
    if typeof(mt) != "struct" then mt = try(ex.obj) end if
    if _expr_has_this(mt) then return true end if
  end if
  if k == "Unary" then
    return _expr_has_this(try(ex.right))
  end if
  if k == "Bin" then
    return _expr_has_this(try(ex.left)) or _expr_has_this(try(ex.right))
  end if
  if k == "Call" then
    cal = try(ex.callee)
    if typeof(cal) != "struct" then cal = try(ex.func) end if
    if _expr_has_this(cal) then return true end if
    args = try(ex.args)
    if typeof(args) == "array" and len(args) > 0 then
      for i = 0 to len(args) - 1
        if _expr_has_this(args[i]) then return true end if
      end for
    end if
  end if
  if k == "Index" then
    return _expr_has_this(try(ex.target)) or _expr_has_this(try(ex.index))
  end if
  if k == "ArrayLit" then
    items = try(ex.items)
    if typeof(items) == "array" and len(items) > 0 then
      for ai = 0 to len(items) - 1
        if _expr_has_this(items[ai]) then return true end if
      end for
    end if
    return false
  end if
  if k == "StructInit" then
    values = try(ex.values)
    if typeof(values) == "array" and len(values) > 0 then
      for si = 0 to len(values) - 1
        if _expr_has_this(values[si]) then return true end if
      end for
    end if
    return false
  end if
  return false
end function

function _stmt_has_this(st)
  if typeof(st) != "struct" then return false end if
  k = _coerce_name(try(st.node_kind))

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
  cached_uses_this = try(fn_node._ml_uses_this)
  if typeof(cached_uses_this) == "bool" then return cached_uses_this end if
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
  if _coerce_name(try(node.node_kind)) == "FunctionDef" then return true end if

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
  target = try(node.target)
  if typeof(target) == "struct" then
    if _contains_nested_fn(target) then return true end if
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

  lbl = "objstr_" + _next_lid(state)
  state.rdata = d.rdata_add_obj_string(state.rdata, lbl, msg)

  state.asm = a.mov_rcx_imm32(state.asm, 48)
  state.asm = a.call(state.asm, "fn_alloc")
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")

  // header: type / struct_id
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRUCT, false)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, c.ERROR_STRUCT_ID, false)

  // field0 = code
  state.asm = a.mov_rax_imm64(state.asm, t.enc_int(err_code))
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8, "rax")

  // field1 = message
  state.asm = a.lea_rax_rip(state.asm, lbl)
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "rax")

  // field2 = script
  state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_script")
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 24, "rax")

  // field3 = func
  state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_func")
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 32, "rax")

  // field4 = line
  state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_line")
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 40, "rax")

  state.asm = a.mov_rax_r11(state.asm)
  return state
end function

function _emit_auto_errprop(state)
  sup = 0
  if typeof(state.errprop_suppression) == "int" then sup = state.errprop_suppression end if
  if sup > 0 then return state end if

  lid = _next_lid(state)
  l_noerr = "errprop_noerr_" + lid
  l_cold = "errprop_cold_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_noerr)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_STRUCT)
  state.asm = a.jcc(state.asm, "ne", l_noerr)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "rax", 4)
  state.asm = a.cmp_r32_imm(state.asm, "r10d", c.ERROR_STRUCT_ID)
  state.asm = a.jcc(state.asm, "ne", l_noerr)

  if core.defer_cold_block(state, l_cold, _emit_auto_errprop_cold_block) then
    state.asm = a.jmp(state.asm, l_cold)
  else
    if state.in_function and typeof(state.func_ret_label) == "string" and state.func_ret_label != "" then
      state.asm = a.jmp(state.asm, state.func_ret_label)
    else
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.call(state.asm, "fn_unhandled_error_exit")
    end if
  end if

  state.asm = a.mark(state.asm, l_noerr)
  return state
end function

function _emit_auto_errprop_cold_block(state)
  if state.in_function and typeof(state.func_ret_label) == "string" and state.func_ret_label != "" then
    state.asm = a.jmp(state.asm, state.func_ret_label)
  else
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, "fn_unhandled_error_exit")
  end if
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
    cal = try(call_node.callee)
    if typeof(cal) != "struct" then cal = try(call_node.func) end if
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

  state.asm = a.call_rip_qword(state.asm, _extern_iat_label(dll, sym))
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
    enc = t.try_enc_float_immediate(value)
    if typeof(enc) == "int" then
      state.asm = a.mov_rax_imm64(state.asm, enc)
    else
      lbl = "cflt_" + _next_lid(state)
      state.rdata = d.rdata_add_obj_float(state.rdata, lbl, value)
      state.asm = a.lea_rax_rip(state.asm, lbl)
    end if
    return state
  end if
  if tv == "string" then
    lbl2 = "cstr_" + _next_lid(state)
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
    stub_lbl = _strpair_get(state.extern_stub_labels, qn)
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

    state.asm = a.call_rip_qword(state.asm, _extern_iat_label(dll, sym))
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
