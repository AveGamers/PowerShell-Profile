function install-xaml {
    $url = "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.3"
    Invoke-WebRequest -Uri $URL -OutFile "xaml.zip" -UseBasicParsing
    Expand-Archive .\xaml.zip -DestinationPath C:\source\xaml
    Add-AppxPackage -Path "C:\source\xaml\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.7.appx" 
    Remove-Item "xaml.zip"
}

function install-winget {
        # get latest download url
        $URL = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
        $URL = (Invoke-WebRequest -Uri $URL).Content | ConvertFrom-Json |
                Select-Object -ExpandProperty "assets" |
                Where-Object "browser_download_url" -Match '.msixbundle' |
                Select-Object -ExpandProperty "browser_download_url"

        # download
        Invoke-WebRequest -Uri $URL -OutFile "Setup.msix" -UseBasicParsing

        # install
        install-xaml
        Add-AppxPackage -Path "Setup.msix"

        # delete file
        Remove-Item "Setup.msix"
}

function say-hello {
        Write-Host "###############################################"
        Write-Host "##                                           ##"
        Write-Host "##  Welcome to the Windows Package Manager!  ##"
        Write-Host "##                                           ##"
        Write-Host "###############################################"     
}

function update {
    winget upgrade --all --accept-package-agreements --accept-source-agreements --force
    Write-Host "Update complete!"
}

function install {
    winget install $args --accept-package-agreements --accept-source-agreements --force
}

function uninstall {
    winget uninstall $args --force
}

install-xaml
say-hello