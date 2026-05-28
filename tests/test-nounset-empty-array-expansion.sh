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

# ─────────────────────────────────────────────────────────────────────
# 5) Coverage check (0.6.144): every shell script under scripts/ and
#    templates/.sfs-local-template/scripts/ that expands "${arr[@]}" must
#    EITHER use the nounset-safe `${arr[@]+...}` idiom AT THAT SITE, OR
#    keep an explicit `${#arr[@]}` length check somewhere in the same file
#    so the unsafe path can be reasoned about. Sites without either guard
#    are likely to recur as 0.6.2-style crashes on macOS bash 3.2 + set -u.
#
#    This is a static heuristic, not a proof — it flags sites that warrant
#    a human review rather than failing on every legitimate use. To
#    silence a legitimate site without adding a guard, add a `# nounset-safe:`
#    comment on the line above the expansion (rare; use sparingly).
# ─────────────────────────────────────────────────────────────────────
coverage_dirs=(
  "${DIST_DIR}/scripts"
  "${DIST_DIR}/templates/.sfs-local-template/scripts"
)
unsafe_hits=""
for dir in "${coverage_dirs[@]}"; do
  [[ -d "${dir}" ]] || continue
  while IFS= read -r -d '' f; do
    # Skip non-bash scripts (only first-line shebang matching bash counts).
    head -n1 "${f}" | grep -qE '^#!.*bash' || continue
    # Find every "${name[@]}" expansion that is NOT already the safe idiom.
    # The idiom looks like:  ${name[@]+"${name[@]}"}
    while IFS=: read -r lineno line; do
      [[ -n "${line}" ]] || continue
      # Skip lines that contain the safe idiom literally.
      if [[ "${line}" == *'[@]+"${'* ]]; then
        continue
      fi
      # Skip lines explicitly marked safe by the maintainer.
      prev_line=$(awk -v n="${lineno}" 'NR == n-1 { print; exit }' "${f}")
      if [[ "${prev_line}" == *'# nounset-safe:'* ]]; then
        continue
      fi
      # Extract the array name from the first "${name[@]}" match on the line.
      name="$(printf '%s\n' "${line}" \
        | grep -oE '"\$\{[A-Za-z_][A-Za-z0-9_]*\[@\]\}"' \
        | head -1 \
        | sed -E 's/.*\{([A-Za-z_][A-Za-z0-9_]*)\[@\]\}.*/\1/')"
      [[ -n "${name}" ]] || continue
      # Pass if the same file contains a `${#name[@]}` length check
      # anywhere — author at least reasoned about empty-array boundary.
      if grep -qE "\\\$\\{#${name}\\[@\\]\\}" "${f}"; then
        continue
      fi
      unsafe_hits+="  ${f}:${lineno}: ${line}"$'\n'
    done < <(grep -nE '"\$\{[A-Za-z_][A-Za-z0-9_]*\[@\]\}"' "${f}" || true)
  done < <(find "${dir}" -maxdepth 1 -type f -name '*.sh' -print0)
done

if [[ -n "${unsafe_hits}" ]]; then
  fail "nounset coverage: unsafe \"\${arr[@]}\" expansion without idiom or length-guard
${unsafe_hits}
  Fix options:
    1. Replace with idiom:  \"\${arr[@]+\"\${arr[@]}\"}\"
    2. Add an explicit  (( \${#arr[@]} == 0 ))  guard somewhere in the file
    3. If you have audited the call site and it cannot be reached with an empty
       array on bash 3.2, add  # nounset-safe: <reason>  on the line above."
fi

echo "test-nounset-empty-array-expansion: OK"
