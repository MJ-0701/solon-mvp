---
id: sfs-user-context-separation
summary: Split context three ways — soul (agent identity) / user (operator) / procedure (routed) — so identity stays thin and operator context has its own home.
load_when: ["operator context", "user context", "soul user procedure", "identity layer", "context separation", "who is the operator", "personalize agent", "thin identity", "compartment", "per-channel scope", "cross-boundary memory", "private learning leak"]
---

# User Context Separation

Keep three kinds of context in three places so none of them bloats the others.
Source: note 27 (Hermes splits memory into soul.md / user.md / skill MD) and
note 12 (AI-employee onboarding — identity stays a thin layer; org process and
procedure live in routed docs/skills, or the identity file drifts and bloats).

## THREE_LAYERS

- **Soul — agent identity.** Personality, tone, role, hard prohibitions of the
  agent itself. Home: `personas/` (CEO / CTO / CPO / worker personas). Keep it
  thin; it describes *how the agent behaves*, not what the project is.
- **User — operator context.** Who is running the project and how they want the
  agent to work: role, expertise, autonomy/ask bias, runtimes, reporting
  channel, standing always/never preferences. Home:
  `operator-context.md`. This is the layer Solon was missing — operator
  preferences previously had nowhere to live except the agent identity file.
- **Procedure — how work is done.** Lifecycle, gates, policies, skills. Home:
  the routed context (`kernel.md` + `commands/` + `policies/`), loaded on demand
  via `_INDEX.md`. Never inline procedure into soul or user files.

## WHY_SEPARATE

- Identity bloat is the failure mode: appending operator preferences or process
  rules onto a persona/identity file causes context bloat and SSoT drift
  (note 12). A dedicated operator file keeps the soul layer thin.
- Each layer has a different change cadence and a different owner: soul is set by
  the distribution, user is owned by the operator, procedure is routed and
  versioned. Mixing them couples edits that should move independently.
- Operator context is the personalization point for a one-person operator — the
  same Solon runtime serves different operators by swapping only the user layer.

## COMPARTMENT_SCOPING

The three layers above split *kinds* of context; a compartment splits *boundaries
of work*. Access and memory belong to the **compartment** (the work boundary — a
project, repo, or channel) **not to the user** who happens to be present. The
model:

- **Baseline inherited, per-boundary override.** A workspace baseline applies to
  every compartment; a compartment narrows or overrides it for its own scope. A
  grant given for one compartment is not a grant everywhere.
- **Cross-boundary memory does not leak.** What an agent learns inside one
  compartment stays scoped to it — a private compartment's memory and access
  **does not leak** into another. Private learning in one boundary never silently
  surfaces in a different one.

For a one-person operator this is not multi-tenant overhead: the live boundaries
are the operator's own — a personal/learning docset versus a company project. The
rule keeps private-docset learning from bleeding into company-project output (the
product-leak boundary the distribution already guards with
`tests/test-private-dev-path-hygiene.sh`). It is the memory-scope companion to the
agent's own per-identity credential scope (`credential-hygiene.md` AGENT_IDENTITY)
and the worker handoff isolation of `runtime-token-firewall.md`. External
validation (by-reference): a Claude blog post on the agent identity access model,
2026-06-24 — permissions move from per-user to per-compartment, each private
boundary keeping a separate memory and access scope; principle adopted, vendor
surfaces held out.

## TEMPLATE_DISCIPLINE

`operator-context.md` ships as **placeholders only** (`<OPERATOR-ROLE>`, …) — no
fixed operator values baked into the distribution (the root `CLAUDE.md`
placeholder rule; `tests/test-private-dev-path-hygiene.sh` guards the related
private-path leak). The operator fills it at onboarding; unset values are asked
for via `AskUserQuestion` at runtime rather than defaulted
(`skill-catalog-discipline.md` SETUP_VIA_PLACEHOLDER).

## CROSS_REFERENCES

- Soul layer: `personas/` (shipped persona files).
- Project (not operator) context: `llm-wiki/project-context.md`.
- Procedure routing: `_INDEX.md`, `kernel.md`.
- Setup-via-placeholder convention: `skill-catalog-discipline.md`.
