# BUILD:B64WRAPPER

if (Test-PathWritable -Path "$env:TEMP") {
    Write-Host "The environment temp directory is writable." -ForegroundColor Green
} else {
    Write-Host "The environment temp directory is not writable." -ForegroundColor Red
}