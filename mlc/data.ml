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

// Deterministic chunked builders for PE data sections and named labels.
//! Provides the mlc data package.

package mlc.data
import mlc.constants as c
import mlc.tools as t

/// Named offset into a writable or zero-initialized section.
struct DataLabel
  /// Stores the name member of `DataLabel`.
  name,
  /// Stores the offset member of `DataLabel`.
  offset,
end struct

/// Named offset and byte length into read-only data.
struct DataRangeLabel
  /// Stores the name member of `DataRangeLabel`.
  name,
  /// Stores the offset member of `DataRangeLabel`.
  offset,
  /// Stores the length member of `DataRangeLabel`.
  length,
end struct

/// Deduplication entry for pooled constants.
struct PoolEntry
  /// Stores the key member of `PoolEntry`.
  key,
  /// Stores the offset member of `PoolEntry`.
  offset,
  /// Stores the length member of `PoolEntry`.
  length,
  /// Stores the label member of `PoolEntry`.
  label,
end struct

/// Deferred absolute-address relocation inside a data section.
struct DataPatch
  /// Stores the offset member of `DataPatch`.
  offset,
  /// Stores the target member of `DataPatch`.
  target,
  /// Stores the kind member of `DataPatch`.
  kind,
end struct

/// Chunked writable-data builder with indexed labels and relocations.
struct DataBuilder
  /// Stores the data member of `DataBuilder`.
  data,
  /// Stores the labels member of `DataBuilder`.
  labels,
  /// Stores the label index member of `DataBuilder`.
  label_index,
  /// Stores the reference label index member of `DataBuilder`.
  reference_label_index,
  /// Stores the patches member of `DataBuilder`.
  patches,
  /// Stores the used member of `DataBuilder`.
  used,
end struct

/// Size-only builder for the zero-initialized section.
struct BssBuilder
  /// Stores the size member of `BssBuilder`.
  size,
  /// Stores the labels member of `BssBuilder`.
  labels,
end struct

/// Chunked read-only builder with typed constant-deduplication pools.
struct RDataBuilder
  /// Stores the data member of `RDataBuilder`.
  data,
  /// Stores the labels member of `RDataBuilder`.
  labels,
  /// Stores the label index member of `RDataBuilder`.
  label_index,
  /// Stores the reference label index member of `RDataBuilder`.
  reference_label_index,
  /// Stores the patches member of `RDataBuilder`.
  patches,
  /// Stores the pool raw member of `RDataBuilder`.
  pool_raw,
  /// Stores the pool obj string member of `RDataBuilder`.
  pool_obj_string,
  /// Stores the pool obj float member of `RDataBuilder`.
  pool_obj_float,
  /// Stores the alias index member of `RDataBuilder`.
  alias_index,
  /// Stores the used member of `RDataBuilder`.
  used,
end struct

/// Returns find data label index.
/// @internal
function _find_data_label_index(labels, name)
  if len(labels) <= 0 then return -1 end if
  for i = 0 to len(labels) - 1
    it = labels[i]
    if typeof(it) != "struct" then continue end if
    if try(it.name) == name then return i end if
  end for
  return -1
end function

/// Implements upsert data label.
/// @internal
function _upsert_data_label(labels, name, offset)
  idx = _find_data_label_index(labels, name)
  if idx < 0 then
    return labels +[DataLabel(name, offset)]
  end if
  labels[idx] = DataLabel(name, offset)
  return labels
end function

/// Returns find range label index.
/// @internal
function _find_range_label_index(labels, name)
  if len(labels) <= 0 then return -1 end if
  for i = 0 to len(labels) - 1
    it = labels[i]
    if typeof(it) != "struct" then continue end if
    if try(it.name) == name then return i end if
  end for
  return -1
end function

/// Implements upsert range label.
/// @internal
function _upsert_range_label(labels, name, offset, length)
  idx = _find_range_label_index(labels, name)
  if idx < 0 then
    return labels +[DataRangeLabel(name, offset, length)]
  end if
  labels[idx] = DataRangeLabel(name, offset, length)
  return labels
end function

/// Returns find pool entry.
/// @internal
function _find_pool_entry(pool, key)
  if typeof(pool) == "struct" and typeof(pool.cap) == "int" and typeof(pool.keys) == "array" and typeof(pool.values) == "array" and typeof(pool.used) == "bytes" then
    return t.fastmap_get(pool, key, 0)
  end if

  if typeof(pool) == "array" then
    if len(pool) <= 0 then return 0 end if
    for i = 0 to len(pool) - 1
      it = pool[i]
      if typeof(it) == "struct" and it.key == key then return it end if
    end for
    return 0
  end if

  if typeof(pool) == "struct" then
    if typeof(pool.chunks) == "array" and len(pool.chunks) > 0 then
      for ci = 0 to len(pool.chunks) - 1
        chunk = pool.chunks[ci]
        if typeof(chunk) != "array" or len(chunk) <= 0 then continue end if
        for i = 0 to len(chunk) - 1
          it2 = chunk[i]
          if typeof(it2) == "struct" and it2.key == key then return it2 end if
        end for
      end for
    end if
    tail_n = t.arr_chunk_tail_len(pool.tail)
    if tail_n > 0 then
      for ti = 0 to tail_n - 1
        it3 = t.arr_chunk_tail_get(pool.tail, ti, 0)
        if typeof(it3) == "struct" and it3.key == key then return it3 end if
      end for
    end if
  end if

  return 0
end function

/// Create an empty writable-data builder with production-sized capacities.
function newDataBuilder()
  return DataBuilder(bytes(16384, 0), t.arr_chunk_new(1024), t.fastmap_new(2048), 0, t.arr_chunk_new(1024), 0)
end function

/// Implements data get labels.
/// @param db Value supplied for `db`.
function data_get_labels(db)
  if typeof(db) != "struct" then return [] end if
  if typeof(db.labels) == "array" then return db.labels end if
  if typeof(db.labels) == "struct" then return t.arr_chunk_finish(db.labels) end if
  return []
end function

/// Implements data get labels after.
/// @param db Value supplied for `db`.
/// @param start_index Value supplied for `start_index`.
function data_get_labels_after(db, start_index)
  out_b = t.arr_chunk_new(64)
  if typeof(db) != "struct" then return t.arr_chunk_finish(out_b) end if
  start = start_index
  if typeof(start) != "int" or start < 0 then start = 0 end if
  count = data_label_count(db)
  if start >= count then return t.arr_chunk_finish(out_b) end if
  if typeof(db.labels) == "array" then
    for i = start to count - 1 out_b = t.arr_chunk_push(out_b, db.labels[i]) end for
  else
    for i = start to count - 1 out_b = t.arr_chunk_push(out_b, t.arr_chunk_get(db.labels, i, 0)) end for
  end if
  return t.arr_chunk_finish(out_b)
end function

/// Implements data label count.
/// @param db Value supplied for `db`.
function data_label_count(db)
  if typeof(db) != "struct" then return 0 end if
  if typeof(db.label_index) == "struct" then return t.fastmap_size(db.label_index) end if
  return len(data_get_labels(db))
end function

/// Implements data label record.
/// @param db Value supplied for `db`.
/// @param name Name of the requested item.
function data_label_record(db, name)
  if typeof(db) != "struct" or typeof(name) != "string" or name == "" then return 0 end if
  if typeof(db.label_index) == "struct" then
    hit = t.fastmap_get(db.label_index, name, 0)
    if typeof(hit) == "struct" then return hit end if
  end if
  if typeof(db.reference_label_index) == "struct" then
    ref_hit = t.fastmap_get(db.reference_label_index, name, 0)
    if typeof(ref_hit) == "struct" then return ref_hit end if
  end if
  labels = data_get_labels(db)
  if len(labels) > 0 then
    for i = 0 to len(labels) - 1
      it = labels[i]
      if typeof(it) == "struct" and try(it.name) == name then return it end if
    end for
  end if
  return 0
end function

/// Implements data has label.
/// @param db Value supplied for `db`.
/// @param name Name of the requested item.
/// @returns The resulting `bool` value.
function data_has_label(db as struct, name as string) returns bool
  return typeof(data_label_record(db, name)) == "struct"
end function

/// Implements data set labels.
/// @param db Value supplied for `db`.
/// @param labels Value supplied for `labels`.
function data_set_labels(db, labels)
  if typeof(db) != "struct" then return db end if
  db.labels = t.arr_chunk_new(1024)
  db.reference_label_index = 0
  cap = 2048
  if typeof(labels) == "array" and len(labels) > 0 then cap = (len(labels) * 2) + 64 end if
  db.label_index = t.fastmap_new(cap)
  if typeof(labels) == "array" and len(labels) > 0 then
    for i = 0 to len(labels) - 1
      it = labels[i]
      if typeof(it) != "struct" or typeof(it.name) != "string" then continue end if
      db.labels = t.arr_chunk_push(db.labels, it)
      db.label_index = t.fastmap_set(db.label_index, it.name, it)
    end for
  end if
  return db
end function

/// Implements data clear labels.
/// @param db Value supplied for `db`.
function data_clear_labels(db)
  return data_set_labels(db, [])
end function

/// Implements data upsert label.
/// @internal
function _data_upsert_label(db, name, offset)
  if typeof(db) != "struct" or typeof(name) != "string" or name == "" then return db end if
  if typeof(db.labels) != "struct" or typeof(db.label_index) != "struct" then
    db = data_set_labels(db, data_get_labels(db))
  end if
  hit = t.fastmap_get(db.label_index, name, 0)
  if typeof(hit) == "struct" then
    hit.offset = offset
    return db
  end if
  rec = DataLabel(name, offset)
  db.labels = t.arr_chunk_push(db.labels, rec)
  db.label_index = t.fastmap_set(db.label_index, name, rec)
  return db
end function

/// Create an empty zero-initialized-data builder.
function newBssBuilder()
  return BssBuilder(0,[])
end function

/// Create an empty read-only-data builder and its constant pools.
function newRDataBuilder()
  return RDataBuilder(bytes(16384, 0), t.arr_chunk_new(1024), t.fastmap_new(2048), 0, t.arr_chunk_new(1024), t.fastmap_new(2048), t.fastmap_new(1024), t.fastmap_new(1024), t.fastmap_new(1024), 0)
end function

/// Implements data get patches.
/// @param db Value supplied for `db`.
function data_get_patches(db)
  if typeof(db) != "struct" then return [] end if
  if typeof(db.patches) == "array" then return db.patches end if
  if typeof(db.patches) == "struct" then return t.arr_chunk_finish(db.patches) end if
  return []
end function

/// Implements data patch count.
/// @param db Value supplied for `db`.
function data_patch_count(db)
  if typeof(db) != "struct" then return 0 end if
  if typeof(db.patches) == "array" then return len(db.patches) end if
  if typeof(db.patches) == "struct" then return t.arr_chunk_count(db.patches) end if
  return 0
end function

/// Implements data get patches after.
/// @param db Value supplied for `db`.
/// @param start_index Value supplied for `start_index`.
function data_get_patches_after(db, start_index)
  out_b = t.arr_chunk_new(64)
  if typeof(db) != "struct" then return t.arr_chunk_finish(out_b) end if
  start = start_index
  if typeof(start) != "int" or start < 0 then start = 0 end if
  count = data_patch_count(db)
  if start >= count then return t.arr_chunk_finish(out_b) end if
  if typeof(db.patches) == "array" then
    for i = start to count - 1 out_b = t.arr_chunk_push(out_b, db.patches[i]) end for
  else
    for i = start to count - 1 out_b = t.arr_chunk_push(out_b, t.arr_chunk_get(db.patches, i, 0)) end for
  end if
  return t.arr_chunk_finish(out_b)
end function

/// Implements data set patches.
/// @param db Value supplied for `db`.
/// @param patches Value supplied for `patches`.
function data_set_patches(db, patches)
  if typeof(db) != "struct" then return db end if
  db.patches = t.arr_chunk_new(1024)
  if typeof(patches) == "array" and len(patches) > 0 then
    for i = 0 to len(patches) - 1
      db.patches = t.arr_chunk_push(db.patches, patches[i])
    end for
  end if
  return db
end function

/// Implements data clear patches.
/// @param db Value supplied for `db`.
function data_clear_patches(db)
  return data_set_patches(db, [])
end function

/// Implements rdata get patches.
/// @param rb Value supplied for `rb`.
function rdata_get_patches(rb)
  if typeof(rb) != "struct" then return [] end if
  if typeof(rb.patches) == "array" then return rb.patches end if
  if typeof(rb.patches) == "struct" then return t.arr_chunk_finish(rb.patches) end if
  return []
end function

/// Implements rdata patch count.
/// @param rb Value supplied for `rb`.
function rdata_patch_count(rb)
  if typeof(rb) != "struct" then return 0 end if
  if typeof(rb.patches) == "array" then return len(rb.patches) end if
  if typeof(rb.patches) == "struct" then return t.arr_chunk_count(rb.patches) end if
  return 0
end function

/// Implements rdata get patches after.
/// @param rb Value supplied for `rb`.
/// @param start_index Value supplied for `start_index`.
function rdata_get_patches_after(rb, start_index)
  out_b = t.arr_chunk_new(64)
  if typeof(rb) != "struct" then return t.arr_chunk_finish(out_b) end if
  start = start_index
  if typeof(start) != "int" or start < 0 then start = 0 end if
  count = rdata_patch_count(rb)
  if start >= count then return t.arr_chunk_finish(out_b) end if
  if typeof(rb.patches) == "array" then
    for i = start to count - 1 out_b = t.arr_chunk_push(out_b, rb.patches[i]) end for
  else
    for i = start to count - 1 out_b = t.arr_chunk_push(out_b, t.arr_chunk_get(rb.patches, i, 0)) end for
  end if
  return t.arr_chunk_finish(out_b)
end function

/// Implements rdata set patches.
/// @param rb Value supplied for `rb`.
/// @param patches Value supplied for `patches`.
function rdata_set_patches(rb, patches)
  if typeof(rb) != "struct" then return rb end if
  rb.patches = t.arr_chunk_new(1024)
  if typeof(patches) == "array" and len(patches) > 0 then
    for i = 0 to len(patches) - 1
      rb.patches = t.arr_chunk_push(rb.patches, patches[i])
    end for
  end if
  return rb
end function

/// Implements rdata clear patches.
/// @param rb Value supplied for `rb`.
function rdata_clear_patches(rb)
  return rdata_set_patches(rb, [])
end function

/// Implements rdata get labels.
/// @param rb Value supplied for `rb`.
function rdata_get_labels(rb)
  if typeof(rb) != "struct" then return [] end if
  if typeof(rb.labels) == "array" then return rb.labels end if
  if typeof(rb.labels) == "struct" then return t.arr_chunk_finish(rb.labels) end if
  return []
end function

/// Implements rdata get labels after.
/// @param rb Value supplied for `rb`.
/// @param start_index Value supplied for `start_index`.
function rdata_get_labels_after(rb, start_index)
  out_b = t.arr_chunk_new(64)
  if typeof(rb) != "struct" then return t.arr_chunk_finish(out_b) end if
  start = start_index
  if typeof(start) != "int" or start < 0 then start = 0 end if
  count = rdata_label_count(rb)
  if start >= count then return t.arr_chunk_finish(out_b) end if
  if typeof(rb.labels) == "array" then
    for i = start to count - 1 out_b = t.arr_chunk_push(out_b, rb.labels[i]) end for
  else
    for i = start to count - 1 out_b = t.arr_chunk_push(out_b, t.arr_chunk_get(rb.labels, i, 0)) end for
  end if
  return t.arr_chunk_finish(out_b)
end function

/// Implements rdata resolve alias.
/// @param rb Value supplied for `rb`.
/// @param name Name of the requested item.
function rdata_resolve_alias(rb, name)
  if typeof(rb) != "struct" or typeof(name) != "string" or name == "" then return name end if
  if typeof(rb.alias_index) != "struct" then return name end if
  return t.fastmap_get(rb.alias_index, name, name)
end function

/// Implements rdata label count.
/// @param rb Value supplied for `rb`.
function rdata_label_count(rb)
  if typeof(rb) != "struct" then return 0 end if
  if typeof(rb.label_index) == "struct" then return t.fastmap_size(rb.label_index) end if
  labels = rdata_get_labels(rb)
  return len(labels)
end function

/// Implements rdata label record.
/// @param rb Value supplied for `rb`.
/// @param name Name of the requested item.
function rdata_label_record(rb, name)
  if typeof(rb) != "struct" or typeof(name) != "string" or name == "" then return 0 end if
  if typeof(rb.label_index) == "struct" then
    hit = t.fastmap_get(rb.label_index, name, 0)
    if typeof(hit) == "struct" then return hit end if
  end if
  if typeof(rb.reference_label_index) == "struct" then
    ref_hit = t.fastmap_get(rb.reference_label_index, name, 0)
    if typeof(ref_hit) == "struct" then return ref_hit end if
  end if
  labels = rdata_get_labels(rb)
  if len(labels) > 0 then
    for i = 0 to len(labels) - 1
      it = labels[i]
      if typeof(it) == "struct" and try(it.name) == name then return it end if
    end for
  end if
  return 0
end function

/// Implements rdata has label.
/// @param rb Value supplied for `rb`.
/// @param name Name of the requested item.
function rdata_has_label(rb, name)
  return typeof(rdata_label_record(rb, name)) == "struct"
end function

/// Implements rdata label length.
/// @param rb Value supplied for `rb`.
/// @param name Name of the requested item.
function rdata_label_length(rb, name)
  rec = rdata_label_record(rb, name)
  if typeof(rec) == "struct" and typeof(rec.length) == "int" then return rec.length end if
  return 0
end function

/// Implements rdata set labels.
/// @param rb Value supplied for `rb`.
/// @param labels Value supplied for `labels`.
function rdata_set_labels(rb, labels)
  if typeof(rb) != "struct" then return rb end if
  rb.labels = t.arr_chunk_new(1024)
  rb.reference_label_index = 0
  cap = 2048
  if typeof(labels) == "array" and len(labels) > 0 then cap = (len(labels) * 2) + 64 end if
  rb.label_index = t.fastmap_new(cap)
  if typeof(labels) == "array" and len(labels) > 0 then
    for i = 0 to len(labels) - 1
      it = labels[i]
      if typeof(it) != "struct" or typeof(it.name) != "string" then continue end if
      rb.labels = t.arr_chunk_push(rb.labels, it)
      rb.label_index = t.fastmap_set(rb.label_index, it.name, it)
    end for
  end if
  return rb
end function

/// Implements rdata clear labels.
/// @param rb Value supplied for `rb`.
function rdata_clear_labels(rb)
  return rdata_set_labels(rb, [])
end function

/// Implements rdata upsert label.
/// @internal
function _rdata_upsert_label(rb, name, offset, length)
  if typeof(rb) != "struct" or typeof(name) != "string" or name == "" then return rb end if
  if typeof(rb.labels) != "struct" or typeof(rb.label_index) != "struct" then
    rb = rdata_set_labels(rb, rdata_get_labels(rb))
  end if
  hit = t.fastmap_get(rb.label_index, name, 0)
  if typeof(hit) == "struct" then
    hit.offset = offset
    hit.length = length
    return rb
  end if
  rec = DataRangeLabel(name, offset, length)
  rb.labels = t.arr_chunk_push(rb.labels, rec)
  rb.label_index = t.fastmap_set(rb.label_index, name, rec)
  return rb
end function

/// Implements buf used.
/// @internal
function _buf_used(db)
  if typeof(db.used) == "int" and db.used >= 0 then return db.used end if
  if typeof(db.data) == "bytes" then return len(db.data) end if
  return 0
end function

/// Implements rdata used.
/// @param rb Value supplied for `rb`.
function rdata_used(rb)
  return _buf_used(rb)
end function

/// Implements buf ensure.
/// @internal
function _buf_ensure(db, need)
  if typeof(db.data) != "bytes" then db.data = bytes(0) end if
  cap = len(db.data)
  if cap >= need then return db end if

  ncap = cap
  if ncap <= 0 then ncap = 64 end if
  while ncap < need
    ncap = ncap * 2
  end while

  nb = bytes(ncap, 0)
  used = _buf_used(db)
  if used > cap then used = cap end if
  for i = 0 to used - 1
    nb[i] = db.data[i]
  end for
  db.data = nb
  return db
end function

/// Implements buf append.
/// @internal
function _buf_append(db, b)
  if typeof(b) != "bytes" or len(b) <= 0 then return db end if
  off = _buf_used(db)
  db = _buf_ensure(db, off + len(b))
  for i = 0 to len(b) - 1
    db.data[off + i] = b[i]
  end for
  db.used = off + len(b)
  return db
end function

/// Implements data add u32.
/// @param db Value supplied for `db`.
/// @param name Name of the requested item.
/// @param value Value to process.
function data_add_u32(db, name, value)
  off = _buf_used(db)
  db = _data_upsert_label(db, name, off)
  db = _buf_append(db, t.u32(value))
  return db
end function

/// Implements data add u64.
/// @param db Value supplied for `db`.
/// @param name Name of the requested item.
/// @param value Value to process.
function data_add_u64(db, name, value)
  off = _buf_used(db)
  db = _data_upsert_label(db, name, off)
  db = _buf_append(db, t.u64(value))
  return db
end function

/// Implements data add bytes.
/// @param db Value supplied for `db`.
/// @param name Name of the requested item.
/// @param b Second input value.
function data_add_bytes(db, name, b)
  off = _buf_used(db)
  db = _data_upsert_label(db, name, off)
  db = _buf_append(db, b)
  return db
end function

/// Implements data add abs64 patch.
/// @param db Value supplied for `db`.
/// @param offset Zero-based starting offset.
/// @param target Value supplied for `target`.
function data_add_abs64_patch(db, offset, target)
  if typeof(db.patches) != "struct" then db = data_set_patches(db, data_get_patches(db)) end if
  db.patches = t.arr_chunk_push(db.patches, DataPatch(offset, target, "abs64"))
  return db
end function

/// Implements data pad align.
/// @param db Value supplied for `db`.
/// @param align Value supplied for `align`.
function data_pad_align(db, align)
  if align <= 0 then return db end if
  used = _buf_used(db)
  pad = (-used) % align
  if pad > 0 then
    db = _buf_append(db, bytes(pad, 0))
  end if
  return db
end function

/// Implements bss pad align.
/// @param bb Value supplied for `bb`.
/// @param align Value supplied for `align`.
function bss_pad_align(bb, align)
  if align <= 0 then return bb end if
  pad = (-bb.size) % align
  if pad > 0 then
    bb.size = bb.size + pad
  end if
  return bb
end function

/// Implements bss reserve.
/// @param bb Value supplied for `bb`.
/// @param name Name of the requested item.
/// @param size Value supplied for `size`.
/// @param align Value supplied for `align`.
function bss_reserve(bb, name, size, align)
  if _find_data_label_index(bb.labels, name) >= 0 then
    return bb
  end if
  bb = bss_pad_align(bb, align)
  bb.labels = bb.labels +[DataLabel(name, bb.size)]
  bb.size = bb.size + size
  return bb
end function

/// Implements rdata pad align.
/// @param rb Value supplied for `rb`.
/// @param align Value supplied for `align`.
function rdata_pad_align(rb, align)
  if align <= 0 then return rb end if
  pad = (-_buf_used(rb)) % align
  if pad > 0 then
    rb = _buf_append(rb, bytes(pad, 0))
  end if
  return rb
end function

/// Implements rdata intern raw.
/// @internal
function _rdata_intern_raw(rb, name, raw)
  hit = _find_pool_entry(rb.pool_raw, raw)
  if typeof(hit) == "struct" then
    pe = hit
    if typeof(rb.alias_index) != "struct" then rb.alias_index = t.fastmap_new(1024) end if
    rb.alias_index = t.fastmap_set(rb.alias_index, name, pe.label)
    rb = _rdata_upsert_label(rb, name, pe.offset, pe.length)
    return rb
  end if

  off = _buf_used(rb)
  rb = _buf_append(rb, raw)
  rec = PoolEntry(raw, off, len(raw), name)
  rb.pool_raw = t.fastmap_set(rb.pool_raw, raw, rec)
  rb = _rdata_upsert_label(rb, name, off, len(raw))
  return rb
end function

/// Implements rdata add str.
/// @param rb Value supplied for `rb`.
/// @param name Name of the requested item.
/// @param text Text to process.
function rdata_add_str(rb, name, text)
  return rdata_add_str_nl(rb, name, text, true)
end function

/// Implements rdata add str nl.
/// @param rb Value supplied for `rb`.
/// @param name Name of the requested item.
/// @param text Text to process.
/// @param add_newline Value supplied for `add_newline`.
function rdata_add_str_nl(rb, name, text, add_newline)
  s = text
  if add_newline then
    s = s + "\n"
  end if
  return _rdata_intern_raw(rb, name, bytes(s))
end function

/// Implements rdata add bytes.
/// @param rb Value supplied for `rb`.
/// @param name Name of the requested item.
/// @param raw Value supplied for `raw`.
function rdata_add_bytes(rb, name, raw)
  return _rdata_intern_raw(rb, name, raw)
end function

/// Implements rdata add bytes unique.
/// @param rb Value supplied for `rb`.
/// @param name Name of the requested item.
/// @param raw Value supplied for `raw`.
function rdata_add_bytes_unique(rb, name, raw)
  off = _buf_used(rb)
  rb = _buf_append(rb, raw)
  // The caller promises a fresh label. Avoid the otherwise quadratic
  // duplicate-name scan for large generated static-object tables.
  rb = _rdata_upsert_label(rb, name, off, len(raw))
  return rb
end function

/// Implements rdata add abs64 patch.
/// @param rb Value supplied for `rb`.
/// @param offset Zero-based starting offset.
/// @param target Value supplied for `target`.
function rdata_add_abs64_patch(rb, offset, target)
  if typeof(rb.patches) != "struct" then rb = rdata_set_patches(rb, rdata_get_patches(rb)) end if
  rb.patches = t.arr_chunk_push(rb.patches, DataPatch(offset, target, "abs64"))
  return rb
end function

/// Implements float to f64le.
/// @internal
function _float_to_f64le(value)
  v = value
  if typeof(v) == "int" then
    v = v + 0.0
  end if
  if typeof(v) != "float" then
    return bytes(8, 0)
  end if

  // NaN -> qNaN bit pattern 0x7FF8000000000000
  if v != v then
    bnan = bytes(8, 0)
    bnan[6] = 0xF8
    bnan[7] = 0x7F
    return bnan
  end if

  sign = 0
  x = v
  if x < 0.0 then
    sign = 1
    x = 0.0 - x
  end if

  if x == 0.0 then
    bz = bytes(8, 0)
    if sign == 1 then bz[7] = 0x80 end if
    return bz
  end if

  exp = 0
  y = x
  while y >= 2.0 and exp < 2048
    y = y / 2.0
    exp = exp + 1
  end while
  while y < 1.0 and exp > -2048
    y = y * 2.0
    exp = exp - 1
  end while

  exp_field = exp + 1023
  mant = 0
  if exp_field <= 0 then
    // subnormal underflow fallback
    exp_field = 0
    mant = 0
  else
    if exp_field >= 0x7FF then
      exp_field = 0x7FF
      mant = 0
    else
      frac = y - 1.0
      bit = 1 << 51
      i = 0
      while i < 52
        frac = frac * 2.0
        if frac >= 1.0 then
          mant = mant | bit
          frac = frac - 1.0
        end if
        bit = bit >> 1
        i = i + 1
      end while
    end if
  end if

  b = bytes(8, 0)
  b[0] = mant & 0xFF
  b[1] =(mant >> 8) & 0xFF
  b[2] =(mant >> 16) & 0xFF
  b[3] =(mant >> 24) & 0xFF
  b[4] =(mant >> 32) & 0xFF
  b[5] =(mant >> 40) & 0xFF
  b[6] =((mant >> 48) & 0x0F) |((exp_field & 0x0F) << 4)
  b[7] =((exp_field >> 4) & 0x7F) |(sign << 7)
  return b
end function

/// Implements rdata add obj string.
/// @param rb Value supplied for `rb`.
/// @param name Name of the requested item.
/// @param text Text to process.
function rdata_add_obj_string(rb, name, text)
  payload = bytes(text)

  hit = _find_pool_entry(rb.pool_obj_string, payload)
  if typeof(hit) == "struct" then
    if typeof(rb.alias_index) != "struct" then rb.alias_index = t.fastmap_new(1024) end if
    rb.alias_index = t.fastmap_set(rb.alias_index, name, hit.label)
    rb = _rdata_upsert_label(rb, name, hit.offset, hit.length)
    return rb
  end if

  rb = rdata_pad_align(rb, 8)
  off = _buf_used(rb)
  rb = _buf_append(rb, t.u32(c.OBJ_STRING))
  rb = _buf_append(rb, t.u32(len(payload)))
  rb = _buf_append(rb, payload)
  rb = _buf_append(rb, bytes(1, 0))
  ln = _buf_used(rb) - off

  rb = _rdata_upsert_label(rb, name, off, ln)
  rb.pool_obj_string = t.fastmap_set(rb.pool_obj_string, payload, PoolEntry(payload, off, ln, name))
  return rb
end function

/// Implements rdata add obj string unique.
/// @param rb Value supplied for `rb`.
/// @param name Name of the requested item.
/// @param text Text to process.
function rdata_add_obj_string_unique(rb, name, text)
  payload = bytes(text)

  hit = _find_pool_entry(rb.pool_obj_string, payload)
  if typeof(hit) == "struct" then
    if typeof(rb.alias_index) != "struct" then rb.alias_index = t.fastmap_new(1024) end if
    rb.alias_index = t.fastmap_set(rb.alias_index, name, hit.label)
    rb = _rdata_upsert_label(rb, name, hit.offset, hit.length)
    return rb
  end if

  rb = rdata_pad_align(rb, 8)
  off = _buf_used(rb)
  rb = _buf_append(rb, t.u32(c.OBJ_STRING))
  rb = _buf_append(rb, t.u32(len(payload)))
  rb = _buf_append(rb, payload)
  rb = _buf_append(rb, bytes(1, 0))
  ln = _buf_used(rb) - off

  rb = _rdata_upsert_label(rb, name, off, ln)
  rb.pool_obj_string = t.fastmap_set(rb.pool_obj_string, payload, PoolEntry(payload, off, ln, name))
  return rb
end function

/// Implements rdata add obj float.
/// @param rb Value supplied for `rb`.
/// @param name Name of the requested item.
/// @param value Value to process.
function rdata_add_obj_float(rb, name, value)
  packed = _float_to_f64le(value)

  hit = _find_pool_entry(rb.pool_obj_float, packed)
  if typeof(hit) == "struct" then
    if typeof(rb.alias_index) != "struct" then rb.alias_index = t.fastmap_new(1024) end if
    rb.alias_index = t.fastmap_set(rb.alias_index, name, hit.label)
    rb = _rdata_upsert_label(rb, name, hit.offset, hit.length)
    return rb
  end if

  rb = rdata_pad_align(rb, 8)
  off = _buf_used(rb)
  rb = _buf_append(rb, t.u32(c.OBJ_FLOAT))
  rb = _buf_append(rb, t.u32(0))
  rb = _buf_append(rb, packed)
  ln = _buf_used(rb) - off

  rb = _rdata_upsert_label(rb, name, off, ln)
  rb.pool_obj_float = t.fastmap_set(rb.pool_obj_float, packed, PoolEntry(packed, off, ln, name))
  return rb
end function
