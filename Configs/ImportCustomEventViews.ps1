Write-Host "Importando vistas personalizadas del EventViewer"
Copy-Item -Path ".\EventViewer\*" -Recurse -Destination "$env:ProgramData\Microsoft\Event Viewer\Views" -Verbose