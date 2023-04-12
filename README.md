# Introduction 
En este repositorio armamos una lista de las personalizaciones recomendadas para instalar aplicaciones y configuraciones en entornos de desarrollos.

# Getting Started
Requerido [chocolatey]https://chocolatey.org/install
Se instalan las siguientes aplicaciones

##  Se puede copiar y pegar todo junto en powershell

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install curl -y

curl -o $env:TEMP\DefaultPackages.config https://raw.githubusercontent.com/JonatanTorino/ChocolateyPoC/main/DefaultPackages.config

choco install $env:TEMP\DefaultPackages.config -y

curl -o $env:TEMP\JonasPackages.config https://raw.githubusercontent.com/JonatanTorino/ChocolateyPoC/main/JonasPackages.config

choco install $env:TEMP\JonasPackages.config -y


##  O sino se pueden instalar por separado de forma individual
choco install 7zip -y \
choco install GoogleChrome -y \
choco install microsoft-edge -y \
choco install remoteapp -y \
choco install sizer -y \
choco install vscode -y \
choco install notepadplusplus.install -y \
