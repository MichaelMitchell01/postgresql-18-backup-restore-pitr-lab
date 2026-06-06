@echo off
setlocal

set SRC=%~1
set FILENAME=%~2
set DEST=C:\pg_dba_lab\wal_archive\%FILENAME%

if exist "%DEST%" (
    fc /b "%SRC%" "%DEST%" >nul
    if errorlevel 1 exit /b 1
    exit /b 0
)

copy /b "%SRC%" "%DEST%" >nul
if errorlevel 1 exit /b 1

exit /b 0