$BuildDebugDir = (Get-ProjectTasksEnvironmentProperty BuildDebugDir)

Write-Host "Compile any scripts tagged for base64 embedding" -ForegroundColor Yellow

Get-ChildItem "$BuildDebugDir\scripts" -Filter "*.ps1" | ForEach-Object {
    Write-Host "Collecting script file $($_.Name) for embedding" -ForegroundColor Cyan

    $RawScriptContent = Get-Content -Path $_.FullName -Raw

    if($RawScriptContent -match "^# BUILD:B64WRAPPER") {
        $ResolvedScriptContent = ($RawScriptContent -replace "^# BUILD:B64WRAPPER", [string]::Join("`n", @(
            "# This script is automatically generated by the build process."
            "# It contains base64 encoded content of the original script."
            "# Do not edit this file directly."
            
            "`$PSScriptRoot = `"`$([System.Environment]::ExpandEnvironmentVariables(`"%currentFileDir%`"))`""
            "`$PSScriptName = `"`$([System.Environment]::ExpandEnvironmentVariables(`"%currentFileName%`"))`""
            "`$PSCommandPath = (Join-Path `$PSScriptRoot `$PSScriptName)"
        )))

        $EncodedContent = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($ResolvedScriptContent))
        $EncodedFileName = "$($_.BaseName).cmd"

        $EncodedFilePath = "$BuildDebugDir\bin\$EncodedFileName"
        
        $WrapperLines = [array]@(
            "@echo off"
            "REM This script is automatically generated by the build process."
            "REM It contains base64 encoded content of the original script."
            "REM Do not edit this file directly."
            "echo Invoking PowerShell script with base64 encoded content..."
            "set `"originalWorkingDir=%cd%`""
            "set `"currentFileDir=%~dp0`""
            "set `"currentFileName=%~nx0`""
            "cd %currentFileDir%"
            "start powershell.exe -ExecutionPolicy Bypass -NoExit -NoProfile -EncodedCommand $EncodedContent"
            "cd %originalWorkingDir%"
        )

        [string]::Join("`n", $WrapperLines) | Out-File -FilePath $EncodedFilePath -Encoding ASCII

        Write-Host "> Wrapper for encoded script content written to $EncodedFilePath" -ForegroundColor Green
    }
}