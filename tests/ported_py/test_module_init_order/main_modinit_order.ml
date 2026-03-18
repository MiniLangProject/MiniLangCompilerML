import mod.a
import std.assert as t
print "=== MODULE INIT ORDER ==="
t.assertEq(mod.b.getValue(), 10, "mod.b.getValue")
t.assertEq(mod.a.getValue(), 11, "mod.a.getValue")
print "=== DONE ==="
