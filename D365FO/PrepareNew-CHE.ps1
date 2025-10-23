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

.\PrepareNew-CommonEnvironment.ps1


#region Additional tools
. ".\DownloadFromGitHub.ps1"
# These applications were commented out in *Packages.config because they do not download correctly
downloadReleaseFromGitHub -repo "kimmknight/remoteapptool" -path "$pathAxxon\Tools" `
    -filesToDownload @("RemoteApp.Tool.6100.msi") `
    -filesToExecute @("RemoteApp.Tool.6100.msi")
#endregion
