#!/usr/bin/env bash
# Classify whether the cross-repo product-channel publish workflow is usable.
#
# This is intentionally a classifier, not a secret reader. It checks only
# whether the workflow credential name is present and tells release owners
# whether to dispatch the workflow or use the local Homebrew/Scoop fallback.
set -euo pipefail

script_name="$(basename "$0")"
repo="MJ-0701/solon-product"
secret_name="SOLON_RELEASE_BOT_TOKEN"
version=""
mode="push"
require_workflow=0

usage() {
  cat <<EOF
Usage:
  ${script_name} [--repo owner/repo] [--version X.Y.Z] [--mode pr|push] [--require-workflow]

Outputs one of:
  status workflow_ready
  status manual_required

Default exit code is 0 for both statuses because missing workflow auth should
route the release to the local channel-publish fallback. With --require-workflow,
manual_required exits 1.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help|help) usage; exit 0 ;;
    --repo) repo="${2:-}"; shift 2 ;;
    --repo=*) repo="${1#*=}"; shift ;;
    --version) version="${2:-}"; shift 2 ;;
    --version=*) version="${1#*=}"; shift ;;
    --mode) mode="${2:-}"; shift 2 ;;
    --mode=*) mode="${1#*=}"; shift ;;
    --require-workflow) require_workflow=1; shift ;;
    *) echo "${script_name}: unknown arg: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "${repo}" ]]; then
  echo "${script_name}: --repo cannot be empty" >&2
  exit 2
fi
case "${mode}" in
  pr|push) ;;
  *) echo "${script_name}: --mode must be pr or push" >&2; exit 2 ;;
esac

status="manual_required"
reason=""
secret_list=""
if ! command -v gh >/dev/null 2>&1; then
  reason="gh_unavailable"
elif ! secret_list="$(gh secret list --repo "${repo}" 2>&1)"; then
  reason="gh_secret_list_failed"
elif printf '%s\n' "${secret_list}" | awk '{print $1}' | grep -qx "${secret_name}"; then
  status="workflow_ready"
  reason="secret_present"
else
  reason="missing_secret"
fi

printf 'status %s\n' "${status}"
printf 'reason %s\n' "${reason}"
printf 'repo %s\n' "${repo}"
[[ -n "${version}" ]] && printf 'version %s\n' "${version}"
printf 'mode %s\n' "${mode}"

if [[ "${status}" == "workflow_ready" ]]; then
  cat <<EOF
next gh workflow run publish-product-channels.yml --repo ${repo} -f version=${version:-<VERSION>} -f mode=${mode}
note workflow may publish Homebrew/Scoop because ${secret_name} is configured.
EOF
else
  cat <<EOF
next do_not_dispatch_publish_product_channels_workflow
note ${secret_name} is optional workflow automation for cross-repo Homebrew/Scoop writes, not a release blocker.
note publish Homebrew and Scoop locally, push those channel repos, then run scripts/verify-product-release.sh --version ${version:-<VERSION>}.
EOF
  if [[ "${reason}" == "gh_secret_list_failed" ]]; then
    printf 'gh_error %s\n' "$(printf '%s\n' "${secret_list}" | head -1)"
  fi
fi

if [[ "${require_workflow}" == "1" && "${status}" != "workflow_ready" ]]; then
  exit 1
fi
