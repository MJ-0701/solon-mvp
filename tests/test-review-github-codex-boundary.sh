#!/usr/bin/env bash
# GitHub @codex PR review 와 SFS review gate 경계를 고정하는 회귀 테스트.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  local normalized
  [[ -f "${file}" ]] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" \
    || {
      normalized="$(tr '\n' ' ' <"${file}" | sed 's/[[:space:]][[:space:]]*/ /g')"
      printf '%s' "${normalized}" | grep -Fq -- "${needle}"
    } \
    || fail "${label}: missing '${needle}' in ${file}"
}

assert_boundary_matrix() {
  local file="$1" label="$2"
  assert_contains "${file}" '@codex' "${label} GitHub @codex signal"
  assert_contains "${file}" 'PR approval' "${label} PR approval signal"
  assert_contains "${file}" 'GitHub check PASS' "${label} GitHub check signal"
  assert_contains "${file}" 'self-CPO' "${label} self-CPO boundary"
  assert_contains "${file}" 'SFS cross review' "${label} SFS cross review boundary"
  assert_contains "${file}" 'sfs review' "${label} sfs review boundary"
  assert_contains "${file}" 'Gate 3' "${label} Gate 3 boundary"
  assert_contains "${file}" 'Gate 6 PASS' "${label} Gate 6 PASS boundary"
}

assert_does_not_satisfy_matrix() {
  local file="$1" label="$2"
  assert_boundary_matrix "${file}" "${label}"
  assert_contains "${file}" 'does not satisfy' "${label} does-not-satisfy boundary"
}

assert_does_not_replace_matrix() {
  local file="$1" label="$2"
  assert_boundary_matrix "${file}" "${label}"
  assert_contains "${file}" 'does not replace' "${label} does-not-replace boundary"
}

assert_korean_replacement_matrix() {
  local file="$1" label="$2"
  assert_boundary_matrix "${file}" "${label}"
  assert_contains "${file}" '대체하지 않습니다' "${label} Korean replacement boundary"
}

kernel="${DIST_DIR}/templates/.sfs-local-template/context/kernel.md"
review_context="${DIST_DIR}/templates/.sfs-local-template/context/commands/review.md"
implement_context="${DIST_DIR}/templates/.sfs-local-template/context/commands/implement.md"
review_script="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-review.sh"
cpo_persona="${DIST_DIR}/templates/.sfs-local-template/personas/cpo-evaluator.md"
model_profiles="${DIST_DIR}/templates/.sfs-local-template/model-profiles.yaml"
guide="${DIST_DIR}/GUIDE.md"
en_guide="${DIST_DIR}/docs/en/guide.md"
ko_shape="${DIST_DIR}/docs/ko/current-product-shape.md"
en_shape="${DIST_DIR}/docs/en/current-product-shape.md"

assert_contains "${kernel}" 'GitHub PR/code review is separate from SFS review' "kernel boundary"
assert_contains "${kernel}" 'post-implementation' "kernel GitHub post implementation only"
assert_contains "${review_context}" 'GitHub `@codex` PR/code review is external code-review evidence only' "review context boundary"
assert_contains "${review_context}" 'GitHub @codex review is post-implementation only' "review context post implementation"
assert_contains "${implement_context}" 'A GitHub `@codex` PR/code review, PR approval, or GitHub check PASS does not' "implement context boundary"
assert_contains "${implement_context}" 'GitHub @codex applies only after implementation' "implement context post implementation"
assert_contains "${review_script}" 'GitHub @codex PR/code review is external code-review evidence only' "review prompt lens boundary"
assert_contains "${review_script}" 'GitHub PR/@codex code review is not an SFS gate verdict' "review prompt verdict boundary"
assert_contains "${review_script}" 'GitHub @codex review is post-implementation only' "review prompt post implementation"
assert_contains "${cpo_persona}" 'A GitHub `@codex` PR/code review, PR approval, or GitHub check PASS is' "CPO persona boundary"
assert_contains "${model_profiles}" 'GitHub @codex PR/code review, PR approval, or GitHub check PASS is external evidence only' "model profile boundary"
assert_contains "${guide}" 'GitHub 의 `@codex` PR/code review 는 외부 코드리뷰 evidence 일 뿐입니다' "Korean guide boundary"
assert_contains "${en_guide}" 'GitHub `@codex` PR/code review is external evidence only' "English guide boundary"
assert_contains "${ko_shape}" 'GitHub 의 `@codex` PR/code review 는 외부 코드리뷰 evidence 일 뿐입니다' "Korean product shape boundary"
assert_contains "${en_shape}" 'GitHub `@codex` PR/code review is external evidence only' "English product shape boundary"

assert_does_not_satisfy_matrix "${kernel}" "kernel"
assert_does_not_satisfy_matrix "${review_context}" "review context"
assert_does_not_satisfy_matrix "${implement_context}" "implement context"
assert_does_not_satisfy_matrix "${review_script}" "review prompt"
assert_does_not_satisfy_matrix "${cpo_persona}" "CPO persona"
assert_does_not_satisfy_matrix "${model_profiles}" "model profile"
assert_korean_replacement_matrix "${guide}" "Korean guide"
assert_does_not_replace_matrix "${en_guide}" "English guide"
assert_korean_replacement_matrix "${ko_shape}" "Korean product shape"
assert_does_not_replace_matrix "${en_shape}" "English product shape"

adapter_files=(
  "${DIST_DIR}/templates/AGENTS.md.template"
  "${DIST_DIR}/templates/CLAUDE.md.template"
  "${DIST_DIR}/templates/GEMINI.md.template"
  "${DIST_DIR}/templates/codex-skill/SKILL.md"
  "${DIST_DIR}/plugins/solon/commands/sfs.md"
)

for file in "${adapter_files[@]}"; do
  assert_contains "${file}" 'A GitHub `@codex` PR/code review, PR approval, or GitHub check PASS is' "adapter boundary ${file}"
  assert_contains "${file}" 'post-implementation only' "adapter post implementation ${file}"
  assert_does_not_satisfy_matrix "${file}" "adapter boundary ${file}"
done

echo "test-review-github-codex-boundary: OK"
