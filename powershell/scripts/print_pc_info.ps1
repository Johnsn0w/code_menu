

function GetBatteryHealth() {
    # author: https://www.scriptrunner.com/blog-admin-architect/detecting-laptop-battery-wear
    $DesignedCapacity = Get-WmiObject -Class 'BatteryStaticData' -Namespace 'root\wmi' | 
    Group-Object -Property InstanceName -AsHashTable -AsString
    
    Get-CimInstance -Class 'BatteryFullChargedCapacity' -Namespace 'root/wmi' | 
    Select-Object -Property InstanceName, FullChargedCapacity, DesignedCapacity, Percent |
    ForEach-Object {
        $_.DesignedCapacity = $DesignedCapacity[$_.InstanceName].DesignedCapacity
        $_.Percent = [Math]::Round( ( $_.FullChargedCapacity * 100 / $_.DesignedCapacity), 2)
        $_
    } 
}


function PrintDisksHealth() {
    
    Get-PhysicalDisk | Where-Object { $_.BusType -ne "USB" } | 
    Select-Object FriendlyName, MediaType, HealthStatus, OperationalStatus, 
    @{Name = 'Size'; Expression = { [math]::Round($_.Size / 1GB, 2) } } |
    Format-Table
}

function PrintSysInfo(){
    $classes = "Win32_BIOS Win32_ComputerSystem Win32_ComputerSystemProduct Win32_SystemEnclosure Win32_BaseBoard" -split " "
    foreach ($item in $classes) {
        Write-Host "`n$item`n -----------"
        (Get-CimInstance $item | Format-List | Out-String).Trim() | Write-Host
    }
    "`n" + (Get-CimInstance Win32_OperatingSystem).Caption
}

function NetworkTest(){
    "IP Ping: " + (Test-Connection 8.8.8.8 -Count 1 -Quiet)
    "DNS Ping: " + (Test-Connection "google.com" -Count 1 -Quiet)
}
clear
# NetworkTest
# p
PrintSysInfo

function ControlPanelShortcuts(){
    Get-ControlPanelItem | Select-Object Name
}