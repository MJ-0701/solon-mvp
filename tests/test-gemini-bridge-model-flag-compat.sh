#!/usr/bin/env bash
# Gemini bridge defaults use 3.x model flags only when the installed CLI supports them.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMMON="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-common.sh"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-gemini-bridge.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

write_fake_gemini() {
  local mode="$1"
  mkdir -p "${TMP_DIR}/bin"
  cat > "${TMP_DIR}/bin/gemini" <<EOF
#!/usr/bin/env bash
if [[ "\${1:-}" == "--help" ]]; then
  if [[ "${mode}" == "model" ]]; then
    echo "Usage: gemini --model <model>"
  elif [[ "${mode}" == "large_model" ]]; then
    echo "Usage: gemini --model <model>"
    for i in {1..100000}; do
      echo "filler \${i}"
    done
  else
    echo "Usage: gemini"
  fi
  exit 0
fi
echo "fake gemini"
EOF
  chmod +x "${TMP_DIR}/bin/gemini"
}

write_fake_gemini no_model
cmd_no_model="$(
  PATH="${TMP_DIR}/bin:${PATH}" bash -c '
    source "$1"
    sfs_gemini_default_cmd "gemini-3.1-pro-preview" "Read stdin and perform the requested CPO review."
  ' bash "${COMMON}"
)"

case "${cmd_no_model}" in
  *"--model"*) fail "no-model CLI should not receive --model: ${cmd_no_model}" ;;
esac
case "${cmd_no_model}" in
  *"gemini --skip-trust --output-format text -p \"Read stdin and perform the requested CPO review.\""*) ;;
  *) fail "no-model CLI bridge command unexpected: ${cmd_no_model}" ;;
esac

write_fake_gemini model
cmd_with_model="$(
  PATH="${TMP_DIR}/bin:${PATH}" bash -c '
    source "$1"
    sfs_gemini_default_cmd "gemini-3.1-pro-preview" "Read stdin and perform the requested CPO review."
  ' bash "${COMMON}"
)"

case "${cmd_with_model}" in
  *"--model gemini-3.1-pro-preview"*) ;;
  *) fail "model-capable CLI should receive Gemini 3.x model flag: ${cmd_with_model}" ;;
esac

write_fake_gemini large_model
cmd_with_large_help="$(
  PATH="${TMP_DIR}/bin:${PATH}" bash -c '
    set -o pipefail
    source "$1"
    sfs_gemini_default_cmd "gemini-3.1-pro-preview" "Read stdin and perform the requested CPO review."
  ' bash "${COMMON}"
)"

case "${cmd_with_large_help}" in
  *"--model gemini-3.1-pro-preview"*) ;;
  *) fail "large --help output must not drop supported --model under pipefail: ${cmd_with_large_help}" ;;
esac

echo "test-gemini-bridge-model-flag-compat: OK"
