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
  obsidian-llm-wiki
  infra-knowledge-pack
  design-knowledge-pack
  taxonomy-knowledge-pack
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
assert_contains "${POLICIES}/strategy-pm-knowledge-pack.md" "deployment and data location are" "EN strategy local-first trust lens"
assert_contains "${POLICIES}/strategy-pm-knowledge-pack.md" "support and community as adoption loops" "EN strategy community-support lens"
assert_contains "${POLICIES}/strategy-pm-knowledge-pack.md" "not a monetization strategy" "EN strategy vibe-coding leverage lens"
assert_contains "${POLICIES}/strategy-pm-knowledge-pack.md" "demand evidence before build" "EN strategy product validation lens"
assert_contains "${POLICIES}/strategy-pm-knowledge-pack.md" "AX is process redesign" "EN strategy AX process lens"
assert_contains "${POLICIES}/strategy-pm-knowledge-pack.md" "Reject activity-list strategy" "EN strategy winning-theory lens"
assert_contains "${POLICIES}/strategy-pm-knowledge-pack.ko.md" "PM-AIERA-007" "KO strategy four-element id"
assert_contains "${POLICIES}/strategy-pm-knowledge-pack.ko.md" "요청에 4요소" "KO strategy request-shape lens"
assert_contains "${POLICIES}/strategy-pm-knowledge-pack.ko.md" "데이터 위치가 제품" "KO strategy local-first trust lens"
assert_contains "${POLICIES}/strategy-pm-knowledge-pack.ko.md" "adoption loop" "KO strategy community-support lens"
assert_contains "${POLICIES}/strategy-pm-knowledge-pack.ko.md" "수익화 전략이 아니라 레버리지" "KO strategy vibe-coding leverage lens"
assert_contains "${POLICIES}/strategy-pm-knowledge-pack.ko.md" "demand evidence" "KO strategy product validation lens"
assert_contains "${POLICIES}/strategy-pm-knowledge-pack.ko.md" "측정 가능한 시간/비용 절감" "KO strategy AX process lens"
assert_contains "${POLICIES}/strategy-pm-knowledge-pack.ko.md" "activity-list strategy 를 거부" "KO strategy winning-theory lens"

assert_contains "${POLICIES}/domain-knowledge-assets.md" "Trust, relationship, and scarcity are the AI-era moat" "EN domain trust-moat lens"
assert_contains "${POLICIES}/domain-knowledge-assets.md" "Community and support loops are domain assets" "EN domain community-support lens"
assert_contains "${POLICIES}/domain-knowledge-assets.md" "AI literacy is a baseline assumption" "EN domain ai-literacy lens"
assert_contains "${POLICIES}/domain-knowledge-assets.md" "Root knowledge beats tool fashion" "EN domain root-knowledge lens"
assert_contains "${POLICIES}/domain-knowledge-assets.md" "Domain expertise is a build/no-build gate" "EN domain build-gate lens"
assert_contains "${POLICIES}/domain-knowledge-assets.md" "Delegation muscle needs compiled context" "EN domain delegation-context lens"
assert_contains "${POLICIES}/domain-knowledge-assets.ko.md" "신뢰·관계·희소성이 AI 시대 해자" "KO domain trust-moat lens"
assert_contains "${POLICIES}/domain-knowledge-assets.ko.md" "community 와 support loop 는 도메인 자산" "KO domain community-support lens"
assert_contains "${POLICIES}/domain-knowledge-assets.ko.md" "AI 리터러시는 옵션이 아니라 baseline 전제" "KO domain ai-literacy lens"
assert_contains "${POLICIES}/domain-knowledge-assets.ko.md" "뿌리지식은 tool 유행보다 오래" "KO domain root-knowledge lens"
assert_contains "${POLICIES}/domain-knowledge-assets.ko.md" "도메인 전문성은 build/no-build gate" "KO domain build-gate lens"
assert_contains "${POLICIES}/domain-knowledge-assets.ko.md" "위임 근육은 컴파일된 컨텍스트" "KO domain delegation-context lens"

# --- pass-2 (WU-pack-expand): obsidian-llm-wiki + infra/design/taxonomy ---

assert_contains "${POLICIES}/obsidian-llm-wiki.md" "WIKI-AIERA-001" "EN obsidian observe-first id"
assert_contains "${POLICIES}/obsidian-llm-wiki.md" "operator reads APM" "EN obsidian observe-first lens"
assert_contains "${POLICIES}/obsidian-llm-wiki.md" "Gold In, Gold Out" "EN obsidian purpose-first lens"
assert_contains "${POLICIES}/obsidian-llm-wiki.md" "indexed context, not a" "EN obsidian indexed-second-brain lens"
assert_contains "${POLICIES}/obsidian-llm-wiki.md" "external source manager" "EN obsidian source-library boundary"
assert_contains "${POLICIES}/obsidian-llm-wiki.md" "Source-bundle analysis tools are derived workspaces" "EN obsidian source-bundle boundary"
assert_contains "${POLICIES}/obsidian-llm-wiki.ko.md" "WIKI-AIERA-001" "KO obsidian observe-first id"
assert_contains "${POLICIES}/obsidian-llm-wiki.ko.md" "APM 을 읽듯" "KO obsidian observe-first lens"
assert_contains "${POLICIES}/obsidian-llm-wiki.ko.md" "창고가 아니라 색인된 context" "KO obsidian indexed-second-brain lens"
assert_contains "${POLICIES}/obsidian-llm-wiki.ko.md" "외부 source manager" "KO obsidian source-library boundary"
assert_contains "${POLICIES}/obsidian-llm-wiki.ko.md" "source-bundle 분석 도구 결과" "KO obsidian source-bundle boundary"

assert_contains "${POLICIES}/infra-knowledge-pack.md" "INF-AIERA-001" "EN infra capacity id"
assert_contains "${POLICIES}/infra-knowledge-pack.md" "token budget as a first-class resource" "EN infra token lens"
assert_contains "${POLICIES}/infra-knowledge-pack.md" "Jevons" "EN infra jevons lens"
assert_contains "${POLICIES}/infra-knowledge-pack.md" "Language shape is part of token capacity" "EN infra language-token lens"
assert_contains "${POLICIES}/infra-knowledge-pack.md" "Local LLMs are a privacy/capacity tradeoff" "EN infra local-llm lens"
assert_contains "${POLICIES}/infra-knowledge-pack.ko.md" "INF-AIERA-001" "KO infra capacity id"
assert_contains "${POLICIES}/infra-knowledge-pack.ko.md" "토큰 예산을 1급 자원" "KO infra token lens"
assert_contains "${POLICIES}/infra-knowledge-pack.ko.md" "언어 형태도 토큰 용량의 일부" "KO infra language-token lens"
assert_contains "${POLICIES}/infra-knowledge-pack.ko.md" "로컬 LLM 은 단순한" "KO infra local-llm lens"

assert_contains "${POLICIES}/design-knowledge-pack.md" "DES-AIERA-001" "EN design gen-asset id"
assert_contains "${POLICIES}/design-knowledge-pack.md" "reference-not-plagiarize" "EN design IP lens"
assert_contains "${POLICIES}/design-knowledge-pack.md" "Generated product ads need an asset-consistency contract" "EN design product-ad consistency lens"
assert_contains "${POLICIES}/design-knowledge-pack.ko.md" "DES-AIERA-001" "KO design gen-asset id"
assert_contains "${POLICIES}/design-knowledge-pack.ko.md" "표절-아닌-재창작" "KO design IP lens"
assert_contains "${POLICIES}/design-knowledge-pack.ko.md" "생성형 제품 광고는 생성 전 asset-consistency 계약" "KO design product-ad consistency lens"

assert_contains "${POLICIES}/taxonomy-knowledge-pack.md" "TAX-AIERA-001" "EN taxonomy asset id"
assert_contains "${POLICIES}/taxonomy-knowledge-pack.md" "classifiable assets" "EN taxonomy asset lens"
assert_contains "${POLICIES}/taxonomy-knowledge-pack.md" "High-context language is not yet an AI contract" "EN taxonomy high-context lens"
assert_contains "${POLICIES}/taxonomy-knowledge-pack.md" "positive target behavior" "EN taxonomy positive prompt lens"
assert_contains "${POLICIES}/taxonomy-knowledge-pack.ko.md" "TAX-AIERA-001" "KO taxonomy asset id"
assert_contains "${POLICIES}/taxonomy-knowledge-pack.ko.md" "분류 가능한 자산" "KO taxonomy asset lens"
assert_contains "${POLICIES}/taxonomy-knowledge-pack.ko.md" "고맥락 언어는 아직 AI 계약이 아니다" "KO taxonomy high-context lens"
assert_contains "${POLICIES}/taxonomy-knowledge-pack.ko.md" "긍정적 목표 행동" "KO taxonomy positive prompt lens"

# BLOCKER-2 (CEO §1.15 gate C1): the WIKI-AIERA section must stay review-questions
# only. llm-wiki core mechanic (ingest purpose-gate / source_type schema / sfs init
# interview / queryable-company) is core-product surface, not a Schema-layer lens
# rule. Section-scoped negative-lock converts the boundary from prose-judgment to
# a red-proof gate (mirrors the by-reference number lock above).
for f in "${POLICIES}/obsidian-llm-wiki.md" "${POLICIES}/obsidian-llm-wiki.ko.md"; do
  section="$(awk '/## WIKI-AIERA/{f=1} f' "${f}")"
  [[ -n "${section}" ]] || fail "WIKI-AIERA section missing in $(basename "${f}")"
  for tok in "source_type" "sfs init" "init interview" "purpose gate" "queryable" "company query"; do
    if printf '%s' "${section}" | grep -Fq -- "${tok}"; then
      fail "WIKI-AIERA mechanic leak in $(basename "${f}"): '${tok}'"
    fi
  done
done

echo "test-pack-expand-aiera-lens: OK"
