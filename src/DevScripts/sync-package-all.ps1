# Version Check
if ($PSVersionTable.PSVersion.Major -lt 5)
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

$CorePackageName = "dev.voltstro.unitywebbrowser.engine.cef"
$CorePackagePath = "../Packages/UnityWebBrowser/package.json"
$CorePackageJson = Get-Content $CorePackagePath | ConvertFrom-Json 
$CorePackageVersion = $CorePackageJson.version

$CefPackagesVersion = "$($CorePackageVersion)-$($CefVersion)"

$EngineCefJsonPath = "../Packages/UnityWebBrowser.Engine.Cef/package.json"
$EngineCefJson = Get-Content $EngineCefJsonPath | ConvertFrom-Json

if (!$EngineCefJson) {
    $EngineCefJson = @{
        "name" = $CorePackageName
        "version" = $CefPackagesVersion
    }
} else {
    $EngineCefJson | Add-Member -Force -MemberType NoteProperty -Name "name" -Value $CorePackageName
    $EngineCefJson | Add-Member -Force -MemberType NoteProperty -Name "version" -Value $CefPackagesVersion
}

$EngineCefJson | ConvertTo-Json | Out-File -NoNewline -FilePath $EngineCefJsonPath -Encoding UTF8

$EngineCefWinJsonPackageName = "dev.voltstro.unitywebbrowser.engine.cef.win.x64"
$EngineCefWinJsonPath = "../Packages/UnityWebBrowser.Engine.Cef.Win-x64/package.json"

if(-not (Test-Path -Path $EngineCefWinJsonPath)) {
    $EngineCefWinJson = @{
        "name" = $EngineCefWinJsonPackageName
        "version" = $CefPackagesVersion
    }
} else {
    $EngineCefWinJson = Get-Content $EngineCefWinJsonPath | ConvertFrom-Json
}   

if (!$EngineCefWinJson) {
    $EngineCefWinJson = @{
        "name" = $EngineCefWinJsonPackageName
        "version" = $CefPackagesVersion
    }
} else {
    $EngineCefWinJson | Add-Member -Force -MemberType NoteProperty -Name "name" -Value $EngineCefWinJsonPackageName
    $EngineCefWinJson | Add-Member -Force -MemberType NoteProperty -Name "version" -Value $CefPackagesVersion
}

$EngineCefWinJson | ConvertTo-Json | Out-File -NoNewline -FilePath $EngineCefWinJsonPath -Encoding UTF8