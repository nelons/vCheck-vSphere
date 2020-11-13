# Start of Settings
$UpdatesInDays = -7;
$ExcludedClassifications = @("Definition Updates");
# End of Settings

$yesterday = $(get-date).AddDays($UpdatesInDays);

$uscope = New-Object Microsoft.UpdateServices.Administration.UpdateScope
$uscope.FromArrivalDate = $yesterday;

# Get all the builtin classifications
$all_class = $WSUSServer.GetUpdateClassifications()

# Get the subcription
$sub = $WSUSServer.GetSubscription();

# Get the classifications included in the sub.
$sub_class = $sub.GetUpdateClassifications();

# Make sure we're only interested in the classifications we're getting.
foreach ($class in $sub_class) {
    # Are we ignoring this classification ?
    $excluded = $ExcludedClassifications | Where-Object { $_ -eq $class.Title };

    if ($null -eq $excluded) {
        $def = $all_class | Where-Object { 
            $_.Title -eq $class.Title 
        };
        
        if ($null -ne $def) { 
            $uscope.Classifications.Add($def); 
        } 
    }
}

$updates = $WSUSServer.SearchUpdates($uscope);

$updates | Select-Object Title, UpdateClassificationTitle, ArrivalDate;

$Title = "Updates arrived in last 24 hours"
$Author = "Neale Lonslow"
$PluginVersion = 1.0
$Header = "New Updates"
$Comments = "Updates that have arrived within the last $UpdatesInDays days."
$Display = "Table"
$PluginCategory = "WSUS"