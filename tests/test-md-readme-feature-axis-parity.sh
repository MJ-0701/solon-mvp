#!/usr/bin/env bash
# 0.13.1 / 0.14.1 — the thin index feature table must stay in sync with what shipped.
#
# README.md (ko) and docs/en/index.md (en) both carry the six-axis "what Solon
# provides" table. It is the first thing a reader sees, so it drifts silently
# whenever a release adds a surface and nobody updates the index. This test
# locks: both tables carry the same six axes, both carry the 0.13.0 clauses,
# the axis rows point at commands that exist, and the safety contract names the
# two new standing rules. Also asserts the README stays a thin index — the table
# routes to the feature overview instead of restating it.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
RM="${DIST_DIR}/README.md"
EN="${DIST_DIR}/docs/en/index.md"
SAFETY="${DIST_DIR}/README/09-section.md"
KO_OVERVIEW="${DIST_DIR}/docs/ko/current-product-shape/29-feature-overview.md"
EN_OVERVIEW="${DIST_DIR}/docs/en/current-product-shape/29-feature-overview.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
khas() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── (a) both indexes carry a six-axis table ─────────────────────────
ko_axes="$(LC_ALL=C awk '/^\| 축 \|/,/^$/' "${RM}" | grep -c '^| ' || true)"
en_axes="$(awk '/^\| Axis \|/,/^$/' "${EN}" | grep -c '^| ' || true)"
# The `|---|---|---|` separator has no space after the pipe, so it is not
# counted: header + 6 axis rows = 7.
[[ "${ko_axes}" -eq 7 ]] || fail "README.md feature table has ${ko_axes} rows, expected 7 (header + 6 axes)"
[[ "${en_axes}" -eq 7 ]] || fail "docs/en/index.md feature table has ${en_axes} rows, expected 7"

# ── (b) the 0.13.0 clauses reached BOTH indexes ─────────────────────
khas "${RM}" "런 중 intent 재검증" "ko axis: in-flight recheck"
khas "${RM}" "과제약·중복 지시 감지" "ko axis: rightsize detection"
khas "${RM}" "지시 배치 판별" "ko axis: instruction classification"
khas "${RM}" "advisor 선택 코칭" "ko axis: advisor binding"
khas "${RM}" "보안 finding 클래스 폐루프" "ko axis: security closed loop"

fhas "${EN}" "recheck intent mid-run" "en axis: in-flight recheck"
fhas "${EN}" "redundant-guidance detection" "en axis: rightsize detection"
fhas "${EN}" "instruction classification" "en axis: instruction classification"
fhas "${EN}" "advisor coaching binding" "en axis: advisor binding"
fhas "${EN}" "security finding class closed loop" "en axis: security closed loop"

# ── (b2) the 0.14.0 clauses reached BOTH indexes ────────────────────
khas "${RM}" "구현 착수 전 자기 반증 패스" "ko axis: self-refutation pass"
khas "${RM}" "고위험 티어는 추론 로그" "ko axis: reasoning log"
khas "${RM}" "게이트 활동 계측" "ko axis: gate activity reading"
khas "${RM}" "결과당 비용 프레임" "ko axis: cost per outcome"
khas "${RM}" "단계별 effort 사전 배분" "ko axis: staged effort"

fhas "${EN}" "self-refutation pass runs before implementation" "en axis: self-refutation pass"
fhas "${EN}" "reasoning log on the top risk tier" "en axis: reasoning log"
fhas "${EN}" "gate activity reading" "en axis: gate activity reading"
fhas "${EN}" "cost-per-outcome framing" "en axis: cost per outcome"
fhas "${EN}" "per-stage effort allocation" "en axis: staged effort"

# ── (c) thin index — the table routes, it does not restate ──────────
fhas "${RM}" "29-feature-overview.md" "README routes to the feature overview"
for f in "${KO_OVERVIEW}" "${EN_OVERVIEW}"; do
  [[ -f "${f}" ]] || fail "feature overview missing: ${f}"
done
# Every anchor named in an index clause must have its full row in the overview,
# so the index stays a pointer and the overview stays the SSoT.
for anchor in RIGHTSIZE_CONTEXT_PASS RULE_VS_GUARDRAIL ADVISOR_STRATEGY_BINDING \
              VULNERABILITY_CLASS_CLOSED_LOOP MID_RUN_INTENT_RECHECK \
              ANTAGONISTIC_RESEARCH_PASS REASONING_LOG_AS_AUDIT_ARTIFACT \
              KNOB_DIAGNOSTIC_LADDER VERSIONED_EXTENSION_SURFACE \
              SUBAGENT_TIER_DEFAULT DELEGATION_UNIT_LADDER gate_activity_check; do
  grep -Ewq -- "${anchor}" "${KO_OVERVIEW}" || fail "ko overview missing anchor row: ${anchor}"
  grep -Ewq -- "${anchor}" "${EN_OVERVIEW}" || fail "en overview missing anchor row: ${anchor}"
done
rm_lines="$(wc -l < "${RM}" | tr -d '[:space:]')"
[[ "${rm_lines}" -le 100 ]] || fail "README.md grew to ${rm_lines} lines — it is a thin index, not a manual"

# ── (d) safety contract carries the two new standing rules ──────────
khas "${SAFETY}" "집행 표면" "safety: invariants live on an enforcement surface"
khas "${SAFETY}" "접점마다" "safety: per-touch ingress check"
khas "${SAFETY}" "다른 에이전트의 요청도" "safety: agents are inside the boundary"
# The pre-existing contract must survive the addition.
khas "${SAFETY}" "조용히 덮어쓰지 않습니다" "safety: no silent overwrite preserved"
khas "${SAFETY}" "최종 제품 판단은 항상 사용자" "safety: human owns product judgment preserved"

# ── (d2) 0.14.0 safety additions, ko README section + both overviews ─
khas "${SAFETY}" "그 자체로 안전 근거가 아닙니다" "safety: approval is not the argument"
khas "${SAFETY}" "재량에 넘기지 않는 클래스" "safety: the never-approve class"
khas "${SAFETY}" "광역 waiver 는 예외가 아니라 게이트 폐지" "safety: blanket waiver is gate removal"
khas "${KO_OVERVIEW}" "APPROVAL_FATIGUE_DECAY" "ko overview safety: approval decay anchor"
khas "${KO_OVERVIEW}" "NEVER_APPROVE_CLASS" "ko overview safety: never-approve anchor"
fhas "${EN_OVERVIEW}" "APPROVAL_FATIGUE_DECAY" "en overview safety: approval decay anchor"
fhas "${EN_OVERVIEW}" "NEVER_APPROVE_CLASS" "en overview safety: never-approve anchor"
fhas "${EN_OVERVIEW}" "not a safety argument" "en overview safety: the discarded assumption"

# ── (e) commands named by the axes actually exist ───────────────────
# Asserted against the real runtime's own inventory rather than by grepping
# the dispatcher: commands are declared in pipe-separated case patterns, so a
# naive `cmd)` grep only matches whichever alternative happens to be last.
inventory="$(bash "${DIST_DIR}/bin/sfs" help --full 2>&1 || true)"
[[ -n "${inventory}" ]] || fail "sfs help --full produced no inventory to check against"
for cmd in start plan implement review capture recall dig audit context team route ingest tidy; do
  printf '%s' "${inventory}" | grep -Eq "(^|[[:space:],])${cmd}([[:space:],]|$)" \
    || fail "README axis names a command missing from the runtime inventory: ${cmd}"
done

# ── (f) line budgets ────────────────────────────────────────────────
for f in "${RM}" "${EN}" "${SAFETY}"; do
  lines="$(wc -l < "${f}" | tr -d '[:space:]')"
  [[ "${lines}" -le 200 ]] || fail "$(basename "${f}") exceeds 200-line budget (${lines})"
done

echo "PASS: README / en-index feature axis parity locked"
