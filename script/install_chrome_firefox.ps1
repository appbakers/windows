function LogWrite {
    Param ([string]$logstring)
    $now = Get-Date -format s
    Add-Content $Logfile -value "$now $logstring"
    Write-Host $logstring
}
 
function CheckLocation {
    Param ([string]$location)
    if (!(Test-Path  $location)) {
        throw [System.IO.FileNotFoundException] "Could not download to Destination $location."
    }
}
 
$Logfile = "C:\Windows\Temp\chrome-firefox-install.log"
 
$chrome_source = "http://dl.google.com/chrome/install/375.126/chrome_installer.exe"
$chrome_destination = "C:\Windows\Temp\chrome_installer.exe"
$firefox_source = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/39.0/win32/hu/Firefox%20Setup%2039.0.exe"
$firefox_destination = "C:\Windows\Temp\firefoxinstaller.exe"
 
LogWrite 'Starting to download files.'
try {
    LogWrite 'Downloading Chrome...'
    (New-Object System.Net.WebClient).DownloadFile($chrome_source, $chrome_destination)
    CheckLocation $chrome_destination
    LogWrite 'Done...'
    LogWrite 'Downloading Firefox...'
    (New-Object System.Net.WebClient).DownloadFile($firefox_source, $firefox_destination)
    CheckLocation $firefox_destination
} catch [Exception] {
    LogWrite "Exception during download. Probable cause could be that the directory or the file didn't exist."
    LogWrite '$_.Exception is' $_.Exception
}
 
LogWrite 'Starting firefox install process.'
try {
    Start-Process -FilePath $firefox_destination -ArgumentList "-ms" -Wait -PassThru
} catch [Exception] {
    LogWrite 'Exception during install process.'
    LogWrite '$_.Exception is' $_.Exception
}
LogWrite 'Starting chrome install process.'
 
try {
    Start-Process -FilePath $chrome_destination -ArgumentList "/silent /install" -Wait -PassThru
} catch [Exception] {
    LogWrite 'Exception during install process.'
    LogWrite '$_.Exception is' $_.Exception
}
 
LogWrite 'All done. Goodbye.'
