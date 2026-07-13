#!/usr/bin/env bash
# 무문서 코드베이스 역추적(excavation) 파이프라인의 결정론 코어를 담당한다.
# L0(scan+ERD)·L1(graph+queue)·카드 검증기·상태 대시보드는 LLM 0토큰으로 완결.
# 대상 저장소의 소스는 절대 수정하지 않는다(read-only); 쓰기는 --write 로만.
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMMAND="${1:-help}"
[ $# -gt 0 ] && shift

usage() {
  cat <<'EOF'
Usage:
  sfs dig scan  [--domain <name>] [--write] [--live-schema <tsv>] [--waive-sanity "<reason>"]
  sfs dig graph [--domain <name>] [--write]
  sfs dig capsule [--domain <name>] [--next | --target <file>] [--write]
  sfs dig card validate <file|dir> [--root <repo-root>]
  sfs dig status [--domain <name>]

Bottom-up excavation for an undocumented codebase (code -> evidence -> map).
L0 scan + ERD and L1 graph + queue are fully deterministic (zero LLM tokens).
The target repository is read-only: dig never edits source, and artifacts are
written only under docs/solon/<domain>/excavation/ when --write is given
(without --write everything prints to stdout).

--live-schema expects a TSV of table<TAB>column<TAB>type, e.g. the output of:
  SELECT table_name, column_name, data_type FROM information_schema.columns
  WHERE table_schema = '<your-schema>';
Run that query yourself; dig never accepts or stores connection credentials,
and only schema STRUCTURE enters the report — data rows never do.
EOF
}

# ── 공통 ──────────────────────────────────────────────────────────────
DOMAIN=""
WRITE=0
LIVE_SCHEMA=""
WAIVE_SANITY=""
CARD_ROOT="$PWD"

parse_flags() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --domain) DOMAIN="${2:-}"; shift 2 ;;
      --write) WRITE=1; shift ;;
      --live-schema) LIVE_SCHEMA="${2:-}"; shift 2 ;;
      --waive-sanity) WAIVE_SANITY="${2:-}"; shift 2 ;;
      --root) CARD_ROOT="${2:-}"; shift 2 ;;
      *) echo "unknown flag: $1" >&2; exit 2 ;;
    esac
  done
}

# 도메인 slug 는 항상 [a-z0-9-] 로 정규화한다 — 명시 --domain 도 예외 없이 통과시켜
# `../` / 절대경로 / 공백 traversal 로 docs/solon/ 밖에 쓰는 것을 원천 차단한다.
domain_slug() {
  local raw
  if [ -n "${DOMAIN}" ]; then raw="${DOMAIN}"; else raw="$(basename "$PWD")"; fi
  printf '%s' "${raw}" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9-' '-' | sed 's/-*$//;s/^-*//'
}

exc_dir() { printf 'docs/solon/%s/excavation' "$(domain_slug)"; }

# emit <relative-artifact-name> : stdin 을 --write 면 파일로, 아니면 stdout 프리뷰로.
emit() {
  local name="$1"
  if [ "${WRITE}" = "1" ]; then
    mkdir -p "$(dirname "$(exc_dir)/${name}")"
    cat > "$(exc_dir)/${name}"
    echo "  wrote $(exc_dir)/${name}" >&2
  else
    echo "--- ${name} (preview; use --write to save) ---"
    cat
  fi
}

state_get() { # state_get <key>
  local f="$(exc_dir)/state"
  [ -f "$f" ] && sed -n "s/^$1=//p" "$f" | tail -1
}

state_set() { # state_set <key> <value>
  local f="$(exc_dir)/state" tmp
  mkdir -p "$(exc_dir)"
  tmp="$(mktemp)"
  { [ -f "$f" ] && grep -v "^$1=" "$f"; echo "$1=$2"; } > "$tmp" && mv "$tmp" "$f"
}

# 소스 파일 나열 (vendor/빌드 산출물 제외). 대상 저장소 read-only 원칙: find 만.
src_files() {
  find . -type f \( -name '*.java' -o -name '*.kt' -o -name '*.ts' -o -name '*.tsx' \
    -o -name '*.js' -o -name '*.jsx' -o -name '*.py' -o -name '*.rb' -o -name '*.go' \
    -o -name '*.php' -o -name '*.cs' \) \
    ! -path '*/node_modules/*' ! -path '*/.git/*' ! -path '*/dist/*' \
    ! -path '*/build/*' ! -path '*/target/*' ! -path '*/vendor/*' \
    ! -path '*/.sfs-local/*' ! -path './docs/solon/*' 2>/dev/null | sed 's|^\./||' | LC_ALL=C sort
}

# ── L0: scan ─────────────────────────────────────────────────────────
detect_frameworks() {
  # stdout: one marker per line "framework<TAB>evidence-file"
  [ -f pom.xml ] && grep -q 'spring-boot' pom.xml 2>/dev/null && printf 'spring-boot\tpom.xml\n'
  { [ -f build.gradle ] && grep -q 'spring-boot' build.gradle 2>/dev/null; } && printf 'spring-boot\tbuild.gradle\n'
  grep -rl '@Entity' --include='*.java' --include='*.kt' . 2>/dev/null | head -1 | sed 's|^\./||' | awk 'NF {print "jpa\t" $0}'
  if [ -f package.json ]; then
    grep -q '"express"' package.json && printf 'express\tpackage.json\n'
    grep -q '"@nestjs/core"' package.json && printf 'nestjs\tpackage.json\n'
    grep -q '"prisma"\|"@prisma/client"' package.json && printf 'prisma\tpackage.json\n'
    grep -q '"sequelize"' package.json && printf 'sequelize\tpackage.json\n'
    grep -q '"typeorm"' package.json && printf 'typeorm\tpackage.json\n'
    grep -q '"next"' package.json && printf 'nextjs\tpackage.json\n'
  fi
  [ -f manage.py ] && printf 'django\tmanage.py\n'
  { [ -f Gemfile ] && grep -q 'rails' Gemfile 2>/dev/null; } && printf 'rails\tGemfile\n'
}

detect_entrypoints() {
  grep -rn '@SpringBootApplication' --include='*.java' --include='*.kt' . 2>/dev/null | sed 's|^\./||' | awk -F: '{print $1":"$2"\tspring-boot main"}'
  if [ -f package.json ]; then
    main="$(sed -n 's/.*"main"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' package.json | head -1)"
    [ -n "${main}" ] && printf '%s\tpackage.json main\n' "${main}"
    sed -n 's/.*"start"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' package.json | head -1 | awk 'NF {print "package.json\tstart: " $0}'
  fi
  [ -f manage.py ] && printf 'manage.py\tdjango entry\n'
  for f in src/index.js src/index.ts index.js app.js server.js src/main.ts; do
    [ -f "$f" ] && printf '%s\tconventional entry\n' "$f"
  done
}

detect_routes() {
  # stdout: file:line<TAB>method<TAB>path-or-annotation
  grep -rn -E '@(Get|Post|Put|Delete|Patch|Request)Mapping' --include='*.java' --include='*.kt' . 2>/dev/null \
    | sed 's|^\./||' \
    | awk -F: '{line=$0; sub(/^[^:]*:[^:]*:/, "", line); gsub(/^[[:space:]]+/, "", line); print $1":"$2"\tspring\t" line}'
  grep -rn -E '(^|[^A-Za-z0-9_])(app|router)\.(get|post|put|delete|patch)\(' --include='*.js' --include='*.ts' . 2>/dev/null \
    | grep -v node_modules | sed 's|^\./||' \
    | awk -F: '{line=$0; sub(/^[^:]*:[^:]*:/, "", line); gsub(/^[[:space:]]+/, "", line); print $1":"$2"\texpress\t" line}'
  grep -rn -E "@(Get|Post|Put|Delete|Patch)\(" --include='*.ts' . 2>/dev/null \
    | grep -v node_modules | sed 's|^\./||' \
    | awk -F: '{line=$0; sub(/^[^:]*:[^:]*:/, "", line); gsub(/^[[:space:]]+/, "", line); print $1":"$2"\tnestjs\t" line}'
  grep -rn -E "^[[:space:]]*(path|re_path|url)\(" --include='urls.py' . 2>/dev/null | sed 's|^\./||' \
    | awk -F: '{line=$0; sub(/^[^:]*:[^:]*:/, "", line); gsub(/^[[:space:]]+/, "", line); print $1":"$2"\tdjango\t" line}'
}

detect_env_keys() {
  # 이름만 — 값은 절대 출력하지 않는다 (credential-hygiene).
  for f in .env .env.example .env.local .env.sample; do
    [ -f "$f" ] && sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\)=.*/\1/p' "$f" | awk -v f="$f" '{print f "\t" $0}'
  done
  grep -rh -oE 'process\.env\.[A-Z_][A-Z0-9_]*' --include='*.js' --include='*.ts' . 2>/dev/null \
    | grep -v node_modules | sed 's/process\.env\.//' | LC_ALL=C sort -u | awk '{print "process.env\t" $0}'
  grep -rh -oE 'System\.getenv\("[^"]*"\)' --include='*.java' . 2>/dev/null \
    | sed 's/System\.getenv("//;s/")//' | LC_ALL=C sort -u | awk '{print "System.getenv\t" $0}'
  grep -rh -oE "os\.environ(\.get)?\([\"'][A-Z_]+[\"']" --include='*.py' . 2>/dev/null \
    | sed -E "s/.*[\"']([A-Z_]+)[\"']$/\1/" | LC_ALL=C sort -u | awk 'NF {print "os.environ\t" $0}'
}

detect_schema_sources() {
  # stdout: kind<TAB>path
  find . -type f -name '*.sql' \( -path '*migration*' -o -path '*migrations*' \) ! -path '*/node_modules/*' ! -path '*/.git/*' 2>/dev/null \
    | sed 's|^\./||' | awk '{print "sql-migration\t" $0}'
  grep -rln '@Entity' --include='*.java' --include='*.kt' . 2>/dev/null | sed 's|^\./||' | awk '{print "jpa-entity\t" $0}'
  find . -name 'schema.prisma' ! -path '*/node_modules/*' 2>/dev/null | sed 's|^\./||' | awk '{print "prisma\t" $0}'
  grep -rln 'sequelize.define\|DataTypes\.' --include='*.js' --include='*.ts' . 2>/dev/null | grep -v node_modules | sed 's|^\./||' | awk '{print "sequelize\t" $0}'
  grep -rln 'models\.Model' --include='*.py' . 2>/dev/null | sed 's|^\./||' | awk '{print "django-model\t" $0}'
  for f in docker-compose.yml docker-compose.yaml compose.yml; do
    [ -f "$f" ] && grep -nE 'image:.*(mysql|postgres|mariadb|mongo)' "$f" | awk -F: -v f="$f" '{print "docker-db\t" f ":" $1}'
  done
}

count_functions() {
  # 커버리지 분모용 대략적 함수 정의 수 (결정론 regex).
  local total=0 n
  n=$(grep -rc -E '(public|private|protected)[^=;]*\)[[:space:]]*\{' --include='*.java' --include='*.kt' . 2>/dev/null | awk -F: '{s+=$2} END {print s+0}')
  total=$((total + n))
  n=$(grep -rhc -E '(^|[[:space:]])(function [A-Za-z_]|const [A-Za-z_][A-Za-z0-9_]* = (async )?\(|[A-Za-z_][A-Za-z0-9_]*[[:space:]]*: (async )?\()' --include='*.js' --include='*.ts' . 2>/dev/null | awk '{s+=$1} END {print s+0}')
  total=$((total + n))
  n=$(grep -rhc -E '^[[:space:]]*def [a-zA-Z_]' --include='*.py' . 2>/dev/null | awk '{s+=$1} END {print s+0}')
  total=$((total + n))
  echo "${total}"
}

run_sanity_precheck() {
  # 기존 harness doctor 재사용 — 실패해도 dig 는 계속 (signal-only).
  local out rc
  if out="$(bash "${SCRIPT_DIR}/sfs-harness.sh" doctor 2>/dev/null)"; then rc=0; else rc=$?; fi
  if [ -z "${out}" ]; then
    echo "unavailable"
  elif [ "${rc}" = "0" ]; then
    echo "pass"
  else
    echo "warn"
  fi
}

# ── ERD parsers ──────────────────────────────────────────────────────
erd_from_sql() { # args: sql files. stdout: TABLE/COL/FK/IDX rows (TSV)
  # 키워드 판정은 tolower(line) 토큰으로 — BSD awk 는 IGNORECASE 를 무시하므로
  # 대소문자 무관 매칭을 명시 소문자화로 보장한다 (대문자/소문자 SQL 모두 인식).
  awk '
    function strip(x){ gsub(/[`",;]/,"",x); return x }
    {
      line=$0; gsub(/[`"]/,"",line); gsub(/^[[:space:]]+/,"",line)
      L=tolower(line)
      nl=split(L, tl, /[[:space:]()]+/)   # 소문자 토큰(키워드용)
      no=split(line, to, /[[:space:]()]+/) # 원문 토큰(식별자용)
    }
    (tl[1]=="create" && tl[2]=="table") {
      i=3; if (tl[3]=="if" && tl[4]=="not" && tl[5]=="exists") i=6
      t=strip(to[i]); sub(/^.*\./,"",t)
      table=t; intable=1
      printf "TABLE\t%s\t%s:%d\n", t, FILENAME, FNR
      next
    }
    intable && L ~ /^[[:space:]]*\)/ { intable=0; next }
    intable {
      # FK: "FOREIGN KEY (col) REFERENCES p(id)" 또는
      # "CONSTRAINT x FOREIGN KEY (col) REFERENCES p(id)" — foreign+key 가 어디에
      # 있든 잡는다(앞에 CONSTRAINT 가 있어도).
      has_fk=0; fkcol=""; ref=""
      for (k=1;k<nl;k++) if (tl[k]=="foreign" && tl[k+1]=="key") has_fk=1
      if (has_fk) {
        for (k=1;k<=nl;k++) {
          if (tl[k]=="key" && fkcol=="") fkcol=strip(to[k+1])
          if (tl[k]=="references") ref=strip(to[k+1])
        }
        sub(/^.*\./,"",ref)
        if (fkcol!="" && ref!="") printf "FK\t%s\t%s\t%s\t%s:%d\n", table, fkcol, ref, FILENAME, FNR
        next
      }
      # 제약/인덱스 키워드(CHECK 포함) 는 컬럼이 아니라 IDX 로 — CHECK 가 컬럼명으로
      # 오분류되던 문제 수정.
      if (tl[1]=="primary"||tl[1]=="unique"||tl[1]=="key"||tl[1]=="index"||tl[1]=="constraint"||tl[1]=="check") {
        line2=line; gsub(/^[[:space:]]+/,"",line2)
        printf "IDX\t%s\t%s\t%s:%d\n", table, line2, FILENAME, FNR; next
      }
      # 일반 컬럼 정의: 첫 토큰이 식별자
      if (to[1] ~ /^[A-Za-z_][A-Za-z0-9_]*$/) {
        printf "COL\t%s\t%s\t%s\t%s:%d\n", table, strip(to[1]), strip(to[2]), FILENAME, FNR
        # 인라인 REFERENCES: col TYPE REFERENCES parent(id)
        for (k=1;k<=nl;k++) if (tl[k]=="references") {
          ref=strip(to[k+1]); sub(/^.*\./,"",ref)
          if (ref!="") printf "FK\t%s\t%s\t%s\t%s:%d\n", table, strip(to[1]), ref, FILENAME, FNR
          break
        }
      }
    }
  ' "$@"
}

erd_from_prisma() { # args: schema.prisma files
  awk '
    /^model[[:space:]]/ { model=$2; printf "TABLE\t%s\t%s:%d\n", model, FILENAME, FNR; next }
    /^\}/ { model=""; next }
    model != "" {
      line=$0; gsub(/^[[:space:]]+/, "", line)
      if (line == "" || line ~ /^\/\//) next
      if (line ~ /^@@/) { printf "IDX\t%s\t%s\t%s:%d\n", model, line, FILENAME, FNR; next }
      split(line, a, /[[:space:]]+/)
      fname=a[1]; ftype=a[2]
      # 실 FK 는 @relation(fields: [...]) 를 가진 소유측만 — fields: 없는 역방향
      # 관계(예: posts Post[] @relation("...")) 는 빈 FK 를 만들지 않고 건너뛴다.
      if (line ~ /@relation\(/ && line ~ /fields:[[:space:]]*\[/) {
        match(line, /fields:[[:space:]]*\[[A-Za-z0-9_, ]+\]/)
        fk=substr(line, RSTART, RLENGTH); sub(/fields:[[:space:]]*\[/, "", fk); sub(/\]/, "", fk)
        gsub(/[[:space:]]/, "", fk)   # 콤마 구분 다중 필드도 그대로 보존
        reftype=ftype; gsub(/[\[\]?]/, "", reftype)
        printf "FK\t%s\t%s\t%s\t%s:%d\n", model, fk, reftype, FILENAME, FNR
        next
      }
      # 배열/모델타입 필드(역방향 관계)는 컬럼 아님
      if (ftype ~ /^[A-Z]/ && ftype ~ /\[\]$/) next
      if (fname != "" && ftype != "")
        printf "COL\t%s\t%s\t%s\t%s:%d\n", model, fname, ftype, FILENAME, FNR
    }
  ' "$@"
}

erd_from_jpa() { # args: entity .java/.kt files
  awk '
    FNR == 1 { entity=""; table=""; pend_rel=0; pend_line=0; reltype="" }
    /@Table/ {
      if (match($0, /name[[:space:]]*=[[:space:]]*"[^"]*"/)) {
        t=substr($0, RSTART, RLENGTH); sub(/name[[:space:]]*=[[:space:]]*"/, "", t); sub(/"$/, "", t)
        table=t
      }
    }
    /@Entity/ { seen_entity=1 }
    /(public|internal)?[[:space:]]*class[[:space:]]+[A-Za-z0-9_]+/ && entity == "" {
      match($0, /class[[:space:]]+[A-Za-z0-9_]+/); c=substr($0, RSTART+6, RLENGTH-6)
      gsub(/^[[:space:]]+/, "", c)
      entity=c
      if (table == "") table=c
      printf "TABLE\t%s\t%s:%d\n", table, FILENAME, FNR
    }
    /@(ManyToOne|OneToOne)/ { pend_rel=1; next }
    pend_rel && /@JoinColumn/ {
      if (match($0, /name[[:space:]]*=[[:space:]]*"[^"]*"/)) {
        jc=substr($0, RSTART, RLENGTH); sub(/name[[:space:]]*=[[:space:]]*"/, "", jc); sub(/"$/, "", jc)
        pendcol=jc; pend_line=FNR
      }
      next
    }
    pend_rel && /private[[:space:]]+[A-Za-z0-9_<>]+[[:space:]]+[A-Za-z0-9_]+;/ {
      split($0, a, /[[:space:]]+/)
      for (i=1; i<=length(a); i++) if (a[i]=="private") { reltype=a[i+1]; break }
      if (pendcol == "") pendcol="(join column unknown)"
      printf "FK\t%s\t%s\t%s\t%s:%d\n", table, pendcol, reltype, FILENAME, FNR
      pend_rel=0; pendcol=""; next
    }
    /private[[:space:]]+[A-Za-z0-9_<>]+[[:space:]]+[A-Za-z0-9_]+;/ && entity != "" && !pend_rel {
      if ($0 ~ /(List|Set|Collection)</) next
      split($0, a, /[[:space:]]+/)
      for (i=1; i<=length(a); i++) if (a[i]=="private") { ftype=a[i+1]; fname=a[i+2]; break }
      sub(/;$/, "", fname)
      printf "COL\t%s\t%s\t%s\t%s:%d\n", table, fname, ftype, FILENAME, FNR
    }
  ' "$@"
}

render_erd_md() { # stdin: TSV rows -> mermaid + 근거 표
  awk -F'\t' '
    $1 == "TABLE" { tables[$2]=$3; order[++n]=$2 }
    $1 == "COL" {
      t=$4; gsub(/\(.*/, "", t); gsub(/[^A-Za-z0-9_]/, "", t)  # mermaid-safe type
      if (t == "") t="unknown"
      cols[$2] = cols[$2] "    " t " " $3 "\n"; src[$2":"$3]=$5
    }
    $1 == "FK" { fks[++f] = $2 "\t" $3 "\t" $4 "\t" $5 }
    $1 == "IDX" { idx[$2] = idx[$2] "- `" $3 "` (" $4 ")\n" }
    END {
      print "```mermaid"
      print "erDiagram"
      for (i=1; i<=n; i++) {
        t=order[i]
        printf "  %s {\n%s  }\n", t, cols[t]
      }
      for (i=1; i<=f; i++) {
        split(fks[i], a, "\t")
        # child }o--|| parent : "fk_col"
        printf "  %s }o--|| %s : \"%s\"\n", a[1], a[3], a[2]
      }
      print "```"
      print ""
      print "## 근거 (file:line)"
      print ""
      print "| table | source |"
      print "|---|---|"
      for (i=1; i<=n; i++) printf "| %s | %s |\n", order[i], tables[order[i]]
      print ""
      if (f > 0) {
        print "| FK (child.col → parent) | source |"
        print "|---|---|"
        for (i=1; i<=f; i++) {
          split(fks[i], a, "\t")
          printf "| %s.%s → %s | %s |\n", a[1], a[2], a[3], a[4]
        }
        print ""
      }
      print "## 인덱스/제약"
      print ""
      for (t in idx) { printf "### %s\n%s\n", t, idx[t] }
    }
  '
}

collect_erd_rows() {
  local sources kind path
  local -a sql_files=() prisma_files=() jpa_files=()
  sources="$(detect_schema_sources)"
  # newline-분리 목록을 배열로 — 공백 포함 파일명이 word-split 되지 않게 한다.
  while IFS="$(printf '\t')" read -r kind path; do
    [ -z "${path}" ] && continue
    case "${kind}" in
      sql-migration) sql_files+=("${path}") ;;
      prisma) prisma_files+=("${path}") ;;
      jpa-entity) jpa_files+=("${path}") ;;
    esac
  done <<EOF
${sources}
EOF
  # 우선순위: 마이그레이션 SQL(가장 권위) > ORM 스키마.
  if [ "${#sql_files[@]}" -gt 0 ]; then
    erd_from_sql "${sql_files[@]}"
  elif [ "${#prisma_files[@]}" -gt 0 ]; then
    erd_from_prisma "${prisma_files[@]}"
  elif [ "${#jpa_files[@]}" -gt 0 ]; then
    erd_from_jpa "${jpa_files[@]}"
  fi
}

live_schema_diff() { # $1: live tsv (table<TAB>column<TAB>type), stdin: erd rows
  local live="$1" tmp_code tmp_live
  tmp_code="$(mktemp)"; tmp_live="$(mktemp)"
  awk -F'\t' '$1=="COL" {print tolower($2) "." tolower($3)}' | LC_ALL=C sort -u > "${tmp_code}"
  awk -F'\t' 'NF>=2 {print tolower($1) "." tolower($2)}' "${live}" | LC_ALL=C sort -u > "${tmp_live}"
  echo "## 코드 ERD ↔ 실 DB 스키마 diff"
  echo ""
  echo "실 DB 에만 있는 컬럼 (코드 추정에 없음 — unknowns 후보):"
  echo '```'
  LC_ALL=C comm -13 "${tmp_code}" "${tmp_live}"
  echo '```'
  echo "코드에만 있는 컬럼 (실 DB 에 없음 — dead schema 또는 미적용 마이그레이션):"
  echo '```'
  LC_ALL=C comm -23 "${tmp_code}" "${tmp_live}"
  echo '```'
  rm -f "${tmp_code}" "${tmp_live}"
}

cmd_scan() {
  parse_flags "$@"
  local sanity fw entries routes envs schemas ftotal files_total erd_rows
  echo "sfs dig scan — L0 deterministic scan (zero LLM tokens)" >&2
  sanity="$(run_sanity_precheck)"
  fw="$(detect_frameworks)"
  entries="$(detect_entrypoints)"
  routes="$(detect_routes)"
  envs="$(detect_env_keys)"
  schemas="$(detect_schema_sources)"
  ftotal="$(count_functions)"
  files_total="$(src_files | wc -l | tr -d '[:space:]')"

  {
    echo "---"
    echo "doc_id: excavation-scan-$(domain_slug)"
    echo "title: \"L0 scan — $(domain_slug)\""
    echo "doc_type: excavation-artifact"
    echo "generated_by: sfs dig scan (deterministic)"
    echo "---"
    echo ""
    echo "# L0 scan — $(domain_slug)"
    echo ""
    echo "- source files: ${files_total} / approx function defs: ${ftotal}"
    echo "- sanity precheck: ${sanity} (harness doctor; L2 gate input)"
    echo ""
    echo "## Frameworks"
    echo '```'
    printf '%s\n' "${fw:-"(none detected)"}"
    echo '```'
    echo "## Entrypoints"
    echo '```'
    printf '%s\n' "${entries:-"(none detected)"}"
    echo '```'
    echo "## Routes"
    echo '```'
    printf '%s\n' "${routes:-"(none detected)"}"
    echo '```'
    echo "## Config / env keys (names only — values are never recorded)"
    echo '```'
    printf '%s\n' "${envs:-"(none detected)"}"
    echo '```'
    echo "## Schema sources"
    echo '```'
    printf '%s\n' "${schemas:-"(none detected)"}"
    echo '```'
  } | emit "00-scan.md"

  erd_rows="$(collect_erd_rows)"
  if [ -n "${erd_rows}" ]; then
    {
      echo "---"
      echo "doc_id: excavation-erd-$(domain_slug)"
      echo "title: \"ERD (code-derived) — $(domain_slug)\""
      echo "doc_type: excavation-artifact"
      echo "generated_by: sfs dig scan (deterministic)"
      echo "---"
      echo ""
      echo "# ERD (code-derived) — $(domain_slug)"
      echo ""
      printf '%s\n' "${erd_rows}" | render_erd_md
    } | emit "erd.md"
  else
    echo "  no parsable schema source (sql-migration/prisma/jpa) — erd.md skipped" >&2
  fi

  if [ -n "${LIVE_SCHEMA}" ] && [ -f "${LIVE_SCHEMA}" ]; then
    {
      echo "---"
      echo "doc_id: excavation-erd-diff-$(domain_slug)"
      echo "title: \"ERD diff (code vs live schema) — $(domain_slug)\""
      echo "doc_type: excavation-artifact"
      echo "generated_by: sfs dig scan --live-schema (deterministic; structure only)"
      echo "---"
      echo ""
      printf '%s\n' "${erd_rows}" | live_schema_diff "${LIVE_SCHEMA}"
    } | emit "erd-diff.md"
  fi

  if [ "${WRITE}" = "1" ]; then
    state_set "sanity_result" "${sanity}"
    state_set "function_total" "${ftotal}"
    state_set "files_total" "${files_total}"
    [ -n "${WAIVE_SANITY}" ] && state_set "sanity_waiver" "${WAIVE_SANITY}"
    state_set "scan_commit" "$(git rev-parse --short HEAD 2>/dev/null || echo 'no-git')"
  fi
  echo "scan done (sanity=${sanity})" >&2
}

# ── L1: graph + L2 queue ────────────────────────────────────────────
import_edges() {
  # stdout: from<TAB>to (repo-relative, resolved best-effort)
  local files tmp_all
  tmp_all="$(mktemp)"
  src_files > "${tmp_all}"
  # JS/TS relative imports
  grep -rn -E "(require\(|from )['\"]\.\.?/" --include='*.js' --include='*.ts' --include='*.tsx' . 2>/dev/null \
    | grep -v node_modules | sed 's|^\./||' | while IFS=: read -r f _ line; do
      rel="$(printf '%s' "${line}" | sed -nE "s/.*['\"](\.{1,2}\/[^'\"]*)['\"].*/\1/p")"
      [ -z "${rel}" ] && continue
      base="$(dirname "${f}")/${rel}"
      # normalize ../ and ./ via cd (read-only)
      norm="$(cd "$(dirname "${base}")" 2>/dev/null && pwd)/$(basename "${base}")"
      norm="${norm#"$PWD"/}"
      for cand in "${norm}" "${norm}.js" "${norm}.ts" "${norm}/index.js" "${norm}/index.ts"; do
        if grep -qx "${cand}" "${tmp_all}"; then printf '%s\t%s\n' "${f}" "${cand}"; break; fi
      done
    done
  # Java imports: import a.b.ClassName; -> find ClassName.java
  grep -rn -E '^import [a-z0-9_.]+\.[A-Z][A-Za-z0-9_]*;' --include='*.java' . 2>/dev/null \
    | sed 's|^\./||' | while IFS=: read -r f _ line; do
      cls="$(printf '%s' "${line}" | sed -n 's/^import .*\.\([A-Z][A-Za-z0-9_]*\);$/\1/p')"
      [ -z "${cls}" ] && continue
      to="$(grep -m1 "/${cls}\.java$" "${tmp_all}" || true)"
      [ -n "${to}" ] && printf '%s\t%s\n' "${f}" "${to}"
    done
  # Python relative-ish imports: from x.y import / import x.y -> x/y.py
  grep -rn -E '^(from|import) [a-z_][a-z0-9_.]*' --include='*.py' . 2>/dev/null \
    | sed 's|^\./||' | while IFS=: read -r f _ line; do
      mod="$(printf '%s' "${line}" | sed -n 's/^\(from\|import\) \([a-z_][a-z0-9_.]*\).*/\2/p' | tr '.' '/')"
      [ -z "${mod}" ] && continue
      for cand in "${mod}.py" "${mod}/__init__.py"; do
        if grep -qx "${cand}" "${tmp_all}"; then printf '%s\t%s\n' "${f}" "${cand}"; break; fi
      done
    done
  rm -f "${tmp_all}"
}

cmd_graph() {
  parse_flags "$@"
  local edges routes entries tmp_edges tmp_visit tmp_queue queue_gate sanity waiver erd_rows
  echo "sfs dig graph — L1 static graph, grep reduced mode (zero LLM tokens)" >&2
  edges="$(import_edges | LC_ALL=C sort -u)"
  routes="$(detect_routes)"
  entries="$(detect_entrypoints | awk -F'\t' '{print $1}' | sed 's/:.*//' )"
  erd_rows="$(collect_erd_rows)"

  # entity file -> table name map (JPA 엔티티에서 직접; ERD 소스 우선순위와 무관)
  local tmp_entity_map jpa_path
  local -a jpa_entity_files=()
  tmp_entity_map="$(mktemp)"
  while IFS= read -r jpa_path; do
    [ -n "${jpa_path}" ] && jpa_entity_files+=("${jpa_path}")
  done <<EOF
$(detect_schema_sources | awk -F'\t' '$1=="jpa-entity" {print $2}')
EOF
  if [ "${#jpa_entity_files[@]}" -gt 0 ]; then
    erd_from_jpa "${jpa_entity_files[@]}" | awk -F'\t' '$1=="TABLE" {split($3, a, ":"); print a[1] "\t" $2}' > "${tmp_entity_map}"
  fi

  # route -> handler-file -> imported services -> tables touched (heuristic, deterministic)
  local chains=""
  chains="$(printf '%s\n' "${routes}" | while IFS=$'\t' read -r loc kind sig; do
    [ -z "${loc}" ] && continue
    rfile="${loc%%:*}"
    svc="$(printf '%s\n' "${edges}" | awk -F'\t' -v f="${rfile}" '$1==f && ($2 ~ /[Ss]ervice/) {print $2}' | tr '\n' ' ')"
    tbls=""
    for s in ${svc}; do
      # service -> (repository ->) entity: 2-hop 추적 후 entity->table 매핑
      hop1="$(printf '%s\n' "${edges}" | awk -F'\t' -v f="${s}" '$1==f {print $2}')"
      hop2="$(printf '%s\n' "${hop1}" | while read -r d; do
        [ -n "${d}" ] && printf '%s\n' "${edges}" | awk -F'\t' -v f="${d}" '$1==f {print $2}'
      done)"
      t1="$(printf '%s\n%s\n' "${hop1}" "${hop2}" | awk 'NF' | while read -r d; do
        awk -F'\t' -v f="${d}" '$1==f {print $2}' "${tmp_entity_map}"
      done | LC_ALL=C sort -u | tr '\n' ' ')"
      t2="$(grep -oE 'prisma\.[a-zA-Z]+\.' "${s}" 2>/dev/null | sed 's/prisma\.//;s/\.$//' | LC_ALL=C sort -u | tr '\n' ' ')"
      tbls="${tbls}${t1}${t2}"
    done
    printf '| %s | %s | %s | %s |\n' "${loc}" "${sig}" "${svc:-—}" "${tbls:-—}"
  done)"
  rm -f "${tmp_entity_map}"

  # BFS from entrypoints + route files over import edges
  tmp_edges="$(mktemp)"; tmp_visit="$(mktemp)"; tmp_queue="$(mktemp)"
  printf '%s\n' "${edges}" > "${tmp_edges}"
  { printf '%s\n' "${entries}"; printf '%s\n' "${routes}" | awk -F'\t' '{print $1}' | sed 's/:[0-9]*$//'; } \
    | awk 'NF' | LC_ALL=C sort -u > "${tmp_queue}"
  : > "${tmp_visit}"
  local depth=0 frontier next
  frontier="$(cat "${tmp_queue}")"
  while [ -n "${frontier}" ] && [ "${depth}" -lt 30 ]; do
    printf '%s\n' "${frontier}" | while read -r n; do
      [ -z "${n}" ] && continue
      grep -qxF "${n}" "${tmp_visit}" 2>/dev/null || printf '%s\t%s\n' "${depth}" "${n}" >> "${tmp_visit}"
    done
    next="$(printf '%s\n' "${frontier}" | while read -r n; do
      awk -F'\t' -v f="${n}" '$1==f {print $2}' "${tmp_edges}"
    done | LC_ALL=C sort -u | while read -r c; do
      awk -F'\t' '{print $2}' "${tmp_visit}" | grep -qxF "${c}" || printf '%s\n' "${c}"
    done)"
    frontier="${next}"
    depth=$((depth + 1))
  done
  # dead-code candidates: source files never visited
  local dead
  dead="$(src_files | while read -r f; do
    awk -F'\t' '{print $2}' "${tmp_visit}" | grep -qxF "${f}" || printf '%s\n' "${f}"
  done)"

  # L2 gate: sanity pass 또는 waiver 없으면 큐 헤더에 NOT-READY 마킹 (signal-only —
  # 파일은 항상 쓰되 순서 규율 위반을 명시적으로 드러낸다. ALT-INV-3: 차단 아님.)
  sanity="$(state_get sanity_result)"
  waiver="$(state_get sanity_waiver)"
  [ -f ".sfs-local/readiness-waiver" ] && waiver="${waiver:-.sfs-local/readiness-waiver}"
  if [ "${sanity}" = "pass" ] || [ -n "${waiver}" ]; then
    queue_gate="READY (sanity=${sanity:-unknown}${waiver:+, waiver: ${waiver}})"
  else
    queue_gate="NOT-READY (sanity=${sanity:-not-run} — run 'sfs dig scan --write' first; pass Sanity or record a waiver before dispatching L2 capsules)"
  fi

  {
    echo "---"
    echo "doc_id: excavation-graph-$(domain_slug)"
    echo "title: \"L1 static graph — $(domain_slug)\""
    echo "doc_type: excavation-artifact"
    echo "generated_by: sfs dig graph (deterministic, grep reduced mode)"
    echo "---"
    echo ""
    echo "# L1 static graph — $(domain_slug)"
    echo ""
    echo "External graph tools (tree-sitter/madge/jdeps) are opt-in enrichment;"
    echo "this artifact is the reduced grep/regex mode and is complete without them."
    echo ""
    echo "## Route → handler → service → table"
    echo ""
    echo "| route (file:line) | signature | services | tables |"
    echo "|---|---|---|---|"
    printf '%s\n' "${chains:-"| — | — | — | — |"}"
    echo ""
    echo "## Import edges (from → to)"
    echo '```'
    printf '%s\n' "${edges:-"(none resolved)"}"
    echo '```'
    echo "## Dead-code candidates (unreachable from entrypoints/routes)"
    echo '```'
    printf '%s\n' "${dead:-"(none)"}"
    echo '```'
  } | emit "graph.md"

  {
    echo "---"
    echo "doc_id: excavation-l2-queue-$(domain_slug)"
    echo "title: \"L2 traversal queue — $(domain_slug)\""
    echo "doc_type: excavation-artifact"
    echo "generated_by: sfs dig graph (deterministic)"
    echo "---"
    echo ""
    echo "# L2 traversal queue — $(domain_slug)"
    echo ""
    echo "L2-GATE: ${queue_gate}"
    echo ""
    echo "BFS order from entrypoints/routes (depth asc); dead-code candidates last."
    echo "One capsule per file/module; fact-card schema and validator:"
    echo "\`sfs dig card validate\` (see routed context commands/dig.md)."
    echo ""
    LC_ALL=C sort -n "${tmp_visit}" | awk -F'\t' '{printf "- [ ] depth=%s %s\n", $1, $2}'
    printf '%s\n' "${dead}" | awk 'NF {printf "- [ ] dead-code-candidate %s\n", $0}'
  } | emit "l2-queue.md"

  rm -f "${tmp_edges}" "${tmp_visit}" "${tmp_queue}"
  echo "graph done (gate: ${queue_gate})" >&2
}

# ── L2: capsule 발행 헬퍼 (결정론) ────────────────────────────────────
CAPSULE_NEXT=0
CAPSULE_TARGET=""

parse_capsule_flags() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --domain) DOMAIN="${2:-}"; shift 2 ;;
      --write) WRITE=1; shift ;;
      --next) CAPSULE_NEXT=1; shift ;;
      --target) CAPSULE_TARGET="${2:-}"; shift 2 ;;
      *) echo "unknown flag: $1" >&2; exit 2 ;;
    esac
  done
}

first_valid_card() { # stdout: repo-relative path of first validator-PASS card, or nothing
  local dir="$(exc_dir)/cards" f
  [ -d "${dir}" ] || return 0
  for f in "${dir}"/*.md; do
    [ -f "$f" ] || continue
    if validate_card "$f" >/dev/null 2>&1; then printf '%s\n' "$f"; return 0; fi
  done
  return 0
}

cmd_capsule() {
  parse_capsule_flags "$@"
  local queue dir target slug edges_block scope exemplar gate budget timeout
  dir="$(exc_dir)"
  queue="${dir}/l2-queue.md"
  [ -f "${queue}" ] || { echo "no l2-queue.md — run: sfs dig graph --write" >&2; exit 3; }

  # L2 게이트 강제 지점: 캡슐 발행은 순서 규율의 집행점이다. NOT-READY 면 발행을
  # 거부하고 waiver 경로를 안내한다 (act-directly 계열 exit 3 — dig 밖 명령은
  # 아무것도 막지 않는다; ALT-INV-3 유지).
  gate="$(grep -m1 '^L2-GATE:' "${queue}" || echo 'L2-GATE: unknown')"
  case "${gate}" in
    "L2-GATE: READY"*) : ;;
    *)
      echo "capsule refused — ${gate}" >&2
      echo "record a waiver first: sfs dig scan --write --waive-sanity \"<reason>\" && sfs dig graph --write" >&2
      exit 3
      ;;
  esac

  if [ "${CAPSULE_NEXT}" = "1" ] && [ -n "${CAPSULE_TARGET}" ]; then
    echo "capsule: pass either --next or --target, not both" >&2; exit 2
  fi
  if [ -n "${CAPSULE_TARGET}" ]; then
    target="${CAPSULE_TARGET}"
    # 임의 경로·traversal 거부: --target 은 반드시 열린 큐 항목이어야 한다.
    case "${target}" in
      /*|*..*) echo "capsule: --target must be a repo-relative path inside the queue (no absolute/.. paths): ${target}" >&2; exit 2 ;;
    esac
    # 큐 항목의 파일 경로만 뽑아 고정 문자열 비교 — 경로의 정규식 메타문자
    # (`[id].js` 등)가 매칭을 깨거나 오탐하지 않도록 grep -Fx 를 쓴다 (재리뷰 #4).
    if ! sed -nE 's/^- \[ \] (depth=[0-9]+|dead-code-candidate) //p' "${queue}" | grep -Fxq -- "${target}"; then
      echo "capsule: --target '${target}' is not an open l2-queue item — pick one from ${queue}" >&2; exit 3
    fi
  else
    target="$(grep -m1 -E '^- \[ \] (depth=[0-9]+|dead-code-candidate) ' "${queue}" | sed -E 's/^- \[ \] (depth=[0-9]+|dead-code-candidate) //')"
  fi
  [ -n "${target}" ] || { echo "l2-queue has no open item (or pass --target <file>)" >&2; exit 3; }
  slug="$(printf '%s' "${target}" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-' | sed 's/-*$//;s/^-*//')"

  # files_scope = target + 직접 의존(그래프 import edges) + 직접 피의존
  edges_block="$(sed -n '/^## Import edges/,/^## /p' "${dir}/graph.md" 2>/dev/null | grep -E '^[^#`]' || true)"
  scope="$(printf '%s\n' "${target}"; printf '%s\n' "${edges_block}" | awk -F'\t' -v t="${target}" '$1==t {print $2} $2==t {print $1}')"
  scope="$(printf '%s\n' "${scope}" | awk 'NF' | LC_ALL=C sort -u)"
  exemplar="$(first_valid_card)"
  budget="${SFS_DIG_CAPSULE_TOKEN_BUDGET:-8000}"
  timeout="${SFS_DIG_CAPSULE_TIMEOUT:-15m}"

  {
    echo "---"
    echo "capsule_id: dig-card-${slug}"
    echo "generated_by: sfs dig capsule (deterministic)"
    echo "---"
    echo ""
    echo "# L2 fact-card capsule — ${target}"
    echo ""
    echo "goal: Write one fact card for \`${target}\` that passes \`sfs dig card validate\`."
    echo ""
    echo "acceptance_criteria:"
    echo "- card exists at the output path and \`sfs dig card validate <card> --root .\` exits 0"
    echo "- every narrative claim cites file:line evidence inside files_scope"
    echo "- confidence is an honest 0-2 self-rating; low confidence goes to unknowns, not prose padding"
    echo "- if the territory contradicts this capsule's assumptions, make the conservative choice and record it under a \`## Deviations\` heading in the card (unknowns-and-deviations DEVIATIONS_LOG)"
    echo ""
    echo "files_scope:"
    printf '%s\n' "${scope}" | awk '{print "- " $0}'
    echo ""
    echo "tools_allowed: read-only file access within files_scope + \`sfs dig card validate\`. No edits outside output_paths, no network, no credentials."
    echo ""
    echo "output_paths:"
    echo "- $(exc_dir)/cards/${slug}.md"
    echo ""
    echo "token_budget: ${budget} (warn-before-block: surface a threshold warning at ~75/90% and decide refine/pivot/halt — do not run to the cap)"
    echo "timeout: ${timeout}"
    echo "pii_rules: never copy env values, credentials, or data rows into the card — key names and schema structure only."
    if [ -n "${exemplar}" ]; then
      echo "exemplar: ${exemplar} (validator-PASS card — imitate its shape)"
    else
      echo "# exemplar: none yet — first card of this excavation (omission is allowed by the capsule contract)"
    fi
  } | emit "capsules/${slug}.capsule.md"
  echo "capsule ready (target: ${target})" >&2
}

# ── card validator + 확증 상태 머신 ───────────────────────────────────
validate_card() { # $1: card file. echoes verdict line; returns 0/1
  local f="$1" reason="" conf evid_files evid_count runtime_count sec state
  [ -f "${f}" ] || { echo "REJECT ${f}: file not found"; return 1; }
  head -1 "${f}" | grep -q '^---$' || { echo "REJECT ${f}: missing frontmatter"; return 1; }
  grep -q '^card_id:' "${f}" || { echo "REJECT ${f}: missing card_id"; return 1; }
  grep -q '^target:' "${f}" || { echo "REJECT ${f}: missing target"; return 1; }
  conf="$(sed -n 's/^confidence:[[:space:]]*//p' "${f}" | head -1)"
  case "${conf}" in 0|1|2) : ;; *) echo "REJECT ${f}: confidence must be 0|1|2 (got '${conf:-none}')"; return 1 ;; esac
  for sec in "## Purpose" "## Inputs/Outputs" "## Side effects" "## Tables" "## Calls" "## Evidence"; do
    grep -q "^${sec}" "${f}" || { echo "REJECT ${f}: missing required section '${sec}'"; return 1; }
  done
  # Evidence 절의 file:line 인용 — 근거 없는 서술은 reject (환각 차단은 검증기 소유)
  evid_files="$(sed -n '/^## Evidence/,/^## /p' "${f}" | grep -oE '[A-Za-z0-9_./-]+\.[A-Za-z0-9]+:[0-9]+' | sed 's/:[0-9]*$//' | LC_ALL=C sort -u)"
  evid_count="$(printf '%s\n' "${evid_files}" | awk 'NF' | wc -l | tr -d '[:space:]')"
  [ "${evid_count}" -ge 1 ] || { echo "REJECT ${f}: Evidence section has no file:line citation — narrative without evidence"; return 1; }
  # 인용 파일 실존 검사 (repo root 기준)
  local missing=""
  while IFS= read -r ef; do
    [ -z "${ef}" ] && continue
    [ -f "${CARD_ROOT}/${ef}" ] || missing="${ef}"
  done <<EOF
${evid_files}
EOF
  [ -z "${missing}" ] || { echo "REJECT ${f}: evidence cites nonexistent file '${missing}'"; return 1; }
  # 확증 상태 파생 (결정론): runtime evidence -> verified; 독립 근거 파일 2+ -> corroborated
  runtime_count="$(sed -n '/^## Runtime evidence/,/^## /p' "${f}" | grep -cE '^[[:space:]]*- ' || true)"
  if [ "${runtime_count:-0}" -ge 1 ]; then state="verified"
  elif [ "${evid_count}" -ge 2 ]; then state="corroborated"
  else state="unverified"; fi
  echo "PASS ${f} state=${state} confidence=${conf} evidence_files=${evid_count}"
  return 0
}

cmd_card() {
  local sub="${1:-}"; shift || true
  case "${sub}" in
    validate)
      local target="${1:-}"; shift || true
      parse_flags "$@"
      [ -n "${target}" ] || { echo "usage: sfs dig card validate <file|dir> [--root <repo-root>]" >&2; exit 2; }
      local rc=0
      if [ -d "${target}" ]; then
        local found=0
        for f in "${target}"/*.md; do
          [ -f "$f" ] || continue
          found=1
          validate_card "$f" || rc=1
        done
        [ "${found}" = "1" ] || { echo "no cards under ${target}" >&2; exit 2; }
      else
        validate_card "${target}" || rc=1
      fi
      exit "${rc}"
      ;;
    *) usage; exit 2 ;;
  esac
}

cmd_status() {
  parse_flags "$@"
  local dir cards total ftotal unv cor ver queue_total queue_dead
  dir="$(exc_dir)"
  echo "sfs dig status — $(domain_slug) (signal-only)"
  [ -d "${dir}" ] || { echo "  no excavation yet — run: sfs dig scan --write"; exit 0; }
  ftotal="$(state_get function_total)"
  echo "  sanity: $(state_get sanity_result || echo '-') / waiver: $(state_get sanity_waiver || echo '-')"
  total=0; unv=0; cor=0; ver=0
  if [ -d "${dir}/cards" ]; then
    for f in "${dir}/cards"/*.md; do
      [ -f "$f" ] || continue
      out="$(validate_card "$f" 2>/dev/null || true)"
      case "${out}" in
        PASS*state=verified*) ver=$((ver+1)); total=$((total+1)) ;;
        PASS*state=corroborated*) cor=$((cor+1)); total=$((total+1)) ;;
        PASS*state=unverified*) unv=$((unv+1)); total=$((total+1)) ;;
        REJECT*) echo "  invalid card: ${out}" ;;
      esac
    done
  fi
  echo "  cards: ${total} (unverified=${unv} corroborated=${cor} verified=${ver})"
  if [ -n "${ftotal}" ] && [ "${ftotal}" -gt 0 ] 2>/dev/null; then
    echo "  coverage: ${total}/${ftotal} function-scale units ($(( total * 100 / ftotal ))%)"
  fi
  if [ -f "${dir}/l2-queue.md" ]; then
    queue_total="$(grep -c '^- \[ \]' "${dir}/l2-queue.md" || true)"
    queue_dead="$(grep -c 'dead-code-candidate' "${dir}/l2-queue.md" || true)"
    echo "  l2-queue: ${queue_total} open items (${queue_dead} dead-code candidates)"
    grep -m1 '^L2-GATE:' "${dir}/l2-queue.md" | sed 's/^/  /'
  fi
}

case "${COMMAND}" in
  scan) cmd_scan "$@" ;;
  graph) cmd_graph "$@" ;;
  capsule) cmd_capsule "$@" ;;
  card) cmd_card "$@" ;;
  status) cmd_status "$@" ;;
  help|-h|--help) usage ;;
  *) usage; exit 2 ;;
esac
