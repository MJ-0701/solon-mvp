#!/usr/bin/env bash
# tests/test-no-deprecated-cli-flags.sh
#
# 0.6.3 regression: 0.6.1 ship had `brew audit --new-formula` baked into
# `scripts/sfs-release-sequence.sh`, which Homebrew has since removed. The
# command exits with `Error: invalid option: --new-formula` and the audit
# phase fails for any user driving a real release.
#
# This test asserts deprecated external-CLI flags are not silently
# reintroduced into scripts/. CHANGELOG history is *intentionally* not
# scanned — historical release notes legitimately reference the old flag.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() { echo "FAIL: $*" >&2; exit 1; }

# Forbidden patterns. Each entry: <pattern> | <human readable reason>.
forbidden=(
  '--new-formula|brew removed --new-formula; use --strict --online for tap audit, or --new only for Homebrew core submission'
)

scan_root="${DIST_DIR}/scripts"
[[ -d "${scan_root}" ]] || fail "scan root missing: ${scan_root}"

for entry in "${forbidden[@]}"; do
  pattern="${entry%%|*}"
  reason="${entry#*|}"
  # Scan all .sh files under scan_root. Skip pure-comment lines (first
  # non-blank char `#`) so explanatory documentation can legitimately
  # reference deprecated flags by name without tripping the guard.
  hits=""
  while IFS= read -r -d '' f; do
    while IFS=: read -r ln body; do
      [[ -n "${ln}" ]] || continue
      # Strip leading whitespace; skip lines starting with `#`.
      stripped="${body#"${body%%[![:space:]]*}"}"
      [[ "${stripped:0:1}" == "#" ]] && continue
      hits+="${f}:${ln}:${body}"$'\n'
    done < <(grep -nF -- "${pattern}" "${f}" 2>/dev/null || true)
  done < <(find "${scan_root}" -type f -name '*.sh' -print0 2>/dev/null)
  if [[ -n "${hits}" ]]; then
    fail "deprecated flag '${pattern}' reappeared in scripts/:
${hits}  reason: ${reason}"
  fi
done

# 0.6.4 regression: Homebrew also disabled `brew audit [path ...]`. The
# pre-publish path-based check in scripts/sfs-release-sequence.sh must use
# `brew style` (path-friendly RuboCop linter), not `brew audit` against a
# path variable.
seq_script="${DIST_DIR}/scripts/sfs-release-sequence.sh"
if [[ -f "${seq_script}" ]]; then
  # Negative: `brew audit "${formula}"` (or any `brew audit` followed by a
  # quoted variable expansion) signals the dead path-based form. Comments
  # are allowed to mention it for documentation purposes — the check is
  # restricted to non-comment shell content via grep -v on lines whose
  # first non-blank char is `#`.
  body=$(grep -vE '^[[:space:]]*#' "${seq_script}" 2>/dev/null || true)
  if grep -qE 'brew audit[[:space:]]+(--[a-z-]+[[:space:]]+)*"\$\{' <<<"${body}"; then
    fail "brew audit invoked with a quoted-variable argument in
  ${seq_script}
  reason: Homebrew disabled \`brew audit [path ...]\`. Use \`brew style \"\${formula}\"\` for pre-publish path-based check, or \`brew audit --strict --online <name>\` after tap-update against the installed tap."
  fi

  # Positive: `brew style` should be present at the audit phase.
  if ! grep -qE 'brew style[[:space:]]+' "${seq_script}"; then
    fail "scripts/sfs-release-sequence.sh missing \`brew style ...\` invocation
  reason: 0.6.4 fix replaced path-based brew audit with brew style at the audit phase. Restore it."
  fi
fi

echo "test-no-deprecated-cli-flags: OK"
