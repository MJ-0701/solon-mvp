#!/usr/bin/env bash
# Search a markdown document plus its split child directory, if present.

sfs_doc_sources() {
  local file="$1"
  printf '%s\n' "${file}"

  local child_dir="${file%.md}"
  if [[ -d "${child_dir}" ]]; then
    find "${child_dir}" -name '*.md' -type f | sort
  fi
}

sfs_doc_contains() {
  local file="$1" needle="$2"

  [[ -f "${file}" ]] || return 2
  while IFS= read -r source; do
    grep -Fq -- "${needle}" "${source}" && return 0
  done < <(sfs_doc_sources "${file}")

  local normalized
  normalized="$(while IFS= read -r source; do cat "${source}"; printf '\n'; done < <(sfs_doc_sources "${file}") | tr '\n' ' ' | sed 's/[[:space:]][[:space:]]*/ /g')"
  printf '%s' "${normalized}" | grep -Fq -- "${needle}"
}

sfs_doc_not_contains() {
  local file="$1" needle="$2"

  [[ -f "${file}" ]] || return 2
  while IFS= read -r source; do
    if grep -Fq -- "${needle}" "${source}"; then
      return 1
    fi
  done < <(sfs_doc_sources "${file}")
  return 0
}
