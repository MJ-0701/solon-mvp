#!/usr/bin/env bash
# .sfs-local/scripts/sfs-route.sh
#
# Solon SFS — multi-agent dispatch helper (P3). `sfs route <role> <capsule>`.
#
# 어댑터의 "자기 role 아니면 헬퍼 호출" 규약(design D2/D5)의 1차 메커니즘. P1/P2 의
# data 표면(runtime_registry / agent_runtime_bindings / team_preset_catalog) 위에
# 얹는 얇은 라우터다:
#   1. role → runtime           (sfs-team.sh resolve-runtime)
#   2. runtime → invoke 템플릿    (sfs-team.sh resolve-invoke)
#   3. runtime → transport_kind  (sfs-team.sh resolve-transport: argv|stdin|file)
#   4. capsule(typed 8필드)에서 {prompt}/{tools} 채움
#   5. hop/cycle 가드 통과 시 headless 호출 (token_budget 는 advisory cost 가드)
#
# OCP: 실제 CLI 호출법은 전부 registry 데이터(invoke + transport_kind)다. 새 CLI 추가
# (지원 transport 사용 시)나 전달방식 변경은 model-profiles.yaml 편집만으로 끝나고 본
# 파일은 한 글자도 안 바뀐다. 명령명이 `route` 인 이유: `dispatch` 는 라우터 엔진
# 자체(sfs-dispatch.sh), `handoff` 는 기존 명령이라 둘 다 점유됨(design D5).
#
# Standalone: team_preset 가 solo 거나 registry 가 통째로 없으면(invoke 빈출력) 디스패치
# off 로 판정하고 "직접 수행" 신호(exit 3)를 줄 뿐, 절대 crash 하지 않는다 — dispatch
# 는 라우팅이지 기능 의존성이 아니다.
#
# 실제 외부 CLI 호출은 인증/세션이 필요하므로 본 배포본 테스트에서는 SFS_ROUTE_DRY_RUN=1
# 로 mock 한다(채워진 명령을 출력만). 실호출 경로는 best-effort.
#
# Exit codes: 0 dispatched(또는 dry-run), 3 dispatch-off(직접 수행하라), 7 usage,
#             8 guard 거부(hop 상한/순환).

set -euo pipefail

SFS_LOCAL_DIR="${SFS_LOCAL_DIR:-.sfs-local}"
MP="${SFS_MODEL_PROFILES:-${SFS_LOCAL_DIR}/model-profiles.yaml}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEAM="${SFS_TEAM_RESOLVER:-${SCRIPT_DIR}/sfs-team.sh}"

SFS_EXIT_USAGE=7
SFS_EXIT_GUARD=8
SFS_EXIT_DISPATCH_OFF=3

# 무한 dispatch 방지 가드 (nested 호출에 env 로 전파).
SFS_ROUTE_MAX_HOPS="${SFS_ROUTE_MAX_HOPS:-3}"
SFS_ROUTE_HOP="${SFS_ROUTE_HOP:-0}"
SFS_ROUTE_CHAIN="${SFS_ROUTE_CHAIN:-}"   # 콜론 구분 role 누적 (순환 감지용)

usage() {
  cat <<'EOF'
Usage:
  sfs route <role> <capsule-path>    role 을 적임 runtime 으로 headless 디스패치

Resolves role→runtime→invoke-template→transport from model-profiles.yaml data and
calls the runtime headless with the capsule's {prompt}/{tools}. Refuses (exit 8) on
hop-limit or role cycle, and degrades to "act directly" (exit 3) when dispatch is off
(solo) or the registry is absent. Set SFS_ROUTE_DRY_RUN=1 to print the resolved
command instead of executing. Guards: SFS_ROUTE_MAX_HOPS (default 3), SFS_ROUTE_HOP,
SFS_ROUTE_CHAIN (carried across nested routes).
EOF
}

team() { bash "${TEAM}" "$@"; }

# team_preset scalar (solo 면 dispatch off).
read_preset() {
  [[ -f "${MP}" ]] || return 0
  awk '/^team_preset:/ {v=$0; sub(/^team_preset:[[:space:]]*/,"",v); sub(/[[:space:]]*#.*/,"",v); gsub(/[[:space:]]/,"",v); print v; exit}' "${MP}"
}

# capsule 의 flat `^<key>:` 값(첫 매치). 멀티라인/블록은 미지원(typed 8필드는 스칼라).
capsule_field() {
  local key="$1" file="$2"
  [[ -f "${file}" ]] || return 0
  awk -v want="${key}" '
    $0 ~ "^"want":" {
      v=$0; sub("^"want":[[:space:]]*","",v)
      sub(/[[:space:]]*$/,"",v); gsub(/^["\047]|["\047]$/,"",v)
      print v; exit
    }
  ' "${file}"
}

cmd="${1:-}"
case "${cmd}" in
  ""|-h|--help|help) usage; exit 0 ;;
esac

role="${1:-}"
capsule="${2:-}"
[[ -n "${role}" ]]    || { echo "route: missing <role>" >&2; usage >&2; exit "${SFS_EXIT_USAGE}"; }
[[ -n "${capsule}" ]] || { echo "route: missing <capsule-path>" >&2; usage >&2; exit "${SFS_EXIT_USAGE}"; }
[[ -f "${capsule}" ]] || { echo "route: capsule not found: ${capsule}" >&2; exit "${SFS_EXIT_USAGE}"; }
[[ -f "${TEAM}" ]]    || { echo "route: team resolver not found: ${TEAM}" >&2; exit "${SFS_EXIT_USAGE}"; }

# ── dispatch off? (solo / standalone) → 직접 수행 신호 ──────────────────────
preset="$(read_preset)"
if [[ -z "${preset}" || "${preset}" == "solo" ]]; then
  echo "route: dispatch off (team_preset='${preset:-<none>}') — act directly" >&2
  exit "${SFS_EXIT_DISPATCH_OFF}"
fi

runtime="$(team resolve-runtime "${role}")"
invoke="$(team resolve-invoke "${runtime}")"
if [[ -z "${invoke}" ]]; then
  echo "route: no invoke template for runtime='${runtime:-<none>}' (registry absent) — act directly" >&2
  exit "${SFS_EXIT_DISPATCH_OFF}"
fi
transport="$(team resolve-transport "${runtime}")"

# ── 가드: 순환 + hop 상한 ───────────────────────────────────────────────────
case ":${SFS_ROUTE_CHAIN}:" in
  *":${role}:"*)
    echo "route: cycle detected — role '${role}' already in chain '${SFS_ROUTE_CHAIN}'" >&2
    exit "${SFS_EXIT_GUARD}"
    ;;
esac
if [[ "${SFS_ROUTE_HOP}" -ge "${SFS_ROUTE_MAX_HOPS}" ]]; then
  echo "route: hop limit reached (${SFS_ROUTE_HOP}/${SFS_ROUTE_MAX_HOPS}) — refusing further dispatch" >&2
  exit "${SFS_EXIT_GUARD}"
fi
next_hop=$((SFS_ROUTE_HOP + 1))
next_chain="${SFS_ROUTE_CHAIN:+${SFS_ROUTE_CHAIN}:}${role}"

# ── capsule → prompt / tools ────────────────────────────────────────────────
goal="$(capsule_field goal "${capsule}")"
[[ -n "${goal}" ]] || { echo "route: capsule missing required 'goal' field" >&2; exit "${SFS_EXIT_USAGE}"; }
ac="$(capsule_field acceptance_criteria "${capsule}")"
files="$(capsule_field files_scope "${capsule}")"
outp="$(capsule_field output_paths "${capsule}")"
tools="$(capsule_field tools_allowed "${capsule}")"
budget="$(capsule_field token_budget "${capsule}")"

prompt="GOAL: ${goal}"
[[ -n "${ac}" ]]    && prompt="${prompt} | AC: ${ac}"
[[ -n "${files}" ]] && prompt="${prompt} | FILES: ${files}"
[[ -n "${outp}" ]]  && prompt="${prompt} | OUTPUT: ${outp}"

# advisory cost 가드 (차단 아님 — product finding 으로 표면화만).
[[ -n "${budget}" ]] && echo "route: advisory token_budget=${budget} (worker 초과 시 product finding)" >&2

# ── invoke 템플릿 채움 + transport 전달 전략 ─────────────────────────────────
cmd_str="${invoke//\{tools\}/${tools}}"
prompt_file=""
case "${transport}" in
  argv)
    cmd_str="${cmd_str//\{prompt\}/${prompt}}"
    delivery="argv (inline {prompt})"
    ;;
  stdin)
    cmd_str="${cmd_str//\{prompt\}/}"
    delivery="stdin (prompt piped)"
    ;;
  file)
    prompt_file="$(mktemp "${TMPDIR:-/tmp}/sfs-route-prompt.XXXXXX")"
    printf '%s\n' "${prompt}" > "${prompt_file}"
    cmd_str="${cmd_str//\{prompt_file\}/${prompt_file}}"
    delivery="file (${prompt_file})"
    ;;
  *)
    cmd_str="${cmd_str//\{prompt\}/${prompt}}"
    delivery="argv (fallback)"
    ;;
esac

# ── 실행 (또는 dry-run mock) ─────────────────────────────────────────────────
if [[ "${SFS_ROUTE_DRY_RUN:-0}" == "1" ]]; then
  printf 'route_dry_run role=%s runtime=%s transport=%s hop=%s->%s chain=%s\n' \
    "${role}" "${runtime}" "${transport}" "${SFS_ROUTE_HOP}" "${next_hop}" "${next_chain}"
  printf 'route_dry_run delivery=%s\n' "${delivery}"
  printf 'route_dry_run command: %s\n' "${cmd_str}"
  [[ "${transport}" == "stdin" ]] && printf 'route_dry_run stdin: %s\n' "${prompt}"
  [[ -n "${prompt_file}" ]] && rm -f "${prompt_file}"
  exit 0
fi

# real exec: guards propagate via env so a worker that itself routes stays bounded.
# ⚠️ SECURITY (future real-exec wiring, P4/Hermes): the eval below substitutes the
# capsule's goal/AC text into the command string. A capsule whose goal contains
# `$(...)`/backticks would execute as shell. The dry-run path (the only one tested
# here) never evals; before wiring real headless calls, build an argv ARRAY per
# transport_kind instead of eval-ing an interpolated string — close the injection seam.
export SFS_ROUTE_HOP="${next_hop}" SFS_ROUTE_CHAIN="${next_chain}"
rc=0
if [[ "${transport}" == "stdin" ]]; then
  printf '%s\n' "${prompt}" | eval "${cmd_str}" || rc=$?
else
  eval "${cmd_str}" || rc=$?
fi
[[ -n "${prompt_file}" ]] && rm -f "${prompt_file}"
exit "${rc}"
