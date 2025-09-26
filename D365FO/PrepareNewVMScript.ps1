# VM preparation script for Dynamics 365 FO
# Based on https://github.com/TrudAX/TRUDScripts/

#region Install main tools
Install-Module -Name SqlServer -AllowClobber
Install-Module -Name d365fo.tools -AllowClobber
Add-D365WindowsDefenderRules
Invoke-D365InstallAzCopy
Invoke-D365InstallSqlPackage # -url "https://go.microsoft.com/fwlink/?linkid=2316204"
# Copy C:\Program Files\Microsoft SQL Server\170\DAC\bin to C:\Temp\d365fo.tools\SqlPackage if needed
#endregion

#region Backup configuration
Backup-D365WebConfig 
Backup-D365DevConfig 
#endregion

#region Install additional applications using Chocolatey
if (Test-Path -Path "$env:ProgramData\Chocolatey") {
    choco upgrade chocolatey -y
    choco upgrade all --ignore-checksums -y
} else {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    choco install curl -y

    curl -o $env:TEMP\DefaultPackages.config https://raw.githubusercontent.com/JonatanTorino/ChocolateyD365FO/main/DefaultPackages.config
    choco install $env:TEMP\DefaultPackages.config -y

    curl -o $env:TEMP\JonasPackages.config https://raw.githubusercontent.com/JonatanTorino/ChocolateyD365FO/main/JonasPackages.config
    choco install $env:TEMP\JonasPackages.config -y

    choco install Nuget.CommandLine
    nuget sources add -Name NugetOrg -Source https://api.nuget.org/v3/index.json
}
#endregion

#region SQL Server configuration
Import-Module SqlServer
# Create server object for default instance
$SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server "."
# Limit max server memory to 5000 MB
$SqlServer.Configuration.MaxServerMemory.ConfigValue = 5000
# Enable backup compression
$SqlServer.Configuration.DefaultBackupCompression.ConfigValue = 1
# Save changes
$SqlServer.Configuration.Alter()
#endregion

#region Disable unnecessary services
Write-Host "Setting web browser homepage to the local environment"
Get-D365Url | Set-D365StartPage

Write-Host "Setting Management Reporter to manual startup"
Stop-D365Environment -FinancialReporter
Get-D365Environment -FinancialReporter | Set-Service -StartupType Disabled
Stop-Service -Name MR2012ProcessService -Force
Set-Service -Name MR2012ProcessService -StartupType Disabled

Write-Host "Setting DMF to manual startup"
Stop-D365Environment -DMF
Get-D365Environment -DMF | Set-Service -StartupType Disabled

Write-Host "Adding Windows Defender rules to speed up compilation"
Add-D365WindowsDefenderRules -Silent
#endregion

#region Switch from IIS Express to IIS
if (Test-Path "$env:servicedrive\AOSService\PackagesLocalDirectory\bin\DynamicsDevConfig.xml") {
    [xml]$xmlDoc = Get-Content "$env:servicedrive\AOSService\PackagesLocalDirectory\bin\DynamicsDevConfig.xml"
    if ($xmlDoc.DynamicsDevConfig.RuntimeHostType -ne "IIS") {
        Write-Host 'Changing RuntimeHostType to "IIS" in DynamicsDevConfig.xml' -ForegroundColor yellow
        $xmlDoc.DynamicsDevConfig.RuntimeHostType = "IIS"
        $xmlDoc.Save("$env:servicedrive\AOSService\PackagesLocalDirectory\bin\DynamicsDevConfig.xml")
        Write-Host 'RuntimeHostType changed to "IIS" in DynamicsDevConfig.xml' -ForegroundColor Green
    }
} else { 
    Write-Host 'AOSService drive not found! Could not change RuntimeHostType to "IIS"' -ForegroundColor red 
}
#endregion

# Enable IIS preload
Enable-D365IISPreload

# #region Load support scripts
# if ([string]::IsNullOrWhiteSpace($PSScriptRoot)) {
#     $PSScriptRoot = (Get-Location).Path
# }
. ".\DownloadFromGitHub.ps1"
. ".\Add-D365FOExtension.ps1"
. ".\Invoke-VSInstallExtension.ps1"
#endregion

#region Install Visual Studio extensions D365FO
$pathAxxon = "K:\Axxon"
$pathForVSIX = "$pathAxxon\D365foVSExtensions"

downloadReleaseFromGitHub -repo "TrudAX/TRUDUtilsD365" -path "$pathForVSIX\TRUDUtilsD365"
Add-ExtensionToDynamicsDevConfig -AddInPath "$pathForVSIX\TRUDUtilsD365"

downloadReleaseFromGitHub -repo "HichemDax\D365FONinjaDevTools" -path "$pathForVSIX\D365FONinjaDevTools"
Add-ExtensionToDynamicsDevConfig -AddInPath "$pathForVSIX\HichemDax"

downloadReleaseFromGitHub -repo "noakesey/d365fo-entity-schema" -path "$pathForVSIX\d365fo-entity-schema"
Add-ExtensionToDynamicsDevConfig -AddInPath "$pathForVSIX\d365fo-entity-schema"

downloadReleaseFromGitHub -repo "shashisadasivan/SSD365VSAddIn" -path "$pathForVSIX\SSD365VSAddIn"
Add-ExtensionToDynamicsDevConfig -AddInPath "$pathForVSIX\SSD365VSAddIn"

#endregion

#region Install Visual Studio extensions
Invoke-VSInstallExtension -Version 2022 -PackageName 'cpmcgrath.Codealignment'
Invoke-VSInstallExtension -Version 2022 -PackageName 'EWoodruff.VisualStudioSpellCheckerVS2022andLater'
Invoke-VSInstallExtension -Version 2022 -PackageName 'MadsKristensen.OpeninVisualStudioCode'
Invoke-VSInstallExtension -Version 2022 -PackageName 'MadsKristensen.TrailingWhitespace64'
Invoke-VSInstallExtension -Version 2022 -PackageName 'VisualStudioProductTeam.ProjectSystemTools2022'
Invoke-VSInstallExtension -Version 2022 -PackageName 'ViktarKarpach.DebugAttachManager2022'
Invoke-VSInstallExtension -Version 2022 -PackageName 'Loop8ack.ExtensionManager2022'
#endregion

#region Install vscode extensions
$vsCodeExtensions = @(
    "alexk.vscode-xpp"
    ,"mhutchie.git-graph"

    #Style
    ,"alefragnani.bookmarks"
    ,"johnpapa.vscode-peacock"
    ,"wayou.vscode-todo-highlight"
    ,"gruntfuggly.todo-tree"
    ,"oderwat.indent-rainbow"
    ,"pkief.material-icon-theme"

    #JSON/XML
    ,"ZainChen.json"
    ,"DotJoshJohnson.xml"
    ,"meezilla.json"

    #PowerShell
    ,"ms-vscode.PowerShell"
    ,"tylerleonhardt.vscode-inline-values-powershell"
    
    #DBML
    ,"bocovo.dbml-erd-visualizer"
    ,"rizkykurniawan.dbml-previewer"
    ,"matt-meyers.vscode-dbml"

    #Database
    ,"ms-mssql.mssql"
    ,"piotrgredowski.poor-mans-t-sql-formatter-pg"

    #Markdown
    ,"yzhang.markdown-all-in-one"
    ,"shd101wyy.markdown-preview-enhanced"
    ,"takumii.markdowntable"
    ,"davidanson.vscode-markdownlint"
    ,"bpruitt-goddard.mermaid-markdown-syntax-highlighting"
    ,"csholmq.excel-to-markdown-table"
    ,"bierner.github-markdown-preview"

    #UML
    ,"jebbs.plantuml"
    ,"claudineyqr.plantuml-snippets"
    ,"hediet.vscode-drawio"
    ,"ms-vscode.copilot-mermaid-diagram"

    #REST Client
    ,"humao.rest-client"

    #AI
    ,"rooveterinaryinc.roo-cline"

    #CSV
    ,"phplasma.csv-to-table"
    ,"mechatroner.rainbow-csv"
)

$vsCodeExtensions | ForEach-Object {
    code --install-extension $_
}
#endregion

#region Additional tools
# These applications were commented out in *Packages.config because they do not download correctly
downloadReleaseFromGitHub -repo "kimmknight/remoteapptool" -path "$pathAxxon\Tools" `
    -filesToDownload @("RemoteApp.Tool.6100.msi") `
    -filesToExecute @("RemoteApp.Tool.6100.msi")

curl -o "$pathAxxon\Tools\sizer4_dev640.msi" https://www.brianapps.net/sizer4/sizer4_dev640.msi
#endregion
