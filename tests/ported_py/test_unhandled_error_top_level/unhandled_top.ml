print "=== UNHANDLED ERROR TOP ==="
function boom()
  return error(7, "boom")
end function
boom()
print "SHOULD NOT REACH"
