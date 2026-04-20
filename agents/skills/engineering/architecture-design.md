# Architecture Design Skill

> 기술개발본부 -- Architecture design framework

| Role | Access |
|------|--------|
| CTO | W |
| 기술개발본부장 | R |
| 제품품질본부장 | R |

---

## 1. DESIGN.md Authoring Framework

DESIGN.md consists of 5 sections. Follow the order strictly.

### Section 1: Architecture Decision

- One-line summary of chosen approach
- Why this approach (2-3 lines of rationale)
- Alternatives comparison table:

| Approach | Pros | Cons | Selected |
|----------|------|------|----------|

### Section 2: Implementation Plan

- Numbered steps (1, 2, 3...)
- Per step: target file, change description, dependencies
- Explicitly state ordering dependencies (parallelizable or not)

### Section 3: File Changes

| File | Change Type | Description |
|------|-------------|-------------|

- Change Type: `CREATE` / `MODIFY` / `DELETE`
- Paths are relative to project root

### Section 4: AC Coverage

| AC | Solution | Verification |
|----|----------|--------------|

- Every AC must be mapped without exception
- Verification = "how to confirm" (test, log, manual check)

### Section 5: Risk & Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|

- Impact: High / Medium / Low
- Identify at least 1 risk

---

## 2. Spring <-> Python Separation Principle

```
Spring (Kotlin)          Python (FastAPI)
  Crawling                 All AI calls
  File storage/mgmt        Gemini API communication
  API Gateway              rembg background removal (누끼)
  Static resource serving  Image generation/composition
                           Prompt builder
```

**Violation checklist:**
- [ ] Does Spring code call Gemini/OpenAI directly? --> Violation
- [ ] Does Python save files to local disk? --> Violation (base64 return only)
- [ ] Does Python contain crawling logic? --> Violation

---

## 3. Change Impact Analysis

Perform 3-hop analysis for every changed file:

```
Changed file --> Files that import/call this file --> Affected API endpoints
```

Example:
```
services/product_analyzer.py
  --> routers/generate_all.py
    --> POST /api/v1/generate-all
  --> (Spring) ImageServiceClient.kt
    --> POST /api/generate-from-url
```

---

## 4. Architecture Decision Record (ADR) Pattern

Short decisions go in DESIGN.md Section 1. Major decisions get a separate ADR file.

```
## Context
Current situation, problem to solve

## Decision
Chosen decision and rationale

## Consequences
Positive outcomes / Negative outcomes / Trade-offs
```

---

## 5. Design Constraints (Hard Constraints)

| Constraint | Detail |
|------------|--------|
| AI engine | Gemini only (GPT disabled, code retained) |
| API key | Environment variables only (GOOGLE_API_KEY). Hardcoding strictly prohibited |
| Product image | Product itself must never be altered. Only background/model can change |
| Color variants | Based on actual per-color reference images only. Forcing color via prompt = tampering |
| Config format | Spring = application.yml (not properties) |
| Controller | suspend fun (Kotlin Coroutines) |
