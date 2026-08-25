#!/usr/bin/env bash
# tests/test-homebrew-runtime-detection.sh — Homebrew opt/Cellar runtime detection.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${REPO_DIR}/bin/sfs"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

extract_function() {
  local name="$1"
  awk -v signature="${name}()" '
    index($0, signature " {") == 1 { capture=1 }
    capture { print }
    capture && /^}$/ { exit }
  ' "${SFS_BIN}"
}

tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/sfs-homebrew-runtime.XXXXXX")"
trap 'rm -rf "${tmpdir}"' EXIT

functions_file="${tmpdir}/runtime-functions.sh"
{
  extract_function upgrade_command
  extract_function is_homebrew_runtime
  extract_function is_scoop_runtime
} > "${functions_file}"

# shellcheck source=/dev/null
source "${functions_file}"

fake_bin="${tmpdir}/bin"
brew_root="${tmpdir}/homebrew"
keg="${brew_root}/Cellar/sfs/0.15.0"
opt_prefix="${brew_root}/opt/sfs"
mkdir -p "${fake_bin}" "${keg}/libexec" "${brew_root}/opt"
ln -s "../Cellar/sfs/0.15.0" "${opt_prefix}"

cat > "${fake_bin}/brew" <<'SH'
#!/usr/bin/env bash
case "${1:-}" in
  --prefix)
    printf '%s\n' "${FAKE_BREW_PREFIX:?}"
    ;;
  info)
    printf '%s\n' "${FAKE_BREW_INFO:?}"
    ;;
  *)
    exit 1
    ;;
esac
SH
chmod +x "${fake_bin}/brew"
export PATH="${fake_bin}:/usr/bin:/bin"

# Regression: brew --prefix returns opt/sfs while the formula wrapper exports
# the physical Cellar libexec path as SFS_DIST_DIR.
export FAKE_BREW_PREFIX="${opt_prefix}"
export FAKE_BREW_INFO="mj-0701/solon-product/sfs: stable 0.15.0"
DIST_DIR="${keg}/libexec"
is_homebrew_runtime \
  || fail "opt -> Cellar symlink fixture was not recognized as Homebrew"

# Positive control: a physical keg prefix still recognizes its libexec child.
export FAKE_BREW_PREFIX="${keg}"
is_homebrew_runtime \
  || fail "physical Cellar prefix was not recognized as Homebrew"

# Negative control: an unrelated dist must not pass prefix containment.
unrelated_dist="${tmpdir}/unrelated/libexec"
mkdir -p "${unrelated_dist}"
DIST_DIR="${unrelated_dist}"
if is_homebrew_runtime; then
  fail "unrelated DIST_DIR was accepted as Homebrew"
fi

# Negative control: preserve the tap/formula package identity guard.
DIST_DIR="${keg}/libexec"
export FAKE_BREW_PREFIX="${opt_prefix}"
export FAKE_BREW_INFO="homebrew/core/sfs: stable 0.15.0"
if is_homebrew_runtime; then
  fail "runtime passed with the wrong Homebrew package identity"
fi

homebrew_source="$(extract_function is_homebrew_runtime)"
grep -Fq 'cd -P' <<<"${homebrew_source}" \
  || fail "Homebrew paths are not normalized with cd -P"
if grep -Fq 'realpath' <<<"${homebrew_source}"; then
  fail "Homebrew runtime detection must remain compatible with macOS bash 3.2 (no realpath)"
fi

# Caller contract: an unmanaged runtime reports exactly one skip reason, but
# explicit --no-self-upgrade / SFS_UPDATE_SELF=0 remains silent.
caller_dist="${tmpdir}/caller-dist"
mkdir -p "${caller_dist}"
cat > "${caller_dist}/upgrade.sh" <<'SH'
#!/usr/bin/env bash
exit 0
SH

DIST_DIR="${caller_dist}"
repair_legacy_sfs_project_markers_for_upgrade() { return 0; }
ensure_project_initialized() { return 0; }
is_homebrew_runtime() { return 1; }
is_scoop_runtime() { return 1; }
self_upgrade_if_homebrew() { return 0; }
self_upgrade_if_scoop() { return 0; }
sfs_router_doc_refactor_one() { return 0; }
agent_root_doc_doctor() { return 0; }
project_local_dir() { printf '.sfs-local\n'; }
sfs_project_layout() { printf 'thin\n'; }
install_agent_adapter() { return 0; }

skip_reason='global runtime self-upgrade: skipped (runtime is not managed by Homebrew or Scoop)'
caller_output="$(upgrade_command)"
skip_count="$(printf '%s\n' "${caller_output}" | grep -Fxc "${skip_reason}" || true)"
[[ "${skip_count}" == "1" ]] \
  || fail "unmanaged caller emitted ${skip_count} skip reasons (expected exactly one)"

disabled_output="$(upgrade_command --no-self-upgrade)"
if grep -Fq 'global runtime self-upgrade: skipped' <<<"${disabled_output}"; then
  fail "--no-self-upgrade must not emit an implicit skip reason"
fi

env_disabled_output="$(SFS_UPDATE_SELF=0 upgrade_command)"
if grep -Fq 'global runtime self-upgrade: skipped' <<<"${env_disabled_output}"; then
  fail "SFS_UPDATE_SELF=0 must not emit an implicit skip reason"
fi

# Regression: a Scoop-managed runtime routes to Scoop only.
routing_log="${tmpdir}/upgrade-routing.log"
: > "${routing_log}"
is_homebrew_runtime() { return 1; }
is_scoop_runtime() { return 0; }
self_upgrade_if_homebrew() { printf 'homebrew\n' >> "${routing_log}"; }
self_upgrade_if_scoop() { printf 'scoop\n' >> "${routing_log}"; }

upgrade_command >/dev/null
routing_calls="$(cat "${routing_log}")"
[[ "${routing_calls}" == "scoop" ]] \
  || fail "Scoop runtime invoked '${routing_calls}' (expected only scoop)"

echo "test-homebrew-runtime-detection: OK"
