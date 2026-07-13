#!/usr/bin/env bash
# 정적 보안 감사(security audit) 파이프라인의 결정론 코어를 담당한다.
# 운영자 자기 저장소를 read-only 로 스캔해 OWASP 계열 취약점 표면을 표로 낸다.
# LLM 0토큰: 스캔·severity 판정·redaction·재스캔 diff 는 전부 결정론.
# 실행형 익스플로잇 아님 — 정적 위협모델 표면만. 대상 소스는 절대 수정 안 함.
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMMAND="${1:-help}"
[ $# -gt 0 ] && shift

usage() {
  cat <<'EOF'
Usage:
  sfs audit scan   [--domain <name>] [--write] [--lens <name|all>] [--severity-min low|medium|high|critical]
  sfs audit report [--domain <name>]
  sfs audit status [--domain <name>]

Static, read-only security audit of the operator's OWN repository (code ->
finding -> OWASP family). Fully deterministic (zero LLM tokens); the LLM-driven
threat model, exploit-hypothesis (reasoning only, never execution), and fix
proposals are designated points in routed context commands/audit.md.

Lenses (default all): secret | owasp | config | deps | hygiene
  secret  — hardcoded credentials/keys/tokens (values are always redacted)
  owasp   — injection / unsafe-deserialization / XSS static sinks (A03/A08)
  config  — security misconfiguration: debug on, TLS verify off, permissive CORS (A05)
  deps    — dependency posture: manifests, lockfiles, loose pins + the offline
            ecosystem audit command to run yourself (network checks stay manual)
  hygiene — stray debug residue + security-flavored TODO/FIXME (A09 + project issues)

This is a defensive scanner: findings carry verify/fix guidance, never weaponized
exploit steps. All findings are signal-only and never block a command. Writes go
only to docs/solon/<domain>/audit/ under --write (else stdout preview).
EOF
}

DOMAIN=""
WRITE=0
LENS="all"
SEV_MIN="low"

parse_flags() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --domain) DOMAIN="${2:-}"; shift 2 ;;
      --write) WRITE=1; shift ;;
      --lens) LENS="${2:-all}"; shift 2 ;;
      --severity-min) SEV_MIN="${2:-low}"; shift 2 ;;
      *) echo "unknown flag: $1" >&2; exit 2 ;;
    esac
  done
}

domain_slug() {
  if [ -n "${DOMAIN}" ]; then printf '%s' "${DOMAIN}"; else
    basename "$PWD" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9-' '-' | sed 's/-*$//;s/^-*//'
  fi
}

audit_dir() { printf 'docs/solon/%s/audit' "$(domain_slug)"; }

emit() {
  local name="$1"
  if [ "${WRITE}" = "1" ]; then
    mkdir -p "$(dirname "$(audit_dir)/${name}")"
    cat > "$(audit_dir)/${name}"
    echo "  wrote $(audit_dir)/${name}" >&2
  else
    echo "--- ${name} (preview; use --write to save) ---"
    cat
  fi
}

# 스캔 대상 소스 (vendor/빌드/감사산출물 제외). 대상 저장소 read-only.
src_files() {
  find . -type f \( -name '*.java' -o -name '*.kt' -o -name '*.ts' -o -name '*.tsx' \
    -o -name '*.js' -o -name '*.jsx' -o -name '*.py' -o -name '*.rb' -o -name '*.go' \
    -o -name '*.php' -o -name '*.cs' -o -name '*.yml' -o -name '*.yaml' \
    -o -name '*.env' -o -name '*.properties' -o -name '*.xml' -o -name '*.json' \
    -o -name '*.sh' -o -name '*.bash' \) \
    ! -path '*/node_modules/*' ! -path '*/.git/*' ! -path '*/dist/*' \
    ! -path '*/build/*' ! -path '*/target/*' ! -path '*/vendor/*' \
    ! -path '*/.sfs-local/*' ! -path './docs/solon/*' \
    ! -path '*/test/*' ! -path '*/tests/*' ! -path '*/spec/*' \
    ! -path '*/__tests__/*' ! -path '*/fixtures/*' ! -name '*.test.*' \
    ! -name 'sfs-audit.sh' 2>/dev/null | sed 's|^\./||' | LC_ALL=C sort
}

is_test_path() {
  case "$1" in
    *test*|*spec*|*__tests__*|*/fixtures/*|*.example|*.sample) return 0 ;;
    *) return 1 ;;
  esac
}

sev_rank() { case "$1" in critical) echo 4 ;; high) echo 3 ;; medium) echo 2 ;; low) echo 1 ;; *) echo 0 ;; esac; }

# redact <string> : 앞 4자만 남기고 마스킹 — 시크릿 값 원문 노출 금지.
redact() {
  local s="$1" head
  head="$(printf '%s' "${s}" | cut -c1-4)"
  printf '%s…[redacted %d chars]' "${head}" "${#s}"
}

# finding 누적 버퍼: severity<TAB>family<TAB>rule<TAB>file:line<TAB>evidence
FINDINGS=""
add_finding() { FINDINGS="${FINDINGS}$1	$2	$3	$4	$5
"; }

# ── secret lens (A02 Cryptographic Failures / 자격증명 노출) ─────────
scan_secret() {
  local f line ln content m
  while IFS= read -r f; do
    [ -z "${f}" ] && continue
    case "${f}" in *.env) is_test_path "${f}" || add_finding critical "A02" "committed .env file" "${f}:1" "environment file tracked in source" ;; esac
    # 라인 스캔 (grep -n 으로 file:line 확보)
    while IFS=: read -r ln content; do
      [ -z "${ln}" ] && continue
      # AWS access key
      m="$(printf '%s' "${content}" | grep -oE 'AKIA[0-9A-Z]{16}' | head -1)"
      [ -n "${m}" ] && add_finding critical "A02" "AWS access key id" "${f}:${ln}" "$(redact "${m}")"
      # GitHub token
      m="$(printf '%s' "${content}" | grep -oE '(ghp|gho|ghs|ghr)_[A-Za-z0-9]{36}' | head -1)"
      [ -n "${m}" ] && add_finding critical "A02" "GitHub token" "${f}:${ln}" "$(redact "${m}")"
      # Slack token
      m="$(printf '%s' "${content}" | grep -oE 'xox[baprs]-[A-Za-z0-9-]{10,}' | head -1)"
      [ -n "${m}" ] && add_finding critical "A02" "Slack token" "${f}:${ln}" "$(redact "${m}")"
      # private key block
      printf '%s' "${content}" | grep -qE 'BEGIN [A-Z ]*PRIVATE KEY' \
        && add_finding critical "A02" "private key material" "${f}:${ln}" "PEM private key block in source"
      # generic assigned secret (redact value)
      m="$(printf '%s' "${content}" | grep -oiE '(api[_-]?key|secret|passwo?rd|access[_-]?token|auth[_-]?token)["'"'"' ]*[=:][ ]*["'"'"'][^"'"'"']{8,}["'"'"']' | head -1)"
      if [ -n "${m}" ]; then
        local val
        val="$(printf '%s' "${m}" | sed -E 's/.*["'"'"']([^"'"'"']{8,})["'"'"']$/\1/')"
        case "${val}" in
          *'${'*|*'process.env'*|*'os.environ'*|*'System.getenv'*|CHANGE*|change*|xxx*|XXX*|your-*|placeholder*|example*) : ;;
          *) is_test_path "${f}" || add_finding high "A02" "hardcoded secret assignment" "${f}:${ln}" "$(redact "${val}")" ;;
        esac
      fi
    done <<EOF
$(grep -niE 'AKIA[0-9A-Z]{16}|(ghp|gho|ghs|ghr)_[A-Za-z0-9]{36}|xox[baprs]-|BEGIN [A-Z ]*PRIVATE KEY|(api[_-]?key|secret|passwo?rd|access[_-]?token|auth[_-]?token)["'"'"' ]*[=:]' "${f}" 2>/dev/null)
EOF
  done <<EOF
$(src_files)
EOF
}

# ── owasp lens (A03 Injection / A08 Integrity) ──────────────────────
scan_owasp() {
  local f ln content
  while IFS= read -r f; do
    [ -z "${f}" ] && continue
    is_test_path "${f}" && continue
    while IFS=: read -r ln content; do
      [ -z "${ln}" ] && continue
      # command execution with interpolation (exec/system call whose argument is concatenated)
      printf '%s' "${content}" | grep -qE '(child_process\.(exec|execSync)\(|[A-Za-z_][A-Za-z0-9_]*\.exec(Sync)?\([^)]*\+|Runtime\.getRuntime\(\)\.exec\(|os\.system\(|subprocess\.(call|run|Popen)\([^)]*shell[[:space:]]*=[[:space:]]*True)' \
        && add_finding high "A03" "command execution sink" "${f}:${ln}" "shell/exec call — verify input is not attacker-controlled"
      # eval
      printf '%s' "${content}" | grep -qE '(^|[^A-Za-z_])eval\(' \
        && add_finding high "A03" "eval() dynamic execution" "${f}:${ln}" "eval on runtime data — verify source is trusted"
      # SQL string concatenation
      printf '%s' "${content}" | grep -qiE '(select|insert|update|delete)[^;]*"[[:space:]]*\+|execute\([^)]*\+|query\([^)]*\+[^)]*(req|param|input|user)' \
        && add_finding high "A03" "possible SQL injection (string concat)" "${f}:${ln}" "SQL built by concatenation — prefer parameterized queries"
      # unsafe deserialization (yaml.load with an explicit safe loader is excluded)
      if printf '%s' "${content}" | grep -qE '(pickle\.loads|yaml\.load\(|ObjectInputStream|unserialize\(|Marshal\.load)'; then
        printf '%s' "${content}" | grep -qE 'yaml\.load\(' && printf '%s' "${content}" | grep -qE '(SafeLoader|Loader[[:space:]]*=)' \
          || add_finding high "A08" "unsafe deserialization" "${f}:${ln}" "deserializing untrusted data — use a safe loader/allowlist"
      fi
      # XSS sinks
      printf '%s' "${content}" | grep -qE '(dangerouslySetInnerHTML|\.innerHTML[[:space:]]*=|v-html=)' \
        && add_finding medium "A03" "XSS sink (raw HTML injection)" "${f}:${ln}" "raw HTML from data — escape or sanitize"
    done <<EOF
$(grep -nE 'child_process\.(exec|execSync)\(|\.exec(Sync)?\([^)]*\+|Runtime\.getRuntime\(\)\.exec\(|os\.system\(|subprocess\.(call|run|Popen)\(|(^|[^A-Za-z_])eval\(|(select|insert|update|delete)[^;]*"[[:space:]]*\+|execute\([^)]*\+|query\([^)]*\+|pickle\.loads|yaml\.load\(|ObjectInputStream|unserialize\(|Marshal\.load|dangerouslySetInnerHTML|\.innerHTML[[:space:]]*=|v-html=' "${f}" 2>/dev/null)
EOF
  done <<EOF
$(src_files)
EOF
}

# ── config lens (A05 Security Misconfiguration) ─────────────────────
scan_config() {
  local f ln content
  while IFS= read -r f; do
    [ -z "${f}" ] && continue
    is_test_path "${f}" && continue
    while IFS=: read -r ln content; do
      [ -z "${ln}" ] && continue
      printf '%s' "${content}" | grep -qiE '(DEBUG[[:space:]]*=[[:space:]]*True|debug:[[:space:]]*true|app\.debug[[:space:]]*=[[:space:]]*True)' \
        && add_finding medium "A05" "debug mode enabled" "${f}:${ln}" "debug flag on — must be off in production builds"
      printf '%s' "${content}" | grep -qE '(verify[[:space:]]*=[[:space:]]*False|rejectUnauthorized:[[:space:]]*false|InsecureSkipVerify:[[:space:]]*true|strictSSL:[[:space:]]*false|CURLOPT_SSL_VERIFYPEER[^)]*(0|false))' \
        && add_finding high "A05" "TLS certificate verification disabled" "${f}:${ln}" "disabled cert verification — enables MITM"
      printf '%s' "${content}" | grep -qE "(Access-Control-Allow-Origin[\"': ]*\*|origin:[[:space:]]*['\"]\*['\"]|origin:[[:space:]]*true)" \
        && add_finding medium "A05" "permissive CORS (wildcard origin)" "${f}:${ln}" "any-origin CORS — restrict to known hosts"
    done <<EOF
$(grep -niE 'DEBUG[[:space:]]*=[[:space:]]*True|debug:[[:space:]]*true|app\.debug|verify[[:space:]]*=[[:space:]]*False|rejectUnauthorized:[[:space:]]*false|InsecureSkipVerify:[[:space:]]*true|strictSSL:[[:space:]]*false|CURLOPT_SSL_VERIFYPEER|Access-Control-Allow-Origin|origin:[[:space:]]*(.\*.|true)' "${f}" 2>/dev/null)
EOF
  done <<EOF
$(src_files)
EOF
}

# ── deps lens (A06 Vulnerable Components) — offline posture only ─────
scan_deps() {
  local manifests loose
  check_manifest() { # name lockfile-glob auditcmd
    local mf="$1" lock="$2" cmd="$3"
    [ -f "${mf}" ] || return 0
    if ls ${lock} >/dev/null 2>&1; then
      add_finding info "A06" "dependency manifest present (lockfile found)" "${mf}:1" "run \`${cmd}\` yourself for live CVE data (network required)"
    else
      add_finding medium "A06" "dependency manifest without lockfile" "${mf}:1" "no lockfile — pin versions and run \`${cmd}\`"
    fi
  }
  check_manifest package.json "package-lock.json yarn.lock pnpm-lock.yaml" "npm audit"
  check_manifest requirements.txt "requirements.lock Pipfile.lock poetry.lock" "pip-audit"
  check_manifest pom.xml "pom.xml" "mvn org.owasp:dependency-check-maven:check"
  check_manifest build.gradle "gradle.lockfile" "gradle dependencyCheckAnalyze"
  check_manifest Gemfile "Gemfile.lock" "bundle audit"
  check_manifest go.mod "go.sum" "govulncheck ./..."
  # loose pins in package.json
  if [ -f package.json ]; then
    loose="$(grep -nE '":[[:space:]]*"(\*|latest)"' package.json 2>/dev/null | head -5)"
    if [ -n "${loose}" ]; then
      printf '%s\n' "${loose}" | while IFS=: read -r ln _; do
        add_finding low "A06" "unpinned dependency (* or latest)" "package.json:${ln}" "wildcard version — pin to a reviewed range"
      done
    fi
  fi
}

# ── hygiene lens (A09 Logging + 프로젝트 이슈) ───────────────────────
scan_hygiene() {
  local f ln content
  while IFS= read -r f; do
    [ -z "${f}" ] && continue
    is_test_path "${f}" && continue
    while IFS=: read -r ln content; do
      [ -z "${ln}" ] && continue
      printf '%s' "${content}" | grep -qE '(console\.(log|debug)\(|debugger;|System\.out\.println\(|binding\.pry|var_dump\()' \
        && add_finding low "A09" "stray debug output" "${f}:${ln}" "debug residue — remove before production"
      printf '%s' "${content}" | grep -qiE '(^|[^A-Za-z])(TODO|FIXME|HACK|XXX)([^A-Za-z]).*(secur|auth|secret|password|token|hardcod|remove before|insecure)' \
        && add_finding low "A09" "security-flavored TODO/FIXME" "${f}:${ln}" "unresolved security note — triage before release"
    done <<EOF
$(grep -niE 'console\.(log|debug)\(|debugger;|System\.out\.println\(|binding\.pry|var_dump\(|(^|[^A-Za-z])(TODO|FIXME|HACK|XXX)([^A-Za-z]).*(secur|auth|secret|password|token|hardcod|remove before|insecure)' "${f}" 2>/dev/null)
EOF
  done <<EOF
$(src_files)
EOF
}

run_lenses() {
  case "${LENS}" in
    all) scan_secret; scan_owasp; scan_config; scan_deps; scan_hygiene ;;
    secret) scan_secret ;;
    owasp) scan_owasp ;;
    config) scan_config ;;
    deps) scan_deps ;;
    hygiene) scan_hygiene ;;
    *) echo "unknown lens: ${LENS} (secret|owasp|config|deps|hygiene|all)" >&2; exit 2 ;;
  esac
}

# waiver 조회: .sfs-local/audit-waivers 의 한 줄이 `<file:line>|<rule ...reason>` 형식.
# 해당 file:line 로 시작하고 rule 문자열을 포함하면 waived.
is_waived() { # $1 file:line  $2 rule
  local w=".sfs-local/audit-waivers" line rest
  [ -f "${w}" ] || return 1
  while IFS= read -r line; do
    case "${line}" in
      "$1|"*)
        rest="${line#*|}"
        case "${rest}" in *"$2"*) return 0 ;; esac
        ;;
    esac
  done < "${w}"
  return 1
}

sort_findings() { # stdin findings -> severity desc, then file
  awk -F'\t' 'NF>=5 {
    r = ($1=="critical"?4:($1=="high"?3:($1=="medium"?2:($1=="low"?1:0))))
    print r "\t" $0
  }' | LC_ALL=C sort -t'	' -k1,1nr -k5,5 | cut -f2-
}

render_report() { # stdin sorted findings
  local minr; minr="$(sev_rank "${SEV_MIN}")"
  awk -F'\t' -v minr="${minr}" '
    function rank(s){return (s=="critical"?4:(s=="high"?3:(s=="medium"?2:(s=="low"?1:0))))}
    BEGIN{
      print "```"
      print "severity  family  rule                                   location"
      print "```"
    }
    { all[NR]=$0; sev=$1; if(rank(sev)>=minr){ c[sev]++; shown++ } tot[sev]++ }
    END{
      print ""
      print "## Findings (severity-sorted, redacted)"
      print ""
      print "| severity | OWASP | rule | location | evidence (redacted) |"
      print "|---|---|---|---|---|"
      for(i=1;i<=NR;i++){ split(all[i],a,"\t"); if(rank(a[1])>=minr) printf "| %s | %s | %s | `%s` | %s |\n", a[1],a[2],a[3],a[4],a[5] }
      print ""
      print "## Counts"
      print ""
      printf "- critical: %d  high: %d  medium: %d  low: %d  info: %d\n", tot["critical"]+0,tot["high"]+0,tot["medium"]+0,tot["low"]+0,tot["info"]+0
      printf "- shown at --severity-min: %d\n", shown+0
    }
  '
}

cmd_scan() {
  parse_flags "$@"
  echo "sfs audit scan — static security audit, read-only, zero LLM tokens (lens=${LENS})" >&2
  run_lenses
  local sorted total crit
  sorted="$(printf '%s' "${FINDINGS}" | awk 'NF' | sort_findings)"
  # waiver 적용: waived 행은 severity 를 info-waived 로 강등 표기
  sorted="$(printf '%s\n' "${sorted}" | while IFS=$'\t' read -r sev fam rule loc ev; do
    [ -z "${sev}" ] && continue
    if is_waived "${loc}" "${rule}"; then printf 'waived\t%s\t%s\t%s\t%s\n' "${fam}" "${rule}" "${loc}" "${ev}"; else printf '%s\t%s\t%s\t%s\t%s\n' "${sev}" "${fam}" "${rule}" "${loc}" "${ev}"; fi
  done)"
  total="$(printf '%s\n' "${sorted}" | awk 'NF' | wc -l | tr -d '[:space:]')"
  crit="$(printf '%s\n' "${sorted}" | awk -F'\t' '$1=="critical"' | wc -l | tr -d '[:space:]')"

  {
    echo "---"
    echo "doc_id: audit-report-$(domain_slug)"
    echo "title: \"Security audit — $(domain_slug)\""
    echo "doc_type: audit-artifact"
    echo "generated_by: sfs audit scan (deterministic, static, read-only)"
    echo "---"
    echo ""
    echo "# Security audit — $(domain_slug)"
    echo ""
    echo "Static, read-only OWASP-family scan. Signal-only — nothing here blocks a"
    echo "command. Secret values are redacted. Findings carry verify/fix guidance,"
    echo "never weaponized exploit steps. The threat model, exploit-hypothesis"
    echo "(reasoning only), and fix work are LLM steps in \`commands/audit.md\`."
    echo ""
    echo "- lens: ${LENS} / severity-min: ${SEV_MIN}"
    echo "- total findings: ${total} (critical: ${crit})"
    echo ""
    printf '%s\n' "${sorted}" | awk 'NF' | render_report
    echo ""
    echo "## Waiver"
    echo ""
    echo "Acknowledge a finding you have judged acceptable by adding a line to"
    echo "\`.sfs-local/audit-waivers\` containing \`<file:line>|<rule>\` plus your"
    echo "reason. Re-scan reflects it as \`waived\`. Fixing the code makes the"
    echo "finding disappear on the next scan (deterministic re-derivation)."
    echo ""
    echo "## Next (LLM designated points — see commands/audit.md)"
    echo ""
    echo "1. Threat model: cluster these findings into attack scenarios by"
    echo "   exploitability x impact on THIS repo (operator-authorized)."
    echo "2. Exploit hypothesis: describe how findings could chain — reasoning"
    echo "   only, never execute against a live target."
    echo "3. Fixes: propose the secure-by-default change per finding."
  } | emit "00-audit.md"

  if [ "${WRITE}" = "1" ]; then
    mkdir -p ".sfs-local"
    printf '%s\n' "${sorted}" | awk 'NF' > ".sfs-local/audit-findings.tsv" 2>/dev/null || true
  fi
  echo "audit done (findings=${total}, critical=${crit})" >&2
}

cmd_report() {
  parse_flags "$@"
  local f="$(audit_dir)/00-audit.md"
  [ -f "${f}" ] || { echo "no audit report — run: sfs audit scan --write" >&2; exit 3; }
  cat "${f}"
}

cmd_status() {
  parse_flags "$@"
  echo "sfs audit status — $(domain_slug) (signal-only)"
  local tsv=".sfs-local/audit-findings.tsv"
  [ -f "${tsv}" ] || { echo "  no scan yet — run: sfs audit scan --write"; exit 0; }
  local c h m l i w
  c="$(awk -F'\t' '$1=="critical"' "${tsv}" | wc -l | tr -d '[:space:]')"
  h="$(awk -F'\t' '$1=="high"' "${tsv}" | wc -l | tr -d '[:space:]')"
  m="$(awk -F'\t' '$1=="medium"' "${tsv}" | wc -l | tr -d '[:space:]')"
  l="$(awk -F'\t' '$1=="low"' "${tsv}" | wc -l | tr -d '[:space:]')"
  i="$(awk -F'\t' '$1=="info"' "${tsv}" | wc -l | tr -d '[:space:]')"
  w="$(awk -F'\t' '$1=="waived"' "${tsv}" | wc -l | tr -d '[:space:]')"
  echo "  critical=${c} high=${h} medium=${m} low=${l} info=${i} waived=${w}"
  if [ "${c}" -gt 0 ] 2>/dev/null; then
    echo "  open critical findings — review commands/audit.md threat-model step:"
    awk -F'\t' '$1=="critical" {print "   - " $4 "  " $3}' "${tsv}"
  fi
}

case "${COMMAND}" in
  scan) cmd_scan "$@" ;;
  report) cmd_report "$@" ;;
  status) cmd_status "$@" ;;
  help|-h|--help) usage ;;
  *) usage; exit 2 ;;
esac
