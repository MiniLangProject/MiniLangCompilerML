// Native compiler entrypoint kept intentionally thin for bootstrap stability.
import mlc.compiler as compiler

// Forward the process argument array to the high-level CLI.
function run(args)
  return compiler.run_cli(args)
end function

// Language-level entrypoint used by generated Windows executables.
function main(args)
  return run(args)
end function
