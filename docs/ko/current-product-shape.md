# 현재 제품 흐름과 최근 변화

**Language**: 한국어 / [English](../en/current-product-shape.md)

이 문서는 최근 Solon Product 패치들의 결과를 한 번에 이해하기 위한 문서입니다. 핵심은
명령어를 더 많이 외우게 만드는 것이 아니라, 사용자가 AI 시대에도 product owner 로서
생각의 근육을 잃지 않게 하는 흐름을 만드는 것입니다.

## 한 줄 요약

Solon 은 `start → brainstorm → plan → implement → review → retro` 를 통해
모호한 의도를 검증 가능한 작업 계약으로 바꾸고, AI 가 빠르게 실행하더라도 사람의 판단,
용어, 설계, 검증 흐름이 사라지지 않게 합니다.

```text
fuzzy intent
→ shared understanding
→ plan contract
→ small implementation slice
→ artifact acceptance review
→ retro close with report
```

## Start 이후의 인계

`sfs start "<goal>"` 는 sprint workspace 를 만들고 끝나는 명령입니다. 다만 새 요구 탐색에는
대부분 brainstorm 이 필요하므로, start 성공 출력은 사용자가 가이드를 읽지 않았어도 다음 선택지를
볼 수 있게 안내합니다.

```text
next: sfs brainstorm --simple "..."  # 빠른 정리
      sfs brainstorm "..."           # 기본값, normal thinking scaffold
      sfs brainstorm --hard "..."    # product owner hard training
```

이 안내는 새 명령 체계를 강요하려는 것이 아닙니다. 사용자의 원래 명령어는 계속 `sfs brainstorm`
입니다. 다만 Solon 이 지금 작업의 성격에 맞는 depth 를 드러내 줍니다.

## Brainstorm 3단계

| Mode | 별칭 | 역할 |
|---|---|---|
| `--simple` | `--easy`, `--quick` | 이미 방향이 뚜렷한 작업을 빠르게 정리하고 plan seed 로 넘김 |
| 기본 `normal` | 없음 | 요구사항을 정리하면서도 핵심 모순, 우선순위, 성공 기준, 검증 방식을 몇 가지 질문함 |
| `--hard` | 없음 | 사용자가 product owner 로 깊게 생각하도록 의도, 포기할 것, 경계, 용어를 집요하게 캐물음 |

초기에는 `normal` 이 단순 요약처럼 보일 수 있었지만, 이제 기본값도 사용자가 더 생각하게 만드는
방향이 맞습니다. 차이는 강도입니다.

- `simple`: 이미 답이 있을 때 빠른 정리
- `normal`: 대부분의 작업에 맞는 기본 사고 scaffold
- `hard`: 제품 판단과 설계가 흐릿할 때 쓰는 hard training

## Hard Mode 의 목적

`brainstorm --hard` 는 AI 가 "좋아, 바로 할게" 하고 달려가는 흐름을 일부러 늦춥니다.
사용자에게 자잘하지만 중요한 질문을 계속 던져서 아래 항목을 드러냅니다.

- 진짜 해결하려는 문제
- 서로 충돌하는 욕구
- 우선순위와 포기할 것
- 성공/실패를 판정할 방식
- 작업의 경계와 하지 않을 것
- 프로젝트 안에서 써야 하는 용어

이 모드는 AI 도움을 줄이는 기능이 아니라, AI 가 일을 시작하기 전에 사용자의 소유권과 판단력을
더 강하게 세우는 기능입니다.

## Plan 은 transcript 가 아니라 계약

`sfs plan` 은 brainstorm 대화를 예쁘게 옮기는 단계가 아닙니다. plan 은 다음 항목을 포함해야 합니다.

- measurable acceptance criteria
- 이번 sprint 에 포함할 scope 와 제외할 scope
- feedback loop 또는 smoke/test/review 방식
- evaluator 가 어떤 기준으로 통과/보류/실패를 판단할지
- 다음 구현 slice 가 무엇인지

중요한 owner decision 이 비어 있으면 plan 을 추측으로 채우지 않습니다. 질문을 유지하고,
사용자의 판단을 기다립니다.

## Implement 는 코드만 뜻하지 않는다

`sfs implement` 의 산출물은 코드일 수도 있지만, Solon 에서는 아래도 모두 implementation artifact 입니다.

- documentation update
- strategy memo
- design handoff
- taxonomy 또는 domain language 정리
- QA evidence
- ops/runbook
- release packaging

AI coding 시대에는 "구현"이라는 말이 코드 파일만 가리키면 작업 흐름이 좁아집니다. Solon 은
사용자가 만든 실제 artifact 를 기준으로 다음 review lens 를 정합니다.

## Review 는 artifact acceptance review

`sfs review` 는 코드리뷰 하나가 아닙니다. 같은 명령어를 유지하되 Solon 이 sprint evidence 와
변경 artifact 를 보고 lens 를 자동 추론합니다.

| Lens | 주로 보는 것 |
|---|---|
| `code` | correctness, tests, regressions, maintainability |
| `docs` | reader flow, accuracy, stale claims, missing links |
| `strategy` | decision quality, tradeoffs, feasibility, next action |
| `design` | user flow, consistency, visual/interaction evidence |
| `taxonomy` | terms, categories, naming boundaries |
| `qa` | coverage, smoke evidence, reproduction, residual risk |
| `ops` | runbook, deployment, rollback, observability |
| `release` | version, changelog, package channel, verification |

사용자는 계속 `sfs review` 라고만 말하면 됩니다. `--lens` 는 Solon 의 추론이 틀렸을 때만 쓰는
override 입니다.

## Retro 는 기본적으로 sprint close

예전에는 `retro` 와 `retro --close` 가 나뉘어 있었지만, 실제 제품 흐름에서는 close 까지 해야
마무리입니다. 그래서 현재 기본값은 아래와 같습니다.

```text
sfs retro
```

이 명령은 `report.md` 와 `retro.md` 를 정리하고, workbench 원문을 archive 로 접고, sprint close 상태와
local close commit 까지 연결합니다. 초안만 열고 싶을 때는 명시적으로 `sfs retro --draft` 를 씁니다.

## 문서 구조

README 는 전체 설명을 다 담는 파일이 아니라 큰 흐름과 목차입니다. 자세한 철학과 판단 기준은
별도 문서로 분리합니다.

```text
README.md
docs/ko/index.md
docs/en/index.md
docs/ko/current-product-shape.md
docs/en/current-product-shape.md
docs/ko/10x-value.md
10X-VALUE.md
GUIDE.md
docs/en/guide.md
```

GitHub Markdown 은 언어 전환 탭을 기본 지원하지 않습니다. 그래서 Solon 은 문서 상단의
`Language` 링크를 표준으로 씁니다.

## Token / Harness Hygiene

SFS 는 Claude plugin 을 모든 사용자에게 설치하지 않습니다. 대신 그 플러그인들이 해결하는
문제를 SFS 운영 흐름 안에 흡수합니다.

- Session Report 계열: 토큰이 빨리 닳는 느낌이 있으면 usage report 를 먼저 확인한다.
- CLAUDE.md Management 계열: adapter 문서는 얇게 유지하고, 긴 규칙은 routed context/docs 로 뺀다.
- Serena 계열: 큰 코드베이스에서는 전체 파일 읽기보다 symbol/semantic search 를 우선한다.
- Hookify 계열: 반복 실수는 다음에도 설명할 말이 아니라 guardrail/check/hook 으로 바꾼다.

이 원칙은 특정 Claude plugin 에 묶이지 않습니다. Codex, Gemini, 다른 agent 도 각자 가진
usage report, LSP/index, hook/check 수단으로 같은 hygiene 를 적용합니다.

## 언제 어떤 모드를 고르나

| 상황 | 추천 |
|---|---|
| 이미 구현할 범위가 분명함 | `sfs brainstorm --simple` 또는 바로 `sfs plan` |
| 새 기능을 처음 정의함 | `sfs brainstorm` |
| 사용자의 의도와 우선순위가 흔들림 | `sfs brainstorm --hard` |
| 설계/용어/검증 기준이 불명확함 | `sfs brainstorm --hard` |
| 이전 sprint 의 plan/ADR 을 이어받음 | inherit 기록 후 바로 `sfs implement` |

Solon 의 좋은 사용감은 빠르게 달리는 것이 아니라, 피드백 없이 너무 멀리 달리지 않는 것입니다.
