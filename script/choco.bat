@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

@powershell -NoProfile -ExecutionPolicy Bypass -Command "winrm set winrm/config '@{MaxTimeoutms="7200000"}'"
@powershell -NoProfile -ExecutionPolicy Bypass -Command "winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="0"}'"
@powershell -NoProfile -ExecutionPolicy Bypass -Command "winrm set winrm/config/winrs '@{MaxProcessesPerShell="0"}'"
@powershell -NoProfile -ExecutionPolicy Bypass -Command "winrm set winrm/config/winrs '@{MaxShellsPerUser="0"}'"
