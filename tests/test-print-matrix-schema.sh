#!/usr/bin/env bash
# tests/test-print-matrix-schema.sh — AC10.1 JSON Lines 6 fields schema.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCRIPT="${DIST_DIR}/scripts/sfs-migrate-artifacts.sh"

[[ -x "${SCRIPT}" ]] || { echo "missing: ${SCRIPT}" >&2; exit 1; }

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT
cd "${tmp}"
git init -q
git config user.email t@t
git config user.name t
mkdir -p .sfs-local/sprints/0-5-x-mxs/foo
echo "data" > .sfs-local/sprints/0-5-x-mxs/foo/notes.md
echo "## Report" > .sfs-local/sprints/0-5-x-mxs/foo/report.md
git add -A && git commit -q -m init

lines="$(bash "${SCRIPT}" --print-matrix --root . 2>/dev/null)"
[[ -n "${lines}" ]] || { echo "AC10.1 FAIL: empty matrix"; exit 1; }

# Each line must have all 6 fields.
fail=0
while IFS= read -r line; do
  [[ -n "${line}" ]] || continue
  for k in '"source":' '"dest":' '"action":' '"sha256_before":' '"sha256_after":' '"reason":'; do
    if ! echo "${line}" | grep -q "${k}"; then
      echo "AC10.1 FAIL: missing key ${k} in: ${line}"
      fail=$((fail + 1))
    fi
  done
  # action enum check.
  action="$(echo "${line}" | sed -E 's/.*"action":"([^"]+)".*/\1/')"
  case "${action}" in
    migrate|archive|delete|skip) ;;
    *) echo "AC10.1 FAIL: action enum violation: ${action}"; fail=$((fail + 1));;
  esac
  # null semantics: action ∈ delete/skip → sha256_after must be null.
  case "${action}" in
    delete|skip)
      if ! echo "${line}" | grep -qE '"sha256_after":null'; then
        echo "AC10.1 FAIL: ${action} action requires sha256_after=null: ${line}"
        fail=$((fail + 1))
      fi
      ;;
  esac
done <<< "${lines}"

if [[ "${fail}" -gt 0 ]]; then exit 1; fi
echo "test-print-matrix-schema: OK"
