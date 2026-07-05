
using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation.Host
using namespace System.Collections.ObjectModel
. "${PSScriptRoot}\_global_source.ps1"

$temp = [Dictionary[string, int]]::new()
$temp.Add("UP", -1) ; $temp.Add("DOWN", 1)
$DIRECTION = [ReadOnlyDictionary[string, int]]::new($temp)


function HighlightRange {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        $_Start, $_End, $_Bg
    )
    $_Start.y..$_End.y | ForEach-Object {
        $row = $_
        $_Start.x..$_End.x | ForEach-Object {
            $pos = [Coordinates]::new($row, $_)
            $char = GetCharacterAtPos $pos
            $host.UI.RawUI.CursorPosition = $pos
            Write-Host $char -BackgroundColor $_Bg
        }
    }
}

function GetCharacterAtPos {
    param (
        $_Pos
    )
    $zero = $Host.UI.RawUI.WindowPosition   # top-left coord of visible window
    $rect = New-Object Rectangle(
        ($zero.X + $_Pos.X), 
        ($zero.Y + $_Pos.Y),
        ($zero.X + $_Pos.X), 
        ($zero.Y + $_Pos.Y)
    )
    $char = $Host.UI.RawUI.GetBufferContents($rect)[0, 0].Character
    $char
}
# GetCharacterAtPos ([Coordinates]::new(0, 0)).


function MoveCursor {
    param ( $_Direction )
    # $CursorIndex[0] += $_Direction
    $mv_result = $CursorIndex[0] + $_Direction

    if ($mv_result -lt 0 ) {return}
    if ($mv_result -gt $CurrentList.Count ) {return}
    $CursorIndex[0] = $mv_result
}


function main {
    New-Variable -Name CursorIndex -Value ([int[]]@(0)) -Option Constant
    New-Variable -Name CurrentList -Value ([List[string]]::new()) -Option Constant
    HighlightRange `
        -_Start ([Coordinates]::new($CursorIndex[0], 0)) `
        -_End   ([Coordinates]::new($CursorIndex[0], 5)) `
        -_Bg    ([System.ConsoleColor]::DarkYellow)
}


If ($MyInvocation.InvocationName -ne ".") {
    # main
}