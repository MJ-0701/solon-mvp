# Market Research -- Competitor Analysis Skill

## Competitor Analysis Framework

Collect the following fields per competitor and build a comparison table:

| Field | Description |
|-------|-------------|
| Service name | Official name + URL |
| Features | Core features in bullet points |
| Pricing | Free/paid plans, per-item cost |
| Image quality | AI-generated vs template vs manual, based on samples |
| Supported sites | List of wholesale sites with crawling support |
| Differentiators | Strengths/weaknesses vs our service |

Comparison table example:
```
| Item | Our Service | Competitor A | Competitor B |
|------|-------------|--------------|--------------|
| AI image generation | O (Gemini) | O (DALL-E) | X (template) |
| Auto crawling | O | X (manual input) | O |
| Auto detail page | O | X | O |
| Per-item cost | TBD | $0.5 | $1.0 |
```

---

## Market Size Estimation Fields

| Metric | Source Hint |
|--------|------------|
| Number of resellers | Smartstore/Coupang registered seller stats |
| Monthly product listings | Estimated from wholesale site (e.g., Domeggook/1688) volume |
| AI image generation market growth | Gartner/CB Insights reports |
| Monthly image production cost per seller | Based on design outsourcing rates |

---

## Reseller Pain Points

| Pain Point | Impact | Our Solution |
|------------|--------|-------------|
| Manual image editing time | 30min-1hr per product | URL input -> auto-generation (2-3 min) |
| Detail page design cost | $4-15 per item | Auto-composition (free/low-cost) |
| Repetitive labor for bulk listings | Limited to 5-10/day | Batch processing enables dozens |
| Image copyright issues | Risk of unauthorized use of wholesale images | AI generation produces original images |

---

## Data Collection Report Template

Used by Researcher/Data Collector agents when reporting results:

```markdown
## Research: {topic}

**Collection date**: {YYYY-MM-DD}
**Collector**: {agent name}

### Sources
- {URL 1}
- {URL 2}

### Key Findings
- {Finding 1}
- {Finding 2}
- {Finding 3}

### Data
{comparison table or metrics}

### Requires Interpretation
> The following items require director-level judgment:
> - {Decision request 1}
> - {Decision request 2}
```

> Researchers collect and organize data only. Strategic judgment and interpretation belong to directors/C-Level.
