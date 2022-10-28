<#	
	.NOTES
	===========================================================================
	 Created on:   	10/26/2022
	 Created by:    Noah Huotari
	 Organization: 	HBS
	 Filename:     	GetADPermissions.ps1
	===========================================================================
	.DESCRIPTION
		Creates a report of AD OU Permissions
    
    .INSTRUCTIONS
    Only change folder and file NAME only
    1. Update folder if needed
    2. Run script
    3. Open .csv file in Excel
    4. Select all data in the first column
    5. Go to the data tab, and select text to columns
    6. Select Delimited, then next, then select semicolor and click finish
    7. Select all data and hit ctrl+t to create a table, check box for having headers
    8. Use Excel sorting as you wish
#>

#Set export directory 
$folder = "c:\hbs"
Set-Location -Path $folder

# Set up output file
$File = "AD_Permissions.csv"
"Path;ID;Rights;Type" | Out-File $File

# Import AD module
Import-Module ActiveDirectory

# Get all OU's in the domain
$OUs = Get-ADOrganizationalUnit -Filter *
$Result = @()
ForEach($OU In $OUs){
    # Get ACL of OU
    $Path = "AD:\" + $OU.DistinguishedName
    $ACLs = (Get-Acl -Path $Path).Access
    ForEach($ACL in $ACLs){
        # Only examine non-inherited ACL's
        If ($ACL.IsInherited -eq $False){
            # Objectify the result for easier handling
            $Properties = @{
                ACL = $ACL
                OU = $OU.DistinguishedName
                }
            $Result += New-Object psobject -Property $Properties
        }
    }
}
ForEach ($Item In $Result){
    $Output = $Item.OU + ";" + $Item.ACL.IdentityReference + ";" + $Item.ACL.ActiveDirectoryRights + ";" + $Item.ACL.AccessControlType
    $Output | Out-File $file -Append
}
