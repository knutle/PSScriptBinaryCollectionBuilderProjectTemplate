$BuildDir = (Get-ProjectTasksEnvironmentProperty BuildDir)

Write-Host "Generating self-contained autoloader" -ForegroundColor Yellow

$AutoloaderPath = "$BuildDir\lib\_autoload_full.ps1"

if(-not (Test-Path $AutoloaderPath)) {
    New-Item -ItemType File -Path $AutoloaderPath | Out-Null
} else {
    Clear-Content -Path $AutoloaderPath
}

Get-ChildItem "$BuildDir\src" -Filter "*-*.ps1" | ForEach-Object {
    Write-Host "Import '$($_.Name)'" -ForegroundColor Cyan
    
    Get-Content -Path $_.FullName | Out-File -FilePath $AutoloaderPath -Append
}