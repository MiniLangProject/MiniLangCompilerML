/*
Copyright 2026 Nils Kopal

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// Structured compile errors and diagnostics shared across compiler phases.
//! Provides the mlc errors package.

package mlc.errors

/// Single fatal compiler error with optional source coordinates.
struct CompileError
  /// Stores the message member of `CompileError`.
  message,
  /// Stores the pos member of `CompileError`.
  pos,
  /// Stores the filename member of `CompileError`.
  filename,
end struct

/// Recoverable diagnostic used by keep-going compilation.
struct Diagnostic
  /// Stores the kind member of `Diagnostic`.
  kind,
  /// Stores the message member of `Diagnostic`.
  message,
  /// Stores the filename member of `Diagnostic`.
  filename,
  /// Stores the pos member of `Diagnostic`.
  pos,
  /// Stores the source member of `Diagnostic`.
  source,
end struct

/// Aggregate returned when multiple diagnostics must cross a phase boundary.
struct MultiCompileError
  /// Stores the diags member of `MultiCompileError`.
  diags,
end struct

/// Construct a fatal compile error record.
/// @param message Value supplied for `message`.
/// @param pos Value supplied for `pos`.
/// @param filename Value supplied for `filename`.
function newCompileError(message, pos, filename)
  return CompileError(message, pos, filename)
end function

/// Construct one normalized source diagnostic.
/// @param kind Value supplied for `kind`.
/// @param message Value supplied for `message`.
/// @param filename Value supplied for `filename`.
/// @param pos Value supplied for `pos`.
/// @param source Source value to process.
function newDiagnostic(kind, message, filename, pos, source)
  return Diagnostic(kind, message, filename, pos, source)
end function

/// Wrap an ordered diagnostic collection as one error value.
/// @param diags Value supplied for `diags`.
function newMultiCompileError(diags)
  return MultiCompileError(diags)
end function
