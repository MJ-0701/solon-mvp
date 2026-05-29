#!/usr/bin/env bash
# tests/test-domain-ontology-lens-lock.sh — ontology review lens: path auto-inference,
# alias normalization, and valid/alias hint on bad input.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-ontology-lens.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

run_sfs() {
  SFS_COMMAND_TIMEOUT_SEC=0 SFS_REVIEW_BRIDGE_PROBE_TIMEOUT_SEC=1 \
    SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" "$@"
}

cd "${TMP_DIR}"
git init -q
printf '# Ontology Lens Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

run_sfs init --layout thin --yes >/dev/null
run_sfs start "ontology lens lock" >/dev/null

# Path-based auto inference: a diff touching llm-wiki/ddd/ infers the ontology
# lens before the ddd-tdd lens. Must run before any other auto review so the
# per-sprint auto-lens lock does not interfere.
mkdir -p llm-wiki/ddd
printf '# Order aggregate\n\nOrder owns OrderLine.\n' > llm-wiki/ddd/order.md
# Stage the file: git porcelain collapses untracked directories to the dir name,
# so the full path llm-wiki/ddd/order.md only appears once it is tracked/staged.
git add llm-wiki/ddd/order.md
auto_out="$(run_sfs review --gate 6 --lens auto --prompt-only --allow-empty)"
case "${auto_out}" in
  *"lens ontology (auto) prompt ready"*) ;;
  *) fail "diff under llm-wiki/ddd should infer ontology lens: ${auto_out}" ;;
esac
auto_path="$(printf '%s\n' "${auto_out}" | sed -nE 's/^review\.md ready: ([^|]+) \|.*/\1/p')"
[[ -f "${auto_path}" ]] || fail "review path missing for auto ontology: ${auto_path}"
grep -Fq 'review_lens: "ontology"' "${auto_path}" \
  || fail "review.md frontmatter missing inferred ontology lens"

assert_alias() {
  local alias="$1" out review_path
  out="$(run_sfs review --gate 6 --lens "${alias}" --prompt-only --allow-empty)"
  case "${out}" in
    *"lens ontology (explicit) prompt ready"*) ;;
    *) fail "--lens ${alias} did not normalize to ontology: ${out}" ;;
  esac
  review_path="$(printf '%s\n' "${out}" | sed -nE 's/^review\.md ready: ([^|]+) \|.*/\1/p')"
  [[ -f "${review_path}" ]] || fail "review path missing for ${alias}: ${review_path}"
  grep -Fq 'review_lens: "ontology"' "${review_path}" \
    || fail "review.md frontmatter missing normalized ontology lens for ${alias}"
}

assert_alias ontology
assert_alias domain-ontology
assert_alias entity-change
assert_alias entity-relationship

if run_sfs review --gate 6 --lens not-a-lens --prompt-only >"${TMP_DIR}/invalid.out" 2>"${TMP_DIR}/invalid.err"; then
  fail "invalid lens unexpectedly passed"
fi
grep -Fq ", ontology," "${TMP_DIR}/invalid.err" \
  || fail "invalid lens error should list ontology as a valid lens"
grep -Fq "entity-change/domain-ontology -> ontology" "${TMP_DIR}/invalid.err" \
  || fail "invalid lens error should show ontology alias hint"

echo "test-domain-ontology-lens-lock: OK"
