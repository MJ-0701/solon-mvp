#!/usr/bin/env bash
# DESIGN-2026-07-03 (ai-ready-codebase-token-efficiency) P1 — headline.
#
# Eval-first cache-invalidation scenario checklist, locked as anchors.
# Each scenario must be answered by templates policy text:
#   S1 mid-session model-tier change      -> frozen at session start, fresh session
#   S2 mid-session root-adapter/policy edit -> land the edit, then fresh session
#   S3 long session / TTL expiry           -> handoff + fresh session over
#                                             repeated in-place compaction
#   S4 heavy exploration in lead session   -> scoped worker keeps lead prefix warm
#   S5 capsule exemplar                    -> optional exemplar field exists
# Additive-only: pre-existing token-harness anchors stay (0.8.36 layout).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
TOKEN="${CTX}/policies/token-harness.md"
CAPSULE_EN="${CTX}/policies/sub-agent-capsule-contract.md"
CAPSULE_KO="${CTX}/policies/sub-agent-capsule-contract.ko.md"
WIKI_EN="${DIST_DIR}/docs/en/current-product-shape/17-token-harness-hygiene.md"
WIKI_KO="${DIST_DIR}/docs/ko/current-product-shape/17-token-harness-hygiene.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# section anchor.
has "${TOKEN}" "Cache-prefix discipline" "discipline section anchor"

# S1 + S2: prefix surfaces frozen per session; change means fresh session.
has "${TOKEN}" "frozen for the session" "S1/S2 session-frozen prefix surfaces"
has "${TOKEN}" "land the change, then start a fresh session" "S2 adapter/policy edit exit path"

# S3: restart over repeated compaction.
has "${TOKEN}" "repeatedly compacted" "S3 anti repeated-compaction"
has "${TOKEN}" "session-continuation-guard.md" "S3 handoff cross-ref"

# S4: delegation keeps the lead prefix warm (cache rationale only, no re-statement).
has "${TOKEN}" "lead prefix warm" "S4 delegation cache rationale"

# S5: capsule exemplar field, EN + KO twins.
has "${CAPSULE_EN}" "\`exemplar\`" "S5 exemplar field (en)"
has "${CAPSULE_KO}" "\`exemplar\`" "S5 exemplar field (ko)"

# doc colocation: product-shape wiki carries the cache bullet, both languages.
has "${WIKI_EN}" "prompt cache" "wiki cache bullet (en)"
has "${WIKI_KO}" "prompt cache" "wiki cache bullet (ko)"

# additive guarantee: 0.8.36 layout anchors and neighbouring bullets stay.
has "${TOKEN}" "CACHE_AWARE_PROMPT_LAYOUT" "pre-existing layout anchor preserved"
has "${TOKEN}" "One model per run segment" "pre-existing model-segment anchor preserved"
has "${TOKEN}" "Runtime Token Firewall" "pre-existing firewall anchor preserved"
has "${TOKEN}" "Session Continuation Guard" "pre-existing continuation anchor preserved"

# line budgets on touched templates policies.
for f in "${TOKEN}" "${CAPSULE_EN}" "${CAPSULE_KO}"; do
  lines="$(wc -l < "${f}")"
  [[ "${lines}" -lt 200 ]] || fail "$(basename "${f}") exceeds 200-line budget (${lines})"
done

echo "PASS"
