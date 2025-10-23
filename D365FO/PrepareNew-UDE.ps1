

<#
.SYNOPSIS
    Prepara un nuevo entorno UDE (Unified Development Environment) para D365FO
.DESCRIPTION
    Este script configura un entorno UDE con todas las herramientas necesarias para desarrollo con D365FO
.EXAMPLE
    .\PrepareNew-UDE.ps1
#>

. ".\CommonFunctions.ps1"

Write-LogMessage "Iniciando preparación de nuevo entorno UDE para D365FO" -Level Info

# Ejecutar script de entorno común
Write-LogMessage "Ejecutando preparación de entorno común..." -Level Info
try {
    & ".\PrepareNew-CommonEnvironment.ps1"
    Write-LogMessage "Entorno común preparado exitosamente" -Level Success
} catch {
    Write-LogMessage "Error en preparación de entorno común: $($_.Exception.Message)" -Level Error
    throw
}

Write-LogMessage "Preparación del entorno UDE completada" -Level Success
