Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objShell = CreateObject("WScript.Shell")

' Get the directory where this VBS script is running
currentDir = objFSO.GetParentFolderName(WScript.ScriptFullName)

' Construct the full path to setup.ps1 in the same directory
ps1Path = Chr(34) & currentDir & "\iinstall.ps1" & Chr(34)

' Run the PowerShell script with elevated privileges and hidden window
objShell.Run "powershell -Command ""Start-Process powershell -Verb runAs -ArgumentList '-WindowStyle','Hidden','-NoExit','-ExecutionPolicy','Bypass','-File'," & ps1Path & """", 0, False
