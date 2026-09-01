import std.fs as fs
import std.string as s
import mlc.asm as a
import mlc.data as d
import mlc.linux_runtime as linux_runtime
import mlc.tools as tools

struct TestExternSignature
  name,
  dll,
  symbol_name,
  params,
end struct

struct TestLinuxThunkState
  asm,
  extern_sigs,
end struct

function checkOpcode(name, builder, expected)
  actual = hex(a.finalize(builder))
  if actual != expected then
    print "FAIL: " + name + " expected=" + expected + " actual=" + actual
    return 1
  end if
  return 0
end function

function checkLinuxThunkLocalBranches()
  sig = TestExternSignature("strlen", "libc.so.6", "strlen", [])
  state = TestLinuxThunkState(a.newCodegenAsmBuilder(), [sig])
  state = linux_runtime._emit_extern_thunks(state)
  state.asm = a.materialize(state.asm)
  buf = state.asm.buf
  seen = 0
  failures = 0
  if len(buf) >= 6 then
    for i = 0 to len(buf) - 6
      if buf[i] == 0x0F and (buf[i + 1] == 0x84 or buf[i + 1] == 0x85) then
        seen = seen + 1
        if buf[i + 2] == 0 and buf[i + 3] == 0 and buf[i + 4] == 0 and buf[i + 5] == 0 then
          print "FAIL: Linux extern thunk retained a zero local branch displacement"
          failures = failures + 1
        end if
      end if
    end for
  end if
  // The thunk has one cached-resolution branch plus explicit failure branches
  // after dlopen and dlsym. All three must be locally resolved.
  if seen != 3 then
    print "FAIL: Linux extern thunk resolver branch count"
    failures = failures + 1
  end if
  return failures
end function

function checkRDataLabelScale()
  rb = d.newRDataBuilder()
  for i = 0 to 66000
    rb = d.rdata_add_bytes_unique(rb, "scale_label_" + i, bytes(1, i & 0xFF))
  end for

  failures = 0
  labels = d.rdata_get_labels(rb)
  if len(labels) != 66001 or d.rdata_label_count(rb) != 66001 then
    print "FAIL: chunked rdata label count"
    failures = failures + 1
  end if
  if d.rdata_has_label(rb, "scale_label_0") == false or d.rdata_has_label(rb, "scale_label_65536") == false or d.rdata_has_label(rb, "scale_label_66000") == false then
    print "FAIL: chunked rdata label lookup"
    failures = failures + 1
  end if
  last = d.rdata_label_record(rb, "scale_label_66000")
  if typeof(last) != "struct" or last.offset != 66000 or last.length != 1 then
    print "FAIL: chunked rdata label record"
    failures = failures + 1
  end if
  return failures
end function

function checkDataLabelScale()
  db = d.newDataBuilder()
  for i = 0 to 66000
    db = d.data_add_bytes(db, "data_scale_label_" + i, bytes(1, i & 0xFF))
  end for

  failures = 0
  labels = d.data_get_labels(db)
  if len(labels) != 66001 or d.data_label_count(db) != 66001 then
    print "FAIL: chunked data label count"
    failures = failures + 1
  end if
  if d.data_has_label(db, "data_scale_label_0") == false or d.data_has_label(db, "data_scale_label_65536") == false or d.data_has_label(db, "data_scale_label_66000") == false then
    print "FAIL: chunked data label lookup"
    failures = failures + 1
  end if
  last = d.data_label_record(db, "data_scale_label_66000")
  if typeof(last) != "struct" or last.offset != 66000 then
    print "FAIL: chunked data label record"
    failures = failures + 1
  end if
  return failures
end function

function checkChunkedIndexedRead()
  builder = tools.arr_chunk_new(256)
  for i = 0 to 17000
    builder = tools.arr_chunk_push(builder, i)
  end for
  failures = 0
  if tools.arr_chunked_count(builder.chunks, builder.tail, 256) != 17001 then
    print "FAIL: chunked indexed count"
    failures = failures + 1
  end if
  probes = [0, 255, 256, 16383, 16384, 17000]
  for each idx in probes
    if tools.arr_chunked_get(builder.chunks, builder.tail, idx, 256, -1) != idx then
      print "FAIL: chunked indexed read at " + idx
      failures = failures + 1
    end if
  end for
  // The streaming view must preserve the paged chunks and the partial tail in
  // logical order without flattening all 17,001 values into another array.
  groups = tools.arr_chunked_groups(builder.chunks, builder.tail)
  expected = 0
  if len(groups) != 67 or len(groups[0]) != 256 or len(groups[66]) != 105 then
    print "FAIL: chunked streaming group shape"
    failures = failures + 1
  else
    for each group in groups
      for each value in group
        if value != expected then
          print "FAIL: chunked streaming read at " + expected
          failures = failures + 1
          break
        end if
        expected = expected + 1
      end for
    end for
    if expected != 17001 then
      print "FAIL: chunked streaming count"
      failures = failures + 1
    end if
  end if
  return failures
end function

function checkAssemblerChunkBoundary()
  builder = a.newAsmBuilder()
  for i = 0 to 65540
    builder = a.emit8(builder, i & 0xFF)
  end for
  raw = a.finalize(builder)
  if typeof(raw) != "bytes" or len(raw) != 65541 then
    print "FAIL: assembler chunk-boundary length"
    return 1
  end if
  probes = [0, 1, 65534, 65535, 65536, 65537, 65540]
  for each idx in probes
    if raw[idx] != (idx & 0xFF) then
      print "FAIL: assembler chunk-boundary byte at " + idx
      return 1
    end if
  end for
  return 0
end function

function checkAssemblerMaterializedReuse()
  builder = a.newAsmBuilder()
  builder = a.emit8(builder, 0x11)
  builder = a.emit8(builder, 0x22)
  builder = a.materialize(builder)
  builder = a.emit8(builder, 0x33)
  raw = a.finalize(builder)
  if typeof(raw) != "bytes" or len(raw) != 3 or raw[0] != 0x11 or raw[1] != 0x22 or raw[2] != 0x33 then
    print "FAIL: assembler emission after materialization"
    return 1
  end if

  patched = a.newAsmBuilder()
  patched = a.jmp(patched, "done")
  patched = a.nop(patched)
  patched = a.mark(patched, "done")
  patched = a.ret(patched)
  patched = a.materialize(patched)
  patched_raw = a.finalize(patched)
  if typeof(patched_raw) != "bytes" or len(patched_raw) != 7 then
    print "FAIL: assembler patch after materialization length"
    return 1
  end if
  if patched_raw[0] != 0xE9 or patched_raw[1] != 1 or patched_raw[2] != 0 or patched_raw[3] != 0 or patched_raw[4] != 0 or patched_raw[5] != 0x90 or patched_raw[6] != 0xC3 then
    print "FAIL: assembler patch after materialization bytes"
    return 1
  end if
  return 0
end function

function checkCallAndHelperTracking()
  failures = 0

  // General assembler clients retain the historical complete call list.
  builder = a.newAsmBuilder()
  builder = a.call(builder, "fn_alloc")
  builder = a.call(builder, "fn_alloc")
  builder = a.call(builder, "fn_user_example")
  if len(a.get_calls(builder)) != 3 then
    print "FAIL: general assembler call tracking"
    failures = failures + 1
  end if
  if len(a.get_tracked_helpers(builder)) != 1 or a.get_tracked_helpers(builder)[0] != "fn_alloc" then
    print "FAIL: indexed helper de-duplication"
    failures = failures + 1
  end if

  // Production codegen needs the unique helper set, but never reads the much
  // larger per-call history.
  builder = a.newCodegenAsmBuilder()
  builder = a.call(builder, "fn_alloc")
  builder = a.call(builder, "fn_alloc")
  if len(a.get_calls(builder)) != 0 or len(a.get_tracked_helpers(builder)) != 1 then
    print "FAIL: codegen assembler tracking policy"
    failures = failures + 1
  end if
  builder = a.clear_tracked_helpers(builder)
  builder = a.call(builder, "fn_alloc")
  if len(a.get_tracked_helpers(builder)) != 1 then
    print "FAIL: helper index reset"
    failures = failures + 1
  end if

  return failures
end function

function main(args)
  p = "tests\\asm_opcodes_golden.json"
  if fs.exists(p) == false then
    print "SKIP: asm_opcodes_golden.json not found"
    return 0
  end if

  txt = fs.readAllText(p)
  if typeof(txt) != "string" then
    print "FAIL: could not read asm_opcodes_golden.json"
    return 2
  end if
  if len(txt) == 0 then
    print "FAIL: asm_opcodes_golden.json is empty"
    return 3
  end if
  if s.contains(txt, "\"vectors\"") == false then
    print "FAIL: asm_opcodes_golden.json has no vectors field"
    return 4
  end if
  if s.contains(txt, "\"count\": 229") == false then
    print "FAIL: asm_opcodes_golden.json does not contain the synchronized 229-vector set"
    return 5
  end if

  failures = 0

  b = a.newAsmBuilder()
  b = a.movq_r64_xmm(b, "r10", "xmm9")
  failures = failures + checkOpcode("movq_r64_xmm", b, "664d0f7eca")

  b = a.newAsmBuilder()
  b = a.add_r32_imm(b, "r11d", 0x11223344)
  failures = failures + checkOpcode("add_r32_imm", b, "4181c344332211")

  b = a.newAsmBuilder()
  b = a.add_r64_r64(b, "r11", "r10")
  failures = failures + checkOpcode("add_r64_r64", b, "4d03da")

  b = a.newAsmBuilder()
  // MiniLang integers are tagged and therefore cannot represent an arbitrary
  // unsigned 64-bit literal.  Keep this smoke operand inside the exact range.
  b = a.mov_r64_imm64(b, "r11", 0x0122334455667788)
  failures = failures + checkOpcode("mov_r64_imm64", b, "49bb8877665544332201")

  b = a.newAsmBuilder()
  b = a.mov_membase_disp_r64(b, "rbp", -16, "r11")
  failures = failures + checkOpcode("mov_membase_disp_r64", b, "4c895df0")

  b = a.newAsmBuilder()
  b = a.mov_r64_membase_disp(b, "r11", "rbp", -16)
  failures = failures + checkOpcode("mov_r64_membase_disp", b, "4c8b5df0")

  b = a.newAsmBuilder()
  b = a.movsd_xmm_xmm(b, "xmm9", "xmm1")
  failures = failures + checkOpcode("movsd_xmm_xmm", b, "f2440f10c9")

  b = a.newAsmBuilder()
  b = a.setcc_r8(b, "e", "r11b")
  failures = failures + checkOpcode("setcc_r8", b, "410f94c3")

  b = a.newAsmBuilder()
  b = a.xor_r32_r32(b, "r11d", "r10d")
  failures = failures + checkOpcode("xor_r32_r32", b, "4533da")

  b = a.newAsmBuilder()
  b = a.and_r32_r32(b, "r11d", "r10d")
  failures = failures + checkOpcode("and_r32_r32", b, "4523da")

  b = a.newAsmBuilder()
  b = a.or_r32_r32(b, "r11d", "r10d")
  failures = failures + checkOpcode("or_r32_r32", b, "450bda")

  b = a.newAsmBuilder()
  b = a.bsr_r32_r32(b, "r11d", "r10d")
  failures = failures + checkOpcode("bsr_r32_r32", b, "450fbdda")

  b = a.newAsmBuilder()
  b = a.crc32_r32_membase_disp8(b, "r11d", "rbp", -16)
  failures = failures + checkOpcode("crc32_r32_membase_disp8", b, "f2440f38f05df0")

  b = a.newAsmBuilder()
  b = a.crc32_r64_membase_disp(b, "r11", "rbp", -16)
  failures = failures + checkOpcode("crc32_r64_membase_disp", b, "f24c0f38f15df0")

  b = a.newAsmBuilder()
  b = a.push_reg(b, "r11")
  b = a.pop_reg(b, "r11")
  b = a.ret(b)
  // Both encoders peephole away an adjacent push/pop of the same register.
  failures = failures + checkOpcode("push/pop/ret peephole", b, "c3")

  b = a.newAsmBuilder()
  b = a.push_reg(b, "rax")
  b = a.mov_r32_imm32(b, "eax", 0x50000000)
  b = a.pop_reg(b, "rax")
  // The immediate ends in 0x50 too, but it makes PUSH and POP non-adjacent.
  failures = failures + checkOpcode("non-adjacent push/pop", b, "50b80000005058")

  b = a.newAsmBuilder()
  b = a.mark(b, "loop")
  b = a.nop(b)
  b = a.jmp(b, "loop")
  failures = failures + checkOpcode("short backward jmp", b, "90ebfd")

  b = a.newAsmBuilder()
  b = a.mark(b, "loop")
  b = a.nop(b)
  b = a.jcc(b, "ne", "loop")
  failures = failures + checkOpcode("short backward jcc", b, "9075fd")

  b = a.newAsmBuilder()
  b = a.jmp(b, "later")
  b = a.nop(b)
  b = a.mark(b, "later")
  if len(a.get_patches(b)) != 1 then
    print "FAIL: forward jmp patch was not recorded"
    failures = failures + 1
  end if
  b = a.resolve_defined_patches(b)
  if len(a.get_patches(b)) != 0 then
    print "FAIL: defined .text patch was not released"
    failures = failures + 1
  end if
  failures = failures + checkOpcode("forward jmp remains rel32", b, "e90100000090")

  b = a.newAsmBuilder()
  b = a.jmp(b, "deferred_later")
  b = a.resolve_defined_patches(b)
  b = a.nop(b)
  b = a.mark(b, "deferred_later")
  b = a.resolve_defined_patches(b)
  if len(a.get_patches(b)) != 1 then
    print "FAIL: deferred forward patch was lost before the final sweep"
    failures = failures + 1
  end if
  b = a.resolve_all_defined_patches(b)
  if len(a.get_patches(b)) != 0 then
    print "FAIL: final sweep did not resolve a deferred .text patch"
    failures = failures + 1
  end if
  failures = failures + checkOpcode("deferred forward jmp remains rel32", b, "e90100000090")

  b = a.newAsmBuilder()
  b = a.lea_rax_rip(b, "external_section_label")
  b = a.resolve_defined_patches(b)
  b = a.resolve_all_defined_patches(b)
  if len(a.get_patches(b)) != 1 then
    print "FAIL: unresolved section patch was released"
    failures = failures + 1
  end if

  failures = failures + checkLinuxThunkLocalBranches()
  failures = failures + checkRDataLabelScale()
  failures = failures + checkDataLabelScale()
  failures = failures + checkChunkedIndexedRead()
  failures = failures + checkAssemblerChunkBoundary()
  failures = failures + checkAssemblerMaterializedReuse()
  failures = failures + checkCallAndHelperTracking()

  if failures != 0 then return 6 end if

  print "OK: synchronized opcode golden + direct encoder smoke"
  return 0
end function
