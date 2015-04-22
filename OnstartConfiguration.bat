

::::ONSTART ONLY!::::
:: These are things that should always be done ONSTART, but are too big to fit into a Scheduled Task.

:: Fix the PostGres bug that breaks FME Server
:: Kill postgres.exe that is being run by SYSTEM. That is the cause of FME Server failing on first boot.
:: https://technet.microsoft.com/en-us/library/bb491009.aspx
:: Restart FME Server Database, because it doesn't start properly 1 time in 5 when first booting

set LOG=c:\temp\OnstartConfiguration.log
set SSD=z:
set SMTP=https://s3.amazonaws.com/FMETraining/SMTPConfigure.fmw
set RDP=https://s3.amazonaws.com/FMETraining/ZippedRDPFileCreator.fmw

::Create the RDP files to connect to this instance
:: RDPFiles.zip can then be downloaded from <ip address>\examples\RDPFiles.zip
aria2c %RDP% --out="%TEMP%\ZippedRDPFileCreator.fmw" --allow-overwrite=true >> %LOG%
C:\apps\FME\fme.exe "%TEMP%\ZippedRDPFileCreator.fmw" >> %LOG%

taskkill /f /t /fi "USERNAME eq SYSTEM" /im postgres.exe > %LOG%
net stop "FME Server Database" >> %LOG%
net start "FME Server Database" >> %LOG%


:: Ken's Email Configuration
:: Remember to handle the FMW file.
net stop SMTPRelay >> %LOG%
aria2c %SMTP% --out="%TEMP%\SMTPConfigure.fmw" --allow-overwrite=true >> %LOG%
C:\apps\FME\fme.exe "%TEMP%\SMTPConfigure.fmw" >> %LOG%
copy C:\apps\FMEServer\Utilities\smtprelay\james\apps\james\SAR-INF\config_fme.xml C:\apps\FMEServer\Utilities\smtprelay\james\apps\james\SAR-INF\config.xml /Y >> %LOG%
net start SMTPRelay >> %LOG%

::Copy FMEDATA onto the SSD drive for better performance, or backup.
for /f "delims=" %%a in ('dir /b/ad "c:\fmedata*" ') robocopy c:\%%a %SSD%\%%a /E >> %LOG%

::Warn people not to put permanent stuff on the SSD drive.
echo "This is a temporary drive. It is deleted upon shutdown. Use with caution" > "%SSD%\This is a temporary drive.txt"

