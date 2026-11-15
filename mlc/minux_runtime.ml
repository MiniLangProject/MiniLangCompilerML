/* Copyright 2026 Nils Kopal.
Licensed under the Apache License, Version 2.0.
https://www.apache.org/licenses/LICENSE-2.0 */
// MinUX ELF runtime. The boundary bytes are generated from minux_runtime.S.
package mlc.minux_runtime
import mlc.asm as a
import mlc.data as d
import mlc.tools as t
import mlc.minux_blob as blob
import mlc.sysv_runtime as sysv
import std.string as s

/// Validate the native MinUX import namespace and ABI.
/// @internal
function validate_extern_sigs(signatures)
  symbols = []
  libraries = []
  dependencies = ["libc.so.1"]
  private_symbols = ["minux_sem_init", "minux_sem_wait", "minux_sem_trywait", "minux_sem_post", "minux_sem_getvalue", "minux_sem_destroy", "minux_executable_path"]
  if typeof(signatures) != "array" then return "" end if
  for i = 0 to len(signatures) - 1
    sig = signatures[i]
    library = "" + try(sig.dll)
    sym = "" + try(sig.symbol_name)
    if sym == "" then sym = "" + try(sig.name) end if
    message = ""
    if library == "" or library != s.trim(library) or s.indexOf(library, "/", 0) >= 0 or s.indexOf(library, "\\", 0) >= 0 or s.indexOf(library, "\0", 0) >= 0 then
      message = "MinUX imports require an exact library basename"
    end if
    if library == "libc.so.6" or library == "libpthread.so.0" or library == "libdl.so.2" or library == "libm.so.6" then
      message = "MinUX does not provide the Linux ABI library " + library + "; use MinUX libraries (libc.so.1) and native layouts"
    end if
    if library == "__minilang_minux_runtime" then
      supported = false
      for j = 0 to len(private_symbols) - 1
        if private_symbols[j] == sym then supported = true end if
      end for
      if supported == false then message = "unknown private MinUX runtime symbol: " + sym end if
    else
      found = false
      for j = 0 to len(dependencies) - 1
        if dependencies[j] == library then found = true end if
      end for
      if found == false then dependencies = dependencies + [library] end if
      if len(dependencies) > 15 then message = "MinUX supports at most 15 dependency libraries per executable" end if
    end if
    if len(symbols) > 0 then
      for j = 0 to len(symbols) - 1
        if symbols[j] == sym and libraries[j] != library then
          message = "MinUX global ELF namespace cannot disambiguate symbol " + sym + " from " + libraries[j] + " and " + library
        end if
      end for
    end if
    symbols = symbols + [sym]
    libraries = libraries + [library]
    if message != "" then return "extern function " + sig.qname + ": " + message end if
  end for
  return ""
end function

/// Append a generated runtime fragment and register its relocations.
/// @internal
function _fragment(state, raw, labels, patches)
  base = a.pos(state.asm)
  cursor = 0
  for i = 0 to len(labels) - 1
    item = labels[i]
    if item[1] > cursor then state.asm = a.emit(state.asm, slice(raw, cursor, item[1] - cursor)) end if
    state.asm = a.mark(state.asm, item[0])
    cursor = item[1]
  end for
  if cursor < len(raw) then state.asm = a.emit(state.asm, slice(raw, cursor, len(raw) - cursor)) end if
  for i = 0 to len(patches) - 1
    state.asm = a.add_patch(state.asm, base + patches[i][0], patches[i][1], "rip32")
  end for
  return state
end function

/// Emit the MinUX process entry and argument boundary.
/// @internal
function emit_startup(state)
  if d.data_has_label(state.data, "minux_reserve_cursor") == false then
    state.data = d.data_pad_align(state.data, 8)
    state.data = d.data_add_u64(state.data, "minux_reserve_cursor", 0x4000000000)
  end if
  if d.data_has_label(state.data, "minux_executable_name") == false then
    state.data = d.data_pad_align(state.data, 8)
    state.data = d.data_add_u64(state.data, "minux_executable_name", 0)
  end if
  state = _fragment(state, blob.startup_bytes(), blob.startup_labels(), blob.startup_patches())
  state.asm = a.mark(state.asm, "minux_program_entry")
  return state
end function

/// Assign MinUX imports to their runtime slots.
/// @internal
function prepare_dynamic_imports(state)
  imports = []
  symbols = ["__minux_libc_set_environ", "calloc", "free", "pthread_create", "pthread_join"]
  labels = ["elfiat_runtime_set_environ", "elfiat_runtime_calloc", "elfiat_runtime_free", "elfiat_runtime_pthread_create", "elfiat_runtime_pthread_join"]
  for i = 0 to len(symbols) - 1
    if d.data_has_label(state.data, labels[i]) == false then
      state.data = d.data_pad_align(state.data, 8)
      state.data = d.data_add_u64(state.data, labels[i], 0)
    end if
    rec = d.data_label_record(state.data, labels[i])
    imports = imports + [sysv.DynamicImport("libc.so.1", symbols[i], rec.offset)]
  end for
  xs = state.extern_sigs
  if typeof(xs) == "array" and len(xs) > 0 then
    for i = 0 to len(xs) - 1
      sig = xs[i]
      if typeof(sig) != "struct" then continue end if
      library = "" + try(sig.dll)
      sym = "" + try(sig.symbol_name)
      if sym == "" then sym = "" + try(sig.name) end if
      if library == "" or sym == "" then continue end if
      label = "iat_" + t.extern_library_label_token(library) + "_" + sym
      if d.data_has_label(state.data, label) == false then
        state.data = d.data_pad_align(state.data, 8)
        off = state.data.used
        state.data = d.data_add_u64(state.data, label, 0)
        state.data = d.data_add_abs64_patch(state.data, off, "linux_extern_thunk_" + s.substr(label, 4, len(label) - 4))
      end if
      loader = "elfiat_" + s.substr(label, 4, len(label) - 4)
      if d.data_has_label(state.data, loader) == false then
        state.data = d.data_pad_align(state.data, 8)
        off = state.data.used
        state.data = d.data_add_u64(state.data, loader, 0)
        if library == "__minilang_minux_runtime" then state.data = d.data_add_abs64_patch(state.data, off, sym) end if
      end if
      if library == "__minilang_minux_runtime" then continue end if
      rec = d.data_label_record(state.data, loader)
      duplicate = false
      for j = 0 to len(imports) - 1
        if imports[j].library == library and imports[j].symbol_name == sym and imports[j].slot_offset == rec.offset then duplicate = true end if
      end for
      if duplicate == false then imports = imports + [sysv.DynamicImport(library, sym, rec.offset)] end if
    end for
  end if
  return sysv.DynamicImportsResult(state, imports)
end function

/// Emit MinUX services and shared SysV native marshalling.
/// @internal
function emit_runtime(state)
  names = ["GetStdHandle", "ReadFile", "WriteFile", "WriteConsoleW", "MultiByteToWideChar", "SetConsoleOutputCP", "FreeConsole", "ExitProcess", "VirtualAlloc", "VirtualFree", "GetCommandLineW", "LocalFree", "WideCharToMultiByte", "CreateThread", "WaitForSingleObject", "CloseHandle", "Sleep", "InitializeCriticalSection", "EnterCriticalSection", "LeaveCriticalSection", "_gcvt", "fmod", "CommandLineToArgvW"]
  for i = 0 to len(names) - 1
    slot = "iat_" + names[i]
    if d.data_has_label(state.data, slot) then continue end if
    state.data = d.data_pad_align(state.data, 8)
    off = state.data.used
    state.data = d.data_add_u64(state.data, slot, 0)
    state.data = d.data_add_abs64_patch(state.data, off, "minux_" + names[i])
  end for
  prepared = prepare_dynamic_imports(state)
  state = prepared.state
  state = _fragment(state, blob.runtime_bytes(), blob.runtime_labels(), blob.runtime_patches())
  return sysv.emit_extern_thunks(state, true)
end function
