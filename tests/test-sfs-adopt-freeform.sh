#!/usr/bin/env bash
# tests/test-sfs-adopt-freeform.sh — adopt accepts the same natural-language brief shape as start/brainstorm.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-adopt-freeform.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

cd "${TMP_DIR}"
git init -q
printf '# Legacy Project\n\nExisting docs need a current-state cleanup.\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial legacy project'

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null

mkdir -p .sfs-local/sprints/2026-W19-sprint-1
printf '# Active Legacy Sprint\n\nThis sprint predates adoption and should be cold-archived.\n' \
  > .sfs-local/sprints/2026-W19-sprint-1/plan.md
printf '2026-W19-sprint-1\n' > .sfs-local/current-sprint
mkdir -p .sfs-local/tmp/review-prompts
printf 'legacy review prompt\n' > .sfs-local/tmp/review-prompts/2026-W19-sprint-1-gate3.txt
mkdir -p .sfs-local/tmp/empty-leftover
mkdir -p .sfs-local/cache
printf 'last_checked_epoch=0\n' > .sfs-local/cache/hygiene-notice.env
mkdir -p .sfs-local/decisions
printf '# Legacy Decision\n\nCold archive me after adopt.\n' > .sfs-local/decisions/0001-legacy.md
printf '# Local auth placeholder\n' > .sfs-local/auth.env
printf '# Local auth example\n' > .sfs-local/auth.env.example
printf '{"ts":"2026-05-09T00:00:00+09:00","type":"sprint_start","sprint_id":"2026-W19-sprint-1"}\n' \
  > .sfs-local/events.jsonl
mkdir -p docs/solon
printf '# Old flat adopt summary\n' > docs/solon/legacy-baseline-adoption-summary.md
printf '# Old flat adopt summary\n' > docs/solon/doc-cleanup-adoption-summary.md

brief="문서 정리좀 해야될거 같은데."
dry_run="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" adopt "${brief}")"
case "${dry_run}" in
  *"adopt dry-run: legacy-baseline"* ) ;;
  *) fail "dry-run did not complete: ${dry_run}" ;;
esac
case "${dry_run}" in
  *"brief: ${brief}"* ) ;;
  *) fail "dry-run did not echo free-form brief: ${dry_run}" ;;
esac
case "${dry_run}" in
  *"active_sprint_before_adopt: 2026-W19-sprint-1"* ) ;;
  *) fail "dry-run did not mark active sprint for reset: ${dry_run}" ;;
esac
case "${dry_run}" in
  *"would_remove_active_sprint_pointer: .sfs-local/current-sprint"* ) ;;
  *) fail "dry-run did not mark active sprint pointer removal: ${dry_run}" ;;
esac
case "${dry_run}" in
  *"preserve_current_sprint"* ) fail "dry-run should not preserve current sprint: ${dry_run}" ;;
esac
case "${dry_run}" in
  *"would_archive_tmp_artifacts: 1"* ) ;;
  *) fail "dry-run did not mark tmp scratch for archive: ${dry_run}" ;;
esac
case "${dry_run}" in
  *"would_archive_event_ledger_lines: 1"* ) ;;
  *) fail "dry-run did not mark event ledger reset: ${dry_run}" ;;
esac
case "${dry_run}" in
  *"would_archive_nonessential_residue:"*".sfs-local/decisions/0001-legacy.md"* ) ;;
  *) fail "dry-run did not mark decision residue for archive: ${dry_run}" ;;
esac
case "${dry_run}" in
  *"would_archive_nonessential_residue:"*".sfs-local/auth.env.example"* ) ;;
  *) fail "dry-run did not mark auth example residue for archive: ${dry_run}" ;;
esac
case "${dry_run}" in
  *"would_archive_nonessential_residue:"*".sfs-local/auth.env"* ) ;;
  *) fail "dry-run did not mark auth env residue for archive: ${dry_run}" ;;
esac
case "${dry_run}" in
  *"would_archive_nonessential_residue:"*".sfs-local/cache/hygiene-notice.env"* ) ;;
  *) fail "dry-run did not mark cache residue for archive: ${dry_run}" ;;
esac
case "${dry_run}" in
  *"would_archive_legacy_flat_shared_doc: 1"* ) ;;
  *) fail "dry-run did not mark legacy flat shared doc for archive: ${dry_run}" ;;
esac

applied="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" adopt --id doc-cleanup --apply "${brief}")"
case "${applied}" in
  *"adopted: doc-cleanup"* ) ;;
  *) fail "apply did not complete: ${applied}" ;;
esac
case "${applied}" in
  *"brief: ${brief}"* ) ;;
  *) fail "apply did not echo free-form brief: ${applied}" ;;
esac

date_dir="$(date +%Y%m%d)"
SHARED_DOC="docs/solon/doc-cleanup/${date_dir}/handoff.md"
[[ -f "${SHARED_DOC}" ]] || fail "missing shared handoff doc: ${SHARED_DOC}"
[[ ! -d ".sfs-local/sprints/doc-cleanup" ]] || fail "adopt should not create a visible sprint workspace"
[[ ! -f ".sfs-local/current-sprint" ]] || fail "adopt should not leave an active sprint pointer"
[[ ! -d ".sfs-local/sprints/2026-W19-sprint-1" ]] || fail "adopt should cold-archive the active legacy sprint"
find .sfs-local/archives/adopt/doc-cleanup -name existing-sprints.tar.gz -type f | grep -q . \
  || fail "missing active legacy sprint cold archive"
[[ ! -e ".sfs-local/tmp" ]] || fail "adopt should cold-archive old tmp scratch"
find .sfs-local/archives/adopt/doc-cleanup -name preexisting-tmp.tar.gz -type f | grep -q . \
  || fail "missing tmp scratch cold archive"
find .sfs-local/archives/adopt/doc-cleanup -name preexisting-events.jsonl -type f | grep -q . \
  || fail "missing previous event ledger backup"
adopt_event_excerpt=".sfs-local/archives/events/sprints/2026-W19-sprint-1.jsonl"
[[ -f "${adopt_event_excerpt}" ]] \
  || fail "adopt should preserve per-sprint event excerpt before resetting active ledger"
grep -Fq "\"type\":\"sprint_start\"" "${adopt_event_excerpt}" \
  || fail "adopt event excerpt should keep raw sprint_start line"
grep -Fq "\"sprint_id\":\"2026-W19-sprint-1\"" "${adopt_event_excerpt}" \
  || fail "adopt event excerpt should be grep-friendly by sprint id"
[[ ! -e ".sfs-local/decisions/0001-legacy.md" ]] || fail "adopt should archive legacy decision residue"
[[ ! -e ".sfs-local/auth.env" ]] || fail "adopt should archive nonessential auth env residue"
[[ ! -e ".sfs-local/auth.env.example" ]] || fail "adopt should archive nonessential auth example residue"
[[ ! -e ".sfs-local/cache" ]] || fail "adopt should remove stale cache residue"
find .sfs-local/archives/adopt/doc-cleanup -name preexisting-residue.tar.gz -type f | grep -q . \
  || fail "missing nonessential residue cold archive"
[[ ! -e docs/solon/doc-cleanup-adoption-summary.md ]] || fail "legacy flat shared doc should be removed"
find .sfs-local/archives/adopt/doc-cleanup -name preexisting-shared-adoption-summary.md -type f | grep -q . \
  || fail "missing legacy flat shared doc archive"
[[ -f ".sfs-local/config.yaml" ]] || fail "runtime config should remain"
[[ -f ".sfs-local/VERSION" ]] || fail "runtime VERSION should remain"
[[ -f ".sfs-local/model-profiles.yaml" ]] || fail "runtime model profiles should remain"
[[ -f ".sfs-local/divisions.yaml" ]] || fail "runtime divisions config should remain"
grep -Fq "goal: \"${brief}\"" "${SHARED_DOC}" || fail "shared doc frontmatter did not store brief as goal"
grep -Fq "${brief}" "${SHARED_DOC}" || fail "shared doc body missing brief"
case "${applied}" in
  *"event_ledger_after_adopt: none"* ) ;;
  *) fail "apply should report no active event ledger after adopt: ${applied}" ;;
esac
[[ ! -e .sfs-local/events.jsonl ]] || fail "adopt should not leave events.jsonl log residue"
source_summary="$(find .sfs-local/archives/adopt/doc-cleanup -name source-summary.txt -type f | sort | tail -1)"
[[ -n "${source_summary}" && -f "${source_summary}" ]] || fail "missing source summary"
grep -Fq "archived_tmp_artifact_count: 1" "${source_summary}" \
  || fail "source summary missing tmp archive count"
grep -Fq "archived_event_ledger_lines: 1" "${source_summary}" \
  || fail "source summary missing event ledger archive count"
grep -Fq "archived_nonessential_residue_count:" "${source_summary}" \
  || fail "source summary missing residue archive count"
grep -Fq "removed_empty_surface_dir_count:" "${source_summary}" \
  || fail "source summary missing empty surface dir cleanup count"
grep -Fq ".sfs-local/decisions/0001-legacy.md" "${source_summary}" \
  || fail "source summary missing decision residue path"

adopt_fail_dir="${TMP_DIR}/adopt-fail-closed"
mkdir -p "${adopt_fail_dir}"
cd "${adopt_fail_dir}"
git init -q
printf '# Adopt Fail Closed Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null
mkdir -p .sfs-local/sprints/2026-W19-fail-closed
printf '# Active Legacy Sprint\n' > .sfs-local/sprints/2026-W19-fail-closed/plan.md
printf '2026-W19-fail-closed\n' > .sfs-local/current-sprint
printf '{"ts":"2026-05-09T00:00:00+09:00","type":"sprint_start","sprint_id":"2026-W19-fail-closed"}\n' \
  > .sfs-local/events.jsonl
mkdir -p .sfs-local/archives
printf 'not a directory\n' > .sfs-local/archives/events
set +e
SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" adopt --id fail-closed --apply "fail closed" >/dev/null 2>adopt-fail.err
adopt_fail_rc=$?
set -e
[[ "${adopt_fail_rc}" -ne 0 ]] || fail "adopt should fail closed when event excerpt archive path cannot be written"
[[ -f .sfs-local/current-sprint ]] || fail "adopt preservation failure should keep current-sprint pointer"
[[ -d .sfs-local/sprints/2026-W19-fail-closed ]] \
  || fail "adopt preservation failure should not collapse legacy sprint before event preservation"
grep -Fq "\"sprint_id\":\"2026-W19-fail-closed\"" .sfs-local/events.jsonl \
  || fail "adopt preservation failure should leave preexisting event ledger intact"

echo "test-sfs-adopt-freeform: OK"
