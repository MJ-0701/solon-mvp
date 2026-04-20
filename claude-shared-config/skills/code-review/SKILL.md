---
name: code-review
description: 백엔드 코드리뷰 — 구조/트랜잭션/DB/보안/관측성/테스트 관점 위험 식별
---

> **Hook Profile: standard** — 이 스킬 시작 시 `echo "standard" > .claude/.hook-profile`을 실행하세요.

# Code Review Skill

## 목적
백엔드 코드리뷰 시 구조, DB, 보안, 예외 처리, 관측성, 테스트 관점에서 빠르게 위험을 찾아내기 위한 스킬이다.

## 리뷰 우선순위
1. 구조/책임 분리 (Controller→Service→Domain 경계)
2. Transaction/정합성 (boundary, readOnly, 외부호출 분리)
3. DB/N+1/인덱스 (QueryDSL 동적 쿼리, fetch join, projection)
4. 보안/PII (인증/인가, RequestBodyTaggingFilter 대상, 로그 노출)
5. 관측성 (Datadog metric/tag, traceId, 에러 알림)
6. 테스트/회귀 위험 (Spock spec, FixtureMonkey fixture, 경계값)

## 리뷰 질문
- 이 변경은 어디서부터 어디까지 영향을 주는가?
- merge 후 운영에서 가장 먼저 터질 지점은 어디인가?
- Datadog metric과 로그가 장애를 감지하기에 충분한가?
- 장기 유지보수 비용을 높이는 구조는 없는가?

## 프로젝트 필수 체크
- [ ] URL: /v{n}/{dash-case-복수형}, PathVariable은 PK만
- [ ] 응답: ApiResponse 래퍼 금지, 데이터 직접 반환
- [ ] DTO: {Entity}{Client}Request/Response, 빌더 금지, of()/from()/to()
- [ ] ErrorResponse: { "errorCode": "...", "errorMessage": "..." }
- [ ] Redis 캐시: invalidation 전략, TTL 정의
- [ ] Flyway: 마이그레이션 버전 충돌 없음
- [ ] Design by Contract: 사전조건(Controller), 사후조건(Service), 불변식(VO) 준수
- [ ] Aggregate 경계: Root 통해서만 내부 접근, 외부에서 Entity/VO 직접 접근 금지
- [ ] 쉴드 패턴: Controller에서 `@Valid` + 비즈니스 규칙 검증 적용
- [ ] 외부 연동: WebClient/RestTemplate/Redis 등 사용 시 timeout/retry/fallback/observability 검토 (`/external-api-integration` 기준)
- [ ] Enum 네이밍: 새 enum 상수 추가 시 기존 코드베이스의 스펠링과 일치하는지 확인 (예: CANCELED vs CANCELLED)
- [ ] 예외 리팩토링: 예외 타입/에러 처리 변경 시 관련 테스트 assertion 함께 업데이트 확인

## 보안 취약점 탐색 (공격자 관점)

변경된 코드에 아래 패턴이 포함되어 있으면, Controller(entrypoint) → Service → 실제 호출(sink)까지 코드 경로를 추적하여 사용자 입력이 도달 가능한지 확인한다.

| 패턴 | CWE | 확인 포인트 |
|------|-----|-----------|
| 사용자 입력 URL로 외부 호출 (SSRF) | CWE-918 | allowlist 없이 사용자 URL을 WebClient/RestTemplate에 전달하는지 |
| Native Query 문자열 연결 (SQL Injection) | CWE-89 | `@Query`에서 `:param` 바인딩 대신 문자열 연결 사용하는지 |
| 사용자 입력으로 명령 실행 (Command Injection) | CWE-78 | ProcessBuilder/Runtime.exec에 사용자 입력이 들어가는지 |
| 파일 경로에 사용자 입력 (Path Traversal) | CWE-22 | `../` 등으로 의도하지 않은 경로 접근 가능한지 |
| 역직렬화 (Deserialization RCE) | CWE-502 | 사용자 업로드 파일을 ObjectInputStream으로 읽는지 |
| 인증/인가 우회 (Auth Bypass) | CWE-287 | SecurityConfig에서 새 endpoint가 permitAll인지, 권한 체크 누락인지 |

**절차:**
1. 변경된 코드에서 위 패턴에 해당하는 sink 확인
2. entrypoint(Controller)에서 sink까지 사용자 입력이 도달하는 경로 추적
3. 도달 가능하면 **필수 수정**으로 보고

**무시할 것:** 테스트 코드, 로컬 전용 CLI, 하드코딩된 명령, 보안 헤더 누락 단독

## 참고 문서 (단일 원천: docs/standards/)
- docs/standards/backend-rules.md
- docs/standards/security-rules.md
- docs/standards/db-rules.md

## 출력 형식
- 주요 위험
- 필수 수정
- 권장 개선
- merge 가능 여부

## 종료 시
이 스킬의 모든 절차가 완료되면 `echo "minimal" > .claude/.hook-profile`을 실행하여 hook 프로필을 초기화하세요.
