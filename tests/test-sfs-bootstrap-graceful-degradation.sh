#!/usr/bin/env bash
# tests/test-sfs-bootstrap-graceful-degradation.sh — R-A AC-func-4 4-case graceful degradation.
#
# (a) network OK + API up    → cache verified + exit 0   (skipped — would require live API)
# (b) network OK + API 4xx   → hard fail + exit 2
# (c) network OK + API 5xx   → fallback to cache + exit 0
# (d) network OFF            → fallback to cache + exit 0
# (e) cache absent           → exit 2
#
# Cases (b)/(c) are simulated with a fake curl; (d) uses an unreachable loopback port.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCRIPT="${DIST_DIR}/scripts/sfs-bootstrap.sh"

[[ -x "${SCRIPT}" ]] || { echo "missing: ${SCRIPT}" >&2; exit 1; }

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT

cd "${tmp}"

# Fake curl that returns a caller-selected HTTP status without real network.
fake_bin="${tmp}/fake-bin"
mkdir -p "${fake_bin}"
cat >"${fake_bin}/curl" <<'EOF_CURL'
#!/usr/bin/env bash
out=""
code="${SFS_FAKE_HTTP_CODE:-500}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o) out="${2:-}"; shift 2 ;;
    -w) shift 2 ;;
    --max-time) shift 2 ;;
    *) shift ;;
  esac
done
[[ -n "${out}" ]] && printf 'fake response for HTTP %s\n' "${code}" >"${out}"
printf '%s' "${code}"
exit 0
EOF_CURL
chmod +x "${fake_bin}/curl"

# === Case (e): cache absent → exit 2 ===
fake_dist="${tmp}/fake-dist"
mkdir -p "${fake_dist}/templates"   # has templates/ but no spring-kotlin-zero/
set +e
SFS_DIST_DIR="${fake_dist}" SFS_ALIVE_THRESHOLD_SECS=300 \
  bash "${SCRIPT}" --experimental spring-kotlin myproj --quick 2>"${tmp}/err-d.log"
rc=$?
set -e
[[ "${rc}" == "2" ]] || { echo "FAIL: case (e) cache absent should exit 2, got ${rc}" >&2; cat "${tmp}/err-d.log" >&2; exit 1; }
grep -q "template cache absent" "${tmp}/err-d.log" \
  || { echo "FAIL: case (e) stderr should mention 'template cache absent'" >&2; cat "${tmp}/err-d.log" >&2; exit 1; }

# === Case (e) with --refresh → exit 2 + extra hint ===
set +e
SFS_DIST_DIR="${fake_dist}" SFS_ALIVE_THRESHOLD_SECS=300 \
  bash "${SCRIPT}" --experimental spring-kotlin myproj --refresh 2>"${tmp}/err-d-refresh.log"
rc=$?
set -e
[[ "${rc}" == "2" ]] || { echo "FAIL: case (e) + --refresh should exit 2, got ${rc}" >&2; exit 1; }
grep -q "requires network" "${tmp}/err-d-refresh.log" \
  || { echo "FAIL: case (e) + --refresh should hint 'requires network'" >&2; cat "${tmp}/err-d-refresh.log" >&2; exit 1; }

# === Case (b): API 4xx, cache present → hard fail exit 2 (no fallback) ===
set +e
PATH="${fake_bin}:$PATH" SFS_FAKE_HTTP_CODE=400 SFS_DIST_DIR="${DIST_DIR}" SFS_ALIVE_THRESHOLD_SECS=300 \
  bash "${SCRIPT}" --experimental spring-kotlin myproj-4xx --quick --refresh 2>"${tmp}/err-4xx.log"
rc=$?
set -e
[[ "${rc}" == "2" ]] || { echo "FAIL: case (b) API 4xx should exit 2, got ${rc}" >&2; cat "${tmp}/err-4xx.log" >&2; exit 1; }
grep -q "HTTP 400" "${tmp}/err-4xx.log" \
  || { echo "FAIL: case (b) stderr should mention HTTP 400" >&2; cat "${tmp}/err-4xx.log" >&2; exit 1; }
[[ ! -e myproj-4xx ]] \
  || { echo "FAIL: case (b) API 4xx should not create project from stale cache" >&2; exit 1; }

# === Case (c): API 5xx, cache present → fallback exit 0 ===
PATH="${fake_bin}:$PATH" SFS_FAKE_HTTP_CODE=500 SFS_DIST_DIR="${DIST_DIR}" SFS_ALIVE_THRESHOLD_SECS=300 \
  bash "${SCRIPT}" --experimental spring-kotlin myproj-5xx --quick --refresh 2>"${tmp}/err-5xx.log"
[[ -f myproj-5xx/build.gradle.kts ]] \
  || { echo "FAIL: case (c) project should be created from cache fallback" >&2; cat "${tmp}/err-5xx.log" >&2; exit 1; }
grep -q "HTTP 500" "${tmp}/err-5xx.log" \
  || { echo "FAIL: case (c) stderr should mention HTTP 500 fallback" >&2; cat "${tmp}/err-5xx.log" >&2; exit 1; }

# === Case (d): API unreachable, cache present → fallback exit 0 ===
SFS_DIST_DIR="${DIST_DIR}" SFS_ALIVE_THRESHOLD_SECS=300 \
  SFS_INITIALIZR_API="http://127.0.0.1:1" SFS_INITIALIZR_TIMEOUT=2 \
    bash "${SCRIPT}" --experimental spring-kotlin myproj-bc --quick --refresh 2>"${tmp}/err-bc.log"
[[ -f myproj-bc/build.gradle.kts ]] \
  || { echo "FAIL: case (d) project should be created from cache fallback" >&2; cat "${tmp}/err-bc.log" >&2; exit 1; }
grep -qE 'falling back to cache|cache verified' "${tmp}/err-bc.log" \
  || { echo "FAIL: case (d) should emit fallback or verify message" >&2; cat "${tmp}/err-bc.log" >&2; exit 1; }

# === Case (a) proxy: default --quick (no --refresh), cache present → exit 0 ===
SFS_DIST_DIR="${DIST_DIR}" SFS_ALIVE_THRESHOLD_SECS=300 \
  bash "${SCRIPT}" --experimental spring-kotlin myproj-a --quick
[[ -f myproj-a/build.gradle.kts ]] \
  || { echo "FAIL: case (a) default --quick + cache present should create project" >&2; exit 1; }

echo "test-sfs-bootstrap-graceful-degradation: OK"
