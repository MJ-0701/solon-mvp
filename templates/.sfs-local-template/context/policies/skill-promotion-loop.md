---
id: sfs-skill-promotion-loop
summary: Suggest (never auto-create) skill/command candidates from repeated completed-work patterns; the success-path twin of lessons-accumulation.
load_when: ["skill promotion", "promote to skill", "repeated task", "skill candidate", "tidy skill-promote", "compile a skill", "recurring workflow", "automate repeated work"]
---

# Skill Promotion Loop

`lessons-accumulation.md` captures repeated **failures** as avoidance rules. This
policy is its twin on the **success** side: a task done the same way three times
is a skill or command waiting to be compiled. Source: note 27 (Hermes turns
every completed task into a reusable, human-editable skill MD — "작업→스킬
자산화"). The unit of growth is an editable Markdown skill/command, exactly
Solon's docs-first format, so promotion is a curation step, not code generation.

## SUGGEST_ONLY

The loop is **read-only and suggest-only**. It surfaces candidates; a human (or
the agent under explicit instruction) decides whether to compile one. It never
writes a skill file, never edits the catalog, and never blocks. This keeps the
catalog from filling with ceremony skills — a candidate is only worth compiling
when a real repeated task needs it (see `skill-catalog-discipline.md`: do not pad
thin buckets).

## DETECTION

`sfs harness doctor` adds a **Skill Promotion Candidates** section that reads the
consumer project's completed-work logs only (`PROGRESS.md`,
`docs/solon/*/PROGRESS.md`, `HANDOFF-next-session.md`), never the shipped
distribution. It normalizes each finished task line (`- [x]` / `- [X]`) into a
signature — ASCII-lowercased, digits and punctuation stripped, whitespace
collapsed (non-ASCII text such as Korean task lines is preserved) — so
version/date-stamped repeats (`release cut 0.8.23/24/25`) collapse to one
`release cut` signature. When a signature recurs at the promote threshold
(**3+**) it emits an `info` candidate. The section emits only `info`/`ok`, so it
never changes the doctor exit code.

The signature is a coarse heuristic; it groups by shared wording, not semantic
intent. A surfaced candidate is a prompt to look, not a verdict.

## ACTING_ON_A_CANDIDATE

This runs on the existing `tidy` rail — no new lifecycle command (the kernel
absorbs disciplines as policies/lenses, not commands). At `tidy`/retro time, run
`sfs harness doctor`, read the candidates, and for a worthwhile one compile a
skill/command the normal way: give it a trigger-centric `load_when`, an `_INDEX`
route, and the workflow+guard shape from `skill-catalog-discipline.md`. Record
the decision (promoted, or deferred with reason) so a candidate is not re-surfaced
without context.

## CROSS_REFERENCES

- Failure-side twin (avoidance rules): `lessons-accumulation.md`.
- Catalog discipline + nine-category lens the new skill must fit: `skill-catalog-discipline.md`.
- Tidy/retro rail that consumes candidates: `commands/tidy.md`.
- Line budget for this file: `md-line-budget.md`.
</content>
