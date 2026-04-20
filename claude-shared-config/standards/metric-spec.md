# Metric Spec

## 1. 목적
전사 백엔드 서비스에서 공통으로 사용하는 메트릭 이름, 태그, 타입, 금지 규칙을 정의한다.

## 2. Naming Convention
형식:
{domain}.{action}.{metric_type}

예시:
- claim.submit.count
- claim.submit.latency
- claim.submit.error
- external.api.count
- http.request.latency
- batch.job.duration

## 3. Metric Type
- count: 발생 횟수
- error: 오류 발생 횟수
- latency: 요청 또는 작업 지연 시간
- duration: 작업 소요 시간
- gauge: 시점 상태값
- distribution: 분포 분석이 필요한 지표

## 4. 공통 메트릭
### HTTP
- http.request.count
- http.request.latency
- http.request.error

### External API
- external.api.count
- external.api.latency
- external.api.error

### Batch
- batch.job.count
- batch.job.duration
- batch.job.error

## 5. Business Metric 예시 (보험 도메인)
- claim.submit.count (tags: result=accepted/rejected, guarantee_type)
- claim.submit.latency (tags: guarantee_type)
- claim.submit.error (tags: error_type=validation/timeout/system)
- claim.approval.count (tags: approval_type=auto/manual)
- proxy.commission.count (tags: status=success/error, payment_type)
- payment.confirm.count (tags: payment_method=card/bank, provider)
- payment.confirm.error (tags: error_type=timeout/declined/system)
- external.api.hospital.count (tags: hospital_code, operation)
- external.api.hospital.error (tags: hospital_code, error_type=timeout/validation)
- policy.sync.error (tags: insurance_company, error_type)

## 6. 필수 태그
- env
- service
- version

## 7. 허용 태그
- endpoint
- method
- result
- status
- client
- job
- error_type
- guarantee_type
- insurance_company
- hospital_code
- payment_method
- provider
- approval_type
- operation

## 8. 금지 태그
- user_id
- phone
- email
- resident_number
- claim_id
- hospital_name 원문
- 자유 텍스트 전체

## 9. 태그 설계 원칙
- snake_case 사용
- 값은 제한된 집합을 우선 사용
- tag cardinality 폭발을 피한다.
- 운영 대시보드/모니터에서 실제로 쓰는 태그만 유지한다.

## 10. Alert 기본 가이드
- error rate > 기준치
- latency p95 > 기준치
- 외부 API error 증가
- batch 실패 즉시 알림
- 핵심 비즈니스 성공률 급감 시 알림

## 11. Dashboard 기본 가이드
- throughput
- error rate
- latency(p50/p95/p99)
- external dependency health
- batch success/failure
- business KPI metric

## 12. 변경 규칙
새로운 메트릭을 추가할 때는 다음을 만족해야 한다.
- naming convention 준수
- 태그 규칙 준수
- 목적과 활용 대시보드/모니터 정의
- high-cardinality 위험 검토
