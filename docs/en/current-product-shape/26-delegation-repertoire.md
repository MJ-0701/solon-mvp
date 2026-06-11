---
doc_id: sfs-current-product-shape-en-26
title: "Standard delegation repertoire — for a one-person operator"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-06-11
parent: docs/en/current-product-shape.md
summary: "The official common workflows adapted to a one-person operator — a standard menu of delegation patterns: what to hand off, at which runtime tier, with what artifact."
load_when: "Read when deciding which recurring knowledge work to hand the agent, or building a personal delegation menu."
---
## Standard delegation repertoire — for a one-person operator

If you reason from zero every time about "should I give this to the AI," delegation
never grows. Capture the recurring knowledge work as *named patterns*, and next
time the same job appears you just pick the pattern. Below is a starting menu —
the official common-workflow set adapted to a one-person operator (source: "The
Claude Cowork product guide", 2026-06-05, by-reference — the exact workflow
names/count are publication-time product detail, so they are generalized here).

Each pattern assumes work that passes the five-factor test in
`policies/work-delegation-and-startup.md`. Tier choice follows that policy's
runtime axis (conversational / supervised session / autonomous code).

### Pattern menu

1. **Research brief** — investigate one topic across sources, compress to
   conclusion / evidence / open questions. Tier: supervised session. Artifact: a
   brief with citations.
2. **Decision / meeting prep** — gather scattered material into the key issues,
   options, and a recommendation. Tier: supervised session. Artifact: a
   one-page decision note.
3. **Recurring report** — generate the same-shape weekly/monthly report from its
   sources. Tier: supervised session + scheduled trigger. Artifact: a
   structured report.
   Externally validated: spreadsheet → weekly report, log/metric watch →
   anomaly brief ("New in Claude Managed Agents", 2026-06-09, by-reference).
   Operating contract for scheduled runs:
   `policies/work-delegation-and-startup.md` SCHEDULED_RUN_CONTRACT.
4. **Inbox / issue triage** — classify and prioritize incoming items and attach
   draft responses. Tier: supervised session. Artifact: a sorted queue + draft
   replies.
5. **Source-grounded drafting** — write a new outbound artifact (email, notice,
   doc) grounded in existing docs/notes. Tier: supervised session. Artifact: a
   review-ready draft (re-read the current source before writing,
   `policies/source-pointer-citation.md`).
6. **Data pull & summarize** — extract from logs/sheets/responses into a
   one-screen summary and next actions. Tier: supervised session, or autonomous
   code for repo data. Artifact: a summary + action list.
7. **Long-running task** — multi-step build, migration, audit — work that does
   not finish in one turn. Tier: autonomous code under a gated `loop`, with a
   handoff (`commands/loop.md`).

### Where it meets the Solon workflow

- Bracket the day with the bookend operating loop — the morning brief routines
  patterns 1 and 6, the evening recap routines pattern 3 (`commands/daily.md`).
- For every pattern, reading, understanding, and forming an opinion on the
  output stays human (`current-product-shape/24-topdown-learning-guide.md`).
- One-off / repeated / batch routing follows
  `policies/ai-work-intake-routing.md`.
</content>
