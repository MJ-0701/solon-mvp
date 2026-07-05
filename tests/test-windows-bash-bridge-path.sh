#!/usr/bin/env bash
# tests/test-windows-bash-bridge-path.sh — 0.8.54 Windows ps1 bash-bridge POSIX
# PATH guarantee (issue #9).
#
# Bug: bin/sfs.ps1 launched the bash core as a NON-login `bash <script>`, which
# inherits the Windows PATH WITHOUT Git for Windows' <GitRoot>\usr\bin. So before
# any SFS logic ran, the watchdog's `timeout` bound to C:\Windows\System32\
# timeout.exe and `mktemp` / `dirname` were "command not found" — team / auth /
# report-bug died at bin/sfs line 110 (mktemp) / 173 (dirname). The verified
# working repro from the issue is exactly `export PATH=/usr/bin:/bin:$PATH`
# inside bash before the entrypoint runs.
#
# Fix (Approach B, leak-proof): prepend /usr/bin:/bin AHEAD of $PATH inside
# bash, then `exec bash "$@"` re-runs the real entrypoint with the original
# script path + args. The parent $env:PATH is never mutated (so repeated
# sfs.cmd calls do not grow it), and /usr/bin resolves through the Git Bash
# mount table for any install dir (and for a custom SFS_BASH / WSL).
#
# 0.8.65: the prelude ships as a packaged FILE (bin/sfs-bridge.sh) invoked as
# `bash <bridge> <script> <args>` — no `-c`, no embedded quotes. The inline
# `-c '<prelude>'` form worked under Windows PowerShell 5.1 (Legacy raw arg
# passing, real-Windows-verified) but pwsh 7.3+ Standard escaping for bash.exe
# collided with the MSYS2 command-line re-parse: the prelude swallowed the
# script + args and the bridge silently no-opped with rc 0 (scoop-smoke red
# since 0.8.54, evidence: run 28742085408).
#
# The contract is locked two ways:
#   (1) static source asserts on bin/sfs.ps1 + bin/sfs-bridge.sh that BREAK if
#       the prepend is removed, reordered behind $PATH, mutated onto the parent
#       env (leak), turned into a hard-fail, or moved back to an inline -c
#       prelude; and a guard that the workaround stays confined to the Windows
#       bridge (bin/sfs bash core untouched — the T3 non-Windows invariant).
#   (2) an executable oracle proving the PATH-ordering invariant: when /usr/bin:
#       /bin is prepended ahead of a PATH that shadows mktemp, the POSIX mktemp
#       wins and actually runs — exactly what unbricks the watchdog.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
PS1="${DIST_DIR}/bin/sfs.ps1"
SFS="${DIST_DIR}/bin/sfs"
BRIDGE="${DIST_DIR}/bin/sfs-bridge.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "${PS1}" ]] || fail "missing ${PS1}"
[[ -f "${SFS}" ]] || fail "missing ${SFS}"
[[ -f "${BRIDGE}" ]] || fail "missing ${BRIDGE} (packaged bash bridge)"
bash -n "${BRIDGE}" || fail "bin/sfs-bridge.sh must parse as bash"

# ── S1: bridge launches bash via the FILE, entrypoint + args via $@ ──────────
# `bash <bridge> <script> <args>`: only plain path/word args on the native
# command line — nothing for PS 5.1 (Legacy) vs pwsh 7 (Standard) to re-parse
# differently.
grep -Fq '& $bash $bridgeShBash $sfsShBash @bashArgs' "${PS1}" \
  || fail "S1: bridge must invoke 'bash \$bridgeShBash \$sfsShBash @bashArgs' (file bridge, script via \$@)"
grep -Fq '$sfsShBash = Convert-ToBashPath $sfsSh' "${PS1}" \
  || fail "S1: \$sfsShBash must be the bash-form entrypoint forwarded into \$@"
grep -Fq '$bridgeShBash = Convert-ToBashPath $bridgeSh' "${PS1}" \
  || fail "S1: \$bridgeShBash must be the bash-form bridge path"
# Negative: no inline `-c` prelude and no login shell on the bridge line — the
# quoted inline form is exactly the pwsh-vs-5.1 re-parse bug this fix removes.
if grep -Eq '& \$bash -l?c ' "${PS1}"; then
  fail "S1: bridge must invoke the bridge FILE, never an inline 'bash -c/-lc' prelude"
fi
if grep -Fq '$bridgePrelude' "${PS1}"; then
  fail "S1: no inline \$bridgePrelude may remain in bin/sfs.ps1 (moved to bin/sfs-bridge.sh)"
fi

# ── S2: the bridge prepends /usr/bin:/bin AHEAD of $PATH (POSIX-first) ────────
# The exact ordering is the whole fix: /usr/bin:/bin must come BEFORE "$PATH" so
# POSIX timeout/mktemp/dirname beat C:\Windows\System32\timeout.exe et al.
grep -Fq 'export PATH=/usr/bin:/bin:"$PATH"' "${BRIDGE}" \
  || fail "S2: bridge must 'export PATH=/usr/bin:/bin:\"\$PATH\"' (POSIX dirs FIRST)"
# Negative: the POSIX dirs must NOT be appended behind $PATH (that loses to the
# Windows timeout.exe and re-bricks the watchdog).
if grep -Eq 'export PATH="?\$PATH"?:/usr/bin' "${BRIDGE}"; then
  fail "S2: POSIX dirs must be PREPENDED, not appended behind \$PATH"
fi

# ── S3: leak-proof — the parent $env:PATH is NEVER mutated ───────────────────
# Approach A (mutate $env:PATH in PowerShell) would leak into the in-process
# ps1-shim session and grow PATH unbounded across calls. Assert no such write.
if grep -Eq '\$env:PATH[[:space:]]*=' "${PS1}"; then
  fail "S3: bridge must not assign \$env:PATH (leaks into the session / grows PATH per call)"
fi

# ── S4: warn-only diagnostic, never a hard-fail ──────────────────────────────
# A genuinely incomplete Git for Windows gets a recovery hint, but an install
# that already works (PATH correct, WSL, custom bash) must be left untouched —
# so the probe uses `||` + printf to stderr and STILL `exec bash`, no exit.
grep -Fq 'command -v mktemp >/dev/null 2>&1 ||' "${BRIDGE}" \
  || fail "S4: bridge must probe mktemp with a warn-only '|| printf ...' guard"
grep -Fq 'exec bash "$@"' "${BRIDGE}" \
  || fail "S4: bridge must 'exec bash \"\$@\"' (script+args via \$@) after the warn-only probe"
# The bridge must not `exit` on the probe (which would hard-fail a working
# install) — executable statements are the non-comment lines only.
if grep -Ev '^[[:space:]]*#' "${BRIDGE}" | grep -Eq '(^|[;[:space:]])exit([[:space:]]|$)'; then
  fail "S4: bridge must be warn-only — no 'exit' statement in bin/sfs-bridge.sh"
fi

# ── S5: the POSIX-PATH workaround stays confined to the ps1 wrapper ──────────
# Non-Windows path is byte-for-byte unchanged: the fix must live ONLY in the
# Windows wrapper, never in the shared bash core (bin/sfs).
if grep -Fq 'export PATH=/usr/bin:/bin' "${SFS}"; then
  fail "S5: bin/sfs (bash core) must NOT carry the /usr/bin:/bin prepend — Windows-wrapper-only fix"
fi

# ── L1 oracle: PATH-ordering invariant, executable ───────────────────────────
# Find a real POSIX dir that provides mktemp on this host (the stand-in for Git
# for Windows' /usr/bin). Skip cleanly if the host lacks one.
posix_dir=""
for d in /usr/bin /bin; do
  if [[ -x "${d}/mktemp" ]]; then posix_dir="${d}"; break; fi
done
if [[ -z "${posix_dir}" ]]; then
  echo "SKIP L1: host has no /usr/bin|/bin mktemp to stand in for Git usr\\bin"
else
  shadow="$(command mktemp -d)"
  trap 'rm -rf "${shadow}"' EXIT
  # A broken `mktemp` on PATH, mimicking the Windows session where the only
  # resolvable utils are the wrong ones (or none).
  cat > "${shadow}/mktemp" <<'EOF'
#!/bin/sh
echo "BROKEN-SHADOW-MKTEMP" >&2
exit 99
EOF
  chmod +x "${shadow}/mktemp"

  # NOTE: set PATH INSIDE /bin/sh (absolute), not as a `PATH=x sh` prefix — a
  # prefix assignment also governs the lookup of `sh` itself, which would make
  # `sh` unfindable under the degraded PATH and void the test.
  # Degraded PATH (POSIX dir absent) → the shadow wins (the bug).
  got_broken="$(SHADOW="${shadow}" /bin/sh -c 'PATH="$SHADOW"; command -v mktemp' 2>/dev/null || true)"
  [[ "${got_broken}" == "${shadow}/mktemp" ]] \
    || fail "L1: precondition — degraded PATH should resolve mktemp to the shadow, got '${got_broken}'"

  # Apply the prelude's ordering: POSIX dirs FIRST → the real mktemp wins and runs.
  resolved="$(SHADOW="${shadow}" PD="${posix_dir}" /bin/sh -c 'PATH="$PD:$SHADOW"; command -v mktemp')"
  [[ "${resolved}" == "${posix_dir}/mktemp" ]] \
    || fail "L1: prepend must make the POSIX mktemp win, got '${resolved}'"
  out="$(SHADOW="${shadow}" PD="${posix_dir}" /bin/sh -c 'PATH="$PD:$SHADOW"; f=$(mktemp) && printf OK && rm -f "$f"' 2>/dev/null || true)"
  [[ "${out}" == "OK" ]] \
    || fail "L1: POSIX mktemp must actually run under the prepended PATH (got '${out}')"
fi

echo "PASS: $(basename "$0")"
