#!/usr/bin/env bash
# tests/test-sfs-measure-alive.sh — R-D AC-perf-5 alive heartbeat test.
#
# Uses SFS_ALIVE_THRESHOLD_SECS=2 + 3-second wrapped sleep to force at least one
# `[alive] still in step:` stderr emit without inflating run-all.sh runtime.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCRIPT="${DIST_DIR}/scripts/sfs-measure.sh"

[[ -x "${SCRIPT}" ]] || { echo "missing: ${SCRIPT}" >&2; exit 1; }

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT

stderr_log="${tmp}/stderr.log"

# Wrapped sleep 3 with threshold 2 → at least one alive emit.
set +e
SFS_ALIVE_THRESHOLD_SECS=2 bash "${SCRIPT}" --alive --step "test-step" -- sleep 3 2>"${stderr_log}"
rc=$?
set -e

[[ "${rc}" == "0" ]] || { echo "FAIL: wrapped sleep returned non-zero rc=${rc}" >&2; cat "${stderr_log}" >&2; exit 1; }

if ! grep -q '\[alive\] still in step: test-step' "${stderr_log}"; then
  echo "FAIL: no [alive] emit detected (threshold=2, sleep=3)" >&2
  cat "${stderr_log}" >&2
  exit 1
fi

# Forwards wrapped command's exit code unchanged.
set +e
SFS_ALIVE_THRESHOLD_SECS=300 bash "${SCRIPT}" --alive --step exit-code-test -- bash -c 'exit 7' 2>/dev/null
rc=$?
set -e
[[ "${rc}" == "7" ]] || { echo "FAIL: exit-code forwarding broken, expected 7 got ${rc}" >&2; exit 1; }

# --timer (DEFER 0.6.1+) must reject.
set +e
SFS_ALIVE_THRESHOLD_SECS=300 bash "${SCRIPT}" --timer -- echo nope 2>/dev/null
rc=$?
set -e
[[ "${rc}" == "2" ]] || { echo "FAIL: --timer should reject with exit 2 (DEFER), got ${rc}" >&2; exit 1; }

# --token (DEFER 0.6.1+) must reject.
set +e
SFS_ALIVE_THRESHOLD_SECS=300 bash "${SCRIPT}" --token -- echo nope 2>/dev/null
rc=$?
set -e
[[ "${rc}" == "2" ]] || { echo "FAIL: --token should reject with exit 2 (DEFER), got ${rc}" >&2; exit 1; }

# Missing --alive flag → exit 2.
set +e
SFS_ALIVE_THRESHOLD_SECS=300 bash "${SCRIPT}" -- echo nope 2>/dev/null
rc=$?
set -e
[[ "${rc}" == "2" ]] || { echo "FAIL: missing --alive should exit 2, got ${rc}" >&2; exit 1; }

# --alive without wrapped command → exit 2.
set +e
bash "${SCRIPT}" --alive 2>/dev/null
rc=$?
set -e
[[ "${rc}" == "2" ]] || { echo "FAIL: --alive without wrapped command should exit 2, got ${rc}" >&2; exit 1; }

# Signal cleanup must be armed before child spawn, and watcher cleanup must own
# its foreground sleep so TERM cannot leave a sleep process behind until threshold.
trap_line="$(awk '/exit 130/ {print NR; exit}' "${SCRIPT}")"
spawn_line="$(awk '/REMAINING/ && /&/ {print NR; exit}' "${SCRIPT}")"
[[ -n "${trap_line}" && -n "${spawn_line}" && "${trap_line}" -lt "${spawn_line}" ]] \
  || { echo "FAIL: INT/TERM trap should be registered before wrapped command spawn" >&2; exit 1; }
grep -q 'sleep_pid=' "${SCRIPT}" \
  || { echo "FAIL: watcher should track sleep_pid" >&2; exit 1; }
grep -q 'kill "${sleep_pid}"' "${SCRIPT}" \
  || { echo "FAIL: watcher signal trap should kill sleep_pid" >&2; exit 1; }

# Runtime signal smoke: TERM wrapper, expect 130 and wrapped child gone.
child_pid_file="${tmp}/child.pid"
set +e
SFS_ALIVE_THRESHOLD_SECS=300 bash "${SCRIPT}" --alive --step signal-test -- \
  bash -c 'printf "%s\n" "$$" >"$1"; exec sleep 20' _ "${child_pid_file}" 2>"${tmp}/signal.err" &
wrapper_pid=$!
set -e
for _ in 1 2 3 4 5 6 7 8 9 10; do
  [[ -s "${child_pid_file}" ]] && break
  sleep 0.1
done
[[ -s "${child_pid_file}" ]] \
  || { echo "FAIL: wrapped child pid file not created" >&2; cat "${tmp}/signal.err" >&2; kill "${wrapper_pid}" 2>/dev/null || true; exit 1; }
child_pid="$(cat "${child_pid_file}")"
set +e
kill -TERM "${wrapper_pid}"
wait "${wrapper_pid}"
rc=$?
set -e
[[ "${rc}" == "130" ]] \
  || { echo "FAIL: TERM cleanup should exit 130, got ${rc}" >&2; cat "${tmp}/signal.err" >&2; kill "${child_pid}" 2>/dev/null || true; exit 1; }
if kill -0 "${child_pid}" 2>/dev/null; then
  sleep 0.2
  if kill -0 "${child_pid}" 2>/dev/null; then
    kill "${child_pid}" 2>/dev/null || true
    echo "FAIL: TERM cleanup left wrapped child alive" >&2
    exit 1
  fi
fi

echo "test-sfs-measure-alive: OK"
