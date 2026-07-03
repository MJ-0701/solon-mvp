---
doc_id: cost-signal-readiness-adapter-design
title: "Design — 코스트 지표 파서 어댑터 seam + AI-readiness 채점 루브릭 (P2·P3)"
visibility: oss-public
doc_type: design-doc
language: ko
updated: 2026-07-03
summary: "ai-ready-codebase-token-efficiency design 의 P2(세션 로그 기반 signal-only 코스트 지표)와 P3(Sanity→Cartography readiness 진단)의 구현 전 설계. Claude Code 세션 로그 포맷 조사 결과 + 런타임 어댑터 seam + 결정론 채점 루브릭. 설계만 — 본 문서 시점에 구현 없음."
load_when: "sfs harness doctor 의 코스트/readiness 지표 구현 착수 시, 세션 로그 파서 어댑터 작업 시, readiness 채점 루브릭 논의 시."
---

# Design — 코스트 지표 파서 어댑터 seam + AI-readiness 채점 루브릭

- **status**: P2 구현됨 (0.8.60 — doctor "Cost Signals" 섹션 +
  `scripts/sfs-harness-cost-adapters/claude-code.sh`) / P3 구현됨 (0.8.61 —
  doctor "AI Readiness (Sanity)" 섹션 + `policies/harness-readiness.md` +
  `.sfs-local/readiness-waiver` + map --write 순서 advisory). §6 결정 반영 완료.
  **0.8.62**: Codex/Gemini seam 을 실 어댑터로 채움 (2026-07-03 실측:
  codex rollout JSONL 은 token_count **누적** — 마지막 값 채택, session_meta.cwd
  로 프로젝트 매칭, turn_context.model; gemini chats JSONL 은 per-turn tokens
  합산, projects.json 이 경로→slug 결정론 매핑, tool 이름 미기록 → read/edit 0
  정직 보고) + doctor `SFS_COST_RUNTIME` 어댑터 핀.
- **parent**: [2026-07-03-ai-ready-codebase-token-efficiency.design.md](2026-07-03-ai-ready-codebase-token-efficiency.design.md)
- **date**: 2026-07-03
- **불변 조건**: 모든 신호는 signal-only (ALT-INV-3 never-hard-block). 외부
  그래프 도구 본체 의존 금지. 실 세션 로그를 fixture 로 쓰지 않음 (개인정보 /
  private path hygiene) — 테스트는 합성 fixture 전용.

---

## 1. P2 — 세션 로그 포맷 조사 결과 (Claude Code, 2026-07-03 실측)

위치: `~/.claude/projects/<project-slug>/<session-id>.jsonl` — 프로젝트 경로를
slug 화한 디렉토리 아래 세션당 JSONL 1개. 라인 1개 = 이벤트 1개.

관측된 구조 (라인별 `version` 필드가 있는 **비공식 포맷** — 버전 종속):

- top-level 키: `type` (user / assistant / queue-operation 등), `message`,
  `timestamp`, `sessionId`, `uuid` / `parentUuid`, `isSidechain`, `cwd`,
  `gitBranch`, `version`, `requestId`, `toolUseResult` 등.
- assistant 이벤트의 `message` 에 `model` 과 `usage` 가 실린다:
  `input_tokens`, `output_tokens`, `cache_creation_input_tokens`,
  `cache_read_input_tokens`, `cache_creation.ephemeral_5m_input_tokens` /
  `.ephemeral_1h_input_tokens`, `service_tier`.
- assistant `message.content[]` 의 `tool_use` 블록에 tool 이름이 있어
  read-family (Read / Grep / Glob / WebFetch / Agent-explore) 대
  edit-family (Edit / Write / NotebookEdit) 대 exec (Bash) 분류가 가능하다.
- `isSidechain: true` 라인으로 sub-agent 소비를 lead 소비와 분리 집계 가능.

파생 가능한 지표 (전부 로그만으로 결정론 계산):

| 지표 | 정의 |
|---|---|
| `session_tokens` | usage 합산 (in/out/cache-write/cache-read 분리). |
| `cache_read_ratio` | cache_read / (input + cache_read + cache_creation). |
| `explore_edit_ratio` | read-family tool_use 수 / edit-family tool_use 수. |
| `sidechain_share` | sidechain 라인 토큰 / 전체 토큰. |
| `model_mix` | model 값별 output 토큰 분포 (mid-session swap 탐지 겸용). |

`model_mix` 가 2개 이상 tier 를 보이면 cache-prefix discipline (P1) 위반
후보 — 역시 신호만.

## 2. P2 — 어댑터 seam 설계

- 진입점: `sfs harness cost [--session <id>|--latest]` (신규) 또는
  `sfs harness doctor` 의 지표 섹션. 판정 없음 — 지표 + 경고 라벨만 출력.
- seam: `scripts/sfs-harness-cost-adapters/` 아래 런타임별 어댑터 1파일.
  계약(인터페이스)은 bash 호환:
  - 입력: `detect` (로그 존재 여부 판별) / `emit` (표준 출력으로 지표 레코드).
  - 출력 레코드: `k=v` 라인 나열 (위 표의 지표 키) + `runtime=` + `schema=1`.
  - 미지원 런타임 어댑터는 `detect` 실패만 반환 — doctor 는 "no cost signal
    source" 한 줄로 강등 (실패 아님).
- 1차 구현 대상: Claude Code JSONL 파서 (jq 우선, 없으면 python3, 둘 다
  없으면 detect 실패로 강등). Codex / Gemini 는 seam 만 두고 어댑터 없음.
- 임계 신호 (전부 warn 라벨, 차단 없음 — ALT-INV-3):
  - `cache_read_ratio` 저조 + `model_mix` 복수 tier → prefix-discipline 신호.
  - `explore_edit_ratio` 고율 → "탐색이 토큰 대부분" 가설(L081, 미검증)의
    측정 지점. 도입 전후 수치로 가설을 채택/폐기.
  - `sidechain_share` 0% + 대형 세션 → 위임 미사용 신호 (token-harness 위임
    규율 교차 참조).
- 회귀 잠금: 합성 JSONL fixture (수기 5~10라인) 기반 단위 테스트. 실 로그
  경로를 테스트에 하드코딩하지 않음. "signal-only" 는 테스트로 잠금 —
  어댑터/doctor 가 지표 사유로 비정상 종료하면 FAIL.

## 3. P3 — AI-readiness (Sanity) 채점 루브릭

`sfs harness readiness` (신규, 또는 doctor 의 축 추가). 결정론 bash 채점,
축당 0–2점, 근거 라인 동반 출력. LLM 판단 불개입.

| 축 | 0 | 1 | 2 |
|---|---|---|---|
| self-verification | 테스트 러너 없음 | 러너 있으나 smoke 급 | 러너 + 에이전트가 스스로 실행 가능한 문서화된 명령 |
| dead-code 흔적 | 미사용 파일/브랜치 다수 감지 | 소수 감지 | 감지 없음 (결정론 휴리스틱: 미참조 스크립트, orphan 문서) |
| convention 일관성 | 같은 목적 패턴 3+ 공존 | 2 공존 | 단일 패턴 (예: DTO 변환, 에러 응답, 네이밍) |
| entry-doc 신선도 | 어댑터 문서 stale (참조 파일 부재 등) | 경미 drift | frontmatter 검증 통과 + 참조 무결 |

- 순서 규율 (명문화만, 강제 없음): readiness 감사 통과 또는 명시 waiver 후에
  `sfs harness map --write` 카토그래피를 권장한다 — "Sanity 없이 지도만
  그리면 거짓 정보" (L081-I4). map 자체를 막지 않는다 (signal-only).
- waiver: `.sfs-local/` 상태 파일에 사유 1줄 — 이후 readiness 재실행 시
  waiver 표기와 함께 통과 처리.
- 지식 그래프 (Graphify 계열, L084): 본체 흡수 금지. `obsidian-llm-wiki`
  정책과 같은 **opt-in 포인터** 패턴으로만 문서화 — 그래프 최신성(drift)
  관리 비용 미해결이 본체 의존 금지의 근거.

## 4. 비목표 (부모 설계 §3 승계)

- 코스트/readiness 신호의 hard-block 화 (ALT-INV-3 위반).
- 루트 어댑터 문서에 정책 인라인 (frontmatter-only 유지).
- 특정 외부 그래프/분석 도구에 대한 본체 의존.
- 실 사용자 세션 로그의 fixture 화 또는 경로 하드코딩.

## 5. 회귀 잠금 / 검증 계획

- P2: 합성 fixture 파서 단위 테스트 + signal-only 잠금 테스트 + jq/python3
  부재 시 강등 경로 테스트 (bash 호환 배포 원칙).
- P3: 루브릭 표 ↔ 채점 스크립트 출력 일치 잠금 (축 이름 / 0–2 범위),
  waiver round-trip 테스트, readiness→map 순서 권장 문구 앵커 잠금.
- 릴리스: VERSION semver + CHANGELOG + Gate 6 리뷰 경유.

## 5-A. 설계 원칙 — 결정론적 코어 / 비결정론적 쉘 (2026-07-03 추가 지시 layering)

근거: idea_wiki 강의 노트 085(결정론적 코어)·086(에이전틱 엔지니어), 기존
L078-I12(결정론만 강제력)·L048-I10(결정론 도구 우선)과 한 축. 배경
by-reference (일반화 원칙만 승격, 강연자/벤더/채널 디테일 보류 —
`methodology-7-step.md` 의 map-first 기록과 같은 방식):

- solon 7-step Gate 구조 자체가 결정론적 코어 패턴의 선례다 — 흐름(게이트
  순서·evidence 계약)은 결정론 rail 이 소유하고, LLM 은 게이트 안의 지정
  지점에서만 호출된다 (L085-I5·I8).
- P3 readiness 진단은 '컨텍스트 설계' 역량의 제품화이고, P2 코스트 신호는
  "생성이 빨라질수록 자동 검증 > 눈 리뷰"(L086-I4) 수요에 대한 응답이다 —
  제품 포지셔닝 근거로만 기록.

설계 제약 3건 (P2·P3 파이프라인 적용, 출하 구현 0.8.60-62 대조 결과 포함):

1. **흐름은 결정론 코드가 소유 — LLM 은 지정 지점에서만 선택 호출**
   (L085-I5). 지표 수집(adapter detect/emit)·readiness 채점·순서 advisory
   전부 bash+jq/python3 결정론이고 LLM 호출 지점은 0개다. 지표의 해석·요약은
   doctor 출력을 읽는 세션의 선택 작업이지 파이프라인 단계가 아니다.
   **검증: LLM 없이 파이프라인 완결 ✓** — doctor/adapter 는 오프라인 단독
   실행되며 합성 fixture 테스트가 이를 잠근다.
2. **순서는 상태 머신으로 강제 가능하게 설계 — 차단 대상은 전이 순서지 판정
   결과가 아니다** (L085-I6, ALT-INV-3 양립). 현 출하 상태(Stage 0) =
   advisory: `map --write` 가 readiness advisory/waiver 를 출력만 하고 진입은
   막지 않는다. Stage 1 (미구현, 설계만): `.sfs-local/readiness-state` 상태
   파일 — 상태 {UNAUDITED, SANITY_PASS, WAIVED}, 이벤트 {doctor 채점 완료 /
   waiver 기록 / 구조 변경 감지}, 전환 규칙 "Cartography(map --write) 진입은
   SANITY_PASS 또는 WAIVED 에서만". 낮은 점수도 waiver 로 전이 가능 — 결과
   점수는 어떤 단계도 차단하지 않는다. 프레임워크 검토 결과: 신규 의존성
   불필요 — 기존 `sfs-common.sh` 스타일 k=v 상태 파일 + release-state 마커
   디렉토리 패턴으로 충분.
3. **검증 게이트는 결정론으로 고정** (L085-I7) — 테스트·스키마·fixture 가
   계약을 잠그고, 프롬프트 지시에 의존하는 검증 설계는 금지. 현 구현: emit
   k=v 스키마 byte-일치 테스트, rc-equality signal-only 잠금, 합성 fixture —
   전부 결정론 ✓.

4대 역량 매핑 (L086-I3) — 갭은 기록만, 구현 금지:

| 역량 | solon 표면 | 갭 |
|---|---|---|
| 문제 정의 | `work-delegation-and-startup.md` (요구 복창+클래리파잉) + eval-first plan gate | **문제 정의 품질을 진단하는 표면 부재** — doctor 는 codebase readiness 만 채점, problem-statement readiness 축 없음 (기록만) |
| 컨텍스트 설계 | routed context + `token-harness.md` + P3 readiness | — (제품화 완료) |
| 검증 | Gate 6 + verification automation + P2 cost signals + capsule verifier≠author | — |
| 오케스트레이션 | 7-step rail + division council + capsule contract | — |

## 6. 결정 사항 (2026-07-03 사용자 확정 — 구현 착수 시 이 값이 기준)

1. **진입점 = doctor 통합.** `sfs harness doctor` 에 cost 섹션 추가 (신규
   서브커맨드 없음 — tool-surface budget 유지, command-surface parity 갱신
   불필요). 지표가 커지면 그때 분리 재검토.
2. **JSONL drift = detect 실패 강등.** 파서가 아는 필드를 못 찾으면 "no cost
   signal source" 한 줄로 강등. best-effort 부분 파싱 하지 않음 — 오판 지표보다
   무신호가 안전.
3. **P3 휴리스틱 = 파일-수준만.** 언어별 도구(컴파일러 경고 / linter) 의존
   없이 미참조 스크립트 / orphan 문서 / 동일 목적 패턴 공존 휴리스틱으로 시작.
   결정론 + bash 호환 + 도메인 중립 보장.
4. **waiver = `.sfs-local/` 기존 상태 파일 패턴 재사용.** 사유 1줄 + 날짜
   (예: `.sfs-local/readiness-waiver`). 신규 스키마 발명 없음.
