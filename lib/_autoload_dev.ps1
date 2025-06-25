Write-Verbose "Autoloading"

Get-ChildItem "$PSScriptRoot\..\src" -Filter "*-*.ps1" | ForEach-Object {
    Write-Verbose "Loading $($_.Name) from path $($_.FullName)"
    . $_.FullName
}