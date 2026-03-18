import "geom/vec.ml"

import std.assert as t

function assertEq(actual, expected, label)
  return t.assertEq(actual, expected, label)
end function

print "=== PACKAGE DOTTED ==="
assertEq(geom.vec.add(2, 3), 5, "geom.vec.add")
print "=== DONE ==="
