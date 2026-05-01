#!/usr/bin/env bash
# .sfs-local/scripts/sfs-adopt.sh
#
# Solon SFS — `/sfs adopt [--apply]`.
# Creates a compact legacy-baseline sprint for projects that already have code
# and git history but no useful SFS sprint trail. The visible result is
# report.md + retro.md only; raw scan evidence is kept under archives.

set -euo pipefail

SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

: "${SFS_EXIT_BADCLI:=7}"

usage_adopt() {
  cat <<'EOF'
Usage:
  /sfs adopt [--id <sprint-id>] [--apply] [--force] [--max-commits <N>]

Adopt an existing legacy project into SFS without creating document sprawl.
  - Default is dry-run; it prints the baseline sprint and evidence sources.
  - --apply creates .sfs-local/sprints/<id>/report.md and retro.md only.
  - Existing visible sprint folders and expanded archive folders are collapsed
    into cold .tar.gz archives with short manifests.
  - Raw scan evidence is preserved in .sfs-local/archives/adopt/<id>/...
  - The report separates evidence-backed facts from inferred next sprint ideas.
  - Existing docs/sprint files are read as signals when present, but git/code
    history is the primary source because most legacy projects have no SFS docs.

Exit codes:
  0  ok
  1  no .sfs-local/ or target sprint exists without --force
  3  not a git repo
  5  permission denied
  7  usage
  99 unknown
EOF
}

validate_sprint_id_arg() {
  local sid="${1:-}"
  case "${sid}" in
    ""|*..*|*/*|*\\*|*$'\n'*|*$'\t'*|*' '*|.*)
      echo "invalid sprint-id: '${sid}'" >&2
      return "${SFS_EXIT_BADCLI}"
      ;;
  esac
  return "${SFS_EXIT_OK}"
}

json_escape() {
  printf '%s' "${1:-}" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

has_tracked_match() {
  local pattern="$1"
  git ls-files 2>/dev/null | grep -E -q "${pattern}"
}

detect_stack_signals() {
  local signals=""
  [[ -f package.json ]] && signals="${signals}node/package.json, "
  [[ -f pnpm-lock.yaml ]] && signals="${signals}pnpm, "
  [[ -f yarn.lock ]] && signals="${signals}yarn, "
  [[ -f package-lock.json ]] && signals="${signals}npm, "
  [[ -f pyproject.toml ]] && signals="${signals}python/pyproject, "
  [[ -f requirements.txt ]] && signals="${signals}python/requirements, "
  [[ -f uv.lock ]] && signals="${signals}uv, "
  [[ -f poetry.lock ]] && signals="${signals}poetry, "
  [[ -f pom.xml ]] && signals="${signals}maven, "
  [[ -f build.gradle || -f build.gradle.kts || -f settings.gradle || -f settings.gradle.kts ]] && signals="${signals}gradle, "
  [[ -f go.mod ]] && signals="${signals}go, "
  [[ -f Cargo.toml ]] && signals="${signals}rust, "
  [[ -f Dockerfile ]] && signals="${signals}dockerfile, "
  [[ -f docker-compose.yml || -f compose.yml ]] && signals="${signals}compose, "
  [[ -f Makefile ]] && signals="${signals}make, "
  [[ ! -f pyproject.toml && ! -f requirements.txt && ! -f uv.lock && ! -f poetry.lock ]] && has_tracked_match '\.py$' && signals="${signals}python/files, "
  [[ ! -f package.json && ! -f pnpm-lock.yaml && ! -f yarn.lock && ! -f package-lock.json ]] && has_tracked_match '\.(js|jsx|ts|tsx)$' && signals="${signals}javascript/files, "
  [[ ! -f pom.xml && ! -f build.gradle && ! -f build.gradle.kts && ! -f settings.gradle && ! -f settings.gradle.kts ]] && has_tracked_match '\.(java|kt|kts)$' && signals="${signals}jvm/files, "
  [[ ! -f go.mod ]] && has_tracked_match '\.go$' && signals="${signals}go/files, "
  [[ ! -f Cargo.toml ]] && has_tracked_match '\.rs$' && signals="${signals}rust/files, "
  signals="${signals%, }"
  printf '%s\n' "${signals:-none detected}"
}

suggest_verify_commands() {
  local cmds=""
  [[ -f package.json ]] && cmds="${cmds}- npm test / npm run build (if defined)"$'\n'
  [[ -f pnpm-lock.yaml ]] && cmds="${cmds}- pnpm test / pnpm build (if defined)"$'\n'
  [[ -f pyproject.toml || -f requirements.txt ]] && cmds="${cmds}- pytest or project-specific Python smoke"$'\n'
  [[ -f build.gradle || -f build.gradle.kts || -f settings.gradle || -f settings.gradle.kts ]] && cmds="${cmds}- ./gradlew test"$'\n'
  [[ -f pom.xml ]] && cmds="${cmds}- mvn test"$'\n'
  [[ -f go.mod ]] && cmds="${cmds}- go test ./..."$'\n'
  [[ -f Cargo.toml ]] && cmds="${cmds}- cargo test"$'\n'
  [[ -f Makefile ]] && cmds="${cmds}- make test or make check (if defined)"$'\n'
  if [[ -z "${cmds}" ]]; then
    if has_tracked_match '\.py$'; then
      cmds="- run project-specific Python smoke check"$'\n'
    elif has_tracked_match '\.(js|jsx|ts|tsx)$'; then
      cmds="- run project-specific Node/browser smoke check"$'\n'
    elif has_tracked_match '\.(java|kt|kts)$'; then
      cmds="- run project-specific JVM smoke check"$'\n'
    else
      cmds="- define a baseline smoke command (no docs/test/build signals detected)"$'\n'
    fi
  fi
  printf '%s' "${cmds}"
}

count_paths() {
  local pattern="$1"
  git ls-files 2>/dev/null | { grep -E "${pattern}" || true; } | wc -l | tr -d '[:space:]'
}

top_changed_paths() {
  local max_commits="$1"
  git log --name-only --pretty=format: -n "${max_commits}" 2>/dev/null \
    | sed '/^[[:space:]]*$/d' \
    | awk -F/ '{ if (NF >= 2) print $1"/"$2; else print $1 }' \
    | sort | uniq -c | sort -nr | head -12 \
    | sed 's/^/  - /'
}

nonempty_line_count() {
  local text="${1:-}"
  if [[ -z "${text}" ]]; then
    printf '0\n'
    return "${SFS_EXIT_OK}"
  fi
  printf '%s\n' "${text}" | sed '/^[[:space:]]*$/d' | wc -l | tr -d '[:space:]'
}

existing_sprint_ids_for_adopt() {
  [[ -d "${SFS_SPRINTS_DIR}" ]] || return "${SFS_EXIT_OK}"
  find "${SFS_SPRINTS_DIR}" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null \
    | while IFS= read -r dir; do
        sid="$(basename "${dir}")"
        [[ "${sid}" == "${SPRINT_ID}" ]] && continue
        if [[ "${PRESERVE_CURRENT_SPRINT:-0}" -eq 1 && "${sid}" == "${CURRENT_SPRINT:-}" ]]; then
          continue
        fi
        printf '%s\n' "${sid}"
      done \
    | sort
}

existing_archive_ids_for_adopt() {
  [[ -d "${SFS_ARCHIVES_DIR}" ]] || return "${SFS_EXIT_OK}"
  find "${SFS_ARCHIVES_DIR}" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null \
    | while IFS= read -r dir; do
        aid="$(basename "${dir}")"
        [[ "${aid}" == "adopt" ]] && continue
        printf '%s\n' "${aid}"
      done \
    | sort
}

print_cold_archive_plan() {
  local label="${1:?label required}" ids="${2:-}" base_dir="${3:?base dir required}" archive_path="${4:?archive path required}" manifest_path="${5:?manifest path required}"
  local count
  count="$(nonempty_line_count "${ids}")"
  echo "  ${label}: ${count}"
  [[ "${count}" -gt 0 ]] || return "${SFS_EXIT_OK}"
  echo "    cold_archive: ${archive_path}"
  echo "    manifest: ${manifest_path}"
  printf '%s\n' "${ids}" | while IFS= read -r item; do
    [[ -n "${item}" ]] || continue
    echo "    - ${base_dir}/${item}"
  done
}

collapse_dirs_to_cold_archive() {
  local ids="${1:-}" base_dir="${2:?base dir required}" archive_path="${3:?archive path required}" manifest_path="${4:?manifest path required}" title="${5:?title required}"
  local count item
  local tar_items=()
  count="$(nonempty_line_count "${ids}")"
  [[ "${count}" -gt 0 ]] || return "${SFS_EXIT_OK}"
  mkdir -p "$(dirname "${archive_path}")" || return "${SFS_EXIT_PERM}"
  {
    echo "${title}"
    echo "generated_at: ${NOW}"
    echo "source_root: ${base_dir}"
    echo "archive: ${archive_path}"
    echo "count: ${count}"
    echo
    echo "items:"
    printf '%s\n' "${ids}" | while IFS= read -r item; do
      [[ -n "${item}" ]] || continue
      echo "- ${base_dir}/${item}"
    done
  } > "${manifest_path}" || return "${SFS_EXIT_PERM}"

  while IFS= read -r item; do
    [[ -n "${item}" ]] || continue
    tar_items+=("${item}")
  done <<< "${ids}"
  tar -czf "${archive_path}" -C "${base_dir}" "${tar_items[@]}" || return "${SFS_EXIT_PERM}"

  while IFS= read -r item; do
    [[ -n "${item}" ]] || continue
    rm -rf "${base_dir}/${item}" || return "${SFS_EXIT_PERM}"
  done <<< "${ids}"
  return "${SFS_EXIT_OK}"
}

SPRINT_ID="legacy-baseline"
APPLY=0
FORCE=0
MAX_COMMITS=80

while [[ $# -gt 0 ]]; do
  case "$1" in
    --id)
      if [[ $# -lt 2 ]]; then
        echo "--id requires a value" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      SPRINT_ID="$2"
      shift 2
      ;;
    --id=*)
      SPRINT_ID="${1#--id=}"
      shift
      ;;
    --apply)
      APPLY=1
      shift
      ;;
    --dry-run)
      APPLY=0
      shift
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --max-commits)
      if [[ $# -lt 2 ]]; then
        echo "--max-commits requires a value" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      MAX_COMMITS="$2"
      shift 2
      ;;
    --max-commits=*)
      MAX_COMMITS="${1#--max-commits=}"
      shift
      ;;
    -h|--help)
      usage_adopt
      exit "${SFS_EXIT_OK}"
      ;;
    --)
      shift
      if [[ $# -gt 0 ]]; then
        echo "unexpected extra args after --: $*" >&2
        exit "${SFS_EXIT_BADCLI}"
      fi
      ;;
    -*)
      echo "unknown flag: $1" >&2
      exit "${SFS_EXIT_BADCLI}"
      ;;
    *)
      echo "unknown arg: $1" >&2
      exit "${SFS_EXIT_BADCLI}"
      ;;
  esac
done

validate_sprint_id_arg "${SPRINT_ID}" || exit "$?"
case "${MAX_COMMITS}" in
  ''|*[!0-9]*)
    echo "invalid --max-commits: ${MAX_COMMITS}" >&2
    exit "${SFS_EXIT_BADCLI}"
    ;;
esac
if [[ "${MAX_COMMITS}" -lt 1 ]]; then
  echo "invalid --max-commits: ${MAX_COMMITS}" >&2
  exit "${SFS_EXIT_BADCLI}"
fi

set +e
validate_sfs_local
_validate_rc=$?
set -e
if [[ "${_validate_rc}" -ne 0 ]]; then
  exit "${_validate_rc}"
fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "not a git repo (adopt requires git history)" >&2
  exit "${SFS_EXIT_NO_GIT}"
fi

NOW="$(date +%Y-%m-%dT%H:%M:%S%z 2>/dev/null | sed -E 's/([0-9]{2})$/:\1/')"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
BRANCH="$(git branch --show-current 2>/dev/null || true)"
HEAD_SHA="$(git rev-parse --short HEAD 2>/dev/null || true)"
FIRST_COMMIT="$(git rev-list --max-parents=0 HEAD 2>/dev/null | head -1 | cut -c1-12 || true)"
COMMIT_COUNT="$(git rev-list --count HEAD 2>/dev/null || echo 0)"
TRACKED_COUNT="$(git ls-files 2>/dev/null | wc -l | tr -d '[:space:]')"
DOC_COUNT="$(count_paths '(^|/)(docs?|README|CHANGELOG|AGENTS|CLAUDE|GEMINI|SFS)(/|\.|$)')"
TEST_COUNT="$(count_paths '(^|/)(test|tests|spec|specs|__tests__|src/test)(/|$)|(_test|\.spec|\.test)\.')"
STACK_SIGNALS="$(detect_stack_signals)"
SUBMODULE_STATUS="$(git submodule status --recursive 2>/dev/null || true)"
SUBMODULE_COUNT="$(git ls-files --stage 2>/dev/null | awk '$1 == "160000" {c++} END {print c+0}')"
SFS_SPRINT_COUNT=0
if [[ -d "${SFS_SPRINTS_DIR}" ]]; then
  SFS_SPRINT_COUNT="$(find "${SFS_SPRINTS_DIR}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d '[:space:]')"
fi

TARGET_DIR="${SFS_SPRINTS_DIR}/${SPRINT_ID}"
REPORT_PATH="${TARGET_DIR}/report.md"
RETRO_PATH="${TARGET_DIR}/retro.md"
ARCHIVE_DIR="${SFS_ARCHIVES_DIR}/adopt/${SPRINT_ID}/${NOW//:/-}"
ARCHIVE_DIR="${ARCHIVE_DIR//+/-}"
CURRENT_SPRINT=""
if [[ -f "${SFS_CURRENT_SPRINT_FILE}" ]]; then
  CURRENT_SPRINT="$(sed -n '1p' "${SFS_CURRENT_SPRINT_FILE}" 2>/dev/null | tr -d '[:space:]' || true)"
fi
PRESERVE_CURRENT_SPRINT=0
if [[ -d "${TARGET_DIR}" && -n "${CURRENT_SPRINT}" && "${CURRENT_SPRINT}" != "${SPRINT_ID}" ]]; then
  PRESERVE_CURRENT_SPRINT=1
fi
EXISTING_SPRINT_IDS="$(existing_sprint_ids_for_adopt)"
EXISTING_ARCHIVE_IDS="$(existing_archive_ids_for_adopt)"
EXISTING_SPRINT_ARCHIVE_COUNT="$(nonempty_line_count "${EXISTING_SPRINT_IDS}")"
EXISTING_ARCHIVE_COLLAPSE_COUNT="$(nonempty_line_count "${EXISTING_ARCHIVE_IDS}")"
EXISTING_SPRINTS_TARBALL="${ARCHIVE_DIR}/existing-sprints.tar.gz"
EXISTING_SPRINTS_MANIFEST="${ARCHIVE_DIR}/existing-sprints.manifest.txt"
EXISTING_ARCHIVES_TARBALL="${ARCHIVE_DIR}/preexisting-archives.tar.gz"
EXISTING_ARCHIVES_MANIFEST="${ARCHIVE_DIR}/preexisting-archives.manifest.txt"
PREEXISTING_TARGET_TARBALL="${ARCHIVE_DIR}/preexisting-target.tar.gz"
PREEXISTING_TARGET_MANIFEST="${ARCHIVE_DIR}/preexisting-target.manifest.txt"

if [[ "${APPLY}" -eq 0 ]]; then
  echo "adopt dry-run: ${SPRINT_ID}"
  echo "  root: ${ROOT}"
  echo "  branch: ${BRANCH:--} @ ${HEAD_SHA:--}"
  echo "  commits: ${COMMIT_COUNT} (first ${FIRST_COMMIT:--}, scan last ${MAX_COMMITS})"
  echo "  tracked_files: ${TRACKED_COUNT}"
  echo "  docs_signals: ${DOC_COUNT}"
  echo "  test_signals: ${TEST_COUNT}"
  echo "  stack: ${STACK_SIGNALS}"
  echo "  submodules: ${SUBMODULE_COUNT}"
  if [[ "${PRESERVE_CURRENT_SPRINT}" -eq 1 ]]; then
    echo "  preserve_current_sprint: ${CURRENT_SPRINT} (target exists; treating as post-adopt real sprint)"
  fi
  if [[ -d "${TARGET_DIR}" && "${FORCE}" -ne 1 ]]; then
    echo "  target: ${TARGET_DIR} (exists; --apply would require --force)"
  else
    echo "  target: ${TARGET_DIR}"
  fi
  echo "  would_create:"
  echo "    - ${REPORT_PATH}"
  echo "    - ${RETRO_PATH}"
  echo "  would_archive:"
  echo "    - ${ARCHIVE_DIR}/source-summary.txt"
  print_cold_archive_plan "would_archive_existing_sprints" "${EXISTING_SPRINT_IDS}" "${SFS_SPRINTS_DIR}" "${EXISTING_SPRINTS_TARBALL}" "${EXISTING_SPRINTS_MANIFEST}"
  print_cold_archive_plan "would_collapse_existing_archives" "${EXISTING_ARCHIVE_IDS}" "${SFS_ARCHIVES_DIR}" "${EXISTING_ARCHIVES_TARBALL}" "${EXISTING_ARCHIVES_MANIFEST}"
  if [[ -d "${TARGET_DIR}" && "${FORCE}" -eq 1 ]]; then
    echo "  would_archive_existing_target: 1"
    echo "    cold_archive: ${PREEXISTING_TARGET_TARBALL}"
    echo "    manifest: ${PREEXISTING_TARGET_MANIFEST}"
    echo "    - ${TARGET_DIR}"
  fi
  echo "  visible_policy: report.md + retro.md only; raw scan evidence stays archived"
  exit "${SFS_EXIT_OK}"
fi

if [[ -d "${TARGET_DIR}" && "${FORCE}" -ne 1 ]]; then
  echo "sprint ${SPRINT_ID} already exists, use --force or choose --id" >&2
  exit "${SFS_EXIT_NO_INIT}"
fi

mkdir -p "${ARCHIVE_DIR}" || exit "${SFS_EXIT_PERM}"

if [[ -d "${TARGET_DIR}" && "${FORCE}" -eq 1 ]]; then
  collapse_dirs_to_cold_archive "${SPRINT_ID}" "${SFS_SPRINTS_DIR}" "${PREEXISTING_TARGET_TARBALL}" "${PREEXISTING_TARGET_MANIFEST}" "SFS adopt preexisting target sprint archive" || exit "${SFS_EXIT_PERM}"
fi

collapse_dirs_to_cold_archive "${EXISTING_SPRINT_IDS}" "${SFS_SPRINTS_DIR}" "${EXISTING_SPRINTS_TARBALL}" "${EXISTING_SPRINTS_MANIFEST}" "SFS adopt preexisting sprint archive" || exit "${SFS_EXIT_PERM}"
collapse_dirs_to_cold_archive "${EXISTING_ARCHIVE_IDS}" "${SFS_ARCHIVES_DIR}" "${EXISTING_ARCHIVES_TARBALL}" "${EXISTING_ARCHIVES_MANIFEST}" "SFS adopt preexisting expanded archive collapse" || exit "${SFS_EXIT_PERM}"

mkdir -p "${TARGET_DIR}" || exit "${SFS_EXIT_PERM}"

RECENT_COMMITS="$(git log -n "${MAX_COMMITS}" --date=short --pretty=format:'- %h %ad %s' 2>/dev/null || true)"
TOP_CHANGED="$(top_changed_paths "${MAX_COMMITS}" || true)"
VERIFY_COMMANDS="$(suggest_verify_commands)"

{
  echo "SFS adopt source summary"
  echo "generated_at: ${NOW}"
  echo "root: ${ROOT}"
  echo "branch: ${BRANCH:--}"
  echo "head: ${HEAD_SHA:--}"
  echo "first_commit: ${FIRST_COMMIT:--}"
  echo "commit_count: ${COMMIT_COUNT}"
  echo "tracked_files: ${TRACKED_COUNT}"
  echo "docs_signals: ${DOC_COUNT}"
  echo "test_signals: ${TEST_COUNT}"
  echo "stack: ${STACK_SIGNALS}"
  echo "sfs_sprint_count_before_adopt: ${SFS_SPRINT_COUNT}"
  echo "preserved_current_sprint: ${CURRENT_SPRINT:-}"
  echo "preserved_current_sprint_applied: ${PRESERVE_CURRENT_SPRINT}"
  echo "archived_existing_sprint_count: ${EXISTING_SPRINT_ARCHIVE_COUNT}"
  echo "collapsed_existing_archive_count: ${EXISTING_ARCHIVE_COLLAPSE_COUNT}"
  echo "submodule_count: ${SUBMODULE_COUNT}"
  if [[ "${EXISTING_SPRINT_ARCHIVE_COUNT}" -gt 0 ]]; then
    echo
    echo "archived_existing_sprints:"
    printf '%s\n' "${EXISTING_SPRINT_IDS}" | sed "s#^#- ${SFS_SPRINTS_DIR}/#"
    echo "cold_archive: ${EXISTING_SPRINTS_TARBALL}"
    echo "manifest: ${EXISTING_SPRINTS_MANIFEST}"
  fi
  if [[ "${EXISTING_ARCHIVE_COLLAPSE_COUNT}" -gt 0 ]]; then
    echo
    echo "collapsed_existing_archives:"
    printf '%s\n' "${EXISTING_ARCHIVE_IDS}" | sed "s#^#- ${SFS_ARCHIVES_DIR}/#"
    echo "cold_archive: ${EXISTING_ARCHIVES_TARBALL}"
    echo "manifest: ${EXISTING_ARCHIVES_MANIFEST}"
  fi
  if [[ -n "${SUBMODULE_STATUS}" ]]; then
    echo
    echo "submodules:"
    printf '%s\n' "${SUBMODULE_STATUS}"
  fi
  echo
  echo "top_changed_paths:"
  printf '%s\n' "${TOP_CHANGED:-  - none}"
  echo
  echo "recent_commits:"
  printf '%s\n' "${RECENT_COMMITS:-  - none}"
} > "${ARCHIVE_DIR}/source-summary.txt" || exit "${SFS_EXIT_PERM}"

cat > "${REPORT_PATH}" <<EOF
---
phase: report
status: legacy-baseline
sprint_id: "${SPRINT_ID}"
goal: "Adopt existing legacy project into SFS"
created_at: "${NOW}"
last_touched_at: "${NOW}"
closed_at: ""
source: "git/code/docs scan"
confidence: "mixed"
---

# Report — Legacy Baseline Intake

> This report is the first SFS reading entrance for a project that already had
> history before SFS. It intentionally does **not** recreate every old document.
> The rule is: keep what must remain visible, archive the rest.

## §1. Executive Summary

- **Goal**: adopt this legacy project into SFS without adding document sprawl.
- **Outcome**: baseline created from git/code/docs signals.
- **Final verdict**: not-reviewed.
- **One-line result**: SFS can now start from \`${SPRINT_ID}\` with report-first context instead of scattered historical documents.

## §2. Evidence-Backed Facts

- **Repository root**: \`${ROOT}\`
- **Current branch / head**: \`${BRANCH:--}\` / \`${HEAD_SHA:--}\`
- **Commit history**: ${COMMIT_COUNT} commits; first observed commit \`${FIRST_COMMIT:--}\`
- **Tracked files**: ${TRACKED_COUNT}
- **Documentation signals**: ${DOC_COUNT}
- **Test signals**: ${TEST_COUNT}
- **Stack signals**: ${STACK_SIGNALS}
- **Submodule/subrepo signals**: ${SUBMODULE_COUNT}
- **Existing SFS sprint folders before adopt**: ${SFS_SPRINT_COUNT}
- **Preserved current sprint during re-adopt**: ${CURRENT_SPRINT:-none}
- **Archived existing SFS sprint folders during adopt**: ${EXISTING_SPRINT_ARCHIVE_COUNT}
- **Collapsed pre-existing expanded archive folders**: ${EXISTING_ARCHIVE_COLLAPSE_COUNT}

## §3. High-Change Areas

The last ${MAX_COMMITS} commits point to these recurring paths:

\`\`\`text
${TOP_CHANGED:-  - none}
\`\`\`

## §4. Reconstructed Work History

Recent git commits:

\`\`\`text
${RECENT_COMMITS:-  - none}
\`\`\`

## §5. Verification Starting Points

Suggested checks to confirm the current baseline:

\`\`\`text
${VERIFY_COMMANDS}
\`\`\`

## §6. SFS Handoff

- **Keep visible**: this \`report.md\` and \`retro.md\`.
- **Archive evidence**: \`${ARCHIVE_DIR}/source-summary.txt\`.
- **Cold archive policy**: old sprint/archive trees are stored as tarballs plus short manifests, not expanded as a second visible document tree.
- **Archived old sprint folders**: ${EXISTING_SPRINT_ARCHIVE_COUNT} in \`${EXISTING_SPRINTS_TARBALL}\`.
- **Collapsed old archive folders**: ${EXISTING_ARCHIVE_COLLAPSE_COUNT} in \`${EXISTING_ARCHIVES_TARBALL}\`.
- **Next sprint candidates**:
  - turn the highest-change area into the first implementation sprint.
  - run the suggested verification commands and record pass/fail in review.
  - use \`/sfs tidy --apply\` later only for completed SFS sprint workbench cleanup.

## §7. Open Questions

- Which high-change area is the product-critical domain?
- Which command is the authoritative baseline verification command?
- Are docs/submodules authoritative references or historical residue?
EOF

cat > "${RETRO_PATH}" <<EOF
---
phase: retro
gate_id: G5
sprint_id: "${SPRINT_ID}"
goal: "Adopt existing legacy project into SFS"
created_at: "${NOW}"
last_touched_at: "${NOW}"
closed_at: ""
---

# Retro — Legacy Baseline Intake

## §1. KPT

### Keep

- Preserve raw history as evidence, but make \`report.md\` the visible entry point.

### Problem

- Legacy projects often have too many scattered documents or no sprint documents at all.
- Reading every old note before work creates more cost than value.

### Try

- Start the next sprint from the highest-value domain in \`report.md\`, not from a full archaeology pass.

## §2. PDCA Learning

- **Plan**: adoption must create a small baseline, not a second documentation system.
- **Do**: git/code/docs signals are enough for first-pass handoff.
- **Check**: verification commands still need a human/AI runtime to run and record evidence.
- **Act**: next sprint should validate the baseline and choose one implementation slice.

## §3. Artifact Map

- \`report.md\` — durable baseline entry.
- \`retro.md\` — why the baseline is intentionally compact.
- \`${ARCHIVE_DIR}/source-summary.txt\` — archived scan evidence.
- \`${EXISTING_SPRINTS_TARBALL}\` — cold archive of pre-existing visible sprint folders, when any existed.
- \`${EXISTING_ARCHIVES_TARBALL}\` — cold archive of pre-existing expanded archive folders, when any existed.
EOF

printf '%s\n' "${SPRINT_ID}" > "${SFS_CURRENT_SPRINT_FILE}" || exit "${SFS_EXIT_PERM}"

_esc_sprint="$(json_escape "${SPRINT_ID}")"
_esc_report="$(json_escape "${REPORT_PATH}")"
_esc_retro="$(json_escape "${RETRO_PATH}")"
_esc_archive="$(json_escape "${ARCHIVE_DIR}/source-summary.txt")"
append_event "legacy_adopt" "{\"sprint_id\":\"${_esc_sprint}\",\"report\":\"${_esc_report}\",\"retro\":\"${_esc_retro}\",\"archive\":\"${_esc_archive}\",\"commits\":${COMMIT_COUNT},\"tracked_files\":${TRACKED_COUNT},\"docs_signals\":${DOC_COUNT},\"test_signals\":${TEST_COUNT},\"submodules\":${SUBMODULE_COUNT},\"archived_existing_sprints\":${EXISTING_SPRINT_ARCHIVE_COUNT},\"collapsed_existing_archives\":${EXISTING_ARCHIVE_COLLAPSE_COUNT}}"

echo "adopted: ${SPRINT_ID}"
echo "  report: ${REPORT_PATH}"
echo "  retro: ${RETRO_PATH}"
echo "  archive: ${ARCHIVE_DIR}/source-summary.txt"
if [[ "${PRESERVE_CURRENT_SPRINT}" -eq 1 ]]; then
  echo "  preserved_current_sprint: ${CURRENT_SPRINT}"
fi
echo "  archived_existing_sprints: ${EXISTING_SPRINT_ARCHIVE_COUNT}"
if [[ "${EXISTING_SPRINT_ARCHIVE_COUNT}" -gt 0 ]]; then
  echo "  existing_sprints_archive: ${EXISTING_SPRINTS_TARBALL}"
fi
echo "  collapsed_existing_archives: ${EXISTING_ARCHIVE_COLLAPSE_COUNT}"
if [[ "${EXISTING_ARCHIVE_COLLAPSE_COUNT}" -gt 0 ]]; then
  echo "  existing_archives_archive: ${EXISTING_ARCHIVES_TARBALL}"
fi
echo "  visible_policy: report.md + retro.md only"
echo "  next: run baseline verification, then start the first real SFS sprint"

exit "${SFS_EXIT_OK}"
