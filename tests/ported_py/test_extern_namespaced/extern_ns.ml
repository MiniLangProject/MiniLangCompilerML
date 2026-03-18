import "winapi.ml" as w

function ok(cond, label)
  if cond then
    print label + " [OK]"
  else
    print label + " [FAIL]"
  end if
end function

print "=== EXTERN NAMESPACED ==="
namespace win32
  extern function GetCurrentProcessId() from "kernel32.dll" returns u32
end namespace

pid = win32.GetCurrentProcessId()
ok(pid > 0, "win32.GetCurrentProcessId > 0")

a = w.GetTickCount()
b = w.GetTickCount()
ok(b >= a, "w.GetTickCount monotonic")
print "=== DONE ==="
