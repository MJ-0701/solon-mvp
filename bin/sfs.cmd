@echo off
setlocal

set "BASH_EXE="
set "SCRIPT_DIR=%~dp0"

call :maybe_self_upgrade %*
if defined SFS_SELF_UPGRADE_DONE exit /b %ERRORLEVEL%
if errorlevel 1 exit /b %ERRORLEVEL%

call :maybe_native_readonly %*
if defined SFS_NATIVE_READONLY_DONE exit /b %ERRORLEVEL%

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
set "SFS_OLD_SCOOP_PROJECT_UPGRADE=%SFS_SCOOP_PROJECT_UPGRADE%"
set "SFS_SCOOP_PROJECT_UPGRADE=0"
call scoop update sfs
set "SFS_SCOOP_UPDATE_EXIT=%ERRORLEVEL%"
if defined SFS_OLD_SCOOP_PROJECT_UPGRADE (
  set "SFS_SCOOP_PROJECT_UPGRADE=%SFS_OLD_SCOOP_PROJECT_UPGRADE%"
) else (
  set "SFS_SCOOP_PROJECT_UPGRADE="
)
if not "%SFS_SCOOP_UPDATE_EXIT%"=="0" (
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
call "%UPDATED_SFS_CMD%" %*
set "SFS_SELF_UPGRADE_DONE=1"
exit /b %ERRORLEVEL%

:maybe_native_readonly
set "SFS_NATIVE_READONLY_DONE="
set "SFS_NATIVE_ARGS=%*"
set "SFS_NATIVE_CMD=%~1"
set "SFS_NATIVE_OPT=%~2"
if /I "%SFS_NATIVE_CMD%"=="/sfs" (
  set "SFS_NATIVE_CMD=%~2"
  set "SFS_NATIVE_OPT=%~3"
)
if /I "%SFS_NATIVE_CMD%"=="sfs" (
  set "SFS_NATIVE_CMD=%~2"
  set "SFS_NATIVE_OPT=%~3"
)
if /I "%SFS_NATIVE_CMD%"=="$sfs" (
  set "SFS_NATIVE_CMD=%~2"
  set "SFS_NATIVE_OPT=%~3"
)

if not defined SFS_NATIVE_CMD (
  call :native_usage
  set "SFS_NATIVE_READONLY_DONE=1"
  exit /b 0
)
if /I "%SFS_NATIVE_CMD%"=="help" (
  call :native_usage
  set "SFS_NATIVE_READONLY_DONE=1"
  exit /b 0
)
if /I "%SFS_NATIVE_CMD%"=="--help" (
  call :native_usage
  set "SFS_NATIVE_READONLY_DONE=1"
  exit /b 0
)
if /I "%SFS_NATIVE_CMD%"=="-h" (
  call :native_usage
  set "SFS_NATIVE_READONLY_DONE=1"
  exit /b 0
)
if /I "%SFS_NATIVE_CMD%"=="guide" goto native_guide_dispatch
if /I "%SFS_NATIVE_CMD%"=="status" goto native_powershell_readonly_dispatch
if /I "%SFS_NATIVE_CMD%"=="context" goto native_powershell_readonly_dispatch
if /I "%SFS_NATIVE_CMD%"=="version" goto native_powershell_readonly_dispatch
if /I "%SFS_NATIVE_CMD%"=="--version" goto native_powershell_readonly_dispatch
if /I "%SFS_NATIVE_CMD%"=="-v" goto native_powershell_readonly_dispatch
exit /b 0

:native_guide_dispatch
call :native_guide "%SFS_NATIVE_OPT%"
set "SFS_NATIVE_RC=%ERRORLEVEL%"
set "SFS_NATIVE_READONLY_DONE=1"
exit /b %SFS_NATIVE_RC%

:native_powershell_readonly_dispatch
set "SFS_NATIVE_POWERSHELL=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%SFS_NATIVE_POWERSHELL%" set "SFS_NATIVE_POWERSHELL=powershell.exe"
if not exist "%SCRIPT_DIR%sfs.ps1" (
  echo missing packaged SFS PowerShell entrypoint: %SCRIPT_DIR%sfs.ps1 1>&2
  set "SFS_NATIVE_READONLY_DONE=1"
  exit /b 4
)
set "SFS_OLD_NATIVE_ONLY=%SFS_NATIVE_ONLY%"
set "SFS_NATIVE_ONLY=1"
"%SFS_NATIVE_POWERSHELL%" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%sfs.ps1" %SFS_NATIVE_ARGS%
set "SFS_NATIVE_RC=%ERRORLEVEL%"
if defined SFS_OLD_NATIVE_ONLY (
  set "SFS_NATIVE_ONLY=%SFS_OLD_NATIVE_ONLY%"
) else (
  set "SFS_NATIVE_ONLY="
)
set "SFS_OLD_NATIVE_ONLY="
set "SFS_NATIVE_READONLY_DONE=1"
exit /b %SFS_NATIVE_RC%

:native_dist_dir
for %%I in ("%SCRIPT_DIR%..") do set "SFS_NATIVE_DIST=%%~fI"
exit /b 0

:native_usage
echo Usage:
echo   sfs.cmd init [--yes] [--layout thin^|vendored]
echo   sfs.cmd upgrade [--skip-existing] [--no-self-upgrade] [--interactive] [--layout thin^|vendored]
echo   sfs.cmd update [--skip-existing]
echo   sfs.cmd uninstall [--keep-artifacts^|--remove-all] [--remove-docs^|--keep-docs]
echo   sfs.cmd agent install ^<claude^|gemini^|codex^|all^> [--skip-existing]
echo   sfs.cmd context path ^<kernel^|index^|commands/name.md^|policies/name.md^>
echo   sfs.cmd context cat  ^<kernel^|index^|commands/name.md^|policies/name.md^>
echo   sfs.cmd ^<command^> [args]
echo.
echo Commands:
echo   agent install, upgrade, update, uninstall
echo   version [--check]
echo   status, start, guide, auth, profile, division, adopt, brainstorm, plan, implement, review, decision, report, tidy, retro, commit, loop
echo   bootstrap [plain-language app idea]
echo   measure --alive -- ^<command^>
echo.
echo Windows note:
echo   PowerShell/cmd users should prefer sfs.cmd. Git Bash/WSL users can use sfs.
echo   sfs.cmd status, version, guide, and context path/cat are native read-only.
echo   Mutating commands still require Git for Windows/Git Bash.
exit /b 0

:native_guide
set "SFS_NATIVE_GUIDE_OPT=%~1"
if /I "%SFS_NATIVE_GUIDE_OPT%"=="--help" (
  call :native_guide_usage
  exit /b 0
)
if /I "%SFS_NATIVE_GUIDE_OPT%"=="-h" (
  call :native_guide_usage
  exit /b 0
)
if defined SFS_NATIVE_GUIDE_OPT (
  if /I not "%SFS_NATIVE_GUIDE_OPT%"=="--path" if /I not "%SFS_NATIVE_GUIDE_OPT%"=="--print" (
    echo unknown arg for guide: %SFS_NATIVE_GUIDE_OPT% 1>&2
    exit /b 99
  )
)

call :native_resolve_guide_path
if /I "%SFS_NATIVE_GUIDE_OPT%"=="--path" goto native_guide_path
if /I "%SFS_NATIVE_GUIDE_OPT%"=="--print" goto native_guide_print

echo Solon guide context
echo.
echo What this is:
echo   Solon keeps sprint, decision, review, retro, and handoff state inside this repo.
echo.
echo First files:
echo   SFS.md        project operating guide
echo   CLAUDE.md     Claude Code entry
echo   AGENTS.md     Codex entry
echo   GEMINI.md     Gemini CLI entry
echo.
echo Command entrypoints:
echo   PowerShell/cmd:        sfs.cmd ...
echo   Git Bash/WSL/macOS:    sfs ...
echo   Claude/Gemini agents:  /sfs ...
echo   Codex agents:          $sfs ...
echo.
echo First flow:
echo   sfs.cmd status
echo   sfs.cmd auth status
echo   sfs.cmd start "current sprint goal"
echo   sfs.cmd brainstorm "raw requirements"
echo   sfs.cmd plan
echo   sfs.cmd implement "first slice"
echo.
echo Full guide:
echo   sfs.cmd guide --print
echo   path: %SFS_NATIVE_GUIDE_PATH%
exit /b 0

:native_guide_path
echo %SFS_NATIVE_GUIDE_PATH%
exit /b 0

:native_guide_print
if not exist "%SFS_NATIVE_GUIDE_PATH%" (
  echo guide missing: %SFS_NATIVE_GUIDE_PATH% 1>&2
  exit /b 4
)
type "%SFS_NATIVE_GUIDE_PATH%"
set "SFS_NATIVE_TYPE_RC=%ERRORLEVEL%"
exit /b %SFS_NATIVE_TYPE_RC%

:native_guide_usage
echo Usage:
echo   sfs.cmd guide [--path^|--print]
echo.
echo Shows the Solon Product onboarding guide installed with this project.
echo   --path   print only the guide path
echo   --print  print the full guide contents
exit /b 0

:native_resolve_guide_path
call :native_dist_dir
set "SFS_NATIVE_GUIDE_PATH=%CD%\.sfs-local\GUIDE.md"
if not exist "%SFS_NATIVE_GUIDE_PATH%" set "SFS_NATIVE_GUIDE_PATH=%SFS_NATIVE_DIST%\GUIDE.md"
exit /b 0
