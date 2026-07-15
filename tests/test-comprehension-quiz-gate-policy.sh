#!/usr/bin/env bash
# WU-5 (user-lecture-2026-07-15) — comprehension quiz gate refinement, headline.
#
# Locks the COMPREHENSION_GATE quiz rules: 3–5 questions drawn only from the
# slice's changed code/decisions, result recorded in the sprint workbench,
# each missed question links to the explainer/report section that answers it.
# Signal-only standing preserved.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POLICY="${CTX}/policies/unknowns-and-deviations.md"
REPORT_TPL="${DIST_DIR}/templates/.sfs-local-template/sprint-templates/report.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fhas_ko() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── quiz scope + record + wrong-answer routing ───────────────────────
fhas "${POLICY}" "3–5 questions drawn only from this slice's changed" "changed-code-only scope rule"
fhas "${POLICY}" "no general-knowledge trivia" "trivia exclusion"
fhas "${POLICY}" "in the sprint workbench (report / retro)" "record location rule"
fhas "${POLICY}" "each missed question links to" "wrong-answer link rule"
fhas "${POLICY}" "targeted re-read, never to a block" "signal-only routing"

# ── report template carries the record slot ──────────────────────────
fhas "${REPORT_TPL}" "comprehension quiz" "report template quiz slot"
fhas_ko "${REPORT_TPL}" "변경 기반 3~5문항" "report template scope hint"

# ── review command carries the quiz check ────────────────────────────
fhas "${CTX}/commands/review.md" "COMPREHENSION_GATE" "review.md gate pointer preserved"
fhas "${CTX}/commands/review.md" "drawn only from the changed code/decisions" "review.md scope rule"

# ── additive guarantee ───────────────────────────────────────────────
fhas "${POLICY}" "COMPREHENSION_GATE" "pre-existing comprehension anchor preserved"
fhas "${POLICY}" "explainer" "pre-existing explainer artifact preserved"
fhas "${POLICY}" "HTML-encouraged" "pre-existing docs-strategy tie-in preserved"
fhas "${POLICY}" "signal-only" "pre-existing signal-only standing preserved"

# ── budgets ──────────────────────────────────────────────────────────
for f in "${POLICY}" "${CTX}/commands/review.md"; do
  lines="$(wc -l < "$f")"
  [[ "${lines}" -le 200 ]] || fail "$(basename "$f") exceeds 200-line budget (${lines})"
done

echo "PASS: comprehension quiz gate locked"
