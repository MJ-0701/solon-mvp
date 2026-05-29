#!/usr/bin/env bash
# tests/test-search-tooling-rg-baseline.sh — 0.7.11 contract.
#
# The search-tooling routed policy declares `rg` (ripgrep) as the agent search
# baseline and records the ast-grep / Aider PASS decision. The three router
# adapters (Claude command, Codex prompt, agents SKILL) must surface that
# baseline and must NOT recommend `grep -r` / `grep -R` directly. The policy
# doc itself stays routable and in-budget.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
POLICY_DIR="${DIST_DIR}/templates/.sfs-local-template/context/policies"
INDEX="${DIST_DIR}/templates/.sfs-local-template/context/_INDEX.md"

ADAPTERS=(
  "${DIST_DIR}/templates/.claude/commands/sfs.md"
  "${DIST_DIR}/templates/.codex/prompts/sfs.md"
  "${DIST_DIR}/templates/.agents/skills/sfs/SKILL.md"
)

fail() { echo "FAIL: $*" >&2; exit 1; }

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [ -f "${file}" ] || fail "${label}: missing file ${file}"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing '${needle}' in ${file}"
}

# ── Policy docs: routable + in-budget + decision evidence ───────────
for file in "${POLICY_DIR}/search-tooling.md" "${POLICY_DIR}/search-tooling.ko.md"; do
  [ -f "${file}" ] || fail "missing policy doc ${file}"

  lines="$(wc -l <"${file}" | tr -d '[:space:]')"
  [ "${lines}" -le 200 ] || fail "${file} exceeds the 200-line ceiling: ${lines}"

  first_line="$(sed -n '1p' "${file}")"
  [ "${first_line}" = "---" ] || fail "${file} missing opening frontmatter"
  grep -Eq '^id:' "${file}"        || fail "${file} missing id frontmatter"
  grep -Eq '^summary:' "${file}"   || fail "${file} missing summary frontmatter"
  grep -Eq '^load_when:' "${file}" || fail "${file} missing load_when frontmatter"

  # load_when must carry the search keywords the router keys on.
  load_when_line="$(grep -E '^load_when:' "${file}")"
  case "${load_when_line}" in
    *rg*) ;;     *) fail "${file} load_when missing 'rg' keyword" ;;
  esac
  case "${load_when_line}" in
    *grep*) ;;   *) fail "${file} load_when missing 'grep' keyword" ;;
  esac

  # Decision evidence: rg baseline + ast-grep / Aider recorded.
  grep -Fq 'ripgrep' "${file}" || fail "${file} missing ripgrep baseline mention"
  grep -Fiq 'ast-grep' "${file}" || fail "${file} missing ast-grep evaluation"
  grep -Fiq 'aider' "${file}" || fail "${file} missing Aider evaluation"
done

# ── Routed index registers the policy ───────────────────────────────
assert_contains "${INDEX}" "policies/search-tooling.md" "index row"
assert_contains "${INDEX}" "policies/search-tooling.ko.md" "index ko mirror"

# ── Adapters: rg baseline present, no grep -r/-R recommendation ──────
for adapter in "${ADAPTERS[@]}"; do
  [ -f "${adapter}" ] || fail "missing adapter ${adapter}"

  grep -Fq 'rg' "${adapter}" || fail "${adapter} does not mention rg baseline"
  grep -Fq 'search-tooling' "${adapter}" || fail "${adapter} does not route to search-tooling policy"

  # No direct grep -r / grep -R recommendation. The literal token "grep -r"
  # (with optional R/extra letters) must not appear as a recommended command.
  if grep -Eq 'grep[[:space:]]+-[a-zA-Z]*[rR]' "${adapter}"; then
    fail "${adapter} recommends grep -r/-R directly; route to rg instead"
  fi
done

echo "PASS: test-search-tooling-rg-baseline.sh"
