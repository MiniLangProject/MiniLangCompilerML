print "TOP"

function main(args)
  print "MAIN"
  print "argc=" + len(args)
  if len(args) > 0 then print args[0] end if
  if len(args) > 1 then print args[1] end if
  if len(args) > 2 then print args[2] end if
  return 7
end function
