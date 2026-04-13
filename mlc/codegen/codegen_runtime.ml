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
  imax = toNumber("9223372036854775807")
  if typeof(imax) == "int" then
    state.asm = a.mov_rax_imm64(state.asm, imax)
    return state
  end if
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.dec_r64(state.asm, "rax")
  state.asm = a.shr_r64_imm8(state.asm, "rax", 1)
  return state
end function

function _emit_to_double_xmm(state, xmm, fail_label)
  lid = state.label_id
  state.label_id = state.label_id + 1
  l_int = "todbl_int_" + lid
  l_immf = "todbl_immf_" + lid
  l_ptr = "todbl_ptr_" + lid
  l_done = "todbl_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.and_r64_imm(state.asm, "rdx", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_INT)
  state.asm = a.jcc(state.asm, "e", l_int)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_FLOAT)
  state.asm = a.jcc(state.asm, "e", l_immf)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "e", l_ptr)
  state.asm = a.jmp(state.asm, fail_label)

  state.asm = a.mark(state.asm, l_int)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.sar_r64_imm8(state.asm, "rcx", 3)
  if xmm == 1 or xmm == "xmm1" then
    state.asm = a.cvtsi2sd_xmm_r64(state.asm, "xmm1", "rcx")
  else
    state.asm = a.cvtsi2sd_xmm_r64(state.asm, "xmm0", "rcx")
  end if
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_immf)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.shr_r64_imm8(state.asm, "rcx", 3)
  if xmm == 1 or xmm == "xmm1" then
    state.asm = a.movq_xmm_r64(state.asm, "xmm1", "rcx")
    state.asm = a.cvtss2sd_xmm_xmm(state.asm, "xmm1", "xmm1")
  else
    state.asm = a.movq_xmm_r64(state.asm, "xmm0", "rcx")
    state.asm = a.cvtss2sd_xmm_xmm(state.asm, "xmm0", "xmm0")
  end if
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_ptr)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FLOAT)
  state.asm = a.jcc(state.asm, "ne", fail_label)
  if xmm == 1 or xmm == "xmm1" then
    state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm1", "rax", 8)
  else
    state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm0", "rax", 8)
  end if

  state.asm = a.mark(state.asm, l_done)
  return state
end function

function _emit_normalize_xmm0_to_value(state)
  lid = state.label_id
  state.label_id = state.label_id + 1
  l_int = "norm_int_" + lid
  l_try_immf = "norm_try_immf_" + lid
  l_box = "norm_box_" + lid
  l_end = "norm_end_" + lid

  state.asm = a.cvttsd2si_r64_xmm(state.asm, "rax", "xmm0")
  state.asm = a.cvtsi2sd_xmm_r64(state.asm, "xmm1", "rax")
  state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm1")
  state.asm = a.jcc(state.asm, "e", l_int)
  state.asm = a.jmp(state.asm, l_try_immf)

  state.asm = a.mark(state.asm, l_int)
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
  state.asm = a.jmp(state.asm, l_end)

  state.asm = a.mark(state.asm, l_try_immf)
  state.asm = a.cvtsd2ss_xmm_xmm(state.asm, "xmm2", "xmm0")
  state.asm = a.cvtss2sd_xmm_xmm(state.asm, "xmm3", "xmm2")
  state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm3")
  state.asm = a.jcc(state.asm, "ne", l_box)
  state.asm = a.jcc(state.asm, "p", l_box)
  state.asm = a.movd_r32_xmm(state.asm, "eax", "xmm2")
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_FLOAT)
  state.asm = a.jmp(state.asm, l_end)

  state.asm = a.mark(state.asm, l_box)
  state.asm = a.call(state.asm, "fn_box_float")

  state.asm = a.mark(state.asm, l_end)
  return state
end function

function _emit_force_xmm0_to_float_value(state)
  lid = state.label_id
  state.label_id = state.label_id + 1
  l_box = "forcef_box_" + lid
  l_end = "forcef_end_" + lid

  state.asm = a.cvtsd2ss_xmm_xmm(state.asm, "xmm2", "xmm0")
  state.asm = a.cvtss2sd_xmm_xmm(state.asm, "xmm3", "xmm2")
  state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm3")
  state.asm = a.jcc(state.asm, "ne", l_box)
  state.asm = a.jcc(state.asm, "p", l_box)
  state.asm = a.movd_r32_xmm(state.asm, "eax", "xmm2")
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_FLOAT)
  state.asm = a.jmp(state.asm, l_end)

  state.asm = a.mark(state.asm, l_box)
  state.asm = a.call(state.asm, "fn_box_float")

  state.asm = a.mark(state.asm, l_end)
  return state
end function

function emit_cpu_init_function(state)
  state.asm = a.mark(state.asm, "fn_cpu_init")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_no = "cpuinit_no_" + lid
  l_done = "cpuinit_done_" + lid

  state.asm = a.push_reg(state.asm, "rbx")
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.cpuid(state.asm)
  state.asm = a.cmp_r32_imm(state.asm, "eax", 7)
  state.asm = a.jcc(state.asm, "b", l_no)

  state.asm = a.mov_r32_imm32(state.asm, "eax", 1)
  state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.cpuid(state.asm)
  state.asm = a.mov_r32_r32(state.asm, "r10d", "ecx")
  state.asm = a.and_r32_imm(state.asm, "r10d", (1 << 27) | (1 << 28))
  state.asm = a.cmp_r32_imm(state.asm, "r10d", (1 << 27) | (1 << 28))
  state.asm = a.jcc(state.asm, "ne", l_no)

  state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.xgetbv(state.asm)
  state.asm = a.and_r32_imm(state.asm, "eax", 0x6)
  state.asm = a.cmp_r32_imm(state.asm, "eax", 0x6)
  state.asm = a.jcc(state.asm, "ne", l_no)

  state.asm = a.mov_r32_imm32(state.asm, "eax", 7)
  state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.cpuid(state.asm)
  state.asm = a.mov_r32_r32(state.asm, "eax", "ebx")
  state.asm = a.shr_r32_imm8(state.asm, "eax", 5)
  state.asm = a.and_r32_imm(state.asm, "eax", 1)
  state.asm = a.mov_rip_dword_eax(state.asm, "cpu_has_avx2")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_no)
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.mov_rip_dword_eax(state.asm, "cpu_has_avx2")

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.pop_reg(state.asm, "rbx")
  state.asm = a.ret(state.asm)
  return state
end function

function emit_mem_eq_bytes_function(state)
  state.asm = a.mark(state.asm, "fn_mem_eq_bytes")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_true = "memeq_true_" + lid
  l_false = "memeq_false_" + lid
  l_false_avx = "memeq_false_avx_" + lid
  l_avx_check = "memeq_avx_check_" + lid
  l_avx_loop = "memeq_avx_loop_" + lid
  l_avx_done = "memeq_avx_done_" + lid
  l_sse_loop = "memeq_sse_loop_" + lid
  l_tail = "memeq_tail_" + lid
  l_tail_loop = "memeq_tail_loop_" + lid
  l_done = "memeq_done_" + lid

  state.asm = a.cmp_r64_r64(state.asm, "rcx", "rdx")
  state.asm = a.jcc(state.asm, "e", l_true)
  state.asm = a.test_r32_r32(state.asm, "r8d", "r8d")
  state.asm = a.jcc(state.asm, "e", l_true)

  state.asm = a.mov_r64_r64(state.asm, "r9", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rdx")
  state.asm = a.mov_r32_r32(state.asm, "r11d", "r8d")

  state.asm = a.mov_eax_rip_dword(state.asm, "cpu_has_avx2")
  state.asm = a.test_r32_r32(state.asm, "eax", "eax")
  state.asm = a.jcc(state.asm, "e", l_sse_loop)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", 32)
  state.asm = a.jcc(state.asm, "b", l_sse_loop)

  state.asm = a.mark(state.asm, l_avx_check)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", 32)
  state.asm = a.jcc(state.asm, "b", l_avx_done)
  state.asm = a.mark(state.asm, l_avx_loop)
  state.asm = a.vmovdqu_ymm_membase_disp(state.asm, "ymm0", "r9", 0)
  state.asm = a.vmovdqu_ymm_membase_disp(state.asm, "ymm1", "r10", 0)
  state.asm = a.vpcmpeqb_ymm_ymm_ymm(state.asm, "ymm0", "ymm0", "ymm1")
  state.asm = a.vpmovmskb_r32_ymm(state.asm, "eax", "ymm0")
  state.asm = a.cmp_r32_imm(state.asm, "eax", 0xFFFFFFFF)
  state.asm = a.jcc(state.asm, "ne", l_false_avx)
  state.asm = a.add_r64_imm(state.asm, "r9", 32)
  state.asm = a.add_r64_imm(state.asm, "r10", 32)
  state.asm = a.sub_r32_imm(state.asm, "r11d", 32)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", 32)
  state.asm = a.jcc(state.asm, "ae", l_avx_loop)

  state.asm = a.mark(state.asm, l_avx_done)
  state.asm = a.vzeroupper(state.asm)

  state.asm = a.mark(state.asm, l_sse_loop)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", 16)
  state.asm = a.jcc(state.asm, "b", l_tail)
  state.asm = a.movdqu_xmm_membase_disp(state.asm, "xmm0", "r9", 0)
  state.asm = a.movdqu_xmm_membase_disp(state.asm, "xmm1", "r10", 0)
  state.asm = a.pcmpeqb_xmm_xmm(state.asm, "xmm0", "xmm1")
  state.asm = a.pmovmskb_r32_xmm(state.asm, "eax", "xmm0")
  state.asm = a.cmp_r32_imm(state.asm, "eax", 0xFFFF)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.add_r64_imm(state.asm, "r9", 16)
  state.asm = a.add_r64_imm(state.asm, "r10", 16)
  state.asm = a.sub_r32_imm(state.asm, "r11d", 16)
  state.asm = a.jmp(state.asm, l_sse_loop)

  state.asm = a.mark(state.asm, l_tail)
  state.asm = a.test_r32_r32(state.asm, "r11d", "r11d")
  state.asm = a.jcc(state.asm, "e", l_true)
  state.asm = a.mark(state.asm, l_tail_loop)
  state.asm = a.movzx_r32_membase_disp(state.asm, "eax", "r9", 0)
  state.asm = a.movzx_r32_membase_disp(state.asm, "edx", "r10", 0)
  state.asm = a.cmp_r32_r32(state.asm, "eax", "edx")
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.inc_r64(state.asm, "r9")
  state.asm = a.inc_r64(state.asm, "r10")
  state.asm = a.dec_r32(state.asm, "r11d")
  state.asm = a.jcc(state.asm, "ne", l_tail_loop)
  state.asm = a.jmp(state.asm, l_true)

  state.asm = a.mark(state.asm, l_false_avx)
  state.asm = a.vzeroupper(state.asm)
  state.asm = a.jmp(state.asm, l_false)

  state.asm = a.mark(state.asm, l_false)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_true)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_scan_nul_bytes_function(state)
  state.asm = a.mark(state.asm, "fn_scan_nul_bytes")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_avx_setup = "scan0b_avx_setup_" + lid
  l_avx_loop = "scan0b_avx_loop_" + lid
  l_avx_found = "scan0b_avx_found_" + lid
  l_avx_done = "scan0b_avx_done_" + lid
  l_sse_setup = "scan0b_sse_setup_" + lid
  l_sse_loop = "scan0b_sse_loop_" + lid
  l_sse_found = "scan0b_sse_found_" + lid
  l_tail = "scan0b_tail_" + lid
  l_tail_loop = "scan0b_tail_loop_" + lid
  l_done = "scan0b_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r8", "rcx")
  state.asm = a.mov_r32_r32(state.asm, "r10d", "edx")
  state.asm = a.xor_r32_r32(state.asm, "r9d", "r9d")

  state.asm = a.mov_eax_rip_dword(state.asm, "cpu_has_avx2")
  state.asm = a.test_r32_r32(state.asm, "eax", "eax")
  state.asm = a.jcc(state.asm, "e", l_sse_setup)
  state.asm = a.cmp_r32_imm(state.asm, "r10d", 32)
  state.asm = a.jcc(state.asm, "b", l_sse_setup)

  state.asm = a.mark(state.asm, l_avx_setup)
  state.asm = a.vpxor_ymm_ymm_ymm(state.asm, "ymm0", "ymm0", "ymm0")
  state.asm = a.mark(state.asm, l_avx_loop)
  state.asm = a.mov_r32_r32(state.asm, "eax", "r10d")
  state.asm = a.sub_r32_imm(state.asm, "eax", 32)
  state.asm = a.cmp_r32_r32(state.asm, "eax", "r9d")
  state.asm = a.jcc(state.asm, "l", l_avx_done)
  state.asm = a.lea_r64_mem_bis(state.asm, "r11", "r8", "r9", 1, 0)
  state.asm = a.vmovdqu_ymm_membase_disp(state.asm, "ymm1", "r11", 0)
  state.asm = a.vpcmpeqb_ymm_ymm_ymm(state.asm, "ymm1", "ymm1", "ymm0")
  state.asm = a.vpmovmskb_r32_ymm(state.asm, "eax", "ymm1")
  state.asm = a.test_r32_r32(state.asm, "eax", "eax")
  state.asm = a.jcc(state.asm, "ne", l_avx_found)
  state.asm = a.add_r32_imm(state.asm, "r9d", 32)
  state.asm = a.jmp(state.asm, l_avx_loop)

  state.asm = a.mark(state.asm, l_avx_found)
  state.asm = a.bsf_r32_r32(state.asm, "eax", "eax")
  state.asm = a.add_r32_r32(state.asm, "eax", "r9d")
  state.asm = a.mov_r32_r32(state.asm, "edx", "eax")
  state.asm = a.vzeroupper(state.asm)
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_avx_done)
  state.asm = a.vzeroupper(state.asm)

  state.asm = a.mark(state.asm, l_sse_setup)
  state.asm = a.pxor_xmm_xmm(state.asm, "xmm0", "xmm0")
  state.asm = a.mark(state.asm, l_sse_loop)
  state.asm = a.mov_r32_r32(state.asm, "eax", "r10d")
  state.asm = a.sub_r32_imm(state.asm, "eax", 16)
  state.asm = a.cmp_r32_r32(state.asm, "eax", "r9d")
  state.asm = a.jcc(state.asm, "l", l_tail)
  state.asm = a.lea_r64_mem_bis(state.asm, "r11", "r8", "r9", 1, 0)
  state.asm = a.movdqu_xmm_membase_disp(state.asm, "xmm1", "r11", 0)
  state.asm = a.pcmpeqb_xmm_xmm(state.asm, "xmm1", "xmm0")
  state.asm = a.pmovmskb_r32_xmm(state.asm, "eax", "xmm1")
  state.asm = a.test_r32_r32(state.asm, "eax", "eax")
  state.asm = a.jcc(state.asm, "ne", l_sse_found)
  state.asm = a.add_r32_imm(state.asm, "r9d", 16)
  state.asm = a.jmp(state.asm, l_sse_loop)

  state.asm = a.mark(state.asm, l_sse_found)
  state.asm = a.bsf_r32_r32(state.asm, "eax", "eax")
  state.asm = a.add_r32_r32(state.asm, "eax", "r9d")
  state.asm = a.mov_r32_r32(state.asm, "edx", "eax")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_tail)
  state.asm = a.mark(state.asm, l_tail_loop)
  state.asm = a.cmp_r32_r32(state.asm, "r9d", "r10d")
  state.asm = a.jcc(state.asm, "ge", l_done)
  state.asm = a.lea_r64_mem_bis(state.asm, "r11", "r8", "r9", 1, 0)
  state.asm = a.movzx_r32_membase_disp(state.asm, "eax", "r11", 0)
  state.asm = a.test_r32_r32(state.asm, "eax", "eax")
  state.asm = a.jcc(state.asm, "e", l_done)
  state.asm = a.inc_r32(state.asm, "r9d")
  state.asm = a.jmp(state.asm, l_tail_loop)

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.mov_r32_r32(state.asm, "edx", "r9d")
  state.asm = a.ret(state.asm)
  return state
end function

function emit_scan_byte2_bytes_function(state)
  state.asm = a.mark(state.asm, "fn_scan_byte2_bytes")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_sse_loop = "scan2b_sse_loop_" + lid
  l_sse_found = "scan2b_sse_found_" + lid
  l_tail = "scan2b_tail_" + lid
  l_tail_loop = "scan2b_tail_loop_" + lid
  l_done = "scan2b_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r10", "rcx")
  state.asm = a.mov_r32_r32(state.asm, "r11d", "edx")

  state.asm = a.movzx_r32_r8(state.asm, "eax", "r8b")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.shl_r64_imm8(state.asm, "rdx", 8)
  state.asm = a.or_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.shl_r64_imm8(state.asm, "rdx", 16)
  state.asm = a.or_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.shl_r64_imm8(state.asm, "rdx", 32)
  state.asm = a.or_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.movq_xmm_r64(state.asm, "xmm0", "rax")
  state.asm = a.punpcklqdq_xmm_xmm(state.asm, "xmm0", "xmm0")

  state.asm = a.movzx_r32_r8(state.asm, "eax", "r9b")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.shl_r64_imm8(state.asm, "rdx", 8)
  state.asm = a.or_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.shl_r64_imm8(state.asm, "rdx", 16)
  state.asm = a.or_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.shl_r64_imm8(state.asm, "rdx", 32)
  state.asm = a.or_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.movq_xmm_r64(state.asm, "xmm2", "rax")
  state.asm = a.punpcklqdq_xmm_xmm(state.asm, "xmm2", "xmm2")

  state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")

  state.asm = a.mark(state.asm, l_sse_loop)
  state.asm = a.mov_r32_r32(state.asm, "eax", "r11d")
  state.asm = a.sub_r32_imm(state.asm, "eax", 16)
  state.asm = a.cmp_r32_r32(state.asm, "eax", "ecx")
  state.asm = a.jcc(state.asm, "l", l_tail)
  state.asm = a.lea_r64_mem_bis(state.asm, "rax", "r10", "rcx", 1, 0)
  state.asm = a.movdqu_xmm_membase_disp(state.asm, "xmm1", "rax", 0)
  state.asm = a.movdqu_xmm_membase_disp(state.asm, "xmm3", "rax", 0)
  state.asm = a.pcmpeqb_xmm_xmm(state.asm, "xmm1", "xmm0")
  state.asm = a.pcmpeqb_xmm_xmm(state.asm, "xmm3", "xmm2")
  state.asm = a.pmovmskb_r32_xmm(state.asm, "eax", "xmm1")
  state.asm = a.pmovmskb_r32_xmm(state.asm, "edx", "xmm3")
  state.asm = a.or_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.test_r32_r32(state.asm, "eax", "eax")
  state.asm = a.jcc(state.asm, "ne", l_sse_found)
  state.asm = a.add_r32_imm(state.asm, "ecx", 16)
  state.asm = a.jmp(state.asm, l_sse_loop)

  state.asm = a.mark(state.asm, l_sse_found)
  state.asm = a.bsf_r32_r32(state.asm, "eax", "eax")
  state.asm = a.add_r32_r32(state.asm, "eax", "ecx")
  state.asm = a.mov_r32_r32(state.asm, "edx", "eax")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_tail)
  state.asm = a.mark(state.asm, l_tail_loop)
  state.asm = a.cmp_r32_r32(state.asm, "ecx", "r11d")
  state.asm = a.jcc(state.asm, "ge", l_done)
  state.asm = a.lea_r64_mem_bis(state.asm, "rax", "r10", "rcx", 1, 0)
  state.asm = a.movzx_r32_membase_disp(state.asm, "eax", "rax", 0)
  state.asm = a.movzx_r32_r8(state.asm, "edx", "r8b")
  state.asm = a.cmp_r32_r32(state.asm, "eax", "edx")
  state.asm = a.jcc(state.asm, "e", l_done)
  state.asm = a.movzx_r32_r8(state.asm, "edx", "r9b")
  state.asm = a.cmp_r32_r32(state.asm, "eax", "edx")
  state.asm = a.jcc(state.asm, "e", l_done)
  state.asm = a.inc_r32(state.asm, "ecx")
  state.asm = a.jmp(state.asm, l_tail_loop)

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.mov_r32_r32(state.asm, "edx", "ecx")
  state.asm = a.ret(state.asm)
  return state
end function

function emit_scan_nul_wchars_function(state)
  state.asm = a.mark(state.asm, "fn_scan_nul_wchars")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_avx_setup = "scan0w_avx_setup_" + lid
  l_avx_loop = "scan0w_avx_loop_" + lid
  l_avx_found = "scan0w_avx_found_" + lid
  l_avx_done = "scan0w_avx_done_" + lid
  l_sse_setup = "scan0w_sse_setup_" + lid
  l_sse_loop = "scan0w_sse_loop_" + lid
  l_sse_found = "scan0w_sse_found_" + lid
  l_tail = "scan0w_tail_" + lid
  l_tail_loop = "scan0w_tail_loop_" + lid
  l_done = "scan0w_done_" + lid
  l_tail_cont = "scan0w_tail_cont_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r8", "rcx")
  state.asm = a.mov_r32_r32(state.asm, "r10d", "edx")
  state.asm = a.xor_r32_r32(state.asm, "r9d", "r9d")

  state.asm = a.mov_eax_rip_dword(state.asm, "cpu_has_avx2")
  state.asm = a.test_r32_r32(state.asm, "eax", "eax")
  state.asm = a.jcc(state.asm, "e", l_sse_setup)
  state.asm = a.cmp_r32_imm(state.asm, "r10d", 16)
  state.asm = a.jcc(state.asm, "b", l_sse_setup)

  state.asm = a.mark(state.asm, l_avx_setup)
  state.asm = a.vpxor_ymm_ymm_ymm(state.asm, "ymm0", "ymm0", "ymm0")
  state.asm = a.mark(state.asm, l_avx_loop)
  state.asm = a.mov_r32_r32(state.asm, "eax", "r10d")
  state.asm = a.sub_r32_imm(state.asm, "eax", 16)
  state.asm = a.cmp_r32_r32(state.asm, "eax", "r9d")
  state.asm = a.jcc(state.asm, "l", l_avx_done)
  state.asm = a.lea_r64_mem_bis(state.asm, "r11", "r8", "r9", 2, 0)
  state.asm = a.vmovdqu_ymm_membase_disp(state.asm, "ymm1", "r11", 0)
  state.asm = a.vpcmpeqw_ymm_ymm_ymm(state.asm, "ymm1", "ymm1", "ymm0")
  state.asm = a.vpmovmskb_r32_ymm(state.asm, "eax", "ymm1")
  state.asm = a.test_r32_r32(state.asm, "eax", "eax")
  state.asm = a.jcc(state.asm, "ne", l_avx_found)
  state.asm = a.add_r32_imm(state.asm, "r9d", 16)
  state.asm = a.jmp(state.asm, l_avx_loop)

  state.asm = a.mark(state.asm, l_avx_found)
  state.asm = a.bsf_r32_r32(state.asm, "eax", "eax")
  state.asm = a.shr_r32_imm8(state.asm, "eax", 1)
  state.asm = a.add_r32_r32(state.asm, "eax", "r9d")
  state.asm = a.mov_r32_r32(state.asm, "edx", "eax")
  state.asm = a.vzeroupper(state.asm)
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_avx_done)
  state.asm = a.vzeroupper(state.asm)

  state.asm = a.mark(state.asm, l_sse_setup)
  state.asm = a.pxor_xmm_xmm(state.asm, "xmm0", "xmm0")
  state.asm = a.mark(state.asm, l_sse_loop)
  state.asm = a.mov_r32_r32(state.asm, "eax", "r10d")
  state.asm = a.sub_r32_imm(state.asm, "eax", 8)
  state.asm = a.cmp_r32_r32(state.asm, "eax", "r9d")
  state.asm = a.jcc(state.asm, "l", l_tail)
  state.asm = a.lea_r64_mem_bis(state.asm, "r11", "r8", "r9", 2, 0)
  state.asm = a.movdqu_xmm_membase_disp(state.asm, "xmm1", "r11", 0)
  state.asm = a.pcmpeqw_xmm_xmm(state.asm, "xmm1", "xmm0")
  state.asm = a.pmovmskb_r32_xmm(state.asm, "eax", "xmm1")
  state.asm = a.test_r32_r32(state.asm, "eax", "eax")
  state.asm = a.jcc(state.asm, "ne", l_sse_found)
  state.asm = a.add_r32_imm(state.asm, "r9d", 8)
  state.asm = a.jmp(state.asm, l_sse_loop)

  state.asm = a.mark(state.asm, l_sse_found)
  state.asm = a.bsf_r32_r32(state.asm, "eax", "eax")
  state.asm = a.shr_r32_imm8(state.asm, "eax", 1)
  state.asm = a.add_r32_r32(state.asm, "eax", "r9d")
  state.asm = a.mov_r32_r32(state.asm, "edx", "eax")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_tail)
  state.asm = a.mark(state.asm, l_tail_loop)
  state.asm = a.cmp_r32_r32(state.asm, "r9d", "r10d")
  state.asm = a.jcc(state.asm, "ge", l_done)
  state.asm = a.lea_r64_mem_bis(state.asm, "r11", "r8", "r9", 2, 0)
  state.asm = a.movzx_r32_membase_disp(state.asm, "eax", "r11", 0)
  state.asm = a.test_r32_r32(state.asm, "eax", "eax")
  state.asm = a.jcc(state.asm, "ne", l_tail_cont)
  state.asm = a.movzx_r32_membase_disp(state.asm, "eax", "r11", 1)
  state.asm = a.test_r32_r32(state.asm, "eax", "eax")
  state.asm = a.jcc(state.asm, "e", l_done)
  state.asm = a.mark(state.asm, l_tail_cont)
  state.asm = a.inc_r32(state.asm, "r9d")
  state.asm = a.jmp(state.asm, l_tail_loop)

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.mov_r32_r32(state.asm, "edx", "r9d")
  state.asm = a.ret(state.asm)
  return state
end function

function emit_bytes_hash_function(state)
  state.asm = a.mark(state.asm, "fn_bytes_hash")
  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "bhash_fail_" + lid
  l_loop = "bhash_loop_" + lid
  l_done = "bhash_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r9", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r9")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r9", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "r9", 4)
  state.asm = a.mov_r64_imm64(state.asm, "rax", 2166136261)
  state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.mark(state.asm, l_loop)
  state.asm = a.cmp_r32_r32(state.asm, "ecx", "r11d")
  state.asm = a.jcc(state.asm, "ge", l_done)
  state.asm = a.lea_r64_mem_bis(state.asm, "r10", "r9", "rcx", 1, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "r10d", "r10", 0)
  state.asm = a.xor_r64_r64(state.asm, "rax", "r10")
  state.asm = a.imul_r64_r64_imm(state.asm, "rax", "rax", 16777619)
  state.asm = a.and_r64_imm(state.asm, "rax", 0xFFFFFFFF)
  state.asm = a.inc_r32(state.asm, "ecx")
  state.asm = a.jmp(state.asm, l_loop)

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.shl_r64_imm8(state.asm, "rax", 3)
  state.asm = a.or_r64_imm8(state.asm, "rax", c.TAG_INT)
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.ret(state.asm)
  return state
end function

function emit_string_hash_function(state)
  state.asm = a.mark(state.asm, "fn_string_hash")
  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "shash_fail_" + lid
  l_loop = "shash_loop_" + lid
  l_done = "shash_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r9", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r9")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r9", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "r9", 4)
  state.asm = a.mov_r64_imm64(state.asm, "rax", 2166136261)
  state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.mark(state.asm, l_loop)
  state.asm = a.cmp_r32_r32(state.asm, "ecx", "r11d")
  state.asm = a.jcc(state.asm, "ge", l_done)
  state.asm = a.lea_r64_mem_bis(state.asm, "r10", "r9", "rcx", 1, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "r10d", "r10", 0)
  state.asm = a.xor_r64_r64(state.asm, "rax", "r10")
  state.asm = a.imul_r64_r64_imm(state.asm, "rax", "rax", 16777619)
  state.asm = a.and_r64_imm(state.asm, "rax", 0xFFFFFFFF)
  state.asm = a.inc_r32(state.asm, "ecx")
  state.asm = a.jmp(state.asm, l_loop)

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.shl_r64_imm8(state.asm, "rax", 3)
  state.asm = a.or_r64_imm8(state.asm, "rax", c.TAG_INT)
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.ret(state.asm)
  return state
end function

function emit_bytes_startswith_function(state)
  state.asm = a.mark(state.asm, "fn_bytes_startswith")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_false = "bstarts_false_" + lid
  l_true = "bstarts_true_" + lid
  l_done = "bstarts_done_" + lid

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
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r9", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_BYTES)
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

function emit_bytes_endswith_function(state)
  state.asm = a.mark(state.asm, "fn_bytes_endswith")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_false = "bends_false_" + lid
  l_true = "bends_true_" + lid
  l_done = "bends_done_" + lid

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
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r9", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "ne", l_false)

  state.asm = a.cmp_r64_r64(state.asm, "r8", "r9")
  state.asm = a.jcc(state.asm, "e", l_true)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r8", 4)
  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "r9", 4)
  state.asm = a.test_r32_r32(state.asm, "r11d", "r11d")
  state.asm = a.jcc(state.asm, "e", l_true)
  state.asm = a.cmp_r32_r32(state.asm, "r11d", "r10d")
  state.asm = a.jcc(state.asm, "g", l_false)
  state.asm = a.mov_r32_r32(state.asm, "eax", "r10d")
  state.asm = a.sub_r32_r32(state.asm, "eax", "r11d")
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r8", 8)
  state.asm = a.add_r64_r64(state.asm, "rcx", "rax")
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

function emit_bytes_indexof_function(state)
  state.asm = a.mark(state.asm, "fn_bytes_indexof")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "bidx_fail_" + lid
  l_not_found = "bidx_not_found_" + lid
  l_start_nonneg = "bidx_start_nonneg_" + lid
  l_start_in_range = "bidx_start_in_range_" + lid
  l_prepare = "bidx_prepare_" + lid
  l_outer = "bidx_outer_" + lid
  l_inner = "bidx_inner_" + lid
  l_found = "bidx_found_" + lid
  l_done = "bidx_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r11", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r11", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "r11", 4)

  state.asm = a.mov_r64_r64(state.asm, "r10", "rdx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r10", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_BYTES)
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

function emit_bytes_lastindexof_function(state)
  state.asm = a.mark(state.asm, "fn_bytes_lastindexof")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "bridx_fail_" + lid
  l_not_found = "bridx_not_found_" + lid
  l_prepare = "bridx_prepare_" + lid
  l_outer = "bridx_outer_" + lid
  l_inner = "bridx_inner_" + lid
  l_found = "bridx_found_" + lid
  l_done = "bridx_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r11", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r11", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "r11", 4)

  state.asm = a.mov_r64_r64(state.asm, "r10", "rdx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r10", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_BYTES)
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

function emit_bytes_compare_function(state)
  state.asm = a.mark(state.asm, "fn_bytes_compare")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "bcmp_fail_" + lid
  l_loop = "bcmp_loop_" + lid
  l_done = "bcmp_done_" + lid

  state.asm = a.mov_r64_r64(state.asm, "r8", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "r9", "rdx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r9")
  state.asm = a.and_r64_imm(state.asm, "rax", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rax", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r8", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "ne", l_fail)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r9", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "ne", l_fail)

  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r8", 4)
  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "r9", 4)
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x20, "r10d")
  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x24, "r11d")
  state.asm = a.xor_r64_r64(state.asm, "rcx", "rcx")
  state.asm = a.cmp_r32_r32(state.asm, "r11d", "r10d")
  state.asm = a.jcc(state.asm, "ge", l_loop)
  state.asm = a.mov_r32_r32(state.asm, "r10d", "r11d")

  state.asm = a.mark(state.asm, l_loop)
  state.asm = a.test_r32_r32(state.asm, "r10d", "r10d")
  state.asm = a.jcc(state.asm, "e", l_done)
  state.asm = a.lea_r64_mem_bis(state.asm, "rax", "r8", "rcx", 1, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "eax", "rax", 0)
  state.asm = a.lea_r64_mem_bis(state.asm, "rdx", "r9", "rcx", 1, 8)
  state.asm = a.movzx_r32_membase_disp(state.asm, "edx", "rdx", 0)
  state.asm = a.cmp_r32_r32(state.asm, "eax", "edx")
  state.asm = a.jcc(state.asm, "b", l_done + "_neg")
  state.asm = a.jcc(state.asm, "a", l_done + "_pos")
  state.asm = a.inc_r64(state.asm, "rcx")
  state.asm = a.dec_r32(state.asm, "r10d")
  state.asm = a.jmp(state.asm, l_loop)

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rsp", 0x20)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rsp", 0x24)
  state.asm = a.cmp_r32_r32(state.asm, "eax", "edx")
  state.asm = a.jcc(state.asm, "b", l_done + "_neg")
  state.asm = a.jcc(state.asm, "a", l_done + "_pos")
  state.asm = a.mov_rax_imm64(state.asm, t.enc_int(0))
  state.asm = a.jmp(state.asm, l_done + "_ret")

  state.asm = a.mark(state.asm, l_done + "_neg")
  state.asm = a.mov_rax_imm64(state.asm, t.enc_int(-1))
  state.asm = a.jmp(state.asm, l_done + "_ret")

  state.asm = a.mark(state.asm, l_done + "_pos")
  state.asm = a.mov_rax_imm64(state.asm, t.enc_int(1))
  state.asm = a.jmp(state.asm, l_done + "_ret")

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())

  state.asm = a.mark(state.asm, l_done + "_ret")
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_builtin_copyStringBytes_function(state)
  state.asm = a.mark(state.asm, "fn_builtin_copyStringBytes")
  lid = state.label_id
  state.label_id = state.label_id + 1
  l_ret_void = "bcopys_ret_void_" + lid
  l_len_dst = "bcopys_len_dst_" + lid
  l_len_src = "bcopys_len_src_" + lid

  state.asm = a.cmp_r32_imm(state.asm, "r10d", 5)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)

  state.asm = a.mov_r64_r64(state.asm, "r11", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "r10", "r8")
  state.asm = a.mov_r64_r64(state.asm, "r8", "r9")

  // dst must be OBJ_BYTES
  state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
  state.asm = a.mov_r64_r64(state.asm, "r9", "rax")
  state.asm = a.and_r64_imm(state.asm, "r9", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r11", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)

  // dstOff -> r9d
  state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.mov_r64_r64(state.asm, "r9", "rax")
  state.asm = a.and_r64_imm(state.asm, "r9", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_INT)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
  state.asm = a.jcc(state.asm, "l", l_ret_void)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
  state.asm = a.jcc(state.asm, "g", l_ret_void)
  state.asm = a.mov_r32_r32(state.asm, "r9d", "eax")

  // src must be OBJ_STRING
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.and_r64_imm(state.asm, "rcx", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rcx", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r10", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)

  // srcOff -> r8d
  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.and_r64_imm(state.asm, "rcx", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rcx", c.TAG_INT)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
  state.asm = a.jcc(state.asm, "l", l_ret_void)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
  state.asm = a.jcc(state.asm, "g", l_ret_void)
  state.asm = a.mov_r32_r32(state.asm, "r8d", "eax")

  // len -> edx
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x28)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.and_r64_imm(state.asm, "rcx", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rcx", c.TAG_INT)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
  state.asm = a.jcc(state.asm, "l", l_ret_void)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
  state.asm = a.jcc(state.asm, "g", l_ret_void)
  state.asm = a.mov_r32_r32(state.asm, "edx", "eax")

  // Clamp length to available tail room in both buffers.
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r11", 4)
  state.asm = a.cmp_r32_r32(state.asm, "r9d", "eax")
  state.asm = a.jcc(state.asm, "ge", l_ret_void)
  state.asm = a.sub_r32_r32(state.asm, "eax", "r9d")

  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "r10", 4)
  state.asm = a.cmp_r32_r32(state.asm, "r8d", "ecx")
  state.asm = a.jcc(state.asm, "ge", l_ret_void)
  state.asm = a.sub_r32_r32(state.asm, "ecx", "r8d")

  state.asm = a.cmp_r32_r32(state.asm, "edx", "eax")
  state.asm = a.jcc(state.asm, "le", l_len_dst)
  state.asm = a.mov_r32_r32(state.asm, "edx", "eax")
  state.asm = a.mark(state.asm, l_len_dst)
  state.asm = a.cmp_r32_r32(state.asm, "edx", "ecx")
  state.asm = a.jcc(state.asm, "le", l_len_src)
  state.asm = a.mov_r32_r32(state.asm, "edx", "ecx")
  state.asm = a.mark(state.asm, l_len_src)
  state.asm = a.test_r32_r32(state.asm, "edx", "edx")
  state.asm = a.jcc(state.asm, "le", l_ret_void)

  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x20, "edx")
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r11", 8)
  state.asm = a.add_r64_r64(state.asm, "rcx", "r9")
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r10", 8)
  state.asm = a.add_r64_r64(state.asm, "rdx", "r8")
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rsp", 0x20)
  state.asm = a.call(state.asm, "fn_copy_bytes")

  state.asm = a.mark(state.asm, l_ret_void)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.ret(state.asm)
  return state
end function

function emit_copy_bytes_function(state)
  state.asm = a.mark(state.asm, "fn_copy_bytes")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_ret = "cpy_ret_" + lid
  l_scalar_small = "cpy_scalar_small_" + lid
  l_scalar_loop = "cpy_scalar_loop_" + lid
  l_qword_small = "cpy_qword_small_" + lid
  l_xmm_small = "cpy_xmm_small_" + lid
  l_large = "cpy_large_" + lid
  l_avx_loop = "cpy_avx_loop_" + lid
  l_avx_done = "cpy_avx_done_" + lid
  l_sse_loop = "cpy_sse_loop_" + lid
  l_tail = "cpy_tail_" + lid
  l_rep = "cpy_rep_" + lid

  state.asm = a.test_r32_r32(state.asm, "r8d", "r8d")
  state.asm = a.jcc(state.asm, "e", l_ret)
  state.asm = a.cmp_r32_imm(state.asm, "r8d", 8)
  state.asm = a.jcc(state.asm, "b", l_scalar_small)
  state.asm = a.cmp_r32_imm(state.asm, "r8d", 16)
  state.asm = a.jcc(state.asm, "b", l_qword_small)
  state.asm = a.cmp_r32_imm(state.asm, "r8d", 32)
  state.asm = a.jcc(state.asm, "be", l_xmm_small)
  state.asm = a.jmp(state.asm, l_large)

  state.asm = a.mark(state.asm, l_scalar_small)
  state.asm = a.mov_r64_r64(state.asm, "r9", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rdx")
  state.asm = a.mov_r32_r32(state.asm, "r11d", "r8d")
  state.asm = a.mark(state.asm, l_scalar_loop)
  state.asm = a.mov_r8_membase_disp(state.asm, "al", "r10", 0)
  state.asm = a.mov_membase_disp_r8(state.asm, "r9", 0, "al")
  state.asm = a.inc_r64(state.asm, "r9")
  state.asm = a.inc_r64(state.asm, "r10")
  state.asm = a.dec_r32(state.asm, "r11d")
  state.asm = a.jcc(state.asm, "ne", l_scalar_loop)
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_qword_small)
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rdx", 0)
  state.asm = a.mov_membase_disp_r64(state.asm, "rcx", 0, "rax")
  state.asm = a.mov_r32_r32(state.asm, "r11d", "r8d")
  state.asm = a.sub_r32_imm(state.asm, "r11d", 8)
  state.asm = a.lea_r64_mem_bis(state.asm, "r10", "rdx", "r11", 1, 0)
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r10", 0)
  state.asm = a.lea_r64_mem_bis(state.asm, "r9", "rcx", "r11", 1, 0)
  state.asm = a.mov_membase_disp_r64(state.asm, "r9", 0, "rax")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_xmm_small)
  state.asm = a.movdqu_xmm_membase_disp(state.asm, "xmm0", "rdx", 0)
  state.asm = a.movdqu_membase_disp_xmm(state.asm, "rcx", 0, "xmm0")
  state.asm = a.cmp_r32_imm(state.asm, "r8d", 16)
  state.asm = a.jcc(state.asm, "e", l_ret)
  state.asm = a.mov_r32_r32(state.asm, "r11d", "r8d")
  state.asm = a.sub_r32_imm(state.asm, "r11d", 16)
  state.asm = a.lea_r64_mem_bis(state.asm, "r10", "rdx", "r11", 1, 0)
  state.asm = a.movdqu_xmm_membase_disp(state.asm, "xmm0", "r10", 0)
  state.asm = a.lea_r64_mem_bis(state.asm, "r9", "rcx", "r11", 1, 0)
  state.asm = a.movdqu_membase_disp_xmm(state.asm, "r9", 0, "xmm0")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_large)
  state.asm = a.mov_r64_r64(state.asm, "r9", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rdx")
  state.asm = a.mov_r32_r32(state.asm, "r11d", "r8d")
  state.asm = a.mov_eax_rip_dword(state.asm, "cpu_has_avx2")
  state.asm = a.test_r32_r32(state.asm, "eax", "eax")
  state.asm = a.jcc(state.asm, "e", l_rep)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", 64)
  state.asm = a.jcc(state.asm, "b", l_sse_loop)

  state.asm = a.mark(state.asm, l_avx_loop)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", 32)
  state.asm = a.jcc(state.asm, "b", l_avx_done)
  state.asm = a.vmovdqu_ymm_membase_disp(state.asm, "ymm0", "r10", 0)
  state.asm = a.vmovdqu_membase_disp_ymm(state.asm, "r9", 0, "ymm0")
  state.asm = a.add_r64_imm(state.asm, "r9", 32)
  state.asm = a.add_r64_imm(state.asm, "r10", 32)
  state.asm = a.sub_r32_imm(state.asm, "r11d", 32)
  state.asm = a.jmp(state.asm, l_avx_loop)

  state.asm = a.mark(state.asm, l_avx_done)
  state.asm = a.vzeroupper(state.asm)

  state.asm = a.mark(state.asm, l_sse_loop)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", 16)
  state.asm = a.jcc(state.asm, "b", l_tail)
  state.asm = a.movdqu_xmm_membase_disp(state.asm, "xmm0", "r10", 0)
  state.asm = a.movdqu_membase_disp_xmm(state.asm, "r9", 0, "xmm0")
  state.asm = a.add_r64_imm(state.asm, "r9", 16)
  state.asm = a.add_r64_imm(state.asm, "r10", 16)
  state.asm = a.sub_r32_imm(state.asm, "r11d", 16)
  state.asm = a.jmp(state.asm, l_sse_loop)

  state.asm = a.mark(state.asm, l_tail)
  state.asm = a.test_r32_r32(state.asm, "r11d", "r11d")
  state.asm = a.jcc(state.asm, "e", l_ret)
  state.asm = a.mov_r8_membase_disp(state.asm, "al", "r10", 0)
  state.asm = a.mov_membase_disp_r8(state.asm, "r9", 0, "al")
  state.asm = a.inc_r64(state.asm, "r9")
  state.asm = a.inc_r64(state.asm, "r10")
  state.asm = a.dec_r32(state.asm, "r11d")
  state.asm = a.jmp(state.asm, l_tail)

  state.asm = a.mark(state.asm, l_rep)
  state.asm = a.push_reg(state.asm, "rsi")
  state.asm = a.push_reg(state.asm, "rdi")
  state.asm = a.mov_r64_r64(state.asm, "rdi", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "rsi", "rdx")
  state.asm = a.mov_r32_r32(state.asm, "ecx", "r8d")
  state.asm = a.rep_movsb(state.asm)
  state.asm = a.pop_reg(state.asm, "rdi")
  state.asm = a.pop_reg(state.asm, "rsi")

  state.asm = a.mark(state.asm, l_ret)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_fill_bytes_function(state)
  state.asm = a.mark(state.asm, "fn_fill_bytes")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_ret = "fillb_ret_" + lid
  l_scalar = "fillb_scalar_" + lid
  l_scalar_loop = "fillb_scalar_loop_" + lid
  l_after_pattern = "fillb_after_pattern_" + lid
  l_qword = "fillb_qword_" + lid
  l_xmm = "fillb_xmm_" + lid
  l_xmm_loop = "fillb_xmm_loop_" + lid
  l_tail = "fillb_tail_" + lid
  l_rep = "fillb_rep_" + lid

  state.asm = a.test_r32_r32(state.asm, "edx", "edx")
  state.asm = a.jcc(state.asm, "e", l_ret)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 8)
  state.asm = a.jcc(state.asm, "b", l_scalar)

  state.asm = a.movzx_r32_r8(state.asm, "eax", "r8b")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.shl_r64_imm8(state.asm, "r10", 8)
  state.asm = a.or_r64_r64(state.asm, "rax", "r10")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.shl_r64_imm8(state.asm, "r10", 16)
  state.asm = a.or_r64_r64(state.asm, "rax", "r10")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.shl_r64_imm8(state.asm, "r10", 32)
  state.asm = a.or_r64_r64(state.asm, "rax", "r10")
  state.asm = a.jmp(state.asm, l_after_pattern)

  state.asm = a.mark(state.asm, l_scalar)
  state.asm = a.mov_r64_r64(state.asm, "r9", "rcx")
  state.asm = a.mov_r32_r32(state.asm, "r10d", "edx")
  state.asm = a.mark(state.asm, l_scalar_loop)
  state.asm = a.mov_membase_disp_r8(state.asm, "r9", 0, "r8b")
  state.asm = a.inc_r64(state.asm, "r9")
  state.asm = a.dec_r32(state.asm, "r10d")
  state.asm = a.jcc(state.asm, "ne", l_scalar_loop)
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_after_pattern)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 16)
  state.asm = a.jcc(state.asm, "b", l_qword)

  state.asm = a.movq_xmm_r64(state.asm, "xmm0", "rax")
  state.asm = a.punpcklqdq_xmm_xmm(state.asm, "xmm0", "xmm0")
  state.asm = a.cmp_r32_imm(state.asm, "edx", 32)
  state.asm = a.jcc(state.asm, "be", l_xmm)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 64)
  state.asm = a.jcc(state.asm, "a", l_rep)

  state.asm = a.mov_r64_r64(state.asm, "r9", "rcx")
  state.asm = a.mov_r32_r32(state.asm, "r10d", "edx")
  state.asm = a.mark(state.asm, l_xmm_loop)
  state.asm = a.cmp_r32_imm(state.asm, "r10d", 16)
  state.asm = a.jcc(state.asm, "b", l_tail)
  state.asm = a.movdqu_membase_disp_xmm(state.asm, "r9", 0, "xmm0")
  state.asm = a.add_r64_imm(state.asm, "r9", 16)
  state.asm = a.sub_r32_imm(state.asm, "r10d", 16)
  state.asm = a.jmp(state.asm, l_xmm_loop)

  state.asm = a.mark(state.asm, l_qword)
  state.asm = a.mov_membase_disp_r64(state.asm, "rcx", 0, "rax")
  state.asm = a.mov_r32_r32(state.asm, "r10d", "edx")
  state.asm = a.sub_r32_imm(state.asm, "r10d", 8)
  state.asm = a.lea_r64_mem_bis(state.asm, "r9", "rcx", "r10", 1, 0)
  state.asm = a.mov_membase_disp_r64(state.asm, "r9", 0, "rax")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_xmm)
  state.asm = a.movdqu_membase_disp_xmm(state.asm, "rcx", 0, "xmm0")
  state.asm = a.cmp_r32_imm(state.asm, "edx", 16)
  state.asm = a.jcc(state.asm, "e", l_ret)
  state.asm = a.mov_r32_r32(state.asm, "r10d", "edx")
  state.asm = a.sub_r32_imm(state.asm, "r10d", 16)
  state.asm = a.lea_r64_mem_bis(state.asm, "r9", "rcx", "r10", 1, 0)
  state.asm = a.movdqu_membase_disp_xmm(state.asm, "r9", 0, "xmm0")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_tail)
  state.asm = a.test_r32_r32(state.asm, "r10d", "r10d")
  state.asm = a.jcc(state.asm, "e", l_ret)
  state.asm = a.mov_membase_disp_r8(state.asm, "r9", 0, "r8b")
  state.asm = a.inc_r64(state.asm, "r9")
  state.asm = a.dec_r32(state.asm, "r10d")
  state.asm = a.jmp(state.asm, l_tail)

  state.asm = a.mark(state.asm, l_rep)
  state.asm = a.push_reg(state.asm, "rdi")
  state.asm = a.mov_r64_r64(state.asm, "rdi", "rcx")
  state.asm = a.mov_r8_r8(state.asm, "al", "r8b")
  state.asm = a.mov_r32_r32(state.asm, "ecx", "edx")
  state.asm = a.rep_stosb(state.asm)
  state.asm = a.pop_reg(state.asm, "rdi")

  state.asm = a.mark(state.asm, l_ret)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_fill_qwords_function(state)
  state.asm = a.mark(state.asm, "fn_fill_qwords")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_ret = "fillq_ret_" + lid
  l_small = "fillq_small_" + lid
  l_rep = "fillq_rep_" + lid

  state.asm = a.test_r32_r32(state.asm, "edx", "edx")
  state.asm = a.jcc(state.asm, "e", l_ret)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.cmp_r32_imm(state.asm, "edx", 1)
  state.asm = a.jcc(state.asm, "e", l_small)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 4)
  state.asm = a.jcc(state.asm, "a", l_rep)

  state.asm = a.movq_xmm_r64(state.asm, "xmm0", "rax")
  state.asm = a.punpcklqdq_xmm_xmm(state.asm, "xmm0", "xmm0")
  state.asm = a.movdqu_membase_disp_xmm(state.asm, "rcx", 0, "xmm0")
  state.asm = a.cmp_r32_imm(state.asm, "edx", 2)
  state.asm = a.jcc(state.asm, "e", l_ret)
  state.asm = a.mov_r32_r32(state.asm, "r10d", "edx")
  state.asm = a.shl_r32_imm8(state.asm, "r10d", 3)
  state.asm = a.sub_r32_imm(state.asm, "r10d", 16)
  state.asm = a.lea_r64_mem_bis(state.asm, "r9", "rcx", "r10", 1, 0)
  state.asm = a.movdqu_membase_disp_xmm(state.asm, "r9", 0, "xmm0")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_small)
  state.asm = a.mov_membase_disp_r64(state.asm, "rcx", 0, "rax")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_rep)
  state.asm = a.push_reg(state.asm, "rdi")
  state.asm = a.mov_r64_r64(state.asm, "rdi", "rcx")
  state.asm = a.mov_r32_r32(state.asm, "ecx", "edx")
  state.asm = a.rep_stosq(state.asm)
  state.asm = a.pop_reg(state.asm, "rdi")

  state.asm = a.mark(state.asm, l_ret)
  state.asm = a.ret(state.asm)
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
  l_immf = "ton_immf_" + lid
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
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_FLOAT)
  state.asm = a.jcc(state.asm, "e", l_immf)

  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "e", l_ptr)

  state.asm = a.jmp(state.asm, l_fail)

  state.asm = a.mark(state.asm, l_immf)
  state = _emit_to_double_xmm(state, 0, l_fail)
  state = _emit_normalize_xmm0_to_value(state)
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_ptr)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FLOAT)
  state.asm = a.jcc(state.asm, "e", l_float)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "e", l_str)
  state.asm = a.jmp(state.asm, l_fail)

  state.asm = a.mark(state.asm, l_float)
  state = _emit_to_double_xmm(state, 0, l_fail)
  state = _emit_normalize_xmm0_to_value(state)
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
  state.asm = a.mov_rax_u64_hi_lo_exact(state.asm, 1072693248, 0)
  state.asm = a.movq_xmm_r64(state.asm, "xmm2", "rax")
  state.asm = a.mov_rax_u64_hi_lo_exact(state.asm, 1076101120, 0)
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
  state.asm = a.mov_rax_u64_hi_lo_exact(state.asm, 3220176896, 0)
  state.asm = a.movq_xmm_r64(state.asm, "xmm3", "rax")
  state.asm = a.mulsd_xmm_xmm(state.asm, "xmm0", "xmm3")
  state.asm = a.mark(state.asm, l_pos)
  state = _emit_normalize_xmm0_to_value(state)
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

function emit_toFloat_function(state)
  state.asm = a.mark(state.asm, "fn_toFloat")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_fail = "toflt_fail_" + lid
  l_done = "toflt_done_" + lid

  state.asm = a.call(state.asm, "fn_toNumber")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.and_r64_imm(state.asm, "rdx", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_VOID)
  state.asm = a.jcc(state.asm, "e", l_done)
  state = _emit_to_double_xmm(state, 0, l_fail)
  state = _emit_force_xmm0_to_float_value(state)
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
  l_immf = "tof_immf_" + lid
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
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_FLOAT)
  state.asm = a.jcc(state.asm, "e", l_immf)
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

  state.asm = a.mark(state.asm, l_immf)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_float")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_ptr)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)

  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "e", l_str)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
  state.asm = a.jcc(state.asm, "e", l_arr)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY_IMM)
  state.asm = a.jcc(state.asm, "e", l_arr)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "e", l_bytes)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FLOAT)
  state.asm = a.jcc(state.asm, "e", l_flt)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FUNCTION)
  state.asm = a.jcc(state.asm, "e", l_fun)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_CLOSURE)
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
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 4)
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
  l_immf = "tna_immf_" + lid
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
  state.asm = a.cmp_r64_imm(state.asm, "rdx", c.TAG_FLOAT)
  state.asm = a.jcc(state.asm, "e", l_immf)
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

  state.asm = a.mark(state.asm, l_immf)
  state.asm = a.lea_rax_rip(state.asm, "obj_type_float")
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_ptr)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "e", l_str)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
  state.asm = a.jcc(state.asm, "e", l_arr)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY_IMM)
  state.asm = a.jcc(state.asm, "e", l_arr)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "e", l_bytes)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FLOAT)
  state.asm = a.jcc(state.asm, "e", l_flt)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FUNCTION)
  state.asm = a.jcc(state.asm, "e", l_fun)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_CLOSURE)
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
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 4)
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
  state.asm = a.mov_r32_imm32(state.asm, "edx", 0x7FFFFFFF)
  state.asm = a.call(state.asm, "fn_scan_nul_bytes")
  state.asm = a.ret(state.asm)
  return state
end function

function emit_string_eq_function(state)
  state.asm = a.mark(state.asm, "fn_str_eq")

  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_false = "streq_false_" + lid
  l_true = "streq_true_" + lid
  l_done = "streq_done_" + lid

  state.asm = a.cmp_r64_r64(state.asm, "rcx", "rdx")
  state.asm = a.jcc(state.asm, "e", l_true)
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rcx", 4)
  state.asm = a.mov_r32_membase_disp(state.asm, "r9d", "rdx", 4)
  state.asm = a.cmp_r32_r32(state.asm, "r8d", "r9d")
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.test_r32_r32(state.asm, "r8d", "r8d")
  state.asm = a.jcc(state.asm, "e", l_true)
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "rcx", 8)
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "rdx", 8)
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

function emit_value_eq_function(state)
  state.asm = a.mark(state.asm, "fn_val_eq")

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

  state.asm = a.lea_r64_membase_disp(state.asm, "r14", "rsp", 40)
  state.asm = a.mov_r64_r64(state.asm, "r13", "r14")
  state.asm = a.mov_r64_r64(state.asm, "r15", "r14")
  state.asm = a.add_r64_imm(state.asm, "r15", pair_stack_bytes)
  state.asm = a.mov_membase_disp_r64(state.asm, "r13", 0, "rcx")
  state.asm = a.mov_membase_disp_r64(state.asm, "r13", 8, "rdx")
  state.asm = a.add_r64_imm(state.asm, "r13", 16)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_loop = "vale_it_loop_" + lid
  l_false = "vale_it_false_" + lid
  l_true = "vale_it_true_" + lid
  l_done = "vale_it_done_" + lid
  l_ptr = "vale_it_ptr_" + lid
  l_num = "vale_it_num_" + lid
  l_enum = "vale_it_enum_" + lid
  l_is_arr = "vale_it_is_arr_" + lid
  l_is_flt = "vale_it_is_flt_" + lid
  l_is_other = "vale_it_is_other_" + lid

  state.asm = a.mark(state.asm, l_loop)
  state.asm = a.cmp_r64_r64(state.asm, "r13", "r14")
  state.asm = a.jcc(state.asm, "e", l_true)

  state.asm = a.sub_r64_imm(state.asm, "r13", 16)
  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "r13", 0)
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "r13", 8)
  state.asm = a.cmp_r64_r64(state.asm, "r10", "r11")
  state.asm = a.jcc(state.asm, "e", l_loop)

  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.and_rax_imm8(state.asm, 7)
  state.asm = a.mov_r64_r64(state.asm, "r8", "rax")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
  state.asm = a.and_rax_imm8(state.asm, 7)
  state.asm = a.mov_r64_r64(state.asm, "r9", "rax")

  state.asm = a.cmp_r64_imm(state.asm, "r8", c.TAG_ENUM)
  state.asm = a.jcc(state.asm, "e", l_enum)
  state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_ENUM)
  state.asm = a.jcc(state.asm, "e", l_enum)

  state.asm = a.cmp_r64_imm(state.asm, "r8", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_num)
  state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "e", l_ptr)
  state.asm = a.jmp(state.asm, l_num)

  state.asm = a.mark(state.asm, l_ptr)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r10", 0)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)

  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_STRING)
  state.asm = a.jcc(state.asm, "ne", l_is_arr)
  state.asm = a.cmp_r32_r32(state.asm, "eax", "edx")
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "r10")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
  state.asm = a.call(state.asm, "fn_str_eq")
  state.asm = a.cmp_rax_imm32(state.asm, t.enc_bool(true))
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.jmp(state.asm, l_loop)

  state.asm = a.mark(state.asm, l_is_arr)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_ARRAY)
  state.asm = a.jcc(state.asm, "e", "vale_arr_pair_" + lid)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_ARRAY_IMM)
  state.asm = a.jcc(state.asm, "e", "vale_arr_pair_" + lid)
  state.asm = a.jmp(state.asm, l_is_flt)

  state.asm = a.mark(state.asm, "vale_arr_pair_" + lid)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY)
  state.asm = a.jcc(state.asm, "e", "vale_arr_scan_" + lid)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY_IMM)
  state.asm = a.jcc(state.asm, "ne", l_is_other)
  state.asm = a.mark(state.asm, "vale_arr_scan_" + lid)
  state.asm = a.mov_r32_membase_disp(state.asm, "ebx", "r10", 4)
  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "r11", 4)
  state.asm = a.cmp_r32_r32(state.asm, "ebx", "ecx")
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.test_r32_r32(state.asm, "ebx", "ebx")
  state.asm = a.jcc(state.asm, "e", l_loop)
  state.asm = a.lea_r64_membase_disp(state.asm, "rsi", "r10", 8)
  state.asm = a.lea_r64_membase_disp(state.asm, "rdi", "r11", 8)
  state.asm = a.xor_r32_r32(state.asm, "r9d", "r9d")
  state.asm = a.mark(state.asm, "vale_it_ap_loop_" + lid)
  state.asm = a.cmp_r32_r32(state.asm, "r9d", "ebx")
  state.asm = a.jcc(state.asm, "ge", "vale_it_ap_done_" + lid)
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
  state.asm = a.jmp(state.asm, "vale_it_ap_loop_" + lid)
  state.asm = a.mark(state.asm, "vale_it_ap_done_" + lid)
  state.asm = a.jmp(state.asm, l_loop)

  state.asm = a.mark(state.asm, l_is_flt)
  state.asm = a.cmp_r32_r32(state.asm, "eax", "edx")
  state.asm = a.jcc(state.asm, "ne", l_is_other)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_FLOAT)
  state.asm = a.jcc(state.asm, "ne", l_is_other)
  state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm0", "r10", 8)
  state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm1", "r11", 8)
  state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm1")
  state.asm = a.jcc(state.asm, "p", l_false)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.jmp(state.asm, l_loop)

  state.asm = a.mark(state.asm, l_is_other)
  state.asm = a.jmp(state.asm, l_false)

  state.asm = a.mark(state.asm, l_num)
  state.asm = a.cmp_r64_imm(state.asm, "r8", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "e", l_num + "_mix")
  state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "e", l_num + "_mix")
  state.asm = a.cmp_r64_imm(state.asm, "r8", c.TAG_FLOAT)
  state.asm = a.jcc(state.asm, "e", l_num + "_mix")
  state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_FLOAT)
  state.asm = a.jcc(state.asm, "e", l_num + "_mix")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
  state.asm = a.sar_r64_imm8(state.asm, "rdx", 3)
  state.asm = a.cmp_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.jmp(state.asm, l_loop)

  state.asm = a.mark(state.asm, l_num + "_mix")
  state.asm = a.cmp_r64_imm(state.asm, "r8", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_num + "_v1_imm")
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r10", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_FLOAT)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm0", "r10", 8)
  state.asm = a.jmp(state.asm, l_num + "_v1_done")
  state.asm = a.mark(state.asm, l_num + "_v1_imm")
  state.asm = a.cmp_r64_imm(state.asm, "r8", c.TAG_FLOAT)
  state.asm = a.jcc(state.asm, "e", l_num + "_v1_immf")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.cvtsi2sd_xmm_r64(state.asm, "xmm0", "rax")
  state.asm = a.jmp(state.asm, l_num + "_v1_done")
  state.asm = a.mark(state.asm, l_num + "_v1_immf")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state = _emit_to_double_xmm(state, 0, l_false)
  state.asm = a.mark(state.asm, l_num + "_v1_done")

  state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_num + "_v2_imm")
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "r11", 0)
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_FLOAT)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm1", "r11", 8)
  state.asm = a.jmp(state.asm, l_num + "_v2_done")
  state.asm = a.mark(state.asm, l_num + "_v2_imm")
  state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_FLOAT)
  state.asm = a.jcc(state.asm, "e", l_num + "_v2_immf")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.cvtsi2sd_xmm_r64(state.asm, "xmm1", "rax")
  state.asm = a.jmp(state.asm, l_num + "_v2_done")
  state.asm = a.mark(state.asm, l_num + "_v2_immf")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
  state = _emit_to_double_xmm(state, 1, l_false)
  state.asm = a.mark(state.asm, l_num + "_v2_done")
  state.asm = a.ucomisd_xmm_xmm(state.asm, "xmm0", "xmm1")
  state.asm = a.jcc(state.asm, "p", l_false)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.jmp(state.asm, l_loop)

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
  state.asm = a.mark(state.asm, "fn_unhandled_error_exit")
  state.asm = a.sub_rsp_imm8(state.asm, 0x68)

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

  // Save error fields to local slots.
  state.asm = a.mov_r64_r64(state.asm, "r11", "rcx")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r11", 8)  // code
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x30, "rax")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r11", 16)  // message
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x38, "rax")

  lid_nf = state.label_id
  state.label_id = state.label_id + 1
  l_nf_old = "unh_nf_old_" + lid_nf
  l_nf_done = "unh_nf_done_" + lid_nf

  // Guard origin fields for legacy 2-field error objects.
  state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "r11", c.GC_OFF_BLOCK_SIZE)
  state.asm = a.and_r64_imm(state.asm, "rdx", c.GC_BLOCK_SIZE_MASK)
  state.asm = a.sub_r64_imm(state.asm, "rdx", c.GC_HEADER_SIZE + 8)
  state.asm = a.shr_r64_imm8(state.asm, "rdx", 3)
  state.asm = a.cmp_r32_imm(state.asm, "edx", 5)
  state.asm = a.jcc(state.asm, "l", l_nf_old)

  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r11", 24)  // script
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x40, "rax")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r11", 32)  // func
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x48, "rax")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r11", 40)  // line
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
  state.asm = a.call_rip_qword(state.asm, "iat_ExitProcess")
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

  state.asm = a.call_rip_qword(state.asm, "iat_GetCommandLineW")

  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.lea_rdx_rip(state.asm, "ml_argc")
  state.asm = a.call_rip_qword(state.asm, "iat_CommandLineToArgvW")

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
  state.asm = a.call_rip_qword(state.asm, "iat_WideCharToMultiByte")
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
  state.asm = a.call_rip_qword(state.asm, "iat_WideCharToMultiByte")

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
  state.asm = a.call_rip_qword(state.asm, "iat_LocalFree")

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

function emit_builtin_copyBytes_function(state)
  state.asm = a.mark(state.asm, "fn_builtin_copyBytes")
  lid = state.label_id
  state.label_id = state.label_id + 1
  l_ret_void = "bcopy_ret_void_" + lid
  l_len_dst = "bcopy_len_dst_" + lid
  l_len_src = "bcopy_len_src_" + lid

  state.asm = a.cmp_r32_imm(state.asm, "r10d", 5)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)

  state.asm = a.mov_r64_r64(state.asm, "r11", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "r10", "r8")
  state.asm = a.mov_r64_r64(state.asm, "r8", "r9")

  state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
  state.asm = a.mov_r64_r64(state.asm, "r9", "rax")
  state.asm = a.and_r64_imm(state.asm, "r9", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r11", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)

  state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.mov_r64_r64(state.asm, "r9", "rax")
  state.asm = a.and_r64_imm(state.asm, "r9", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_INT)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
  state.asm = a.jcc(state.asm, "l", l_ret_void)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
  state.asm = a.jcc(state.asm, "g", l_ret_void)
  state.asm = a.mov_r32_r32(state.asm, "r9d", "eax")

  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.and_r64_imm(state.asm, "rcx", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rcx", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r10", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)

  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.and_r64_imm(state.asm, "rcx", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rcx", c.TAG_INT)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
  state.asm = a.jcc(state.asm, "l", l_ret_void)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
  state.asm = a.jcc(state.asm, "g", l_ret_void)
  state.asm = a.mov_r32_r32(state.asm, "r8d", "eax")

  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x28)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.and_r64_imm(state.asm, "rcx", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rcx", c.TAG_INT)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
  state.asm = a.jcc(state.asm, "l", l_ret_void)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
  state.asm = a.jcc(state.asm, "g", l_ret_void)
  state.asm = a.mov_r32_r32(state.asm, "edx", "eax")

  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r11", 4)
  state.asm = a.cmp_r32_r32(state.asm, "r9d", "eax")
  state.asm = a.jcc(state.asm, "ge", l_ret_void)
  state.asm = a.sub_r32_r32(state.asm, "eax", "r9d")

  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "r10", 4)
  state.asm = a.cmp_r32_r32(state.asm, "r8d", "ecx")
  state.asm = a.jcc(state.asm, "ge", l_ret_void)
  state.asm = a.sub_r32_r32(state.asm, "ecx", "r8d")

  state.asm = a.cmp_r32_r32(state.asm, "edx", "eax")
  state.asm = a.jcc(state.asm, "le", l_len_dst)
  state.asm = a.mov_r32_r32(state.asm, "edx", "eax")
  state.asm = a.mark(state.asm, l_len_dst)
  state.asm = a.cmp_r32_r32(state.asm, "edx", "ecx")
  state.asm = a.jcc(state.asm, "le", l_len_src)
  state.asm = a.mov_r32_r32(state.asm, "edx", "ecx")
  state.asm = a.mark(state.asm, l_len_src)
  state.asm = a.test_r32_r32(state.asm, "edx", "edx")
  state.asm = a.jcc(state.asm, "le", l_ret_void)

  state.asm = a.mov_membase_disp_r32(state.asm, "rsp", 0x20, "edx")
  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r11", 8)
  state.asm = a.add_r64_r64(state.asm, "rcx", "r9")
  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r10", 8)
  state.asm = a.add_r64_r64(state.asm, "rdx", "r8")
  state.asm = a.mov_r32_membase_disp(state.asm, "r8d", "rsp", 0x20)
  state.asm = a.call(state.asm, "fn_copy_bytes")

  state.asm = a.mark(state.asm, l_ret_void)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.ret(state.asm)
  return state
end function

function emit_builtin_fillBytes_function(state)
  state.asm = a.mark(state.asm, "fn_builtin_fillBytes")
  lid = state.label_id
  state.label_id = state.label_id + 1
  l_ret_void = "bfill_ret_void_" + lid
  l_len_ok = "bfill_len_ok_" + lid

  state.asm = a.cmp_r32_imm(state.asm, "r10d", 4)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)

  state.asm = a.mov_r64_r64(state.asm, "r11", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "r10", "r9")

  state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.and_r64_imm(state.asm, "rcx", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rcx", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r11", 0)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_BYTES)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)

  state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.mov_r64_r64(state.asm, "r9", "rax")
  state.asm = a.and_r64_imm(state.asm, "r9", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r9", c.TAG_INT)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
  state.asm = a.jcc(state.asm, "l", l_ret_void)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
  state.asm = a.jcc(state.asm, "g", l_ret_void)
  state.asm = a.mov_r32_r32(state.asm, "r9d", "eax")

  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.and_r64_imm(state.asm, "rcx", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rcx", c.TAG_INT)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
  state.asm = a.jcc(state.asm, "l", l_ret_void)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0x7FFFFFFF)
  state.asm = a.jcc(state.asm, "g", l_ret_void)
  state.asm = a.mov_r32_r32(state.asm, "edx", "eax")

  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.and_r64_imm(state.asm, "rcx", 7)
  state.asm = a.cmp_r64_imm(state.asm, "rcx", c.TAG_INT)
  state.asm = a.jcc(state.asm, "ne", l_ret_void)
  state.asm = a.sar_r64_imm8(state.asm, "rax", 3)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 0)
  state.asm = a.jcc(state.asm, "l", l_ret_void)
  state.asm = a.cmp_r64_imm(state.asm, "rax", 255)
  state.asm = a.jcc(state.asm, "g", l_ret_void)
  state.asm = a.mov_r32_r32(state.asm, "r8d", "eax")

  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r11", 4)
  state.asm = a.cmp_r32_r32(state.asm, "r9d", "eax")
  state.asm = a.jcc(state.asm, "ge", l_ret_void)
  state.asm = a.sub_r32_r32(state.asm, "eax", "r9d")
  state.asm = a.cmp_r32_r32(state.asm, "edx", "eax")
  state.asm = a.jcc(state.asm, "le", l_len_ok)
  state.asm = a.mov_r32_r32(state.asm, "edx", "eax")
  state.asm = a.mark(state.asm, l_len_ok)
  state.asm = a.test_r32_r32(state.asm, "edx", "edx")
  state.asm = a.jcc(state.asm, "le", l_ret_void)

  state.asm = a.lea_r64_membase_disp(state.asm, "rcx", "r11", 8)
  state.asm = a.add_r64_r64(state.asm, "rcx", "r9")
  state.asm = a.call(state.asm, "fn_fill_bytes")

  state.asm = a.mark(state.asm, l_ret_void)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
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
  state.asm = a.cmp_r32_imm(state.asm, "edx", c.OBJ_ARRAY_IMM)
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
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_young_bytes_limit")
  state.asm = a.mov_rax_imm64(state.asm, 0)
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_bytes_since")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_young_bytes_since")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_not_int)
  state.asm = a.jmp(state.asm, l_disable)

  state.asm = a.mark(state.asm, l_disable)
  state.asm = a.mov_rax_u64_hi_lo_exact(state.asm, 2147483647, 4294967295)
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_bytes_limit")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_young_bytes_limit")
  state.asm = a.mov_rax_imm64(state.asm, 0)
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_bytes_since")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_young_bytes_since")

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
      // Allocate callStat struct: type + struct_id + 2 fields.
      state.asm = a.mov_rcx_imm32(state.asm, 24)
      state.asm = a.call(state.asm, "fn_alloc")
      state.asm = a.mov_r64_r64(state.asm, "r10", "rax")

      state.asm = a.mov_membase_disp_imm32(state.asm, "r10", 0, c.OBJ_STRUCT, false)
      state.asm = a.mov_membase_disp_imm32(state.asm, "r10", 4, c.CALLSTAT_STRUCT_ID, false)

      if i < len(name_labels) and typeof(name_labels[i]) == "string" and name_labels[i] != "" then
        state.asm = a.lea_rax_rip(state.asm, name_labels[i])
        state.asm = a.mov_membase_disp_r64(state.asm, "r10", 8, "rax")
      else
        state.asm = a.mov_membase_disp_imm32(state.asm, "r10", 8, t.enc_void(), true)
      end if

      // field1 = tagged call count from callprof_counts[i]
      state.asm = a.lea_r11_rip(state.asm, "callprof_counts")
      state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r11", i * 8)
      state.asm = a.shl_r64_imm8(state.asm, "rax", 3)
      state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
      state.asm = a.mov_membase_disp_r64(state.asm, "r10", 16, "rax")

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

