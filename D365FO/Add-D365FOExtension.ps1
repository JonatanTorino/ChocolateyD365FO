<#
.SYNOPSIS
    Agrega una extensión al archivo DynamicsDevConfig.xml
.DESCRIPTION
    Esta función agrega una ruta de extensión al archivo de configuración de desarrollo de Dynamics 365 FO
.PARAMETER AddInPath
    Ruta de la extensión a agregar
.PARAMETER XmlPath
    Ruta del archivo DynamicsDevConfig.xml (opcional, usa ruta por defecto)
.EXAMPLE
    Add-ExtensionToDynamicsDevConfig -AddInPath "C:\Extensions\MyExtension"
#>

. ".\CommonFunctions.ps1"

function Add-ExtensionToDynamicsDevConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$AddInPath,

        [Parameter(Mandatory = $false)]
        [string]$XmlPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Personal) + "\Visual Studio Dynamics 365\DynamicsDevConfig.xml"
    )

    Write-LogMessage "Agregando extensión a DynamicsDevConfig.xml: $AddInPath" -Level Info

    # Verificar si el archivo XML existe
    if (!(Test-Path $XmlPath)) {
        Write-LogMessage "Archivo DynamicsDevConfig.xml no encontrado en: $XmlPath" -Level Error
        return
    }

    try {
        [xml]$xmlDoc = Get-Content $XmlPath
        $nsMgr = New-Object System.Xml.XmlNamespaceManager($xmlDoc.NameTable)
        $nsMgr.AddNamespace("d", "http://schemas.microsoft.com/dynamics/2012/03/development/configuration")
        $nsMgr.AddNamespace("d2p1", "http://schemas.microsoft.com/2003/10/Serialization/Arrays")

        $addInPathsNode = $xmlDoc.SelectSingleNode("//d:AddInPaths", $nsMgr)

        if ($null -ne $addInPathsNode) {
            # Verificar si la extensión ya existe
            $existingPaths = $addInPathsNode.SelectNodes("d2p1:string", $nsMgr) | ForEach-Object { $_.InnerText }
            if ($AddInPath -in $existingPaths) {
                Write-LogMessage "La extensión ya existe en AddInPaths: $AddInPath" -Level Warning
                return
            }

            # Crear y agregar el nuevo elemento
            $newElem = $xmlDoc.CreateElement("d2p1:string", "http://schemas.microsoft.com/2003/10/Serialization/Arrays")
            $newElem.InnerText = $AddInPath
            $addInPathsNode.AppendChild($newElem) | Out-Null
            $xmlDoc.Save($XmlPath)

            Write-LogMessage "Extensión agregada exitosamente: $AddInPath" -Level Success
        } else {
            Write-LogMessage "Nodo AddInPaths no encontrado en DynamicsDevConfig.xml" -Level Warning
        }
    }
    catch {
        Write-LogMessage "Error al procesar DynamicsDevConfig.xml: $($_.Exception.Message)" -Level Error
        throw
    }
}
