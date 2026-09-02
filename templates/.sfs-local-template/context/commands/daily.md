---
id: sfs-command-daily
summary: Bookend daily operating loop for a one-person operator — a morning brief and an evening recap that compose existing runnable commands; not a separate binary.
load_when: ["daily", "daily brief", "daily recap", "start my day", "end my day", "bookend", "daily handoff", "manager report", "운영 루프", "하루 시작", "하루 마무리", "오늘 뭐부터", "일일 보고"]
---

# Daily

A bookend operating loop for a one-person operator: open the day with a **brief**
and close it with a **recap**. It is a *composition* of commands SFS already
ships, not a new executable — there is no `sfs daily` binary. Run the named
primitives directly; this doc is the routine that strings them together so the
agent can manage the operator's day instead of the operator re-deriving the
routine each morning.

## Grain

The single source of truth for the recommended morning/evening loop that turns
SFS's existing primitives into a daily operator rhythm.

## Scope

Covers: which existing commands to run, in what order, to start and end a working
day, what each step produces, and the manager-readable handoff publication refreshed
at Gate 6 and finalized by the normal Gate 7 close (MANAGER_HANDOFF). Does NOT cover: any new command, scheduler,
calendar/email integration, or external connector — those stay out of the SFS
core (vendor-specific automation is a consumer extension, not promoted here).

## Usage

Open this when the operator says "start my day" / "what first today" /
"wrap up the day" / "하루 시작" / "하루 마무리", or before/after a working
session to restore and then persist context cheaply.

## MORNING_BRIEF

Orient the day from durable state, spending as few model tokens as possible:

1. `sfs status` — current sprint / work-unit state, the authoritative starting
   point (kernel: "Start from `sfs status`").
2. `sfs recall <yesterday|keyword>` — token-zero recall over the prior session's
   handoff / report / retro so yesterday's resume note and open threads return
   without re-reading or re-asking.
3. From those two, name **today's focus**: the next unmet AC or the resume note
   the handoff already records. If intent is unclear, ask the smallest blocking
   question rather than guessing.

The brief reads only; it does not start implementation by itself.

## EVENING_RECAP

Close the day so tomorrow's brief is cheap and lossless:

1. `sfs capture --kind <decision|blocker|waiver|...>` — persist any approval,
   decision, blocker, or external evidence a later gate must remember (capture is
   an evidence primitive, not a routine lifecycle step — record only what matters).
2. `sfs retro` — normal Gate 7 close. It finalizes report/retro in the dated
   `docs/solon/<workspace>/<yyyyMMdd>/` handoff directory, automatically
   publishes `daily-handoff.md` and `daily-handoff.html`, then compacts the
   workbench. Publication failure aborts the close; it is never skipped.
3. `sfs tidy` — optionally sweep other already-closed workbench surfaces. The
   default `sfs retro` has already compacted its current sprint, so `tidy` is
   maintenance composition, not a separate daily-handoff publication step.
4. Optionally `sfs loop` to queue the next slice so the morning brief starts with
   a primed next action.

The recap's output (handoff / report) is exactly what the next `MORNING_BRIEF`
restores — the two ends close the loop.

## MANAGER_HANDOFF

This is automatic lifecycle output, not a user-run record-generation step. The
Markdown handoff is authoritative; the HTML is a derived projection — regenerate
it, never hand-edit it.

1. **Gate 3 (Plan) — decision capture.** When a durable choice qualifies under
   `docs/maintenance/adr-policy.md`, create the ADR before implementation and
   mention its existing `ADR-NNNN` in the report or retro decision evidence.
   Routine choices add no ADR.
2. **Gate 6 (Review) — per-work-unit refresh.** Every actual evaluator run for
   Gate 6 that completes with a non-failing recorded verdict refreshes the dated
   `daily-handoff.md` and derived `daily-handoff.html` automatically. While
   Gate 7 is unavailable, the publisher cites the available report and review
   evidence; prompt-only/print/show paths, failed executors, failing or
   unknown verdicts, and other gates do not publish. A refresh failure fails the
   review before it claims completion.
3. **Gate 7 (Retro) — finalization.** Default `sfs retro` enriches and
   finalizes the same handoff after report/retro generation and before
   workbench/event compaction. It adds the available retro evidence alongside
   report and (when it exists) review, preserves the marked human-notes block on rerun, and
   fails the close if either artifact cannot be published.

## Gotchas

- Not a binary. `sfs daily` does not exist; running it will fail. Invoke the
  primitives (`status` / `recall` / `capture` / `tidy` / `loop`) directly.
- Standalone guarantee intact. Every primitive behaves identically with or
  without this doc; the loop is advisory convenience, never a dependency.
- Do not let the recap balloon. `capture` only durable evidence, `tidy` only
  closed work; routine chatter does not belong in the dated record.
- The handoff HTML is derived output. Edit the Markdown input and regenerate;
  hand-edits to the HTML are lost on the next automatic Gate 6 refresh or Gate
  7 finalization. Put manual
  additions only inside the generated human-notes marker block.

## Cross-Ref

- Token-zero recall mechanics: `commands/recall.md`.
- Evidence primitive contract: `commands/capture.md`.
- Report / retro / archive: `commands/tidy.md`.
- Queue / autonomous slice: `commands/loop.md`.
- Manager handoff shape: `sprint-templates/daily-handoff.md`.
- Internal Gate 6/7 publisher + derived renderer: `scripts/sfs-publish-daily-handoff.sh`
  and `scripts/daily-handoff-html.sh`. Neither is a user command; regression locks
  `tests/test-daily-handoff-html.sh`, `tests/test-sfs-review-daily-handoff.sh`,
  and `tests/test-sfs-retro-daily-handoff.sh`.
- Standard delegation repertoire (which work to hand off): `policies/work-delegation-and-startup.md`.
- Parent route: `_INDEX.md` (`commands/daily.md`).

Provenance: Source-grade derived | Confidence high | Reviewed self-CPO |
Freshness 2026-06-07 | Owner SFS maintainer.
