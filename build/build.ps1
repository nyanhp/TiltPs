param (
    [string]
    $Repository = 'PSGallery'
)
$workingDirectory = Split-Path $PSScriptRoot

# Prepare output path and copy function folder
Remove-Item -Path "$workingDirectory/publish" -Recurse -Force -ErrorAction Ignore
$buildFolder = New-Item -Path $workingDirectory -Name 'publish' -ItemType Directory -Force -ErrorAction Stop
Copy-Item -Path "$workingDirectory/function/*" -Destination $buildFolder.FullName -Recurse -Force
$null = New-Item -ItemType Directory -Path (Join-Path $workingDirectory 'publish/modules') -Force -ErrorAction Stop

# Process Dependencies
$requiredModules = (Import-PowerShellDataFile -Path "$workingDirectory/AutoBeerPS/AutoBeerPS.psd1").RequiredModules
foreach ($module in $requiredModules) {
    Save-Module -Name $module -Path "$($buildFolder.FullName)/modules" -Force -Repository $Repository
}

# Process Function Module
Copy-Item -Path "$workingDirectory/AutoBeerPS" -Destination "$($buildFolder.FullName)/modules" -Force -Recurse

Get-ChildItem $buildFolder
