<#
.SYNOPSIS
Builds and packages CCTVVideoDownloader into a redistributable Windows folder.

.DESCRIPTION
The script compiles the Release|x64 configuration, optionally runs the VS test suite,
and then uses windeployqt plus vcpkg DLLs to assemble a runnable output directory.
Requires MSVC 2022, Qt 6.8.0 (msvc2022_64), and a vcpkg tree that provides cpr/curl/OpenSSL.

.EXAMPLE
powershell -ExecutionPolicy Bypass -File scripts/package-windows.ps1 -QtInstallRoot "C:\\Qt\\6.8.0\\msvc2022_64" -VcpkgRoot "C:\\vcpkg"
#>
param(
    [string]$Configuration = "Release",
    [string]$Platform = "x64",
    [string]$QtInstallRoot = "C:\\Qt\\6.8.0\\msvc2022_64",
    [string]$VcpkgRoot = $env:VCPKG_ROOT,
    [string]$OutputRoot = "artifacts",
    [switch]$SkipTests
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
$packageRoot = Join-Path $repoRoot $OutputRoot
$packageDir = Join-Path $packageRoot "CCTVVideoDownloader-$Platform-$Configuration"

Assert-PathExists $QtInstallRoot "Qt install not found: set -QtInstallRoot to your Qt 6.8.0 msvc2022_64 path"
Assert-PathExists (Join-Path $QtInstallRoot "bin/windeployqt.exe") "windeployqt.exe was not found in $QtInstallRoot"
Assert-PathExists $VcpkgRoot "vcpkg root not found: set -VcpkgRoot or VCPKG_ROOT"

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

New-Item -ItemType Directory -Force -Path $packageDir | Out-Null

& $msbuild "$repoRoot/CCTVVideoDownloader.vcxproj" /p:Configuration=$Configuration /p:Platform=$Platform | Write-Output

if (-not $SkipTests) {
    & $msbuild "$repoRoot/test/test.vcxproj" /p:Configuration=$Configuration /p:Platform=$Platform | Write-Output
    $vsTest = Join-Path (Split-Path $msbuild -Parent -Parent) "Common7/IDE/CommonExtensions/Microsoft/TestWindow/vstest.console.exe"
    if (Test-Path $vsTest) {
        $testBinary = Join-Path $repoRoot "test/$Platform/$Configuration/test.dll"
        if (Test-Path $testBinary) {
            & $vsTest $testBinary --parallel | Write-Output
        } else {
            Write-Warning "Test binary not found at $testBinary; skipping vstest"
        }
    } else {
        Write-Warning "vstest.console.exe not located; skipping test run"
    }
}

Assert-PathExists $binaryPath "Build output missing: expected $binaryPath"

Copy-Item $binaryPath $packageDir -Force
if (Test-Path (Join-Path $buildDir "decrypt")) {
    Copy-Item (Join-Path $buildDir "decrypt") (Join-Path $packageDir "decrypt") -Recurse -Force
}

$windeploy = Join-Path $QtInstallRoot "bin/windeployqt.exe"
& $windeploy --release --compiler-runtime --dir $packageDir $binaryPath | Write-Output

$vcpkgBin = Join-Path $VcpkgRoot "installed/$Platform-windows/bin"
if (Test-Path $vcpkgBin) {
    $vcpkgDlls = @(
        "cpr.dll",
        "libcurl.dll",
        "libssl-3-x64.dll",
        "libcrypto-3-x64.dll",
        "zlib1.dll",
        "brotlicommon.dll",
        "brotlidec.dll",
        "libssh2.dll",
        "nghttp2.dll",
        "cares.dll"
    )
    foreach ($dll in $vcpkgDlls) {
        $candidate = Join-Path $vcpkgBin $dll
        if (Test-Path $candidate) {
            Copy-Item $candidate $packageDir -Force
        }
    }
} else {
    Write-Warning "vcpkg bin directory $vcpkgBin not found; ensure dependent DLLs are copied manually"
}

"Package ready at $packageDir"
