. $PSScriptRoot/init.ps1

Set-Location $(Get-ProjectTasksEnvironmentProperty -Name OutputDir) -ErrorAction Stop

Write-Host "Cleaning up build files..." -ForegroundColor Cyan

Remove-Item -Recurse -Force ./build/* -Exclude ".gitkeep"