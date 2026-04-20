---
name: backend-pdca
description: Spring Boot 백엔드 PLAN→DESIGN→CHECK→ACT 워크플로우. 신규 기능, 리팩토링, 외부 연동, 장애 대응에 사용.
argument-hint: docs/path/to/requirements.md
---

> **Hook Profile: strict** — 이 스킬 시작 시 `echo "strict" > .claude/.hook-profile`을 실행하세요.

# Backend PDCA Skill

## 요구사항
!`cat $ARGUMENTS`

> 위 요구사항이 비어있으면 사용자에게 요구사항 문서 경로를 요청한다.
> 요구사항에서 JIRA 티켓 번호(예: IVS-xxx)를 찾을 수 없으면 PLAN 작성 전에 반드시 사용자에게 티켓 번호를 확인한다.

## 산출물 저장 규칙
- 경로에서 도메인 추출: `docs/{domain}/...` → domain
- 산출물 저장 경로: `docs/{domain}/{yyyyMMdd}/`
- 각 단계 완료 + 사용자 확인 후 해당 파일 생성:
  - PLAN → `docs/{domain}/{yyyyMMdd}/plan.md`
  - DESIGN → `docs/{domain}/{yyyyMMdd}/design.md`
  - CHECK → `docs/{domain}/{yyyyMMdd}/check.md`

## 목적
Spring Boot 백엔드 작업을 PLAN → DESIGN → (구현) → CHECK → ACT 구조로 수행하기 위한 공통 스킬이다.

## 언제 사용할까
- 신규 기능 설계
- 복잡한 리팩토링
- 외부 API 연동 추가
- 장애/버그 후 재발 방지 정리
- 대규모 영향 범위가 있는 변경

## 수행 절차

**반드시 각 단계 완료 후 사용자 확인을 받고 다음 단계로 넘어간다.**

1. PLAN: 문제 정의, 목표, 제약조건, 리스크 정리 → Context Anchor(WHY-WHO-RISK-SUCCESS-SCOPE) 포함
   → **사용자 확인**
2. DESIGN: 아키텍처, API, DB(JPA+QueryDSL), Redis 캐싱, 보안, observability 설계
   - Domain Design: Value Object(불변, Side-Effect-Free), Aggregate(Root 통해서만 접근)
   - Design by Contract: 사전조건(Controller) → 사후조건(Service) → 불변식(VO) → 구현(Domain)
   - 캡슐화: 같은 패키지(interface+package-private), 다른 패키지(abstract class+public final)
   - **구현 Step 분리**: DESIGN 마지막에 구현 단위(Step)를 나열한다.
     예) Step 1: Entity/VO → Step 2: Repository → Step 3: Service → Step 4: Controller/DTO
   → **사용자 확인**
3. 구현: DESIGN에서 정의한 Step 순서대로 진행
   - **각 Step 시작 전 — Search First (기존 코드 조사)**:
     1. **코드베이스 검색**: Grep으로 유사 클래스명/메서드명/패턴 검색
     2. **공통 모듈 확인**: common/ 패키지, 유틸 클래스에 재사용 가능한 코드가 있는지 확인
     3. **같은 도메인 참고**: 같은 도메인 또는 유사 도메인의 기존 Service/Repository/DTO 패턴 참고
     4. **의존성 확인**: 이미 프로젝트에 포함된 라이브러리로 해결 가능한지 확인 (build.gradle)
     5. **결정**:
        - 재사용 가능 → 기존 코드를 그대로 사용하거나 확장
        - 유사 패턴 존재 → 해당 패턴을 따라 일관성 있게 구현
        - 해당 없음 → 새로 구현하되, 조사 결과를 사용자에게 공유
     - 검색 없이 바로 구현하지 않는다.
   - TDD(RED→GREEN→REFACTOR) 진행
   - **Step 단위로 구현 → 사용자 확인을 반복한다.**
   - 한 번에 여러 Step을 구현하지 않는다.
   → **각 Step 완료 시마다 사용자 확인**
4. CHECK: `/code-review` 스킬 기준으로 리뷰 수행 + check.md 작성
   - 외부 연동 코드(WebClient, RestTemplate, Redis 등)가 포함된 경우 `/external-api-integration` 기준으로 timeout/retry/fallback/observability를 반드시 리뷰한다.
   → **사용자 확인 후 세션 종료** (배포 진행)

> ACT는 배포 후 `/backend-act` 스킬로 별도 진행한다.

## 프로젝트 컨텍스트
- 멀티모듈: greenribbon-web(REST) / greenribbon-service(도메인) / greenribbon-batch(배치)
- 93+ 도메인 패키지 (proxy, member, insurance, hospital, payment 등)
- API: /v{n}/{dash-case-복수형}, no ApiResponse wrapper, 4xx=비즈니스, 5xx=인프라
- DTO: {Entity}{Client}Request/Response, of()/from()/to() 정적 변환, 빌더 금지
- DB: MySQL 8.0 (UTC), Flyway 마이그레이션 V{yyyyMMddHHmmss}__
- 관측성: Datadog APM + StatsD, RequestBodyTaggingFilter
- 테스트: Spock + FixtureMonkey

## 반드시 참고할 문서 (단일 원천: docs/standards/)
- docs/standards/backend-rules.md
- docs/standards/security-rules.md
- docs/standards/db-rules.md
- docs/standards/observability-rules.md
- docs/standards/metric-spec.md
- docs/standards/pdca/spring-backend-plan.md
- docs/standards/pdca/spring-backend-design.md
- docs/standards/pdca/spring-backend-check.md
- docs/standards/pdca/spring-backend-act.md

## 출력 원칙
- 설계와 구현을 구분한다.
- trade-off를 명확히 쓴다.
- 위험과 후속 액션을 숨기지 않는다.
- 팀 표준으로 환원 가능한 규칙을 도출한다.

## 종료 시
이 스킬의 모든 절차가 완료되면 `echo "minimal" > .claude/.hook-profile`을 실행하여 hook 프로필을 초기화하세요.
