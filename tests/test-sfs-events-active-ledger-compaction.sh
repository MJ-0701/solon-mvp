#!/usr/bin/env bash
# tests/test-sfs-events-active-ledger-compaction.sh — events.jsonl is bounded active state.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-events-compact.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

count_type() {
  local type="$1"
  grep -F "\"type\":\"${type}\"" .sfs-local/events.jsonl 2>/dev/null | wc -l | tr -d '[:space:]'
}

cd "${TMP_DIR}"
git init -q
printf '# Events Compact Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start "compact active ledger" >/dev/null
sid="$(cat .sfs-local/current-sprint)"

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" brainstorm --simple "first" >/dev/null
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" brainstorm --simple "second" >/dev/null
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" plan >/dev/null
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" plan >/dev/null

[[ "$(count_type sprint_start)" = "1" ]] || fail "sprint_start should be a single active line"
[[ "$(count_type brainstorm_open)" = "1" ]] || fail "brainstorm_open should compact repeated opens"
[[ "$(count_type plan_open)" = "1" ]] || fail "plan_open should compact repeated opens"
[[ "$(wc -l < .sfs-local/events.jsonl | tr -d '[:space:]')" -le 3 ]] || fail "events.jsonl should not grow as append-only history"

old_sid="2026-W00-sprint-1"
tmp_events=".sfs-local/events.injected"
{
  printf '{"ts":"2026-05-01T00:00:00+09:00","type":"sprint_start","sprint_id":"%s","goal":"closed"}\n' "${old_sid}"
  printf '{"ts":"2026-05-01T00:01:00+09:00","type":"plan_open","sprint_id":"%s","path":".sfs-local/sprints/%s/plan.md"}\n' "${old_sid}" "${old_sid}"
  printf '{"ts":"2026-05-01T00:02:00+09:00","type":"sprint_close","sprint_id":"%s"}\n' "${old_sid}"
  cat .sfs-local/events.jsonl
} > "${tmp_events}"
mv "${tmp_events}" .sfs-local/events.jsonl

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" tidy --all --apply >/dev/null
! grep -Fq "\"sprint_id\":\"${old_sid}\"" .sfs-local/events.jsonl \
  || fail "tidy should prune closed-sprint event lines while keeping only active sprint state"
grep -Fq "\"sprint_id\":\"${sid}\"" .sfs-local/events.jsonl \
  || fail "tidy should keep current sprint active-state event lines"

rm -f .sfs-local/current-sprint
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" tidy --all --apply >/dev/null
[[ ! -e .sfs-local/events.jsonl ]] || fail "events.jsonl should be removed when no active sprint needs it"
[[ -f "docs/solon/compact-active-ledger/$(date +%Y%m%d)/report.md" ]] \
  || fail "closed sprint should leave durable shared report"
[[ ! -e ".sfs-local/sprints/${sid}/brainstorm.md" ]] || fail "closed workbench docs should not remain visible"

echo "test-sfs-events-active-ledger-compaction: OK"
