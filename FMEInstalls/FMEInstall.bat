::Turn of echo and get into C:\temp
@echo off
pushd c:\temp

::Prompt for year and build number
set /P FMEYEAR=Enter Year of FME Release:
set /P FMEBUILD=Enter FME Build Number:

::Download all the installers
aria2c http://downloads.safe.com/fme/%FMEYEAR%/fme-desktop-b%FMEBUILD%-win-x86.msi --allow-overwrite=true
aria2c http://downloads.safe.com/fme/%FMEYEAR%/fme-desktop-b%FMEBUILD%-win-x64.msi --allow-overwrite=true
aria2c http://downloads.safe.com/fme/%FMEYEAR%/fme-server-b%FMEBUILD%-win-x86.msi --allow-overwrite=true

::Run all the installers
msiexec /i fme-desktop-b%FMEBUILD%-win-x86.msi /qb INSTALLLEVEL=3 INSTALLDIR="c:\apps\FME" ENABLE_POST_INSTALL_TASKS=no
msiexec /i fme-desktop-b%FMEBUILD%-win-x64.msi /qb INSTALLLEVEL=3 INSTALLDIR="c:\Program Files\FME" ENABLE_POST_INSTALL_TASKS=no
msiexec /i fme-server-b%FMEBUILD%-win-x86.msi /qb /norestart /l*v installFMEServerLog.txt FMESERVERHOSTNAME=localhost
