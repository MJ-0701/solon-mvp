#!/usr/bin/env bash
# WU-4 (user-lecture-2026-07-15) — kickoff blind_spots check step, headline.
#
# Locks the BLIND_SPOT_PASS refinement: the pass output is a concrete
# `blind_spots` list in the kickoff artifact with per-item states
# (answered / delegated / open); an open item at contract freeze is a
# plan-readiness finding. Brainstorm template + command carry the section.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POLICY="${CTX}/policies/unknowns-and-deviations.md"
BS_TPL="${DIST_DIR}/templates/.sfs-local-template/sprint-templates/brainstorm.md"
PLAN_TPL="${DIST_DIR}/templates/.sfs-local-template/sprint-templates/plan.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fhas_ko() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── policy: list + states + freeze rule ──────────────────────────────
fhas "${POLICY}" "blind_spots" "blind_spots list anchor"
fhas "${POLICY}" "\`answered\` (operator decided)" "answered state"
fhas "${POLICY}" "\`delegated\` (explicitly left to the worker's conservative judgment)" "delegated state"
fhas "${POLICY}" "plan-readiness finding" "open-at-freeze rule"

# ── kickoff artifact template section ────────────────────────────────
fhas "${BS_TPL}" "blind_spots" "brainstorm template blind_spots section"
fhas "${BS_TPL}" "answered / delegated / open" "brainstorm template state values"
fhas "${BS_TPL}" "BLIND_SPOT_PASS" "brainstorm template policy pointer"

# ── plan/brainstorm commands + plan readiness checklist ──────────────
fhas "${CTX}/commands/plan.md" "blind_spots" "plan.md blind_spots pointer"
fhas "${CTX}/commands/brainstorm.md" "blind_spots" "brainstorm.md blind_spots pointer"
fhas_ko "${PLAN_TPL}" "blind_spots 항목이 전부 answered / delegated" "plan template readiness item"

# ── additive guarantee ───────────────────────────────────────────────
fhas "${POLICY}" "BLIND_SPOT_PASS" "pre-existing blind-spot anchor preserved"
fhas "${POLICY}" "non-technical operators" "pre-existing operator emphasis preserved"
fhas_ko "${BS_TPL}" "## 6. 막는 질문" "brainstorm template pre-existing section preserved"
fhas_ko "${BS_TPL}" "## 7. Plan 재료" "brainstorm template plan-seed section preserved"

# ── vendor/lecture hygiene ───────────────────────────────────────────
for f in "${POLICY}" "${BS_TPL}"; do
  if LC_ALL=C grep -Eiq 'second brain|세컨드 브레인' "${f}"; then
    fail "$(basename "${f}"): lecture-specific naming leaked"
  fi
done

# ── budgets ──────────────────────────────────────────────────────────
for f in "${POLICY}" "${CTX}/commands/brainstorm.md"; do
  lines="$(wc -l < "$f")"
  [[ "${lines}" -le 200 ]] || fail "$(basename "$f") exceeds 200-line budget (${lines})"
done

echo "PASS: blind-spot check step locked"
