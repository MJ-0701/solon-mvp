---
id: sfs-policy-harness-readiness
summary: AI-readiness (Sanity) audit rubric, waiver, and the readiness-before-cartography order discipline behind `sfs harness doctor` / `map`.
load_when:
  - readiness
  - sanity audit
  - cartography
  - harness map
  - readiness waiver
  - dead code
  - convention consistency
  - AI-ready codebase
---

# Harness Readiness (Sanity Audit)

A codebase map drawn over an unhealthy codebase is false information: dead
files get mapped as live surface, mixed conventions get mapped as two
patterns, and an agent trusts all of it. So Sanity precedes Cartography —
`sfs harness doctor` scores readiness first, and `sfs harness map` is
*recommended* (never forced) to follow a pass or an explicit waiver. All of
this is signal-only (ALT-INV-3): no score, missing audit, or missing waiver
ever blocks a command.

## RUBRIC

Deterministic bash scoring, file-level heuristics only (no compiler, linter,
or language-tool dependency). Each axis prints its score with one evidence
line; axis names below are the exact tokens doctor prints.

| axis | 0 | 1 | 2 |
|---|---|---|---|
| `self-verification` | no test runner detected | test surface without a named entrypoint | named entrypoint an agent can run unaided (`tests/run-all.sh`, package.json `test`, Makefile `test:`, gradle/maven) |
| `dead-code` | 3+ unreferenced `scripts/*.sh` | 1-2 unreferenced | none unreferenced (or no candidates) |
| `convention-consistency` | 3 filename styles coexist in one extension group | 2 styles | single style (or insufficient sample) |
| `entry-doc-freshness` | entry doc absent, or 3+ broken relative links | 1-2 broken links | all relative links in `SFS.md` / root adapter docs resolve |

Total is advisory (`N/8`). Scores read the consumer working tree only —
never the shipped distribution — and skip `.sfs-local/` (SFS-owned files are
not the consumer's codebase health).

## AI_FRIENDLY_SURFACE

A second axis group next to the Sanity four (own `ai-surface total N/8`
line, same 0-2 form, same signal-only contract). The repo-standard four
elements a 3,500-engineer rollout converged on (external case, cite:
`idea_wiki:L087-I5`) map 1:1 onto surfaces solon installs, so scoring is
file existence/freshness:

| repo-standard element | solon surface | axis token |
|---|---|---|
| repository guide (MD) | `SFS.md` router + root adapter docs (`CLAUDE.md`/`AGENTS.md`/`GEMINI.md`) | `repo-guide` |
| rules / guardrails file | routed context loadable (`kernel.md` + `_INDEX.md`, packaged or `.sfs-local/context/` override) | `guardrails` |
| repeated work as slash commands / skills | project command/skill artifacts (`.claude/commands|skills`, `.sfs-local/skills`); completed-work logs count as promotion material (1/2) | `command-skill` |
| AI code reviewer active | Gate 6 review rail — sprint `review.md` evidence (2/2) vs installed-but-unused (1/2) | `ai-reviewer` |

| axis | 0 | 1 | 2 |
|---|---|---|---|
| `repo-guide` | neither surface | `SFS.md` or adapter docs, not both | `SFS.md` + >= 1 root adapter doc |
| `guardrails` | kernel and `_INDEX` both unavailable | one of the two | both loadable |
| `command-skill` | no artifacts, no promotion material | completed-work logs only | >= 1 compiled command/skill |
| `ai-reviewer` | no review rail | rail installed, no sprint evidence | review evidence in >= 1 sprint |

Unlike the Sanity axes these intentionally check solon-installed surfaces
(including the packaged distribution for `guardrails`); doc freshness itself
stays with the Sanity `entry-doc-freshness` axis and is not re-scored here.

## ORDER_DISCIPLINE

- Run the readiness audit (doctor section) before `sfs harness map --write`;
  map over a failing Sanity score is a false-map risk, not an error.
- `map --write` prints a one-line readiness advisory when no waiver is
  recorded. The map is always written — the advisory can never block.
- Re-audit after structural changes (test surface added/removed, script
  cleanup, adapter-doc rewrite), not on a timer.

## WAIVER

- Path: `.sfs-local/readiness-waiver` — one line: reason + date.
- Recording a waiver says "we know the Sanity state and map anyway"; doctor
  and `map --write` then echo the waiver instead of the advisory.
- A waiver is a project decision, not a suppression trick: keep the reason
  honest (e.g. "legacy pilot repo, cleanup scheduled"). Delete the file to
  re-arm the advisory.

## KNOWLEDGE_GRAPH_POINTER

Graphify-class knowledge graphs are an **opt-in external pointer only**,
same pattern as `obsidian-llm-wiki.md`: the consumer may attach one, the
core never depends on it, and removing it changes nothing. Graph freshness
(drift against the moving codebase) is an unsolved maintenance cost — that
is the standing reason this stays a pointer, not a core dependency.
