<#	
	.NOTES
	===========================================================================
	 Created on:   	11/17/2021
  	 Updated on:	1/29/2024
	 Created by:    Noah Huotari
	 Organization: 	HBS
	 Filename:     	GetADComputer-OS.ps1
	===========================================================================
	.DESCRIPTION
		Gets all AD computers that have logged in within the last 30 days
        Exports a CSV with a computers: Name, OS, IP and Last Login 
#>

<#
	.ChangeLog
 	===========================================================================
 	1-29-2024 - Added Windows 11 23H2, updated Windows 10 export names
#>

$folder = "c:\hbs" 

$FullList = Get-ADComputer -filter * -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address,LastLogonDate
$list = $fulllist | Where-Object {$_.Enabled -eq $true -and $_.LastLogonDate -GT (Get-Date).AddDays(-30) } 
$oldList = $fulllist | Where-Object {$_.Enabled -eq $true -and $_.LastLogonDate -LT (Get-Date).AddDays(-30) }

$totalNumber = $FullList | Measure-Object | Select-Object -ExpandProperty Count
$activeNumber = $list | Measure-Object | Select-Object -ExpandProperty Count
$inactiveNumber = $oldList | Measure-Object | Select-Object -ExpandProperty Count
$disabledNumber = $totalNumber - $activeNumber - $inactiveNumber

$FinalResults = @()
foreach ($System in $List) {
    $Result = switch ($System.OperatingSystemVersion)
        {
            "10.0 (10240)" {"Win10 1507"}
            "10.0 (10586)" {"Win10 1511"}
            "10.0 (14393)" {"Win10 1607"}
            "10.0 (15063)" {"Win10 1703"}
            "10.0 (16299)" {"Win10 1709"}
            "10.0 (17134)" {"Win10 1803"}
            "10.0 (17763)" {"Win10 1809"}
            "10.0 (18362)" {"Win10 1903"}
            "10.0 (18363)" {"Win10 1909"}
            "10.0 (19041)" {"Win10 2004"}
            "10.0 (19042)" {"Win10 20H2"}
            "10.0 (19043)" {"Win10 21H1"}
            "10.0 (19044)" {"Win10 21H2"}
            "10.0 (19045)" {"Win10 22H2"}
            "10.0 (22000)" {"Win11 21H2"}
            "10.0 (22621)" {"Win11 22H2"}
            "10.0 (22631)" {"Win11 23H2"}
            "6.3 (9600)" {"Server 2012 R2"}
            "6.2 (9200)" {"Server 2012"}
            "6.1 (7601)" {"Server 2008 R2"}
            default {$System.OperatingSystemVersion}
        }

    $FinalResults += New-Object psobject -Property @{
                        Name = $System.Name
                        OperatingSystem = $System.OperatingSystem
                        OperatingSystemVersion = $Result
                        IPv4 = $System.IPv4Address
                        LastLogin = $System.LastLogonDate
                        }
}

if (Test-Path -Path $Folder) {
} else {
    New-Item -ItemType "directory" -Path $folder 
}

$output = $FinalResults | Select-Object Name,OperatingSystem,OperatingSystemVersion,IPv4,LastLogin | Sort-Object operatingsystemversion -Descending
$path = $folder+"\"+(Get-Date).tostring("dd-MM-yyyy-hh-mm-ss")+"_ADDeviceExport.csv"
$output | Export-Csv $path -NoTypeInformation

$output | Format-Table -AutoSize
Write-Host "There are $activeNumber AD devices that have logged in within the last 30 days"
Write-Host "There are $inactiveNumber AD devices that have NOT logged in within the last 30 days"
Write-Host "There are $disabledNumber AD devices that are disabled" 
Write-Host "CSV File is located here: $path"
