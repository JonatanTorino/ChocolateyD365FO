<#
.SYNOPSIS
    Ensures the script runs with elevated privileges and then executes the common environment setup.

.DESCRIPTION
    This script checks if it is running as an Administrator. If not, it relaunches itself with elevated privileges.
    Once running as an administrator, it invokes the 'PrepareNewEnv-CommonEnvironment.ps1' script to perform the actual environment setup.

.NOTES
    File: PrepareNewEnv-UDE.ps1
    Version: 1.0
    Author: Gemini Code Assist
    Date: 2024-05-21
#>

# Check for administrator privileges
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Administrator privileges are required. Requesting elevation..."
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

Write-Host "Running with administrator privileges. Executing common environment setup..."
. (Join-Path $PSScriptRoot "PrepareNewEnv-CommonEnvironment.ps1")