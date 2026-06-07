#!/usr/bin/env bash
# WU-1 daily bookend operating loop — headline test.
#
# Locks: the routed command doc exists + is routed in _INDEX + resolves via
# `sfs context path daily`; it carries the reference-doc skeleton and a
# provenance footer; it names the existing primitives it composes; and it is a
# composition, NOT a new binary (no `daily` dispatch entry, and the doc says so).
# ASCII anchors only.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
DOC="${CTX}/commands/daily.md"
DISPATCH="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-dispatch.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

# 1) doc exists + frontmatter id + index route.
[[ -f "${DOC}" ]] || fail "missing commands/daily.md"
has "${DOC}" "id: sfs-command-daily" "frontmatter id"
has "${CTX}/_INDEX.md" "commands/daily.md" "index route"

# 2) reference-doc skeleton + provenance footer.
for field in Grain Scope Usage Gotchas Cross-Ref; do
  has "${DOC}" "${field}" "skeleton field ${field}"
done
has "${DOC}" "Provenance:" "provenance footer"

# 3) section anchors + composed primitives named.
has "${DOC}" "MORNING_BRIEF" "morning anchor"
has "${DOC}" "EVENING_RECAP" "evening anchor"
for cmd in "sfs status" "sfs recall" "sfs capture" "sfs tidy" "sfs loop"; do
  has "${DOC}" "${cmd}" "composed primitive ${cmd}"
done

# 4) composition, not a binary: doc says so AND dispatch does not route 'daily'.
has "${DOC}" "not a" "not-a-binary contract"
grep -Fq "sfs daily" "${DOC}" || fail "doc should explicitly mention there is no 'sfs daily' binary"
if grep -qE '(^|[^a-z])daily([^a-z]|$)' "${DISPATCH}"; then
  fail "dispatch must NOT route 'daily' — it is a composed routine, not a binary"
fi

# 5) resolves via context path (alias forms).
for key in daily commands/daily commands/daily.md; do
  out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context path "${key}")"
  case "${out}" in
    */context/commands/daily.md) ;;
    *) fail "context key ${key} resolved to unexpected path: ${out}" ;;
  esac
done

echo "test-daily-bookend-loop: OK"
