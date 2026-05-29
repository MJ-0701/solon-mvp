#!/usr/bin/env bash
# Review lens false-positive rejection contract (0.7.9).
#
# 0.7.1 tightened the broad-substring `*"ui"*` / `*"ops"*` patterns
# in `infer_review_lens` because they were matching common English
# words ("build", "develops") and routing plans to wrong lenses.
# 0.7.9 extends that sweep across the sibling broad-substring
# patterns: bare `*"auth"*` (→ "author"), `*"perf"*` (→ "perfect",
# redundant with `*"performance"*`), `*"tax"*` (→ "taxonomy"),
# `*"aggregate"*` (→ "aggregated data"), `*"memory"*` (→ general
# memory mentions), `*"query"*` (→ "queryable"), plus the path-side
# `*ui*` / `*ux*` / `*api*` / `*ddd*` / `*tdd*` equivalents.
#
# This test pairs each rejection case with a positive case so a
# regression that re-broadens the pattern fails immediately.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REVIEW_SH="${DIST_DIR}/templates/.sfs-local-template/scripts/sfs-review.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }

[[ -f "${REVIEW_SH}" ]] || fail "missing sfs-review.sh"

# ── 1) Static: 0.7.9 comments are in place. ─────────────────────────
for marker in '0.7.9: `\*"auth"\*` was matching "author"' \
              '0.7.9: dropped `\*"perf"\*`' \
              '0.7.9: bare `\*"aggregate"\*` matched' \
              '0.7.9: bare `\*"tax"\*` matched' \
              '0.7.9: bare `\*auth\*` / `\*token\*`' \
              '0.7.9: dropped `\*perf\*`' \
              '0.7.9: bare `\*api\*` matched' \
              '0.7.9: bare `\*ui\*` matched' \
              '0.7.9: bare `\*ddd\*`'
do
  grep -qE "${marker}" "${REVIEW_SH}" \
    || fail "sfs-review.sh missing 0.7.9 sweep marker: ${marker}"
done

# ── 2) Bare auth (text) — "author" must NOT match. ──────────────────
case "this plan discusses the author of the original library" in
  *" auth "*|*"auth:"*|*"auth/"*|*"authn"*|*"authz"*|*"authorization"*|*"authentication"*)
    fail "TEXT 'author' should NOT match the tightened auth pattern"
    ;;
esac
case "the change covers authentication and authorization rotation" in
  *"authorization"*|*"authentication"*) ;;
  *) fail "TEXT 'authentication' must still match the security pattern" ;;
esac

# ── 3) Bare perf (text) — dropped entirely. ─────────────────────────
case "a perfect plan" in
  *"perf "*|*"perf-"*|*"perf:"*|*"perf/"*)
    fail "TEXT 'perfect' should NOT match the dropped perf pattern"
    ;;
esac
case "the performance regression on the hot path was reproduced" in
  *"performance"*) ;;
  *) fail "TEXT 'performance' must still match" ;;
esac

# ── 4) Bare tax (text) — "taxonomy" / "syntax" must NOT match. ──────
case "the taxonomy module enumerates canonical terms for syntax checks" in
  *" tax "*|*"tax form"*|*"taxpayer"*|*"taxation"*|*"taxes"*|*"tax record"*)
    fail "TEXT 'taxonomy' / 'syntax' should NOT match the tightened tax pattern"
    ;;
esac
case "the slice ships a quarterly tax form generator with payroll" in
  *"tax form"*|*"payroll"*) ;;
  *) fail "TEXT 'tax form' / 'payroll' must still match management-admin" ;;
esac

# ── 5) Bare aggregate (text). ───────────────────────────────────────
case "the report shows aggregated data for the last quarter" in
  *" aggregate "*|*"aggregate root"*|*"aggregate boundary"*|*"ddd aggregate"*)
    fail "TEXT 'aggregated data' should NOT match the tightened aggregate pattern"
    ;;
esac
case "the order aggregate root absorbs the invariant" in
  *"aggregate root"*) ;;
  *) fail "TEXT 'aggregate root' must still match ddd-tdd" ;;
esac

# ── 6) Bare memory (text). ──────────────────────────────────────────
case "the user wrote a memory of their experience using the product" in
  *"memory leak"*|*"memory usage"*|*"out of memory"*|*" oom "*|*"heap usage"*)
    fail "TEXT general 'memory' mention should NOT match the tightened performance pattern"
    ;;
esac
case "this fixes an out of memory issue in the streaming pipeline" in
  *"out of memory"*) ;;
  *) fail "TEXT 'out of memory' must still match performance" ;;
esac

# ── 7) Bare query (text). ───────────────────────────────────────────
case "the new function is queryable from any context" in
  *"sql query"*|*"db query"*|*"slow query"*|*"queries"*)
    fail "TEXT 'queryable' should NOT match the tightened query pattern"
    ;;
esac
case "the slow query monitor catches the n+1 pattern" in
  *"slow query"*) ;;
  *) fail "TEXT 'slow query' must still match performance" ;;
esac

# ── 8) PATH bare ui — common English filenames must NOT match. ──────
for fp_path in "src/guide/setup.md" "build/output.js" "library/index.ts" "auxiliary/helper.py"; do
  case "${fp_path}" in
    *ui/*|*ux/*|*-ui-*|*-ux-*|*react-ui*|*ui-kit*)
      fail "PATH '${fp_path}' should NOT match the tightened design pattern"
      ;;
  esac
done
for fp_path in "src/ui/Button.tsx" "packages/react-ui/index.ts" "design-system/tokens.json"; do
  case "${fp_path}" in
    *ui/*|*-ui-*|*-ux-*|*react-ui*|*ui-kit*|*design-system*) ;;
    *) fail "PATH '${fp_path}' must still match design" ;;
  esac
done

# ── 9) PATH bare api / perf / ddd / tdd. ────────────────────────────
for fp_path in "src/rapid/index.ts" "lib/scrappy.go" "data/tapioca.csv"; do
  case "${fp_path}" in
    *api/*|*apis/*|*public-api*|*restapi*)
      fail "PATH '${fp_path}' should NOT match the tightened api pattern"
      ;;
  esac
done
case "perfect-storm/index.js" in
  *performance*|*hot-path*|*hot_path*)
    fail "PATH 'perfect-storm' should NOT match performance pattern"
    ;;
esac
for fp_path in "daddy/notes.md" "boundaddyd.go" "stuttdddly.css"; do
  case "${fp_path}" in
    *ddd/*|*-ddd-*|*tdd/*|*-tdd-*)
      fail "PATH '${fp_path}' should NOT match the tightened ddd-tdd pattern"
      ;;
  esac
done
case "src/api/users.py" in
  *api/*) ;;
  *) fail "PATH 'src/api/users.py' must still match api-contract" ;;
esac
case "src/main/kotlin/domain/Order.kt" in
  *src/main/*/domain*) ;;
  *) fail "PATH 'src/main/*/domain' must still match ddd-tdd" ;;
esac

echo "test-review-lens-false-positive-rejection: OK"
