import std.assert as t

function cp_f()
  return 1
end function

function cp_g()
  // cp_f called twice per cp_g call
  return cp_f() + cp_f()
end function

print "=== CALL PROFILE ==="
cp_g()
cp_g()

stats = callStats()
f_calls = 0
g_calls = 0
for each s in stats
  if s.name == "cp_f" then f_calls = s.calls end if
  if s.name == "cp_g" then g_calls = s.calls end if
end for

t.assertEq(f_calls, 4, "callprof: cp_f calls")
t.assertEq(g_calls, 2, "callprof: cp_g calls")
print "=== DONE ==="
