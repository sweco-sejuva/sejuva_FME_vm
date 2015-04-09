::This file does the initial configuration of the AWS instance.
::This should be filled with things that you only want to do once, like name the computer.
::OnstartConfiguration is a copy of this, but with most commands DISABLED
::Download and run this from the (elevated?) command line by using the following command:

::bitsadmin.exe /transfer "Start" https://s3.amazonaws.com/FMETraining/InitialConfiguration.bat OnsiteConfiguration.bat & OnsiteConfiguration.bat

::Last Edited By: Ryan Cragg 2015-03-31

::::GENERAL SETTINGS FOR LATER IN BATCH FILE - THINGS THAT CHANGE::::

set SAFE_LICENSE_FILE=@107.20.199.168
set FMEDESKTOPURL=https://s3.amazonaws.com/downloads.safe.com/fme/2015/fme_eval.msi
set FMEDESKTOP64URL=https://s3.amazonaws.com/downloads.safe.com/fme/2015/win64/fme_eval.msi
set FMESERVERURL=https://s3.amazonaws.com/downloads.safe.com/fme/2015/win64/fme_eval.msi
set FMEDATAURL=https://s3.amazonaws.com/FMEData/FME-Sample-Dataset-Full.zip

set DISABLED=::
set TEMP=c:\temp
md %TEMP%
set LOG=%TEMP%\Configure.log


echo "Starting Downloading, Installing, and Configuring" > %LOG%

::::CONFIGURE WINDOWS SETTINGS::::

::Set some SYSTEM environment variables
setx /m SAFE_LICENSE_FILE %SAFE_LICENSE_FILE% >> %LOG%
setx /m FME_USE_LM_ENVIRONMENT YES >> %LOG%

:: Log that variables are set correctly
echo "Variables are set to:" >> %LOG%
set >> %LOG%

::::INSTALL SOFTWARE::::

::Install Chocolatey. This is a package installer for Windows. It replaces Ninite.
::https://chocolatey.org/
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))) >$null 2>&1" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

::Bitsadmin does not work in a scheduled task. Install aria2. It is amazingly fast.
choco install aria2 -y >> %LOG%

::Google Chrome and Firefox are useful web browsers
choco install google-chrome-x64 -y  >> %LOG%
choco install firefox -y  >> %LOG%

::The following should be used in the onsite script:
::Adobe Reader is used to read manuals
choco install adobereader -y  >> %LOG%

::Notepad++ is great for text editing
choco install notepadplusplus -y  >> %LOG%

::Google Earth is useful
choco install googleearth -y  >> %LOG%

::Install Python and Eclipse
choco install python -y  >> %LOG%
choco install python2 -y  >> %LOG%
choco install eclipse -y  >> %LOG%

:: Download the latest FMEData. This is done so that Ryan doesn't have to create a new AMI whenever there is just a small change in FMEData
:: FMEData should be kept as https://s3.amazonaws.com/FMEData/FME-Sample-Dataset-Full.zip
:: Get the basic FMEData and unzip any updates into c:\
pushd %TEMP% && aria2c %FMEDATAURL% --allow-overwrite=true >> %LOG%
pushd %TEMP% && unzip -u FME-Sample-Dataset-Full.zip -d c:\ >> %LOG%

:: The lastest FME Desktop Installers are available from http://www.safe.com/fme/fme-desktop/trial-download/download.php
pushd %TEMP% && aria2c %FMEDESKTOPURL% --allow-overwrite=true >> %LOG%
pushd %TEMP% && aria2c %FMEDESKTOP64URL% --allow-overwrite=true >> %LOG%

:: The lastest FME Server Installers are available from http://www.safe.com/fme/fme-server/trial-download/download.php
pushd %TEMP% && aria2c %FMESERVERURL%  --allow-overwrite=true >> %LOG%

:: Might be nice to have the lastest ArcGIS installer downloaded and ready to go.
:: Silent Install?

::Silent Install of PostGreSQL/PostGIS?
::Silent Install of Oracle?

echo "Finished the Restart Process" >> %LOG%



