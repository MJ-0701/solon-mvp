#!/usr/bin/env bash
# sfs-archive-branch-sync.sh — closed sprint archive branch 자동 sync.
#
# closed sprint dir 들을 main 에서 archive branch 로 이동 (main 은 진행 중 + 신규 sprint 만 보존).
# race 보호: flock(1) 또는 advisory file lock — 동시 실행 second process 는 graceful exit (no-op).
#
# Usage:
#   sfs archive-branch-sync [--dry-run] [--lock <path>] [--branch <name>]
#
# Exit codes:
#   0  = OK (sync 완료 or already up-to-date or lock-held graceful exit)
#   1  = generic error
#   2  = invalid arg
#   3  = lock acquire timeout
#
# AC reference: AC2.7 (race 보호 flock or advisory file lock).
# Implementation: chunk 1 = skeleton + arg parse + flock wrap. 실 git branch + mv logic = 다음 chunk (R-B B-7).

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
  cat <<'EOF'
sfs-archive-branch-sync — closed sprint archive branch sync

Usage:
  sfs archive-branch-sync [--dry-run] [--lock <path>] [--branch <name>]

Options:
  --dry-run         실 git 변경 없이 plan 출력
  --lock <path>     advisory lock file path (default: .sfs-local/.archive-sync.lock)
  --branch <name>   archive branch 이름 (default: archive)
EOF
}

dry_run=0
lock_file=".sfs-local/.archive-sync.lock"
archive_branch="archive"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help|help)
      usage
      exit 0
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    --lock)
      lock_file="${2:-}"
      shift 2 || { echo "missing value for --lock" >&2; exit 2; }
      ;;
    --branch)
      archive_branch="${2:-}"
      shift 2 || { echo "missing value for --branch" >&2; exit 2; }
      ;;
    *)
      echo "${SCRIPT_NAME}: unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

mkdir -p "$(dirname "${lock_file}")"

# race 보호: flock(1) 사용 가능하면 우선, 부재 시 advisory file lock fallback.
acquire_lock() {
  if command -v flock >/dev/null 2>&1; then
    exec 9>"${lock_file}"
    if ! flock -n 9; then
      printf 'sfs-archive-branch-sync: another process holds flock(%s) — graceful exit\n' "${lock_file}" >&2
      exit 0   # AC2.7 second process graceful exit no-op
    fi
    return 0
  fi
  # advisory fallback (fcntl-less env: macOS BSD flock 부재 시)
  if [[ -e "${lock_file}" ]]; then
    pid="$(cat "${lock_file}" 2>/dev/null || echo 0)"
    if [[ "${pid}" =~ ^[0-9]+$ ]] && kill -0 "${pid}" 2>/dev/null; then
      printf 'sfs-archive-branch-sync: advisory lock held by pid %s — graceful exit\n' "${pid}" >&2
      exit 0
    fi
  fi
  echo "$$" > "${lock_file}"
  trap 'rm -f "${lock_file}"' EXIT
}

acquire_lock

# TODO chunk N (R-B B-7):
#   1. git rev-parse 로 archive branch 존재 확인 → 없으면 git branch ${archive_branch} 생성.
#   2. closed sprint detect (sprint.yml status=closed iter).
#   3. dry_run=0: git checkout archive → mv closed sprint dir → commit, git checkout main → rm closed sprint dir → commit.
#   4. atomic safety: pre-mv snapshot + post-fail rollback.

if [[ "${dry_run}" == "1" ]]; then
  printf 'sfs-archive-branch-sync: dry-run — would sync closed sprints to branch %s\n' "${archive_branch}"
  exit 0
fi

printf 'sfs-archive-branch-sync: placeholder — chunk N R-B B-7 logic 미구현\n'
exit 0
