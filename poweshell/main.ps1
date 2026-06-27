using namespace System.Collections

. "${PSScriptRoot}\_process_db.ps1"
. "${PSScriptRoot}\_render_list.ps1"

Set-StrictMode -Version Latest 
$ErrorActionPreference = "Stop"

$host.UI.RawUI.WindowTitle = "My Menu"

$logfile = Join-Path $PWD ".log.txt"
Clear-Content -Path $logfile  -ErrorAction SilentlyContinue

$BACKSPACE = 8
$MODIFIER_KEYS = 16, 17, 18, 91, 92
$ESC = [ConsoleKey]::Escape
$ENTER = [ConsoleKey]::Enter

$JsonPath = "${PSScriptRoot}\_ps.json"
$CMD_DB = load_json_to_hash_table $JsonPath

$tag_str = @("ps") ###
$PS_CMDS = filter_table_by_tag -_Table $CMD_DB -_Tags $tag_str

function Log {
    param( [string]$_msg)
    # Clear-Content -Path $logfile
    $_msg | Out-File -FilePath $logfile -Append

}

function ProcessUserInput {
    param($_PreviousUserInput)
    if ($host.UI.RawUI.KeyAvailable) {
        $UpdatedInput = ""
        $new_keypress = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        switch ($new_keypress) {
            { $_.VirtualKeyCode -eq $BACKSPACE} {
                if (-not $_PreviousUserInput) { break } # dont try erase from empty list
                $UpdatedInput = $_PreviousUserInput.Substring(0, $_PreviousUserInput.Length - 1)
                break
            }
            #region
            { $_.VirtualKeyCode -eq $ENTER } { execute_selection ; break }
            { $_.VirtualKeyCode -eq $ESC } { Write-Host "`nExiting...`n" ; exit 0 } 
            { [char]::IsControl($_.Character) } { break <# ignore other ctrl chars #> }
            { $_.VirtualKeyCode -in $MODIFIER_KEYS } { break <# don't write modifier keys #> }
            #endregion
            Default {
                $UpdatedInput = $_PreviousUserInput + $_.Character
            }
        }      
        return $UpdatedInput
    }
}


function execute_selection() {}



function main() {

    $ui = ""

    while ($true) {
        
        $NewInput = ProcessUserInput -_PreviousUserInput $ui

        if ($ui -ne $NewInput) {
            $ui = $NewInput
            $filtered_results = filter_table_by_cmd_name -_Table $PS_CMDS -_NameStrFilter $ui
            RenderList -_List $filtered_results -_UserInput $ui
        }
    }

}
main