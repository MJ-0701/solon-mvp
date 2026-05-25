---
id: sfs-policy-postdev-external-review-pack
summary: Post-development Claude/Gemini/Codex review evidence without replacing SFS gates.
load_when:
  - post-development review
  - external review
  - Claude Cowork
  - Gemini review
  - Codex review
  - after implementation
status: filled-v1
---

# Post-Development External Review Pack

Use this pack after implementation evidence exists. It adds independent
reviewers without turning review volume into the success criterion.

## Contract

- SFS gates stay authoritative: self-CPO PASS, SFS cross review, then external
  evidence where available.
- External reviewers include GitHub `@codex`, Claude Code/Cowork, Gemini, or a
  future reviewer bridge. They are evidence, not SFS PASS by themselves.
- If a CLI bridge is authenticated, run it yourself. If Claude Cowork is UI-only
  or host-controlled, create a compact review capsule for that host and record
  `manual_host_review_pending`; do not make the user repeat context.
- Use Runtime Token Firewall: pass goal, AC/ADR, diff/files, tests, and open
  risks only. Never pass full chat history, secrets, raw env, or broad logs.
- A PASS from any external reviewer is a continuation trigger: attach evidence,
  then run the next unmet SFS step. A deterministic finding enters bounded
  micro-rework.

## Preferred Order

1. Local verification and self-CPO PASS.
2. SFS cross review through an independent executor when available.
3. Gemini `gemini-3.1-pro-preview` for broad strategy/security/reasoning review
   when research/review depth helps.
4. Claude Code/Cowork for implementation-readability, UX/product fit, or
   handoff review when the host is available.
5. GitHub `@codex` on the PR as final external PR/code-review evidence.

## PASS Shape

- Each external lane records status: `pass`, `partial`, `fail`, `blocked`,
  `not_applicable`, or `manual_host_review_pending`.
- Evidence names command, host, PR/comment URL, prompt capsule path, or waiver.
- Release is blocked only by a real unresolved risk, not by an unavailable
  optional reviewer.
