#!/usr/bin/env bash
# WU-7 (user-lecture-2026-07-15) — prototype fork mode, headline.
#
# Locks PROTOTYPE_FORK: when direction cannot be verbalized, fork 2–4 cheap
# variants, present a comparison table, operator picks; selection + rejection
# reasons are recorded in the brainstorm workbench. Optional pre-spec step on
# the existing Gate 2 rail — no new lifecycle command, signal-only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POLICY="${CTX}/policies/unknowns-and-deviations.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fhas_ko() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── policy anchor + fork rules ───────────────────────────────────────
fhas "${POLICY}" "PROTOTYPE_FORK" "prototype fork anchor"
fhas "${POLICY}" "2–4 cheap variants" "variant count rule"
fhas "${POLICY}" "comparison table" "comparison table rule"
fhas "${POLICY}" "rejection reasons" "rejection record rule"
fhas "${POLICY}" "optional pre-spec step on the existing Gate 2 rail" "existing-rail placement"
fhas "${POLICY}" "lifecycle command, signal-only" "no-new-command boundary"

# ── brainstorm command carries the fork ──────────────────────────────
fhas "${CTX}/commands/brainstorm.md" "PROTOTYPE_FORK" "brainstorm.md fork pointer"
fhas "${CTX}/commands/brainstorm.md" "rejection" "brainstorm.md rejection record"

# ── methodology quick-ref carries the pointer ────────────────────────
fhas_ko "${DIST_DIR}/docs/maintenance/methodology-7-step.md" "PROTOTYPE_FORK" "methodology fork pointer"

# ── additive guarantee ───────────────────────────────────────────────
fhas "${POLICY}" "BLIND_SPOT_PASS" "pre-existing blind-spot anchor preserved"
fhas "${CTX}/commands/brainstorm.md" "Advancement Scorecard" "brainstorm.md pre-existing scorecard preserved"
fhas "${CTX}/commands/brainstorm.md" "Deep-interview convergence" "brainstorm.md pre-existing interview anchor preserved"

# ── vendor/lecture hygiene ───────────────────────────────────────────
if grep -Eiq 'fable|opus|sonnet|haiku|claude code|cowork' "${POLICY}"; then
  fail "vendor/model name leaked into unknowns-and-deviations.md"
fi

# ── budgets ──────────────────────────────────────────────────────────
for f in "${POLICY}" "${CTX}/commands/brainstorm.md"; do
  lines="$(wc -l < "$f")"
  [[ "${lines}" -le 200 ]] || fail "$(basename "$f") exceeds 200-line budget (${lines})"
done

echo "PASS: prototype fork mode locked"
