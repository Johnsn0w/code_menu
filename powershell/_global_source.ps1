Set-Location -Path $PSScriptRoot
$logfile = Join-Path $PWD ".log.txt"
Clear-Content -Path $logfile  -ErrorAction SilentlyContinue


function Log {
    param( [string]$_msg)
    # Clear-Content -Path $logfile
    $_msg | Out-File -FilePath $logfile -Append

}


# ai coded, review later
function ConvertToHashTable {
    param($InputObject)
    $hash = @{}
    $InputObject.PSObject.Properties | ForEach-Object {
        $Value = $_.Value

        # Safety check: ensure 'tags' exists on every entry
        if (-not ($Value.PSObject.Properties.Name -contains 'tags')) {
            $Value | Add-Member -NotePropertyName 'tags' -NotePropertyValue @() -Force
        }

        $hash[$_.Name] = $Value
    }
    return $hash
}