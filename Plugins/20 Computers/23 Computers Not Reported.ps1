$DaysSinceContact = 30;

$results = @();

$cscope = New-Object Microsoft.UpdateServices.Administration.ComputerTargetScope
$cscope.IncludeDownstreamComputerTargets = $true;

$computers = $WSUSServer.GetComputerTargets($cscope);

foreach ($computer in $computers) {
    # Last Status Report
    $last_status_report = $(Get-Date) - $computer.LastReportedStatusTime;
    if ($last_status_report.Days -gt $DaysSinceContact) {
        $info = "" | Select Name, Age;
        $info.Name = $computer.FullDomainName;
        $info.Age = $last_status_report.Days;
        $results += $info;
        
    }
}

$results  | Sort Name | Select-Object Name, Age;

$Title = "Computers Not Reported"
$Author = "Neale Lonslow"
$PluginVersion = 1.0
$Header = "Computers not reported"
$Comments = "Computers that have not reported status in more than $DaysSinceContact days."
$Display = "Table"
$PluginCategory = "WSUS"