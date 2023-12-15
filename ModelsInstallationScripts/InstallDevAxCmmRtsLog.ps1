
# Task 1: Clone the repository
$repositoryUrl = "https://github.com/JonatanTorino/DevAxCmmRtsLog"
$localPath = "K:\Axxon\GitHub.JonatanTorino\DevAxCmmRtsLog"
$modelName = "DevAxCmmRtsLog"

# Clone the repository
git clone $repositoryUrl $localPath | Wait-Process

Write-Host -ForegroundColor Yellow "Deteniendo todos los servicios de D365FO"
Stop-D365Environment

# Task 2: Create a symbolic link
$packagesLocalDirectory = "K:\AosService\PackagesLocalDirectory"
$targetPath = Join-Path $localPath -ChildPath $modelName
$linkPath = Join-Path $packagesLocalDirectory -ChildPath $modelName

Write-Host -ForegroundColor Blue "Remove existing directory if it exists $linkPath"
cmd /c rmdir /q /s $linkPath

Write-Host -ForegroundColor Blue "Create a symbolic link to $targetPath"
New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath

# Task 3: Compile the model
Write-Host -ForegroundColor Green "Executing the D365 module compile command: $modelName"
Invoke-D365ModuleFullCompile -Module $modelName

Start-D365Environment -Aos
Write-Host -ForegroundColor Yellow "Iniciando el servicio del AOS de D365FO"
Start-D365Environment -Batch
Write-Host -ForegroundColor Yellow "Iniciando el servicio del BATCH de D365FO"
