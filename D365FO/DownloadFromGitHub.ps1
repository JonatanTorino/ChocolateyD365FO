<#
.SYNOPSIS
    Descarga archivos de la última release de un repositorio de GitHub
.DESCRIPTION
    Esta función descarga archivos específicos o todos los archivos de la última release de un repositorio de GitHub
.PARAMETER Repo
    Nombre del repositorio en formato usuario/repo
.PARAMETER Path
    Ruta de destino para los archivos descargados
.PARAMETER FilesToDownload
    Array de nombres de archivos específicos a descargar (opcional)
.PARAMETER FilesToExecute
    Array de nombres de archivos a ejecutar después de la descarga (opcional)
.EXAMPLE
    Download-ReleaseFromGitHub -Repo "usuario/repo" -Path "C:\Downloads"
.EXAMPLE
    Download-ReleaseFromGitHub -Repo "usuario/repo" -Path "C:\Downloads" -FilesToDownload @("archivo1.zip", "archivo2.exe")
#>

. ".\CommonFunctions.ps1"

function Download-ReleaseFromGitHub {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Repo,

        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [string[]]$FilesToDownload,

        [Parameter(Mandatory = $false)]
        [string[]]$FilesToExecute
    )

    Write-LogMessage "Iniciando descarga desde GitHub: $Repo" -Level Info

    # Crear directorio de destino si no existe
    Test-PathAndCreate -Path $Path

    # Cambiar al directorio de destino
    Push-Location $Path

    try {
        # Obtener información de la última release
        $release = Get-LatestReleaseFromGitHub -Repo $Repo
        $tag = $release.tag_name

        Write-LogMessage "Descargando archivos de la release $tag" -Level Info

        # Descargar archivos
        if ($null -eq $FilesToDownload -or $FilesToDownload.Count -eq 0) {
            # Descargar todos los archivos de la release
            foreach ($asset in $release.assets) {
                $downloadUrl = $asset.browser_download_url
                $fileName = $asset.name

                Write-LogMessage "Descargando: $fileName" -Level Info
                Invoke-WebRequestWithRetry -Uri $downloadUrl -OutFile $fileName
                Unblock-File $fileName
            }
        } else {
            # Descargar archivos específicos
            foreach ($file in $FilesToDownload) {
                $downloadUrl = "https://github.com/$Repo/releases/download/$tag/$file"

                Write-LogMessage "Descargando: $file" -Level Info
                Invoke-WebRequestWithRetry -Uri $downloadUrl -OutFile $file
                Unblock-File $file
            }
        }

        # Ejecutar archivos si se especificaron
        if ($FilesToExecute -and $FilesToExecute.Count -gt 0) {
            foreach ($file in $FilesToExecute) {
                $filePath = Join-Path $Path $file
                if (Test-Path $filePath) {
                    Write-LogMessage "Ejecutando: $file" -Level Info
                    Start-ProcessAndWait -FilePath $filePath
                } else {
                    Write-LogMessage "Archivo a ejecutar no encontrado: $filePath" -Level Warning
                }
            }
        }

        Write-LogMessage "Descarga completada exitosamente desde $Repo" -Level Success
    }
    catch {
        Write-LogMessage "Error durante la descarga: $($_.Exception.Message)" -Level Error
        throw
    }
    finally {
        Pop-Location
    }
}

# Alias para mantener compatibilidad
Set-Alias -Name downloadReleaseFromGitHub -Value Download-ReleaseFromGitHub