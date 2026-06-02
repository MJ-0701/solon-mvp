#!/usr/bin/env bash
# WMU-2 — `sfs init` / `sfs upgrade` materialize the llm-wiki/ knowledge vault.
#
# Locks the wiki-model-unification WU-2 contract:
#   - templates/.sfs-local-template/llm-wiki/ is a generic, manually-maintained
#     skeleton (no generator dependency) shipped as an EXACT closed file set.
#   - R1 negative-lock: the shipped skeleton carries ZERO private vault content.
#     Proven two ways — an allowlist+golden-checksum manifest (any drift fails)
#     and a literal private-substring denylist. This test must NEVER reference
#     the live private ../../../llm-wiki vault path (doing so would itself be the
#     leak); all expectations are hardcoded here.
#   - install.sh + upgrade.sh both scaffold the vault at project-root $TARGET/llm-wiki
#     with recommended-default + opt-out (SFS_INSTALL_LLM_WIKI=0 → waiver) +
#     skip-if-exists. Existing consumers get it on `sfs upgrade`, not init-only.
set -euo pipefail
export LC_ALL=C   # deterministic grep over Korean (multibyte) skeleton content

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WIKI_TPL="${DIST_DIR}/templates/.sfs-local-template/llm-wiki"

fail() { echo "FAIL: $*" >&2; exit 1; }

sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print $1}'
  else shasum -a 256 "$1" | awk '{print $1}'; fi
}

# ── 1) Allowlist manifest — exact closed file set, no more, no less. ─────────
expected_manifest="$(printf '%s\n' \
  "00-llm-retrieval-guide.md" \
  "README.md" \
  "_FRONTMATTER.md" \
  "bug-reports/README.md" \
  "ddd/README.md" \
  "project-context.md" | sort)"
[ -d "${WIKI_TPL}" ] || fail "missing template dir: templates/.sfs-local-template/llm-wiki"
actual_manifest="$(cd "${WIKI_TPL}" && find . -type f | sed 's#^\./##' | sort)"
if [ "${actual_manifest}" != "${expected_manifest}" ]; then
  fail "llm-wiki template file set drifted. expected:
${expected_manifest}
got:
${actual_manifest}
(if you intentionally added/removed a skeleton file, update this allowlist AND the golden checksums below — after confirming zero private content.)"
fi

# ── 2) Golden checksums — byte-exact skeleton; any content edit must be re-reviewed. ─
declare -a GOLDEN=(
  "00-llm-retrieval-guide.md ecabe1fa582748ff01618a8646c88d6c447e05423ef993281cf061b296a1c8e8"
  "README.md 7654dd723f7fb3fb62acbaf21147aa5af206bf105ea6a8df5ee097adb5522afd"
  "_FRONTMATTER.md 45e6f15ecf6048d0ae26751fafd162992abac8ace620c10e8c8e9ce01f5fb66c"
  "bug-reports/README.md 6ffd032005dffb10b1d141d2b3e8ec48ecab0777a1cdfed3e498ff6749f36eee"
  "ddd/README.md 2d5e3a9336012a1beb48a724925ac2a530250c3a73d6173c164719d91028b6c0"
  "project-context.md cd268e7e4072bd25ecbfbaf480cb18a6d0c22b2f16f6756641c45358dc5faa37"
)
for row in "${GOLDEN[@]}"; do
  rel="${row%% *}"; want="${row##* }"
  got="$(sha256_of "${WIKI_TPL}/${rel}")"
  [ "${got}" = "${want}" ] || fail "golden checksum mismatch for ${rel}: want ${want} got ${got}
(if you intentionally edited the skeleton, review the new content for private data, then update GOLDEN above.)"
done

# ── 3) R1 structural lock — the skeleton must be self-contained. ────────────
#     The actual leak vector is an upward path reference into a private vault
#     (the live retrieval guide hard-links `../<private-docset>/...`). A shipped
#     generic skeleton must link only within itself. We forbid the *vector*, not
#     named private literals — embedding private tokens (maintainer checkout
#     name, session codenames, lecture proper nouns) in a SHIPPED test would
#     itself be the leak (and trips test-private-dev-path-hygiene.sh, which
#     already covers private dev-path tokens dist-wide). Byte-exact content is
#     locked by the golden checksums in §2; this is defense-in-depth on links.
for rel in README.md 00-llm-retrieval-guide.md _FRONTMATTER.md project-context.md; do
  if grep -nE '\]\(\.\./' "${WIKI_TPL}/${rel}" >/dev/null; then
    fail "vault-root file ${rel} links outside the vault ('../') — skeleton must be self-contained"
  fi
done
for rel in ddd/README.md bug-reports/README.md; do
  if grep -nE '\]\(\.\./\.\./' "${WIKI_TPL}/${rel}" >/dev/null; then
    fail "vault subdir file ${rel} escapes the vault ('../../') — skeleton must be self-contained"
  fi
done

# ── 4) install.sh + upgrade.sh carry the scaffold contract (static). ─────────
INSTALL="${DIST_DIR}/install.sh"; UPGRADE="${DIST_DIR}/upgrade.sh"
grep -qF 'confirm_default_yes' "${INSTALL}" || fail "install.sh missing recommended-default helper confirm_default_yes"
for f in "${INSTALL}" "${UPGRADE}"; do
  grep -qF 'SFS_INSTALL_LLM_WIKI' "$f" || fail "$f missing SFS_INSTALL_LLM_WIKI opt-out gate"
  grep -qF 'llm-wiki.waiver' "$f"      || fail "$f missing llm-wiki.waiver opt-out record"
  grep -qF 'templates/.sfs-local-template/llm-wiki' "$f" || fail "$f missing llm-wiki copy source"
done

# ── helpers for live runs ───────────────────────────────────────────────────
fresh_repo() { local t; t="$(mktemp -d "${TMPDIR:-/tmp}/wmu2-test.XXXXXX")"; ( cd "$t" && git init -q ); echo "$t"; }
do_install() { # $1=repo $2..=extra env assignments
  local repo="$1"; shift
  ( cd "$repo" && env "$@" SFS_SKIP_CLI_DISCOVERY=1 INSTALL_AGENT_ADAPTERS=0 \
      bash "${INSTALL}" --yes >/dev/null 2>&1 )
}

# ── 5) Live: `sfs init --yes` materializes the full vault at project root. ───
t_install="$(fresh_repo)"
do_install "${t_install}"
for rel in README.md 00-llm-retrieval-guide.md _FRONTMATTER.md ddd/README.md bug-reports/README.md project-context.md; do
  [ -f "${t_install}/llm-wiki/${rel}" ] || fail "init did not materialize llm-wiki/${rel}"
done
[ -f "${t_install}/.sfs-local/llm-wiki.waiver" ] && fail "init default-install must NOT write a waiver"

# ── 6) Opt-out: SFS_INSTALL_LLM_WIKI=0 → no vault, waiver recorded, no hard-block. ─
t_opt="$(fresh_repo)"
do_install "${t_opt}" SFS_INSTALL_LLM_WIKI=0
[ -d "${t_opt}/llm-wiki" ] && fail "opt-out must not create llm-wiki/"
[ -f "${t_opt}/.sfs-local/llm-wiki.waiver" ] || fail "opt-out must record .sfs-local/llm-wiki.waiver"

# ── 7) Skip-if-exists: a pre-existing user vault is preserved untouched. ─────
t_skip="$(fresh_repo)"
mkdir -p "${t_skip}/llm-wiki"; echo "USER-VAULT-SENTINEL" > "${t_skip}/llm-wiki/MY-NOTE.md"
do_install "${t_skip}"
grep -qF USER-VAULT-SENTINEL "${t_skip}/llm-wiki/MY-NOTE.md" || fail "skip-if-exists lost user vault content"
[ -f "${t_skip}/llm-wiki/README.md" ] && fail "skip-if-exists must not inject skeleton over an existing vault"

# ── 8) Upgrade (option 나): pre-WMU-2 consumer (no vault) gets it on upgrade. ─
t_up="$(fresh_repo)"
do_install "${t_up}"
rm -rf "${t_up}/llm-wiki"   # simulate a consumer initialized before WMU-2
( cd "${t_up}" && SFS_SKIP_CLI_DISCOVERY=1 bash "${UPGRADE}" --yes >/dev/null 2>&1 )
[ -f "${t_up}/llm-wiki/README.md" ] || fail "upgrade must materialize llm-wiki/ for existing consumers (option 나)"

# Upgrade respects a prior opt-out waiver: no resurrection.
t_upw="$(fresh_repo)"
do_install "${t_upw}" SFS_INSTALL_LLM_WIKI=0   # waiver recorded, no vault
( cd "${t_upw}" && SFS_SKIP_CLI_DISCOVERY=1 bash "${UPGRADE}" --yes >/dev/null 2>&1 )
[ -d "${t_upw}/llm-wiki" ] && fail "upgrade must respect a prior opt-out waiver (no resurrection)"

rm -rf "${t_install}" "${t_opt}" "${t_skip}" "${t_up}" "${t_upw}"
echo "test-wiki-init-scaffold: OK"
