<#	
	.NOTES
	===========================================================================
	 Created on:   	10/24/2022
	 Created by:    Noah Huotari
	 Organization: 	HBS
	 Filename:     	GetComputerAV.ps1
	===========================================================================
	.DESCRIPTION
		Checks each computer in AD if the Antivirus service is running
#>

Import-Module ActiveDirectory
$Computers = Get-ADComputer -filter *
$Service = 'WRSVC'
 
 
foreach ($computer in $computers)
{          
    If (Test-Connection -count 2 $computer.name -ErrorAction SilentlyContinue -quiet) 
    {
        #"can ping $computer"
        if ($mcStatus = (Get-Service -computer $computer.name -Name $service -erroraction silentlycontinue).status)
        {
          Write-Host -ForegroundColor Green "$service service exists on $computer and is $mcStatus."
        }
        else
        {
          Write-Host -ForegroundColor Red "$service does not exist on $computer."
        }
    }
    Else
    {
      Write-Host -ForegroundColor DarkYellow "Cannot ping the computer named $Computer"
    }   
} 
