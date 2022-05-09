<#	
	.NOTES
	===========================================================================
	 Created on:   	2/25/2022
	 Created by:    Noah Huotari
	 Organization: 	HBS
	 Filename:     	GetOldADUsers.ps1
	===========================================================================
	.DESCRIPTION
		Gets all AD Users that have NOT logged in within the last number of days
        Exports a CSV with information
#>

#User Variables
$DaysInactive = 60
$folder = "c:\hbs"

#####################################################################
#Begin Script 
if (Get-Module -ListAvailable -Name ImportExcel) {
    Import-Module ImportExcel
} 
else {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Install-Module ImportExcel
    Import-Module ImportExcel
}

if (Test-Path -Path $Folder) {
} else {
    New-Item -ItemType "directory" -Path $folder 
}

$time = (Get-Date).Adddays(-($DaysInactive))

$outputData = Get-ADUser -Filter {LastLogonTimeStamp -lt $time} -ResultPageSize 2000 -resultSetSize $null -Properties LastLogonDate

$output = $outputData | Select-Object Name,Enabled,SamAccountName,LastLogonDate,DistinguishedName

$path = $folder+"\"+(Get-Date).tostring("dd-MM-yyyy-hh-mm-ss")+"_OldADusers.xlsx"

$output | Export-Excel -path $path -AutoSize -TableName OldADusers -WorksheetName OldADusers
