Set-StrictMode -Version Latest 
$ErrorActionPreference = "Stop"
. "${PSScriptRoot}\_global_source.ps1"
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
    }`
    generate_blank_window
    Write-Host $_UserInput
    $script:first_run = $false
    
    if (-not $_List){
        return
    }
    
    $WindowHeight = ($Host.UI.RawUI.WindowSize.Height - 3)
    if ($_List.Count -gt $WindowHeight){
        $_List = $_List[0..$WindowHeight]
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
    $items = 1..20 | ForEach-Object { $_.ToString() + "item" }
    RenderList -_List $items -_UserInput "a"

}

function RenderItemInfo {
    param($_Item)
    generate_blank_window
    Write-Host "--------- ${_Item} ---------"
    Write-Host $_Item.command
    Read-Host  "Press enter to return to menu..."
}


If ($MyInvocation.InvocationName -ne ".") {
    New-Variable -Name CursorIndex -Value ([int[]]@(0)) -Option Constant
    main
}