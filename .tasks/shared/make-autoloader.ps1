$BuildDebugDir = (Get-ProjectTasksEnvironmentProperty BuildDebugDir)

Write-Host "Generating self-contained autoloader" -ForegroundColor Yellow

$AutoloaderPath = "$BuildDebugDir\lib\_autoload.ps1"

if(-not (Test-Path $AutoloaderPath)) {
    New-Item -ItemType File -Path $AutoloaderPath | Out-Null
} else {
    Clear-Content -Path $AutoloaderPath
}

Get-ChildItem "$BuildDebugDir\src" -Filter "*-*.ps1" | ForEach-Object {
    Write-Host "Import '$($_.Name)'" -ForegroundColor Cyan
    
    Get-Content -Path $_.FullName | Out-File -FilePath $AutoloaderPath -Append
}