function add4(a, b, c, d)
  return a + b + c + d
end function

function gate(level, threshold)
  if level >= threshold then
    return 1
  else
    return 0
  end if
end function

print add4(1, 2, 3, 4)
print gate(5, 3)
