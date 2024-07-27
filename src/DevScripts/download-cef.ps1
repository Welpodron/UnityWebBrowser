# Version Check
if ($PSVersionTable.PSVersion.Major -lt 5)
{
    throw "You need to use the NEW PowerShell version! You can get it here: https://github.com/powershell/powershell#get-powershell"
}

function Reset 
{
    #Reset our location
    Pop-Location
}

function CheckProcess
{
    param(
    [Parameter (Mandatory = $true)] [String]$ErrorMessage,
    [Parameter (Mandatory = $true)] [System.Diagnostics.Process]$Process
    )

    if($Process.ExitCode -ne 0) 
    {
        Reset
        throw $ErrorMessage
    }
}

$OperatingSystem = "windows64"
#Set location
Push-Location $PSScriptRoot

$CefGlueVersionFile = "../ThirdParty/CefGlue/CefGlue/Interop/version.g.cs"

if(-not (Test-Path -Path $CefGlueVersionFile))
{
    Write-Warning "The CefGlue version file doesn't exist! Initalizing the submodules for you..."
    Push-Location "$($PSScriptRoot)../../"

    #Run git submodule init and update
    $p = Start-Process git -ArgumentList 'submodule init' -Wait -NoNewWindow -PassThru
    CheckProcess "Error running git submodule init!" $p

    $p = Start-Process git -ArgumentList 'submodule update' -Wait -NoNewWindow -PassThru
    CheckProcess "Error running git submodule update!" $p

    #Return location
    Reset
}

$CefGlueVersionfileContent = Get-Content $CefGlueVersionFile
$CefGlueVersionRegex = [regex] 'CEF_VERSION = \"(.*)\"'

if(!$CefGlueVersionfileContent)
{
    Reset
    throw "Failed to read version info!"
}

$CefVersion = ""
foreach($Content in $CefGlueVersionfileContent)
{
    $Match = [System.Text.RegularExpressions.Regex]::Match($Content, $CefGlueVersionRegex)
    if($Match.Success) 
    {
        $CefVersion = $Match.groups[1].value
    }
}

#Create a temp directory
#NOTE: We have [void] at the start here so it doens't spew out the logs
[void](New-Item -Path "../ThirdParty/Libs/cef/" -Name "temp" -ItemType "directory" -Force)

#Lots of variables we gonna use
$TempDirectory = (Resolve-Path -Path ../ThirdParty/Libs/cef/temp/).Path
$CefBinName = "cef_binary_$($cefVersion)_$($OperatingSystem)_minimal"
$CefBinTarFileName = "$($CefBinName).tar"
$CefBinTarFileLocation = "$($TempDirectory)$($CefBinTarFileName)"
$CefBinTarBz2FileName = "$($CefBinTarFileName).bz2"
$CefBinTarBz2FileLocation = "$($TempDirectory)$($CefBinTarBz2FileName)"

Write-Output "Downloading CEF version $($CefVersion) for $($OperatingSystem)..."

#We download the CEF builds off from Spotify's CEF build server
#The URL look like this:
#   https://cef-builds.spotifycdn.com/cef_binary_[CEF-VERSION]_[OPERATING-SYSTEM]_minimal.tar.bz2
#   Example: https://cef-builds.spotifycdn.com/cef_binary_85.3.12+g3e94ebf+chromium-85.0.4183.121_linux64_minimal.tar.bz2

$progressPreference = 'silentlyContinue'
Invoke-WebRequest -Uri "https://cef-builds.spotifycdn.com/$($CefBinTarBz2FileName)" -OutFile $CefBinTarBz2FileLocation
$progressPreference = 'Continue'

# #Check to make sure the file downloaded
if(-not (Test-Path -Path $CefBinTarBz2FileLocation))
{
    Reset
    throw "CEF build failed to download!"
}

Write-Output "Downloaded CEF build to '$($CefBinTarBz2FileLocation)'."
Write-Output "Exracting CEF build..."

#Extract our files
$tarApp = "tar.exe"

$p = Start-Process $tarApp -ArgumentList "-xvzf $($CefBinTarBz2FileLocation) -C $($TempDirectory) *.pak *.dat *.bin *.dll *.lib *.json" -Wait -NoNewWindow -PassThru
CheckProcess "Extracting failed!" $p

#Setup some variables to using the copying phase
$CefExtractedLocation = (Resolve-Path -Path "$($TempDirectory)/$($CefBinName)/").Path
$CefExtractedReleaseLocation = "$($CefExtractedLocation)Release/"
$CefExtractedResourcesLocation = "$($CefExtractedLocation)Resources/"

$CefLibsLocation = (Resolve-Path -Path ../ThirdParty/Libs/cef/$($OperatingSystem)).Path

# #Copy files
Write-Output "Copying files..."

Copy-Item -Path "$($CefExtractedReleaseLocation)/*" -Destination $CefLibsLocation -Force -PassThru -Recurse
Copy-Item -Path "$($CefExtractedResourcesLocation)/*" -Destination $CefLibsLocation -Force -PassThru -Recurse

# Cleanup
Write-Output "Cleaning up..."
Remove-Item -Path $CefBinTarBz2FileLocation -Force
Remove-Item -Path $CefExtractedLocation -Force -Recurse

Reset

Write-Output "Done!"