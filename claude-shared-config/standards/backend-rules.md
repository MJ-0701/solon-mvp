# Backend Rules

## 목적
이 문서는 Spring Boot 기반 백엔드 서비스가 최소한으로 지켜야 할 설계 및 구현 기준을 정의한다.
목표는 일관된 품질, 예측 가능한 운영, 빠른 코드리뷰, 장애 예방이다.

## 1. 아키텍처 기본 원칙
- 설계 없이 구현하지 않는다. PLAN → DESIGN → DO → CHECK → ACT 흐름을 우선한다.
- 개발 3대 원칙: KISS, YAGNI, DRY
- Pattern: CQRS (READ/WRITE 분리)
- Design Principle: 책임주도개발 + SOLID + 계약에 의한 설계
- 도메인 로직은 가능한 Domain에 위치시킨다.
- Service는 orchestration과 transaction boundary 관리에 집중한다.
- Controller는 request/response, validation, authentication context 처리에 집중한다.
- Infra 관심사는 Domain에 침투시키지 않는다.
- Variable Naming: 변수명은 클래스명과 동일하게 (축약 금지)
  - O: `OrderCommandService orderCommandService`
  - X: `OrderCommandService service`

## 2. 패키지 및 책임 분리
- Controller: API entrypoint, validation, response mapping
- Service: use case orchestration, transaction boundary
- Domain: 상태 변경 규칙, 핵심 정책
- Repository: 영속성 추상화
- Client/Adapter: 외부 API, 메시징, 스토리지 연동
- Config: framework 설정

## 3. API 규칙
- Request/Response DTO를 분리한다.
- 엔티티를 Controller 응답으로 직접 반환하지 않는다.
- 상태코드는 HTTP 의미에 맞게 사용한다.
- 에러 응답은 공통 포맷으로 관리한다.
- 리스트 조회는 pagination 또는 cursor 전략을 명시한다.
- 쓰기 API는 멱등성 필요 여부를 반드시 검토한다.

## 4. Transaction 규칙
- 쓰기 로직은 transaction boundary를 명시한다.
- 조회 로직은 가능한 readOnly=true를 사용한다.
- long transaction을 피한다.
- 외부 API 호출은 트랜잭션 경계 밖에서 수행한다.
  - 예외: 외부 API 실패 시 롤백이 필요한 경우만 트랜잭션 내부 (명시적 문서화 필수)
- batch/bulk 작업은 chunk와 rollback 전략을 문서화한다.
- 분산 락은 Redis 기반을 선호한다. 락 획득은 트랜잭션 경계 밖에서 수행한다.
  - 순서: 락 획득 → 트랜잭션 시작 → 작업 → 커밋 → 락 해제
  - 락을 @Transactional 내부에서 획득/해제하지 않는다.

## 5. 예외 처리 규칙
- 사용자 메시지와 내부 원인 메시지를 분리한다.
- 도메인 예외, 외부 연동 예외, 검증 예외를 구분한다.
- swallow exception 금지
- 재시도 가능 여부를 예외 의미에 반영한다.
- HTTP 상태코드 매핑:
  - 400: `IllegalArgumentException`, `IllegalStateException` (인자/상태 오류)
  - 404: `NoSuchElementException` (리소스 없음)
  - 500: `RuntimeException` (서버 오류)
- 4xx는 클라이언트가 retry하지 않는다 (비즈니스 오류).
- 5xx는 멱등성이 보장되는 GET만 retry 가능. POST/PUT은 retry 금지.
- 일부 retry로 해소 가능한 앱 오류는 500으로 보낼 수 있다. 이 경우 반드시 문서화한다.
- @ControllerAdvice로 예외를 일관성 있게 처리한다.

## 6. 테스트 기준
- 핵심 서비스 로직에는 Spock spec으로 unit test를 둔다.
- 복잡한 테스트 데이터는 FixtureMonkey로 생성한다.
- Repository 쿼리가 복잡하면 integration test를 둔다.
- 실패 케이스와 경계값을 테스트한다.
- 장애/버그 수정 시 회귀 테스트를 추가한다.
- 예외 타입/에러 처리를 리팩토링할 때 관련 테스트 assertion도 반드시 함께 업데이트한다.

### TDD 프로세스
```
RED (테스트 작성) → GREEN (최소 구현) → REFACTOR (패턴 적용, 테스트 유지)
```

### RIGHT BICEP 원칙
| 원칙              | 검증 내용               |
|-----------------|---------------------|
| **R**ight       | 결과가 올바른가            |
| **B**oundary    | 경계값 (null, 빈값, 최대값) |
| **I**nverse     | 역연산 검증              |
| **C**ross-check | 다른 방법으로 교차 검증       |
| **E**rror       | 예외 발생 검증            |
| **P**erformance | 성능 허용 범위            |

### 테스트 분류
객체지향 → 단위+통합+슬라이스, 트랜잭션 스크립트 → 통합테스트만.

| 종류       | 위치                          | 도구                |
|----------|-----------------------------|-------------------|
| 단위 테스트   | `{service-module}/src/test` | JUnit, AssertJ    |
| 통합 테스트   | `{web-module}/src/test`     | `@SpringBootTest` |
| 슬라이스 테스트 | `{web-module}/src/test`     | `@WebMvcTest`     |

## 7. 관측성 기준
- 모든 기능 배포 시 Datadog metric 설계를 포함한다. (Sentry 사용하지 않음)
- MDC에 traceId/correlationId를 설정한다.
- 결제 플로우는 PaymentMdcAspect를 적용한다.
- 외부 API 호출은 count/latency/error metric을 남긴다.

## 8. 코드리뷰 필수 확인
- 책임 분리 적절성
- transaction 범위 적절성
- N+1 위험 여부 (QueryDSL fetch join, projection 검토)
- validation 및 예외 처리 누락 여부
- Datadog observability 누락 여부
- 보안 이슈 여부
- Redis 캐시 invalidation 전략 적절성

## 9. Design by Contract

| 구분       | 위치                      | 책임                  |
|----------|-------------------------|---------------------|
| **사전조건** | 진입점 (Controller/Facade) | null 체크, 필수값 검증     |
| **사후조건** | 중간 계층 (Service)         | 결과 유효성 검증           |
| **불변식**  | Value Object            | 항상 유효한 상태 보장        |
| **구현체**  | Domain                  | 순수 비즈니스 로직만 (검증 없음) |

### 캡슐화 전략

| 조건     | 전략                                                      |
|--------|---------------------------------------------------------|
| 같은 패키지 | `interface` + `package-private` 구현체                     |
| 다른 패키지 | `abstract class` + `public final` 구현체 + `protected` 메서드 |

## 10. Domain Design

### Value Object
- `ValueObject.java` 상속, 불변, Side-Effect-Free
- 값이 같으면 같은 객체

### Aggregate
- Aggregate Root: `AggregateRoot.java` 상속
- Entity: `DomainEntity.java` 상속
- Value Object: `ValueObject.java` 상속
- Aggregate Root를 통해서만 내부 접근

## 11. 인프라 규칙
- Secret Key(API Key, 비밀번호, 토큰) 하드코딩 금지 → 환경별 Secret Manager 사용
- DDL 변경은 Flyway 필수
- Hibernate 6 호환성: QueryDSL `transform(groupBy())`는 Hibernate 6에서 비호환 → `select().fetch()` + stream collector 사용

## 12. 금지 사항
- 설계 없이 큰 기능을 한 번에 구현
- Controller/Service에 비즈니스 규칙을 과도하게 누적
- Entity 직접 노출
- 테스트 없이 merge
- 로그/메트릭 없이 배포
