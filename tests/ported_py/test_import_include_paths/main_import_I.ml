import foo.bar

function main(args)
  // Reference imported symbol so resolution is required.
  return foo.bar.add(2, 3)
end function
