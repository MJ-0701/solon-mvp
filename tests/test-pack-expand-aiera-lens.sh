#!/usr/bin/env bash
# batch2/batch3 lecture-derived AI-era review-lens items stay append-only,
# lens-framed (not hard rules), EN/KO paired, under the 200-line cap, and free
# of by-reference speaker-time numbers (no raw figures baked into packs).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
POLICIES="${DIST_DIR}/templates/.sfs-local-template/context/policies"

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
    fail "${label}: unexpected by-reference literal '${needle}'"
  fi
}

packs=(
  ddd-tdd-knowledge-pack
  qa-knowledge-pack
  agentic-security-logging-pack
  strategy-pm-knowledge-pack
  domain-knowledge-assets
)

# Frontmatter + line-cap + lens-framing disclaimer + by-reference negative lock.
for pack in "${packs[@]}"; do
  en="${POLICIES}/${pack}.md"
  ko="${POLICIES}/${pack}.ko.md"
  for f in "${en}" "${ko}"; do
    assert_contains "${f}" "id:" "frontmatter id ${f}"
    assert_contains "${f}" "summary:" "frontmatter summary ${f}"
    assert_contains "${f}" "load_when:" "frontmatter load_when ${f}"
    lines="$(wc -l <"${f}" | tr -d '[:space:]')"
    [[ "${lines}" -le 200 ]] || fail "${pack} ($(basename "${f}")) exceeds 200 lines: ${lines}"
  done
  # lens-framing: each pack's AI-era section is discussion lens, not a hard rule.
  assert_contains "${en}" "speaker-time assertion" "EN lens-framing disclaimer ${pack}"
  assert_contains "${ko}" "강연 시점" "KO lens-framing disclaimer ${pack}"
  # by-reference: speaker-time numbers must not be baked into shipping packs.
  for lit in "5,000" "6,500" "10배" "5000통"; do
    assert_not_contains "${en}" "${lit}" "EN by-reference number lock ${pack}"
    assert_not_contains "${ko}" "${lit}" "KO by-reference number lock ${pack}"
  done
done

# Per-pack new headline items (EN + KO paired).
assert_contains "${POLICIES}/ddd-tdd-knowledge-pack.md" "DT-AIERA-001" "EN ddd-tdd ownership id"
assert_contains "${POLICIES}/ddd-tdd-knowledge-pack.md" "AI-generated code still needs a human owner" "EN ddd-tdd ownership lens"
assert_contains "${POLICIES}/ddd-tdd-knowledge-pack.md" "AI-Era Closed-Loop Evidence" "EN ddd-tdd spec=human by-reference"
assert_contains "${POLICIES}/ddd-tdd-knowledge-pack.ko.md" "DT-AIERA-001" "KO ddd-tdd ownership id"
assert_contains "${POLICIES}/ddd-tdd-knowledge-pack.ko.md" "AI 생성 코드에도 사람 소유자가 필요" "KO ddd-tdd ownership lens"

assert_contains "${POLICIES}/qa-knowledge-pack.md" "QA-AIERA-005" "EN qa static-analysis id"
assert_contains "${POLICIES}/qa-knowledge-pack.md" "Static analysis plus tests is the minimum safety net" "EN qa leveling lens"
assert_contains "${POLICIES}/qa-knowledge-pack.ko.md" "QA-AIERA-005" "KO qa static-analysis id"
assert_contains "${POLICIES}/qa-knowledge-pack.ko.md" "정적분석+테스트는 개인 기량 편차" "KO qa leveling lens"

assert_contains "${POLICIES}/agentic-security-logging-pack.md" "SEC-AIERA-001" "EN sec skill-contract id"
assert_contains "${POLICIES}/agentic-security-logging-pack.md" "secure-by-default" "EN sec secure-by-default lens"
assert_contains "${POLICIES}/agentic-security-logging-pack.md" "skip its security step" "EN sec no-skip lens"
assert_contains "${POLICIES}/agentic-security-logging-pack.ko.md" "SEC-AIERA-001" "KO sec skill-contract id"
assert_contains "${POLICIES}/agentic-security-logging-pack.ko.md" "secure-by-default" "KO sec secure-by-default lens"

assert_contains "${POLICIES}/strategy-pm-knowledge-pack.md" "PM-AIERA-007" "EN strategy four-element id"
assert_contains "${POLICIES}/strategy-pm-knowledge-pack.md" "four-element shape" "EN strategy request-shape lens"
assert_contains "${POLICIES}/strategy-pm-knowledge-pack.md" "PM-AIERA-010" "EN strategy automation-boundary id"
assert_contains "${POLICIES}/strategy-pm-knowledge-pack.ko.md" "PM-AIERA-007" "KO strategy four-element id"
assert_contains "${POLICIES}/strategy-pm-knowledge-pack.ko.md" "요청에 4요소" "KO strategy request-shape lens"

assert_contains "${POLICIES}/domain-knowledge-assets.md" "Trust, relationship, and scarcity are the AI-era moat" "EN domain trust-moat lens"
assert_contains "${POLICIES}/domain-knowledge-assets.md" "AI literacy is a baseline assumption" "EN domain ai-literacy lens"
assert_contains "${POLICIES}/domain-knowledge-assets.ko.md" "신뢰·관계·희소성이 AI 시대 해자" "KO domain trust-moat lens"
assert_contains "${POLICIES}/domain-knowledge-assets.ko.md" "AI 리터러시는 옵션이 아니라 baseline 전제" "KO domain ai-literacy lens"

echo "test-pack-expand-aiera-lens: OK"
