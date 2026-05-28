#!/usr/bin/env bash
# 하네스 엔지니어링 원칙이 SFS 런타임/문서/어댑터 표면에 고정되는지 검증한다.
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

  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

context="${DIST_DIR}/templates/.sfs-local-template/context"
kernel="${context}/kernel.md"
token_policy="${context}/policies/token-harness.md"
plan="${context}/commands/plan.md"
implement="${context}/commands/implement.md"
review="${context}/commands/review.md"
docs_en="${DIST_DIR}/docs/en/current-product-shape/17-token-harness-hygiene.md"
docs_ko="${DIST_DIR}/docs/ko/current-product-shape/17-token-harness-hygiene.md"

assert_contains "${kernel}" "Harness Engineering is ambient" "kernel ambient harness"
assert_contains "${kernel}" "active tool surface narrow" "kernel tool-surface narrowing"
assert_contains "${kernel}" "project-as-prompt" "kernel project-as-prompt"
assert_contains "${kernel}" "design decisions human-owned" "kernel human-owned design"

assert_contains "${token_policy}" "structure, not pleading" "token policy structure over pleading"
assert_contains "${token_policy}" "Tool-surface budget" "token policy tool budget"
assert_contains "${token_policy}" "Project-as-prompt audit" "token policy project prompt"
assert_contains "${token_policy}" "Verification automation" "token policy verification automation"
assert_contains "${token_policy}" "Human understanding boundary" "token policy human boundary"

assert_contains "${plan}" "human-owned understanding" "plan human understanding"
assert_contains "${plan}" "AI-owned execution" "plan AI execution"
assert_contains "${plan}" "project-as-prompt structure" "plan project prompt"
assert_contains "${implement}" "narrow active tools" "implement narrow tools"
assert_contains "${implement}" "human-owned design decisions" "implement human decisions"
assert_contains "${review}" "Harness Engineering contract" "review harness contract"
assert_contains "${review}" "narrow active tool surface" "review tool surface"
assert_contains "${review}" "project-as-prompt" "review project prompt"

assert_contains "${docs_en}" "raise the AI ceiling with structure, not pleading" "EN docs ceiling"
assert_contains "${docs_en}" "leave product understanding/design choices human-owned" "EN docs human boundary"
assert_contains "${docs_ko}" "부탁이 아니라 구조로 AI 의 천장을 높인다" "KO docs ceiling"
assert_contains "${docs_ko}" "제품 이해와 설계 판단은" "KO docs human boundary"

adapter_files=(
  "${DIST_DIR}/commands/sfs.toml"
  "${DIST_DIR}/plugins/solon/commands/sfs.md"
  "${DIST_DIR}/templates/codex-skill/SKILL.md"
  "${DIST_DIR}/templates/.agents/skills/sfs/SKILL.md"
  "${DIST_DIR}/templates/.claude/commands/sfs.md"
  "${DIST_DIR}/templates/.gemini/commands/sfs.toml"
  "${DIST_DIR}/templates/.codex/prompts/sfs.md"
)

for file in "${adapter_files[@]}"; do
  assert_contains "${file}" "Harness Engineering" "adapter harness ${file}"
done

assert_contains "${DIST_DIR}/templates/SFS.md.template" "sfs context cat kernel" "SFS template routes harness context"
assert_contains "${kernel}" "Harness Engineering is ambient" "kernel harness body"

echo "test-harness-engineering-guardrails: OK"
