#!/usr/bin/env bash
# INSIGHT-2026-07-12 (marketing-ops automation patterns) — headline.
#
# Locks four generalized principles, all additive by-reference:
#   1. DISPATCHER_SPECIALIST_SEPARATION — the dispatch layer routes only
#      (role check + capsule issue/collect); execution always belongs to a
#      specialist that can evolve independently (team-topology design doc,
#      consistent with the OCP binding=data principle)
#   2. fresh-context audit agent — external validation of the
#      verifier != implementer invariant (harness-autonomy)
#   3. repeated-correction trigger — same correction twice = skill candidate
#      at floor 2 (skill-promotion-loop DETECTION, fourth signal)
#   4. end-of-session reflect pass — CURATION_PASS at session grain
#      (lessons-accumulation) + operator-facing GUIDE wording ko/en
#      ("Claude builds the skill for you")
# Vendor hygiene: the vendor product name appears nowhere in touched routed
# policies. Additive: pre-existing anchors preserved.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
TOPO="${DIST_DIR}/docs/maintenance/2026-06-23-multi-agent-team-topology.design.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── Principle 1: dispatcher/specialist separation ────────────────────
fhas "${TOPO}" "DISPATCHER_SPECIALIST_SEPARATION" "topology separation anchor"
LC_ALL=C grep -q "라우팅만" "${TOPO}" || fail "topology: missing routing-only wording"
fhas "${TOPO}" "by-reference" "topology external case by-reference"

# ── Principle 2: fresh-context audit agent ──────────────────────────
fhas "${CTX}/policies/harness-autonomy.md" "fresh-context audit agent" "audit-agent anchor"
fhas "${CTX}/policies/harness-autonomy.md" "builder context" "fresh-context meaning"
fhas "${CTX}/policies/harness-autonomy.md" "by-reference" "audit case by-reference"

# ── Principle 3: repeated-correction trigger ─────────────────────────
fhas "${CTX}/policies/skill-promotion-loop.md" "repeated-correction trigger" "correction trigger anchor"
fhas "${CTX}/policies/skill-promotion-loop.md" "lower floor (2)" "correction floor"
fhas "${CTX}/policies/skill-promotion-loop.md" "promote it into the" "external standing rule wording"

# ── Principle 4: end-of-session reflect pass + GUIDE wording ─────────
fhas "${CTX}/policies/lessons-accumulation.md" "end-of-session reflect pass" "reflect pass anchor"
fhas "${CTX}/policies/lessons-accumulation.md" "session grain" "curation-at-session-grain wording"
LC_ALL=C grep -q "skill 은 Claude 가 대신 만들어" "${DIST_DIR}/GUIDE/16-15-team-rollout.md" \
  || fail "GUIDE ko: missing operator skill wording"
fhas "${DIST_DIR}/docs/en/guide/11-10-team-rollout.md" "Claude builds the skill for you" "GUIDE en operator wording"
fhas "${DIST_DIR}/GUIDE/16-15-team-rollout.md" "skill-promotion-loop.md" "GUIDE ko routes to policy"
fhas "${DIST_DIR}/docs/en/guide/11-10-team-rollout.md" "lessons-accumulation.md" "GUIDE en routes to policy"

# ── Vendor hygiene: product name locked out of touched routed policies ─
for f in "${CTX}/policies/harness-autonomy.md" \
         "${CTX}/policies/skill-promotion-loop.md" \
         "${CTX}/policies/lessons-accumulation.md"; do
  if grep -Eiq 'cowork|fable' "$f"; then
    fail "vendor product/model name leaked into $(basename "$f")"
  fi
done

# ── Budgets ──────────────────────────────────────────────────────────
for f in "${TOPO}" "${CTX}/policies/harness-autonomy.md" \
         "${CTX}/policies/skill-promotion-loop.md" \
         "${CTX}/policies/lessons-accumulation.md"; do
  lines="$(wc -l < "$f")"
  [[ "${lines}" -le 200 ]] || fail "$(basename "$f") exceeds 200-line budget (${lines})"
done

# ── Additive guarantee: pre-existing anchors survive ─────────────────
fhas "${TOPO}" "Entry-agnostic" "topology principle 4 preserved"
fhas "${TOPO}" "Standalone guarantee" "topology principle 2 preserved"
fhas "${CTX}/policies/harness-autonomy.md" "Verifier != implementer" "verifier invariant preserved"
fhas "${CTX}/policies/harness-autonomy.md" "verification capability is the precondition" "autonomy precondition preserved"
fhas "${CTX}/policies/skill-promotion-loop.md" "usage-value signal" "third DETECTION source preserved"
fhas "${CTX}/policies/skill-promotion-loop.md" "HELD_OUT_SCORING" "held-out scoring preserved"
fhas "${CTX}/policies/lessons-accumulation.md" "CURATION_PASS" "curation pass preserved"
fhas "${CTX}/policies/lessons-accumulation.md" "DEVIATIONS_LOG" "deviations signal preserved"

echo "PASS: dispatcher/specialist separation + fresh-context audit + reflect loop locked"
