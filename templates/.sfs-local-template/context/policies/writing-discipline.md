---
id: writing-discipline
summary: User-facing writing keeps only what the reader actually needs. No preamble, hedging, self-congratulation, re-statement, or filler conclusions. Core facts, decisions, evidence, paths, and exact commands are preserved.
load_when: ["writing", "readme", "guide", "report", "summary", "documentation", "docs", "user-facing", "README.md", "GUIDE.md", "RELEASE-NOTES.md", "caveman", "no fluff", "tone", "lens:docs", "lens:source-docs", "보고서", "안내서", "사용자 문서", "문서 작성"]
---

# Writing Discipline (user-facing artifacts)

Governs what an agent writes into user-facing artifacts: README.md,
GUIDE.md, BEGINNER-GUIDE.md, RELEASE-NOTES.md, study notes, project
reports, summaries, customer docs. Does NOT govern agent-internal logs,
evidence captures, or routed context modules — those have their own
rules (`context-pollution-guard.md`, `token-harness.md`).

## The rule

Keep only what the reader actually needs. Cut everything else.

Do NOT add:

- **Preamble** — "Great question!", "Certainly!", "Let me explain...",
  "In this document we will..."
- **Self-congratulation** — "comprehensive", "robust", "powerful",
  "seamless", "world-class", "best-in-class", "industry-leading"
- **Hedging without information** — "might", "perhaps", "I think",
  "could potentially", "may possibly"
- **Re-statement** — repeating what the heading or previous sentence
  already said
- **Filler conclusions** — "In summary...", "I hope this helps",
  "Thank you for reading"
- **Marketing prose** — adjective chains, em-dash flourishes used for
  rhythm, parallel structures with no added meaning

Do KEEP:

- **Facts** — what it is, who it is for, what it does
- **Decisions** — why this shape, what was rejected
- **Evidence** — file paths, line numbers, exact commands, test names,
  version numbers
- **Boundaries** — what is and is not in scope
- **Risk warnings** — when this fails, what to check

The success condition is not "shorter." It is "everything kept earns
its place." A sentence added to make a paragraph "flow better" without
adding new information should be deleted.

## Caveman vs writing-discipline

"Caveman" appears elsewhere in Solon
(`docs/ko/10x-value/06-token-diet-10x.md`) as an OPT-IN persona/말투
mode — playful, deliberately short tone. That is a *style toggle* for
product output, not a writing-quality contract.

This `writing-discipline` policy is the *quality contract*. It applies
whether or not the Caveman persona is on. With persona off you write
normally but without fluff. With persona on you write in Caveman style
AND without fluff. They compose; they are not the same thing.

## When this fires

Routed-context loader picks this policy up via the `load_when`
triggers. Most commonly:

- README.md / GUIDE.md / BEGINNER-GUIDE.md creation or refactor
- RELEASE-NOTES.md entries
- Sprint, project, handoff reports
- Study notes, customer documentation, onboarding pages

For agent-internal artifacts (sprint log, capture, decision file,
context modules), use `context-pollution-guard.md` and
`token-harness.md` instead.

## Review check

`sfs review --lens docs` and `--lens source-docs` verify:

- The artifact does not open with a preamble paragraph that adds no
  information.
- Headings and first sentences do not repeat each other.
- Adjective density stays low; chains of
  "comprehensive, robust, seamless, ..." are not present.
- File paths, command names, version numbers, decision rationale are
  present and exact.
- Filler conclusions are absent.

A CPO who finds the artifact technically correct but full of preamble /
self-congratulation / filler records a PARTIAL verdict with this policy
id, not PASS.

## Why this policy exists

Codex / Claude / Gemini default training pushes verbose, hedged,
self-congratulatory prose because that style tested well on rating
benchmarks. Solon-driven user-facing artifacts have a different
audience: a real human reading documentation, a maintainer reading
release notes, a study-note owner reading their own project. Default
verbose prose wastes their time and dilutes evidence. The compactness
floor in `kernel.md` says do not lose evidence; this policy adds the
upper bound: do not pad either.
