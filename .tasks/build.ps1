. $PSScriptRoot/init.ps1
. $PSScriptRoot/clean.ps1

$ProjectRoot = Get-ProjectTasksEnvironmentProperty -Name ProjectRoot
$BuildDir = Get-ProjectTasksEnvironmentProperty -Name BuildDir

Write-Host "Collect relevant source files to process during build" -ForegroundColor Yellow

$SourcePaths = @(
    "bin\"
    "src\"
    "scripts\"
    "lib\"
)

$SourcePaths | ForEach-Object {
    $SourcePath = Join-Path $ProjectRoot $_

    Write-Host "Processing source path '$SourcePath'" -ForegroundColor Cyan

    if(-not (Test-Path $SourcePath)) {
        Write-Error "Source path '$SourcePath' does not exist. Please check your project structure."
        exit 1
    }

    Copy-Item -Path $SourcePath -Destination (Join-Path $BuildDir $_) -Recurse
}

. "$PSScriptRoot\shared\make-autoloader.ps1"
. "$PSScriptRoot\shared\import-embeds.ps1"
. "$PSScriptRoot\shared\compile-b64wrappers.ps1"
. "$PSScriptRoot\shared\apply-templates.ps1"
