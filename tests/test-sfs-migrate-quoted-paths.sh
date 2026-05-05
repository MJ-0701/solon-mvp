#!/usr/bin/env bash
# tests/test-sfs-migrate-quoted-paths.sh — G6.1.1 V1 regression.
#
# Contract: file paths containing characters that JSON must escape (literal `"` and `\`)
# MUST survive the full migrate → recover round-trip without silent truncation.
# The pre-V1 sed regex `[^"]*` would stop at the FIRST byte after `"path":"`,
# including escaped quotes (`\"`), causing journal_replay_cleanup to skip the
# corresponding dest file and verify_no_data_loss to misreport.
#
# Test scenario:
#   1) Create tracked source files with `"` and `\` in filenames.
#   2) Run --auto migration → confirm both reach dest.
#   3) Run --recover → confirm both dests are cleaned + sources restored
#      (this is the critical assertion — pre-fix would leave dest behind).
#   4) Spot-check json_get_string helper directly via embedded awk fixture.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
MIGRATE="${DIST_DIR}/scripts/sfs-migrate-artifacts.sh"

[[ -x "${MIGRATE}" ]] || { echo "missing: ${MIGRATE}" >&2; exit 1; }

# ─── (A) Static contract — json_get_string helper present ────────────────
if ! grep -qE '^json_get_string\(\)' "${MIGRATE}"; then
  echo "V1 FAIL: json_get_string() helper not defined in sfs-migrate-artifacts.sh"
  exit 1
fi
# Pre-V1 sed pattern `"path":"([^"]*)"` MUST be replaced — fail if any `[^"]*`
# capture pattern remains in journal_replay_cleanup or verify_no_data_loss.
if awk '/^journal_replay_cleanup\(\)/,/^}/' "${MIGRATE}" | grep -qE 'sed[^|]*\[\^\"\]\*'; then
  echo "V1 FAIL: journal_replay_cleanup still uses '[^\"]*' sed extraction (escape-blind regression)"
  exit 1
fi
if awk '/^verify_no_data_loss\(\)/,/^}/' "${MIGRATE}" | grep -qE 'sed[^|]*"path":"\(\[\^\"\]\*\)"'; then
  echo "V1 FAIL: verify_no_data_loss still uses '[^\"]*' sed extraction for path (escape-blind regression)"
  exit 1
fi

# ─── (B) End-to-end — escaped-quote + backslash filenames ────────────────
tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT
cd "${tmp}"
git init -q
git config user.email t@t
git config user.name t

# POSIX permits `"` and `\` in filenames; we add literal samples plus a normal one.
mkdir -p '.sfs-local/sprints/0-5-x-quotes'
echo "normal-data"  > '.sfs-local/sprints/0-5-x-quotes/normal.md'
echo "quote-data"   > '.sfs-local/sprints/0-5-x-quotes/my"weird.md'
echo "backslash"    > '.sfs-local/sprints/0-5-x-quotes/back\slash.md'
git add -A && git commit -q -m init >/dev/null 2>&1 || true   # some FSes refuse \, allow soft-skip below

# If git couldn't track the backslash variant on this filesystem, drop it.
[[ -f '.sfs-local/sprints/0-5-x-quotes/back\slash.md' ]] || rm -f '.sfs-local/sprints/0-5-x-quotes/back\slash.md' 2>/dev/null || true

src_count_pre="$(find .sfs-local/sprints -type f | wc -l | tr -d ' ')"
[[ "${src_count_pre}" -ge 2 ]] || { echo "V1 setup FAIL: only ${src_count_pre} src files (expected ≥2)"; exit 1; }

# Apply migration.
auto_out="$(bash "${MIGRATE}" --auto --root . 2>&1)"

# Both critical files must reach dest.
[[ -f '.solon/sprints/0-5-x-quotes/default/normal.md' ]] || { echo "V1 FAIL: normal.md not migrated"; exit 1; }
if [[ ! -f '.solon/sprints/0-5-x-quotes/default/my"weird.md' ]]; then
  echo 'V1 FAIL: my"weird.md not migrated to dest (apply broke on quoted path)'
  ls -la .solon/sprints/0-5-x-quotes/default/ 2>/dev/null
  exit 1
fi

# Source files removed (apply moved them).
[[ ! -f '.sfs-local/sprints/0-5-x-quotes/my"weird.md' ]] || { echo 'V1 FAIL: src my"weird.md not removed after apply'; exit 1; }

# G6.1.2 V1 follow-up — verify_no_data_loss MUST count ALL files (including quoted).
# Pre-G6.1.2 the `grep -oE '\{"path":"[^"]*",...\}'` would silently skip entries
# whose path contained an escaped `\"`. emit_manifest_files_entries depth-tracker
# now extracts every entry regardless of escapes. Assert: files=N where N = src_count_pre.
verify_files_line="$(printf '%s' "${auto_out}" | grep '^verify_no_data_loss:' | tail -1)"
verify_count="$(printf '%s' "${verify_files_line}" | sed -nE 's/.*files=([0-9]+).*/\1/p')"
if [[ -z "${verify_count}" ]] || [[ "${verify_count}" -lt "${src_count_pre}" ]]; then
  echo "V1 FAIL: verify_no_data_loss reported files=${verify_count:-?} (expected ${src_count_pre}). emit_manifest_files_entries may still skip quoted-path entries."
  echo "  full line: ${verify_files_line}"
  exit 1
fi

# G6.1.2 — also re-run --verify-snapshot standalone against the captured manifest to
# exercise the entry-level extraction explicitly (gemini round-2 CTO action item).
snap_iso="$(find .sfs-local/archives -maxdepth 1 -name 'pre-migrate-*' -type d | head -1 | sed 's|.*pre-migrate-||')"
if [[ -n "${snap_iso}" ]]; then
  vs_out="$(bash "${MIGRATE}" --verify-snapshot "${snap_iso}" --root . 2>&1)"
  vs_count="$(printf '%s' "${vs_out}" | grep '^verify_no_data_loss:' | sed -nE 's/.*files=([0-9]+).*/\1/p' | head -1)"
  if [[ -z "${vs_count}" ]] || [[ "${vs_count}" -lt "${src_count_pre}" ]]; then
    echo "V1 FAIL: --verify-snapshot reported files=${vs_count:-?} (expected ${src_count_pre}). manifest entry extraction broken."
    echo "  full output: ${vs_out}"
    exit 1
  fi
fi

# ─── (C) --recover MUST clean BOTH dests (pre-fix would leave the quoted one) ────
bash "${MIGRATE}" --recover --root . >/dev/null 2>&1

if [[ -f '.solon/sprints/0-5-x-quotes/default/normal.md' ]]; then
  echo "V1 FAIL: normal.md dest not cleaned after --recover"; exit 1
fi
if [[ -f '.solon/sprints/0-5-x-quotes/default/my"weird.md' ]]; then
  echo 'V1 FAIL: my"weird.md dest NOT cleaned after --recover (escape-blind regex regression — journal entry truncated)'
  exit 1
fi

# Sources restored.
[[ -f '.sfs-local/sprints/0-5-x-quotes/normal.md' ]]    || { echo "V1 FAIL: normal.md src not restored"; exit 1; }
[[ -f '.sfs-local/sprints/0-5-x-quotes/my"weird.md' ]] || { echo 'V1 FAIL: my"weird.md src not restored'; exit 1; }

src_count_post="$(find .sfs-local/sprints -type f | wc -l | tr -d ' ')"
[[ "${src_count_post}" -eq "${src_count_pre}" ]] || {
  echo "V1 FAIL: src count post=${src_count_post} pre=${src_count_pre}"; exit 1
}

echo "test-sfs-migrate-quoted-paths: OK (escaped-quote + backslash filenames survive journal cleanup + verify, ${src_count_post}/${src_count_pre} src restored)"
