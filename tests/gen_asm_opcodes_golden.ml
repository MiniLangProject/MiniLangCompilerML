import std.fs as fs

function main(args)
  out_path = "tests\\asm_opcodes_golden.json"
  if fs.exists(out_path) == false then
    print "asm_opcodes_golden.json not found"
    print "Please provide the golden file before running opcode tests."
    return 2
  end if

  print "asm_opcodes_golden.json already present - nothing to regenerate in ML mode."
  return 0
end function
