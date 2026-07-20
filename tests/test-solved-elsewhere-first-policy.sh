#!/usr/bin/env bash
# BLOG-2026-07-17-2 — solved-elsewhere-first + eval-surface blind spot.
#
# Locks: SOLVED_ELSEWHERE_FIRST (lessons consult heuristic + dig surface),
# EVAL_SURFACE_BLIND_SPOT (BLIND_SPOT_PASS checks the eval/test surface
# itself). Vendor names/figures locked out.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
LES="${CTX}/policies/lessons-accumulation.md"
UNK="${CTX}/policies/unknowns-and-deviations.md"
DIG="${CTX}/commands/dig.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fhas_ko() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── (a) solved elsewhere first ───────────────────────────────────────
fhas "${LES}" "SOLVED_ELSEWHERE_FIRST" "lessons heuristic anchor"
fhas "${LES}" "already solved somewhere" "first-hypothesis rule"
fhas "${LES}" "drift signal" "naive-retry drift rule"
fhas_ko "${DIG}" "SOLVED_ELSEWHERE_FIRST" "dig search-surface pointer"

# ── (b) eval surface blind spot ──────────────────────────────────────
fhas "${UNK}" "EVAL_SURFACE_BLIND_SPOT" "unknowns eval-surface anchor"
fhas "${UNK}" "eval/test
surface itself" "eval-surface-in-checklist rule"
fhas "${UNK}" "surfaces that as a finding" "self-report path"

# ── additive guarantee ───────────────────────────────────────────────
fhas "${LES}" "Consult obligation" "lessons consult section preserved"
fhas "${LES}" "SOLVED_ELSEWHERE" "anchor present"
fhas "${LES}" "CURATION_PASS" "lessons curation preserved"
fhas "${UNK}" "BLIND_SPOT_PASS" "blind-spot anchor preserved"
fhas "${UNK}" "blind_spots" "blind_spots list preserved"
fhas_ko "${DIG}" "REFERENCES_FIELD" "dig references bridge preserved"

# ── vendor lockout ───────────────────────────────────────────────────
for f in "${LES}" "${UNK}" "${DIG}"; do
  if grep -Eiq 'base44|superagents' "${f}"; then
    fail "$(basename "${f}"): vendor name leaked"
  fi
done

# ── budgets ──────────────────────────────────────────────────────────
for f in "${LES}" "${UNK}" "${DIG}"; do
  lines="$(wc -l < "$f")"
  [[ "${lines}" -le 200 ]] || fail "$(basename "$f") exceeds 200-line budget (${lines})"
done

echo "PASS: solved-elsewhere-first + eval-surface blind spot locked"
