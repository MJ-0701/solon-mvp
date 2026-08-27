#!/usr/bin/env bash
# 도메인 노하우가 AI 재사용 자산으로 라우팅되는지 검증한다.
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
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

policy="${CONTEXT_DIR}/policies/domain-knowledge-assets.md"
policy_ko="${CONTEXT_DIR}/policies/domain-knowledge-assets.ko.md"
kernel="${CONTEXT_DIR}/kernel.md"

assert_contains "${policy}" "AI makes generic coding and scaffolding more evenly available" "EN policy premise"
assert_contains "${policy}" "expert domain judgment made legible enough for AI to reuse" "EN policy moat"
assert_contains "${policy}" "Skill/knowledge pack/review lens" "EN policy asset shapes"
assert_contains "${policy}" "Six Required Council Roles Asset Loop" "EN policy council-role loop"
assert_contains "${policy}" "five organization divisions" "EN policy five-division boundary"
assert_contains "${policy}" "Taxonomy is the cross-cutting product function/lens" "EN policy taxonomy boundary"
assert_contains "${policy}" "asset_candidate" "EN policy asset candidate"
assert_contains "${policy}" "Record source, owner/expert, confidence, gaps, and promotion status" "EN policy source ownership"
assert_contains "${policy}" "shared outside the private project" "EN policy human approval"
assert_contains "${policy}" "reference absorption guard" "EN reference absorption guard"
assert_contains "${policy}" "Reference is input, not direction" "EN reference not direction"
assert_contains "${policy}" "Vendor feature is evidence, not product identity" "EN vendor not identity"
assert_contains "${policy}" "wiki-only/deferred" "EN ambiguous reference defer"
assert_contains "${policy}" "Root knowledge beats tool fashion" "EN policy root knowledge"
assert_contains "${policy}" "Domain expertise is a build/no-build gate" "EN policy domain gate"
assert_contains "${policy_ko}" "AI 가 일반 코딩과 scaffold 를 평준화" "KO policy premise"
assert_contains "${policy_ko}" "도메인 판단" "KO policy moat"
assert_contains "${policy_ko}" "Skill/knowledge pack/review lens" "KO policy skill shape"
assert_contains "${policy_ko}" "6개 필수 council role" "KO policy council-role loop"
assert_contains "${policy_ko}" "organization division은 다섯 개" "KO policy five-division boundary"
assert_contains "${policy_ko}" "Taxonomy는" "KO policy taxonomy role"
assert_contains "${policy_ko}" "cross-cutting product function/lens" "KO policy taxonomy boundary"
assert_contains "${policy_ko}" "asset_candidate" "KO policy asset candidate"
assert_contains "${policy_ko}" "source, owner/expert, confidence, gap, promotion status" "KO policy source ownership"
assert_contains "${policy_ko}" "명시적 사람 승인" "KO policy human approval"
assert_contains "${policy_ko}" "reference absorption guard" "KO reference absorption guard"
assert_contains "${policy_ko}" "Reference 는 input 이지 direction 이 아니다" "KO reference not direction"
assert_contains "${policy_ko}" "Vendor feature 는 evidence 이지 product" "KO vendor not identity"
assert_contains "${policy_ko}" "wiki-only/deferred" "KO ambiguous reference defer"
assert_contains "${policy_ko}" "뿌리지식은 tool 유행보다 오래" "KO policy root knowledge"
assert_contains "${policy_ko}" "도메인 전문성은 build/no-build gate" "KO policy domain gate"

assert_contains "${CONTEXT_DIR}/_INDEX.md" "policies/domain-knowledge-assets.md" "context index policy"
assert_contains "${CONTEXT_DIR}/kernel.md" "Domain knowledge is an AI-era moat" "kernel domain moat"
assert_contains "${CONTEXT_DIR}/kernel.md" "glossary/domain map, playbook/checklist, skill/knowledge pack" "kernel asset shapes"
assert_contains "${CONTEXT_DIR}/commands/brainstorm.md" "policies/domain-knowledge-assets.md" "brainstorm policy load"
assert_contains "${CONTEXT_DIR}/commands/plan.md" "Domain Asset Promotion Ledger" "plan asset contract"
assert_contains "${CONTEXT_DIR}/commands/implement.md" "Domain Asset Implementation Ledger" "implement asset ledger"
assert_contains "${CONTEXT_DIR}/commands/review.md" "Domain Asset Review Ledger" "review asset acceptance"
assert_contains "${CONTEXT_DIR}/policies/knowledge-pack-router.md" "Domain knowledge asset signals" "EN router signal"
assert_contains "${CONTEXT_DIR}/policies/knowledge-pack-router.ko.md" "Domain knowledge asset signals" "KO router signal"
assert_contains "${CONTEXT_DIR}/policies/knowledge-pack-router.md" "policies/domain-knowledge-assets.md" "EN router mapping"
assert_contains "${CONTEXT_DIR}/policies/knowledge-pack-router.ko.md" "policies/domain-knowledge-assets.ko.md" "KO router mapping"

assert_contains "${DIST_DIR}/docs/en/current-product-shape.md" "21-domain-knowledge-assets.md" "EN product index"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape.md" "21-domain-knowledge-assets.md" "KO product index"
assert_contains "${DIST_DIR}/docs/en/current-product-shape/21-domain-knowledge-assets.md" "expert domain" "EN product doc"
assert_contains "${DIST_DIR}/docs/en/current-product-shape/21-domain-knowledge-assets.md" "five organization divisions plus taxonomy" "EN product five-division boundary"
assert_contains "${DIST_DIR}/docs/en/current-product-shape/21-domain-knowledge-assets.md" "six required council roles" "EN product six-role asset loop"
assert_contains "${DIST_DIR}/docs/en/current-product-shape/21-domain-knowledge-assets.md" "asset_candidate" "EN product asset candidate"
assert_contains "${DIST_DIR}/docs/en/current-product-shape/21-domain-knowledge-assets.md" "Domain Asset Promotion Ledger" "EN product ledger path"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape/21-domain-knowledge-assets.md" "도메인 지식" "KO product doc"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape/21-domain-knowledge-assets.md" "5개 조직 본부" "KO product five-division boundary"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape/21-domain-knowledge-assets.md" "6개 필수 council role" "KO product six-role asset loop"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape/21-domain-knowledge-assets.md" "asset_candidate" "KO product asset candidate"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape/21-domain-knowledge-assets.md" "Domain Asset Promotion Ledger" "KO product ledger path"
assert_contains "${DIST_DIR}/docs/en/index.md" "Domain expertise becomes leverage" "EN docs index"
assert_contains "${DIST_DIR}/docs/ko/index.md" "도메인 전문성은 AI 가 쓸 수 있는 자산" "KO docs index"

assert_contains "${DIST_DIR}/templates/.sfs-local-template/sprint-templates/plan.md" "Domain Asset Promotion Ledger" "plan template asset ledger"
assert_contains "${DIST_DIR}/templates/.sfs-local-template/sprint-templates/implement.md" "Domain Asset Implementation Ledger" "implement template asset ledger"
assert_contains "${DIST_DIR}/templates/.sfs-local-template/sprint-templates/review.md" "Domain Asset Review Ledger" "review template asset ledger"

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
  assert_contains "${file}" "Domain knowledge assets are first-class" "adapter domain assets ${file}"
  assert_contains "${file}" "owner/confidence/gaps" "adapter evidence boundary ${file}"
done

assert_contains "${DIST_DIR}/templates/SFS.md.template" "sfs context cat kernel" "SFS template routes domain policy through context"
assert_contains "${kernel}" "Domain knowledge is an AI-era moat" "kernel domain assets"
assert_contains "${kernel}" "expert/owner, confidence, gaps" "kernel domain evidence boundary"

echo "test-domain-knowledge-assets: OK"
