#!/usr/bin/env bash
# BLOG-2026-06-19-3 "Claude Code now supports artifacts" absorption — headline.
#
# Locks the generalized live-status surface pattern WITHOUT promoting the vendor
# Team/Enterprise beta feature as a solon capability or dependency:
#   (a) HTML-encouraged doc strategy (release-policy.md §5) gains a live-status
#       variant — session state -> self-updating shared status surface, file
#       ledger authoritative, HTML derived;
#   (b) flowcheck.md names the render path that unifies status / flowcheck /
#       PROGRESS into one live surface;
#   (c) regression: the vendor feature is by-reference and explicitly NOT a
#       dependency (removing it leaves all behavior intact).
# Additive-only: pre-existing anchors in both touched files stay.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
FLOW="${CTX}/commands/flowcheck.md"
RELPOL="${DIST_DIR}/docs/maintenance/release-policy.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
has_ko() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── (b) flowcheck render path unifies the three surfaces ───────────
has "${FLOW}" "Live status surface" "flowcheck live-status section anchor"
has "${FLOW}" "self-updating status surface" "flowcheck self-updating surface"
has "${FLOW}" "sfs status" "flowcheck names status surface"
has "${FLOW}" "PROGRESS" "flowcheck names PROGRESS ledger"
has "${FLOW}" "fills itself in as the run proceeds" "flowcheck self-filling checklist"
has "${FLOW}" "authoritative source and the" "flowcheck ledger-authoritative"
has "${FLOW}" "derived, never authoritative" "flowcheck render-is-derived"
has "${FLOW}" "by-reference" "flowcheck vendor by-reference"
# pre-existing flowcheck anchors preserved (additive guarantee)
has "${FLOW}" "Plan-gate self-check" "pre-existing plan-gate preserved"
has "${FLOW}" "eval-first" "pre-existing WU-0 eval-first preserved"
has "${FLOW}" "invariant SSoT" "pre-existing invariant-SSoT preserved"

# ── (a) HTML-encouraged strategy gains the live-status variant ─────
has_ko "${RELPOL}" "Live-status 변형" "release-policy live-status variant anchor"
has_ko "${RELPOL}" "스스로" "release-policy self-filling phrasing"
has "${RELPOL}" "events.jsonl" "release-policy file-ledger authoritative"
has "${RELPOL}" "flowcheck.md" "release-policy cross-ref to render path"
has "${RELPOL}" "by-reference" "release-policy vendor by-reference"
# pre-existing release-policy anchor preserved
has_ko "${RELPOL}" "User-facing docs HTML-encouraged" "pre-existing principle-5 title preserved"

# ── (c) regression: vendor feature is NOT a solon dependency ───────
# Wherever the vendor beta tier is named, the non-dependency framing must be in
# the same file — the feature is cited, never promoted as a solon capability.
for f in "${FLOW}" "${RELPOL}"; do
  if grep -Fq -- "Team/Enterprise" "${f}"; then
    if [[ "${f}" == "${RELPOL}" ]]; then
      has_ko "${f}" "의존하지 않는다" "$(basename "${f}") non-dependency framing"
    else
      has "${f}" "not a dependency" "$(basename "${f}") non-dependency framing"
    fi
  fi
done
# explicit positive locks on the non-dependency claim
has "${FLOW}" "not a dependency" "flowcheck explicit non-dependency"
has_ko "${RELPOL}" "의존하지 않는다" "release-policy explicit non-dependency"

# ── line budgets ───────────────────────────────────────────────────
for f in "${FLOW}" "${RELPOL}"; do
  lines="$(wc -l < "${f}")"
  [[ "${lines}" -lt 200 ]] || fail "$(basename "${f}") exceeds 200-line budget (${lines})"
done

echo "PASS"
