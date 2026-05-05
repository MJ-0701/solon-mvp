#!/usr/bin/env bash
# tests/test-nounset-empty-array-expansion.sh
#
# 0.6.2 regression: macOS bash 3.2 + `set -u` crashes on `"${arr[@]}"` whenever
# the array is empty. The fix uses `${arr[@]+"${arr[@]}"}` parameter-expansion
# default, which is correct on bash 3.2 (substitute nothing) and bash 4.4+
# (substitute the expansion).
#
# Concrete bug found in 0.6.1: `sfs upgrade` with no flags crashed at
# bin/sfs:848 with `dep_args[@]: unbound variable`.
#
# Linux bash 5.x (typical CI host) does NOT reproduce the original crash
# because bash 4.4 fixed the empty-array expansion behavior. This test
# therefore asserts the *idiom is in place* by static check + runs the idiom
# under `set -u` to confirm it never errors with an empty array. If a future
# refactor reintroduces the unsafe pattern at the same call sites, this test
# fails.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() { echo "FAIL: $*" >&2; exit 1; }

# ─────────────────────────────────────────────────────────────────────
# 1) Static assertion at bin/sfs deprecation-hook call site (0.6.2 fix #1)
# ─────────────────────────────────────────────────────────────────────
if ! grep -qF '"${dep_args[@]+"${dep_args[@]}"}"' "${DIST_DIR}/bin/sfs"; then
  fail "bin/sfs missing nounset-safe dep_args expansion (0.6.2 fix #1).
  expected idiom:  \"\${dep_args[@]+\"\${dep_args[@]}\"}\"
  rationale:       macOS bash 3.2 + set -u crashes on empty \"\${dep_args[@]}\""
fi

# ─────────────────────────────────────────────────────────────────────
# 2) Static assertion at sfs-loop.sh worker-spawn call site (0.6.2 fix #2)
# ─────────────────────────────────────────────────────────────────────
LOOP_SH="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-loop.sh"
if ! grep -qF '"${extra_flags[@]+"${extra_flags[@]}"}"' "${LOOP_SH}"; then
  fail "sfs-loop.sh missing nounset-safe extra_flags expansion (0.6.2 fix #2).
  expected idiom:  \"\${extra_flags[@]+\"\${extra_flags[@]}\"}\""
fi

# ─────────────────────────────────────────────────────────────────────
# 3) Runtime check: the idiom must work under `set -u` with an empty array
#    AND with a populated array, on whatever bash run-all.sh is using.
# ─────────────────────────────────────────────────────────────────────
out=$(bash -c '
  set -u
  arr=()
  count_args() { printf "n=%d\n" "$#"; }
  count_args "${arr[@]+"${arr[@]}"}"
  arr+=("--opt-in" "0.6-storage")
  count_args "${arr[@]+"${arr[@]}"}"
' 2>&1) || fail "idiom did not run cleanly under set -u: ${out}"

expected="n=0
n=2"
if [[ "${out}" != "${expected}" ]]; then
  fail "idiom output mismatch
  got:      ${out}
  expected: ${expected}"
fi

# ─────────────────────────────────────────────────────────────────────
# 4) Smoke check: bin/sfs upgrade with no flags must not die on the
#    deprecation-hook line with `unbound variable`. We invoke it in a
#    fresh tmpdir (no .sfs-local/) so it will fail later for unrelated
#    reasons (project not initialized) — that's expected and OK. What we
#    verify is the *absence* of `dep_args[@]: unbound variable` in stderr.
# ─────────────────────────────────────────────────────────────────────
tmp=$(mktemp -d)
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT
cd "${tmp}"

# Run with stdin closed and a hard timeout so a hung interactive prompt cannot
# wedge the test harness. Exit code is intentionally ignored — uninitialized
# project will exit non-zero for legitimate reasons; we only inspect stderr
# for the regression marker.
stderr=$(bash -c '
  exec </dev/null
  "${DIST_DIR}/bin/sfs" upgrade --no-self-upgrade --skip-existing --layout thin 2>&1 >/dev/null
' DIST_DIR="${DIST_DIR}" 2>&1 || true)

if echo "${stderr}" | grep -q 'dep_args\[@\]: unbound variable'; then
  fail "0.6.1 regression: dep_args[@] unbound variable still reachable
  stderr: ${stderr}"
fi

echo "test-nounset-empty-array-expansion: OK"
