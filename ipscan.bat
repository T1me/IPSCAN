@echo off

:main
if "%1" == "" (echo Usage: ipscan 192.168.1.<nul&goto :eof) else (set ipgroup=%1)
if exist "ipscan.txt" (del "ipscan.txt")
for /l %%I in (1,1,5) DO (
call :ping %ipgroup%%%I
)
echo Ping result log saved to ipscan.txt.
echo ---------------------------------------
set /p="Press Enter to Exit. . ."
goto :eof

:ping
set /p=Ping %1...<nul
ping.exe -n 1 %1>>ipscan.txt
if errorlevel 1 (echo Error) else (echo Received)
goto :eof
