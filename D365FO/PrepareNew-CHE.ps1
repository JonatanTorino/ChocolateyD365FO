<#
.SYNOPSIS
    Prepara un nuevo entorno CHE (Cloud-Hosted Environment) para D365FO
.DESCRIPTION
    Este script configura un entorno CHE con todas las herramientas necesarias para desarrollo con D365FO
.EXAMPLE
    .\PrepareNew-CHE.ps1
#>

. ".\CommonFunctions.ps1"

Write-LogMessage "Iniciando preparación de nuevo entorno CHE para D365FO" -Level Info

#region Instalar herramientas principales
Write-LogMessage "Instalando herramientas principales..." -Level Info

try {
    Install-Module -Name SqlServer -AllowClobber
    Write-LogMessage "Módulo SqlServer instalado" -Level Success
} catch {
    Write-LogMessage "Error instalando SqlServer: $($_.Exception.Message)" -Level Error
}

try {
    Install-Module -Name d365fo.tools -AllowClobber
    Write-LogMessage "Módulo d365fo.tools instalado" -Level Success
} catch {
    Write-LogMessage "Error instalando d365fo.tools: $($_.Exception.Message)" -Level Error
}

try {
    Add-D365WindowsDefenderRules
    Write-LogMessage "Reglas de Windows Defender agregadas" -Level Success
} catch {
    Write-LogMessage "Error agregando reglas de Windows Defender: $($_.Exception.Message)" -Level Warning
}

try {
    Invoke-D365InstallAzCopy
    Write-LogMessage "AzCopy instalado" -Level Success
} catch {
    Write-LogMessage "Error instalando AzCopy: $($_.Exception.Message)" -Level Warning
}

try {
    Invoke-D365InstallSqlPackage
    Write-LogMessage "SqlPackage instalado" -Level Success
} catch {
    Write-LogMessage "Error instalando SqlPackage: $($_.Exception.Message)" -Level Warning
}
#endregion

#region Backup de configuración
Write-LogMessage "Realizando backup de configuraciones..." -Level Info

try {
    Backup-D365WebConfig
    Write-LogMessage "Backup de web.config completado" -Level Success
} catch {
    Write-LogMessage "Error en backup de web.config: $($_.Exception.Message)" -Level Warning
}

try {
    Backup-D365DevConfig
    Write-LogMessage "Backup de dev.config completado" -Level Success
} catch {
    Write-LogMessage "Error en backup de dev.config: $($_.Exception.Message)" -Level Warning
}
#endregion

#region Configuración de SQL Server
Write-LogMessage "Configurando SQL Server..." -Level Info

try {
    Import-Module SqlServer
    $SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server "."

    # Limitar memoria máxima del servidor a 5000 MB
    $SqlServer.Configuration.MaxServerMemory.ConfigValue = 5000
    Write-LogMessage "Memoria máxima del servidor configurada a 5000 MB" -Level Info

    # Habilitar compresión de backups
    $SqlServer.Configuration.DefaultBackupCompression.ConfigValue = 1
    Write-LogMessage "Compresión de backups habilitada" -Level Info

    # Guardar cambios
    $SqlServer.Configuration.Alter()
    Write-LogMessage "Configuración de SQL Server guardada" -Level Success
} catch {
    Write-LogMessage "Error configurando SQL Server: $($_.Exception.Message)" -Level Error
}
#endregion

#region Deshabilitar servicios innecesarios
Write-LogMessage "Configurando servicios..." -Level Info

try {
    Write-LogMessage "Configurando página de inicio del navegador web al entorno local" -Level Info
    Get-D365Url | Set-D365StartPage
    Write-LogMessage "Página de inicio configurada" -Level Success
} catch {
    Write-LogMessage "Error configurando página de inicio: $($_.Exception.Message)" -Level Warning
}

try {
    Write-LogMessage "Configurando Management Reporter para inicio manual" -Level Info
    Stop-D365Environment -FinancialReporter
    Get-D365Environment -FinancialReporter | Set-Service -StartupType Disabled
    Stop-Service -Name MR2012ProcessService -Force
    Set-Service -Name MR2012ProcessService -StartupType Disabled
    Write-LogMessage "Management Reporter configurado para inicio manual" -Level Success
} catch {
    Write-LogMessage "Error configurando Management Reporter: $($_.Exception.Message)" -Level Warning
}

try {
    Write-LogMessage "Configurando DMF para inicio manual" -Level Info
    Stop-D365Environment -DMF
    Get-D365Environment -DMF | Set-Service -StartupType Disabled
    Write-LogMessage "DMF configurado para inicio manual" -Level Success
} catch {
    Write-LogMessage "Error configurando DMF: $($_.Exception.Message)" -Level Warning
}

try {
    Write-LogMessage "Agregando reglas de Windows Defender para acelerar compilación" -Level Info
    Add-D365WindowsDefenderRules -Silent
    Write-LogMessage "Reglas de Windows Defender agregadas" -Level Success
} catch {
    Write-LogMessage "Error agregando reglas de Windows Defender: $($_.Exception.Message)" -Level Warning
}
#endregion

#region Cambiar de IIS Express a IIS
Write-LogMessage "Verificando configuración de RuntimeHostType..." -Level Info

$devConfigPath = "$env:servicedrive\AOSService\PackagesLocalDirectory\bin\DynamicsDevConfig.xml"
if (Test-Path $devConfigPath) {
    try {
        [xml]$xmlDoc = Get-Content $devConfigPath
        if ($xmlDoc.DynamicsDevConfig.RuntimeHostType -ne "IIS") {
            Write-LogMessage "Cambiando RuntimeHostType a IIS en DynamicsDevConfig.xml" -Level Info
            $xmlDoc.DynamicsDevConfig.RuntimeHostType = "IIS"
            $xmlDoc.Save($devConfigPath)
            Write-LogMessage "RuntimeHostType cambiado a IIS exitosamente" -Level Success
        } else {
            Write-LogMessage "RuntimeHostType ya está configurado como IIS" -Level Info
        }
    } catch {
        Write-LogMessage "Error cambiando RuntimeHostType: $($_.Exception.Message)" -Level Error
    }
} else {
    Write-LogMessage "Drive de AOSService no encontrado. No se pudo cambiar RuntimeHostType a IIS" -Level Warning
}
#endregion

# Habilitar preload de IIS
try {
    Write-LogMessage "Habilitando IIS preload..." -Level Info
    Enable-D365IISPreload
    Write-LogMessage "IIS preload habilitado" -Level Success
} catch {
    Write-LogMessage "Error habilitando IIS preload: $($_.Exception.Message)" -Level Warning
}

# region Ejecutar script de entorno común
Write-LogMessage "Ejecutando preparación de entorno común..." -Level Info
try {
    & ".\PrepareNew-CommonEnvironment.ps1"
    Write-LogMessage "Entorno común preparado exitosamente" -Level Success
} catch {
    Write-LogMessage "Error en preparación de entorno común: $($_.Exception.Message)" -Level Error
}
#endregion

#region Herramientas adicionales
Write-LogMessage "Instalando herramientas adicionales..." -Level Info

try {
    . ".\DownloadFromGitHub.ps1"

    # Nota: Estas aplicaciones estaban comentadas en *Packages.config porque no descargan correctamente
    $pathAxxon = "C:\Axxon"
    Download-ReleaseFromGitHub -repo "kimmknight/remoteapptool" -path "$pathAxxon\Tools" `
        -filesToDownload @("RemoteApp.Tool.6100.msi") `
        -filesToExecute @("RemoteApp.Tool.6100.msi")

    Write-LogMessage "Herramientas adicionales instaladas" -Level Success
} catch {
    Write-LogMessage "Error instalando herramientas adicionales: $($_.Exception.Message)" -Level Warning
}
#endregion

Write-LogMessage "Preparación del entorno CHE completada" -Level Success
