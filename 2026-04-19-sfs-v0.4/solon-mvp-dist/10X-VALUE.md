# Solon 10x Value

> Solon does not make code cheap by generating more of it.
> Solon makes AI work safer by turning unclear intent into shared concepts,
> domain language, testable contracts, small work units, and review signals.

AI coding is fast when the codebase is easy to change. In a codebase with weak
structure, unclear domain language, and slow feedback, AI often accelerates
software entropy: local patches accumulate, design intent disappears, and each
new change becomes harder to trust.

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

## Why AI Coding Fails

Solon treats these as product problems, not prompt problems.

1. **No shared design concept**
   - The user has a picture in their head, but the AI builds a different one.
   - More prompt detail does not always fix it because the hidden model is still unshared.

2. **No domain language**
   - The user, domain expert, developer, and AI use the same words differently.
   - The result is verbose explanation, wrong abstraction, and code that does not match the real work.

3. **No tight feedback loop**
   - The AI writes too much code before anything is tested.
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

## Developer 10x Loop

For coding work, Solon assumes DDD and TDD are defaults.

They are not ceremony. They are AI safety rails.

| Practice | Solon meaning | Why it matters for AI |
|---|---|---|
| Codebase analysis | ask what patterns already exist before editing | AI should follow the system, not invent a new one |
| DDD-lite | name domain terms, entities, states, and invariants | AI uses the user's real language in code |
| TDD contract | define behavior before implementation | AI must work in smaller feedback loops |
| Small slice | implement one bounded change | Local failure stays local |
| Review gate | independent CPO verdict and CTO actions | The generator does not self-approve |

Good code is code that remains easy to change. Good AI coding is coding that
preserves that property.

## Solon Coding Contract

When Solon is used to build code, the default implementation sequence should be:

1. Analyze the existing codebase and name the dominant rules.
2. Extract or update the domain language.
3. Write acceptance criteria and test candidates before implementation.
4. Choose the smallest implementation slice that can prove progress.
5. Run tests or equivalent feedback before expanding scope.
6. Review against domain intent, codebase regularity, and user-visible behavior.
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
