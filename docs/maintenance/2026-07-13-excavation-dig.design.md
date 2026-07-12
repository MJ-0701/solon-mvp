---
doc_id: excavation-dig-design
title: "Design — sfs dig: 무문서 코드베이스 역추적 파이프라인"
visibility: oss-public
doc_type: design-doc
language: ko
updated: 2026-07-13
summary: "인계 문서 없는 코드베이스를 코드→증거→합성으로 역추적하는 excavation 파이프라인. 결정론 코어(L0 스캔+ERD / L1 그래프+큐 / 카드 검증기 / L4 확증 파생) + LLM 지정 지점(L2 카드, L3 합성). 네이밍 결정 D1 포함."
load_when: "sfs dig / excavation 파이프라인의 설계 근거, 네이밍 결정, 레이어 경계를 확인할 때."
---

# Design — `sfs dig` (excavation pipeline)

- **status**: shipped (0.9.0)
- **date**: 2026-07-13
- **scope**: 무문서 인계 코드베이스 역추적 — 프로젝트 개요·ERD 를 코드에서 복원

## 1. 문제

외주 빌드 인수 상황: 인계 문서·기획서·요구사항정의서 없음, 깃 히스토리 신뢰
불가. 첫 질문 두 개 — "이 시스템이 뭘 하나"(라우트/기능)와 "데이터가 어떻게
생겼나"(ERD) — 에 코드만으로 답해야 한다.

## 2. 설계 원칙

1. **결정론 코어**: L0~L1 + ERD 추출 + 카드 검증 + 확증 파생은 LLM 0토큰.
   LLM 은 L2(카드 작성)·L3(합성) 지정 지점만.
2. **방향**: dig 는 아래→위(코드→증거→합성). tidy(위→아래, 요약→위키 승격)의
   교체가 아니라 앞단 공급원 — dig 산출물이 `tidy --wiki-promote` 입력.
3. **순서 규율 재사용**: Sanity(harness doctor) pass/waiver 없이 L2 진입하지
   않음 — readiness-before-cartography 의 dig 적용. 마커는 결정론
   (`l2-queue.md` 의 `L2-GATE:`), 판정은 signal-only (ALT-INV-3).
4. **read-only**: 대상 코드 수정 절대 금지. 산출물은
   `docs/solon/<domain>/excavation/` 에만, 쓰기는 `--write` consent.
5. **보안 경계**: env 값·DB 접속 정보·데이터 로우는 어떤 산출물에도 불록.
   키 이름·스키마 구조만 (credential-hygiene 결).

## 3. 결정

- **D1 — 네이밍: `sfs dig` 신설 (harness map 확장 기각).** 근거: (a) harness
  map 은 1-shot 환경 설계도(roles/gates/artifacts)로 의미론이 다름 — dig 는
  자체 산출물 트리 + 상태 + 다단계 순회를 가진 rail; (b) "doctor 섹션, 신규
  서브커맨드 없음"(0.8.63 D5) 선례는 진단을 기존 진단에 흡수한 것 — 결정론
  코어 + 자체 산출물을 가진 rail 은 adopt/ingest/measure/daily 선례를 따라
  명령 신설; (c) 순서 규율 결합은 dig 가 harness doctor 를 호출해 재사용.
  배치는 dist-level `scripts/sfs-dig.sh` (harness 와 동일), consumer dispatch
  미등록 (bin/sfs 직행 — doctor/harness/measure 와 같은 클래스).
- **D2 — ERD 소스 우선순위: SQL 마이그레이션 > Prisma > JPA.** 마이그레이션이
  가장 권위(실제 DDL). 복수 소스 감지 시 상위 하나로 ERD 를 뽑고 나머지는
  스캔 리포트에 소스로만 기록. Sequelize/TypeORM/Django 는 탐지만 (추출 파서
  후속) — 미추출 소스는 unknowns 후보.
- **D3 — 실 DB diff 는 사용자-덤프 TSV 경유.** dig 는 접속 문자열을 받지도
  저장하지도 않는다. 사용자가 `information_schema.columns` 쿼리를 직접 돌려
  TSV 로 전달 (`--live-schema`); diff 는 구조만.
- **D4 — L2 게이트는 마커, 차단 아님.** `l2-queue.md` 헤더의
  `L2-GATE: READY|NOT-READY` 가 결정론 마커. 파일 생성·명령 실행은 막지 않고
  (signal-only), "NOT-READY 상태에서 L2 캡슐 dispatch 금지"는 routed context
  `commands/dig.md` 의 계약 + healthcheck advisory(excavation-gate)로 지탱.
- **D5 — 확증 상태는 저장 필드가 아니라 파생.** `card validate` 가 카드
  내용에서 unverified(근거 1곳)/corroborated(독립 근거 2곳)/verified(runtime
  evidence 존재)를 매 실행 파생 — 상태 동기화 버그 원천 차단.
- **D6 — 외부 그래프 도구는 opt-in 보강.** grep/정규식 축소 모드가 기본이자
  완결 경로. tree-sitter/madge/jdeps 는 설치돼 있어도 기본 경로를 바꾸지
  않는 확장점 (제거해도 동일 동작 계약).
- **D8 — L2 캡슐 발행은 결정론 헬퍼 (`sfs dig capsule`, 0.9.1).** 큐에서
  항목을 골라(`--next`/`--target`) 8필드 캡슐을 생성 — files_scope = 대상 +
  L1 그래프 직접 의존/피의존, exemplar = 첫 validator-PASS 카드 자동 포인터.
  **capsule 발행이 L2 게이트의 집행점**: NOT-READY 큐에서 발행 거부(exit 3,
  act-directly 계열) + waiver 경로 안내. D4 의 "마커는 signal-only" 와 양립 —
  dig 밖 명령은 아무것도 막지 않는다.
- **D7 — flowcheck 아닌 healthcheck 에 정합 점검.** flowcheck 는 방법론 실행
  적합성(이벤트 기반), excavation 정합은 프로젝트 상태 드리프트 — healthcheck
  소관. advisory 2종: 무효 카드 수(excavation-cards), 게이트 추월
  (excavation-gate). 둘 다 이슈 카운트·exit 불변.

## 4. 레이어 계약 (SSoT: routed context `commands/dig.md`)

| layer | 산출물 | 실행 |
|---|---|---|
| L0 | `00-scan.md`, `erd.md`, (`erd-diff.md`) | `sfs dig scan` — 결정론 |
| L1 | `graph.md`, `l2-queue.md` | `sfs dig graph` — 결정론 |
| L2 | `capsules/*.capsule.md`, `cards/*.md` | 캡슐 발행 `sfs dig capsule`(결정론) → 카드 작성(LLM) → `card validate`(결정론) |
| L3 | `feature-map.md`, `reverse-spec.md`(#추정 표기), `unknowns.md`(질문 리스트) | LLM, 규칙은 dig.md |
| L4 | 카드 확증 상태 | 결정론 파생 |

커버리지: `sfs dig status` — 카드 수 / scan 이 기록한 함수 규모 %.

## 5. 회귀 잠금

- `tests/test-dig-scan-erd.sh` — 2 프레임워크 fixture(spring-jpa/node-prisma)
  스캔·ERD·FK·file:line 근거·env 값 불록·live-schema diff·zero-LLM 정적 잠금.
- `tests/test-dig-graph-queue.sh` — import 에지·라우트 체인(route→service→
  table)·BFS 큐·dead-code 후순위·L2 게이트 READY/NOT-READY 양방향.
- `tests/test-dig-card-state.sh` — 카드 스키마 강제·근거 없는 서술 reject·
  유령 파일 인용 reject·확증 3상태 파생·디렉토리 모드 rc.
