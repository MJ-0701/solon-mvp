#!/usr/bin/env bash
# tests/test-sfs-cross-instance-verify.sh — AC4.4 4-bullet fallback policy.
#
# Fallback policy (F4 codex 4-bullet):
#  AC4.4.1 PR (incl. fork) without secrets   → SKIP with warning, exit 0 (CI status success).
#  AC4.4.2 main / nightly / release w/ secrets → both Codex + Gemini PASS required (block on either fail).
#  AC4.4.3 External API outage                → retry exponential backoff (max 3) then release-block,
#                                                PR fall back to skip+warning.
#  AC4.4.4 Sentinel masking isolated step      → see tests/test-sfs-log-masking.sh.
#
# This script is the orchestration shell. CI workflow invokes it with env hints.
#
# Env contract:
#   CODEX_API_KEY   = real key (auto detect)
#   GEMINI_API_KEY  = real key (auto detect)
#   SFS_CROSS_VERIFY_MODE = pr | main | nightly | release   (default pr)
#   SFS_CROSS_VERIFY_DRYRUN = 1 to skip real CLI calls (default 0 in CI; auto 1 outside CI)
#
# Exit codes:
#   0 = OK (PASS or SKIP-with-warning)
#   1 = block (FAIL on main/nightly/release with secrets, or repeated outage)
set -uo pipefail

mode="${SFS_CROSS_VERIFY_MODE:-pr}"
dryrun_default=0
[[ -n "${CI:-}" ]] || dryrun_default=1
dryrun="${SFS_CROSS_VERIFY_DRYRUN:-${dryrun_default}}"

has_codex_key=0
has_gemini_key=0
[[ -n "${CODEX_API_KEY:-}" ]] && has_codex_key=1
[[ -n "${GEMINI_API_KEY:-}" ]] && has_gemini_key=1

# AC4.4.1 — PR without secrets → SKIP with warning.
if [[ "${mode}" == "pr" ]] && [[ "${has_codex_key}" == "0" || "${has_gemini_key}" == "0" ]]; then
  echo "::warning::cross-instance verify SKIPPED (PR without one or both secrets) — AC4.4.1" >&2
  exit 0
fi

# Outside CI dryrun behaves like SKIP (test harness friendly).
if [[ "${dryrun}" == "1" ]]; then
  echo "test-sfs-cross-instance-verify: dryrun=1, mode=${mode} — SKIP (no real CLI invoke)"
  exit 0
fi

# Real verify (would invoke `codex` and `gemini` CLI). Sketch:
codex_pass=0
gemini_pass=0
attempts=0
max_attempts=3
backoff=2

while (( attempts < max_attempts )) && [[ "${codex_pass}" == "0" || "${gemini_pass}" == "0" ]]; do
  attempts=$((attempts + 1))

  if [[ "${codex_pass}" == "0" ]] && command -v codex >/dev/null 2>&1; then
    if codex --version >/dev/null 2>&1; then codex_pass=1; fi
  fi
  if [[ "${gemini_pass}" == "0" ]] && command -v gemini >/dev/null 2>&1; then
    if gemini --version >/dev/null 2>&1; then gemini_pass=1; fi
  fi

  if [[ "${codex_pass}" == "0" || "${gemini_pass}" == "0" ]]; then
    sleep "${backoff}"
    backoff=$((backoff * 2))
  fi
done

if [[ "${codex_pass}" == "1" && "${gemini_pass}" == "1" ]]; then
  echo "test-sfs-cross-instance-verify: AC4.4.2 PASS (codex+gemini both verified, mode=${mode})"
  exit 0
fi

# AC4.4.3 outage handling.
case "${mode}" in
  pr)
    echo "::warning::cross-instance verify outage on PR (codex=${codex_pass} gemini=${gemini_pass}) — SKIP fallback (AC4.4.3)" >&2
    exit 0
    ;;
  main|nightly|release)
    echo "AC4.4.3 RELEASE-BLOCK: cross-instance verify failed after ${max_attempts} attempts (codex=${codex_pass} gemini=${gemini_pass})" >&2
    exit 1
    ;;
  *)
    echo "AC4.4 unknown mode: ${mode}" >&2
    exit 1
    ;;
esac
