$BuildDir = (Get-ProjectTasksEnvironmentProperty BuildDir)

Write-Host "Scanning for any files marked for embedding during build" -ForegroundColor Yellow

Get-ChildItem $BuildDir -Filter "*.ps1" -Recurse | ForEach-Object {
    Write-Host "> Importing embeds for $($_.Name)" -ForegroundColor Cyan
    
    $ResolvedScriptRoot = Split-Path $_.FullName
    
    $ReplacementsCount = 0
    $ErrorsCount = 0

    $ResolvedOutput = Get-Content -Path $_.FullName | ForEach-Object {
        if($_ -match "^\.[ ]*?`"(.+)`" # BUILD:EMBED$") {
            $ResolvedScriptPath = Resolve-Path $Matches[1].Replace("`$PSScriptRoot", $ResolvedScriptRoot)
            $MatchedScriptPath = $Matches[1]
            $MatchedScriptName = Split-Path $MatchedScriptPath -Leaf

            if(Test-Path $ResolvedScriptPath) {
                Write-Host "> Resolved $MatchedScriptPath to $ResolvedScriptPath" -ForegroundColor DarkGray

                $ResolvedScriptContent = Get-Content $ResolvedScriptPath -Raw
                $ResolvedScriptContent = [string]::Join("`n", @(
                    ""
                    "# START EMBEDDED CONTENT FROM $MatchedScriptName"
                    $ResolvedScriptContent
                    "# END EMBEDDED CONTENT FROM $MatchedScriptName"
                    ""
                ))

                $Output = $_.Replace($Matches[0], $ResolvedScriptContent)

                $ReplacementsCount++
            } else {
                $ErrorsCount++
                Write-Error "Unable to resolve file path from $($Matches[0])"
                $Output = $_
            }

            $Output
        } else {
            $_
        }
    }

    if($ErrorsCount -gt 0) {
        Write-Error "Encountered $ErrorsCount errors while resolving embedded scripts in file $($_.FullName)"
    } elseif($ReplacementsCount -gt 0) {
        $ResolvedOutput | Out-File $_.FullName
        
        Write-Host "> Resolved $ReplacementsCount embedded scripts in file $($_.Name)" -ForegroundColor Green
    } else {
        Write-Host "> No tagged imports found in file" -ForegroundColor DarkGray
    }
}