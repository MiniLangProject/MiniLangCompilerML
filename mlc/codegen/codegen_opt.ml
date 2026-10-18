/*
Copyright 2026 Nils Kopal

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

//! Bounded, fail-closed local lifetime and escape analysis.
package mlc.codegen.codegen_opt
import mlc.tools as t
import mlc.codegen.codegen_scope as scope
import std.fs as fs
import std.string as s

/// ASCII token predicate; non-ASCII declaration names are never pruned.
/// @param value ASCII byte value to classify.
function name_byte(value)
  return (value >= 65 and value <= 90) or (value >= 97 and value <= 122) or (value >= 48 and value <= 57) or value == 95
end function

/// Prove source-unreferenced functions, conservatively counting comments and
/// strings too. Methods, generated names and profiling retain native bodies.
/// @param state Code-generation state with loaded source and declaration metadata.
function unused_functions(state)
  result = t.fastmap_new(64)
  if state.call_profile then return result end if
  files = t.fastmap_new(64)
  files = t.fastmap_set(files, state.filename, 1)
  for each entry in t.fastmap_items(state.file_prefix_map) files = t.fastmap_set(files, entry[0], 1) end for
  for each entry in state.user_functions
    filename = t.ast_filename(entry[1])
    if typeof(filename) == "string" and filename != "" then files = t.fastmap_set(files, filename, 1) end if
  end for
  counts = t.fastmap_new(1024)
  declarations = t.fastmap_new(256)
  for each file_entry in t.fastmap_items(files)
    if file_entry[0] == "" then continue end if
    source = fs.readAllBytes(file_entry[0])
    if typeof(source) != "bytes" then return result end if
    position = 0
    pending = false
    while position < len(source)
      if name_byte(source[position]) == false then position = position + 1; continue end if
      start = position
      while position < len(source) and name_byte(source[position]) position = position + 1 end while
      name = decode(slice(source, start, position - start))
      count = t.fastmap_get(counts, name, 0)
      if count < 2 then counts = t.fastmap_set(counts, name, count + 1) end if
      if pending and name != "inline" and name != "synchronized" and name != "static" then
        count = t.fastmap_get(declarations, name, 0)
        if count < 2 then declarations = t.fastmap_set(declarations, name, count + 1) end if
        pending = false
      end if
      if name == "function" then pending = true end if
    end while
  end for
  for each entry in state.user_functions
    qname = entry[0]
    dot = s.lastIndexOf(qname, ".")
    parent = ""
    name = qname
    if dot >= 0 then parent = s.substr(qname, 0, dot); name = s.substr(qname, dot + 1, len(qname) - dot - 1) end if
    if name == "main" or s.contains(qname, "__") then continue end if
    method = false
    for each fields in state.struct_fields
      key = try(fields.key)
      if typeof(fields) == "array" and len(fields) > 0 then key = fields[0] end if
      if key == parent then method = true end if
    end for
    if method then continue end if
    if t.fastmap_get(counts, name, 0) == 1 and t.fastmap_get(declarations, name, 0) == 1 then result = t.fastmap_set(result, qname, true) end if
  end for
  return result
end function

/// One AST use and its containing top-level statement.
struct Access
  node,
  parent,
  index,
end struct

/// Enumerate supported semantic children. Unknown syntax disables optimization.
/// @param node AST node or arena handle to inspect.
function children(node)
  k = t.ast_kind(node)
  if k == "Num" or k == "Str" or k == "Bool" or k == "VoidLit" or k == "Var" or k == "Break" or k == "Continue" then return [] end if
  if k == "Unary" then return [t.ast_right(node)] end if
  if k == "Bin" then return [t.ast_left(node), t.ast_right(node)] end if
  if k == "Coalesce" then return [node.left, node.right] end if
  // The native parser represents a bare return by integer zero; Python uses
  // None. It is an absent child, not unsupported syntax (arena IDs are negative).
  if k == "Return" and typeof(node.expr) == "int" and node.expr == 0 then return [] end if
  if k == "IsType" or k == "TypeGuard" or k == "Assign" or k == "ConstDecl" or k == "Print" or k == "ExprStmt" or k == "Return" then return [node.expr] end if
  if k == "Call" then return [node.callee, node.args] end if
  if k == "Member" then return [node.target] end if
  if k == "Index" then return [node.target, node.index] end if
  if k == "ArrayLit" then return [node.items] end if
  if k == "SetMember" then return [node.obj, node.expr] end if
  if k == "SetIndex" then return [node.target, node.index, node.expr] end if
  if k == "If" then return [node.cond, node.then_body, node.elifs, node.else_body] end if
  if k == "While" or k == "DoWhile" then return [node.cond, node.body] end if
  if k == "For" then return [node.start, node.end_expr, node.body] end if
  if k == "ForEach" then return [node.iterable, node.body] end if
  return void
end function

/// Return bounded AST uses, or void for unsupported syntax. Loops stay atomic.
/// @param body Ordered top-level statements of one function.
function accesses(body)
  work = t.arr_vec_new(64)
  if len(body) > 0 then
    for i = 0 to len(body) - 1 work = t.arr_vec_push(work, Access(body[i], void, i)) end for
  end if
  output = t.arr_vec_new(64)
  cursor = 0
  while cursor < work.size
    item = work.data[cursor]
    cursor = cursor + 1
    node = item.node
    if typeof(node) == "void" then continue end if
    if typeof(node) == "array" then
      for each child in node work = t.arr_vec_push(work, Access(child, item.parent, item.index)) end for
      continue
    end if
    parts = children(node)
    if typeof(parts) != "array" or output.size >= 4096 then return void end if
    output = t.arr_vec_push(output, item)
    for each child in parts work = t.arr_vec_push(work, Access(child, node, item.index)) end for
  end while
  return t.arr_vec_finish(output)
end function

/// Whole-top-level-statement lifetimes, conservative across loops and branches.
/// @param body Ordered function statements used to bound local lifetimes.
function intervals(body)
  records = accesses(body)
  if typeof(records) != "array" then return void end if
  result = t.fastmap_new(64)
  for each item in records
    node = item.node
    kind = t.ast_kind(node)
    name = ""
    if kind == "Var" then name = t.ast_name(node) end if
    if kind == "Assign" or kind == "ConstDecl" then name = node.name end if
    if kind == "For" or kind == "ForEach" then name = node.var end if
    if name == "" then continue end if
    old = t.fastmap_get(result, name, void)
    if typeof(old) != "array" then old = [item.index, item.index, 0, 0, false] end if
    if item.index < old[0] then old[0] = item.index end if
    if item.index > old[1] then old[1] = item.index end if
    if kind == "For" or kind == "ForEach" then old[4] = true end if
    // Extra mirrors must amortize one GPR-to-XMM transfer per store. Require
    // at least three explicit loop reads per write; cheap accumulators stay
    // in their existing two homes/stack slots instead of slowing down.
    top_kind = t.ast_kind(body[item.index])
    if top_kind == "For" or top_kind == "ForEach" or top_kind == "While" or top_kind == "DoWhile" then
      metric = 3
      if kind == "Var" then metric = 2 end if
      old[metric] = old[metric] + 1
    end if
    result = t.fastmap_set(result, name, old)
  end for
  return result
end function

/// Reject every use except known field reads/writes after the constructor.
/// @param records Bounded AST access records for the function.
/// @param declaration Original local constructor assignment.
/// @param index Top-level statement index of the constructor.
/// @param fields Known untyped field names in declaration order.
function scalar_uses(records, declaration, index, fields)
  name = declaration.name
  for each item in records
    node = item.node
    k = t.ast_kind(node)
    if (k == "Assign" or k == "ConstDecl") and node.name == name and node != declaration then return false end if
    if (k == "For" or k == "ForEach") and node.var == name then return false end if
    if k != "Var" or t.ast_name(node) != name then continue end if
    parent = item.parent
    pk = t.ast_kind(parent)
    field = ""
    if pk == "Member" and parent.target == node then field = parent.name end if
    if pk == "SetMember" and parent.obj == node then field = parent.field end if
    found = false
    for each known in fields if field == known then found = true end if end for
    if found == false or item.index <= index then return false end if
  end for
  return true
end function

/// Resolve a scalar field only for its original lexical binding, not inline shadows.
/// @param state Current lexical bindings and scalar-replacement plans.
/// @param target Receiver expression of the field access.
/// @param field Field name to resolve to a rooted stack slot.
function scalar_slot(state, target, field)
  if t.ast_kind(target) != "Var" or len(state._inline_call_stack) > 0 then return -1 end if
  binding = scope.cg_resolve_binding(state, t.ast_name(target))
  if typeof(binding) != "struct" then return -1 end if
  for each plan in state.scalar_structs
    if binding.id != plan[1].id then continue end if
    for i = 0 to len(plan[2]) - 1
      if plan[2][i] == field then return plan[3][i] end if
    end for
  end for
  return -1
end function
