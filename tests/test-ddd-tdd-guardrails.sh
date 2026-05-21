#!/usr/bin/env bash
# DDD/TDD guardrails must be visible in scaffold, plan, implement, review, and adapters.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONTEXT_DIR="${DIST_DIR}/templates/.sfs-local-template/context"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-ddd-tdd-guardrails.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

assert_text_contains() {
  local file="$1" needle="$2" label="$3"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}'"
}

kernel="${CONTEXT_DIR}/kernel.md"
plan="${CONTEXT_DIR}/commands/plan.md"
implement="${CONTEXT_DIR}/commands/implement.md"
review_lens="${CONTEXT_DIR}/policies/review-lens-routing.md"
router="${CONTEXT_DIR}/policies/knowledge-pack-router.md"
router_ko="${CONTEXT_DIR}/policies/knowledge-pack-router.ko.md"
ddd_pack="${CONTEXT_DIR}/policies/ddd-tdd-knowledge-pack.md"
ddd_pack_ko="${CONTEXT_DIR}/policies/ddd-tdd-knowledge-pack.ko.md"
plan_template="${DIST_DIR}/templates/.sfs-local-template/sprint-templates/plan.md"
implement_template="${DIST_DIR}/templates/.sfs-local-template/sprint-templates/implement.md"
review_script="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-review.sh"
bootstrap_script="${DIST_DIR}/scripts/sfs-bootstrap.sh"

assert_contains "${kernel}" "DDD/TDD is a product-level engineering floor" "kernel product-level DDD/TDD floor"
assert_contains "${plan}" "DDD/TDD becomes an explicit product-level engineering floor" "plan product-level DDD/TDD floor"
assert_contains "${implement}" 'Load `policies/ddd-tdd-knowledge-pack.md`' "implement loads DDD/TDD pack"
assert_contains "${implement}" "whenever product behavior changes, not only backend" "implement product-level DDD/TDD"
assert_contains "${router}" "DDD/TDD signals" "router DDD/TDD signals"
assert_contains "${router}" "product behavior" "router product behavior signal"
assert_contains "${router_ko}" "DDD/TDD signals" "KO router DDD/TDD signals"
assert_contains "${router_ko}" "product behavior" "KO router product behavior signal"
assert_contains "${review_lens}" 'map to `ddd-tdd`' "review lens DDD/TDD alias"
assert_contains "${review_lens}" "product-level domain language" "review lens product-level DDD/TDD"
assert_contains "${ddd_pack}" "Product-level DDD/TDD baseline" "EN pack product-level summary"
assert_contains "${ddd_pack}" "Backend package layout is one application" "EN pack backend not scope"
assert_contains "${ddd_pack}" "clean layered monolith" "EN pack DDD layers"
assert_contains "${ddd_pack}" "failing acceptance, regression, or" "EN pack TDD first"
assert_contains "${ddd_pack}" "Product-level evidence may be" "EN pack product evidence"
assert_contains "${ddd_pack_ko}" "제품 수준" "KO pack product-level"
assert_contains "${ddd_pack_ko}" "backend 로 제한되지 않는다" "KO pack backend not scope"
assert_contains "${ddd_pack_ko}" "clean layered monolith" "KO pack DDD layers"
assert_contains "${ddd_pack_ko}" "failing acceptance" "KO pack TDD first"
assert_contains "${plan_template}" "## 6. DDD/TDD 기준" "plan template DDD/TDD section"
assert_contains "${plan_template}" "product behavior boundary" "plan template product behavior boundary"
assert_contains "${plan_template}" "TDD evidence 또는 waiver" "plan template DDD/TDD review checklist"
assert_contains "${implement_template}" "DDD boundary" "implement template DDD boundary"
assert_contains "${implement_template}" "product behavior boundary" "implement template product behavior boundary"
assert_contains "${implement_template}" "first failing/characterization/smoke/review evidence" "implement template TDD evidence"
assert_contains "${review_script}" "ddd-tdd)" "review script ddd-tdd lens"
assert_contains "${review_script}" "product-level DDD/TDD acceptance lens" "review script product lens label"
assert_contains "${review_script}" "DDD/TDD aliases" "review script alias help"
assert_contains "${bootstrap_script}" "Default product scaffolds to product-level DDD/TDD" "bootstrap public product DDD/TDD handoff"

for layer in domain application interfaces infrastructure; do
  assert_contains "${DIST_DIR}/templates/spring-kotlin-zero/src/main/kotlin/__PACKAGE_PATH__/${layer}/.gitkeep" "" "spring main ${layer}"
  assert_contains "${DIST_DIR}/templates/spring-kotlin-zero/src/test/kotlin/__PACKAGE_PATH__/${layer}/.gitkeep" "" "spring test ${layer}"
done

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

for file in "${adapter_files[@]}"; do
  assert_contains "${file}" "DDD/TDD is a product-level engineering floor" "adapter product-level DDD/TDD floor ${file}"
  assert_contains "${file}" "ddd-tdd" "adapter ddd-tdd lens ${file}"
done

SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context cat plan >"${TMP_DIR}/plan-context.md"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context cat implement >"${TMP_DIR}/implement-context.md"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context cat policies/ddd-tdd-knowledge-pack.md >"${TMP_DIR}/ddd-pack.md"

assert_text_contains "${TMP_DIR}/plan-context.md" "product-level engineering floor" "CLI plan context product DDD/TDD"
assert_text_contains "${TMP_DIR}/implement-context.md" "whenever product behavior changes, not only backend" "CLI implement context product DDD/TDD"
assert_text_contains "${TMP_DIR}/ddd-pack.md" "Backend package layout is one application" "CLI DDD/TDD pack backend boundary"

echo "test-ddd-tdd-guardrails: OK"
