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
$script:ArtifactsBaseDir = ""
$script:ArtifactOwnerToken = ""
$script:ArtifactOwnerMarker = ""

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

function Test-PathContainedBy {
  # Compare complete path components instead of accepting sibling names that
  # merely share a textual prefix with the intended parent directory.
  param(
    [string]$Path,
    [string]$Parent
  )
  $fullPath = [System.IO.Path]::GetFullPath($Path).TrimEnd(
    [System.IO.Path]::DirectorySeparatorChar,
    [System.IO.Path]::AltDirectorySeparatorChar)
  $fullParent = [System.IO.Path]::GetFullPath($Parent).TrimEnd(
    [System.IO.Path]::DirectorySeparatorChar,
    [System.IO.Path]::AltDirectorySeparatorChar)
  if ([string]::Equals($fullPath, $fullParent, [System.StringComparison]::OrdinalIgnoreCase)) {
    return $false
  }
  $prefix = $fullParent + [System.IO.Path]::DirectorySeparatorChar
  return $fullPath.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)
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
  $expected = "MiniLang Compiler 1.2.1"
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

function Invoke-ExpectedCompilerFailure {
  param(
    [string]$Name,
    [string]$CompilerPath,
    [string[]]$Arguments,
    [string]$ExpectedText
  )
  Write-Host ""
  Write-Host "== $Name =="
  Write-LogLine ""
  Write-LogLine "== $Name =="
  $timer = [System.Diagnostics.Stopwatch]::StartNew()
  $lines = @(& $CompilerPath @Arguments 2>&1 | ForEach-Object { "" + $_ })
  $nativeExit = [int]$LASTEXITCODE
  foreach ($line in $lines) { Write-Host $line; Write-LogLine $line }
  $passed = $nativeExit -ne 0 -and (($lines -join "`n") -like ("*" + $ExpectedText + "*"))
  $timer.Stop()
  return [pscustomobject]@{
    Name = $Name
    ExitCode = $(if ($passed) { 0 } else { 1 })
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

function Test-LinuxRuntimeBlobLayout {
  param([string]$Name)

  $timer = [System.Diagnostics.Stopwatch]::StartNew()
  $sourcePath = Join-Path $Root "mlc\linux_runtime.ml"
  $source = Get-Content -LiteralPath $sourcePath -Raw
  $rawMatch = [regex]::Match(
    $source,
    'function _runtime_blob_raw\(\)\s+.*?return fromHex\("([0-9a-f]+)"\)',
    [System.Text.RegularExpressions.RegexOptions]::Singleline)
  $pthreadMatch = [regex]::Match(
    $source,
    'function _pthread_runtime_blob\(\)\s+return fromHex\("([0-9a-f]+)"\)',
    [System.Text.RegularExpressions.RegexOptions]::Singleline)
  $passed = $rawMatch.Success -and $pthreadMatch.Success

  $constant = @{}
  foreach ($constantName in @(
      "RUNTIME_LEGACY_THREAD_START", "RUNTIME_LEGACY_THREAD_END",
      "RUNTIME_PTHREAD_CREATE_PATCH", "RUNTIME_PTHREAD_WAIT_PATCH",
      "RUNTIME_PTHREAD_CLOSE_PATCH")) {
    $match = [regex]::Match($source, "const $constantName = ([0-9]+)")
    if (-not $match.Success) {
      $passed = $false
    } else {
      $constant[$constantName] = [int]$match.Groups[1].Value
    }
  }

  if ($passed) {
    $rawBytes = $rawMatch.Groups[1].Value.Length / 2
    $pthreadHex = $pthreadMatch.Groups[1].Value
    $pthreadBytes = $pthreadHex.Length / 2
    $start = $constant["RUNTIME_LEGACY_THREAD_START"]
    $end = $constant["RUNTIME_LEGACY_THREAD_END"]
    $finalBytes = $start + $pthreadBytes + ($rawBytes - $end)
    $passed = ($rawBytes -eq 1785 -and $pthreadBytes -eq 1077 -and
               $start -eq 497 -and $end -eq 1361 -and $finalBytes -eq 1998)

    foreach ($patchName in @(
        "RUNTIME_PTHREAD_CREATE_PATCH", "RUNTIME_PTHREAD_WAIT_PATCH",
        "RUNTIME_PTHREAD_CLOSE_PATCH")) {
      $relative = $constant[$patchName] - $start
      if ($relative -lt 2 -or $relative + 3 -ge $pthreadBytes) {
        $passed = $false
        continue
      }
      $opcode = $pthreadHex.Substring(($relative - 2) * 2, 4)
      if ($opcode -cne "ff15") { $passed = $false }
    }
  }

  $timer.Stop()
  $label = if ($passed) { "[PASS]" } else { "[FAIL]" }
  $detail = "$label $Name"
  Write-Host $detail
  Write-LogLine $detail
  return [pscustomobject]@{
    Name = $Name
    ExitCode = $(if ($passed) { 0 } else { 1 })
    Seconds = $timer.Elapsed.TotalSeconds
  }
}

function Remove-TestArtifacts {
  if ($KeepArtifacts) { return }

  if (Test-Path -LiteralPath $script:ResolvedArtifactsDir) {
    $fullArtifacts = [System.IO.Path]::GetFullPath($script:ResolvedArtifactsDir)
    $markerMatches = $false
    if (Test-Path -LiteralPath $script:ArtifactOwnerMarker -PathType Leaf) {
      $markerValue = Get-Content -LiteralPath $script:ArtifactOwnerMarker -Raw
      $markerMatches = [string]::Equals(
        $markerValue.Trim(), $script:ArtifactOwnerToken,
        [System.StringComparison]::Ordinal)
    }
    if ($markerMatches -and (Test-PathContainedBy $fullArtifacts $script:ArtifactsBaseDir)) {
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
$script:ArtifactsBaseDir = Resolve-RepoPath $ArtifactsDir
$script:ArtifactOwnerToken = [System.Guid]::NewGuid().ToString("N")
# Each invocation owns a fresh child directory. The caller-selected parent is
# never deleted, even when it already contains unrelated files or is outside
# this repository.
$script:ResolvedArtifactsDir = Join-Path $script:ArtifactsBaseDir ("run-" + $script:ArtifactOwnerToken)
$script:ArtifactOwnerMarker = Join-Path $script:ResolvedArtifactsDir ".minilang-test-artifacts-owner"
$script:ResolvedLogPath = Resolve-RepoPath $LogPath

if (-not (Test-Path -LiteralPath $Compiler)) {
  throw "Compiler not found: $Compiler"
}

New-Item -ItemType Directory -Force -Path $script:ResolvedArtifactsDir | Out-Null
Set-Content -LiteralPath $script:ArtifactOwnerMarker -Encoding ASCII -NoNewline -Value $script:ArtifactOwnerToken
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

  $results += Test-LinuxRuntimeBlobLayout "Linux pthread runtime blob layout"
  $results += Invoke-CompilerVersionCheck "compiler version CLI" $Compiler
  $invalidLinuxFfiOutput = Join-Path $script:ResolvedArtifactsDir "invalid-linux-ffi.elf"
  $invalidLinuxFfiArgs = @((Join-Path $Root "tests\linux_windows_ffi_error.ml"), $invalidLinuxFfiOutput,
                           "-I", $Root, "--target", "linux-x64") + $effectiveCompilerArgs
  $results += Invoke-ExpectedCompilerFailure "linux-x64 rejects Windows DLL imports" $Compiler $invalidLinuxFfiArgs "cannot be imported by the linux-x64 target"
  $conflictingAbiOutput = Join-Path $script:ResolvedArtifactsDir "invalid-extern-abi.elf"
  $conflictingAbiArgs = @((Join-Path $Root "tests\extern_abi_conflict.ml"), $conflictingAbiOutput,
                          "-I", $Root, "--target", "linux-x64") + $effectiveCompilerArgs
  $results += Invoke-ExpectedCompilerFailure "extern aliases reject incompatible native ABI signatures" $Compiler $conflictingAbiArgs "incompatible ABI signature"

  # Cross-compile representative static, dynamic-FFI and threaded Linux ELF
  # programs, then execute them through WSL on the Windows test host.
  if ($null -ne (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    $linuxCases = @(
      [pscustomobject]@{ Name = "Linux target smoke"; Source = "linux_target_smoke.ml"; RunArgs = @("one", "two") },
      [pscustomobject]@{ Name = "Linux SysV FFI"; Source = "linux_ffi.ml"; RunArgs = @() },
      [pscustomobject]@{ Name = "Linux double out FFI"; Source = "linux_ffi_out_double.ml"; RunArgs = @() },
      [pscustomobject]@{ Name = "Linux exact library spelling"; Source = "linux_ffi_whitespace_library.ml"; RunArgs = @() },
      [pscustomobject]@{ Name = "Linux FFI resolution errors"; Source = "linux_ffi_resolution_error.ml"; RunArgs = @() },
      [pscustomobject]@{ Name = "Linux concurrent FFI resolution"; Source = "linux_ffi_concurrent_resolution.ml"; RunArgs = @() },
      [pscustomobject]@{ Name = "Linux float rounding carry"; Source = "linux_float_format.ml"; RunArgs = @() },
      [pscustomobject]@{ Name = "Linux shared heap and threads"; Source = "thread_features.ml"; RunArgs = @() },
      [pscustomobject]@{ Name = "Linux atomic Thread.Start"; Source = "thread_concurrent_start.ml"; RunArgs = @() },
      [pscustomobject]@{ Name = "Linux thread lifecycle races"; Source = "thread_lifecycle_races.ml"; RunArgs = @() },
      [pscustomobject]@{ Name = "Linux managed thread pool"; Source = "thread_pool.ml"; RunArgs = @() },
      [pscustomobject]@{ Name = "Linux standard library"; Source = "stdlib_unit_tests.ml"; RunArgs = @() },
      [pscustomobject]@{ Name = "Linux threading standard library"; Source = "threading_stdlib.ml"; RunArgs = @() },
      [pscustomobject]@{ Name = "Linux platform crypto"; Source = "crypto_cng.ml"; RunArgs = @() },
      [pscustomobject]@{ Name = "Linux shared-value snapshots"; Source = "shared_value.ml"; RunArgs = @() },
      [pscustomobject]@{ Name = "Linux platform services"; Source = "platform_services.ml"; RunArgs = @() },
      [pscustomobject]@{ Name = "Linux extern/user basename collision"; Source = "extern_user_name_collision\main.ml"; RunArgs = @() },
      [pscustomobject]@{ Name = "Linux GC safepoint publication"; Source = "gc_back_to_back_safepoint.ml"; RunArgs = @() },
      [pscustomobject]@{ Name = "Linux language extensions"; Source = "language_extensions.ml"; RunArgs = @() },
      [pscustomobject]@{ Name = "Linux async variadics"; Source = "language_async_variadic.ml"; RunArgs = @() },
      [pscustomobject]@{ Name = "Linux default lambda lowering"; Source = "language_default_lambda.ml"; RunArgs = @() },
      [pscustomobject]@{ Name = "Linux imported interfaces"; Source = "language_imported_interface.ml"; RunArgs = @() }
    )
    foreach ($linuxCase in $linuxCases) {
      $linuxSource = Join-Path $Root ("tests\" + $linuxCase.Source)
      $linuxStem = [System.IO.Path]::GetFileNameWithoutExtension($linuxCase.Source)
      $linuxImage = Join-Path $script:ResolvedArtifactsDir ($linuxStem + ".elf")
      $linuxArgs = @($linuxSource, $linuxImage, "-I", $Root, "--target", "linux-x64") + $effectiveCompilerArgs
      $results += Invoke-NativeStep ("compile " + $linuxCase.Name) $Compiler $linuxArgs
      if ($results[-1].ExitCode -ne 0) { continue }
      $magic = [System.IO.File]::ReadAllBytes($linuxImage)
      if ($magic.Length -lt 4 -or $magic[0] -ne 0x7F -or $magic[1] -ne 0x45 -or $magic[2] -ne 0x4C -or $magic[3] -ne 0x46) {
        $results += [pscustomobject]@{ Name = ("verify " + $linuxCase.Name + " ELF magic"); ExitCode = 1; Seconds = 0.0 }
        continue
      }
      $linuxPath = @(& wsl.exe wslpath -a -u ($linuxImage.Replace('\', '/')) 2>&1)[0]
      & wsl.exe chmod +x $linuxPath
      $results += Invoke-NativeStep ("run " + $linuxCase.Name) "wsl.exe" (@("timeout", "120s", $linuxPath) + $linuxCase.RunArgs)
    }

    $linuxObjectImage = Join-Path $script:ResolvedArtifactsDir "linux_target_smoke_object.elf"
    $linuxObjectArgs = @((Join-Path $Root "tests\linux_target_smoke.ml"), $linuxObjectImage,
                         "-I", $Root, "--target", "linux-x64", "--object-pipeline") + $effectiveCompilerArgs
    $results += Invoke-NativeStep "compile Linux object-pipeline parity" $Compiler $linuxObjectArgs
    if ($results[-1].ExitCode -eq 0) {
      $linuxMonoImage = Join-Path $script:ResolvedArtifactsDir "linux_target_smoke.elf"
      $results += Compare-BinaryArtifacts "Linux --object-pipeline compatibility byte identity" $linuxMonoImage $linuxObjectImage
    }
  }

  $runnerSrc = Join-Path $Root "tests\runtests.ml"
  $runnerExe = Join-Path $script:ResolvedArtifactsDir "runtests.exe"

  if (-not $SkipRunnerBuild) {
    $runnerBuildArgs = @($runnerSrc, $runnerExe, "-I", $Root) + $effectiveCompilerArgs
    $results += Invoke-NativeStep "compile ML test runner" $Compiler $runnerBuildArgs
    if ($results[-1].ExitCode -ne 0) { throw "Failed to compile test runner." }
  } elseif (-not (Test-Path -LiteralPath $runnerExe)) {
    throw "Test runner not found: $runnerExe"
  }

  $innerArtifacts = Join-Path $script:ResolvedArtifactsDir "inner"
  New-Item -ItemType Directory -Force -Path $innerArtifacts | Out-Null
  $runnerArgs = @($Compiler, $innerArtifacts) + $effectiveCompilerArgs
  $results += Invoke-NativeStep "run ML test harness" $runnerExe $runnerArgs

  $nativePrimitiveCases = @(
    [pscustomobject]@{ Name = "checksum runtime"; Source = "checksum_runtime.ml" },
    [pscustomobject]@{ Name = "SIMD search differential"; Source = "simd_search.ml" },
    [pscustomobject]@{ Name = "platform crypto vectors"; Source = "crypto_cng.ml" },
    [pscustomobject]@{ Name = "portable shared-value snapshots"; Source = "shared_value.ml" },
    [pscustomobject]@{ Name = "portable platform services"; Source = "platform_services.ml" },
    [pscustomobject]@{ Name = "extern/user basename collision"; Source = "extern_user_name_collision\main.ml" }
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

  # Use a deliberately small initial commitment to exercise the allocator's
  # grow-before-emergency-GC path independently of the normal suite defaults.
  $heapGrowthSource = Join-Path $Root "tests\heap_growth_precedes_gc.ml"
  $heapGrowthExe = Join-Path $script:ResolvedArtifactsDir "heap_growth_precedes_gc.exe"
  $heapGrowthArgs = @(
    $heapGrowthSource, $heapGrowthExe, "-I", $Root,
    "--heap-reserve", "64m", "--heap-commit", "1m",
    "--heap-grow", "1m", "--gc-limit", "64m"
  )
  $results += Invoke-NativeStep "compile heap growth before emergency GC" $Compiler $heapGrowthArgs
  if ($results[-1].ExitCode -eq 0) {
    $results += Invoke-NativeStep "run heap growth before emergency GC" $heapGrowthExe @()
  }

  # Keep heap trimming behavior aligned with the Python backend. This catches a
  # missing post-GC decommit block even when ordinary programs remain correct.
  $heapShrinkSource = Join-Path $Root "tests\heap_shrink.ml"
  $heapShrinkExe = Join-Path $script:ResolvedArtifactsDir "heap_shrink.exe"
  $heapShrinkArgs = @(
    $heapShrinkSource, $heapShrinkExe, "-I", $Root,
    "--heap-reserve", "128m", "--heap-commit", "64m",
    "--heap-shrink", "--heap-shrink-min", "16m", "--gc-limit", "64m"
  )
  $results += Invoke-NativeStep "compile heap shrink" $Compiler $heapShrinkArgs
  if ($results[-1].ExitCode -eq 0) {
    $results += Invoke-NativeStep "run heap shrink" $heapShrinkExe @()
  }

  if ($null -ne (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    $heapShrinkLinux = Join-Path $script:ResolvedArtifactsDir "heap_shrink.elf"
    $heapShrinkLinuxArgs = @(
      $heapShrinkSource, $heapShrinkLinux, "-I", $Root, "--target", "linux-x64",
      "--heap-reserve", "128m", "--heap-commit", "64m",
      "--heap-shrink", "--heap-shrink-min", "16m", "--gc-limit", "64m"
    )
    $results += Invoke-NativeStep "compile Linux heap shrink" $Compiler $heapShrinkLinuxArgs
    if ($results[-1].ExitCode -eq 0) {
      $heapShrinkLinuxPath = @(& wsl.exe wslpath -a -u ($heapShrinkLinux.Replace('\', '/')) 2>&1)[0]
      & wsl.exe chmod +x $heapShrinkLinuxPath
      $results += Invoke-NativeStep "run Linux heap shrink" "wsl.exe" @("timeout", "120s", $heapShrinkLinuxPath)
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
    },
    [pscustomobject]@{
      Name = "synchronized globals"
      Source = Join-Path $Root "tests\thread_features.ml"
      Includes = @($Root)
      Args = @()
    },
    [pscustomobject]@{
      Name = "language extensions"
      Source = Join-Path $Root "tests\language_extensions.ml"
      Includes = @($Root)
      Args = @()
    },
    [pscustomobject]@{
      Name = "typed struct field guards"
      Source = Join-Path $Root "tests\language_type_guard_object.ml"
      Includes = @($Root)
      Args = @()
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

    # Exercise the standalone streaming linker against retained canonical
    # objects, independently of the coordinator that emitted them.
    if ($parityCase.Name -eq "codegen optimizations") {
      $objectStem = [System.IO.Path]::GetFileNameWithoutExtension($objectExe)
      $objectDir = Join-Path (Join-Path (Split-Path -Parent $objectExe) "tmp") $objectStem
      $relinkedExe = Join-Path $script:ResolvedArtifactsDir ($stem + "_relinked.exe")
      $relinkArgs = @($parityCase.Source, $relinkedExe, "--link-obj-dir", $objectDir) + $parityCompilerArgs
      $results += Invoke-NativeStep "relink retained object directory" $Compiler $relinkArgs
      if ($results[-1].ExitCode -eq 0) {
        $results += Compare-BinaryArtifacts "standalone object relink byte identity" $objectExe $relinkedExe
      }
    }
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

  # Keep the constant-loop optimization bounded by one shared statement and
  # expression budget. The simple loops in main should disappear, whereas the
  # TLS-shaped condition in budgetedLoop must retain a real loop.
  $unrollSrc = Join-Path $Root "tests\for_unroll_budget.ml"
  $unrollExe = Join-Path $script:ResolvedArtifactsDir "for_unroll_budget.exe"
  $unrollLabels = Join-Path $script:ResolvedArtifactsDir "for_unroll_budget.labels"
  $unrollArgs = @(
    $unrollSrc, $unrollExe, "-I", $Root,
    "--dump-labels", $unrollLabels
  ) + $effectiveCompilerArgs
  $results += Invoke-NativeStep "compile bounded for-unroll regression" $Compiler $unrollArgs
  if ($results[-1].ExitCode -eq 0) {
    $results += Invoke-NativeStep "run bounded for-unroll regression" $unrollExe @()
    $unrollOk = Test-Path -LiteralPath $unrollLabels
    if ($unrollOk) {
      $unrollText = Get-Content -LiteralPath $unrollLabels -Raw
      $mainBlock = [regex]::Match($unrollText, '(?ms)^\[label\] fn_user_main .*?(?=^\[label\] fn_user_|\z)').Value
      $budgetBlock = [regex]::Match($unrollText, '(?ms)^\[label\] fn_user_budgetedLoop .*?(?=^\[label\] fn_user_|\z)').Value
      $unrollOk = $mainBlock.Length -gt 0 -and $budgetBlock.Length -gt 0 -and
                  $mainBlock -notmatch 'for_top_|for_cont_|for_end_|__for_end_|__for_step_' -and
                  $budgetBlock.Contains('for_top_') -and $budgetBlock.Contains('for_end_')
    }
    $unrollResult = [pscustomobject]@{
      Name = "verify bounded for-unroll structure"
      ExitCode = $(if ($unrollOk) { 0 } else { 1 })
      Seconds = 0.0
    }
    $results += $unrollResult
    $unrollLabel = if ($unrollOk) { "[PASS]" } else { "[FAIL]" }
    Write-Host ($unrollLabel + " bounded for-unroll structure")
    Write-LogLine ($unrollLabel + " bounded for-unroll structure")
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
