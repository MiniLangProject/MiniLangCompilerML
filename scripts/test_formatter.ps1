<#
Build and exercise mlfmt with the self-hosted Windows compiler.
Checks exact golden source (including literal CRLF bytes), idempotence, runtime
output, PE/ELF image parity and recursive directory mode. Linux execution is
checked through WSL when installed. For a native Linux host use:
  python3 tests/check_formatter.py --compiler /path/to/mlc-native
#>
param(
  [Parameter(Mandatory = $true)]
  [string]$Compiler,
  [string]$ArtifactsDir = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$Compiler = [IO.Path]::GetFullPath($Compiler)
$ownsArtifacts = [string]::IsNullOrWhiteSpace($ArtifactsDir)
if ($ownsArtifacts) {
  $ArtifactsDir = Join-Path ([IO.Path]::GetTempPath()) ("minilang-formatter-" + [guid]::NewGuid().ToString("N"))
}
$ArtifactsDir = [IO.Path]::GetFullPath($ArtifactsDir)
New-Item -ItemType Directory -Force -Path $ArtifactsDir | Out-Null
$utf8 = [Text.UTF8Encoding]::new($false)
$hasWsl = $null -ne (Get-Command wsl.exe -ErrorAction SilentlyContinue)

function Invoke-Checked {
  param([string]$Name, [string]$FilePath, [string[]]$Arguments)
  & $FilePath @Arguments | Out-Host
  if ($LASTEXITCODE -ne 0) { throw "$Name failed with exit code $LASTEXITCODE" }
}

function Assert-Bytes {
  param([string]$Name, [byte[]]$Actual, [byte[]]$Expected)
  if (-not [Linq.Enumerable]::SequenceEqual([byte[]]$Actual, [byte[]]$Expected)) {
    throw "$Name differs (actual $($Actual.Length) bytes, expected $($Expected.Length) bytes)"
  }
}

function Read-Fixture {
  param([string]$Name)
  # Ignore Git checkout EOL conversion; the CRLF test constructs literal bytes explicitly.
  return ([IO.File]::ReadAllText((Join-Path $Root "tests\$Name"))).Replace("`r`n", "`n")
}

function Convert-ToWslPath {
  param([string]$Path)
  $value = @(& wsl.exe wslpath -a -u ([IO.Path]::GetFullPath($Path).Replace('\', '/')) 2>&1)
  if ($LASTEXITCODE -ne 0 -or $value.Count -eq 0) { throw "wslpath failed for $Path" }
  return ("" + $value[0]).Trim()
}

function Build-Image {
  param([string]$Source, [string]$Image, [string]$Target)
  Invoke-Checked "$Target build of $Source" $Compiler @($Source, $Image, "-I", $Root, "--target", $Target)
  $bytes = [IO.File]::ReadAllBytes($Image)
  $magic = if ($Target -eq "windows-x64") { [byte[]]@(0x4d, 0x5a) } else { [byte[]]@(0x7f, 0x45, 0x4c, 0x46) }
  Assert-Bytes "$Image executable magic" $bytes[0..($magic.Length - 1)] $magic
}

function Invoke-Program {
  param([string]$Target, [string]$Image)
  if ($Target -eq "windows-x64") {
    $output = @(& $Image 2>&1) -join "`n"
  } else {
    $linuxPath = Convert-ToWslPath $Image
    Invoke-Checked "mark Linux executable" "wsl.exe" @("chmod", "+x", $linuxPath)
    $output = @(& wsl.exe timeout 240s $linuxPath 2>&1) -join "`n"
  }
  if ($LASTEXITCODE -ne 0) { throw "$Target program failed: $Image`n$output" }
  return $output
}

function Invoke-Formatter {
  param([string]$Target, [string]$Source, [string[]]$Options)
  if ($Target -eq "windows-x64") {
    Invoke-Checked "Windows formatter" $formatterExe (@($Source) + $Options)
  } else {
    $sourceWsl = Convert-ToWslPath $Source
    Invoke-Checked "Linux formatter" "wsl.exe" (@("timeout", "240s", $formatterWsl, $sourceWsl) + $Options)
  }
}

try {
  $formatterSource = Join-Path $Root "tools\mlfmt.ml"
  $formatterExe = Join-Path $ArtifactsDir "mlfmt.exe"
  $linuxFormatter = Join-Path $ArtifactsDir "mlfmt-linux"
  Build-Image $formatterSource $formatterExe "windows-x64"
  Build-Image $formatterSource $linuxFormatter "linux-x64"
  if ($hasWsl) {
    $formatterWsl = Convert-ToWslPath $linuxFormatter
    Invoke-Checked "mark Linux formatter executable" "wsl.exe" @("chmod", "+x", $formatterWsl)
  } else {
    Write-Host "[NOTE] Linux/WSL runtime unavailable; still checking ELF builds and before/after image bytes."
  }

  $edges = Read-Fixture "formatter_edges_input.ml"
  $edgesExpected = Read-Fixture "formatter_edges_expected.ml"
  $start = $edges.IndexOf('s = "hello')
  $end = $edges.IndexOf('if len(s)', $start)
  $literalRegion = $edges.Substring($start, $end - $start)
  $crlfRegion = $literalRegion.Replace("`n", "`r`n")
  $blankInput = "function main(args)`n`n`n`ns = `"hello`n`n`n`nworld`"`nif len(s)!=14 then return 1 end if`nprint `"[OK] formatter blank lines`"`nreturn 0`nend function`n"
  $blankExpected = "function main(args)`ns = `"hello`n`n`n`nworld`"`n  if len(s) != 14 then return 1 end if`n  print `"[OK] formatter blank lines`"`n  return 0`nend function`n"
  $cases = @(
    @{ Name = "modern"; Input = (Read-Fixture "formatter_modern_input.ml"); Expected = (Read-Fixture "formatter_modern_expected.ml"); Marker = "[OK] formatter modern syntax"; Options = @() },
    @{ Name = "edges"; Input = $edges; Expected = $edgesExpected; Marker = "[OK] formatter lexical edges"; Options = @() },
    @{ Name = "literal-crlf"; Input = $edges.Replace($literalRegion, $crlfRegion); Expected = $edgesExpected.Replace($literalRegion, $crlfRegion); Marker = "[OK] formatter lexical edges"; Options = @() },
    @{ Name = "max-blank-zero"; Input = $blankInput; Expected = $blankExpected; Marker = "[OK] formatter blank lines"; Options = @("--max-blank", "0") }
  )
  foreach ($case in $cases) {
    # Removing layout-only blank lines legitimately changes embedded diagnostic line numbers.
    $preserveLines = ($case.Input.Split("`n").Length -eq $case.Expected.Split("`n").Length)
    $caseDir = Join-Path $ArtifactsDir $case.Name
    New-Item -ItemType Directory -Force -Path $caseDir | Out-Null
    $source = Join-Path $caseDir "fixture.ml"
    [IO.File]::WriteAllBytes($source, $utf8.GetBytes($case.Input))
    $expectedBytes = $utf8.GetBytes($case.Expected)
    $beforeHashes = @{}
    $beforeOutputs = @{}
    foreach ($target in @("windows-x64", "linux-x64")) {
      $before = Join-Path $caseDir "before-$target.exe"
      Build-Image $source $before $target
      $beforeHashes[$target] = (Get-FileHash -LiteralPath $before -Algorithm SHA256).Hash
      if ($target -eq "windows-x64" -or $hasWsl) {
        $beforeOutputs[$target] = Invoke-Program $target $before
        if (-not $beforeOutputs[$target].Contains($case.Marker)) { throw "$($case.Name): $target success marker missing" }
      }
    }
    $options = @("--inplace") + $case.Options
    Invoke-Formatter "windows-x64" $source $options
    Assert-Bytes "$($case.Name) golden source" ([IO.File]::ReadAllBytes($source)) $expectedBytes
    Invoke-Formatter "windows-x64" $source $options
    Assert-Bytes "$($case.Name) idempotence" ([IO.File]::ReadAllBytes($source)) $expectedBytes
    foreach ($target in @("windows-x64", "linux-x64")) {
      $after = Join-Path $caseDir "after-$target.exe"
      Build-Image $source $after $target
      if ($preserveLines -and (Get-FileHash -LiteralPath $after -Algorithm SHA256).Hash -cne $beforeHashes[$target]) {
        throw "$($case.Name): formatting changed the $target executable"
      }
      if ($target -eq "windows-x64" -or $hasWsl) {
        if ((Invoke-Program $target $after) -cne $beforeOutputs[$target]) { throw "$($case.Name): $target runtime output changed" }
      }
    }
    if ($hasWsl) {
      $alternate = Join-Path $caseDir "alternate.ml"
      [IO.File]::WriteAllBytes($alternate, $utf8.GetBytes($case.Input))
      Invoke-Formatter "linux-x64" $alternate $options
      Assert-Bytes "$($case.Name) Linux formatter parity" ([IO.File]::ReadAllBytes($alternate)) $expectedBytes
      Invoke-Formatter "linux-x64" $alternate $options
      Assert-Bytes "$($case.Name) Linux idempotence" ([IO.File]::ReadAllBytes($alternate)) $expectedBytes
    }
    $imageCheck = if ($preserveLines) { "image parity" } else { "builds (source line numbers changed)" }
    Write-Host "[OK] $($case.Name): exact source, idempotence, runtime output and PE/ELF $imageCheck"
  }

  foreach ($target in @("windows-x64", "linux-x64")) {
    if ($target -eq "linux-x64" -and -not $hasWsl) { continue }
    $treeRoot = Join-Path $ArtifactsDir "tree-$target"
    $treeDir = Join-Path $treeRoot "nested"
    New-Item -ItemType Directory -Force -Path $treeDir | Out-Null
    $treeSource = Join-Path $treeDir "tree.ml"
    [IO.File]::WriteAllText($treeSource, "function main(args)`nif true then`nprint `"tree`"`nend if`nreturn 0`nend function`n", $utf8)
    Invoke-Formatter $target $treeRoot @()
    $treeExpected = "function main(args)`n  if true then`n    print `"tree`"`n  end if`n  return 0`nend function`n"
    Assert-Bytes "$target recursive directory formatting" ([IO.File]::ReadAllBytes($treeSource)) ($utf8.GetBytes($treeExpected))
    Write-Host "[OK] ${target}: recursive directory formatting"
  }
  exit 0
}
catch {
  Write-Error $_ -ErrorAction Continue
  exit 1
}
finally {
  if ($ownsArtifacts -and (Test-Path -LiteralPath $ArtifactsDir)) {
    Remove-Item -LiteralPath $ArtifactsDir -Recurse -Force
  }
}
