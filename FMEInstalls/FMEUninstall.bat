:: Turn off echo, and get into C:\temp
@echo off
pushd c:\temp

::Create the PS1 file
call :uninstallFME >uninstallFME.ps1

::Execute the PS1 file
powershell -NoProfile -executionpolicy bypass -File uninstallFME.ps1

goto :eof

:uninstallFME
@echo off
echo $app = Get-WmiObject -Class Win32_Product -Filter "Vendor='Safe Software Inc.'"
echo $app.Uninstall()
@echo on
@goto :eof
