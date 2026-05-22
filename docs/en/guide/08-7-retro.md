---
doc_id: sfs-product-guide-en-8
title: "7. Retro"
visibility: oss-public
doc_type: user-guide
language: en
updated: 2026-05-22
parent: docs/en/guide.md
summary: "7. Retro"
load_when: "Read when docs/en/guide.md routes to this section."
---
## 7. Retro

```bash
sfs retro
```

`retro` is the normal sprint completion command. It refines the retro, ensures
the report exists, folds away noisy temporary records, closes sprint state, and
creates the local close commit. Use `sfs retro --draft` only when you want to
open the draft without closing the sprint.

Use `sfs report` separately only when you want to preview or rebuild the report
without closing the sprint. The full list of optional helpers
(`report --sprint <id>`, `tidy`, `decision`, `adopt`, etc.) is in the Korean
GUIDE §11.
For compact routine output, use `sfs status --compact`,
`sfs start "..." --output-style compact`, or `sfs report --output-style
compact`. `sfs report --compact` still means finalize/archive the workbench; it
is separate from output style.
For committing Solon work, use `sfs commit plan` to inspect groups, then
`sfs commit apply --group <name>`. `apply` commits and pushes the current branch
by default; use `--no-push` only for local sandbox/release testing or offline
work. Do not route SFS work to a host-local `/commit` skill.
When a report asks for a decision, the `Q1` label is only a cross-reference. The
report should spell out what is being decided, why it matters now, the default
recommendation, and what each option changes. Confirmation should use natural
language, not internal option bundles such as `A/A/A/C/C confirmed`.

