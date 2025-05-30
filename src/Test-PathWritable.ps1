function Test-PathWritable {
    param (
        [string]$Path
    )

    if (!(Test-Path $Path -PathType Container)) {
        return $false
    }

    $FileName = Join-Path $Path ([io.path]::GetRandomFileName())

    try {
        [io.file]::OpenWrite($FileName).close()
        [io.file]::Delete($FileName)
        return $true
    } catch {
        return $false
    }
}