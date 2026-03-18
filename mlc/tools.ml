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

_arr_void_sentinel = ArrayChunkVoidSentinel(0xA11D)

function _u64_mask()
  // All bits set without a large out-of-range source literal.
  return 0 - 1
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

function arr_chunk_tail_len(tail)
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
  outv = []
  for i = 0 to n - 1
    outv = outv + [_arr_unwrap_value(tail.data[i])]
  end for
  return outv
end function

function arr_chunk_new(cap)
  ccap = cap
  if typeof(ccap) != "int" or ccap <= 0 then ccap = 64 end if
  return ArrayChunkBuilder([], _arr_tail_new(ccap), ccap)
end function

function arr_chunked_push(chunks, tail, value, cap)
  if typeof(chunks) != "array" then chunks = [] end if
  ccap = cap
  if typeof(ccap) != "int" or ccap <= 0 then ccap = 64 end if
  t = tail
  if typeof(t) == "array" then t = _arr_tail_from_array(t, ccap) end if
  if typeof(t) != "struct" or typeof(t.data) != "array" then t = _arr_tail_new(ccap) end if

  if typeof(t.cap) != "int" or t.cap <= 0 then t.cap = ccap end if
  if t.cap != ccap then
    if arr_chunk_tail_len(t) > 0 then
      chunks = chunks + [_arr_tail_to_array(t)]
    end if
    t = _arr_tail_new(ccap)
  end if

  if arr_chunk_tail_len(t) >= ccap then
    chunks = chunks + [_arr_tail_to_array(t)]
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
  all = []
  if typeof(chunks) == "array" and len(chunks) > 0 then
    all = chunks
  end if
  tail_arr = _arr_tail_to_array(tail)
  if typeof(tail_arr) == "array" and len(tail_arr) > 0 then
    all = all + [tail_arr]
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

function _bp_chunk_count(bp)
  n = 0
  if typeof(bp.chunk_pages) == "array" then n = n + (len(bp.chunk_pages) << 8) end if
  n = n + arr_chunk_tail_len(bp.chunk_tail)
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
  return arr_chunk_tail_get(bp.chunk_tail, ti, bytes(65536, 0))
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
