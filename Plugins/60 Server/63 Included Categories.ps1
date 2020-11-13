$Title = "Categories to Download"
$Author = "Neale Lonslow"
$PluginVersion = 1.0
$Header = "Categories"
$Comments = "Updates will be retrieved for these products."
$Display = "Table"
$PluginCategory = "WSUS"

$sub = $WSUSServer.GetSubscription();
$cats = $sub.GetUpdateCategories();

$cats | Sort-Object Title | Select-Object Title;