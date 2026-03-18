import doom.doomdef
import std.assert as t
print "=== SELF IMPORT OK ==="
t.assertEq(doom.doomdef.answer(), 42, "doom.doomdef.answer")
print "=== DONE ==="
