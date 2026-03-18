package mlc.asm
import mlc.tools as t

struct AsmPatch
  pos,
  target,
  kind,
end struct

struct AsmLabel
  name,
  pos,
end struct

struct AsmBuilder
  buf,
  size,
  labels,
  labels_chunks,
  labels_tail,
  patches_chunks,
  patches_tail,
  calls_chunks,
  calls_tail,
  chunk_pages,
  chunk_tail,
  chunk_size,
  buf_valid,
end struct

struct EncMem
  rex_x,
  rex_b,
  tail,
end struct

function newAsmBuilder()
  cs = 65536
  return AsmBuilder(bytes(0), 0, [], [], [], [], [], [], [], [], [bytes(cs, 0)], cs, false)
end function

function get_patches(asm)
  return t.arr_chunked_finish(asm.patches_chunks, asm.patches_tail)
end function

function get_calls(asm)
  return t.arr_chunked_finish(asm.calls_chunks, asm.calls_tail)
end function

function get_labels(asm)
  if typeof(asm.labels) == "array" and len(asm.labels) > 0 then
    return asm.labels
  end if
  return t.arr_chunked_finish(asm.labels_chunks, asm.labels_tail)
end function

function clear_calls(asm)
  asm.calls_chunks = []
  asm.calls_tail = []
  return asm
end function

function _patch_push(asm, patch)
  app = t.arr_chunked_push(asm.patches_chunks, asm.patches_tail, patch, 256)
  asm.patches_chunks = app[0]
  asm.patches_tail = app[1]
  return asm
end function

function _call_push(asm, label)
  app = t.arr_chunked_push(asm.calls_chunks, asm.calls_tail, label, 256)
  asm.calls_chunks = app[0]
  asm.calls_tail = app[1]
  return asm
end function

function _label_push(asm, label)
  app = t.arr_chunked_push(asm.labels_chunks, asm.labels_tail, label, 256)
  asm.labels_chunks = app[0]
  asm.labels_tail = app[1]
  return asm
end function

function _label_index(labels, name)
  if len(labels) <= 0 then return -1 end if
  for i = 0 to len(labels) - 1
    if labels[i].name == name then return i end if
  end for
  return -1
end function

function _label_pos(labels, name)
  idx = _label_index(labels, name)
  if idx < 0 then return -1 end if
  return labels[idx].pos
end function

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

function _chunk_count(asm)
  n = 0
  if typeof(asm.chunk_pages) == "array" then n = n + (len(asm.chunk_pages) << 8) end if
  n = n + t.arr_chunk_tail_len(asm.chunk_tail)
  return n
end function

function _chunk_get(asm, idx)
  pi = idx >> 8
  po = idx & 0xFF
  if pi < len(asm.chunk_pages) then
    pg = asm.chunk_pages[pi]
    return pg[po]
  end if
  ti = idx - (len(asm.chunk_pages) << 8)
  return t.arr_chunk_tail_get(asm.chunk_tail, ti, bytes(asm.chunk_size, 0))
end function

function _chunk_set(asm, idx, chunk)
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

function _chunk_push(asm, chunk)
  app = t.arr_chunked_push(asm.chunk_pages, asm.chunk_tail, chunk, 256)
  asm.chunk_pages = app[0]
  asm.chunk_tail = app[1]
  return asm
end function

function _ensure_capacity(asm, need)
  if need <= 0 then return asm end if
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

function _set_chunk_byte(asm, idx, value)
  ci = idx >> 16
  off = idx & 0xFFFF
  ch = _chunk_get(asm, ci)
  ch[off] = value & 0xFF
  asm = _chunk_set(asm, ci, ch)
  return asm
end function

function _materialize_buffer(asm)
  if typeof(asm.buf) == "bytes" and asm.buf_valid and len(asm.buf) == asm.size then
    return asm
  end if
  if asm.size <= 0 then
    asm.buf = bytes(0)
    asm.buf_valid = true
    return asm
  end if

  asm = _ensure_capacity(asm, asm.size)
  buf_out = bytes(asm.size, 0)
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
  return asm
end function

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

function _emit8(asm, x)
  need = asm.size + 1
  asm = _ensure_capacity(asm, need)
  asm = _set_chunk_byte(asm, asm.size, x)
  asm.size = need
  asm.buf_valid = false
  return asm
end function

function materialize(asm)
  return _materialize_buffer(asm)
end function

function _emit32(asm, x)
  return _emit(asm, t.u32(x))
end function

function _emit64(asm, x)
  return _emit(asm, t.u64(x))
end function

function pos(asm)
  return asm.size
end function

function _emit_rex(asm, w, r, x, b, force)
  if (w | r | x | b) == 0 and force == false then
    return asm
  end if
  v = 0x40 |((w & 1) << 3) |((r & 1) << 2) |((x & 1) << 1) |(b & 1)
  return _emit8(asm, v)
end function

function _emit_modrm(asm, mod, reg, rm)
  v = ((mod & 3) << 6) |((reg & 7) << 3) |(rm & 7)
  return _emit8(asm, v)
end function

function _modrm_byte(mod, reg, rm)
  return ((mod & 3) << 6) |((reg & 7) << 3) |(rm & 7)
end function

function _sib_byte(scale, index, base)
  return ((scale & 3) << 6) |((index & 7) << 3) |(base & 7)
end function

function _fits_i8(x)
  return x >= -128 and x <= 127
end function

function _emit_bytes_u8(v)
  b = bytes(1, 0)
  b[0] = v & 0xFF
  return b
end function

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

function _scale_bits(scale)
  if scale == 1 then return 0 end if
  if scale == 2 then return 1 end if
  if scale == 4 then return 2 end if
  if scale == 8 then return 3 end if
  return 0
end function

function _encode_mem_bis(reg_field, base_id, index_id, scale, disp)
  base_lo = base_id & 7
  idx_lo = index_id & 7
  rex_b = 0
  if base_id >= 8 then rex_b = 1 end if
  rex_x = 0
  if index_id >= 8 then rex_x = 1 end if
  if idx_lo == 4 then idx_lo = 0 end if

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

function emit(asm, b)
  return _emit(asm, b)
end function

function emit8(asm, x)
  return _emit8(asm, x)
end function

function emit32(asm, x)
  return _emit32(asm, x)
end function

function emit64(asm, x)
  return _emit64(asm, x)
end function

function mark(asm, name)
  asm.labels = []
  asm = _label_push(asm, AsmLabel(name, pos(asm)))
  return asm
end function

function finalize(asm)
  labels = get_labels(asm)
  if typeof(labels) != "array" then labels = [] end if
  asm.labels = labels
  patches = get_patches(asm)
  if len(patches) > 0 then
    asm.buf_valid = false
    for i = 0 to len(patches) - 1
      p = patches[i]
      tgt = _label_pos(labels, p.target)
      if tgt < 0 then
        continue
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

function nop(asm)
  return _emit8(asm, 0x90)
end function

function jmp(asm, label)
  asm = _emit8(asm, 0xE9)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rel32"))
  return asm
end function

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
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, op)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rel32"))
  return asm
end function

function je(asm, label) return jcc(asm, "e", label) end function
function jz(asm, label) return jcc(asm, "z", label) end function
function jne(asm, label) return jcc(asm, "ne", label) end function
function jnz(asm, label) return jcc(asm, "nz", label) end function
function jl(asm, label) return jcc(asm, "l", label) end function
function jle(asm, label) return jcc(asm, "le", label) end function
function jg(asm, label) return jcc(asm, "g", label) end function
function jge(asm, label) return jcc(asm, "ge", label) end function
function jb(asm, label) return jcc(asm, "b", label) end function
function jbe(asm, label) return jcc(asm, "be", label) end function
function ja(asm, label) return jcc(asm, "a", label) end function
function jae(asm, label) return jcc(asm, "ae", label) end function

function call(asm, label)
  asm = _emit8(asm, 0xE8)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rel32"))
  if typeof(label) == "string" then
    asm = _call_push(asm, label)
  end if
  return asm
end function

function call_rax(asm)
  asm = _emit8(asm, 0xFF)
  asm = _emit8(asm, 0xD0)
  return asm
end function

function ret(asm)
  return _emit8(asm, 0xC3)
end function

function leave(asm)
  return _emit8(asm, 0xC9)
end function

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

function lea_rax_rip(asm, label)
  return lea_r64_rip(asm, "rax", label)
end function

function lea_rdx_rip(asm, label)
  return lea_r64_rip(asm, "rdx", label)
end function

function lea_r8_rip(asm, label)
  return lea_r64_rip(asm, "r8", label)
end function

function lea_r9_rip(asm, label)
  return lea_r64_rip(asm, "r9", label)
end function

function lea_r11_rip(asm, label)
  return lea_r64_rip(asm, "r11", label)
end function

function push_reg(asm, reg)
  rid = _rid_any(reg)
  if rid < 0 then return asm end if
  if rid >= 8 then
    asm = _emit8(asm, 0x41)
  end if
  asm = _emit8(asm, 0x50 +(rid & 7))
  return asm
end function

function pop_reg(asm, reg)
  rid = _rid_any(reg)
  if rid < 0 then return asm end if
  if rid >= 8 then
    asm = _emit8(asm, 0x41)
  end if
  asm = _emit8(asm, 0x58 +(rid & 7))
  return asm
end function

function push_rbx(asm) return push_reg(asm, "rbx") end function
function pop_rbx(asm) return pop_reg(asm, "rbx") end function
function push_r12(asm) return push_reg(asm, "r12") end function
function pop_r12(asm) return pop_reg(asm, "r12") end function
function push_r13(asm) return push_reg(asm, "r13") end function
function pop_r13(asm) return pop_reg(asm, "r13") end function
function push_r14(asm) return push_reg(asm, "r14") end function
function pop_r14(asm) return pop_reg(asm, "r14") end function
function push_r15(asm) return push_reg(asm, "r15") end function
function pop_r15(asm) return pop_reg(asm, "r15") end function
function push_rbp(asm) return push_reg(asm, "rbp") end function
function pop_rbp(asm) return pop_reg(asm, "rbp") end function

function mov_rbp_rsp(asm)
  return mov_r64_r64(asm, "rbp", "rsp")
end function

function mov_r64_imm64(asm, dst, imm)
  rd = _rid_any(dst)
  if rd < 0 then return asm end if
  asm = _emit_rex(asm, 1, 0, 0, (rd >> 3) & 1, false)
  asm = _emit8(asm, 0xB8 +(rd & 7))
  asm = _emit64(asm, imm)
  return asm
end function

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

function mov_rax_imm64(asm, imm)
  return mov_r64_imm64(asm, "rax", imm)
end function

function mov_rcx_imm32(asm, imm)
  return mov_r32_imm32(asm, "ecx", imm)
end function

function mov_r8d_imm32(asm, imm)
  return mov_r32_imm32(asm, "r8d", imm)
end function

function mov_r64_r64(asm, dst, src)
  rd = _rid_any(dst)
  rs = _rid_any(src)
  if rd < 0 or rs < 0 then return asm end if
  asm = _emit_rex(asm, 1, (rs >> 3) & 1, 0, (rd >> 3) & 1, false)
  asm = _emit8(asm, 0x89)
  asm = _emit_modrm(asm, 3, rs & 7, rd & 7)
  return asm
end function

function mov_r32_r32(asm, dst, src)
  rd = _rid_any(dst)
  rs = _rid_any(src)
  if rd < 0 or rs < 0 then return asm end if
  asm = _emit_rex(asm, 0, (rs >> 3) & 1, 0, (rd >> 3) & 1, false)
  asm = _emit8(asm, 0x89)
  asm = _emit_modrm(asm, 3, rs & 7, rd & 7)
  return asm
end function

function mov_r8_r8(asm, dst, src)
  rd = _rid_any(dst)
  rs = _rid_any(src)
  if rd < 0 or rs < 0 then return asm end if
  force = false
  if dst == "spl" or dst == "bpl" or dst == "sil" or dst == "dil" then force = true end if
  if src == "spl" or src == "bpl" or src == "sil" or src == "dil" then force = true end if
  asm = _emit_rex(asm, 0, (rs >> 3) & 1, 0, (rd >> 3) & 1, force)
  asm = _emit8(asm, 0x88)
  asm = _emit_modrm(asm, 3, rs & 7, rd & 7)
  return asm
end function

function _grp1_imm(asm, reg_name, subop, imm, w, imm8)
  rd = _rid_any(reg_name)
  if rd < 0 then return asm end if
  asm = _emit_rex(asm, w, 0, 0, (rd >> 3) & 1, false)

  if imm8 then
    asm = _emit8(asm, 0x83)
    asm = _emit_modrm(asm, 3, subop, rd & 7)
    asm = _emit8(asm, imm)
    return asm
  end if

  if subop == 0 and(rd & 7) == 0 then
    asm = _emit8(asm, 0x05)
    asm = _emit32(asm, imm)
    return asm
  end if
  asm = _emit8(asm, 0x81)
  asm = _emit_modrm(asm, 3, subop, rd & 7)
  asm = _emit32(asm, imm)
  return asm
end function

function add_r64_imm(asm, reg_name, imm) return _grp1_imm(asm, reg_name, 0, imm, 1, false) end function
function sub_r64_imm(asm, reg_name, imm) return _grp1_imm(asm, reg_name, 5, imm, 1, false) end function
function and_r64_imm(asm, reg_name, imm) return _grp1_imm(asm, reg_name, 4, imm, 1, false) end function
function or_r64_imm(asm, reg_name, imm) return _grp1_imm(asm, reg_name, 1, imm, 1, false) end function
function xor_r64_imm(asm, reg_name, imm) return _grp1_imm(asm, reg_name, 6, imm, 1, false) end function
function cmp_r64_imm(asm, reg_name, imm) return _grp1_imm(asm, reg_name, 7, imm, 1, false) end function

function add_r64_imm8(asm, reg_name, imm) return _grp1_imm(asm, reg_name, 0, imm, 1, true) end function
function sub_r64_imm8(asm, reg_name, imm) return _grp1_imm(asm, reg_name, 5, imm, 1, true) end function
function and_r64_imm8(asm, reg_name, imm) return _grp1_imm(asm, reg_name, 4, imm, 1, true) end function
function or_r64_imm8(asm, reg_name, imm) return _grp1_imm(asm, reg_name, 1, imm, 1, true) end function
function xor_r64_imm8(asm, reg_name, imm) return _grp1_imm(asm, reg_name, 6, imm, 1, true) end function
function cmp_r64_imm8(asm, reg_name, imm) return _grp1_imm(asm, reg_name, 7, imm, 1, true) end function

function add_r32_imm(asm, reg_name, imm) return _grp1_imm(asm, reg_name, 0, imm, 0, false) end function
function sub_r32_imm(asm, reg_name, imm) return _grp1_imm(asm, reg_name, 5, imm, 0, false) end function
function and_r32_imm(asm, reg_name, imm) return _grp1_imm(asm, reg_name, 4, imm, 0, false) end function
function or_r32_imm(asm, reg_name, imm) return _grp1_imm(asm, reg_name, 1, imm, 0, false) end function
function xor_r32_imm(asm, reg_name, imm) return _grp1_imm(asm, reg_name, 6, imm, 0, false) end function
function cmp_r32_imm(asm, reg_name, imm) return _grp1_imm(asm, reg_name, 7, imm, 0, false) end function
function cmp_r32_imm32(asm, reg_name, imm) return _grp1_imm(asm, reg_name, 7, imm, 0, false) end function
function cmp_r64_imm32(asm, reg_name, imm) return _grp1_imm(asm, reg_name, 7, imm, 1, false) end function

function _emit_bin_rr(asm, op, dst, src, w)
  rd = _rid_any(dst)
  rs = _rid_any(src)
  if rd < 0 or rs < 0 then return asm end if
  asm = _emit_rex(asm, w, (rs >> 3) & 1, 0, (rd >> 3) & 1, false)
  asm = _emit8(asm, op)
  asm = _emit_modrm(asm, 3, rs & 7, rd & 7)
  return asm
end function

function add_r64_r64(asm, dst, src) return _emit_bin_rr(asm, 0x01, dst, src, 1) end function
function sub_r64_r64(asm, dst, src) return _emit_bin_rr(asm, 0x29, dst, src, 1) end function
function add_r32_r32(asm, dst, src) return _emit_bin_rr(asm, 0x01, dst, src, 0) end function
function sub_r32_r32(asm, dst, src) return _emit_bin_rr(asm, 0x29, dst, src, 0) end function
function xor_r64_r64(asm, dst, src) return _emit_bin_rr(asm, 0x31, dst, src, 1) end function
function xor_r32_r32(asm, dst, src) return _emit_bin_rr(asm, 0x31, dst, src, 0) end function
function and_r64_r64(asm, dst, src) return _emit_bin_rr(asm, 0x21, dst, src, 1) end function
function or_r64_r64(asm, dst, src) return _emit_bin_rr(asm, 0x09, dst, src, 1) end function
function and_r8_r8(asm, dst, src) return _emit_bin_rr(asm, 0x20, dst, src, 0) end function
function or_r8_r8(asm, dst, src) return _emit_bin_rr(asm, 0x08, dst, src, 0) end function

function cmp_r64_r64(asm, left, right) return _emit_bin_rr(asm, 0x39, left, right, 1) end function
function cmp_r32_r32(asm, left, right) return _emit_bin_rr(asm, 0x39, left, right, 0) end function
function test_r64_r64(asm, left, right) return _emit_bin_rr(asm, 0x85, left, right, 1) end function
function test_r32_r32(asm, left, right) return _emit_bin_rr(asm, 0x85, left, right, 0) end function

function test_r8_r8(asm, left, right)
  return _emit_bin_rr(asm, 0x84, left, right, 0)
end function

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
  if op < 0 then return asm end if
  rd = _rid_any(dst8)
  if rd < 0 then return asm end if
  force = false
  if dst8 == "spl" or dst8 == "bpl" or dst8 == "sil" or dst8 == "dil" then force = true end if
  asm = _emit_rex(asm, 0, 0, 0, (rd >> 3) & 1, force)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, op)
  asm = _emit_modrm(asm, 3, 0, rd & 7)
  return asm
end function

function setcc_al(asm, cc)
  return setcc_r8(asm, cc, "al")
end function

function movzx_r32_r8(asm, dst, src8)
  rd = _rid_any(dst)
  rs = _rid_any(src8)
  if rd < 0 or rs < 0 then return asm end if
  force = false
  if src8 == "spl" or src8 == "bpl" or src8 == "sil" or src8 == "dil" then force = true end if
  asm = _emit_rex(asm, 0, (rd >> 3) & 1, 0, (rs >> 3) & 1, force)
  asm = _emit8(asm, 0x0F)
  asm = _emit8(asm, 0xB6)
  asm = _emit_modrm(asm, 3, rd & 7, rs & 7)
  return asm
end function

function movzx_eax_al(asm)
  return movzx_r32_r8(asm, "eax", "al")
end function

function mov_rbx_rax(asm) return mov_r64_r64(asm, "rbx", "rax") end function
function mov_rcx_rbx(asm) return mov_r64_r64(asm, "rcx", "rbx") end function
function mov_rdx_rax(asm) return mov_r64_r64(asm, "rdx", "rax") end function
function mov_r10_rax(asm) return mov_r64_r64(asm, "r10", "rax") end function
function mov_r11_rax(asm) return mov_r64_r64(asm, "r11", "rax") end function
function mov_rax_r10(asm) return mov_r64_r64(asm, "rax", "r10") end function
function mov_rax_r11(asm) return mov_r64_r64(asm, "rax", "r11") end function

function add_rax_r10(asm) return add_r64_r64(asm, "rax", "r10") end function
function sub_rax_r11(asm) return sub_r64_r64(asm, "rax", "r11") end function
function add_rax_imm8(asm, imm) return add_r64_imm8(asm, "rax", imm) end function
function sub_rax_imm8(asm, imm) return sub_r64_imm8(asm, "rax", imm) end function
function and_rax_imm8(asm, imm) return and_r64_imm8(asm, "rax", imm) end function
function or_rax_imm8(asm, imm) return or_r64_imm8(asm, "rax", imm) end function

function _emit_shift_imm8(asm, subop, reg_name, imm, w)
  rd = _rid_any(reg_name)
  if rd < 0 then return asm end if
  asm = _emit_rex(asm, w, 0, 0, (rd >> 3) & 1, false)
  asm = _emit8(asm, 0xC1)
  asm = _emit_modrm(asm, 3, subop, rd & 7)
  asm = _emit8(asm, imm)
  return asm
end function

function shl_r64_imm8(asm, reg_name, imm) return _emit_shift_imm8(asm, 4, reg_name, imm, 1) end function
function shr_r64_imm8(asm, reg_name, imm) return _emit_shift_imm8(asm, 5, reg_name, imm, 1) end function
function sar_r64_imm8(asm, reg_name, imm) return _emit_shift_imm8(asm, 7, reg_name, imm, 1) end function
function shl_r32_imm8(asm, reg_name, imm) return _emit_shift_imm8(asm, 4, reg_name, imm, 0) end function
function sar_r32_imm8(asm, reg_name, imm) return _emit_shift_imm8(asm, 7, reg_name, imm, 0) end function

function sar_rax_imm8(asm, imm) return sar_r64_imm8(asm, "rax", imm) end function
function shl_rax_imm8(asm, imm) return shl_r64_imm8(asm, "rax", imm) end function

function neg_r64(asm, reg_name)
  rd = _rid_any(reg_name)
  if rd < 0 then return asm end if
  asm = _emit_rex(asm, 1, 0, 0, (rd >> 3) & 1, false)
  asm = _emit8(asm, 0xF7)
  asm = _emit_modrm(asm, 3, 3, rd & 7)
  return asm
end function

function neg_rax(asm)
  return neg_r64(asm, "rax")
end function

function cmp_rax_r10(asm)
  return cmp_r64_r64(asm, "rax", "r10")
end function

function cmp_rax_imm8(asm, imm)
  return cmp_r64_imm8(asm, "rax", imm)
end function

function cmp_rax_imm32(asm, imm)
  return cmp_r64_imm(asm, "rax", imm)
end function

function test_rax_imm32(asm, imm)
  rd = _rid_any("rax")
  asm = _emit_rex(asm, 1, 0, 0, (rd >> 3) & 1, false)
  asm = _emit8(asm, 0xF7)
  asm = _emit_modrm(asm, 3, 0, rd & 7)
  asm = _emit32(asm, imm)
  return asm
end function

function xor_ecx_ecx(asm)
  return xor_r32_r32(asm, "ecx", "ecx")
end function

function xor_eax_eax(asm)
  return xor_r32_r32(asm, "eax", "eax")
end function

function add_rcx_imm8(asm, imm)
  return add_r64_imm8(asm, "rcx", imm)
end function

function add_rcx_imm32(asm, imm)
  return add_r64_imm(asm, "rcx", imm)
end function

function sub_rsp_imm8(asm, imm)
  if imm == 0 then return asm end if
  return sub_r64_imm(asm, "rsp", imm)
end function

function add_rsp_imm8(asm, imm)
  if imm == 0 then return asm end if
  return add_r64_imm(asm, "rsp", imm)
end function

function sub_rsp_imm32(asm, imm)
  return sub_rsp_imm8(asm, imm)
end function

function add_rsp_imm32(asm, imm)
  return add_rsp_imm8(asm, imm)
end function

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

function mov_r8_membase_disp(asm, dst, base, disp)
  d = _rid_any(dst)
  b = _rid_any(base)
  if d < 0 or b < 0 then return asm end if
  force = false
  if dst == "spl" or dst == "bpl" or dst == "sil" or dst == "dil" then force = true end if
  enc = _encode_mem(d & 7, b, disp)
  rex_r = 0
  if d >= 8 then rex_r = 1 end if
  asm = _emit_rex(asm, 0, rex_r, enc.rex_x, enc.rex_b, force)
  asm = _emit8(asm, 0x8A)
  asm = _emit(asm, enc.tail)
  return asm
end function

function mov_membase_disp_r8(asm, base, disp, src)
  sreg = _rid_any(src)
  b = _rid_any(base)
  if sreg < 0 or b < 0 then return asm end if
  force = false
  if src == "spl" or src == "bpl" or src == "sil" or src == "dil" then force = true end if
  enc = _encode_mem(sreg & 7, b, disp)
  rex_r = 0
  if sreg >= 8 then rex_r = 1 end if
  asm = _emit_rex(asm, 0, rex_r, enc.rex_x, enc.rex_b, force)
  asm = _emit8(asm, 0x88)
  asm = _emit(asm, enc.tail)
  return asm
end function

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

function mov_rax_rsp_disp8(asm, disp)
  return mov_r64_membase_disp(asm, "rax", "rsp", disp)
end function

function mov_rsp_disp8_rax(asm, disp)
  return mov_membase_disp_r64(asm, "rsp", disp, "rax")
end function

function mov_rax_rsp_disp32(asm, disp)
  return mov_r64_membase_disp(asm, "rax", "rsp", disp)
end function

function mov_rsp_disp32_rax(asm, disp)
  return mov_membase_disp_r64(asm, "rsp", disp, "rax")
end function

function _grp1_r8_imm8(asm, subop, reg8, imm)
  r = _rid_any(reg8)
  if r < 0 then return asm end if
  force = false
  if reg8 == "spl" or reg8 == "bpl" or reg8 == "sil" or reg8 == "dil" then force = true end if
  asm = _emit_rex(asm, 0, 0, 0, (r >> 3) & 1, force)
  asm = _emit8(asm, 0x80)
  asm = _emit_modrm(asm, 3, subop, r & 7)
  asm = _emit8(asm, imm)
  return asm
end function

function and_r8_imm8(asm, reg8, imm) return _grp1_r8_imm8(asm, 4, reg8, imm) end function
function or_r8_imm8(asm, reg8, imm) return _grp1_r8_imm8(asm, 1, reg8, imm) end function
function xor_r8_imm8(asm, reg8, imm) return _grp1_r8_imm8(asm, 6, reg8, imm) end function
function add_r8_imm8(asm, reg8, imm) return _grp1_r8_imm8(asm, 0, reg8, imm) end function
function sub_r8_imm8(asm, reg8, imm) return _grp1_r8_imm8(asm, 5, reg8, imm) end function

function cmp_r8_imm8(asm, reg8, imm)
  if imm == 0 then
    return test_r8_r8(asm, reg8, reg8)
  end if
  return _grp1_r8_imm8(asm, 7, reg8, imm)
end function

function test_r64_imm32(asm, reg_name, imm)
  r = _rid_any(reg_name)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 1, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xF7)
  asm = _emit_modrm(asm, 3, 0, r & 7)
  asm = _emit32(asm, imm)
  return asm
end function

function cmp_r8_membase_disp(asm, reg8, base, disp)
  r = _rid_any(reg8)
  b = _rid_any(base)
  if r < 0 or b < 0 then return asm end if
  force = false
  if reg8 == "spl" or reg8 == "bpl" or reg8 == "sil" or reg8 == "dil" then force = true end if
  enc = _encode_mem(r & 7, b, disp)
  rex_r = 0
  if r >= 8 then rex_r = 1 end if
  asm = _emit_rex(asm, 0, rex_r, enc.rex_x, enc.rex_b, force)
  asm = _emit8(asm, 0x3A)
  asm = _emit(asm, enc.tail)
  return asm
end function

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

function movzx_r32_membase_disp(asm, dst32, base, disp)
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

function inc_r64(asm, reg_name)
  r = _rid_any(reg_name)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 1, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xFF)
  asm = _emit_modrm(asm, 3, 0, r & 7)
  return asm
end function

function dec_r64(asm, reg_name)
  r = _rid_any(reg_name)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 1, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xFF)
  asm = _emit_modrm(asm, 3, 1, r & 7)
  return asm
end function

function inc_r32(asm, reg_name)
  r = _rid_any(reg_name)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 0, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xFF)
  asm = _emit_modrm(asm, 3, 0, r & 7)
  return asm
end function

function dec_r32(asm, reg_name)
  r = _rid_any(reg_name)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 0, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xFF)
  asm = _emit_modrm(asm, 3, 1, r & 7)
  return asm
end function

function inc_membase_disp_qword(asm, base, disp)
  b = _rid_any(base)
  if b < 0 then return asm end if
  enc = _encode_mem(0, b, disp)
  asm = _emit_rex(asm, 1, 0, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0xFF)
  asm = _emit(asm, enc.tail)
  return asm
end function

function dec_membase_disp_qword(asm, base, disp)
  b = _rid_any(base)
  if b < 0 then return asm end if
  enc = _encode_mem(1, b, disp)
  asm = _emit_rex(asm, 1, 0, enc.rex_x, enc.rex_b, false)
  asm = _emit8(asm, 0xFF)
  asm = _emit(asm, enc.tail)
  return asm
end function

function mov_r9d_imm32(asm, imm)
  return mov_r32_imm32(asm, "r9d", imm)
end function

function mov_r8d_edx(asm)
  return mov_r32_r32(asm, "r8d", "edx")
end function

function mov_qword_ptr_rsp20_rax_zero(asm)
  asm = xor_r32_r32(asm, "eax", "eax")
  asm = mov_membase_disp_r64(asm, "rsp", 0x20, "rax")
  return asm
end function

function mov_eax_rip_dword(asm, label)
  asm = _emit8(asm, 0x8B)
  asm = _emit8(asm, 0x05)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rip32"))
  return asm
end function

function mov_rip_dword_eax(asm, label)
  asm = _emit8(asm, 0x89)
  asm = _emit8(asm, 0x05)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rip32"))
  return asm
end function

function mov_rax_rip_qword(asm, label)
  asm = _emit_rex(asm, 1, 0, 0, 0, false)
  asm = _emit8(asm, 0x8B)
  asm = _emit8(asm, 0x05)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rip32"))
  return asm
end function

function mov_rdx_rip_qword(asm, label)
  asm = _emit_rex(asm, 1, 0, 0, 0, false)
  asm = _emit8(asm, 0x8B)
  asm = _emit8(asm, 0x15)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rip32"))
  return asm
end function

function mov_rip_qword_rax(asm, label)
  asm = _emit_rex(asm, 1, 0, 0, 0, false)
  asm = _emit8(asm, 0x89)
  asm = _emit8(asm, 0x05)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rip32"))
  return asm
end function

function mov_rip_qword_rdx(asm, label)
  asm = _emit_rex(asm, 1, 0, 0, 0, false)
  asm = _emit8(asm, 0x89)
  asm = _emit8(asm, 0x15)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rip32"))
  return asm
end function

function mov_rip_qword_r11(asm, label)
  asm = _emit_rex(asm, 1, 1, 0, 0, false)
  asm = _emit8(asm, 0x89)
  asm = _emit8(asm, 0x1D)
  p = pos(asm)
  asm = _emit32(asm, 0)
  asm = _patch_push(asm, AsmPatch(p, label, "rip32"))
  return asm
end function

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

function shl_r64_cl(asm, reg_name)
  r = _rid_any(reg_name)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 1, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xD3)
  asm = _emit_modrm(asm, 3, 4, r & 7)
  return asm
end function

function shr_r64_cl(asm, reg_name)
  r = _rid_any(reg_name)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 1, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xD3)
  asm = _emit_modrm(asm, 3, 5, r & 7)
  return asm
end function

function sar_r64_cl(asm, reg_name)
  r = _rid_any(reg_name)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 1, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xD3)
  asm = _emit_modrm(asm, 3, 7, r & 7)
  return asm
end function

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

function imul_r64_r64_imm(asm, dst, src, imm)
  d = _rid_any(dst)
  sreg = _rid_any(src)
  if d < 0 or sreg < 0 then return asm end if
  asm = _emit_rex(asm, 1, (d >> 3) & 1, 0, (sreg >> 3) & 1, false)
  asm = _emit8(asm, 0x69)
  asm = _emit_modrm(asm, 3, d & 7, sreg & 7)
  asm = _emit32(asm, imm)
  return asm
end function

function cqo(asm)
  asm = _emit_rex(asm, 1, 0, 0, 0, false)
  asm = _emit8(asm, 0x99)
  return asm
end function

function idiv_r64(asm, reg_name)
  r = _rid_any(reg_name)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 1, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xF7)
  asm = _emit_modrm(asm, 3, 7, r & 7)
  return asm
end function

function div_r64(asm, reg_name)
  r = _rid_any(reg_name)
  if r < 0 then return asm end if
  asm = _emit_rex(asm, 1, 0, 0, (r >> 3) & 1, false)
  asm = _emit8(asm, 0xF7)
  asm = _emit_modrm(asm, 3, 6, r & 7)
  return asm
end function

function rep_movsb(asm)
  asm = _emit8(asm, 0xF3)
  asm = _emit8(asm, 0xA4)
  return asm
end function

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

function movsd_xmm_xmm(asm, dst_xmm, src_xmm)
  return _emit_sse_rr(asm, 0xF2, -1, 0x10, dst_xmm, src_xmm)
end function

function addsd_xmm_xmm(asm, dst_xmm, src_xmm)
  return _emit_sse_rr(asm, 0xF2, -1, 0x58, dst_xmm, src_xmm)
end function

function subsd_xmm_xmm(asm, dst_xmm, src_xmm)
  return _emit_sse_rr(asm, 0xF2, -1, 0x5C, dst_xmm, src_xmm)
end function

function mulsd_xmm_xmm(asm, dst_xmm, src_xmm)
  return _emit_sse_rr(asm, 0xF2, -1, 0x59, dst_xmm, src_xmm)
end function

function divsd_xmm_xmm(asm, dst_xmm, src_xmm)
  return _emit_sse_rr(asm, 0xF2, -1, 0x5E, dst_xmm, src_xmm)
end function

function ucomisd_xmm_xmm(asm, left_xmm, right_xmm)
  return _emit_sse_rr(asm, 0x66, -1, 0x2E, left_xmm, right_xmm)
end function

function xorpd_xmm_xmm(asm, dst_xmm, src_xmm)
  return _emit_sse_rr(asm, 0x66, -1, 0x57, dst_xmm, src_xmm)
end function

function movapd_xmm_xmm(asm, dst_xmm, src_xmm)
  return _emit_sse_rr(asm, 0x66, -1, 0x28, dst_xmm, src_xmm)
end function

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

function _peephole_trim_tail(asm, n)
  return asm
end function

function enable_listing(asm, path, show_addr, show_bytes, show_text)
  return asm
end function

function disable_listing(asm)
  return asm
end function

function gpr(name)
  return _rid_any(name)
end function

function _rex(w, r, x, b, force)
  if (w | r | x | b) == 0 and force == false then
    return bytes(0)
  end if
  return _emit_bytes_u8(0x40 |((w & 1) << 3) |((r & 1) << 2) |((x & 1) << 1) |(b & 1))
end function

function _modrm(mod, reg, rm)
  return _emit_bytes_u8(_modrm_byte(mod, reg, rm))
end function

function _sib(scale, index, base)
  return _emit_bytes_u8(_sib_byte(scale, index, base))
end function

function _jcc_mnemonic(cc)
  return cc
end function

function _fmt_disp(disp)
  return ""
end function

function _fmt_mem(base, disp)
  return ""
end function

function _fmt_mem_sib(base, index_reg, scale, disp)
  return ""
end function

function _format_call(name, args, kwargs)
  return ""
end function

function write_listing(asm, path)
  return asm
end function

function emit_placeholder(asm, text)
  return asm
end function
