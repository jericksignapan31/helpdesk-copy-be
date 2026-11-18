@echo off
color 0A
title AUTO CLEAN PC

echo ===============================
echo Cleaning Temporary Files...
echo ===============================

del /s /f /q %temp%\*.*
rd /s /q %temp%
mkdir %temp%

echo Cleaning Windows Temp...
del /s /f /q C:\Windows\Temp\*.*
rd /s /q C:\Windows\Temp
mkdir C:\Windows\Temp

echo Cleaning Prefetch...
del /s /f /q C:\Windows\Prefetch\*.*

echo Cleaning Recent Files...
del /s /f /q %APPDATA%\Microsoft\Windows\Recent\*.*

echo Flushing DNS Cache...
ipconfig /flushdns

echo Cleaning Thumbnail Cache...
del /s /f /q %LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db

echo Emptying Recycle Bin...
PowerShell.exe -NoProfile -Command "Clear-RecycleBin -Force"

echo ===============================
echo Cleaning Windows Update Cache
echo ===============================

net stop wuauserv
del /s /f /q C:\Windows\SoftwareDistribution\Download\*.*
net start wuauserv

echo ===============================
echo CLEANING COMPLETE
echo ===============================

pause