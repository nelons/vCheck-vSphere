$Title = "Unassigned Computers"
$Author = "Neale Lonslow"
$PluginVersion = 1.0
$Header = "Unassigned Computers"
$Comments = "Computers that do not belong to a WSUS Group."
$Display = "Table"
$PluginCategory = "WSUS"

# Change this if the group name is displayed as something different in your WSUS.
$unassigned_computers_group_name = "Unassigned Computers";

$unassigned_group = $Groups | ? { $_.Name -eq $unassigned_computers_group_name };

if ($null -ne $unassigned_group) {
    # Get the Computers in the group.
    $cscope = New-Object Microsoft.UpdateServices.Administration.ComputerTargetScope
    $cscope.IncludeDownstreamComputerTargets = $true;
    $cscope.ComputerTargetGroups.Add($unassigned_group) | out-null;

    $computers = $WSUSServer.GetComputerTargets($cscope);

    $computers | Select @{L='Name';E={$_.FullDomainName}}, @{L='IP Address';E={$_.IPAddress}}, @{L='Operating System';E={$_.OSDescription}}, @{L='Last Reported';E={$_.LastReportedStatusTime}} 
    #$computers | Select FullDomainName, IPAddress, OSDescription, LastReportedStatusTime
}