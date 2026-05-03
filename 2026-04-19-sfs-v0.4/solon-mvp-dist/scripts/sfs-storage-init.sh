#!/usr/bin/env bash
# sfs-storage-init.sh — Layer 1/2 path schema 생성/검증.
#
# Layer 1 (영구 docs/<domain>/<sub>/<feat>/) + Layer 2 (작업 .solon/sprints/<S-id>/<feat>/)
# 생성 + 검증. 본 script 는 R-B B-1/B-2 spec 정합 (storage-architecture-spec.md 참조).
#
# Usage:
#   sfs storage init [--check] [--domain <d>] [--sub <s>] [--feat <f>] [--sprint-id <S>]
#   sfs storage init --validate <root>   # 기존 layout schema 정합 검증 only
#
# Exit codes:
#   0  = OK (생성 성공 또는 schema 정합)
#   1  = generic error
#   2  = invalid arg
#   3  = schema mismatch (validate mode)
#
# AC reference: AC2.1 (Layer 1 path 생성), AC2.2 (Layer 2 path 생성), anti-AC2 (도메인 hardcoding 0).

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

# Slug regex: lowercase alphanumeric + dash, 1~64 chars (POSIX-portable, no domain hardcoding).
SLUG_RE='^[a-z0-9][a-z0-9-]{0,63}$'

usage() {
  cat <<'EOF'
sfs-storage-init — Layer 1/2 path schema 생성/검증

Usage:
  sfs storage init [--check] [--domain <d>] [--sub <s>] [--feat <f>] [--sprint-id <S>]
  sfs storage init --validate <root>

Modes:
  (default)        Layer 1 (docs/<domain>/<sub>/<feat>/) + Layer 2 (.solon/sprints/<S>/<feat>/) 생성
  --check          dry-run, 실 mkdir 0
  --validate <r>   기존 layout schema 정합 verify only (mkdir 0)

Required when not --validate:
  --domain <d>     Layer 1 도메인 (free string, 도메인 hardcoding 금지 — anti-AC2)
  --sub <s>        Layer 1 sub (free string)
  --feat <f>       feature 이름 (free string)
  --sprint-id <S>  Layer 2 sprint id (e.g. 0-6-0-product-implement)

Slug rule (all of --domain/--sub/--feat/--sprint-id):
  lowercase alphanumeric + dash, 1~64 chars. regex: [a-z0-9][a-z0-9-]{0,63}
EOF
}

validate_slug() {
  local label="$1" value="$2"
  if [[ -z "${value}" ]]; then
    echo "${SCRIPT_NAME}: ${label} is empty" >&2
    return 2
  fi
  if ! [[ "${value}" =~ ${SLUG_RE} ]]; then
    echo "${SCRIPT_NAME}: ${label} '${value}' violates slug rule (lowercase alnum + dash, 1~64)" >&2
    return 2
  fi
  return 0
}

# arg parse
mode="create"
check=0
domain=""
sub=""
feat=""
sprint_id=""
validate_root=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help|help)
      usage
      exit 0
      ;;
    --check)
      check=1
      shift
      ;;
    --domain)
      domain="${2:-}"
      shift 2 || { echo "missing value for --domain" >&2; exit 2; }
      ;;
    --sub)
      sub="${2:-}"
      shift 2 || { echo "missing value for --sub" >&2; exit 2; }
      ;;
    --feat)
      feat="${2:-}"
      shift 2 || { echo "missing value for --feat" >&2; exit 2; }
      ;;
    --sprint-id)
      sprint_id="${2:-}"
      shift 2 || { echo "missing value for --sprint-id" >&2; exit 2; }
      ;;
    --validate)
      mode="validate"
      validate_root="${2:-}"
      shift 2 || { echo "missing value for --validate" >&2; exit 2; }
      ;;
    *)
      echo "${SCRIPT_NAME}: unknown arg: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "${mode}" in
  create)
    if [[ -z "${domain}" || -z "${sub}" || -z "${feat}" || -z "${sprint_id}" ]]; then
      echo "${SCRIPT_NAME}: --domain, --sub, --feat, --sprint-id 모두 필요 (or use --validate)" >&2
      usage >&2
      exit 2
    fi
    validate_slug "--domain" "${domain}" || exit 2
    validate_slug "--sub" "${sub}" || exit 2
    validate_slug "--feat" "${feat}" || exit 2
    validate_slug "--sprint-id" "${sprint_id}" || exit 2

    layer1_path="docs/${domain}/${sub}/${feat}"
    layer2_path=".solon/sprints/${sprint_id}/${feat}"

    # Co-location pre-flight: 같은 feat 가 다른 Layer 1 (다른 domain/sub) 에 이미 존재?
    if [[ -d "docs" ]]; then
      while IFS= read -r existing; do
        existing="${existing%/}"
        if [[ "${existing}" != "${layer1_path}" ]]; then
          echo "${SCRIPT_NAME}: co-location warning — feat '${feat}' already exists at: ${existing}" >&2
          # warn-only (not fail) — same feat across multiple domains may be intentional in some cases.
        fi
      done < <(find docs -mindepth 3 -maxdepth 3 -type d -name "${feat}" 2>/dev/null || true)
    fi

    if [[ "${check}" == "1" ]]; then
      printf 'sfs-storage-init: dry-run — would create:\n  %s/\n  %s/\n' "${layer1_path}" "${layer2_path}"
      exit 0
    fi

    mkdir -p "${layer1_path}" "${layer2_path}"
    [[ -e "${layer1_path}/.gitkeep" ]] || : > "${layer1_path}/.gitkeep"
    [[ -e "${layer2_path}/.gitkeep" ]] || : > "${layer2_path}/.gitkeep"
    printf 'sfs-storage-init: created %s/ + %s/\n' "${layer1_path}" "${layer2_path}"
    ;;
  validate)
    if [[ -z "${validate_root}" ]]; then
      echo "${SCRIPT_NAME}: --validate <root> requires path arg" >&2
      exit 2
    fi
    if [[ ! -d "${validate_root}" ]]; then
      echo "${SCRIPT_NAME}: validate root not a directory: ${validate_root}" >&2
      exit 1
    fi

    fail=0

    # Layer 1: docs/<domain>/<sub>/<feat>/ — depth 3 dirs must satisfy slug rule.
    if [[ -d "${validate_root}/docs" ]]; then
      while IFS= read -r dir; do
        rel="${dir#${validate_root}/docs/}"
        IFS=/ read -r d s f <<< "${rel}"
        for label_value_pair in "domain:${d}" "sub:${s}" "feat:${f}"; do
          label="${label_value_pair%%:*}"
          value="${label_value_pair#*:}"
          if [[ -n "${value}" ]] && ! [[ "${value}" =~ ${SLUG_RE} ]]; then
            echo "${SCRIPT_NAME}: schema fail — Layer 1 ${label} '${value}' (path: docs/${rel}/) violates slug" >&2
            fail=$((fail + 1))
          fi
        done
      done < <(find "${validate_root}/docs" -mindepth 3 -maxdepth 3 -type d 2>/dev/null || true)
    fi

    # Layer 2: .solon/sprints/<S-id>/<feat>/ — depth 2 dirs.
    if [[ -d "${validate_root}/.solon/sprints" ]]; then
      while IFS= read -r dir; do
        rel="${dir#${validate_root}/.solon/sprints/}"
        IFS=/ read -r sid f <<< "${rel}"
        for label_value_pair in "sprint-id:${sid}" "feat:${f}"; do
          label="${label_value_pair%%:*}"
          value="${label_value_pair#*:}"
          if [[ -n "${value}" ]] && ! [[ "${value}" =~ ${SLUG_RE} ]]; then
            echo "${SCRIPT_NAME}: schema fail — Layer 2 ${label} '${value}' (path: .solon/sprints/${rel}/) violates slug" >&2
            fail=$((fail + 1))
          fi
        done
      done < <(find "${validate_root}/.solon/sprints" -mindepth 2 -maxdepth 2 -type d 2>/dev/null || true)
    fi

    if [[ "${fail}" -gt 0 ]]; then
      echo "${SCRIPT_NAME}: validate FAIL — ${fail} schema mismatch" >&2
      exit 3
    fi
    printf 'sfs-storage-init: validate OK — %s\n' "${validate_root}"
    exit 0
    ;;
esac
