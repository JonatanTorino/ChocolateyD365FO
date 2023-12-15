
# Task 1: Clone the repository
$repositoryUrl = "https://github.com/TrudAX/XppTools"
$metadata = "K:\Axxon\GitHub.JonatanTorino\XppTools"

# Clone the repository
git clone $repositoryUrl $localPath | Wait-Process

Write-Host -ForegroundColor Yellow "Deteniendo todos los servicios de D365FO"
Stop-D365Environment

# Task 2: Create a symbolic link

# Task 1: Listado de modelos
$modelList = Get-ChildItem -Path $metadata -Directory |  Select-Object -ExpandProperty Name
$modelList

# Task 2: Create a symbolic link
Write-Host -ForegroundColor Yellow "Deteniendo todos los servicios de D365FO"
Stop-D365Environment

foreach ($modelName in $modelList) {
    $targetPath = Join-Path $metadata -ChildPath $modelName
    $linkPath = Join-Path $packagesLocalDirectory -ChildPath $modelName
    
    Write-Host -ForegroundColor Blue "Remove existing directory if it exists $linkPath"
    cmd /c rmdir /q /s $linkPath

    Write-Host -ForegroundColor Blue "Create a symbolic link to $targetPath"
    Write-Host
    New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath
    Write-Host
}

Write-Host
Write-Host

# # Task 3: Compile the model
foreach ($modelName in $modelList) {
    Write-Host -ForegroundColor Green  "Executing the D365 module compile command: $modelName"
    Invoke-D365ModuleFullCompile -Module $modelName
}

Start-D365Environment -Aos
Write-Host -ForegroundColor Yellow "Iniciando el servicio del AOS de D365FO"
Start-D365Environment -Batch
Write-Host -ForegroundColor Yellow "Iniciando el servicio del BATCH de D365FO"
