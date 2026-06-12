#!/usr/bin/env bash
# AUDIT-2026-06-12 Tier-2 — command/asset surface drift locks.
#
# The command surface is defined in several parallel places (bin/sfs dispatch,
# consumer sfs-dispatch.sh, template adapters, MCP tool wrappers, usage text,
# router-doc marker lists). A full single-registry rewrite is high-regression;
# this test delivers the registry's core promise instead: SILENT DRIFT BETWEEN
# THE LISTS BECOMES A TEST FAILURE. Add a command in one place and this names
# every other place you forgot.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DISPATCH="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-dispatch.sh"
SCRIPTS_DIR="${DIST_DIR}/templates/.sfs-local-template/scripts"
MCP="${DIST_DIR}/mcp-server/solon_mcp_server.py"

fail() { echo "FAIL: $*" >&2; exit 1; }

# ── 1) consumer dispatch.sh routed commands ↔ template adapters ──────
# every command dispatch.sh routes to sfs-<cmd>.sh must have that adapter.
routed_line="$(grep -E '^\s+status\|start\|' "${DISPATCH}")" \
  || fail "cannot find the routed-command case label in sfs-dispatch.sh"
routed="$(printf '%s' "${routed_line}" | tr -d ' )' | tr '|' '\n')"
for cmd in ${routed}; do
  [[ -f "${SCRIPTS_DIR}/sfs-${cmd}.sh" ]] \
    || fail "dispatch.sh routes '${cmd}' but templates/scripts/sfs-${cmd}.sh is missing"
done

# inverse: every template adapter is reachable from dispatch.sh (no orphans).
# non-command adapters by design: sfs-common (lib), sfs-dispatch (router),
# sfs-capture (aliased via capture|note branch).
for f in "${SCRIPTS_DIR}"/sfs-*.sh; do
  base="$(basename "${f}" .sh)"; cmd="${base#sfs-}"
  case "${cmd}" in common|dispatch|capture) continue ;; esac
  printf '%s\n' "${routed}" | grep -qx "${cmd}" \
    || fail "template adapter sfs-${cmd}.sh exists but dispatch.sh never routes '${cmd}' (orphan adapter)"
done
grep -q 'capture|note)' "${DISPATCH}" || fail "dispatch.sh capture|note alias branch missing"

# ── 2) MCP tool wrappers ↔ command surface ───────────────────────────
# every `def sfs_<name>` must map (underscore→hyphen) to a dispatch.sh routed
# command, or to a bin/sfs-level command (version, harness doctor).
mcp_tools="$(grep -oE '^def sfs_[a-z_]+' "${MCP}" | sed 's/^def sfs_//')"
for tool in ${mcp_tools}; do
  cmd="$(printf '%s' "${tool}" | tr '_' '-')"
  if printf '%s\n' "${routed}" | grep -qx "${cmd}"; then continue; fi
  case "${tool}" in
    version) continue ;;                    # bin/sfs builtin
    harness_doctor) continue ;;             # bin/sfs harness subcommand
    capture) continue ;;                    # dispatch.sh alias branch
    *) fail "MCP tool sfs_${tool} maps to no dispatched command '${cmd}'" ;;
  esac
done

# ── 3) router-doc marker parity (3 copies must agree) ────────────────
# sfs_router_doc_is_sfs/needs_refactor live near-duplicated in bin/sfs,
# upgrade.sh, and sfs-doctor.sh with context-specific plumbing — but the
# MARKER STRINGS are the shared contract: a marker added in one copy and
# not the others reintroduces the drift this lock exists to stop.
extract_markers() {
  sed -n '/sfs_router_doc_is_sfs()/,/^}/p;/sfs_router_doc_needs_refactor()/,/^}/p' "$1" \
    | grep -oE '"[^"]+"' | grep -vE '^\"\$' | LC_ALL=C sort -u
}
m_bin="$(extract_markers "${DIST_DIR}/bin/sfs")"
m_up="$(extract_markers "${DIST_DIR}/upgrade.sh")"
m_doc="$(extract_markers "${DIST_DIR}/scripts/sfs-doctor.sh")"
[[ -n "${m_bin}" ]] || fail "router-doc marker extraction came back empty (functions renamed/moved?)"
[[ "${m_bin}" == "${m_up}" ]] \
  || fail "router-doc detection markers drifted between bin/sfs and upgrade.sh:
$(diff <(printf '%s\n' "${m_bin}") <(printf '%s\n' "${m_up}") | head -6)"
[[ "${m_bin}" == "${m_doc}" ]] \
  || fail "router-doc detection markers drifted between bin/sfs and sfs-doctor.sh:
$(diff <(printf '%s\n' "${m_bin}") <(printf '%s\n' "${m_doc}") | head -6)"

# ── 4) every routed command module resolves via `sfs context path` ───
# (caught live: `recall` was routed + documented but context_resolve_rel
# never learned it — `sfs context path recall` errored.)
for f in "${DIST_DIR}/templates/.sfs-local-template/context/commands"/*.md; do
  key="$(basename "${f}" .md)"
  "${DIST_DIR}/bin/sfs" context path "${key}" >/dev/null 2>&1 \
    || fail "commands/${key}.md exists but 'sfs context path ${key}' cannot resolve it"
done

# ── 5) bin/sfs usage mentions every dispatch.sh routed command ───────
# scope to the "Full command inventory:" block — whole-help prose mentions
# of status/guide/decision made full-text grep a false-pass (CPO E, 0.8.38).
usage_text="$("${DIST_DIR}/bin/sfs" help --full 2>/dev/null || true)"
[[ -n "${usage_text}" ]] || fail "bin/sfs help --full produced no output"
inventory="$(printf '%s\n' "${usage_text}" | sed -n '/Full command inventory:/,/^$/p')"
[[ -n "${inventory}" ]] || fail "help --full lost its 'Full command inventory:' block"
missing=""
for cmd in ${routed}; do
  printf '%s' "${inventory}" | grep -qE "(^|[ |/])${cmd}([ |/,]|$)" \
    || missing="${missing} ${cmd}"
done
[[ -z "${missing}" ]] \
  || fail "help --full command inventory does not list routed command(s):${missing}"

echo "test-command-surface-parity: OK"
