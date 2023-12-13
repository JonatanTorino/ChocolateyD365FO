
# Installation

## Using Power Shell
Copy and past

### [DevAxCmmRtsLog](https://github.com/JonatanTorino/DevAxCmmRtsLog)
Este modelo sirve para tener un registro del intercambio de mensajes entre el RTS y el RetailServer
```powershell
# Task 1: Clone the repository
$repositoryUrl = "https://github.com/JonatanTorino/DevAxCmmRtsLog"
$localPath = "K:\Axxon\GitHub.JonatanTorino\DevAxCmmRtsLog"

# Clone the repository
git clone $repositoryUrl $localPath | Wait-Process

# Task 2: Create a symbolic link
$modelName = "DevAxCmmRtsLog"
$targetPath = "K:\Axxon\GitHub.JonatanTorino\DevAxCmmRtsLog\"+$modelName
$linkPath = "K:\AosService\PackagesLocalDirectory\"+$modelName

Write-Host 'Remove existing directory if it exists'
cmd /c rmdir /q /s $linkPath

Write-Host 'Create a symbolic link'
New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath

# Task 3: Compile the model
Write-Host 'Executing the D365 module compile command'
Invoke-D365ModuleFullCompile -Module $modelName

```

### [AOTBrowser](https://github.com/arganollc/aotbrowser)
Dynamics 365 for Finance and Operations AOT Browser
```powershell
# Task 1: Clone the repository
$repositoryUrl = "https://github.com/arganollc/aotbrowser"
$localPath = "K:\Axxon\GitHub.JonatanTorino\AOTBrowser"

# Clone the repository
git clone $repositoryUrl $localPath | Wait-Process

# Task 2: Create a symbolic link
$modelName = "AOTBrowser"
$targetPath = "K:\Axxon\GitHub.JonatanTorino\AOTBrowser\Metadata\"+$modelName
$linkPath = "K:\AosService\PackagesLocalDirectory\"+$modelName

Write-Host 'Remove existing directory if it exists'
cmd /c rmdir /q /s $linkPath

Write-Host 'Create a symbolic link'
New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath

# Task 3: Compile the model
Write-Host 'Executing the D365 module compile command'
Invoke-D365ModuleFullCompile -Module $modelName

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
$localPath = "K:\Axxon\GitHub.JonatanTorino\XppTools"

# Clone the repository
git clone $repositoryUrl $localPath | Wait-Process

# Task 2: Create a symbolic link
$modelName = "DEVCommon"
$targetPath = "K:\Axxon\GitHub.JonatanTorino\XppTools\"+$modelName
$linkPath = "K:\AosService\PackagesLocalDirectory\"+$modelName

Write-Host 'Remove existing directory if it exists'
cmd /c rmdir /q /s $linkPath

Write-Host 'Create a symbolic link'
New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath

# Task 3: Compile the model
Write-Host 'Executing the D365 module compile command'
Invoke-D365ModuleFullCompile -Module $modelName

# Task 2: Create a symbolic link
$modelName = "DEVTools"
$targetPath = "K:\Axxon\GitHub.JonatanTorino\XppTools\"+$modelName
$linkPath = "K:\AosService\PackagesLocalDirectory\"+$modelName

Write-Host 'Remove existing directory if it exists'
Remove-Item -Path $linkPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host 'Create a symbolic link'
New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath

# Task 3: Compile the model
Write-Host 'Executing the D365 module compile command'
Invoke-D365ModuleFullCompile -Module $modelName

# Task 2: Create a symbolic link
$modelName = "DEVTutorial"
$targetPath = "K:\Axxon\GitHub.JonatanTorino\XppTools\"+$modelName
$linkPath = "K:\AosService\PackagesLocalDirectory\"+$modelName

Write-Host 'Remove existing directory if it exists'
Remove-Item -Path $linkPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host 'Create a symbolic link'
New-Item -ItemType SymbolicLink -Path $linkPath -Target $targetPath

# Task 3: Compile the model
Write-Host 'Executing the D365 module compile command'
Invoke-D365ModuleFullCompile -Module $modelName

```
