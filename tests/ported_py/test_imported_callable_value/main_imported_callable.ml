import "callable_lib.ml"
import std.assert as t

print "=== IMPORTED CALLABLE VALUE ==="

f = add1

t.assertEq(typeof(f), "function", "imported fn typeof")
t.assertEq(f(41), 42, "imported fn direct value call")

arr = [add1]
t.assertEq(arr[0](5), 6, "imported fn array call")
t.assertEq(apply1(add1, 9), 10, "imported fn passed as arg")

print "=== DONE ==="
