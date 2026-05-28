#!/usr/bin/env bash
# Solon Status dashboard sustaining contract를 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${DIST_DIR}/.." && pwd)"
SPEC="${REPO_ROOT}/solon-status-report.md"

if [[ ! -f "${SPEC}" ]]; then
  echo "test-status-dashboard-contract: SKIP (owner dashboard spec is not packaged in this tree)"
  exit 0
fi

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"

  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

assert_not_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"

  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  if grep -Fq -- "${needle}" "${file}"; then
    fail "${label}: unexpected '${needle}'"
  fi
}

assert_contains "${SPEC}" "version: 0.6.17" "dashboard spec version"
assert_contains "${SPEC}" "evidence-preserving dashboard" "dashboard evidence-preserving title"
assert_contains "${SPEC}" "Token Diet 정합" "dashboard token diet alignment"
assert_contains "${SPEC}" "source/evidence/next/decision" "dashboard trace fields"
assert_contains "${SPEC}" "full clarity" "dashboard full clarity fallback"
assert_contains "${SPEC}" "plain-language decision brief" "dashboard decision clarity"
assert_contains "${SPEC}" "details/source" "dashboard source folding"
assert_contains "${SPEC}" "Sources" "dashboard source section"

for adapter in \
  "${DIST_DIR}/templates/codex-skill/SKILL.md" \
  "${DIST_DIR}/plugins/solon/commands/sfs.md" \
  "${DIST_DIR}/commands/sfs.toml"
do
  assert_contains "${adapter}" "compact console dashboard" "adapter dashboard style ${adapter}"
  assert_contains "${adapter}" "Compact output is quality-preserving only" "adapter token diet contract ${adapter}"
done
assert_contains "${DIST_DIR}/templates/SFS.md.template" "Compact output is quality-preserving only" "SFS router keeps output contract"
assert_contains "${DIST_DIR}/templates/SFS.md.template" "sfs context cat kernel" "SFS router delegates dashboard style"

assert_not_contains "${SPEC}" "📊 bkit Feature Usage" "dashboard no bkit usage footer"

echo "test-status-dashboard-contract: OK"
