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
ps_wrapper="${DIST_DIR}/bin/sfs.ps1"
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
assert_contains "${cmd_wrapper}" ":sfs_collect_args" "cmd env arg collection loop"
assert_contains "${cmd_wrapper}" "set \"SFS_NATIVE_ARG_%%I=%~1\"" "cmd stores numbered env args"
assert_contains "${cmd_wrapper}" "-File \"%SFS_NATIVE_SCRIPT%\" %* & exit /b !ERRORLEVEL!" "cmd powershell env/positional bridge exits on parsed line"
assert_contains "${scoop_template}" '"bin\\sfs.ps1"' "Scoop manifest uses PowerShell shim entrypoint"
if grep -Fq -- '"bin\\sfs.cmd"' "${scoop_template}"; then
  fail "Scoop manifest must not shim through bin\\sfs.cmd; generated cmd shims lost args in the field"
fi
assert_contains "${scoop_post_install}" "Install-SfsScoopShims" "Scoop post-install hardens generated shims"
assert_contains "${scoop_post_install}" 'Set-Content -LiteralPath (Join-Path $shimDir "sfs.cmd")' "Scoop post-install overwrites sfs.cmd shim"
assert_contains "${scoop_post_install}" 'Set-Content -LiteralPath (Join-Path $shimDir "sfs.ps1")' "Scoop post-install overwrites sfs.ps1 shim"
assert_contains "${scoop_post_install}" 'Set-Content -LiteralPath (Join-Path $shimDir "sfs")' "Scoop post-install installs Git Bash sfs shim"
assert_contains "${scoop_post_install}" 'set "SFS_NATIVE_ARGC=0"' "Scoop sfs.cmd shim initializes env arg bridge"
assert_contains "${scoop_post_install}" 'set "SFS_NATIVE_ARG_%%I=%~1"' "Scoop sfs.cmd shim stores numbered args"
assert_contains "${scoop_post_install}" '-File "%SFS_NATIVE_SCRIPT%" %* & exit /b !ERRORLEVEL!' "Scoop sfs.cmd shim keeps positional fallback and exits on the same parsed line"
assert_contains "${scoop_post_install}" '& $target @args' "Scoop sfs.ps1 shim forwards PowerShell args"
assert_contains "${scoop_post_install}" 'exec bash "$_sfs_path" "$@"' "Scoop Git Bash shim forwards args"
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
assert_contains "${ps_wrapper}" "Resolve-SfsCmdLineArgs" "ps1 cmdcmdline fallback"
assert_contains "${ps_wrapper}" "CMDCMDLINE" "ps1 reads original cmd command line"
assert_contains "${ps_wrapper}" "Split-SfsCommandLine" "ps1 command-line splitter"
assert_contains "${ps_wrapper}" 'Resolve-SfsArgs -ParamArgs $SfsCmdLineArgs -AutomaticArgs @() -UnboundArgs @()' "ps1 cmdcmdline args fallback order"
assert_contains "${ps_wrapper}" 'Resolve-SfsArgs -ParamArgs $SfsEnvArgs -AutomaticArgs $SfsParamArgs -UnboundArgs $args' "ps1 env/param/automatic args fallback"
assert_contains "${ps_wrapper}" 'Resolve-SfsArgs -ParamArgs @() -AutomaticArgs @() -UnboundArgs $MyInvocation.UnboundArguments' "ps1 unbound args final fallback"
assert_contains "${ps_wrapper}" 'Invoke-SfsNativeReadonly -Args $SfsArgs' "ps1 passes resolved args as one array"
assert_contains "${ps_wrapper}" 'Invoke-ScoopSelfUpgrade -Args $SfsArgs' "ps1 self-upgrade sees the full resolved arg array"
assert_contains "${ps_wrapper}" '$resolved[0] -eq "--%"' "ps1 stop-parsing token normalization"
assert_contains "${ps_wrapper}" "Enable-SfsUtf8Bridge" "ps1 utf8 bridge"
assert_contains "${ps_wrapper}" "Invoke-ScoopSelfUpgrade" "ps1 owns Scoop self-upgrade"
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
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" '$shimText -notmatch "%\*"' "Windows CI verifies hardened sfs.cmd shim positional fallback"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "sfs.cmd version" "Windows CI PowerShell sfs.cmd version"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "sfs.cmd init --layout thin --yes" "Windows CI PowerShell sfs.cmd init"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "sfs.cmd agent install all" "Windows CI PowerShell sfs.cmd agent install"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "sfs.cmd start --id ci-sprint-test" "Windows CI sfs.cmd start smoke"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" '"goal":"sprint-create-test"' "Windows CI sprint_start goal evidence"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "SFS_TEST_PREVIOUS_VERSION" "Windows CI installs previous local Scoop package first"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "SFS_TEST_BROKEN_VERSION" "Windows CI installs known-broken package for recovery"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" 'Join-Path $env:GITHUB_WORKSPACE "packaging/scoop/sfs.json.template"' "Windows CI reads Scoop template from checkout after Set-Location"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "sfs.cmd upgrade" "Windows CI sfs.cmd self-upgrade smoke"
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
