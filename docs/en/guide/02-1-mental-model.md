---
doc_id: sfs-product-guide-en-2
title: "1. Mental Model"
visibility: oss-public
doc_type: user-guide
language: en
updated: 2026-05-22
parent: docs/en/guide.md
summary: "1. Mental Model"
load_when: "Read when docs/en/guide.md routes to this section."
---
## 1. Mental Model

Solon gives a project two things:

- the `sfs` command
- project-local active workbench state in `.sfs-local/`

The files you normally edit are:

| File | Role |
|---|---|
| `SFS.md` | Project operating identity |
| `CLAUDE.md` | Where Claude Code finds Solon |
| `AGENTS.md` | Where Codex finds Solon |
| `GEMINI.md` | Where Gemini CLI finds Solon |

Project-local `.claude/`, `.gemini/`, and `.agents/` command/skill files are
optional. Install those native shortcuts only when a project needs them:

```bash
sfs agent install all
```

If root agent docs accumulated SFS policy text, run `sfs agent doctor --fix`.
It archives recognized SFS adapters and rewrites them as frontmatter-only
pointers.

Old projects can be upgraded into the lighter thin-runtime shape. Use
`sfs upgrade --layout vendored` only when Solon package files must stay inside
the project.
When adopting an existing codebase, `sfs adopt --ddd-tdd-retrofit --apply`
scans source paths for DDD-lite boundaries, writes a retrofit plan, and seeds
the next sprint so legacy refactor work starts with characterization/TDD
evidence before code moves.
After adoption or upgrade, `sfs tidy --all --apply` can clean targetless
surface residue: project-local cache notices, orphan logs, placeholder auth,
and split archive buckets collapse back under `archives/adopt/surface-cleanup`.
`.sfs-local/` is not a history stack. A file stays visible only when its
one-line keep reason is clear. `events.jsonl` is an active-sprint ledger: keep
it while the current sprint is open, then hand durable history to
`docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/` and git history.
Domainless exploration may still use the legacy
`docs/solon/<english-workspace>/<yyyyMMdd>/` fallback. Repeated cleanup
evidence is date-bucketed as
`.sfs-local/archives/adopt/surface-cleanup/<yyyyMMdd>/surface-cleanup.tar.gz`
instead of many visible timestamp folders.

Current Solon separates divisions, knowledge packs, and review lenses. The local
`.sfs-local/divisions.yaml` file is the six-slot compatibility activation state
for older projects. Actual guidance is read from product-level DDD/TDD, backend,
strategy/PM, QA, design/frontend, infra/DevOps, management-admin, and taxonomy
packs/lenses. DDD/TDD is the cross-cutting product behavior floor. Backend is a
dev specialization, management-admin covers finance/bookkeeping/tax/accounting,
and taxonomy is a cross-cutting language/classification lens.
The user does not need to choose those labels manually. The AI should read the
relevant Solon lens when the work calls for it, then explain the judgment in
plain language.

Agent-skills-style practices are absorbed into existing SFS
commands instead of becoming new lifecycle commands: source-driven
implementation, stop-the-line debugging, deprecation/migration, shipping
checks, and stronger review lenses.
Small deterministic review findings stay inside the same cycle. For grep
scope, stale evidence, missing AC/file mapping, evidence path typos, or
meaning-preserving doc consistency, the agent patches, verifies, and reruns the
same gate review without asking the user to trigger it. User input is reserved
for product judgment: scope, architecture, public contract,
security/privacy/data-loss, cost/latency/model policy, destructive behavior, or
changed AC meaning.

Sprint handoff documents are shared under
`docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/report.md` and
`docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/retro.md`. Users normally
run `sfs start "<goal>"`; SFS infers high-confidence labels from the natural
goal. `--domain`, `--subdomain`, and `--feature` are override levers when the
inference is wrong, while `--workspace <english-name>` remains the legacy
fallback for early exploration. The prose should use the user's native or
workspace language, matching the native-language commit message rule.
