#!/usr/bin/env bash
# Ensure routed context/skill markdown stays compact and frontmatter-loadable.
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

while IFS= read -r file; do
  lines="$(wc -l <"${file}" | tr -d '[:space:]')"
  [[ "${lines}" -le 200 ]] || fail "${file} exceeds 200 lines: ${lines}"

  first_line="$(sed -n '1p' "${file}")"
  [[ "${first_line}" == "---" ]] || fail "${file} missing opening frontmatter"
  grep -Eq '^id:' "${file}" || fail "${file} missing id frontmatter"
  grep -Eq '^summary:' "${file}" || fail "${file} missing summary frontmatter"
  grep -Eq '^load_when:' "${file}" || fail "${file} missing load_when frontmatter"
done < <(find "${CONTEXT_DIR}" -name '*.md' -type f | sort)

skill_files=(
  "${DIST_DIR}/templates/codex-skill/SKILL.md"
  "${DIST_DIR}/templates/.agents/skills/sfs/SKILL.md"
)

for file in "${skill_files[@]}"; do
  lines="$(wc -l <"${file}" | tr -d '[:space:]')"
  [[ "${lines}" -le 200 ]] || fail "${file} exceeds 200 lines: ${lines}"
done

router="${CONTEXT_DIR}/policies/knowledge-pack-router.md"
router_ko="${CONTEXT_DIR}/policies/knowledge-pack-router.ko.md"
index="${CONTEXT_DIR}/_INDEX.md"

for file in "${router}" "${router_ko}" "${index}"; do
  assert_contains "${file}" "backend-knowledge-pack-runtime" "backend runtime split routing ${file}"
  assert_contains "${file}" "backend-knowledge-pack-transactions" "backend transaction split routing ${file}"
  assert_contains "${file}" "backend-knowledge-pack-integration" "backend integration split routing ${file}"
  assert_contains "${file}" "backend-knowledge-pack-operating" "backend operating split routing ${file}"
  assert_contains "${file}" "design-knowledge-pack-operating" "design split routing ${file}"
  assert_contains "${file}" "ddd-tdd-knowledge-pack" "DDD/TDD pack routing ${file}"
  assert_contains "${file}" "enterprise-agent-team-pack" "enterprise parent routing ${file}"
  assert_contains "${file}" "enterprise-plan-council-pack" "enterprise plan routing ${file}"
  assert_contains "${file}" "enterprise-evidence-pack" "enterprise evidence routing ${file}"
  assert_contains "${file}" "enterprise-performance-review-pack" "enterprise performance routing ${file}"
done

assert_contains "${CONTEXT_DIR}/policies/backend-knowledge-pack.md" "split_children:" "backend parent split metadata"
assert_contains "${CONTEXT_DIR}/policies/backend-knowledge-pack.ko.md" "split_children:" "backend KO parent split metadata"
assert_contains "${CONTEXT_DIR}/policies/design-knowledge-pack.md" "design-knowledge-pack-operating.md" "design parent split pointer"
assert_contains "${CONTEXT_DIR}/policies/design-knowledge-pack.ko.md" "design-knowledge-pack-operating.ko.md" "design KO parent split pointer"

echo "test-context-md-split-frontmatter: OK"
