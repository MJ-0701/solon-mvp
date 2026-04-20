# Quality Division Skills — AI Context

## Purpose
Skills for the Quality Division (CPO, QA Lead, QA Engineer, Data Collector).

## Files
| File | Description | W (produce) | R (reference) |
|------|-------------|-------------|---------------|
| `evaluation-criteria.md` | 5-axis scoring + HARD FAIL rules | CPO, QA Lead | QA Engineer |
| `gap-analysis.md` | DESIGN vs implementation match rate | QA Lead, QA Engineer | CPO, Data Collector |
| `test-strategy.md` | AC-based test + edge case + E2E checklist | QA Lead | CPO, QA Engineer, Data Collector |

## Usage
- CPO defines evaluation criteria during Check phase.
- QA Lead designs test strategy and runs gap analysis against DESIGN.md.
- QA Engineer executes gap analysis and code quality checks.
- Data Collector gathers logs/metrics to support analysis.
- Score >= 90 = pass, < 90 = rework (max 3 iterations).
