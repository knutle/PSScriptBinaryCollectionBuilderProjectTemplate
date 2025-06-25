$BuildDebugDir = (Get-ProjectTasksEnvironmentProperty BuildDebugDir)

Write-Host "Compile any scripts tagged for base64 embedding" -ForegroundColor Yellow

Get-ChildItem "$BuildDebugDir\scripts" -Filter "*.ps1" | ForEach-Object {
    Write-Host "Collecting script file $($_.Name) for embedding" -ForegroundColor Cyan

    $RawScriptContent = Get-Content -Path $_.FullName -Raw

    if($RawScriptContent -match "^# BUILD:B64WRAPPER") {
        $EncodedContent = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes(($RawScriptContent -replace "^# BUILD:B64WRAPPER", "`$PSScriptRoot = `"`$(cmd /c echo %cd%)`"")))
        $EncodedFileName = "$($_.BaseName).cmd"

        $EncodedFilePath = "$BuildDebugDir\bin\$EncodedFileName"
        
        $WrapperLines = [array]@(
            "@echo off"
            "cd %~dp0"
            "powershell.exe -ExecutionPolicy Bypass -NoExit -NoProfile -EncodedCommand $EncodedContent"
        )

        [string]::Join("`n", $WrapperLines) | Out-File -FilePath $EncodedFilePath -Encoding ASCII

        Write-Host "> Wrapper for encoded script content written to $EncodedFilePath" -ForegroundColor Green
    }
}