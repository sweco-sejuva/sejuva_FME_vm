

::::ONSTART ONLY!::::
:: These are things that should always be done ONSTART, but are too big to fit into a Scheduled Task.

:: Fix the PostGres bug that breaks FME Server
:: Kill postgres.exe that is being run by SYSTEM. That is the cause of FME Server failing on first boot.
:: https://technet.microsoft.com/en-us/library/bb491009.aspx
:: Restart FME Server Database, because it doesn't start properly 1 time in 5 when first booting

set LOG=c:\temp\OnstartConfiguration.log
set SSD=z:\

taskkill /f /t /fi "USERNAME eq SYSTEM" /im postgres.exe > %LOG%
net stop "FME Server Database" >> %LOG%
net start "FME Server Database" >> %LOG%

::This is a test of GitHUb
::test

:: Ken's Email Configuration
:: Remember to handle the FMW file.
net stop SMTPRelay >> %LOG%
C:\apps\FME\fme.exe "C:\Users\Administrator\Documents\My FME Workspaces\SMTPConfigure.fmw" >> %LOG%
copy C:\apps\FMEServer\Utilities\smtprelay\james\apps\james\SAR-INF\config_fme.xml C:\apps\FMEServer\Utilities\smtprelay\james\apps\james\SAR-INF\config.xml /Y >> %LOG%
net start SMTPRelay >> %LOG%

::Copy FMEDATA onto the SSD drive for better performance, or backup.
for /f "delims=" %%a in ('dir /b/ad "c:\fmedata*" ') robocopy c:\%%a %SSD%\%%a /E >> %LOG%

::Warn people not to put permanent stuff on the SSD drive.
echo "This is a temporary drive. It is deleted upon shutdown. Use with caution" > "%SSD%\This is a temporary drive.txt"

