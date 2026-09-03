<#
Build and exercise mlfmt against the complete modern MiniLang syntax surface.

The regression covers canonical output, byte-idempotence, unchanged generated
Windows code, recursive directory mode, native Linux execution and formatted
program execution. It is intentionally host-side because the formatter is a
standalone compiler output rather than a library linked into runtests.ml.
#>
param(
  [Parameter(Mandatory = $true)]
  [string]$Compiler,
  [string]$ArtifactsDir = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $PSCommandPath
$Root = Split-Path -Parent $ScriptDir
$Compiler = [IO.Path]::GetFullPath($Compiler)
$ownsArtifacts = [string]::IsNullOrWhiteSpace($ArtifactsDir)
if ($ownsArtifacts) {
  $ArtifactsDir = Join-Path ([IO.Path]::GetTempPath()) ("minilang-formatter-" + [guid]::NewGuid().ToString("N"))
}
$ArtifactsDir = [IO.Path]::GetFullPath($ArtifactsDir)
New-Item -ItemType Directory -Force -Path $ArtifactsDir | Out-Null

function Invoke-Checked {
  param([string]$Name, [string]$FilePath, [string[]]$Arguments)
  & $FilePath @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "$Name failed with exit code $LASTEXITCODE"
  }
}

function Normalize-Text {
  param([string]$Value)
  return $Value.Replace("`r`n", "`n").Replace("`r", "`n")
}

function Convert-ToWslPath {
  param([string]$Path)
  $value = @(& wsl.exe wslpath -a -u ([IO.Path]::GetFullPath($Path).Replace('\', '/')) 2>&1)
  if ($LASTEXITCODE -ne 0 -or $value.Count -eq 0) {
    throw "wslpath failed for $Path"
  }
  return ("" + $value[0]).Trim()
}

try {
  $formatterSource = Join-Path $Root "tools\mlfmt.ml"
  $inputFixture = Join-Path $Root "tests\formatter_modern_input.ml"
  $expectedFixture = Join-Path $Root "tests\formatter_modern_expected.ml"
  $formatterExe = Join-Path $ArtifactsDir "mlfmt.exe"
  $source = Join-Path $ArtifactsDir "formatter_modern.ml"
  $beforeExe = Join-Path $ArtifactsDir "formatter_before.exe"
  $afterExe = Join-Path $ArtifactsDir "formatter_after.exe"
  $marker = "[OK] formatter modern syntax"

  Invoke-Checked "Windows formatter build" $Compiler @($formatterSource, $formatterExe, "-I", $Root)
  Copy-Item -LiteralPath $inputFixture -Destination $source -Force
  Invoke-Checked "unformatted fixture build" $Compiler @($source, $beforeExe, "-I", $Root)
  $beforeOutput = @(& $beforeExe 2>&1) -join "`n"
  if ($LASTEXITCODE -ne 0 -or -not $beforeOutput.Contains($marker)) {
    throw "unformatted fixture failed at runtime"
  }

  Invoke-Checked "Windows formatter execution" $formatterExe @($source, "--inplace")
  $expected = Normalize-Text ([IO.File]::ReadAllText($expectedFixture))
  $actual = Normalize-Text ([IO.File]::ReadAllText($source))
  if ($actual -cne $expected) { throw "formatted source differs from formatter_modern_expected.ml" }
  foreach ($required in @("=>", "?.", "??", "///", "/**", "lazy iterator function", "async function", "synchronized(guard)", "end match")) {
    if (-not $actual.Contains($required)) { throw "formatted source lost required syntax: $required" }
  }

  $firstPass = [IO.File]::ReadAllBytes($source)
  Invoke-Checked "formatter idempotence pass" $formatterExe @($source, "--inplace")
  $secondPass = [IO.File]::ReadAllBytes($source)
  if (-not [Linq.Enumerable]::SequenceEqual([byte[]]$firstPass, [byte[]]$secondPass)) {
    throw "formatter is not byte-idempotent"
  }

  Invoke-Checked "formatted fixture build" $Compiler @($source, $afterExe, "-I", $Root)
  $afterOutput = @(& $afterExe 2>&1) -join "`n"
  if ($LASTEXITCODE -ne 0 -or -not $afterOutput.Contains($marker)) {
    throw "formatted fixture failed at runtime"
  }
  $beforeHash = (Get-FileHash -LiteralPath $beforeExe -Algorithm SHA256).Hash
  $afterHash = (Get-FileHash -LiteralPath $afterExe -Algorithm SHA256).Hash
  if ($beforeHash -cne $afterHash) { throw "formatting changed the generated Windows executable" }

  $treeRoot = Join-Path $ArtifactsDir "tree"
  $treeDir = Join-Path $treeRoot "nested"
  $treeSource = Join-Path $treeDir "tree.ml"
  New-Item -ItemType Directory -Force -Path $treeDir | Out-Null
  [IO.File]::WriteAllText(
    $treeSource,
    "function main(args)`nif true then`nprint `"tree`"`nend if`nreturn 0`nend function`n",
    [Text.UTF8Encoding]::new($false))
  Invoke-Checked "recursive Windows formatter execution" $formatterExe @($treeRoot)
  $treeExpected = "function main(args)`n  if true then`n    print `"tree`"`n  end if`n  return 0`nend function`n"
  if ((Normalize-Text ([IO.File]::ReadAllText($treeSource))) -cne $treeExpected) {
    throw "recursive directory formatting produced unexpected output"
  }

  $linuxFormatter = Join-Path $ArtifactsDir "mlfmt-linux"
  Invoke-Checked "Linux formatter build" $Compiler @($formatterSource, $linuxFormatter, "-I", $Root, "--target", "linux-x64")
  $linuxMagic = [IO.File]::ReadAllBytes($linuxFormatter)
  if ($linuxMagic.Length -lt 4 -or $linuxMagic[0] -ne 0x7f -or $linuxMagic[1] -ne 0x45 -or
      $linuxMagic[2] -ne 0x4c -or $linuxMagic[3] -ne 0x46) {
    throw "Linux formatter output is not ELF64"
  }

  if ($null -ne (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    $linuxSource = Join-Path $ArtifactsDir "formatter_modern_linux.ml"
    $linuxProgram = Join-Path $ArtifactsDir "formatter_modern_linux"
    Copy-Item -LiteralPath $inputFixture -Destination $linuxSource -Force
    $formatterWsl = Convert-ToWslPath $linuxFormatter
    $sourceWsl = Convert-ToWslPath $linuxSource
    Invoke-Checked "mark Linux formatter executable" "wsl.exe" @("chmod", "+x", $formatterWsl)
    Invoke-Checked "Linux formatter execution" "wsl.exe" @("timeout", "120s", $formatterWsl, $sourceWsl, "--inplace")
    if ((Normalize-Text ([IO.File]::ReadAllText($linuxSource))) -cne $expected) {
      throw "Linux and Windows formatter output differs"
    }
    Invoke-Checked "Linux formatted fixture build" $Compiler @($linuxSource, $linuxProgram, "-I", $Root, "--target", "linux-x64")
    $programWsl = Convert-ToWslPath $linuxProgram
    Invoke-Checked "mark Linux fixture executable" "wsl.exe" @("chmod", "+x", $programWsl)
    $linuxOutput = @(& wsl.exe timeout 120s $programWsl 2>&1) -join "`n"
    if ($LASTEXITCODE -ne 0 -or -not $linuxOutput.Contains($marker)) {
      throw "Linux formatted fixture failed at runtime"
    }
  }

  Write-Host "[OK] formatter modern syntax, idempotence and Windows/Linux parity"
  exit 0
}
catch {
  Write-Error $_
  exit 1
}
finally {
  if ($ownsArtifacts -and (Test-Path -LiteralPath $ArtifactsDir)) {
    Remove-Item -LiteralPath $ArtifactsDir -Recurse -Force
  }
}
