#!/usr/bin/env bash
# sfs-bootstrap-skeleton-signature.sh — detect skeleton (zero-feature) signature.
#
# Returns exit 0 if the target dir matches the skeleton signature
# (no feature endpoints, no real tests beyond contextLoads, only boilerplate),
# enabling G6 review auto-skip via R-A integration.
# Returns exit 1 if the dir has been featured-up (normal G6 review path).
#
# Usage:
#   sfs-bootstrap-skeleton-signature.sh <project-dir>
#
# Exit codes:
#   0  skeleton detected (auto-skip G6)
#   1  features detected (normal G6 review)
#   2  invalid arg (no dir / not a dir)
#
# AC reference: AC-func-5 (skeleton autodetect → review skip), AC-rev-2 (review docs 합성 0).

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
  cat <<'EOF'
sfs-bootstrap-skeleton-signature — detect skeleton (zero-feature) signature

Usage:
  sfs-bootstrap-skeleton-signature.sh <project-dir>

Exit codes:
  0  skeleton (no endpoints, no real tests, only boilerplate)
  1  features detected
  2  invalid arg
EOF
}

main() {
  if [[ $# -lt 1 ]]; then
    usage >&2
    return 2
  fi

  case "$1" in
    -h|--help|help)
      usage
      return 0
      ;;
  esac

  local target="$1"
  if [[ ! -d "${target}" ]]; then
    echo "${SCRIPT_NAME}: '${target}' is not a directory" >&2
    return 2
  fi

  # Endpoint annotations we treat as "feature presence".
  local endpoint_count=0 endpoint_files
  if [[ -d "${target}/src/main/kotlin" ]]; then
    # `grep -rlE` exits non-zero on zero matches; capture defensively.
    endpoint_files="$(grep -rlE '@(RestController|Controller|RequestMapping|GetMapping|PostMapping|PutMapping|DeleteMapping|PatchMapping|RequestBody|RequestParam|PathVariable|RestControllerAdvice|ControllerAdvice|RouterFunction)' \
      "${target}/src/main/kotlin" 2>/dev/null || true)"
    if [[ -n "${endpoint_files}" ]]; then
      endpoint_count="$(printf '%s\n' "${endpoint_files}" | grep -c .)"
    fi
  fi

  # Real tests = @Test occurrences excluding ApplicationTests.contextLoads boilerplate.
  local test_count=0
  if [[ -d "${target}/src/test/kotlin" ]]; then
    local raw_test_files
    raw_test_files="$(grep -rlE '@Test([^a-zA-Z_]|$)' "${target}/src/test/kotlin" 2>/dev/null || true)"
    if [[ -n "${raw_test_files}" ]]; then
      while IFS= read -r f; do
        [[ -n "${f}" ]] || continue
        local at_count=0 cl_count=0
        at_count="$(grep -cE '@Test([^a-zA-Z_]|$)' "${f}" 2>/dev/null || true)"
        [[ -z "${at_count}" ]] && at_count=0
        if [[ "$(basename "${f}")" == "ApplicationTests.kt" ]]; then
          cl_count="$(grep -cE 'fun[[:space:]]+contextLoads' "${f}" 2>/dev/null || true)"
          [[ -z "${cl_count}" ]] && cl_count=0
          if (( at_count > cl_count )); then
            test_count=$((test_count + at_count - cl_count))
          fi
        else
          test_count=$((test_count + at_count))
        fi
      done <<<"${raw_test_files}"
    fi
  fi

  # Source kotlin file count, excluding the canonical boilerplate Application.kt + ApplicationTests.kt.
  local src_count=0
  if [[ -d "${target}/src" ]]; then
    src_count="$(find "${target}/src" -type f -name '*.kt' \
      ! -name 'Application.kt' ! -name 'ApplicationTests.kt' 2>/dev/null | grep -c . || true)"
    [[ -z "${src_count}" ]] && src_count=0
  fi

  # Skeleton signature: zero endpoints + zero non-boilerplate tests + zero extra source files.
  if (( endpoint_count == 0 && test_count == 0 && src_count == 0 )); then
    return 0
  fi

  return 1
}

main "$@"
