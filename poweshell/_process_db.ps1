
function load_json_to_hash_table {
    param (
        $_FilePath
    )
    $Table = Get-Content -Raw -Path $_FilePath | ConvertFrom-Json -AsHashtable
    return $Table
}


function filter_table_by_tag {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        $_Table,
        [array]$_Tags
    )
    $ResultsFiltered = @{}
    $_Table.GetEnumerator() | # iterate over items
    Where-Object { Compare-Object $_.Value.tags $_Tags -IncludeEqual -ExcludeDifferent } |
    ForEach-Object { $ResultsFiltered[$_.Key] = $_.Value }
        
    return $ResultsFiltered
        
}
    
function filter_table_by_cmd_name {
    [CmdletBinding(PositionalBinding = $false)]
    param (
        $_Table,
        [string]$_NameStrFilter
    )
    $_Table.GetEnumerator() |
    Where-Object { $_.Key -like "*$_NameStrFilter*" }        
        
}
    
    
If ($MyInvocation.InvocationName -ne ".") { # like pythons __main__
    Write-Host "NOT SOURCED"
    Set-StrictMode -Version Latest 
    $ErrorActionPreference = "Stop"


    $tags_to_filter = @("ps")
    $json_filepath = '.\_ps.json'

    $cmds_db = load_json_to_hash_table $json_filepath
        
    $SearchStr = "print"
        
    $search_result = `
        filter_table_by_cmd_name `
        -_Table $cmds_db `
        -_NameStrFilter $SearchStr
    $search_result
}