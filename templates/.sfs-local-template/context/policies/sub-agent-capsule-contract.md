---
id: sfs-policy-sub-agent-capsule-contract
summary: Structured field contract for the capsule-only worker/sub-agent handoff that kernel and runtime-token-firewall reference in prose.
load_when:
  - capsule
  - sub-agent
  - subagent
  - worker handoff
  - tool scope
  - token budget
  - agent capsule
status: filled-v1
parent_doc: policies/runtime-token-firewall.md
content_policy: "load when a lead agent hands a work slice to a worker / sub-agent / external executor, or when the agent-build review lens checks a handoff"
---

# Sub-Agent Capsule Contract

`runtime-token-firewall.md` requires capsule-only handoff and `kernel.md` names
the capsule fields in prose. This pack turns that prose into a checkable field
contract so a worker/sub-agent handoff can be validated, not just described. It
adds no new lifecycle command — it is the schema behind the existing
capsule-only rule, and the `agent-build` review lens checks it at handoff.

## Required fields

A capsule passed from a lead/C-Level agent to a worker, reviewer, or external
executor must carry these fields. Omitting one is a handoff finding, not a
convenience.

| field | meaning |
|---|---|
| `goal` | one-sentence outcome the worker must achieve. |
| `acceptance_criteria` | testable conditions that decide pass/fail; no vibe. |
| `files_scope` | explicit paths/globs the worker may read and edit; nothing outside. |
| `tools_allowed` | the narrow tool/permission set; default-deny everything else. |
| `output_paths` | where the worker writes `status` / `result` / `evidence` / touched-file manifest. |
| `token_budget` | expected output-token ceiling; exceeding it is a product finding (firewall §budget). |
| `timeout` | wall-clock ceiling; on hit, return partial + name the missing artifact. |
| `pii_rules` | redaction/persistence rules for any user/workspace data the worker may touch. |

## Handoff rules

- Capsule-only: never forward the lead's full conversation history, hidden
  chain, or unrelated prior turns (see `runtime-token-firewall.md`).
- Poll artifacts at `output_paths`, not the worker's thoughts. Insufficient
  evidence → the worker returns partial/fail and names the missing artifact.
- A bridge that cannot express these fields (e.g. a forked-context helper that
  inherits the whole chat) is a manual escape hatch, not the default executor.

## Validation (agent-build lens)

At handoff, the `agent-build` review lens checks: every required field present;
`files_scope` and `tools_allowed` are narrow (no "do anything"); `token_budget`
+ `timeout` set; `pii_rules` cover any data the tools can reach; `output_paths`
are concrete. A missing or unbounded field is a finding with a fix, not a pass.
