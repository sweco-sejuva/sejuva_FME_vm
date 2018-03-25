
::make sure you are in TEMP
md c:\temp
pushd c:\temp

:: clean up existing installers
del fme-desktop*.msi
del fme-server*.msi

::download new installers
aria2c https://bluesky-safe-software.fmecloud.com/fmedatastreaming/FMETraining/DownloadList.fmw --out=FMEs.txt --allow-overwrite=true 
aria2c -i FMEs.txt --allow-overwrite=true

::install FME Desktop and Server
for %%f in (fme-desktop*.msi) do msiexec /i %%f /qb INSTALLLEVEL=3 INSTALLDIR="c:\Program Files\FME" ENABLE_POST_INSTALL_TASKS=no
for %%f in (fme-server*.msi) do msiexec /i %%f /qb /norestart /l*v installFMEServerLog.txt FMESERVERHOSTNAME=localhost

::License FME Desktop and Server. These should be existing environment variables.
"c:\Program Files\fme\fmelicensingassistant_cmd.exe" --floating %FMELICENSEIP% smallworld	
"c:\Program Files\fmeserver\server\fme\fmelicensingassistant_cmd.exe" --serial %FMESERVERSERIAL%
