---
name: external-api-integration
description: 외부 API 연동 리뷰 — timeout/retry/fallback/정합성/관측성 종합 검토
---

> **Hook Profile: standard** — 이 스킬 시작 시 `echo "standard" > .claude/.hook-profile`을 실행하세요.

# External API Integration Skill

## 목적
외부 API 연동 작업 시 timeout, retry, 장애 전파, observability, 정합성, 보정 전략을 함께 검토하기 위한 스킬이다.

## 적용 대상
- 보험사/병원/제휴사 연동 (HIRA, NHIS, 홈텍스, 신정원 등)
- webhook/callback 처리 (결제 콜백, 병원 서류 수신)
- polling/sync 작업 (보험 계약 동기화, 청구 상태 조회)
- 외부 인증/조회/전송 API

## 기본 원칙
- 외부 시스템은 항상 실패할 수 있다.
- timeout 없이 호출하지 않는다.
- retry는 idempotent 호출에 한해 검토한다. (멱등성 보장 방법: unique constraint, idempotency key)
- 실패 시 사용자/운영자 관점의 의미를 분리한다.
- external.api.count / latency / error metric을 설계한다.
- circuit breaker 패턴 필요 여부를 검토한다.

## 프로젝트 컨텍스트
- 93+ 외부 연동 대상 (보험사, 병원, 결제, 공공기관)
- Datadog APM으로 외부 호출 추적 (StatsD port 8125)
- RequestBodyTaggingFilter로 민감정보 자동 redact
- 인증 정보: AWS Secrets Manager / Parameter Store 사용

## 참고 문서 (단일 원천: docs/standards/)
- docs/standards/backend-rules.md
- docs/standards/observability-rules.md
- docs/standards/metric-spec.md

## 출력 형식
1. 연동 개요 (대상 시스템, 프로토콜, 인증 방식)
2. 장애/정합성 리스크 (부분 실패, 데이터 불일치)
3. timeout/retry/fallback/circuit breaker 제안
4. observability 설계 (metric, log, trace, alert)
5. 운영 보정 전략 (수동 재처리, 자동 복구)

## 종료 시
이 스킬의 모든 절차가 완료되면 `echo "minimal" > .claude/.hook-profile`을 실행하여 hook 프로필을 초기화하세요.
