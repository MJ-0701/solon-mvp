#!/usr/bin/env bash
# Static contract check for templates/.sfs-local-template/presets/solon-safe-permissions.yaml.
#
# The preset is a runtime-agnostic translation of the CLAUDE.md 절대 금지
# rules + kernel.md mainline-first / Gate 6 contract. This test ensures
# the executable shape stays in sync with the documented policy: if a
# critical denial drops out by accident, the preset stops being safe.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PRESET="${DIST_DIR}/templates/.sfs-local-template/presets/solon-safe-permissions.yaml"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "${PRESET}" ]] || fail "missing preset: ${PRESET}"

# ── 1) Version tracks the 0.7.x line so consumers can pin. ──────────
grep -qE '^version: "0\.7\.[0-9]+"' "${PRESET}" \
  || fail "preset version must track the 0.7.x line"

# ── 2) Top-level sections present. ──────────────────────────────────
for section in 'tools:' 'workflow:' 'audit:'; do
  grep -qF "${section}" "${PRESET}" \
    || fail "preset missing top-level section: ${section}"
done

# ── 3) Read-only pre-approvals — must include the Solon read surface
#       and the host-side read tools. ────────────────────────────────
for need in \
  '- read' \
  '- web_fetch' \
  '- WebFetch' \
  '- solon.sfs_status' \
  '- solon.sfs_version' \
  '- solon.sfs_report' \
  '- solon.sfs_harness_doctor' \
  '"bash:sfs status"' \
  '"bash:sfs harness doctor"'
do
  grep -qF -- "${need}" "${PRESET}" \
    || fail "preset pre_approved missing: ${need}"
done

# ── 4) Approval-gated writes — must include every mutating MCP tool. ─
for need in \
  '- solon.sfs_start' \
  '- solon.sfs_brainstorm' \
  '- solon.sfs_plan' \
  '- solon.sfs_implement' \
  '- solon.sfs_review' \
  '- solon.sfs_retro' \
  '- solon.sfs_decision' \
  '- solon.sfs_capture' \
  '- write' \
  '- edit'
do
  grep -qF -- "${need}" "${PRESET}" \
    || fail "preset ask_approval missing: ${need}"
done

# ── 5) Denials — the "절대 금지" rules. Auto-push is the marquee one. ─
for need in \
  '"bash:git push*"' \
  '"bash:rm -rf *"' \
  '"bash:git reset --hard*"' \
  '"bash:git push --force*"' \
  '"edit:.sfs-local/sprints/**"' \
  '"edit:.sfs-local/decisions/**"' \
  '"edit:.sfs-local/events.jsonl"'
do
  grep -qF -- "${need}" "${PRESET}" \
    || fail "preset denied rules missing: ${need}"
done

# ── 6) Workflow advisories — Gate 6 + mainline-first are load-bearing. ─
for need in \
  'mainline_first: true' \
  'require_gate_6: true' \
  'require_release_readiness_when_production: true' \
  'handoff_is_stop_contract: true'
do
  grep -qF -- "${need}" "${PRESET}" \
    || fail "preset workflow missing: ${need}"
done

# ── 7) Audit redaction — well-known secret env vars must be in the
#       redaction list so they cannot leak through tool-call audit logs. ─
for secret in \
  ANTHROPIC_API_KEY \
  OPENAI_API_KEY \
  GEMINI_API_KEY \
  GOOGLE_API_KEY \
  CLAUDE_CODE_OAUTH_TOKEN \
  GOOGLE_APPLICATION_CREDENTIALS
do
  grep -qF -- "${secret}" "${PRESET}" \
    || fail "preset audit.redact_in_logs missing: ${secret}"
done

echo "test-solon-safe-permissions-preset: OK"
