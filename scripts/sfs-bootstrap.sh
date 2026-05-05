#!/usr/bin/env bash
# sfs-bootstrap.sh — Stack-explicit project bootstrap.
#
# Default behavior is an agent-facing conversational setup trigger. Solon does
# not create app skeletons itself; the current AI/native tool should infer the
# right starter from the user's plain-language goal, ask for consent, build it,
# then return to SFS. Non-developers should not have to know this command exists.
#
# 0.6.0 also ships the first measured template only: spring-kotlin.
# FastAPI / NestJS / React / Next.js / Vue / Nuxt and other stacks must be added
# as explicit future stack packs; bare `sfs bootstrap ...` must not silently default
# to Spring/Kotlin.
#
# spring-kotlin quick mode: skeleton only, autodetect → G6 review skip via R-C signature.
# spring-kotlin refresh mode: Spring Initializr API → cache verify, graceful 4-case fallback.
#
# Usage:
#   sfs bootstrap [<what the user wants to build...>]  # agent-facing handoff
#   sfs bootstrap --experimental spring-kotlin [<project-name>] [--quick] [--refresh] [--java-version 21]
#   sfs bootstrap --experimental --stack spring-kotlin [<project-name>] [--quick] [--refresh] [--java-version 21]
#                 [--spring-boot 3.3.6] [--package <pkg>] [--no-review]
#                 [--force] [--yes]
#
# Exit codes:
#   0  OK (project created)
#   1  existing target dir without --force, or generic error
#   2  invalid arg, or template cache absent
#
# AC reference: AC-func-1 (idempotency guard), AC-func-4 (graceful degradation 4-case),
# AC-func-5 (skeleton autodetect → R-C), AC-func-6 (override flag), AC-perf-4 (file-level),
# AC-perf-5 (alive heartbeat via R-D scripts/sfs-measure.sh + SFS_ALIVE_THRESHOLD_SECS).
# γ scope (chunk-2): AC-func-2/3 (./gradlew build/test) DEFER to chunk-3 manual measurement.

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

# Defaults (override via flags or env)
DEFAULT_JAVA_VERSION="${SFS_BOOTSTRAP_JAVA_VERSION:-21}"
DEFAULT_SPRING_BOOT_VERSION="${SFS_BOOTSTRAP_SPRING_BOOT_VERSION:-3.3.6}"
DEFAULT_PACKAGE="${SFS_BOOTSTRAP_PACKAGE:-com.example.demo}"
DEFAULT_PROJECT_NAME="${SFS_BOOTSTRAP_PROJECT_NAME:-myproject}"
INITIALIZR_API="${SFS_INITIALIZR_API:-https://start.spring.io}"
SUPPORTED_STACKS="spring-kotlin"

# Parsed config
EXPERIMENTAL=0
STACK="${SFS_BOOTSTRAP_STACK:-}"
PROJECT_NAME=""
QUICK=1
REFRESH=0
JAVA_VERSION="${DEFAULT_JAVA_VERSION}"
SPRING_BOOT_VERSION="${DEFAULT_SPRING_BOOT_VERSION}"
PACKAGE="${DEFAULT_PACKAGE}"
NO_REVIEW=0
FORCE=0
YES=0

# Slug rule (POSIX-portable, no domain hardcoding)
SLUG_RE='^[a-z0-9][a-z0-9-]{0,63}$'

usage() {
  cat <<'EOF'
sfs-bootstrap — Stack-explicit project bootstrap

Usage:
  sfs bootstrap [<what the user wants to build...>]
  sfs bootstrap --experimental spring-kotlin [<project-name>] [--quick] [--refresh] [--java-version 21]
  sfs bootstrap --experimental --stack spring-kotlin [<project-name>] [--quick] [--refresh] [--java-version 21]
                [--spring-boot 3.3.6] [--package <pkg>] [--no-review]
                [--force] [--yes]

Intent:
  Solon does not try to beat native AI/framework scaffolders at app generation.
  Non-developers should not need to know words like Next.js, Spring, Java, or API.
  The default `sfs bootstrap ...` path is an agent-facing trigger for the current AI session:
  infer the likely starter from the user's goal, ask "초기 프로젝트 구성해드릴까요?",
  create the app with Claude/Codex/Gemini or the framework's own CLI after consent,
  then return to Solon with:
    sfs init --layout thin --yes
    sfs start "<goal>"

Supported stacks in 0.6.0:
  spring-kotlin       experimental measurement helper for this hotfix

Not implied by 0.6.0:
  fastapi, nestjs, react, nextjs, vue, nuxt, and other stacks are future stack packs.
  Bare `sfs bootstrap ...` does not create Spring/Kotlin files. It prints an
  agent action handoff and exits 0 so the current AI can offer and execute the
  right native setup in the same session. End users can simply describe what
  they want to build during brainstorm.

Experimental Spring/Kotlin modes:
  (default --quick)  skeleton-only project for the selected experimental stack
  --refresh          spring-kotlin only: re-fetch template from Spring Initializr API
  --no-review        force-skip skeleton-signature emit (rare; explicit override)

Required for experimental helper:
  <project-name>     target directory name (slug: [a-z0-9][a-z0-9-]{0,63}). default: myproject

Override flags (AC-func-6):
  --java-version N        JDK version (default 21)
  --spring-boot V         Spring Boot version (default 3.3.6)
  --package P             Java package (default com.example.demo)

Idempotency guard (AC-func-1):
  existing target dir       → exit 1 (default).
  --force                   → confirm overwrite (interactive prompt y/N).
  --force --yes             → skip prompt + immediately rm -rf + recreate (CI mode).

Graceful degradation for --refresh (AC-func-4):
  (a) network OK + API 2xx  → cache verified + exit 0
  (b) network OK + API 4xx  → hard fail + exit 2 (invalid request/input)
  (c) network OK + API 5xx  → fallback to cache + exit 0 (warn)
  (d) network OFF           → fallback to cache + exit 0 (warn)
  (e) cache absent          → exit 2 (hard fail; --refresh required network)

Alive heartbeat (R-D / AC-perf-5):
  SFS_ALIVE_THRESHOLD_SECS    seconds before [alive] stderr emit. prod 30, test 2.

Exit codes:
  0  OK
  1  existing dir (no --force) or generic
  2  invalid arg or cache absent
EOF
}

validate_slug() {
  local label="$1" value="$2"
  if [[ -z "${value}" ]]; then
    echo "${SCRIPT_NAME}: ${label} is empty" >&2
    return 2
  fi
  if ! [[ "${value}" =~ ${SLUG_RE} ]]; then
    echo "${SCRIPT_NAME}: ${label} '${value}' violates slug rule (lowercase alnum + dash, 1-64)" >&2
    return 2
  fi
  return 0
}

validate_stack() {
  if [[ -z "${STACK}" ]]; then
    echo "${SCRIPT_NAME}: bootstrap stack is required; Spring/Kotlin is not the generic default." >&2
    echo "${SCRIPT_NAME}: use: sfs bootstrap --experimental spring-kotlin <project-name> --quick" >&2
    echo "${SCRIPT_NAME}: or:  sfs bootstrap --experimental --stack spring-kotlin <project-name> --quick" >&2
    echo "${SCRIPT_NAME}: future stack packs should be explicit (fastapi, nestjs, react, nextjs, vue, nuxt, ...)." >&2
    return 2
  fi
  if [[ "${STACK}" != "spring-kotlin" ]]; then
    echo "${SCRIPT_NAME}: unsupported bootstrap stack '${STACK}'" >&2
    echo "${SCRIPT_NAME}: supported in 0.6.0: ${SUPPORTED_STACKS}" >&2
    echo "${SCRIPT_NAME}: future stack packs should be added explicitly, not hidden behind Spring/Kotlin defaults." >&2
    return 2
  fi
  return 0
}

require_experimental() {
  if [[ "${EXPERIMENTAL}" == "1" ]]; then
    return 0
  fi
  print_native_handoff "$@"
  return 0
}

has_experimental_flag() {
  local arg
  for arg in "$@"; do
    if [[ "${arg}" == "--experimental" ]]; then
      return 0
    fi
  done
  return 1
}

print_native_handoff() {
  local request="$*"
  if [[ -z "${request}" ]]; then
    request="<infer from the conversation; ask what they want to make only if unclear>"
  fi
  cat >&2 <<'EOF'
sfs-bootstrap: initial project setup trigger captured.

Solon should not keep a framework generator surface just to make a blank app.
For non-developers, infer the right starter from what they want to build; do not
ask them to choose between Next.js, Spring, FastAPI, NestJS, Vue, etc. unless
that choice is genuinely necessary.
Leave only the setup, context, and operating records that will matter after the
first app skeleton exists.
EOF
  printf '\nRequest:\n  %s\n\n' "${request}" >&2
  cat >&2 <<'EOF'
Agent action:
  1. From the conversation, infer whether an initial project/app skeleton is useful.
  2. If useful and not already approved, ask in plain language:
       "초기 프로젝트 구성해드릴까요?"
  3. If the user says yes, pick a starter size that matches the goal:
       - tiny: static page / prototype / no backend
       - small: frontend app with simple local state or mock data
       - medium: app + API/server + persistence
       - larger: only after explicit scope discussion
  4. Choose the native scaffold path yourself:
       - official framework CLI when appropriate
       - or direct file edits by Claude/Codex/Gemini when that is simpler
  5. Do not add Solon-owned framework template files.
  6. cd into the generated app.
  7. Run `sfs init --layout thin --yes`.
  8. Run `sfs start "<first useful goal>"` or continue the user's requested task.

Experimental measurement helper, not public default:
  sfs bootstrap --experimental spring-kotlin <project-name> --quick
EOF
}

resolve_dist_dir() {
  if [[ -n "${SFS_DIST_DIR:-}" && -d "${SFS_DIST_DIR}/templates" ]]; then
    printf '%s\n' "${SFS_DIST_DIR}"
    return 0
  fi
  local script_dir
  script_dir="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [[ -d "${script_dir}/../templates" ]]; then
    (cd "${script_dir}/.." && pwd)
    return 0
  fi
  echo "${SCRIPT_NAME}: cannot resolve SFS_DIST_DIR (no templates/ found)" >&2
  return 2
}

# Wrap a callable with R-D alive heartbeat. Falls back to direct exec if measure script missing.
run_with_alive() {
  local step_name="$1"; shift
  local measure_script="${DIST_DIR}/scripts/sfs-measure.sh"
  if [[ -x "${measure_script}" ]]; then
    SFS_MEASURE_STEP_NAME="${step_name}" bash "${measure_script}" --alive -- "$@"
    return $?
  fi
  "$@"
}

confirm_overwrite() {
  local target="$1"
  if [[ "${YES}" == "1" ]]; then
    return 0
  fi
  if [[ ! -t 0 ]]; then
    echo "${SCRIPT_NAME}: --force requires --yes for non-interactive overwrite" >&2
    return 1
  fi
  printf 'Overwrite existing %q? [y/N]: ' "${target}" >&2
  local reply
  read -r reply </dev/tty
  case "${reply}" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

# Refresh cache from Spring Initializr API.
# 4xx means bad user/request input and must not silently fall back to cache.
# 5xx / timeout / offline preserve graceful fallback to the local cache.
refresh_cache() {
  local cache_dir="$1"
  local timeout="${SFS_INITIALIZR_TIMEOUT:-30}"
  local tmp_tar url http_code curl_rc
  url="${INITIALIZR_API}/starter.tgz?type=gradle-project-kotlin&language=kotlin&bootVersion=${SPRING_BOOT_VERSION}&javaVersion=${JAVA_VERSION}&packaging=jar&groupId=${PACKAGE%.*}&artifactId=${PROJECT_NAME}&name=${PROJECT_NAME}&packageName=${PACKAGE}&dependencies=web"

  if ! command -v curl >/dev/null 2>&1; then
    echo "${SCRIPT_NAME}: warn: curl not available, falling back to cache" >&2
    return 0
  fi

  tmp_tar="$(mktemp -t "sfs-bootstrap.XXXXXX")" || return 0
  # shellcheck disable=SC2064
  trap "rm -f '${tmp_tar}'" RETURN

  if http_code="$(curl -sSL --max-time "${timeout}" -w '%{http_code}' -o "${tmp_tar}" "${url}" 2>/dev/null)"; then
    curl_rc=0
  else
    curl_rc=$?
  fi

  if [[ "${curl_rc}" != "0" ]]; then
    echo "${SCRIPT_NAME}: warn: --refresh API unreachable (timeout/offline), falling back to cache" >&2
    return 0
  fi

  case "${http_code}" in
    2??)
      if tar -tzf "${tmp_tar}" >/dev/null 2>&1; then
        printf '[refresh] cache verified from API %s\n' "${INITIALIZR_API}" >&2
        return 0
      fi
      echo "${SCRIPT_NAME}: warn: tarball corrupt, falling back to cache" >&2
      return 0
      ;;
    4??)
      echo "${SCRIPT_NAME}: error: --refresh API rejected request (HTTP ${http_code}); check --spring-boot, --java-version, --package, and project name" >&2
      return 2
      ;;
    5??)
      echo "${SCRIPT_NAME}: warn: --refresh API server error (HTTP ${http_code}), falling back to cache" >&2
      return 0
      ;;
    000)
      echo "${SCRIPT_NAME}: warn: --refresh API unreachable (HTTP 000), falling back to cache" >&2
      return 0
      ;;
    *)
      echo "${SCRIPT_NAME}: warn: --refresh API returned unexpected HTTP ${http_code}, falling back to cache" >&2
      return 0
      ;;
  esac
}

substitute_placeholders() {
  local target="$1"
  # Use tr (bash 3.2 + BSD/GNU compat) — bash parameter expansion `${var//./\/}` keeps the `\` on macOS bash 3.2.
  local pkg_path
  pkg_path="$(printf '%s' "${PACKAGE}" | tr '.' '/')"

  # Move package skeleton from __PACKAGE_PATH__ placeholder to actual package path.
  local dir kotlin_main="${target}/src/main/kotlin" kotlin_test="${target}/src/test/kotlin"
  for dir in "${kotlin_main}" "${kotlin_test}"; do
    if [[ -d "${dir}/__PACKAGE_PATH__" ]]; then
      mkdir -p "${dir}/${pkg_path}"
      # shellcheck disable=SC2012
      if [[ -n "$(ls -A "${dir}/__PACKAGE_PATH__" 2>/dev/null)" ]]; then
        mv "${dir}/__PACKAGE_PATH__"/* "${dir}/${pkg_path}/"
      fi
      rmdir "${dir}/__PACKAGE_PATH__" 2>/dev/null || true
    fi
  done

  # Substitute placeholders in all text files (BSD/GNU sed compat).
  # γ scope: templates/spring-kotlin-zero/ is text-only — no JAR / binary in template tree.
  local file sed_inplace=()
  if [[ "$(uname -s)" == "Darwin" ]]; then
    sed_inplace=(-i '')
  else
    sed_inplace=(-i)
  fi
  while IFS= read -r -d '' file; do
    sed "${sed_inplace[@]}" \
      -e "s|<PROJECT-NAME>|${PROJECT_NAME}|g" \
      -e "s|<PACKAGE>|${PACKAGE}|g" \
      -e "s|<PACKAGE_PATH>|${pkg_path}|g" \
      -e "s|<JAVA-VERSION>|${JAVA_VERSION}|g" \
      -e "s|<SPRING-BOOT-VERSION>|${SPRING_BOOT_VERSION}|g" \
      "${file}"
  done < <(find "${target}" -type f -print0)
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "${1}" in
      --experimental) EXPERIMENTAL=1; shift ;;
      --stack) STACK="${2:-}"; shift 2 ;;
      --stack=*) STACK="${1#--stack=}"; shift ;;
      --quick) QUICK=1; shift ;;
      --refresh) REFRESH=1; shift ;;
      --no-quick) QUICK=0; shift ;;
      --java-version) JAVA_VERSION="${2:-}"; shift 2 ;;
      --spring-boot) SPRING_BOOT_VERSION="${2:-}"; shift 2 ;;
      --package) PACKAGE="${2:-}"; shift 2 ;;
      --no-review) NO_REVIEW=1; shift ;;
      --force) FORCE=1; shift ;;
      --yes) YES=1; shift ;;
      -h|--help|help) usage; exit 0 ;;
      --) shift; break ;;
      -*)
        echo "${SCRIPT_NAME}: unknown flag '${1}'" >&2
        usage >&2
        return 2
        ;;
      spring-kotlin)
        if [[ -z "${STACK}" ]]; then
          STACK="spring-kotlin"
          shift
        elif [[ -z "${PROJECT_NAME}" ]]; then
          PROJECT_NAME="${1}"
          shift
        else
          echo "${SCRIPT_NAME}: extra positional arg '${1}'" >&2
          return 2
        fi
        ;;
      *)
        if [[ -z "${PROJECT_NAME}" ]]; then
          PROJECT_NAME="${1}"
          shift
        else
          echo "${SCRIPT_NAME}: extra positional arg '${1}'" >&2
          return 2
        fi
        ;;
    esac
  done
}

main() {
  case "${1:-}" in
    -h|--help|help) usage; return 0 ;;
  esac

  if ! has_experimental_flag "$@"; then
    print_native_handoff "$@"
    return 0
  fi

  parse_args "$@" || return $?

  require_experimental "$@" || return $?
  validate_stack || return 2

  if [[ -z "${PROJECT_NAME}" ]]; then
    PROJECT_NAME="${DEFAULT_PROJECT_NAME}"
  fi

  validate_slug "project-name" "${PROJECT_NAME}" || return 2

  if ! [[ "${JAVA_VERSION}" =~ ^[0-9]+$ ]]; then
    echo "${SCRIPT_NAME}: --java-version must be integer (got '${JAVA_VERSION}')" >&2
    return 2
  fi

  DIST_DIR="$(resolve_dist_dir)" || return 2
  local cache_dir="${DIST_DIR}/templates/spring-kotlin-zero"

  # Graceful degradation case (d): cache absent → hard fail
  if [[ ! -d "${cache_dir}" ]]; then
    echo "${SCRIPT_NAME}: error: template cache absent at ${cache_dir}" >&2
    if [[ "${REFRESH}" == "1" ]]; then
      echo "${SCRIPT_NAME}: --refresh requires network + API access" >&2
    fi
    return 2
  fi

  # Idempotency guard (AC-func-1)
  if [[ -e "${PROJECT_NAME}" ]]; then
    if [[ "${FORCE}" != "1" ]]; then
      echo "${SCRIPT_NAME}: error: target directory '${PROJECT_NAME}' already exists. use --force to overwrite" >&2
      return 1
    fi
    if ! confirm_overwrite "${PROJECT_NAME}"; then
      echo "${SCRIPT_NAME}: cancelled" >&2
      return 1
    fi
    rm -rf -- "${PROJECT_NAME}"
  fi

  # Refresh cache (graceful degradation cases a/b/c). Internal function — direct call.
  if [[ "${REFRESH}" == "1" ]]; then
    refresh_cache "${cache_dir}" || return $?
  fi

  # Copy template — wrapped with alive heartbeat (R-D / AC-perf-5).
  run_with_alive "copy-template" cp -R "${cache_dir}" "${PROJECT_NAME}"

  # Substitute placeholders — internal function, direct call (sub-second on 7 files).
  substitute_placeholders "${PROJECT_NAME}"

  # G6 review skip check via R-C skeleton signature
  local skeleton_sig="${DIST_DIR}/scripts/sfs-bootstrap-skeleton-signature.sh"
  if [[ -x "${skeleton_sig}" && "${NO_REVIEW}" != "1" ]]; then
    if bash "${skeleton_sig}" "${PROJECT_NAME}" >/dev/null 2>&1; then
      printf '[bootstrap] skeleton signature detected — G6 review auto-skip\n' >&2
    fi
  fi

  printf '[bootstrap] %s created (stack=%s java=%s spring-boot=%s package=%s)\n' \
    "${PROJECT_NAME}" "${STACK}" "${JAVA_VERSION}" "${SPRING_BOOT_VERSION}" "${PACKAGE}" >&2
  if [[ ! -f "${PROJECT_NAME}/gradlew" ]]; then
    printf '[bootstrap] hint: Gradle wrapper scripts are not bundled in --quick template; run `gradle wrapper --gradle-version 8.10.2` before `./gradlew build` or `./gradlew test`.\n' >&2
  fi

  return 0
}

main "$@"
