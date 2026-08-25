import std.fs as fs
import std.string as s

extern function _wsystem(cmd as wstr) from "msvcrt.dll" returns int

function _q(x)
  if typeof(x) != "string" then return "\"\"" end if
  return "\"" + x + "\""
end function

function _dirname(path)
  if typeof(path) != "string" then return "." end if
  i = len(path) - 1
  while i >= 0
    ch = path[i]
    if ch == "\\" or ch == "/" then
      if i <= 0 then return "." end if
      return s.substr(path, 0, i)
    end if
    i = i - 1
  end while
  return "."
end function

function _path_join(a, b)
  if typeof(a) != "string" or a == "" then return b end if
  if typeof(b) != "string" or b == "" then return a end if
  last = a[len(a) - 1]
  if last == "\\" or last == "/" then
    return a + b
  end if
  return a + "\\" + b
end function

function _repo_root_hint(compiler_path)
  if fs.exists("tests\\language_suite.ml") then
    return "."
  end if
  if fs.exists("language_suite.ml") and fs.exists("ns_import_tests\\testlib.ml") then
    return ".."
  end if
  return _dirname(compiler_path)
end function

function _join_extra_args(args, start_idx)
  joined = ""
  if typeof(args) != "array" then return joined end if
  if start_idx < 0 then start_idx = 0 end if
  if start_idx >= len(args) then return joined end if
  for i = start_idx to len(args) - 1
    if joined != "" then joined = joined + " " end if
    joined = joined + _q(args[i])
  end for
  return joined
end function

function _run_compile(compiler_path, src_abs, out_abs, include_root, extra_flags, mode_flags)
  cmd = "call " + _q(compiler_path) + " " + _q(src_abs) + " " + _q(out_abs) + " -I " + _q(include_root)
  if typeof(extra_flags) == "string" and extra_flags != "" then
    cmd = cmd + " " + extra_flags
  end if
  if typeof(mode_flags) == "string" and mode_flags != "" then
    cmd = cmd + " " + mode_flags
  end if
  return _wsystem(cmd)
end function

function _run_exe(path_abs, run_flags)
  cmd = "call " + _q(path_abs)
  if typeof(run_flags) == "string" and run_flags != "" then
    cmd = cmd + " " + run_flags
  end if
  return _wsystem(cmd)
end function

function _starts_with(text, pref)
  if typeof(text) != "string" or typeof(pref) != "string" then return false end if
  if len(pref) > len(text) then return false end if
  return s.substr(text, 0, len(pref)) == pref
end function

function _test_adv(compiler_path, repo_root, name, src_rel, mode, local_flags, run_flags)
  src_abs = _path_join(repo_root, src_rel)
  out_abs = _path_join(repo_root, "tests\\_rt_" + name + ".exe")

  if fs.exists(src_abs) == false then
    print "[FAIL] " + name + " (missing source: " + src_abs + ")"
    return false
  end if

  if fs.exists(out_abs) then
    fs.delete(out_abs)
  end if

  rc_compile = _run_compile(compiler_path, src_abs, out_abs, repo_root, "", local_flags)

  if mode == "compile_fail" then
    if rc_compile != 0 then
      print "[PASS] " + name + " (expected compile failure)"
      return true
    end if
    print "[FAIL] " + name + " (expected compile failure, but compile succeeded)"
    return false
  end if

  if rc_compile != 0 then
    print "[FAIL] " + name + " (compile rc=" + rc_compile + ")"
    return false
  end if

  if mode == "compile_ok" then
    print "[PASS] " + name
    return true
  end if

  exp_run_rc = 0
  if mode == "run_rc1" then exp_run_rc = 1 end if
  if mode == "run_rc5" then exp_run_rc = 5 end if
  if mode == "run_rc7" then exp_run_rc = 7 end if

  rc_run = _run_exe(out_abs, run_flags)
  if rc_run != exp_run_rc then
    print "[FAIL] " + name + " (runtime rc=" + rc_run + ", expected=" + exp_run_rc + ")"
    return false
  end if

  print "[PASS] " + name
  return true
end function

function _test(compiler_path, repo_root, name, src_rel, mode, extra_flags)
  src_abs = _path_join(repo_root, src_rel)
  out_abs = _path_join(repo_root, "tests\\_rt_" + name + ".exe")
  mode_flags = ""
  run_after_compile = true
  expect_compile_fail = false

  if mode == "compile_fail" then
    expect_compile_fail = true
    run_after_compile = false
  end if

  if fs.exists(src_abs) == false then
    print "[FAIL] " + name + " (missing source: " + src_abs + ")"
    return false
  end if

  if fs.exists(out_abs) then
    fs.delete(out_abs)
  end if

  rc_compile = _run_compile(compiler_path, src_abs, out_abs, repo_root, extra_flags, mode_flags)

  if expect_compile_fail then
    if rc_compile != 0 then
      print "[PASS] " + name + " (expected compile failure)"
      return true
    end if
    print "[FAIL] " + name + " (expected compile failure, but compile succeeded)"
    return false
  end if

  if rc_compile != 0 then
    print "[FAIL] " + name + " (compile rc=" + rc_compile + ")"
    return false
  end if

  if run_after_compile then
    rc_run = _run_exe(out_abs, "")
    if rc_run != 0 then
      print "[FAIL] " + name + " (runtime rc=" + rc_run + ")"
      return false
    end if
  end if

  print "[PASS] " + name
  return true
end function

function _test_project_manifest(compiler_path, repo_root)
  name = "project_manifest_cache"
  manifest_abs = _path_join(repo_root, "build\\_rt_project_manifest.toml")
  source_abs = _path_join(repo_root, "build\\_rt_project_source.ml")
  output_abs = _path_join(repo_root, "build\\_rt_project_output.exe")
  manifest_text = "[project]\nentry = \"_rt_project_source.ml\"\noutput = \"_rt_project_output.exe\"\nincremental = true\ncache_dir = \"_rt_project_cache\"\n"
  if typeof(fs.writeAllText(manifest_abs, manifest_text)) == "error" then
    print "[FAIL] " + name + " (could not write manifest)"
    return false
  end if
  source_v1 = "function main(args)\n  return 0\nend function\n"
  if typeof(fs.writeAllText(source_abs, source_v1)) == "error" then
    print "[FAIL] " + name + " (could not write v1 source)"
    return false
  end if
  cmd = "call " + _q(compiler_path) + " --project " + _q(manifest_abs)
  if _wsystem(cmd) != 0 or _run_exe(output_abs, "") != 0 then
    print "[FAIL] " + name + " (initial build/run failed)"
    return false
  end if

  // A source-content change must invalidate the cached executable.
  source_v2 = "function main(args)\n  return 7\nend function\n"
  if typeof(fs.writeAllText(source_abs, source_v2)) == "error" or _wsystem(cmd) != 0 then
    print "[FAIL] " + name + " (source-change rebuild failed)"
    return false
  end if
  if _run_exe(output_abs, "") != 7 then
    print "[FAIL] " + name + " (stale executable after source change)"
    return false
  end if

  // Removing only the output must allow an exact cache hit to restore it.
  if fs.delete(output_abs) == false then
    print "[FAIL] " + name + " (could not remove output before restore)"
    return false
  end if
  if _wsystem(cmd) != 0 or fs.exists(output_abs) == false or _run_exe(output_abs, "") != 7 then
    print "[FAIL] " + name + " (cache restore failed)"
    return false
  end if
  print "[PASS] " + name
  return true
end function

function _label_function_block(labels, fn_name)
  marker = "[label] fn_user_" + fn_name + " "
  start = s.indexOf(labels, marker, 0)
  if start < 0 then return "" end if
  next_start = s.indexOf(labels, "\n[label] fn_user_", start + len(marker))
  if next_start < 0 then return s.substr(labels, start, len(labels) - start) end if
  return s.substr(labels, start, next_start - start)
end function

function _all_user_functions_aligned(labels, alignment)
  if typeof(labels) != "string" or typeof(alignment) != "int" or alignment <= 0 then return false end if
  lines = s.split(labels, "\n")
  found = false
  for each line in lines
    if s.startsWith(line, "[label] fn_user_") == false then continue end if
    found = true
    separator = s.lastIndexOf(line, " ")
    if separator < 0 or separator + 1 >= len(line) then return false end if
    offset = toNumber(s.substr(line, separator + 1, len(line) - separator - 1))
    if typeof(offset) != "int" or (offset % alignment) != 0 then return false end if
  end for
  return found
end function

function _test_codegen_optimizations(compiler_path, repo_root, extra_flags)
  name = "codegen_optimizations"
  src_abs = _path_join(repo_root, "tests\\codegen_optimizations.ml")
  out_abs = _path_join(repo_root, "tests\\_rt_codegen_optimizations.exe")
  labels_abs = _path_join(repo_root, "tests\\_rt_codegen_optimizations.labels")
  if fs.exists(src_abs) == false then
    print "[FAIL] " + name + " (missing source)"
    return false
  end if
  if fs.exists(out_abs) then fs.delete(out_abs) end if
  if fs.exists(labels_abs) then fs.delete(labels_abs) end if

  mode_flags = "--dump-labels " + _q(labels_abs)
  rc_compile = _run_compile(compiler_path, src_abs, out_abs, repo_root, extra_flags, mode_flags)
  if rc_compile != 0 then
    print "[FAIL] " + name + " (compile rc=" + rc_compile + ")"
    return false
  end if
  rc_run = _run_exe(out_abs, "")
  if rc_run != 0 then
    print "[FAIL] " + name + " (runtime rc=" + rc_run + ")"
    return false
  end if

  labels = fs.readAllText(labels_abs)
  if typeof(labels) != "string" then
    print "[FAIL] " + name + " (missing label dump)"
    return false
  end if
  if _all_user_functions_aligned(labels, 16) == false then
    print "[FAIL] " + name + " (user functions are not 16-byte aligned)"
    return false
  end if
  if s.contains(labels, "[label] fn_user_pruned_add ") == false or s.contains(labels, "[label] fn_user_kept_add ") == false or s.contains(labels, "[label] fn_user_budget_add ") == false or s.contains(labels, "[label] fn_user_loop_inline ") == false then
    print "[FAIL] " + name + " (safe inline fallback body is missing)"
    return false
  end if
  // This fixture cannot create a Thread. Whole-program feature gating must
  // therefore eliminate cancellation/GC polls, TLS paths and the now-unused
  // heap/native synchronization helper bodies from the generated binary.
  if s.contains(labels, "thread_cancel_done_") or s.contains(labels, "gc_poll_done_") or s.contains(labels, "dbg_worker_") or s.contains(labels, "dbg_line_worker_") or s.contains(labels, "gc_context_loop_") or s.contains(labels, "[label] fn_heap_enter ") or s.contains(labels, "[label] fn_heap_leave ") or s.contains(labels, "[label] fn_gc_native_enter ") or s.contains(labels, "[label] fn_gc_native_leave ") or s.contains(labels, "[label] fn_gc_safepoint ") then
    print "[FAIL] " + name + " (thread-free target retained native-thread overhead)"
    return false
  end if

  leaf_labels = _label_function_block(labels, "leaf_frame")
  if leaf_labels == "" or s.contains(leaf_labels, "gcclr_loop_") == false then
    print "[FAIL] " + name + " (hidden inline call arity did not expand the caller root frame)"
    return false
  end if
  loop_labels = _label_function_block(labels, "const_loop")
  if loop_labels == "" or s.contains(loop_labels, "for_top_") == false then
    print "[FAIL] " + name + " (constant loop was not emitted)"
    return false
  end if
  if s.contains(loop_labels, "__for_end_") or s.contains(loop_labels, "__for_step_") then
    print "[FAIL] " + name + " (constant loop retained dynamic end/step state)"
    return false
  end if
  flow_labels = _label_function_block(labels, "extended_type_flow")
  flow_markers = [
    "numeric_float_fast_", "bool_condition_fast_",
    "struct_member_fast_", "struct_setmember_fast_",
    "loop_invariant_base_array_", "loop_invariant_base_bytes_",
    "idx_fast_array_", "idx_fast_bytes_", "idx_fast_bounds_elided_",
    "seti_fast_bytes_", "seti_fast_bounds_elided_"
  ]
  if flow_labels == "" then
    print "[FAIL] " + name + " (extended type-flow function is missing)"
    return false
  end if
  for each flow_marker in flow_markers
    if s.contains(flow_labels, flow_marker) == false then
      print "[FAIL] " + name + " (extended type-flow/BCE lowering is missing: " + flow_marker + ")"
      return false
    end if
  end for
  if s.contains(flow_labels, "idx_fast_oob_") or s.contains(flow_labels, "seti_fast_oob_") then
    print "[FAIL] " + name + " (proven fixed-length loop retained bounds checks)"
    return false
  end if
  negative_index_labels = _label_function_block(labels, "fixed_negative_index")
  if s.contains(negative_index_labels, "idx_fast_array_") == false or s.contains(negative_index_labels, "idx_fast_nonnegative_") == false or s.contains(negative_index_labels, "idx_fast_oob_") == false then
    print "[FAIL] " + name + " (negative fixed index incorrectly elided normalization/bounds checks)"
    return false
  end if
  known_method_labels = _label_function_block(labels, "known_method_calls")
  if known_method_labels == "" or s.contains(known_method_labels, "inline_end_") == false or s.contains(known_method_labels, "mcall_ic_") then
    print "[FAIL] " + name + " (known struct method retained dynamic dispatch or missed inlining)"
    return false
  end if
  wide_method_labels = _label_function_block(labels, "known_wide_method_call")
  if wide_method_labels == "" or s.contains(wide_method_labels, "mcall_ic_") then
    print "[FAIL] " + name + " (wide known method retained dynamic dispatch)"
    return false
  end if
  invalid_bytes_labels = _label_function_block(labels, "invalid_bytes_index")
  if invalid_bytes_labels == "" or s.contains(invalid_bytes_labels, "idx_fast_bytes_checked_") == false then
    print "[FAIL] " + name + " (fallible bytes construction missed its guarded specialized index path)"
    return false
  end if
  checked_bytes_labels = _label_function_block(labels, "checked_bytes_roundtrip")
  if checked_bytes_labels == "" or s.contains(checked_bytes_labels, "idx_fast_bytes_checked_") == false or s.contains(checked_bytes_labels, "seti_fast_bytes_checked_") == false or s.contains(checked_bytes_labels, "idx_fast_bad_target_") == false or s.contains(checked_bytes_labels, "seti_fast_bad_target_") == false then
    print "[FAIL] " + name + " (checked bytes reads/writes lost their runtime target guards)"
    return false
  end if
  context_enum_labels = _label_function_block(labels, "tests.codegen_context_values.enumValueFlow")
  if context_enum_labels == "" or s.contains(context_enum_labels, "eq_lhs_not_bytes_") then
    print "[FAIL] " + name + " (package enum constants missed function-context integer flow)"
    return false
  end if
  strength_labels = _label_function_block(labels, "constant_strength_reduction")
  if strength_labels == "" or s.contains(strength_labels, "known_mod_") or s.contains(strength_labels, "known_shift_") then
    print "[FAIL] " + name + " (constant integer operations retained generic control flow)"
    return false
  end if

  small_src = _path_join(repo_root, "tests\\root_frame_small.ml")
  small_out = _path_join(repo_root, "tests\\_rt_root_frame_small.exe")
  small_labels_abs = _path_join(repo_root, "tests\\_rt_root_frame_small.labels")
  if fs.exists(small_out) then fs.delete(small_out) end if
  if fs.exists(small_labels_abs) then fs.delete(small_labels_abs) end if
  small_mode_flags = "--dump-labels " + _q(small_labels_abs)
  small_compile = _run_compile(compiler_path, small_src, small_out, repo_root, extra_flags, small_mode_flags)
  if small_compile != 0 or _run_exe(small_out, "") != 0 then
    print "[FAIL] " + name + " (small root-frame regression program failed)"
    return false
  end if
  small_labels = fs.readAllText(small_labels_abs)
  small_leaf_labels = _label_function_block(small_labels, "leaf_frame")
  if small_leaf_labels == "" or s.contains(small_leaf_labels, "gcclr_loop_") then
    print "[FAIL] " + name + " (tiny root frame did not use straight-line clearing)"
    return false
  end if

  print "[PASS] " + name
  return true
end function

function _test_tlab_shared_heap(compiler_path, repo_root, extra_flags)
  name = "tlab_shared_heap"
  src_abs = _path_join(repo_root, "tests\\tlab_shared_heap.ml")
  out_abs = _path_join(repo_root, "tests\\_rt_tlab_shared_heap.exe")
  labels_abs = _path_join(repo_root, "tests\\_rt_tlab_shared_heap.labels")
  if fs.exists(out_abs) then fs.delete(out_abs) end if
  if fs.exists(labels_abs) then fs.delete(labels_abs) end if

  mode_flags = "--dump-labels " + _q(labels_abs)
  rc_compile = _run_compile(compiler_path, src_abs, out_abs, repo_root, extra_flags, mode_flags)
  if rc_compile != 0 or _run_exe(out_abs, "") != 0 then
    print "[FAIL] " + name + " (compile/runtime regression)"
    return false
  end if
  labels = fs.readAllText(labels_abs)
  if typeof(labels) != "string" or s.contains(labels, "[label] tlab_refill_") == false or s.contains(labels, "[label] tlab_retire_internal ") == false or s.contains(labels, "[label] fn_heap_enter ") == false or s.contains(labels, "[label] gc_context_loop_") == false or s.contains(labels, "[label] gcsafe_park_") == false then
    print "[FAIL] " + name + " (generated TLAB runtime shape is missing)"
    return false
  end if
  print "[PASS] " + name
  return true
end function

function main(args)
  if typeof(args) != "array" or len(args) < 1 then
    print "Usage: runtests.exe <compiler.exe> [extra compiler args...]"
    print "Example: runtests.exe .\\bin\\mlc_selfhost.exe"
    return 2
  end if

  compiler_path = args[0]
  extra_flags = _join_extra_args(args, 1)
  compiler_gc_flags = extra_flags
  if compiler_gc_flags != "" then compiler_gc_flags = compiler_gc_flags + " " end if
  compiler_gc_flags = compiler_gc_flags + "--gc-limit 1m"
  repo_root = _repo_root_hint(compiler_path)

  pass = 0
  fail = 0

  // Suite-style runtime tests
  if _test(compiler_path, repo_root, "array_vector", "tests\\array_vector.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "language_suite", "tests\\language_suite.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "stdlib_unit_tests", "tests\\stdlib_unit_tests.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "gc_periodic_test", "tests\\gc_periodic_test.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "gc_heap_stress", "tests\\gc_heap_stress.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "gc_box_float_safepoint", "tests\\gc_box_float_safepoint.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "gc_float_call_roots", "tests\\gc_float_call_roots.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "gc_nested_graph_roots", "tests\\gc_nested_graph_roots.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "gc_reference_write_roots", "tests\\gc_reference_write_roots.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "aes128_ecb_nist_kat", "tests\\aes128_ecb_nist_kat.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "winapi_extern_smoke", "tests\\winapi_extern_smoke.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "native_bytes_ptr_smoke", "tests\\native_bytes_ptr_smoke.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "native_raw_value_smoke", "tests\\native_raw_value_smoke.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "native_callback_wndproc_smoke", "tests\\native_callback_wndproc_smoke.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "extern_out_runtime", "tests\\extern_out_runtime.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "defer_features", "tests\\defer_features.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test_project_manifest(compiler_path, repo_root) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "global_function_rebind", "tests\\global_function_rebind.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "thread_features", "tests\\thread_features.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test_tlab_shared_heap(compiler_path, repo_root, extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "gc_back_to_back_safepoint", "tests\\gc_back_to_back_safepoint.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "threading_stdlib", "tests\\threading_stdlib.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "thread_pool", "tests\\thread_pool.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "type_checks", "tests\\type_checks.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "thread_invalid_entry", "tests\\thread_invalid_entry.ml", "compile_fail", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "thread_invalid_synchronized_local", "tests\\thread_invalid_synchronized_local.ml", "compile_fail", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "asm_opcodes_golden_smoke", "tests\\test_asm_opcodes.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "member_callable_direct", "tests\\member_callable_direct.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "codegen_phase_gc", "tests\\codegen_phase_gc.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "compiler_gc_liveness", "tests\\compiler_gc_liveness.ml", "run_ok", compiler_gc_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test_codegen_optimizations(compiler_path, repo_root, extra_flags) then pass = pass + 1 else fail = fail + 1 end if

  // Existing ns/import framework tests
  if _test(compiler_path, repo_root, "ns_basic", "tests\\ns_import_tests\\cases\\basic\\main.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "ns_relative_path", "tests\\ns_import_tests\\cases\\relative_path\\main.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "ns_structs", "tests\\ns_import_tests\\cases\\structs\\main.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "ns_cycle", "tests\\ns_import_tests\\cases\\cycle_fail\\main.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "ns_decl_only_fail", "tests\\ns_import_tests\\cases\\decl_only_fail\\main.ml", "compile_fail", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "ns_unqualified_fail", "tests\\ns_import_tests\\cases\\unqualified_fail\\main.ml", "compile_fail", extra_flags) then pass = pass + 1 else fail = fail + 1 end if



  // Ported tests from python runner (generated/staticized)
  run_args_main = _q("a") + " " + _q("b c") + " " + _q("d")
  flag_inc_ok = "-I " + _q(_path_join(repo_root, "tests/ported_py/test_import_include_paths/libroot"))
  flag_inc_amb = "-I " + _q(_path_join(repo_root, "tests/ported_py/test_import_ambiguous_include_paths/libroot"))

  if _test_adv(compiler_path, repo_root, "py_unhandled_top", "tests/ported_py/test_unhandled_error_top_level/unhandled_top.ml", "run_rc1", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_unhandled_main", "tests/ported_py/test_unhandled_error_main_return/unhandled_main.ml", "run_rc1", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_unhandled_origin_top", "tests/ported_py/test_unhandled_error_origin_top_level/unhandled_origin_top.ml", "run_rc1", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_unhandled_origin_main", "tests/ported_py/test_unhandled_error_origin_main_return/unhandled_origin_main.ml", "run_rc1", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_unhandled_origin_cleared", "tests/ported_py/test_unhandled_error_origin_omitted_when_cleared/unhandled_origin_cleared.ml", "run_rc1", "", "") then pass = pass + 1 else fail = fail + 1 end if

  if _test_adv(compiler_path, repo_root, "py_reserved_ident", "tests/ported_py/test_reserved_identifiers/reserved_ident.ml", "compile_fail", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_keepgoing_multi", "tests/ported_py/test_keep_going_reports_multiple_errors/main_keepgoing.ml", "compile_fail", "--keep-going --max-errors 50", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_keepgoing_max", "tests/ported_py/test_keep_going_respects_max_errors/main_keepgoing_max.ml", "compile_fail", "--keep-going --max-errors 2", "") then pass = pass + 1 else fail = fail + 1 end if

  if _test_adv(compiler_path, repo_root, "py_package_basic", "tests/ported_py/test_package_basic/main_pkg.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_package_dotted", "tests/ported_py/test_package_dotted/main_pkg_dotted.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_import_as_alias", "tests/ported_py/test_import_as_alias/main_import_as.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_import_mod_pkg_mismatch", "tests/ported_py/test_import_module_package_mismatch/main_import_mod.ml", "compile_fail", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_import_pkg_path_mismatch", "tests/ported_py/test_import_package_path_mismatch/main_import_path_pkg_mismatch.ml", "compile_fail", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_import_alias_file_skips_pkg_path", "tests/ported_py/test_import_alias_file_skips_package_path_check/main_alias_file.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_import_include_noI", "tests/ported_py/test_import_include_paths/main_import_I.ml", "compile_fail", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_import_include_withI", "tests/ported_py/test_import_include_paths/main_import_I.ml", "run_rc5", flag_inc_ok, "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_import_ambig_local_ok", "tests/ported_py/test_import_ambiguous_include_paths/main_import_ambig.ml", "run_rc5", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_import_ambig_withI", "tests/ported_py/test_import_ambiguous_include_paths/main_import_ambig.ml", "compile_fail", flag_inc_amb, "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_package_not_first", "tests/ported_py/test_package_not_first/pkg_not_first.ml", "compile_fail", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_package_duplicate", "tests/ported_py/test_package_duplicate/pkg_dup.ml", "compile_fail", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_main_in_package", "tests/ported_py/test_main_in_package/main_in_pkg.ml", "compile_fail", "", "") then pass = pass + 1 else fail = fail + 1 end if

  if _test_adv(compiler_path, repo_root, "py_namespace_dotted", "tests/ported_py/test_namespace_dotted/main_ns_dotted.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_namespace_nested", "tests/ported_py/test_namespace_nested/main_ns_nested.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_import_cycle_allowed", "tests/ported_py/test_import_cycle_allowed/main_cycle_ok.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_import_self_ignored", "tests/ported_py/test_import_self_ignored/main_self_import_ok.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_module_init_order", "tests/ported_py/test_module_init_order/main_modinit_order.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_module_init_once_cycle", "tests/ported_py/test_module_init_once_in_cycle/main_modinit_once_cycle.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "package_global_resolution", "tests/package_global_resolution/main.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_import_decl_only", "tests/ported_py/test_import_decl_only_violation/main_bad.ml", "compile_fail", "", "") then pass = pass + 1 else fail = fail + 1 end if

  if _test_adv(compiler_path, repo_root, "py_call_arity", "tests/ported_py/test_call_arity_mismatch/arity_bad.ml", "compile_fail", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_enum_unknown", "tests/ported_py/test_enum_unknown_variant/enum_unknown_variant.ml", "compile_fail", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_enum_duplicate", "tests/ported_py/test_enum_duplicate_variant/enum_duplicate_variant.ml", "compile_fail", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_const_reassign", "tests/ported_py/test_const_reassign_rejected/const_reassign.ml", "compile_fail", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "constexpr_bool_arithmetic_invalid", "tests\\constexpr_bool_arithmetic_invalid.ml", "compile_fail", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_enum_autoinc", "tests/ported_py/test_enum_autoinc_ignores_strings/enum_autoinc_ignore_strings.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_typequalified_this", "tests/ported_py/test_typequalified_instance_method_uses_this_rejected/typequalified_uses_this.ml", "compile_fail", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_member_call_arity_diag", "tests/ported_py/test_member_call_arity_error_message/member_call_arity_diag.ml", "run_rc1", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_import_init_const", "tests/ported_py/test_import_initializer_behavior_const/main_ce_bad.ml", "compile_fail", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_import_init_global", "tests/ported_py/test_import_initializer_behavior_global/main_ce_bad.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_no_newlines", "tests/ported_py/test_no_newlines_required/no_newlines_required.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_import_constexpr_ok", "tests/ported_py/test_import_constexpr_ok/main_ce_ok.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_imported_callable_value", "tests/ported_py/test_imported_callable_value/main_imported_callable.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if


  if _test_adv(compiler_path, repo_root, "py_main_args_exit", "tests/ported_py/test_main_args_and_exitcode/main_args.ml", "run_rc7", "", run_args_main) then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_main_void", "tests/ported_py/test_main_void_exit0/main_void.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_main_arity0", "tests/ported_py/test_main_bad_arity0/main_arity0.ml", "compile_fail", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_main_arity2", "tests/ported_py/test_main_bad_arity2/main_arity2.ml", "compile_fail", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_main_in_ns", "tests/ported_py/test_main_in_namespace/main_in_ns.ml", "compile_fail", "", "") then pass = pass + 1 else fail = fail + 1 end if

  if _test_adv(compiler_path, repo_root, "py_heap_cfg", "tests/ported_py/test_heap_cli_config_applied/heap_cfg.ml", "run_ok", "--heap-reserve 48m --heap-commit 24m", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_heap_invalid", "tests/ported_py/test_heap_cli_invalid_size/heap_bad.ml", "compile_fail", "--heap-reserve 1z", "") then pass = pass + 1 else fail = fail + 1 end if

  if _test_adv(compiler_path, repo_root, "py_ns_struct_optional", "tests/ported_py/test_ns_struct_optional/main_geom.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_extern_namespaced", "tests/ported_py/test_extern_namespaced/extern_ns.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_extern_value_runtime", "tests/ported_py/test_extern_value_runtime/extern_value_runtime.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_extern_double_abi", "tests/ported_py/test_extern_double_abi/extern_double_abi.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "extern_abi_valid", "tests/extern_abi_validation_valid.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "extern_abi_bad_field", "tests/extern_abi_validation_bad_field.ml", "compile_fail", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "extern_abi_bad_out_order", "tests/extern_abi_validation_bad_out_order.ml", "compile_fail", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "extern_abi_bad_param", "tests/extern_abi_validation_bad_param.ml", "compile_fail", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_callable_values_runtime", "tests/ported_py/test_callable_values_runtime/callable_values_runtime.ml", "run_ok", "", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_call_profile", "tests/ported_py/test_call_profile_counts/call_profile_counts.ml", "run_ok", "--profile-calls", "") then pass = pass + 1 else fail = fail + 1 end if
  if _test_adv(compiler_path, repo_root, "py_trace_calls", "tests/ported_py/test_trace_calls_preserves_params/trace_calls_params.ml", "run_ok", "--trace-calls", "") then pass = pass + 1 else fail = fail + 1 end if

  print ""
  print "=== SUMMARY ==="
  print "PASS: " + pass
  print "FAIL: " + fail

  if fail == 0 then
    print "OK"
    return 0
  end if

  print "NOT OK"
  return 1
end function
