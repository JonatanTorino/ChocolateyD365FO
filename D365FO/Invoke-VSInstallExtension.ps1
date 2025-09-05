function Invoke-VSInstallExtension {
    param(
        [Parameter(Position=1)]
        [ValidateSet('2019','2022')]
        [System.String]$Version,  
    [String] $PackageName)
 
    $ErrorActionPreference = "Stop"
 
    $baseProtocol = "https:"
    $baseHostName = "marketplace.visualstudio.com"
 
    $Uri = "$($baseProtocol)//$($baseHostName)/items?itemName=$($PackageName)"
    $VsixLocation = "$($env:Temp)\$([guid]::NewGuid()).vsix"

    switch ($Version) {
        '2019' {
            $VSInstallDir = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\resources\app\ServiceHub\Services\Microsoft.VisualStudio.Setup.Service"
        }
        '2022' {
            $VSInstallDir = "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\"
        }
    }

    If ((test-path $VSInstallDir)) {

        Write-Host "Grabbing VSIX extension at $($Uri)"
        $HTML = Invoke-WebRequest -Uri $Uri -UseBasicParsing -SessionVariable session
    
        Write-Host "Attempting to download $($PackageName)..."
        $anchor = $HTML.Links |
        Where-Object { $_.class -eq 'install-button-container' } |
        Select-Object -ExpandProperty href

        if (-Not $anchor) {
            Write-Error "Could not find download anchor tag on the Visual Studio Extensions page"
            Exit 1
        }
        Write-Host "Anchor is $($anchor)"
        $href = "$($baseProtocol)//$($baseHostName)$($anchor)"
        Write-Host "Href is $($href)"
        Invoke-WebRequest $href -OutFile $VsixLocation -WebSession $session
    
        if (-Not (Test-Path $VsixLocation)) {
            Write-Error "Downloaded VSIX file could not be located"
            Exit 1
        }


        Write-Host "************    VSInstallDir is:  $($VSInstallDir)"
        Write-Host "************    VsixLocation is: $($VsixLocation)"
        Write-Host "************    Installing: $($PackageName)..."
        Start-Process -Filepath "$($VSInstallDir)\VSIXInstaller" -ArgumentList "/q /a $($VsixLocation)" -Wait

        Write-Host "Cleanup..."
        Remove-Item $VsixLocation -Force -Confirm:$false
    
        Write-Host "Installation of $($PackageName) complete!"
    }
}