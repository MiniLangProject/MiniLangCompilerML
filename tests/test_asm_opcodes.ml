import std.fs as fs
import std.string as s
import mlc.asm as a
import mlc.data as d
import mlc.tools as tools

function checkOpcode(name, builder, expected)
  actual = hex(a.finalize(builder))
  if actual != expected then
    print "FAIL: " + name + " expected=" + expected + " actual=" + actual
    return 1
  end if
  return 0
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
  if s.contains(txt, "\"count\": 227") == false then
    print "FAIL: asm_opcodes_golden.json does not contain the synchronized 227-vector set"
    return 5
  end if

  failures = 0
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

  failures = failures + checkRDataLabelScale()
  failures = failures + checkDataLabelScale()
  failures = failures + checkChunkedIndexedRead()

  if failures != 0 then return 6 end if

  print "OK: synchronized opcode golden + direct encoder smoke"
  return 0
end function
