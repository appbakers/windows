param (
	[string]$admin_password= $(throw "-admin_password is required for new installation."),
	[string]$password = $(throw "-password is required for new installation.")
)

if( [Environment]::Is64BitProcess ) { $tightvnc_version_arch = '64bit'; }
else { $tightvnc_version_arch = '32bit'; }

$url = "http://www.tightvnc.com/download/2.7.10/tightvnc-2.7.10-setup-$tightvnc_version_arch.msi";
$storageDir = $pwd;
$filename = $url.Substring($url.LastIndexOf("/") + 1);
$file = "$storageDir\$filename";

if( -Not (Test-Path $filename) ) {
 Write-Output "Downloading Starting";
 $client = New-Object System.Net.Webclient;
 $client.DownloadFile($url, $file);
 Write-Output "Downloading Finished.";
}

Write-Output "Installing TightVNC";
#msiexec /i $file /quiet /norestart /l* tightvnc_install.log ADDLOCAL="Server,Viewer" VIEWER_ASSOCIATE_VNC_EXTENSION=1 SERVER_REGISTER_AS_SERVICE=1 SERVER_ADD_FIREWALL_EXCEPTION=1 VIEWER_ADD_FIREWALL_EXCEPTION=1 SERVER_ALLOW_SAS=1 SET_USEVNCAUTHENTICATION=1 VALUE_OF_USEVNCAUTHENTICATION=1 SET_PASSWORD=1 VALUE_OF_PASSWORD=$password SET_USECONTROLAUTHENTICATION=1 VALUE_OF_USECONTROLAUTHENTICATION=1 SET_CONTROLPASSWORD=1 VALUE_OF_CONTROLPASSWORD=$admin_password

###==> debugging. purpose. Write-Output "fatal-debug: $password"

$result = (Start-Process -FilePath msiexec.exe -ArgumentList "/i $file /quiet /norestart /l* tightvnc_install.log ADDLOCAL=Server,Viewer VIEWER_ASSOCIATE_VNC_EXTENSION=1 SERVER_REGISTER_AS_SERVICE=1 SERVER_ADD_FIREWALL_EXCEPTION=1 VIEWER_ADD_FIREWALL_EXCEPTION=1 SERVER_ALLOW_SAS=1 SET_USEVNCAUTHENTICATION=1 VALUE_OF_USEVNCAUTHENTICATION=1 SET_PASSWORD=1 VALUE_OF_PASSWORD=$password SET_USECONTROLAUTHENTICATION=1 VALUE_OF_USECONTROLAUTHENTICATION=1 SET_CONTROLPASSWORD=1 VALUE_OF_CONTROLPASSWORD=$admin_password" -Wait -Passthru).ExitCode

if( $null -ne (wmic product where name=`"TightVNC`" get name) ) { Write-Output "TightVNC is Installed." }
else { Write-Output "TightVNC failed to install. Please check $storageDir\tightvnc_install.log" }
