#!/usr/bin/env bash
# tests/test-windows-argv-stale-env.sh — 0.8.51 Windows ps1 stale-env argv guard.
#
# Locks the 0.8.51 fix for the 0.6.45-0.6.56 / 0.8.50 regression class: a prior
# `sfs upgrade` reload set $env:SFS_NATIVE_* on the in-process PowerShell session
# and never cleared it, and bin/sfs.ps1 selected the env channel BEFORE the
# typed args — so every later typed command (sfs init, sfs team show, ...) was
# silently rewritten to the stale "update".
#
# No pwsh on the CI host, so we lock the contract two ways:
#   (1) an executable bash oracle that encodes the precedence INVARIANT
#       ("current typed args beat inherited env") and proves the canonical
#       stale-env case resolves to the typed command, and
#   (2) semantic source asserts on bin/sfs.ps1 that BREAK if the precedence
#       flips back to env-first or the reload stops restoring session env.
# This is stronger than 0.8.50's static text match: it enforces the line-order
# RELATIONSHIP (typed selection precedes the env fallback; env is guarded), which
# is exactly the property that regressed.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PS1="${DIST_DIR}/bin/sfs.ps1"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "${PS1}" ]] || fail "missing ${PS1}"

# ── L1 oracle: the precedence invariant, executable ─────────────────────────
# Mirror of bin/sfs.ps1's resolution rule: when typed args are non-empty they
# win; the env channel is consulted ONLY when typed is empty (the cmd-shim path
# that forwards zero positional args). Encodes the contract the ps1 must satisfy.
resolve_like_ps1() {
  # $1 = typed args (space-joined, "" if none); $2 = inherited env args.
  local typed="$1" env_args="$2"
  if [[ -n "${typed// }" ]]; then printf '%s' "${typed}"; else printf '%s' "${env_args}"; fi
}

# Canonical failing scenario from the confirmed trace: stale env = "update",
# user typed "init --yes". Must resolve to the typed command, NOT the stale env.
got="$(resolve_like_ps1 "init --yes" "update")"
[[ "${got}" == "init --yes" ]] \
  || fail "L1 oracle: stale env must not shadow typed args (got '${got}')"
# cmd-shim path preserved: no typed args -> env channel still authoritative.
got="$(resolve_like_ps1 "" "team use trio")"
[[ "${got}" == "team use trio" ]] \
  || fail "L1 oracle: cmd-shim path (empty typed) must still use env (got '${got}')"

# ── L1 source: typed selection precedes the env fallback, env is guarded ─────
typed_line="$(grep -nF '$SfsTypedArgs = Resolve-SfsArgs' "${PS1}" | head -1 | cut -d: -f1)"
[[ -n "${typed_line}" ]] \
  || fail "L1: bin/sfs.ps1 must derive \$SfsTypedArgs from typed args before env selection"

env_line="$(grep -nF '$SfsArgs = Resolve-SfsArgs -ParamArgs $SfsEnvArgs' "${PS1}" | head -1 | cut -d: -f1)"
[[ -n "${env_line}" ]] \
  || fail "L1: bin/sfs.ps1 must keep an env-channel fallback (\$SfsEnvArgs)"

[[ "${typed_line}" -lt "${env_line}" ]] \
  || fail "L1: typed-arg selection (line ${typed_line}) must come BEFORE the env fallback (line ${env_line}); env-first is the regression"

# The env fallback must be reached only when typed args are unusable. Assert an
# `if (-not (Test-SfsUsableArgs $SfsArgs))` guard sits just above the env line.
guard_window="$(sed -n "$((env_line-3)),$((env_line-1))p" "${PS1}")"
printf '%s\n' "${guard_window}" | grep -q 'if (-not (Test-SfsUsableArgs \$SfsArgs))' \
  || fail "L1: env fallback must be guarded by 'if (-not (Test-SfsUsableArgs \$SfsArgs))' (typed-empty only)"

# Negative: the old env-first one-liner (env as ParamArgs while $args is the
# UnboundArgs in the SAME call) must be gone — that is precisely env-over-typed.
if grep -qF 'Resolve-SfsArgs -ParamArgs $SfsEnvArgs -AutomaticArgs $SfsParamArgs -UnboundArgs $args' "${PS1}"; then
  fail "L1: env-first selection ('-ParamArgs \$SfsEnvArgs ... -UnboundArgs \$args') must NOT return (it lets stale env shadow typed args)"
fi

# ── L2 source: scoop reload restores session env (no SFS_NATIVE_* leak) ──────
for fn in 'function Get-SfsNativeArgEnvSnapshot' 'function Restore-SfsNativeArgEnvSnapshot'; do
  grep -qF "${fn}" "${PS1}" || fail "L2: missing helper '${fn}'"
done

snap_line="$(grep -nF '$nativeArgSnapshot = Get-SfsNativeArgEnvSnapshot' "${PS1}" | head -1 | cut -d: -f1)"
set_line="$(grep -nF 'Set-SfsNativeArgEnv $reloadArgs' "${PS1}" | head -1 | cut -d: -f1)"
restore_line="$(grep -nF 'Restore-SfsNativeArgEnvSnapshot $nativeArgSnapshot' "${PS1}" | head -1 | cut -d: -f1)"
for v in snap_line set_line restore_line; do
  [[ -n "${!v}" ]] || fail "L2: could not locate reload env-hygiene anchor (${v})"
done
[[ "${snap_line}" -lt "${set_line}" && "${set_line}" -lt "${restore_line}" ]] \
  || fail "L2: order must be snapshot(${snap_line}) -> Set-SfsNativeArgEnv(${set_line}) -> Restore(${restore_line})"

# Restore must live in a finally (runs even though the reload branch `exit`s).
between="$(sed -n "${set_line},$((restore_line+4))p" "${PS1}")"
printf '%s\n' "${between}" | grep -q 'finally {' \
  || fail "L2: Restore-SfsNativeArgEnvSnapshot must run inside a 'finally' after the reload"

# The skip-self-upgrade flag is also session env — restore it too.
printf '%s\n' "${between}" | grep -q 'Restore-SfsEnvValue "SFS_SKIP_SELF_UPGRADE"' \
  || fail "L2: reload must also restore SFS_SKIP_SELF_UPGRADE in the finally"

echo "PASS: Windows ps1 stale-env argv guard (typed beats stale env; reload restores session env)"
