# Solon 10x Value

**Language**: [한국어](./docs/ko/10x-value.md) / English

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
