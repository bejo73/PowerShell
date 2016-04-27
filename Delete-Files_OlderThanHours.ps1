# Path to the files to be deleted
Set-Location -Path "Microsoft.PowerShell.Core\FileSystem::C:\Temp"

# Hours to keep messages 
$hours = 3

# Extension of the files to delete
$extension = "*.bak"

# Remove old files 
Get-ChildItem -Path . -Filter $extension | Where { $_.Lastwritetime -lt (Date).addhours(-$hours) } | Remove-Item
