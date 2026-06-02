#!/usr/bin/env bash
# BWU-5/6/7: model-tier quick reference and founder lifecycle matrix.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() { echo "FAIL: $*" >&2; exit 1; }

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

method="${DIST_DIR}/docs/maintenance/methodology-7-step.md"
readme1="${DIST_DIR}/README/01-solon.md"
readme3="${DIST_DIR}/README/03-section.md"
readme5="${DIST_DIR}/README/05-section.md"

assert_contains "${method}" "Model-tier quick reference" "methodology model section"
assert_contains "${method}" "Advisor/CPO" "advisor route"
assert_contains "${method}" "gpt-5.3-codex" "codex helper route"
assert_contains "${method}" "Spark" "spark mechanical route"
assert_contains "${readme1}" "Founder 관점" "founder narrative"
assert_contains "${readme1}" "Idea" "founder idea"
assert_contains "${readme1}" "MVP" "founder MVP"
assert_contains "${readme1}" "Launch" "founder launch"
assert_contains "${readme1}" "Scale" "founder scale"
assert_contains "${readme3}" "| stage | Solon focus | Cowork/Chat | Code/CLI |" "founder matrix header"
assert_contains "${readme3}" "| Idea |" "founder matrix Idea"
assert_contains "${readme3}" "| Scale |" "founder matrix Scale"
assert_contains "${readme5}" "chat 에서 판단" "Cowork/chat role"
assert_contains "${readme5}" "code runtime" "Code runtime role"

echo "test-founder-model-routing-docs: OK"
