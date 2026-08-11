---
doc_id: sfs-current-product-shape-en-29
title: "Feature Overview"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-07-28
parent: docs/en/current-product-shape.md
summary: "One-page overview of the whole Solon/SFS feature surface — command surfaces plus routing into the detailed sections."
load_when: "Read when you need the whole feature surface at a glance, before routing into a detailed section."
---
## Feature Overview

The whole Solon (SFS) feature surface on one page. Each row is an entry
point that routes to a detailed section; the SSoT for the actual contracts
is routed context (`sfs context cat ...`).

### 1. The 7-step work rail (deterministic core)

Deterministic rails own the flow; LLMs are called at designated points
inside each gate.

| feature | surface | detail |
|---|---|---|
| sprint start/status | `sfs start "<goal>"` / `sfs status` | [start](./02-handoff-after-start.md) |
| intent shaping (Gate 2) | `sfs brainstorm [--simple\|--hard]` | [brainstorm](./05-three-brainstorm-depths.md), [hard mode](./06-purpose-of-hard-mode.md) |
| plan contract (Gate 3, eval-first) | `sfs plan` | [plan](./07-plan-is-a-contract.md) |
| implementation slice (Gate 4) | `sfs implement [slice\|--stdin]` | [implement](./09-implement-is-not-only-code.md) |
| artifact acceptance review (Gate 6) | `sfs review [--lens ...]` | [review](./10-review-is-artifact-acceptance.md), [lenses](./14-divisions-knowledge-packs-review-lenses.md) |
| retro / close (Gate 7) | `sfs retro [--draft]` | [retro](./15-retro-closes-the-sprint-by-default.md) |
| flow conformance | `sfs flowcheck` / `sfs healthcheck` | routed context `commands/flowcheck.md` |
| unknowns loop (recon, prototype fork, interview gate, blind_spots, references, deviation ledger, comprehension quiz) | plan/implement/review rails + sprint template sections (signal-only) | [Unknowns Loop](./30-unknowns-loop.md) |
| unknowns runtime signals (deviation-ledger / plan-readiness advisories) | `sfs healthcheck` WARN (exit unchanged) | [Unknowns Loop](./30-unknowns-loop.md) |
| self-refutation pass (once, before implementation) | the agent attacks the conclusion it reached itself and records what it tried and what survived in the plan; no trace on a research-backed plan is a review finding (signal-only) | routed context `policies/source-pointer-citation.md` (ANTAGONISTIC_RESEARCH_PASS) |

### 2. Evidence and record primitives

| feature | surface | detail |
|---|---|---|
| minimal fact capture | `sfs capture [--kind ...]` / `sfs note` | [capture](./08-capture-is-an-evidence-primitive.md) |
| decisions / events | `sfs decision` / `sfs event` | routed context `commands/*` |
| reports / bugs | `sfs report` / `sfs report-bug` | bug-report lifecycle policy |
| recall past work | `sfs recall` | routed context `commands/recall.md` |
| shared artifacts | `docs/solon/<domain>/.../report.md` / `retro.md` | [design.md](./13-design-md-and-anti-ai-slop-guardrails.md) |
| reasoning log as an audit artifact (top risk tier only) | for destructive or long unattended work the judgment trace is contracted too — the after-the-fact partner to the pre-work invariant declaration, deliberately off for routine work | routed context `policies/flow-conformance-postflight.md` (REASONING_LOG_AS_AUDIT_ARTIFACT) |

### 3. Harness engineering (diagnosis, metrics, blueprints)

| feature | surface | detail |
|---|---|---|
| harness readiness check | `sfs harness doctor` | [harness map](./22-project-harness-map.md) |
| AI-readiness (Sanity) rubric, 4 axes | doctor "AI Readiness" section, `.sfs-local/readiness-waiver` | policy `policies/harness-readiness.md` |
| AI-friendly surface, 4 axes (repo-standard 4 elements) | same section `ai-surface` axis group — repo guide/guardrails/commands-skills/AI reviewer | policy `policies/harness-readiness.md` |
| AI maturity self-diagnosis (5-level ladder) | doctor "AI Maturity" section — delegated-wu/review-loop/parallel-capsule/rework signals | policy `policies/harness-maturity.md` |
| session cost signals (3 runtimes) | doctor "Cost Signals" — Claude Code / Codex / Gemini adapters, `SFS_COST_RUNTIME` pin | [token harness](./17-token-harness-hygiene.md) |
| harness blueprint + evolution ledger | `sfs harness map --write` | [harness map](./22-project-harness-map.md) |
| saved-time / cost dashboard | `sfs measure [--json]` / `measure --alive` | `bin/sfs` usage |
| undocumented-codebase excavation (L0 scan/ERD, L1 graph, fact cards, confirmation states) | `sfs dig scan|graph|capsule|card|status` | routed context `commands/dig.md` |
| static security audit (OWASP-family, secret redaction, defensive scope) | `sfs audit scan|report|status` | routed context `commands/audit.md` |
| held-out evals scaffold (eval-first, wrong-premise fixture axis) | `.sfs-local/evals/README.md` + doctor "Held-Out Evals" section (case count only, bodies never read) | [Unknowns Loop](./30-unknowns-loop.md) |
| model-swap discipline (head-to-head bench + new-model setup audit) | policy `model-workaround-sunset.md` (MODEL_HEAD_TO_HEAD_ON_UPGRADE / MODEL_UPGRADE_SETUP_AUDIT, tidy rail) | routed context `policies/model-workaround-sunset.md` |
| overconstraint / redundant-guidance detection (rightsize) | doctor "Context Conflict Gate" section — standing directives restated across 2+ surfaces, plus a narrative always/never count (info-only) | routed context `policies/context-conflict-gate.md` (RIGHTSIZE_CONTEXT_PASS) |
| in-flight intent recheck | a long or unattended WU records assumption-change detection and an original-AC comparison at each step boundary (silent progress = drift finding, advisory) | routed context `policies/flow-conformance-postflight.md` (MID_RUN_INTENT_RECHECK) |
| gate activity reading | doctor "Verification Loop" section — reads the deviation ledger and lessons file to show whether a gate has actually caught anything. Zero activity means unverified, not proven safe (info-only, exit unchanged) | `scripts/sfs-harness.sh` `gate_activity_check` |

The Sanity-before-Cartography order discipline and the signal-only
(never-blocking) contract apply across all of these.

### 4. Context routing and token hygiene

| feature | surface | detail |
|---|---|---|
| routed context access | `sfs context path\|cat\|list` | [token diet](./03-token-diet-compact-i-o.md) |
| thin adapters kept thin | `sfs agent doctor --fix` / `sfs doctor --fix` | [token/harness hygiene](./17-token-harness-hygiene.md) |
| cache-prefix discipline | policy `policies/token-harness.md` (session-frozen prefix, fresh-session restart) | same doc |
| worker delegation capsules | policy `sub-agent-capsule-contract.md` (goal/AC/scope/budget + optional exemplar; verb-grain least agency, done = artifact on disk, shared-surface conflict scan) | [delegation repertoire](./26-delegation-repertoire.md) |
| large-batch loop discipline (rule-upstream fix, judge negative control, expensive-op serialization) | policies `harness-autonomy.md` / `token-harness.md` (FIX_THE_LOOP / JUDGE_NEGATIVE_CONTROL / SERIALIZE_EXPENSIVE_OPS) | routed context `policies/harness-autonomy.md` |
| instruction classification (inviolable gate vs narrative advisory) | if one violation is catastrophic it belongs on an enforcement surface; otherwise it is a trim candidate — labelling, not deletion | routed context `policies/steering-surface-taxonomy.md` (RULE_VS_GUARDRAIL) |
| cost-per-outcome frame | enter on what one finished result costs, not tokens — "what would this have cost with no agent, counting work that would not have happened?" and "is this hard work, or merely a lot of work?" | routed context `policies/token-harness.md` (KNOB_DIAGNOSTIC_LADDER) |
| fixed core, versioned extensions | ask of any new capability whether it is a core change or a versioned extension surface — without an extension path the pressure lands in the core | routed context `policies/skill-catalog-discipline.md` (VERSIONED_EXTENSION_SURFACE) |
| verification check placement ladder | standalone → embedded → chained → every-change; repeated manual invocation is the promotion signal, and habit→contract chaining ships with its trade-offs | routed context `policies/loop-taxonomy.md` (CHECK_PLACEMENT_LADDER) |
| spec-is-the-artifact / control-logic-as-data | no translation layer between the verified and the executed artifact; routines, transitions, and gates live on a readable, editable data surface | routed context `policies/harness-autonomy.md` (SPEC_IS_THE_ARTIFACT / CONTROL_LOGIC_AS_DATA) |

### 5. Teams and orchestration

| feature | surface | detail |
|---|---|---|
| team preset activation | `sfs team use <solo\|pair\|trio>` / `team refresh` / `team show` | [human-agent teams](./27-human-agent-teams.md) |
| six-division council (always-on) | `sfs division` + `.sfs-local/divisions.yaml` | [review lenses](./14-divisions-knowledge-packs-review-lenses.md) |
| work routing / orchestration | `sfs route` / `sfs orchestrator` / `sfs dispatch` | [work intake routing](./20-ai-work-intake-routing.md) |
| recurring loops | `sfs loop` + the loop-taxonomy policy (four-type decision lens) | routed context `policies/loop-taxonomy.md` |
| agent identity / compartments | `agent-identity` and compartment policies | [identity and compartments](./28-agent-identity-and-compartments.md) |
| selective advisor coaching binding | a fast worker plus an advisor called only when needed — the call conditions (stuck / verification gate, with ship-eve evaluation the representative point / low-confidence) are a data surface beside `agent_runtime_bindings` | routed context `policies/external-orchestrator-entry.md` (ADVISOR_STRATEGY_BINDING) |
| per-stage effort allocation | allocated at capsule issue time — low effort for routing, extraction, and summary; high for final judgment and review. Distinct from failure-driven escalation, and an opening bid rather than a ceiling | routed context `policies/sub-agent-capsule-contract.md` (SUBAGENT_TIER_DEFAULT) |
| unattended-delegation signal | without a score the agent can hill-climb on its own, the delegated unit stays capped however low the risk tier — the practical test for "can this run while I sleep?" | routed context `policies/work-delegation-and-startup.md` (DELEGATION_UNIT_LADDER) |
| delegation unit ladder | chunk → task → decision, climbing on trusted verification and capped by the target surface's risk tier | routed context `policies/work-delegation-and-startup.md` (DELEGATION_UNIT_LADDER) |

### 6. Memory and wiki (long-horizon memory)

| feature | surface | detail |
|---|---|---|
| LLM navigation wiki | `llm-wiki/` (opt-in, waiver available) | [wiki continuity](./19-obsidian-llm-wiki-continuity.md), [onboarding](./25-wiki-onboarding-guide.md) |
| raw source intake | `sfs ingest --source-type --purpose` | [intake routing](./20-ai-work-intake-routing.md) |
| promotion pipeline | `sfs tidy --all --wiki-promote [--apply]` | [domain knowledge assets](./21-domain-knowledge-assets.md) |
| repeated-mistake ledger | `.sfs-local/lessons.md` (record→reflect flywheel) | routed context `policies/lessons-accumulation.md` |
| security finding class closed loop | a waiver or point fix closes an instance, not a class — a recurring class is promoted to a routed rule, skill rule, or regression lock | routed context `commands/audit.md` (VULNERABILITY_CLASS_CLOSED_LOOP) |
| manual review promoted to evals | perform the task by hand once to fix what "good" means, then promote structured review into held-out cases (judge agent scores transcripts) | routed context `policies/self-improvement-loop.md` (BE_THE_AGENT_FIRST / REFLECTION_TO_EVAL_PIPELINE) |
| derived-doc annotation survival | regenerating a doc derived from code preserves the human why/correction/constraint notes anchored to an item instead of clobbering them (conflict → gap) | routed context `policies/doc-colocation-provenance.md` (DERIVED_DOC_ANNOTATION) |

### 7. Host channels and platforms

| feature | surface | detail |
|---|---|---|
| CLI | `sfs <cmd>` (shared by Claude Code / Codex / Gemini CLI) | [host channels](./23-host-channels-and-mcp.md) |
| MCP | `mcp-server/` stdio `solon-mcp` (`sfs_*` tools, 1:1) | same doc |
| Agent SDK | `templates/claude-agent-sdk-zero/` scaffold | same doc |
| Windows | `install.ps1` / `sfs.ps1` bridging to the Git Bash bash SSoT | [Windows](./04-windows-wrapper-stabilization.md) |

### 8. Install, upgrade, release operations

| feature | surface | detail |
|---|---|---|
| install / init | `install.sh` → `sfs init --layout thin --yes` / `sfs bootstrap` | README install section |
| staying current | `sfs upgrade` / `sfs update` / `sfs version --check` | README commands section |
| commit rail | `sfs commit plan` → `commit apply --group` | [start](./02-handoff-after-start.md) |
| distribution channels | Homebrew tap / Scoop bucket (sha-pinned per release) | CHANGELOG |
| handoff verification | `sfs handoff verify` / session-transfer policy | [learning guide](./24-topdown-learning-guide.md) |

### 9. Safety contract (applies everywhere)

- Gates, metrics, and advisories are **all signal-only** — no verdict ever
  blocks a command (only transition *order* may be enforced by design, and
  even that is waiver-transitionable).
- Before wiring a new connector/MCP/external tool: the **four-question risk
  preflight** (untrusted ingest / actions+identity / blast radius /
  observability — suggest-only, `policies/credential-hygiene.md`); capsule
  tools narrow at the verb grain — irreversible verbs removed from the list
  are blocked by construction.
- Boundaries are designed from **what the operator permits**, never today's
  model limits — emergent in-bounds behavior after an upgrade is
  observability's job (`policies/harness-autonomy.md`
  BOUNDS_OUTLIVE_MODEL_LIMITS).
- What must hold every time lives in the **harness**, not the prompt — over a
  long run prompt sentences go unheeded, so standing rules move down to rails,
  gates, and regression locks (`policies/harness-autonomy.md`
  PROMPTS_ARE_SUGGESTIONS).
- Every point where the agent touches untrusted content carries an injection
  checkpoint, and a successful hijack is assumed and bounded by narrowing what
  it can reach (`policies/credential-hygiene.md` INGRESS_TRUST_CHECKPOINT).
- Per-step human approval is **not a safety argument** — its detection power
  falls as a session runs, so standing rules move to the harness layer and
  scarce consent is spent only on the classes nothing may decide alone
  (`policies/harness-autonomy.md` APPROVAL_FATIGUE_DECAY).
- A **class of actions is never routed to discretion** — credential or source
  exfiltration, and any message addressed to a person that leaves the machine.
  It is declared on a config data surface, a user request cannot unlock it, and
  only the declaration can change, before the run
  (`policies/credential-hygiene.md` NEVER_APPROVE_CLASS). A blanket waiver wide
  enough to pass a whole class is gate removal, not an exception.
- Writes are consent-gated: `--yes` / `--apply` / dry-run previews by default.
- External orchestrators, knowledge graphs, and the wiki are opt-in —
  removing them leaves every feature working (standalone guarantee).
- Cost/readiness adapters read aggregate token counts and tool names only —
  never message text.
