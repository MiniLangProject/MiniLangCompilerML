import ce.ok
import std.assert as t
function assertEq(actual, expected, label)
  return t.assertEq(actual, expected, label)
end function
print "=== IMPORT CONSTEXPR OK ==="
assertEq(ce.ok.A, 3, "ce.ok.A")
assertEq(ce.ok.x, 17, "ce.ok.x")
assertEq(ce.ok.Flags.All, 3, "ce.ok.Flags.All")
print "=== DONE ==="
