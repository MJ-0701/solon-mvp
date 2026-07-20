#!/usr/bin/env bash
# BLOG-2026-07-19-2 — wrong-premise eval fixture + recon run + conflict scan.
#
# Locks: WRONG_PREMISE_EVAL_FIXTURE (evals README axis + HELD_OUT_SCORING
# mention), RECON_RUN_BEFORE_COMMIT (unknowns pre-attempt recon),
# SHARED_SURFACE_CONFLICT_SCAN (capsule worker preflight), route-unknown
# uncertainty line in the knob ladder. Vendor/bench names locked out.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
EVALS="${DIST_DIR}/templates/.sfs-local-template/evals/README.md"
PROMOTE="${CTX}/policies/skill-promotion-loop.md"
UNK="${CTX}/policies/unknowns-and-deviations.md"
CAP="${CTX}/policies/sub-agent-capsule-contract.md"
TH="${CTX}/policies/token-harness.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fhas_ko() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# ── (a) wrong-premise fixture axis ───────────────────────────────────
fhas "${EVALS}" "WRONG_PREMISE_EVAL_FIXTURE" "evals README fixture anchor"
fhas_ko "${EVALS}" "일부러 틀린 전제" "deliberately-wrong-premise type"
fhas_ko "${EVALS}" "잘못된 전제를 반박하고 root" "refute-premise judging rule"
fhas_ko "${EVALS}" "JUDGE_NEGATIVE_CONTROL" "evals negative-control tie"
fhas "${PROMOTE}" "wrong-premise" "held-out scoring fixture-axis mention"
fhas "${PROMOTE}" "WRONG_PREMISE_EVAL_FIXTURE" "held-out scoring anchor ref"

# ── (b) recon run before commit ──────────────────────────────────────
fhas "${UNK}" "RECON_RUN_BEFORE_COMMIT" "unknowns recon anchor"
fhas "${UNK}" "read-only recon pass" "read-only recon rule"
fhas "${UNK}" "no new artifact, no new command" "no-structure rule"
fhas "${TH}" "route-unknown" "knob ladder uncertainty delta"

# ── (c) shared-surface conflict scan ─────────────────────────────────
fhas "${CAP}" "SHARED_SURFACE_CONFLICT_SCAN" "capsule conflict-scan anchor"
fhas "${CAP}" "recent commits" "commit-scan rule"
fhas "${CAP}" "surfaces the conflict" "preflight-before-edit rule"

# ── additive guarantee ───────────────────────────────────────────────
fhas "${EVALS}" "eval-first" "evals README discipline preserved"
fhas_ko "${EVALS}" "표면 확장" "evals README surface-expansion preserved"
fhas "${PROMOTE}" "HELD_OUT_SCORING" "held-out anchor preserved"
fhas "${UNK}" "PROTOTYPE_FORK" "prototype fork preserved"
fhas "${CAP}" "files_scope" "capsule files_scope preserved"
fhas "${TH}" "KNOB_DIAGNOSTIC_LADDER" "knob ladder preserved"

# ── vendor lockout ───────────────────────────────────────────────────
for f in "${EVALS}" "${PROMOTE}" "${UNK}" "${CAP}" "${TH}"; do
  if grep -Eiq 'cursor|72\.9' "${f}"; then
    fail "$(basename "${f}"): vendor/bench name leaked"
  fi
done

# ── budgets (promote has its own stricter <200 lock elsewhere) ───────
for f in "${PROMOTE}" "${UNK}" "${CAP}" "${TH}"; do
  lines="$(wc -l < "$f")"
  [[ "${lines}" -le 200 ]] || fail "$(basename "$f") exceeds 200-line budget (${lines})"
done

echo "PASS: wrong-premise eval + recon run + conflict scan locked"
