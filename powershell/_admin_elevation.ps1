. "${PSScriptRoot}\_global_source.ps1"
function ElevateToAdmin {
    param([switch]$_Force)
    if (-not $_Force) {
        if ($env:TERM_PROGRAM -eq "vscode") { return "skipping elevation in vscode" }
    }
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $scriptPath = $PSCommandPath
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
        exit
    }
    Set-Location -Path $PSScriptRoot
}
ElevateToAdmin -_Force