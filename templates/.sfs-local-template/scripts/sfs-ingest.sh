#!/usr/bin/env bash
# WMU-3 — raw intake stubs require a collection purpose before wiki compile.
set -euo pipefail

SFS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./sfs-common.sh
source "${SFS_SCRIPT_DIR}/sfs-common.sh"

usage() {
  cat <<'EOF'
Usage:
  sfs ingest --source-type <article|youtube|podcast|book|research> --purpose <one-line purpose> [--title <title>] [--url <url>]

Creates a typed raw-intake draft under .sfs-local/ingest/. It does not fetch,
record, summarize, or compile source content. The draft is a purpose-gated
pointer that can later be compiled by reference into llm-wiki/.
EOF
}

SOURCE_TYPE=""
PURPOSE=""
TITLE=""
URL=""

require_value_arg() {
  local opt="$1"
  local value="${2:-}"
  if [[ -z "${value}" || "${value}" == --* ]]; then
    echo "${opt} requires a value" >&2
    exit 7
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source-type)
      shift
      require_value_arg "--source-type" "${1:-}"
      SOURCE_TYPE="$1"
      ;;
    --source-type=*)
      SOURCE_TYPE="${1#--source-type=}"
      ;;
    --purpose)
      shift
      require_value_arg "--purpose" "${1:-}"
      PURPOSE="$1"
      ;;
    --purpose=*)
      PURPOSE="${1#--purpose=}"
      ;;
    --title)
      shift
      require_value_arg "--title" "${1:-}"
      TITLE="$1"
      ;;
    --title=*)
      TITLE="${1#--title=}"
      ;;
    --url)
      shift
      require_value_arg "--url" "${1:-}"
      URL="$1"
      ;;
    --url=*)
      URL="${1#--url=}"
      ;;
    -h|--help|help)
      usage
      exit 0
      ;;
    *)
      echo "unknown arg: $1" >&2
      usage >&2
      exit 7
      ;;
  esac
  shift
done

case "${SOURCE_TYPE}" in
  article|youtube|podcast|book|research) ;;
  "")
    echo "source_type required: article, youtube, podcast, book, or research" >&2
    exit 7
    ;;
  *)
    echo "invalid source_type: ${SOURCE_TYPE} (expected article, youtube, podcast, book, research)" >&2
    exit 7
    ;;
esac

if [[ -z "${PURPOSE//[[:space:]]/}" ]]; then
  echo "collection purpose required: pass --purpose \"why this source, for which question\"" >&2
  exit 7
fi

if [[ -z "${TITLE//[[:space:]]/}" ]]; then
  TITLE="untitled ${SOURCE_TYPE} source"
fi

yaml_quote() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '"%s"' "${value}"
}

slugify() {
  local value="$1"
  value="$(printf '%s' "${value}" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-+/-/g')"
  if [[ -z "${value}" ]]; then
    value="${SOURCE_TYPE}-source"
  fi
  printf '%s' "${value}"
}

ts="$(date -u +%Y%m%dT%H%M%SZ)"
iso_ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
slug="$(slugify "${TITLE}")"
out_dir="${SFS_LOCAL_DIR}/ingest"
out_path="${out_dir}/${ts}-${slug}.md"

mkdir -p "${out_dir}"

type_fields() {
  case "${SOURCE_TYPE}" in
    article)
      cat <<EOF
- url: ${URL:-TBD}
- publisher: TBD
- published_at: TBD
EOF
      ;;
    youtube)
      cat <<EOF
- url: ${URL:-TBD}
- channel: TBD
- runtime: TBD
EOF
      ;;
    podcast)
      cat <<EOF
- show: TBD
- episode: TBD
- runtime: TBD
EOF
      ;;
    book)
      cat <<EOF
- author: TBD
- edition: TBD
- pages: TBD
EOF
      ;;
    research)
      cat <<EOF
- authors: TBD
- venue: TBD
- doi_or_url: ${URL:-TBD}
EOF
      ;;
  esac
}

{
  cat <<EOF
---
doc_id: raw-ingest-${ts}-${slug}
doc_type: raw-intake
source_type: ${SOURCE_TYPE}
title: $(yaml_quote "${TITLE}")
collection_purpose: $(yaml_quote "${PURPOSE}")
captured_at: ${iso_ts}
compile_to_wiki: pending
wiki_target: llm-wiki/
---

# ${TITLE}

## Collection Purpose

${PURPOSE}

## Source Pointer

$(type_fields)

## Raw Notes

- TBD

## Wiki Compile Plan

- Question this source should answer: ${PURPOSE}
- Glossary seeds:
  - TBD
- Map or TopicHub target:
  - TBD
- Source-link confidence/gaps:
  - TBD
EOF
} > "${out_path}"

echo "ingest draft created: ${out_path} | source_type ${SOURCE_TYPE} | purpose recorded"
