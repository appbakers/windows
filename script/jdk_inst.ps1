param (
		[string]$major="7",
		[string]$minor="79",
		[string]$build="15"
)

function LogWrite {
	Param ([string]$logstring);
	$now = Get-Date -format s;
	Add-Content $Logfile -value "$now $logstring";
	Write-Host $logstring;
}
$Logfile = "C:\Windows\Temp\jdk-install.log";

$Arch = (Get-Process -Id $PID).StartInfo.EnvironmentVariables["PROCESSOR_ARCHITECTURE"];
if ($Arch -eq 'x86') {
	Write-Host -Object 'Running 32-bit PowerShell';
	$OS_ARCH=32;
}
elseif ($Arch -eq 'amd64') {
	Write-Host -Object 'Running 64-bit PowerShell';
	$OS_ARCH=64;
}
LogWrite "OS_ARCH detected as $OS_ARCH";

$JDK_VER=$major +'u'+ $minor;
$JDK_FULL_VER=$major +'u'+ $minor +'-b'+ $build;
$JDK_PATH='1.'+ $major +'.0_'+ $minor;
$source86 = "http://download.oracle.com/otn-pub/java/jdk/$JDK_FULL_VER/jdk-$JDK_VER-windows-i586.exe";
$source64 = "http://download.oracle.com/otn-pub/java/jdk/$JDK_FULL_VER/jdk-$JDK_VER-windows-x64.exe";
$destination86 = "C:\Windows\Temp\$JDK_VER-x86.exe";
$destination64 = "C:\Windows\Temp\$JDK_VER-x64.exe";
$client = new-object System.Net.WebClient;
$cookie = "oraclelicense=accept-securebackup-cookie";
$client.Headers.Add([System.Net.HttpRequestHeader]::Cookie, $cookie);

LogWrite "Setting Execution Policy level to Bypass";
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force;

LogWrite 'Checking if Java ($JDK_PATH) is already installed';
if ((Test-Path "c:\Program Files (x86)\Java\$JDK_PATH") -Or (Test-Path "c:\Program Files\Java\$JDK_PATH")) {
	LogWrite 'No need to Install Java';
	Exit;
}

LogWrite 'Downloading x86 to $destination86';
try {
	$client.downloadFile($source86, $destination86);
	if (!(Test-Path $destination86)) {
		LogWrite "Downloading $destination86 failed";
		Exit;
	}

	if( $OS_ARCH -eq '64' ) {
		LogWrite 'Downloading x64 to $destination64';

		$client.downloadFile($source64, $destination64);
		if (!(Test-Path $destination64)) {
			LogWrite "Downloading $destination64 failed";
			Exit;
		}
	}
} catch [Exception] {
	LogWrite '$_.Exception is' $_.Exception;
}

try {
	if( $OS_ARCH -eq '64' ) {
		LogWrite 'Installing JDK-x64';
		$proc1 = Start-Process -FilePath "$destination64" -ArgumentList "/s REBOOT=ReallySuppress" -Wait -PassThru;
		$proc1.waitForExit();
		LogWrite 'Installation Done.';
	}

	LogWrite 'Installing JDK-x86';
	$proc2 = Start-Process -FilePath "$destination86" -ArgumentList "/s REBOOT=ReallySuppress" -Wait -PassThru;
	$proc2.waitForExit();
	LogWrite 'Installtion Done.';
} catch [exception] {
	LogWrite '$_ is' $_;
	LogWrite '$_.GetType().FullName is' $_.GetType().FullName;
	LogWrite '$_.Exception is' $_.Exception;
	LogWrite '$_.Exception.GetType().FullName is' $_.Exception.GetType().FullName;
	LogWrite '$_.Exception.Message is' $_.Exception.Message;
}

if ((Test-Path "c:\Program Files (x86)\Java") -Or (Test-Path "c:\Program Files\Java")) {
	LogWrite 'Java installed successfully.';
} else {
	LogWrite 'Java install Failed!';
}
LogWrite 'Setting up Path variables.';

if( $OS_ARCH -eq '32' ) {
	[System.Environment]::SetEnvironmentVariable("JAVA_HOME", "c:\Program Files\Java\jdk$JDK_PATH", "Machine");
	[System.Environment]::SetEnvironmentVariable("JAVA_HOME32", "c:\Program Files\Java\jdk$JDK_PATH", "Machine");
	[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";c:\Program Files\Java\jdk$JDK_PATH\bin", "Machine");
} else {
	[System.Environment]::SetEnvironmentVariable("JAVA_HOME", "c:\Program Files\Java\jdk$JDK_PATH", "Machine");
	[System.Environment]::SetEnvironmentVariable("JAVA_HOME32", "c:\Program Files (x86)\Java\jdk$JDK_PATH", "Machine");
	[System.Environment]::SetEnvironmentVariable("JAVA_HOME64", "c:\Program Files\Java\jdk$JDK_PATH", "Machine");
	[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";c:\Program Files\Java\jdk$JDK_PATH\bin", "Machine");
}
LogWrite '$Env:JAVA_HOME :: ' [System.Environment]::GetEnvironmentVariable("JAVA_HOME");
LogWrite '$Env:JAVA_HOME32 ::' [System.Environment]::GetEnvironmentVariable("JAVA_HOME32");
LogWrite '$Env:JAVA_HOME64 ::' [System.Environment]::GetEnvironmentVariable("JAVA_HOME64");

LogWrite 'Done. Goodbye.'

