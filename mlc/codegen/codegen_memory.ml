package mlc.codegen.codegen_memory
import mlc.asm as a
import mlc.constants as c
import mlc.tools as t
import mlc.data as d

const MEM_PAGE_SIZE = 0x1000
const MEM_RESERVE_GRANULARITY = 0x10000
const HEAP_SIZE_DEFAULT = 0x02000000
const HEAP_COMMIT_DEFAULT = HEAP_SIZE_DEFAULT
const HEAP_RESERVE_DEFAULT = 1024 * 1024 * 1024 * 4
const HEAP_RESERVE_MIN = HEAP_SIZE_DEFAULT
const HEAP_GROW_MIN = 0x01000000
const ALLOC_MIN_SPLIT = 32
const GC_MARK_STACK_QWORDS = 8388608
const GC_DEFAULT_BYTES_LIMIT = 64 << 20
const GC_DISABLE_PERIODIC_LIMIT = 0x7FFFFFFFFFFFFFFF
const GC_YOUNG_DEFAULT_BYTES_LIMIT = 8 << 20
const GC_YOUNG_OBJECT_MAX_BYTES = 256
const MEMORY_ENABLE_REFCOUNT = false

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

function _has_label(labels, name)
  if typeof(labels) != "array" or len(labels) <= 0 then return false end if
  for i = 0 to len(labels) - 1
    it = labels[i]
    if typeof(it) == "struct" and it.name == name then return true end if
  end for
  return false
end function

function _ensure_data_u64(db, name, value)
  if _has_label(db.labels, name) then return db end if
  return d.data_add_u64(db, name, value)
end function

function _ensure_rdata_str(rb, name, text)
  if _has_label(rb.labels, name) then return rb end if
  return d.rdata_add_str_nl(rb, name, text, false)
end function

function _mark_bitmap_bytes_for_heap_bytes(heap_bytes)
  if heap_bytes < 0 then heap_bytes = 0 end if
  return (heap_bytes + 63) >> 6
end function

function _rlabel_len(labels, name)
  if typeof(labels) != "array" or len(labels) <= 0 then return 0 end if
  for i = 0 to len(labels) - 1
    it = labels[i]
    if typeof(it) == "struct" and it.name == name then
      if typeof(it.length) == "int" then return it.length end if
      return 0
    end if
  end for
  return 0
end function

function _heap_cfg_get_any(state, key)
  cfg = 0
  if typeof(state) == "struct" then cfg = state.heap_config end if
  if typeof(cfg) != "array" or len(cfg) <= 0 then return 0 end if
  for i = 0 to len(cfg) - 1
    it = cfg[i]
    if typeof(it) == "struct" and typeof(it.key) == "string" and it.key == key then
      return it.value
    end if
    if typeof(it) == "array" and len(it) >= 2 and typeof(it[0]) == "string" and it[0] == key then
      return it[1]
    end if
  end for
  return 0
end function

function _heap_cfg_get_int(state, key, defaultv)
  v = _heap_cfg_get_any(state, key)
  if typeof(v) == "int" then return v end if
  return defaultv
end function

function _heap_cfg_has_any(state)
  cfg = 0
  if typeof(state) == "struct" then cfg = state.heap_config end if
  return typeof(cfg) == "array" and len(cfg) > 0
end function

function __init__(state)
  return state
end function

function ensure_gc_data(state)
  db = state.data
  bb = state.bss

  db = _ensure_data_u64(db, "gc_roots_head", 0)
  db = _ensure_data_u64(db, "gc_free_head", 0)
  db = _ensure_data_u64(db, "gc_bytes_since", 0)
  db = _ensure_data_u64(db, "gc_bytes_limit", GC_DEFAULT_BYTES_LIMIT)
  db = _ensure_data_u64(db, "gc_young_bytes_since", 0)
  db = _ensure_data_u64(db, "gc_young_bytes_limit", GC_YOUNG_DEFAULT_BYTES_LIMIT)

  for i = 0 to 7
    nm = "gc_tmp" + i
    db = _ensure_data_u64(db, nm, t.enc_void())
  end for

  db = _ensure_data_u64(db, "gc_mark_top", 0)
  db = _ensure_data_u64(db, "gc_mark_bits_base", 0)
  db = _ensure_data_u64(db, "gc_mark_bits_end", 0)
  db = _ensure_data_u64(db, "gc_mark_bits_reserve_end", 0)

  db = _ensure_data_u64(db, "heap_base", 0)
  db = _ensure_data_u64(db, "heap_ptr", 0)
  db = _ensure_data_u64(db, "heap_end", 0)
  db = _ensure_data_u64(db, "heap_reserve_end", 0)
  db = _ensure_data_u64(db, "heap_min_end", 0)
  db = _ensure_data_u64(db, "heap_commit_bytes", 0)
  db = _ensure_data_u64(db, "heap_reserve_bytes", 0)

  has_ms_data = _has_label(db.labels, "gc_mark_stack")
  has_ms_bss = _has_label(bb.labels, "gc_mark_stack")
  if has_ms_data == false and has_ms_bss == false then
    bb = d.bss_reserve(bb, "gc_mark_stack", GC_MARK_STACK_QWORDS * 8, 8)
  end if

  state.data = db
  state.bss = bb
  return state
end function

function emit_heap_init(state, heap_size)
  state = ensure_gc_data(state)

  reserve_bytes = _heap_cfg_get_int(state, "reserve_bytes", HEAP_RESERVE_DEFAULT)
  commit_bytes = _heap_cfg_get_int(state, "commit_bytes", HEAP_COMMIT_DEFAULT)
  shrink_min_bytes = _heap_cfg_get_int(state, "shrink_min_bytes", 0)
  if shrink_min_bytes <= 0 then
    shrink_min_bytes = _heap_cfg_get_int(state, "heap_shrink_min_bytes", commit_bytes)
  end if

  if _heap_cfg_has_any(state) == false and typeof(heap_size) == "int" and heap_size > 0 and heap_size != HEAP_SIZE_DEFAULT then
    reserve_bytes = heap_size
    commit_bytes = heap_size
    shrink_min_bytes = commit_bytes
  end if

  if typeof(reserve_bytes) != "int" or reserve_bytes <= 0 then
    reserve_bytes = toNumber("4294967296")
    if typeof(reserve_bytes) != "int" or reserve_bytes <= 0 then
      reserve_bytes = HEAP_SIZE_DEFAULT
    end if
  end if
  if typeof(commit_bytes) != "int" or commit_bytes <= 0 then
    commit_bytes = HEAP_COMMIT_DEFAULT
  end if
  if typeof(shrink_min_bytes) != "int" or shrink_min_bytes <= 0 then
    shrink_min_bytes = commit_bytes
  end if
  reserve_bytes = t.align_up(reserve_bytes, MEM_RESERVE_GRANULARITY)
  commit_bytes = t.align_up(commit_bytes, MEM_PAGE_SIZE)
  shrink_min_bytes = t.align_up(shrink_min_bytes, MEM_PAGE_SIZE)
  if commit_bytes > reserve_bytes then commit_bytes = reserve_bytes end if
  if shrink_min_bytes > commit_bytes then shrink_min_bytes = commit_bytes end if

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_ok_res = "heap_res_ok_" + lid
  l_ok_com = "heap_com_ok_" + lid

  // reserve: base = VirtualAlloc(NULL, reserve, MEM_RESERVE, PAGE_READWRITE)
  state.asm = a.xor_ecx_ecx(state.asm)
  state.asm = a.mov_rax_imm64(state.asm, reserve_bytes)
  state.asm = a.mov_rdx_rax(state.asm)
  state.asm = a.mov_r8d_imm32(state.asm, 0x2000)
  state.asm = a.mov_r9d_imm32(state.asm, 0x04)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_VirtualAlloc")
  state.asm = a.call_rax(state.asm)
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "ne", l_ok_res)
  state.asm = a.mov_rcx_imm32(state.asm, 1)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_ExitProcess")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mark(state.asm, l_ok_res)

  state.asm = a.mov_rip_qword_rax(state.asm, "heap_base")
  state.asm = a.mov_rip_qword_rax(state.asm, "heap_ptr")

  // commit: VirtualAlloc(base, commit, MEM_COMMIT, PAGE_READWRITE)
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_imm64(state.asm, commit_bytes)
  state.asm = a.mov_rdx_rax(state.asm)
  state.asm = a.mov_r8d_imm32(state.asm, 0x1000)
  state.asm = a.mov_r9d_imm32(state.asm, 0x04)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_VirtualAlloc")
  state.asm = a.call_rax(state.asm)
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "ne", l_ok_com)
  state.asm = a.mov_rcx_imm32(state.asm, 1)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_ExitProcess")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mark(state.asm, l_ok_com)

  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.mov_rip_qword_rax(state.asm, "heap_ptr")

  // heap_end = base + commit
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.mov_rax_imm64(state.asm, commit_bytes)
  state.asm = a.add_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.mov_rip_qword_rdx(state.asm, "heap_end")

  // heap_min_end = base + shrink_min_bytes
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.mov_rax_imm64(state.asm, shrink_min_bytes)
  state.asm = a.add_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.mov_rip_qword_rdx(state.asm, "heap_min_end")

  // heap_reserve_end = base + reserve
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.mov_rax_imm64(state.asm, reserve_bytes)
  state.asm = a.add_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.mov_rip_qword_rdx(state.asm, "heap_reserve_end")

  state.asm = a.mov_rax_imm64(state.asm, commit_bytes)
  state.asm = a.mov_rip_qword_rax(state.asm, "heap_commit_bytes")
  state.asm = a.mov_rax_imm64(state.asm, reserve_bytes)
  state.asm = a.mov_rip_qword_rax(state.asm, "heap_reserve_bytes")

  bitmap_reserve_bytes = _mark_bitmap_bytes_for_heap_bytes(reserve_bytes)
  bitmap_commit_bytes = _mark_bitmap_bytes_for_heap_bytes(commit_bytes)
  bitmap_reserve_bytes = t.align_up(bitmap_reserve_bytes, MEM_RESERVE_GRANULARITY)
  bitmap_commit_bytes = t.align_up(bitmap_commit_bytes, MEM_PAGE_SIZE)

  // Reserve the GC mark bitmap alongside the heap.
  state.asm = a.xor_ecx_ecx(state.asm)
  state.asm = a.mov_rax_imm64(state.asm, bitmap_reserve_bytes)
  state.asm = a.mov_rdx_rax(state.asm)
  state.asm = a.mov_r8d_imm32(state.asm, 0x2000)
  state.asm = a.mov_r9d_imm32(state.asm, 0x04)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_VirtualAlloc")
  state.asm = a.call_rax(state.asm)
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  lbl_ok_bm_res = "heap_bm_res_ok_" + state.label_id
  state.label_id = state.label_id + 1
  state.asm = a.jcc(state.asm, "ne", lbl_ok_bm_res)
  state.asm = a.mov_rcx_imm32(state.asm, 1)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_ExitProcess")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mark(state.asm, lbl_ok_bm_res)

  state.asm = a.mov_rip_qword_rax(state.asm, "gc_mark_bits_base")

  state.asm = a.mov_rax_rip_qword(state.asm, "gc_mark_bits_base")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_imm64(state.asm, bitmap_commit_bytes)
  state.asm = a.mov_rdx_rax(state.asm)
  state.asm = a.mov_r8d_imm32(state.asm, 0x1000)
  state.asm = a.mov_r9d_imm32(state.asm, 0x04)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_VirtualAlloc")
  state.asm = a.call_rax(state.asm)
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  lbl_ok_bm_com = "heap_bm_com_ok_" + state.label_id
  state.label_id = state.label_id + 1
  state.asm = a.jcc(state.asm, "ne", lbl_ok_bm_com)
  state.asm = a.mov_rcx_imm32(state.asm, 1)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_ExitProcess")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mark(state.asm, lbl_ok_bm_com)

  state.asm = a.mov_rax_rip_qword(state.asm, "gc_mark_bits_base")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.mov_rax_imm64(state.asm, bitmap_commit_bytes)
  state.asm = a.add_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.mov_rip_qword_rdx(state.asm, "gc_mark_bits_end")

  state.asm = a.mov_rax_rip_qword(state.asm, "gc_mark_bits_base")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.mov_rax_imm64(state.asm, bitmap_reserve_bytes)
  state.asm = a.add_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.mov_rip_qword_rdx(state.asm, "gc_mark_bits_reserve_end")

  return state
end function

function emit_gc_init_globals(state, disable_periodic)
  state = ensure_gc_data(state)

  state.asm = a.mov_rax_imm64(state.asm, 0)
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_roots_head")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_free_head")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_mark_top")

  if disable_periodic then
    state.asm = a.mov_rax_imm64(state.asm, 0)
    state.asm = a.mov_rip_qword_rax(state.asm, "gc_bytes_since")
    state = _emit_mov_rax_i64_max(state)
    state.asm = a.mov_rip_qword_rax(state.asm, "gc_bytes_limit")
    state.asm = a.mov_rax_imm64(state.asm, 0)
    state.asm = a.mov_rip_qword_rax(state.asm, "gc_young_bytes_since")
    state = _emit_mov_rax_i64_max(state)
    state.asm = a.mov_rip_qword_rax(state.asm, "gc_young_bytes_limit")
  end if

  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  for i = 0 to 7
    state.asm = a.mov_rip_qword_rax(state.asm, "gc_tmp" + i)
  end for

  return state
end function

function emit_gc_clear_root_slots(state, root_base, root_top)
  root_count = (root_top - root_base) / 8
  if root_count <= 0 then return state end if

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_loop = "gcclr_loop_" + lid

  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x00, "rcx")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x08, "rdx")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x10, "r8")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x18, "r9")
  state.asm = a.mov_r64_r64(state.asm, "r11", "r10")
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.lea_r64_membase_disp(state.asm, "r10", "rsp", root_base)
  state.asm = a.mov_r32_imm32(state.asm, "ecx", root_count)
  state.asm = a.mark(state.asm, l_loop)
  state.asm = a.mov_membase_disp_r64(state.asm, "r10", 0, "rax")
  state.asm = a.add_r64_imm(state.asm, "r10", 8)
  state.asm = a.dec_r32(state.asm, "ecx")
  state.asm = a.jcc(state.asm, "ne", l_loop)
  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x00)
  state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", 0x08)
  state.asm = a.mov_r64_membase_disp(state.asm, "r8", "rsp", 0x10)
  state.asm = a.mov_r64_membase_disp(state.asm, "r9", "rsp", 0x18)
  state.asm = a.mov_r64_r64(state.asm, "r10", "r11")
  return state
end function

function emit_gc_push_root_frame(state, root_rec_off, root_base, root_top)
  state = ensure_gc_data(state)
  root_count = (root_top - root_base) >> 3

  state.asm = a.mov_rax_rip_qword(state.asm, "gc_roots_head")
  state.asm = a.mov_rsp_disp32_rax(state.asm, root_rec_off + 0)

  state.asm = a.lea_r64_membase_disp(state.asm, "rax", "rsp", root_base)
  state.asm = a.mov_rsp_disp32_rax(state.asm, root_rec_off + 8)

  state.asm = a.mov_rax_imm64(state.asm, root_count)
  state.asm = a.mov_rsp_disp32_rax(state.asm, root_rec_off + 16)

  state.asm = a.lea_r64_membase_disp(state.asm, "rax", "rsp", root_rec_off)
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_roots_head")
  return state
end function

function emit_gc_pop_root_frame(state, root_rec_off)
  state = ensure_gc_data(state)
  state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rsp", root_rec_off + 0)
  state.asm = a.mov_rip_qword_rdx(state.asm, "gc_roots_head")
  return state
end function

function emit_alloc_function(state)
  state = ensure_gc_data(state)

  rb = state.rdata
  rb = _ensure_rdata_str(rb, "oom_hdr", "ERROR: out of memory (MiniLang heap exhausted)\n")
  rb = _ensure_rdata_str(rb, "oom_requested", "requested=")
  rb = _ensure_rdata_str(rb, "oom_reserved", "reserved=")
  rb = _ensure_rdata_str(rb, "oom_committed", "committed=")
  rb = _ensure_rdata_str(rb, "oom_used", "used=")
  rb = _ensure_rdata_str(rb, "oom_nl", "\n")
  state.rdata = rb
  oom_hdr_len = _rlabel_len(rb.labels, "oom_hdr")
  oom_requested_len = _rlabel_len(rb.labels, "oom_requested")
  oom_reserved_len = _rlabel_len(rb.labels, "oom_reserved")
  oom_committed_len = _rlabel_len(rb.labels, "oom_committed")
  oom_used_len = _rlabel_len(rb.labels, "oom_used")
  oom_nl_len = _rlabel_len(rb.labels, "oom_nl")

  state.asm = a.mark(state.asm, "fn_alloc")

  state.asm = a.sub_rsp_imm8(state.asm, 0x48)

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.mov_rsp_disp32_rax(state.asm, 0x38)

  lid_fix = state.label_id
  state.label_id = state.label_id + 1
  l_fix_ok = "alloc_heap_ok_" + lid_fix
  l_fix_do = "alloc_heap_fix_" + lid_fix
  l_fix_done = "alloc_heap_fix_done_" + lid_fix
  l_fix_res_ok = "alloc_heap_fix_res_ok_" + lid_fix
  l_fix_end_ok = "alloc_heap_fix_end_ok_" + lid_fix
  l_fix_ptr_ok = "alloc_heap_fix_ptr_ok_" + lid_fix
  l_fix_commit_nonzero = "alloc_heap_fix_commit_nonzero_" + lid_fix
  l_fix_commit_default = "alloc_heap_fix_commit_default_" + lid_fix
  l_fix_commit_ok = "alloc_heap_fix_commit_ok_" + lid_fix
  l_fix_ptr_ge_base = "alloc_heap_fix_ptr_ge_base_" + lid_fix
  l_fix_ptr_le_end = "alloc_heap_fix_ptr_le_end_" + lid_fix

  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_reserve_end")
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")

  state.asm = a.cmp_r64_r64(state.asm, "r11", "r10")
  state.asm = a.jcc(state.asm, "a", l_fix_res_ok)
  state.asm = a.jmp(state.asm, l_fix_do)
  state.asm = a.mark(state.asm, l_fix_res_ok)

  state.asm = a.mov_rax_rip_qword(state.asm, "heap_end")
  state.asm = a.cmp_r64_r64(state.asm, "rax", "r10")
  state.asm = a.jcc(state.asm, "ae", l_fix_end_ok)
  state.asm = a.jmp(state.asm, l_fix_do)
  state.asm = a.mark(state.asm, l_fix_end_ok)

  state.asm = a.cmp_r64_r64(state.asm, "rax", "r11")
  state.asm = a.jcc(state.asm, "be", l_fix_ptr_ok)
  state.asm = a.jmp(state.asm, l_fix_do)

  state.asm = a.mark(state.asm, l_fix_ptr_ok)
  state.asm = a.mov_rdx_rip_qword(state.asm, "heap_ptr")
  state.asm = a.cmp_r64_r64(state.asm, "rdx", "r10")
  state.asm = a.jcc(state.asm, "ae", l_fix_ok)
  state.asm = a.jmp(state.asm, l_fix_do)

  state.asm = a.mark(state.asm, l_fix_ok)
  state.asm = a.cmp_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.jcc(state.asm, "be", l_fix_done)

  state.asm = a.mark(state.asm, l_fix_do)
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_reserve_bytes")
  state.asm = a.add_r64_r64(state.asm, "rax", "r10")
  state.asm = a.mov_rip_qword_rax(state.asm, "heap_reserve_end")
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")

  state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")
  state.asm = a.sub_r64_r64(state.asm, "rdx", "r10")

  state.asm = a.mov_rax_rip_qword(state.asm, "heap_commit_bytes")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "nz", l_fix_commit_nonzero)
  state.asm = a.jmp(state.asm, l_fix_commit_default)
  state.asm = a.mark(state.asm, l_fix_commit_nonzero)

  state.asm = a.cmp_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.jcc(state.asm, "be", l_fix_commit_ok)

  state.asm = a.mark(state.asm, l_fix_commit_default)
  state.asm = a.mov_rax_imm64(state.asm, HEAP_COMMIT_DEFAULT)
  state.asm = a.cmp_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.jcc(state.asm, "be", l_fix_commit_ok)
  state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")

  state.asm = a.mark(state.asm, l_fix_commit_ok)
  state.asm = a.add_r64_r64(state.asm, "rax", "r10")
  state.asm = a.mov_rip_qword_rax(state.asm, "heap_end")

  state.asm = a.mov_rdx_rip_qword(state.asm, "heap_ptr")
  state.asm = a.cmp_r64_r64(state.asm, "rdx", "r10")
  state.asm = a.jcc(state.asm, "ae", l_fix_ptr_ge_base)
  state.asm = a.mov_r64_r64(state.asm, "rdx", "r10")
  state.asm = a.mark(state.asm, l_fix_ptr_ge_base)
  state.asm = a.cmp_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.jcc(state.asm, "be", l_fix_ptr_le_end)
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.mark(state.asm, l_fix_ptr_le_end)
  state.asm = a.mov_rip_qword_rdx(state.asm, "heap_ptr")

  state.asm = a.mov_r64_r64(state.asm, "rcx", "r10")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.sub_r64_r64(state.asm, "rdx", "r10")
  state.asm = a.mov_r8d_imm32(state.asm, 0x1000)
  state.asm = a.mov_r9d_imm32(state.asm, 0x04)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_VirtualAlloc")
  state.asm = a.call_rax(state.asm)
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "ne", l_fix_done)
  state.asm = a.mov_rcx_imm32(state.asm, 1)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_ExitProcess")
  state.asm = a.call_rax(state.asm)

  state.asm = a.mark(state.asm, l_fix_done)

  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x38)
  state.asm = a.add_rcx_imm8(state.asm, c.GC_HEADER_SIZE)
  state.asm = a.add_rcx_imm8(state.asm, 7)
  state.asm = a.and_r64_imm(state.asm, "rcx", -8)

  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.mov_rsp_disp32_rax(state.asm, 0x20)
  state.asm = a.mov_rax_imm64(state.asm, 0)
  state.asm = a.mov_rsp_disp32_rax(state.asm, 0x30)
  state.asm = a.mov_rax_imm64(state.asm, 0)
  state.asm = a.mov_rsp_disp32_rax(state.asm, 0x40)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_retry = "alloc_retry_" + lid
  l_periodic_done = "alloc_periodic_done_" + lid
  l_young_skip = "alloc_young_skip_" + lid
  l_try_free = "alloc_try_free_" + lid
  l_free_loop = "alloc_free_loop_" + lid
  l_free_advance = "alloc_free_adv_" + lid
  l_free_found = "alloc_free_found_" + lid
  l_free_head = "alloc_free_head_" + lid
  l_free_unlinked = "alloc_free_unlinked_" + lid
  l_free_nosplit = "alloc_free_nosplit_" + lid
  l_bump = "alloc_bump_" + lid
  l_grow = "alloc_grow_" + lid
  l_ok = "alloc_ok_" + lid
  l_oom = "alloc_oom_" + lid
  l_do_grow = "alloc_do_grow_" + lid
  l_free_return = "alloc_free_return_" + lid

  state.asm = a.mark(state.asm, l_retry)
  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x20)

  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x40)
  state.asm = a.test_r64_r64(state.asm, "r11", "r11")
  state.asm = a.jcc(state.asm, "nz", l_periodic_done)

  state.asm = a.mov_rax_rip_qword(state.asm, "gc_bytes_since")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.add_r64_r64(state.asm, "rdx", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_bytes_since")

  state.asm = a.cmp_r64_imm(state.asm, "rcx", GC_YOUNG_OBJECT_MAX_BYTES)
  state.asm = a.jcc(state.asm, "a", l_young_skip)
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_young_bytes_since")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.add_r64_r64(state.asm, "r10", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_young_bytes_since")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_young_bytes_limit")
  state.asm = a.cmp_r64_r64(state.asm, "r10", "rax")
  state.asm = a.jcc(state.asm, "b", l_young_skip)
  state.asm = a.call(state.asm, "fn_gc_collect")
  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x20)
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_bytes_since")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.mark(state.asm, l_young_skip)

  state.asm = a.mov_rax_rip_qword(state.asm, "gc_bytes_limit")
  state.asm = a.cmp_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.jcc(state.asm, "b", l_periodic_done)
  state.asm = a.call(state.asm, "fn_gc_collect")

  state.asm = a.mark(state.asm, l_periodic_done)
  state.asm = a.mov_rax_imm64(state.asm, 1)
  state.asm = a.mov_rsp_disp32_rax(state.asm, 0x40)

  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x20)
  state.asm = a.mark(state.asm, l_try_free)

  state.asm = a.mov_rax_rip_qword(state.asm, "gc_free_head")
  state.asm = a.mov_r64_r64(state.asm, "r8", "rax")
  state.asm = a.mov_rax_imm64(state.asm, 0)
  state.asm = a.mov_rsp_disp32_rax(state.asm, 0x28)

  state.asm = a.mark(state.asm, l_free_loop)
  state.asm = a.test_r64_r64(state.asm, "r8", "r8")
  state.asm = a.jcc(state.asm, "z", l_bump)

  state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "r8", 0)
  state.asm = a.and_r64_imm(state.asm, "rdx", c.GC_BLOCK_SIZE_MASK)
  state.asm = a.cmp_r64_r64(state.asm, "rdx", "rcx")
  state.asm = a.jcc(state.asm, "b", l_free_advance)
  state.asm = a.jmp(state.asm, l_free_found)

  state.asm = a.mark(state.asm, l_free_advance)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.mov_rsp_disp32_rax(state.asm, 0x28)
  state.asm = a.mov_r64_membase_disp(state.asm, "r8", "r8", c.GC_OFF_NEXT_FREE)
  state.asm = a.jmp(state.asm, l_free_loop)

  state.asm = a.mark(state.asm, l_free_found)
  state.asm = a.mov_r64_membase_disp(state.asm, "r9", "r8", c.GC_OFF_NEXT_FREE)
  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x28)
  state.asm = a.test_r64_r64(state.asm, "r10", "r10")
  state.asm = a.jcc(state.asm, "z", l_free_head)
  state.asm = a.mov_membase_disp_r64(state.asm, "r10", c.GC_OFF_NEXT_FREE, "r9")
  state.asm = a.jmp(state.asm, l_free_unlinked)

  state.asm = a.mark(state.asm, l_free_head)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r9")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_free_head")

  state.asm = a.mark(state.asm, l_free_unlinked)
  state.asm = a.mov_r64_r64(state.asm, "r11", "rdx")
  state.asm = a.sub_r64_r64(state.asm, "r11", "rcx")
  state.asm = a.cmp_r64_imm(state.asm, "r11", ALLOC_MIN_SPLIT)
  state.asm = a.jcc(state.asm, "b", l_free_nosplit)

  state.asm = a.mov_r64_r64(state.asm, "rdx", "r8")
  state.asm = a.add_r64_r64(state.asm, "rdx", "rcx")

  state.asm = a.or_r64_imm(state.asm, "r11", c.GC_BLOCK_FREE_BIT)
  state.asm = a.mov_membase_disp_r64(state.asm, "rdx", 0, "r11")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_free_head")
  state.asm = a.mov_membase_disp_r64(state.asm, "rdx", c.GC_OFF_NEXT_FREE, "rax")
  state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_free_head")
  state.asm = a.mov_membase_disp_r64(state.asm, "r8", 0, "rcx")

  state.asm = a.jmp(state.asm, l_free_return)

  state.asm = a.mark(state.asm, l_free_nosplit)
  state.asm = a.mov_membase_disp_r64(state.asm, "r8", 0, "rdx")
  state.asm = a.mark(state.asm, l_free_return)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.add_rax_imm8(state.asm, c.GC_HEADER_SIZE)
  state.asm = a.add_rsp_imm8(state.asm, 0x48)
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, l_bump)
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_ptr")
  state.asm = a.mov_rdx_rax(state.asm)

  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.add_r64_r64(state.asm, "r10", "rcx")

  state.asm = a.mov_rax_rip_qword(state.asm, "heap_end")
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
  state.asm = a.cmp_r64_r64(state.asm, "r10", "r11")
  state.asm = a.jcc(state.asm, "be", l_ok)

  state.asm = a.mark(state.asm, l_grow)
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x30)
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "nz", l_do_grow)

  state.asm = a.mov_rax_imm64(state.asm, 1)
  state.asm = a.mov_rsp_disp32_rax(state.asm, 0x30)
  state.asm = a.call(state.asm, "fn_gc_collect")
  state.asm = a.jmp(state.asm, l_retry)

  state.asm = a.mark(state.asm, l_do_grow)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "r10")
  state.asm = a.call(state.asm, "fn_heap_grow")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "nz", l_retry)
  state.asm = a.jmp(state.asm, l_oom)

  state.asm = a.mov_rax_imm64(state.asm, 1)
  state.asm = a.mov_rsp_disp32_rax(state.asm, 0x30)
  state.asm = a.call(state.asm, "fn_gc_collect")
  state.asm = a.jmp(state.asm, l_retry)

  state.asm = a.mark(state.asm, l_oom)
  state.asm = a.mov_rcx_imm32(state.asm, -12)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_GetStdHandle")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_rsp_disp32_rax(state.asm, 0x40)

  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x40)
  state.asm = a.lea_rdx_rip(state.asm, "oom_hdr")
  state.asm = a.mov_r8d_imm32(state.asm, oom_hdr_len)
  state.asm = a.lea_r64_membase_disp(state.asm, "r9", "rsp", 0x30)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WriteFile")
  state.asm = a.call_rax(state.asm)

  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x40)
  state.asm = a.lea_rdx_rip(state.asm, "oom_requested")
  state.asm = a.mov_r8d_imm32(state.asm, oom_requested_len)
  state.asm = a.lea_r64_membase_disp(state.asm, "r9", "rsp", 0x30)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WriteFile")
  state.asm = a.call_rax(state.asm)

  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x38)
  state.asm = a.shl_r64_imm8(state.asm, "rax", 3)
  state.asm = a.or_r64_imm(state.asm, "rax", 1)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.call(state.asm, "fn_int_to_dec")
  state.asm = a.mov_r8d_edx(state.asm)
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x40)
  state.asm = a.lea_r64_membase_disp(state.asm, "r9", "rsp", 0x30)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WriteFile")
  state.asm = a.call_rax(state.asm)

  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x40)
  state.asm = a.lea_rdx_rip(state.asm, "oom_nl")
  state.asm = a.mov_r8d_imm32(state.asm, oom_nl_len)
  state.asm = a.lea_r64_membase_disp(state.asm, "r9", "rsp", 0x30)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WriteFile")
  state.asm = a.call_rax(state.asm)

  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x40)
  state.asm = a.lea_rdx_rip(state.asm, "oom_reserved")
  state.asm = a.mov_r8d_imm32(state.asm, oom_reserved_len)
  state.asm = a.lea_r64_membase_disp(state.asm, "r9", "rsp", 0x30)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WriteFile")
  state.asm = a.call_rax(state.asm)

  state.asm = a.call(state.asm, "fn_heap_bytes_reserved")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.call(state.asm, "fn_int_to_dec")
  state.asm = a.mov_r8d_edx(state.asm)
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x40)
  state.asm = a.lea_r64_membase_disp(state.asm, "r9", "rsp", 0x30)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WriteFile")
  state.asm = a.call_rax(state.asm)

  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x40)
  state.asm = a.lea_rdx_rip(state.asm, "oom_nl")
  state.asm = a.mov_r8d_imm32(state.asm, oom_nl_len)
  state.asm = a.lea_r64_membase_disp(state.asm, "r9", "rsp", 0x30)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WriteFile")
  state.asm = a.call_rax(state.asm)

  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x40)
  state.asm = a.lea_rdx_rip(state.asm, "oom_committed")
  state.asm = a.mov_r8d_imm32(state.asm, oom_committed_len)
  state.asm = a.lea_r64_membase_disp(state.asm, "r9", "rsp", 0x30)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WriteFile")
  state.asm = a.call_rax(state.asm)

  state.asm = a.call(state.asm, "fn_heap_bytes_committed")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.call(state.asm, "fn_int_to_dec")
  state.asm = a.mov_r8d_edx(state.asm)
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x40)
  state.asm = a.lea_r64_membase_disp(state.asm, "r9", "rsp", 0x30)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WriteFile")
  state.asm = a.call_rax(state.asm)

  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x40)
  state.asm = a.lea_rdx_rip(state.asm, "oom_nl")
  state.asm = a.mov_r8d_imm32(state.asm, oom_nl_len)
  state.asm = a.lea_r64_membase_disp(state.asm, "r9", "rsp", 0x30)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WriteFile")
  state.asm = a.call_rax(state.asm)

  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x40)
  state.asm = a.lea_rdx_rip(state.asm, "oom_used")
  state.asm = a.mov_r8d_imm32(state.asm, oom_used_len)
  state.asm = a.lea_r64_membase_disp(state.asm, "r9", "rsp", 0x30)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WriteFile")
  state.asm = a.call_rax(state.asm)

  state.asm = a.call(state.asm, "fn_heap_bytes_used")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.call(state.asm, "fn_int_to_dec")
  state.asm = a.mov_r8d_edx(state.asm)
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x40)
  state.asm = a.lea_r64_membase_disp(state.asm, "r9", "rsp", 0x30)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WriteFile")
  state.asm = a.call_rax(state.asm)

  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rsp", 0x40)
  state.asm = a.lea_rdx_rip(state.asm, "oom_nl")
  state.asm = a.mov_r8d_imm32(state.asm, oom_nl_len)
  state.asm = a.lea_r64_membase_disp(state.asm, "r9", "rsp", 0x30)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WriteFile")
  state.asm = a.call_rax(state.asm)

  state.asm = a.mov_rcx_imm32(state.asm, 1)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_ExitProcess")
  state.asm = a.call_rax(state.asm)

  state.asm = a.mark(state.asm, l_ok)
  state.asm = a.mov_rax_r10(state.asm)
  state.asm = a.mov_rip_qword_rax(state.asm, "heap_ptr")

  state.asm = a.mov_membase_disp_r64(state.asm, "rdx", 0, "rcx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "rdx")
  state.asm = a.add_rax_imm8(state.asm, c.GC_HEADER_SIZE)
  state.asm = a.add_rsp_imm8(state.asm, 0x48)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_gc_collect_function(state)
  state = ensure_gc_data(state)
  if typeof(state.rdata) == "struct" then
    state.rdata = _ensure_rdata_str(state.rdata, "gc_ms_overflow", "ERROR: GC mark stack overflow\n")
  end if
  state.asm = a.mark(state.asm, "fn_gc_collect")

  // Preserve non-volatile regs used by collector.
  state.asm = a.push_rbx(state.asm)
  state.asm = a.push_rbp(state.asm)
  state.asm = a.push_reg(state.asm, "rsi")
  state.asm = a.push_r12(state.asm)
  state.asm = a.push_r13(state.asm)
  state.asm = a.push_r14(state.asm)
  state.asm = a.push_r15(state.asm)
  state.asm = a.push_reg(state.asm, "rdi")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  L_MARK_VALUE = "gc_mark_value_" + lid
  L_MARK_VALUE_RET = "gc_mark_value_ret_" + lid
  L_BODY = "gc_body_" + lid
  L_MARK_LOOP = "gc_mark_loop_" + lid
  L_MARK_DONE = "gc_mark_done_" + lid
  L_SCAN_ARRAY = "gc_scan_array_" + lid
  L_SCAN_ARRAY_LOOP = "gc_scan_array_loop_" + lid
  L_SCAN_ARRAY_DONE = "gc_scan_array_done_" + lid
  L_SCAN_STRUCT = "gc_scan_struct_" + lid
  L_SCAN_STRUCT_LOOP = "gc_scan_struct_loop_" + lid
  L_SCAN_STRUCT_DONE = "gc_scan_struct_done_" + lid
  L_SCAN_FUNCTION = "gc_scan_function_" + lid
  L_SCAN_ENV = "gc_scan_env_" + lid
  L_SCAN_ENV_LOCAL = "gc_scan_env_local_" + lid
  L_SCAN_ENV_LOOP = "gc_scan_env_loop_" + lid
  L_SCAN_ENV_DONE = "gc_scan_env_done_" + lid
  L_SCAN_BOX = "gc_scan_box_" + lid
  L_MS_OVERFLOW = "gc_mark_stack_overflow_" + lid
  L_ROOT_FRAMES = "gc_root_frames_" + lid
  L_ROOT_FRAME_LOOP = "gc_root_frame_loop_" + lid
  L_ROOT_FRAME_SLOTS = "gc_root_frame_slots_" + lid
  L_ROOT_FRAME_SLOTS_LOOP = "gc_root_frame_slots_loop_" + lid
  L_ROOT_FRAME_NEXT = "gc_root_frame_next_" + lid
  L_SWEEP_LOOP = "gc_sweep_loop_" + lid
  L_SWEEP_LIVE = "gc_sweep_live_" + lid
  L_SWEEP_DEAD = "gc_sweep_dead_" + lid
  L_SWEEP_DONE = "gc_sweep_done_" + lid
  L_REBUILD_LOOP = "gc_rebuild_loop_" + lid
  L_REBUILD_LIVE = "gc_rebuild_live_" + lid
  L_REBUILD_NEXT = "gc_rebuild_next_" + lid
  L_REBUILD_DONE = "gc_rebuild_done_" + lid
  L_REBUILD2_LOOP = "gc_rebuild2_loop_" + lid
  L_REBUILD2_LIVE = "gc_rebuild2_live_" + lid
  L_REBUILD2_NEXT = "gc_rebuild2_next_" + lid
  L_REBUILD2_DONE = "gc_rebuild2_done_" + lid
  L_REBUILD2_AFTER = "gc_rebuild2_after_" + lid
  L_COAL_LOOP = "gc_coal_loop_" + lid
  L_COAL_DONE = "gc_coal_done_" + lid
  L_COAL2_LOOP = "gc_coal2_loop_" + lid
  L_COAL2_DONE = "gc_coal2_done_" + lid

  // r12 = &gc_mark_stack
  state.asm = a.lea_rax_rip(state.asm, "gc_mark_stack")
  state.asm = a.mov_r64_r64(state.asm, "r12", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.mov_r64_r64(state.asm, "rbp", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_mark_bits_base")
  state.asm = a.mov_r64_r64(state.asm, "rsi", "rax")
  state.asm = a.mov_rax_imm64(state.asm, 0)
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_mark_top")

  // Jump over local helper body.
  state.asm = a.jmp(state.asm, L_BODY)

  // local helper: mark tagged value in RAX
  state.asm = a.mark(state.asm, L_MARK_VALUE)
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.and_r64_imm(state.asm, "rdx", 7)
  state.asm = a.test_r64_r64(state.asm, "rdx", "rdx")
  state.asm = a.jcc(state.asm, "ne", L_MARK_VALUE_RET)

  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "r11")

  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.add_r64_imm(state.asm, "rax", c.GC_HEADER_SIZE)
  state.asm = a.cmp_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.jcc(state.asm, "b", L_MARK_VALUE_RET)

  state.asm = a.mov_rax_rip_qword(state.asm, "heap_end")
  state.asm = a.cmp_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.jcc(state.asm, "ae", L_MARK_VALUE_RET)

  state.asm = a.sub_r64_imm(state.asm, "rdx", c.GC_HEADER_SIZE)
  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rdx", 0)
  state.asm = a.test_r64_imm32(state.asm, "r10", c.GC_BLOCK_FREE_BIT)
  state.asm = a.jcc(state.asm, "ne", L_MARK_VALUE_RET)

  state.asm = a.mov_r64_r64(state.asm, "r8", "r10")
  state.asm = a.and_r64_imm(state.asm, "r8", c.GC_BLOCK_SIZE_MASK)
  state.asm = a.cmp_r64_imm(state.asm, "r8", c.GC_HEADER_SIZE + 8)
  state.asm = a.jcc(state.asm, "b", L_MARK_VALUE_RET)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rdx")
  state.asm = a.add_r64_r64(state.asm, "rcx", "r8")
  state.asm = a.cmp_r64_r64(state.asm, "rcx", "rdx")
  state.asm = a.jcc(state.asm, "b", L_MARK_VALUE_RET)
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_end")
  state.asm = a.cmp_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.jcc(state.asm, "a", L_MARK_VALUE_RET)

  state.asm = a.mov_r64_r64(state.asm, "r8", "rdx")
  state.asm = a.sub_r64_r64(state.asm, "r8", "rbp")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "r8")
  state.asm = a.shr_r64_imm8(state.asm, "r8", 6)
  state.asm = a.shr_r64_imm8(state.asm, "rcx", 3)
  state.asm = a.and_r64_imm(state.asm, "rcx", 7)
  state.asm = a.mov_rax_imm64(state.asm, 1)
  state.asm = a.shl_r64_cl(state.asm, "rax")
  state.asm = a.mov_r64_r64(state.asm, "r9", "rsi")
  state.asm = a.add_r64_r64(state.asm, "r9", "r8")
  state.asm = a.mov_r8_membase_disp(state.asm, "r10b", "r9", 0)
  state.asm = a.test_r8_r8(state.asm, "r10b", "al")
  state.asm = a.jcc(state.asm, "ne", L_MARK_VALUE_RET)
  state.asm = a.or_r8_r8(state.asm, "r10b", "al")
  state.asm = a.mov_membase_disp_r8(state.asm, "r9", 0, "r10b")

  state.asm = a.mov_rax_rip_qword(state.asm, "gc_mark_top")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.cmp_r64_imm(state.asm, "r10", GC_MARK_STACK_QWORDS)
  state.asm = a.jcc(state.asm, "ae", L_MS_OVERFLOW)

  state.asm = a.mov_mem_bis_r64(state.asm, "r12", "r10", 8, 0, "r11")
  state.asm = a.inc_r64(state.asm, "r10")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_mark_top")

  state.asm = a.mark(state.asm, L_MARK_VALUE_RET)
  state.asm = a.ret(state.asm)

  state.asm = a.mark(state.asm, L_MS_OVERFLOW)
  if typeof(state.rdata) == "struct" then
    ln = _rlabel_len(state.rdata.labels, "gc_ms_overflow")
    state.asm = a.mov_rcx_imm32(state.asm, -12)
    state.asm = a.mov_rax_rip_qword(state.asm, "iat_GetStdHandle")
    state.asm = a.call_rax(state.asm)
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.lea_rdx_rip(state.asm, "gc_ms_overflow")
    state.asm = a.mov_r8d_imm32(state.asm, ln)
    state.asm = a.lea_r64_membase_disp(state.asm, "r9", "rsp", 0x28)
    state.asm = a.mov_membase_disp_imm32(state.asm, "rsp", 0x20, 0, true)
    state.asm = a.mov_rax_rip_qword(state.asm, "iat_WriteFile")
    state.asm = a.call_rax(state.asm)
  end if
  state.asm = a.mov_rcx_imm32(state.asm, 1)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_ExitProcess")
  state.asm = a.call_rax(state.asm)

  state.asm = a.mark(state.asm, L_BODY)

  // Roots: gc_tmp0..gc_tmp7
  for i = 0 to 7
    state.asm = a.mov_rax_rip_qword(state.asm, "gc_tmp" + i)
    state.asm = a.call(state.asm, L_MARK_VALUE)
  end for

  // Roots: global slots
  if typeof(state.global_slots) == "array" and len(state.global_slots) > 0 then
    for gi = 0 to len(state.global_slots) - 1
      glb = state.global_slots[gi]
      if typeof(glb) != "string" or glb == "" then continue end if
      state.asm = a.mov_rax_rip_qword(state.asm, glb)
      state.asm = a.call(state.asm, L_MARK_VALUE)
    end for
  end if

  // Roots: shadow stack frames
  state.asm = a.mark(state.asm, L_ROOT_FRAMES)
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_roots_head")
  state.asm = a.mov_r64_r64(state.asm, "r13", "rax")
  state.asm = a.mark(state.asm, L_ROOT_FRAME_LOOP)
  state.asm = a.test_r64_r64(state.asm, "r13", "r13")
  state.asm = a.jcc(state.asm, "e", L_MARK_LOOP)

  state.asm = a.mov_r64_membase_disp(state.asm, "r14", "r13", 8)
  state.asm = a.mov_r64_membase_disp(state.asm, "r15", "r13", 16)

  state.asm = a.mark(state.asm, L_ROOT_FRAME_SLOTS)
  state.asm = a.mark(state.asm, L_ROOT_FRAME_SLOTS_LOOP)
  state.asm = a.test_r64_r64(state.asm, "r15", "r15")
  state.asm = a.jcc(state.asm, "e", L_ROOT_FRAME_NEXT)
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r14", 0)
  state.asm = a.call(state.asm, L_MARK_VALUE)
  state.asm = a.add_r64_imm(state.asm, "r14", 8)
  state.asm = a.dec_r64(state.asm, "r15")
  state.asm = a.jmp(state.asm, L_ROOT_FRAME_SLOTS_LOOP)

  state.asm = a.mark(state.asm, L_ROOT_FRAME_NEXT)
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r13", 0)
  state.asm = a.mov_r64_r64(state.asm, "r13", "rax")
  state.asm = a.jmp(state.asm, L_ROOT_FRAME_LOOP)

  // mark loop
  state.asm = a.mark(state.asm, L_MARK_LOOP)
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_mark_top")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.test_r64_r64(state.asm, "r10", "r10")
  state.asm = a.jcc(state.asm, "e", L_MARK_DONE)

  state.asm = a.dec_r64(state.asm, "r10")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_mark_top")
  state.asm = a.mov_r64_mem_bis(state.asm, "r11", "r12", "r10", 8, 0)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r11")

  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "ecx", c.OBJ_ARRAY)
  state.asm = a.jcc(state.asm, "e", L_SCAN_ARRAY)
  state.asm = a.cmp_r32_imm(state.asm, "ecx", c.OBJ_ARRAY_IMM)
  state.asm = a.jcc(state.asm, "e", L_MARK_LOOP)
  state.asm = a.cmp_r32_imm(state.asm, "ecx", c.OBJ_STRUCT)
  state.asm = a.jcc(state.asm, "e", L_SCAN_STRUCT)
  state.asm = a.cmp_r32_imm(state.asm, "ecx", c.OBJ_FUNCTION)
  state.asm = a.jcc(state.asm, "e", L_MARK_LOOP)
  state.asm = a.cmp_r32_imm(state.asm, "ecx", c.OBJ_CLOSURE)
  state.asm = a.jcc(state.asm, "e", L_SCAN_FUNCTION)
  state.asm = a.cmp_r32_imm(state.asm, "ecx", c.OBJ_ENV)
  state.asm = a.jcc(state.asm, "e", L_SCAN_ENV)
  state.asm = a.cmp_r32_imm(state.asm, "ecx", c.OBJ_ENV_LOCAL)
  state.asm = a.jcc(state.asm, "e", L_SCAN_ENV_LOCAL)
  state.asm = a.cmp_r32_imm(state.asm, "ecx", c.OBJ_BOX)
  state.asm = a.jcc(state.asm, "e", L_SCAN_BOX)
  state.asm = a.jmp(state.asm, L_MARK_LOOP)

  state.asm = a.mark(state.asm, L_SCAN_ARRAY)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rax", 4)
  state.asm = a.lea_r64_membase_disp(state.asm, "rbx", "rax", 8)
  state.asm = a.mov_r32_r32(state.asm, "r14d", "edx")
  state.asm = a.xor_r32_r32(state.asm, "r13d", "r13d")
  state.asm = a.mark(state.asm, L_SCAN_ARRAY_LOOP)
  state.asm = a.cmp_r32_r32(state.asm, "r13d", "r14d")
  state.asm = a.jcc(state.asm, "ge", L_SCAN_ARRAY_DONE)
  state.asm = a.mov_r64_mem_bis(state.asm, "rax", "rbx", "r13", 8, 0)
  state.asm = a.call(state.asm, L_MARK_VALUE)
  state.asm = a.inc_r32(state.asm, "r13d")
  state.asm = a.jmp(state.asm, L_SCAN_ARRAY_LOOP)
  state.asm = a.mark(state.asm, L_SCAN_ARRAY_DONE)
  state.asm = a.jmp(state.asm, L_MARK_LOOP)

  state.asm = a.mark(state.asm, L_SCAN_STRUCT)
  state.asm = a.mov_r64_membase_disp(state.asm, "rdx", "rax", c.GC_OFF_BLOCK_SIZE)
  state.asm = a.and_r64_imm(state.asm, "rdx", c.GC_BLOCK_SIZE_MASK)
  state.asm = a.sub_r64_imm(state.asm, "rdx", c.GC_HEADER_SIZE + 8)
  state.asm = a.shr_r64_imm8(state.asm, "rdx", 3)
  state.asm = a.lea_r64_membase_disp(state.asm, "rbx", "rax", 8)
  state.asm = a.mov_r32_r32(state.asm, "r14d", "edx")
  state.asm = a.xor_r32_r32(state.asm, "r13d", "r13d")
  state.asm = a.mark(state.asm, L_SCAN_STRUCT_LOOP)
  state.asm = a.cmp_r32_r32(state.asm, "r13d", "r14d")
  state.asm = a.jcc(state.asm, "ge", L_SCAN_STRUCT_DONE)
  state.asm = a.mov_r64_mem_bis(state.asm, "rax", "rbx", "r13", 8, 0)
  state.asm = a.call(state.asm, L_MARK_VALUE)
  state.asm = a.inc_r32(state.asm, "r13d")
  state.asm = a.jmp(state.asm, L_SCAN_STRUCT_LOOP)
  state.asm = a.mark(state.asm, L_SCAN_STRUCT_DONE)
  state.asm = a.jmp(state.asm, L_MARK_LOOP)

  state.asm = a.mark(state.asm, L_SCAN_FUNCTION)
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r11", 16)
  state.asm = a.call(state.asm, L_MARK_VALUE)
  state.asm = a.jmp(state.asm, L_MARK_LOOP)

  state.asm = a.mark(state.asm, L_SCAN_ENV)
  state.asm = a.mov_r64_r64(state.asm, "rdi", "r11")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rdi", 8)
  state.asm = a.call(state.asm, L_MARK_VALUE)
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rdi", 4)
  state.asm = a.lea_r64_membase_disp(state.asm, "rbx", "rdi", 16)
  state.asm = a.mov_r32_r32(state.asm, "r14d", "edx")
  state.asm = a.xor_r32_r32(state.asm, "r13d", "r13d")
  state.asm = a.mark(state.asm, L_SCAN_ENV_LOOP)
  state.asm = a.cmp_r32_r32(state.asm, "r13d", "r14d")
  state.asm = a.jcc(state.asm, "ge", L_SCAN_ENV_DONE)
  state.asm = a.mov_r64_mem_bis(state.asm, "rax", "rbx", "r13", 8, 0)
  state.asm = a.call(state.asm, L_MARK_VALUE)
  state.asm = a.inc_r32(state.asm, "r13d")
  state.asm = a.jmp(state.asm, L_SCAN_ENV_LOOP)
  state.asm = a.mark(state.asm, L_SCAN_ENV_DONE)
  state.asm = a.jmp(state.asm, L_MARK_LOOP)

  state.asm = a.mark(state.asm, L_SCAN_ENV_LOCAL)
  state.asm = a.mov_r64_r64(state.asm, "rdi", "r11")
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rdi", 4)
  state.asm = a.lea_r64_membase_disp(state.asm, "rbx", "rdi", 8)
  state.asm = a.mov_r32_r32(state.asm, "r14d", "edx")
  state.asm = a.xor_r32_r32(state.asm, "r13d", "r13d")
  state.asm = a.jmp(state.asm, L_SCAN_ENV_LOOP)

  state.asm = a.mark(state.asm, L_SCAN_BOX)
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r11", 8)
  state.asm = a.call(state.asm, L_MARK_VALUE)
  state.asm = a.jmp(state.asm, L_MARK_LOOP)

  state.asm = a.mark(state.asm, L_MARK_DONE)

  // Sweep pass 1: keep bitmap marks intact and compute the new live heap end.
  state.asm = a.mov_rax_imm64(state.asm, 0)
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_free_head")
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.mov_r64_r64(state.asm, "rbx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_ptr")
  state.asm = a.mov_r64_r64(state.asm, "r14", "rax")
  state.asm = a.mov_r64_r64(state.asm, "r15", "rbx")

  state.asm = a.mark(state.asm, L_SWEEP_LOOP)
  state.asm = a.cmp_r64_r64(state.asm, "rbx", "r14")
  state.asm = a.jcc(state.asm, "ae", L_SWEEP_DONE)

  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rbx", 0)
  state.asm = a.test_r64_r64(state.asm, "r10", "r10")
  state.asm = a.jcc(state.asm, "e", L_SWEEP_DONE)
  state.asm = a.and_r64_imm(state.asm, "r10", c.GC_BLOCK_SIZE_MASK)

  state.asm = a.mov_r64_r64(state.asm, "r8", "rbx")
  state.asm = a.sub_r64_r64(state.asm, "r8", "rbp")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "r8")
  state.asm = a.shr_r64_imm8(state.asm, "r8", 6)
  state.asm = a.shr_r64_imm8(state.asm, "rcx", 3)
  state.asm = a.and_r64_imm(state.asm, "rcx", 7)
  state.asm = a.mov_rax_imm64(state.asm, 1)
  state.asm = a.shl_r64_cl(state.asm, "rax")
  state.asm = a.mov_r64_r64(state.asm, "r9", "rsi")
  state.asm = a.add_r64_r64(state.asm, "r9", "r8")
  state.asm = a.mov_r8_membase_disp(state.asm, "r8b", "r9", 0)
  state.asm = a.test_r8_r8(state.asm, "r8b", "al")
  state.asm = a.jcc(state.asm, "ne", L_SWEEP_LIVE)

  state.asm = a.add_r64_r64(state.asm, "rbx", "r10")
  state.asm = a.jmp(state.asm, L_SWEEP_LOOP)

  state.asm = a.mark(state.asm, L_SWEEP_LIVE)
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rbx")
  state.asm = a.add_r64_r64(state.asm, "rdx", "r10")
  state.asm = a.cmp_r64_r64(state.asm, "rdx", "r15")
  state.asm = a.jcc(state.asm, "be", L_SWEEP_DEAD)
  state.asm = a.mov_r64_r64(state.asm, "r15", "rdx")

  state.asm = a.mark(state.asm, L_SWEEP_DEAD)
  state.asm = a.add_r64_r64(state.asm, "rbx", "r10")
  state.asm = a.jmp(state.asm, L_SWEEP_LOOP)

  state.asm = a.mark(state.asm, L_SWEEP_DONE)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r15")
  state.asm = a.mov_rip_qword_rax(state.asm, "heap_ptr")

  // Sweep pass 2: rebuild free list from the side bitmap and clear live bits.
  state.asm = a.mov_rax_imm64(state.asm, 0)
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_free_head")
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.mov_r64_r64(state.asm, "rbx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_ptr")
  state.asm = a.mov_r64_r64(state.asm, "r14", "rax")

  state.asm = a.mark(state.asm, L_REBUILD2_LOOP)
  state.asm = a.cmp_r64_r64(state.asm, "rbx", "r14")
  state.asm = a.jcc(state.asm, "ae", L_REBUILD2_DONE)

  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rbx", 0)
  state.asm = a.test_r64_r64(state.asm, "r10", "r10")
  state.asm = a.jcc(state.asm, "e", L_REBUILD2_DONE)
  state.asm = a.and_r64_imm(state.asm, "r10", c.GC_BLOCK_SIZE_MASK)

  state.asm = a.mov_r64_r64(state.asm, "r8", "rbx")
  state.asm = a.sub_r64_r64(state.asm, "r8", "rbp")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "r8")
  state.asm = a.shr_r64_imm8(state.asm, "r8", 6)
  state.asm = a.shr_r64_imm8(state.asm, "rcx", 3)
  state.asm = a.and_r64_imm(state.asm, "rcx", 7)
  state.asm = a.mov_rax_imm64(state.asm, 1)
  state.asm = a.shl_r64_cl(state.asm, "rax")
  state.asm = a.mov_r64_r64(state.asm, "r9", "rsi")
  state.asm = a.add_r64_r64(state.asm, "r9", "r8")
  state.asm = a.mov_r8_membase_disp(state.asm, "r8b", "r9", 0)
  state.asm = a.test_r8_r8(state.asm, "r8b", "al")
  state.asm = a.jcc(state.asm, "ne", L_REBUILD2_LIVE)

  state.asm = a.mark(state.asm, L_COAL2_LOOP)
  state.asm = a.mov_r64_r64(state.asm, "r11", "rbx")
  state.asm = a.add_r64_r64(state.asm, "r11", "r10")
  state.asm = a.cmp_r64_r64(state.asm, "r11", "r14")
  state.asm = a.jcc(state.asm, "ae", L_COAL2_DONE)

  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "r11", 0)
  state.asm = a.test_r64_r64(state.asm, "rcx", "rcx")
  state.asm = a.jcc(state.asm, "e", L_COAL2_DONE)
  state.asm = a.and_r64_imm(state.asm, "rcx", c.GC_BLOCK_SIZE_MASK)

  state.asm = a.mov_r64_r64(state.asm, "r8", "r11")
  state.asm = a.sub_r64_r64(state.asm, "r8", "rbp")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "r8")
  state.asm = a.shr_r64_imm8(state.asm, "r8", 6)
  state.asm = a.shr_r64_imm8(state.asm, "rdx", 3)
  state.asm = a.and_r64_imm(state.asm, "rdx", 7)
  state.asm = a.mov_r64_imm64(state.asm, "rax", 1)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rdx")
  state.asm = a.shl_r64_cl(state.asm, "rax")
  state.asm = a.mov_r64_r64(state.asm, "r9", "rsi")
  state.asm = a.add_r64_r64(state.asm, "r9", "r8")
  state.asm = a.mov_r8_membase_disp(state.asm, "r8b", "r9", 0)
  state.asm = a.test_r8_r8(state.asm, "r8b", "al")
  state.asm = a.jcc(state.asm, "ne", L_COAL2_DONE)

  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "r11", 0)
  state.asm = a.and_r64_imm(state.asm, "rcx", c.GC_BLOCK_SIZE_MASK)
  state.asm = a.add_r64_r64(state.asm, "r10", "rcx")
  state.asm = a.jmp(state.asm, L_COAL2_LOOP)

  state.asm = a.mark(state.asm, L_COAL2_DONE)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.or_r64_imm(state.asm, "rax", c.GC_BLOCK_FREE_BIT)
  state.asm = a.mov_membase_disp_r64(state.asm, "rbx", 0, "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_free_head")
  state.asm = a.mov_membase_disp_r64(state.asm, "rbx", c.GC_OFF_NEXT_FREE, "rax")
  state.asm = a.mov_r64_r64(state.asm, "rax", "rbx")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_free_head")
  state.asm = a.jmp(state.asm, L_REBUILD2_NEXT)

  state.asm = a.mark(state.asm, L_REBUILD2_LIVE)
  state.asm = a.xor_r8_imm8(state.asm, "al", 0xFF)
  state.asm = a.and_r8_r8(state.asm, "r8b", "al")
  state.asm = a.mov_membase_disp_r8(state.asm, "r9", 0, "r8b")
  state.asm = a.mov_membase_disp_r64(state.asm, "rbx", 0, "r10")

  state.asm = a.mark(state.asm, L_REBUILD2_NEXT)
  state.asm = a.add_r64_r64(state.asm, "rbx", "r10")
  state.asm = a.jmp(state.asm, L_REBUILD2_LOOP)

  state.asm = a.mark(state.asm, L_REBUILD2_DONE)
  state.asm = a.jmp(state.asm, L_REBUILD2_AFTER)

  state.asm = a.mov_rax_imm64(state.asm, 0)
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_free_head")
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.mov_r64_r64(state.asm, "rbx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_ptr")
  state.asm = a.mov_r64_r64(state.asm, "r14", "rax")

  state.asm = a.mark(state.asm, L_REBUILD_LOOP)
  state.asm = a.cmp_r64_r64(state.asm, "rbx", "r14")
  state.asm = a.jcc(state.asm, "ae", L_REBUILD_DONE)

  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rbx", 0)
  state.asm = a.test_r64_r64(state.asm, "r10", "r10")
  state.asm = a.jcc(state.asm, "e", L_REBUILD_DONE)

  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "rbx", c.GC_HEADER_SIZE)
  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rdx", 0)
  state.asm = a.test_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.jcc(state.asm, "ne", L_REBUILD_NEXT)

  state.asm = a.mark(state.asm, L_COAL_LOOP)
  state.asm = a.mov_r64_r64(state.asm, "r11", "rbx")
  state.asm = a.add_r64_r64(state.asm, "r11", "r10")
  state.asm = a.cmp_r64_r64(state.asm, "r11", "r14")
  state.asm = a.jcc(state.asm, "ae", L_COAL_DONE)

  state.asm = a.lea_r64_membase_disp(state.asm, "rdx", "r11", c.GC_HEADER_SIZE)
  state.asm = a.mov_r32_membase_disp(state.asm, "ecx", "rdx", 0)
  state.asm = a.test_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.jcc(state.asm, "ne", L_COAL_DONE)

  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "r11", 0)
  state.asm = a.add_r64_r64(state.asm, "r10", "rcx")
  state.asm = a.mov_membase_disp_r64(state.asm, "rbx", 0, "r10")
  state.asm = a.jmp(state.asm, L_COAL_LOOP)

  state.asm = a.mark(state.asm, L_COAL_DONE)
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_free_head")
  state.asm = a.mov_membase_disp_r64(state.asm, "rbx", 8, "rax")
  state.asm = a.mov_r64_r64(state.asm, "rax", "rbx")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_free_head")

  state.asm = a.mark(state.asm, L_REBUILD_NEXT)
  state.asm = a.add_r64_r64(state.asm, "rbx", "r10")
  state.asm = a.jmp(state.asm, L_REBUILD_LOOP)

  state.asm = a.mark(state.asm, L_REBUILD_DONE)
  state.asm = a.mark(state.asm, L_REBUILD2_AFTER)
  state.asm = a.mov_rax_imm64(state.asm, 0)
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_bytes_since")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_young_bytes_since")

  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.pop_reg(state.asm, "rdi")
  state.asm = a.pop_r15(state.asm)
  state.asm = a.pop_r14(state.asm)
  state.asm = a.pop_r13(state.asm)
  state.asm = a.pop_r12(state.asm)
  state.asm = a.pop_reg(state.asm, "rsi")
  state.asm = a.pop_rbp(state.asm)
  state.asm = a.pop_rbx(state.asm)

  state.asm = a.ret(state.asm)
  return state
end function

function emit_incref_function(state)
  state.asm = a.mark(state.asm, "fn_incref")
  state.asm = a.ret(state.asm)
  return state
end function

function emit_decref_function(state)
  state.asm = a.mark(state.asm, "fn_decref")
  state.asm = a.ret(state.asm)
  return state
end function

function emit_heap_count_function(state)
  state = ensure_gc_data(state)
  state.asm = a.mark(state.asm, "fn_heap_count")

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_loop = "heap_count_loop_" + lid
  l_live = "heap_count_live_" + lid
  l_done = "heap_count_done_" + lid

  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.mov_r10_rax(state.asm)

  state.asm = a.mov_rax_rip_qword(state.asm, "heap_ptr")
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")

  state.asm = a.xor_r64_r64(state.asm, "r8", "r8")

  state.asm = a.mark(state.asm, l_loop)
  state.asm = a.cmp_r64_r64(state.asm, "r10", "r11")
  state.asm = a.jcc(state.asm, "ae", l_done)

  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "r10", 0)
  state.asm = a.test_r64_imm32(state.asm, "rcx", c.GC_BLOCK_FREE_BIT)
  state.asm = a.jcc(state.asm, "e", l_live)

  state.asm = a.and_r64_imm(state.asm, "rcx", c.GC_BLOCK_SIZE_MASK)
  state.asm = a.add_r64_r64(state.asm, "r10", "rcx")
  state.asm = a.jmp(state.asm, l_loop)

  state.asm = a.mark(state.asm, l_live)
  state.asm = a.inc_r64(state.asm, "r8")
  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "r10", 0)
  state.asm = a.and_r64_imm(state.asm, "rcx", c.GC_BLOCK_SIZE_MASK)
  state.asm = a.add_r64_r64(state.asm, "r10", "rcx")
  state.asm = a.jmp(state.asm, l_loop)

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_heap_bytes_used_function(state)
  state = ensure_gc_data(state)
  state.asm = a.mark(state.asm, "fn_heap_bytes_used")

  state.asm = a.mov_rax_rip_qword(state.asm, "heap_ptr")
  state.asm = a.mov_r10_rax(state.asm)
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.sub_r64_r64(state.asm, "r10", "rax")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_heap_bytes_committed_function(state)
  state = ensure_gc_data(state)
  state.asm = a.mark(state.asm, "fn_heap_bytes_committed")

  state.asm = a.mov_rax_rip_qword(state.asm, "heap_end")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.sub_r64_r64(state.asm, "r10", "rax")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_heap_bytes_reserved_function(state)
  state = ensure_gc_data(state)
  state.asm = a.mark(state.asm, "fn_heap_bytes_reserved")

  state.asm = a.mov_rax_rip_qword(state.asm, "heap_reserve_end")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.sub_r64_r64(state.asm, "r10", "rax")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r10")
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_heap_free_blocks_function(state)
  state = ensure_gc_data(state)
  state.asm = a.mark(state.asm, "fn_heap_free_blocks")
  state.asm = a.push_r13(state.asm)

  state.asm = a.xor_r32_r32(state.asm, "r8d", "r8d")

  state.asm = a.mov_rax_rip_qword(state.asm, "gc_free_head")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")

  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")

  state.asm = a.mov_rax_rip_qword(state.asm, "heap_end")
  state.asm = a.mov_r64_r64(state.asm, "r9", "rax")

  state.asm = a.mov_r64_imm64(state.asm, "r13", 200000)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_loop = "hfb_loop_" + lid
  l_done = "hfb_done_" + lid
  l_bad = "hfb_bad_" + lid

  state.asm = a.mark(state.asm, l_loop)
  state.asm = a.cmp_r64_imm(state.asm, "r10", 0)
  state.asm = a.jcc(state.asm, "e", l_done)

  state.asm = a.dec_r64(state.asm, "r13")
  state.asm = a.jcc(state.asm, "z", l_bad)

  state.asm = a.cmp_r64_r64(state.asm, "r10", "r11")
  state.asm = a.jcc(state.asm, "b", l_bad)
  state.asm = a.cmp_r64_r64(state.asm, "r10", "r9")
  state.asm = a.jcc(state.asm, "ae", l_bad)

  state.asm = a.test_r64_imm32(state.asm, "r10", 7)
  state.asm = a.jcc(state.asm, "ne", l_bad)

  state.asm = a.inc_r32(state.asm, "r8d")
  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "r10", c.GC_OFF_NEXT_FREE)
  state.asm = a.jmp(state.asm, l_loop)

  state.asm = a.mark(state.asm, l_bad)
  state.asm = a.xor_r32_r32(state.asm, "r8d", "r8d")

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
  state.asm = a.pop_r13(state.asm)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_heap_free_bytes_function(state)
  state = ensure_gc_data(state)
  state.asm = a.mark(state.asm, "fn_heap_free_bytes")
  state.asm = a.push_r13(state.asm)

  state.asm = a.xor_r32_r32(state.asm, "r8d", "r8d")

  state.asm = a.mov_rax_rip_qword(state.asm, "gc_free_head")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rax")

  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")

  state.asm = a.mov_rax_rip_qword(state.asm, "heap_end")
  state.asm = a.mov_r64_r64(state.asm, "r9", "rax")

  state.asm = a.mov_r64_imm64(state.asm, "r13", 200000)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_loop = "hfb2_loop_" + lid
  l_done = "hfb2_done_" + lid
  l_bad = "hfb2_bad_" + lid

  state.asm = a.mark(state.asm, l_loop)
  state.asm = a.cmp_r64_imm(state.asm, "r10", 0)
  state.asm = a.jcc(state.asm, "e", l_done)

  state.asm = a.dec_r64(state.asm, "r13")
  state.asm = a.jcc(state.asm, "z", l_bad)

  state.asm = a.cmp_r64_r64(state.asm, "r10", "r11")
  state.asm = a.jcc(state.asm, "b", l_bad)
  state.asm = a.cmp_r64_r64(state.asm, "r10", "r9")
  state.asm = a.jcc(state.asm, "ae", l_bad)
  state.asm = a.test_r64_imm32(state.asm, "r10", 7)
  state.asm = a.jcc(state.asm, "ne", l_bad)

  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r10", 0)
  state.asm = a.and_r64_imm(state.asm, "rax", c.GC_BLOCK_SIZE_MASK)
  state.asm = a.add_r64_r64(state.asm, "r8", "rax")

  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "r10", c.GC_OFF_NEXT_FREE)
  state.asm = a.jmp(state.asm, l_loop)

  state.asm = a.mark(state.asm, l_bad)
  state.asm = a.xor_r32_r32(state.asm, "r8d", "r8d")

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.mov_r64_r64(state.asm, "rax", "r8")
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.or_rax_imm8(state.asm, c.TAG_INT)
  state.asm = a.pop_r13(state.asm)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_heap_grow_function(state)
  state = ensure_gc_data(state)
  state.asm = a.mark(state.asm, "fn_heap_grow")

  grow_min = _heap_cfg_get_int(state, "grow_min_bytes", HEAP_GROW_MIN)
  if typeof(grow_min) != "int" or grow_min <= 0 then grow_min = HEAP_GROW_MIN end if

  state.asm = a.push_rbx(state.asm)
  state.asm = a.push_r12(state.asm)
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)

  lid = state.label_id
  state.label_id = state.label_id + 1
  l_ok = "hg_ok_" + lid
  l_bitmap_ok = "hg_bitmap_ok_" + lid
  l_bitmap_call = "hg_bitmap_call_" + lid
  l_call = "hg_call_" + lid
  l_fail = "hg_fail_" + lid
  l_done = "hg_done_" + lid
  l_use_min = "hg_use_min_" + lid

  state.asm = a.mov_rax_rip_qword(state.asm, "heap_end")
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")

  state.asm = a.cmp_r64_r64(state.asm, "rcx", "r11")
  state.asm = a.jcc(state.asm, "be", l_ok)

  state.asm = a.mov_r64_r64(state.asm, "rdx", "rcx")
  state.asm = a.sub_r64_r64(state.asm, "rdx", "r11")
  state.asm = a.add_r64_imm(state.asm, "rdx", 4095)
  state.asm = a.and_r64_imm(state.asm, "rdx", -4096)

  state.asm = a.cmp_r64_imm(state.asm, "rdx", grow_min)
  state.asm = a.jcc(state.asm, "ae", l_use_min)
  state.asm = a.mov_r64_imm64(state.asm, "rdx", grow_min)
  state.asm = a.mark(state.asm, l_use_min)

  state.asm = a.mov_r64_r64(state.asm, "rbx", "r11")
  state.asm = a.add_r64_r64(state.asm, "rbx", "rdx")

  state.asm = a.mov_rax_rip_qword(state.asm, "heap_reserve_end")
  state.asm = a.cmp_r64_r64(state.asm, "rbx", "rax")
  state.asm = a.jcc(state.asm, "be", l_call)
  state.asm = a.jmp(state.asm, l_fail)

  // Grow the bitmap first so GC metadata always covers committed heap pages.
  state.asm = a.mark(state.asm, l_call)
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_base")
  state.asm = a.mov_r64_r64(state.asm, "r10", "rbx")
  state.asm = a.sub_r64_r64(state.asm, "r10", "rax")
  state.asm = a.add_r64_imm(state.asm, "r10", 63)
  state.asm = a.shr_r64_imm8(state.asm, "r10", 6)
  state.asm = a.add_r64_imm(state.asm, "r10", MEM_PAGE_SIZE - 1)
  state.asm = a.and_r64_imm(state.asm, "r10", -MEM_PAGE_SIZE)

  state.asm = a.mov_rax_rip_qword(state.asm, "gc_mark_bits_base")
  state.asm = a.mov_r64_r64(state.asm, "r12", "rax")
  state.asm = a.add_r64_r64(state.asm, "r12", "r10")

  state.asm = a.mov_rax_rip_qword(state.asm, "gc_mark_bits_end")
  state.asm = a.cmp_r64_r64(state.asm, "rax", "r12")
  state.asm = a.jcc(state.asm, "ae", l_bitmap_ok)

  state.asm = a.mov_rax_rip_qword(state.asm, "gc_mark_bits_reserve_end")
  state.asm = a.cmp_r64_r64(state.asm, "r12", "rax")
  state.asm = a.jcc(state.asm, "be", l_bitmap_call)
  state.asm = a.jmp(state.asm, l_fail)

  state.asm = a.mark(state.asm, l_bitmap_call)
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_mark_bits_end")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "r12")
  state.asm = a.sub_r64_r64(state.asm, "rdx", "rax")
  state.asm = a.mov_r8d_imm32(state.asm, 0x1000)
  state.asm = a.mov_r9d_imm32(state.asm, 0x04)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_VirtualAlloc")
  state.asm = a.call_rax(state.asm)

  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", l_fail)

  state.asm = a.mov_r64_r64(state.asm, "rax", "r12")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_mark_bits_end")

  state.asm = a.mark(state.asm, l_bitmap_ok)
  state.asm = a.mov_rax_rip_qword(state.asm, "heap_end")
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "r11")
  state.asm = a.mov_r64_r64(state.asm, "rdx", "rbx")
  state.asm = a.sub_r64_r64(state.asm, "rdx", "r11")
  state.asm = a.mov_r8d_imm32(state.asm, 0x1000)
  state.asm = a.mov_r9d_imm32(state.asm, 0x04)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_VirtualAlloc")
  state.asm = a.call_rax(state.asm)

  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", l_fail)

  // heap_end aus rbx aktualisieren
  state.asm = a.mov_r64_r64(state.asm, "rax", "rbx")
  state.asm = a.mov_rip_qword_rax(state.asm, "heap_end")

  state.asm = a.mark(state.asm, l_ok)
  state.asm = a.xor_eax_eax(state.asm)
  state.asm = a.inc_r32(state.asm, "eax")
  state.asm = a.jmp(state.asm, l_done)

  state.asm = a.mark(state.asm, l_fail)
  state.asm = a.xor_eax_eax(state.asm)

  state.asm = a.mark(state.asm, l_done)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.pop_r12(state.asm)
  state.asm = a.pop_rbx(state.asm)
  state.asm = a.ret(state.asm)
  return state
end function

function cg_memory_init(state)
  return ensure_gc_data(state)
end function
