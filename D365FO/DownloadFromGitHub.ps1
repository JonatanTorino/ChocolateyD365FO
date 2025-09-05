function downloadReleaseFromGitHub {
    Param(
        [Parameter(Mandatory = $true)][string]$repo,
        [Parameter(Mandatory = $true)][string]$path,
        [string[]]$filesToDownload,
        [string[]]$filesToExecute
    )
    Process {
        $releases = "https://api.github.com/repos/$repo/releases"

        # Create destination directory if it does not exist
        if (!(Test-Path $path)) {
            New-Item -ItemType Directory -Force -Path $path
        }
        cd $path

        Write-Host "Determining latest release"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $release = (Invoke-WebRequest -Uri $releases -UseBasicParsing | ConvertFrom-Json)[0]
        $tag = $release.tag_name

        Write-Host "Downloading files"
        if ($null -eq $filesToDownload -or $filesToDownload.Count -eq 0) {
            foreach ($asset in $release.assets) {
                $download = $asset.browser_download_url
                $file = $asset.name
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                Invoke-WebRequest $download -OutFile $file
                Unblock-File $file
            }
        } else {
            foreach ($file in $filesToDownload) {
                $download = "https://github.com/$repo/releases/download/$tag/$file"
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                Invoke-WebRequest $download -OutFile $file
                Unblock-File $file
            }
        }

        # Execute files if specified
        foreach ($file in $filesToExecute) {
            Start-Process -FilePath $file
        }
    }
}