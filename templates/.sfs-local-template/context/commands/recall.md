---
id: sfs-command-recall
summary: Token-zero session recall over structured session/handoff/PROGRESS logs via grep/date index.
load_when: ["recall", "회상", "session recall", "handoff lookup", "과거 작업", "지난 세션"]
---

# Recall

`sfs recall <date|keyword>` finds past work without spending model tokens. It is
read-only and non-LLM: plain grep + date indexing over the structured logs SFS
already writes. Use it to restore context from a prior session before re-reading
or re-asking.

## Query forms

- Date — `YYYY-MM-DD` or `YYYYMMDD`. Lists dated session directories under
  `docs/solon/<workspace>/<yyyyMMdd>/` and their `handoff`/`report`/`retro`
  docs, plus event-ledger lines stamped with that date.
- Keyword — any free text. Greps `file:line` across `docs/solon/` and
  `.sfs-local/sprints/` markdown plus `.sfs-local/events.jsonl`.

## Contract

- Read-only: never writes, edits, stages, commits, or mutates a file. It only
  prints where the context lives.
- Token-zero: the search itself spends no model tokens; open the listed files to
  restore context.
- Packaged in the runtime dispatch, so thin-layout consumers get it through
  `brew upgrade` / `scoop update sfs` without per-project template work.

## Exit codes

- `0` — matches found.
- `1` — no matches.
- `2` — usage error (missing query / extra argument).
