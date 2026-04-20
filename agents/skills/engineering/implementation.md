# Implementation Skill

> 기술개발본부 -- Implementation guide and coding rules

| Role | Access |
|------|--------|
| 기술개발본부장 | W |
| Developer | W |
| CTO | R |
| Tech Researcher | R |

---

## 1. Comment & Logger Language Rules

| Context | Language | Example |
|---------|----------|---------|
| Business logic comments | Korean | `# 제품 카테고리별 프롬프트 분기` |
| Technical operation comments | English | `# Retry with exponential backoff` |
| User-facing logs | Korean | `logger.info("상품 분석 완료: %s", product_name)` |
| Internal system logs | English | `logger.debug("Cache hit for key=%s", cache_key)` |

---

## 2. Domain Skill Reference Process

Always check domain skills before modifying any file:

```
1. Open skills/SKILL_INDEX.md
2. Search for the target file
3. Read the mapped .skill.md file
4. Understand business context, then start coding
```

Domain skills contain "why it works this way," "caveats," and "prohibitions."
Coding without reading the skill carries high risk of business logic errors.

---

## 3. Error Handling Patterns

### Gemini API Calls

```python
# Use circuit breaker pattern (utils/circuit_breakers.py)
from utils.circuit_breakers import gemini_circuit_breaker
from utils.exceptions import ExternalAPIError

async def call_gemini(...):
    try:
        async with gemini_circuit_breaker:
            result = await asyncio.wait_for(
                gemini_client.generate(...),
                timeout=30.0
            )
    except asyncio.TimeoutError:
        raise ExternalAPIError("Gemini API timeout")
    except CircuitBreakerOpen:
        raise ExternalAPIError("Gemini API circuit open")
```

### rembg Background Removal (누끼)

```python
# Graceful degradation -- return fallback score on failure
try:
    result = remove_background(image_bytes)
    score = evaluate_quality(result)
except Exception as e:
    logger.warning("rembg failed, using fallback: %s", e)
    score = 0.0  # Fallback to lowest score
```

### Timeouts

```python
# asyncio.wait_for -- set reasonable limits
result = await asyncio.wait_for(
    long_running_task(),
    timeout=60.0  # Generous for testing, reasonable for production
)
```

---

## 4. Environment Variable Management

```
GOOGLE_API_KEY
  --> Python: config/settings.py (Settings class)
  --> Kotlin: application.yml (image-service.api-key)
  --> Docker: docker-compose.yml (environment section)
```

**Prohibited:** Direct `os.environ["GOOGLE_API_KEY"]` in code. Always go through settings.

---

## 5. File Structure Rules

### Python (image-service/)

| Directory | Purpose | Example |
|-----------|---------|---------|
| `routers/` | API endpoint definitions | `generate_all.py` |
| `services/` | Business logic | `product_analyzer.py` |
| `models/` | Pydantic schemas | `schemas.py` |
| `config/` | Environment configuration | `settings.py` |
| `utils/` | Shared utilities | `circuit_breakers.py`, `exceptions.py` |

### Kotlin (src/main/kotlin/)

| Directory | Purpose | Example |
|-----------|---------|---------|
| `controller/` | API endpoints (suspend fun) | `GenerationController.kt` |
| `service/` | Business logic | `ProductGenerationService.kt` |
| `crawler/` | Crawling logic | `DomeggookParser.kt` |
| `dto/` | Data transfer objects | `Dtos.kt` |
| `config/` | Configuration | `CorsConfig.kt` |

---

## 6. Code Structure Rules (OOP)

**MANDATORY** — applies to ALL code in this project:

### Function Size
- **Max 50 lines per function.** If it exceeds 50 lines, split it.
- Each function does ONE thing. Name should describe that one thing.

### Common Logic Extraction
- Same logic in 2+ places → **extract to shared function or class**
- Related functions operating on same data → **group into a class**
- Utility logic (string parsing, image format detection, JSON cleaning) → **put in utils/**

### Class Design (OOP)
- Prefer composition over inline logic
- Service classes hold state (client, config) and expose methods
- Dataclasses for data transfer between layers
- Don't put business logic in dataclasses — use service methods

### Refactoring Triggers
- Function > 50 lines → split immediately
- Same 3+ lines repeated → extract helper
- 3+ related functions with shared params → create class
- Nested if/for > 3 levels deep → extract inner block to function

### Anti-patterns to AVOID
- God functions (100+ lines doing everything)
- Copy-paste with slight variation (use parameters instead)
- Inline logic that should be a named function
- Passing 5+ parameters (use dataclass or context object)

---

## 7. Reuse Existing Utilities

Check existing code before writing new utilities:

| Utility | Location | Purpose |
|---------|----------|---------|
| Circuit Breaker | `utils/circuit_breakers.py` | Prevents external API failure propagation |
| Custom Exceptions | `utils/exceptions.py` | Standardized error types |
| Image Preprocessor | `services/image_preprocessor.py` | Image resize, format conversion, preprocessing |
| Prompt Builder | `services/prompt_builder.py` | Gemini prompt assembly |
| Post Processor | `services/post_processor.py` | Generated image post-processing |

Duplicate implementations will be flagged as WARN in code review.
