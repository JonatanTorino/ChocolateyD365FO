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

# Carpeta temporal para descargar los .nupkg/.zip
$tempDir = "$env:TEMP\PSModulesDownload"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# Directorio de instalación
$installPath = "C:\Program Files\WindowsPowerShell\Modules"

# User-Agent para evitar bloqueos por parte de PowerShell Gallery
$userAgent = "Mozilla/5.0"

foreach ($module in $modules) {
    Write-Host "Procesando módulo: $module" -ForegroundColor Cyan

    # Buscar la última versión del módulo
    $searchUrl = "https://www.powershellgallery.com/api/v2/Packages?`$filter=Id%20eq%20'$module'%20and%20IsLatestVersion"
    $xmlFile = "$tempDir\$module.xml"

    & curl.exe -s -A $userAgent $searchUrl -o $xmlFile

    if (-not (Test-Path $xmlFile)) {
        Write-Warning "No se pudo obtener la información del módulo $module"
        continue
    }

    [xml]$feed = Get-Content $xmlFile
    $entries = $feed.feed.entry

    if (-not $entries) {
        Write-Warning "No se encontraron versiones para $module"
        continue
    }

    # Obtener la última versión
    $lastEntry = $entries[-1]
    $version = $lastEntry.properties.Version
    Write-Host "Versión encontrada: $version"

    # Descargar .nupkg
    $nupkgUrl = "https://www.powershellgallery.com/api/v2/package/$module/$version"
    $nupkgPath = "$tempDir\$module.$version.nupkg"
    & curl.exe -L -A $userAgent -o $nupkgPath $nupkgUrl

    if (-not (Test-Path $nupkgPath)) {
        Write-Warning "Error al descargar $module"
        continue
    }

    # Cambiar extensión a .zip
    $zipPath = "$tempDir\$module.$version.zip"
    Rename-Item -Path $nupkgPath -NewName "$module.$version.zip"

    # Crear carpeta de instalación
    $destPath = Join-Path -Path $installPath -ChildPath "$module\$version"
    New-Item -ItemType Directory -Path $destPath -Force | Out-Null

    # Expandir archivo ZIP
    Expand-Archive -Path $zipPath -DestinationPath $destPath -Force

    # Mover contenido si está en /tools o /content
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

    Write-Host "✅ $module $version instalado en $destPath" -ForegroundColor Green
}

# Limpieza de temporales
Remove-Item -Recurse -Force $tempDir

Write-Host "`n🎉 Todos los módulos fueron procesados correctamente." -ForegroundColor Cyan
