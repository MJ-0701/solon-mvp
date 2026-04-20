# CLAUDE.md (공통)

## API Conventions

- URL: `/v{n}/{dash-case-복수형}` (예: `/v3/coverage-analysis/reports`)
- PathVariable은 PK만 허용, 조회 조건은 QueryParam
- 성공 응답: HTTP 200, 래핑 없이 데이터 직접 반환 (ApiResponse 래퍼 금지)
- 에러: 4xx (비즈니스 오류, warn 로그), 5xx (인프라 오류, error 로그)
- ErrorResponse: `{ "errorCode": "...", "errorMessage": "..." }`
- Shield Pattern: Controller에서 `@Valid` + 비즈니스 규칙 검증 적용

## DTO Rules

- Controller 레이어: `{Entity}{Client}Request/Response` (예: `RoleWebRequest`)
- Service 레이어: `{Entity}Request/Response` (예: `RoleRequest`)
- 파일 1개당 DTO 1개, `of()`/`from()`/`to()` 정적 메서드로 변환
- Mapper 라이브러리 사용 금지, 빌더 패턴 사용 금지

## Migration

- 네이밍: `V{yyyyMMddHHmmss}__{description}.sql`
- Flyway 실행은 앱 외부에서 관리

## Git Conventions

- 브랜치: `{type}/{JIRA-KEY}` 또는 `{JIRA-KEY}` (예: `feature/IVS-159`, `IVS-159`)
- git commit/push는 반드시 `/commit` 스킬을 통해 수행한다.

## Code Style

- Google Java Style (intellij-java-google-style.xml)
- Lombok 사용 (compileOnly)

## Infrastructure

- Secret Key(API Key, 비밀번호, 토큰) 하드코딩 금지
- local: git-crypt으로 암호화된 로컬 설정 파일
- dev/prod: AWS Secrets Manager

## Standards (조직 기준)

설계·구현·리뷰·운영에 걸쳐 일관된 품질을 유지하기 위한 표준 문서.

| 문서                  | 경로                                      | 용도                            |
|---------------------|-----------------------------------------|-------------------------------|
| Backend Rules       | `docs/standards/backend-rules.md`       | 아키텍처, 트랜잭션, 예외처리, 테스트 기준      |
| Security Rules      | `docs/standards/security-rules.md`      | 인증/인가, 입력검증, PII, 보안로깅        |
| DB Rules            | `docs/standards/db-rules.md`            | JPA, N+1, 인덱스, 락, 배치          |
| Observability Rules | `docs/standards/observability-rules.md` | metric+log+trace, Datadog, 알림 |
| Metric Spec         | `docs/standards/metric-spec.md`         | 메트릭 네이밍, 태그 정책                |
| PDCA Templates      | `docs/standards/pdca/`                  | Plan/Design/Check/Act 템플릿     |

## Agents & Skills

- `.claude/agents/` — 역할 기반 리뷰어 (architect, api, db, security, observability, qa)
- `.claude/skills/backend-pdca/` — PLAN→DESIGN→구현→CHECK 워크플로우
- `.claude/skills/backend-act/` — 배포 후 회고, act.md 작성
- `.claude/skills/code-review/` — 빠른 코드리뷰
- `.claude/skills/external-api-integration/` — 외부 API 연동 리뷰
- `.claude/skills/spring-observability/` — Datadog 관측성 설계
- 모든 스킬은 `docs/standards/`를 단일 원천으로 참조 (복사본 없음)

## 작업 유형별 프로세스

| 유형                   | 기준                             | 프로세스                 | 스킬                               |
|----------------------|--------------------------------|----------------------|----------------------------------|
| **Full PDCA**        | 신규 기능, 외부 연동, 2일+ 작업, 도메인 간 영향 | PLAN→DESIGN→구현→CHECK | `/backend-pdca` + `/backend-act` |
| **Code Review Only** | 버그 수정, 리팩토링, 의존성 변경, 1일 이내     | 구현→리뷰                | `/code-review`                   |
| **Skip**             | 문서 수정, 설정 변경, 오타 수정            | 구현→커밋                | —                                |

## Token Rules

- CLAUDE.md, standards, 스킬/메모리에 이미 있는 내용이면 파일 읽기 건너뛰기
- 확실하지 않으면 도구 호출 대신 사용자에게 확인
- 가능하면 병렬 처리
- 사용자 말을 앵무새처럼 반복하지 않기
- 상세 문서: docs/standards/ (단일 원천)
