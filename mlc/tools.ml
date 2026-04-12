package mlc.tools
import mlc.constants as c

struct ArrayChunkBuilder
  chunks,
  tail,
  cap,
end struct

struct ArrayChunkTail
  data,
  used,
  cap,
end struct

struct ArrayChunkVoidSentinel
  tag,
end struct

struct BytePages
  chunk_pages,
  chunk_tail,
  size,
end struct

struct FastMap
  keys,
  values,
  used,
  cap,
  size,
end struct

_arr_void_sentinel = ArrayChunkVoidSentinel(0xA11D)

function _u64_mask()
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

  bs = bytes(0)
  if typeof(key) == "bytes" then
    bs = key
  else
    txt = ""
    if typeof(key) == "string" then
      txt = key
    else
      txt = "" + key
    end if
    bs = bytes(txt)
  end if
  h = 2166136261
  if len(bs) > 0 then
    for i = 0 to len(bs) - 1
      h = h ^ bs[i]
      h = (h * 16777619) & 0x7FFFFFFF
    end for
  end if
  return h
end function

function _fm_is_valid(mapv)
  if typeof(mapv) != "struct" then return false end if
  if typeof(mapv.keys) != "array" then return false end if
  if typeof(mapv.values) != "array" then return false end if
  if typeof(mapv.used) != "array" then return false end if
  if typeof(mapv.cap) != "int" or mapv.cap <= 0 then return false end if
  if len(mapv.keys) != mapv.cap then return false end if
  if len(mapv.values) != mapv.cap then return false end if
  if len(mapv.used) != mapv.cap then return false end if
  return true
end function

function fastmap_new(initial_cap)
  cap = _fm_next_pow2(initial_cap)
  return FastMap(_arr_fill(cap, ""), _arr_fill(cap, 0), _arr_fill(cap, 0), cap, 0)
end function

function fastmap_clear(mapv)
  m = mapv
  if _fm_is_valid(m) == false then return fastmap_new(64) end if
  if typeof(m.used) == "array" and len(m.used) > 0 then
    for i = 0 to len(m.used) - 1
      m.used[i] = 0
    end for
  end if
  m.size = 0
  return m
end function

function _fm_probe_slot(mapv, key)
  if _fm_is_valid(mapv) == false then return [-1, false] end if
  mask = mapv.cap - 1
  idx = _fm_hash_any(key) & mask
  steps = 0
  while steps < mapv.cap
    if mapv.used[idx] == 0 then return [idx, false] end if
    if mapv.keys[idx] == key then return [idx, true] end if
    idx = (idx + 1) & mask
    steps = steps + 1
  end while
  return [-1, false]
end function

function _fm_insert_no_resize(mapv, key, value)
  p = _fm_probe_slot(mapv, key)
  idx = p[0]
  found = p[1]
  if idx < 0 then return mapv end if
  if found == false then
    mapv.used[idx] = 1
    mapv.keys[idx] = key
    mapv.size = mapv.size + 1
  end if
  mapv.values[idx] = value
  return mapv
end function

function _fm_rehash(mapv, new_cap)
  nm = fastmap_new(new_cap)
  if _fm_is_valid(mapv) == false then return nm end if
  for i = 0 to mapv.cap - 1
    if mapv.used[i] != 0 then
      nm = _fm_insert_no_resize(nm, mapv.keys[i], mapv.values[i])
    end if
  end for
  return nm
end function

function fastmap_set(mapv, key, value)
  m = mapv
  if _fm_is_valid(m) == false then m = fastmap_new(64) end if
  if (m.size + 1) * 10 >= m.cap * 7 then
    m = _fm_rehash(m, m.cap * 2)
  end if
  return _fm_insert_no_resize(m, key, value)
end function

function fastmap_get(mapv, key, defaultv)
  if _fm_is_valid(mapv) == false then return defaultv end if
  p = _fm_probe_slot(mapv, key)
  idx = p[0]
  found = p[1]
  if idx < 0 or found == false then return defaultv end if
  return mapv.values[idx]
end function

function fastmap_has(mapv, key)
  if _fm_is_valid(mapv) == false then return false end if
  p = _fm_probe_slot(mapv, key)
  return p[0] >= 0 and p[1]
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
    if mapv.used[i] != 0 then
      out_b = arr_chunk_push(out_b, [mapv.keys[i], mapv.values[i]])
    end if
  end for
  return arr_chunk_finish(out_b)
end function

function align_up(n, a)
  return (n +(a - 1)) & ~(a - 1)
end function

function align_to_mod(n, mod, target)
  r = n % mod
  pad = (target - r) % mod
  return n + pad
end function

function u16(x)
  b = bytes(2, 0)
  v = x & 0xFFFF
  b[0] = v & 0xFF
  b[1] =(v >> 8) & 0xFF
  return b
end function

function u32(x)
  b = bytes(4, 0)
  v = x & 0xFFFFFFFF
  b[0] = v & 0xFF
  b[1] =(v >> 8) & 0xFF
  b[2] =(v >> 16) & 0xFF
  b[3] =(v >> 24) & 0xFF
  return b
end function

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

function enc_int(x)
  return ((x << 3) & _u64_mask()) | c.TAG_INT
end function

function enc_bool(b)
  if b then
    return ((1 << 3) & _u64_mask()) | c.TAG_BOOL
  end if
  return c.TAG_BOOL
end function

function enc_void()
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
  outv = []
  if typeof(n) != "int" or n <= 0 then return outv end if
  blk = [fill]
  pows = []
  while len(blk) <= n
    pows = pows + [blk]
    blk = blk + blk
  end while

  rem = n
  i = len(pows) - 1
  while i >= 0
    b = pows[i]
    if len(b) <= rem then
      outv = outv + b
      rem = rem - len(b)
      if rem <= 0 then return outv end if
    end if
    i = i - 1
  end while
  return outv
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

  parts = []
  blk = []
  blk_cap = 256
  for i = 0 to n - 1
    blk = blk + [_arr_unwrap_value(tail.data[i])]
    if len(blk) >= blk_cap then
      parts = parts + [blk]
      blk = []
    end if
  end for
  if len(blk) > 0 then
    parts = parts + [blk]
  end if
  return arr_merge_chunks_balanced(parts)
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
  return arr_merge_chunks_balanced([flat, tail_arr])
end function

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
  if t.cap != ccap then
    if t.used > 0 then
      chunks = _chunks_push_chunk(chunks, _arr_tail_to_array(t))
    end if
    t = _arr_tail_new(ccap)
  end if

  if t.used >= ccap then
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
  curr = chunks
  while len(curr) > 1
    next_n = len(curr) >> 1
    if (len(curr) & 1) == 1 then next_n = next_n + 1 end if
    next = _arr_fill(next_n, [])
    ni = 0
    i = 0
    while i < len(curr)
      if i + 1 < len(curr) then
        next[ni] = curr[i] + curr[i + 1]
        i = i + 2
      else
        next[ni] = curr[i]
        i = i + 1
      end if
      ni = ni + 1
    end while
    curr = next
  end while
  return curr[0]
end function

function arr_chunked_finish(chunks, tail)
  all = _chunks_materialize(chunks)
  tail_arr = _arr_tail_to_array(tail)
  if typeof(tail_arr) == "array" and len(tail_arr) > 0 then
    all = all + [tail_arr]
  end if
  if typeof(all) == "array" and len(all) == 1 and typeof(all[0]) == "array" then
    return all[0]
  end if
  return arr_merge_chunks_balanced(all)
end function

function arr_chunk_finish(builder)
  b = builder
  if typeof(b) != "struct" then return [] end if
  return arr_chunked_finish(b.chunks, b.tail)
end function

function arr_chunk_push_all(builder, values)
  b = builder
  if typeof(values) != "array" or len(values) <= 0 then return b end if
  for i = 0 to len(values) - 1
    b = arr_chunk_push(b, values[i])
  end for
  return b
end function

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
