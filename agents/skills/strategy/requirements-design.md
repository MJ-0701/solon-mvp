# Requirements Design -- AC Design Skill

## AC (Acceptance Criteria) Writing: 3 Principles

| Principle | Description | Good Example | Bad Example |
|-----------|-------------|--------------|-------------|
| Observable | Result the user can directly see | "Generated image contains the product" | "Image is stored in internal buffer" |
| Measurable | Pass/Fail determination possible | "13+ of 15 images match the product" | "Image quality is good" |
| Tech-agnostic | What (outcome), not How (method) | "Product image with background removed" | "Background removed using rembg" |

---

## User Story Template

```
As a {reseller},
I want to {specific action},
so that {business value}.
```

Example:
- "As a reseller, I want lifestyle images (15) auto-generated from just a wholesale URL, so that I can list on Smartstore immediately without Photoshop."

---

## Root Cause Analysis Guide

```
1. Define the current problem
   → "Product is distorted in lifestyle images"

2. Identify 3+ root causes
   → Cause A: Product features not reflected in prompt
   → Cause B: Reference image resolution too low
   → Cause C: No post-generation verification

3. Map each cause to an AC
   → Cause A → AC: "Prompt includes product name/color/shape"
   → Cause B → AC: "Reference image minimum 512px"
   → Cause C → AC: "Generated vs reference similarity >= 0.85"
```

---

## Out of Scope Criteria

| Criteria | Include | Exclude |
|----------|---------|---------|
| Decision basis | Business priority | Technical difficulty |
| Inclusion condition | Directly impacts seller value | "Can be done later" |
| Exclusion reason | "Not aligned with this sprint goal" | "Too difficult" (X) |

> Out of Scope means "chose not to do," not "unable to do." Decisions are based on business priority, not technical constraints.

---

## Seller-Perspective Value Checklist

- [ ] Can the seller list directly on Smartstore?
- [ ] Does it save time compared to manual work?
- [ ] Do generated images match the actual product? (legal risk)
- [ ] Does the detail page help drive purchase conversion?

---

## Quality Criteria Defaults

| Metric | Threshold | Description |
|--------|-----------|-------------|
| Match Rate | >= 90% | AC fulfillment rate |
| Critical Code Issues | 0 | Security/crash/data loss |
| Build Errors | 0 | Compile + lint pass |
