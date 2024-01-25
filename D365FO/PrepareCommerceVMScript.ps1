
# Task 1: Clone the repository
[PSCustomObject[]] $repositories = [PSCustomObject]@{
    repositoryUrl = "https://github.com/JonatanTorino/DevAxCmmRtsLog"
    localPath = "K:\Axxon\GitHub.JonatanTorino\DevAxCmmRtsLog"
    models = [PSCustomObject[]]@(
        [PSCustomObject]@{modelName = "DevAxCmmRtsLog"; metadataPath = "K:\Axxon\GitHub.JonatanTorino\DevAxCmmRtsLog"}
    )
}

$repositories += [PSCustomObject]@{
    repositoryUrl = "https://github.com/JonatanTorino/DevAxCmmUtils"
    localPath = "K:\Axxon\GitHub.JonatanTorino\DevAxCmmUtils"
    models = [PSCustomObject[]]@(
        [PSCustomObject]@{modelName = "DevAxCmmUtils"; metadataPath = "K:\Axxon\GitHub.JonatanTorino\DevAxCmmUtils"}
    )
}

$repositories += [PSCustomObject]@{
    repositoryUrl = "https://github.com/arganollc/aotbrowser"
    localPath = "K:\Axxon\GitHub.JonatanTorino\AOTBrowser"
    models = [PSCustomObject[]]@(
        [PSCustomObject]@{modelName = "AOTBrowser"; metadataPath = "K:\Axxon\Github.JonatanTorino\AOTBrowser\Metadata\AOTBrowser"}
    )
}

$repositories += [PSCustomObject]@{
    repositoryUrl = "https://github.com/TrudAX/XppTools"
    localPath = "K:\Axxon\GitHub.JonatanTorino\XppTools"
    models = [PSCustomObject[]]@(
        [PSCustomObject]@{modelName = "DEVCommon"; metadataPath = "K:\Axxon\GitHub.JonatanTorino\XppTools\DEVCommon"},
        [PSCustomObject]@{modelName = "DEVTools"; metadataPath = "K:\Axxon\GitHub.JonatanTorino\XppTools\DEVTools"},
        [PSCustomObject]@{modelName = "DEVTutorial"; metadataPath = "K:\Axxon\GitHub.JonatanTorino\XppTools\DEVTutorial"}
    )
}

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
        cmd /c rmdir /q /s $linkPath
        
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
