$CurrentScriptFileParentDir = Split-Path $PSScriptRoot -Leaf

if($CurrentScriptFileParentDir -ne ".tasks") {
    throw "All build scripts must be run from the '.tasks' directory. Current parent directory is '$CurrentScriptFileParentDir'. Please check your project structure and try again."
}

$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$ProjectName = Split-Path $ProjectRoot -Leaf

$global:__ProjectTasksEnvironment = @{
    ProjectRoot = $ProjectRoot
    ProjectName = $ProjectName
    
    IsInitialized = $false
}

. (Join-Path $PSScriptRoot "cmdlets" "Get-ProjectEnvironmentPath.ps1")

# Initialize the project tasks environment

$BuildDirectories = @(
    "build"
    (Join-Path "build" "debug")
    (Join-Path "build" "release")
)

$SourceDirectories = @(
    "bin"
    "src"
    (Join-Path "src" "templates")
    "scripts"
    "lib"
)

$ResourceDirectories = @(
    "resources"
)

$global:__ProjectTasksEnvironment += @{
    BuildDebugDir = Get-ProjectEnvironmentPath -Path "build" "debug"
    BuildReleaseDir = Get-ProjectEnvironmentPath -Path "build" "release"
    
    BuildDirectories = $BuildDirectories | ForEach-Object { Get-ProjectEnvironmentPath -Path $_ }
    SourceDirectories = $SourceDirectories | ForEach-Object { Get-ProjectEnvironmentPath -Path $_ }
    ResourceDirectories = $ResourceDirectories | ForEach-Object { Get-ProjectEnvironmentPath -Path $_ }
}

$global:__ProjectTasksEnvironment += @{
    RequiredDirectories = $global:__ProjectTasksEnvironment.BuildDirectories + $global:__ProjectTasksEnvironment.SourceDirectories + $global:__ProjectTasksEnvironment.ResourceDirectories
}

$global:__ProjectTasksEnvironment.RequiredDirectories | ForEach-Object {
    if(-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -ErrorAction Stop | Out-Null
    }
}

. (Join-Path $PSScriptRoot "cmdlets" "Test-ProjectTasksEnvironment.ps1")

$global:__ProjectTasksEnvironment.IsInitialized = Test-ProjectTasksEnvironment

if(-not $global:__ProjectTasksEnvironment.IsInitialized) {
    throw "Project tasks environment was de-initialized during validation."
}

. (Join-Path $PSScriptRoot "cmdlets" "Get-ProjectTasksEnvironmentProperty.ps1")
