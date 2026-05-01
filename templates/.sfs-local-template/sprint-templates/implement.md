---
phase: implement
status: draft
sprint_id: ""          # filled by /sfs start
goal: ""               # filled by /sfs start <goal>
created_at: ""         # filled by /sfs start
last_touched_at: ""
---

# Implement — <sprint title>

> Implementation execution artifact. This file records the work slice, code
> changes, and verification evidence. It is not a substitute for changing code.
> AI implementation must preserve system design, not only satisfy the nearest
> edit request.
> 생명주기: 구현 중에는 evidence 를 충분히 남기되, close 후 최종 변경/검증 요약은
> `report.md` 로 압축된다. 본 파일은 완료 뒤 compact stub 대상이다.

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

- **Work slice**:
- **Plan source**: `plan.md`
- **Implementation persona**: `.sfs-local/personas/implementation-worker.md`
- **Reasoning tier**: `execution_standard`
- **Model profile source**: `.sfs-local/model-profiles.yaml`
- **Runtime / resolved model / reasoning effort**:
- **Fallback if profile unset**: current runtime model
- **Agent model override used?** no
- **Acceptance criteria in scope**:
- **Out of scope for this slice**:
- **Shared design concept**:
- **DDD terms touched**:

## §2. Execution Notes

- **Approach**:
- **Files/modules expected to change**:
- **Test-first plan**:
- **Risks / rollback notes**:

## §3. Code Changes Made

- 

## §4. Verification

- **Commands run**:
- **Result**:
- **Manual smoke / inspection**:

## §5. Review Handoff

- **Ready for review?** no
- **Recommended next gate**: `G4`
- **Next command**: `/sfs review --gate G4`
