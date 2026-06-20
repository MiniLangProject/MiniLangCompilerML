extern function pow(x as double, y as double) from "msvcrt.dll" returns double

function main(args)
  direct = pow(2.0, 5.0)
  if direct != 32.0 then
    return 1
  end if

  f = pow
  via_value = f(3.0, 4.0)
  if via_value != 81.0 then
    return 2
  end if

  return 0
end function
