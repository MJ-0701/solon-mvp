#!/usr/bin/env bash
# Obsidian 위키가 host-local 도구 묶음을 project SoT 로 승격하지 않는지 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONTEXT_DIR="${DIST_DIR}/templates/.sfs-local-template/context"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  grep -Fiq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

assert_not_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  if grep -Fqi -- "${needle}" "${file}"; then
    fail "${label}: unexpected '${needle}' in ${file}"
  fi
}

boundary_files=(
  "${CONTEXT_DIR}/kernel.md"
  "${CONTEXT_DIR}/policies/obsidian-llm-wiki.md"
  "${CONTEXT_DIR}/policies/obsidian-llm-wiki.ko.md"
  "${DIST_DIR}/templates/codex-skill/SKILL.md"
  "${DIST_DIR}/templates/.agents/skills/sfs/SKILL.md"
  "${DIST_DIR}/docs/en/current-product-shape/19-obsidian-llm-wiki-continuity.md"
  "${DIST_DIR}/docs/ko/current-product-shape/19-obsidian-llm-wiki-continuity.md"
)

named_tool="$(printf '%s%s' 'g' 'stack')"
named_folder="$(printf '%s%s%s' '.' 'g' 'stack')"

for file in "${boundary_files[@]}"; do
  assert_contains "${file}" "host-local" "host-local boundary present"
  assert_not_contains "${file}" "${named_tool}" "no named host-local tool promotion"
  assert_not_contains "${file}" "${named_folder}" "no named user-home folder promotion"
done

assert_contains "${CONTEXT_DIR}/policies/obsidian-llm-wiki.md" "not project SSoT, wiki roots, install targets, or migration sources" "EN no host-local SoT"
assert_contains "${CONTEXT_DIR}/policies/obsidian-llm-wiki.ko.md" "project SSoT, wiki root" "KO no host-local SoT"

echo "test-obsidian-host-local-boundary: OK"
