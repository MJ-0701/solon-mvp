#!/usr/bin/env bash
# Release channel workflow auth must be preflighted before workflow dispatch.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${DIST_DIR}/.." && pwd)"
SCRIPT="${DIST_DIR}/scripts/sfs-channel-publish-preflight.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

. "${SCRIPT_DIR}/helpers/doc-search.sh"

assert_contains() {
  local file="$1" needle="$2" label="$3"
  [[ -f "${file}" ]] || fail "${label}: missing ${file}"
  sfs_doc_contains "${file}" "${needle}" || fail "${label}: missing '${needle}'"
}

[[ -x "${SCRIPT}" ]] || fail "preflight script missing or not executable"

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT
mkdir -p "${tmp}/bin"
cat > "${tmp}/bin/gh" <<'FAKE_GH'
#!/usr/bin/env bash
case "${FAKE_GH_MODE:-present}" in
  present)
    printf 'SOLON_RELEASE_BOT_TOKEN\t2026-05-25T00:00:00Z\n'
    ;;
  absent)
    printf 'OTHER_SECRET\t2026-05-25T00:00:00Z\n'
    ;;
  fail)
    echo 'HTTP 403: missing secret list scope' >&2
    exit 1
    ;;
  *)
    echo "unknown FAKE_GH_MODE=${FAKE_GH_MODE}" >&2
    exit 2
    ;;
esac
FAKE_GH
chmod +x "${tmp}/bin/gh"

out="$(PATH="${tmp}/bin:${PATH}" FAKE_GH_MODE=present bash "${SCRIPT}" --version 0.6.128 --mode push)"
printf '%s\n' "${out}" | grep -q '^status workflow_ready$' || fail "present secret should be workflow_ready"
printf '%s\n' "${out}" | grep -q 'publish-product-channels.yml' || fail "workflow_ready should name workflow dispatch"

out="$(PATH="${tmp}/bin:${PATH}" FAKE_GH_MODE=absent bash "${SCRIPT}" --version 0.6.128 --mode push)"
printf '%s\n' "${out}" | grep -q '^status manual_required$' || fail "absent secret should be manual_required"
printf '%s\n' "${out}" | grep -q '^reason missing_secret$' || fail "absent secret should name missing_secret"
printf '%s\n' "${out}" | grep -q 'do_not_dispatch_publish_product_channels_workflow' || fail "manual_required should skip workflow dispatch"
printf '%s\n' "${out}" | grep -q 'verify-product-release.sh --version 0.6.128' || fail "manual_required should route to verifier"

if PATH="${tmp}/bin:${PATH}" FAKE_GH_MODE=absent bash "${SCRIPT}" --version 0.6.128 --require-workflow >/dev/null 2>&1; then
  fail "--require-workflow should fail when secret is absent"
fi

out="$(PATH="${tmp}/bin:${PATH}" FAKE_GH_MODE=fail bash "${SCRIPT}" --version 0.6.128 --mode pr)"
printf '%s\n' "${out}" | grep -q '^status manual_required$' || fail "gh failure should route manual_required"
printf '%s\n' "${out}" | grep -q '^reason gh_secret_list_failed$' || fail "gh failure should classify reason"

workflow="${DIST_DIR}/.github/workflows/publish-product-channels.yml"
release_context="${DIST_DIR}/templates/.sfs-local-template/context/commands/release.md"
shipping_policy="${DIST_DIR}/templates/.sfs-local-template/context/policies/shipping-and-launch.md"
scripts_readme="${REPO_ROOT}/scripts/_README.md"
release_sequence="${DIST_DIR}/scripts/sfs-release-sequence.sh"

assert_contains "${workflow}" "sfs-channel-publish-preflight.sh" "workflow missing preflight hint"
assert_contains "${workflow}" "do not dispatch this workflow" "workflow missing manual fallback hint"
assert_contains "${workflow}" "workflow-file-push-validation" "workflow missing push no-op job"
assert_contains "${workflow}" "github.event_name == 'push'" "workflow missing push no-op condition"
assert_contains "${workflow}" "github.event_name == 'workflow_dispatch'" "workflow missing manual publish gate"
assert_contains "${release_context}" "sfs-channel-publish-preflight.sh" "release context missing preflight"
assert_contains "${release_context}" "manual_required" "release context missing manual_required"
assert_contains "${release_context}" "not a user blocker or release blocker" "release context missing non-blocker contract"
assert_contains "${shipping_policy}" "Cross-repo channel workflow auth is a lane" "shipping policy missing lane framing"
assert_contains "${shipping_policy}" "do not ask the user for a token" "shipping policy missing user-call guard"
assert_contains "${scripts_readme}" "SOLON_RELEASE_BOT_TOKEN" "scripts README missing token contract"
assert_contains "${scripts_readme}" "manual_required" "scripts README missing manual fallback"
assert_contains "${release_sequence}" "sfs-channel-publish-preflight.sh" "release sequence missing preflight"

echo "test-release-channel-auth-preflight: OK"
