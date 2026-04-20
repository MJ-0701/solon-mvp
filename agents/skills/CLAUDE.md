# Work Skills — AI Context

## How to Use
1. Read `SKILL_MAP.md` first to find your agent's skill assignments.
2. Load skills marked **W** (work) for your role — you produce outputs using these frameworks.
3. Skills marked **R** (reference) are context-only — do not produce outputs from them.
4. Skills marked **-** should not be loaded.

## Important Distinction
- **Work Skills** (this directory): How to perform tasks (sprint workflow, code review, etc.)
- **Domain Skills** (project root `skills/`): What the code does (crawling, background removal, etc.)

Both may be needed. Check `skills/SKILL_INDEX.md` at project root before touching specific code.

## Folder Layout
| Folder | Skills | Primary Users |
|--------|--------|---------------|
| `common/` | sprint-workflow | All C-Level and Leads |
| `strategy/` | requirements-design, market-research | CEO, Strategy Lead, Researcher |
| `engineering/` | architecture-design, code-review, implementation | CTO, Dev Lead, Developer |
| `quality/` | evaluation-criteria, gap-analysis, test-strategy | CPO, QA Lead, QA Engineer |
