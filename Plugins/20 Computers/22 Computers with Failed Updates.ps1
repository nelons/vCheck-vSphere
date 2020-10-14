$Title = "Computers with Failed Updates"
$Author = "Neale Lonslow"
$PluginVersion = 1.0
$Header = "Computers with Failed Updates"
$Comments = ""
$Display = "Table"
$PluginCategory = "WSUS"

$cscope = New-Object Microsoft.UpdateServices.Administration.ComputerTargetScope
$cscope.IncludeDownstreamComputerTargets = $true;
$cscope.IncludedInstallationStates = "Failed";

$computers = $WSUSServer.GetComputerTargets($cscope) | Sort FullDomainName;

$results = @();

if ($null -ne $computers) {
    $start = Get-Date -Date 0;
    $now = Get-Date;

    foreach ($comp in $computers) {
        $entry = "" | Select Name, Failedupdates;
        $entry.Name = $comp.FullDomainName;
        $entry.FailedUpdates = @();

        # Get the Failed Update
        $uscope = New-Object Microsoft.UpdateServices.Administration.UpdateScope
        $uscope.IncludedInstallationStates = "Failed";
        $failed_updates = $comp.GetUpdateInstallationInfoPerUpdate($uscope)

        foreach ($failed_update in $failed_updates) {
            #try {
                $update = "" | Select UpdateId, Update, Message, ErrorCode, When, Line;
                $update.UpdateId = $failed_update.UpdateId;
                $update.Update = $WSUSServer.GetUpdate($failed_update.UpdateId);
                $entry.FailedUpdates += $update;

                $update.Line = $update.Update.Title;

            <#} catch {
                Write-Host "Failed to get the Update from the UpdateId" -Foreground Red;

            }#>
        }

        # Get the Failed Update Events for this computer.
        $events = $WSUSServer.GetUpdateEventHistory($start, $now, $comp);

        foreach ($event in $events) {
            if ($event.IsError -eq $true) {
                $found_update = $entry.FailedUpdates | ? { $_.UpdateId -eq $event.UpdateId };
                if ($null -ne $found_update) { 
                    try {
                        #$update = "" | Select UpdateId, Update, Message, ErrorCode, When, Line;
                        #$update.UpdateId = $event.UpdateId;
                        #$update.Update = $WSUSServer.GetUpdate($event.UpdateId);

                        $found_update.Message = $event.Message;
                        $found_update.ErrorCode = $event.ErrorCode;
                        $found_update.When = $event.CreationDate;

                        $found_update.Line = "$($found_update.Update.Title) - $($found_update.ErrorCode) - $($found_update.Message)"
        
                        #$entry.FailedUpdates += $update;

                    } catch {


                    }
                }
            }
        }

        $results += $entry;
    }

    $results | Select Name, @{N="Updates";E={ ($_.FailedUpdates | Select -ExpandProperty Line) -join "<br />" }};
}