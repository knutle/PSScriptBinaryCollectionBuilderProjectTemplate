$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$ProjectName = Split-Path $ProjectRoot -Leaf
$OutputDir = Join-Path $ProjectRoot "output"
$BuildDir = Join-Path $OutputDir "build"
$ReleaseDir = Join-Path $OutputDir "release"

if(-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

if(-not (Test-Path $BuildDir)) {
    New-Item -ItemType Directory -Path $BuildDir | Out-Null
}

if(-not (Test-Path $ReleaseDir)) {
    New-Item -ItemType Directory -Path $ReleaseDir | Out-Null
}

$global:__ProjectTasksEnvironment = @{
    ProjectRoot = $ProjectRoot
    ProjectName = $ProjectName
    OutputDir = $OutputDir
    BuildDir = $BuildDir
    ReleaseDir = $ReleaseDir
    IsInitialized = $true
}

function Get-ProjectTasksEnvironmentProperty {
    [CmdletBinding()]
    
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("ProjectRoot", "ProjectName", "OutputDir", "BuildDir", "ReleaseDir", "IsInitialized")]
        [string]$Name
    )

    if(-not $global:__ProjectTasksEnvironment.IsInitialized) {
        throw "Project tasks environment is not initialized. Please run the initialization script first."
        
        return $null
    }
    
    $Value = $global:__ProjectTasksEnvironment.$Name

    if(-not $Value) {
        throw "Property '$Name' does not exist in the project tasks environment."
    }

    return $Value
}