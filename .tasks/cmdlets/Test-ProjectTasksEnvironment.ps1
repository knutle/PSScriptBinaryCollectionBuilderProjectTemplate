function Test-ProjectTasksEnvironment {
    [CmdletBinding()]
    param()

    Write-Verbose "Testing project tasks environment..."

    if(-not $global:__ProjectTasksEnvironment.IsInitialized) {
        throw "Project tasks environment is not initialized. Please run the initialization script first."
    }

    # Ensure the global project tasks environment is initialized
    if(-not $global:__ProjectTasksEnvironment -or -not $global:__ProjectTasksEnvironment.RequiredDirectories) {
        throw "Unable to resolve required project directories. Please check your initialization script."
    }

    # Ensure all required directories exist
    $requiredDirs = $global:__ProjectTasksEnvironment.RequiredDirectories
    foreach ($dir in $requiredDirs) {
        Write-Verbose "Checking required directory: $dir"
        if(-not (Test-Path $dir)) {
            $global:__ProjectTasksEnvironment.IsInitialized = $false

            Write-Error "Required directory '$dir' does not exist. Please check your project structure."
        }
    }

    if(-not $global:__ProjectTasksEnvironment.IsInitialized) {
        throw "Project tasks environment was de-initialized during validation."
    }

    Write-Verbose "Project tasks environment is valid."

    return $true
}