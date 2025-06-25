$ProjectRoot = (Get-ProjectTasksEnvironmentProperty ProjectRoot)
$BuildDebugDir = (Get-ProjectTasksEnvironmentProperty BuildDebugDir)

Write-Host "Resolve template stubs before compiling scripts" -ForegroundColor Yellow

Get-ChildItem "$BuildDebugDir\scripts" -Filter "*.ps1" -Recurse | ForEach-Object {
    Write-Host "Resolve stubs in script $($_.Name)" -ForegroundColor Cyan
    
    $ResolvedScriptName = Split-Path $_.FullName -Leaf
    
    $StubRefsCount = 0

    $ScriptContentLines = Get-Content -Path $_.FullName

    $ParsedOutput = $ScriptContentLines | ForEach-Object {
        $Line = $_

        if($_ -match "^# BUILD:STUB\((.+)\)$") {
            $StubRefsCount++

            $RelativeStubPath = "$BuildDebugDir\templates\$($Matches[1]).stub"
            $ResolvedStubPath = Resolve-Path $RelativeStubPath

            if(Test-Path $ResolvedStubPath) {
                $StubDef = [System.IO.Path]::GetFileNameWithoutExtension($ResolvedStubPath)
                $StubName = [System.IO.Path]::GetFileNameWithoutExtension($StubDef)
                $StubExt = [System.IO.Path]::GetExtension($StubDef)

                Write-Host "> Resolved stub $StubName of type $StubExt" -ForegroundColor DarkGray

                $ResolvedStubContent = Get-Content $ResolvedStubPath -Raw
                $Line = $_.Replace($Matches[0], $ResolvedStubContent)

                Write-Host "> Inserted $($ResolvedStubContent.Length) characters from stub $StubName" -ForegroundColor Green
            } else {
                Write-Error "Unable to resolve stub path from $RelativeStubPath"
            }
        }

        $Line
    }

    $OutputFilePath = $_.FullName

    $ParsedOutput | Out-File -FilePath $OutputFilePath

    if($StubRefsCount -gt 0) {
        Write-Host "> Resolved $StubRefsCount stubs in script $ResolvedScriptName" -ForegroundColor Green
    } else {
        Write-Host "> No stubs referenced in script $ResolvedScriptName"
    }
}