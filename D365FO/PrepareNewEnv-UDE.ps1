<#
.SYNOPSIS
    Executes user-level tasks first, then elevates for admin tasks to prepare the environment.

.DESCRIPTION
    This script first executes functions that do not require administrator privileges.
    Then, it elevates to administrator privileges to execute the remaining functions.

.NOTES
    File: PrepareNewEnv-UDE.ps1
    Version: 1.0
    Author: Gemini Code Assist
    Date: 2024-05-21
#>

$commonScriptPath = Join-Path $PSScriptRoot "PrepareNewEnv-CommonEnvironment.ps1"

# --- Tareas de Nivel de Usuario ---
Write-Host "Ejecutando tareas de nivel de usuario..." -ForegroundColor Green
# Carga las funciones en la sesión actual y las ejecuta como el usuario actual.
. $commonScriptPath
Load-SupportScripts
Install-VSCodeExtensions

# --- Tareas de Nivel de Administrador ---
Write-Host "Iniciando tareas que requieren elevación de privilegios..." -ForegroundColor Green
$adminFunctions = @(
    'Install-MainTools',
    'Install-ChocolateyAndApps',
    'Install-VSExtensionsD365FO',
    'Install-VSMarketplaceExtensions',
    'Install-AdditionalTools'
)

# Prepara los argumentos para el nuevo proceso de PowerShell
$arguments = @(
    '-NoProfile',
    '-ExecutionPolicy', 'Bypass',
    '-File', $commonScriptPath,
    '-RunFunction', ($adminFunctions -join ',') # Pasa los nombres como un string separado por comas
)

# Inicia el proceso con elevación y espera a que termine
try {
    $process = Start-Process powershell.exe -ArgumentList $arguments -Verb RunAs -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        Write-Error "El script elevado finalizó con errores. Código de salida: $($process.ExitCode)"
    } else {
        Write-Host "Las tareas de administrador se completaron exitosamente." -ForegroundColor Green
    }
}
catch {
    Write-Error "No se pudo iniciar el proceso elevado. ¿Canceló el usuario el UAC? Error: $_"
}

Write-Host "Proceso de preparación de UDE completado."