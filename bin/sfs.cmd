@echo off
setlocal

set "BASH_EXE="

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

set "SFS_SH=%~dp0sfs"
set "SFS_SH=%SFS_SH:\=/%"

"%BASH_EXE%" "%SFS_SH%" %*
exit /b %ERRORLEVEL%
