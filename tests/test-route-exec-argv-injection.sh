#!/usr/bin/env bash
# sfs route real-exec injection lock (Hermes P3 security precondition).
#
# Before P3 wired real headless dispatch, sfs-route.sh executed the resolved
# command with `eval` over an interpolated string — a capsule whose goal carried
# `$(...)` / backticks would have run as shell. P3 replaced that with an argv
# ARRAY ("${cmd_arr[@]}"), so capsule text is inert data. This test drives the
# REAL exec path (not dry-run) against a mock runtime and proves:
#   - a `$(touch PWNED)` / backtick payload in the capsule goal does NOT execute;
#   - the payload reaches the runtime as ONE literal argv element.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ROUTE="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-route.sh"
TEAM="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-team.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

# Static guard: the real-exec path must not eval (defense in depth beyond the
# dynamic test below).
grep -Eq 'eval[[:space:]]+"\$\{cmd' "${ROUTE}" && fail "sfs-route.sh still evals the interpolated command string"
grep -Fq '"${cmd_arr[@]}"' "${ROUTE}" || fail "sfs-route.sh real exec is not an argv array"

TMP="$(mktemp -d "${TMPDIR:-/tmp}/sfs-route-inj.XXXXXX")"
cleanup() { rm -rf "${TMP}"; }
trap cleanup EXIT

PWN="${TMP}/PWNED"
ARGV_OUT="${TMP}/argv.out"

# Mock runtime: record each argv element verbatim, then exit 0. Executing this at
# all proves the array ran; the recorded args prove what it received.
mkdir -p "${TMP}/bin"
cat > "${TMP}/bin/sfsmockcli" <<EOF
#!/usr/bin/env bash
: > "${ARGV_OUT}"
for a in "\$@"; do printf '%s\n' "\$a" >> "${ARGV_OUT}"; done
exit 0
EOF
chmod +x "${TMP}/bin/sfsmockcli"

# Minimal model-profiles binding a role to the mock runtime (argv transport).
MP="${TMP}/model-profiles.yaml"
cat > "${MP}" <<'EOF'
team_preset: pair
configuration:
  selected_runtime: mockcli
runtime_registry:
  mockcli:
    invoke: "sfsmockcli {prompt} {tools}"
    transport_kind: argv
agent_runtime_bindings:
  worker: mockcli
EOF
[[ "$(SFS_MODEL_PROFILES="${MP}" bash "${TEAM}" resolve-invoke mockcli)" == "sfsmockcli {prompt} {tools}" ]] \
  || fail "setup: mock invoke not resolved"

# Capsule whose goal carries a command-substitution + backtick payload.
CAP="${TMP}/capsule.yaml"
cat > "${CAP}" <<EOF
goal: pwn \$(touch ${PWN}) and \`touch ${PWN}\` end
tools_allowed: read
EOF

# REAL exec (no dry-run). Mock is on PATH.
PATH="${TMP}/bin:${PATH}" SFS_MODEL_PROFILES="${MP}" bash "${ROUTE}" worker "${CAP}" >/dev/null 2>&1 \
  || fail "route real-exec returned non-zero against the mock"

# 1) the payload must NOT have executed.
[[ ! -e "${PWN}" ]] || fail "INJECTION: capsule goal '\$(touch ...)' executed as shell (argv array breached)"

# 2) the payload reached the runtime as one literal argv element.
[[ -f "${ARGV_OUT}" ]] || fail "mock runtime was not invoked"
grep -Fq '$(touch' "${ARGV_OUT}" || fail "payload not passed through literally (expected inert data)"
grep -Fq '`touch' "${ARGV_OUT}" || fail "backtick payload not passed through literally"

echo "test-route-exec-argv-injection: OK"
