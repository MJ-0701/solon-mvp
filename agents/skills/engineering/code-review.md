# Code Review Skill

> 기술개발본부 -- Code review and pre-handoff self-check

| Role | Access |
|------|--------|
| CTO | W |
| 기술개발본부장 | W |
| Developer | R |
| 제품품질본부장 | R |
| QA Engineer | R |

---

## 1. Pre-Handoff Self-Check

Check 5 categories in order before handoff. Any failure blocks the handoff.

### Category 1: Build & Syntax

- [ ] Python: `py_compile` or `python -m compileall` -- no errors
- [ ] Kotlin: `compileKotlin` task succeeds
- [ ] No import errors (no references to nonexistent modules)
- [ ] No syntax errors (indentation, brackets, semicolons)

### Category 2: Security

- [ ] No hardcoded API keys
  ```bash
  grep -rn "API_KEY\|password\|token\|secret" --include="*.py" --include="*.kt" \
    | grep -v "os.environ\|getenv\|settings\.\|application.yml\|\.env"
  ```
- [ ] Only environment variables used (via settings.py / application.yml)
- [ ] No SQL injection vectors (parameter binding for raw queries)
- [ ] .env file is in .gitignore

### Category 3: Code Quality & OOP Structure

- [ ] Function length <= 50 lines (split if exceeded — **HARD LIMIT**)
- [ ] No duplicate code blocks >= 10 lines (extract to shared function/class)
- [ ] Same logic in 2+ places → must be extracted to shared utility
- [ ] Related functions with shared state → grouped into a class
- [ ] No nested if/for > 3 levels deep (extract inner block)
- [ ] No functions with 5+ parameters (use dataclass/context object)
- [ ] Naming consistency:
  - Python: `snake_case` (functions, variables, files)
  - Kotlin: `camelCase` (functions, variables), `PascalCase` (classes)
- [ ] No magic strings (use constants or enums)
- [ ] No unnecessary comments (when code is self-explanatory)

### Category 4: Architecture Compliance

- [ ] No direct AI API calls from Spring
- [ ] No file system writes from Python (base64 return only)
- [ ] Layer separation: Router/Controller --> Service --> External dependency
- [ ] New dependencies reflected in requirements.txt / build.gradle.kts

### Category 5: Design Fidelity

- [ ] All File Changes from DESIGN.md are implemented
- [ ] No files changed beyond what DESIGN.md specifies
- [ ] Implementation exists for each AC
- [ ] Implementation matches design intent (no over-engineering)

---

## 2. Issue Severity

| Level | Label | Criteria | Action |
|-------|-------|----------|--------|
| Critical | CRIT | Security vulnerability, build failure, data loss risk | Must fix immediately |
| Warning | WARN | Quality degradation, missing edge cases, naming inconsistency | Recommended fix (before handoff) |
| Info | INFO | Style, minor improvements, preference differences | Optional fix |

---

## 3. Review Priority

```
Security  >  Architecture  >  Quality  >  Style
(1st)        (2nd)            (3rd)       (4th)
```

If a Security issue is found, stop all other review and resolve Security first.

---

## 4. Review Comment Format

```
[SEVERITY] file:line -- description
  Current: (problematic code)
  Suggested: (fixed code)
  Reason: (why this change is needed)
```

Example:
```
[CRIT] services/product_analyzer.py:42 -- Hardcoded API key
  Current: api_key = "AIza..."
  Suggested: api_key = settings.google_api_key
  Reason: Key exposure leads to billing abuse + security incident
```
