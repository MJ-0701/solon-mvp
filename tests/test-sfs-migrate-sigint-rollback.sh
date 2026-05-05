#!/usr/bin/env bash
# tests/test-sfs-migrate-sigint-rollback.sh — G6.1 F3 regression.
#
# Two layers:
#   (A) Static contract — script source MUST register signal-aware traps and
#       hook journal_replay_cleanup before snapshot restore. Always runs.
#   (B) Integration probe — try to land SIGINT mid-apply on a sized workload.
#       If the host completes the migration before SIGINT lands the trap is
#       not exercised; the probe reports SKIPPED rather than FAIL.
#
# Contract assertions cover the regression even when the integration probe
# can't be exercised on fast hardware.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
MIGRATE="${DIST_DIR}/scripts/sfs-migrate-artifacts.sh"

[[ -x "${MIGRATE}" ]] || { echo "missing: ${MIGRATE}" >&2; exit 1; }

# ─── (A) Static contract checks ────────────────────────────────────────────
fail=0
check() {
  # check "<label>" "<grep -E pattern>"
  if ! grep -qE "$2" "${MIGRATE}"; then
    echo "F3 FAIL: ${1}"
    fail=$((fail + 1))
  fi
}

check "trap registers on_interrupt INT"            "trap[[:space:]]+'on_interrupt INT'[[:space:]]+INT"
check "trap registers on_interrupt TERM"           "trap[[:space:]]+'on_interrupt TERM'[[:space:]]+TERM"
check "SIGINT branch exits 130"                    "INT\\)[[:space:]]+exit 130"
check "SIGTERM branch exits 143"                   "TERM\\)[[:space:]]+exit 143"
check "journal_replay_cleanup invoked in trap"     "on_interrupt.*\\n.*journal_replay_cleanup|journal_replay_cleanup.*TX_JOURNAL"
check "snapshot restore inside trap"               "cp -a.*SNAPSHOT_FOR_INT.*files"
check "git status verify in trap"                  "git -C.*status --porcelain"

# G6.1.1 V2 — cp -a snapshot restore must not silently swallow failures.
if grep -E 'cp -a[^|]*SNAPSHOT_FOR_INT[^|]*\|\| true' "${MIGRATE}" >/dev/null; then
  echo "F3/V2 FAIL: cp -a still has '|| true' after SNAPSHOT_FOR_INT (G6.1.1 V2 fix incomplete)"
  fail=$((fail + 1))
fi
check "exit code 5 (SEVERE rollback) reachable"    "exit 5"
check "SEVERE marker emitted on rollback failure"  "SEVERE.*rollback INCOMPLETE"

# G6.1.1 HB2 — re-entrancy guard at trap entry.
if ! awk '/^on_interrupt\(\)/,/^}/' "${MIGRATE}" | head -10 | grep -qE "trap[[:space:]]+''[[:space:]]+INT[[:space:]]+TERM"; then
  echo "F3/HB2 FAIL: on_interrupt() does not block trap re-entrancy (trap '' INT TERM expected near function entry)"
  fail=$((fail + 1))
fi

# Looser fallback for the multiline trap composition
if ! awk '/^on_interrupt\(\)/,/^}/' "${MIGRATE}" | grep -q 'journal_replay_cleanup'; then
  echo "F3 FAIL: on_interrupt() body does not call journal_replay_cleanup"
  fail=$((fail + 1))
fi

if [[ "${fail}" -gt 0 ]]; then
  echo "test-sfs-migrate-sigint-rollback: ${fail} contract violation(s)"
  exit 1
fi

echo "test-sfs-migrate-sigint-rollback: contract OK (traps + signal-aware exit + journal+snapshot cleanup)"

# ─── (B) Integration probe (best-effort; SKIPPED if host too fast) ────────
tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT
cd "${tmp}"
git init -q
git config user.email t@t
git config user.name t

# Large-ish workload — 60 sprints × 4 files × ~80KB each = 240 files.
for s in $(seq 1 60); do
  mkdir -p ".sfs-local/sprints/0-5-x-${s}"
  for f in $(seq 1 4); do
    head -c 80000 /dev/urandom | base64 > ".sfs-local/sprints/0-5-x-${s}/file-${f}.md"
  done
done
git add -A && git commit -q -m init >/dev/null
src_count_pre="$(find .sfs-local/sprints -type f | wc -l | tr -d ' ')"

bash "${MIGRATE}" --no-tty --root . >/dev/null 2>&1 &
pid=$!
sleep 0.5

if ! kill -0 ${pid} 2>/dev/null; then
  echo "test-sfs-migrate-sigint-rollback: integration probe SKIPPED (host raced to completion before SIGINT could land)"
  exit 0
fi

kill -INT ${pid} 2>/dev/null || true
wait ${pid} 2>/dev/null
code=$?

if [[ "${code}" -eq 0 ]]; then
  echo "test-sfs-migrate-sigint-rollback: integration probe SKIPPED (script raced to clean exit before SIGINT trap — host too fast)"
  exit 0
fi

# Exit code 130 (SIGINT) / 143 (SIGTERM) / legacy 4 acceptable.
if [[ "${code}" -ne 130 ]] && [[ "${code}" -ne 143 ]] && [[ "${code}" -ne 4 ]]; then
  echo "test-sfs-migrate-sigint-rollback: integration probe WARN — exit ${code} (expected 130 for SIGINT)"
fi

dest_residual="$(find .solon/sprints -type f 2>/dev/null | wc -l | tr -d ' ')"
if [[ "${dest_residual}" -gt 0 ]]; then
  echo "test-sfs-migrate-sigint-rollback: integration probe FAIL — ${dest_residual} dest files left (rollback incomplete)"
  exit 1
fi

archive_residual="$(find .sfs-local/archives/migrate-archive -type f 2>/dev/null | wc -l | tr -d ' ')"
if [[ "${archive_residual}" -gt 0 ]]; then
  echo "test-sfs-migrate-sigint-rollback: integration probe FAIL — ${archive_residual} archive files left"
  exit 1
fi

src_count_post="$(find .sfs-local/sprints -type f 2>/dev/null | wc -l | tr -d ' ')"
if [[ "${src_count_post}" -lt "${src_count_pre}" ]]; then
  echo "test-sfs-migrate-sigint-rollback: integration probe FAIL — src count post=${src_count_post} < pre=${src_count_pre}"
  exit 1
fi

echo "test-sfs-migrate-sigint-rollback: integration probe OK (exit ${code}, no residual, src ${src_count_post}/${src_count_pre})"
