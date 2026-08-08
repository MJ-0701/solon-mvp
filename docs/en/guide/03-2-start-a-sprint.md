---
doc_id: sfs-product-guide-en-3
title: "2. Start A Sprint"
visibility: oss-public
doc_type: user-guide
language: en
updated: 2026-05-22
parent: docs/en/guide.md
summary: "2. Start A Sprint"
load_when: "Read when docs/en/guide.md routes to this section."
---
## 2. Start A Sprint

```bash
sfs status
sfs start "todo app v0 - add, complete, delete, persist"
```

`start` creates the sprint workspace and shows the useful next step. For new
requirements, that is usually brainstorm.

```text
sfs brainstorm --simple "..."  # quick cleanup
sfs brainstorm "..."           # default normal thinking scaffold
sfs brainstorm --hard "..."    # product-owner hard training
```

Use Token Diet compact output when you want routine command output in fewer
tokens without dropping traceability:

```bash
SFS_OUTPUT_STYLE=compact sfs status
sfs status --compact
sfs start "first goal" --output-style compact
SFS_OUTPUT_STYLE=compact sfs report
```

Compact output keeps paths, next actions, alternative modes, archive paths, and
verification fields. Destructive/security/privacy/data-loss warnings, user
decisions, review findings, and raw-source traceability stay in full clarity
when shortening would lower quality. Caveman/persona speech is not the default.

As of 0.6.85, the release verifier follows the same evidence floor: successful
internal install/upgrade smoke logs stay quiet, while failures replay captured
stdout/stderr so the original cause remains traceable.

Session Continuation Guard covers a different budget. `sfs upgrade` updates the
runtime and project-local context, but it cannot shrink an already-open
Claude/Codex/Gemini conversation. If the host token meter is 30% or higher
before the first implementation/review action of a new WU/sprint, or 50% or
higher before a new gate, loop wakeup, or cross-review handoff, stop and create
a fresh session handoff with `report.md`, `review.md`, capture ids,
commit/branch, and the next SFS command. `.sfs-local/` size is a tidy signal,
not a token-meter substitute.

On cost, **take stock for a month before you restrict**. You cannot set a sane
limit before you have watched a month of real usage, so the first move is to see
where the spend actually goes, not to cap it. And judge in the right unit: not
tokens but **cost per outcome** — "what would this have cost without an agent,
counting the work that would simply not have been done?" and "is this hard work,
or merely a lot of work?" The full rubric lives in routed context:
`policies/token-harness.md` KNOB_DIAGNOSTIC_LADDER is the SSoT.

If a blank app would help before a sprint, the user should not need to know words
like Next.js, Spring, Java, or API. The user can simply describe what they want
to make. During brainstorm, the AI should infer when an initial project setup
would help and ask in plain language:

```text
Would you like me to set up the initial project?
```

After consent, the current AI should choose the native setup path, create the app,
then return to Solon. It may use `sfs bootstrap "small booking web app"` as an
internal handoff trigger, but the user should not need to know that command:

```bash
cd my-new-app
sfs init --layout thin --yes
sfs start "first goal"
```

For multi-sprint work, the AI may also recommend a repo-root Obsidian
`llm-wiki/` map after the scaffold exists. That map is optional; it points to
source docs and components so the next sprint starts from retrieval context
instead of a broad repo scan.
