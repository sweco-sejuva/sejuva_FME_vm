::This file does the initial configuration of the AWS instance for Server Certification; things that you only want to do once, like name the computer.
::Assuming that a T2.large is being used. Provide at least 70GB of storage.
::Should take less than 30 minutes to complete.
::use User Data when creating the EC2 instance. Past in the following script:
:: <script>powershell -Command "Invoke-WebRequest https://raw.githubusercontent.com/rjcragg/AWS/2016/ServerCertification.bat -OutFile ServerCertification.bat" && ServerCertification.bat</script>

:main
	::::GENERAL SETTINGS FOR LATER IN BATCH FILE, and run procedures::::
		set EC2PASSWORD=FME2016learnings
		set FMESERVERURL=http://downloads.safe.com/fme/2015/fme-server-2015.1.3-win-x86.msi
		set FMEDATAURL=https://s3.amazonaws.com/FMEData/FMEData2016.zip

		set LOG=c:\temp\InitialConfiguration.log
		set TEMP=c:\temp
	::Make required folders
		md %TEMP%
		pushd %TEMP%
	:::::::::::::::::Here are the procedure calls:::::::::::::::::
	:: Start Logging, and call sub routines for configuring the computer
	::basicSetup sets things like license files. Always necessary
		call :basicSetup > %LOG%
	::ec2Setup sets things like computer password, timezone, etc.  Not necessary for non-ec2 training machines
		call :ec2Setup >> %LOG%
	::helpfulApps are applications that are helpful. Always necessary
		call :helpfulApps >> %LOG%
	::installFME installs FME 32 and 64 bit, and FME Server
		call :installFME >> %LOG%
	::downloadArcGIS downloads the ArcGIS installer and unzips it
	::shut down the computer
		call :shutdown >> %LOG%
goto :eof

:::::::::::::::::Everything below here are sub routines:::::::::::::::::
:basicSetup
		echo "Starting Downloading, Installing, and Configuring"
	:: Log that variables are set correctly
		echo "Variables are set to:"
		set
goto :eof

:ec2Setup
	::::CONFIGURE WINDOWS SETTINGS::::
	:: Set the time zone
		tzutil /s "Pacific Standard Time"
	::Set Computer Name. This will require a reboot. Reboot is at the end of this batch file.
		wmic computersystem where name="%COMPUTERNAME%" call rename name="FMETraining"
	::Set Password for Administrator. I hate password complexity requiremens, but they can't be changed from the command line.
		net user Administrator %EC2PASSWORD%
	::Make sure password does not expire.
		WMIC USERACCOUNT WHERE "Name='administrator'" SET PasswordExpires=FALSE
goto :eof



:helpfulApps
	::::INSTALL SOFTWARE::::
	::Install Chocolatey  https://chocolatey.org/
		@powershell -NoProfile -ExecutionPolicy unrestricted -Command "(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))) >$null 2>&1" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
	:: Chocolatey allows you to specify what you want on a single line. Let's try that
	::Bitsadmin does not work in a scheduled task. Install aria2. It is amazingly fast.
	::We'll need to unzip stuff eventually so get devbox-unzip
	::I'm sure GIT will be useful at some point
	::WinDirStat is useful for finding what is taking up drive space.
	::UltraVNC is useful when helping students troubleshoot. Why 2 passwords? The first is for full control; the second is for view-only.
	::Google Chrome and Firefox are useful web browsers
	::Adobe Reader is used to read manuals
	::Notepad++ is great for text editing
	::Google Earth is useful
	::Install Python and Eclipse
		choco install aria2 notepadplusplus google-chrome-x64 firefox adobereader ultravnc googleearth windirstat devbox-unzip git python eclipse -y
	::Create a scheduled task to start VNCServer. If it is a service, you have to log in, and that kicks out the student
		"C:\Program Files\uvnc bvba\UltraVNC\setpasswd.exe" safevnc safevnc2 
		schtasks /Create /F /TN UltraVNCServer /SC ONLOGON /TR "C:\Program Files\uvnc bvba\UltraVNC\winvnc.exe"
goto :eof

:installFME
	::Download the latest FMEData. This is done so that Ryan doesn't have to create a new AMI whenever there is just a small change in FMEData
	::Get the basic FMEData and unzip any updates into c:\
		aria2c %FMEDATAURL% --out=FMEData.zip --allow-overwrite=true
		unzip -u FMEData.zip -d c:\ 

	::The lastest FME Server Installers are available from http://www.safe.com/fme/fme-server/trial-download/download.php
		aria2c %FMESERVERURL%  --out=FMEServer.msi --allow-overwrite=true

	:: Silent install of FME Server:
		msiexec /i fmeserver.msi /qb /norestart /l*v installFMEServerLog.txt FMESERVERHOSTNAME=localhost

goto :eof

:shutdown
	::Shutdown the computer
		echo Finished the Initial Configuration
		echo Done! %date% %time% 
		shutdown /s /t 1
goto :eof

