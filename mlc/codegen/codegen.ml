package mlc.codegen.codegen
import mlc.codegen.codegen_builtins_alloc as bal
import mlc.codegen.codegen_core as core
import mlc.codegen.codegen_expr as exprmod
import mlc.codegen.codegen_memory as mem
import mlc.codegen.codegen_runtime as rt
import mlc.codegen.codegen_stmt as stmt
import mlc.codegen.codegen_scope as scope

// Facade module that mirrors the Python `Codegen` composition surface.
// The actual implementation still lives in the mixin-style modules; this file
// only wires construction and program emission together.
struct Codegen
  state,
end struct

function newCodegen(source, filename, import_aliases, extern_sigs, extern_structs)
  st = core.cg_core_new(source, filename, import_aliases, extern_sigs, extern_structs)
  st = scope.cg_scope_setup(st)
  return Codegen(st)
end function

function __init__(cg)
  if typeof(cg) != "struct" then return cg end if
  if typeof(cg.state) == "struct" then
    cg.state = core.cg_core_init(cg.state)
  end if
  return cg
end function

function emit_program(cg, program)
  if typeof(cg) != "struct" then return cg end if
  if typeof(cg.state) != "struct" then return cg end if
  st = core.cg_core_init(cg.state)
  st = stmt.emit_program(st, program)
  cg.state = st
  return cg
end function
