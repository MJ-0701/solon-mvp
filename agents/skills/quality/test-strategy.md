# Test Strategy -- Testing Framework

> **Owner**: 제품품질본부장(W) | **Reader**: CPO(R), QA Engineer(R), Data Collector(R)
>
> Provides AC-based test design, image project-specific edge case identification, and E2E verification checklists.

---

## 1. AC-Based Test Scenario Design

3-step procedure to convert each AC (Acceptance Criteria) into independent test cases.

### Step 1: AC -> Test Case Conversion

| Field | Description |
|---|---|
| TC ID | `TC-{sprint}-{ac-number}` |
| AC Reference | Original AC statement |
| Pass Condition | Condition that constitutes a pass |
| Fail Condition | Condition that constitutes a fail (specific failure case) |
| Verification Method | Manual / Automated / Log / Screenshot |
| Priority | P0 (required) / P1 (important) / P2 (optional) |

### Step 2: Verification Method Assignment

| Method | When to Use | Tool |
|---|---|---|
| Automated test | API responses, data transforms, business logic | JUnit, pytest |
| Log verification | Internal processing flow, error handling | Server log grep |
| Screenshot | UI layout, image output | Browser capture |
| Manual verification | Image quality, color accuracy, naturalness | Visual comparison |

### Step 3: Test Scenario Template

```markdown
## TC-{sprint}-{n}: {test title}

**AC**: {original AC statement}
**Priority**: P0

### Pass Condition
- {specific pass criteria}

### Fail Condition
- {specific failure criteria}

### Steps
1. {execution step}
2. {verification step}

### Verification
- Method: {manual/automated/log/screenshot}
- Evidence: {evidence collection method}

### Result
- [ ] Pass / Fail
- Notes: {remarks}
```

---

## 2. Edge Case Identification Guide (Image Project-Specific)

Edge cases by product type that frequently cause issues in image generation services.

### 2.1 Body-Contact Products

| Product Type | Risk | Test Focus |
|---|---|---|
| Foot bath | Foot images included in background-removed (누끼) output | Verify body parts removed from COMPOSITE source |
| Massager | Hand/arm image contamination | product_solo vs product_with_person classification accuracy |
| Nail art supplies | Fingernails/fingers included | Verify hands not in background-removed output |
| Hair products | Hair/face included | Verify product can be isolated |

### 2.2 High-Difficulty Color/Material Products

| Product Type | Risk | Test Focus |
|---|---|---|
| Transparent products (glass cups, clear cases) | Product removed along with background | Verify rembg output quality |
| Solid-color products | Unclear boundary between background and product | Verify background removal (누끼) quality |
| Skin-tone similar (beige/peach plastic) | Misidentified as skin, classified as person | Image classification accuracy |

### 2.3 High-Difficulty Structure/Form Products

| Product Type | Risk | Test Focus |
|---|---|---|
| Multi-color variants (pink/green/blue) | Need per-color reference images | Verify accuracy per color individually |
| Foldable/articulated | Product shape changes | Generated image matches original form |
| Machine parts (complex 3D) | Detail structure distortion | Shape preservation accuracy |
| Set products (multi-piece) | Components missing or extra added | Verify all components included |

### 2.4 Data Scarcity Scenarios

| Situation | Risk | Test Focus |
|---|---|---|
| No product-only image available | Cannot extract background-removed (누끼) image | Error handling + fallback strategy |
| Only low-resolution images exist | Generation quality degradation | Minimum resolution threshold verification |
| Insufficient product description | Analysis accuracy drop | Analysis result confidence check |

---

## 3. E2E Verification Checklist

Sequentially verify the entire pipeline from URL input to final output.

### 3.1 Basic Flow

```
[ ] Server startup confirmed (Spring Boot + Python FastAPI)
[ ] URL input -> crawling success (200 response)
[ ] Product analysis result accuracy (product name, category, features)
[ ] Image classification accuracy (product_solo vs product_with_person vs etc)
[ ] Background-removed (누끼) output does not contain humans
[ ] Background-removed output preserves product shape/color
[ ] Lifestyle image color matches reference
[ ] Lifestyle image shape matches reference
[ ] Detail page layout correct (860px width, section order)
[ ] Total time within target (goal: 150s)
[ ] Appropriate error message on failure response
```

### 3.2 Full Image Quality Inspection

For each of the 15 generated lifestyle images:

```
[ ] Product color matches original
[ ] Product shape/proportion matches original
[ ] Product orientation is correct
[ ] Background composited naturally
[ ] No AI artifacts (boundary blurring, unusual patterns)
[ ] Resolution sufficient (minimum 512px)
```

### 3.3 Detail Page Verification

```
[ ] 860px width compliance
[ ] Korean font renders correctly
[ ] Section order matches design
[ ] No image-text overlap
[ ] Full page loads successfully
```

---

## 4. Performance Benchmark

Record performance changes in before/after comparison format.

### Benchmark Template

| Metric | Before | After | Change | Target |
|---|---|---|---|---|
| Total time | {n}s | {n}s | {+/-n}s | <= 150s |
| Image generation time | {n}s | {n}s | {+/-n}s | <= 90s |
| Crawling time | {n}s | {n}s | {+/-n}s | <= 10s |
| Background removal (누끼) time | {n}s | {n}s | {+/-n}s | <= 15s |
| Detail page composition | {n}s | {n}s | {+/-n}s | <= 20s |
| Images generated | {n}/15 | {n}/15 | {+/-n} | 15/15 |
| Generation success rate | {n}% | {n}% | {+/-n}% | >= 95% |
| HARD FAIL count | {n} | {n} | {+/-n} | 0 |

### Measurement Conditions

- Same product URL, 3 repeated runs, use median
- Record network conditions (local/remote)
- Record Gemini API response time separately (external dependency)

---

## 5. Test Data

Cover diverse product types with a minimum of 3 URLs.

| Category | Product | URL Source | Test Focus |
|---|---|---|---|
| Body-contact | Foot bath | Domeggook | Human contamination prevention, background removal quality |
| Body-contact | Massager | Domeggook | Image classification, shape preservation |
| General item | Household goods | Domeggook | Basic pipeline, performance baseline |

### Test Data Selection Criteria

- Minimum 2 body-contact products (edge case coverage)
- Minimum 1 multi-color product (color accuracy verification)
- Minimum 1 simple-shape product (baseline performance)
- Use actual Domeggook URLs (includes crawling compatibility verification)

---

## 6. Test Execution Checklist

```
[ ] Verify test data URL validity
[ ] Confirm server environment (Docker Compose or local)
[ ] Confirm GOOGLE_API_KEY environment variable is set
[ ] Execute E2E basic flow
[ ] Full image quality inspection (15 images * number of test URLs)
[ ] Detail page verification
[ ] Performance benchmark measurement (3 repeated runs)
[ ] Edge case product testing
[ ] Write results report
[ ] Apply evaluation-criteria on HARD FAIL discovery
```
