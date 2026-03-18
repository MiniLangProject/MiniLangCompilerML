import "../../ns_import_tests/testlib.ml"
import "../../ns_import_tests/cases/structs/geom.ml"
print "=== NS/IMPORT STRUCT ==="
p = geom.Point(1, 2)
assertEq(p.x, 1, "geom.Point.x")
assertEq(p.y, 2, "geom.Point.y")
print "=== DONE ==="
