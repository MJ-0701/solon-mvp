---
phase: implement
status: ready-for-review
sprint_id: "sfs-doc-tidy-release-notes"
goal: "SFS doc tidy command + update awareness + release notes policy"
created_at: "2026-05-01T18:27:08+09:00"
last_touched_at: 2026-05-01T19:06:14+09:00
---

# Implement — <sprint title>

> Implementation execution artifact. This file records the work slice, code
> changes, and verification evidence. It is not a substitute for changing code.
> AI implementation must preserve system design, not only satisfy the nearest
> edit request.
> 생명주기: 구현 중에는 evidence 를 충분히 남기되, close 후 최종 변경/검증 요약은
> `report.md` 로 정리된다. 본 파일 원문은 완료 뒤 archive 로 이동해 보존된다.

---

## §0. AI Coding Guardrails — Harness / Design / DDD / TDD

AI coding fails when it optimizes for the nearest change while ignoring the
system design. Treat bad code as expensive: unclear domain language, weak tests,
and irregular structure make future AI edits worse.

The first four guardrails are mandatory for code implementation, not just for
the final report. `/sfs implement` is complete only when the code slice is
small, scoped, verified, and ready to summarize.

- **Think before coding**: name assumptions, trade-offs, and success criteria
  before editing when the request is ambiguous.
- **Simplicity first**: implement the smallest code and document surface that
  proves the AC. Do not add flexibility or ceremony for imagined futures.
- **Surgical changes**: every changed line must connect to the requested slice.
  Leave unrelated cleanup as a finding or follow-up.
- **Goal-driven execution**: finish with verification evidence, not confidence.
- **Shared design concept first**: before editing, name the intended design,
  module boundary, and why this slice belongs there.
- **DDD language**: use the project's domain terms consistently in code,
  tests, filenames, and this artifact. If terms are missing, record them before
  implementing.
- **TDD feedback loop**: prefer a small failing/covering test first, then make
  it pass, then refactor. If a true test-first loop is impractical, record the
  reason and run the smallest useful verification before widening scope.
- **Regularity over cleverness**: follow existing codebase patterns. If a
  pattern is unclear or harmful, stop and record the refactor decision instead
  of adding another one-off.

## §1. Implementation Target

- **Work slice**: `sfs tidy` adapter + archive-first cleanup lifecycle + release note preflight.
- **Plan source**: `plan.md`
- **Implementation persona**: `.sfs-local/personas/implementation-worker.md`
- **Reasoning tier**: `execution_standard`
- **Model profile source**: `.sfs-local/model-profiles.yaml`
- **Runtime / resolved model / reasoning effort**: Codex current session.
- **Fallback if profile unset**: current runtime model
- **Agent model override used?** no
- **Acceptance criteria in scope**: dry-run, apply archive, report creation for legacy sprint, tmp cleanup, docs/skill exposure, release preflight.
- **Out of scope for this slice**: applying tidy to real historical user sprints; archive restore UI; background update notifier.
- **Shared design concept**: workbench files are active 노트패드; completed sprint surface keeps only durable report/retro/decision artifacts.
- **DDD terms touched**: workbench, report, retro, archive, tmp review artifact, release note preflight.

## §2. Execution Notes

- **Approach**: Extend shared cleanup helper from stub-writing compaction to archive-moving cleanup; add `sfs tidy` as explicit migration command; reuse same helper in report/retro cycle.
- **Files/modules expected to change**: `sfs-common.sh`, `sfs-tidy.sh`, dispatch/bin CLI, report/retro scripts, report template, README/GUIDE/SFS/agent command docs, `cut-release.sh`, `CHANGELOG.md`.
- **Test-first plan**: Bash syntax checks first, then temp project smoke for legacy sprint without `report.md`, tmp artifact movement, report compact path, release preflight pass/fail.
- **Risks / rollback notes**: Archive path growth is local and ignored by git; rollback is restoring files from `.sfs-local/archives/` because cleanup uses `mv`, not deletion.

## §3. Code Changes Made

- Added `sfs-tidy.sh` with dry-run default, `--sprint`, `--current`, `--all`, and `--apply`.
- Changed shared cleanup helper to move `brainstorm/plan/implement/log/review` into `.sfs-local/archives/sprints/<sid>/<timestamp>/` instead of writing visible stubs.
- Added tmp review artifact cleanup: matching `.sfs-local/tmp/**/<sprint-id>*` files move into the same archive tree and unrelated tmp files stay in place.
- Wired `tidy` into active/product dispatch, global `bin/sfs`, Codex/Claude/Gemini command docs, README/GUIDE/SFS docs, `.gitignore`, and report template.
- Reused the archive helper from `sfs report --compact` and `sfs retro --close`, so manual tidy and lifecycle close share the same cleanup behavior.
- Added `cut-release.sh` preflight: `--apply` fails when target `CHANGELOG.md` version entry is missing.
- Included the other session's agent/model setting guard changes in install/upgrade/templates/model profile docs.

## §4. Verification

- **Commands run**:
  - `bash -n` on product + active `sfs-common.sh`, `sfs-tidy.sh`, `sfs-dispatch.sh`, `sfs-report.sh`, `sfs-retro.sh`, `bin/sfs`, `install.sh`, `upgrade.sh`, `scripts/cut-release.sh`
  - temp project install/start/tidy smoke under `/private/tmp/sfs-tidy-smoke.REwE7D`
  - `sfs tidy --sprint 2026-W18-sprint-1` dry-run
  - `sfs tidy --sprint 2026-W18-sprint-1 --apply`
  - `sfs report --sprint 2026-W18-sprint-2 --compact`
  - `sfs report --sprint 2026-W18-sprint-3 --compact` after archive path output patch
  - `cut-release.sh --version 0.5.46-product --allow-dirty --allow-divergence`
  - `cut-release.sh --version 9.9.9-product --apply --allow-dirty --allow-divergence --no-tag`
- **Result**: PASS. Legacy sprint without `report.md` created `report.md`, moved 5 workbench files + 2 tmp files into archive, left only `report.md`/`retro.md` visible, and preserved unrelated tmp. Missing release note apply failed with exit 8.
- **Manual smoke / inspection**: `find` confirmed archive files and visible sprint files; `rg` confirmed no stale redirect/stub wording in managed docs.

## §5. Review Handoff

- **Ready for review?** yes
- **Recommended next gate**: `G4`
- **Next command**: `/sfs review --gate G4`

## 2026-05-01T18:31:58+09:00 — Implementation Request

```text
sfs tidy adapter + release note preflight 구현
```
