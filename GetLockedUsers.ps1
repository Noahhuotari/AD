# Getting the PDC emulator DC
$pdc = (Get-ADDomain).PDCEmulator

# Creating filter criteria for events
$filterHash = @{LogName = "Security"; Id = 4740; StartTime = (Get-Date).AddDays(-1)}

# Getting lockout events from the PDC emulator
$lockoutEvents = Get-WinEvent -ComputerName $pdc -FilterHashTable $filterHash -ErrorAction SilentlyContinue

# Building output based on advanced properties
$lockoutEvents | Select @{Name = "LockedUser"; Expression = {$_.Properties[0].Value}}, `
                        @{Name = "SourceComputer"; Expression = {$_.Properties[1].Value}}, `
                        @{Name = "DomainController"; Expression = {$_.Properties[4].Value}}, TimeCreated | where {$_.LockedUser -eq "skuesel"}
                        
                        
                        
#Try to run this script to find the source of the lock out
# Creating filter criteria for events
$filterHash = @{LogName = "Security"; Id = 4625; StartTime = (Get-Date).AddDays(-1)}

# Getting lockout events from the source computer
$lockoutEvents = Get-WinEvent -ComputerName COMPUTERNAME -FilterHashTable $filterHash -MaxEvents 1 -ErrorAction 0

# Building output based on advanced properties
$lockoutEvents | Select @{Name = "LockedUserName"; Expression = {$_.Properties[5].Value}}, `
                        @{Name = "LogonType"; Expression = {$_.Properties[10].Value}}, `
                        @{Name = "LogonProcessName"; Expression = {$_.Properties[11].Value}}, `
                        @{Name = "ProcessName"; Expression = {$_.Properties[18].Value}}
