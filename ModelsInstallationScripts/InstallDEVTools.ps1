
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
