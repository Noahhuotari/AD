<#	
	.NOTES
	===========================================================================
	 Created on:   	11/17/2021
	 Created by:    Noah Huotari
	 Organization: 	HBS
	 Filename:     	GetExpiredPassword.ps1
	===========================================================================
	.DESCRIPTION
		Gets all users who's passswords are set to never expire along with last change date
#>

$folder = "c:\hbs" 

$users = get-aduser -filter * -properties Name, PasswordNeverExpires, passwordlastset |
Where-Object { $_.passwordNeverExpires -eq "true" } | Where-Object {$_.enabled -eq "true"}

if (Test-Path -Path $Folder) {
} else {
    New-Item -ItemType "directory" -Path $folder 
}

$output = $users | Select-Object Name,SamAccountName,PasswordLastSet | Sort-Object Name
$path = $folder+"\"+(Get-Date).tostring("dd-MM-yyyy-hh-mm-ss")+"_AD-Password-Set-Expired.csv"
$output | Export-Csv $path -NoTypeInformation

$output | Format-Table -AutoSize
Write-Host "CSV File is located here: $path"