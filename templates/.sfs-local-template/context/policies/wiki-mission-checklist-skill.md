---
id: sfs-policy-wiki-mission-checklist-skill
summary: Lightweight checklist skill for long-context work so findings do not blur before completion.
load_when:
  - checklist
  - wiki checklist
  - long context
  - context heavy
  - multi-step
  - follow-through
  - 흐려짐
  - 체크리스트
status: filled-v1
content_policy: "load when work spans many steps, repeated defects, multiple requests, release, monitoring, or long context"
---

# Wiki Mission Checklist Skill

When context is heavy, make the mission durable before continuing. A checklist
is not a replacement for plan/review; it is a short live control surface that
keeps the agent from dropping user-reported issues.

## Activation

Create or update a checklist when any is true:

- the user worries issues will blur or be forgotten;
- the task spans multiple product defects, tools, agents, repos, or releases;
- the work will take several verification loops or more than one session;
- a monitor/heartbeat, long PR loop, or cross-agent handoff is active;
- SFS itself or a project-wide policy is being changed.

## Location

- If the current project has `llm-wiki/` and the checklist is durable product
  knowledge, use `llm-wiki/tmp-<slug>-checklist.md` during work, then fold the
  final evidence into the relevant wiki map.
- If the project wiki must not be touched, use the SFS product-management wiki
  or the current sprint artifact, as the user instructed.
- If no wiki exists, use the current sprint workbench artifact.

## Checklist Rules

- Each item starts as `[ ]`, moves to `[~]` when actively being handled, and
  becomes `[x]` only after evidence is linked.
- Update status at natural boundaries: after audit, before edits, after tests,
  after review, after release, and before final answer.
- Include evidence paths/commands, not transcripts or raw secrets.
- If a new defect is discovered, add it immediately instead of relying on chat
  memory.

Gate 6 is partial when a high-context sprint used a checklist but final evidence
does not reconcile every open item.
