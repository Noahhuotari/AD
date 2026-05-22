# Ensure the DNS Server module is available
If (-not (Get-Module -ListAvailable -Name DNSServer)) {
    Write-Error "The DNSServer PowerShell module is required. Please run this script on a DNS Server or install RSAT DNS tools."
    Exit
}

Write-Host "Gathering DNS Zones and Dynamic Update Settings for Domain..." -ForegroundColor Cyan
Write-Host "----------------------------------------------------------------------"

# Get all authoritative zones from the local DNS server
$DnsZones = Get-DnsServerZone | Where-Object { $_.ZoneType -in @("Primary", "Secondary") -and $_.ZoneName -ne "TrustAnchors" }

$Results = foreach ($Zone in $DnsZones) {
    # Translate the raw integer/string output of DynamicUpdate into human-readable compliance definitions
    # 0 or None = Secure/Nonsecure Disabled
    # 1 or NonsecureAndSecure = Insecure updates allowed (High Risk)
    # 2 or Secure = Secure Only (Compliant for AD integration)
    
    $StatusStyle = "Secure Only (Compliant)"
    $RiskRating = "Low"
    
    if ($Zone.DynamicUpdate -eq "NonsecureAndSecure" -or $Zone.DynamicUpdate -eq "1") {
        $StatusStyle = "Nonsecure and Secure (VULNERABLE)"
        $RiskRating = "HIGH"
    } elseif ($Zone.DynamicUpdate -eq "None" -or $Zone.DynamicUpdate -eq "0") {
        $StatusStyle = "Disabled (No Updates Allowed)"
        $RiskRating = "Low"
    }

    # Explicit check for the critical infrastructure forest locator zone
    if ($Zone.ZoneName -like "_msdcs*") {
        if ($RiskRating -eq "HIGH") {
            $RiskRating = "CRITICAL RISK (Authentication Hijack Potential)"
        }
    }

    [PSCustomObject]@{
        "Zone Name"           = $Zone.ZoneName
        "Zone Type"           = $Zone.ZoneType
        "Is AD Integrated"    = $Zone.IsDsIntegrated
        "Dynamic Update Mode" = $StatusStyle
        "Risk Assessment"     = $RiskRating
    }
}

# Output to console cleanly as a formatted list/table
$Results | Format-Table -AutoSize

# Optional: Export findings to a CSV in the local working folder for audit reporting
$CsvPath = ".\DNS_Zone_Security_Assessment.csv"
$Results | Export-Csv -Path $CsvPath -NoTypeInformation
Write-Host "`n[Success] Assessment complete. Report exported to: $CsvPath" -ForegroundColor Green
