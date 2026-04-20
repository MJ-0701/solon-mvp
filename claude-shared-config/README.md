# claude-shared-config

Green Ribbon 프로젝트들의 Claude Code 공유 설정 저장소.

각 프로젝트에서 동일한 규칙, 에이전트, 스킬, 훅, 표준 문서를 사용하기 위해 단일 원천으로 관리한다.

## 대상 프로젝트

| 프로젝트 | 경로 |
|----------|------|
| greenribbon-api | `/Users/gr/IdeaProjects/greenribbon-api` |
| agent-work-manage-api | `/Users/gr/IdeaProjects/agent-work-manage-api` |

## 설치

```bash
git clone https://github.com/green-ribbon/claude-shared-config.git
cd claude-shared-config

# 전체 설치 (전역 CLAUDE.md + 프로젝트별 설정 + AgentShield)
./install.sh /Users/gr/IdeaProjects/greenribbon-api /Users/gr/IdeaProjects/agent-work-manage-api

# 전역 CLAUDE.md만 설치
./install.sh --global-only
```

## 설치되는 항목

| 항목 | 설치 위치 | 설명 |
|------|----------|------|
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | 전역 공통 규칙 (API Convention, DTO Rules, Git Convention 등) |
| `agents/` (7개) | 프로젝트/.claude/agents/ | 역할 기반 코드리뷰 에이전트 |
| `skills/` (8개) | 프로젝트/.claude/skills/ | 워크플로우 스킬 |
| `hooks/` (6개) | 프로젝트/.claude/hooks/ | 자동화 훅 |
| `ecc-agentshield` | 글로벌 (`npm -g`) | Claude Code 설정 보안 스캔 |
| `settings.json` | 프로젝트/.claude/settings.json | 훅 등록 설정 |
| `standards/` (10개) | 프로젝트/docs/standards/ | 설계/구현/리뷰 표준 문서 |
| `README.md` | 프로젝트/docs/claudeguide.md | 이 문서 (Claude 사용 가이드) |

### 설치하지 않는 것 (프로젝트 고유)

| 항목 | 위치 | 이유 |
|------|------|------|
| 프로젝트 CLAUDE.md | 프로젝트 루트 `CLAUDE.md` | 모듈, 패키지 구조, Local Dev 등 프로젝트마다 다름 |
| settings.local.json | 프로젝트/.claude/settings.local.json | 허용 명령어가 프로젝트마다 다름 |

## 재실행 시 동작 (스마트 갱신)

install.sh는 checksum 기반으로 변경을 감지한다.

| 상황 | 동작 |
|------|------|
| 공유 레포 변경 없음, 프로젝트 수정 있음 | **스킵** (프로젝트 수정 보존) |
| 공유 레포 변경 있음, 프로젝트 수정 없음 | **갱신** |
| 양쪽 다 변경 | **갱신** + 기존 `.bak` 백업 + diff 안내 |
| 신규 파일 | **설치** |

## 구조

```
claude-shared-config/
├── CLAUDE.md                          # 전역 공통 규칙 → ~/.claude/CLAUDE.md
├── README.md                          # 이 문서 → docs/claudeguide.md
│
├── agents/                            # 코드리뷰 에이전트 → .claude/agents/
│   ├── backend-architect-orchestrator.md   # PDCA 전체 조율
│   ├── spring-architect.md                 # Spring 설계 검토
│   ├── security-reviewer.md                # 인증/인가/보안
│   ├── db-performance-reviewer.md          # DB/QueryDSL/N+1
│   ├── api-contract-reviewer.md            # API 계약/버전 관리
│   ├── observability-reviewer.md           # Datadog 관측성
│   └── qa-regression-reviewer.md           # 테스트/회귀 위험
│
├── skills/                            # 워크플로우 스킬 → .claude/skills/
│   ├── backend-pdca/                       # PLAN→DESIGN→구현→CHECK
│   ├── backend-act/                        # 배포 후 회고
│   ├── commit/                             # 커밋 + 푸시 + PR 관리
│   ├── code-review/                        # 코드 리뷰
│   ├── external-api-integration/           # 외부 API 연동 리뷰
│   ├── spring-observability/               # Datadog 관측성 설계
│   ├── security-scan/                      # AgentShield 보안 스캔
│   └── continuous-learning-v2/             # 세션 학습 (ECC)
│
├── hooks/                             # 자동화 훅 → .claude/hooks/
│   ├── pdca-phase-guard.sh                 # PDCA 단계 전환 시 사용자 확인
│   ├── impl-step-guard.sh                  # 테스트 성공 후 다음 Step 확인
│   ├── external-api-guard.sh               # 외부 API 코드 감지 시 리뷰 리마인드
│   ├── erd-generate-guard.sh               # migration 변경 시 ERD 자동 생성
│   ├── guide-update-guard.sh               # PDCA 문서 변경 시 가이드 문서 갱신
│   └── security-scan-on-stop.sh            # 세션 종료 시 보안 스캔
│
├── standards/                         # 표준 문서 → docs/standards/
│   ├── backend-rules.md                    # 아키텍처, 트랜잭션, 예외처리, 테스트
│   ├── security-rules.md                   # 인증/인가, 입력검증, PII
│   ├── db-rules.md                         # JPA, N+1, 인덱스, 락
│   ├── observability-rules.md              # metric+log+trace, Datadog
│   ├── metric-spec.md                      # 메트릭 네이밍, 태그 정책
│   └── pdca/                               # PDCA 템플릿
│       ├── spring-backend-plan.md
│       ├── spring-backend-design.md
│       ├── spring-backend-check.md
│       ├── spring-backend-act.md
│       └── act-input-template.md
│
├── settings.json                      # 훅 등록 설정 → .claude/settings.json
└── install.sh                         # 설치 스크립트
```

## CLAUDE.md 구조

Claude Code는 세션 시작 시 모든 계층의 CLAUDE.md를 자동으로 합쳐서 로드한다.

```
~/.claude/CLAUDE.md              # 공통 규칙 (install.sh가 설치)
프로젝트/CLAUDE.md               # 프로젝트 고유 정보 (직접 작성)
```

| 계층 | 내용 |
|------|------|
| **공통** (`~/.claude/CLAUDE.md`) | API Convention, DTO Rules, Git Convention, Code Style, Infrastructure, Migration, Standards 참조, 작업 프로세스, Token Rules |
| **프로젝트** (루트 `CLAUDE.md`) | Stack, Modules, Package Structure, Migration 경로, Local Dev |

---

# Claude 사용 가이드

## 작업 유형별 프로세스

| 유형 | 기준 | 스킬 |
|------|------|------|
| **Full PDCA** | 신규 기능, 외부 연동, 2일+ 작업, 도메인 간 영향 | `/backend-pdca` + `/backend-act` |
| **Code Review Only** | 버그 수정, 리팩토링, 의존성 변경, 1일 이내 | `/code-review` |
| **Skip** | 문서 수정, 설정 변경, 오타 수정 | 없음 |

---

## 1. 신규 기능 개발 (Full PDCA)

### 사전 준비

요구사항 문서를 `docs/{domain}/` 하위에 작성한다. (예: `docs/member/requirements.md`)

요구사항 문서에 JIRA 티켓 번호가 포함되어 있지 않으면 Claude가 물어본다.

### PLAN → DESIGN → 구현 → CHECK

```
/backend-pdca docs/{domain}/requirements.md
```

하나의 스킬 호출로 CHECK까지 진행된다. 각 단계 사이에 사용자 확인을 받으며, 별도로 명령어를 다시 칠 필요 없다.

```
나: /backend-pdca docs/member/requirements.md

Claude: [PLAN 작성] → docs/member/20260408/plan.md 저장
Claude: "PLAN 확인해주세요"
나: "OK"

Claude: [DESIGN 작성 (1~8: 상세 설계, 9: 테스트 설계, 10: 구현 Step)] → docs/member/20260408/design.md 저장
Claude: "DESIGN 확인해주세요"
나: "OK"

Claude: [구현 Step 1] (기존 코드 조사 → TDD: RED→GREEN→REFACTOR)
Claude: "Step 1 확인해주세요"
나: "OK"

Claude: [구현 Step 2]
Claude: "Step 2 확인해주세요"
나: "OK"
...

Claude: [CHECK] → docs/member/20260408/check.md 저장
Claude: "CHECK 확인해주세요"
나: "OK" → 세션 종료, 배포 진행
```

### ACT (배포 후 별도 진행)

배포 후 운영 결과를 관찰한 뒤, `docs/standards/pdca/act-input-template.md` 양식을 복사하여 작성한다.

```
나: /backend-act docs/member/20260408/act-input.md

Claude: plan.md, design.md, check.md + act-input.md 종합
Claude: → docs/member/20260408/act.md 저장
Claude: "standards 반영 대상이 있습니다. 확인해주세요"
나: "OK" → docs/standards/ 반영
```

### DESIGN 구조 (spring-backend-design.md)

| 섹션 | 내용 |
|------|------|
| 0. 설계 범위 | 대상 기능, 영향 서비스, 영향 테이블 |
| 1. 아키텍처 구조 | Controller/Service/Domain/Repository 구조 |
| 2. API 설계 | Endpoint, DTO, Error Model |
| 3. 도메인 설계 | Entity/Aggregate, 상태 전이, 정책 |
| 4. 데이터 설계 | 테이블, 인덱스, 조회 패턴 |
| 5. Transaction 전략 | boundary, readOnly, 락/경합 |
| 6. 외부 연동 설계 | timeout, retry, fallback |
| 7. 보안 설계 | 인증/인가, PII, 입력 검증 |
| 8. Observability 설계 | 로그, metric, trace, alert |
| 9. 테스트 설계 | 단위/통합/슬라이스 대상, 회귀 포인트 |
| 10. 구현 Step | Step별 대상 + 테스트 + 산출물 |

### 산출물 구조

```
docs/{domain}/{yyyyMMdd}/
  ├── plan.md        ← 문제 정의, 목표, 제약조건, 리스크
  ├── design.md      ← 상세 설계 (1~8) + 테스트 설계 (9) + 구현 Step (10)
  ├── check.md       ← 코드/설계/DB/보안/운영 리뷰
  ├── act-input.md   ← 사용자가 작성하는 운영 결과 입력
  └── act.md         ← Claude가 작성하는 회고 + standards 환원
```

---

## 2. 버그 수정 / 리팩토링 (Code Review Only)

```
/code-review
```

구현 후 리뷰만 수행한다.

```
나: (버그 수정 코드 작성)
나: /code-review
→ 구조/트랜잭션/DB/보안/관측성/테스트 관점 리뷰
→ 공격자 관점 취약점 탐색 (SSRF, SQL Injection, Command Injection, Path Traversal, Auth Bypass)
```

---

## 3. 외부 API 연동

```
/external-api-integration
```

timeout/retry/fallback/circuit breaker 종합 검토.

---

## 4. 관측성 설계

```
/spring-observability
```

Datadog metric/log/trace/alert 설계.

---

## 5. 커밋 / 푸시 / PR

```
/commit
```

git commit/push는 반드시 이 스킬을 통해 수행한다. 자연어로 "커밋해줘"라고 하지 않는다.

```
나: /commit

Claude: [브랜치 확인] feature/IVS-159
Claude: [변경사항 분석]
Claude: 커밋 메시지:
  IVS-159:feat: 보장분석 리포트 PDF 다운로드 기능 추가

  변경 사항:
  - ReportController PDF 엔드포인트 추가
  - ReportService PDF 생성 로직 구현

  Deploy-Note: 보장분석 리포트를 PDF로 다운로드할 수 있습니다.

Claude: "이 메시지로 커밋할까요?"
나: "OK"
Claude: [커밋 완료]
Claude: "푸시할까요?"
나: "OK"
Claude: [푸시 완료]
Claude: [PR 확인 → Deploy Note 갱신]
```

### Deploy-Note
- 비개발자(영업, 기획, 운영)가 읽는 배포 공지용 한 줄 요약
- 기술 용어 사용 금지, 사용자/고객 관점으로 작성
- GitHub Actions가 PR body의 `## Deploy Note` 섹션을 추출하여 Slack 배포공지에 전송

### PR 자동 관리
- PR이 없으면: 커밋 내역 분석 → PR 자동 생성 (사용자 확인 후)
- PR이 있으면: 전체 커밋의 Deploy-Note를 통합하여 PR body 갱신
- 같은 PR 내 중복/유사 Deploy-Note는 한 문장으로 합침

---

## 6. 보안 스캔

```
/security-scan
```

AgentShield를 사용하여 Claude Code 설정(`.claude/`)의 보안 취약점을 스캔한다.

### 스캔 대상

| 파일 | 검사 내용 |
|------|----------|
| CLAUDE.md | 하드코딩된 시크릿, 프롬프트 인젝션 패턴 |
| settings.json / settings.local.json | 과도한 허용 목록, 거부 목록 부재, 위험 명령 |
| hooks/ | 명령어 인젝션, 데이터 유출 |
| agents/*.md | 제한되지 않은 도구 접근 |

### 실행 방법

| 방법 | 명령 | 설명 |
|------|------|------|
| 수동 | `/security-scan` | 필요할 때 직접 호출 |
| 주기적 | `/loop 5m /security-scan` | 세션 중 5분마다 자동 (간격 조절 가능) |
| 자동 | 세션 종료 시 Stop hook | 설정 불필요, 자동 실행 |
| 심층 | `npx ecc-agentshield scan --opus` | Red/Blue/Auditor 3-에이전트 분석 (API 키 필요) |

---

## 7. 문서/설정/오타 수정

스킬 없이 바로 구현 → `/commit`으로 커밋.

---

## Hooks (자동 강제)

Claude Code hooks가 다음을 자동으로 강제한다. 개발자가 별도로 설정할 필요 없다.

| Hook | 트리거 | 동작 | 프로필 |
|------|--------|------|--------|
| `pdca-phase-guard` | plan/design/check/act.md 파일 저장 시 | 다음 PDCA 단계 전환 전 사용자 확인 강제 | strict |
| `impl-step-guard` | gradle test 성공 시 | 다음 구현 Step 전환 전 사용자 확인 강제 | strict |
| `external-api-guard` | Java 파일에 WebClient/RestTemplate/Redis 등 감지 시 | 외부 연동 리뷰 리마인드 | standard+ |
| `guide-update-guard` | git commit 후 PDCA 문서 변경 감지 시 | 해당 도메인의 guide.md 갱신 | standard+ |
| `erd-generate-guard` | migration 파일 staged 시 | ERD 자동 생성 | standard+ |
| `security-scan-on-stop` | 세션 종료 시 | AgentShield 보안 스캔 | 항상 |

### Hook 프로필 시스템

스킬에 따라 hook 실행 범위가 자동 조절된다. 사용자가 별도로 설정할 필요 없다.

| 스킬 | 프로필 | 실행되는 hook |
|------|--------|-------------|
| `/backend-pdca` | strict | 전체 hook |
| `/code-review` 등 | standard | external-api, guide-update, erd, observe |
| `/commit` 또는 스킬 없음 | minimal | observe만 |

프로필은 `.claude/.hook-profile` 파일로 관리된다. 스킬 시작 시 자동 설정, 종료 시 minimal로 초기화.

---

## Continuous Learning (세션 학습)

[ECC(everything-claude-code)](https://github.com/affaan-m/everything-claude-code)의 continuous-learning-v2 스킬을 도입했다. Claude Code 세션에서 반복되는 패턴을 자동으로 감지하고 학습한다.

### 동작 방식

1. **자동 관찰** — 매 도구 호출마다 `observe.sh`가 관찰 기록을 쌓음 (`~/.claude/homunculus/projects/<hash>/observations.jsonl`)
2. **패턴 분석** — observer가 활성화되면 20개 이상 관찰 수집 후 5분 간격으로 패턴 분석 (user correction, error resolution, repeated workflow)
3. **instinct 생성** — "하나의 트리거 → 하나의 액션" 형태의 패턴으로 저장 (confidence 0.3~0.9)

observer는 기본 비활성 상태이며, `skills/continuous-learning-v2/config.json`에서 `enabled: true`로 변경하면 활성화된다.

### 명령어

| 명령 | 용도 |
|------|------|
| `/instinct-status` | 학습된 패턴 목록 + confidence 확인 |
| `/evolve` | 관련 패턴을 클러스터링해서 skill/command로 승격 |
| `/instinct-export` | instinct를 파일로 내보내기 |
| `/instinct-import <file>` | 외부 instinct 가져오기 |
| `/promote` | 프로젝트 패턴을 전역으로 승격 |
| `/projects` | 프로젝트별 instinct 현황 |

### 데이터 저장 위치

모든 데이터는 로컬(`~/.claude/homunculus/`)에만 저장된다. git이나 외부로 전송되지 않는다.

---

## 강제 vs 비강제

### 자동 적용 (매 대화 로드, 설정 불필요)
- CLAUDE.md: `/commit` 스킬 필수 사용, API 컨벤션, Code Style
- .claudeignore: 불필요 파일 컨텍스트 제외
- Hooks: PDCA 단계/구현 Step 전환 시 사용자 확인 강제, 외부 API 연동 감지, 보안 스캔

### 수동 호출 필요 (개발자가 직접 스킬 호출)
- `/backend-pdca` — PLAN → DESIGN → 구현 → CHECK
- `/backend-act` — 배포 후 회고
- `/commit` — 커밋 + 푸시 + PR 관리
- `/code-review` — 코드 리뷰
- `/external-api-integration` — 외부 연동 리뷰
- `/spring-observability` — 관측성 설계
- `/security-scan` — 보안 스캔
- `docs/standards/*.md` — 스킬 호출 시에만 참조됨

---

## 규칙 수정

### 공통 규칙 수정

1. 이 레포에서 수정 후 커밋/푸시
2. 각 프로젝트에서 `install.sh` 재실행

### 프로젝트에서 미세 조정

프로젝트에서 설치된 파일을 직접 수정할 수 있다. 공유 레포 원본이 변경되지 않는 한 다음 install.sh 실행 시에도 수정 내용이 보존된다.

공유 레포 원본이 변경된 경우 갱신되며, 프로젝트 수정분은 `.bak` 파일로 백업된다.
