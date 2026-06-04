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
old_event_excerpt=".sfs-local/archives/events/sprints/${old_sid}.jsonl"
[[ -f "${old_event_excerpt}" ]] \
  || fail "tidy should preserve pruned closed-sprint events before pruning active ledger"
grep -Fq "\"type\":\"sprint_close\"" "${old_event_excerpt}" \
  || fail "closed-sprint event excerpt should keep raw sprint_close line"
grep -Fq "\"sprint_id\":\"${old_sid}\"" "${old_event_excerpt}" \
  || fail "closed-sprint event excerpt should be grep-friendly by sprint id"

rm -f .sfs-local/current-sprint
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" tidy --all --apply >/dev/null
[[ ! -e .sfs-local/events.jsonl ]] || fail "events.jsonl should be removed when no active sprint needs it"
current_event_excerpt=".sfs-local/archives/events/sprints/${sid}.jsonl"
[[ -f "${current_event_excerpt}" ]] \
  || fail "tidy should preserve formerly-active sprint events before deleting empty active ledger"
grep -Fq "\"type\":\"sprint_start\"" "${current_event_excerpt}" \
  || fail "formerly-active sprint event excerpt should keep raw sprint_start line"
[[ -f "docs/solon/compact-active-ledger/$(date +%Y%m%d)/report.md" ]] \
  || fail "closed sprint should leave durable shared report"
[[ ! -e ".sfs-local/sprints/${sid}/brainstorm.md" ]] || fail "closed workbench docs should not remain visible"

close_dir="${TMP_DIR}/close-case"
mkdir -p "${close_dir}"
cd "${close_dir}"
git init -q
printf '# Retro Close Events Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start "retro close event preservation" >/dev/null
close_sid="$(cat .sfs-local/current-sprint)"
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" brainstorm --simple "close case" >/dev/null
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" plan >/dev/null
printf '{"ts":"2026-05-09T01:20:00+09:00","type":"review_open","sprint_id":"%s"}\n' "${close_sid}" >> .sfs-local/events.jsonl
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" retro >/dev/null
close_event_excerpt=".sfs-local/archives/events/sprints/${close_sid}.jsonl"
[[ -f "${close_event_excerpt}" ]] \
  || fail "retro close should preserve sprint event excerpt before pruning active ledger"
grep -Fq "\"type\":\"sprint_close\"" "${close_event_excerpt}" \
  || fail "retro close event excerpt should keep raw sprint_close line"
grep -Fq "\"type\":\"report_ready\"" "${close_event_excerpt}" \
  || fail "retro close event excerpt should keep raw report_ready line"
[[ ! -e .sfs-local/events.jsonl ]] || fail "retro close should prune active event ledger after preservation"
archive_tar="$(find ".sfs-local/archives/sprints/${close_sid}" -name sprint-evidence.tar.gz -type f | head -1)"
[[ -n "${archive_tar}" ]] || fail "retro close should keep sprint cold archive"
tar -tzf "${archive_tar}" | grep -Fq "archives/events/sprints/${close_sid}.jsonl" \
  || fail "sprint cold archive should include preserved event excerpt"

close_fail_dir="${TMP_DIR}/close-fail-closed"
mkdir -p "${close_fail_dir}"
cd "${close_fail_dir}"
git init -q
printf '# Retro Close Fail Closed Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start "retro close fail closed" >/dev/null
close_fail_sid="$(cat .sfs-local/current-sprint)"
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" plan >/dev/null
printf '{"ts":"2026-05-09T01:20:00+09:00","type":"review_open","sprint_id":"%s"}\n' "${close_fail_sid}" >> .sfs-local/events.jsonl
mkdir -p .sfs-local/archives
printf 'not a directory\n' > .sfs-local/archives/events
set +e
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" retro >/dev/null 2>retro-fail.err
retro_fail_rc=$?
set -e
[[ "${retro_fail_rc}" -ne 0 ]] || fail "retro close should fail closed when event excerpt archive path cannot be written"
[[ -f .sfs-local/current-sprint ]] || fail "retro close preservation failure should keep current-sprint pointer"
grep -Fq "\"sprint_id\":\"${close_fail_sid}\"" .sfs-local/events.jsonl \
  || fail "retro close preservation failure should leave sprint events in active ledger"
[[ -f ".sfs-local/sprints/${close_fail_sid}/plan.md" ]] \
  || fail "retro close preservation failure should not compact workbench before event preservation"

fail_closed_dir="${TMP_DIR}/fail-closed-case"
mkdir -p "${fail_closed_dir}"
cd "${fail_closed_dir}"
git init -q
printf '# Fail Closed Events Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" start "fail closed event preservation" >/dev/null
fail_current_sid="$(cat .sfs-local/current-sprint)"
fail_old_sid="2026-W00-fail-closed"
{
  printf '{"ts":"2026-05-01T00:00:00+09:00","type":"sprint_start","sprint_id":"%s","goal":"closed"}\n' "${fail_old_sid}"
  printf '{"ts":"2026-05-01T00:02:00+09:00","type":"sprint_close","sprint_id":"%s"}\n' "${fail_old_sid}"
  cat .sfs-local/events.jsonl
} > .sfs-local/events.injected
mv .sfs-local/events.injected .sfs-local/events.jsonl
mkdir -p .sfs-local/archives
printf 'not a directory\n' > .sfs-local/archives/events
set +e
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" tidy --all --apply >/dev/null 2>tidy-fail.err
tidy_fail_rc=$?
set -e
[[ "${tidy_fail_rc}" -ne 0 ]] || fail "tidy should fail closed when event excerpt archive path cannot be written"
grep -Fq "\"sprint_id\":\"${fail_old_sid}\"" .sfs-local/events.jsonl \
  || fail "tidy must not prune historical events when preservation fails"
grep -Fq "\"sprint_id\":\"${fail_current_sid}\"" .sfs-local/events.jsonl \
  || fail "tidy preservation failure should leave active sprint events in the ledger"

echo "test-sfs-events-active-ledger-compaction: OK"
