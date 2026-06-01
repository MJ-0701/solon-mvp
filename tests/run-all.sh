#!/usr/bin/env bash
# tests/run-all.sh — R-D AC4.1 entry point. Runs every tests/test-*.sh and reports.
#
# Each test script:
#   - exit 0 = PASS
#   - non-zero = FAIL (record reason from stderr)
# This harness aggregates exit codes, prints summary, exits non-zero on any FAIL.
#
# 0.7.7: a per-category breakdown is appended after the existing summary.
# The flat PASS / FAIL / Failed-scripts shape is preserved so any external
# consumer (CI grep, doc reader) of the original format keeps working.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

# ── Category classifier ─────────────────────────────────────────────
#
# Mapping is filename-pattern → category, evaluated top-down (first match
# wins). Add new patterns above the catch-all when you add a test family.
# The categories themselves are chosen to surface meaningful Solon areas
# (host-channel surface, harness, review, packaging) rather than mirror
# the filesystem.
categorize() {
  local name="$1"
  case "${name}" in
    test-host-channel-docs-coverage.sh \
      | test-mcp-server-contract.sh \
      | test-solon-safe-permissions-preset.sh \
      | test-agent-build-review-lens.sh \
      | test-claude-agent-sdk-zero-template.sh \
      | test-bootstrap-template-flag.sh \
      | test-install-completion-hints.sh \
      | test-harness-host-channel-surface.sh \
      | test-polluted-adapter-hygiene-notice.sh)
      printf 'host-channel\n'
      ;;
    test-harness-*.sh | test-sfs-harness-*.sh | test-obsidian-applied-project-harness.sh)
      printf 'harness\n'
      ;;
    test-version-release-headline.sh \
      | test-docs-division-version-sync.sh \
      | test-release-*.sh \
      | test-upgrade-freshness-summary.sh)
      printf 'release\n'
      ;;
    test-packaging-*.sh \
      | test-homebrew-formula-style.sh \
      | scoop-manifest-validate.sh \
      | test-windows-*.sh)
      printf 'packaging\n'
      ;;
    test-review-*.sh \
      | test-sfs-review-*.sh \
      | test-sfs-implement-plan-review-*.sh \
      | test-postdev-review-*.sh \
      | test-runtime-token-firewall.sh \
      | test-auth-probe-liveness.sh)
      printf 'review\n'
      ;;
    test-agent-*.sh \
      | test-thin-agent-*.sh \
      | test-polluted-*.sh \
      | test-context-*.sh \
      | test-md-split-audit.sh \
      | test-context-md-split-frontmatter.sh \
      | test-status-dashboard-contract.sh \
      | test-friendly-ux-contract.sh \
      | test-design-system-anti-slop.sh)
      printf 'doc-and-context\n'
      ;;
    test-private-dev-path-hygiene.sh \
      | test-no-data-loss*.sh \
      | test-no-deprecated-cli-flags.sh \
      | test-nounset-empty-array-expansion.sh \
      | test-docs-token-diet.sh \
      | test-token-diet-*.sh \
      | test-native-language-commit-messages.sh \
      | test-readme-intro-hygiene.sh \
      | test-product-md-frontmatter-line-budget.sh \
      | test-user-facing-docs-html-first.sh \
      | test-print-matrix-schema.sh \
      | test-hash-parity.sh \
      | test-domain-knowledge-assets.sh \
      | test-enterprise-agent-team-knowledge-packs.sh \
      | test-division-subagent-continuation-guard.sh \
      | test-ddd-tdd-guardrails.sh \
      | test-mainline-data-security-guardrails.sh \
      | test-obsidian-host-local-boundary.sh \
      | test-obsidian-llm-wiki-guidance.sh \
      | test-product-identity-wiki-boundary.sh \
      | test-solon-advancement-scorecard.sh \
      | test-docs-model-routing.sh \
      | test-ai-work-intake-routing.sh \
      | test-print-matrix-schema.sh)
      printf 'hygiene-and-policy\n'
      ;;
    test-sfs-*.sh \
      | test-session-continuation-token-guard.sh \
      | test-sessions-index-retro-complete.sh \
      | test-backup-manifest-schema.sh \
      | test-bad-fixture.sh \
      | test-cli-discovery-*.sh \
      | test-gemini-bridge-model-flag-compat.sh \
      | test-rollback-from-snapshot.sh \
      | test-workflow-permissions.sh)
      printf 'sfs-core\n'
      ;;
    *)
      printf 'other\n'
      ;;
  esac
}

pass=0
fail=0
failed_tests=()

# Per-category counters via parallel arrays (bash 3.2 safe, no assoc array).
cat_keys=()
cat_pass=()
cat_fail=()

bump_category() {
  local key="$1" verdict="$2" i
  for ((i=0; i<${#cat_keys[@]}; i++)); do
    if [[ "${cat_keys[$i]}" == "${key}" ]]; then
      if [[ "${verdict}" == "PASS" ]]; then
        cat_pass[$i]=$((cat_pass[$i] + 1))
      else
        cat_fail[$i]=$((cat_fail[$i] + 1))
      fi
      return 0
    fi
  done
  cat_keys+=("${key}")
  if [[ "${verdict}" == "PASS" ]]; then
    cat_pass+=(1)
    cat_fail+=(0)
  else
    cat_pass+=(0)
    cat_fail+=(1)
  fi
}

for t in test-*.sh; do
  [[ -f "${t}" ]] || continue
  category="$(categorize "${t}")"
  printf '\n=== %s [%s] ===\n' "${t}" "${category}"
  if bash "${t}"; then
    pass=$((pass + 1))
    bump_category "${category}" PASS
    printf '  PASS\n'
  else
    fail=$((fail + 1))
    failed_tests+=("${t}")
    bump_category "${category}" FAIL
    printf '  FAIL\n'
  fi
done

printf '\n--- run-all summary ---\n'
printf '  PASS: %d\n' "${pass}"
printf '  FAIL: %d\n' "${fail}"
if [[ "${#failed_tests[@]}" -gt 0 ]]; then
  printf '  Failed scripts:\n'
  for t in "${failed_tests[@]+"${failed_tests[@]}"}"; do
    printf '    - %s\n' "${t}"
  done
fi

# 0.7.7: per-category breakdown. Sorted by descending PASS count so the
# largest categories surface first. The header line is grep-friendly
# ("by category:") so CI / reporting tools can pick it out without
# parsing the per-line format.
printf '\n  by category:\n'
if (( ${#cat_keys[@]} > 0 )); then
  for ((i=0; i<${#cat_keys[@]}; i++)); do
    printf '%s\t%d\t%d\n' "${cat_keys[$i]}" "${cat_pass[$i]}" "${cat_fail[$i]}"
  done | sort -t$'\t' -k2,2nr -k1,1 | awk -F'\t' '{
    printf "    %-20s pass=%d  fail=%d\n", $1, $2, $3
  }'
fi

if [[ "${#failed_tests[@]}" -gt 0 ]]; then
  exit 1
fi
exit 0
