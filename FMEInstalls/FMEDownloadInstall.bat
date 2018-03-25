pushd c:\temp

del fme-desktop*.msi
del fme-server*.msi
aria2c https://bluesky-safe-software.fmecloud.com/fmedatastreaming/FMETraining/DownloadList.fmw --out=FMEs.txt --allow-overwrite=true 
aria2c -i FMEs.txt --allow-overwrite=true
for %%f in (fme-desktop*.msi) do msiexec /i %%f /qb INSTALLLEVEL=3 INSTALLDIR="c:\Program Files\FME" ENABLE_POST_INSTALL_TASKS=no
for %%f in (fme-server*.msi) do msiexec /i %%f /qb /norestart /l*v installFMEServerLog.txt FMESERVERHOSTNAME=localhost

"c:\Program Files\fme\fmelicensingassistant_cmd.exe" --floating %fmelicenseip% smallworld
	
"c:\Program Files\fmeserver\server\fme\fmelicensingassistant_cmd.exe" --serial %fmeserverserial%
