@echo off
title IT TECH MAINTENANCE TOOL
color 0A

:menu
cls
echo ==========================================
echo          IT TECH MAINTENANCE TOOL
echo ==========================================
echo.
echo   [1] Full System Cleanup
echo   [2] System File Repair (SFC + DISM)
echo   [3] Network Fix
echo   [4] RAM Refresh
echo   [5] Windows Update Fix
echo   [6] Printer Spooler Fix
echo   [7] Exit
echo.
set /p choice=Select Option:

if %choice%==1 goto fullclean
if %choice%==2 goto repair
if %choice%==3 goto network
if %choice%==4 goto ram
if %choice%==5 goto winupdate
if %choice%==6 goto printer
if %choice%==7 exit
goto menu

:fullclean
cls
echo ==========================================
echo           FULL SYSTEM CLEANUP
echo ==========================================

echo Cleaning TEMP files...
del /s /f /q %temp%*.*
rd /s /q %temp%
mkdir %temp%

echo Cleaning Windows Temp...
del /s /f /q C:\Windows\Temp*.*
rd /s /q C:\Windows\Temp
mkdir C:\Windows\Temp

echo Cleaning Prefetch...
del /s /f /q C:\Windows\Prefetch*.*

echo Cleaning Thumbnail Cache...
del /s /f /q %LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db

echo Cleaning Recent Files...
del /s /f /q %APPDATA%\Microsoft\Windows\Recent*.*

echo Emptying Recycle Bin...
PowerShell.exe -NoProfile -Command "Clear-RecycleBin -Force"

echo Flushing DNS Cache...
ipconfig /flushdns

echo Cleaning Windows Update Cache...
net stop wuauserv
net stop bits
del /s /f /q C:\Windows\SoftwareDistribution\Download*.*
net start wuauserv
net start bits

echo Running DISM Component Cleanup...
DISM /Online /Cleanup-Image /StartComponentCleanup

echo Running Disk Cleanup...
cleanmgr /sagerun:1

echo Running System File Checker...
sfc /scannow

echo.
echo FULL CLEANUP COMPLETE
pause
goto menu

:repair
cls
echo ==========================================
echo        WINDOWS SYSTEM REPAIR
echo ==========================================

echo Running System File Checker...
sfc /scannow

echo Running DISM Restore Health...
DISM /Online /Cleanup-Image /RestoreHealth

echo Repair Complete
pause
goto menu

:network
cls
echo ==========================================
echo           NETWORK RESET
echo ==========================================

ipconfig /release
ipconfig /renew
ipconfig /flushdns
netsh winsock reset
netsh int ip reset

echo Network Reset Complete
pause
goto menu

:ram
cls
echo ==========================================
echo            RAM REFRESH
echo ==========================================

taskkill /f /im explorer.exe
start explorer.exe

echo RAM Refresh Done
pause
goto menu

:winupdate
cls
echo ==========================================
echo         WINDOWS UPDATE FIX
echo ==========================================

net stop wuauserv
net stop bits
net stop cryptsvc

ren C:\Windows\SoftwareDistribution SoftwareDistribution.old
ren C:\Windows\System32\catroot2 catroot2.old

net start wuauserv
net start bits
net start cryptsvc

echo Windows Update Reset Complete
pause
goto menu

:printer
cls
echo ==========================================
echo         PRINTER SPOOLER FIX
echo ==========================================

net stop spooler
del /s /f /q C:\Windows\System32\spool\PRINTERS*.*
net start spooler

echo Printer Spooler Restarted
pause
goto menu
