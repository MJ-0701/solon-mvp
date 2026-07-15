#!/usr/bin/env bash
# WU-6 (user-lecture-2026-07-15) — spec references field, headline.
#
# Locks REFERENCES_FIELD: the plan may point at existing code that already
# does the desired behavior (path/repo/commit + one-line intent); when set,
# the worker reads references before implementing and records the read trace
# in the implementation log. Template stays placeholder-only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POLICY="${CTX}/policies/unknowns-and-deviations.md"
PLAN_TPL="${DIST_DIR}/templates/.sfs-local-template/sprint-templates/plan.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fhas_ko() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── policy anchor + rules ────────────────────────────────────────────
fhas "${POLICY}" "REFERENCES_FIELD" "references field anchor"
fhas "${POLICY}" "more precise spec than prose describing it" "pointer-beats-prose principle"
fhas "${POLICY}" "reads the references before implementing" "read-before-implement rule"
fhas "${POLICY}" "no read trace in the log is a review" "missing-trace finding rule"
fhas "${POLICY}" "cite locations, do not paste" "pointer-not-payload rule"
fhas "${POLICY}" "source-pointer-citation.md" "citation policy cross-ref"

# ── plan template field is a placeholder (no fixed value) ────────────
fhas_ko "${PLAN_TPL}" "references (경로/리포/커밋 + 모방할 점 한 줄" "plan template references field"
ref_line="$(LC_ALL=C grep -F -- "references (경로/리포/커밋" "${PLAN_TPL}")"
case "${ref_line}" in
  *:) : ;; # ends with a colon → placeholder, no baked-in value
  *) fail "plan template references line carries a fixed value: '${ref_line}'" ;;
esac
fhas_ko "${PLAN_TPL}" "references 가 있으면 구현 전 필독" "plan template readiness item"

# ── plan + implement commands carry the contract ─────────────────────
fhas "${CTX}/commands/plan.md" "REFERENCES_FIELD" "plan.md references pointer"
fhas "${CTX}/commands/implement.md" "REFERENCES_FIELD" "implement.md references pointer"
fhas "${CTX}/commands/implement.md" "read them before the first edit" "implement.md read-first rule"

# ── additive guarantee ───────────────────────────────────────────────
fhas "${POLICY}" "UNKNOWNS_QUADRANT" "pre-existing quadrant anchor preserved"
fhas "${POLICY}" "DEVIATIONS_LOG" "pre-existing deviations anchor preserved"
fhas_ko "${PLAN_TPL}" "AI 위임 범위:" "plan template pre-existing contract field preserved"

# ── budgets ──────────────────────────────────────────────────────────
for f in "${POLICY}" "${CTX}/commands/plan.md" "${CTX}/commands/implement.md"; do
  lines="$(wc -l < "$f")"
  [[ "${lines}" -le 200 ]] || fail "$(basename "$f") exceeds 200-line budget (${lines})"
done

echo "PASS: spec references field locked"
