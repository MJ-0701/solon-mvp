---
doc_id: sfs-product-guide-en-7
title: "6. Review The Artifact"
visibility: oss-public
doc_type: user-guide
language: en
updated: 2026-05-25
parent: docs/en/guide.md
summary: "6. Review The Artifact"
load_when: "Read when docs/en/guide.md routes to this section."
---
## 6. Review The Artifact

```bash
sfs review
```

Review is artifact acceptance review. Code review is only the `code` lens.
GitHub `@codex` PR/code review is external evidence only; a PR approval,
GitHub check PASS, or `@codex` comment does not replace `sfs review`,
self-CPO, SFS cross review, or Gate 3/Gate 6 PASS. Claude Cowork, Gemini, and
future external reviews follow the same post-development evidence boundary.
External review/check PASS is a continuation trigger, not a stopping point.
Codex, Claude, Gemini, and future LLM agents continue with self-CPO first, then
the configured cross-review order after self-CPO PASS. For a closed sprint, use
`sfs review --sprint <id> --gate <n>` instead of hand-editing
`.sfs-local/current-sprint`.
Solon can infer lenses such as `docs`, `source-docs`, `simplify`, `security`,
`performance`, `api-contract`, `strategy`, `design`, `taxonomy`, `qa`, `ops`,
`release`, or `process-lean` from sprint evidence. Use `--lens` only when the
inference is wrong.
