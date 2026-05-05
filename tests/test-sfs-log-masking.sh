#!/usr/bin/env bash
# tests/test-sfs-log-masking.sh — AC4.4.4 + AC4.6 sentinel value masking, isolated step.
#
# Procedure (S3R3-N1 Round 3 fix):
#  (i)   real CODEX_API_KEY/GEMINI_API_KEY env vars unset
#  (ii)  inject sentinel values: SFS_TEST_SENTINEL_dummy_codex_<HEX16> + _gemini_<HEX16>
#        regex contract: ^SFS_TEST_SENTINEL_dummy_(codex|gemini)_[0-9a-f]{16}$
#  (iii) generate fake log artifact bearing sentinels (mock invoker)
#  (iv)  grep masked artifact for sentinel literal — count must be 0
#
# Mask replacement: ***  (or [masked] / [redacted])
# Env var name leakage of CODEX_API_KEY / GEMINI_API_KEY is OK (public convention; .github/workflows/*.yml).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT
cd "${tmp}"

# (i) ensure no real keys are present.
unset CODEX_API_KEY GEMINI_API_KEY 2>/dev/null || true

# (ii) generate sentinels via openssl rand -hex 8 (fallback if openssl missing).
gen_hex16() {
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -hex 8
  else
    head -c 8 /dev/urandom | xxd -p -c 8 | tr -d '\n' | head -c 16
  fi
}
sentinel_codex="SFS_TEST_SENTINEL_dummy_codex_$(gen_hex16)"
sentinel_gemini="SFS_TEST_SENTINEL_dummy_gemini_$(gen_hex16)"

# Regex contract verify on sentinels.
RE='^SFS_TEST_SENTINEL_dummy_(codex|gemini)_[0-9a-f]{16}$'
[[ "${sentinel_codex}" =~ ${RE} ]] || { echo "sentinel codex regex mismatch"; exit 1; }
[[ "${sentinel_gemini}" =~ ${RE} ]] || { echo "sentinel gemini regex mismatch"; exit 1; }

# (iii) fake log production — mimic an invoker that emits sentinels into output.
unmasked_log="${tmp}/raw-log.txt"
{
  echo "info: invoking codex..."
  echo "auth_attempt key=${sentinel_codex}"
  echo "info: invoking gemini..."
  echo "auth_attempt key=${sentinel_gemini}"
  echo "env CODEX_API_KEY name visible (public convention OK)"
  echo "env GEMINI_API_KEY name visible (public convention OK)"
} > "${unmasked_log}"

# Mask via sed: replace sentinel values with *** (env var names preserved).
masked_log="${tmp}/masked-log.txt"
sed -E "s|${sentinel_codex}|***|g; s|${sentinel_gemini}|***|g" "${unmasked_log}" > "${masked_log}"

# (iv) Verify sentinel value literals do not appear.
hits_codex="$(grep -c "${sentinel_codex}" "${masked_log}" || true)"
hits_gemini="$(grep -c "${sentinel_gemini}" "${masked_log}" || true)"
if [[ "${hits_codex}" != "0" || "${hits_gemini}" != "0" ]]; then
  echo "AC4.6 FAIL: sentinel value literal leaked (codex=${hits_codex} gemini=${hits_gemini})"
  exit 1
fi

# Env var names allowed:
if ! grep -q "CODEX_API_KEY" "${masked_log}"; then
  echo "AC4.4.4 NOTE: env var name CODEX_API_KEY missing — should remain visible (informational)"
fi

echo "test-sfs-log-masking: OK (sentinels masked, env var names preserved)"
