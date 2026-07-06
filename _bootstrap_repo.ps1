#### Simple script to download the repo zip to the system temp directory, extract files, and launch `main.ps1` elevated
param(
    [switch]$SkipElevation = $true,
    $ScriptEntryPoint  # = "powershell\main.ps1"
    )
if(-not $ScriptEntryPoint) {throw "SAM: ERROR $PSScriptRoot MISSING REQUIRED PARAM"}

Set-StrictMode -Version Latest 
$ErrorActionPreference = "Stop"

$RepoName = "code_menu"
$UserName = "Johnsn0w"
$BaseApiUrl = "https://api.github.com/repos/$UserName/$RepoName"
$BaseRawUrl = "https://raw.githubusercontent.com/$UserName/$RepoName/main"
$TempFilesPath = "${env:TEMP}\ps_temp_files"
$ZipPath = "${TempFilesPath}\.repo.zip"

$IsDevEnv = $PSScriptRoot
$IsDevEnv = $false


function DownloadRepoFiles() {
    If (-not (Test-Path $TempFilesPath)) {
        New-Item -ItemType Directory -Path $TempFilesPath
    }
    If (-not (Test-Path $ZipPath)) {
        Invoke-RestMethod -Uri "$BaseApiUrl/zipball" -OutFile $ZipPath
    }
    if ( -not (GetUnpackedRepoPath) ) {
        Expand-Archive -Path $ZipPath -DestinationPath "$TempFilesPath"
    } }

function GetUnpackedRepoPath() {
    if ( -not (Test-Path "$TempFilesPath\${UserName}*") ) { 
        return }
    $UnpackedRepoPath = (Get-ChildItem "$TempFilesPath\${UserName}*").FullName
    return $UnpackedRepoPath
}

if ($IsDevEnv) {
    $MainScript = "$PSScriptRoot\$ScriptEntryPoint"
}
else {
    DownloadRepoFiles
    $RepoPath = GetUnpackedRepoPath
    $MainScript = "$RepoPath\$ScriptEntrypoint"
}

If ($SkipElevation) {
    . $MainScript
}
else {
    Start-Process powershell -ArgumentList "-NoExit -NoProfile -ExecutionPolicy Bypass -File `"$MainScript`"" -Verb RunAs
}
