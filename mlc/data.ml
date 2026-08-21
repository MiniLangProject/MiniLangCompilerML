package mlc.data
import mlc.constants as c
import mlc.tools as t

struct DataLabel
  name,
  offset,
end struct

struct DataRangeLabel
  name,
  offset,
  length,
end struct

struct PoolEntry
  key,
  offset,
  length,
end struct

struct DataPatch
  offset,
  target,
  kind,
end struct

struct DataBuilder
  data,
  labels,
  label_index,
  patches,
  used,
end struct

struct BssBuilder
  size,
  labels,
end struct

struct RDataBuilder
  data,
  labels,
  label_index,
  patches,
  pool_raw,
  pool_obj_string,
  pool_obj_float,
  used,
end struct

function _find_data_label_index(labels, name)
  if len(labels) <= 0 then return -1 end if
  for i = 0 to len(labels) - 1
    it = labels[i]
    if typeof(it) != "struct" then continue end if
    if try(it.name) == name then return i end if
  end for
  return -1
end function

function _upsert_data_label(labels, name, offset)
  idx = _find_data_label_index(labels, name)
  if idx < 0 then
    return labels +[DataLabel(name, offset)]
  end if
  labels[idx] = DataLabel(name, offset)
  return labels
end function

function _find_range_label_index(labels, name)
  if len(labels) <= 0 then return -1 end if
  for i = 0 to len(labels) - 1
    it = labels[i]
    if typeof(it) != "struct" then continue end if
    if try(it.name) == name then return i end if
  end for
  return -1
end function

function _upsert_range_label(labels, name, offset, length)
  idx = _find_range_label_index(labels, name)
  if idx < 0 then
    return labels +[DataRangeLabel(name, offset, length)]
  end if
  labels[idx] = DataRangeLabel(name, offset, length)
  return labels
end function

function _find_pool_entry(pool, key)
  if typeof(pool) == "struct" and typeof(pool.cap) == "int" and typeof(pool.keys) == "array" and typeof(pool.values) == "array" and typeof(pool.used) == "array" then
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

function newDataBuilder()
  return DataBuilder(bytes(16384, 0), t.arr_chunk_new(1024), t.fastmap_new(2048), t.arr_chunk_new(1024), 0)
end function

function data_get_labels(db)
  if typeof(db) != "struct" then return [] end if
  if typeof(db.labels) == "array" then return db.labels end if
  if typeof(db.labels) == "struct" then return t.arr_chunk_finish(db.labels) end if
  return []
end function

function data_label_count(db)
  if typeof(db) != "struct" then return 0 end if
  if typeof(db.label_index) == "struct" then return t.fastmap_size(db.label_index) end if
  return len(data_get_labels(db))
end function

function data_label_record(db, name)
  if typeof(db) != "struct" or typeof(name) != "string" or name == "" then return 0 end if
  if typeof(db.label_index) == "struct" then
    hit = t.fastmap_get(db.label_index, name, 0)
    if typeof(hit) == "struct" then return hit end if
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

function data_has_label(db, name)
  return typeof(data_label_record(db, name)) == "struct"
end function

function data_set_labels(db, labels)
  if typeof(db) != "struct" then return db end if
  db.labels = t.arr_chunk_new(1024)
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

function data_clear_labels(db)
  return data_set_labels(db, [])
end function

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

function newBssBuilder()
  return BssBuilder(0,[])
end function

function newRDataBuilder()
  return RDataBuilder(bytes(16384, 0), t.arr_chunk_new(1024), t.fastmap_new(2048), t.arr_chunk_new(1024), t.fastmap_new(2048), t.fastmap_new(1024), t.fastmap_new(1024), 0)
end function

function data_get_patches(db)
  if typeof(db) != "struct" then return [] end if
  if typeof(db.patches) == "array" then return db.patches end if
  if typeof(db.patches) == "struct" then return t.arr_chunk_finish(db.patches) end if
  return []
end function

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

function data_clear_patches(db)
  return data_set_patches(db, [])
end function

function rdata_get_patches(rb)
  if typeof(rb) != "struct" then return [] end if
  if typeof(rb.patches) == "array" then return rb.patches end if
  if typeof(rb.patches) == "struct" then return t.arr_chunk_finish(rb.patches) end if
  return []
end function

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

function rdata_clear_patches(rb)
  return rdata_set_patches(rb, [])
end function

function rdata_get_labels(rb)
  if typeof(rb) != "struct" then return [] end if
  if typeof(rb.labels) == "array" then return rb.labels end if
  if typeof(rb.labels) == "struct" then return t.arr_chunk_finish(rb.labels) end if
  return []
end function

function rdata_label_count(rb)
  if typeof(rb) != "struct" then return 0 end if
  if typeof(rb.label_index) == "struct" then return t.fastmap_size(rb.label_index) end if
  labels = rdata_get_labels(rb)
  return len(labels)
end function

function rdata_label_record(rb, name)
  if typeof(rb) != "struct" or typeof(name) != "string" or name == "" then return 0 end if
  if typeof(rb.label_index) == "struct" then
    hit = t.fastmap_get(rb.label_index, name, 0)
    if typeof(hit) == "struct" then return hit end if
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

function rdata_has_label(rb, name)
  return typeof(rdata_label_record(rb, name)) == "struct"
end function

function rdata_label_length(rb, name)
  rec = rdata_label_record(rb, name)
  if typeof(rec) == "struct" and typeof(rec.length) == "int" then return rec.length end if
  return 0
end function

function rdata_set_labels(rb, labels)
  if typeof(rb) != "struct" then return rb end if
  rb.labels = t.arr_chunk_new(1024)
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

function rdata_clear_labels(rb)
  return rdata_set_labels(rb, [])
end function

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

function _buf_used(db)
  if typeof(db.used) == "int" and db.used >= 0 then return db.used end if
  if typeof(db.data) == "bytes" then return len(db.data) end if
  return 0
end function

function rdata_used(rb)
  return _buf_used(rb)
end function

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

function data_add_u32(db, name, value)
  off = _buf_used(db)
  db = _data_upsert_label(db, name, off)
  db = _buf_append(db, t.u32(value))
  return db
end function

function data_add_u64(db, name, value)
  off = _buf_used(db)
  db = _data_upsert_label(db, name, off)
  db = _buf_append(db, t.u64(value))
  return db
end function

function data_add_bytes(db, name, b)
  off = _buf_used(db)
  db = _data_upsert_label(db, name, off)
  db = _buf_append(db, b)
  return db
end function

function data_add_abs64_patch(db, offset, target)
  if typeof(db.patches) != "struct" then db = data_set_patches(db, data_get_patches(db)) end if
  db.patches = t.arr_chunk_push(db.patches, DataPatch(offset, target, "abs64"))
  return db
end function

function data_pad_align(db, align)
  if align <= 0 then return db end if
  used = _buf_used(db)
  pad = (-used) % align
  if pad > 0 then
    db = _buf_append(db, bytes(pad, 0))
  end if
  return db
end function

function bss_pad_align(bb, align)
  if align <= 0 then return bb end if
  pad = (-bb.size) % align
  if pad > 0 then
    bb.size = bb.size + pad
  end if
  return bb
end function

function bss_reserve(bb, name, size, align)
  if _find_data_label_index(bb.labels, name) >= 0 then
    return bb
  end if
  bb = bss_pad_align(bb, align)
  bb.labels = bb.labels +[DataLabel(name, bb.size)]
  bb.size = bb.size + size
  return bb
end function

function rdata_pad_align(rb, align)
  if align <= 0 then return rb end if
  pad = (-_buf_used(rb)) % align
  if pad > 0 then
    rb = _buf_append(rb, bytes(pad, 0))
  end if
  return rb
end function

function _rdata_intern_raw(rb, name, raw)
  hit = _find_pool_entry(rb.pool_raw, raw)
  if typeof(hit) == "struct" then
    pe = hit
    rb = _rdata_upsert_label(rb, name, pe.offset, pe.length)
    return rb
  end if

  off = _buf_used(rb)
  rb = _buf_append(rb, raw)
  rec = PoolEntry(raw, off, len(raw))
  rb.pool_raw = t.fastmap_set(rb.pool_raw, raw, rec)
  rb = _rdata_upsert_label(rb, name, off, len(raw))
  return rb
end function

function rdata_add_str(rb, name, text)
  return rdata_add_str_nl(rb, name, text, true)
end function

function rdata_add_str_nl(rb, name, text, add_newline)
  s = text
  if add_newline then
    s = s + "\n"
  end if
  return _rdata_intern_raw(rb, name, bytes(s))
end function

function rdata_add_bytes(rb, name, raw)
  return _rdata_intern_raw(rb, name, raw)
end function

function rdata_add_bytes_unique(rb, name, raw)
  off = _buf_used(rb)
  rb = _buf_append(rb, raw)
  // The caller promises a fresh label. Avoid the otherwise quadratic
  // duplicate-name scan for large generated static-object tables.
  rb = _rdata_upsert_label(rb, name, off, len(raw))
  return rb
end function

function rdata_add_abs64_patch(rb, offset, target)
  if typeof(rb.patches) != "struct" then rb = rdata_set_patches(rb, rdata_get_patches(rb)) end if
  rb.patches = t.arr_chunk_push(rb.patches, DataPatch(offset, target, "abs64"))
  return rb
end function

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

function rdata_add_obj_string(rb, name, text)
  payload = bytes(text)

  hit = _find_pool_entry(rb.pool_obj_string, payload)
  if typeof(hit) == "struct" then
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
  rb.pool_obj_string = t.fastmap_set(rb.pool_obj_string, payload, PoolEntry(payload, off, ln))
  return rb
end function

function rdata_add_obj_string_unique(rb, name, text)
  payload = bytes(text)

  hit = _find_pool_entry(rb.pool_obj_string, payload)
  if typeof(hit) == "struct" then
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
  rb.pool_obj_string = t.fastmap_set(rb.pool_obj_string, payload, PoolEntry(payload, off, ln))
  return rb
end function

function rdata_add_obj_float(rb, name, value)
  packed = _float_to_f64le(value)

  hit = _find_pool_entry(rb.pool_obj_float, packed)
  if typeof(hit) == "struct" then
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
  rb.pool_obj_float = t.fastmap_set(rb.pool_obj_float, packed, PoolEntry(packed, off, ln))
  return rb
end function
