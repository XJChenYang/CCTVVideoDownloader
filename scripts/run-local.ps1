<#
.SYNOPSIS
Builds and launches the app directly from source after cloning the repository.

.DESCRIPTION
Restores paths for Qt and vcpkg, builds the specified configuration, and then
runs the generated executable from the build output folder. This keeps the
workflow simple: git clone → run script → app starts.

.EXAMPLE
powershell -ExecutionPolicy Bypass -File scripts/run-local.ps1 \
    -QtInstallRoot "C:\\Qt\\6.8.0\\msvc2022_64" -VcpkgRoot "C:\\vcpkg" -Configuration Debug
#>
param(
    [string]$Configuration = "Debug",
    [string]$Platform = "x64",
    [string]$QtInstallRoot = $env:QtInstallRoot,
    [string]$VcpkgRoot = $env:VCPKG_ROOT,
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

function Assert-PathExists {
    param(
        [string]$Path,
        [string]$Message
    )
    if (-not (Test-Path $Path)) {
        throw $Message
    }
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$buildDir = Join-Path $repoRoot "$Platform/$Configuration"
$binaryPath = Join-Path $buildDir "CCTVVideoDownloader.exe"

Assert-PathExists $QtInstallRoot "Qt install not found: pass -QtInstallRoot or set QtInstallRoot env var"
Assert-PathExists (Join-Path $QtInstallRoot "bin") "Qt bin directory missing under $QtInstallRoot"
Assert-PathExists $VcpkgRoot "vcpkg root not found: set -VcpkgRoot or VCPKG_ROOT"

$qtBin = Join-Path $QtInstallRoot "bin"
$vcpkgBin = Join-Path $VcpkgRoot "installed/$Platform-windows/bin"

$msbuild = (Get-Command msbuild.exe -ErrorAction SilentlyContinue)?.Source
if (-not $msbuild) {
    $vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio/Installer/vswhere.exe"
    if (Test-Path $vswhere) {
        $vsInstall = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -property installationPath
        if ($vsInstall) {
            $msbuildCandidate = Join-Path $vsInstall "MSBuild/Current/Bin/MSBuild.exe"
            if (Test-Path $msbuildCandidate) {
                $msbuild = $msbuildCandidate
            }
        }
    }
}
Assert-PathExists $msbuild "MSBuild.exe not found; install Visual Studio 2022 Build Tools"

if (-not $SkipBuild) {
    & $msbuild "$repoRoot/CCTVVideoDownloader.vcxproj" /p:Configuration=$Configuration /p:Platform=$Platform | Write-Output
}

Assert-PathExists $binaryPath "Build output missing: expected $binaryPath"

# Ensure Qt and vcpkg runtime DLLs are visible to the running process.
$env:Path = "$qtBin;$vcpkgBin;$env:Path"

Write-Host "Launching $binaryPath with Qt=$QtInstallRoot and vcpkg=$vcpkgBin"
Start-Process -FilePath $binaryPath -WorkingDirectory $buildDir
