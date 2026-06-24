#!/usr/bin/env bash
# .sfs-local/scripts/sfs-team-apply.sh
#
# Solon SFS — shared multi-agent team-preset MATERIALIZE core (0.8.49 R1).
#
# Single SSoT for the write path: legacy-schema scaffold → team_preset write →
# 3-way agent_runtime_bindings fill → idempotent adapter dispatch injection.
# Called by BOTH `sfs upgrade --team <preset>` (upgrade.sh) and the new
# `sfs team use <preset>` write command, so the two entry points share one
# core. 0.8.48 had this logic duplicated in upgrade.sh (upgrade_apply_team_preset
# + upgrade_scaffold_team_schema) and install.sh (sfs_apply_team_preset);
# 0.8.49 collapses upgrade + `team use` onto this file.
#
# Contract — inputs via env:
#   SFS_TEAM_TARGET           project root containing .sfs-local/  [required]
#   SFS_TEAM_TEMPLATE         packaged model-profiles.yaml used to scaffold a
#                             legacy (pre-0.8.42, zero team keys) profile [opt]
#   SFS_TEAM_RESOLVER         sfs-team.sh path for `preset-bindings <preset>`
#                             data lookup [opt; sibling by default]
#   SFS_TEAM_CAPABILITY_GATE  1 = R3 preflight: probe each binding's runtime
#                                 (CLI present + auth); apply only capable
#                                 bindings, hold the rest with guidance.
#                             0 = materialize the full preset intent (default;
#                                 preserves 0.8.48 `upgrade --team` behavior so
#                                 the explicit-flag path stays byte-compatible).
#   SFS_TEAM_FORCE_CAPABLE_<RT>=0|1   test/CI override per runtime (CLAUDE,
#                                 CODEX, ANTIGRAVITY, GEMINI) — force a runtime
#                                 capable(1)/incapable(0) without touching the
#                                 host. Lets R3 paths be tested deterministically.
#
# Usage:
#   sfs-team-apply.sh <solo|pair|trio>   materialize the preset
#   sfs-team-apply.sh --scaffold-only    only legacy-schema scaffold (solo)
#
# Pure-data resolution: preset→bindings is read from the model-profiles
# team_preset_catalog (data, not code). Removing the team sections degrades
# cleanly to standalone solo. Idempotent: re-running with the same preset is a
# no-op on adapters and a stable rewrite on the profile.

set -euo pipefail

SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

# Local presentation helpers (sfs-common.sh does not define ok/warn/info).
# Plain text — message bodies are the contract the headline tests grep for.
ta_info() { printf '%s\n' "$*"; }
ta_ok()   { printf '  ✓ %s\n' "$*"; }
ta_warn() { printf '  ⚠ %s\n' "$*"; }

ta_sed_inplace() {
  if [ "$(uname)" = "Darwin" ]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

TARGET="${SFS_TEAM_TARGET:-}"
[ -n "${TARGET}" ] || { echo "sfs-team-apply: SFS_TEAM_TARGET required" >&2; exit 2; }
MP="${TARGET}/.sfs-local/model-profiles.yaml"
TEMPLATE="${SFS_TEAM_TEMPLATE:-}"
RESOLVER="${SFS_TEAM_RESOLVER:-${SFS_SCRIPT_DIR}/sfs-team.sh}"
GATE="${SFS_TEAM_CAPABILITY_GATE:-0}"

# ── legacy-schema scaffold (F2, verbatim contract from 0.8.48) ──────────────
# legacy(pre-0.8.42, team 키 부재) profile 감지 시 packaged template 의 team
# 블록을 configuration 블록 직후에 idempotent 하게 주입한다. 기존 키/tier 커스텀은
# 보존하고, team_preset 은 solo 로 들어가 무변경(behavior)을 보장한다. 현행 스키마
# (team_preset 키 존재)면 no-op → 현행 solo 는 byte-for-byte 불변.
team_scaffold_schema() {
  local mp="$1"
  grep -q '^team_preset:' "$mp" && return 0   # sentinel: 이미 현행 스키마 → no-op
  [ -n "${TEMPLATE}" ] && [ -f "${TEMPLATE}" ] || { ta_warn "team 스키마 스캐폴딩 불가: packaged template 없음"; return 0; }
  local block_file="$mp.teamblock.tmp"
  # template 의 team 섹션(주석 헤더 ~ unassigned_role_policy)만 추출(데이터, 코드 아님).
  awk '
    /^# ── Multi-agent team topology/ { p=1 }
    p { print }
    /^unassigned_role_policy:/ { if (p) exit }
  ' "${TEMPLATE}" > "$block_file"
  [ -s "$block_file" ] || { rm -f "$block_file"; ta_warn "team 스키마 스캐폴딩 불가: template team 블록 추출 실패"; return 0; }
  # configuration 블록(들여쓰기/빈줄 포함) 직후, 다음 top-level 키 앞에 삽입.
  awk -v bf="$block_file" '
    ins==0 && /^configuration:/ { print; inconf=1; next }
    inconf==1 {
      if ($0 ~ /^[[:space:]]/ || $0 ~ /^[[:space:]]*$/) { print; next }
      print ""; while ((getline l < bf) > 0) print l; close(bf); print ""
      ins=1; inconf=0; print; next
    }
    { print }
    END { if (inconf==1 && ins==0) { print ""; while ((getline l < bf) > 0) print l; close(bf) } }
  ' "$mp" > "$mp.tmp" && mv "$mp.tmp" "$mp"
  rm -f "$block_file"
  ta_ok "team 스키마 스캐폴딩: legacy profile 에 team 블록 주입(기본 solo = 무변경)"
}

# ── R3 capability probe ─────────────────────────────────────────────────────
# runtime CLI 존재 + 인증을 확인. 가능=0, 불가=1. 테스트 override 우선
# (SFS_TEAM_FORCE_CAPABLE_<RT>). executor_auth_ready(sfs-common) 재사용,
# antigravity(agy)는 별도 presence probe.
team_runtime_capable() {
  local rt="$1" up force
  up="$(printf '%s' "$rt" | tr '[:lower:]-' '[:upper:]_')"
  eval "force=\${SFS_TEAM_FORCE_CAPABLE_${up}:-}"
  case "${force}" in 1) return 0 ;; 0) return 1 ;; esac
  case "$rt" in
    claude)      executor_auth_ready claude ;;
    codex)       executor_auth_ready codex ;;
    antigravity) command -v agy >/dev/null 2>&1 ;;
    gemini)      executor_auth_ready gemini || command -v gemini >/dev/null 2>&1 ;;
    *)           return 0 ;;   # unknown/custom runtime: trust intent
  esac
}

# preset-bindings 한 줄("  role: runtime") 을 capability 게이트에 통과시킨다.
# 통과 → stdout 으로 적용할 라인 출력. 보류 → 빈 출력 + stderr 안내.
# researcher=antigravity 불가 시 gemini fallback(deprecated) → 보류 순.
team_gate_binding_line() {
  local preset="$1" line="$2"
  local role rt
  role="$(printf '%s' "$line" | sed -E 's/^[[:space:]]*([A-Za-z_]+):.*$/\1/')"
  rt="$(printf '%s'   "$line" | sed -E 's/^[[:space:]]*[A-Za-z_]+:[[:space:]]*//; s/[[:space:]]*#.*$//; s/[[:space:]]*$//')"
  if team_runtime_capable "$rt"; then
    printf '  %s: %s\n' "$role" "$rt"
    return 0
  fi
  if [ "$role" = "researcher" ] && [ "$rt" = "antigravity" ]; then
    if team_runtime_capable gemini; then
      ta_warn "researcher 런타임 antigravity(agy) 미탐지 — gemini fallback 적용 (DEPRECATED: 'agy' 설치/인증 후 'sfs team use ${preset}' 재실행 권장)" >&2
      printf '  %s: %s\n' "$role" "gemini"
      return 0
    fi
  fi
  ta_warn "${role} 런타임 ${rt} 미탐지/미인증 — 이 binding 보류. ${rt} 설치/인증 후 'sfs team use ${preset}' 재실행" >&2
  return 0
}

# ── core materialize (write preset → fill bindings → inject adapters) ───────
# 3-way bindings 가드 (부재 vs 리터럴 {} vs 사용자 커스텀) + idempotent 어댑터 주입.
# preset solo 면 bindings/dispatch 비활성으로 early-return.
team_materialize_preset() {
  local team="$1"
  ta_sed_inplace -e "s|^team_preset:.*|team_preset: $team|" "$MP" 2>/dev/null || true
  if [ "$team" = "solo" ]; then
    ta_ok "team preset solo 재적용 (bindings/dispatch 비활성 — 기존 동작)"
    return 0
  fi
  # F3: bindings-fill 가드 3-way 분기 (부재 vs 리터럴 {} vs 사용자 커스텀).
  if ! grep -q '^agent_runtime_bindings:' "$MP"; then
    ta_warn "agent_runtime_bindings 키 부재 — team 스키마 스캐폴딩 후 재적용 필요 (preset 적용 skip)"
  elif grep -Eq '^agent_runtime_bindings:[[:space:]]*\{\}[[:space:]]*$' "$MP"; then
    if [ -f "$RESOLVER" ]; then
      local binds_file="$MP.binds.tmp"
      SFS_MODEL_PROFILES="$MP" bash "$RESOLVER" preset-bindings "$team" 2>/dev/null | sed 's/^/  /' > "$binds_file" || true
      if [ "$GATE" = "1" ] && [ -s "$binds_file" ]; then
        # R3: capability preflight — 가능한 binding 만 통과시킨다.
        local gated_file="$MP.binds.gated.tmp" l
        : > "$gated_file"
        while IFS= read -r l; do
          [ -n "$l" ] || continue
          team_gate_binding_line "$team" "$l" >> "$gated_file"
        done < "$binds_file"
        mv "$gated_file" "$binds_file"
      fi
      if [ -s "$binds_file" ]; then
        awk -v bf="$binds_file" '
          $1 == "agent_runtime_bindings:" && index($0, "{}") {
            print "agent_runtime_bindings:"
            while ((getline l < bf) > 0) print l
            close(bf); next
          }
          { print }
        ' "$MP" > "$MP.tmp" && mv "$MP.tmp" "$MP"
        ta_ok "team preset '$team' → agent_runtime_bindings 채움"
      else
        ta_warn "team preset '$team' → 적용 가능한 binding 없음 (capability 불충족) — solo 동작 유지. 런타임 설치/인증 후 'sfs team use $team' 재실행"
      fi
      rm -f "$binds_file"
    else
      ta_warn "team preset 적용 불가: resolver(sfs-team.sh) 없음 — agent_runtime_bindings 미충전"
    fi
  else
    ta_warn "agent_runtime_bindings 사용자 커스텀 값 감지 — team preset 자동 적용 skip (보존). 직접 편집하세요."
  fi
  local adapter
  for adapter in "$TARGET/CLAUDE.md" "$TARGET/AGENTS.md" "$TARGET/GEMINI.md"; do
    [ -f "$adapter" ] || continue
    grep -q '^team_dispatch:' "$adapter" && continue
    awk -v preset="$team" '
      BEGIN { fm=0; done=0 }
      NR==1 && $0=="---" { fm=1; print; next }
      fm==1 && done==0 && $0=="---" {
        print "team_dispatch:                          # injected by --team " preset " (P2); solo 면 부재"
        print "  preset: " preset
        print "  rule: \"task role 분류(plan/review/docs=lead, 구현=worker, 조사=researcher) → `sfs team resolve-runtime <role>` 로 runtime 해석 → 내 runtime 과 다르면 typed capsule 발행 후 `sfs route <role> <capsule>` 로 위임 → 회수·통합. solo/standalone 은 항상 직접 수행.\""
        print "  ssot: \"docs/maintenance/2026-06-23-multi-agent-team-topology.design.md §4.4\""
        done=1; print; next
      }
      { print }
    ' "$adapter" > "$adapter.tmp" && mv "$adapter.tmp" "$adapter"
  done
  ta_ok "team dispatch rule 주입(idempotent): CLAUDE.md / AGENTS.md / GEMINI.md (preset=$team)"
}

# R5 helper: capability fingerprint for a preset. Prints `fp=<sorted capable
# runtimes>` to stdout. Exit 0 = offer-worthy (lead AND worker capable), 3 =
# not worthy. Used by upgrade.sh to gate the auto-offer (R5a) and to detect the
# incapable→capable transition for re-offer (R5c). Capability logic lives here
# (single SSoT) so the offer path and the apply path agree.
team_capability_fp() {
  local preset="$1" binds role rt
  binds="$(SFS_MODEL_PROFILES="$MP" bash "$RESOLVER" preset-bindings "$preset" 2>/dev/null || true)"
  local cap_lead=0 cap_worker=0 capable=""
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    role="$(printf '%s' "$line" | sed -E 's/^[[:space:]]*([A-Za-z_]+):.*$/\1/')"
    rt="$(printf '%s'   "$line" | sed -E 's/^[[:space:]]*[A-Za-z_]+:[[:space:]]*//; s/[[:space:]]*#.*$//; s/[[:space:]]*$//')"
    if team_runtime_capable "$rt"; then
      capable="${capable}${rt}\n"
      [ "$role" = "lead" ]   && cap_lead=1
      [ "$role" = "worker" ] && cap_worker=1
    elif [ "$role" = "researcher" ] && [ "$rt" = "antigravity" ] && team_runtime_capable gemini; then
      capable="${capable}gemini\n"
    fi
  done <<EOF
$(printf '%s\n' "$binds")
EOF
  local fp
  fp="$(printf '%b' "$capable" | sed '/^$/d' | sort -u | paste -sd, - 2>/dev/null || true)"
  printf 'fp=%s\n' "$fp"
  [ "$cap_lead" = 1 ] && [ "$cap_worker" = 1 ] && return 0 || return 3
}

# ── entry ───────────────────────────────────────────────────────────────────
ARG="${1:-}"
if [ ! -f "$MP" ]; then
  case "$ARG" in
    --capability-fp) printf 'fp=\n'; exit 3 ;;
    --scaffold-only) exit 0 ;;
    *) ta_warn "team preset 적용 불가: model-profiles.yaml 없음"; exit 0 ;;
  esac
fi

case "$ARG" in
  --capability-fp)
    team_capability_fp "${2:-trio}"
    exit $?
    ;;
  --scaffold-only)
    team_scaffold_schema "$MP"
    exit 0
    ;;
  solo|pair|trio)
    team_scaffold_schema "$MP"   # legacy(team 키 부재)는 명시 호출 없이도 스키마 스캐폴딩
    team_materialize_preset "$ARG"
    exit 0
    ;;
  "")
    echo "sfs-team-apply: missing preset (solo|pair|trio) or --scaffold-only" >&2
    exit 2
    ;;
  *)
    echo "sfs-team-apply: unknown preset '$ARG' (expected solo|pair|trio)" >&2
    exit 2
    ;;
esac
