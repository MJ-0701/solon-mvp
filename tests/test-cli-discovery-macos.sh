#!/usr/bin/env bash
# test-cli-discovery-macos.sh — verify install-cli-discovery.sh behavior in
# a sandboxed environment without requiring real claude/gemini/codex CLIs.
#
# Tests:
#   T1  Codex skill is copied to $HOME/.codex/skills/sfs/SKILL.md
#   T2  Hook exits 0 when claude/gemini/codex are NOT on PATH (graceful)
#   T3  Idempotency: running hook twice does not error and ends in same state
#   T4  Bundle source-dir auto-detection works when invoked from script dir
#   T5  Claude plugin settings/registries promote solon to first on install/update
#   T6  Later user-managed priority change is respected unless forced
#
# Exit: 0 = all pass, non-zero = first failure

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOK="$DIST_DIR/scripts/install-cli-discovery.sh"
SKILL_SRC="$DIST_DIR/templates/codex-skill/SKILL.md"

if [ ! -f "$HOOK" ]; then echo "FAIL: hook not found at $HOOK"; exit 2; fi
if [ ! -f "$SKILL_SRC" ]; then echo "FAIL: SKILL.md source not found at $SKILL_SRC"; exit 2; fi

PASS=0
FAIL=0
report() {
  local label="$1"; local outcome="$2"; local detail="${3:-}"
  if [ "$outcome" = "PASS" ]; then
    printf "  ✓ %-40s PASS\n" "$label"; PASS=$((PASS+1))
  else
    printf "  ✗ %-40s FAIL  %s\n" "$label" "$detail"; FAIL=$((FAIL+1))
  fi
}

# Sandbox: fake HOME + isolated PATH (no claude/gemini/codex)
TMPHOME="$(mktemp -d -t solon-disc-XXXXXX)"
cleanup() { rm -rf "$TMPHOME"; }
trap cleanup EXIT

# T2 + T1 + T4 (combined: first run, no CLIs available)
HOME="$TMPHOME" \
  USERPROFILE="$TMPHOME" \
  PATH="/usr/bin:/bin" \
  SFS_DISCOVERY_SOURCE_DIR="$DIST_DIR" \
  bash "$HOOK" >"$TMPHOME/run1.log" 2>&1
EXIT1=$?

if [ "$EXIT1" = "0" ]; then
  report "T2 graceful exit 0 (no CLIs)" "PASS"
else
  report "T2 graceful exit 0 (no CLIs)" "FAIL" "exit=$EXIT1"
fi

if [ -f "$TMPHOME/.codex/skills/sfs/SKILL.md" ]; then
  if cmp -s "$SKILL_SRC" "$TMPHOME/.codex/skills/sfs/SKILL.md"; then
    report "T1 codex skill installed (C-1)" "PASS"
  else
    report "T1 codex skill installed (C-1)" "FAIL" "content mismatch"
  fi
else
  report "T1 codex skill installed (C-1)" "FAIL" "file missing"
fi

# T4 source-dir auto-detect (re-run without SFS_DISCOVERY_SOURCE_DIR)
rm -rf "$TMPHOME/.codex"
HOME="$TMPHOME" \
  USERPROFILE="$TMPHOME" \
  PATH="/usr/bin:/bin" \
  bash "$HOOK" >"$TMPHOME/run2.log" 2>&1
EXIT2=$?
if [ "$EXIT2" = "0" ] && [ -f "$TMPHOME/.codex/skills/sfs/SKILL.md" ]; then
  report "T4 source-dir auto-detect" "PASS"
else
  report "T4 source-dir auto-detect" "FAIL" "exit=$EXIT2 file=$([ -f "$TMPHOME/.codex/skills/sfs/SKILL.md" ] && echo present || echo missing)"
fi

# T3 idempotency: third run, expect identical end state, exit 0
HOME="$TMPHOME" \
  USERPROFILE="$TMPHOME" \
  PATH="/usr/bin:/bin" \
  SFS_DISCOVERY_SOURCE_DIR="$DIST_DIR" \
  bash "$HOOK" >"$TMPHOME/run3.log" 2>&1
EXIT3=$?
if [ "$EXIT3" = "0" ] && cmp -s "$SKILL_SRC" "$TMPHOME/.codex/skills/sfs/SKILL.md"; then
  report "T3 idempotent re-run" "PASS"
else
  report "T3 idempotent re-run" "FAIL" "exit=$EXIT3"
fi

# T5 priority: fake Claude is present and reports plugin already installed.
# The hook must still reorder settings/registry files so SFS is exposed first.
FAKEBIN="$TMPHOME/fakebin"
mkdir -p "$FAKEBIN"
cat >"$FAKEBIN/claude" <<'EOF'
#!/usr/bin/env bash
case "${1:-}" in
  --version) echo "claude fake 1.0.0"; exit 0 ;;
  plugin) echo "already installed"; exit 0 ;;
  *) echo "ok"; exit 0 ;;
esac
EOF
chmod +x "$FAKEBIN/claude"
mkdir -p "$TMPHOME/.claude/plugins"
cat >"$TMPHOME/.claude/settings.json" <<'EOF'
{
  "enabledPlugins": {
    "bkit@bkit-marketplace": true,
    "solon@solon": true,
    "other@market": true
  },
  "extraKnownMarketplaces": {
    "bkit-marketplace": { "source": { "source": "github", "repo": "popup-studio-ai/bkit-claude-code" } },
    "solon": { "source": { "source": "github", "repo": "MJ-0701/solon-product" } }
  }
}
EOF
cat >"$TMPHOME/.claude/plugins/installed_plugins.json" <<'EOF'
{
  "version": 2,
  "plugins": {
    "bkit@bkit-marketplace": [],
    "solon@solon": [],
    "other@market": []
  }
}
EOF
cat >"$TMPHOME/.claude/plugins/known_marketplaces.json" <<'EOF'
{
  "bkit-marketplace": { "source": { "source": "github", "repo": "popup-studio-ai/bkit-claude-code" } },
  "solon": { "source": { "source": "github", "repo": "MJ-0701/solon-product" } }
}
EOF

HOME="$TMPHOME" \
  USERPROFILE="$TMPHOME" \
  PATH="$FAKEBIN:/usr/bin:/bin" \
  SFS_DISCOVERY_SOURCE_DIR="$DIST_DIR" \
  bash "$HOOK" >"$TMPHOME/run4.log" 2>&1
EXIT4=$?
first_enabled="$(jq -r '.enabledPlugins | keys_unsorted[0]' "$TMPHOME/.claude/settings.json")"
first_market="$(jq -r '.extraKnownMarketplaces | keys_unsorted[0]' "$TMPHOME/.claude/settings.json")"
first_registry="$(jq -r '.plugins | keys_unsorted[0]' "$TMPHOME/.claude/plugins/installed_plugins.json")"
first_known="$(jq -r 'keys_unsorted[0]' "$TMPHOME/.claude/plugins/known_marketplaces.json")"
if [ "$EXIT4" = "0" ] &&
   [ "$first_enabled" = "solon@solon" ] &&
   [ "$first_market" = "solon" ] &&
   [ "$first_registry" = "solon@solon" ] &&
   [ "$first_known" = "solon" ]; then
  report "T5 solon priority on install/update" "PASS"
else
  report "T5 solon priority on install/update" "FAIL" "exit=$EXIT4 enabled=$first_enabled market=$first_market registry=$first_registry known=$first_known"
fi

# T6 user-managed order: after T5 writes the marker, a later manual reorder
# should be respected on normal install/update reruns.
cat >"$TMPHOME/.claude/settings.json" <<'EOF'
{
  "enabledPlugins": {
    "bkit@bkit-marketplace": true,
    "solon@solon": true
  },
  "extraKnownMarketplaces": {
    "bkit-marketplace": { "source": { "source": "github", "repo": "popup-studio-ai/bkit-claude-code" } },
    "solon": { "source": { "source": "github", "repo": "MJ-0701/solon-product" } }
  }
}
EOF
HOME="$TMPHOME" \
  USERPROFILE="$TMPHOME" \
  PATH="$FAKEBIN:/usr/bin:/bin" \
  SFS_DISCOVERY_SOURCE_DIR="$DIST_DIR" \
  bash "$HOOK" >"$TMPHOME/run5.log" 2>&1
EXIT5=$?
first_after_user="$(jq -r '.enabledPlugins | keys_unsorted[0]' "$TMPHOME/.claude/settings.json")"
if [ "$EXIT5" = "0" ] && [ "$first_after_user" = "bkit@bkit-marketplace" ]; then
  report "T6 respect user-managed priority" "PASS"
else
  report "T6 respect user-managed priority" "FAIL" "exit=$EXIT5 first=$first_after_user"
fi

echo
printf "  pass: %d   fail: %d\n" "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
