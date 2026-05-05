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

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
  cat <<'EOF'
sfs-archive-branch-sync — closed sprint archive branch sync

Usage:
  sfs archive-branch-sync [--dry-run] [--lock <path>] [--branch <name>] [--root <repo-root>]

Options:
  --dry-run         실 git 변경 없이 plan 출력
  --lock <path>     advisory lock file path (default: .sfs-local/.archive-sync.lock)
  --branch <name>   archive branch 이름 (default: archive)
  --root <r>        repo root (default: git rev-parse --show-toplevel)

Race protection (AC2.7):
  flock(1) 우선 사용. 부재 시 advisory PID lock fallback.
  second process = lock detect 후 graceful exit (no-op, exit 0).
EOF
}

dry_run=0
lock_file=""
archive_branch="archive"
repo_root=""

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
    --root)
      repo_root="${2:-}"
      shift 2 || { echo "missing value for --root" >&2; exit 2; }
      ;;
    *)
      echo "${SCRIPT_NAME}: unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "${repo_root}" ]]; then
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
cd "${repo_root}"

if [[ -z "${lock_file}" ]]; then
  lock_file=".sfs-local/.archive-sync.lock"
fi
mkdir -p "$(dirname "${lock_file}")"

# race 보호: flock(1) 사용 가능하면 우선, 부재 시 advisory PID lock fallback.
acquire_lock() {
  if command -v flock >/dev/null 2>&1; then
    exec 9>"${lock_file}"
    if ! flock -n 9; then
      printf 'sfs-archive-branch-sync: another process holds flock(%s) — graceful exit\n' "${lock_file}" >&2
      exit 0   # AC2.7 second process graceful exit no-op
    fi
    # flock holds via fd 9 until process exits.
    return 0
  fi
  # advisory PID-based fallback (macOS BSD flock-only env, etc).
  if [[ -e "${lock_file}" ]]; then
    pid="$(cat "${lock_file}" 2>/dev/null || echo 0)"
    if [[ "${pid}" =~ ^[0-9]+$ ]] && [[ "${pid}" -gt 0 ]] && kill -0 "${pid}" 2>/dev/null; then
      printf 'sfs-archive-branch-sync: advisory lock held by pid %s — graceful exit\n' "${pid}" >&2
      exit 0
    fi
  fi
  echo "$$" > "${lock_file}"
  trap 'rm -f "${lock_file}"' EXIT
}

acquire_lock

# Detect closed sprints (sprint.yml status=closed).
closed_sprints=()
if [[ -d ".solon/sprints" ]]; then
  while IFS= read -r sprint_dir; do
    yml="${sprint_dir}/sprint.yml"
    if [[ -f "${yml}" ]]; then
      status="$(awk '/^status:/ {print $2; exit}' "${yml}" 2>/dev/null | tr -d '"' || true)"
      if [[ "${status}" == "closed" ]]; then
        closed_sprints+=("${sprint_dir}")
      fi
    fi
  done < <(find .solon/sprints -mindepth 1 -maxdepth 1 -type d 2>/dev/null || true)
fi

if [[ "${#closed_sprints[@]}" -eq 0 ]]; then
  printf 'sfs-archive-branch-sync: no closed sprints to sync (mode=%s)\n' \
    "$([[ "${dry_run}" == 1 ]] && echo dry-run || echo apply)"
  exit 0
fi

if [[ "${dry_run}" == "1" ]]; then
  printf 'sfs-archive-branch-sync: dry-run — would move %d closed sprint(s) to branch %s:\n' \
    "${#closed_sprints[@]}" "${archive_branch}"
  for s in "${closed_sprints[@]}"; do
    printf '  - %s\n' "${s}"
  done
  exit 0
fi

# Safety pre-check: clean working tree required (atomic mv 보호).
if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
  echo "${SCRIPT_NAME}: working tree dirty — stash or commit before archive sync" >&2
  exit 1
fi

current_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
if [[ "${current_branch}" == "unknown" || "${current_branch}" == "HEAD" ]]; then
  echo "${SCRIPT_NAME}: cannot detect current branch (detached HEAD?)" >&2
  exit 1
fi

# Ensure archive branch exists.
if ! git show-ref --verify --quiet "refs/heads/${archive_branch}"; then
  printf 'sfs-archive-branch-sync: creating archive branch %s\n' "${archive_branch}"
  git branch "${archive_branch}" >/dev/null
fi

# Pre-mv snapshot for atomic safety.
ts="$(date -u +%Y%m%dT%H%M%SZ)"
snapshot_dir=".sfs-local/archives/archive-sync-${ts}"
mkdir -p "${snapshot_dir}"
for sprint_dir in "${closed_sprints[@]}"; do
  rel="${sprint_dir#./}"
  mkdir -p "${snapshot_dir}/$(dirname "${rel}")"
  cp -a "${sprint_dir}" "${snapshot_dir}/${rel}"
done
printf '%s\n' "${closed_sprints[@]}" > "${snapshot_dir}/_manifest.txt"

# Phase 1: Add to archive branch.
git checkout -q "${archive_branch}"
moved=0
for sprint_dir in "${closed_sprints[@]}"; do
  if [[ -d "${sprint_dir}" ]]; then
    moved=$((moved + 1))
  else
    # Recreate from snapshot if missing on archive branch.
    rel="${sprint_dir#./}"
    src="${snapshot_dir}/${rel}"
    if [[ -d "${src}" ]]; then
      mkdir -p "$(dirname "${sprint_dir}")"
      cp -a "${src}" "${sprint_dir}"
      git add "${sprint_dir}" >/dev/null
      moved=$((moved + 1))
    fi
  fi
done
if [[ "${moved}" -gt 0 ]] && [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
  git commit -q -m "archive-sync: ${moved} closed sprint(s) (${ts})"
fi

# Phase 2: Remove from origin branch.
git checkout -q "${current_branch}"
removed=0
for sprint_dir in "${closed_sprints[@]}"; do
  if [[ -d "${sprint_dir}" ]]; then
    git rm -rq "${sprint_dir}"
    removed=$((removed + 1))
  fi
done
if [[ "${removed}" -gt 0 ]] && [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
  git commit -q -m "archive-sync: prune ${removed} closed sprint(s) moved to ${archive_branch} (${ts})"
fi

printf 'sfs-archive-branch-sync: synced %d closed sprint(s) → %s, snapshot=%s\n' \
  "${moved}" "${archive_branch}" "${snapshot_dir}"
exit 0
