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
  local rt="$1" up force force_var
  # rt 는 project-editable model-profiles.yaml 에서 온다. eval 로 확장하면
  # `x}$(cmd)` 같은 값이 코드 실행으로 이어진다 — 런타임 이름은 [a-z0-9-] 만
  # 허용하고, override 조회는 eval 이 아니라 bash 간접 확장(${!var})으로 한다.
  case "$rt" in
    *[!a-z0-9-]*|'') return 0 ;;   # 비정상 runtime 이름: 신뢰 안 함, 무해 통과
  esac
  up="$(printf '%s' "$rt" | tr '[:lower:]-' '[:upper:]_')"
  force_var="SFS_TEAM_FORCE_CAPABLE_${up}"
  force="${!force_var:-}"
  case "${force}" in 1) return 0 ;; 0) return 1 ;; esac
  case "$rt" in
    claude)      executor_auth_ready claude ;;
    codex)       executor_auth_ready codex ;;
    antigravity)
      # R5: presence-only(command -v agy)는 "설치됐으나 미인증"을 capable 로 오판해
      # researcher 를 승격했다가 런타임 에러("promoted but unauthed")를 냈다. claude/codex
      # 처럼 auth-ready 까지 확인한다. antigravity(agy)는 models_ref: gemini → Google
      # 자격증명을 공유하므로 gemini 의 env 관용을 따른다(+ SFS_ANTIGRAVITY_AUTH_READY).
      command -v agy >/dev/null 2>&1 && {
        [ -n "${GEMINI_API_KEY:-}" ] || [ -n "${GOOGLE_API_KEY:-}" ] \
          || [ -n "${GOOGLE_APPLICATION_CREDENTIALS:-}" ] \
          || [ "${SFS_ANTIGRAVITY_AUTH_READY:-0}" = "1" ]
      } ;;
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
      ta_warn "researcher 런타임 antigravity(agy) 미탐지/미인증 — gemini fallback 적용 (DEPRECATED: 'agy' 설치/인증 후 'sfs team use ${preset}' 또는 'sfs team refresh' 로 자동 승격)" >&2
      # R1: fallback provenance 표식. canonical(antigravity)을 명시해 두면 나중에
      # capability 회복 시 이 한 줄만 골라 승격할 수 있다(사용자가 고른 gemini 와 구분).
      # resolver(read_binding)는 주석을 strip 하므로 resolve-runtime 결과엔 영향 없음.
      printf '  %s: %s   # sfs-fallback: %s\n' "$role" "gemini" "$rt"
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
    # bindings 가 채워진 상태(4-way 가드의 4번째). 사용자 커스텀은 보존하되, deprecated
    # fallback 은 승격 제안: (a) `# sfs-fallback:` 표식 [0.8.52] 또는 (b) 표식 없는 legacy
    # deprecated binding(catalog canonical 이 다르고 capable) [0.8.53]. 둘 다 없으면
    # team_promote_fallbacks 가 "보존" 통지만 하고 무변경.
    team_promote_fallbacks "$MP" "$team"
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

# ── R2: deprecated-fallback → canonical 자동 승격 ────────────────────────────
# fallback 표식(`# sfs-fallback:<canonical>`)을 단 binding 만 골라, canonical 런타임이
# 이제 capable 이면 그 한 줄을 canonical 로 rewrite(표식 제거)한다. 표식 없는 사용자
# 커스텀 binding 은 절대 건드리지 않는다(4-way: 부재 / {} / fallback(승격대상) /
# user-custom(보존)). 동의: SFS_TEAM_PROMOTE_YES=1 = 무프롬프트 강제(refresh --yes),
# 아니면 interactive tty Y/n, 그 외(비대화+미force) = 무변경(byte-for-byte).

# bindings 블록에서 fallback 표식 라인을 `role rt canonical` 로 방출.
team_scan_fallback_lines() {
  awk '
    /^agent_runtime_bindings:/ { inb=1; next }
    inb && /^[A-Za-z_]/ { inb=0 }
    inb && /#[[:space:]]*sfs-fallback:[[:space:]]*[A-Za-z0-9_-]+/ {
      role=$0; sub(/^[[:space:]]+/,"",role); sub(/:.*/,"",role)
      rt=$0; sub(/^[[:space:]]+[A-Za-z0-9_-]+:[[:space:]]*/,"",rt); sub(/[[:space:]]*#.*/,"",rt); sub(/[[:space:]]*$/,"",rt)
      canon=$0; sub(/^.*#[[:space:]]*sfs-fallback:[[:space:]]*/,"",canon); sub(/[^A-Za-z0-9_-].*$/,"",canon)
      print role, rt, canon
    }
  ' "$1"
}

# 표식 binding 중 canonical 이 capable 인 집합을 정렬·중복제거해 출력(R5 게이트와 동일
# capability 판정 = team_runtime_capable). upgrade.sh 의 nag-게이트가 사용.
team_promotable_canonicals() {
  local mp="$1" preset="${2:-}"
  local role rt canon out=""
  while read -r role rt canon; do
    [ -n "${canon:-}" ] || continue
    if team_runtime_capable "$canon"; then out="${out}${canon}\n"; fi
  done < <(team_scan_fallback_lines "$mp"; team_scan_legacy_lines "$mp" "$preset")
  printf '%b' "$out" | sed '/^$/d' | sort -u | paste -sd, - 2>/dev/null || true
}

# bindings 블록 안에서 role 의 binding 라인을 canonical 로 rewrite(있던 표식/핀 제거).
# 호출 전 scan 이 이미 승격 대상 role 만 골라줬다(표식 fallback 또는 legacy deprecated).
# bindings 밖 다른 `role:` 키(model 설정 등)는 inb 가드로 건드리지 않음.
team_rewrite_binding_line() {
  local mp="$1" role="$2" canon="$3"
  awk -v role="$role" -v canon="$canon" '
    /^agent_runtime_bindings:/ { inb=1; print; next }
    inb && /^[A-Za-z_]/ { inb=0 }
    inb && $0 ~ ("^[[:space:]]+" role ":") {
      print "  " role ": " canon; next
    }
    { print }
  ' "$mp" > "$mp.tmp" && mv "$mp.tmp" "$mp"
}

# ── 0.8.53: legacy UNMARKED deprecated-fallback inference ─────────────────────
# 0.8.52 의 provenance 표식(`# sfs-fallback:`)은 0.8.52 이후 materialize 된 binding
# 에만 찍힌다. 그 이전에 antigravity 부재로 gemini 로 굳은 binding(표식 없음, 예 수동
# splice)은 user-custom 으로 보존돼 승격되지 않았다. 0.8.53 은 2번째 신호로 이 legacy
# 케이스를 추론한다: 표식/핀 없는 binding 이 deprecated 런타임을 가리키고(runtime_registry
# 의 deprecated 키), 활성 preset 의 team_preset_catalog canonical 이 다른 런타임이며 그게
# capable 이면 — 표식 fallback 과 동일하게 detect→offer→consent→promote 한다.

# runtime_registry.<rt> 에 deprecated 키가 있으면 0, 없으면 1.
team_registry_deprecated() {
  local mp="$1" rt="$2"
  awk -v want="$rt" '
    /^runtime_registry:/ { inr=1; next }
    inr && /^[A-Za-z_]/ { inr=0 }
    inr && /^  [A-Za-z0-9_-]+:/ {
      name=$0; sub(/^  /,"",name); sub(/:.*/,"",name); cur=(name==want)?1:0; next
    }
    inr && cur && /^[[:space:]]+deprecated:/ { found=1 }
    END { exit (found?0:1) }
  ' "$mp"
}

# team_preset_catalog.<preset>.<role> 의 canonical 런타임 (데이터 SSoT = resolver).
team_catalog_canonical() {
  local preset="$1" role="$2"
  [ -n "$preset" ] || return 0
  SFS_MODEL_PROFILES="$MP" bash "$RESOLVER" preset-bindings "$preset" 2>/dev/null \
    | awk -v r="$role" '$1==r":" { print $2; exit }'
}

# bindings 블록에서 legacy-shaped 라인을 `role rt canon` 로 방출(capability 미필터 —
# 표식 스캐너와 대칭, capability 는 promote 에서 판정). 표식(`# sfs-fallback:`)이나
# 핀(`# sfs-pinned:`)이 있는 라인은 제외. rt 가 deprecated 이고 catalog canonical 이
# 존재하며 rt 와 다를 때만 후보.
team_scan_legacy_lines() {
  local mp="$1" preset="${2:-}"
  [ -n "$preset" ] || return 0
  local role rt canon
  while read -r role rt; do
    [ -n "${rt:-}" ] || continue
    team_registry_deprecated "$mp" "$rt" || continue
    canon="$(team_catalog_canonical "$preset" "$role")"
    [ -n "$canon" ] && [ "$canon" != "$rt" ] && printf '%s %s %s\n' "$role" "$rt" "$canon"
  done < <(awk '
    /^agent_runtime_bindings:/ { inb=1; next }
    inb && /^[A-Za-z_]/ { inb=0 }
    inb && /^[[:space:]]+[A-Za-z0-9_-]+:/ && !/#[[:space:]]*sfs-fallback:/ && !/#[[:space:]]*sfs-pinned:/ {
      role=$0; sub(/^[[:space:]]+/,"",role); sub(/:.*/,"",role)
      rt=$0; sub(/^[[:space:]]+[A-Za-z0-9_-]+:[[:space:]]*/,"",rt); sub(/[[:space:]]*#.*/,"",rt); sub(/[[:space:]]*$/,"",rt)
      if (rt != "" && rt !~ /^[{]/) print role, rt
    }
  ' "$mp")
}

# R2: 거절(N)을 사용자 의도로 확정 — role 의 binding 라인에 `# sfs-pinned: <rt> (user)`
# 표식을 붙인다(이미 표식/핀 있으면 무시). legacy 스캐너가 핀 라인을 제외하므로 이후 영영
# 재제안되지 않는다. 주석이라 resolver(read_binding)가 strip → resolve-runtime 무영향.
team_pin_binding_line() {
  local mp="$1" role="$2" rt="$3"
  awk -v role="$role" -v rt="$rt" '
    /^agent_runtime_bindings:/ { inb=1; print; next }
    inb && /^[A-Za-z_]/ { inb=0 }
    inb && $0 ~ ("^[[:space:]]+" role ":") && $0 !~ /#[[:space:]]*sfs-(fallback|pinned):/ {
      sub(/[[:space:]]*$/, "")
      print $0 "   # sfs-pinned: " rt " (user)"; next
    }
    { print }
  ' "$mp" > "$mp.tmp" && mv "$mp.tmp" "$mp"
}

# 3-valued consent (0.8.53). A 2-valued accept/not-accept collapses "interactive
# N" and "no interaction" into one branch — fine for MARKED fallbacks (don't-apply
# = leave marker, re-offerable) but wrong for LEGACY unmarked candidates, where an
# explicit N must PIN (R2: 영영 재제안 안 함) while no-interaction must be byte-for-
# byte无변경 with NO pin write (R5). So return three states:
#   0 = promote (accept)         SFS_TEAM_PROMOTE_YES / interactive Y
#   1 = explicit decline         SFS_TEAM_PROMOTE_DECLINE / interactive N
#   2 = no interaction           non-interactive without an explicit flag
team_promote_decide() {
  case "${SFS_TEAM_PROMOTE_YES:-0}" in 1|true|TRUE|yes|YES) return 0 ;; esac
  case "${SFS_TEAM_PROMOTE_DECLINE:-0}" in 1|true|TRUE|yes|YES) return 1 ;; esac
  executor_interactive_tty_available || return 2
  local ans
  printf '%s [Y/n]: ' "$1" > /dev/tty 2>/dev/null || return 2
  read -r ans < /dev/tty 2>/dev/null || ans=""
  case "${ans:-Y}" in n|N|no|NO|No) return 1 ;; *) return 0 ;; esac
}

# Unified deprecated-fallback → canonical promotion (0.8.52 marked + 0.8.53 legacy).
# Gathers two signals (OR): (a) `# sfs-fallback:`-marked binding [0.8.52], and
# (b) legacy UNMARKED binding to a deprecated runtime whose preset catalog canonical
# differs and is capable [0.8.53]. capability(team_runtime_capable, auth-aware)
# filters both. One consent covers all promotable lines. Decline action branches by
# source: a LEGACY decline PINS (`# sfs-pinned:`, R2 — 영영 재제안 안 함); a MARKED
# decline leaves the marker re-offerable (0.8.52 behavior). No-interaction (R5) =
# byte-for-byte 무변경, no pin. user-custom(비-deprecated/핀) binding 은 불변.
team_promote_fallbacks() {
  local mp="$1" preset="${2:-}"
  # any-shaped (capability 미필터) detection for messaging.
  local any_marked any_legacy
  any_marked="$(team_scan_fallback_lines "$mp")"
  any_legacy="$(team_scan_legacy_lines "$mp" "$preset")"

  # promotable candidates: capability-filtered, tagged with source.
  local role rt canon cands=""
  while read -r role rt canon; do
    [ -n "${canon:-}" ] || continue
    team_runtime_capable "$canon" && cands="${cands}${role}|${rt}|${canon}|marked"$'\n'
  done < <(printf '%s\n' "$any_marked")
  while read -r role rt canon; do
    [ -n "${canon:-}" ] || continue
    team_runtime_capable "$canon" && cands="${cands}${role}|${rt}|${canon}|legacy"$'\n'
  done < <(printf '%s\n' "$any_legacy")
  cands="$(printf '%s' "$cands" | sed '/^$/d')"

  if [ -z "$cands" ]; then
    if [ -n "$any_marked" ] || [ -n "$any_legacy" ]; then
      ta_info "deprecated fallback binding 유지 — canonical 런타임 아직 미탐지/미인증 (변경 없음). 설치/인증 후 'sfs team refresh'."
    else
      ta_warn "agent_runtime_bindings 사용자 커스텀 값 감지 — team preset 자동 적용 skip (보존). 직접 편집하세요."
    fi
    return 0
  fi

  local desc decision=0
  desc="$(printf '%s\n' "$cands" | while IFS='|' read -r r rt c s; do [ -n "$r" ] && printf '%s→%s ' "$r" "$c"; done)"
  team_promote_decide "deprecated fallback 승격 가능: ${desc}— canonical 로 승격?" || decision=$?
  case "$decision" in
    0)  # accept → promote every candidate (strip marker for marked; replace for legacy)
      printf '%s\n' "$cands" | while IFS='|' read -r role rt canon src; do
        [ -n "$role" ] || continue
        team_rewrite_binding_line "$mp" "$role" "$canon"
        ta_ok "${role} 승격: deprecated fallback → ${canon} (표식 제거)"
      done
      ;;
    1)  # explicit decline → PIN legacy candidates (R2); leave marked re-offerable
      printf '%s\n' "$cands" | while IFS='|' read -r role rt canon src; do
        [ -n "$role" ] || continue
        if [ "$src" = "legacy" ]; then
          team_pin_binding_line "$mp" "$role" "$rt"
          ta_info "${role} = ${rt} 사용자 의도로 확정(pin) — 다시 제안 안 함."
        fi
      done
      ta_info "fallback 승격 보류 — binding 무변경 (나중에 'sfs team refresh' 로 다시 제안)"
      ;;
    *)  # no interaction (R5) → byte-for-byte 무변경, no pin
      ta_info "fallback 승격 보류 — binding 무변경 (나중에 'sfs team refresh' 로 다시 제안)"
      ;;
  esac
}

# ── entry ───────────────────────────────────────────────────────────────────
ARG="${1:-}"
if [ ! -f "$MP" ]; then
  case "$ARG" in
    --capability-fp|--promotable-fp) printf 'fp=\n'; exit 3 ;;
    --scaffold-only|--refresh) exit 0 ;;
    *) ta_warn "team preset 적용 불가: model-profiles.yaml 없음"; exit 0 ;;
  esac
fi

case "$ARG" in
  --capability-fp)
    team_capability_fp "${2:-trio}"
    exit $?
    ;;
  --promotable-fp)
    # 표식(0.8.52) + legacy 추론(0.8.53) 둘 다 포함 → preset 필요(catalog canonical).
    PRESET_NOW="$(awk '/^team_preset:/ {v=$0; sub(/^team_preset:[[:space:]]*/,"",v); sub(/[[:space:]]*#.*/,"",v); gsub(/[[:space:]]/,"",v); print v; exit}' "$MP")"
    fp="$(team_promotable_canonicals "$MP" "${PRESET_NOW:-}")"
    printf 'fp=%s\n' "$fp"
    [ -n "$fp" ] && exit 0 || exit 3
    ;;
  --refresh)
    # R2: preset 불변. deprecated fallback 만 canonical 승격 스캔/제안 — 표식 fallback
    # [0.8.52] + 표식 없는 legacy deprecated binding [0.8.53] 둘 다. bindings 가 채워져
    # 있어야(리터럴 {} 아님) 후보가 생긴다.
    PRESET_NOW="$(awk '/^team_preset:/ {v=$0; sub(/^team_preset:[[:space:]]*/,"",v); sub(/[[:space:]]*#.*/,"",v); gsub(/[[:space:]]/,"",v); print v; exit}' "$MP")"
    if grep -q '^agent_runtime_bindings:' "$MP" && ! grep -Eq '^agent_runtime_bindings:[[:space:]]*\{\}[[:space:]]*$' "$MP"; then
      team_promote_fallbacks "$MP" "${PRESET_NOW:-}"
    else
      ta_info "deprecated fallback 표식 없음 — 승격할 binding 없음 (변경 없음)"
    fi
    exit 0
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
