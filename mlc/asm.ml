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

// Deterministic x86-64 encoder, label patcher and assembly-listing support.
//! Provides the mlc asm package.

package mlc.asm
import mlc.tools as t

/// Deferred rel32 relocation from an instruction field to a named label.
struct AsmPatch
  /// Pos associated with `AsmPatch`.
  pos,
  /// Target associated with `AsmPatch`.
  target,
  /// Kind associated with `AsmPatch`.
  kind,
end struct

/// Named code offset in the materialized instruction stream.
struct AsmLabel
  /// Name associated with `AsmLabel`.
  name,
  /// Pos associated with `AsmLabel`.
  pos,
end struct

/// Paged instruction stream plus chunked labels, patches and call metadata.
struct AsmBuilder
  /// Buf associated with `AsmBuilder`.
  buf,
  /// Current logical size of `AsmBuilder`.
  size,
  /// Labels associated with `AsmBuilder`.
  labels,
  /// Labels chunks associated with `AsmBuilder`.
  labels_chunks,
  /// Labels tail associated with `AsmBuilder`.
  labels_tail,
  /// Patches chunks associated with `AsmBuilder`.
  patches_chunks,
  /// Patches tail associated with `AsmBuilder`.
  patches_tail,
  /// Deferred patches chunks associated with `AsmBuilder`.
  deferred_patches_chunks,
  /// Deferred patches tail associated with `AsmBuilder`.
  deferred_patches_tail,
  /// Calls chunks associated with `AsmBuilder`.
  calls_chunks,
  /// Calls tail associated with `AsmBuilder`.
  calls_tail,
  /// Chunk pages associated with `AsmBuilder`.
  chunk_pages,
  /// Chunk tail associated with `AsmBuilder`.
  chunk_tail,
  /// Chunk size associated with `AsmBuilder`.
  chunk_size,
  /// Buf valid associated with `AsmBuilder`.
  buf_valid,
  /// Before call live temps associated with `AsmBuilder`.
  before_call_live_temps,
  /// Tracked helpers associated with `AsmBuilder`.
  tracked_helpers,
  /// Label pos map associated with `AsmBuilder`.
  label_pos_map,
  /// Peephole last jump associated with `AsmBuilder`.
  peephole_last_jump,
  /// Peephole last push associated with `AsmBuilder`.
  peephole_last_push,
  /// Record calls associated with `AsmBuilder`.
  record_calls,
  /// Tracked helper map associated with `AsmBuilder`.
  tracked_helper_map,
  /// Active chunk associated with `AsmBuilder`.
  active_chunk,
  /// Active chunk index associated with `AsmBuilder`.
  active_chunk_index,
end struct

/// Encoded general-purpose-register number, width and REX requirement.
struct GPR
  /// Id associated with `GPR`.
  id,
  /// Current logical size of `GPR`.
  size,
  /// Force rex associated with `GPR`.
  force_rex,
end struct

/// Encoded ModRM/SIB memory operand tail and extension bits.
struct EncMem
  /// Rex x associated with `EncMem`.
  rex_x,
  /// Rex b associated with `EncMem`.
  rex_b,
  /// Tail associated with `EncMem`.
  tail,
end struct

/// Track materialize keepalive compiler state.
_materialize_keepalive = 0

/// Encode or manage starts with text in the native x64 assembler.
/// @internal
function _starts_with_text(text, prefix)
  if typeof(text) != "string" then return false end if
  if typeof(prefix) != "string" then return false end if
  if len(prefix) <= 0 then return true end if
  if len(text) < len(prefix) then return false end if
  for i = 0 to len(prefix) - 1
    if text[i] != prefix[i] then return false end if
  end for
  return true
end function

/// Encode or manage array contains text in the native x64 assembler.
/// @internal
function _array_contains_text(arr, value)
  if typeof(arr) != "array" or len(arr) <= 0 then return false end if
  for i = 0 to len(arr) - 1
    if arr[i] == value then return true end if
  end for
  return false
end function

/// Encode or manage keepalive barrier in the native x64 assembler.
/// @internal
function _keepalive_barrier(value)
  return value
end function

/// Creates alloc zero bytes keepalive.
/// @internal
function _alloc_zero_bytes_keepalive(keepalive, size)
  return bytes(size, 0)
end function

/// Create an empty assembler with production-sized page and index capacities.
function newAsmBuilder()
  cs = 65536
  first_chunk = bytes(cs, 0)
  asm = AsmBuilder(bytes(0), 0, [], [], [], [], [], [], [], [], [], [], [first_chunk], cs, false, [], [], t.fastmap_new(256), [], [], true, t.fastmap_new(256), first_chunk, 0)
  return asm
end function

/// Code generation discovers runtime helpers separately and never consumes the complete call history. Avoid retaining one string for every emitted call in large monolithic builds while preserving call recording for assembler users.
function newCodegenAsmBuilder()
  asm = newAsmBuilder()
  asm.record_calls = false
  return asm
end function

/// Materialize unresolved and active patch chunks in deterministic order.
/// @param asm Value supplied for `asm`.
function get_patches(asm)
  patch_out = t.arr_chunk_new(1024)
  deferred_count = t.arr_chunked_count(asm.deferred_patches_chunks, asm.deferred_patches_tail, 256)
  if deferred_count > 0 then
    for i = 0 to deferred_count - 1
      patch_out = t.arr_chunk_push(patch_out, t.arr_chunked_get(asm.deferred_patches_chunks, asm.deferred_patches_tail, i, 256, 0))
    end for
  end if
  active_count = t.arr_chunked_count(asm.patches_chunks, asm.patches_tail, 256)
  if active_count > 0 then
    for i = 0 to active_count - 1
      patch_out = t.arr_chunk_push(patch_out, t.arr_chunked_get(asm.patches_chunks, asm.patches_tail, i, 256, 0))
    end for
  end if
  return t.arr_chunk_finish(patch_out)
end function

/// Fold same-fragment x64 PC-relative patches after materialization while walking the assembler's paged patch storage directly. Returning only the unresolved records prevents object emission from first flattening millions of local patches into a second managed array.
/// @internal
function _fold_materialized_patch_set(asm, patch_chunks, patch_tail, out_b)
  patch_groups = t.arr_chunked_groups(patch_chunks, patch_tail)
  if len(patch_groups) <= 0 then return [asm, out_b] end if
  for group_i = 0 to len(patch_groups) - 1
    patch_group = patch_groups[group_i]
    if typeof(patch_group) == "array" and len(patch_group) > 0 then
      for patch_i = 0 to len(patch_group) - 1
        p = patch_group[patch_i]
        folded = false
        if typeof(p) == "struct" then
          patch_pos = try(p.pos)
          patch_target = try(p.target)
          patch_kind = try(p.kind)
          if typeof(patch_pos) == "int" and typeof(patch_target) == "string" and (patch_kind == "rel32" or patch_kind == "rip32") then
            target_pos = -1
            if typeof(asm.label_pos_map) == "struct" then
              target_pos = t.fastmap_get(asm.label_pos_map, patch_target, -1)
              if typeof(target_pos) != "int" then target_pos = -1 end if
            end if
            if target_pos >= 0 and patch_pos >= 0 and patch_pos + 3 < asm.size and typeof(asm.buf) == "bytes" then
              disp = target_pos - (patch_pos + 4)
              asm.buf[patch_pos] = disp & 0xFF
              asm.buf[patch_pos + 1] = (disp >> 8) & 0xFF
              asm.buf[patch_pos + 2] = (disp >> 16) & 0xFF
              asm.buf[patch_pos + 3] = (disp >> 24) & 0xFF
              folded = true
            end if
          end if
        end if
        if folded == false then out_b = t.arr_chunk_push(out_b, p) end if
      end for
    end if
  end for
  return [asm, out_b]
end function

/// Encode or manage materialize and fold local patches in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function materialize_and_fold_local_patches(asm)
  asm = _materialize_buffer(asm)
  out_b = t.arr_chunk_new(64)
  r = _fold_materialized_patch_set(asm, asm.deferred_patches_chunks, asm.deferred_patches_tail, out_b)
  asm = r[0]
  r = _fold_materialized_patch_set(asm, asm.patches_chunks, asm.patches_tail, r[1])
  asm = r[0]
  // The caller owns the returned unresolved array; release the consumed
  // chunk roots before it serializes the object.
  asm.deferred_patches_chunks = []
  asm.deferred_patches_tail = []
  asm.patches_chunks = []
  asm.patches_tail = []
  return [asm, t.arr_chunk_finish(r[1])]
end function

/// Apply every currently resolvable rel32 patch and retain forward references.
/// @internal
function _resolve_patch_set(asm, patch_chunks, patch_tail, kept_chunks, kept_tail)
  patch_count = t.arr_chunked_count(patch_chunks, patch_tail, 256)
  if patch_count <= 0 then return [asm, kept_chunks, kept_tail] end if
  for i = 0 to patch_count - 1
    p = t.arr_chunked_get(patch_chunks, patch_tail, i, 256, 0)
    resolved = false
    patch_pos = try(p.pos)
    patch_target = try(p.target)
    if typeof(p) == "struct" and typeof(patch_pos) == "int" and typeof(patch_target) == "string" then
      target_pos = -1
      if typeof(asm.label_pos_map) == "struct" then
        target_pos = t.fastmap_get(asm.label_pos_map, patch_target, -1)
        if typeof(target_pos) != "int" then target_pos = -1 end if
      end if
      if target_pos >= 0 and patch_pos >= 0 and patch_pos + 3 < asm.size then
        disp = target_pos - (patch_pos + 4)
        b = t.u32(disp)
        asm = _set_chunk_byte(asm, patch_pos, b[0])
        asm = _set_chunk_byte(asm, patch_pos + 1, b[1])
        asm = _set_chunk_byte(asm, patch_pos + 2, b[2])
        asm = _set_chunk_byte(asm, patch_pos + 3, b[3])
        resolved = true
      end if
    end if
    if resolved == false then
      app = t.arr_chunked_push(kept_chunks, kept_tail, p, 256)
      kept_chunks = app[0]
      kept_tail = app[1]
    end if
  end for
  return [asm, kept_chunks, kept_tail]
end function

/// Encode or manage resolve defined patches in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function resolve_defined_patches(asm)
  // Resolve only patches emitted since the previous phase. Forward targets
  // move to a deferred generation instead of being scanned again after every
  // 128 functions. This keeps large-program code generation linear.
  r = _resolve_patch_set(asm, asm.patches_chunks, asm.patches_tail, asm.deferred_patches_chunks, asm.deferred_patches_tail)
  asm = r[0]
  asm.deferred_patches_chunks = r[1]
  asm.deferred_patches_tail = r[2]
  asm.patches_chunks = []
  asm.patches_tail = []
  asm.buf_valid = false
  return asm
end function

/// Encode or manage resolve all defined patches in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function resolve_all_defined_patches(asm)
  // Once helper labels have been emitted, revisit deferred forward references
  // exactly once. Only PE-section/data/IAT relocations remain pending.
  r = _resolve_patch_set(asm, asm.deferred_patches_chunks, asm.deferred_patches_tail, [], [])
  asm = r[0]
  r = _resolve_patch_set(asm, asm.patches_chunks, asm.patches_tail, r[1], r[2])
  asm = r[0]
  asm.deferred_patches_chunks = r[1]
  asm.deferred_patches_tail = r[2]
  asm.patches_chunks = []
  asm.patches_tail = []
  asm.buf_valid = false
  return asm
end function

/// Returns get calls.
/// @param asm Value supplied for `asm`.
function get_calls(asm)
  return t.arr_chunked_finish(asm.calls_chunks, asm.calls_tail)
end function

/// Returns get labels.
/// @param asm Value supplied for `asm`.
function get_labels(asm)
  if typeof(asm.labels) == "array" and len(asm.labels) > 0 then
    return asm.labels
  end if
  return t.arr_chunked_finish(asm.labels_chunks, asm.labels_tail)
end function

/// Releases or resets clear calls.
/// @param asm Value supplied for `asm`.
function clear_calls(asm)
  asm.calls_chunks = []
  asm.calls_tail = []
  return asm
end function

/// Releases or resets clear tracked helpers.
/// @param asm Value supplied for `asm`.
function clear_tracked_helpers(asm)
  asm.tracked_helpers = []
  asm.tracked_helper_map = t.fastmap_new(256)
  return asm
end function

/// Returns get tracked helpers.
/// @param asm Value supplied for `asm`.
function get_tracked_helpers(asm)
  return asm.tracked_helpers
end function

/// Encode or manage patch push in the native x64 assembler.
/// @internal
function _patch_push(asm, patch)
  app = t.arr_chunked_push(asm.patches_chunks, asm.patches_tail, patch, 256)
  asm.patches_chunks = app[0]
  asm.patches_tail = app[1]
  return asm
end function

/// Encode or manage call push in the native x64 assembler.
/// @internal
function _call_push(asm, label)
  app = t.arr_chunked_push(asm.calls_chunks, asm.calls_tail, label, 256)
  asm.calls_chunks = app[0]
  asm.calls_tail = app[1]
  return asm
end function

/// Encode or manage track helper label in the native x64 assembler.
/// @internal
function _track_helper_label(asm, label)
  if typeof(label) != "string" or label == "" then return asm end if
  if _starts_with_text(label, "fn_") == false then return asm end if
  if _starts_with_text(label, "fn_user_") then return asm end if
  if _starts_with_text(label, "fn_extern_") then return asm end if
  // Per-function return/defer targets share the fn_ prefix with runtime
  // helpers, but they are ordinary labels in the current text fragment.
  // Tracking them as helpers makes large programs feed thousands of local
  // labels into the iterative support-tail emitter.
  if _starts_with_text(label, "fn_ret_") then return asm end if
  if _starts_with_text(label, "fn_defer_") then return asm end if
  if typeof(asm.tracked_helpers) != "array" then asm.tracked_helpers = [] end if
  if typeof(asm.tracked_helper_map) != "struct" then
    asm.tracked_helper_map = t.fastmap_new(256)
    if len(asm.tracked_helpers) > 0 then
      for i = 0 to len(asm.tracked_helpers) - 1
        existing = asm.tracked_helpers[i]
        if typeof(existing) == "string" then
          asm.tracked_helper_map = t.fastmap_set(asm.tracked_helper_map, existing, 1)
        end if
      end for
    end if
  end if
  if t.fastmap_has(asm.tracked_helper_map, label) == false then
    asm.tracked_helpers = asm.tracked_helpers + [label]
    asm.tracked_helper_map = t.fastmap_set(asm.tracked_helper_map, label, 1)
  end if
  return asm
end function

/// Encode or manage spill before call in the native x64 assembler.
/// @internal
function _spill_before_call(asm)
  live = asm.before_call_live_temps
  if typeof(live) != "array" or len(live) <= 0 then return asm end if
  for i = 0 to len(live) - 1
    tmp = live[i]
    if typeof(tmp) != "struct" then continue end if
    if typeof(tmp.reg) != "string" or tmp.reg == "" then continue end if
    if typeof(tmp.dirty) != "bool" or tmp.dirty == false then continue end if
    asm = mov_membase_disp_r64(asm, "rsp", tmp.off, tmp.reg)
    tmp.dirty = false
  end for
  return asm
end function

/// Encode or manage label push in the native x64 assembler.
/// @internal
function _label_push(asm, label)
  app = t.arr_chunked_push(asm.labels_chunks, asm.labels_tail, label, 256)
  asm.labels_chunks = app[0]
  asm.labels_tail = app[1]
  return asm
end function

/// Encode or manage label index in the native x64 assembler.
/// @internal
function _label_index(labels, name)
  if len(labels) <= 0 then return -1 end if
  for i = 0 to len(labels) - 1
    if labels[i].name == name then return i end if
  end for
  return -1
end function

/// Encode or manage label pos in the native x64 assembler.
/// @internal
function _label_pos(labels, name)
  idx = _label_index(labels, name)
  if idx < 0 then return -1 end if
  return labels[idx].pos
end function

/// Encode or manage rid any in the native x64 assembler.
/// @internal
function _rid_any(name)
  if name == "rax" or name == "eax" or name == "al" then return 0 end if
  if name == "rcx" or name == "ecx" or name == "cl" then return 1 end if
  if name == "rdx" or name == "edx" or name == "dl" then return 2 end if
  if name == "rbx" or name == "ebx" or name == "bl" then return 3 end if
  if name == "rsp" or name == "esp" or name == "spl" then return 4 end if
  if name == "rbp" or name == "ebp" or name == "bpl" then return 5 end if
  if name == "rsi" or name == "esi" or name == "sil" then return 6 end if
  if name == "rdi" or name == "edi" or name == "dil" then return 7 end if
  if name == "r8" or name == "r8d" or name == "r8b" then return 8 end if
  if name == "r9" or name == "r9d" or name == "r9b" then return 9 end if
  if name == "r10" or name == "r10d" or name == "r10b" then return 10 end if
  if name == "r11" or name == "r11d" or name == "r11b" then return 11 end if
  if name == "r12" or name == "r12d" or name == "r12b" then return 12 end if
  if name == "r13" or name == "r13d" or name == "r13b" then return 13 end if
  if name == "r14" or name == "r14d" or name == "r14b" then return 14 end if
  if name == "r15" or name == "r15d" or name == "r15b" then return 15 end if
  return -1
end function

/// Reports whether is r8 name.
/// @internal
function _is_r8_name(name as string) returns bool
  return name == "al" or name == "cl" or name == "dl" or name == "bl" or name == "spl" or name == "bpl" or name == "sil" or name == "dil" or name == "r8b" or name == "r9b" or name == "r10b" or name == "r11b" or name == "r12b" or name == "r13b" or name == "r14b" or name == "r15b"
end function

/// Reports whether is r32 name.
/// @internal
function _is_r32_name(name as string) returns bool
  return name == "eax" or name == "ecx" or name == "edx" or name == "ebx" or name == "esp" or name == "ebp" or name == "esi" or name == "edi" or name == "r8d" or name == "r9d" or name == "r10d" or name == "r11d" or name == "r12d" or name == "r13d" or name == "r14d" or name == "r15d"
end function

/// Reports whether is force rex 8.
/// @internal
function _is_force_rex_8(name as string) returns bool
  return name == "spl" or name == "bpl" or name == "sil" or name == "dil"
end function

/// Encode or manage byte at in the native x64 assembler.
/// @internal
function _byte_at(asm, idx)
  if typeof(idx) != "int" or idx < 0 or idx >= asm.size then return -1 end if
  ci = idx >> 16
  off = idx & 0xFFFF
  pi = ci >> 8
  po = ci & 0xFF
  if pi < len(asm.chunk_pages) then
    pg = asm.chunk_pages[pi]
    if typeof(pg) == "array" and po >= 0 and po < len(pg) then
      ch = pg[po]
      if typeof(ch) == "bytes" and off >= 0 and off < len(ch) then return ch[off] end if
    end if
  else
    ti = ci - (len(asm.chunk_pages) << 8)
    if typeof(asm.chunk_tail) == "array" then
      if ti >= 0 and ti < len(asm.chunk_tail) and typeof(asm.chunk_tail[ti]) == "bytes" then
        ch2 = asm.chunk_tail[ti]
        if off >= 0 and off < len(ch2) then return ch2[off] end if
      end if
    else
      if typeof(asm.chunk_tail) == "struct" and typeof(asm.chunk_tail.data) == "array" then
        tn = t.arr_chunk_tail_len(asm.chunk_tail)
        if ti >= 0 and ti < tn and typeof(asm.chunk_tail.data[ti]) == "bytes" then
          ch3 = asm.chunk_tail.data[ti]
          if off >= 0 and off < len(ch3) then return ch3[off] end if
        end if
      end if
    end if
  end if
  return -1
end function

/// Encode or manage patches replace in the native x64 assembler.
/// @internal
function _patches_replace(asm, patches)
  asm.patches_chunks = []
  asm.patches_tail = []
  asm.deferred_patches_chunks = []
  asm.deferred_patches_tail = []
  if typeof(patches) != "array" then return asm end if
  for i = 0 to len(patches) - 1
    asm = _patch_push(asm, patches[i])
  end for
  return asm
end function

/// Releases or resets remove patch at.
/// @internal
function _remove_patch_at(asm, idx)
  patches = get_patches(asm)
  if typeof(patches) != "array" then return asm end if
  if idx < 0 or idx >= len(patches) then return asm end if
  kept = []
  for i = 0 to len(patches) - 1
    if i != idx then
      kept = kept + [patches[i]]
    end if
  end for
  return _patches_replace(asm, kept)
end function

/// Encode or manage last patch in the native x64 assembler.
/// @internal
function _last_patch(asm)
  tn = t.arr_chunk_tail_len(asm.patches_tail)
  if tn <= 0 then return 0 end if
  return t.arr_chunk_tail_get(asm.patches_tail, tn - 1, 0)
end function

/// Encode or manage drop last patch in the native x64 assembler.
/// @internal
function _drop_last_patch(asm)
  tn = t.arr_chunk_tail_len(asm.patches_tail)
  if tn <= 0 then return asm end if
  if typeof(asm.patches_tail) == "array" then
    asm.patches_tail = t.arr_drop_last(asm.patches_tail)
    return asm
  end if
  if typeof(asm.patches_tail) == "struct" then
    asm.patches_tail.used = tn - 1
  end if
  return asm
end function

/// Encode or manage chunk count in the native x64 assembler.
/// @internal
function _chunk_count(asm)
  n = 0
  if typeof(asm.chunk_pages) == "array" then n = n + (len(asm.chunk_pages) << 8) end if
  n = n + t.arr_chunk_tail_len(asm.chunk_tail)
  return n
end function

/// Encode or manage chunk get in the native x64 assembler.
/// @internal
function _chunk_get(asm, idx)
  if typeof(asm.active_chunk) == "bytes" and asm.active_chunk_index == idx then
    return asm.active_chunk
  end if
  pi = idx >> 8
  po = idx & 0xFF
  if pi < len(asm.chunk_pages) then
    pg = asm.chunk_pages[pi]
    return pg[po]
  end if
  ti = idx - (len(asm.chunk_pages) << 8)
  if typeof(asm.chunk_tail) == "array" then
    if ti >= 0 and ti < len(asm.chunk_tail) and typeof(asm.chunk_tail[ti]) == "bytes" then
      return asm.chunk_tail[ti]
    end if
  else
    if typeof(asm.chunk_tail) == "struct" and typeof(asm.chunk_tail.data) == "array" then
      tn = t.arr_chunk_tail_len(asm.chunk_tail)
      if ti >= 0 and ti < tn and typeof(asm.chunk_tail.data[ti]) == "bytes" then
        return asm.chunk_tail.data[ti]
      end if
    end if
  end if
  cs = asm.chunk_size
  if typeof(cs) != "int" or cs <= 0 then cs = 65536 end if
  return bytes(cs, 0)
end function

/// Encode or manage chunk set in the native x64 assembler.
/// @internal
function _chunk_set(asm, idx, chunk)
  asm.active_chunk = chunk
  asm.active_chunk_index = idx
  pi = idx >> 8
  po = idx & 0xFF
  if pi < len(asm.chunk_pages) then
    pg = asm.chunk_pages[pi]
    pg[po] = chunk
    asm.chunk_pages[pi] = pg
    return asm
  end if
  ti = idx - (len(asm.chunk_pages) << 8)
  asm.chunk_tail = t.arr_chunk_tail_set(asm.chunk_tail, ti, chunk)
  return asm
end function

/// Encode or manage chunk push in the native x64 assembler.
/// @internal
function _chunk_push(asm, chunk)
  app = t.arr_chunked_push(asm.chunk_pages, asm.chunk_tail, chunk, 256)
  asm.chunk_pages = app[0]
  asm.chunk_tail = app[1]
  return asm
end function

/// Materialization releases the paged backing store to reduce compiler peak memory. Recreate it lazily if a caller later resumes emission or patching. This keeps materialize() reusable without retaining both representations.
/// @internal
function _restore_materialized_chunks(asm)
  if typeof(asm) != "struct" or asm.buf_valid == false then return asm end if
  if typeof(asm.buf) != "bytes" or typeof(asm.size) != "int" or asm.size <= 0 then return asm end if
  cs = asm.chunk_size
  if typeof(cs) != "int" or cs <= 0 then cs = 65536 end if
  want_chunks = asm.size >> 16
  if (asm.size & 0xFFFF) != 0 then want_chunks = want_chunks + 1 end if
  if _chunk_count(asm) >= want_chunks then return asm end if

  asm.chunk_pages = []
  asm.chunk_tail = []
  src = 0
  ci = 0
  while src < asm.size
    chunk = bytes(cs, 0)
    take = asm.size - src
    if take > cs then take = cs end if
    copyBytes(chunk, 0, asm.buf, src, take)
    asm = _chunk_push(asm, chunk)
    asm.active_chunk = chunk
    asm.active_chunk_index = ci
    src = src + take
    ci = ci + 1
  end while
  return asm
end function

/// Encode or manage ensure capacity in the native x64 assembler.
/// @internal
function _ensure_capacity(asm, need)
  if need <= 0 then return asm end if
  // Normal emission keeps buf_valid false, so the hot capacity path avoids a
  // helper call unless a compact materialized snapshot is actually present.
  if asm.buf_valid then asm = _restore_materialized_chunks(asm) end if
  cs = asm.chunk_size
  if typeof(cs) != "int" or cs <= 0 then
    cs = 65536
    asm.chunk_size = cs
  end if
  if typeof(asm.chunk_pages) != "array" then asm.chunk_pages = [] end if
  if typeof(asm.chunk_tail) != "array" and typeof(asm.chunk_tail) != "struct" then asm.chunk_tail = [] end if

  want_chunks = need >> 16
  if (need & 0xFFFF) != 0 then want_chunks = want_chunks + 1 end if
  while _chunk_count(asm) < want_chunks
    asm = _chunk_push(asm, bytes(cs, 0))
  end while
  return asm
end function

/// Updates set chunk byte.
/// @internal
function _set_chunk_byte(asm, idx, value)
  asm = _ensure_capacity(asm, asm.size)
  ci = idx >> 16
  off = idx & 0xFFFF
  ch = _chunk_get(asm, ci)
  ch[off] = value & 0xFF
  asm = _chunk_set(asm, ci, ch)
  asm.buf_valid = false
  return asm
end function

/// Encode or manage materialize buffer in the native x64 assembler.
/// @internal
function _materialize_buffer(asm)
  /// Current materialize keepalive used by this routine.
  /// @internal
  global _materialize_keepalive
  if typeof(asm.buf) == "bytes" and asm.buf_valid and len(asm.buf) == asm.size then
    return asm
  end if
  if asm.size <= 0 then
    asm.buf = bytes(0)
    asm.buf_valid = true
    return asm
  end if

  _materialize_keepalive = asm
  asm = _ensure_capacity(asm, asm.size)
  asm_keep = asm
  _materialize_keepalive = asm_keep
  asm_keep = _keepalive_barrier(asm_keep)
  chunk_n = _chunk_count(asm_keep)
  if chunk_n < 0 then return asm_keep end if
  size0 = asm_keep.size
  buf_out = _alloc_zero_bytes_keepalive(asm_keep, size0)
  asm = asm_keep
  if typeof(_materialize_keepalive) == "struct" then asm = _materialize_keepalive end if
  cs = asm.chunk_size
  dst = 0
  ci = 0
  cn = _chunk_count(asm)
  while dst < asm.size and ci < cn
    ch = _chunk_get(asm, ci)
    take = cs
    left = asm.size - dst
    if left < take then take = left end if
    for j = 0 to take - 1
      buf_out[dst + j] = ch[j]
    end for
    dst = dst + take
    ci = ci + 1
  end while
  asm.buf = buf_out
  asm.buf_valid = true
  asm.chunk_pages = []
  asm.chunk_tail = []
  asm.active_chunk = bytes(0)
  asm.active_chunk_index = -1
  _materialize_keepalive = 0
  return asm
end function

/// Encode or manage emit in the native x64 assembler.
/// @internal
function _emit(asm, b)
  if typeof(b) != "bytes" or len(b) <= 0 then return asm end if
  need = asm.size + len(b)
  asm = _ensure_capacity(asm, need)
  src = 0
  dst = asm.size
  cs = asm.chunk_size
  while src < len(b)
    ci = dst >> 16
    off = dst & 0xFFFF
    ch = _chunk_get(asm, ci)
    take = cs - off
    left = len(b) - src
    if left < take then take = left end if
    for j = 0 to take - 1
      ch[off + j] = b[src + j]
    end for
    asm = _chunk_set(asm, ci, ch)
    dst = dst + take
    src = src + take
  end while
  asm.size = need
  asm.buf_valid = false
  return asm
end function

/// Encode or manage emit8 in the native x64 assembler.
/// @internal
function _emit8(asm, x)
  dst = asm.size
  need = dst + 1
  if asm.buf_valid or (dst & 0xFFFF) == 0 then
    asm = _ensure_capacity(asm, need)
  end if
  ci = dst >> 16
  off = dst & 0xFFFF
  ch = asm.active_chunk
  if typeof(ch) != "bytes" or asm.active_chunk_index != ci then
    ch = _chunk_get(asm, ci)
    asm.active_chunk = ch
    asm.active_chunk_index = ci
  end if
  ch[off] = x & 0xFF
  asm.active_chunk = ch
  asm.size = need
  asm.buf_valid = false
  return asm
end function

/// Encode or manage materialize in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function materialize(asm)
  return _materialize_buffer(asm)
end function

/// Encode or manage emit32 in the native x64 assembler.
/// @internal
function _emit32(asm, x)
  dst = asm.size
  need = dst + 4
  asm = _ensure_capacity(asm, need)
  ci = dst >> 16
  off = dst & 0xFFFF
  if off <= 0xFFFC then
    ch = _chunk_get(asm, ci)
    ch[off] = x & 0xFF
    ch[off + 1] = (x >> 8) & 0xFF
    ch[off + 2] = (x >> 16) & 0xFF
    ch[off + 3] = (x >> 24) & 0xFF
    asm = _chunk_set(asm, ci, ch)
    asm.size = need
    asm.buf_valid = false
    return asm
  end if
  asm = _emit8(asm, x & 0xFF)
  asm = _emit8(asm, (x >> 8) & 0xFF)
  asm = _emit8(asm, (x >> 16) & 0xFF)
  return _emit8(asm, (x >> 24) & 0xFF)
end function

/// Add a relocation owned by a separately assembled fragment. This keeps large parent assemblers out of the fragment's per-instruction update path.
/// @param asm Value supplied for `asm`.
/// @param position Value supplied for `position`.
/// @param label Value supplied for `label`.
/// @param kind Value supplied for `kind`.
function add_patch(asm, position, label, kind)
  return _patch_push(asm, AsmPatch(position, label, kind))
end function

/// Encode or manage emit64 in the native x64 assembler.
/// @internal
function _emit64(asm, x)
  dst = asm.size
  need = dst + 8
  asm = _ensure_capacity(asm, need)
  ci = dst >> 16
  off = dst & 0xFFFF
  if off <= 0xFFF8 then
    ch = _chunk_get(asm, ci)
    ch[off] = x & 0xFF
    ch[off + 1] = (x >> 8) & 0xFF
    ch[off + 2] = (x >> 16) & 0xFF
    ch[off + 3] = (x >> 24) & 0xFF
    ch[off + 4] = (x >> 32) & 0xFF
    ch[off + 5] = (x >> 40) & 0xFF
    ch[off + 6] = (x >> 48) & 0xFF
    ch[off + 7] = (x >> 56) & 0xFF
    asm = _chunk_set(asm, ci, ch)
    asm.size = need
    asm.buf_valid = false
    return asm
  end if
  for i = 0 to 7
    asm = _emit8(asm, (x >> (i * 8)) & 0xFF)
  end for
  return asm
end function

/// Encode or manage pos in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @returns The resulting `int` value.
function pos(asm as struct) returns int
  return asm.size
end function

/// Encode or manage emit rex in the native x64 assembler.
/// @internal
function _emit_rex(asm, w, r, x, b, force)
  if (w | r | x | b) == 0 and force == false then
    return asm
  end if
  v = 0x40 |((w & 1) << 3) |((r & 1) << 2) |((x & 1) << 1) |(b & 1)
  return _emit8(asm, v)
end function

/// Encode or manage emit modrm in the native x64 assembler.
/// @internal
function _emit_modrm(asm, mod, reg, rm)
  v = ((mod & 3) << 6) |((reg & 7) << 3) |(rm & 7)
  return _emit8(asm, v)
end function

/// Encode or manage modrm byte in the native x64 assembler.
/// @internal
function _modrm_byte(mod as int, reg as int, rm as int) returns int
  return ((mod & 3) << 6) |((reg & 7) << 3) |(rm & 7)
end function

/// Encode or manage sib byte in the native x64 assembler.
/// @internal
function _sib_byte(scale as int, index as int, base as int) returns int
  return ((scale & 3) << 6) |((index & 7) << 3) |(base & 7)
end function

/// Encode or manage fits i8 in the native x64 assembler.
/// @internal
function _fits_i8(x as int) returns bool
  return x >= -128 and x <= 127
end function

/// Encode or manage emit bytes u8 in the native x64 assembler.
/// @internal
function _emit_bytes_u8(v)
  b = bytes(1, 0)
  b[0] = v & 0xFF
  return b
end function

/// Converts encode mem.
/// @internal
function _encode_mem(reg_field, base_id, disp)
  base_lo = base_id & 7
  rex_b = 0
  if base_id >= 8 then rex_b = 1 end if
  rex_x = 0

  use_sib = false
  if base_lo == 4 then use_sib = true end if

  mod = 0
  disp_bytes = bytes(0)
  if disp == 0 and base_lo != 5 then
    mod = 0
  else
    if _fits_i8(disp) then
      mod = 1
      disp_bytes = _emit_bytes_u8(disp)
    else
      mod = 2
      disp_bytes = t.u32(disp)
    end if
  end if

  if disp == 0 and base_lo == 5 then
    mod = 1
    disp_bytes = bytes(1, 0)
  end if

  tail = bytes(0)
  if use_sib then
    modrm = _modrm_byte(mod, reg_field, 4)
    sib = _sib_byte(0, 4, base_lo)
    tail = _emit_bytes_u8(modrm) + _emit_bytes_u8(sib) + disp_bytes
  else
    modrm = _modrm_byte(mod, reg_field, base_lo)
    tail = _emit_bytes_u8(modrm) + disp_bytes
  end if
  return EncMem(rex_x, rex_b, tail)
end function

/// Encode or manage scale bits in the native x64 assembler.
/// @internal
function _scale_bits(scale)
  if scale == 1 then return 0 end if
  if scale == 2 then return 1 end if
  if scale == 4 then return 2 end if
  if scale == 8 then return 3 end if
  return error(1, "Invalid SIB scale: " + scale)
end function

/// Converts encode mem bis.
/// @internal
function _encode_mem_bis(reg_field, base_id, index_id, scale, disp)
  base_lo = base_id & 7
  idx_lo = index_id & 7
  rex_b = 0
  if base_id >= 8 then rex_b = 1 end if
  rex_x = 0
  if index_id >= 8 then rex_x = 1 end if
  if idx_lo == 4 then
    return error(1, "SIB index cannot be rsp/r12")
  end if

  mod = 0
  disp_bytes = bytes(0)
  if disp == 0 and base_lo != 5 then
    mod = 0
  else
    if _fits_i8(disp) then
      mod = 1
      disp_bytes = _emit_bytes_u8(disp)
    else
      mod = 2
      disp_bytes = t.u32(disp)
    end if
  end if

  if disp == 0 and base_lo == 5 then
    mod = 1
    disp_bytes = bytes(1, 0)
  end if

  modrm = _modrm_byte(mod, reg_field, 4)
  sib = _sib_byte(_scale_bits(scale), idx_lo, base_lo)
  tail = _emit_bytes_u8(modrm) + _emit_bytes_u8(sib) + disp_bytes
  return EncMem(rex_x, rex_b, tail)
end function

/// Encode or manage vex3 in the native x64 assembler.
/// @internal
function _vex3(m, w, vvvv, l, pp, r, x, b)
  rb = 1
  if r != 0 then rb = 0 end if
  xb = 1
  if x != 0 then xb = 0 end if
  bb = 1
  if b != 0 then bb = 0 end if
  b1 = (rb << 7) |(xb << 6) |(bb << 5) |(m & 0x1F)
  v_field = 0xF
  if vvvv == void then
    v_field = 0xF
  else
    v_field = 0xF ^ (vvvv & 0xF)
  end if
  b2 = ((w & 1) << 7) |(v_field << 3) |((l & 1) << 2) |(pp & 0x3)
  return _emit_bytes_u8(0xC4) + _emit_bytes_u8(b1) + _emit_bytes_u8(b2)
end function

/// Encode or manage xmm id in the native x64 assembler.
/// @internal
function _xmm_id(name)
  if name == "xmm0" then return 0 end if
  if name == "xmm1" then return 1 end if
  if name == "xmm2" then return 2 end if
  if name == "xmm3" then return 3 end if
  if name == "xmm4" then return 4 end if
  if name == "xmm5" then return 5 end if
  if name == "xmm6" then return 6 end if
  if name == "xmm7" then return 7 end if
  if name == "xmm8" then return 8 end if
  if name == "xmm9" then return 9 end if
  if name == "xmm10" then return 10 end if
  if name == "xmm11" then return 11 end if
  if name == "xmm12" then return 12 end if
  if name == "xmm13" then return 13 end if
  if name == "xmm14" then return 14 end if
  if name == "xmm15" then return 15 end if
  return -1
end function

/// Encode or manage ymm id in the native x64 assembler.
/// @internal
function _ymm_id(name)
  if name == "ymm0" then return 0 end if
  if name == "ymm1" then return 1 end if
  if name == "ymm2" then return 2 end if
  if name == "ymm3" then return 3 end if
  if name == "ymm4" then return 4 end if
  if name == "ymm5" then return 5 end if
  if name == "ymm6" then return 6 end if
  if name == "ymm7" then return 7 end if
  if name == "ymm8" then return 8 end if
  if name == "ymm9" then return 9 end if
  if name == "ymm10" then return 10 end if
  if name == "ymm11" then return 11 end if
  if name == "ymm12" then return 12 end if
  if name == "ymm13" then return 13 end if
  if name == "ymm14" then return 14 end if
  if name == "ymm15" then return 15 end if
  return -1
end function

/// Encode or manage emit in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param b Second input value.
function emit(asm, b)
  return _emit(asm, b)
end function

/// Encode or manage emit8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param x Value supplied for `x`.
function emit8(asm, x)
  return _emit8(asm, x)
end function

/// Encode or manage emit32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param x Value supplied for `x`.
function emit32(asm, x)
  return _emit32(asm, x)
end function

/// Encode or manage emit64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param x Value supplied for `x`.
function emit64(asm, x)
  return _emit64(asm, x)
end function

/// Encode or manage mov rax gs qword 28 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function mov_rax_gs_qword_28(asm)
  vals = [0x65, 0x48, 0x8B, 0x04, 0x25, 0x28, 0, 0, 0]
  for i = 0 to len(vals) - 1 asm = _emit8(asm, vals[i]) end for
  return asm
end function

/// Encode or manage mov r11 gs qword 28 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function mov_r11_gs_qword_28(asm)
  vals = [0x65, 0x4C, 0x8B, 0x1C, 0x25, 0x28, 0, 0, 0]
  for i = 0 to len(vals) - 1 asm = _emit8(asm, vals[i]) end for
  return asm
end function

/// Encode or manage mov r10 gs qword 28 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function mov_r10_gs_qword_28(asm)
  vals = [0x65, 0x4C, 0x8B, 0x14, 0x25, 0x28, 0, 0, 0]
  for i = 0 to len(vals) - 1 asm = _emit8(asm, vals[i]) end for
  return asm
end function

/// Encode or manage mov gs qword 28 rax in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function mov_gs_qword_28_rax(asm)
  vals = [0x65, 0x48, 0x89, 0x04, 0x25, 0x28, 0, 0, 0]
  for i = 0 to len(vals) - 1 asm = _emit8(asm, vals[i]) end for
  return asm
end function

/// Encode or manage gc tmp context offset in the native x64 assembler.
/// @internal
function _gc_tmp_context_offset(label)
  if label == "gc_tmp0" then return 56 end if
  if label == "gc_tmp1" then return 64 end if
  if label == "gc_tmp2" then return 72 end if
  if label == "gc_tmp3" then return 80 end if
  if label == "gc_tmp4" then return 88 end if
  if label == "gc_tmp5" then return 96 end if
  if label == "gc_tmp6" then return 104 end if
  if label == "gc_tmp7" then return 112 end if
  return -1
end function

/// Encode or manage mark in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param name Name of the requested item.
function mark(asm, name)
  here = pos(asm)
  // Never fold stack operations across a control-flow boundary.
  asm.peephole_last_push = []
  last_jump = []
  if typeof(asm.peephole_last_jump) == "array" then last_jump = asm.peephole_last_jump end if
  if len(last_jump) == 4 then
    start = last_jump[0]
    jend = last_jump[1]
    target = last_jump[2]
    disp_pos = last_jump[3]
    if target == name and jend == here then
      p = _last_patch(asm)
      if typeof(p) == "struct" and p.pos == disp_pos and p.target == name then
        asm = _drop_last_patch(asm)
      end if
      asm = _peephole_trim_tail(asm, jend - start)
    end if
  end if
  asm.peephole_last_jump = []
  asm.labels = []
  asm = _label_push(asm, AsmLabel(name, pos(asm)))
  if typeof(asm.label_pos_map) != "struct" then asm.label_pos_map = t.fastmap_new(256) end if
  asm.label_pos_map = t.fastmap_set(asm.label_pos_map, name, pos(asm))
  return asm
end function

/// Encode or manage finalize in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function finalize(asm)
  labels = get_labels(asm)
  if typeof(labels) != "array" then labels = [] end if
  asm.labels = labels
  label_pos_map = t.fastmap_new((len(labels) * 2) + 64)
  if len(labels) > 0 then
    for li = 0 to len(labels) - 1
      lb = labels[li]
      if typeof(lb) == "struct" and typeof(lb.name) == "string" and typeof(lb.pos) == "int" then
        label_pos_map = t.fastmap_set(label_pos_map, lb.name, lb.pos)
      end if
    end for
  end if
  patches = get_patches(asm)
  if len(patches) > 0 then
    asm = _ensure_capacity(asm, asm.size)
    asm.buf_valid = false
    for i = 0 to len(patches) - 1
      p = patches[i]
      tgt = t.fastmap_get(label_pos_map, p.target, -1)
      if typeof(tgt) != "int" then tgt = -1 end if
      if tgt < 0 then
        return error(1, "Unknown label referenced in patch: " + p.target)
      end if
      disp = tgt -(p.pos + 4)
      b = t.u32(disp)
      if p.pos + 3 < asm.size then
        asm = _set_chunk_byte(asm, p.pos, b[0])
        asm = _set_chunk_byte(asm, p.pos + 1, b[1])
        asm = _set_chunk_byte(asm, p.pos + 2, b[2])
        asm = _set_chunk_byte(asm, p.pos + 3, b[3])
      end if
    end for
  end if
  asm = _materialize_buffer(asm)
  return asm.buf
end function

/// Encode or manage nop in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function nop(asm)
  return _emit8(asm, 0x90)
end function

/// Encode or manage jmp in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function jmp(asm, label)
  target = -1
  if typeof(asm.label_pos_map) == "struct" then
    target = t.fastmap_get(asm.label_pos_map, label, -1)
    if typeof(target) != "int" then target = -1 end if
  end if
  if target >= 0 then
    disp8 = target -(pos(asm) + 2)
    if disp8 >= -128 and disp8 <= 127 then
      asm = _emit8(asm, 0xEB)
      asm = _emit8(asm, disp8)
      return asm
    end if
  end if

  start = pos(asm)
  asm = _emit8(asm, 0xE9)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rel32"))
  asm.peephole_last_jump = [start, pos(asm), label, p]
  return asm
end function

/// Encode or manage jmp r64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg Value supplied for `reg`.
function jmp_r64(asm, reg)
  r = _rid_any(reg)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 0, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xFF)
  asm = _emit_modrm(asm, 3, 4, r & 7)
  return asm
end function

/// Encode or manage jcc in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param cc Value supplied for `cc`.
/// @param label Value supplied for `label`.
function jcc(asm, cc, label)
  op = -1
  if cc == "e" or cc == "z" then op = 0x84 end if
  if cc == "ne" or cc == "nz" then op = 0x85 end if
  if cc == "l" then op = 0x8C end if
  if cc == "le" then op = 0x8E end if
  if cc == "g" then op = 0x8F end if
  if cc == "ge" then op = 0x8D end if
  if cc == "b" then op = 0x82 end if
  if cc == "be" then op = 0x86 end if
  if cc == "a" then op = 0x87 end if
  if cc == "ae" then op = 0x83 end if
  if cc == "s" then op = 0x88 end if
  if cc == "ns" then op = 0x89 end if
  if cc == "p" then op = 0x8A end if
  if cc == "np" then op = 0x8B end if
  if cc == "o" then op = 0x80 end if
  if cc == "no" then op = 0x81 end if
  if op < 0 then return asm end if

  target = -1
  if typeof(asm.label_pos_map) == "struct" then
    target = t.fastmap_get(asm.label_pos_map, label, -1)
    if typeof(target) != "int" then target = -1 end if
  end if
  if target >= 0 then
    disp8 = target -(pos(asm) + 2)
    if disp8 >= -128 and disp8 <= 127 then
      asm = _emit8(asm, 0x70 | (op & 0x0F))
      asm = _emit8(asm, disp8)
      return asm
    end if
  end if

  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, op)
  start = pos(asm) - 2
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rel32"))
  asm.peephole_last_jump = [start, pos(asm), label, p]
  return asm
end function

/// Encode or manage je in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function je(asm, label) return jcc(asm, "e", label) end function
/// Encode or manage jz in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function jz(asm, label) return jcc(asm, "z", label) end function
/// Encode or manage jne in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function jne(asm, label) return jcc(asm, "ne", label) end function
/// Encode or manage jnz in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function jnz(asm, label) return jcc(asm, "nz", label) end function
/// Encode or manage jl in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function jl(asm, label) return jcc(asm, "l", label) end function
/// Encode or manage jle in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function jle(asm, label) return jcc(asm, "le", label) end function
/// Encode or manage jg in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function jg(asm, label) return jcc(asm, "g", label) end function
/// Encode or manage jge in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function jge(asm, label) return jcc(asm, "ge", label) end function
/// Encode or manage jb in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function jb(asm, label) return jcc(asm, "b", label) end function
/// Encode or manage jbe in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function jbe(asm, label) return jcc(asm, "be", label) end function
/// Encode or manage ja in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function ja(asm, label) return jcc(asm, "a", label) end function
/// Encode or manage jae in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function jae(asm, label) return jcc(asm, "ae", label) end function

/// Encode or manage call in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function call(asm, label)
  asm = _spill_before_call(asm)
  asm = _emit8(asm, 0xE8)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rel32"))
  if typeof(label) == "string" then
    if asm.record_calls then asm = _call_push(asm, label) end if
    asm = _track_helper_label(asm, label)
  end if
  return asm
end function

/// Encode or manage call rax in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function call_rax(asm)
  asm = _spill_before_call(asm)
  asm = _emit8(asm, 0xFF)
  asm = _emit8(asm, 0xD0)
  return asm
end function

/// Encode or manage call membase disp in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
function call_membase_disp(asm, base, disp)
  asm = _spill_before_call(asm)
  b = _rid_any(base)
  if b < 0 then return asm end if
  enc = _encode_mem(2, b, disp)
  asm = _emit_rex(asm, 0, 0, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0xFF)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage call rip qword in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function call_rip_qword(asm, label)
  asm = _spill_before_call(asm)
  asm = _emit8(asm, 0xFF)
  asm = _emit8(asm, 0x15)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rip32"))
  return asm
end function

/// Encode or manage ret in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function ret(asm)
  return _emit8(asm, 0xC3)
end function

/// Encode or manage leave in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function leave(asm)
  return _emit8(asm, 0xC9)
end function

/// Encode or manage lea r64 rip in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param label Value supplied for `label`.
function lea_r64_rip(asm, dst, label)
  rd = _rid_any(dst)
  if rd < 0 then return asm end if
  // LEA r64,[RIP+disp32]: destination is encoded in ModRM.reg => REX.R
  asm = _emit_rex(asm, 1, (rd >> 3) & 1, 0, 0, false)
  asm = _emit8(asm, 0x8D)
  asm = _emit_modrm(asm, 0, rd & 7, 5)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rip32"))
  return asm
end function

/// Encode or manage lea rax rip in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
/// @returns The resulting `struct` value.
function lea_rax_rip(asm as struct, label as string) returns struct
  return lea_r64_rip(asm, "rax", label)
end function

/// Encode or manage lea rdx rip in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function lea_rdx_rip(asm, label)
  return lea_r64_rip(asm, "rdx", label)
end function

/// Encode or manage lea r8 rip in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function lea_r8_rip(asm, label)
  return lea_r64_rip(asm, "r8", label)
end function

/// Encode or manage lea r9 rip in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function lea_r9_rip(asm, label)
  return lea_r64_rip(asm, "r9", label)
end function

/// Encode or manage lea r11 rip in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function lea_r11_rip(asm, label)
  return lea_r64_rip(asm, "r11", label)
end function

/// Updates push reg.
/// @param asm Value supplied for `asm`.
/// @param reg Value supplied for `reg`.
function push_reg(asm, reg)
  rid = _rid_any(reg)
  if rid < 0 then return asm end if
  push_len = 1
  if rid >= 8 then
    asm = _emit8(asm, 0x41)
    push_len = 2
  end if
  asm = _emit8(asm, 0x50 +(rid & 7))
  asm.peephole_last_push = [asm.size, rid, push_len]
  return asm
end function

/// Encode or manage pop reg in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg Value supplied for `reg`.
function pop_reg(asm, reg)
  rid = _rid_any(reg)
  if rid < 0 then return asm end if
  push_len = 1
  if rid >= 8 then push_len = 2 end if
  last_push = asm.peephole_last_push
  asm.peephole_last_push = []
  if typeof(last_push) == "array" and len(last_push) == 3 and last_push[0] == asm.size and last_push[1] == rid and last_push[2] == push_len and asm.size >= push_len then
    start = asm.size - push_len
    ok = true
    if rid >= 8 and _byte_at(asm, start) != 0x41 then ok = false end if
    if ok and _byte_at(asm, asm.size - 1) != 0x50 +(rid & 7) then ok = false end if
    if ok then
      return _peephole_trim_tail(asm, push_len)
    end if
  end if
  if rid >= 8 then
    asm = _emit8(asm, 0x41)
  end if
  asm = _emit8(asm, 0x58 +(rid & 7))
  return asm
end function

/// Updates push rbx.
/// @param asm Value supplied for `asm`.
function push_rbx(asm) return push_reg(asm, "rbx") end function
/// Encode or manage pop rbx in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function pop_rbx(asm) return pop_reg(asm, "rbx") end function
/// Updates push r12.
/// @param asm Value supplied for `asm`.
function push_r12(asm) return push_reg(asm, "r12") end function
/// Encode or manage pop r12 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function pop_r12(asm) return pop_reg(asm, "r12") end function
/// Updates push r13.
/// @param asm Value supplied for `asm`.
function push_r13(asm) return push_reg(asm, "r13") end function
/// Encode or manage pop r13 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function pop_r13(asm) return pop_reg(asm, "r13") end function
/// Updates push r14.
/// @param asm Value supplied for `asm`.
function push_r14(asm) return push_reg(asm, "r14") end function
/// Encode or manage pop r14 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function pop_r14(asm) return pop_reg(asm, "r14") end function
/// Updates push r15.
/// @param asm Value supplied for `asm`.
function push_r15(asm) return push_reg(asm, "r15") end function
/// Encode or manage pop r15 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function pop_r15(asm) return pop_reg(asm, "r15") end function
/// Updates push rbp.
/// @param asm Value supplied for `asm`.
function push_rbp(asm) return push_reg(asm, "rbp") end function
/// Encode or manage pop rbp in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function pop_rbp(asm) return pop_reg(asm, "rbp") end function

/// Encode or manage mov rbp rsp in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function mov_rbp_rsp(asm)
  return mov_r64_r64(asm, "rbp", "rsp")
end function

/// Encode or manage mov r64 imm64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param imm Value supplied for `imm`.
function mov_r64_imm64(asm, dst, imm)
  rd = _rid_any(dst)
  if rd < 0 then return asm end if
  rex_b = (rd >> 3) & 1
  imm_v = imm
  imm_u = imm & 0xFFFFFFFFFFFFFFFF
  if imm_v >= 0 and imm_v <= 0xFFFFFFFF then
    asm = _emit_rex(asm, 0, 0, 0, rex_b, false)
    asm = _emit8(asm, 0xB8 +(rd & 7))
    asm = _emit32(asm, imm_u)
    return asm
  end if
  if imm_v < 0 and imm_v >= -2147483648 then
    asm = _emit_rex(asm, 1, 0, 0, rex_b, false)
    asm = _emit8(asm, 0xC7)
    asm = _emit_modrm(asm, 3, 0, rd & 7)
    asm = _emit32(asm, imm_u)
    return asm
  end if
  asm = _emit_rex(asm, 1, 0, 0, rex_b, false)
  asm = _emit8(asm, 0xB8 +(rd & 7))
  asm = _emit64(asm, imm_u)
  return asm
end function

/// Encode or manage mov r32 imm32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param imm Value supplied for `imm`.
function mov_r32_imm32(asm, dst, imm)
  rd = _rid_any(dst)
  if rd < 0 then return asm end if
  if rd >= 8 then
    asm = _emit_rex(asm, 0, 0, 0, 1, false)
  end if
  asm = _emit8(asm, 0xB8 +(rd & 7))
  asm = _emit32(asm, imm)
  return asm
end function

/// Encode or manage mov rax imm64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param imm Value supplied for `imm`.
/// @returns The resulting `struct` value.
function mov_rax_imm64(asm as struct, imm as int) returns struct
  return mov_r64_imm64(asm, "rax", imm)
end function

/// Encode or manage mov r64 tagged int in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param value Value to process.
function mov_r64_tagged_int(asm, dst, value)
  // Shifting a compiler-host integer is only exact while the tagged result
  // still fits MiniLang's own signed-61 payload. Split wider results into
  // two u32 halves so minimum/maximum target integers keep every raw bit.
  if value >= -144115188075855872 and value <= 144115188075855871 then
    return mov_r64_imm64(asm, dst, t.enc_int(value))
  end if
  lo32 = ((value & 0x1FFFFFFF) << 3) | 1
  hi32 = (value >> 29) & 0xFFFFFFFF
  return mov_r64_u64_hi_lo_exact(asm, dst, hi32, lo32)
end function

/// Encode or manage mov rax tagged int in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param value Value to process.
/// @returns The resulting `struct` value.
function mov_rax_tagged_int(asm as struct, value as int) returns struct
  return mov_r64_tagged_int(asm, "rax", value)
end function

/// Encode or manage mov r64 u64 hi lo exact in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param hi32 Value supplied for `hi32`.
/// @param lo32 Value supplied for `lo32`.
function mov_r64_u64_hi_lo_exact(asm, dst, hi32, lo32)
  rd = _rid_any(dst)
  if rd < 0 then return asm end if
  asm = _emit_rex(asm, 1, 0, 0, (rd >> 3) & 1, false)
  asm = _emit8(asm, 0xB8 +(rd & 7))
  asm = _emit32(asm, lo32)
  asm = _emit32(asm, hi32)
  return asm
end function

/// Encode or manage mov rax u64 hi lo exact in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param hi32 Value supplied for `hi32`.
/// @param lo32 Value supplied for `lo32`.
function mov_rax_u64_hi_lo_exact(asm, hi32, lo32)
  return mov_r64_u64_hi_lo_exact(asm, "rax", hi32, lo32)
end function

/// Encode or manage mov rcx imm32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param imm Value supplied for `imm`.
/// @returns The resulting `struct` value.
function mov_rcx_imm32(asm as struct, imm as int) returns struct
  return mov_r32_imm32(asm, "ecx", imm)
end function

/// Encode or manage mov r8d imm32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param imm Value supplied for `imm`.
function mov_r8d_imm32(asm, imm)
  return mov_r32_imm32(asm, "r8d", imm)
end function

/// Encode or manage mov r64 r64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function mov_r64_r64(asm, dst, src)
  if dst == src then return asm end if
  rd = _rid_any(dst)
  rs = _rid_any(src)
  if rd < 0 or rs < 0 then return asm end if
  asm = _emit_rex(asm, 1, (rd >> 3) & 1, 0, (rs >> 3) & 1, false)
  asm = _emit8(asm, 0x8B)
  asm = _emit_modrm(asm, 3, rd & 7, rs & 7)
  return asm
end function

/// Encode or manage mov r32 r32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function mov_r32_r32(asm, dst, src)
  if dst == src then return asm end if
  rd = _rid_any(dst)
  rs = _rid_any(src)
  if rd < 0 or rs < 0 then return asm end if
  asm = _emit_rex(asm, 0, (rd >> 3) & 1, 0, (rs >> 3) & 1, false)
  asm = _emit8(asm, 0x8B)
  asm = _emit_modrm(asm, 3, rd & 7, rs & 7)
  return asm
end function

/// Encode or manage mov r8 r8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function mov_r8_r8(asm, dst, src)
  if dst == src then return asm end if
  rd = _rid_any(dst)
  rs = _rid_any(src)
  if rd < 0 or rs < 0 then return asm end if
  if _is_r8_name(dst) == false or _is_r8_name(src) == false then return error(1, "mov_r8_r8 requires 8-bit registers") end if
  force = _is_force_rex_8(dst) or _is_force_rex_8(src)
  asm = _emit_rex(asm, 0, (rd >> 3) & 1, 0, (rs >> 3) & 1, force)
  asm = _emit8(asm, 0x8A)
  asm = _emit_modrm(asm, 3, rd & 7, rs & 7)
  return asm
end function

/// Encode or manage grp1 imm in the native x64 assembler.
/// @internal
function _grp1_imm(asm, size, subop, rm, imm)
  if size != 8 and size != 32 and size != 64 then return error(1, "Unsupported operand size for grp1") end if
  rd = -1
  opcode = 0
  imm_bytes = bytes(0)
  w = 0
  if typeof(rm) == "string" then
    rd = _rid_any(rm)
  else
    rd = rm
  end if
  if rd < 0 then return asm end if
  if size == 8 then
    opcode = 0x80
    imm_bytes = _emit_bytes_u8(imm)
    w = 0
  else
    if _fits_i8(imm) then
      opcode = 0x83
      imm_bytes = _emit_bytes_u8(imm)
    else
      opcode = 0x81
      imm_bytes = t.u32(imm)
    end if
    if size == 64 then w = 1 else w = 0 end if
  end if
  asm = _emit_rex(asm, w, 0, 0, (rd >> 3) & 1, false)
  asm = _emit8(asm, opcode)
  asm = _emit_modrm(asm, 3, subop, rd & 7)
  asm = _emit(asm, imm_bytes)
  return asm
end function

/// Updates add r64 imm.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function add_r64_imm(asm, reg_name, imm) return _grp1_imm(asm, 64, 0, reg_name, imm) end function
/// Encode or manage sub r64 imm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function sub_r64_imm(asm, reg_name, imm) return _grp1_imm(asm, 64, 5, reg_name, imm) end function
/// Encode or manage and r64 imm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function and_r64_imm(asm, reg_name, imm) return _grp1_imm(asm, 64, 4, reg_name, imm) end function
/// Encode or manage or r64 imm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function or_r64_imm(asm, reg_name, imm) return _grp1_imm(asm, 64, 1, reg_name, imm) end function
/// Encode or manage xor r64 imm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function xor_r64_imm(asm, reg_name, imm) return _grp1_imm(asm, 64, 6, reg_name, imm) end function
/// Encode or manage cmp r64 imm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function cmp_r64_imm(asm, reg_name, imm)
  if imm == 0 then
    return test_r64_r64(asm, reg_name, reg_name)
  end if
  return _grp1_imm(asm, 64, 7, reg_name, imm)
end function

/// Updates add r64 imm8.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function add_r64_imm8(asm, reg_name, imm)
  // Be permissive here: large selfhosted builds occasionally route wider
  // immediates through the compact helper path. Fall back to the generic
  // encoder instead of poisoning the asm builder with an error object.
  return add_r64_imm(asm, reg_name, imm)
end function
/// Encode or manage sub r64 imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function sub_r64_imm8(asm, reg_name, imm)
  return sub_r64_imm(asm, reg_name, imm)
end function
/// Encode or manage and r64 imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
/// @returns The resulting `struct` value.
function and_r64_imm8(asm as struct, reg_name as string, imm as int) returns struct
  return and_r64_imm(asm, reg_name, imm)
end function
/// Encode or manage or r64 imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
/// @returns The resulting `struct` value.
function or_r64_imm8(asm as struct, reg_name as string, imm as int) returns struct
  return or_r64_imm(asm, reg_name, imm)
end function
/// Encode or manage xor r64 imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function xor_r64_imm8(asm, reg_name, imm)
  return xor_r64_imm(asm, reg_name, imm)
end function
/// Encode or manage cmp r64 imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
/// @returns The resulting `struct` value.
function cmp_r64_imm8(asm as struct, reg_name as string, imm as int) returns struct
  return cmp_r64_imm(asm, reg_name, imm)
end function

/// Updates add r32 imm.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function add_r32_imm(asm, reg_name, imm) return _grp1_imm(asm, 32, 0, reg_name, imm) end function
/// Encode or manage sub r32 imm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function sub_r32_imm(asm, reg_name, imm) return _grp1_imm(asm, 32, 5, reg_name, imm) end function
/// Encode or manage and r32 imm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function and_r32_imm(asm, reg_name, imm) return _grp1_imm(asm, 32, 4, reg_name, imm) end function
/// Encode or manage or r32 imm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function or_r32_imm(asm, reg_name, imm) return _grp1_imm(asm, 32, 1, reg_name, imm) end function
/// Encode or manage xor r32 imm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function xor_r32_imm(asm, reg_name, imm) return _grp1_imm(asm, 32, 6, reg_name, imm) end function
/// Encode or manage cmp r32 imm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function cmp_r32_imm(asm, reg_name, imm)
  if imm == 0 then
    return test_r32_r32(asm, reg_name, reg_name)
  end if
  return _grp1_imm(asm, 32, 7, reg_name, imm)
end function
/// Encode or manage cmp r32 imm32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function cmp_r32_imm32(asm, reg_name, imm) return cmp_r32_imm(asm, reg_name, imm) end function
/// Encode or manage cmp r64 imm32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function cmp_r64_imm32(asm, reg_name, imm) return cmp_r64_imm(asm, reg_name, imm) end function

/// Encode or manage emit bin rr in the native x64 assembler.
/// @internal
function _emit_bin_rr(asm, op, dst, src, w)
  rd = _rid_any(dst)
  rs = _rid_any(src)
  if rd < 0 or rs < 0 then return asm end if
  asm = _emit_rex(asm, w, (rd >> 3) & 1, 0, (rs >> 3) & 1, false)
  asm = _emit8(asm, op)
  asm = _emit_modrm(asm, 3, rd & 7, rs & 7)
  return asm
end function

/// Updates add r64 r64.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function add_r64_r64(asm, dst, src) return _emit_bin_rr(asm, 0x03, dst, src, 1) end function
/// Encode or manage sub r64 r64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function sub_r64_r64(asm, dst, src) return _emit_bin_rr(asm, 0x2B, dst, src, 1) end function
/// Updates add r32 r32.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function add_r32_r32(asm, dst, src) return _emit_bin_rr(asm, 0x03, dst, src, 0) end function
/// Encode or manage sub r32 r32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function sub_r32_r32(asm, dst, src) return _emit_bin_rr(asm, 0x2B, dst, src, 0) end function
/// Encode or manage xor r64 r64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function xor_r64_r64(asm, dst, src) return _emit_bin_rr(asm, 0x33, dst, src, 1) end function
/// Encode or manage xor r32 r32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function xor_r32_r32(asm, dst, src) return _emit_bin_rr(asm, 0x33, dst, src, 0) end function
/// Encode or manage and r64 r64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function and_r64_r64(asm, dst, src) return _emit_bin_rr(asm, 0x23, dst, src, 1) end function
/// Encode or manage and r32 r32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function and_r32_r32(asm, dst, src) return _emit_bin_rr(asm, 0x23, dst, src, 0) end function
/// Encode or manage or r64 r64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function or_r64_r64(asm, dst, src) return _emit_bin_rr(asm, 0x0B, dst, src, 1) end function
/// Encode or manage or r32 r32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function or_r32_r32(asm, dst, src) return _emit_bin_rr(asm, 0x0B, dst, src, 0) end function
/// Encode or manage and r8 r8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function and_r8_r8(asm, dst, src) return _emit_bin_rr(asm, 0x22, dst, src, 0) end function
/// Encode or manage or r8 r8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function or_r8_r8(asm, dst, src) return _emit_bin_rr(asm, 0x0A, dst, src, 0) end function

/// Encode or manage cmp r64 r64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param left Left input value.
/// @param right Right input value.
function cmp_r64_r64(asm, left, right) return _emit_bin_rr(asm, 0x3B, left, right, 1) end function
/// Encode or manage cmp r32 r32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param left Left input value.
/// @param right Right input value.
function cmp_r32_r32(asm, left, right) return _emit_bin_rr(asm, 0x3B, left, right, 0) end function
/// Encode or manage test r64 r64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param left Left input value.
/// @param right Right input value.
function test_r64_r64(asm, left, right) return _emit_bin_rr(asm, 0x85, left, right, 1) end function
/// Encode or manage test r32 r32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param left Left input value.
/// @param right Right input value.
function test_r32_r32(asm, left, right) return _emit_bin_rr(asm, 0x85, left, right, 0) end function

/// Encode or manage test r8 r8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param left Left input value.
/// @param right Right input value.
function test_r8_r8(asm, left, right)
  if _is_r8_name(left) == false or _is_r8_name(right) == false then return error(1, "test_r8_r8 requires 8-bit regs") end if
  aa = _rid_any(left)
  bb = _rid_any(right)
  force = _is_force_rex_8(left) or _is_force_rex_8(right)
  asm = _emit_rex(asm, 0, (bb >> 3) & 1, 0, (aa >> 3) & 1, force)
  asm = _emit8(asm, 0x84)
  asm = _emit_modrm(asm, 3, bb & 7, aa & 7)
  return asm
end function

/// Updates setcc r8.
/// @param asm Value supplied for `asm`.
/// @param cc Value supplied for `cc`.
/// @param dst8 Value supplied for `dst8`.
function setcc_r8(asm, cc, dst8)
  op = -1
  if cc == "e" or cc == "z" then op = 0x94 end if
  if cc == "ne" or cc == "nz" then op = 0x95 end if
  if cc == "l" then op = 0x9C end if
  if cc == "le" then op = 0x9E end if
  if cc == "g" then op = 0x9F end if
  if cc == "ge" then op = 0x9D end if
  if cc == "b" then op = 0x92 end if
  if cc == "be" then op = 0x96 end if
  if cc == "a" then op = 0x97 end if
  if cc == "ae" then op = 0x93 end if
  if cc == "s" then op = 0x98 end if
  if cc == "ns" then op = 0x99 end if
  if cc == "p" then op = 0x9A end if
  if cc == "np" then op = 0x9B end if
  if cc == "o" then op = 0x90 end if
  if cc == "no" then op = 0x91 end if
  if op < 0 then return error(1, "Unknown setcc: " + cc) end if
  if _is_r8_name(dst8) == false then return error(1, "setcc_r8 requires an 8-bit register") end if
  rd = _rid_any(dst8)
  force = _is_force_rex_8(dst8)
  asm = _emit_rex(asm, 0, 0, 0, (rd >> 3) & 1, force)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, op)
  asm = _emit_modrm(asm, 3, 0, rd & 7)
  return asm
end function

/// Updates setcc al.
/// @param asm Value supplied for `asm`.
/// @param cc Value supplied for `cc`.
/// @returns The resulting `struct` value.
function setcc_al(asm as struct, cc as string) returns struct
  return setcc_r8(asm, cc, "al")
end function

/// Encode or manage movzx r32 r8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src8 Value supplied for `src8`.
function movzx_r32_r8(asm, dst, src8)
  if _is_r32_name(dst) == false or _is_r8_name(src8) == false then return error(1, "movzx_r32_r8 requires (r32, r8)") end if
  rd = _rid_any(dst)
  rs = _rid_any(src8)
  force = _is_force_rex_8(src8)
  asm = _emit_rex(asm, 0, (rd >> 3) & 1, 0, (rs >> 3) & 1, force)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0xB6)
  asm = _emit_modrm(asm, 3, rd & 7, rs & 7)
  return asm
end function

/// Encode or manage movzx eax al in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @returns The resulting `struct` value.
function movzx_eax_al(asm as struct) returns struct
  return movzx_r32_r8(asm, "eax", "al")
end function

/// Encode or manage mov rbx rax in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function mov_rbx_rax(asm) return mov_r64_r64(asm, "rbx", "rax") end function
/// Encode or manage mov rcx rbx in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function mov_rcx_rbx(asm) return mov_r64_r64(asm, "rcx", "rbx") end function
/// Encode or manage mov rdx rax in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function mov_rdx_rax(asm) return mov_r64_r64(asm, "rdx", "rax") end function
/// Encode or manage mov r10 rax in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function mov_r10_rax(asm) return mov_r64_r64(asm, "r10", "rax") end function
/// Encode or manage mov r11 rax in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function mov_r11_rax(asm) return mov_r64_r64(asm, "r11", "rax") end function
/// Encode or manage mov rax r10 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function mov_rax_r10(asm) return mov_r64_r64(asm, "rax", "r10") end function
/// Encode or manage mov rax r11 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function mov_rax_r11(asm) return mov_r64_r64(asm, "rax", "r11") end function

/// Updates add rax r10.
/// @param asm Value supplied for `asm`.
function add_rax_r10(asm) return add_r64_r64(asm, "rax", "r10") end function
/// Encode or manage sub rax r11 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function sub_rax_r11(asm) return sub_r64_r64(asm, "rax", "r11") end function
/// Updates add rax imm8.
/// @param asm Value supplied for `asm`.
/// @param imm Value supplied for `imm`.
function add_rax_imm8(asm, imm) return add_r64_imm8(asm, "rax", imm) end function
/// Encode or manage sub rax imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param imm Value supplied for `imm`.
function sub_rax_imm8(asm, imm) return sub_r64_imm8(asm, "rax", imm) end function
/// Encode or manage and rax imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param imm Value supplied for `imm`.
function and_rax_imm8(asm, imm) return and_r64_imm8(asm, "rax", imm) end function
/// Encode or manage or rax imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param imm Value supplied for `imm`.
function or_rax_imm8(asm, imm) return or_r64_imm8(asm, "rax", imm) end function

/// Encode or manage emit shift imm8 in the native x64 assembler.
/// @internal
function _emit_shift_imm8(asm, subop, reg_name, imm, w)
  rd = _rid_any(reg_name)
  if rd < 0 then return asm end if
  asm = _emit_rex(asm, w, 0, 0, (rd >> 3) & 1, false)
  asm = _emit8(asm, 0xC1)
  asm = _emit_modrm(asm, 3, subop, rd & 7)
  asm = _emit8(asm, imm)
  return asm
end function

/// Encode or manage shl r64 imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function shl_r64_imm8(asm, reg_name, imm) return _emit_shift_imm8(asm, 4, reg_name, imm, 1) end function
/// Encode or manage shr r64 imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function shr_r64_imm8(asm, reg_name, imm) return _emit_shift_imm8(asm, 5, reg_name, imm, 1) end function
/// Encode or manage sar r64 imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function sar_r64_imm8(asm, reg_name, imm) return _emit_shift_imm8(asm, 7, reg_name, imm, 1) end function
/// Encode or manage shl r32 imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function shl_r32_imm8(asm, reg_name, imm) return _emit_shift_imm8(asm, 4, reg_name, imm, 0) end function
/// Encode or manage sar r32 imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function sar_r32_imm8(asm, reg_name, imm) return _emit_shift_imm8(asm, 7, reg_name, imm, 0) end function
/// Encode or manage shr r32 imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function shr_r32_imm8(asm, reg_name, imm) return _emit_shift_imm8(asm, 5, reg_name, imm, 0) end function

/// Encode or manage sar rax imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param imm Value supplied for `imm`.
function sar_rax_imm8(asm, imm) return sar_r64_imm8(asm, "rax", imm) end function
/// Encode or manage shl rax imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param imm Value supplied for `imm`.
function shl_rax_imm8(asm, imm) return shl_r64_imm8(asm, "rax", imm) end function

/// Encode or manage neg r64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
function neg_r64(asm, reg_name)
  rd = _rid_any(reg_name)
  if rd < 0 then return asm end if
  asm = _emit_rex(asm, 1, 0, 0, (rd >> 3) & 1, false)
  asm = _emit8(asm, 0xF7)
  asm = _emit_modrm(asm, 3, 3, rd & 7)
  return asm
end function

/// Encode or manage neg rax in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function neg_rax(asm)
  return neg_r64(asm, "rax")
end function

/// Encode or manage cmp rax r10 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function cmp_rax_r10(asm)
  return cmp_r64_r64(asm, "rax", "r10")
end function

/// Encode or manage cmp rax imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param imm Value supplied for `imm`.
/// @returns The resulting `struct` value.
function cmp_rax_imm8(asm as struct, imm as int) returns struct
  return cmp_r64_imm8(asm, "rax", imm)
end function

/// Encode or manage cmp rax imm32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param imm Value supplied for `imm`.
function cmp_rax_imm32(asm, imm)
  return cmp_r64_imm(asm, "rax", imm)
end function

/// Encode or manage test rax imm32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param imm Value supplied for `imm`.
function test_rax_imm32(asm, imm)
  rd = _rid_any("rax")
  asm = _emit_rex(asm, 1, 0, 0, (rd >> 3) & 1, false)
  asm = _emit8(asm, 0xF7)
  asm = _emit_modrm(asm, 3, 0, rd & 7)
  asm = _emit32(asm, imm)
  return asm
end function

/// Encode or manage xor ecx ecx in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function xor_ecx_ecx(asm)
  return xor_r32_r32(asm, "ecx", "ecx")
end function

/// Encode or manage xor eax eax in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function xor_eax_eax(asm)
  return xor_r32_r32(asm, "eax", "eax")
end function

/// Updates add rcx imm8.
/// @param asm Value supplied for `asm`.
/// @param imm Value supplied for `imm`.
function add_rcx_imm8(asm, imm)
  return add_r64_imm8(asm, "rcx", imm)
end function

/// Updates add rcx imm32.
/// @param asm Value supplied for `asm`.
/// @param imm Value supplied for `imm`.
function add_rcx_imm32(asm, imm)
  return add_r64_imm(asm, "rcx", imm)
end function

/// Encode or manage sub rsp imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param imm Value supplied for `imm`.
function sub_rsp_imm8(asm, imm)
  if imm == 0 then return asm end if
  return sub_r64_imm(asm, "rsp", imm)
end function

/// Updates add rsp imm8.
/// @param asm Value supplied for `asm`.
/// @param imm Value supplied for `imm`.
function add_rsp_imm8(asm, imm)
  if imm == 0 then return asm end if
  return add_r64_imm(asm, "rsp", imm)
end function

/// Encode or manage sub rsp imm32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param imm Value supplied for `imm`.
function sub_rsp_imm32(asm, imm)
  return sub_rsp_imm8(asm, imm)
end function

/// Updates add rsp imm32.
/// @param asm Value supplied for `asm`.
/// @param imm Value supplied for `imm`.
function add_rsp_imm32(asm, imm)
  return add_rsp_imm8(asm, imm)
end function

/// Encode or manage mov r64 membase disp in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
function mov_r64_membase_disp(asm, dst, base, disp)
  d = _rid_any(dst)
  b = _rid_any(base)
  if d < 0 or b < 0 then return asm end if
  enc = _encode_mem(d & 7, b, disp)
  rex_r = 0
  if d >= 8 then rex_r = 1 end if
  asm = _emit_rex(asm, 1, rex_r, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0x8B)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage mov membase disp r64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
/// @param src Value supplied for `src`.
function mov_membase_disp_r64(asm, base, disp, src)
  sreg = _rid_any(src)
  b = _rid_any(base)
  if sreg < 0 or b < 0 then return asm end if
  enc = _encode_mem(sreg & 7, b, disp)
  rex_r = 0
  if sreg >= 8 then rex_r = 1 end if
  asm = _emit_rex(asm, 1, rex_r, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0x89)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage mov r32 membase disp in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
function mov_r32_membase_disp(asm, dst, base, disp)
  d = _rid_any(dst)
  b = _rid_any(base)
  if d < 0 or b < 0 then return asm end if
  enc = _encode_mem(d & 7, b, disp)
  rex_r = 0
  if d >= 8 then rex_r = 1 end if
  asm = _emit_rex(asm, 0, rex_r, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0x8B)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage mov membase disp r32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
/// @param src Value supplied for `src`.
function mov_membase_disp_r32(asm, base, disp, src)
  sreg = _rid_any(src)
  b = _rid_any(base)
  if sreg < 0 or b < 0 then return asm end if
  enc = _encode_mem(sreg & 7, b, disp)
  rex_r = 0
  if sreg >= 8 then rex_r = 1 end if
  asm = _emit_rex(asm, 0, rex_r, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0x89)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage lock cmpxchg membase disp r32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
/// @param src Value supplied for `src`.
function lock_cmpxchg_membase_disp_r32(asm, base, disp, src)
  sreg = _rid_any(src)
  b = _rid_any(base)
  if sreg < 0 or b < 0 then return asm end if
  enc = _encode_mem(sreg & 7, b, disp)
  rex_r = 0
  if sreg >= 8 then rex_r = 1 end if
  asm = _emit8(asm, 0xF0)
  asm = _emit_rex(asm, 0, rex_r, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0xB1)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage lock cmpxchg membase disp r64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
/// @param src Value supplied for `src`.
function lock_cmpxchg_membase_disp_r64(asm, base, disp, src)
  // CMPXCHG implicitly compares RAX with the qword destination and returns the
  // observed destination in RAX when the exchange does not occur.
  sreg = _rid_any(src)
  b = _rid_any(base)
  if sreg < 0 or b < 0 then return asm end if
  enc = _encode_mem(sreg & 7, b, disp)
  rex_r = 0
  if sreg >= 8 then rex_r = 1 end if
  asm = _emit8(asm, 0xF0)
  asm = _emit_rex(asm, 1, rex_r, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0xB1)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage mov r8 membase disp in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
function mov_r8_membase_disp(asm, dst, base, disp)
  if _is_r8_name(dst) == false then return error(1, "mov_r8_membase_disp requires an 8-bit dst register") end if
  d = _rid_any(dst)
  b = _rid_any(base)
  if d < 0 or b < 0 then return asm end if
  force = _is_force_rex_8(dst)
  enc = _encode_mem(d & 7, b, disp)
  rex_r = 0
  if d >= 8 then rex_r = 1 end if
  asm = _emit_rex(asm, 0, rex_r, enc.rex_x, enc.rex_b, force)
  asm = _emit8(asm, 0x8A)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage mov membase disp r8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
/// @param src Value supplied for `src`.
function mov_membase_disp_r8(asm, base, disp, src)
  if _is_r8_name(src) == false then return error(1, "mov_membase_disp_r8 requires an 8-bit src register") end if
  sreg = _rid_any(src)
  b = _rid_any(base)
  if sreg < 0 or b < 0 then return asm end if
  force = _is_force_rex_8(src)
  enc = _encode_mem(sreg & 7, b, disp)
  rex_r = 0
  if sreg >= 8 then rex_r = 1 end if
  asm = _emit_rex(asm, 0, rex_r, enc.rex_x, enc.rex_b, force)
  asm = _emit8(asm, 0x88)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage mov membase disp imm32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
/// @param imm Value supplied for `imm`.
/// @param qword Value supplied for `qword`.
function mov_membase_disp_imm32(asm, base, disp, imm, qword)
  b = _rid_any(base)
  if b < 0 then return asm end if
  enc = _encode_mem(0, b, disp)
  w = 0
  if qword then w = 1 end if
  asm = _emit_rex(asm, w, 0, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0xC7)
  asm = _emit(asm, enc.tail)
  asm = _emit32(asm, imm)
  return asm
end function

/// Encode or manage mov membase disp imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
/// @param imm Value supplied for `imm`.
function mov_membase_disp_imm8(asm, base, disp, imm)
  b = _rid_any(base)
  if b < 0 then return asm end if
  enc = _encode_mem(0, b, disp)
  asm = _emit_rex(asm, 0, 0, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0xC6)
  asm = _emit(asm, enc.tail)
  asm = _emit8(asm, imm)
  return asm
end function

/// Encode or manage lea r64 membase disp in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
function lea_r64_membase_disp(asm, dst, base, disp)
  d = _rid_any(dst)
  b = _rid_any(base)
  if d < 0 or b < 0 then return asm end if
  enc = _encode_mem(d & 7, b, disp)
  rex_r = 0
  if d >= 8 then rex_r = 1 end if
  asm = _emit_rex(asm, 1, rex_r, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0x8D)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage mov rax rsp disp8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param disp Value supplied for `disp`.
function mov_rax_rsp_disp8(asm, disp)
  return mov_r64_membase_disp(asm, "rax", "rsp", disp)
end function

/// Encode or manage mov rsp disp8 rax in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param disp Value supplied for `disp`.
function mov_rsp_disp8_rax(asm, disp)
  return mov_membase_disp_r64(asm, "rsp", disp, "rax")
end function

/// Encode or manage mov rax rsp disp32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param disp Value supplied for `disp`.
/// @returns The resulting `struct` value.
function mov_rax_rsp_disp32(asm as struct, disp as int) returns struct
  return mov_r64_membase_disp(asm, "rax", "rsp", disp)
end function

/// Encode or manage mov rsp disp32 rax in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param disp Value supplied for `disp`.
/// @returns The resulting `struct` value.
function mov_rsp_disp32_rax(asm as struct, disp as int) returns struct
  return mov_membase_disp_r64(asm, "rsp", disp, "rax")
end function

/// Encode or manage grp1 r8 imm8 in the native x64 assembler.
/// @internal
function _grp1_r8_imm8(asm, subop, reg8, imm)
  r = _rid_any(reg8)
  if r < 0 then return asm end if
  force = _is_force_rex_8(reg8)
  asm = _emit_rex(asm, 0, 0, 0, (r >> 3) & 1, force)
  asm = _emit8(asm, 0x80)
  asm = _emit_modrm(asm, 3, subop, r & 7)
  asm = _emit8(asm, imm)
  return asm
end function

/// Encode or manage and r8 imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg8 Value supplied for `reg8`.
/// @param imm Value supplied for `imm`.
function and_r8_imm8(asm, reg8, imm) return _grp1_r8_imm8(asm, 4, reg8, imm) end function
/// Encode or manage or r8 imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg8 Value supplied for `reg8`.
/// @param imm Value supplied for `imm`.
function or_r8_imm8(asm, reg8, imm) return _grp1_r8_imm8(asm, 1, reg8, imm) end function
/// Encode or manage xor r8 imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg8 Value supplied for `reg8`.
/// @param imm Value supplied for `imm`.
function xor_r8_imm8(asm, reg8, imm) return _grp1_r8_imm8(asm, 6, reg8, imm) end function
/// Updates add r8 imm8.
/// @param asm Value supplied for `asm`.
/// @param reg8 Value supplied for `reg8`.
/// @param imm Value supplied for `imm`.
function add_r8_imm8(asm, reg8, imm) return _grp1_r8_imm8(asm, 0, reg8, imm) end function
/// Encode or manage sub r8 imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg8 Value supplied for `reg8`.
/// @param imm Value supplied for `imm`.
function sub_r8_imm8(asm, reg8, imm) return _grp1_r8_imm8(asm, 5, reg8, imm) end function

/// Encode or manage cmp r8 imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg8 Value supplied for `reg8`.
/// @param imm Value supplied for `imm`.
function cmp_r8_imm8(asm, reg8, imm)
  if imm == 0 then
    return test_r8_r8(asm, reg8, reg8)
  end if
  return _grp1_r8_imm8(asm, 7, reg8, imm)
end function

/// Encode or manage test r64 imm32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
/// @param imm Value supplied for `imm`.
function test_r64_imm32(asm, reg_name, imm)
  r = _rid_any(reg_name)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 1, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xF7)
  asm = _emit_modrm(asm, 3, 0, r & 7)
  asm = _emit32(asm, imm)
  return asm
end function

/// Encode or manage cmp r8 membase disp in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg8 Value supplied for `reg8`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
function cmp_r8_membase_disp(asm, reg8, base, disp)
  if _is_r8_name(reg8) == false then return error(1, "cmp_r8_membase_disp requires an 8-bit reg") end if
  r = _rid_any(reg8)
  b = _rid_any(base)
  if r < 0 or b < 0 then return asm end if
  force = _is_force_rex_8(reg8)
  enc = _encode_mem(r & 7, b, disp)
  rex_r = 0
  if r >= 8 then rex_r = 1 end if
  asm = _emit_rex(asm, 0, rex_r, enc.rex_x, enc.rex_b, force)
  asm = _emit8(asm, 0x3A)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage cmp membase disp imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
/// @param imm Value supplied for `imm`.
function cmp_membase_disp_imm8(asm, base, disp, imm)
  b = _rid_any(base)
  if b < 0 then return asm end if
  enc = _encode_mem(7, b, disp)
  asm = _emit_rex(asm, 0, 0, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0x80)
  asm = _emit(asm, enc.tail)
  asm = _emit8(asm, imm)
  return asm
end function

/// Encode or manage movzx r32 membase disp in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst32 Value supplied for `dst32`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
function movzx_r32_membase_disp(asm, dst32, base, disp)
  if _is_r32_name(dst32) == false then return error(1, "movzx_r32_membase_disp requires 32-bit dst") end if
  d = _rid_any(dst32)
  b = _rid_any(base)
  if d < 0 or b < 0 then return asm end if
  enc = _encode_mem(d & 7, b, disp)
  rex_r = 0
  if d >= 8 then rex_r = 1 end if
  asm = _emit_rex(asm, 0, rex_r, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0xB6)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage bsf r32 r32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst32 Value supplied for `dst32`.
/// @param src32 Value supplied for `src32`.
function bsf_r32_r32(asm, dst32, src32)
  if _is_r32_name(dst32) == false or _is_r32_name(src32) == false then return error(1, "bsf_r32_r32 requires (r32, r32)") end if
  d = _rid_any(dst32)
  s = _rid_any(src32)
  rex_r = 0
  if d >= 8 then rex_r = 1 end if
  rex_b = 0
  if s >= 8 then rex_b = 1 end if
  asm = _emit_rex(asm, 0, rex_r, 0, rex_b, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0xBC)
  asm = _emit_modrm(asm, 3, d & 7, s & 7)
  return asm
end function

/// Encode or manage bsr r32 r32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst32 Value supplied for `dst32`.
/// @param src32 Value supplied for `src32`.
function bsr_r32_r32(asm, dst32, src32)
  if _is_r32_name(dst32) == false or _is_r32_name(src32) == false then return error(1, "bsr_r32_r32 requires (r32, r32)") end if
  d = _rid_any(dst32)
  s = _rid_any(src32)
  rex_r = 0
  if d >= 8 then rex_r = 1 end if
  rex_b = 0
  if s >= 8 then rex_b = 1 end if
  asm = _emit_rex(asm, 0, rex_r, 0, rex_b, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0xBD)
  asm = _emit_modrm(asm, 3, d & 7, s & 7)
  return asm
end function

/// Emit SSE4.2 CRC32 r64, qword [base+disp]. Callers must dispatch on CPUID.SSE4.2; this instruction implements CRC-32C, not CRC-32/IEEE.
/// @param asm Value supplied for `asm`.
/// @param dst64 Value supplied for `dst64`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
function crc32_r64_membase_disp(asm, dst64, base, disp)
  d = _rid_any(dst64)
  b = _rid_any(base)
  if d < 0 or b < 0 then return asm end if
  enc = _encode_mem(d & 7, b, disp)
  asm = _emit8(asm, 0xF2)
  asm = _emit_rex(asm, 1, (d >> 3) & 1, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0x38)
  asm = _emit8(asm, 0xF1)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage crc32 r32 membase disp8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst32 Value supplied for `dst32`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
function crc32_r32_membase_disp8(asm, dst32, base, disp)
  if _is_r32_name(dst32) == false then return error(1, "crc32_r32_membase_disp8 requires a 32-bit destination") end if
  d = _rid_any(dst32)
  b = _rid_any(base)
  if d < 0 or b < 0 then return asm end if
  enc = _encode_mem(d & 7, b, disp)
  asm = _emit8(asm, 0xF2)
  asm = _emit_rex(asm, 0, (d >> 3) & 1, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0x38)
  asm = _emit8(asm, 0xF0)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage inc r64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
function inc_r64(asm, reg_name)
  r = _rid_any(reg_name)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 1, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xFF)
  asm = _emit_modrm(asm, 3, 0, r & 7)
  return asm
end function

/// Encode or manage dec r64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
function dec_r64(asm, reg_name)
  r = _rid_any(reg_name)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 1, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xFF)
  asm = _emit_modrm(asm, 3, 1, r & 7)
  return asm
end function

/// Encode or manage inc r32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
function inc_r32(asm, reg_name)
  r = _rid_any(reg_name)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 0, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xFF)
  asm = _emit_modrm(asm, 3, 0, r & 7)
  return asm
end function

/// Encode or manage dec r32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
function dec_r32(asm, reg_name)
  r = _rid_any(reg_name)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 0, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xFF)
  asm = _emit_modrm(asm, 3, 1, r & 7)
  return asm
end function

/// Encode or manage inc membase disp qword in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
function inc_membase_disp_qword(asm, base, disp)
  b = _rid_any(base)
  if b < 0 then return asm end if
  enc = _encode_mem(0, b, disp)
  asm = _emit_rex(asm, 1, 0, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0xFF)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage dec membase disp qword in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
function dec_membase_disp_qword(asm, base, disp)
  b = _rid_any(base)
  if b < 0 then return asm end if
  enc = _encode_mem(1, b, disp)
  asm = _emit_rex(asm, 1, 0, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0xFF)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage mov r9d imm32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param imm Value supplied for `imm`.
function mov_r9d_imm32(asm, imm)
  return mov_r32_imm32(asm, "r9d", imm)
end function

/// Encode or manage mov r8d edx in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function mov_r8d_edx(asm)
  return mov_r32_r32(asm, "r8d", "edx")
end function

/// Encode or manage mov qword ptr rsp20 rax zero in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function mov_qword_ptr_rsp20_rax_zero(asm)
  asm = xor_r32_r32(asm, "eax", "eax")
  asm = mov_membase_disp_r64(asm, "rsp", 0x20, "rax")
  return asm
end function

/// Encode or manage mov eax rip dword in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function mov_eax_rip_dword(asm, label)
  asm = _emit8(asm, 0x8B)
  asm = _emit8(asm, 0x05)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rip32"))
  return asm
end function

/// Encode or manage mov rip dword eax in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function mov_rip_dword_eax(asm, label)
  asm = _emit8(asm, 0x89)
  asm = _emit8(asm, 0x05)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rip32"))
  return asm
end function

/// Encode or manage mov rax rip qword in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function mov_rax_rip_qword(asm, label)
  tmp_off = _gc_tmp_context_offset(label)
  if tmp_off >= 0 then
    asm = push_reg(asm, "r10")
    asm = mov_r10_gs_qword_28(asm)
    asm = mov_r64_membase_disp(asm, "rax", "r10", tmp_off)
    asm = pop_reg(asm, "r10")
    return asm
  end if
  asm = _emit_rex(asm, 1, 0, 0, 0, false)
  asm = _emit8(asm, 0x8B)
  asm = _emit8(asm, 0x05)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rip32"))
  return asm
end function

/// Encode or manage mov rdx rip qword in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function mov_rdx_rip_qword(asm, label)
  tmp_off = _gc_tmp_context_offset(label)
  if tmp_off >= 0 then
    asm = push_reg(asm, "r10")
    asm = mov_r10_gs_qword_28(asm)
    asm = mov_r64_membase_disp(asm, "rdx", "r10", tmp_off)
    asm = pop_reg(asm, "r10")
    return asm
  end if
  asm = _emit_rex(asm, 1, 0, 0, 0, false)
  asm = _emit8(asm, 0x8B)
  asm = _emit8(asm, 0x15)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rip32"))
  return asm
end function

/// Encode or manage mov rip qword rax in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function mov_rip_qword_rax(asm, label)
  tmp_off = _gc_tmp_context_offset(label)
  if tmp_off >= 0 then
    asm = push_reg(asm, "r10")
    asm = mov_r10_gs_qword_28(asm)
    asm = mov_membase_disp_r64(asm, "r10", tmp_off, "rax")
    asm = pop_reg(asm, "r10")
    return asm
  end if
  asm = _emit_rex(asm, 1, 0, 0, 0, false)
  asm = _emit8(asm, 0x89)
  asm = _emit8(asm, 0x05)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rip32"))
  return asm
end function

/// Encode or manage mov rip qword rdx in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function mov_rip_qword_rdx(asm, label)
  tmp_off = _gc_tmp_context_offset(label)
  if tmp_off >= 0 then
    asm = push_reg(asm, "r10")
    asm = mov_r10_gs_qword_28(asm)
    asm = mov_membase_disp_r64(asm, "r10", tmp_off, "rdx")
    asm = pop_reg(asm, "r10")
    return asm
  end if
  asm = _emit_rex(asm, 1, 0, 0, 0, false)
  asm = _emit8(asm, 0x89)
  asm = _emit8(asm, 0x15)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rip32"))
  return asm
end function

/// Encode or manage mov rip qword r11 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function mov_rip_qword_r11(asm, label)
  tmp_off = _gc_tmp_context_offset(label)
  if tmp_off >= 0 then
    asm = push_reg(asm, "r10")
    asm = mov_r10_gs_qword_28(asm)
    asm = mov_membase_disp_r64(asm, "r10", tmp_off, "r11")
    asm = pop_reg(asm, "r10")
    return asm
  end if
  asm = _emit_rex(asm, 1, 1, 0, 0, false)
  asm = _emit8(asm, 0x89)
  asm = _emit8(asm, 0x1D)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rip32"))
  return asm
end function

/// Encode or manage mov rip qword r8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function mov_rip_qword_r8(asm, label)
  tmp_off = _gc_tmp_context_offset(label)
  if tmp_off >= 0 then
    asm = push_reg(asm, "r10")
    asm = mov_r10_gs_qword_28(asm)
    asm = mov_membase_disp_r64(asm, "r10", tmp_off, "r8")
    asm = pop_reg(asm, "r10")
    return asm
  end if
  asm = _emit_rex(asm, 1, 1, 0, 0, false)
  asm = _emit8(asm, 0x89)
  asm = _emit8(asm, 0x05)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rip32"))
  return asm
end function

/// Encode or manage mov rip qword r9 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param label Value supplied for `label`.
function mov_rip_qword_r9(asm, label)
  tmp_off = _gc_tmp_context_offset(label)
  if tmp_off >= 0 then
    asm = push_reg(asm, "r10")
    asm = mov_r10_gs_qword_28(asm)
    asm = mov_membase_disp_r64(asm, "r10", tmp_off, "r9")
    asm = pop_reg(asm, "r10")
    return asm
  end if
  asm = _emit_rex(asm, 1, 1, 0, 0, false)
  asm = _emit8(asm, 0x89)
  asm = _emit8(asm, 0x0D)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rip32"))
  return asm
end function

/// Encode or manage mov r64 mem bis in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param base Value supplied for `base`.
/// @param index_reg Value supplied for `index_reg`.
/// @param scale Value supplied for `scale`.
/// @param disp Value supplied for `disp`.
function mov_r64_mem_bis(asm, dst, base, index_reg, scale, disp)
  d = _rid_any(dst)
  b = _rid_any(base)
  idx = _rid_any(index_reg)
  if d < 0 or b < 0 or idx < 0 then return asm end if
  enc = _encode_mem_bis(d & 7, b, idx, scale, disp)
  rex_r = 0
  if d >= 8 then rex_r = 1 end if
  asm = _emit_rex(asm, 1, rex_r, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0x8B)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage mov mem bis r64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param base Value supplied for `base`.
/// @param index_reg Value supplied for `index_reg`.
/// @param scale Value supplied for `scale`.
/// @param disp Value supplied for `disp`.
/// @param src Value supplied for `src`.
function mov_mem_bis_r64(asm, base, index_reg, scale, disp, src)
  sreg = _rid_any(src)
  b = _rid_any(base)
  idx = _rid_any(index_reg)
  if sreg < 0 or b < 0 or idx < 0 then return asm end if
  enc = _encode_mem_bis(sreg & 7, b, idx, scale, disp)
  rex_r = 0
  if sreg >= 8 then rex_r = 1 end if
  asm = _emit_rex(asm, 1, rex_r, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0x89)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage mov r32 mem bis in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param base Value supplied for `base`.
/// @param index_reg Value supplied for `index_reg`.
/// @param scale Value supplied for `scale`.
/// @param disp Value supplied for `disp`.
function mov_r32_mem_bis(asm, dst, base, index_reg, scale, disp)
  d = _rid_any(dst)
  b = _rid_any(base)
  idx = _rid_any(index_reg)
  if d < 0 or b < 0 or idx < 0 then return asm end if
  enc = _encode_mem_bis(d & 7, b, idx, scale, disp)
  rex_r = 0
  if d >= 8 then rex_r = 1 end if
  asm = _emit_rex(asm, 0, rex_r, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0x8B)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage mov mem bis r32 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param base Value supplied for `base`.
/// @param index_reg Value supplied for `index_reg`.
/// @param scale Value supplied for `scale`.
/// @param disp Value supplied for `disp`.
/// @param src Value supplied for `src`.
function mov_mem_bis_r32(asm, base, index_reg, scale, disp, src)
  sreg = _rid_any(src)
  b = _rid_any(base)
  idx = _rid_any(index_reg)
  if sreg < 0 or b < 0 or idx < 0 then return asm end if
  enc = _encode_mem_bis(sreg & 7, b, idx, scale, disp)
  rex_r = 0
  if sreg >= 8 then rex_r = 1 end if
  asm = _emit_rex(asm, 0, rex_r, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0x89)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage lea r64 mem bis in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param base Value supplied for `base`.
/// @param index_reg Value supplied for `index_reg`.
/// @param scale Value supplied for `scale`.
/// @param disp Value supplied for `disp`.
function lea_r64_mem_bis(asm, dst, base, index_reg, scale, disp)
  d = _rid_any(dst)
  b = _rid_any(base)
  idx = _rid_any(index_reg)
  if d < 0 or b < 0 or idx < 0 then return asm end if
  enc = _encode_mem_bis(d & 7, b, idx, scale, disp)
  rex_r = 0
  if d >= 8 then rex_r = 1 end if
  asm = _emit_rex(asm, 1, rex_r, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0x8D)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage shl r64 cl in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
function shl_r64_cl(asm, reg_name)
  r = _rid_any(reg_name)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 1, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xD3)
  asm = _emit_modrm(asm, 3, 4, r & 7)
  return asm
end function

/// Encode or manage shr r64 cl in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
function shr_r64_cl(asm, reg_name)
  r = _rid_any(reg_name)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 1, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xD3)
  asm = _emit_modrm(asm, 3, 5, r & 7)
  return asm
end function

/// Encode or manage sar r64 cl in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
function sar_r64_cl(asm, reg_name)
  r = _rid_any(reg_name)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 1, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xD3)
  asm = _emit_modrm(asm, 3, 7, r & 7)
  return asm
end function

/// Encode or manage imul r64 r64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function imul_r64_r64(asm, dst, src)
  d = _rid_any(dst)
  sreg = _rid_any(src)
  if d < 0 or sreg < 0 then return asm end if
  asm = _emit_rex(asm, 1, (d >> 3) & 1, 0, (sreg >> 3) & 1, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0xAF)
  asm = _emit_modrm(asm, 3, d & 7, sreg & 7)
  return asm
end function

/// Encode or manage imul r64 r64 imm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
/// @param imm Value supplied for `imm`.
function imul_r64_r64_imm(asm, dst, src, imm)
  d = _rid_any(dst)
  sreg = _rid_any(src)
  if d < 0 or sreg < 0 then return asm end if
  asm = _emit_rex(asm, 1, (d >> 3) & 1, 0, (sreg >> 3) & 1, false)
  if imm >= -128 and imm <= 127 then
    asm = _emit8(asm, 0x6B)
    asm = _emit_modrm(asm, 3, d & 7, sreg & 7)
    asm = _emit8(asm, imm)
    return asm
  end if
  asm = _emit8(asm, 0x69)
  asm = _emit_modrm(asm, 3, d & 7, sreg & 7)
  asm = _emit32(asm, imm)
  return asm
end function

/// Encode or manage cqo in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function cqo(asm)
  asm = _emit_rex(asm, 1, 0, 0, 0, false)
  asm = _emit8(asm, 0x99)
  return asm
end function

/// Encode or manage idiv r64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
function idiv_r64(asm, reg_name)
  r = _rid_any(reg_name)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 1, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xF7)
  asm = _emit_modrm(asm, 3, 7, r & 7)
  return asm
end function

/// Encode or manage div r64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param reg_name Value supplied for `reg_name`.
function div_r64(asm, reg_name)
  r = _rid_any(reg_name)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 1, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xF7)
  asm = _emit_modrm(asm, 3, 6, r & 7)
  return asm
end function

/// Encode or manage rep movsb in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function rep_movsb(asm)
  asm = _emit8(asm, 0xF3)
  asm = _emit8(asm, 0xA4)
  return asm
end function

/// Encode or manage rep movsq in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function rep_movsq(asm)
  asm = _emit8(asm, 0xF3)
  asm = _emit8(asm, 0x48)
  asm = _emit8(asm, 0xA5)
  return asm
end function

/// Encode or manage rep stosb in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function rep_stosb(asm)
  asm = _emit8(asm, 0xF3)
  asm = _emit8(asm, 0xAA)
  return asm
end function

/// Encode or manage rep stosq in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function rep_stosq(asm)
  asm = _emit8(asm, 0xF3)
  asm = _emit8(asm, 0x48)
  asm = _emit8(asm, 0xAB)
  return asm
end function

/// Encode or manage repe cmpsb in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function repe_cmpsb(asm)
  asm = _emit8(asm, 0xF3)
  asm = _emit8(asm, 0xA6)
  return asm
end function

/// Encode or manage cpuid in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function cpuid(asm)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0xA2)
  return asm
end function

/// Encode or manage xgetbv in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function xgetbv(asm)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0x01)
  asm = _emit8(asm, 0xD0)
  return asm
end function

/// Encode or manage emit sse rr in the native x64 assembler.
/// @internal
function _emit_sse_rr(asm, prefix1, prefix2, opcode, dst_xmm, src_xmm)
  d = _xmm_id(dst_xmm)
  sr = _xmm_id(src_xmm)
  if d < 0 or sr < 0 then return asm end if
  if prefix1 >= 0 then asm = _emit8(asm, prefix1) end if
  if prefix2 >= 0 then asm = _emit8(asm, prefix2) end if
  asm = _emit_rex(asm, 0, (d >> 3) & 1, 0, (sr >> 3) & 1, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, opcode)
  asm = _emit_modrm(asm, 3, d & 7, sr & 7)
  return asm
end function

/// Encode or manage movsd xmm xmm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst_xmm Value supplied for `dst_xmm`.
/// @param src_xmm Value supplied for `src_xmm`.
function movsd_xmm_xmm(asm, dst_xmm, src_xmm)
  return _emit_sse_rr(asm, 0xF2, -1, 0x10, dst_xmm, src_xmm)
end function

/// Updates addsd xmm xmm.
/// @param asm Value supplied for `asm`.
/// @param dst_xmm Value supplied for `dst_xmm`.
/// @param src_xmm Value supplied for `src_xmm`.
function addsd_xmm_xmm(asm, dst_xmm, src_xmm)
  return _emit_sse_rr(asm, 0xF2, -1, 0x58, dst_xmm, src_xmm)
end function

/// Encode or manage subsd xmm xmm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst_xmm Value supplied for `dst_xmm`.
/// @param src_xmm Value supplied for `src_xmm`.
function subsd_xmm_xmm(asm, dst_xmm, src_xmm)
  return _emit_sse_rr(asm, 0xF2, -1, 0x5C, dst_xmm, src_xmm)
end function

/// Encode or manage mulsd xmm xmm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst_xmm Value supplied for `dst_xmm`.
/// @param src_xmm Value supplied for `src_xmm`.
function mulsd_xmm_xmm(asm, dst_xmm, src_xmm)
  return _emit_sse_rr(asm, 0xF2, -1, 0x59, dst_xmm, src_xmm)
end function

/// Encode or manage divsd xmm xmm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst_xmm Value supplied for `dst_xmm`.
/// @param src_xmm Value supplied for `src_xmm`.
function divsd_xmm_xmm(asm, dst_xmm, src_xmm)
  return _emit_sse_rr(asm, 0xF2, -1, 0x5E, dst_xmm, src_xmm)
end function

/// Encode or manage ucomisd xmm xmm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param left_xmm Value supplied for `left_xmm`.
/// @param right_xmm Value supplied for `right_xmm`.
/// @returns The resulting `struct` value.
function ucomisd_xmm_xmm(asm as struct, left_xmm as string, right_xmm as string) returns struct
  return _emit_sse_rr(asm, 0x66, -1, 0x2E, left_xmm, right_xmm)
end function

/// Encode or manage xorpd xmm xmm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst_xmm Value supplied for `dst_xmm`.
/// @param src_xmm Value supplied for `src_xmm`.
/// @returns The resulting `struct` value.
function xorpd_xmm_xmm(asm as struct, dst_xmm as string, src_xmm as string) returns struct
  return _emit_sse_rr(asm, 0x66, -1, 0x57, dst_xmm, src_xmm)
end function

/// Encode or manage movapd xmm xmm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst_xmm Value supplied for `dst_xmm`.
/// @param src_xmm Value supplied for `src_xmm`.
function movapd_xmm_xmm(asm, dst_xmm, src_xmm)
  if dst_xmm == src_xmm then return asm end if
  return _emit_sse_rr(asm, 0x66, -1, 0x28, dst_xmm, src_xmm)
end function

/// Encode or manage movsd xmm membase disp in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst_xmm Value supplied for `dst_xmm`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
function movsd_xmm_membase_disp(asm, dst_xmm, base, disp)
  d = _xmm_id(dst_xmm)
  b = _rid_any(base)
  if d < 0 or b < 0 then return asm end if
  enc = _encode_mem(d & 7, b, disp)
  asm = _emit8(asm, 0xF2)
  asm = _emit_rex(asm, 0, (d >> 3) & 1, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0x10)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage movsd membase disp xmm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
/// @param src_xmm Value supplied for `src_xmm`.
function movsd_membase_disp_xmm(asm, base, disp, src_xmm)
  sreg = _xmm_id(src_xmm)
  b = _rid_any(base)
  if sreg < 0 or b < 0 then return asm end if
  enc = _encode_mem(sreg & 7, b, disp)
  asm = _emit8(asm, 0xF2)
  asm = _emit_rex(asm, 0, (sreg >> 3) & 1, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0x11)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage cvtsi2sd xmm r64 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst_xmm Value supplied for `dst_xmm`.
/// @param src_reg Value supplied for `src_reg`.
function cvtsi2sd_xmm_r64(asm, dst_xmm, src_reg)
  d = _xmm_id(dst_xmm)
  sr = _rid_any(src_reg)
  if d < 0 or sr < 0 then return asm end if
  asm = _emit8(asm, 0xF2)
  asm = _emit_rex(asm, 1, (d >> 3) & 1, 0, (sr >> 3) & 1, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0x2A)
  asm = _emit_modrm(asm, 3, d & 7, sr & 7)
  return asm
end function

/// Encode or manage cvttsd2si r64 xmm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst_reg Value supplied for `dst_reg`.
/// @param src_xmm Value supplied for `src_xmm`.
function cvttsd2si_r64_xmm(asm, dst_reg, src_xmm)
  d = _rid_any(dst_reg)
  sr = _xmm_id(src_xmm)
  if d < 0 or sr < 0 then return asm end if
  asm = _emit8(asm, 0xF2)
  asm = _emit_rex(asm, 1, (d >> 3) & 1, 0, (sr >> 3) & 1, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0x2C)
  asm = _emit_modrm(asm, 3, d & 7, sr & 7)
  return asm
end function

/// Encode or manage roundsd xmm xmm imm8 in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst_xmm Value supplied for `dst_xmm`.
/// @param src_xmm Value supplied for `src_xmm`.
/// @param imm8 Value supplied for `imm8`.
function roundsd_xmm_xmm_imm8(asm, dst_xmm, src_xmm, imm8)
  d = _xmm_id(dst_xmm)
  sr = _xmm_id(src_xmm)
  if d < 0 or sr < 0 then return asm end if
  asm = _emit8(asm, 0x66)
  asm = _emit_rex(asm, 0, (d >> 3) & 1, 0, (sr >> 3) & 1, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0x3A)
  asm = _emit8(asm, 0x0B)
  asm = _emit_modrm(asm, 3, d & 7, sr & 7)
  asm = _emit8(asm, imm8)
  return asm
end function

/// Move one tagged 64-bit value into the low qword of an XMM register.
/// @param asm Value supplied for `asm`.
/// @param dst_xmm Value supplied for `dst_xmm`.
/// @param src_reg Value supplied for `src_reg`.
function movq_xmm_r64(asm, dst_xmm, src_reg)
  d = _xmm_id(dst_xmm)
  sr = _rid_any(src_reg)
  if d < 0 or sr < 0 then return asm end if
  asm = _emit8(asm, 0x66)
  asm = _emit_rex(asm, 1, (d >> 3) & 1, 0, (sr >> 3) & 1, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0x6E)
  asm = _emit_modrm(asm, 3, d & 7, sr & 7)
  return asm
end function

/// Restore one tagged 64-bit value from the low qword of an XMM register.
/// @param asm Value supplied for `asm`.
/// @param dst_reg Value supplied for `dst_reg`.
/// @param src_xmm Value supplied for `src_xmm`.
function movq_r64_xmm(asm, dst_reg, src_xmm)
  d = _rid_any(dst_reg)
  sr = _xmm_id(src_xmm)
  if d < 0 or sr < 0 then return asm end if
  asm = _emit8(asm, 0x66)
  asm = _emit_rex(asm, 1, (sr >> 3) & 1, 0, (d >> 3) & 1, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0x7E)
  asm = _emit_modrm(asm, 3, sr & 7, d & 7)
  return asm
end function

/// Encode or manage movd r32 xmm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function movd_r32_xmm(asm, dst, src)
  if _is_r32_name(dst) == false then return error(1, "movd_r32_xmm requires 32-bit dst") end if
  d = _rid_any(dst)
  s = _xmm_id(src)
  if d < 0 or s < 0 then return asm end if
  asm = _emit8(asm, 0x66)
  asm = _emit_rex(asm, 0, (s >> 3) & 1, 0, (d >> 3) & 1, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0x7E)
  asm = _emit_modrm(asm, 3, s & 7, d & 7)
  return asm
end function

/// Encode or manage movdqu xmm membase disp in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
function movdqu_xmm_membase_disp(asm, dst, base, disp)
  d = _xmm_id(dst)
  b = _rid_any(base)
  if d < 0 or b < 0 then return asm end if
  enc = _encode_mem(d & 7, b, disp)
  asm = _emit8(asm, 0xF3)
  asm = _emit_rex(asm, 0, (d >> 3) & 1, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0x6F)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage movdqu membase disp xmm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
/// @param src Value supplied for `src`.
function movdqu_membase_disp_xmm(asm, base, disp, src)
  s = _xmm_id(src)
  b = _rid_any(base)
  if s < 0 or b < 0 then return asm end if
  enc = _encode_mem(s & 7, b, disp)
  asm = _emit8(asm, 0xF3)
  asm = _emit_rex(asm, 0, (s >> 3) & 1, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0x7F)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage pxor xmm xmm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function pxor_xmm_xmm(asm, dst, src)
  return _emit_sse_rr(asm, 0x66, -1, 0xEF, dst, src)
end function

/// Encode or manage pcmpeqb xmm xmm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function pcmpeqb_xmm_xmm(asm, dst, src)
  return _emit_sse_rr(asm, 0x66, -1, 0x74, dst, src)
end function

/// Encode or manage pcmpeqw xmm xmm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function pcmpeqw_xmm_xmm(asm, dst, src)
  return _emit_sse_rr(asm, 0x66, -1, 0x75, dst, src)
end function

/// Encode or manage pmovmskb r32 xmm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst32 Value supplied for `dst32`.
/// @param src Value supplied for `src`.
function pmovmskb_r32_xmm(asm, dst32, src)
  if _is_r32_name(dst32) == false then return error(1, "pmovmskb_r32_xmm requires 32-bit dst") end if
  d = _rid_any(dst32)
  s = _xmm_id(src)
  if d < 0 or s < 0 then return asm end if
  asm = _emit8(asm, 0x66)
  asm = _emit_rex(asm, 0, (d >> 3) & 1, 0, (s >> 3) & 1, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0xD7)
  asm = _emit_modrm(asm, 3, d & 7, s & 7)
  return asm
end function

/// Encode or manage punpcklqdq xmm xmm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function punpcklqdq_xmm_xmm(asm, dst, src)
  return _emit_sse_rr(asm, 0x66, -1, 0x6C, dst, src)
end function

/// Encode or manage cvtsd2ss xmm xmm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function cvtsd2ss_xmm_xmm(asm, dst, src)
  d = _xmm_id(dst)
  s = _xmm_id(src)
  if d < 0 or s < 0 then return asm end if
  asm = _emit8(asm, 0xF2)
  asm = _emit_rex(asm, 0, (d >> 3) & 1, 0, (s >> 3) & 1, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0x5A)
  asm = _emit_modrm(asm, 3, d & 7, s & 7)
  return asm
end function

/// Encode or manage cvtss2sd xmm xmm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src Value supplied for `src`.
function cvtss2sd_xmm_xmm(asm, dst, src)
  d = _xmm_id(dst)
  s = _xmm_id(src)
  if d < 0 or s < 0 then return asm end if
  asm = _emit8(asm, 0xF3)
  asm = _emit_rex(asm, 0, (d >> 3) & 1, 0, (s >> 3) & 1, false)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0x5A)
  asm = _emit_modrm(asm, 3, d & 7, s & 7)
  return asm
end function

/// Encode or manage vmovdqu ymm membase disp in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
function vmovdqu_ymm_membase_disp(asm, dst, base, disp)
  d = _ymm_id(dst)
  b = _rid_any(base)
  if d < 0 or b < 0 then return asm end if
  enc = _encode_mem(d & 7, b, disp)
  asm = _emit(asm, _vex3(1, 0, void, 1, 2, (d >> 3) & 1, enc.rex_x, enc.rex_b))
  asm = _emit8(asm, 0x6F)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage vmovdqu membase disp ymm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param base Value supplied for `base`.
/// @param disp Value supplied for `disp`.
/// @param src Value supplied for `src`.
function vmovdqu_membase_disp_ymm(asm, base, disp, src)
  s = _ymm_id(src)
  b = _rid_any(base)
  if s < 0 or b < 0 then return asm end if
  enc = _encode_mem(s & 7, b, disp)
  asm = _emit(asm, _vex3(1, 0, void, 1, 2, (s >> 3) & 1, enc.rex_x, enc.rex_b))
  asm = _emit8(asm, 0x7F)
  asm = _emit(asm, enc.tail)
  return asm
end function

/// Encode or manage vpcmpeqb ymm ymm ymm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src1 Value supplied for `src1`.
/// @param src2 Value supplied for `src2`.
function vpcmpeqb_ymm_ymm_ymm(asm, dst, src1, src2)
  d = _ymm_id(dst)
  s1 = _ymm_id(src1)
  s2 = _ymm_id(src2)
  if d < 0 or s1 < 0 or s2 < 0 then return asm end if
  asm = _emit(asm, _vex3(1, 0, s1, 1, 1, (d >> 3) & 1, 0, (s2 >> 3) & 1))
  asm = _emit8(asm, 0x74)
  asm = _emit_modrm(asm, 3, d & 7, s2 & 7)
  return asm
end function

/// Encode or manage vpcmpeqw ymm ymm ymm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src1 Value supplied for `src1`.
/// @param src2 Value supplied for `src2`.
function vpcmpeqw_ymm_ymm_ymm(asm, dst, src1, src2)
  d = _ymm_id(dst)
  s1 = _ymm_id(src1)
  s2 = _ymm_id(src2)
  if d < 0 or s1 < 0 or s2 < 0 then return asm end if
  asm = _emit(asm, _vex3(1, 0, s1, 1, 1, (d >> 3) & 1, 0, (s2 >> 3) & 1))
  asm = _emit8(asm, 0x75)
  asm = _emit_modrm(asm, 3, d & 7, s2 & 7)
  return asm
end function

/// Encode or manage vpmovmskb r32 ymm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst32 Value supplied for `dst32`.
/// @param src Value supplied for `src`.
function vpmovmskb_r32_ymm(asm, dst32, src)
  if _is_r32_name(dst32) == false then return error(1, "vpmovmskb_r32_ymm requires 32-bit dst") end if
  d = _rid_any(dst32)
  s = _ymm_id(src)
  if d < 0 or s < 0 then return asm end if
  asm = _emit(asm, _vex3(1, 0, void, 1, 1, (d >> 3) & 1, 0, (s >> 3) & 1))
  asm = _emit8(asm, 0xD7)
  asm = _emit_modrm(asm, 3, d & 7, s & 7)
  return asm
end function

/// Encode or manage vpxor ymm ymm ymm in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param dst Value supplied for `dst`.
/// @param src1 Value supplied for `src1`.
/// @param src2 Value supplied for `src2`.
function vpxor_ymm_ymm_ymm(asm, dst, src1, src2)
  d = _ymm_id(dst)
  s1 = _ymm_id(src1)
  s2 = _ymm_id(src2)
  if d < 0 or s1 < 0 or s2 < 0 then return asm end if
  asm = _emit(asm, _vex3(1, 0, s1, 1, 1, (d >> 3) & 1, 0, (s2 >> 3) & 1))
  asm = _emit8(asm, 0xEF)
  asm = _emit_modrm(asm, 3, d & 7, s2 & 7)
  return asm
end function

/// Encode or manage vzeroupper in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function vzeroupper(asm)
  asm = _emit8(asm, 0xC5)
  asm = _emit8(asm, 0xF8)
  asm = _emit8(asm, 0x77)
  return asm
end function

/// Encode or manage peephole trim tail in the native x64 assembler.
/// @internal
function _peephole_trim_tail(asm, n)
  if typeof(n) != "int" or n <= 0 then return asm end if
  if typeof(asm.size) != "int" or asm.size < n then return asm end if
  asm = _ensure_capacity(asm, asm.size)
  asm.size = asm.size - n
  asm.buf_valid = false
  return asm
end function

/// Encode or manage enable listing in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param path Path to operate on.
/// @param show_addr Value supplied for `show_addr`.
/// @param show_bytes Value supplied for `show_bytes`.
/// @param show_text Value supplied for `show_text`.
function enable_listing(asm, path, show_addr, show_bytes, show_text)
  return asm
end function

/// Encode or manage disable listing in the native x64 assembler.
/// @param asm Value supplied for `asm`.
function disable_listing(asm)
  return asm
end function

/// Encode or manage gpr in the native x64 assembler.
/// @param name Name of the requested item.
function gpr(name)
  if _is_r8_name(name) then
    rid = _rid_any(name)
    return GPR(rid, 8, _is_force_rex_8(name))
  end if
  if _is_r32_name(name) then
    return GPR(_rid_any(name), 32, false)
  end if
  rd = _rid_any(name)
  if rd >= 0 then
    return GPR(rd, 64, false)
  end if
  return error(1, "Unknown register: " + name)
end function

/// Encode or manage rex in the native x64 assembler.
/// @internal
function _rex(w, r, x, b, force)
  if (w | r | x | b) == 0 and force == false then
    return bytes(0)
  end if
  return _emit_bytes_u8(0x40 |((w & 1) << 3) |((r & 1) << 2) |((x & 1) << 1) |(b & 1))
end function

/// Encode or manage modrm in the native x64 assembler.
/// @internal
function _modrm(mod, reg, rm)
  return _emit_bytes_u8(_modrm_byte(mod, reg, rm))
end function

/// Encode or manage sib in the native x64 assembler.
/// @internal
function _sib(scale, index, base)
  return _emit_bytes_u8(_sib_byte(scale, index, base))
end function

/// Encode or manage jcc mnemonic in the native x64 assembler.
/// @internal
function _jcc_mnemonic(cc)
  return cc
end function

/// Encode or manage fmt disp in the native x64 assembler.
/// @internal
function _fmt_disp(disp)
  return ""
end function

/// Encode or manage fmt mem in the native x64 assembler.
/// @internal
function _fmt_mem(base, disp)
  return ""
end function

/// Encode or manage fmt mem sib in the native x64 assembler.
/// @internal
function _fmt_mem_sib(base, index_reg, scale, disp)
  return ""
end function

/// Converts format call.
/// @internal
function _format_call(name, args, kwargs)
  return ""
end function

/// Updates write listing.
/// @param asm Value supplied for `asm`.
/// @param path Path to operate on.
function write_listing(asm, path)
  return asm
end function

/// Encode or manage emit placeholder in the native x64 assembler.
/// @param asm Value supplied for `asm`.
/// @param text Text to process.
function emit_placeholder(asm, text)
  return asm
end function
