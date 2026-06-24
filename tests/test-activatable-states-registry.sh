#!/usr/bin/env bash
# Activatable-states registry meta-test (0.8.52 PART 1 / P1c).
#
# Enforces policies/zero-knowledge-activation.md as a machine invariant: any
# state SFS can detect + safely apply must be reachable via
# detect -> guide -> consent(once) -> apply, and must own an offer-path test.
#
# This meta-test reads tests/activatable-states.registry (the data enumeration)
# and FAILS run-all if any registered state lacks an existing, run-all-discovered
# offer-path test. A new activatable state added to the registry without an
# offer-path test cannot pass — that is the enforcement the policy promises.
# It cannot enumerate the universe of states (no test can), so the human gate
# for "this new feature is an activatable state -> register it" is the Gate 6
# review check in agent-build-review-lens.md §2. This locks the other half:
# once registered, the offer path must exist and be tested.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REG="${SCRIPT_DIR}/activatable-states.registry"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
POLICY="${CTX}/policies/zero-knowledge-activation.md"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "${REG}" ]]    || fail "missing activatable-states registry: ${REG}"
[[ -f "${POLICY}" ]] || fail "missing zero-knowledge-activation policy: ${POLICY}"

# ── 1) every registered state owns an existing, discoverable offer-path test ──
rows=0
while IFS='|' read -r id test desc; do
  case "${id}" in ''|\#*) continue ;; esac
  id="$(printf '%s' "${id}" | tr -d '[:space:]')"
  test="$(printf '%s' "${test}" | tr -d '[:space:]')"
  [[ -n "${test}" ]] || fail "state '${id}': no offer-path test column"
  [[ -n "${desc// /}" ]] || fail "state '${id}': missing description"
  case "${test}" in
    test-*.sh) ;;
    *) fail "state '${id}': offer-path test must be a tests/test-*.sh file (got '${test}')" ;;
  esac
  [[ -f "${SCRIPT_DIR}/${test}" ]] \
    || fail "state '${id}': offer-path test missing — tests/${test} (register the test or remove the state)"
  rows=$((rows + 1))
done < "${REG}"

# Registry must at least cover the two states this enforcement layer shipped for.
[[ "${rows}" -ge 2 ]] || fail "registry enumerates only ${rows} state(s); expected the known activatable states"

# The two seed states must be present by id (drift lock).
for must in team-topology-activation deprecated-fallback-promotion; do
  grep -Eq "^${must}\|" "${REG}" || fail "registry missing required state id: ${must}"
done

# ── 2) policy SSoT references this registry + meta-test, and is routed ─────────
grep -Fq "activatable-states.registry" "${POLICY}" \
  || fail "policy must reference tests/activatable-states.registry"
grep -Fq "test-activatable-states-registry.sh" "${POLICY}" \
  || fail "policy must reference this meta-test"
grep -Fq "policies/zero-knowledge-activation.md" "${CTX}/_INDEX.md" \
  || fail "zero-knowledge-activation policy not routed in _INDEX.md"

# ── 3) Gate 6 review lens carries the activation check (P1b) ───────────────────
grep -Fq "Zero-knowledge activation (Gate 6 check)" \
  "${CTX}/policies/agent-build-review-lens.md" \
  || fail "agent-build-review-lens.md missing the Gate 6 zero-knowledge-activation check"

echo "test-activatable-states-registry: OK (${rows} states)"
