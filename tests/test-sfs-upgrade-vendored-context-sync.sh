#!/usr/bin/env bash
# vendored upgrade가 새 context policy 파일을 빠뜨리지 않게 검증한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-upgrade-context.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

cd "${TMP_DIR}"
git init -q
printf '# Vendored Context Sync\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

SFS_COMMAND_TIMEOUT_SEC=0 \
SFS_DIST_DIR="${DIST_DIR}" \
bash "${SFS_BIN}" init --layout vendored --yes >/dev/null

for intake_policy in \
  .sfs-local/context/policies/design-intake-flow.md \
  .sfs-local/context/policies/design-intake-flow.ko.md; do
  [[ -f "${intake_policy}" ]] || fail "vendored init missed ${intake_policy}"
done

rm -f .sfs-local/context/policies/session-continuation-guard.md
rm -f .sfs-local/context/policies/design-intake-flow.md
rm -f .sfs-local/context/policies/design-intake-flow.ko.md
awk '
  /^solon_mvp_version:/ { print "solon_mvp_version: 0.6.91"; next }
  { print }
' .sfs-local/VERSION > .sfs-local/VERSION.tmp
mv .sfs-local/VERSION.tmp .sfs-local/VERSION

if ! SFS_MODEL_PROFILE_PROMPT=0 \
  SFS_SKIP_CLI_DISCOVERY=1 \
  SFS_UPDATE_SELF=0 \
  SFS_COMMAND_TIMEOUT_SEC=0 \
  SFS_DIST_DIR="${DIST_DIR}" \
  bash "${SFS_BIN}" upgrade --no-self-upgrade --layout vendored >upgrade.out 2>upgrade.err; then
  sed -n '1,120p' upgrade.err >&2
  tail -80 upgrade.out >&2
  fail "vendored upgrade failed"
fi

guard=".sfs-local/context/policies/session-continuation-guard.md"
[[ -f "${guard}" ]] || fail "missing restored session continuation guard"
grep -Fq "30%" "${guard}" || fail "restored guard is not the current policy"
for intake_policy in \
  .sfs-local/context/policies/design-intake-flow.md \
  .sfs-local/context/policies/design-intake-flow.ko.md; do
  [[ -f "${intake_policy}" ]] || fail "vendored upgrade missed ${intake_policy}"
done

expected_version="$(head -1 "${DIST_DIR}/VERSION")"
grep -Fq "solon_mvp_version: ${expected_version}" .sfs-local/VERSION \
  || fail "project VERSION was not upgraded to ${expected_version}"

path_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" context path policies/session-continuation-guard.md)"
case "${path_out}" in
  .sfs-local/context/policies/session-continuation-guard.md) ;;
  *) fail "vendored current project should resolve guard from local context, got: ${path_out}" ;;
esac

echo "test-sfs-upgrade-vendored-context-sync: OK"
