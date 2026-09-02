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

// Regression coverage for indexed lexical binding resolution.

import mlc.codegen.codegen_scope as scope
import mlc.tools as t

struct LookupState
  scope_stack,
  scope_index_stack,
end struct

struct LookupBinding
  name,
  marker,
end struct

function check(cond, message)
  if cond then return true end if
  print "[FAIL] " + message
  return false
end function

function main(args)
  ok = true
  outer = LookupBinding("value", "outer")
  inner = LookupBinding("value", "inner")
  hidden = LookupBinding("frame-only", "hidden")

  outer_index = t.fastmap_new(8)
  outer_index = t.fastmap_set(outer_index, "value", outer)
  inner_index = t.fastmap_new(8)
  inner_index = t.fastmap_set(inner_index, "value", inner)

  indexed = LookupState([[outer], [inner]], [outer_index, inner_index])
  hit = scope.cg_resolve_binding(indexed, "value")
  if check(typeof(hit) == "struct" and hit.marker == "inner", "nearest indexed binding") == false then ok = false end if
  if check(scope.cg_resolve_binding(indexed, "missing") == 0, "complete indexed miss") == false then ok = false end if

  // Complete indexes are authoritative even if a manually assembled frame is
  // inconsistent. Production state always updates the two structures together.
  authoritative = LookupState([[hidden]], [t.fastmap_new(8)])
  if check(scope.cg_resolve_binding(authoritative, "frame-only") == 0, "authoritative complete index") == false then ok = false end if

  // A mismatched stack represents legacy/partially constructed state and must
  // retain the compatibility scan rather than silently losing a binding.
  legacy = LookupState([[outer], [hidden]], [outer_index])
  legacy_hit = scope.cg_resolve_binding(legacy, "frame-only")
  if check(typeof(legacy_hit) == "struct" and legacy_hit.marker == "hidden", "legacy frame fallback") == false then ok = false end if

  if ok == false then return 1 end if
  print "compiler scope index tests [OK]"
  return 0
end function
