#!/usr/bin/env bash
# tests/test-sfs-bootstrap-quick.sh — R-A + R-B AC-func-1/6 + AC-perf-4 file-level inventory test.
#
# γ scope: 7 expected files (no Gradle wrapper JAR / gradlew / gradlew.bat — those are
# carry to chunk-3 manual measurement via `gradle wrapper` post-copy or `--refresh`).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCRIPT="${DIST_DIR}/scripts/sfs-bootstrap.sh"

[[ -x "${SCRIPT}" ]] || { echo "missing: ${SCRIPT}" >&2; exit 1; }

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT

cd "${tmp}"

# Public surface guard: non-experimental bootstrap is a conversational setup
# handoff, not a generic SFS-owned framework generator.
set +e
SFS_DIST_DIR="${DIST_DIR}" SFS_ALIVE_THRESHOLD_SECS=300 \
  bash "${SCRIPT}" myproject --quick 2>"${tmp}/bootstrap-public.err"
rc=$?
set -e
[[ "${rc}" == "0" ]] || { echo "FAIL: non-experimental bootstrap trigger should exit 0, got ${rc}" >&2; cat "${tmp}/bootstrap-public.err" >&2; exit 1; }
grep -q 'initial project setup trigger captured' "${tmp}/bootstrap-public.err" \
  || { echo "FAIL: non-experimental bootstrap should guide native AI/framework scaffolding" >&2; cat "${tmp}/bootstrap-public.err" >&2; exit 1; }
grep -q 'Agent action' "${tmp}/bootstrap-public.err" \
  || { echo "FAIL: non-experimental bootstrap should emit agent action handoff" >&2; cat "${tmp}/bootstrap-public.err" >&2; exit 1; }
grep -q '초기 프로젝트 구성해드릴까요' "${tmp}/bootstrap-public.err" \
  || { echo "FAIL: bootstrap trigger should use non-developer setup offer wording" >&2; cat "${tmp}/bootstrap-public.err" >&2; exit 1; }
[[ ! -e myproject ]] \
  || { echo "FAIL: non-experimental bootstrap trigger must not create framework files" >&2; exit 1; }

set +e
SFS_DIST_DIR="${DIST_DIR}" SFS_ALIVE_THRESHOLD_SECS=300 \
  bash "${SCRIPT}" --experimental myproject --quick 2>"${tmp}/bootstrap-no-stack.err"
rc=$?
set -e
[[ "${rc}" == "2" ]] || { echo "FAIL: experimental bootstrap without stack should exit 2, got ${rc}" >&2; cat "${tmp}/bootstrap-no-stack.err" >&2; exit 1; }
grep -q 'bootstrap stack is required' "${tmp}/bootstrap-no-stack.err" \
  || { echo "FAIL: missing stack should be explicit" >&2; cat "${tmp}/bootstrap-no-stack.err" >&2; exit 1; }

set +e
SFS_DIST_DIR="${DIST_DIR}" SFS_ALIVE_THRESHOLD_SECS=300 \
  bash "${SCRIPT}" --experimental --stack fastapi myproject --quick 2>"${tmp}/bootstrap-fastapi.err"
rc=$?
set -e
[[ "${rc}" == "2" ]] || { echo "FAIL: unsupported stack should exit 2, got ${rc}" >&2; cat "${tmp}/bootstrap-fastapi.err" >&2; exit 1; }
grep -q 'supported in 0.6.0: spring-kotlin' "${tmp}/bootstrap-fastapi.err" \
  || { echo "FAIL: unsupported stack should list supported stacks" >&2; cat "${tmp}/bootstrap-fastapi.err" >&2; exit 1; }

# Default --quick path with explicit override flags (AC-func-6).
SFS_DIST_DIR="${DIST_DIR}" SFS_ALIVE_THRESHOLD_SECS=300 \
  bash "${SCRIPT}" --experimental spring-kotlin myproject --quick \
    --java-version 21 --spring-boot 3.3.6 --package com.example.demo \
    2>"${tmp}/bootstrap-myproject.err"

# AC-perf-4 file-level inventory (γ: 7 files, no JAR/gradlew/gradlew.bat).
expected_files=(
  "myproject/build.gradle.kts"
  "myproject/settings.gradle.kts"
  "myproject/gradle/wrapper/gradle-wrapper.properties"
  "myproject/src/main/kotlin/com/example/demo/Application.kt"
  "myproject/src/main/resources/application.properties"
  "myproject/src/test/kotlin/com/example/demo/ApplicationTests.kt"
  "myproject/.gitignore"
)
for f in "${expected_files[@]}"; do
  [[ -f "${f}" ]] || { echo "FAIL: missing ${f}" >&2; exit 1; }
done

# AC-func-6 override flag substitution.
grep -q 'version "3.3.6"' myproject/build.gradle.kts \
  || { echo "FAIL: --spring-boot 3.3.6 not substituted" >&2; exit 1; }
grep -q 'JavaLanguageVersion.of(21)' myproject/build.gradle.kts \
  || { echo "FAIL: --java-version 21 not substituted" >&2; exit 1; }
grep -q '^package com.example.demo$' myproject/src/main/kotlin/com/example/demo/Application.kt \
  || { echo "FAIL: --package com.example.demo not substituted in Application.kt" >&2; exit 1; }
grep -q '^package com.example.demo$' myproject/src/test/kotlin/com/example/demo/ApplicationTests.kt \
  || { echo "FAIL: --package com.example.demo not substituted in ApplicationTests.kt" >&2; exit 1; }
grep -q 'rootProject.name = "myproject"' myproject/settings.gradle.kts \
  || { echo "FAIL: <PROJECT-NAME> not substituted in settings.gradle.kts" >&2; exit 1; }

# Placeholder dir __PACKAGE_PATH__ should not remain.
if [[ -d myproject/src/main/kotlin/__PACKAGE_PATH__ ]]; then
  echo "FAIL: __PACKAGE_PATH__ placeholder dir not renamed in main/kotlin" >&2
  exit 1
fi
if [[ -d myproject/src/test/kotlin/__PACKAGE_PATH__ ]]; then
  echo "FAIL: __PACKAGE_PATH__ placeholder dir not renamed in test/kotlin" >&2
  exit 1
fi

# anti-AC: no <PACKAGE> / <PROJECT-NAME> / <JAVA-VERSION> / <SPRING-BOOT-VERSION> placeholder leaks.
if grep -rE '<PROJECT-NAME>|<PACKAGE>|<PACKAGE_PATH>|<JAVA-VERSION>|<SPRING-BOOT-VERSION>' myproject 2>/dev/null; then
  echo "FAIL: placeholder leaked in generated project" >&2
  exit 1
fi

# AC-rev-2: skeleton output must not create a substantive review artifact.
if find myproject -name 'review-g6.md' -type f -size +0c -print -quit | grep -q .; then
  echo "FAIL: skeleton output created non-empty review-g6.md" >&2
  exit 1
fi

# Gamma JAR strategy UX: --quick omits gradlew/gradlew.bat/JAR, so stderr must say what to do next.
grep -q 'gradle wrapper --gradle-version 8.10.2' "${tmp}/bootstrap-myproject.err" \
  || { echo "FAIL: --quick output should include Gradle wrapper hint" >&2; cat "${tmp}/bootstrap-myproject.err" >&2; exit 1; }

# Different override values produce different output.
SFS_DIST_DIR="${DIST_DIR}" SFS_ALIVE_THRESHOLD_SECS=300 \
  bash "${SCRIPT}" --experimental --stack spring-kotlin alt --quick --java-version 17 --spring-boot 3.2.0 --package com.foo.bar
grep -q 'JavaLanguageVersion.of(17)' alt/build.gradle.kts \
  || { echo "FAIL: --java-version 17 override not substituted" >&2; exit 1; }
grep -q 'version "3.2.0"' alt/build.gradle.kts \
  || { echo "FAIL: --spring-boot 3.2.0 override not substituted" >&2; exit 1; }
[[ -f alt/src/main/kotlin/com/foo/bar/Application.kt ]] \
  || { echo "FAIL: --package com.foo.bar package path not created" >&2; exit 1; }

echo "test-sfs-bootstrap-quick: OK"
