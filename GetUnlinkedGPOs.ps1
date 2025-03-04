Get-GPO -All | Where-Object {
     $_ | Get-GPOReport -ReportType XML | Select-String -NotMatch "<LinksTo>"
 } | select DisplayName | ft -AutoSize
