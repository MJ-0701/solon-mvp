# Gap Analysis -- Design vs Implementation Comparison

> **Owner**: 제품품질본부장(W), QA Engineer(W) | **Reader**: CPO(R), Data Collector(R)
>
> Quantitatively measures alignment between DESIGN.md specification and actual implementation, systematically classifying missing/changed/added items.

---

## 1. Analysis Methodology

### Step 1: File Change Verification

Verify that all files listed in DESIGN.md's `File Changes` table were actually changed.

```bash
# DESIGN.md file list vs actual git diff
git diff --name-only {base-branch}...HEAD
```

| Check | Method |
|---|---|
| Listed files actually changed | Cross-reference git diff file list |
| Each file's changes match specification | Compare diff content vs DESIGN.md spec |
| Implementation exists for each AC | Trace implementation code per AC item |
| Unlisted additional changes | Files in git diff but not in DESIGN.md |

### Step 2: AC Mapping

Map each AC (Acceptance Criteria) to implementation code location and approach.

```
AC-1: "Return product name on successful crawl"
  -> CrawlService.kt:45 - parseProductName()
  -> Test: CrawlServiceTest.kt:20
  -> Status: Match
```

### Step 3: Item Classification

| Category | Symbol | Meaning | Example |
|---|---|---|---|
| Missing | 🔴 | In design but not implemented | Error handling specified in AC is missing |
| Changed | 🟡 | Implemented differently from design | Return type changed, parameter added |
| Added | 🔵 | Not in design but was added | Extra utility functions, config files |

---

## 2. Match Rate Calculation

```
Match Rate = Match Items / Total Items * 100
```

- **Total Items** = DESIGN.md File Changes count + AC count
- **Match Items** = Items fully matching design
- **Changed items**: 0.5 points (partial match)
- **Missing/Added items**: 0 points

### Example

```
Total: 20 items (12 files + 8 ACs)
Match: 16
Changed: 2 (= 1.0 points)
Missing: 1
Added: 1

Match Rate = (16 + 1.0) / 20 * 100 = 85%
```

---

## 3. Issue Severity Classification

| Severity | Criteria | Action |
|---|---|---|
| **Critical** | Security vulnerability, build failure, data loss risk | Fix immediately, block deployment |
| **Warning** | Quality issue, missing edge case, naming inconsistency | Fix within current sprint |
| **Info** | Style, minor improvement, documentation typo | Add to backlog |

### Image Project-Specific Critical Criteria

- API key hardcoded or exposed
- Logic that could distort image color/shape
- Path allowing human image contamination in COMPOSITE source
- Missing rembg output verification logic
- Prompt containing forced color change instruction

---

## 4. Gap Analysis Report Template

```markdown
## Gap Analysis: {sprint-id}

### Summary
- **Match Rate**: {n}%
- **Missing**: {n} / **Changed**: {n} / **Added**: {n}
- **Critical Issues**: {n}
- **Overall Verdict**: Pass / Fail(fixable) / Fail(major)

### File Changes Verification
| File | Design Action | Actual | Status |
|---|---|---|---|
| {path} | {new/modify/delete} | {match/missing/changed} | {symbol} |

### AC Verification
| AC ID | Description | Implementation | Status |
|---|---|---|---|
| AC-{n} | {description} | {file:line or missing} | {symbol} |

### 🔴 Missing
| Item | Design Location | Description | Severity |
|---|---|---|---|
| {item} | DESIGN.md #{section} | {what is missing} | {Critical/Warning/Info} |

### 🟡 Changed
| Item | Design | Actual | Impact | Severity |
|---|---|---|---|---|
| {item} | {designed behavior} | {actual behavior} | {impact description} | {severity} |

### 🔵 Added
| Item | Location | Description | Risk |
|---|---|---|---|
| {item} | {file:line} | {what was added} | {Low/Medium/High} |

### Recommendations
1. {actionable recommendation}
2. {actionable recommendation}
```

---

## 5. Analysis Execution Checklist

```
[ ] Confirm latest version of DESIGN.md
[ ] Extract git diff file list
[ ] Cross-reference all File Changes table entries
[ ] Map implementation code per AC item
[ ] Identify Missing items + classify severity
[ ] Identify Changed items + analyze impact
[ ] Identify Added items + assess risk
[ ] Calculate Match Rate
[ ] Check image project-specific Critical criteria
[ ] Write report
[ ] (On Critical finding) Escalate immediately
```

---

## 6. Recurring Pattern Tracking

Request Root Cause Analysis (RCA) when the same type of gap occurs 2+ times.

| Pattern | Trigger | Action |
|---|---|---|
| Same file repeatedly missing | Same file Missing in 2+ sprints | Review design process |
| AC interpretation mismatch | Changed items are 30%+ of total | Redefine AC writing standards |
| Excessive Added items | Added items are 25%+ of total | Adjust design scope |
