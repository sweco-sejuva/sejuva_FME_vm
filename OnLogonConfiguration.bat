::On Logon Configuration
::These are things that should only happen once a user has logged in.

::Set all required variables
  set LOG=c:\temp\OnstartLogon.log

call :VNC > %LOG%
exit /b

:VNC
  IF NOT %SESSIONNAME%==Console (
    taskkill /f /t /fi "USERNAME eq SYSTEM" /im winvnc.exe
    net stop "uvnc_service"
    "C:\Program Files\uvnc bvba\UltraVNC\winvnc.exe"
  )
goto :eof
