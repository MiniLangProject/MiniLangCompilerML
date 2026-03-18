package mlc.errors

struct CompileError
  message,
  pos,
  filename,
end struct

struct Diagnostic
  kind,
  message,
  filename,
  pos,
  source,
end struct

struct MultiCompileError
  diagnostics,
end struct

function newCompileError(message, pos, filename)
  return CompileError(message, pos, filename)
end function

function newDiagnostic(kind, message, filename, pos, source)
  return Diagnostic(kind, message, filename, pos, source)
end function

function newMultiCompileError(diags)
  return MultiCompileError(diags)
end function
