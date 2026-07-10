. "${PSScriptRoot}\_global_source.ps1"

function load_json_to_hash_table {
    param (
        $_FilePath
    )
    $Table = Get-Content -Raw -Path $_FilePath 
    $Table = Get-Content -Raw -Path $_FilePath | ConvertFrom-Json
    return $Table
}


function filter_table_by_tag {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        $_Table,
        [array]$_Tags
    )
    $ResultsFiltered = @{}
    # $_Table | Get-Member -Force
    # clear
    # $_Table | ForEach-Object { $_ }
    # $_Table.ps_test.tags
    foreach ($item in $_Table.PSObject.Properties) {
        If (Compare-Object $item.Value.tags $_Tags -IncludeEqual -ExcludeDifferent) {
            $ResultsFiltered.Add($item.Name, $item.Value)
        }
    }
    # $_Table.GetEnumerator() | # iterate over items 
    # Where-Object { Compare-Object $_.Value.tags $_Tags -IncludeEqual -ExcludeDifferent } |
    # ForEach-Object { $ResultsFiltered[$_.Key] = $_.Value }
        
    return $ResultsFiltered
        
}
    
function filter_table_by_cmd_name {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        $_Table,
        [string]$_NameStrFilter
    ) 
    $_Table.keys | Where-Object { $_ -like "*$_NameStrFilter*" }
        
}
    
    
If ($MyInvocation.InvocationName -ne ".") {
    # like pythons __main__
    Write-Host "NOT SOURCED"
    Set-StrictMode -Version Latest 
    $ErrorActionPreference = "Stop"


    $tags_to_filter = @("ps")
    $json_filepath = (Split-Path $PSScriptRoot -Parent) + "\exports\_ps.json"

    $cmds_db = load_json_to_hash_table $json_filepath
        
    $SearchStr = "print"
        
    $search_result = `
        filter_table_by_cmd_name `
        -_Table $cmds_db `
        -_NameStrFilter $SearchStr
    $search_result
}