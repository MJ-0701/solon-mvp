#!/usr/bin/env bash
# Agent-entry doc hygiene — 회귀 방지 잠금 (0.7.2).
#
# 사용자 보고 (2026-05-28): "CLAUDE.md / AGENTS.md / GEMINI.md 같은 agent
# 지침서는 agent 지침에 맞는 내용이 들어가야지, 프로젝트 진행사항 / 아키텍처
# / 인프라 / 방법론 같은 내용이 박히면 안 된다. 프로젝트 정보는 frontmatter
# 로만 연결한다."
#
# 본 테스트는 그 룰을 정적으로 잠근다.
#
#   1. top-level CLAUDE.md / AGENTS.md 는 thin agent entry 다.
#      - 본문 100 줄 이하.
#      - body 에 프로젝트-정보-성격 H2 (예: "Repo 정체성", "배포 원칙",
#        "수정 시 체크리스트", "7-step flow 요약") 가 나오면 fail.
#      - 단 agent 행동 룰 H2 (예: "Agent 가 절대 하지 말 것",
#        "비동작", "Non-Goals", "작업 전 읽을 것", "참고", "Changelog",
#        "진입 순서") 는 허용.
#
#   2. consumer 어댑터 template (CLAUDE.md.template, AGENTS.md.template,
#      GEMINI.md.template) 은 `frontmatter_only: true` 마커를 유지해야
#      한다. 마커가 사라지면 fail.
#
#   3. SFS.md.template 는 router doc 으로 body 가 더 길어도 되지만,
#      `router_doc: true` 마커를 유지해야 한다.
#
#   4. 새로 분리된 maintenance doc 들 (docs/maintenance/*.md) 은 실제로
#      존재해야 한다 — CLAUDE.md 가 frontmatter 의 detail_sources 로
#      이들을 가리키므로, 깨진 link 가 되면 안 된다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() { echo "FAIL: $*" >&2; exit 1; }

# ── 1) top-level thin entry 검사 ─────────────────────────────────────
top_entries=(
  "${DIST_DIR}/CLAUDE.md"
  "${DIST_DIR}/AGENTS.md"
)

# Body 에 등장하면 안 되는 H2 (project content pollution markers).
forbidden_h2=(
  '## Repo 정체성'
  '## 배포 원칙'
  '## 수정 시 체크리스트'
  '## 7-step flow 요약'
  '## Repo identity'
  '## Release policy'
  '## Modification checklist'
  '## 7-step flow summary'
)

for f in "${top_entries[@]}"; do
  [[ -f "${f}" ]] || fail "missing top-level agent entry: ${f}"

  lines="$(wc -l <"${f}" | tr -d '[:space:]')"
  [[ "${lines}" -le 100 ]] || fail "${f} exceeds 100 lines: ${lines} (thin agent entry must point at docs/maintenance/, not inline project content)"

  for h2 in "${forbidden_h2[@]}"; do
    if grep -Fxq -- "${h2}" "${f}"; then
      fail "${f}: forbidden project-content H2 detected: '${h2}'
  rationale: project identity / release policy / modification checklists / methodology summaries belong in docs/maintenance/*.md, not in the thin agent entry.
  fix: move the section out, leave only a cross-link in body or frontmatter detail_sources."
    fi
  done

  # The thin entry MUST link out to the maintenance docs (proves the
  # split happened and the link target is real).
  grep -Fq 'docs/maintenance/' "${f}" \
    || fail "${f}: thin agent entry must cross-link to docs/maintenance/"
done

# ── 2) consumer adapter templates 는 frontmatter_only ────────────────
adapter_templates=(
  "${DIST_DIR}/templates/CLAUDE.md.template"
  "${DIST_DIR}/templates/AGENTS.md.template"
  "${DIST_DIR}/templates/GEMINI.md.template"
)
for f in "${adapter_templates[@]}"; do
  [[ -f "${f}" ]] || fail "missing adapter template: ${f}"
  grep -qE '^frontmatter_only:[[:space:]]*true' "${f}" \
    || fail "${f}: must keep \`frontmatter_only: true\` marker"
  # WU-B: wiki awareness is a frontmatter pointer (knowledge_wiki block),
  # never inlined policy body. Lock the pointer's presence; the body-line
  # counter below keeps it frontmatter-only.
  grep -qE '^knowledge_wiki:' "${f}" \
    || fail "${f}: must keep \`knowledge_wiki:\` pointer block (WU-B)"
  # No body content beyond the closing --- (frontmatter only).
  # Count non-blank lines AFTER the second '---'.
  body_lines="$(awk '
    /^---$/ { fence++; next }
    fence >= 2 && NF > 0 { count++ }
    END { print count + 0 }
  ' "${f}")"
  [[ "${body_lines}" -le 2 ]] \
    || fail "${f}: adapter template must stay frontmatter-only; found ${body_lines} non-blank body lines after the closing fence."
done

# ── 3) SFS.md.template 는 router_doc 마커 유지 ──────────────────────
sfs_tpl="${DIST_DIR}/templates/SFS.md.template"
[[ -f "${sfs_tpl}" ]] || fail "missing SFS.md.template"
grep -qE '^router_doc:[[:space:]]*true' "${sfs_tpl}" \
  || fail "${sfs_tpl}: must keep \`router_doc: true\` marker"
sfs_lines="$(wc -l <"${sfs_tpl}" | tr -d '[:space:]')"
[[ "${sfs_lines}" -le 120 ]] \
  || fail "${sfs_tpl} exceeds 120 lines: ${sfs_lines} (router doc may be longer than adapter templates but should still stay compact)"

# ── 4) maintenance docs 실제 존재 ───────────────────────────────────
maintenance_docs=(
  "${DIST_DIR}/docs/maintenance/project-identity.md"
  "${DIST_DIR}/docs/maintenance/release-policy.md"
  "${DIST_DIR}/docs/maintenance/contributing.md"
  "${DIST_DIR}/docs/maintenance/methodology-7-step.md"
  "${DIST_DIR}/docs/maintenance/policies/session-transfer-autopilot.md"
)
for f in "${maintenance_docs[@]}"; do
  [[ -f "${f}" ]] || fail "missing maintenance doc referenced by thin agent entry: ${f}"
  # Each maintenance doc must have frontmatter (for routing).
  first_line="$(sed -n '1p' "${f}")"
  [[ "${first_line}" == "---" ]] \
    || fail "${f}: missing opening frontmatter (maintenance docs must be LLM-loadable)"
done

echo "test-agent-entry-doc-hygiene: OK"
