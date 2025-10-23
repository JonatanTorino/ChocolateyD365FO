<#
.SYNOPSIS
    Prepara el entorno común para desarrollo con D365FO
.DESCRIPTION
    Este script instala WinGet, PowerShell, Git y aplicaciones usando Chocolatey
.EXAMPLE
    .\PrepareNew-CommonEnvironment.ps1
#>

. ".\CommonFunctions.ps1"

Write-LogMessage "Iniciando preparación del entorno común para D365FO" -Level Info

#region Instalar WinGet, PowerShell, Git
Write-LogMessage "Instalando WinGet, PowerShell y Git..." -Level Info

$progressPreference = 'silentlyContinue'

try {
    Write-LogMessage "Instalando módulo WinGet desde PSGallery..." -Level Info
    Install-PackageProvider -Name NuGet -Force | Out-Null
    Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null

    Write-LogMessage "Reparando administrador de paquetes WinGet..." -Level Info
    Repair-WinGetPackageManager -AllUsers
    Write-LogMessage "WinGet configurado exitosamente" -Level Success
} catch {
    Write-LogMessage "Error configurando WinGet: $($_.Exception.Message)" -Level Error
}

try {
    Write-LogMessage "Instalando PowerShell..." -Level Info
    winget install --id Microsoft.PowerShell --source winget
    Write-LogMessage "PowerShell instalado exitosamente" -Level Success
} catch {
    Write-LogMessage "Error instalando PowerShell: $($_.Exception.Message)" -Level Warning
}

try {
    Write-LogMessage "Instalando Git..." -Level Info
    winget install --id Git.Git -e --source winget
    Write-LogMessage "Git instalado exitosamente" -Level Success
} catch {
    Write-LogMessage "Error instalando Git: $($_.Exception.Message)" -Level Warning
}
#endregion

#region Instalar aplicaciones usando Chocolatey
Write-LogMessage "Instalando aplicaciones usando Chocolatey..." -Level Info

if (Test-Path -Path "$env:ProgramData\Chocolatey") {
    try {
        Write-LogMessage "Actualizando Chocolatey..." -Level Info
        choco upgrade chocolatey -y

        Write-LogMessage "Actualizando todas las aplicaciones..." -Level Info
        choco upgrade all --ignore-checksums -y
        Write-LogMessage "Aplicaciones actualizadas exitosamente" -Level Success
    } catch {
        Write-LogMessage "Error actualizando aplicaciones con Chocolatey: $($_.Exception.Message)" -Level Warning
    }
} else {
    try {
        Write-LogMessage "Instalando Chocolatey..." -Level Info
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

        Write-LogMessage "Instalando curl..." -Level Info
        choco install curl -y

        Write-LogMessage "Descargando e instalando paquetes predeterminados..." -Level Info
        Invoke-WebRequestWithRetry -Uri "https://raw.githubusercontent.com/JonatanTorino/ChocolateyD365FO/main/DefaultPackages.config" -OutFile "$env:TEMP\DefaultPackages.config"
        choco install "$env:TEMP\DefaultPackages.config" -y

        Write-LogMessage "Descargando e instalando paquetes de Jonas..." -Level Info
        Invoke-WebRequestWithRetry -Uri "https://raw.githubusercontent.com/JonatanTorino/ChocolateyD365FO/main/JonasPackages.config" -OutFile "$env:TEMP\JonasPackages.config"
        choco install "$env:TEMP\JonasPackages.config" -y

        Write-LogMessage "Instalando NuGet Command Line..." -Level Info
        choco install Nuget.CommandLine -y

        Write-LogMessage "Configurando fuente NuGet..." -Level Info
        nuget sources add -Name NugetOrg -Source https://api.nuget.org/v3/index.json

        Write-LogMessage "Chocolatey y aplicaciones instaladas exitosamente" -Level Success
    } catch {
        Write-LogMessage "Error instalando Chocolatey o aplicaciones: $($_.Exception.Message)" -Level Error
    }
}
#endregion

#region Instalar extensiones para Visual Studio D365FO
Write-LogMessage "Instalando extensiones para Visual Studio D365FO..." -Level Info

Push-Location

try {
    . ".\DownloadFromGitHub.ps1"
    . ".\Add-D365FOExtension.ps1"

    $pathAxxon = "C:\Axxon"
    $pathForVSIX = "$pathAxxon\D365foVSExtensions"

    # Definir extensiones a instalar
    $vsExtensions = @(
        @{ Repo = "TrudAX/TRUDUtilsD365"; Path = "$pathForVSIX\TRUDUtilsD365"; ConfigPath = "$pathForVSIX\TRUDUtilsD365" },
        @{ Repo = "HichemDax\D365FONinjaDevTools"; Path = "$pathForVSIX\D365FONinjaDevTools"; ConfigPath = "$pathForVSIX\HichemDax" },
        @{ Repo = "noakesey/d365fo-entity-schema"; Path = "$pathForVSIX\d365fo-entity-schema"; ConfigPath = "$pathForVSIX\d365fo-entity-schema" },
        @{ Repo = "shashisadasivan/SSD365VSAddIn"; Path = "$pathForVSIX\SSD365VSAddIn"; ConfigPath = "$pathForVSIX\SSD365VSAddIn" }
    )

    foreach ($ext in $vsExtensions) {
        try {
            Write-LogMessage "Instalando extensión: $($ext.Repo)" -Level Info
            Download-ReleaseFromGitHub -Repo $ext.Repo -Path $ext.Path
            Add-ExtensionToDynamicsDevConfig -AddInPath $ext.ConfigPath
            Write-LogMessage "Extensión $($ext.Repo) instalada exitosamente" -Level Success
        } catch {
            Write-LogMessage "Error instalando extensión $($ext.Repo): $($_.Exception.Message)" -Level Warning
        }
    }

    Write-LogMessage "Extensiones de Visual Studio D365FO instaladas" -Level Success
} catch {
    Write-LogMessage "Error en instalación de extensiones VS D365FO: $($_.Exception.Message)" -Level Error
} finally {
    Pop-Location
}
#endregion

#region Instalar extensiones de Visual Studio
Write-LogMessage "Instalando extensiones de Visual Studio..." -Level Info

try {
    . ".\Invoke-VSInstallExtension.ps1"

    # Lista de extensiones de VS a instalar
    $vsExtensions = @(
        'AndriesDK.Highlighter',
        'cpmcgrath.Codealignment',
        'EWoodruff.VisualStudioSpellCheckerVS2022andLater',
        'Loop8ack.ExtensionManager2022',
        'MadsKristensen.OpeninVisualStudioCode',
        'MadsKristensen.OutputWindowFilter',
        'MadsKristensen.TrailingWhitespace64',
        'MadsKristensen.WorkflowBrowser',
        'MattLaceyLtd.WarnAboutTODOs',
        'NeVeS.MermaidEditorForVisualStudio',
        'NikolayBalakin.Outputenhancer',
        'SharpDevelopTeam.ILSpy2022',
        'ShemeerNS.FilePathOnFooter',
        'ShemeerNS.QuickSolutionFolderX64',
        'ViktarKarpach.DebugAttachManager2022',
        'VisualStudioPlatformTeam.MatchMargin2022',
        'VisualStudioPlatformTeam.SolutionErrorVisualizer2022',
        'VisualStudioPlatformTeam.TimeStampMargin2022',
        'VisualStudioProductTeam.ProjectSystemTools2022'
    )

    $installedCount = 0
    foreach ($ext in $vsExtensions) {
        try {
            Write-LogMessage "Instalando extensión VS: $ext" -Level Info
            Invoke-VSInstallExtension -Version 2022 -PackageName $ext
            $installedCount++
        } catch {
            Write-LogMessage "Error instalando extensión $ext`: $($_.Exception.Message)" -Level Warning
        }
    }

    Write-LogMessage "Extensiones de Visual Studio instaladas: $installedCount de $($vsExtensions.Count)" -Level Success
} catch {
    Write-LogMessage "Error en instalación de extensiones VS: $($_.Exception.Message)" -Level Error
}
#endregion

#region Instalar extensiones para VSCode
Write-LogMessage "Instalando extensiones para VSCode..." -Level Info

try {
    $vsCodeExtensions = @(
        "alexk.vscode-xpp",
        "mhutchie.git-graph",

        # Estilo
        "alefragnani.bookmarks",
        "johnpapa.vscode-peacock",
        "wayou.vscode-todo-highlight",
        "gruntfuggly.todo-tree",
        "oderwat.indent-rainbow",
        "pkief.material-icon-theme",

        # JSON/XML
        "ZainChen.json",
        "DotJoshJohnson.xml",
        "meezilla.json",

        # PowerShell
        "ms-vscode.PowerShell",
        "tylerleonhardt.vscode-inline-values-powershell",

        # DBML
        "bocovo.dbml-erd-visualizer",
        "rizkykurniawan.dbml-previewer",
        "matt-meyers.vscode-dbml",

        # Base de datos
        "ms-mssql.mssql",
        "piotrgredowski.poor-mans-t-sql-formatter-pg",

        # Markdown
        "yzhang.markdown-all-in-one",
        "shd101wyy.markdown-preview-enhanced",
        "takumii.markdowntable",
        "davidanson.vscode-markdownlint",
        "bpruitt-goddard.mermaid-markdown-syntax-highlighting",
        "csholmq.excel-to-markdown-table",
        "bierner.github-markdown-preview",

        # UML
        "jebbs.plantuml",
        "claudineyqr.plantuml-snippets",
        "hediet.vscode-drawio",
        "ms-vscode.copilot-mermaid-diagram",

        # REST Client
        "humao.rest-client",

        # AI
        "rooveterinaryinc.roo-cline",

        # CSV
        "phplasma.csv-to-table",
        "mechatroner.rainbow-csv"
    )

    $installedCount = 0
    $vsCodeExtensions | ForEach-Object {
        try {
            Write-LogMessage "Instalando extensión VSCode: $_" -Level Info
            $result = & code --install-extension $_ 2>&1
            if ($LASTEXITCODE -eq 0) {
                $installedCount++
                Write-LogMessage "Extensión $_ instalada exitosamente" -Level Success
            } else {
                Write-LogMessage "Error instalando extensión $_`: $result" -Level Warning
            }
        } catch {
            Write-LogMessage "Error instalando extensión $_`: $($_.Exception.Message)" -Level Warning
        }
    }

    Write-LogMessage "Extensiones de VSCode instaladas: $installedCount de $($vsCodeExtensions.Count)" -Level Success
} catch {
    Write-LogMessage "Error en instalación de extensiones VSCode: $($_.Exception.Message)" -Level Error
}
#endregion

#region Herramientas adicionales
Write-LogMessage "Instalando herramientas adicionales..." -Level Info

try {
    . ".\DownloadFromGitHub.ps1"

    $pathAxxon = "C:\Axxon"
    Test-PathAndCreate -Path "$pathAxxon\Tools"

    # Instalar Sizer4
    $sizerUrl = "https://www.brianapps.net/sizer4/sizer4_dev640.msi"
    $sizerPath = "$pathAxxon\Tools\sizer4_dev640.msi"

    Write-LogMessage "Descargando e instalando Sizer4..." -Level Info
    Invoke-WebRequestWithRetry -Uri $sizerUrl -OutFile $sizerPath
    Start-ProcessAndWait -FilePath $sizerPath -ArgumentList '/quiet'

    Write-LogMessage "Herramientas adicionales instaladas exitosamente" -Level Success
} catch {
    Write-LogMessage "Error instalando herramientas adicionales: $($_.Exception.Message)" -Level Warning
}
#endregion

Write-LogMessage "Preparación del entorno común completada" -Level Success
