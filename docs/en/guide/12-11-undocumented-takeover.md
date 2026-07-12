---
doc_id: sfs-product-guide-en-12
title: "11. Taking Over an Undocumented Codebase (dig)"
visibility: oss-public
doc_type: user-guide
language: en
updated: 2026-07-13
parent: docs/en/guide.md
summary: "Reverse-engineer a handover-less legacy codebase from the code itself — with a first-day 30-minute checklist"
load_when: "Read when docs/en/guide.md routes to this section."
---
## 11. Taking Over an Undocumented Codebase (dig)

When you inherit a codebase with no handover docs, no spec, and an untrustworthy
git history, `sfs dig` reverse-engineers the project overview and ERD from the
code. The direction is bottom-up (code → evidence → synthesis); L0 (scan/ERD)
and L1 (graph/queue) complete deterministically with zero LLM tokens. The
target code is never modified (read-only).

### Sequence (A→B→C→D→E)

1. **A. `sfs dig scan --write`** — detect frameworks / entrypoints / routes /
   env-var keys / schema sources and extract the **ERD first** (`erd.md`,
   mermaid + file:line evidence). If you can reach the real DB, dump
   `information_schema` to a TSV yourself and pass `--live-schema` to diff it
   against the code-derived ERD — connection credentials and data rows are
   never stored anywhere.
2. **B. `sfs dig graph --write`** — build the import / route→service→table
   graph and the L2 traversal queue (BFS from entrypoints; dead-code
   candidates last).
3. **C. fact cards** — delegate one capsule per queue item to write module
   cards. Narrative without a file:line citation is mechanically rejected by
   `sfs dig card validate` — the validator, not the prompt, blocks
   hallucination.
4. **D. synthesis** — cluster cards into a feature map and a reverse-spec
   (every inference marked `#추정`/assumed), and collect low-confidence items
   into `unknowns.md` — the **vendor question list** you bring to the handover
   meeting.
5. **E. confirmation** — as answers and runtime checks land, cards climb
   unverified → corroborated → verified (`sfs dig status` shows coverage).

### First-day 30-minute checklist

- [ ] after `git clone`, run `sfs dig scan --write` at the repo root
- [ ] open `erd.md` and check tables/FKs (add `--live-schema` diff if the DB is reachable)
- [ ] `sfs dig graph --write` → check the L2-GATE line in `l2-queue.md`
      (if Sanity is not ready, record `--waive-sanity "<reason>"` and proceed)
- [ ] the routes table in `00-scan.md` is your first answer to "what does this system do"
- [ ] draft unknowns: write 3 questions from mismatches visible in scan/erd-diff

The full contract (card schema, gate, boundaries) lives in routed context
`commands/dig.md`. Once artifacts stabilize, promote them to the wiki via
`sfs tidy --wiki-promote`.
