# Source file location
$source = 'https://dl.google.com/drive-file-stream/GoogleDriveSetup.exe'
# Destination to save the file
$destination = "$env:USERPROFILE\Downloads\GoogleDriveSetup.exe"
#Download the file
Invoke-WebRequest -Uri $source -OutFile $destination
#Install
Start-Process -FilePath "$env:USERPROFILE\Downloads\GoogleDriveSetup.exe" --silent
