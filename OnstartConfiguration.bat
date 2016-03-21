::::ONSTART ONLY!::::
:: These are things that should always be done ONSTART, but are too big to fit into a Scheduled Task.

:: Fix the PostGres bug that breaks FME Server
:: Kill postgres.exe that is being run by SYSTEM. That is the cause of FME Server failing on first boot.
:: https://technet.microsoft.com/en-us/library/bb491009.aspx
:: Restart FME Server Database, because it doesn't start properly 1 time in 5 when first booting
:: Create the RDP files to connect to this instance
:: RDPFiles.zip can then be downloaded from <ip address>\examples\RDPFiles.zip

set LOG=c:\temp\OnstartConfiguration.log
set SMTP=https://s3.amazonaws.com/FMETraining/SMTPConfigure.fmw
set RDP=https://s3.amazonaws.com/FMETraining/ZippedRDPFileCreator.fmw
set FMEDATAURL=https://cdn.safe.com/training/sample-data/FME-Sample-Dataset-Full.zip

call :sub > %LOG%
exit /b

:sub
pushd c:\temp

:: RDP creation is now done using Bluesky.
::aria2c %RDP% --allow-overwrite=true
::C:\apps\FME\fme.exe "c:\temp\ZippedRDPFileCreator.fmw"

taskkill /f /t /fi "USERNAME eq SYSTEM" /im postgres.exe
net stop "FME Server Database"
net start "FME Server Database"


:: Ken's Email Configuration
:: Remember to handle the FMW file.
net stop SMTPRelay
aria2c %SMTP% --allow-overwrite=true
C:\apps\FME\fme.exe "c:\temp\SMTPConfigure.fmw"
copy C:\apps\FMEServer\Utilities\smtprelay\james\apps\james\SAR-INF\config_fme.xml C:\apps\FMEServer\Utilities\smtprelay\james\apps\james\SAR-INF\config.xml /Y
net start SMTPRelay

::Adding URLs to the desktop is the preferred way of giving students their manuals. Ensures that everyone is using the same manuals
:: Add the URLs to c:\users\public\desktop. That way everyone gets it.
::Database Connections URL
echo [InternetShortcut] > "c:\users\public\desktop\Database Connection Parameters.url"
echo URL=http://fme.ly/database >>"c:\users\public\desktop\Database Connection Parameters.url"

:: FME Desktop Course Resources
echo [InternetShortcut] > "c:\users\public\desktop\FME Desktop Course Resources.url"
echo URL=http://fme.ly/course >>"c:\users\public\desktop\FME Desktop Course Resources.url"

:: FME Server Course Resources
echo [InternetShortcut] > "c:\users\public\desktop\FME Server Course Resources.url"
echo URL=http://www.safe.com/learning/training/resource-center/fme-server-authoring >> "c:\users\public\desktop\FME Server Course Resources.url"

:: Your Computer DNS Name
echo [InternetShortcut] > "c:\users\public\desktop\Your Computer DNS Name.url"
echo URL=http://169.254.169.254/latest/meta-data/public-hostname >>"c:\users\public\desktop\Your Computer DNS Name.url"

::update FMEData
::aria2c %FMEDATAURL% --out=FMEData.zip --allow-overwrite=true
::unzip -uo FMEData.zip -d c:\ 

:: Indicate the end of the log file.
echo "Onstart Configuration complete"

