<#	
	.NOTES
	===========================================================================
	 Created on:   	11/17/2021
	 Created by:    Noah Huotari
	 Organization: 	HBS
	 Filename:     	GetOldADComputers.ps1
	===========================================================================
	.DESCRIPTION
		Gets all AD computers that have NOT logged in within the last number of days
        Exports a CSV with information
#>

#User Variables
$DaysInactive = 60
$folder = "c:\hbs"

#####################################################################
#Begin Script 

if (Test-Path -Path $Folder) {
} else {
    New-Item -ItemType "directory" -Path $folder 
}

$time = (Get-Date).Adddays(-($DaysInactive))

$outputData = Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -ResultPageSize 2000 -resultSetSize $null -Properties Name, OperatingSystem, SamAccountName, DistinguishedName, LastLogonDate

$output = $outputData | select Name,Enabled,OperatingSystem,LastLogonDate,DistinguishedName

$path = $folder+"\"+(Get-Date).tostring("dd-MM-yyyy-hh-mm-ss")+"_OldADcomputers.csv"

$output | Export-Csv $path -NoTypeInformation