function Get-Special-Commands {
    Write-Host " "
    Write-Host "#################################################"
    Write-Host "#                                               #"
    Write-Host "#    Spezielle Befehle:                         #"
    Write-Host "#                                               #"
    Write-Host "#    1. change-bg <Pfad zum Bild>               #"
    Write-Host "#    2. Install-Winget                          #"
    Write-Host "#    3. Install-PSWU                            #"
    Write-Host "#    4. update                                  #"
    Write-Host "#    5. line9                                   #"
    Write-Host "#    6. line4                                   #"
    Write-Host "#    7. pswu                                    #"
    Write-Host "#    8. open-tweaks                             #"
    Write-Host "#    9. compare-filehash                        #"
    Write-Host "#                                               #"
    Write-Host "#################################################"
    Write-Host " "
}

function hello-sir {
    cls
    Write-Host "#################################################"
    Write-Host "#                                               #"
    Write-Host "#    Hallo Sir, Willkommen in PowerShell        #"
    Write-Host "#                                               #"
    Write-host "#################################################"
    Write-Host " "
    Write-Host "# Eine Liste der verfuegbaren Befehle finden Sie unter Get-Special-Commands"
    Get-Special-Commands
}

function Test-Administrator  
{  
    write-host "Teste nach Administrator-Permission"
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

function compare-filehash($File, $Hash, $Type) {
    $TypeFiles = "Files"
    $TypeHash = "Hash"

    if ($Type -match $TypeFiles) {
        Write-Host "Vergleiche Hashes zweier Dateien!"
        $File1_Hash = (Get-FileHash $File).Hash
        $File2_Hash = (Get-FileHash $Hash).Hash
        if ($File1_Hash -match $File2_Hash) {
            Write-Host "####################################"
            Write-Host "#   Der Filehash stimmt ueberein!  #"
            Write-Host "####################################"
            Write-Host "File1 -> $File1_Hash"
            Write-Host "File2 -> $File2_Hash"
        } else {
            Write-Warning "##########################################"
            Write-Warning "#   Der Filehash stimmt NICHT ueberein!  #"
            Write-Warning "##########################################"
            Write-Warning "File1 -> $File1_Hash"
            Write-Warning "File2 -> $File2_Hash"
        }
    } elseif ($Type -match $TypeHash) {
        Write-Host "Vergleiche Filehash mit angebenen Hashwert"
        $File1_Hash = (Get-FileHash $File).Hash
        if ($File1_Hash -match $Hash) {
            Write-Host "####################################"
            Write-Host "#   Der Filehash stimmt ueberein!  #"
            Write-Host "####################################"
            Write-Host "File1     -> $File1_Hash"
            Write-Host "ang. Hash -> $Hash"
        } else {
            Write-Warning "##########################################"
            Write-Warning "#   Der Filehash stimmt NICHT ueberein!  #"
            Write-Warning "##########################################"
            Write-Host "File1     -> $File1_Hash"
            Write-Host "ang. Hash -> $Hash"
        } 
    } else {
        Write-Host "Falscher Syntax => compare-filehash <File> <Hash oder File2> <Type: Files, Hash>"
    }
}

function Test-Administrator  
{  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

function change-bg {

    $path = $args[0]

    $setwallpapersrc = @"
    using System.Runtime.InteropServices;

    public class Wallpaper
    {
    public const int SetDesktopWallpaper = 20;
    public const int UpdateIniFile = 0x01;
    public const int SendWinIniChange = 0x02;
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    public static void SetWallpaper(string path)
    {
      SystemParametersInfo(SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange);
    }
    }
"@
        Add-Type -TypeDefinition $setwallpapersrc

        [Wallpaper]::SetWallpaper($path)

}

function Install-Winget { #Lets install Winget
  $winget = Get-Command winget -ErrorAction SilentlyContinue
  if ($winget -eq $null) {
      Write-Output "Winget is not installed. Installing Winget..."
      powershell "irm https://gitlab.it-wehgeh.de/Jonas_Techand/winget-install/-/raw/master/winget-install.ps1 | iex" 
      # This uses a public githup repo to download all sources and install winget. This also installs the App Installer for .msix files.
      if ($?) {
          Write-Output "Winget was installed successfully."
      }
      else {
          Write-Warning "Winget was not installed successfully."
      }}
  else {
      Write-Output "Winget is already installed. Skipping installation."
      return
  }}

  function Install-PSWU {
    $PSWU = Get-Command Install-WindowsUpdate -ErrorAction SilentlyContinue
    if ($PSWU -eq $null) {
        Write-Output "The PowerShell Windows Update Tool is not installed. Installing PSWU..."
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass # Set Execution Policy to Bypass to allow the installation of the PSWindowsUpdate Module
        $ExecutionPol = Get-ExecutionPolicy
        if ($ExecutionPol -ne "Bypass") {
            Write-Warning "Could not set the Execution Policy to Bypass. The PSWindowsUpdate Module will not be installed."
            return
        } else {
        Install-PackageProvider -Name NuGet -Force -Scope AllUsers -ForceBootstrap # Install Nuget to Skip Prompt. Necessary for PSWindowsUpdate
        Install-Module -Name PSWindowsUpdate -Force # Install PSWindowsUpdate
        Add-WUServiceManager -ServiceID "7971f918-a847-4430-9279-4a52d1efe18d" -AddServiceFlag 7 -Confirm:$False # Adds global updates from microsoft to the update manager to catch all updates and drivers. 
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned # Set Execution Policy back to RemoteSigned
        }
        if ($?) {
            Write-Output "The PowerShell Windows Update Tool was installed successfully."
        }
        else {
            Write-Warning "The PowerShell Windows Update Tool was not installed successfully."
        }}
    else {
        Write-Output "The PowerShell Windows Update Tool is already installed. Skipping installation."
        return
    }}

function enable-scripting {
    write-host "Aktiviere Skripting. Bitte deaktivere es nach der Installation wieder!"
    Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\PowerShell -Name ExecutionPolicy -Value ByPass
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
}

function disable-scripting {
    write-host "Deaktiviere Skripting..."
    Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\PowerShell -Name ExecutionPolicy -Value RemoteSigned
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
}

function update {
  $originalPath = Get-Location
  Install-Winget
  $ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
        if ($ResolveWingetPath){
               $WingetPath = $ResolveWingetPath[-1].Path
        }
    
    $Wingetpath = Split-Path -Path $WingetPath -Parent
    cd $wingetpath
  .\winget upgrade --all --force --include-unknown
  Install-PSWU
  Install-WindowsUpdate -MicrosoftUpdate -AcceptAll
  cd $originalPath
}

function line9 {
  ssh techandj@10.5.70.101
}

function line4 {
  ssh techandj@10.5.70.100
}

function pswu {
    Get-WUList -MicrosoftUpdate
    Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot
}

function open-tweaks {
  iwr -useb https://christitus.com/win | iex
}

hello-sir

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
