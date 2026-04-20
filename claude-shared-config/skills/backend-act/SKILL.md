---
name: backend-act
description: 배포 후 회고 — 운영 결과 기반으로 act.md 작성 및 standards 환원
argument-hint: docs/{domain}/{yyyyMMdd}/act-input.md
---

# Backend ACT Skill

## 입력
!`cat $ARGUMENTS`

> 위 입력이 비어있으면 사용자에게 act-input 문서 경로를 요청한다.
> 입력 양식은 `docs/standards/pdca/act-input-template.md`를 참고한다.

## 수행 절차

1. 입력 문서에서 도메인/날짜 추출 → 해당 경로의 plan.md, design.md, check.md 읽기
2. 입력 데이터 + 기존 산출물을 종합하여 `docs/standards/pdca/spring-backend-act.md` 템플릿 기반으로 act.md 작성
3. act.md 저장 경로: `docs/{domain}/{yyyyMMdd}/act.md`
4. 재발 방지 규칙 도출 → `docs/standards/` 반영 대상 제안
   → **사용자 확인 후 standards 반영**

## 참고 문서
- docs/standards/pdca/act-input-template.md
- docs/standards/pdca/spring-backend-act.md
- docs/standards/backend-rules.md
- docs/standards/security-rules.md
- docs/standards/db-rules.md
- docs/standards/observability-rules.md
