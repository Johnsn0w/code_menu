#region imports_and_constants
using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation.Host

. "${PSScriptRoot}\_process_db.ps1"
. "${PSScriptRoot}\_render_list.ps1"
. "${PSScriptRoot}\_helper_funcs.ps1"

Set-StrictMode -Version Latest 
$ErrorActionPreference = "Stop"

$host.UI.RawUI.WindowTitle = "My Menu"

$logfile = Join-Path $PWD ".log.txt"
Clear-Content -Path $logfile  -ErrorAction SilentlyContinue

$K = @{
    BACKSPACE     = [ConsoleKey]::Backspace;
    MODIFIER_KEYS = [ConsoleModifiers]::Alt, [ConsoleModifiers]::Control, [ConsoleModifiers]::Shift;
    ESC           = [ConsoleKey]::Escape;
    ENTER         = [ConsoleKey]::Enter;
    UP            = [ConsoleKey]::UpArrow;
    DOWN          = [ConsoleKey]::DownArrow;
    LEFT          = [ConsoleKey]::LeftArrow
    RIGHT         = [ConsoleKey]::RightArrow
    UP_DOWN       = [ConsoleKey]::UpArrow, [ConsoleKey]::DownArrow;

}
[Console]::CursorVisible = $false
$temp = [Dictionary[string,int]]::new()
$temp.Add("UP", -1) ; $temp.Add("DOWN", 1)
$DIRECTION = [ReadOnlyDictionary[string,int]]::new($temp)

$JsonPath = "${PSScriptRoot}\_ps.json"
$CMD_DB = load_json_to_hash_table $JsonPath

$tag_str = @("ps") ###
$PS_CMDS = filter_table_by_tag -_Table $CMD_DB -_Tags $tag_str

New-Variable -Name CursorIndex -Value ([int[]]@(0)) -Option Constant
#endregion imports_and_constants

function Log {
    param( [string]$_msg)
    # Clear-Content -Path $logfile
    $_msg | Out-File -FilePath $logfile -Append

}

function ProcessUserInput {
    param($_PreviousUserInput)
    if ($host.UI.RawUI.KeyAvailable) {
        $UpdatedInput = $_PreviousUserInput
        $new_keypress = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        switch ($new_keypress) {
            { $_.VirtualKeyCode -eq $K.BACKSPACE } {
                if (-not $_PreviousUserInput) { break } # dont try erase from empty list
                $UpdatedInput = $_PreviousUserInput.Substring(0, $_PreviousUserInput.Length - 1)
                $CursorIndex[0] = 0
                break
            }
            {$_.VirtualKeyCode -in $K.DOWN} { MoveCursor $DIRECTION.DOWN ; break }
            {$_.VirtualKeyCode -in $K.UP  } { MoveCursor $DIRECTION.UP   ; break }
            #region
            { $_.VirtualKeyCode -eq $K.ENTER } { execute_selection ; break }
            { $_.VirtualKeyCode -eq $K.ESC } { Write-Host "`nExiting...`n" ; exit 0 } 
            { [char]::IsControl($_.Character) } { break <# ignore other ctrl chars #> }
            { $_.VirtualKeyCode -in $K.MODIFIER_KEYS } { break <# don't write modifier keys #> }
            #endregion
            Default {
                $UpdatedInput = $_PreviousUserInput + $_.Character
                $CursorIndex[0] = 0
            }
        }      
        return $UpdatedInput
    }
}


function execute_selection() {
    # Read-Host "Exec cursor index: $CursorIndex"
}

function main() {

    $ui = ""
    RenderList -_List (filter_table_by_cmd_name -_Table $PS_CMDS -_NameStrFilter "")
    while ($true) {
        
        $ui = ProcessUserInput -_PreviousUserInput $ui
        $filtered_results = filter_table_by_cmd_name -_Table $PS_CMDS -_NameStrFilter $ui
        RenderList -_List $filtered_results -_UserInput $ui
    }

}
main