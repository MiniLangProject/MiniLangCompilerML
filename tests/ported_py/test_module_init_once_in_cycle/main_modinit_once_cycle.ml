import cyc.a
import std.assert as t
print "=== MODULE INIT ONCE CYCLE ==="
t.assertEq(cyc.a.getInitCount(), 1, "cyc.a init once")
t.assertEq(cyc.b.getInitCount(), 1, "cyc.b init once")
print "=== DONE ==="
