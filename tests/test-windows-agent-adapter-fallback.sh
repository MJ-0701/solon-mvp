#!/usr/bin/env bash
# Windows Claude/Gemini/Codex adapter fallback guardrail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"

  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

line_number() {
  local file="$1"
  local needle="$2"
  awk -v needle="${needle}" 'index($0, needle) { print NR; exit }' "${file}"
}

cmd_wrapper="${DIST_DIR}/bin/sfs.cmd"
sfs_bin="${DIST_DIR}/bin/sfs"
ps_wrapper="${DIST_DIR}/bin/sfs.ps1"
upgrade_sh="${DIST_DIR}/upgrade.sh"
scoop_post_install="${DIST_DIR}/bin/sfs-scoop-post-install.ps1"
scoop_template="${DIST_DIR}/packaging/scoop/sfs.json.template"
windows_discovery="${DIST_DIR}/scripts/install-cli-discovery.ps1"
codex_global_skill="${DIST_DIR}/templates/codex-skill/SKILL.md"
codex_project_skill="${DIST_DIR}/templates/.agents/skills/sfs/SKILL.md"
adapter_files=(
  "${DIST_DIR}/templates/CLAUDE.md.template"
  "${DIST_DIR}/templates/AGENTS.md.template"
  "${DIST_DIR}/templates/GEMINI.md.template"
  "${DIST_DIR}/templates/codex-skill/SKILL.md"
  "${DIST_DIR}/templates/.agents/skills/sfs/SKILL.md"
  "${DIST_DIR}/templates/.claude/commands/sfs.md"
  "${DIST_DIR}/templates/.gemini/commands/sfs.toml"
  "${DIST_DIR}/templates/.codex/prompts/sfs.md"
  "${DIST_DIR}/commands/sfs.toml"
  "${DIST_DIR}/plugins/solon/commands/sfs.md"
)

assert_contains "${cmd_wrapper}" "setlocal EnableExtensions DisableDelayedExpansion" "cmd collects args without delayed-expansion corruption"
assert_contains "${cmd_wrapper}" "set \"SFS_NATIVE_SCRIPT=%SCRIPT_DIR%sfs.ps1\"" "cmd stores ps1 path for powershell command bridge"
assert_contains "${cmd_wrapper}" "set \"SFS_NATIVE_ARGC=0\"" "cmd initializes env arg bridge"
assert_contains "${cmd_wrapper}" "set \"SFS_NATIVE_RAW_ARGS=%*\"" "cmd captures raw arg tail before shift"
assert_contains "${cmd_wrapper}" "set \"SFS_NATIVE_CMDLINE=!CMDCMDLINE!\"" "cmd captures original cmd command line after delayed expansion is enabled"
assert_contains "${cmd_wrapper}" "SFS_WINDOWS_ARG_TRACE" "cmd exposes opt-in Windows arg trace"
assert_contains "${cmd_wrapper}" "SFS_ARGTRACE_CMD_ARGC" "cmd traces collected arg count"
assert_contains "${cmd_wrapper}" ":sfs_collect_args" "cmd env arg collection loop"
assert_contains "${cmd_wrapper}" "set \"SFS_NATIVE_ARG_%%I=%~1\"" "cmd stores numbered env args"
assert_contains "${cmd_wrapper}" "-File \"%SFS_NATIVE_SCRIPT%\" & exit /b !ERRORLEVEL!" "cmd powershell env bridge exits on parsed line"
if grep -Fq -- '--% %SFS_NATIVE_RAW_ARGS%' "${cmd_wrapper}"; then
  fail "cmd wrapper must not pass raw args through PowerShell --%; GitHub runner converted it into --SFS_NATIVE_RAW_ARGS"
fi
assert_contains "${scoop_template}" '"bin\\sfs.ps1"' "Scoop manifest uses PowerShell shim entrypoint"
if grep -Fq -- '"bin\\sfs.cmd"' "${scoop_template}"; then
  fail "Scoop manifest must not shim through bin\\sfs.cmd; generated cmd shims lost args in the field"
fi
assert_contains "${scoop_post_install}" "Install-SfsScoopShims" "Scoop post-install hardens generated shims"
assert_contains "${scoop_post_install}" 'Set-Content -LiteralPath (Join-Path $shimDir "sfs.cmd")' "Scoop post-install overwrites sfs.cmd shim"
assert_contains "${scoop_post_install}" 'Set-Content -LiteralPath (Join-Path $shimDir "sfs.ps1")' "Scoop post-install overwrites sfs.ps1 shim"
assert_contains "${scoop_post_install}" 'Set-Content -LiteralPath (Join-Path $shimDir "sfs")' "Scoop post-install installs Git Bash sfs shim"
assert_contains "${scoop_post_install}" 'set "SFS_NATIVE_ARGC=0"' "Scoop sfs.cmd shim initializes env arg bridge"
assert_contains "${scoop_post_install}" 'set "SFS_NATIVE_RAW_ARGS=%*"' "Scoop sfs.cmd shim captures raw arg tail before shift"
assert_contains "${scoop_post_install}" 'set "SFS_NATIVE_CMDLINE=!CMDCMDLINE!"' "Scoop sfs.cmd shim captures original cmd command line after delayed expansion is enabled"
assert_contains "${scoop_post_install}" 'SFS_WINDOWS_ARG_TRACE' "Scoop sfs.cmd shim exposes opt-in Windows arg trace"
assert_contains "${scoop_post_install}" 'SFS_ARGTRACE_CMD_ARGC' "Scoop sfs.cmd shim traces collected arg count"
assert_contains "${scoop_post_install}" 'set "SFS_NATIVE_ARG_%%I=%~1"' "Scoop sfs.cmd shim stores numbered args"
assert_contains "${scoop_post_install}" '-File "%SFS_NATIVE_SCRIPT%" & exit /b !ERRORLEVEL!' "Scoop sfs.cmd shim keeps env bridge dispatch on the same parsed line"
if grep -Fq -- '--% %SFS_NATIVE_RAW_ARGS%' "${scoop_post_install}"; then
  fail "Scoop sfs.cmd shim must not pass raw args through PowerShell --%; GitHub runner converted it into --SFS_NATIVE_RAW_ARGS"
fi
assert_contains "${scoop_post_install}" '& $target @args' "Scoop sfs.ps1 shim forwards PowerShell args"
assert_contains "${scoop_post_install}" 'exec bash "$_sfs_path" "$@"' "Scoop Git Bash shim forwards args"
if grep -Fq -- 'set "SFS_NATIVE_CMDLINE=%CMDCMDLINE%"' "${cmd_wrapper}" "${scoop_post_install}"; then
  fail "cmdline bridge must not expand raw %CMDCMDLINE% in a batch set line; quotes and shell operators can break parsing"
fi
if grep -Fq -- "-Command \"& \$env:SFS_NATIVE_SCRIPT @args\"" "${cmd_wrapper}"; then
  fail "cmd wrapper must not rely on PowerShell -Command @args; Scoop shims lost args through that path"
fi
if grep -Fq -- "call :" "${cmd_wrapper}"; then
  fail "cmd wrapper must stay a thin direct PowerShell entrypoint; call-label forwarding lost args under Scoop shims"
fi
if grep -Fq -- "call :maybe_self_upgrade" "${cmd_wrapper}"; then
  fail "cmd wrapper must not run Scoop self-upgrade from the batch file that Scoop replaces"
fi
if grep -Fq -- "call scoop update" "${cmd_wrapper}"; then
  fail "cmd wrapper must not call scoop update directly; sfs.ps1 owns the stable self-upgrade"
fi
if grep -Fq -- "SFS_ORIGINAL_ARGS" "${cmd_wrapper}"; then
  fail "cmd wrapper must forward the call-label %* directly; cached SFS_ORIGINAL_ARGS went empty under Scoop shims"
fi
if grep -Fq -- "call exit /b %%ERRORLEVEL%%" "${cmd_wrapper}"; then
  fail "cmd wrapper must not use unstable CALL+ERRORLEVEL double expansion for post-upgrade exit"
fi
if grep -Fq -- "\"%BASH_EXE%\" \"%SFS_SH%\" %*" "${cmd_wrapper}"; then
  fail "cmd wrapper must not send mutating commands through the raw Git Bash %* bridge"
fi
if perl -0ne 'exit((/-File "%SCRIPT_DIR%sfs\.ps1" %\*\r?\nexit \/b/) ? 0 : 1)' "${cmd_wrapper}"; then
  fail "cmd wrapper must not put PowerShell dispatch and exit on separate parsed lines during self-upgrade"
fi

if grep -Fq -- "ValueFromRemainingArguments" "${ps_wrapper}"; then
  fail "ps1 must not rely on ValueFromRemainingArguments; Scoop PowerShell shims lost args through that path"
fi
assert_contains "${ps_wrapper}" '$SfsParamArgs = @()' "ps1 disables broken script-param arg source"
assert_contains "${ps_wrapper}" '$args' "ps1 automatic args source"
assert_contains "${ps_wrapper}" "Resolve-SfsEnvArgs" "ps1 env arg bridge"
assert_contains "${ps_wrapper}" 'SFS_NATIVE_ARGC' "ps1 reads env arg count"
assert_contains "${ps_wrapper}" 'SFS_NATIVE_ARG_$i' "ps1 reads numbered env args"
assert_contains "${ps_wrapper}" "Resolve-SfsRawArgs" "ps1 raw arg fallback"
assert_contains "${ps_wrapper}" "SFS_NATIVE_RAW_ARGS" "ps1 reads raw arg tail"
assert_contains "${ps_wrapper}" "Write-SfsArgTrace" "ps1 exposes opt-in Windows arg trace"
assert_contains "${ps_wrapper}" "SFS_ARGTRACE_" "ps1 writes stable arg trace markers"
assert_contains "${ps_wrapper}" "PS_SELECTED_SOURCE" "ps1 traces selected arg source"
assert_contains "${ps_wrapper}" "PS_FINAL_ARGS" "ps1 traces final resolved args"
assert_contains "${ps_wrapper}" 'function Test-SfsUsableArgs([string[]] $Items)' "ps1 usable-args guard avoids the broken Args parameter name"
if grep -Fq -- 'function Test-SfsUsableArgs([string[]] $Args)' "${ps_wrapper}"; then
  fail "ps1 usable-args guard must not name its parameter Args; that made env args look empty on the Windows runner"
fi
if grep -Eq '\[string\[\]\] \$Args|@Args|-Args \$SfsArgs' "${ps_wrapper}"; then
  fail "ps1 must not use Args as a parameter/splat/named call; Windows PowerShell treated it like the automatic args variable"
fi
assert_contains "${ps_wrapper}" "Test-SfsUsableArgs" "ps1 treats empty env arg arrays as unusable"
assert_contains "${ps_wrapper}" "Resolve-SfsSavedCmdLineArgs" "ps1 saved cmdline fallback"
assert_contains "${ps_wrapper}" "SFS_NATIVE_CMDLINE" "ps1 reads batch-captured original cmd line"
assert_contains "${ps_wrapper}" "Resolve-SfsParentCmdLineArgs" "ps1 parent cmdline fallback"
assert_contains "${ps_wrapper}" "Get-CimInstance -ClassName Win32_Process" "ps1 reads parent cmd.exe command line"
assert_contains "${ps_wrapper}" "Resolve-SfsCmdLineArgs" "ps1 cmdcmdline fallback"
assert_contains "${ps_wrapper}" "CMDCMDLINE" "ps1 reads original cmd command line"
assert_contains "${ps_wrapper}" "Split-SfsCommandLine" "ps1 command-line splitter"
assert_contains "${ps_wrapper}" "Trim-SfsShellControlTail" "ps1 trims cmd.exe shell-control tail from saved command line"
assert_contains "${ps_wrapper}" "Resolve-SfsArgsAfterCommandName" "ps1 extracts args after sfs.cmd before whitespace splitting parent cmdline"
assert_contains "${ps_wrapper}" "Test-SfsCommandBoundaryAfter" "ps1 checks command-name boundary before parsing parent cmdline"
assert_contains "${ps_wrapper}" 'if (-not (Test-SfsUsableArgs $SfsArgs))' "ps1 raw/cmdline fallbacks are gated by usable args"
assert_contains "${ps_wrapper}" 'Resolve-SfsArgs -ParamArgs $SfsRawArgs -AutomaticArgs @() -UnboundArgs @()' "ps1 raw args fallback order"
assert_contains "${ps_wrapper}" 'Resolve-SfsArgs -ParamArgs $SfsSavedCmdLineArgs -AutomaticArgs @() -UnboundArgs @()' "ps1 saved cmdline args fallback order"
assert_contains "${ps_wrapper}" 'Resolve-SfsArgs -ParamArgs $SfsParentCmdLineArgs -AutomaticArgs @() -UnboundArgs @()' "ps1 parent cmdline args fallback order"
assert_contains "${ps_wrapper}" 'Resolve-SfsArgs -ParamArgs $SfsCmdLineArgs -AutomaticArgs @() -UnboundArgs @()' "ps1 cmdcmdline args fallback order"
assert_contains "${ps_wrapper}" 'Resolve-SfsArgs -ParamArgs $SfsEnvArgs -AutomaticArgs $SfsParamArgs -UnboundArgs $args' "ps1 env/param/automatic args fallback"
assert_contains "${ps_wrapper}" 'Resolve-SfsArgs -ParamArgs @() -AutomaticArgs @() -UnboundArgs $MyInvocation.UnboundArguments' "ps1 unbound args final fallback"
assert_contains "${ps_wrapper}" 'Invoke-SfsNativeReadonly -InvocationArgs $SfsArgs' "ps1 passes resolved args as one array"
assert_contains "${ps_wrapper}" 'Invoke-ScoopSelfUpgrade -InvocationArgs $SfsArgs' "ps1 self-upgrade sees the full resolved arg array"
assert_contains "${ps_wrapper}" "Resolve-SfsScoopCurrentScriptPath" "ps1 reloads through Scoop current after self-upgrade"
assert_contains "${ps_wrapper}" "Normalize-SfsScoopReloadArgs" "ps1 canonicalizes Scoop self-upgrade reload args"
assert_contains "${ps_wrapper}" '$items[$cmdIndex] = "update"' "ps1 maps Windows upgrade reloads to canonical update"
assert_contains "${ps_wrapper}" '$item -in @("--yes", "-y")' "ps1 strips wrapper-level yes flags before Bash reload"
assert_contains "${ps_wrapper}" 'function Set-SfsNativeArgEnv([string[]] $InvocationArgs)' "ps1 rewrites the env arg bridge before reloading updated runtime"
assert_contains "${ps_wrapper}" 'Remove-Item "Env:SFS_NATIVE_ARG_$i"' "ps1 clears stale numbered env args before reload"
assert_contains "${ps_wrapper}" 'Set-Item "Env:SFS_NATIVE_ARG_$($i + 1)"' "ps1 writes normalized numbered env args before reload"
assert_contains "${ps_wrapper}" '$env:SFS_NATIVE_ARGC = [string] $newCount' "ps1 rewrites env argc before reload"
assert_contains "${ps_wrapper}" '$env:SFS_NATIVE_CMDLINE = if ($rawArgs) { "sfs.cmd $rawArgs" } else { "sfs.cmd" }' "ps1 rewrites saved cmdline with normalized reload args"
assert_contains "${ps_wrapper}" '$reloadArgs = [string[]] @(Normalize-SfsScoopReloadArgs $InvocationArgs)' "ps1 self-upgrade reload normalizes invocation args and preserves one-token arrays"
assert_contains "${ps_wrapper}" 'Set-SfsNativeArgEnv $reloadArgs' "ps1 self-upgrade reload replaces stale env args with canonical update"
assert_contains "${ps_wrapper}" '$reloadScriptPath = Resolve-SfsScoopCurrentScriptPath $CurrentScriptPath' "ps1 resolves the post-update current script before reload"
assert_contains "${ps_wrapper}" 'Write-SfsArgTrace "PS_RELOAD_SCRIPT" $reloadScriptPath' "ps1 traces self-upgrade reload script path"
assert_contains "${ps_wrapper}" 'Write-SfsArgTrace "PS_RELOAD_ARGS" $reloadArgs' "ps1 traces self-upgrade reload args"
assert_contains "${ps_wrapper}" '& $reloadScriptPath @reloadArgs' "ps1 self-upgrade reload splats normalized arg array"
if grep -Fq '& $CurrentScriptPath @InvocationArgs' "${ps_wrapper}"; then
  echo "ps1 self-upgrade reload still splats possibly scalar InvocationArgs directly" >&2
  exit 1
fi
if grep -Fq '& $CurrentScriptPath @reloadArgs' "${ps_wrapper}"; then
  echo "ps1 self-upgrade reload still targets the pre-update script path" >&2
  exit 1
fi
assert_contains "${ps_wrapper}" '$bashArgs = [string[]] @($SfsArgs)' "ps1 bash bridge preserves whole arg tokens"
assert_contains "${ps_wrapper}" 'Write-SfsArgTrace "PS_BASH_ARGS" $bashArgs' "ps1 traces final bash bridge args"
assert_contains "${ps_wrapper}" '& $bash (Convert-ToBashPath $sfsSh) @bashArgs' "ps1 bash bridge splats normalized arg array"
if grep -Fq '& $bash (Convert-ToBashPath $sfsSh) @SfsArgs' "${ps_wrapper}"; then
  echo "ps1 bash bridge still splats possibly scalar SfsArgs directly" >&2
  exit 1
fi
assert_contains "${ps_wrapper}" '$resolved[0] -eq "--%"' "ps1 stop-parsing token normalization"
assert_contains "${ps_wrapper}" "Enable-SfsUtf8Bridge" "ps1 utf8 bridge"
assert_contains "${ps_wrapper}" "Invoke-ScoopSelfUpgrade" "ps1 owns Scoop self-upgrade"
assert_contains "${ps_wrapper}" "Enable-SfsPowerShellUtility" "ps1 prepares PowerShell utility module before Scoop self-upgrade"
assert_contains "${ps_wrapper}" "Add-SfsPowerShellModulePath" "ps1 restores WindowsPowerShell module paths before Scoop self-upgrade"
assert_contains "${ps_wrapper}" "Install-SfsGetFileHashFallback" "ps1 installs a Get-FileHash fallback for Scoop self-upgrade"
assert_contains "${ps_wrapper}" "function global:Get-FileHash" "ps1 fallback exposes Get-FileHash to Scoop scripts"
assert_contains "${ps_wrapper}" "[System.IO.Stream] \$InputStream" "ps1 Get-FileHash fallback supports Scoop stream hashing"
assert_contains "${ps_wrapper}" "Import-Module Microsoft.PowerShell.Utility" "ps1 imports Get-FileHash provider before Scoop self-upgrade"
assert_contains "${ps_wrapper}" "Get-Command Get-FileHash" "ps1 verifies Get-FileHash exists before Scoop self-upgrade"
assert_contains "${ps_wrapper}" "\$env:LC_CTYPE = \"C.UTF-8\"" "ps1 bash utf8 locale"
assert_contains "${ps_wrapper}" "Invoke-SfsNativeStatus" "ps1 native status"
assert_contains "${ps_wrapper}" "Invoke-SfsNativeContext" "ps1 native context"
assert_contains "${ps_wrapper}" "Invoke-SfsNativeGuide" "ps1 native guide"
assert_contains "${ps_wrapper}" "Native read-only helper for Windows agents. It does not start Git Bash." "ps1 native context help"
assert_contains "${windows_discovery}" "plugin filesystem-direct deploy failed" "Windows cli-discovery catches A-2 deploy errors"

while IFS= read -r -d '' windows_script; do
  if perl -ne 'if (/[^\x00-\x7F]/) { exit 1 }' "${windows_script}"; then
    :
  else
    fail "Windows PowerShell/cmd scripts must stay ASCII for BOM-less Windows PowerShell 5.1 parsing: ${windows_script}"
  fi
done < <(find "${DIST_DIR}" -type f \( -name '*.ps1' -o -name '*.cmd' \) -print0)

if command -v powershell.exe >/dev/null 2>&1; then
  ps_script="${ps_wrapper}"
  if command -v cygpath >/dev/null 2>&1; then
    ps_script="$(cygpath -w "${ps_wrapper}")"
  fi
  context_out="$(powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${ps_script}" context cat kernel 2>&1)"
  case "${context_out}" in
    *"SFS Kernel"* ) ;;
    *) fail "PowerShell -File context cat kernel did not receive args: ${context_out}" ;;
  esac

  tmp_status="$(mktemp -d "${TMPDIR:-/tmp}/sfs-ps-status.XXXXXX")"
  set +e
  status_out="$(cd "${tmp_status}" && powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${ps_script}" status 2>&1)"
  status_rc=$?
  set -e
  rm -rf "${tmp_status}"
  [[ "${status_rc}" -ne 0 ]] || fail "PowerShell -File status without .sfs-local should fail"
  case "${status_out}" in
    *"no .sfs-local found"* ) ;;
    *) fail "PowerShell -File status fell back to usage or wrong output: ${status_out}" ;;
  esac
fi

for adapter in "${adapter_files[@]}"; do
  assert_contains "${adapter}" "sfs.cmd <command>" "adapter Windows command ${adapter}"
  assert_contains "${adapter}" "Win32 error 5" "adapter Git Bash sandbox recovery ${adapter}"
  assert_contains "${adapter}" "sfs.cmd status" "adapter native status ${adapter}"
  assert_contains "${adapter}" "sfs.cmd context" "adapter native context ${adapter}"
  assert_contains "${adapter}" "Empty adapter output is not success" "adapter no empty success ${adapter}"
  assert_contains "${adapter}" ".sfs-local/current-sprint" "adapter start artifact verification ${adapter}"
done
assert_contains "${codex_global_skill}" "sfs.cmd context cat" "global Codex Windows native context cat"
assert_contains "${codex_project_skill}" "sfs.cmd context cat" "project Codex Windows native context cat"

assert_contains "${DIST_DIR}/BEGINNER-GUIDE.md" "sfs.cmd --help" "beginner Windows help"
assert_contains "${DIST_DIR}/BEGINNER-GUIDE.md" "sfs.cmd context cat kernel" "beginner Windows native context"
assert_contains "${DIST_DIR}/GUIDE.md" "couldn't create signal pipe, Win32 error 5" "guide Windows Codex troubleshooting"
assert_contains "${DIST_DIR}/GUIDE.md" "sfs.cmd context cat kernel" "guide Windows native context"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "sfs.cmd context cat kernel" "Windows CI sfs.cmd native context"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "SFS_NATIVE_ARGC" "Windows CI verifies hardened sfs.cmd shim env bridge"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "SFS_NATIVE_RAW_ARGS" "Windows CI verifies hardened sfs.cmd shim raw arg bridge"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "SFS_WINDOWS_ARG_TRACE" "Windows CI enables opt-in arg trace before accepting sfs.cmd version"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "SFS_ARGTRACE_PS_SELECTED_SOURCE=env" "Windows CI proves env bridge selected source"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "SFS_ARGTRACE_PS_FINAL_ARGS=.*version" "Windows CI proves version reaches sfs.ps1"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "Tee-Object -Variable upgradeTrace" "Windows CI streams upgrade logs live"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "SFS_UPGRADE_TRACE" "Windows CI enables opt-in Bash upgrade trace while diagnosing self-upgrade hangs"
if grep -Fq '$upgradeLines = & sfs.cmd upgrade' "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml"; then
  fail "Windows CI must not assign the Tee-Object pipeline; assignment captures output and hides live trace logs"
fi
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "sfs.cmd upgrade live trace" "Windows CI groups upgrade trace logs"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "sfs.cmd upgrade" "Windows CI tests user-facing upgrade spelling"
if grep -Fq 'sfs.cmd upgrade --yes' "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml"; then
  fail "Windows CI must not pass wrapper-level --yes through sfs.cmd upgrade; sfs.ps1 canonicalizes upgrade to update after self-upgrade"
fi
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "timeout-minutes: 15" "Windows CI bounds the self-upgrade smoke step"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "SFS_NATIVE_CMDLINE" "Windows CI verifies hardened sfs.cmd shim cmdline bridge"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" '$shimText -notmatch "%\*"' "Windows CI verifies hardened sfs.cmd shim positional fallback"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "sfs.cmd version" "Windows CI PowerShell sfs.cmd version"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "sfs.cmd init --layout thin --yes" "Windows CI PowerShell sfs.cmd init"
assert_contains "${upgrade_sh}" "sfs_is_ci" "upgrade.sh detects CI before reopening /dev/tty"
assert_contains "${upgrade_sh}" "trace_upgrade" "upgrade.sh has opt-in phase trace for diagnosing CI hangs"
assert_contains "${upgrade_sh}" 'SFS_UPGRADE_TRACE' "upgrade.sh trace is gated behind SFS_UPGRADE_TRACE"
assert_contains "${upgrade_sh}" 'if ! sfs_is_ci && [ ! -t 0 ] && [ -e /dev/tty ]; then' "upgrade.sh does not block GitHub Actions on interactive tty prompts"
assert_contains "${sfs_bin}" '-y|--yes)' "Bash sfs accepts wrapper-level yes flag as a compatibility no-op"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "sfs.cmd agent install all" "Windows CI PowerShell sfs.cmd agent install"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "sfs.cmd start --id ci-sprint-test" "Windows CI sfs.cmd start smoke"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" '"goal":"sprint-create-test"' "Windows CI sprint_start goal evidence"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "SFS_TEST_PREVIOUS_VERSION" "Windows CI installs previous local Scoop package first"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "SFS_TEST_BROKEN_VERSION" "Windows CI installs known-broken package for recovery"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" 'refs/tags/v${brokenVersion}:refs/tags/v${brokenVersion}' "Windows CI braces PowerShell tag refspec interpolation"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" 'git archive --format=zip --output="$brokenArchive" --prefix="$brokenExtractDir/" "v${brokenVersion}"' "Windows CI braces PowerShell archive tag interpolation"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" 'Join-Path $env:GITHUB_WORKSPACE "packaging/scoop/sfs.json.template"' "Windows CI reads Scoop template from checkout after Set-Location"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "sfs.cmd upgrade" "Windows CI sfs.cmd self-upgrade smoke"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "SFS_NATIVE_RAW_ARGS" "Windows CI verifies hardened shim raw arg bridge"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "recovered sfs.cmd arg trace" "Windows CI traces recovered shim arg delivery"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "SFS_NATIVE_CMDLINE" "Windows CI verifies hardened shim saved cmdline bridge"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "Smoke saved cmdline fallback" "Windows CI forces saved cmdline fallback"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" 'cmd.exe /d /c "sfs.cmd version && sfs.cmd --help >NUL"' "Windows CI saved cmdline fallback includes shell-control tail"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "Smoke parent cmdline fallback" "Windows CI forces parent cmdline fallback"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "sfs parent-cmdline-project" "Windows CI parent fallback covers spaces before sfs.cmd in path"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "parent-cmdline-start" "Windows CI parent cmdline fallback exercises start"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "Scoop clones buckets when they are added" "Windows CI refreshes cloned bucket before broken package install"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "Direct Scoop recovery must bypass the broken wrapper" "Windows CI refreshes cloned bucket before direct recovery update"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "scoop update sfs" "Windows CI direct Scoop recovery smoke"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "expected broken 0.6.49 sfs.cmd version to print usage" "Windows CI proves broken 0.6.49 before recovery"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "TIVE_READONLY_DONE|LF_UPGRADE_DONE" "Windows CI batch tail-fragment rejection"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "sfs.cmd start --id ci-korean-sprint-test" "Windows CI Korean sfs.cmd start smoke"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" '"goal":"스프린트 생성 테스트"' "Windows CI Korean sprint_start goal evidence"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" 'cmd /c "sfs.cmd version' "Windows CI cmd.exe uses sfs.cmd"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" 'command -v sfs && sfs version' "Windows CI Git Bash keeps bare sfs"
if grep -Eq '^[[:space:]]+sfs (version|--help|init|status|auth|agent install)' "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml"; then
  fail "Windows PowerShell smoke must not use bare sfs for PowerShell/cmd commands"
fi
if grep -Fq -- 'cmd /c "sfs version' "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml"; then
  fail "Windows cmd.exe smoke must use sfs.cmd, not bare sfs"
fi
assert_contains "${DIST_DIR}/packaging/scoop/README.md" 'sfs.cmd -> sfs.ps1 -> bin/sfs' "Scoop README documents PowerShell bridge"
assert_contains "${DIST_DIR}/packaging/scoop/README.md" 'sfs.cmd upgrade' "Scoop README documents wrapper-owned upgrade smoke"
if grep -Fq -- "scoop update sfs --force" "${DIST_DIR}/packaging/scoop/README.md"; then
  fail "Scoop README must not document the old direct scoop update smoke as the Windows wrapper proof"
fi

echo "test-windows-agent-adapter-fallback: OK"
