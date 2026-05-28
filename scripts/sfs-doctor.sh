#!/usr/bin/env bash
# sfs-doctor.sh — diagnose Solon Product runtime health, with focus on
# slash-command discovery.
#
# Exit codes:
#   0  all checks pass
#   1  warnings only (degraded but functional)
#   2  hard failure (`sfs` binary itself broken)

set -u

HOME_DIR="${HOME:-$USERPROFILE}"
SOLON_REPO="${SOLON_REPO:-MJ-0701/solon-product}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FIX_MODE=0

if [ -t 1 ]; then
  C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_RED=$'\033[31m'
  C_BOLD=$'\033[1m'; C_DIM=$'\033[2m'; C_RESET=$'\033[0m'
else
  C_GREEN=''; C_YELLOW=''; C_RED=''; C_BOLD=''; C_DIM=''; C_RESET=''
fi

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

ok()   { printf "  ${C_GREEN}✅${C_RESET} %s\n" "$*"; PASS_COUNT=$((PASS_COUNT+1)); }
warn() { printf "  ${C_YELLOW}⚠️${C_RESET}  %s\n" "$*"; WARN_COUNT=$((WARN_COUNT+1)); }
fail() { printf "  ${C_RED}❌${C_RESET} %s\n" "$*"; FAIL_COUNT=$((FAIL_COUNT+1)); }
info() { printf "  ${C_DIM}%s${C_RESET}\n" "$*"; }
section() { printf "\n${C_BOLD}%s${C_RESET}\n" "$*"; }

usage() {
  cat <<'EOF'
Usage:
  sfs doctor [--fix]

Checks global Solon runtime discovery plus current-project SFS surfaces.
With --fix, recognized SFS.md router bloat is archived and rewritten as a thin
router while preserving the "## 프로젝트 개요" section. Root LLM agent docs are
delegated to "sfs agent doctor --fix".
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --fix|--apply)
      FIX_MODE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf "unknown arg: %s\n" "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

sfs_router_doc_is_sfs() {
  local file="$1"
  [ -f "$file" ] || return 1
  grep -Fq "doc_type: solon-router" "$file" 2>/dev/null && return 0
  grep -Fq "Solon SFS has two meanings" "$file" 2>/dev/null && return 0
  grep -Fq "sfs context cat kernel" "$file" 2>/dev/null && return 0
  grep -Fq "Project overview refresh" "$file" 2>/dev/null && return 0
  return 1
}

sfs_router_doc_needs_refactor() {
  local file="$1" marker lines
  sfs_router_doc_is_sfs "$file" || return 1
  for marker in \
    "SFS commands —" \
    "Executable Action Ownership" \
    "Monitor checkpoint classification" \
    "Handoff-only scope is a stop contract" \
    "Session Continuation Guard" \
    "Division sub-agent council is always-on" \
    "User-escalation premise guard" \
    "DDD/TDD is a product-level engineering floor" \
    "compact option bundle"; do
    grep -Fq "$marker" "$file" 2>/dev/null && return 0
  done
  lines="$(wc -l < "$file" 2>/dev/null | tr -d '[:space:]')"
  case "${lines:-0}" in
    ''|*[!0-9]*) return 1 ;;
  esac
  [ "$lines" -gt 90 ]
}

sfs_router_extract_overview() {
  local src="$1" out="$2"
  awk '
    $0 == "## 프로젝트 개요" {
      in_section = 1
      found = 1
      seen_bullet = 0
      print
      next
    }
    in_section && /^## / {
      exit
    }
    in_section && /^-/ {
      seen_bullet = 1
      print
      next
    }
    in_section && seen_bullet && /^[[:space:]]/ {
      print
      next
    }
    in_section && seen_bullet {
      exit
    }
    in_section {
      print
    }
    END {
      exit found ? 0 : 1
    }
  ' "$src" > "$out"
}

sfs_router_write_template() {
  local dst="$1" overview="$2" template="$DIST_DIR/templates/SFS.md.template"
  local tmp project_name today
  [ -f "$template" ] || return 4
  tmp="$dst.tmp.$$"
  project_name="$(basename "$PWD")"
  today="$(date +%F)"
  awk -v block_file="$overview" '
    BEGIN {
      while ((getline line < block_file) > 0) {
        block = block line "\n"
      }
      close(block_file)
      in_profile = 0
      replaced = 0
    }
    $0 == "## 프로젝트 개요" && block != "" {
      printf "%s", block
      in_profile = 1
      replaced = 1
      next
    }
    in_profile && /^## / {
      in_profile = 0
      print
      next
    }
    !in_profile {
      print
    }
    END {
      if (!replaced && block != "") {
        print ""
        printf "%s", block
      }
    }
  ' "$template" | sed \
    -e "s|<PROJECT-NAME>|$project_name|g" \
    -e "s|<DATE>|$today|g" > "$tmp" || return 5
  mv "$tmp" "$dst"
}

sfs_router_refactor() {
  local file="$1" ts backup_dir stage archive overview manifest
  ts="$(date +%Y%m%d-%H%M%S)"
  backup_dir="$PWD/.sfs-local/archives/sfs-router-doc-refactor/$ts"
  stage="$backup_dir/.stage"
  archive="$backup_dir/SFS.md.tar.gz"
  overview="$(mktemp "${TMPDIR:-/tmp}/sfs-router-overview.XXXXXX")" || return 5
  mkdir -p "$stage" || return 5
  cp "$file" "$stage/SFS.md" || return 5
  if ! sfs_router_extract_overview "$file" "$overview"; then
    sed -n '/^## 프로젝트 개요$/,/^## /p' "$DIST_DIR/templates/SFS.md.template" > "$overview"
  fi
  sfs_router_write_template "$file" "$overview" || return $?
  rm -f "$overview"
  manifest="$backup_dir/manifest.txt"
  {
    echo "SFS router doc refactor backup"
    echo "generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "reason: recognized SFS.md contained routed policy body; SFS.md must stay a thin router"
    echo "archive: $archive"
    echo "items:"
    echo "- SFS.md"
  } > "$manifest" || return 5
  tar -czf "$archive" -C "$stage" . || return 5
  rm -rf "$stage" || return 5
  printf "%s\n" "${archive#$PWD/}"
}

check_project_docs() {
  local file="SFS.md" archive_out agent_out agent_rc
  if [ ! -f "$file" ]; then
    info "SFS.md not found in current directory"
    return 0
  fi
  if ! sfs_router_doc_is_sfs "$file"; then
    warn "SFS.md exists but does not look like an SFS router; skipped automatic refactor"
    return 0
  fi
  if sfs_router_doc_needs_refactor "$file"; then
    if [ "$FIX_MODE" = "1" ]; then
      archive_out="$(sfs_router_refactor "$file" 2>/dev/null || true)"
      if [ -n "$archive_out" ]; then
        ok "SFS.md thin-router refactor applied (backup: $archive_out)"
      else
        fail "SFS.md thin-router refactor failed"
      fi
    else
      warn "SFS.md needs thin-router refactor — run 'sfs doctor --fix'"
    fi
  else
    ok "SFS.md is a thin router"
  fi

  if [ "$FIX_MODE" = "1" ] && command -v sfs >/dev/null 2>&1; then
    agent_out="$(sfs agent doctor --fix 2>&1)"
    agent_rc=$?
    if [ "$agent_rc" = "0" ]; then
      ok "root agent docs checked/fixed by sfs agent doctor --fix"
      [ -n "$agent_out" ] && info "$agent_out"
    else
      warn "root agent doc doctor returned $agent_rc"
      [ -n "$agent_out" ] && info "$agent_out"
    fi
  elif [ "$FIX_MODE" != "1" ] && command -v sfs >/dev/null 2>&1; then
    agent_out="$(sfs agent doctor 2>&1)"
    agent_rc=$?
    if printf "%s\n" "$agent_out" | grep -Fq "needs-refactor:"; then
      warn "root agent docs need frontmatter-only refactor — run 'sfs agent doctor --fix'"
    else
      ok "root agent docs are thin or not SFS-owned"
    fi
  fi
}

# ---------------------------------------------------------------------------
# 1. sfs binary
# ---------------------------------------------------------------------------
section "Solon runtime"

if command -v sfs >/dev/null 2>&1; then
  SFS_VER="$(sfs version 2>/dev/null | head -1 || echo unknown)"
  ok "sfs binary on PATH (version: $SFS_VER)"
else
  fail "sfs binary NOT on PATH — install via Homebrew (macOS) or Scoop (Windows)"
  fail "  recovery: brew install MJ-0701/solon-product/sfs"
  exit 2
fi

# ---------------------------------------------------------------------------
# 2. Slash-command discovery — three CLI surfaces
# ---------------------------------------------------------------------------
section "Slash-command discovery"

# 2.1 Claude Code
if command -v claude >/dev/null 2>&1; then
  CC_VER="$(claude --version 2>/dev/null | head -1 || echo unknown)"
  info "Claude Code detected: $CC_VER"
  CC_PLUGIN_DIR="$HOME_DIR/.claude/plugins/solon"
  CC_SETTINGS="$HOME_DIR/.claude/settings.json"
  CC_OK=0
  if [ -d "$CC_PLUGIN_DIR" ]; then
    ok "Claude Code: plugin filesystem deployed at ~/.claude/plugins/solon (A-2)"
    CC_OK=1
  fi
  if [ -f "$CC_SETTINGS" ] && grep -q "solon" "$CC_SETTINGS" 2>/dev/null; then
    ok "Claude Code: settings.json references solon (extraKnownMarketplaces / enabledPlugins)"
    CC_OK=1
    if command -v jq >/dev/null 2>&1; then
      FIRST_PLUGIN="$(jq -r '(.enabledPlugins // {}) | keys_unsorted[0] // empty' "$CC_SETTINGS" 2>/dev/null || true)"
      if [ "$FIRST_PLUGIN" = "solon@solon" ]; then
        ok "Claude Code: solon is first enabled plugin (priority-1)"
      elif [ -n "$FIRST_PLUGIN" ]; then
        warn "Claude Code: solon is installed but not first enabled plugin (first=$FIRST_PLUGIN)"
        warn "  If this was intentional, no action needed. To force Solon first again: SFS_DISCOVERY_FORCE_PROMOTE=1 sfs upgrade"
      fi
    fi
  fi
  # Try CLI subcommand inspection (best-effort). Some Claude builds can hang
  # here when plugin auth/state is stale, so only run it behind timeout(1).
  if command -v timeout >/dev/null 2>&1; then
    if timeout 5 claude plugin list 2>/dev/null | grep -qi "solon"; then
      ok "Claude Code: 'claude plugin list' shows solon (A-1 path active)"
      CC_OK=1
    fi
  else
    info "Claude Code: skip 'claude plugin list' probe (timeout command unavailable)"
  fi
  if [ "$CC_OK" = "0" ]; then
    warn "Claude Code: solon plugin not registered"
    warn "  recovery: claude plugin marketplace add $SOLON_REPO"
    warn "  alternative: re-run 'sfs upgrade' to trigger the install hook"
  fi
else
  info "Claude Code: not on PATH (skip)"
fi

# 2.2 Gemini CLI
if command -v gemini >/dev/null 2>&1; then
  GM_VER="$(gemini --version 2>/dev/null | head -1 || echo unknown)"
  info "Gemini CLI detected: $GM_VER"
  GM_EXTENSION_DIR="$HOME_DIR/.gemini/extensions/solon"
  if [ -f "$GM_EXTENSION_DIR/gemini-extension.json" ] || [ -f "$GM_EXTENSION_DIR/commands/sfs.toml" ]; then
    ok "Gemini CLI: solon extension filesystem present at ~/.gemini/extensions/solon"
    GM_ENABLE="$HOME_DIR/.gemini/extensions/extension-enablement.json"
    if [ -f "$GM_ENABLE" ] && command -v jq >/dev/null 2>&1; then
      FIRST_EXT="$(jq -r 'keys_unsorted[0] // empty' "$GM_ENABLE" 2>/dev/null || true)"
      if [ "$FIRST_EXT" = "solon" ]; then
        ok "Gemini CLI: solon is first extension enablement entry (priority-1)"
      elif [ -n "$FIRST_EXT" ]; then
        warn "Gemini CLI: solon extension installed but not first enablement entry (first=$FIRST_EXT)"
        warn "  If this was intentional, no action needed. To force Solon first again: SFS_DISCOVERY_FORCE_PROMOTE=1 sfs upgrade"
      fi
    fi
  elif gemini extensions list 2>/dev/null | grep -qiE "(^|/)solon\b|MJ-0701/solon-product"; then
    ok "Gemini CLI: solon extension installed"
    GM_ENABLE="$HOME_DIR/.gemini/extensions/extension-enablement.json"
    if [ -f "$GM_ENABLE" ] && command -v jq >/dev/null 2>&1; then
      FIRST_EXT="$(jq -r 'keys_unsorted[0] // empty' "$GM_ENABLE" 2>/dev/null || true)"
      if [ "$FIRST_EXT" = "solon" ]; then
        ok "Gemini CLI: solon is first extension enablement entry (priority-1)"
      elif [ -n "$FIRST_EXT" ]; then
        warn "Gemini CLI: solon extension installed but not first enablement entry (first=$FIRST_EXT)"
        warn "  If this was intentional, no action needed. To force Solon first again: SFS_DISCOVERY_FORCE_PROMOTE=1 sfs upgrade"
      fi
    fi
  else
    warn "Gemini CLI: solon extension NOT installed"
    warn "  recovery: gemini extensions install --consent https://github.com/$SOLON_REPO.git"
  fi
else
  info "Gemini CLI: not on PATH (skip)"
fi

# 2.3 Codex CLI
CODEX_SKILL="$HOME_DIR/.codex/skills/sfs/SKILL.md"
if [ -f "$CODEX_SKILL" ]; then
  ok "Codex CLI: user-global skill at ~/.codex/skills/sfs/SKILL.md (C-1)"
  if grep -q "Priority-1 Solon SFS" "$CODEX_SKILL" 2>/dev/null; then
    ok "Codex CLI: SFS skill advertises priority-1 routing"
  else
    warn "Codex CLI: SFS skill exists but lacks priority-1 routing text"
    warn "  recovery: re-run 'sfs upgrade' to refresh ~/.codex/skills/sfs/SKILL.md"
  fi
else
  warn "Codex CLI: ~/.codex/skills/sfs/SKILL.md NOT found"
  warn "  recovery: re-run 'sfs upgrade' (or reinstall via brew/scoop)"
fi
if command -v codex >/dev/null 2>&1; then
  CDX_VER="$(codex --version 2>/dev/null | head -1 || echo unknown)"
  info "Codex CLI detected: $CDX_VER"
fi

# ---------------------------------------------------------------------------
# 3. Project state (only when invoked inside a project)
# ---------------------------------------------------------------------------
section "Project state (current dir)"
if [ -f "SFS.md" ] && [ -f ".sfs-local/VERSION" ]; then
  PROJ_VER="$(grep -E '^solon_(mvp|product)_version:' .sfs-local/VERSION 2>/dev/null | head -1 | awk -F: '{gsub(/ /,"",$2); print $2}')"
  ok "project initialized (SFS.md + .sfs-local/VERSION present, $PROJ_VER)"
  check_project_docs
else
  info "no Solon project at current directory (skip — run 'sfs init' to initialize)"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
section "Summary"
printf "  pass: %d   warn: %d   fail: %d\n" "$PASS_COUNT" "$WARN_COUNT" "$FAIL_COUNT"
echo

if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 2
elif [ "$WARN_COUNT" -gt 0 ]; then
  exit 1
fi
exit 0
