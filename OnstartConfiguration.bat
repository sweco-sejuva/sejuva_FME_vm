::::ONSTART ONLY!::::
:: These are things that should always be done ONSTART, but are too big to fit into a Scheduled Task.

:: Set the VM password. That way you don't need to create a new VM just to update the password.
:: Fix the PostGres bug that breaks FME Server
:: Kill postgres.exe that is being run by SYSTEM. That is the cause of FME Server failing on first boot.
:: https://technet.microsoft.com/en-us/library/bb491009.aspx
:: Restart FME Server Database, because it doesn't start properly 1 time in 5 when first booting

:: Set all the required variables
	set LOG=c:\temp\OnstartConfiguration.log
	set SMTP=https://s3.amazonaws.com/FMETraining/SMTPConfigure.fmw
	set RDP=https://s3.amazonaws.com/FMETraining/ZippedRDPFileCreator.fmw
	set FMEDATAURL=http://s3.amazonaws.com/FMEData/FMEData2018.zip
	set OnLogonConfigurationURL=https://raw.githubusercontent.com/rjcragg/AWS/master/OnLogonConfiguration.bat
::	set VM_PASSWORD=FME2016learnings

call :sub > %LOG%
call :vnc >>%LOG%
exit /b

:sub
::Get into the correct folder
	pushd c:\temp

::Set the password and VNC password
::	net user Administrator %VM_PASSWORD%
::	"C:\Program Files\uvnc bvba\UltraVNC\setpasswd.exe" %VM_PASSWORD% %VM_PASSWORD%V
	
::Get any extra chocolatey stuff (install any additional applications that you forgot when first creating the instance)
::I'm moving to 7zip for command line unzipping. Not yet on default instances
	choco install 7zip -y

::Create the OnLogon scheduled task to run OnLogon.bat
	schtasks /Create /F /RU SYSTEM /TN OnLogonConfiguration /SC ONLOGON /TR "cmd.exe /C aria2c.exe %OnLogonConfigurationURL% --dir=/temp --allow-overwrite=true && c:\temp\OnLogonConfiguration.bat

:: Ken's Email Configuration
:: Remember to handle the FMW file.
::net stop SMTPRelay
::aria2c %SMTP% --allow-overwrite=true
::C:\apps\FME\fme.exe "c:\temp\SMTPConfigure.fmw"
::copy C:\apps\FMEServer\Utilities\smtprelay\james\apps\james\SAR-INF\config_fme.xml C:\apps\FMEServer\Utilities\smtprelay\james\apps\james\SAR-INF\config.xml /Y
::net start SMTPRelay

::Adding URLs to the desktop is the preferred way of giving students their manuals. Ensures that everyone is using the same manuals
:: Add the URLs to c:\users\public\desktop. That way everyone gets it.
::Database Connections URL
	echo [InternetShortcut] > "c:\users\public\desktop\Database Connection Parameters.url"
	echo URL=http://fme.ly/database >>"c:\users\public\desktop\Database Connection Parameters.url"

:: FME Desktop Course Resources
	echo [InternetShortcut] > "c:\users\public\desktop\FME Desktop Course Resources.url"
	echo URL=https://knowledge.safe.com/content/kbentry/25216/fme-desktop-basic-training-course-resources.html >>"c:\users\public\desktop\FME Desktop Course Resources.url"

:: FME Server Course Resources
	echo [InternetShortcut] > "c:\users\public\desktop\FME Server Course Resources.url"
	echo URL=https://knowledge.safe.com/content/kbentry/28253/fme-server-authoring-training-course-resources.html >> "c:\users\public\desktop\FME Server Course Resources.url"


:: FME Server Course Resources
	echo [InternetShortcut] > "c:\users\public\desktop\FME Esri Course Resources.url"
	echo URL=https://knowledge.safe.com/articles/30330/fme-desktop-for-esri-training-course-resources.html >> "c:\users\public\desktop\FME Esri Course Resources.url"

:: FME for Smallworld Course Resources
	echo [InternetShortcut] > "c:\users\public\desktop\FME Smallworld Course Resources.url"
	echo URL=https://knowledge.safe.com/articles/48300/index.html >> "c:\users\public\desktop\FME Smallworld Course Resources.url"


:: Your Computer DNS Name
	echo [InternetShortcut] > "c:\users\public\desktop\Your Computer DNS Name.url"
	echo URL=http://169.254.169.254/latest/meta-data/public-hostname >>"c:\users\public\desktop\Your Computer DNS Name.url"

:: Put the latest FME Server PDF manual on the desktop
	aria2c https://www.gitbook.com/download/pdf/book/safe-software/fme-server-training-2017 --allow-overwrite=true
	copy *.pdf c:\users\public\desktop\ /Y

:: Open Ports, if necessary.
::VNC Port
	netsh firewall add portopening TCP 5800 "VNC"

::update FMEData
	aria2c %FMEDATAURL% --out=FMEData2017.zip --allow-overwrite=true
	7z x -oc:\ -aoa FMEData2017.zip

::Add any additional large files and stuff for the FME2017UC
::aria2c https://s3.amazonaws.com/FMEData/FMEUC2017/RasterTraining.zip --out=RasterTraining.zip --allow-overwrite=true
::unzip -uo RasterTraining.zip -d c:\FMEData2017\Resources\Raster\
::aria2c https://s3.amazonaws.com/FMETraining/Installers/CreateNewCustomer.fmx --dir=C:\Users\Administrator\Documents\FME\Transformers\ --out=CreateNewCustomer.fmx --allow-overwrite=true
::aria2c https://s3.amazonaws.com/FMETraining/Installers/FloodPolygonExtractor.fmx --dir=C:\Users\Administrator\Documents\FME\Transformers\ --out=FloodPolygonExtractor.fmx --allow-overwrite=true

:: Configure the TaskBar
	call :taskbarPinning >taskbarPinning.ps1
	powershell -NoProfile -executionpolicy bypass -File taskbarPinning.ps1

:: Download FME uninstaller and installer
	aria2c https://github.com/rjcragg/AWS/raw/master/FMEInstalls/FMEInstall.bat --allow-overwrite=true
	aria2c https://github.com/rjcragg/AWS/raw/master/FMEInstalls/FMEUninstall.bat --allow-overwrite=true

::Steve's database stuff
::	net start OracleServiceXE
::	net start OracleXETNSListner
::	aria2c https://s3.amazonaws.com/FMEData/FMEUC2017/1.CreateDatabase.fmw --allow-overwrite=true
::	C:\apps\FME\fme.exe "c:\temp\1.CreateDatabase.fmw"


:: FME Server sometimes doesn't like to start properly. Halt it and try again here
	taskkill /f /t /fi "USERNAME eq SYSTEM" /im postgres.exe
	net stop "FME Server Engines"
	net stop "FME Server Core" /y
	net stop FMEServerAppServer
	net stop "FME Server Database"

	net start FMEServerAppServer
	net start "FME Server Database"
	net start "FME Server Core"
	net start "FME Server Engines"

:: Indicate the end of the log file.
	echo "Onstart Configuration complete"
	goto :eof

:vnc
    taskkill /f /t /fi "USERNAME eq SYSTEM" /im winvnc.exe
    net stop "uvnc_service"
    echo "C:\Program Files\uvnc bvba\UltraVNC\setpasswd.exe" safevnc safevnc2 > "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\vncpassword.bat"
    xcopy "C:\Users\Administrator\Desktop\UltraVNC Server.lnk" "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp" /y
goto :eof

:taskbarPinning
@echo off
echo $sa = new-object -c shell.application
echo $pn = $sa.namespace('c:\program files\fme').parsename('fmeworkbench.exe')
echo $pn.invokeverb('taskbarpin')

echo $sa = new-object -c shell.application
echo $pn = $sa.namespace('c:\program files\fme').parsename('fmedatainspector.exe')
echo $pn.invokeverb('taskbarpin')

::echo $sa = new-object -c shell.application
::echo $pn = $sa.namespace('c:\windows\system32').parsename('ServerManager.exe')
::echo $pn.invokeverb('taskbarunpin')

::echo $sa = new-object -c shell.application
::echo $pn = $sa.namespace('C:\Windows\System32\WindowsPowerShell\v1.0').parsename('powershell.exe')
::echo $pn.invokeverb('taskbarunpin')

@echo on
@goto :eof

