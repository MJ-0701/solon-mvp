#!/usr/bin/env bash
# verify-product-release.sh — post-publish verification for a cut release.
#
# Codifies the manual verification sequence the channel-publish runbook used
# to describe in prose (and that operators repeated by hand for 0.8.34-36):
#   1. VERSION file matches the version under verification
#   2. git tag v<version> exists and points at an ancestor of HEAD
#   3. release-state phase markers complete (tag-push/audit/tap-update/post-audit)
#   4. Homebrew tap clone (if present) carries v<version> in Formula/sfs.rb
#   5. Scoop bucket clone (if present) carries <version> in bucket/sfs.json
#   6. installed sfs (if on PATH) reports the version (best-effort, warn only)
#
# Local-evidence only: no network calls, no provider APIs. Channel clones are
# located via SFS_HOMEBREW_CLONE / SFS_SCOOP_CLONE env or the conventional
# ~/tmp/{homebrew,scoop}-solon-product paths; absent clones warn, not fail.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

version=""
while [ $# -gt 0 ]; do
  case "$1" in
    --version) version="${2:-}"; shift 2 || { echo "--version requires X.Y.Z" >&2; exit 2; } ;;
    -h|--help)
      echo "usage: verify-product-release.sh --version X.Y.Z"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done
[ -n "${version}" ] || { echo "usage: verify-product-release.sh --version X.Y.Z" >&2; exit 2; }

fails=0
ok()   { printf 'ok   %s\n' "$1"; }
warn() { printf 'warn %s\n' "$1"; }
bad()  { printf 'FAIL %s\n' "$1"; fails=$((fails + 1)); }

# 1) VERSION file
if [ "$(cat "${DIST_DIR}/VERSION" 2>/dev/null | tr -d '[:space:]')" = "${version}" ]; then
  ok "VERSION file is ${version}"
else
  bad "VERSION file ($(cat "${DIST_DIR}/VERSION" 2>/dev/null)) != ${version}"
fi

# 2) git tag exists and is an ancestor of HEAD
if git -C "${DIST_DIR}" rev-parse "v${version}" >/dev/null 2>&1; then
  if git -C "${DIST_DIR}" merge-base --is-ancestor "v${version}" HEAD 2>/dev/null; then
    ok "tag v${version} exists and is an ancestor of HEAD"
  else
    bad "tag v${version} exists but is not an ancestor of HEAD"
  fi
else
  bad "tag v${version} missing"
fi

# 3) release-state phase markers
state_dir="${DIST_DIR}/.sfs-local/release-state/${version}"
for marker in tag-push audit tap-update post-audit; do
  if [ -f "${state_dir}/${marker}.done" ]; then
    ok "phase marker ${marker}.done"
  else
    bad "phase marker missing: ${state_dir}/${marker}.done"
  fi
done

# 4) Homebrew tap clone
brew_clone="${SFS_HOMEBREW_CLONE:-$HOME/tmp/homebrew-solon-product}"
if [ -f "${brew_clone}/Formula/sfs.rb" ]; then
  if grep -qF "v${version}.tar.gz" "${brew_clone}/Formula/sfs.rb"; then
    ok "homebrew formula carries v${version}"
  else
    bad "homebrew formula at ${brew_clone} does not carry v${version}"
  fi
else
  warn "homebrew clone not found at ${brew_clone} (set SFS_HOMEBREW_CLONE)"
fi

# 5) Scoop bucket clone
scoop_clone="${SFS_SCOOP_CLONE:-$HOME/tmp/scoop-solon-product}"
if [ -f "${scoop_clone}/bucket/sfs.json" ]; then
  if grep -qF "\"version\": \"${version}\"" "${scoop_clone}/bucket/sfs.json"; then
    ok "scoop manifest carries ${version}"
  else
    bad "scoop manifest at ${scoop_clone} does not carry ${version}"
  fi
else
  warn "scoop clone not found at ${scoop_clone} (set SFS_SCOOP_CLONE)"
fi

# 6) installed sfs (best-effort)
if command -v sfs >/dev/null 2>&1; then
  installed="$(sfs version 2>/dev/null | head -1 || true)"
  if [ "${installed}" = "sfs ${version}" ]; then
    ok "installed sfs reports ${version}"
  else
    warn "installed sfs reports '${installed}' (upgrade pending or different machine)"
  fi
else
  warn "sfs not on PATH (skipping installed check)"
fi

if [ "${fails}" -gt 0 ]; then
  echo "verify-product-release: FAIL (${fails} failing checks) version=${version}"
  exit 1
fi
echo "verify-product-release: OK version=${version}"
