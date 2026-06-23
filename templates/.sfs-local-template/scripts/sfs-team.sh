#!/usr/bin/env bash
# .sfs-local/scripts/sfs-team.sh
#
# Solon SFS — multi-agent team topology resolver (read-only, data-driven).
#
# OCP 1원칙: runtime 은 데이터(model-profiles.yaml: runtime_registry)로 안다.
# 본 스크립트는 분기 코드가 아니라 데이터를 조회만 한다 — agent enum 하드코딩 0.
# 역할 재배치나 새 CLI 추가는 model-profiles.yaml 편집만으로 끝나고 본 파일은
# 한 글자도 바뀌지 않는다(test-team-runtime-ocp.sh 가 그 불변을 잠근다).
#
# 본 P1 표면은 resolution(데이터 조회)까지만 한다. 실제 CLI 호출(dispatch
# 실행)은 P3 (`sfs dispatch`) 에서 이 resolver 위에 얹는다 — 여기서는 어떤
# 외부 CLI 도 spawn 하지 않는다.
#
# Subcommands:
#   resolve-runtime <token>   token(cluster lead/worker/researcher 또는 개별
#                             role)을 agent_runtime_bindings 로 조회 → 없으면
#                             configuration.selected_runtime 으로 fallback.
#                             (unassigned_role_policy: use_selected_runtime.)
#   resolve-invoke <runtime>  runtime_registry.<runtime>.invoke 템플릿을 출력.
#                             없으면 빈 줄(standalone 에서 dispatch off 이므로
#                             호출되지 않음 — crash 금지).
#   preset-bindings <preset>  team_preset_catalog.<preset> 의 binding 묶음을
#                             `key: value` 라인으로 방출(install/upgrade 가
#                             agent_runtime_bindings 블록을 채울 때 사용). solo/
#                             미정의/빈 묶음 → 빈 출력. 새 preset 추가 = 카탈로그
#                             편집만 → install 코드 diff 0 (OCP). read-only.
#   show                      현재 team_preset / bindings / registry 키 요약.
#
# Exit codes: 0 ok(미발견 fallback/빈출력 포함), 7 usage.

set -euo pipefail

SFS_LOCAL_DIR="${SFS_LOCAL_DIR:-.sfs-local}"
MP="${SFS_MODEL_PROFILES:-${SFS_LOCAL_DIR}/model-profiles.yaml}"
SFS_EXIT_USAGE=7

usage() {
  cat <<'EOF'
Usage:
  sfs team resolve-runtime <token>   role/cluster → runtime (fallback: selected_runtime)
  sfs team resolve-invoke <runtime>  runtime → registry invoke template (empty if absent)
  sfs team preset-bindings <preset>  preset → agent_runtime_bindings lines (empty for solo)
  sfs team resolve-transport <rt>    runtime → transport_kind (argv|stdin|file; argv default)
  sfs team show                      summarize team_preset / bindings / registry

Resolution is pure data lookup over .sfs-local/model-profiles.yaml. Default solo
(team_preset: solo, empty bindings) → every token falls back to selected_runtime,
so removing the team sections degrades cleanly to standalone solo behavior.
EOF
}

# configuration.selected_runtime (the standalone fallback).
read_selected_runtime() {
  [[ -f "${MP}" ]] || return 0
  awk '
    /^configuration:/ { inc=1; next }
    inc && /^[[:space:]]+selected_runtime:/ {
      v=$0
      sub(/^[[:space:]]+selected_runtime:[[:space:]]*/, "", v)
      sub(/[[:space:]]*#.*/, "", v)
      gsub(/["\047]/, "", v)
      sub(/[[:space:]]*$/, "", v)
      print v; exit
    }
    inc && /^[A-Za-z_]/ { inc=0 }
  ' "${MP}"
}

# agent_runtime_bindings[<key>] — block-style flat map only (solo uses `{}`).
read_binding() {
  local key="$1"
  [[ -f "${MP}" ]] || return 0
  awk -v want="${key}" '
    /^agent_runtime_bindings:/ { inb=1; next }
    inb && /^[A-Za-z_]/ { inb=0 }
    inb {
      line=$0
      if (match(line, /^[[:space:]]+[A-Za-z0-9_-]+:[[:space:]]*/)) {
        k=line; sub(/^[[:space:]]+/, "", k); sub(/:.*/, "", k)
        if (k == want) {
          v=line
          sub(/^[[:space:]]+[A-Za-z0-9_-]+:[[:space:]]*/, "", v)
          sub(/[[:space:]]*#.*/, "", v)
          gsub(/["\047]/, "", v)
          sub(/[[:space:]]*$/, "", v)
          if (v != "" && v !~ /^[{]/) { print v; exit }
        }
      }
    }
  ' "${MP}"
}

# runtime_registry.<runtime>.invoke
read_invoke() {
  local rt="$1"
  [[ -f "${MP}" ]] || return 0
  awk -v want="${rt}" '
    /^runtime_registry:/ { inr=1; next }
    inr && /^[A-Za-z_]/ { inr=0 }
    inr && /^  [A-Za-z0-9_-]+:/ {
      name=$0; sub(/^  /, "", name); sub(/:.*/, "", name)
      cur = (name == want) ? 1 : 0
      next
    }
    inr && cur && /^[[:space:]]+invoke:[[:space:]]*/ {
      v=$0
      sub(/^[[:space:]]+invoke:[[:space:]]*/, "", v)
      sub(/^"/, "", v); sub(/"[[:space:]]*$/, "", v)
      sub(/^\x27/, "", v); sub(/\x27[[:space:]]*$/, "", v)
      print v; exit
    }
  ' "${MP}"
}

# team_preset_catalog.<preset> → emit each `key: value` binding line.
# Block-style nested map only; `<preset>: {}` (inline empty) emits nothing.
read_preset_bindings() {
  local preset="$1"
  [[ -f "${MP}" ]] || return 0
  awk -v want="${preset}" '
    /^team_preset_catalog:/ { inc=1; next }
    inc && /^[A-Za-z_]/ { inc=0 }
    inc && /^  [A-Za-z0-9_-]+:/ {
      name=$0; sub(/^  /, "", name); sub(/:.*/, "", name)
      cur = (name == want) ? 1 : 0
      next
    }
    inc && cur && /^    [A-Za-z0-9_-]+:[[:space:]]*/ {
      line=$0; sub(/^    /, "", line)
      k=line; sub(/:.*/, "", k)
      v=line; sub(/^[A-Za-z0-9_-]+:[[:space:]]*/, "", v)
      sub(/[[:space:]]*#.*/, "", v); gsub(/["\047]/, "", v); sub(/[[:space:]]*$/, "", v)
      if (v != "" && v !~ /^[{]/) { printf "%s: %s\n", k, v }
    }
  ' "${MP}"
}

# runtime_registry.<runtime>.transport_kind (P3). argv if absent/unknown.
read_transport() {
  local rt="$1"
  [[ -f "${MP}" ]] || { printf 'argv'; return 0; }
  local v
  v="$(awk -v want="${rt}" '
    /^runtime_registry:/ { inr=1; next }
    inr && /^[A-Za-z_]/ { inr=0 }
    inr && /^  [A-Za-z0-9_-]+:/ {
      name=$0; sub(/^  /, "", name); sub(/:.*/, "", name)
      cur = (name == want) ? 1 : 0
      next
    }
    inr && cur && /^[[:space:]]+transport_kind:[[:space:]]*/ {
      x=$0
      sub(/^[[:space:]]+transport_kind:[[:space:]]*/, "", x)
      sub(/[[:space:]]*#.*/, "", x); gsub(/["\047]/, "", x); sub(/[[:space:]]*$/, "", x)
      print x; exit
    }
  ' "${MP}")"
  case "${v}" in
    argv|stdin|file) printf '%s' "${v}" ;;
    *) printf 'argv' ;;
  esac
}

cmd="${1:-}"
case "${cmd}" in
  resolve-runtime)
    token="${2:-}"
    [[ -n "${token}" ]] || { echo "resolve-runtime: missing <token>" >&2; usage >&2; exit "${SFS_EXIT_USAGE}"; }
    rt="$(read_binding "${token}")"
    if [[ -z "${rt}" ]]; then
      rt="$(read_selected_runtime)"   # unassigned_role_policy: use_selected_runtime
    fi
    printf '%s\n' "${rt}"
    ;;
  resolve-invoke)
    rt="${2:-}"
    [[ -n "${rt}" ]] || { echo "resolve-invoke: missing <runtime>" >&2; usage >&2; exit "${SFS_EXIT_USAGE}"; }
    printf '%s\n' "$(read_invoke "${rt}")"
    ;;
  preset-bindings)
    preset="${2:-}"
    [[ -n "${preset}" ]] || { echo "preset-bindings: missing <preset>" >&2; usage >&2; exit "${SFS_EXIT_USAGE}"; }
    read_preset_bindings "${preset}"
    ;;
  resolve-transport)
    rt="${2:-}"
    [[ -n "${rt}" ]] || { echo "resolve-transport: missing <runtime>" >&2; usage >&2; exit "${SFS_EXIT_USAGE}"; }
    printf '%s\n' "$(read_transport "${rt}")"
    ;;
  show)
    preset="$([[ -f "${MP}" ]] && awk '/^team_preset:/ {v=$0; sub(/^team_preset:[[:space:]]*/,"",v); sub(/[[:space:]]*#.*/,"",v); gsub(/[[:space:]]/,"",v); print v; exit}' "${MP}")"
    printf 'team_preset: %s\n' "${preset:-<none>}"
    printf 'selected_runtime: %s\n' "$(read_selected_runtime)"
    printf 'runtimes:'
    if [[ -f "${MP}" ]]; then
      awk '
        /^runtime_registry:/ { inr=1; next }
        inr && /^[A-Za-z_]/ { inr=0 }
        inr && /^  [A-Za-z0-9_-]+:/ {
          name=$0; sub(/^  /, "", name); sub(/:.*/, "", name); printf " %s", name
        }
      ' "${MP}"
    fi
    printf '\n'
    ;;
  ""|-h|--help|help)
    usage
    ;;
  *)
    echo "unknown subcommand: ${cmd}" >&2
    usage >&2
    exit "${SFS_EXIT_USAGE}"
    ;;
esac
