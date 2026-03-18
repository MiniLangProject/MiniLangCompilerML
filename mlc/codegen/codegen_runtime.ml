package mlc.codegen.codegen_runtime
import mlc.asm as a
import mlc.constants as c
import mlc.tools as t

function cg_runtime_init(state)
  return state
end function

// Build an exact 64-bit immediate in RAX from two 32-bit halves.
// This avoids out-of-range MiniLang integer literals in compiler source.
function _emit_mov_rax_u64_hi_lo(state, hi32, lo32)
  state.asm = a.mov_r32_imm32(state.asm, "eax", hi32)
  state.asm = a.shl_rax_imm8(state.asm, 32)
  if lo32 != 0 then
    state.asm = a.mov_r32_imm32(state.asm, "edx", lo32)
    state.asm = a.or_r64_r64(state.asm, "rax", "rdx")
  end if
  return state
end function

// RAX = 0x7FFFFFFFFFFFFFFF without using an out-of-range source literal.
function _emit_mov_rax_i64_max(state)
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.dec_r64(state.asm, "rax")
  state.asm = a.shr_r64_imm8(state.asm, "rax", 1)
  return state
end function

function emit_int_to_dec_function(state)
  state.asm = a.mark(state.asm, "fn_int_to_dec")
  state.asm = a.push_reg(state.asm, "rdi")

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.sar_rax_imm8(state.asm, 3)

  state.asm = a.lea_r9_rip(state.asm, "intbuf_end")
  state.asm = a.mov_r64_r64(state.asm, "rdi", "r9")

  // rax == 0 -> "0"
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "nz", "itd_nonzero")
  state.asm = a.dec_r64(state.asm, "rdi")
  state.asm = a.mov_membase_disp_imm8(state.asm, "rdi", 0, 0x30)
  state.asm = a.mov_r64_r64(state.asm, "rax", "rdi")
  state.asm = a.mov_r32_imm32(state.asm, "edx", 1)
  state.asm = a.pop_reg(state.asm, "rdi")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, "itd_nonzero")
  state.asm = a.xor_r32_r32(state.asm, "r10d", "r10d")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "ge", "itd_pos")
  state.asm = a.neg_r64(state.asm, "rax")
  state.asm = a.mov_r32_imm32(state.asm, "r10d", 1)
  state.asm = a.mark(state.asm, "itd_pos")

  state.asm = a.mark(state.asm, "itd_loop")
  state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
  state.asm = a.mov_r32_imm32(state.asm, "r11d", 10)
  state.asm = a.div_r64(state.asm, "r11")
  state.asm = a.add_r8_imm8(state.asm, "dl", 48)
  state.asm = a.dec_r64(state.asm, "rdi")
  state.asm = a.mov_membase_disp_r8(state.asm, "rdi", 0, "dl")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "nz", "itd_loop")

  state.asm = a.cmp_r32_imm(state.asm, "r10d", 0)
  state.asm = a.jcc(state.asm, "e", "itd_done")
  state.asm = a.dec_r64(state.asm, "rdi")
  state.asm = a.mov_membase_disp_imm8(state.asm, "rdi", 0, 0x2D)

  state.asm = a.mark(state.asm, "itd_done")
  state.asm = a.mov_r64_r64(state.asm, "rax", "rdi")
  state.asm = a.mov_r64_r64(state.asm, "r11", "r9")
  state.asm = a.sub_r64_r64(state.asm, "r11", "rdi")
  state.asm = a.mov_r32_r32(state.asm, "edx", "r11d")
  state.asm = a.pop_reg(state.asm, "rdi")
  state.asm = a.ret(state.asm)
  return state
end function

function emit_toNumber_function(state)
  state.asm = a.mark(state.asm, "fn_toNumber")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_ptr = "ton_ptr_" + lid
  l_float = "ton_float_" + lid
  l_str = "ton_str_" + lid
  l_fail = "ton_fail_" + lid
  l_done = "ton_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.and_r64_imm(state.asm, "rdx", 7)

  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_INT)
  state.asm = a.jcc(state.asm, "e", l_done)

  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "e", l_ptr)

  state.asm = a.jmp(state.asm, l_fail)

  state.asm = a.mark(state.asm, l_ptr)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FLOAT)
  state.asm = a.jcc(state.asm, "e", l_float)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "e", l_str)
  state.asm = a.jmp(state.asm, l_fail)

  state.asm = a.mark(state.asm, l_float)
  state.asm = a.mov_r64_r64(state.asm, "r9", "rax")
  state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm0", "rax", 8)
  state.asm = a.cvttsd2si_r64_xmm(state.asm, "rax", "xmm0")
  state.asm = a.cvtsi2sd_xmm_r64(state.asm, "xmm1", "rax")
  state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm1")
  l_keepf = "ton_keepf_" + lid
  state.asm = a.jcc(state.asm, "ne", l_keepf)
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
  state.asm = a.jmp(state.asm, l_done)
  state.asm = a.mark(state.asm, l_keepf)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r9")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_str)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 4)
  state.asm = a.lea_r64_membase_disp(state.asm, "r8", "rax", 8)
  state.asm = a.mov_r64_r64(state.asm, "r9", "r8")
  state.asm = a.add_r64_r64(state.asm, "r9", "rdx")

  l_tl = "ton_tl_" + lid
  l_tl_done = "ton_tl_done_" + lid
  state.asm = a.mark(state.asm, l_tl)
  state.asm = a.cmp_r64_r64(state.asm, "r8", "r9")
  state.asm = a.jcc(state.asm, "ge", l_tl_done)
  state.asm = a.mov_r8_membase_disp(state.asm, "al", "r8", 0)
  state.asm = a.cmp_r8_imm8(state.asm, "al", 32)
  state.asm = a.jcc(state.asm, "g", l_tl_done)
  state.asm = a.inc_r64(state.asm, "r8")
  state.asm = a.jmp(state.asm, l_tl)
  state.asm = a.mark(state.asm, l_tl_done)

  l_tr = "ton_tr_" + lid
  l_tr_done = "ton_tr_done_" + lid
  state.asm = a.mark(state.asm, l_tr)
  state.asm = a.cmp_r64_r64(state.asm, "r9", "r8")
  state.asm = a.jcc(state.asm, "le", l_tr_done)
  state.asm = a.mov_r8_membase_disp(state.asm, "al", "r9", -1)
  state.asm = a.cmp_r8_imm8(state.asm, "al", 32)
  state.asm = a.jcc(state.asm, "g", l_tr_done)
  state.asm = a.dec_r64(state.asm, "r9")
  state.asm = a.jmp(state.asm, l_tr)
  state.asm = a.mark(state.asm, l_tr_done)

  state.asm = a.cmp_r64_r64(state.asm, "r8", "r9")
  state.asm = a.jcc(state.asm, "e", l_fail)

  state.asm = a.xor_r32_r32(state.asm, "r10d", "r10d")
  state.asm = a.mov_r8_membase_disp(state.asm, "al", "r8", 0)
  state.asm = a.cmp_r8_imm8(state.asm, "al", 45)
  l_nosign = "ton_nosign_" + lid
  state.asm = a.jcc(state.asm, "ne", l_nosign)
  state.asm = a.mov_r32_imm32(state.asm, "r10d", 1)
  state.asm = a.inc_r64(state.asm, "r8")
  state.asm = a.mark(state.asm, l_nosign)

  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
  l_dig = "ton_dig_" + lid
  l_dig_done = "ton_dig_done_" + lid
  state.asm = a.mark(state.asm, l_dig)
  state.asm = a.cmp_r64_r64(state.asm, "r8", "r9")
  state.asm = a.jcc(state.asm, "ge", l_dig_done)
  state.asm = a.movzx_r32_membase_disp(state.asm, "ecx", "r8", 0)
  state.asm = a.cmp_r8_imm8(state.asm, "cl", 48)
  state.asm = a.jcc(state.asm, "l", l_dig_done)
  state.asm = a.cmp_r8_imm8(state.asm, "cl", 57)
  state.asm = a.jcc(state.asm, "g", l_dig_done)
  state.asm = a.imul_r64_r64_imm(state.asm, "rax", "rax", 10)
  state.asm = a.sub_r32_imm(state.asm, "ecx", 48)
  state.asm = a.add_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.inc_r64(state.asm, "r8")
  state.asm = a.inc_r32(state.asm, "edx")
  state.asm = a.jmp(state.asm, l_dig)
  state.asm = a.mark(state.asm, l_dig_done)

  state.asm = a.test_r32_r32(state.asm, "edx", "edx")
  state.asm = a.jcc(state.asm, "z", l_fail)

  l_make_int = "ton_make_int_" + lid
  state.asm = a.cmp_r64_r64(state.asm, "r8", "r9")
  state.asm = a.jcc(state.asm, "e", l_make_int)

  state.asm = a.cmp_membase_disp_imm8(state.asm, "r8", 0, 46)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.inc_r64(state.asm, "r8")

  state.asm = a.xor_r32_r32(state.asm, "r11d", "r11d")
  state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
  l_fd = "ton_fd_" + lid
  l_fd_done = "ton_fd_done_" + lid
  state.asm = a.mark(state.asm, l_fd)
  state.asm = a.cmp_r64_r64(state.asm, "r8", "r9")
  state.asm = a.jcc(state.asm, "ge", l_fd_done)
  state.asm = a.movzx_r32_membase_disp(state.asm, "ecx", "r8", 0)
  state.asm = a.cmp_r8_imm8(state.asm, "cl", 48)
  state.asm = a.jcc(state.asm, "l", l_fd_done)
  state.asm = a.cmp_r8_imm8(state.asm, "cl", 57)
  state.asm = a.jcc(state.asm, "g", l_fd_done)
  state.asm = a.imul_r64_r64_imm(state.asm, "r11", "r11", 10)
  state.asm = a.sub_r32_imm(state.asm, "ecx", 48)
  state.asm = a.add_r64_r64(state.asm, "r11", "rcx")
  state.asm = a.inc_r64(state.asm, "r8")
  state.asm = a.inc_r32(state.asm, "edx")
  state.asm = a.jmp(state.asm, l_fd)
  state.asm = a.mark(state.asm, l_fd_done)

  state.asm = a.test_r32_r32(state.asm, "edx", "edx")
  state.asm = a.jcc(state.asm, "z", l_fail)
  state.asm = a.cmp_r64_r64(state.asm, "r8", "r9")
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.cvtsi2sd_xmm_r64(state.asm, "xmm0", "rax")
  state.asm = a.cvtsi2sd_xmm_r64(state.asm, "xmm1", "r11")
  state = _emit_mov_rax_u64_hi_lo(state, 0x3FF00000, 0)
  state.asm = a.movq_xmm_r64(state.asm, "xmm2", "rax")
  state = _emit_mov_rax_u64_hi_lo(state, 0x40240000, 0)
  state.asm = a.movq_xmm_r64(state.asm, "xmm3", "rax")

  state.asm = a.mov_r32_r32(state.asm, "ecx", "edx")
  l_pow = "ton_pow_" + lid
  l_pow_done = "ton_pow_done_" + lid
  state.asm = a.mark(state.asm, l_pow)
  state.asm = a.test_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.jcc(state.asm, "z", l_pow_done)
  state.asm = a.mulsd_xmm_xmm(state.asm, "xmm2", "xmm3")
  state.asm = a.dec_r32(state.asm, "ecx")
  state.asm = a.jmp(state.asm, l_pow)
  state.asm = a.mark(state.asm, l_pow_done)

  state.asm = a.divsd_xmm_xmm(state.asm, "xmm1", "xmm2")
  state.asm = a.addsd_xmm_xmm(state.asm, "xmm0", "xmm1")

  state.asm = a.cmp_r32_imm(state.asm, "r10d", 0)
  l_pos = "ton_pos_" + lid
  state.asm = a.jcc(state.asm, "e", l_pos)
  state = _emit_mov_rax_u64_hi_lo(state, 0xBFF00000, 0)
  state.asm = a.movq_xmm_r64(state.asm, "xmm3", "rax")
  state.asm = a.mulsd_xmm_xmm(state.asm, "xmm0", "xmm3")
  state.asm = a.mark(state.asm, l_pos)

  state.asm = a.cvttsd2si_r64_xmm(state.asm, "rax", "xmm0")
  state.asm = a.cvtsi2sd_xmm_r64(state.asm, "xmm1", "rax")
  state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm1")
  l_box = "ton_box_" + lid
  state.asm = a.jcc(state.asm, "ne", l_box)
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
  state.asm = a.jmp(state.asm, l_done)
  state.asm = a.mark(state.asm, l_box)
  state.asm = a.call(state.asm, "fn_box_float")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_make_int)
  state.asm = a.cmp_r32_imm(state.asm, "r10d", 0)
  l_mi_pos = "ton_mi_pos_" + lid
  state.asm = a.jcc(state.asm, "e", l_mi_pos)
  state.asm = a.neg_r64(state.asm, "rax")
  state.asm = a.mark(state.asm, l_mi_pos)
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_typeof_function(state)
  state.asm = a.mark(state.asm, "fn_typeof")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_int = "tof_int_" + lid
  l_bool = "tof_bool_" + lid
  l_void = "tof_void_" + lid
  l_enum = "tof_enum_" + lid
  l_ptr = "tof_ptr_" + lid
  l_str = "tof_str_" + lid
  l_arr = "tof_arr_" + lid
  l_flt = "tof_flt_" + lid
  l_bytes = "tof_bytes_" + lid
  l_fun = "tof_fun_" + lid
  l_sti = "tof_sti_" + lid
  l_stt = "tof_stt_" + lid
  l_unk = "tof_unk_" + lid

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.and_r64_imm(state.asm, "rdx", 7)

  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_INT)
  state.asm = a.jcc(state.asm, "e", l_int)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_BOOL)
  state.asm = a.jcc(state.asm, "e", l_bool)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_VOID)
  state.asm = a.jcc(state.asm, "e", l_void)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_ENUM)
  state.asm = a.jcc(state.asm, "e", l_enum)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "e", l_ptr)
  state.asm = a.jmp(state.asm, l_unk)

  state.asm = a.mark(state.asm, l_int)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_int")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_bool)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_bool")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_void)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_void")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_enum)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_enum")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_ptr)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)

  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "e", l_str)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
  state.asm = a.jcc(state.asm, "e", l_arr)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "e", l_bytes)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FLOAT)
  state.asm = a.jcc(state.asm, "e", l_flt)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FUNCTION)
  state.asm = a.jcc(state.asm, "e", l_fun)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BUILTIN)
  state.asm = a.jcc(state.asm, "e", l_fun)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRUCT)
  state.asm = a.jcc(state.asm, "e", l_sti)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRUCTTYPE)
  state.asm = a.jcc(state.asm, "e", l_stt)
  state.asm = a.jmp(state.asm, l_unk)

  state.asm = a.mark(state.asm, l_str)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_string")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_arr)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_array")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_bytes)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_bytes")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_flt)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_float")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_fun)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_function")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_sti)
  l_err = "tof_err_" + lid
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 8)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.ERROR_STRUCT_ID)
  state.asm = a.jcc(state.asm, "e", l_err)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_struct")
  state.asm = a.ret(state.asm)
  state.asm = a.mark(state.asm, l_err)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_error")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_stt)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_struct")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_unk)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_unknown")
  state.asm = a.ret(state.asm)
  return state
end function

function emit_typeName_function(state)
  state.asm = a.mark(state.asm, "fn_typeName")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_int = "tna_int_" + lid
  l_bool = "tna_bool_" + lid
  l_void = "tna_void_" + lid
  l_enum = "tna_enum_" + lid
  l_ptr = "tna_ptr_" + lid
  l_str = "tna_str_" + lid
  l_arr = "tna_arr_" + lid
  l_flt = "tna_flt_" + lid
  l_bytes = "tna_bytes_" + lid
  l_fun = "tna_fun_" + lid
  l_sti = "tna_sti_" + lid
  l_stt = "tna_stt_" + lid
  l_unk = "tna_unk_" + lid

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.and_r64_imm(state.asm, "rdx", 7)

  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_INT)
  state.asm = a.jcc(state.asm, "e", l_int)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_BOOL)
  state.asm = a.jcc(state.asm, "e", l_bool)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_VOID)
  state.asm = a.jcc(state.asm, "e", l_void)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_ENUM)
  state.asm = a.jcc(state.asm, "e", l_enum)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "e", l_ptr)
  state.asm = a.jmp(state.asm, l_unk)

  state.asm = a.mark(state.asm, l_int)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_int")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_bool)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_bool")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_void)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_void")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_enum)
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.shr_r64_imm8(state.asm, "rdx", 3)
  state.asm = a.and_r64_imm(state.asm, "rdx", 0xFFFF)
  if typeof(state.typename_enum_by_id) == "array" and len(state.typename_enum_by_id) > 0 then
    for ei = 0 to len(state.typename_enum_by_id) - 1
      it_e = state.typename_enum_by_id[ei]
      eid = -1
      lbl_e = ""
      if typeof(it_e) == "array" and len(it_e) >= 2 then
        if typeof(it_e[0]) == "int" then eid = it_e[0] end if
        if typeof(it_e[1]) == "string" then lbl_e = it_e[1] end if
      else
        if typeof(it_e) == "struct" then
          if typeof(it_e.key) == "int" then eid = it_e.key end if
          if typeof(it_e.value) == "string" then lbl_e = it_e.value end if
        end if
      end if
      if eid < 0 or lbl_e == "" then continue end if
      l_enext = "tna_e_next_" + eid + "_" + lid + "_" + ei
      state.asm = a.cmp_r32_imm(state.asm, "edx", eid)
      state.asm = a.jcc(state.asm, "ne", l_enext)
      state.asm = a.lea_rax_rip(state.asm, lbl_e)
      state.asm = a.ret(state.asm)
      state.asm = a.mark(state.asm, l_enext)
    end for
  end if
  state.asm = a.lea_rax_rip(state.asm, "obj_type_enum")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_ptr)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "e", l_str)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
  state.asm = a.jcc(state.asm, "e", l_arr)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "e", l_bytes)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FLOAT)
  state.asm = a.jcc(state.asm, "e", l_flt)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FUNCTION)
  state.asm = a.jcc(state.asm, "e", l_fun)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BUILTIN)
  state.asm = a.jcc(state.asm, "e", l_fun)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRUCT)
  state.asm = a.jcc(state.asm, "e", l_sti)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRUCTTYPE)
  state.asm = a.jcc(state.asm, "e", l_stt)
  state.asm = a.jmp(state.asm, l_unk)

  state.asm = a.mark(state.asm, l_str)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_string")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_arr)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_array")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_bytes)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_bytes")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_flt)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_float")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_fun)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_function")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_sti)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 8)
  if typeof(state.typename_struct_by_id) == "array" and len(state.typename_struct_by_id) > 0 then
    for si = 0 to len(state.typename_struct_by_id) - 1
      it_s = state.typename_struct_by_id[si]
      sid = -1
      lbl_s = ""
      if typeof(it_s) == "array" and len(it_s) >= 2 then
        if typeof(it_s[0]) == "int" then sid = it_s[0] end if
        if typeof(it_s[1]) == "string" then lbl_s = it_s[1] end if
      else
        if typeof(it_s) == "struct" then
          if typeof(it_s.key) == "int" then sid = it_s.key end if
          if typeof(it_s.value) == "string" then lbl_s = it_s.value end if
        end if
      end if
      if sid < 0 or lbl_s == "" then continue end if
      l_snext = "tna_s_next_" + sid + "_" + lid + "_" + si
      state.asm = a.cmp_r32_imm(state.asm, "edx", sid)
      state.asm = a.jcc(state.asm, "ne", l_snext)
      state.asm = a.lea_rax_rip(state.asm, lbl_s)
      state.asm = a.ret(state.asm)
      state.asm = a.mark(state.asm, l_snext)
    end for
  end if
  state.asm = a.lea_rax_rip(state.asm, "obj_type_struct")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_stt)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 8)
  if typeof(state.typename_struct_by_id) == "array" and len(state.typename_struct_by_id) > 0 then
    for ti = 0 to len(state.typename_struct_by_id) - 1
      it_t = state.typename_struct_by_id[ti]
      tid = -1
      lbl_t = ""
      if typeof(it_t) == "array" and len(it_t) >= 2 then
        if typeof(it_t[0]) == "int" then tid = it_t[0] end if
        if typeof(it_t[1]) == "string" then lbl_t = it_t[1] end if
      else
        if typeof(it_t) == "struct" then
          if typeof(it_t.key) == "int" then tid = it_t.key end if
          if typeof(it_t.value) == "string" then lbl_t = it_t.value end if
        end if
      end if
      if tid < 0 or lbl_t == "" then continue end if
      l_tnext = "tna_t_next_" + tid + "_" + lid + "_" + ti
      state.asm = a.cmp_r32_imm(state.asm, "edx", tid)
      state.asm = a.jcc(state.asm, "ne", l_tnext)
      state.asm = a.lea_rax_rip(state.asm, lbl_t)
      state.asm = a.ret(state.asm)
      state.asm = a.mark(state.asm, l_tnext)
    end for
  end if
  state.asm = a.lea_rax_rip(state.asm, "obj_type_struct")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_unk)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_unknown")
  state.asm = a.ret(state.asm)
  return state
end function

function emit_strlen_function(state)
  state.asm = a.mark(state.asm, "fn_strlen")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_top = "strlen_top_" + lid
  l_done = "strlen_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
  state.asm = a.mark(state.asm, l_top)
  state.asm = a.cmp_membase_disp_imm8(state.asm, "rax", 0, 0)
  state.asm = a.jcc(state.asm, "e", l_done)
  state.asm = a.inc_r64(state.asm, "rax")
  state.asm = a.inc_r32(state.asm, "edx")
  state.asm = a.jmp(state.asm, l_top)
  state.asm = a.mark(state.asm, l_done)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_string_eq_function(state)
  state.asm = a.mark(state.asm, "fn_str_eq")

  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rcx", 4)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rdx", 4)
  state.asm = a.cmp_r32_r32(state.asm, "r8d", "r9d")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_false0 = "streq_false0_" + lid
  l_false1 = "streq_false1_" + lid
  l_true = "streq_true_" + lid
  l_loop = "streq_loop_" + lid
  l_done = "streq_done_" + lid
  state.asm = a.jcc(state.asm, "ne", l_false0)

  state.asm = a.test_r32_r32(state.asm, "r8d", "r8d")
  state.asm = a.jcc(state.asm, "e", l_true)

  state.asm = a.push_reg(state.asm, "rsi")
  state.asm = a.push_reg(state.asm, "rdi")
  state.asm = a.lea_r64_membase_disp(state.asm, "rsi", "rcx", 8)
  state.asm = a.lea_r64_membase_disp(state.asm, "rdi", "rdx", 8)
  state.asm = a.mov_r32_r32(state.asm, "ecx", "r8d")

  state.asm = a.mark(state.asm, l_loop)
  state.asm = a.mov_r8_membase_disp(state.asm, "al", "rsi", 0)
  state.asm = a.cmp_r8_membase_disp(state.asm, "al", "rdi", 0)
  state.asm = a.jcc(state.asm, "ne", l_false1)
  state.asm = a.inc_r64(state.asm, "rsi")
  state.asm = a.inc_r64(state.asm, "rdi")
  state.asm = a.dec_r32(state.asm, "ecx")
  state.asm = a.jcc(state.asm, "ne", l_loop)

  state.asm = a.pop_reg(state.asm, "rdi")
  state.asm = a.pop_reg(state.asm, "rsi")
  state.asm = a.jmp(state.asm, l_true)

  state.asm = a.mark(state.asm, l_false0)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_false1)
  state.asm = a.pop_reg(state.asm, "rdi")
  state.asm = a.pop_reg(state.asm, "rsi")
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_true)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_value_eq_function(state)
  state.asm = a.mark(state.asm, "fn_val_eq")

  // Save non-volatile regs (Win64 ABI)
  state.asm = a.push_rbx(state.asm)
  state.asm = a.push_reg(state.asm, "rsi")
  state.asm = a.push_reg(state.asm, "rdi")
  state.asm = a.push_r12(state.asm)
  state.asm = a.push_r13(state.asm)
  state.asm = a.push_r14(state.asm)
  state.asm = a.push_r15(state.asm)

  pair_stack_bytes = 0x1000
  frame_bytes = 0x28 + pair_stack_bytes
  state.asm = a.sub_rsp_imm32(state.asm, frame_bytes)

  // r14 = pair-stack base, r13 = top, r15 = end
  state.asm = a.lea_r64_membase_disp(state.asm, "r14", "rsp", 40)
  state.asm = a.mov_r64_r64(state.asm, "r13", "r14")
  state.asm = a.mov_r64_r64(state.asm, "r15", "r14")
  state.asm = a.add_r64_imm(state.asm, "r15", pair_stack_bytes)

  // push initial pair (rcx, rdx)
  state.asm = a.mov_membase_disp_r64(state.asm, "r13", 0, "rcx")
  state.asm = a.mov_membase_disp_r64(state.asm, "r13", 8, "rdx")
  state.asm = a.add_r64_imm(state.asm, "r13", 16)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_loop = "vale_it_loop_" + lid
  l_pop = "vale_it_pop_" + lid
  l_false = "vale_it_false_" + lid
  l_true = "vale_it_true_" + lid
  l_done = "vale_it_done_" + lid
  l_ptr = "vale_it_ptr_" + lid
  l_num = "vale_it_num_" + lid
  l_enum = "vale_it_enum_" + lid
  l_is_arr = "vale_it_is_arr_" + lid
  l_is_flt = "vale_it_is_flt_" + lid
  l_is_other = "vale_it_is_other_" + lid
  l_ap_loop = "vale_it_ap_loop_" + lid
  l_ap_done = "vale_it_ap_done_" + lid
  l_num_mix = "vale_it_num_mix_" + lid
  l_v1_imm = "vale_it_v1_imm_" + lid
  l_v1_done = "vale_it_v1_done_" + lid
  l_v2_imm = "vale_it_v2_imm_" + lid
  l_v2_done = "vale_it_v2_done_" + lid

  state.asm = a.mark(state.asm, l_loop)
  // while top != base
  state.asm = a.cmp_r64_r64(state.asm, "r13", "r14")
  state.asm = a.jcc(state.asm, "e", l_true)

  state.asm = a.mark(state.asm, l_pop)
  state.asm = a.sub_r64_imm(state.asm, "r13", 16)
  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "r13", 0)
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "r13", 8)

  // Fast identity
  state.asm = a.cmp_r64_r64(state.asm, "r10", "r11")
  state.asm = a.jcc(state.asm, "e", l_loop)

  // tag1 -> r8, tag2 -> r9
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.and_rax_imm8(state.asm, 7)
  state.asm = a.mov_r64_r64(state.asm, "r8", "rax")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
  state.asm = a.and_rax_imm8(state.asm, 7)
  state.asm = a.mov_r64_r64(state.asm, "r9", "rax")

  // enum equality is identity-only (handled above)
  state.asm = a.cmp_r64_imm(state.asm, "r8", c.TAG_ENUM)
  state.asm = a.jcc(state.asm, "e", l_enum)
  state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_ENUM)
  state.asm = a.jcc(state.asm, "e", l_enum)

  // both pointers -> pointer path, else numeric path
  state.asm = a.cmp_r64_imm(state.asm, "r8", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_num)
  state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "e", l_ptr)
  state.asm = a.jmp(state.asm, l_num)

  // ---- pointer path ----
  state.asm = a.mark(state.asm, l_ptr)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r10", 0)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
  state.asm = a.cmp_r32_r32(state.asm, "eax", "edx")
  state.asm = a.jcc(state.asm, "ne", l_false)

  // OBJ_STRING -> content compare
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_is_arr)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "r10")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
  state.asm = a.call(state.asm, "fn_str_eq")
  state.asm = a.cmp_rax_imm32(state.asm, t.enc_bool(true))
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.jmp(state.asm, l_loop)

  // OBJ_ARRAY -> deep compare via explicit pair stack
  state.asm = a.mark(state.asm, l_is_arr)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_ARRAY)
  state.asm = a.jcc(state.asm, "ne", l_is_flt)
  state.asm = a.mov_r32_membase_disp(state.asm, "ebx", "r10", 4)
  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "r11", 4)
  state.asm = a.cmp_r32_r32(state.asm, "ebx", "ecx")
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.test_r32_r32(state.asm, "ebx", "ebx")
  state.asm = a.jcc(state.asm, "e", l_loop)

  state.asm = a.lea_r64_membase_disp(state.asm, "rsi", "r10", 8)
  state.asm = a.lea_r64_membase_disp(state.asm, "rdi", "r11", 8)
  state.asm = a.xor_r32_r32(state.asm, "r9d", "r9d")

  state.asm = a.mark(state.asm, l_ap_loop)
  state.asm = a.cmp_r32_r32(state.asm, "r9d", "ebx")
  state.asm = a.jcc(state.asm, "ge", l_ap_done)

  // if top+16 > end, avoid stack overflow and fail
  state.asm = a.mov_r64_r64(state.asm, "rax", "r13")
  state.asm = a.add_r64_imm(state.asm, "rax", 16)
  state.asm = a.cmp_r64_r64(state.asm, "rax", "r15")
  state.asm = a.jcc(state.asm, "a", l_false)

  state.asm = a.mov_r64_mem_bis(state.asm, "rax", "rsi", "r9", 8, 0)
  state.asm = a.mov_r64_mem_bis(state.asm, "rdx", "rdi", "r9", 8, 0)
  state.asm = a.mov_membase_disp_r64(state.asm, "r13", 0, "rax")
  state.asm = a.mov_membase_disp_r64(state.asm, "r13", 8, "rdx")
  state.asm = a.add_r64_imm(state.asm, "r13", 16)
  state.asm = a.inc_r32(state.asm, "r9d")
  state.asm = a.jmp(state.asm, l_ap_loop)

  state.asm = a.mark(state.asm, l_ap_done)
  state.asm = a.jmp(state.asm, l_loop)

  // OBJ_FLOAT -> numeric double compare
  state.asm = a.mark(state.asm, l_is_flt)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_FLOAT)
  state.asm = a.jcc(state.asm, "ne", l_is_other)
  state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm0", "r10", 8)
  state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm1", "r11", 8)
  state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm1")
  state.asm = a.jcc(state.asm, "p", l_false)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.jmp(state.asm, l_loop)

  // Other heap objects: identity-only
  state.asm = a.mark(state.asm, l_is_other)
  state.asm = a.jmp(state.asm, l_false)

  // ---- numeric path (int/bool/float mix) ----
  state.asm = a.mark(state.asm, l_num)
  state.asm = a.cmp_r64_imm(state.asm, "r8", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "e", l_num_mix)
  state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "e", l_num_mix)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
  state.asm = a.sar_r64_imm8(state.asm, "rdx", 3)
  state.asm = a.cmp_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.jmp(state.asm, l_loop)

  state.asm = a.mark(state.asm, l_num_mix)
  // v1 -> xmm0
  state.asm = a.cmp_r64_imm(state.asm, "r8", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_v1_imm)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r10", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_FLOAT)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm0", "r10", 8)
  state.asm = a.jmp(state.asm, l_v1_done)

  state.asm = a.mark(state.asm, l_v1_imm)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.cvtsi2sd_xmm_r64(state.asm, "xmm0", "rax")

  state.asm = a.mark(state.asm, l_v1_done)
  // v2 -> xmm1
  state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_v2_imm)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FLOAT)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm1", "r11", 8)
  state.asm = a.jmp(state.asm, l_v2_done)

  state.asm = a.mark(state.asm, l_v2_imm)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.cvtsi2sd_xmm_r64(state.asm, "xmm1", "rax")

  state.asm = a.mark(state.asm, l_v2_done)
  state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm1")
  state.asm = a.jcc(state.asm, "p", l_false)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.jmp(state.asm, l_loop)

  // ---- return paths ----
  state.asm = a.mark(state.asm, l_true)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_enum)
  state.asm = a.jmp(state.asm, l_false)

  state.asm = a.mark(state.asm, l_false)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.add_rsp_imm32(state.asm, frame_bytes)
  state.asm = a.pop_r15(state.asm)
  state.asm = a.pop_r14(state.asm)
  state.asm = a.pop_r13(state.asm)
  state.asm = a.pop_r12(state.asm)
  state.asm = a.pop_reg(state.asm, "rdi")
  state.asm = a.pop_reg(state.asm, "rsi")
  state.asm = a.pop_rbx(state.asm)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_unhandled_error_exit_function(state)
  // WriteFile(stdout, rdx=ptr, r8d=len)
  // caller must provide shadow space at [rsp+0x20].
  // Uses rbx as cached stdout HANDLE.
  function _emit_writefile_ptr_len(state2)
    state2.asm = a.mov_r64_r64(state2.asm, "rcx", "rbx")
    state2.asm = a.lea_r9_rip(state2.asm, "bytesWritten")
    state2.asm = a.mov_qword_ptr_rsp20_rax_zero(state2.asm)
    state2.asm = a.mov_rax_rip_qword(state2.asm, "iat_WriteFile")
    state2.asm = a.call_rax(state2.asm)
    return state2
  end function

  function _emit_writefile(state2, lbl, ln)
    state2.asm = a.lea_rdx_rip(state2.asm, lbl)
    state2.asm = a.mov_r8d_imm32(state2.asm, ln)
    return _emit_writefile_ptr_len(state2)
  end function

  state.asm = a.mark(state.asm, "fn_unhandled_error_exit")
  state.asm = a.sub_rsp_imm8(state.asm, 0x68)

  // Save error fields to local slots.
  state.asm = a.mov_r64_r64(state.asm, "r11", "rcx")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r11", 16)  // code
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x30, "rax")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r11", 24)  // message
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x38, "rax")

  lid_nf = state.label_id
  state.label_id = state.label_id + 1
  l_nf_old = "unh_nf_old_" + lid_nf
  l_nf_done = "unh_nf_done_" + lid_nf

  // Guard origin fields for legacy 2-field error objects.
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 4)  // nfields
  state.asm = a.cmp_r32_imm(state.asm, "edx", 5)
  state.asm = a.jcc(state.asm, "l", l_nf_old)

  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r11", 32)  // script
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x40, "rax")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r11", 40)  // func
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x48, "rax")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r11", 48)  // line
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x50, "rax")
  state.asm = a.jmp(state.asm, l_nf_done)

  state.asm = a.mark(state.asm, l_nf_old)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x40, "rax")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x48, "rax")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x50, "rax")
  state.asm = a.mark(state.asm, l_nf_done)

  // "Error occured: no="
  state = _emit_writefile(state, "err_occ_prefix", 18)

  // Print code
  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x30)
  state.asm = a.call(state.asm, "fn_int_to_dec")
  state.asm = a.mov_r32_r32(state.asm, "r8d", "edx")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state = _emit_writefile_ptr_len(state)

  // " message="
  state = _emit_writefile(state, "err_occ_mid", 9)

  // Print message through value_to_string.
  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x38)
  state.asm = a.call(state.asm, "fn_value_to_string")
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rax", 4)
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "rax", 8)
  state = _emit_writefile_ptr_len(state)

  state = _emit_writefile(state, "nl", 1)

  // Optional origin line: "  at <script>:<line> in <func>"
  lid = state.label_id
  state.label_id = state.label_id + 1
  l_skip = "unh_loc_skip_" + lid
  l_exit = "unh_loc_exit_" + lid

  // script must be non-empty string
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x40)
  state.asm = a.mov_r64_r64(state.asm, "r10", "r11")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_skip)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_skip)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 4)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 0)
  state.asm = a.jcc(state.asm, "e", l_skip)

  // line must be positive tagged int
  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x50)
  state.asm = a.mov_r64_r64(state.asm, "r9", "r10")
  state.asm = a.and_r64_imm(state.asm, "r9", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_INT)
  state.asm = a.jcc(state.asm, "ne", l_skip)
  state.asm = a.cmp_r64_imm(state.asm, "r10", t.enc_int(0))
  state.asm = a.jcc(state.asm, "le", l_skip)

  state = _emit_writefile(state, "err_occ_at", 5)

  // Reload script ptr after call clobbers.
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x40)
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "r11", 4)
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r11", 8)
  state = _emit_writefile_ptr_len(state)

  state = _emit_writefile(state, "err_occ_colon", 1)

  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x50)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "r10")
  state.asm = a.call(state.asm, "fn_int_to_dec")
  state.asm = a.mov_r32_r32(state.asm, "r8d", "edx")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state = _emit_writefile_ptr_len(state)

  // func must be string
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x48)
  state.asm = a.mov_r64_r64(state.asm, "r10", "r11")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_exit)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_exit)

  state = _emit_writefile(state, "err_occ_in", 4)
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x48)
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "r11", 4)
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r11", 8)
  state = _emit_writefile_ptr_len(state)
  state = _emit_writefile(state, "nl", 1)
  state.asm = a.jmp(state.asm, l_exit)

  state.asm = a.mark(state.asm, l_skip)
  state.asm = a.jmp(state.asm, l_exit)

  state.asm = a.mark(state.asm, l_exit)
  state.asm = a.mov_rcx_imm32(state.asm, 1)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_ExitProcess")
  state.asm = a.call_rax(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x68)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_init_argvw_function(state)
  state.asm = a.mark(state.asm, "fn_init_argvw")

  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_ok = "argvw_ok_" + lid
  l_done = "argvw_done_" + lid

  state.asm = a.mov_rax_rip_qword(state.asm, "iat_GetCommandLineW")
  state.asm = a.call_rax(state.asm)

  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.lea_rdx_rip(state.asm, "ml_argc")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_CommandLineToArgvW")
  state.asm = a.call_rax(state.asm)

  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "ne", l_ok)
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.mov_rip_dword_eax(state.asm, "ml_argc")
  state.asm = a.xor_r64_r64(state.asm, "rax", "rax")
  state.asm = a.mov_rip_qword_rax(state.asm, "ml_argvw")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_ok)
  state.asm = a.mov_rip_qword_rax(state.asm, "ml_argvw")

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_build_args_function(state)
  state.asm = a.mark(state.asm, "fn_build_args")
  // Frame:
  // [rsp+0x40] array_base (qword)
  // [rsp+0x48] n (dword)
  // [rsp+0x4C] i (dword)
  // [rsp+0x50] argvw (qword)
  // [rsp+0x58] wide_ptr (qword)
  // [rsp+0x60] tmp (dword)
  // [rsp+0x64] len (dword)
  state.asm = a.sub_rsp_imm32(state.asm, 0x88)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_n0 = "args_n0_" + lid
  l_loop = "args_loop_" + lid
  l_done = "args_done_" + lid
  l_len0 = "args_len0_" + lid
  l_free = "args_free_" + lid
  l_done_alloc = l_done + "_alloc"
  l_len0_done = l_len0 + "_done"
  l_free_skip = l_free + "_skip"

  state.asm = a.call(state.asm, "fn_init_argvw")

  // n = max(ml_argc - 1, 0)
  state.asm = a.mov_eax_rip_dword(state.asm, "ml_argc")
  state.asm = a.cmp_r32_imm(state.asm, "eax", 1)
  state.asm = a.jcc(state.asm, "le", l_n0)
  state.asm = a.sub_r32_imm(state.asm, "eax", 1)
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x48, "eax")
  state.asm = a.jmp(state.asm, l_done_alloc)

  state.asm = a.mark(state.asm, l_n0)
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x48, "eax")

  state.asm = a.mark(state.asm, l_done_alloc)
  state.asm = a.mov_rax_rip_qword(state.asm, "ml_argvw")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x50, "rax")

  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x4C, 0, false)

  // Allocate OBJ_ARRAY: size = 8 + n*8
  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rsp", 0x48)
  state.asm = a.shl_r32_imm8(state.asm, "ecx", 3)
  state.asm = a.add_r32_imm(state.asm, "ecx", 8)
  state.asm = a.call(state.asm, "fn_alloc")

  state.asm = a.mov_r11_rax(state.asm)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_ARRAY, false)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rsp", 0x48)
  state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "eax")

  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x40, "r11")
  state.asm = a.mov_rip_qword_r11(state.asm, "gc_tmp0")

  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rsp", 0x48)
  state.asm = a.test_r32_r32(state.asm, "eax", "eax")
  state.asm = a.jcc(state.asm, "e", l_free)

  state.asm = a.mark(state.asm, l_loop)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rsp", 0x4C)
  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rsp", 0x48)
  state.asm = a.cmp_r32_r32(state.asm, "eax", "ecx")
  state.asm = a.jcc(state.asm, "ge", l_free)

  // wide_ptr = argvw[i+1]
  state.asm = a.mov_r32_r32(state.asm, "edx", "eax")
  state.asm = a.add_r32_imm(state.asm, "edx", 1)
  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x50)
  state.asm = a.shl_r64_imm8(state.asm, "rdx", 3)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.add_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rax", 0)
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x58, "r8")

  // bytes_with_nul = WideCharToMultiByte(..., NULL, 0, NULL, NULL)
  state.asm = a.mov_r32_imm32(state.asm, "ecx", 65001)
  state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
  state.asm = a.mov_r32_imm32(state.asm, "r9d", 0xFFFFFFFF)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x28, 0, true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x30, 0, true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x38, 0, true)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WideCharToMultiByte")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x60, "eax")

  // len = max(bytes_with_nul - 1, 0)
  state.asm = a.test_r32_r32(state.asm, "eax", "eax")
  state.asm = a.jcc(state.asm, "e", l_len0)
  state.asm = a.sub_r32_imm(state.asm, "eax", 1)
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x64, "eax")
  state.asm = a.jmp(state.asm, l_len0_done)

  state.asm = a.mark(state.asm, l_len0)
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x64, "eax")

  state.asm = a.mark(state.asm, l_len0_done)

  // Allocate OBJ_STRING: size = 9 + len
  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rsp", 0x64)
  state.asm = a.add_r32_imm(state.asm, "ecx", 9)
  state.asm = a.call(state.asm, "fn_alloc")

  state.asm = a.mov_r11_rax(state.asm)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_STRING, false)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rsp", 0x64)
  state.asm = a.mov_membase_disp_r32(state.asm, "r11", 4, "eax")

  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x68, "r11")
  state.asm = a.lea_r64_membase_disp(state.asm, "r10", "r11", 8)
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x70, "r10")

  // WideCharToMultiByte(..., dest, len+1, NULL, NULL)
  state.asm = a.mov_r32_imm32(state.asm, "ecx", 65001)
  state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
  state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", 0x58)
  state.asm = a.mov_r32_imm32(state.asm, "r9d", 0xFFFFFFFF)
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "r10")
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x28, 0, true)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rsp", 0x64)
  state.asm = a.add_r32_imm(state.asm, "eax", 1)
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x28, "eax")
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x30, 0, true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x38, 0, true)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WideCharToMultiByte")
  state.asm = a.call_rax(state.asm)

  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x70)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rsp", 0x64)
  state.asm = a.add_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.mov_membase_disp_imm8(state.asm, "rax", 0, 0)

  // array[i] = string_ptr
  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x40)
  state.asm = a.lea_r64_membase_disp(state.asm, "rax", "r10", 8)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rsp", 0x4C)
  state.asm = a.shl_r64_imm8(state.asm, "rdx", 3)
  state.asm = a.add_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x68)
  state.asm = a.mov_membase_disp_r64(state.asm, "rax", 0, "r11")

  // i++
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rsp", 0x4C)
  state.asm = a.add_r32_imm(state.asm, "eax", 1)
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x4C, "eax")
  state.asm = a.jmp(state.asm, l_loop)

  state.asm = a.mark(state.asm, l_free)
  state.asm = a.mov_rax_rip_qword(state.asm, "ml_argvw")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", l_free_skip)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_LocalFree")
  state.asm = a.call_rax(state.asm)

  state.asm = a.mark(state.asm, l_free_skip)
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.mov_rip_dword_eax(state.asm, "ml_argc")
  state.asm = a.xor_r64_r64(state.asm, "rax", "rax")
  state.asm = a.mov_rip_qword_rax(state.asm, "ml_argvw")

  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x40)
  state.asm = a.add_rsp_imm32(state.asm, 0x88)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_builtin_len_function(state)
  state.asm = a.mark(state.asm, "fn_builtin_len")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_ok = "bl_ok_" + lid
  l_ret0 = "bl_ret0_" + lid

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")

  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.and_r64_imm(state.asm, "r10", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r10", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_ret0)

  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "e", l_ok)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
  state.asm = a.jcc(state.asm, "e", l_ok)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "e", l_ok)
  state.asm = a.jmp(state.asm, l_ret0)

  state.asm = a.mark(state.asm, l_ok)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 4)
  state.asm = a.mov_r32_r32(state.asm, "eax", "edx")
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_ret0)
  state.asm = a.mov_rax_imm64(state.asm, c.TAG_INT)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_builtin_input_function(state)
  state.asm = a.mark(state.asm, "fn_builtin_input")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_call = "bi_call_" + lid
  l_ret_void = "bi_ret_void_" + lid

  state.asm = a.cmp_r32_imm(state.asm, "r10d", 0)
  state.asm = a.jcc(state.asm, "e", l_call)
  state.asm = a.cmp_r32_imm(state.asm, "r10d", 1)
  state.asm = a.jcc(state.asm, "e", l_call)
  state.asm = a.jmp(state.asm, l_ret_void)

  state.asm = a.mark(state.asm, l_call)
  state.asm = a.call(state.asm, "fn_input")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_ret_void)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.ret(state.asm)
  return state
end function

function emit_builtin_gc_collect_function(state)
  state.asm = a.mark(state.asm, "fn_builtin_gc_collect")
  state.asm = a.call(state.asm, "fn_gc_collect")
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.ret(state.asm)
  return state
end function

function emit_builtin_gc_set_limit_function(state)
  state.asm = a.mark(state.asm, "fn_builtin_gc_set_limit")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_call = "bgsl_call_" + lid
  l_ret_void = "bgsl_ret_void_" + lid
  l_disable = "bgsl_disable_" + lid
  l_done = "bgsl_done_" + lid
  l_not_int = "bgsl_not_int_" + lid

  state.asm = a.cmp_r32_imm(state.asm, "r10d", 1)
  state.asm = a.jcc(state.asm, "e", l_call)
  state.asm = a.jmp(state.asm, l_ret_void)

  state.asm = a.mark(state.asm, l_call)

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.and_r64_imm(state.asm, "rdx", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_INT)
  state.asm = a.jcc(state.asm, "ne", l_not_int)

  state.asm = a.sar_rax_imm8(state.asm, 3)

  state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
  state.asm = a.jcc(state.asm, "le", l_disable)

  state.asm = a.mov_rip_qword_rax(state.asm, "gc_bytes_limit")
  state.asm = a.mov_rax_imm64(state.asm, 0)
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_bytes_since")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_not_int)
  state.asm = a.jmp(state.asm, l_disable)

  state.asm = a.mark(state.asm, l_disable)
  state = _emit_mov_rax_i64_max(state)
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_bytes_limit")
  state.asm = a.mov_rax_imm64(state.asm, 0)
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_bytes_since")

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_ret_void)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.ret(state.asm)
  return state
end function

function emit_callStats_function(state)
  state.asm = a.mark(state.asm, "fn_callStats")

  if state.call_profile == false then
    state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
    state.asm = a.ret(state.asm)
    return state
  end if

  n = 0
  if typeof(state.callprof_n) == "int" and state.callprof_n > 0 then n = state.callprof_n end if
  name_labels = []
  if typeof(state.callprof_name_labels) == "array" then name_labels = state.callprof_name_labels end if

  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  // Allocate OBJ_ARRAY: size = 8 + n*8
  state.asm = a.mov_r32_imm32(state.asm, "ecx", n)
  state.asm = a.shl_r32_imm8(state.asm, "ecx", 3)
  state.asm = a.add_r32_imm(state.asm, "ecx", 8)
  state.asm = a.call(state.asm, "fn_alloc")

  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, c.OBJ_ARRAY, false)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 4, n, false)

  // Save array ptr and root during nested allocations.
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "r11")
  state.asm = a.mov_rip_qword_r11(state.asm, "gc_tmp0")

  if n > 0 then
    for i = 0 to n - 1
      // Allocate callStat struct: 16-byte header + 2 fields.
      state.asm = a.mov_rcx_imm32(state.asm, 32)
      state.asm = a.call(state.asm, "fn_alloc")
      state.asm = a.mov_r64_r64(state.asm, "r10", "rax")

      state.asm = a.mov_membase_disp_imm32(state.asm, "r10", 0, c.OBJ_STRUCT, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r10", 4, 2, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r10", 8, c.CALLSTAT_STRUCT_ID, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r10", 12, 0, false)

      if i < len(name_labels) and typeof(name_labels[i]) == "string" and name_labels[i] != "" then
        state.asm = a.lea_rax_rip(state.asm, name_labels[i])
        state.asm = a.mov_membase_disp_r64(state.asm, "r10", 16, "rax")
      else
        state.asm = a.mov_membase_disp_imm32(state.asm, "r10", 16, t.enc_void(), true)
      end if

      // field1 = tagged call count from callprof_counts[i]
      state.asm = a.lea_r11_rip(state.asm, "callprof_counts")
      state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r11", i * 8)
      state.asm = a.shl_r64_imm8(state.asm, "rax", 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
      state.asm = a.mov_membase_disp_r64(state.asm, "r10", 24, "rax")

      // array[i] = struct
      state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x20)
      state.asm = a.mov_membase_disp_r64(state.asm, "r11", 8 + i * 8, "r10")
    end for
  end if

  // Unroot temp and return array pointer.
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp0")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x20)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function
