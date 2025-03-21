if (-not (Get-Module -ListAvailable -Name PolicyFileEditor)) {
    Install-PackageProvider -Name Nuget -MinimumVersion 2.8.5.201 -Force
    Set-PSRepository cmdlet -Force
    Install-Module -Name PolicyFileEditor -Force
    Start-Sleep -Seconds 15
}
Import-module -Name PolicyFileEditor
$url = "https://github.com/BlockCrusherSC/image/archive/refs/heads/main.zip"
$ping = Test-Connection -ComputerName $url -Count 1 -Quiet
$output = "image"
$WallpaperPath = "C:\Windows\ImmersiveControlPanel\images\image.png"
$MachineDir = "$env:windir\System32\GroupPolicy\Machine\Registry.pol"
$UserRegDir = "$env:windir\system32\GroupPolicy\User\registry.pol"
$settings = Get-Process -Name SystemSettings -ErrorAction SilentlyContinue

Test-Connection -ComputerName https://github.com/BlockCrusherSC/image/archive/refs/heads/main.zip -Count 1 -Quiet
Remove-Item -LiteralPath "$PSScriptRoot\image" -Force -Recurse
Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile "$PSScriptRoot\$output.zip"
Start-Sleep -Seconds 10
Expand-Archive -Path "$PSScriptRoot\$output.zip" -DestinationPath "$PSScriptRoot\$output" -Force
Start-Sleep -Seconds 10
Remove-Item "$PSScriptRoot\$output.zip"
$imNum = Get-Content -Path "$PSScriptRoot\image\image-main\image-number.txt" -TotalCount 1
$doIt = (Get-Content -Path "$PSScriptRoot\image\image-main\image-number.txt" -TotalCount 2)[-1]
Copy-Item -Path "$PSScriptRoot\image\image-main\$imNum.png" -Destination "C:\Windows\ImmersiveControlPanel\images\image.png"
if ($doIt -eq 1 -or $doIt -eq "1"){
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name 'WallPaper' -Value $WallpaperPath
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name 'WallpaperStyle' -Value 22
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name 'TileWallpaper' -Value 0
RUNDLL32.EXE user32.dll, UpdatePerUserSystemParameters 1, True
RUNDLL32.EXE user32.dll, UpdatePerUserSystemParameters
Copy-Item -Path "$PSScriptRoot\image\image-main\$imNum.png" -Destination "C:\ProgramData\Microsoft\User Account Pictures\user.png"
Copy-Item -Path "$PSScriptRoot\image\image-main\$imNum.png" -Destination "C:\ProgramData\Microsoft\User Account Pictures\guest.png"
# Computers --> Control Panel --> Personalization --> Force a specific default lock screen and logon image
$RegPath = "Software\Policies\Microsoft\Windows\Personalization"
Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName "LockScreenImage" -Data $WallpaperPath -Type "String"

# Users --> Control Panel --> Personalization --> Prevent changing desktop background --> Enable
$RegPath = "Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop"
Set-PolicyFileEntry -Path $UserRegDir -Key $RegPath -ValueName "NoChangingWallPaper" -Data 1 -Type "DWord"

# Users --> Desktop --> Desktop --> Wallpaper
$RegPath = "Software\Microsoft\Windows\CurrentVersion\Policies\System"
Set-PolicyFileEntry -Path $UserRegDir -Key $RegPath -ValueName "Wallpaper" -Data $WallpaperPath -Type "String"
Set-PolicyFileEntry -Path $UserRegDir -Key $RegPath -ValueName "WallpaperStyle" -Data 5 -Type "String"

# Users --> Desktop --> Desktop --> Prevent Changes
$RegPath = "Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
Set-PolicyFileEntry -Path $UserRegDir -Key $RegPath -ValueName "NoActiveDesktopChanges" -Data 1 -Type "String"

# Computers --> Control Panel --> Personalization --> Prevent changing lock screen and logon image
$RegPath = "Software\Policies\Microsoft\Windows\Personalization"
Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName "NoChangingLockScreen" -Data 1 -Type "String"
Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName "NoChangingStartMenuBackground" -Data 1 -Type "String"

$RegPath = "Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName "UseDefaultTile" -Data 1 -Type "DWord"



gpupdate /force
RUNDLL32.EXE user32.dll, UpdatePerUserSystemParameters 1, True
$code = @'
using System.Runtime.InteropServices; 
namespace Win32{ 
    
     public class Wallpaper{ 
        [DllImport("user32.dll", CharSet=CharSet.Auto)] 
         static extern int SystemParametersInfo (int uAction , int uParam , string lpvParam , int fuWinIni) ; 
         
         public static void SetWallpaper(string thePath){ 
            SystemParametersInfo(20,0,thePath,3); 
         }
    }
 } 
'@

add-type $code 
[Win32.Wallpaper]::SetWallpaper($WallpaperPath)
Start-Process "RUNDLL32.EXE" -ArgumentList "USER32.DLL,UpdatePerUserSystemParameters 1, True"
RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True
RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True
RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True
RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True
RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True
RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True
RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True
RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True
RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True
RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True
RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True
RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True
RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True
RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True
RUNDLL32.EXE USER32.DLL, UpdatePerUserSystemParameters 1, True
}