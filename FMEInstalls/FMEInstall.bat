@echo off
pushd c:\temp

:check
IF %1.==. GOTO ask
IF %2.==. GOTO ask

set FMEYEAR=%1
set FMEBUILD=%2
goto work

:ask
set /P FMEYEAR=Enter Year of FME Release:
set /P FMEBUILD=Enter FME Build Number:
goto work

:work
aria2c http://downloads.safe.com/fme/%FMEYEAR%/fme-desktop-b%FMEBUILD%-win-x86.msi --allow-overwrite=true
aria2c http://downloads.safe.com/fme/%FMEYEAR%/fme-desktop-b%FMEBUILD%-win-x64.msi --allow-overwrite=true
aria2c http://downloads.safe.com/fme/%FMEYEAR%/fme-server-b%FMEBUILD%-win-x86.msi --allow-overwrite=true

msiexec /i fme-desktop-b%FMEBUILD%-win-x86.msi /qb INSTALLLEVEL=3 INSTALLDIR="c:\apps\FME" ENABLE_POST_INSTALL_TASKS=no
msiexec /i fme-desktop-b%FMEBUILD%-win-x64.msi /qb INSTALLLEVEL=3 INSTALLDIR="c:\Program Files\FME" ENABLE_POST_INSTALL_TASKS=no
msiexec /i fme-server-b%FMEBUILD%-win-x86.msi /qb /norestart /l*v installFMEServerLog.txt FMESERVERHOSTNAME=localhost

exit /b