
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
