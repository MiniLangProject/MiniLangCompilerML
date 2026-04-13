package mlc.codegen.codegen_builtins_alloc
import mlc.asm as a
import mlc.constants as c
import mlc.codegen.codegen_core as core
import mlc.codegen.codegen_memory as mem
import mlc.tools as t
import mlc.data as d

const INPUT_READ_MAX = 4095

function _emit_addstr_error(state, msg_lbl)
  state.asm = a.lea_rax_rip(state.asm, msg_lbl)
  return state
end function

function _has_label(labels, name)
  if typeof(labels) != "array" or len(labels) <= 0 then return false end if
  for i = 0 to len(labels) - 1
    it = labels[i]
    if typeof(it) == "struct" and it.name == name then return true end if
  end for
  return false
end function

function _enum_variants_of(state, qname)
  arr = state.enum_variants
  if typeof(arr) != "array" or len(arr) <= 0 then return [] end if
  for i = 0 to len(arr) - 1
    it = arr[i]
    if typeof(it) == "struct" and it.key == qname then
      if typeof(it.values) == "array" then return it.values end if
      return []
    end if
    if typeof(it) == "array" and len(it) >= 2 and it[0] == qname then
      if typeof(it[1]) == "array" then return it[1] end if
      return []
    end if
  end for
  return []
end function

function _ensure_enum_obj_strings(state)
  if typeof(state.enum_ids) != "array" or len(state.enum_ids) <= 0 then return state end if
  for i = 0 to len(state.enum_ids) - 1
    e = state.enum_ids[i]
    eqn = ""
    eid = -1
    if typeof(e) == "struct" then
      if typeof(e.key) == "string" then eqn = e.key end if
      if typeof(e.value) == "int" then eid = e.value end if
    else
      if typeof(e) == "array" and len(e) >= 2 then
        if typeof(e[0]) == "string" then eqn = e[0] end if
        if typeof(e[1]) == "int" then eid = e[1] end if
      end if
    end if
    if eqn == "" or eid < 0 then continue end if
    vals = _enum_variants_of(state, eqn)
    if typeof(vals) != "array" or len(vals) <= 0 then continue end if
    for vid = 0 to len(vals) - 1
      vname = vals[vid]
      if typeof(vname) != "string" then continue end if
      lbl = "enumv_" + eid + "_" + vid
      if _has_label(state.rdata.labels, lbl) == false then
        state.rdata = d.rdata_add_obj_string(state.rdata, lbl, eqn + "." + vname)
      end if
    end for
  end for
  return state
end function

function emit_input_function(state)
  state.asm = a.mark(state.asm, "fn_input")

  if typeof(state.is_windows_subsystem) == "bool" and state.is_windows_subsystem then
    state.asm = a.lea_rax_rip(state.asm, "obj_empty_string")
    state.asm = a.ret(state.asm)
    return state
  end if

  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  state.asm = a.mov_rcx_imm32(state.asm, 0xFFFFFFF6)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_GetStdHandle")
  state.asm = a.call_rax(state.asm)

  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.lea_rax_rip(state.asm, "inbuf")
  state.asm = a.mov_rdx_rax(state.asm)
  state.asm = a.mov_r8d_imm32(state.asm, INPUT_READ_MAX)
  state.asm = a.lea_r9_rip(state.asm, "bytesRead")
  state.asm = a.mov_qword_ptr_rsp20_rax_zero(state.asm)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_ReadFile")
  state.asm = a.call_rax(state.asm)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_read_ok = "in_read_ok_" + lid
  l_nonempty = "in_nonempty_" + lid

  state.asm = a.test_r32_r32(state.asm, "eax", "eax")
  state.asm = a.jcc(state.asm, "ne", l_read_ok)
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.mov_rip_dword_eax(state.asm, "bytesRead")
  state.asm = a.mark(state.asm, l_read_ok)

  state.asm = a.mov_eax_rip_dword(state.asm, "bytesRead")
  state.asm = a.mov_r32_r32(state.asm, "r9d", "eax")

  state.asm = a.lea_rax_rip(state.asm, "inbuf")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_r32_r32(state.asm, "edx", "r9d")
  state.asm = a.mov_r32_imm32(state.asm, "r8d", 10)
  state.asm = a.mov_r32_imm32(state.asm, "r9d", 13)
  state.asm = a.call(state.asm, "fn_scan_byte2_bytes")
  state.asm = a.mov_r32_r32(state.asm, "r9d", "edx")

  state.asm = a.cmp_r32_imm(state.asm, "r9d", 0)
  state.asm = a.jcc(state.asm, "ne", l_nonempty)
  state.asm = a.lea_rax_rip(state.asm, "obj_empty_string")
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  state.asm = a.mark(state.asm, l_nonempty)

  state.asm = a.mov_r32_r32(state.asm, "ecx", "r9d")
  state.asm = a.add_r32_imm(state.asm, "ecx", 9)
  state.asm = a.call(state.asm, "fn_alloc")

  state.asm = a.mov_r11_rax(state.asm)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRING, false)
  state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "r9d")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "r11")
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r11", 8)
  state.asm = a.lea_rdx_rip(state.asm, "inbuf")
  state.asm = a.mov_r32_r32(state.asm, "r8d", "r9d")
  state.asm = a.call(state.asm, "fn_copy_bytes")
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x20)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "r11", 4)

  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_r64_r64(state.asm, "rax", "r9")
  state.asm = a.add_rax_imm8(state.asm, 8)
  state.asm = a.mov_membase_disp_imm8(state.asm, "rax", 0, 0)

  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_decode_function(state)
  state.asm = a.mark(state.asm, "fn_decode")

  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "dec_fail_" + lid
  l_nonempty = "dec_nonempty_" + lid

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")

  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rax", 4)

  state.asm = a.cmp_r32_imm(state.asm, "r9d", 0)
  state.asm = a.jcc(state.asm, "ne", l_nonempty)
  state.asm = a.lea_rax_rip(state.asm, "obj_empty_string")
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  state.asm = a.mark(state.asm, l_nonempty)

  state.asm = a.mov_r32_r32(state.asm, "ecx", "r9d")
  state.asm = a.add_r32_imm(state.asm, "ecx", 9)
  state.asm = a.call(state.asm, "fn_alloc")
  state.asm = a.mov_r11_rax(state.asm)

  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x20)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "r10", 4)

  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRING, false)
  state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "r9d")

  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "r11")
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r11", 8)
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r10", 8)
  state.asm = a.mov_r32_r32(state.asm, "r8d", "r9d")
  state.asm = a.call(state.asm, "fn_copy_bytes")
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x20)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "r11", 4)

  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_r64_r64(state.asm, "rax", "r9")
  state.asm = a.add_rax_imm8(state.asm, 8)
  state.asm = a.mov_membase_disp_imm8(state.asm, "rax", 0, 0)

  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_decodeZ_function(state)
  state.asm = a.mark(state.asm, "fn_decodeZ")

  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "decZ_fail_" + lid
  l_nonempty = "decZ_nonempty_" + lid

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")

  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 4)
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "rax", 8)
  state.asm = a.call(state.asm, "fn_scan_nul_bytes")
  state.asm = a.mov_r32_r32(state.asm, "r9d", "edx")

  state.asm = a.cmp_r32_imm(state.asm, "r9d", 0)
  state.asm = a.jcc(state.asm, "ne", l_nonempty)
  state.asm = a.lea_rax_rip(state.asm, "obj_empty_string")
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  state.asm = a.mark(state.asm, l_nonempty)

  state.asm = a.mov_r32_r32(state.asm, "ecx", "r9d")
  state.asm = a.add_r32_imm(state.asm, "ecx", 9)
  state.asm = a.call(state.asm, "fn_alloc")

  state.asm = a.mov_r11_rax(state.asm)

  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x20)
  state.asm = a.mov_r32_r32(state.asm, "r8d", "r9d")

  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRING, false)
  state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "r9d")

  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "r11")
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r11", 8)
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r10", 8)
  state.asm = a.mov_r32_r32(state.asm, "r8d", "r8d")
  state.asm = a.call(state.asm, "fn_copy_bytes")
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x20)
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "r11", 4)

  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_r64_r64(state.asm, "rax", "r8")
  state.asm = a.add_rax_imm8(state.asm, 8)
  state.asm = a.mov_membase_disp_imm8(state.asm, "rax", 0, 0)

  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_decode16Z_function(state)
  state.asm = a.mark(state.asm, "fn_decode16Z")

  state.asm = a.sub_rsp_imm8(state.asm, 0x68)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "dec16Z_fail_" + lid
  l_empty = "dec16Z_empty_" + lid

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")

  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x40, "rax")
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 4)
  state.asm = a.shr_r32_imm8(state.asm, "edx", 1)
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "rax", 8)
  state.asm = a.call(state.asm, "fn_scan_nul_wchars")
  state.asm = a.mov_r32_r32(state.asm, "r8d", "edx")

  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x40)
  state.asm = a.lea_r64_membase_disp(state.asm, "r11", "r11", 8)
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x40, "r11")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x48, "r8")

  state.asm = a.cmp_r32_imm(state.asm, "r8d", 0)
  state.asm = a.jcc(state.asm, "e", l_empty)

  state.asm = a.mov_rcx_imm32(state.asm, 65001)
  state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
  state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", 0x40)
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x48)
  state.asm = a.mov_r32_r32(state.asm, "r9d", "eax")
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x28, 0, true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x30, 0, true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x38, 0, true)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WideCharToMultiByte")
  state.asm = a.call_rax(state.asm)

  state.asm = a.cmp_r64_imm8(state.asm, "rax", 0)
  state.asm = a.jcc(state.asm, "e", l_fail)

  state.asm = a.mov_r32_r32(state.asm, "r9d", "eax")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x58, "rax")

  state.asm = a.mov_r32_r32(state.asm, "ecx", "r9d")
  state.asm = a.add_r32_imm(state.asm, "ecx", 9)
  state.asm = a.call(state.asm, "fn_alloc")

  state.asm = a.mov_r11_rax(state.asm)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRING, false)
  state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "r9d")

  state.asm = a.mov_rcx_imm32(state.asm, 65001)
  state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
  state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", 0x40)
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x48)
  state.asm = a.mov_r32_r32(state.asm, "r9d", "eax")
  state.asm = a.lea_r64_membase_disp(state.asm, "rax", "r11", 8)
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x58)
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x28, "rax")
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x30, 0, true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x38, 0, true)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WideCharToMultiByte")
  state.asm = a.call_rax(state.asm)

  state.asm = a.cmp_r64_imm8(state.asm, "rax", 0)
  state.asm = a.jcc(state.asm, "e", l_fail)

  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x58)
  state.asm = a.lea_r64_membase_disp(state.asm, "r10", "r11", 8)
  state.asm = a.add_r64_r64(state.asm, "r10", "rax")
  state.asm = a.mov_membase_disp_imm8(state.asm, "r10", 0, 0)

  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x68)
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_empty)
  state.asm = a.lea_rax_rip(state.asm, "obj_empty_string")
  state.asm = a.add_rsp_imm8(state.asm, 0x68)
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.add_rsp_imm8(state.asm, 0x68)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_hex_function(state)
  state = mem.ensure_gc_data(state)
  state.asm = a.mark(state.asm, "fn_hex")

  state.asm = a.sub_rsp_imm8(state.asm, 0x38)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "hex_fail_" + lid
  l_nonempty = "hex_nonempty_" + lid
  l_top = "hex_top_" + lid
  l_done = "hex_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")

  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")

  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rax", 4)
  state.asm = a.cmp_r32_imm(state.asm, "r8d", 0x3FFFFFFF)
  state.asm = a.jcc(state.asm, "a", l_fail)

  state.asm = a.mov_r32_r32(state.asm, "r9d", "r8d")
  state.asm = a.add_r32_r32(state.asm, "r9d", "r8d")
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x28, "r9d")

  state.asm = a.cmp_r32_imm(state.asm, "r9d", 0)
  state.asm = a.jcc(state.asm, "ne", l_nonempty)
  state.asm = a.lea_rax_rip(state.asm, "obj_empty_string")
  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)
  state.asm = a.mark(state.asm, l_nonempty)

  state.asm = a.mov_r32_r32(state.asm, "ecx", "r9d")
  state.asm = a.add_r32_imm(state.asm, "ecx", 9)
  state.asm = a.call(state.asm, "fn_alloc")

  state.asm = a.mov_r11_rax(state.asm)

  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x20)
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "r10", 4)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rsp", 0x28)

  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRING, false)
  state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "r9d")

  state.asm = a.push_reg(state.asm, "rsi")
  state.asm = a.push_reg(state.asm, "rdi")
  state.asm = a.push_reg(state.asm, "r12")

  state.asm = a.lea_rax_rip(state.asm, "hex_tbl")
  state.asm = a.mov_r64_r64(state.asm, "r12", "rax")

  state.asm = a.lea_r64_membase_disp(state.asm, "rsi", "r10", 8)
  state.asm = a.lea_r64_membase_disp(state.asm, "rdi", "r11", 8)
  state.asm = a.mov_r32_r32(state.asm, "r10d", "r8d")

  state.asm = a.mark(state.asm, l_top)
  state.asm = a.test_r32_r32(state.asm, "r10d", "r10d")
  state.asm = a.jcc(state.asm, "e", l_done)

  state.asm = a.movzx_r32_membase_disp(state.asm, "r8d", "rsi", 0)
  state.asm = a.mov_r32_r32(state.asm, "r9d", "r8d")
  state.asm = a.shr_r64_imm8(state.asm, "r9", 4)
  state.asm = a.and_r32_imm(state.asm, "r8d", 0x0F)

  state.asm = a.lea_r64_mem_bis(state.asm, "rax", "r12", "r9", 1, 0)
  state.asm = a.mov_r8_membase_disp(state.asm, "al", "rax", 0)
  state.asm = a.mov_membase_disp_r8(state.asm, "rdi", 0, "al")
  state.asm = a.inc_r64(state.asm, "rdi")

  state.asm = a.lea_r64_mem_bis(state.asm, "rax", "r12", "r8", 1, 0)
  state.asm = a.mov_r8_membase_disp(state.asm, "al", "rax", 0)
  state.asm = a.mov_membase_disp_r8(state.asm, "rdi", 0, "al")
  state.asm = a.inc_r64(state.asm, "rdi")

  state.asm = a.inc_r64(state.asm, "rsi")
  state.asm = a.dec_r32(state.asm, "r10d")
  state.asm = a.jmp(state.asm, l_top)

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.pop_reg(state.asm, "r12")
  state.asm = a.pop_reg(state.asm, "rdi")
  state.asm = a.pop_reg(state.asm, "rsi")

  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_rax_imm8(state.asm, 8)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rsp", 0x28)
  state.asm = a.add_r64_r64(state.asm, "rax", "r9")
  state.asm = a.mov_membase_disp_imm8(state.asm, "rax", 0, 0)

  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_fromHex_function(state)
  state = mem.ensure_gc_data(state)
  state.asm = a.mark(state.asm, "fn_fromHex")

  state.asm = a.push_reg(state.asm, "rsi")
  state.asm = a.push_reg(state.asm, "rdi")
  state.asm = a.push_reg(state.asm, "r12")
  state.asm = a.push_reg(state.asm, "r13")
  state.asm = a.push_reg(state.asm, "r14")
  state.asm = a.push_reg(state.asm, "r15")
  state.asm = a.sub_rsp_imm8(state.asm, 0x58)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "fh_fail_" + lid
  l_count_top = "fh_count_top_" + lid
  l_count_done = "fh_count_done_" + lid
  l_parse_top = "fh_parse_top_" + lid
  l_parse_prefix_done = "fh_parse_prefix_done_" + lid
  l_parse_skip = "fh_parse_skip_" + lid
  l_parse_next = "fh_parse_next_" + lid
  l_parse_done = "fh_parse_done_" + lid
  l_is_sep = "fh_is_sep_" + lid
  l_not_sep = "fh_not_sep_" + lid
  l_is_digit = "fh_is_digit_" + lid
  l_set_hi = "fh_set_hi_" + lid
  l_have_hi = "fh_have_hi_" + lid

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")

  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rax", 4)
  state.asm = a.lea_r64_membase_disp(state.asm, "rsi", "rax", 8)
  state.asm = a.xor_r32_r32(state.asm, "r9d", "r9d")

  state.asm = a.cmp_r32_imm(state.asm, "r8d", 2)
  l_no_prefix = "fh_no_prefix_" + lid
  state.asm = a.jcc(state.asm, "b", l_no_prefix)

  state.asm = a.movzx_r32_membase_disp(state.asm, "r10d", "rsi", 0)
  state.asm = a.cmp_r32_imm(state.asm, "r10d", 48)
  state.asm = a.jcc(state.asm, "ne", l_no_prefix)
  state.asm = a.movzx_r32_membase_disp(state.asm, "r10d", "rsi", 1)
  state.asm = a.cmp_r32_imm(state.asm, "r10d", 120)
  l_chk_X = "fh_chk_X_" + lid
  state.asm = a.jcc(state.asm, "e", l_chk_X)
  state.asm = a.cmp_r32_imm(state.asm, "r10d", 88)
  state.asm = a.jcc(state.asm, "ne", l_no_prefix)
  state.asm = a.mark(state.asm, l_chk_X)
  state.asm = a.mov_r32_imm32(state.asm, "r9d", 2)

  state.asm = a.mark(state.asm, l_no_prefix)
  state.asm = a.xor_r32_r32(state.asm, "r10d", "r10d")

  state.asm = a.mark(state.asm, l_count_top)
  state.asm = a.cmp_r32_r32(state.asm, "r9d", "r8d")
  state.asm = a.jcc(state.asm, "ge", l_count_done)

  state.asm = a.lea_r64_mem_bis(state.asm, "rax", "rsi", "r9", 1, 0)
  state.asm = a.movzx_r32_membase_disp(state.asm, "r11d", "rax", 0)

  state.asm = a.cmp_r32_imm(state.asm, "r11d", 32)
  state.asm = a.jcc(state.asm, "e", l_is_sep)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", 9)
  state.asm = a.jcc(state.asm, "e", l_is_sep)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", 10)
  state.asm = a.jcc(state.asm, "e", l_is_sep)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", 13)
  state.asm = a.jcc(state.asm, "e", l_is_sep)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", 95)
  state.asm = a.jcc(state.asm, "e", l_is_sep)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", 45)
  state.asm = a.jcc(state.asm, "e", l_is_sep)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", 58)
  state.asm = a.jcc(state.asm, "e", l_is_sep)
  state.asm = a.jmp(state.asm, l_not_sep)

  state.asm = a.mark(state.asm, l_is_sep)
  state.asm = a.inc_r32(state.asm, "r9d")
  state.asm = a.jmp(state.asm, l_count_top)

  state.asm = a.mark(state.asm, l_not_sep)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", 48)
  l_chk_a = "fh_chk_a_" + lid
  state.asm = a.jcc(state.asm, "b", l_chk_a)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", 57)
  state.asm = a.jcc(state.asm, "be", l_is_digit)

  state.asm = a.mark(state.asm, l_chk_a)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", 97)
  l_chk_A = "fh_chk_A_" + lid
  state.asm = a.jcc(state.asm, "b", l_chk_A)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", 102)
  state.asm = a.jcc(state.asm, "be", l_is_digit)

  state.asm = a.mark(state.asm, l_chk_A)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", 65)
  state.asm = a.jcc(state.asm, "b", l_fail)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", 70)
  state.asm = a.jcc(state.asm, "a", l_fail)

  state.asm = a.mark(state.asm, l_is_digit)
  state.asm = a.inc_r32(state.asm, "r10d")
  state.asm = a.inc_r32(state.asm, "r9d")
  state.asm = a.jmp(state.asm, l_count_top)

  state.asm = a.mark(state.asm, l_count_done)
  state.asm = a.test_r64_imm32(state.asm, "r10", 1)
  state.asm = a.jcc(state.asm, "nz", l_fail)

  state.asm = a.shr_r64_imm8(state.asm, "r10", 1)

  state.asm = a.mov_r32_r32(state.asm, "ecx", "r10d")
  state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
  state.asm = a.call(state.asm, "fn_bytes_alloc")

  state.asm = a.mov_r11_rax(state.asm)
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp3")

  state.asm = a.mov_r64_membase_disp(state.asm, "r12", "rsp", 0x20)
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "r12", 4)
  state.asm = a.lea_r64_membase_disp(state.asm, "rsi", "r12", 8)

  state.asm = a.xor_r32_r32(state.asm, "r9d", "r9d")
  state.asm = a.cmp_r32_imm(state.asm, "r8d", 2)
  state.asm = a.jcc(state.asm, "b", l_parse_prefix_done)
  state.asm = a.movzx_r32_membase_disp(state.asm, "r13d", "rsi", 0)
  state.asm = a.cmp_r32_imm(state.asm, "r13d", 48)
  state.asm = a.jcc(state.asm, "ne", l_parse_prefix_done)
  state.asm = a.movzx_r32_membase_disp(state.asm, "r13d", "rsi", 1)
  state.asm = a.cmp_r32_imm(state.asm, "r13d", 120)
  l_pchk_X = "fh_pchk_X_" + lid
  state.asm = a.jcc(state.asm, "e", l_pchk_X)
  state.asm = a.cmp_r32_imm(state.asm, "r13d", 88)
  state.asm = a.jcc(state.asm, "ne", l_parse_prefix_done)
  state.asm = a.mark(state.asm, l_pchk_X)
  state.asm = a.mov_r32_imm32(state.asm, "r9d", 2)

  state.asm = a.mark(state.asm, l_parse_prefix_done)
  state.asm = a.lea_r64_membase_disp(state.asm, "rdi", "r11", 8)
  state.asm = a.xor_r32_r32(state.asm, "r14d", "r14d")
  state.asm = a.xor_r32_r32(state.asm, "r15d", "r15d")

  state.asm = a.mark(state.asm, l_parse_top)
  state.asm = a.cmp_r32_r32(state.asm, "r9d", "r8d")
  state.asm = a.jcc(state.asm, "ge", l_parse_done)

  state.asm = a.lea_r64_mem_bis(state.asm, "rax", "rsi", "r9", 1, 0)
  state.asm = a.movzx_r32_membase_disp(state.asm, "r13d", "rax", 0)

  state.asm = a.cmp_r32_imm(state.asm, "r13d", 32)
  state.asm = a.jcc(state.asm, "e", l_parse_skip)
  state.asm = a.cmp_r32_imm(state.asm, "r13d", 9)
  state.asm = a.jcc(state.asm, "e", l_parse_skip)
  state.asm = a.cmp_r32_imm(state.asm, "r13d", 10)
  state.asm = a.jcc(state.asm, "e", l_parse_skip)
  state.asm = a.cmp_r32_imm(state.asm, "r13d", 13)
  state.asm = a.jcc(state.asm, "e", l_parse_skip)
  state.asm = a.cmp_r32_imm(state.asm, "r13d", 95)
  state.asm = a.jcc(state.asm, "e", l_parse_skip)
  state.asm = a.cmp_r32_imm(state.asm, "r13d", 45)
  state.asm = a.jcc(state.asm, "e", l_parse_skip)
  state.asm = a.cmp_r32_imm(state.asm, "r13d", 58)
  state.asm = a.jcc(state.asm, "e", l_parse_skip)

  state.asm = a.cmp_r32_imm(state.asm, "r13d", 48)
  l_pchk_a = "fh_pchk_a_" + lid
  state.asm = a.jcc(state.asm, "b", l_pchk_a)
  state.asm = a.cmp_r32_imm(state.asm, "r13d", 57)
  l_pis_a = "fh_pis_a_" + lid
  state.asm = a.jcc(state.asm, "be", l_pis_a)

  state.asm = a.mark(state.asm, l_pchk_a)
  state.asm = a.cmp_r32_imm(state.asm, "r13d", 97)
  l_pchk_A2 = "fh_pchk_A2_" + lid
  state.asm = a.jcc(state.asm, "b", l_pchk_A2)
  state.asm = a.cmp_r32_imm(state.asm, "r13d", 102)
  l_pis_f = "fh_pis_f_" + lid
  state.asm = a.jcc(state.asm, "be", l_pis_f)

  state.asm = a.mark(state.asm, l_pchk_A2)
  state.asm = a.cmp_r32_imm(state.asm, "r13d", 65)
  state.asm = a.jcc(state.asm, "b", l_fail)
  state.asm = a.cmp_r32_imm(state.asm, "r13d", 70)
  state.asm = a.jcc(state.asm, "a", l_fail)
  state.asm = a.sub_r32_imm(state.asm, "r13d", 55)
  state.asm = a.jmp(state.asm, l_have_hi)

  state.asm = a.mark(state.asm, l_pis_a)
  state.asm = a.sub_r32_imm(state.asm, "r13d", 48)
  state.asm = a.jmp(state.asm, l_have_hi)

  state.asm = a.mark(state.asm, l_pis_f)
  state.asm = a.sub_r32_imm(state.asm, "r13d", 87)

  state.asm = a.mark(state.asm, l_have_hi)
  state.asm = a.test_r32_r32(state.asm, "r14d", "r14d")
  state.asm = a.jcc(state.asm, "z", l_set_hi)

  state.asm = a.mov_r32_r32(state.asm, "eax", "r15d")
  state.asm = a.shl_r32_imm8(state.asm, "eax", 4)
  state.asm = a.add_r32_r32(state.asm, "eax", "r13d")
  state.asm = a.mov_membase_disp_r8(state.asm, "rdi", 0, "al")
  state.asm = a.inc_r64(state.asm, "rdi")
  state.asm = a.xor_r32_r32(state.asm, "r14d", "r14d")
  state.asm = a.jmp(state.asm, l_parse_next)

  state.asm = a.mark(state.asm, l_set_hi)
  state.asm = a.mov_r32_r32(state.asm, "r15d", "r13d")
  state.asm = a.mov_r32_imm32(state.asm, "r14d", 1)

  state.asm = a.mark(state.asm, l_parse_next)
  state.asm = a.inc_r32(state.asm, "r9d")
  state.asm = a.jmp(state.asm, l_parse_top)

  state.asm = a.mark(state.asm, l_parse_skip)
  state.asm = a.inc_r32(state.asm, "r9d")
  state.asm = a.jmp(state.asm, l_parse_top)

  state.asm = a.mark(state.asm, l_parse_done)
  state.asm = a.test_r32_r32(state.asm, "r14d", "r14d")
  state.asm = a.jcc(state.asm, "nz", l_fail)

  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x58)
  state.asm = a.pop_reg(state.asm, "r15")
  state.asm = a.pop_reg(state.asm, "r14")
  state.asm = a.pop_reg(state.asm, "r13")
  state.asm = a.pop_reg(state.asm, "r12")
  state.asm = a.pop_reg(state.asm, "rdi")
  state.asm = a.pop_reg(state.asm, "rsi")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.add_rsp_imm8(state.asm, 0x58)
  state.asm = a.pop_reg(state.asm, "r15")
  state.asm = a.pop_reg(state.asm, "r14")
  state.asm = a.pop_reg(state.asm, "r13")
  state.asm = a.pop_reg(state.asm, "r12")
  state.asm = a.pop_reg(state.asm, "rdi")
  state.asm = a.pop_reg(state.asm, "rsi")
  state.asm = a.ret(state.asm)
  return state
end function

function emit_box_float_function(state)
  state = mem.ensure_gc_data(state)
  state.asm = a.mark(state.asm, "fn_box_float")

  state.asm = a.sub_rsp_imm8(state.asm, 0x28)
  state.asm = a.mov_rcx_imm32(state.asm, 16)
  state.asm = a.call(state.asm, "fn_alloc")
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", 0, c.OBJ_FLOAT, false)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", 4, 0, false)
  state.asm = a.movsd_membase_disp_xmm(state.asm, "rax", 8, "xmm0")
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_value_to_string_function(state)
  state = mem.ensure_gc_data(state)
  state = _ensure_enum_obj_strings(state)
  state.asm = a.mark(state.asm, "fn_value_to_string")

  state.asm = a.sub_rsp_imm8(state.asm, 0x38)
  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_ptr = "v2s_ptr_" + lid
  l_int = "v2s_int_" + lid
  l_bool = "v2s_bool_" + lid
  l_void = "v2s_void_" + lid
  l_enum = "v2s_enum_" + lid
  l_float_imm = "v2s_float_imm_" + lid
  l_float = "v2s_float_" + lid
  l_float_fmt = "v2s_float_fmt_" + lid
  l_array = "v2s_array_" + lid
  l_bytes = "v2s_bytes_" + lid
  l_stt = "v2s_stt_" + lid
  l_uns = "v2s_uns_" + lid
  l_done = "v2s_done_" + lid

  state.asm = a.cmp_rax_imm8(state.asm, c.TAG_VOID)
  state.asm = a.jcc(state.asm, "e", l_void)

  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.and_r64_imm(state.asm, "rdx", 7)

  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "e", l_ptr)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_INT)
  state.asm = a.jcc(state.asm, "e", l_int)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_BOOL)
  state.asm = a.jcc(state.asm, "e", l_bool)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_ENUM)
  state.asm = a.jcc(state.asm, "e", l_enum)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_FLOAT)
  state.asm = a.jcc(state.asm, "e", l_float_imm)
  state.asm = a.jmp(state.asm, l_uns)

  state.asm = a.mark(state.asm, l_void)
  state.asm = a.lea_rax_rip(state.asm, "obj_void")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_ptr)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "e", l_done)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FLOAT)
  state.asm = a.jcc(state.asm, "e", l_float)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
  state.asm = a.jcc(state.asm, "e", l_array)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY_IMM)
  state.asm = a.jcc(state.asm, "e", l_array)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "e", l_bytes)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRUCTTYPE)
  state.asm = a.jcc(state.asm, "e", l_stt)
  state.asm = a.jmp(state.asm, l_uns)

  state.asm = a.mark(state.asm, l_array)
  state.asm = a.lea_rax_rip(state.asm, "obj_array")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_bytes)
  state.asm = a.lea_rax_rip(state.asm, "obj_bytes")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_bool)
  state.asm = a.test_rax_imm32(state.asm, 8)
  l_bfalse = "v2s_bfalse_" + lid
  state.asm = a.jcc(state.asm, "z", l_bfalse)
  state.asm = a.lea_rax_rip(state.asm, "obj_true")
  state.asm = a.jmp(state.asm, l_done)
  state.asm = a.mark(state.asm, l_bfalse)
  state.asm = a.lea_rax_rip(state.asm, "obj_false")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_enum)
  state.asm = a.mov_r64_r64(state.asm, "r8", "rax")
  state.asm = a.shr_r64_imm8(state.asm, "r8", 3)
  state.asm = a.mov_r64_r64(state.asm, "r9", "r8")
  state.asm = a.shr_r64_imm8(state.asm, "r9", 16)
  state.asm = a.and_r32_imm(state.asm, "r8d", 0xFFFF)
  state.asm = a.and_r32_imm(state.asm, "r9d", 0xFFFF)

  if typeof(state.enum_ids) == "array" and len(state.enum_ids) > 0 then
    for ei = 0 to len(state.enum_ids) - 1
      eidrec = state.enum_ids[ei]
      eqn = ""
      eid = -1
      if typeof(eidrec) == "struct" then
        if typeof(eidrec.key) == "string" then eqn = eidrec.key end if
        if typeof(eidrec.value) == "int" then eid = eidrec.value end if
      else
        if typeof(eidrec) == "array" and len(eidrec) >= 2 then
          if typeof(eidrec[0]) == "string" then eqn = eidrec[0] end if
          if typeof(eidrec[1]) == "int" then eid = eidrec[1] end if
        end if
      end if
      if eqn == "" or eid < 0 then continue end if
      vals = _enum_variants_of(state, eqn)
      if typeof(vals) != "array" or len(vals) <= 0 then continue end if
      for vid = 0 to len(vals) - 1
        lbl = "enumv_" + eid + "_" + vid
        l_next = "v2s_enum_next_" + lid + "_" + eid + "_" + vid
        state.asm = a.cmp_r32_imm(state.asm, "r8d", eid)
        state.asm = a.jcc(state.asm, "ne", l_next)
        state.asm = a.cmp_r32_imm(state.asm, "r9d", vid)
        state.asm = a.jcc(state.asm, "ne", l_next)
        state.asm = a.lea_rax_rip(state.asm, lbl)
        state.asm = a.jmp(state.asm, l_done)
        state.asm = a.mark(state.asm, l_next)
      end for
    end for
  end if

  state.asm = a.lea_rax_rip(state.asm, "obj_uns")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_int)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.call(state.asm, "fn_int_to_dec")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x28, "edx")

  state.asm = a.mov_r32_r32(state.asm, "r9d", "edx")
  state.asm = a.mov_r32_r32(state.asm, "ecx", "edx")
  state.asm = a.add_r32_imm(state.asm, "ecx", 9)
  state.asm = a.call(state.asm, "fn_alloc")

  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x20)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rsp", 0x28)

  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", 0, c.OBJ_STRING, false)
  state.asm = a.mov_membase_disp_r32(state.asm, "rax", 4, "r9d")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "rax", 8)
  state.asm = a.mov_r64_r64(state.asm, "rdx", "r10")
  state.asm = a.mov_r32_r32(state.asm, "r8d", "r9d")
  state.asm = a.call(state.asm, "fn_copy_bytes")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x20)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rax", 4)
  state.asm = a.lea_r64_membase_disp(state.asm, "r10", "rax", 8)
  state.asm = a.add_r64_r64(state.asm, "r10", "r9")
  state.asm = a.mov_membase_disp_imm8(state.asm, "r10", 0, 0)
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_float_imm)
  state = core.emit_to_double_xmm(state, 0, l_uns)
  state.asm = a.jmp(state.asm, l_float_fmt)

  state.asm = a.mark(state.asm, l_float)
  state = core.emit_to_double_xmm(state, 0, l_uns)
  state.asm = a.mark(state.asm, l_float_fmt)
  state.asm = a.mov_r32_imm32(state.asm, "edx", 15)
  state.asm = a.lea_r8_rip(state.asm, "floatbuf")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat__gcvt")
  state.asm = a.call_rax(state.asm)

  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.call(state.asm, "fn_strlen")
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x28, "edx")

  state.asm = a.mov_r32_r32(state.asm, "r9d", "edx")
  state.asm = a.mov_r32_r32(state.asm, "ecx", "edx")
  state.asm = a.add_r32_imm(state.asm, "ecx", 9)
  state.asm = a.call(state.asm, "fn_alloc")

  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x20)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rsp", 0x28)

  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", 0, c.OBJ_STRING, false)
  state.asm = a.mov_membase_disp_r32(state.asm, "rax", 4, "r9d")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "rax", 8)
  state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
  state.asm = a.mov_r32_r32(state.asm, "r8d", "r9d")
  state.asm = a.call(state.asm, "fn_copy_bytes")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x20)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rax", 4)
  state.asm = a.lea_r64_membase_disp(state.asm, "r10", "rax", 8)
  state.asm = a.add_r64_r64(state.asm, "r10", "r9")
  state.asm = a.mov_membase_disp_imm8(state.asm, "r10", 0, 0)
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_stt)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_struct")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_uns)
  state.asm = a.lea_rax_rip(state.asm, "obj_uns")

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_string_add_function(state)
  state = mem.ensure_gc_data(state)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail_uns = "addstr_fail_uns_" + lid
  l_fail_void = "addstr_fail_void_" + lid
  l_s1_convert = "addstr_s1_convert_" + lid
  l_s1_ready = "addstr_s1_ready_" + lid
  l_s2_convert = "addstr_s2_convert_" + lid
  l_s2_ready = "addstr_s2_ready_" + lid

  lbl_msg_uns = "objstr_" + len(state.rdata.labels)
  state.rdata = d.rdata_add_obj_string(state.rdata, lbl_msg_uns, "Cannot stringify unsupported value for string concatenation")
  lbl_msg_void = "objstr_" + len(state.rdata.labels)
  state.rdata = d.rdata_add_obj_string(state.rdata, lbl_msg_void, "Cannot stringify void for string concatenation")

  state.asm = a.mark(state.asm, "fn_add_string")

  state.asm = a.sub_rsp_imm8(state.asm, 0x38)

  // Save rhs (b) before stringifying lhs.
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rdx")

  // s1 = a if already string, else value_to_string(a)
  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_s1_convert)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "e", l_s1_ready)
  state.asm = a.mark(state.asm, l_s1_convert)
  state.asm = a.call(state.asm, "fn_value_to_string")
  state.asm = a.mark(state.asm, l_s1_ready)
  state.asm = a.lea_r11_rip(state.asm, "obj_uns")
  state.asm = a.cmp_r64_r64(state.asm, "rax", "r11")
  state.asm = a.jcc(state.asm, "e", l_fail_uns)
  state.asm = a.lea_r11_rip(state.asm, "obj_void")
  state.asm = a.cmp_r64_r64(state.asm, "rax", "r11")
  state.asm = a.jcc(state.asm, "e", l_fail_void)
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x28, "rax")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")

  // s2 = b if already string, else value_to_string(b)
  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x20)
  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_s2_convert)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "e", l_s2_ready)
  state.asm = a.mark(state.asm, l_s2_convert)
  state.asm = a.call(state.asm, "fn_value_to_string")
  state.asm = a.mark(state.asm, l_s2_ready)
  state.asm = a.lea_r11_rip(state.asm, "obj_uns")
  state.asm = a.cmp_r64_r64(state.asm, "rax", "r11")
  state.asm = a.jcc(state.asm, "e", l_fail_uns)
  state.asm = a.lea_r11_rip(state.asm, "obj_void")
  state.asm = a.cmp_r64_r64(state.asm, "rax", "r11")
  state.asm = a.jcc(state.asm, "e", l_fail_void)
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x30, "r11")
  state.asm = a.mov_rip_qword_r11(state.asm, "gc_tmp3")

  // reload s1 into r10
  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x28)

  // r8d = len1, r9d = len2
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "r10", 4)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "r11", 4)

  // ecx = totalLen = len1 + len2
  state.asm = a.mov_r32_r32(state.asm, "ecx", "r8d")
  state.asm = a.add_r32_r32(state.asm, "ecx", "r9d")

  lid_nonempty = state.label_id
  state.label_id = state.label_id + 1
  l_add_nonempty = "addstr_nonempty_" + lid_nonempty

  state.asm = a.cmp_r32_imm(state.asm, "ecx", 0)
  state.asm = a.jcc(state.asm, "ne", l_add_nonempty)
  state.asm = a.lea_rax_rip(state.asm, "obj_empty_string")
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp3")
  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_add_nonempty)
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x20, "ecx")
  state.asm = a.add_r32_imm(state.asm, "ecx", 9)
  state.asm = a.call(state.asm, "fn_alloc")

  // reload totalLen into r8d
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rsp", 0x20)
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.mov_membase_disp_imm32(state.asm, "rdx", 0, c.OBJ_STRING, false)
  state.asm = a.mov_membase_disp_r32(state.asm, "rdx", 4, "r8d")

  // reload s1/s2 before any pushes
  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x28)
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x30)

  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rdx")
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "rdx", 8)
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r10", 8)
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "r10", 4)
  state.asm = a.call(state.asm, "fn_copy_bytes")

  state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", 0x20)
  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x28)
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x30)
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "rdx", 8)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r10", 4)
  state.asm = a.add_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r11", 8)
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "r11", 4)
  state.asm = a.call(state.asm, "fn_copy_bytes")

  state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", 0x20)
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rdx", 4)
  state.asm = a.lea_r64_membase_disp(state.asm, "r11", "rdx", 8)
  state.asm = a.add_r64_r64(state.asm, "r11", "r8")
  state.asm = a.mov_membase_disp_imm8(state.asm, "r11", 0, 0)
  state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")

  // Clear GC temp roots without clobbering return value.
  state.asm = a.mov_r11_rax(state.asm)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp3")
  state.asm = a.mov_rax_r11(state.asm)

  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_fail_uns)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp3")
  state.asm = a.mov_rcx_imm32(state.asm, 48)
  state.asm = a.call(state.asm, "fn_alloc")
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRUCT, false)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, c.ERROR_STRUCT_ID, false)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_int(c.ERR_STRINGIFY_UNSUPPORTED))
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8, "rax")
  state.asm = a.lea_rax_rip(state.asm, lbl_msg_uns)
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_script")
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 24, "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_func")
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 32, "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_line")
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 40, "rax")
  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_fail_void)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp3")
  state.asm = a.mov_rcx_imm32(state.asm, 48)
  state.asm = a.call(state.asm, "fn_alloc")
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRUCT, false)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, c.ERROR_STRUCT_ID, false)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_int(c.ERR_STRINGIFY_UNSUPPORTED))
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8, "rax")
  state.asm = a.lea_rax_rip(state.asm, lbl_msg_void)
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 16, "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_script")
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 24, "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_func")
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 32, "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "dbg_loc_line")
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", 40, "rax")
  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_array_add_function(state)
  state = mem.ensure_gc_data(state)
  state.asm = a.mark(state.asm, "fn_add_array")

  state.asm = a.sub_rsp_imm8(state.asm, 0x38)

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.mov_rip_qword_rdx(state.asm, "gc_tmp3")

  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rcx")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x28, "rdx")

  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rcx", 4)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rdx", 4)
  state.asm = a.mov_r32_r32(state.asm, "eax", "r8d")
  state.asm = a.add_r32_r32(state.asm, "eax", "r9d")
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x30, "eax")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_store_out_type = "addarr_store_out_type_" + lid
  state.asm = a.mov_r32_imm32(state.asm, "eax", c.OBJ_ARRAY)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "rcx", 0)
  state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_ARRAY_IMM)
  state.asm = a.jcc(state.asm, "ne", l_store_out_type)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "rdx", 0)
  state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_ARRAY_IMM)
  state.asm = a.jcc(state.asm, "ne", l_store_out_type)
  state.asm = a.mov_r32_imm32(state.asm, "eax", c.OBJ_ARRAY_IMM)
  state.asm = a.mark(state.asm, l_store_out_type)
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x34, "eax")

  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rsp", 0x30)
  state.asm = a.shl_r64_imm8(state.asm, "rcx", 3)
  state.asm = a.add_r64_imm(state.asm, "rcx", 8)
  state.asm = a.call(state.asm, "fn_alloc")

  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rsp", 0x34)
  state.asm = a.mov_membase_disp_r32(state.asm, "rdx", 0, "ecx")
  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rsp", 0x30)
  state.asm = a.mov_membase_disp_r32(state.asm, "rdx", 4, "ecx")

  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x20)
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x28)

  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x30, "rdx")
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "rdx", 8)
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r10", 8)
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "r10", 4)
  state.asm = a.shl_r32_imm8(state.asm, "r8d", 3)
  state.asm = a.call(state.asm, "fn_copy_bytes")

  state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", 0x30)
  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x20)
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x28)
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "rdx", 8)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r10", 4)
  state.asm = a.shl_r32_imm8(state.asm, "eax", 3)
  state.asm = a.add_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r11", 8)
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "r11", 4)
  state.asm = a.shl_r32_imm8(state.asm, "r8d", 3)
  state.asm = a.call(state.asm, "fn_copy_bytes")

  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x30)
  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_bytes_alloc_function(state)
  state = mem.ensure_gc_data(state)
  state.asm = a.mark(state.asm, "fn_bytes_alloc")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_nonempty = "bytes_alloc_nonempty_" + lid
  state.asm = a.test_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.jcc(state.asm, "ne", l_nonempty)
  state.asm = a.lea_rax_rip(state.asm, "obj_empty_bytes")
  state.asm = a.ret(state.asm)
  state.asm = a.mark(state.asm, l_nonempty)

  state.asm = a.sub_rsp_imm8(state.asm, 0x38)

  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x20, "ecx")
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x24, "edx")

  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rsp", 0x20)
  state.asm = a.add_r32_imm(state.asm, "ecx", 8)
  state.asm = a.call(state.asm, "fn_alloc")

  state.asm = a.mov_r11_rax(state.asm)

  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_BYTES, false)
  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rsp", 0x20)
  state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "ecx")

  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x28, "r11")
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r11", 8)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rsp", 0x20)
  state.asm = a.mov_r8_membase_disp(state.asm, "r8b", "rsp", 0x24)
  state.asm = a.call(state.asm, "fn_fill_bytes")
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x28)

  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_bytes_add_function(state)
  state = mem.ensure_gc_data(state)
  state.asm = a.mark(state.asm, "fn_add_bytes")

  state.asm = a.sub_rsp_imm8(state.asm, 0x38)

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.mov_rip_qword_rdx(state.asm, "gc_tmp3")

  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rcx")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x28, "rdx")

  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rcx", 4)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rdx", 4)

  state.asm = a.mov_r32_r32(state.asm, "eax", "r8d")
  state.asm = a.add_r32_r32(state.asm, "eax", "r9d")
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x30, "eax")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_nonempty = "addbytes_nonempty_" + lid
  state.asm = a.cmp_r32_imm(state.asm, "eax", 0)
  state.asm = a.jcc(state.asm, "ne", l_nonempty)
  state.asm = a.lea_rax_rip(state.asm, "obj_empty_bytes")
  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)
  state.asm = a.mark(state.asm, l_nonempty)

  state.asm = a.mov_r32_r32(state.asm, "ecx", "eax")
  state.asm = a.add_r32_imm(state.asm, "ecx", 8)
  state.asm = a.call(state.asm, "fn_alloc")

  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")

  state.asm = a.mov_membase_disp_imm32(state.asm, "rdx", 0, c.OBJ_BYTES, false)
  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rsp", 0x30)
  state.asm = a.mov_membase_disp_r32(state.asm, "rdx", 4, "ecx")

  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x20)
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x28)

  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "r10", 4)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "r11", 4)

  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x30, "rdx")
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "rdx", 8)
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r10", 8)
  state.asm = a.mov_r32_r32(state.asm, "r8d", "r8d")
  state.asm = a.call(state.asm, "fn_copy_bytes")

  state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", 0x30)
  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x20)
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x28)
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "rdx", 8)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r10", 4)
  state.asm = a.add_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r11", 8)
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "r11", 4)
  state.asm = a.call(state.asm, "fn_copy_bytes")

  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x30)
  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_bytes_eq_function(state)
  state.asm = a.mark(state.asm, "fn_bytes_eq")

  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "beq_fail_" + lid
  l_ok = "beq_ok_" + lid

  // Keep originals in r8/r9.
  state.asm = a.mov_r64_r64(state.asm, "r8", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "r9", "rdx")
  state.asm = a.cmp_r64_r64(state.asm, "r8", "r9")
  state.asm = a.jcc(state.asm, "e", l_ok)

  // tag checks: both must be pointers.
  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r9")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)

  // type checks: both must be OBJ_BYTES.
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r8", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r9", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "ne", l_fail)

  // lengths equal?
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r8", 4)
  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "r9", 4)
  state.asm = a.cmp_r32_r32(state.asm, "r10d", "r11d")
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.test_r32_r32(state.asm, "r10d", "r10d")
  state.asm = a.jcc(state.asm, "e", l_ok)
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r8", 8)
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r9", 8)
  state.asm = a.mov_r32_r32(state.asm, "r8d", "r10d")
  state.asm = a.call(state.asm, "fn_mem_eq_bytes")
  state.asm = a.cmp_rax_imm32(state.asm, t.enc_bool(true))
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.mark(state.asm, l_ok)
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.inc_r32(state.asm, "eax")
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_BOOL)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_BOOL)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_slice_function(state)
  state = mem.ensure_gc_data(state)
  state.asm = a.mark(state.asm, "fn_slice")

  state.asm = a.push_reg(state.asm, "rsi")
  state.asm = a.push_reg(state.asm, "rdi")
  state.asm = a.sub_rsp_imm8(state.asm, 0x48)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "slice_fail_" + lid
  l_done = "slice_done_" + lid
  l_off_nonneg = "slice_off_nonneg_" + lid

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")

  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")

  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rax", 4)

  state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x28, "rax")

  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
  state.asm = a.jcc(state.asm, "l", l_fail)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
  state.asm = a.jcc(state.asm, "g", l_fail)
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x30, "eax")

  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x28)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
  state.asm = a.jcc(state.asm, "ge", l_off_nonneg)
  state.asm = a.add_r64_r64(state.asm, "rax", "r9")
  state.asm = a.mark(state.asm, l_off_nonneg)

  state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
  state.asm = a.jcc(state.asm, "l", l_fail)
  state.asm = a.cmp_r64_r64(state.asm, "rax", "r9")
  state.asm = a.jcc(state.asm, "g", l_fail)

  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "rsp", 0x30)
  state.asm = a.add_r64_r64(state.asm, "r11", "r10")
  state.asm = a.cmp_r64_r64(state.asm, "r11", "r9")
  state.asm = a.jcc(state.asm, "g", l_fail)

  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x28, "rax")

  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rsp", 0x30)
  state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
  state.asm = a.call(state.asm, "fn_bytes_alloc")

  state.asm = a.mov_r11_rax(state.asm)

  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rsp", 0x30)
  state.asm = a.test_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.jcc(state.asm, "e", l_done)

  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x20)
  state.asm = a.mov_r64_membase_disp(state.asm, "r9", "rsp", 0x28)
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x38, "r11")
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r11", 8)
  state.asm = a.lea_r64_mem_bis(state.asm, "rdx", "r10", "r9", 1, 8)
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rsp", 0x30)
  state.asm = a.call(state.asm, "fn_copy_bytes")
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x38)

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x48)
  state.asm = a.pop_reg(state.asm, "rdi")
  state.asm = a.pop_reg(state.asm, "rsi")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.add_rsp_imm8(state.asm, 0x48)
  state.asm = a.pop_reg(state.asm, "rdi")
  state.asm = a.pop_reg(state.asm, "rsi")
  state.asm = a.ret(state.asm)
  return state
end function

function emit_string_slice_function(state)
  state = mem.ensure_gc_data(state)
  state.asm = a.mark(state.asm, "fn_string_slice")
  state.asm = a.sub_rsp_imm8(state.asm, 0x48)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "strslice_fail_" + lid
  l_off_nonneg = "strslice_off_nonneg_" + lid
  l_off_ge0 = "strslice_off_ge0_" + lid
  l_off_ok = "strslice_off_ok_" + lid
  l_len_pos = "strslice_len_pos_" + lid
  l_len_clamped = "strslice_len_clamped_" + lid
  l_need_copy = "strslice_need_copy_" + lid
  l_done = "strslice_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rax", 4)

  state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
  state.asm = a.jcc(state.asm, "ge", l_off_nonneg)
  state.asm = a.add_r64_r64(state.asm, "rax", "r9")
  state.asm = a.mark(state.asm, l_off_nonneg)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
  state.asm = a.jcc(state.asm, "ge", l_off_ge0)
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.mark(state.asm, l_off_ge0)
  state.asm = a.cmp_r64_r64(state.asm, "rax", "r9")
  state.asm = a.jcc(state.asm, "le", l_off_ok)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r9")
  state.asm = a.mark(state.asm, l_off_ok)
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x28, "rax")

  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
  state.asm = a.jcc(state.asm, "g", l_len_pos)
  state.asm = a.lea_rax_rip(state.asm, "obj_empty_string")
  state.asm = a.jmp(state.asm, l_done)
  state.asm = a.mark(state.asm, l_len_pos)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
  state.asm = a.jcc(state.asm, "g", l_fail)
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x30, "eax")

  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x28)
  state.asm = a.mov_r64_r64(state.asm, "r11", "r9")
  state.asm = a.sub_r64_r64(state.asm, "r11", "rax")
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "rsp", 0x30)
  state.asm = a.cmp_r64_r64(state.asm, "r10", "r11")
  state.asm = a.jcc(state.asm, "le", l_len_clamped)
  state.asm = a.mov_r32_r32(state.asm, "r10d", "r11d")
  state.asm = a.mark(state.asm, l_len_clamped)
  state.asm = a.test_r32_r32(state.asm, "r10d", "r10d")
  state.asm = a.jcc(state.asm, "g", l_need_copy)
  state.asm = a.lea_rax_rip(state.asm, "obj_empty_string")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_need_copy)
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x28)
  state.asm = a.test_r32_r32(state.asm, "r11d", "r11d")
  state.asm = a.jcc(state.asm, "ne", l_need_copy + "_full")
  state.asm = a.cmp_r32_r32(state.asm, "r10d", "r9d")
  state.asm = a.jcc(state.asm, "ne", l_need_copy + "_full")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x20)
  state.asm = a.jmp(state.asm, l_done)
  state.asm = a.mark(state.asm, l_need_copy + "_full")

  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x34, "r10d")
  state.asm = a.mov_r32_r32(state.asm, "ecx", "r10d")
  state.asm = a.add_r32_imm(state.asm, "ecx", 9)
  state.asm = a.call(state.asm, "fn_alloc")

  state.asm = a.mov_r11_rax(state.asm)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRING, false)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rsp", 0x34)
  state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "edx")

  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x38, "r11")
  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x20)
  state.asm = a.mov_r64_membase_disp(state.asm, "r9", "rsp", 0x28)
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r11", 8)
  state.asm = a.lea_r64_mem_bis(state.asm, "rdx", "r10", "r9", 1, 8)
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rsp", 0x34)
  state.asm = a.call(state.asm, "fn_copy_bytes")
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x38)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "rsp", 0x34)
  state.asm = a.lea_r64_membase_disp(state.asm, "rax", "r11", 8)
  state.asm = a.add_r64_r64(state.asm, "rax", "r10")
  state.asm = a.mov_membase_disp_imm8(state.asm, "rax", 0, 0)
  state.asm = a.mov_rax_r11(state.asm)

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.mov_r11_rax(state.asm)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x48)
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.add_rsp_imm8(state.asm, 0x48)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_string_indexof_function(state)
  state.asm = a.mark(state.asm, "fn_string_indexof")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "stridx_fail_" + lid
  l_not_found = "stridx_not_found_" + lid
  l_start_nonneg = "stridx_start_nonneg_" + lid
  l_start_in_range = "stridx_start_in_range_" + lid
  l_prepare = "stridx_prepare_" + lid
  l_outer = "stridx_outer_" + lid
  l_inner = "stridx_inner_" + lid
  l_found = "stridx_found_" + lid
  l_done = "stridx_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r11", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r11", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "r11", 4)

  state.asm = a.mov_r64_r64(state.asm, "r10", "rdx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r10", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.and_r64_imm(state.asm, "rdx", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_INT)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.sar_r64_imm8(state.asm, "r8", 3)
  state.asm = a.cmp_r64_imm(state.asm, "r8", 0)
  state.asm = a.jcc(state.asm, "ge", l_start_nonneg)
  state.asm = a.xor_r32_r32(state.asm, "r8d", "r8d")
  state.asm = a.mark(state.asm, l_start_nonneg)
  state.asm = a.cmp_r64_r64(state.asm, "r8", "r9")
  state.asm = a.jcc(state.asm, "le", l_start_in_range)
  state.asm = a.mov_r64_r64(state.asm, "r8", "r9")
  state.asm = a.mark(state.asm, l_start_in_range)

  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r10", 4)
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x20, "edx")
  state.asm = a.test_r32_r32(state.asm, "edx", "edx")
  state.asm = a.jcc(state.asm, "ne", l_prepare)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.shl_r64_imm8(state.asm, "rax", 3)
  state.asm = a.or_r64_imm8(state.asm, "rax", c.TAG_INT)
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_prepare)
  state.asm = a.cmp_r32_r32(state.asm, "edx", "r9d")
  state.asm = a.jcc(state.asm, "g", l_not_found)
  state.asm = a.mov_r32_r32(state.asm, "eax", "r9d")
  state.asm = a.sub_r32_r32(state.asm, "eax", "edx")
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x24, "eax")
  state.asm = a.cmp_r32_r32(state.asm, "r8d", "eax")
  state.asm = a.jcc(state.asm, "g", l_not_found)
  state.asm = a.mov_r32_r32(state.asm, "r9d", "r8d")

  state.asm = a.mark(state.asm, l_outer)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rsp", 0x24)
  state.asm = a.cmp_r32_r32(state.asm, "r9d", "eax")
  state.asm = a.jcc(state.asm, "g", l_not_found)
  state.asm = a.xor_r32_r32(state.asm, "r8d", "r8d")

  state.asm = a.mark(state.asm, l_inner)
  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rsp", 0x20)
  state.asm = a.cmp_r32_r32(state.asm, "r8d", "ecx")
  state.asm = a.jcc(state.asm, "ge", l_found)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r9")
  state.asm = a.add_r64_r64(state.asm, "rax", "r8")
  state.asm = a.lea_r64_mem_bis(state.asm, "rdx", "r11", "rax", 1, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "edx", "rdx", 0)
  state.asm = a.lea_r64_mem_bis(state.asm, "rax", "r10", "r8", 1, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "eax", "rax", 0)
  state.asm = a.cmp_r32_r32(state.asm, "edx", "eax")
  state.asm = a.jcc(state.asm, "ne", l_inner + "_miss")
  state.asm = a.inc_r32(state.asm, "r8d")
  state.asm = a.jmp(state.asm, l_inner)

  state.asm = a.mark(state.asm, l_inner + "_miss")
  state.asm = a.inc_r32(state.asm, "r9d")
  state.asm = a.jmp(state.asm, l_outer)

  state.asm = a.mark(state.asm, l_found)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r9")
  state.asm = a.shl_r64_imm8(state.asm, "rax", 3)
  state.asm = a.or_r64_imm8(state.asm, "rax", c.TAG_INT)
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_not_found)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_int(-1))
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_string_lastindexof_function(state)
  state.asm = a.mark(state.asm, "fn_string_lastindexof")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "strridx_fail_" + lid
  l_not_found = "strridx_not_found_" + lid
  l_prepare = "strridx_prepare_" + lid
  l_outer = "strridx_outer_" + lid
  l_inner = "strridx_inner_" + lid
  l_found = "strridx_found_" + lid
  l_done = "strridx_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r11", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r11", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "r11", 4)

  state.asm = a.mov_r64_r64(state.asm, "r10", "rdx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r10", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r10", 4)
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x20, "edx")
  state.asm = a.test_r32_r32(state.asm, "edx", "edx")
  state.asm = a.jcc(state.asm, "ne", l_prepare)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r9")
  state.asm = a.shl_r64_imm8(state.asm, "rax", 3)
  state.asm = a.or_r64_imm8(state.asm, "rax", c.TAG_INT)
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_prepare)
  state.asm = a.cmp_r32_r32(state.asm, "edx", "r9d")
  state.asm = a.jcc(state.asm, "g", l_not_found)
  state.asm = a.mov_r32_r32(state.asm, "eax", "r9d")
  state.asm = a.sub_r32_r32(state.asm, "eax", "edx")
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x24, "eax")
  state.asm = a.mov_r32_r32(state.asm, "r9d", "eax")

  state.asm = a.mark(state.asm, l_outer)
  state.asm = a.cmp_r32_imm(state.asm, "r9d", 0)
  state.asm = a.jcc(state.asm, "l", l_not_found)
  state.asm = a.xor_r32_r32(state.asm, "r8d", "r8d")

  state.asm = a.mark(state.asm, l_inner)
  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rsp", 0x20)
  state.asm = a.cmp_r32_r32(state.asm, "r8d", "ecx")
  state.asm = a.jcc(state.asm, "ge", l_found)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r9")
  state.asm = a.add_r64_r64(state.asm, "rax", "r8")
  state.asm = a.lea_r64_mem_bis(state.asm, "rdx", "r11", "rax", 1, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "edx", "rdx", 0)
  state.asm = a.lea_r64_mem_bis(state.asm, "rax", "r10", "r8", 1, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "eax", "rax", 0)
  state.asm = a.cmp_r32_r32(state.asm, "edx", "eax")
  state.asm = a.jcc(state.asm, "ne", l_inner + "_miss")
  state.asm = a.inc_r32(state.asm, "r8d")
  state.asm = a.jmp(state.asm, l_inner)

  state.asm = a.mark(state.asm, l_inner + "_miss")
  state.asm = a.dec_r32(state.asm, "r9d")
  state.asm = a.jmp(state.asm, l_outer)

  state.asm = a.mark(state.asm, l_found)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r9")
  state.asm = a.shl_r64_imm8(state.asm, "rax", 3)
  state.asm = a.or_r64_imm8(state.asm, "rax", c.TAG_INT)
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_not_found)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_int(-1))
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_string_startswith_function(state)
  state.asm = a.mark(state.asm, "fn_string_startswith")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_false = "strsw_false_" + lid
  l_true = "strsw_true_" + lid
  l_done = "strsw_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r8", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "r9", "rdx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r9")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r8", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r9", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_false)

  state.asm = a.cmp_r64_r64(state.asm, "r8", "r9")
  state.asm = a.jcc(state.asm, "e", l_true)

  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r8", 4)
  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "r9", 4)
  state.asm = a.test_r32_r32(state.asm, "r11d", "r11d")
  state.asm = a.jcc(state.asm, "e", l_true)
  state.asm = a.cmp_r32_r32(state.asm, "r11d", "r10d")
  state.asm = a.jcc(state.asm, "g", l_false)
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r8", 8)
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r9", 8)
  state.asm = a.mov_r32_r32(state.asm, "r8d", "r11d")
  state.asm = a.call(state.asm, "fn_mem_eq_bytes")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_false)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_true)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_string_endswith_function(state)
  state.asm = a.mark(state.asm, "fn_string_endswith")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_false = "strew_false_" + lid
  l_true = "strew_true_" + lid
  l_done = "strew_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r8", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "r9", "rdx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r9")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r8", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r9", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_false)

  state.asm = a.cmp_r64_r64(state.asm, "r8", "r9")
  state.asm = a.jcc(state.asm, "e", l_true)

  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r8", 4)
  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "r9", 4)
  state.asm = a.test_r32_r32(state.asm, "r11d", "r11d")
  state.asm = a.jcc(state.asm, "e", l_true)
  state.asm = a.cmp_r32_r32(state.asm, "r11d", "r10d")
  state.asm = a.jcc(state.asm, "g", l_false)
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r8", 8)
  state.asm = a.sub_r64_r64(state.asm, "r10", "r11")
  state.asm = a.add_r64_r64(state.asm, "rcx", "r10")
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r9", 8)
  state.asm = a.mov_r32_r32(state.asm, "r8d", "r11d")
  state.asm = a.call(state.asm, "fn_mem_eq_bytes")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_false)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_true)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_string_repeat_function(state)
  state = mem.ensure_gc_data(state)
  state.asm = a.mark(state.asm, "fn_string_repeat")
  state.asm = a.sub_rsp_imm8(state.asm, 0x48)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "strrep_fail_" + lid
  l_count_ok = "strrep_count_ok_" + lid
  l_count_pos = "strrep_count_pos_" + lid
  l_have_total = "strrep_have_total_" + lid
  l_loop = "strrep_loop_" + lid
  l_done = "strrep_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rax", 4)
  state.asm = a.test_r32_r32(state.asm, "r9d", "r9d")
  state.asm = a.jcc(state.asm, "ne", l_count_ok)
  state.asm = a.lea_rax_rip(state.asm, "obj_empty_string")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_count_ok)
  state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_INT)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
  state.asm = a.jcc(state.asm, "g", l_count_pos)
  state.asm = a.lea_rax_rip(state.asm, "obj_empty_string")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_count_pos)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
  state.asm = a.jcc(state.asm, "g", l_fail)
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x28, "eax")

  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r9")
  state.asm = a.imul_r64_r64(state.asm, "rax", "r10")
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
  state.asm = a.jcc(state.asm, "g", l_fail)
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x30, "eax")
  state.asm = a.mark(state.asm, l_have_total)

  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rsp", 0x30)
  state.asm = a.add_r32_imm(state.asm, "ecx", 9)
  state.asm = a.call(state.asm, "fn_alloc")

  state.asm = a.mov_r11_rax(state.asm)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRING, false)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rsp", 0x30)
  state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "edx")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x38, "r11")

  state.asm = a.lea_r64_membase_disp(state.asm, "rax", "r11", 8)
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x40, "rax")

  state.asm = a.mark(state.asm, l_loop)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rsp", 0x28)
  state.asm = a.test_r32_r32(state.asm, "eax", "eax")
  state.asm = a.jcc(state.asm, "e", l_loop + "_done")
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x38)
  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x20)
  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x40)
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r10", 8)
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "r10", 4)
  state.asm = a.call(state.asm, "fn_copy_bytes")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x40)
  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x20)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r10", 4)
  state.asm = a.add_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x40, "rax")
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rsp", 0x28)
  state.asm = a.dec_r32(state.asm, "eax")
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x28, "eax")
  state.asm = a.jmp(state.asm, l_loop)

  state.asm = a.mark(state.asm, l_loop + "_done")
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x38)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "rsp", 0x30)
  state.asm = a.lea_r64_membase_disp(state.asm, "rax", "r11", 8)
  state.asm = a.add_r64_r64(state.asm, "rax", "r10")
  state.asm = a.mov_membase_disp_imm8(state.asm, "rax", 0, 0)
  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.mov_r11_rax(state.asm)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x48)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_string_ltrim_ascii_function(state)
  state.asm = a.mark(state.asm, "fn_string_ltrim_ascii")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "strltrim_fail_" + lid
  l_scan = "strltrim_scan_" + lid
  l_inc = "strltrim_inc_" + lid
  l_found = "strltrim_found_" + lid
  l_done = "strltrim_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r11", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r11", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "r11", 4)
  state.asm = a.test_r32_r32(state.asm, "r9d", "r9d")
  state.asm = a.jcc(state.asm, "e", l_done + "_empty")
  state.asm = a.xor_r32_r32(state.asm, "r8d", "r8d")
  state.asm = a.mark(state.asm, l_scan)
  state.asm = a.cmp_r32_r32(state.asm, "r8d", "r9d")
  state.asm = a.jcc(state.asm, "ge", l_found)
  state.asm = a.lea_r64_mem_bis(state.asm, "rax", "r11", "r8", 1, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "edx", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 32)
  state.asm = a.jcc(state.asm, "e", l_inc)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 9)
  state.asm = a.jcc(state.asm, "e", l_inc)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 10)
  state.asm = a.jcc(state.asm, "e", l_inc)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 13)
  state.asm = a.jcc(state.asm, "ne", l_found)
  state.asm = a.mark(state.asm, l_inc)
  state.asm = a.inc_r32(state.asm, "r8d")
  state.asm = a.jmp(state.asm, l_scan)

  state.asm = a.mark(state.asm, l_found)
  state.asm = a.test_r32_r32(state.asm, "r8d", "r8d")
  state.asm = a.jcc(state.asm, "e", l_done + "_same")
  state.asm = a.cmp_r32_r32(state.asm, "r8d", "r9d")
  state.asm = a.jcc(state.asm, "e", l_done + "_empty")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "r11")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "r8")
  state.asm = a.shl_r64_imm8(state.asm, "rdx", 3)
  state.asm = a.or_r64_imm8(state.asm, "rdx", c.TAG_INT)
  state.asm = a.mov_r32_r32(state.asm, "r10d", "r9d")
  state.asm = a.sub_r32_r32(state.asm, "r10d", "r8d")
  state.asm = a.mov_r64_r64(state.asm, "r8", "r10")
  state.asm = a.shl_r64_imm8(state.asm, "r8", 3)
  state.asm = a.or_r64_imm8(state.asm, "r8", c.TAG_INT)
  state.asm = a.call(state.asm, "fn_string_slice")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_done + "_same")
  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_done + "_empty")
  state.asm = a.lea_rax_rip(state.asm, "obj_empty_string")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_string_rtrim_ascii_function(state)
  state.asm = a.mark(state.asm, "fn_string_rtrim_ascii")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "strrtrim_fail_" + lid
  l_scan = "strrtrim_scan_" + lid
  l_dec = "strrtrim_dec_" + lid
  l_done = "strrtrim_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r11", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r11", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "r11", 4)
  state.asm = a.test_r32_r32(state.asm, "r9d", "r9d")
  state.asm = a.jcc(state.asm, "e", l_done + "_empty")
  state.asm = a.mov_r32_r32(state.asm, "r8d", "r9d")
  state.asm = a.dec_r32(state.asm, "r8d")

  state.asm = a.mark(state.asm, l_scan)
  state.asm = a.cmp_r32_imm(state.asm, "r8d", 0)
  state.asm = a.jcc(state.asm, "l", l_done + "_empty")
  state.asm = a.lea_r64_mem_bis(state.asm, "rax", "r11", "r8", 1, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "edx", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 32)
  state.asm = a.jcc(state.asm, "e", l_dec)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 9)
  state.asm = a.jcc(state.asm, "e", l_dec)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 10)
  state.asm = a.jcc(state.asm, "e", l_dec)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 13)
  state.asm = a.jcc(state.asm, "ne", l_done + "_check")
  state.asm = a.mark(state.asm, l_dec)
  state.asm = a.dec_r32(state.asm, "r8d")
  state.asm = a.jmp(state.asm, l_scan)

  state.asm = a.mark(state.asm, l_done + "_check")
  state.asm = a.mov_r32_r32(state.asm, "eax", "r9d")
  state.asm = a.dec_r32(state.asm, "eax")
  state.asm = a.cmp_r32_r32(state.asm, "r8d", "eax")
  state.asm = a.jcc(state.asm, "e", l_done + "_same")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "r11")
  state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
  state.asm = a.or_r64_imm8(state.asm, "rdx", c.TAG_INT)
  state.asm = a.inc_r64(state.asm, "r8")
  state.asm = a.shl_r64_imm8(state.asm, "r8", 3)
  state.asm = a.or_r64_imm8(state.asm, "r8", c.TAG_INT)
  state.asm = a.call(state.asm, "fn_string_slice")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_done + "_same")
  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_done + "_empty")
  state.asm = a.lea_rax_rip(state.asm, "obj_empty_string")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_string_trim_ascii_function(state)
  state.asm = a.mark(state.asm, "fn_string_trim_ascii")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "strtrim_fail_" + lid
  l_left = "strtrim_left_" + lid
  l_left_inc = "strtrim_left_inc_" + lid
  l_right = "strtrim_right_" + lid
  l_right_dec = "strtrim_right_dec_" + lid
  l_done = "strtrim_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r11", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r11", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "r11", 4)
  state.asm = a.test_r32_r32(state.asm, "r9d", "r9d")
  state.asm = a.jcc(state.asm, "e", l_done + "_empty")
  state.asm = a.xor_r32_r32(state.asm, "r8d", "r8d")

  state.asm = a.mark(state.asm, l_left)
  state.asm = a.cmp_r32_r32(state.asm, "r8d", "r9d")
  state.asm = a.jcc(state.asm, "ge", l_done + "_empty")
  state.asm = a.lea_r64_mem_bis(state.asm, "rax", "r11", "r8", 1, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "edx", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 32)
  state.asm = a.jcc(state.asm, "e", l_left_inc)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 9)
  state.asm = a.jcc(state.asm, "e", l_left_inc)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 10)
  state.asm = a.jcc(state.asm, "e", l_left_inc)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 13)
  state.asm = a.jcc(state.asm, "ne", l_right)
  state.asm = a.mark(state.asm, l_left_inc)
  state.asm = a.inc_r32(state.asm, "r8d")
  state.asm = a.jmp(state.asm, l_left)

  state.asm = a.mark(state.asm, l_right)
  state.asm = a.mov_r32_r32(state.asm, "r10d", "r9d")
  state.asm = a.dec_r32(state.asm, "r10d")
  state.asm = a.mark(state.asm, l_right + "_loop")
  state.asm = a.cmp_r32_r32(state.asm, "r10d", "r8d")
  state.asm = a.jcc(state.asm, "l", l_done + "_empty")
  state.asm = a.lea_r64_mem_bis(state.asm, "rax", "r11", "r10", 1, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "edx", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 32)
  state.asm = a.jcc(state.asm, "e", l_right_dec)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 9)
  state.asm = a.jcc(state.asm, "e", l_right_dec)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 10)
  state.asm = a.jcc(state.asm, "e", l_right_dec)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 13)
  state.asm = a.jcc(state.asm, "ne", l_done + "_check")
  state.asm = a.mark(state.asm, l_right_dec)
  state.asm = a.dec_r32(state.asm, "r10d")
  state.asm = a.jmp(state.asm, l_right + "_loop")

  state.asm = a.mark(state.asm, l_done + "_check")
  state.asm = a.test_r32_r32(state.asm, "r8d", "r8d")
  state.asm = a.jcc(state.asm, "ne", l_done + "_slice")
  state.asm = a.mov_r32_r32(state.asm, "eax", "r9d")
  state.asm = a.dec_r32(state.asm, "eax")
  state.asm = a.cmp_r32_r32(state.asm, "r10d", "eax")
  state.asm = a.jcc(state.asm, "e", l_done + "_same")

  state.asm = a.mark(state.asm, l_done + "_slice")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "r11")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "r8")
  state.asm = a.shl_r64_imm8(state.asm, "rdx", 3)
  state.asm = a.or_r64_imm8(state.asm, "rdx", c.TAG_INT)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.sub_r64_r64(state.asm, "rax", "r8")
  state.asm = a.inc_r64(state.asm, "rax")
  state.asm = a.mov_r64_r64(state.asm, "r8", "rax")
  state.asm = a.shl_r64_imm8(state.asm, "r8", 3)
  state.asm = a.or_r64_imm8(state.asm, "r8", c.TAG_INT)
  state.asm = a.call(state.asm, "fn_string_slice")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_done + "_same")
  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_done + "_empty")
  state.asm = a.lea_rax_rip(state.asm, "obj_empty_string")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_string_is_blank_ascii_function(state)
  state.asm = a.mark(state.asm, "fn_string_is_blank_ascii")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_false = "strblank_false_" + lid
  l_true = "strblank_true_" + lid
  l_loop = "strblank_loop_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r8", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r8", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "r8", 4)
  state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.mark(state.asm, l_loop)
  state.asm = a.cmp_r32_r32(state.asm, "ecx", "r9d")
  state.asm = a.jcc(state.asm, "ge", l_true)
  state.asm = a.lea_r64_mem_bis(state.asm, "rax", "r8", "rcx", 1, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "edx", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 32)
  state.asm = a.jcc(state.asm, "e", l_loop + "_next")
  state.asm = a.cmp_r32_imm(state.asm, "edx", 9)
  state.asm = a.jcc(state.asm, "e", l_loop + "_next")
  state.asm = a.cmp_r32_imm(state.asm, "edx", 10)
  state.asm = a.jcc(state.asm, "e", l_loop + "_next")
  state.asm = a.cmp_r32_imm(state.asm, "edx", 13)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.mark(state.asm, l_loop + "_next")
  state.asm = a.inc_r32(state.asm, "ecx")
  state.asm = a.jmp(state.asm, l_loop)

  state.asm = a.mark(state.asm, l_true)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_false)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
  state.asm = a.ret(state.asm)
  return state
end function

function emit_string_reverse_function(state)
  state = mem.ensure_gc_data(state)
  state.asm = a.mark(state.asm, "fn_string_reverse")
  state.asm = a.sub_rsp_imm8(state.asm, 0x38)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "strrev_fail_" + lid
  l_loop = "strrev_loop_" + lid
  l_done = "strrev_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rax", 4)
  state.asm = a.test_r32_r32(state.asm, "r9d", "r9d")
  state.asm = a.jcc(state.asm, "e", l_done + "_empty")
  state.asm = a.cmp_r32_imm(state.asm, "r9d", 1)
  state.asm = a.jcc(state.asm, "e", l_done + "_same")

  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x28, "r9d")
  state.asm = a.mov_r32_r32(state.asm, "ecx", "r9d")
  state.asm = a.add_r32_imm(state.asm, "ecx", 9)
  state.asm = a.call(state.asm, "fn_alloc")

  state.asm = a.mov_r11_rax(state.asm)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRING, false)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rsp", 0x28)
  state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "edx")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x30, "r11")
  state.asm = a.xor_r32_r32(state.asm, "r8d", "r8d")

  state.asm = a.mark(state.asm, l_loop)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rsp", 0x28)
  state.asm = a.cmp_r32_r32(state.asm, "r8d", "eax")
  state.asm = a.jcc(state.asm, "ge", l_loop + "_done")
  state.asm = a.mov_r32_r32(state.asm, "r10d", "eax")
  state.asm = a.dec_r32(state.asm, "r10d")
  state.asm = a.sub_r32_r32(state.asm, "r10d", "r8d")
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x20)
  state.asm = a.lea_r64_mem_bis(state.asm, "rax", "r11", "r10", 1, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "edx", "rax", 0)
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x30)
  state.asm = a.lea_r64_mem_bis(state.asm, "rax", "r11", "r8", 1, 8)
  state.asm = a.mov_membase_disp_r8(state.asm, "rax", 0, "dl")
  state.asm = a.inc_r32(state.asm, "r8d")
  state.asm = a.jmp(state.asm, l_loop)

  state.asm = a.mark(state.asm, l_loop + "_done")
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x30)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "rsp", 0x28)
  state.asm = a.lea_r64_membase_disp(state.asm, "rax", "r11", 8)
  state.asm = a.add_r64_r64(state.asm, "rax", "r10")
  state.asm = a.mov_membase_disp_imm8(state.asm, "rax", 0, 0)
  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_done + "_same")
  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_done + "_empty")
  state.asm = a.lea_rax_rip(state.asm, "obj_empty_string")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.mov_r11_rax(state.asm)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_string_to_lower_ascii_function(state)
  state = mem.ensure_gc_data(state)
  state.asm = a.mark(state.asm, "fn_string_to_lower_ascii")
  state.asm = a.sub_rsp_imm8(state.asm, 0x38)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "strlower_fail_" + lid
  l_scan = "strlower_scan_" + lid
  l_has_change = "strlower_has_change_" + lid
  l_loop = "strlower_loop_" + lid
  l_done = "strlower_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rax", 4)
  state.asm = a.test_r32_r32(state.asm, "r9d", "r9d")
  state.asm = a.jcc(state.asm, "e", l_done + "_empty")

  state.asm = a.xor_r32_r32(state.asm, "r8d", "r8d")
  state.asm = a.mark(state.asm, l_scan)
  state.asm = a.cmp_r32_r32(state.asm, "r8d", "r9d")
  state.asm = a.jcc(state.asm, "ge", l_done + "_same")
  state.asm = a.lea_r64_mem_bis(state.asm, "r10", "rax", "r8", 1, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "edx", "r10", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 65)
  state.asm = a.jcc(state.asm, "b", l_scan + "_next")
  state.asm = a.cmp_r32_imm(state.asm, "edx", 90)
  state.asm = a.jcc(state.asm, "be", l_has_change)
  state.asm = a.mark(state.asm, l_scan + "_next")
  state.asm = a.inc_r32(state.asm, "r8d")
  state.asm = a.jmp(state.asm, l_scan)

  state.asm = a.mark(state.asm, l_has_change)
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x28, "r9d")
  state.asm = a.mov_r32_r32(state.asm, "ecx", "r9d")
  state.asm = a.add_r32_imm(state.asm, "ecx", 9)
  state.asm = a.call(state.asm, "fn_alloc")
  state.asm = a.mov_r11_rax(state.asm)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRING, false)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rsp", 0x28)
  state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "edx")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x30, "r11")
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r11", 8)
  state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", 0x20)
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "rdx", 8)
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rsp", 0x28)
  state.asm = a.call(state.asm, "fn_copy_bytes")
  state.asm = a.xor_r32_r32(state.asm, "r8d", "r8d")

  state.asm = a.mark(state.asm, l_loop)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rsp", 0x28)
  state.asm = a.cmp_r32_r32(state.asm, "r8d", "eax")
  state.asm = a.jcc(state.asm, "ge", l_loop + "_done")
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x30)
  state.asm = a.lea_r64_mem_bis(state.asm, "r10", "r11", "r8", 1, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "edx", "r10", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 65)
  state.asm = a.jcc(state.asm, "b", l_loop + "_next")
  state.asm = a.cmp_r32_imm(state.asm, "edx", 90)
  state.asm = a.jcc(state.asm, "a", l_loop + "_next")
  state.asm = a.add_r32_imm(state.asm, "edx", 32)
  state.asm = a.mov_membase_disp_r8(state.asm, "r10", 0, "dl")
  state.asm = a.mark(state.asm, l_loop + "_next")
  state.asm = a.inc_r32(state.asm, "r8d")
  state.asm = a.jmp(state.asm, l_loop)

  state.asm = a.mark(state.asm, l_loop + "_done")
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x30)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "rsp", 0x28)
  state.asm = a.lea_r64_membase_disp(state.asm, "rax", "r11", 8)
  state.asm = a.add_r64_r64(state.asm, "rax", "r10")
  state.asm = a.mov_membase_disp_imm8(state.asm, "rax", 0, 0)
  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_done + "_same")
  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_done + "_empty")
  state.asm = a.lea_rax_rip(state.asm, "obj_empty_string")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.mov_r11_rax(state.asm)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_string_to_upper_ascii_function(state)
  state = mem.ensure_gc_data(state)
  state.asm = a.mark(state.asm, "fn_string_to_upper_ascii")
  state.asm = a.sub_rsp_imm8(state.asm, 0x38)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "strupper_fail_" + lid
  l_scan = "strupper_scan_" + lid
  l_has_change = "strupper_has_change_" + lid
  l_loop = "strupper_loop_" + lid
  l_done = "strupper_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rax", 4)
  state.asm = a.test_r32_r32(state.asm, "r9d", "r9d")
  state.asm = a.jcc(state.asm, "e", l_done + "_empty")

  state.asm = a.xor_r32_r32(state.asm, "r8d", "r8d")
  state.asm = a.mark(state.asm, l_scan)
  state.asm = a.cmp_r32_r32(state.asm, "r8d", "r9d")
  state.asm = a.jcc(state.asm, "ge", l_done + "_same")
  state.asm = a.lea_r64_mem_bis(state.asm, "r10", "rax", "r8", 1, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "edx", "r10", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 97)
  state.asm = a.jcc(state.asm, "b", l_scan + "_next")
  state.asm = a.cmp_r32_imm(state.asm, "edx", 122)
  state.asm = a.jcc(state.asm, "be", l_has_change)
  state.asm = a.mark(state.asm, l_scan + "_next")
  state.asm = a.inc_r32(state.asm, "r8d")
  state.asm = a.jmp(state.asm, l_scan)

  state.asm = a.mark(state.asm, l_has_change)
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x28, "r9d")
  state.asm = a.mov_r32_r32(state.asm, "ecx", "r9d")
  state.asm = a.add_r32_imm(state.asm, "ecx", 9)
  state.asm = a.call(state.asm, "fn_alloc")
  state.asm = a.mov_r11_rax(state.asm)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRING, false)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rsp", 0x28)
  state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "edx")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x30, "r11")
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r11", 8)
  state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", 0x20)
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "rdx", 8)
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rsp", 0x28)
  state.asm = a.call(state.asm, "fn_copy_bytes")
  state.asm = a.xor_r32_r32(state.asm, "r8d", "r8d")

  state.asm = a.mark(state.asm, l_loop)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rsp", 0x28)
  state.asm = a.cmp_r32_r32(state.asm, "r8d", "eax")
  state.asm = a.jcc(state.asm, "ge", l_loop + "_done")
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x30)
  state.asm = a.lea_r64_mem_bis(state.asm, "r10", "r11", "r8", 1, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "edx", "r10", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 97)
  state.asm = a.jcc(state.asm, "b", l_loop + "_next")
  state.asm = a.cmp_r32_imm(state.asm, "edx", 122)
  state.asm = a.jcc(state.asm, "a", l_loop + "_next")
  state.asm = a.sub_r32_imm(state.asm, "edx", 32)
  state.asm = a.mov_membase_disp_r8(state.asm, "r10", 0, "dl")
  state.asm = a.mark(state.asm, l_loop + "_next")
  state.asm = a.inc_r32(state.asm, "r8d")
  state.asm = a.jmp(state.asm, l_loop)

  state.asm = a.mark(state.asm, l_loop + "_done")
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x30)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "rsp", 0x28)
  state.asm = a.lea_r64_membase_disp(state.asm, "rax", "r11", 8)
  state.asm = a.add_r64_r64(state.asm, "rax", "r10")
  state.asm = a.mov_membase_disp_imm8(state.asm, "rax", 0, 0)
  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_done + "_same")
  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_done + "_empty")
  state.asm = a.lea_rax_rip(state.asm, "obj_empty_string")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.mov_r11_rax(state.asm)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_string_eq_ignore_case_ascii_function(state)
  state.asm = a.mark(state.asm, "fn_string_eq_ignore_case_ascii")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_false = "streqic_false_" + lid
  l_true = "streqic_true_" + lid
  l_loop = "streqic_loop_" + lid
  l_done = "streqic_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r8", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "r9", "rdx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r9")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r8", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r9", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.cmp_r64_r64(state.asm, "r8", "r9")
  state.asm = a.jcc(state.asm, "e", l_true)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r8", 4)
  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "r9", 4)
  state.asm = a.cmp_r32_r32(state.asm, "r10d", "r11d")
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")

  state.asm = a.mark(state.asm, l_loop)
  state.asm = a.cmp_r32_r32(state.asm, "ecx", "r10d")
  state.asm = a.jcc(state.asm, "ge", l_true)
  state.asm = a.lea_r64_mem_bis(state.asm, "rax", "r8", "rcx", 1, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "edx", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 65)
  state.asm = a.jcc(state.asm, "b", l_loop + "_aok")
  state.asm = a.cmp_r32_imm(state.asm, "edx", 90)
  state.asm = a.jcc(state.asm, "a", l_loop + "_aok")
  state.asm = a.add_r32_imm(state.asm, "edx", 32)
  state.asm = a.mark(state.asm, l_loop + "_aok")
  state.asm = a.lea_r64_mem_bis(state.asm, "rax", "r9", "rcx", 1, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "eax", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", 65)
  state.asm = a.jcc(state.asm, "b", l_loop + "_bok")
  state.asm = a.cmp_r32_imm(state.asm, "eax", 90)
  state.asm = a.jcc(state.asm, "a", l_loop + "_bok")
  state.asm = a.add_r32_imm(state.asm, "eax", 32)
  state.asm = a.mark(state.asm, l_loop + "_bok")
  state.asm = a.cmp_r32_r32(state.asm, "eax", "edx")
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.inc_r32(state.asm, "ecx")
  state.asm = a.jmp(state.asm, l_loop)

  state.asm = a.mark(state.asm, l_true)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_false)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_string_join_function(state)
  state = mem.ensure_gc_data(state)
  state.asm = a.mark(state.asm, "fn_string_join")
  state.asm = a.push_reg(state.asm, "rbx")
  state.asm = a.push_reg(state.asm, "r13")
  state.asm = a.push_reg(state.asm, "r14")
  state.asm = a.sub_rsp_imm8(state.asm, 0x40)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "strjoin_fail_" + lid
  l_len_loop = "strjoin_len_loop_" + lid
  l_copy_loop = "strjoin_copy_loop_" + lid
  l_done = "strjoin_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r8", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "r9", "rdx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r8", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_ARRAY)
  state.asm = a.jcc(state.asm, "e", l_done + "_arr_ok")
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_ARRAY_IMM)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mark(state.asm, l_done + "_arr_ok")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r9")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r9", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.mov_rip_qword_r8(state.asm, "gc_tmp2")
  state.asm = a.mov_rip_qword_r9(state.asm, "gc_tmp3")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "r8")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x28, "r9")

  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r8", 4)
  state.asm = a.test_r32_r32(state.asm, "r10d", "r10d")
  state.asm = a.jcc(state.asm, "e", l_done + "_empty")
  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "r9", 4)
  state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")

  state.asm = a.mark(state.asm, l_len_loop)
  state.asm = a.cmp_r32_r32(state.asm, "ecx", "r10d")
  state.asm = a.jcc(state.asm, "ge", l_len_loop + "_done")
  state.asm = a.mov_r64_mem_bis(state.asm, "rdx", "r8", "rcx", 8, 8)
  state.asm = a.mov_r64_r64(state.asm, "r9", "rdx")
  state.asm = a.and_r64_imm(state.asm, "r9", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rdx", 0)
  state.asm = a.cmp_r32_imm(state.asm, "r9d", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rdx", 4)
  state.asm = a.add_r32_r32(state.asm, "eax", "edx")
  state.asm = a.cmp_r32_imm(state.asm, "ecx", 0)
  state.asm = a.jcc(state.asm, "e", l_len_loop + "_next")
  state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", 0x28)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rdx", 4)
  state.asm = a.add_r32_r32(state.asm, "eax", "edx")
  state.asm = a.mark(state.asm, l_len_loop + "_next")
  state.asm = a.cmp_r32_imm(state.asm, "eax", 0x7FFFFFFF)
  state.asm = a.jcc(state.asm, "g", l_fail)
  state.asm = a.inc_r32(state.asm, "ecx")
  state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", 0x20)
  state.asm = a.jmp(state.asm, l_len_loop)

  state.asm = a.mark(state.asm, l_len_loop + "_done")
  state.asm = a.test_r32_r32(state.asm, "eax", "eax")
  state.asm = a.jcc(state.asm, "e", l_done + "_empty")
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x30, "eax")
  state.asm = a.mov_r32_r32(state.asm, "ecx", "eax")
  state.asm = a.add_r32_imm(state.asm, "ecx", 9)
  state.asm = a.call(state.asm, "fn_alloc")

  state.asm = a.mov_r64_r64(state.asm, "r14", "rax")
  state.asm = a.mov_membase_disp_imm32(state.asm, "r14", 0, c.OBJ_STRING, false)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rsp", 0x30)
  state.asm = a.mov_membase_disp_r32(state.asm, "r14", 4, "edx")
  state.asm = a.xor_r64_r64(state.asm, "r13", "r13")
  state.asm = a.xor_r32_r32(state.asm, "ebx", "ebx")

  state.asm = a.mark(state.asm, l_copy_loop)
  state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", 0x20)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r8", 4)
  state.asm = a.cmp_r32_r32(state.asm, "ebx", "r10d")
  state.asm = a.jcc(state.asm, "ge", l_copy_loop + "_done")

  state.asm = a.cmp_r32_imm(state.asm, "ebx", 0)
  state.asm = a.jcc(state.asm, "e", l_copy_loop + "_no_sep")
  state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", 0x28)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "rdx", 4)
  state.asm = a.test_r32_r32(state.asm, "r10d", "r10d")
  state.asm = a.jcc(state.asm, "e", l_copy_loop + "_no_sep")
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x30, "r10d")
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r14", 8)
  state.asm = a.add_r64_r64(state.asm, "rcx", "r13")
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "rdx", 8)
  state.asm = a.mov_r32_r32(state.asm, "r8d", "r10d")
  state.asm = a.call(state.asm, "fn_copy_bytes")
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "rsp", 0x30)
  state.asm = a.add_r64_r64(state.asm, "r13", "r10")
  state.asm = a.mark(state.asm, l_copy_loop + "_no_sep")

  state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", 0x20)
  state.asm = a.mov_r64_mem_bis(state.asm, "rdx", "r8", "rbx", 8, 8)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "rdx", 4)
  state.asm = a.test_r32_r32(state.asm, "r10d", "r10d")
  state.asm = a.jcc(state.asm, "e", l_copy_loop + "_next")
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x30, "r10d")
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r14", 8)
  state.asm = a.add_r64_r64(state.asm, "rcx", "r13")
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "rdx", 8)
  state.asm = a.mov_r32_r32(state.asm, "r8d", "r10d")
  state.asm = a.call(state.asm, "fn_copy_bytes")
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "rsp", 0x30)
  state.asm = a.add_r64_r64(state.asm, "r13", "r10")
  state.asm = a.mark(state.asm, l_copy_loop + "_next")
  state.asm = a.inc_r32(state.asm, "ebx")
  state.asm = a.jmp(state.asm, l_copy_loop)

  state.asm = a.mark(state.asm, l_copy_loop + "_done")
  state.asm = a.lea_r64_membase_disp(state.asm, "rax", "r14", 8)
  state.asm = a.add_r64_r64(state.asm, "rax", "r13")
  state.asm = a.mov_membase_disp_imm8(state.asm, "rax", 0, 0)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r14")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_done + "_empty")
  state.asm = a.lea_rax_rip(state.asm, "obj_empty_string")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.mov_r11_rax(state.asm)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp2")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp3")
  state.asm = a.mov_rax_r11(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x40)
  state.asm = a.pop_reg(state.asm, "r14")
  state.asm = a.pop_reg(state.asm, "r13")
  state.asm = a.pop_reg(state.asm, "rbx")
  state.asm = a.ret(state.asm)
  return state
end function

function cg_emit_builtins_alloc(state)
  state = emit_input_function(state)
  state = emit_decode_function(state)
  state = emit_decodeZ_function(state)
  state = emit_decode16Z_function(state)
  state = emit_hex_function(state)
  state = emit_fromHex_function(state)
  state = emit_box_float_function(state)
  state = emit_value_to_string_function(state)
  state = emit_string_add_function(state)
  state = emit_array_add_function(state)
  state = emit_bytes_alloc_function(state)
  state = emit_bytes_add_function(state)
  state = emit_bytes_eq_function(state)
  state = emit_slice_function(state)
  state = emit_string_slice_function(state)
  state = emit_string_indexof_function(state)
  state = emit_string_lastindexof_function(state)
  state = emit_string_startswith_function(state)
  state = emit_string_endswith_function(state)
  state = emit_string_repeat_function(state)
  state = emit_string_ltrim_ascii_function(state)
  state = emit_string_rtrim_ascii_function(state)
  state = emit_string_trim_ascii_function(state)
  state = emit_string_is_blank_ascii_function(state)
  state = emit_string_reverse_function(state)
  state = emit_string_to_lower_ascii_function(state)
  state = emit_string_to_upper_ascii_function(state)
  state = emit_string_eq_ignore_case_ascii_function(state)
  state = emit_string_join_function(state)
  return state
end function

