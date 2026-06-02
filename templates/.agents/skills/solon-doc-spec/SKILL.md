---
name: solon-doc-spec
description: Render a spec / plan as a self-contained HTML artifact with goal, acceptance-criteria table, explicit assumptions, and open decisions. Use when writing a spec, plan, PRD, design brief, or 기획 that a reviewer (human or agent) must read and approve before code. Turns "plan = quality gate" into a shareable artifact.
---

# Solon Spec / Plan — HTML artifact

Renders a spec/plan from `template.html` (bundled next to this file). The
template is placeholder-driven and ships no project-specific values.

## When to use

- A spec / plan / PRD is the gate before implementation (plan = quality gate).
- The user asks for a 기획서 / 설계 / plan that others will review.
- You want assumptions made explicit before code, not after.

## How to render

1. Copy `template.html` to the project's report location.
2. Replace placeholders:
   - `<PROJECT-NAME>` / `<DATE>`, `{{TITLE}}`, `{{GENERATED_AT}}`.
   - `{{GOAL}}` — the actual outcome being built.
   - `{{ACCEPTANCE_ROW}}` — repeat per acceptance criterion (id / criterion /
     how-verified).
   - `{{ASSUMPTION_ITEM}}` — repeat per still-implicit assumption made explicit.
   - `{{EDGE_CASE_ITEM}}` — repeat per easy-to-forget edge case.
   - `{{OPEN_DECISION_ROW}}` — repeat per open decision (question / options /
     owner). Decisions are the user's to make; list them, do not pre-decide.

## Contract

- Every acceptance criterion states how it is verified, not just what is wanted.
- The "Explicit assumptions" section is mandatory: convert implicit → explicit.
- Do not hardcode private docset paths or absolute staging paths.
- Self-contained HTML (inline CSS); opens with no server.
