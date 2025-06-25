# Requires -Module Pester
# Requires -Version 5.1

Describe "Get-ProjectEnvironmentPath" {

    BeforeAll {
        # Set up global environment
        $global:__ProjectTasksEnvironment = @{
            ProjectRoot = Join-Path $env:TEMP "ProjectRoot"
            BuildDebugDir = Join-Path $env:TEMP "ProjectRoot" "build" "debug"
            BuildReleaseDir = Join-Path $env:TEMP "ProjectRoot" "build" "release"
            IsInitialized = $false
        }
        
        # Mock environment property getter
        function Get-ProjectTasksEnvironmentProperty {
            param([string]$Name)

            switch ($Name) {
                "ProjectRoot"     { return $global:__ProjectTasksEnvironment.ProjectRoot }
                "BuildDebugDir"   { return $global:__ProjectTasksEnvironment.BuildDebugDir }
                "BuildReleaseDir" { return $global:__ProjectTasksEnvironment.BuildReleaseDir }
                default           { throw "Unknown property" }
            }
        }
        
        . (Join-Path $PSScriptRoot ".." ".tasks" "cmdlets" "Get-ProjectEnvironmentPath.ps1")
    }

    Context "PathFromString parameter set" {
        It "returns correct path with only Path" {
            $result = Get-ProjectEnvironmentPath -Path "src"
            $result | Should -Be (Join-Path $env:TEMP "ProjectRoot" "src")
        }

        It "returns correct path with Path and SubPaths" {
            $result = Get-ProjectEnvironmentPath -Path "src" -SubPaths "module", "file.ps1"
            $result | Should -Be (Join-Path $env:TEMP "ProjectRoot" "src" "module" "file.ps1")
        }

        It "throws if Path is null or empty" {
            { Get-ProjectEnvironmentPath -Path "" } | Should -Throw
        }
    }

    Context "PathFromEnvironmentProperty parameter set" {
        It "returns correct path for ProjectRoot" {
            $result = Get-ProjectEnvironmentPath -PathFromEnvironmentProperty "ProjectRoot"
            $result | Should -Be (Join-Path $env:TEMP "ProjectRoot")
        }

        It "returns correct path for BuildDebugDir with subpaths as named parameters" {
            $result = Get-ProjectEnvironmentPath -PathFromEnvironmentProperty "BuildDebugDir" -EnvironmentSubPaths "bin", "test"
            $result | Should -Be (Join-Path $env:TEMP "ProjectRoot" "build" "debug" "bin" "test")
        }

        It "returns correct path for BuildDebugDir with subpaths as positional parameters" {
            $result = Get-ProjectEnvironmentPath -PathFromEnvironmentProperty "BuildDebugDir" "bin" "test"
            $result | Should -Be (Join-Path $env:TEMP "ProjectRoot" "build" "debug" "bin" "test")
        }

        It "throws if ProjectRoot is not set" {
            $oldEnv = $global:__ProjectTasksEnvironment
            $global:__ProjectTasksEnvironment = @{}
            try {
                { Get-ProjectEnvironmentPath -Path "src" } | Should -Throw
            } finally {
                $global:__ProjectTasksEnvironment = $oldEnv
            }
        }
    }
}