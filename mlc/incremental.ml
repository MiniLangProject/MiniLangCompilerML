// Copyright 2026 Nils Kopal. Licensed under the Apache License, Version 2.0.
//! Persistent native-function fragments with semantic and layout validation.
package mlc.incremental
import mlc.cache_codec as codec
import mlc.incremental_ast as ast
import mlc.tools as t
import mlc.asm as a
import mlc.data as d
import mlc.project as project
import std.fs as fs
import std.process as process
import std.checksum.crc32 as crc32
import std.checksum.crc32c as crc32c

/// One build's cache state; no frontend AST is retained here.
struct Cache
  /// Persistent directory containing one last generation per function.
  directory,
  /// Compiler identity and effective options.
  options,
  /// Declaration and inline-body fingerprint.
  declarations,
  /// Prepared global semantic fingerprint.
  context,
  /// Per-module content identities.
  files,
  /// Rolling section/pool mutation identities.
  ieee,
  castagnoli,
  /// Whether the initial section frontier has been fingerprinted.
  initialized,
  /// Reused, compiled, and invalid-entry counts.
  hits,
  misses,
  invalid,
end struct

/// Active cache is globally rooted across object-emitter collections.
_cache = void

/// Configure optional caching. Compiler bytes, not version strings, identify codegen.
/// @param directory Persistent cache root selected by the caller.
/// @param options Effective compiler options used for invalidation.
function configure(directory, options)
  global _cache
  _cache = void
  if typeof(directory) != "string" or directory == "" then return end if
  compiler_id = try(project._file_content_id(process.executablePath()))
  if typeof(compiler_id) != "string" then return end if
  path = project._join(directory, "functions-ml-v1")
  if project._ensure_dir(path) == false then return end if
  _cache = Cache(path, ["MiniLang-function-cache-ml-1", compiler_id, options], "", "", t.fastmap_new(128), 0, 0, false, 0, 0, 0)
end function

/// Whether fragment caching is configured for this compilation.
function enabled()
  return typeof(_cache) == "struct"
end function

/// Load a source- and compiler-specific packed token arena, if present.
function loadTokens(source)
  if enabled() == false then return void end if
  key = codec.key([_cache.options, "tokens-ml-v1", source])
  if key == "" then return void end if
  path = project._join(_cache.directory, key + ".mtok")
  if fs.isFile(path) == false then return void end if
  size = try(fs.fileSize(path))
  if typeof(size) != "int" or size > 67108864 then return void end if
  raw = try(fs.readAllBytes(path))
  envelope = codec.decodeRecord(raw)
  if typeof(envelope) != "array" or len(envelope) != 3 then return void end if
  if envelope[0] != key or typeof(envelope[2]) != "bytes" then return void end if
  if envelope[1] != codec.identity(envelope[2]) then return void end if
  return codec.decodeRecord(envelope[2])
end function

/// Publish only primitive token columns; never deserialize executable ASTs.
function storeTokens(source, record)
  if enabled() == false then return end if
  key = codec.key([_cache.options, "tokens-ml-v1", source])
  if key == "" then return end if
  payload = codec.encode(record)
  if typeof(payload) != "bytes" or len(payload) > 65000000 then return end if
  path = project._join(_cache.directory, key + ".mtok")
  envelope = codec.encode([key, codec.identity(payload), payload])
  if typeof(envelope) != "bytes" then return end if
  temporary = path + "." + process.id() + ".tmp"
  written = try(fs.writeAllBytes(temporary, envelope))
  if typeof(written) != "error" then
    if project._atomic_cache_replace(temporary, path) == false then ignored = try(fs.delete(temporary)) end if
  else
    ignored = try(fs.delete(temporary))
  end if
end function

/// Capture declarations before the frontend releases or mutates function bodies.
/// @param program Combined current AST before function bodies are released.
function prepare(program)
  if enabled() == false then return end if
  _cache.declarations = ast.interfaceKey(program)
end function

/// Include body-derived whole-program facts in every reuse decision.
/// @param state Prepared code generator and its canonical output stream.
/// @param contracts Body-derived callee contracts that can affect callers.
function seal(state, contracts)
  if enabled() == false or _cache.declarations == "" then return end if
  globals_view = t.arr_chunk_new(128)
  if len(state.scope_stack) > 0 then
    bindings = state.scope_stack[0]
    for each binding in bindings
      globals_view = t.arr_chunk_push(globals_view, [binding.id, binding.name, binding.kind, binding.label, binding.offset, binding.is_const])
    end for
  end if
  _cache.context = codec.key([_cache.options, _cache.declarations, contracts,
    t.fastmap_items(state.dead_functions), state.native_threads_possible,
    t.fastmap_items(state.mutable_user_functions), state.max_inline_call_args_global,
    state.synchronized_globals, t.arr_chunk_finish(globals_view)])
end function

/// Snapshot stream-wide effects, excluding disposable analysis arenas.
/// @param state Prepared code generator and its canonical output stream.
function stateValues(state)
  return [state.label_id, state.binding_id, t.fastmap_items(state._inline_emitted_bytes),
    state.used_helpers, state.emitted_helpers, state.ext_widebuf_labels,
    state.call_total_count, state.call_indirect_count, state.expr_temp_max,
    state.inline_only_functions, state.pruned_inline_functions,
    state.asm.tracked_helpers]
end function

/// Restore exactly the persistent effects that normal function lowering produces.
/// @param state Prepared code generator and its canonical output stream.
/// @param values Previously validated stream-wide accounting values.
function restoreState(state, values)
  state.label_id = values[0]
  state.binding_id = values[1]
  budget = t.fastmap_new(128)
  for each item in values[2]
    budget = t.fastmap_set(budget, item[0], item[1])
  end for
  state._inline_emitted_bytes = budget
  state.used_helpers = values[3]
  state.emitted_helpers = values[4]
  state.ext_widebuf_labels = values[5]
  state.call_total_count = values[6]
  state.call_indirect_count = values[7]
  state.expr_temp_max = values[8]
  state.inline_only_functions = values[9]
  state.pruned_inline_functions = values[10]
  state.asm.tracked_helpers = values[11]
  helpers = t.fastmap_new(256)
  for each helper in values[11]
    helpers = t.fastmap_set(helpers, helper, true)
  end for
  state.asm.tracked_helper_map = helpers
  return state
end function

/// Fold section changes into the next fragment's input fingerprint.
/// @param value Primitive value to encode or fingerprint.
function advance(value)
  raw = codec.encode(value)
  if typeof(raw) != "bytes" then _cache.context = ""; return end if
  _cache.ieee = crc32.update(_cache.ieee, raw, 0, len(raw))
  _cache.castagnoli = crc32c.update(_cache.castagnoli, raw, 0, len(raw))
end function

/// Summarize initial labels, bytes, and pool entries once, not per function.
/// @param state Prepared code generator and its canonical output stream.
function initialize(state)
  labels = t.arr_chunk_new(256)
  rlabels = d.rdata_get_labels(state.rdata)
  for each item in rlabels
    labels = t.arr_chunk_push(labels, [1, item.name, item.offset, item.length])
  end for
  dlabels = d.data_get_labels(state.data)
  for each item in dlabels
    labels = t.arr_chunk_push(labels, [0, item.name, item.offset])
  end for
  pools = [state.rdata.pool_raw, state.rdata.pool_obj_string, state.rdata.pool_obj_float]
  for pi = 0 to 2
    entries = t.fastmap_items(pools[pi])
    for each pair in entries
      entry = pair[1]
      labels = t.arr_chunk_push(labels, [2 + pi, entry.key, entry.offset, entry.length, entry.label])
    end for
  end for
  advance([codec.slice(state.rdata.data, 0, d.rdata_used(state.rdata)),
    codec.slice(state.data.data, 0, d._buf_used(state.data)),
    t.arr_chunk_finish(labels), state.bss.size])
  _cache.initialized = true
end function

/// Count chunked records without flattening an accumulated assembler.
/// @param chunks Completed assembler record chunks.
/// @param tail Current partial assembler record chunk.
function count(chunks, tail)
  return t.arr_chunked_count(chunks, tail, 256)
end function

/// Optimizer state crossing a function boundary (normally empty after RET).
/// @param asm Assembler whose appended bytes or optimizer state is inspected.
function peephole(asm)
  previous = void
  if typeof(asm.peephole_prev_jump_patch) == "struct" then
    p = asm.peephole_prev_jump_patch
    previous = [p.pos, p.target, p.kind]
  end if
  forward = asm.forward_branch
  if typeof(forward) == "array" and len(forward) == 4 and typeof(forward[1]) == "struct" then
    p = forward[1]
    forward = [forward[0], [p.pos, p.target, p.kind], forward[2], forward[3]]
  end if
  return [asm.peephole_last_push, asm.peephole_last_jump, previous, forward]
end function

/// Memoize source identities, including inline dependency debug locations.
/// @param filename Canonical source path recorded by the frontend.
function sourceIdentity(filename)
  file_id = t.fastmap_get(_cache.files, filename, "")
  if file_id == "" then _cache.declarations = ""; _cache.context = "" end if
  return file_id
end function

/// Capture exactly the input parsed by the frontend, including line mappings.
/// Re-reading later could publish old machine code under a newly saved file's key.
/// @param filename Canonical source path recorded by the frontend.
/// @param source Exact text read for parsing this module.
function recordSource(filename, source)
  if enabled() then _cache.files = t.fastmap_set(_cache.files, filename, codec.key([source])) end if
end function

/// Start a fragment transaction and return its validated record, if any.
/// @param state Prepared code generator and its canonical output stream.
/// @param fn Function declaration selected for lowering.
/// @param code_name Unique native symbol, including nested-function ownership.
function begin(state, fn, code_name)
  if enabled() == false or _cache.context == "" then return end if
  if _cache.initialized == false then initialize(state) end if
  filename = t.ast_filename(fn)
  file_id = sourceIdentity(filename)
  if file_id == "" then return end if
  key = codec.key([_cache.context, code_name, filename, file_id, stateValues(state),
    a.pos(state.asm), state.heap_config, _cache.ieee, _cache.castagnoli, peephole(state.asm)])
  if key == "" then _cache.context = ""; return end if
  path = project._join(_cache.directory, codec.key([filename, code_name, state.target]) + ".mfc")
  record = void
  if fs.isFile(path) then
    size = try(fs.fileSize(path))
    if typeof(size) == "int" and size <= 67108864 then
      raw_entry = try(fs.readAllBytes(path))
      envelope = codec.decodeRecord(raw_entry)
      if typeof(envelope) == "array" and len(envelope) == 3 then
        if typeof(envelope[2]) == "bytes" and envelope[1] == codec.identity(envelope[2]) then
          if envelope[0] == key then
            candidate = codec.decodeRecord(envelope[2])
            if validRecord(candidate, a.pos(state.asm)) then
              record = candidate
            else
              _cache.invalid = _cache.invalid + 1
            end if
          end if
        else
          _cache.invalid = _cache.invalid + 1
        end if
      else
        _cache.invalid = _cache.invalid + 1
      end if
    end if
  end if
  checkpoint = [a.pos(state.asm), count(state.asm.labels_chunks, state.asm.labels_tail),
    count(state.asm.patches_chunks, state.asm.patches_tail),
    count(state.asm.deferred_patches_chunks, state.asm.deferred_patches_tail),
    d._buf_used(state.data), d.rdata_used(state.rdata),
    d.data_patch_count(state.data), d.rdata_patch_count(state.rdata), len(state.bss.labels)]
  d.cache_begin()
  return [path, key, checkpoint, record]
end function

/// Check primitive relocation tuples before touching live codegen state.
/// @param items Relocation records to project or validate.
function validPatches(items)
  if typeof(items) != "array" then return false end if
  for each item in items
    if typeof(item) != "array" or len(item) != 3 then return false end if
    if typeof(item[0]) != "int" or item[0] < 0 or typeof(item[1]) != "string" then return false end if
    if item[2] != "rel32" and item[2] != "rip32" and item[2] != "abs64" then return false end if
  end for
  return true
end function

/// Verify record shape and bounded offsets; a malformed cache is a miss.
/// @param record Candidate primitive cache record to validate.
/// @param start First byte or record offset to include.
function validRecord(record, start)
  if typeof(record) != "array" or len(record) != 7 then return false end if
  if typeof(record[0]) != "bytes" or typeof(record[1]) != "array" then return false end if
  if validPatches(record[2]) == false or validPatches(record[3]) == false then return false end if
  for each label in record[1]
    if typeof(label) != "array" or len(label) != 2 then return false end if
    if typeof(label[0]) != "string" or typeof(label[1]) != "int" then return false end if
    if label[1] < start or label[1] > start + len(record[0]) then return false end if
  end for
  accounting = record[4]
  if typeof(accounting) != "array" or len(accounting) != 12 then return false end if
  for each index in [0, 1, 6, 7, 8]
    if typeof(accounting[index]) != "int" or accounting[index] < 0 then return false end if
  end for
  for each index in [2, 3, 4, 5, 9, 10, 11]
    if typeof(accounting[index]) != "array" then return false end if
  end for
  for each item in accounting[2]
    if typeof(item) != "array" or len(item) != 2 then return false end if
    if typeof(item[0]) != "string" or typeof(item[1]) != "int" then return false end if
  end for
  sections = record[5]
  if typeof(sections) != "array" or len(sections) != 7 then return false end if
  if typeof(sections[0]) != "bytes" or typeof(sections[1]) != "bytes" then return false end if
  if validPatches(sections[2]) == false or validPatches(sections[3]) == false then return false end if
  if typeof(sections[4]) != "array" or typeof(sections[5]) != "array" then return false end if
  if typeof(sections[6]) != "int" or sections[6] < 0 then return false end if
  for each item in sections[4]
    if typeof(item) != "array" or len(item) < 3 then return false end if
    kind = item[0]
    if typeof(kind) != "int" or kind < 0 or kind > 5 then return false end if
    if kind == 0 or kind == 5 then
      if len(item) != 3 or typeof(item[1]) != "string" then return false end if
      if kind == 0 and typeof(item[2]) != "int" then return false end if
      if kind == 5 and typeof(item[2]) != "string" then return false end if
    else if kind == 1 then
      if len(item) != 4 or typeof(item[1]) != "string" or typeof(item[2]) != "int" or typeof(item[3]) != "int" then return false end if
    else
      if len(item) != 5 or typeof(item[1]) != "bytes" or typeof(item[2]) != "int" or typeof(item[3]) != "int" or typeof(item[4]) != "string" then return false end if
    end if
  end for
  for each item in sections[5]
    if typeof(item) != "array" or len(item) != 2 then return false end if
    if typeof(item[0]) != "string" or typeof(item[1]) != "int" then return false end if
  end for
  ph = record[6]
  if typeof(ph) != "array" or len(ph) != 4 then return false end if
  if typeof(ph[0]) != "array" or typeof(ph[1]) != "array" or typeof(ph[3]) != "array" then return false end if
  if typeof(ph[2]) != "void" and validPatches([ph[2]]) == false then return false end if
  if len(ph[3]) != 0 then
    if len(ph[3]) != 4 then return false end if
    if validPatches([ph[3][1]]) == false then return false end if
  end if
  return true
end function

/// Read only the new paged instruction bytes; never materialize the whole stream.
/// @param asm Assembler whose appended bytes or optimizer state is inspected.
/// @param start First byte or record offset to include.
function codeSlice(asm, start)
  result = bytes(a.pos(asm) - start, 0)
  offset = 0
  while offset < len(result)
    position = start + offset
    page = a._chunk_get(asm, position >> 16)
    in_page = position & 65535
    take = 65536 - in_page
    if take > len(result) - offset then take = len(result) - offset end if
    t._copy_native_bytes(nativeBytesPtr(result) + offset, nativeBytesPtr(page) + in_page, take)
    offset = offset + take
  end while
  return result
end function

/// Project appended relocation records to primitive cache data.
/// @param chunks Completed assembler record chunks.
/// @param tail Current partial assembler record chunk.
/// @param start First byte or record offset to include.
function patches(chunks, tail, start)
  result = t.arr_chunk_new(64)
  total = count(chunks, tail)
  if total > start then
    for i = start to total - 1
      p = t.arr_chunked_get(chunks, tail, i, 256, void)
      result = t.arr_chunk_push(result, [p.pos, p.target, p.kind])
    end for
  end if
  return t.arr_chunk_finish(result)
end function

/// Project data relocations without native pointers or class names.
/// @param items Relocation records to project or validate.
function dataPatches(items)
  result = t.arr_chunk_new(64)
  for each p in items
    result = t.arr_chunk_push(result, [p.offset, p.target, p.kind])
  end for
  return t.arr_chunk_finish(result)
end function

/// Complete a successful emission, atomically publish it, and advance the frontier.
/// @param state Prepared code generator and its canonical output stream.
/// @param transaction Cache key, checkpoint and optional saved fragment.
function finish(state, transaction)
  if typeof(transaction) != "array" then return state end if
  journal = d.cache_end()
  if len(state.diagnostics) > 0 then _cache.context = ""; return state end if
  cp = transaction[2]
  labels = t.arr_chunk_new(64)
  total = count(state.asm.labels_chunks, state.asm.labels_tail)
  if total > cp[1] then
    for i = cp[1] to total - 1
      item = t.arr_chunked_get(state.asm.labels_chunks, state.asm.labels_tail, i, 256, void)
      labels = t.arr_chunk_push(labels, [item.name, item.pos])
    end for
  end if
  bss_labels = t.arr_chunk_new(16)
  if len(state.bss.labels) > cp[8] then
    for i = cp[8] to len(state.bss.labels) - 1
      item = state.bss.labels[i]
      bss_labels = t.arr_chunk_push(bss_labels, [item.name, item.offset])
    end for
  end if
  sections = [codec.slice(state.data.data, cp[4], d._buf_used(state.data) - cp[4]),
    codec.slice(state.rdata.data, cp[5], d.rdata_used(state.rdata) - cp[5]),
    dataPatches(d.data_get_patches_after(state.data, cp[6])),
    dataPatches(d.rdata_get_patches_after(state.rdata, cp[7])), journal,
    t.arr_chunk_finish(bss_labels), state.bss.size]
  record = [codeSlice(state.asm, cp[0]), t.arr_chunk_finish(labels),
    patches(state.asm.patches_chunks, state.asm.patches_tail, cp[2]),
    patches(state.asm.deferred_patches_chunks, state.asm.deferred_patches_tail, cp[3]),
    stateValues(state), sections, peephole(state.asm)]
  payload = codec.encode(record)
  if typeof(payload) == "bytes" and len(payload) <= 65000000 then
    envelope = codec.encode([transaction[1], codec.identity(payload), payload])
    temporary = transaction[0] + "." + process.id() + ".tmp"
    written = try(fs.writeAllBytes(temporary, envelope))
    if typeof(written) != "error" then
      // Windows readers may briefly hold a handle without SHARE_DELETE.
      // Losing this optional cache publication must not fail compilation.
      published = project._atomic_cache_replace(temporary, transaction[0])
      if published == false then ignored = try(fs.delete(temporary)) end if
    else
      ignored = try(fs.delete(temporary))
    end if
  end if
  _cache.misses = _cache.misses + 1
  advance(sections)
  return state
end function

/// Replay a previously validated append-only section journal.
/// @param state Prepared code generator and its canonical output stream.
/// @param sections Validated section bytes, labels, pools and relocations.
function replaySections(state, sections)
  state.data = d._buf_append(state.data, sections[0])
  state.rdata = d._buf_append(state.rdata, sections[1])
  for each p in sections[2]
    state.data = d.data_add_abs64_patch(state.data, p[0], p[1])
  end for
  for each p in sections[3]
    state.rdata = d.rdata_add_abs64_patch(state.rdata, p[0], p[1])
  end for
  for each item in sections[4]
    kind = item[0]
    if kind == 0 then
      state.data = d._data_upsert_label(state.data, item[1], item[2])
    else if kind == 1 then
      state.rdata = d._rdata_upsert_label(state.rdata, item[1], item[2], item[3])
    else if kind == 5 then
      state.rdata.alias_index = t.fastmap_set(state.rdata.alias_index, item[1], item[2])
    else
      entry = d.PoolEntry(item[1], item[2], item[3], item[4])
      if kind == 2 then state.rdata.pool_raw = t.fastmap_set(state.rdata.pool_raw, item[1], entry) end if
      if kind == 3 then state.rdata.pool_obj_string = t.fastmap_set(state.rdata.pool_obj_string, item[1], entry) end if
      if kind == 4 then state.rdata.pool_obj_float = t.fastmap_set(state.rdata.pool_obj_float, item[1], entry) end if
    end if
  end for
  for each item in sections[5]
    state.bss.labels = state.bss.labels + [d.DataLabel(item[0], item[1])]
  end for
  state.bss.size = sections[6]
  return state
end function

/// Restore code, relocation and accounting effects without rerunning lowering.
/// @param state Prepared code generator and its canonical output stream.
/// @param transaction Cache key, checkpoint and optional saved fragment.
function replay(state, transaction)
  d.cache_end()
  record = transaction[3]
  state.asm = a._emit(state.asm, record[0])
  for each item in record[1]
    state.asm = a._label_push(state.asm, a.AsmLabel(item[0], item[1]))
    state.asm.label_pos_map = t.fastmap_set(state.asm.label_pos_map, item[0], item[1])
  end for
  state.asm.labels = []
  for each item in record[2]
    state.asm = a._patch_push(state.asm, a.AsmPatch(item[0], item[1], item[2]))
  end for
  for each item in record[3]
    app = t.arr_chunked_push(state.asm.deferred_patches_chunks, state.asm.deferred_patches_tail, a.AsmPatch(item[0], item[1], item[2]), 256)
    state.asm.deferred_patches_chunks = app[0]
    state.asm.deferred_patches_tail = app[1]
  end for
  state = restoreState(state, record[4])
  state = replaySections(state, record[5])
  ph = record[6]
  state.asm.peephole_last_push = ph[0]
  state.asm.peephole_last_jump = ph[1]
  state.asm.peephole_prev_jump_patch = 0
  if typeof(ph[2]) == "array" then state.asm.peephole_prev_jump_patch = a.AsmPatch(ph[2][0], ph[2][1], ph[2][2]) end if
  forward = ph[3]
  if typeof(forward) == "array" and len(forward) == 4 then
    p = forward[1]
    forward = [forward[0], a.AsmPatch(p[0], p[1], p[2]), forward[2], forward[3]]
  end if
  state.asm.forward_branch = forward
  _cache.hits = _cache.hits + 1
  advance(record[5])
  return state
end function

/// Report real codegen reuse separately from the whole-build artifact cache.
function report()
  if enabled() and _cache.initialized then print "[incremental] reused=" + _cache.hits + " compiled=" + _cache.misses + " invalid=" + _cache.invalid end if
end function
