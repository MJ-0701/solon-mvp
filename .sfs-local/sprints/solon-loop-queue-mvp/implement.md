---
phase: implement
status: ready-for-review
sprint_id: "solon-loop-queue-mvp"
goal: "Apply SFS harness document lifecycle across all phases"
created_at: "2026-05-01T17:12:20+09:00"
last_touched_at: "2026-05-01T17:37:03+09:00"
---

# Implement — <sprint title>

> Implementation execution artifact. This file records the work slice, code
> changes, and verification evidence. It is not a substitute for changing code.
> AI implementation must preserve system design, not only satisfy the nearest
> edit request.

---

## §0. AI Coding Guardrails — Design / DDD / TDD

AI coding fails when it optimizes for the nearest change while ignoring the
system design. Treat bad code as expensive: unclear domain language, weak tests,
and irregular structure make future AI edits worse.

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

- **Work slice**: SFS document lifecycle harness: workbench during execution, compact final report after completion.
- **Plan source**: user directive in current session. Existing `plan.md` belongs to the prior queue sprint, so this artifact records the new implementation slice explicitly instead of pretending the old plan is the source.
- **Implementation persona**: `.sfs-local/personas/implementation-worker.md`
- **Reasoning tier**: `execution_standard`
- **Model profile source**: `.sfs-local/model-profiles.yaml`
- **Runtime / resolved model / reasoning effort**: Codex current runtime.
- **Fallback if profile unset**: current runtime model
- **Agent model override used?** no
- **Acceptance criteria in scope**:
  - `/sfs report` exists and creates/updates `report.md`.
  - `--compact` explicitly converts `brainstorm/plan/implement/log/review` to short redirect stubs.
  - `retro --close` prepares final report and compacts workbench docs.
  - SFS/adapter docs describe notepad vs report lifecycle across Claude/Codex/Gemini.
- **Out of scope for this slice**: automatic cleanup of old sprint history without explicit user consent.
- **Shared design concept**: workbench artifacts are active scratch space; `report.md` is the closed-sprint reading entry.
- **DDD terms touched**: workbench, final report, compact stub, retro history.

## §2. Execution Notes

- **Approach**: add the smallest runtime command (`sfs-report.sh`) and shared helper functions, then wire dispatch/bin/update/docs/agent adapters to the same lifecycle.
- **Files/modules expected to change**: SFS runtime scripts, sprint templates, SFS docs, agent command templates, current installed project adapters.
- **Test-first plan**: syntax checks first; temp-project smoke for `sfs init` → `sfs start` → `sfs report` → `sfs report --compact`.
- **Risks / rollback notes**: direct `--compact` relies on explicit user intent; AI adapters instruct report refinement before compaction.

## §3. Code Changes Made

- Added `sfs-report.sh` and `report.md` sprint template in product dist and active project runtime.
- Added `sfs_prepare_sprint_report` and `sfs_compact_sprint_workbench` helpers.
- Wired `report` into `bin/sfs`, `sfs-dispatch.sh`, `upgrade.sh`, active/project adapters, and Claude/Codex/Gemini command docs.
- Updated sprint templates and guides to separate active workbench docs from completed report/retro artifacts.
- Updated `retro --close` to finalize `report.md` and compact workbench docs after sprint close bookkeeping.

## §4. Verification

- **Commands run**:
  - `bash -n` on product and active `sfs-common.sh`, `sfs-report.sh`, `sfs-retro.sh`, `sfs-dispatch.sh`, `sfs-start.sh`, `bin/sfs`, `install.sh`, `upgrade.sh`.
  - temp-project smoke: local dist `bin/sfs init --yes --layout thin`; `sfs start --id smoke-sprint`; `sfs report`; `sfs report --compact`; grep checks for final report + compact stubs.
- **Result**: PASS. First smoke surfaced a `printf` portability bug in compact stubs; fixed and reran PASS.
- **Manual smoke / inspection**: verified `report` appears in command surfaces and that `brainstorm/plan/review` stubs point to `report.md` + `retro.md`.

## §5. Review Handoff

- **Ready for review?** yes
- **Recommended next gate**: `G4`
- **Next command**: `/sfs review --gate G4`

## 2026-05-01T17:12:20+09:00 — Implementation Request

```text
apply harness-style document lifecycle across all SFS phases: active workbench docs may be verbose, completed sprint artifacts must be compact final reports with raw history delegated to retro/session logs
```
