# Introduction 
En este repositorio armamos una lista de las personalizaciones recomendadas para instalar aplicaciones y configuraciones en entornos de desarrollos.

# Getting Started
Requerido [chocolatey](https://chocolatey.org/install).
Se instalan las siguientes aplicaciones

## Installation

### Using Power Shell
Copy and past
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install curl -y

curl -o $env:TEMP\DefaultPackages.config https://raw.githubusercontent.com/JonatanTorino/ChocolateyD365FO/main/DefaultPackages.config

choco install $env:TEMP\DefaultPackages.config -y

curl -o $env:TEMP\JonasPackages.config https://raw.githubusercontent.com/JonatanTorino/ChocolateyD365FO/main/JonasPackages.config

choco install $env:TEMP\JonasPackages.config -y

```

##  Instalattion individualy
```powershell
choco install GoogleChrome -y 
choco install microsoft-edge -y 
choco install 7zip -y 
choco install remoteapp -y 
choco install sizer -y 
choco install vscode -y 
choco install notepadplusplus.install -y 
```
