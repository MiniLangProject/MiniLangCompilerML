import cyc.a
import std.assert as t
print "=== IMPORT CYCLE OK ==="
t.assertEq(cyc.a.a(), 11, "cyc.a.a")
t.assertEq(cyc.b.b(), 22, "cyc.b.b")
print "=== DONE ==="
