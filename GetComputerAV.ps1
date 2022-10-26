<#	
	.NOTES
	===========================================================================
	 Created on:   	10/26/2022
	 Created by:    Noah Huotari
	 Organization: 	HBS
	 Filename:     	GetComputerAV.ps1
	===========================================================================
	.DESCRIPTION
		Checks each computer in AD if the Antivirus service is running
#>

Import-Module ActiveDirectory
$Computers = Get-ADComputer -filter * | where {$_.Enabled -eq "true"}
#$Computers = Get-ADComputer cwpmw-dc
$Service = 'Sense'
$folder = "c:\hbs"

$FinalResults = @()
foreach ($computer in $computers)
{          
    If (Test-Connection -count 1 $computer.name -ErrorAction SilentlyContinue -quiet) 
    {
        #"can ping $computer"
        if ($mcStatus = (Get-Service -computer $computer.name -Name $service -erroraction silentlycontinue).status)
        {
          $serviceInstalled = "TRUE"
          $computerStatus = "Online"
          Write-Host -ForegroundColor Green "$service service exists on $computer and is $mcStatus."
        }
        else
        {
          $serviceInstalled = "FALSE"
          $computerStatus = "Online"
          Write-Host -ForegroundColor Red "$service does not exist on $computer."
        }
    }
    Else
    {
      Write-Host -ForegroundColor DarkYellow "Cannot ping the computer named $Computer"
      $serviceInstalled = "FALSE"
      $computerStatus = "Offline"
      $mcStatus = "Unknown"
    }
    $FinalResults += New-Object psobject -Property @{
                        Name = $computer.name
                        Installed = $serviceInstalled
                        Online = $computerStatus
                        Service = $Service
                        Status = $mcStatus
                        }
    #Variable reset
    $serviceInstalled = ""
    $computerStatus = ""
    $mcStatus = ""
}

if (Test-Path -Path $Folder) {
} else {
    New-Item -ItemType "directory" -Path $folder 
}

$path = $folder+"\"+(Get-Date).tostring("dd-MM-yyyy-hh-mm")+"_AD-AV_Staus.csv"
$FinalResults | Export-Csv $path -NoTypeInformation
