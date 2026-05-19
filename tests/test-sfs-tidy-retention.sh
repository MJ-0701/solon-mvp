#!/usr/bin/env bash
# tests/test-sfs-tidy-retention.sh — tidy removes residue without a one-line keep reason.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-tidy-retention.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1" needle="$2" label="$3"
  case "${haystack}" in
    *"${needle}"*) ;;
    *) fail "${label}: missing ${needle} in: ${haystack}" ;;
  esac
}

cd "${TMP_DIR}"
git init -q
printf '# Tidy Retention Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null

sprint_id="2026-W19-sprint-done"
sprint_dir=".sfs-local/sprints/${sprint_id}"
shared_report="docs/solon/retention/$(date +%Y%m%d)/report.md"
flat_shared_dir="docs/solon/order-items-quantity-update/$(date +%Y%m%d)"
domain_shared_dir="docs/solon/order/order-items/quantity-update/$(date +%Y%m%d)"
mkdir -p "${sprint_dir}" .sfs-local/queue/pending .sfs-local/decisions
mkdir -p "${flat_shared_dir}"
touch .sfs-local/sprints/.gitkeep
touch .sfs-local/queue/pending/.gitkeep
touch .sfs-local/decisions/.gitkeep
printf '# Flat Report\n' > "${flat_shared_dir}/report.md"
printf '# Flat Retro\n' > "${flat_shared_dir}/retro.md"
printf 'missing-sprint\n' > .sfs-local/current-sprint
printf '# Brainstorm\n\nraw notes\n' > "${sprint_dir}/brainstorm.md"
printf '# Review\n\nraw review\n' > "${sprint_dir}/review.md"
printf '{"ts":"2026-05-09T00:00:00+09:00","type":"sprint_start","sprint_id":"%s","goal":"retention"}\n' "${sprint_id}" > .sfs-local/events.jsonl
printf '{"ts":"2026-05-09T00:01:00+09:00","type":"review_open","sprint_id":"%s"}\n' "${sprint_id}" >> .sfs-local/events.jsonl
printf '{"ts":"2026-05-09T00:02:00+09:00","type":"legacy_probe"}\n' >> .sfs-local/events.jsonl

dry_run="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" tidy --all)"
assert_contains "${dry_run}" "rule: keep only files with a one-line keep reason" "dry-run retention rule"
assert_contains "${dry_run}" "events: 3 line(s) would prune" "dry-run event pruning"
assert_contains "${dry_run}" "shared_docs: 1 flat handoff dir(s) would rehome" "dry-run shared docs rehome"

apply_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" tidy --all --apply)"
assert_contains "${apply_out}" "retention:" "apply retention summary"
assert_contains "${apply_out}" "events: 3 historical line(s) pruned" "apply event pruning"
assert_contains "${apply_out}" "residue:" "apply residue summary"
assert_contains "${apply_out}" "surface_cleanup: 1 run dir(s) consolidated by date" "apply surface cleanup consolidation"
assert_contains "${apply_out}" "shared_docs: 1 flat handoff dir(s) rehomed; 0 skipped" "apply shared docs rehome"

[[ -f "${shared_report}" ]] || fail "shared report.md should remain as durable sprint outcome"
[[ -f "${domain_shared_dir}/report.md" ]] || fail "flat report should move to domain shared dir"
[[ -f "${domain_shared_dir}/retro.md" ]] || fail "flat retro should move to domain shared dir"
[[ ! -d docs/solon/order-items-quantity-update ]] || fail "flat shared workspace dir should be removed"
[[ ! -e "${sprint_dir}/report.md" ]] || fail "private sprint report.md should not remain"
[[ ! -e "${sprint_dir}/brainstorm.md" ]] || fail "brainstorm.md should be removed from visible sprint folder"
[[ ! -e "${sprint_dir}/review.md" ]] || fail "review.md should be removed from visible sprint folder"
[[ ! -e .sfs-local/events.jsonl ]] || fail "events.jsonl should be deleted when no active-state lines remain"
[[ ! -e .sfs-local/current-sprint ]] || fail "broken current-sprint pointer should be removed"
[[ ! -e .sfs-local/sprints/.gitkeep ]] || fail "sprints .gitkeep residue should be removed"
[[ ! -d .sfs-local/queue ]] || fail "empty queue placeholder tree should be removed"
[[ ! -d .sfs-local/decisions ]] || fail "empty decisions placeholder dir should be removed"

[[ ! -d .sfs-local/archives/sprints ]] || fail "sprint archive bucket should be collapsed under archives/adopt"
surface_bundle="$(find ".sfs-local/archives/adopt/surface-cleanup" -mindepth 2 -maxdepth 2 -name surface-cleanup.tar.gz -type f 2>/dev/null | head -1)"
[[ -n "${surface_bundle}" ]] || fail "missing daily surface cleanup bundle"
extract_dir="${TMP_DIR}/surface-extract"
mkdir -p "${extract_dir}"
tar -xzf "${surface_bundle}" -C "${extract_dir}"
archive_file="$(find "${extract_dir}" -name preexisting-archives.tar.gz -type f 2>/dev/null | head -1)"
[[ -n "${archive_file}" ]] || fail "missing collapsed sprint cold archive"
tar -tzf "${archive_file}" | grep -Fq "sprints/${sprint_id}/" \
  || fail "collapsed archive missing sprint archive bucket"
tar -tzf "${archive_file}" | grep -Fq "sprint-evidence.tar.gz" \
  || fail "collapsed archive missing sprint evidence tarball"
tar -tzf "${archive_file}" | grep -Fq "manifest.txt" \
  || fail "collapsed archive missing sprint manifest"

echo "test-sfs-tidy-retention: OK"
