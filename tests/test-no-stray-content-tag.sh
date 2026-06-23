#!/usr/bin/env bash
# 0.8.41 — stray closing-tag hygiene (regression lock).
#
# The blog/lecture absorption workflow occasionally pasted a wrapper's
# closing tag (`</content>`, `</invoke>`) into the bottom of a shipped
# Markdown surface. With no matching opening tag these are pure EOF
# litter, and they ship to consumers under templates/ and docs/.
# 0.8.41 stripped 14 such files (12 with a lone `</content>`, 2 with
# `</content>` + `</invoke>`). This test fails if any stray closing-tag
# artifact reappears in a shipped surface.
#
# Scope: the consumer-shipped Markdown surfaces only — templates/ and
# docs/. The blog-watch absorption reports legitimately *discuss* the
# tag in prose and live outside this repo, so they are not in scope.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() { echo "FAIL: $*" >&2; exit 1; }

# Stray closing tags that have no business in a shipped Markdown body.
# A line consisting solely of one of these (optional trailing space) is
# the artifact signature.
pattern='^</(content|invoke|function_calls|antml:[A-Za-z_]+|parameter)>[[:space:]]*$'

hits=""
for dir in "${DIST_DIR}/templates" "${DIST_DIR}/docs"; do
  [[ -d "${dir}" ]] || continue
  while IFS= read -r f; do
    if grep -nE "${pattern}" "${f}" >/dev/null 2>&1; then
      while IFS= read -r line; do
        hits+="${f#${DIST_DIR}/}:${line}"$'\n'
      done < <(grep -nE "${pattern}" "${f}")
    fi
  done < <(find "${dir}" -name '*.md' -type f)
done

if [[ -n "${hits}" ]]; then
  echo "Stray closing-tag artifacts found in shipped surfaces:" >&2
  printf '%s' "${hits}" >&2
  fail "shipped Markdown must not contain stray closing tags"
fi

# Positive control: the detector must actually fire on a planted artifact,
# so a future refactor of the pattern can't silently no-op.
probe="$(mktemp "${TMPDIR:-/tmp}/stray-probe.XXXXXX.md")"
trap 'rm -f "${probe}"' EXIT
printf 'real body line\n</content>\n' > "${probe}"
grep -nE "${pattern}" "${probe}" >/dev/null 2>&1 \
  || fail "detector failed to flag a planted </content> artifact"

echo "PASS: no stray closing-tag artifacts in templates/ or docs/"
