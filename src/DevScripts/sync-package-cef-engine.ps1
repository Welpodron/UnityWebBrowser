# Version Check
if ($PSVersionTable.PSVersion.Major -lt 7)
{
    throw "You need to use the NEW PowerShell version! You can get it here: https://github.com/powershell/powershell#get-powershell"
}

#Find what version of CefGlue we are using
$CefGlueVersionFile = "../ThirdParty/CefGlue/CefGlue/Interop/version.g.cs"
$CefGlueVersionfileContent = Get-Content $CefGlueVersionFile
$CefGlueVersionRegex = [regex] 'CEF_VERSION = \"(\d+.\d+.\d+)'

$CefVersion = ""
foreach($Content in $CefGlueVersionfileContent)
{
    $Match = [System.Text.RegularExpressions.Regex]::Match($Content, $CefGlueVersionRegex)
    if($Match.Success) 
    {
        $CefVersion = $Match.groups[1].value
    }
}

$CorePackagePath = "../Packages/UnityWebBrowser/package.json"
$CorePackageJson = Get-Content $CorePackagePath | ConvertFrom-Json -AsHashtable
$CorePackageVersion = $CorePackageJson["version"]

$CefPackagesVersion = "$($CorePackageVersion)-$($CefVersion)"

$EngineCefJsonPath = "../Packages/UnityWebBrowser.Engine.Cef/package.json"
$EngineCefJson = Get-Content $EngineCefJsonPath | ConvertFrom-Json -AsHashtable
$EngineCefJson["version"] = $CefPackagesVersion
$EngineCefJson | ConvertTo-Json | Out-File -FilePath $EngineCefJsonPath

$EngineCefWinJsonPath = "../Packages/UnityWebBrowser.Engine.Cef.Win-x64/package.json"
$EngineCefWinJson = Get-Content $EngineCefWinJsonPath | ConvertFrom-Json -AsHashtable
$EngineCefWinJson["version"] = $CefPackagesVersion
$EngineCefWinJson["dependencies"]["dev.voltstro.unitywebbrowser.engine.cef"] = $CefPackagesVersion
$EngineCefWinJson | ConvertTo-Json | Out-File -FilePath $EngineCefWinJsonPath