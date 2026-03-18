extern function GetTickCount() from "kernel32.dll" returns u32

function ok(cond, label)
  if cond then
    print label + " [OK]"
  else
    print label + " [FAIL]"
  end if
end function

function call0(f)
  return f()
end function

function make(f)
  return f
end function

struct Box
  fn
end struct

print "=== EXTERN VALUE RUNTIME ==="

// capture extern as value
f = GetTickCount
a = f()
b = f()
ok(b >= a, "direct value call")

// store in array and call via index-expression callee
arr = [f]
c = arr[0]()
d = arr[0]()
ok(d >= c, "array element call")

// store in struct field (note: bx.fn() is parsed as namespace call; use temp)
bx = Box(f)
h = bx.fn
e = h()
ok(e >= a, "struct field call")

// pass as argument / return from function
ok(call0(f) >= a, "passed as arg")
g = make(f)
ok(g() >= a, "returned value")

// allocate many ephemeral objects and run GC repeatedly, then call again
for i = 0 to 20000
  tmp = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" + i
  tmp2 = [tmp, i, [i, tmp]]
  if (i % 200) == 0 then
    gc_collect()
  end if
end for
gc_collect()
ok(arr[0]() >= a, "after gc_collect")

print "=== DONE ==="
