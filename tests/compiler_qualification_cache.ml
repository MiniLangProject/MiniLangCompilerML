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

// Regression coverage for package-suffix qualification caching.

import mlc.codegen.codegen_core as core
import mlc.codegen.codegen_expr as expr
import mlc.tools as t

struct SymbolMarker
  name,
end struct

function check(cond, message)
  if cond then return true end if
  print "[FAIL] " + message
  return false
end function

function _suffixCacheKey(state, suffix)
  return "@suffix|" + len(state.user_functions) + "|" + len(state.extern_sigs) + "|" + len(state.struct_fields) + "|" + len(state.enum_ids) + "|pkg.|." + suffix
end function

function main(args)
  ok = true
  state = core.cg_core_new("", "qualification-cache-test.ml", [], [], [], "windows-x64", [])
  state.current_file_prefix = "pkg"
  state.current_qname_prefix = "pkg.worker"
  state.user_functions = [["pkg.alpha.target", SymbolMarker("first")]]

  first = expr._qualify_identifier(state, "target")
  if check(first == "pkg.alpha.target", "unique suffix resolution") == false then ok = false end if

  unique_key = _suffixCacheKey(state, "target")
  if check(t.fastmap_get(state.qualify_cache, unique_key, "") == "pkg.alpha.target", "unique suffix cache entry") == false then ok = false end if

  // Changing the lexical generation must not force another static-pool scan.
  state.binding_id = state.binding_id + 1
  if check(expr._qualify_identifier(state, "target") == "pkg.alpha.target", "stable cache across binding generations") == false then ok = false end if

  // Pool growth invalidates the stable key. Two matching suffixes are
  // ambiguous, so qualification must retain the source spelling.
  state.user_functions = state.user_functions + [["pkg.beta.target", SymbolMarker("second")]]
  state.binding_id = state.binding_id + 1
  ambiguous = expr._qualify_identifier(state, "target")
  if check(ambiguous == "target", "pool growth invalidates unique suffix") == false then ok = false end if
  if check(t.fastmap_get(state.qualify_cache, _suffixCacheKey(state, "target"), true) == false, "ambiguous suffix cache entry") == false then ok = false end if

  // A later lexical binding remains authoritative even after an ambiguous
  // static result was cached.
  lexical = t.fastmap_new(8)
  lexical = t.fastmap_set(lexical, "pkg.target", SymbolMarker("lexical"))
  state.scope_stack = [[SymbolMarker("lexical")]]
  state.scope_index_stack = [lexical]
  state.binding_id = state.binding_id + 1
  if check(expr._qualify_identifier(state, "target") == "pkg.target", "lexical binding precedes suffix cache") == false then ok = false end if

  if ok == false then return 1 end if
  print "compiler qualification cache tests [OK]"
  return 0
end function
