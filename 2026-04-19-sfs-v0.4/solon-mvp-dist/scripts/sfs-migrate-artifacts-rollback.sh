#!/usr/bin/env bash
# sfs-migrate-artifacts-rollback.sh — git revert + Layer 1 atomic rollback helper.
#
# sfs-migrate-artifacts.sh --rollback <sha> 의 backend.
# git revert + Layer 1 (docs/) file movements 를 transactional 보장.
# partial commit / interrupted mid-way 시 working tree 자동 복구.
#
# Usage:
#   sfs-migrate-artifacts-rollback.sh --commit-sha <sha> [--snapshot-iso <ISO>] [--root <r>]
#   sfs-migrate-artifacts-rollback.sh --from-snapshot <ISO> [--root <r>]
#
# Exit codes:
#   0  = OK (working tree restored)
#   1  = generic error (working tree dirty 등)
#   2  = invalid arg
#   3  = rollback fail (snapshot missing or git revert conflict)
#
# AC reference: AC3.6 (rollback git revert + atomic), AC10.4 (rollback-from-snapshot),
#               AC10.5 (interrupted-midway recovery), AC2.9 (atomic Layer 1 movement).

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
  cat <<'EOF'
sfs-migrate-artifacts-rollback — git revert + Layer 1 atomic rollback helper

Usage:
  sfs-migrate-artifacts-rollback.sh --commit-sha <sha> [--snapshot-iso <ISO>] [--root <r>]
  sfs-migrate-artifacts-rollback.sh --from-snapshot <ISO> [--root <r>]

Modes:
  --commit-sha <sha>             git revert <sha> + Layer 1 atomic rollback
  --from-snapshot <ISO>          pre-migrate snapshot (.sfs-local/archives/pre-migrate-<ISO>/) restore

Atomic safety:
  - working tree dirty detect → exit 1 with stash 권장 message
  - git revert conflict → restore from snapshot (있을 때) → exit 3 if snapshot missing
  - SIGINT/SIGTERM → restore from snapshot → exit 4
EOF
}

mode=""
commit_sha=""
snapshot_iso=""
repo_root=""

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
    --root)
      repo_root="${2:-}"
      shift 2 || { echo "${SCRIPT_NAME}: --root requires <path>" >&2; exit 2; }
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

if [[ -z "${repo_root}" ]]; then
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
[[ -d "${repo_root}" ]] || { echo "${SCRIPT_NAME}: repo_root not a directory: ${repo_root}" >&2; exit 1; }
cd "${repo_root}"

# working tree dirty detect (working tree must be clean for atomic rollback).
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
    echo "${SCRIPT_NAME}: working tree dirty — git stash 또는 commit 후 재실행" >&2
    exit 1
  fi
fi

# SIGINT/SIGTERM trap: restore from snapshot if specified.
SNAPSHOT_DIR_FOR_INT=""
on_interrupt() {
  echo "${SCRIPT_NAME}: SIGINT/SIGTERM received — atomic snapshot restore" >&2
  if [[ -n "${SNAPSHOT_DIR_FOR_INT}" ]] && [[ -d "${SNAPSHOT_DIR_FOR_INT}/files" ]]; then
    cp -a "${SNAPSHOT_DIR_FOR_INT}/files/." "${repo_root}/"
  fi
  exit 4
}
trap 'on_interrupt' INT TERM

restore_from_snapshot_dir() {
  local sd="$1"
  if [[ ! -d "${sd}" ]]; then
    echo "${SCRIPT_NAME}: snapshot dir not found: ${sd}" >&2
    return 3
  fi
  local manifest="${sd}/manifest.json"
  if [[ ! -f "${manifest}" ]]; then
    echo "${SCRIPT_NAME}: snapshot manifest not found: ${manifest}" >&2
    return 3
  fi
  if [[ ! -d "${sd}/files" ]]; then
    echo "${SCRIPT_NAME}: snapshot files/ not found: ${sd}/files" >&2
    return 3
  fi
  cp -a "${sd}/files/." "${repo_root}/"
  printf 'sfs-migrate-artifacts-rollback: restored from %s (manifest: %s)\n' "${sd}" "${manifest}"
}

case "${mode}" in
  commit)
    # Locate snapshot if --snapshot-iso provided.
    if [[ -n "${snapshot_iso}" ]]; then
      SNAPSHOT_DIR_FOR_INT=".sfs-local/archives/pre-migrate-${snapshot_iso}"
    fi
    # git revert (no-edit) the migrate commit.
    if ! git revert --no-edit "${commit_sha}" 2>&1; then
      echo "${SCRIPT_NAME}: git revert ${commit_sha} failed" >&2
      git revert --abort 2>/dev/null || true
      if [[ -n "${SNAPSHOT_DIR_FOR_INT}" ]] && [[ -d "${SNAPSHOT_DIR_FOR_INT}" ]]; then
        echo "${SCRIPT_NAME}: attempting snapshot restore" >&2
        if restore_from_snapshot_dir "${SNAPSHOT_DIR_FOR_INT}"; then
          exit 0
        fi
      fi
      exit 3
    fi
    printf 'sfs-migrate-artifacts-rollback: git revert %s OK\n' "${commit_sha}"
    ;;

  snapshot)
    snapshot_dir=".sfs-local/archives/pre-migrate-${snapshot_iso}"
    SNAPSHOT_DIR_FOR_INT="${snapshot_dir}"
    restore_from_snapshot_dir "${snapshot_dir}" || exit 3
    ;;
esac
exit 0
