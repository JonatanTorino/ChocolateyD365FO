
# Scripts de Preparación para D365FO

Este repositorio contiene scripts estandarizados de PowerShell para preparar entornos de desarrollo de Dynamics 365 Finance and Operations (D365FO).

## Estructura de Scripts

### Scripts Principales

- **`PrepareNew-CHE.ps1`** - Prepara un entorno Cloud-Hosted Environment (CHE)
- **`PrepareNew-UDE.ps1`** - Prepara un entorno Unified Development Environment (UDE)
- **`PrepareNew-CommonEnvironment.ps1`** - Configuración común para todos los entornos
- **`PrepareCommerceVMScript.ps1`** - Preparación específica para entornos de Commerce

### Scripts de Utilidades

- **`CommonFunctions.ps1`** - Funciones compartidas y utilitarias
- **`Add-D365FOExtension.ps1`** - Gestión de extensiones de D365FO
- **`DownloadFromGitHub.ps1`** - Descarga de releases desde GitHub
- **`InstallAppCheckerDependencies.ps1`** - Instalación de dependencias para App Checker
- **`installModulesD365FO.ps1`** - Instalación de módulos de PowerShell
- **`Invoke-VSInstallExtension.ps1`** - Instalación de extensiones de Visual Studio

## Uso

### Preparar un nuevo entorno CHE
```powershell
.\PrepareNew-CHE.ps1
```

### Preparar un nuevo entorno UDE
```powershell
.\PrepareNew-UDE.ps1
```

### Instalar dependencias para App Checker
```powershell
.\InstallAppCheckerDependencies.ps1
```

### Instalar módulos de PowerShell para D365FO
```powershell
.\installModulesD365FO.ps1
```

## Instalación de Modelos Personalizados

### [DevAxCmmUtils](https://github.com/JonatanTorino/DevAxCmmUtils)
Este modelo sirve para tener un registro del intercambio de mensajes entre el RTS y el RetailServer
```powershell
# Usando el script unificado
.\PrepareCommerceVMScript.ps1
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

### [AOTBrowser](https://github.com/arganollc/aotbrowser)
Dynamics 365 for Finance and Operations AOT Browser

### [D365FOAdminToolkit](https://github.com/ameyer505/D365FOAdminToolkit)
Herramientas de administración para D365FO

## Funciones Disponibles

### Funciones de Logging
- `Write-LogMessage` - Escribe mensajes de log con colores consistentes
- `Test-PathAndCreate` - Verifica y crea directorios si no existen

### Funciones de Red
- `Invoke-WebRequestWithRetry` - Realiza peticiones web con reintentos
- `Get-LatestReleaseFromGitHub` - Obtiene información de la última release de GitHub

### Funciones de Procesos
- `Start-ProcessAndWait` - Inicia procesos y espera a que terminen

### Funciones Específicas de D365FO
- `Add-ExtensionToDynamicsDevConfig` - Agrega extensiones al archivo de configuración
- `Download-ReleaseFromGitHub` - Descarga releases desde GitHub
- `Invoke-VSInstallExtension` - Instala extensiones de Visual Studio

## Estándares de Código

Todos los scripts siguen estos estándares:

1. **Comentarios de ayuda**: Todos los scripts y funciones tienen documentación completa
2. **Manejo de errores**: Try-catch blocks para operaciones críticas
3. **Logging consistente**: Uso de `Write-LogMessage` para mensajes uniformes
4. **Funciones reutilizables**: Código común extraído a `CommonFunctions.ps1`
5. **Nombres descriptivos**: Variables y funciones con nombres claros
6. **Validación de parámetros**: Uso de `[CmdletBinding()]` y validaciones apropiadas

## Requisitos

- PowerShell 5.1 o superior
- Módulo `d365fo.tools`
- Acceso a internet para descargas
- Permisos de administrador para algunas operaciones
