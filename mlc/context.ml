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

// Lightweight records for breakable control-flow and exception regions.
//! Provides the mlc context package.

package mlc.context

/// Track breakable kind loop.
const BREAKABLE_KIND_LOOP = "loop"
/// Track breakable kind switch.
const BREAKABLE_KIND_SWITCH = "switch"

/// Track breakable ctx default continue label.
const BREAKABLE_CTX_DEFAULT_CONTINUE_LABEL = void
/// Track breakable ctx default break depth.
const BREAKABLE_CTX_DEFAULT_BREAK_DEPTH = 0
/// Track breakable ctx default continue depth.
const BREAKABLE_CTX_DEFAULT_CONTINUE_DEPTH = 0

/// Legacy loop-only context retained for compatible helper signatures.
struct LoopCtx
  /// Break label associated with `LoopCtx`.
  break_label,
  /// Continue label associated with `LoopCtx`.
  continue_label,
end struct

/// Unified loop/switch target plus cleanup depths for non-local exits.
struct BreakableCtx
  /// Kind associated with `BreakableCtx`.
  kind,
  /// Break label associated with `BreakableCtx`.
  break_label,
  /// Continue label associated with `BreakableCtx`.
  continue_label,
  /// Break depth associated with `BreakableCtx`.
  break_depth,
  /// Continue depth associated with `BreakableCtx`.
  continue_depth,
end struct

/// Construct the compact legacy loop context.
/// @param break_label Value supplied for `break_label`.
/// @param continue_label Value supplied for `continue_label`.
function newLoopCtx(break_label, continue_label)
  return LoopCtx(break_label, continue_label)
end function

/// Track normalize breakable ctx in the compiler context.
/// @internal
function _normalizeBreakableCtx(kind, break_label, continue_label, break_depth, continue_depth)
  // Python parity: continue_label is optional, depths default to 0.
  if typeof(continue_label) != "string" and typeof(continue_label) != "void" then
    continue_label = BREAKABLE_CTX_DEFAULT_CONTINUE_LABEL
  end if
  if typeof(break_depth) != "int" or break_depth < 0 then
    break_depth = BREAKABLE_CTX_DEFAULT_BREAK_DEPTH
  end if
  if typeof(continue_depth) != "int" or continue_depth < 0 then
    continue_depth = BREAKABLE_CTX_DEFAULT_CONTINUE_DEPTH
  end if
  return BreakableCtx(kind, break_label, continue_label, break_depth, continue_depth)
end function

/// Construct a validated breakable-region descriptor.
/// @param kind Value supplied for `kind`.
/// @param break_label Value supplied for `break_label`.
/// @param continue_label Value supplied for `continue_label`.
/// @param break_depth Value supplied for `break_depth`.
/// @param continue_depth Value supplied for `continue_depth`.
function newBreakableCtx(kind, break_label, continue_label, break_depth, continue_depth)
  return _normalizeBreakableCtx(kind, break_label, continue_label, break_depth, continue_depth)
end function
