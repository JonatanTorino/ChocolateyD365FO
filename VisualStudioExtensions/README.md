Esta sección es para automatizar las instalaciones de extensiones para VisualStudio
- TRUDUtilsD365

# Instalacion usando Power Shell
Copiar y pegar en consola

## [TRUDUtilsD365](https://github.com/TrudAX/TRUDUtilsD365)
### For VS 2022
```powershell
$repo = "TrudAX/TRUDUtilsD365"
$releases = "https://api.github.com/repos/$repo/releases"
$path = "C:\AAA_VS2022"

If(!(test-path $path))
{
    New-Item -ItemType Directory -Force -Path $path
}
cd $path

Write-Host Determining latest release
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$tag = (Invoke-WebRequest -Uri $releases -UseBasicParsing | ConvertFrom-Json)[0].tag_name

$files = @("InstallToVS.exe",  "TRUDUtilsD365.dll",  "TRUDUtilsD365.pdb")

Write-Host Downloading files
foreach ($file in $files) 
{
    $download = "https://github.com/$repo/releases/download/$tag/$file"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest $download -Out $file
    Unblock-File $file
}
Start-Process "InstallToVS.exe" -Verb runAs

```

### For VS 2019
```powershell
$repo = "TrudAX/TRUDUtilsD365"
$path = "C:\AAA_VS2019"

If(!(test-path $path))
{
    New-Item -ItemType Directory -Force -Path $path
}
cd $path

Write-Host Determining latest release for VS 2019 is 2.5.7
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$tag = "2.5.7" # Last version for VS 2019

$files = @("InstallToVS.exe",  "TRUDUtilsD365.dll",  "TRUDUtilsD365.pdb")

Write-Host Downloading files
foreach ($file in $files) 
{
    $download = "https://github.com/$repo/releases/download/$tag/$file"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest $download -Out $file
    Unblock-File $file
}
Start-Process "InstallToVS.exe" -Verb runAs

```