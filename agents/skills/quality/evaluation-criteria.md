# Evaluation Criteria -- Quality Assessment Framework

> **Owner**: CPO(W), 제품품질본부장(W) | **Reader**: QA Engineer(R)
>
> Quantitative quality assessment criteria for sprint deliverables. Since product fidelity carries legal risk in an image generation service, HARD FAIL criteria are maintained separately.

---

## 1. 5-Axis Evaluation Criteria

| Axis | Weight | Measurement | Verification Method |
|---|---|---|---|
| Functional Correctness | 30% | Individual AC verification | 1:1 AC checklist comparison |
| Product Fidelity | 25% | Image color/shape/orientation accuracy | Visual + automated comparison against reference |
| UX Quality | 20% | User flow, screenshot verification | E2E scenario execution, UI screenshots |
| Technical Quality | 15% | Console errors, exception handling, logging | Browser console + server log inspection |
| Performance | 10% | Response time, rendering speed | Before/after benchmark comparison |

### Per-Axis Scoring Guide

- **Functional Correctness**: N total ACs, M passed -> `M/N * 100` points
- **Product Fidelity**: Check HARD FAIL items first (see below). If passed, score based on reference similarity
- **UX Quality**: N key flow scenarios, M passing -> `M/N * 100` points
- **Technical Quality**: 0 console errors=100, 1-2=80, 3+=60, unhandled exceptions=40
- **Performance**: Within target=100, within 1.5x=80, within 2x=60, exceeds 2x=40

---

## 2. Image Quality HARD FAIL Criteria

Any single failure automatically zeros the Product Fidelity axis. Immediately reflected in final score.

| Criterion | Pass | Fail | Verification Method |
|---|---|---|---|
| Color accuracy | Same color tone as reference image | Color distortion (e.g., pink->beige) | Side-by-side reference comparison |
| Shape preservation | Same proportion/shape as actual product | Ratio distortion, shape deformation | Compare against original crawled image |
| Orientation | Correct position (up/down/left/right normal) | Flipped, rotated sideways | Visual inspection |
| Human contamination | COMPOSITE source contains product only | Body parts (hands, feet, face, etc.) included | Visual inspection of background-removed (누끼) output |
| Background quality | Natural composition, smooth boundaries | AI artifacts, unnatural boundaries | Zoomed inspection of generated image |

### Procedure When HARD FAIL Is Found

1. Capture the image + record the failed criterion
2. Auto-assign 0 points to Product Fidelity axis
3. Immediately create an issue for the responsible developer
4. Re-evaluate after fix (only HARD FAIL items re-verified)

---

## 3. Final Score Calculation

```
Final Score = (Design Match * 0.3) + (Code Quality * 0.2) + (5-Axis Weighted * 0.5)
```

| Component | Source | Weight |
|---|---|---|
| Design Match | Gap Analysis match rate (%) | 0.3 |
| Code Quality | Code review score (0-100) | 0.2 |
| 5-Axis Weighted | Weighted sum of 5-axis scores | 0.5 |

### 5-Axis Weighted Calculation Example

```
5-Axis = (FC * 0.30) + (PF * 0.25) + (UX * 0.20) + (TQ * 0.15) + (Perf * 0.10)
       = (90 * 0.30) + (85 * 0.25) + (80 * 0.20) + (95 * 0.15) + (70 * 0.10)
       = 27.0 + 21.25 + 16.0 + 14.25 + 7.0
       = 85.5
```

---

## 4. Pass/Fail Judgment

| Range | Verdict | Action |
|---|---|---|
| >= 90 | **Pass** | Deployment approved |
| 70 - 89 | **Fail (fixable)** | Issue list delivered, re-evaluate after fix |
| < 70 | **Fail (major rework)** | Escalate to CEO, re-plan sprint |

### Escalation Criteria

- 2+ HARD FAILs -> Auto-escalation (regardless of score)
- Same HARD FAIL occurs 2 consecutive times -> Request Root Cause Analysis (RCA)
- Final Score < 70 -> CEO report + rework scope estimation

---

## 5. Evaluation Execution Checklist

```
[ ] Gap Analysis completed (Design Match calculated)
[ ] Code review completed (Code Quality calculated)
[ ] All 5 HARD FAIL items fully inspected
[ ] Individual 5-axis scores calculated
[ ] Final Score computed
[ ] Pass/Fail judgment made
[ ] Results report written
[ ] (On Fail) Issue list + fix deadline assigned
[ ] (On < 70) CEO escalation
```
