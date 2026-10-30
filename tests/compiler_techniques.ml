/// Cross-backend semantics for fused concat, region value numbering and
/// versioned byte loops, including their guarded fallback paths.
function stringMix(value)
  prefix = "a"
  return prefix + value + "c"
end function

function region(value as int) returns int
  first = value * 17 + value * 31
  second = value * 17 + value * 31
  value = value + 1
  third = value * 17 + value * 31
  return first + second + third
end function

function bytesSum(buffer as bytes) returns int
  total = 0
  for i = 0 to len(buffer) - 1
    total += buffer[i]
  end for
  return total
end function

function main(args)
  print stringMix("b")
  print stringMix("")
  print stringMix(42)
  print region(2)
  print bytesSum(bytes(4, 7))
  errorValue = try(bytesSum(bytes(0)))
  print errorValue.code
end function
