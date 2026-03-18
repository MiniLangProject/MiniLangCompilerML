import std.fs as fs
import std.string as s

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

  print "OK: asm_opcodes_golden.json present"
  return 0
end function
