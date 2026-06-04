#!/usr/bin/env bash
# tests/test-sfs-lite-first-experience.sh — B6 first-experience command surface.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BIN="${DIST_DIR}/bin/sfs"
GUIDE_SCRIPT="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-guide.sh"
CONTEXT_DIR="${DIST_DIR}/templates/.sfs-local-template/context"
SCRIPT_DIR_RUNTIME="${DIST_DIR}/templates/.sfs-local-template/scripts"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local text="$1" needle="$2" label="$3"
  grep -Fq -- "${needle}" <<<"${text}" || {
    echo "FAIL: missing ${label}: ${needle}" >&2
    echo "--- text ---" >&2
    printf '%s\n' "${text}" >&2
    exit 1
  }
}

assert_not_contains() {
  local text="$1" needle="$2" label="$3"
  if grep -Fq -- "${needle}" <<<"${text}"; then
    echo "FAIL: unexpected ${label}: ${needle}" >&2
    echo "--- text ---" >&2
    printf '%s\n' "${text}" >&2
    exit 1
  fi
}

help_default="$(SFS_COMMAND_TIMEOUT_SEC=0 bash "${BIN}" help)"
assert_contains "${help_default}" "First experience:" "default help first experience heading"
for cmd in \
  'sfs start "<goal>"' \
  'sfs plan' \
  'sfs implement "<slice>"' \
  'sfs review --gate 6'; do
  assert_contains "${help_default}" "${cmd}" "default help ${cmd}"
done
assert_contains "${help_default}" "Full command inventory:" "default help full pointer"
assert_contains "${help_default}" "sfs help --full" "default help full command"
assert_contains "${help_default}" "sfs harness doctor|map [--write]" "default help harness setup"
assert_not_contains "${help_default}" "status, start, guide, auth" "old full inventory in default help"
assert_not_contains "${help_default}" "brainstorm, plan, implement" "old lifecycle inventory in default help"

help_full="$(SFS_COMMAND_TIMEOUT_SEC=0 bash "${BIN}" help --full)"
assert_contains "${help_full}" "Full command inventory" "full help heading"
for cmd in brainstorm decision capture retro commit loop healthcheck measure handoff; do
  assert_contains "${help_full}" "${cmd}" "full help keeps ${cmd}"
done

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT

project="${tmp}/project"
mkdir -p "${project}/.sfs-local"
cat > "${project}/.sfs-local/VERSION" <<'EOF'
solon_mvp_version: test
installed_at: test
install_layout: thin
EOF

guide_default="$(
  cd "${project}"
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${BIN}" guide
)"
guide_first_flow="$(awk '
  /^첫 흐름/ {capture=1}
  /^전체 가이드/ {capture=0}
  capture {print}
' <<<"${guide_default}")"
for cmd in \
  'sfs start "<이번 sprint 목표>"' \
  'sfs plan' \
  'sfs implement "<첫 구현 slice>"' \
  'sfs review --gate 6'; do
  assert_contains "${guide_first_flow}" "${cmd}" "guide first flow ${cmd}"
done
for hidden in 'sfs brainstorm' 'sfs decision' 'sfs retro'; do
  assert_not_contains "${guide_first_flow}" "${hidden}" "guide first flow hides ${hidden}"
done
assert_contains "${guide_default}" "sfs guide --print" "guide default full pointer"

guide_print="$(
  cd "${project}"
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${BIN}" guide --print
)"
assert_contains "${guide_print}" "필요할 때만 쓰는 명령" "guide print full guide"
assert_contains "${guide_print}" "Review" "guide print review"
assert_contains "${guide_print}" "Retro" "guide print retro"

for path in \
  "${GUIDE_SCRIPT}" \
  "${SCRIPT_DIR_RUNTIME}/sfs-brainstorm.sh" \
  "${SCRIPT_DIR_RUNTIME}/sfs-capture.sh" \
  "${SCRIPT_DIR_RUNTIME}/sfs-retro.sh" \
  "${CONTEXT_DIR}/commands/brainstorm.md" \
  "${CONTEXT_DIR}/commands/capture.md" \
  "${CONTEXT_DIR}/commands/loop.md"; do
  [[ -f "${path}" ]] || fail "non-destructive full mode asset missing: ${path}"
done

grep -Fq 'brainstorm|plan|implement|review|decision|capture|note|ingest|report|flowcheck|event|tidy|retro|commit|loop' "${BIN}" \
  || fail "dispatch allowlist lost advanced commands"

echo "test-sfs-lite-first-experience: OK"
