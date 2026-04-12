import mlc.compiler as compiler

function run(args)
  return compiler.run_cli(args)
end function

function main(args)
  return run(args)
end function
