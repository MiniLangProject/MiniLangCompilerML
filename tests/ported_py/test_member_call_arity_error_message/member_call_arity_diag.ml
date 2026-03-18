print "=== CALL ARITY DIAG ==="
struct Holder
  f
end struct

function add2(a, b)
  return a + b
end function

h = Holder(add2)
// wrong: add2 expects 2 args
h.f(1)
print "SHOULD NOT REACH"
