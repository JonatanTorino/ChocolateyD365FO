$downloadsPath = "$Env:USERPROFILE\Downloads"

$fileName = 'jdk-25_windows-x64_bin.msi'
# Construir la ruta completa del archivo de destino
$fullPath = Join-Path -Path $downloadPath -ChildPath $fileName

# Ejecutar curl.exe
# -L: Sigue redirecciones
# -o: Especifica el archivo de salida con la ruta completa
curl.exe -L -o $fullPath 'https://download.oracle.com/java/25/latest/jdk-25_windows-x64_bin.msi'
Start-Process -FilePath $fullPath -ArgumentList '/quiet' -Wait


$fileName = 'BaseX120.exe'
# Construir la ruta completa del archivo de destino
$fullPath = Join-Path -Path $downloadPath -ChildPath $fileName

# Ejecutar curl.exe
# -L: Sigue redirecciones
# -o: Especifica el archivo de salida con la ruta completa
curl.exe -L -o $fullPath 'https://files.basex.org/releases/12.0/BaseX120.exe'
Start-Process -FilePath $fullPath -ArgumentList '/quiet' -Wait
