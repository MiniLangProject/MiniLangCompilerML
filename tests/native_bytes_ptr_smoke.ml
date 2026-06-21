extern function RtlMoveMemory(dest as ptr, src as bytes, count as int) from "kernel32.dll" symbol "RtlMoveMemory" returns ptr

function main(args)
  dst = bytes(4, 0)
  src = bytes("ABCD")
  p = nativeBytesPtr(dst)
  if typeof(p) != "int" then return 1 end if
  if p == 0 then return 2 end if
  RtlMoveMemory(p, src, 4)
  if decode(dst) != "ABCD" then return 3 end if
  if nativeBytesPtr("not bytes") != 0 then return 4 end if
  return 0
end function
