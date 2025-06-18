function Get-ProjectTasksEnvironmentProperty {
    [CmdletBinding()]
    
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("ProjectRoot", "ProjectName", "BuildDebugDir", "BuildReleaseDir", "BuildDirectories", "SourceDirectories", "ResourceDirectories", "RequiredDirectories", "IsInitialized")]
        [string]$Name
    )

    if(-not $global:__ProjectTasksEnvironment.IsInitialized) {
        throw "Project tasks environment is not initialized. Please run the initialization script first."
    }
    
    $Value = $global:__ProjectTasksEnvironment.$Name

    if(-not $Value) {
        throw "Property '$Name' does not exist in the project tasks environment."
    }

    return $Value
}