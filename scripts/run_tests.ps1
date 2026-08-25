<#
Compile and run the self-hosted compiler regression suite.

The runner validates the compiler CLI, compiled MiniLang harness, ABI/input
regressions, assembly listings and focused historical reproductions.
#>
param(
  [string]$Compiler = "",
  [string[]]$CompilerArgs = @(),
  [switch]$NoDefaultCompilerArgs,
  [switch]$SkipRunnerBuild,
  [switch]$SkipRepros,
  [switch]$KeepArtifacts,
  [switch]$ShowCompilerProgress,
  [string]$LogPath = "",
  [string]$ArtifactsDir = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $PSCommandPath
$Root = Split-Path -Parent $ScriptDir

function Resolve-RepoPath {
  param([string]$Path)
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return [System.IO.Path]::GetFullPath($Path)
  }
  return [System.IO.Path]::GetFullPath((Join-Path $Root $Path))
}

function Quote-Arg {
  param([string]$Value)
  if ($null -eq $Value) { return '""' }
  if ($Value -match '[\s"]') {
    return '"' + ($Value -replace '"', '\"') + '"'
  }
  return $Value
}

function Format-Command {
  param(
    [string]$FilePath,
    [string[]]$Arguments
  )
  $parts = @((Quote-Arg $FilePath))
  foreach ($arg in $Arguments) {
    $parts += (Quote-Arg $arg)
  }
  return ($parts -join " ")
}

function Write-LogLine {
  param([string]$Line)
  Add-Content -LiteralPath $script:ResolvedLogPath -Encoding UTF8 -Value $Line
}

function Should-Print-Line {
  param([string]$Line)
  if ($ShowCompilerProgress) { return $true }
  if ($Line -match '^\[(phase|obj|link)\]') { return $false }
  return $true
}

function Invoke-NativeStep {
  param(
    [string]$Name,
    [string]$FilePath,
    [string[]]$Arguments
  )

  Write-Host ""
  Write-Host "== $Name =="
  Write-Host ("> " + (Format-Command $FilePath $Arguments))
  Write-LogLine ""
  Write-LogLine "== $Name =="
  Write-LogLine ("> " + (Format-Command $FilePath $Arguments))

  $timer = [System.Diagnostics.Stopwatch]::StartNew()
  & $FilePath @Arguments 2>&1 | ForEach-Object {
    $line = "" + $_
    Write-LogLine $line
    if (Should-Print-Line $line) {
      Write-Host $line
    }
  }
  $exitCode = $LASTEXITCODE
  $timer.Stop()

  $summary = ("{0}: exit={1} time={2:n3}s" -f $Name, $exitCode, $timer.Elapsed.TotalSeconds)
  Write-Host $summary
  Write-LogLine $summary

  return [pscustomobject]@{
    Name = $Name
    ExitCode = $exitCode
    Seconds = $timer.Elapsed.TotalSeconds
  }
}

function Invoke-CompilerVersionCheck {
  param(
    [string]$Name,
    [string]$CompilerPath
  )

  Write-Host ""
  Write-Host "== $Name =="
  Write-LogLine ""
  Write-LogLine "== $Name =="
  $timer = [System.Diagnostics.Stopwatch]::StartNew()
  $expected = "MiniLang Compiler 1.1.0"
  $exitCode = 0

  foreach ($flag in @("-version", "--version")) {
    $lines = @(& $CompilerPath $flag 2>&1 | ForEach-Object { "" + $_ })
    $currentExit = [int]$LASTEXITCODE
    foreach ($line in $lines) {
      Write-Host $line
      Write-LogLine $line
    }
    if ($currentExit -ne 0 -or ($lines -join "`n").Trim() -ne $expected) {
      $exitCode = 1
    }
  }

  $timer.Stop()
  return [pscustomobject]@{
    Name = $Name
    ExitCode = $exitCode
    Seconds = $timer.Elapsed.TotalSeconds
  }
}

function Compare-BinaryArtifacts {
  param(
    [string]$Name,
    [string]$ExpectedPath,
    [string]$ActualPath
  )

  $timer = [System.Diagnostics.Stopwatch]::StartNew()
  $same = (Test-Path -LiteralPath $ExpectedPath) -and (Test-Path -LiteralPath $ActualPath)
  $expectedHash = ""
  $actualHash = ""
  if ($same) {
    $expectedHash = (Get-FileHash -LiteralPath $ExpectedPath -Algorithm SHA256).Hash
    $actualHash = (Get-FileHash -LiteralPath $ActualPath -Algorithm SHA256).Hash
    $same = $expectedHash -ceq $actualHash
  }
  $timer.Stop()

  $label = if ($same) { "[PASS]" } else { "[FAIL]" }
  $detail = "$label $Name expected=$expectedHash actual=$actualHash"
  Write-Host $detail
  Write-LogLine $detail
  return [pscustomobject]@{
    Name = $Name
    ExitCode = $(if ($same) { 0 } else { 1 })
    Seconds = $timer.Elapsed.TotalSeconds
  }
}

function Remove-TestArtifacts {
  if ($KeepArtifacts) { return }

  $rtPattern = Join-Path $Root "tests\_rt_*.exe"
  Get-ChildItem -Path $rtPattern -ErrorAction SilentlyContinue | ForEach-Object {
    $full = [System.IO.Path]::GetFullPath($_.FullName)
    if ($full.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
      Remove-Item -LiteralPath $full -Force
    }
  }

  $testsTmp = Join-Path $Root "tests\tmp"
  if (Test-Path -LiteralPath $testsTmp) {
    $fullTestsTmp = [System.IO.Path]::GetFullPath($testsTmp)
    if ($fullTestsTmp.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
      Remove-Item -LiteralPath $fullTestsTmp -Recurse -Force
    }
  }

  if (Test-Path -LiteralPath $script:ResolvedArtifactsDir) {
    $fullArtifacts = [System.IO.Path]::GetFullPath($script:ResolvedArtifactsDir)
    if ($fullArtifacts.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase) -and
        -not [string]::Equals($fullArtifacts, $Root, [System.StringComparison]::OrdinalIgnoreCase)) {
      Remove-Item -LiteralPath $fullArtifacts -Recurse -Force
    }
  }
}

if ($Compiler -eq "") {
  $Compiler = Join-Path $Root "build\mlc_win64.exe"
}
if ($ArtifactsDir -eq "") {
  $ArtifactsDir = Join-Path $Root "build\test-bin"
}
if ($LogPath -eq "") {
  $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
  $LogPath = Join-Path $Root ("build\test-logs\run-tests-" + $stamp + ".log")
}

$Compiler = Resolve-RepoPath $Compiler
$script:ResolvedArtifactsDir = Resolve-RepoPath $ArtifactsDir
$script:ResolvedLogPath = Resolve-RepoPath $LogPath

if (-not (Test-Path -LiteralPath $Compiler)) {
  throw "Compiler not found: $Compiler"
}

New-Item -ItemType Directory -Force -Path $script:ResolvedArtifactsDir | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $script:ResolvedLogPath) | Out-Null
Set-Content -LiteralPath $script:ResolvedLogPath -Encoding UTF8 -Value @(
  "MiniLang test run",
  ("Root: " + $Root),
  ("Compiler: " + $Compiler)
)

$defaultArgs = @(
  "--heap-reserve", "4g",
  "--heap-commit", "512m",
  "--heap-shrink",
  "--heap-shrink-min", "128m",
  "--gc-limit", "384m"
)

$effectiveCompilerArgs = @()
if (-not $NoDefaultCompilerArgs) {
  $effectiveCompilerArgs += $defaultArgs
}
$effectiveCompilerArgs += $CompilerArgs

$results = @()
$overallTimer = [System.Diagnostics.Stopwatch]::StartNew()

try {
  $concatGuard = Join-Path $ScriptDir "check_hotpath_concats.ps1"
  & $concatGuard
  if ($LASTEXITCODE -ne 0) { throw "Compiler hot-path concatenation guard failed." }

  $results += Invoke-CompilerVersionCheck "compiler version CLI" $Compiler

  $runnerSrc = Join-Path $Root "tests\runtests.ml"
  $runnerExe = Join-Path $script:ResolvedArtifactsDir "runtests.exe"

  if (-not $SkipRunnerBuild) {
    $runnerBuildArgs = @($runnerSrc, $runnerExe, "-I", $Root) + $effectiveCompilerArgs
    $results += Invoke-NativeStep "compile ML test runner" $Compiler $runnerBuildArgs
    if ($results[-1].ExitCode -ne 0) { throw "Failed to compile test runner." }
  } elseif (-not (Test-Path -LiteralPath $runnerExe)) {
    throw "Test runner not found: $runnerExe"
  }

  $runnerArgs = @($Compiler) + $effectiveCompilerArgs
  $results += Invoke-NativeStep "run ML test harness" $runnerExe $runnerArgs

  $nativePrimitiveCases = @(
    [pscustomobject]@{ Name = "checksum runtime"; Source = "checksum_runtime.ml" },
    [pscustomobject]@{ Name = "SIMD search differential"; Source = "simd_search.ml" },
    [pscustomobject]@{ Name = "CNG crypto vectors"; Source = "crypto_cng.ml" }
  )
  foreach ($nativeCase in $nativePrimitiveCases) {
    $nativeSource = Join-Path $Root ("tests\" + $nativeCase.Source)
    $nativeStem = [System.IO.Path]::GetFileNameWithoutExtension($nativeCase.Source)
    $nativeExe = Join-Path $script:ResolvedArtifactsDir ($nativeStem + ".exe")
    $nativeArgs = @($nativeSource, $nativeExe, "-I", $Root) + $effectiveCompilerArgs
    $results += Invoke-NativeStep ("compile " + $nativeCase.Name) $Compiler $nativeArgs
    if ($results[-1].ExitCode -eq 0) {
      $results += Invoke-NativeStep ("run " + $nativeCase.Name) $nativeExe @()
    }
  }

  # The object pipeline is a serialization boundary for one canonical codegen
  # stream. Guard both optimization-heavy and cross-module programs so layout,
  # constant pooling and module initialization cannot drift from normal builds.
  $parityCompilerArgs = @($effectiveCompilerArgs | Where-Object { $_ -ne "--object-pipeline" })
  $objectParityCases = @(
    [pscustomobject]@{
      Name = "entry initializer inline"
      Source = Join-Path $Root "tests\object_entry_inline.ml"
      Includes = @($Root)
      Args = @()
    },
    [pscustomobject]@{
      Name = "codegen optimizations"
      Source = Join-Path $Root "tests\codegen_optimizations.ml"
      Includes = @($Root)
      Args = @()
    },
    [pscustomobject]@{
      Name = "module initialization"
      Source = Join-Path $Root "tests\ported_py\test_module_init_order\main_modinit_order.ml"
      Includes = @((Join-Path $Root "tests\ported_py\test_module_init_order"), $Root)
      Args = @()
    },
    [pscustomobject]@{
      Name = "conditional compilation"
      Source = Join-Path $Root "tests\conditional_compilation.ml"
      Includes = @($Root)
      Args = @("-DFEATURE=true", '-DLABEL="enabled"')
    }
  )
  foreach ($parityCase in $objectParityCases) {
    $stem = ($parityCase.Name -replace '[^A-Za-z0-9]+', '_').Trim('_').ToLowerInvariant()
    $monoExe = Join-Path $script:ResolvedArtifactsDir ($stem + "_monolithic.exe")
    $objectExe = Join-Path $script:ResolvedArtifactsDir ($stem + "_object.exe")
    $includeArgs = @()
    foreach ($includeRoot in $parityCase.Includes) {
      $includeArgs += @("-I", $includeRoot)
    }
    $monoArgs = @($parityCase.Source, $monoExe) + $includeArgs + $parityCompilerArgs + $parityCase.Args
    $objectArgs = @($parityCase.Source, $objectExe) + $includeArgs + $parityCompilerArgs + $parityCase.Args + @("--object-pipeline")
    $results += Invoke-NativeStep ("compile parity monolithic: " + $parityCase.Name) $Compiler $monoArgs
    if ($results[-1].ExitCode -ne 0) { continue }
    $results += Invoke-NativeStep ("compile parity object: " + $parityCase.Name) $Compiler $objectArgs
    if ($results[-1].ExitCode -ne 0) { continue }
    $results += Compare-BinaryArtifacts ("object byte identity: " + $parityCase.Name) $monoExe $objectExe
  }

  $inputSrc = Join-Path $Root "tests\input_length_regression.ml"
  $inputExe = Join-Path $script:ResolvedArtifactsDir "input_length_regression.exe"
  $inputBuildArgs = @($inputSrc, $inputExe, "-I", $Root) + $effectiveCompilerArgs
  $results += Invoke-NativeStep "compile input ABI regression" $Compiler $inputBuildArgs
  if ($results[-1].ExitCode -eq 0) {
    Write-Host ""
    Write-Host "== run input ABI regression =="
    Write-LogLine ""
    Write-LogLine "== run input ABI regression =="
    $inputTimer = [System.Diagnostics.Stopwatch]::StartNew()
    $inputOutput = @(@("show tables;", "\q") | & $inputExe 2>&1 | ForEach-Object { "" + $_ })
    $inputExit = $LASTEXITCODE
    $inputTimer.Stop()
    foreach ($line in $inputOutput) {
      Write-Host $line
      Write-LogLine $line
    }
    if ($inputExit -eq 0 -and -not ($inputOutput -contains "[OK] input ABI length")) {
      $inputExit = 1
    }
    $results += [pscustomobject]@{
      Name = "run input ABI regression"
      ExitCode = $inputExit
      Seconds = $inputTimer.Elapsed.TotalSeconds
    }
  }

  $listingSrc = Join-Path $Root "tests\native_raw_value_smoke.ml"
  $listingExe = Join-Path $script:ResolvedArtifactsDir "asm_listing_smoke.exe"
  $listingPath = Join-Path $script:ResolvedArtifactsDir "asm_listing_smoke.asm"
  $listingArgs = @(
    $listingSrc, $listingExe, "-I", $Root,
    "--asm", "--asm-out", $listingPath, "--asm-data", "--asm-pe"
  ) + $effectiveCompilerArgs
  $results += Invoke-NativeStep "compile assembly listing smoke" $Compiler $listingArgs
  if ($results[-1].ExitCode -eq 0) {
    $listingOk = Test-Path -LiteralPath $listingPath
    if ($listingOk) {
      $listingText = Get-Content -LiteralPath $listingPath -Raw
      $listingOk = $listingText.Contains(".text") -and
                   $listingText.Contains(".rdata") -and
                   $listingText.Contains(".idata")
    }
    $listingResult = [pscustomobject]@{
      Name = "verify assembly listing contents"
      ExitCode = $(if ($listingOk) { 0 } else { 1 })
      Seconds = 0.0
    }
    $results += $listingResult
    $listingLabel = if ($listingOk) { "[PASS]" } else { "[FAIL]" }
    Write-Host ($listingLabel + " assembly listing contents")
    Write-LogLine ($listingLabel + " assembly listing contents")
  }

  if (-not $SkipRepros) {
    $repros = @(
      "tests\psprites_repro.ml",
      "tests\psprite_action_repro.ml"
    )

    foreach ($rel in $repros) {
      $src = Join-Path $Root $rel
      $stem = [System.IO.Path]::GetFileNameWithoutExtension($src)
      $exe = Join-Path $script:ResolvedArtifactsDir ($stem + ".exe")

      $compileArgs = @($src, $exe, "-I", $Root) + $effectiveCompilerArgs
      $results += Invoke-NativeStep ("compile " + $stem) $Compiler $compileArgs
      if ($results[-1].ExitCode -ne 0) { continue }

      $results += Invoke-NativeStep ("run " + $stem) $exe @()
    }
  }
} finally {
  $overallTimer.Stop()
  Remove-TestArtifacts
}

$failed = @($results | Where-Object { $_.ExitCode -ne 0 })

Write-Host ""
Write-Host "== Summary =="
foreach ($result in $results) {
  Write-Host ("{0}: exit={1} time={2:n3}s" -f $result.Name, $result.ExitCode, $result.Seconds)
}
Write-Host ("Total time: {0:n3}s" -f $overallTimer.Elapsed.TotalSeconds)
Write-Host ("Log: " + $script:ResolvedLogPath)

Write-LogLine ""
Write-LogLine "== Summary =="
foreach ($result in $results) {
  Write-LogLine ("{0}: exit={1} time={2:n3}s" -f $result.Name, $result.ExitCode, $result.Seconds)
}
Write-LogLine ("Total time: {0:n3}s" -f $overallTimer.Elapsed.TotalSeconds)

if ($failed.Count -gt 0) {
  Write-Host ("FAILED steps: " + $failed.Count)
  exit 1
}

Write-Host "OK"
exit 0
