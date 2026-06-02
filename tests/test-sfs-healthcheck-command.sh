#!/usr/bin/env bash
# sfs healthcheck는 read-only 제품 런타임 진단이어야 한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
HEALTHCHECK_SCRIPT="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-healthcheck.sh"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-healthcheck.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1" needle="$2" label="$3"
  grep -Fq -- "${needle}" "${file}" || fail "${label}: missing ${needle}"
}

create_project() {
  local dir="$1"
  mkdir -p "${dir}"
  cd "${dir}"
  git init -q
  git config user.email "healthcheck@solon.invalid"
  git config user.name "Solon Healthcheck Test"
  printf '# healthcheck fixture\n' > README.md
  git add README.md
  git commit -qm "init"
  SFS_INSTALL_LLM_WIKI=1 \
    SFS_COMMAND_TIMEOUT_SEC=0 \
    SFS_DIST_DIR="${DIST_DIR}" \
    bash "${SFS_BIN}" init --layout thin --yes >/dev/null 2>&1
  git add .
  git commit -qm "sfs init"
}

snapshot_project() {
  local dir="$1"
  (cd "${dir}" && find . -type f -print | LC_ALL=C sort | while IFS= read -r f; do cksum "${f}"; done)
}

PROJECT_DIR="${TMP_DIR}/green-project"
create_project "${PROJECT_DIR}"

snapshot_project "${PROJECT_DIR}" > "${TMP_DIR}/before.cksum"
if ! SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" healthcheck --project "${PROJECT_DIR}" > "${TMP_DIR}/green.out" 2>&1; then
  sed -n '1,220p' "${TMP_DIR}/green.out" >&2
  fail "healthcheck should be green for a fresh thin project"
fi
snapshot_project "${PROJECT_DIR}" > "${TMP_DIR}/after.cksum"
diff -u "${TMP_DIR}/before.cksum" "${TMP_DIR}/after.cksum" >/dev/null \
  || fail "healthcheck mutated project files"
git -C "${PROJECT_DIR}" status --porcelain > "${TMP_DIR}/git-status.out"
[[ ! -s "${TMP_DIR}/git-status.out" ]] || fail "healthcheck changed git worktree"
assert_contains "${TMP_DIR}/green.out" "Summary: projects=1 issues=0" "green summary"
assert_contains "${TMP_DIR}/green.out" "runtime regression test-context-report-bug-command.sh" "runtime subset"

EMPTY_DIV="${TMP_DIR}/empty-divisions"
create_project "${EMPTY_DIV}"
: > "${EMPTY_DIV}/.sfs-local/divisions.yaml"
set +e
SFS_HEALTHCHECK_SKIP_RUNTIME_TESTS=1 \
  SFS_DIST_DIR="${DIST_DIR}" \
  bash "${SFS_BIN}" healthcheck --project "${EMPTY_DIV}" > "${TMP_DIR}/empty-divisions.out" 2>&1
rc=$?
set -e
[[ "${rc}" -eq 1 ]] || fail "empty divisions should exit 1, got ${rc}"
assert_contains "${TMP_DIR}/empty-divisions.out" "divisions-parse" "empty divisions issue"
assert_contains "${TMP_DIR}/empty-divisions.out" "report-bug DRAFT (not submitted)" "empty divisions draft"

BAD_WIKI="${TMP_DIR}/bad-wiki"
create_project "${BAD_WIKI}"
printf 'missing frontmatter\n' > "${BAD_WIKI}/llm-wiki/bad-note.md"
set +e
SFS_HEALTHCHECK_SKIP_RUNTIME_TESTS=1 \
  SFS_DIST_DIR="${DIST_DIR}" \
  bash "${SFS_BIN}" healthcheck --project "${BAD_WIKI}" > "${TMP_DIR}/bad-wiki.out" 2>&1
rc=$?
set -e
[[ "${rc}" -eq 1 ]] || fail "bad wiki frontmatter should exit 1, got ${rc}"
assert_contains "${TMP_DIR}/bad-wiki.out" "vault-frontmatter" "bad wiki issue"
assert_contains "${TMP_DIR}/bad-wiki.out" "bad-note.md missing opening frontmatter" "bad wiki detail"

FAKEBIN="${TMP_DIR}/fakebin"
mkdir -p "${FAKEBIN}"
cat > "${FAKEBIN}/gh" <<'EOF'
#!/usr/bin/env bash
echo "gh was called" >> "${GH_CALLED_FILE:?}"
exit 99
EOF
chmod +x "${FAKEBIN}/gh"
GH_CALLED_FILE="${TMP_DIR}/gh-called"
set +e
GH_CALLED_FILE="${GH_CALLED_FILE}" \
  PATH="${FAKEBIN}:$PATH" \
  SFS_HEALTHCHECK_SKIP_RUNTIME_TESTS=1 \
  SFS_DIST_DIR="${DIST_DIR}" \
  bash "${SFS_BIN}" healthcheck --project "${BAD_WIKI}" > "${TMP_DIR}/fake-gh.out" 2>&1
rc=$?
set -e
[[ "${rc}" -eq 1 ]] || fail "fake gh red healthcheck should still exit 1"
[[ ! -f "${GH_CALLED_FILE}" ]] || fail "healthcheck must not call gh/report-bug automatically"
assert_contains "${TMP_DIR}/fake-gh.out" "No GitHub issue was" "draft-only wording"

grep -Fq "set -u" "${HEALTHCHECK_SCRIPT}" || fail "healthcheck must use set -u"
grep -Fq "pipefail" "${HEALTHCHECK_SCRIPT}" && fail "healthcheck must not enable pipe status traps"
grep -Eq 'grep[[:space:]][^;&|]*-q|grep[[:space:]][^;&|]*-[A-Za-z]*q' "${HEALTHCHECK_SCRIPT}" \
  && fail "healthcheck must not use grep -q"

SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context cat healthcheck > "${TMP_DIR}/context-healthcheck.out" 2>&1 \
  || fail "bare healthcheck context key should resolve"
assert_contains "${TMP_DIR}/context-healthcheck.out" "report-bug DRAFT" "context draft contract"

echo "test-sfs-healthcheck-command: OK"
