#!/usr/bin/env bash
# tests/test-sfs-upgrade-minimal-residue-migration.sh — same-version upgrade compacts legacy visible residue.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SFS_BIN="${DIST_DIR}/bin/sfs"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sfs-upgrade-min-residue.XXXXXX")"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

cd "${TMP_DIR}"
git init -q
printf '# Legacy Residue Project\n' > README.md
git add README.md
git -c user.name='SFS Test' -c user.email='sfs-test@example.invalid' commit -qm 'initial'

SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" init --layout thin --yes >/dev/null

mkdir -p .sfs-local/sprints/legacy-baseline
cat > .sfs-local/sprints/legacy-baseline/report.md <<'EOF'
---
phase: report
status: legacy-baseline
sprint_id: "legacy-baseline"
---

# Report — Legacy Baseline Intake

Project facts that should become the shared adoption handoff.
EOF
printf '# Retro\n\nlegacy notes\n' > .sfs-local/sprints/legacy-baseline/retro.md

mkdir -p .sfs-local/sprints/2026-W19-sprint-1
touch .sfs-local/sprints/.gitkeep
for doc in brainstorm plan implement log review retro; do
  cat > ".sfs-local/sprints/2026-W19-sprint-1/${doc}.md" <<EOF
---
phase: ${doc}
sprint_id: "2026-W19-sprint-1"
last_touched_at: ""
---

# ${doc}

Old runtime prefilled template residue.
EOF
done
printf '2026-W19-sprint-1\n' > .sfs-local/current-sprint
printf '{"ts":"2026-05-05T22:40:00+09:00","type":"sprint_start","sprint_id":"2026-W18-sprint-9","goal":"closed"}\n' >> .sfs-local/events.jsonl
printf '{"ts":"2026-05-05T22:41:00+09:00","type":"plan_open","sprint_id":"2026-W18-sprint-9","path":".sfs-local/sprints/2026-W18-sprint-9/plan.md"}\n' >> .sfs-local/events.jsonl
printf '{"ts":"2026-05-05T22:42:00+09:00","type":"sprint_close","sprint_id":"2026-W18-sprint-9"}\n' >> .sfs-local/events.jsonl
printf '{"ts":"2026-05-05T23:47:46+09:00","type":"sprint_start","sprint_id":"2026-W19-sprint-1","goal":"residue","by":"sfs-start"}\n' >> .sfs-local/events.jsonl
mkdir -p .sfs-local/cache .sfs-local/tmp/empty-leftover .sfs-local/queue/pending
printf 'last_checked_epoch=0\nlatest=0.0.0\n' > .sfs-local/cache/version-notice.env
printf 'last_checked_epoch=0\n' > .sfs-local/cache/hygiene-notice.env
printf '# old local auth sample\n' > .sfs-local/auth.env.example
printf '# placeholder only\n' > .sfs-local/auth.env

SFS_MODEL_PROFILE_PROMPT=0 \
SFS_SKIP_CLI_DISCOVERY=1 \
SFS_COMMAND_TIMEOUT_SEC=0 \
bash "${DIST_DIR}/upgrade.sh" --yes --layout thin >/tmp/sfs-upgrade-min-residue.out

SHARED_DOC="docs/solon/legacy-baseline/$(date +%Y%m%d)/handoff.md"
[[ -f "${SHARED_DOC}" ]] || fail "missing migrated shared adoption doc"
grep -Fq "Project facts that should become the shared adoption handoff." "${SHARED_DOC}" \
  || fail "shared adoption doc did not preserve legacy report body"
[[ ! -d .sfs-local/sprints/legacy-baseline ]] || fail "legacy-baseline visible sprint should be archived away"
find .sfs-local/archives/adopt/legacy-baseline -name visible-sprint-workspace.tar.gz -type f | grep -q . \
  || fail "missing legacy-baseline visible sprint cold archive"

for doc in brainstorm plan implement log review retro; do
  [[ ! -e ".sfs-local/sprints/2026-W19-sprint-1/${doc}.md" ]] \
    || fail "prefilled ${doc}.md should be archived away"
done
[[ ! -e .sfs-local/sprints/.gitkeep ]] || fail "legacy sprints .gitkeep should be removed"
[[ "$(cat .sfs-local/current-sprint)" = "2026-W19-sprint-1" ]] || fail "active sprint pointer should remain"
[[ ! -e .sfs-local/auth.env.example ]] || fail "upgrade should remove project-local auth.env.example sample"
[[ ! -e .sfs-local/auth.env ]] || fail "placeholder auth.env should be removed"
[[ ! -d .sfs-local/cache ]] || fail "empty cache dir should be removed"
[[ ! -d .sfs-local/tmp ]] || fail "empty tmp dir should be removed"
[[ ! -d .sfs-local/queue ]] || fail "empty queue dir should be removed"
[[ ! -d .sfs-local/archives/runtime-migrations ]] || fail "runtime-migrations bucket should be collapsed under archives/adopt"
[[ ! -d .sfs-local/archives/runtime-upgrades ]] || fail "runtime-upgrades bucket should be collapsed under archives/adopt"
[[ ! -d .sfs-local/archives/sprints ]] || fail "sprints archive bucket should be collapsed under archives/adopt"

archive_index="$(mktemp "${TMP_DIR}/archives.XXXXXX")"
surface_extract="${TMP_DIR}/surface-extract"
mkdir -p "${surface_extract}"
while IFS= read -r bundle; do
  tar -xzf "${bundle}" -C "${surface_extract}"
done < <(find .sfs-local/archives/adopt/surface-cleanup -name surface-cleanup.tar.gz -type f | sort)
while IFS= read -r archive; do
  tar -tzf "${archive}" >> "${archive_index}"
done < <(
  {
    find .sfs-local/archives/adopt -path '*/surface-cleanup/*' -prune -o -name preexisting-archives.tar.gz -type f -print
    find "${surface_extract}" -name preexisting-archives.tar.gz -type f -print
  } | sort
)
grep -Fq '2026-W19-sprint-1-step-docs.tar.gz' "${archive_index}" \
  || fail "missing prefilled step-doc cold archive inside collapsed archive bucket"
grep -Fq 'auth-env-example.tar.gz' "${archive_index}" \
  || fail "missing auth.env.example cold archive inside collapsed archive bucket"

! grep -Fq '"sprint_id":"2026-W18-sprint-9"' .sfs-local/events.jsonl \
  || fail "closed sprint event lines should not remain after upgrade"
! grep -Fq '"type":"legacy_adopt_surface_migrated"' .sfs-local/events.jsonl \
  || fail "legacy adopt migration event should be archive/doc evidence, not active ledger residue"
grep -Fq '"type":"prefilled_step_docs_compacted"' .sfs-local/events.jsonl \
  || fail "missing prefilled step-doc compaction event"
! grep -Eq '\}\}$' .sfs-local/events.jsonl || fail "events.jsonl contains a double-closing-brace line"

status_out="$(SFS_COMMAND_TIMEOUT_SEC=0 SFS_DIST_DIR="${DIST_DIR}" bash "${SFS_BIN}" status)"
case "${status_out}" in
  *"sprint 2026-W19-sprint-1"* ) ;;
  *) fail "status did not preserve active sprint: ${status_out}" ;;
esac

echo "test-sfs-upgrade-minimal-residue-migration: OK"
