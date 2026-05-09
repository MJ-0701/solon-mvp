#!/usr/bin/env bash
# .sfs-local/scripts/sfs-adopt.sh
#
# Solon SFS — `/sfs adopt [<brief>] [--apply]`.
# Creates one shared adoption summary for projects that already have code and
# git history. Raw scan evidence and cold archives stay private under .sfs-local.

set -euo pipefail

SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

: "${SFS_EXIT_BADCLI:=7}"

usage_adopt() {
  cat <<'EOF'
Usage:
  /sfs adopt [<brief>] [--id <sprint-id>] [--apply] [--force] [--max-commits <N>]

Adopt an existing legacy project into SFS without creating document sprawl.
  - Default is dry-run; it prints the baseline sprint and evidence sources.
  - Optional <brief> is a single-line user note, for example:
      /sfs adopt "docs cleanup and current-state handoff"
  - --apply creates docs/solon/<english-workspace>/<yyyyMMdd>/handoff.md as the shared entry;
    for adopt, <workspace> defaults to the adopt id.
  - Existing visible sprint folders and expanded archive folders are collapsed
    into cold .tar.gz archives with short manifests.
  - Raw scan evidence is preserved in .sfs-local/archives/adopt/<id>/...
  - The summary separates evidence-backed facts from inferred next sprint ideas.
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
    | grep -Ev '^(\.sfs-local/|\.claude/|\.agents/|\.gemini/|docs/archive/|docs/\.pdca-snapshots/|memory/)' \
    | awk -F/ '{ if (NF >= 2) print $1"/"$2; else print $1 }' \
    | sort | uniq -c | sort -nr | head -12 \
    | sed 's/^/  - /'
}

recent_product_commits() {
  local max_commits="$1"
  git log -n "${max_commits}" --date=short --pretty=format:'- %h %ad %s' 2>/dev/null \
    | grep -Ev 'chore\(sfs\)|docs\(sfs\)|close sprint|update runtime|adopt baseline' \
    | head -18
}

project_identity_excerpt() {
  local emitted=0
  if [[ -f SFS.md ]]; then
    awk '
      /^## 프로젝트 개요/ { in_section=1; next }
      in_section && /^## / { exit }
      in_section && NF { print; count++; if (count >= 10) exit }
    ' SFS.md
    emitted=1
  fi
  if [[ -f README.md ]]; then
    if [[ "${emitted}" -eq 1 ]]; then
      printf '\n'
    fi
    awk '
      NF && $0 !~ /^!\[/ {
        print
        count++
        if (count >= 10) exit
      }
    ' README.md
  fi
}

component_map() {
  git ls-files 2>/dev/null \
    | grep -Ev '^(\.gitignore$|\.sfs-local/|\.claude/|\.agents/|\.gemini/|node_modules/|build/|dist/|out/|target/|vendor/)' \
    | awk -F/ '
      NF >= 2 { key=$1 }
      NF < 2 { key="root" }
      { c[key]++ }
      END {
        for (k in c) printf "%6d %s\n", c[k], k
      }
    ' \
    | sort -nr | head -12 | sed 's/^/  - /'
}

doc_topology() {
  local found=0
  if git ls-files --stage 2>/dev/null | awk '$1 == "160000" {print $4}' | grep -qx 'docs'; then
    echo "- docs/: git submodule; read docs at its pinned commit when historical product docs matter."
    found=1
  elif [[ -e docs/.git ]]; then
    echo "- docs/: nested git repository/subrepo; treat docs history as separate from main repo history."
    found=1
  elif [[ -d docs ]]; then
    echo "- docs/: in-repo documentation directory."
    found=1
  fi
  [[ -f README.md ]] && { echo "- README.md: current project/product entry."; found=1; }
  [[ -f HANDOFF.md ]] && { echo "- HANDOFF.md: legacy handoff signal; verify freshness before treating as current."; found=1; }
  [[ -f SFS.md ]] && { echo "- SFS.md: Solon operating identity and routed entry."; found=1; }
  [[ "${found}" -eq 1 ]] || echo "- no first-class docs detected."
}

submodule_summary() {
  local status nested
  status="$(git submodule status --recursive 2>/dev/null || true)"
  nested="$(find . -mindepth 2 -maxdepth 3 \
    \( -path './.git' -o -path "./${SFS_LOCAL_DIR}" -o -path './node_modules' -o -path './frontend/node_modules' -o -path './build' -o -path './dist' \) -prune \
    -o -name .git -print 2>/dev/null | sed 's#^\./##; s#/\.git$##' | sort || true)"
  if [[ -z "${status}" && -z "${nested}" ]]; then
    echo "- none"
  else
    if [[ -n "${status}" ]]; then
      printf '%s\n' "${status}" | sed 's/^/- git-submodule: /'
    fi
    if [[ -n "${nested}" ]]; then
      printf '%s\n' "${nested}" | sed 's/^/- nested-repo: /'
    fi
  fi
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

tmp_artifact_count_for_adopt() {
  [[ -d "${SFS_LOCAL_DIR}/tmp" ]] || { printf '0\n'; return "${SFS_EXIT_OK}"; }
  find "${SFS_LOCAL_DIR}/tmp" -type f 2>/dev/null | wc -l | tr -d '[:space:]'
}

event_ledger_line_count_for_adopt() {
  [[ -f "${SFS_EVENTS_FILE}" ]] || { printf '0\n'; return "${SFS_EXIT_OK}"; }
  wc -l < "${SFS_EVENTS_FILE}" 2>/dev/null | tr -d '[:space:]'
}

is_adopt_runtime_keep_file() {
  case "${1:-}" in
    "${SFS_LOCAL_DIR}/config.yaml"|"${SFS_LOCAL_DIR}/VERSION"|"${SFS_LOCAL_DIR}/model-profiles.yaml"|"${SFS_LOCAL_DIR}/divisions.yaml")
      return "${SFS_EXIT_OK}"
      ;;
    *)
      return 1
      ;;
  esac
}

residue_files_for_adopt() {
  [[ -d "${SFS_LOCAL_DIR}" ]] || return "${SFS_EXIT_OK}"
  find "${SFS_LOCAL_DIR}" -type f 2>/dev/null | sort \
    | while IFS= read -r file; do
        case "${file}" in
          "${SFS_ARCHIVES_DIR}/"*|"${SFS_EVENTS_FILE}"|"${SFS_CURRENT_SPRINT_FILE}"|"${SFS_LOCAL_DIR}/tmp/"*)
            continue
            ;;
        esac
        if is_adopt_runtime_keep_file "${file}"; then
          continue
        fi
        printf '%s\n' "${file}"
      done
}

residue_file_count_for_adopt() {
  residue_files_for_adopt | sed '/^[[:space:]]*$/d' | wc -l | tr -d '[:space:]'
}

empty_surface_dirs_for_adopt() {
  [[ -d "${SFS_LOCAL_DIR}" ]] || return "${SFS_EXIT_OK}"
  local root
  for root in \
    "${SFS_LOCAL_DIR}/cache" \
    "${SFS_LOCAL_DIR}/tmp" \
    "${SFS_LOCAL_DIR}/queue" \
    "${SFS_SPRINTS_DIR}" \
    "${SFS_DECISIONS_DIR}"; do
    [[ -d "${root}" ]] || continue
    find "${root}" -depth -type d -empty -print 2>/dev/null
  done
}

cleanup_empty_surface_dirs_for_adopt() {
  local count=0 removed dir
  while :; do
    removed=0
    while IFS= read -r dir; do
      [[ -n "${dir}" && -d "${dir}" ]] || continue
      rmdir "${dir}" 2>/dev/null || true
      if [[ ! -d "${dir}" ]]; then
        count=$((count + 1))
        removed=$((removed + 1))
      fi
    done < <(empty_surface_dirs_for_adopt)
    [[ "${removed}" -gt 0 ]] || break
  done
  printf '%s\n' "${count}"
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

collapse_tmp_to_cold_archive() {
  local archive_path="${1:?archive path required}" manifest_path="${2:?manifest path required}"
  local tmp_root="${SFS_LOCAL_DIR}/tmp" count staging file rel
  [[ -d "${tmp_root}" ]] || return "${SFS_EXIT_OK}"
  count="$(tmp_artifact_count_for_adopt)"
  [[ "${count}" -gt 0 ]] || return "${SFS_EXIT_OK}"

  mkdir -p "$(dirname "${archive_path}")" || return "${SFS_EXIT_PERM}"
  staging="$(mktemp -d "$(dirname "${archive_path}")/.tmp-stage.XXXXXX")" || return "${SFS_EXIT_PERM}"
  while IFS= read -r file; do
    [[ -f "${file}" ]] || continue
    rel="${file#${SFS_LOCAL_DIR}/}"
    mkdir -p "${staging}/$(dirname "${rel}")" || return "${SFS_EXIT_PERM}"
    cp "${file}" "${staging}/${rel}" || return "${SFS_EXIT_PERM}"
  done < <(find "${tmp_root}" -type f 2>/dev/null | sort)

  {
    echo "SFS adopt preexisting tmp artifact archive"
    echo "generated_at: ${NOW}"
    echo "source_root: ${tmp_root}"
    echo "archive: ${archive_path}"
    echo "count: ${count}"
    echo
    echo "policy:"
    echo "- adopt resets the active workbench; old tmp prompt/run scratch is cold history"
    echo "- use this archive only for archaeology, dispute resolution, or deep recovery"
    echo
    echo "items:"
    find "${staging}" -type f 2>/dev/null | sort | while IFS= read -r staged; do
      printf -- "- %s\n" "${staged#${staging}/}"
    done
  } > "${manifest_path}" || return "${SFS_EXIT_PERM}"

  tar -czf "${archive_path}" -C "${staging}" . || return "${SFS_EXIT_PERM}"
  rm -rf "${staging}" || return "${SFS_EXIT_PERM}"
  while IFS= read -r file; do
    [[ -f "${file}" ]] || continue
    rm -f "${file}" || return "${SFS_EXIT_PERM}"
  done < <(find "${tmp_root}" -type f 2>/dev/null | sort)
  find "${tmp_root}" -depth -type d -empty -exec rmdir {} \; 2>/dev/null || true
  return "${SFS_EXIT_OK}"
}

collapse_residue_files_to_cold_archive() {
  local archive_path="${1:?archive path required}" manifest_path="${2:?manifest path required}"
  local files="${3:-}" count staging file rel
  count="$(nonempty_line_count "${files}")"
  [[ "${count}" -gt 0 ]] || return "${SFS_EXIT_OK}"

  mkdir -p "$(dirname "${archive_path}")" || return "${SFS_EXIT_PERM}"
  staging="$(mktemp -d "$(dirname "${archive_path}")/.residue-stage.XXXXXX")" || return "${SFS_EXIT_PERM}"
  while IFS= read -r file; do
    [[ -n "${file}" && -f "${file}" ]] || continue
    rel="${file#${SFS_LOCAL_DIR}/}"
    mkdir -p "${staging}/${SFS_LOCAL_DIR}/$(dirname "${rel}")" || return "${SFS_EXIT_PERM}"
    cp "${file}" "${staging}/${SFS_LOCAL_DIR}/${rel}" || return "${SFS_EXIT_PERM}"
  done <<< "${files}"

  {
    echo "SFS adopt nonessential residue archive"
    echo "generated_at: ${NOW}"
    echo "source_root: ${SFS_LOCAL_DIR}"
    echo "archive: ${archive_path}"
    echo "count: ${count}"
    echo
    echo "policy:"
    echo "- adopt keeps only files with a clear one-line runtime reason visible"
    echo "- archived files remain recoverable cold history, not active workbench surface"
    echo
    echo "retained_runtime_files:"
    echo "- ${SFS_LOCAL_DIR}/config.yaml — workspace SFS runtime config"
    echo "- ${SFS_LOCAL_DIR}/VERSION — installed SFS version/upgrade state"
    echo "- ${SFS_LOCAL_DIR}/model-profiles.yaml — project model-routing config"
    echo "- ${SFS_LOCAL_DIR}/divisions.yaml — project division activation config"
    echo
    echo "items:"
    find "${staging}" -type f 2>/dev/null | sort | while IFS= read -r staged; do
      printf -- "- %s\n" "${staged#${staging}/}"
    done
  } > "${manifest_path}" || return "${SFS_EXIT_PERM}"

  tar -czf "${archive_path}" -C "${staging}" . || return "${SFS_EXIT_PERM}"
  rm -rf "${staging}" || return "${SFS_EXIT_PERM}"
  while IFS= read -r file; do
    [[ -n "${file}" && -f "${file}" ]] || continue
    rm -f "${file}" || return "${SFS_EXIT_PERM}"
  done <<< "${files}"
  find "${SFS_LOCAL_DIR}" -depth -type d -empty ! -path "${SFS_ARCHIVES_DIR}" ! -path "${SFS_ARCHIVES_DIR}/*" -exec rmdir {} \; 2>/dev/null || true
  return "${SFS_EXIT_OK}"
}

archive_and_reset_event_ledger_for_adopt() {
  local backup_path="${1:?backup path required}" line_count
  [[ -f "${SFS_EVENTS_FILE}" ]] || { printf '0\n'; return "${SFS_EXIT_OK}"; }
  line_count="$(event_ledger_line_count_for_adopt)"
  [[ "${line_count}" -gt 0 ]] || { rm -f "${SFS_EVENTS_FILE}" 2>/dev/null || true; printf '0\n'; return "${SFS_EXIT_OK}"; }
  mkdir -p "$(dirname "${backup_path}")" || return "${SFS_EXIT_PERM}"
  cp "${SFS_EVENTS_FILE}" "${backup_path}" || return "${SFS_EXIT_PERM}"
  rm -f "${SFS_EVENTS_FILE}" || return "${SFS_EXIT_PERM}"
  printf '%s\n' "${line_count}"
  return "${SFS_EXIT_OK}"
}

archive_legacy_shared_doc_for_adopt() {
  local legacy_path="${1:?legacy path required}" archive_path="${2:?archive path required}" manifest_path="${3:?manifest path required}"
  [[ -f "${legacy_path}" ]] || { printf '0\n'; return "${SFS_EXIT_OK}"; }
  mkdir -p "$(dirname "${archive_path}")" || return "${SFS_EXIT_PERM}"
  cp "${legacy_path}" "${archive_path}" || return "${SFS_EXIT_PERM}"
  {
    echo "SFS adopt legacy shared doc archive"
    echo "generated_at: ${NOW}"
    echo "legacy_path: ${legacy_path}"
    echo "archive: ${archive_path}"
    echo
    echo "reason:"
    echo "- previous runtimes wrote adopt handoff as a flat docs/solon summary"
    echo "- current policy keeps handoff/history docs under docs/solon/<english-workspace>/<yyyyMMdd>/"
  } > "${manifest_path}" || return "${SFS_EXIT_PERM}"
  rm -f "${legacy_path}" || return "${SFS_EXIT_PERM}"
  rmdir "$(dirname "${legacy_path}")" 2>/dev/null || true
  printf '1\n'
  return "${SFS_EXIT_OK}"
}

SPRINT_ID="legacy-baseline"
APPLY=0
FORCE=0
MAX_COMMITS=80
BRIEF_PARTS=()
ADOPT_BRIEF=""

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
      while [[ $# -gt 0 ]]; do
        BRIEF_PARTS+=("$1")
        shift
      done
      ;;
    -*)
      echo "unknown flag: $1" >&2
      exit "${SFS_EXIT_BADCLI}"
      ;;
    *)
      BRIEF_PARTS+=("$1")
      shift
      ;;
  esac
done

if [[ ${#BRIEF_PARTS[@]} -gt 0 ]]; then
  ADOPT_BRIEF="${BRIEF_PARTS[*]}"
fi

case "${ADOPT_BRIEF}" in
  *$'\n'*|*$'\r'*)
    echo "invalid brief: newline not allowed" >&2
    exit "${SFS_EXIT_BADCLI}"
    ;;
esac

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
NESTED_REPO_COUNT="$(find . -mindepth 2 -maxdepth 3 \
  \( -path './.git' -o -path "./${SFS_LOCAL_DIR}" -o -path './node_modules' -o -path './frontend/node_modules' -o -path './build' -o -path './dist' \) -prune \
  -o -name .git -print 2>/dev/null | wc -l | tr -d '[:space:]')"
SUBREPO_SIGNAL_COUNT=$((SUBMODULE_COUNT + NESTED_REPO_COUNT))
SFS_SPRINT_COUNT=0
if [[ -d "${SFS_SPRINTS_DIR}" ]]; then
  SFS_SPRINT_COUNT="$(find "${SFS_SPRINTS_DIR}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d '[:space:]')"
fi

TARGET_DIR="${SFS_SPRINTS_DIR}/${SPRINT_ID}"
ARCHIVE_DIR="${SFS_ARCHIVES_DIR}/adopt/${SPRINT_ID}/${NOW//:/-}"
ARCHIVE_DIR="${ARCHIVE_DIR//+/-}"
SHARED_DOC_ROOT="${SFS_SHARED_DOC_DIR:-${SFS_SHARED_DOCS_DIR:-docs/solon}}"
ADOPT_WORKSPACE="$(sfs_path_segment_from_text "${SPRINT_ID}" "legacy-baseline")"
ADOPT_DATE_DIR="$(sfs_date_dir_from_ts "${NOW}")"
SHARED_DOC_DIR="${SHARED_DOC_ROOT}/${ADOPT_WORKSPACE}/${ADOPT_DATE_DIR}"
SHARED_DOC_PATH="${SHARED_DOC_DIR}/handoff.md"
LEGACY_SHARED_DOC_PATH="docs/solon/${SPRINT_ID}-adoption-summary.md"
LEGACY_SHARED_DOC_ARCHIVE="${ARCHIVE_DIR}/preexisting-shared-adoption-summary.md"
LEGACY_SHARED_DOC_MANIFEST="${ARCHIVE_DIR}/preexisting-shared-adoption-summary.manifest.txt"
CURRENT_SPRINT=""
if [[ -f "${SFS_CURRENT_SPRINT_FILE}" ]]; then
  CURRENT_SPRINT="$(sed -n '1p' "${SFS_CURRENT_SPRINT_FILE}" 2>/dev/null | tr -d '[:space:]' || true)"
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
TMP_ARTIFACT_COUNT="$(tmp_artifact_count_for_adopt)"
TMP_ARTIFACTS_TARBALL="${ARCHIVE_DIR}/preexisting-tmp.tar.gz"
TMP_ARTIFACTS_MANIFEST="${ARCHIVE_DIR}/preexisting-tmp.manifest.txt"
EVENT_LEDGER_LINE_COUNT="$(event_ledger_line_count_for_adopt)"
EVENT_LEDGER_BACKUP="${ARCHIVE_DIR}/preexisting-events.jsonl"
RESIDUE_FILES="$(residue_files_for_adopt)"
RESIDUE_FILE_COUNT="$(nonempty_line_count "${RESIDUE_FILES}")"
RESIDUE_TARBALL="${ARCHIVE_DIR}/preexisting-residue.tar.gz"
RESIDUE_MANIFEST="${ARCHIVE_DIR}/preexisting-residue.manifest.txt"
EMPTY_SURFACE_DIRS="$(empty_surface_dirs_for_adopt)"
EMPTY_SURFACE_DIR_COUNT="$(nonempty_line_count "${EMPTY_SURFACE_DIRS}")"
LEGACY_SHARED_DOC_COUNT=0
if [[ -f "${LEGACY_SHARED_DOC_PATH}" && "${LEGACY_SHARED_DOC_PATH}" != "${SHARED_DOC_PATH}" ]]; then
  LEGACY_SHARED_DOC_COUNT=1
fi

if [[ "${APPLY}" -eq 0 ]]; then
  echo "adopt dry-run: ${SPRINT_ID}"
  if [[ -n "${ADOPT_BRIEF}" ]]; then
    echo "  brief: ${ADOPT_BRIEF}"
  fi
  echo "  root: ${ROOT}"
  echo "  branch: ${BRANCH:--} @ ${HEAD_SHA:--}"
  echo "  commits: ${COMMIT_COUNT} (first ${FIRST_COMMIT:--}, scan last ${MAX_COMMITS})"
  echo "  tracked_files: ${TRACKED_COUNT}"
  echo "  docs_signals: ${DOC_COUNT}"
  echo "  test_signals: ${TEST_COUNT}"
  echo "  stack: ${STACK_SIGNALS}"
  echo "  submodules/subrepos: ${SUBREPO_SIGNAL_COUNT}"
  if [[ -n "${CURRENT_SPRINT}" ]]; then
    echo "  active_sprint_before_adopt: ${CURRENT_SPRINT} (will archive/reset; first real sprint starts after adopt)"
    echo "  would_remove_active_sprint_pointer: ${SFS_CURRENT_SPRINT_FILE}"
  fi
  if [[ -d "${TARGET_DIR}" && "${FORCE}" -ne 1 ]]; then
    echo "  target: ${TARGET_DIR} (exists; --apply would require --force)"
  else
    echo "  target: ${TARGET_DIR}"
  fi
  echo "  would_create:"
  echo "    - ${SHARED_DOC_PATH}"
  echo "  would_archive:"
  echo "    - ${ARCHIVE_DIR}/source-summary.txt"
  print_cold_archive_plan "would_archive_existing_sprints" "${EXISTING_SPRINT_IDS}" "${SFS_SPRINTS_DIR}" "${EXISTING_SPRINTS_TARBALL}" "${EXISTING_SPRINTS_MANIFEST}"
  print_cold_archive_plan "would_collapse_existing_archives" "${EXISTING_ARCHIVE_IDS}" "${SFS_ARCHIVES_DIR}" "${EXISTING_ARCHIVES_TARBALL}" "${EXISTING_ARCHIVES_MANIFEST}"
  echo "  would_archive_tmp_artifacts: ${TMP_ARTIFACT_COUNT}"
  if [[ "${TMP_ARTIFACT_COUNT}" -gt 0 ]]; then
    echo "    cold_archive: ${TMP_ARTIFACTS_TARBALL}"
    echo "    manifest: ${TMP_ARTIFACTS_MANIFEST}"
    echo "    - ${SFS_LOCAL_DIR}/tmp"
  fi
  echo "  would_archive_event_ledger_lines: ${EVENT_LEDGER_LINE_COUNT}"
  if [[ "${EVENT_LEDGER_LINE_COUNT}" -gt 0 ]]; then
    echo "    backup: ${EVENT_LEDGER_BACKUP}"
    echo "    reset: ${SFS_EVENTS_FILE}"
  fi
  echo "  would_archive_legacy_flat_shared_doc: ${LEGACY_SHARED_DOC_COUNT}"
  if [[ "${LEGACY_SHARED_DOC_COUNT}" -gt 0 ]]; then
    echo "    archive: ${LEGACY_SHARED_DOC_ARCHIVE}"
    echo "    manifest: ${LEGACY_SHARED_DOC_MANIFEST}"
    echo "    - ${LEGACY_SHARED_DOC_PATH}"
  fi
  echo "  would_archive_nonessential_residue: ${RESIDUE_FILE_COUNT}"
  if [[ "${RESIDUE_FILE_COUNT}" -gt 0 ]]; then
    echo "    cold_archive: ${RESIDUE_TARBALL}"
    echo "    manifest: ${RESIDUE_MANIFEST}"
    printf '%s\n' "${RESIDUE_FILES}" | while IFS= read -r item; do
      [[ -n "${item}" ]] || continue
      echo "    - ${item}"
    done
  fi
  echo "  would_remove_empty_surface_dirs: ${EMPTY_SURFACE_DIR_COUNT}"
  if [[ "${EMPTY_SURFACE_DIR_COUNT}" -gt 0 ]]; then
    printf '%s\n' "${EMPTY_SURFACE_DIRS}" | while IFS= read -r item; do
      [[ -n "${item}" ]] || continue
      echo "    - ${item}"
    done
  fi
  echo "  would_keep_runtime_files:"
  echo "    - ${SFS_LOCAL_DIR}/config.yaml — workspace SFS runtime config"
  echo "    - ${SFS_LOCAL_DIR}/VERSION — installed SFS version/upgrade state"
  echo "    - ${SFS_LOCAL_DIR}/model-profiles.yaml — project model-routing config"
  echo "    - ${SFS_LOCAL_DIR}/divisions.yaml — project division activation config"
  if [[ -d "${TARGET_DIR}" && "${FORCE}" -eq 1 ]]; then
    echo "  would_archive_existing_target: 1"
    echo "    cold_archive: ${PREEXISTING_TARGET_TARBALL}"
    echo "    manifest: ${PREEXISTING_TARGET_MANIFEST}"
    echo "    - ${TARGET_DIR}"
  fi
  echo "  visible_policy: shared docs/solon/<english-workspace>/<yyyyMMdd>/handoff.md only; .sfs-local stays private"
  exit "${SFS_EXIT_OK}"
fi

if [[ -d "${TARGET_DIR}" && "${FORCE}" -ne 1 ]]; then
  echo "sprint ${SPRINT_ID} already exists, use --force or choose --id" >&2
  exit "${SFS_EXIT_NO_INIT}"
fi
if [[ -f "${SHARED_DOC_PATH}" && "${FORCE}" -ne 1 ]]; then
  echo "shared adoption summary already exists: ${SHARED_DOC_PATH} (use --force or choose --id)" >&2
  exit "${SFS_EXIT_NO_INIT}"
fi

mkdir -p "${ARCHIVE_DIR}" || exit "${SFS_EXIT_PERM}"

if [[ -d "${TARGET_DIR}" && "${FORCE}" -eq 1 ]]; then
  collapse_dirs_to_cold_archive "${SPRINT_ID}" "${SFS_SPRINTS_DIR}" "${PREEXISTING_TARGET_TARBALL}" "${PREEXISTING_TARGET_MANIFEST}" "SFS adopt preexisting target sprint archive" || exit "${SFS_EXIT_PERM}"
fi

collapse_dirs_to_cold_archive "${EXISTING_SPRINT_IDS}" "${SFS_SPRINTS_DIR}" "${EXISTING_SPRINTS_TARBALL}" "${EXISTING_SPRINTS_MANIFEST}" "SFS adopt preexisting sprint archive" || exit "${SFS_EXIT_PERM}"
collapse_dirs_to_cold_archive "${EXISTING_ARCHIVE_IDS}" "${SFS_ARCHIVES_DIR}" "${EXISTING_ARCHIVES_TARBALL}" "${EXISTING_ARCHIVES_MANIFEST}" "SFS adopt preexisting expanded archive collapse" || exit "${SFS_EXIT_PERM}"
collapse_tmp_to_cold_archive "${TMP_ARTIFACTS_TARBALL}" "${TMP_ARTIFACTS_MANIFEST}" || exit "${SFS_EXIT_PERM}"
ACTIVE_SPRINT_POINTER_REMOVED=0
if [[ -f "${SFS_CURRENT_SPRINT_FILE}" ]]; then
  rm -f "${SFS_CURRENT_SPRINT_FILE}" || exit "${SFS_EXIT_PERM}"
  ACTIVE_SPRINT_POINTER_REMOVED=1
fi
EVENT_LEDGER_ARCHIVED_LINES="$(archive_and_reset_event_ledger_for_adopt "${EVENT_LEDGER_BACKUP}")" || exit "${SFS_EXIT_PERM}"
LEGACY_SHARED_DOC_ARCHIVED="$(archive_legacy_shared_doc_for_adopt "${LEGACY_SHARED_DOC_PATH}" "${LEGACY_SHARED_DOC_ARCHIVE}" "${LEGACY_SHARED_DOC_MANIFEST}")" || exit "${SFS_EXIT_PERM}"
collapse_residue_files_to_cold_archive "${RESIDUE_TARBALL}" "${RESIDUE_MANIFEST}" "${RESIDUE_FILES}" || exit "${SFS_EXIT_PERM}"
rmdir "${SFS_SPRINTS_DIR}" 2>/dev/null || true
EMPTY_SURFACE_DIRS_AFTER_RESIDUE="$(empty_surface_dirs_for_adopt)"
EMPTY_SURFACE_DIRS_REMOVED="$(cleanup_empty_surface_dirs_for_adopt "${EMPTY_SURFACE_DIRS_AFTER_RESIDUE}")" || exit "${SFS_EXIT_PERM}"
mkdir -p "${SHARED_DOC_DIR}" || exit "${SFS_EXIT_PERM}"

RECENT_COMMITS="$(git log -n "${MAX_COMMITS}" --date=short --pretty=format:'- %h %ad %s' 2>/dev/null || true)"
RECENT_PRODUCT_COMMITS="$(recent_product_commits "${MAX_COMMITS}" || true)"
TOP_CHANGED="$(top_changed_paths "${MAX_COMMITS}" || true)"
VERIFY_COMMANDS="$(suggest_verify_commands)"
PROJECT_IDENTITY="$(project_identity_excerpt || true)"
COMPONENT_MAP="$(component_map || true)"
DOC_TOPOLOGY="$(doc_topology || true)"
SUBMODULE_SUMMARY="$(submodule_summary || true)"
REPORT_GOAL="Adopt existing legacy project into SFS"
REPORT_SOURCE="git/code/docs scan"
if [[ -n "${ADOPT_BRIEF}" ]]; then
  REPORT_GOAL="${ADOPT_BRIEF}"
  REPORT_SOURCE="${REPORT_SOURCE} + user brief"
fi
REPORT_GOAL_YAML="$(json_escape "${REPORT_GOAL}")"
REPORT_SOURCE_YAML="$(json_escape "${REPORT_SOURCE}")"

{
  echo "SFS adopt source summary"
  echo "generated_at: ${NOW}"
  if [[ -n "${ADOPT_BRIEF}" ]]; then
    echo "adopt_brief: ${ADOPT_BRIEF}"
  fi
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
  echo "active_sprint_before_adopt: ${CURRENT_SPRINT:-}"
  echo "active_sprint_pointer_removed: ${ACTIVE_SPRINT_POINTER_REMOVED}"
  echo "preserved_current_sprint: "
  echo "preserved_current_sprint_applied: 0"
  echo "archived_existing_sprint_count: ${EXISTING_SPRINT_ARCHIVE_COUNT}"
  echo "collapsed_existing_archive_count: ${EXISTING_ARCHIVE_COLLAPSE_COUNT}"
  echo "archived_tmp_artifact_count: ${TMP_ARTIFACT_COUNT}"
  echo "archived_event_ledger_lines: ${EVENT_LEDGER_ARCHIVED_LINES}"
  echo "archived_legacy_flat_shared_doc: ${LEGACY_SHARED_DOC_ARCHIVED}"
  echo "archived_nonessential_residue_count: ${RESIDUE_FILE_COUNT}"
  echo "removed_empty_surface_dir_count: ${EMPTY_SURFACE_DIRS_REMOVED}"
  echo "submodule_count: ${SUBMODULE_COUNT}"
  echo "nested_repo_count: ${NESTED_REPO_COUNT}"
  echo
  echo "retained_runtime_files:"
  echo "- ${SFS_LOCAL_DIR}/config.yaml — workspace SFS runtime config"
  echo "- ${SFS_LOCAL_DIR}/VERSION — installed SFS version/upgrade state"
  echo "- ${SFS_LOCAL_DIR}/model-profiles.yaml — project model-routing config"
  echo "- ${SFS_LOCAL_DIR}/divisions.yaml — project division activation config"
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
  if [[ "${RESIDUE_FILE_COUNT}" -gt 0 ]]; then
    echo
    echo "archived_nonessential_residue:"
    printf '%s\n' "${RESIDUE_FILES}" | sed 's#^#- #'
    echo "cold_archive: ${RESIDUE_TARBALL}"
    echo "manifest: ${RESIDUE_MANIFEST}"
  fi
  if [[ "${EMPTY_SURFACE_DIRS_REMOVED}" -gt 0 ]]; then
    echo
    echo "removed_empty_surface_dirs:"
    printf '%s\n' "${EMPTY_SURFACE_DIRS_AFTER_RESIDUE}" | sed 's#^#- #'
  fi
  if [[ "${LEGACY_SHARED_DOC_ARCHIVED}" -gt 0 ]]; then
    echo
    echo "archived_legacy_flat_shared_doc:"
    echo "- ${LEGACY_SHARED_DOC_PATH}"
    echo "archive: ${LEGACY_SHARED_DOC_ARCHIVE}"
    echo "manifest: ${LEGACY_SHARED_DOC_MANIFEST}"
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

cat > "${SHARED_DOC_PATH}" <<EOF
---
title: "Solon Adoption Summary"
status: legacy-baseline
adopt_id: "${SPRINT_ID}"
goal: "${REPORT_GOAL_YAML}"
created_at: "${NOW}"
last_touched_at: "${NOW}"
source: "${REPORT_SOURCE_YAML}"
confidence: "mixed"
---

# Solon Adoption Summary — ${SPRINT_ID}

## §1. Project Snapshot

The project describes itself as:

\`\`\`text
${PROJECT_IDENTITY:-  - no README.md or SFS.md identity excerpt found}
\`\`\`

SFS did not infer product intent from archived notes. It created a compact
handoff from current project files, git history, and documentation topology.

User brief:

\`\`\`text
${ADOPT_BRIEF:-  - none}
\`\`\`

## §2. Operating Facts

- **Repository root**: \`${ROOT}\`
- **Current branch / head**: \`${BRANCH:--}\` / \`${HEAD_SHA:--}\`
- **Commit history**: ${COMMIT_COUNT} commits; first observed commit \`${FIRST_COMMIT:--}\`
- **Tracked files**: ${TRACKED_COUNT}
- **Documentation signals**: ${DOC_COUNT}
- **Test signals**: ${TEST_COUNT}
- **Stack signals**: ${STACK_SIGNALS}
- **Submodule/subrepo signals**: ${SUBREPO_SIGNAL_COUNT}
- **Existing SFS sprint folders before adopt**: ${SFS_SPRINT_COUNT}
- **Active sprint before adopt**: ${CURRENT_SPRINT:-none}
- **Active sprint pointer removed during adopt**: ${ACTIVE_SPRINT_POINTER_REMOVED}
- **Archived existing SFS sprint folders during adopt**: ${EXISTING_SPRINT_ARCHIVE_COUNT}
- **Collapsed pre-existing expanded archive folders**: ${EXISTING_ARCHIVE_COLLAPSE_COUNT}
- **Archived tmp scratch files during adopt**: ${TMP_ARTIFACT_COUNT}
- **Archived previous event ledger lines during adopt**: ${EVENT_LEDGER_ARCHIVED_LINES}
- **Archived nonessential \`.sfs-local\` residue during adopt**: ${RESIDUE_FILE_COUNT}
- **Removed empty workbench surface dirs during adopt**: ${EMPTY_SURFACE_DIRS_REMOVED}
- **Retained runtime files and one-line reasons**:
  - \`.sfs-local/config.yaml\` — workspace SFS runtime config.
  - \`.sfs-local/VERSION\` — installed SFS version/upgrade state.
  - \`.sfs-local/model-profiles.yaml\` — project model-routing config.
  - \`.sfs-local/divisions.yaml\` — project division activation config.

## §3. Component Map

Largest tracked project surfaces, excluding SFS/agent runtime state:

\`\`\`text
${COMPONENT_MAP:-  - none}
\`\`\`

Documentation topology:

\`\`\`text
${DOC_TOPOLOGY:-  - none}
\`\`\`

Submodules:

\`\`\`text
${SUBMODULE_SUMMARY:-  - none}
\`\`\`

If docs are a submodule, treat the main repo report as the product/runtime
handoff and read the docs submodule at its pinned commit only when docs history
is directly relevant.

## §4. Product Change Signals

The last ${MAX_COMMITS} commits point to these recurring product paths after
filtering SFS/archive/runtime noise:

\`\`\`text
${TOP_CHANGED:-  - none}
\`\`\`

Recent non-SFS commits:

\`\`\`text
${RECENT_PRODUCT_COMMITS:-  - none}
\`\`\`

## §5. Verification Starting Points

Suggested checks to confirm the current baseline:

\`\`\`text
${VERIFY_COMMANDS}
\`\`\`

## §6. SFS Handoff

- **Shared document**: \`${SHARED_DOC_PATH}\`.
- **Private evidence**: \`${ARCHIVE_DIR}/source-summary.txt\`.
- **Cold archive policy**: old sprint/archive trees are stored as tarballs plus short manifests, not expanded as a visible document tree.
- **Archived old sprint folders**: ${EXISTING_SPRINT_ARCHIVE_COUNT} in \`${EXISTING_SPRINTS_TARBALL}\`.
- **Collapsed old archive folders**: ${EXISTING_ARCHIVE_COLLAPSE_COUNT} in \`${EXISTING_ARCHIVES_TARBALL}\`.
- **Archived old tmp scratch**: ${TMP_ARTIFACT_COUNT} files in \`${TMP_ARTIFACTS_TARBALL}\`.
- **Archived old event ledger**: ${EVENT_LEDGER_ARCHIVED_LINES} lines in \`${EVENT_LEDGER_BACKUP}\`.
- **Archived legacy flat shared doc**: ${LEGACY_SHARED_DOC_ARCHIVED} file in \`${LEGACY_SHARED_DOC_ARCHIVE}\`.
- **Archived nonessential residue**: ${RESIDUE_FILE_COUNT} files in \`${RESIDUE_TARBALL}\`.
- **Removed empty workbench surface dirs**: ${EMPTY_SURFACE_DIRS_REMOVED}.
- **Event ledger after adopt**: none. \`adopt\` leaves no active log file; the
  shared summary and private source summary are the durable evidence.

## §7. Next Sprint Contract Seed

Before implementation, choose one:

- product area/component to change.
- acceptance criteria that prove the slice is done.
- verification command or manual smoke path.
- whether docs/submodule history is authoritative for this slice.

Do not start the next sprint by reading the cold archives. Use them only for
archaeology, dispute resolution, or deep recovery.
EOF

echo "adopted: ${SPRINT_ID}"
if [[ -n "${ADOPT_BRIEF}" ]]; then
  echo "  brief: ${ADOPT_BRIEF}"
fi
echo "  shared_doc: ${SHARED_DOC_PATH}"
echo "  private_archive: ${ARCHIVE_DIR}/source-summary.txt"
if [[ -n "${CURRENT_SPRINT}" ]]; then
  echo "  active_sprint_archived: ${CURRENT_SPRINT}"
fi
if [[ "${ACTIVE_SPRINT_POINTER_REMOVED}" -eq 1 ]]; then
  echo "  removed_active_sprint_pointer: ${SFS_CURRENT_SPRINT_FILE}"
fi
echo "  archived_existing_sprints: ${EXISTING_SPRINT_ARCHIVE_COUNT}"
if [[ "${EXISTING_SPRINT_ARCHIVE_COUNT}" -gt 0 ]]; then
  echo "  existing_sprints_archive: ${EXISTING_SPRINTS_TARBALL}"
fi
echo "  collapsed_existing_archives: ${EXISTING_ARCHIVE_COLLAPSE_COUNT}"
if [[ "${EXISTING_ARCHIVE_COLLAPSE_COUNT}" -gt 0 ]]; then
  echo "  existing_archives_archive: ${EXISTING_ARCHIVES_TARBALL}"
fi
echo "  archived_tmp_artifacts: ${TMP_ARTIFACT_COUNT}"
if [[ "${TMP_ARTIFACT_COUNT}" -gt 0 ]]; then
  echo "  tmp_archive: ${TMP_ARTIFACTS_TARBALL}"
fi
echo "  archived_event_ledger_lines: ${EVENT_LEDGER_ARCHIVED_LINES}"
if [[ "${EVENT_LEDGER_ARCHIVED_LINES}" -gt 0 ]]; then
  echo "  event_ledger_backup: ${EVENT_LEDGER_BACKUP}"
fi
echo "  archived_legacy_flat_shared_doc: ${LEGACY_SHARED_DOC_ARCHIVED}"
if [[ "${LEGACY_SHARED_DOC_ARCHIVED}" -gt 0 ]]; then
  echo "  legacy_flat_shared_doc_archive: ${LEGACY_SHARED_DOC_ARCHIVE}"
fi
echo "  archived_nonessential_residue: ${RESIDUE_FILE_COUNT}"
if [[ "${RESIDUE_FILE_COUNT}" -gt 0 ]]; then
  echo "  residue_archive: ${RESIDUE_TARBALL}"
fi
echo "  removed_empty_surface_dirs: ${EMPTY_SURFACE_DIRS_REMOVED}"
echo "  kept_runtime_files:"
echo "    - ${SFS_LOCAL_DIR}/config.yaml — workspace SFS runtime config"
echo "    - ${SFS_LOCAL_DIR}/VERSION — installed SFS version/upgrade state"
echo "    - ${SFS_LOCAL_DIR}/model-profiles.yaml — project model-routing config"
echo "    - ${SFS_LOCAL_DIR}/divisions.yaml — project division activation config"
echo "  event_ledger_after_adopt: none"
echo "  visible_policy: shared docs/solon/<english-workspace>/<yyyyMMdd>/handoff.md only; .sfs-local stays private"
echo "  next: run baseline verification, then start the first real SFS sprint"

exit "${SFS_EXIT_OK}"
