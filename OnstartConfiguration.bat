

::::ONSTART ONLY!::::
:: These are things that should always be done ONSTART, but are too big to fit into a Scheduled Task.

:: Fix the PostGres bug that breaks FME Server
:: Kill postgres.exe that is being run by SYSTEM. That is the cause of FME Server failing on first boot.
:: https://technet.microsoft.com/en-us/library/bb491009.aspx
:: Restart FME Server Database, because it doesn't start properly 1 time in 5 when first booting
taskkill /f /t /fi "USERNAME eq SYSTEM" /im postgres.exe
net stop "FME Server Database" >> c:\temp\FMEServerRestart.log
net start "FME Server Database" >> c:\temp\FMEServerRestart.log

::This is a test of GitHUb
::test

:: Ken's Email Configuration
:: Remember to handle the FMW file.
net stop SMTPRelay
C:\apps\FME\fme.exe "C:\Users\Administrator\Documents\My FME Workspaces\SMTPConfigure.fmw"
copy C:\apps\FMEServer\Utilities\smtprelay\james\apps\james\SAR-INF\config_fme.xml C:\apps\FMEServer\Utilities\smtprelay\james\apps\james\SAR-INF\config.xml /Y
net start SMTPRelay

:: New Comment test
:: Another new comment
