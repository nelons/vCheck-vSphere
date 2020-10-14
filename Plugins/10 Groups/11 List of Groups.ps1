$Title = "List of WSUS Groups"
$Author = "Neale Lonslow"
$PluginVersion = 1.0
$Header = "Groups"
$Comments = ""
$Display = "Table"
$PluginCategory = "WSUS"

$DaysSinceContact = 30;

$all_groups = $Groups | Sort Name;
$results = @();

foreach ($group in $Groups) {
    $cscope = New-Object Microsoft.UpdateServices.Administration.ComputerTargetScope
    $cscope.IncludeDownstreamComputerTargets = $true;
    $cscope.ComputerTargetGroups.Add($group) | out-null;

    $computers = $WSUSServer.GetComputerTargets($cscope);

    $group_info = "" | Select Name, Total, Needed, Failed, PendingReboot, NotContacted, NotReported;
    $group_info.Name = $group.Name;
    $group_info.Total = $computers.Count;
    $group_info.Needed = 0;
    $group_info.Failed = 0;
    $group_info.PendingReboot = 0;
    $group_info.NotContacted = 0;
    $group_info.NotReported = 0;

    foreach ($computer in $computers) {
        $summary = $computer.GetUpdateInstallationSummary();

        if ($summary.NotInstalledCount -gt 0) {
            $group_info.Needed++;

        }

        if ($summary.FailedCount -gt 0) {
            $group_info.Failed++;
        }

        if ($summary.InstalledPendingRebootCount -gt 0) {
            $group_info.PendingReboot++;

        }

        # Last Contact
        $last_contact = $(Get-Date) - $computer.LastSyncTime;
        if ($last_contact.Days -gt $DaysSinceContact) {
            $group_info.NotContacted++;
        }

        # Last Status Report
        $last_status_report = $(Get-Date) - $computer.LastReportedStatusTime;
        if ($last_status_report.Days -gt $DaysSinceContact) {
            $group_info.NotReported++;

        }
    }

    $results += $group_info;
}

$results | Select Name, Total, Needed, Failed, NotReported;