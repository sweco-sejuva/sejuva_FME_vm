::This file does the initial configuration of the AWS instance; things that you only want to do once, like name the computer.
::Assuming that a T2.large is being used. Provide at least 70GB of storage.
::OnstartConfiguration is a copy of this, but with most commands DISABLED
::Download and run this from the (elevated?) command line (Win+R, CMD) by using the following command:
:: powershell -Command "Invoke-WebRequest https://raw.githubusercontent.com/rjcragg/AWS/master/InitialConfiguration.bat -OutFile InitialConfiguration.bat" && InitialConfiguration.bat
::OR use User Data when creating the EC2 instance. Past in the following script:
:: <script>powershell -Command "Invoke-WebRequest https://raw.githubusercontent.com/rjcragg/AWS/master/InitialConfiguration.bat -OutFile InitialConfiguration.bat" && InitialConfiguration.bat</script>

:main
	::::GENERAL SETTINGS FOR LATER IN BATCH FILE, and run procedures::::
		set OnstartConfigurationURL=https://raw.githubusercontent.com/rjcragg/AWS/master/OnstartConfiguration.bat
		set LICENSEIP=172.30.1.27
		set SERIAL=UJRD-A7PQ-166X
		::set SAFE_LICENSE_FILE=@%LICENSEIP%
		set EC2PASSWORD=FME2016learnings
		set PORTFORWARDING=81;82;443;8080;8081
		set FMEDESKTOPURL=https://s3.amazonaws.com/downloads.safe.com/fme/2016/fme_eval.msi
		set FMEDESKTOP64URL=https://s3.amazonaws.com/downloads.safe.com/fme/2016/win64/fme_eval.msi
		set FMESERVERURL=http://downloads.safe.com/fme/2016/fme-server-b16492-win-x86.msi
		set FMEDATAURL=https://cdn.safe.com/training/sample-data/FME-Sample-Dataset-Full.zip
		set ARCGISURL=https://s3.amazonaws.com/FME-Installers/ArcGIS10.3.1-20150220.zip
		set NEWCOMPUTERNAME=FMETraining

		set DISABLED=::
		set LOG=c:\temp\InitialConfiguration.log
		set TEMP=c:\temp
	::Make required folders
		md %TEMP%
		pushd %TEMP%
	:::::::::::::::::Here are the procedure calls:::::::::::::::::
	::Create an XML file needed for the task scheduler
		call :idlexml > idle.xml
	:: Start Logging, and call sub routines for configuring the computer
	::basicSetup sets things like license files. Always necessary
		call :basicSetup > %LOG%
	::ec2Setup sets things like computer password, timezone, etc.  Not necessary for non-ec2 training machines
		call :ec2Setup >> %LOG%
	::scheduleTasks sets up shutdown scripts, and additional startup tasks. Not neccessary for non-ec2 training machines
		call :scheduleTasks >> %LOG%
	::helpfulApps are applications that are helpful. Always necessary
		call :helpfulApps >> %LOG%
	::installFME installs FME 32 and 64 bit, and FME Server
		call :installFME >> %LOG%
	::downloadArcGIS downloads the ArcGIS installer and unzips it
		call :downloadArcGIS >> %LOG%
	::oracle installs 32-bit and 64-bit Oracle Instant Clients
		call :oracle >> %LOG%
	::shut down the computer
		call :shutdown >> %LOG%
goto :eof

:::::::::::::::::Everything below here are sub routines:::::::::::::::::
:basicSetup
		echo "Starting Downloading, Installing, and Configuring"
	:: Log that variables are set correctly
		echo "Variables are set to:"
		set
	::Set some SYSTEM environment variables. Dropped this because it didn't play nice with FME Server
	::	setx /m SAFE_LICENSE_FILE %SAFE_LICENSE_FILE%
	::	setx /m FME_USE_LM_ENVIRONMENT YES 
	::We should make sure port 80 is open too, for FME Server. This might be unnecessary
		netsh firewall add portopening TCP 80 "FME Server"
	::We should make sure port 25 is open too, for FME Server. Necessary for SMTP forwarding
		netsh firewall add portopening TCP 25 "SMTP"
	::We also need to open the port for UltraVNC. The installer fails to do that
		netsh firewall add portopening TCP 5900 "VNC"
	::FME Server needs port 7078 opened for web sockets
		netsh firewall add portopening TCP 7078 "WebSockets"
goto :eof

:ec2Setup
	::::CONFIGURE WINDOWS SETTINGS::::
	:: Set the time zone
		tzutil /s "Pacific Standard Time"
	:: The purpose of this section is to configure proxy ports for Remote Desktop
	:: It must be run with elevated permissions (right-click and run as administrator)
	:: The batch file assumes the computer name will not change.
	:: Be sure to also open the listed ports in the EC2 security group
	:: The ports to be set are in PORTFORWARDING:
	:: First, we reset the existing proxy ports.
		netsh interface portproxy reset
	:: Now we set the proxy ports and add them to the firewall
		for %%f IN (%PORTFORWARDING%) DO (
			netsh interface portproxy add v4tov4 listenport=%%f connectport=3389 connectaddress=%NEWCOMPUTERNAME%
			netsh firewall add portopening TCP %%f "Remote Desktop Port Proxy"
		)
	::Set Computer Name. This will require a reboot. Reboot is at the end of this batch file.
		wmic computersystem where name="%COMPUTERNAME%" call rename name="%NEWCOMPUTERNAME%"
	::Set Password for Administrator. I hate password complexity requiremens, but they can't be changed from the command line.
		net user Administrator %EC2PASSWORD%
	::Make sure password does not expire.
		WMIC USERACCOUNT WHERE "Name='administrator'" SET PasswordExpires=FALSE
goto :eof

:scheduleTasks
	::::SCHEDULED TASKS::::
	:: It's a very good idea to limit how long an instance will run for. Leaving them for weeks at a time is bad
	::Create the Scheduled tasks. Shut down machine if not logged onto within 24 (cancelled on logon by another task) or 56 hours.
	::Remember to FORCE schedule task creation--otherwise you'll be prompted. 
	::Create the Shutdowns
		schtasks /Create /F /RU SYSTEM /TN FirstAutoShutdown /SC ONSTART /DELAY 1440:00 /TR "C:\Windows\System32\shutdown.exe /s"
		::schtasks /create /xml "idle.xml" /tn "IdleShutdown"
	::On Logon, Disable the FirstAutoShutdown
		schtasks /Create /F /RU SYSTEM /TN DisableAutoShutdown /SC ONLOGON /TR "schtasks /Change /Disable /TN "FirstAutoShutdown""
		::schtasks /Create /F /RU SYSTEM /TN DisableIdleShutdown /SC ONLOGON /TR "schtasks /Change /Disable /TN "IdleShutdown""
	::Then, re-enable FirstAutoShutdown so I don't have to worry about it when creating the AMI
		schtasks /Create /F /RU SYSTEM /TN EnableAutoShutdown /SC ONLOGON /DELAY 0004:00 /TR "schtasks /Change /Enable /TN "FirstAutoShutdown""
		::schtasks /Create /F /RU SYSTEM /TN EnableIdleShutdown /SC ONLOGON /DELAY 0005:00 /TR "schtasks /Change /Enable /TN "IdleShutdown"" 
	::Create scheduled task that downloads and runs the other batch file. User aria2--bitsadmin doesn't play well with scheduled tasks
	::Get the other batch file and run it.
		::schtasks /Create /F /RU SYSTEM /TN OnstartConfigurationSetup /SC ONSTART /TR "aria2c.exe %OnstartConfigurationURL% --dir=/temp --allow-overwrite=true"
		::schtasks /Create /F /RU SYSTEM /TN OnstartConfigurationRun /SC ONSTART /DELAY 0001:00 /TR "c:/temp/OnstartConfiguration.bat"
		schtasks /Create /F /RU Administrator /RP %EC2PASSWORD% /TN OnstartConfiguration /SC ONSTART /TR "cmd.exe /C aria2c.exe %OnstartConfigurationURL% --dir=/temp --allow-overwrite=true && c:\temp\OnstartConfiguration.bat"
	::The VNC Scheduled Task is created when installing VNC, in the INSTALL SOFTWARE section
goto :eof

:helpfulApps
	::::INSTALL SOFTWARE::::
	::Install Chocolatey  https://chocolatey.org/
		 @powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
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
		choco install aria2 notepadplusplus google-chrome-x64 firefox adobereader ultravnc googleearth windirstat unzip git python eclipse -y
	::Create a scheduled task to start VNCServer. If it is a service, you have to log in, and that kicks out the student
		"C:\Program Files\uvnc bvba\UltraVNC\winvnc.exe -remove"
		"C:\Program Files\uvnc bvba\UltraVNC\setpasswd.exe" safevnc safevnc2 
		schtasks /Create /F /TN UltraVNCServer /SC ONLOGON /TR "C:\Program Files\uvnc bvba\UltraVNC\winvnc.exe"
goto :eof

:installFME
	::Download the latest FMEData. This is done so that Ryan doesn't have to create a new AMI whenever there is just a small change in FMEData
	::Get the basic FMEData and unzip any updates into c:\
		aria2c %FMEDATAURL% --out=FMEData.zip --allow-overwrite=true
		unzip -u FMEData.zip -d c:\ 

	::The lastest FME Desktop Installers are available from http://www.safe.com/fme/fme-desktop/trial-download/download.php
		aria2c %FMEDESKTOPURL% --out=FMEDesktop.msi --allow-overwrite=true
		aria2c %FMEDESKTOP64URL% --out=FMEDesktop64.msi --allow-overwrite=true 
	::The lastest FME Server Installers are available from http://www.safe.com/fme/fme-server/trial-download/download.php
		aria2c %FMESERVERURL%  --out=FMEServer.msi --allow-overwrite=true
	:: Silent install of FME Desktop follows the form of:
	::msiexec /i fme-desktop-b15475-win-x86.msi /qb INSTALLLEVEL=3 INSTALLDIR="c:\apps\fme" ENABLE_POST_INSTALL_TASKS=no
		msiexec /i FMEDesktop.msi /qb INSTALLLEVEL=3 INSTALLDIR="c:\apps\FME" ENABLE_POST_INSTALL_TASKS=no
		c:\apps\fme\fme\fmelicensingassistant_cmd.exe --floating %LICENSEIP% smallworld
		msiexec /i FMEDesktop64.msi /qb INSTALLLEVEL=3 INSTALLDIR="c:\Program Files\FME" ENABLE_POST_INSTALL_TASKS=no
		"c:\Program Files\fme\fmelicensingassistant_cmd.exe" --floating %LICENSEIP% smallworld
	:: Silent install of FME Server:
		msiexec /i fmeserver.msi /qb /norestart /l*v installFMEServerLog.txt FMESERVERHOSTNAME=localhost
	:: License FME Server
		c:\apps\fmeserver\server\fme\fmelicensingassistant_cmd.exe --serial %SERIAL%
	::Install Beta.  Comment this out.
	::aria2c https://s3.amazonaws.com/FME-Installers/fme-desktop-b16016-win-x86.msi
	::msiexec /i fme-desktop-b16016-win-x86.msi /qb INSTALLLEVEL=3 INSTALLDIR="c:\apps\FME2016" ENABLE_POST_INSTALL_TASKS=no

goto :eof

:downloadArcGIS
	::Might be nice to have the lastest ArcGIS installer downloaded and ready to go.
		aria2c %ARCGISURL% --out=ARCGIS.zip --allow-overwrite=true
		unzip -u ARCGIS.zip -d %TEMP%
	:: Silent Install ArcGIS?
	::Silent Install of PostGreSQL/PostGIS?
goto :eof

:oracle
	::Install the 64 and 32 bit Oracle Instant Clients
		aria2c https://s3.amazonaws.com/FMETraining/instantclient-basiclite-nt-12.1.0.2.0.zip --out=Oracle32InstantClient.zip --allow-overwrite=true
		aria2c https://s3.amazonaws.com/FMETraining/instantclient-basiclite-windows.x64-12.1.0.2.0.zip --out=Oracle64InstantClient.zip --allow-overwrite=true
		unzip -u Oracle32InstantClient.zip -d c:\Oracle32InstantClient
		unzip -u Oracle64InstantClient.zip -d c:\Oracle64InstantClient
		setx /m PATH "%PATH%;C:\Oracle32InstantClient\instantclient_12_1;c:\Oracle64InstantClient\instantclient_12_1"
goto :eof

:shutdown
	::Shutdown the computer
		echo Finished the Initial Configuration
		echo Done! %date% %time% 
		shutdown /s /t 1
goto :eof

:idlexml
::The idle shutdown is tricky to create; it requires an XML file which we create in a subroutine
::If the echo is on, the XML will be malformed
@echo off
echo ^<?xml version="1.0" encoding="UTF-16"?^>
echo ^<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"^>
echo   ^<RegistrationInfo^>
echo     ^<Date^>2015-10-02T15:47:19.2075945^</Date^>
echo     ^<Author^>Administrator^</Author^>
echo   ^</RegistrationInfo^>
echo   ^<Triggers^>
echo     ^<SessionStateChangeTrigger^>
echo       ^<Enabled^>true^</Enabled^>
echo       ^<StateChange^>RemoteDisconnect^</StateChange^>
echo       ^<Delay^>PT1440M0S^</Delay^>
echo     ^</SessionStateChangeTrigger^>
echo   ^</Triggers^>
echo   ^<Principals^>
echo     ^<Principal id="Author"^>
echo       ^<UserId^>S-1-5-18^</UserId^>
echo       ^<RunLevel^>LeastPrivilege^</RunLevel^>
echo     ^</Principal^>
echo   ^</Principals^>
echo   ^<Settings^>
echo     ^<MultipleInstancesPolicy^>IgnoreNew^</MultipleInstancesPolicy^>
echo     ^<DisallowStartIfOnBatteries^>true^</DisallowStartIfOnBatteries^>
echo     ^<StopIfGoingOnBatteries^>true^</StopIfGoingOnBatteries^>
echo     ^<AllowHardTerminate^>true^</AllowHardTerminate^>
echo     ^<StartWhenAvailable^>false^</StartWhenAvailable^>
echo     ^<RunOnlyIfNetworkAvailable^>false^</RunOnlyIfNetworkAvailable^>
echo     ^<IdleSettings^>
echo       ^<StopOnIdleEnd^>true^</StopOnIdleEnd^>
echo       ^<RestartOnIdle^>false^</RestartOnIdle^>
echo     ^</IdleSettings^>
echo     ^<AllowStartOnDemand^>true^</AllowStartOnDemand^>
echo     ^<Enabled^>true^</Enabled^>
echo     ^<Hidden^>false^</Hidden^>
echo     ^<RunOnlyIfIdle^>false^</RunOnlyIfIdle^>
echo     ^<WakeToRun^>false^</WakeToRun^>
echo     ^<ExecutionTimeLimit^>P3D^</ExecutionTimeLimit^>
echo     ^<Priority^>7^</Priority^>
echo   ^</Settings^>
echo   ^<Actions Context="Author"^>
echo     ^<Exec^>
echo       ^<Command^>C:\Windows\System32\shutdown.exe^</Command^>
echo       ^<Arguments^>/s /f^</Arguments^>
echo     ^</Exec^>
echo   ^</Actions^>
echo ^</Task^>
@echo on
@goto :eof


