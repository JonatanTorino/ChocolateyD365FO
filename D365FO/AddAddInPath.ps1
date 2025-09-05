function Add-AddInPathToDynamicsDevConfig {
    param(
        [Parameter(Mandatory = $true)][string]$AddInPath,
        [string]$XmlPath = "$env:USERPROFILE\Documents\Visual Studio Dynamics 365\DynamicsDevConfig.xml"
    )
    # Check if the XML file exists
    if (Test-Path $XmlPath) {
        [xml]$xmlDoc = Get-Content $XmlPath
        $nsMgr = New-Object System.Xml.XmlNamespaceManager($xmlDoc.NameTable)
        $nsMgr.AddNamespace("d", "http://schemas.microsoft.com/dynamics/2012/03/development/configuration")
        $nsMgr.AddNamespace("d2p1", "http://schemas.microsoft.com/2003/10/Serialization/Arrays")
        $addInPathsNode = $xmlDoc.SelectSingleNode("//d:AddInPaths", $nsMgr)
        if ($addInPathsNode -ne $null) {
            # Create and add the new node with the received path
            $newElem = $xmlDoc.CreateElement("d2p1:string", "http://schemas.microsoft.com/2003/10/Serialization/Arrays")
            $newElem.InnerText = $AddInPath
            $addInPathsNode.AppendChild($newElem) | Out-Null
            $xmlDoc.Save($XmlPath)
            Write-Host "Added $AddInPath to AddInPaths in DynamicsDevConfig.xml" -ForegroundColor Green
        } else {
            Write-Host "AddInPaths node not found in DynamicsDevConfig.xml" -ForegroundColor Yellow
        }
    } else {
        Write-Host "DynamicsDevConfig.xml not found at $XmlPath" -ForegroundColor Red
    }
}
