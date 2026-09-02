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

// Diagnostic compiler entry point that reports non-zero function counters.
//! Provides a reproducible call-profile harness for the self-hosted compiler.

import mlc.compiler as compiler

/// Print every instrumented function that ran in the current process.
function printNonzeroCallStats()
  stats = callStats()
  if typeof(stats) != "array" then return void end if
  for each stat in stats
    if stat.calls > 0 then
      print "[call-profile] name=" + stat.name + " calls=" + stat.calls
    end if
  end for
  return void
end function

/// Run the compiler and append the current process's call counters.
/// @param args Command-line arguments forwarded to the compiler.
/// @returns The compiler process exit code.
function main(args)
  result = compiler.run_cli(args)
  printNonzeroCallStats()
  return result
end function
