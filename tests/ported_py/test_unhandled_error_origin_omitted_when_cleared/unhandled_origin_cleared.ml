print "=== UNHANDLED ORIGIN CLEARED ==="
function boom()
  e = error(11, "boom cleared")
  e.script = ""
  e.func = ""
  e.line = 0
  return e
end function
boom()
