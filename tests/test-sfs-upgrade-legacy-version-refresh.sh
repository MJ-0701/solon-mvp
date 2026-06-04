#!/usr/bin/env bash
# legacy VERSION marker 를 가진 0.8.x 프로젝트의 upgrade refresh 경로를 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
EXPECTED_VERSION="$(head -1 "${DIST_DIR}/VERSION")"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-upgrade-legacy-version.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

make_mixed_legacy_fixture() {
  local root="$1"
  mkdir -p "${root}"
  cd "${root}"
  git init -q
  git config user.email "legacy-version@solon.invalid"
  git config user.name "Solon Legacy Version Test"
  printf '# Mixed Legacy SFS Project\n' > README.md
  git add README.md
  git commit -qm "initial"

  SFS_DIST_DIR="${DIST_DIR}" \
  SFS_INSTALL_LLM_WIKI=0 \
  SFS_MODEL_PROFILE_PROMPT=0 \
  SFS_SKIP_CLI_DISCOVERY=1 \
  SFS_COMMAND_TIMEOUT_SEC=0 \
  bash "${SFS_BIN}" init --layout thin --yes >/dev/null

  mkdir -p .sfs-local/sprints/2026-W23-sprint-x .sfs-local/scripts
  printf '2026-W23-sprint-x\n' > .sfs-local/current-sprint
  printf '# report\n\nmixed legacy state\n' > .sfs-local/sprints/2026-W23-sprint-x/report.md
  printf '# already-current local script marker\n' > .sfs-local/scripts/sfs-common.sh
  cat > .sfs-local/VERSION <<'EOF'
solon_mvp_version: 0.5.23-product
installed_at: 2026-04-30T10:46:38Z
upgraded_at: 2026-04-30T12:12:00Z
upgraded_from: 0.5.22-product
installed_from: local
source_repo: https://github.com/MJ-0701/solon-product
EOF
}

assert_refreshed_marker() {
  local root="$1" label="$2"
  grep -Fq "solon_mvp_version: ${EXPECTED_VERSION}" "${root}/.sfs-local/VERSION" \
    || fail "${label}: VERSION should refresh solon_mvp_version to ${EXPECTED_VERSION}"
  grep -Fq 'install_layout: thin' "${root}/.sfs-local/VERSION" \
    || fail "${label}: VERSION should add thin install_layout"
  grep -Fq 'upgraded_from: 0.5.23-product' "${root}/.sfs-local/VERSION" \
    || fail "${label}: VERSION should preserve legacy upgraded_from"
  grep -Fq '2026-W23-sprint-x' "${root}/.sfs-local/current-sprint" \
    || fail "${label}: current sprint pointer should be preserved"
  grep -Fq 'mixed legacy state' "${root}/.sfs-local/sprints/2026-W23-sprint-x/report.md" \
    || fail "${label}: existing sprint evidence should be preserved"
}

direct_root="${TMP_DIR}/direct"
make_mixed_legacy_fixture "${direct_root}"
set +e
direct_out="$(
  cd "${direct_root}" && \
  SFS_INSTALL_LLM_WIKI=0 \
  SFS_MODEL_PROFILE_PROMPT=0 \
  SFS_SKIP_CLI_DISCOVERY=1 \
  SFS_COMMAND_TIMEOUT_SEC=0 \
  bash "${DIST_DIR}/upgrade.sh" --yes --layout thin 2>&1
)"
direct_rc=$?
set -e

[[ "${direct_rc}" -eq 0 ]] \
  || fail "direct upgrade.sh should succeed for legacy VERSION without install_layout, rc=${direct_rc}: ${direct_out}"
assert_refreshed_marker "${direct_root}" "direct upgrade.sh"
grep -Fq 'VERSION 갱신: 0.5.23-product' <<<"${direct_out}" \
  || fail "direct upgrade.sh should surface VERSION refresh, got: ${direct_out}"

opt_in_root="${TMP_DIR}/opt-in"
make_mixed_legacy_fixture "${opt_in_root}"
set +e
opt_in_out="$(
  cd "${opt_in_root}" && \
  SFS_DIST_DIR="${DIST_DIR}" \
  SFS_UPDATE_SELF=0 \
  SFS_INSTALL_LLM_WIKI=0 \
  SFS_MODEL_PROFILE_PROMPT=0 \
  SFS_SKIP_CLI_DISCOVERY=1 \
  SFS_COMMAND_TIMEOUT_SEC=0 \
  bash "${SFS_BIN}" upgrade --no-self-upgrade --skip-existing --opt-in 0.6-storage --layout thin 2>&1
)"
opt_in_rc=$?
set -e

[[ "${opt_in_rc}" -eq 0 ]] \
  || fail "sfs upgrade --opt-in should continue after idempotent migration no-op, rc=${opt_in_rc}: ${opt_in_out}"
grep -Fq 'idempotent OK' <<<"${opt_in_out}" \
  || fail "sfs upgrade --opt-in should show migration no-op evidence, got: ${opt_in_out}"
assert_refreshed_marker "${opt_in_root}" "sfs upgrade --opt-in"

wrapper_root="${TMP_DIR}/wrapper"
mkdir -p "${wrapper_root}/.sfs-local" "${TMP_DIR}/fake-dist/templates/.sfs-local-template/scripts"
cat > "${wrapper_root}/.sfs-local/VERSION" <<'EOF'
solon_mvp_version: 0.8.21
installed_at: 2026-06-04T00:00:00Z
install_layout: thin
EOF
printf '%s\n' "${EXPECTED_VERSION}" > "${TMP_DIR}/fake-dist/VERSION"
cat > "${TMP_DIR}/fake-dist/upgrade.sh" <<'EOF'
#!/usr/bin/env bash
exit 17
EOF
chmod +x "${TMP_DIR}/fake-dist/upgrade.sh"

set +e
wrapper_out="$(
  cd "${wrapper_root}" && \
  SFS_DIST_DIR="${TMP_DIR}/fake-dist" \
  SFS_UPDATE_SELF=0 \
  SFS_COMMAND_TIMEOUT_SEC=0 \
  bash "${SFS_BIN}" upgrade --no-self-upgrade --layout thin 2>&1
)"
wrapper_rc=$?
set -e

[[ "${wrapper_rc}" -eq 17 ]] \
  || fail "wrapper should preserve child upgrade.sh exit code 17, got ${wrapper_rc}: ${wrapper_out}"
grep -Fq 'sfs upgrade: project upgrade script failed' <<<"${wrapper_out}" \
  || fail "wrapper should name failed project upgrade script, got: ${wrapper_out}"

echo "test-sfs-upgrade-legacy-version-refresh: OK"
