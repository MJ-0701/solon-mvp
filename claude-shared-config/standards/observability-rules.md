# Observability Rules

## 목적
모든 백엔드 서비스가 장애를 빠르게 감지하고, 원인을 추적 가능하며, 개선 가능한 상태를 유지하도록 하기 위한 기준이다.

## 1. 기본 원칙
- 로그만으로 운영하지 않는다. metric + log + trace 관점을 함께 본다.
- 모든 핵심 비즈니스 플로우는 success / error / latency를 측정한다.
- 모든 외부 API 연동은 count / latency / error를 측정한다.
- 모든 요청 흐름에는 traceId 또는 correlationId가 존재해야 한다.
- 새 기능 배포 시 observability 설계가 포함되어야 한다.

## 2. 필수 메트릭 범주
### HTTP
- http.request.count
- http.request.latency
- http.request.error

### External API
- external.api.count
- external.api.latency
- external.api.error

### Business
- {domain}.{action}.count
- {domain}.{action}.latency
- {domain}.{action}.error

### Batch
- batch.job.count
- batch.job.duration
- batch.job.error

## 3. 로그 규칙
- traceId/correlationId를 포함한다.
- 에러 로그는 원인 파악에 필요한 context를 포함한다.
- 개인정보, 토큰, 패스워드 등 민감정보는 남기지 않는다.
- 외부 API 실패 시 대상 시스템, timeout 여부, 상태 코드를 식별 가능하게 남긴다.

## 4. 메트릭 설계 원칙
- metric 이름은 일관된 naming convention을 따른다.
- 태그는 low-cardinality 중심으로 설계한다.
- user_id, email, claim_id 등 폭발적인 태그는 금지한다.
- SLO 또는 운영 판단에 쓰일 수 있는 지표를 우선 측정한다.

## 5. Alert 기본 기준
- 5xx error rate 증가
- latency p95/p99 악화
- 외부 API 에러율 증가
- 배치 실패 또는 처리량 급감
- 핵심 비즈니스 이벤트 성공률 급감

## 6. Datadog 운영 기준 (전사 표준 — Sentry 사용하지 않음)
- env, service, version 태그를 기본 사용한다.
- dashboard는 요청 수, 에러율, latency, 외부 의존성을 기본 포함한다.
- monitor는 너무 민감해서 노이즈가 되지 않도록 임계치와 지속시간을 검토한다.
- Error Tracking: Datadog Error Tracking을 사용한다. (Sentry 사용 금지)
- APM: dd-java-agent.jar 기반, StatsD flavor (port 8125, step 1m)
- Span 태깅: RequestBodyTaggingFilter를 통해 요청 body에서 태그를 추출한다.
  - 자동 redact 대상: password, token, cardnumber, ssn 등
- 결제 로깅: PaymentMdcAspect로 결제 트랜잭션 전용 MDC를 설정한다.
- MDC: MdcLoggerInterceptor로 요청 스코프 traceId/correlationId를 설정한다.

## 7. ACT 연계
모든 ACT 문서에는 아래가 포함되어야 한다.
- 부족했던 로그
- 부족했던 메트릭
- 추가해야 할 monitor/alert
- 다음부터 표준화할 observability 패턴

## 8. 금지 사항
- 메트릭 없이 기능 배포
- 로그 없이 배포
- 외부 연동을 black box로 운영
- high-cardinality 태그 남발
