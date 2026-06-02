#!/usr/bin/env bash
# BWU-4: project-scoped SFS skill and suggest-only Stop hook wiring.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() { echo "FAIL: $*" >&2; exit 1; }

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

hook="${DIST_DIR}/templates/.claude/hooks/solon-stop-suggest.sh"
install="${DIST_DIR}/install.sh"
skill="${DIST_DIR}/templates/.agents/skills/sfs/SKILL.md"
gitignore="${DIST_DIR}/.gitignore"

assert_contains "${hook}" "suggest-only" "hook suggest-only marker"
assert_contains "${hook}" "sfs agent doctor --fix" "hook agent doctor suggestion"
assert_contains "${hook}" "does not edit files" "hook no mutation statement"
assert_contains "${install}" "templates/.claude/hooks/solon-stop-suggest.sh" "install hook source"
assert_contains "${install}" ".claude/hooks/solon-stop-suggest.sh" "install hook target"
assert_contains "${skill}" "Host-local tool/skill bundles" "project-scoped skill boundary"
assert_contains "${gitignore}" "!templates/.claude/hooks/**" "hook template not ignored"
assert_contains "${gitignore}" "__pycache__/" "python cache remains ignored"

if grep -Eq 'git[[:space:]]+(add|commit|push)|rm[[:space:]]+-rf|mv[[:space:]]+-f|cp[[:space:]]' "${hook}"; then
  fail "hook must remain suggest-only; found mutating command"
fi

echo "test-path-scoped-stop-hook: OK"
