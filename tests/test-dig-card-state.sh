#!/usr/bin/env bash
# sfs dig C+E — fact-card validator + confirmation state machine headline.
#
# Locks:
#   - fixed card schema: frontmatter (card_id/target/confidence 0-2) +
#     required sections (Purpose/Inputs/Side effects/Tables/Calls/Evidence)
#   - deterministic rejects own hallucination control: narrative without a
#     file:line citation, bad confidence scale, evidence citing a
#     nonexistent file — all REJECT with nonzero exit
#   - confirmation states derived deterministically (signal-only):
#     unverified (1 evidence file) -> corroborated (2+ independent files)
#     -> verified (runtime evidence present)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DIG="${DIST_DIR}/scripts/sfs-dig.sh"
CARDS="${SCRIPT_DIR}/fixtures/dig/cards"
SPRING="${SCRIPT_DIR}/fixtures/dig/spring-jpa"
NODE="${SCRIPT_DIR}/fixtures/dig/node-prisma"

fail() { echo "FAIL: $*" >&2; exit 1; }

run() { bash "${DIG}" card validate "$@" 2>&1; }

# ── PASS + state derivation ─────────────────────────────────────────
out="$(run "${CARDS}/good-corroborated.md" --root "${SPRING}")" || fail "corroborated card rejected: ${out}"
grep -q "state=corroborated" <<<"${out}" || fail "2 independent evidence files must derive corroborated: ${out}"

out="$(run "${CARDS}/good-verified.md" --root "${NODE}")" || fail "verified card rejected: ${out}"
grep -q "state=verified" <<<"${out}" || fail "runtime evidence must derive verified: ${out}"

out="$(run "${CARDS}/good-unverified.md" --root "${SPRING}")" || fail "unverified card rejected: ${out}"
grep -q "state=unverified" <<<"${out}" || fail "single evidence file must derive unverified: ${out}"

# ── deterministic rejects (hallucination control) ────────────────────
if out="$(run "${CARDS}/bad-no-evidence.md" --root "${SPRING}")"; then
  fail "narrative without file:line citation must be rejected"
fi
grep -q "no file:line citation" <<<"${out}" || fail "reject reason must name the missing citation: ${out}"

if out="$(run "${CARDS}/bad-confidence.md" --root "${NODE}")"; then
  fail "confidence outside 0|1|2 must be rejected"
fi
grep -q "confidence must be 0|1|2" <<<"${out}" || fail "reject reason must name the confidence scale: ${out}"

if out="$(run "${CARDS}/bad-ghost-evidence.md" --root "${NODE}")"; then
  fail "evidence citing a nonexistent file must be rejected"
fi
grep -q "nonexistent file" <<<"${out}" || fail "reject reason must name the ghost file: ${out}"

# ── directory mode: any invalid card fails the batch ────────────────
if run "${CARDS}" --root "${SPRING}" >/dev/null; then
  fail "directory mode must exit nonzero when any card is invalid"
fi

echo "test-dig-card-state: OK"
