# DB Rules

## 목적
DB 접근, JPA 사용, 인덱스, 정합성, 배치 처리 기준을 정의한다.

## 1. 조회 쿼리 기본 원칙
- 리스트 API는 pagination 전략을 명시한다.
- where/join/order 조건을 보고 인덱스를 검토한다.
- explain 또는 실행계획 확인 없이 무거운 쿼리를 merge하지 않는다.
- 대량 조회는 projection/DTO 조회를 우선 검토한다.

## 2. JPA 사용 기준
- 기본 fetch 전략이 실제 쿼리 패턴과 맞는지 검토한다.
- N+1 가능성을 반드시 점검한다.
- fetch join, EntityGraph, projection 중 목적에 맞는 방식을 선택한다.
- 양방향 연관관계는 최소화한다.

## 2-1. QueryDSL 사용 기준
- 동적 조건이 3개 이상이면 QueryDSL을 우선 검토한다.
- Q-type 기반 타입 안전 쿼리를 사용한다. 문자열 JPQL 직접 작성은 지양한다.
- BooleanExpression을 조합하여 동적 predicate를 구성한다. null 조건은 무시 처리한다.
- QueryDSL + Pageable 조합 시 count 쿼리 최적화를 검토한다.
- projection(Projections.constructor, @QueryProjection)을 활용하여 필요한 컬럼만 조회한다.

## 2-2. Redis 캐싱 전략
- 자주 조회되고 변경이 드문 데이터(보험사 목록, 보장 유형 등)를 캐시 대상으로 한다.
- Cache-Aside 패턴을 기본으로 한다. (조회 시 캐시 확인 → miss → DB 조회 → 캐시 저장)
- TTL을 반드시 설정한다. 무기한 캐시를 사용하지 않는다.
- 쓰기 시 캐시를 무효화한다. 캐시 키는 `{entity}:{id}` 형식으로 일관되게 설계한다.
- 캐시 적중률과 eviction rate를 모니터링한다.

## 3. 정합성
- 금액/상태/정산 관련 계산은 도메인 정책으로 관리한다.
- 상태 전이는 서비스 if-else 체인보다 도메인 메서드로 우선 표현한다.
- 중복 처리 가능성이 있는 쓰기 로직은 멱등성 또는 unique constraint를 검토한다.

## 4. 락과 트랜잭션
- long transaction 금지
- 락 범위를 최소화한다.
- 대량 업데이트/삭제는 배치 처리 또는 별도 전략을 검토한다.
- 외부 호출과 DB 락을 동시에 길게 유지하지 않는다.

## 5. 인덱스 기준
- where, join, sort, unique 제약 조건 기반으로 인덱스를 설계한다.
- 인덱스 추가 시 쓰기 비용과 저장공간 trade-off를 함께 검토한다.
- 자주 쓰는 조회 패턴이 바뀌면 인덱스도 재평가한다.

## 6. 배치/Bulk 처리
- chunk size를 명시한다.
- 실패 시 재처리 전략을 문서화한다.
- 운영 영향도를 고려해 throttling 또는 시간대 제어를 검토한다.
- chunk 단위 성공/실패 메트릭을 남긴다.

## 7. 코드리뷰 체크포인트
- N+1 위험
- 불필요한 전체 조회
- 정렬/검색 시 인덱스 부재
- count 쿼리 비용
- 락/경합 가능성
- JPA dirty checking 범위 과다

## 8. 금지 사항
- 무제한 리스트 조회
- explain 없이 위험 쿼리 배포
- 고비용 쿼리를 핫패스에 무비판적으로 사용
- 운영 데이터에 대한 즉흥 bulk update
