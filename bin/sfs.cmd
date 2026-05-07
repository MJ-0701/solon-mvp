@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "SFS_ORIGINAL_ARGS=%*"

call :maybe_native_readonly %*
if not "%SFS_NATIVE_READONLY_DONE%"=="" exit /b %ERRORLEVEL%

call :powershell_dispatch %*
exit /b %ERRORLEVEL%

:powershell_dispatch
set "SFS_NATIVE_POWERSHELL=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%SFS_NATIVE_POWERSHELL%" set "SFS_NATIVE_POWERSHELL=powershell.exe"
if not exist "%SCRIPT_DIR%sfs.ps1" (
  echo missing packaged SFS PowerShell entrypoint: %SCRIPT_DIR%sfs.ps1 1>&2
  exit /b 4
)
"%SFS_NATIVE_POWERSHELL%" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%sfs.ps1" %SFS_ORIGINAL_ARGS%
exit /b %ERRORLEVEL%

:maybe_native_readonly
set "SFS_NATIVE_READONLY_DONE="
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
"%SFS_NATIVE_POWERSHELL%" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%sfs.ps1" %SFS_ORIGINAL_ARGS%
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
