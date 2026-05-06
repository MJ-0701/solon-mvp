# Solon 10x Value

**Language**: [한국어](../ko/10x-value.md) / English

> Solon does not make code cheap by generating more of it.
> Solon makes AI work safer by turning unclear intent into shared concepts,
> domain language, testable contracts, small work units, and review signals.

AI coding is fast when the codebase is easy to change. AI execution is safe
when the whole project surface is easy to change. In a project with weak
structure, unclear domain language, and slow feedback, AI often accelerates
entropy: local patches accumulate, design intent disappears, and each new
change becomes harder to trust.

Solon's 10x value is the operating loop that prevents that decay.

```text
Fuzzy idea
-> shared design concept
-> domain language
-> acceptance criteria
-> test contract
-> small work unit
-> independent review
-> retro / next action
```

## Brainstorm As Thinking Training

In the AI coding era, one sentence can move a project forward. That is powerful,
but it also creates a risk: users can stop exercising product judgment. Solon
uses brainstorm depth to keep that judgment active.

| Mode | Value |
|---|---|
| `--simple` | Fast cleanup when the direction is already clear |
| default `normal` | A thinking scaffold that asks focused questions before plan |
| `--hard` | Product-owner hard training for intent, tradeoffs, validation, boundaries, and language |

`--hard` is not less AI assistance. It is AI assistance that uses questions to
strengthen user ownership before execution starts.

## Why AI Execution Fails

Solon treats these as product problems, not prompt problems.

1. **No shared design concept**
   - The user has a picture in their head, but the AI builds a different one.
   - More prompt detail does not always fix it because the hidden model is still unshared.

2. **No domain language**
   - The user, domain expert, developer, and AI use the same words differently.
   - The result is verbose explanation, wrong abstraction, and artifacts that do not match the real work.

3. **No tight feedback loop**
   - The AI changes too much before anything is tested or reviewed.
   - Bugs appear late, and the rework is broad instead of local.

4. **No codebase regularity**
   - Patterns differ from file to file.
   - Both humans and AI must keep too much structure in their heads, so context breaks.

## Non-Developer 10x Loop

For a founder, planner, operator, or domain expert, Solon turns "I know what I
want but cannot specify it like an engineer" into a verifiable work contract.

| Step | Solon output | Value |
|---|---|---|
| Idea capture | `brainstorm.md` raw log | The original thought is not lost |
| Design concept | problem / options / scope seed | The AI and user share the same picture |
| Domain language | glossary, actors, objects, states, rules | Words stop drifting |
| Acceptance criteria | measurable pass/fail conditions | "Done" becomes testable |
| Work units | small implementation slices | Execution becomes manageable |
| Review signal | verdict + required actions | The user sees what still matters |

The non-developer does not need to learn software architecture first. Solon
extracts the minimum structure needed for an AI and a developer to build the
right thing.

## Execution 10x Loop

For execution work, Solon assumes domain language and tight feedback are
defaults. For code slices, that means DDD-lite and TDD-lite. For non-code
slices, it means named terms, artifact boundaries, and the smallest useful
review/check.

They are not ceremony. They are AI safety rails.

| Practice | Solon meaning | Why it matters for AI |
|---|---|---|
| System analysis | ask what patterns already exist before editing | AI should follow the system, not invent a new one |
| Domain language | name terms, entities, states, labels, and invariants | AI uses the user's real language across artifacts |
| Feedback contract | define behavior, review, or smoke evidence before implementation | AI must work in smaller feedback loops |
| Small slice | implement one bounded change | Local failure stays local |
| Review gate | independent CPO verdict and CTO actions | The generator does not self-approve |

Good implementation artifacts remain easy to change. Good AI execution
preserves that property.

## Parallel Agent 10x Loop

Using multiple agents is not valuable because "more agents means more output."
In Solon, parallelism creates 10x value only when the work is split into
commit-sized lanes that can be described clearly, verified locally, and reviewed
by a different agent.

Single Agent is the default. Use `--agent-mode parallel` only when the plan
already splits into independent lanes, each lane has disjoint files_scope, and
each lane can name its one-sentence commit message. If that sentence is unclear,
the work is not ready to split.

That commit message should be written in the user's native or workspace
language. English is the default only when English is the user/repo language;
for a Korean user, Korean commit messages are the friendly default.

```text
fixed plan
-> commit-unit lanes
-> disjoint files_scope
-> lane verification
-> agent cross review
-> Gate 6 review
```

With that structure, Codex, Claude, and Gemini can increase both speed and
quality control. Without it, parallelism mostly creates collisions and duplicate
review work.

## Design System 10x Loop

In the AI coding era, code generation is no longer the moat. The user's first
impression comes from the visible surface: rhythm, spacing, typography, icon
style, and consistency. The design division's 10x value is not drawing more
pixels. It is building the system that AI must follow and reviewing when AI
regresses toward generic average output.

For visible UI work, Solon treats `design.md` or `docs/solon/design.md` as the
design contract. It should define colors, fonts, type scale, spacing, radius,
shadow, component variants, icon style, forbidden values, and rationale. During
implementation, AI reads that contract first. During review, the evaluator looks
for token drift outside that contract.

| Design practice | Solon meaning | Why it matters for AI |
|---|---|---|
| `design.md` | AI-readable design-system contract | Screens stop reinventing colors, spacing, and radius |
| Token drift check | Inspect arbitrary hex values, font sizes, spacing, and icon styles | AI-slop signals become review findings |
| Korean typography | Check Korean-capable fonts, line-height, and long-label fit | Korean UI is not squeezed into English defaults |
| Coherent icon family | Use one icon system or the existing product icon system | The surface keeps one visual voice |
| Screenshot evidence | Verify desktop/mobile fit visually | Review judges user experience, not plausibility |

Wanted Montage-style components, a coherent icon family such as Coolicons, and
a Korean-capable font such as Pretendard can be useful starter references for
Korean products. The point is not vendor lock-in. The point is that the design
system is the asset. If an existing product design system exists, it wins. If
not, start with a small `design.md` seed.

## Solon Execution Contract

When Solon is used to implement work, the default sequence should be:

1. Analyze the existing project surface and name the dominant rules.
2. Extract or update the domain language.
3. Write acceptance criteria and feedback candidates before implementation.
4. Choose the smallest implementation slice that can prove progress.
5. Run tests, review, smoke, or equivalent feedback before expanding scope.
6. Review against domain intent, project regularity, and user-visible behavior.
7. Record the decision, rework, or next action.

This is the difference between "spec to code" and "intent to durable software".

## What Solon Does Not Promise

- It does not make bad codebases magically cheap.
- It does not remove the need for human product judgment.
- It does not treat AI output as correct because it compiles.
- It does not make TDD/DDD heavy by default.

Solon keeps the loop small enough to run, but structured enough to protect the
codebase.

## Product Promise

Solon helps non-developers turn fuzzy intent into verifiable work, and helps
developers use AI without destroying the design surface of the codebase.

The result is not just faster output. It is safer iteration.
