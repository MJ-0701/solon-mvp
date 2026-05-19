#!/usr/bin/env bash
# 낡은 project-local context가 최신 runtime guard를 가리지 않게 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-context-stale.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

cd "${TMP_DIR}"
git init -q
mkdir -p .sfs-local/context
cat > .sfs-local/VERSION <<'EOF'
solon_mvp_version: 0.5.23-product
installed_at: 2026-04-30T00:00:00Z
EOF
printf 'STALE PROJECT KERNEL\n' > .sfs-local/context/kernel.md

runtime_kernel="${DIST_DIR}/templates/.sfs-local-template/context/kernel.md"
project_kernel=".sfs-local/context/kernel.md"

out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context path kernel)"
[[ "${out}" = "${runtime_kernel}" ]] \
  || fail "stale project context should resolve to runtime kernel, got: ${out}"

cat_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context cat kernel)"
case "${cat_out}" in
  *"Session Continuation Guard"*) ;;
  *) fail "runtime kernel did not expose Session Continuation Guard" ;;
esac
case "${cat_out}" in
  *"STALE PROJECT KERNEL"*) fail "stale project kernel leaked into context cat" ;;
esac

override_out="$(
  SFS_CONTEXT_PREFER_PROJECT=1 \
  SFS_COMMAND_TIMEOUT_SEC=0 \
  SFS_DIST_DIR="${DIST_DIR}" \
  bash "${SFS_BIN}" context path kernel
)"
[[ "${override_out}" = "${project_kernel}" ]] \
  || fail "explicit project override should preserve local context path, got: ${override_out}"

echo "test-context-stale-project-runtime-precedence: OK"
