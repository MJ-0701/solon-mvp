---
id: sfs-policy-harness-autonomy
summary: Convert Harness Engineering from principle into project-operating evidence.
load_when: ["harness", "autonomy", "parallel agents", "long-running", "quality"]
---

# Project Harness Autonomy

Harness Engineering means the model is only one component. The product quality
comes from the environment around it: agent roles, skills, tools, routed
context, orchestrator rails, artifacts, memory, tests, review, and release
checks.

SFS applies this as a project-operating contract:

- Diagnose before long autonomy: `sfs harness doctor` checks whether a project
  has thin entry docs, routed context, active divisions, memory, tests, and
  release/check rails.
- Map before parallelization: `sfs harness map --write` records roles, inputs,
  outputs, quality gates, and human-owned boundaries before optional worker
  lanes are split.
- Lock the change basis before long implementation: write a compact docs/ADR/
  spec diff or equivalent run brief so workers read the changed intent first,
  not the whole conversation or a stale plan.
- Measure agent productivity as time-to-validated artifact, not human busywork
  avoided. Improve context routing, memory indexing, tool boundaries, slice
  size, and automated feedback before adding more agents.
- Long-running harnesses need a phase/run ledger: current phase, resume point,
  remaining work, expected outputs, recovery path, and stop condition must be
  artifact-backed before automation continues unattended.
- Treat artifacts as coordination, not chat: workers write files, reports,
  ledgers, test output, or release evidence; leads inspect artifacts instead of
  relying on conversational memory.
- ChatOps workrooms are coordination surfaces, not memory SSoT: use project
  channels for routing/status and task threads for bounded work capsules; close
  or archive threads with result/evidence and refresh summaries before
  reactivation.
- Standing AI workers need an onboarding contract before cron or unattended
  delivery: identity/persona boundary, routed operating manual or skill,
  bounded memory with review cadence, schedule/trigger plus delivery mode, and
  report channel with permission, attachment, redaction, and disable path.
- PRs and review threads are report artifacts: useful for later human audit,
  but they do not replace SFS Gate 3/6 review or acceptance evidence.
- Multi-agent review reduces human bottleneck only when the lead adjudicates
  reviewer findings against AC/source evidence; another agent's critique is
  evidence to evaluate, not automatic truth.
- Keep humans on product judgment: goals, domain meaning, tradeoffs, ethics,
  and public-contract changes stay human-owned.
- Convert repeated defects into harness assets: tests, wiki bug reports,
  routed policies, knowledge packs, fixtures, or review questions.

Multi-agent execution remains opt-in. The default upgrade from a single model
is not "more agents"; it is a better environment for whichever model is active.
