. (Join-Path $PSScriptRoot "build.ps1")

$ProjectName = Get-ProjectTasksEnvironmentProperty -Name ProjectName
$BuildDebugDir = Get-ProjectTasksEnvironmentProperty -Name BuildDebugDir
$ReleaseDir = Get-ProjectTasksEnvironmentProperty -Name ReleaseDir
$ResourceDirs = Get-ProjectTasksEnvironmentProperty -Name ResourceDirectories

$ArchivePaths = ($BuildDebugDir, $ResourceDirs) | ForEach-Object {
    if(-not (Test-Path $_)) {
        Write-Error "Build directory '$_' does not exist. Please run the build task first."
        exit 1
    }

    return Join-Path $_ "*"
}

$archiveName = "$ProjectName $(Get-Date -UFormat "%Y-%m-%d %H%M%S").zip"
$archiveDestinationPath = "$(Join-Path $ReleaseDir $archiveName)"

if(!(Test-Path $ReleaseDir)) {
    New-Item $ReleaseDir -ItemType Directory -Force
}

Compress-Archive -Path $ArchivePaths -DestinationPath "$archiveDestinationPath"

Start-Process explorer.exe -ArgumentList "/select,`"$archiveDestinationPath`""