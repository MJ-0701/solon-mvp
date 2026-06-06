#!/usr/bin/env bash
# WU-5 S3-2: external orchestrator (Hermes-class) entry policy headline test.
#
# Locks the entry contract: headless invocation, file-bus reporting, inviolable
# gates (no orchestrator-initiated release/push/merge/approval-bypass), and
# first-permission read-only. Document existence + gate-inviolability markers.
# ASCII anchors.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POLICY="${CTX}/policies/external-orchestrator-entry.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
has() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }

[[ -f "${POLICY}" ]] || fail "missing external-orchestrator-entry.md"
has "${POLICY}" "id: sfs-policy-external-orchestrator-entry" "frontmatter id"
has "${POLICY}" "Headless invocation" "headless entry shape"
has "${POLICY}" "File-bus reporting" "file-bus reporting"
has "${POLICY}" "Inviolable gates" "gate-inviolability section"
has "${POLICY}" "cannot bypass" "gate bypass prohibition"
has "${POLICY}" "First-permission read-only" "first-permission read-only"

# Open-source boundary (WU-5-followup): optional/standalone + vendor-neutral +
# the discriminating test line. ASCII anchors so no LC_ALL juggling is needed.
has "${POLICY}" "Optional by design (standalone guarantee)" "optional/standalone frame"
has "${POLICY}" "Standalone guarantee." "standalone guarantee marker"
has "${POLICY}" "Vendor-neutral." "vendor-neutral marker"
has "${POLICY}" "Remove every external orchestrator" "discriminating test line"

has "${CTX}/_INDEX.md" "policies/external-orchestrator-entry.md" "index route"

# No implementation/adapter code — this is a thin convention (no code fences with
# shell/exec). A leaked absolute path would also fail private-path hygiene.
if grep -Eq '/Users/|/home/[a-z]' "${POLICY}"; then
  fail "orchestrator policy leaks an absolute private path"
fi

echo "test-external-orchestrator-entry: OK"
