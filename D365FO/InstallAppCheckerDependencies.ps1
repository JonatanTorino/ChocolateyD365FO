<#
.SYNOPSIS
    Instala las dependencias necesarias para App Checker
.DESCRIPTION
    Este script instala JDK y BaseX que son requeridos para App Checker de Dynamics 365 FO
.EXAMPLE
    .\InstallAppCheckerDependencies.ps1
#>

. ".\CommonFunctions.ps1"

Write-LogMessage "Iniciando instalación de dependencias para App Checker" -Level Info

$downloadsPath = "$Env:USERPROFILE\Downloads"

# Definir las dependencias a instalar
$dependencies = @(
    @{
        Name = "JDK 25"
        FileName = 'jdk-25_windows-x64_bin.msi'
        Url = 'https://download.oracle.com/java/25/latest/jdk-25_windows-x64_bin.msi'
        InstallArgs = '/quiet'
    },
    @{
        Name = "BaseX 12.0"
        FileName = 'BaseX120.exe'
        Url = 'https://files.basex.org/releases/12.0/BaseX120.exe'
        InstallArgs = '/quiet'
    }
)

foreach ($dep in $dependencies) {
    Write-LogMessage "Instalando $($dep.Name)..." -Level Info

    try {
        # Construir la ruta completa del archivo
        $fullPath = Join-Path -Path $downloadsPath -ChildPath $dep.FileName

        # Descargar el archivo
        Write-LogMessage "Descargando $($dep.Name)..." -Level Info
        Invoke-WebRequestWithRetry -Uri $dep.Url -OutFile $fullPath

        # Instalar el software
        Write-LogMessage "Instalando $($dep.Name)..." -Level Info
        Start-ProcessAndWait -FilePath $fullPath -ArgumentList $dep.InstallArgs

        Write-LogMessage "$($dep.Name) instalado exitosamente" -Level Success
    }
    catch {
        Write-LogMessage "Error al instalar $($dep.Name): $($_.Exception.Message)" -Level Error
        throw
    }
}

Write-LogMessage "Instalación de dependencias para App Checker completada" -Level Success
