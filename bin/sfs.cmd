@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "SFS_NATIVE_POWERSHELL=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "SFS_NATIVE_SCRIPT=%SCRIPT_DIR%sfs.ps1"
if not exist "%SFS_NATIVE_POWERSHELL%" set "SFS_NATIVE_POWERSHELL=powershell.exe"
if not exist "%SFS_NATIVE_SCRIPT%" (
  echo missing packaged SFS PowerShell entrypoint: %SFS_NATIVE_SCRIPT% 1>&2
  exit /b 4
)

"%SFS_NATIVE_POWERSHELL%" -NoProfile -ExecutionPolicy Bypass -Command "& $env:SFS_NATIVE_SCRIPT @args" %* & exit /b !ERRORLEVEL!
