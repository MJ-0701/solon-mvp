#!/usr/bin/env bash
# Enterprise six-role council packs stay routed, split, and measurable without
# classifying the taxonomy function as an organization division.
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
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

assert_not_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  if grep -Fq -- "${needle}" "${file}"; then
    fail "${label}: unexpected '${needle}'"
  fi
}

packs=(
  enterprise-agent-team-pack.md
  enterprise-agent-team-pack.ko.md
  enterprise-plan-council-pack.md
  enterprise-plan-council-pack.ko.md
  enterprise-evidence-pack.md
  enterprise-evidence-pack.ko.md
  enterprise-performance-review-pack.md
  enterprise-performance-review-pack.ko.md
  mainline-focus-guard.md
  mainline-focus-guard.ko.md
  gate6-data-validation-pack.md
  gate6-data-validation-pack.ko.md
  agentic-security-logging-pack.md
  agentic-security-logging-pack.ko.md
  wiki-mission-checklist-skill.md
  wiki-mission-checklist-skill.ko.md
)

for pack in "${packs[@]}"; do
  file="${CONTEXT_DIR}/policies/${pack}"
  assert_contains "${file}" "id:" "frontmatter id ${pack}"
  assert_contains "${file}" "summary:" "frontmatter summary ${pack}"
  assert_contains "${file}" "load_when:" "frontmatter load_when ${pack}"
  lines="$(wc -l <"${file}" | tr -d '[:space:]')"
  [[ "${lines}" -le 200 ]] || fail "${pack} exceeds 200 lines: ${lines}"
done

router="${CONTEXT_DIR}/policies/knowledge-pack-router.md"
router_ko="${CONTEXT_DIR}/policies/knowledge-pack-router.ko.md"
index="${CONTEXT_DIR}/_INDEX.md"
plan="${CONTEXT_DIR}/commands/plan.md"
implement="${CONTEXT_DIR}/commands/implement.md"
review="${CONTEXT_DIR}/commands/review.md"
plan_template="${DIST_DIR}/templates/.sfs-local-template/sprint-templates/plan.md"
implement_template="${DIST_DIR}/templates/.sfs-local-template/sprint-templates/implement.md"
review_template="${DIST_DIR}/templates/.sfs-local-template/sprint-templates/review.md"
lens_router="${CONTEXT_DIR}/policies/review-lens-routing.md"
model_profiles="${DIST_DIR}/templates/.sfs-local-template/model-profiles.yaml"
common_script="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-common.sh"
auth_script="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-auth.sh"
review_script="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-review.sh"

for file in "${router}" "${router_ko}" "${index}"; do
  assert_contains "${file}" "enterprise-agent-team-pack" "enterprise parent routing ${file}"
  assert_contains "${file}" "enterprise-plan-council-pack" "enterprise plan routing ${file}"
  assert_contains "${file}" "enterprise-evidence-pack" "enterprise evidence routing ${file}"
  assert_contains "${file}" "enterprise-performance-review-pack" "enterprise performance routing ${file}"
done

assert_contains "${CONTEXT_DIR}/policies/enterprise-agent-team-pack.md" "default domain-asset loop" "EN enterprise domain asset loop"
assert_contains "${CONTEXT_DIR}/policies/enterprise-agent-team-pack.md" "five organization divisions" "EN enterprise five-division boundary"
assert_contains "${CONTEXT_DIR}/policies/enterprise-agent-team-pack.md" "All six are required council roles" "EN enterprise council roles"
assert_contains "${CONTEXT_DIR}/policies/enterprise-agent-team-pack.md" "asset_candidate" "EN enterprise asset candidate"
assert_contains "${CONTEXT_DIR}/policies/enterprise-agent-team-pack.ko.md" "domain-asset loop" "KO enterprise domain asset loop"
assert_contains "${CONTEXT_DIR}/policies/enterprise-agent-team-pack.ko.md" "organization division은 다섯 개" "KO enterprise five-division boundary"
assert_contains "${CONTEXT_DIR}/policies/enterprise-agent-team-pack.ko.md" "여섯 role은 모두 required council role" "KO enterprise council roles"
assert_contains "${CONTEXT_DIR}/policies/enterprise-agent-team-pack.ko.md" "asset_candidate" "KO enterprise asset candidate"
assert_contains "${CONTEXT_DIR}/policies/enterprise-plan-council-pack.md" "asset_candidate" "EN plan council asset candidate"
assert_contains "${CONTEXT_DIR}/policies/enterprise-plan-council-pack.md" "winning theory" "EN plan council winning theory"
assert_contains "${CONTEXT_DIR}/policies/enterprise-plan-council-pack.ko.md" "asset_candidate" "KO plan council asset candidate"
assert_contains "${CONTEXT_DIR}/policies/enterprise-plan-council-pack.ko.md" "winning theory" "KO plan council winning theory"
assert_contains "${CONTEXT_DIR}/policies/division-subagent-council.md" "asset_candidate" "division council asset candidate"
assert_contains "${DIST_DIR}/docs/en/current-product-shape/14-divisions-knowledge-packs-review-lenses.md" "domain-asset capture loop" "EN docs 6 division asset loop"
assert_contains "${DIST_DIR}/docs/en/current-product-shape/14-divisions-knowledge-packs-review-lenses.md" "asset_candidate" "EN docs asset candidate"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape/14-review-lens.md" "domain-asset capture" "KO docs 6 division asset loop"
assert_contains "${DIST_DIR}/docs/ko/current-product-shape/14-review-lens.md" "asset_candidate" "KO docs asset candidate"

assert_contains "${plan}" "enterprise-plan-council-pack" "plan loads enterprise council"
assert_contains "${plan}" "risk flags" "plan risk flags"
assert_contains "${plan}" "Empty six-role council ceremony is not PASS" "plan no decorative council"
assert_contains "${plan_template}" "Enterprise Plan Council" "plan template enterprise section"
assert_contains "${plan_template}" "risk flags" "plan template risk flags"
assert_contains "${plan_template}" "selected knowledge packs" "plan template selected packs"
assert_contains "${plan_template}" "asset_candidate" "plan template asset candidate"
assert_contains "${plan_template}" "Domain Asset Promotion Ledger" "plan template domain asset ledger"

assert_contains "${implement}" "enterprise-performance-review-pack" "implement performance pack"
assert_contains "${implement}" "project-applied QA/QC" "implement applied QA"
assert_contains "${implement_template}" "Enterprise QA/QC And Performance" "implement template enterprise QA"
assert_contains "${implement_template}" "Domain Asset Implementation Ledger" "implement template domain asset ledger"

assert_contains "${review}" "enterprise-performance-review-pack" "review performance pack"
assert_contains "${review}" "Performance/algorithm PASS needs measurement" "review no paper perf pass"
assert_contains "${review_template}" "Performance / Algorithm Ledger" "review template perf ledger"
assert_contains "${review_template}" "Enterprise Evidence Ledger" "review template evidence ledger"
assert_contains "${review_template}" "Domain Asset Review Ledger" "review template domain asset ledger"
assert_contains "${lens_router}" "performance-algorithm" "review lens performance algorithm alias"

assert_contains "${model_profiles}" 'model: "gemini-3.1-pro-preview"' "gemini pro route"
assert_contains "${model_profiles}" 'model: "gemini-3-flash-preview"' "gemini coding route"
assert_contains "${model_profiles}" 'model: "gemini-3.1-flash-lite"' "gemini economy route"
assert_contains "${model_profiles}" "five organization divisions plus the taxonomy cross-cutting product function/lens" "model profile taxonomy boundary"
assert_contains "${model_profiles}" "all six required council roles" "model profile council role requirement"
assert_not_contains "${model_profiles}" "gemini-3.5-flash" "no unsupported gemini 3.5 route"
assert_not_contains "${model_profiles}" 'model: "gemini-3-pro-auto"' "no stale gemini auto route"
assert_not_contains "${model_profiles}" "for every SFS role" "no stale gemini every-role rule"
assert_not_contains "${model_profiles}" "gemini-2.5" "no gemini 2.5"

assert_contains "${common_script}" "Executable Action Ownership" "auth flow agent ownership note"
assert_contains "${common_script}" "Council Role Activation Recommendations" "cycle-end council role heading"
assert_contains "${common_script}" "Taxonomy product function/lens" "cycle-end taxonomy function"
assert_contains "${auth_script}" "gemini-3.1-flash-lite" "auth probe cheap gemini route"
assert_contains "${review_script}" "gemini-3.1-pro-preview" "review gemini pro route"

echo "test-enterprise-agent-team-knowledge-packs: OK"
