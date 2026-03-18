package mlc.codegen.codegen
import mlc.codegen.codegen_core as core
import mlc.codegen.codegen_stmt as stmt
import mlc.codegen.codegen_scope as scope

struct Codegen
  state,
end struct

function newCodegen(source, filename, import_aliases, extern_sigs, extern_structs)
  st = core.cg_core_new(source, filename, import_aliases, extern_sigs, extern_structs)
  st = scope.cg_scope_setup(st)
  return Codegen(st)
end function

function emit_program(cg, program)
  st = core.cg_core_init(cg.state)
  st = stmt.emit_program(st, program)
  cg.state = st
  return cg
end function
