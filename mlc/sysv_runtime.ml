/* Copyright 2026 Nils Kopal.
Licensed under the Apache License, Version 2.0.
https://www.apache.org/licenses/LICENSE-2.0 */
// Shared MiniLang-to-SysV native call bridge for ELF output platforms.
package mlc.sysv_runtime
import mlc.asm as a
import mlc.tools as t
import std.string as s

/// Represents dynamic import.
struct DynamicImport
  /// Library associated with `DynamicImport`.
  library,
  /// Symbol name associated with `DynamicImport`.
  symbol_name,
  /// Slot offset associated with `DynamicImport`.
  slot_offset,
end struct

/// Represents dynamic imports result.
struct DynamicImportsResult
  /// State associated with `DynamicImportsResult`.
  state,
  /// Imports associated with `DynamicImportsResult`.
  imports,
end struct

/// Represents thunk destination.
struct ThunkDestination
  /// Kind associated with `ThunkDestination`.
  kind,
  /// Value associated with `ThunkDestination`.
  value,
end struct

/// Emit extern param type for the Linux x64 runtime.
/// @internal
function _extern_param_type(param)
  if typeof(param) == "struct" then
    if typeof(try(param.is_out)) == "bool" and param.is_out then return "pointer" end if
    value = "" + try(param.ty)
    if value == "" then value = "" + try(param.type) end if
    if value == "" then value = "" + try(param.abi_ty) end if
    return s.toLowerAscii(s.trim(value))
  end if
  return s.toLowerAscii(s.trim("" + param))
end function

/// Emit array has for the Linux x64 runtime.
/// @internal
function _array_has(values, wanted)
  if len(values) <= 0 then return false end if
  for i = 0 to len(values) - 1
    if values[i] == wanted then return true end if
  end for
  return false
end function

/// Translate MiniLang's stable Win64-like native ABI to SysV.
/// @internal
function emit_extern_thunks(state, eager)
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
    iat_label = "iat_" + t.extern_library_label_token(library) + "_" + sym
    thunk_label = "linux_extern_thunk_" + s.substr(iat_label, 4, len(iat_label) - 4)
    if _array_has(emitted, thunk_label) then continue end if
    emitted = emitted + [thunk_label]
    loader_label = "elfiat_" + s.substr(iat_label, 4, len(iat_label) - 4)
    suffix = s.substr(iat_label, 4, len(iat_label) - 4)
    library_label = "linux_extern_library_" + suffix
    symbol_label = "linux_extern_symbol_" + suffix
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
    loader_handle_offset = xmm_save_base + 10 * 16
    frame_min = loader_handle_offset + 8
    frame = frame_min
    while frame % 16 != 8 frame = frame + 1 end while

    asm = a.mark(asm, thunk_label)
    fragment = a.newCodegenAsmBuilder()
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

    external_patches = []
    resolve_retry_label = thunk_label + "_resolve_retry"
    resolve_claim_label = thunk_label + "_resolve_claim"
    resolve_wait_label = thunk_label + "_resolve_wait"
    resolve_symbol_failed_label = thunk_label + "_resolve_symbol_failed"
    resolve_publish_failed_label = thunk_label + "_resolve_publish_failed"
    resolved_label = thunk_label + "_resolved"
    resolve_failed_label = thunk_label + "_resolve_failed"
    epilogue_label = thunk_label + "_epilogue"
    if eager == false then
      // Resolve through the declared library's handle. ELF symbol relocations
      // alone use one process-global namespace and cannot distinguish duplicate
      // symbol names from different shared libraries. The shared slot uses
      // 0=unresolved, 1=resolving, 2=failed and any other value as the pointer;
      // one atomic owner performs libdl work while concurrent callers wait.
      fragment = a.mark(fragment, resolve_retry_label)
      fragment = a.emit(fragment, fromHex("488b05"))
      external_patches = external_patches + [[a.pos(fragment), loader_label]]
      fragment = a.emit(fragment, bytes(4, 0))
      fragment = a.test_r64_r64(fragment, "rax", "rax")
      fragment = a.jcc(fragment, "e", resolve_claim_label)
      fragment = a.cmp_r64_imm(fragment, "rax", 1)
      fragment = a.jcc(fragment, "e", resolve_wait_label)
      fragment = a.cmp_r64_imm(fragment, "rax", 2)
      fragment = a.jcc(fragment, "e", resolve_failed_label)
      fragment = a.jmp(fragment, resolved_label)
      fragment = a.mark(fragment, resolve_wait_label)
      fragment = a.emit(fragment, bytes([0xF3, 0x90]))
      fragment = a.jmp(fragment, resolve_retry_label)
      fragment = a.mark(fragment, resolve_claim_label)
      fragment = a.emit(fragment, bytes([0x4C, 0x8D, 0x1D]))
      external_patches = external_patches + [[a.pos(fragment), loader_label]]
      fragment = a.emit(fragment, bytes(4, 0))
      fragment = a.mov_r32_imm32(fragment, "edx", 1)
      fragment = a.lock_cmpxchg_membase_disp_r64(fragment, "r11", 0, "rdx")
      fragment = a.jcc(fragment, "ne", resolve_retry_label)
      fragment = a.emit(fragment, fromHex("488d05"))
      external_patches = external_patches + [[a.pos(fragment), library_label]]
      fragment = a.emit(fragment, bytes(4, 0))
      fragment = a.mov_r64_r64(fragment, "rdi", "rax")
      fragment = a.mov_r32_imm32(fragment, "esi", 2)
      fragment = a.emit(fragment, fromHex("ff15"))
      external_patches = external_patches + [[a.pos(fragment), "elfiat_runtime_dlopen"]]
      fragment = a.emit(fragment, bytes(4, 0))
      fragment = a.test_r64_r64(fragment, "rax", "rax")
      fragment = a.jcc(fragment, "e", resolve_publish_failed_label)
      fragment = a.mov_membase_disp_r64(fragment, "rsp", loader_handle_offset, "rax")
      fragment = a.mov_r64_r64(fragment, "rdi", "rax")
      fragment = a.emit(fragment, fromHex("488d05"))
      external_patches = external_patches + [[a.pos(fragment), symbol_label]]
      fragment = a.emit(fragment, bytes(4, 0))
      fragment = a.mov_r64_r64(fragment, "rsi", "rax")
      fragment = a.emit(fragment, fromHex("ff15"))
      external_patches = external_patches + [[a.pos(fragment), "elfiat_runtime_dlsym"]]
      fragment = a.emit(fragment, bytes(4, 0))
      fragment = a.test_r64_r64(fragment, "rax", "rax")
      fragment = a.jcc(fragment, "e", resolve_symbol_failed_label)
      fragment = a.emit(fragment, fromHex("488905"))
      external_patches = external_patches + [[a.pos(fragment), loader_label]]
      fragment = a.emit(fragment, bytes(4, 0))
      fragment = a.mark(fragment, resolved_label)

    end if

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
    // Carry resolution failure to the caller in CF while retaining the native
    // result in RAX/XMM0. The common epilogue performs the flag-setting shift.
    fragment = a.mov_r32_imm32(fragment, "r11d", 0)
    if eager == false then
      fragment = a.jmp(fragment, epilogue_label)
      fragment = a.mark(fragment, resolve_symbol_failed_label)
      fragment = a.mov_r64_membase_disp(fragment, "rdi", "rsp", loader_handle_offset)
      fragment = a.emit(fragment, bytes([0xFF, 0x15]))
      external_patches = external_patches + [[a.pos(fragment), "elfiat_runtime_dlclose"]]
      fragment = a.emit(fragment, bytes(4, 0))
      fragment = a.mark(fragment, resolve_publish_failed_label)
      fragment = a.mov_r32_imm32(fragment, "eax", 2)
      fragment = a.emit(fragment, fromHex("488905"))
      external_patches = external_patches + [[a.pos(fragment), loader_label]]
      fragment = a.emit(fragment, bytes(4, 0))
      fragment = a.jmp(fragment, resolve_failed_label)
      fragment = a.mark(fragment, resolve_failed_label)
      fragment = a.mov_r32_imm32(fragment, "r11d", 1)
      fragment = a.mark(fragment, epilogue_label)

    end if

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
    fragment = a.shr_r32_imm8(fragment, "r11d", 1)
    fragment = a.ret(fragment)
    // The resolver path above introduces forward local branches. Fold those
    // fragment-owned patches before copying its bytes into the parent builder;
    // materializing alone would leave zero displacements in every thunk.
    folded_fragment = a.materialize_and_fold_local_patches(fragment)
    fragment = folded_fragment[0]
    fragment_base = a.pos(asm)
    asm = a.emit(asm, fragment.buf)
    if len(external_patches) > 0 then
      for pi = 0 to len(external_patches) - 1
        asm = a.add_patch(asm, fragment_base + external_patches[pi][0], external_patches[pi][1], "rip32")
      end for
    end if
    asm = a.add_patch(asm, fragment_base + call_patch_offset, loader_label, "rip32")
  end for
  state.asm = asm
  return state
end function
