# Tomado de ejemplo desde el repositorio https://github.com/TrudAX/TRUDScripts/

#region Install tools
Install-Module -Name SqlServer -AllowClobber
Install-Module -Name d365fo.tools -AllowClobber
Add-D365WindowsDefenderRules
Invoke-D365InstallAzCopy
#endregion


#region Install additional apps using Chocolatey
If (Test-Path -Path "$env:ProgramData\Chocolatey") {
    choco upgrade chocolatey -y
    choco upgrade all --ignore-checksums -y
}
Else {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    choco install curl -y

    curl -o $env:TEMP\DefaultPackages.config https://raw.githubusercontent.com/JonatanTorino/ChocolateyD365FO/main/DefaultPackages.config

    choco install $env:TEMP\DefaultPackages.config -y

    curl -o $env:TEMP\JonasPackages.config https://raw.githubusercontent.com/JonatanTorino/ChocolateyD365FO/main/JonasPackages.config

    choco install $env:TEMP\JonasPackages.config -y

    choco install Nuget.CommandLine
    nuget sources add -Name NugetOrg -Source https://api.nuget.org/v3/index.json
}
#endregion


#region ChangeSQLServer
Import-Module SqlServer
# Create a Server object for the default instance
$SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server "."
# Set the maximum server memory to 5000 MB
$SqlServer.Configuration.MaxServerMemory.ConfigValue = 5000
# Set the "Compress Backup" option to true
$SqlServer.Configuration.DefaultBackupCompression.ConfigValue = 1
# Save the changes
$SqlServer.Configuration.Alter()
#endregion


#region Disable services
Write-Host "Setting web browser homepage to the local environment"
Get-D365Url | Set-D365StartPage
Write-Host "Setting Management Reporter to manual startup to reduce churn and Event Log messages"
Get-D365Environment -FinancialReporter | Set-Service -StartupType Manual
Stop-Service -Name MR2012ProcessService -Force
Set-Service -Name MR2012ProcessService -StartupType Disabled
Write-Host "Setting Windows Defender rules to speed up compilation time"
Add-D365WindowsDefenderRules -Silent
#endregion


#region ChangeIIS Express for IIS
if (test-path "$env:servicedrive\AOSService\PackagesLocalDirectory\bin\DynamicsDevConfig.xml") {
    [xml]$xmlDoc = Get-Content "$env:servicedrive\AOSService\PackagesLocalDirectory\bin\DynamicsDevConfig.xml"
    if ($xmlDoc.DynamicsDevConfig.RuntimeHostType -ne "IIS") {
        write-host 'Setting RuntimeHostType to "IIS" in DynamicsDevConfig.xml' -ForegroundColor yellow
        $xmlDoc.DynamicsDevConfig.RuntimeHostType = "IIS"
        $xmlDoc.Save("$env:servicedrive\AOSService\PackagesLocalDirectory\bin\DynamicsDevConfig.xml")
        write-host 'RuntimeHostType set "IIS" in DynamicsDevConfig.xml' -ForegroundColor Green
    }#end if IIS check
}#end if test-path xml file
else { write-host 'AOSService drive not found! Could not set RuntimeHostType to "IIS"' -ForegroundColor red }
#endregion


#region Download from Github
Function downloadReleaseFromGitHub {
    Param(
        [Parameter(Mandatory = $true)][string]$repo,
        [Parameter(Mandatory = $true)][string]$path,
        [Parameter(Mandatory = $true)][string[]]$filesToDownload,
        [string[]]$filesToExecute
    )
    Process {
        $releases = "https://api.github.com/repos/$repo/releases"

        If (!(test-path $path)) {
            New-Item -ItemType Directory -Force -Path $path
        }
        cd $path
        
        Write-Host Determining latest release
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $tag = (Invoke-WebRequest -Uri $releases -UseBasicParsing | ConvertFrom-Json)[0].tag_name

        Write-Host Downloading files
        foreach ($file in $filesToDownload) {
            $download = "https://github.com/$repo/releases/download/$tag/$file"
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest $download -Out $file
            Unblock-File $file
        }

        foreach ($file in $filesToExecute) {
            Start-Process -FilePath $file
        }
    }
}
#endregion


#region Install extensions para VisualStudio

# TrudUtilsD365 2022
$pathForVSIX = "K:\Axxon\VSExtensions"
downloadReleaseFromGitHub -repo "TrudAX/TRUDUtilsD365" -path "$pathForVSIX\TRUDUtilsD365" -filesToDownload @("InstallToVS.exe", "TRUDUtilsD365.dll", "TRUDUtilsD365.pdb") -filesToExecute @("InstallToVS.exe")

# Debug Attach Manager 2019
downloadReleaseFromGitHub -repo "karpach/debug-attach-manager" -path "K:\Axxon\VSExtensions" -filesToDownload @("DebugAttachHistory.vsix")

# Debug Attach Manager 2022
curl -o "$pathForVSIX\DebugAttachManager2022.vsix" https://viktarkarpach.gallerycdn.vsassets.io/extensions/viktarkarpach/debugattachmanager2022/2.4.220301.0/1646780693672/DebugAttachHistory.vsix

# ExtensionManager 2022
curl -o "$pathForVSIX\ExtensionManager2022.vsix" https://loop8ack.gallerycdn.vsassets.io/extensions/loop8ack/extensionmanager2022/1.2.180/1702761415816/ExtensionManager2022.vsix

# ExtensionManager 2022
curl -o "$pathForVSIX\ExtensionManager2019.vsix" https://madskristensen.gallerycdn.vsassets.io/extensions/madskristensen/extensionmanager2019/1.1.82/1624393592068/Extension_Manager_2019_v1.1.82.vsix

$filesVSIX = Get-ChildItem -Path $pathForVSIX -Filter *.vsix
foreach ($file in $filesVSIX) {
    Start-Process -FilePath $file -Wait
}
#endregion


