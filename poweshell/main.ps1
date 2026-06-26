using namespace System.Collections

. "${PSScriptRoot}\_process_db.ps1"
. "${PSScriptRoot}\_render_list.ps1"

Set-StrictMode -Version Latest 
$ErrorActionPreference = "Stop"

$host.UI.RawUI.WindowTitle = "My Menu"

$logfile = Join-Path $PWD ".log.txt"
Clear-Content -Path $logfile  -ErrorAction SilentlyContinue

$script:user_input = ""
$BACKSPACE = 8
$MODIFIER_KEYS = 16, 17, 18, 91, 92
$ESC = [ConsoleKey]::Escape
$ENTER = [ConsoleKey]::Enter
New-Variable -Name CursorIndex -Value ([int[]]@(0)) -Option Constant
New-Variable -Name CurrentItems -Value ([ArrayList]::new()) -Option Constant
# $CMD_DB = Get-Content -Raw -Path (Join-Path $PSScriptRoot '.\_ps.json') | ConvertFrom-Json
$JsonPath = "${PSScriptRoot}\_ps.json"
$CMD_DB = load_json_to_hash_table $JsonPath

$tag_str = @("ps") ###

$PS_CMDS = filter_table_by_tag -_Table $CMD_DB -_Tags $tag_str

# $PS_CMDS

function Log {
    param( [string]$_msg)
    Clear-Content -Path $logfile
    $_msg | Out-File -FilePath $logfile -Append

}

function scan_user_input {
    if ($host.UI.RawUI.KeyAvailable) {
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        $char = $key.Character
        
        switch ($key) {
            { $_.VirtualKeyCode -eq $BACKSPACE } {
                Write-Host "`b `b" -NoNewline
                $script:user_input = $user_input.Substring(0, $user_input.Length - 1)
            }
            { $_.VirtualKeyCode -eq $ENTER } { execute_selection }
            { $_.VirtualKeyCode -eq $ESC } { Write-Host "`nExiting...`n" ; exit 0 } 
            { [char]::IsControl($_.Character) } { <# ignore other ctrl chars #> }
            { $_.VirtualKeyCode -in $MODIFIER_KEYS } { <# don't write modifier keys #> }
            Default {
                Write-Host $char -NoNewline -ForegroundColor Cyan
                $script:user_input += $char
            }
        }      
        Log $user_input
        return $user_input
    }
}


function execute_selection() {}



function main() {
    while ($true) {
    
        $ui = scan_user_input
        if ($ui) {
            Write-Output $ui
            $filtered_results = filter_table_by_cmd_name -_Table $PS_CMDS -_NameStrFilter $ui
            RenderList -_List $filtered_results -_UserInput $ui
        }
    }

}
main