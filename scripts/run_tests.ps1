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
