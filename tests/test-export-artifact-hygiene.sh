#!/usr/bin/env bash
# WU-A standalone export-artifact hygiene lock (solon-product side).
#
# The authoritative drift check (artifact == normalize(wiki source)) lives in
# the dev docset, where the wiki and the dev product are co-located. This repo
# ships without a wiki, so it can only enforce the cheap, wiki-free invariant:
# every checked-in EXPORT artifact (a routed policy generated from a
# wiki concept note) must carry the do-not-hand-edit banner + generated_from +
# generated_at, so hand edits are visible in review.
#
# WU-A note (decision#1 = β): no category-2 concept note ships today
# (glossary / ubiquitous-language are raw-internal; taxonomy / ontology stay
# routed operating packs). So 0 export artifacts are expected right now — this
# lock passes vacuously but is WIRED, and activates the moment the first
# generated artifact lands.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
POLICIES="${DIST_DIR}/templates/.sfs-local-template/context/policies"
BANNER_MARK="DO NOT HAND-EDIT"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -d "${POLICIES}" ]] || fail "policies dir missing: ${POLICIES}"

# An export artifact is any policy whose frontmatter declares generated_from.
# (while-read, not mapfile — portable to macOS bash 3.2.)
artifacts=()
while IFS= read -r f; do
  [[ -n "${f}" ]] && artifacts+=("${f}")
done < <(grep -rl --include='*.md' '^generated_from:' "${POLICIES}" 2>/dev/null | sort)

if [[ ${#artifacts[@]} -eq 0 ]]; then
  echo "ok: 0 generated export artifacts present (WU-A β: no cat-2 concept note ships yet). Lock wired."
  echo "PASS: export-artifact-hygiene"
  exit 0
fi

# Private-path markers, assembled at runtime so the literal docset token never
# appears in this file's source (which would itself trip the private-dev-path
# hygiene lock). Covers absolute paths + the dev docset checkout name.
priv_marker="agent""_architect"
for f in "${artifacts[@]}"; do
  grep -Fq -- "${BANNER_MARK}" "${f}" || fail "${f}: export artifact missing do-not-hand-edit banner"
  grep -q '^generated_from:' "${f}" || fail "${f}: missing generated_from key"
  grep -q '^generated_at:' "${f}" || fail "${f}: missing generated_at key"
  # generated_from / any line must be repo-relative — no absolute or private path.
  grep -q '/Users/' "${f}" && fail "${f}: absolute path leaked into export artifact (generated_from must be repo-relative)"
  grep -Fq "${priv_marker}" "${f}" && fail "${f}: private dev docset name leaked into export artifact"
  echo "ok: ${f#"${DIST_DIR}/"} carries banner + generated_from + generated_at, no path leak"
done

echo "PASS: export-artifact-hygiene (${#artifacts[@]} artifact(s))"
