---
id: sfs-steering-surface-taxonomy
summary: Decision matrix for WHERE a behavior instruction belongs — entry stub vs routed policy vs Gate/hook vs capsule — scored on load-timing, compaction, context-cost, and authority. "Every time / Never" rules cannot be guaranteed by prose and must promote to deterministic enforcement.
load_when:
  - steering
  - where to put rule
  - which surface
  - prose vs hook
  - authority
  - managed settings
  - always do
  - never do
  - rule placement
  - load timing
---

# Steering Surface Taxonomy

Solon already has the surfaces — thin agent entry, `kernel.md`, routed
`commands/`·`policies/` (`load_when`), Gate / FCP / lint / `sfs harness doctor`,
install-time hooks, and the sub-agent capsule. What was implicit is *which
surface a given instruction belongs on*. This policy makes that choice explicit:
score the instruction on four axes, then place it where the axes point.

External validation (by-reference): a Claude blog post on steering coding agents
(2026-06-18) frames the same trade-off across its instruction surfaces; the
generalized decision frame is adopted, vendor-specific surface names and the
host's managed-settings mechanism are held by-reference (see AUTHORITY below).

## FOUR_AXES

Score every candidate instruction on all four before choosing a home:

1. **Load timing** — *when* does it enter context? Always (entry stub / kernel,
   every turn) · trigger-scoped (routed `load_when`, only on a matching trigger)
   · on-demand (skill/command the operator invokes) · install-time (hook wired
   once, runs as code).
2. **Compaction behavior** — prose in the context window can be summarized away
   under compaction; a rule that must survive *cannot* live only as prose.
   Code-enforced surfaces (hooks, lint, Gate) are immune — they are program
   logic, not tokens. Capsule output is final-message-only, so a worker's body
   never enters the parent window to be compacted in the first place.
3. **Context cost** — always-loaded prose is paid every turn (entry/kernel = the
   expensive layer; keep it thin, ≤200 lines). Trigger-scoped `load_when` is
   near-zero until fired. Hooks and Gates cost no context tokens (they run as
   code). Capsules carry their own isolated budget.
4. **Authority** — how strongly is it enforced? Advisory prose (Tier A,
   `critical-rule-hook-promotion.md`) < review-enforced gate/lint (Tier B) <
   code-enforced hook (Tier C, 100%). A host with admin-deployed *managed
   settings* adds a tier above operator config the operator cannot override —
   **by-reference only**: solon's bash distribution ships no such surface, the
   operator owns all config and overrides every default
   (`user-override-precedence.md`). Do not read this axis as solon implementing
   managed settings.

## PLACEMENT_RULES

The axes resolve to a small set of rules:

- **"Every time X" / "Never do Y"** cannot be *guaranteed* by prose — the agent
  is only asked, and compaction can drop the ask. A rule whose single violation
  is catastrophic must promote to deterministic enforcement (hook + permission),
  per `critical-rule-hook-promotion.md` PROMOTION_CRITERIA. Prose is an
  expectation; only code enforces.
- **Always-true, cheap, identity-level** facts → entry stub / `kernel.md`. Pay
  the every-turn cost only for what every turn needs. Keep the stub thin,
  owner-assigned, and reviewed like code (`test-agent-entry-doc-hygiene.sh`).
- **A procedure** (multi-step how-to) → a routed `commands/` or skill with a
  trigger-centric `load_when`, not the always-loaded layer.
- **A scoped constraint** → a routed `policies/` module with a `load_when`
  trigger. Vendor hosts express file-specific constraints as *path-scoped* rules
  (`paths:` frontmatter); solon routes on **triggers**, not paths — a
  `load_when` keyword set, not a glob. Choose the trigger so the rule loads
  exactly when relevant and stays out of context otherwise.
- **Isolated heavy work** → a sub-agent capsule with the field contract
  (`sub-agent-capsule-contract.md`); its body returns final-message-only and
  never pollutes the parent window.

## DECISION_TABLE

| Instruction shape | Axes that dominate | Home |
|:--|:--|:--|
| Identity / always-needed fact | always-load, cheap, advisory | entry stub / `kernel.md` |
| Trigger-scoped guidance | trigger-load, low cost | routed `policies/` `load_when` |
| Multi-step procedure | on-demand | routed `commands/` / skill |
| File/scope-specific constraint | trigger-load | `load_when` trigger (not path glob) |
| "Every time / Never", catastrophic | authority = code-enforced | Gate (B) → hook (C) |
| Isolated heavy sub-task | compaction-immune isolation | capsule (final-message-only) |

## CROSS_REFERENCES

- Prose → gate → hook promotion criteria + managed-settings authority note:
  `critical-rule-hook-promotion.md`.
- Operator-overrides-all authority stance: `user-override-precedence.md`.
- Capsule field contract + final-message-only isolation:
  `sub-agent-capsule-contract.md`.
- Always-loaded layer hygiene (thin entry, ≤200 lines):
  `agent-adapter-doc-refactor.md`, `md-line-budget.md`.
- Trigger-centric `load_when` lint + nine-category lens:
  `skill-catalog-discipline.md`.
