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
assert_contains "${cmd_wrapper}" ":native_usage" "cmd native usage"
assert_contains "${cmd_wrapper}" ":native_guide" "cmd native guide"
assert_contains "${cmd_wrapper}" "status\" goto native_powershell_readonly_dispatch" "cmd native status dispatch"
assert_contains "${cmd_wrapper}" "context\" goto native_powershell_readonly_dispatch" "cmd native context dispatch"
assert_contains "${cmd_wrapper}" "version\" goto native_powershell_readonly_dispatch" "cmd native version dispatch"
assert_contains "${cmd_wrapper}" ":native_powershell_readonly_dispatch" "cmd native powershell dispatch"
assert_contains "${cmd_wrapper}" "sfs.cmd guide [--path^|--print]" "cmd native guide help"
assert_contains "${ps_wrapper}" "Invoke-SfsNativeStatus" "ps1 native status"
assert_contains "${ps_wrapper}" "Invoke-SfsNativeContext" "ps1 native context"
assert_contains "${ps_wrapper}" "Native read-only helper for Windows agents. It does not start Git Bash." "ps1 native context help"

native_line="$(line_number "${cmd_wrapper}" "call :maybe_native_readonly %*")"
bash_line="$(line_number "${cmd_wrapper}" "if defined SFS_BASH")"
[[ -n "${native_line}" && -n "${bash_line}" ]] || fail "missing native or bash probe line"
(( native_line < bash_line )) || fail "native read-only fallback must run before Git Bash lookup"

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

echo "test-windows-agent-adapter-fallback: OK"
