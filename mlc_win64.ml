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

//! Provides the native self-hosted compiler entry point.

import mlc.compiler as compiler

/// Forwards process arguments to the high-level compiler CLI.
/// @param args Command-line arguments passed to the compiler.
function run(args)
  return compiler.run_cli(args)
end function

/// Runs the language-level entry point used by generated executables.
/// @param args Command-line arguments passed to the compiler.
function main(args)
  return run(args)
end function
