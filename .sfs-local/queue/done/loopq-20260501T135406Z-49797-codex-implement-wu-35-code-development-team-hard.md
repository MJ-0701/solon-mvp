---
task_id: loopq-20260501T135406Z-49797
title: "codex implement WU-35 code development team hardening"
status: done
priority: 4
mode: user-active-deferred
sprint_id: ""
owner: codex-loop
attempts: 2
max_attempts: 3
created_at: 2026-05-01T13:54:06Z
claimed_at: 2026-05-01T14:33:44Z
size: large
target_minutes: 120
failed_at: 2026-05-01T14:31:59Z
retried_at: 2026-05-01T14:33:33Z
completed_at: 2026-05-01T14:33:47Z
---

# codex implement WU-35 code development team hardening

## Goal

Implement WU-35: fold the user-provided backend architecture checklist and
Spring Batch transaction PDF into the code development team's default
`/sfs implement` behavior.

Concrete outcome:
- Do not create separate `backend-hardening`, `transaction-guard`, or
  `security-guard` skills as the first move.
- Treat transaction discipline as always-on for backend implementation.
- Treat Security / Infra / DevOps as scale-gated guardrails that ask only for
  `light`, `full`, or `skip` at sprint/project scope.
- Generalize the guardrail model across all 6 Solon divisions so the user does
  not need to personally know every non-backend checklist:
  strategy-pm, taxonomy, design/frontend, dev/backend, QA, infra.
- Ensure MVP-overkill checks are recorded as `deferred` or `risk-accepted`
  instead of blocking implementation.
- Keep the user-visible guidance compact enough for real implementation flow.

Source inputs:
- `2026-04-19-sfs-v0.4/sprints/WU-35.md`
- `/Users/mj/Downloads/architecture-review-checklist.md`
- `/Users/mj/Downloads/2ec5a400-5e5b-4052-957d-a16b74371de6_Spring_Batch_트랜잭션.pdf`

Suggested implementation approach:
- Update the installed/local SFS skill and/or dist template guidance for
  `implement` so future sessions naturally apply the guardrails.
- Prefer a compact reference doc if the Skill would become too long.
- Use a common division policy shape:
  - always-on: basic craft rules that should never require a separate question
  - trigger-based: checks activated by UI, API, event, batch, data, deploy, etc.
  - scale-gated: light/full/skip question for expensive reviews
- Update implement/log templates only if needed to capture applied, skipped,
  deferred, and risk-accepted guardrails.
- Preserve existing SFS command semantics and adapter output contracts.

## Files Scope

- `.agents/skills/sfs/SKILL.md`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.agents/skills/sfs/SKILL.md`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.claude/commands/sfs.md`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/README.md`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/GUIDE.md`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/sprint-templates/implement.md`
- `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/sprint-templates/log.md`
- `2026-04-19-sfs-v0.4/sprints/WU-35.md`
- `2026-04-19-sfs-v0.4/sprints/_INDEX.md`
- `2026-04-19-sfs-v0.4/HANDOFF-next-session.md`

Do not edit unrelated release, Scoop, Homebrew, or queue lifecycle files unless
the implementation proves they are directly required.

## Verify

- `bash -n` on any touched shell scripts, if any.
- `rg -n "Transaction|REQUIRES_NEW|Security / Infra / DevOps|risk-accepted|deferred|/sfs implement" <touched docs>`
- Confirm `/sfs implement` guidance distinguishes:
  - backend transaction guardrails = always-on
  - Security / Infra / DevOps = light/full/skip scale gate
  - non-backend divisions = first-pass guardrails supplied by Solon/Codex
  - MVP-overkill = deferred/risk-accepted
- Run `sfs loop queue` and confirm this task can be tracked through queue state.
- Record touched files and verification evidence in WU-35 or the handoff.
