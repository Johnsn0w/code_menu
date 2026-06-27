Set-StrictMode -Version Latest 
$ErrorActionPreference = "Stop"
. "${PSScriptRoot}\_helper_funcs.ps1"
$script:first_run = $true


function RenderList {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [array]$_List,
        [string]$_UserInput
    )
    if (-not $script:first_run) { # prevent overwriting pre-existing buffer
        [Console]::SetCursorPosition(0, 0)
    }
    generate_blank_window
    Write-Host $_UserInput
    $script:first_run = $false
    
    if (-not $_List){
        return
    }
    foreach ($item in $_List){
        Write-Host $item
    }
    if ($CursorIndex[0]) {
        HighlightRange `
            -_Start ([Coordinates]::new($CursorIndex[0], 0)) `
            -_End   ([Coordinates]::new($CursorIndex[0], 5)) `
            -_Bg    ([System.ConsoleColor]::DarkYellow)
    }

    # for ($i = 0; $i -lt $_List.Count; $i++) {
    #     Write-Host "$($i + 1). $($_List[$i])"
    # }
}



function generate_blank_window {
    $windowSize = $Host.UI.RawUI.WindowSize
    $blankLines = [int]$windowSize.Height

    for ($i = 1; $i -lt $blankLines; $i++) {
        Write-Host (' ' * $Host.UI.RawUI.WindowSize.Width)
    }
    [Console]::SetCursorPosition(0, 0)
}


function main {
    $items = 1..8 | ForEach-Object { $_.ToString() + "item" }
    # Write-Host ('x' * $Host.UI.RawUI.WindowSize.Width)
    RenderList -_List $items -_UserInput "a"

}

If ($MyInvocation.InvocationName -ne ".") {
    New-Variable -Name CursorIndex -Value ([int[]]@(0)) -Option Constant
    main
}