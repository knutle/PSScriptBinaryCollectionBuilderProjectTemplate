. (Join-Path $PSScriptRoot "clean.ps1")

$BuildDebugDir = Get-ProjectTasksEnvironmentProperty -Name BuildDebugDir
$BuildSourcePaths = (Get-ProjectTasksEnvironmentProperty -Name SourceDirectories) + (Get-ProjectTasksEnvironmentProperty -Name ResourceDirectories)

Write-Host "Collect relevant source files to process during build" -ForegroundColor Yellow

$BuildSourcePaths | ForEach-Object {
    Write-Host "Processing build source path '$_'" -ForegroundColor Cyan

    if(-not (Test-Path $_)) {
        Write-Error "Source path '$_' does not exist. Please check your project structure."
        exit 1
    }

    Copy-Item -Path $_ -Destination "$BuildDebugDir/" -Recurse
}

. (Join-Path $PSScriptRoot "shared" "make-autoloader.ps1")
. (Join-Path $PSScriptRoot "shared" "import-embeds.ps1")
. (Join-Path $PSScriptRoot "shared" "resolve-stubs.ps1")
. (Join-Path $PSScriptRoot "shared" "compile-b64wrappers.ps1")
. (Join-Path $PSScriptRoot "shared" "apply-templates.ps1")
