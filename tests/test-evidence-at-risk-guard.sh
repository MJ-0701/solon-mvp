#!/usr/bin/env bash
# WU-0 BUGFIX-evidence-at-risk-guard regression lock.
#
# Reproduces the exam-prep failure mode: a sprint runs S1->S2->verify->review
# PASS while the entire working tree stays untracked (git commit 0), the sprint
# is never closed (retro --close never runs), and no surface warns. That is a
# direct violation of the "never forget the handoff" product contract — a
# working-tree accident would lose all evidence.
#
# This is the Red case: open sprint + passing review_run + untracked files must
# light up three existing surfaces (status / dispatch / healthcheck) as
# advisory-only signals. None of them may block.
#
# Markers are ASCII so the assertions never depend on UTF-8 grep locale.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
COMMON="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-common.sh"
DISPATCH="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-dispatch.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-evidence-at-risk.XXXXXX")"
cleanup() { rm -rf "${TMP_DIR}"; }
trap cleanup EXIT

cd "${TMP_DIR}"
git init -q
git config user.email "evidence@solon.invalid"
git config user.name "Solon Evidence Test"
printf '# evidence-at-risk\n' > README.md
git add README.md && git commit -qm "init"

SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1

SPRINT="2026-W23-sprint-1"
mkdir -p ".sfs-local/sprints/${SPRINT}"
printf '%s\n' "${SPRINT}" > ".sfs-local/current-sprint"
printf 'WU-0\n' > ".sfs-local/current-wu"
EVENTS=".sfs-local/events.jsonl"
: > "${EVENTS}"

# A passing review result file — verdict lives in the result doc, not the event
# payload (the runtime reads output_path then greps the verdict line).
RESULT_PATH=".sfs-local/sprints/${SPRINT}/review-result.md"
printf 'gate: G5\nverdict: pass\n' > "${RESULT_PATH}"

emit() {
  local t="$1" body="${2:-}"
  printf '{"ts":"2026-06-05T10:00:00+09:00","type":"%s","sprint_id":"%s"%s}\n' \
    "${t}" "${SPRINT}" "${body}" >> "${EVENTS}"
}

# Open sprint + passing review_run pointing at the PASS result file.
emit "wu_open" ',"wu_id":"WU-0"'
emit "review_open" ',"gate_id":"G5"'
emit "review_run" ",\"gate_id\":\"G5\",\"output_path\":\"${RESULT_PATH}\",\"review_stage\":\"cross\""

# The crux of the bug: the whole working tree is UNTRACKED (git status `??`).
printf 'work 1\n' > untracked-1.txt
printf 'work 2\n' > untracked-2.txt
printf 'work 3\n' > untracked-3.txt

# ─────────────────────────────────────────────────────────────────────
# 1) shared predicate: at-risk when open sprint + review PASS + untracked
# ─────────────────────────────────────────────────────────────────────
# shellcheck source=/dev/null
RISK="$(
  cd "${TMP_DIR}" \
    && SFS_LOCAL_DIR=".sfs-local" SFS_EVENTS_FILE=".sfs-local/events.jsonl" \
       bash -c 'source "$1"; sfs_evidence_at_risk_status' _ "${COMMON}"
)"
[[ "${RISK}" == "at-risk" ]] || fail "predicate should report at-risk, got: '${RISK}'"

# ─────────────────────────────────────────────────────────────────────
# 2) sfs status surfaces the evidence-at-risk marker (additive, 1 line)
# ─────────────────────────────────────────────────────────────────────
STATUS_OUT="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" status --color never 2>&1)"
grep -q "evidence-at-risk" <<<"${STATUS_OUT}" \
  || fail "status should show evidence-at-risk: ${STATUS_OUT}"

# ─────────────────────────────────────────────────────────────────────
# 3) dispatch emits an escalating stderr notice but NEVER blocks (exit 0)
# ─────────────────────────────────────────────────────────────────────
set +e
NOTICE_OUT="$(SFS_DIST_DIR="${DIST_DIR}" SFS_RUNTIME_DIR="${DIST_DIR}/templates/.sfs-local-template" \
  bash "${DISPATCH}" review --help 2>&1 1>/dev/null)"
NOTICE_RC=$?
set -e
[[ "${NOTICE_RC}" -eq 0 ]] || fail "dispatch must not block on evidence-at-risk, rc=${NOTICE_RC}"
grep -q "evidence-at-risk" <<<"${NOTICE_OUT}" \
  || fail "dispatch stderr should carry evidence-at-risk notice: ${NOTICE_OUT}"

# Escalation: more events since the PASS review push the notice to URGENT.
for i in 1 2 3 4 5 6; do emit "decision_created" ",\"n\":\"${i}\""; done
set +e
URGENT_OUT="$(SFS_DIST_DIR="${DIST_DIR}" SFS_RUNTIME_DIR="${DIST_DIR}/templates/.sfs-local-template" \
  bash "${DISPATCH}" review --help 2>&1 1>/dev/null)"
URGENT_RC=$?
set -e
[[ "${URGENT_RC}" -eq 0 ]] || fail "escalated dispatch must not block, rc=${URGENT_RC}"
grep -qi "URGENT" <<<"${URGENT_OUT}" \
  || fail "dispatch notice should escalate to URGENT after many steps: ${URGENT_OUT}"

# ─────────────────────────────────────────────────────────────────────
# 4) healthcheck WARNs (read-only) — never a FAIL issue, exit unchanged
# ─────────────────────────────────────────────────────────────────────
set +e
HC_OUT="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_HEALTHCHECK_SKIP_RUNTIME_TESTS=1 \
  SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" healthcheck 2>&1)"
set -e
grep -q "evidence-at-risk" <<<"${HC_OUT}" \
  || fail "healthcheck should warn about evidence-at-risk: ${HC_OUT}"
grep -qi "WARN" <<<"${HC_OUT}" \
  || fail "healthcheck evidence-at-risk must be a WARN line: ${HC_OUT}"
grep -q "FAIL .*evidence-at-risk" <<<"${HC_OUT}" \
  && fail "healthcheck evidence-at-risk must NOT be a FAIL issue: ${HC_OUT}"

# ─────────────────────────────────────────────────────────────────────
# 4b) durability: after scratch is tidied, the verdict must survive in the
#     durable review.md. Real review results live in ephemeral
#     .sfs-local/tmp/review-runs/.../result.md which tidy removes — if the guard
#     only saw scratch it would go silent in exactly the long-session case it
#     exists to catch.
# ─────────────────────────────────────────────────────────────────────
rm -f "${RESULT_PATH}"   # scratch/result file gone (tidied)
printf '# review\n\n> verdict: pass\n' > ".sfs-local/sprints/${SPRINT}/review.md"
RISK_DURABLE="$(
  cd "${TMP_DIR}" \
    && SFS_LOCAL_DIR=".sfs-local" SFS_EVENTS_FILE=".sfs-local/events.jsonl" \
       bash -c 'source "$1"; sfs_evidence_at_risk_status' _ "${COMMON}"
)"
[[ "${RISK_DURABLE}" == "at-risk" ]] \
  || fail "guard must survive scratch tidy via durable review.md verdict, got: '${RISK_DURABLE}'"
# restore a passing result file for the remaining scenarios
printf 'gate: G5\nverdict: pass\n' > "${RESULT_PATH}"

# ─────────────────────────────────────────────────────────────────────
# 5) negative: once the tree is committed, no surface flags it
# ─────────────────────────────────────────────────────────────────────
git add -A && git commit -qm "commit work" >/dev/null 2>&1
RISK_AFTER="$(
  cd "${TMP_DIR}" \
    && SFS_LOCAL_DIR=".sfs-local" SFS_EVENTS_FILE=".sfs-local/events.jsonl" \
       bash -c 'source "$1"; sfs_evidence_at_risk_status' _ "${COMMON}"
)"
[[ "${RISK_AFTER}" == "ok" ]] || fail "committed tree should be ok, got: '${RISK_AFTER}'"

STATUS_AFTER="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" status --color never 2>&1)"
grep -q "evidence-at-risk" <<<"${STATUS_AFTER}" \
  && fail "committed tree status must not flag evidence-at-risk: ${STATUS_AFTER}"

# ─────────────────────────────────────────────────────────────────────
# 6) negative: no passing review -> no flag even with untracked files
# ─────────────────────────────────────────────────────────────────────
printf 'fail\nverdict: fail\n' > "${RESULT_PATH}"
printf 'more\n' > untracked-extra.txt
RISK_NOPASS="$(
  cd "${TMP_DIR}" \
    && SFS_LOCAL_DIR=".sfs-local" SFS_EVENTS_FILE=".sfs-local/events.jsonl" \
       bash -c 'source "$1"; sfs_evidence_at_risk_status' _ "${COMMON}"
)"
[[ "${RISK_NOPASS}" == "ok" ]] || fail "non-pass review should be ok, got: '${RISK_NOPASS}'"

echo "test-evidence-at-risk-guard: OK"
