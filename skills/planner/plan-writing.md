---
description: Plan Writing Guide - PDCA Plan 문서 작성 가이드
model: sonnet
---

# Plan Writing Guide Skill

PDCA Plan 문서를 작성할 때 따라야 할 구조와 가이드라인.

## Plan Document Structure

1. **Executive Summary** - 4가지 관점 테이블 (Problem/Solution/Function UX Effect/Core Value)
2. **Background & Motivation** - 왜 이 기능이 필요한가?
3. **Scope** - In scope / Out of scope 명확히 구분
4. **Requirements** - 기능적/비기능적 요구사항
5. **Acceptance Criteria** - 측정 가능한 완료 기준
6. **Dependencies** - 외부 의존성 및 제약사항
7. **Risk Assessment** - 리스크 및 대응 방안
8. **Timeline** - 대략적 마일스톤

## Writing Principles

- **한국어** 기본, 기술 용어는 영어
- **구체적이고 측정 가능한** 기준 사용
- **Mermaid 다이어그램** 활용 (복잡한 플로우)
- **YAGNI 원칙** - 필요한 것만 포함

## Project-Specific Considerations

- OpenAI API 비용 고려 (토큰/이미지당 과금)
- 이미지 처리 파이프라인의 비동기 특성
- Rate limiting 및 에러 핸들링 필요성
- 향후 자체 모델 교체 가능성 (인터페이스 추상화)
