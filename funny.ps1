$WallpaperPath = "C:\Hidden\Jerrod-Brown.png"

$MachineDir = "$env:windir\System32\GroupPolicy\Machine\Registry.pol"
$UserRegDir = "$env:windir\system32\GroupPolicy\User\registry.pol"


# Set Wallpaper
$settings = Get-Process -Name SystemSettings -ErrorAction SilentlyContinue


Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name 'WallPaper' -Value $WallpaperPath
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name 'WallpaperStyle' -Value 22
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\' -Name 'TileWallpaper' -Value 0

RUNDLL32.EXE user32.dll, UpdatePerUserSystemParameters 1, True
RUNDLL32.EXE user32.dll, UpdatePerUserSystemParameters


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
Set-PolicyFileEntry -Path $UserRegDir -Key $RegPath -ValueName "NoActiveDesktopChanges" -Data 1 -Type "DWord"

# Computers --> Control Panel --> Personalization --> Prevent changing lock screen and logon image
$RegPath = "Software\Policies\Microsoft\Windows\Personalization"
Set-PolicyFileEntry -Path $MachineDir -Key $RegPath -ValueName "NoChangingLockScreen" -Data 1 -Type "DWord"

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

#Apply the Change on the system 
[Win32.Wallpaper]::SetWallpaper($WallpaperPath)