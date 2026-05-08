@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
set "SFS_NATIVE_POWERSHELL=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
set "SFS_NATIVE_SCRIPT=%SCRIPT_DIR%sfs.ps1"
if not exist "%SFS_NATIVE_POWERSHELL%" set "SFS_NATIVE_POWERSHELL=powershell.exe"
if not exist "%SFS_NATIVE_SCRIPT%" (
  echo missing packaged SFS PowerShell entrypoint: %SFS_NATIVE_SCRIPT% 1>&2
  exit /b 4
)

set "SFS_NATIVE_ARGC=0"
set "SFS_NATIVE_RAW_ARGS=%*"
:sfs_collect_args
if "%~1"=="" goto sfs_args_done
set /a SFS_NATIVE_ARGC+=1 >NUL
for %%I in (%SFS_NATIVE_ARGC%) do set "SFS_NATIVE_ARG_%%I=%~1"
shift
goto sfs_collect_args

:sfs_args_done
setlocal EnableDelayedExpansion
set "SFS_NATIVE_CMDLINE=!CMDCMDLINE!"
"%SFS_NATIVE_POWERSHELL%" -NoProfile -ExecutionPolicy Bypass -File "%SFS_NATIVE_SCRIPT%" & exit /b !ERRORLEVEL!
