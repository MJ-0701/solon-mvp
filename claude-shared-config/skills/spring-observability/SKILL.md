---
name: spring-observability
description: Spring Boot Datadog 관측성 설계 — metric/log/trace/monitor/alert 종합
---

> **Hook Profile: standard** — 이 스킬 시작 시 `echo "standard" > .claude/.hook-profile`을 실행하세요.

# Spring Observability Skill

## 목적
Spring Boot 서비스에서 Datadog 기반의 observability 설계를 빠르게 정리하고 검토한다.

## 다루는 범위
- HTTP metric (http.request.count/latency/error)
- External API metric (external.api.count/latency/error)
- Business metric ({domain}.{action}.count/latency/error)
- Batch metric (batch.job.count/duration/error)
- traceId/correlationId (MDC 기반)
- Datadog dashboard / monitor / alert 기준
- Payment 특화 로깅 (PaymentMdcAspect)

## 프로젝트 스택
- Datadog APM + StatsD (port 8125, step 1m)
- Logback + MDC (traceId, correlationId)
- RequestBodyTaggingFilter (Datadog span 태깅, 민감정보 redact)
- PaymentMdcAspect (결제 트랜잭션 전용 MDC)
- Datadog Error Tracking (Sentry 사용하지 않음)

## 기본 체크포인트
- success / error / latency metric 존재 여부
- high-cardinality 태그 위험 여부 (금지: user_id, email, claim_id, resident_number)
- 외부 API 장애 감지 가능 여부
- 비즈니스 KPI 관측 가능 여부

## 보험 도메인 메트릭 예시
- claim.submit.count (tags: result=accepted/rejected, guarantee_type)
- claim.approval.latency (tags: approval_type=auto/manual)
- proxy.commission.count (tags: status=success/error)
- external.api.hospital.error (tags: hospital_code, error_type=timeout/validation)
- payment.confirm.count (tags: payment_method=card/bank, provider)

## 카디널리티 가드
- 필수 태그: env, service, version
- 허용 태그: endpoint, method, result, status, error_type, job
- 금지 태그: user_id, phone, email, resident_number, claim_id, hospital_name 원문
- 임계값: 태그 값 종류 50개 이상이면 그룹화 또는 제거

## 참고 문서 (단일 원천: docs/standards/)
- docs/standards/observability-rules.md
- docs/standards/metric-spec.md

## 출력 형식
1. 현재 관측 상태
2. 누락된 지표
3. 추천 metric/log/monitor
4. Datadog 대시보드/알림 권고안

## 종료 시
이 스킬의 모든 절차가 완료되면 `echo "minimal" > .claude/.hook-profile`을 실행하여 hook 프로필을 초기화하세요.
