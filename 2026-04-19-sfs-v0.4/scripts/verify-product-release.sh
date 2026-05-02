#!/usr/bin/env bash
# Verify that a product release reached every user-facing channel.
#
# This is an owner-side release guard. It is intentionally separate from
# cut-release.sh because channel publish uses three repos:
#   1. solon-product stable tag
#   2. homebrew-solon-product tap
#   3. scoop-solon-product bucket

set -euo pipefail

VERSION=""
CHECK_INSTALLED=1
CHECK_HANDOFF_CLEAN=1
VERIFY_NETWORK_MAX_TIME_SEC="${SFS_VERIFY_NETWORK_MAX_TIME_SEC:-120}"
VERIFY_GIT_LOW_SPEED_TIME_SEC="${SFS_VERIFY_GIT_LOW_SPEED_TIME_SEC:-30}"
VERIFY_INSTALLED_TIMEOUT_SEC="${SFS_VERIFY_INSTALLED_TIMEOUT_SEC:-45}"

usage() {
  cat <<'EOF'
Usage:
  bash scripts/verify-product-release.sh --version 0.5.60-product
  bash scripts/verify-product-release.sh --version 0.5.60-product --no-installed-check
  bash scripts/verify-product-release.sh --version 0.5.60-product --no-clean-handoff-check

Checks:
  - GitHub product tag v<VERSION> exists
  - Homebrew remote formula URL/sha256 points at v<VERSION>
  - local Homebrew tap clone is not stale, when present
  - Scoop remote manifest URL/hash/extract_dir points at v<VERSION>
  - installed `sfs version --check` is up-to-date, unless skipped
  - local release repos are on clean, pushed main branches for next-session handoff

Local clean handoff repos, when present:
  - SFS_DEV_REPO, default: repo containing this script
  - SOLON_STABLE_REPO, default: ~/tmp/solon-product
  - SFS_HOMEBREW_REPO, default: ~/tmp/homebrew-solon-product
  - SFS_SCOOP_REPO, default: ~/tmp/scoop-solon-product
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      VERSION="${2:-}"
      shift 2
      ;;
    --version=*)
      VERSION="${1#*=}"
      shift
      ;;
    --no-installed-check)
      CHECK_INSTALLED=0
      shift
      ;;
    --no-clean-handoff-check)
      CHECK_HANDOFF_CLEAN=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown arg: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "${VERSION}" ]]; then
  echo "missing --version" >&2
  usage >&2
  exit 1
fi

if ! [[ "${VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+-product$ ]]; then
  echo "invalid product version: ${VERSION}" >&2
  exit 1
fi
for _timeout_name in VERIFY_NETWORK_MAX_TIME_SEC VERIFY_GIT_LOW_SPEED_TIME_SEC VERIFY_INSTALLED_TIMEOUT_SEC; do
  _timeout_value="${!_timeout_name}"
  if ! [[ "${_timeout_value}" =~ ^[1-9][0-9]*$ ]]; then
    echo "invalid ${_timeout_name}: ${_timeout_value} (expected positive integer seconds)" >&2
    exit 1
  fi
done

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-release-verify.XXXXXX")"
cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT INT TERM

log() { printf '[verify-product-release] %s\n' "$*"; }
fail() {
  printf '[verify-product-release] ERROR: %s\n' "$1" >&2
  exit "${2:-1}"
}

fetch() {
  local url="$1" out="$2"
  curl -fsSL --connect-timeout 15 --max-time "${VERIFY_NETWORK_MAX_TIME_SEC}" --retry 2 --retry-delay 1 "$url" -o "$out" \
    || fail "download failed or timed out: $url" 2
}

sha256_file() {
  local file="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print $1}'
  else
    fail "missing sha256 tool: shasum or sha256sum" 2
  fi
}

require_text() {
  local file="$1" pattern="$2" label="$3"
  if ! grep -q "$pattern" "$file"; then
    fail "${label} missing pattern: ${pattern}" 3
  fi
}

PRODUCT_REPO="https://github.com/MJ-0701/solon-product"
HOMEBREW_REPO="https://github.com/MJ-0701/homebrew-solon-product"
SCOOP_REPO="https://github.com/MJ-0701/scoop-solon-product"
TAR_URL="${PRODUCT_REPO}/archive/refs/tags/v${VERSION}.tar.gz"
ZIP_URL="${PRODUCT_REPO}/archive/refs/tags/v${VERSION}.zip"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCSET_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEFAULT_DEV_REPO="$(git -C "${DOCSET_ROOT}" rev-parse --show-toplevel 2>/dev/null || true)"
DEV_REPO="${SFS_DEV_REPO:-${DEFAULT_DEV_REPO}}"
STABLE_LOCAL_REPO="${SOLON_STABLE_REPO:-${HOME}/tmp/solon-product}"
HOMEBREW_LOCAL_REPO="${SFS_HOMEBREW_REPO:-${HOME}/tmp/homebrew-solon-product}"
SCOOP_LOCAL_REPO="${SFS_SCOOP_REPO:-${HOME}/tmp/scoop-solon-product}"

log "version = ${VERSION}"

remote_main_sha() {
  local repo="$1" label="$2" sha
  sha="$(GIT_HTTP_LOW_SPEED_LIMIT=1 GIT_HTTP_LOW_SPEED_TIME="${VERIFY_GIT_LOW_SPEED_TIME_SEC}" \
    git ls-remote "${repo}.git" refs/heads/main | awk '{print $1}' | head -1)"
  [[ -n "${sha}" ]] || fail "cannot resolve ${label} origin/main" 4
  printf '%s\n' "${sha}"
}

log "[1/6] product tag"
if ! GIT_HTTP_LOW_SPEED_LIMIT=1 GIT_HTTP_LOW_SPEED_TIME="${VERIFY_GIT_LOW_SPEED_TIME_SEC}" \
  git ls-remote --tags "${PRODUCT_REPO}.git" "refs/tags/v${VERSION}" | grep -q "refs/tags/v${VERSION}$"; then
  fail "missing product tag: v${VERSION}" 4
fi
log "  ok tag v${VERSION}"

log "[2/6] Homebrew remote formula"
HB_MAIN_SHA="$(remote_main_sha "${HOMEBREW_REPO}" "Homebrew tap")"
HOMEBREW_RAW="https://raw.githubusercontent.com/MJ-0701/homebrew-solon-product/${HB_MAIN_SHA}/Formula/sfs.rb"
HB_FORMULA="${TMP_DIR}/sfs.rb"
fetch "${HOMEBREW_RAW}" "${HB_FORMULA}"
require_text "${HB_FORMULA}" "v${VERSION}\\.tar\\.gz" "Homebrew formula"
HB_SHA="$(sed -n 's/.*sha256 "\([^"]*\)".*/\1/p' "${HB_FORMULA}" | head -1)"
[[ -n "${HB_SHA}" ]] || fail "Homebrew formula sha256 not found" 3
TAR_PATH="${TMP_DIR}/sfs.tar.gz"
fetch "${TAR_URL}" "${TAR_PATH}"
ACTUAL_TAR_SHA="$(sha256_file "${TAR_PATH}")"
[[ "${HB_SHA}" = "${ACTUAL_TAR_SHA}" ]] || fail "Homebrew sha mismatch: formula=${HB_SHA} actual=${ACTUAL_TAR_SHA}" 5
log "  ok formula URL + sha256 (${HB_MAIN_SHA:0:7})"

log "[3/6] local Homebrew tap freshness"
if command -v brew >/dev/null 2>&1; then
  TAP_REPO="$(brew --repo MJ-0701/solon-product 2>/dev/null || true)"
  if [[ -n "${TAP_REPO}" && -d "${TAP_REPO}/.git" ]]; then
    GIT_HTTP_LOW_SPEED_LIMIT=1 GIT_HTTP_LOW_SPEED_TIME="${VERIFY_GIT_LOW_SPEED_TIME_SEC}" \
      git -C "${TAP_REPO}" fetch --quiet origin main || fail "local Homebrew tap fetch failed: ${TAP_REPO}" 6
    TAP_HEAD="$(git -C "${TAP_REPO}" rev-parse HEAD)"
    TAP_ORIGIN="$(git -C "${TAP_REPO}" rev-parse refs/remotes/origin/main)"
    [[ "${TAP_HEAD}" = "${TAP_ORIGIN}" ]] || fail "local Homebrew tap is stale: ${TAP_REPO}" 6
    require_text "${TAP_REPO}/Formula/sfs.rb" "v${VERSION}\\.tar\\.gz" "local Homebrew tap formula"
    log "  ok tap clone ${TAP_REPO}"
  else
    log "  skip: local Homebrew tap clone not installed"
  fi
else
  log "  skip: brew not found"
fi

log "[4/6] Scoop remote manifest"
SCOOP_MAIN_SHA="$(remote_main_sha "${SCOOP_REPO}" "Scoop bucket")"
SCOOP_RAW="https://raw.githubusercontent.com/MJ-0701/scoop-solon-product/${SCOOP_MAIN_SHA}/bucket/sfs.json"
SCOOP_JSON="${TMP_DIR}/sfs.json"
fetch "${SCOOP_RAW}" "${SCOOP_JSON}"
if command -v python3 >/dev/null 2>&1; then
  python3 -m json.tool "${SCOOP_JSON}" >/dev/null || fail "Scoop manifest is invalid JSON" 3
fi
require_text "${SCOOP_JSON}" "\"version\": \"${VERSION}\"" "Scoop manifest"
require_text "${SCOOP_JSON}" "v${VERSION}\\.zip" "Scoop manifest"
require_text "${SCOOP_JSON}" "solon-product-${VERSION}" "Scoop manifest"
SCOOP_SHA="$(sed -n 's/.*"hash": "\([^"]*\)".*/\1/p' "${SCOOP_JSON}" | head -1)"
[[ -n "${SCOOP_SHA}" ]] || fail "Scoop manifest hash not found" 3
ZIP_PATH="${TMP_DIR}/sfs.zip"
fetch "${ZIP_URL}" "${ZIP_PATH}"
ACTUAL_ZIP_SHA="$(sha256_file "${ZIP_PATH}")"
[[ "${SCOOP_SHA}" = "${ACTUAL_ZIP_SHA}" ]] || fail "Scoop hash mismatch: manifest=${SCOOP_SHA} actual=${ACTUAL_ZIP_SHA}" 5
log "  ok manifest URL + hash (${SCOOP_MAIN_SHA:0:7})"

log "[5/6] installed runtime"
if [[ "${CHECK_INSTALLED}" = "1" ]]; then
  command -v sfs >/dev/null 2>&1 || fail "installed sfs not found; rerun with --no-installed-check to skip" 7
  if ! VERSION_OUT="$(SFS_COMMAND_TIMEOUT_SEC="${VERIFY_INSTALLED_TIMEOUT_SEC}" sfs version --check 2>&1)"; then
    fail "installed sfs version check failed or timed out: ${VERSION_OUT}" 7
  fi
  printf '%s\n' "${VERSION_OUT}" | grep -q "^sfs ${VERSION}$" || fail "installed sfs is not ${VERSION}" 7
  printf '%s\n' "${VERSION_OUT}" | grep -q "^latest ${VERSION}$" || fail "latest tag is not ${VERSION}" 7
  printf '%s\n' "${VERSION_OUT}" | grep -q "^status up-to-date$" || fail "installed sfs is not up-to-date" 7
  log "  ok installed sfs up-to-date"
else
  log "  skipped by --no-installed-check"
fi

check_clean_handoff_repo() {
  local repo="$1" label="$2" branch dirty head remote_head
  if [[ -z "${repo}" || ! -d "${repo}" ]]; then
    log "  skip ${label}: local repo not found (${repo:-unset})"
    return 0
  fi
  if [[ ! -d "${repo}/.git" ]]; then
    log "  skip ${label}: not a git repo (${repo})"
    return 0
  fi

  dirty="$(git -C "${repo}" status --porcelain 2>/dev/null || true)"
  if [[ -n "${dirty}" ]]; then
    printf '%s\n' "${dirty}" | sed "s/^/[verify-product-release]   ${label} dirty: /" >&2
    fail "${label} has uncommitted changes; commit/push or intentionally stash before ending release" 8
  fi

  branch="$(git -C "${repo}" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  if [[ "${branch}" != "main" ]]; then
    fail "${label} is on branch ${branch:-unknown}; switch back to main before handoff" 8
  fi

  GIT_HTTP_LOW_SPEED_LIMIT=1 GIT_HTTP_LOW_SPEED_TIME="${VERIFY_GIT_LOW_SPEED_TIME_SEC}" \
    git -C "${repo}" fetch --quiet origin main || fail "${label} origin/main fetch failed" 8
  head="$(git -C "${repo}" rev-parse HEAD 2>/dev/null || true)"
  remote_head="$(git -C "${repo}" rev-parse refs/remotes/origin/main 2>/dev/null || true)"
  if [[ -z "${head}" || -z "${remote_head}" || "${head}" != "${remote_head}" ]]; then
    fail "${label} is not synced with origin/main (HEAD=${head:-unknown}, origin/main=${remote_head:-unknown})" 8
  fi

  log "  ok ${label} clean + synced (${head:0:7})"
}

log "[6/6] clean handoff state"
if [[ "${CHECK_HANDOFF_CLEAN}" = "1" ]]; then
  check_clean_handoff_repo "${DEV_REPO}" "dev repo"
  check_clean_handoff_repo "${STABLE_LOCAL_REPO}" "product stable repo"
  check_clean_handoff_repo "${HOMEBREW_LOCAL_REPO}" "Homebrew tap repo"
  check_clean_handoff_repo "${SCOOP_LOCAL_REPO}" "Scoop bucket repo"
  log "OK product release verified and handoff clean: ${VERSION}"
else
  log "  skipped by --no-clean-handoff-check"
  log "OK product release verified: ${VERSION} (clean handoff check skipped)"
fi
