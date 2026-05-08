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
if defined SFS_WINDOWS_ARG_TRACE (
  set "SFS_ARGTRACE_CMD_FIRST=%~1"
  set "SFS_ARGTRACE_CMD_RAW_ARGS=%*"
  set SFS_ARGTRACE_CMD_FIRST 1>&2
  set SFS_ARGTRACE_CMD_RAW_ARGS 1>&2
)
:sfs_collect_args
if "%~1"=="" goto sfs_args_done
set /a SFS_NATIVE_ARGC+=1 >NUL
for %%I in (%SFS_NATIVE_ARGC%) do set "SFS_NATIVE_ARG_%%I=%~1"
shift
goto sfs_collect_args

:sfs_args_done
setlocal EnableDelayedExpansion
set "SFS_NATIVE_CMDLINE=!CMDCMDLINE!"
if defined SFS_WINDOWS_ARG_TRACE (
  set "SFS_ARGTRACE_CMD_ARGC=!SFS_NATIVE_ARGC!"
  set "SFS_ARGTRACE_CMD_CMDLINE=!SFS_NATIVE_CMDLINE!"
  set SFS_ARGTRACE_CMD_ARGC 1>&2
  set SFS_ARGTRACE_CMD_CMDLINE 1>&2
)
"%SFS_NATIVE_POWERSHELL%" -NoProfile -ExecutionPolicy Bypass -File "%SFS_NATIVE_SCRIPT%" & exit /b !ERRORLEVEL!
