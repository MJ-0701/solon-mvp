---
doc_id: sfs-product-guide-en-11
title: "10. Team Adoption: Champion + Repository First"
visibility: oss-public
doc_type: user-guide
language: en
updated: 2026-07-12
parent: docs/en/guide.md
summary: "10. Team Adoption: Champion + Repository First"
load_when: "Read when docs/en/guide.md routes to this section."
---
## 10. Team Adoption: Champion + Repository First

The proven rollout order is **not company-wide training — a few champions make
the key repositories AI-friendly first** (large-org case, `idea_wiki:L087-I3·I4`).
The reason is simple: a repository is the path every teammate walks daily, so
knowledge a few people plant there raises the whole team's floor
(`idea_wiki:L087-I6`). A lecture changes only its audience; a repository change
changes everyone.

**Standards are not handed down.** Instead of pushing one answer template,
let each repository converge on its own (`idea_wiki:L087-I7`) — solon's routed
policies and adapter docs are the shared skeleton for that convergence, and
per-project differences live in `.sfs-local/context/` overrides and the
repository's own docs.

### Sequence (per repository)

1. **Readiness audit** — run `sfs harness doctor` and read the AI Readiness
   section: the Sanity four axes (test entrypoint / dead code / conventions /
   doc freshness) plus the AI-friendly surface four (repo guide / guardrails /
   commands-skills / AI reviewer). Onboarding's first question is not "what
   do we adopt" but "where are we now" — the AI Maturity section locates the
   current level on a 5-level ladder.
2. **Surface work** — fix the lowest-scoring axes first: a thin `SFS.md`
   router and root adapter docs, a named test entrypoint, repeated work
   compiled into commands/skills. Compiling a skill needs no technical
   knowledge — **Claude builds the skill for you**. If you corrected the
   same thing twice, ask "fold that correction into the skill"; before
   closing a session, ask "reflect on this session — anything worth keeping
   as a skill?" (the repeated-correction trigger in
   `policies/skill-promotion-loop.md` plus the end-of-session reflect pass
   in `policies/lessons-accumulation.md`).
3. **Delegation entry** — once the surface is ready, start delegating whole
   WUs (`sfs start` → plan → implement). Maturity level 3 is the target.
4. **Review loop** — turn the Gate 6 review rail into a standing loop only
   after delegation is flowing. Not enabling the reviewer before the
   repository is ready is itself a proven order discipline
   (`idea_wiki:L087-I10`) — the same shape as readiness's
   Sanity-before-Cartography.

When the ladder starts climbing in one repository, the champion repeats the
same sequence on the next key repository. All diagnosis is signal-only and
never blocks a command — rubrics live in the routed policies
`policies/harness-readiness.md` and `policies/harness-maturity.md`.
