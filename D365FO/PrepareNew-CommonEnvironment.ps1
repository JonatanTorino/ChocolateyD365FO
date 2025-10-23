#region Install WinGet, PowerShell, Git
$progressPreference = 'silentlyContinue'
Write-Host "Installing WinGet PowerShell module from PSGallery..."
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
Write-Host "Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet..."
Repair-WinGetPackageManager -AllUsers
Write-Host "Done."

winget install --id Microsoft.PowerShell --source winget
winget install --id Git.Git -e --source winget
#endregion

#region Install applications using Chocolatey
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

#region Install extensions for Visual Studio D365FO
Push-Location 

. ".\DownloadFromGitHub.ps1"
. ".\Add-D365FOExtension.ps1"
$pathAxxon = "C:\Axxon"
$pathForVSIX = "$pathAxxon\D365foVSExtensions"

downloadReleaseFromGitHub -repo "TrudAX/TRUDUtilsD365" -path "$pathForVSIX\TRUDUtilsD365"
Add-ExtensionToDynamicsDevConfig -AddInPath "$pathForVSIX\TRUDUtilsD365"

downloadReleaseFromGitHub -repo "HichemDax\D365FONinjaDevTools" -path "$pathForVSIX\D365FONinjaDevTools"
Add-ExtensionToDynamicsDevConfig -AddInPath "$pathForVSIX\HichemDax"

downloadReleaseFromGitHub -repo "noakesey/d365fo-entity-schema" -path "$pathForVSIX\d365fo-entity-schema"
Add-ExtensionToDynamicsDevConfig -AddInPath "$pathForVSIX\d365fo-entity-schema"

downloadReleaseFromGitHub -repo "shashisadasivan/SSD365VSAddIn" -path "$pathForVSIX\SSD365VSAddIn"
Add-ExtensionToDynamicsDevConfig -AddInPath "$pathForVSIX\SSD365VSAddIn"

Pop-Location
#endregion

#region Install Visual Studio extensions
. ".\Invoke-VSInstallExtension.ps1"
Invoke-VSInstallExtension -Version 2022 -PackageName 'AndriesDK.Highlighter'
Invoke-VSInstallExtension -Version 2022 -PackageName 'cpmcgrath.Codealignment'
Invoke-VSInstallExtension -Version 2022 -PackageName 'EWoodruff.VisualStudioSpellCheckerVS2022andLater'
Invoke-VSInstallExtension -Version 2022 -PackageName 'Loop8ack.ExtensionManager2022'
Invoke-VSInstallExtension -Version 2022 -PackageName 'MadsKristensen.OpeninVisualStudioCode'
Invoke-VSInstallExtension -Version 2022 -PackageName 'MadsKristensen.OutputWindowFilter'
Invoke-VSInstallExtension -Version 2022 -PackageName 'MadsKristensen.TrailingWhitespace64'
Invoke-VSInstallExtension -Version 2022 -PackageName 'MadsKristensen.WorkflowBrowser'
Invoke-VSInstallExtension -Version 2022 -PackageName 'MattLaceyLtd.WarnAboutTODOs'
Invoke-VSInstallExtension -Version 2022 -PackageName 'NeVeS.MermaidEditorForVisualStudio'
Invoke-VSInstallExtension -Version 2022 -PackageName 'NikolayBalakin.Outputenhancer'
Invoke-VSInstallExtension -Version 2022 -PackageName 'SharpDevelopTeam.ILSpy2022'
Invoke-VSInstallExtension -Version 2022 -PackageName 'ShemeerNS.FilePathOnFooter'
Invoke-VSInstallExtension -Version 2022 -PackageName 'ShemeerNS.QuickSolutionFolderX64'
Invoke-VSInstallExtension -Version 2022 -PackageName 'ViktarKarpach.DebugAttachManager2022'
Invoke-VSInstallExtension -Version 2022 -PackageName 'VisualStudioPlatformTeam.MatchMargin2022'
Invoke-VSInstallExtension -Version 2022 -PackageName 'VisualStudioPlatformTeam.SolutionErrorVisualizer2022'
Invoke-VSInstallExtension -Version 2022 -PackageName 'VisualStudioPlatformTeam.TimeStampMargin2022'
Invoke-VSInstallExtension -Version 2022 -PackageName 'VisualStudioProductTeam.ProjectSystemTools2022'
#endregion

#region Install extensions for VSCode
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
. ".\DownloadFromGitHub.ps1"
curl -o "$pathAxxon\Tools\sizer4_dev640.msi" https://www.brianapps.net/sizer4/sizer4_dev640.msi
Start-Process -FilePath "$pathAxxon\Tools\sizer4_dev640.msi" -ArgumentList '/quiet' -Wait
#endregion
