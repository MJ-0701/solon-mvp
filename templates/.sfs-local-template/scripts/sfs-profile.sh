#!/usr/bin/env bash
# .sfs-local/scripts/sfs-profile.sh
#
# Solon SFS — project profile context/refinement adapter.
# Narrow purpose: fill only SFS.md "프로젝트 개요" without reading sprint/code context.

set -euo pipefail

MODE="prompt"
SFS_LOCAL_DIR="${SFS_LOCAL_DIR:-.sfs-local}"
TARGET="$(pwd)"
SFS_MD="${TARGET}/SFS.md"
PROJECT_NAME="$(basename "$TARGET")"

usage() {
  cat <<'EOF'
Usage:
  sfs profile [--prompt-only]
  sfs profile --apply

Purpose:
  Detect a narrow project profile for SFS.md "프로젝트 개요".

Modes:
  --prompt-only  Print a bounded agent task. The AI runtime may read only the
                 listed files and edit only the SFS.md project overview section.
  --apply        Shell-only quick apply using deterministic detection.
  -h, --help     Show this help.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --prompt-only|--show)
      MODE="prompt"
      ;;
    --apply)
      MODE="apply"
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

pkg_has() {
  local name="$1"
  [ -f "$TARGET/package.json" ] || return 1
  grep -Eq "\"${name}\"[[:space:]]*:" "$TARGET/package.json" 2>/dev/null
}

append_project_environment() {
  local part="$1"
  [ -n "$part" ] || return 0
  case " + $PROJECT_ENVIRONMENT + " in
    *" + $part + "*) return 0 ;;
  esac
  if [ -z "$PROJECT_ENVIRONMENT" ]; then
    PROJECT_ENVIRONMENT="$part"
  else
    PROJECT_ENVIRONMENT="$PROJECT_ENVIRONMENT + $part"
  fi
}

detect_project_profile() {
  PROJECT_TYPE="<PROJECT-TYPE>"
  PROJECT_STAGE="Solon 운영 도입 초기"
  PROJECT_ENVIRONMENT=""
  PROJECT_DATA=""
  PROJECT_OUTPUT="<PROJECT-OUTPUT>"
  PROJECT_DELIVERY=""

  if [ -f "$TARGET/package.json" ]; then
    PROJECT_TYPE="소프트웨어/웹 제품"
    append_project_environment "Node.js"
    if [ -f "$TARGET/tsconfig.json" ] || pkg_has typescript; then
      append_project_environment "TypeScript"
    fi
    if pkg_has next || [ -f "$TARGET/next.config.js" ] || [ -f "$TARGET/next.config.mjs" ] || [ -f "$TARGET/next.config.ts" ]; then
      append_project_environment "Next.js"
      PROJECT_OUTPUT="웹 앱"
    elif pkg_has vite || [ -f "$TARGET/vite.config.js" ] || [ -f "$TARGET/vite.config.ts" ]; then
      append_project_environment "Vite"
      PROJECT_OUTPUT="웹 앱"
    elif pkg_has react; then
      append_project_environment "React"
      PROJECT_OUTPUT="웹 앱"
    elif pkg_has vue; then
      append_project_environment "Vue"
      PROJECT_OUTPUT="웹 앱"
    elif pkg_has svelte; then
      append_project_environment "Svelte"
      PROJECT_OUTPUT="웹 앱"
    else
      PROJECT_OUTPUT="Node.js 앱"
    fi
    if pkg_has tailwindcss || [ -f "$TARGET/tailwind.config.js" ] || [ -f "$TARGET/tailwind.config.ts" ]; then
      append_project_environment "Tailwind CSS"
    fi
    if pkg_has prisma || [ -f "$TARGET/prisma/schema.prisma" ]; then
      append_project_environment "Prisma"
      PROJECT_DATA="Prisma"
    elif pkg_has drizzle-orm || [ -f "$TARGET/drizzle.config.ts" ] || [ -f "$TARGET/drizzle.config.js" ]; then
      append_project_environment "Drizzle"
      PROJECT_DATA="Drizzle"
    fi
  fi

  if [ -f "$TARGET/prisma/schema.prisma" ]; then
    if grep -Eq 'provider[[:space:]]*=[[:space:]]*"postgresql"' "$TARGET/prisma/schema.prisma" 2>/dev/null; then
      append_project_environment "Postgres"; PROJECT_DATA="${PROJECT_DATA:+$PROJECT_DATA + }Postgres"
    elif grep -Eq 'provider[[:space:]]*=[[:space:]]*"mysql"' "$TARGET/prisma/schema.prisma" 2>/dev/null; then
      append_project_environment "MySQL"; PROJECT_DATA="${PROJECT_DATA:+$PROJECT_DATA + }MySQL"
    elif grep -Eq 'provider[[:space:]]*=[[:space:]]*"sqlite"' "$TARGET/prisma/schema.prisma" 2>/dev/null; then
      append_project_environment "SQLite"; PROJECT_DATA="${PROJECT_DATA:+$PROJECT_DATA + }SQLite"
    elif grep -Eq 'provider[[:space:]]*=[[:space:]]*"mongodb"' "$TARGET/prisma/schema.prisma" 2>/dev/null; then
      append_project_environment "MongoDB"; PROJECT_DATA="${PROJECT_DATA:+$PROJECT_DATA + }MongoDB"
    fi
  fi

  if [ -f "$TARGET/pyproject.toml" ] || [ -f "$TARGET/requirements.txt" ]; then
    [ "$PROJECT_TYPE" = "<PROJECT-TYPE>" ] && PROJECT_TYPE="소프트웨어/Python 프로젝트"
    append_project_environment "Python"
    PROJECT_OUTPUT="${PROJECT_OUTPUT#<PROJECT-OUTPUT>}"
    [ -z "$PROJECT_OUTPUT" ] && PROJECT_OUTPUT="Python 앱"
    if grep -Eiq 'fastapi' "$TARGET/pyproject.toml" "$TARGET/requirements.txt" 2>/dev/null; then
      append_project_environment "FastAPI"
      PROJECT_OUTPUT="API 서비스"
    elif grep -Eiq 'django' "$TARGET/pyproject.toml" "$TARGET/requirements.txt" 2>/dev/null; then
      append_project_environment "Django"
      PROJECT_OUTPUT="웹 앱"
    elif grep -Eiq 'flask' "$TARGET/pyproject.toml" "$TARGET/requirements.txt" 2>/dev/null; then
      append_project_environment "Flask"
      PROJECT_OUTPUT="웹/API 앱"
    elif grep -Eiq 'streamlit' "$TARGET/pyproject.toml" "$TARGET/requirements.txt" 2>/dev/null; then
      append_project_environment "Streamlit"
      PROJECT_OUTPUT="데이터 앱"
    fi
  fi

  if [ -f "$TARGET/Cargo.toml" ]; then
    [ "$PROJECT_TYPE" = "<PROJECT-TYPE>" ] && PROJECT_TYPE="소프트웨어/Rust 프로젝트"
    append_project_environment "Rust"
    [ "$PROJECT_OUTPUT" = "<PROJECT-OUTPUT>" ] && PROJECT_OUTPUT="Rust 앱"
  fi
  if [ -f "$TARGET/go.mod" ]; then
    [ "$PROJECT_TYPE" = "<PROJECT-TYPE>" ] && PROJECT_TYPE="소프트웨어/Go 프로젝트"
    append_project_environment "Go"
    [ "$PROJECT_OUTPUT" = "<PROJECT-OUTPUT>" ] && PROJECT_OUTPUT="Go 앱"
  fi
  if [ -f "$TARGET/Gemfile" ]; then
    [ "$PROJECT_TYPE" = "<PROJECT-TYPE>" ] && PROJECT_TYPE="소프트웨어/Ruby 프로젝트"
    append_project_environment "Ruby"
    [ "$PROJECT_OUTPUT" = "<PROJECT-OUTPUT>" ] && PROJECT_OUTPUT="Ruby 앱"
  fi
  if [ -f "$TARGET/pom.xml" ] || [ -f "$TARGET/build.gradle" ] || [ -f "$TARGET/build.gradle.kts" ]; then
    [ "$PROJECT_TYPE" = "<PROJECT-TYPE>" ] && PROJECT_TYPE="소프트웨어/JVM 프로젝트"
    append_project_environment "JVM"
    [ "$PROJECT_OUTPUT" = "<PROJECT-OUTPUT>" ] && PROJECT_OUTPUT="JVM 앱"
  fi

  if [ -f "$TARGET/vercel.json" ]; then
    PROJECT_DELIVERY="Vercel"
  elif [ -f "$TARGET/netlify.toml" ]; then
    PROJECT_DELIVERY="Netlify"
  elif [ -f "$TARGET/wrangler.toml" ]; then
    PROJECT_DELIVERY="Cloudflare"
  elif [ -f "$TARGET/firebase.json" ]; then
    PROJECT_DELIVERY="Firebase"
  elif [ -f "$TARGET/Dockerfile" ] || [ -f "$TARGET/docker-compose.yml" ] || [ -f "$TARGET/compose.yml" ]; then
    PROJECT_DELIVERY="Docker"
  fi

  if [ -d "$TARGET/docs" ] || ls "$TARGET"/*.md >/dev/null 2>&1; then
    if [ "$PROJECT_TYPE" = "<PROJECT-TYPE>" ]; then
      PROJECT_TYPE="문서/지식 작업공간"
      append_project_environment "Markdown/Git 작업공간"
      PROJECT_OUTPUT="문서/운영 기록"
      PROJECT_DELIVERY="${PROJECT_DELIVERY:-Git 또는 문서 공유}"
    fi
  fi

  [ -n "$PROJECT_ENVIRONMENT" ] || PROJECT_ENVIRONMENT="<PROJECT-ENVIRONMENT>"
  [ -n "$PROJECT_DATA" ] || PROJECT_DATA="<PROJECT-DATA>"
  [ -n "$PROJECT_DELIVERY" ] || PROJECT_DELIVERY="<PROJECT-DELIVERY>"
}

profile_block() {
  cat <<EOF
## 프로젝트 개요

- **이름**: \`${PROJECT_NAME}\`
- **유형**: \`${PROJECT_TYPE}\`
- **단계**: \`${PROJECT_STAGE}\`
- **환경**: \`${PROJECT_ENVIRONMENT}\`
- **핵심 산출물**: \`${PROJECT_OUTPUT}\`
- **공유/운영 방식**: \`${PROJECT_DELIVERY}\`

EOF
}

print_prompt() {
  cat <<EOF
sfs profile
status: context-ready
sfs_md: SFS.md

detected:
  name: ${PROJECT_NAME}
  type: ${PROJECT_TYPE}
  stage: ${PROJECT_STAGE}
  environment: ${PROJECT_ENVIRONMENT}
  data: ${PROJECT_DATA}
  output: ${PROJECT_OUTPUT}
  delivery: ${PROJECT_DELIVERY}

allowed_read:
  - SFS.md
  - package.json
  - tsconfig.json
  - next.config.*
  - vite.config.*
  - tailwind.config.*
  - prisma/schema.prisma
  - drizzle.config.*
  - pyproject.toml
  - requirements.txt
  - Cargo.toml
  - go.mod
  - Gemfile
  - pom.xml
  - build.gradle*
  - vercel.json
  - netlify.toml
  - wrangler.toml
  - firebase.json
  - Dockerfile
  - docker-compose.yml
  - compose.yml
  - README.md
  - docs/ index only

write_scope:
  - SFS.md section: from "## 프로젝트 개요" until the next "## " heading only

agent_task:
  1. Read only the allowed files that exist.
  2. Fill SFS.md project overview with name/type/stage/environment/output/delivery.
  3. Keep unknown fields as placeholders.
  4. Do not read sprint files, source files, git history, or unrelated docs.
  5. Do not edit code or any file other than SFS.md.

terminal_apply:
  sfs profile --apply
EOF
}

apply_profile() {
  [ -f "$SFS_MD" ] || {
    echo "SFS.md not found" >&2
    return 1
  }

  local ts backup_dir backup block_tmp out_tmp
  ts=$(date +%Y%m%d-%H%M%S)
  backup_dir="$TARGET/${SFS_LOCAL_DIR}/tmp/profile-backups/${ts}"
  mkdir -p "$backup_dir"
  backup="$backup_dir/SFS.md"
  cp "$SFS_MD" "$backup"

  block_tmp=$(mktemp "${TMPDIR:-/tmp}/sfs-profile-block.XXXXXX")
  out_tmp=$(mktemp "${TMPDIR:-/tmp}/sfs-profile-out.XXXXXX")
  profile_block > "$block_tmp"

  awk -v block_file="$block_tmp" '
    BEGIN {
      while ((getline line < block_file) > 0) {
        block = block line "\n"
      }
      close(block_file)
      in_profile = 0
      replaced = 0
    }
    $0 == "## 프로젝트 개요" {
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
      if (!replaced) {
        print ""
        printf "%s", block
      }
    }
  ' "$SFS_MD" > "$out_tmp"

  mv "$out_tmp" "$SFS_MD"
  rm -f "$block_tmp"
  echo "profile updated: SFS.md"
  echo "backup: ${backup#$TARGET/}"
}

detect_project_profile

case "$MODE" in
  apply)
    apply_profile
    ;;
  prompt)
    print_prompt
    ;;
esac
