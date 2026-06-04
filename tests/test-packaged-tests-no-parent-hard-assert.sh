#!/usr/bin/env bash
# Product-package tests must not hard-assert files outside the packaged dist.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

violations=""
for file in "${SCRIPT_DIR}"/test-*.sh; do
  [[ "$(basename "${file}")" == "test-packaged-tests-no-parent-hard-assert.sh" ]] && continue
  file_violations="$(
    awk -v file="${file}" '
      { lines[NR] = $0 }
      END {
        for (i = 1; i <= NR; i++) {
          line = lines[i]
          if (line ~ /^[[:space:]]*#/) {
            continue
          }
          if (index(line, "${DIST_DIR}/../") == 0) {
            continue
          }
          if (line ~ /(assert_[A-Za-z0-9_]+|(^|[[:space:]])grep[[:space:]])/) {
            printf "%s:%d: direct parent-path hard assertion: %s\n", file, i, line
            continue
          }
          if (line ~ /^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*=/ && index(line, "${DIST_DIR}/../..") == 0) {
            var_name = line
            sub(/^[[:space:]]*/, "", var_name)
            sub(/=.*/, "", var_name)
            parent_vars[var_name] = i
            if (i > 1 && index(lines[i - 1], "-f") > 0 && index(lines[i - 1], "${DIST_DIR}/../") > 0) {
              guarded_vars[var_name] = 1
            }
            continue
          }
        }
        for (i = 1; i <= NR; i++) {
          line = lines[i]
          if (line ~ /^[[:space:]]*#/) {
            continue
          }
          for (var_name in parent_vars) {
            var_ref = "${" var_name "}"
            if (index(line, "-f") > 0 && index(line, var_ref) > 0) {
              guarded_vars[var_name] = 1
            }
            if (i > parent_vars[var_name] && index(line, var_ref) > 0 && line ~ /(assert_[A-Za-z0-9_]+|(^|[[:space:]])grep[[:space:]])/ && guarded_vars[var_name] != 1) {
              printf "%s:%d: parent docset path variable must be file-guarded before assertions: %s\n", file, i, line
            }
          }
        }
      }
    ' "${file}"
  )"
  if [[ -n "${file_violations}" ]]; then
    violations+="${file_violations}"$'\n'
  fi
done

if [[ -n "${violations}" ]]; then
  printf '%s\n' "${violations}" >&2
  fail 'product tests must guard docset-only parent paths before hard assertions'
fi

echo "test-packaged-tests-no-parent-hard-assert: OK"
