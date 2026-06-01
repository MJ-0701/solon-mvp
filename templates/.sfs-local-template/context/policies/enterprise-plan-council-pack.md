---
id: sfs-policy-enterprise-plan-council-pack
summary: Plan-stage six-division council contract for enterprise SFS work.
load_when:
  - plan
  - Gate 3
  - enterprise council
  - division_subagent_ledger
  - plan review
status: filled-v1
parent_doc: enterprise-agent-team-pack.md
content_policy: "load during plan creation, plan rework, and Gate 3 review"
---

# Enterprise Plan Council Pack

Use this pack after Gate 2 brainstorm and before Gate 3 review. Its purpose is
to make plan a real design phase.

## Council Method

1. Read brainstorm, latest handoff/user intent, active sprint state, and wiki or
   domain maps when present.
2. Build the smallest useful work slice and AC list.
3. For each division, record one row: finding, risk flags, AC/files/evidence
   mapping, `asset_candidate`, waiver or N/A reason, and next action.
4. Load deeper knowledge packs only when that row has a real trigger.
5. If any relevant division lacks finding/evidence/waiver, Gate 3 is partial.

## Division Outputs

| division | plan output |
|---|---|
| strategy-pm | product intent, user value, winning theory, scope/non-goals, rollout/decision boundary |
| dev | domain/application/interface/infrastructure boundary, files_scope, slice split |
| QA | first failing/characterization/smoke/review signal, regression and edge cases |
| design | workflow, interaction state, accessibility, copy, visible risk or N/A waiver |
| infra | runtime, deploy, data, secret, observability, cost/latency, rollback risk |
| taxonomy | canonical terms, states/events, forbidden aliases, UI/API/docs/log wording |

Each row also names the reusable domain asset it touches: existing asset reused,
new asset to create, or explicit gap/waiver. This is why the council exists.

## Risk Flags

Escalate depth when any flag is present:

- security, privacy, auth, permission, PII, payment, finance, production write;
- public API/schema/CLI/docs contract or destructive/data-loss behavior;
- broad entrypoint gaining product policy;
- hot path, batch, database query, concurrency, storage, network, or bundle risk;
- multi-agent lanes, repeated partial/fail, or stale sprint versus newer handoff.

## Plan Artifact Requirements

Gate 3 plan must include:

- `enterprise_council_ledger` or extended `division_subagent_ledger`;
- risk flags and selected child packs;
- per-division asset candidates or concrete N/A reasons;
- AC to file/artifact/evidence mapping;
- DDD/TDD boundary for every product-bearing entrypoint;
- user approval boundary only for real product judgment;
- first implementation slice and expected verification command/evidence.

## No-Filler Rule

Do not create empty six-division boilerplate. If a division is not relevant,
record `not-applicable` plus one concrete reason. If it is relevant, name the
finding and evidence. Missing meaningful rows block Gate 3.
