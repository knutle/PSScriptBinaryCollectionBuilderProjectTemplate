. (Join-Path $PSScriptRoot "clean.ps1")

$ProjectRoot = Get-ProjectTasksEnvironmentProperty -Name ProjectRoot
$BuildDir = Get-ProjectTasksEnvironmentProperty -Name BuildDebugDir
$SourcePaths = (Get-ProjectTasksEnvironmentProperty -Name SourceDirectories) + (Get-ProjectTasksEnvironmentProperty -Name ResourceDirectories)

Write-Host "Collect relevant source files to process during build" -ForegroundColor Yellow

$SourcePaths | ForEach-Object {
    $SourcePath = Join-Path $ProjectRoot $_

    Write-Host "Processing source path '$SourcePath'" -ForegroundColor Cyan

    if(-not (Test-Path $SourcePath)) {
        Write-Error "Source path '$SourcePath' does not exist. Please check your project structure."
        exit 1
    }

    Copy-Item -Path $SourcePath -Destination (Join-Path $BuildDir $_) -Recurse
}

. (Join-Path $PSScriptRoot "shared" "make-autoloader.ps1")
. (Join-Path $PSScriptRoot "shared" "import-embeds.ps1")
. (Join-Path $PSScriptRoot "shared" "compile-b64wrappers.ps1")
. (Join-Path $PSScriptRoot "shared" "apply-templates.ps1")
