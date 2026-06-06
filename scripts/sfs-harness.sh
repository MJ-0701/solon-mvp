#!/usr/bin/env bash
# SFS 프로젝트 하네스 진단과 설계도 출력을 담당한다.
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMMAND="${1:-doctor}"

if [ -t 1 ]; then
  C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_RED=$'\033[31m'
  C_BOLD=$'\033[1m'; C_DIM=$'\033[2m'; C_RESET=$'\033[0m'
else
  C_GREEN=''; C_YELLOW=''; C_RED=''; C_BOLD=''; C_DIM=''; C_RESET=''
fi

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

ok() { printf "  ${C_GREEN}✅${C_RESET} %s\n" "$*"; PASS_COUNT=$((PASS_COUNT + 1)); }
warn() { printf "  ${C_YELLOW}⚠️${C_RESET}  %s\n" "$*"; WARN_COUNT=$((WARN_COUNT + 1)); }
# partial: degraded-but-not-release-blocking. Counts as a warn for the exit
# code (doctor returns 1) but prints a distinct severity word so detectors
# can signal "past cushion" without hard-failing the whole harness run.
partial() { printf "  ${C_YELLOW}🟠${C_RESET} partial: %s\n" "$*"; WARN_COUNT=$((WARN_COUNT + 1)); }
fail() { printf "  ${C_RED}❌${C_RESET} %s\n" "$*"; FAIL_COUNT=$((FAIL_COUNT + 1)); }
info() { printf "  ${C_DIM}%s${C_RESET}\n" "$*"; }
section() { printf "\n${C_BOLD}%s${C_RESET}\n" "$*"; }

usage() {
  cat <<'EOF'
Usage:
  sfs harness doctor
  sfs harness map [--write] [--path <file>]

Harness commands inspect the current project as an AI work environment: agent
entry docs, routed context, division council, artifacts/memory, wiki, tests,
and release/check loops. They do not create a sprint or run workers.
EOF
}

project_name() {
  basename "$PWD"
}

project_version() {
  if [ -f ".sfs-local/VERSION" ]; then
    grep -E '^solon_(mvp|product)_version:' .sfs-local/VERSION 2>/dev/null |
      head -1 |
      awk -F: '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}'
  fi
}

is_sfs_project() {
  [ -f "SFS.md" ] && [ -d ".sfs-local" ]
}

file_has_any() {
  local file="$1"
  shift
  [ -f "$file" ] || return 1
  local needle
  for needle in "$@"; do
    grep -Fq "$needle" "$file" 2>/dev/null && return 0
  done
  return 1
}

looks_bloated_sfs_router() {
  local file="SFS.md" lines
  [ -f "$file" ] || return 1
  file_has_any "$file" \
    "SFS commands —" \
    "Executable Action Ownership" \
    "Monitor checkpoint classification" \
    "Handoff-only scope is a stop contract" \
    "Division sub-agent council is always-on" && return 0
  lines="$(wc -l < "$file" 2>/dev/null | tr -d '[:space:]')"
  case "${lines:-0}" in
    ''|*[!0-9]*) return 1 ;;
  esac
  [ "$lines" -gt 90 ] && file_has_any "$file" "sfs context cat kernel" "doc_type: solon-router"
}

agent_doc_needs_refactor() {
  local file="$1" lines
  [ -f "$file" ] || return 1
  file_has_any "$file" "SFS commands —" "Gate 3 self-review PASS" "Executable Action Ownership" || return 1
  lines="$(wc -l < "$file" 2>/dev/null | tr -d '[:space:]')"
  case "${lines:-0}" in
    ''|*[!0-9]*) return 0 ;;
  esac
  [ "$lines" -gt 40 ]
}

division_state() {
  local division="$1"
  [ -f ".sfs-local/divisions.yaml" ] || return 1
  awk -v division="$division" '
    $0 ~ "^[[:space:]]{2}" division ":" { in_division = 1; next }
    in_division && /^[[:space:]]{2}[a-zA-Z0-9_-]+:/ { in_division = 0 }
    in_division && /activation_state:/ {
      state = $0
      sub(/^.*activation_state:[[:space:]]*/, "", state)
      gsub(/[[:space:]"'\'']/, "", state)
      found = 1
    }
    END {
      if (found) {
        print state
        exit 0
      }
      exit 1
    }
  ' .sfs-local/divisions.yaml
}

detect_test_surface() {
  [ -d "tests" ] && return 0
  [ -f "package.json" ] && grep -Eq '"(test|smoke|build)"[[:space:]]*:' package.json 2>/dev/null && return 0
  [ -f "pnpm-lock.yaml" ] && return 0
  [ -f "pom.xml" ] && return 0
  [ -f "build.gradle" ] && return 0
  [ -f "build.gradle.kts" ] && return 0
  [ -x "./gradlew" ] && return 0
  # Allow projects with non-standard test homes to declare them without
  # leaking maintainer-private paths into shipped product code.
  if [ -n "${SFS_HARNESS_EXTRA_TEST_DIRS:-}" ]; then
    local _td
    IFS=':' read -ra _SFS_HARNESS_TEST_DIRS <<< "${SFS_HARNESS_EXTRA_TEST_DIRS}"
    if (( ${#_SFS_HARNESS_TEST_DIRS[@]} > 0 )); then
      for _td in "${_SFS_HARNESS_TEST_DIRS[@]}"; do
        [ -n "${_td}" ] && [ -d "${_td}" ] && return 0
      done
    fi
  fi
  return 1
}

detect_release_surface() {
  [ -f "scripts/verify-product-release.sh" ] && return 0
  [ -f ".github/workflows/sfs-pr-check.yml" ] && return 0
  [ -f ".github/workflows/windows-scoop-smoke.yml" ] && return 0
  # Allow projects with non-standard release verifiers to declare them
  # without leaking maintainer-private paths into shipped product code.
  if [ -n "${SFS_HARNESS_EXTRA_RELEASE_FILES:-}" ]; then
    local _rf
    IFS=':' read -ra _SFS_HARNESS_RELEASE_FILES <<< "${SFS_HARNESS_EXTRA_RELEASE_FILES}"
    if (( ${#_SFS_HARNESS_RELEASE_FILES[@]} > 0 )); then
      for _rf in "${_SFS_HARNESS_RELEASE_FILES[@]}"; do
        [ -n "${_rf}" ] && [ -f "${_rf}" ] && return 0
      done
    fi
  fi
  return 1
}

# 0.7.6: Host channel + 0.7.0 surface detectors.
#
# These are advisory — they report whether the 0.7.0+ host-agnostic
# surfaces are available to this project, not whether they have been
# registered with a particular host. Host config files (e.g. Claude
# Desktop config) live outside the project and intentionally are not
# scanned to avoid false negatives and personal data exposure.

detect_mcp_server_artifact() {
  # The MCP server ships inside the installed SFS distribution. Its
  # presence means consumers can register `solon-mcp` with any MCP host.
  [ -f "${DIST_DIR}/mcp-server/solon_mcp_server.py" ] && return 0
  return 1
}

detect_solon_safe_preset() {
  # The permission preset can live in two places:
  #   - distribution: templates/.sfs-local-template/presets/solon-safe-permissions.yaml
  #   - consumer copy: .sfs-local/presets/solon-safe-permissions.yaml
  [ -f "${DIST_DIR}/templates/.sfs-local-template/presets/solon-safe-permissions.yaml" ] && return 0
  [ -f ".sfs-local/presets/solon-safe-permissions.yaml" ] && return 0
  return 1
}

detect_agent_sdk_template() {
  # The Claude Agent SDK zero template ships inside the distribution.
  [ -d "${DIST_DIR}/templates/claude-agent-sdk-zero" ] && return 0
  return 1
}

detect_agent_build_track() {
  # Consumer project signals that the work itself ships an agent / MCP
  # server / sub-agent harness. agent-build review lens auto-routes
  # when these signals are present.
  [ -f "agent.py" ] && return 0
  [ -d "mcp-server" ] && return 0
  [ -f "system_prompt.md" ] && return 0
  [ -f "solon-safe-permissions.yaml" ] && return 0
  return 1
}

# 0.7.10: Operational-log + md-line-budget detectors.
#
# Sibling failures with one root cause — operational logs are not treated as a
# first-class loadable surface, so they drift (release lag) and bloat (>200
# lines) silently. SSoT for thresholds/scope:
#   templates/.sfs-local-template/context/policies/md-line-budget.md
# These detectors walk only the consumer project's working tree (not the
# shipped distribution), so a project's own PROGRESS.md / handoff / index files
# are checked. Routed context size is already locked by contract tests.

progress_log_path() {
  local p
  for p in PROGRESS.md docs/solon/*/PROGRESS.md .sfs-local/PROGRESS.md; do
    [ -f "$p" ] && { printf '%s' "$p"; return 0; }
  done
  return 1
}

current_release_version() {
  if [ -f "VERSION" ]; then
    head -1 "VERSION" | tr -d '[:space:]'
    return 0
  fi
  project_version
}

progress_last_release_version() {
  local file="$1"
  awk '
    /^[[:space:]]*last_completed_release:/ { in_blk=1; next }
    in_blk && /^[^[:space:]#]/ { exit }
    in_blk && /version:/ {
      v = $0
      sub(/^.*version:[[:space:]]*/, "", v)
      gsub(/[[:space:]"'\'']/, "", v)
      if (v != "") { print v; exit }
    }
  ' "$file" 2>/dev/null
}

# Release lag between two semver strings. Same major.minor → patch distance.
# Differing major or minor → 999 (a minor bump spans many patch releases, so
# treat it as "far past the partial threshold" rather than guess a count).
version_lag() {
  local a="$1" b="$2" a1 a2 a3 b1 b2 b3 d
  IFS=. read -r a1 a2 a3 _ <<< "$a"
  IFS=. read -r b1 b2 b3 _ <<< "$b"
  case "${a3:-0}${b3:-0}" in *[!0-9]*) echo 999; return ;; esac
  [ -n "$a3" ] || a3=0
  [ -n "$b3" ] || b3=0
  if [ "${a1:-}" != "${b1:-}" ] || [ "${a2:-}" != "${b2:-}" ]; then
    echo 999
    return
  fi
  d=$((a3 - b3))
  [ "$d" -lt 0 ] && d=$((-d))
  echo "$d"
}

# Exception list from md-line-budget.md "Out of scope".
md_in_budget_scope() {
  local f="${1#./}"
  case "$f" in
    CHANGELOG.md|RELEASE-NOTES.md) return 1 ;;
    QA-REPORT-*|*/QA-REPORT-*) return 1 ;;
    INTEGRATION-VERIFY-*|*/INTEGRATION-VERIFY-*) return 1 ;;
    archives/*|*/archives/*|.sfs-local/archives/*) return 1 ;;
    docs/solon/*/archive/*|*/archive/*) return 1 ;;
    tests/*) return 1 ;;
  esac
  return 0
}

# In-scope project-local markdown: root-level docs + named operational logs.
list_budget_scope_files() {
  find . -maxdepth 1 -type f -name '*.md' 2>/dev/null
  local p
  for p in PROGRESS.md HANDOFF-next-session.md NEXT-SESSION-BRIEFING.md \
           sessions/_INDEX.md docs/solon/*/PROGRESS.md \
           docs/solon/*/HANDOFF-next-session.md docs/solon/*/sessions/_INDEX.md; do
    [ -f "$p" ] && printf './%s\n' "$p"
  done
}

print_operational_log_section() {
  section "Operational Logs And Size"

  local prog cur led lag
  if prog="$(progress_log_path 2>/dev/null)" && [ -n "$prog" ]; then
    cur="$(current_release_version)"
    led="$(progress_last_release_version "$prog")"
    if [ -z "$cur" ] || [ -z "$led" ]; then
      info "operational-log-lag: $prog present but VERSION / last_completed_release.version incomplete; skipping"
    elif [ "$cur" = "$led" ]; then
      ok "operational-log-lag: $prog last_completed_release in sync with VERSION ($cur)"
    else
      lag="$(version_lag "$cur" "$led")"
      if [ "$lag" -ge 5 ]; then
        partial "operational-log-lag: $prog last_completed_release $led is >=5 releases (or a minor) behind VERSION $cur"
      else
        warn "operational-log-lag: $prog last_completed_release $led behind VERSION $cur (lag $lag)"
      fi
    fi
  else
    info "operational-log-lag: no PROGRESS.md operational log in project tree; skipping"
  fi

  local f lines budget_hits=0
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    md_in_budget_scope "$f" || continue
    lines="$(wc -l < "$f" 2>/dev/null | tr -d '[:space:]')"
    case "${lines:-x}" in ''|*[!0-9]*) continue ;; esac
    if [ "$lines" -ge 250 ]; then
      fail "md-line-budget-violation: $f $lines lines (>=250 fail; archive-rotate before release)"
      budget_hits=$((budget_hits + 1))
    elif [ "$lines" -ge 200 ]; then
      partial "md-line-budget-violation: $f $lines lines (>=200 partial; rotate to archive)"
      budget_hits=$((budget_hits + 1))
    elif [ "$lines" -ge 180 ]; then
      warn "md-line-budget-violation: $f $lines lines (>=180 warn; shrink or rotate soon)"
      budget_hits=$((budget_hits + 1))
    fi
  done < <(list_budget_scope_files | sort -u)
  if [ "$budget_hits" -eq 0 ]; then
    ok "md-line-budget-violation: no in-scope md over 180 lines"
  fi
}

# 0.8.27 (WU-1): Context conflict gate.
#
# Conflict, not volume, is the real context failure (note 21): two directives
# that contradict each other leave the agent guessing. Semantic contradiction is
# not reliably detectable, so this is an OPT-IN marker lint — a directive with a
# binary stance annotates itself with an invisible HTML-comment marker
#   <!-- conflict-key: <slug> stance: allow|deny -->
# and this detector flags any slug declared with BOTH stances. Unannotated prose
# is never compared, so it cannot false-positive on normal policy text. Scope:
# consumer working tree only (.sfs-local/context/), mirroring the other
# detectors — the shipped distribution is never scanned. SSoT:
#   templates/.sfs-local-template/context/policies/context-conflict-gate.md
print_context_conflict_section() {
  section "Context Conflict Gate"

  local ctx_dir=".sfs-local/context"
  if [ ! -d "$ctx_dir" ]; then
    info "context-conflict-gate: no project-local context overrides; skipping"
    return
  fi

  local markers
  markers="$(grep -rh -- '<!-- *conflict-key:' "$ctx_dir" 2>/dev/null || true)"
  if [ -z "$markers" ]; then
    info "context-conflict-gate: no conflict-key markers declared; skipping"
    return
  fi

  # Extract "slug stance" pairs from well-formed single-line markers.
  local pairs
  pairs="$(printf '%s\n' "$markers" \
    | sed -nE 's/.*conflict-key:[[:space:]]*([A-Za-z0-9_-]+).*stance:[[:space:]]*(allow|deny).*/\1 \2/p')"

  local slug stances conflicts=0
  while IFS= read -r slug; do
    [ -n "$slug" ] || continue
    stances="$(printf '%s\n' "$pairs" | awk -v s="$slug" '$1==s {print $2}' | sort -u)"
    if printf '%s\n' "$stances" | grep -qx 'allow' \
       && printf '%s\n' "$stances" | grep -qx 'deny'; then
      warn "context-conflict-gate: '$slug' declared both allow and deny across context (resolve the contradiction)"
      conflicts=$((conflicts + 1))
    fi
  done < <(printf '%s\n' "$pairs" | awk '{print $1}' | sort -u)

  if [ "$conflicts" -eq 0 ]; then
    ok "context-conflict-gate: no conflicting directives among declared conflict-key markers"
  fi
}

# 0.8.27 (WU-3): Skill promotion loop (suggest-only).
#
# The flip side of lessons-accumulation: a repeated SUCCESS path is a skill/
# command waiting to be compiled (note 27 — Hermes turns every task into a
# reusable skill MD). This detector reads the consumer's completed-work logs,
# normalizes each finished task into a signature (digits/punctuation stripped),
# and SUGGESTS promotion when a signature recurs at threshold. It is read-only
# and emits info/ok only — never warn/fail — so it never changes doctor's exit
# code and never auto-creates anything. Scope: consumer working tree logs only.
# SSoT: templates/.sfs-local-template/context/policies/skill-promotion-loop.md
SKILL_PROMOTE_THRESHOLD=3
print_skill_promote_section() {
  section "Skill Promotion Candidates"

  local files=() p
  for p in PROGRESS.md .sfs-local/PROGRESS.md docs/solon/*/PROGRESS.md \
           HANDOFF-next-session.md docs/solon/*/HANDOFF-next-session.md; do
    [ -f "$p" ] && files+=("$p")
  done
  if [ "${#files[@]}" -eq 0 ]; then
    info "skill-promote-candidate: no completed-work log found; skipping"
    return
  fi

  # Completed-task lines -> normalized signature (lowercase ASCII, drop digits
  # and punctuation, collapse whitespace) so "release cut 0.8.23/24/25" collapse
  # to one "release cut" signature. Punctuation is stripped via [[:punct:]] (not
  # a whitelist) so non-ASCII text (e.g. Korean task lines) survives instead of
  # being erased. Checkbox accepts [x] or [X].
  local sigs
  sigs="$(grep -hE '^[[:space:]]*-[[:space:]]*\[[xX]\]' "${files[@]}" 2>/dev/null \
    | sed -E 's/^[[:space:]]*-[[:space:]]*\[[xX]\][[:space:]]*//' \
    | tr 'A-Z' 'a-z' \
    | sed -E 's/[0-9]+//g; s/[[:punct:]]+/ /g; s/[[:space:]]+/ /g; s/^ //; s/ $//' \
    | awk 'NF>=1')"
  if [ -z "$sigs" ]; then
    info "skill-promote-candidate: no completed-task entries; skipping"
    return
  fi

  local found=0 line count sig
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    count="${line%% *}"
    sig="${line#* }"
    if [ "$count" -ge "$SKILL_PROMOTE_THRESHOLD" ]; then
      info "skill-promote-candidate: '$sig' completed $count times -- consider compiling a skill/command (suggest-only)"
      found=$((found + 1))
    fi
  done < <(printf '%s\n' "$sigs" | sort | uniq -c | sort -rn | sed -E 's/^[[:space:]]*//')

  if [ "$found" -eq 0 ]; then
    ok "skill-promote-candidate: no repeated work pattern at promote threshold (>=${SKILL_PROMOTE_THRESHOLD})"
  fi
}

print_doctor() {
  section "SFS Project Harness Doctor"
  if ! is_sfs_project; then
    fail "not an initialized SFS project (expected SFS.md + .sfs-local/)"
    section "Summary"
    printf "  pass: %d   warn: %d   fail: %d\n" "$PASS_COUNT" "$WARN_COUNT" "$FAIL_COUNT"
    return 2
  fi

  ok "project initialized ($(project_name), version: $(project_version))"

  section "Entry And Context"
  if looks_bloated_sfs_router; then
    warn "SFS.md looks bloated; run 'sfs doctor --fix' before long agent work"
  else
    ok "SFS.md is thin enough to stay an entry router"
  fi
  if [ -f "${DIST_DIR}/templates/.sfs-local-template/context/kernel.md" ] &&
     [ -f "${DIST_DIR}/templates/.sfs-local-template/context/_INDEX.md" ]; then
    ok "packaged routed context is available"
  else
    fail "packaged routed context is missing"
  fi
  if [ -d ".sfs-local/context" ]; then
    info "project-local context overrides present: .sfs-local/context"
  else
    info "project-local context overrides absent; thin runtime context will be used"
  fi
  for doc in CLAUDE.md AGENTS.md GEMINI.md; do
    if agent_doc_needs_refactor "$doc"; then
      warn "$doc looks like an SFS adapter policy dump; run 'sfs agent doctor --fix'"
    fi
  done

  section "Team And Memory"
  local division state missing_divisions=0
  for division in strategy-pm dev qa design infra taxonomy; do
    if state="$(division_state "$division" 2>/dev/null)"; then
      if [ "$state" = "active" ]; then
        ok "division active: $division"
      else
        ok "division declared: $division (state: $state)"
      fi
    else
      warn "division not declared: $division"
      missing_divisions=$((missing_divisions + 1))
    fi
  done
  if [ -f ".sfs-local/current-sprint" ]; then
    ok "current sprint pointer exists"
  else
    info "no active sprint pointer; harness can still map the project"
  fi
  if [ -f ".sfs-local/harness/evolution-ledger.md" ]; then
    ok "harness evolution ledger present"
  else
    info "harness evolution ledger absent; run 'sfs harness map --write' before evolving generated harnesses"
  fi
  if [ -d "llm-wiki" ]; then
    ok "llm-wiki present as long-horizon memory"
    if [ -d "llm-wiki/bug-reports" ]; then
      ok "bug report recurrence memory present"
    else
      warn "llm-wiki exists but bug-reports/ is missing"
    fi
  elif [ -f ".sfs-local/llm-wiki.waiver" ]; then
    info "llm-wiki absent; waiver recorded (.sfs-local/llm-wiki.waiver) — SFS workbench artifacts remain the memory surface"
  else
    # Strongly-recommended-by-default advisory: no wiki and no waiver. Stays
    # info-only (never warn/fail) so it changes neither doctor's exit code nor
    # the standalone guarantee. SSoT: policies/obsidian-llm-wiki.md.
    info "llm-wiki advisory: wiki strongly recommended but absent and no waiver recorded; build llm-wiki/ or record .sfs-local/llm-wiki.waiver (advisory only, never blocks)"
  fi

  section "Verification Loop"
  if detect_test_surface; then
    ok "test/build surface detected"
  else
    warn "no obvious test/build surface detected"
  fi
  if detect_release_surface; then
    ok "release/check surface detected"
  else
    info "release/check surface not detected; fine for non-distributed projects"
  fi
  if [ "$missing_divisions" -eq 0 ] && detect_test_surface; then
    ok "minimum autonomous-work harness is present"
  else
    warn "minimum autonomous-work harness has gaps; use 'sfs harness map --write' to make them explicit"
  fi

  section "Host Channels And 0.7.0 Surface"
  ok "CLI channel: sfs <cmd> (always present)"
  if detect_mcp_server_artifact; then
    ok "MCP channel available: ${DIST_DIR}/mcp-server/solon_mcp_server.py"
  else
    warn "MCP channel: solon-mcp server not found in distribution (expected mcp-server/solon_mcp_server.py)"
  fi
  if detect_solon_safe_preset; then
    ok "Solon-safe permission preset available"
  else
    warn "Solon-safe permission preset not found (presets/solon-safe-permissions.yaml)"
  fi
  if detect_agent_sdk_template; then
    ok "Claude Agent SDK scaffold available: templates/claude-agent-sdk-zero"
  else
    warn "Claude Agent SDK scaffold not found (templates/claude-agent-sdk-zero/)"
  fi
  if detect_agent_build_track; then
    info "agent-build track detected (Gate 6 review will auto-route to --lens agent-build)"
  else
    info "agent-build track not detected; review lens routing will use the auto/code/docs path"
  fi

  print_operational_log_section

  print_context_conflict_section

  print_skill_promote_section

  section "Summary"
  printf "  pass: %d   warn: %d   fail: %d\n" "$PASS_COUNT" "$WARN_COUNT" "$FAIL_COUNT"
  if [ "$FAIL_COUNT" -gt 0 ]; then
    return 2
  fi
  if [ "$WARN_COUNT" -gt 0 ]; then
    return 1
  fi
  return 0
}

map_status() {
  if "$@" >/dev/null 2>&1; then
    printf "present"
  else
    printf "gap"
  fi
}

write_map_body() {
  local generated_at version test_status release_status wiki_status bug_status
  local entry_status division_status policy_status artifact_status project
  generated_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  version="$(project_version)"
  project="$(project_name)"
  entry_status="$(map_status is_sfs_project)"
  division_status="$(map_status test -f .sfs-local/divisions.yaml)"
  policy_status="$(map_status test -f "${DIST_DIR}/templates/.sfs-local-template/context/_INDEX.md")"
  artifact_status="$(map_status test -d .sfs-local)"
  test_status="$(map_status detect_test_surface)"
  release_status="$(map_status detect_release_surface)"
  wiki_status="$(map_status test -d llm-wiki)"
  bug_status="$(map_status test -d llm-wiki/bug-reports)"

  cat <<EOF
---
doc_id: sfs-project-harness-map
title: "SFS Project Harness Map"
created: ${generated_at}
visibility: raw-internal
doc_type: harness-map
---

# SFS Project Harness Map

- Project: ${project}
- SFS version: ${version:-unknown}
- Generated: ${generated_at}
EOF

  cat <<'EOF'
## Operating Thesis

The model is not the whole system. SFS treats the project as the harness around
the model: agent roles, skills, tools, routed context, artifacts, memory, tests,
and release checks shape how long the AI can work without losing quality.

## Harness Components

| Component | Current role | Status |
|:--|:--|:--|
EOF
  printf '| Agent entry | `SFS.md`, root agent docs, and routed context tell agents where to start without loading a policy archive. | %s |\n' "$entry_status"
  cat <<'EOF'
| Orchestrator | SFS commands route work through brainstorm, plan, implement, review, retro, and release rails. | present |
EOF
  printf '| Division council | strategy-pm, dev, QA, design, infra, taxonomy provide always-on conceptual review. | %s |\n' "$division_status"
  printf '| Skills and policies | Packaged `.sfs-local/context/` modules load only when the slice triggers them. | %s |\n' "$policy_status"
  printf '| Artifacts and memory | `.sfs-local/sprints/`, `docs/solon/`, reports, retros, decisions, and wiki maps hold durable state. | %s |\n' "$artifact_status"
  printf '| Long-horizon wiki | `llm-wiki/` keeps retrieval maps, DDD language, quality maps, and bug recurrence tracking. | %s |\n' "$wiki_status"
  printf '| Bug recurrence memory | `llm-wiki/bug-reports/` records discovery date, fix date, verification, and recurrence analysis. | %s |\n' "$bug_status"
  printf '| Verification loop | Tests, smoke checks, review ledgers, release verifier, or equivalent checks prove repeated trust. | %s |\n' "$test_status"
  printf '| Release loop | Product release verifier, package channels, CI, or deployment runbooks close distributed changes. | %s |\n' "$release_status"
  local mcp_status preset_status sdk_status agentbuild_status
  mcp_status="$(map_status detect_mcp_server_artifact)"
  preset_status="$(map_status detect_solon_safe_preset)"
  sdk_status="$(map_status detect_agent_sdk_template)"
  agentbuild_status="$(map_status detect_agent_build_track)"
  printf '| Host channels (0.7.0+) | CLI is always present; MCP (`solon-mcp` stdio server) is %s; permission baseline (`solon-safe-permissions.yaml`) is %s; Agent SDK scaffold (`claude-agent-sdk-zero`) is %s; this project'\''s own agent-build track signal is %s. | present |\n' \
    "$mcp_status" "$preset_status" "$sdk_status" "$agentbuild_status"
  cat <<'EOF'
| Harness audit | Generated or extended agent harnesses reconcile declared agents, skills, orchestrator pointers, and change history before new workers are added. | present |
| Team architecture | Optional multi-agent work names the selected pattern: pipeline, fan-out/fan-in, expert pool, producer-reviewer, supervisor, or hierarchical delegation. | present |
| Harness evolution | Initial-to-shipped deltas, feedback, and repeated defects are promoted into tests, policies, skills, or scaffold defaults. | present |

## Division Contracts

| Division | Input | Output | Quality Gate |
|:--|:--|:--|:--|
| strategy-pm | user goal, constraints, market/product intent | AC, scope, risk flags, decision boundary | plan contract maps requirement to evidence |
| dev | implementation slice, files scope, failing/characterization evidence | code/docs/scripts/config changes | smallest relevant test/build/smoke passes |
| QA | acceptance criteria, fixtures, release risks | test matrix, defect triage, confidence note | Gate 6 acceptance ledger has no hidden gaps |
| design | user workflow, UI/content surface, interaction state | flow/state checklist, fit/accessibility notes | visible UX is inspectable and non-overlapping |
| infra | auth, secrets, storage, deploy, observability | deploy/rollback/cost/monitor notes | release path is reversible and observable |
| taxonomy | domain terms, entities, states, naming drift | glossary/map/forbidden aliases | user/workspace language stays consistent |

## Autonomy Loop

1. Audit existing harness files, pointers, and history before extending roles or skills.
2. Capture intent as a goal, materials, ask-back rule, and output format.
3. Split work into a small implementation slice with explicit files and evidence.
4. Name an architecture pattern only when optional multi-agent work is selected.
5. Run checks automatically and convert repeated AI mistakes into tests or guardrails.
6. Record initial-to-shipped harness evolution deltas before promoting a pattern.
7. Review artifacts, not chat vibes, then release only after the channel/runtime checks pass.

## Harness Evolution Ledger

`sfs harness map --write` creates `.sfs-local/harness/evolution-ledger.md` when
it is absent and never overwrites an existing ledger. Record one row per
feedback, repeated defect, failed eval, review finding, or manual audit delta.
The ledger columns are source, baseline, shipped delta, hypothesis, acceptance
signal, promotion target, decision, evidence paths, and next check.

## Human Boundary

Humans own goal selection, domain judgment, acceptable tradeoffs, design meaning,
ethics, and public-contract changes. SFS owns execution rails, evidence capture,
repeatability, and making gaps visible before the AI runs too far.

## Next Harness Actions

- Run `sfs harness doctor` before long autonomous or multi-agent work.
- Run `sfs harness map --write` after major project structure changes.
- If the same mistake recurs, add a test, bug report, routed policy, or wiki map instead of another prompt warning.
EOF
}

write_evolution_ledger() {
  local out_path="$1" generated_at project version
  generated_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  project="$(project_name)"
  version="$(project_version)"

  cat <<EOF
---
doc_id: sfs-harness-evolution-ledger
title: "SFS Harness Evolution Ledger"
created: ${generated_at}
visibility: raw-internal
doc_type: harness-evolution-ledger
project: ${project}
sfs_version: ${version:-unknown}
---

# SFS Harness Evolution Ledger

Record one concrete harness evolution delta per row. Do not paste long
transcripts here; link the source report, review, eval output, bug report, or
user feedback artifact.

## Ledger Columns

| Column | Meaning |
|:--|:--|
| ID | Stable id such as HE-YYYYMMDD-01. |
| Source | user-feedback, repeated-defect, failed-eval, review-finding, manual-audit. |
| Baseline harness | Map, agent, skill, policy, scaffold, or test state before change. |
| Shipped delta | What changed: add, split, merge, remove, reroute, eval, guardrail. |
| Hypothesis | Why this should improve time-to-validated artifact or reduce recurrence. |
| Acceptance signal | With-skill vs baseline, near-miss trigger eval, test, smoke, defect recurrence, or reviewer disposition. |
| Promotion target | test, routed policy, skill, scaffold default, wiki map, bug report, or deferred. |
| Decision | accepted, rejected, deferred, plus owner/date. |
| Evidence paths | Compact links to reports, tests, diffs, review outputs, or source notes. |
| Next check | When/how to re-check that the evolution helped. |

## Evolution Entries

| ID | Source | Baseline harness | Shipped delta | Hypothesis | Acceptance signal | Promotion target | Decision | Evidence paths | Next check |
|:--|:--|:--|:--|:--|:--|:--|:--|:--|:--|
| HE-YYYYMMDD-01 | user-feedback | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ | deferred / owner / date | _TBD_ | _TBD_ |

## Promotion Rules

- One-off feedback stays as a ledger row until it repeats or carries high risk.
- Repeated defects promote to a test, routed policy, skill, scaffold default,
  wiki map, or bug report.
- A rejected delta keeps the reason so the same idea does not churn future
  sessions.
- Public/shared promotion needs human-owned product judgment.
EOF
}

run_map() {
  local write_mode=0 out_path=".sfs-local/harness/harness-map.md"
  shift || true
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --write)
        write_mode=1
        shift
        ;;
      --path)
        out_path="${2:-}"
        if [ -z "$out_path" ]; then
          echo "missing value for --path" >&2
          return 2
        fi
        shift 2
        ;;
      -h|--help)
        usage
        return 0
        ;;
      *)
        echo "unknown arg for harness map: $1" >&2
        usage >&2
        return 2
        ;;
    esac
  done

  if [ "$write_mode" = "1" ]; then
    local evolution_path
    evolution_path="$(dirname "$out_path")/evolution-ledger.md"
    mkdir -p "$(dirname "$out_path")" || return 2
    write_map_body > "$out_path" || return 2
    echo "SFS harness map written: $out_path"
    if [ -f "$evolution_path" ]; then
      echo "SFS harness evolution ledger preserved: $evolution_path"
    else
      write_evolution_ledger "$evolution_path" > "$evolution_path" || return 2
      echo "SFS harness evolution ledger written: $evolution_path"
    fi
  else
    write_map_body
  fi
}

case "$COMMAND" in
  doctor|check)
    shift || true
    if [ "$#" -gt 0 ]; then
      case "$1" in
        -h|--help)
          usage
          exit 0
          ;;
        *)
          echo "unknown arg for harness doctor: $1" >&2
          usage >&2
          exit 2
          ;;
      esac
    fi
    print_doctor
    exit $?
    ;;
  map)
    run_map "$@"
    exit $?
    ;;
  -h|--help|help)
    usage
    exit 0
    ;;
  *)
    echo "unknown harness subcommand: $COMMAND" >&2
    usage >&2
    exit 2
    ;;
esac
