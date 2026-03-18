function ok(cond, label)
  if cond then
    print label + " [OK]"
  else
    print label + " [FAIL]"
  end if
end function

function add1(x)
  return x + 1
end function

function apply1(f, x)
  return f(x)
end function

function ident(x)
  return x
end function

struct Pair
  a
  b
end struct

print "=== CALLABLE VALUES RUNTIME ==="

// user function as value
f = add1
ok(f(41) == 42, "user fn direct value call")
arr = [f]
ok(arr[0](5) == 6, "user fn array element call")
ok(apply1(f, 9) == 10, "user fn passed as arg")
g = ident(f)
ok(g(7) == 8, "user fn returned value")

// struct constructor as value
ctor = Pair
p = ctor(1, 2)
ok(p.a == 1, "struct ctor via value (a)")
ok(p.b == 2, "struct ctor via value (b)")
arrc = [ctor]
q = arrc[0](3, 4)
ok(q.a == 3, "struct ctor array call")

// builtin as value
l = len
ok(l([1,2,3]) == 3, "builtin len via value (array)")
ok(l("abc") == 3, "builtin len via value (string)")
arrl = [l]
ok(arrl[0]([0,1,2,3]) == 4, "builtin len in array")

// GC stress: allocate many temporaries, collect, and re-call values
for i = 0 to 20000
  tmp = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" + i
  tmp2 = [tmp, i, [i, tmp]]
  if (i % 200) == 0 then
    gc_collect()
  end if
end for
gc_collect()
ok(arr[0](41) == 42, "user fn after gc_collect")
t = arrc[0](7, 8)
ok(t.a == 7, "struct ctor after gc_collect")
ok(arrl[0]("abcd") == 4, "builtin len after gc_collect")

print "=== DONE ==="
