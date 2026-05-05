#!/usr/bin/env bash
# install-cli-discovery.sh — 0.5.96-product slash-command zero-file discovery hook
#
# Purpose: After `sfs` binary is on PATH (Homebrew/Scoop installed),
#   register the three CLI discovery surfaces:
#     1. Claude Code:  /plugin marketplace add MJ-0701/solon-product  (A-1)
#                      OR  filesystem-direct deploy + settings.json edit  (A-2 fallback)
#     2. Gemini CLI:   gemini extensions install --consent --auto-update <url>
#     3. Codex CLI:    cp <bundle>/codex-skill/SKILL.md  ~/.codex/skills/sfs/SKILL.md  (C-1)
#
# Idempotent: re-runs as no-op when state already correct.
# Graceful: failure of any single CLI hook prints a warning but does NOT
#   abort the parent install (D7 = b).
# Source of truth for decisions: HANDOFF §4.A + research report §5.

set -u  # do not -e — graceful degrade per D7

# ---------------------------------------------------------------------------
# Defaults / config
# ---------------------------------------------------------------------------
SOLON_REPO="${SOLON_REPO:-MJ-0701/solon-product}"
SOLON_PRODUCT_REPO="${SOLON_PRODUCT_REPO:-MJ-0701/solon-product}"
SOURCE_DIR="${SFS_DISCOVERY_SOURCE_DIR:-}"  # caller may inject; we autodetect otherwise
HOME_DIR="${HOME:-$USERPROFILE}"
A1_FIRST="${SFS_DISCOVERY_A1_FIRST:-1}"   # set 0 to skip A-1 and go straight to A-2
PROMOTE_FIRST="${SFS_DISCOVERY_PROMOTE_FIRST:-1}"   # set 0 to never reorder existing priority
FORCE_PROMOTE="${SFS_DISCOVERY_FORCE_PROMOTE:-0}"   # set 1 to repair a user-managed order back to solon-first

# Color helpers (no-op if not interactive)
if [ -t 1 ]; then
  C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_RED=$'\033[31m'
  C_BOLD=$'\033[1m'; C_RESET=$'\033[0m'
else
  C_GREEN=''; C_YELLOW=''; C_RED=''; C_BOLD=''; C_RESET=''
fi
ok()    { printf "  ${C_GREEN}✓${C_RESET} %s\n" "$*"; }
warn()  { printf "  ${C_YELLOW}!${C_RESET} %s\n" "$*"; }
fail()  { printf "  ${C_RED}✗${C_RESET} %s\n" "$*"; }
info()  { printf "  %s\n" "$*"; }

json_file_or_empty_object() {
  local file="$1"
  if [ -f "$file" ]; then
    cat "$file"
  else
    printf '{}'
  fi
}

priority_marker_file() {
  printf '%s\n' "$HOME_DIR/.sfs/discovery-priority.json"
}

priority_marker_has() {
  local key="$1"
  local marker
  marker="$(priority_marker_file)"
  [ -f "$marker" ] || return 1
  command -v jq >/dev/null 2>&1 || return 1
  jq -e --arg key "$key" '(.promoted // {})[$key] == true' "$marker" >/dev/null 2>&1
}

mark_priority_promoted() {
  local key="$1"
  command -v jq >/dev/null 2>&1 || return 0
  local marker tmp now
  marker="$(priority_marker_file)"
  mkdir -p "$(dirname "$marker")"
  now="$(date -u '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date '+%Y-%m-%dT%H:%M:%SZ')"
  tmp="$(mktemp 2>/dev/null || mktemp -t sfs_discovery_priority)"
  json_file_or_empty_object "$marker" |
    jq --arg key "$key" --arg now "$now" '
      .promoted[$key] = true
      | .lastPromotedAt[$key] = $now
      | .policy = "promote solon to first on install/update; if user later changes order, respect unless SFS_DISCOVERY_FORCE_PROMOTE=1"
    ' > "$tmp" && mv "$tmp" "$marker"
}

should_promote_priority() {
  local key="$1"
  local current_first="$2"
  local desired_first="$3"
  local label="$4"

  if [ "$PROMOTE_FIRST" != "1" ]; then
    info "$label: priority promotion disabled by SFS_DISCOVERY_PROMOTE_FIRST=0"
    return 1
  fi
  if [ "$FORCE_PROMOTE" = "1" ]; then
    return 0
  fi
  if [ -z "$current_first" ] || [ "$current_first" = "$desired_first" ]; then
    return 0
  fi
  if priority_marker_has "$key"; then
    warn "$label: user-managed priority detected (first=$current_first) — respecting existing order"
    warn "  To force Solon first again: SFS_DISCOVERY_FORCE_PROMOTE=1 sfs upgrade"
    return 1
  fi
  return 0
}

promote_claude_priority() {
  if ! command -v jq >/dev/null 2>&1; then
    warn "Claude Code: jq not on PATH — skip priority reorder (manual settings edit may be needed)"
    return 0
  fi

  local SETTINGS="$HOME_DIR/.claude/settings.json"
  mkdir -p "$(dirname "$SETTINGS")"
  local CURRENT_FIRST
  CURRENT_FIRST="$(json_file_or_empty_object "$SETTINGS" | jq -r '(.enabledPlugins // {}) | keys_unsorted[0] // empty' 2>/dev/null || true)"
  if ! should_promote_priority "claude" "$CURRENT_FIRST" "solon@solon" "Claude Code"; then
    return 0
  fi
  local TMP
  TMP="$(mktemp 2>/dev/null || mktemp -t settings)"
  json_file_or_empty_object "$SETTINGS" |
    jq --arg plugin "solon@solon" --arg market "solon" --arg repo "$SOLON_REPO" '
      .enabledPlugins = ({($plugin): true} + ((.enabledPlugins // {}) | del(.[$plugin])))
      | .extraKnownMarketplaces = ({($market): (((.extraKnownMarketplaces // {})[$market]) // {"source":{"source":"github","repo":$repo}})} + ((.extraKnownMarketplaces // {}) | del(.[$market])))
    ' > "$TMP" && mv "$TMP" "$SETTINGS"
  ok "Claude Code: solon promoted to first enabled plugin in ~/.claude/settings.json"

  local INSTALLED="$HOME_DIR/.claude/plugins/installed_plugins.json"
  if [ -f "$INSTALLED" ]; then
    TMP="$(mktemp 2>/dev/null || mktemp -t installed_plugins)"
    jq --arg plugin "solon@solon" '
      if (.plugins // {})[$plugin] then
        .plugins = ({($plugin): .plugins[$plugin]} + (.plugins | del(.[$plugin])))
      else . end
    ' "$INSTALLED" > "$TMP" && mv "$TMP" "$INSTALLED"
    ok "Claude Code: solon promoted to first plugin registry entry"
  fi

  local KNOWN="$HOME_DIR/.claude/plugins/known_marketplaces.json"
  if [ -f "$KNOWN" ]; then
    TMP="$(mktemp 2>/dev/null || mktemp -t known_marketplaces)"
    jq --arg market "solon" --arg repo "$SOLON_REPO" '
      {($market): (.[$market] // {"source":{"source":"github","repo":$repo}})}
      + (del(.[$market]))
    ' "$KNOWN" > "$TMP" && mv "$TMP" "$KNOWN"
    ok "Claude Code: solon promoted to first marketplace registry entry"
  fi
  mark_priority_promoted "claude"
}

promote_gemini_priority() {
  if ! command -v jq >/dev/null 2>&1; then
    warn "Gemini CLI: jq not on PATH — skip extension priority reorder"
    return 0
  fi
  local ENABLE="$HOME_DIR/.gemini/extensions/extension-enablement.json"
  mkdir -p "$(dirname "$ENABLE")"
  local CURRENT_FIRST
  CURRENT_FIRST="$(json_file_or_empty_object "$ENABLE" | jq -r 'keys_unsorted[0] // empty' 2>/dev/null || true)"
  if ! should_promote_priority "gemini" "$CURRENT_FIRST" "solon" "Gemini CLI"; then
    return 0
  fi
  local TMP
  TMP="$(mktemp 2>/dev/null || mktemp -t gemini_extension_enablement)"
  json_file_or_empty_object "$ENABLE" |
    jq --arg name "solon" --arg home "$HOME_DIR" '
      {($name): (.[$name] // {"overrides":[($home + "/*")]})}
      + (del(.[$name]))
    ' > "$TMP" && mv "$TMP" "$ENABLE"
  ok "Gemini CLI: solon promoted to first extension enablement entry"
  mark_priority_promoted "gemini"
}

# Find the bundle root (where templates/codex-skill/SKILL.md lives)
discover_source_dir() {
  if [ -n "$SOURCE_DIR" ] && [ -f "$SOURCE_DIR/templates/codex-skill/SKILL.md" ]; then
    return 0
  fi
  # try: alongside this script's parent (solon-mvp-dist root)
  local self_dir
  self_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd 2>/dev/null)"
  if [ -f "$self_dir/templates/codex-skill/SKILL.md" ]; then
    SOURCE_DIR="$self_dir"
    return 0
  fi
  # try: Homebrew Cellar share/sfs/
  for cand in /opt/homebrew/share/sfs /usr/local/share/sfs "$HOME_DIR/.local/share/sfs"; do
    if [ -f "$cand/templates/codex-skill/SKILL.md" ]; then
      SOURCE_DIR="$cand"
      return 0
    fi
  done
  return 1
}

# ---------------------------------------------------------------------------
# Step 1: Claude Code plugin discovery
# ---------------------------------------------------------------------------
install_claude_discovery() {
  if ! command -v claude >/dev/null 2>&1; then
    info "Claude Code: not on PATH — skip"
    return 0
  fi

  local CLAUDE_VERSION
  CLAUDE_VERSION="$(claude --version 2>/dev/null | head -1 || true)"
  info "Claude Code detected: ${CLAUDE_VERSION:-unknown}"

  if [ "$A1_FIRST" = "1" ]; then
    # A-1: try CLI subcommand non-interactively. The exact subcommand name
    # is uncertain across versions (issue #12999) — try multiple shapes.
    local A1_OUT
    A1_OUT="$(claude plugin marketplace add "$SOLON_REPO" 2>&1 || true)"
    if echo "$A1_OUT" | grep -qiE "(added|already|registered|installed)"; then
      ok "Claude Code: marketplace registered via 'claude plugin marketplace add' (A-1)"
      claude plugin install "solon@solon" >/dev/null 2>&1 || true
      ok "Claude Code: /sfs slash command should be discoverable on next session restart"
      promote_claude_priority
      return 0
    fi
    # fall through to A-2
    warn "Claude Code: A-1 CLI subcommand path unavailable on this version"
    warn "  $(echo "$A1_OUT" | head -1)"
  fi

  # A-2: filesystem-direct deploy + settings.json merge
  local PLUGIN_DEST="$HOME_DIR/.claude/plugins/solon"
  mkdir -p "$PLUGIN_DEST/.claude-plugin" "$PLUGIN_DEST/commands"

  if [ -n "$SOURCE_DIR" ] && [ -d "$SOURCE_DIR/templates" ]; then
    # 0.5.96-product onward: stable repo (MJ-0701/solon-product) hosts both
    # dist tarball + marketplace skeleton at root. We shallow-clone the
    # repo to a temp dir and copy plugins/solon/ into the cellar.
    if command -v git >/dev/null 2>&1; then
      local TMPCLONE
      TMPCLONE="$(mktemp -d 2>/dev/null || mktemp -d -t solon)"
      if git clone --depth 1 "https://github.com/$SOLON_REPO.git" "$TMPCLONE" >/dev/null 2>&1; then
        if [ -d "$TMPCLONE/plugins/solon" ]; then
          cp -R "$TMPCLONE/plugins/solon/." "$PLUGIN_DEST/"
          ok "Claude Code: plugin filesystem-direct deployed at ~/.claude/plugins/solon (A-2)"
        else
          warn "Claude Code: cloned $SOLON_REPO but no plugins/solon/ at root — skip A-2"
        fi
        rm -rf "$TMPCLONE"
      else
        warn "Claude Code: git clone of $SOLON_REPO failed — A-2 skipped"
      fi
    else
      warn "Claude Code: git not on PATH — A-2 cannot deploy plugin filesystem"
    fi
  fi

  # Idempotent settings/registry merge + ordering. Install/update exposes SFS
  # first, but later user-managed priority changes are respected unless forced.
  promote_claude_priority
}

# ---------------------------------------------------------------------------
# Step 2: Gemini CLI extension
# ---------------------------------------------------------------------------
install_gemini_discovery() {
  if ! command -v gemini >/dev/null 2>&1; then
    info "Gemini CLI: not on PATH — skip"
    return 0
  fi
  if ! command -v git >/dev/null 2>&1; then
    warn "Gemini CLI: git not on PATH — extension install requires git"
    warn "  Manual recovery (after installing git):"
    warn "    gemini extensions install --consent https://github.com/$SOLON_REPO.git"
    return 0
  fi

  info "Gemini CLI detected"
  local GM_EXTENSION_DIR="$HOME_DIR/.gemini/extensions/solon"
  if [ -f "$GM_EXTENSION_DIR/gemini-extension.json" ] || [ -f "$GM_EXTENSION_DIR/commands/sfs.toml" ]; then
    ok "Gemini CLI: solon extension filesystem present at ~/.gemini/extensions/solon"
    promote_gemini_priority
    return 0
  fi

  # Idempotent: list current extensions, install only if not present
  local LIST
  LIST="$(gemini extensions list 2>/dev/null || true)"
  if echo "$LIST" | grep -qiE "(^|/)solon\b|MJ-0701/solon-product"; then
    ok "Gemini CLI: solon extension already installed — skip"
    promote_gemini_priority
    return 0
  fi

  local OUT
  OUT="$(gemini extensions install --consent --auto-update "https://github.com/$SOLON_REPO.git" 2>&1 || true)"
  if echo "$OUT" | grep -qiE "(installed|already)"; then
    ok "Gemini CLI: extension installed via 'gemini extensions install --consent'"
    promote_gemini_priority
  else
    warn "Gemini CLI: extension install did not confirm success"
    warn "  Output: $(echo "$OUT" | head -2 | tr '\n' ' ')"
    warn "  Manual recovery: gemini extensions install --consent https://github.com/$SOLON_REPO.git"
  fi
}

# ---------------------------------------------------------------------------
# Step 3: Codex CLI user-global skill (C-1)
# ---------------------------------------------------------------------------
install_codex_discovery() {
  if ! discover_source_dir || [ ! -f "$SOURCE_DIR/templates/codex-skill/SKILL.md" ]; then
    warn "Codex CLI: source bundle not found — skip"
    warn "  (templates/codex-skill/SKILL.md missing)"
    return 0
  fi

  local DEST_DIR="$HOME_DIR/.codex/skills/sfs"
  mkdir -p "$DEST_DIR"
  cp "$SOURCE_DIR/templates/codex-skill/SKILL.md" "$DEST_DIR/SKILL.md"
  ok "Codex CLI: priority-1 user-global skill installed at ~/.codex/skills/sfs/SKILL.md (C-1)"

  # Codex CLI presence is informational — the SKILL is auto-discovered
  # whenever Codex starts in any project.
  if ! command -v codex >/dev/null 2>&1; then
    info "  (Codex CLI not on PATH; skill ready for when it is installed)"
  fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  echo
  echo "${C_BOLD}Solon CLI discovery (slash-command zero-file)${C_RESET}"
  echo
  install_claude_discovery
  echo
  install_gemini_discovery
  echo
  install_codex_discovery
  echo

  cat <<EOF
Verify with:
  ${C_BOLD}sfs doctor${C_RESET}            — check all three CLI discovery paths
  ${C_BOLD}claude${C_RESET} → /sfs        — Claude Code slash command autocomplete
  ${C_BOLD}gemini${C_RESET} → sfs status  — Gemini CLI command
  ${C_BOLD}codex${C_RESET}  → \$sfs status — Codex CLI Skill invocation

If any step warned above, the manual recovery line printed alongside is
the one-shot fix. The brew/scoop install of \`sfs\` itself is unaffected.
EOF
  return 0  # always exit 0; failures are warnings (D7 = b graceful)
}

main "$@"
