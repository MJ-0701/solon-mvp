#!/usr/bin/env bash
# .sfs-local/scripts/sfs-commit.sh
#
# Solon SFS — `sfs commit` command implementation.
# Groups the working tree into meaning-based commit buckets so sprint close
# bookkeeping, product code, and Solon runtime upgrades do not get mixed.
#
# Output:
#   status/plan: grouped git working tree summary
#   apply: local git commit summary (push is never run)
#
# Exit codes:
#   0  ok
#   1  no matching files / nothing to commit
#   3  not a git repo
#   5  unsafe staged files or git commit failed
#   7  usage error
#   99 unknown

set -euo pipefail

: "${SFS_EXIT_NO_MATCH:=1}"
: "${SFS_EXIT_BADCLI:=7}"
: "${SFS_EXIT_COMMIT_FAILED:=5}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SCRIPT_DIR}/sfs-common.sh"

usage() {
  cat <<'EOF'
Usage:
  sfs commit [status|plan]
  sfs commit apply --group <product-code|sprint-meta|runtime-upgrade|ambiguous> [-m <message>] [--dry-run]

What it does:
  status/plan  Show unstaged, staged, and untracked files grouped by meaning.
  apply        Stage every file in the selected group, then run one local git commit.
               A Conventional Commit message is generated automatically from
               selected files and the current Git Flow branch; -m overrides it.

Groups:
  product-code      Project/product source files and assets.
  sprint-meta       .sfs-local sprint/decision/event bookkeeping.
  runtime-upgrade   Solon runtime/docs/adapters managed by install/update.
  ambiguous         Local SFS files that need explicit human grouping.

Safety:
  - Includes untracked and unstaged files in the selected group.
  - Aborts if unrelated files are already staged.
  - Shows Git Flow branch preflight guidance before commit planning/apply.
  - This helper never runs git push; the AI runtime owns branch push/main merge/main push after local commit.

Options for apply:
  -g, --group <name>      Group to commit.
  -m, --message <text>    Override generated commit message.
      --include <path>    Add a path to the selected set.
      --exclude <path>    Remove a path from the selected set.
      --dry-run           Print what would be committed without changing git state.
  -h, --help              Show this help.

Examples:
  sfs commit
  sfs commit plan
  sfs commit apply --group product-code
  sfs commit apply --group product-code -m "feat: add first landing page"
  sfs commit apply --group runtime-upgrade

Exit codes:
  0  ok
  1  no matching files / nothing to commit
  3  not a git repo
  5  unsafe staged files or git commit failed
  7  usage error
  99 unknown
EOF
}

die_usage() {
  echo "$1" >&2
  usage >&2
  exit "${SFS_EXIT_BADCLI}"
}

ensure_git_repo() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "not a git repo" >&2
    exit "${SFS_EXIT_NO_GIT}"
  fi
}

declare -a STAGED_PATHS
declare -a UNSTAGED_PATHS
declare -a UNTRACKED_PATHS
declare -a ALL_PATHS

list_contains() {
  local needle="${1:-}" item
  shift || true
  for item in "$@"; do
    [[ "${item}" == "${needle}" ]] && return 0
  done
  return 1
}

add_unique_all() {
  local path="${1:-}"
  [[ -n "${path}" ]] || return 0
  if ! list_contains "${path}" "${ALL_PATHS[@]+"${ALL_PATHS[@]}"}"; then
    ALL_PATHS+=("${path}")
  fi
}

read_git_paths() {
  local mode="$1" path
  while IFS= read -r path || [[ -n "${path}" ]]; do
    [[ -n "${path}" ]] || continue
    case "${mode}" in
      staged)    STAGED_PATHS+=("${path}") ;;
      unstaged)  UNSTAGED_PATHS+=("${path}") ;;
      untracked) UNTRACKED_PATHS+=("${path}") ;;
    esac
    add_unique_all "${path}"
  done
}

collect_status() {
  STAGED_PATHS=()
  UNSTAGED_PATHS=()
  UNTRACKED_PATHS=()
  ALL_PATHS=()
  while IFS= read -r path || [[ -n "${path}" ]]; do
    [[ -n "${path}" ]] || continue
    STAGED_PATHS+=("${path}")
    add_unique_all "${path}"
  done < <(git diff --cached --name-only --diff-filter=ACMRTD)

  while IFS= read -r path || [[ -n "${path}" ]]; do
    [[ -n "${path}" ]] || continue
    UNSTAGED_PATHS+=("${path}")
    add_unique_all "${path}"
  done < <(git diff --name-only --diff-filter=ACMRTD)

  while IFS= read -r path || [[ -n "${path}" ]]; do
    [[ -n "${path}" ]] || continue
    UNTRACKED_PATHS+=("${path}")
    add_unique_all "${path}"
  done < <(git ls-files --others --exclude-standard)
}

classify_path() {
  local path="${1:-}"
  case "${path}" in
    .sfs-local/sprints/*|.sfs-local/decisions/*|.sfs-local/events.jsonl|.sfs-local/current-sprint|.sfs-local/current-wu)
      echo "sprint-meta"
      ;;
    SFS.md|.sfs-local/VERSION|.sfs-local/GUIDE.md|.sfs-local/auth.env.example|.sfs-local/scripts/*|.sfs-local/sprint-templates/*|.sfs-local/personas/*|.sfs-local/decisions-template/*|.claude/skills/sfs/SKILL.md|.claude/commands/sfs.md|.agents/skills/sfs/SKILL.md|.gemini/commands/sfs.toml|.codex/prompts/sfs.md)
      echo "runtime-upgrade"
      ;;
    .sfs-local/*)
      echo "ambiguous"
      ;;
    *)
      echo "product-code"
      ;;
  esac
}

path_status() {
  local path="${1:-}" staged=0 unstaged=0 untracked=0
  list_contains "${path}" "${STAGED_PATHS[@]+"${STAGED_PATHS[@]}"}" && staged=1
  list_contains "${path}" "${UNSTAGED_PATHS[@]+"${UNSTAGED_PATHS[@]}"}" && unstaged=1
  list_contains "${path}" "${UNTRACKED_PATHS[@]+"${UNTRACKED_PATHS[@]}"}" && untracked=1
  if [[ "${untracked}" -eq 1 ]]; then
    printf '??'
  elif [[ "${staged}" -eq 1 && "${unstaged}" -eq 1 ]]; then
    printf 'SM'
  elif [[ "${staged}" -eq 1 ]]; then
    printf 'S '
  elif [[ "${unstaged}" -eq 1 ]]; then
    printf ' M'
  else
    printf '  '
  fi
}

count_group() {
  local group="${1:-}" path count=0
  for path in "${ALL_PATHS[@]+"${ALL_PATHS[@]}"}"; do
    [[ "$(classify_path "${path}")" == "${group}" ]] && count=$((count + 1))
  done
  echo "${count}"
}

print_group() {
  local group="$1" count path printed=0
  count="$(count_group "${group}")"
  printf '\n[%s] %s file(s)\n' "${group}" "${count}"
  for path in "${ALL_PATHS[@]+"${ALL_PATHS[@]}"}"; do
    if [[ "$(classify_path "${path}")" == "${group}" ]]; then
      printf '  %s %s\n' "$(path_status "${path}")" "${path}"
      printed=1
    fi
  done
  [[ "${printed}" -eq 1 ]] || printf '  -\n'
}

render_status() {
  local branch total staged unstaged untracked
  branch="$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo "-")"
  total="${#ALL_PATHS[@]}"
  staged="${#STAGED_PATHS[@]}"
  unstaged="${#UNSTAGED_PATHS[@]}"
  untracked="${#UNTRACKED_PATHS[@]}"

  printf 'sfs commit status\n'
  printf 'branch: %s\n' "${branch}"
  printf 'changes: %s file(s) (staged %s, unstaged %s, untracked %s)\n' \
    "${total}" "${staged}" "${unstaged}" "${untracked}"

  print_group "product-code"
  print_group "sprint-meta"
  print_group "runtime-upgrade"
  print_group "ambiguous"
}

render_plan() {
  render_status
  render_branch_prework ""
  cat <<'EOF'

Recommended next commands:
  product-code:
    sfs commit apply --group product-code
  sprint-meta:
    sfs commit apply --group sprint-meta
  runtime-upgrade:
    sfs commit apply --group runtime-upgrade
  ambiguous:
    sfs commit apply --group ambiguous

Tip:
  Auto messages follow Conventional Commits and use Git Flow branch prefixes
  when available (feature/* -> feat, bugfix|hotfix/* -> fix, release/* -> chore).
  Use --include/--exclude when one file belongs with a different group.
EOF
}

default_message() {
  case "${1:-}" in
    sprint-meta) echo "chore(sfs): update sprint artifacts" ;;
    runtime-upgrade) echo "chore(sfs): update runtime" ;;
    ambiguous) echo "chore(sfs): update local files" ;;
    *) echo "" ;;
  esac
}

current_branch() {
  git symbolic-ref --short HEAD 2>/dev/null || echo ""
}

branch_suffix() {
  local branch="${1:-}"
  case "${branch}" in
    */*) echo "${branch#*/}" ;;
    *) echo "" ;;
  esac
}

normalize_scope() {
  local raw="${1:-}" scope
  scope="$(printf '%s' "${raw}" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's#[^a-z0-9._-]+#-#g; s#^[._-]+##; s#[._-]+$##; s#[._-][._-]+#-#g')"
  echo "${scope}"
}

git_flow_type() {
  local branch
  branch="$(current_branch)"
  case "${branch}" in
    feature/*|feat/*) echo "feat" ;;
    bugfix/*|fix/*|hotfix/*) echo "fix" ;;
    release/*|support/*) echo "chore" ;;
    *) echo "" ;;
  esac
}

git_flow_scope() {
  local branch suffix
  branch="$(current_branch)"
  case "${branch}" in
    feature/*|feat/*|bugfix/*|fix/*|hotfix/*)
      suffix="$(branch_suffix "${branch}")"
      normalize_scope "${suffix}"
      ;;
    release/*)
      echo "release"
      ;;
    support/*)
      echo "support"
      ;;
    *)
      echo ""
      ;;
  esac
}

git_flow_release_subject() {
  local branch suffix
  branch="$(current_branch)"
  case "${branch}" in
    release/*)
      suffix="$(branch_suffix "${branch}")"
      if [[ -n "${suffix}" ]]; then
        echo "prepare ${suffix}"
      else
        echo "update release artifacts"
      fi
      ;;
    *)
      echo ""
      ;;
  esac
}

is_primary_branch() {
  case "${1:-}" in
    main|master|develop) return 0 ;;
    *) return 1 ;;
  esac
}

is_git_flow_branch() {
  case "${1:-}" in
    feature/*|feat/*|bugfix/*|fix/*|hotfix/*|release/*|support/*) return 0 ;;
    *) return 1 ;;
  esac
}

render_branch_prework() {
  local group="${1:-}" branch
  branch="$(current_branch)"

  printf '\nBranch preflight:\n'
  if [[ -z "${branch}" ]]; then
    printf '  current: detached HEAD\n'
    printf '  guidance: create or switch to a task branch before product commits.\n'
  elif is_git_flow_branch "${branch}"; then
    printf '  current: %s\n' "${branch}"
    printf '  guidance: ok - Git Flow-shaped branch detected; auto message will use it.\n'
  elif is_primary_branch "${branch}"; then
    printf '  current: %s\n' "${branch}"
    if [[ "${group}" == "product-code" || -z "${group}" ]]; then
      printf '  guidance: primary branch. Prefer a task branch before product-code commits.\n'
      printf '  example: git switch -c feature/<work-name>\n'
    else
      printf '  guidance: ok for SFS bookkeeping/runtime commits; product-code should use a task branch.\n'
    fi
  else
    printf '  current: %s\n' "${branch}"
    printf '  guidance: branch is not Git Flow-shaped. Prefer feature/*, bugfix/*, hotfix/*, release/*, or support/*.\n'
  fi
  printf '  solon-branch-helper: AI runtime should create/switch feature/* or hotfix/* before product-code commits when needed.\n'
}

format_subject() {
  local type="$1" scope="$2" description="$3"
  if [[ -n "${scope}" ]]; then
    echo "${type}(${scope}): ${description}"
  else
    echo "${type}: ${description}"
  fi
}

is_docs_path() {
  case "${1:-}" in
    README*|CHANGELOG*|LICENSE*|docs/*|*.md|*.mdx|*.rst|*.txt) return 0 ;;
    *) return 1 ;;
  esac
}

is_test_path() {
  case "${1:-}" in
    *test*|*spec*|__tests__/*|tests/*|test/*|*.test.*|*.spec.*) return 0 ;;
    *) return 1 ;;
  esac
}

is_dependency_path() {
  case "${1:-}" in
    package.json|package-lock.json|pnpm-lock.yaml|yarn.lock|bun.lockb|Gemfile|Gemfile.lock|go.mod|go.sum|Cargo.toml|Cargo.lock|requirements*.txt|pyproject.toml|poetry.lock) return 0 ;;
    *) return 1 ;;
  esac
}

selected_all_untracked() {
  local path
  [[ "${#SELECTED_PATHS[@]}" -gt 0 ]] || return 1
  for path in "${SELECTED_PATHS[@]}"; do
    list_contains "${path}" "${UNTRACKED_PATHS[@]+"${UNTRACKED_PATHS[@]}"}" || return 1
  done
  return 0
}

selected_all_match() {
  local predicate="$1" path
  [[ "${#SELECTED_PATHS[@]}" -gt 0 ]] || return 1
  for path in "${SELECTED_PATHS[@]}"; do
    "${predicate}" "${path}" || return 1
  done
  return 0
}

first_path_root() {
  local path="${1:-}"
  case "${path}" in
    */*) echo "${path%%/*}" ;;
    *) echo "${path}" ;;
  esac
}

path_template_slug() {
  local path="${1:-}" rest=""
  case "${path}" in
    */templates/*)
      rest="${path#*/templates/}"
      echo "${rest%%/*}"
      ;;
    templates/*)
      rest="${path#templates/}"
      echo "${rest%%/*}"
      ;;
  esac
}

selected_template_slug() {
  local path slug first="" seen=0
  for path in "${SELECTED_PATHS[@]}"; do
    slug="$(path_template_slug "${path}")"
    [[ -n "${slug}" ]] || continue
    if [[ "${seen}" -eq 0 ]]; then
      first="${slug}"
      seen=1
    elif [[ "${slug}" != "${first}" ]]; then
      echo ""
      return 0
    fi
  done
  echo "${first}"
}

selected_area() {
  local path root first="" multiple=0
  for path in "${SELECTED_PATHS[@]}"; do
    root="$(first_path_root "${path}")"
    if [[ -z "${first}" ]]; then
      first="${root}"
    elif [[ "${root}" != "${first}" ]]; then
      multiple=1
    fi
  done
  if [[ "${multiple}" -eq 1 ]]; then
    echo "project files"
  elif [[ -n "${first}" ]]; then
    echo "${first}"
  else
    echo "files"
  fi
}

selected_scope() {
  local slug branch_scope area
  slug="$(selected_template_slug)"
  if [[ -n "${slug}" ]]; then
    normalize_scope "${slug}"
    return 0
  fi

  branch_scope="$(git_flow_scope)"
  if [[ -n "${branch_scope}" && "${branch_scope}" != "release" && "${branch_scope}" != "support" ]]; then
    echo "${branch_scope}"
    return 0
  fi

  area="$(selected_area)"
  case "${area}" in
    "project files"|"files") echo "" ;;
    *) normalize_scope "${area}" ;;
  esac
}

generated_subject() {
  local group="$1" default action slug area type scope release_subject
  default="$(default_message "${group}")"
  [[ -n "${default}" && "${group}" != "product-code" ]] && { echo "${default}"; return 0; }

  action="update"
  selected_all_untracked && action="add"

  release_subject="$(git_flow_release_subject)"
  if [[ -n "${release_subject}" ]]; then
    format_subject "chore" "release" "${release_subject}"
    return 0
  fi

  scope="$(selected_scope)"

  if selected_all_match is_docs_path; then
    format_subject "docs" "${scope}" "${action} docs"
    return 0
  fi
  if selected_all_match is_test_path; then
    format_subject "test" "${scope}" "${action} tests"
    return 0
  fi
  if selected_all_match is_dependency_path; then
    format_subject "chore" "deps" "update dependencies"
    return 0
  fi

  slug="$(selected_template_slug)"
  type="$(git_flow_type)"
  [[ -n "${type}" ]] || type="feat"
  if [[ -n "${slug}" ]]; then
    format_subject "${type}" "${scope}" "${action} template"
    return 0
  fi

  area="$(selected_area)"
  format_subject "${type}" "${scope}" "${action} ${area}"
}

generated_body() {
  local group="$1" path branch
  branch="$(current_branch)"
  {
    echo "SFS commit group: ${group}"
    if [[ -n "${branch}" && "${branch}" != "main" && "${branch}" != "master" && "${branch}" != "develop" ]]; then
      echo "Git flow branch: ${branch}"
    fi
    echo ""
    echo "Files:"
    for path in "${SELECTED_PATHS[@]}"; do
      echo "- ${path}"
    done
  }
}

declare -a SELECTED_PATHS
declare -a INCLUDE_PATHS
declare -a EXCLUDE_PATHS

add_selected() {
  local path="${1:-}"
  [[ -n "${path}" ]] || return 0
  if ! list_contains "${path}" "${SELECTED_PATHS[@]+"${SELECTED_PATHS[@]}"}"; then
    SELECTED_PATHS+=("${path}")
  fi
}

is_excluded() {
  local path="${1:-}"
  list_contains "${path}" "${EXCLUDE_PATHS[@]+"${EXCLUDE_PATHS[@]}"}"
}

selected_contains() {
  local path="${1:-}"
  list_contains "${path}" "${SELECTED_PATHS[@]+"${SELECTED_PATHS[@]}"}"
}

build_selection() {
  local group="$1" path
  SELECTED_PATHS=()
  for path in "${ALL_PATHS[@]+"${ALL_PATHS[@]}"}"; do
    if [[ "$(classify_path "${path}")" == "${group}" ]]; then
      add_selected "${path}"
    fi
  done
  for path in "${INCLUDE_PATHS[@]+"${INCLUDE_PATHS[@]}"}"; do
    add_selected "${path}"
  done

  local filtered=()
  for path in "${SELECTED_PATHS[@]+"${SELECTED_PATHS[@]}"}"; do
    if ! is_excluded "${path}"; then
      filtered+=("${path}")
    fi
  done
  SELECTED_PATHS=("${filtered[@]+"${filtered[@]}"}")
}

assert_no_unrelated_staged() {
  local path
  for path in "${STAGED_PATHS[@]+"${STAGED_PATHS[@]}"}"; do
    if ! selected_contains "${path}"; then
      cat >&2 <<EOF
unsafe staged file outside selected group: ${path}

Commit or unstage unrelated staged files first, then rerun sfs commit apply.
EOF
      exit "${SFS_EXIT_COMMIT_FAILED}"
    fi
  done
}

print_selected() {
  local group="$1" message="$2" path
  printf 'sfs commit apply\n'
  printf 'group: %s\n' "${group}"
  printf 'message: %s\n' "${message}"
  printf 'files: %s\n' "${#SELECTED_PATHS[@]}"
  for path in "${SELECTED_PATHS[@]+"${SELECTED_PATHS[@]}"}"; do
    printf '  %s %s\n' "$(path_status "${path}")" "${path}"
  done
}

apply_group() {
  local group="" message="" message_body="" dry_run=0 auto_message=0
  INCLUDE_PATHS=()
  EXCLUDE_PATHS=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -g|--group)
        [[ $# -ge 2 ]] || die_usage "--group requires a value"
        group="$2"
        shift 2
        ;;
      --group=*)
        group="${1#--group=}"
        shift
        ;;
      -m|--message)
        [[ $# -ge 2 ]] || die_usage "--message requires a value"
        message="$2"
        shift 2
        ;;
      --message=*)
        message="${1#--message=}"
        shift
        ;;
      --include)
        [[ $# -ge 2 ]] || die_usage "--include requires a path"
        INCLUDE_PATHS+=("$2")
        shift 2
        ;;
      --include=*)
        INCLUDE_PATHS+=("${1#--include=}")
        shift
        ;;
      --exclude)
        [[ $# -ge 2 ]] || die_usage "--exclude requires a path"
        EXCLUDE_PATHS+=("$2")
        shift 2
        ;;
      --exclude=*)
        EXCLUDE_PATHS+=("${1#--exclude=}")
        shift
        ;;
      --dry-run)
        dry_run=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die_usage "unknown arg: $1"
        ;;
    esac
  done

  case "${group}" in
    product-code|sprint-meta|runtime-upgrade|ambiguous) ;;
    "") die_usage "missing --group" ;;
    *) die_usage "unknown group: ${group}" ;;
  esac

  build_selection "${group}"
  if [[ "${#SELECTED_PATHS[@]}" -eq 0 ]]; then
    echo "no matching files for group: ${group}" >&2
    exit "${SFS_EXIT_NO_MATCH}"
  fi

  if [[ -z "${message}" ]]; then
    message="$(generated_subject "${group}")"
    message_body="$(generated_body "${group}")"
    auto_message=1
  fi

  render_branch_prework "${group}"
  print_selected "${group}" "${message}"
  if [[ "${auto_message}" -eq 1 ]]; then
    printf 'message-source: generated\n'
  else
    printf 'message-source: user\n'
  fi
  printf 'push: not run\n'

  if [[ "${dry_run}" -eq 1 ]]; then
    printf 'dry-run: no git state changed\n'
    exit 0
  fi

  assert_no_unrelated_staged

  git add -- "${SELECTED_PATHS[@]}"
  if git diff --cached --quiet --exit-code; then
    echo "nothing staged after selecting group: ${group}" >&2
    exit "${SFS_EXIT_NO_MATCH}"
  fi

  if [[ "${auto_message}" -eq 1 ]]; then
    git commit -m "${message}" -m "${message_body}" || {
      echo "git commit failed" >&2
      exit "${SFS_EXIT_COMMIT_FAILED}"
    }
  elif ! git commit -m "${message}"; then
    echo "git commit failed" >&2
    exit "${SFS_EXIT_COMMIT_FAILED}"
  fi

  local sha
  sha="$(git rev-parse --short HEAD 2>/dev/null || echo "-")"
  printf 'committed: %s\n' "${sha}"
  printf 'push: not run\n'
}

main() {
  local cmd="${1:-plan}"
  case "${cmd}" in
    -h|--help|help)
      usage
      exit 0
      ;;
    status|plan|apply)
      shift || true
      ;;
    *)
      die_usage "unknown command: ${cmd}"
      ;;
  esac

  ensure_git_repo
  collect_status

  case "${cmd}" in
    status) render_status ;;
    plan) render_plan ;;
    apply) apply_group "$@" ;;
  esac
}

main "$@"
