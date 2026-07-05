#!/usr/bin/env bash
# INSIGHT-2026-07-04 (Claude admin spend controls) — headline.
#
# Locks the three generalized principles, all additive by-reference:
#   1. success-side usage aggregation = value/promotion signal (flowcheck
#      usage-value line -> skill-promotion-loop DETECTION input,
#      self-improvement-loop MEASURE field twin)
#   2. warn-before-block on capsule token_budget/turn caps (threshold warning
#      before the ceiling; refine/pivot/halt at the warning)
#   3. formula transparency (score reports expose formula + inputs; no
#      black-box score as the measured leg)
# Vendor hygiene: enterprise feature names appear nowhere as product features.
# Additive: pre-existing hotspot / HELD_OUT_SCORING anchors preserved.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
FLOWCHECK_SH="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-flowcheck.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
has() { grep -Fq -- "$2" <<<"$1" || fail "$3: missing '$2'"; }

# ── Principle 1: usage aggregation anchors ──────────────────────────
fhas "${CTX}/commands/flowcheck.md" "usage-value" "flowcheck doc usage-value anchor"
fhas "${CTX}/commands/flowcheck.md" "성공측 집계" "flowcheck doc success-side wording"
fhas "${CTX}/policies/skill-promotion-loop.md" "usage-value signal" "DETECTION usage source anchor"
fhas "${CTX}/policies/skill-promotion-loop.md" "field-tested value" "repeated-use-is-value wording"
fhas "${CTX}/policies/self-improvement-loop.md" "usage-value signal" "MEASURE usage-signal anchor"
fhas "${FLOWCHECK_SH}" "usage-value signal" "flowcheck script emits the signal"

# ── Principle 2: warn-before-block anchors ──────────────────────────
fhas "${CTX}/policies/sub-agent-capsule-contract.md" "warn-before-block" "capsule warn-before-block anchor"
fhas "${CTX}/policies/sub-agent-capsule-contract.md" "refine / pivot / halt" "escalation choice at the warning"
fhas "${CTX}/policies/sub-agent-capsule-contract.md" "harness-autonomy.md" "escalation-ladder cross-ref"

# ── Principle 3: formula transparency anchors ───────────────────────
fhas "${CTX}/policies/skill-promotion-loop.md" "every formula is visible" "formula-visible anchor"
fhas "${CTX}/policies/skill-promotion-loop.md" "black-box score" "no-black-box wording"

# ── By-reference + vendor hygiene ───────────────────────────────────
fhas "${CTX}/policies/skill-promotion-loop.md" "by-reference" "principle 1/3 cited by-reference"
fhas "${CTX}/policies/sub-agent-capsule-contract.md" "by-reference" "principle 2 cited by-reference"
for f in "${CTX}/commands/flowcheck.md" \
         "${CTX}/policies/skill-promotion-loop.md" \
         "${CTX}/policies/self-improvement-loop.md" \
         "${CTX}/policies/sub-agent-capsule-contract.md"; do
  if grep -Eiq 'SCIM|entitlement|admin console|Analytics API|Admin API' "$f"; then
    fail "vendor feature name leaked into $(basename "$f")"
  fi
  lines="$(wc -l < "$f")"
  [[ "${lines}" -le 200 ]] || fail "$(basename "$f") exceeds 200-line budget (${lines})"
done

# ── Additive guarantee: pre-existing anchors survive ────────────────
fhas "${CTX}/commands/flowcheck.md" "hotspot" "flowcheck hotspot anchor preserved"
fhas "${FLOWCHECK_SH}" "repeated-failure hotspot" "script hotspot line preserved"
fhas "${CTX}/policies/skill-promotion-loop.md" "HELD_OUT_SCORING" "HELD_OUT_SCORING preserved"
fhas "${CTX}/policies/skill-promotion-loop.md" "necessary-but-not-sufficient" "nbns standing preserved"
fhas "${CTX}/policies/sub-agent-capsule-contract.md" "exemplar" "capsule exemplar field preserved"

# ── Functional fixture: usage-value line through the real flowcheck ─
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-usage-value.XXXXXX")"
trap 'rm -rf "${TMP_DIR}"' EXIT
cd "${TMP_DIR}"
git init -q
git config user.email "usage@solon.invalid"
git config user.name "Usage Test"
printf '# usage\n' > README.md
git add . && git commit -qm "init"
SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1

SPRINT="2026-W27-sprint-1"
mkdir -p ".sfs-local/sprints/${SPRINT}"
printf '%s\n' "${SPRINT}" > ".sfs-local/current-sprint"
EVENTS=".sfs-local/events.jsonl"

emit() {
  local t="$1"; shift
  local body=""
  for kv in "$@"; do body+=",\"${kv%%=*}\":\"${kv#*=}\""; done
  printf '{"ts":"2026-07-05T10:00:00+09:00","type":"%s","sprint_id":"%s"%s}\n' \
    "${t}" "${SPRINT}" "${body}" >> "${EVENTS}"
}

run_flowcheck() {
  set +e
  FLOW_OUT="$(SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" flowcheck 2>&1)"
  FLOW_RC=$?
  set -e
}

# conformant base + telemetry: status 4 ok (usage winner), review 2 ok + 1
# error (2 successes — under the 3 floor), plan 2 errors (hotspot, 0 ok).
emit model_resolved agent_role=implementation-worker resolved_tier=execution_standard resolved_model=sonnet-4.6 source=policy
emit gate_passed gate=G3 order_index=1 self_cpo=pass
emit gate_passed gate=G5 order_index=2 self_cpo=pass
emit verification_pair implementer=implementation-worker verifier=cpo-evaluator implementer_context=worker-1 verifier_context=review-1 gate=G5
emit tool_call tool=sfs_status outcome=ok latency_ms=40
emit tool_call tool=sfs_status outcome=ok latency_ms=42
emit tool_call tool=sfs_status outcome=ok latency_ms=44
emit tool_call tool=sfs_status outcome=ok latency_ms=46
emit tool_call tool=sfs_review outcome=ok latency_ms=100
emit tool_call tool=sfs_review outcome=ok latency_ms=110
emit tool_call tool=sfs_review outcome=error latency_ms=500
emit tool_call tool=sfs_plan outcome=error latency_ms=70
emit tool_call tool=sfs_plan outcome=error latency_ms=75
run_flowcheck

[[ "${FLOW_RC}" -eq 0 ]] || fail "usage aggregation must not change a conformant verdict (want 0, got ${FLOW_RC}): ${FLOW_OUT}"
has "${FLOW_OUT}" "usage-value signal: tool sfs_status — 4 successful call(s)" "usage winner is sfs_status (most successes)"
has "${FLOW_OUT}" "repeated-failure hotspot: tool sfs_plan" "hotspot unchanged (failure side intact)"
grep -q "usage-value signal: tool sfs_review" <<<"${FLOW_OUT}" \
  && fail "sfs_review (2 successes, under the 3 floor) must not be the usage winner: ${FLOW_OUT}"

# artifact carries the same advisory line.
ART=".sfs-local/sprints/${SPRINT}/workbench/flowcheck.md"
[[ -f "${ART}" ]] || fail "flowcheck artifact missing"
grep -q "usage-value signal: tool sfs_status" "${ART}" || fail "artifact missing usage-value line: $(cat "${ART}")"
grep -q "skill-promotion input" "${ART}" || fail "artifact usage line must route to skill promotion: $(cat "${ART}")"

# under-floor only (no tool at 3+ successes) -> no usage line, verdict intact.
: > "${EVENTS}"
emit model_resolved agent_role=implementation-worker resolved_tier=execution_standard resolved_model=sonnet-4.6 source=policy
emit gate_passed gate=G5 order_index=1 self_cpo=pass
emit verification_pair implementer=implementation-worker verifier=cpo-evaluator implementer_context=worker-1 verifier_context=review-1 gate=G5
emit tool_call tool=sfs_status outcome=ok latency_ms=40
emit tool_call tool=sfs_status outcome=ok latency_ms=41
run_flowcheck
[[ "${FLOW_RC}" -eq 0 ]] || fail "under-floor case should stay exit 0, got ${FLOW_RC}: ${FLOW_OUT}"
grep -q "usage-value signal" <<<"${FLOW_OUT}" \
  && fail "no usage-value line expected under the 3-success floor: ${FLOW_OUT}"

echo "test-usage-value-signal: OK"
