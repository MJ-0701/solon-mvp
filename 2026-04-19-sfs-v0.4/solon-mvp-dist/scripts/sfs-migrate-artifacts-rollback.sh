#!/usr/bin/env bash
# sfs-migrate-artifacts-rollback.sh — git revert + Layer 1 atomic rollback helper.
#
# sfs-migrate-artifacts.sh --rollback <sha> 의 backend.
# git revert + Layer 1 (docs/) file movements 를 transactional 보장.
# partial commit / interrupted mid-way 시 working tree 자동 복구.
#
# Usage:
#   sfs-migrate-artifacts-rollback.sh --commit-sha <sha> [--snapshot-iso <ISO>]
#   sfs-migrate-artifacts-rollback.sh --from-snapshot <ISO>
#
# Exit codes:
#   0  = OK (working tree restored)
#   1  = generic error (working tree dirty 등)
#   2  = invalid arg
#   3  = rollback fail (snapshot missing or git revert conflict)
#
# AC reference: AC3.6 (rollback git revert + atomic), AC10.4 (rollback-from-snapshot), AC10.5 (interrupted-midway recovery), AC2.9 (atomic Layer 1 movement).
# Implementation: chunk 1 = skeleton + arg parse + git revert wrap. 실 atomic rollback + snapshot restore = 다음 chunk (R-H H-3, H-5).

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
  cat <<'EOF'
sfs-migrate-artifacts-rollback — git revert + Layer 1 atomic rollback helper

Usage:
  sfs-migrate-artifacts-rollback.sh --commit-sha <sha> [--snapshot-iso <ISO>]
  sfs-migrate-artifacts-rollback.sh --from-snapshot <ISO>

Modes:
  --commit-sha <sha>             git revert <sha> + Layer 1 atomic rollback
  --from-snapshot <ISO>          pre-migrate snapshot (.sfs-local/archives/pre-migrate-<ISO>/) 으로 restore

Atomic safety:
  - working tree dirty detect → exit 1 with stash 권장 message
  - git revert conflict → restore from snapshot (있을 때) → exit 3 if snapshot missing
  - SIGINT/SIGTERM → restore from snapshot → exit 4
EOF
}

mode=""
commit_sha=""
snapshot_iso=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help|help)
      usage
      exit 0
      ;;
    --commit-sha)
      mode="commit"
      commit_sha="${2:-}"
      shift 2 || { echo "${SCRIPT_NAME}: --commit-sha requires <sha>" >&2; exit 2; }
      ;;
    --from-snapshot)
      mode="snapshot"
      snapshot_iso="${2:-}"
      shift 2 || { echo "${SCRIPT_NAME}: --from-snapshot requires <ISO>" >&2; exit 2; }
      ;;
    --snapshot-iso)
      snapshot_iso="${2:-}"
      shift 2 || { echo "${SCRIPT_NAME}: --snapshot-iso requires <ISO>" >&2; exit 2; }
      ;;
    *)
      echo "${SCRIPT_NAME}: unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "${mode}" ]]; then
  echo "${SCRIPT_NAME}: --commit-sha 또는 --from-snapshot 필요" >&2
  usage >&2
  exit 2
fi

# working tree dirty detect
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
    echo "${SCRIPT_NAME}: working tree dirty — git stash 또는 commit 후 재실행" >&2
    exit 1
  fi
fi

# SIGINT/SIGTERM trap
on_interrupt() {
  echo "${SCRIPT_NAME}: SIGINT/SIGTERM received — restore from snapshot (placeholder, chunk N R-H H-5)" >&2
  exit 4
}
trap 'on_interrupt' INT TERM

case "${mode}" in
  commit)
    # TODO chunk N (R-C C-6):
    #   1. git revert ${commit_sha} (--no-edit 권장 default)
    #   2. revert conflict 시 snapshot_iso 있으면 snapshot restore + exit 0
    #   3. snapshot 없고 conflict 시 git revert --abort + exit 3
    printf 'sfs-migrate-artifacts-rollback: --commit-sha=%s placeholder (chunk N R-C C-6)\n' "${commit_sha}"
    ;;
  snapshot)
    snapshot_dir=".sfs-local/archives/pre-migrate-${snapshot_iso}"
    if [[ ! -d "${snapshot_dir}" ]]; then
      echo "${SCRIPT_NAME}: snapshot dir not found: ${snapshot_dir}" >&2
      exit 3
    fi
    # TODO chunk N (R-H H-3):
    #   1. snapshot manifest.json read (9 required fields)
    #   2. files[] iterate → 원래 path 로 restore + sha256 verify
    #   3. skipped[] 는 무시 (extension filter 거부 file)
    #   4. anti-AC10 verify (file count + sha256 sum 정합)
    printf 'sfs-migrate-artifacts-rollback: --from-snapshot=%s placeholder (chunk N R-H H-3)\n' "${snapshot_iso}"
    ;;
esac
exit 0
