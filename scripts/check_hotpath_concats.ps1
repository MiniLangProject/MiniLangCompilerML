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

if ($failures.Count -gt 0) {
  foreach ($failure in $failures) { Write-Error $failure }
  exit 1
}

Write-Host "[PASS] compiler hot paths retain capacity-backed worklists and indexed facts"
exit 0
