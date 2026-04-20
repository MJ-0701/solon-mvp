# Sprint Workflow -- PDCA Sprint Flow

## PDCA Cycle

```
Plan (CEO) → Design (CTO) → Do (CTO team) → Check (CPO team) → Act (CTO team rework)
```

| Phase | Owner | Output | Next Gate |
|-------|-------|--------|-----------|
| Plan | CEO | PLAN.md | AC measurability check |
| Design | CTO | DESIGN.md | design-validator >= 90 |
| Do | CTO team (기술개발본부장 + Developer) | HANDOFF.md + code | build 0 errors |
| Check | CPO team (제품품질본부장 + QA) | EVALUATION.md | score >= 90 |
| Act | CTO team | Fixed code | Re-evaluation pass |

---

## Document Formats

### PLAN.md (Written by CEO)
- User Story: "As a {reseller}, I want to {action}, so that {value}"
- Acceptance Criteria: Observable + measurable condition list
- Quality Criteria: match rate, code issues, build errors thresholds
- Out of Scope: What will NOT be done in this sprint

### DESIGN.md (Written by CTO)
- Architecture change summary
- File change list (create/modify/delete)
- Technical risks and mitigation plans
- AC-to-implementation mapping

### HANDOFF.md (Written by CTO)
- Implementation result summary
- Self-check checklist (build, lint, basic functionality)
- Known constraints

### EVALUATION.md (Written by CPO)
- 3-Layer evaluation: Code Quality / Functional / AC Match
- Per-item Pass/Fail + score
- Rework instructions for failing items

---

## Quality Gates

| Gate | Condition | Fail Action |
|------|-----------|-------------|
| Plan -> Design | All ACs are measurable | CEO rewrites ACs |
| Design -> Do | design-validator >= 90 | CTO revises design |
| Do -> Check | build 0 errors, lint pass | CTO team fixes immediately |
| Check -> Act/Report | evaluation score >= 90 | CTO team rework (Act) |

---

## Cross-Division Delegation Protocol

| Rule | Description |
|------|-------------|
| Communication path | Cross-division communication is C-Level only (CEO/CTO/CPO) |
| Design authority | Only C-Level can author design documents |
| Design review | Director-level (본부장) and above only |
| Implementation | Performed by Sonnet model agents |
| Research | Performed by Haiku model agents |

> Directors/staff are prohibited from directly instructing or requesting another division.
> When needed, escalate to your own division's C-Level.
