#!/usr/bin/env bash
# Token Diet runtime status compact mode를 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local text="$1"
  local needle="$2"
  local label="$3"

  case "${text}" in
    *"${needle}"*) ;;
    *) fail "${label}: missing '${needle}' in '${text}'" ;;
  esac
}

bytes_text() {
  printf '%s' "$1" | wc -c | tr -d ' '
}

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-token-diet-status.XXXXXX")"
trap 'rm -rf "${TMP_DIR}"' EXIT

cd "${TMP_DIR}"
git init -q
git config user.email "sfs@example.invalid"
git config user.name "SFS Test"
printf '# fixture\n' > README.md
git add README.md
git commit -q -m "init"

mkdir -p .sfs-local
printf '0.6.84-test\n' > .sfs-local/VERSION
printf '2026-W20-sprint-1\n' > .sfs-local/current-sprint
printf 'WU-9\n' > .sfs-local/current-wu
cat > .sfs-local/events.jsonl <<'EOF'
{"ts":"2026-05-13T00:00:00+09:00","type":"wu_open","sprint_id":"2026-W20-sprint-1","wu_id":"WU-9"}
{"ts":"2026-05-13T00:01:00+09:00","type":"gate","sprint_id":"2026-W20-sprint-1","gate_id":"G1","verdict":"pass"}
EOF

normal="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" status --color never)"
compact_env="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_OUTPUT_STYLE=compact SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" status --color never)"
compact_flag="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" status --compact --color never)"

assert_contains "${normal}" "sprint 2026-W20-sprint-1" "normal status sprint"
assert_contains "${normal}" "WU WU-9" "normal status wu"
assert_contains "${normal}" "gate Gate 3 (Plan):pass" "normal status gate verdict"
assert_contains "${normal}" "last_event 2026-05-13T00:01:00+09:00" "normal status last event"

expected_compact="sprint=2026-W20-sprint-1 wu=WU-9 gate=Gate 3 (Plan) verdict=pass ahead=0 last_event=2026-05-13T00:01:00+09:00"
[[ "${compact_env}" == "${expected_compact}" ]] || fail "env compact mismatch: ${compact_env}"
[[ "${compact_flag}" == "${expected_compact}" ]] || fail "flag compact mismatch: ${compact_flag}"

normal_bytes="$(bytes_text "${normal}")"
compact_bytes="$(bytes_text "${compact_env}")"
[[ "${compact_bytes}" -lt "${normal_bytes}" ]] \
  || fail "compact status should be shorter: normal=${normal_bytes}, compact=${compact_bytes}"

for field in sprint wu gate verdict ahead last_event; do
  assert_contains "${compact_env}" "${field}=" "compact status field ${field}"
done

set +e
bad_style="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_OUTPUT_STYLE=ultra SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" status 2>&1)"
bad_rc=$?
set -e
[[ "${bad_rc}" -eq 99 ]] || fail "invalid output style should exit 99, got ${bad_rc}"
assert_contains "${bad_style}" "invalid output style" "invalid style error"

echo "test-token-diet-runtime-compact-status: OK"
