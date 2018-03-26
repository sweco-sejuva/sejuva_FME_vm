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
	set CurrentFMEDataDownloadURL=https://bluesky-safe-software.fmecloud.com/fmedatastreaming/FMETraining/CurrentFMEDataDownloadURL.fmw
::	set VM_PASSWORD=FME2016learnings

call :vnc > %LOG%
call :main >>%LOG%
exit /b

:vnc
    taskkill /f /t /fi "USERNAME eq SYSTEM" /im winvnc.exe
    net stop "uvnc_service"
    echo "C:\Program Files\uvnc bvba\UltraVNC\setpasswd.exe" safevnc safevnc2 > "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\vncpassword.bat"
    echo start "" "C:\Program Files\uvnc bvba\UltraVnc\winvnc.exe" >> "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\vncpassword.bat"
goto :eof

:main
::Get into the correct folder
	pushd c:\temp

::Create the OnLogon scheduled task to run OnLogon.bat
::	schtasks /Create /F /RU SYSTEM /TN OnLogonConfiguration /SC ONLOGON /TR "cmd.exe /C aria2c.exe %OnLogonConfigurationURL% --dir=/temp --allow-overwrite=true && c:\temp\OnLogonConfiguration.bat


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

::update FMEData
	aria2c %CurrentFMEDataDownloadURL% --out=CurrentFMEDataDownloadURL.txt --allow-overwrite=true
	aria2c -i CurrentFMEDataDownloadURL.txt --allow-overwrite=true
	for %%f in (FMEDATA*.zip) do 7z x -oc:\ -aoa %%f

:: Configure the TaskBar
	call :taskbarPinning >taskbarPinning.ps1
	powershell -NoProfile -executionpolicy bypass -File taskbarPinning.ps1

:: Download Current FME uninstaller and installer, and post creation steps.
	aria2c https://github.com/rjcragg/AWS/raw/master/FMEInstalls/FMEInstall.bat --allow-overwrite=true
	aria2c https://github.com/rjcragg/AWS/raw/master/FMEInstalls/FMEUninstall.bat --allow-overwrite=true
	aria2c https://github.com/rjcragg/AWS/raw/master/FMEInstalls/FMEDownloadInstall.bat --allow-overwrite=true
	aria2c https://github.com/rjcragg/AWS/raw/master/PostCreationSteps.txt --allow-overwrite=true
	
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

