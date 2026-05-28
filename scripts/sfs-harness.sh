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
  [ -d "2026-04-19-sfs-v0.4/solon-mvp-dist/tests" ] && return 0
  [ -f "package.json" ] && grep -Eq '"(test|smoke|build)"[[:space:]]*:' package.json 2>/dev/null && return 0
  [ -f "pnpm-lock.yaml" ] && return 0
  [ -f "pom.xml" ] && return 0
  [ -f "build.gradle" ] && return 0
  [ -f "build.gradle.kts" ] && return 0
  [ -x "./gradlew" ] && return 0
  return 1
}

detect_release_surface() {
  [ -f "2026-04-19-sfs-v0.4/scripts/verify-product-release.sh" ] && return 0
  [ -f "scripts/verify-product-release.sh" ] && return 0
  [ -f ".github/workflows/sfs-pr-check.yml" ] && return 0
  [ -f ".github/workflows/windows-scoop-smoke.yml" ] && return 0
  return 1
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
  if [ -d "llm-wiki" ]; then
    ok "llm-wiki present as long-horizon memory"
    if [ -d "llm-wiki/bug-reports" ]; then
      ok "bug report recurrence memory present"
    else
      warn "llm-wiki exists but bug-reports/ is missing"
    fi
  else
    info "llm-wiki absent; SFS workbench artifacts remain the memory surface"
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
  cat <<'EOF'

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

1. Capture intent as a goal, materials, ask-back rule, and output format.
2. Split work into a small implementation slice with explicit files and evidence.
3. Let the division council record findings, waivers, and `asset_candidate` items.
4. Run checks automatically and convert repeated AI mistakes into tests or guardrails.
5. Review artifacts, not chat vibes, then release only after the channel/runtime checks pass.

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
    mkdir -p "$(dirname "$out_path")" || return 2
    write_map_body > "$out_path" || return 2
    echo "SFS harness map written: $out_path"
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
