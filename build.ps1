param(
  [string]$Compiler = "",
  [string]$Output = "",
  [switch]$NoReplace,
  [switch]$SkipSmoke,
  [switch]$KeepObjects,
  [switch]$NoBootstrapProbe
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSCommandPath

function Resolve-BuildPath {
  param([string]$Path)
  if ([System.IO.Path]::IsPathRooted($Path)) {
    return [System.IO.Path]::GetFullPath($Path)
  }
  return [System.IO.Path]::GetFullPath((Join-Path $Root $Path))
}

function Remove-CompilerObjects {
  param([string]$ExePath)
  if ($KeepObjects) { return }
  $objDir = Get-CompilerObjectDir $ExePath
  if ($objDir -and (Test-Path -LiteralPath $objDir)) {
    Remove-Item -LiteralPath $objDir -Recurse -Force
  }
}

function Get-CompilerObjectDir {
  param([string]$ExePath)
  $outDir = Split-Path -Parent $ExePath
  $stem = [System.IO.Path]::GetFileNameWithoutExtension($ExePath)
  $objDir = Join-Path (Join-Path $outDir "tmp") $stem
  $full = [System.IO.Path]::GetFullPath($objDir)
  $tempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
  if ($full.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase) -or
      $full.StartsWith($tempRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    return $full
  }
  return ""
}

function Invoke-LinkFallback {
  param(
    [string]$CompilerPath,
    [string]$EntryPath,
    [string]$StageExePath
  )

  $objDir = Get-CompilerObjectDir $StageExePath
  if ($objDir -eq "" -or -not (Test-Path -LiteralPath $objDir)) {
    return $false
  }

  $mloCount = @(Get-ChildItem -LiteralPath $objDir -Filter *.mlo -File -ErrorAction SilentlyContinue).Count
  if ($mloCount -le 0) {
    return $false
  }
  $supportObject = Join-Path $objDir "000_support.mlo"
  if (-not (Test-Path -LiteralPath $supportObject)) {
    return $false
  }

  Write-Host ""
  Write-Host "Retrying link from existing object directory..."
  Write-Host "Object dir: $objDir"
  Write-Host "Objects:    $mloCount"

  & $CompilerPath $EntryPath $StageExePath "--link-obj-dir" $objDir "--subsystem" "console" "--gc-limit" "64m"
  $linkExit = $LASTEXITCODE
  if ($linkExit -ne 0) {
    throw "Fallback link failed with exit code $linkExit"
  }
  return $true
}

if ($Compiler -eq "") {
  $Compiler = Join-Path $Root "build\mlc_win64.exe"
}
if ($Output -eq "") {
  $Output = Join-Path $Root "build\mlc_win64.exe"
}

$Compiler = Resolve-BuildPath $Compiler
$FinalOutput = Resolve-BuildPath $Output

if (-not (Test-Path -LiteralPath $Compiler)) {
  throw "Compiler not found: $Compiler"
}

$outDir = Split-Path -Parent $FinalOutput
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$baseName = [System.IO.Path]::GetFileNameWithoutExtension($FinalOutput)
$stageToken = ("" + $PID + "." + (Get-Date -Format "yyyyMMddHHmmss"))
$stageDir = Join-Path ([System.IO.Path]::GetTempPath()) ("mlc_build_" + $stageToken)
$stageOutput = Join-Path $stageDir ($baseName + ".next.exe")
$replaceFinal = -not $NoReplace
if ($NoReplace) {
  if ([string]::Equals($FinalOutput, $Compiler, [System.StringComparison]::OrdinalIgnoreCase)) {
    $FinalOutput = Join-Path $outDir ($baseName + ".next.exe")
  }
}
New-Item -ItemType Directory -Force -Path $stageDir | Out-Null

if (Test-Path -LiteralPath $stageOutput) {
  Remove-Item -LiteralPath $stageOutput -Force
}

$entry = Join-Path $Root "mlc_win64.ml"
$buildArgs = @(
  $entry,
  $stageOutput,
  "-I", $Root,
  "--heap-reserve", "4g",
  "--heap-commit", "512m",
  "--heap-shrink",
  "--heap-shrink-min", "128m",
  "--gc-limit", "384m"
)
if (-not $NoBootstrapProbe) {
  $buildArgs += "--mem-probe"
}

Write-Host "Compiler: $Compiler"
Write-Host "Entry:    $entry"
Write-Host "Stage:    $stageOutput"
if ($replaceFinal) {
  Write-Host "Output:   $FinalOutput"
} else {
  Write-Host "Output:   $FinalOutput"
}
if (-not $NoBootstrapProbe) {
  Write-Host "Bootstrap: mem-probe enabled"
}

$buildTimer = [System.Diagnostics.Stopwatch]::StartNew()
& $Compiler @buildArgs 2>&1 | ForEach-Object {
  $line = "" + $_
  if ($line -notmatch '^\[mem\]') {
    Write-Host $line
  }
}
$buildExit = $LASTEXITCODE

if ($buildExit -ne 0) {
  $linked = Invoke-LinkFallback $Compiler $entry $stageOutput
  if (-not $linked) {
    throw "Compiler build failed with exit code $buildExit"
  }
}
$buildTimer.Stop()
if (-not (Test-Path -LiteralPath $stageOutput)) {
  throw "Compiler build did not produce output: $stageOutput"
}

if (-not $SkipSmoke) {
  $pidText = "" + $PID
  $smokeSrc = Join-Path ([System.IO.Path]::GetTempPath()) ("mlc_build_smoke_" + $pidText + ".ml")
  $smokeExe = Join-Path ([System.IO.Path]::GetTempPath()) ("mlc_build_smoke_" + $pidText + ".exe")
  Set-Content -LiteralPath $smokeSrc -Encoding ASCII -Value @(
    'print "hello"',
    'x = 1',
    'print "x=" + x'
  )
  if (Test-Path -LiteralPath $smokeExe) {
    Remove-Item -LiteralPath $smokeExe -Force
  }

  $smokeTimer = [System.Diagnostics.Stopwatch]::StartNew()
  & $stageOutput $smokeSrc $smokeExe "--heap-reserve" "4g" "--heap-commit" "256m" "--gc-limit" "128m"
  $smokeCompileExit = $LASTEXITCODE
  if ($smokeCompileExit -ne 0) {
    throw "Smoke compile failed with exit code $smokeCompileExit"
  }
  & $smokeExe
  $smokeRunExit = $LASTEXITCODE
  $smokeTimer.Stop()
  if ($smokeRunExit -ne 0) {
    throw "Smoke executable failed with exit code $smokeRunExit"
  }

  Remove-CompilerObjects $smokeExe
  Remove-Item -LiteralPath $smokeSrc -Force -ErrorAction SilentlyContinue
  Remove-Item -LiteralPath $smokeExe -Force -ErrorAction SilentlyContinue
}

if ($replaceFinal) {
  $backup = Join-Path ([System.IO.Path]::GetTempPath()) ("mlc_win64_previous_" + $PID + ".exe")
  if (Test-Path -LiteralPath $backup) {
    Remove-Item -LiteralPath $backup -Force
  }

  try {
    if (Test-Path -LiteralPath $FinalOutput) {
      Move-Item -LiteralPath $FinalOutput -Destination $backup -Force
    }
    Move-Item -LiteralPath $stageOutput -Destination $FinalOutput -Force
    Remove-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue
  } catch {
    if ((Test-Path -LiteralPath $backup) -and -not (Test-Path -LiteralPath $FinalOutput)) {
      Move-Item -LiteralPath $backup -Destination $FinalOutput -Force
    }
    throw
  }
} else {
  if (Test-Path -LiteralPath $FinalOutput) {
    Remove-Item -LiteralPath $FinalOutput -Force
  }
  Move-Item -LiteralPath $stageOutput -Destination $FinalOutput -Force
}

Remove-CompilerObjects $stageOutput
if ($replaceFinal) {
  Remove-CompilerObjects $FinalOutput
}
if (-not $KeepObjects -and (Test-Path -LiteralPath $stageDir)) {
  Remove-Item -LiteralPath $stageDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host ("Build complete in {0:n3}s." -f $buildTimer.Elapsed.TotalSeconds)
if (-not $SkipSmoke) {
  Write-Host ("Smoke test complete in {0:n3}s." -f $smokeTimer.Elapsed.TotalSeconds)
}
if ($replaceFinal) {
  Write-Host "Wrote: $FinalOutput"
} else {
  Write-Host "Wrote: $FinalOutput"
}
