<#
.SYNOPSIS
    Instala módulos de PowerShell requeridos para D365FO
.DESCRIPTION
    Este script instala manualmente módulos de PowerShell desde PowerShell Gallery
    cuando la instalación normal falla debido a restricciones de red o políticas
.EXAMPLE
    .\installModulesD365FO.ps1
#>

. ".\CommonFunctions.ps1"

Write-LogMessage "Iniciando instalación de módulos de PowerShell para D365FO" -Level Info

# Lista de módulos a instalar manualmente
$modules = @(
    "Az.Accounts",
    "Az.Storage",
    "AzureAD",
    "d365fo.tools",
    "Microsoft.PowerShell.Operation.Validation",
    "PackageManagement",
    "Pester",
    "PowerShellGet",
    "PSFramework",
    "PSOAuthHelper",
    "PSReadline",
    "SqlServer"
)

# Configuración de rutas
$tempDir = "$env:TEMP\PSModulesDownload"
$installPath = "C:\Program Files\WindowsPowerShell\Modules"

# Crear directorio temporal
Test-PathAndCreate -Path $tempDir

$installedCount = 0
$failedCount = 0

foreach ($module in $modules) {
    Write-LogMessage "Procesando módulo: $module" -Level Info

    try {
        # Buscar la última versión del módulo
        $searchUrl = "https://www.powershellgallery.com/api/v2/Packages?`$filter=Id%20eq%20'$module'%20and%20IsLatestVersion"
        $xmlFile = "$tempDir\$module.xml"

        # Usar curl.exe con user-agent para evitar bloqueos
        $curlArgs = "-s", "-A", $script:DefaultUserAgent, $searchUrl, "-o", $xmlFile
        & curl.exe @curlArgs

        if (-not (Test-Path $xmlFile)) {
            Write-LogMessage "No se pudo obtener la información del módulo $module" -Level Warning
            $failedCount++
            continue
        }

        [xml]$feed = Get-Content $xmlFile
        $entries = $feed.feed.entry

        if (-not $entries) {
            Write-LogMessage "No se encontraron versiones para $module" -Level Warning
            $failedCount++
            continue
        }

        # Obtener la última versión
        $lastEntry = $entries[-1]
        $version = $lastEntry.properties.Version
        Write-LogMessage "Versión encontrada: $version" -Level Info

        # Descargar .nupkg
        $nupkgUrl = "https://www.powershellgallery.com/api/v2/package/$module/$version"
        $nupkgPath = "$tempDir\$module.$version.nupkg"

        $curlArgs = "-L", "-A", $script:DefaultUserAgent, "-o", $nupkgPath, $nupkgUrl
        & curl.exe @curlArgs

        if (-not (Test-Path $nupkgPath)) {
            Write-LogMessage "Error al descargar $module" -Level Warning
            $failedCount++
            continue
        }

        # Cambiar extensión a .zip para expansión
        $zipPath = "$tempDir\$module.$version.zip"
        Rename-Item -Path $nupkgPath -NewName "$module.$version.zip"

        # Crear carpeta de instalación
        $destPath = Join-Path -Path $installPath -ChildPath "$module\$version"
        Test-PathAndCreate -Path $destPath

        # Expandir archivo ZIP
        Write-LogMessage "Expandiendo módulo $module..." -Level Info
        Expand-Archive -Path $zipPath -DestinationPath $destPath -Force

        # Mover contenido si está en subcarpetas /tools o /content
        $psd1 = Get-ChildItem -Path $destPath -Filter *.psd1 -Recurse | Select-Object -First 1
        if (-not $psd1) {
            $toolsPath = Join-Path $destPath "tools"
            if (Test-Path $toolsPath) {
                Move-Item -Path "$toolsPath\*" -Destination $destPath -Force
                Remove-Item -Path $toolsPath -Recurse -Force
            }

            $contentPath = Join-Path $destPath "content"
            if (Test-Path $contentPath) {
                Move-Item -Path "$contentPath\*" -Destination $destPath -Force
                Remove-Item -Path $contentPath -Recurse -Force
            }
        }

        Write-LogMessage "✅ $module $version instalado en $destPath" -Level Success
        $installedCount++
    }
    catch {
        Write-LogMessage "Error procesando módulo $module`: $($_.Exception.Message)" -Level Error
        $failedCount++
    }
}

# Limpieza de archivos temporales
Write-LogMessage "Limpiando archivos temporales..." -Level Info
Remove-Item -Recurse -Force $tempDir

# Resumen final
Write-LogMessage "`nResumen de instalación:" -Level Info
Write-LogMessage "✅ Módulos instalados: $installedCount" -Level Success
if ($failedCount -gt 0) {
    Write-LogMessage "❌ Módulos fallidos: $failedCount" -Level Warning
}

Write-LogMessage "`n🎉 Instalación de módulos completada." -Level Success
