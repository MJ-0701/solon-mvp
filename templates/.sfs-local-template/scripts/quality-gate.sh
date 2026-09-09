#!/usr/bin/env bash
# Consumer repository quality gate: seven sequential, redacted evidence stages.
set -uo pipefail

usage() {
  cat <<'EOF'
Usage: quality-gate.sh [--mode pr|full]

Runs detected Python, Node, and Gradle checks sequentially through syntax/type,
format, code security, dependency security, credentials, unit tests, and
regression tests. A missing gitleaks or unit-test tool fails the gate.
EOF
}

mode="pr"
if [[ "$#" -eq 2 && "$1" == "--mode" ]]; then
  mode="$2"
elif [[ "$#" -eq 1 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
  usage
  exit 0
elif [[ "$#" -ne 0 ]]; then
  usage >&2
  exit 2
fi
case "$mode" in pr|full) ;; *) usage >&2; exit 2 ;; esac

root="$(pwd -P)"
umask 077
tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/sfs-quality-gate.XXXXXX")" || exit 1
chmod 700 "$tmpdir" 2>/dev/null || true
cleanup() { rm -rf "$tmpdir"; }
trap cleanup EXIT HUP INT TERM

has_py=0; has_node=0; has_gradle=0
[[ -f "$root/pyproject.toml" ]] && has_py=1
[[ -f "$root/package.json" ]] && has_node=1
[[ -f "$root/build.gradle" || -f "$root/build.gradle.kts" ]] && has_gradle=1
[[ -x "$root/gradlew" ]] && gradle="$root/gradlew" || gradle="gradle"
gradle_build="${root}/build.gradle"
[[ -f "${root}/build.gradle.kts" ]] && gradle_build="${root}/build.gradle.kts"

redact() {
  # Mask synthetic credentials and conventional PII before summaries leave 0600 logs.
  perl -pe 's/((?:AKIA|ASIA)[A-Z0-9]{16})/[REDACTED-AWS-KEY]/g; s/(ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9_-]{20,})/[REDACTED-SECRET]/g; s/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b/[REDACTED-EMAIL]/g; s/\b(?:\+?\d[ -]?){8,}\d\b/[REDACTED-PHONE]/g'
}

stage=0
failed=0
ran=0
run_stage() {
  local label="$1" required="$2" command="$3" log rc
  stage=$((stage + 1))
  log="$tmpdir/stage-$stage.log"
  : > "$log"
  chmod 600 "$log" 2>/dev/null || true
  if [[ -z "$command" ]]; then
    printf 'STAGE %d/7 %s: SKIP(no applicable installed tool)\n' "$stage" "$label"
    printf '%s\n' "--- $label: last 20 lines (redacted) ---"
    printf '%s\n' 'SKIP(no applicable installed tool)'
    [[ "$required" == "required" ]] && { printf 'STAGE %d/7 %s: FAIL(required tool skipped)\n' "$stage" "$label"; failed=1; }
    return 0
  fi
  printf 'STAGE %d/7 %s: RUN\n' "$stage" "$label"
  (cd "$root" && bash -c "$command") >"$log" 2>&1
  rc=$?
  ran=1
  if [[ "$rc" -eq 0 ]]; then
    printf 'STAGE %d/7 %s: PASS\n' "$stage" "$label"
  else
    printf 'STAGE %d/7 %s: FAIL(exit=%d)\n' "$stage" "$label" "$rc"
    failed=1
  fi
  printf '%s\n' "--- $label: last 20 lines (redacted) ---"
  tail -n 20 "$log" | redact
}

commands=""
if [[ "$has_py" -eq 1 ]] && command -v pyright >/dev/null 2>&1; then commands="pyright"; fi
if [[ "$has_node" -eq 1 && -x "$root/node_modules/.bin/tsc" ]]; then commands="${commands}${commands:+ ; }./node_modules/.bin/tsc --noEmit"; fi
if [[ "$has_gradle" -eq 1 ]] && command -v "$gradle" >/dev/null 2>&1; then
  if grep -Eqi 'kotlin|org.jetbrains.kotlin' "$gradle_build"; then commands="${commands}${commands:+ ; }$gradle compileKotlin"; else commands="${commands}${commands:+ ; }$gradle compileJava"; fi
fi
run_stage "syntax/type" optional "$commands"

commands=""
if [[ "$has_py" -eq 1 ]] && command -v ruff >/dev/null 2>&1; then commands="ruff format --check ."; fi
if [[ "$has_node" -eq 1 && -x "$root/node_modules/.bin/eslint" ]]; then commands="${commands}${commands:+ ; }./node_modules/.bin/eslint ."; fi
if [[ "$has_node" -eq 1 && -x "$root/node_modules/.bin/prettier" ]]; then commands="${commands}${commands:+ ; }./node_modules/.bin/prettier --check ."; fi
if [[ "$has_gradle" -eq 1 ]] && command -v "$gradle" >/dev/null 2>&1; then
  if grep -qi 'ktlint' "$gradle_build"; then commands="${commands}${commands:+ ; }$gradle ktlintCheck"; elif grep -qi 'spotless' "$gradle_build"; then commands="${commands}${commands:+ ; }$gradle spotlessCheck"; fi
fi
run_stage "format" optional "$commands"

commands=""
if command -v semgrep >/dev/null 2>&1; then commands="semgrep --config auto ."; fi
run_stage "code security" optional "$commands"

commands=""
if [[ "$has_py" -eq 1 ]] && command -v pip-audit >/dev/null 2>&1; then commands="pip-audit"; fi
if [[ "$has_node" -eq 1 ]] && command -v npm >/dev/null 2>&1; then commands="${commands}${commands:+ ; }npm audit --omit=dev"; fi
if [[ "$has_gradle" -eq 1 ]] && command -v "$gradle" >/dev/null 2>&1 && grep -qi 'dependencyCheck' "$gradle_build"; then commands="${commands}${commands:+ ; }$gradle dependencyCheckAnalyze"; fi
run_stage "dependency security" optional "$commands"

commands=""
if command -v gitleaks >/dev/null 2>&1; then commands="gitleaks detect --source . --no-git"; fi
run_stage "credentials" required "$commands"

commands=""
if [[ "$has_py" -eq 1 ]] && command -v pytest >/dev/null 2>&1; then commands="pytest"; fi
if [[ "$has_node" -eq 1 && -x "$root/node_modules/.bin/vitest" ]]; then commands="${commands}${commands:+ ; }./node_modules/.bin/vitest run"; elif [[ "$has_node" -eq 1 && -x "$root/node_modules/.bin/jest" ]]; then commands="${commands}${commands:+ ; }./node_modules/.bin/jest"; fi
if [[ "$has_gradle" -eq 1 ]] && command -v "$gradle" >/dev/null 2>&1; then commands="${commands}${commands:+ ; }$gradle test"; fi
run_stage "unit tests" required "$commands"

commands=""
if [[ "$mode" == "full" ]]; then
  if [[ "$has_py" -eq 1 ]] && command -v pytest >/dev/null 2>&1; then commands="pytest -m regression"; fi
  if [[ "$has_node" -eq 1 && -x "$root/node_modules/.bin/playwright" ]]; then commands="${commands}${commands:+ ; }./node_modules/.bin/playwright test"; fi
  if [[ "$has_gradle" -eq 1 ]] && command -v "$gradle" >/dev/null 2>&1 && grep -qi 'integrationTest' "$gradle_build"; then commands="${commands}${commands:+ ; }$gradle integrationTest"; fi
fi
run_stage "regression tests" optional "$commands"

if [[ "$failed" -ne 0 ]]; then
  printf 'QUALITY GATE: FAIL (mode=%s)\n' "$mode"
  exit 1
fi
printf 'QUALITY GATE: PASS (mode=%s)\n' "$mode"
