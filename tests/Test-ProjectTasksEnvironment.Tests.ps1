# Requires -Module Pester
# Requires -Version 5.1

Describe "Test-ProjectTasksEnvironment" {

    BeforeEach {
        # Backup and clear global variable
        if ($global:__ProjectTasksEnvironment) {
            $script:backupEnv = $global:__ProjectTasksEnvironment
        } else {
            $script:backupEnv = $null
        }
        Remove-Variable -Name __ProjectTasksEnvironment -Scope Global -ErrorAction SilentlyContinue
        
        . (Join-Path $PSScriptRoot ".." ".tasks" "cmdlets" "Test-ProjectTasksEnvironment.ps1")
    }

    AfterEach {
        # Restore global variable
        if ($script:backupEnv) {
            $global:__ProjectTasksEnvironment = $script:backupEnv
        } else {
            Remove-Variable -Name __ProjectTasksEnvironment -Scope Global -ErrorAction SilentlyContinue
        }
    }

    It "Throws if __ProjectTasksEnvironment is null" {
        $global:__ProjectTasksEnvironment = $null
        { Test-ProjectTasksEnvironment } | Should -Throw -ExpectedMessage "*Project tasks environment is not initialized*"
    }

    It "Throws if __ProjectTasksEnvironment is not set" {
        { Test-ProjectTasksEnvironment } | Should -Throw -ExpectedMessage "*Project tasks environment is not initialized*"
    }

    It "Throws if RequiredDirectories is missing" {
        $global:__ProjectTasksEnvironment = @{}
        { Test-ProjectTasksEnvironment } | Should -Throw -ExpectedMessage "*Project tasks environment is not initialized*"
    }

    It "Throws if a required directory does not exist" {
        $global:__ProjectTasksEnvironment = @{
            RequiredDirectories = @(
                (Join-Path $env:TEMP 'FakeDir1'),
                (Join-Path $env:TEMP 'FakeDir2')
            )
            IsInitialized = $true
        }
        # Ensure directories do not exist
        Remove-Item -Path (Join-Path $env:TEMP 'FakeDir1'), (Join-Path $env:TEMP 'FakeDir2') -Recurse -Force -ErrorAction SilentlyContinue

        $errors = $null
        { Test-ProjectTasksEnvironment -ErrorAction SilentlyContinue } | Should -Throw -ExpectedMessage "Project tasks environment was de-initialized during validation."
        
        $errors = $Error | Where-Object { $_.CategoryInfo.Category -eq 'NotSpecified' -and $_.Exception.Message -like "Required directory '*FakeDir1' does not exist. Please check your project structure." }
        $errors | Should -Not -BeNullOrEmpty
        $errors = $Error | Where-Object { $_.CategoryInfo.Category -eq 'NotSpecified' -and $_.Exception.Message -like "Required directory '*FakeDir2' does not exist. Please check your project structure." }
        $errors | Should -Not -BeNullOrEmpty

        $global:__ProjectTasksEnvironment.IsInitialized | Should -Be $false
    }

    It "Returns true if all required directories exist and environment is initialized" {
        $tempDir1 = New-Item -ItemType Directory -Path (Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid()))
        $tempDir2 = New-Item -ItemType Directory -Path (Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid()))
        $global:__ProjectTasksEnvironment = @{
            RequiredDirectories = @($tempDir1.FullName, $tempDir2.FullName)
            IsInitialized = $true
        }
        try {
            Test-ProjectTasksEnvironment | Should -Be $true
        } finally {
            Remove-Item -Path $tempDir1.FullName, $tempDir2.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It "Throws if IsInitialized is false" {
        $tempDir = New-Item -ItemType Directory -Path (Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid()))
        $global:__ProjectTasksEnvironment = @{
            RequiredDirectories = @($tempDir.FullName)
            IsInitialized = $false
        }
        try {
            { Test-ProjectTasksEnvironment } | Should -Throw -ExpectedMessage "*Project tasks environment is not initialized*"
        } finally {
            Remove-Item -Path $tempDir.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}