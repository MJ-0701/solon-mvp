#!/usr/bin/env bash
# WU-3 (user-lecture-2026-07-15) — spec interview gate, headline.
#
# Locks SPEC_INTERVIEW_GATE: impact-ordered questions (design-overturning
# first), answers merged into the spec, explicit skip records; an open
# question keeps the plan draft. Plan command + review-readiness checklist
# carry the check. Additive: pre-existing plan anchors preserved.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POLICY="${CTX}/policies/unknowns-and-deviations.md"
PLAN_TPL="${DIST_DIR}/templates/.sfs-local-template/sprint-templates/plan.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fhas_ko() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── policy anchor + ordering + merge + skip rules ────────────────────
fhas "${POLICY}" "SPEC_INTERVIEW_GATE" "interview gate anchor"
fhas "${POLICY}" "design-overturning questions first" "design-overturning-first rule"
fhas "${POLICY}" "detail questions last" "impact-ordering tail rule"
fhas "${POLICY}" "merged into the" "answer-merge-into-spec rule"
fhas "${POLICY}" "skip: <reason>" "explicit skip record format"
fhas "${POLICY}" "deferring is allowed, silence is not" "skip-vs-silence rule"
fhas "${POLICY}" 'status: draft' "open-question keeps plan draft"

# ── plan command + template carry the gate ───────────────────────────
fhas "${CTX}/commands/plan.md" "SPEC_INTERVIEW_GATE" "plan.md interview pointer"
fhas "${CTX}/commands/plan.md" "design-overturning first" "plan.md ordering rule"
fhas_ko "${PLAN_TPL}" "인터뷰 열린 질문이 남아 있지 않다" "plan template readiness item"
fhas_ko "${PLAN_TPL}" "명시적 skip" "plan template skip record item"

# ── additive guarantee ───────────────────────────────────────────────
fhas "${POLICY}" "UNKNOWNS_QUADRANT" "pre-existing quadrant anchor preserved"
fhas "${POLICY}" "BLIND_SPOT_PASS" "pre-existing blind-spot anchor preserved"
fhas "${CTX}/commands/plan.md" "UNKNOWNS_QUADRANT" "plan.md quadrant pointer preserved"
fhas_ko "${PLAN_TPL}" "완료 기준이 측정 가능하다" "plan template pre-existing checklist preserved"

# ── vendor/lecture hygiene ───────────────────────────────────────────
if grep -Eiq 'fable|opus|sonnet|haiku|claude code|cowork' "${POLICY}"; then
  fail "vendor/model name leaked into unknowns-and-deviations.md"
fi

# ── budgets ──────────────────────────────────────────────────────────
for f in "${POLICY}" "${CTX}/commands/plan.md"; do
  lines="$(wc -l < "$f")"
  [[ "${lines}" -le 200 ]] || fail "$(basename "$f") exceeds 200-line budget (${lines})"
done

echo "PASS: spec interview gate locked"
