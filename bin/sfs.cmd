@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "SFS_NATIVE_POWERSHELL=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%SFS_NATIVE_POWERSHELL%" set "SFS_NATIVE_POWERSHELL=powershell.exe"
if not exist "%SCRIPT_DIR%sfs.ps1" (
  echo missing packaged SFS PowerShell entrypoint: %SCRIPT_DIR%sfs.ps1 1>&2
  exit /b 4
)

"%SFS_NATIVE_POWERSHELL%" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%sfs.ps1" %* & exit /b !ERRORLEVEL!
