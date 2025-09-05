
# Task 1: Clone the repository
[PSCustomObject[]] $repositories = [PSCustomObject]@{
    repositoryUrl = "https://github.com/JonatanTorino/DevAxCmmUtils"
    localPath     = "K:\Repos\GitHub.JonatanTorino\DevAxCmmUtils"
    models        = [PSCustomObject[]]@(
        [PSCustomObject]@{modelName = "DevAxCmmUtils"; metadataPath = "K:\Repos\GitHub.JonatanTorino\DevAxCmmUtils\DevAxCmmUtils" }
    )
}

$repositories += [PSCustomObject]@{
    repositoryUrl = "https://github.com/JonatanTorino/DevAxRefreshData"
    localPath     = "K:\Repos\GitHub.JonatanTorino\DevAxRefreshData"
    models        = [PSCustomObject[]]@(
        [PSCustomObject]@{modelName = "DevAxRefreshData"; metadataPath = "K:\Repos\Github.JonatanTorino\DevAxRefreshData\DevAxRefreshData" }
    )
}

$repositories += [PSCustomObject]@{
    repositoryUrl = "https://github.com/arganollc/aotbrowser"
    localPath     = "K:\Repos\GitHub.JonatanTorino\AOTBrowser"
    models        = [PSCustomObject[]]@(
        [PSCustomObject]@{modelName = "AOTBrowser"; metadataPath = "K:\Repos\Github.JonatanTorino\AOTBrowser\Metadata\AOTBrowser" }
    )
}

$repositories += [PSCustomObject]@{
    repositoryUrl = "https://github.com/TrudAX/XppTools"
    localPath     = "K:\Repos\GitHub.JonatanTorino\XppTools"
    models        = [PSCustomObject[]]@(
        [PSCustomObject]@{modelName = "DEVCommon"; metadataPath = "K:\Repos\GitHub.JonatanTorino\XppTools\DEVCommon" },
        [PSCustomObject]@{modelName = "DEVTools"; metadataPath = "K:\Repos\GitHub.JonatanTorino\XppTools\DEVTools" }
        #,[PSCustomObject]@{modelName = "DEVTutorial"; metadataPath = "K:\Repos\GitHub.JonatanTorino\XppTools\DEVTutorial"}
    )
}

$repositories += [PSCustomObject]@{
    repositoryUrl = "https://github.com/ameyer505/D365FOAdminToolkit"
    localPath     = "K:\Repos\GitHub.JonatanTorino\D365FOAdminToolkit"
    models        = [PSCustomObject[]]@(
        [PSCustomObject]@{modelName = "D365FOAdminToolkit"; metadataPath = "K:\Repos\GitHub.JonatanTorino\D365FOAdminToolkit\Metadata\D365FOAdminToolkit" },
        [PSCustomObject]@{modelName = "D365FOAdminToolkitTest"; metadataPath = "K:\Repos\GitHub.JonatanTorino\D365FOAdminToolkit\Metadata\D365FOAdminToolkitTests" }
    )
}

$repositories += [PSCustomObject]@{
    repositoryUrl = "https://github.com/JonatanTorino/MyPowerShellScripts"
    localPath     = "K:\Repos\GitHub.JonatanTorino\MyPowerShellScripts"
}

$repositories += [PSCustomObject]@{
    repositoryUrl = "https://github.com/JonatanTorino/CommerceStoreScaleUnitSetupInstaller"
    localPath     = "K:\Repos\GitHub.JonatanTorino\CommerceStoreScaleUnitSetupInstaller"
}

$repositories += [PSCustomObject]@{
    repositoryUrl = "https://github.com/JonatanTorino/CodeSnippets"
    localPath     = "K:\Repos\GitHub.JonatanTorino\CodeSnippets"
}

Import-Module d365fo.tools

foreach ($repo in $repositories) {
    # Clone the repository
    git clone $repo.repositoryUrl $repo.localPath | Wait-Process
}

Write-Host -ForegroundColor Yellow "Deteniendo todos los servicios de D365FO"
Stop-D365Environment

# Task 2: Create a symbolic link
[string[]]$models = @()
$packagesLocalDirectory = "K:\AosService\PackagesLocalDirectory"
foreach ($repo in $repositories) {
    foreach ($model in $repo.models) {
        $targetPath = $model.metadataPath
        $linkPath = Join-Path $packagesLocalDirectory -ChildPath $model.modelName
        
        Write-Host -ForegroundColor Cyan "Remove existing directory if it exists $linkPath"
        Remove-Item -Path $linkPath -Recurse -Force
        
        Write-Host -ForegroundColor Cyan "Create a symbolic link to $targetPath"
        New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath
        
        $models += $model.modelName
    }
}

# Task 3: Compile the models
foreach ($modelItem in $models) {
    Write-Host -ForegroundColor Green "Executing the D365 module compile command: $modelItem"
    # Invoke-D365ProcessModule -Module $modelItem -ExecuteCompile
}
# $modelsToBuild = ($models | ForEach-Object { "`"$_`"" }) -join ','

Write-Host -ForegroundColor Yellow "Iniciando el servicio del AOS de D365FO"
Start-D365EnvironmentV2 -Aos
Write-Host -ForegroundColor Yellow "Iniciando el servicio del BATCH de D365FO"
Start-D365EnvironmentV2 -Batch
