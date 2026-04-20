---
description: Tech Research - 기술 리서치 수행 가이드
model: sonnet
---

# Tech Research Skill

기술 리서치를 수행할 때 따라야 할 프로세스와 출력 포맷.

## Research Process

1. **Define Scope** - 리서치 질문을 명확히 정의
2. **Gather Sources** - 공식 문서, GitHub, 기술 블로그 탐색
3. **Analyze** - 프로젝트 맥락에서 분석
4. **Recommend** - 팀에 실행 가능한 권장사항 제시

## Priority Research Topics

### OpenAI API
- gpt-image-1 파라미터 및 제한사항
- GPT-4o Vision 이미지 분석 프롬프트 최적화
- API rate limits 및 pricing
- 에러 코드 및 retry 전략

### Spring Boot + Kotlin
- WebClient 비동기 패턴
- Coroutine + WebFlux 통합 패턴
- Multipart file upload 처리
- 대용량 파일 스트리밍

### Image Processing
- 포맷별 특성 (PNG, JPEG, WebP)
- 이미지 메타데이터 처리
- 리사이징 및 최적화 전략

## Output Format

```markdown
## Research: {topic}
**Date**: YYYY-MM-DD
**Priority**: HIGH | MEDIUM | LOW
**Model Used**: sonnet | haiku

### Context
{왜 이 리서치가 필요한지}

### Findings
{핵심 발견사항 - 번호 매기기}

### Recommendation
{팀에 대한 구체적 권장사항}

### Sources
{참조 링크 및 문서}
```

## Model Selection Guide

| Task Type | Recommended Model |
|-----------|-------------------|
| API 문서 확인 | haiku (빠른 조회) |
| 아키텍처 패턴 비교 | sonnet (깊은 분석) |
| 라이브러리 버전 체크 | haiku |
| 경쟁사/시장 분석 | sonnet |
| 간단한 FAQ | haiku |
| 기술 트레이드오프 분석 | sonnet |
