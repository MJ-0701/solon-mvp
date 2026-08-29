#!/usr/bin/env bash
# Beginner design intake: semantic mirror, public-doc, and guide contracts.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONTEXT_DIR="${DIST_DIR}/templates/.sfs-local-template/context"
GUIDE_SCRIPT="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-guide.sh"
GUIDE="${DIST_DIR}/GUIDE.md"
BIN="${DIST_DIR}/bin/sfs"

. "${SCRIPT_DIR}/helpers/doc-search.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  sfs_doc_contains "${file}" "${needle}" || fail "${label}: missing '${needle}'"
}

assert_not_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  sfs_doc_not_contains "${file}" "${needle}" || fail "${label}: unexpected '${needle}'"
}

assert_text_contains() {
  local text="$1" needle="$2" label="$3"
  grep -Fq -- "${needle}" <<<"${text}" || fail "${label}: missing '${needle}'"
}

assert_text_not_contains() {
  local text="$1" needle="$2" label="$3"
  ! grep -Fq -- "${needle}" <<<"${text}" || fail "${label}: unexpected '${needle}'"
}

assert_anchor() {
  local file="$1" anchor="$2" label="$3"
  grep -Eq "^## ${anchor}( |$)" "${file}" \
    || fail "${label}: missing section anchor ${anchor}"
}

frontmatter_value() {
  local file="$1" key="$2"
  sed -n "s/^${key}: \"\(.*\)\"$/\1/p" "${file}" | sed -n '1p'
}

section_text() {
  local file="$1" anchor="$2"
  awk -v anchor="${anchor}" '
    $0 ~ "^## " anchor "( |$)" { active=1 }
    active { print }
    active && NR > 1 && /^## / && $0 !~ "^## " anchor "( |$)" { exit }
  ' "${file}"
}

assert_no_private_paths() {
  local file="$1" label="$2" needle
  local private_name="agent""_architect"
  local private_absolute="/Users/mj/${private_name}"
  local private_home="~/${private_name}"

  for needle in "${private_name}" "${private_absolute}" "${private_home}"; do
    if grep -Fq -- "${needle}" "${file}"; then
      fail "${label}: private path leaked into ${file}"
    fi
  done
}

POLICY_EN="${CONTEXT_DIR}/policies/design-intake-flow.md"
POLICY_KO="${CONTEXT_DIR}/policies/design-intake-flow.ko.md"
INDEX="${CONTEXT_DIR}/_INDEX.md"
IMPLEMENT="${CONTEXT_DIR}/commands/implement.md"
REVIEW="${CONTEXT_DIR}/commands/review.md"
REVIEW_SCRIPT="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-review.sh"
DOC_EN="${DIST_DIR}/docs/en/current-product-shape/13-design-md-and-anti-ai-slop-guardrails.md"
DOC_KO="${DIST_DIR}/docs/ko/current-product-shape/13-design-md-ai.md"
PRODUCT_EN="${DIST_DIR}/docs/en/current-product-shape.md"
PRODUCT_KO="${DIST_DIR}/docs/ko/current-product-shape.md"

[[ -f "${POLICY_EN}" && -f "${POLICY_KO}" ]] || fail "missing design intake policy mirror"

expected_question_keys="user-job, first-flow, viewport, constraints, direction, evidence"
for policy in "${POLICY_EN}" "${POLICY_KO}"; do
  [[ "$(frontmatter_value "${policy}" six_question_keys)" == "${expected_question_keys}" ]] \
    || fail "${policy}: six_question_keys changed or incomplete"
  [[ "$(frontmatter_value "${policy}" intake_states)" == "CONFIRMED, UNVERIFIED" ]] \
    || fail "${policy}: intake state contract changed"
  [[ -n "$(frontmatter_value "${policy}" content_policy)" ]] \
    || fail "${policy}: content_policy must be nonempty"
  for anchor in DES-INTAKE-01 DES-INTAKE-02 DES-INTAKE-03 DES-INTAKE-04 DES-INTAKE-05; do
    assert_anchor "${policy}" "${anchor}" "intake policy"
  done
done

# Anchor-local checks test behavior while allowing Korean headings and prose to
# be localized independently of the English mirror.
en_scope="$(section_text "${POLICY_EN}" DES-INTAKE-01)"
ko_scope="$(section_text "${POLICY_KO}" DES-INTAKE-01)"
assert_text_contains "${en_scope}" "design-inexperienced" "EN conditional intake trigger"
assert_text_contains "${en_scope}" "minor edit" "EN minor-edit exemption"
assert_text_contains "${ko_scope}" "디자인 경험" "KO conditional intake trigger"
assert_text_contains "${ko_scope}" "작은 수정" "KO minor-edit exemption"

en_fallback="$(section_text "${POLICY_EN}" DES-INTAKE-03)"
ko_fallback="$(section_text "${POLICY_KO}" DES-INTAKE-03)"
assert_text_contains "${en_fallback}" "no Figma file, screenshot, or reference" "EN no-reference fallback"
assert_text_contains "${en_fallback}" "safe starter" "EN safe starter"
assert_text_contains "${ko_fallback}" "Figma, screenshot, reference가 모두 없다면" "KO no-reference fallback"
assert_text_contains "${ko_fallback}" "안전한 starter direction" "KO safe starter"

for policy in "${POLICY_EN}" "${POLICY_KO}"; do
  state_section="$(section_text "${policy}" DES-INTAKE-04)"
  ready_section="$(section_text "${policy}" DES-INTAKE-05)"
  assert_text_contains "${state_section}" "UNVERIFIED" "intake noninteractive state"
  assert_text_contains "${state_section}" "CI" "intake CI path"
  assert_text_contains "${ready_section}" "Ready" "intake ready distinction"
done
assert_text_contains "$(section_text "${POLICY_EN}" DES-INTAKE-05)" "new gate" "EN intake no-new-gate contract"
assert_text_contains "$(section_text "${POLICY_KO}" DES-INTAKE-05)" "새 gate" "KO intake no-new-gate contract"

assert_contains "${INDEX}" "policies/design-intake-flow.md" "EN intake index route"
assert_contains "${INDEX}" "policies/design-intake-flow.ko.md" "KO intake index route"
assert_contains "${IMPLEMENT}" "exempts minor edits" "implement minor-edit exemption"
assert_contains "${IMPLEMENT}" "noninteractive/CI" "implement CI path"
assert_contains "${IMPLEMENT}" "UNVERIFIED" "implement unverified state"
assert_contains "${IMPLEMENT}" "after either the confirmed design-contract or intake path" "implement unconditional token drift"
assert_contains "${IMPLEMENT}" "token drift: colors, type, spacing, radius, shadows, and icons" "implement token drift scope"
assert_contains "${REVIEW}" 'skipped intake or no confirmation is `UNVERIFIED`, never `Ready`' "review unverified state"
assert_contains "${REVIEW}" "Evidence only, not a hard gate" "review advisory cross-reference"
assert_contains "${REVIEW_SCRIPT}" "as UNVERIFIED, never silently Ready" "review script unverified state"
assert_contains "${REVIEW_SCRIPT}" "This is evidence, not a new hard gate" "review script advisory cross-reference"

assert_contains "${PRODUCT_EN}" "13-design-md-and-anti-ai-slop-guardrails.md" "EN product index route"
assert_contains "${PRODUCT_KO}" "13-design-md-ai.md" "KO product index route"
for doc in "${DOC_EN}" "${DOC_KO}"; do
  [[ -n "$(frontmatter_value "${doc}" load_when)" ]] || fail "${doc}: load_when must be nonempty"
  assert_contains "${doc}" "docs/solon/design.md" "public design seed"
  assert_contains "${doc}" "UNVERIFIED" "public unverified state"
  assert_contains "${doc}" "Ready" "public ready distinction"
  assert_not_contains "${doc}" "../../../templates/" "publish-safe public route"
done
assert_contains "${DOC_EN}" "sfs context cat policies/design-intake-flow" "EN public context command"
assert_contains "${DOC_KO}" "sfs context cat policies/design-intake-flow.ko" "KO public context command"
assert_contains "${DOC_EN}" "When none exists" "EN public no-reference fallback"
assert_contains "${DOC_KO}" "셋 다" "KO public no-reference fallback"

bash -n "${GUIDE_SCRIPT}" || fail "guide script is not valid bash"
guide_lines="$(wc -l <"${GUIDE_SCRIPT}" | tr -d '[:space:]')"
[[ "${guide_lines}" -le 200 ]] || fail "guide script exceeds 200 lines: ${guide_lines}"

tmp="$(mktemp -d "${TMPDIR:-/tmp}/sfs-design-intake.XXXXXX")"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT

# Fresh thin init must discover the installed global guide and route its policy
# through the current runtime, without vendoring that policy into .sfs-local.
mkdir -p "${tmp}/project"
(
  cd "${tmp}/project"
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" \
    bash "${BIN}" init --layout thin --yes >/dev/null
)

guide_path="$(
  cd "${tmp}/project"
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${BIN}" guide --path
)"
[[ "${guide_path}" == "${GUIDE}" ]] \
  || fail "thin init should read the installed global guide, got: ${guide_path}"

guide_default_output="$(
  cd "${tmp}/project"
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${BIN}" guide
)"
assert_text_contains "${guide_default_output}" "sfs guide --print" \
  "default guide leads to the full guide command"
assert_text_contains "${guide_default_output}" "path: ${GUIDE}" \
  "default guide leads to the installed global guide"

guide_output="$(
  cd "${tmp}/project"
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${BIN}" guide --print
)"
guide_design_section="$(
  awk '
    /^## 디자인이 처음이라면$/ { active=1; next }
    active && /^## / { exit }
    active { print }
  ' <<<"${guide_output}"
)"
[[ -n "${guide_design_section}" ]] \
  || fail "installed guide is missing the beginner-design section"
assert_text_contains "${guide_design_section}" \
  '새 화면이나 흐름을 만들 때 디자인 방향이 막막하면, 아래 안내를 열어 필요한 내용을 순서대로 정하세요. 디자인 경험이 없어도 됩니다.' \
  "installed guide beginner-design discovery"
assert_text_contains "${guide_design_section}" \
  'sfs context cat policies/design-intake-flow.ko' \
  "installed guide Korean intake route"
for guide_jargon in '여섯 문항' 'seed' 'gap' 'UNVERIFIED' 'Ready'; do
  assert_text_not_contains "${guide_design_section}" "${guide_jargon}" "guide design intake stays plain-language"
done

policy_path="$(
  cd "${tmp}/project"
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" \
    bash "${BIN}" context path policies/design-intake-flow.ko
)"
[[ "${policy_path}" == "${POLICY_KO}" ]] \
  || fail "thin init should route Korean intake policy globally, got: ${policy_path}"
[[ ! -e "${tmp}/project/.sfs-local/context/policies/design-intake-flow.ko.md" ]] \
  || fail "thin init must not copy Korean intake policy into .sfs-local"

context_output="$(
  cd "${tmp}/project"
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" \
    bash "${BIN}" context cat policies/design-intake-flow.ko
)"
assert_text_contains "${context_output}" "DES-INTAKE-01" "verified intake context command"

for file in "${POLICY_EN}" "${POLICY_KO}" "${INDEX}" "${IMPLEMENT}" "${REVIEW}" \
  "${REVIEW_SCRIPT}" "${DOC_EN}" "${DOC_KO}" "${GUIDE_SCRIPT}" "${GUIDE}"; do
  assert_no_private_paths "${file}" "design intake surface"
done

echo "test-design-intake-flow: OK"
