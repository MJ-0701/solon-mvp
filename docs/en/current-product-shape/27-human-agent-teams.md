---
doc_id: sfs-current-product-shape-en-27
title: "Working as a human-agent team"
visibility: oss-public
doc_type: product-reference
language: en
updated: 2026-06-28
parent: docs/en/current-product-shape.md
summary: "How a one-person operator runs Solon as a small human-agent team: an explicit roster, a documented north star with trust-gated proactivity, verification as the gate to autonomy, and treating human attention as the scarce resource."
load_when: "Read when adding a second agent (or a release/research specialist), setting an ambitious goal, or deciding how much an agent may do unprompted."
---
## Working as a human-agent team

Solo by default does not mean single-agent forever. As soon as a second runtime
joins (a worker, a researcher, a release specialist), you are running a *team* —
and a team needs a few things written down or it drifts into a pile of side
chats. The four habits below are what keep a small human-agent team coherent
(source: a Claude blog post on effective human-agent teams, 2026-06-24,
by-reference — generalized; vendor product/channel specifics held out).

### 1. The roster is an explicit artifact

Write down who is on the team and what each member owns. For agents, that means
each one's **owns / scope / tools** is declared on a durable surface — a
persona/skill file or a routed-context line, the same place
`model-profiles.yaml` already binds `role -> runtime`. The point is that "which
agent does what, with which tools" is *inspectable*, not implied.

The failure mode this prevents: when roles are left unspecified, you end up
spinning up side personal AI assistants for one-off questions, and context
fragments across places no one can see. A roster is the antidote — declare the
players, then route work to them by artifact (`policies/harness-autonomy.md`).

### 2. A north star makes agents proactive

Direction is what lets an agent suggest the next step instead of only reacting.
Document an **ambitious goal (north star)** and name **which agents may propose
work toward it** without being asked. Both live in the operator layer —
`operator-context.md` ships `<OPERATOR-NORTH-STAR>` and
`<OPERATOR-PROACTIVE-AGENTS>` placeholders (`policies/user-context-separation.md`).

Proactivity is **trust-gated, not on by default**: an agent earns the right to
propose for a task type only after it has the context and a verification means
you trust (see habit 3). A proposal stays suggest-only until you or a gate
accept it; the north star never bypasses an inviolable gate
(`policies/work-delegation-and-startup.md` NORTH_STAR).

### 3. Verification is the gate to autonomy

You expand an agent's autonomy on evidence, not hope. The rule:
**a delegated task earns more autonomy only once it carries a verification means**
— a test, a rubric, a style guide, or a separate verifier — that you can trust
before you review the work. No verifier yet → keep it supervised. This extends
the harness invariant that the author cannot be its own only reviewer
(`policies/harness-autonomy.md`).

Trust is built per task type over time. The recurring "lessons and missteps"
review that informs it is the lessons curation pass
(`policies/lessons-accumulation.md` CURATION_PASS) — a periodic, read-only digest
of what failed and what was corrected.

### 4. Human attention is the scarce resource

On a one-person team you are the bottleneck, so a good agent budgets your
attention (`policies/work-delegation-and-startup.md` HUMAN_ATTENTION_IS_SCARCE):

- **batch** blocking questions and ask them together at a decision point;
- **repeat the key context** in the surface you read, so you need not reload
  scrollback;
- **limit one-time-exposure items** — prefer durable artifacts you can re-find
  over things shown once;
- **communicate a workload guardrail** so you can see and cap what it takes on.

### Where it meets the Solon workflow

- The roster only matters once multi-agent work is actually selected; solo stays
  the default (`policies/harness-autonomy.md`).
- Operator-layer setup (north star, proactive agents) is filled at onboarding
  alongside the rest of `operator-context.md`
  (`current-product-shape/25-wiki-onboarding-guide.md`).
- Access scoping for the agents on the roster is its own topic
  (`current-product-shape/28-agent-identity-and-compartments.md`).
