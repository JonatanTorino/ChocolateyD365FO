<#
.SYNOPSIS
    Funciones comunes para scripts de D365FO
.DESCRIPTION
    Este archivo contiene funciones utilitarias compartidas por todos los scripts de D365FO
#>

# Configuración global
$script:LogColors = @{
    Info    = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error   = "Red"
}

$script:DefaultUserAgent = "Mozilla/5.0"

function Write-LogMessage {
    <#
    .SYNOPSIS
        Escribe un mensaje de log con color consistente
    .PARAMETER Message
        El mensaje a escribir
    .PARAMETER Level
        Nivel del mensaje (Info, Success, Warning, Error)
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Level = "Info"
    )

    $color = $script:LogColors[$Level]
    Write-Host $Message -ForegroundColor $color
}

function Test-PathAndCreate {
    <#
    .SYNOPSIS
        Verifica si una ruta existe y la crea si no
    .PARAMETER Path
        La ruta a verificar/crear
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (!(Test-Path $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
        Write-LogMessage "Directorio creado: $Path" -Level Info
    }
}

function Invoke-WebRequestWithRetry {
    <#
    .SYNOPSIS
        Realiza una petición web con reintentos
    .PARAMETER Uri
        La URI a solicitar
    .PARAMETER OutFile
        Archivo de salida (opcional)
    .PARAMETER MaxRetries
        Número máximo de reintentos
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Uri,

        [Parameter(Mandatory = $false)]
        [string]$OutFile,

        [Parameter(Mandatory = $false)]
        [int]$MaxRetries = 3
    )

    $attempt = 0
    do {
        try {
            $attempt++
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

            if ($OutFile) {
                Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing
            } else {
                return Invoke-WebRequest -Uri $Uri -UseBasicParsing
            }
            break
        }
        catch {
            if ($attempt -eq $MaxRetries) {
                Write-LogMessage "Error al descargar $Uri después de $MaxRetries intentos: $($_.Exception.Message)" -Level Error
                throw
            }
            Write-LogMessage "Intento $attempt fallido, reintentando..." -Level Warning
            Start-Sleep -Seconds 2
        }
    } while ($attempt -lt $MaxRetries)
}

function Start-ProcessAndWait {
    <#
    .SYNOPSIS
        Inicia un proceso y espera a que termine
    .PARAMETER FilePath
        Ruta del ejecutable
    .PARAMETER ArgumentList
        Lista de argumentos
    .PARAMETER WorkingDirectory
        Directorio de trabajo (opcional)
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $false)]
        [string]$ArgumentList,

        [Parameter(Mandatory = $false)]
        [string]$WorkingDirectory
    )

    $startInfo = @{
        FilePath = $FilePath
        Wait = $true
    }

    if ($ArgumentList) {
        $startInfo.ArgumentList = $ArgumentList
    }

    if ($WorkingDirectory) {
        $startInfo.WorkingDirectory = $WorkingDirectory
    }

    Write-LogMessage "Ejecutando: $FilePath $ArgumentList" -Level Info
    Start-Process @startInfo
    Write-LogMessage "Proceso completado: $FilePath" -Level Success
}

function Get-LatestReleaseFromGitHub {
    <#
    .SYNOPSIS
        Obtiene la información de la última release de un repositorio de GitHub
    .PARAMETER Repo
        Nombre del repositorio (usuario/repo)
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Repo
    )

    $releasesUrl = "https://api.github.com/repos/$Repo/releases"
    Write-LogMessage "Obteniendo información de la última release de $Repo" -Level Info

    try {
        $release = Invoke-WebRequestWithRetry -Uri $releasesUrl | ConvertFrom-Json | Select-Object -First 1
        Write-LogMessage "Última release: $($release.tag_name)" -Level Success
        return $release
    }
    catch {
        Write-LogMessage "Error al obtener releases de $Repo" -Level Error
        throw
    }
}