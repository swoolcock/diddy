rebuildall.exe

set OLDDIR=%CD%

ren "%OLDDIR%\trans\trans.build\stdcpp\main_winnt.exe" trans_winnt.exe

COPY "%OLDDIR%\trans\trans.build\stdcpp\trans_winnt.exe" %OLDDIR%\..\bin\"

pause