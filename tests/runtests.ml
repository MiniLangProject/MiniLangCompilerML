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

function _run_exe(path_abs)
  return _wsystem("call " + _q(path_abs))
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
    rc_run = _run_exe(out_abs)
    if rc_run != 0 then
      print "[FAIL] " + name + " (runtime rc=" + rc_run + ")"
      return false
    end if
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
  repo_root = _repo_root_hint(compiler_path)

  pass = 0
  fail = 0

  // Suite-style runtime tests
  if _test(compiler_path, repo_root, "language_suite", "tests\\language_suite.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "stdlib_unit_tests", "tests\\stdlib_unit_tests.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "gc_periodic_test", "tests\\gc_periodic_test.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "gc_heap_stress", "tests\\gc_heap_stress.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "aes128_ecb_nist_kat", "tests\\aes128_ecb_nist_kat.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "winapi_extern_smoke", "tests\\winapi_extern_smoke.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "asm_opcodes_golden_smoke", "tests\\test_asm_opcodes.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if

  // Existing ns/import framework tests
  if _test(compiler_path, repo_root, "ns_basic", "tests\\ns_import_tests\\cases\\basic\\main.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "ns_relative_path", "tests\\ns_import_tests\\cases\\relative_path\\main.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "ns_structs", "tests\\ns_import_tests\\cases\\structs\\main.ml", "run_ok", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "ns_cycle_fail", "tests\\ns_import_tests\\cases\\cycle_fail\\main.ml", "compile_fail", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "ns_decl_only_fail", "tests\\ns_import_tests\\cases\\decl_only_fail\\main.ml", "compile_fail", extra_flags) then pass = pass + 1 else fail = fail + 1 end if
  if _test(compiler_path, repo_root, "ns_unqualified_fail", "tests\\ns_import_tests\\cases\\unqualified_fail\\main.ml", "compile_fail", extra_flags) then pass = pass + 1 else fail = fail + 1 end if

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
