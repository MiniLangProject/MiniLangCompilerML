<#
Reject accidental growing-array concatenation in compiler hot paths.

The guarded functions must retain capacity-backed builders because repeated
`items = items + [value]` copies the complete prefix and dominates self-builds.
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$checks = @(
  @{ File = "mlc\codegen\codegen_stmt.ml"; Functions = @("_set_user_function", "_sort_id_label_pairs") },
  @{ File = "mlc\codegen\codegen_scope.ml"; Functions = @("_declare_in_current_scope", "declare_global_binding_root", "declare_const_binding_root_deferred") }
)
$worklistChecks = @(
  @{ File = "mlc\codegen\codegen_stmt.ml"; Functions = @("_infer_known_int_names", "_infer_known_value_types", "_fast_index_scan_loop") }
)
$indexedFactChecks = @(
  @{ File = "mlc\codegen\codegen_stmt.ml"; Function = "_infer_known_int_names"; Pattern = "return\s+candidate_index\b"; Message = "integer facts were converted back from their hash index" },
  @{ File = "mlc\codegen\codegen_stmt.ml"; Function = "_infer_known_value_types"; Pattern = "return\s+facts_index\b"; Message = "value-type facts were converted back from their hash index" },
  @{ File = "mlc\codegen\codegen_expr.ml"; Function = "_intflow_name_has"; Pattern = "fastmap_get\s*\("; Message = "integer fact lookup lost its indexed path" },
  @{ File = "mlc\codegen\codegen_expr.ml"; Function = "_opt_type_fact_get"; Pattern = "fastmap_get\s*\("; Message = "value-type lookup lost its indexed path" }
)

$failures = @()
foreach ($check in $checks) {
  $path = Join-Path $root $check.File
  $source = Get-Content -LiteralPath $path -Raw
  foreach ($functionName in $check.Functions) {
    $escaped = [Regex]::Escape($functionName)
    $match = [Regex]::Match(
      $source,
      "(?ms)^function(?:\s+inline)?\s+$escaped\s*\([^\r\n]*\).*?^end function\s*$"
    )
    if (-not $match.Success) {
      $failures += "$($check.File): function '$functionName' was not found"
      continue
    }
    if ([Regex]::IsMatch($match.Value, "\+\s*\[")) {
      $failures += "$($check.File): function '$functionName' reintroduced growing-array concatenation"
    }
  }
}

foreach ($check in $worklistChecks) {
  $path = Join-Path $root $check.File
  $source = Get-Content -LiteralPath $path -Raw
  foreach ($functionName in $check.Functions) {
    $escaped = [Regex]::Escape($functionName)
    $match = [Regex]::Match(
      $source,
      "(?ms)^function(?:\s+inline)?\s+$escaped\s*\([^\r\n]*\).*?^end function\s*$"
    )
    if (-not $match.Success) {
      $failures += "$($check.File): function '$functionName' was not found"
      continue
    }
    if ([Regex]::IsMatch($match.Value, "stack\s*=\s*stack\s*\+")) {
      $failures += "$($check.File): function '$functionName' reintroduced a copying statement worklist"
    }
  }
}

# Analysis already converges in hash tables. Guard the emission boundary so a
# future cleanup cannot silently rematerialize arrays and restore linear lookup
# for every variable expression in large functions.
foreach ($check in $indexedFactChecks) {
  $path = Join-Path $root $check.File
  $source = Get-Content -LiteralPath $path -Raw
  $escaped = [Regex]::Escape($check.Function)
  $match = [Regex]::Match(
    $source,
    "(?ms)^function(?:\s+inline)?\s+$escaped\s*\([^\r\n]*\).*?^end function\s*$"
  )
  if (-not $match.Success) {
    $failures += "$($check.File): function '$($check.Function)' was not found"
    continue
  }
  if (-not [Regex]::IsMatch($match.Value, $check.Pattern)) {
    $failures += "$($check.File): $($check.Message)"
  }
}

# The former helper flattened every statement-valued field through repeated
# array concatenation before callers copied the result into their worklists.
# Keep that allocator-heavy API retired; the replacement appends directly to
# an ArrayVector and the read-order scan visits fields in place.
$statementSourcePath = Join-Path $root "mlc\codegen\codegen_stmt.ml"
$statementSource = Get-Content -LiteralPath $statementSourcePath -Raw
if ([Regex]::IsMatch($statementSource, "\b_scan_stmt_children\s*\(")) {
  $failures += "mlc\codegen\codegen_stmt.ml: obsolete copying child-array scan was reintroduced"
}

# The serial object stream must retain one materialized semantic fragment state
# instead of rebuilding its global scope and lookup maps for every function
# batch. Binding ids still restart at the canonical value so target bytes stay
# identical to the historical clone-per-batch pipeline.
$compilerSourcePath = Join-Path $root "mlc\compiler.ml"
$compilerSource = Get-Content -LiteralPath $compilerSourcePath -Raw
$objectCompile = [Regex]::Match(
  $compilerSource,
  "(?ms)^function\s+compile_to_exe_opts_object\s*\([^\r\n]*\).*?^end function\s*$"
)
if (-not $objectCompile.Success) {
  $failures += "mlc\compiler.ml: object-pipeline compiler function was not found"
} else {
  if (-not [Regex]::IsMatch($objectCompile.Value, "codegen\.start_object_fragment\s*\(\s*mod_cg\s*\)")) {
    $failures += "mlc\compiler.ml: serial function batches no longer reuse one fragment state"
  }
  if (-not [Regex]::IsMatch($objectCompile.Value, "mod_cg\.state\.binding_id\s*=\s*cg\.state\.binding_id")) {
    $failures += "mlc\compiler.ml: reused fragments no longer restore deterministic binding ids"
  }
  if (-not [Regex]::IsMatch($objectCompile.Value, "fn_analysis_scratch\s*=\s*codegen\.new_function_analysis_scratch\s*\(\s*\)")) {
    $failures += "mlc\compiler.ml: object batches no longer share one function-analysis workspace"
  }
  if (-not [Regex]::IsMatch($objectCompile.Value, "emit_module_function_entries\s*\([^\r\n]*fn_analysis_scratch\s*\)")) {
    $failures += "mlc\compiler.ml: reusable function-analysis workspace is not passed across object batches"
  }
  if (-not [Regex]::IsMatch($compilerSource, "(?m)^const\s+OBJECT_EMISSION_GC_STRIDE\s*=\s*32\s*$")) {
    $failures += "mlc\compiler.ml: bounded object-emission GC stride is not 32 fragments"
  }
  if (-not [Regex]::IsMatch($compilerSource, "(?m)^const\s+OBJECT_LARGE_EMISSION_GC_STRIDE\s*=\s*64\s*$")) {
    $failures += "mlc\compiler.ml: large-program object-emission GC stride is not 64 fragments"
  }
  if (-not [Regex]::IsMatch($compilerSource, "(?m)^const\s+OBJECT_LARGE_EMISSION_FUNCTION_THRESHOLD\s*=\s*2048\s*$")) {
    $failures += "mlc\compiler.ml: large-program GC threshold is not 2048 functions"
  }
  if (-not [Regex]::IsMatch($objectCompile.Value, "(?:len\(fn_entries\)|fn_entry_count)\s*>\s*OBJECT_LARGE_EMISSION_FUNCTION_THRESHOLD")) {
    $failures += "mlc\compiler.ml: object emission no longer selects the large-program GC stride"
  }
  if (-not [Regex]::IsMatch($objectCompile.Value, "module_object_seq\s*%\s*fn_gc_stride")) {
    $failures += "mlc\compiler.ml: object emission no longer uses the selected GC stride"
  }
  # Every managed value read after the stride collection must be present in
  # the explicit root frontier. Missing paths were previously hidden by
  # --mem-probe and crashed a plain self-build immediately after object 127.
  foreach ($rootName in @("tmp_dir", "input_abs", "entry_path", "runtime_config", "output_exe")) {
    if (-not [Regex]::IsMatch(
        $objectCompile.Value,
        "_compile_codegen_keepalive\s*=\s*\[[^\]]*\b$rootName\b[^\]]*\]")) {
      $failures += "mlc\compiler.ml: object-emission GC frontier does not root '$rootName'"
    }
  }
  if (-not [Regex]::IsMatch($objectCompile.Value, "object_gc_roots\s*=\s*_compile_codegen_keepalive")) {
    $failures += "mlc\compiler.ml: object-emission GC frontier is not reloaded after collection"
  }
  foreach ($reloadName in @("load", "cg", "mod_cg", "fn_entries", "tmp_dir", "output_exe")) {
    if (-not [Regex]::IsMatch($objectCompile.Value, "\b$reloadName\s*=\s*object_gc_roots\s*\[")) {
      $failures += "mlc\compiler.ml: object-emission GC frontier does not reload '$reloadName'"
    }
  }
}

# Native compiler bootstraps keep the large reserve but start with a smaller
# commit on both hosts. This prevents orchestrator/emitter heap commits from
# multiplying without reducing the maximum heap available to large targets.
$buildPsSource = Get-Content -LiteralPath (Join-Path $root "build.ps1") -Raw
$buildShSource = Get-Content -LiteralPath (Join-Path $root "build.sh") -Raw
if (-not [Regex]::IsMatch($buildPsSource, '"--heap-commit"\s*,\s*"512m"')) {
  $failures += "build.ps1: self-host compiler initial heap commit is not 512 MiB"
}
if (-not [Regex]::IsMatch(
    $buildPsSource,
    '\$enableBootstrapProbe\s*=\s*-not\s+\$NoBootstrapProbe\s+-and\s+-not\s+\$script:CompilerIsPython')) {
  $failures += "build.ps1: Python bootstrap is no longer protected from the self-host-only --mem-probe flag"
}
if (-not [Regex]::IsMatch($buildShSource, "--heap-commit\s+512m")) {
  $failures += "build.sh: self-host compiler initial heap commit is not 512 MiB"
}

# Traversal and fact workspaces must retain their high-water allocations between
# serial functions. This is intentionally compiler-local and must not become a
# CgState field or a new module-global GC root, both of which alter target layout.
if (-not [Regex]::IsMatch($statementSource, "stack\s*=\s*t\.arr_vec_clear\s*\(\s*scratch\[0\]\s*\)")) {
  $failures += "mlc\codegen\codegen_stmt.ml: statement analysis no longer reuses its traversal vector"
}
if (-not [Regex]::IsMatch($statementSource, "candidate_index\s*=\s*_reset_analysis_map\s*\(\s*scratch\[3\]")) {
  $failures += "mlc\codegen\codegen_stmt.ml: integer analysis no longer reuses its fact map"
}
if (-not [Regex]::IsMatch($statementSource, "facts_index\s*=\s*_reset_analysis_map\s*\(\s*scratch\[4\]")) {
  $failures += "mlc\codegen\codegen_stmt.ml: value analysis no longer reuses its fact map"
}
if ([Regex]::IsMatch($statementSource, "(?m)^_function_analysis_scratch\s*=")) {
  $failures += "mlc\codegen\codegen_stmt.ml: analysis workspace became a module-global GC root"
}

# Long source literals and project trees must stay linear. These two paths run
# before or around every large build and previously copied their complete
# growing prefixes for each appended character/file.
$parserSource = Get-Content -LiteralPath (Join-Path $root "mlc\minilang_parser.ml") -Raw
$decodeString = [Regex]::Match(
  $parserSource,
  "(?ms)^function\s+_decode_string_raw\s*\([^\r\n]*\).*?^end function\s*$"
)
if (-not $decodeString.Success) {
  $failures += "mlc\minilang_parser.ml: string decoder function was not found"
} else {
  if (-not [Regex]::IsMatch($decodeString.Value, "StringBuilder\.withCapacity")) {
    $failures += "mlc\minilang_parser.ml: string decoder lost its capacity-backed builder"
  }
  if ([Regex]::IsMatch($decodeString.Value, "decoded\s*=\s*decoded\s*\+")) {
    $failures += "mlc\minilang_parser.ml: string decoder reintroduced immutable prefix copying"
  }
}

$projectSource = Get-Content -LiteralPath (Join-Path $root "mlc\project.ml") -Raw
$collectSources = [Regex]::Match(
  $projectSource,
  "(?ms)^function\s+_collect_ml_files_inner\s*\([^\r\n]*\).*?^end function\s*$"
)
if (-not $collectSources.Success) {
  $failures += "mlc\project.ml: project source collector was not found"
} else {
  if (-not [Regex]::IsMatch($collectSources.Value, "arr_vec_push") -or
      -not [Regex]::IsMatch($collectSources.Value, "fastmap_has")) {
    $failures += "mlc\project.ml: project source collector lost its indexed capacity-backed state"
  }
  if ([Regex]::IsMatch($collectSources.Value, "result_paths\s*=\s*result_paths\s*\+")) {
    $failures += "mlc\project.ml: project source collector reintroduced immutable array growth"
  }
}

# Windows compiler children must bypass cmd.exe; otherwise CRT quoting, percent
# expansion and trailing path separators can alter valid compiler arguments.
if (-not [Regex]::IsMatch($compilerSource, "_host_CreateProcessW\s*\(")) {
  $failures += "mlc\compiler.ml: Windows child compiler launch no longer uses CreateProcessW"
}

if ($failures.Count -gt 0) {
  foreach ($failure in $failures) { Write-Error $failure }
  exit 1
}

Write-Host "[PASS] compiler hot paths retain reusable fragments, linear source builders and indexed facts"
exit 0
