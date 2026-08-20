import std.fs as fs
import std.string as s
import mlc.asm as a

function checkOpcode(name, builder, expected)
  actual = hex(a.finalize(builder))
  if actual != expected then
    print "FAIL: " + name + " expected=" + expected + " actual=" + actual
    return 1
  end if
  return 0
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
  if s.contains(txt, "\"count\": 221") == false then
    print "FAIL: asm_opcodes_golden.json does not contain the synchronized 221-vector set"
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
  b = a.push_reg(b, "r11")
  b = a.pop_reg(b, "r11")
  b = a.ret(b)
  // Both encoders peephole away an adjacent push/pop of the same register.
  failures = failures + checkOpcode("push/pop/ret peephole", b, "c3")

  if failures != 0 then return 6 end if

  print "OK: synchronized opcode golden + direct encoder smoke"
  return 0
end function
