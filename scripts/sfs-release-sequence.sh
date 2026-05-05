#!/usr/bin/env bash
# sfs-release-sequence.sh — AC11 release sequence enforcement.
#
# Phases (must run in order):
#   1. tag-push     git tag v<version> + push to origin
#   2. audit        brew audit (AC7.4) + scoop schema check (AC7.5)
#   3. tap-update   tap repo formula/manifest update + push (Homebrew + Scoop bucket)
#
# Out-of-order invocation exits non-zero.
# Phase markers are written to .sfs-local/release-state/<version>/ for cross-script consumption.

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
  cat <<'EOF'
sfs-release-sequence — AC11 release sequence enforcement

Usage:
  sfs-release-sequence.sh --phase <tag-push|audit|tap-update> --version <X.Y.Z>
                          [--dry-run] [--state-dir <path>]

Phases (must run in order):
  1. tag-push     git tag v<version> + push to origin
  2. audit        brew audit + scoop schema check
  3. tap-update   tap repo update + push

Phase markers persist in .sfs-local/release-state/<version>/ (no-cleanup default).
EOF
}

phase=""
version=""
dry_run=0
state_dir=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help|help) usage; exit 0 ;;
    --phase)
      phase="${2:-}"
      shift 2 || { echo "${SCRIPT_NAME}: --phase requires value" >&2; exit 2; }
      ;;
    --version)
      version="${2:-}"
      shift 2 || { echo "${SCRIPT_NAME}: --version requires X.Y.Z" >&2; exit 2; }
      ;;
    --dry-run) dry_run=1; shift ;;
    --state-dir)
      state_dir="${2:-}"
      shift 2 || { echo "${SCRIPT_NAME}: --state-dir requires <path>" >&2; exit 2; }
      ;;
    *)
      echo "${SCRIPT_NAME}: unknown arg: $1" >&2
      usage >&2; exit 2 ;;
  esac
done

[[ -n "${phase}" && -n "${version}" ]] || { usage >&2; exit 2; }
case "${phase}" in
  tag-push|audit|tap-update) ;;
  *) echo "${SCRIPT_NAME}: unknown phase: ${phase}" >&2; exit 2 ;;
esac

if [[ -z "${state_dir}" ]]; then
  state_dir=".sfs-local/release-state/${version}"
fi
mkdir -p "${state_dir}"

phase_done() {
  [[ -f "${state_dir}/${1}.done" ]]
}
mark_phase() {
  printf '%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "${state_dir}/${1}.done"
}

# Order enforcement.
case "${phase}" in
  tag-push)
    : # always allowed first
    ;;
  audit)
    if ! phase_done tag-push; then
      echo "${SCRIPT_NAME}: AC11 ORDER FAIL — phase=audit requires tag-push first (state: ${state_dir})" >&2
      exit 1
    fi
    ;;
  tap-update)
    if ! phase_done tag-push || ! phase_done audit; then
      echo "${SCRIPT_NAME}: AC11 ORDER FAIL — phase=tap-update requires tag-push + audit (state: ${state_dir})" >&2
      exit 1
    fi
    ;;
esac

case "${phase}" in
  tag-push)
    if [[ "${dry_run}" == "1" ]]; then
      printf '[dry-run] git tag v%s + git push origin v%s\n' "${version}" "${version}"
    else
      if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "${SCRIPT_NAME}: not in git repo" >&2; exit 1
      fi
      if git rev-parse "v${version}" >/dev/null 2>&1; then
        echo "${SCRIPT_NAME}: tag v${version} already exists (idempotent skip)"
      else
        git tag "v${version}"
      fi
      git push origin "v${version}"
    fi
    mark_phase tag-push
    ;;

  audit)
    if [[ "${dry_run}" == "1" ]]; then
      printf '[dry-run] brew style packaging/homebrew/sfs.rb (skipped on placeholder sha256) + scoop manifest schema validate\n'
    else
      if command -v brew >/dev/null 2>&1; then
        formula="${DIST_DIR}/packaging/homebrew/sfs.rb"
        if [[ -f "${formula}" ]]; then
          # 0.6.5 hotfix: when the formula still carries the cut-release
          # placeholder for sha256, `brew style` flags the placeholder string
          # itself as 3 separate lint errors (length / chars / case). This is
          # noise in the pre-cut state — the real sha256 only lands during
          # tap-update via scripts/cut-release.sh in dev staging. We therefore
          # detect the placeholder and skip `brew style` with an informative
          # message, while still running scoop schema validation.
          # NOTE: the full strict + online audit (URL availability, license
          # checks, etc.) can no longer run on a path (Homebrew disabled
          # `brew audit [path ...]`). After tap-update publishes the formula,
          # run `brew audit --strict --online sfs` (by name, against the
          # installed tap) as a post-publish verification step. Tracked as a
          # follow-up in CHANGELOG `[0.6.5]` Process learning.
          # 0.6.3/0.6.4 history: previously this phase used the now-removed
          # `--new-formula` flag, then `brew audit "${formula}"` with a path
          # argument; both broken upstream. Regression-guarded by
          # tests/test-no-deprecated-cli-flags.sh.
          if grep -q '__SHA256_PLACEHOLDER_FOR_RELEASE_CUT__' "${formula}"; then
            echo "${SCRIPT_NAME}: brew style — skipped (formula has placeholder sha256; release-cut will materialize)" >&2
          else
            brew style "${formula}" || { echo "brew style FAIL"; exit 1; }
          fi
        else
          echo "${SCRIPT_NAME}: brew formula missing — using template (release-cut will materialize sha256)" >&2
        fi
      else
        echo "${SCRIPT_NAME}: brew not installed — local skip (CI macOS will run real audit)" >&2
      fi
      bash "${DIST_DIR}/tests/scoop-manifest-validate.sh" || { echo "scoop schema FAIL"; exit 1; }
    fi
    mark_phase audit
    ;;

  tap-update)
    if [[ "${dry_run}" == "1" ]]; then
      printf '[dry-run] update tap/Formula/sfs.rb + bucket/sfs.json + git push (Homebrew + Scoop)\n'
    else
      echo "${SCRIPT_NAME}: tap-update — invoke tap-update helper (release tool integration point)"
      # Real tap update lives in scripts/cut-release.sh / scripts/update-product-taps.sh.
      # Here we only enforce the order; the actual push runs in the release tool.
    fi
    mark_phase tap-update
    ;;
esac

printf 'sfs-release-sequence: phase=%s version=%s OK (state: %s)\n' "${phase}" "${version}" "${state_dir}"
