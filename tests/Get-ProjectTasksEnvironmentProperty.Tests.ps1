# Requires -Module Pester
# Requires -Version 5.1

Describe "Get-ProjectTasksEnvironmentProperty" {

    BeforeEach {
        # Mock a global environment object using Join-Path with only positional parameters, using $env:TEMP as the root
        $projectRoot = Join-Path $env:TEMP "Project"
        $buildDir    = Join-Path $projectRoot "build"
        $debugDir    = Join-Path $buildDir "debug"
        $releaseDir  = Join-Path $buildDir "release"

        $global:__ProjectTasksEnvironment = [PSCustomObject]@{
            IsInitialized      = $true
            ProjectRoot        = $projectRoot
            ProjectName        = "TestProject"
            BuildDebugDir      = $debugDir
            BuildReleaseDir    = $releaseDir
            BuildDirectories   = @(
                Join-Path $projectRoot "build" "debug"
                Join-Path $projectRoot "build" "release"
            )
            SourceDirectories  = @(
                Join-Path $projectRoot "src"
            )
            ResourceDirectories= @(
                Join-Path $projectRoot "resources"
            )
            RequiredDirectories= @(
                Join-Path $projectRoot "src"
                Join-Path $projectRoot "resources"
                Join-Path $projectRoot "build"
            )
        }

        . (Join-Path $PSScriptRoot ".." ".tasks" "cmdlets" "Get-ProjectTasksEnvironmentProperty.ps1")
    }

    AfterEach {
        Remove-Variable -Name __ProjectTasksEnvironment -Scope Global -ErrorAction SilentlyContinue
    }

    It "returns the correct property value for ProjectRoot" {
        $result = Get-ProjectTasksEnvironmentProperty -Name ProjectRoot
        $result | Should -Be (Join-Path $env:TEMP "Project")
    }

    It "returns the correct property value for ProjectName" {
        $result = Get-ProjectTasksEnvironmentProperty -Name ProjectName
        $result | Should -Be "TestProject"
    }

    It "returns the correct property value for BuildDirectories" {
        $expected = @(
            Join-Path $env:TEMP "Project" "build" "debug"
            Join-Path $env:TEMP "Project" "build" "release"
        )
        $result = Get-ProjectTasksEnvironmentProperty -Name BuildDirectories
        $result | Should -Be $expected
    }

    It "returns the correct property value for BuildReleaseDir" {
        $result = Get-ProjectTasksEnvironmentProperty -Name BuildReleaseDir
        $result | Should -Be (Join-Path $env:TEMP "Project" "build" "release")
    }
    It "returns the correct property value for BuildDebugDir" {
        $result = Get-ProjectTasksEnvironmentProperty -Name BuildDebugDir
        $result | Should -Be (Join-Path $env:TEMP "Project" "build" "debug")
    }
    It "returns the correct property value for SourceDirectories" {
        $expected = @(
            Join-Path $env:TEMP "Project" "src"
        )
        $result = Get-ProjectTasksEnvironmentProperty -Name SourceDirectories
        $result | Should -Be $expected
    }

    It "throws if the environment is not initialized" {
        $global:__ProjectTasksEnvironment.IsInitialized = $false
        { Get-ProjectTasksEnvironmentProperty -Name ProjectRoot } | Should -Throw "Project tasks environment is not initialized. Please run the initialization script first."
    }

    It "throws if the property does not exist" {
        # Remove ProjectRoot property
        $global:__ProjectTasksEnvironment.PSObject.Properties.Remove("ProjectRoot")
        { Get-ProjectTasksEnvironmentProperty -Name ProjectRoot } | Should -Throw "Property 'ProjectRoot' does not exist in the project tasks environment."
    }

    It "throws if an invalid property name is provided" {
        { Get-ProjectTasksEnvironmentProperty -Name "InvalidProperty" } | Should -Throw
    }
}