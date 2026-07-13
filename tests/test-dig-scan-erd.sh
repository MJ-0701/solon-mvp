#!/usr/bin/env bash
# sfs dig A — L0 deterministic scan + ERD-first headline.
#
# Locks, against two framework fixtures (spring-jpa / node-prisma):
#   - framework/entrypoint/route/env/schema-source detection with file:line
#   - ERD extraction to mermaid + evidence table (SQL migration priority,
#     prisma fallback), FK edges present
#   - env keys are NAMES ONLY — no value (credential) ever enters the artifact
#   - --live-schema TSV diff reports structure-only differences
#   - zero-LLM guarantee: the script never invokes an LLM or network
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DIG="${DIST_DIR}/scripts/sfs-dig.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
fhas() { grep -Fq -- "$2" "$1" || fail "$3: missing '$2' in $1"; }
fnot() { if grep -Fq -- "$2" "$1"; then fail "$3: unexpected '$2' in $1"; fi; }

TMP="$(mktemp -d "${TMPDIR:-/tmp}/sfs-dig-scan.XXXXXX")"
trap 'rm -rf "${TMP}"' EXIT

# ── zero-LLM / zero-network guarantee (static) ───────────────────────
# Guard the transitive closure dig actually executes at runtime: sfs-dig.sh
# itself AND sfs-harness.sh (dig scan shells `sfs-harness.sh doctor` for the
# Sanity precheck). A network/LLM call added to either would break determinism.
# Invocation-shaped patterns (not the bare vendor word, which appears as an
# adapter-name string / comment in sfs-harness.sh); comment lines are skipped.
det_pattern='(curl|wget)[[:space:]]|claude[[:space:]]+-p|codex[[:space:]]+exec|gemini[[:space:]]+-p|agy[[:space:]]+-p'
for det in "${DIG}" "${DIST_DIR}/scripts/sfs-harness.sh"; do
  if grep -nE "${det_pattern}" "${det}" | grep -vqE '^[0-9]+:[[:space:]]*#'; then
    grep -nE "${det_pattern}" "${det}" | grep -vE '^[0-9]+:[[:space:]]*#' >&2
    fail "$(basename "${det}") must be deterministic: no network/LLM invocation on dig's runtime path"
  fi
done

# ── spring-jpa fixture ───────────────────────────────────────────────
cp -R "${SCRIPT_DIR}/fixtures/dig/spring-jpa" "${TMP}/spring-jpa"
cd "${TMP}/spring-jpa"
bash "${DIG}" scan --write >/dev/null 2>&1 || fail "scan failed on spring-jpa"
EXC="docs/solon/spring-jpa/excavation"
[[ -f "${EXC}/00-scan.md" ]] || fail "spring: 00-scan.md not written"
[[ -f "${EXC}/erd.md" ]] || fail "spring: erd.md not written"
fhas "${EXC}/00-scan.md" "spring-boot	pom.xml" "spring framework detection"
fhas "${EXC}/00-scan.md" "spring-boot main" "spring entrypoint"
fhas "${EXC}/00-scan.md" 'OrderController.java:18	spring	@GetMapping' "spring route file:line"
fhas "${EXC}/00-scan.md" "sql-migration	src/main/resources/db/migration/V1__init.sql" "sql schema source"
fhas "${EXC}/00-scan.md" "jpa-entity" "jpa schema source"
fhas "${EXC}/erd.md" "erDiagram" "mermaid erd block"
fhas "${EXC}/erd.md" "customers {" "erd customers table"
fhas "${EXC}/erd.md" "orders {" "erd orders table"
fhas "${EXC}/erd.md" 'orders }o--|| customers : "customer_id"' "erd FK edge"
fhas "${EXC}/erd.md" "V1__init.sql:16" "FK evidence file:line"
fnot "${EXC}/erd.md" "VARCHAR(255)" "mermaid types are paren-sanitized"
fhas "${EXC}/state" "sanity_result=" "state records sanity"
fhas "${EXC}/state" "function_total=" "state records function total"

# ── node-prisma fixture (+ live-schema diff, + credential hygiene) ──
cp -R "${SCRIPT_DIR}/fixtures/dig/node-prisma" "${TMP}/node-prisma"
cd "${TMP}/node-prisma"
# live schema: User has an extra column deleted_at that code does not know
printf 'User\tid\tinteger\nUser\temail\ttext\nUser\tname\ttext\nUser\tdeleted_at\ttimestamp\nPost\tid\tinteger\nPost\ttitle\ttext\nPost\tbody\ttext\nPost\tauthorId\tinteger\n' > "${TMP}/live.tsv"
bash "${DIG}" scan --write --live-schema "${TMP}/live.tsv" >/dev/null 2>&1 || fail "scan failed on node-prisma"
EXC="docs/solon/node-prisma/excavation"
fhas "${EXC}/00-scan.md" "express	package.json" "express detection"
fhas "${EXC}/00-scan.md" "prisma	package.json" "prisma detection"
fhas "${EXC}/00-scan.md" "DATABASE_URL" "env key name recorded"
fnot "${EXC}/00-scan.md" "postgres://" "env VALUE never recorded (credential hygiene)"
fnot "${EXC}/00-scan.md" "user:pass" "credential fragment never recorded"
fhas "${EXC}/erd.md" "User {" "prisma erd user"
fhas "${EXC}/erd.md" 'Post }o--|| User : "authorId"' "prisma FK from @relation"
fhas "${EXC}/erd.md" "schema.prisma:" "prisma evidence file:line"
[[ -f "${EXC}/erd-diff.md" ]] || fail "erd-diff.md not written with --live-schema"
fhas "${EXC}/erd-diff.md" "user.deleted_at" "live-only column surfaced in diff"
fnot "${EXC}/erd-diff.md" "postgres://" "diff carries structure only"

# ── regression: lowercase SQL + inline REFERENCES (BSD-awk portability #5) ──
mkdir -p "${TMP}/lc/db/migration"
printf 'create table teams (\n  id bigint primary key,\n  name varchar(80),\n  owner_id bigint references users(id)\n);\n' \
  > "${TMP}/lc/db/migration/0001_init.sql"
cd "${TMP}/lc"
bash "${DIG}" scan --write >/dev/null 2>&1 || fail "lowercase SQL scan failed"
LC="docs/solon/lc/excavation/erd.md"
fhas "${LC}" "teams {" "#5 lowercase CREATE TABLE parsed"
fhas "${LC}" "owner_id" "#5 lowercase column parsed"
fhas "${LC}" 'teams }o--|| users : "owner_id"' "#5 inline REFERENCES becomes an FK edge"

# ── regression: Prisma inverse relation must NOT invent a phantom FK (#6) ──
mkdir -p "${TMP}/inv/prisma"
cat > "${TMP}/inv/prisma/schema.prisma" <<'PRISMA'
model User {
  id    Int    @id @default(autoincrement())
  posts Post[] @relation("UserPosts")
}

model Post {
  id       Int  @id @default(autoincrement())
  author   User @relation("UserPosts", fields: [authorId], references: [id])
  authorId Int
}
PRISMA
printf '{"name":"inv","dependencies":{"@prisma/client":"^5.0.0"}}\n' > "${TMP}/inv/package.json"
cd "${TMP}/inv"
bash "${DIG}" scan --write >/dev/null 2>&1 || fail "prisma inverse scan failed"
INV="docs/solon/inv/excavation/erd.md"
fhas "${INV}" 'Post }o--|| User : "authorId"' "#6 owner-side FK present"
grep -qE 'User \}o--\|\| Post' "${INV}" && fail "#6 inverse relation must not emit a phantom FK"

# ── regression: named CONSTRAINT FK + CHECK constraint (round-2 #3) ──
mkdir -p "${TMP}/con/db/migrations"
cat > "${TMP}/con/db/migrations/0001.sql" <<'SQL'
CREATE TABLE accounts (
  id BIGINT PRIMARY KEY,
  balance BIGINT,
  owner_id BIGINT,
  CHECK (balance >= 0),
  CONSTRAINT fk_owner FOREIGN KEY (owner_id) REFERENCES users(id)
);
SQL
cd "${TMP}/con"
bash "${DIG}" scan --write >/dev/null 2>&1 || fail "constraint SQL scan failed"
CON="docs/solon/con/excavation/erd.md"
fhas "${CON}" 'accounts }o--|| users : "owner_id"' "#3 named CONSTRAINT FK is an FK edge, not IDX"
grep -qE '^ *(CHECK|check) ' "${CON}" && fail "#3 CHECK must not become a column named CHECK"

# ── safety boundary: no-write default + target read-only + traversal ──
# (review-round-3 gaps — dig runs against a user's undocumented repo)
mkdir -p "${TMP}/safe/src"
printf 'const x=1;\n' > "${TMP}/safe/src/a.js"
printf '{"name":"safe","dependencies":{"express":"^4.0.0"}}\n' > "${TMP}/safe/package.json"
cd "${TMP}/safe"
# checksum every source file before any dig run (target must stay byte-identical)
pre_sum="$(find . -type f ! -path './docs/solon/*' -exec shasum {} \; | LC_ALL=C sort)"

# no-write default: stdout preview only, NO docs/solon/ created
out="$(bash "${DIG}" scan 2>/dev/null)"
[[ -n "${out}" ]] || fail "dig scan without --write must print a preview to stdout"
[[ ! -d "docs/solon" ]] || fail "dig scan without --write must NOT create docs/solon/"
bash "${DIG}" graph >/dev/null 2>&1
[[ ! -d "docs/solon" ]] || fail "dig graph without --write must NOT create docs/solon/"

# target source read-only: even with --write, only docs/solon/ appears; source unchanged
bash "${DIG}" scan --write >/dev/null 2>&1
bash "${DIG}" graph --write >/dev/null 2>&1
post_sum="$(find . -type f ! -path './docs/solon/*' -exec shasum {} \; | LC_ALL=C sort)"
[[ "${pre_sum}" == "${post_sum}" ]] || fail "dig must never modify target source files (read-only invariant)"

# --domain path traversal must be slugified, never escape docs/solon/
bash "${DIG}" scan --write --domain '../../escape' >/dev/null 2>&1 || true
[[ ! -e "${TMP}/escape" && ! -e "${TMP}/safe/../../escape" ]] \
  || fail "dig --domain must not write outside docs/solon/ (traversal guard)"

echo "test-dig-scan-erd: OK"
