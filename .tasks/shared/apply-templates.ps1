$BuildDebugDir = (Get-ProjectTasksEnvironmentProperty BuildDebugDir)

Write-Host "Resolve script templates and generate bin files" -ForegroundColor Yellow

Get-ChildItem "$BuildDebugDir\scripts" -Filter "*.ps1" -Recurse | ForEach-Object {
    Write-Host "Process script $($_.Name) according to template" -ForegroundColor Cyan
    
    $ResolvedScriptName = Split-Path $_.FullName -Leaf
    
    $BinFileCount = 0
    $TemplateRefsCount = 0

    $RawScriptContent = Get-Content -Path $_.FullName -Raw

    if($RawScriptContent -match "^# BUILD:TEMPLATE\((.+)\)") {
        $TemplateRefsCount++

        $RelativeTemplatePath = "$BuildDebugDir\templates\$($Matches[1]).template"
        $ResolvedTemplatePath = Resolve-Path $RelativeTemplatePath

        if(Test-Path $ResolvedTemplatePath) {
            $TemplateDef = [System.IO.Path]::GetFileNameWithoutExtension($ResolvedTemplatePath)
            $TemplateName = [System.IO.Path]::GetFileNameWithoutExtension($TemplateDef)
            $TemplateExt = [System.IO.Path]::GetExtension($TemplateDef)

            Write-Host "> Resolved template $TemplateName of type $TemplateExt" -ForegroundColor DarkGray

            $ResolvedTemplateContent = Get-Content $ResolvedTemplatePath -Raw
            $Output = $RawScriptContent.Replace($Matches[0], $ResolvedTemplateContent)

            $BinFileName = "$ResolvedScriptName$($TemplateExt)"

            $Output | Out-File -FilePath "$BuildDebugDir\bin\$BinFileName"

            $BinFileCount++

            Write-Host "> Generated bin file $BinFileName from template" -ForegroundColor Green
        } else {
            throw "Unable to resolve template path from $RelativeTemplatePath"
        }
    }

    if($TemplateRefsCount -lt 1) {
        Write-Host "No templates referenced in script $ResolvedScriptName"
    }

    if($BinFileCount -gt 0) {
        Write-Host "> Template processing resulted in $BinFileCount bin files" -ForegroundColor Green
    } else {
        Write-Host "> No tagged imports found in file" -ForegroundColor DarkGray
    }
}