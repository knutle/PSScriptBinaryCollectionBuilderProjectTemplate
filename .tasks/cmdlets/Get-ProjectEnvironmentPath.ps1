function Get-ProjectEnvironmentPath {
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory=$true,
            Position = 0,
            ParameterSetName = "PathFromString"
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter(
            Mandatory=$false,
            ValueFromRemainingArguments=$true,
            Position = 1,
            ParameterSetName = "PathFromString"
        )][string[]]
        $SubPaths = @(),

        [Parameter(
            Mandatory=$true,
            Position = 0,
            ParameterSetName = "PathFromEnvironmentProperty"
        )]
        [ValidateSet("ProjectRoot", "BuildDebugDir", "BuildReleaseDir")]
        [string]
        $PathFromEnvironmentProperty,
     
        [Parameter(
            Mandatory=$false,
            ValueFromRemainingArguments=$true,
            Position = 1,
            ParameterSetName = "PathFromEnvironmentProperty"
        )][string[]]
        $EnvironmentSubPaths = @()
    )

    # if parameter set is PathFromEnvironmentProperty, resolve the path from the environment property
    if($PSCmdlet.ParameterSetName -eq "PathFromEnvironmentProperty") {
        $Path = Get-ProjectTasksEnvironmentProperty -Name $PathFromEnvironmentProperty

        if($EnvironmentSubPaths.Count -gt 0) {
            # If EnvironmentSubPaths are provided, append them to the resolved path
            $Path = Join-Path $Path @EnvironmentSubPaths
        }
        
        return $Path
    }

    if(-not $global:__ProjectTasksEnvironment.ProjectRoot) {
        throw "Project root is not set. Please ensure your environment is initialized."
    }

    if($SubPaths.Count -gt 0) {
        # If SubPaths are provided, append them to the unresolved path
        $Path = Join-Path $Path @SubPaths
    }

    return (Join-Path $global:__ProjectTasksEnvironment.ProjectRoot $Path)
}