#!/usr/bin/env bash
# 디자인본부의 design.md 계약과 AI 슬롭 방지 가드레일을 검증한다.
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

DESIGN_EN="${DIST_DIR}/templates/.sfs-local-template/context/policies/design-knowledge-pack.md"
DESIGN_KO="${DIST_DIR}/templates/.sfs-local-template/context/policies/design-knowledge-pack.ko.md"
DESIGN_OPS_EN="${DIST_DIR}/templates/.sfs-local-template/context/policies/design-knowledge-pack-operating.md"
DESIGN_OPS_KO="${DIST_DIR}/templates/.sfs-local-template/context/policies/design-knowledge-pack-operating.ko.md"
IMPLEMENT="${DIST_DIR}/templates/.sfs-local-template/context/commands/implement.md"
REVIEW="${DIST_DIR}/templates/.sfs-local-template/context/commands/review.md"
REVIEW_SCRIPT="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-review.sh"
TENX_KO="${DIST_DIR}/docs/ko/10x-value.md"
TENX_EN="${DIST_DIR}/docs/en/10x-value.md"

assert_contains "${DESIGN_EN}" "DES-FILL-SYSTEM" "EN design system section"
assert_contains "${DESIGN_EN}" "design.md" "EN design.md"
assert_contains "${DESIGN_EN}" "token drift" "EN token drift"
assert_contains "${DESIGN_OPS_EN}" "AI-slop signals" "EN AI slop"
assert_contains "${DESIGN_OPS_EN}" "Wanted Montage-style" "EN starter set"
assert_contains "${DESIGN_OPS_EN}" "Coolicons" "EN icon starter"
assert_contains "${DESIGN_OPS_EN}" "Pretendard" "EN font starter"
assert_contains "${DESIGN_OPS_EN}" "letter-spacing at 0" "EN Korean typography"

assert_contains "${DESIGN_KO}" "DES-FILL-SYSTEM" "KO design system section"
assert_contains "${DESIGN_KO}" "design.md" "KO design.md"
assert_contains "${DESIGN_KO}" "token drift" "KO token drift"
assert_contains "${DESIGN_OPS_KO}" "AI-slop signal" "KO AI slop"
assert_contains "${DESIGN_OPS_KO}" "원티드 몽타주" "KO starter component"
assert_contains "${DESIGN_OPS_KO}" "Coolicons" "KO icon starter"
assert_contains "${DESIGN_OPS_KO}" "Pretendard" "KO font starter"
assert_contains "${DESIGN_OPS_KO}" "letter-spacing 은 기본 0" "KO typography"

assert_contains "${IMPLEMENT}" "design.md" "implement design.md"
assert_contains "${IMPLEMENT}" "drift: colors" "implement token drift"
assert_contains "${REVIEW}" "AI-slop risk" "review AI slop"
assert_contains "${REVIEW}" "arbitrary colors" "review arbitrary tokens"
assert_contains "${REVIEW_SCRIPT}" "design.md/token adherence" "review script design checklist"

assert_contains "${TENX_KO}" "병렬 agent 10x 루프" "KO 10x multi-agent"
assert_contains "${TENX_KO}" "디자인 시스템 10x 루프" "KO 10x design"
assert_contains "${TENX_KO}" "AI 슬롭" "KO 10x AI slop"
assert_contains "${TENX_KO}" "design.md" "KO 10x design.md"

assert_contains "${TENX_EN}" "Parallel Agent 10x Loop" "EN 10x multi-agent"
assert_contains "${TENX_EN}" "Design System 10x Loop" "EN 10x design"
assert_contains "${TENX_EN}" "AI-slop signals" "EN 10x AI slop"
assert_contains "${TENX_EN}" "design.md" "EN 10x design.md"

echo "test-design-system-anti-slop: OK"
