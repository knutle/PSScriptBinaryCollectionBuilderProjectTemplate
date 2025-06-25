. (Join-Path $PSScriptRoot "build.ps1")

$ProjectName = Get-ProjectTasksEnvironmentProperty -Name ProjectName
$BuildDebugDir = Get-ProjectTasksEnvironmentProperty -Name BuildDebugDir
$BuildReleaseDir = Get-ProjectTasksEnvironmentProperty -Name BuildReleaseDir
$ResourceDirs = Get-ProjectTasksEnvironmentProperty -Name ResourceDirectories

$ArchivePaths = ((Join-Path $BuildDebugDir "bin"), $ResourceDirs) | ForEach-Object {
    if(-not (Test-Path $_)) {
        Write-Error "Build directory '$_' does not exist. Please run the build task first."
        exit 1
    }

    return Join-Path $_ "*"
}

$archiveName = "$ProjectName $(Get-Date -UFormat "%Y-%m-%d %H%M%S").zip"
$archiveDestinationPath = "$(Join-Path $BuildReleaseDir $archiveName)"

if(!(Test-Path $BuildReleaseDir)) {
    New-Item $BuildReleaseDir -ItemType Directory -Force
}

Compress-Archive -Path $ArchivePaths -DestinationPath "$archiveDestinationPath"

Start-Process explorer.exe -ArgumentList "/select,`"$archiveDestinationPath`""