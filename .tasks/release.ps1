. $PSScriptRoot/build.ps1

$ProjectName = Get-ProjectTasksEnvironmentProperty -Name ProjectName
$BuildDir = Get-ProjectTasksEnvironmentProperty -Name BuildDir
$ReleaseDir = Get-ProjectTasksEnvironmentProperty -Name ReleaseDir

$archiveName = "$ProjectName $(Get-Date -UFormat "%Y-%m-%d %H%M%S").zip"
$archiveDestinationPath = "$(Join-Path $ReleaseDir $archiveName)"

if(!(Test-Path $ReleaseDir)) {
    New-Item $ReleaseDir -ItemType Directory -Force
}

Compress-Archive -Path "$BuildDir/bin/*" -DestinationPath "$archiveDestinationPath"

Start-Process explorer.exe -ArgumentList "/select,`"$archiveDestinationPath`""