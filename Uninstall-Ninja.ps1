param (
    [Parameter(Mandatory=$false)]
    [switch]$DelTeamViewer = $false
)
 
# Set current Ninja install and registry paths
If ([IntPtr]::Size -eq 4) { # 32-bit OS
 $ninjaSoftKey = 'Registry::HKLM:\SOFTWARE\NinjaRMM LLC\NinjaRMMAgent\'
 $ninjaDir = (Get-ItemPropertyValue $ninjaSoftKey -Name Location)
 $uninstallKey = 'Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
 $installerKey = 'Registry::HKCR\Installer\Products'
    } Else { # 64-bit OS
 $ninjaSoftKey = 'Registry::HKLM\SOFTWARE\WOW6432Node\NinjaRMM LLC\NinjaRMMAgent\'
 $ninjaDir = (Get-ItemPropertyValue $ninjaSoftKey -Name Location)
 $uninstallKey = 'Registry::HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
 $installerKey = 'Registry::HKCR\Installer\Products'
}
 
# Executes uninstall.exe in Ninja install directory
& "$ninjaDir\uninstall.exe" --% --mode unattended | out-null
# Delete Ninja install directory and all contents
& cmd.exe /c rd /s /q $ninjaDir
 
# Removes the Ninja service, may give error "OpenService FAILED 1060" if service was already removed
sc.exe DELETE NinjaRMMAgent
 
# Will search registry locations for NinjaRMMAgent value and delete parent key
# Search $uninstallKey
$keys = Get-ChildItem $uninstallKey | Get-ItemProperty -name 'DisplayName' -ErrorAction SilentlyContinue
foreach ($key in $keys) {
 if ($key.'DisplayName' -eq "NinjaRMMAgent"){
 Remove-Item $key.PSPath -Recurse -Force
        }
}
#Search $installerKey
$keys = Get-ChildItem $installerKey | Get-ItemProperty -name 'ProductName' -ErrorAction SilentlyContinue
foreach ($key in $keys) {
 if ($key.'ProductName' -eq "NinjaRMMAgent"){
 Remove-Item $key.PSPath -Recurse -Force
        }
}
 
# Uninstall TeamViewer only if -DelTeamViewer parameter specified
if($DelTeamViewer -eq $true){
 $tvProcess = Get-Process -Name "teamviewer"
 Stop-Process -InputObject $tvProcess -Force # Stops TeamViewer process
 
    & ${env:Programfiles}"\TeamViewer\uninstall.exe" /S | out-null
    & ${env:ProgramFiles(x86)}"\TeamViewer\uninstall.exe" /S | out-null
 
 Remove-Item -path HKLM:\SOFTWARE\TeamViewer -Recurse
 Remove-Item -path HKLM:\SOFTWARE\WOW6432Node\TeamViewer -Recurse
 Remove-Item -path HKLM:\SOFTWARE\WOW6432Node\TVInstallTemp -Recurse
 Remove-Item -path HKLM:\SOFTWARE\TeamViewer -Recurse
 Remove-Item -path HKLM:\SOFTWARE\Wow6432Node\TeamViewer -Recurse
}
else{
 Exit
}
