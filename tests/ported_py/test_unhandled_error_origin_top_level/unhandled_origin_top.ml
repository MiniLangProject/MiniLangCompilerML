print "=== UNHANDLED ORIGIN TOP ==="
function boom()
  x = 123
  return error(7, "boom")
end function
boom()
