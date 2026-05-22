#!/usr/bin/env bash
# 긴 host session 토큰 누적을 fresh-session handoff 로 끊는 가드 회귀 테스트.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

. "${SCRIPT_DIR}/helpers/doc-search.sh"

assert_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"

  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  sfs_doc_contains "${file}" "${needle}" || fail "${label}: missing '${needle}'"
}

context="${DIST_DIR}/templates/.sfs-local-template/context"
index="${context}/_INDEX.md"
kernel="${context}/kernel.md"
policy="${context}/policies/session-continuation-guard.md"
token_policy="${context}/policies/token-harness.md"
firewall="${context}/policies/runtime-token-firewall.md"
loop="${context}/commands/loop.md"
implement="${context}/commands/implement.md"
review="${context}/commands/review.md"
model_profiles="${DIST_DIR}/templates/.sfs-local-template/model-profiles.yaml"

assert_contains "${index}" "policies/session-continuation-guard.md" "index routes session continuation guard"

assert_contains "${policy}" "SFS upgrades runtime files and project-local context" "policy upgrade scope"
assert_contains "${policy}" "cannot shrink the already-open Claude/Codex/Gemini conversation" "policy cannot shrink host history"
assert_contains "${policy}" "token meter is already 30% or higher" "policy 30 percent threshold"
assert_contains "${policy}" "token meter reaches 50%" "policy 50 percent threshold"
assert_contains "${policy}" "autonomous loop resumes" "policy loop wakeup trigger"
assert_contains "${policy}" "full conversation history" "policy full history bridge trigger"
assert_contains "${policy}" "fresh session" "policy fresh session handoff"
assert_contains "${policy}" '`.sfs-local/` size is a tidy signal' "policy workbench size boundary"

assert_contains "${kernel}" "Session Continuation Guard is ambient" "kernel ambient guard"
assert_contains "${kernel}" '`sfs upgrade` cannot shrink an already' "kernel upgrade cannot shrink"
assert_contains "${kernel}" "30% or higher before a new" "kernel 30 threshold"
assert_contains "${kernel}" "50% or higher before a new gate/loop/review handoff" "kernel 50 threshold"

assert_contains "${token_policy}" "Apply Session Continuation Guard" "token policy applies guard"
assert_contains "${token_policy}" "cannot shrink the already-open LLM conversation" "token policy cannot shrink"
assert_contains "${token_policy}" "write a compact handoff" "token policy compact handoff"

assert_contains "${firewall}" "Session continuation budget is separate from bridge budget" "firewall session budget"
assert_contains "${firewall}" "Stop, capture a fresh-session handoff" "firewall fresh handoff"

assert_contains "${loop}" "Long loops must not keep waking the same host conversation forever" "loop wakeup guard"
assert_contains "${loop}" "after more than two wakeups" "loop wakeup threshold"
assert_contains "${implement}" "Before starting a new implementation slice in a long host conversation" "implement guard"
assert_contains "${review}" "Review handoff must also follow Session Continuation Guard" "review guard"

assert_contains "${model_profiles}" "Session Continuation Guard" "model profiles guard"
assert_contains "${model_profiles}" "30%+ before a new WU/sprint action" "model profiles 30 threshold"

docs=(
  "${DIST_DIR}/GUIDE.md"
  "${DIST_DIR}/docs/en/guide.md"
  "${DIST_DIR}/docs/ko/index.md"
  "${DIST_DIR}/docs/en/index.md"
  "${DIST_DIR}/docs/ko/current-product-shape.md"
  "${DIST_DIR}/docs/en/current-product-shape.md"
)

for file in "${docs[@]}"; do
  assert_contains "${file}" "Session Continuation Guard" "docs guard ${file}"
  assert_contains "${file}" "sfs upgrade" "docs upgrade boundary ${file}"
  assert_contains "${file}" "30%" "docs 30 threshold ${file}"
  assert_contains "${file}" "50%" "docs 50 threshold ${file}"
  assert_contains "${file}" "fresh session" "docs fresh session ${file}"
done

adapter_files=(
  "${DIST_DIR}/templates/AGENTS.md.template"
  "${DIST_DIR}/templates/CLAUDE.md.template"
  "${DIST_DIR}/templates/GEMINI.md.template"
  "${DIST_DIR}/templates/codex-skill/SKILL.md"
  "${DIST_DIR}/templates/.agents/skills/sfs/SKILL.md"
  "${DIST_DIR}/templates/.claude/commands/sfs.md"
  "${DIST_DIR}/templates/.gemini/commands/sfs.toml"
  "${DIST_DIR}/templates/.codex/prompts/sfs.md"
  "${DIST_DIR}/commands/sfs.toml"
  "${DIST_DIR}/plugins/solon/commands/sfs.md"
)

for file in "${adapter_files[@]}"; do
  assert_contains "${file}" "Session Continuation Guard" "adapter guard ${file}"
  assert_contains "${file}" "cannot shrink an already-open LLM conversation" "adapter cannot shrink ${file}"
  assert_contains "${file}" "30%+ before a new WU/sprint action" "adapter 30 threshold ${file}"
  assert_contains "${file}" "50%+ before a new gate/loop/review" "adapter 50 threshold ${file}"
  assert_contains "${file}" "fresh session" "adapter fresh session ${file}"
done

echo "test-session-continuation-token-guard: OK"
