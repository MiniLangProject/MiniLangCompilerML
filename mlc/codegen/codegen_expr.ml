// Lowers MiniLang expressions, calls, constants and native interop to x64.
package mlc.codegen.codegen_expr
import std.string as s
import mlc.asm as a
import mlc.constants as c
import mlc.tools as t
import mlc.data as d
import mlc.minilang_parser as ml
import mlc.codegen.codegen_scope as scope
import mlc.codegen.codegen_core as core
import mlc.codegen.codegen_memory as mem
import mlc.codegen.codegen_threads as th

// Explicit success/value envelope for compile-time expression evaluation.
struct ConstEvalResult
  ok,
  value,
end struct

// Cost and control-flow summary used by the bounded inliner.
struct InlineStats
  cost,
  stmt_count,
  call_count,
  branch_count,
  max_call_args,
  has_loop,
  has_switch,
  has_nested_fn,
end struct

struct ArgNormalizeResult
  ok,
  args,
  message,
end struct

function _variadic_is_direct_var(ex, name)
  return t.ast_is_node(ex) and t.ast_kind(ex) == "Var" and _coerce_name(t.ast_name(ex)) == name
end function

function _variadic_expr_safe(ex, name, allow_direct)
  if typeof(ex) == "void" or ex == 0 then return true end if
  if t.ast_is_node(ex) == false then return true end if
  kind = _coerce_name(t.ast_kind(ex))
  if kind == "Var" then
    if _coerce_name(t.ast_name(ex)) == name then return allow_direct end if
    return true
  end if
  if kind == "Index" then
    return _variadic_expr_safe(try(ex.target), name, true) and _variadic_expr_safe(try(ex.index), name, false)
  end if
  if kind == "Call" then
    callee = try(ex.callee)
    args = try(ex.args)
    if typeof(args) != "array" then args = [] end if
    callee_name = ""
    if t.ast_is_node(callee) and t.ast_kind(callee) == "Var" then callee_name = _coerce_name(t.ast_name(callee)) end if
    if (callee_name == "len" or callee_name == "typeof" or callee_name == "typeName") and len(args) == 1 and _variadic_is_direct_var(args[0], name) then return true end if
    if _variadic_expr_safe(callee, name, false) == false then return false end if
    if len(args) > 0 then
      for i = 0 to len(args) - 1
        if _variadic_expr_safe(args[i], name, false) == false then return false end if
      end for
    end if
    return true
  end if
  if kind == "Bin" then return _variadic_expr_safe(t.ast_left(ex), name, false) and _variadic_expr_safe(t.ast_right(ex), name, false) end if
  if kind == "Unary" then return _variadic_expr_safe(t.ast_right(ex), name, false) end if
  if kind == "IsType" or kind == "TypeGuard" then return _variadic_expr_safe(try(ex.expr), name, false) end if
  if kind == "Member" or kind == "SafeMember" then return _variadic_expr_safe(try(ex.target), name, false) end if
  if kind == "ArrayLit" then
    items = try(ex.items)
    if typeof(items) == "array" and len(items) > 0 then
      for i = 0 to len(items) - 1
        if _variadic_expr_safe(items[i], name, false) == false then return false end if
      end for
    end if
    return true
  end if
  // Unknown expression shapes are safe only if their common child slots do
  // not contain the variadic parameter directly or transitively.
  if _variadic_expr_safe(try(ex.expr), name, false) == false then return false end if
  if _variadic_expr_safe(try(ex.target), name, false) == false then return false end if
  if _variadic_expr_safe(try(ex.index), name, false) == false then return false end if
  return true
end function

function _variadic_stmts_safe(body, name)
  if typeof(body) != "array" or len(body) <= 0 then return true end if
  for i = 0 to len(body) - 1
    st = body[i]
    if typeof(st) != "struct" then continue end if
    kind = _coerce_name(t.ast_kind(st))
    if kind == "Assign" or kind == "ConstDecl" or kind == "SynchronizedDecl" then
      if _coerce_name(try(st.name)) == name or _variadic_expr_safe(try(st.expr), name, false) == false then return false end if
    else if kind == "Return" or kind == "Yield" or kind == "Defer" or kind == "ExprStmt" or kind == "Print" then
      if _variadic_expr_safe(try(st.expr), name, false) == false then return false end if
    else if kind == "SetIndex" then
      if _variadic_is_direct_var(try(st.target), name) then return false end if
      if _variadic_expr_safe(try(st.target), name, false) == false or _variadic_expr_safe(try(st.index), name, false) == false or _variadic_expr_safe(try(st.expr), name, false) == false then return false end if
    else if kind == "SetMember" then
      if _variadic_expr_safe(try(st.obj), name, false) == false or _variadic_expr_safe(try(st.expr), name, false) == false then return false end if
    else if kind == "ForEach" then
      if _variadic_expr_safe(try(st.iterable), name, true) == false or _variadic_stmts_safe(try(st.body), name) == false then return false end if
      continue
    else
      if _variadic_expr_safe(try(st.expr), name, false) == false or _variadic_expr_safe(try(st.cond), name, false) == false or _variadic_expr_safe(try(st.start), name, false) == false or _variadic_expr_safe(try(st.end_expr), name, false) == false or _variadic_expr_safe(try(st.iterable), name, false) == false or _variadic_expr_safe(try(st.lock), name, false) == false then return false end if
    end if
    if kind == "If" then
      if _variadic_stmts_safe(try(st.then_body), name) == false or _variadic_stmts_safe(try(st.else_body), name) == false then return false end if
      elifs = try(st.elifs)
      if typeof(elifs) == "array" and len(elifs) > 0 then
        for j = 0 to len(elifs) - 1
          if _variadic_expr_safe(elifs[j][0], name, false) == false or _variadic_stmts_safe(elifs[j][1], name) == false then return false end if
        end for
      end if
    else if kind == "Switch" then
      cases = try(st.cases)
      if typeof(cases) == "array" and len(cases) > 0 then
        for j = 0 to len(cases) - 1
          if _variadic_stmts_safe(try(cases[j].body), name) == false then return false end if
        end for
      end if
      if _variadic_stmts_safe(try(st.default_body), name) == false then return false end if
    else if kind != "ForEach" then
      nested = try(st.body)
      if typeof(nested) == "array" and _variadic_stmts_safe(nested, name) == false then return false end if
    end if
  end for
  return true
end function

function _variadic_param_stack_safe(fn)
  if typeof(fn) != "struct" then return false end if
  index = try(fn.variadic_index)
  params = try(fn.params)
  if typeof(index) != "int" or index < 0 or typeof(params) != "array" or index >= len(params) then return false end if
  return _variadic_stmts_safe(try(fn.body), _coerce_name(params[index]))
end function

function _normalize_declared_call_args(expr, fn, implicit)
  supplied = try(expr.args)
  if typeof(supplied) != "array" then supplied = [] end if
  names = try(expr.arg_names)
  if typeof(names) != "array" then names = [] end if
  params_all = try(fn.params)
  if typeof(params_all) != "array" then params_all = [] end if
  defaults_all = try(fn.param_defaults)
  if typeof(defaults_all) != "array" then defaults_all = [] end if
  params = []
  defaults = []
  if implicit < len(params_all) then
    for i = implicit to len(params_all) - 1
      params = params + [params_all[i]]
      dv = void
      if i < len(defaults_all) then dv = defaults_all[i] end if
      defaults = defaults + [dv]
    end for
  end if
  raw_variadic = try(fn.variadic_index)
  if typeof(raw_variadic) != "int" then raw_variadic = -1 end if
  variadic = -1
  if raw_variadic >= implicit then variadic = raw_variadic - implicit end if
  fixed_count = len(params)
  if variadic >= 0 then fixed_count = variadic end if
  slots = array(fixed_count, void)
  extras = []
  next_pos = 0
  used_names = []
  if len(supplied) > 0 then
    for i = 0 to len(supplied) - 1
      arg_name = void
      if i < len(names) then arg_name = names[i] end if
      if typeof(arg_name) != "string" then
        while next_pos < fixed_count and typeof(slots[next_pos]) != "void"
          next_pos = next_pos + 1
        end while
        if next_pos < fixed_count then
          slots[next_pos] = supplied[i]
          next_pos = next_pos + 1
        else if variadic >= 0 then
          extras = extras + [supplied[i]]
        else
          return ArgNormalizeResult(false, [], "Function " + fn.name + " expects " + len(params) + " args, got " + len(supplied))
        end if
        continue
      end if
      duplicate_name = false
      if len(used_names) > 0 then
        for ui = 0 to len(used_names) - 1
          if used_names[ui] == arg_name then duplicate_name = true break end if
        end for
      end if
      if duplicate_name then return ArgNormalizeResult(false, [], "Argument '" + arg_name + "' was supplied more than once") end if
      used_names = used_names + [arg_name]
      index = -1
      if len(params) > 0 then
        for j = 0 to len(params) - 1
          if params[j] == arg_name then index = j break end if
        end for
      end if
      if index < 0 then return ArgNormalizeResult(false, [], "Unknown named argument '" + arg_name + "' for " + fn.name) end if
      if index == variadic then return ArgNormalizeResult(false, [], "Variadic parameter '" + arg_name + "' cannot be supplied by name") end if
      if index >= fixed_count or typeof(slots[index]) != "void" then return ArgNormalizeResult(false, [], "Argument '" + arg_name + "' was supplied more than once") end if
      slots[index] = supplied[i]
    end for
  end if
  if fixed_count > 0 then
    for i = 0 to fixed_count - 1
      if typeof(slots[i]) == "void" then
        default_value = void
        if i < len(defaults) then default_value = defaults[i] end if
        if typeof(default_value) == "void" then return ArgNormalizeResult(false, [], "Missing required argument '" + params[i] + "' for " + fn.name) end if
        slots[i] = default_value
      end if
    end for
  end if
  if variadic >= 0 then
    tail = ml.ArrayLit("ArrayLit", extras, false, try(expr._pos), try(expr._filename))
    if implicit == 0 and _variadic_param_stack_safe(fn) then tail.stack_variadic = true end if
    slots = slots + [tail]
  end if
  return ArgNormalizeResult(true, slots, "")
end function

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

function inline _state_struct_field_types_get(state, key)
  return _state_named_array_get(0, state.struct_field_types, key)
end function

function inline _state_struct_methods_get(state, key)
  return _state_named_array_get(state.struct_methods_index, state.struct_methods, key)
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
    gl_count = 0
    if t.arr_vec_is(gls) then
      gl_count = t.arr_vec_count(gls)
    else if typeof(gls) == "array" then
      gl_count = len(gls)
    end if
    if gl_count > 0 then
      for i = 0 to gl_count - 1
        g = void
        if t.arr_vec_is(gls) then g = t.arr_vec_get(gls, i, void) else g = gls[i] end if
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
  if nm == "copyArray" then return "fn_builtin_copyArray" end if
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

function _native_callback_resolve_user_fn(state, ex)
  qn = _expr_to_qualname(state, ex)
  if qn == "" then return "" end if
  qn = _apply_import_alias(state, qn)
  if typeof(_user_function_get(state, qn)) == "struct" then return qn end if
  cands = _qname_with_prefixes(state, qn)
  if typeof(cands) == "array" and len(cands) > 0 then
    for i = 0 to len(cands) - 1
      cand = _coerce_name(cands[i])
      if cand == "" then continue end if
      if typeof(_user_function_get(state, cand)) == "struct" then return cand end if
    end for
  end if
  return ""
end function

function _emit_native_callback_ret_lresult(state, l_zero, l_done)
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
  state.asm = a.and_r64_imm(state.asm, "r11", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r11", c.TAG_INT)
  state.asm = a.jcc(state.asm, "e", l_zero + "_int")
  state.asm = a.cmp_r64_imm(state.asm, "r11", c.TAG_BOOL)
  state.asm = a.jcc(state.asm, "e", l_zero + "_bool")
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_zero + "_int")
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_zero + "_bool")
  state.asm = a.shr_r64_imm8(state.asm, "rax", 3)
  state.asm = a.jmp(state.asm, l_done)
  return state
end function

function _emit_native_callback_wndproc(state, fn_qn)
  fn = _user_function_get(state, fn_qn)
  if typeof(fn) != "struct" then
    state.diagnostics = state.diagnostics + ["nativeCallback: unknown function '" + fn_qn + "'"]
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return state
  end if
  ar = 0
  if typeof(fn.params) == "array" then ar = len(fn.params) end if
  if ar != 4 then
    state.diagnostics = state.diagnostics + ["nativeCallback: wndproc callback '" + fn_qn + "' must accept exactly 4 parameters"]
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return state
  end if

  lid = _next_lid(state)
  cb_lbl = "native_cb_wndproc_" + lid
  after_lbl = "native_cb_after_" + lid
  ret_zero_lbl = "native_cb_ret_" + lid
  ret_done_lbl = "native_cb_ret_done_" + lid

  state.asm = a.lea_rax_rip(state.asm, cb_lbl)
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
  state.asm = a.jmp(state.asm, after_lbl)

  state.asm = a.mark(state.asm, cb_lbl)
  state.asm = a.push_reg(state.asm, "rbx")
  state.asm = a.push_reg(state.asm, "rbp")
  state.asm = a.push_reg(state.asm, "rsi")
  state.asm = a.push_reg(state.asm, "rdi")
  state.asm = a.push_reg(state.asm, "r12")
  state.asm = a.push_reg(state.asm, "r13")
  state.asm = a.push_reg(state.asm, "r14")
  state.asm = a.push_reg(state.asm, "r15")
  state.asm = a.sub_rsp_imm8(state.asm, 40)

  // Convert WNDPROC(HWND, UINT, WPARAM, LPARAM) to MiniLang int values.
  state.asm = a.shl_r64_imm8(state.asm, "rcx", 3)
  state.asm = a.or_r64_imm8(state.asm, "rcx", c.TAG_INT)
  state.asm = a.shl_r64_imm8(state.asm, "rdx", 3)
  state.asm = a.or_r64_imm8(state.asm, "rdx", c.TAG_INT)
  state.asm = a.shl_r64_imm8(state.asm, "r8", 3)
  state.asm = a.or_r64_imm8(state.asm, "r8", c.TAG_INT)
  state.asm = a.shl_r64_imm8(state.asm, "r9", 3)
  state.asm = a.or_r64_imm8(state.asm, "r9", c.TAG_INT)
  state.asm = a.mov_r64_imm64(state.asm, "r10", t.enc_void())
  state.asm = a.call(state.asm, "fn_user_" + fn_qn)

  state = _emit_native_callback_ret_lresult(state, ret_zero_lbl, ret_done_lbl)

  state.asm = a.mark(state.asm, ret_done_lbl)
  state.asm = a.add_rsp_imm8(state.asm, 40)
  state.asm = a.pop_reg(state.asm, "r15")
  state.asm = a.pop_reg(state.asm, "r14")
  state.asm = a.pop_reg(state.asm, "r13")
  state.asm = a.pop_reg(state.asm, "r12")
  state.asm = a.pop_reg(state.asm, "rdi")
  state.asm = a.pop_reg(state.asm, "rsi")
  state.asm = a.pop_reg(state.asm, "rbp")
  state.asm = a.pop_reg(state.asm, "rbx")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, after_lbl)
  return state
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
  while t.ast_kind(cur) == "Member"
    nxt = try(cur.target)
    obj = try(cur.obj)
    if typeof(nxt) != "struct" and typeof(obj) == "struct" then nxt = obj end if
    cur = nxt
  end while
  if t.ast_kind(cur) != "Var" then return false end if
  base = _coerce_name(t.ast_name(cur))
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
    if typeof(hitq) == "string" then
      // A previous unresolved lookup may have fallen back to the raw name.
      // Function analysis installs explicit global bindings incrementally, so
      // only reuse cache entries that still resolve to a binding or symbol.
      hitb = scope.cg_resolve_binding(state, hitq)
      if typeof(hitb) == "struct" or _compile_symbol_has(state, hitq) then return hitq end if
    end if
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

  // Do not cache an unresolved raw fallback: a later `global` declaration in
  // the same analysis scope can make the package-qualified candidate valid.
  return n1
end function

function _expr_to_qualname(state, expr)
  if t.ast_is_node(expr) == false then return "" end if
  qn0 = _qname_of(state, expr)
  if typeof(qn0) == "string" and qn0 != "" then return qn0 end if
  k0 = _coerce_name(t.ast_kind(expr))
  if k0 == "Var" and typeof(t.ast_name(expr)) == "string" then
    nm = t.ast_name(expr)
    if s.contains(nm, ".") then return _qualify_identifier(state, _apply_import_alias(state, nm)) end if
    b = scope.cg_resolve_binding(state, nm)
    if typeof(b) == "struct" then return nm end if
    if _has_any_global_prefix(state, nm) then return nm end if
    return _qualify_identifier(state, nm)
  end if
  if k0 == "Member" then
    mt = try(expr.target)
    if t.ast_is_node(mt) == false then mt = try(expr.obj) end if
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

function _cg_expr_try_const_value(state, expr, preserve_unary_float)
  if t.ast_is_node(expr) == false then return ConstEvalResult(false, 0) end if

  k = _coerce_name(t.ast_kind(expr))

  if k == "Num" or k == "Str" or k == "Bool" then
    return ConstEvalResult(true, t.ast_value(expr))
  end if

  if k == "Var" then
    raw_nm = _coerce_name(t.ast_name(expr))
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
    rv = _cg_expr_try_const_value(state, t.ast_right(expr), preserve_unary_float)
    if rv.ok == false then return ConstEvalResult(false, 0) end if
    opu = _coerce_name(t.ast_op(expr))
    if opu == "not" then return ConstEvalResult(true, not _opt_truthy(rv.value)) end if
    if opu == "-" then
      if _is_number_no_bool(rv.value) == false then return ConstEvalResult(false, 0) end if
      if preserve_unary_float and typeof(rv.value) == "float" then
        // MiniLang arithmetic normalizes exact integral float results to int.
        // Const evaluation must preserve Python's unary-minus float type so
        // both compilers encode values such as `-16.0` identically.
        encf = t.try_enc_float_immediate(rv.value)
        if typeof(encf) == "int" then
          return ConstEvalResult(true, nativeValueFromRaw(encf ^ (1 << 34)))
        end if
        return ConstEvalResult(true, toFloat(0 - rv.value))
      end if
      return ConstEvalResult(true, 0 - rv.value)
    end if
    if opu == "~" then
      if _is_int_no_bool(rv.value) == false then return ConstEvalResult(false, 0) end if
      return ConstEvalResult(true, ~rv.value)
    end if
    return ConstEvalResult(false, 0)
  end if

  if k == "Bin" then
    lv = _cg_expr_try_const_value(state, t.ast_left(expr), preserve_unary_float)
    if lv.ok == false then return ConstEvalResult(false, 0) end if

    opb = _coerce_name(t.ast_op(expr))
    if opb == "and" and _opt_truthy(lv.value) == false then
      return ConstEvalResult(true, false)
    end if
    if opb == "or" and _opt_truthy(lv.value) then
      return ConstEvalResult(true, true)
    end if

    rv = _cg_expr_try_const_value(state, t.ast_right(expr), preserve_unary_float)
    if rv.ok == false then return ConstEvalResult(false, 0) end if
    return _try_const_bin(opb, lv.value, rv.value)
  end if

  return ConstEvalResult(false, 0)
end function

function _opt_try_const_immediate_encoded(state, expr)
  cv = cg_expr_try_const_value(state, expr)
  if cv.ok == false then return 0 end if
  if typeof(cv.value) == "bool" then return t.enc_bool(cv.value) end if
  if typeof(cv.value) == "int" then
    if cv.value < -144115188075855872 or cv.value > 144115188075855871 then return 0 end if
    return t.enc_int(cv.value)
  end if
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

  if t.ast_kind(expr) == "VoidLit" then
    return "obj_type_void"
  end if
  fact = _opt_expr_known_type(state, expr)
  base = _opt_type_base(fact)
  if base == "int" then return "obj_type_int" end if
  if base == "float" then return "obj_type_float" end if
  if base == "bool" then return "obj_type_bool" end if
  if base == "string" then return "obj_type_string" end if
  if base == "array" then return "obj_type_array" end if
  if base == "bytes" then return "obj_type_bytes" end if
  if base == "struct" then
    if detailed then
      colon = -1
      for i = 0 to len(fact) - 1 if fact[i] == ":" then colon = i; break end if end for
      if colon >= 0 then
        qname = s.substr(fact, colon + 1, len(fact) - colon - 1)
        label = _strpair_get(state.typename_struct_by_qname, qname)
        if label != "" then return label end if
      end if
    end if
    return "obj_type_struct"
  end if
  return ""
end function

function _qname_parts_any(expr)
  if t.ast_is_node(expr) == false then return 0 end if
  k = _coerce_name(t.ast_kind(expr))
  if k == "Var" then
    nm = _coerce_name(t.ast_name(expr))
    if nm == "" then return 0 end if
    return s.split(nm, ".")
  end if
  if k == "Member" then
    // The self-hosted parser's Member AST has `target`/`name`. `obj` belongs
    // to SetMember and cannot be probed safely on a Member struct at runtime.
    tgt2 = try(expr.target)
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
  if callee_name != "std.math.floor" and callee_name != "std.math.ceil" and callee_name != "std.math.trunc" and callee_name != "std.math.round" then
    return [state, false]
  end if

  lid = _next_lid(state)
  l_float = "math_float_" + lid
  l_fail = "math_fail_" + lid
  l_done = "math_done_" + lid

  state = cg_emit_expr(state, arg)
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
  state.asm = a.jcc(state.asm, "e", l_done)
  state = core.emit_to_double_xmm(state, 0, l_fail)
  state.asm = a.jmp(state.asm, l_float)

  state.asm = a.mark(state.asm, l_float)
  if callee_name == "std.math.floor" then
    l_exact_floor = "math_floor_exact_" + lid
    state.asm = a.roundsd_xmm_xmm_imm8(state.asm, "xmm1", "xmm0", 1)
    state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm1")
    state.asm = a.jcc(state.asm, "e", l_exact_floor)
    state.asm = a.movapd_xmm_xmm(state.asm, "xmm0", "xmm1")
    state = core.emit_normalize_xmm0_to_value(state)
    state.asm = a.jmp(state.asm, l_done)
    state.asm = a.mark(state.asm, l_exact_floor)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.jmp(state.asm, l_done)
  end if

  if callee_name == "std.math.ceil" then
    l_exact_ceil = "math_ceil_exact_" + lid
    state.asm = a.roundsd_xmm_xmm_imm8(state.asm, "xmm1", "xmm0", 2)
    state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm1")
    state.asm = a.jcc(state.asm, "e", l_exact_ceil)
    state.asm = a.movapd_xmm_xmm(state.asm, "xmm0", "xmm1")
    state = core.emit_normalize_xmm0_to_value(state)
    state.asm = a.jmp(state.asm, l_done)
    state.asm = a.mark(state.asm, l_exact_ceil)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.jmp(state.asm, l_done)
  end if

  if callee_name == "std.math.trunc" then
    state.asm = a.roundsd_xmm_xmm_imm8(state.asm, "xmm0", "xmm0", 3)
    state = core.emit_normalize_xmm0_to_value(state)
    state.asm = a.jmp(state.asm, l_done)
  end if

  if callee_name == "std.math.round" then
    l_nonneg = "math_round_nonneg_" + lid
    state.asm = a.xorpd_xmm_xmm(state.asm, "xmm2", "xmm2")
    state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm2")
    // The +0.5 bit pattern exceeds MiniLang's tagged-int range. Emit its two
    // 32-bit halves directly so self-hosting preserves every immediate bit.
    state.asm = a.mov_rax_u64_hi_lo_exact(state.asm, 0x3FE00000, 0)
    state.asm = a.movq_xmm_r64(state.asm, "xmm1", "rax")
    state.asm = a.jcc(state.asm, "ae", l_nonneg)
    state.asm = a.subsd_xmm_xmm(state.asm, "xmm0", "xmm1")
    state.asm = a.roundsd_xmm_xmm_imm8(state.asm, "xmm0", "xmm0", 2)
    state = core.emit_normalize_xmm0_to_value(state)
    state.asm = a.jmp(state.asm, l_done)
    state.asm = a.mark(state.asm, l_nonneg)
    state.asm = a.addsd_xmm_xmm(state.asm, "xmm0", "xmm1")
    state.asm = a.roundsd_xmm_xmm_imm8(state.asm, "xmm0", "xmm0", 1)
    state = core.emit_normalize_xmm0_to_value(state)
    state.asm = a.jmp(state.asm, l_done)
  end if

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.mark(state.asm, l_done)
  return [state, true]
end function

function cg_expr_try_const_value(state, expr)
  // Optimizer folding follows runtime arithmetic normalization.
  return _cg_expr_try_const_value(state, expr, false)
end function

function cg_expr_try_const_decl_value(state, expr)
  // Declaration constexpr evaluation matches Python's source-value typing.
  return _cg_expr_try_const_value(state, expr, true)
end function

function _extern_struct_get(state, qname)
  xs = state.extern_abi_structs
  if typeof(xs) != "array" or len(xs) <= 0 then return 0 end if
  for esi = 0 to len(xs) - 1
    it = xs[esi]
    if typeof(it) == "struct" and _coerce_name(try(it.qname)) == qname then return it end if
  end for
  return 0
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
  if t.ast_is_node(expr) == false then
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return state
  end if

  k = _coerce_name(t.ast_kind(expr))
  if k == "" and typeof(expr) == "struct" then k = _coerce_name(try(expr.kind)) end if

  if k == "COMMA" then
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return state
  end if

  // Compiler-internal operand used by the defer epilogue.  The captured
  // MiniLang value lives in the current function's published root range.
  if k == "DeferredCapture" then
    state.asm = a.mov_rax_rsp_disp32(state.asm, try(expr.offset))
    return state
  end if

  if k == "Coalesce" then return _emit_expr_coalesce(state, expr) end if
  if k == "SafeMember" then return _emit_expr_safe_member(state, expr) end if
  if k == "TypeGuard" then return _emit_expr_type_guard(state, expr) end if

  // Constant folding must precede the node-kind dispatch. Keeping it after the
  // known expression cases made it unreachable for every foldable AST node
  // (notably unary literals and constant arithmetic), unlike the Python backend.
  cv = cg_expr_try_const_value(state, expr)
  if cv.ok then
    return _opt_emit_const_value(state, cv.value)
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
    if t.ast_kind(expr.callee) == "SafeMember" then return _emit_expr_safe_call(state, expr) end if
    return _emit_expr_call(state, expr)
  end if

  if k == "ArrayLit" then
    return _emit_expr_array_lit(state, expr)
  end if

  return _emit_expr_unsupported(state, expr, k)
end function

function _emit_expr_coalesce(state, expr)
  lid = _next_lid(state)
  l_done = "coalesce_done_" + lid
  state = cg_emit_expr(state, expr.left)
  state.asm = a.cmp_rax_imm8(state.asm, t.enc_void())
  state.asm = a.jcc(state.asm, "ne", l_done)
  state = cg_emit_expr(state, expr.right)
  state.asm = a.mark(state.asm, l_done)
  return state
end function

function _emit_expr_safe_member(state, expr)
  lid = _next_lid(state)
  l_void = "safe_member_void_" + lid
  l_done = "safe_member_done_" + lid
  off = core.alloc_expr_temps(state, 8)
  state = cg_emit_expr(state, expr.target)
  state.asm = a.mov_rsp_disp32_rax(state.asm, off)
  state.asm = a.cmp_rax_imm8(state.asm, t.enc_void())
  state.asm = a.jcc(state.asm, "e", l_void)
  target = ml.DeferredCapture("DeferredCapture", off, -1, "")
  member = ml.Member("Member", target, expr.name, -1, "")
  state = cg_emit_expr(state, member)
  state.asm = a.jmp(state.asm, l_done)
  state.asm = a.mark(state.asm, l_void)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.mark(state.asm, l_done)
  state = core.free_expr_temps(state, 8)
  return state
end function

function _emit_expr_safe_call(state, expr)
  safe = expr.callee
  lid = _next_lid(state)
  l_void = "safe_call_void_" + lid
  l_done = "safe_call_done_" + lid
  off = core.alloc_expr_temps(state, 8)
  state = cg_emit_expr(state, safe.target)
  state.asm = a.mov_rsp_disp32_rax(state.asm, off)
  state.asm = a.cmp_rax_imm8(state.asm, t.enc_void())
  state.asm = a.jcc(state.asm, "e", l_void)
  target = ml.DeferredCapture("DeferredCapture", off, -1, "")
  member = ml.Member("Member", target, safe.name, -1, "")
  nested = ml.Call("Call", member, expr.args, try(expr.arg_names), -1, "")
  state = cg_emit_expr(state, nested)
  state.asm = a.jmp(state.asm, l_done)
  state.asm = a.mark(state.asm, l_void)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.mark(state.asm, l_done)
  state = core.free_expr_temps(state, 8)
  return state
end function

function _emit_expr_type_guard(state, expr)
  lid = _next_lid(state)
  l_valid = "type_guard_valid_" + lid
  l_done = "type_guard_done_" + lid
  off = core.alloc_expr_temps(state, 8)
  state = cg_emit_expr(state, expr.expr)
  state.asm = a.mov_rsp_disp32_rax(state.asm, off)
  optional = false
  if typeof(expr.optional) == "bool" and expr.optional then optional = true end if
  if optional then
    state.asm = a.cmp_rax_imm8(state.asm, t.enc_void())
    state.asm = a.jcc(state.asm, "e", l_valid)
  end if
  raw_type = _coerce_name(expr.type_name)
  canonical = raw_type
  if s.contains(raw_type, ".") == false then
    canonical = s.toLowerAscii(raw_type)
    if canonical == "integer" then canonical = "int" end if
    if canonical == "boolean" then canonical = "bool" end if
    if canonical == "str" then canonical = "string" end if
  end if
  loaded = ml.DeferredCapture("DeferredCapture", off, -1, "")
  primitive = canonical == "int" or canonical == "float" or canonical == "bool" or canonical == "string" or canonical == "array" or canonical == "bytes" or canonical == "function" or canonical == "struct" or canonical == "enum" or canonical == "error" or canonical == "thread" or canonical == "void" or canonical == "unknown"
  check = 0
  if primitive then
    typeof_call = ml.Call("Call", ml.Var("Var", "typeof", -1, ""), [loaded], [], -1, "")
    check = ml.Bin("Bin", typeof_call, "==", ml.Str("Str", canonical, -1, ""), -1, "")
  else
    check = ml.IsType("IsType", loaded, raw_type, false, -1, "")
  end if
  state = cg_emit_expr(state, check)
  state.asm = a.cmp_rax_imm8(state.asm, t.enc_bool(true))
  state.asm = a.jcc(state.asm, "e", l_valid)
  suffix = ""
  if optional then suffix = "?" end if
  state = _emit_make_error_const(state, c.ERR_TYPE_GUARD, "Expected value of type " + raw_type + suffix)
  state.asm = a.jmp(state.asm, l_done)
  state.asm = a.mark(state.asm, l_valid)
  state.asm = a.mov_rax_rsp_disp32(state.asm, off)
  state.asm = a.mark(state.asm, l_done)
  state = core.free_expr_temps(state, 8)
  // Type contracts propagate like other fallible expressions, while try()
  // suppresses this branch through the shared errprop_suppression counter.
  state = _emit_auto_errprop(state)
  return state
end function

function _emit_expr_num(state, expr)
  val_num = t.ast_value(expr)
  if typeof(val_num) == "int" then
    state.asm = a.mov_rax_tagged_int(state.asm, val_num)
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
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(t.ast_value(expr)))
  return state
end function

function _emit_expr_str(state, expr)
  lbl_str = "objstr_" + _next_lid(state)
  state.rdata = d.rdata_add_obj_string(state.rdata, lbl_str, t.ast_value(expr))
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
      base_parts_ty = t.arr_drop_last(parts_ty)
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
    off_v = core.alloc_expr_temps(state, 8)
    state.asm = a.mov_rsp_disp32_rax(state.asm, off_v)
    fid_v = _next_lid(state)
    l_true_v = "is_ve_true_" + fid_v
    l_false_v = "is_ve_false_" + fid_v
    l_done_v = "is_ve_done_" + fid_v

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

      if cv_v.ok and typeof(cv_v.value) == "bool" then
        state.asm = a.mov_r64_imm64(state.asm, "rdx", t.enc_bool(cv_v.value))
      else
        if cv_v.ok and typeof(cv_v.value) == "int" then
          state.asm = a.mov_r64_tagged_int(state.asm, "rdx", cv_v.value)
        else
          if cv_v.ok and typeof(cv_v.value) == "string" then
            lbl_ve = "cstr_ve_" + d.rdata_label_count(state.rdata)
            state.rdata = d.rdata_add_obj_string(state.rdata, lbl_ve, cv_v.value)
            state.asm = a.lea_rdx_rip(state.asm, lbl_ve)
          else
            state = scope.emit_load_var_scoped(state, qmem_v)
            state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
          end if
        end if
      end if

      state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", off_v)
      state.asm = a.call(state.asm, "fn_val_eq")
      state.asm = a.cmp_r64_imm(state.asm, "rax", t.enc_bool(true))
      state.asm = a.jcc(state.asm, "e", l_true_v)
    end for

    state.asm = a.jmp(state.asm, l_false_v)
    state.asm = a.mark(state.asm, l_true_v)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
    state.asm = a.jmp(state.asm, l_done_v)
    state.asm = a.mark(state.asm, l_false_v)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
    state.asm = a.mark(state.asm, l_done_v)
    state = core.free_expr_temps(state, 8)
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
  nm_try = t.ast_name(expr)
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
  if t.ast_is_node(tgt) == false then
    tgt = try(expr.target)
    obj_rt = try(expr.obj)
    if t.ast_is_node(tgt) == false and t.ast_is_node(obj_rt) then tgt = obj_rt end if
  end if
  known_struct = _opt_expr_known_type(state, tgt)
  if s.startsWith(known_struct, "struct:") then
    struct_qname = s.substr(known_struct, 7, len(known_struct) - 7)
    fields_fast = _state_struct_fields_get(state, struct_qname)
    if typeof(fields_fast) == "array" and len(fields_fast) > 0 then
      for fi_fast = 0 to len(fields_fast) - 1
        if _coerce_name(fields_fast[fi_fast]) == mname then
          state.asm = a.mark(state.asm, "struct_member_fast_" + _next_lid(state))
          state = cg_emit_expr(state, tgt)
          state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rax", 8 + fi_fast * 8)
          return state
        end if
      end for
    end if
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
  fast_plan = _opt_known_index_plan(state, expr)
  if typeof(fast_plan) == "array" and len(fast_plan) >= 3 then
    return _opt_emit_known_index(state, expr, fast_plan)
  end if

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
  state = cg_emit_expr(state, t.ast_right(expr))
  if t.ast_op(expr) == "-" then
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
  if t.ast_op(expr) == "not" then
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
  if t.ast_op(expr) == "~" then
    lid_b = _next_lid(state)
    lid_v = _next_lid(state)
    l_ok_b = "bnot_ok_" + lid_b
    l_fail_b = "bnot_fail_" + lid_b
    l_end_b = "bnot_end_" + lid_b
    l_nvoid_b = "bnot_nvoid_" + lid_v
    state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
    state.asm = a.and_r64_imm(state.asm, "rdx", 7)
    state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_INT)
    state.asm = a.jcc(state.asm, "e", l_ok_b)
    state.asm = a.jmp(state.asm, l_fail_b)
    state.asm = a.mark(state.asm, l_ok_b)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.xor_r64_imm(state.asm, "rax", -1)
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
    state.asm = a.jmp(state.asm, l_end_b)
    state.asm = a.mark(state.asm, l_fail_b)
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

function _intflow_name_has(arr, name)
  if typeof(arr) == "struct" then return t.fastmap_get(arr, name, 0) != 0 end if
  if typeof(arr) != "array" or len(arr) <= 0 then return false end if
  for i = 0 to len(arr) - 1
    if arr[i] == name then return true end if
  end for
  return false
end function

function _opt_const_nonzero_number(state, ex)
  cv = cg_expr_try_const_value(state, ex)
  if typeof(cv) != "struct" or cv.ok == false then return false end if
  tv = typeof(cv.value)
  return (tv == "int" or tv == "float") and cv.value != 0
end function

function _opt_const_nonnegative_int(state, ex)
  cv = cg_expr_try_const_value(state, ex)
  return typeof(cv) == "struct" and cv.ok and typeof(cv.value) == "int" and cv.value >= 0
end function

function _opt_expr_known_int(state, ex)
  if t.ast_is_node(ex) == false then return false end if
  cv = cg_expr_try_const_value(state, ex)
  if typeof(cv) == "struct" and cv.ok and typeof(cv.value) == "int" then return true end if
  k = _coerce_name(t.ast_kind(ex))
  if k == "Var" then
    nm = _coerce_name(t.ast_name(ex))
    known_by_flow = _intflow_name_has(state.known_int_names, nm)
    known_by_contract = _opt_type_base(_opt_type_fact_get(state.known_value_types, nm)) == "int"
    if known_by_flow == false and known_by_contract == false then return false end if
    b = scope.cg_resolve_binding(state, nm)
    if typeof(b) != "struct" then return false end if
    if b.kind != "local" and b.kind != "param" then return false end if
    if typeof(b.boxed) == "bool" and b.boxed then return false end if
    return true
  end if
  if k == "Unary" then
    op_u = _coerce_name(t.ast_op(ex))
    if op_u != "-" and op_u != "~" then return false end if
    return _opt_expr_known_int(state, t.ast_right(ex))
  end if
  if k == "Bin" then
    op_b = _coerce_name(t.ast_op(ex))
    left_b = t.ast_left(ex)
    right_b = t.ast_right(ex)
    operands_int = _opt_expr_known_int(state, left_b) and _opt_expr_known_int(state, right_b)
    if op_b == "+" or op_b == "-" or op_b == "*" or op_b == "&" or op_b == "|" or op_b == "^" then return operands_int end if
    if op_b == "%" then return operands_int and _opt_const_nonzero_number(state, right_b) end if
    if op_b == "<<" or op_b == ">>" then return operands_int and _opt_const_nonnegative_int(state, right_b) end if
  end if
  return false
end function

function inline _opt_type_base(type_name)
  if typeof(type_name) != "string" or type_name == "" then return "" end if
  for i = 0 to len(type_name) - 1
    if type_name[i] == ":" then return s.substr(type_name, 0, i) end if
  end for
  return type_name
end function

function _opt_type_exact_length(type_name)
  if typeof(type_name) != "string" or type_name == "" then return -1 end if
  colon = -1
  for i = 0 to len(type_name) - 1
    if type_name[i] == ":" then colon = i; break end if
  end for
  if colon < 0 then return -1 end if
  base = s.substr(type_name, 0, colon)
  if base != "array" and base != "bytes" then return -1 end if
  raw = s.substr(type_name, colon + 1, len(type_name) - colon - 1)
  value = toNumber(raw)
  if typeof(value) != "int" or value < 0 then return -1 end if
  return value
end function

function _opt_type_fact_get(items, name)
  if typeof(items) == "struct" then
    fact = t.fastmap_get(items, name, "")
    if typeof(fact) == "string" then return fact end if
    return ""
  end if
  if typeof(items) != "array" or len(items) <= 0 then return "" end if
  for i = 0 to len(items) - 1
    rec = items[i]
    if typeof(rec) == "array" and len(rec) >= 2 and rec[0] == name and typeof(rec[1]) == "string" then return rec[1] end if
  end for
  return ""
end function

function _opt_expr_known_type(state, ex)
  if t.ast_is_node(ex) == false then return "" end if
  k = _coerce_name(t.ast_kind(ex))
  if k == "Num" then
    if typeof(t.ast_value(ex)) == "int" then return "int" end if
    if typeof(t.ast_value(ex)) == "float" then return "float" end if
    return ""
  end if
  if k == "Bool" then return "bool" end if
  if k == "Str" then return "string" end if
  if k == "ArrayLit" then
    items = try(ex.items)
    if typeof(items) != "array" then items = [] end if
    return "array:" + len(items)
  end if
  if k == "Var" then
    nm = _coerce_name(t.ast_name(ex))
    fact = _opt_type_fact_get(state.known_value_types, nm)
    if fact == "" then return "" end if
    b = scope.cg_resolve_binding(state, nm)
    if typeof(b) != "struct" then return "" end if
    if b.kind != "local" and b.kind != "param" then return "" end if
    if typeof(b.boxed) == "bool" and b.boxed then return "" end if
    return fact
  end if
  if k == "IsType" then return "bool" end if
  if k == "Unary" then
    op_u = _coerce_name(t.ast_op(ex))
    rb = _opt_type_base(_opt_expr_known_type(state, t.ast_right(ex)))
    if op_u == "not" and rb != "" then return "bool" end if
    if op_u == "~" and rb == "int" then return "int" end if
    if op_u == "-" and rb == "int" then return "int" end if
    if op_u == "-" and (rb == "float" or rb == "number") then return "number" end if
    return ""
  end if
  if k == "Bin" then
    op_b = _coerce_name(t.ast_op(ex))
    lb = _opt_type_base(_opt_expr_known_type(state, t.ast_left(ex)))
    rb2 = _opt_type_base(_opt_expr_known_type(state, t.ast_right(ex)))
    if op_b == "==" or op_b == "!=" then return "bool" end if
    numeric_l_cmp = lb == "int" or lb == "float" or lb == "number"
    numeric_r_cmp = rb2 == "int" or rb2 == "float" or rb2 == "number"
    if (op_b == "<" or op_b == "<=" or op_b == ">" or op_b == ">=") and numeric_l_cmp and numeric_r_cmp then return "bool" end if
    if (op_b == "and" or op_b == "or") and lb != "" and rb2 != "" then return "bool" end if
    right_b = t.ast_right(ex)
    if (op_b == "&" or op_b == "|" or op_b == "^") and lb == "int" and rb2 == "int" then return "int" end if
    if (op_b == "<<" or op_b == ">>") and lb == "int" and rb2 == "int" and _opt_const_nonnegative_int(state, right_b) then return "int" end if
    if (op_b == "+" or op_b == "-" or op_b == "*") and lb == "int" and rb2 == "int" then return "int" end if
    if op_b == "%" and lb == "int" and rb2 == "int" and _opt_const_nonzero_number(state, right_b) then return "int" end if
    numeric_l = lb == "int" or lb == "float" or lb == "number"
    numeric_r = rb2 == "int" or rb2 == "float" or rb2 == "number"
    if (op_b == "+" or op_b == "-" or op_b == "*") and numeric_l and numeric_r then return "number" end if
    if (op_b == "/" or op_b == "%") and numeric_l and numeric_r and _opt_const_nonzero_number(state, right_b) then return "number" end if
    return ""
  end if
  if k == "Index" then
    target_type = _opt_expr_known_type(state, try(ex.target))
    tb = _opt_type_base(target_type)
    exact_len = _opt_type_exact_length(target_type)
    index_cv = cg_expr_try_const_value(state, try(ex.index))
    if tb == "bytes" and exact_len >= 0 and typeof(index_cv) == "struct" and index_cv.ok and typeof(index_cv.value) == "int" and index_cv.value >= 0 - exact_len and index_cv.value < exact_len then return "int" end if
    index_base = _opt_type_base(_opt_expr_known_type(state, try(ex.index)))
    // Specialized indexing propagates target and bounds errors. Its normal
    // continuation has a stable result type even when bytes(...) still needs
    // a runtime target guard.
    if (tb == "bytes" or tb == "bytes?") and index_base == "int" then return "int" end if
    if tb == "string" and index_base == "int" then return "string" end if
  end if
  return ""
end function

function _opt_type_query_can_elide_evaluation(ex)
  if t.ast_is_node(ex) == false then return false end if
  k = _coerce_name(t.ast_kind(ex))
  return k == "Num" or k == "Bool" or k == "Str" or k == "Var"
end function

function _opt_known_index_plan(state, ex)
  if typeof(ex) != "struct" then return [] end if
  target = try(ex.target)
  index = try(ex.index)
  if t.ast_kind(target) != "Var" then return [] end if
  fact = _opt_expr_known_type(state, target)
  kind = _opt_type_base(fact)
  if kind == "bytes?" then kind = "bytes_checked" end if
  if kind != "array" and kind != "bytes" and kind != "bytes_checked" and kind != "string" then return [] end if
  if _opt_type_base(_opt_expr_known_type(state, index)) != "int" then return [] end if
  target_binding = scope.cg_resolve_binding(state, _coerce_name(t.ast_name(target)))
  if typeof(target_binding) != "struct" then return [] end if
  base_slot = -1
  bounds_proven = false
  if t.ast_kind(index) == "Var" then
    index_binding = scope.cg_resolve_binding(state, _coerce_name(t.ast_name(index)))
    if typeof(index_binding) == "struct" and typeof(state.loop_index_fast_stack) == "array" and len(state.loop_index_fast_stack) > 0 then
      li = len(state.loop_index_fast_stack) - 1
      while li >= 0
        loop_rec = state.loop_index_fast_stack[li]
        if typeof(loop_rec) == "array" and len(loop_rec) >= 2 and loop_rec[0] == index_binding.id then
          targets = loop_rec[1]
          if typeof(targets) == "array" and len(targets) > 0 then
            for ti = 0 to len(targets) - 1
              spec = targets[ti]
              if typeof(spec) == "array" and len(spec) >= 4 and spec[0] == target_binding.id and spec[1] == kind then
                base_slot = spec[2]
                bounds_proven = spec[3]
                return [kind, base_slot, bounds_proven]
              end if
            end for
          end if
        end if
        li = li - 1
      end while
    end if
  end if
  exact_len = _opt_type_exact_length(fact)
  cv = cg_expr_try_const_value(state, index)
  if exact_len >= 0 and cv.ok and typeof(cv.value) == "int" then
    // Negative indices still require runtime length-based normalization.
    if cv.value >= 0 and cv.value < exact_len then bounds_proven = true end if
  end if
  return [kind, base_slot, bounds_proven]
end function

function _opt_emit_known_index(state, expr, plan)
  kind = plan[0]
  base_slot = plan[1]
  bounds_proven = plan[2]
  lid = _next_lid(state)
  l_oob = "idx_fast_oob_" + lid
  l_bad_target = "idx_fast_bad_target_" + lid
  l_done = "idx_fast_done_" + lid
  state.asm = a.mark(state.asm, "idx_fast_" + kind + "_" + lid)
  if bounds_proven then
    state.asm = a.mark(state.asm, "idx_fast_bounds_elided_" + lid)
  end if
  spill = -1
  if typeof(base_slot) == "int" and base_slot >= 0 then
    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", base_slot)
  else
    state = cg_emit_expr(state, try(expr.target))
    spill = core.alloc_expr_temps(state, 8)
    state.asm = a.mov_rsp_disp32_rax(state.asm, spill)
  end if
  state = cg_emit_expr(state, try(expr.index))
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.sar_r64_imm8(state.asm, "rcx", 3)
  if spill >= 0 then
    state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", spill)
    state = core.free_expr_temps(state, 8)
  end if
  if kind == "bytes_checked" then
    // The constructor fact is conditional on normal completion. Validate the
    // tagged object before selecting the compact byte-buffer layout.
    state.asm = a.mov_r64_r64(state.asm, "r10", "r11")
    state.asm = a.and_r64_imm(state.asm, "r10", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_bad_target)
    state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", 0)
    state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "ne", l_bad_target)
  end if
  if bounds_proven == false then
    state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 4)
    l_nonnegative = "idx_fast_nonnegative_" + lid
    state.asm = a.cmp_r32_imm(state.asm, "ecx", 0)
    state.asm = a.jcc(state.asm, "ge", l_nonnegative)
    state.asm = a.add_r32_r32(state.asm, "ecx", "edx")
    state.asm = a.mark(state.asm, l_nonnegative)
    state.asm = a.cmp_r32_imm(state.asm, "ecx", 0)
    state.asm = a.jcc(state.asm, "l", l_oob)
    state.asm = a.cmp_r32_r32(state.asm, "ecx", "edx")
    state.asm = a.jcc(state.asm, "ge", l_oob)
  end if
  if kind == "array" then
    state.asm = a.mov_r64_mem_bis(state.asm, "rax", "r11", "rcx", 8, 8)
  else
    if kind == "bytes" or kind == "bytes_checked" then
      state.asm = a.lea_r64_mem_bis(state.asm, "rax", "r11", "rcx", 1, 8)
      state.asm = a.movzx_r32_membase_disp(state.asm, "eax", "rax", 0)
      state.asm = a.shl_rax_imm8(state.asm, 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
    else
      state.asm = a.lea_r64_mem_bis(state.asm, "rax", "r11", "rcx", 1, 8)
      state.asm = a.movzx_r32_membase_disp(state.asm, "eax", "rax", 0)
      state.asm = a.lea_r11_rip(state.asm, "obj_char_table")
      state.asm = a.shl_rax_imm8(state.asm, 4)
      state.asm = a.add_r64_r64(state.asm, "rax", "r11")
    end if
  end if
  if bounds_proven == false or kind == "bytes_checked" then
    state.asm = a.jmp(state.asm, l_done)
  end if
  if kind == "bytes_checked" then
    state.asm = a.mark(state.asm, l_bad_target)
    state = core.emit_dbg_line(state, expr)
    state = _emit_make_error_const(state, c.ERR_INDEX_TARGET_TYPE, "Indexing requires array, string, or bytes")
    state = _emit_auto_errprop(state)
  end if
  if bounds_proven == false then
    state.asm = a.mark(state.asm, l_oob)
    state = core.emit_dbg_line(state, expr)
    state = _emit_make_error_const(state, c.ERR_INDEX_OOB, "Array index out of bounds")
    state = _emit_auto_errprop(state)
  end if
  if bounds_proven == false or kind == "bytes_checked" then state.asm = a.mark(state.asm, l_done) end if
  return state
end function

// Return log2(value), or -1 when value is not a positive power of two.
function _positive_power_of_two_shift(value)
  if typeof(value) != "int" or value <= 0 then return -1 end if
  shift = 0
  probe = value
  while probe > 1
    if (probe & 1) != 0 then return -1 end if
    probe = probe >> 1
    shift = shift + 1
  end while
  return shift
end function

function _emit_known_int_binop(state, op, lhs_ok, lhs_const, rhs_ok, rhs_const)
  // Operands in r10/r11 are proven tagged integers. Every specialization must
  // preserve the generic path's wraparound and void/error behavior.
  // Tagged add/sub immediates must fit the sign-extended x64 imm32 encoding.
  if op == "+" then
    if rhs_ok and rhs_const >= -268435456 and rhs_const < 268435456 then
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      tagged_delta = rhs_const * 8
      if tagged_delta != 0 then state.asm = a.add_r64_imm(state.asm, "rax", tagged_delta) end if
    else
      if lhs_ok and lhs_const >= -268435456 and lhs_const < 268435456 then
        state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
        tagged_delta = lhs_const * 8
        if tagged_delta != 0 then state.asm = a.add_r64_imm(state.asm, "rax", tagged_delta) end if
      else
        // Each encoded operand contains TAG_INT; remove one duplicate tag.
        state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
        state.asm = a.add_r64_r64(state.asm, "rax", "r11")
        state.asm = a.sub_rax_imm8(state.asm, 1)
      end if
    end if
    return state
  end if
  if op == "-" then
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    if rhs_ok and rhs_const >= -268435456 and rhs_const < 268435456 then
      tagged_delta = rhs_const * 8
      if tagged_delta != 0 then state.asm = a.sub_r64_imm(state.asm, "rax", tagged_delta) end if
    else
      state.asm = a.sub_r64_r64(state.asm, "rax", "r11")
      state.asm = a.add_rax_imm8(state.asm, 1)
    end if
    return state
  end if
  if op == "*" then
    const_ok = rhs_ok or lhs_ok
    const_value = 0
    value_reg = "r11"
    if rhs_ok then
      const_value = rhs_const
      value_reg = "r10"
    else
      if lhs_ok then const_value = lhs_const end if
    end if
    if const_ok and const_value == 0 then
      state.asm = a.mov_rax_imm64(state.asm, t.enc_int(0))
      return state
    end if
    if const_ok and const_value == 1 then
      state.asm = a.mov_r64_r64(state.asm, "rax", value_reg)
      return state
    end if
    state.asm = a.mov_r64_r64(state.asm, "rax", value_reg)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    if const_ok and const_value >= -2147483648 and const_value < 2147483648 then
      factor_shift = _positive_power_of_two_shift(const_value)
      if const_value == -1 then
        state.asm = a.neg_r64(state.asm, "rax")
      else
        if factor_shift >= 0 then
          state.asm = a.shl_rax_imm8(state.asm, factor_shift)
        else
          state.asm = a.imul_r64_r64_imm(state.asm, "rax", "rax", const_value)
        end if
      end if
    else
      other_reg = "r10"
      if value_reg == "r10" then other_reg = "r11" end if
      state.asm = a.sar_r64_imm8(state.asm, other_reg, 3)
      state.asm = a.imul_r64_r64(state.asm, "rax", other_reg)
    end if
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
    return state
  end if
  if op == "%" then
    if rhs_ok then
      divisor = rhs_const
      if divisor == 0 then
        state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
        return state
      end if
      if divisor == -1 or divisor == 1 then
        state.asm = a.mov_rax_imm64(state.asm, t.enc_int(0))
        return state
      end if
      divisor_shift = _positive_power_of_two_shift(divisor)
      if divisor <= 2147483648 and divisor_shift >= 0 then
        // For a positive power-of-two divisor this mask also implements
        // Python-style modulo for negative dividends.
        state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
        state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
        state.asm = a.and_r64_imm(state.asm, "rax", divisor - 1)
        state.asm = a.shl_rax_imm8(state.asm, 3)
        state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
        return state
      end if
    end if
    lid_m = _next_lid(state)
    l_ok_m = "known_mod_ok_" + lid_m
    dynamic_divisor_m = rhs_ok == false
    l_fail_m = ""
    l_done_m = ""
    if dynamic_divisor_m then
      l_fail_m = "known_mod_fail_" + lid_m
      l_done_m = "known_mod_done_" + lid_m
    end if
    l_divide_m = "known_mod_divide_" + lid_m
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    if rhs_ok and rhs_const >= -2147483648 and rhs_const < 2147483648 then
      state.asm = a.mov_r64_imm64(state.asm, "r11", rhs_const)
    else
      state.asm = a.sar_r64_imm8(state.asm, "r11", 3)
      if dynamic_divisor_m then
        state.asm = a.test_r64_r64(state.asm, "r11", "r11")
        state.asm = a.jcc(state.asm, "e", l_fail_m)
        // Avoid the sole signed-idiv overflow case. Modulo by -1 is zero
        // for every MiniLang integer, including the minimum tagged value.
        state.asm = a.cmp_r64_imm(state.asm, "r11", -1)
        state.asm = a.jcc(state.asm, "ne", l_divide_m)
        state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
        state.asm = a.jmp(state.asm, l_ok_m)
        state.asm = a.mark(state.asm, l_divide_m)
      end if
    end if
    state.asm = a.cqo(state.asm)
    state.asm = a.idiv_r64(state.asm, "r11")
    state.asm = a.test_r64_r64(state.asm, "rdx", "rdx")
    state.asm = a.jcc(state.asm, "e", l_ok_m)
    state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")
    state.asm = a.xor_r64_r64(state.asm, "rax", "r11")
    state.asm = a.test_r64_r64(state.asm, "rax", "rax")
    state.asm = a.jcc(state.asm, "ge", l_ok_m)
    state.asm = a.add_r64_r64(state.asm, "rdx", "r11")
    state.asm = a.mark(state.asm, l_ok_m)
    state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
    if dynamic_divisor_m then
      state.asm = a.jmp(state.asm, l_done_m)
      state.asm = a.mark(state.asm, l_fail_m)
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      state.asm = a.mark(state.asm, l_done_m)
    end if
    return state
  end if
  if op == "&" or op == "|" or op == "^" then
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
    return state
  end if
  if op == "<<" or op == ">>" then
    if rhs_ok then
      if rhs_const < 0 then
        state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
        return state
      end if
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
      // x64 masks variable shift counts to six bits; do the same at compile time.
      shift_const = rhs_const & 63
      if shift_const != 0 then
        if op == "<<" then
          state.asm = a.shl_rax_imm8(state.asm, shift_const)
        else
          state.asm = a.sar_r64_imm8(state.asm, "rax", shift_const)
        end if
      end if
      state.asm = a.shl_rax_imm8(state.asm, 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
      return state
    end if
    lid_s = _next_lid(state)
    l_fail_s = "known_shift_fail_" + lid_s
    l_done_s = "known_shift_done_" + lid_s
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.mov_r64_r64(state.asm, "rcx", "r11")
    state.asm = a.sar_r64_imm8(state.asm, "rcx", 3)
    state.asm = a.cmp_r64_imm(state.asm, "rcx", 0)
    state.asm = a.jcc(state.asm, "l", l_fail_s)
    state.asm = a.and_r64_imm(state.asm, "rcx", 63)
    if op == "<<" then
      state.asm = a.shl_r64_cl(state.asm, "rax")
    else
      state.asm = a.sar_r64_cl(state.asm, "rax")
    end if
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
    state.asm = a.jmp(state.asm, l_done_s)
    state.asm = a.mark(state.asm, l_fail_s)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    state.asm = a.mark(state.asm, l_done_s)
    return state
  end if
  if op == "==" or op == "!=" or op == "<" or op == "<=" or op == ">" or op == ">=" then
    cc = "e"
    if op == "!=" then cc = "ne" end if
    if op == "<" then cc = "l" end if
    if op == "<=" then cc = "le" end if
    if op == ">" then cc = "g" end if
    if op == ">=" then cc = "ge" end if
    state.asm = a.cmp_r64_r64(state.asm, "r10", "r11")
    state.asm = a.setcc_al(state.asm, cc)
    state.asm = a.movzx_eax_al(state.asm)
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_BOOL)
    return state
  end if
  return state
end function

function _emit_known_float_binop(state, expr)
  op = _coerce_name(t.ast_op(expr))
  supported = op == "+" or op == "-" or op == "*" or op == "/" or op == "%" or op == "==" or op == "!=" or op == "<" or op == "<=" or op == ">" or op == ">="
  if supported == false then return [state, false] end if
  lhs = _opt_type_base(_opt_expr_known_type(state, t.ast_left(expr)))
  rhs = _opt_type_base(_opt_expr_known_type(state, t.ast_right(expr)))
  lhs_numeric = lhs == "int" or lhs == "float" or lhs == "number"
  rhs_numeric = rhs == "int" or rhs == "float" or rhs == "number"
  if lhs_numeric == false or rhs_numeric == false or (lhs != "float" and rhs != "float") then return [state, false] end if

  lid = _next_lid(state)
  l_fail = "numeric_float_fail_" + lid
  l_done = "numeric_float_done_" + lid
  state.asm = a.mark(state.asm, "numeric_float_fast_" + lid)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state = core.emit_to_double_xmm(state, 0, l_fail)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
  state = core.emit_to_double_xmm(state, 1, l_fail)

  if op == "/" or op == "%" then
    state.asm = a.xorpd_xmm_xmm(state.asm, "xmm2", "xmm2")
    state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm1", "xmm2")
    state.asm = a.jcc(state.asm, "e", l_fail)
  end if

  if op == "+" then state.asm = a.addsd_xmm_xmm(state.asm, "xmm0", "xmm1") end if
  if op == "-" then state.asm = a.subsd_xmm_xmm(state.asm, "xmm0", "xmm1") end if
  if op == "*" then state.asm = a.mulsd_xmm_xmm(state.asm, "xmm0", "xmm1") end if
  if op == "/" then state.asm = a.divsd_xmm_xmm(state.asm, "xmm0", "xmm1") end if
  if op == "%" then
    state.asm = a.movapd_xmm_xmm(state.asm, "xmm3", "xmm0")
    state.asm = a.divsd_xmm_xmm(state.asm, "xmm0", "xmm1")
    state.asm = a.roundsd_xmm_xmm_imm8(state.asm, "xmm2", "xmm0", 1)
    state.asm = a.mulsd_xmm_xmm(state.asm, "xmm2", "xmm1")
    state.asm = a.subsd_xmm_xmm(state.asm, "xmm3", "xmm2")
    state.asm = a.movapd_xmm_xmm(state.asm, "xmm0", "xmm3")
  end if

  is_compare = op == "==" or op == "!=" or op == "<" or op == "<=" or op == ">" or op == ">="
  if is_compare then
    state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm1")
    if op == "==" then
      state.asm = a.setcc_al(state.asm, "e")
      state.asm = a.setcc_r8(state.asm, "p", "dl")
      state.asm = a.xor_r8_imm8(state.asm, "dl", 1)
      state.asm = a.and_r8_r8(state.asm, "al", "dl")
    else
      if op == "!=" then
        state.asm = a.setcc_al(state.asm, "ne")
        state.asm = a.setcc_r8(state.asm, "p", "dl")
        state.asm = a.or_r8_r8(state.asm, "al", "dl")
      else
        cc = "b"
        if op == "<=" then cc = "be" end if
        if op == ">" then cc = "a" end if
        if op == ">=" then cc = "ae" end if
        state.asm = a.setcc_al(state.asm, cc)
        state.asm = a.setcc_r8(state.asm, "p", "dl")
        state.asm = a.xor_r8_imm8(state.asm, "dl", 1)
        state.asm = a.and_r8_r8(state.asm, "al", "dl")
      end if
    end if
    state.asm = a.movzx_eax_al(state.asm)
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_BOOL)
    state.asm = a.jmp(state.asm, l_done)
  else
    state = core.emit_normalize_xmm0_to_value(state)
    state.asm = a.jmp(state.asm, l_done)
  end if

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.mark(state.asm, l_done)
  return [state, true]
end function

function _emit_expr_bin(state, expr)
  if t.ast_op(expr) == "and" then
    lid_and = _next_lid(state)
    lid_and_v = _next_lid(state)
    lid_and_rv = _next_lid(state)
    l_and_false = "and_false_" + lid_and
    l_and_end = "and_end_" + lid_and
    l_and_nvoid = "and_nvoid_" + lid_and_v
    l_and_rnvoid = "and_rnvoid_" + lid_and_rv
    l_and_rfalse = "and_rfalse_" + lid_and
    state = cg_emit_expr(state, t.ast_left(expr))
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
    state = cg_emit_expr(state, t.ast_right(expr))
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

  if t.ast_op(expr) == "or" then
    lid_or = _next_lid(state)
    lid_or_v = _next_lid(state)
    lid_or_rv = _next_lid(state)
    l_or_eval = "or_eval_" + lid_or
    l_or_false = "or_rfalse_" + lid_or
    l_or_end = "or_end_" + lid_or
    l_or_nvoid = "or_nvoid_" + lid_or_v
    l_or_rnvoid = "or_rnvoid_" + lid_or_rv
    state = cg_emit_expr(state, t.ast_left(expr))
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
    state = cg_emit_expr(state, t.ast_right(expr))
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
  state = cg_emit_expr(state, t.ast_left(expr))
  state.asm = a.mov_rsp_disp32_rax(state.asm, left_tmp)
  state = cg_emit_expr(state, t.ast_right(expr))
  state.asm = a.mov_rsp_disp32_rax(state.asm, right_tmp)

  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", left_tmp)
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", right_tmp)
  state = core.free_expr_temps(state, 16)
  tmp_bin_ok = false

  lhs_const = _opt_try_const_value(state, t.ast_left(expr))
  rhs_const = _opt_try_const_value(state, t.ast_right(expr))
  lhs_const_type = typeof(lhs_const.value)
  rhs_const_type = typeof(rhs_const.value)
  lhs_const_int_ok = lhs_const.ok and (lhs_const_type == "int" or (lhs_const_type == "float" and (lhs_const.value % 1) == 0))
  rhs_const_int_ok = rhs_const.ok and (rhs_const_type == "int" or (rhs_const_type == "float" and (rhs_const.value % 1) == 0))
  lhs_const_int = 0
  rhs_const_int = 0
  if lhs_const_int_ok then lhs_const_int = lhs_const.value end if
  if rhs_const_int_ok then rhs_const_int = rhs_const.value end if

  op = t.ast_op(expr)
  known_int_op = op == "+" or op == "-" or op == "*" or op == "%" or op == "&" or op == "|" or op == "^" or op == "<<" or op == ">>" or op == "==" or op == "!=" or op == "<" or op == "<=" or op == ">" or op == ">="
  if known_int_op and _opt_expr_known_int(state, t.ast_left(expr)) and _opt_expr_known_int(state, t.ast_right(expr)) then
    state = _emit_known_int_binop(state, op, lhs_const_int_ok, lhs_const_int, rhs_const_int_ok, rhs_const_int)
    return state
  end if
  known_float_result = _emit_known_float_binop(state, expr)
  state = known_float_result[0]
  if known_float_result[1] then return state end if

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
    l_div_fail = "div_fail_" + lid_divf
    l_div_done = "div_done_" + lid_divf

    // Match the reference compiler's strict-void semantics. Numeric conversion
    // still returns void for ordinary type/divide-by-zero failures, but applying
    // division to an actual void value is a propagated runtime error.
    vidv = _next_lid(state)
    l_nvoid = "div_nvoid_" + vidv
    l_isvoid = "div_isvoid_" + vidv
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_VOID)
    state.asm = a.jcc(state.asm, "e", l_isvoid)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.and_rax_imm8(state.asm, 7)
    state.asm = a.cmp_rax_imm8(state.asm, c.TAG_VOID)
    state.asm = a.jcc(state.asm, "ne", l_nvoid)
    state.asm = a.mark(state.asm, l_isvoid)
    state = core.emit_dbg_line(state, expr)
    state = _emit_make_error_const(state, c.ERR_VOID_OP, "Cannot apply '/' to void")
    state = _emit_auto_errprop(state)
    state.asm = a.jmp(state.asm, l_div_done)
    state.asm = a.mark(state.asm, l_nvoid)

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
      l_mod_divide = "mod_divide_" + lid_arith
      state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
      state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
      state.asm = a.sar_r64_imm8(state.asm, "r11", 3)
      state.asm = a.test_r64_r64(state.asm, "r11", "r11")
      state.asm = a.jcc(state.asm, "e", l_arith_fail)
      state.asm = a.cmp_r64_imm(state.asm, "r11", -1)
      state.asm = a.jcc(state.asm, "ne", l_mod_divide)
      state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
      state.asm = a.jmp(state.asm, l_mod_ok)
      state.asm = a.mark(state.asm, l_mod_divide)
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
    l_moddivide = "bin_moddivide_" + lid_mod
    state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
    state.asm = a.jcc(state.asm, "e", l_modz)
    state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.mov_r64_r64(state.asm, "r11", "r11")
    state.asm = a.sar_r64_imm8(state.asm, "r11", 3)
    state.asm = a.cmp_r64_imm(state.asm, "r11", -1)
    state.asm = a.jcc(state.asm, "ne", l_moddivide)
    state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
    state.asm = a.jmp(state.asm, l_modok)
    state.asm = a.mark(state.asm, l_moddivide)
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
  if t.ast_is_node(cal) == false then cal = try(expr.func) end if
  args = try(expr.args)
  if typeof(args) != "array" then args = [] end if
  call_args = _filter_expr_list_separator_artifacts(args)
  nargs = len(call_args)
  member_runtime = false
  compiletime_callee_qn = ""

  pre_raw = ""
  cal_kind = _coerce_name(t.ast_kind(cal))
  if cal_kind == "Var" and typeof(t.ast_name(cal)) == "string" then
    pre_raw = t.ast_name(cal)
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
  if t.ast_is_node(cal) then
    compiletime_callee_qn = _qname_of(state, cal)
    cal_kind = _coerce_name(t.ast_kind(cal))
    if cal_kind == "Member" then
      member_runtime = compiletime_callee_qn == ""
      callee = compiletime_callee_qn
    end if
    if cal_kind == "Var" then
      cal_name_try = t.ast_name(cal)
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

  // Normalize named/default/variadic syntax before direct-call and inline
  // paths. The native ABI remains fixed; a variadic tail is one array value.
  has_named = false
  arg_names = try(expr.arg_names)
  if typeof(arg_names) == "array" and len(arg_names) > 0 then
    for ni = 0 to len(arg_names) - 1
      if typeof(arg_names[ni]) == "string" then has_named = true break end if
    end for
  end if
  direct_decl = _user_function_get(state, callee)
  if typeof(direct_decl) == "struct" and _is_instance_method_qname(state, callee) == false then
    normalized = _normalize_declared_call_args(expr, direct_decl, 0)
    if normalized.ok == false then
      state.diagnostics = state.diagnostics + [normalized.message]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return state
    end if
    call_args = normalized.args
    expr.args = call_args
    expr.arg_names = array(len(call_args), void)
    nargs = len(call_args)
  else
    if has_named and not (member_runtime and cal_kind == "Member") then
      ctor_fields = _state_struct_fields_get(state, callee)
      if typeof(ctor_fields) != "array" then
        state.diagnostics = state.diagnostics + ["Named arguments require a directly resolved MiniLang function or struct"]
        state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
        return state
      end if
      values = array(len(ctor_fields), void)
      next_pos = 0
      for ni = 0 to len(call_args) - 1
        arg_name = void
        if ni < len(arg_names) then arg_name = arg_names[ni] end if
        if typeof(arg_name) != "string" then
          while next_pos < len(values) and typeof(values[next_pos]) != "void"
            next_pos = next_pos + 1
          end while
          if next_pos >= len(values) then
            state.diagnostics = state.diagnostics + ["Struct " + callee + " received too many arguments"]
            state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
            return state
          end if
          values[next_pos] = call_args[ni]
          next_pos = next_pos + 1
        else
          field_index = -1
          for fi = 0 to len(ctor_fields) - 1
            if ctor_fields[fi] == arg_name then field_index = fi break end if
          end for
          if field_index < 0 then
            state.diagnostics = state.diagnostics + ["Unknown field argument '" + arg_name + "' for struct " + callee]
            state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
            return state
          end if
          if typeof(values[field_index]) != "void" then
            state.diagnostics = state.diagnostics + ["Field argument '" + arg_name + "' was supplied more than once"]
            state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
            return state
          end if
          values[field_index] = call_args[ni]
        end if
      end for
      for fi = 0 to len(values) - 1
        if typeof(values[fi]) == "void" then
          state.diagnostics = state.diagnostics + ["Missing field argument '" + ctor_fields[fi] + "' for struct " + callee]
          state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
          return state
        end if
      end for
      call_args = values
      expr.args = values
      expr.arg_names = array(len(values), void)
      nargs = len(values)
    end if
  end if

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

  // Native Thread object methods. They intentionally share member-call syntax
  // with user structs, but dispatch through the reserved OBJ_THREAD header.
  if t.ast_kind(cal) == "Member" and member_runtime then
    mname_th = _coerce_name(try(cal.name))
    if mname_th == "" then mname_th = _coerce_name(try(cal.field)) end if
    helper_th = ""
    min_args_th = 0
    max_args_th = 0
    if mname_th == "Start" then
      helper_th = "fn_thread_start"
      max_args_th = 1
    end if
    if mname_th == "Stop" then helper_th = "fn_thread_stop" end if
    if mname_th == "Join" then
      helper_th = "fn_thread_join"
      max_args_th = 1
    end if
    if mname_th == "Status" then helper_th = "fn_thread_status" end if
    if mname_th == "IsAlive" then helper_th = "fn_thread_alive" end if
    if mname_th == "Id" then helper_th = "fn_thread_id" end if
    if mname_th == "LogicalId" then helper_th = "fn_thread_logical_id" end if
    if mname_th == "SetLogicalId" then
      helper_th = "fn_thread_set_logical_id"
      min_args_th = 1
      max_args_th = 1
    end if
    if mname_th == "Result" then helper_th = "fn_thread_result" end if
    if mname_th == "Close" then helper_th = "fn_thread_close" end if
    if helper_th != "" then
      arg_names_th = try(expr.arg_names)
      if typeof(arg_names_th) == "array" and len(arg_names_th) > 0 then
        for ani_th = 0 to len(arg_names_th) - 1
          if typeof(arg_names_th[ani_th]) == "string" then
            state.diagnostics = state.diagnostics + ["Thread." + mname_th + " does not accept named arguments"]
            state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
            return state
          end if
        end for
      end if
      if nargs < min_args_th or nargs > max_args_th then
        allowed_th = "" + min_args_th
        if max_args_th != min_args_th then allowed_th = allowed_th + " or " + max_args_th end if
        state.diagnostics = state.diagnostics + ["Thread." + mname_th + " expects " + allowed_th + " arguments, got " + nargs]
        state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
        return state
      end if
      tgt_th = try(cal.target)
      if t.ast_is_node(tgt_th) == false then tgt_th = try(cal.obj) end if
      total_th = nargs + 1
      base_th = core.alloc_expr_temps(state, total_th * 8)
      state = cg_emit_expr(state, tgt_th)
      state.asm = a.mov_rsp_disp32_rax(state.asm, base_th)
      if nargs > 0 then
        for ai_th = 0 to nargs - 1
          state = cg_emit_expr(state, call_args[ai_th])
          state.asm = a.mov_membase_disp_r64(state.asm, "rsp", base_th + (ai_th + 1) * 8, "rax")
        end for
      end if

      fid_th = _next_lid(state)
      l_fail_th = "thread_method_fail_" + fid_th
      l_done_th = "thread_method_done_" + fid_th
      state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", base_th)
      state.asm = a.mov_r64_r64(state.asm, "r11", "rcx")
      state.asm = a.and_r64_imm(state.asm, "r11", 7)
      state.asm = a.cmp_r64_imm(state.asm, "r11", c.TAG_PTR)
      state.asm = a.jcc(state.asm, "ne", l_fail_th)
      state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "rcx", 0)
      state.asm = a.cmp_r32_imm(state.asm, "r11d", c.OBJ_THREAD)
      state.asm = a.jcc(state.asm, "ne", l_fail_th)

      if mname_th == "Start" then
        if nargs == 1 then
          state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", base_th + 8)
          state.asm = a.mov_r32_imm32(state.asm, "r8d", 1)
        else
          state.asm = a.mov_r64_imm64(state.asm, "rdx", t.enc_void())
          state.asm = a.xor_r32_r32(state.asm, "r8d", "r8d")
        end if
      end if
      if mname_th == "SetLogicalId" then
        state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", base_th + 8)
      end if
      if mname_th == "Join" then
        if nargs == 1 then
          state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", base_th + 8)
          state.asm = a.mov_r64_r64(state.asm, "r11", "rdx")
          state.asm = a.and_r64_imm(state.asm, "r11", 7)
          state.asm = a.cmp_r64_imm(state.asm, "r11", c.TAG_INT)
          state.asm = a.jcc(state.asm, "ne", l_fail_th)
          state.asm = a.sar_r64_imm8(state.asm, "rdx", 3)
        else
          state.asm = a.mov_r32_imm32(state.asm, "edx", 0xFFFFFFFF)
        end if
      end if
      state.asm = a.call(state.asm, helper_th)
      state.asm = a.jmp(state.asm, l_done_th)
      state.asm = a.mark(state.asm, l_fail_th)
      state = _emit_make_error_const(state, c.ERR_METHOD_NOT_FOUND, "No matching Thread method '" + mname_th + "' for receiver")
      state.asm = a.mark(state.asm, l_done_th)
      state = _emit_auto_errprop(state)
      state = core.free_expr_temps(state, total_th * 8)
      return state
    end if
  end if

  // OOP-style struct instance call: obj.method(args...)
  // Compile as dynamic dispatch on receiver.struct_id -> direct call of hoisted method body.
  if t.ast_kind(cal) == "Member" and member_runtime then
    mname_dyn = _coerce_name(try(cal.name))
    if mname_dyn == "" then mname_dyn = _coerce_name(try(cal.field)) end if
    tgt_dyn = try(cal.target)
    obj_dyn = try(cal.obj)
    if t.ast_is_node(tgt_dyn) == false then tgt_dyn = obj_dyn end if

    if mname_dyn != "" and typeof(state.struct_methods) == "array" and len(state.struct_methods) > 0 then
      // A concrete receiver fact makes runtime tag/type checks, struct-id
      // dispatch and the polymorphic cache redundant. It also gives a small
      // inline method to the existing source-level inliner.
      known_type_dyn = _opt_expr_known_type(state, tgt_dyn)
      known_qname_dyn = ""
      if s.startsWith(known_type_dyn, "struct:") then
        known_qname_dyn = s.substr(known_type_dyn, 7, len(known_type_dyn) - 7)
      end if
      known_method_dyn = ""
      if known_qname_dyn != "" then
        known_method_dyn = _method_map_get(_state_struct_methods_get(state, known_qname_dyn), mname_dyn)
      end if
      known_def_dyn = 0
      if known_method_dyn != "" then known_def_dyn = _user_function_get(state, known_method_dyn) end if
      if typeof(known_def_dyn) == "struct" then
        normalized_dyn = _normalize_declared_call_args(expr, known_def_dyn, 1)
        if normalized_dyn.ok == false then
          state.diagnostics = state.diagnostics + [normalized_dyn.message]
          state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
          return state
        end if
        call_args = normalized_dyn.args
        expr.args = call_args
        expr.arg_names = array(len(call_args), void)
        nargs = len(call_args)
      else if has_named then
        state.diagnostics = state.diagnostics + ["Named method arguments require a statically known struct receiver"]
        state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
        return state
      end if
      total_dyn = nargs + 1
      known_arity_dyn = -1
      if typeof(known_def_dyn) == "struct" and typeof(try(known_def_dyn.params)) == "array" then
        known_arity_dyn = len(known_def_dyn.params)
      end if
      if known_arity_dyn == total_dyn then
        known_inline_used = 0
        if typeof(state._inline_emitted_bytes) == "struct" then
          known_inline_used = t.fastmap_get(state._inline_emitted_bytes, known_method_dyn, 0)
          if typeof(known_inline_used) != "int" then known_inline_used = 0 end if
        end if
        if known_inline_used < 4096 and _function_wants_inline(known_def_dyn) and _call_args_have_stack_variadic(call_args) == false and _inline_call_eligible(known_def_dyn) then
          // Only the inliner needs a synthetic receiver-plus-arguments array;
          // the common direct-call path emits from the original AST arrays.
          known_args_b = t.arr_chunk_new(total_dyn)
          known_args_b = t.arr_chunk_push(known_args_b, tgt_dyn)
          if nargs > 0 then known_args_b = t.arr_chunk_push_all(known_args_b, call_args) end if
          known_args_dyn = t.arr_chunk_finish(known_args_b)
          state = _emit_inline_call(state, known_method_dyn, known_args_dyn)
          state = _emit_auto_errprop(state)
          return state
        end if

        known_base_dyn = core.alloc_expr_temps(state, total_dyn * 8)
        if typeof(known_base_dyn) != "int" or known_base_dyn <= 0 then known_base_dyn = 0x300 end if
        state = cg_emit_expr(state, tgt_dyn)
        state.asm = a.mov_rsp_disp32_rax(state.asm, known_base_dyn)
        if nargs > 0 then
          for kai_dyn = 0 to nargs - 1
            state = cg_emit_expr(state, call_args[kai_dyn])
            state.asm = a.mov_rsp_disp32_rax(state.asm, known_base_dyn + (kai_dyn + 1) * 8)
          end for
        end if
        if total_dyn >= 1 then state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", known_base_dyn) end if
        if total_dyn >= 2 then state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", known_base_dyn + 8) end if
        if total_dyn >= 3 then state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", known_base_dyn + 16) end if
        if total_dyn >= 4 then state.asm = a.mov_r64_membase_disp(state.asm, "r9", "rsp", known_base_dyn + 24) end if
        if total_dyn > 4 then
          for ksi_dyn = 4 to total_dyn - 1
            state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", known_base_dyn + ksi_dyn * 8)
            state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20 + (ksi_dyn - 4) * 8, "r11")
          end for
        end if
        state.asm = a.mov_r64_imm64(state.asm, "r10", t.enc_void())
        state.asm = a.call(state.asm, "fn_user_" + known_method_dyn)
        state = _emit_auto_errprop(state)
        state = core.free_expr_temps(state, total_dyn * 8)
        if total_dyn > 4 then
          for kci_dyn = 4 to total_dyn - 1
            state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20 + (kci_dyn - 4) * 8, t.enc_void(), true)
          end for
        end if
        return state
      end if

      // Candidate storage is needed only when the concrete receiver was not
      // proven and runtime method dispatch must be emitted.
      cand_b = t.arr_chunk_new(16)
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
        fid_dyn = _next_lid(state)
        l_fail_dyn = "mcall_fail_" + fid_dyn
        l_done_dyn = "mcall_done_" + fid_dyn
        l_ic_try1_dyn = "mcall_ic_try1_" + fid_dyn
        l_ic_miss_dyn = "mcall_ic_miss_" + fid_dyn
        cache_sid0_lbl_dyn = "mcall_ic_sid0_" + fid_dyn
        cache_pad0_lbl_dyn = "mcall_ic_sid0pad_" + fid_dyn
        cache_code0_lbl_dyn = "mcall_ic_code0_" + fid_dyn
        cache_sid1_lbl_dyn = "mcall_ic_sid1_" + fid_dyn
        cache_pad1_lbl_dyn = "mcall_ic_sid1pad_" + fid_dyn
        cache_code1_lbl_dyn = "mcall_ic_code1_" + fid_dyn
        state.data = d.data_pad_align(state.data, 8)
        state.data = d.data_add_u32(state.data, cache_sid0_lbl_dyn, 0xFFFFFFFF)
        state.data = d.data_add_u32(state.data, cache_pad0_lbl_dyn, 0)
        state.data = d.data_add_u64(state.data, cache_code0_lbl_dyn, 0)
        state.data = d.data_add_u32(state.data, cache_sid1_lbl_dyn, 0xFFFFFFFF)
        state.data = d.data_add_u32(state.data, cache_pad1_lbl_dyn, 0)
        state.data = d.data_add_u64(state.data, cache_code1_lbl_dyn, 0)

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

        // Small polymorphic inline cache: primary + secondary struct_id/code pair.
        state.asm = a.mov_eax_rip_dword(state.asm, cache_sid0_lbl_dyn)
        state.asm = a.cmp_r32_r32(state.asm, "r10d", "eax")
        state.asm = a.jcc(state.asm, "ne", l_ic_try1_dyn)
        state.asm = a.mov_rax_rip_qword(state.asm, cache_code0_lbl_dyn)
        state.asm = a.test_r64_r64(state.asm, "rax", "rax")
        state.asm = a.jcc(state.asm, "e", l_ic_try1_dyn)
        state.asm = a.mov_r64_imm64(state.asm, "r10", t.enc_void())
        state.asm = a.call_rax(state.asm)
        state.asm = a.jmp(state.asm, l_done_dyn)

        state.asm = a.mark(state.asm, l_ic_try1_dyn)
        state.asm = a.mov_eax_rip_dword(state.asm, cache_sid1_lbl_dyn)
        state.asm = a.cmp_r32_r32(state.asm, "r10d", "eax")
        state.asm = a.jcc(state.asm, "ne", l_ic_miss_dyn)
        state.asm = a.mov_rax_rip_qword(state.asm, cache_code1_lbl_dyn)
        state.asm = a.test_r64_r64(state.asm, "rax", "rax")
        state.asm = a.jcc(state.asm, "e", l_ic_miss_dyn)
        state.asm = a.mov_r64_imm64(state.asm, "r10", t.enc_void())
        state.asm = a.call_rax(state.asm)
        state.asm = a.jmp(state.asm, l_done_dyn)

        state.asm = a.mark(state.asm, l_ic_miss_dyn)
        for ci_dyn = 0 to len(cands_dyn) - 1
          c_dyn = cands_dyn[ci_dyn]
          sid_dyn2 = -1
          if typeof(c_dyn) == "array" and len(c_dyn) >= 2 then
            if typeof(c_dyn[0]) == "int" then sid_dyn2 = c_dyn[0] end if
          end if
          if sid_dyn2 < 0 then continue end if
          l_case_dyn = "mcall_case_" + fid_dyn + "_" + sid_dyn2
          state.asm = a.cmp_r32_imm(state.asm, "r10d", sid_dyn2)
          state.asm = a.jcc(state.asm, "e", l_case_dyn)
        end for
        state.asm = a.jmp(state.asm, l_fail_dyn)

        for ci_dyn2 = 0 to len(cands_dyn) - 1
          c_dyn2 = cands_dyn[ci_dyn2]
          sid_dyn3 = -1
          fnq_dyn3 = ""
          if typeof(c_dyn2) == "array" and len(c_dyn2) >= 2 then
            if typeof(c_dyn2[0]) == "int" then sid_dyn3 = c_dyn2[0] end if
            fnq_dyn3 = _coerce_name(c_dyn2[1])
          end if
          if sid_dyn3 < 0 or fnq_dyn3 == "" then continue end if
          l_case_dyn2 = "mcall_case_" + fid_dyn + "_" + sid_dyn3
          state.asm = a.mark(state.asm, l_case_dyn2)
          state.asm = a.mov_eax_rip_dword(state.asm, cache_sid0_lbl_dyn)
          state.asm = a.mov_rip_dword_eax(state.asm, cache_sid1_lbl_dyn)
          state.asm = a.mov_rax_rip_qword(state.asm, cache_code0_lbl_dyn)
          state.asm = a.mov_rip_qword_rax(state.asm, cache_code1_lbl_dyn)
          state.asm = a.mov_r32_r32(state.asm, "eax", "r10d")
          state.asm = a.mov_rip_dword_eax(state.asm, cache_sid0_lbl_dyn)
          state.asm = a.lea_rax_rip(state.asm, "fn_user_" + fnq_dyn3)
          state.asm = a.mov_rip_qword_rax(state.asm, cache_code0_lbl_dyn)
          state.asm = a.mov_r64_imm64(state.asm, "r10", t.enc_void())
          state.asm = a.call(state.asm, "fn_user_" + fnq_dyn3)
          state.asm = a.jmp(state.asm, l_done_dyn)
        end for

        state.asm = a.mark(state.asm, l_fail_dyn)
        state = _emit_make_error_const(state, c.ERR_METHOD_NOT_FOUND, "No matching method '" + mname_dyn + "' for receiver")
        state.asm = a.mark(state.asm, l_done_dyn)
        state = _emit_auto_errprop(state)
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
        if total_dyn > 4 then
          for clear_dyn = 4 to total_dyn - 1
            state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20 + (clear_dyn - 4) * 8, t.enc_void(), true)
          end for
        end if
        return state
      end if
    end if
  end if

  // Thread(function[, logicalId]): create a real OS thread over the shared heap.
  // Entry points are capture-free, top-level functions with zero or one parameter.
  if callee == "Thread" or raw_name == "Thread" then
    if nargs < 1 or nargs > 2 then
      state.diagnostics = state.diagnostics + ["Thread expects 1 function and an optional logical id, got " + nargs + " arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return state
    end if
    fn_qn_th = _qname_of(state, call_args[0])
    if fn_qn_th != "" then fn_qn_th = _apply_import_alias(state, fn_qn_th) end if
    fn_def_th = 0
    if fn_qn_th != "" then fn_def_th = _user_function_get(state, fn_qn_th) end if
    if typeof(fn_def_th) != "struct" then
      state.diagnostics = state.diagnostics + ["Thread expects a top-level function name"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return state
    end if
    params_th = try(fn_def_th.params)
    entry_arity_th = 0
    if typeof(params_th) == "array" then entry_arity_th = len(params_th) end if
    if entry_arity_th > 1 then
      state.diagnostics = state.diagnostics + ["Thread entry function '" + fn_qn_th + "' must have zero or one parameter"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return state
    end if
    captures_th = try(fn_def_th._ml_captures)
    if typeof(captures_th) == "array" and len(captures_th) > 0 then
      state.diagnostics = state.diagnostics + ["Thread entry function '" + fn_qn_th + "' must not capture local variables"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return state
    end if
    if nargs == 2 then
      state = cg_emit_expr(state, call_args[1])
      state.asm = a.mov_r64_r64(state.asm, "r8", "rax")
    else
      state.asm = a.mov_r64_imm64(state.asm, "r8", t.enc_void())
    end if
    state.asm = a.lea_rax_rip(state.asm, "fn_user_" + fn_qn_th)
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.mov_r32_imm32(state.asm, "edx", entry_arity_th)
    state.asm = a.call(state.asm, "fn_thread_new")
    return state
  end if

  if callee == "threadStopRequested" or raw_name == "threadStopRequested" then
    if nargs != 0 then
      state.diagnostics = state.diagnostics + ["threadStopRequested expects no arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return state
    end if
    state.asm = a.call(state.asm, "fn_thread_stop_requested")
    return state
  end if

  if callee == "threadLogicalId" or raw_name == "threadLogicalId" then
    if nargs != 0 then
      state.diagnostics = state.diagnostics + ["threadLogicalId expects no arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return state
    end if
    state.asm = a.call(state.asm, "fn_thread_current_logical_id")
    return state
  end if

  if callee == "threadSleep" or raw_name == "threadSleep" then
    if nargs != 1 then
      state.diagnostics = state.diagnostics + ["threadSleep expects 1 argument, got " + nargs]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return state
    end if
    state = cg_emit_expr(state, call_args[0])
    lid_sleep = _next_lid(state)
    l_ok_sleep = "thsleep_ok_" + lid_sleep
    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.and_r64_imm(state.asm, "r11", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r11", c.TAG_INT)
    state.asm = a.jcc(state.asm, "e", l_ok_sleep)
    state = _emit_make_error_const(state, c.ERR_CALL_NOT_CALLABLE, "threadSleep expects an integer millisecond value")
    state = _emit_auto_errprop(state)
    state.asm = a.mark(state.asm, l_ok_sleep)
    state.asm = a.sar_rax_imm8(state.asm, 3)
    state.asm = a.mov_r32_r32(state.asm, "r12d", "eax")
    threaded_native_sleep = state.native_threads_possible
    if threaded_native_sleep then state.asm = a.call(state.asm, "fn_gc_native_enter") end if
    state.asm = a.mov_r32_r32(state.asm, "ecx", "r12d")
    state.asm = a.mov_rax_rip_qword(state.asm, "iat_Sleep")
    state.asm = a.call_rax(state.asm)
    if threaded_native_sleep then state.asm = a.call(state.asm, "fn_gc_native_leave") end if
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return state
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
  // Native string/bytes helpers use the same compact ABI path as the Python
  // compiler.  Keeping this ahead of generic value-call dispatch is important:
  // these names are compiler intrinsics, not rebindable MiniLang functions.
  native_helper = _emit_native_value_helper_call(state, callee, raw_name, call_args, nargs)
  if typeof(native_helper) == "array" and len(native_helper) >= 2 then
    state = native_helper[0]
    if native_helper[1] == true then return [state, true] end if
  end if

  // Checksum, constant-time comparison, and CPU dispatch intrinsics remain
  // special forms so unused programs do not pull in tables or helper code.
  if callee == "nativeCrc32c" or raw_name == "nativeCrc32c" or callee == "nativeCrc32" or raw_name == "nativeCrc32" then
    if nargs != 4 then
      state.diagnostics = state.diagnostics +["native CRC functions expect exactly 4 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    tmp_crc = core.alloc_expr_temps(state, 32)
    tmp_crc_ok = typeof(tmp_crc) == "int" and tmp_crc > 0
    if not tmp_crc_ok then tmp_crc = 0x300 end if
    for crci = 0 to 3
      state = cg_emit_expr(state, call_args[crci])
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_crc + crci * 8, "rax")
    end for
    state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", tmp_crc)
    state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", tmp_crc + 8)
    state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", tmp_crc + 16)
    state.asm = a.mov_r64_membase_disp(state.asm, "r9", "rsp", tmp_crc + 24)
    if callee == "nativeCrc32c" or raw_name == "nativeCrc32c" then
      state.asm = a.call(state.asm, "fn_native_crc32c")
    else
      state.asm = a.call(state.asm, "fn_native_crc32")
    end if
    if tmp_crc_ok then state = core.free_expr_temps(state, 32) end if
    return [state, true]
  end if

  if callee == "bytesConstantTimeEquals" or raw_name == "bytesConstantTimeEquals" then
    if nargs != 2 then
      state.diagnostics = state.diagnostics +["bytesConstantTimeEquals() expects exactly 2 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    tmp_ct = core.alloc_expr_temps(state, 16)
    tmp_ct_ok = typeof(tmp_ct) == "int" and tmp_ct > 0
    if not tmp_ct_ok then tmp_ct = 0x300 end if
    state = cg_emit_expr(state, call_args[0])
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_ct, "rax")
    state = cg_emit_expr(state, call_args[1])
    state.asm = a.mov_membase_disp_r64(state.asm, "rsp", tmp_ct + 8, "rax")
    state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", tmp_ct)
    state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", tmp_ct + 8)
    state.asm = a.call(state.asm, "fn_bytes_constant_time_eq")
    if tmp_ct_ok then state = core.free_expr_temps(state, 16) end if
    return [state, true]
  end if

  if callee == "runtimeCpuFeatures" or raw_name == "runtimeCpuFeatures" then
    if nargs != 0 then state.diagnostics = state.diagnostics +["runtimeCpuFeatures() expects no arguments"] end if
    if nargs == 0 then state.asm = a.call(state.asm, "fn_runtime_cpu_features") else state.asm = a.mov_rax_imm64(state.asm, t.enc_void()) end if
    return [state, true]
  end if
  if callee == "runtimeCpuActiveFeatures" or raw_name == "runtimeCpuActiveFeatures" then
    if nargs != 0 then state.diagnostics = state.diagnostics +["runtimeCpuActiveFeatures() expects no arguments"] end if
    if nargs == 0 then state.asm = a.call(state.asm, "fn_runtime_cpu_active_features") else state.asm = a.mov_rax_imm64(state.asm, t.enc_void()) end if
    return [state, true]
  end if
  if callee == "runtimeCpuSetMask" or raw_name == "runtimeCpuSetMask" then
    if nargs != 1 then
      state.diagnostics = state.diagnostics +["runtimeCpuSetMask() expects exactly 1 argument"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    state = cg_emit_expr(state, call_args[0])
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, "fn_runtime_cpu_set_mask")
    return [state, true]
  end if

  // Builtin nativeBytesPtr(bytes) -> native pointer to the bytes payload.
  if (callee == "nativeBytesPtr" or raw_name == "nativeBytesPtr") then
    if nargs != 1 then
      state.diagnostics = state.diagnostics +["nativeBytesPtr() expects 1 argument"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_int(0))
      return [state, true]
    end if
    state = cg_emit_expr(state, call_args[0])
    lid_nb = _next_lid(state)
    l_ok_nb = "native_bytes_ptr_ok_" + lid_nb
    l_null_nb = "native_bytes_ptr_null_" + lid_nb
    l_done_nb = "native_bytes_ptr_done_" + lid_nb
    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.and_r64_imm(state.asm, "r11", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r11", c.TAG_PTR)
    state.asm = a.jcc(state.asm, "ne", l_null_nb)
    state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "rax", 0)
    state.asm = a.cmp_r32_imm(state.asm, "r11d", c.OBJ_BYTES)
    state.asm = a.jcc(state.asm, "ne", l_null_nb)
    state.asm = a.lea_r64_membase_disp(state.asm, "rax", "rax", 8)
    state.asm = a.jmp(state.asm, l_ok_nb)
    state.asm = a.mark(state.asm, l_null_nb)
    state.asm = a.xor_eax_eax(state.asm)
    state.asm = a.mark(state.asm, l_ok_nb)
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
    state.asm = a.mark(state.asm, l_done_nb)
    return [state, true]
  end if

  // Builtin nativeRawValue(value) -> MiniLang int containing the raw tagged value.
  if (callee == "nativeRawValue" or raw_name == "nativeRawValue") then
    if nargs != 1 then
      state.diagnostics = state.diagnostics +["nativeRawValue() expects 1 argument"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    state = cg_emit_expr(state, call_args[0])
    state.asm = a.shl_rax_imm8(state.asm, 3)
    state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
    return [state, true]
  end if

  // Builtin nativeValueFromRaw(int) -> MiniLang value represented by that raw word.
  if (callee == "nativeValueFromRaw" or raw_name == "nativeValueFromRaw") then
    if nargs != 1 then
      state.diagnostics = state.diagnostics +["nativeValueFromRaw() expects 1 argument"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    state = cg_emit_expr(state, call_args[0])
    lid_nv = _next_lid(state)
    l_ok_nv = "native_value_from_raw_ok_" + lid_nv
    l_done_nv = "native_value_from_raw_done_" + lid_nv
    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.and_r64_imm(state.asm, "r11", 7)
    state.asm = a.cmp_r64_imm(state.asm, "r11", c.TAG_INT)
    state.asm = a.jcc(state.asm, "e", l_ok_nv)
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    state.asm = a.jmp(state.asm, l_done_nv)
    state.asm = a.mark(state.asm, l_ok_nv)
    state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
    state.asm = a.mark(state.asm, l_done_nv)
    return [state, true]
  end if

  // Builtin nativeCallback(fn, "wndproc") -> native function pointer.
  if (callee == "nativeCallback" or raw_name == "nativeCallback") then
    if nargs != 2 then
      state.diagnostics = state.diagnostics +["nativeCallback() expects 2 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    fn_qn = _native_callback_resolve_user_fn(state, call_args[0])
    if fn_qn == "" then
      state.diagnostics = state.diagnostics +["nativeCallback: first argument must be a top-level MiniLang function"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    mode_cv = _opt_try_const_value(state, call_args[1])
    mode = ""
    if typeof(mode_cv) == "struct" and mode_cv.ok and typeof(mode_cv.value) == "string" then
      mode = s.toLowerAscii(mode_cv.value)
    end if
    if mode == "wndproc" or mode == "wndProc" then
      state = _emit_native_callback_wndproc(state, fn_qn)
      return [state, true]
    end if
    state.diagnostics = state.diagnostics +["nativeCallback: unsupported callback ABI '" + mode + "'"]
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return [state, true]
  end if

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
      if _opt_type_query_can_elide_evaluation(arg0) == false then state = cg_emit_expr(state, arg0) end if
      state.asm = a.mark(state.asm, "known_type_label_fast_" + _next_lid(state))
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
          bp_t = t.arr_drop_last(ps_t)
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
      if _opt_type_query_can_elide_evaluation(arg1) == false then state = cg_emit_expr(state, arg1) end if
      state.asm = a.mark(state.asm, "known_type_label_fast_" + _next_lid(state))
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
          bp_n = t.arr_drop_last(ps_n)
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
    state.asm = a.call(state.asm, "fn_heap_bytes_committed")
    return [state, true]
  end if

  if (callee == "heap_bytes_reserved" or raw_name == "heap_bytes_reserved") then
    if nargs != 0 then
      state.diagnostics = state.diagnostics +["heap_bytes_reserved() expects 0 arguments"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return [state, true]
    end if
    state.asm = a.call(state.asm, "fn_heap_bytes_reserved")
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

function _emit_native_value_helper_call(state, callee, raw_name, call_args, nargs)
  nm = callee
  if raw_name != "" then nm = raw_name end if
  lbl = ""
  arity = 0

  if nm == "stringSlice" then
    lbl = "fn_string_slice"
    arity = 3
  end if
  if nm == "bytesStartsWith" then
    lbl = "fn_bytes_startswith"
    arity = 2
  end if
  if nm == "bytesHash" then
    lbl = "fn_bytes_hash"
    arity = 1
  end if
  if nm == "stringHash" then
    lbl = "fn_string_hash"
    arity = 1
  end if
  if nm == "str" then
    lbl = "fn_value_to_string"
    arity = 1
  end if
  if nm == "bytesEndsWith" then
    lbl = "fn_bytes_endswith"
    arity = 2
  end if
  if nm == "bytesIndexOf" then
    lbl = "fn_bytes_indexof"
    arity = 3
  end if
  if nm == "bytesLastIndexOf" then
    lbl = "fn_bytes_lastindexof"
    arity = 2
  end if
  if nm == "bytesCompare" then
    lbl = "fn_bytes_compare"
    arity = 2
  end if
  if nm == "stringIndexOf" then
    lbl = "fn_string_indexof"
    arity = 3
  end if
  if nm == "stringLastIndexOf" then
    lbl = "fn_string_lastindexof"
    arity = 2
  end if
  if nm == "stringStartsWith" then
    lbl = "fn_string_startswith"
    arity = 2
  end if
  if nm == "stringEndsWith" then
    lbl = "fn_string_endswith"
    arity = 2
  end if
  if nm == "stringRepeat" then
    lbl = "fn_string_repeat"
    arity = 2
  end if
  if nm == "stringTrimLeftAscii" then
    lbl = "fn_string_ltrim_ascii"
    arity = 1
  end if
  if nm == "stringTrimRightAscii" then
    lbl = "fn_string_rtrim_ascii"
    arity = 1
  end if
  if nm == "stringTrimAscii" then
    lbl = "fn_string_trim_ascii"
    arity = 1
  end if
  if nm == "stringIsBlankAscii" then
    lbl = "fn_string_is_blank_ascii"
    arity = 1
  end if
  if nm == "stringReverse" then
    lbl = "fn_string_reverse"
    arity = 1
  end if
  if nm == "stringToLowerAscii" then
    lbl = "fn_string_to_lower_ascii"
    arity = 1
  end if
  if nm == "stringToUpperAscii" then
    lbl = "fn_string_to_upper_ascii"
    arity = 1
  end if
  if nm == "stringEqualsIgnoreCaseAscii" then
    lbl = "fn_string_eq_ignore_case_ascii"
    arity = 2
  end if
  if nm == "stringJoin" then
    lbl = "fn_string_join"
    arity = 2
  end if

  if lbl == "" or nargs != arity then return [state, false] end if

  if arity == 1 then
    state = cg_emit_expr(state, call_args[0])
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.call(state.asm, lbl)
    return [state, true]
  end if

  tmp_off = core.alloc_expr_temps(state, arity * 8)
  for i = 0 to arity - 1
    state = cg_emit_expr(state, call_args[i])
    state.asm = a.mov_rsp_disp32_rax(state.asm, tmp_off + i * 8)
  end for
  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", tmp_off)
  state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", tmp_off + 8)
  if arity == 3 then
    state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", tmp_off + 16)
  end if
  state.asm = a.call(state.asm, lbl)
  state = core.free_expr_temps(state, arity * 8)
  return [state, true]
end function

function _expr_heap_cfg_bool(state, key, defaultv)
  if typeof(state) != "struct" or typeof(state.heap_config) != "array" or len(state.heap_config) <= 0 then return defaultv end if
  for ci = 0 to len(state.heap_config) - 1
    it = state.heap_config[ci]
    if typeof(it) == "array" and len(it) >= 2 and typeof(it[0]) == "string" and it[0] == key then
      if typeof(it[1]) == "bool" then return it[1] end if
      return defaultv
    end if
  end for
  return defaultv
end function

function _direct_user_call_enabled(state, qname)
  // Keep the old unguarded fast path available for controlled experiments,
  // but do not use it by default: a top-level function binding can legally be
  // rebound at runtime.  The guarded path below preserves that behaviour.
  return _expr_heap_cfg_bool(state, "cg_unguarded_direct_user_calls", false)
end function

function _emit_expr_call_generic(state, cal, callee, raw_name, call_args, nargs, member_runtime)
  skip_call_args_eval = false
  direct_struct_constructor = false
  direct_user_global = false
  direct_user_name = ""
  generic_nonmember_candidate = false
  compiletime_member_callable = false
  cal_kind_skip = _coerce_name(t.ast_kind(cal))
  if cal_kind_skip == "Member" and member_runtime == false then
    compiletime_member_callable = true
  end if
  if t.ast_is_node(cal) and cal_kind_skip != "Member" then
    skip_qn = callee
    if skip_qn == "" then skip_qn = raw_name end if
    if skip_qn != "" then
      skip_fn = _user_function_get(state, skip_qn)
      if typeof(skip_fn) == "struct" then
        skip_bind = scope.cg_resolve_binding(state, skip_qn)
        if (typeof(skip_bind) != "struct" or skip_bind.kind == "global") and _direct_user_call_enabled(state, skip_qn) then
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
        if special_qn == "nativeBytesPtr" then is_special = true end if
        if special_qn == "nativeRawValue" then is_special = true end if
        if special_qn == "nativeValueFromRaw" then is_special = true end if
        if special_qn == "nativeCallback" then is_special = true end if
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

  if raw_name == "" and t.ast_kind(cal) == "Member" then
    raw_name = _expr_to_qualname(state, cal)
  end if

  handled_generic_builtin = _emit_generic_call_builtin_cases(state, callee, raw_name, call_args, nargs, call_args_base)
  if typeof(handled_generic_builtin) == "array" and len(handled_generic_builtin) >= 2 then
    state = handled_generic_builtin[0]
    if handled_generic_builtin[1] then return state end if
  end if

  inline_name = callee
  if inline_name == "" then inline_name = raw_name end if
  inline_fn = _user_function_get(state, inline_name)
  inline_used_bytes = 0
  if typeof(state._inline_emitted_bytes) == "struct" then
    inline_used_bytes = t.fastmap_get(state._inline_emitted_bytes, inline_name, 0)
    if typeof(inline_used_bytes) != "int" then inline_used_bytes = 0 end if
  end if
  if inline_used_bytes < 4096 and typeof(inline_fn) == "struct" and _function_wants_inline(inline_fn) and _call_args_have_stack_variadic(call_args) == false and _inline_call_eligible(inline_fn) then
    inline_binding = scope.cg_resolve_binding(state, inline_name)
    if typeof(inline_binding) != "struct" or inline_binding.kind == "global" then
      state = _emit_inline_call(state, inline_name, call_args)
      state = _emit_auto_errprop(state)
      return state
    end if
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
      field_contracts = _state_struct_field_types_get(state, scallee)
      for fi = 0 to nargs - 1
        guarded_arg = call_args[fi]
        if typeof(field_contracts) == "array" and fi < len(field_contracts) then
          contract = field_contracts[fi]
          if typeof(contract) == "array" and len(contract) >= 2 and typeof(contract[0]) == "string" then
            guarded_arg = ml.TypeGuard("TypeGuard", guarded_arg, contract[0], contract[1], t.ast_pos(call_args[fi]), t.ast_filename(call_args[fi]))
          end if
        end if
        state = cg_emit_expr(state, guarded_arg)
        state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", base_struct)
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8 + fi * 8, "rax")
      end for
    end if
    state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", base_struct)
    if base_struct_ok then state = core.free_expr_temps(state, 8) end if
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

  // Direct extern calls may omit trailing `out` parameters. Full-arity calls
  // keep using the first-class OBJ_BUILTIN stub for backward compatibility.
  ext_name = callee
  ext_sig = _extern_sig_get(state, ext_name)
  if typeof(ext_sig) != "struct" and raw_name != "" then
    ext_name = raw_name
    ext_sig = _extern_sig_get(state, ext_name)
  end if
  if typeof(ext_sig) == "struct" then
    ext_binding = scope.cg_resolve_binding(state, ext_name)
    if typeof(ext_binding) != "struct" or ext_binding.kind == "global" then
      ext_params = try(ext_sig.params)
      if typeof(ext_params) != "array" then ext_params = [] end if
      ext_total = len(ext_params)
      ext_required = ext_total
      while ext_required > 0
        ep = ext_params[ext_required - 1]
        if typeof(ep) != "struct" or typeof(try(ep.is_out)) != "bool" or ep.is_out == false then break end if
        ext_required = ext_required - 1
      end while
      if nargs < ext_required or nargs > ext_total then
        want = "" + ext_total
        if ext_required != ext_total then want = "" + ext_required + ".." + ext_total end if
        state.diagnostics = state.diagnostics + ["Extern " + ext_name + " expects " + want + " args, got " + nargs]
        state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
        return state
      end if
      if nargs < ext_total then
        state = _emit_extern_call(state, cal, call_args, "", ext_name, t.ast_pos(cal))
        state = _emit_auto_errprop(state)
        return state
      end if
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
  if t.ast_kind(cal) == "Member" then
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
          // Guarded devirtualization preserves runtime rebinding semantics.
          // Canonical .mlo fragments support the same cross-fragment rel32
          // relocations, so both pipelines make the same lowering choice.
          obj_lbl_dg = _strpair_get(state.function_static_obj_labels, dg_name)
          if obj_lbl_dg != "" then
            direct_guard_obj_lbl = obj_lbl_dg
            direct_guard_call_lbl = "fn_user_" + dg_name
            direct_guard_builtin_nargs = false
          end if
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
    stack_varargs_nm = []
    stack_vararg_bytes_nm = 0
    if typeof(call_args) == "array" and len(call_args) > 0 then
      for sva_i = 0 to len(call_args) - 1
        sva_arg = call_args[sva_i]
        if typeof(sva_arg) == "struct" and t.ast_kind(sva_arg) == "ArrayLit" and typeof(try(sva_arg.stack_variadic)) == "bool" and sva_arg.stack_variadic then
          stack_varargs_nm = stack_varargs_nm + [[sva_i, sva_arg, stack_vararg_bytes_nm]]
          sva_items = try(sva_arg.items)
          if typeof(sva_items) != "array" then sva_items = [] end if
          stack_vararg_bytes_nm = stack_vararg_bytes_nm + 8 + len(sva_items) * 8
        end if
      end for
    end if
    temp_bytes_nm = (nargs + 1) * 8 + diag_extra_nm + stack_vararg_bytes_nm
    base_nm = core.alloc_expr_temps(state, temp_bytes_nm)
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

    // Match the Python frontend's evaluation order: preserve the callee first,
    // then initialize the call-scoped variadic views before evaluating args.
    stack_region_nm = base_nm + (nargs + 1) * 8 + diag_extra_nm
    if len(stack_varargs_nm) > 0 then
      for sva_i = 0 to len(stack_varargs_nm) - 1
        sva_rec = stack_varargs_nm[sva_i]
        sva_items = try(sva_rec[1].items)
        if typeof(sva_items) != "array" then sva_items = [] end if
        sva_base = stack_region_nm + sva_rec[2]
        state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", sva_base, c.OBJ_ARRAY_IMM, false)
        state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", sva_base + 4, len(sva_items), false)
        if len(sva_items) > 0 then
          for svi = 0 to len(sva_items) - 1
            state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", sva_base + 8 + svi * 8, t.enc_void(), true)
          end for
        end if
      end for
    end if

    if nargs > 0 then
      for argi_nm = 0 to nargs - 1
        if skip_call_args_eval then
          arg_nm = call_args[argi_nm]
          if typeof(arg_nm) == "int" and arg_nm == 0 then
            state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
          else
            stack_match_nm = -1
            if len(stack_varargs_nm) > 0 then
              for sva_i = 0 to len(stack_varargs_nm) - 1
                if stack_varargs_nm[sva_i][0] == argi_nm then stack_match_nm = sva_i; break end if
              end for
            end if
            if stack_match_nm >= 0 then
              sva_rec = stack_varargs_nm[stack_match_nm]
              sva_items = try(sva_rec[1].items)
              if typeof(sva_items) != "array" then sva_items = [] end if
              sva_base = stack_region_nm + sva_rec[2]
              if len(sva_items) > 0 then
                for svi = 0 to len(sva_items) - 1
                  state = cg_emit_expr(state, sva_items[svi])
                  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", sva_base + 8 + svi * 8, "rax")
                end for
              end if
              state.asm = a.lea_r64_membase_disp(state.asm, "rax", "rsp", sva_base)
            else
              state = cg_emit_expr(state, arg_nm)
            end if
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

    state = core.free_expr_temps(state, temp_bytes_nm)
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
  // Arbitrary array elements may inline statement bodies that use the normal
  // non-volatile scratch registers without crossing an ABI call boundary.
  // Keep the managed base in its published stack-root slot throughout element
  // evaluation so a clobbered cached register can never override that root.
  base_tmp = core.alloc_expr_value_temp(state, false)
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
  fn_dbg = _coerce_name(t.ast_filename(expr))
  pos_dbg = t.ast_pos(expr)
  if fn_dbg != "" and typeof(pos_dbg) == "int" then loc = " at " + fn_dbg + ":" + pos_dbg end if
  if fn_dbg != "" and loc == "" then loc = " at " + fn_dbg end if
  ctx_dbg = _coerce_name(try(state._debug_current_function))
  if ctx_dbg == "" then ctx_dbg = _coerce_name(try(state.current_qname_prefix)) end if
  if ctx_dbg != "" then loc = loc + " in " + ctx_dbg end if
  extra = ""
  if k == "" then
    type_dbg = typeName(expr)
    kind_dbg = _coerce_name(try(expr.kind))
    name_dbg = _coerce_name(t.ast_name(expr))
    value_dbg = _coerce_name(t.ast_value(expr))
    value_ty_dbg = typeof(t.ast_value(expr))
    extra = "<missing node_kind> type=" + type_dbg + " kind=" + kind_dbg + " name=" + name_dbg + " value_type=" + value_ty_dbg + " value=" + value_dbg
  else
    value_dbg2 = _coerce_name(t.ast_value(expr))
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
  if typeof(abi_ty) == "string" then return abi_ty end if
  if typeof(abi_ty) == "struct" then
    if typeof(abi_ty.ty) == "string" then return abi_ty.ty end if
    if typeof(abi_ty.type) == "string" then return abi_ty.type end if
    if typeof(abi_ty.name) == "string" then return abi_ty.name end if
  end if
  return ""
end function

function _qname_parts(state, ex)
  qn = _expr_to_qualname(state, ex)
  if qn == "" then return [] end if
  return s.split(qn, ".")
end function

function _qname_of(state, ex)
  if t.ast_is_node(ex) == false then return "" end if

  ex_kind = _coerce_name(t.ast_kind(ex))
  if ex_kind == "Var" then
    return _qualify_identifier(state, _coerce_name(t.ast_name(ex)))
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
  if t.ast_is_node(ex) == false then return false end if
  k = _coerce_name(t.ast_kind(ex))
  if k == "Var" and typeof(t.ast_name(ex)) == "string" and t.ast_name(ex) == "this" then
    return true
  end if
  if k == "IsType" then
    return _expr_has_this(try(ex.expr))
  end if
  if k == "Member" then
    mt = try(ex.target)
    if t.ast_is_node(mt) == false then mt = try(ex.obj) end if
    if _expr_has_this(mt) then return true end if
  end if
  if k == "Unary" then
    return _expr_has_this(t.ast_right(ex))
  end if
  if k == "Bin" then
    return _expr_has_this(t.ast_left(ex)) or _expr_has_this(t.ast_right(ex))
  end if
  if k == "Call" then
    cal = try(ex.callee)
    if t.ast_is_node(cal) == false then cal = try(ex.func) end if
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
  if t.ast_is_node(try(node.expr)) then
    if _contains_nested_fn(node.expr) then return true end if
  end if
  if t.ast_is_node(t.ast_left(node)) then
    if _contains_nested_fn(t.ast_left(node)) then return true end if
  end if
  if t.ast_is_node(t.ast_right(node)) then
    if _contains_nested_fn(t.ast_right(node)) then return true end if
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
  sync_cleanup_depth = 0
  if typeof(state.errprop_sync_depth) == "int" then sync_cleanup_depth = state.errprop_sync_depth end if

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

  if sync_cleanup_depth > 0 then
    for cleanup_i = 1 to sync_cleanup_depth
      state.asm = a.call(state.asm, "fn_sync_leave")
    end for
    if state.in_function and typeof(state.func_ret_label) == "string" and state.func_ret_label != "" then
      state.asm = a.jmp(state.asm, state.func_ret_label)
    else
      state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
      state.asm = a.call(state.asm, "fn_unhandled_error_exit")
    end if
  else if core.defer_cold_block(state, l_cold, _emit_auto_errprop_cold_block) then
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
  raw_ty = s.trim(_abi_ty_to_str(abi_ty))
  ty = s.toLowerAscii(raw_ty)
  if typeof(_extern_struct_get(state, raw_ty)) == "struct" then ty = "ptr" end if
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
    state.asm = a.call_rip_qword(state.asm, "iat_MultiByteToWideChar")
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

  if ty == "double" then
    state = core.emit_force_xmm0_to_float_value(state)
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

function _emit_extern_out_from_stack(state, abi_ty, stack_off, pos)
  ty_raw = s.trim(_abi_ty_to_str(abi_ty))
  ty = s.toLowerAscii(ty_raw)
  ext = _extern_struct_get(state, ty_raw)
  if typeof(ext) == "struct" then
    fields = try(ext.fields)
    types = try(ext.types)
    offsets = try(ext.offsets)
    if typeof(fields) != "array" or typeof(types) != "array" or typeof(offsets) != "array" or len(fields) != len(types) or len(fields) != len(offsets) then
      state.diagnostics = state.diagnostics + ["Invalid extern struct layout for '" + ty_raw + "'"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return state
    end if
    sid = _state_struct_id_get(state, ty_raw, 0)
    if sid == 0 then
      state.diagnostics = state.diagnostics + ["Invalid extern struct layout for '" + ty_raw + "'"]
      state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
      return state
    end if
    base_off = core.alloc_expr_temps(state, 8)
    state.asm = a.mov_rcx_imm32(state.asm, 8 + len(fields) * 8)
    state.asm = a.call(state.asm, "fn_alloc")
    state.asm = a.mov_rsp_disp32_rax(state.asm, base_off)
    state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRUCT, false)
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, sid, false)
    if len(fields) > 0 then
      for efi = 0 to len(fields) - 1
        state = _emit_extern_out_from_stack(state, types[efi], stack_off + offsets[efi], pos)
        state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", base_off)
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8 + efi * 8, "rax")
      end for
    end if
    state.asm = a.mov_rax_rsp_disp32(state.asm, base_off)
    state = core.release_expr_temps(state, 8)
    return state
  end if

  if ty == "double" then
    state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm0", "rsp", stack_off)
    return core.emit_force_xmm0_to_float_value(state)
  end if
  if ty == "i32" or ty == "u32" or ty == "bool" then
    state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rsp", stack_off)
  else
    state.asm = a.mov_rax_rsp_disp32(state.asm, stack_off)
  end if
  if ty == "bytes" or ty == "buffer" or ty == "bytebuffer" then ty = "ptr" end if
  return _emit_extern_ret_from_native(state, ty, "", pos)
end function

function _emit_extern_call(state, call_node, args, out_kind, out_name, pos)
  threaded_native = state.native_threads_possible
  qn = ""
  if typeof(out_name) == "string" then qn = out_name end if
  if qn == "" and typeof(call_node) == "struct" then
    cal = try(call_node.callee)
    if t.ast_is_node(cal) == false then cal = try(call_node.func) end if
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
  native_nargs = len(ps)
  if nargs > native_nargs then
    state.diagnostics = state.diagnostics + ["Extern call arity mismatch: " + qn + " expects " + len(ps) + " args, got " + nargs]
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return state
  end if
  omitted = native_nargs - nargs
  if omitted > 0 then
    for ovi = nargs to native_nargs - 1
      op = ps[ovi]
      if typeof(op) != "struct" or typeof(try(op.is_out)) != "bool" or op.is_out == false then
        state.diagnostics = state.diagnostics + ["Extern call arity mismatch: " + qn + " expects " + len(ps) + " args, got " + nargs]
        state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
        return state
      end if
    end for
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

  l_fail = "L_extern_fail_" + _next_lid(state)
  l_cleanup = "L_extern_cleanup_" + _next_lid(state)
  l_done = "L_extern_done_" + _next_lid(state)
  wpool = ["widebuf", "widebuf1", "widebuf2", "widebuf3"]
  root_base = 0
  root_alloc = false
  if nargs > 0 then
    root_base = core.alloc_expr_temps(state, nargs * 8)
    if typeof(root_base) == "int" and root_base > 0 then
      root_alloc = true
    else
      root_base = 0
    end if
  end if

  out_offsets = array(native_nargs, 0)
  out_bytes = 0
  if omitted > 0 then
    for obi = nargs to native_nargs - 1
      oty = s.trim(_abi_ty_to_str(ps[obi]))
      olayout = _extern_struct_get(state, oty)
      osize = 8
      oalign = 8
      if typeof(olayout) == "struct" then
        if typeof(olayout.size) == "int" and olayout.size > 0 then osize = olayout.size end if
        if typeof(olayout.align) == "int" and olayout.align > 0 then oalign = olayout.align end if
      end if
      out_bytes = t.align_up(out_bytes, oalign)
      out_offsets[obi] = out_bytes
      padded = t.align_up(osize, 8)
      if padded < 8 then padded = 8 end if
      out_bytes = out_bytes + padded
    end for
  end if
  out_base = 0
  out_alloc = false
  if out_bytes > 0 then
    out_base = core.alloc_expr_temps(state, out_bytes)
    if typeof(out_base) == "int" and out_base > 0 then out_alloc = true end if
    for oz = 0 to (out_bytes / 8) - 1
      state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", out_base + oz * 8, 0, true)
    end for
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
    if root_base > 0 then
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", root_base + i * 8, "rax")
    end if
    if aty_l == "wstr" or aty_l == "wstring" then
      wbuf = wpool[i % len(wpool)]
    end if
    if aty_l == "double" then
      state = core.emit_to_double_xmm(state, 0, l_fail)
      state.asm = a.movsd_membase_disp_xmm(state.asm, "rsp", state.call_temp_base + i * 8, "xmm0")
    else
      state = _emit_extern_arg_to_native(state, pp, l_fail, pos, wbuf)
      state.asm = a.shl_rax_imm8(state.asm, 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", state.call_temp_base + i * 8, "rax")
    end if
    i = i + 1
  end while

  if omitted > 0 then
    for opi = nargs to native_nargs - 1
      state.asm = a.lea_r64_membase_disp(state.asm, "rax", "rsp", out_base + out_offsets[opi])
      state.asm = a.shl_rax_imm8(state.asm, 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", state.call_temp_base + opi * 8, "rax")
    end for
  end if

  // Native code may block indefinitely. Publish a stable stack-root chain
  // before entering it so stop-the-world GC need not wait for the OS call.
  if threaded_native then state.asm = a.call(state.asm, "fn_gc_native_enter") end if

  if native_nargs >= 1 then
    aty0 = _coerce_name(ps[0])
    if typeof(ps[0]) == "struct" then
      aty0 = _coerce_name(ps[0].ty)
      if aty0 == "" then aty0 = _coerce_name(ps[0].type) end if
      if aty0 == "" then aty0 = _coerce_name(ps[0].abi_ty) end if
    end if
    if s.toLowerAscii(s.trim(aty0)) == "double" then
      state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm0", "rsp", state.call_temp_base + 0 * 8)
    else
      state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", state.call_temp_base + 0 * 8)
      state.asm = a.sar_r64_imm8(state.asm, "rcx", 3)
    end if
  end if
  if native_nargs >= 2 then
    aty1 = _coerce_name(ps[1])
    if typeof(ps[1]) == "struct" then
      aty1 = _coerce_name(ps[1].ty)
      if aty1 == "" then aty1 = _coerce_name(ps[1].type) end if
      if aty1 == "" then aty1 = _coerce_name(ps[1].abi_ty) end if
    end if
    if s.toLowerAscii(s.trim(aty1)) == "double" then
      state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm1", "rsp", state.call_temp_base + 1 * 8)
    else
      state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", state.call_temp_base + 1 * 8)
      state.asm = a.sar_r64_imm8(state.asm, "rdx", 3)
    end if
  end if
  if native_nargs >= 3 then
    aty2 = _coerce_name(ps[2])
    if typeof(ps[2]) == "struct" then
      aty2 = _coerce_name(ps[2].ty)
      if aty2 == "" then aty2 = _coerce_name(ps[2].type) end if
      if aty2 == "" then aty2 = _coerce_name(ps[2].abi_ty) end if
    end if
    if s.toLowerAscii(s.trim(aty2)) == "double" then
      state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm2", "rsp", state.call_temp_base + 2 * 8)
    else
      state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", state.call_temp_base + 2 * 8)
      state.asm = a.sar_r64_imm8(state.asm, "r8", 3)
    end if
  end if
  if native_nargs >= 4 then
    aty3 = _coerce_name(ps[3])
    if typeof(ps[3]) == "struct" then
      aty3 = _coerce_name(ps[3].ty)
      if aty3 == "" then aty3 = _coerce_name(ps[3].type) end if
      if aty3 == "" then aty3 = _coerce_name(ps[3].abi_ty) end if
    end if
    if s.toLowerAscii(s.trim(aty3)) == "double" then
      state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm3", "rsp", state.call_temp_base + 3 * 8)
    else
      state.asm = a.mov_r64_membase_disp(state.asm, "r9", "rsp", state.call_temp_base + 3 * 8)
      state.asm = a.sar_r64_imm8(state.asm, "r9", 3)
    end if
  end if
  ext_stack_save_off = 0
  ext_stack_save_count = 0
  ext_stack_save_alloc = false
  if native_nargs > 8 then
    ext_stack_save_count = native_nargs - 8
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
  if native_nargs > 4 then
    si = 4
    while si < native_nargs
      state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", state.call_temp_base + si * 8)
      sty = _coerce_name(ps[si])
      if typeof(ps[si]) == "struct" then
        sty = _coerce_name(ps[si].ty)
        if sty == "" then sty = _coerce_name(ps[si].type) end if
        if sty == "" then sty = _coerce_name(ps[si].abi_ty) end if
      end if
      if s.toLowerAscii(s.trim(sty)) != "double" then
        state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
      end if
      state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20 + (si - 4) * 8, "rax")
      si = si + 1
    end while
  end if

  state.asm = a.call_rip_qword(state.asm, _extern_iat_label(dll, sym))
  if threaded_native then state.asm = a.call(state.asm, "fn_gc_native_leave") end if
  if omitted > 0 then
    out_ok = "L_extern_out_ok_" + _next_lid(state)
    if s.toLowerAscii(s.trim(_abi_ty_to_str(sig.ret_ty))) == "bool" then
      state.asm = a.test_r64_r64(state.asm, "rax", "rax")
      state.asm = a.jcc(state.asm, "ne", out_ok)
      state = _emit_make_error_const(state, c.ERR_EXTERN_CONVERSION, "Extern out call failed: " + qn + " returned false")
      state.asm = a.jmp(state.asm, l_cleanup)
      state.asm = a.mark(state.asm, out_ok)
    end if
    if omitted == 1 then
      oi = nargs
      state = _emit_extern_out_from_stack(state, ps[oi], out_base + out_offsets[oi], pos)
    else
      arr_root = core.alloc_expr_temps(state, 8)
      state.asm = a.mov_rcx_imm32(state.asm, 8 + omitted * 8)
      state.asm = a.call(state.asm, "fn_alloc")
      state.asm = a.mov_rsp_disp32_rax(state.asm, arr_root)
      state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_ARRAY, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, omitted, false)
      for omi = 0 to omitted - 1
        oi2 = nargs + omi
        state = _emit_extern_out_from_stack(state, ps[oi2], out_base + out_offsets[oi2], pos)
        state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", arr_root)
        state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8 + omi * 8, "rax")
      end for
      state.asm = a.mov_rax_rsp_disp32(state.asm, arr_root)
      state = core.release_expr_temps(state, 8)
    end if
  else
    state = _emit_extern_ret_from_native(state, sig.ret_ty, l_fail, pos)
  end if
  state.asm = a.jmp(state.asm, l_cleanup)

  state.asm = a.mark(state.asm, l_fail)
  state = _emit_make_error_const(state, c.ERR_EXTERN_CONVERSION, "Extern call failed: " + qn + " (argument type mismatch or conversion failure)")

  state.asm = a.mark(state.asm, l_cleanup)
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
  if out_alloc then
    state = core.release_expr_temps(state, out_bytes)
  end if
  if root_alloc then
    state = core.release_expr_temps(state, nargs * 8)
  end if
  state.asm = a.mark(state.asm, l_done)
  return state
end function

function _inline_collect_expr_stats(ex, stats)
  if t.ast_is_node(ex) == false then return 0 end if
  k = _coerce_name(t.ast_kind(ex))
  if k == "Num" or k == "Str" or k == "Bool" or k == "VoidLit" or k == "Var" then return 1 end if
  if k == "ArrayLit" then
    cost = 4
    items = try(ex.items)
    if typeof(items) == "array" and len(items) > 0 then
      for i = 0 to len(items) - 1
        cost = cost + _inline_collect_expr_stats(items[i], stats)
      end for
    end if
    return cost
  end if
  if k == "Unary" then return 2 + _inline_collect_expr_stats(t.ast_right(ex), stats) end if
  if k == "Bin" then return 3 + _inline_collect_expr_stats(t.ast_left(ex), stats) + _inline_collect_expr_stats(t.ast_right(ex), stats) end if
  if k == "IsType" then return 3 + _inline_collect_expr_stats(try(ex.expr), stats) end if
  if k == "Call" then
    stats.call_count = stats.call_count + 1
    args = try(ex.args)
    if typeof(args) != "array" then args = [] end if
    if len(args) > stats.max_call_args then stats.max_call_args = len(args) end if
    cost2 = 12 + _inline_collect_expr_stats(try(ex.callee), stats)
    if len(args) > 0 then
      for i2 = 0 to len(args) - 1
        cost2 = cost2 + _inline_collect_expr_stats(args[i2], stats)
      end for
    end if
    return cost2
  end if
  if k == "Index" then return 5 + _inline_collect_expr_stats(try(ex.target), stats) + _inline_collect_expr_stats(try(ex.index), stats) end if
  if k == "Member" then return 4 + _inline_collect_expr_stats(try(ex.target), stats) end if
  return 8
end function

function _inline_collect_stmt_list_stats(stmts, stats)
  cost = 0
  if typeof(stmts) != "array" or len(stmts) <= 0 then return cost end if
  for si = 0 to len(stmts) - 1
    cost = cost + _inline_collect_stmt_stats(stmts[si], stats)
  end for
  return cost
end function

function _inline_collect_stmt_stats(st, stats)
  if typeof(st) != "struct" then return 0 end if
  k = _coerce_name(try(st.node_kind))
  if k == "GlobalDecl" then return 0 end if
  stats.stmt_count = stats.stmt_count + 1
  if k == "Assign" or k == "ConstDecl" or k == "ExprStmt" then return 2 + _inline_collect_expr_stats(try(st.expr), stats) end if
  if k == "Print" then return 4 + _inline_collect_expr_stats(try(st.expr), stats) end if
  if k == "Return" then return 1 + _inline_collect_expr_stats(try(st.expr), stats) end if
  if k == "Defer" then
    stats.has_nested_fn = true
    return 24 + _inline_collect_expr_stats(try(st.expr), stats)
  end if
  if k == "SetMember" then return 6 + _inline_collect_expr_stats(try(st.obj), stats) + _inline_collect_expr_stats(try(st.expr), stats) end if
  if k == "SetIndex" then return 7 + _inline_collect_expr_stats(try(st.target), stats) + _inline_collect_expr_stats(try(st.index), stats) + _inline_collect_expr_stats(try(st.expr), stats) end if
  if k == "If" then
    elifs = try(st.elifs)
    if typeof(elifs) != "array" then elifs = [] end if
    else_body = try(st.else_body)
    if typeof(else_body) != "array" then else_body = [] end if
    stats.branch_count = stats.branch_count + 1 + len(elifs)
    if len(else_body) > 0 then stats.branch_count = stats.branch_count + 1 end if
    cost3 = 8 + _inline_collect_expr_stats(try(st.cond), stats)
    cost3 = cost3 + _inline_collect_stmt_list_stats(try(st.then_body), stats)
    if len(elifs) > 0 then
      for ei = 0 to len(elifs) - 1
        el = elifs[ei]
        if typeof(el) == "array" and len(el) >= 2 then
          cost3 = cost3 + 4 + _inline_collect_expr_stats(el[0], stats)
          cost3 = cost3 + _inline_collect_stmt_list_stats(el[1], stats)
        end if
      end for
    end if
    cost3 = cost3 + _inline_collect_stmt_list_stats(else_body, stats)
    return cost3
  end if
  if k == "While" or k == "DoWhile" or k == "For" then
    stats.has_loop = true
    cost4 = 48
    if k == "While" or k == "DoWhile" then cost4 = cost4 + _inline_collect_expr_stats(try(st.cond), stats) end if
    if k == "For" then
      cost4 = cost4 + _inline_collect_expr_stats(try(st.start), stats)
      cost4 = cost4 + _inline_collect_expr_stats(try(st.end_expr), stats)
    end if
    return cost4 + _inline_collect_stmt_list_stats(try(st.body), stats)
  end if
  if k == "ForEach" or k == "ForEachArray" or k == "ForEachString" then
    stats.has_loop = true
    return 48 + _inline_collect_expr_stats(try(st.iterable), stats) + _inline_collect_stmt_list_stats(try(st.body), stats)
  end if
  if k == "Switch" then
    stats.has_switch = true
    cost5 = 56 + _inline_collect_expr_stats(try(st.expr), stats)
    cases = try(st.cases)
    if typeof(cases) == "array" and len(cases) > 0 then
      for ci = 0 to len(cases) - 1
        cs = cases[ci]
        if typeof(cs) != "struct" then continue end if
        vals = try(cs.values)
        if typeof(vals) == "array" and len(vals) > 0 then
          for vi = 0 to len(vals) - 1
            cost5 = cost5 + _inline_collect_expr_stats(vals[vi], stats)
          end for
        else
          cost5 = cost5 + _inline_collect_expr_stats(try(cs.range_start), stats)
          cost5 = cost5 + _inline_collect_expr_stats(try(cs.range_end), stats)
        end if
        cost5 = cost5 + _inline_collect_stmt_list_stats(try(cs.body), stats)
      end for
    end if
    cost5 = cost5 + _inline_collect_stmt_list_stats(try(st.default_body), stats)
    return cost5
  end if
  if k == "FunctionDef" then
    stats.has_nested_fn = true
    return 64
  end if
  if k == "Break" or k == "Continue" then return 1 end if
  return 6
end function

function _function_wants_inline(fn)
  if typeof(fn) != "struct" then return false end if
  if typeof(try(fn.is_inline)) == "bool" and fn.is_inline then return true end if
  if typeof(try(fn.is_synchronized)) == "bool" and fn.is_synchronized then return false end if
  name = _coerce_name(try(fn.name))
  generated_lambda = s.startsWith(name, "__ml_lambda_")
  variadic = try(fn.variadic_index)
  if typeof(variadic) == "int" and variadic >= 0 then return false end if
  params = try(fn.params)
  types = try(fn.param_types)
  if typeof(params) != "array" then return false end if
  if typeof(types) != "array" then types = [] end if
  if generated_lambda == false and len(params) != len(types) then return false end if
  if generated_lambda == false and len(types) > 0 then
    for i = 0 to len(types) - 1
      if typeof(types[i]) != "string" or types[i] == "" then return false end if
    end for
  end if
  fully_typed = typeof(try(fn.return_type)) == "string" and fn.return_type != ""
  if fully_typed == false and generated_lambda == false then return false end if
  body = try(fn.body)
  if typeof(body) != "array" or len(body) <= 0 or t.ast_kind(body[len(body) - 1]) != "Return" then return false end if
  if len(body) > 1 then
    for bi = 0 to len(body) - 2
      guard = body[bi]
      if t.ast_kind(guard) != "Assign" or _intflow_name_has(params, _coerce_name(try(guard.name))) == false or t.ast_kind(try(guard.expr)) != "TypeGuard" then return false end if
    end for
  end if
  return true
end function

function _call_args_have_stack_variadic(args)
  if typeof(args) != "array" or len(args) <= 0 then return false end if
  for i = 0 to len(args) - 1
    arg = args[i]
    if typeof(arg) == "struct" and t.ast_kind(arg) == "ArrayLit" and typeof(try(arg.stack_variadic)) == "bool" and arg.stack_variadic then return true end if
  end for
  return false
end function

function _inline_declared_type_fact(state, raw_type)
  if typeof(raw_type) != "string" or raw_type == "" then return "" end if
  lower = s.toLowerAscii(raw_type)
  if lower == "integer" then lower = "int" end if
  if lower == "boolean" then lower = "bool" end if
  if lower == "str" then lower = "string" end if
  if lower == "int" or lower == "float" or lower == "bool" or lower == "string" or lower == "array" or lower == "bytes" or lower == "function" or lower == "thread" or lower == "error" or lower == "void" then return lower end if
  qualified = _qualify_identifier(state, raw_type)
  if qualified == "" then qualified = raw_type end if
  return "struct:" + qualified
end function

function _inline_call_eligible(fn)
  if typeof(fn) != "struct" then return false end if
  stats = InlineStats(0, 0, 0, 0, 0, false, false, false)
  body = try(fn.body)
  if typeof(body) != "array" then body = [] end if
  stats.cost = _inline_collect_stmt_list_stats(body, stats)
  params = try(fn.params)
  if typeof(params) == "array" then stats.cost = stats.cost + len(params) end if
  if stats.has_loop or stats.has_switch or stats.has_nested_fn then return false end if
  if stats.stmt_count > 8 or stats.call_count > 2 or stats.branch_count > 2 or stats.cost > 64 then return false end if
  return true
end function

function _emit_inline_call(state, callee, args)
  // Inline expansion evaluates arguments left-to-right into persistent root
  // slots, then emits the callee in an isolated scope so caller bindings cannot
  // leak into it. Return statements target one local join label. Every saved
  // scope, root cursor and inline-recursion record is restored before returning
  // to the caller, including diagnostic exits.
  fn = _user_function_get(state, callee)
  if typeof(fn) != "struct" then
    state.diagnostics = state.diagnostics + ["Unknown inline function '" + callee + "'"]
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return state
  end if

  if typeof(state._inline_call_stack) != "array" then state._inline_call_stack = [] end if
  if len(state._inline_call_stack) > 0 then
    for ri = 0 to len(state._inline_call_stack) - 1
      if state._inline_call_stack[ri] == callee then
        state.diagnostics = state.diagnostics + ["inline recursion is not supported: " + callee]
        state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
        return state
      end if
    end for
  end if

  env_slots = try(fn._ml_env_slots)
  captures = try(fn._ml_captures)
  boxed = try(fn._ml_boxed)
  if (typeof(try(fn._ml_env_hop)) == "bool" and fn._ml_env_hop) or (typeof(env_slots) == "array" and len(env_slots) > 0) or (typeof(captures) == "array" and len(captures) > 0) or (typeof(boxed) == "array" and len(boxed) > 0) then
    state.diagnostics = state.diagnostics + ["inline function '" + callee + "' cannot use closures or boxed variables"]
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return state
  end if

  params = try(fn.params)
  if typeof(params) != "array" then params = [] end if
  if typeof(args) != "array" then args = [] end if
  if len(args) != len(params) then
    state.diagnostics = state.diagnostics + ["Function " + callee + " expects " + len(params) + " args, got " + len(args)]
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    return state
  end if

  base_top = state.expr_temp_top
  if typeof(base_top) != "int" then base_top = 0 end if
  param_base = 0
  if len(params) > 0 then param_base = core.alloc_expr_temps(state, len(params) * 8) end if
  if len(args) > 0 then
    for ai = 0 to len(args) - 1
      state = cg_emit_expr(state, args[ai])
      state.asm = a.mov_rsp_disp32_rax(state.asm, param_base + ai * 8)
    end for
  end if
  inline_body_start = a.pos(state.asm)

  l_end = "inline_end_" + _next_lid(state)

  saved_in_fn = state.in_function
  saved_ret = state.func_ret_label
  saved_scope_stack = state.scope_stack
  saved_scope_declared = state.scope_declared
  saved_scope_index_stack = state.scope_index_stack
  saved_scope_declared_index_stack = state.scope_declared_index_stack
  saved_decl_site = state.decl_site_bindings
  saved_fn_locals = state.function_locals
  saved_fn_local_ids = state.function_local_ids
  saved_func_globals = state.func_globals
  saved_func_global_map = state.func_global_map
  saved_func_global_map_index = state.func_global_map_index
  saved_qpref = state.current_qname_prefix
  saved_filepref = state.current_file_prefix
  saved_boxed = state.current_fn_boxed_names
  saved_env_index = state.current_fn_env_index
  saved_param_names = try(state.current_fn_param_names)
  saved_known_value_types = state.known_value_types
  saved_known_int_names = state.known_int_names
  saved_loop_index_fast_stack = state.loop_index_fast_stack

  base_globals = []
  if typeof(saved_scope_stack) == "array" and len(saved_scope_stack) > 0 then base_globals = saved_scope_stack[0] end if
  base_scope_index = t.fastmap_new(128)
  if typeof(saved_scope_index_stack) == "array" and len(saved_scope_index_stack) > 0 then base_scope_index = saved_scope_index_stack[0] end if
  base_decl_index = t.fastmap_new(128)
  if typeof(saved_scope_declared_index_stack) == "array" and len(saved_scope_declared_index_stack) > 0 then base_decl_index = saved_scope_declared_index_stack[0] end if

  state.scope_stack = [base_globals, []]
  state.scope_declared = [[], []]
  state.scope_index_stack = [base_scope_index, t.fastmap_new(128)]
  state.scope_declared_index_stack = [base_decl_index, t.fastmap_new(128)]
  state.decl_site_bindings = t.fastmap_new(128)
  state.function_locals = []
  state.function_local_ids = t.fastmap_new(64)
  state.func_globals = []
  state.func_global_map = []
  state.func_global_map_index = t.fastmap_new(64)
  state.current_fn_boxed_names = []
  state.current_fn_env_index = []
  state.current_fn_param_names = params
  state.in_function = true
  state.func_ret_label = l_end
  state.known_value_types = t.fastmap_new(64)
  state.known_int_names = t.fastmap_new(64)
  param_types = try(fn.param_types)
  param_optional = try(fn.param_optional)
  if typeof(param_types) != "array" then param_types = [] end if
  if typeof(param_optional) != "array" then param_optional = [] end if
  if len(params) > 0 then
    for pti = 0 to len(params) - 1
      optional = false
      if pti < len(param_optional) and typeof(param_optional[pti]) == "bool" then optional = param_optional[pti] end if
      if optional or pti >= len(param_types) then continue end if
      fact = _inline_declared_type_fact(state, param_types[pti])
      if fact == "" then continue end if
      pname = _coerce_name(params[pti])
      state.known_value_types = t.fastmap_set(state.known_value_types, pname, fact)
      if _opt_type_base(fact) == "int" then state.known_int_names = t.fastmap_set(state.known_int_names, pname, 1) end if
    end for
  end if
  state.loop_index_fast_stack = []

  dot = -1
  for qi = len(callee) - 1 to 0
    if callee[qi] == "." then
      dot = qi
      break
    end if
  end for
  if dot >= 0 then
    state.current_qname_prefix = s.substr(callee, 0, dot + 1)
  else
    state.current_qname_prefix = ""
  end if
  fn_file = try(fn._filename)
  if typeof(fn_file) == "string" and fn_file != "" then
    fp = _strpair_get(state.file_prefix_map, fn_file)
    if fp != "" then state.current_file_prefix = fp end if
  end if

  if len(params) > 0 then
    for pi = 0 to len(params) - 1
      state = scope.bind_param(state, _coerce_name(params[pi]), param_base + pi * 8, fn)
    end for
  end if

  // Keep the caller's stack in a local root and restore it unconditionally.
  // Statement emission may return a copied codegen state; relying on its field
  // to pop the active callee can therefore observe `void` in large programs.
  saved_inline_call_stack = state._inline_call_stack
  state._inline_call_stack = saved_inline_call_stack + [callee]
  emitter = state._inline_param_stack
  body = try(fn.body)
  if typeof(body) != "array" then body = [] end if
  if typeof(emitter) != "function" then
    state.diagnostics = state.diagnostics + ["Internal error: inline statement emitter is unavailable"]
  else
    if len(body) > 0 then
      for bi = 0 to len(body) - 1
        state = emitter(state, body[bi])
      end for
    end if
  end if
  state._inline_call_stack = saved_inline_call_stack

  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.mark(state.asm, l_end)
  emitted_inline_bytes = a.pos(state.asm) - inline_body_start
  if emitted_inline_bytes < 0 then emitted_inline_bytes = 0 end if
  if typeof(state._inline_emitted_bytes) != "struct" then state._inline_emitted_bytes = t.fastmap_new(128) end if
  old_inline_bytes = t.fastmap_get(state._inline_emitted_bytes, callee, 0)
  if typeof(old_inline_bytes) != "int" then old_inline_bytes = 0 end if
  state._inline_emitted_bytes = t.fastmap_set(state._inline_emitted_bytes, callee, old_inline_bytes + emitted_inline_bytes)

  state.in_function = saved_in_fn
  state.func_ret_label = saved_ret
  state.scope_stack = saved_scope_stack
  state.scope_declared = saved_scope_declared
  state.scope_index_stack = saved_scope_index_stack
  state.scope_declared_index_stack = saved_scope_declared_index_stack
  state.decl_site_bindings = saved_decl_site
  state.function_locals = saved_fn_locals
  state.function_local_ids = saved_fn_local_ids
  state.func_globals = saved_func_globals
  state.func_global_map = saved_func_global_map
  state.func_global_map_index = saved_func_global_map_index
  state.current_qname_prefix = saved_qpref
  state.current_file_prefix = saved_filepref
  state.current_fn_boxed_names = saved_boxed
  state.current_fn_env_index = saved_env_index
  state.current_fn_param_names = saved_param_names
  state.known_value_types = saved_known_value_types
  state.known_int_names = saved_known_int_names
  state.loop_index_fast_stack = saved_loop_index_fast_stack

  delta = state.expr_temp_top - base_top
  if delta > 0 then state = core.free_expr_temps(state, delta) end if
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
    state.asm = a.mov_rax_tagged_int(state.asm, value)
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
  threaded_native = state.native_threads_possible
  if threaded_native then
    state.used_helpers = state.used_helpers + ["fn_gc_native_enter", "fn_gc_native_leave"]
  end if
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
        if aty_l == "double" then
          state = core.emit_to_double_xmm(state, 0, l_fail)
          state.asm = a.movsd_membase_disp_xmm(state.asm, "rsp", native_off + ai2 * 8, "xmm0")
        else
          state = _emit_extern_arg_to_native(state, pp, l_fail, pos, wbuf)
          state.asm = a.mov_membase_disp_r64(state.asm, "rsp", native_off + ai2 * 8, "rax")
        end if
      end for
    end if

    if threaded_native then state.asm = a.call(state.asm, "fn_gc_native_enter") end if

    regs = ["rcx", "rdx", "r8", "r9"]
    xregs = ["xmm0", "xmm1", "xmm2", "xmm3"]
    lim = nargs
    if lim > 4 then lim = 4 end if
    if lim > 0 then
      for ri = 0 to lim - 1
        rty = _coerce_name(params[ri])
        if typeof(params[ri]) == "struct" then
          rty = _coerce_name(params[ri].ty)
          if rty == "" then rty = _coerce_name(params[ri].type) end if
          if rty == "" then rty = _coerce_name(params[ri].abi_ty) end if
        end if
        if s.toLowerAscii(s.trim(rty)) == "double" then
          state.asm = a.movsd_xmm_membase_disp(state.asm, xregs[ri], "rsp", native_off + ri * 8)
        else
          state.asm = a.mov_r64_membase_disp(state.asm, regs[ri], "rsp", native_off + ri * 8)
        end if
      end for
    end if
    if nargs > 4 then
      for si = 4 to nargs - 1
        state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", native_off + si * 8)
        state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20 + (si - 4) * 8, "rax")
      end for
    end if

    state.asm = a.call_rip_qword(state.asm, _extern_iat_label(dll, sym))
    if threaded_native then state.asm = a.call(state.asm, "fn_gc_native_leave") end if
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
