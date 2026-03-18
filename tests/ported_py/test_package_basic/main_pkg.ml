import "geom.ml"

import std.assert as t

function assertEq(actual, expected, label)
  return t.assertEq(actual, expected, label)
end function

print "=== PACKAGE BASIC ==="
assertEq(geom.add(2, 3), 5, "geom.add")
print "=== DONE ==="
