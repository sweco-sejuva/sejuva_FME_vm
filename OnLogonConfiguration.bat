::On Logon Configuration
::These are things that should only happen once a user has logged in.

  IF NOT %SESSIONNAME%==Console (
    taskkill /f /t /fi "USERNAME eq SYSTEM" /im winvnc.exe
    net stop "uvnc_service"
    "C:\Program Files\uvnc bvba\UltraVNC\winvnc.exe"
  )
