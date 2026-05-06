#!/usr/bin/env bash
# Guardrail: user-facing validation guidance must stay repair-first.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

DESIGN_EN="${ROOT_DIR}/templates/.sfs-local-template/context/policies/design-knowledge-pack.md"
DESIGN_KO="${ROOT_DIR}/templates/.sfs-local-template/context/policies/design-knowledge-pack.ko.md"
IMPLEMENT="${ROOT_DIR}/templates/.sfs-local-template/context/commands/implement.md"

assert_contains() {
  local file="$1"
  local needle="$2"
  if ! grep -Fq -- "${needle}" "${file}"; then
    echo "missing guardrail text in ${file}: ${needle}" >&2
    exit 1
  fi
}

assert_contains "${DESIGN_EN}" "DES-PROP-019"
assert_contains "${DESIGN_EN}" "DES-FILL-REPAIR"
assert_contains "${DESIGN_EN}" "repair-first UX contract"
assert_contains "${DESIGN_EN}" "Server-side 4xx validation is a final safety net"
assert_contains "${DESIGN_EN}" "Repair matrix for validation states"

assert_contains "${DESIGN_KO}" "DES-FILL-REPAIR"
assert_contains "${DESIGN_KO}" "repair-first UX contract"
assert_contains "${DESIGN_KO}" "[Product]"
assert_contains "${DESIGN_KO}" "AI 에게 맡기기"
assert_contains "${DESIGN_KO}" "시네마틱"
assert_contains "${DESIGN_KO}" "structured information"

assert_contains "${IMPLEMENT}" "S0 repair contract"
assert_contains "${IMPLEMENT}" "Warning/blocking alone is not a"

echo "friendly UX contract guardrails present"
