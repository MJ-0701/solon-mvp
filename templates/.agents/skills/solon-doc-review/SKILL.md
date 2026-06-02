---
name: solon-doc-review
description: Render a code review as a self-contained HTML artifact with diff blocks, inline annotations, and a severity-tagged findings table. Use when writing a PR review, code-review writeup, or Gate-6 review evidence that a human or agent must read. Pairs diff context with each finding so the reviewer sees code and comment together.
---

# Solon Code Review — HTML artifact

Renders a review from `template.html` (bundled next to this file). The template
is placeholder-driven and ships no project-specific values.

## When to use

- A PR / diff review writeup that others (human or agent) will read.
- Gate-6 review evidence that should be shareable, not buried in a terminal.
- Any review where diff context next to each comment improves the read.

## How to render

1. Copy `template.html` to the project's report location.
2. Replace placeholders:
   - `<PROJECT-NAME>` / `<DATE>`, `{{GENERATED_AT}}`, `{{BRANCH_OR_PR}}`.
   - `{{SUMMARY}}` — verdict + headline counts (blocker/major/minor).
   - `{{FINDING_ROW}}` — repeat per finding (severity / file:line / problem /
     fix). Severity in {blocker, major, minor, nit}.
   - `{{DIFF_FILE}}`, `{{DIFF_BODY}}` — repeat the diff block per file; keep
     `+`/`-` line prefixes so the diff colors render.
   - `{{ANNOTATION_ITEM}}` — repeat per inline annotation tied to a diff line.

## Contract

- Every finding states a fix, not just a problem.
- Severity is explicit; do not bury blockers among nits.
- Self/cross review verdict is the user's call to accept; present findings,
  do not auto-resolve.
- Do not hardcode private docset paths or absolute staging paths.
- Self-contained HTML (inline CSS); opens with no server.
