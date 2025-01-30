
# Task 1: Clone the repository
[PSCustomObject[]] $repositories = [PSCustomObject]@{
    repositoryUrl = "https://github.com/JonatanTorino/DevAxCmmUtils"
    localPath     = "K:\Axxon\GitHub.JonatanTorino\DevAxCmmUtils"
    models        = [PSCustomObject[]]@(
        [PSCustomObject]@{modelName = "DevAxCmmUtils"; metadataPath = "K:\Axxon\GitHub.JonatanTorino\DevAxCmmUtils\DevAxCmmUtils" }
    )
}

$repositories += [PSCustomObject]@{
    repositoryUrl = "https://github.com/JonatanTorino/DevAxRefreshData"
    localPath     = "K:\Axxon\GitHub.JonatanTorino\DevAxRefreshData"
    models        = [PSCustomObject[]]@(
        [PSCustomObject]@{modelName = "DevAxRefreshData"; metadataPath = "K:\Axxon\Github.JonatanTorino\DevAxRefreshData\DevAxRefreshData" }
    )
}

$repositories += [PSCustomObject]@{
    repositoryUrl = "https://github.com/arganollc/aotbrowser"
    localPath     = "K:\Axxon\GitHub.JonatanTorino\AOTBrowser"
    models        = [PSCustomObject[]]@(
        [PSCustomObject]@{modelName = "AOTBrowser"; metadataPath = "K:\Axxon\Github.JonatanTorino\AOTBrowser\Metadata\AOTBrowser" }
    )
}

$repositories += [PSCustomObject]@{
    repositoryUrl = "https://github.com/TrudAX/XppTools"
    localPath     = "K:\Axxon\GitHub.JonatanTorino\XppTools"
    models        = [PSCustomObject[]]@(
        [PSCustomObject]@{modelName = "DEVCommon"; metadataPath = "K:\Axxon\GitHub.JonatanTorino\XppTools\DEVCommon" },
        [PSCustomObject]@{modelName = "DEVTools"; metadataPath = "K:\Axxon\GitHub.JonatanTorino\XppTools\DEVTools" }
        #,[PSCustomObject]@{modelName = "DEVTutorial"; metadataPath = "K:\Axxon\GitHub.JonatanTorino\XppTools\DEVTutorial"}
    )
}

$repositories += [PSCustomObject]@{
    repositoryUrl = "https://github.com/ameyer505/D365FOAdminToolkit"
    localPath     = "K:\Axxon\GitHub.JonatanTorino\D365FOAdminToolkit"
    models        = [PSCustomObject[]]@(
        [PSCustomObject]@{modelName = "D365FOAdminToolkit"; metadataPath = "K:\Axxon\GitHub.JonatanTorino\D365FOAdminToolkit\Metadata\D365FOAdminToolkit" },
        [PSCustomObject]@{modelName = "D365FOAdminToolkitTest"; metadataPath = "K:\Axxon\GitHub.JonatanTorino\D365FOAdminToolkit\Metadata\D365FOAdminToolkitTests" }
    )
}

$repositories += [PSCustomObject]@{
    repositoryUrl = "https://github.com/JonatanTorino/MyPowerShellScripts"
    localPath     = "K:\Axxon\GitHub.JonatanTorino\MyPowerShellScripts"
}

$repositories += [PSCustomObject]@{
    repositoryUrl = "https://github.com/JonatanTorino/CommerceStoreScaleUnitSetupInstaller"
    localPath     = "K:\Axxon\GitHub.JonatanTorino\CommerceStoreScaleUnitSetupInstaller"
}

$repositories += [PSCustomObject]@{
    repositoryUrl = "https://github.com/JonatanTorino/CodeSnippets"
    localPath     = "K:\Axxon\GitHub.JonatanTorino\CodeSnippets"
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
    Invoke-D365ProcessModule -Module $modelItem -ExecuteCompile
}
# $modelsToBuild = ($models | ForEach-Object { "`"$_`"" }) -join ','

Write-Host -ForegroundColor Yellow "Iniciando el servicio del AOS de D365FO"
Start-D365EnvironmentV2 -Aos
Write-Host -ForegroundColor Yellow "Iniciando el servicio del BATCH de D365FO"
Start-D365EnvironmentV2 -Batch
