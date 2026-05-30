#!/usr/bin/env bash
# PR 변경과 본문 증거를 대조해 제품 변경이 Gate 6 review flow 없이 통과하지 못하게 한다.
#
# Usage:
#   bash scripts/sfs-pr-review-flow-check.sh [--root <repo-root>] [--strict|--advisory]
#
# Inputs:
#   SFS_PR_CHANGED_FILES  optional newline-delimited changed file list
#   SFS_PR_BODY           optional pull request body text
#   SFS_PR_BASE_SHA       optional base sha for git diff
#   SFS_PR_HEAD_SHA       optional head sha for git diff
#   GITHUB_EVENT_PATH     optional GitHub Actions event payload for PR body
#
# Exit codes:
#   0 OK or advisory skip
#   1 strict review-flow failure
#   2 invalid usage

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
repo_root=""
mode="strict"

usage() {
  cat <<'EOF'
sfs-pr-review-flow-check — require formal SFS Gate 6 review evidence for product PRs

Usage:
  sfs-pr-review-flow-check [--root <repo-root>] [--strict|--advisory]

Required PR evidence for product-bearing changes:
  1. self-CPO PASS evidence:  sfs review --gate 6 --stage self: PASS
  2. cross PASS evidence:     sfs review --gate 6 --stage cross: PASS
     or a concrete self-CPO fallback reason such as no other agent subscription,
     external agent token exhaustion, or cross-review bridge unavailability.

GitHub @codex review, PR approval, or GitHub check PASS is external evidence
only and does not satisfy the SFS Gate 6 self/cross review flow.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help|help)
      usage
      exit 0
      ;;
    --root)
      repo_root="${2:-}"
      shift 2 || { echo "${SCRIPT_NAME}: missing value for --root" >&2; exit 2; }
      ;;
    --strict)
      mode="strict"
      shift
      ;;
    --advisory)
      mode="advisory"
      shift
      ;;
    *)
      echo "${SCRIPT_NAME}: unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "${repo_root}" ]]; then
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
if [[ ! -d "${repo_root}" ]]; then
  echo "${SCRIPT_NAME}: repo root not found: ${repo_root}" >&2
  exit 2
fi

cd "${repo_root}"

is_product_bearing_path() {
  case "${1:-}" in
    .github/workflows/*|bin/*|commands/*|docs/*|packaging/*|plugins/*|scripts/*|templates/*|tests/*) return 0 ;;
    AGENTS.md|BEGINNER-GUIDE.md|CHANGELOG.md|CLAUDE.md|GEMINI.md|GUIDE.md|README.md|RELEASE-NOTES.md|SFS.md|VERSION) return 0 ;;
    install.sh|install.ps1|upgrade.sh|upgrade.ps1|uninstall.sh|uninstall.ps1) return 0 ;;
    BEGINNER-GUIDE/*|GUIDE/*|README/*) return 0 ;;
    *) return 1 ;;
  esac
}

changed_files() {
  if [[ -n "${SFS_PR_CHANGED_FILES:-}" ]]; then
    printf '%s\n' "${SFS_PR_CHANGED_FILES}"
    return 0
  fi
  if [[ -n "${SFS_PR_BASE_SHA:-}" && -n "${SFS_PR_HEAD_SHA:-}" ]]; then
    git diff --name-only "${SFS_PR_BASE_SHA}" "${SFS_PR_HEAD_SHA}" 2>/dev/null && return 0
  fi
  if git rev-parse --verify HEAD^1 >/dev/null 2>&1; then
    git diff --name-only HEAD^1 HEAD 2>/dev/null && return 0
  fi
  return 0
}

event_body() {
  local event="${GITHUB_EVENT_PATH:-}"
  if [[ -n "${SFS_PR_BODY:-}" ]]; then
    printf '%s\n' "${SFS_PR_BODY}"
    return 0
  fi
  [[ -n "${event}" && -f "${event}" ]] || return 1
  if command -v jq >/dev/null 2>&1; then
    jq -r '.pull_request.body // ""' "${event}" 2>/dev/null && return 0
  fi
  if command -v ruby >/dev/null 2>&1; then
    ruby -rjson -e 'puts JSON.parse(File.read(ARGV.fetch(0))).dig("pull_request","body").to_s' "${event}" 2>/dev/null && return 0
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import json,sys; print((json.load(open(sys.argv[1])).get("pull_request") or {}).get("body") or "")' "${event}" 2>/dev/null && return 0
  fi
  return 1
}

body_has_regex() {
  local regex="$1"
  printf '%s\n' "${BODY_FLAT}" | grep -Eiq -- "${regex}"
}

fail_or_warn() {
  local msg="$1"
  if [[ "${mode}" == "advisory" ]]; then
    echo "${SCRIPT_NAME}: advisory warning — ${msg}" >&2
    return 0
  fi
  echo "${SCRIPT_NAME}: STRICT FAIL — ${msg}" >&2
  return 1
}

product_paths=""
product_count=0
while IFS= read -r path; do
  [[ -n "${path}" ]] || continue
  if is_product_bearing_path "${path}"; then
    product_count=$((product_count + 1))
    product_paths="${product_paths}${path}
"
  fi
done < <(changed_files)

if [[ "${product_count}" -eq 0 ]]; then
  echo "${SCRIPT_NAME}: OK — no product-bearing paths changed"
  exit 0
fi

BODY="$(event_body || true)"
BODY_FLAT="$(printf '%s\n' "${BODY}" | tr '\r\t' '  ' | awk 'BEGIN { sep="" } { printf "%s%s", sep, $0; sep=" | " } END { print "" }' | sed 's/[[:space:]][[:space:]]*/ /g')"

SELF_RE='(sfs[[:space:]]+review[[:space:]]+--gate[[:space:]]+6[[:space:]]+--stage[[:space:]]+self[^.;|]{0,120}(PASS|PASSED)|sfs[[:space:]]+review[[:space:]]+--stage[[:space:]]+self[[:space:]]+--gate[[:space:]]+6[^.;|]{0,120}(PASS|PASSED)|review_stage[[:space:]]*:[[:space:]]*`?self`?[^.;|]{0,120}verdict[[:space:]]*:[[:space:]]*`?pass`?|verdict[[:space:]]*:[[:space:]]*`?pass`?[^.;|]{0,120}review_stage[[:space:]]*:[[:space:]]*`?self`?|Gate[[:space:]]*6[[:space:]-]+self[[:space:]-]*CPO[[:space:]]+PASS)'
CROSS_RE='(sfs[[:space:]]+review[[:space:]]+--gate[[:space:]]+6[[:space:]]+--stage[[:space:]]+cross[^.;|]{0,120}(PASS|PASSED)|sfs[[:space:]]+review[[:space:]]+--stage[[:space:]]+cross[[:space:]]+--gate[[:space:]]+6[^.;|]{0,120}(PASS|PASSED)|review_stage[[:space:]]*:[[:space:]]*`?cross`?[^.;|]{0,120}verdict[[:space:]]*:[[:space:]]*`?pass`?|verdict[[:space:]]*:[[:space:]]*`?pass`?[^.;|]{0,120}review_stage[[:space:]]*:[[:space:]]*`?cross`?|Gate[[:space:]]*6[[:space:]-]+cross[[:space:]-]*CPO[[:space:]]+PASS)'
FALLBACK_RE='(no[[:space:]-]+other[[:space:]-]+agent[[:space:]-]+subscription|external[[:space:]-]+agent[[:space:]-]+tokens?[[:space:]-]+exhausted|cross[[:space:]-]*review[[:space:]-]*bridge[[:space:]-]*unavailable|cross[[:space:]-]*review[[:space:]-]*unavailable|cross_review_unavailable)'
GITHUB_ONLY_RE='(@codex|GitHub[[:space:]-]+check[[:space:]]+PASS|PR[[:space:]-]+approval|GitHub[[:space:]-]+review)'

self_ok=false
cross_or_fallback_ok=false
github_signal=false

body_has_regex "${SELF_RE}" && self_ok=true
if body_has_regex "${CROSS_RE}" || body_has_regex "${FALLBACK_RE}"; then
  cross_or_fallback_ok=true
fi
body_has_regex "${GITHUB_ONLY_RE}" && github_signal=true

if [[ "${self_ok}" != "true" || "${cross_or_fallback_ok}" != "true" ]]; then
  {
    echo "${SCRIPT_NAME}: product-bearing changed paths:"
    printf '%s' "${product_paths}" | sed 's/^/  - /'
    echo
    echo "Required PR body evidence:"
    echo "  - self-CPO PASS: sfs review --gate 6 --stage self: PASS"
    echo "  - cross CPO PASS: sfs review --gate 6 --stage cross: PASS"
    echo "    or concrete fallback reason: no other agent subscription, external agent token exhaustion, or cross-review bridge unavailability"
    if [[ "${github_signal}" == "true" ]]; then
      echo "GitHub @codex/PR/check evidence was present, but it is external evidence only and does not satisfy SFS self/cross review."
    fi
  } >&2
  fail_or_warn "formal SFS Gate 6 self/cross review evidence is missing for product PR"
  exit $?
fi

echo "${SCRIPT_NAME}: OK — product PR carries formal SFS Gate 6 self/cross evidence (${product_count} product paths)"
