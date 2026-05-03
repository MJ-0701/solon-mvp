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
# Implementation: chunk 1 = skeleton + arg parse + usage. 실 mkdir/validate logic = 다음 chunk (R-B B-1/B-2 따라 살 붙임).

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

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
EOF
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
    layer1_path="docs/${domain}/${sub}/${feat}"
    layer2_path=".solon/sprints/${sprint_id}/${feat}"
    if [[ "${check}" == "1" ]]; then
      printf 'sfs-storage-init: dry-run — would create:\n  %s/\n  %s/\n' "${layer1_path}" "${layer2_path}"
      exit 0
    fi
    # TODO chunk N (R-B B-1/B-2): 실 mkdir + .gitkeep + permission validate + co-location pre-flight.
    # placeholder:
    mkdir -p "${layer1_path}" "${layer2_path}"
    : > "${layer1_path}/.gitkeep"
    : > "${layer2_path}/.gitkeep"
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
    # TODO chunk N (R-B B-1/B-2): 실 schema regex check + Layer 1/Layer 2 정합 + co-location detect.
    # placeholder: 디렉토리 존재만 확인.
    printf 'sfs-storage-init: validate placeholder OK — %s exists (full schema check 다음 chunk)\n' "${validate_root}"
    exit 0
    ;;
esac
