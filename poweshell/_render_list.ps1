Set-StrictMode -Version Latest 
$ErrorActionPreference = "Stop"

$script:first_run = $true


function RenderList {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [array]$_List,
        [string]$_UserInput
    )
    if (-not $script:first_run) {
        [Console]::SetCursorPosition(0, 0)
    }
    generate_blank_window
    Write-Host $_UserInput
    $script:first_run = $false
    
    if (-not $_List){
        return
    }
    # for ($item -in $_List){
    #     Write-Host $item
    # }
    for ($i = 0; $i -lt $_List.Count; $i++) {
        Write-Host "$($i + 1). $($_List[$i])"
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
    $items = 1..8 | ForEach-Object { $_.ToString() + "item" }
    # Write-Host ('x' * $Host.UI.RawUI.WindowSize.Width)
    RenderList -_List $items -_UserInput "a"

}

If ($MyInvocation.InvocationName -ne ".") {
    main
}