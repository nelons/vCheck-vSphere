$Title = "Computer with no group.ps1"
$Author = "Neale Lonslow"
$PluginVersion = 1.0
$Header = "Computers with no group configured at the client level."
$Comments = "Computers that are not configured (typically by GPO) to belong in a specific WSUS group."
$Display = "Table"
$PluginCategory = "WSUS"

$computers = $WSUSServer.GetComputerTargets();

$filtered = $computers | Where-Object { 
    $_.RequestedTargetGroupName -eq $null -Or $_.RequestedTargetGroupName.Length -eq 0 
} | Sort-Object FullDomainName;

$filtered | Select-Object FullDomainName, IPAddress, OSDescription;