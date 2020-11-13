$Title = "Classifications to Download"
$Author = "Neale Lonslow"
$PluginVersion = 1.0
$Header = "Classifications"
$Comments = "These are the types of updates that will be downloaded automatically."
$Display = "Table"
$PluginCategory = "WSUS"

$sub = $WSUSServer.GetSubscription();
$classes = $sub.GetUpdateClassifications();

$classes | Sort-Object Title | Select-Object Title;