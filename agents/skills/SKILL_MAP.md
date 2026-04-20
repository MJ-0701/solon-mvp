# Skill Map -- Agent x Skill Matrix

## Skill System: 2-Type Structure

| Type | Location | Purpose | Example |
|------|----------|---------|---------|
| Domain Skill | `skills/*.skill.md` | Business domain knowledge (crawling, background removal (누끼), detail page, etc.) | `crawling.skill.md` |
| Work Skill | `.claude/agents/skills/` | Work execution frameworks (sprint, requirements, research, etc.) | `sprint-workflow.md` |

- **Domain Skill**: "What is this product/feature and why does it work this way" -- reference before code work
- **Work Skill**: "What process do I follow for this task" -- reference when performing a role

---

## Agent x Work Skill Matrix

W = Performs task / R = Reference only / - = Not needed

| Skill | CEO | 전략기획본부장 | Researcher | CTO | 기술개발본부장 | Developer | Tech Researcher | CPO | 제품품질본부장 | QA Engineer | Data Collector |
|-------|-----|---------------|------------|-----|---------------|-----------|-----------------|-----|--------------|-------------|----------------|
| sprint-workflow | R | R | - | R | R | - | - | R | R | - | - |
| requirements-design | W | W | R | R | - | - | - | R | R | - | - |
| market-research | R | W | W | - | - | - | - | R | - | - | - |
| architecture-design | - | - | - | W | R | - | - | - | R | - | - |
| code-review | - | - | - | W | W | R | - | - | R | R | - |
| implementation | - | - | - | R | W | W | R | - | - | - | - |
| evaluation-criteria | - | - | - | - | - | - | - | W | W | R | - |
| gap-analysis | - | - | - | - | - | - | - | R | W | W | R |
| test-strategy | - | - | - | - | - | - | - | R | W | R | R |

## How to Read

- **W agent**: Directly applies the skill file's framework/template to produce deliverables
- **R agent**: References for context only. Not responsible for creating deliverables
- **- agent**: Skill not needed. Do not load

## Skill File Paths

```
.claude/agents/skills/
├── SKILL_MAP.md                          # This file
├── common/
│   └── sprint-workflow.md                # PDCA sprint flow
├── strategy/
│   ├── requirements-design.md            # AC/requirements design
│   └── market-research.md                # Market/competitor research
├── engineering/
│   ├── architecture-design.md            # Architecture design
│   ├── code-review.md                    # Code review
│   └── implementation.md                 # Implementation guide
└── quality/
    ├── evaluation-criteria.md            # 5-axis evaluation criteria + HARD FAIL + scoring
    ├── gap-analysis.md                   # DESIGN vs implementation comparison, Match Rate calculation
    └── test-strategy.md                  # AC-based testing + Edge Cases + E2E checklist
```
