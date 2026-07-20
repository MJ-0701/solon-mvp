---
doc_id: sfs-current-product-shape-en-29
title: "Feature Overview"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-07-20
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

### 2. Evidence and record primitives

| feature | surface | detail |
|---|---|---|
| minimal fact capture | `sfs capture [--kind ...]` / `sfs note` | [capture](./08-capture-is-an-evidence-primitive.md) |
| decisions / events | `sfs decision` / `sfs event` | routed context `commands/*` |
| reports / bugs | `sfs report` / `sfs report-bug` | bug-report lifecycle policy |
| recall past work | `sfs recall` | routed context `commands/recall.md` |
| shared artifacts | `docs/solon/<domain>/.../report.md` / `retro.md` | [design.md](./13-design-md-and-anti-ai-slop-guardrails.md) |

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

### 5. Teams and orchestration

| feature | surface | detail |
|---|---|---|
| team preset activation | `sfs team use <solo\|pair\|trio>` / `team refresh` / `team show` | [human-agent teams](./27-human-agent-teams.md) |
| six-division council (always-on) | `sfs division` + `.sfs-local/divisions.yaml` | [review lenses](./14-divisions-knowledge-packs-review-lenses.md) |
| work routing / orchestration | `sfs route` / `sfs orchestrator` / `sfs dispatch` | [work intake routing](./20-ai-work-intake-routing.md) |
| recurring loops | `sfs loop` + the loop-taxonomy policy (four-type decision lens) | routed context `policies/loop-taxonomy.md` |
| agent identity / compartments | `agent-identity` and compartment policies | [identity and compartments](./28-agent-identity-and-compartments.md) |

### 6. Memory and wiki (long-horizon memory)

| feature | surface | detail |
|---|---|---|
| LLM navigation wiki | `llm-wiki/` (opt-in, waiver available) | [wiki continuity](./19-obsidian-llm-wiki-continuity.md), [onboarding](./25-wiki-onboarding-guide.md) |
| raw source intake | `sfs ingest --source-type --purpose` | [intake routing](./20-ai-work-intake-routing.md) |
| promotion pipeline | `sfs tidy --all --wiki-promote [--apply]` | [domain knowledge assets](./21-domain-knowledge-assets.md) |
| repeated-mistake ledger | `.sfs-local/lessons.md` (record→reflect flywheel) | routed context `policies/lessons-accumulation.md` |

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
- Writes are consent-gated: `--yes` / `--apply` / dry-run previews by default.
- External orchestrators, knowledge graphs, and the wiki are opt-in —
  removing them leaves every feature working (standalone guarantee).
- Cost/readiness adapters read aggregate token counts and tool names only —
  never message text.
