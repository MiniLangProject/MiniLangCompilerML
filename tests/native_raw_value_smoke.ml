function main(args)
  b = bytes("x")
  raw = nativeRawValue(b)
  if typeof(raw) != "int" then return 1 end if
  if raw == 0 then return 2 end if
  b2 = nativeValueFromRaw(raw)
  if b2 != b then return 3 end if
  if nativeValueFromRaw("not raw") is void == false then return 4 end if
  return 0
end function
