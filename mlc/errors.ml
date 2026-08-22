// Structured compile errors and diagnostics shared across compiler phases.
package mlc.errors

// Single fatal compiler error with optional source coordinates.
struct CompileError
  message,
  pos,
  filename,
end struct

// Recoverable diagnostic used by keep-going compilation.
struct Diagnostic
  kind,
  message,
  filename,
  pos,
  source,
end struct

// Aggregate returned when multiple diagnostics must cross a phase boundary.
struct MultiCompileError
  diags,
end struct

// Construct a fatal compile error record.
function newCompileError(message, pos, filename)
  return CompileError(message, pos, filename)
end function

// Construct one normalized source diagnostic.
function newDiagnostic(kind, message, filename, pos, source)
  return Diagnostic(kind, message, filename, pos, source)
end function

// Wrap an ordered diagnostic collection as one error value.
function newMultiCompileError(diags)
  return MultiCompileError(diags)
end function
