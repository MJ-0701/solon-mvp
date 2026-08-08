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

Decomposition is a model-invariant discipline: however capable the model,
splitting work into small, repeatable, **checked steps with controlled
inputs** stays — capsules are that discipline's contract form. External
validation (by-reference): a frontier finance-diligence builder kept
deterministic step composition over single-model runs even on its strongest
model (Claude blog, 2026-07-13); vendor and product specifics held out.

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

One optional field complements the table: `exemplar` — a pointer to one
known-good reference output or pattern the worker should imitate. Attach it
when one exists; a worked example steers a worker more cheaply than longer
prose. Absence is not a validation finding.

LEAST_AGENCY_VERB_SCOPING: `tools_allowed` narrows at the **verb/action**
grain, not just the tool grain — grant the minimum *actions* the goal needs,
and remove irreversible verbs (delete / send / publish / push / pay-class
actions) from the list entirely when the goal does not require them. A verb
absent from the world cannot be attempted: removal is a by-construction block,
strictly stronger than prompting the worker not to use it. This is the
access-control face of the typed boundary rule
(`critical-rule-hook-promotion.md` DECLARATIVE_BOUNDARY_SURFACE); when an
irreversible verb *is* required, it stays behind that typed gate. External
validation (by-reference): a Claude blog CISO guide (2026-07-17) — controls
scope to verbs, and least agency beats least privilege for agents; vendor
specifics held out.

CONSTRAIN_ORCHESTRATION_FREE_JUDGMENT: the capsule's fields and
LEAST_AGENCY_VERB_SCOPING above constrain the **orchestration** layer — what
always happens, in what order, with which verbs reachable. They are not
licence to constrain the **judgment** interval as well. Inside `files_scope`
and `tools_allowed`, how the worker gets to the outcome is left open:
open-ended tools (read, search, shell within scope) are what let it route
around a surprise instead of failing at it, and prescribing the method is how
a capsule loses the improvisation that produced the best results. The dividing
line is a placement rule, not a strength dial — **what must always happen is
hard-coded in the harness; how it is solved is free** (`harness-autonomy.md`
PROMPTS_ARE_SUGGESTIONS puts the first half in the harness rather than in
prose). It is also why the dispatcher/specialist split holds: the dispatcher
constrains routing, the specialist keeps its judgment. A capsule whose
`acceptance_criteria` pin the method rather than the outcome has crossed the
line, and it shows up as a deviation the worker must log rather than as better
control. External validation (by-reference): a Claude blog writeup on a
long-running autonomous investigator (2026-07-22) — constrain orchestration,
free judgment; vendor, product, and business figures held out.

SUBAGENT_TIER_DEFAULT: for high-volume worker capsules the economical default
is a mid-tier runtime, with escalation to the strongest tier reserved for
low-confidence or genuinely hard slices — the routing decision and its
call conditions are data, owned by `external-orchestrator-entry.md`
ADVISOR_STRATEGY_BINDING and the `agent_runtime_bindings` surface. Not
restated here; named so a capsule author knows a tier is a routing input, not
a per-capsule field.

Effort is allocated **at issue time, per pipeline stage**, not only escalated
after a failure. Routing, extraction, and summarization stages issue at low
effort; the final judgment and review stages issue high. The failure-driven
escalation in `token-harness.md` KNOB_DIAGNOSTIC_LADDER still applies on top —
this is the opening bid, not a ceiling. Deciding it up front is what makes an
unattended run's cost predictable instead of discovered the next morning.

`token_budget` and `timeout` follow **warn-before-block**: surface a threshold
warning before the ceiling (the 75/90% two-step alert pattern, external
admin-controls case by-reference) so the worker decides refine / pivot / halt
at the warning instead of being cut mid-task at the cap — the same quantitative
escalation shape as `harness-autonomy.md`'s discard ladder. The cap itself is
unchanged; the warning is a signal, not a new gate.

## Handoff rules

- Capsule-only: never forward the lead's full conversation history, hidden
  chain, or unrelated prior turns (see `runtime-token-firewall.md`).
- Final-message-only return: the worker's own reasoning and body never enter the
  parent context — only its final message (the artifacts at `output_paths` plus
  a short result) crosses back. Isolation is bidirectional: parent history does
  not flow down, worker body does not flow up, so neither pollutes the other's
  window or survives into the parent's compaction. A bridge that leaks the
  worker's transcript into the parent is the same escape-hatch failure as one
  that inherits the parent's chat. External validation (by-reference): a Claude
  blog post on steering coding agents (2026-06-18) — a sub-agent's body never
  enters the parent conversation, only the final message returns.
- Poll artifacts at `output_paths`, not the worker's thoughts. Insufficient
  evidence → the worker returns partial/fail and names the missing artifact.
- DONE_IS_ARTIFACT_ON_DISK: in a parallel work queue, an item is done **iff
  its artifact exists at `output_paths` on disk** — never because a status
  message said so. The queue is re-derived from disk state each round, so
  interruption and resume are correct by construction: a crashed or killed
  run resumes by rebuilding the queue from what actually shipped (same
  migration source as the serialization rule, by-reference,
  `token-harness.md` SERIALIZE_EXPENSIVE_OPS). **The research step is inside
  this contract, not upstream of it**: context an agent explores is committed
  as a file the next step reads, so what the implementation is built on is
  reviewable and re-derivable rather than living in one session's window. The
  refutation trace of ANTAGONISTIC_RESEARCH_PASS
  (`source-pointer-citation.md`) rides that same artifact.
- SHARED_SURFACE_CONFLICT_SCAN: before a worker edits a **shared surface**
  (a file or contract other lanes also touch), it scans the recent commits
  and the live queue for overlapping work and surfaces the conflict *before*
  editing — a preflight flag beats a merge conflict after both lanes spent
  their budget. Composes with the disjoint-`files_scope` rule; this covers
  the surfaces that cannot be made disjoint.
- Deviation convention: when the territory contradicts the capsule's plan or
  `acceptance_criteria` assumptions mid-slice, the worker makes the
  conservative choice, records it under a `## Deviations` heading in the
  `output_paths` evidence (what the plan said / what was found / choice /
  why conservative), and continues — no silent improvisation, no hard stop
  for non-blocking gaps (`unknowns-and-deviations.md` DEVIATIONS_LOG). The
  lead reviews deviations with the result; recurring classes feed
  `lessons-accumulation.md`.
- A bridge that cannot express these fields (e.g. a forked-context helper that
  inherits the whole chat) is a manual escape hatch, not the default executor.
- For chat/channel handoffs, encode the server/channel/thread locator as
  evidence, not permission to read unlimited history. Mention/allowlist/
  auto-response scope belongs in `tools_allowed` or `pii_rules`; thread
  close/archive and resume summary belong in `output_paths`.
- Verifier ≠ author: the agent that verifies `acceptance_criteria` must not be
  the same instance as the authoring agent (self-evaluation bias). "Different
  agent" means a different instance by default; model diversity (Codex/Gemini)
  is required only at Gate 6 cross-CPO, not as a per-capsule field.
- Verifier capsule patterns (by-reference options, not new fields): an
  **isolated verifier capsule** runs in clean context while the author iterates
  a **self-correction loop** until every `acceptance_criteria` passes; an
  **adversarial verifier capsule** is prompted to *refute* the result rather
  than confirm it — the pre-publish red-team discipline (`cardnews-redteam`-style
  review) generalized to any product verification. Both are selectable roles on
  the advisor↔Code file bus (`external-orchestrator-entry.md`). External
  validation (by-reference): a Claude blog build-day hackathon writeup
  (2026-06-17) — winners paired the agent with an independent verifier and an
  adversarial agent, looping until a fixed test set passed.

## Validation (agent-build lens)

At handoff, the `agent-build` review lens checks: every required field present;
`files_scope` and `tools_allowed` are narrow (no "do anything"); `token_budget`
+ `timeout` set; `pii_rules` cover any data the tools can reach; `output_paths`
are concrete; and the verifying agent is a different instance from the author.
A missing or unbounded field is a finding with a fix, not a pass.
