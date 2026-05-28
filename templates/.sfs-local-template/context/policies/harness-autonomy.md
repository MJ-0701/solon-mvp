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
- Treat artifacts as coordination, not chat: workers write files, reports,
  ledgers, test output, or release evidence; leads inspect artifacts instead of
  relying on conversational memory.
- Keep humans on product judgment: goals, domain meaning, tradeoffs, ethics,
  and public-contract changes stay human-owned.
- Convert repeated defects into harness assets: tests, wiki bug reports,
  routed policies, knowledge packs, fixtures, or review questions.

Multi-agent execution remains opt-in. The default upgrade from a single model
is not "more agents"; it is a better environment for whichever model is active.
