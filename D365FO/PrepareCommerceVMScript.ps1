
<#
.SYNOPSIS
    Prepara una VM de Commerce para desarrollo con D365FO
.DESCRIPTION
    Este script clona repositorios de GitHub, crea enlaces simbólicos y configura el entorno de desarrollo
.EXAMPLE
    .\PrepareCommerceVMScript.ps1
#>

. ".\CommonFunctions.ps1"

Write-LogMessage "Iniciando preparación de VM de Commerce para D365FO" -Level Info

# Configuración de repositorios
$repositories = @(
    [PSCustomObject]@{
        repositoryUrl = "https://github.com/JonatanTorino/DevAxCmmUtils"
        localPath     = "K:\Repos\GitHub.JonatanTorino\DevAxCmmUtils"
        models        = @(
            [PSCustomObject]@{modelName = "DevAxCmmUtils"; metadataPath = "K:\Repos\GitHub.JonatanTorino\DevAxCmmUtils\DevAxCmmUtils" }
        )
    },
    [PSCustomObject]@{
        repositoryUrl = "https://github.com/JonatanTorino/DevAxRefreshData"
        localPath     = "K:\Repos\GitHub.JonatanTorino\DevAxRefreshData"
        models        = @(
            [PSCustomObject]@{modelName = "DevAxRefreshData"; metadataPath = "K:\Repos\GitHub.JonatanTorino\DevAxRefreshData\DevAxRefreshData" }
        )
    },
    [PSCustomObject]@{
        repositoryUrl = "https://github.com/arganollc/aotbrowser"
        localPath     = "K:\Repos\GitHub.JonatanTorino\AOTBrowser"
        models        = @(
            [PSCustomObject]@{modelName = "AOTBrowser"; metadataPath = "K:\Repos\GitHub.JonatanTorino\AOTBrowser\Metadata\AOTBrowser" }
        )
    },
    [PSCustomObject]@{
        repositoryUrl = "https://github.com/TrudAX/XppTools"
        localPath     = "K:\Repos\GitHub.JonatanTorino\XppTools"
        models        = @(
            [PSCustomObject]@{modelName = "DEVCommon"; metadataPath = "K:\Repos\GitHub.JonatanTorino\XppTools\DEVCommon" },
            [PSCustomObject]@{modelName = "DEVTools"; metadataPath = "K:\Repos\GitHub.JonatanTorino\XppTools\DEVTools" }
            # [PSCustomObject]@{modelName = "DEVTutorial"; metadataPath = "K:\Repos\GitHub.JonatanTorino\XppTools\DEVTutorial"}
        )
    },
    [PSCustomObject]@{
        repositoryUrl = "https://github.com/ameyer505/D365FOAdminToolkit"
        localPath     = "K:\Repos\GitHub.JonatanTorino\D365FOAdminToolkit"
        models        = @(
            [PSCustomObject]@{modelName = "D365FOAdminToolkit"; metadataPath = "K:\Repos\GitHub.JonatanTorino\D365FOAdminToolkit\Metadata\D365FOAdminToolkit" },
            [PSCustomObject]@{modelName = "D365FOAdminToolkitTest"; metadataPath = "K:\Repos\GitHub.JonatanTorino\D365FOAdminToolkit\Metadata\D365FOAdminToolkitTests" }
        )
    },
    [PSCustomObject]@{
        repositoryUrl = "https://github.com/JonatanTorino/MyPowerShellScripts"
        localPath     = "K:\Repos\GitHub.JonatanTorino\MyPowerShellScripts"
        models        = @()
    },
    [PSCustomObject]@{
        repositoryUrl = "https://github.com/JonatanTorino/CommerceStoreScaleUnitSetupInstaller"
        localPath     = "K:\Repos\GitHub.JonatanTorino\CommerceStoreScaleUnitSetupInstaller"
        models        = @()
    },
    [PSCustomObject]@{
        repositoryUrl = "https://github.com/JonatanTorino/CodeSnippets"
        localPath     = "K:\Repos\GitHub.JonatanTorino\CodeSnippets"
        models        = @()
    }
)

# Importar módulo d365fo.tools
Write-LogMessage "Importando módulo d365fo.tools" -Level Info
Import-Module d365fo.tools

# Tarea 1: Clonar repositorios
Write-LogMessage "Clonando repositorios..." -Level Info
foreach ($repo in $repositories) {
    try {
        Write-LogMessage "Clonando: $($repo.repositoryUrl)" -Level Info
        $process = Start-Process -FilePath "git" -ArgumentList "clone", $repo.repositoryUrl, $repo.localPath -NoNewWindow -Wait -PassThru
        if ($process.ExitCode -ne 0) {
            Write-LogMessage "Error al clonar $($repo.repositoryUrl)" -Level Warning
        } else {
            Write-LogMessage "Repositorio clonado exitosamente" -Level Success
        }
    }
    catch {
        Write-LogMessage "Error al clonar $($repo.repositoryUrl): $($_.Exception.Message)" -Level Error
    }
}

# Detener servicios de D365FO
Write-LogMessage "Deteniendo todos los servicios de D365FO" -Level Info
Stop-D365Environment

# Tarea 2: Crear enlaces simbólicos
$models = @()
$packagesLocalDirectory = "K:\AosService\PackagesLocalDirectory"

Write-LogMessage "Creando enlaces simbólicos para modelos..." -Level Info
foreach ($repo in $repositories) {
    foreach ($model in $repo.models) {
        $targetPath = $model.metadataPath
        $linkPath = Join-Path $packagesLocalDirectory -ChildPath $model.modelName

        try {
            Write-LogMessage "Creando enlace simbólico para $($model.modelName)" -Level Info

            # Remover directorio existente si existe
            if (Test-Path $linkPath) {
                Remove-Item -Path $linkPath -Recurse -Force
            }

            # Crear enlace simbólico
            New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath
            Write-LogMessage "Enlace simbólico creado: $linkPath -> $targetPath" -Level Success

            $models += $model.modelName
        }
        catch {
            Write-LogMessage "Error creando enlace simbólico para $($model.modelName): $($_.Exception.Message)" -Level Error
        }
    }
}

# Tarea 3: Compilar modelos (comentado por defecto)
Write-LogMessage "Compilación de modelos (deshabilitada por defecto)" -Level Info
foreach ($modelItem in $models) {
    Write-LogMessage "Compilación del modelo: $modelItem (comentada)" -Level Info
    # Invoke-D365ProcessModule -Module $modelItem -ExecuteCompile
}

# Iniciar servicios de D365FO
Write-LogMessage "Iniciando servicios de D365FO" -Level Info
Write-LogMessage "Iniciando servicio AOS..." -Level Info
Start-D365EnvironmentV2 -Aos

Write-LogMessage "Iniciando servicio Batch..." -Level Info
Start-D365EnvironmentV2 -Batch

Write-LogMessage "Preparación de VM de Commerce completada" -Level Success
