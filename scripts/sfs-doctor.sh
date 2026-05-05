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
