---
doc_id: sfs-current-product-shape-ko-30
title: "Unknowns 루프 — 지도와 영토의 간극 다루기"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-07-20
parent: docs/ko/current-product-shape.md
summary: "계획(지도)과 코드베이스(영토)의 간극을 스프린트 전 구간에서 다루는 루프: 정찰·시안 fork·인터뷰 게이트·blind_spots·references·deviation ledger·이해 퀴즈, 그리고 healthcheck/doctor 런타임 신호."
load_when: "계획이 자꾸 빗나갈 때, 스펙이 모호할 때, 구현이 계획과 다르게 갈 때, 완료 보고를 믿어도 되는지 판단할 때 읽는다."
---
## Unknowns 루프 — 지도와 영토의 간극 다루기

프롬프트·계획·컨텍스트 묶음은 **지도**이고, 실제 코드베이스·데이터·도메인은
**영토**입니다. 작업 품질의 병목은 모델 성능이 아니라 **이 간극(운영자의
unknowns)을 얼마나 빨리 찾아내는가**입니다. Solon 은 이 간극에 스프린트 전
구간의 터치포인트를 배치합니다. 규약 SSoT 는 routed context
`policies/unknowns-and-deviations.md` — 이 문서는 운영자용 안내입니다.

### 한눈에 보기 (스프린트 타임라인 순)

| 시점 | 기법 | 하는 일 |
|---|---|---|
| 방향 자체가 말로 안 될 때 | **PROTOTYPE_FORK** | 시안 2~4개 + 비교표 → 선택, 탈락 사유 기록 |
| 불확실성 높은 slice 착수 전 | **RECON_RUN_BEFORE_COMMIT** | read-only 정찰(`sfs dig`, 표적 읽기)로 사실 수집 → plan 반영 |
| 킥오프 | **blind_spots 목록** | "말하지 않았지만 결정이 필요한 지점" 목록화, answered/delegated/open 상태 |
| 스펙 확정 전 | **SPEC_INTERVIEW_GATE** | 질문을 영향도순(설계 전복 → 세부)으로 묻고 답을 스펙에 병합, skip 은 명시 기록만 |
| 스펙 작성 | **REFERENCES_FIELD** | 원하는 동작을 이미 하는 코드 포인터(경로/커밋+의도 1줄), 구현 전 필독 |
| 구현 중 | **DEVIATIONS_LOG** | 계획≠영토 발견 시 보수적 선택 + `## Deviations` 기록 + 계속 |
| 완료 주장 시 | **ledger 명시** | entries 또는 `none observed` — 미명시 완료는 unverified |
| 착수/작업 중 막힘 | **SOLVED_ELSEWHERE_FIRST** | "이 저장소 어딘가에서 이미 풀렸다"를 1차 가설로 탐색 |
| 작업 중 발견 | **EVAL_SURFACE_BLIND_SPOT** | 수용기준이 못 보는 축(비용·캐시 등) 발견 시 finding 으로 surface |
| 머지 전후 | **COMPREHENSION_GATE** | 변경 기반 3~5문항 퀴즈 — 운영자 이해도 검증, 오답은 설명 섹션 링크 |

전부 **signal-only** — 어떤 것도 명령을 차단하지 않습니다. 게이트는 artifact
readiness 상태(draft ↔ ready)와 리뷰 finding 만 움직입니다.

### 왜 이 순서인가

- **fork 와 recon 은 형제**입니다: 방향을 모르면 시안으로 고르고(fork), 방향은
  아는데 영토를 모르면 정찰합니다(recon).
- **인터뷰는 스펙을 비웁니다**: 답이 채팅에만 남은 질문은 스펙이 아닙니다.
  미답변 질문이 남으면 plan 은 `status: draft` 로 남고, 건너뛰려면
  `skip: <사유>` 를 명시합니다.
- **deviation 기록은 다음 스프린트의 지도**입니다: 오늘의 이탈 기록이 내일의
  plan 프리플라이트 입력이 됩니다 (lessons SIGNAL → `L-NNN`).
- **퀴즈는 작업이 아니라 운영자를 검증**합니다: Gate 6 리뷰가 작업을 검증하는
  것의 짝 — 무엇을 얻고 무엇을 포기했는지 답할 수 있을 때 채택하십시오.

### 런타임 신호 (자동 advisory)

| 신호 | 표면 | 조건 |
|---|---|---|
| `deviation-ledger` WARN | `sfs healthcheck` | review/report 존재(완료 주장)인데 `## Deviations` ledger 미명시 |
| `plan-readiness` WARN | `sfs healthcheck` | 구현 시작됐는데 인터뷰/blind_spots/references readiness 항목 unchecked |
| "Held-Out Evals" 섹션 | `sfs harness doctor` | held-out eval 케이스 파일 수 (내용 미열람) |

전부 say_warn/info — exit code 를 바꾸지 않습니다.

### eval 짝 (evals scaffold)

`.sfs-local/evals/README.md` 가 held-out 채점 세트의 입구입니다. 케이스 축에
**wrong-premise fixture**(underspecified 프롬프트 + 일부러 틀린 전제 — 판정
대상은 정답이 아니라 반박 여부)가 포함되고, 판정자 자체는 일부러 깨뜨린
fixture 로 fail 방향을 선검증합니다 (`policies/harness-autonomy.md`
JUDGE_NEGATIVE_CONTROL).

### 관련 문서

- 스프린트 레일 전반: [기능 총람](./29-feature-overview.md)
- 위임 캡슐(워커의 deviation 기록 위치): [위임 레퍼토리](./26-delegation-repertoire.md)
- 규약 SSoT: `sfs context cat policies/unknowns-and-deviations`
