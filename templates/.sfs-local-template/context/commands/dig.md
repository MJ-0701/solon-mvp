---
id: sfs-command-dig
summary: Bottom-up excavation of an undocumented codebase — deterministic L0 scan + ERD and L1 graph, capsule-delegated L2 fact cards, L3 synthesis with marked inference, L4 confirmation states.
load_when: ["dig", "excavation", "역추적", "무문서", "인수인계 없음", "ERD 추출", "reverse-spec", "fact card", "코드베이스 인수"]
---

# Dig (Excavation Pipeline)

인계 문서 없는 코드베이스를 코드→증거→합성 방향(아래→위)으로 역추적한다.
tidy(위→아래: 요약→위키 승격)의 교체가 아니라 **앞단 공급원** — dig 산출물이
`tidy --wiki-promote` 의 입력이 된다. 대상 저장소 소스는 **read-only** — dig 는
대상 코드를 절대 수정하지 않고, 산출물은 `docs/solon/<domain>/excavation/` 에만
쓴다(쓰기는 `--write` consent 필요, 없으면 stdout 프리뷰).

## 레이어 (결정론 코어 / LLM 지정 지점)

| layer | 내용 | 실행 주체 |
|---|---|---|
| L0 | `sfs dig scan` — 프레임워크/엔트리포인트/라우트/env키/스키마소스 + ERD | 결정론 (LLM 0토큰) |
| L1 | `sfs dig graph` — import/route→handler→service→table + BFS L2 큐 | 결정론 (LLM 0토큰) |
| L2 | fact card 작성 — 큐 항목별 캡슐 위임 | LLM (캡슐), 검증은 결정론 |
| L3 | feature-map / reverse-spec / unknowns 합성 | LLM, 규칙은 본 문서 |
| L4 | unverified→corroborated→verified 확증 전이 | 결정론 파생 (`card validate`) |

- ERD-first: `erd.md` 가 첫 산출물. 실 DB 접근 가능하면 사용자가 직접
  `information_schema.columns` 를 TSV 로 덤프해 `--live-schema <tsv>` 로 diff
  (`erd-diff.md`). **접속 정보는 dig 가 받지도 저장하지도 않고, 데이터 로우는
  어떤 산출물에도 들어가지 않는다 — 스키마 구조만.**
- 외부 그래프 도구(tree-sitter/madge/jdeps)는 opt-in 보강 — 미설치 시 grep
  축소 모드가 기본이고 그것으로 완결이다 (제거해도 동일 동작).

## 순서 규율 (L2 게이트 — signal-only)

Sanity(harness doctor) pass 또는 기록된 waiver 없이 L2 캡슐을 dispatch 하지
않는다 — readiness-before-cartography(`policies/harness-readiness.md`)의 dig
적용이다. `l2-queue.md` 헤더의 `L2-GATE: READY|NOT-READY` 가 결정론 마커고,
waiver 는 `sfs dig scan --write --waive-sanity "<이유>"` 또는 기존
`.sfs-local/readiness-waiver` 로 기록한다. 파일 생성 자체는 막지 않는다
(ALT-INV-3 — 게이트는 순서 규율이지 verdict 가 아니다).

## L2 fact card (캡슐 위임 계약)

큐 항목별로 워커 캡슐(`policies/sub-agent-capsule-contract.md` 8필드) 을 발행
한다. **발행은 결정론 헬퍼가 한다**: `sfs dig capsule [--next|--target <file>]
--write` 가 큐에서 항목을 골라 8필드 캡슐을 생성한다 — `goal` = 카드 1장,
`files_scope` = 해당 모듈 + L1 그래프의 직접 의존/피의존, `output_paths` =
`excavation/cards/<card_id>.md`, `exemplar` = 기존 검증 통과 카드 1장 자동
포인터(첫 카드면 생략 허용). capsule 발행이 L2 게이트의 집행점이다 —
NOT-READY 큐에서는 발행을 거부하고 waiver 경로를 안내한다 (exit 3,
act-directly 계열; dig 밖 명령은 아무것도 막지 않는다).

카드 고정 스키마 (검증기 `sfs dig card validate` 가 강제):

```
---
card_id: <slug>            # 필수
target: <file:line-range>  # 필수
confidence: 0|1|2          # 필수 — 이 스케일 밖이면 REJECT
---
## Purpose / ## Inputs/Outputs / ## Side effects / ## Tables / ## Calls   # 전부 필수
## Evidence                # file:line 인용 1개 이상 — 없으면 REJECT
## Runtime evidence        # 선택 — 있으면 L4 verified 파생
```

- **근거 없는 서술은 검증기가 reject 한다** — 환각 차단은 LLM 프롬프트가 아니라
  결정론 검증기 소유다. 존재하지 않는 파일 인용도 reject.
- 저장은 기존 evidence 프리미티브 재사용 — 카드는 excavation 디렉토리의 MD 파일,
  결정/승인은 `sfs capture`. 신규 저장소 개념 금지.
- 커버리지는 `sfs dig status` — 카드 수 / 함수 규모(scan 이 기록) %.

## L4 확증 상태 (결정론 파생)

`card validate` 가 카드 내용에서 파생한다 — 저장된 상태 필드 없음, 전이는 판정:

- **unverified** — 근거 파일 1곳.
- **corroborated** — 독립 근거 파일 2곳 이상 일치.
- **verified** — `## Runtime evidence` 존재 (로그/실DB diff/테스트 실행 확인).

전부 signal-only — 상태가 어떤 명령도 막지 않는다.

fact card 의 `file:line` 근거 포인터는 이후 sprint plan 의 `references` 필드
(`policies/unknowns-and-deviations.md` REFERENCES_FIELD) 에 그대로 넣을 수 있는
기성 항목이다 — 발굴된 영토가 다음 계약의 지도가 된다.

## L3 합성 규칙

카드가 쌓이면 클러스터링해 두 산출물을 작성한다:

- `feature-map.md` — 기능 지도: 라우트/카드 클러스터 → 기능 단위, 각 항목에
  카드 링크.
- `reverse-spec.md` — 역-기획서(추정 요구사항정의서). **모든 추론 문장은
  `#추정` 표기 + 근거 카드 링크 필수** — 카드 없는 추론 문장은 리뷰 finding.

`unknowns.md` — 확신도 0-1 카드, 근거 부족 항목, erd-diff 의 코드↔DB 불일치를
자동 수집해 **외주사 질문 리스트** 포맷으로: `질문 / 관련 카드 / 답을 얻으면
갱신할 산출물`. 인수인계 미팅의 핵심 지참물이다. honest-unknowns 계약
(`policies/flow-conformance-postflight.md` HONEST_UNKNOWNS)의 dig 적용 —
"첫 그럴듯한 결론"은 unknowns 로 내리고 확신도로 구분한다.

위키 승격은 마지막에만: `sfs tidy --wiki-promote` 경유 (자동 승격 금지,
기존 opt-in 파이프라인).

## 경계

- 대상 저장소 read-only — dig 는 대상 코드 수정 절대 금지.
- 쓰기는 `--write` consent 필요; 산출물은 excavation 디렉토리에만.
- env 값·DB 접속 정보·데이터 로우는 어떤 산출물에도 불록 — 키 이름/스키마
  구조만 (`policies/credential-hygiene.md`).
- 모든 판정 signal-only; hard-block 없음.
- healthcheck 가 excavation 정합(무효 카드 수·게이트 상태)을 advisory 로
  surface 한다 (verdict/exit 불변).
