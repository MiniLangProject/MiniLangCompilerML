/*
Copyright 2026 Nils Kopal
Licensed under the Apache License, Version 2.0.
*/

//! Optional Windows SATB collector. The worker never executes managed code.
package mlc.codegen.codegen_concurrent_gc
import mlc.asm as a
import mlc.data as d
import mlc.codegen.codegen_memory as mem

const SATB_CAPACITY = 1048576
const HEAP_LOCK_DEPTH = 208

/// Return deletion-log capacity in qwords, clamped before byte-to-entry conversion.
/// @param state Backend state containing the optional diagnostic byte limit.
function satb_capacity(state)
  // The legacy config lookup uses zero for missing keys. Distinguish an
  // omitted limit from an explicit zero, which is clamped to the minimum.
  value = SATB_CAPACITY * 8
  cfg = state.heap_config
  if typeof(cfg) == "array" then
    for each item in cfg
      if typeof(item) == "array" and len(item) >= 2 and item[0] == "gc_satb_limit_bytes" and typeof(item[1]) == "int" then value = item[1] end if
      if typeof(item) == "struct" and typeof(item.key) == "string" and item.key == "gc_satb_limit_bytes" and typeof(item.value) == "int" then value = item.value end if
    end for
  end if
  if value < 64 then value = 64 end if
  if value > 67108864 then value = 67108864 end if
  return value div 8
end function

/// Test whether this image uses the optional Windows background collector.
/// @param state Backend state containing the target heap configuration.
function enabled(state)
  return mem._heap_cfg_get_bool(state, "gc_concurrent", false)
end function

/// Materialize the private collector context, event handles and deletion-log storage once.
/// @param state Backend state receiving data and BSS labels.
function ensure_data(state)
  state = mem.ensure_gc_data(state)
  for each name in ["gc_concurrent_handle", "gc_concurrent_go", "gc_concurrent_done", "gc_concurrent_frontier", "gc_concurrent_free_head", "gc_concurrent_free_tail", "gc_concurrent_pause_start", "gc_satb_active", "gc_satb_count", "gc_satb_lock", "gc_satb_overflow", "gc_reuse_bits", "gc_reuse_capacity", "gc_reuse_min"]
    state.data = mem._ensure_data_u64(state.data, name, 0)
  end for
  if d.data_has_label(state.data, "gc_concurrent_context") == false then
    state.data = d.data_pad_align(state.data, 8)
    state.data = d.data_add_bytes(state.data, "gc_concurrent_context", bytes(216, 0))
  end if
  if d.data_has_label(state.data, "gc_free_bins") == false then
    state.data = d.data_pad_align(state.data, 8)
    state.data = d.data_add_bytes(state.data, "gc_free_bins", bytes(512, 0))
  end if
  if mem._has_label(state.bss.labels, "gc_satb_buffer") == false then
    state.bss = d.bss_reserve(state.bss, "gc_satb_buffer", satb_capacity(state) * 8, 8)
  end if
  return state
end function

/// Record RAX as an overwritten tagged value while preserving all registers.
/// No allocation, OS call or safepoint may separate logging from the managed store.
/// @param state Backend state receiving the SATB leaf helper.
function emit_satb_record(state)
  state = ensure_data(state)
  state.asm = a.mark(state.asm, "fn_gc_satb_record")
  state.asm = a.push_reg(state.asm, "rcx")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_satb_active")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", "satb_record_done")
  state.asm = a.test_r64_imm32(state.asm, "rcx", 7)
  state.asm = a.jcc(state.asm, "ne", "satb_record_done")
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.add_r64_imm(state.asm, "rax", 8)
  state.asm = a.cmp_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.jcc(state.asm, "b", "satb_record_done")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_concurrent_frontier")
  state.asm = a.cmp_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.jcc(state.asm, "ae", "satb_record_done")
  state.asm = a.push_reg(state.asm, "rdx")
  state.asm = a.push_reg(state.asm, "r10")
  state.asm = a.push_reg(state.asm, "r11")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rcx")
  // Marked values (including gray objects) already belong to the snapshot.
  // Filtering these duplicate deletions bounds log growth and worker traffic.
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.mov_r64_r64(state.asm, "r11", "rcx")
  state.asm = a.sub_r64_r64(state.asm, "r11", "rax")
  state.asm = a.sub_r64_imm(state.asm, "r11", 8)
  state.asm = a.shr_r64_imm8(state.asm, "r11", 3)
  state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
  state.asm = a.shr_r64_imm8(state.asm, "rdx", 6)
  // Allocations in snapshot-free ranges are born outside this cycle.
  // The immutable exclusion bitmap also avoids logging their deletions.
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_reuse_min")
  state.asm = a.cmp_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.jcc(state.asm, "b", "satb_record_snapshot")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_reuse_bits")
  state.asm = a.mov_r64_mem_bis(state.asm, "rax", "rax", "rdx", 8, 0)
  state.asm = a.bt_r64_r64(state.asm, "rax", "r11")
  state.asm = a.jcc(state.asm, "b", "satb_record_restore")
  state.asm = a.mark(state.asm, "satb_record_snapshot")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_mark_bits_base")
  state.asm = a.mov_r64_mem_bis(state.asm, "rax", "rax", "rdx", 8, 0)
  state.asm = a.bt_r64_r64(state.asm, "rax", "r11")
  state.asm = a.jcc(state.asm, "b", "satb_record_restore")
  state.asm = a.lea_r64_rip(state.asm, "r11", "gc_satb_lock")
  state.asm = a.mark(state.asm, "satb_record_lock")
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.mov_r32_imm32(state.asm, "edx", 1)
  state.asm = a.lock_cmpxchg_membase_disp_r32(state.asm, "r11", 0, "edx")
  state.asm = a.jcc(state.asm, "e", "satb_record_owned")
  state.asm = a.emit(state.asm, fromHex("f390"))
  state.asm = a.jmp(state.asm, "satb_record_lock")
  state.asm = a.mark(state.asm, "satb_record_owned")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_satb_count")
  state.asm = a.cmp_r64_imm(state.asm, "rax", satb_capacity(state))
  state.asm = a.jcc(state.asm, "ae", "satb_record_overflow")
  state.asm = a.lea_r64_rip(state.asm, "rdx", "gc_satb_buffer")
  state.asm = a.mov_mem_bis_r64(state.asm, "rdx", "rax", 8, 0, "r10")
  state.asm = a.inc_r64(state.asm, "rax")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_satb_count")
  state.asm = a.jmp(state.asm, "satb_record_unlock")
  state.asm = a.mark(state.asm, "satb_record_overflow")
  // Never drop an edge and then reclaim. Overflow retains the entire snapshot.
  state.asm = a.mov_rax_imm64(state.asm, 1)
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_satb_overflow")
  state.asm = a.mark(state.asm, "satb_record_unlock")
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, 0, false)
  state.asm = a.mark(state.asm, "satb_record_restore")
  state.asm = a.pop_reg(state.asm, "r11")
  state.asm = a.pop_reg(state.asm, "r10")
  state.asm = a.pop_reg(state.asm, "rdx")
  state.asm = a.mark(state.asm, "satb_record_done")
  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.pop_reg(state.asm, "rcx")
  state.asm = a.ret(state.asm)
  return state
end function

// The worker consumes one logged value at a time without holding the heap lock.
/// Pop a logged reference under the spinlock, or return zero when empty.
/// @param state Backend state receiving the collector-only pop helper.
function emit_satb_pop(state)
  state = ensure_data(state)
  state.asm = a.mark(state.asm, "fn_gc_satb_pop")
  state.asm = a.lea_r64_rip(state.asm, "r11", "gc_satb_lock")
  state.asm = a.mark(state.asm, "satb_pop_lock")
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.mov_r32_imm32(state.asm, "edx", 1)
  state.asm = a.lock_cmpxchg_membase_disp_r32(state.asm, "r11", 0, "edx")
  state.asm = a.jcc(state.asm, "e", "satb_pop_owned")
  state.asm = a.emit(state.asm, fromHex("f390"))
  state.asm = a.jmp(state.asm, "satb_pop_lock")
  state.asm = a.mark(state.asm, "satb_pop_owned")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_satb_count")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", "satb_pop_empty")
  state.asm = a.dec_r64(state.asm, "rax")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_satb_count")
  state.asm = a.lea_r64_rip(state.asm, "rdx", "gc_satb_buffer")
  state.asm = a.mov_r64_mem_bis(state.asm, "rax", "rdx", "rax", 8, 0)
  state.asm = a.mark(state.asm, "satb_pop_empty")
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", 0, 0, false)
  state.asm = a.ret(state.asm)
  return state
end function

/// Insert free header RAX by floor(log2(size)); preserve all registers.
/// @param state Backend state receiving the native allocator helper.
function emit_free_push(state)
  state = ensure_data(state)
  state.asm = a.mark(state.asm, "fn_gc_free_push")
  for each reg in ["rax", "rcx", "rdx", "r10", "r11"]
    state.asm = a.push_reg(state.asm, reg)
  end for
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r10", 0)
  state.asm = a.and_r64_imm(state.asm, "rax", -8)
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.shr_r64_imm8(state.asm, "rdx", 32)
  state.asm = a.test_r32_r32(state.asm, "edx", "edx")
  state.asm = a.jcc(state.asm, "e", "gc_free_push_low")
  state.asm = a.bsr_r32_r32(state.asm, "edx", "edx")
  state.asm = a.add_r64_imm(state.asm, "rdx", 32)
  state.asm = a.jmp(state.asm, "gc_free_push_index")
  state.asm = a.mark(state.asm, "gc_free_push_low")
  state.asm = a.bsr_r32_r32(state.asm, "edx", "eax")
  state.asm = a.mark(state.asm, "gc_free_push_index")
  state.asm = a.lea_r64_rip(state.asm, "r11", "gc_free_bins")
  state.asm = a.mov_r64_mem_bis(state.asm, "rcx", "r11", "rdx", 8, 0)
  state.asm = a.mov_membase_disp_r64(state.asm, "r10", 8, "rcx")
  state.asm = a.mov_mem_bis_r64(state.asm, "r11", "rdx", 8, 0, "r10")
  for each reg in ["r11", "r10", "rdx", "rcx", "rax"]
    state.asm = a.pop_reg(state.asm, reg)
  end for
  state.asm = a.ret(state.asm)
  return state
end function

/// Move a detached list at RAX into size bins under the heap monitor.
/// @param state Backend state receiving the native allocator helper.
function emit_free_merge(state)
  state = ensure_data(state)
  state.used_helpers = mem._append_unique(state.used_helpers, "fn_gc_free_push")
  state.asm = a.mark(state.asm, "fn_gc_free_merge")
  state.asm = a.sub_rsp_imm8(state.asm, 40)
  state.asm = a.mark(state.asm, "gc_free_merge_loop")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", "gc_free_merge_done")
  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rax", 8)
  state.asm = a.call(state.asm, "fn_gc_free_push")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.jmp(state.asm, "gc_free_merge_loop")
  state.asm = a.mark(state.asm, "gc_free_merge_done")
  state.asm = a.add_rsp_imm8(state.asm, 40)
  state.asm = a.ret(state.asm)
  return state
end function

/// Detach all bins into gc_free_head only while preparing a snapshot.
/// @param state Backend state receiving the native allocator helper.
function emit_free_flatten(state)
  state = ensure_data(state)
  state.asm = a.mark(state.asm, "fn_gc_free_flatten")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_free_head")
  state.asm = a.lea_r64_rip(state.asm, "r11", "gc_free_bins")
  state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.mark(state.asm, "gc_free_flatten_bin")
  state.asm = a.mov_r64_mem_bis(state.asm, "r8", "r11", "rcx", 8, 0)
  state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
  state.asm = a.mov_mem_bis_r64(state.asm, "r11", "rcx", 8, 0, "rdx")
  state.asm = a.test_r64_r64(state.asm, "r8", "r8")
  state.asm = a.jcc(state.asm, "e", "gc_free_flatten_next")
  state.asm = a.mov_r64_r64(state.asm, "r9", "r8")
  state.asm = a.mark(state.asm, "gc_free_flatten_tail")
  state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "r9", 8)
  state.asm = a.test_r64_r64(state.asm, "rdx", "rdx")
  state.asm = a.jcc(state.asm, "e", "gc_free_flatten_link")
  state.asm = a.mov_r64_r64(state.asm, "r9", "rdx")
  state.asm = a.jmp(state.asm, "gc_free_flatten_tail")
  state.asm = a.mark(state.asm, "gc_free_flatten_link")
  state.asm = a.mov_membase_disp_r64(state.asm, "r9", 8, "rax")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.mark(state.asm, "gc_free_flatten_next")
  state.asm = a.inc_r64(state.asm, "rcx")
  state.asm = a.cmp_r64_imm(state.asm, "rcx", 64)
  state.asm = a.jcc(state.asm, "b", "gc_free_flatten_bin")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_free_head")
  state.asm = a.ret(state.asm)
  return state
end function

/// Pop the smallest suitable size class; allow >=4 KiB partial TLABs.
///
/// RCX is desired size, RDX is the TLAB flag. Return header R8 (or zero),
/// block size RDX and actual request RCX. Caller holds the heap monitor.
/// @param state Backend state receiving the native allocator helper.
function emit_free_take(state)
  state = ensure_data(state)
  state.asm = a.mark(state.asm, "fn_gc_free_take")
  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.test_r64_r64(state.asm, "rdx", "rdx")
  state.asm = a.jcc(state.asm, "e", "gc_free_take_class")
  // A refill is a capacity preference, not a user-visible 64 KiB object.
  // Reuse almost-full retired TLABs instead of cutting large buffer holes.
  state.asm = a.mov_r32_imm32(state.asm, "eax", 4096)
  state.asm = a.mark(state.asm, "gc_free_take_class")
  state.asm = a.mov_r64_r64(state.asm, "r9", "rax")
  state.asm = a.shr_r64_imm8(state.asm, "r9", 32)
  state.asm = a.test_r32_r32(state.asm, "r9d", "r9d")
  state.asm = a.jcc(state.asm, "e", "gc_free_take_low")
  state.asm = a.bsr_r32_r32(state.asm, "r9d", "r9d")
  state.asm = a.add_r64_imm(state.asm, "r9", 32)
  state.asm = a.jmp(state.asm, "gc_free_take_bin")
  state.asm = a.mark(state.asm, "gc_free_take_low")
  state.asm = a.bsr_r32_r32(state.asm, "r9d", "eax")
  state.asm = a.mark(state.asm, "gc_free_take_bin")
  state.asm = a.lea_r64_rip(state.asm, "r11", "gc_free_bins")
  state.asm = a.lea_r64_mem_bis(state.asm, "r10", "r11", "r9", 8, 0)
  state.asm = a.mark(state.asm, "gc_free_take_node")
  state.asm = a.mov_r64_membase_disp(state.asm, "r8", "r10", 0)
  state.asm = a.test_r64_r64(state.asm, "r8", "r8")
  state.asm = a.jcc(state.asm, "e", "gc_free_take_next_bin")
  if mem._uses_gc_stats(state) then
    state.asm = a.mov_rax_rip_qword(state.asm, "gc_free_probes")
    state.asm = a.inc_r64(state.asm, "rax")
    state.asm = a.mov_rip_qword_rax(state.asm, "gc_free_probes")
  end if
  state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "r8", 0)
  state.asm = a.and_r64_imm(state.asm, "rdx", -8)
  // A 64 KiB request visits smaller bins only in TLAB refill mode.
  state.asm = a.cmp_r64_imm(state.asm, "r9", 16)
  state.asm = a.jcc(state.asm, "ae", "gc_free_take_exact")
  state.asm = a.cmp_r64_r64(state.asm, "rdx", "rcx")
  state.asm = a.jcc(state.asm, "ae", "gc_free_take_found")
  // For ordinary small allocations, the first bin can be undersized.
  // Ordinary 64 KiB objects start at bin 16 and cannot take this path.
  state.asm = a.cmp_r64_imm(state.asm, "rcx", 65536)
  state.asm = a.jcc(state.asm, "ne", "gc_free_take_advance")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rdx")
  state.asm = a.jmp(state.asm, "gc_free_take_found")
  state.asm = a.mark(state.asm, "gc_free_take_exact")
  state.asm = a.cmp_r64_r64(state.asm, "rdx", "rcx")
  state.asm = a.jcc(state.asm, "ae", "gc_free_take_found")
  state.asm = a.mark(state.asm, "gc_free_take_advance")
  state.asm = a.lea_r64_membase_disp(state.asm, "r10", "r8", 8)
  state.asm = a.jmp(state.asm, "gc_free_take_node")
  state.asm = a.mark(state.asm, "gc_free_take_next_bin")
  state.asm = a.inc_r64(state.asm, "r9")
  state.asm = a.cmp_r64_imm(state.asm, "r9", 64)
  state.asm = a.jcc(state.asm, "b", "gc_free_take_bin")
  state.asm = a.ret(state.asm)
  state.asm = a.mark(state.asm, "gc_free_take_found")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r8", 8)
  state.asm = a.mov_membase_disp_r64(state.asm, "r10", 0, "rax")
  state.asm = a.ret(state.asm)
  return state
end function

/// Return validated bin count RAX, byte sum RDX and largest block RCX.
/// @param state Backend state receiving the native allocator helper.
function emit_free_stats(state)
  state = ensure_data(state)
  state.asm = a.mark(state.asm, "fn_gc_free_stats")
  for each reg in ["rbx", "rsi", "rdi"]
    state.asm = a.push_reg(state.asm, reg)
  end for
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
  state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.xor_r32_r32(state.asm, "ebx", "ebx")
  state.asm = a.lea_r64_rip(state.asm, "rsi", "gc_free_bins")
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_ptr")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.mov_r64_r64(state.asm, "r9", "r10")
  state.asm = a.sub_r64_r64(state.asm, "r9", "r11")
  state.asm = a.shr_r64_imm8(state.asm, "r9", 4)
  state.asm = a.mark(state.asm, "gc_free_stats_bin")
  state.asm = a.mov_r64_mem_bis(state.asm, "r8", "rsi", "rbx", 8, 0)
  state.asm = a.mark(state.asm, "gc_free_stats_node")
  state.asm = a.test_r64_r64(state.asm, "r8", "r8")
  state.asm = a.jcc(state.asm, "e", "gc_free_stats_next")
  state.asm = a.test_r64_r64(state.asm, "r9", "r9")
  state.asm = a.jcc(state.asm, "e", "gc_free_stats_bad")
  state.asm = a.dec_r64(state.asm, "r9")
  state.asm = a.cmp_r64_r64(state.asm, "r8", "r11")
  state.asm = a.jcc(state.asm, "b", "gc_free_stats_bad")
  // Reject high invalid pointers before header-end arithmetic can wrap.
  state.asm = a.cmp_r64_r64(state.asm, "r8", "r10")
  state.asm = a.jcc(state.asm, "ae", "gc_free_stats_bad")
  state.asm = a.lea_r64_membase_disp(state.asm, "rdi", "r8", 16)
  state.asm = a.cmp_r64_r64(state.asm, "rdi", "r10")
  state.asm = a.jcc(state.asm, "a", "gc_free_stats_bad")
  state.asm = a.test_r64_imm32(state.asm, "r8", 7)
  state.asm = a.jcc(state.asm, "ne", "gc_free_stats_bad")
  state.asm = a.mov_r64_membase_disp(state.asm, "rdi", "r8", 0)
  state.asm = a.test_r64_imm32(state.asm, "rdi", 1)
  state.asm = a.jcc(state.asm, "e", "gc_free_stats_bad")
  state.asm = a.and_r64_imm(state.asm, "rdi", -8)
  state.asm = a.cmp_r64_imm(state.asm, "rdi", 16)
  state.asm = a.jcc(state.asm, "b", "gc_free_stats_bad")
  state.asm = a.add_r64_r64(state.asm, "rdi", "r8")
  state.asm = a.jcc(state.asm, "b", "gc_free_stats_bad")
  state.asm = a.cmp_r64_r64(state.asm, "rdi", "r10")
  state.asm = a.jcc(state.asm, "a", "gc_free_stats_bad")
  state.asm = a.sub_r64_r64(state.asm, "rdi", "r8")
  state.asm = a.inc_r64(state.asm, "rax")
  state.asm = a.add_r64_r64(state.asm, "rdx", "rdi")
  state.asm = a.cmp_r64_r64(state.asm, "rcx", "rdi")
  state.asm = a.jcc(state.asm, "ae", "gc_free_stats_size")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rdi")
  state.asm = a.mark(state.asm, "gc_free_stats_size")
  state.asm = a.mov_r64_membase_disp(state.asm, "r8", "r8", 8)
  state.asm = a.jmp(state.asm, "gc_free_stats_node")
  state.asm = a.mark(state.asm, "gc_free_stats_next")
  state.asm = a.inc_r64(state.asm, "rbx")
  state.asm = a.cmp_r64_imm(state.asm, "rbx", 64)
  state.asm = a.jcc(state.asm, "b", "gc_free_stats_bin")
  state.asm = a.jmp(state.asm, "gc_free_stats_done")
  state.asm = a.mark(state.asm, "gc_free_stats_bad")
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
  state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.mark(state.asm, "gc_free_stats_done")
  for each reg in ["rdi", "rsi", "rbx"]
    state.asm = a.pop_reg(state.asm, reg)
  end for
  state.asm = a.ret(state.asm)
  return state
end function
/// Emit the public free-byte/count query over all size bins.
/// @param state Backend state receiving the native allocator helper.
/// @param byte_sum Select the sum of free bytes instead of the free block count.
function emit_heap_free_stat(state, byte_sum)
  state = ensure_data(state)
  state.used_helpers = mem._append_unique(state.used_helpers, "fn_heap_enter")
  state.used_helpers = mem._append_unique(state.used_helpers, "fn_heap_leave")
  state.used_helpers = mem._append_unique(state.used_helpers, "fn_gc_free_stats")
  label = "fn_heap_free_blocks"
  if byte_sum then
    label = "fn_heap_free_bytes"
  end if
  state.asm = a.mark(state.asm, label)
  state.asm = a.sub_rsp_imm8(state.asm, 40)
  state.asm = a.call(state.asm, "fn_heap_enter")
  state.asm = a.call(state.asm, "fn_gc_free_stats")
  if byte_sum then
    state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")
  end if
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.or_rax_imm8(state.asm, 1)
  state.asm = a.call(state.asm, "fn_heap_leave")
  state.asm = a.add_rsp_imm8(state.asm, 40)
  state.asm = a.ret(state.asm)
  return state
end function

/// Return the end of the protected run containing header RAX (leaf).
/// @param state Backend state receiving the snapshot reuse helper.
function emit_reuse_end(state)
  state = ensure_data(state)
  state.asm = a.mark(state.asm, "fn_gc_reuse_end")
  state.asm = a.mov_rdx_rip_qword(state.asm, "heap_base")
  state.asm = a.sub_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.shr_r64_imm8(state.asm, "rax", 3)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.shr_r64_imm8(state.asm, "rax", 6)
  state.asm = a.mov_r64_r64(state.asm, "r8", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_reuse_bits")
  state.asm = a.mov_r64_r64(state.asm, "r9", "rax")
  state.asm = a.mov_r64_mem_bis(state.asm, "rax", "r9", "r8", 8, 0)
  // Ignore bits before the requested header in its first bitmap word.
  state.asm = a.mov_r64_imm64(state.asm, "r11", -1)
  state.asm = a.shl_r64_cl(state.asm, "r11")
  state.asm = a.xor_r64_imm(state.asm, "r11", -1)
  state.asm = a.or_r64_r64(state.asm, "rax", "r11")
  state.asm = a.mark(state.asm, "gc_reuse_end_word")
  state.asm = a.xor_r64_imm(state.asm, "rax", -1)
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "ne", "gc_reuse_end_bit")
  state.asm = a.inc_r64(state.asm, "r8")
  state.asm = a.mov_r64_mem_bis(state.asm, "rax", "r9", "r8", 8, 0)
  state.asm = a.jmp(state.asm, "gc_reuse_end_word")
  state.asm = a.mark(state.asm, "gc_reuse_end_bit")
  // BSF32 works on baseline x64; no BMI/POPCNT or AVX requirement.
  state.asm = a.xor_r32_r32(state.asm, "r11d", "r11d")
  state.asm = a.test_r32_r32(state.asm, "eax", "eax")
  state.asm = a.jcc(state.asm, "ne", "gc_reuse_end_low")
  state.asm = a.shr_r64_imm8(state.asm, "rax", 32)
  state.asm = a.mov_r32_imm32(state.asm, "r11d", 32)
  state.asm = a.mark(state.asm, "gc_reuse_end_low")
  state.asm = a.bsf_r32_r32(state.asm, "eax", "eax")
  state.asm = a.add_r64_r64(state.asm, "rax", "r11")
  state.asm = a.shl_r64_imm8(state.asm, "r8", 6)
  state.asm = a.add_r64_r64(state.asm, "rax", "r8")
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.add_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.ret(state.asm)
  return state
end function

/// Protect and coalesce central free ranges while all mutators are parked.
/// @param state Backend state receiving the snapshot reuse helper.
function emit_reuse_snapshot(state)
  state = ensure_data(state)
  state.used_helpers = state.used_helpers + ["fn_gc_reuse_end", "fn_gc_free_push"]
  state.asm = a.mark(state.asm, "fn_gc_reuse_snapshot")
  for each reg in ["rbx", "rbp", "rsi", "rdi", "r12", "r13", "r14", "r15"]
    state.asm = a.push_reg(state.asm, reg)
  end for
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.mov_r64_r64(state.asm, "rbp", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_concurrent_frontier")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_reuse_min")
  state.asm = a.sub_r64_r64(state.asm, "rax", "rbp")
  // One exclusion bit per 8 heap bytes, plus a zero sentinel word so
  // scanning a free run ending exactly on a bitmap page cannot overread.
  state.asm = a.add_r64_imm(state.asm, "rax", 511)
  state.asm = a.shr_r64_imm8(state.asm, "rax", 9)
  state.asm = a.inc_r64(state.asm, "rax")
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.mov_r64_r64(state.asm, "r13", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_reuse_capacity")
  state.asm = a.cmp_r64_r64(state.asm, "rax", "r13")
  state.asm = a.jcc(state.asm, "ae", "gc_reuse_storage_ready")
  state.asm = a.shl_rax_imm8(state.asm, 1)
  state.asm = a.cmp_r64_r64(state.asm, "rax", "r13")
  state.asm = a.jcc(state.asm, "ae", "gc_reuse_storage_size")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r13")
  state.asm = a.mark(state.asm, "gc_reuse_storage_size")
  state.asm = a.add_r64_imm(state.asm, "rax", 4095)
  state.asm = a.and_r64_imm(state.asm, "rax", -4096)
  state.asm = a.mov_r64_r64(state.asm, "r14", "rax")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.mov_r8d_imm32(state.asm, 0x3000)
  state.asm = a.mov_r9d_imm32(state.asm, 4)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_VirtualAlloc")
  state.asm = a.call_rax(state.asm)
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", "gc_reuse_storage_failed")
  state.asm = a.mov_r64_r64(state.asm, "r12", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_reuse_bits")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", "gc_reuse_storage_publish")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
  state.asm = a.mov_r8d_imm32(state.asm, 0x8000)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_VirtualFree")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mark(state.asm, "gc_reuse_storage_publish")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r12")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_reuse_bits")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r14")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_reuse_capacity")
  state.asm = a.mark(state.asm, "gc_reuse_storage_ready")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_reuse_bits")
  state.asm = a.mov_r64_r64(state.asm, "r12", "rax")
  state.asm = a.mov_r64_r64(state.asm, "rdi", "rax")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "r13")
  state.asm = a.shr_r64_imm8(state.asm, "rcx", 3)
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.rep_stosq(state.asm)
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_free_head")
  state.asm = a.mov_r64_r64(state.asm, "r14", "rax")
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_free_head")
  state.asm = a.xor_r32_r32(state.asm, "r15d", "r15d")
  // Consume bins directly while constructing the exclusion bitmap.
  // Flattening first walked every cache-cold free header an extra time.
  state.asm = a.lea_r64_rip(state.asm, "rbx", "gc_free_bins")
  state.asm = a.mark(state.asm, "gc_reuse_protect_loop")
  state.asm = a.test_r64_r64(state.asm, "r14", "r14")
  state.asm = a.jcc(state.asm, "e", "gc_reuse_protect_bin")
  state.asm = a.mov_r64_membase_disp(state.asm, "rsi", "r14", 8)
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_reuse_min")
  state.asm = a.cmp_r64_r64(state.asm, "r14", "rax")
  state.asm = a.jcc(state.asm, "ae", "gc_reuse_min_done")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r14")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_reuse_min")
  state.asm = a.mark(state.asm, "gc_reuse_min_done")
  state.asm = a.mov_r64_r64(state.asm, "r8", "r14")
  state.asm = a.sub_r64_r64(state.asm, "r8", "rbp")
  state.asm = a.mov_r64_membase_disp(state.asm, "r9", "r14", 0)
  state.asm = a.and_r64_imm(state.asm, "r9", -8)
  state.asm = a.add_r64_r64(state.asm, "r9", "r8")
  state.asm = a.shr_r64_imm8(state.asm, "r8", 3)
  state.asm = a.shr_r64_imm8(state.asm, "r9", 3)
  state.asm = a.dec_r64(state.asm, "r9")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "r8")
  state.asm = a.shr_r64_imm8(state.asm, "rdx", 6)
  state.asm = a.mov_r64_r64(state.asm, "r10", "r9")
  state.asm = a.shr_r64_imm8(state.asm, "r10", 6)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "r8")
  state.asm = a.mov_r64_imm64(state.asm, "r11", -1)
  state.asm = a.shl_r64_cl(state.asm, "r11")
  state.asm = a.and_r64_imm(state.asm, "r9", 63)
  state.asm = a.mov_rcx_imm32(state.asm, 63)
  state.asm = a.sub_r64_r64(state.asm, "rcx", "r9")
  state.asm = a.mov_rax_imm64(state.asm, -1)
  state.asm = a.shr_r64_cl(state.asm, "rax")
  state.asm = a.cmp_r64_r64(state.asm, "rdx", "r10")
  state.asm = a.jcc(state.asm, "ne", "gc_reuse_multiple_words")
  state.asm = a.and_r64_r64(state.asm, "rax", "r11")
  state.asm = a.mov_r64_mem_bis(state.asm, "rcx", "r12", "rdx", 8, 0)
  state.asm = a.or_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.mov_mem_bis_r64(state.asm, "r12", "rdx", 8, 0, "rax")
  state.asm = a.jmp(state.asm, "gc_reuse_protect_next")
  state.asm = a.mark(state.asm, "gc_reuse_multiple_words")
  state.asm = a.mov_r64_mem_bis(state.asm, "rcx", "r12", "rdx", 8, 0)
  state.asm = a.or_r64_r64(state.asm, "rcx", "r11")
  state.asm = a.mov_mem_bis_r64(state.asm, "r12", "rdx", 8, 0, "rcx")
  state.asm = a.mov_r64_mem_bis(state.asm, "rcx", "r12", "r10", 8, 0)
  state.asm = a.or_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.mov_mem_bis_r64(state.asm, "r12", "r10", 8, 0, "rax")
  state.asm = a.lea_r64_mem_bis(state.asm, "rdi", "r12", "rdx", 8, 8)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "r10")
  state.asm = a.sub_r64_r64(state.asm, "rcx", "rdx")
  state.asm = a.dec_r64(state.asm, "rcx")
  state.asm = a.mov_rax_imm64(state.asm, -1)
  state.asm = a.rep_stosq(state.asm)
  state.asm = a.mark(state.asm, "gc_reuse_protect_next")
  state.asm = a.mov_r64_r64(state.asm, "r14", "rsi")
  state.asm = a.jmp(state.asm, "gc_reuse_protect_loop")
  state.asm = a.mark(state.asm, "gc_reuse_protect_bin")
  state.asm = a.cmp_r64_imm(state.asm, "r15", 64)
  state.asm = a.jcc(state.asm, "ae", "gc_reuse_coalesce_begin")
  state.asm = a.mov_r64_mem_bis(state.asm, "r14", "rbx", "r15", 8, 0)
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.mov_mem_bis_r64(state.asm, "rbx", "r15", 8, 0, "rax")
  state.asm = a.inc_r64(state.asm, "r15")
  state.asm = a.jmp(state.asm, "gc_reuse_protect_loop")
  // Coalesce maximal runs from the compact immutable bitmap, avoiding a
  // second cache-cold walk through free headers. Publish each completed
  // run directly into its size bin, without another temporary list walk.
  state.asm = a.mark(state.asm, "gc_reuse_coalesce_begin")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_reuse_min")
  state.asm = a.sub_r64_r64(state.asm, "rax", "rbp")
  state.asm = a.shr_r64_imm8(state.asm, "rax", 3)
  state.asm = a.mov_r64_r64(state.asm, "r14", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_concurrent_frontier")
  state.asm = a.sub_r64_r64(state.asm, "rax", "rbp")
  state.asm = a.shr_r64_imm8(state.asm, "rax", 3)
  state.asm = a.mov_r64_r64(state.asm, "r13", "rax")
  state.asm = a.mark(state.asm, "gc_reuse_coalesce_loop")
  state.asm = a.cmp_r64_r64(state.asm, "r14", "r13")
  state.asm = a.jcc(state.asm, "ae", "gc_reuse_coalesce_done")
  state.asm = a.mov_r64_r64(state.asm, "r8", "r14")
  state.asm = a.shr_r64_imm8(state.asm, "r8", 6)
  state.asm = a.mov_r64_mem_bis(state.asm, "rax", "r12", "r8", 8, 0)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "r14")
  state.asm = a.mov_r64_imm64(state.asm, "rdx", -1)
  state.asm = a.shl_r64_cl(state.asm, "rdx")
  state.asm = a.and_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "ne", "gc_reuse_coalesce_bit")
  state.asm = a.or_r64_imm(state.asm, "r14", 63)
  state.asm = a.inc_r64(state.asm, "r14")
  // Large live buffers leave long zero spans. Skip 128 bitmap bytes
  // together, bounded by the frozen frontier (baseline x64, no SIMD).
  state.asm = a.mark(state.asm, "gc_reuse_coalesce_zero")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r14")
  state.asm = a.add_r64_imm(state.asm, "rax", 1024)
  state.asm = a.cmp_r64_r64(state.asm, "rax", "r13")
  state.asm = a.jcc(state.asm, "a", "gc_reuse_coalesce_loop")
  state.asm = a.mov_r64_r64(state.asm, "r8", "r14")
  state.asm = a.shr_r64_imm8(state.asm, "r8", 6)
  state.asm = a.mov_r64_mem_bis(state.asm, "rax", "r12", "r8", 8, 0)
  for i = 1 to 15
    state.asm = a.mov_r64_mem_bis(state.asm, "rdx", "r12", "r8", 8, i * 8)
    state.asm = a.or_r64_r64(state.asm, "rax", "rdx")
  end for
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "ne", "gc_reuse_coalesce_loop")
  state.asm = a.add_r64_imm(state.asm, "r14", 1024)
  state.asm = a.jmp(state.asm, "gc_reuse_coalesce_zero")
  state.asm = a.mark(state.asm, "gc_reuse_coalesce_bit")
  state.asm = a.and_r64_imm(state.asm, "r14", -64)
  state.asm = a.test_r32_r32(state.asm, "eax", "eax")
  state.asm = a.jcc(state.asm, "ne", "gc_reuse_coalesce_low")
  state.asm = a.shr_r64_imm8(state.asm, "rax", 32)
  state.asm = a.add_r64_imm(state.asm, "r14", 32)
  state.asm = a.mark(state.asm, "gc_reuse_coalesce_low")
  state.asm = a.bsf_r32_r32(state.asm, "eax", "eax")
  state.asm = a.add_r64_r64(state.asm, "r14", "rax")
  state.asm = a.shl_r64_imm8(state.asm, "r14", 3)
  state.asm = a.add_r64_r64(state.asm, "r14", "rbp")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r14")
  state.asm = a.call(state.asm, "fn_gc_reuse_end")
  state.asm = a.mov_r64_r64(state.asm, "rsi", "rax")
  state.asm = a.sub_r64_r64(state.asm, "rax", "r14")
  state.asm = a.or_r64_imm(state.asm, "rax", 1)
  state.asm = a.mov_membase_disp_r64(state.asm, "r14", 0, "rax")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r14")
  state.asm = a.call(state.asm, "fn_gc_free_push")
  state.asm = a.mov_r64_r64(state.asm, "r14", "rsi")
  state.asm = a.sub_r64_r64(state.asm, "r14", "rbp")
  state.asm = a.shr_r64_imm8(state.asm, "r14", 3)
  state.asm = a.jmp(state.asm, "gc_reuse_coalesce_loop")
  state.asm = a.mark(state.asm, "gc_reuse_coalesce_done")
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_free_head")
  state.asm = a.jmp(state.asm, "gc_reuse_snapshot_done")
  state.asm = a.mark(state.asm, "gc_reuse_storage_failed")
  // Safe fallback to the old frozen-list policy if metadata allocation
  // fails. The frontier minimum disables every exclusion-bitmap read.
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_free_head")
  state.asm = a.lea_r64_rip(state.asm, "rdi", "gc_free_bins")
  state.asm = a.mov_rcx_imm32(state.asm, 64)
  state.asm = a.rep_stosq(state.asm)
  state.asm = a.mark(state.asm, "gc_reuse_snapshot_done")
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  for each reg in ["r15", "r14", "r13", "r12", "rdi", "rsi", "rbp", "rbx"]
    state.asm = a.pop_reg(state.asm, reg)
  end for
  state.asm = a.ret(state.asm)
  return state
end function

/// Emit a persistent native worker waiting on an auto-reset event between cycles.
/// @param state Backend state receiving the private worker loop.
function emit_worker(state)
  state = ensure_data(state)
  state.used_helpers = state.used_helpers + ["fn_gc_concurrent_cycle"]
  state.asm = a.mark(state.asm, "fn_gc_concurrent_worker")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)
  state.asm = a.lea_rax_rip(state.asm, "gc_concurrent_context")
  state.asm = a.mov_gs_qword_28_rax(state.asm)
  state.asm = a.mark(state.asm, "gc_worker_wait")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_concurrent_go")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_r32_imm32(state.asm, "edx", -1)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WaitForSingleObject")
  state.asm = a.call_rax(state.asm)
  state.asm = a.call(state.asm, "fn_gc_concurrent_cycle")
  state.asm = a.jmp(state.asm, "gc_worker_wait")
  return state
end function

/// Return the completion sequence to wait for, coalescing already-active requests.
/// Initialization and publication use the reentrant heap monitor, including fn_alloc calls.
/// @param state Backend state receiving the asynchronous request helper.
function emit_request(state)
  state = ensure_data(state)
  state.used_helpers = state.used_helpers + ["fn_gc_concurrent_worker", "fn_heap_enter", "fn_heap_leave"]
  state.asm = a.mark(state.asm, "fn_gc_concurrent_request")
  state.asm = a.sub_rsp_imm8(state.asm, 0x38)
  state.asm = a.call(state.asm, "fn_heap_enter")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_concurrent_phase")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x30, "rax")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "ne", "gc_request_return")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_concurrent_handle")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "ne", "gc_request_ready")
  // Both events are private unnamed Win32 handles.
  for each name in ["gc_concurrent_go", "gc_concurrent_done"]
    state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
    manual = 0
    if name == "gc_concurrent_done" then manual = 1 end if
    state.asm = a.mov_r32_imm32(state.asm, "edx", manual)
    state.asm = a.xor_r32_r32(state.asm, "r8d", "r8d")
    state.asm = a.xor_r32_r32(state.asm, "r9d", "r9d")
    state.asm = a.mov_rax_rip_qword(state.asm, "iat_CreateEventW")
    state.asm = a.call_rax(state.asm)
    state.asm = a.test_r64_r64(state.asm, "rax", "rax")
    state.asm = a.jcc(state.asm, "e", "gc_worker_init_failed")
    state.asm = a.mov_rip_qword_rax(state.asm, name)
  end for
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x28, 0, true)
  state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
  state.asm = a.lea_r8_rip(state.asm, "fn_gc_concurrent_worker")
  state.asm = a.xor_r32_r32(state.asm, "r9d", "r9d")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_CreateThread")
  state.asm = a.call_rax(state.asm)
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", "gc_worker_init_failed")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_concurrent_handle")
  state.asm = a.mark(state.asm, "gc_request_ready")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_concurrent_done")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_ResetEvent")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_rax_imm64(state.asm, 3)
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_concurrent_phase")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_concurrent_go")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_SetEvent")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mark(state.asm, "gc_request_return")
  // Account another threshold only after allocations made since this request.
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_bytes_since")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_young_bytes_since")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_concurrent_completed")
  state.asm = a.inc_r64(state.asm, "rax")
  state.asm = a.call(state.asm, "fn_heap_leave")
  state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", 0x30)
  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)
  state.asm = a.mark(state.asm, "gc_worker_init_failed")
  state.asm = a.mov_r32_imm32(state.asm, "ecx", 1)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_ExitProcess")
  state.asm = a.call_rax(state.asm)
  return state
end function

/// Keep gc_collect synchronous while other managed threads continue running.
/// Emergency waiters release all recursive heap locks and restore the original depth.
/// @param state Backend state receiving the completion-wait helper.
function emit_collect(state)
  state = ensure_data(state)
  state.used_helpers = state.used_helpers + ["fn_gc_concurrent_request", "fn_gc_native_enter", "fn_gc_native_leave", "fn_heap_enter", "fn_heap_leave"]
  state.asm = a.mark(state.asm, "fn_gc_collect")
  state.asm = a.push_reg(state.asm, "rbx")
  state.asm = a.push_reg(state.asm, "r12")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)
  state.asm = a.mov_r11_gs_qword_28(state.asm)
  state.asm = a.mov_r32_membase_disp(state.asm, "ebx", "r11", HEAP_LOCK_DEPTH)
  state.asm = a.mov_r64_r64(state.asm, "r12", "rbx")
  state.asm = a.mark(state.asm, "gc_collect_release")
  state.asm = a.test_r64_r64(state.asm, "r12", "r12")
  state.asm = a.jcc(state.asm, "e", "gc_collect_request")
  state.asm = a.call(state.asm, "fn_heap_leave")
  state.asm = a.dec_r64(state.asm, "r12")
  state.asm = a.jmp(state.asm, "gc_collect_release")
  state.asm = a.mark(state.asm, "gc_collect_request")
  state.asm = a.call(state.asm, "fn_gc_concurrent_request")
  // If another cycle was already active, wait for it and then request a fresh
  // snapshot. Do not wait to observe an idle phase: continuous allocation can
  // legitimately request the next cycle before that observation is possible.
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rdx")
  state.asm = a.mov_r64_r64(state.asm, "r12", "rax")
  state.asm = a.mark(state.asm, "gc_collect_wait_enter")
  state.asm = a.call(state.asm, "fn_gc_native_enter")
  state.asm = a.mark(state.asm, "gc_collect_wait")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_concurrent_completed")
  state.asm = a.cmp_r64_r64(state.asm, "rax", "r12")
  state.asm = a.jcc(state.asm, "ae", "gc_collect_restore")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_concurrent_done")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_r32_imm32(state.asm, "edx", 10)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WaitForSingleObject")
  state.asm = a.call_rax(state.asm)
  state.asm = a.jmp(state.asm, "gc_collect_wait")
  state.asm = a.mark(state.asm, "gc_collect_restore")
  state.asm = a.call(state.asm, "fn_gc_native_leave")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x20)
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", "gc_collect_relock")
  state.asm = a.call(state.asm, "fn_gc_concurrent_request")
  state.asm = a.mov_r64_r64(state.asm, "r12", "rax")
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
  state.asm = a.jmp(state.asm, "gc_collect_wait_enter")
  state.asm = a.mark(state.asm, "gc_collect_relock")
  state.asm = a.test_r64_r64(state.asm, "rbx", "rbx")
  state.asm = a.jcc(state.asm, "e", "gc_collect_return")
  state.asm = a.call(state.asm, "fn_heap_enter")
  // Another emergency waiter may have started a new snapshot before this
  // allocator reacquired the monitor. That snapshot temporarily hides all
  // reusable old blocks. Wait for it instead of returning a false OOM on the
  // allocator's one retry; observe idle while holding the monitor.
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_concurrent_phase")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", "gc_collect_relock_owned")
  state.asm = a.call(state.asm, "fn_heap_leave")
  state.asm = a.call(state.asm, "fn_gc_concurrent_request")
  state.asm = a.mov_r64_r64(state.asm, "r12", "rax")
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
  state.asm = a.jmp(state.asm, "gc_collect_wait_enter")
  state.asm = a.mark(state.asm, "gc_collect_relock_owned")
  state.asm = a.dec_r64(state.asm, "rbx")
  state.asm = a.jmp(state.asm, "gc_collect_relock")
  state.asm = a.mark(state.asm, "gc_collect_return")
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.pop_reg(state.asm, "r12")
  state.asm = a.pop_reg(state.asm, "rbx")
  state.asm = a.ret(state.asm)
  return state
end function
