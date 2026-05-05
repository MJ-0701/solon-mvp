#!/usr/bin/env bash
# tests/test-context-aliases.sh — agent adapters should not need exact .md keys.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -x "${SFS_BIN}" ]] || fail "missing executable bin/sfs"

for key in start commands/start commands/start.md sprint intake; do
  out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context path "${key}")"
  case "${out}" in
    */context/commands/start.md) ;;
    *) fail "context key ${key} resolved to unexpected path: ${out}" ;;
  esac
done

echo "test-context-aliases: OK"
