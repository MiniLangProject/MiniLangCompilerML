// Dependency-light integer, path, hashing and chunked-builder utilities.
package mlc.tools

import mlc.constants as c

// Copy immutable string payloads directly into paged byte buffers. MiniLang's
// collector is non-moving, so both managed objects remain stable for the
// duration of this synchronous native copy.
#if TARGET_OS == "windows"
extern function _copy_native_bytes(destination as ptr, source as ptr, count as u64) from "kernel32.dll" symbol "RtlMoveMemory" returns ptr
#else
extern function _copy_native_bytes(destination as ptr, source as ptr, count as u64) from "libc.so.6" symbol "memmove" returns ptr
#endif

// Return every array element except the last one. The builtin slice() operates
// on bytes, so compiler data structures must use an explicit array copy.
function arr_drop_last(values)
  if typeof(values) != "array" or len(values) <= 1 then return [] end if
  output = array(len(values) - 1, void)
  for i = 0 to len(output) - 1
    output[i] = values[i]
  end for
  return output
end function

// Append-only array builder that avoids copying a growing prefix.
struct ArrayChunkBuilder
  chunks,
  tail,
  cap,
end struct

// Partially filled final chunk with explicit logical length.
struct ArrayChunkTail
  data,
  used,
  cap,
end struct

// Internal marker that preserves actual void values inside spare capacity.
struct ArrayChunkVoidSentinel
  tag,
end struct

// Capacity-backed mutable sequence for compiler-internal hot paths.  MiniLang
// arrays have exact length, so repeatedly doing `items = items + [value]`
// copies the complete prefix.  ArrayVector grows geometrically and is
// materialized only at API boundaries.
struct ArrayVector
  data,
  size,
  cap,
end struct

// Paged byte buffer used by large assembler and linker outputs.
struct BytePages
  chunk_pages,
  chunk_tail,
  size,
end struct

// Compiler-internal open-addressing map with power-of-two capacity.
struct FastMap
  keys,
  values,
  used,
  cap,
  size,
  epoch,
  touched,
end struct

_arr_void_sentinel = ArrayChunkVoidSentinel(0xA11D)

// Compact arena for immutable expression leaves. Negative integers are stable
// NodeIds; ordinary non-negative MiniLang values therefore never collide with
// compiler AST handles. The structure-of-arrays layout keeps source locations,
// variable symbols and kinds out of individual managed structs.
const AST_LEAF_NUM = 1
const AST_LEAF_STR = 2
const AST_LEAF_BOOL = 3
const AST_LEAF_VOID = 4
const AST_LEAF_VAR = 5
const AST_BIN_HANDLE_BASE = 1073741824

_ast_leaf_kinds = bytes(0)
_ast_leaf_payloads = []
_ast_leaf_positions = bytes(0)
_ast_leaf_file_ids = bytes(0)
_ast_leaf_symbol_ids = bytes(0)
_ast_leaf_count = 0
_ast_leaf_cap = 0
_ast_filenames = 0
_ast_filename_index = 0
_ast_symbols = 0
_ast_symbol_index = 0
_ast_bin_lefts = []
_ast_bin_rights = []
_ast_bin_op_ids = bytes(0)
_ast_bin_positions = bytes(0)
_ast_bin_file_ids = bytes(0)
_ast_bin_count = 0
_ast_bin_cap = 0

function _ast_u32_write(buf, index, value)
  off = index << 2
  buf[off] = value & 0xFF
  buf[off + 1] = (value >> 8) & 0xFF
  buf[off + 2] = (value >> 16) & 0xFF
  buf[off + 3] = (value >> 24) & 0xFF
end function

function inline _ast_u32_read(buf, index)
  off = index << 2
  return buf[off] | (buf[off + 1] << 8) | (buf[off + 2] << 16) | (buf[off + 3] << 24)
end function

// Drop every compilation-owned compact AST column and intern table. This is a
// bulk ownership boundary: callers must release only after code generation no
// longer holds or dereferences NodeIds from this arena.
function ast_arena_release()
  global _ast_leaf_kinds, _ast_leaf_payloads, _ast_leaf_positions
  global _ast_leaf_file_ids, _ast_leaf_symbol_ids, _ast_leaf_count, _ast_leaf_cap
  global _ast_filenames, _ast_filename_index, _ast_symbols, _ast_symbol_index
  global _ast_bin_lefts, _ast_bin_rights, _ast_bin_op_ids
  global _ast_bin_positions, _ast_bin_file_ids, _ast_bin_count, _ast_bin_cap
  _ast_leaf_kinds = bytes(0)
  _ast_leaf_payloads = []
  _ast_leaf_positions = bytes(0)
  _ast_leaf_file_ids = bytes(0)
  _ast_leaf_symbol_ids = bytes(0)
  _ast_leaf_count = 0
  _ast_leaf_cap = 0
  _ast_filenames = 0
  _ast_filename_index = 0
  _ast_symbols = 0
  _ast_symbol_index = 0
  _ast_bin_lefts = []
  _ast_bin_rights = []
  _ast_bin_op_ids = bytes(0)
  _ast_bin_positions = bytes(0)
  _ast_bin_file_ids = bytes(0)
  _ast_bin_count = 0
  _ast_bin_cap = 0
end function

function ast_leaf_reset()
  global _ast_filenames, _ast_filename_index, _ast_symbols, _ast_symbol_index
  ast_arena_release()
  _ast_filenames = arr_vec_new(64)
  _ast_filename_index = fastmap_new(128)
  _ast_symbols = arr_vec_new(1024)
  _ast_symbol_index = fastmap_new(2048)
end function

function _ast_bin_ensure(need)
  global _ast_bin_lefts, _ast_bin_rights, _ast_bin_op_ids
  global _ast_bin_positions, _ast_bin_file_ids, _ast_bin_cap
  if need <= _ast_bin_cap then return void end if
  next_cap = _ast_bin_cap
  if next_cap < 4096 then next_cap = 4096 end if
  while next_cap < need
    next_cap = next_cap << 1
  end while
  next_lefts = array(next_cap, 0)
  next_rights = array(next_cap, 0)
  next_ops = bytes(next_cap * 4, 0)
  next_positions = bytes(next_cap * 4, 0)
  next_files = bytes(next_cap * 4, 0)
  if _ast_bin_cap > 0 and _ast_bin_count > 0 then
    copyArray(next_lefts, 0, _ast_bin_lefts, 0, _ast_bin_count)
    copyArray(next_rights, 0, _ast_bin_rights, 0, _ast_bin_count)
    copyBytes(next_ops, 0, _ast_bin_op_ids, 0, _ast_bin_count * 4)
    copyBytes(next_positions, 0, _ast_bin_positions, 0, _ast_bin_count * 4)
    copyBytes(next_files, 0, _ast_bin_file_ids, 0, _ast_bin_count * 4)
  end if
  _ast_bin_lefts = next_lefts
  _ast_bin_rights = next_rights
  _ast_bin_op_ids = next_ops
  _ast_bin_positions = next_positions
  _ast_bin_file_ids = next_files
  _ast_bin_cap = next_cap
end function

function _ast_leaf_ensure(need)
  global _ast_leaf_kinds, _ast_leaf_payloads, _ast_leaf_positions
  global _ast_leaf_file_ids, _ast_leaf_symbol_ids, _ast_leaf_cap
  if need <= _ast_leaf_cap then return void end if
  next_cap = _ast_leaf_cap
  if next_cap < 65536 then next_cap = 65536 end if
  while next_cap < need
    next_cap = next_cap << 1
  end while
  next_kinds = bytes(next_cap, 0)
  next_payloads = array(next_cap, 0)
  next_positions = bytes(next_cap * 4, 0)
  next_files = bytes(next_cap * 4, 0)
  next_symbols = bytes(next_cap * 4, 0)
  if _ast_leaf_cap > 0 and _ast_leaf_count > 0 then
    copyBytes(next_kinds, 0, _ast_leaf_kinds, 0, _ast_leaf_count)
    copyArray(next_payloads, 0, _ast_leaf_payloads, 0, _ast_leaf_count)
    copyBytes(next_positions, 0, _ast_leaf_positions, 0, _ast_leaf_count * 4)
    copyBytes(next_files, 0, _ast_leaf_file_ids, 0, _ast_leaf_count * 4)
    copyBytes(next_symbols, 0, _ast_leaf_symbol_ids, 0, _ast_leaf_count * 4)
  end if
  _ast_leaf_kinds = next_kinds
  _ast_leaf_payloads = next_payloads
  _ast_leaf_positions = next_positions
  _ast_leaf_file_ids = next_files
  _ast_leaf_symbol_ids = next_symbols
  _ast_leaf_cap = next_cap
end function

function _ast_intern(index_map, values, text)
  existing = fastmap_get(index_map, text, 0)
  if typeof(existing) == "int" and existing > 0 then return [index_map, values, existing] end if
  id = arr_vec_count(values) + 1
  values = arr_vec_push(values, text)
  index_map = fastmap_set(index_map, text, id)
  return [index_map, values, id]
end function

function _ast_leaf_kind_id(kind)
  if kind == "Num" then return AST_LEAF_NUM end if
  if kind == "Str" then return AST_LEAF_STR end if
  if kind == "Bool" then return AST_LEAF_BOOL end if
  if kind == "VoidLit" then return AST_LEAF_VOID end if
  if kind == "Var" then return AST_LEAF_VAR end if
  return 0
end function

function _ast_leaf_kind_name(kind_id)
  if kind_id == AST_LEAF_NUM then return "Num" end if
  if kind_id == AST_LEAF_STR then return "Str" end if
  if kind_id == AST_LEAF_BOOL then return "Bool" end if
  if kind_id == AST_LEAF_VOID then return "VoidLit" end if
  if kind_id == AST_LEAF_VAR then return "Var" end if
  return ""
end function

function ast_leaf_new(kind, value, pos, filename)
  global _ast_leaf_count, _ast_leaf_payloads, _ast_filename_index, _ast_filenames
  global _ast_symbol_index, _ast_symbols
  global _ast_leaf_kinds, _ast_leaf_positions, _ast_leaf_file_ids, _ast_leaf_symbol_ids
  kind_id = _ast_leaf_kind_id(kind)
  if kind_id <= 0 then return 0 end if
  if _ast_leaf_cap <= 0 then ast_leaf_reset() end if
  slot = _ast_leaf_count
  _ast_leaf_ensure(slot + 1)
  file_text = filename
  if typeof(file_text) != "string" then file_text = "" end if
  fi = _ast_intern(_ast_filename_index, _ast_filenames, file_text)
  _ast_filename_index = fi[0]
  _ast_filenames = fi[1]
  file_id = fi[2]
  symbol_id = 0
  payload = value
  if kind_id == AST_LEAF_VAR then
    symbol_text = value
    if typeof(symbol_text) != "string" then symbol_text = "" + symbol_text end if
    si = _ast_intern(_ast_symbol_index, _ast_symbols, symbol_text)
    _ast_symbol_index = si[0]
    _ast_symbols = si[1]
    symbol_id = si[2]
    payload = 0
  end if
  _ast_leaf_kinds[slot] = kind_id
  _ast_leaf_payloads[slot] = payload
  _ast_u32_write(_ast_leaf_positions, slot, pos)
  _ast_u32_write(_ast_leaf_file_ids, slot, file_id)
  _ast_u32_write(_ast_leaf_symbol_ids, slot, symbol_id)
  _ast_leaf_count = slot + 1
  return 0 - (slot + 1)
end function

// Binary expressions are the most frequent composite AST node. Store their
// children and metadata in a typed structure-of-arrays arena while retaining
// the same accessors for compiler-created legacy structs.
function ast_bin_new(left, op, right, pos, filename)
  global _ast_bin_lefts, _ast_bin_rights, _ast_bin_op_ids
  global _ast_bin_positions, _ast_bin_file_ids, _ast_bin_count
  global _ast_filename_index, _ast_filenames, _ast_symbol_index, _ast_symbols
  if typeof(_ast_filename_index) != "struct" then ast_leaf_reset() end if
  slot = _ast_bin_count
  _ast_bin_ensure(slot + 1)
  file_text = filename
  if typeof(file_text) != "string" then file_text = "" end if
  fi = _ast_intern(_ast_filename_index, _ast_filenames, file_text)
  _ast_filename_index = fi[0]
  _ast_filenames = fi[1]
  op_text = op
  if typeof(op_text) != "string" then op_text = "" + op_text end if
  oi = _ast_intern(_ast_symbol_index, _ast_symbols, op_text)
  _ast_symbol_index = oi[0]
  _ast_symbols = oi[1]
  _ast_bin_lefts[slot] = left
  _ast_bin_rights[slot] = right
  _ast_u32_write(_ast_bin_op_ids, slot, oi[2])
  _ast_u32_write(_ast_bin_positions, slot, pos)
  _ast_u32_write(_ast_bin_file_ids, slot, fi[2])
  _ast_bin_count = slot + 1
  return 0 - (AST_BIN_HANDLE_BASE + slot + 1)
end function

function inline ast_is_leaf(node)
  if typeof(node) != "int" or node >= 0 then return false end if
  slot = (0 - node) - 1
  return slot >= 0 and slot < _ast_leaf_count
end function

function inline ast_is_bin(node)
  if typeof(node) != "int" or node >= 0 then return false end if
  slot = (0 - node) - AST_BIN_HANDLE_BASE - 1
  return slot >= 0 and slot < _ast_bin_count
end function

function ast_is_node(node)
  if ast_is_leaf(node) or ast_is_bin(node) then return true end if
  return typeof(node) == "struct" and typeof(try(node.node_kind)) == "string"
end function

function ast_kind(node)
  if ast_is_leaf(node) then
    return _ast_leaf_kind_name(_ast_leaf_kinds[(0 - node) - 1])
  end if
  if ast_is_bin(node) then return "Bin" end if
  if typeof(node) == "struct" and typeof(try(node.node_kind)) == "string" then return node.node_kind end if
  return ""
end function

function ast_value(node)
  if ast_is_leaf(node) then return _ast_leaf_payloads[(0 - node) - 1] end if
  if typeof(node) == "struct" then return try(node.value) end if
  return void
end function

function ast_name(node)
  if ast_is_leaf(node) then
    slot = (0 - node) - 1
    if _ast_leaf_kinds[slot] != AST_LEAF_VAR then return "" end if
    symbol_id = _ast_u32_read(_ast_leaf_symbol_ids, slot)
    return arr_vec_get(_ast_symbols, symbol_id - 1, "")
  end if
  if typeof(node) == "struct" then return try(node.name) end if
  return ""
end function

function ast_pos(node)
  if ast_is_leaf(node) then return _ast_u32_read(_ast_leaf_positions, (0 - node) - 1) end if
  if ast_is_bin(node) then return _ast_u32_read(_ast_bin_positions, (0 - node) - AST_BIN_HANDLE_BASE - 1) end if
  if typeof(node) == "struct" and typeof(try(node._pos)) == "int" then return node._pos end if
  return 0
end function

function ast_filename(node)
  if ast_is_leaf(node) then
    file_id = _ast_u32_read(_ast_leaf_file_ids, (0 - node) - 1)
    return arr_vec_get(_ast_filenames, file_id - 1, "")
  end if
  if ast_is_bin(node) then
    file_id = _ast_u32_read(_ast_bin_file_ids, (0 - node) - AST_BIN_HANDLE_BASE - 1)
    return arr_vec_get(_ast_filenames, file_id - 1, "")
  end if
  if typeof(node) == "struct" and typeof(try(node._filename)) == "string" then return node._filename end if
  return ""
end function

function ast_left(node)
  if ast_is_bin(node) then return _ast_bin_lefts[(0 - node) - AST_BIN_HANDLE_BASE - 1] end if
  if typeof(node) == "struct" and typeof(try(node.node_kind)) == "string" and node.node_kind == "Bin" then return node.left end if
  return void
end function

function ast_right(node)
  if ast_is_bin(node) then return _ast_bin_rights[(0 - node) - AST_BIN_HANDLE_BASE - 1] end if
  if typeof(node) == "struct" and typeof(try(node.node_kind)) == "string" and (node.node_kind == "Bin" or node.node_kind == "Unary") then return node.right end if
  return void
end function

function ast_op(node)
  if ast_is_bin(node) then
    op_id = _ast_u32_read(_ast_bin_op_ids, (0 - node) - AST_BIN_HANDLE_BASE - 1)
    if op_id > 0 and op_id <= arr_vec_count(_ast_symbols) then return arr_vec_get(_ast_symbols, op_id - 1, "") end if
    return ""
  end if
  if typeof(node) == "struct" and typeof(try(node.node_kind)) == "string" and (node.node_kind == "Bin" or node.node_kind == "Unary") then return node.op end if
  return ""
end function

function ast_leaf_stats()
  payload_bytes = _ast_leaf_cap * 8
  packed_bytes = _ast_leaf_cap * 13
  bin_bytes = _ast_bin_cap * 28
  return [_ast_leaf_count, _ast_leaf_cap, arr_vec_count(_ast_symbols), arr_vec_count(_ast_filenames), payload_bytes + packed_bytes + bin_bytes, _ast_bin_count, _ast_bin_cap, bin_bytes]
end function

// ArrayVector operations keep append-heavy planning tables capacity-backed.
function arr_vec_is(value)
  if typeof(value) != "struct" then return false end if
  if typeof(try(value.data)) != "array" then return false end if
  if typeof(try(value.size)) != "int" then return false end if
  if typeof(try(value.cap)) != "int" then return false end if
  return true
end function

function arr_vec_new(initial_cap)
  ccap = initial_cap
  if typeof(ccap) != "int" or ccap < 4 then ccap = 4 end if
  return ArrayVector(array(ccap, _arr_void_sentinel), 0, ccap)
end function

function arr_vec_count(vec)
  if arr_vec_is(vec) == false then return 0 end if
  n = vec.size
  if n < 0 then return 0 end if
  if n > len(vec.data) then return len(vec.data) end if
  return n
end function

// Reset a compiler-internal vector without discarding its capacity. Stale
// backing slots are intentionally left in place: compiler worklists normally
// reference the still-live AST, and overwriting the active prefix on the next
// pass is cheaper than clearing the complete high-water capacity.
function arr_vec_clear(vec)
  v = vec
  if arr_vec_is(v) == false then return arr_vec_new(4) end if
  v.size = 0
  return v
end function

// Reset a transient vector and remove every managed reference from its backing
// store.  Ordinary arr_vec_clear deliberately retains stale slots for speed;
// compiler phase arenas must use this stronger form before a collection so a
// high-water worklist cannot keep already emitted AST nodes alive.
function arr_vec_release_refs(vec)
  v = vec
  if arr_vec_is(v) == false then return arr_vec_new(4) end if
  if typeof(v.data) == "array" and len(v.data) > 0 then
    for i = 0 to len(v.data) - 1
      v.data[i] = _arr_void_sentinel
    end for
  end if
  v.size = 0
  return v
end function

function arr_vec_get(vec, idx, defaultv)
  if arr_vec_is(vec) == false then return defaultv end if
  n = arr_vec_count(vec)
  if typeof(idx) != "int" or idx < 0 or idx >= n then return defaultv end if
  return _arr_unwrap_value(vec.data[idx])
end function

function arr_vec_set(vec, idx, value)
  v = vec
  if arr_vec_is(v) == false then return v end if
  n = arr_vec_count(v)
  if typeof(idx) != "int" or idx < 0 or idx >= n then return v end if
  v.data[idx] = _arr_wrap_value(value)
  return v
end function

function arr_vec_push(vec, value)
  v = vec
  if arr_vec_is(v) == false then v = arr_vec_new(4) end if
  n = arr_vec_count(v)
  if n >= v.cap or n >= len(v.data) then
    next_cap = v.cap << 1
    if next_cap < 4 then next_cap = 4 end if
    while next_cap <= n
      next_cap = next_cap << 1
    end while
    next_data = array(next_cap, _arr_void_sentinel)
    if n > 0 then
      for i = 0 to n - 1
        next_data[i] = v.data[i]
      end for
    end if
    v.data = next_data
    v.cap = next_cap
  end if
  v.data[n] = _arr_wrap_value(value)
  v.size = n + 1
  return v
end function

function arr_vec_from_array(values, extra_cap)
  n = 0
  if typeof(values) == "array" then n = len(values) end if
  extra = extra_cap
  if typeof(extra) != "int" or extra < 0 then extra = 0 end if
  v = arr_vec_new(n + extra)
  if n > 0 then
    for i = 0 to n - 1
      v.data[i] = _arr_wrap_value(values[i])
    end for
  end if
  v.size = n
  return v
end function

function arr_vec_finish(vec)
  if arr_vec_is(vec) == false then
    if typeof(vec) == "array" then return vec end if
    return []
  end if
  n = arr_vec_count(vec)
  if n <= 0 then return [] end if
  // Reuse the chunk-tail materializer: its fast path is one linear copy, and
  // its sentinel path is the language-supported way to retain actual void
  // elements (direct index assignment of void is intentionally rejected).
  return _arr_tail_to_array(ArrayChunkTail(vec.data, n, vec.cap))
end function

function _u64_mask() returns int
  // All bits set without a large out-of-range source literal.
  return 0 - 1
end function

function _fm_next_pow2(n)
  p = 16
  if typeof(n) != "int" or n <= 0 then return p end if
  while p < n
    p = p << 1
  end while
  return p
end function

function _fm_hash_any(key)
  if typeof(key) == "int" then
    return key & 0x7FFFFFFF
  end if
  if typeof(key) == "bool" then
    if key then return 1 end if
    return 0
  end if

  // These builtins execute the same FNV-1a loop in the native runtime without
  // allocating a converted byte copy for every map access.  FastMap capacities
  // are powers of two, so the historical 31-bit mask preserves identical slots.
  if typeof(key) == "bytes" then return bytesHash(key) & 0x7FFFFFFF end if
  if typeof(key) == "string" then return stringHash(key) & 0x7FFFFFFF end if

  bs = bytes(0)
  txt = ""
  if typeof(key) == "struct" then
    node_kind = try(key.node_kind)
    if typeof(node_kind) == "string" then txt = node_kind end if
    kind = try(key.kind)
    if txt == "" and typeof(kind) == "string" then txt = kind end if
    name = try(key.name)
    if typeof(name) == "string" and name != "" then
      if txt != "" then txt = txt + ":" end if
      txt = txt + name
    end if
    key_name = try(key.key)
    if txt == "" and typeof(key_name) == "string" then txt = key_name end if
    filename = try(key._filename)
    if typeof(filename) == "string" and filename != "" then
      if txt != "" then txt = txt + "@" end if
      txt = txt + filename
      pos = try(key._pos)
      if typeof(pos) == "int" then txt = txt + ":" + pos end if
    end if
    value = try(key.value)
    if txt == "" and typeof(value) == "string" then txt = value end if
    if txt == "" then txt = "struct" end if
  else
    if typeof(key) == "array" then
      txt = "array:" + len(key)
    else
      if typeof(key) == "void" then
        txt = "void"
      else
        txt = typeof(key)
      end if
    end if
  end if
  bs = bytes(txt)
  return bytesHash(bs) & 0x7FFFFFFF
end function

function _fm_is_valid(mapv)
  if typeof(mapv) != "struct" then return false end if
  if typeof(mapv.keys) != "array" then return false end if
  if typeof(mapv.values) != "array" then return false end if
  if typeof(mapv.used) != "bytes" then return false end if
  if typeof(mapv.cap) != "int" or mapv.cap <= 0 then return false end if
  if typeof(mapv.epoch) != "int" or mapv.epoch <= 0 then return false end if
  if len(mapv.keys) != mapv.cap then return false end if
  if len(mapv.values) != mapv.cap then return false end if
  if len(mapv.used) != mapv.cap then return false end if
  return true
end function

// FastMap operations use deterministic hashing and linear probing.
function fastmap_new(initial_cap)
  cap = _fm_next_pow2(initial_cap)
  // Slot generations need one byte, not one fully tagged array cell. Large
  // compiler maps therefore spend 1/17 rather than 8/24 of their backing
  // storage on occupancy metadata while keys and values remain unchanged.
  return FastMap(_arr_fill(cap, ""), _arr_fill(cap, 0), bytes(cap, 0), cap, 0, 1, 0)
end function

// Enable precise reference release only for phase-local maps. Production
// symbol and label indexes retain the O(1) insertion path and do not pay for a
// touched-slot side vector they never need to reset strongly.
function fastmap_track_refs(mapv)
  m = mapv
  if _fm_is_valid(m) == false then m = fastmap_new(64) end if
  if arr_vec_is(try(m.touched)) == false then
    m.touched = arr_vec_new(16)
    // Tracking may be enabled on an already populated map by callers outside
    // the compiler workspace. Seed its current live slots once so the first
    // strong release cannot leave pre-tracking references behind.
    if m.size > 0 then
      for i = 0 to m.cap - 1
        if m.used[i] == m.epoch then m.touched = arr_vec_push(m.touched, i) end if
      end for
    end if
  end if
  return m
end function

function fastmap_clear(mapv)
  m = mapv
  if _fm_is_valid(m) == false then return fastmap_new(64) end if
  next_epoch = m.epoch + 1
  // Byte epochs wrap after 254 clears; retain the deterministic full-array
  // reset so a very long-lived compiler process can never revive stale slots.
  if next_epoch <= 0 or next_epoch >= 255 then
    if typeof(m.used) == "bytes" and len(m.used) > 0 then
      for i = 0 to len(m.used) - 1
        m.used[i] = 0
      end for
    end if
    next_epoch = 1
  end if
  m.epoch = next_epoch
  m.size = 0
  return m
end function

// Reset a transient map including stale generations.  Epoch-only clearing is
// O(1), but its old key/value cells remain visible to the tracing collector.
// Batch arenas call this at ownership boundaries, trading one linear sweep for
// prompt reclamation of large analysis graphs.
function fastmap_release_refs(mapv)
  m = mapv
  if _fm_is_valid(m) == false then return fastmap_new(64) end if
  touched = try(m.touched)
  if arr_vec_is(touched) then
    n = arr_vec_count(touched)
    if n > 0 then
      for i = 0 to n - 1
        idx = arr_vec_get(touched, i, -1)
        if typeof(idx) == "int" and idx >= 0 and idx < m.cap then
          m.keys[idx] = ""
          m.values[idx] = 0
          m.used[idx] = 0
        end if
      end for
    end if
    m.touched = arr_vec_release_refs(touched)
  else
    // Compatibility fallback for a map produced by an older bootstrap image.
    if m.cap > 0 then
      for i = 0 to m.cap - 1
        m.keys[i] = ""
        m.values[i] = 0
        m.used[i] = 0
      end for
    end if
    m.touched = arr_vec_new(16)
  end if
  m.size = 0
  m.epoch = 1
  return m
end function

function _fm_probe_slot(mapv, key)
  if _fm_is_valid(mapv) == false then return [-1, false] end if
  mask = mapv.cap - 1
  idx = _fm_hash_any(key) & mask
  steps = 0
  while steps < mapv.cap
    if mapv.used[idx] != mapv.epoch then return [idx, false] end if
    if mapv.keys[idx] == key then return [idx, true] end if
    idx = (idx + 1) & mask
    steps = steps + 1
  end while
  return [-1, false]
end function

function _fm_insert_no_resize(mapv, key, value)
  used_arr = mapv.used
  keys_arr = mapv.keys
  vals_arr = mapv.values
  epoch = mapv.epoch
  if typeof(used_arr) != "bytes" then return mapv end if
  if typeof(keys_arr) != "array" then return mapv end if
  if typeof(vals_arr) != "array" then return mapv end if
  mask = mapv.cap - 1
  idx = _fm_hash_any(key) & mask
  steps = 0
  while steps < mapv.cap
    if used_arr[idx] != epoch then
      used_arr[idx] = epoch
      keys_arr[idx] = key
      vals_arr[idx] = value
      mapv.size = mapv.size + 1
      if arr_vec_is(try(mapv.touched)) then mapv.touched = arr_vec_push(mapv.touched, idx) end if
      mapv.used = used_arr
      mapv.keys = keys_arr
      mapv.values = vals_arr
      return mapv
    end if
    if keys_arr[idx] == key then
      vals_arr[idx] = value
      mapv.values = vals_arr
      return mapv
    end if
    idx = (idx + 1) & mask
    steps = steps + 1
  end while
  return mapv
end function

function _fm_rehash(mapv, new_cap)
  nm = fastmap_new(new_cap)
  if _fm_is_valid(mapv) == false then return nm end if
  if arr_vec_is(try(mapv.touched)) then nm = fastmap_track_refs(nm) end if
  for i = 0 to mapv.cap - 1
    if mapv.used[i] == mapv.epoch then
      nm = _fm_insert_no_resize(nm, mapv.keys[i], mapv.values[i])
    end if
  end for
  return nm
end function

function fastmap_set(mapv, key, value)
  m = mapv
  if _fm_is_valid(m) == false then m = fastmap_new(64) end if
  if (m.size + 1) * 10 >= m.cap * 8 then
    m = _fm_rehash(m, m.cap * 2)
  end if
  return _fm_insert_no_resize(m, key, value)
end function

function fastmap_get(mapv, key, defaultv)
  if _fm_is_valid(mapv) == false then return defaultv end if
  mask = mapv.cap - 1
  idx = _fm_hash_any(key) & mask
  steps = 0
  while steps < mapv.cap
    if mapv.used[idx] != mapv.epoch then return defaultv end if
    if mapv.keys[idx] == key then return mapv.values[idx] end if
    idx = (idx + 1) & mask
    steps = steps + 1
  end while
  return defaultv
end function

function fastmap_has(mapv, key)
  if _fm_is_valid(mapv) == false then return false end if
  mask = mapv.cap - 1
  idx = _fm_hash_any(key) & mask
  steps = 0
  while steps < mapv.cap
    if mapv.used[idx] != mapv.epoch then return false end if
    if mapv.keys[idx] == key then return true end if
    idx = (idx + 1) & mask
    steps = steps + 1
  end while
  return false
end function

function fastmap_size(mapv)
  if _fm_is_valid(mapv) == false then return 0 end if
  if typeof(mapv.size) != "int" then return 0 end if
  return mapv.size
end function

function fastmap_items(mapv)
  out_b = arr_chunk_new(64)
  if _fm_is_valid(mapv) == false then return arr_chunk_finish(out_b) end if
  for i = 0 to mapv.cap - 1
    if mapv.used[i] == mapv.epoch then
      out_b = arr_chunk_push(out_b, [mapv.keys[i], mapv.values[i]])
    end if
  end for
  return arr_chunk_finish(out_b)
end function

// Round n upward to the next power-of-two alignment boundary.
function align_up(n as int, a as int) returns int
  return (n +(a - 1)) & ~(a - 1)
end function

function align_to_mod(n, mod, target)
  r = n % mod
  pad = (target - r) % mod
  return n + pad
end function

// Serialize an unsigned 16-bit value in little-endian order.
function u16(x)
  b = bytes(2, 0)
  v = x & 0xFFFF
  b[0] = v & 0xFF
  b[1] =(v >> 8) & 0xFF
  return b
end function

// Serialize an unsigned 32-bit value in little-endian order.
function u32(x)
  b = bytes(4, 0)
  v = x & 0xFFFFFFFF
  b[0] = v & 0xFF
  b[1] =(v >> 8) & 0xFF
  b[2] =(v >> 16) & 0xFF
  b[3] =(v >> 24) & 0xFF
  return b
end function

// Serialize the low 64 bits of a value in little-endian order.
function u64(x)
  b = bytes(8, 0)
  v = x & _u64_mask()
  b[0] = v & 0xFF
  b[1] =(v >> 8) & 0xFF
  b[2] =(v >> 16) & 0xFF
  b[3] =(v >> 24) & 0xFF
  b[4] =(v >> 32) & 0xFF
  b[5] =(v >> 40) & 0xFF
  b[6] =(v >> 48) & 0xFF
  b[7] =(v >> 56) & 0xFF
  return b
end function

function enc_int(x as int) returns int
  return ((x << 3) & _u64_mask()) | c.TAG_INT
end function

function enc_bool(b)
  if b then
    return ((1 << 3) & _u64_mask()) | c.TAG_BOOL
  end if
  return c.TAG_BOOL
end function

function enc_void() returns int
  return c.TAG_VOID
end function

function enc_enum(enum_id, variant_id)
  payload = ((variant_id & 0xFFFF) << 16) | (enum_id & 0xFFFF)
  return (payload << 3) | c.TAG_ENUM
end function

function inline _f32_is_nan(v)
  return typeof(v) == "float" and v != v
end function

function inline _f32_is_inf(v)
  if typeof(v) != "float" then return false end if
  if v != v then return false end if
  d = v - v
  return d != d
end function

function try_enc_float_immediate(x)
  // Encode x as a tagged float32 immediate only when the value round-trips
  // exactly. Otherwise the compiler should fall back to a boxed double.
  v = x
  if typeof(v) == "int" then
    v = v + 0.0
  end if
  if typeof(v) != "float" then
    return
  end if

  if _f32_is_nan(v) then
    return
  end if

  sign = 0
  ax = v
  if ax < 0.0 then
    sign = 1
    ax = 0.0 - ax
  else
    if ax == 0.0 then
      sx = "" + v
      if typeof(sx) == "string" and len(sx) > 0 and sx[0] == "-" then
        sign = 1
      end if
    end if
  end if

  if _f32_is_inf(v) then
    return ((((sign << 31) | (0xFF << 23)) << 3) | c.TAG_FLOAT)
  end if

  if ax == 0.0 then
    return ((((sign << 31)) << 3) | c.TAG_FLOAT)
  end if

  e = 0
  y = ax
  while y >= 2.0
    y = y / 2.0
    e = e + 1
    if e > 127 then
      return
    end if
  end while
  while y < 1.0
    y = y * 2.0
    e = e - 1
  end while

  if e >= -126 then
    frac = y - 1.0
    mant = 0
    bit = 1 << 22
    i = 0
    while i < 23
      frac = frac * 2.0
      if frac >= 1.0 then
        mant = mant | bit
        frac = frac - 1.0
      end if
      bit = bit >> 1
      i = i + 1
    end while
    if frac != 0.0 then return end if

    exp_field = e + 127
    if exp_field <= 0 or exp_field >= 255 then return end if
    return ((((sign << 31) | (exp_field << 23) | mant) << 3) | c.TAG_FLOAT)
  end if

  scaled = ax
  i = 0
  while i < 149
    scaled = scaled * 2.0
    i = i + 1
  end while

  mant = 0
  bit = 1 << 22
  p = 4194304.0
  i = 0
  while i < 23
    if scaled >= p then
      mant = mant | bit
      scaled = scaled - p
    end if
    bit = bit >> 1
    p = p / 2.0
    i = i + 1
  end while
  if scaled != 0.0 then return end if
  return ((((sign << 31) | mant) << 3) | c.TAG_FLOAT)
end function

function _arr_fill(n, fill)
  if typeof(n) != "int" or n <= 0 then return [] end if
  // Modern runtimes allocate and initialize the final array in one native
  // operation. The old doubling builder existed only for early bootstraps.
  return array(n, fill)
end function

function _arr_copy_prefix(arr, n)
  if typeof(arr) != "array" or n <= 0 then return [] end if
  outv = _arr_fill(n, 0)
  for i = 0 to n - 1
    outv[i] = arr[i]
  end for
  return outv
end function

function _arr_wrap_value(value)
  if typeof(value) == "void" then
    return _arr_void_sentinel
  end if
  return value
end function

function _arr_unwrap_value(value)
  if typeof(value) == "struct" and value == _arr_void_sentinel then
    return
  end if
  if typeof(value) == "void" then
    return
  end if
  return value
end function

function _arr_tail_new(cap)
  ccap = cap
  if typeof(ccap) != "int" or ccap <= 0 then ccap = 64 end if
  return ArrayChunkTail(_arr_fill(ccap, 0), 0, ccap)
end function

function _arr_tail_from_array(arr, cap)
  t = _arr_tail_new(cap)
  if typeof(arr) != "array" or len(arr) <= 0 then return t end if
  copy_n = len(arr)
  if copy_n > t.cap then copy_n = t.cap end if
  for i = 0 to copy_n - 1
    t.data[i] = _arr_wrap_value(arr[i])
  end for
  t.used = copy_n
  return t
end function

function inline arr_chunk_tail_len(tail)
  if typeof(tail) == "array" then return len(tail) end if
  if typeof(tail) != "struct" then return 0 end if
  if typeof(tail.used) != "int" or tail.used <= 0 then return 0 end if
  n = tail.used
  if typeof(tail.cap) == "int" and tail.cap >= 0 and n > tail.cap then n = tail.cap end if
  if typeof(tail.data) == "array" and n > len(tail.data) then n = len(tail.data) end if
  if n < 0 then n = 0 end if
  return n
end function

function arr_chunk_tail_get(tail, idx, defaultv)
  if typeof(idx) != "int" or idx < 0 then return defaultv end if
  if typeof(tail) == "array" then
    if idx < len(tail) then return tail[idx] end if
    return defaultv
  end if
  if typeof(tail) != "struct" or typeof(tail.data) != "array" then return defaultv end if
  n = arr_chunk_tail_len(tail)
  if idx >= n then return defaultv end if
  return _arr_unwrap_value(tail.data[idx])
end function

function arr_chunk_tail_set(tail, idx, value)
  t = tail
  if typeof(idx) != "int" or idx < 0 then return t end if
  if typeof(t) == "array" then
    if idx < len(t) then t[idx] = value end if
    return t
  end if
  if typeof(t) != "struct" or typeof(t.data) != "array" then return t end if
  if typeof(t.cap) != "int" or t.cap <= 0 then t.cap = len(t.data) end if
  if idx >= t.cap or idx >= len(t.data) then return t end if
  t.data[idx] = _arr_wrap_value(value)
  if typeof(t.used) != "int" or t.used < 0 then t.used = 0 end if
  if idx >= t.used then t.used = idx + 1 end if
  return t
end function

function _arr_concat_chunks_balanced(parts)
  if typeof(parts) != "array" or len(parts) <= 0 then return [] end if
  current = parts
  while len(current) > 1
    next_b = arr_vec_new((len(current) + 1) / 2)
    i = 0
    while i < len(current)
      if i + 1 < len(current) then
        next_b = arr_vec_push(next_b, current[i] + current[i + 1])
      else
        next_b = arr_vec_push(next_b, current[i])
      end if
      i = i + 2
    end while
    current = arr_vec_finish(next_b)
  end while
  return current[0]
end function

function _arr_tail_to_array(tail)
  if typeof(tail) == "array" then return tail end if
  if typeof(tail) != "struct" then return [] end if
  n = arr_chunk_tail_len(tail)
  if n <= 0 then return [] end if
  if typeof(tail.data) != "array" then return [] end if

  has_void = false
  for i = 0 to n - 1
    cell = tail.data[i]
    if typeof(cell) == "struct" and cell == _arr_void_sentinel then
      has_void = true
      break
    end if
    if typeof(cell) == "void" then
      has_void = true
      break
    end if
  end for

  if has_void == false then
    outv = _arr_fill(n, 0)
    for i = 0 to n - 1
      outv[i] = tail.data[i]
    end for
    return outv
  end if

  outv = array(n, void)
  for i = 0 to n - 1
    cell2 = tail.data[i]
    if typeof(cell2) == "struct" and cell2 == _arr_void_sentinel then continue end if
    if typeof(cell2) == "void" then continue end if
    outv[i] = cell2
  end for
  return outv
end function

function inline _chunks_paged_tag()
  return "__acp__"
end function

function inline _chunks_is_paged(chunks)
  if typeof(chunks) != "array" or len(chunks) < 3 then return false end if
  if typeof(chunks[0]) != "string" then return false end if
  return chunks[0] == _chunks_paged_tag()
end function

function _chunks_paged_new()
  return [_chunks_paged_tag(), [], _arr_tail_new(256)]
end function

function _chunks_paged_push(chunks, chunk)
  p = chunks
  if _chunks_is_paged(p) == false then p = _chunks_paged_new() end if

  pages = p[1]
  if typeof(pages) != "array" then pages = [] end if
  t = p[2]
  if typeof(t) == "array" then t = _arr_tail_from_array(t, 256) end if
  if typeof(t) != "struct" or typeof(t.data) != "array" then t = _arr_tail_new(256) end if
  if typeof(t.used) != "int" or t.used < 0 then t.used = 0 end if
  if len(t.data) < 256 then
    if t.used > len(t.data) then t.used = len(t.data) end if
    if t.used > 0 then
      pages = pages + [_arr_tail_to_array(t)]
    end if
    t = _arr_tail_new(256)
  end if

  if t.used >= 256 then
    pages = pages + [_arr_tail_to_array(t)]
    t = _arr_tail_new(256)
  end if

  t.data[t.used] = _arr_wrap_value(chunk)
  t.used = t.used + 1
  p[1] = pages
  p[2] = t
  return p
end function

function _chunks_paged_from_array(chunks)
  p = _chunks_paged_new()
  if typeof(chunks) != "array" or len(chunks) <= 0 then return p end if
  for i = 0 to len(chunks) - 1
    p = _chunks_paged_push(p, chunks[i])
  end for
  return p
end function

function _chunks_push_chunk(chunks, chunk)
  if _chunks_is_paged(chunks) then
    return _chunks_paged_push(chunks, chunk)
  end if
  if typeof(chunks) != "array" then
    return [chunk]
  end if
  if len(chunks) < 64 then
    return chunks + [chunk]
  end if
  p = _chunks_paged_from_array(chunks)
  return _chunks_paged_push(p, chunk)
end function

function _chunks_materialize(chunks)
  if _chunks_is_paged(chunks) == false then
    if typeof(chunks) == "array" then return chunks end if
    return []
  end if

  pages = chunks[1]
  if typeof(pages) != "array" then pages = [] end if
  t = chunks[2]
  tail_arr = _arr_tail_to_array(t)

  flat = []
  if len(pages) > 0 then
    flat = arr_merge_chunks_balanced(pages)
  end if

  if len(flat) <= 0 then return tail_arr end if
  if len(tail_arr) <= 0 then return flat end if
  return arr_merge_variadic_parts(flat, tail_arr)
end function

// Create a chunked array builder with the requested tail capacity.
function arr_chunk_new(cap)
  ccap = cap
  if typeof(ccap) != "int" or ccap <= 0 then ccap = 64 end if
  return ArrayChunkBuilder([], _arr_tail_new(ccap), ccap)
end function

function arr_chunked_push(chunks, tail, value, cap)
  if _chunks_is_paged(chunks) == false and typeof(chunks) != "array" then chunks = [] end if
  ccap = cap
  if typeof(ccap) != "int" or ccap <= 0 then ccap = 64 end if
  t = tail
  if typeof(t) == "array" then t = _arr_tail_from_array(t, ccap) end if
  if typeof(t) != "struct" or typeof(t.data) != "array" then t = _arr_tail_new(ccap) end if

  if typeof(t.cap) != "int" or t.cap <= 0 then t.cap = ccap end if
  if typeof(t.used) != "int" or t.used < 0 then t.used = 0 end if
  if len(t.data) < ccap then
    if t.used > len(t.data) then t.used = len(t.data) end if
    if t.used > 0 then
      chunks = _chunks_push_chunk(chunks, _arr_tail_to_array(t))
    end if
    t = _arr_tail_new(ccap)
  end if
  if t.cap != ccap then
    if t.used > 0 then
      chunks = _chunks_push_chunk(chunks, _arr_tail_to_array(t))
    end if
    t = _arr_tail_new(ccap)
  end if

  if t.used >= ccap or t.used >= len(t.data) then
    chunks = _chunks_push_chunk(chunks, _arr_tail_to_array(t))
    t = _arr_tail_new(ccap)
  end if

  t.data[t.used] = _arr_wrap_value(value)
  t.used = t.used + 1
  return [chunks, t]
end function

function arr_chunk_push(builder, value)
  b = builder
  if typeof(b) != "struct" then b = arr_chunk_new(64) end if
  parts = arr_chunked_push(b.chunks, b.tail, value, b.cap)
  b.chunks = parts[0]
  b.tail = parts[1]
  return b
end function

function arr_merge_chunks_balanced(chunks)
  if typeof(chunks) != "array" or len(chunks) <= 0 then return [] end if
  total = 0
  for i = 0 to len(chunks) - 1
    part = chunks[i]
    if typeof(part) == "array" then
      total = total + len(part)
    else
      total = total + 1
    end if
  end for
  if total <= 0 then return [] end if
  outv = _arr_fill(total, 0)
  oi = 0
  for i = 0 to len(chunks) - 1
    part = chunks[i]
    if typeof(part) == "array" then
      copyArray(outv, oi, part, 0, len(part))
      oi = oi + len(part)
    else
      outv[oi] = part
      oi = oi + 1
    end if
  end for
  return outv
end function

// Flatten existing chunk groups plus the active tail directly into the final
// array. This avoids allocating and copying a temporary outer `groups + tail`
// array at every builder finalization.
function arr_merge_chunk_groups_with_tail(groups, tail_arr)
  total = 0
  if typeof(tail_arr) == "array" then total = len(tail_arr) end if
  if typeof(groups) == "array" and len(groups) > 0 then
    for i = 0 to len(groups) - 1
      part = groups[i]
      if typeof(part) == "array" then total = total + len(part) else total = total + 1 end if
    end for
  end if
  if total <= 0 then return [] end if
  outv = _arr_fill(total, 0)
  oi = 0
  if typeof(groups) == "array" and len(groups) > 0 then
    for i = 0 to len(groups) - 1
      part = groups[i]
      if typeof(part) == "array" then
        copyArray(outv, oi, part, 0, len(part))
        oi = oi + len(part)
      else
        outv[oi] = part
        oi = oi + 1
      end if
    end for
  end if
  if typeof(tail_arr) == "array" and len(tail_arr) > 0 then
    copyArray(outv, oi, tail_arr, 0, len(tail_arr))
  end if
  return outv
end function

// Merge short-lived call-site parts without first allocating an outer array.
// The variadic tail is read-only and never escapes, so the compiler represents
// it as an immutable view over the caller's argument slots.
function arr_merge_variadic_parts(parts...)
  if len(parts) <= 0 then return [] end if
  total = 0
  for i = 0 to len(parts) - 1
    part = parts[i]
    if typeof(part) == "array" then
      total = total + len(part)
    else
      total = total + 1
    end if
  end for
  if total <= 0 then return [] end if
  outv = _arr_fill(total, 0)
  oi = 0
  for i = 0 to len(parts) - 1
    part = parts[i]
    if typeof(part) == "array" then
      copyArray(outv, oi, part, 0, len(part))
      oi = oi + len(part)
    else
      outv[oi] = part
      oi = oi + 1
    end if
  end for
  return outv
end function

function arr_chunked_finish(chunks, tail)
  all = _chunks_materialize(chunks)
  tail_arr = _arr_tail_to_array(tail)
  if typeof(tail_arr) == "array" and len(tail_arr) > 0 then
    return arr_merge_chunk_groups_with_tail(all, tail_arr)
  end if
  if typeof(all) == "array" and len(all) == 1 and typeof(all[0]) == "array" then
    return all[0]
  end if
  return arr_merge_chunks_balanced(all)
end function

// Return the storage groups of a chunked sequence without flattening their
// elements. Hot consumers can traverse the small outer array and each fixed
// chunk directly, avoiding an indexed lookup and shape validation per value.
function arr_chunked_groups(chunks, tail)
  all = _chunks_materialize(chunks)
  tail_arr = _arr_tail_to_array(tail)
  if typeof(tail_arr) == "array" and len(tail_arr) > 0 then
    n = 0
    if typeof(all) == "array" then n = len(all) end if
    grown = array(n + 1, void)
    if n > 0 then copyArray(grown, 0, all, 0, n) end if
    grown[n] = tail_arr
    return grown
  end if
  return all
end function

function arr_chunked_count(chunks, tail, cap)
  ccap = cap
  if typeof(ccap) != "int" or ccap <= 0 then ccap = 64 end if
  chunk_count = 0
  if _chunks_is_paged(chunks) then
    pages = chunks[1]
    if typeof(pages) == "array" and len(pages) > 0 then
      for pi = 0 to len(pages) - 1
        page = pages[pi]
        if typeof(page) == "array" then chunk_count = chunk_count + len(page) end if
      end for
    end if
    chunk_count = chunk_count + arr_chunk_tail_len(chunks[2])
  else
    if typeof(chunks) == "array" then chunk_count = len(chunks) end if
  end if
  return chunk_count * ccap + arr_chunk_tail_len(tail)
end function

function arr_chunked_get(chunks, tail, idx, cap, defaultv)
  if typeof(idx) != "int" or idx < 0 then return defaultv end if
  ccap = cap
  if typeof(ccap) != "int" or ccap <= 0 then ccap = 64 end if
  chunk_offset = idx % ccap
  chunk_index = (idx - chunk_offset) / ccap
  chunk = 0
  chunk_count = 0

  if _chunks_is_paged(chunks) then
    pages = chunks[1]
    if typeof(pages) != "array" then pages = [] end if
    page_index = chunk_index >> 8
    page_offset = chunk_index & 0xFF
    if page_index >= 0 and page_index < len(pages) then
      page = pages[page_index]
      if typeof(page) == "array" and page_offset >= 0 and page_offset < len(page) then
        chunk = page[page_offset]
      end if
    end if
    chunk_count = len(pages) << 8
    if typeof(chunk) != "array" then
      tail_chunk_index = chunk_index - chunk_count
      chunk = arr_chunk_tail_get(chunks[2], tail_chunk_index, 0)
    end if
    chunk_count = chunk_count + arr_chunk_tail_len(chunks[2])
  else
    if typeof(chunks) == "array" then
      chunk_count = len(chunks)
      if chunk_index < chunk_count then chunk = chunks[chunk_index] end if
    end if
  end if

  if typeof(chunk) == "array" then
    if chunk_offset >= 0 and chunk_offset < len(chunk) then return chunk[chunk_offset] end if
    return defaultv
  end if
  tail_index = idx - chunk_count * ccap
  return arr_chunk_tail_get(tail, tail_index, defaultv)
end function

function arr_chunk_finish(builder)
  b = builder
  if typeof(b) != "struct" then return [] end if
  return arr_chunked_finish(b.chunks, b.tail)
end function

function arr_chunk_count(builder)
  if typeof(builder) != "struct" then return 0 end if
  return arr_chunked_count(builder.chunks, builder.tail, builder.cap)
end function

function arr_chunk_get(builder, idx, defaultv)
  if typeof(builder) != "struct" then return defaultv end if
  return arr_chunked_get(builder.chunks, builder.tail, idx, builder.cap, defaultv)
end function

function arr_chunk_push_all(builder, values)
  b = builder
  if typeof(values) != "array" or len(values) <= 0 then return b end if
  for i = 0 to len(values) - 1
    b = arr_chunk_push(b, values[i])
  end for
  return b
end function

// Create an empty paged byte buffer.
function byte_pages_new()
  return BytePages([], [], 0)
end function

function inline _bp_chunk_count(bp)
  n = 0
  if typeof(bp.chunk_pages) == "array" then n = n + (len(bp.chunk_pages) << 8) end if
  t = bp.chunk_tail
  if typeof(t) == "array" then
    n = n + len(t)
  else
    if typeof(t) == "struct" then
      used = t.used
      if typeof(used) != "int" or used < 0 then used = 0 end if
      if typeof(t.cap) == "int" and t.cap >= 0 and used > t.cap then used = t.cap end if
      if typeof(t.data) == "array" and used > len(t.data) then used = len(t.data) end if
      n = n + used
    end if
  end if
  return n
end function

function _bp_chunk_get(bp, idx)
  pi = idx >> 8
  po = idx & 0xFF
  if pi < len(bp.chunk_pages) then
    pg = bp.chunk_pages[pi]
    return pg[po]
  end if
  ti = idx - (len(bp.chunk_pages) << 8)
  if typeof(bp.chunk_tail) == "array" then
    if ti >= 0 and ti < len(bp.chunk_tail) and typeof(bp.chunk_tail[ti]) == "bytes" then
      return bp.chunk_tail[ti]
    end if
  else
    if typeof(bp.chunk_tail) == "struct" and typeof(bp.chunk_tail.data) == "array" then
      tn = arr_chunk_tail_len(bp.chunk_tail)
      if ti >= 0 and ti < tn and typeof(bp.chunk_tail.data[ti]) == "bytes" then
        return bp.chunk_tail.data[ti]
      end if
    end if
  end if
  return bytes(65536, 0)
end function

function _bp_chunk_set(bp, idx, page)
  pi = idx >> 8
  po = idx & 0xFF
  if pi < len(bp.chunk_pages) then
    pg = bp.chunk_pages[pi]
    pg[po] = page
    bp.chunk_pages[pi] = pg
    return bp
  end if
  ti = idx - (len(bp.chunk_pages) << 8)
  bp.chunk_tail = arr_chunk_tail_set(bp.chunk_tail, ti, page)
  return bp
end function

function _bp_chunk_push(bp, page)
  app = arr_chunked_push(bp.chunk_pages, bp.chunk_tail, page, 256)
  bp.chunk_pages = app[0]
  bp.chunk_tail = app[1]
  return bp
end function

function _bp_ensure(bp, need)
  if need <= 0 then return bp end if
  want = need >> 16
  if (need & 0xFFFF) != 0 then want = want + 1 end if
  while _bp_chunk_count(bp) < want
    bp = _bp_chunk_push(bp, bytes(65536, 0))
  end while
  return bp
end function

function byte_pages_len(bp)
  if typeof(bp) != "struct" then return 0 end if
  if typeof(bp.size) != "int" or bp.size < 0 then return 0 end if
  return bp.size
end function

// Expose read-only pages to streaming serializers. The final page may contain
// spare capacity; byte_pages_page_used() reports the exact writable prefix.
function byte_pages_page_count(bp)
  if typeof(bp) != "struct" then return 0 end if
  n = byte_pages_len(bp)
  if n <= 0 then return 0 end if
  count = n >> 16
  if (n & 0xFFFF) != 0 then count = count + 1 end if
  return count
end function

function byte_pages_page(bp, page_index)
  if typeof(bp) != "struct" or typeof(page_index) != "int" then return bytes(0) end if
  if page_index < 0 or page_index >= byte_pages_page_count(bp) then return bytes(0) end if
  return _bp_chunk_get(bp, page_index)
end function

function byte_pages_page_used(bp, page_index)
  count = byte_pages_page_count(bp)
  if typeof(page_index) != "int" or page_index < 0 or page_index >= count then return 0 end if
  if page_index + 1 < count then return 65536 end if
  used = byte_pages_len(bp) - (page_index << 16)
  if used < 0 then return 0 end if
  if used > 65536 then return 65536 end if
  return used
end function

function byte_pages_append(bp, src)
  b = bp
  if typeof(b) != "struct" then b = byte_pages_new() end if
  if typeof(src) != "bytes" or len(src) <= 0 then return b end if

  old = byte_pages_len(b)
  need = old + len(src)
  b = _bp_ensure(b, need)
  s = 0
  d = old
  while s < len(src)
    ci = d >> 16
    off = d & 0xFFFF
    pg = _bp_chunk_get(b, ci)
    take = 65536 - off
    left = len(src) - s
    if left < take then take = left end if
    for j = 0 to take - 1
      pg[off + j] = src[s + j]
    end for
    b = _bp_chunk_set(b, ci, pg)
    d = d + take
    s = s + take
  end while
  b.size = need
  return b
end function

// Append a string's UTF-8 payload without first allocating an equally large
// temporary bytes value. String length is stored in bytes by the runtime, and
// the payload immediately follows the common eight-byte object header.
function byte_pages_append_string(bp, text)
  b = bp
  if typeof(b) != "struct" then b = byte_pages_new() end if
  if typeof(text) != "string" or len(text) <= 0 then return b end if

  old = byte_pages_len(b)
  need = old + len(text)
  b = _bp_ensure(b, need)
  source = nativeRawValue(text) + 8
  s = 0
  d = old
  while s < len(text)
    ci = d >> 16
    off = d & 0xFFFF
    pg = _bp_chunk_get(b, ci)
    take = 65536 - off
    left = len(text) - s
    if left < take then take = left end if
    _copy_native_bytes(nativeBytesPtr(pg) + off, source + s, take)
    b = _bp_chunk_set(b, ci, pg)
    d = d + take
    s = s + take
  end while
  b.size = need
  return b
end function

// Append one little-endian 16-bit value without a temporary bytes object.
function byte_pages_append_u16(bp, value)
  b = bp
  if typeof(b) != "struct" then b = byte_pages_new() end if
  old = byte_pages_len(b)
  need = old + 2
  b = _bp_ensure(b, need)

  ci = old >> 16
  off = old & 0xFFFF
  if off <= 65534 then
    pg = _bp_chunk_get(b, ci)
    pg[off] = value & 0xFF
    pg[off + 1] = (value >> 8) & 0xFF
    b = _bp_chunk_set(b, ci, pg)
  else
    b = byte_pages_set_byte(b, old, value)
    b = byte_pages_set_byte(b, old + 1, value >> 8)
  end if
  b.size = need
  return b
end function

// Append one little-endian 32-bit value without allocating a temporary
// four-byte object. Object serialization writes several integers per label
// and relocation, so avoiding that allocation materially reduces allocator
// and GC traffic on large programs.
function byte_pages_append_u32(bp, value)
  b = bp
  if typeof(b) != "struct" then b = byte_pages_new() end if
  old = byte_pages_len(b)
  need = old + 4
  b = _bp_ensure(b, need)

  ci = old >> 16
  off = old & 0xFFFF
  if off <= 65532 then
    pg = _bp_chunk_get(b, ci)
    pg[off] = value & 0xFF
    pg[off + 1] = (value >> 8) & 0xFF
    pg[off + 2] = (value >> 16) & 0xFF
    pg[off + 3] = (value >> 24) & 0xFF
    b = _bp_chunk_set(b, ci, pg)
  else
    // A value can straddle two 64-KiB pages. Reuse the general byte setter
    // for this rare boundary case while still avoiding a bytes allocation.
    b = byte_pages_set_byte(b, old, value)
    b = byte_pages_set_byte(b, old + 1, value >> 8)
    b = byte_pages_set_byte(b, old + 2, value >> 16)
    b = byte_pages_set_byte(b, old + 3, value >> 24)
  end if
  b.size = need
  return b
end function

// Append one little-endian 64-bit value. MiniLang integers carry 61 payload
// bits; the writer deliberately preserves their sign-extended bit pattern.
function byte_pages_append_u64(bp, value)
  b = bp
  if typeof(b) != "struct" then b = byte_pages_new() end if
  old = byte_pages_len(b)
  need = old + 8
  b = _bp_ensure(b, need)

  ci = old >> 16
  off = old & 0xFFFF
  if off <= 65528 then
    pg = _bp_chunk_get(b, ci)
    pg[off] = value & 0xFF
    pg[off + 1] = (value >> 8) & 0xFF
    pg[off + 2] = (value >> 16) & 0xFF
    pg[off + 3] = (value >> 24) & 0xFF
    pg[off + 4] = (value >> 32) & 0xFF
    pg[off + 5] = (value >> 40) & 0xFF
    pg[off + 6] = (value >> 48) & 0xFF
    pg[off + 7] = (value >> 56) & 0xFF
    b = _bp_chunk_set(b, ci, pg)
  else
    for i = 0 to 7
      b = byte_pages_set_byte(b, old + i, value >> (i * 8))
    end for
  end if
  b.size = need
  return b
end function

function byte_pages_write_at(bp, offset, src)
  b = bp
  if typeof(b) != "struct" then b = byte_pages_new() end if
  if typeof(offset) != "int" or offset < 0 then return b end if
  if typeof(src) != "bytes" or len(src) <= 0 then return b end if

  end_pos = offset + len(src)
  b = _bp_ensure(b, end_pos)

  s = 0
  d = offset
  while s < len(src)
    ci = d >> 16
    off = d & 0xFFFF
    pg = _bp_chunk_get(b, ci)
    take = 65536 - off
    left = len(src) - s
    if left < take then take = left end if
    for j = 0 to take - 1
      pg[off + j] = src[s + j]
    end for
    b = _bp_chunk_set(b, ci, pg)
    d = d + take
    s = s + take
  end while

  if end_pos > byte_pages_len(b) then b.size = end_pos end if
  return b
end function

function byte_pages_to_bytes(bp)
  if typeof(bp) != "struct" then return bytes(0) end if
  n = byte_pages_len(bp)
  if n <= 0 then return bytes(0) end if

  b = _bp_ensure(bp, n)
  outv = bytes(n, 0)
  dst = 0
  ci = 0
  cn = _bp_chunk_count(b)
  while dst < n and ci < cn
    pg = _bp_chunk_get(b, ci)
    take = 65536
    left = n - dst
    if left < take then take = left end if
    for j = 0 to take - 1
      outv[dst + j] = pg[j]
    end for
    dst = dst + take
    ci = ci + 1
  end while
  return outv
end function

function byte_pages_set_byte(bp, idx, value)
  b = bp
  if typeof(b) != "struct" then b = byte_pages_new() end if
  if typeof(idx) != "int" or idx < 0 then return b end if

  need = idx + 1
  b = _bp_ensure(b, need)
  ci = idx >> 16
  off = idx & 0xFFFF
  pg = _bp_chunk_get(b, ci)
  pg[off] = value & 0xFF
  b = _bp_chunk_set(b, ci, pg)
  if need > byte_pages_len(b) then b.size = need end if
  return b
end function

function byte_pages_get_byte(bp, idx, defaultv)
  if typeof(bp) != "struct" then return defaultv end if
  if typeof(idx) != "int" or idx < 0 then return defaultv end if
  if idx >= byte_pages_len(bp) then return defaultv end if
  ci = idx >> 16
  off = idx & 0xFFFF
  pg = _bp_chunk_get(bp, ci)
  return pg[off]
end function
