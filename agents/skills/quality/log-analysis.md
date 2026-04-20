# Log Analysis Skill

> 제품품질본부 -- Generation feedback log analysis methodology

| Role | Access |
|------|--------|
| Prompt Analyst | W |
| 제품품질본부장 | R |
| CPO | R |
| Data Collector | R |

---

## 1. Data Source

Generation feedback logs at: `image-service/logs/generation-feedback/YYYY-MM-DD.jsonl`

### Schema

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | ISO 8601 | Generation time |
| `request_id` | string | Request tracking ID |
| `product_title` | string | Product name |
| `product_category` | string | AI-classified category |
| `complexity_score` | int (0-5) | Product complexity |
| `scene_id` | string | Scene identifier (scene-1 to scene-4) |
| `scene_type` | string | "person" or "product_only" |
| `prompt_hash` | string | SHA256[:12] of the prompt text |
| `prompt_length` | int | Character count of prompt |
| `reference_image_count` | int | Number of reference images sent |
| `temperature` | float | Generation temperature used |
| `num_candidates` | int | Candidates generated |
| `verify_scores` | array | [{shape, color, detail, total, passed}] |
| `retry_used` | bool | Whether retry was triggered |
| `final_passed` | bool | Whether the scene was ultimately accepted |
| `generation_time_ms` | int | Total time for scene generation |
| `skipped` | bool | Whether scene was skipped (all failed) |

---

## 2. Analysis Framework

### Level 1: Basic Metrics (run weekly)

```bash
# Count total records
wc -l image-service/logs/generation-feedback/*.jsonl

# Pass rate
grep '"final_passed": true' *.jsonl | wc -l
grep '"final_passed": false' *.jsonl | wc -l
```

Compute:
- Overall pass rate
- Pass rate by scene_type (person vs product_only)
- Skip rate (skipped = true)
- Retry rate (retry_used = true)
- Average generation time

### Level 2: Failure Pattern Analysis (run weekly or after quality complaints)

Group failures by:
1. **product_category** — which product types fail most?
2. **complexity_score** — which complexity levels fail most?
3. **scene_type** — person scenes vs product-only scenes
4. **Weakest axis** — is shape, color, or detail consistently lowest?

Detection rules:
- Category with pass rate < 50% → flag as "high-risk category"
- Complexity 4-5 with skip rate > 30% → flag as "needs prompt improvement"
- shape < 6 average → structural generation issue
- color < 6 average → color accuracy issue
- detail < 6 average → detail preservation issue

### Level 3: Prompt Effectiveness (run after prompt changes)

Compare prompt versions using `prompt_hash`:
- Group scores by prompt_hash
- Before/after comparison of pass rates
- Temperature vs pass rate correlation
- Reference image count vs pass rate correlation

### Level 4: Cost Efficiency (run monthly)

Calculate:
- Average candidates per successful image
- Wasted candidates (generated but not used)
- API cost per successful image
- Cost impact of retry mechanism

---

## 3. Report Template

Write to: `image-service/logs/generation-feedback/analysis/YYYY-MM-DD-analysis.md`

```markdown
# Generation Feedback Analysis — {date range}

## 1. Summary
| Metric | Value |
|--------|-------|
| Total requests | {n} |
| Total scenes | {n} |
| Overall pass rate | {n}% |
| Product-only pass rate | {n}% |
| Person scene pass rate | {n}% |
| Average verify score | {n}/30 |
| Skip rate | {n}% |
| Retry rate | {n}% |
| Avg generation time | {n}ms |

## 2. Failure Patterns

### By Category (top 5 failures)
| Category | Scenes | Pass Rate | Avg Shape | Avg Color | Avg Detail |
|----------|:------:|:---------:|:---------:|:---------:|:----------:|

### By Complexity
| Score | Scenes | Pass Rate | Skip Rate | Retry Rate |
|:-----:|:------:|:---------:|:---------:|:----------:|

### Weakest Axis
{Analysis of which axis fails most and why}

## 3. Prompt Version Comparison
| Prompt Hash | Usage Count | Avg Score | Pass Rate |
|-------------|:----------:|:---------:|:---------:|

## 4. Recommendations
1. {Data-backed prompt improvement suggestion}
2. {Temperature/threshold adjustment suggestion}
3. {Category-specific strategy suggestion}

## 5. Action Items
- For CTO: {specific code changes with file paths}
- For CPO: {quality threshold adjustments}
- For CEO: {product category risk alerts}
```

---

## 4. Scheduling Guidelines

| Trigger | Analysis Level | Purpose |
|---------|:--------------:|---------|
| Weekly (Monday) | Level 1 + 2 | Routine health check |
| After prompt changes | Level 3 | Before/after comparison |
| Quality complaint | Level 2 + 3 | Root cause investigation |
| Monthly | Level 4 | Cost optimization review |

---

## 5. Alerting Thresholds

| Metric | Warning | Critical |
|--------|:-------:|:--------:|
| Overall pass rate | < 70% | < 50% |
| Product-only pass rate | < 60% | < 40% |
| Skip rate | > 20% | > 40% |
| Avg generation time | > 40s | > 60s |
| Category pass rate | < 50% | < 30% |

When Critical threshold is hit → escalate to 제품품질 본부장 immediately.
