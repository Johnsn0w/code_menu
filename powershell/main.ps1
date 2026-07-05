#region imports_and_constants
using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation.Host
. "${PSScriptRoot}\_global_source.ps1"
. "${PSScriptRoot}\_process_db.ps1"
. "${PSScriptRoot}\_render_list.ps1"
. "${PSScriptRoot}\_helper_funcs.ps1"
. "${PSScriptRoot}\_capture_user_input.ps1"

Set-StrictMode -Version Latest 
$ErrorActionPreference = "Stop"

$host.UI.RawUI.WindowTitle = "My Menu"

[Console]::CursorVisible = $false
$temp = [Dictionary[string, int]]::new()
$temp.Add("UP", -1) ; $temp.Add("DOWN", 1)
$DIRECTION = [ReadOnlyDictionary[string, int]]::new($temp)

$JsonPath = (Split-Path $PSScriptRoot -Parent) + "\exports\_ps.json"

$CMD_DB = load_json_to_hash_table $JsonPath

$tag_str = @("ps") ###
$PS_CMDS = filter_table_by_tag -_Table $CMD_DB -_Tags $tag_str
#endregion imports_etc..
New-Variable -Name CursorIndex      -Value ([int[]]@(0)) -Option Constant
New-Variable -Name CurrentUserInput -Value ([String[]]@("")) -Option Constant
New-Variable -Name CurrentList      -Value ([List[string]]::new()) -Option Constant





function execute_selection() {

    $SelectedItem = GetSelectedItem

    generate_blank_window
    Invoke-Expression $SelectedItem.command
    
    Read-Host "---------------------`nExecution finished...`n---------------------"

}

function GetSelectedItem() {
    $index = $CursorIndex[0]
    if ($index) { $index-- }

    $SelectedItemName = $CurrentList[$index]
    $SelectedItem = $PS_CMDS[$SelectedItemName]
    return $SelectedItem
}

function main() {

    RenderList -_List (filter_table_by_cmd_name -_Table $PS_CMDS -_NameStrFilter "")
    while ($true) {

        $UserInput = GetUserInput
        HandleUserInput $UserInput
        if ($script:CurrentList) { $script:CurrentList.Clear() }
        $FilteredResults = filter_table_by_cmd_name -_Table $PS_CMDS -_NameStrFilter $CurrentUserInput[0]
        if ($FilteredResults) { $FilteredResults | ForEach-Object { $CurrentList.Add($_) } }       
        RenderList -_List $CurrentList -_UserInput $CurrentUserInput[0]
    }

}
main