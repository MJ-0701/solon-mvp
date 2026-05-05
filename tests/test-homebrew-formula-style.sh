#!/usr/bin/env bash
# tests/test-homebrew-formula-style.sh
#
# 0.6.5 regression: `brew style packaging/homebrew/sfs.rb` failed on 0.6.4
# with 9 offenses — 6 real style/structure problems (sigils, frozen literal,
# class doc, components order, livecheck regex extension) plus 3 noise
# offenses caused by the cut-release sha256 placeholder. This test asserts
# the file-level fixes are in place and that the audit phase skips brew
# style when the placeholder is still present.
#
# We don't invoke `brew style` here — Linux CI commonly has no Homebrew. The
# checks below are static (grep) so they run on any host.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() { echo "FAIL: $*" >&2; exit 1; }

# Files under audit. Both must satisfy the universal style rules; only sfs.rb
# carries version/sha256/livecheck and so gets the additional checks.
universal_files=(
  "${DIST_DIR}/packaging/homebrew/sfs.rb"
  "${DIST_DIR}/packaging/homebrew/sfs.rb.template"
)

for f in "${universal_files[@]}"; do
  [[ -f "${f}" ]] || fail "missing formula file: ${f}"

  # Sorbet sigil. Either `# typed: false`, `# typed: true`, or
  # `# typed: strict` is acceptable; the cop fails only on absence.
  if ! grep -qE '^# typed: (false|true|strict|ignore)' "${f}"; then
    fail "${f}: missing Sorbet sigil (e.g. \`# typed: false\`).
  rationale: Sorbet/StrictSigil and Sorbet/TrueSigil cops require it."
  fi

  # Frozen string literal magic comment.
  if ! grep -qE '^# frozen_string_literal: true' "${f}"; then
    fail "${f}: missing \`# frozen_string_literal: true\`.
  rationale: Style/FrozenStringLiteralComment cop requires it."
  fi

  # Class documentation comment immediately above `class Sfs`.
  # We allow any comment line whose content is non-trivial (not just `#` alone)
  # right above the class line.
  class_line=$(grep -nE '^class Sfs' "${f}" | head -1 | cut -d: -f1)
  if [[ -z "${class_line}" ]]; then
    fail "${f}: \`class Sfs < Formula\` not found"
  fi
  prev_line=$((class_line - 1))
  if (( prev_line < 1 )); then
    fail "${f}: no room for class doc comment above \`class Sfs\`"
  fi
  prev_content=$(sed -n "${prev_line}p" "${f}")
  if ! echo "${prev_content}" | grep -qE '^# .+'; then
    fail "${f}: missing class doc comment immediately above \`class Sfs\` (line ${prev_line})
  current line ${prev_line}: ${prev_content}
  rationale: Style/Documentation cop requires a YARD-style class comment."
  fi

  if ! grep -qF '.gitattributes' "${f}" || ! grep -qF '.github' "${f}"; then
    fail "${f}: formula install must preserve release-root dotfiles/directories.
  rationale: Homebrew installs otherwise drop .gitattributes/.github, making installed verification tests fail."
  fi

  if grep -qE '^[[:space:]]*def[[:space:]]+post_install' "${f}"; then
    fail "${f}: Homebrew formula must not run project/user-home discovery from post_install.
  rationale: post_install can block or mutate host CLI config during brew install/reinstall; keep adapter setup explicit."
  fi
done

# sfs.rb-specific structural checks.
sfs_rb="${DIST_DIR}/packaging/homebrew/sfs.rb"
version_line=$(grep -nE '^[[:space:]]*version[[:space:]]+' "${sfs_rb}" | head -1 | cut -d: -f1 || true)
sha256_line=$(grep -nE '^[[:space:]]*sha256[[:space:]]+' "${sfs_rb}" | head -1 | cut -d: -f1 || true)
if [[ -n "${version_line}" && -n "${sha256_line}" ]]; then
  if (( version_line >= sha256_line )); then
    fail "sfs.rb: \`version\` (line ${version_line}) must come before \`sha256\` (line ${sha256_line}).
  rationale: FormulaAudit/ComponentsOrder cop."
  fi
fi

# Livecheck regex must use \.t (or broader), not the literal \.tar\.gz.
if grep -qE 'regex\(/.*\\\.tar\\\.gz' "${sfs_rb}"; then
  fail "sfs.rb: livecheck regex still uses \\.tar\\.gz literally.
  rationale: FormulaAudit/LivecheckRegexExtension wants \\.t to match both .tar.gz and .tgz mirrors."
fi

# Audit phase must skip brew style when the formula carries the placeholder.
seq_script="${DIST_DIR}/scripts/sfs-release-sequence.sh"
if [[ -f "${seq_script}" ]]; then
  body=$(grep -vE '^[[:space:]]*#' "${seq_script}" 2>/dev/null || true)
  if ! grep -qF '__SHA256_PLACEHOLDER_FOR_RELEASE_CUT__' <<<"${body}"; then
    fail "${seq_script}: audit phase no longer detects the cut-release sha256 placeholder.
  rationale: 0.6.5 fix added a placeholder skip so brew style isn't run on a template (which would fail with 3 sha256-shape errors)."
  fi
fi

echo "test-homebrew-formula-style: OK"
