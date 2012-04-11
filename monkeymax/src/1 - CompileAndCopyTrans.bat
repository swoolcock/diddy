set OLDDIR=%CD%

%OLDDIR%\..\bin\trans_winnt.exe -build -config=release -target=stdcpp %OLDDIR%\trans\trans.monkey
@echo off
for /f "tokens=1-4 delims=/ " %%a in ('date /t') do (
 set dd=%%b
 set mo=%%c
 set yy=%%d
)

for /f "tokens=1-3 delims=:." %%a in ("%time%") do (
 set hh=%%a
 set mm=%%b
 set ss=%%c
)

echo.
echo Backing up old trans_winnt.exe (if its there) to trans_winnt.exe.bak_%yy%_%mo%_%dd%_%hh%_%mm%_%ss%
ren "%OLDDIR%\trans\trans.build\stdcpp\trans_winnt.exe" trans_winnt.exe.bak_%yy%_%mo%_%dd%_%hh%_%mm%_%ss%
echo.
echo Renaming main_winnt.exe to trans_winnt.exe
ren "%OLDDIR%\trans\trans.build\stdcpp\main_winnt.exe" trans_winnt.exe
echo.
echo Copying to the bin folder...
ren "%OLDDIR%\..\bin\trans_winnt.exe" trans_winnt.exe.bak_%yy%_%mo%_%dd%_%hh%_%mm%_%ss%
COPY "%OLDDIR%\trans\trans.build\stdcpp\trans_winnt.exe" %OLDDIR%\..\bin\"
echo.
echo.
echo DONE!

pause