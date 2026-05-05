#!/usr/bin/env bash
# tests/test-sfs-pass1-prompts.sh — AC3.4 deterministic 6 enumerated prompts.
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
mkdir -p .sfs-local/sprints/0-5-x-no-report
echo "scratch" > .sfs-local/sprints/0-5-x-no-report/notes.md   # report.md absent → triggers Pass 1 prompts
git add -A && git commit -q -m init

out="$(bash "${SCRIPT}" --auto --root . 2>&1 || true)"

count=0
for q in "Q-A:" "Q-B:" "Q-C:" "Q-D:" "Q-E:" "Q-F:"; do
  if echo "${out}" | grep -q "^${q}"; then
    count=$((count + 1))
  else
    echo "AC3.4 FAIL: missing prompt prefix ${q}"
  fi
done

if [[ "${count}" -lt 6 ]]; then
  echo "AC3.4 FAIL: only ${count}/6 enumerated prompts found" >&2
  echo "${out}" >&2
  exit 1
fi

echo "test-sfs-pass1-prompts: OK (6/6 deterministic prompts present)"
