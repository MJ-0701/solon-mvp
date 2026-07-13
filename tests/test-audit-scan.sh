#!/usr/bin/env bash
# sfs audit — static security-audit scanner headline.
#
# Locks, against two vulnerable fixtures (vuln-node / vuln-python):
#   - OWASP-family detection across the five lenses (secret A02 / owasp
#     A03+A08 / config A05 / deps A06 / hygiene A09) with file:line
#   - secret values are ALWAYS redacted — the raw secret never appears in
#     any artifact (credential-hygiene); placeholders/env refs do not flag
#   - severity model + --severity-min filtering
#   - waiver flip via .sfs-local/audit-waivers (deterministic re-derivation)
#   - fixing code clears the finding on re-scan
#   - defensive framing: no weaponized exploit steps in output
#   - zero-LLM / zero-network static guarantee on the script
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
AUD="${DIST_DIR}/scripts/sfs-audit.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2' in $1"; }
fnot() { if grep -Fq -- "$2" "$1"; then fail "$3: unexpected '$2' in $1"; fi; }

# ── zero-LLM / zero-network guarantee (static) ───────────────────────
if grep -nE 'curl|wget|claude -p|codex exec|gemini|nc |nmap|sqlmap|metasploit' "${AUD}"; then
  fail "sfs-audit.sh must be a static offline scanner: no network/LLM/exploit tooling"
fi

TMP="$(mktemp -d "${TMPDIR:-/tmp}/sfs-audit.XXXXXX")"
trap 'rm -rf "${TMP}"' EXIT

# ── node fixture ─────────────────────────────────────────────────────
cp -R "${SCRIPT_DIR}/fixtures/audit/vuln-node" "${TMP}/vuln-node"
cd "${TMP}/vuln-node"
bash "${AUD}" scan --write >/dev/null 2>&1 || fail "node scan failed"
REP="docs/solon/vuln-node/audit/00-audit.md"
[[ -f "${REP}" ]] || fail "node audit report not written"
fhas "${REP}" "AWS access key id" "node: AWS key finding (A02)"
fhas "${REP}" "| critical |" "node: critical severity present"
fhas "${REP}" "hardcoded secret assignment" "node: hardcoded secret (A02)"
fhas "${REP}" "command execution sink" "node: command exec (A03)"
fhas "${REP}" "possible SQL injection" "node: SQL injection (A03)"
fhas "${REP}" "XSS sink" "node: XSS (A03)"
fhas "${REP}" "permissive CORS" "node: CORS (A05)"
fhas "${REP}" "dependency manifest without lockfile" "node: deps (A06)"
fhas "${REP}" "stray debug output" "node: hygiene (A09)"
# redaction: the raw secret values must NEVER appear
fnot "${REP}" "AKIAIOSFODNN7EXAMPLE" "node: AWS key value must be redacted"
fnot "${REP}" "sk_live_abcd1234efgh5678ijkl" "node: API key value must be redacted"
fhas "${REP}" "redacted" "node: redaction marker present"
# defensive framing: no weaponized language
fnot "${REP}" "payload" "node: no weaponized exploit payload in report"
fhas "${REP}" "verify/fix guidance" "node: defensive framing stated"

# ── python fixture ───────────────────────────────────────────────────
cp -R "${SCRIPT_DIR}/fixtures/audit/vuln-python" "${TMP}/vuln-python"
cd "${TMP}/vuln-python"
bash "${AUD}" scan --write >/dev/null 2>&1 || fail "python scan failed"
REP="docs/solon/vuln-python/audit/00-audit.md"
fhas "${REP}" "unsafe deserialization" "py: pickle deser (A08)"
fhas "${REP}" "TLS certificate verification disabled" "py: verify=False (A05)"
fhas "${REP}" "command execution sink" "py: subprocess shell=True (A03)"
fhas "${REP}" "debug mode enabled" "py: DEBUG=True (A05)"
fhas "${REP}" "security-flavored TODO" "py: security TODO (A09)"
fnot "${REP}" "s3cr3t-admin-pw-2024" "py: admin password must be redacted"
# env-var reference must NOT be flagged as a hardcoded secret
grep -q 'views.py:26' "${REP}" && fail "py: os.environ reference wrongly flagged as secret"

# ── severity-min filter ──────────────────────────────────────────────
out="$(bash "${AUD}" scan --severity-min high 2>&1)"
grep -q "command execution sink" <<<"${out}" || fail "severity-min high keeps high findings"
grep -q "security-flavored TODO" <<<"${out}" && fail "severity-min high must drop low findings"

# ── findings index lives under the audit dir (not .sfs-local) — invariant #4
cd "${TMP}/vuln-node"
bash "${AUD}" scan --write >/dev/null 2>&1
TSV="docs/solon/vuln-node/audit/findings.tsv"
[[ -f "${TSV}" ]] || fail "findings index must be written under docs/solon/<domain>/audit/"
[[ ! -f ".sfs-local/audit-findings.tsv" ]] || fail "findings index must NOT be written under .sfs-local (contract #4)"

# ── waiver flip + fix-clears-finding ─────────────────────────────────
mkdir -p .sfs-local
echo 'src/server.js:10|stray debug output — reviewed dev-only logger' > .sfs-local/audit-waivers
bash "${AUD}" scan --write >/dev/null 2>&1
awk -F'\t' '$1=="waived"{print $4}' "${TSV}" | grep -q 'src/server.js:10' \
  || fail "waiver must flip the finding to waived"
# fix the AWS key -> re-scan clears the critical
sed -i.bak 's/AKIAIOSFODNN7EXAMPLE/process.env.AWS_KEY/' src/handlers.js && rm -f src/handlers.js.bak
bash "${AUD}" scan --write >/dev/null 2>&1
awk -F'\t' '$1=="critical"' "${TSV}" | grep -q . \
  && fail "fixing the AWS key must clear the critical finding on re-scan"

# ── regression locks from the Codex review (negative tests) ──────────
# #1 domain traversal: an explicit --domain with ../ must be slugified, never
# escape docs/solon/
cd "${TMP}"
mkdir -p trav/src && printf 'const x=1;\n' > trav/src/a.js
cd trav
bash "${AUD}" scan --write --domain '../../escape' >/dev/null 2>&1 || true
[[ ! -e "${TMP}/escape" && ! -e "${TMP}/trav/../../escape" ]] || fail "#1 --domain must not write outside docs/solon/"
ls docs/solon/ >/dev/null 2>&1 || fail "#1 slugified domain must still write under docs/solon/"

# #3 is_test_path component match: a 'contest' dir is production, must be scanned
mkdir -p contest && printf 'const AWS="AKIAIOSFODNN7EXAMPLE";\n' > contest/pay.js
bash "${AUD}" scan --write --domain contestcase >/dev/null 2>&1
grep -q 'contest/pay.js' docs/solon/contestcase/audit/00-audit.md \
  || fail "#3 'contest' must not be treated as a test path (false negative)"

# #10 current token families: ASIA temp keys + github_pat_ fine-grained
printf 'a="ASIAIOSFODNN7EXAMPLE"\nb="github_pat_11ABCDE0123456789_abcdefghijklmnopqrstuvwx"\n' > contest/tok.js
bash "${AUD}" scan --write --domain tokcase >/dev/null 2>&1
REP2="docs/solon/tokcase/audit/00-audit.md"
grep -q 'AWS access key id' "${REP2}" || fail "#10 ASIA temporary key must be detected"
grep -q 'GitHub token' "${REP2}" || fail "#10 github_pat_ fine-grained token must be detected"
fnot "${REP2}" "ASIAIOSFODNN7EXAMPLE" "#10 ASIA value must be redacted"

echo "test-audit-scan: OK"
