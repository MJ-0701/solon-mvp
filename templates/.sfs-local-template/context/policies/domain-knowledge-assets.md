---
id: sfs-policy-domain-knowledge-assets
summary: Turn expert domain know-how into AI-usable project assets.
language: en
load_when:
  - domain knowledge
  - domain expertise
  - expert know-how
  - SME
  - playbook
  - heuristic
  - craft
  - skill
  - knowledge asset
  - domain moat
  - reference absorption
  - lecture reference
  - benchmark practice
status: filled-v1
content_policy: "compile expert judgment into small reviewable assets; do not publish or share private know-how without human approval"
---

# Domain Knowledge Assets Policy

AI makes generic coding and scaffolding more evenly available. The durable moat
is expert domain judgment made legible enough for AI to reuse: terms, rules,
heuristics, examples, counterexamples, checks, and taste boundaries.

## Activation Rules

- The user provides field notes, specialist critique, craft vocabulary, domain
  rules, or "we always do this here" guidance.
- The same explanation has been repeated across sprints, reviews, or agents.
- A plan depends on tacit expertise such as finance, operations, medical,
  legal, design, video, music, marketing, support, or internal company process.
- A user asks to turn notes into a skill, playbook, knowledge pack, checklist,
  wiki page, fixture, test, or agent prompt.
- A review finds that generic AI output missed domain-specific judgment.
- A user asks to absorb a lecture, benchmark, tool demo, vendor workflow, or
  outside reference into Solon without letting product direction drift.

## Asset Shapes

- Raw source: original note, capture, interview, example, support ticket, PR
  comment, meeting note, or expert review. Preserve it by reference.
- Ubiquitous language: canonical terms, forbidden aliases, actor/state names,
  domain boundaries, and source links.
- Playbook/checklist: when-to-use rules, step order, risk signs, recovery steps,
  and "do not do this" constraints.
- Skill/knowledge pack/review lens: compact reusable guidance that an agent can
  load for a recurring domain or craft judgment.
- Fixture/test/smoke: example and counterexample pairs that prove the guidance
  is executable, not decorative.
- Wiki TopicHub/index: retrieval map that points to the source truth and the
  compiled asset.

## Six Required Council Roles Asset Loop

The organization has five organization divisions: strategy-pm, dev, QA, design,
and infra. Taxonomy is the cross-cutting product function/lens. All six are
required council roles and form the default domain-asset collector. Each row
asks what human know-how should be reused next time:

- Strategy-PM: market, positioning, priority, rollout, and decision-boundary
  judgment becomes roadmap/playbook/AC guidance.
- Taxonomy: vocabulary, states, events, aliases, and classification judgment
  becomes glossary, domain map, naming rule, or review lens.
- Design: workflow, taste, interaction, accessibility, copy, and visible craft
  judgment becomes `design.md`, checklist, example/counterexample, screenshot,
  or browser-review heuristic.
- Dev: architecture, runtime, invariant, API, migration, and implementation
  judgment becomes boundary notes, interface contracts, fixtures, tests, or
  source-driven implementation guidance.
- QA: defect, risk, regression, edge-case, and acceptance judgment becomes
  fixture sets, smoke checks, acceptance ledgers, or review questions.
- Infra: deploy, observability, security, reliability, rollback, and cost
  judgment becomes runbook, monitor, shipping check, or operations evidence.

Each council-role ledger row should record `asset_candidate`: reuse an existing
asset, create a new one, or mark a concrete gap/waiver.

## Compile Flow

1. Keep the raw source in its source location. Do not paste large private notes
   into core context.
2. Extract the smallest reusable unit: terms, heuristic, decision rule, example,
   counterexample, or review question.
3. Run the reference absorption guard: separate the durable principle from the
   source's vendor workflow, tactic, UI, metric, and implementation fashion.
4. Choose the narrowest asset shape. Prefer docs/solon, llm-wiki, checklist,
   fixture, or review lens before adding a new command or tool.
5. Record source, owner/expert, confidence, gaps, and promotion status.
6. Add a feedback check: review question, test, fixture assertion, smoke run,
   or dry-run prompt.
7. If the asset will be shared outside the private project, require explicit
   human approval for IP, privacy, attribution, and commercial boundary.

## Boundaries

- Do not flatten craft into generic advice. Preserve the domain words and the
  reason the rule matters.
- Do not treat AI confidence as expert authority. AI can package, compare, and
  test; humans own meaning, taste, public contract, and publish/share decisions.
- Do not hard-code one expert's preference as universal product law without
  scope, counterexamples, and review.
- Reference is input, not direction. Vendor feature is evidence, not product identity.
  Extract the generalizable Solon protocol, then discard or defer the vendor-specific shape.
- Ambiguous or vendor-specific details stay wiki-only/deferred until they prove
  they improve SFS intent capture, plan contracts, handoff, review evidence, or
  repeated-context retrieval with AC/test/review evidence.
- A "skill" is an output shape, not a mandatory lifecycle command. Use the SFS
  command/policy surface unless a real tool boundary is needed.

## Review Questions

- What raw source or expert signal produced the asset?
- Which terms, heuristics, examples, and counterexamples became reusable?
- Is the asset small enough for an agent to load at the right moment?
- Is there a check that proves the knowledge changes behavior?
- Are privacy, IP, attribution, and publication status explicit?
- Did the work avoid turning private notes or host-local skill bundles into
  project SSoT without approval?
- Did the work avoid treating a lecture, benchmark, vendor workflow, or tool
  feature as Solon product direction?
- What was generalized into Solon protocol, and what stayed wiki-only/deferred?
- If the domain knowledge affects product behavior, is it tied to AC, files,
  docs, tests, wiki, or review evidence?

## Evidence

- Source link, capture id, interview/note path, or expert review reference.
- Compiled glossary/domain-map/playbook/skill/knowledge-pack/checklist/wiki path.
- Example/counterexample fixture or review prompt that exercises the rule.
- Verification command/result, dry-run transcript excerpt, or reviewer verdict.
- Human approval/waiver for shared-public, paid, or cross-team publication.

## AI-Era Moat Notes

Review-lens prompts distilled from 2026-05 practitioner talks. Discussion
checks, not hard rules; cited claims are speaker-time assertions.

- "Domain knowledge over coding": as AI evens out generic implementation, the
  scarce input is knowing *what* to build and *why*. When a plan leans on
  AI to write code, check that the domain judgment behind it is captured as a
  reusable asset, not left tacit.
- Public-data ceiling = private-data value: AI trained on public information
  cannot reach an operator's proprietary, non-public data or hard-won alpha.
  Treat the user's own private knowledge and data as the asset worth compiling
  and protecting.
- Asset-ize the know-how: package repeated work and craft judgment into
  reusable skills, prompt packs, checklists, or review lenses — turning shared
  expertise into durable leverage (and reputation) rather than one-off chat.
- Trust, relationship, and scarcity are the AI-era moat: as copying and option
  overload level out raw skill, trust becomes the differentiator. Ask whether
  the work treats earned trust, relationships, and scarce judgment as a solo
  operator's positioning assets rather than soft extras.
- Community and support loops are domain assets: repeated customer questions,
  fast fix explanations, mentor answers, and field-exclusive materials should
  be compiled into playbooks, FAQ/checklists, onboarding, and review prompts
  before they disappear into chat or inbox history.
- AI literacy is a baseline assumption, not an option: using AI is now table
  stakes (refusing it is a disadvantage). Ask whether onboarding and packs
  assume the operator already leverages AI, and what scarce value is being
  captured on top of that.
- Root knowledge beats tool fashion: prompt, agent, and harness techniques will
  change, but product purpose, web/AI fundamentals, and domain language are the
  reusable substrate that should become glossary, playbook, checklist, or lens.
- Domain expertise is a build/no-build gate: when a paid product, especially
  B2B/B2G, depends on a domain the team does not understand, record the expert
  partner, evidence plan, or stop condition before letting AI implementation run.
- Delegation muscle needs compiled context: turning repeated human work into
  agent work requires explicit goals, materials, ask-back rules, output shape,
  feedback checks, and a second-brain path the agent can load without searching a pile.
