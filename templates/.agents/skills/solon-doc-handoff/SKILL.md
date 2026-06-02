---
name: solon-doc-handoff
description: Render a Solon session handoff as a self-contained HTML artifact with a standard copy-as-prompt export. Use when ending a session, writing a handoff/인계, or capturing branch/commit/status/evidence/next-prompt for the next session. The handoff is always emitted as a re-enterable next-session prompt, not a read-only document.
---

# Solon Handoff — HTML artifact with copy-as-prompt

Renders a handoff from `template.html` (bundled next to this file). The template
is placeholder-driven and ships no project-specific values; fill the tokens.

## When to use

- Session is ending and the next session must resume cleanly.
- The user asks for a handoff / 인계 / "다음 세션 프롬프트".
- Any time you would otherwise leave state in a plain note — emit HTML so a
  non-technical operator can read it and copy the prompt in one click.

## How to render

1. Copy `template.html` to the project's report location (e.g.
   `docs/<domain>/.../handoff-<DATE>.html` or the project's handoff path).
2. Replace placeholders:
   - `<PROJECT-NAME>` / `<DATE>` — project + date.
   - `{{GENERATED_AT}}`, `{{SESSION_CODENAME}}`.
   - `{{BRANCH}}`, `{{COMMIT_SHA}}`, `{{GIT_STATUS}}`, `{{CURRENT_WU}}`.
   - `{{DONE_ITEM}}` / `{{EVIDENCE_ITEM}}` — repeat the `<li>` per item.
   - `{{NEXT_SESSION_PROMPT}}` — the exact prompt to paste into the next
     session. This is the payload of the copy-as-prompt button.
3. Keep the `data-copy-as-prompt` button and the `#next-session-prompt` block —
   they are the standard export that makes a handoff a prompt (§1.29).

## Contract

- The next-session prompt must be self-contained: tree roles, current branch /
  commit / status, what was done, evidence, and the exact resume instruction.
- Do not hardcode private docset paths or absolute staging paths into the
  rendered artifact (private-path hygiene).
- The HTML is self-contained (inline CSS/JS); it opens with no server.
