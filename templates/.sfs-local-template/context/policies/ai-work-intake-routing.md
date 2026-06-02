---
id: sfs-policy-ai-work-intake-routing
summary: Four-part AI work intake and work-size routing for SFS.
load_when:
  - intake
  - goal
  - materials
  - ask-back
  - output format
  - repeated work
  - batch workspace
---

# AI Work Intake Routing

Use this policy when a user asks SFS to turn loose work into a useful AI-assisted
workflow. It absorbs general AI prompting advice into Solon terms without
creating a new lifecycle command.

## Four-Part Intake

Before Gate 2 (Brainstorm) can become a useful plan seed, identify four fields
from the user's request and available project context.

- Goal: what outcome is being produced and why it matters now.
- Materials: source notes, files, screenshots, prior docs, code, links, examples,
  meeting context, or project memory the agent should use.
- Ask-back rule: what is ambiguous enough to ask before drafting, and what can be
  safely inferred from SFS history, wiki, docs, or the current sprint.
- Output format: the artifact shape the user can use immediately, such as a
  meeting note, checklist, table, PR, plan, HTML guide, report, or per-file
  output plus master index.

Do not turn these fields into ceremony. Infer missing pieces from nearby
evidence when safe; ask only the smallest blocking question when the missing
piece would change product meaning, scope, owner decision, or artifact shape.
For documentation-poor projects, nearby evidence includes code structure, tests,
config, git history, release/deploy scripts, and issue/PR traces. The agent must
form a minimal known/unknown map before asking the user to re-explain broad
project context.

## Deep-Interview Intake Battery

When the user gives an ambiguous app/product request, reduce ambiguity before
Gate 3 rather than rewarding vague agreement. Target `ambiguity <= 20%` for
plan-ready status; in hard mode, keep Brainstorm as `status: draft` until the
material owner decisions are answered. Ask only questions that change the
artifact: purpose (business/prototype/portfolio demo), product/domain, stack
preference or AI recommendation, must-have vs not-now features, done bar
(completion: core E2E, responsive UI, README/handoff), and desired detail depth. A bare
"ㄱㄱ" or "ok" advances the interview only when these answers are already
captured; otherwise it is not plan readiness.

## High-Context Prompt Normalization

Keep the user's native language, but before worker handoff compile high-context
or ellipsis-heavy wording into a low-context contract: explicit actor, object,
scope, desired result, and acceptance signal.

Prefer positive target behavior over negative-only phrasing. Forbidden moves
still matter, but they should be checkable constraints paired with what the
output should do.

When tone, emotion, customer empathy, or literary nuance matters, capture
examples/non-examples and the human review boundary instead of trusting
translation or summary alone.

## Work-Size Routing

Classify the work before choosing how much SFS machinery to activate.

- Delegation candidates should start small: repeated work with visible output,
  low blast radius, and easy before/after measurement. Record feedback so the
  workflow is iterated instead of trusted once.
- One-off work: answer or edit directly in the current chat when the task is
  small, non-repeated, and does not need durable project memory. Avoid opening a
  sprint only to format a single note or short answer.
- Repeated work: promote stable goal/material/format rules into SFS project
  memory, `SFS.md`, `docs/solon/`, or `llm-wiki/` so the next request can be
  short and still grounded.
- Memory-formation work: when a project lacks a documentation system, use
  `llm-wiki/` to create the first durable project memory from evidence. Record
  project map, domain terms, decision ledger, unknowns/gaps, questions ledger,
  and guardrails before feature development depends on unstated assumptions.
- Batch workspace work: when the user provides a folder or many files, preserve
  raw inputs, process each source separately, and create the requested aggregate
  artifact such as a master table, index, status report, or owner/action rollup.

The routing terms are vendor-neutral. Claude chat/project/cowork, Codex threads,
local folders, Obsidian, Git, or other tools can implement the same pattern; SFS
records the durable contract and evidence, not the vendor brand.

## Review Questions

- Are goal, materials, ask-back rule, and output format explicit or safely
  inferred?
- Was high-context language normalized into explicit actor/object/scope/result
  before worker or reviewer handoff?
- Did the agent choose one-off, repeated, or batch workspace scope before adding
  ceremony?
- For repeated work, was durable project memory updated or was a gap recorded?
- For batch work, were raw sources preserved and the aggregate artifact tied back
  to per-source outputs?
- Did the agent ask only blocking questions instead of making the user restate
  context already available in SFS/wiki/docs?
- For documentation-poor projects, did the agent check code/git/tests/config
  before broad ask-back, and did it record already-answered facts?

## Evidence

- Brainstorm/plan fields or report text showing the four-part intake.
- Links to materials, wiki maps, source folders, or raw inputs.
- Output artifact path and format.
- For repeated work, updated memory/wiki/docs or a recorded gap/waiver.
- For memory-formation work, a project map, decision/questions ledger, and
  unknowns/gaps with source links and confidence.
- For batch work, per-source output plus master index/table/report.
