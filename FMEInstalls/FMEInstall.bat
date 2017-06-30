@echo off
pushd c:\temp

:check
IF %1.==. GOTO ask
IF %2.==. GOTO ask

set FMERELEASE=%1
set FMEBUILD=%2
goto work

:ask
set /P FMEYEAR=Enter FME Release (ie. 2017.1):
set /P FMEBUILD=Enter FME Build Number:
goto work

:work
set FMEYEAR=%FMEBUILD:~0,4%
aria2c http://downloads.safe.com/fme/%FMEYEAR%/fme-desktop-%FMERELEASE%-b%FMEBUILD%-win-x86.msi --allow-overwrite=true
aria2c http://downloads.safe.com/fme/%FMEYEAR%/fme-desktop-%FMERELEASE%-b%FMEBUILD%-win-x64.msi --allow-overwrite=true
aria2c http://downloads.safe.com/fme/%FMEYEAR%/fme-server-%FMERELEASE%-b%FMEBUILD%-win-x86.msi --allow-overwrite=true

msiexec /i fme-desktop-%FMERELEASE%-b%FMEBUILD%-win-x86.msi /qb INSTALLLEVEL=3 INSTALLDIR="c:\apps\FME" ENABLE_POST_INSTALL_TASKS=no
msiexec /i fme-desktop-%FMERELEASE%-b%FMEBUILD%-win-x64.msi /qb INSTALLLEVEL=3 INSTALLDIR="c:\Program Files\FME" ENABLE_POST_INSTALL_TASKS=no
msiexec /i fme-server-%FMERELEASE%-b%FMEBUILD%-win-x86.msi /qb /norestart /l*v installFMEServerLog.txt FMESERVERHOSTNAME=localhost

exit /b
