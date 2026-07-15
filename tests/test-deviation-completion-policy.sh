#!/usr/bin/env bash
# WU-2 (user-lecture-2026-07-15) — deviation log completion contract, headline.
#
# Locks the DEVIATIONS_LOG refinement: a completion claim must state the
# deviation ledger explicitly (entries or `none observed`); the sprint
# implement artifact carries a `## Deviations` section; Gate 6 review reads
# the ledger. Additive: pre-existing DEVIATIONS_LOG anchors preserved.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POLICY="${CTX}/policies/unknowns-and-deviations.md"
IMPL_TPL="${DIST_DIR}/templates/.sfs-local-template/sprint-templates/implement.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fhas_ko() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── completion-claim rule in the policy ─────────────────────────────
fhas "${POLICY}" "none observed" "explicit empty-ledger literal"
fhas "${POLICY}" "A completion claim states the ledger explicitly" "completion-claim rule"
fhas "${POLICY}" "next sprint's map" "deviation-log-as-map principle"

# ── sprint artifact template carries the section ─────────────────────
fhas "${IMPL_TPL}" "## Deviations" "implement template Deviations section"
fhas "${IMPL_TPL}" "none observed" "implement template empty-ledger literal"
fhas "${IMPL_TPL}" "DEVIATIONS_LOG" "implement template policy pointer"

# ── implement + review commands carry the contract ───────────────────
fhas "${CTX}/commands/implement.md" "DEVIATIONS_LOG" "implement.md deviation pointer"
fhas "${CTX}/commands/implement.md" "none observed" "implement.md empty-ledger literal"
fhas "${CTX}/commands/review.md" "none observed" "review.md unstated-ledger check"

# ── additive guarantee: pre-existing anchors survive ─────────────────
fhas "${POLICY}" "DEVIATIONS_LOG" "pre-existing deviations anchor preserved"
fhas "${POLICY}" "conservative" "pre-existing conservative-choice rule preserved"
fhas "${POLICY}" "## Deviations" "pre-existing heading convention preserved"
fhas "${POLICY}" "Gate 6 review finding" "pre-existing gate-6 finding rule preserved"

# ── lecture hygiene: no lecture/vendor specifics in touched files ────
for f in "${POLICY}" "${IMPL_TPL}"; do
  if LC_ALL=C grep -Eiq 'second brain|세컨드 브레인' "${f}"; then
    fail "$(basename "${f}"): lecture-specific naming leaked"
  fi
done

# ── budgets ──────────────────────────────────────────────────────────
for f in "${POLICY}" "${CTX}/commands/implement.md" "${CTX}/commands/review.md"; do
  lines="$(wc -l < "$f")"
  [[ "${lines}" -le 200 ]] || fail "$(basename "$f") exceeds 200-line budget (${lines})"
done

echo "PASS: deviation completion contract locked"
