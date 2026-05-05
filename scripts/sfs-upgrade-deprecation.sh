#!/usr/bin/env bash
# sfs-upgrade-deprecation.sh — 0.5.x consumer deprecation warning + opt-in 0.6-storage migrate.
#
# Called by bin/sfs upgrade_command (R-E AC5.1~AC5.4 implementation).
# Detects consumer project version from .sfs-local/VERSION and applies deprecation logic:
#   - 0.6.x consumer  → silent (AC5.3)
#   - 0.5.x consumer pre-grace (before 2026-11-03)  → deprecation warning (AC5.1)
#                       --opt-in 0.6-storage flag  → backfill execute (AC5.2)
#   - 0.5.x consumer post-grace (>= 2026-11-03) → default forced migrate (AC5.4)
#                       --commit opt-in / no-flag prompt
#                       dirty WT + no --commit → exit non-zero
#                       commit idempotence (AC5.4.1) — re-run on clean tree → exit 0 no empty commit
#
# Usage:
#   sfs-upgrade-deprecation.sh [--opt-in 0.6-storage] [--commit] [--root <r>] [--force-cut-date YYYY-MM-DD]
#
# Exit codes:
#   0  = OK (silent / warn-only / migrate done)
#   1  = error (dirty WT no --commit, etc.)
#   2  = invalid arg
#
# AC reference: AC5.1, AC5.2, AC5.3, AC5.4, AC5.4.1.

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

HARD_CUT_DATE="2026-11-03"
DEPRECATION_WORDING_PREFIX="sfs deprecation:"

usage() {
  cat <<'EOF'
sfs-upgrade-deprecation — 0.5.x consumer deprecation + opt-in 0.6-storage

Usage:
  sfs-upgrade-deprecation.sh [--opt-in 0.6-storage] [--commit] [--root <r>] [--force-cut-date YYYY-MM-DD]

Modes (auto-detected from .sfs-local/VERSION):
  0.6.x consumer            silent (no warning, no migrate)
  0.5.x consumer pre-grace  deprecation warning printed to stderr
                            --opt-in 0.6-storage  → run sfs-migrate-artifacts --backfill-legacy
  0.5.x consumer post-grace default forced migrate
                            --commit              → migrate + auto git commit
                            (no flag)             → migrate + prompt commit y/N

Hard-cut date: 2026-11-03 (override with --force-cut-date for testing).
EOF
}

opt_in=""
do_commit=0
repo_root=""
force_cut_date=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help|help) usage; exit 0 ;;
    --opt-in)
      opt_in="${2:-}"
      shift 2 || { echo "${SCRIPT_NAME}: --opt-in requires value" >&2; exit 2; }
      ;;
    --commit) do_commit=1; shift ;;
    --root)
      repo_root="${2:-}"
      shift 2 || { echo "${SCRIPT_NAME}: --root requires <path>" >&2; exit 2; }
      ;;
    --force-cut-date)
      force_cut_date="${2:-}"
      shift 2 || { echo "${SCRIPT_NAME}: --force-cut-date requires YYYY-MM-DD" >&2; exit 2; }
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

# Detect consumer version.
version_file=".sfs-local/VERSION"
if [[ ! -f "${version_file}" ]]; then
  printf '%s no .sfs-local/VERSION found — not a Solon project, skipping deprecation check.\n' "${SCRIPT_NAME}" >&2
  exit 0
fi

consumer_ver="$(awk '/^solon_mvp_version:/ {print $2; exit}' "${version_file}" 2>/dev/null | tr -d '"' || true)"
if [[ -z "${consumer_ver}" ]]; then
  exit 0
fi

# Strip suffix to get base semver.
case "${consumer_ver}" in
  *-product) base="${consumer_ver%-product}" ;;
  *-mvp) base="${consumer_ver%-mvp}" ;;
  *) base="${consumer_ver}" ;;
esac

IFS=. read -r major minor _patch <<< "${base}"
if ! [[ "${major}" =~ ^[0-9]+$ ]] || ! [[ "${minor}" =~ ^[0-9]+$ ]]; then
  exit 0
fi

# AC5.3: 0.6.x or higher → silent.
if (( major > 0 )) || (( major == 0 && minor >= 6 )); then
  exit 0
fi

# 0.5.x consumer detected.
today="$(date -u +%Y-%m-%d)"
[[ -n "${force_cut_date}" ]] && cut="${force_cut_date}" || cut="${HARD_CUT_DATE}"

post_grace=0
if [[ "${today}" > "${cut}" || "${today}" == "${cut}" ]]; then
  post_grace=1
fi

# AC5.1: deprecation warning (always for 0.5.x).
{
  printf '%s consumer %s detected. 0.6.0 storage schema is now the default.\n' \
    "${DEPRECATION_WORDING_PREFIX}" "${consumer_ver}"
  printf '  hard cut: %s (current: %s)\n' "${cut}" "${today}"
  if [[ "${post_grace}" == "0" ]]; then
    printf '  to migrate now: sfs upgrade --opt-in 0.6-storage\n'
  fi
} >&2

if [[ "${post_grace}" == "0" ]]; then
  # Pre-grace: opt-in only.
  if [[ "${opt_in}" == "0.6-storage" ]]; then
    printf '%s opt-in 0.6-storage → invoking sfs-migrate-artifacts --backfill-legacy\n' "${SCRIPT_NAME}" >&2
    "${SCRIPT_DIR}/sfs-migrate-artifacts.sh" --backfill-legacy --root "${repo_root}"
  fi
  exit 0
fi

# AC5.4: post-grace forced migrate.
printf '%s POST-GRACE forced migrate (>= %s).\n' "${SCRIPT_NAME}" "${cut}" >&2

# AC5.4 dirty WT detect — exit non-zero unless --commit.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if [[ -n "$(git status --porcelain 2>/dev/null)" ]] && [[ "${do_commit}" == "0" ]]; then
    {
      printf '%s ERROR: working tree dirty.\n' "${SCRIPT_NAME}"
      printf '  Stash or commit your changes before forced migrate, OR re-run with --commit to auto-commit.\n'
    } >&2
    exit 1
  fi
fi

# AC5.4.1 idempotence guard — if no migrate work to do, exit 0 no empty commit.
prior_head=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  prior_head="$(git rev-parse HEAD 2>/dev/null || echo)"
fi

migrate_script="${SCRIPT_DIR}/sfs-migrate-artifacts.sh"
if [[ ! -x "${migrate_script}" ]]; then
  echo "${SCRIPT_NAME}: migrate script missing: ${migrate_script}" >&2
  exit 1
fi

# Check if any 0.5.x sprint left to convert (idempotence guard).
work_to_do=0
for d in .sfs-local/sprints sprints; do
  [[ -d "${d}" ]] || continue
  while IFS= read -r legacy_dir; do
    sid="${legacy_dir##*/}"
    case "${sid}" in 0-5-*) work_to_do=$((work_to_do + 1)) ;; esac
  done < <(find "${d}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null || true)
done

if [[ "${work_to_do}" -eq 0 ]]; then
  printf '%s no 0.5.x sprints to migrate — idempotent no-op (AC5.4.1).\n' "${SCRIPT_NAME}" >&2
  exit 0
fi

# Run migration.
"${migrate_script}" --backfill-legacy --root "${repo_root}"

# Commit handling.
post_dirty=0
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
    post_dirty=1
  fi
fi

if [[ "${post_dirty}" == "0" ]]; then
  printf '%s migration produced no working-tree changes — idempotent (AC5.4.1).\n' "${SCRIPT_NAME}" >&2
  exit 0
fi

if [[ "${do_commit}" == "1" ]]; then
  git add -A
  if git diff --cached --quiet 2>/dev/null; then
    printf '%s no staged changes after add — idempotent (AC5.4.1).\n' "${SCRIPT_NAME}" >&2
    exit 0
  fi
  git commit -q -m "migrate(forced): hard cut ${cut}"
  new_head="$(git rev-parse HEAD 2>/dev/null || echo)"
  if [[ -n "${prior_head}" ]] && [[ "${prior_head}" == "${new_head}" ]]; then
    printf '%s commit idempotence guard active — no new commit (AC5.4.1).\n' "${SCRIPT_NAME}" >&2
  else
    printf '%s migrated + committed (HEAD: %s).\n' "${SCRIPT_NAME}" "${new_head:0:8}" >&2
  fi
else
  printf '%s migration applied to working tree.\n' "${SCRIPT_NAME}" >&2
  printf 'Commit migration now? [y/N]: '
  if read -r -t 60 ans 2>/dev/null && [[ "${ans}" =~ ^[Yy]$ ]]; then
    git add -A
    git commit -q -m "migrate(forced): hard cut ${cut}"
    printf '%s committed.\n' "${SCRIPT_NAME}" >&2
  else
    printf '%s migration left in working tree — manual git add + commit recommended.\n' "${SCRIPT_NAME}" >&2
  fi
fi

exit 0
