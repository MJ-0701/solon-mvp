#!/usr/bin/env bash
# BLOG-2026-08-01-1 — MCP 2026-07-28: stateless core, versioned extensions.
#
# Locks three things the spec release made concrete for Solon:
#
#   1. The MCP spec revision `mcp-server` is written against is declared in
#      exactly ONE place in the source (`MCP_PROTOCOL_REVISION`), and no other
#      shipped file restates the date — two copies are two things to forget to
#      bump. The release checklist names the three-part bump obligation.
#   2. STATELESS_TRANSPORT_ASSUMPTION is real, not aspirational: the audit
#      found the server already stateless, and this test re-runs that audit —
#      no module-level mutable state, every tool a verbatim shell-out — so a
#      later patch cannot quietly reintroduce session-lifetime state.
#   3. VERSIONED_EXTENSION_SURFACE exists as a routed anchor with the
#      discriminating question, single-owner.
#
# Vendor lockout: extension product names, auth/enterprise surfaces, and the
# connector-directory/observability material the report deferred must not
# appear in product prose.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CTX="${DIST_DIR}/templates/.sfs-local-template/context"
SRV="${DIST_DIR}/mcp-server/solon_mcp_server.py"
SRV_README="${DIST_DIR}/mcp-server/README.md"
SKILL="${CTX}/policies/skill-catalog-discipline.md"
RELPOL="${DIST_DIR}/docs/maintenance/release-policy.md"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fhasu() { LC_ALL=C grep -Fq -- "$2" "$1" || fail "$3: missing '$2'"; }
fanchor() { grep -Ewq -- "$2" "$1" || fail "$3: missing anchor '$2'"; }
fnot() { grep -Fq -- "$2" "$1" && fail "$3: forbidden '$2' present"; return 0; }

# ── (1) revision declared once, in the source ───────────────────────
grep -Eq '^MCP_PROTOCOL_REVISION[[:space:]]*=[[:space:]]*"[0-9]{4}-[0-9]{2}-[0-9]{2}"' "${SRV}" \
  || fail "MCP_PROTOCOL_REVISION must be a dated constant at module level in solon_mcp_server.py"
decls="$(grep -cE '^MCP_PROTOCOL_REVISION[[:space:]]*=' "${SRV}")"
[[ "${decls}" -eq 1 ]] || fail "MCP_PROTOCOL_REVISION assigned ${decls} times; must be one"

rev="$(sed -nE 's/^MCP_PROTOCOL_REVISION[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "${SRV}")"
[[ -n "${rev}" ]] || fail "could not read the declared revision"

# No shipped file may restate the revision date — the source is the one copy.
# (CHANGELOG/RELEASE-NOTES legitimately quote it in release prose.)
while IFS= read -r f; do
  case "$f" in
    */CHANGELOG.md|*/RELEASE-NOTES.md|*/.git/*|*/tests/*) continue ;;
    "${SRV}") continue ;;
  esac
  grep -Fq -- "${rev}" "$f" \
    && fail "revision ${rev} restated in ${f#${DIST_DIR}/} — read MCP_PROTOCOL_REVISION instead"
done < <(find "${DIST_DIR}/mcp-server" "${CTX}" "${DIST_DIR}/docs/maintenance" \
              -type f \( -name '*.md' -o -name '*.py' -o -name '*.toml' \))

# README points at the constant rather than copying it
fhas "${SRV_README}" "MCP_PROTOCOL_REVISION" "README routes to the single source"
fhas "${SRV_README}" "restate the date, because two copies" "README states why it does not copy"

# ── (1b) the three-part release obligation ──────────────────────────
fhasu "${RELPOL}" "MCP_PROTOCOL_REVISION" "release policy names the constant"
fhasu "${RELPOL}" "하위호환 유지 여부" "release policy requires the compat decision"
fhasu "${RELPOL}" "CHANGELOG 에 둘 다 명기" "release policy requires the CHANGELOG record"
fhasu "${RELPOL}" "test-protocol-revision-single-source-policy.sh" "release policy names its regression lock"

# ── (2) stateless transport, re-audited not just asserted ───────────
fhas "${SRV}" "STATELESS_TRANSPORT_ASSUMPTION" "stateless assumption named in the source"
fhas "${SRV}" "DONE_IS_ARTIFACT_ON_DISK" "the on-disk-state counterpart cited"
fhas "${SRV_README}" "stateless by construction" "README states the transport property"

# Re-run the audit: no module-level mutable state (dict/list/set literals or
# mutable constructors bound at module scope), and no global rebinding.
python3 - "${SRV}" <<'PY' || exit 1
import ast, sys
src = open(sys.argv[1]).read()
tree = ast.parse(src)
bad = []
MUTABLE = (ast.Dict, ast.List, ast.Set, ast.DictComp, ast.ListComp, ast.SetComp)
MUTABLE_CALLS = {"dict", "list", "set", "defaultdict", "deque", "Counter", "OrderedDict"}
for node in tree.body:
    if isinstance(node, (ast.Assign, ast.AnnAssign)):
        val = node.value
        if val is None:
            continue
        if isinstance(val, MUTABLE):
            bad.append(f"module-level mutable literal at line {node.lineno}")
        if isinstance(val, ast.Call) and isinstance(val.func, ast.Name) \
                and val.func.id in MUTABLE_CALLS:
            bad.append(f"module-level mutable container at line {node.lineno}")
for node in ast.walk(tree):
    if isinstance(node, ast.Global):
        bad.append(f"`global` rebinding at line {node.lineno} — session state in the transport")
if bad:
    print("FAIL: stateless transport audit: " + "; ".join(bad), file=sys.stderr)
    sys.exit(1)
PY

# Every exposed tool returns a verbatim shell-out, not a computed/cached value.
python3 - "${SRV}" <<'PY' || exit 1
import ast, sys
tree = ast.parse(open(sys.argv[1]).read())
tools = [n for n in tree.body
         if isinstance(n, ast.FunctionDef)
         and any(isinstance(d, ast.Call) and getattr(d.func, "attr", "") == "tool"
                 for d in n.decorator_list)]
if not tools:
    print("FAIL: no @mcp.tool() functions found — audit would be vacuous", file=sys.stderr)
    sys.exit(1)
offenders = [t.name for t in tools
             if not any(isinstance(c, ast.Call) and getattr(c.func, "id", "") == "_run_sfs"
                        for c in ast.walk(t))]
if offenders:
    print("FAIL: tools not shelling out verbatim: " + ", ".join(offenders), file=sys.stderr)
    sys.exit(1)
PY

# ── (3) VERSIONED_EXTENSION_SURFACE anchor, single owner ────────────
fanchor "${SKILL}" "VERSIONED_EXTENSION_SURFACE" "versioned-extension anchor"
owners=0
while IFS= read -r f; do
  grep -Eq '^#{1,6}[[:space:]]+VERSIONED_EXTENSION_SURFACE[[:space:]]*$' "$f" && owners=$((owners + 1))
done < <(find "${CTX}" "${DIST_DIR}/docs" -name '*.md' -type f)
[[ "${owners}" -eq 1 ]] || fail "VERSIONED_EXTENSION_SURFACE must be defined once (found ${owners})"

fhas "${SKILL}" "is this a core change" "the discriminating question"
fhas "${SKILL}" "nowhere to go" "the extension-pressure consequence"
fhas "${SKILL}" "kernel.md" "solon instance 1: routed context extends, kernel fixed"
fhas "${SKILL}" "MCP_PROTOCOL_REVISION" "solon instance 3: the outward-facing pin"
fhas "${SKILL}" "widening the core is a design" "core-widening is surfaced, not routine"
# preserved neighbours
fanchor "${SKILL}" "SHADOW_MODE_TRUST_LADDER" "preserved skill-catalog anchor"

# ── (4) vendor lockout on the deferred enterprise surface ───────────
for f in "${SKILL}" "${SRV}" "${SRV_README}" "${RELPOL}"; do
  for s in "MCP Apps" "MCP Tasks" "Entra" "Okta" "OIDC provider" "connector directory" \
           "enterprise-managed auth"; do
    fnot "$f" "$s" "vendor/enterprise lockout in $(basename "$f")"
  done
done

# ── (5) budgets ─────────────────────────────────────────────────────
for f in "${SKILL}" "${RELPOL}"; do
  n="$(wc -l < "$f" | tr -d ' ')"
  [[ "$n" -le 200 ]] || fail "$(basename "$f") exceeds the 200-line budget: ${n}"
done

echo "PASS: protocol revision single source + stateless transport + versioned extension surface"
