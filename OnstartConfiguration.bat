::::ONSTART ONLY!::::
:: These are things that should always be done ONSTART, but are too big to fit into a Scheduled Task.

:: Fix the PostGres bug that breaks FME Server
:: Kill postgres.exe that is being run by SYSTEM. That is the cause of FME Server failing on first boot.
:: https://technet.microsoft.com/en-us/library/bb491009.aspx
:: Restart FME Server Database, because it doesn't start properly 1 time in 5 when first booting
:: Create the RDP files to connect to this instance
:: RDPFiles.zip can then be downloaded from <ip address>\examples\RDPFiles.zip

set LOG=c:\temp\OnstartConfiguration.log
set SSD=z:
set SMTP=https://s3.amazonaws.com/FMETraining/SMTPConfigure.fmw
set RDP=https://s3.amazonaws.com/FMETraining/ZippedRDPFileCreator.fmw

call :sub > %LOG%
exit /b

:sub
pushd c:\temp

aria2c %RDP% --allow-overwrite=true
C:\apps\FME\fme.exe "c:\temp\ZippedRDPFileCreator.fmw"

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

::Copy FMEDATA onto the SSD drive for better performance, or backup.
for /f "delims=" %%a in ('dir /b/ad "c:\fmedata*" ') do robocopy c:\%%a %SSD%\%%a /E

::Warn people not to put permanent stuff on the SSD drive.
echo "This is a temporary drive. It is deleted upon shutdown. Use with caution" > "%SSD%\This is a temporary drive.txt"

::Adding URLs to the desktop is the preferred way of giving students their manuals. Ensures that everyone is using the same manuals
::Database Connections URL
echo [InternetShortcut] > "c:\users\default\desktop\Database Connection Parameters.url"
echo URL=http://fme.ly/database >>"c:\users\default\desktop\Database Connection Parameters.url"

:: FME Desktop Course Resources
echo [InternetShortcut] > "c:\users\default\desktop\FME Desktop Course Resources.url"
echo URL=http://fme.ly/course >>"c:\users\default\desktop\FME Desktop Course Resources.url"

:: Your Computer DNS Name
echo [InternetShortcut] > "c:\users\default\desktop\Your Computer DNS Name.url"
echo URL=http://169.254.169.254/latest/meta-data/public-hostname >>"c:\users\default\desktop\Your Computer DNS Name.url"


:: Indicate the end of the log file.
echo "Onstart Configuration complete"

