// Emits native threads, synchronization and stop-the-world GC coordination.
package mlc.codegen.codegen_threads
import mlc.asm as a
import mlc.constants as c
import mlc.data as d
import mlc.tools as t

// Native thread-context layout. Tagged managed values occupy qword fields and
// are scanned as GC roots; status and counters use native integer fields.
const THREAD_TYPE = 0
const THREAD_STATUS = 4
const THREAD_HANDLE = 8
const THREAD_ID = 16
const THREAD_CODE = 24
const THREAD_STOP = 32
const THREAD_RESULT = 40
const THREAD_ROOTS = 48
const THREAD_TMP0 = 56
const THREAD_NEXT = 120
const THREAD_GC_STATE = 128
// Cursor for the four allocation-handoff roots at THREAD_TMP0+32.
const THREAD_HANDOFF_CURSOR = 136
const THREAD_ALLOC_CURSOR = THREAD_HANDOFF_CURSOR
const THREAD_ARG = 144
const THREAD_LOGICAL_ID = 152
const THREAD_ARITY = 160
const THREAD_HEAP_BYPASS_DEPTH = 168
// Per-thread allocation ranges carved from the shared process heap.
const THREAD_TLAB_START = 176
const THREAD_TLAB_CURSOR = 184
const THREAD_TLAB_END = 192
const THREAD_CONTEXT_SIZE = 200

// Public lifecycle states stored in THREAD_STATUS.
const THREAD_CREATED = 0
const THREAD_RUNNING = 1
const THREAD_STOP_REQUESTED = 2
const THREAD_COMPLETED = 3
const THREAD_STOPPED = 4
const THREAD_FAILED = 5

// Collector-facing states used by cooperative stop-the-world coordination.
const GC_THREAD_RUNNING = 0
const GC_THREAD_PARKED = 1
const GC_THREAD_NATIVE = 2
const GC_THREAD_INACTIVE = 3
const GC_THREAD_COLLECTOR = 4

function _has_label(labels, name)
  if typeof(labels) != "array" or len(labels) <= 0 then return false end if
  for i = 0 to len(labels) - 1
    if labels[i].name == name then return true end if
  end for
  return false
end function

function _append_unique(values, value)
  if typeof(values) != "array" then values = [] end if
  if len(values) <= 0 then return [value] end if
  for i = 0 to len(values) - 1
    if values[i] == value then return values end if
  end for
  return values + [value]
end function

function _new_label_id(state)
  state.label_id = state.label_id + 1
  return state.label_id
end function

// Materialize global monitors, the main context and coordination counters once.
function ensure_thread_data(state)
  if d.data_has_label(state.data, "sync_monitor") == false then
    state.data = d.data_pad_align(state.data, 8)
    state.data = d.data_add_bytes(state.data, "sync_monitor", bytes(40, 0))
  end if
  if d.data_has_label(state.data, "heap_monitor") == false then
    state.data = d.data_pad_align(state.data, 8)
    state.data = d.data_add_bytes(state.data, "heap_monitor", bytes(40, 0))
  end if
  if d.data_has_label(state.data, "gc_coord_monitor") == false then
    state.data = d.data_pad_align(state.data, 8)
    state.data = d.data_add_bytes(state.data, "gc_coord_monitor", bytes(40, 0))
  end if
  if d.data_has_label(state.data, "main_thread_context") == false then
    state.data = d.data_pad_align(state.data, 8)
    state.data = d.data_add_bytes(state.data, "main_thread_context", bytes(THREAD_CONTEXT_SIZE, 0))
  end if
  if d.data_has_label(state.data, "thread_contexts_head") == false then
    state.data = d.data_add_u64(state.data, "thread_contexts_head", 0)
  end if
  if d.data_has_label(state.data, "gc_requested") == false then
    state.data = d.data_add_u64(state.data, "gc_requested", 0)
  end if
  if d.data_has_label(state.data, "managed_thread_count") == false then
    state.data = d.data_add_u64(state.data, "managed_thread_count", 1)
  end if
  return state
end function

// Initialize the main thread context and all process-wide critical sections.
function emit_sync_init(state)
  state = ensure_thread_data(state)
  state.asm = a.lea_rax_rip(state.asm, "main_thread_context")
  state.asm = a.mov_gs_qword_28_rax(state.asm)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_TYPE, 0, false)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_RESULT, t.enc_void(), true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_ROOTS, 0, true)
  for i = 0 to 7
    state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_TMP0 + i * 8, t.enc_void(), true)
  end for
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_NEXT, 0, true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_GC_STATE, GC_THREAD_RUNNING, false)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_HANDOFF_CURSOR, 0, false)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_ARG, t.enc_void(), true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_LOGICAL_ID, t.enc_void(), true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_ARITY, 0, false)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_HEAP_BYPASS_DEPTH, 0, false)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_TLAB_START, 0, true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_TLAB_CURSOR, 0, true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_TLAB_END, 0, true)
  state.asm = a.mov_rip_qword_rax(state.asm, "thread_contexts_head")
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_requested")
  state.asm = a.mov_rax_imm64(state.asm, 1)
  state.asm = a.mov_rip_qword_rax(state.asm, "managed_thread_count")
  monitors = ["sync_monitor", "heap_monitor", "gc_coord_monitor"]
  for i = 0 to len(monitors) - 1
    state.asm = a.lea_rax_rip(state.asm, monitors[i])
    state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
    state.asm = a.mov_rax_rip_qword(state.asm, "iat_InitializeCriticalSection")
    state.asm = a.call_rax(state.asm)
  end for
  return state
end function

// Emit a cheap conditional call that parks when collection was requested.
function emit_gc_safepoint_poll(state)
  if state.native_threads_possible == false then return state end if
  state.used_helpers = _append_unique(state.used_helpers, "fn_gc_safepoint")
  done = "gc_poll_done_" + _new_label_id(state)
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_requested")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", done)
  state.asm = a.call(state.asm, "fn_gc_safepoint")
  state.asm = a.mark(state.asm, done)
  return state
end function

// Cooperatively turn a stop request into an early function return.
function emit_thread_cancellation_poll(state)
  if state.native_threads_possible == false then return state end if
  if state.in_function == false then return state end if
  if typeof(state.func_ret_label) != "string" or state.func_ret_label == "" then return state end if
  lid = _new_label_id(state)
  l_done = "thread_cancel_done_" + lid
  state.asm = a.mov_r11_gs_qword_28(state.asm)
  state.asm = a.test_r64_r64(state.asm, "r11", "r11")
  state.asm = a.jcc(state.asm, "e", l_done)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", THREAD_TYPE)
  state.asm = a.cmp_r32_imm(state.asm, "r10d", c.OBJ_THREAD)
  state.asm = a.jcc(state.asm, "ne", l_done)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", THREAD_STATUS)
  state.asm = a.cmp_r32_imm(state.asm, "r10d", THREAD_STOP_REQUESTED)
  state.asm = a.jcc(state.asm, "ne", l_done)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_void())
  state.asm = a.jmp(state.asm, state.func_ret_label)
  state.asm = a.mark(state.asm, l_done)
  return state
end function

function _emit_managed_thread_count_delta(state, delta)
  lid = _new_label_id(state)
  l_retry = "managed_thread_count_retry_" + lid
  state.asm = a.lea_r11_rip(state.asm, "managed_thread_count")
  state.asm = a.mark(state.asm, l_retry)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r11", 0)
  state.asm = a.mov_r32_r32(state.asm, "edx", "eax")
  if delta >= 0 then
    state.asm = a.inc_r32(state.asm, "edx")
  else
    state.asm = a.dec_r32(state.asm, "edx")
  end if
  state.asm = a.lock_cmpxchg_membase_disp_r32(state.asm, "r11", 0, "edx")
  state.asm = a.jcc(state.asm, "ne", l_retry)
  return state
end function

// Emit the slow path that publishes a parked state until GC resumes the world.
function emit_gc_safepoint_function(state)
  state = ensure_thread_data(state)
  state.asm = a.mark(state.asm, "fn_gc_safepoint")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)
  lid = _new_label_id(state)
  l_done = "gcsafe_done_" + lid
  l_wait = "gcsafe_wait_" + lid
  l_recheck = "gcsafe_recheck_" + lid
  l_park = "gcsafe_park_" + lid
  l_resume = "gcsafe_resume_" + lid
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_requested")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", l_done)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_EnterCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_requested")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", l_resume)
  state.asm = a.mark(state.asm, l_park)
  state.asm = a.mov_r11_gs_qword_28(state.asm)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", THREAD_GC_STATE, GC_THREAD_PARKED, false)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_LeaveCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mark(state.asm, l_wait)
  state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_Sleep")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_requested")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "ne", l_wait)
  state.asm = a.mark(state.asm, l_recheck)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_EnterCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_requested")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  // A back-to-back collection must observe this thread as parked before it
  // waits. Publish the state while the coordination monitor is still held.
  state.asm = a.jcc(state.asm, "ne", l_park)
  state.asm = a.mov_r11_gs_qword_28(state.asm)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", THREAD_GC_STATE, GC_THREAD_RUNNING, false)
  state.asm = a.mark(state.asm, l_resume)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_LeaveCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_requested")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  // Reacquire the monitor before waiting so a newly requested collection
  // cannot see RUNNING while this thread spins for the request to clear.
  state.asm = a.jcc(state.asm, "ne", l_recheck)
  state.asm = a.mark(state.asm, l_done)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

// Mark the current thread native so the collector does not wait for a poll.
function emit_gc_native_enter_function(state)
  state.used_helpers = _append_unique(state.used_helpers, "fn_gc_safepoint")
  state = ensure_thread_data(state)
  state.asm = a.mark(state.asm, "fn_gc_native_enter")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)
  lid = _new_label_id(state)
  l_retry = "gcnative_enter_retry_" + lid
  l_ready = "gcnative_enter_ready_" + lid
  state.asm = a.mark(state.asm, l_retry)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_EnterCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_requested")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", l_ready)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_LeaveCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.call(state.asm, "fn_gc_safepoint")
  state.asm = a.jmp(state.asm, l_retry)
  state.asm = a.mark(state.asm, l_ready)
  state.asm = a.mov_r11_gs_qword_28(state.asm)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", THREAD_GC_STATE, GC_THREAD_NATIVE, false)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_LeaveCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

// Rejoin managed execution, parking first when a collection is active.
function emit_gc_native_leave_function(state)
  state = ensure_thread_data(state)
  state.asm = a.mark(state.asm, "fn_gc_native_leave")
  state.asm = a.sub_rsp_imm8(state.asm, 0x38)
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")
  state.asm = a.movsd_membase_disp_xmm(state.asm, "rsp", 0x28, "xmm0")
  lid = _new_label_id(state)
  l_wait = "gcnative_leave_wait_" + lid
  l_lock = "gcnative_leave_lock_" + lid
  l_running = "gcnative_leave_running_" + lid
  state.asm = a.mark(state.asm, l_lock)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_EnterCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_requested")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", l_running)
  state.asm = a.mov_r11_gs_qword_28(state.asm)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", THREAD_GC_STATE, GC_THREAD_PARKED, false)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_LeaveCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mark(state.asm, l_wait)
  state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_Sleep")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_requested")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "ne", l_wait)
  state.asm = a.jmp(state.asm, l_lock)
  state.asm = a.mark(state.asm, l_running)
  state.asm = a.mov_r11_gs_qword_28(state.asm)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", THREAD_GC_STATE, GC_THREAD_RUNNING, false)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_LeaveCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x20)
  state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm0", "rsp", 0x28)
  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)
  return state
end function

// Remove a terminating managed worker from collector participation.
function emit_gc_managed_exit_function(state)
  state = ensure_thread_data(state)
  state.asm = a.mark(state.asm, "fn_gc_managed_exit")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_EnterCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_r11_gs_qword_28(state.asm)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", THREAD_GC_STATE, GC_THREAD_INACTIVE, false)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_LeaveCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

// Serialize heap mutation while preserving re-entrant allocation depth.
function emit_heap_enter_function(state)
  state.used_helpers = _append_unique(state.used_helpers, "fn_gc_safepoint")
  state.used_helpers = _append_unique(state.used_helpers, "fn_gc_native_enter")
  state = ensure_thread_data(state)
  state.asm = a.mark(state.asm, "fn_heap_enter")
  lid_fast = _new_label_id(state)
  l_locked_fast = "heap_enter_locked_" + lid_fast
  state.asm = a.mov_rax_rip_qword(state.asm, "managed_thread_count")
  state.asm = a.cmp_r64_imm(state.asm, "rax", 1)
  state.asm = a.jcc(state.asm, "a", l_locked_fast)
  state.asm = a.mov_r11_gs_qword_28(state.asm)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", THREAD_HEAP_BYPASS_DEPTH)
  state.asm = a.inc_r32(state.asm, "r10d")
  state.asm = a.mov_membase_disp_r32(state.asm, "r11", THREAD_HEAP_BYPASS_DEPTH, "r10d")
  state.asm = a.ret(state.asm)
  state.asm = a.mark(state.asm, l_locked_fast)
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)
  lid = _new_label_id(state)
  l_retry = "heap_enter_retry_" + lid
  l_owned = "heap_enter_owned_" + lid
  state.asm = a.mark(state.asm, l_retry)
  state.asm = a.call(state.asm, "fn_gc_safepoint")
  state.asm = a.call(state.asm, "fn_gc_native_enter")
  state.asm = a.lea_rax_rip(state.asm, "heap_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_EnterCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_EnterCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_rax_rip_qword(state.asm, "gc_requested")
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", l_owned)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_LeaveCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.lea_rax_rip(state.asm, "heap_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_LeaveCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.call(state.asm, "fn_gc_safepoint")
  state.asm = a.jmp(state.asm, l_retry)
  state.asm = a.mark(state.asm, l_owned)
  state.asm = a.mov_r11_gs_qword_28(state.asm)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", THREAD_GC_STATE, GC_THREAD_RUNNING, false)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_LeaveCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

// Release the heap monitor at the outermost allocation depth.
function emit_heap_leave_function(state)
  state = ensure_thread_data(state)
  state.asm = a.mark(state.asm, "fn_heap_leave")
  lid = _new_label_id(state)
  l_locked = "heap_leave_locked_" + lid
  state.asm = a.mov_r11_gs_qword_28(state.asm)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", THREAD_HEAP_BYPASS_DEPTH)
  state.asm = a.test_r32_r32(state.asm, "r10d", "r10d")
  state.asm = a.jcc(state.asm, "e", l_locked)
  state.asm = a.dec_r32(state.asm, "r10d")
  state.asm = a.mov_membase_disp_r32(state.asm, "r11", THREAD_HEAP_BYPASS_DEPTH, "r10d")
  state.asm = a.ret(state.asm)
  state.asm = a.mark(state.asm, l_locked)
  state.asm = a.sub_rsp_imm8(state.asm, 0x38)
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")
  state.asm = a.movsd_membase_disp_xmm(state.asm, "rsp", 0x28, "xmm0")
  state.asm = a.lea_rax_rip(state.asm, "heap_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_LeaveCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x20)
  state.asm = a.movsd_xmm_membase_disp(state.asm, "xmm0", "rsp", 0x28)
  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)
  return state
end function

// Request collection and wait until every other managed thread is safe.
function emit_gc_world_stop_function(state)
  state = ensure_thread_data(state)
  state.asm = a.mark(state.asm, "fn_gc_world_stop")
  state.asm = a.sub_rsp_imm8(state.asm, 0x38)
  state.asm = a.mov_r11_gs_qword_28(state.asm)
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x30, "r11")
  lid = _new_label_id(state)
  l_wait = "gcworld_wait_" + lid
  l_scan = "gcworld_scan_" + lid
  l_next = "gcworld_next_" + lid
  l_not_ready = "gcworld_not_ready_" + lid
  l_ready = "gcworld_ready_" + lid
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_EnterCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_r11_gs_qword_28(state.asm)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", THREAD_GC_STATE, GC_THREAD_COLLECTOR, false)
  state.asm = a.mov_rax_imm64(state.asm, 1)
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_requested")
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_LeaveCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mark(state.asm, l_wait)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_EnterCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_rax_rip_qword(state.asm, "thread_contexts_head")
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
  state.asm = a.mark(state.asm, l_scan)
  state.asm = a.test_r64_r64(state.asm, "r11", "r11")
  state.asm = a.jcc(state.asm, "e", l_ready)
  state.asm = a.mov_r64_membase_disp(state.asm, "r10", "rsp", 0x30)
  state.asm = a.cmp_r64_r64(state.asm, "r11", "r10")
  state.asm = a.jcc(state.asm, "e", l_next)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r11", THREAD_GC_STATE)
  state.asm = a.cmp_r32_imm(state.asm, "eax", GC_THREAD_RUNNING)
  state.asm = a.jcc(state.asm, "e", l_not_ready)
  state.asm = a.mark(state.asm, l_next)
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "r11", THREAD_NEXT)
  state.asm = a.jmp(state.asm, l_scan)
  state.asm = a.mark(state.asm, l_not_ready)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_LeaveCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_Sleep")
  state.asm = a.call_rax(state.asm)
  state.asm = a.jmp(state.asm, l_wait)
  state.asm = a.mark(state.asm, l_ready)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_LeaveCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)
  return state
end function

// Clear the collection request and make parked threads runnable again.
function emit_gc_world_resume_function(state)
  state = ensure_thread_data(state)
  state.asm = a.mark(state.asm, "fn_gc_world_resume")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_EnterCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.mov_rip_qword_rax(state.asm, "gc_requested")
  state.asm = a.mov_r11_gs_qword_28(state.asm)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", THREAD_GC_STATE, GC_THREAD_RUNNING, false)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_LeaveCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

// Enter the process-wide monitor used by synchronized language constructs.
function emit_sync_enter_function(state)
  state.used_helpers = _append_unique(state.used_helpers, "fn_gc_native_enter")
  state.used_helpers = _append_unique(state.used_helpers, "fn_gc_native_leave")
  state = ensure_thread_data(state)
  state.asm = a.mark(state.asm, "fn_sync_enter")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)
  state.asm = a.call(state.asm, "fn_gc_native_enter")
  state.asm = a.lea_rax_rip(state.asm, "sync_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_EnterCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.call(state.asm, "fn_gc_native_leave")
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.ret(state.asm)
  return state
end function

// Leave the process-wide synchronized monitor.
function emit_sync_leave_function(state)
  state = ensure_thread_data(state)
  state.asm = a.mark(state.asm, "fn_sync_leave")
  state.asm = a.push_reg(state.asm, "rax")
  state.asm = a.sub_rsp_imm8(state.asm, 0x20)
  state.asm = a.lea_rax_rip(state.asm, "sync_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_LeaveCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x20)
  state.asm = a.pop_reg(state.asm, "rax")
  state.asm = a.ret(state.asm)
  return state
end function

// Allocate and initialize a managed Thread object without starting it.
function emit_thread_new_function(state)
  state = ensure_thread_data(state)
  state.asm = a.mark(state.asm, "fn_thread_new")
  state.asm = a.sub_rsp_imm8(state.asm, 0x58)
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x38, "rcx")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x40, "rdx")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x48, "r8")
  state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.mov_r32_imm32(state.asm, "edx", THREAD_CONTEXT_SIZE)
  state.asm = a.mov_r8d_imm32(state.asm, 0x3000)
  state.asm = a.mov_r9d_imm32(state.asm, 0x04)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_VirtualAlloc")
  state.asm = a.call_rax(state.asm)
  lid = _new_label_id(state)
  l_done = "thnew_done_" + lid
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", l_done)
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x30, "rax")
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_TYPE, c.OBJ_THREAD, false)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_STATUS, THREAD_CREATED, false)
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x38)
  state.asm = a.mov_membase_disp_r64(state.asm, "rax", THREAD_CODE, "r11")
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_RESULT, t.enc_void(), true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_ROOTS, 0, true)
  for i = 0 to 7
    state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_TMP0 + i * 8, t.enc_void(), true)
  end for
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_GC_STATE, GC_THREAD_INACTIVE, false)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_HANDOFF_CURSOR, 0, false)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_ARG, t.enc_void(), true)
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x48)
  state.asm = a.mov_membase_disp_r64(state.asm, "rax", THREAD_LOGICAL_ID, "r11")
  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "rsp", 0x40)
  state.asm = a.mov_membase_disp_r32(state.asm, "rax", THREAD_ARITY, "r11d")
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_HEAP_BYPASS_DEPTH, 0, false)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_TLAB_START, 0, true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_TLAB_CURSOR, 0, true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rax", THREAD_TLAB_END, 0, true)
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_EnterCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_rax_rip_qword(state.asm, "thread_contexts_head")
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x30)
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", THREAD_NEXT, "rax")
  state.asm = a.mov_r64_r64(state.asm, "rax", "r11")
  state.asm = a.mov_rip_qword_rax(state.asm, "thread_contexts_head")
  state.asm = a.lea_rax_rip(state.asm, "gc_coord_monitor")
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_LeaveCriticalSection")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0x30)
  state.asm = a.mark(state.asm, l_done)
  state.asm = a.add_rsp_imm8(state.asm, 0x58)
  state.asm = a.ret(state.asm)
  return state
end function

// Publish the argument and create the native worker exactly once.
function emit_thread_start_function(state)
  state.used_helpers = _append_unique(state.used_helpers, "fn_thread_entry")
  state.asm = a.mark(state.asm, "fn_thread_start")
  state.asm = a.sub_rsp_imm8(state.asm, 0x58)
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x30, "rcx")
  lid = _new_label_id(state)
  l_not_created = "thstart_not_created_" + lid
  l_wrong_arity = "thstart_wrong_arity_" + lid
  l_create_fail = "thstart_create_fail_" + lid
  l_done = "thstart_done_" + lid
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rcx", THREAD_ARITY)
  state.asm = a.cmp_r32_r32(state.asm, "eax", "r8d")
  state.asm = a.jcc(state.asm, "ne", l_wrong_arity)
  // Claim the one-shot Thread object before publishing its argument. A plain
  // load/store allowed two callers to overwrite the same handle and argument.
  state.asm = a.mov_r32_imm32(state.asm, "eax", THREAD_CREATED)
  state.asm = a.mov_r32_imm32(state.asm, "r11d", THREAD_RUNNING)
  state.asm = a.lock_cmpxchg_membase_disp_r32(state.asm, "rcx", THREAD_STATUS, "r11d")
  state.asm = a.cmp_r32_imm(state.asm, "eax", THREAD_CREATED)
  state.asm = a.jcc(state.asm, "ne", l_not_created)
  state.asm = a.mov_membase_disp_imm32(state.asm, "rcx", THREAD_STOP, 0, false)
  state.asm = a.mov_membase_disp_r64(state.asm, "rcx", THREAD_ARG, "rdx")
  state = _emit_managed_thread_count_delta(state, 1)
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rax")
  state.asm = a.lea_r64_membase_disp(state.asm, "rax", "rsp", 0x40)
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x28, "rax")
  state.asm = a.xor_r32_r32(state.asm, "ecx", "ecx")
  state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
  state.asm = a.lea_r8_rip(state.asm, "fn_thread_entry")
  state.asm = a.mov_r64_membase_disp(state.asm, "r9", "rsp", 0x30)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_CreateThread")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x30)
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", l_create_fail)
  state.asm = a.mov_membase_disp_r64(state.asm, "r11", THREAD_HANDLE, "rax")
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rsp", 0x40)
  state.asm = a.mov_membase_disp_r32(state.asm, "r11", THREAD_ID, "eax")
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
  state.asm = a.jmp(state.asm, l_done)
  state.asm = a.mark(state.asm, l_create_fail)
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x30)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", THREAD_STATUS, THREAD_FAILED, false)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", THREAD_ARG, t.enc_void(), true)
  state = _emit_managed_thread_count_delta(state, -1)
  state.asm = a.mark(state.asm, l_wrong_arity)
  state.asm = a.mark(state.asm, l_not_created)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
  state.asm = a.mark(state.asm, l_done)
  state.asm = a.add_rsp_imm8(state.asm, 0x58)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_thread_stop_function(state)
  state.asm = a.mark(state.asm, "fn_thread_stop")
  lid = _new_label_id(state)
  l_false = "thstop_false_" + lid
  l_done = "thstop_done_" + lid
  state.asm = a.mov_r32_imm32(state.asm, "eax", THREAD_RUNNING)
  state.asm = a.mov_r32_imm32(state.asm, "edx", THREAD_STOP_REQUESTED)
  state.asm = a.lock_cmpxchg_membase_disp_r32(state.asm, "rcx", THREAD_STATUS, "edx")
  state.asm = a.cmp_r32_imm(state.asm, "eax", THREAD_RUNNING)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
  state.asm = a.jmp(state.asm, l_done)
  state.asm = a.mark(state.asm, l_false)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
  state.asm = a.mark(state.asm, l_done)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_thread_join_function(state)
  state.used_helpers = _append_unique(state.used_helpers, "fn_gc_native_enter")
  state.used_helpers = _append_unique(state.used_helpers, "fn_gc_native_leave")
  state.asm = a.mark(state.asm, "fn_thread_join")
  state.asm = a.sub_rsp_imm8(state.asm, 0x38)
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x20, "rcx")
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x28, "rdx")
  lid = _new_label_id(state)
  l_false = "thjoin_false_" + lid
  l_done = "thjoin_done_" + lid
  state.asm = a.call(state.asm, "fn_gc_native_enter")
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x20)
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r11", THREAD_HANDLE)
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", l_false)
  state.asm = a.mov_r64_r64(state.asm, "rcx", "rax")
  state.asm = a.mov_r32_membase_disp(state.asm, "edx", "rsp", 0x28)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_WaitForSingleObject")
  state.asm = a.call_rax(state.asm)
  state.asm = a.call(state.asm, "fn_gc_native_leave")
  state.asm = a.cmp_r32_imm(state.asm, "eax", 0)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
  state.asm = a.jmp(state.asm, l_done)
  state.asm = a.mark(state.asm, l_false)
  l_false_ready = "thjoin_false_ready_" + lid
  state.asm = a.mov_r11_gs_qword_28(state.asm)
  state.asm = a.mov_r32_membase_disp(state.asm, "r10d", "r11", THREAD_GC_STATE)
  state.asm = a.cmp_r32_imm(state.asm, "r10d", GC_THREAD_NATIVE)
  state.asm = a.jcc(state.asm, "ne", l_false_ready)
  state.asm = a.call(state.asm, "fn_gc_native_leave")
  state.asm = a.mark(state.asm, l_false_ready)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
  state.asm = a.mark(state.asm, l_done)
  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_thread_alive_function(state)
  state.asm = a.mark(state.asm, "fn_thread_alive")
  lid = _new_label_id(state)
  l_true = "thalive_true_" + lid
  l_done = "thalive_done_" + lid
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rcx", THREAD_STATUS)
  state.asm = a.cmp_r32_imm(state.asm, "eax", THREAD_RUNNING)
  state.asm = a.jcc(state.asm, "e", l_true)
  state.asm = a.cmp_r32_imm(state.asm, "eax", THREAD_STOP_REQUESTED)
  state.asm = a.jcc(state.asm, "e", l_true)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
  state.asm = a.jmp(state.asm, l_done)
  state.asm = a.mark(state.asm, l_true)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
  state.asm = a.mark(state.asm, l_done)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_thread_id_function(state)
  state.asm = a.mark(state.asm, "fn_thread_id")
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rcx", THREAD_ID)
  state.asm = a.shl_rax_imm8(state.asm, 3)
  state.asm = a.or_rax_imm8(state.asm, 1)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_thread_logical_id_function(state)
  state.asm = a.mark(state.asm, "fn_thread_logical_id")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rcx", THREAD_LOGICAL_ID)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_thread_set_logical_id_function(state)
  state.asm = a.mark(state.asm, "fn_thread_set_logical_id")
  lid = _new_label_id(state)
  l_false = "thsetid_false_" + lid
  l_done = "thsetid_done_" + lid
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rcx", THREAD_STATUS)
  state.asm = a.cmp_r32_imm(state.asm, "eax", THREAD_CREATED)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.mov_membase_disp_r64(state.asm, "rcx", THREAD_LOGICAL_ID, "rdx")
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
  state.asm = a.jmp(state.asm, l_done)
  state.asm = a.mark(state.asm, l_false)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
  state.asm = a.mark(state.asm, l_done)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_thread_result_function(state)
  state.asm = a.mark(state.asm, "fn_thread_result")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rcx", THREAD_RESULT)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_thread_current_logical_id_function(state)
  state.asm = a.mark(state.asm, "fn_thread_current_logical_id")
  state.asm = a.mov_r11_gs_qword_28(state.asm)
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r11", THREAD_LOGICAL_ID)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_thread_status_function(state)
  names = ["obj_thread_created", "obj_thread_running", "obj_thread_stop_requested", "obj_thread_completed", "obj_thread_stopped", "obj_thread_failed"]
  values = ["Created", "Running", "StopRequested", "Completed", "Stopped", "Failed"]
  for i = 0 to len(names) - 1
    if d.rdata_has_label(state.rdata, names[i]) == false then
      state.rdata = d.rdata_add_obj_string(state.rdata, names[i], values[i])
    end if
  end for
  state.asm = a.mark(state.asm, "fn_thread_status")
  lid = _new_label_id(state)
  l_done = "thstatus_done_" + lid
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rcx", THREAD_STATUS)
  for status = 0 to len(names) - 1
    state.asm = a.cmp_r32_imm(state.asm, "eax", status)
    state.asm = a.jcc(state.asm, "e", "thstatus_" + status + "_" + lid)
  end for
  state.asm = a.lea_rax_rip(state.asm, "obj_thread_failed")
  state.asm = a.jmp(state.asm, l_done)
  for status = 0 to len(names) - 1
    state.asm = a.mark(state.asm, "thstatus_" + status + "_" + lid)
    state.asm = a.lea_rax_rip(state.asm, names[status])
    state.asm = a.jmp(state.asm, l_done)
  end for
  state.asm = a.mark(state.asm, l_done)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_thread_close_function(state)
  state.asm = a.mark(state.asm, "fn_thread_close")
  state.asm = a.sub_rsp_imm8(state.asm, 0x38)
  state.asm = a.mov_membase_disp_r64(state.asm, "rsp", 0x30, "rcx")
  lid = _new_label_id(state)
  l_false = "thclose_false_" + lid
  l_done = "thclose_done_" + lid
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "rcx", THREAD_STATUS)
  state.asm = a.cmp_r32_imm(state.asm, "eax", THREAD_RUNNING)
  state.asm = a.jcc(state.asm, "e", l_false)
  state.asm = a.cmp_r32_imm(state.asm, "eax", THREAD_STOP_REQUESTED)
  state.asm = a.jcc(state.asm, "e", l_false)
  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "rcx", THREAD_HANDLE)
  state.asm = a.test_r64_r64(state.asm, "rcx", "rcx")
  state.asm = a.jcc(state.asm, "e", l_false)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_CloseHandle")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_r64_membase_disp(state.asm, "r11", "rsp", 0x30)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", THREAD_HANDLE, 0, true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", THREAD_CODE, t.enc_void(), true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", THREAD_RESULT, t.enc_void(), true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", THREAD_ARG, t.enc_void(), true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", THREAD_LOGICAL_ID, t.enc_void(), true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", THREAD_TLAB_START, 0, true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", THREAD_TLAB_CURSOR, 0, true)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r11", THREAD_TLAB_END, 0, true)
  for i = 0 to 7
    state.asm = a.mov_membase_disp_imm32(state.asm, "r11", THREAD_TMP0 + i * 8, t.enc_void(), true)
  end for
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
  state.asm = a.jmp(state.asm, l_done)
  state.asm = a.mark(state.asm, l_false)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
  state.asm = a.mark(state.asm, l_done)
  state.asm = a.add_rsp_imm8(state.asm, 0x38)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_thread_stop_requested_function(state)
  state.asm = a.mark(state.asm, "fn_thread_stop_requested")
  lid = _new_label_id(state)
  l_false = "thsr_false_" + lid
  l_done = "thsr_done_" + lid
  state.asm = a.mov_r11_gs_qword_28(state.asm)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r11", THREAD_TYPE)
  state.asm = a.cmp_r32_imm(state.asm, "eax", c.OBJ_THREAD)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.mov_r32_membase_disp(state.asm, "eax", "r11", THREAD_STATUS)
  state.asm = a.cmp_r32_imm(state.asm, "eax", THREAD_STOP_REQUESTED)
  state.asm = a.jcc(state.asm, "ne", l_false)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(true))
  state.asm = a.jmp(state.asm, l_done)
  state.asm = a.mark(state.asm, l_false)
  state.asm = a.mov_rax_imm64(state.asm, t.enc_bool(false))
  state.asm = a.mark(state.asm, l_done)
  state.asm = a.ret(state.asm)
  return state
end function

function emit_thread_alloc_function(state)
  state.used_helpers = _append_unique(state.used_helpers, "fn_alloc")
  state.asm = a.mark(state.asm, "fn_thread_alloc")
  state.asm = a.jmp(state.asm, "fn_alloc")
  return state
end function

// Bridge the Win32 entrypoint to a managed callback and publish its result.
function emit_thread_entry_function(state)
  state.used_helpers = _append_unique(state.used_helpers, "fn_gc_native_leave")
  state.used_helpers = _append_unique(state.used_helpers, "fn_gc_managed_exit")
  // fn_alloc also emits the private TLAB-retirement helper used below.
  state.used_helpers = _append_unique(state.used_helpers, "fn_alloc")
  state.asm = a.mark(state.asm, "fn_thread_entry")
  state.asm = a.push_reg(state.asm, "rbx")
  state.asm = a.push_reg(state.asm, "r12")
  state.asm = a.sub_rsp_imm8(state.asm, 0x28)
  state.asm = a.mov_r64_r64(state.asm, "r12", "rcx")
  state.asm = a.mov_r64_r64(state.asm, "rax", "rcx")
  state.asm = a.mov_gs_qword_28_rax(state.asm)
  lid = _new_label_id(state)
  l_finish = "thentry_finish_" + lid
  l_finalize = "thentry_finalize_" + lid

  state.asm = a.mov_rcx_imm32(state.asm, 0xFFFFFFF5)
  state.asm = a.mov_rax_rip_qword(state.asm, "iat_GetStdHandle")
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_rbx_rax(state.asm)

  state.asm = a.call(state.asm, "fn_gc_native_leave")
  state.asm = a.mov_r64_imm64(state.asm, "r10", t.enc_void())
  state.asm = a.mov_r64_membase_disp(state.asm, "rcx", "r12", THREAD_ARG)
  // The callee parameter slot becomes the precise root before its first poll.
  state.asm = a.mov_membase_disp_imm32(state.asm, "r12", THREAD_ARG, t.enc_void(), true)
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "r12", THREAD_CODE)
  state.asm = a.call_rax(state.asm)
  state.asm = a.mov_membase_disp_r64(state.asm, "r12", THREAD_RESULT, "rax")
  l_not_error = "thentry_not_error_" + lid
  state.asm = a.mov_r64_r64(state.asm, "r11", "rax")
  state.asm = a.and_r64_imm(state.asm, "r11", 7)
  state.asm = a.cmp_r64_imm(state.asm, "r11", c.TAG_PTR)
  state.asm = a.jcc(state.asm, "ne", l_not_error)
  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "rax", 0)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", c.OBJ_STRUCT)
  state.asm = a.jcc(state.asm, "ne", l_not_error)
  state.asm = a.mov_r32_membase_disp(state.asm, "r11d", "rax", 4)
  state.asm = a.cmp_r32_imm(state.asm, "r11d", c.ERROR_STRUCT_ID)
  state.asm = a.jcc(state.asm, "ne", l_not_error)
  state.asm = a.mov_r32_imm32(state.asm, "edx", THREAD_FAILED)
  state.asm = a.jmp(state.asm, l_finalize)
  state.asm = a.mark(state.asm, l_not_error)
  state.asm = a.mov_r32_imm32(state.asm, "edx", THREAD_COMPLETED)
  state.asm = a.mark(state.asm, l_finalize)
  state.asm = a.mov_r32_imm32(state.asm, "eax", THREAD_RUNNING)
  state.asm = a.lock_cmpxchg_membase_disp_r32(state.asm, "r12", THREAD_STATUS, "edx")
  state.asm = a.cmp_r32_imm(state.asm, "eax", THREAD_STOP_REQUESTED)
  state.asm = a.jcc(state.asm, "ne", l_finish)
  state.asm = a.mov_membase_disp_imm32(state.asm, "r12", THREAD_STATUS, THREAD_STOPPED, false)
  state.asm = a.jmp(state.asm, l_finish)
  state.asm = a.mark(state.asm, l_finish)
  state.asm = a.call(state.asm, "tlab_retire_internal")
  state.asm = a.call(state.asm, "fn_gc_managed_exit")
  state = _emit_managed_thread_count_delta(state, -1)
  state.asm = a.xor_r32_r32(state.asm, "eax", "eax")
  state.asm = a.mov_gs_qword_28_rax(state.asm)
  state.asm = a.add_rsp_imm8(state.asm, 0x28)
  state.asm = a.pop_reg(state.asm, "r12")
  state.asm = a.pop_reg(state.asm, "rbx")
  state.asm = a.ret(state.asm)
  return state
end function
