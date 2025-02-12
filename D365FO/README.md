
# Installation

## Using Power Shell
Copy and past

### [DevAxCmmUtils](https://github.com/JonatanTorino/DevAxCmmUtils)
Este modelo sirve para tener un registro del intercambio de mensajes entre el RTS y el RetailServer
```powershell
# Task 1: Clone the repository
$repositoryUrl = "https://github.com/JonatanTorino/DevAxCmmUtils"
$localPath = "K:\Axxon\GitHub.JonatanTorino\DevAxCmmUtils"
$modelName = "DevAxCmmUtils"

# Clone the repository
git clone $repositoryUrl $localPath | Wait-Process

Write-Host -ForegroundColor Yellow "Deteniendo todos los servicios de D365FO"
Stop-D365Environment

# Task 2: Create a symbolic link
$packagesLocalDirectory = "K:\AosService\PackagesLocalDirectory"
$targetPath = Join-Path $localPath -ChildPath $modelName
$linkPath = Join-Path $packagesLocalDirectory -ChildPath $modelName

Write-Host -ForegroundColor Cyan "Remove existing directory if it exists $linkPath"
Remove-Item -Path $linkPath -Recurse -Force

Write-Host -ForegroundColor Cyan "Create a symbolic link to $target<Path"
New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath

# Task 3: Compile the model
Write-Host -ForegroundColor Green "Executing the D365 module compile command: $modelName"
Invoke-D365ModuleFullCompile -Module $modelName

Write-Host -ForegroundColor Yellow "Iniciando el servicio del AOS de D365FO"
Start-D365EnvironmentV2 -Aos
Write-Host -ForegroundColor Yellow "Iniciando el servicio del BATCH de D365FO"
Start-D365EnvironmentV2 -Batch

```

### [DEVTools](https://github.com/TrudAX/XppTools)
- Fields list
- Display system field name in the query filter
- Display table relation fields
- Editable table browser
- List of Values to Range
- Execute direct SQL in D365FO database
- SQL reports
- D365FO Infolog call stack
- D365FO DFM Tools
```powershell
# Task 1: Clone the repository
$repositoryUrl = "https://github.com/TrudAX/XppTools"
$metadata = "K:\Axxon\GitHub.JonatanTorino\XppTools"

# Clone the repository
git clone $repositoryUrl $metadata | Wait-Process

Write-Host -ForegroundColor Yellow "Deteniendo todos los servicios de D365FO"
Stop-D365Environment

# Task 1: Listado de modelos
$modelList = Get-ChildItem -Path $metadata -Directory | Select-Object -ExpandProperty Name | Where { $_ -like "DEV*" }
$modelList

# Task 2: Create a symbolic link
Write-Host -ForegroundColor Yellow "Deteniendo todos los servicios de D365FO"
Stop-D365Environment

foreach ($modelName in $modelList) {
    $targetPath = Join-Path $metadata -ChildPath $modelName
    $linkPath = Join-Path $packagesLocalDirectory -ChildPath $modelName
    
    Write-Host -ForegroundColor Cyan "Remove existing directory if it exists $linkPath"
    Remove-Item -Path $linkPath -Recurse -Force

    Write-Host -ForegroundColor Cyan "Create a symbolic link to $targetPath"
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

Start-D365EnvironmentV2 -Aos
Write-Host -ForegroundColor Yellow "Iniciando el servicio del AOS de D365FO"
Start-D365EnvironmentV2 -Batch
Write-Host -ForegroundColor Yellow "Iniciando el servicio del BATCH de D365FO"

```

### [AOTBrowser](https://github.com/arganollc/aotbrowser)
Dynamics 365 for Finance and Operations AOT Browser
```powershell
# Task 1: Clone the repository
$repositoryUrl = "https://github.com/arganollc/aotbrowser"
$localPath = "K:\Axxon\GitHub.JonatanTorino\AOTBrowser"
$modelName = "AOTBrowser"
$AOTBrowsersln = "K:\Axxon\Github.JonatanTorino\AOTBrowser\Projects\AOTBrowser\AOTBrowser.sln"

# Clone the repository
git clone $repositoryUrl $localPath | Wait-Process

Write-Host -ForegroundColor Yellow "Deteniendo todos los servicios de D365FO"
Stop-D365Environment

# Task 2: Create a symbolic link
$packagesLocalDirectory = "K:\AosService\PackagesLocalDirectory"
$targetPath = Join-Path $localPath -ChildPath "Metadata\$modelName"
$linkPath = Join-Path $packagesLocalDirectory -ChildPath $modelName

Write-Host -ForegroundColor Cyan "Remove existing directory if it exists $linkPath"
Remove-Item -Path $linkPath -Recurse -Force

Write-Host -ForegroundColor Cyan "Create a symbolic link to $targetPath"
New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath

Write-Host -ForegroundColor Cyan "Start VisualStudio for build the solution $AOTBrowsersln"
Write-Host -ForegroundColor Cyan "Then press any key for continue..."
Read-Host

# Task 3: Compile the model
Write-Host -ForegroundColor Green "Executing the D365 module compile command: $modelName"
Invoke-D365ModuleFullCompile -Module $modelName

Write-Host -ForegroundColor Yellow "Iniciando el servicio del AOS de D365FO"
Start-D365EnvironmentV2 -Aos
Write-Host -ForegroundColor Yellow "Iniciando el servicio del BATCH de D365FO"
Start-D365EnvironmentV2 -Batch

```
