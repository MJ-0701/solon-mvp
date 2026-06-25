#!/usr/bin/env bash
# tests/test-windows-team-parity.sh — 0.8.50 Windows ps1 team-activation parity.
#
# Design (D0): the Windows entry surface is a THIN wrapper that DELEGATES to the
# bash core (install.sh / upgrade.sh / bin/sfs → sfs-team-apply.sh). There is no
# native PowerShell port of the materialize/offer logic — single SSoT, zero
# duplication. So "parity" here is a static contract: the ps1 wrappers must
# forward --team correctly (and only when asked), and bin/sfs.ps1 must keep
# delegating team/upgrade to bash. The actual materialize/auto-offer behavior is
# locked by the bash headline tests (test-team-use-activation.sh,
# test-team-auto-offer.sh); the ps1 hits that same core, so output parity is by
# construction. No pwsh/Windows on the CI host → static is the ceiling, so each
# assertion is made meaningful (forward-only-when-set, no native capture).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() { echo "FAIL: $*" >&2; exit 1; }

install_ps1="${DIST_DIR}/install.ps1"
upgrade_ps1="${DIST_DIR}/upgrade.ps1"
sfs_ps1="${DIST_DIR}/bin/sfs.ps1"

for f in "${install_ps1}" "${upgrade_ps1}" "${sfs_ps1}"; do
  [[ -f "${f}" ]] || fail "missing ${f}"
done

# ── P2/P3: install.ps1 + upgrade.ps1 declare -Team and forward --team ───────
# Assert (a) a [string] $Team param exists, (b) the forward is GUARDED by
# `if ($Team)` so omitting -Team forwards ZERO --team (the T3 byte-for-byte /
# R5-reachability hinge), and (c) the forwarded flag spelling is exactly
# "--team" + the value (byte-compatible with the bash front door).
assert_team_forward() {
  local f="$1" label="$2"
  grep -Eq '\[string\][[:space:]]*\$Team' "${f}" \
    || fail "${label}: missing [string] \$Team param"
  # Guarded forward: `if ($Team) { ... "--team" ... $Team }`.
  awk '
    /if[[:space:]]*\(\$Team\)/ { inblk=1 }
    inblk && /"--team"/        { sawflag=1 }
    inblk && /\$Team/ && sawflag && !/if[[:space:]]*\(\$Team\)/ { sawval=1 }
    inblk && /}/               { inblk=0 }
    END { exit (sawflag && sawval) ? 0 : 1 }
  ' "${f}" || fail "${label}: --team must be forwarded ONLY inside 'if (\$Team)' guard (with the \$Team value)"
  # Negative: $Team must have NO default — a default would leak --team on every
  # invocation, killing the R5 auto-offer and the solo no-op contract.
  if grep -Eq '\[string\][[:space:]]*\$Team[[:space:]]*=' "${f}"; then
    fail "${label}: \$Team must have NO default (a default leaks --team on every invocation, killing R5 auto-offer + solo no-op)"
  fi
}

assert_team_forward "${install_ps1}" "install.ps1"
assert_team_forward "${upgrade_ps1}" "upgrade.ps1"

# Bash core authority (no PowerShell ValidateSet that would change the error
# contract): the preset must NOT be constrained by a ValidateSet on $Team.
for f in "${install_ps1}" "${upgrade_ps1}"; do
  if grep -B1 -E '\[string\][[:space:]]*\$Team' "${f}" | grep -q 'ValidateSet'; then
    fail "$(basename "${f}"): \$Team must not use ValidateSet — bash (install.sh/upgrade.sh) is the preset authority"
  fi
done

# ── P2: --yes / -Yes forward stays guarded (locks T2/T3 R5 reachability) ────
# The R5 auto-offer in upgrade.sh is suppressed under --yes (non-interactive).
# So -Yes must forward --yes ONLY when set; a leaked --yes would silently kill
# the interactive offer.
grep -q 'if[[:space:]]*(\$Yes)[[:space:]]*{[[:space:]]*\$argsForBash[[:space:]]*+=[[:space:]]*"--yes"' "${upgrade_ps1}" \
  || fail "upgrade.ps1: --yes must be forwarded only inside 'if (\$Yes)'"

# ── P1: bin/sfs.ps1 keeps DELEGATING team/upgrade/update to bash ────────────
# `sfs.cmd team use trio` / `sfs.cmd upgrade --team trio` reach the bash core
# only because the native read-only handler does NOT claim these commands (they
# fall to the `default` branch → bash bridge). Lock that: the native readonly
# switch must not add team/upgrade/update cases. Guard against a future native
# handler edit that would silently break P1.
readonly_switch="$(awk '
  /function Invoke-SfsNativeReadonly/ { inblk=1 }
  inblk { print }
  inblk && /^}/ { c++; if (c>=2) exit }
' "${sfs_ps1}")"
[[ -n "${readonly_switch}" ]] || fail "bin/sfs.ps1: could not locate Invoke-SfsNativeReadonly"
for forbidden in '"team"' '"upgrade"' '"update"'; do
  if printf '%s\n' "${readonly_switch}" | grep -Eq "^[[:space:]]*${forbidden}[[:space:]]*\{"; then
    fail "bin/sfs.ps1: native readonly handler must NOT claim ${forbidden} (it must delegate to bash for team parity)"
  fi
done

# ── P1: scoop self-upgrade reload preserves --team ──────────────────────────
# Normalize-SfsScoopReloadArgs strips --yes/-y and rewrites upgrade→update, but
# must pass --team (and its value) through unchanged so `upgrade --team trio`
# survives the scoop reload hop.
norm_block="$(awk '
  /function Normalize-SfsScoopReloadArgs/ { inblk=1 }
  inblk { print }
  inblk && /^}/ { exit }
' "${sfs_ps1}")"
[[ -n "${norm_block}" ]] || fail "bin/sfs.ps1: could not locate Normalize-SfsScoopReloadArgs"
if printf '%s\n' "${norm_block}" | grep -q -- '--team'; then
  fail "bin/sfs.ps1: Normalize-SfsScoopReloadArgs must NOT special-case --team (it should pass through, preserving the preset across scoop reload)"
fi

# ── D0 degrade: 'Git Bash 필요' fallback also surfaces the team-use path ────
for f in "${install_ps1}" "${upgrade_ps1}" "${sfs_ps1}"; do
  grep -q 'requires Git Bash' "${f}" || fail "$(basename "${f}"): missing Git Bash requirement message"
  grep -q 'sfs team use' "${f}" \
    || fail "$(basename "${f}"): Git Bash fallback must surface the 'sfs team use' activation path (D0 degrade spec)"
done

# ── Bash front-door authority sanity (the SSoT the ps1 forwards into) ───────
grep -q -- '--team' "${DIST_DIR}/install.sh" || fail "install.sh: missing --team front door"
grep -q -- '--team' "${DIST_DIR}/upgrade.sh" || fail "upgrade.sh: missing --team front door"

# ── 0.8.54 (issue #9): bash-bridge POSIX PATH guarantee ─────────────────────
# team / auth / report-bug are bash-delegated, so the very bridge that reaches
# the bash core must give it Git for Windows' POSIX utils. A non-login
# `bash <script>` inherited the Windows PATH WITHOUT /usr/bin, so mktemp/dirname/
# timeout were "command not found" and every team command died before SFS logic.
# The smoke-verified fix: launch bash with `-c` (NOT `-lc` — no profile sourcing),
# prepend /usr/bin:/bin INSIDE bash, then `exec bash "$@"` to preserve the
# original script path + args. These asserts mirror the dedicated regression in
# tests/test-windows-bash-bridge-path.sh so team parity owns the contract too.
grep -Fq 'export PATH=/usr/bin:/bin:"$PATH"' "${sfs_ps1}" \
  || fail "bin/sfs.ps1: bash bridge must prepend /usr/bin:/bin ahead of \$PATH (POSIX utils for team/auth/report-bug)"
grep -Fq 'exec bash "$@"' "${sfs_ps1}" \
  || fail "bin/sfs.ps1: bash bridge must 'exec bash \"\$@\"' to preserve the original script path + args"
grep -Fq '& $bash -c $bridgePrelude "sfs" $sfsShBash @bashArgs' "${sfs_ps1}" \
  || fail "bin/sfs.ps1: bash bridge must launch via 'bash -c' with the script + args forwarded as \$@"
if grep -Eq '& \$bash -lc ' "${sfs_ps1}"; then
  fail "bin/sfs.ps1: bash bridge must use 'bash -c', never 'bash -lc' (a login shell sources user profile scripts)"
fi

echo "PASS: Windows ps1 team-activation parity (delegation contract intact)"
