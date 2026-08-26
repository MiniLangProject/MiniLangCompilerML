// Linux-x64 startup and syscall-backed native runtime thunks.
package mlc.linux_runtime
import mlc.asm as a
import mlc.data as d
import std.string as s

struct RuntimeLabel
  name,
  offset,
end struct

struct DynamicImport
  library,
  symbol_name,
  slot_offset,
end struct

struct DynamicImportsResult
  state,
  imports,
end struct

struct ThunkDestination
  kind,
  value,
end struct

function _extern_dll_base(dll)
  x = s.toLowerAscii("" + dll)
  x = s.replaceAll(x, "\\", "/")
  parts = s.split(x, "/")
  if len(parts) > 0 then x = parts[len(parts) - 1] end if
  if s.endsWith(x, ".dll") then x = s.substr(x, 0, len(x) - 4) end if
  x = s.replaceAll(x, "-", "_")
  x = s.replaceAll(x, " ", "_")
  x = s.replaceAll(x, ".", "_")
  while s.contains(x, "__") x = s.replaceAll(x, "__", "_") end while
  if x == "" then x = "dll" end if
  return x
end function

// Allocate writable slots that the Linux dynamic loader fills for externs.
function prepare_dynamic_imports(state)
  imports = []
  // Runtime-created workers must go through pthreads so every worker owns the
  // libc TLS needed by malloc, recursive mutexes, OpenSSL and other providers.
  runtime_libraries = ["libpthread.so.0", "libpthread.so.0"]
  runtime_symbols = ["pthread_create", "pthread_join"]
  runtime_labels = ["elfiat_runtime_pthread_create", "elfiat_runtime_pthread_join"]
  for i = 0 to len(runtime_symbols) - 1
    loader_label = runtime_labels[i]
    if d.data_has_label(state.data, loader_label) == false then
      state.data = d.data_pad_align(state.data, 8)
      state.data = d.data_add_u64(state.data, loader_label, 0)
    end if
    rec = d.data_label_record(state.data, loader_label)
    imports = imports + [DynamicImport(runtime_libraries[i], runtime_symbols[i], rec.offset)]
  end for
  xs = state.extern_sigs
  if typeof(xs) != "array" or len(xs) <= 0 then return DynamicImportsResult(state, imports) end if
  for i = 0 to len(xs) - 1
    sig = xs[i]
    if typeof(sig) != "struct" then continue end if
    library = "" + try(sig.dll)
    sym = "" + try(sig.symbol_name)
    if sym == "" then sym = "" + try(sig.name) end if
    if library == "" or sym == "" then continue end if
    label = "iat_" + _extern_dll_base(library) + "_" + sym
    if d.data_has_label(state.data, label) == false then
      state.data = d.data_pad_align(state.data, 8)
      patch_offset = state.data.used
      state.data = d.data_add_u64(state.data, label, 0)
      state.data = d.data_add_abs64_patch(state.data, patch_offset, "linux_extern_thunk_" + s.substr(label, 4, len(label) - 4))
    end if
    loader_label = "elfiat_" + s.substr(label, 4, len(label) - 4)
    if d.data_has_label(state.data, loader_label) == false then
      state.data = d.data_pad_align(state.data, 8)
      state.data = d.data_add_u64(state.data, loader_label, 0)
    end if
    rec = d.data_label_record(state.data, loader_label)
    duplicate = false
    if len(imports) > 0 then
      for j = 0 to len(imports) - 1
        old = imports[j]
        if old.library == library and old.symbol_name == sym and old.slot_offset == rec.offset then duplicate = true end if
      end for
    end if
    if duplicate == false then imports = imports + [DynamicImport(library, sym, rec.offset)] end if
  end for
  return DynamicImportsResult(state, imports)
end function

function emit_startup(state)
  if d.data_has_label(state.data, "linux_sigpipe_action") == false then
    // Linux kernel_sigaction: handler=SIG_IGN, flags/restorer/mask=0.
    state.data = d.data_add_bytes(state.data, "linux_sigpipe_action", fromHex("0100000000000000000000000000000000000000000000000000000000000000"))
  end if
  state.asm = a.mark(state.asm, "_start")
  state.asm = a.mov_r64_membase_disp(state.asm, "rax", "rsp", 0)
  state.asm = a.mov_rip_dword_eax(state.asm, "ml_argc")
  state.asm = a.lea_r64_membase_disp(state.asm, "rax", "rsp", 8)
  state.asm = a.mov_rip_qword_rax(state.asm, "ml_argvw")
  state.asm = a.mov_r64_r64(state.asm, "r11", "rsp")
  state.asm = a.mov_rip_qword_r11(state.asm, "linux_initial_rsp")
  // Convert peer-closed socket writes into EPIPE instead of terminating the
  // process with SIGPIPE. This covers both std.net and native TLS providers.
  state.asm = a.mov_r32_imm32(state.asm, "edi", 13)
  state.asm = a.lea_rax_rip(state.asm, "linux_sigpipe_action")
  state.asm = a.mov_r64_r64(state.asm, "rsi", "rax")
  state.asm = a.xor_r32_r32(state.asm, "edx", "edx")
  state.asm = a.mov_r32_imm32(state.asm, "r10d", 8)
  state.asm = a.mov_r32_imm32(state.asm, "eax", 13)
  state.asm = a.emit(state.asm, bytes([0x0F, 0x05]))
  state.asm = a.mov_r32_imm32(state.asm, "edi", 0x1001)
  state.asm = a.lea_rax_rip(state.asm, "linux_gs_area")
  state.asm = a.mov_r64_r64(state.asm, "rsi", "rax")
  state.asm = a.mov_r32_imm32(state.asm, "eax", 158)
  state.asm = a.emit(state.asm, bytes([0x0F, 0x05]))
  state.asm = a.test_r64_r64(state.asm, "rax", "rax")
  state.asm = a.jcc(state.asm, "e", "linux_gs_ready")
  state.asm = a.mov_r32_imm32(state.asm, "eax", 60)
  state.asm = a.mov_r32_imm32(state.asm, "edi", 127)
  state.asm = a.emit(state.asm, bytes([0x0F, 0x05, 0x0F, 0x0B]))
  state.asm = a.mark(state.asm, "linux_gs_ready")
  state.asm = a.sub_rsp_imm8(state.asm, 8)
  state.asm = a.jmp(state.asm, "linux_program_entry")
  state.asm = a.mark(state.asm, "linux_program_entry")
  return state
end function

function _runtime_labels()
  return [
    RuntimeLabel("linux_GetStdHandle", 0), RuntimeLabel("linux_std_in", 24), RuntimeLabel("linux_std_out", 27),
    RuntimeLabel("linux_WriteFile", 33), RuntimeLabel("linux_write_fail", 73), RuntimeLabel("linux_write_done", 75),
    RuntimeLabel("linux_ReadFile", 78), RuntimeLabel("linux_read_fail", 115), RuntimeLabel("linux_read_done", 117),
    RuntimeLabel("linux_ExitProcess", 120), RuntimeLabel("linux_VirtualAlloc", 131), RuntimeLabel("linux_valloc_res_prot", 184),
    RuntimeLabel("linux_valloc_commit", 229), RuntimeLabel("linux_valloc_fail", 267), RuntimeLabel("linux_VirtualFree", 270),
    RuntimeLabel("linux_Sleep", 307), RuntimeLabel("linux_sleep_poll", 329), RuntimeLabel("linux_sleep_done", 342),
    RuntimeLabel("linux_InitializeCriticalSection", 345), RuntimeLabel("linux_EnterCriticalSection", 352),
    RuntimeLabel("linux_cs_lock_loop", 389), RuntimeLabel("linux_cs_lock_done", 418), RuntimeLabel("linux_LeaveCriticalSection", 431),
    RuntimeLabel("linux_cs_leave_release", 473), RuntimeLabel("linux_cs_leave_done", 496), RuntimeLabel("linux_CreateThread", 497),
    RuntimeLabel("linux_pthread_start", 809), RuntimeLabel("linux_thread_create_cleanup", 869), RuntimeLabel("linux_thread_create_fail", 884),
    RuntimeLabel("linux_WaitForSingleObject", 978), RuntimeLabel("linux_thread_wait_loop", 1070), RuntimeLabel("linux_thread_wait_join", 1113),
    RuntimeLabel("linux_thread_wait_ok", 1155), RuntimeLabel("linux_thread_wait_failed", 1162), RuntimeLabel("linux_thread_wait_timeout", 1172),
    RuntimeLabel("linux_thread_wait_done", 1177), RuntimeLabel("linux_CloseHandle", 1264), RuntimeLabel("linux_thread_close_unmap", 1397),
    RuntimeLabel("linux_thread_close_fail", 1431), RuntimeLabel("linux_thread_close_done", 1433), RuntimeLabel("linux_fmod", 1518),
    RuntimeLabel("linux__gcvt", 1541), RuntimeLabel("linux_gcvt_abs", 1600), RuntimeLabel("linux_gcvt_int_loop", 1630),
    RuntimeLabel("linux_gcvt_reverse_loop", 1670), RuntimeLabel("linux_gcvt_int_done", 1699), RuntimeLabel("linux_gcvt_frac_loop", 1761),
    RuntimeLabel("linux_gcvt_trim", 1803), RuntimeLabel("linux_gcvt_terminate", 1821), RuntimeLabel("linux_SetConsoleOutputCP", 1841),
    RuntimeLabel("linux_FreeConsole", 1847), RuntimeLabel("linux_LocalFree", 1853), RuntimeLabel("linux_GetCommandLineW", 1859),
    RuntimeLabel("linux_CommandLineToArgvW", 1862), RuntimeLabel("linux_WriteConsoleW", 1865), RuntimeLabel("linux_MultiByteToWideChar", 1868),
    RuntimeLabel("linux_WideCharToMultiByte", 1871)
  ]
end function

function _runtime_blob()
  // Stable base blob for the syscall helpers surrounding the thread runtime.
  // emit_runtime replaces its legacy raw-clone thread range with the pthread
  // implementation below. Sleep(0) and contended runtime-monitor acquisition
  // use sched_yield so a collector cannot starve the mutator whose safepoint or
  // monitor release it is awaiting.
  return fromHex("83f9f60f840f00000083f9f50f8409000000b802000000c333c0c3b801000000c35756488bf9488bf2418bd0b8010000000f054885c00f880d000000418901b801000000e90200000033c05e5fc35756488bf9488bf2418bd033c00f054885c00f880d000000418901b801000000e90200000033c05e5fc38bf9b83c0000000f050f0b4585c0418bc081e0002000000f84500000005756488bf9488bf2418bc081e000100000ba0000000085c00f8405000000ba0300000041ba2200000049c7c0ffffffff4533c9b8090000000f054c8bd85e5f498bc34881f801f0ffff0f8327000000c35756488bf9488bf2ba03000000b80a0000000f054c8bd85e5f4d85db0f8504000000488bc1c333c0c35756488bf9488bf2ba04000000b81c0000000f0533d2b80a0000000f055e5fb801000000c3575685c90f850c000000b8180000000f05e90d00000033ff33f68bd1b8070000000f055e5fc3c70100000000c34c8bd1b8ba0000000f05448bc8418b4204413bc10f850b000000418b4208ffc041894208c333c0ba01000000f0410fb1120f840b000000f390b8180000000f05ebe345894a0441c7420801000000c34c8bd1b8ba0000000f05418b52043bd00f852b000000418b520883fa010f8e07000000ffca41895208c341c742080000000041c742040000000041c70200000000c3415441554156415757564d8be84d8bf14c8b7c246033ffbe00001000ba0300000041ba2200000049c7c0ffffffff4533c9b8090000000f054881f801f0ffff0f83800000004c8be0498db42400001000bf000f3501498bd44d8bd44533c0b8380000000f054885c00f841d0000004885c00f883f0000004189074d8bdc5e5f415f415e415d415c498bc3c3498d442440488bf0bf01100000b89e0000000f054883ec20498bce498bc5ffd0b83c00000033ff0f050f0b498bfcbe00001000b80b0000000f055e5f415f415e415d415c33c0c3415441554c8be1448bea418b042485c00f841e0000004585ed0f841c000000b901000000e847feffff4183fdff74db41ffcdebd633c0e905000000b802010000415d415cc35756488bf9be00001000b80b0000000f055e5f4833c04885c0b801000000c3f20f10d0f20f5ed1660f3a0bd203f20f59d1f20f5cc2c353415441554156415756574d8be04d8be866480f7ec04c8bd849c1eb3f48c1e00148c1e80166480f6ec04d85db0f840800000041c645002d49ffc5f24c0f2cf04d8bfd4d85f60f850d00000041c645003049ffc5e945000000498bc64899bb0a00000048f7f383c2304188550049ffc54c8bf04d85f675e14d8bd74d8bdd49ffcb4d3bd30f8314000000418a02418a1341881241880349ffc249ffcbebe3f24c0f2cf0f2490f2acef20f5cc1b840420f00f2480f2ac8f20f59c1660f3a0bc000f24c0f2cf04d85f60f844a00000041c645002e49ffc541bfa0860100498bc6489949f7f783c0304188450049ffc54c8bf2498bc74899bb0a00000048f7f34c8bf84d85ff75d6418a45ff80f8300f850500000049ffcdebee41c6450000498bc45f5e415f415e415d415c5bc3b801000000c3b801000000c3b801000000c333c0c333c0c333c0c333c0c333c0c3")
end function

// Generated pthread-backed replacement for the legacy CreateThread through
// CloseHandle portion of _runtime_blob. Internal branches are pre-resolved;
// the three dynamic pthread calls are registered as RIP patches by emit_runtime.
function _pthread_runtime_blob()
  return fromHex("53415441554156415757564881eca0000000f30f7f3424f30f7f7c2410f3440f7f442420f3440f7f4c2430f3440f7f542440f3440f7f5c2450f3440f7f642460f3440f7f6c2470f3440f7fb42480000000f3440f7fbc24900000004d8be84d8bf14c8bbc240801000033ffbe00100000ba0300000041ba2200000049c7c0ffffffff4533c9b8090000000f054881f801f0ffff0f83ea0000004c8be041c7442408010000004d896c24104d89742418498bfc33f6488d057d000000488bd0498bccff150000000085c00f85a5000000498b04244189074d8bdcf30f6f3424f30f6f7c2410f3440f6f442420f3440f6f4c2430f3440f6f542440f3440f6f5c2450f3440f6f642460f3440f6f6c2470f3440f6fb42480000000f3440f6fbc24900000004881c4a00000005e5f415f415e415d415c5b498bc3c341544883ec204c8be7498d442440488bf0bf01100000b89e0000000f05498b4c2418498b442410ffd041c7442408000000004833c04883c420415cc3498bfcbe00100000b80b0000000f05f30f6f3424f30f6f7c2410f3440f6f442420f3440f6f4c2430f3440f6f542440f3440f6f5c2450f3440f6f642460f3440f6f6c2470f3440f6fb42480000000f3440f6fbc24900000004881c4a00000005e5f415f415e415d415c5b33c0c34154415541564881eca0000000f30f7f3424f30f7f7c2410f3440f7f442420f3440f7f4c2430f3440f7f542440f3440f7f5c2450f3440f7f642460f3440f7f6c2470f3440f7fb42480000000f3440f7fbc24900000004c8be1448bea418b44240885c00f841e0000004585ed0f8450000000b901000000e8e5fcffff4183fdff74da41ffcdebd5418b44242085c00f851d000000498b3c2433f6ff150000000085c00f851000000041c74424200100000033c0e90f000000b8ffffffffe905000000b802010000f30f6f3424f30f6f7c2410f3440f6f442420f3440f6f4c2430f3440f6f542440f3440f6f5c2450f3440f6f642460f3440f6f6c2470f3440f6fb42480000000f3440f6fbc24900000004881c4a0000000415e415d415cc3415457564881eca0000000f30f7f3424f30f7f7c2410f3440f7f442420f3440f7f4c2430f3440f7f542440f3440f7f5c2450f3440f7f642460f3440f7f6c2470f3440f7fb42480000000f3440f7fbc24900000004c8be1418b44240885c00f8543000000418b44242085c00f8514000000498b3c2433f6ff150000000085c00f8522000000498bfcbe00100000b80b0000000f054885c00f850a000000b801000000e90200000033c0f30f6f3424f30f6f7c2410f3440f6f442420f3440f6f4c2430f3440f6f542440f3440f6f5c2450f3440f6f642460f3440f6f6c2470f3440f6fb42480000000f3440f6fbc24900000004881c4a00000005e5f415cc3")
end function

function _extern_param_type(param)
  if typeof(param) == "struct" then
    value = "" + try(param.ty)
    if value == "" then value = "" + try(param.type) end if
    if value == "" then value = "" + try(param.abi_ty) end if
    return s.toLowerAscii(s.trim(value))
  end if
  return s.toLowerAscii(s.trim("" + param))
end function

function _array_has(values, wanted)
  if len(values) <= 0 then return false end if
  for i = 0 to len(values) - 1
    if values[i] == wanted then return true end if
  end for
  return false
end function

// Translate MiniLang's stable Win64-like native ABI to Linux SysV.
function _emit_extern_thunks(state)
  asm = state.asm
  win_regs = ["rcx", "rdx", "r8", "r9"]
  sysv_regs = ["rdi", "rsi", "rdx", "rcx", "r8", "r9"]
  sysv_xregs = ["xmm0", "xmm1", "xmm2", "xmm3", "xmm4", "xmm5", "xmm6", "xmm7"]
  emitted = []
  xs = state.extern_sigs
  if typeof(xs) != "array" or len(xs) <= 0 then return state end if

  for xi = 0 to len(xs) - 1
    sig = xs[xi]
    if typeof(sig) != "struct" then continue end if
    library = "" + try(sig.dll)
    sym = "" + try(sig.symbol_name)
    if sym == "" then sym = "" + try(sig.name) end if
    if library == "" or sym == "" then continue end if
    iat_label = "iat_" + _extern_dll_base(library) + "_" + sym
    thunk_label = "linux_extern_thunk_" + s.substr(iat_label, 4, len(iat_label) - 4)
    if _array_has(emitted, thunk_label) then continue end if
    emitted = emitted + [thunk_label]
    loader_label = "elfiat_" + s.substr(iat_label, 4, len(iat_label) - 4)
    params = try(sig.params)
    if typeof(params) != "array" then params = [] end if

    int_index = 0
    xmm_index = 0
    destinations = []
    stack_count = 0
    if len(params) > 0 then
      for i = 0 to len(params) - 1
        is_double = _extern_param_type(params[i]) == "double"
        if is_double and xmm_index < len(sysv_xregs) then
          destinations = destinations + [ThunkDestination("xmm", sysv_xregs[xmm_index])]
          xmm_index = xmm_index + 1
        else if is_double == false and int_index < len(sysv_regs) then
          destinations = destinations + [ThunkDestination("reg", sysv_regs[int_index])]
          int_index = int_index + 1
        else
          destinations = destinations + [ThunkDestination("stack", stack_count)]
          stack_count = stack_count + 1
        end if
      end for
    end if

    native_base = stack_count * 8
    xmm_save_base = native_base + len(params) * 8
    frame_min = xmm_save_base + 10 * 16
    frame = frame_min
    while frame % 16 != 8 frame = frame + 1 end while

    asm = a.mark(asm, thunk_label)
    fragment = a.newAsmBuilder()
    call_patch_offset = -1
    fragment = a.push_reg(fragment, "rdi")
    fragment = a.push_reg(fragment, "rsi")
    if frame <= 0x7F then
      fragment = a.sub_rsp_imm8(fragment, frame)
    else
      fragment = a.sub_rsp_imm32(fragment, frame)
    end if

    if len(params) > 0 then
      for i = 0 to len(params) - 1
        destination = native_base + i * 8
        if i < 4 then
          if _extern_param_type(params[i]) == "double" then
            fragment = a.movsd_membase_disp_xmm(fragment, "rsp", destination, "xmm" + i)
          else
            fragment = a.mov_membase_disp_r64(fragment, "rsp", destination, win_regs[i])
          end if
        else
          original_stack = frame + 0x38 + (i - 4) * 8
          fragment = a.mov_r64_membase_disp(fragment, "rax", "rsp", original_stack)
          fragment = a.mov_membase_disp_r64(fragment, "rsp", destination, "rax")
        end if
      end for
    end if

    for i = 6 to 15
      fragment = a.movdqu_membase_disp_xmm(fragment, "rsp", xmm_save_base + (i - 6) * 16, "xmm" + i)
    end for

    if len(destinations) > 0 then
      for i = 0 to len(destinations) - 1
        item = destinations[i]
        source = native_base + i * 8
        if item.kind == "xmm" then
          fragment = a.movsd_xmm_membase_disp(fragment, "" + item.value, "rsp", source)
        else if item.kind == "reg" then
          fragment = a.mov_r64_membase_disp(fragment, "" + item.value, "rsp", source)
        else
          fragment = a.mov_r64_membase_disp(fragment, "rax", "rsp", source)
          fragment = a.mov_membase_disp_r64(fragment, "rsp", item.value * 8, "rax")
        end if
      end for
    end if
    fragment = a.mov_r32_imm32(fragment, "eax", xmm_index)
    // Encode the one unresolved loader-slot call locally, then transfer its
    // relocation after the finished fragment is appended to the main image.
    call_patch_offset = a.pos(fragment) + 2
    fragment = a.emit(fragment, bytes([0xFF, 0x15, 0, 0, 0, 0]))

    for i = 6 to 15
      fragment = a.movdqu_xmm_membase_disp(fragment, "xmm" + i, "rsp", xmm_save_base + (i - 6) * 16)
    end for
    if frame <= 0x7F then
      fragment = a.add_rsp_imm8(fragment, frame)
    else
      fragment = a.add_rsp_imm32(fragment, frame)
    end if
    fragment = a.pop_reg(fragment, "rsi")
    fragment = a.pop_reg(fragment, "rdi")
    fragment = a.ret(fragment)
    fragment = a.materialize(fragment)
    fragment_base = a.pos(asm)
    asm = a.emit(asm, fragment.buf)
    asm = a.add_patch(asm, fragment_base + call_patch_offset, loader_label, "rip32")
  end for
  state.asm = asm
  return state
end function

function emit_runtime(state)
  names = ["GetStdHandle", "ReadFile", "WriteFile", "WriteConsoleW", "MultiByteToWideChar", "SetConsoleOutputCP", "FreeConsole", "ExitProcess", "VirtualAlloc", "VirtualFree", "GetCommandLineW", "LocalFree", "WideCharToMultiByte", "CreateThread", "WaitForSingleObject", "CloseHandle", "Sleep", "InitializeCriticalSection", "EnterCriticalSection", "LeaveCriticalSection", "_gcvt", "fmod", "CommandLineToArgvW"]
  for i = 0 to len(names) - 1
    slot = "iat_" + names[i]
    if d.data_has_label(state.data, slot) then continue end if
    state.data = d.data_pad_align(state.data, 8)
    off = state.data.used
    state.data = d.data_add_u64(state.data, slot, 0)
    state.data = d.data_add_abs64_patch(state.data, off, "linux_" + names[i])
  end for
  prepared = prepare_dynamic_imports(state)
  state = prepared.state

  base_blob = _runtime_blob()
  // Keep the stable syscall helpers before/after the thread range. Patch the
  // ExitProcess syscall number (60 -> 231) and splice in the pthread runtime.
  blob = slice(base_blob, 0, 123) + fromHex("e7000000") + slice(base_blob, 127, 370)
  blob = blob + _pthread_runtime_blob() + slice(base_blob, 807, len(base_blob) - 807)
  labels = _runtime_labels()
  blob_base = a.pos(state.asm)
  cursor = 0
  for i = 0 to len(labels) - 1
    item = labels[i]
    if item.offset > cursor then
      state.asm = a.emit(state.asm, slice(blob, cursor, item.offset - cursor))
    end if
    state.asm = a.mark(state.asm, item.name)
    cursor = item.offset
  end for
  if cursor < len(blob) then state.asm = a.emit(state.asm, slice(blob, cursor, len(blob) - cursor)) end if
  // These RIP-relative slots are resolved after the ELF data layout is known.
  state.asm = a.add_patch(state.asm, blob_base + 692, "elfiat_runtime_pthread_create", "rip32")
  state.asm = a.add_patch(state.asm, blob_base + 1134, "elfiat_runtime_pthread_join", "rip32")
  state.asm = a.add_patch(state.asm, blob_base + 1385, "elfiat_runtime_pthread_join", "rip32")
  state = _emit_extern_thunks(state)
  return state
end function
