
using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation.Host
using namespace System.Collections.ObjectModel

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
    $CursorIndex[0] += $_Direction
    # HighlightRange `
    #     -_Start ([Coordinates]::new($CursorIndex[0], 0)) `
    #     -_End   ([Coordinates]::new($CursorIndex[0], 5)) `
    #     -_Bg    ([System.ConsoleColor]::DarkYellow)
}


function main {
    # MoveCursor $DIRECTION.DOWN
    New-Variable -Name CursorIndex -Value ([int[]]@(0)) -Option Constant
    $start = [Coordinates]::new(0, 0)
    $end = [Coordinates]::new(5, 20)
    $bg_color = [System.ConsoleColor]::DarkYellow
    HighlightRange `
        -_Start ([Coordinates]::new($CursorIndex[0], 0)) `
        -_End   ([Coordinates]::new($CursorIndex[0], 5)) `
        -_Bg    ([System.ConsoleColor]::DarkYellow)
}


If ($MyInvocation.InvocationName -ne ".") {
    # main
}