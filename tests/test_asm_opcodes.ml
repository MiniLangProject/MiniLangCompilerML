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
  // Five near branches cover claim/wait/cached failure plus dlopen/dlsym
  // failure. The compare/exchange retry is intentionally a short branch.
  if seen != 5 then
    print "FAIL: Linux extern thunk resolver branch count expected=5 actual=" + seen
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
  if typeof(patched_raw) != "bytes" or len(patched_raw) != 4 then
    print "FAIL: assembler patch after materialization length"
    return 1
  end if
  if patched_raw[0] != 0xEB or patched_raw[1] != 1 or patched_raw[2] != 0x90 or patched_raw[3] != 0xC3 then
    print "FAIL: assembler patch after materialization bytes"
    return 1
  end if
  return 0
end function

/// Exercise rel8 limits, intervening labels/calls, byte chunks and relocation
/// chunks (including second-level pages). A call's opcode must never be patched.
function checkForwardRelaxation()
  failures = 0
  for each size in [0, 1, 126, 127, 128]
    b = a.jcc(a.newAsmBuilder(), "ne", "done")
    if size > 0 then for i = 1 to size b = a.nop(b) end for end if
    b = a.mark(b, "done")
    raw = a.finalize(b)
    expected = size + 2
    if size == 0 then expected = 0 end if
    if size == 128 then expected = size + 6 end if
    if len(raw) != expected then print "FAIL: forward branch limit " + size; failures = failures + 1 end if
    if size > 0 and size <= 127 then
      if raw[0] != 0x75 or raw[1] != size then print "FAIL: forward rel8 bytes"; failures = failures + 1 end if
    end if
  end for
  for each count in [0, 254, 255, 256, 16383, 65535]
    b = a.mark(a.newAsmBuilder(), "before")
    if count > 0 then for i = 1 to count b = a.call(b, "before") end for end if
    start = a.pos(b)
    b = a.jcc(b, "e", "done")
    b = a.mark(b, "middle")
    b = a.call(b, "before")
    b = a.lea_rax_rip(b, "done")
    b = a.mark(b, "done")
    raw = a.finalize(b)
    if raw[start] != 0x74 or raw[start + 1] != 12 or raw[start + 2] != 0xE8 then
      print "FAIL: forward relocation chunk " + count
      failures = failures + 1
    end if
    if a._label_pos(a.get_labels(b), "middle") != start + 2 then print "FAIL: forward label rebase"; failures = failures + 1 end if
    disp = (raw[start + 3] | (raw[start + 4] << 8) | (raw[start + 5] << 16) | (raw[start + 6] << 24)) & 0xFFFFFFFF
    if disp != ((0 - start - 7) & 0xFFFFFFFF) then print "FAIL: forward call rebase"; failures = failures + 1 end if
    if len(a.get_patches(b)) != count + 2 then print "FAIL: forward relocation count"; failures = failures + 1 end if
  end for
  b = a.newAsmBuilder()
  for i = 1 to 65533 b = a.nop(b) end for
  b = a.jmp(b, "end")
  b = a.nop(b)
  b = a.mark(b, "end")
  raw = a.finalize(b)
  if hex(slice(raw, 65533, 3)) != "eb0190" then print "FAIL: forward byte chunk"; failures = failures + 1 end if
  return failures
end function

/// Mirror the ordered-error fallthrough, rel8 boundary and adjacent join tests.
function checkAdjacentErrorJoins()
  failures = 0
  for each prefix in [0, 65531]
    for each size in [29, 126, 127, 128]
      b = a.emit(a.newAsmBuilder(), bytes(prefix, 144))
      b = a.jmp(b, "done")
      b = a.mark(b, "non_numeric")
      b = a.mov_r32_imm32(b, "ecx", 1200)
      b = a.lea_rdx_rip(b, "payload")
      b = a.call(b, "make_error")
      b = a.emit(b, bytes(size - 17, 144))
      // Do not emit a redundant JMP done: preserve the earlier candidate.
      b = a.mark(b, "done")
      b = a.nop(b)
      b = a.jmp(b, "following")
      b = a.mark(b, "neighbor")
      b = a.nop(b)
      b = a.mark(b, "following")
      b = a.mark(b, "make_error")
      b = a.ret(b)
      b = a.mark(b, "payload")
      b = a.emit(b, bytes(8))
      code = a.finalize(b)
      width = 2
      opcode = 0xEB
      if size > 127 then width = 5; opcode = 0xE9 end if
      body = prefix + width
      done = body + size
      labels = a.get_labels(b)
      if code[prefix] != opcode or a._label_pos(labels, "non_numeric") != body or a._label_pos(labels, "done") != done then
        print "FAIL: ordered error branch width"
        failures += 1
      end if
      if hex(slice(code, done + 1, 3)) != "eb0190" or a._label_pos(labels, "neighbor") != done + 3 then
        print "FAIL: adjacent ordered error join"
        failures += 1
      end if
      for each fixup in [[8, 12, "payload"], [13, 17, "make_error"]]
        pos = body + fixup[0]
        disp = code[pos] | (code[pos + 1] << 8) | (code[pos + 2] << 16) | (code[pos + 3] << 24)
        if disp != a._label_pos(labels, fixup[2]) - body - fixup[1] then
          print "FAIL: ordered error RIP/call relocation"
          failures += 1
        end if
      end for
    end for
  end for
  return failures
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

/// Verify shorter encodings against independent architectural opcode vectors.
function checkCompactEncodings()
  failures = 0
  failures = failures + checkOpcode("AND positive mask", a.and_r64_imm(a.newAsmBuilder(), "rax", 7), "83e007")
  failures = failures + checkOpcode("AND extended reg", a.and_r64_imm(a.newAsmBuilder(), "r8", 7), "4183e007")
  failures = failures + checkOpcode("AND mask boundary", a.and_r64_imm(a.newAsmBuilder(), "rax", 0x7FFFFFFF), "25ffffff7f")
  failures = failures + checkOpcode("AND negative mask", a.and_r64_imm(a.newAsmBuilder(), "rax", -1), "4883e0ff")
  failures = failures + checkOpcode("AND sign-extended mask", a.and_r64_imm(a.newAsmBuilder(), "rax", 0x80000000), "482500000080")
  failures = failures + checkOpcode("AND negative extended reg", a.and_r64_imm(a.newAsmBuilder(), "r8", -2147483648), "4981e000000080")
  failures = failures + checkOpcode("ADD imm8", a.add_r64_imm(a.newAsmBuilder(), "rax", 127), "4883c07f")
  failures = failures + checkOpcode("ADD accumulator", a.add_r64_imm(a.newAsmBuilder(), "rax", 128), "480580000000")
  failures = failures + checkOpcode("SUB accumulator", a.sub_r32_imm(a.newAsmBuilder(), "eax", 128), "2d80000000")
  failures = failures + checkOpcode("CMP accumulator", a.cmp_r64_imm(a.newAsmBuilder(), "rax", -129), "483d7fffffff")
  failures = failures + checkOpcode("XOR AL", a.xor_r8_imm8(a.newAsmBuilder(), "al", 255), "34ff")
  failures = failures + checkOpcode("OR R8B", a.or_r8_imm8(a.newAsmBuilder(), "r8b", 7), "4180c807")
  failures = failures + checkOpcode("TEST accumulator", a.test_r64_imm32(a.newAsmBuilder(), "rax", -1), "48a9ffffffff")
  failures = failures + checkOpcode("TEST accumulator alias", a.test_rax_imm32(a.newAsmBuilder(), 8), "48a908000000")
  failures = failures + checkOpcode("AND accumulator alias", a.and_rax_imm8(a.newAsmBuilder(), 7), "83e007")
  failures = failures + checkOpcode("CMP accumulator alias", a.cmp_rax_imm32(a.newAsmBuilder(), 128), "483d80000000")
  failures = failures + checkOpcode("TEST extended reg", a.test_r64_imm32(a.newAsmBuilder(), "r8", 7), "49f7c007000000")
  for each count in [0, 1, 2, 31, 32, 33, 63, 64, 65, 255, 257]
    suffix = "c1"
    tail = hex(bytes(1, count & 255))
    if (count & 255) == 1 then suffix = "d1"; tail = "" end if
    failures = failures + checkOpcode("SHL64 count=" + count, a.shl_r64_imm8(a.newAsmBuilder(), "rax", count), "48" + suffix + "e0" + tail)
    failures = failures + checkOpcode("SHR64 count=" + count, a.shr_r64_imm8(a.newAsmBuilder(), "r9", count), "49" + suffix + "e9" + tail)
    failures = failures + checkOpcode("SAR64 count=" + count, a.sar_r64_imm8(a.newAsmBuilder(), "rax", count), "48" + suffix + "f8" + tail)
    failures = failures + checkOpcode("SHL32 count=" + count, a.shl_r32_imm8(a.newAsmBuilder(), "r9d", count), "41" + suffix + "e1" + tail)
    failures = failures + checkOpcode("SHR32 count=" + count, a.shr_r32_imm8(a.newAsmBuilder(), "eax", count), suffix + "e8" + tail)
    failures = failures + checkOpcode("SAR32 count=" + count, a.sar_r32_imm8(a.newAsmBuilder(), "r9d", count), "41" + suffix + "f9" + tail)
  end for
  return failures
end function

/// Exercise branch inversion at code-page and relocation-chunk boundaries.
function checkCompactBranches()
  failures = 0
  conditions = ["o", "no", "b", "ae", "e", "ne", "be", "a", "s", "ns", "p", "np", "l", "ge", "le", "g"]
  for i = 0 to 15
    b = a.newAsmBuilder()
    b = a.jcc(b, conditions[i], "yes")
    b = a.jmp(b, "no")
    b = a.mark(b, "yes")
    b = a.nop(b)
    b = a.mark(b, "no")
    expected = "0f" + hex(bytes(1, 0x80 + (i ^ 1))) + "0100000090"
    failures = failures + checkOpcode("inverted " + conditions[i], b, expected)
  end for
  for each prefix in [0, 254, 255, 256]
    for each padding in [0, 4090, 4091, 4095]
      b = a.newAsmBuilder()
      i = 0
      while i < prefix
        b = a.call(b, "no")
        i = i + 1
      end while
      i = 0
      while i < padding
        b = a.nop(b)
        i = i + 1
      end while
      branch_start = a.pos(b)
      b = a.jcc(b, "e", "yes")
      b = a.jmp(b, "no")
      b = a.mark(b, "yes")
      b = a.resolve_defined_patches(b)
      b = a.nop(b)
      b = a.mark(b, "no")
      b = a.resolve_all_defined_patches(b)
      code = a.finalize(b)
      if len(code) != branch_start + 7 or code[branch_start + 1] != 0x85 or code[branch_start + 2] != 1 then
        print "FAIL: compact branch boundary prefix=" + prefix + " padding=" + padding
        failures = failures + 1
      end if
      i = 0
      while i < prefix
        offset = i * 5 + 1
        displacement = code[offset] | (code[offset + 1] << 8) | (code[offset + 2] << 16) | (code[offset + 3] << 24)
        if offset + 4 + displacement != branch_start + 7 then
          print "FAIL: compact branch earlier relocation"
          failures = failures + 1
        end if
        i = i + 1
      end while
    end for
  end for
  for each barrier in ["label", "nop"]
    b = a.newAsmBuilder()
    b = a.jcc(b, "e", "yes")
    if barrier == "label" then b = a.mark(b, "other_entry") else b = a.nop(b) end if
    b = a.jmp(b, "no")
    b = a.mark(b, "yes")
    b = a.nop(b)
    b = a.mark(b, "no")
    code = a.finalize(b)
    if code[1] != 0x84 or len(a.get_patches(b)) != 1 then
      print "FAIL: compact branch crossed " + barrier
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
  if s.contains(txt, "\"count\": 239") == false then
    print "FAIL: asm_opcodes_golden.json does not contain the synchronized 239-vector set"
    return 5
  end if

  failures = 0

  b = a.newAsmBuilder()
  b = a.bsf_r64_r64(b, "rax", "rcx")
  failures = failures + checkOpcode("BSF64 low", b, "480fbcc1")
  b = a.newAsmBuilder()
  b = a.bsf_r64_r64(b, "r9", "r10")
  failures = failures + checkOpcode("BSF64 high", b, "4d0fbcca")
  b = a.newAsmBuilder()
  b = a.bsr_r64_r64(b, "rdx", "rax")
  failures = failures + checkOpcode("BSR64 low", b, "480fbdd0")
  b = a.newAsmBuilder()
  b = a.bsr_r64_r64(b, "r15", "r8")
  failures = failures + checkOpcode("BSR64 high", b, "4d0fbdf8")
  b = a.newAsmBuilder()
  b = a.pclmulqdq_xmm_xmm_imm8(b, "xmm0", "xmm3", 16)
  failures = failures + checkOpcode("PCLMUL low", b, "660f3a44c310")
  b = a.newAsmBuilder()
  b = a.pclmulqdq_xmm_xmm_imm8(b, "xmm9", "xmm14", 1)
  failures = failures + checkOpcode("PCLMUL high", b, "66450f3a44ce01")
  b = a.newAsmBuilder()
  b = a.pand_xmm_xmm(b, "xmm9", "xmm14")
  b = a.psrldq_xmm_imm8(b, "xmm9", 8)
  b = a.pslldq_xmm_imm8(b, "xmm9", 4)
  failures = failures + checkOpcode("SSE2 reduction", b, "66450fdbce66410f73d90866410f73f904")
  if typeof(try(a.bsf_r64_r64(a.newAsmBuilder(), "eax", "rcx"))) != "error" then failures = failures + 1 end if
  if typeof(try(a.bsr_r64_r64(a.newAsmBuilder(), "rax", "ecx"))) != "error" then failures = failures + 1 end if
  if typeof(try(a.pclmulqdq_xmm_xmm_imm8(a.newAsmBuilder(), "xmm0", "xmm1", 256))) != "error" then failures = failures + 1 end if

  // Check RIP-relative addressing independently of generated golden vectors.
  b = a.newAsmBuilder()
  b = a.lea_r64_rip(b, "rcx", "target")
  b = a.mark(b, "target")
  failures = failures + checkOpcode("lea_r64_rip low register", b, "488d0d00000000")
  b = a.newAsmBuilder()
  b = a.mark(b, "target")
  b = a.lea_r64_rip(b, "r11", "target")
  failures = failures + checkOpcode("lea_r64_rip high register backward", b, "4c8d1df9ffffff")

  // Independently pin register-bit-test encodings, including both REX fields.
  b = a.newAsmBuilder()
  b = a.bt_r64_r64(b, "rax", "rcx")
  failures = failures + checkOpcode("bt_r64_r64 low registers", b, "480fa3c8")

  b = a.newAsmBuilder()
  b = a.bts_r64_r64(b, "rax", "rcx")
  failures = failures + checkOpcode("bts_r64_r64 low registers", b, "480fabc8")

  b = a.newAsmBuilder()
  b = a.bt_r64_r64(b, "r10", "r8")
  failures = failures + checkOpcode("bt_r64_r64 high registers", b, "4d0fa3c2")

  b = a.newAsmBuilder()
  b = a.bts_r64_r64(b, "r10", "r8")
  failures = failures + checkOpcode("bts_r64_r64 high registers", b, "4d0fabc2")

  b = a.newAsmBuilder()
  b = a.mul_r64(b, "r11")
  failures = failures + checkOpcode("mul_r64", b, "49f7e3")

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
  if len(a.get_patches(b)) != 0 then
    print "FAIL: relaxed forward jmp retained a relocation"
    failures = failures + 1
  end if
  b = a.resolve_defined_patches(b)
  if len(a.get_patches(b)) != 0 then
    print "FAIL: defined .text patch was not released"
    failures = failures + 1
  end if
  failures = failures + checkOpcode("short forward jmp", b, "eb0190")

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
  failures = failures + checkCompactEncodings()
  failures = failures + checkCompactBranches()
  failures = failures + checkRDataLabelScale()
  failures = failures + checkDataLabelScale()
  failures = failures + checkChunkedIndexedRead()
  failures = failures + checkAssemblerChunkBoundary()
  failures = failures + checkAssemblerMaterializedReuse()
  failures = failures + checkCallAndHelperTracking()
  failures = failures + checkForwardRelaxation()
  failures = failures + checkAdjacentErrorJoins()
  for prefix = 0 to 31
    b = a.newAsmBuilder()
    b = a.emit(b, bytes(prefix, 144))
    b = a.jcc(b, "e", "after")
    b = a.align_loop(b, 12)
    b = a.mark(b, "loop")
    loop_position = a.pos(b)
    if (12 + loop_position) % 16 != 0 then failures = failures + 1 end if
    b = a.nop(b)
    b = a.jmp(b, "loop")
    b = a.mark(b, "after")
    b = a.resolve_all_defined_patches(b)
    code = a.finalize(b)
    if slice(code, loop_position, 3) != fromHex("90ebfd") then failures = failures + 1 end if
  end for

  if failures != 0 then return 6 end if

  print "OK: synchronized opcode golden + direct encoder smoke"
  return 0
end function
