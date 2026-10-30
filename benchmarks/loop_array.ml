/// Dynamic array index loop used to measure guarded bounds elimination.
function arraySum(values as array) returns int
  total = 0
  for i = 0 to len(values) - 1
    total += values[i]
  end for
  return total
end function

function main(args)
  values = array(8192, 1)
  result = 0
  for repeat = 0 to 7999
    result += arraySum(values)
  end for
  print result
end function
