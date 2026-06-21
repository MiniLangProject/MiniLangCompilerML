extern function CallWindowProcW(prev as ptr, hwnd as ptr, msg as u32, wParam as ptr, lParam as ptr) from "user32.dll" symbol "CallWindowProcW" returns ptr

function smokeWndProc(hwnd, msg, wParam, lParam)
  if hwnd != 0 then return 11 end if
  if wParam != 44 then return 12 end if
  if lParam != 55 then return 13 end if
  return msg + 7
end function

function main(args)
  cb = nativeCallback(smokeWndProc, "wndproc")
  if typeof(cb) != "int" then return 1 end if
  if cb == 0 then return 2 end if

  r = CallWindowProcW(cb, 0, 1234, 44, 55)
  if r != 1241 then
    print "unexpected callback result: " + r
    return 3
  end if
  return 0
end function
