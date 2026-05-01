@echo off
setlocal

set "BASH_EXE="
set "SCRIPT_DIR=%~dp0"

call :maybe_self_upgrade %*
if defined SFS_SELF_UPGRADE_DONE exit /b %ERRORLEVEL%
if errorlevel 1 exit /b %ERRORLEVEL%

if defined SFS_BASH (
  if exist "%SFS_BASH%" set "BASH_EXE=%SFS_BASH%"
  if not defined BASH_EXE (
    for /f "delims=" %%B in ('where "%SFS_BASH%" 2^>nul') do (
      if not defined BASH_EXE set "BASH_EXE=%%B"
    )
  )
)

if not defined BASH_EXE if exist "%ProgramFiles%\Git\bin\bash.exe" set "BASH_EXE=%ProgramFiles%\Git\bin\bash.exe"
if not defined BASH_EXE if exist "%ProgramFiles%\Git\usr\bin\bash.exe" set "BASH_EXE=%ProgramFiles%\Git\usr\bin\bash.exe"
if not defined BASH_EXE if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" set "BASH_EXE=%ProgramFiles(x86)%\Git\bin\bash.exe"
if not defined BASH_EXE if exist "%ProgramFiles(x86)%\Git\usr\bin\bash.exe" set "BASH_EXE=%ProgramFiles(x86)%\Git\usr\bin\bash.exe"

if not defined BASH_EXE (
  for /f "delims=" %%B in ('where bash.exe 2^>nul') do (
    if not defined BASH_EXE (
      echo "%%B" | findstr /I "\\Windows\\System32\\bash.exe" >nul
      if errorlevel 1 set "BASH_EXE=%%B"
    )
  )
)

if not defined BASH_EXE (
  echo Solon SFS on Windows requires Git Bash. Install Git for Windows, or set SFS_BASH to a compatible bash.exe. 1>&2
  exit /b 9
)

set "SFS_SH=%SCRIPT_DIR%sfs"
set "SFS_SH=%SFS_SH:\=/%"

"%BASH_EXE%" "%SFS_SH%" %*
exit /b %ERRORLEVEL%

:maybe_self_upgrade
if defined SFS_SKIP_SELF_UPGRADE exit /b 0
if "%SFS_UPDATE_SELF%"=="0" exit /b 0

set "SFS_CMD_ARG=%~1"
if /I "%SFS_CMD_ARG%"=="/sfs" set "SFS_CMD_ARG=%~2"
if /I "%SFS_CMD_ARG%"=="sfs" set "SFS_CMD_ARG=%~2"
if /I "%SFS_CMD_ARG%"=="$sfs" set "SFS_CMD_ARG=%~2"

set "SFS_IS_UPGRADE="
if /I "%SFS_CMD_ARG%"=="upgrade" set "SFS_IS_UPGRADE=1"
if /I "%SFS_CMD_ARG%"=="update" set "SFS_IS_UPGRADE=1"
if not defined SFS_IS_UPGRADE exit /b 0

set "SFS_NO_SELF="
for %%A in (%*) do (
  if /I "%%~A"=="--no-self-upgrade" set "SFS_NO_SELF=1"
)
if defined SFS_NO_SELF exit /b 0

echo "%SCRIPT_DIR%" | findstr /I "\\scoop\\apps\\sfs\\" >nul
if errorlevel 1 exit /b 0

where scoop >nul 2>nul
if errorlevel 1 (
  echo scoop command not found; rerun with SFS_UPDATE_SELF=0 to use the current runtime only. 1>&2
  exit /b 1
)

echo global runtime self-upgrade:
echo   scoop update
call scoop update
if errorlevel 1 (
  echo scoop update failed; rerun with SFS_UPDATE_SELF=0 to use the current runtime only. 1>&2
  exit /b 1
)

echo   scoop update sfs
call scoop update sfs
if errorlevel 1 (
  echo scoop update sfs failed; rerun with SFS_UPDATE_SELF=0 to use the current runtime only. 1>&2
  exit /b 1
)

set "UPDATED_SFS_CMD="
for /f "delims=" %%S in ('where sfs.cmd 2^>nul') do (
  if not defined UPDATED_SFS_CMD set "UPDATED_SFS_CMD=%%S"
)
if not defined UPDATED_SFS_CMD set "UPDATED_SFS_CMD=%~f0"

echo reloading installed sfs runtime...
set "SFS_SKIP_SELF_UPGRADE=1"
set "SFS_SELF_UPGRADE_DONE=1"
call "%UPDATED_SFS_CMD%" %*
exit /b %ERRORLEVEL%
