---
description: Architecture Decision Record - 주요 아키텍처 결정 기록
model: opus
---

# Architecture Decision Record (ADR) Skill

주요 기술 결정을 구조화하여 기록하는 스킬.

## ADR Template

```markdown
# ADR-{number}: {title}

## Status
PROPOSED | ACCEPTED | DEPRECATED | SUPERSEDED

## Context
결정이 필요한 배경과 상황.

## Decision
선택한 결정과 이유.

## Alternatives Considered
| Option | Pros | Cons |
|--------|------|------|
| Option A | ... | ... |
| Option B | ... | ... |

## Consequences
### Positive
- ...
### Negative
- ...

## References
- ...
```

## Project-Specific Decisions to Track
- OpenAI API 모델 선택 (gpt-image-1 vs alternatives)
- 이미지 처리 파이프라인 설계
- 에러 핸들링 전략
- 캐싱 전략
- Rate limiting 접근법
