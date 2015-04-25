::This file does the initial configuration of the AWS instance.
::This should be filled with things that you only want to do once, like name the computer.
::OnstartConfiguration is a copy of this, but with most commands DISABLED
::Download and run this from the (elevated?) command line by using the following command:

::bitsadmin.exe /transfer "Start" https://s3.amazonaws.com/FMETraining/OnsiteConfiguration.bat OnsiteConfiguration.bat & OnsiteConfiguration.bat

::Last Edited By: Ryan Cragg 2015-03-31

::::GENERAL SETTINGS FOR LATER IN BATCH FILE - THINGS THAT CHANGE::::

set SAFE_LICENSE_FILE=@107.20.199.168
set FMEDESKTOPURL=https://s3.amazonaws.com/downloads.safe.com/fme/2015/fme_eval.msi
set FMEDESKTOP64URL=https://s3.amazonaws.com/downloads.safe.com/fme/2015/win64/fme_eval.msi
set FMESERVERURL=http://downloads.safe.com/fme/2015/fme-server-b15253-win-x86.msi
set FMEDATAURL=https://s3.amazonaws.com/FMEData/FME-Sample-Dataset-Full.zip

set DISABLED=::
set TEMP=c:\temp
set LOG=%TEMP%\OnsiteConfiguration.log

call :sub > %LOG%
exit /b

:sub
echo "Starting Downloading, Installing, and Configuring" 

:: Let's work in the TEMP folder
md %TEMP%
pushd %TEMP%

::::CONFIGURE WINDOWS SETTINGS::::

::Set some SYSTEM environment variables
setx /m SAFE_LICENSE_FILE %SAFE_LICENSE_FILE% 
setx /m FME_USE_LM_ENVIRONMENT YES 

:: Log that variables are set correctly
echo "Variables are set to:" 
set

::::INSTALL SOFTWARE::::

::Install Chocolatey. This is a package installer for Windows. It replaces Ninite.
::https://chocolatey.org/
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))) >$null 2>&1" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

::Bitsadmin does not work in a scheduled task. Install aria2. It is amazingly fast.
choco install aria2 -y 

::Google Chrome and Firefox are useful web browsers
choco install google-chrome-x64 -y  
choco install firefox -y  

::The following should be used in the onsite script:
::Adobe Reader is used to read manuals
choco install adobereader -y  

::Notepad++ is great for text editing
choco install notepadplusplus -y

::Google Earth is useful
choco install googleearth -y

::Install Python and Eclipse
choco install python -y 
choco install python2 -y
choco install eclipse -y 

:: Download the latest FMEData. This is done so that Ryan doesn't have to create a new AMI whenever there is just a small change in FMEData
:: FMEData should be kept as https://s3.amazonaws.com/FMEData/FME-Sample-Dataset-Full.zip
:: Get the basic FMEData and unzip any updates into c:\
aria2c %FMEDATAURL% --allow-overwrite=true 
unzip -u FME-Sample-Dataset-Full.zip -d c:\ 

:: The lastest FME Desktop Installers are available from http://www.safe.com/fme/fme-desktop/trial-download/download.php
aria2c %FMEDESKTOPURL% --allow-overwrite=true --out=FMEDesktop.msi
aria2c %FMEDESKTOP64URL% --allow-overwrite=true --out=FMEDesktop64.msi

:: The lastest FME Server Installers are available from http://www.safe.com/fme/fme-server/trial-download/download.php
aria2c %FMESERVERURL%  --allow-overwrite=true --out=FMEServer.msi

:: Now, let's install everything
:: Silent install of FME Desktop follows the form of:
::msiexec /i fme-desktop-b15475-win-x86.msi /qb INSTALLLEVEL=3 INSTALLDIR="c:\apps\fme" ENABLE_POST_INSTALL_TASKS=no
msiexec /i FMEDesktop.msi /qb INSTALLLEVEL=3 INSTALLDIR="c:\apps\FME" ENABLE_POST_INSTALL_TASKS=no
msiexec /i FMEDesktop64.msi /qb INSTALLLEVEL=3 INSTALLDIR="c:\Program Files\FME" ENABLE_POST_INSTALL_TASKS=no

:: Silent install of FME Server:
msiexec /i fmeserver.msi /qb /norestart /l*v installFMEServerLog.txt FMESERVERHOSTNAME=localhost


:: Might be nice to have the lastest ArcGIS installer downloaded and ready to go.
:: Silent Install?

::Silent Install of PostGreSQL/PostGIS?
::Silent Install of Oracle?

echo "Finished Setup. Going to Reboot"
shutdown /r
