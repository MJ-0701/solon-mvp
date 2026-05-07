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

assert_contains "${cmd_wrapper}" "call :maybe_native_readonly %*" "cmd native fallback hook"
assert_contains "${cmd_wrapper}" "setlocal EnableExtensions EnableDelayedExpansion" "cmd delayed errorlevel expansion"
if grep -Fq -- "call :maybe_self_upgrade" "${cmd_wrapper}"; then
  fail "cmd wrapper must not run Scoop self-upgrade from the batch file that Scoop replaces"
fi
if grep -Fq -- "call scoop update" "${cmd_wrapper}"; then
  fail "cmd wrapper must not call scoop update directly; sfs.ps1 owns the stable self-upgrade"
fi
assert_contains "${cmd_wrapper}" ":native_usage" "cmd native usage"
assert_contains "${cmd_wrapper}" ":native_guide" "cmd native guide"
assert_contains "${cmd_wrapper}" "status\" goto native_powershell_readonly_dispatch" "cmd native status dispatch"
assert_contains "${cmd_wrapper}" "context\" goto native_powershell_readonly_dispatch" "cmd native context dispatch"
assert_contains "${cmd_wrapper}" "version\" goto native_powershell_readonly_dispatch" "cmd native version dispatch"
assert_contains "${cmd_wrapper}" ":native_powershell_readonly_dispatch" "cmd native powershell dispatch"
assert_contains "${cmd_wrapper}" "set \"SFS_ORIGINAL_ARGS=%*\"" "cmd top-level argument capture"
assert_contains "${cmd_wrapper}" "-File \"%SCRIPT_DIR%sfs.ps1\" %SFS_ORIGINAL_ARGS%" "cmd powershell top-level argument forwarding"
assert_contains "${cmd_wrapper}" "call :powershell_dispatch %* & exit /b !ERRORLEVEL!" "cmd non-native powershell bridge exits on parsed line"
assert_contains "${cmd_wrapper}" ":powershell_dispatch" "cmd powershell bridge label"
assert_contains "${cmd_wrapper}" "-File \"%SCRIPT_DIR%sfs.ps1\" %SFS_ORIGINAL_ARGS% & exit /b !ERRORLEVEL!" "cmd powershell dispatch exits on parsed line"
if grep -Fq -- "call exit /b %%ERRORLEVEL%%" "${cmd_wrapper}"; then
  fail "cmd wrapper must not use unstable CALL+ERRORLEVEL double expansion for post-upgrade exit"
fi
assert_contains "${cmd_wrapper}" "sfs.cmd guide [--path^|--print]" "cmd native guide help"
if grep -Fq -- "\"%BASH_EXE%\" \"%SFS_SH%\" %*" "${cmd_wrapper}"; then
  fail "cmd wrapper must not send mutating commands through the raw Git Bash %* bridge"
fi
if perl -0ne 'exit((/-File "%SCRIPT_DIR%sfs\.ps1" %SFS_ORIGINAL_ARGS%\r?\nexit \/b/) ? 0 : 1)' "${cmd_wrapper}"; then
  fail "cmd wrapper must not put PowerShell dispatch and exit on separate parsed lines during self-upgrade"
fi

if grep -Fq -- "ValueFromRemainingArguments" "${ps_wrapper}"; then
  fail "ps1 must not rely on ValueFromRemainingArguments; Windows PowerShell -File lost args in the field"
fi
assert_contains "${ps_wrapper}" 'Resolve-SfsArgs $args $MyInvocation.UnboundArguments' "ps1 automatic/unbound args fallback"
assert_contains "${ps_wrapper}" '$resolved[0] -eq "--%"' "ps1 stop-parsing token normalization"
assert_contains "${ps_wrapper}" "Enable-SfsUtf8Bridge" "ps1 utf8 bridge"
assert_contains "${ps_wrapper}" "Invoke-ScoopSelfUpgrade" "ps1 owns Scoop self-upgrade"
assert_contains "${ps_wrapper}" "\$env:LC_CTYPE = \"C.UTF-8\"" "ps1 bash utf8 locale"
assert_contains "${ps_wrapper}" "Invoke-SfsNativeStatus" "ps1 native status"
assert_contains "${ps_wrapper}" "Invoke-SfsNativeContext" "ps1 native context"
assert_contains "${ps_wrapper}" "Native read-only helper for Windows agents. It does not start Git Bash." "ps1 native context help"
assert_contains "${windows_discovery}" "plugin filesystem-direct deploy failed" "Windows cli-discovery catches A-2 deploy errors"

native_line="$(line_number "${cmd_wrapper}" "call :maybe_native_readonly %*")"
bridge_line="$(line_number "${cmd_wrapper}" "call :powershell_dispatch %*")"
[[ -n "${native_line}" && -n "${bridge_line}" ]] || fail "missing native or PowerShell bridge line"
(( native_line < bridge_line )) || fail "native read-only fallback must run before PowerShell bridge fallback"

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
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "sfs.cmd start --id ci-sprint-test" "Windows CI sfs.cmd start smoke"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" '"goal":"sprint-create-test"' "Windows CI sprint_start goal evidence"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "SFS_TEST_PREVIOUS_VERSION" "Windows CI installs previous local Scoop package first"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" 'Join-Path $env:GITHUB_WORKSPACE "packaging/scoop/sfs.json.template"' "Windows CI reads Scoop template from checkout after Set-Location"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "sfs.cmd upgrade" "Windows CI sfs.cmd self-upgrade smoke"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "TIVE_READONLY_DONE|LF_UPGRADE_DONE" "Windows CI batch tail-fragment rejection"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" "sfs.cmd start --id ci-korean-sprint-test" "Windows CI Korean sfs.cmd start smoke"
assert_contains "${DIST_DIR}/.github/workflows/windows-scoop-smoke.yml" '"goal":"스프린트 생성 테스트"' "Windows CI Korean sprint_start goal evidence"
assert_contains "${DIST_DIR}/packaging/scoop/README.md" 'sfs.cmd -> sfs.ps1 -> bin/sfs' "Scoop README documents PowerShell bridge"
assert_contains "${DIST_DIR}/packaging/scoop/README.md" 'sfs.cmd upgrade' "Scoop README documents wrapper-owned upgrade smoke"
if grep -Fq -- "scoop update sfs --force" "${DIST_DIR}/packaging/scoop/README.md"; then
  fail "Scoop README must not document the old direct scoop update smoke as the Windows wrapper proof"
fi

echo "test-windows-agent-adapter-fallback: OK"
