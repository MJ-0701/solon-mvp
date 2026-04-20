# Agent Team — AI Context

## Structure
12 agents across 3 divisions + Chief of Staff. See `README.md` for full org chart.

## Communication Rules
| Scope | Who | Model |
|-------|-----|-------|
| Design (PLAN/DESIGN.md) | C-Level only | Opus |
| Design Review | Lead+ | Opus/Sonnet |
| Cross-division | C-Level only | Opus |
| Implementation | Engineers | Sonnet |
| Research/data collection | Researchers | Haiku |

## Agent Loading
- Each agent file (`planner.md`, `generator.md`, etc.) is self-contained.
- Load the agent file matching your assigned role before starting work.
- Work Skills are in `skills/` — check `skills/SKILL_MAP.md` for which skills to load (W=work, R=reference).
- Domain Skills are in project root `skills/SKILL_INDEX.md` — load before touching specific code files.

## Sprint Flow (PDCA)
Plan (CEO) -> Design (CTO) -> Do (Dev team) -> Check (QA team) -> Act (rework or complete)
Score >= 90 = pass. Max 3 rework iterations.
