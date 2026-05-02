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

usage() {
  cat <<'EOF'
Usage:
  bash scripts/verify-product-release.sh --version 0.5.60-product
  bash scripts/verify-product-release.sh --version 0.5.60-product --no-installed-check

Checks:
  - GitHub product tag v<VERSION> exists
  - Homebrew remote formula URL/sha256 points at v<VERSION>
  - local Homebrew tap clone is not stale, when present
  - Scoop remote manifest URL/hash/extract_dir points at v<VERSION>
  - installed `sfs version --check` is up-to-date, unless skipped
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
  curl -fsSL "$url" -o "$out" || fail "download failed: $url" 2
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
HOMEBREW_RAW="https://raw.githubusercontent.com/MJ-0701/homebrew-solon-product/main/Formula/sfs.rb"
SCOOP_RAW="https://raw.githubusercontent.com/MJ-0701/scoop-solon-product/main/bucket/sfs.json"
TAR_URL="${PRODUCT_REPO}/archive/refs/tags/v${VERSION}.tar.gz"
ZIP_URL="${PRODUCT_REPO}/archive/refs/tags/v${VERSION}.zip"

log "version = ${VERSION}"

log "[1/5] product tag"
if ! git ls-remote --tags "${PRODUCT_REPO}.git" "refs/tags/v${VERSION}" | grep -q "refs/tags/v${VERSION}$"; then
  fail "missing product tag: v${VERSION}" 4
fi
log "  ok tag v${VERSION}"

log "[2/5] Homebrew remote formula"
HB_FORMULA="${TMP_DIR}/sfs.rb"
fetch "${HOMEBREW_RAW}" "${HB_FORMULA}"
require_text "${HB_FORMULA}" "v${VERSION}\\.tar\\.gz" "Homebrew formula"
HB_SHA="$(sed -n 's/.*sha256 "\([^"]*\)".*/\1/p' "${HB_FORMULA}" | head -1)"
[[ -n "${HB_SHA}" ]] || fail "Homebrew formula sha256 not found" 3
TAR_PATH="${TMP_DIR}/sfs.tar.gz"
fetch "${TAR_URL}" "${TAR_PATH}"
ACTUAL_TAR_SHA="$(sha256_file "${TAR_PATH}")"
[[ "${HB_SHA}" = "${ACTUAL_TAR_SHA}" ]] || fail "Homebrew sha mismatch: formula=${HB_SHA} actual=${ACTUAL_TAR_SHA}" 5
log "  ok formula URL + sha256"

log "[3/5] local Homebrew tap freshness"
if command -v brew >/dev/null 2>&1; then
  TAP_REPO="$(brew --repo MJ-0701/solon-product 2>/dev/null || true)"
  if [[ -n "${TAP_REPO}" && -d "${TAP_REPO}/.git" ]]; then
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

log "[4/5] Scoop remote manifest"
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
log "  ok manifest URL + hash"

log "[5/5] installed runtime"
if [[ "${CHECK_INSTALLED}" = "1" ]]; then
  command -v sfs >/dev/null 2>&1 || fail "installed sfs not found; rerun with --no-installed-check to skip" 7
  VERSION_OUT="$(sfs version --check)"
  printf '%s\n' "${VERSION_OUT}" | grep -q "^sfs ${VERSION}$" || fail "installed sfs is not ${VERSION}" 7
  printf '%s\n' "${VERSION_OUT}" | grep -q "^latest ${VERSION}$" || fail "latest tag is not ${VERSION}" 7
  printf '%s\n' "${VERSION_OUT}" | grep -q "^status up-to-date$" || fail "installed sfs is not up-to-date" 7
  log "  ok installed sfs up-to-date"
else
  log "  skipped by --no-installed-check"
fi

log "OK product release verified: ${VERSION}"
