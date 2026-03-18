import "geom/vec.ml" as g

import std.assert as t

function assertEq(actual, expected, label)
  return t.assertEq(actual, expected, label)
end function

print "=== IMPORT AS ==="
assertEq(g.add(2, 3), 5, "g.add")
print "=== DONE ==="
