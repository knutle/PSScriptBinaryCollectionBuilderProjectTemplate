. (Join-Path $PSScriptRoot "init.ps1")

Write-Host "Cleaning up build files..." -ForegroundColor Cyan

Remove-Item -Recurse -Force -Path (Get-ProjectEnvironmentPath -PathFromEnvironmentProperty BuildDebugDir "*")