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

if ($failures.Count -gt 0) {
  foreach ($failure in $failures) { Write-Error $failure }
  exit 1
}

Write-Host "[PASS] compiler hot paths contain no growing-array concatenations"
exit 0
