<#
.SYNOPSIS
    Instala una extensión de Visual Studio desde el Marketplace
.DESCRIPTION
    Esta función descarga e instala una extensión de Visual Studio desde el Marketplace oficial
.PARAMETER Version
    Versión de Visual Studio (2019 o 2022)
.PARAMETER PackageName
    Nombre del paquete de la extensión en el Marketplace
.EXAMPLE
    Invoke-VSInstallExtension -Version 2022 -PackageName 'MadsKristensen.TrailingWhitespace64'
#>

. ".\CommonFunctions.ps1"

function Invoke-VSInstallExtension {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet('2019', '2022')]
        [string]$Version,

        [Parameter(Mandatory = $true)]
        [string]$PackageName
    )

    Write-LogMessage "Iniciando instalación de extensión VS $PackageName para VS $Version" -Level Info

    $ErrorActionPreference = "Stop"

    # Configuración de URLs y rutas
    $baseProtocol = "https:"
    $baseHostName = "marketplace.visualstudio.com"
    $uri = "$($baseProtocol)//$($baseHostName)/items?itemName=$($PackageName)"
    $vsixLocation = "$($env:Temp)\$([guid]::NewGuid()).vsix"

    # Determinar directorio de instalación de VS
    switch ($Version) {
        '2019' {
            $vsInstallDir = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\resources\app\ServiceHub\Services\Microsoft.VisualStudio.Setup.Service"
        }
        '2022' {
            $vsInstallDir = "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\"
        }
    }

    # Verificar que VS esté instalado
    if (!(Test-Path $vsInstallDir)) {
        Write-LogMessage "Visual Studio $Version no encontrado en la ruta esperada: $vsInstallDir" -Level Error
        throw "Visual Studio $Version no está instalado o no se encuentra en la ubicación esperada"
    }

    try {
        Write-LogMessage "Obteniendo información de la extensión desde: $uri" -Level Info
        $html = Invoke-WebRequestWithRetry -Uri $uri

        Write-LogMessage "Descargando extensión: $PackageName" -Level Info
        $anchor = $html.Links |
            Where-Object { $_.class -eq 'install-button-container' } |
            Select-Object -ExpandProperty href -First 1

        if (-not $anchor) {
            Write-LogMessage "No se pudo encontrar el enlace de descarga en la página de extensiones de VS" -Level Error
            throw "Could not find download anchor tag on the Visual Studio Extensions page"
        }

        Write-LogMessage "Enlace de descarga encontrado: $anchor" -Level Info
        $href = "$($baseProtocol)//$($baseHostName)$($anchor)"

        Write-LogMessage "Descargando archivo VSIX..." -Level Info
        Invoke-WebRequestWithRetry -Uri $href -OutFile $vsixLocation

        if (!(Test-Path $vsixLocation)) {
            Write-LogMessage "El archivo VSIX descargado no se pudo localizar" -Level Error
            throw "Downloaded VSIX file could not be located"
        }

        Write-LogMessage "Instalando extensión: $PackageName" -Level Info
        Write-LogMessage "VS Install Dir: $vsInstallDir" -Level Info
        Write-LogMessage "VSIX Location: $vsixLocation" -Level Info

        $installerPath = Join-Path $vsInstallDir "VSIXInstaller.exe"
        Start-ProcessAndWait -FilePath $installerPath -ArgumentList "/q /a $($vsixLocation)"

        Write-LogMessage "Limpiando archivos temporales..." -Level Info
        Remove-Item $vsixLocation -Force -Confirm:$false

        Write-LogMessage "Instalación de $PackageName completada exitosamente" -Level Success
    }
    catch {
        # Limpiar archivo temporal en caso de error
        if (Test-Path $vsixLocation) {
            Remove-Item $vsixLocation -Force -Confirm:$false
        }
        Write-LogMessage "Error durante la instalación: $($_.Exception.Message)" -Level Error
        throw
    }
}