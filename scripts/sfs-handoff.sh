#!/usr/bin/env bash
# sfs handoff verify — session-transfer durable-handoff closure check.
#
# Checks the 9-item mandatory sync surface defined in
#   docs/maintenance/policies/session-transfer-autopilot.md
#   (## Durable handoff artifact — mandatory sync surface)
# That policy doc is the SSoT; this command only mechanizes the checklist.
#
# harness doctor is *prevention* (size/lag drift caught any time); handoff
# verify is *transfer-moment closure* — run it before dropping a session so
# the next session does not start from a stale ledger. Any single MISMATCH
# makes the command exit non-zero.
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -t 1 ]; then
  C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_RED=$'\033[31m'
  C_BOLD=$'\033[1m'; C_DIM=$'\033[2m'; C_RESET=$'\033[0m'
else
  C_GREEN=''; C_YELLOW=''; C_RED=''; C_BOLD=''; C_DIM=''; C_RESET=''
fi

PASS_COUNT=0
MISMATCH_COUNT=0
NA_COUNT=0
WARN_COUNT=0

# Dual-repo layout: items 1-2 (VERSION / CHANGELOG) read from the product repo;
# items 3-8 (PROGRESS / HANDOFF / sessions / line budget) read from the docset.
# Both default to "."; --dir sets both (backward compat); --product-dir /
# --docset-dir set each independently; PROGRESS.md frontmatter
# `product_repo_path:` is the fallback product pointer when --product-dir is
# unset (so `sfs handoff verify --dir <docset>` resolves the product on its own).
PRODUCT_DIR="."
DOCSET_DIR="."
PRODUCT_DIR_EXPLICIT=0
DOCSET_DIR_EXPLICIT=0
DIR_VALUE=""

usage() {
  cat <<'EOF'
Usage:
  sfs handoff verify [--dir <root>] [--product-dir <path>] [--docset-dir <path>]

Verifies the durable-handoff mandatory sync surface (9 items) from
session-transfer-autopilot.md. The product VERSION/CHANGELOG (items 1-2) and the
operational ledger (PROGRESS.md, HANDOFF-next-session.md, sessions/_INDEX.md,
items 3-8) frequently live in *different* repos under the dual-repo layout (product repo + docset).

  --dir <root>         set both product and docset roots (default: ".")
  --product-dir <path> product repo holding VERSION + CHANGELOG.md
  --docset-dir <path>  workspace docset holding PROGRESS / HANDOFF / sessions

If --product-dir is omitted, a `product_repo_path:` key in the docset's
PROGRESS.md frontmatter is used as the product root (relative paths resolve
against the docset). With no options at all, both roots are ".".

Each item is marked PASS / MISMATCH / N/A. Any MISMATCH exits 1.
EOF
}

item_pass() {
  printf "  ${C_GREEN}✅ PASS${C_RESET}  %s. %s\n" "$1" "$2"
  PASS_COUNT=$((PASS_COUNT + 1))
}
item_mismatch() {
  printf "  ${C_RED}❌ MISMATCH${C_RESET}  %s. %s\n" "$1" "$2"
  MISMATCH_COUNT=$((MISMATCH_COUNT + 1))
}
item_na() {
  printf "  ${C_DIM}➖ N/A${C_RESET}  %s. %s\n" "$1" "$2"
  NA_COUNT=$((NA_COUNT + 1))
}
item_warn() {
  # Non-fatal: backward-compat gap that should be filled but does not block transfer.
  printf "  ${C_YELLOW}⚠️  WARN${C_RESET}  %s. %s\n" "$1" "$2"
  WARN_COUNT=$((WARN_COUNT + 1))
}

# ── helpers ─────────────────────────────────────────────────────────
version_value() {
  [ -f "${PRODUCT_DIR}/VERSION" ] || return 1
  head -1 "${PRODUCT_DIR}/VERSION" | tr -d '[:space:]'
}

changelog_headline_version() {
  # First "## [X.Y.Z]" section in CHANGELOG (skip Unreleased).
  [ -f "${PRODUCT_DIR}/CHANGELOG.md" ] || return 1
  awk '
    match($0, /^## \[[0-9]+\.[0-9]+\.[0-9]+\]/) {
      v = $0
      sub(/^## \[/, "", v); sub(/\].*/, "", v)
      print v; exit
    }
  ' "${PRODUCT_DIR}/CHANGELOG.md"
}

changelog_has_headline_line() {
  # The first numbered section must carry a "> **...**" summary line.
  [ -f "${PRODUCT_DIR}/CHANGELOG.md" ] || return 1
  awk '
    /^## \[[0-9]+\.[0-9]+\.[0-9]+\]/ { if (seen) exit; seen=1; next }
    seen && /^> / { found=1; exit }
    END { exit (found ? 0 : 1) }
  ' "${PRODUCT_DIR}/CHANGELOG.md"
}

progress_path() {
  local p
  for p in "${DOCSET_DIR}/PROGRESS.md" "${DOCSET_DIR}"/docs/solon/*/PROGRESS.md \
           "${DOCSET_DIR}/.sfs-local/PROGRESS.md"; do
    [ -f "$p" ] && { printf '%s' "$p"; return 0; }
  done
  return 1
}

# product_repo_path frontmatter pointer — top-level YAML key inside the leading
# `---` fence of PROGRESS.md. Used only when --product-dir is unset.
progress_product_repo_path() {
  local file="$1"
  [ -f "$file" ] || return 1
  awk '
    NR == 1 && $0 != "---" { exit 1 }
    NR == 1 { next }
    $0 == "---" { exit 1 }
    /^product_repo_path:[[:space:]]*/ {
      v = $0
      sub(/^product_repo_path:[[:space:]]*/, "", v)
      gsub(/^["'\'']|["'\'']$/, "", v)
      sub(/[[:space:]]+$/, "", v)
      if (v != "") { print v; exit 0 }
    }
  ' "$file"
}

progress_block_value() {
  # progress_block_value <file> <block-key> <field-key>
  local file="$1" block="$2" field="$3"
  awk -v block="$block" -v field="$field" '
    $0 ~ ("^[[:space:]]*" block ":") { in_blk=1; next }
    in_blk && /^[^[:space:]#]/ { exit }
    in_blk && $0 ~ ("[[:space:]]" field ":") {
      v = $0
      sub(("^.*" field ":[[:space:]]*"), "", v)
      gsub(/[[:space:]"'\'']/, "", v)
      if (v != "") { print v; exit }
    }
  ' "$file" 2>/dev/null
}

progress_has_key() {
  local file="$1" key="$2"
  grep -Eq "^[[:space:]]*${key}[[:space:]]*:" "$file" 2>/dev/null
}

# handoff_fm_value <file> <key> — read a top-level frontmatter key from the
# leading `---` fence (used for entry_working_dir / entry_repo).
handoff_fm_value() {
  local file="$1" key="$2"
  [ -f "$file" ] || return 1
  awk -v key="$key" '
    NR == 1 && $0 != "---" { exit 1 }
    NR == 1 { next }
    $0 == "---" { exit }
    $0 ~ ("^" key ":[[:space:]]*") {
      v = $0
      sub(("^" key ":[[:space:]]*"), "", v)
      sub(/[[:space:]]*#.*$/, "", v)            # strip trailing inline comment
      gsub(/^["'\'']|["'\'']$/, "", v)
      sub(/[[:space:]]+$/, "", v)
      if (v != "") { print v; exit }
    }
  ' "$file"
}

# expand a leading ~ to $HOME for entry_working_dir resolution.
expand_tilde() {
  case "$1" in
    "~") printf '%s' "$HOME" ;;
    "~/"*) printf '%s/%s' "$HOME" "${1#\~/}" ;;
    *) printf '%s' "$1" ;;
  esac
}

line_count() { wc -l < "$1" 2>/dev/null | tr -d '[:space:]'; }

budget_state() {
  # echo ok|warn|partial|fail for a file's line count
  local n; n="$(line_count "$1")"
  case "${n:-x}" in ''|*[!0-9]*) echo "unknown"; return ;; esac
  if [ "$n" -ge 250 ]; then echo "fail"
  elif [ "$n" -ge 200 ]; then echo "partial"
  elif [ "$n" -ge 180 ]; then echo "warn"
  else echo "ok"; fi
}

# ── arg parse ───────────────────────────────────────────────────────
while [ "$#" -gt 0 ]; do
  case "$1" in
    --dir) DIR_VALUE="${2:-}"; [ -n "$DIR_VALUE" ] || { echo "missing value for --dir" >&2; exit 2; }; shift 2 ;;
    --dir=*) DIR_VALUE="${1#*=}"; shift ;;
    --product-dir) PRODUCT_DIR="${2:-}"; [ -n "$PRODUCT_DIR" ] || { echo "missing value for --product-dir" >&2; exit 2; }; PRODUCT_DIR_EXPLICIT=1; shift 2 ;;
    --product-dir=*) PRODUCT_DIR="${1#*=}"; PRODUCT_DIR_EXPLICIT=1; shift ;;
    --docset-dir) DOCSET_DIR="${2:-}"; [ -n "$DOCSET_DIR" ] || { echo "missing value for --docset-dir" >&2; exit 2; }; DOCSET_DIR_EXPLICIT=1; shift 2 ;;
    --docset-dir=*) DOCSET_DIR="${1#*=}"; DOCSET_DIR_EXPLICIT=1; shift ;;
    -h|--help|help) usage; exit 0 ;;
    verify) shift ;;
    *) echo "unknown arg for handoff verify: $1" >&2; usage >&2; exit 2 ;;
  esac
done

# Resolve roots. --dir is the base default for whichever side was not set
# explicitly; with no --dir the base default stays ".".
if [ -n "$DIR_VALUE" ]; then
  [ "$DOCSET_DIR_EXPLICIT" -eq 1 ] || DOCSET_DIR="$DIR_VALUE"
  [ "$PRODUCT_DIR_EXPLICIT" -eq 1 ] || PRODUCT_DIR="$DIR_VALUE"
fi

[ -d "$DOCSET_DIR" ] || { echo "docset root not found: $DOCSET_DIR" >&2; exit 2; }

# Frontmatter product pointer fallback (only when --product-dir not given).
PRODUCT_SOURCE="--product-dir/--dir"
if [ "$PRODUCT_DIR_EXPLICIT" -eq 0 ]; then
  PP="$(progress_product_repo_path "$(progress_path || true)" 2>/dev/null || true)"
  if [ -n "$PP" ]; then
    case "$PP" in
      /*) PRODUCT_DIR="$PP" ;;
      *)  PRODUCT_DIR="${DOCSET_DIR%/}/${PP}" ;;
    esac
    PRODUCT_SOURCE="PROGRESS.md product_repo_path"
  fi
fi

[ -d "$PRODUCT_DIR" ] || { echo "product root not found: $PRODUCT_DIR (source: ${PRODUCT_SOURCE})" >&2; exit 2; }

printf "\n${C_BOLD}Durable Handoff Verify${C_RESET}\n"
printf "${C_DIM}  product: %s   docset: %s${C_RESET}\n" "$PRODUCT_DIR" "$DOCSET_DIR"
printf "${C_DIM}  product source: %s${C_RESET}\n" "$PRODUCT_SOURCE"
printf "${C_DIM}SSoT: session-transfer-autopilot.md — mandatory sync surface${C_RESET}\n\n"

VERSION_VAL="$(version_value || true)"
CHANGELOG_VER="$(changelog_headline_version || true)"
PROGRESS="$(progress_path || true)"

# 1. product VERSION
if [ -n "$VERSION_VAL" ]; then
  item_pass "1" "product VERSION present: ${VERSION_VAL}"
else
  item_mismatch "1" "VERSION file missing or empty at ${PRODUCT_DIR}/VERSION"
fi

# 2. CHANGELOG headline
if [ -n "$CHANGELOG_VER" ] && changelog_has_headline_line; then
  if [ -n "$VERSION_VAL" ] && [ "$CHANGELOG_VER" != "$VERSION_VAL" ]; then
    item_mismatch "2" "CHANGELOG latest section [${CHANGELOG_VER}] != VERSION ${VERSION_VAL}"
  else
    item_pass "2" "CHANGELOG headline section [${CHANGELOG_VER}] has summary line"
  fi
elif [ -n "$CHANGELOG_VER" ]; then
  item_mismatch "2" "CHANGELOG [${CHANGELOG_VER}] section missing a '> **summary**' headline line"
else
  item_mismatch "2" "no numbered '## [X.Y.Z]' release section in CHANGELOG.md"
fi

# 3. PROGRESS.md last_completed_release matches VERSION/CHANGELOG
if [ -n "$PROGRESS" ]; then
  LCR_VER="$(progress_block_value "$PROGRESS" "last_completed_release" "version")"
  if [ -z "$LCR_VER" ]; then
    item_mismatch "3" "${PROGRESS} has no last_completed_release.version"
  elif [ -n "$VERSION_VAL" ] && [ "$LCR_VER" != "$VERSION_VAL" ]; then
    item_mismatch "3" "last_completed_release.version ${LCR_VER} != VERSION ${VERSION_VAL}"
  else
    item_pass "3" "last_completed_release.version ${LCR_VER} matches VERSION"
  fi
else
  item_na "3" "no PROGRESS.md found under ${DOCSET_DIR}; ledger items skipped"
fi

# 4. recent_session_owner_history present
if [ -n "$PROGRESS" ]; then
  if progress_has_key "$PROGRESS" "recent_session_owner_history"; then
    item_pass "4" "recent_session_owner_history present in PROGRESS.md"
  else
    item_mismatch "4" "PROGRESS.md missing recent_session_owner_history"
  fi
else
  item_na "4" "no PROGRESS.md; session-owner history skipped"
fi

# 5. resume_hint.default_action present + not pinned to an older release
if [ -n "$PROGRESS" ]; then
  if progress_has_key "$PROGRESS" "resume_hint"; then
    DA="$(progress_block_value "$PROGRESS" "resume_hint" "default_action")"
    if [ -z "$DA" ]; then
      item_mismatch "5" "resume_hint present but default_action empty"
    else
      item_pass "5" "resume_hint.default_action set"
    fi
  else
    item_mismatch "5" "PROGRESS.md missing resume_hint.default_action"
  fi
else
  item_na "5" "no PROGRESS.md; resume hint skipped"
fi

# 6. HANDOFF-next-session.md present and non-empty
HANDOFF=""
for p in "${DOCSET_DIR}/HANDOFF-next-session.md" "${DOCSET_DIR}"/docs/solon/*/HANDOFF-next-session.md; do
  [ -f "$p" ] && { HANDOFF="$p"; break; }
done
if [ -n "$HANDOFF" ]; then
  if [ "$(line_count "$HANDOFF")" -ge 1 ] && grep -Eqi 'branch|sha|WU|mode|next' "$HANDOFF"; then
    item_pass "6" "HANDOFF stub present: ${HANDOFF}"
  else
    item_mismatch "6" "${HANDOFF} present but missing branch/sha/WU/mode handoff content"
  fi
else
  item_mismatch "6" "HANDOFF-next-session.md not found under ${DOCSET_DIR}"
fi

# 7. sessions/_INDEX.md present with updated: frontmatter
SESS=""
for p in "${DOCSET_DIR}/sessions/_INDEX.md" "${DOCSET_DIR}"/docs/solon/*/sessions/_INDEX.md; do
  [ -f "$p" ] && { SESS="$p"; break; }
done
if [ -n "$SESS" ]; then
  if grep -Eq '^updated:' "$SESS"; then
    item_pass "7" "sessions/_INDEX.md present with updated: frontmatter"
  else
    item_mismatch "7" "${SESS} missing updated: frontmatter date"
  fi
else
  item_na "7" "no sessions/_INDEX.md under ${DOCSET_DIR}; ledger index skipped"
fi

# 8. 200-line policy compliance on (3)(6)(7) files
budget_ok=1
budget_detail=""
for f in "$PROGRESS" "$HANDOFF" "$SESS"; do
  [ -n "$f" ] && [ -f "$f" ] || continue
  st="$(budget_state "$f")"
  budget_detail="${budget_detail} ${f##*/}=${st}"
  case "$st" in partial|fail) budget_ok=0 ;; esac
done
if [ -z "$budget_detail" ]; then
  item_na "8" "no operational-log files present to size-check"
elif [ "$budget_ok" -eq 1 ]; then
  item_pass "8" "200-line budget:${budget_detail}"
else
  item_mismatch "8" "200-line budget exceeded (partial/fail):${budget_detail} — archive-rotate then re-sync"
fi

# 9. HANDOFF entry_working_dir declared + resume target resolves there.
# Prevents the cross-repo silent non-pickup: a handoff authored in the docset
# but opened in the distribution repo (or vice-versa) finds no PROGRESS/sprints/
# CLAUDE.md and mis-reads the absence as "nothing to do".
if [ -z "$HANDOFF" ]; then
  item_na "9" "no HANDOFF-next-session.md; entry-dir check skipped"
else
  EWD="$(handoff_fm_value "$HANDOFF" "entry_working_dir" || true)"
  EREPO="$(handoff_fm_value "$HANDOFF" "entry_repo" || true)"
  if [ -z "$EWD" ]; then
    item_warn "9" "HANDOFF has no entry_working_dir — receiver runtime may open the wrong repo (docset vs distribution); add entry_working_dir + entry_repo + entry_warning"
  else
    EWD_RESOLVED="$(expand_tilde "$EWD")"
    case "$EWD_RESOLVED" in
      /*) : ;;
      *) EWD_RESOLVED="${DOCSET_DIR%/}/${EWD_RESOLVED}" ;;
    esac
    if [ ! -d "$EWD_RESOLVED" ]; then
      item_mismatch "9" "entry_working_dir '${EWD}' does not resolve to a directory (${EWD_RESOLVED})"
    elif [ -f "${EWD_RESOLVED}/PROGRESS.md" ] || [ -d "${EWD_RESOLVED}/sprints" ] || [ -f "${EWD_RESOLVED}/CLAUDE.md" ]; then
      item_pass "9" "entry_working_dir resolves a resume target: ${EWD}${EREPO:+ (repo: ${EREPO})}"
    else
      item_mismatch "9" "entry_working_dir '${EWD}' has no resume target (PROGRESS.md / sprints/ / CLAUDE.md) — next session would silently find nothing"
    fi
  fi
fi

printf "\n${C_BOLD}Summary${C_RESET}\n"
printf "  PASS: %d   MISMATCH: %d   WARN: %d   N/A: %d\n" "$PASS_COUNT" "$MISMATCH_COUNT" "$WARN_COUNT" "$NA_COUNT"
if [ "$MISMATCH_COUNT" -gt 0 ]; then
  printf "  ${C_RED}handoff verify FAILED — resolve mismatches before transferring the session.${C_RESET}\n"
  exit 1
fi
printf "  ${C_GREEN}handoff verify OK — durable handoff surface is in sync.${C_RESET}\n"
exit 0
