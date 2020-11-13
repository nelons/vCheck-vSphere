$Title = "Computer Groups Dont match"
$Author = "Neale Lonslow"
$PluginVersion = 1.0
$Header = "Computers in a configuration mismatched group."
$Comments = "Lists computers that are configured to be in a group, but are actually in another group."
$Display = "Table"
$PluginCategory = "WSUS"

$results = @();

$WSUSServer = Get-WsusServer wsus-prd-01.rci.uk -PortNumber 8530

$computers = $WSUSServer.GetComputerTargets();

$computers | % {
    $entry = "" | Select Name, RequestedGroup, ActualGroups;
    $entry.Name = $_.FullDomainName;
    $entry.RequestedGroup = $_.RequestedTargetGroupName;

    if ($null -ne $_.RequestedTargetGroupName -And $_.RequestedTargetGroupName -gt 0) {  
        #Write-Host $_.Fulldomainname;
        $ids = $_.ComputerTargetGroupIds | % { 
            $id = $_.Guid; 
            $target_groups = $groups | ? { $_.Id -eq $id }; 
            return $target_groups; 
        }; 

        write-host $ids;
    
        if ($null -ne $ids) {
            $groups = $ids | Select -expandproperty Name;
            $entry.ActualGroups = [string]::join(',', $groups);
            $results += $entry;
        }
    }
}

$results | Sort Name | Select Name, RequestedGroup, ActualGroups;